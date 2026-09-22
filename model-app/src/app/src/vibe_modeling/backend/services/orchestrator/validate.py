"""DAG validator — the single pure function called by both
``POST /runs/validate`` (live form feedback) and ``POST /runs`` (hard
submit). See ``docs/orchestrator-design.md`` §2.4 + §2.4.1.

This module owns the ``validate_dag`` primitive: given a built ``Dag``
plus a way to look operations up by name, walk the DAG and collect every
field-level (Pydantic) and cross-step (Dag) issue without raising.

The higher-level ``validate_dag_request(req, business, context,
agent_config)`` coordinator — which selects the DAG factory from
``req.intent`` and produces the ``Dag`` — belongs to the Phase 4 wirer
slice. Phase 1 owns only this primitive.
"""

from dataclasses import dataclass
from typing import Callable, Optional, TYPE_CHECKING

from pydantic import ValidationError

from ._types import Issue
from .dag import Dag

from ..operations._protocol import Operation
from ...models import Intent

if TYPE_CHECKING:
    from ...db_models import AgentConfig, Business, BusinessContext
    from ...models import RunIn


@dataclass(frozen=True, slots=True)
class ValidationResult:
    """Outcome of validating a Dag.

    ``dag`` is the original DAG when there are no blockers (so the
    caller can carry it forward into ``orchestrator.start``), and
    ``None`` when at least one blocker was found (``POST /runs`` returns
    400 in that case).

    ``warnings`` flow through to ``POST /runs`` callers regardless — the
    UI surfaces them as "Submit anyway" confirmations per spec §2.4.
    """

    dag: Optional[Dag]
    blockers: list[Issue]
    warnings: list[Issue]


def validate_dag(
    dag: Dag,
    *,
    registry_get: Callable[[str], Operation],
) -> ValidationResult:
    """Validate every step of ``dag`` and collect all findings.

    Pure function. No I/O, no DB, no logging. ``registry_get`` is
    injected so:

    - Unit tests pass a fake registry without bootstrapping the real one.
    - The Phase 4 wirers can pass ``services.operations._registry.get``
      after the integrator merges that branch.

    The validation walks per spec §2.4.1:

    1. Gate A — name resolution: ``registry_get(step.name)``.
       ``KeyError`` → blocker, continue (skip Gate B for this step).
    2. Gate B — field-level + within-step: ``op.params_model(**params)``.
       ``ValidationError`` → one blocker per ``err`` in
       ``e.errors()``.
    3. Gate C — cross-step: ``dag.validate_cross_step()``.

    Warnings are emitted only by DAG factories (Phase 4) before the DAG
    reaches this function; the validator itself currently produces only
    blockers. The ``warnings`` field is preserved on the result so the
    coordinator (``validate_dag_request``, Phase 4) can pass through any
    warnings it received from the factory.
    """
    blockers: list[Issue] = []
    warnings: list[Issue] = []

    # Track which step names belong to version-producing ops so we can
    # flag duplicate ``output_version_id`` bindings (rule below). The
    # orchestrator binds an op's ``output_version_id`` to its step name
    # at dispatch time (see ``Orchestrator._inherit_parent_version``);
    # two version-producing steps that share a name would emit two
    # ModelVersions under one identifier, silently breaking lineage.
    version_producing_step_indices: dict[str, list[int]] = {}

    for i, step in enumerate(dag.steps):
        # Gate A — does this primitive exist?
        try:
            op = registry_get(step.name)
        except KeyError:
            blockers.append(
                Issue(
                    field_path=f"steps[{i}].name",
                    step_index=i,
                    message=f"Unknown primitive: '{step.name}'",
                    severity="blocker",
                )
            )
            # Skip Gate B for this step; we have nothing to validate
            # ``params`` against.
            continue

        # Gate B — field-level + within-step rules via Pydantic.
        try:
            op.params_model(**step.params)
        except ValidationError as e:
            for err in e.errors():
                # err["loc"] is a tuple like ("schema_prefix",) or
                # ("nested", "field"). Join it for a stable
                # ``field_path`` the UI can render.
                loc = ".".join(str(p) for p in err["loc"])
                blockers.append(
                    Issue(
                        field_path=(
                            f"steps[{i}].params.{loc}"
                            if loc
                            else f"steps[{i}].params"
                        ),
                        step_index=i,
                        message=err["msg"],
                        severity="blocker",
                    )
                )

        # Track version-producing steps for the duplicate-output rule
        # below. Skip non-producing primitives (``install``, etc.) —
        # multi-catalog DAGs legitimately repeat them once per scope.
        if getattr(op, "produces_version", False):
            version_producing_step_indices.setdefault(step.name, []).append(i)

    # Cross-step rule — duplicate ``output_version_id`` binding. Lives
    # here (not in ``Dag.validate_cross_step``) because it needs the
    # registry to know which steps actually produce a ModelVersion.
    # Flag every duplicate after the first so the operator sees which
    # step name needs renaming.
    for step_name, indices in version_producing_step_indices.items():
        if len(indices) <= 1:
            continue
        for i in indices[1:]:
            blockers.append(
                Issue(
                    field_path=f"steps[{i}].name",
                    step_index=i,
                    message=(
                        f"Duplicate output_version_id: step name "
                        f"'{step_name}' is bound by {len(indices)} "
                        f"version-producing steps; output lineage cannot "
                        f"be disambiguated"
                    ),
                    severity="blocker",
                )
            )

    # Gate C — cross-step rules.
    blockers.extend(dag.validate_cross_step())

    return ValidationResult(
        dag=dag if not blockers else None,
        blockers=blockers,
        warnings=warnings,
    )


