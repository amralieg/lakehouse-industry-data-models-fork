"""Single-step DAG factories for the four "simple" intents.

The four intents covered here each map to exactly one
:class:`OperationStep` — no fan-out, no skip predicates, no
``needs_version_from`` chains. The orchestrator persists one
``RunOperation`` row per run, dispatches it on ``start()``, and walks
to a terminal state in a single observe pass once the underlying
Databricks job completes.

Per ``docs/orchestrator-design.md`` §3:

* Factories are pure (no DB, no workspace client). The route handler
  passes in the ``req`` (the validated ``RunIn`` body), the resolved
  ``Business`` / ``BusinessContext`` / ``AgentConfig`` rows, and any
  carry-keys the handler already worked out (e.g. the resolved target
  catalog and the parent ``ModelVersion`` row).
* Factories may emit warnings via the returned ``Dag``'s validation
  surface — but for the simple intents there is no cross-step rule
  to violate, so today every Dag returned here has zero warnings.

Per the Phase-4 briefing, the route handler is responsible for
populating the ``RunOperation.parent_version_id`` field on the
persisted row before the orchestrator advances the DAG. The factory
itself does NOT thread ``parent_version_id`` through ``params`` — it
flows on the :class:`OperationContext` instead (spec §2 reconciliation
brief #1).
"""

from __future__ import annotations

from typing import Any, Optional

from ....core import resolve_run_target_catalog
from ....core._names import agent_business_segment
from ....models import Intent
from ..dag import Dag, OperationStep


def _sanitized_business_name(business: Any) -> str:
    """Coerce ``Business.name`` into the lowercase-snake form the
    install/uninstall/generate_samples primitives expect.

    The ``install`` / ``uninstall`` / ``generate_samples`` params
    models constrain ``business_name`` to ``^[a-z][a-z0-9_]+$`` (a
    legal UC catalog segment fragment). Phase 4 of the drift-unification
    plan reconciles this helper with the canonical
    :func:`agent_business_segment` (the agent's own
    ``sanitize_name(strip_stop_words=False)`` rule that produces the
    on-disk Volume path segment) so that the value carried in
    ``business_name`` matches the agent's actual filesystem layout.

    For realistic business labels the two sanitizers are empirically
    identical (see ``tests/test_app/test_core_names.py::
    test_agent_segment_eq_catalog_segment_for_business_names``); the
    only divergences are empty-default and digit-prefix, and both
    produce a value the pydantic regex rejects up-front anyway. Using
    the agent rule keeps every path-builder consumer consistent.
    """
    return agent_business_segment(getattr(business, "name", "") or "")


def _resolved_cataloging_style(req: Any) -> str:
    """One of the three cataloging styles the agent supports."""
    style = (getattr(req, "cataloging_style", None) or "").strip()
    return style or "One Catalog"


def _scope_short(req: Any, parent_mv: Any) -> str:
    """``"ecm"`` or ``"mvm"`` — the short form the primitives expect.

    Prefers an explicit ``req.scope`` (the route handler / form already
    resolved it) and falls back to ``parent_mv.scope`` so the route
    handler can pass either signal. Both eventually agree because the
    install/uninstall/samples primitives only operate on a deployed
    ModelVersion whose own scope IS the run's scope.
    """
    explicit = (getattr(req, "scope", None) or "").lower()
    if "ecm" in explicit:
        return "ecm"
    if "mvm" in explicit:
        return "mvm"
    raw = (getattr(parent_mv, "scope", "") or "").lower()
    return "ecm" if "ecm" in raw else "mvm"


def _model_version_int(req: Any, parent_mv: Any) -> int:
    """The integer version this run operates on. ``0`` if unresolvable
    (the validator will reject it because all three deployment
    primitives require ``model_version > 0``)."""
    explicit = getattr(req, "version_int", None)
    if isinstance(explicit, int) and explicit > 0:
        return explicit
    if parent_mv is None:
        return 0
    try:
        return int(getattr(parent_mv, "version", 0) or 0)
    except (TypeError, ValueError):
        return 0


