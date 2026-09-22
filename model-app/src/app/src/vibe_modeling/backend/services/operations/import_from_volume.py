"""``import_from_volume`` primitive — synthetic, in-process.

No agent job. The op reads a ``model.json`` already present in a UC Volume
and materialises it into Lakebase as a fresh :class:`ModelVersion`. This is
the recovery path for runs that succeeded on the agent side but lost the
sync hop — pre-orchestrator the same logic lives on
``POST /businesses/{id}/versions/import-from-volume``; that endpoint stays
in place, this primitive lets a DAG drive the same work.

Synthetic conventions:

* :meth:`dispatch` performs the entire side-effect synchronously. There is
  no ``databricks_run_id`` to poll.
* :meth:`observe` ALWAYS returns ``is_terminal=True`` with a snapshotted
  result the dispatch step stowed in ``handle.extra``. Idempotent against
  re-call after a process restart because the dispatch step also writes
  the result onto the ``RunOperation`` row's ``output_version_id`` (the
  orchestrator owns persistence of the row itself).

See ``docs/orchestrator-design.md`` §2 (table) and §10 (failure modes).
"""

from __future__ import annotations

import json
import logging
from datetime import datetime, timezone
from typing import Any, Optional

from pydantic import BaseModel, Field, field_validator
from sqlmodel import select

from ...agent_compat import extract_version_provenance
from ...db_models import Business, ModelVersion, RunOperation
from ..._query_helpers import (
    next_version_for_scope,
    resolve_lineage_parent,
)
from ...core._warehouse import get_warehouse_id
from ...model_sync import ModelSyncService
from ._registry import register
from ._protocol import (
    Operation,
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
    OperationResult,
)

logger = logging.getLogger(__name__)


class ImportFromVolumeParams(BaseModel):
    """Parameters for the ``import_from_volume`` primitive.

    The ``volume_path`` MUST be an absolute UC Volume path with no ``..``
    segments. The path-shape gate runs at the params layer so impossible
    inputs (path traversal, non-Volumes roots) reject before any
    workspace I/O — see spec §2.4 ("Field-level rules ... live in the
    params_model directly").

    ``business_name`` and ``deployment_catalog`` are optional in the
    params_model and resolved at dispatch from the
    :class:`OperationContext` when blank (spec §2: OperationContext is
    the source of truth for org config).
    """

    business_name: str = ""
    deployment_catalog: str = ""
    volume_path: str = Field(min_length=1)

    @field_validator("volume_path")
    @classmethod
    def _validate_volume_path(cls, v: str) -> str:
        if not v:
            raise ValueError("volume_path is required")
        if not v.startswith("/Volumes/"):
            raise ValueError(
                "volume_path must be an absolute UC Volume path "
                "(starts with '/Volumes/')"
            )
        # Reject path traversal at any segment depth.
        segments = [s for s in v.split("/") if s]
        if any(s == ".." for s in segments):
            raise ValueError(
                "volume_path must not contain '..' segments "
                "(path traversal rejected)"
            )
        return v


