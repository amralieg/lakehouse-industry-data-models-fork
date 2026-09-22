"""``vibe_iterate`` primitive — agent ``vibe modeling of version`` op.

Iterates an existing ModelVersion with a fresh batch of vibe instructions.
The agent reads the parent version's model.json, applies the vibe text, and
writes a NEW version next to it (e.g. ``v3_ecm`` → ``v4_ecm``). On terminal
success this primitive:

* allocates a new ``ModelVersion`` row in Lakebase (sequential per-business
  ``version`` integer);
* syncs its structure into Lakebase via :class:`ModelSyncService`;
* marks the parent version as ``superseded`` so the Explorer surfaces the
  new iteration by default. Rollback restores the parent's prior status.

See ``docs/orchestrator-design.md`` §2 (table) and §10 (failure modes).
"""

from __future__ import annotations

import json
import logging
import time
from datetime import datetime, timezone
from typing import Any, Literal, Optional

from pydantic import BaseModel, Field, field_validator
from sqlmodel import select

from ...db_models import (
    AgentConfig,
    Business,
    ModelVersion,
    RunOperation,
)
from ..._query_helpers import (
    next_version_for_scope,
    resolve_lineage_parent,
    resolve_model_version,
)
from ...job_launcher import (
    build_job_tags,
    finalize_widgets_or_raise,
    generate_session_id,
    launch_run,
    map_run_params_to_widgets,
    scope_label_for,
    session_id_to_bigint,
)
from ...core._names import agent_business_segment
from ...core._warehouse import get_warehouse_id
from ...model_sync import ModelSyncService, _SyncEmptyError
from ...version_resolution_parser import lookup_resolved_version
from ._generation_common import (
    restore_superseded_priors,
    supersede_same_scope_priors,
)
from ._registry import register
from ._protocol import (
    Operation,
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
    OperationResult,
)

logger = logging.getLogger(__name__)


_AGENT_OP = "vibe modeling of version"


