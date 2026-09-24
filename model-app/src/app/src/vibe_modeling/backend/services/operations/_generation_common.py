"""Shared helpers for the generation-group primitives.

The three generation primitives (``generate_ecm``, ``shrink_to_mvm``,
``enlarge_to_ecm``) all wrap a Databricks agent job that produces a
ModelVersion. They share:

* Widget construction (the ~28 widget names the notebook expects, derived
  from each primitive's params_model).
* Delta polling (`_business` + `_vibe_progress` snapshot — same query
  shape progress_tracker uses, but pulled into a single non-blocking
  ``observe()`` call rather than the streaming poll loop).
* Lakebase model sync on terminal success.
* Rollback (delete ModelVersion + clear lakebase + un-supersede siblings
  + best-effort uninstall of the agent-installed schema).

Keeping this module local to ``services/operations/`` so the primitives
don't reach back into ``progress_tracker.py`` (which Phase 4 owns and
will rewrite).
"""

from __future__ import annotations

import json
import logging
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any, Optional

from sqlmodel import select

from ...core._names import agent_business_segment
from ...core._paths import model_json_volume_candidates
from ...db_models import AgentConfig, ModelVersion, Run, RunOperation
from ..._query_helpers import (
    next_version_for_scope,
    resolve_lineage_parent,
)
from ...version_resolution_parser import lookup_resolved_version
from ...core._ids import session_id_to_bigint
from ...core._warehouse import get_warehouse_id
from ...core._widgets import build_widget_map
from ...job_launcher import (
    build_job_tags_from_session,
    finalize_widgets_or_raise,
    generate_session_id,
    launch_run,
)
from ...model_sync import ModelSyncService, _SyncEmptyError
from ._protocol import OperationDispatchHandle, OperationObservation, OperationResult

logger = logging.getLogger(__name__)

# Agent's `data_model_scopes` widget vocabulary — the long descriptive
# label is what the notebook expects, even though the volume folder /
# rollback flow uses the short "ecm" / "mvm" form.
SCOPE_LABEL_ECM = "Expanded Coverage Model - ECM"
SCOPE_LABEL_MVM = "Minimum Viable Model - MVM"

# Operation strings the agent recognises. Mirrors `MODEL_PRODUCING_OPS`
# in `job_launcher.py` but kept locally so the primitives don't reach
# into that frozenset (they're a layer above and shouldn't depend on the
# launcher's bookkeeping).
AGENT_OP_NEW_BASE_MODEL = "new base model"
AGENT_OP_SHRINK_ECM = "shrink ecm"
AGENT_OP_ENLARGE_MVM = "enlarge mvm"

# SQL state name returned when a Delta table is missing — matches
# progress_tracker._TABLE_NOT_FOUND. Pulled here so observe() can swallow
# the early-poll case where the agent hasn't created its handshake row
# yet without depending on progress_tracker.
_TABLE_NOT_FOUND = "TABLE_OR_VIEW_NOT_FOUND"


class _ShadowCtx:
    """Lightweight ctx overlay that swaps a fresh ``params`` dict in.

    ``OperationContext`` is a frozen dataclass — primitives that need to
    enrich ``params`` before passing to a shared helper build one of
    these instead of mutating the original. The other fields proxy
    transparently so call sites can treat it like a real
    ``OperationContext``.
    """

    __slots__ = ("_inner", "params")

    def __init__(self, inner: Any, params: dict) -> None:
        self._inner = inner
        self.params = params

    def __getattr__(self, name: str) -> Any:
        return getattr(self._inner, name)


def supersede_same_scope_priors(
    session: Any,
    business_id: str,
    scope: str,
    exclude_id: str,
) -> list[str]:
    """Flip every other ``completed`` ModelVersion of ``(business_id, scope)`` to ``superseded``.

    The conceptual rule: at any point in time there is at most one
    ``completed`` ModelVersion per ``(business_id, scope)``. Creating a
    new ``completed`` version of a given scope implicitly retires every
    previous ``completed`` version of the same scope. Different-scope
    rows are untouched (an ECM and an MVM coexist as the current pair).

    Returns the list of ids that were flipped — used by rollback to
    restore them. Rows already in non-``completed`` terminal states
    (``superseded``, ``failed``, ``cancelled``) are left alone and not
    included in the returned list.

    Raises ``ValueError`` if ``scope`` is empty/whitespace — legacy
    unscoped rows are intentionally not swept (we don't know what
    scope they belonged to and would risk superseding cross-scope).
    """
    if not scope or not scope.strip():
        raise ValueError(
            "supersede_same_scope_priors: scope must be a non-empty string; "
            "refusing to sweep legacy unscoped ModelVersion rows"
        )
    rows = session.exec(
        select(ModelVersion).where(
            ModelVersion.business_id == business_id,
            ModelVersion.scope == scope,
            ModelVersion.id != exclude_id,
            ModelVersion.status == "completed",
        )
    ).all()
    flipped: list[str] = []
    for row in rows:
        row.status = "superseded"
        session.add(row)
        flipped.append(row.id)
    return flipped


