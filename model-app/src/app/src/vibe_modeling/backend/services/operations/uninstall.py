"""``uninstall`` deployment primitive.

Wraps the agent's ``uninstall model version`` notebook operation. No
rollback — uninstall IS the rollback in the inverse direction (see
``docs/orchestrator-design.md`` §2 + §10).

- ``produces_version=False``: uninstall does not write to ``ModelVersion``.
- ``is_idempotent=True``: re-uninstalling missing schemas is a no-op
  (the agent treats missing schemas as success).
- Polling: Jobs API only. See ``backend.job_launcher.LIFECYCLE_OPS``.
- Rollback: not supported. The orchestrator never reverses an uninstall;
  to "undo" an uninstall the user must run a fresh ``install``.
"""

from __future__ import annotations

from typing import Any, Literal, Optional

from pydantic import BaseModel, Field
from sqlmodel import select

from ...db_models import AgentConfig, ModelVersion
from ...job_launcher import (
    build_job_tags_from_session,
    generate_session_id,
    launch_run,
    session_id_to_bigint,
)
from ._deployment_widgets import scope_label
from ._protocol import (
    Operation,
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
    OperationResult,
)


class UninstallParams(BaseModel):
    """Parameters for the ``uninstall`` primitive."""

    business_name: str = Field(min_length=1, pattern=r"^[a-z][a-z0-9_]+$")
    deployment_catalog: str = Field(min_length=1, pattern=r"^[a-z][a-z0-9_]+$")
    schema_prefix: str = ""
    scope: Literal["ecm", "mvm"]
    model_version: int = Field(gt=0)
    cataloging_style: Literal[
        "One Catalog", "Catalog per Division", "Catalog per Domain"
    ] = "One Catalog"
    # Lakebase ``ModelVersion.id`` of the version being uninstalled.
    # Carried so ``observe`` can flip ``deployment_status='uninstalled'``
    # the moment the agent reports terminal success — without it, the UI
    # keeps showing "Installed" after a successful uninstall (the agent
    # has no idea the app's Lakebase row exists).
    version_id: Optional[str] = None


def _build_uninstall_widgets(p: UninstallParams, session_id_bigint: str) -> dict[str, str]:
    """Compose the ``uninstall model version`` widget map.

    The agent's uninstall op is parameterised by (catalog, business_name,
    version) — schema_prefix + cataloging_style let it find the exact
    schemas the matching install laid down (One Catalog uses
    ``{prefix}{domain}`` schemas; Catalog-per-* uses dedicated catalogs
    and the prefix is empty).

    ``data_model_scopes`` is a universal agent widget (see the integration
    guide's "Widget values to pass as base_parameters" table), not an
    install-only one. Before this was added here, an uninstall dispatch
    omitted it entirely and the agent's Model Scope widget fell back to
    its own default (MVM) regardless of which scope was actually being
    uninstalled — verified live: an ECM uninstall (``schema_prefix=
    "ecm_"``) dropped all of the business's ``mvm_*`` schemas instead of
    the intended ``ecm_*`` ones. Must always be set, matching
    ``install``/``generate_samples``.
    """
    return {
        "operation": "uninstall model version",
        "business_name": p.business_name,
        "deployment_catalog": p.deployment_catalog,
        "data_model_scopes": scope_label(p.scope),
        "model_version": str(p.model_version),
        "schema_prefix": p.schema_prefix,
        "cataloging_style": p.cataloging_style,
        "vibe_session_id": session_id_bigint,
    }


def _resolve_agent_job_id(session: Any) -> Optional[int]:
    cfg = session.exec(select(AgentConfig).limit(1)).first()
    if not cfg or not cfg.job_id:
        return None
    return cfg.job_id


def _terminal_observation(
    *, succeeded: bool, error: Optional[str], rollback_state: dict
) -> OperationObservation:
    return OperationObservation(
        progress_percent=100,
        progress_message="completed" if succeeded else (error or "failed"),
        is_terminal=True,
        terminal_result=OperationResult(
            succeeded=succeeded,
            output_version_id=None,
            output_artifacts=[],
            rollback_state=rollback_state,
            error=error,
        ),
    )