class ImportFromVolume(Operation):
    """Synthetic primitive — reads model.json from a Volume and syncs it."""

    name = "import_from_volume"
    params_model = ImportFromVolumeParams
    is_idempotent = False
    produces_version = True

    # ------------------------------------------------------------------
    # dispatch — does ALL the work synchronously
    # ------------------------------------------------------------------

    def dispatch(
        self,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationDispatchHandle:
        """Read the model.json, create the ModelVersion, sync into Lakebase.

        Idempotent against re-call: if the orchestrator restarts after the
        ModelVersion was written, the next dispatch reads the prior result
        off the ``RunOperation`` row and re-emits the same handle without
        creating a duplicate row.

        Soft-failure semantics: read/parse/schema errors are returned as
        ``handle.extra["error"]`` so :meth:`observe` can surface a terminal
        failure with a useful message (spec §10 — "io_from_volume" failure
        modes are observable, not raised). True bugs (e.g. params validation)
        still raise.
        """
        run_op = session.get(RunOperation, ctx.operation_id)
        if (
            run_op is not None
            and run_op.output_version_id
            and session.get(ModelVersion, run_op.output_version_id) is not None
        ):
            return OperationDispatchHandle(
                databricks_run_id=None,
                vibe_session_id=None,
                extra={
                    "completed": True,
                    "version_id": run_op.output_version_id,
                },
            )

        params = self.params_model(**ctx.params)

        # Resolve catalog/business name from context when omitted.
        deployment_catalog = params.deployment_catalog or (
            (ctx.inherited_params or {}).get("deployment_catalog") or ""
        )
        business_name = params.business_name
        if not business_name:
            biz = session.get(Business, ctx.business_id)
            business_name = biz.name if biz else ""

        # Load the model.json from the Volume — soft-fail to observe().
        try:
            resp = ws.files.download(params.volume_path)
            raw = resp.contents.read()
        except Exception as e:
            return _emit_dispatch_error(
                session,
                ctx,
                error=(
                    f"could not read {params.volume_path}: {e} "
                    f"(file not found or inaccessible)"
                ),
            )

        try:
            doc = json.loads(raw)
        except (ValueError, json.JSONDecodeError) as e:
            return _emit_dispatch_error(
                session,
                ctx,
                error=f"invalid JSON in {params.volume_path}: {e}",
            )

        # Accept either the flat shape (`domains` at top level) or the
        # `{model: {...}}` wrapper the agent currently writes.
        if isinstance(doc, dict) and "model" in doc:
            model_payload = doc.get("model")
        else:
            model_payload = doc

        # Schema sanity: type must be "business" and domains must be present.
        if not isinstance(model_payload, dict):
            return _emit_dispatch_error(
                session,
                ctx,
                error="model.json: missing required `model` object",
            )
        if "domains" not in model_payload:
            return _emit_dispatch_error(
                session,
                ctx,
                error=(
                    "model.json: missing required `domains` field "
                    "(schema check failed)"
                ),
            )
        # When a `type` field is present it MUST be "business" — anything
        # else is a different kind of artifact that this primitive cannot
        # safely import.
        mtype = model_payload.get("type")
        if mtype is not None and mtype != "business":
            return _emit_dispatch_error(
                session,
                ctx,
                error=(
                    f"model.json: required field `type` must be 'business', "
                    f"got {mtype!r}"
                ),
            )

        # Derive scope from the volume path's `{scope}_v{N}` segment.
        scope = _scope_from_volume_path(params.volume_path)

        # Per-scope ordinal allocation: an imported MVM lands next to
        # MVM siblings (not after the global max) so the natural key
        # `(business, version, scope)` stays unique.
        new_version_num = next_version_for_scope(
            session, ctx.business_id, scope
        )

        # Lineage from the agent's `generated_from_version` tag in the
        # imported model.json (e.g. "v1_ecm" → look up the matching MV
        # row and link as base_version_id). The volume-import path is
        # the recovery surface for runs that succeeded on the agent
        # side but lost the sync hop; the same lineage tag the
        # orchestrator-driven runs rely on is available here.
        lineage_parent_id: Optional[str] = None
        for blob in (model_payload, model_payload.get("model") or {}):
            if not isinstance(blob, dict):
                continue
            tag = blob.get("generated_from_version")
            if not tag:
                continue
            parent = resolve_lineage_parent(session, ctx.business_id, str(tag))
            if parent is not None:
                lineage_parent_id = parent.id
                break

        # Version provenance from the FULL model.json envelope ``doc`` — the
        # top-level agent_version / release_version keys live there, not on the
        # unwrapped ``model_payload`` (``doc["model"]``).
        agent_version, release_version = extract_version_provenance(doc)

        deployment_status = "deployed" if deployment_catalog else "draft"
        mv = ModelVersion(
            business_id=ctx.business_id,
            version=new_version_num,
            status="completed",
            deployment_status=deployment_status,
            base_version_id=lineage_parent_id,
            vibe_instructions="",
            scope=scope,
            uc_catalog=deployment_catalog,
            completion_date=datetime.now(timezone.utc),
            agent_version=agent_version,
            release_version=release_version,
        )
        session.add(mv)
        session.flush()

        # Sync structure into Lakebase. A sync failure here is reportable
        # via observe() so the orchestrator can roll back the version.
        sync_error: Optional[str] = None
        try:
            sync = ModelSyncService(session, ws, get_warehouse_id(session))
            sync.sync_from_model_json(mv.id, model_payload)
        except Exception as e:
            logger.exception(
                "import_from_volume: sync_from_model_json failed for mv=%s",
                mv.id,
            )
            sync_error = str(e) or "lakebase sync failed"

        # Persist on the RunOperation row so a re-call returns the same
        # handle without duplicating the version.
        _upsert_run_op_dispatch(session, ctx, output_version_id=mv.id)

        return OperationDispatchHandle(
            databricks_run_id=None,
            vibe_session_id=None,
            extra={
                "completed": True,
                "version_id": mv.id,
                "scope": scope,
                "version_int": new_version_num,
                **({"sync_error": sync_error} if sync_error else {}),
            },
        )

    # ------------------------------------------------------------------
    # observe — terminal immediately
    # ------------------------------------------------------------------

    def observe(
        self,
        handle: OperationDispatchHandle,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationObservation:
        """Always returns terminal — dispatch did the whole thing.

        Surfaces ``handle.extra["error"]`` (set by dispatch on file-read /
        parse / schema failures) as a terminal-failed observation. Sync
        failures are reported as terminal-success-with-sync-error so the
        orchestrator can drive a version rollback while still recording
        that the artifact existed.

        Falls back to reading ``output_version_id`` off the
        :class:`RunOperation` row when ``handle.extra["version_id"]`` is
        missing — ``_advance_running`` reconstructs ``handle.extra`` from
        ``rollback_state_json`` before calling ``observe()``, so this
        fallback covers the case where dispatch wrote ``output_version_id``
        as a dedicated column rather than in ``extra``.
        """
        extra = handle.extra or {}
        err = extra.get("error")
        if err:
            return OperationObservation(
                progress_percent=0,
                progress_message="Failed",
                is_terminal=True,
                terminal_result=OperationResult(
                    succeeded=False,
                    output_version_id=None,
                    output_artifacts=[],
                    rollback_state={},
                    error=str(err),
                ),
            )
        version_id = extra.get("version_id")
        if not version_id:
            # Row-side fallback for the version id — dispatch persisted
            # ``output_version_id`` on the RunOperation row before the
            # orchestrator rebuilt this handle, so a missing
            # ``handle.extra["version_id"]`` is not authoritative.
            try:
                run_op = session.get(RunOperation, ctx.operation_id)
            except Exception:  # noqa: BLE001 — best-effort fallback
                run_op = None
            if run_op is not None and run_op.output_version_id:
                version_id = run_op.output_version_id
        if not version_id:
            return OperationObservation(
                progress_percent=0,
                progress_message="No version produced",
                is_terminal=True,
                terminal_result=OperationResult(
                    succeeded=False,
                    output_version_id=None,
                    output_artifacts=[],
                    rollback_state={},
                    error="import_from_volume: dispatch produced no version_id",
                ),
            )
        return OperationObservation(
            progress_percent=100,
            progress_message="Imported",
            is_terminal=True,
            terminal_result=OperationResult(
                succeeded=True,
                output_version_id=version_id,
                output_artifacts=[],
                rollback_state={
                    "version_id": version_id,
                    "new_version_id": version_id,
                },
                error=None,
            ),
        )

    # ------------------------------------------------------------------
    # rollback — delete the imported version + clear Lakebase model data
    # ------------------------------------------------------------------

    def rollback(
        self,
        ctx: OperationContext,
        rollback_state: dict,
        ws: Any,
        session: Any,
    ) -> None:
        """Delete the imported ModelVersion + clear its Lakebase model data.

        Accepts either ``version_id`` (this primitive's terminal_result key)
        or ``new_version_id`` (the cross-primitive convention used by the
        orchestrator's cancel-with-rollback path).
        """
        version_id = rollback_state.get("version_id") or rollback_state.get(
            "new_version_id"
        )
        if not version_id:
            return
        mv = session.get(ModelVersion, version_id)
        if mv is None:
            return  # already gone — idempotent

        try:
            sync = ModelSyncService(session, ws, get_warehouse_id(session))
            sync.clear_version_data(version_id)
        except Exception:
            logger.exception(
                "import_from_volume.rollback: clear_version_data failed for %s",
                version_id,
            )

        session.delete(mv)
        session.flush()


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------


def _scope_from_volume_path(volume_path: str) -> str:
    """Pull the scope (``ecm`` / ``mvm``) out of a version-dir Volume path.

    Handles every layout the app has written:

    - Nested (agent 4.9.8+): ``.../v{N}/{scope}/...`` — the scope is a
      standalone segment directly after a ``v{N}`` segment.
    - Flat (pre-4.9.8): ``{scope}_v{N}`` (e.g. ``ecm_v1``).
    - Legacy flat (pre-v0.5.9): ``v{N}_{scope}``.

    Nested is checked first so a nested path never mis-parses; the flat forms
    remain as fallbacks so an old folder that happens to be re-imported still
    resolves. Falls back to ``ecm`` if the path doesn't match — the admin
    endpoint has the same default. The orchestrator-driven path comes through
    a DAG factory that should set scope explicitly upstream; this helper exists
    so a hand-rolled DAG omitting the scope still works.
    """
    parts = [p for p in volume_path.split("/") if p]
    # Nested layout: a standalone "ecm"/"mvm" segment following a "v{N}" segment.
    for i, p in enumerate(parts):
        if p in ("ecm", "mvm") and i > 0:
            prev = parts[i - 1]
            if prev.startswith("v") and prev[1:].isdigit():
                return p
    # Flat layouts.
    for p in parts:
        if "_" not in p:
            continue
        head, tail = p.split("_", 1)
        # "{scope}_v{int}".
        if head in ("ecm", "mvm") and tail.startswith("v") and tail[1:].isdigit():
            return head
        # Legacy "v{int}_{scope}".
        if head.startswith("v") and head[1:].isdigit() and tail in ("ecm", "mvm"):
            return tail
    return "ecm"


def _emit_dispatch_error(
    session: Any, ctx: OperationContext, *, error: str
) -> OperationDispatchHandle:
    """Persist a soft dispatch error onto the RunOperation row + return
    a terminal handle.

    The in-memory handle carries the error directly, so ``observe()``
    callers that pass it without a DB round-trip (e.g. unit tests) see
    the error immediately. The orchestrator's ``_dispatch_pending`` also
    writes ``handle.extra`` onto ``rollback_state_json`` after
    ``dispatch()`` returns, so the error survives a process restart.
    """
    extra = {"completed": True, "error": error}
    _upsert_run_op_dispatch(session, ctx, output_version_id=None)
    return OperationDispatchHandle(
        databricks_run_id=None,
        vibe_session_id=None,
        extra=extra,
    )


def _upsert_run_op_dispatch(
    session: Any,
    ctx: OperationContext,
    *,
    output_version_id: Optional[str],
) -> None:
    """Persist the dispatch outcome on the RunOperation row.

    Tests call dispatch directly without the orchestrator; insert a stub
    row keyed on ``ctx.operation_id`` so the resume guard short-circuits a
    second dispatch with the same operation_id.

    Does NOT write ``rollback_state_json`` - the orchestrator's
    ``_dispatch_pending`` persists ``handle.extra`` onto that column
    generically for every primitive right after ``dispatch()`` returns.
    """
    try:
        run_op = session.get(RunOperation, ctx.operation_id)
    except Exception:
        run_op = None
    if run_op is None:
        run_op = RunOperation(
            id=ctx.operation_id,
            run_id=ctx.run_id,
            step_index=0,
            operation_name="import_from_volume",
            params_json=json.dumps(ctx.params or {}),
            status="succeeded",
        )
        session.add(run_op)
    run_op.output_version_id = output_version_id
    session.flush()


# Singleton registration on import.
register(ImportFromVolume())


__all__ = ["ImportFromVolume", "ImportFromVolumeParams"]