def restore_superseded_priors(
    session: Any,
    auto_superseded_ids: list[str],
) -> None:
    """Reverse :func:`supersede_same_scope_priors` for rollback.

    For each id in the list, if the row is still ``superseded``,
    flip it back to ``completed``. Idempotent: rows that have since
    been deleted, or moved to a different status, are left alone.
    """
    for vid in auto_superseded_ids or []:
        if not vid:
            continue
        row = session.get(ModelVersion, vid)
        if row is not None and row.status == "superseded":
            row.status = "completed"
            session.add(row)


def get_agent_job_id(session: Any) -> Optional[int]:
    """Return the configured Databricks job id, or ``None`` if not configured.

    A missing ``AgentConfig`` row or a row without ``job_id`` is treated
    as "agent not yet wired up" — dispatch raises so the orchestrator
    can mark the op failed.
    """
    cfg = session.exec(select(AgentConfig).limit(1)).first()
    if not cfg or not cfg.job_id:
        return None
    return cfg.job_id


def build_generation_widgets(
    *,
    operation: str,
    data_model_scopes: str,
    business: Any,
    catalog: str,
    session_id: str,
    vibe_instructions: str,
    business_context_path: str,
    business_description_override: str,
    model_version: str,
    model_folder: str,
    schema_prefix: str,
    naming_convention: str,
    primary_key_suffix: str,
    schema_suffix: str,
    tag_prefix: str,
    tag_suffix: str,
    table_id_type: str,
    boolean_format: str,
    date_format: str,
    timestamp_format: str,
    cataloging_style: str,
    catalog_prefix: str,
    catalog_suffix: str,
    org_divisions: str,
    business_domains: str,
    classification_levels: str,
    housekeeping_columns: str,
    history_tracking_columns: str,
    generate_samples: bool,
) -> dict[str, str]:
    """Build the ~28-widget map a generation-group agent op expects.

    Thin wrapper around ``core._widgets.build_widget_map``. The signature
    accepts the agent's full ``operation`` + ``data_model_scopes`` strings
    explicitly so each primitive sets them precisely. All other fields
    flow straight through.
    """
    return build_widget_map(
        operation=operation,
        data_model_scopes=data_model_scopes,
        business=business,
        catalog=catalog,
        session_id=session_id,
        vibe_instructions=vibe_instructions,
        business_context_path=business_context_path,
        business_description_override=business_description_override,
        model_version=model_version,
        model_folder=model_folder,
        naming_convention=naming_convention,
        primary_key_suffix=primary_key_suffix,
        schema_prefix=schema_prefix,
        schema_suffix=schema_suffix,
        tag_prefix=tag_prefix,
        tag_suffix=tag_suffix,
        table_id_type=table_id_type,
        boolean_format=boolean_format,
        date_format=date_format,
        timestamp_format=timestamp_format,
        cataloging_style=cataloging_style,
        catalog_prefix=catalog_prefix,
        catalog_suffix=catalog_suffix,
        org_divisions=org_divisions,
        business_domains=business_domains,
        classification_levels=classification_levels,
        housekeeping_columns=housekeeping_columns,
        history_tracking_columns=history_tracking_columns,
        generate_samples=generate_samples,
    )


def widgets_from_params(
    *,
    operation: str,
    data_model_scopes: str,
    params: dict,
    business: Any,
    session_id: str,
    model_version: str = "",
) -> dict[str, str]:
    """Project a primitive's validated ``params`` into agent widgets.

    All three generation primitives share the same field set apart from
    ``operation`` + ``data_model_scopes`` + ``model_version`` (which the
    caller picks). The remaining fields come straight from the validated
    params dict.
    """
    return build_generation_widgets(
        operation=operation,
        data_model_scopes=data_model_scopes,
        business=business,
        catalog=params.get("deployment_catalog", ""),
        session_id=session_id,
        vibe_instructions=params.get("model_vibes", ""),
        business_context_path=params.get("context_file", ""),
        business_description_override=params.get("business_description", ""),
        model_version=model_version,
        model_folder=params.get("model_folder", ""),
        schema_prefix=params.get("schema_prefix", ""),
        naming_convention=params.get("naming_convention", "snake_case"),
        primary_key_suffix=params.get("primary_key_suffix", "_id"),
        schema_suffix=params.get("schema_suffix", ""),
        tag_prefix=params.get("tag_prefix", "dbx_"),
        tag_suffix=params.get("tag_suffix", ""),
        table_id_type=params.get("table_id_type", "BIGINT"),
        boolean_format=params.get("boolean_format", "Boolean (True/False)"),
        date_format=params.get("date_format", "yyyy-MM-dd"),
        timestamp_format=params.get("timestamp_format", "yyyy-MM-dd HH:mm:ss"),
        cataloging_style=params.get("cataloging_style", "One Catalog"),
        catalog_prefix=params.get("catalog_prefix", ""),
        catalog_suffix=params.get("catalog_suffix", ""),
        org_divisions=params.get("org_divisions", "Operations"),
        business_domains=params.get("business_domains", ""),
        classification_levels=params.get("classification_levels", ""),
        housekeeping_columns=params.get("housekeeping_columns", "No"),
        history_tracking_columns=params.get("history_tracking_columns", "No"),
        generate_samples=bool(params.get("generate_samples", False)),
    )