# --- Coordinator -----------------------------------------------------------
#
# Higher-level entry point used by both ``POST /runs/validate`` and
# ``POST /runs`` per spec §2.4.1. Picks the DAG factory by ``req.intent``,
# composes the DAG, then delegates to ``validate_dag`` for Gates A–C.


def validate_dag_request(
    req: "RunIn",
    business: "Business",
    business_context: "Optional[BusinessContext]" = None,
    agent_config: "Optional[AgentConfig]" = None,
    *,
    registry_get: Optional[Callable[[str], Operation]] = None,
) -> ValidationResult:
    """Build the DAG for ``req.intent`` and validate it.

    Pure function — no DB, no I/O. The route handler is responsible for
    loading ``business`` / ``business_context`` / ``agent_config`` from
    Lakebase before calling this.

    Returns a :class:`ValidationResult`:

    - ``dag``: the composed :class:`Dag` (``None`` when blockers found).
    - ``blockers``: list of ``Issue(severity="blocker")``.
    - ``warnings``: list of ``Issue(severity="warning")``.

    The handler maps ``blockers`` to HTTP 400 on ``POST /runs`` and
    echoes them inline for the ``POST /runs/validate`` form-feedback
    surface; warnings flow through to both gates so the UI can show a
    "Submit anyway" confirmation.
    """
    # Lazy import: avoid a circular edge between models.py + this module
    # at import time. ``models.py`` does not depend on the orchestrator
    # package — keeping this import inside the function keeps it that
    # way.
    from .dag_factories import (
        dag_for_new_base_model,
        dag_for_vibe_new_ecm_mvm,
    )
    from ..operations._registry import get as default_registry_get

    rget = registry_get or default_registry_get

    # Pick the factory. New intents land here as additional branches —
    # the other Phase 4 wirers (simple, recovery) own theirs.
    intent_value = (
        req.intent.value if req.intent is not None else None
    )

    if intent_value == Intent.NEW_BASE_MODEL.value:
        dag = dag_for_new_base_model(req, business, business_context, agent_config)
        return validate_dag(dag, registry_get=rget)

    if intent_value == Intent.VIBE_NEW_ECM_MVM.value:
        dag = dag_for_vibe_new_ecm_mvm(
            req, business, business_context, agent_config
        )
        return validate_dag(dag, registry_get=rget)

    # No DAG factory wired for this intent yet. This is not a submission
    # blocker: intents outside the two wired above (vibe-iterate, install,
    # uninstall, generate-samples, revert, import-from-volume) still submit
    # through the standard (non-orchestrator) pipeline; only the
    # ``POST /runs/validate`` preview is unavailable. Surface a warning so
    # the run form's "Submit anyway" flow stays open per spec §2.4.
    return ValidationResult(
        dag=None,
        blockers=[],
        warnings=[
            Issue(
                field_path="intent",
                step_index=-1,
                message=(
                    f"Run-plan preview is not available for intent "
                    f"{intent_value!r} yet; submission uses the standard "
                    f"pipeline."
                ),
                severity="warning",
            )
        ],
    )


# --- Per-intent gates that require DB lookups -------------------------------
#
# ``validate_dag_request`` is a pure function: no DB session, no workspace
# client. A handful of cross-step rules need to consult the resolved parent
# ``ModelVersion`` (e.g. "for vibe-new-ecm-mvm the parent must be
# ECM-scoped"). The route handler resolves that row and calls these helpers
# directly before / alongside ``validate_dag_request``.