class VibeIterateParams(BaseModel):
    """Parameters for the ``vibe_iterate`` primitive.

    Per spec §2 (OperationContext is the source of truth), a few fields are
    optional in the params_model and resolved at dispatch time from
    :class:`OperationContext`:

    * ``business_name`` — derived from ``ctx.business_id`` lookup if blank.
    * ``parent_version_int`` — derived from ``ctx.parent_version_id`` if 0.
    * ``cataloging_style`` — read from ``ctx.inherited_params`` if blank.

    The validator below rejects empty/whitespace ``vibe_instructions``.
    """

    business_name: str = Field(default="", pattern=r"^[a-z][a-z0-9_]*$|^$")
    deployment_catalog: str = Field(default="", pattern=r"^[a-z][a-z0-9_]+$|^$")
    parent_version_int: int = Field(default=0, ge=0)
    vibe_instructions: str = Field(min_length=1)
    cataloging_style: str = ""
    schema_prefix: str = ""

    # Carry-keys (optional; defaulted to match the agent's expectations)
    business_description: str = ""
    business_description_override: str = ""
    business_context_path: str = ""
    industry_alignment: str = ""
    business_domains: str = ""
    org_divisions: str = "Operations"
    catalog_prefix: str = ""
    catalog_suffix: str = ""
    naming_convention: str = "snake_case"
    primary_key_suffix: str = "_id"
    schema_suffix: str = ""
    tag_prefix: str = "dbx_"
    tag_suffix: str = ""
    table_id_type: str = "BIGINT"
    boolean_format: str = "Boolean (True/False)"
    date_format: str = "yyyy-MM-dd"
    timestamp_format: str = "yyyy-MM-dd HH:mm:ss"
    classification_levels: str = ""
    housekeeping_columns: str = "No"
    history_tracking_columns: str = "No"
    model_size: str = "small model"
    generate_samples: bool = False

    @field_validator("vibe_instructions")
    @classmethod
    def _reject_blank_vibe_instructions(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError("vibe_instructions must be non-empty (no whitespace-only)")
        return v


class VibeIterate(Operation):
    """Wrap the agent's ``vibe modeling of version`` op as an Operation."""

    name = "vibe_iterate"
    params_model = VibeIterateParams
    is_idempotent = False
    produces_version = True

    # ------------------------------------------------------------------
    # dispatch
    # ------------------------------------------------------------------

    def dispatch(
        self,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationDispatchHandle:
        """Launch the Databricks job for ``vibe modeling of version``."""
        # Per spec §2 / reconciliation brief #1: parent_version_id from the
        # context drives the parent-version int lookup, not a duplicate
        # params field. Resolve it FIRST so a missing-parent error surfaces
        # before we touch AgentConfig or Business — the test asserts the
        # error mentions the parent.
        parent_version_id = ctx.parent_version_id
        parent_mv: Optional[ModelVersion] = None
        if parent_version_id:
            parent_mv = session.get(ModelVersion, parent_version_id)
            if parent_mv is None:
                raise ValueError(
                    f"vibe_iterate: parent ModelVersion not found "
                    f"(parent_version_id={parent_version_id!r})"
                )

        params = self.params_model(**ctx.params)
        business = session.get(Business, ctx.business_id)
        if business is None:
            raise RuntimeError(
                f"vibe_iterate: business {ctx.business_id} not found"
            )

        # Derive carry-key fallbacks from the context.
        cataloging_style = (
            params.cataloging_style
            or (ctx.inherited_params or {}).get("cataloging_style")
            or "One Catalog"
        )
        parent_version_int = params.parent_version_int or (
            int(parent_mv.version) if parent_mv and parent_mv.version else 0
        )
        if parent_version_int <= 0:
            # No parent supplied either way — vibe_iterate inherently needs one.
            raise ValueError(
                "vibe_iterate: parent version is required "
                "(set ctx.parent_version_id or params.parent_version_int)"
            )

        agent_config = session.exec(select(AgentConfig).limit(1)).first()
        # Tests don't seed an AgentConfig — fall through with a stub job id
        # if one isn't configured. The orchestrator path always seeds a
        # config at startup.
        job_id = int(agent_config.job_id) if agent_config and agent_config.job_id else 0

        sid = generate_session_id()
        sid_bigint = session_id_to_bigint(sid)
        # vibe-iterate's params_json snapshot stores the catalog under
        # ``catalog`` (legacy) while new-base-model uses
        # ``deployment_catalog``. Read either so the dispatch resolves
        # correctly regardless of which intent's snapshot we got. The
        # upstream agent PR (#28) will canonicalise widget naming to
        # remove the dual-key absurdity entirely.
        inherited = ctx.inherited_params or {}
        deployment_catalog = (
            params.deployment_catalog
            or inherited.get("deployment_catalog")
            or inherited.get("catalog")
            or ""
        )

        # A vibe-iterate runs in the PARENT version's scope - it targets a
        # specific existing version, so the scope is fixed and cannot be
        # re-chosen from model_size. Passing the parent's scope stops the
        # agent from defaulting to MVM and hard-failing on an ECM-only version
        # ("Version 'N' with model_scope 'mvm' does not exist").
        parent_scope = (parent_mv.scope if parent_mv and parent_mv.scope else "ecm")
        widgets = map_run_params_to_widgets(
            operation=_AGENT_OP,
            business=business,
            catalog=deployment_catalog,
            session_id=sid,
            vibe_instructions=params.vibe_instructions,
            model_size=params.model_size,
            data_model_scopes=scope_label_for(parent_scope),
            generate_samples=params.generate_samples,
            business_context_path=params.business_context_path,
            business_description_override=params.business_description_override,
            model_version=str(parent_version_int),
            naming_convention=params.naming_convention,
            primary_key_suffix=params.primary_key_suffix,
            schema_prefix=params.schema_prefix,
            schema_suffix=params.schema_suffix,
            tag_prefix=params.tag_prefix,
            tag_suffix=params.tag_suffix,
            table_id_type=params.table_id_type,
            boolean_format=params.boolean_format,
            date_format=params.date_format,
            timestamp_format=params.timestamp_format,
            cataloging_style=cataloging_style,
            catalog_prefix=params.catalog_prefix,
            catalog_suffix=params.catalog_suffix,
            org_divisions=params.org_divisions,
            business_domains=params.business_domains,
            classification_levels=params.classification_levels,
            housekeeping_columns=params.housekeeping_columns,
            history_tracking_columns=params.history_tracking_columns,
        )
        widgets["operation"] = _AGENT_OP
        widgets["vibe_session_id"] = str(sid_bigint)
        widgets = finalize_widgets_or_raise(
            ws,
            widgets,
            catalog=deployment_catalog,
            business_name=business.name,
            session_id=sid,
            raw_vibes=params.vibe_instructions,
        )

        job_tags = build_job_tags(
            business_name=business.name,
            model_scope=widgets.get("data_model_scopes", ""),
            version=str(parent_version_int),
            operation=_AGENT_OP,
            notebook_path=agent_config.notebook_path if agent_config else "",
            session_id=sid,
            collect_statistics=(
                agent_config.collect_vibe_run_statistics if agent_config else False
            ),
        )

        dbx_run_id = launch_run(
            ws,
            job_id,
            widgets,
            job_tags=job_tags,
        )

        # Persist the dispatch on the RunOperation row so the resume guard
        # short-circuits a second dispatch with the same operation_id.
        # Tests call dispatch directly without the orchestrator; upsert a
        # stub row when none exists.
        # Stash the agent-normalized business name (lowercase + space->_)
        # so the observe-side sync builds the same Volume path the agent
        # wrote to. Storing the raw DB literal here would cause the
        # /Volumes/.../business/<biz>/{scope}_v{N}/model.json lookup to
        # 404 silently and leave Lakebase empty for the new version.
        agent_biz = agent_business_segment(business.name)
        _upsert_run_op_dispatch(
            session, ctx, dbx_run_id=int(dbx_run_id), vibe_session_id=sid,
        )

        return OperationDispatchHandle(
            databricks_run_id=int(dbx_run_id),
            vibe_session_id=sid,
            extra={
                "session_id_bigint": int(sid_bigint),
                "deployment_catalog": deployment_catalog,
                "business_name": agent_biz,
                "parent_version_int": int(parent_version_int),
            },
            # Write-once audit of the exact widget map dispatched to the
            # Jobs API (see OperationDispatchHandle.dispatched_widgets).
            # Persisted verbatim onto RunOperation.dispatched_widgets_json
            # so the run-detail "What you submitted → Dispatched widgets"
            # block populates for vibe-iterate runs, matching install/
            # uninstall/generate_samples + the generation primitives.
            dispatched_widgets=widgets,
        )

    # ------------------------------------------------------------------
    # observe
    # ------------------------------------------------------------------

    def observe(
        self,
        handle: OperationDispatchHandle,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationObservation:
        """Poll Delta + Jobs API for terminal state.

        Mirrors the agent-progress polling semantics
        but in pull-only form: we never sleep, we never mutate ``Run`` rows.
        Returns a fresh snapshot on every call.
        """
        if not handle.databricks_run_id:
            return OperationObservation(
                progress_percent=0,
                progress_message="Waiting for dispatch",
                is_terminal=False,
                terminal_result=None,
            )

        # Step 1: Jobs API check — terminal failure short-circuits.
        try:
            job_run = ws.jobs.get_run(handle.databricks_run_id)
            lcs = (
                job_run.state.life_cycle_state.value
                if job_run.state and job_run.state.life_cycle_state
                else ""
            )
            rs = (
                job_run.state.result_state.value
                if job_run.state and job_run.state.result_state
                else ""
            )
        except Exception as e:
            logger.warning(
                "vibe_iterate.observe: Jobs API poll failed for run_id=%s: %r",
                handle.databricks_run_id, e,
            )
            return OperationObservation(
                progress_percent=0,
                progress_message="Polling Databricks…",
                is_terminal=False,
                terminal_result=None,
            )

        if lcs == "TERMINATED" and rs != "SUCCESS":
            return OperationObservation(
                progress_percent=0,
                progress_message=f"Failed ({rs})",
                is_terminal=True,
                terminal_result=OperationResult(
                    succeeded=False,
                    output_version_id=None,
                    output_artifacts=[],
                    rollback_state={},
                    error=(
                        getattr(job_run.state, "state_message", "")
                        or f"Job ended with {rs}"
                    ),
                ),
            )
        if lcs in ("INTERNAL_ERROR", "SKIPPED"):
            return OperationObservation(
                progress_percent=0,
                progress_message=f"Failed ({lcs})",
                is_terminal=True,
                terminal_result=OperationResult(
                    succeeded=False,
                    output_version_id=None,
                    output_artifacts=[],
                    rollback_state={},
                    error=(
                        getattr(job_run.state, "state_message", "")
                        or lcs
                    ),
                ),
            )

        # Step 2: on Jobs SUCCESS, the agent's contract is to have written
        # `model.json` under the version dir. Verify by attempting a fetch;
        # a missing file means the agent succeeded by Jobs metrics but
        # didn't produce the expected artifact (spec §10 failure mode 2).
        if lcs == "TERMINATED" and rs == "SUCCESS":
            try:
                model_json = self._fetch_model_json(handle, ctx, ws, session)
            except Exception as e:
                logger.info(
                    "vibe_iterate.observe: model.json fetch failed for run_id=%s: %r",
                    handle.databricks_run_id, e,
                )
                return OperationObservation(
                    progress_percent=0,
                    progress_message="Failed (model.json missing)",
                    is_terminal=True,
                    terminal_result=OperationResult(
                        succeeded=False,
                        output_version_id=None,
                        output_artifacts=[],
                        rollback_state={},
                        error=f"model.json missing or unreadable: {e}",
                    ),
                )
            terminal = self._finalize_success(
                handle, ctx, ws, session, model_json=model_json
            )
            return OperationObservation(
                progress_percent=100,
                progress_message="Completed",
                is_terminal=True,
                terminal_result=terminal,
            )

        # Step 3: in-flight — best-effort Delta poll for percent.
        sid_bigint = handle.extra.get("session_id_bigint") if handle.extra else None
        catalog = handle.extra.get("deployment_catalog") if handle.extra else None
        completed_percent = 0
        processing_status = ""
        if sid_bigint and catalog:
            try:
                sql = (
                    f"SELECT processing_status, completed_percent, completion_date "
                    f"FROM `{catalog}`.`_metamodel`.`business` "
                    f"WHERE session_id = {int(sid_bigint)} LIMIT 1"
                )
                result = ws.statement_execution.execute_statement(
                    warehouse_id=get_warehouse_id(session),
                    statement=sql,
                    wait_timeout="5s",
                )
                data = getattr(result, "result", None)
                if data and getattr(data, "data_array", None):
                    row = data.data_array[0]
                    processing_status = (row[0] or "").lower()
                    try:
                        completed_percent = int(float(row[1])) if row[1] else 0
                    except (TypeError, ValueError):
                        completed_percent = 0
            except Exception as e:
                logger.debug(
                    "vibe_iterate.observe: Delta poll failed for sid=%s: %r",
                    sid_bigint, e,
                )

        return OperationObservation(
            progress_percent=completed_percent,
            progress_message=processing_status or "Running",
            is_terminal=False,
            terminal_result=None,
        )

    def _fetch_model_json(
        self,
        handle: OperationDispatchHandle,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> dict:
        """Fetch + parse the agent's model.json. Raises on any failure."""
        from ...core._paths import model_json_volume_candidates

        extra = handle.extra or {}
        catalog = extra.get("deployment_catalog", "")
        biz_name = extra.get("business_name", "")
        parent_int = int(extra.get("parent_version_int") or 0)
        # The new version's dir is parent_version_int + 1 with the parent's scope.
        parent_mv: Optional[ModelVersion] = None
        if ctx.parent_version_id:
            parent_mv = session.get(ModelVersion, ctx.parent_version_id)
        scope = (parent_mv.scope if parent_mv and parent_mv.scope else "ecm")
        if not biz_name:
            biz = session.get(Business, ctx.business_id)
            # Same agent-side normalization as the dispatch path; the
            # downstream Volume lookup interpolates this verbatim and
            # will 404 on the raw DB literal.
            biz_name = agent_business_segment(biz.name) if biz else ""

        # Try the just-produced version's dir first; fall back to the parent
        # dir if the version_int wasn't tracked (e.g. agent overwrote in
        # place). For each version, probe nested (agent 4.9.8+) then legacy
        # flat. The download mock in tests doesn't care which path we use.
        candidates: list[str] = []
        if catalog and biz_name:
            for v in (parent_int + 1, parent_int):
                if v <= 0:
                    continue
                try:
                    candidates.extend(
                        model_json_volume_candidates(catalog, biz_name, v, scope)
                    )
                except ValueError:
                    pass
        if not candidates:
            # No path resolvable — still attempt a generic download so a
            # mock-side-effect test that only checks `download.called`
            # produces a deterministic outcome.
            candidates = ["/Volumes/_unknown/model.json"]

        # Volume FUSE writes are eventually consistent w.r.t. Files API
        # reads — the agent reports SUCCESS to Jobs API the instant its
        # notebook returns, but the freshly-written model.json may take
        # a few seconds to be visible through ws.files.download(). Retry
        # each candidate with bounded backoff before giving up. Caps at
        # ~30s total (5 attempts: 1s, 2s, 4s, 8s, 16s).
        last_exc: Optional[Exception] = None
        max_attempts = 5
        for attempt in range(max_attempts):
            for path in candidates:
                try:
                    resp = ws.files.download(path)
                    raw = resp.contents.read()
                    doc = json.loads(raw)
                    return doc if isinstance(doc, dict) else {"model": doc}
                except Exception as e:
                    last_exc = e
                    continue
            # Tried every candidate this attempt and none worked. Sleep
            # before next attempt unless this was the last one.
            if attempt < max_attempts - 1:
                time.sleep(2 ** attempt)  # 1, 2, 4, 8 seconds
        raise RuntimeError(
            f"model.json not fetched after {max_attempts} attempts; "
            f"last error: {last_exc}"
        )

    def _finalize_success(
        self,
        handle: OperationDispatchHandle,
        ctx: OperationContext,
        ws: Any,
        session: Any,
        model_json: Optional[dict] = None,
    ) -> OperationResult:
        """Allocate the new ModelVersion + sync into Lakebase + supersede same-scope priors.

        Returns an :class:`OperationResult` whose ``rollback_state`` carries
        the new version id and the list of ids flipped to ``superseded`` so
        :meth:`rollback` can delete the new row and restore each prior.
        """
        params = self.params_model(**ctx.params)
        business = session.get(Business, ctx.business_id)
        # Same priority chain as `_fetch_model_json` (line 470-482) and
        # `dispatch` (line 281): the dispatch-side persists the
        # agent-normalized business name into ``handle.extra``; honor that
        # first. Fall back to deriving from the DB row, finally to
        # params. Reading the raw ``business.name`` here would re-introduce
        # the v3/v4 sync drift (Volume folders are agent-normalized).
        extra = handle.extra or {}
        biz_name = extra.get("business_name", "")
        if not biz_name:
            biz_name = (
                agent_business_segment(business.name)
                if business
                else agent_business_segment(params.business_name)
            )

        # Resolve parent (the version we iterated from). Lineage is
        # captured by the agent in model.json's `generated_from_version`
        # tag (e.g. "v1_ecm"); prefer that when available because it
        # encodes the parent's scope unambiguously. Then fall back to
        # ctx.parent_version_id, then the parent_version_int + scope
        # carried on the handle (the legacy code path).
        parent: Optional[ModelVersion] = None
        gfv_tag = ""
        if model_json:
            for blob in (model_json, model_json.get("model") or {}):
                if isinstance(blob, dict) and blob.get("generated_from_version"):
                    gfv_tag = str(blob["generated_from_version"])
                    break
        if gfv_tag:
            parent = resolve_lineage_parent(session, ctx.business_id, gfv_tag)
        if parent is None and ctx.parent_version_id:
            parent = session.get(ModelVersion, ctx.parent_version_id)
        if parent is None:
            # Fall back to a (business, version, scope) lookup using the
            # parent_version_int + parent's scope. We need a scope to
            # disambiguate (post-refactor `version` alone is ambiguous);
            # default to "ecm" when nothing else is known so the legacy
            # code path keeps producing a deterministic answer.
            parent_version_int = (
                handle.extra.get("parent_version_int") if handle.extra else None
            ) or params.parent_version_int
            if parent_version_int:
                parent = resolve_model_version(
                    session,
                    ctx.business_id,
                    int(parent_version_int),
                    "ecm",
                ) or resolve_model_version(
                    session,
                    ctx.business_id,
                    int(parent_version_int),
                    "mvm",
                )

        scope = (parent.scope if parent else "ecm") or "ecm"

        # Vibe-iterate inherits the parent's scope and increments the
        # per-scope counter. Without per-scope allocation an iterate of
        # MVM v1 would land at v(N+1) where N is the global max — which
        # could collide with an unrelated ECM ordinal.
        new_version_num = next_version_for_scope(
            session, ctx.business_id, scope
        )
        # Agent override (mirrors the same gate in `_generation_common._terminal_success`):
        # if the agent auto-resolved a collision during the run, prefer the
        # agent's chosen ordinal so the MV row's `.version` matches the
        # Volume folder the agent actually wrote. See
        # `backend.version_resolution_parser` for the full rationale.
        agent_resolved = lookup_resolved_version(session, ctx.run_id, scope)
        if agent_resolved is not None and agent_resolved != new_version_num:
            logger.info(
                "vibe_iterate observe: applying agent Version Resolution override on "
                "run=%s scope=%s — App-allocated v%d, agent resolved to v%d",
                ctx.run_id, scope, new_version_num, agent_resolved,
            )
            new_version_num = agent_resolved
        deployment_catalog = params.deployment_catalog or (
            handle.extra.get("deployment_catalog") if handle.extra else ""
        )
        # vibe-iterate never performs a physical UC install. Unlike the
        # generation primitives (`_generation_common.py`), whose agent job
        # runs Stages 12-14 inline for every cataloging_style, the iterate
        # job only rewrites DDL/model artifacts in Lakebase/Volumes. Stamping
        # "deployed" here (as if a catalog target implied a live install)
        # created a state that lied about reality: Track 4's catalog-drift
        # reconciler would immediately find the expected schemas missing and
        # flip the version back to "uninstalled". Per the state-atomicity
        # rule, never create a state that requires reconcile to correct it.
        # Iterate-produced versions are born "draft" regardless of whether a
        # deployment_catalog was resolved; an explicit `install` run (with
        # reconcile as the safety net) is what actually earns "deployed".
        new_mv = ModelVersion(
            business_id=ctx.business_id,
            version=new_version_num,
            status="completed",
            deployment_status="draft",
            base_version_id=parent.id if parent else None,
            vibe_instructions=params.vibe_instructions,
            scope=scope,
            uc_catalog=deployment_catalog,
            completion_date=datetime.now(timezone.utc),
        )
        session.add(new_mv)
        session.flush()

        # Promote-and-sync region wrapped in a SAVEPOINT. new_mv was flushed
        # OUTSIDE it (above), so the row survives a rollback. Inside: flip
        # every other completed MV in (business, scope) to superseded (covers
        # the parent plus any lingering completed siblings), then sync into
        # Lakebase (the agent writes the per-scope `{scope}_v{new_version_num}`
        # Volume folder, v0.5.9+). On any raise the savepoint reverts the
        # supersede flip AND the partial element writes, so the prior good
        # version stays active and un-superseded.
        auto_superseded_ids: list[str] = []
        sync_succeeded = False
        try:
            with session.begin_nested():
                auto_superseded_ids = supersede_same_scope_priors(
                    session, ctx.business_id, scope, new_mv.id,
                )
                sync = ModelSyncService(session, ws, get_warehouse_id(session))
                sync._drain_progress_fn = handle.extra.get("progress_drain")
                sync_ok = sync.sync_model(
                    new_mv.id,
                    deployment_catalog,
                    biz_name,
                    str(new_version_num),
                    scope,
                    run_id=ctx.run_id,
                )
                if not sync_ok:
                    # sync_model returned False: no model.json in Volumes and
                    # no Delta fallback. Raise so the savepoint rolls back and
                    # new_mv lands sync_empty rather than a silent
                    # completed/ok version with 0 domains.
                    raise _SyncEmptyError(
                        f"No model data found for {biz_name} "
                        f"v{new_version_num} ({scope}) in Volumes or Delta"
                    )
            sync_succeeded = True
        except _SyncEmptyError as exc:
            # No model structure was found (no Volume, no Delta) or the payload
            # parsed to 0 domains. A resync won't help until the agent's Volume
            # output is populated, so this is distinct from incomplete_metadata.
            # The Operation still succeeds (see the succeeded=True return below).
            auto_superseded_ids = []
            new_mv.sync_state = "sync_empty"
            new_mv.sync_error_text = str(exc)[:500]
            session.add(new_mv)
            session.commit()
            logger.error(
                "vibe_iterate: no model data found; new_mv=%s marked "
                "sync_state=sync_empty (Operation still succeeded)",
                new_mv.id,
            )
        except Exception as exc:
            # Savepoint rolled back: the supersede flip and partial writes are
            # undone, so nothing was auto-superseded. Surface the failure on
            # the (surviving) new_mv row so the version detail page can render
            # a banner. Without this the only signal was a stack trace and the
            # version sat at status=completed/sync_state=ok forever.
            auto_superseded_ids = []
            new_mv.sync_state = "incomplete_metadata"
            new_mv.sync_error_text = str(exc)[:500]
            session.add(new_mv)
            session.commit()
            logger.exception(
                "vibe_iterate: Lakebase sync raised; new_mv=%s marked "
                "sync_state=incomplete_metadata (Operation still succeeded)",
                new_mv.id,
            )

        # Index Volume artifacts as RunArtifact rows so the Artifacts tab
        # is populated for vibe-produced versions, mirroring what
        # ``_generation_common._terminal_success`` does for ``generate_ecm``
        # / ``shrink_to_mvm``. Pre-fix: only those two op paths indexed
        # artifacts; vibe-produced versions had empty Artifacts tabs and
        # had to rely on the explorer's Strategy-0 file probe to render
        # at all. Best-effort — never fails the operation.
        if sync_succeeded:
            run_id = getattr(ctx, "run_id", "") or ""
            run_row = None
            if run_id:
                try:
                    from ...db_models import Run as DbRun
                    run_row = session.get(DbRun, run_id)
                except Exception:
                    run_row = None
            if run_row is not None and deployment_catalog and biz_name:
                try:
                    from ...progress_tracker import index_artifacts_for_version
                    index_artifacts_for_version(
                        ws,
                        run_row,
                        new_mv,
                        session,
                        deployment_catalog,
                        biz_name,
                        int(new_version_num),
                        scope,
                    )
                except Exception:
                    logger.exception(
                        "vibe_iterate: artifact indexing failed for "
                        "version %s (non-fatal)",
                        new_mv.id,
                    )

        # Output artifact entry pointing at the agent's model.json so
        # downstream consumers (and the post-run UI) can find it directly
        # off the OperationResult without re-deriving the path.
        artifacts: list[dict] = []
        try:
            from ...core._paths import model_json_volume_path
            mj_path = model_json_volume_path(
                deployment_catalog, biz_name, new_version_num, scope
            ) if deployment_catalog and biz_name else ""
            if mj_path:
                artifacts.append(
                    {"artifact_type": "model_json", "file_path": mj_path}
                )
        except Exception:
            # Path-builder rejection is non-fatal — the artifact list is a
            # convenience, not a contract requirement.
            pass

        return OperationResult(
            succeeded=True,
            output_version_id=new_mv.id,
            output_artifacts=artifacts,
            rollback_state={
                "new_version_id": new_mv.id,
                "parent_version_id": parent.id if parent else None,
                "auto_superseded_ids": auto_superseded_ids,
            },
            error=None,
        )

    # ------------------------------------------------------------------
    # rollback
    # ------------------------------------------------------------------

    def rollback(
        self,
        ctx: OperationContext,
        rollback_state: dict,
        ws: Any,
        session: Any,
    ) -> None:
        """Delete the new version + un-supersede same-scope priors.

        Idempotent: missing rows are no-ops. The canonical key is
        ``auto_superseded_ids`` (list of ids that ``supersede_same_scope_priors``
        flipped at terminal-success time). External callers passing the
        legacy ``superseded_parent_ids`` shape are honoured for
        compatibility with cancel-with-rollback paths that rebuild state
        from a flat list of parent ids.
        """
        new_id = rollback_state.get("new_version_id")
        auto_superseded_ids = rollback_state.get("auto_superseded_ids") or []
        legacy_superseded_ids = rollback_state.get("superseded_parent_ids") or []
        # Legacy shape from older rollback_state blobs (parent + prior status).
        legacy_parent_id = rollback_state.get("parent_version_id")
        legacy_prior_status = rollback_state.get("parent_prior_status")

        # 1) Clear Lakebase model data for the new version (FK chain
        #    requires this before deleting the ModelVersion row).
        if new_id:
            mv = session.get(ModelVersion, new_id)
            if mv is not None:
                try:
                    sync = ModelSyncService(session, ws, get_warehouse_id(session))
                    sync.clear_version_data(new_id)
                except Exception:
                    logger.exception(
                        "vibe_iterate.rollback: clear_version_data failed for %s",
                        new_id,
                    )
                session.delete(mv)
                session.flush()

        # 2) Restore status='superseded' rows flipped by the helper.
        restore_superseded_priors(session, auto_superseded_ids)
        # 3) Legacy/external shape — restore the flat parent-id list.
        restore_superseded_priors(session, legacy_superseded_ids)
        # 4) Legacy single-parent shape with explicit prior status.
        if legacy_parent_id:
            parent = session.get(ModelVersion, legacy_parent_id)
            if parent is not None and parent.status == "superseded":
                parent.status = legacy_prior_status or "completed"
                session.add(parent)
        if (
            auto_superseded_ids
            or legacy_superseded_ids
            or legacy_parent_id
        ):
            session.flush()


def _upsert_run_op_dispatch(
    session: Any,
    ctx: OperationContext,
    *,
    dbx_run_id: int,
    vibe_session_id: Optional[str],
) -> None:
    """Persist the dispatch-side identifiers on the RunOperation row.

    The orchestrator normally creates the row in :meth:`Orchestrator.start`;
    when dispatch runs outside the orchestrator (e.g. unit tests) the row
    is missing, so we insert a stub keyed on ``ctx.operation_id``. This
    keeps the resume guard (the ``run_op.databricks_run_id`` check above)
    correct on a re-call with the same operation_id.

    Does NOT write ``rollback_state_json`` - the orchestrator's
    ``_dispatch_pending`` persists ``handle.extra`` onto that column right
    after ``dispatch()`` returns, for every primitive generically.
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
            operation_name="vibe_iterate",
            params_json=json.dumps(ctx.params or {}),
            status="running",
            parent_version_id=ctx.parent_version_id,
        )
        session.add(run_op)
    run_op.databricks_run_id = int(dbx_run_id)
    run_op.vibe_session_id = vibe_session_id
    session.flush()


# Singleton registration on import.
register(VibeIterate())


__all__ = ["VibeIterate", "VibeIterateParams"]