def dispatch_generation_op(
    *,
    operation: str,
    data_model_scopes: str,
    ctx: Any,
    ws: Any,
    session: Any,
    business: Any,
    job_id: int,
    warehouse_id: str,
    model_version: str = "",
) -> OperationDispatchHandle:
    """Common dispatch path for the three generation primitives.

    On a fresh launch, persist the new ``databricks_run_id`` onto the row so
    the orchestrator's resume scan can find it.
    """
    sid = generate_session_id()
    widgets = widgets_from_params(
        operation=operation,
        data_model_scopes=data_model_scopes,
        params=ctx.params,
        business=business,
        session_id=sid,
        model_version=model_version,
    )
    widgets = finalize_widgets_or_raise(
        ws,
        widgets,
        catalog=ctx.params.get("deployment_catalog", ""),
        business_name=business.name,
        session_id=sid,
        raw_vibes=ctx.params.get("model_vibes", ""),
    )
    job_tags = build_job_tags_from_session(
        session,
        business_name=business.name,
        model_scope=data_model_scopes,
        version=model_version,
        operation=operation,
        session_id=sid,
    )
    dbx_run_id = launch_run(
        ws,
        job_id,
        widgets,
        job_tags=job_tags,
        warehouse_id=warehouse_id,
    )
    _persist_run_id(session, ctx.operation_id, dbx_run_id, sid)
    return OperationDispatchHandle(
        databricks_run_id=dbx_run_id,
        vibe_session_id=sid,
        extra={},
        # Write-once audit of the exact widget map handed to the Jobs
        # API. Covers all three generation primitives (generate_ecm,
        # shrink_to_mvm, enlarge_to_ecm) that route through this helper,
        # mirroring how install/uninstall/generate_samples populate it.
        # The orchestrator persists this verbatim onto
        # ``RunOperation.dispatched_widgets_json`` at dispatch time
        # (_runner.py) so the run-detail "What you submitted → Dispatched
        # widgets" block populates for model runs.
        dispatched_widgets=widgets,
    )


def _existing_run_op(session: Any, operation_id: str) -> Optional[RunOperation]:
    """Look up the ``RunOperation`` row for an op id; returns ``None``
    when the row is absent (DAG-factory tests may not seed one)."""
    if not operation_id:
        return None
    try:
        return session.get(RunOperation, operation_id)
    except Exception:
        return None


def _persist_run_id(
    session: Any, operation_id: str, dbx_run_id: int, vibe_session_id: str,
) -> None:
    """Write the dispatched ``databricks_run_id`` + ``vibe_session_id``
    onto the op's row so resume + idempotent-dispatch can short-circuit."""
    ro = _existing_run_op(session, operation_id)
    if ro is None:
        return
    ro.databricks_run_id = dbx_run_id
    ro.vibe_session_id = vibe_session_id
    if ro.status == "pending":
        ro.status = "running"
    session.add(ro)
    session.flush()


@dataclass
class _SessionRow:
    """Minimal projection of the agent's ``_business`` row used by
    ``observe_generation_op``."""

    completed_percent: float
    processing_status: str
    completion_date: Optional[str]
    results_json: Optional[dict]
    business: str
    version: str
    model_scope: str


def _execute_sql(ws: Any, warehouse_id: str, sql: str) -> Optional[Any]:
    """Run a SQL statement and return the response, or ``None`` if the
    table doesn't exist yet (agent hasn't produced output)."""
    try:
        result = ws.statement_execution.execute_statement(
            warehouse_id=warehouse_id,
            statement=sql,
            wait_timeout="30s",
        )
        status = getattr(result, "status", None)
        err = getattr(status, "error", None) if status else None
        msg = getattr(err, "message", "") if err else ""
        if msg and _TABLE_NOT_FOUND in msg:
            return None
        if msg:
            raise RuntimeError(f"SQL error: {msg}")
        return result
    except Exception as e:
        if _TABLE_NOT_FOUND in str(e):
            return None
        raise


def _read_session_row(
    ws: Any, warehouse_id: str, catalog: str, session_id_bigint: int,
) -> Optional[_SessionRow]:
    """Read the agent's session-status row for the current session.

    Returns ``None`` while the agent hasn't written its handshake row yet
    (table missing or no matching row). The exact shape mirrors what
    ``progress_tracker._poll_session_status_by_id`` returns; we don't
    import that helper because Phase 4 owns ``progress_tracker``.
    """
    sql = (
        f"SELECT completed_percent, processing_status, "
        f"CAST(completion_date AS STRING) as completion_date, "
        f"CAST(results_json AS STRING) as results_json, "
        f"business, version, model_scope "
        f"FROM `{catalog}`.`_metamodel`.`business` "
        f"WHERE session_id = {session_id_bigint} "
        f"LIMIT 1"
    )
    result = _execute_sql(ws, warehouse_id, sql)
    if result is None:
        return None
    data = getattr(result, "result", None)
    arr = getattr(data, "data_array", None) if data else None
    if not arr or not arr[0]:
        return None
    row = arr[0]
    rj: Optional[dict] = None
    if row[3]:
        try:
            rj = json.loads(row[3])
        except (json.JSONDecodeError, TypeError):
            rj = {"raw": row[3]}
    return _SessionRow(
        completed_percent=float(row[0]) if row[0] else 0.0,
        processing_status=row[1] or "",
        completion_date=row[2],
        results_json=rj,
        business=row[4] or "",
        version=row[5] or "",
        model_scope=row[6] or "",
    )