def _schema_prefix_for(
    req: Any, cataloging_style: str, parent_mv: Any = None
) -> str:
    """Resolve the ``schema_prefix`` the install/uninstall/samples
    primitives expect.

    ``InstallParams.schema_prefix_matches_cataloging_style`` enforces:
    - One Catalog requires a non-empty prefix.
    - Catalog per Division/Domain forbids one.

    Resolution order:
    1. ``req.schema_prefix`` — explicit user override always wins.
    2. ``parent_mv.scope`` — derive ``ecm_`` or ``mvm_`` from the
       version being installed/uninstalled/sampled, matching the
       unified-pipeline convention (spec §3 "One Catalog" DAG).
    3. Fallback to ``mvm_`` for One Catalog when no parent scope is
       available — most single-step callers target a deployed (MVM)
       model. Multi-catalog styles must remain empty per the
       primitive's model validator.

    Phase 4.5 walkthrough (the test workspace): step 1A blocked because the
    frontend doesn't expose ``schema_prefix`` on the simple-op forms
    (intentional — for One Catalog the prefix is conventional, not
    user-chosen). Without parent-derived defaults the install op
    422'd at validation; this resolution chain unblocks.

    NOTE: ``None`` (field absent from the request) and ``""`` (explicit
    empty string) are treated differently. ``None`` falls through to
    the parent-derived default; ``""`` is passed through verbatim so
    a curl caller that explicitly says "empty" still trips the
    primitive's cross-field validator (preserves the test contract in
    ``test_install_one_catalog_without_schema_prefix_returns_blocker``).
    """
    explicit = getattr(req, "schema_prefix", None)
    if explicit is not None:
        # Explicit user choice — pass through verbatim. The primitive's
        # validator will surface a blocker if the value combined with
        # the cataloging_style is illegal.
        return explicit
    if cataloging_style != "One Catalog":
        # Catalog per Division / per Domain: the per-scope catalog
        # already provides the namespace; passing a prefix would
        # double-namespace and fail validation.
        return ""
    # One Catalog: derive from the parent model version's scope.
    scope = ""
    if parent_mv is not None:
        scope = (getattr(parent_mv, "scope", "") or "").lower()
    if "ecm" in scope:
        return "ecm_"
    if "mvm" in scope:
        return "mvm_"
    # No parent scope information: fall back to ``mvm_``. Most callers
    # of these single-step ops target a deployed (MVM) model.
    return "mvm_"


def dag_for_vibe_iterate(
    req: Any,
    business: Any,
    ctx: Any = None,
    agent_cfg: Any = None,
) -> Dag:
    """Single-op DAG for the ``vibe-iterate`` intent.

    The agent's ``vibe modeling of version`` op iterates an existing
    ModelVersion: it reads the parent's ``model.json``, applies the
    user's vibe text, and writes a NEW version. ``parent_version_id``
    flows through :class:`OperationContext` (set by the route handler
    on the persisted ``RunOperation`` row) — NOT through the params
    dict.
    """
    return Dag(
        intent=Intent.VIBE_ITERATE.value,
        steps=(
            OperationStep(
                name="vibe_iterate",
                params={
                    "business_name": _sanitized_business_name(business),
                    "deployment_catalog": resolve_run_target_catalog(req, agent_cfg),
                    "vibe_instructions": getattr(req, "vibe_instructions", "") or "",
                    "cataloging_style": _resolved_cataloging_style(req),
                    "schema_prefix": getattr(req, "schema_prefix", "") or "",
                    # Carry-keys (the params model defaults already match
                    # the agent's expectations; these only fire when the
                    # caller wants to override). Keep this list narrow —
                    # vibe_iterate's params model accepts a wide surface
                    # but most fields are intentionally optional.
                    **_optional_convention_params(req),
                },
            ),
        ),
    )


def dag_for_install(
    req: Any,
    business: Any,
    ctx: Any = None,
    agent_cfg: Any = None,
) -> Dag:
    """Single-op DAG for the ``install`` intent.

    The route handler resolves the target ``ModelVersion`` (the
    version being installed) and passes it via ``ctx.parent_mv`` so we
    can read its scope + version int. The orchestrator's
    ``parent_version_id`` is set on the persisted row by the route
    handler — the factory does not touch that surface.
    """
    parent_mv = getattr(ctx, "parent_mv", None) if ctx is not None else None
    cataloging_style = _resolved_cataloging_style(req)
    # Imported and reference-seeded ModelVersions record their actual
    # model.json location on ``import_source_path``. Agent-produced
    # versions leave that field NULL because the agent writes model.json
    # at the convention path the install widget builder constructs by
    # default. Threading the override here closes the import / seed gap
    # surfaced by the 2026-05-18 walkthrough (energy_utilities import +
    # Ecommerce Reference Model both failed install with "Model JSON
    # File not found" before this fix).
    context_file_override = (
        getattr(parent_mv, "import_source_path", None) if parent_mv is not None else None
    )
    return Dag(
        intent="install",
        steps=(
            OperationStep(
                name="install",
                params={
                    "scope": _scope_short(req, parent_mv),
                    "business_name": _sanitized_business_name(business),
                    "deployment_catalog": resolve_run_target_catalog(req, agent_cfg),
                    "schema_prefix": _schema_prefix_for(
                        req, cataloging_style, parent_mv
                    ),
                    "model_version": _model_version_int(req, parent_mv),
                    "cataloging_style": cataloging_style,
                    "naming_convention": (
                        getattr(req, "naming_convention", None) or "snake_case"
                    ),
                    "primary_key_suffix": (
                        getattr(req, "primary_key_suffix", None) or "_id"
                    ),
                    "table_id_type": (
                        getattr(req, "table_id_type", None) or "BIGINT"
                    ),
                    "context_file_override": context_file_override,
                },
            ),
        ),
    )


