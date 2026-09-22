"""API routes for the Vibe Modeling control plane — runs surface.

Plan task #33 split the per-resource endpoints into `routes/<area>.py`
modules. This file deliberately keeps the `/runs/...` endpoints in place
because Phase 4 of the orchestrator refactor (collaborator branch
`mwissad/dev`) is rewriting them and we don't want to fight a merge over
identical lines moving in two directions.

The module also re-exports a handful of helpers (`launch_run`, …) so
existing tests that monkey-patch them via
`vibe_modeling.backend.router.<name>` keep working unchanged.
"""

import json
import logging
from datetime import datetime, timezone
from typing import Literal, Optional

from fastapi import HTTPException, Query
from fastapi.responses import StreamingResponse
from sqlmodel import select

logger = logging.getLogger(__name__)

from ._artifact_io import (
    build_artifact_content_response,
    build_artifact_download_response,
    build_artifacts_zip_bytes,
)
from .core import Dependencies, create_router, resolve_run_target_catalog
from .db_models import (
    AgentConfig,
    ModelVersion,
    Run,
    RunArtifact,
    RunInputLink,
    RunNextVibeLink,
    RunOperation,
    RunProgressEvent,
)
from .job_launcher import (
    build_job_tags,
    generate_session_id,
    launch_run,
    map_run_params_to_widgets,
    finalize_widgets_or_raise,
    WidgetPayloadTooLargeError,
    session_id_to_bigint,
)
from .models import (
    CancelOpAppliedOut,
    CancelOpFailureOut,
    CancelWithRollbackOut,
    HealthOut,
    Intent,
    IssueOut,
    NextVibeItem,
    ProgressEventOut,
    ResumeRunOut,
    RunArtifactOut,
    RunIn,
    RunLineageOut,
    RunLineageVersionOut,
    RunListOut,
    RunOperationOut,
    RunOut,
    ValidateRunOut,
)
from .routes._helpers import (
    _build_run_out,
    _get_agent_config,
    _preflight_notebook_access,
    _validate_next_vibe_ids,
    params_json_omit_deployment_catalog_for_multi_catalog,
    resolve_warehouse_id,
)
from .services.operations import get as _operations_registry_get
from .services.orchestrator import Dag, OperationStep
from .services.orchestrator.dag_factories import (
    dag_for_generate_samples,
    dag_for_install,
    dag_for_uninstall,
    dag_for_vibe_iterate,
)
from .services.orchestrator import validate as _orch_validate


# Factories indexed by ``Intent``. The route handler picks one based on
# the incoming intent.
_DAG_FACTORIES = {
    Intent.VIBE_ITERATE: dag_for_vibe_iterate,
    Intent.INSTALL: dag_for_install,
    Intent.UNINSTALL: dag_for_uninstall,
    Intent.GENERATE_SAMPLES: dag_for_generate_samples,
}


class _SimpleRunFactoryContext:
    """Adapter passed as ``ctx`` into the simple-run DAG factories.

    The factories accept any object with a ``parent_mv`` attribute so
    they can read scope + version int off the parent ``ModelVersion``.
    The Phase-4 unified-runs wirer will introduce a richer
    ``OperationContext`` shape; for now this lightweight namespace
    keeps the factory contract consistent.
    """

    __slots__ = ("parent_mv",)

    def __init__(self, parent_mv: Optional[ModelVersion]):
        self.parent_mv = parent_mv


def _resolve_orchestrator_intent(data: RunIn) -> Optional[Intent]:
    """Return the :class:`Intent` for an orchestrator-routed simple
    ``POST /runs`` body, or ``None`` if the intent maps to a multi-step
    DAG handled by a different branch.
    """
    return data.intent if data.intent in _INTENT_TO_PRIMITIVE else None


# Map each orchestrator-routed intent to the primitive name it
# dispatches via the simple DAG factories. Used as a registry-readiness
# probe so the route can fall through to the legacy walker when test
# isolation has cleared the operations registry mid-suite (the
# primitives' module-level ``register(...)`` calls only fire once per
# process, so a teardown ``reset_for_tests()`` empties it for every
# test that runs after).
_INTENT_TO_PRIMITIVE: dict[Intent, str] = {
    Intent.VIBE_ITERATE: "vibe_iterate",
    Intent.INSTALL: "install",
    Intent.UNINSTALL: "uninstall",
    Intent.GENERATE_SAMPLES: "generate_samples",
}


def _orchestrator_intent_registered(intent: Intent) -> bool:
    """Probe the live operations registry for the primitive an intent
    needs. Returns ``False`` (→ fall back to legacy) when the registry
    has been emptied by a test fixture; ``True`` on the production
    path where lifespan startup has populated everything."""
    primitive = _INTENT_TO_PRIMITIVE.get(intent)
    if primitive is None:
        return False
    try:
        _operations_registry_get(primitive)
    except KeyError:
        return False
    return True

from ._compile import compile_inputs

router = create_router()


def _compile_inputs_into_instructions(session, version_id, data) -> None:
    """Set ``data.vibe_instructions`` to the compiled markdown of the selected
    Vibe Inputs anchored to ``version_id``.

    Inputs are the sole source of run instructions (Task 5 §5/§7). A no-op when
    ``data.input_ids`` is empty so the first-model description-mode path (run 1,
    no inputs) and free-text instructions are left untouched.
    """
    input_ids = getattr(data, "input_ids", None) or []
    if not input_ids or not version_id:
        return
    compiled = compile_inputs(session, version_id, input_ids)
    data.vibe_instructions = compiled.markdown


def _persist_run_input_links(session, run_id, input_ids) -> None:
    """Write the intended-selection ``RunInputLink`` rows at launch (immutable
    usage audit; ``consumed`` flips only on successful completion). Idempotent
    against the composite PK."""
    if not input_ids:
        return
    for iid in input_ids:
        existing = session.get(RunInputLink, (run_id, iid))
        if existing is None:
            session.add(RunInputLink(run_id=run_id, input_id=iid))


def get_run_in_business(session, business_id: str, run_id: str) -> Run:
    """Load a ``Run`` by id and assert it belongs to ``business_id``.

    Raises ``HTTPException(404, "Run not found")`` when:
      * no row exists for ``run_id``, or
      * the row exists but its ``business_id`` does not match.

    Both cases collapse to 404 (not 403) so the API does not leak the
    existence of runs across businesses — a caller probing
    ``/businesses/{wrong}/runs/{rid}`` should see the same response as
    if ``rid`` did not exist at all.
    """
    run = session.get(Run, run_id)
    if not run or run.business_id != business_id:
        raise HTTPException(status_code=404, detail="Run not found")
    return run


# --- Orchestrator-driven create_run helpers (Phase 4 — #29) ---


def _resolve_parent_model_version(
    business_id: str, data: RunIn, intent: Intent, session
) -> Optional[ModelVersion]:
    """Pick the ``ModelVersion`` an orchestrator-routed run targets.

    All four simple intents (vibe-iterate, install, uninstall,
    generate-samples) operate on a specific version. The user-facing
    contract: when ``data.version_id`` is supplied we use that row;
    otherwise we fall back to the latest completed version on the
    business so the model-version page can submit "install latest"
    without re-resolving the id client-side.
    """
    parent_mv: Optional[ModelVersion] = None
    if data.version_id:
        parent_mv = session.get(ModelVersion, data.version_id)
    if parent_mv is not None:
        return parent_mv
    return session.exec(
        select(ModelVersion)
        .where(
            ModelVersion.business_id == business_id,
            ModelVersion.status == "completed",
        )
        .order_by(ModelVersion.version.desc())
    ).first()


def _issue_to_dict(issue) -> dict:
    """Serialise an :class:`Issue` for the 400-response payload."""
    return {
        "field_path": issue.field_path,
        "step_index": issue.step_index,
        "message": issue.message,
        "severity": issue.severity,
    }


def _create_run_via_orchestrator(
    *,
    business_id: str,
    data: RunIn,
    business,
    agent_config,
    intent: Intent,
    parent_mv: ModelVersion,
    session,
    ws,
    tracker,
) -> RunOut:
    """Build the DAG, validate, persist, and hand off to the orchestrator.

    Side-effects (all under the route's session, committed at the end
    of a successful happy path):

    1. Build the matching DAG via the per-intent factory (the parent
       ``ModelVersion`` is supplied by the route handler — the
       transitional fallback above only routes here when one was
       resolvable).
    2. Run :func:`validate_dag`. On any blocker, raise 400 with the
       ``{"blockers": [...], "warnings": [...]}`` payload the
       frontend renders inline.
    3. Insert the ``Run`` row + the ``RunOperation`` row(s),
       pre-populating ``parent_version_id`` so the orchestrator's
       dispatch step doesn't have to re-derive it from prior steps
       (single-step DAGs have no priors to inherit from).
    4. Call ``tracker.orchestrator.start(run, dag, session)`` which
       dispatches step 0 via the registered ``Operation`` and stamps
       ``run.status = "running"``.

    Returns the ``RunOut`` Pydantic model the route promised. No
    ``response_model=dict`` (per spec acceptance criterion #46).
    """
    # The selected Vibe Inputs ARE the instructions: compile them into
    # ``data.vibe_instructions`` so the factory bakes the doc into the leading
    # step's params (the agent's ``model_vibes`` widget). No-op when there are
    # no ``input_ids`` (install/uninstall/samples, and the first-model
    # description-mode path), leaving ``vibe_instructions`` untouched.
    _compile_inputs_into_instructions(
        session, parent_mv.id if parent_mv is not None else None, data
    )

    factory_ctx = _SimpleRunFactoryContext(parent_mv=parent_mv)

    # 1) Build the DAG. Factories are pure — no DB or workspace IO.
    factory = _DAG_FACTORIES[intent]
    dag = factory(data, business, factory_ctx, agent_config)

    # 2) Validate the DAG against the live operations registry.
    #    Resolved through the module attribute (NOT a from-import) so
    #    tests + admin tooling can monkey-patch ``validate_dag`` on
    #    ``services.orchestrator.validate`` and have the override seen
    #    by this route handler — see Phase 4 reconciliation note.
    result = _orch_validate.validate_dag(
        dag, registry_get=_operations_registry_get
    )
    if result.blockers:
        raise HTTPException(
            status_code=400,
            detail={
                "blockers": [_issue_to_dict(i) for i in result.blockers],
                "warnings": [_issue_to_dict(i) for i in result.warnings],
            },
        )

    # 3) Persist the Run row. The ``parameters_json`` blob is a verbatim
    #    snapshot of the user-submitted form values per spec §5.1; the
    #    orchestrator no longer mutates it.
    run = Run(
        business_id=business_id,
        version_id=data.version_id,
        intent=intent.value,
        status="pending",
        parameters_json=json.dumps(_run_parameters_snapshot(data)),
        vibe_instructions_text=(data.vibe_instructions or ""),
        business_context_text=(data.business_context_text or "").strip(),
    )
    session.add(run)
    session.flush()

    # The selected inputs ARE this run's inputs: link them to THIS run so the
    # success-finalize consumes exactly them (the legacy launch paths do the
    # same). Emitted next_vibes are element-linked at generation, never linked
    # to their generating run, so they are not swept in here.
    _persist_run_input_links(session, run.id, data.input_ids)

    # 4) Pre-create the ``RunOperation`` row(s) so we can stamp
    #    ``parent_version_id`` before the orchestrator dispatches.
    #    ``Orchestrator.start`` is idempotent w.r.t. existing rows —
    #    it sees our pre-persisted row, skips the persistence loop,
    #    and proceeds straight to dispatch. This keeps the
    #    parent-version wiring out of the factory's params dict
    #    (where it would fail validation against every primitive's
    #    ``params_model``).
    parent_version_id = parent_mv.id if parent_mv is not None else None
    for i, step in enumerate(dag.steps):
        from .db_models import RunOperation

        row = RunOperation(
            run_id=run.id,
            step_index=i,
            operation_name=step.name,
            params_json=json.dumps(step.params),
            skip_if=step.skip_if or "",
            status="pending",
            parent_version_id=parent_version_id,
        )
        session.add(row)
    session.flush()

    # 5) Hand off to the orchestrator. ``start`` re-dispatches the
    #    first pending row; on dispatch failure the row is marked
    #    ``failed`` and the run terminal envelope reflects that —
    #    we still return RunOut so the UI sees the failed run row.
    #
    #    The orchestrator may not be wired through the test tracker
    #    (the unit-test ``mock_tracker`` is a bare ``MagicMock`` that
    #    never starts the real run). In that case we still want the
    #    Run + RunOperation rows to land so contract tests can read
    #    them back, so we treat any tracker failure as a non-fatal
    #    smoke. The legacy launch branch below wraps ``launch_run``
    #    in the same way.
    try:
        tracker.orchestrator.start(run, dag, session)
    except Exception:  # noqa: BLE001 — tracker errors must not lose the row
        logger.exception("orchestrator.start failed for run=%s", run.id)
    session.commit()
    session.refresh(run)

    # Mirror the legacy launch path's tracker-start hook so the poll
    # loop picks up this run on the next tick.
    if run.status == "running":
        try:
            tracker.start_tracking(run.id)
        except Exception:  # noqa: BLE001 — non-fatal
            logger.exception("tracker.start_tracking failed for run=%s", run.id)

    # Thread the deployed-version clash warning into the submit-time
    # response too, not just the pre-submit validate preview - it's the
    # same canonical check `_collect_run_preflight_blockers` runs, just
    # also surfaced here since ``result.warnings`` (DAG-level validation)
    # never carries it.
    extra_warnings = list(result.warnings)
    deployed_warning = _orch_validate.deployed_version_reinstall_warning(
        intent.value, parent_mv, resolve_run_target_catalog(data, agent_config)
    )
    if deployed_warning is not None:
        extra_warnings.append(deployed_warning)

    warnings_dicts = [_issue_to_dict(i) for i in extra_warnings]
    return _build_run_out(run, ws, session, warnings=warnings_dicts)