def _job_lifecycle(ws: Any, dbx_run_id: int) -> tuple[str, str]:
    """Return ``(life_cycle_state, result_state)``. Empty strings on read
    failure or partial state — the caller treats either as "still running".
    """
    if not dbx_run_id:
        return ("", "")
    try:
        job_run = ws.jobs.get_run(dbx_run_id)
    except Exception:
        return ("", "")
    state = getattr(job_run, "state", None)
    lcs_obj = getattr(state, "life_cycle_state", None) if state else None
    rs_obj = getattr(state, "result_state", None) if state else None
    lcs = getattr(lcs_obj, "value", "") if lcs_obj else ""
    rs = getattr(rs_obj, "value", "") if rs_obj else ""
    lcs = lcs if isinstance(lcs, str) else ""
    rs = rs if isinstance(rs, str) else ""
    return (lcs, rs)


def observe_generation_op(
    *,
    handle: OperationDispatchHandle,
    ctx: Any,
    ws: Any,
    session: Any,
    scope_short: str,
) -> OperationObservation:
    """Snapshot of an in-flight generation op.

    Algorithm (per §10 row 1):
      1. Poll the Jobs API. Terminal-not-success → terminal failure obs.
      2. Non-terminal lifecycle → return a non-terminal progress obs.
      3. TERMINATED + SUCCESS → verify the agent's ``model.json`` is in
         the Volume. Missing → terminal failure (succeeded=False, no
         version produced). Present → create the ModelVersion row, run
         the Lakebase sync. Sync failure leaves the version row in place
         (so rollback can delete it) and returns ``succeeded=True`` with
         a sync-failed marker in ``rollback_state`` per §10 row 1 col 3.

    ``scope_short`` is "ecm" or "mvm" — controls which Volume folder the
    agent wrote model.json to.
    """
    if handle.databricks_run_id is None:
        return _terminal_failure(
            "Operation dispatched without a Databricks run id; cannot observe.",
        )

    catalog = ctx.params.get("deployment_catalog", "")
    business_name = ctx.params.get("business_name", "")

    # 1. Jobs API check.
    lcs, rs = _job_lifecycle(ws, handle.databricks_run_id)
    if lcs in ("INTERNAL_ERROR", "SKIPPED"):
        return _terminal_failure(f"Databricks job ended with {lcs}/{rs}")
    if lcs == "TERMINATED" and rs and rs != "SUCCESS":
        return _terminal_failure(f"Databricks job ended with {lcs}/{rs}")

    # 2. Still in flight.
    if lcs != "TERMINATED" or rs != "SUCCESS":
        return OperationObservation(
            progress_percent=0 if lcs in ("", "PENDING") else 50,
            progress_message=f"Job state: {lcs or 'PENDING'}/{rs or '...'}",
            is_terminal=False,
            terminal_result=None,
        )

    # 3a. Job succeeded — verify model.json exists in the Volume.
    #
    # Volume FUSE writes are eventually consistent w.r.t. Files API
    # reads — the agent reports SUCCESS to Jobs API the instant its
    # notebook returns, but the freshly-written model.json may take a
    # few seconds to be visible through ws.files.download(). Retry
    # with bounded backoff before giving up. Mirrors the pattern in
    # ``vibe_iterate._fetch_model_json`` (5 attempts: 1+2+4+8 = 15s).
    model_json_candidates = _model_json_candidates(
        ctx=ctx, session=session, scope_short=scope_short,
    )
    model_json_payload: Optional[dict] = None
    last_exc: Optional[Exception] = None
    max_attempts = 5
    for attempt in range(max_attempts):
        last_exc = None
        # Nested (agent 4.9.8+) first, legacy flat fallback for a pre-upgrade base.
        for model_json_path in model_json_candidates:
            try:
                resp = ws.files.download(model_json_path)
                # Best-effort .read() to catch payload-level errors as
                # missing artifacts the same way progress_tracker does.
                # Also parse the bytes when present so `_terminal_success`
                # can read ``generated_from_version`` for lineage
                # resolution.
                contents = getattr(resp, "contents", None)
                if contents is not None and hasattr(contents, "read"):
                    raw = contents.read()
                    if raw and isinstance(raw, (str, bytes, bytearray)):
                        try:
                            model_json_payload = json.loads(raw)
                            if not isinstance(model_json_payload, dict):
                                model_json_payload = {"model": model_json_payload}
                        except (ValueError, json.JSONDecodeError, TypeError):
                            # Bytes were unparseable JSON — keep the
                            # existing behaviour (succeed if the file at
                            # least existed) but skip lineage resolution.
                            model_json_payload = None
                last_exc = None
                break
            except Exception as e:
                last_exc = e
                continue
        if last_exc is None:
            break
        if attempt < max_attempts - 1:
            time.sleep(2 ** attempt)  # 1, 2, 4, 8 seconds
    if last_exc is not None:
        tried = ", ".join(model_json_candidates) or "<no path>"
        if isinstance(last_exc, FileNotFoundError):
            return _terminal_failure(
                f"Agent model.json missing (tried {tried}) "
                f"after {max_attempts} attempts: {last_exc}"
            )
        return _terminal_failure(
            f"Agent model.json missing or unreadable (tried {tried}) "
            f"after {max_attempts} attempts: {last_exc}"
        )

    # 3b. Soft-failure check: the agent may have completed the Databricks
    #     job successfully but emitted a ``pipeline_error`` row in the
    #     ``_business`` Delta table (e.g. an in-job validation failure
    #     short-circuited model production). Best-effort — wrapped in a
    #     try/except because callers (adversarial tests, in-process
    #     orchestrator) may not populate the SQL warehouse stub.
    pipeline_err = _check_pipeline_error(
        ws, session, ctx, handle.vibe_session_id,
    )
    if pipeline_err:
        return _terminal_failure(pipeline_err)

    # 3c. Artifact present — create the ModelVersion + run sync.
    warehouse_id = get_warehouse_id(session)
    return _terminal_success(
        ctx=ctx,
        ws=ws,
        session=session,
        warehouse_id=warehouse_id,
        catalog=catalog,
        business_name=business_name,
        agent_business=business_name,
        agent_version="",
        agent_model_scope=scope_short,
        scope_short=scope_short,
        model_json_payload=model_json_payload,
        drain_fn=handle.extra.get("progress_drain"),
    )


