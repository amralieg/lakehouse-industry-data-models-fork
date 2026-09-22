"""``install`` deployment primitive.

Wraps the agent's ``install model`` notebook operation. The op is a pure
deployment side-effect — it does NOT produce a new ``ModelVersion``; the
orchestrator owns version creation and the install consumes whatever
ModelVersion the prior generation step produced.

See ``docs/orchestrator-design.md`` §2 + §10:

- ``produces_version=False``: the install never creates a row in
  ``ModelVersion``. ``parent_version_id`` on ``OperationContext`` points at
  the version being deployed.
- Polling: Jobs API only, no Delta polling. Lifecycle ops don't surface
  ``_vibe_progress`` rows (see ``backend.job_launcher.LIFECYCLE_OPS``).
- Rollback: emit an ``uninstall_schema`` against the catalog + scope_short
  by re-launching the agent's ``uninstall model version`` job.
- Safety gate: rollback refuses (raises) if the in-flight Databricks job
  has already TERMINATED with SUCCESS. The orchestrator's cancel-with-
  rollback path checks Jobs API state first and surfaces a 409 — this
  primitive's rollback enforces the same invariant defensively in case
  the gate is ever bypassed.
"""

from __future__ import annotations

import logging
from typing import Any, Literal, Optional

from pydantic import BaseModel, Field, model_validator
from sqlmodel import select

from ...core._paths import model_json_volume_path
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

logger = logging.getLogger(__name__)


class InstallParams(BaseModel):
    """Parameters for the ``install`` primitive.

    The agent's ``install model`` op is parameterised by scope, target
    catalog, schema_prefix (computed by the DAG factory upstream via
    :func:`compute_install_catalog_and_prefix`), the version to install,
    and the cataloging style. Naming-convention pass-throughs are
    forwarded to the agent so the install lays out schemas the same way
    the corresponding generation op did.
    """

    scope: Literal["ecm", "mvm"]
    business_name: str = Field(pattern=r"^[a-z][a-z0-9_]+$")
    deployment_catalog: str = Field(pattern=r"^[a-z][a-z0-9_]+$")
    schema_prefix: str = Field(default="", pattern=r"^[a-z][a-z0-9_]*_$|^$")
    model_version: int = Field(gt=0)
    cataloging_style: Literal[
        "One Catalog", "Catalog per Division", "Catalog per Domain"
    ] = "One Catalog"
    naming_convention: str = "snake_case"
    primary_key_suffix: str = "_id"
    table_id_type: str = "BIGINT"
    # Override for the agent's ``context_file`` (the model.json path) when
    # the ModelVersion didn't come from a same-business agent run. The
    # constructed default (see ``_build_install_widgets``) points at
    # ``business/<biz>/<scope>_v<N>/model.json`` — correct for agent-
    # produced versions where the agent itself wrote that file. For
    # imported ModelVersions and reference seeds, the model.json lives at
    # ``ModelVersion.import_source_path`` instead; the DAG factory passes
    # that value here so the install op reads the actual file rather than
    # crashing with "Model JSON File not found" on the constructed path.
    context_file_override: Optional[str] = None

    @model_validator(mode="after")
    def _schema_prefix_matches_cataloging_style(self):
        """Enforce the cross-field rule from spec §2.4.

        - ``One Catalog``: a non-empty ``schema_prefix`` is required because
          all scopes share the same catalog and need a per-scope namespace.
        - ``Catalog per Division`` / ``Catalog per Domain``: the per-scope
          catalog already provides the namespace, so a ``schema_prefix`` is
          forbidden (passing one would silently double up the namespace).
        """
        if self.cataloging_style == "One Catalog" and not self.schema_prefix:
            raise ValueError(
                "One Catalog cataloging_style requires a non-empty schema_prefix"
            )
        if self.cataloging_style != "One Catalog" and self.schema_prefix:
            raise ValueError(
                f"{self.cataloging_style} cataloging_style forbids schema_prefix; "
                "leave it empty"
            )
        return self