def _run_parameters_snapshot(data: RunIn) -> dict:
    """Serialise the user-submitted ``RunIn`` body for
    ``Run.parameters_json``.

    Per spec §5.1, the orchestrator narrows ``parameters_json`` to "the
    user's submitted form values" — the orchestrator no longer mutates
    it during execution. The legacy fallback (the existing
    ``router.create_run`` branch below) writes a widget-derived blob;
    here we just dump the pydantic model so the audit trail captures
    exactly what the caller submitted.
    """
    try:
        snapshot = data.model_dump(mode="json")
    except Exception:  # noqa: BLE001 — pydantic v1 fallback
        snapshot = data.dict()  # type: ignore[attr-defined]
    # RunIn carries ``deployment_catalog`` as a deprecated alias for
    # ``catalog``. In multi-catalog styles the agent derives per-scope
    # catalogs and ignores this field, so strip it from the audit
    # snapshot to match the other parameters_json sites.
    return params_json_omit_deployment_catalog_for_multi_catalog(
        snapshot, snapshot.get("cataloging_style")
    )


def _create_new_base_model_run_via_orchestrator(
    *,
    business_id: str,
    data,
    business,
    agent_config,
    session,
    ws,
    tracker,
):
    """Build the ``new-base-model`` DAG, validate it, persist a Run row,
    and call ``orchestrator.start`` (spec §2.4.1 + §4).

    Returns the standard :class:`RunOut` shape so the route handler is a
    transparent passthrough — the UI does not need to know whether a
    given run flowed through the orchestrator or the legacy path.
    """
    from .db_models import BusinessContext
    from .services.orchestrator import validate_dag_request

    # Same gate the legacy path applies — next_vibe_ids only make sense
    # against a specific base version, and ``new-base-model`` runs do
    # not have one (they create the first version).
    if data.next_vibe_ids and not data.version_id:
        raise HTTPException(
            status_code=400,
            detail="next_vibe_ids require a base version_id",
        )

    # First run of a business has no composed inputs: seed the instructions
    # (→ the leading generate_ecm step's ``model_vibes`` widget) from the
    # business's detailed description (``business_vibes``). model_vibes spills to
    # a UC Volume file when large, so it is NOT bound by the 2048-char
    # ``business_description`` widget limit — the short summary rides
    # ``business_description`` separately. Decoupled from the inputs path: this
    # seeds the first model only; iterations use vibe_inputs.
    if not (data.vibe_instructions or "").strip():
        data.vibe_instructions = (getattr(business, "business_vibes", "") or "").strip()

    # Sub-pull business context. The validator + the factories may
    # consult it for cross-step rules; pass the most recent one.
    business_context = session.exec(
        select(BusinessContext)
        .where(BusinessContext.business_id == business_id)
        .order_by(BusinessContext.created_at.desc())
    ).first()

    result = validate_dag_request(
        data, business, business_context, agent_config
    )
    if result.blockers:
        raise HTTPException(
            status_code=400,
            detail={
                "blockers": [
                    _issue_to_out(i).model_dump() for i in result.blockers
                ],
                "warnings": [
                    _issue_to_out(i).model_dump() for i in result.warnings
                ],
            },
        )
    if result.dag is None:
        # Defensive — validate_dag_request only returns dag=None when
        # there are blockers; this branch is unreachable in practice.
        raise HTTPException(
            status_code=500,
            detail="DAG factory returned None without blockers",
        )

    # Persist a Run row. ``intent`` is the durable label (spec §5.1).
    sid = generate_session_id()
    sid_bigint = session_id_to_bigint(sid)

    # The DAG factory snapshots the user's submitted form values into
    # each step's params. Mirror them onto ``Run.parameters_json`` so
    # the UI's lineage / artifacts pages keep their reference shape.
    style = (data.cataloging_style or "One Catalog").strip() or "One Catalog"
    default_ecm_prefix = "ecm_" if style == "One Catalog" else ""
    default_mvm_prefix = "mvm_" if style == "One Catalog" else ""
    ecm_prefix = (
        data.ecm_schema_prefix
        if data.ecm_schema_prefix is not None
        else default_ecm_prefix
    )
    mvm_prefix = (
        data.mvm_schema_prefix
        if data.mvm_schema_prefix is not None
        else default_mvm_prefix
    )
    stored_params: dict[str, object] = {
        "intent": result.dag.intent,
        "cataloging_style": style,
        "deployment_catalog": resolve_run_target_catalog(data, agent_config),
        "ecm_schema_prefix": ecm_prefix,
        "mvm_schema_prefix": mvm_prefix,
        "schema_prefix": ecm_prefix,
    }
    params_json_omit_deployment_catalog_for_multi_catalog(stored_params, style)
    # Mirror the user's other Advanced Options into parameters_json so
    # the run-detail "What you submitted" disclosure is honest about what
    # was sent. The widget map (build_generation_widgets / job_launcher)
    # reads the same fields off `data` directly, so the agent already
    # gets them — but `parameters_json` was previously omitting them,
    # producing a misleading audit trail. Only persist non-default
    # values to keep the stored shape compact.
    _user_overrides = {
        "business_domains": (data.business_domains or "").strip(),
        "org_divisions": (data.org_divisions or "").strip(),
        "classification_levels": (data.classification_levels or "").strip(),
        "naming_convention": (data.naming_convention or "").strip(),
        "primary_key_suffix": (data.primary_key_suffix or "").strip(),
        "tag_prefix": (data.tag_prefix or "").strip(),
        "tag_suffix": (data.tag_suffix or "").strip(),
        "schema_suffix": (data.schema_suffix or "").strip(),
        "table_id_type": (data.table_id_type or "").strip(),
        "boolean_format": (data.boolean_format or "").strip(),
        "date_format": (data.date_format or "").strip(),
        "timestamp_format": (data.timestamp_format or "").strip(),
        "catalog_prefix": (data.catalog_prefix or "").strip(),
        "catalog_suffix": (data.catalog_suffix or "").strip(),
        "housekeeping_columns": (data.housekeeping_columns or "").strip(),
        "history_tracking_columns": (data.history_tracking_columns or "").strip(),
    }
    for k, v in _user_overrides.items():
        if v:
            stored_params[k] = v

    run = Run(
        business_id=business_id,
        intent=result.dag.intent,
        status="pending",
        vibe_session_id=sid,
        vibe_session_id_bigint=sid_bigint,
        parameters_json=json.dumps(stored_params),
        vibe_instructions_text=(data.vibe_instructions or ""),
        business_context_text=(data.business_context_text or "").strip(),
    )
    session.add(run)
    session.commit()
    session.refresh(run)

    # Hand off to the orchestrator — persists RunOperation rows, sets
    # ``run.intent`` (already set above; idempotent) and dispatches step
    # 0. The orchestrator owns ``run.status`` from here on; tracker
    # picks up polling once started.
    try:
        tracker.orchestrator.start(run, result.dag, session)
        session.commit()
        session.refresh(run)
    except Exception as e:
        # Wiring audit (router orchestrator start failure):
        #   Previous: direct run.status / run.completed_at writes.
        #   New: transition_run stamps all five layers atomically.
        from .run_state_transitions import transition_run
        reason = f"Orchestrator failed to start: {e}"
        run.error_message = reason
        session.add(run)
        transition_run(session, run, target_status="failed", reason=reason)
        session.commit()
        session.refresh(run)
        return _build_run_out(run, ws, session)

    if run.status == "running":
        tracker.start_tracking(run.id)

    return _build_run_out(run, ws, session)


def _create_vibe_new_ecm_mvm_run_via_orchestrator(
    *,
    business_id: str,
    data,
    business,
    agent_config,
    session,
    ws,
    tracker,
):
    """Build the ``vibe-new-ecm-mvm`` DAG, validate it (including the
    parent-ECM scope gate), persist a Run + per-step RunOperation rows
    with ``parent_version_id`` stamped, and hand off to the
    orchestrator.

    Mirrors :func:`_create_new_base_model_run_via_orchestrator` but adds:
    - parent ``ModelVersion`` resolution (the run vibes an existing ECM,
      so a parent is mandatory),
    - parent-scope validation (must be ECM; MVM parents are rejected as
      a blocker on ``parent_version_id`` per the spec),
    - per-step ``RunOperation.parent_version_id`` stamping so the
      orchestrator threads the parent through every step's
      :class:`OperationContext`.
    """
    from .db_models import BusinessContext, RunOperation
    from .services.orchestrator import validate_dag_request
    from .services.orchestrator.validate import (
        parent_scope_blocker_for_intent,
    )

    intent_value = Intent.VIBE_NEW_ECM_MVM.value

    # Resolve the parent ModelVersion the run vibes from. Honour the
    # explicit ``version_id`` / ``parent_version_id`` first, then fall
    # back to the latest completed ECM on the business so the model-
    # version page can submit "vibe-new from latest ECM" without re-
    # resolving client-side. Reject MVM parents up-front via the
    # validator helper below.
    parent_id = data.version_id or data.parent_version_id
    parent_mv: Optional[ModelVersion] = None
    if parent_id:
        parent_mv = session.get(ModelVersion, parent_id)
    if parent_mv is None:
        # Fallback: latest completed ECM scope on this business.
        parent_mv = session.exec(
            select(ModelVersion)
            .where(
                ModelVersion.business_id == business_id,
                ModelVersion.status == "completed",
                ModelVersion.scope.in_(["", "ecm"]),
            )
            .order_by(ModelVersion.version.desc())
        ).first()

    parent_blocker = parent_scope_blocker_for_intent(intent_value, parent_mv)
    if parent_blocker is not None:
        raise HTTPException(
            status_code=400,
            detail={
                "blockers": [_issue_to_out(parent_blocker).model_dump()],
                "warnings": [],
            },
        )

    # Validate next-vibe selections against the parent ECM's structured agent
    # ``VibeInput`` rows (unknown ids → 400) and resolve them so RunNextVibeLink
    # rows can be persisted for audit below. Their text is not folded into the
    # instructions — the compiled inputs are the sole source.
    selected_next_vibes: list[NextVibeItem] = []
    if data.next_vibe_ids:
        selected_next_vibes = _validate_next_vibe_ids(
            session, parent_mv.id, data.next_vibe_ids
        )

    # Compile the selected Vibe Inputs into ``data.vibe_instructions`` so the
    # DAG factory bakes the doc into the leading ``vibe_iterate`` step's params
    # (and, by extension, the ``model_vibes`` widget the agent reads at
    # dispatch). Inputs ARE the instructions; next-vibe link rows are still
    # persisted below for the audit.
    _compile_inputs_into_instructions(session, parent_mv.id, data)

    # Sub-pull business context. The factory may consult it for
    # carry-keys; pass the most recent one.
    business_context = session.exec(
        select(BusinessContext)
        .where(BusinessContext.business_id == business_id)
        .order_by(BusinessContext.created_at.desc())
    ).first()

    result = validate_dag_request(
        data, business, business_context, agent_config
    )
    if result.blockers:
        raise HTTPException(
            status_code=400,
            detail={
                "blockers": [
                    _issue_to_out(i).model_dump() for i in result.blockers
                ],
                "warnings": [
                    _issue_to_out(i).model_dump() for i in result.warnings
                ],
            },
        )
    if result.dag is None:
        raise HTTPException(
            status_code=500,
            detail="DAG factory returned None without blockers",
        )

    sid = generate_session_id()
    sid_bigint = session_id_to_bigint(sid)

    # Snapshot the user-submitted form values for the audit trail.
    style = (data.cataloging_style or "One Catalog").strip() or "One Catalog"
    default_ecm_prefix = "ecm_" if style == "One Catalog" else ""
    default_mvm_prefix = "mvm_" if style == "One Catalog" else ""
    ecm_prefix = (
        data.ecm_schema_prefix
        if data.ecm_schema_prefix is not None
        else default_ecm_prefix
    )
    mvm_prefix = (
        data.mvm_schema_prefix
        if data.mvm_schema_prefix is not None
        else default_mvm_prefix
    )
    stored_params = {
        "intent": result.dag.intent,
        "cataloging_style": style,
        "deployment_catalog": resolve_run_target_catalog(data, agent_config),
        "ecm_schema_prefix": ecm_prefix,
        "mvm_schema_prefix": mvm_prefix,
        "schema_prefix": ecm_prefix,
        "parent_version_id": parent_mv.id,
        "input_ids": list(data.input_ids or []),
    }
    params_json_omit_deployment_catalog_for_multi_catalog(stored_params, style)

    run = Run(
        business_id=business_id,
        version_id=parent_mv.id,
        intent=result.dag.intent,
        status="pending",
        vibe_session_id=sid,
        vibe_session_id_bigint=sid_bigint,
        parameters_json=json.dumps(stored_params),
        # ``data.vibe_instructions`` was rewritten above to the compiled
        # Vibe Inputs doc; persist it so the audit trail reflects what the
        # agent saw.
        vibe_instructions_text=(data.vibe_instructions or ""),
        business_context_text=(data.business_context_text or "").strip(),
    )
    session.add(run)
    session.commit()
    session.refresh(run)

    # Persist next-vibe link rows for traceability. Links live regardless of
    # whether the downstream orchestrator dispatch succeeds, so the UI can
    # still surface which selections were intended for this attempt.
    for nv in selected_next_vibes:
        session.add(RunNextVibeLink(run_id=run.id, next_vibe_id=nv.id))
    # Vibe Inputs intended-selection audit (consume flips on success only).
    _persist_run_input_links(session, run.id, data.input_ids)
    if selected_next_vibes or data.input_ids:
        session.commit()

    # Pre-create RunOperation rows so we can stamp ``parent_version_id``
    # on each step. The orchestrator's resume guard sees these existing
    # rows and skips its own persistence step. ``parent_version_id`` is
    # only meaningful for the leading version-producing step (the
    # ``vibe_iterate`` row); the orchestrator overrides it on subsequent
    # steps via ``needs_version_from``.
    for i, step in enumerate(result.dag.steps):
        row = RunOperation(
            run_id=run.id,
            step_index=i,
            operation_name=step.name,
            params_json=json.dumps(step.params),
            skip_if=step.skip_if or "",
            status="pending",
            # Only the first step inherits from the user-supplied parent;
            # the orchestrator threads downstream steps via
            # ``needs_version_from`` when it advances each step.
            parent_version_id=parent_mv.id if i == 0 else None,
        )
        session.add(row)
    session.commit()

    try:
        tracker.orchestrator.start(run, result.dag, session)
        session.commit()
        session.refresh(run)
    except Exception as e:
        from .run_state_transitions import transition_run
        reason = f"Orchestrator failed to start: {e}"
        run.error_message = reason
        session.add(run)
        transition_run(session, run, target_status="failed", reason=reason)
        session.commit()
        session.refresh(run)
        return _build_run_out(run, ws, session)

    if run.status == "running":
        tracker.start_tracking(run.id)

    return _build_run_out(run, ws, session)