def _check_pipeline_error(
    ws: Any, session: Any, ctx: Any, vibe_session_id: Optional[str],
) -> str:
    """Return the agent's pipeline_error message if one is recorded in
    the ``_business`` Delta row for this session, else ``""``.

    Defensive: any exception (warehouse not configured, MagicMock-only
    test stubs, malformed payload) returns ``""`` so the caller proceeds
    on the happy path. Phase 3 may upgrade this to a structured pre-sync
    health check; for now it preserves the legacy ``progress_tracker``
    semantics that the smoke tests depend on.
    """
    if not vibe_session_id:
        return ""
    warehouse_id = get_warehouse_id(session)
    catalog = ctx.params.get("deployment_catalog", "")
    if not warehouse_id or not catalog:
        return ""
    try:
        sid_bigint = session_id_to_bigint(vibe_session_id)
        status = _read_session_row(ws, warehouse_id, catalog, sid_bigint)
    except Exception:
        return ""
    if status is None:
        return ""
    if (
        status.completed_percent >= 100
        and isinstance(status.results_json, dict)
        and status.results_json.get("status") == "pipeline_error"
    ):
        err = status.results_json.get("error") or "pipeline_error"
        return str(err)
    return ""


def _model_json_candidates(*, ctx: Any, session: Any, scope_short: str) -> list[str]:
    """Compute the Volume paths the agent may have written ``model.json`` to.

    Agent layout (4.9.8+, nested):
      ``/Volumes/{deployment_catalog}/_metamodel/vol_root/business/
      {sanitized_business_name}/v{N}/{scope}/model.json``

    Returns the nested path first and the legacy flat ``{scope}_v{N}`` path
    second so a run against a pre-upgrade base still resolves. The
    ``business_name`` is passed raw to the builder, which applies
    ``agent_business_segment`` internally (the same ``sanitize_name`` rule the
    notebook uses to write ``model.json``).

    For ``generate_ecm``: N=1 (always — agent writes v1 in new-base mode).
    For ``shrink_to_mvm`` / ``enlarge_to_ecm``: N=parent_version_int
    (resolved from ``ctx.parent_version_id`` if not in params).
    """
    catalog = ctx.params.get("deployment_catalog", "")
    business_name = ctx.params.get("business_name", "")
    # Try params overrides first, then fall back to parent_version lookup,
    # then to 1 for new-base.
    n = (
        ctx.params.get("parent_ecm_version_int")
        or ctx.params.get("parent_mvm_version_int")
        or ctx.params.get("model_version_int")
    )
    if not n and ctx.parent_version_id:
        parent = session.get(ModelVersion, ctx.parent_version_id)
        if parent is not None:
            n = parent.version
    if not n:
        n = 1
    return model_json_volume_candidates(catalog, business_name, int(n), scope_short)


def _terminal_failure(error: str) -> OperationObservation:
    """Build a terminal-failure observation with no produced version."""
    return OperationObservation(
        progress_percent=100,
        progress_message=error,
        is_terminal=True,
        terminal_result=OperationResult(
            succeeded=False,
            output_version_id=None,
            output_artifacts=[],
            rollback_state={},
            error=error,
        ),
    )