def _mark_version_uninstalled(session: Any, version_id: Optional[str]) -> None:
    """Flip ``ModelVersion.deployment_status`` to ``"uninstalled"`` on
    successful uninstall. No-op if ``version_id`` is missing or the row
    is already in a non-deployed state — uninstall is idempotent
    metadata-wise: a re-uninstall of an already-uninstalled version
    just keeps the metadata correct.
    """
    if not version_id:
        return
    try:
        mv = session.get(ModelVersion, version_id)
    except Exception:  # noqa: BLE001 — best-effort metadata write
        return
    if mv is None:
        return
    if mv.deployment_status != "uninstalled":
        mv.deployment_status = "uninstalled"
        session.add(mv)


class Uninstall(Operation):
    """``uninstall model version`` primitive (Group B — deployment)."""

    name = "uninstall"
    params_model = UninstallParams
    is_idempotent = True
    produces_version = False

    def dispatch(
        self,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationDispatchHandle:
        params = UninstallParams(**ctx.params)

        sid = generate_session_id()
        sid_bigint = str(session_id_to_bigint(sid))
        widgets = _build_uninstall_widgets(params, sid_bigint)

        job_id = _resolve_agent_job_id(session)
        if not job_id:
            raise RuntimeError(
                "Agent not configured — cannot dispatch `uninstall` primitive."
            )

        job_tags = build_job_tags_from_session(
            session,
            business_name=params.business_name,
            version=str(params.model_version),
            operation="uninstall",
            session_id=sid,
        )
        dbx_run_id = launch_run(ws, job_id, widgets, job_tags=job_tags)
        return OperationDispatchHandle(
            databricks_run_id=dbx_run_id,
            vibe_session_id=sid,
            extra={
                "deployment_catalog": params.deployment_catalog,
                "model_version": params.model_version,
                "business_name": params.business_name,
            },
            dispatched_widgets=widgets,
        )

    def observe(
        self,
        handle: OperationDispatchHandle,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationObservation:
        if handle.databricks_run_id is None:
            return OperationObservation(
                progress_percent=0,
                progress_message="awaiting dispatch",
                is_terminal=False,
                terminal_result=None,
            )

        try:
            job_run = ws.jobs.get_run(handle.databricks_run_id)
        except Exception as e:  # noqa: BLE001 — surface the message
            return OperationObservation(
                progress_percent=0,
                progress_message=f"poll error: {e!r}",
                is_terminal=False,
                terminal_result=None,
            )

        state = getattr(job_run, "state", None)
        lcs = ""
        rs = ""
        state_message = ""
        if state is not None:
            lcs_obj = getattr(state, "life_cycle_state", None)
            rs_obj = getattr(state, "result_state", None)
            lcs = getattr(lcs_obj, "value", "") if lcs_obj is not None else ""
            rs = getattr(rs_obj, "value", "") if rs_obj is not None else ""
            state_message = getattr(state, "state_message", "") or ""

        rollback_state = {
            "databricks_run_id": handle.databricks_run_id,
            "jobs_terminal_result_state": rs,
        }

        if lcs == "TERMINATED":
            succeeded = rs == "SUCCESS"
            error = None if succeeded else (state_message or f"Job ended with {rs}")
            if succeeded:
                # The agent reports "success" even when there was nothing
                # to drop (DROP SCHEMA IF EXISTS is a no-op on missing
                # schemas). Treat that as the user-visible truth: the
                # version is no longer installed, regardless of whether
                # any DDL fired. Update Lakebase metadata accordingly so
                # the UI stops showing a phantom "Installed" badge.
                params = UninstallParams(**ctx.params)
                _mark_version_uninstalled(session, params.version_id)
            return _terminal_observation(
                succeeded=succeeded, error=error, rollback_state=rollback_state
            )
        if lcs in ("INTERNAL_ERROR", "SKIPPED"):
            return _terminal_observation(
                succeeded=False,
                error=state_message or lcs,
                rollback_state=rollback_state,
            )
        return OperationObservation(
            progress_percent=10,
            progress_message=f"{lcs}/{rs}" if lcs else "running",
            is_terminal=False,
            terminal_result=None,
        )

    def rollback(
        self,
        ctx: OperationContext,
        rollback_state: dict,
        ws: Any,
        session: Any,
    ) -> None:
        """Uninstall has no rollback (uninstall IS the rollback).

        The orchestrator iterates ``RunOperation`` rows in reverse step
        order and calls ``rollback()`` on every succeeded op. For
        ``uninstall``, the only honest semantics is to do nothing:
        re-installing the schemas would require a fresh ModelVersion the
        orchestrator does not own. Operators who want to "undo" an
        uninstall must launch a new ``install`` run.
        """
        return None