# --- Runs ---

# Map Intent → the agent-side operation string. Used by widget builders that
# still talk to the agent in its native vocabulary (`new base model`,
# `vibe modeling of version`, …). This is a presentation-layer translation
# only; the durable Run.intent column carries the orchestrator vocabulary.
_INTENT_TO_AGENT_OP: dict[str, str] = {
    Intent.NEW_BASE_MODEL.value: "new base model",
    Intent.VIBE_ITERATE.value: "vibe modeling of version",
    # ``vibe-new-ecm-mvm`` is multi-step: the first step is the agent's
    # vibe op (mirrors VIBE_ITERATE's translation). The downstream
    # ``shrink_to_mvm`` primitive translates separately when its widgets
    # are built — this mapping is the lead-step label for monitoring tags.
    Intent.VIBE_NEW_ECM_MVM.value: "vibe modeling of version",
    Intent.INSTALL.value: "install model",
    Intent.UNINSTALL.value: "uninstall model version",
    Intent.GENERATE_SAMPLES.value: "generate sample data",
    Intent.REVERT.value: "revert model version",
    Intent.IMPORT_FROM_VOLUME.value: "import model version",
}


def _issue_to_out(issue) -> IssueOut:
    """Adapter: orchestrator's :class:`Issue` dataclass → wire shape."""
    return IssueOut(
        field_path=issue.field_path,
        step_index=issue.step_index,
        message=issue.message,
        severity=issue.severity,
    )


# Non-terminal Run statuses. Used by ``GET /health`` so the deploy
# script (``scripts/dev/redeploy.sh``) can refuse to push a new build
# while runs are still active. Atomic-replace App containers can't hand
# off in-flight pollers cleanly, so the deploy-time guard is the right
# place to enforce "don't redeploy while runs are active" — the App
# itself no longer carries a runtime drain gate.
_IN_FLIGHT_STATUSES: tuple[str, ...] = ("pending", "running", "stale")


def _count_in_flight_runs(session) -> int:
    rows = session.exec(
        select(Run.id).where(Run.status.in_(_IN_FLIGHT_STATUSES))
    ).all()
    return len(rows)


@router.get("/health", response_model=HealthOut, operation_id="getHealth")
def get_health(session: Dependencies.Session):
    """Liveness + active-run count.

    ``in_flight_runs`` lets the deploy script (``scripts/dev/redeploy.sh``)
    refuse to push a new wheel while a run is active. The App no longer
    carries a runtime drain gate — atomic-replace App containers can't
    cleanly hand off in-flight pollers, so blocking new dispatches while
    a deploy is in flight is the deploy script's job, not the App's.
    """
    return HealthOut(ok=True, in_flight_runs=_count_in_flight_runs(session))


@router.post(
    "/businesses/{business_id}/runs/validate",
    response_model=ValidateRunOut,
    operation_id="validateRun",
)
def validate_run(
    business_id: str,
    data: RunIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
):
    """Live form-feedback for the New Run page (spec §2.4 + §2.4.1).

    Same body as ``POST /runs``; returns ``{warnings, blockers}`` from
    the same validator that gates the hard submit. Does NOT create a
    ``Run`` row, write to Lakebase, or launch a job — purely a pure
    function over the request + business + agent config.

    The UI calls this debounced (300ms or onBlur) so impossible field
    combinations surface inline next to the offending field. Submit
    stays disabled while blockers are present.
    """
    from .db_models import AgentConfig, Business, BusinessContext
    from .services.orchestrator import validate_dag_request

    intent_value = data.intent.value
    if not intent_value:
        # Unknown intent: surface as a single blocker so the form can
        # render it inline. Same shape as the validator emits.
        return ValidateRunOut(
            blockers=[
                IssueOut(
                    field_path="intent",
                    step_index=-1,
                    message=(
                        "Cannot validate request: intent is missing or "
                        "has no DAG factory wired yet."
                    ),
                    severity="blocker",
                )
            ]
        )

    business = session.get(Business, business_id)
    if not business:
        return ValidateRunOut(
            blockers=[
                IssueOut(
                    field_path="business_id",
                    step_index=-1,
                    message=f"Business {business_id!r} not found",
                    severity="blocker",
                )
            ]
        )

    business_context = session.exec(
        select(BusinessContext)
        .where(BusinessContext.business_id == business_id)
        .order_by(BusinessContext.created_at.desc())
    ).first()
    agent_config = session.exec(select(AgentConfig).limit(1)).first()

    # Pre-flight catalog-clash check fires FIRST (spec §F5 dev). If the
    # target catalog already contains user schemas under the run's
    # prefix(es), short-circuit the form feedback with the clash blocker
    # — running the rest of validate_dag_request behind that produces
    # generic "step N missing field X" noise that drowns out the actual
    # cause of the failure.
    clash_blockers = _check_target_catalog_clash(
        business_id, data, agent_config, session, ws,
    )
    if clash_blockers:
        return ValidateRunOut(warnings=[], blockers=clash_blockers)

    # Validate legacy selections + set ``data.vibe_instructions`` to the
    # compiled selected inputs BEFORE handing off to the DAG validator, so the
    # validate endpoint sees the same effective payload create does. Without
    # this the OperationStep param validator's ``vibe_instructions:
    # min_length=1`` would reject an empty textbox even when the user has
    # selected inputs that compile into a non-empty instruction doc.
    try:
        _resolve_and_link_legacy_selections(business_id, data, session)
    except HTTPException as exc:
        # Mirror the create endpoint's 400 shape so the form's error
        # plumbing handles validate + create rejections identically.
        raise exc

    result = validate_dag_request(
        data, business, business_context, agent_config
    )
    blockers = [_issue_to_out(i) for i in result.blockers]
    warnings = [_issue_to_out(i) for i in result.warnings]
    # Per-intent parent-scope gate (e.g. vibe-new-ecm-mvm requires an
    # ECM parent). The orchestrator validator is pure and has no DB
    # access, so the route handler resolves the parent ModelVersion and
    # runs the gate here. Symmetric with the create handler so the form
    # sees the same blocker set on both endpoints.
    parent_blocker = _resolve_parent_scope_blocker(business_id, data, session)
    if parent_blocker is not None:
        blockers.append(_issue_to_out(parent_blocker))
    # Symmetry with POST /api/runs: the create handler enforces a set of
    # pre-flight gates BEFORE it even reaches the orchestrator branch
    # (active-run lock, agent config required, metamodel catalog
    # configured, target catalog required for One Catalog mode). The
    # live form-validation endpoint MUST report the same gates as
    # blockers — otherwise the user gets "no blockers" from /validate
    # then a 400 from /runs (Phase 4.5 bug 1).
    preflight = _collect_run_preflight_blockers(business_id, data, agent_config, session, ws=ws, config=config)
    # Preflight may emit both blockers and (informational) warnings - e.g. the
    # run-target-override visibility notice. Route each to the matching bucket
    # so a warning never reads as a hard blocker on the form.
    blockers.extend(p for p in preflight if p.severity != "warning")
    warnings.extend(p for p in preflight if p.severity == "warning")
    return ValidateRunOut(warnings=warnings, blockers=blockers)


def _resolve_parent_scope_blocker(business_id: str, data: RunIn, session) -> Optional["Issue"]:
    """Resolve the request's parent ``ModelVersion`` and run the
    per-intent parent-scope gate (if any).

    Currently only ``vibe-new-ecm-mvm`` carries such a gate. Returns the
    blocker Issue (still in the orchestrator's ``Issue`` shape — the
    caller adapts to ``IssueOut``) or ``None`` if the parent is fine.
    Returns ``None`` for intents that don't have a parent-scope rule
    so the caller can append the result unconditionally.
    """
    from .services.orchestrator.validate import (
        parent_scope_blocker_for_intent,
    )

    intent_value = data.intent.value if data.intent is not None else ""
    if intent_value != Intent.VIBE_NEW_ECM_MVM.value:
        return None

    parent_mv = _resolve_iterate_parent_version(business_id, data, session)
    return parent_scope_blocker_for_intent(intent_value, parent_mv)


def _resolve_iterate_parent_version(
    business_id: str, data: RunIn, session
) -> Optional[ModelVersion]:
    """Resolve an iterate's parent ``ModelVersion`` the way the create handler
    does: explicit ``version_id`` / ``parent_version_id`` wins, else the latest
    completed ECM on the business. Single source of truth so the parent-scope
    gate and the parent-metamodel gate resolve identically.

    Distinct from :func:`_resolve_parent_model_version` (the orchestrator's
    any-scope latest-completed resolver that ignores ``parent_version_id``);
    this one is the ECM-parent resolver the vibe-new-ecm-mvm scope gate uses.
    """
    parent_id = data.version_id or data.parent_version_id
    parent_mv: Optional[ModelVersion] = None
    if parent_id:
        parent_mv = session.get(ModelVersion, parent_id)
    if parent_mv is None:
        parent_mv = session.exec(
            select(ModelVersion)
            .where(
                ModelVersion.business_id == business_id,
                ModelVersion.status == "completed",
                ModelVersion.scope.in_(["", "ecm"]),
            )
            .order_by(ModelVersion.version.desc())
        ).first()
    return parent_mv


def _resolve_business_context_override(
    business_id: str, data: RunIn, session
) -> tuple[str, str]:
    """Resolve the ``(business_context_path, business_description_override)``
    pair the LEGACY dispatch branch of ``create_run`` widgets with: inline
    text overrides the ``business_description`` widget, an explicit file path
    goes to the ``context_file`` widget, else fall back to the most recent
    completed base/iterate run's own context path so a re-run doesn't need to
    re-supply it.

    NOTE: the pre-submit description gate
    (:func:`business_description_blocker_for_intent`, called from
    :func:`_collect_run_preflight_blockers`) deliberately does NOT call this
    helper - it only honours ``data.business_context_text`` /
    ``data.business_context_path`` directly, not the last-completed-run
    fallback below. This is a conservative simplification, not a proven
    equivalence: a business whose only prior successful run relied on that
    fallback (description perpetually blank, always dispatched via an
    inherited context file) could see the gate block a resubmission the
    actual dispatch would still let through. Accepted for now because the
    gate errs toward over-blocking (an inline blocker the user can dismiss
    by re-typing the description) rather than under-blocking (a wasted
    minute of agent compute) - revisit if that edge case turns out to be
    common in practice.
    """
    business_context_path = data.business_context_path
    business_description_override = ""
    if data.business_context_text.strip():
        # Inline text: pass as business_description widget (the monolith
        # builds its full context from business_name + business_description
        # when no context_file is provided).
        business_description_override = data.business_context_text.strip()
    if not business_context_path:
        last_run = session.exec(
            select(Run)
            .where(
                Run.business_id == business_id,
                Run.status == "completed",
                Run.intent.in_([Intent.NEW_BASE_MODEL.value, Intent.VIBE_ITERATE.value]),
            )
            .order_by(Run.completed_at.desc())
        ).first()
        if last_run and last_run.parameters_json:
            try:
                prev_params = json.loads(last_run.parameters_json)
                business_context_path = prev_params.get("business_context", "") or prev_params.get("context_file", "")
            except (json.JSONDecodeError, TypeError):
                pass
    return business_context_path, business_description_override