def _resolve_lineage_parent_for_success(
    *,
    session: Any,
    ctx: Any,
    model_json_payload: Optional[dict],
) -> Optional[ModelVersion]:
    """Pick the parent ``ModelVersion`` for a freshly-produced agent run.

    Order of preference:
    1. Parse ``model.json``'s ``generated_from_version`` (e.g. ``"v1_ecm"``)
       and look up the matching ``(business, version, scope)`` row. The
       agent writes this tag durably; trust it across orchestrator
       restarts where ``ctx.parent_version_id`` may have been rebuilt
       without a parent.
    2. ``ctx.parent_version_id`` — set by DAG factories at dispatch and
       carried through ``OperationContext``.
    3. ``None`` — the op has no parent (e.g. fresh ECM).
    """
    business_id = getattr(ctx, "business_id", "") or ""
    if model_json_payload and isinstance(model_json_payload, dict):
        # Accept either flat shape or {model: {...}} wrapper — the agent
        # currently writes the wrapper but tests sometimes seed flat.
        for blob in (model_json_payload, model_json_payload.get("model") or {}):
            if not isinstance(blob, dict):
                continue
            tag = blob.get("generated_from_version")
            if not tag:
                continue
            parent = resolve_lineage_parent(session, business_id, str(tag))
            if parent is not None:
                return parent
    parent_id = getattr(ctx, "parent_version_id", None)
    if parent_id:
        return session.get(ModelVersion, parent_id)
    return None