def _build_install_widgets(p: InstallParams, session_id_bigint: str) -> dict[str, str]:
    """Compose the ``install model`` widget map.

    The DAG factory is responsible for resolving ``deployment_catalog``
    and ``schema_prefix`` via :func:`compute_install_catalog_and_prefix`
    before constructing the params — this primitive does not reapply
    that derivation.

    ``context_file`` priority:
    1. ``p.context_file_override`` when set — the DAG factory threads
       ``ModelVersion.import_source_path`` here for imported and
       reference-seeded versions whose model.json doesn't live at the
       agent-output convention.
    2. The agent-output convention path
       ``<deployment_catalog>/_metamodel/vol_root/business/<biz>/<scope>_v<N>/model.json``
       — correct for ModelVersions written by a same-business agent run.
    """
    if p.context_file_override:
        context_file = p.context_file_override
    else:
        context_file = model_json_volume_path(
            p.deployment_catalog, p.business_name, int(p.model_version), p.scope
        )
    return {
        "operation": "install model",
        "business_name": p.business_name,
        "deployment_catalog": p.deployment_catalog,
        "data_model_scopes": scope_label(p.scope),
        "model_version": str(p.model_version),
        "context_file": context_file,
        "generate_samples": "0",
        "schema_prefix": p.schema_prefix,
        "cataloging_style": p.cataloging_style,
        "naming_convention": p.naming_convention,
        "primary_key_suffix": p.primary_key_suffix,
        "table_id_type": p.table_id_type,
        "vibe_session_id": session_id_bigint,
    }


def _resolve_agent_job_id(session: Any) -> Optional[int]:
    """Look up the configured agent job id, or ``None`` if unconfigured."""
    cfg = session.exec(select(AgentConfig).limit(1)).first()
    if not cfg or not cfg.job_id:
        return None
    return cfg.job_id


def _mark_version_deployed(
    session: Any, version_id: Optional[str], uc_catalog: str
) -> None:
    """Stamp ``deployment_status='deployed'`` + ``uc_catalog`` on successful
    install.

    ``install`` is the one primitive that DOES physically deploy the model
    into Unity Catalog (unlike ``vibe_iterate``, which only rewrites
    Lakebase/Volume artifacts - see the "born draft" rationale in
    ``vibe_iterate.py``). Without this write-back the target ``ModelVersion``
    stays ``draft``/``uc_catalog=""`` forever even though the schemas exist,
    which both keeps offering "Install" in the UI and starves the
    installation-status drift probe of the ``uc_catalog`` it needs to run
    (see ``routes/versions.py::get_installation_status``).

    Mirrors ``uninstall.py::_mark_version_uninstalled``: no-op if
    ``version_id`` is missing (e.g. a legacy/hand-built context) rather than
    failing the whole terminal observation over a metadata write.
    """
    if not version_id:
        return
    try:
        mv = session.get(ModelVersion, version_id)
    except Exception:  # noqa: BLE001 - best-effort metadata write
        return
    if mv is None:
        return
    changed = False
    if uc_catalog and mv.uc_catalog != uc_catalog:
        mv.uc_catalog = uc_catalog
        changed = True
    elif not uc_catalog:
        # Loud, not silent: stamping deployed with an empty uc_catalog is
        # exactly the asymmetry that shipped a "deployed" ModelVersion the
        # installation-status drift probe could never check (empty
        # uc_catalog short-circuits ``get_installation_status`` to a
        # cannot-probe skip). This should be unreachable now that dispatch
        # extras round-trip through the DB (see ``_runner.py::
        # _dispatch_pending``) and ``dag_for_install`` always resolves a
        # non-empty catalog — if this fires, something upstream regressed.
        logger.warning(
            "_mark_version_deployed: stamping version_id=%s deployed with "
            "an EMPTY uc_catalog — the drift probe will not be able to "
            "verify this install. Check the dispatch-time deployment_catalog "
            "resolution for this run's install RunOperation.",
            version_id,
        )
    if mv.deployment_status != "deployed":
        mv.deployment_status = "deployed"
        changed = True
    if changed:
        session.add(mv)


def _terminal_observation(
    *, succeeded: bool, error: Optional[str], rollback_state: dict
) -> OperationObservation:
    """Build a terminal observation."""
    return OperationObservation(
        progress_percent=100,
        progress_message="completed" if succeeded else (error or "failed"),
        is_terminal=True,
        terminal_result=OperationResult(
            succeeded=succeeded,
            output_version_id=None,  # install never produces a version
            output_artifacts=[],
            rollback_state=rollback_state,
            error=error,
        ),
    )