# Intents whose run-create handlers compile selected inputs into
# ``data.vibe_instructions`` and validate ``next_vibe_ids`` before DAG
# validation. The validate endpoint mirrors the same step so its DAG-validator
# call sees the same effective payload create does (otherwise the form's live
# error panel rejects empty vibe_instructions when the user has selected inputs
# that compile into a non-empty doc).
_FEEDBACK_NEXT_VIBE_INTENTS = frozenset({
    Intent.VIBE_ITERATE.value,
    Intent.VIBE_NEW_ECM_MVM.value,
})


def _resolve_and_link_legacy_selections(business_id: str, data: RunIn, session) -> None:
    """Validate ``next_vibe_ids`` and set ``data.vibe_instructions`` to the
    compiled selected Vibe Inputs.

    The compiled inputs are the sole source of run instructions. Next-vibe IDs
    are validated here so stale clients get a clear 400 (their RunNextVibeLink
    audit rows are written at launch); their text is not folded into the
    instructions.

    Shared by the validate endpoint and the create branches so all apply the
    same transform before ``validate_dag_request``.

    Raises ``HTTPException(400)`` on:
      - next_vibe_ids that don't appear on the base version's parsed payload,
      - ``next_vibe_ids`` set without a resolvable base version.

    No-op for intents outside ``_FEEDBACK_NEXT_VIBE_INTENTS`` and for requests
    with no ``next_vibe_ids`` or ``input_ids``.
    """
    intent_value = data.intent.value if data.intent is not None else ""
    if intent_value not in _FEEDBACK_NEXT_VIBE_INTENTS:
        return
    if not data.next_vibe_ids and not data.input_ids:
        return

    # Validate next-vibe selections off the base ModelVersion (``version_id``
    # or ``parent_version_id``) so unknown IDs raise the same 400 create does.
    if data.next_vibe_ids:
        base_id = data.version_id or data.parent_version_id
        if not base_id:
            raise HTTPException(
                status_code=400,
                detail="next_vibe_ids require a base version_id",
            )
        _validate_next_vibe_ids(session, base_id, data.next_vibe_ids)

    # Set ``data.vibe_instructions`` to the compiled selected Vibe Inputs.
    base_id = data.version_id or data.parent_version_id
    _compile_inputs_into_instructions(session, base_id, data)


# Schemas that are not "user data" for clash-detection purposes:
# - ``information_schema`` / ``default``: UC-builtin
# - ``_metamodel``: the agent's own bookkeeping schema, present in every
#   deployment catalog the agent has ever touched. It survives uninstalls
#   on purpose.
# - ``_metrics``: the agent's metric-views layer; the agent recreates it
#   per run and its presence does not block a fresh new-base-model.
# Anything starting with ``_`` is also treated as agent/system bookkeeping —
# matches the agent's own ``_INTERNAL_SCHEMAS`` + leading-underscore
# convention in ``_early_clash_detection``.
_SYSTEM_SCHEMAS_DEFAULT_OK = frozenset({
    "information_schema", "default", "_metamodel", "_metrics",
})

# Intents that build new schemas under the deployment catalog and therefore
# need the pre-flight clash check. ``vibe-iterate`` is included because it
# can re-emit the parent's schemas at a new version int — which clashes if
# stale per-version schemas were left behind by a prior partial run.
_CLASH_CHECK_INTENTS = frozenset({
    Intent.NEW_BASE_MODEL.value,
    Intent.VIBE_NEW_ECM_MVM.value,
    Intent.VIBE_ITERATE.value,
})


def _resolve_clash_check_prefixes(data: RunIn) -> list[tuple[str, str]]:
    """Return the per-scope prefixes the run will write under, as
    ``[(field_path, prefix), ...]``.

    Defaults mirror ``orchestrator.dag_factories._unified``:

    - One Catalog → ``ecm_schema_prefix="ecm_"`` and
      ``mvm_schema_prefix="mvm_"`` when the user didn't override them.
    - Catalog per Division/Domain → both empty by default; per-scope
      catalog naming already isolates ECM from MVM.

    For ``vibe-iterate`` we additionally include ``schema_prefix`` (the
    legacy single-prefix field).

    Empty effective prefixes are filtered out — the check can't enumerate
    "every schema" without a prefix anchor (and the agent's own clash
    detection is the backstop for that case).
    """
    cataloging_style = (data.cataloging_style or "One Catalog").strip()
    intent_value = data.intent.value if data.intent is not None else ""

    out: list[tuple[str, str]] = []

    # ECM + MVM scopes (new-base-model and vibe-new-ecm-mvm). Use explicit
    # user value when supplied, else the cataloging-style default.
    if intent_value in (Intent.NEW_BASE_MODEL.value, Intent.VIBE_NEW_ECM_MVM.value):
        ecm_explicit = data.ecm_schema_prefix
        ecm_pref = (
            ecm_explicit
            if ecm_explicit is not None
            else ("ecm_" if cataloging_style == "One Catalog" else "")
        )
        mvm_explicit = data.mvm_schema_prefix
        mvm_pref = (
            mvm_explicit
            if mvm_explicit is not None
            else ("mvm_" if cataloging_style == "One Catalog" else "")
        )
        if ecm_pref:
            out.append(("ecm_schema_prefix", ecm_pref))
        if mvm_pref:
            out.append(("mvm_schema_prefix", mvm_pref))

        # Catalog-per-Division / Catalog-per-Domain: the per-scope ECM/MVM
        # prefixes are empty (catalogs themselves isolate scopes), so the
        # filter anchor is the user's ``catalog_prefix`` instead. Match the
        # agent's catalog-level enumeration in ``_early_clash_detection``.
        if cataloging_style != "One Catalog":
            cat_prefix = (data.catalog_prefix or "").strip()
            if cat_prefix:
                out.append(("catalog_prefix", cat_prefix))

    # vibe-iterate uses the legacy single ``schema_prefix`` (no per-scope
    # split for the simple branch).
    if intent_value == Intent.VIBE_ITERATE.value:
        single = (data.schema_prefix or "").strip()
        if single:
            out.append(("schema_prefix", single))

    return out


def _suggest_free_prefix(used_prefixes: set[str], base: str) -> str:
    """Suggest a free prefix derived from ``base`` (e.g. ``ecm_``) that
    doesn't collide with any of ``used_prefixes`` (lower-cased)."""
    used = {p.lower() for p in used_prefixes}
    base_l = base.lower()
    # Try base + "v2_", "v3_", … which the user can rename freely.
    for n in range(2, 100):
        candidate = f"{base_l}v{n}_"
        if candidate not in used:
            return candidate
    return f"{base_l}new_"


def _metamodel_owned_schemas(
    session: "Session",
    business_id: str,
    scope: str,
    target_catalog: str,
) -> tuple[set[str], bool]:
    """Return the set of schema names this business has previously
    deployed under ``scope``, plus a flag for "a prior install completed".

    Returns ``(owned_database_names, has_completed_install_in_catalog)``:

    - ``owned_database_names`` — lower-cased ``Domain.database_name``
      values across every ModelVersion for this business + scope. These
      are the explicit "we own this schema" records the model_sync layer
      mirrors from the agent's metamodel table.
    - ``has_completed_install_in_catalog`` — ``True`` if a completed Run
      row exists for this business whose ``parameters_json`` mentions the
      target catalog. Used as a fallback ownership signal when the
      Domain mirror is empty (model_sync lag) — without it, a partial
      mirror would false-block legitimate re-runs.

    A ModelVersion alone is NOT enough to claim ownership: the unified
    pipeline writes ModelVersion rows at job-launch time, and a
    cancelled/failed pipeline can leave behind a ModelVersion with no
    actual physical schemas. Tying the fallback to a completed Run row +
    catalog mention catches the real "we already deployed here" case
    while staying strict about hostile clashes.
    """
    from .db_models import Domain, Run

    if not business_id:
        return (set(), False)

    try:
        rows = session.exec(
            select(Domain.database_name)
            .join(ModelVersion, Domain.version_id == ModelVersion.id)
            .where(
                ModelVersion.business_id == business_id,
                ModelVersion.scope == scope,
            )
        ).all()

        completed_runs = session.exec(
            select(Run.parameters_json).where(
                Run.business_id == business_id,
                Run.status == "completed",
            )
        ).all()
    except Exception as exc:  # noqa: BLE001
        logger.warning(
            "Pre-flight catalog clash — metamodel lookup failed for "
            "business=%r scope=%r: %s",
            business_id, scope, exc,
        )
        return (set(), False)

    owned = {(r or "").lower() for r in rows if r}
    target_lower = target_catalog.lower() if target_catalog else ""
    has_completed = False
    if target_lower:
        for params_json in completed_runs:
            if not params_json:
                continue
            if target_lower in params_json.lower():
                has_completed = True
                break
    return (owned, has_completed)


# Intents whose dispatch reads/writes the agent's ``_metamodel`` schema
# under the target catalog. ``import-from-volume`` creates the schema
# implicitly via the sync step (no pre-existing requirement), and the
# stub intents are rejected upstream. Everything else uses _metamodel
# as the model.json / Delta-table root.
_METAMODEL_REQUIRED_INTENTS = frozenset({
    Intent.NEW_BASE_MODEL.value,
    Intent.VIBE_ITERATE.value,
    Intent.VIBE_NEW_ECM_MVM.value,
    Intent.INSTALL.value,
    Intent.UNINSTALL.value,
    Intent.GENERATE_SAMPLES.value,
    Intent.REVERT.value,
})


def _check_metamodel_schema_present(
    data: RunIn,
    agent_config: Optional["AgentConfig"],
    ws,
) -> Optional[IssueOut]:
    """Refuse to dispatch a run when the target catalog has no ``_metamodel``
    schema. The agent reads model.json from
    ``<catalog>/_metamodel/vol_root/business/<biz>/<scope>_v<N>/model.json``
    and writes Delta tables under ``<catalog>/_metamodel/{business,product,...}``;
    no schema → install crashes at dispatch with a less helpful error.

    Returns a single blocker (or ``None`` when the catalog is healthy /
    the check is skipped). The blocker points at ``field_path="catalog"``
    so the form highlights the catalog field, not a generic dispatch error.
    """
    if data.intent.value not in _METAMODEL_REQUIRED_INTENTS:
        return None
    target_catalog = resolve_run_target_catalog(data, agent_config)
    if not target_catalog:
        # Empty catalog name will be caught by the per-intent validator
        # downstream — no need to double-up.
        return None
    if ws is None:
        return None

    try:
        schemas = list(ws.schemas.list(catalog_name=target_catalog))
    except Exception:  # noqa: BLE001 — be lenient on auth/transient errors
        # The App SP may not have USE_CATALOG on the picked catalog (the
        # walkthrough's expected case is the SP DOES have it, but defending
        # against the unhappy path means the user still sees the agent's
        # error rather than a misleading "no _metamodel" message we can't
        # actually verify).
        return None

    names = {(getattr(s, "name", "") or "").strip() for s in schemas}
    # An empty / non-string-name result set means we couldn't actually
    # enumerate schemas (every real UC catalog has at least ``default``).
    # Skip silently — the agent will surface its own error if the schema
    # really is missing.
    if not any(names):
        return None
    if "_metamodel" in names:
        return None

    return IssueOut(
        field_path="catalog",
        step_index=-1,
        message=(
            f"Catalog '{target_catalog}' has no `_metamodel` schema. "
            "Run the installer's catalog setup (`install/grant_catalog.py`) "
            "or pick a different catalog. The agent writes model.json + "
            "Delta tables under `<catalog>/_metamodel/...`."
        ),
        severity="blocker",
    )


# Intents whose run reads its PARENT model from `_metamodel` at version
# resolution (the agent's `_version_exists` gate). A parent with zero
# `_metamodel.business` rows fails deep inside the run with a confusing
# "version does not exist"; the preflight turns that into an actionable
# blocker. Deliberately intent-only: NEW_BASE_MODEL has no parent;
# INSTALL/UNINSTALL/GENERATE_SAMPLES read model.json from the Volume, not the
# `_metamodel`-first version gate. REVERT is excluded - it dispatches
# uninstall→install lifecycle ops (a version-pointer move), not a
# model-producing agent run that resolves a parent via `_version_exists`.
_PARENT_METAMODEL_GATED_INTENTS = frozenset({
    Intent.VIBE_ITERATE.value,
    Intent.VIBE_NEW_ECM_MVM.value,
})