def _terminal_success(
    *,
    ctx: Any,
    ws: Any,
    session: Any,
    warehouse_id: str,
    catalog: str,
    business_name: str,
    agent_business: str,
    agent_version: str,
    agent_model_scope: str,
    scope_short: str,
    model_json_payload: Optional[dict] = None,
    drain_fn: Any = None,
) -> OperationObservation:
    """Create the ModelVersion, run Lakebase sync, return terminal success.

    A sync failure does NOT abort the op — the agent's Volumes-side
    artifacts exist and are recoverable; the user can retry sync via the
    UI. We surface the failure in ``rollback_state`` so the rollback path
    can clean it up if the user later cancels.

    Per-scope version semantics (§spec):
    * Shrink-style ops (parent ECM + new MVM scope) write the same
      ``version`` number as the parent — ECM v=N → MVM v=N.
    * Enlarge-style ops (parent MVM + new ECM scope) likewise mirror the
      parent's version.
    * All other model-producing ops (e.g. fresh ECM) allocate
      ``next_version_for_scope(business, scope_short)``.
    """
    # Resolve lineage parent. Prefer the agent's
    # ``generated_from_version`` tag in model.json (durable, survives
    # orchestrator restarts); fall back to ``ctx.parent_version_id``
    # which DAG factories set at dispatch time.
    lineage_parent = _resolve_lineage_parent_for_success(
        session=session,
        ctx=ctx,
        model_json_payload=model_json_payload,
    )

    # Per-scope ordinal allocation. Shrink/enlarge keeps the parent's
    # version number; everything else allocates `max(scope) + 1`.
    parent_for_mirror: Optional[ModelVersion] = lineage_parent
    if parent_for_mirror is None and getattr(ctx, "parent_version_id", None):
        parent_for_mirror = session.get(ModelVersion, ctx.parent_version_id)
    if (
        parent_for_mirror is not None
        and parent_for_mirror.scope
        and parent_for_mirror.scope != scope_short
    ):
        # ECM↔MVM swap: same version int, opposite scope.
        new_version_num = int(parent_for_mirror.version)
    else:
        new_version_num = next_version_for_scope(
            session, ctx.business_id, scope_short
        )
    # Agent override: if the agent's Volume already had a collision at
    # ``new_version_num`` and it auto-resolved to a higher ordinal, the
    # tracker recorded that decision as a Version Resolution event on
    # this run. Prefer the agent's chosen ordinal so the MV row's
    # ``.version`` matches the Volume folder the agent actually wrote.
    # See ``backend.version_resolution_parser`` for the full rationale
    # (incident: 2026-05-04 the test workspace, ECM/MVM v1 collision auto-bumped to v3).
    agent_resolved = lookup_resolved_version(
        session, ctx.run_id, scope_short,
    )
    if agent_resolved is not None and agent_resolved != new_version_num:
        logger.info(
            "observe: applying agent Version Resolution override on "
            "run=%s scope=%s — App-allocated v%d, agent resolved to v%d",
            ctx.run_id, scope_short, new_version_num, agent_resolved,
        )
        new_version_num = agent_resolved

    deployment_status = "deployed" if catalog else "draft"

    # Capture sibling ids BEFORE flipping them so the rollback can
    # restore the exact set.
    superseded_ids: list[str] = []
    if deployment_status == "deployed":
        siblings = session.exec(
            select(ModelVersion).where(
                ModelVersion.business_id == ctx.business_id,
                ModelVersion.deployment_status == "deployed",
                ModelVersion.uc_catalog == (catalog or ""),
                ModelVersion.id != "",  # placeholder; real check after MV created
            )
        ).all()
        # Filter out any id that matches the not-yet-created MV (none yet,
        # but keep the structure parallel to progress_tracker).
        superseded_ids = [s.id for s in siblings]

    base_version_id = (
        lineage_parent.id
        if lineage_parent is not None
        else getattr(ctx, "parent_version_id", None)
    )
    mv = ModelVersion(
        business_id=ctx.business_id,
        version=new_version_num,
        status="completed",
        deployment_status=deployment_status,
        base_version_id=base_version_id,
        vibe_instructions=ctx.params.get("model_vibes", ""),
        scope=scope_short,
        uc_catalog=catalog,
        completion_date=datetime.now(timezone.utc),
    )
    session.add(mv)
    session.flush()

    # Promote-and-sync region wrapped in a SAVEPOINT. The mv was flushed
    # OUTSIDE it (above), so the row survives a rollback. Inside the savepoint:
    # flip every other ``completed`` MV in (business, scope_short) to
    # ``superseded`` (the explorer relies on at most one ``completed`` per scope
    # as the current view; cross-scope rows are untouched), un-supersede our
    # siblings, then sync. On any raise the savepoint reverts the supersede
    # flips AND the partial element writes, so the prior good version stays
    # active and un-superseded and the user keeps seeing the last good model.
    auto_superseded_ids: list[str] = []
    sync_succeeded = True
    sync_error = ""
    try:
        with session.begin_nested():
            auto_superseded_ids = supersede_same_scope_priors(
                session, ctx.business_id, scope_short, mv.id,
            )
            # Un-supersede our siblings: flip their deployment_status to uninstalled.
            for sib_id in superseded_ids:
                sib = session.get(ModelVersion, sib_id)
                if sib is not None:
                    sib.deployment_status = "uninstalled"
                    session.add(sib)

            sync = ModelSyncService(session, ws, warehouse_id)
            sync._drain_progress_fn = drain_fn
            sync_ok = sync.sync_model(
                mv.id,
                catalog,
                business_name or agent_business,
                str(new_version_num),
                agent_model_scope,
                run_id=ctx.run_id,
            )
            if not sync_ok:
                # sync_model returned False: no model.json in Volumes and no
                # Delta fallback. Raise so the savepoint rolls back and the
                # (surviving) mv row lands sync_empty rather than a silent
                # completed/ok version with 0 domains.
                raise _SyncEmptyError(
                    f"No model data found for "
                    f"{business_name or agent_business} v{new_version_num} "
                    f"({agent_model_scope}) in Volumes or Delta"
                )
    except _SyncEmptyError as e:
        sync_succeeded = False
        sync_error = repr(e)
        # No model structure was found (no Volume, no Delta) or the payload
        # parsed to 0 domains. A resync won't help until the agent's Volume
        # output is populated, so this is distinct from incomplete_metadata.
        auto_superseded_ids = []
        mv.sync_state = "sync_empty"
        mv.sync_error_text = str(e)[:500]
        session.add(mv)
        session.commit()
        logger.error(
            "observe_generation_op: no model data found for version %s "
            "(marked sync_state=sync_empty); agent Volume artifacts absent "
            "or structurally empty",
            mv.id,
        )
    except Exception as e:
        sync_succeeded = False
        sync_error = repr(e)
        # Savepoint rolled back: the supersede flips and partial writes are
        # undone, so nothing was auto-superseded. Surface the failure on the
        # (surviving) mv row so the version detail page banner fires. The op
        # still reports succeeded=True (the agent's Volume artifacts landed);
        # sync_state is the user signal.
        auto_superseded_ids = []
        mv.sync_state = "incomplete_metadata"
        mv.sync_error_text = str(e)[:500]
        session.add(mv)
        session.commit()
        logger.exception(
            "observe_generation_op: model sync failed for version %s "
            "(marked sync_state=incomplete_metadata)",
            mv.id,
        )

    # Index the agent's Volume artifacts onto this ModelVersion so the
    # Artifacts tab is populated. Best-effort: failures are logged inside
    # the helper and never escape, so they cannot fail the op.
    #
    # Lazy import to avoid the import cycle:
    # progress_tracker -> services.orchestrator -> services.operations
    # -> operations modules -> _generation_common.
    run_row: Optional[Run] = None
    run_id = getattr(ctx, "run_id", "") or ""
    if run_id:
        try:
            run_row = session.get(Run, run_id)
        except Exception:
            run_row = None
    if run_row is not None:
        try:
            from ...progress_tracker import index_artifacts_for_version
            index_artifacts_for_version(
                ws,
                run_row,
                mv,
                session,
                catalog,
                business_name or agent_business,
                int(new_version_num),
                scope_short,
            )
        except Exception:
            logger.exception(
                "observe_generation_op: artifact indexing failed for "
                "version %s (non-fatal)",
                mv.id,
            )

    rollback_state = {
        "version_id": mv.id,
        "scope": scope_short,
        "catalog": catalog,
        "schema_prefix": ctx.params.get("schema_prefix", ""),
        "model_version_int": new_version_num,
        "business_name": business_name,
        "superseded_ids": superseded_ids,
        "auto_superseded_ids": auto_superseded_ids,
        "deployment_status": deployment_status,
        "sync_succeeded": sync_succeeded,
        "sync_error": sync_error,
    }

    # Per spec §10 row 1 col 3: when the agent's model.json artifact
    # exists, the op is "succeeded" (the durable artifact landed in the
    # Volume — Lakebase sync is a separate concern the user can retry).
    # Rollback uses ``sync_succeeded`` in ``rollback_state`` to clean up
    # the version row that's stuck in a sync-failed state.
    if not sync_succeeded:
        return OperationObservation(
            progress_percent=100,
            progress_message=f"Completed v{new_version_num} (sync deferred: {sync_error})",
            is_terminal=True,
            terminal_result=OperationResult(
                succeeded=True,
                output_version_id=mv.id,
                output_artifacts=[],
                rollback_state=rollback_state,
                error=None,
            ),
        )

    return OperationObservation(
        progress_percent=100,
        progress_message=f"Completed v{new_version_num}",
        is_terminal=True,
        terminal_result=OperationResult(
            succeeded=True,
            output_version_id=mv.id,
            output_artifacts=[],  # progress_tracker indexes; orchestrator can plug in later
            rollback_state=rollback_state,
            error=None,
        ),
    )