def dag_for_uninstall(
    req: Any,
    business: Any,
    ctx: Any = None,
    agent_cfg: Any = None,
) -> Dag:
    """Single-op DAG for the ``uninstall`` intent.

    Mirror of :func:`dag_for_install` but emits the ``uninstall``
    primitive. The two share a params surface; we narrow to the
    fields ``UninstallParams`` actually accepts (no naming convention
    pass-through — the agent's uninstall op doesn't use them).
    """
    parent_mv = getattr(ctx, "parent_mv", None) if ctx is not None else None
    cataloging_style = _resolved_cataloging_style(req)
    return Dag(
        intent="uninstall",
        steps=(
            OperationStep(
                name="uninstall",
                params={
                    "business_name": _sanitized_business_name(business),
                    "deployment_catalog": resolve_run_target_catalog(req, agent_cfg),
                    "schema_prefix": _schema_prefix_for(
                        req, cataloging_style, parent_mv
                    ),
                    "scope": _scope_short(req, parent_mv),
                    "model_version": _model_version_int(req, parent_mv),
                    "cataloging_style": cataloging_style,
                    "version_id": getattr(parent_mv, "id", None),
                },
            ),
        ),
    )


def dag_for_generate_samples(
    req: Any,
    business: Any,
    ctx: Any = None,
    agent_cfg: Any = None,
) -> Dag:
    """Single-op DAG for the ``generate-samples`` intent.

    Maps the legacy ``generate_samples: bool`` request field — kept on
    ``RunIn`` for back-compat with the legacy router branches — to
    the primitive's ``sample_count: int`` parameter. ``True`` becomes
    the legacy default of 10 rows; ``False`` would never reach this
    factory (the route handler rejects it). When a caller passes an
    explicit ``sample_count`` via ``req.parameters_json`` (an admin
    fixture path in tests), we honour it.
    """
    parent_mv = getattr(ctx, "parent_mv", None) if ctx is not None else None
    cataloging_style = _resolved_cataloging_style(req)
    sample_count = _resolve_sample_count(req)
    return Dag(
        intent="generate-samples",
        steps=(
            OperationStep(
                name="generate_samples",
                params={
                    "business_name": _sanitized_business_name(business),
                    "deployment_catalog": resolve_run_target_catalog(req, agent_cfg),
                    "schema_prefix": _schema_prefix_for(
                        req, cataloging_style, parent_mv
                    ),
                    "scope": _scope_short(req, parent_mv),
                    "model_version": _model_version_int(req, parent_mv),
                    "cataloging_style": cataloging_style,
                    "sample_count": sample_count,
                },
            ),
        ),
    )


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _optional_convention_params(req: Any) -> dict:
    """Forward only the convention overrides the user actually set.

    ``vibe_iterate`` params model accepts a large surface (carry-keys
    for the agent's ``vibe modeling of version`` op). For each field
    we forward only when the caller explicitly supplied a value —
    leaving Pydantic to pick its default for everything else. This
    keeps the persisted ``params_json`` blob narrow on the happy path
    and avoids accidentally locking in a stale default.
    """
    out: dict[str, Any] = {}
    for field in (
        "naming_convention",
        "primary_key_suffix",
        "schema_suffix",
        "tag_prefix",
        "tag_suffix",
        "table_id_type",
        "boolean_format",
        "date_format",
        "timestamp_format",
        "catalog_prefix",
        "catalog_suffix",
        "org_divisions",
        "business_domains",
        "classification_levels",
        "housekeeping_columns",
        "history_tracking_columns",
    ):
        v = getattr(req, field, None)
        if v is not None:
            out[field] = v
    # Inline business context override → the agent's
    # business_description carry-key (mirrors the legacy router).
    biz_text = getattr(req, "business_context_text", "") or ""
    if biz_text.strip():
        out["business_description_override"] = biz_text.strip()
    biz_path = getattr(req, "business_context_path", "") or ""
    if biz_path.strip():
        out["business_context_path"] = biz_path.strip()
    model_size = getattr(req, "model_size", None)
    if model_size:
        out["model_size"] = model_size
    return out


def _resolve_sample_count(req: Any) -> int:
    """Translate the request's sample-count signal into an int.

    The current ``RunIn`` exposes ``generate_samples: bool`` (legacy)
    rather than a count. We default ``True`` to 10 (the agent's own
    default), letting tests + future callers override via an
    explicit ``sample_count`` attribute on the request. Anything
    illegal (≤0, > 1000) propagates to the params validator as a
    blocker.
    """
    explicit = getattr(req, "sample_count", None)
    if isinstance(explicit, int) and explicit > 0:
        return explicit
    legacy_flag = bool(getattr(req, "generate_samples", False))
    return 10 if legacy_flag else 10  # always at least 10 for an explicit intent


__all__ = [
    "dag_for_generate_samples",
    "dag_for_install",
    "dag_for_uninstall",
    "dag_for_vibe_iterate",
]