def parent_scope_blocker_for_intent(intent_value: str, parent_mv) -> Optional[Issue]:
    """Return a blocker if the parent ``ModelVersion`` is the wrong scope
    for the supplied intent, or ``None`` when the parent is acceptable
    (or no scope rule exists for this intent).

    Today only ``vibe-new-ecm-mvm`` carries a parent-scope constraint:
    the run vibes the parent ECM and then shrinks it to MVM, so an
    MVM parent would be nonsensical. Empty/unset scope on the parent
    is treated as legacy ECM (the original ECM rows pre-date the
    ``scope`` column's per-scope values).
    """
    if intent_value != Intent.VIBE_NEW_ECM_MVM.value:
        return None
    if parent_mv is None:
        return Issue(
            field_path="parent_version_id",
            step_index=-1,
            message=(
                "vibe-new-ecm-mvm requires a parent ECM model version; "
                "none was supplied."
            ),
            severity="blocker",
        )
    raw = (getattr(parent_mv, "scope", "") or "").strip().lower()
    # "" (legacy) and "ecm" both qualify as ECM. Anything else (notably
    # "mvm") is rejected.
    if raw in ("", "ecm"):
        return None
    return Issue(
        field_path="parent_version_id",
        step_index=-1,
        message="Parent version must be an ECM scope",
        severity="blocker",
    )


# Intents that dispatch a generation-group agent op with an empty
# ``business_description`` widget when the business has no description (and no
# inline/file override); the agent's notebook widget validator hard-rejects
# ("Business description is required") for every operation except
# install/uninstall/generate-samples, but only these three intents reach that
# validator via a FRESH description-mode dispatch with no already-durable
# model.json to fall back on: install/uninstall/generate-samples operate on
# an already-completed version (exempted agent-side) and import-from-volume
# never reaches the agent at all. ``revert`` technically hits the same
# agent-side check too, but is deliberately left out of this gate: it always
# replays an already-completed version, so a description was already
# required to produce that version in the first place.
_DESCRIPTION_REQUIRED_INTENTS: frozenset[str] = frozenset({
    Intent.NEW_BASE_MODEL.value,
    Intent.VIBE_ITERATE.value,
    Intent.VIBE_NEW_ECM_MVM.value,
})


def business_description_blocker_for_intent(
    intent_value: str,
    business,
    *,
    business_context_text: str = "",
    business_context_path: str = "",
) -> Optional[Issue]:
    """Return a blocker when a model-producing intent would dispatch to the
    agent with an empty ``business_description`` widget and no rescuing
    context, or ``None`` when the business carries enough context (or the
    intent has no such requirement).

    The agent needs EITHER a non-empty description OR an already-loaded
    context file to resolve the business identity/complexity tier; without
    either it aborts ~1 minute into compute with "Business description is
    required" (see the agent's per-op required-widget validator). Catching
    this here turns that wasted minute into an inline submit-time blocker.

    Both overrides rescue a blank description for all three gated intents:
    ``business_context_text`` (inline text) feeds ``business_description``
    directly, and ``business_context_path`` (a Volume model.json path) feeds
    the agent's ``context_file`` widget; every DAG factory that reaches a
    gated intent threads both through (``dag_for_vibe_iterate`` via
    ``_optional_convention_params``'s ``business_context_path`` carry-key,
    the unified factory via ``req.business_context_path`` directly).
    """
    if intent_value not in _DESCRIPTION_REQUIRED_INTENTS:
        return None
    description = (
        (business_context_text or "").strip()
        or (getattr(business, "description", "") or "").strip()
    )
    if description:
        return None
    if (business_context_path or "").strip():
        return None
    return Issue(
        field_path="business_description",
        step_index=-1,
        message=(
            "Add a business description (Edit business) before launching "
            "a run."
        ),
        severity="blocker",
    )


def deployed_version_reinstall_warning(
    intent_value: str,
    target_mv,
    target_catalog: str,
) -> Optional[Issue]:
    """Return a warning when an install run targets a ``ModelVersion``
    that's already recorded as deployed to this exact catalog, or ``None``
    when the run is safe (or the gate doesn't apply).

    Submitting an install over an already-installed version dispatches the
    agent, which burns ~6 minutes of compute before its own downstream
    clash guard rejects the run (installing over an already-installed
    version is illegal). Catching the same fact here turns that wasted
    run into an inline, submit-time notice.

    Deliberately a warning, never a blocker: re-installing after an
    out-of-band ``DROP SCHEMA``, or a stale reconcile/drift read, are
    legitimate workflows this gate must not prevent.

    Called from both ``_collect_run_preflight_blockers`` (feeds the
    ``POST /runs/validate`` live form-warning surface) and
    ``_create_run_via_orchestrator`` (feeds ``RunOut.warnings`` on the
    actual submit) - the single canonical check for both surfaces.
    """
    if intent_value != Intent.INSTALL.value:
        return None
    if target_mv is None:
        return None
    if (getattr(target_mv, "deployment_status", "") or "") != "deployed":
        return None
    catalog = (target_catalog or "").strip()
    deployed_catalog = (getattr(target_mv, "uc_catalog", "") or "").strip()
    if not catalog or not deployed_catalog or catalog != deployed_catalog:
        return None
    return Issue(
        field_path="version_id",
        step_index=-1,
        message=(
            f"This version is already recorded as deployed to {catalog}; "
            "re-installing without uninstalling first will fail the "
            "agent's clash check."
        ),
        severity="warning",
    )