class Install(Operation):
    """``install model`` primitive (Group B — deployment).

    See module docstring for the rollback strategy and safety gate.
    """

    name = "install"
    params_model = InstallParams
    is_idempotent = True
    produces_version = False

    def dispatch(
        self,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationDispatchHandle:
        params = InstallParams(**ctx.params)

        sid = generate_session_id()
        sid_bigint = str(session_id_to_bigint(sid))
        widgets = _build_install_widgets(params, sid_bigint)

        job_id = _resolve_agent_job_id(session)
        if not job_id:
            raise RuntimeError(
                "Agent not configured — cannot dispatch `install` primitive."
            )

        job_tags = build_job_tags_from_session(
            session,
            business_name=params.business_name,
            model_scope=params.scope,
            version=str(params.model_version),
            operation="install",
            session_id=sid,
        )
        dbx_run_id = launch_run(ws, job_id, widgets, job_tags=job_tags)
        return OperationDispatchHandle(
            databricks_run_id=dbx_run_id,
            vibe_session_id=sid,
            extra={
                "scope": params.scope,
                "deployment_catalog": params.deployment_catalog,
                "schema_prefix": params.schema_prefix,
                "model_version": params.model_version,
                "business_name": params.business_name,
                "cataloging_style": params.cataloging_style,
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
            "deployment_catalog": handle.extra.get("deployment_catalog", ""),
            "schema_prefix": handle.extra.get("schema_prefix", ""),
            "scope": handle.extra.get("scope", ""),
            "model_version": handle.extra.get("model_version"),
            "business_name": handle.extra.get("business_name", ""),
            "cataloging_style": handle.extra.get("cataloging_style", ""),
            "jobs_terminal_result_state": rs,
        }

        if lcs == "TERMINATED":
            succeeded = rs == "SUCCESS"
            error = None if succeeded else (state_message or f"Job ended with {rs}")
            if succeeded:
                # The agent's install job just physically created/populated
                # the target schemas. Stamp Lakebase to match reality -
                # without this the version stays "draft" forever and the
                # drift probe can't even run (no uc_catalog to check
                # against). See `_mark_version_deployed` for rationale.
                _mark_version_deployed(
                    session,
                    ctx.parent_version_id,
                    handle.extra.get("deployment_catalog", ""),
                )
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
        """Emit an ``uninstall model version`` against the install target.

        Idempotent: a re-call against an already-uninstalled schema is the
        agent's responsibility to handle as a no-op (it does — uninstall
        is itself idempotent against missing schemas, see §10 failure
        table for the ``uninstall`` primitive).

        Safety gate: refuse to roll back if the in-flight job terminated
        SUCCESS. The orchestrator's cancel-with-rollback path performs
        the same check up front; this is a defence-in-depth invariant so
        the gate cannot be silently bypassed by a future caller.
        """
        terminal_rs = rollback_state.get("jobs_terminal_result_state", "")
        if terminal_rs == "SUCCESS" or rollback_state.get("job_terminated_success"):
            # Last observation reported the install completed cleanly. We
            # never tear down a successful install — the operator must do
            # that explicitly via the uninstall route.
            raise RuntimeError(
                "Refusing to roll back `install`: the in-flight Databricks "
                "job terminated SUCCESS at cancel time. Use the "
                "`uninstall` primitive directly to tear down a completed "
                "install."
            )

        # Accept either the canonical legacy widget key (``deployment_catalog``)
        # or the short-form key (``catalog``) the orchestrator may pass when
        # constructing rollback_state from a different source. Same for
        # ``model_version`` vs the legacy internal name ``version_int``.
        catalog = rollback_state.get("deployment_catalog") or rollback_state.get(
            "catalog", ""
        )
        version = rollback_state.get("model_version") or rollback_state.get(
            "version_int"
        )
        business_name = rollback_state.get("business_name", "")
        if not catalog or not version or not business_name:
            # Insufficient state to reverse — likely the original dispatch
            # never reached the agent (RuntimeError before
            # ``launch_run``). Treat as no-op rather than blowing up the
            # rollback chain.
            return

        job_id = _resolve_agent_job_id(session)
        if not job_id:
            # Agent unconfigured — schemas can't be torn down here.
            # No-op fallback rather than failing the chain.
            return

        sid = generate_session_id()
        sid_bigint = str(session_id_to_bigint(sid))
        # ``model_version`` may arrive as an int (from observe()) or a str
        # (from a hand-constructed rollback_state). The agent's metamodel
        # stores the bare integer; sending "v<n>" makes the uninstall's
        # version_candidates regex (^(\d+)) miss every install. Strip a
        # leading 'v' if present.
        model_version_widget = (
            str(version)[1:] if str(version).startswith("v") else str(version)
        )
        widgets = {
            "operation": "uninstall model version",
            "business_name": business_name,
            "deployment_catalog": catalog,
            "model_version": model_version_widget,
            "schema_prefix": rollback_state.get("schema_prefix", ""),
            "cataloging_style": rollback_state.get("cataloging_style", "One Catalog"),
            "vibe_session_id": sid_bigint,
        }
        # Fire-and-forget: the rollback chain is non-blocking. The
        # uninstall run is visible in the Jobs UI for operator follow-up.
        rollback_job_tags = build_job_tags_from_session(
            session,
            business_name=business_name,
            version=model_version_widget,
            operation="uninstall model version",
            session_id=sid,
        )
        launch_run(ws, job_id, widgets, job_tags=rollback_job_tags)