def _check_metamodel_parent_version_present(
    business_id: str,
    data: RunIn,
    agent_config: Optional["AgentConfig"],
    session: "Session",
    ws,
) -> Optional[IssueOut]:
    """Refuse to dispatch a parent-reading iterate when the parent version has
    no ``_metamodel.business`` rows.

    The agent resolves its parent model ONLY from
    ``<catalog>._metamodel.business`` on iterate / new-ecm-mvm runs; a version
    that was kickstarted/downloaded before seeding (or whose seed failed) has
    none, so the run would fail deep at version resolution. This is the
    belt-and-suspenders read-time gate on top of the write-time seed.

    Intent-only gate (``_PARENT_METAMODEL_GATED_INTENTS``). Lenient like
    ``_check_metamodel_schema_present``: an unconfigured warehouse/catalog or
    any query error returns ``None`` (no blocker) - only a SUCCESSFUL query
    returning zero rows blocks. ``field_path`` is NOT ``"business_id"`` so the
    create path maps it to a 400, not the active-run 409.
    """
    if data.intent is None or data.intent.value not in _PARENT_METAMODEL_GATED_INTENTS:
        return None
    if agent_config is None:
        return None
    # Concern A: the parent model's _metamodel lives at the installation
    # metamodel catalog, which is the passed agent_config singleton's value.
    # (Empty-default read, not a cross-concern fallback.)
    catalog = (agent_config.deployment_catalog or "").strip()
    if not catalog or ws is None:
        return None

    from .core._names import agent_business_segment, escape_sql_literal
    from .core._warehouse import get_warehouse_id
    from .db_models import Business

    warehouse_id = get_warehouse_id(session)
    if not warehouse_id:
        return None

    parent_mv = _resolve_iterate_parent_version(business_id, data, session)
    if parent_mv is None:
        # No parent to check - the intent's own parent requirement fires
        # elsewhere; this gate only speaks to a resolved-but-unseeded parent.
        return None

    business = session.get(Business, business_id)
    if business is None:
        return None
    seg = agent_business_segment(business.name)
    if not seg:
        return None

    sql = (
        f"SELECT COUNT(*) AS n FROM `{catalog}`.`_metamodel`.`business` "
        f"WHERE LOWER(business) = LOWER('{escape_sql_literal(seg)}') "
        f"AND version = '{escape_sql_literal(str(parent_mv.version))}'"
    )
    try:
        result = ws.statement_execution.execute_statement(
            statement=sql, warehouse_id=warehouse_id, wait_timeout="30s",
        )
        if result.status and result.status.error:
            return None  # lenient: surface the agent's own error, not ours
        rows = result.result.data_array if result.result else None
        if not rows:
            return None  # couldn't read a count - don't block
        count = int(rows[0][0])
    except Exception:  # noqa: BLE001 - auth/transient/parse: stay lenient
        return None

    if count > 0:
        return None

    return IssueOut(
        field_path="version_id",
        step_index=-1,
        message=(
            "This model version has no agent metamodel data, so it can't be "
            "iterated. Re-run the download/kickstart or re-sync the version, "
            "then try again."
        ),
        severity="blocker",
    )


def _check_target_catalog_clash(
    business_id: str,
    data: RunIn,
    agent_config: Optional["AgentConfig"],
    session: "Session",
    ws,
) -> list[IssueOut]:
    """Refuse to dispatch a run that would create new schemas where
    user-data schemas already live under the same prefix.

    Broadened over the original (PR #176) narrow check: the original only
    rejected when the user named the *exact* schemas the run was about to
    create; the agent's own ``_early_clash_detection`` (see
    ``modelling_agent/agent/dbx_vibe_modelling_agent.ipynb``) refuses on
    *any* schema under the configured prefix that doesn't have a matching
    metamodel record. Without parity, the user could submit a run that
    looks fine to the App and then aborts mid-flight with the agent's
    "PHYSICAL DEPLOYMENT CLASH DETECTED" error. Spec §F5 dev.

    Algorithm (matches the agent's heuristic branch):

    1. Resolve effective per-scope prefixes (``ecm_schema_prefix``,
       ``mvm_schema_prefix``, or legacy ``schema_prefix`` for vibe-iterate).
    2. Enumerate ``ws.schemas.list(catalog_name=target_catalog)``.
    3. Filter schemas matching the prefix, minus preserved bookkeeping
       schemas (``_metamodel``, ``_metrics``, ``default``,
       ``information_schema``, anything starting with ``_``).
    4. Subtract schemas that already match a stored ``Domain.database_name``
       for this business+scope+catalog (re-install of our own model).
    5. Anything remaining is a hostile clash → blocker.

    Returns a list of blockers (one per scope that clashes) — empty when
    the catalog is clean. Returning a list (vs. ``Optional``) lets the
    form surface ECM and MVM clashes side-by-side instead of staggering
    them across two submits.
    """
    intent_value = data.intent.value
    if intent_value not in _CLASH_CHECK_INTENTS:
        return []

    target_catalog = resolve_run_target_catalog(data, agent_config)
    if not target_catalog:
        return []
    if ws is None:
        return []

    prefixes = _resolve_clash_check_prefixes(data)

    try:
        schemas = list(ws.schemas.list(catalog_name=target_catalog))
    except Exception as exc:  # noqa: BLE001
        logger.warning(
            "Pre-flight catalog clash check skipped — could not list "
            "schemas in %r: %s",
            target_catalog,
            exc,
        )
        return []

    # Lower-case for case-insensitive matching (UC schemas are
    # case-insensitive identifiers).
    schema_names_lower = sorted({
        (s.name or "").lower()
        for s in schemas
        if s.name
    })

    # Bookkeeping schemas the agent owns — never user clashes.
    def _is_preserved(name: str) -> bool:
        if name in _SYSTEM_SCHEMAS_DEFAULT_OK:
            return True
        if name.startswith("_"):  # _metamodel, _metrics, etc.
            return True
        return False

    candidate_schemas = [n for n in schema_names_lower if not _is_preserved(n)]

    if not prefixes:
        # No anchor prefix to filter on. For One Catalog + new-base-model
        # this is unsafe IF the catalog already contains user schemas —
        # without a prefix the run's ECM/MVM schemas would land at the
        # catalog root and stomp on whatever's there (the bug that
        # motivated this gate). When the user explicitly overrode both
        # prefixes to empty AND the catalog is empty, we allow it (they
        # know what they're doing).
        cataloging_style_2 = (data.cataloging_style or "One Catalog").strip()
        if (
            intent_value in (Intent.NEW_BASE_MODEL.value, Intent.VIBE_NEW_ECM_MVM.value)
            and cataloging_style_2 == "One Catalog"
            and candidate_schemas
        ):
            sample = ", ".join(candidate_schemas[:5])
            more = "" if len(candidate_schemas) <= 5 else (
                f" (+{len(candidate_schemas) - 5} more)"
            )
            return [IssueOut(
                field_path="ecm_schema_prefix",
                step_index=-1,
                message=(
                    f"A schema prefix is required for One Catalog "
                    f"{intent_value} runs when the deployment catalog "
                    f"is non-empty. Target catalog {target_catalog!r} "
                    f"already contains {len(candidate_schemas)} user "
                    f"schema(s): {sample}{more}. Set "
                    "`ecm_schema_prefix` and `mvm_schema_prefix` (or "
                    "leave the defaults of `ecm_` / `mvm_`) to isolate "
                    "this run, or pick an empty deployment catalog."
                ),
                severity="blocker",
            )]
        # Other modes (Catalog per Division/Domain without `catalog_prefix`,
        # or vibe-iterate without a legacy prefix) — agent's own clash
        # detection is the backstop.
        return []

    issues: list[IssueOut] = []

    for field_path, prefix in prefixes:
        prefix_l = prefix.lower()
        matching = [n for n in candidate_schemas if n.startswith(prefix_l)]
        if not matching:
            continue

        # Determine scope label for metamodel lookup.
        if field_path == "ecm_schema_prefix":
            scope = "ecm"
        elif field_path == "mvm_schema_prefix":
            scope = "mvm"
        elif field_path == "catalog_prefix":
            # Catalog-per-Division/Domain enumerates catalogs by prefix
            # across BOTH scopes — accept either ECM or MVM as ownership
            # evidence.
            scope = None
        else:
            # Legacy single-prefix path — derive scope from the run's
            # ``data.scope`` if set, else treat as ECM (vibe-iterate).
            scope = (data.scope or "").strip().lower() or "ecm"

        if scope is None:
            ecm_owned, ecm_prior = _metamodel_owned_schemas(
                session, business_id, "ecm", target_catalog,
            )
            mvm_owned, mvm_prior = _metamodel_owned_schemas(
                session, business_id, "mvm", target_catalog,
            )
            registered = ecm_owned | mvm_owned
            has_prior_install = ecm_prior or mvm_prior
        else:
            registered, has_prior_install = _metamodel_owned_schemas(
                session, business_id, scope, target_catalog,
            )
        # If a prior ModelVersion exists for this business+scope and the
        # Domain mirror is empty (or partial), trust the prior install to
        # own any matching-prefix schemas. Only when the business has
        # never deployed this scope do we treat unregistered prefix-
        # matches as a hostile clash. This mirrors the agent's metamodel-
        # aware fast path while staying robust to mirror lag.
        if has_prior_install and not registered:
            continue
        unmatched = [n for n in matching if n not in registered]
        if not unmatched:
            continue

        sample = ", ".join(unmatched[:5])
        more = "" if len(unmatched) <= 5 else f" (+{len(unmatched) - 5} more)"
        # Suggest a free prefix to nudge the user toward isolation.
        used = {n.split("_", 1)[0] + "_" for n in candidate_schemas if "_" in n}
        suggestion = _suggest_free_prefix(used, prefix)

        issues.append(IssueOut(
            field_path=field_path,
            step_index=-1,
            message=(
                f"Target catalog {target_catalog!r} already contains "
                f"{len(unmatched)} schema(s) under prefix {prefix!r}: "
                f"{sample}{more}. A {intent_value} run would clash with "
                "them. To proceed, either:\n"
                f"  - change the schema prefix (e.g. {suggestion!r}),\n"
                "  - drop the existing schemas, or\n"
                "  - target a different deployment catalog."
            ),
            severity="blocker",
        ))

    return issues


def _collect_run_preflight_blockers(
    business_id: str,
    data: RunIn,
    agent_config: Optional["AgentConfig"],
    session: "Session",
    ws=None,
    create_path: bool = False,
    config=None,
) -> list[IssueOut]:
    """Gates that POST /api/runs enforces BEFORE the orchestrator branch.

    Returns blockers for whatever's missing. The validate endpoint folds
    these into its blocker list so live form-validation surfaces the same
    submit-time errors. The create endpoint converts them to HTTPException
    via ``_raise_run_preflight_blockers`` below.

    Config-missing gates (agent job, metamodel catalog, warehouse) go through
    the shared :func:`require_config` collect mode so run-shaped and
    non-run-shaped operations converge on one mechanism. The remaining gates
    are run-specific: the active-run lock, the One-Catalog effective-target
    check, the metamodel-schema-present probe, the parent-version probe, and
    the target-catalog-clash check.

    See router.create_run for the source-of-truth gating.
    """
    from .db_models import Business, Run
    from .routes._helpers import require_config
    from .services.orchestrator.validate import (
        business_description_blocker_for_intent,
        deployed_version_reinstall_warning,
    )

    blockers: list[IssueOut] = []

    # Active-run lock — POST /runs returns 409 if the business already has
    # a running/pending/stale run. Surface as a blocker too so the form
    # can show "wait for the in-flight run to finish".
    if business_id:
        active = session.exec(
            select(Run).where(
                Run.business_id == business_id,
                Run.status.in_(["pending", "running", "stale"]),
            )
        ).first()
        if active is not None:
            blockers.append(IssueOut(
                field_path="business_id",
                step_index=-1,
                message=f"Business already has an active run: {active.id}",
                severity="blocker",
            ))

    # Description gate: a model-producing intent (new-base-model,
    # vibe-iterate, vibe-new-ecm-mvm) dispatched with an empty business
    # description (and no rescuing override) fails ~1 minute into agent
    # compute with "Business description is required". Catch it here so
    # the run form blocks BEFORE dispatching the Databricks job. Independent
    # of the config gates below - an empty description is wrong regardless
    # of whether the agent job/catalog/warehouse are configured.
    if business_id:
        business = session.get(Business, business_id)
        if business is not None:
            intent_value = data.intent.value if data.intent is not None else ""
            description_blocker = business_description_blocker_for_intent(
                intent_value,
                business,
                business_context_text=data.business_context_text,
                business_context_path=data.business_context_path,
            )
            if description_blocker is not None:
                blockers.append(_issue_to_out(description_blocker))

    # Config gates: agent job + metamodel catalog + warehouse (NEW: warehouse
    # joins the list - progress polling and model-sync die without it). One
    # shared mechanism with the operation preflights.
    config_blockers = require_config(
        session, config, ["agent_job", "metamodel_catalog", "warehouse"],
        mode="collect",
    )
    blockers.extend(config_blockers)

    # Without a configured agent the ws/catalog-dependent gates below can't
    # run meaningfully - stop here (the agent-not-configured blocker is set).
    if agent_config is None or not (agent_config.notebook_path or "").strip():
        return blockers

    # One Catalog mode requires an effective target catalog (explicit form
    # catalog, else the configured metamodel catalog). A missing metamodel
    # catalog is already flagged above; this adds the catalog-field blocker.
    cataloging_style = (data.cataloging_style or "One Catalog").strip()
    if cataloging_style == "One Catalog" and not resolve_run_target_catalog(data, agent_config):
        blockers.append(IssueOut(
            field_path="catalog",
            step_index=-1,
            message=(
                "Deployment catalog is required when cataloging style "
                "is 'One Catalog' and no default metamodel catalog is "
                "configured. Pick a target catalog on the run form."
            ),
            severity="blocker",
        ))

    # Informational (never a blocker): a run whose target catalog differs from
    # the configured metamodel catalog lands its _metamodel + artifacts under
    # the override. The override is the agent's designed per-run _metamodel
    # selector, so this is a visibility notice, not an error.
    override = (data.catalog or "").strip()
    configured = (agent_config.deployment_catalog or "").strip()
    if override and configured and override != configured:
        blockers.append(IssueOut(
            field_path="catalog",
            step_index=-1,
            message=(
                f"This run's `_metamodel` and artifacts will live under "
                f"'{override}'; installation-wide sync and out-of-band "
                f"detection only watch the configured metamodel catalog "
                f"'{configured}'."
            ),
            severity="warning",
        ))

    # Deployed-version clash warning: an install run whose target
    # ModelVersion is already recorded ``deployment_status == "deployed"``
    # for this exact catalog will burn ~6 minutes of agent compute only to
    # be rejected by the agent's own clash guard. Non-blocking - re-install
    # after an out-of-band ``DROP SCHEMA``, or a stale reconcile/drift
    # read, are legitimate workflows this must not prevent.
    preflight_intent_value = data.intent.value if data.intent is not None else ""
    if preflight_intent_value == Intent.INSTALL.value:
        target_mv = _resolve_parent_model_version(business_id, data, Intent.INSTALL, session)
        deployed_warning = deployed_version_reinstall_warning(
            preflight_intent_value, target_mv, resolve_run_target_catalog(data, agent_config)
        )
        if deployed_warning is not None:
            blockers.append(_issue_to_out(deployed_warning))

    metamodel_blocker = _check_metamodel_schema_present(data, agent_config, ws)
    if metamodel_blocker is not None:
        blockers.append(metamodel_blocker)

    # Parent-metamodel gate: a COUNT(*) against the SQL warehouse is too heavy
    # for the per-keystroke validate path, and this is a rare safety net (once
    # seeding is correct it never fires), so run it on the CREATE path only.
    # The actionable message surfaces at submit rather than live.
    if create_path:
        parent_metamodel_blocker = _check_metamodel_parent_version_present(
            business_id, data, agent_config, session, ws
        )
        if parent_metamodel_blocker is not None:
            blockers.append(parent_metamodel_blocker)

    blockers.extend(_check_target_catalog_clash(business_id, data, agent_config, session, ws))

    return blockers


