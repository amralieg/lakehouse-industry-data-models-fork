"""Single source of truth for the agent widget map.

The agent's notebook accepts ~28 widget parameters per run. Both
``job_launcher.map_run_params_to_widgets`` (the legacy/dispatch path) and
``services.operations._generation_common.build_generation_widgets`` (the
unified-DAG path) delegate here. Don't duplicate this dict — fix it once,
here.

Two thin wrappers exist for historical reasons (different caller shapes:
one takes ``model_size``, the other already takes the literal
``data_model_scopes`` label). Both translate their inputs and call
``build_widget_map``. A regression test in
``tests/test_app/test_widget_unification.py`` asserts both wrappers
produce identical output for the same logical input.
"""

from __future__ import annotations

from typing import Any

from ._ids import session_id_to_bigint
from ._names import agent_business_segment


# Agent operations whose notebook widget validator requires a non-empty
# ``model_version`` value ("04. Version"). Dispatching one of these without
# the widget set causes the agent to abort at
# ``main.<locals>.get_widget_values`` with
# ``ValueError: ❌ MISSING REQUIRED VALUES``, BEFORE any progress event is
# written — so the App's run row sits as ``running`` forever while the job
# task has already terminated. Catching the empty value here, at the App
# boundary, surfaces the bug as a 4xx at submit-time instead.
#
# Source: the agent's per-op required-widget table (monolith line ~66099 in
# the v0.7.1-fold agent). When a new version-bound op is added agent-side,
# add it here too. See ``uninstall-diagnosis-2026-05-18.md``.
_AGENT_OPS_REQUIRING_MODEL_VERSION: frozenset[str] = frozenset({
    "vibe modeling of version",
    "install model",
    "uninstall model version",
    "generate sample data",
    "revert model version",
})


def build_widget_map(
    *,
    operation: str,
    data_model_scopes: str,
    business: Any,
    catalog: str,
    session_id: str,
    vibe_instructions: str = "",
    business_context_path: str = "",
    business_description_override: str = "",
    model_version: str = "",
    model_folder: str = "",
    naming_convention: str = "snake_case",
    primary_key_suffix: str = "_id",
    schema_prefix: str = "",
    schema_suffix: str = "",
    tag_prefix: str = "dbx_",
    tag_suffix: str = "",
    table_id_type: str = "BIGINT",
    boolean_format: str = "Boolean (True/False)",
    date_format: str = "yyyy-MM-dd",
    timestamp_format: str = "yyyy-MM-dd HH:mm:ss",
    cataloging_style: str = "One Catalog",
    catalog_prefix: str = "",
    catalog_suffix: str = "",
    org_divisions: str = "Operations",
    business_domains: str = "",
    classification_levels: str = "",
    housekeeping_columns: str = "No",
    history_tracking_columns: str = "No",
    generate_samples: bool = False,
) -> dict[str, str]:
    """Build the canonical ~28-widget map a generation-group agent op expects.

    ``business`` may be a ``db_models.Business`` row or any object exposing
    ``.name``, ``.description``, and ``.industry_alignment``. We use
    ``getattr(...)`` defensively so test doubles (SimpleNamespace) and
    primitives invoked outside a request scope both work.

    Raises ``ValueError`` when ``operation`` is in
    :data:`_AGENT_OPS_REQUIRING_MODEL_VERSION` and ``model_version`` is empty
    or absent — these ops would otherwise dispatch a doomed run that the
    agent's notebook widget validator rejects on launch. The caller (route
    handler / orchestrator factory) must resolve the version first or 4xx.
    """
    if operation in _AGENT_OPS_REQUIRING_MODEL_VERSION and not model_version:
        raise ValueError(
            f"Operation {operation!r} requires a non-empty "
            f"`model_version`; got {model_version!r}. The App could not "
            "resolve a target ModelVersion for this run — pass `version_id` "
            "explicitly, or run new-base-model first."
        )
    widgets: dict[str, str] = {
        # Core operation params
        "operation": operation,
        "business_name": agent_business_segment(getattr(business, "name", "") or ""),
        "business_description": (
            business_description_override
            or (getattr(business, "description", "") or "")
        ),
        "context_file": business_context_path,
        "deployment_catalog": catalog,
        "data_model_scopes": data_model_scopes,
        "generate_samples": "10" if generate_samples else "0",
        "model_vibes": vibe_instructions,
        # Agent expects a BIGINT-as-string here. If we pass a UUID, the agent's
        # ``int(_raw_sid)`` parse fails and it generates its OWN session_id
        # internally, which means the app's progress_tracker (which queries
        # ``_business``/``_vibe_progress`` by the BIGINT we computed at launch
        # time) finds zero rows for the entire run. Convert via the SHA-256
        # truncation helper so the app's BIGINT and the agent's BIGINT match.
        "vibe_session_id": str(session_id_to_bigint(session_id)),
        "industry_alignment": getattr(business, "industry_alignment", "") or "",
        # Organization
        "business_domains": business_domains,
        "org_divisions": org_divisions,
        # Catalog layout
        "cataloging_style": cataloging_style,
        "catalog_prefix": catalog_prefix,
        "catalog_suffix": catalog_suffix,
        # Naming conventions
        "naming_convention": naming_convention,
        "primary_key_suffix": primary_key_suffix,
        "schema_prefix": schema_prefix,
        "schema_suffix": schema_suffix,
        "tag_prefix": tag_prefix,
        "tag_suffix": tag_suffix,
        # Type conventions
        "table_id_type": table_id_type,
        "boolean_format": boolean_format,
        "date_format": date_format,
        "timestamp_format": timestamp_format,
        # Governance
        "classification_levels": classification_levels,
        "housekeeping_columns": housekeeping_columns,
        "history_tracking_columns": history_tracking_columns,
    }
    if model_version:
        widgets["model_version"] = model_version
    if model_folder:
        widgets["model_folder"] = model_folder
    return widgets