def rollback_generation_op(
    *,
    ctx: Any,
    rollback_state: dict,
    ws: Any,
    session: Any,
) -> None:
    """Reverse a successful (or partial) generation op.

    Steps, idempotent each:
      1. Best-effort fire an agent ``uninstall model version`` job for
         the produced (catalog, version) so the inline-installed schemas
         are removed. Triggered whenever the generation observation
         recorded ``deployment_status == "deployed"`` (the agent runs
         Stages 12-14 inline in every cataloging_style — integration
         guide §12); otherwise no-op.
      2. Clear Lakebase model data (Domain/Product/Attribute/FK rows).
      3. Delete the ModelVersion row itself.
      4. Restore previously-superseded siblings to ``deployment_status="deployed"``.
    """
    version_id = rollback_state.get("version_id", "")
    catalog = rollback_state.get("catalog", "")
    model_version_int = (
        rollback_state.get("model_version_int")
        or rollback_state.get("model_version")
    )
    business_name = rollback_state.get("business_name", "")
    superseded_ids = rollback_state.get("superseded_ids", []) or []

    # 1. Uninstall_schema — fire-and-forget. The agent inline-installs in
    #    every cataloging_style (integration guide §12 "Operational Modes"),
    #    so any op whose generation observation recorded
    #    ``deployment_status == "deployed"`` (or set ``installed_inline``
    #    explicitly) needs its schemas torn down on rollback.
    installed_inline = bool(
        rollback_state.get("installed_inline")
        or rollback_state.get("deployment_status") == "deployed"
    )
    if installed_inline and catalog and model_version_int:
        job_id = get_agent_job_id(session)
        if job_id:
            sid = generate_session_id()
            sid_bigint = session_id_to_bigint(sid)
            widgets = {
                "operation": "uninstall model version",
                "business_name": business_name,
                "deployment_catalog": catalog,
                "model_version": str(model_version_int),
                "vibe_session_id": str(sid_bigint),
            }
            try:
                job_tags = build_job_tags_from_session(
                    session,
                    business_name=business_name,
                    version=str(model_version_int),
                    operation="uninstall model version",
                    session_id=sid,
                )
                launch_run(ws, job_id, widgets, job_tags=job_tags)
            except Exception as e:
                # Surface to caller so the rollback chain records the
                # failure.
                raise RuntimeError(
                    f"Failed to launch uninstall job for catalog {catalog!r}: {e}"
                ) from e

    # 2. Clear Lakebase model data — only if the version still exists.
    if version_id:
        mv = session.get(ModelVersion, version_id)
        if mv is not None:
            try:
                sync = ModelSyncService(session, ws, get_warehouse_id(session))
                sync.clear_version_data(version_id)
            except Exception:
                logger.exception(
                    "rollback_generation_op: clear_version_data failed for %s",
                    version_id,
                )
                raise

    # 3. Delete the ModelVersion row — idempotent (no-op if already gone).
    if version_id:
        mv = session.get(ModelVersion, version_id)
        if mv is not None:
            session.delete(mv)

    # 4. Restore superseded siblings to deployed.
    for sib_id in superseded_ids:
        sib = session.get(ModelVersion, sib_id)
        if sib is not None:
            sib.deployment_status = "deployed"
            session.add(sib)

    # 5. Restore status='superseded' siblings flipped by
    #    supersede_same_scope_priors back to 'completed'.
    auto_superseded_ids = rollback_state.get("auto_superseded_ids", []) or []
    restore_superseded_priors(session, auto_superseded_ids)


# ---------------------------------------------------------------------------
# Shared params-model field set
# ---------------------------------------------------------------------------
#
# Importing the Pydantic model here would cause an import cycle with the
# primitive modules. Instead each primitive defines its own params_model
# but shares the field defaults via the constants below — keeps the
# defaults in one place without coupling Pydantic class hierarchies.

DEFAULT_NAMING_CONVENTION = "snake_case"
DEFAULT_PRIMARY_KEY_SUFFIX = "_id"
DEFAULT_TAG_PREFIX = "dbx_"
DEFAULT_TABLE_ID_TYPE = "BIGINT"
DEFAULT_BOOLEAN_FORMAT = "Boolean (True/False)"
DEFAULT_DATE_FORMAT = "yyyy-MM-dd"
DEFAULT_TIMESTAMP_FORMAT = "yyyy-MM-dd HH:mm:ss"
DEFAULT_HOUSEKEEPING_COLUMNS = "No"
DEFAULT_HISTORY_TRACKING_COLUMNS = "No"
DEFAULT_ORG_DIVISIONS = "Operations"