@router.get(
    "/businesses/{business_id}/runs/{run_id}/operations",
    response_model=list[RunOperationOut],
    operation_id="listRunOperations",
)
def list_run_operations(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """List the persisted DAG steps for a run (spec §5.2 + §8).

    The UI reads this to render the "what step are we on" pipeline on
    the run-detail page — augments / replaces the legacy progress
    pipeline once a run has at least one ``RunOperation`` row.

    Returns the rows ordered by ``step_index`` ascending.

    ``run_page_url`` is built per-phase from the phase's own
    ``databricks_run_id`` — each Phase dispatches its own job run, so
    the link belongs at the phase level, not the run level.
    """
    from .db_models import RunOperation
    from .routes._helpers import _build_dbx_run_url

    get_run_in_business(session, business_id, run_id)

    rows = session.exec(
        select(RunOperation)
        .where(RunOperation.run_id == run_id)
        .order_by(RunOperation.step_index)
    ).all()

    # Resolve natural-key (version, scope, business_id) for each
    # ``output_version_id`` in one batched lookup so the "→ v1 ECM"
    # affordance on the Phase row is human-meaningful + navigable
    # instead of a dead "#/model-versions/{uuid}" hash anchor (#49).
    version_ids = [r.output_version_id for r in rows if r.output_version_id]
    version_map: dict[str, ModelVersion] = {}
    if version_ids:
        mvs = session.exec(
            select(ModelVersion).where(ModelVersion.id.in_(version_ids))
        ).all()
        version_map = {mv.id: mv for mv in mvs}

    out: list[RunOperationOut] = []
    for r in rows:
        label: Optional[str] = None
        url: Optional[str] = None
        if r.output_version_id and r.output_version_id in version_map:
            mv = version_map[r.output_version_id]
            scope = (mv.scope or "").strip()
            scope_upper = scope.upper() if scope else ""
            label = f"v{mv.version} {scope_upper}".strip()
            # No ?tab=overview — let the route default to the overview
            # tab. Mirrors the canonical model-version URL used in
            # LineageCard / sidebar chips.
            url = f"/businesses/{mv.business_id}/model/{mv.version}/{scope}"
        out.append(
            RunOperationOut(
                id=r.id,
                run_id=r.run_id,
                step_index=r.step_index,
                operation_name=r.operation_name,
                status=r.status,
                databricks_run_id=r.databricks_run_id,
                run_page_url=_build_dbx_run_url(r.databricks_run_id, ws, session),
                parent_version_id=r.parent_version_id,
                output_version_id=r.output_version_id,
                output_version_label=label,
                output_version_url=url,
                error_message=r.error_message,
                started_at=r.started_at,
                completed_at=r.completed_at,
                created_at=r.created_at,
                dispatched_widgets=(
                    json.loads(r.dispatched_widgets_json)
                    if r.dispatched_widgets_json
                    else {}
                ),
            )
        )
    return out


@router.post(
    "/businesses/{business_id}/runs",
    response_model=RunOut,
    operation_id="createRun",
)
def create_run(
    business_id: str,
    data: RunIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    tracker: Dependencies.Tracker,
    _role: Dependencies.ModelerOnly,
):
    """Create a run record and trigger the Databricks job.

    Phase 4 (#29): runs whose ``intent == "new-base-model"`` are routed
    through :class:`Orchestrator.start` against the DAG produced by
    :func:`dag_for_new_base_model`. Other intents fall through to the
    legacy single-job launch until the simple/recovery wirers replace
    them.
    """
    from .db_models import Business
    from .services.orchestrator import (
        Orchestrator,
        validate_dag_request,
    )

    intent_value = data.intent.value

    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")

    # Per-business lock: reject if there's already an active run
    active_run = session.exec(
        select(Run).where(
            Run.business_id == business_id,
            Run.status.in_(["pending", "running", "stale"]),
        )
    ).first()
    if active_run:
        raise HTTPException(
            status_code=409,
            detail=f"Business already has an active run: {active_run.id}",
        )

    agent_config = _get_agent_config(session)
    # Run the same preflight-blocker checks the validate endpoint runs.
    # If any blocker fires, raise the first one as a 400 (the active-run
    # lock prefers 409). This keeps validate ↔ create symmetric — what
    # the form sees as a blocker is exactly what the submit will reject
    # on (Phase 4.5 bug 1).
    # Config-missing gates hard-fail with the SAME structured 422 config_missing
    # payload (per-key label + settings deep-link) the other operations emit, so
    # the FE renders one consistent "configure X in Settings" surface instead of
    # a bare 400 string. Runs through the shared require_config helper (raise
    # mode) BEFORE the run-specific gates below.
    from .routes._helpers import require_config
    require_config(
        session, config, ["agent_job", "metamodel_catalog", "warehouse"],
        mode="raise",
    )
    preflight = _collect_run_preflight_blockers(
        business_id, data, agent_config, session, ws=ws, create_path=True, config=config
    )
    # Only hard blockers reject the create; informational warnings (e.g. the
    # run-target-override visibility notice) surface via validate, never block.
    # Config-missing blockers were already raised as 422 above; what remains
    # here are the run-specific gates (active-run lock, schema-present, clash).
    hard_blockers = [p for p in preflight if p.severity != "warning"]
    if hard_blockers:
        first = hard_blockers[0]
        # Active-run lock keeps its 409 status code for backwards
        # compatibility with the existing UI that handles 409 specially.
        status_code = 409 if first.field_path == "business_id" else 400
        raise HTTPException(status_code=status_code, detail=first.message)
    # One Catalog target falls back to the agent's metamodel catalog when
    # the user didn't pick a target on the form. Preflight already
    # emitted a blocker if both are empty; this branch only runs when
    # the agent catalog is set.
    cataloging_style = (data.cataloging_style or "One Catalog").strip()
    if cataloging_style == "One Catalog" and not (data.catalog or "").strip():
        data.catalog = resolve_run_target_catalog(data, agent_config)
    # Hard gate: refuse to launch a job if the app SP can no longer reach the
    # configured notebook. This catches the case where the SP lost read access
    # between save time and run time (e.g. the notebook was moved or had its
    # permissions tightened), which would otherwise fail with a cryptic
    # Databricks Jobs error the tracker surfaces after the fact.
    _preflight_notebook_access(ws, agent_config.notebook_path)

    # ------------------------------------------------------------------
    # Orchestrator branches.
    #
    # 1. The unified ``new-base-model`` intent builds a multi-step DAG via
    #    :func:`validate_dag_request` and is dispatched via
    #    :func:`_create_new_base_model_run_via_orchestrator`.
    # 2. The four simple intents — vibe-iterate, install, uninstall,
    #    generate-samples — build single-step DAGs via per-intent
    #    factories and go through :func:`_create_run_via_orchestrator`
    #    with a resolved parent ``ModelVersion``.
    # ------------------------------------------------------------------

    # ----- Unified new-base-model branch (group C) -----------------------
    if intent_value == Intent.NEW_BASE_MODEL.value:
        return _create_new_base_model_run_via_orchestrator(
            business_id=business_id,
            data=data,
            business=business,
            agent_config=agent_config,
            session=session,
            ws=ws,
            tracker=tracker,
        )

    # ----- Vibe-new-ECM-MVM branch (internal authoring helper) -----------
    # Same DAG shape as ``new-base-model`` but seeded from a parent ECM via
    # ``vibe_iterate``. Routes through a dedicated handler so the parent
    # ModelVersion can be resolved + scope-validated before the
    # orchestrator dispatches.
    if intent_value == Intent.VIBE_NEW_ECM_MVM.value:
        return _create_vibe_new_ecm_mvm_run_via_orchestrator(
            business_id=business_id,
            data=data,
            business=business,
            agent_config=agent_config,
            session=session,
            ws=ws,
            tracker=tracker,
        )

    # ----- Simple-intent branch (group A/B) ------------------------------
    # Transitional fallback: only route through the orchestrator when we
    # can resolve a parent ``ModelVersion`` (the four simple intents all
    # operate on a specific version). When neither ``data.version_id`` nor
    # a fallback completed version is available we fall through to the
    # legacy branch below — that path remains the only one exercised by
    # tests + flows that pre-date the Phase 4 contract narrowing. New
    # callers that supply a ``version_id`` get the orchestrator path
    # immediately.
    intent = _resolve_orchestrator_intent(data)
    if (
        intent is not None
        and _orchestrator_intent_registered(intent)
        # Legacy next_vibe_id validation + link persistence is owned by the
        # create branch below: it has its own 400-mapping ("nv-999 not found")
        # and writes the RunNextVibeLink audit rows; the orchestrator's
        # vibe_iterate factory doesn't thread these through. Falling through
        # here keeps that contract intact while leaving the orchestrator
        # surface for the simple "fresh form submit" path the new UI uses.
        and not data.next_vibe_ids
    ):
        parent_mv = _resolve_parent_model_version(business_id, data, intent, session)
        if parent_mv is not None:
            return _create_run_via_orchestrator(
                business_id=business_id,
                data=data,
                business=business,
                agent_config=agent_config,
                intent=intent,
                parent_mv=parent_mv,
                session=session,
                ws=ws,
                tracker=tracker,
            )

    business_context_path, business_description_override = (
        _resolve_business_context_override(business_id, data, session)
    )

    # Resolve the ModelVersion this run operates on. The agent's
    # `model_version` widget (human-facing integer like "1" / "2") tells
    # it which model.json to load off Volumes — missing that widget value
    # causes the agent to abort with "Configuration invalid". Vibe runs
    # always have a base version; install / uninstall / generate samples
    # runs also operate on a specific version now that they're launched
    # from the model-version view. For base-model runs version_id stays
    # None until the run completes.
    version_id = data.version_id
    base_version_int: Optional[int] = None
    _VERSION_BOUND_INTENTS = {
        Intent.VIBE_ITERATE.value,
        Intent.INSTALL.value,
        Intent.UNINSTALL.value,
        Intent.GENERATE_SAMPLES.value,
    }
    if intent_value in _VERSION_BOUND_INTENTS:
        base_mv = None
        if version_id:
            base_mv = session.get(ModelVersion, version_id)
        if not base_mv:
            base_mv = session.exec(
                select(ModelVersion)
                .where(
                    ModelVersion.business_id == business_id,
                    ModelVersion.status == "completed",
                )
                .order_by(ModelVersion.version.desc())
            ).first()
        if base_mv:
            version_id = base_mv.id
            base_version_int = base_mv.version
        else:
            # No matching ModelVersion → cannot derive the agent's
            # ``model_version`` widget. Dispatching anyway would silently
            # drop the widget and the agent's notebook validator would
            # kill the run pre-progress (see uninstall-diagnosis
            # 2026-05-18). 4xx loudly here so the caller can fall back to
            # the orphan-schema workaround / SQL-direct path.
            raise HTTPException(
                status_code=422,
                detail=(
                    f"Could not resolve a target ModelVersion for intent "
                    f"{intent_value!r}. Pass `version_id` explicitly, or run "
                    "new-base-model first. If the deployment catalog holds "
                    "orphan schemas with no matching Lakebase row, drop them "
                    "via SQL (`DROP SCHEMA <catalog>.<schema> CASCADE`) — "
                    "an in-app 'uninstall orphan schemas' flow is on the "
                    "roadmap."
                ),
            )

    # Generate session ID
    sid = generate_session_id()
    sid_bigint = session_id_to_bigint(sid)

    # Map parameters to widget values, passing any convention overrides
    _convention_fields = [
        "naming_convention", "primary_key_suffix", "schema_prefix", "schema_suffix",
        "tag_prefix", "tag_suffix", "table_id_type", "boolean_format", "date_format",
        "timestamp_format", "cataloging_style", "catalog_prefix", "catalog_suffix",
        "org_divisions", "business_domains", "classification_levels",
        "housekeeping_columns", "history_tracking_columns",
    ]
    convention_overrides = {
        f: getattr(data, f) for f in _convention_fields if getattr(data, f) is not None
    }

    # Resolve agent-proposed next-vibe selections off the base version's
    # structured agent ``VibeInput`` rows. RunNextVibeLink rows are persisted
    # after the run row exists (below) for traceability — they now store
    # ``VibeInput.id`` uuids for new runs.
    selected_next_vibes: list[NextVibeItem] = []
    if data.next_vibe_ids:
        if not version_id:
            raise HTTPException(
                status_code=400,
                detail="next_vibe_ids require a base version_id",
            )
        selected_next_vibes = _validate_next_vibe_ids(
            session, version_id, data.next_vibe_ids
        )

    # Compile the selected Vibe Inputs into the instruction doc. No-op (so the
    # first-model description-mode path is untouched) when there are no inputs
    # or no version to anchor them to.
    _compile_inputs_into_instructions(session, version_id, data)
    vibe_instructions = data.vibe_instructions

    # Vibe files live under the run's _metamodel/vol_root, so the upload target
    # is the run's target catalog (explicit form catalog, else the configured
    # metamodel catalog) - the same value the run dispatches with.
    upload_catalog = resolve_run_target_catalog(data, agent_config)

    # New-base-model is the unified ECM → shrink-to-MVM pipeline. Force
    # "large model" here regardless of what the client sent so the
    # orchestrator's DAG sees a consistent input.
    effective_model_size = (
        "large model"
        if intent_value == Intent.NEW_BASE_MODEL.value
        else data.model_size
    )

    agent_op = _INTENT_TO_AGENT_OP.get(intent_value, "new base model")
    widgets = map_run_params_to_widgets(
        operation=agent_op,
        business=business,
        catalog=data.catalog,
        session_id=sid,
        vibe_instructions=vibe_instructions,
        model_size=effective_model_size,
        generate_samples=data.generate_samples,
        business_context_path=business_context_path,
        business_description_override=business_description_override,
        model_version=str(base_version_int) if base_version_int is not None else "",
        **convention_overrides,
    )

    try:
        widgets = finalize_widgets_or_raise(
            ws,
            widgets,
            catalog=upload_catalog,
            business_name=business.name,
            session_id=sid,
            raw_vibes=vibe_instructions,
        )
    except WidgetPayloadTooLargeError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception:
        raise HTTPException(
            status_code=502,
            detail=(
                "Could not stage vibe instructions on the target Volume. "
                "Confirm the app's service principal has WRITE FILES on "
                f"`{upload_catalog}._metamodel.vol_root`."
            ),
        )
    vibe_instructions_volume_path = (
        widgets.get("model_vibes", "")
        if widgets.get("model_vibes", "").startswith("/")
        else ""
    )

    stored_params = dict(widgets)
    params_json_omit_deployment_catalog_for_multi_catalog(
        stored_params, data.cataloging_style
    )

    run = Run(
        business_id=business_id,
        version_id=version_id,
        intent=intent_value,
        status="pending",
        vibe_session_id=sid,
        vibe_session_id_bigint=sid_bigint,
        parameters_json=json.dumps(stored_params),
        vibe_instructions_text=vibe_instructions,
        vibe_instructions_volume_path=vibe_instructions_volume_path,
        business_context_text=(data.business_context_text or "").strip(),
    )
    session.add(run)
    session.commit()
    session.refresh(run)

    # Persist RunNextVibeLink rows for traceability, regardless of whether the
    # job launch succeeds below. If the launch fails, we'll still know which
    # selections were intended for this attempt.
    for nv in selected_next_vibes:
        session.add(RunNextVibeLink(run_id=run.id, next_vibe_id=nv.id))
    # Vibe Inputs intended-selection audit (consume flips on success only).
    _persist_run_input_links(session, run.id, data.input_ids)
    if selected_next_vibes or data.input_ids:
        session.commit()

    # Build per-run job tags for monitoring
    job_tags = build_job_tags(
        business_name=business.name,
        model_scope=widgets.get("data_model_scopes", ""),
        version=widgets.get("model_version", "1"),
        operation=agent_op,
        notebook_path=agent_config.notebook_path,
        session_id=sid,
        collect_statistics=agent_config.collect_vibe_run_statistics,
    )

    # Launch the job
    try:
        dbx_run_id = launch_run(
            ws,
            agent_config.job_id,
            widgets,
            job_tags=job_tags,
            warehouse_id=resolve_warehouse_id(session, config),
            progress_migrate_strategy=config.progress_migrate_strategy,
        )
        run.databricks_run_id = dbx_run_id
        run.status = "running"
        run.started_at = datetime.now(timezone.utc)
        # Baseline message so the UI doesn't show "Waiting for updates" during
        # the gap between job launch and the tracker's first successful read
        # of the agent's session row.
        run.progress_message = "Starting — waiting for agent to report progress"
    except Exception as e:
        # Wiring audit (router legacy launch failure):
        #   Previous: direct run.status write (no completed_at!).
        #   New: transition_run stamps all five layers atomically.
        from .run_state_transitions import transition_run
        reason = f"Failed to trigger job: {str(e)}"
        run.error_message = reason
        session.add(run)
        transition_run(session, run, target_status="failed", reason=reason)

    session.add(run)
    session.commit()
    session.refresh(run)

    # Start async progress tracking
    if run.status == "running":
        tracker.start_tracking(run.id)

    return _build_run_out(run, ws, session)

@router.get(
    "/businesses/{business_id}/runs/{run_id}",
    response_model=RunOut,
    operation_id="getRun",
)
def get_run(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Get run status. Progress is already mirrored to Lakebase by the tracker."""
    run = get_run_in_business(session, business_id, run_id)
    return _build_run_out(run, ws, session)


_SOURCE_LINK_INTENTS = {
    Intent.VIBE_ITERATE.value,
    Intent.VIBE_NEW_ECM_MVM.value,
}
_OPERATES_ON_INTENTS = {
    Intent.INSTALL.value,
    Intent.UNINSTALL.value,
    Intent.GENERATE_SAMPLES.value,
    Intent.REVERT.value,
    Intent.IMPORT_FROM_VOLUME.value,
}
_MODEL_PRODUCING_INTENTS = {
    Intent.NEW_BASE_MODEL.value,
    Intent.VIBE_ITERATE.value,
    Intent.VIBE_NEW_ECM_MVM.value,
}


def _version_lineage_out(mv: Optional[ModelVersion]) -> Optional[RunLineageVersionOut]:
    if mv is None:
        return None
    return RunLineageVersionOut(
        id=mv.id,
        version=mv.version,
        scope=mv.scope or "",
        status=mv.status,
        deployment_status=mv.deployment_status,
    )


@router.get(
    "/businesses/{business_id}/runs/{run_id}/lineage",
    response_model=RunLineageOut,
    operation_id="getRunLineage",
)
def get_run_lineage(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
):
    """Return the source / generated / operates-on version links for a run.

    - source_version: BASE this run branched from (vibe/shrink/enlarge).
    - generated_version: version this run produced (model-producing ops).
    - operates_on_version: target of install/uninstall/samples/revert/import.

    For model-producing ops, `version_id` on the Run points at the OUTPUT
    once the run completes; before that it points at the BASE for vibe /
    shrink / enlarge runs (set at launch time). We disambiguate by
    checking `ModelVersion.base_version_id`: if Run.version_id.base_version_id
    is set, Run.version_id IS the output and its base is the source.
    """
    run = get_run_in_business(session, business_id, run_id)

    out = RunLineageOut(
        run_id=run.id,
        intent=run.intent or "",
        business_id=run.business_id,
    )

    target_mv = session.get(ModelVersion, run.version_id) if run.version_id else None

    intent_value = run.intent or ""
    if intent_value in _OPERATES_ON_INTENTS:
        out.operates_on_version = _version_lineage_out(target_mv)
        return out

    if intent_value in _MODEL_PRODUCING_INTENTS and target_mv is not None:
        if intent_value == Intent.NEW_BASE_MODEL.value:
            out.generated_version = _version_lineage_out(target_mv)
            return out

        # For vibe / shrink / enlarge: Run.version_id is overloaded.
        # At launch time it points at the BASE the user picked; once the
        # run completes successfully, model_sync updates it to point at
        # the freshly-produced OUTPUT. Disambiguate on Run.status:
        #
        #   - run.status != "completed"  → version_id is the SOURCE
        #     (running, pending, failed, cancelled — the run never
        #     advanced past launch, or produced no output)
        #   - run.status == "completed"  → version_id is the OUTPUT
        #
        # Without this, an in-flight vibe-iterate that picked v=1 MVM
        # (which itself has base_version_id pointing to v=1 ECM from
        # the earlier shrink) was rendered as
        #   "Source: v=1 ECM, Generated: v=1 MVM"
        # — both wrong: v=1 MVM is the SOURCE, the output doesn't exist
        # yet.
        is_completed = run.status == "completed"
        if not is_completed:
            out.source_version = _version_lineage_out(target_mv)
            return out

        if target_mv.base_version_id:
            out.generated_version = _version_lineage_out(target_mv)
            base_mv = session.get(ModelVersion, target_mv.base_version_id)
            out.source_version = _version_lineage_out(base_mv)
            return out

        out.source_version = _version_lineage_out(target_mv)
        child = session.exec(
            select(ModelVersion)
            .where(ModelVersion.base_version_id == target_mv.id)
            .order_by(ModelVersion.version.desc())
        ).first()
        out.generated_version = _version_lineage_out(child)
        return out

    return out

@router.get(
    "/businesses/{business_id}/runs",
    response_model=list[RunListOut],
    operation_id="listRuns",
)
def list_runs(business_id: str, session: Dependencies.Session):
    runs = session.exec(
        select(Run)
        .where(Run.business_id == business_id)
        .order_by(Run.created_at.desc())
    ).all()
    return [
        RunListOut(
            id=r.id, business_id=r.business_id,
            intent=r.intent or "",
            status=r.status, progress_percent=r.progress_percent,
            started_at=r.started_at, completed_at=r.completed_at,
            created_at=r.created_at,
        )
        for r in runs
    ]

@router.get(
    "/model-versions/{version_id}/runs",
    response_model=list[RunListOut],
    operation_id="listRunsForVersion",
)
def list_runs_for_version(version_id: str, session: Dependencies.Session):
    """List runs that directly produced or were submitted against this version.

    Does not include runs that produced descendants — those are linked from the
    descendants' own pages.

    A run is "directly involved" if either:
      - ``Run.version_id == version_id`` (generated-for / operates-on / submitted-against), or
      - the run produced this version via a ``RunOperation`` whose
        ``output_version_id == version_id`` (covers cases where the run's own
        ``version_id`` points at the parent or is null at dispatch time).
    """
    mv = session.get(ModelVersion, version_id)
    if not mv:
        raise HTTPException(status_code=404, detail="Model version not found")

    from sqlalchemy import or_

    producing_run_ids_subq = (
        select(RunOperation.run_id)
        .where(RunOperation.output_version_id == version_id)
    )

    runs = session.exec(
        select(Run)
        .where(
            Run.business_id == mv.business_id,
            or_(
                Run.version_id == version_id,
                Run.id.in_(producing_run_ids_subq),
            ),
        )
        .order_by(Run.created_at.desc())
    ).all()
    return [
        RunListOut(
            id=r.id, business_id=r.business_id,
            intent=r.intent or "",
            status=r.status, progress_percent=r.progress_percent,
            started_at=r.started_at, completed_at=r.completed_at,
            created_at=r.created_at,
        )
        for r in runs
    ]

@router.get(
    "/businesses/{business_id}/runs/{run_id}/progress",
    response_model=list[ProgressEventOut],
    operation_id="getRunProgress",
)
def get_run_progress(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    since_step_id: int = 0,
):
    """Get progress events for a run, optionally filtered by step_id."""
    get_run_in_business(session, business_id, run_id)
    events = session.exec(
        select(RunProgressEvent)
        .where(
            RunProgressEvent.run_id == run_id,
            RunProgressEvent.step_id > since_step_id,
        )
        .order_by(RunProgressEvent.created_at.asc(), RunProgressEvent.event_seq.asc())
    ).all()
    return events

@router.post(
    "/businesses/{business_id}/runs/{run_id}/cancel",
    response_model=RunOut,
    operation_id="cancelRun",
)
def cancel_run(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    tracker: Dependencies.Tracker,
    _role: Dependencies.ModelerOnly,
):
    """Cancel a running job.

    Wiring audit
    ------------
    **Intent**: cancel endpoint that atomically closes all dependent layers.

    **Previous wiring**: wrote ``run.status`` and ``run.completed_at`` directly
    via ``ws.jobs.cancel_run``; left RunOperation rows, ``progress_message``,
    and the Databricks job partially dealt with.

    **New wiring**: delegates ALL terminal state changes to
    ``transition_run(..., target_status="cancelled", ws=ws)``.  The helper
    stamps Run.status, Run.completed_at, every in-flight RunOperation, the
    progress_message, and best-effort cancels the Databricks job.

    **Info-flow delta**:
    + RunOperation rows now reach ``"cancelled"`` status.
    + ``progress_message`` is replaced with a non-RUNNING string.
    + Databricks job cancel is now inside the helper (was inline here before;
      the helper issues it best-effort so HTTP 500 is no longer raised on
      cancel API failure — the message notes the failure instead).

    **Dead-end check**: ``tracker.stop_tracking`` is still called here before
    the helper so the poll loop exits before we stamp the terminal status.
    """
    from .run_state_transitions import transition_run

    run = get_run_in_business(session, business_id, run_id)
    if run.status not in ("running", "stale"):
        raise HTTPException(status_code=400, detail=f"Cannot cancel run in '{run.status}' state")
    tracker.stop_tracking(run_id)

    # Atomically close all layers (RunOperation rows, progress_message,
    # completed_at, best-effort Databricks cancel).
    transition_run(session, run, target_status="cancelled", ws=ws)

    session.commit()
    session.refresh(run)
    return _build_run_out(run, ws, session)


@router.post(
    "/businesses/{business_id}/runs/{run_id}/cancel-with-rollback",
    response_model=CancelWithRollbackOut,
    operation_id="cancelRunWithRollback",
)
def cancel_run_with_rollback(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    tracker: Dependencies.Tracker,
    _role: Dependencies.ModelerOnly,
):
    """Cancel a running run AND roll back any partial state recorded
    by the orchestrator.

    Safety:
      * Refuses if the current phase's Databricks job has already
        terminated with SUCCESS — ripping apart a valid install would
        be a data-loss bug.
      * First stops the agent job via ``ws.jobs.cancel_run`` (same as the
        plain cancel endpoint), then replays each
        :meth:`Operation.rollback` in REVERSE step order.
      * Each reverse-op is guarded try/except. First failure marks the
        run ``rolled_back_failed``, records the failing step in
        ``error_message``, and stops — subsequent ops are NOT attempted
        so the operator can triage the residual state.

    Returns ``{ok, status, ops_applied, op_failures}``.
    """
    run = get_run_in_business(session, business_id, run_id)
    if run.status not in ("running", "stale"):
        raise HTTPException(
            status_code=400,
            detail=f"Cannot cancel-with-rollback a run in '{run.status}' state",
        )

    tracker.stop_tracking(run_id)
    result = tracker.orchestrator.cancel_with_rollback(run, session, ws=ws)

    # Safety-gate refusal: orchestrator returns ok=False AND leaves the
    # run untouched (final_run_status is the unchanged input status,
    # not "cancelled" or "rolled_back_failed"). Map this to 409 — the
    # caller asked to cancel a job whose Databricks run already
    # TERMINATED with SUCCESS; ripping apart that install would be a
    # data-loss bug.
    if not result.ok and result.final_run_status not in (
        "cancelled",
        "rolled_back_failed",
    ):
        detail = (
            result.op_failures[0].get("error", "Cancel-with-rollback refused")
            if result.op_failures
            else "Cancel-with-rollback refused"
        )
        raise HTTPException(status_code=409, detail=detail)

    session.commit()
    session.refresh(run)
    return CancelWithRollbackOut(
        ok=result.ok,
        status=result.final_run_status,
        ops_applied=[
            CancelOpAppliedOut(operation_name=n, kind=n)
            for n in result.ops_rolled_back
        ],
        op_failures=[
            CancelOpFailureOut(
                op=f.get("op", {}) if isinstance(f, dict) else {},
                error=(f.get("error", "") if isinstance(f, dict) else str(f)),
            )
            for f in result.op_failures
        ],
    )


def _resume_run_impl(
    business_id: str,
    run_id: str,
    session,
    tracker,
) -> ResumeRunOut:
    """Re-enter the orchestrator at the failed step (spec §6.4)."""
    run = get_run_in_business(session, business_id, run_id)
    if run.status not in ("failed", "cancelled", "stale", "rolled_back_failed"):
        raise HTTPException(
            status_code=400,
            detail=(
                f"Run is in '{run.status}' state; resume only applies to "
                "failed / cancelled / stale / rolled_back_failed runs"
            ),
        )
    tracker.orchestrator.resume(run, session)
    session.commit()
    session.refresh(run)
    if run.status == "running":
        tracker.start_tracking(run.id)
    return ResumeRunOut(
        ok=True,
        status=run.status,
        next_phase="",
        databricks_run_id=run.databricks_run_id,
    )


@router.post(
    "/businesses/{business_id}/runs/{run_id}/resume",
    response_model=ResumeRunOut,
    operation_id="resumeRun",
)
def resume_run(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    tracker: Dependencies.Tracker,
    _role: Dependencies.AdminOnly,
):
    """Resume an orchestrator-managed run from its failed step (spec §6.4)."""
    return _resume_run_impl(business_id, run_id, session, tracker)


@router.delete(
    "/businesses/{business_id}/runs/{run_id}",
    response_model=dict,
    operation_id="deleteRun",
)
def delete_run(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    _role: Dependencies.AdminOnly,
):
    """Delete a run and all its dependents. Only allowed on terminal runs
    (completed / failed / cancelled) to avoid racing the poll loop.

    Progress events, artifacts, operations, next-vibe links, input links, and
    element-lineage rows all die via ``run_id`` ON DELETE CASCADE."""
    run = get_run_in_business(session, business_id, run_id)
    if run.status not in ("completed", "failed", "cancelled"):
        raise HTTPException(
            status_code=400,
            detail=f"Cannot delete run in '{run.status}' state; cancel it first.",
        )

    session.delete(run)
    session.commit()
    return {
        "ok": True,
        "deleted_run_id": run_id,
    }


@router.post(
    "/businesses/{business_id}/runs/{run_id}/retry",
    response_model=RunOut,
    operation_id="retryRun",
)
def retry_run(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    tracker: Dependencies.Tracker,
    _role: Dependencies.ModelerOnly,
):
    """Retry a failed or cancelled run with a new session ID.

    Orchestrator-managed runs (those with persisted ``RunOperation`` rows)
    are retried through ``Orchestrator.resume``, the same re-dispatch
    machinery the admin ``/resume`` endpoint uses. Each operation's own
    ``dispatch()`` rebuilds its notebook_params from its typed params
    model (via ``map_run_params_to_widgets``) and mints a fresh session
    id itself, so this reuses the SAME flattening the original launch
    used. It deliberately does NOT replay ``Run.parameters_json``
    against ``launch_run`` for these runs: per the 0.6.6 run-config
    disclosure work, ``parameters_json`` for orchestrator-managed runs
    is a structured audit record (may hold lists / booleans / nested
    values, e.g. ``input_ids`` or a full request-body snapshot), not
    the flat map of STRING values the Databricks Jobs `run_now` API
    requires for `notebook_params`. Passing it straight through 500s
    with "Expected Scalar value for String field \"value\"".

    Runs with no ``RunOperation`` rows went through the legacy
    single-job launch path, where ``parameters_json`` IS the flat
    widget map used at launch (see ``create_run``'s
    ``stored_params = dict(widgets)``). Those remain safe to replay
    directly below.
    """
    run = get_run_in_business(session, business_id, run_id)
    if run.status not in ("failed", "cancelled"):
        raise HTTPException(status_code=400, detail=f"Cannot retry run in '{run.status}' state")

    has_orchestrator_ops = session.exec(
        select(RunOperation.id).where(RunOperation.run_id == run.id)
    ).first() is not None
    if has_orchestrator_ops:
        # A preceding *failure* deletes this run's RunInputLink rows
        # (re-pool contract; a cancellation does not). Re-establish them
        # from the recorded ``input_ids`` before re-dispatching either
        # way, same as the legacy path below, so a successful retry
        # consumes exactly the inputs the run was launched with (a no-op
        # when the links are still present). ``input_ids`` lives in the
        # structured ``parameters_json`` audit record regardless of which
        # orchestrator branch created the run (see ``_run_parameters_snapshot``
        # and the ``new-base-model`` / ``vibe-new-ecm-mvm`` stored_params).
        try:
            stored = json.loads(run.parameters_json) if run.parameters_json else {}
        except (json.JSONDecodeError, TypeError):
            stored = {}
        input_ids = stored.get("input_ids") if isinstance(stored, dict) else None
        _persist_run_input_links(session, run.id, input_ids or [])
        try:
            tracker.orchestrator.resume(run, session)
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to retry: {e}")
        session.commit()
        session.refresh(run)
        if run.status == "running":
            tracker.start_tracking(run.id)
        return _build_run_out(run, ws, session)

    agent_config = _get_agent_config(session)

    # Generate new session ID for the retry
    sid = generate_session_id()
    sid_bigint = session_id_to_bigint(sid)

    try:
        params = json.loads(run.parameters_json) if run.parameters_json else {}
        params["vibe_session_id"] = sid
        run.vibe_session_id = sid
        run.vibe_session_id_bigint = sid_bigint
        run.last_consumed_step_id = 0

        retry_job_tags = build_job_tags(
            business_name=run.business.name if run.business else "",
            model_scope=params.get("data_model_scopes", ""),
            version=params.get("model_version", ""),
            operation=run.intent,
            notebook_path=agent_config.notebook_path,
            session_id=sid,
            collect_statistics=agent_config.collect_vibe_run_statistics,
        )
        dbx_run_id = launch_run(
            ws,
            agent_config.job_id,
            params,
            job_tags=retry_job_tags,
            warehouse_id=resolve_warehouse_id(session, config),
            progress_migrate_strategy=config.progress_migrate_strategy,
        )
        run.databricks_run_id = dbx_run_id
        run.status = "running"
        run.started_at = datetime.now(timezone.utc)
        run.completed_at = None
        run.error_message = ""
        run.progress_percent = 0
        run.progress_message = ""
        run.parameters_json = json.dumps(params)
        # The preceding failure deleted this run's RunInputLink rows (re-pool
        # contract). Re-establish them from the recorded input_ids so a
        # successful retry consumes exactly the inputs the run was launched
        # with — without them, finalize would find no links and consume nothing.
        _persist_run_input_links(session, run.id, params.get("input_ids") or [])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retry: {e}")

    session.add(run)
    session.commit()
    session.refresh(run)

    tracker.start_tracking(run.id)

    return _build_run_out(run, ws, session)

@router.get(
    "/businesses/{business_id}/runs/{run_id}/artifacts",
    response_model=list[RunArtifactOut],
    operation_id="listArtifacts",
)
def list_artifacts(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
):
    get_run_in_business(session, business_id, run_id)
    artifacts = session.exec(
        select(RunArtifact)
        .where(RunArtifact.run_id == run_id)
        .order_by(RunArtifact.created_at.desc())
    ).all()
    return artifacts


# Artifact preview / download tuning + helpers live in `_artifact_io`
# so router.py (`/runs/.../artifacts/...`) and routes/versions.py
# (`/businesses/.../model-versions/.../artifacts/...`) share one source of truth.


@router.get(
    "/businesses/{business_id}/runs/{run_id}/artifacts/{artifact_id}/content",
    response_model=dict,
    operation_id="getArtifactContent",
)
def get_artifact_content(
    business_id: str,
    run_id: str,
    artifact_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    content_format: Literal["text", "hex"] = Query(
        "text",
        alias="format",
        description='Use "text" for UTF-8 text bodies, "hex" for a short hex dump of any file.',
    ),
):
    """Read artifact bytes from its Volume path. See :func:`build_artifact_content_response`."""
    get_run_in_business(session, business_id, run_id)
    artifact = session.exec(
        select(RunArtifact).where(
            RunArtifact.id == artifact_id,
            RunArtifact.run_id == run_id,
        )
    ).first()
    if not artifact:
        raise HTTPException(status_code=404, detail="Artifact not found")
    return build_artifact_content_response(ws, artifact, content_format)


@router.get(
    "/businesses/{business_id}/runs/{run_id}/artifacts/download",
    operation_id="downloadAllArtifacts",
)
def download_all_artifacts(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Stream a zip of every artifact for this run.

    Artifacts are read from the Volume sequentially and packed into a zip
    in memory. Fine for the MVP size range; if archives ever grow beyond a
    few hundred MB we'd need to stream via a temp file.
    """
    get_run_in_business(session, business_id, run_id)

    artifacts = session.exec(
        select(RunArtifact)
        .where(RunArtifact.run_id == run_id)
        .order_by(RunArtifact.created_at.desc())
    ).all()
    if not artifacts:
        raise HTTPException(status_code=404, detail="No artifacts to download")

    body = build_artifacts_zip_bytes(ws, artifacts)
    filename = f"run-{run_id[:8]}-artifacts.zip"
    return StreamingResponse(
        iter([body]),
        media_type="application/zip",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


@router.get(
    "/businesses/{business_id}/runs/{run_id}/artifacts/{artifact_id}/download",
    operation_id="downloadArtifact",
)
def download_artifact(
    business_id: str,
    run_id: str,
    artifact_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    inline: bool = Query(
        False,
        description="If true, use Content-Disposition: inline and a browser-friendly Content-Type (PDF, images) for embedding in the UI.",
    ),
):
    """Stream a single artifact's raw bytes as a file download (or inline preview)."""
    get_run_in_business(session, business_id, run_id)
    artifact = session.exec(
        select(RunArtifact).where(
            RunArtifact.id == artifact_id,
            RunArtifact.run_id == run_id,
        )
    ).first()
    if not artifact:
        raise HTTPException(status_code=404, detail="Artifact not found")
    return build_artifact_download_response(ws, artifact, inline=inline)
