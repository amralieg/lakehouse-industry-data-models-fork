"""Pydantic models for API request/response validation."""

from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

from .. import __version__


def validate_business_description(value: str) -> str:
    """Reject an empty/whitespace-only business description.

    Shared by ``BusinessIn``'s field validator (create/update Business via the
    API) and the industry-kickstart path (``industry_kickstart.py``), so a
    business can never end up with a blank description regardless of entry
    point - one check, one message.
    """
    if not value.strip():
        raise ValueError("description must not be empty or whitespace-only")
    return value


class VersionOut(BaseModel):
    version: str

    @classmethod
    def from_metadata(cls):
        return cls(version=__version__)

# --- Enums ---

class RunStatus(str, Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"
    STALE = "stale"
    # Set by /runs/{id}/cancel-with-rollback when at least one reverse-op
    # failed. The run is terminal — not reusable — and the UI should
    # surface a "manual cleanup required" banner. Introduced in #118.
    ROLLED_BACK_FAILED = "rolled_back_failed"

# --- Vibe Input enums (string columns + str,Enum mirror; no DB enum type) ---

class VibeInputOrigin(str, Enum):
    USER = "user"
    AGENT_NEXT_VIBE = "agent_next_vibe"

class VibeInputPriority(str, Enum):
    """Canonical priority vocabulary. ``NextVibeItem.priority`` is typed to
    this so the agent's next-vibe priority and the input priority cannot
    drift (unify — task2-lakebase-schema.md §0.3). The agent vocabulary
    (must/optional) is translated to this vocabulary at the parse boundary
    (routes/_helpers.py); ``medium`` is a user-only value the agent never
    emits."""
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"

class VibeInputStatus(str, Enum):
    ACTIVE = "active"
    DEPRECATED = "deprecated"

class NextVibeCategory(str, Enum):
    """Classification of an agent next-vibe finding. The canonical, structured
    representation the next_vibes ingestion will populate (it is NOT recovered
    from a text prefix). Mirrors the nullable ``VibeInput.category`` string
    column; null for ``origin=user`` inputs (feedback has no category).

    - ``STATIC_ANALYSIS`` — a deterministic static-analysis finding.
    - ``PRIORITY_REMEDIATION`` — a prioritized remediation step.
    - ``OTHER`` — any other known issue.
    """
    STATIC_ANALYSIS = "static_analysis"
    PRIORITY_REMEDIATION = "priority_remediation"
    OTHER = "other"

class ReviewState(str, Enum):
    """Product-canonical review state (ADR D-044). Stored sparsely on
    ``product_reviews.state`` (string column + ``str, Enum`` mirror); absence
    of a row means the state is computed (see ``backend/review.py``)."""
    REVIEWED = "reviewed"
    NOT_REVIEWED = "not_reviewed"
    NO_REVIEW_NEEDED = "no_review_needed"

class Intent(str, Enum):
    """Describes "what the user wants the run to accomplish" — multi-step
    DAGs no longer have to pretend to be a single op. The canonical run
    label persisted on ``Run.intent`` (see ``docs/orchestrator-design.md``
    §8).
    """

    NEW_BASE_MODEL = "new-base-model"
    VIBE_ITERATE = "vibe-iterate"
    # Internal-only authoring helper: vibe an ECM, then automatically
    # shrink to MVM in the same run. Same DAG shape as ``new-base-model``
    # but seeded from a parent ECM via ``vibe_iterate`` instead of a
    # cold-start ``generate_ecm``. The parent must be ECM-scoped — the
    # validator rejects MVM parents at submit time.
    VIBE_NEW_ECM_MVM = "vibe-new-ecm-mvm"
    REVERT = "revert"
    IMPORT_FROM_VOLUME = "import-from-volume"
    INSTALL = "install"
    UNINSTALL = "uninstall"
    GENERATE_SAMPLES = "generate-samples"

class DeploymentStatus(str, Enum):
    DRAFT = "draft"
    DEPLOYED = "deployed"
    UNINSTALLED = "uninstalled"

class ModelStatus(str, Enum):
    DRAFT = "draft"
    GENERATING = "generating"
    COMPLETED = "completed"
    FAILED = "failed"
    # Defensive add: vibe-iterate marks the parent ModelVersion's
    # status='superseded' (services/operations/vibe_iterate.py:609) when
    # producing a derived version. Without this entry, ``GET /businesses/
    # {id}/versions`` 500s with a Pydantic enum validation error whenever
    # any version row carries that status. The upstream concern — whether
    # marking the SOURCE version as superseded is the right behaviour —
    # is filed as a separate followup; we widen the response enum here so
    # the FE Base Version dropdown stops breaking.
    SUPERSEDED = "superseded"

class BusinessKind(str, Enum):
    """Discriminator on ``businesses.kind`` (ADR D-046). An ``INDUSTRY`` is a
    meta-business: a reusable template surfaced in the UI as an "Industry"
    (never "meta-business"). A ``BUSINESS`` is a real business. Both share the
    full pipeline; deployments are labelled by kind."""
    BUSINESS = "business"
    INDUSTRY = "industry"

# --- Industry ---

class IndustryIn(BaseModel):
    name: str
    short_name: str
    description: str = ""
    notable_businesses: str = ""
    display_order: int = 0
    is_active: bool = True

class IndustryOut(BaseModel):
    id: str
    name: str
    short_name: str
    description: str
    notable_businesses: str
    display_order: int
    is_active: bool
    is_auto_created: bool
    created_at: datetime
    updated_at: datetime

# --- Sector (taxonomy top level, ADR D-047) ---

class SectorIn(BaseModel):
    name: str
    short_name: str
    description: str = ""
    display_order: int = 0
    is_active: bool = True

class SectorOut(BaseModel):
    id: str
    name: str
    short_name: str
    description: str
    display_order: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

# --- Agent Config ---

# Persistent agent job's max_concurrent_runs floor. Below 3 the app's two
# benign overlaps collide: (a) unified-pipeline phase transition (finalizing
# run briefly coexists with the next phase's run_now) and (b) cancel-with-
# rollback (uninstall cleanup launches while the cancelled run is still
# moving to TERMINATED). Server enforces the floor via ``ge=`` so a sub-3
# value returns 422 with a clear minimum-is-3 message.
_MAX_CONCURRENT_RUNS_MIN = 3
_MAX_CONCURRENT_RUNS_DESCRIPTION = (
    f"Minimum {_MAX_CONCURRENT_RUNS_MIN} — slack for the unified-pipeline "
    "phase transition and cancel-with-rollback cleanup overlaps."
)
_COLLECT_STATISTICS_DESCRIPTION = (
    "Anonymous usage statistics for product improvement. "
    "No sensitive information is collected."
)


class AgentConfigIn(BaseModel):
    notebook_path: str
    max_concurrent_runs: int = Field(
        default=_MAX_CONCURRENT_RUNS_MIN,
        ge=_MAX_CONCURRENT_RUNS_MIN,
        description=_MAX_CONCURRENT_RUNS_DESCRIPTION,
    )
    collect_vibe_run_statistics: bool = Field(
        default=False,
        description=_COLLECT_STATISTICS_DESCRIPTION,
    )

class AgentConfigOut(BaseModel):
    id: str
    notebook_path: str
    job_id: Optional[int]
    job_name: str
    # ``deployment_catalog`` is the DB column name (unchanged); ``metamodel_catalog``
    # is its concern-A vocabulary rename exposed alongside it (see core._catalogs).
    # Both carry the same value. ``deployment_catalog`` STAYS for the FE surfaces
    # that still read it (what-you-submitted, installation-drift-dialog); the
    # after-validator below mirrors it into ``metamodel_catalog`` so callers that
    # build this via ``**cfg.model_dump()`` (which has no metamodel_catalog column)
    # still get the field populated.
    deployment_catalog: str
    metamodel_catalog: str = ""
    warehouse_id: str
    max_concurrent_runs: int = Field(
        default=_MAX_CONCURRENT_RUNS_MIN,
        ge=_MAX_CONCURRENT_RUNS_MIN,
        description=_MAX_CONCURRENT_RUNS_DESCRIPTION,
    )
    collect_vibe_run_statistics: bool = Field(
        default=False,
        description=_COLLECT_STATISTICS_DESCRIPTION,
    )
    created_at: datetime
    updated_at: datetime
    # Pre-built workspace URL for the persistent agent job — backend has the
    # workspace host via Dependencies.Client; FE can't construct it because
    # the app is served from a Databricks Apps proxy origin, not the
    # workspace origin. Empty string when job_id is not yet set.
    job_url: str = ""

    @model_validator(mode="after")
    def _mirror_metamodel_catalog(self) -> "AgentConfigOut":
        # Concern-A rename: metamodel_catalog is the exposed vocabulary for the
        # deployment_catalog column. Mirror the column value unless a caller set
        # it explicitly (it never does today; the DB has no such column).
        if not self.metamodel_catalog:
            self.metamodel_catalog = self.deployment_catalog
        return self

class WarehouseOut(BaseModel):
    id: str
    name: str
    state: str
    cluster_size: str = ""
    warehouse_type: str = ""

class DeploymentCatalogIn(BaseModel):
    deployment_catalog: str


class MetamodelCatalogIn(BaseModel):
    """Concern-A metamodel catalog input for the renamed /config/metamodel-catalog
    endpoints. Same underlying column as DeploymentCatalogIn (deployment_catalog),
    exposed under the concern-A vocabulary."""
    metamodel_catalog: str


class BundledAgentInfoOut(BaseModel):
    """Describes the vibe-modelling-agent notebook bundled inside the app wheel.

    The first-run gate surfaces this so admins can install the shipped
    notebook with one click instead of hunting for the right upstream tag.
    """
    available: bool
    pinned_tag: str = ""
    supported_tags: list[str] = []
    file_name: str = ""


class InstallBundledAgentOut(BaseModel):
    """Response from POST /admin/install-bundled-agent.

    `path` is the workspace path the notebook was uploaded to (what the UI
    should then write into AgentConfig.notebook_path).
    """
    path: str
    version: str
    overwritten: bool


class AgentCompatChange(BaseModel):
    """A single known-upstream-change entry for an agent tag.

    Mirrors the dict shape produced by `agent_compat.known_changes_for_tag`
    so the release-monitor CI job and the Settings UI can render identical
    summaries.
    """
    tag: str
    severity: str  # "breaking" | "info"
    area: str
    summary: str


class AgentCompatOut(BaseModel):
    """Agent release-monitor health surface (Surface 2).

    Backs `GET /api/config/agent-compat` and is consumed by the Settings
    card. Checks BOTH version numbers of the latest upstream agent — the
    public `release_version` (the app-agent interface the app pins) and the
    `agent_version` build counter — and produces a three-way `verdict`:

    * `release_incompatible` — upstream shipped a newer RELEASE than the
      app's pinned `SUPPORTED_AGENT_VERSION`. The app's API calls target the
      pinned release and can't adapt, so the user must update the APP
      (`update_app_required=True`). No install is offered.
    * `build_update_available` — same release, newer `agent_version` build
      counter. Same contract, newer build — informational only.
    * `up_to_date` — otherwise.

    The upstream identity is live-read from the canonical repo notebook and
    cached 7 days on the AgentConfig singleton (see `_get_or_create_agent_config`);
    `checked_at` / `check_error` expose that cache's freshness + last error.
    `install_offered` is always False in this phase (install is deferred).
    """
    pinned_version: str
    latest_known_upstream: str
    newer_available: bool
    has_breaking_change: bool
    known_breaking_changes: list[AgentCompatChange] = []
    repo_url: str = (
        "https://github.com/databricks-industry-solutions/"
        "lakehouse-industry-data-models"
    )
    repo_compare_url: str = ""
    # Three-way release/build verdict (Surface 2). ``pinned_release`` mirrors
    # ``pinned_version`` (the release tag); ``pinned_agent_marker`` is the
    # pinned build counter. The ``latest_upstream_*`` fields carry the live
    # (cached) upstream identity, ``None`` when the cache is cold.
    pinned_release: str = ""
    pinned_agent_marker: str = ""
    latest_upstream_release: Optional[str] = None
    latest_upstream_marker: Optional[str] = None
    verdict: str = "up_to_date"  # up_to_date | build_update_available | release_incompatible
    update_app_required: bool = False
    install_offered: bool = False
    checked_at: Optional[datetime] = None
    check_error: Optional[str] = None

# --- GitHub config (ADR D-049) ---

class GithubConfigIn(BaseModel):
    """Installation GitHub publish/browse config. The token is never carried
    here: for OAuth U2M the ``connection_name`` names the UC HTTP connection;
    for the PAT fallback the secret lives in a secret scope."""
    repo_owner: str = ""
    repo_name: str = ""
    auth_mode: str = ""  # '' | 'oauth_u2m' | 'secret_pat'
    connection_name: str = ""
    secret_scope: str = ""
    secret_key: str = ""

class GithubConfigOut(BaseModel):
    repo_owner: str
    repo_name: str
    auth_mode: str
    connection_name: str
    secret_scope: str
    secret_key: str

# --- Business ---

class BusinessIn(BaseModel):
    # Business.name flows into Delta SQL WHERE/UPDATE clauses via f-strings in
    # progress_tracker and model_sync (properly escaped at the call site, but
    # defence-in-depth: reject names with characters that can't legitimately
    # appear in a business name). Pattern: starts with alphanumeric, continues
    # with alphanumeric / space / underscore / hyphen / ampersand / dot / paren
    # / comma / apostrophe for natural-language names; 1-128 chars.
    name: str = Field(
        min_length=1,
        max_length=128,
        pattern=r"^[A-Za-z0-9][A-Za-z0-9 _\-&.,'()]{0,127}$",
    )
    # The ≤2k business SUMMARY → the agent's ``business_description`` widget
    # (the industry / complexity-tier seed). Capped at 2000 because that widget
    # is inline-only (hard 2048-char Databricks notebook_params limit, no Volume
    # spill). Non-empty after trim — the agent hard-fails an empty description.
    # The full detailed description goes in ``business_vibes`` (below).
    description: str = Field(min_length=1, max_length=2000)
    # The full, arbitrarily-long detailed description (Markdown). Routed to the
    # agent's ``model_vibes`` channel on the initial run (spills to a UC Volume
    # file when large). Optional — a summary alone can seed a model.
    business_vibes: str = ""
    industry_alignment: str = ""
    # ADR D-046/D-047. ``kind`` discriminates business vs industry (an industry
    # is a ``businesses`` row with ``kind='industry'``); ``sector_id`` is the
    # taxonomy placement. Both default to a plain business for back-compat.
    kind: BusinessKind = BusinessKind.BUSINESS
    sector_id: Optional[str] = None

    @field_validator("description")
    @classmethod
    def _description_not_whitespace(cls, v: str) -> str:
        return validate_business_description(v)

class BusinessOut(BaseModel):
    id: str
    name: str
    description: str
    business_vibes: str = ""
    industry_alignment: str
    # ADR D-046/D-047/D-050. ``kind`` discriminates business vs industry;
    # ``sector_id`` is the taxonomy placement; ``source_industry_id`` +
    # ``source_version`` carry kickstart provenance (null for non-kickstarted).
    kind: BusinessKind = BusinessKind.BUSINESS
    sector_id: Optional[str] = None
    source_industry_id: Optional[str] = None
    source_version: Optional[int] = None
    # ADR D-049: the repo path an industry was downloaded from; pre-fills the
    # publish dialog's editable bundle-root. NULL for non-downloaded businesses.
    source_repo_path: Optional[str] = None
    created_at: datetime
    updated_at: datetime

class BusinessListOut(BaseModel):
    id: str
    name: str
    industry_alignment: str
    kind: BusinessKind = BusinessKind.BUSINESS
    sector_id: Optional[str] = None
    source_industry_id: Optional[str] = None
    source_version: Optional[int] = None
    model_count: int = 0
    downloaded_scopes: list[str] = []
    created_at: datetime

# --- Business Context ---

class BusinessContextIn(BaseModel):
    version_label: str = ""
    context_json: str = "{}"
    conventions_json: str = "{}"
    is_active: bool = True

class BusinessContextOut(BaseModel):
    id: str
    business_id: str
    version_label: str
    context_json: str
    conventions_json: str
    is_active: bool
    created_at: datetime

# --- Model Version ---

class ModelVersionOut(BaseModel):
    id: str
    business_id: str
    version: int
    status: ModelStatus
    deployment_status: DeploymentStatus
    base_version_id: Optional[str]
    vibe_instructions: str
    context_id: Optional[str]
    confidence_score: Optional[float]
    scope: str = ""
    uc_catalog: str
    completion_date: Optional[datetime]
    # Post-run sync state, surfaced so the UI can render a banner when
    # something silently failed downstream of the agent's terminal-success
    # event. ``ok`` (default) is the happy path; any other value pairs with a
    # human-readable hint in ``sync_error_text``. Notably ``sync_empty`` covers
    # both G1 (no Volume + no Delta) and G2 (0-domain payload) — a resync won't
    # help — versus ``incomplete_metadata`` (data found, write failed; resync
    # may recover). See db_models.ModelVersion for the full value set.
    sync_state: str = "ok"
    sync_error_text: Optional[str] = None
    # Import provenance — populated when the version was imported from a
    # Volume (a sync, not a run). NULL for agent-produced versions.
    import_source_path: Optional[str] = None
    imported_at: Optional[datetime] = None
    # Version provenance stamped from the model.json envelope at sync/import
    # time. ``agent_version`` is the agent-logic counter (``4.x.y``);
    # ``release_version`` is the public/compat release identity (``0.8.0``).
    # NULL for pre-existing rows and Delta-only payloads.
    agent_version: Optional[str] = None
    release_version: Optional[str] = None
    created_at: datetime


class InstallationStatusOut(BaseModel):
    """Catalog-vs-Lakebase drift snapshot for a single ``ModelVersion``.

    The UI polls this on the model-version Overview to detect cases
    where Lakebase says "Installed" but the underlying physical schemas
    have been dropped externally (DBA, sibling vibe-iterate run with
    different schema layout, etc.). When ``in_sync == False`` the UI
    pops a non-dismissible reconcile dialog.

    ``in_sync`` is ``Optional`` — ``None`` means the probe was skipped
    (no catalog/domains to check, or the catalog listing call failed;
    see ``skipped_reason``) and is deliberately distinct from ``True``
    ("checked, and it's fine"). A skipped probe must never read as
    healthy.
    """
    version_id: str
    deployment_catalog: str
    lakebase_says_installed: bool
    expected_schemas: list[str]
    found_schemas: list[str]
    missing_schemas: list[str]
    catalog_present: bool
    in_sync: Optional[bool]
    checked_at: datetime
    skipped_reason: Optional[str] = None


class ReconcileInstallationOut(BaseModel):
    """Result of a 3-way reconcile (catalog ↔ Lakebase) for a version."""
    version_id: str
    previous_deployment_status: str
    new_deployment_status: str
    schemas_present: list[str]
    schemas_missing: list[str]
    notes: list[str]

# --- Run ---

class RunIn(BaseModel):
    # ``extra="forbid"`` rejects any unknown body field with HTTP 422 so
    # stale clients sending the legacy ``business_id`` (now URL-only) or
    # any other typo surface in CI rather than getting silently dropped
    # into a Frankenstein run-state.
    model_config = ConfigDict(extra="forbid")

    # Spec §8: ``intent`` is the canonical field describing what the user
    # wants this run to accomplish. ``business_id`` is NOT a body field —
    # it is sourced from the URL path on every run-related route and
    # threaded into helpers as a separate parameter.
    intent: Intent = Intent.NEW_BASE_MODEL
    version_id: Optional[str] = None
    parent_version_id: Optional[str] = None
    context_id: Optional[str] = None
    catalog: str = ""
    # ``deployment_catalog`` was added on the request body during the Phase 4
    # wirer rebases as a synonym for ``catalog`` (some test agents and curl
    # callers used one name, the frontend used the other). Keep both fields
    # accepted on the wire — the validator below normalises ``catalog`` to be
    # the canonical source of truth — but new clients should send ``catalog``.
    # This avoids the silent-fail mode where ``deployment_catalog`` was set
    # but the factory only read ``catalog`` (Phase 4.5 bug 2).
    deployment_catalog: str = ""

    @model_validator(mode="after")
    def _normalize_catalog_aliases(self):
        """Allow ``deployment_catalog`` as a deprecated alias for ``catalog``.
        If only the alias is set, copy it onto ``catalog`` so downstream
        readers (DAG factories, route handlers) see a single canonical
        field."""
        cat = (self.catalog or "").strip()
        alias = (self.deployment_catalog or "").strip()
        if not cat and alias:
            self.catalog = alias
        return self
    scope: Optional[str] = None
    version_int: Optional[int] = None
    sample_count: Optional[int] = None
    vibe_instructions: str = ""
    model_size: str = "small model"
    generate_samples: bool = False
    business_context_path: str = ""
    business_context_text: str = ""
    # Convention overrides (None = use defaults from map_run_params_to_widgets)
    naming_convention: Optional[str] = None
    primary_key_suffix: Optional[str] = None
    # Legacy single schema_prefix — still used for non-unified ops (vibe/shrink/
    # enlarge/install/etc). For the unified new-base-model pipeline the
    # per-scope `ecm_schema_prefix` / `mvm_schema_prefix` take over.
    schema_prefix: Optional[str] = None
    # Per-scope schema prefixes for the unified ECM→MVM pipeline (#122).
    # When omitted the router derives defaults from `cataloging_style`:
    #   - One Catalog → ecm_schema_prefix="ecm_", mvm_schema_prefix="mvm_"
    #   - Catalog per Division/Domain → both empty (per-scope catalogs
    #     already isolate ECM from MVM so prefixing would be redundant).
    ecm_schema_prefix: Optional[str] = None
    mvm_schema_prefix: Optional[str] = None
    schema_suffix: Optional[str] = None
    tag_prefix: Optional[str] = None
    tag_suffix: Optional[str] = None
    table_id_type: Optional[str] = None
    boolean_format: Optional[str] = None
    date_format: Optional[str] = None
    timestamp_format: Optional[str] = None
    cataloging_style: Optional[str] = None
    catalog_prefix: Optional[str] = None
    catalog_suffix: Optional[str] = None
    org_divisions: Optional[str] = None
    business_domains: Optional[str] = None
    classification_levels: Optional[str] = None
    housekeeping_columns: Optional[str] = None
    history_tracking_columns: Optional[str] = None
    # Agent-proposed next-vibe IDs the user picked from the base version's
    # structured agent VibeInput rows (the VibeInput.id uuids). Validated
    # against those rows and recorded as RunNextVibeLink rows for audit; their
    # text is NOT folded into the run instructions.
    next_vibe_ids: list[str] = []
    # Selected VibeInput ids — the sole source of run instructions. The server
    # compiles them via compile_inputs and dispatches the resulting markdown
    # through the vibe_instructions widget.
    input_ids: list[str] = []

class WatchdogState(str, Enum):
    """D-09 user-visible watchdog state, derived from Run.status + warm-up."""
    WARMING_UP = "warming_up"
    ARMED = "armed"
    TRIPPED_STALE = "tripped_stale"
    TRIPPED_FAILED = "tripped_failed"
    DISARMED = "disarmed"


class RunOut(BaseModel):
    id: str
    business_id: str
    version_id: Optional[str]
    # Spec §8: durable label for "what does the user want this run to
    # accomplish". Empty string for runs created before the wirer landed.
    intent: str = ""
    status: RunStatus
    databricks_run_id: Optional[int]
    vibe_session_id: Optional[str] = None
    run_page_url: Optional[str] = None
    progress_percent: int
    progress_message: str
    error_message: str
    parameters_json: str
    vibe_instructions_text: str = ""
    vibe_instructions_volume_path: str = ""
    # The business context text the user typed at run-creation. Persisted
    # on Run.business_context_text (added in migration 0.2.0). Empty for
    # legacy runs and ops that don't carry user-typed context.
    business_context_text: str = ""
    started_at: Optional[datetime]
    completed_at: Optional[datetime]
    created_at: datetime
    # --- D-09 user-visible watchdog signals (plan task #51) ---
    # Derived: see backend.router._build_run_out for the watchdog_state
    # mapping; warm-up countdown reaches 0 once the watchdog is armed.
    watchdog_state: WatchdogState = WatchdogState.DISARMED
    watchdog_warm_up_seconds_remaining: int = 0
    # Persisted: tracker writes `last_jobs_api_state` and `last_poll_error`
    # to the Run row on every poll iteration. Empty strings when the
    # tracker has not yet seen a Jobs API call / has just succeeded.
    last_jobs_api_state: str = ""
    last_poll_error: str = ""
    # Derived: seconds since `started_at` (or `created_at` when the run
    # never reached the launched-tracker step). Rounded down.
    elapsed_seconds: int = 0
    # Spec §2.4 + §8: ``warnings`` is a non-optional list — empty on the
    # trivial happy path, populated when the validator emitted
    # warning-severity issues. Each entry mirrors the ``Issue`` envelope
    # used by ``POST /runs/validate`` and the 400 blocker payload:
    # ``{"field_path", "step_index", "message", "severity"}``.
    warnings: list[dict] = []
    # Agent-emitted Version Resolution events for this run (auto-collision
    # resolves). Empty on the happy path. Derived from the run's
    # RunProgressEvent rows — see ``backend.version_resolution_parser``.
    version_resolutions: list["VersionResolutionOut"] = []


class VersionResolutionOut(BaseModel):
    """Surface row for a single agent-emitted Version Resolution event.

    The agent emits this when its pre-allocated output version collides
    with an existing artifact on Volume and it auto-bumps to a higher
    ordinal. Surfaced on the run-detail page so the user can see e.g.
    "Requested v1 → resolved v3 (auto-collision-resolved)".
    """
    target_scope: str
    original_target: int
    new_target: int


class RunListOut(BaseModel):
    id: str
    business_id: str
    intent: str = ""
    status: RunStatus
    progress_percent: int
    started_at: Optional[datetime]
    completed_at: Optional[datetime]
    created_at: datetime


class RunLineageVersionOut(BaseModel):
    id: str
    version: int
    scope: str = ""
    status: ModelStatus
    deployment_status: DeploymentStatus


class RunLineageOut(BaseModel):
    """Lineage links for a single run.

    - `source_version`: the BASE this run branched from (vibe/shrink/enlarge).
    - `generated_version`: the version this run produced, if any (model-producing ops).
    - `operates_on_version`: the version this run targets (install/uninstall/samples).
    """
    run_id: str
    intent: str
    business_id: str
    source_version: Optional[RunLineageVersionOut] = None
    generated_version: Optional[RunLineageVersionOut] = None
    operates_on_version: Optional[RunLineageVersionOut] = None

# --- Run Progress Event ---

class ProgressEventOut(BaseModel):
    id: str
    run_id: str
    step_id: int
    event_seq: Optional[int]
    stage_name: str
    step_name: str
    status: str
    message: str
    progress_increment: float
    result_json: str
    created_at: datetime

# --- Run Artifact ---

class RunArtifactOut(BaseModel):
    id: str
    # Nullable since v_0_5_0 (imports are syncs, not runs — there is no
    # parent Run when the indexer writes rows for an imported ModelVersion).
    # Agent-produced runs still carry a real run_id; only the import path
    # leaves it NULL.
    run_id: Optional[str] = None
    model_version_id: Optional[str] = None
    artifact_type: str
    file_path: str
    created_at: datetime


# --- Run Operation (DAG step persistence) ---


class RunOperationOut(BaseModel):
    """Single ``RunOperation`` row exposed via ``GET /runs/{id}/operations``.

    The UI's "what step are we on" pipeline reads from this — see
    ``docs/orchestrator-design.md`` §5.2 + §8. Step ordering is by
    ``step_index`` ascending; the orchestrator persists rows on
    ``Orchestrator.start()`` and updates lifecycle fields as each op
    transitions.
    """

    id: str
    run_id: str
    step_index: int
    operation_name: str
    status: str
    databricks_run_id: Optional[int] = None
    # Each phase dispatches its own job run, so the per-phase URL is
    # built from the phase's own ``databricks_run_id`` — see
    # ``_build_dbx_run_url`` in ``routes/_helpers.py``.
    run_page_url: Optional[str] = None
    parent_version_id: Optional[str] = None
    output_version_id: Optional[str] = None
    # Natural-key affordance for the UI's "→ v1 ECM" link on the Phase
    # row — populated from the linked ModelVersion's
    # ``(version, scope, business_id)`` so the label is human-meaningful
    # and the URL points at the canonical model version page (#49).
    output_version_label: Optional[str] = None
    output_version_url: Optional[str] = None
    error_message: str = ""
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    created_at: datetime
    # The exact widget map this op's dispatch() sent to `jobs.run_now()`
    # (e.g. `data_model_scopes`, `deployment_catalog`) — the durable
    # answer to "what did we actually dispatch," verifiable without
    # going to the Databricks Jobs API directly. Empty for ops that
    # dispatched before this field existed, or that don't launch a job.
    dispatched_widgets: dict = {}


# --- Run validation (live form feedback) ---


class IssueOut(BaseModel):
    """Single validation finding for ``POST /runs/validate`` /
    ``POST /runs`` (per spec §2.4 + §2.4.1).

    ``severity`` distinguishes ``"warning"`` (soft — UI surfaces a
    "Submit anyway" confirmation, run is still created) from
    ``"blocker"`` (hard — ``POST /runs`` 400s; ``POST /runs/validate``
    flags the offending field inline).
    """

    field_path: str
    step_index: int
    message: str
    severity: str


class ValidateRunOut(BaseModel):
    """Response shape for ``POST /runs/validate`` (spec §8).

    Does NOT create a Run row. The same validator powers ``POST /runs``;
    blockers there reject with 400, warnings flow through.
    """

    warnings: list[IssueOut] = []
    blockers: list[IssueOut] = []


# --- Cancel-with-rollback ---


class CancelOpAppliedOut(BaseModel):
    """One reverse-op the orchestrator successfully replayed during
    ``POST /runs/{id}/cancel-with-rollback`` (spec §6.3).

    ``operation_name`` is the canonical orchestrator-driven label
    (``RunOperation.operation_name``). ``kind`` carries the legacy
    rollback-plan op kind (``delete_model_version`` /
    ``uninstall_schema`` etc.) so existing UI / tests that read
    ``op.kind`` keep working through Phase 4's transition window.
    """

    model_config = {"extra": "allow"}

    operation_name: str = ""
    kind: str = ""


class CancelOpFailureOut(BaseModel):
    """One reverse-op that failed; rollback halts at the first such
    failure and the run lands in ``rolled_back_failed``."""

    op: dict = Field(default_factory=dict)
    error: str = ""


class CancelWithRollbackOut(BaseModel):
    """Response shape for ``POST /businesses/{bid}/runs/{rid}/cancel-with-rollback``."""

    ok: bool
    status: str
    ops_applied: list[CancelOpAppliedOut] = []
    op_failures: list[CancelOpFailureOut] = []


# --- Resume (admin) ---


class ResumeRunOut(BaseModel):
    """Response shape for ``POST /businesses/{bid}/runs/{rid}/resume``."""

    ok: bool
    status: str
    next_phase: str = ""
    databricks_run_id: Optional[int] = None
    error: str = ""


# --- Health ---


class HealthOut(BaseModel):
    """Response shape for ``GET /health``.

    Surfaces ``in_flight_runs`` so the deploy script can refuse to push
    a new wheel while runs are active (atomic-replace App containers
    can't hand off in-flight pollers cleanly).
    """

    ok: bool = True
    in_flight_runs: int = 0

# --- Model Explorer ---

class ChangeStatus(str, Enum):
    UNCHANGED = "unchanged"
    NEW = "new"
    MODIFIED = "modified"
    DELETED = "deleted"

class AttributeOut(BaseModel):
    # Stable per-version UUID; empty for previous-version-only (deleted)
    # placeholders that carry no current DB row.
    id: str = ""
    name: str
    column_name: str
    type: str
    description: str
    business_glossary_term: str = ""
    tags: str = ""
    value_regex: str = ""
    foreign_key_to: str = ""
    references: str = ""
    is_primary_key: bool = False
    is_foreign_key: bool = False
    change_status: ChangeStatus = ChangeStatus.UNCHANGED

class ProductSummaryOut(BaseModel):
    # Stable internal key (per-version UUID) + the human key. ``id`` is empty
    # for products that exist only in a previous version (deleted-product
    # placeholders carry no current DB row); ``fqn`` is the canonical
    # "<domain>.<product>" (formed at the explorer serialization boundary) and
    # is always present.
    id: str = ""
    fqn: str = ""
    name: str
    table_name: str
    description: str
    type: str = ""
    data_type: str = ""
    primary_key: str = ""
    subdomain: str = ""
    reference: str = ""
    attribute_count: int = 0
    fk_count: int = 0
    fk_targets: list[str] = []
    change_status: ChangeStatus = ChangeStatus.UNCHANGED

class ProductDetailOut(BaseModel):
    # Stable per-version UUID + canonical "<domain>.<product>" human key.
    id: str = ""
    fqn: str = ""
    name: str
    table_name: str
    description: str
    type: str = ""
    data_type: str = ""
    primary_key: str = ""
    reference: str = ""
    domain_name: str = ""
    attributes: list[AttributeOut] = []

class SubdomainSummaryOut(BaseModel):
    # Stable per-version UUID; empty when the model dict carries no DB id (the
    # subdomain rollup is name-derived from products on the Volume-fallback path).
    id: str = ""
    name: str
    product_count: int = 0

class DomainSummaryOut(BaseModel):
    # Stable per-version UUID; empty for previous-version-only (deleted)
    # placeholders that carry no current DB row.
    id: str = ""
    name: str
    division: str = ""
    description: str = ""
    database_name: str = ""
    references: str = ""
    product_count: int = 0
    subdomains: list[SubdomainSummaryOut] = []
    change_status: ChangeStatus = ChangeStatus.UNCHANGED

class DomainDetailOut(BaseModel):
    name: str
    division: str = ""
    description: str = ""
    database_name: str = ""
    references: str = ""
    products: list[ProductSummaryOut] = []

class ModelSummaryOut(BaseModel):
    name: str
    version: int
    description: str = ""
    industry_alignment: str = ""
    core_business_processes: str = ""
    vibe_modeling_instructions: str = ""
    domain_count: int = 0
    subdomain_count: int = 0
    product_count: int = 0
    attribute_count: int = 0
    fk_count: int = 0
    confidence_score: Optional[float] = None
    # Product-level review progress (0..1): reviewed ÷ review-needed products.
    # ``no_review_needed`` products are excluded from review_needed. Resets per
    # version (ProductReview FKs straight to this version's product rows).
    review_pct: float = 0.0
    reviewed_count: int = 0
    review_needed_count: int = 0
    no_review_needed_count: int = 0
    domains: list[DomainSummaryOut] = []

class ModelSearchHitOut(BaseModel):
    """One model-wide search result.

    ``type`` names the element kind; the ``*_name`` fields carry exactly what
    URL navigation needs (domain page for a domain/product hit, tabular product
    page for an attribute/column hit). ``label`` is the matched element name and
    ``sublabel`` a breadcrumb-ish context string for the palette secondary line.
    """

    type: str  # "domain" | "product" | "attribute"
    domain_name: str
    product_name: Optional[str] = None
    attribute_name: Optional[str] = None
    label: str
    sublabel: str = ""

# --- User Preferences ---

class UserPreferenceOut(BaseModel):
    key: str
    value: str
    updated_at: datetime

class UserPreferenceIn(BaseModel):
    value: str


class DeleteVersionOut(BaseModel):
    """Response shape for ``DELETE /businesses/{id}/versions/{vid}``.

    The route always deletes the target version's rows (Lakebase + Delta
    ``_metamodel.*``); when ``reinstall_previous=true`` it also dispatches
    an uninstall→install orchestrator DAG to revive the prior version.
    """

    deleted_version: int
    # ``previous_version`` is the same-scope predecessor's version number
    # (the one a follow-up reinstall would target). NULL when the deleted
    # row was the only same-scope version.
    previous_version: Optional[int] = None
    # Populated only when ``reinstall_previous=true`` and the orchestrator
    # dispatch succeeded.
    run_id: Optional[str] = None
    reinstall_dispatched: bool = False
    # True iff the agent's ``_metamodel.business`` table actually carried a
    # row for this version that we cleaned. False for import-only versions
    # that were never written to Delta.
    metamodel_rows_cleaned: bool = False
    message: str

class VersionTreeOut(BaseModel):
    id: str
    version: int
    status: str
    deployment_status: str = "draft"
    base_version_id: Optional[str] = None
    vibe_instructions: str = ""
    confidence_score: Optional[float] = None
    scope: str = ""
    created_at: datetime
    is_base: bool = True

# --- ER Diagram ---

class DiagramNodePort(BaseModel):
    """A column represented as a port on a table node."""

    id: str
    name: str
    is_pk: bool = False
    is_fk: bool = False
    type: str = ""
    description: str = ""
    fk_target: str = ""  # "domain.product.column" if FK

class DiagramNode(BaseModel):
    """A product/table positioned in the diagram."""

    id: str  # "domain.product"
    domain: str
    product: str
    table_name: str
    product_type: str = ""  # Master/Transactional/Reference/Association
    description: str = ""
    x: float = 0
    y: float = 0
    width: float = 0
    height: float = 0
    columns: list[DiagramNodePort] = []
    column_count: int = 0
    fk_count: int = 0
    change_status: ChangeStatus = ChangeStatus.UNCHANGED

class DiagramEdge(BaseModel):
    """A foreign key relationship between two table nodes."""

    id: str
    source_node: str  # "domain.product"
    source_column: str
    target_node: str  # "domain.product"
    target_column: str
    # Focal-view routing (Increment 1). Additive + backward-compatible: empty
    # ``waypoints`` means "no backend routing — the frontend falls back to its
    # smoothstep path" (overview + keys/all focal). When non-empty these are
    # absolute polyline points (x, y) from the source anchor to the target
    # anchor; the frontend draws the polyline directly and self-orients the
    # crow's-foot markers, so no separate anchor side/offset is emitted.
    waypoints: list[tuple[float, float]] = []

class DiagramDomainGroup(BaseModel):
    """A domain boundary rectangle in the diagram."""

    id: str  # "domain:name"
    domain: str
    division: str = ""
    x: float = 0
    y: float = 0
    width: float = 0
    height: float = 0
    is_external: bool = False  # True for related domains in domain-specific view
    product_count: int = 0

class DiagramLayoutOut(BaseModel):
    """Complete positioned diagram layout returned by the backend."""

    nodes: list[DiagramNode] = []
    edges: list[DiagramEdge] = []
    groups: list[DiagramDomainGroup] = []
    domain_filter: Optional[str] = None
    show_columns: bool = False
    total_products: int = 0
    total_edges: int = 0


class DiagramPendingOut(BaseModel):
    """202 response body when a diagram layout is still computing.

    Carries a heartbeat timestamp + queue position so the frontend can show
    ``we're alive, you're #3 in queue`` instead of an opaque spinner.
    """

    status: str = "computing"
    key: str
    # ms-epoch of the most recent heartbeat signal for this key (or the request
    # time if the job hasn't emitted progress yet). Lets the UI display how
    # stale the signal is and detect truly-wedged workers.
    last_heartbeat_ms: int = 0
    # 1-indexed position of this key in the prefetch queue. ``None`` when the
    # key is no longer tracked (shouldn't happen on the 202 path, but kept
    # nullable so the contract is robust).
    queue_position: Optional[int] = None
    # Total number of pending jobs the prefetch pool knows about.
    total_in_queue: int = 0


class DomainConnectivityOut(BaseModel):
    """A pair of connected domains and the FK count between them."""
    source_domain: str
    target_domain: str
    fk_count: int


class RelationshipAnalysisOut(BaseModel):
    """Aggregated FK statistics and domain connectivity for a model version."""
    total_fk_count: int = 0
    cross_domain_fk_count: int = 0
    intra_domain_fk_count: int = 0
    domain_connectivity: list[DomainConnectivityOut] = []


# --- Feedback ---

class FeedbackContext(BaseModel):
    """Captured view state at the moment feedback was submitted.

    Kept as a structured model for type safety; serialized to context_json in DB.
    """
    context_version: int = 1
    view_mode: str = ""  # "er" | "ontology" | "explorer" | "report" | "domain_tables"
    domain_filter: Optional[str] = None
    selected_node_id: Optional[str] = None  # "domain.product"
    selected_edge_id: Optional[str] = None  # "fk:..."
    column_mode: Optional[str] = None  # "hide" | "keys" | "all"
    hide_cross_domain: bool = False


# --- Vibe Inputs (durable input content + anchoring) ---

class VibeInputIn(BaseModel):
    """Input for creating a vibe input.

    ``author`` is resolved from auth headers by the create endpoint (Task 5);
    it is accepted as a field so In→DB contract coverage maps to the new
    ``author`` column. ``version_id`` and the element ids are transient anchor
    fields — the create endpoint materializes the origin ``VibeInputContextLink``
    from them; they are not columns on ``VibeInput``.
    """
    text: str
    origin: VibeInputOrigin = VibeInputOrigin.USER
    priority: VibeInputPriority = VibeInputPriority.MEDIUM
    confidence_score: Optional[float] = None
    author: str = ""
    version_id: Optional[str] = None
    domain_id: Optional[str] = None
    subdomain_id: Optional[str] = None
    product_id: Optional[str] = None
    attribute_id: Optional[str] = None
    fk_link_id: Optional[str] = None
    # Name-based view selection from "Add Feedback" surfaces (the FE holds
    # names, not DB ids). When no explicit element id is given, the create
    # endpoint resolves this against version_id to the anchor element ids.
    origin_context: Optional[FeedbackContext] = None


class VibeInputPatchIn(BaseModel):
    """Edit text/priority. Status + consumed + selected_for_run are driven by
    dedicated endpoints, not free PATCH."""
    text: Optional[str] = None
    priority: Optional[VibeInputPriority] = None


class VibeInputSelectionIn(BaseModel):
    """Bulk set the run-selection flag on a set of inputs. One body serves
    both the single-card toggle (1-element list) and select-all-under-a-tree-
    branch (N-element list). Consumed and out-of-business ids are skipped."""
    input_ids: list[str]
    selected: bool


class VibeInputAnchorOut(BaseModel):
    """Read-only, head-version anchor projection for an input, hydrated by
    listVibeInputs so the FE section tree can render element-named headers
    without an N+1 of /links calls. The durable anchor lives on
    VibeInputContextLink; this is a derived view and is never persisted.

    ``level == "model_wide"`` (link present on the head version but unscoped,
    empty ``path``) is DISTINCT from a null ``VibeInputOut.anchor`` (no link on
    the head version at all).
    """
    level: str
    domain_id: Optional[str] = None
    domain_name: Optional[str] = None
    subdomain_id: Optional[str] = None
    subdomain_name: Optional[str] = None
    product_id: Optional[str] = None
    product_name: Optional[str] = None
    attribute_id: Optional[str] = None
    attribute_name: Optional[str] = None
    fk_link_id: Optional[str] = None
    fk_label: Optional[str] = None
    path: list[str] = []


class VibeInputOut(BaseModel):
    id: str
    business_id: str
    origin: VibeInputOrigin
    author: str
    text: str
    # Agent next-vibe classification; null for origin=user inputs.
    category: Optional[NextVibeCategory] = None
    priority: VibeInputPriority
    confidence_score: Optional[float]
    consumed: bool
    selected_for_run: bool
    status: VibeInputStatus
    deprecated_by: Optional[str]
    created_at: datetime
    updated_at: datetime
    anchor: Optional[VibeInputAnchorOut] = None


class VibeInputContextLinkIn(BaseModel):
    input_id: str
    version_id: str
    domain_id: Optional[str] = None
    subdomain_id: Optional[str] = None
    product_id: Optional[str] = None
    attribute_id: Optional[str] = None
    fk_link_id: Optional[str] = None
    is_origin: bool = False


class VibeInputContextLinkOut(BaseModel):
    id: str
    input_id: str
    version_id: str
    domain_id: Optional[str]
    subdomain_id: Optional[str]
    product_id: Optional[str]
    attribute_id: Optional[str]
    fk_link_id: Optional[str]
    is_origin: bool
    needs_link_review: bool
    reviewed_by: Optional[str]
    reviewed_at: Optional[datetime]
    created_at: datetime


class RunInputLinkOut(BaseModel):
    run_id: str
    input_id: str
    created_at: datetime


class SubdomainOut(BaseModel):
    id: str
    version_id: str
    domain_id: str
    name: str
    previous_element_id: Optional[str]
    created_at: datetime


class RunElementLineageOut(BaseModel):
    """Wire shape for a rename/merge/delete lineage edge (Task 4)."""
    id: str
    run_id: str
    version_id: str
    element_type: str
    change_kind: str
    old_element_id: Optional[str]
    new_element_id: Optional[str]
    old_fqn: str
    new_fqn: str
    reason: str
    created_at: datetime


class ReviewMarkIn(BaseModel):
    """Body for a review mark at any granularity (product / domain / subdomain).

    The target element id rides the URL path; this carries only the chosen
    ``state``. For aggregation grains (domain / subdomain) the state fans out
    onto the product rows beneath the target (the cascade write semantics)."""
    state: ReviewState = ReviewState.REVIEWED


class ProductReviewOut(BaseModel):
    """Effective review state of a single product.

    ``is_explicit`` distinguishes a stored user mark (``product_reviews`` row)
    from a computed default. ``id``/``reviewer``/``reviewed_at`` are populated
    only for explicit rows (empty/None for computed defaults).
    ``product_name``/``fqn`` make a review row self-describing (the human key
    alongside the stable ``product_id`` UUID) so the FE never renders a raw
    UUID; ``fqn`` is the canonical "<domain>.<product>"."""
    id: str = ""
    version_id: str
    product_id: str
    product_name: str = ""
    fqn: str = ""
    state: ReviewState
    reviewer: str = ""
    reviewed_at: Optional[datetime] = None
    is_explicit: bool = False


class ReviewProgressOut(BaseModel):
    """Product-level review progress for a scope (model or a domain).

    ``review_pct`` = reviewed ÷ review-needed (0.0 when nothing needs review);
    ``no_review_needed`` is excluded from ``review_needed``."""
    version_id: str
    review_pct: float = 0.0
    reviewed: int = 0
    review_needed: int = 0
    no_review_needed: int = 0
    total: int = 0


class DomainReviewProgressOut(BaseModel):
    """Per-domain review rollup (derived; no stored aggregate).

    ``review_pct`` = reviewed ÷ review-needed for the domain's products
    (0.0 when nothing needs review); ``no_review_needed`` is excluded from
    ``review_needed``. ``domain`` carries the domain name (the human key the
    scope tree / focus table render by); ``domain_id`` is the stable UUID."""
    domain_id: str
    domain: str = ""
    review_pct: float = 0.0
    reviewed: int = 0
    review_needed: int = 0
    no_review_needed: int = 0


class ReviewCascadeOut(BaseModel):
    """Result of a cascade mark: how many product rows were written and their
    effective states after the write."""
    version_id: str
    affected: int = 0
    products: list[ProductReviewOut] = []


class NextVibeCategoryCountsOut(BaseModel):
    """Open agent-next-vibe counts per ``NextVibeCategory``.

    One non-negative integer per category; the keys match the enum values so
    the client gets a stable, exhaustive shape regardless of which categories
    are present in the data. ``total`` is their sum (== ``total_open``)."""
    static_analysis: int = 0
    priority_remediation: int = 0
    other: int = 0
    total: int = 0


class NextVibeMetricsOut(BaseModel):
    """next_vibes "expected work" metrics for one scope on a version (T13).

    Sourced from open (active, non-consumed) ``origin=agent_next_vibe``
    ``VibeInput`` rows anchored to the scope via ``VibeInputContextLink``:

    * ``quality_score`` — the Model Quality Score: the **mean** of the open
      agent inputs' ``confidence_score`` in scope, ``None`` when there are no
      scored open inputs. The mean is the version-/domain-level representative
      score (a single 0..1 value the FE renders as the headline metric).
    * ``counts`` — open count broken out by category.
    * ``total_open`` — total open agent inputs in scope (== ``counts.total``).
    * ``has_data`` — ``False`` when there are zero open agent inputs in scope
      (the pre-ingestion default). Lets the FE distinguish "genuinely zero
      expected work" from "the next_vibes source has not been populated yet":
      both degrade to zeros/null, only ``has_data`` tells them apart.

    ``domain_id`` is ``None`` for the model scope; set to the resolved domain
    id for the domain scope. Domain scope counts an input when ANY of its
    anchor links on this version resolves to that domain — directly via
    ``domain_id`` or derived from the product/attribute anchor's product →
    domain map (the same derivation the seeder uses)."""
    version_id: str
    domain_id: Optional[str] = None
    quality_score: Optional[float] = None
    counts: NextVibeCategoryCountsOut = NextVibeCategoryCountsOut()
    total_open: int = 0
    has_data: bool = False


# --- Model Evolution Metrics (T16, "Model Evolution Metrics" epic) ---------

class EvolutionSizeOut(BaseModel):
    """Size tally for the version. Counts are the agent's
    ``model_stats_at_generation`` when present, else derived from the model
    structure. ``avg_attributes_per_product`` is derived; ``unlinked_id_count``
    / ``siloed_count`` are agent-only static-analysis findings (``None`` for
    metadata-less imports)."""
    domain_count: Optional[int] = None
    product_count: Optional[int] = None
    attribute_count: Optional[int] = None
    fk_count: Optional[int] = None
    unlinked_id_count: Optional[int] = None
    siloed_count: Optional[int] = None
    avg_attributes_per_product: Optional[float] = None


class EvolutionQualityOut(BaseModel):
    """Quality signals. ``confidence_score`` is a 0..100 percentage, ``None``
    when the run produced no confidence (ECM, or any unjudged run) — never
    coerced to 0. ``issues_addressed`` / ``issues_not_addressed`` are the
    agent's verified issue-resolution claims for this run."""
    confidence_score: Optional[float] = None
    error_count: Optional[int] = None
    warning_count: Optional[int] = None
    info_count: Optional[int] = None
    issues_addressed: list[str] = []
    issues_not_addressed: list[str] = []


class VersionHistoryEntryOut(BaseModel):
    """One point on the per-version timeline (newest last), for sparklines."""
    version: str = ""
    confidence: Optional[int] = None
    errors: Optional[int] = None
    warnings: Optional[int] = None
    unlinked: Optional[int] = None
    trend: Optional[str] = None
    products: Optional[int] = None
    fks: Optional[int] = None


class EvolutionChangeOut(BaseModel):
    """Change vs the previous version. On a baseline (predecessor-less) version
    ``version_trend == "baseline"`` and every delta/previous_* is ``None`` (no
    predecessor to diff against — a 0 would be misleading). ``version_history``
    is the full timeline regardless (a single entry on a baseline).

    ``model_touched_pct`` is the share (0..100) of the model touched this
    version, normalized by the UNION of both versions
    (``(added+modified+removed) / (current_product_count + removed)``) so it
    stays bounded and a deletion-only version reads above 0. Derived from the
    SAME per-product change diff behind the UI change icons
    (``explorer._compute_diff``); ``None`` on a baseline.

    ``products_added`` / ``products_modified`` / ``products_removed`` are the
    raw change-count breakdown behind that ratio (NEW / MODIFIED / DELETED
    product counts from the same diff); each ``None`` on a baseline."""
    version_trend: Optional[str] = None
    model_touched_pct: Optional[float] = None
    products_added: Optional[int] = None
    products_modified: Optional[int] = None
    products_removed: Optional[int] = None
    confidence_delta: Optional[int] = None
    warnings_delta: Optional[int] = None
    errors_delta: Optional[int] = None
    unlinked_delta: Optional[int] = None
    previous_confidence: Optional[int] = None
    previous_warnings: Optional[int] = None
    previous_errors: Optional[int] = None
    previous_unlinked: Optional[int] = None
    version_history: list[VersionHistoryEntryOut] = []


class EvolutionEffortOut(BaseModel):
    """AI effort/cost for the run that produced this version.
    ``per_model_cost_usd`` maps serving-model name → USD."""
    total_ai_calls: Optional[int] = None
    estimated_input_tokens: Optional[int] = None
    estimated_output_tokens: Optional[int] = None
    estimated_total_cost_usd: Optional[float] = None
    per_model_cost_usd: dict[str, float] = Field(default_factory=dict)
    duration_hours: Optional[float] = None


class EvolutionProvenanceOut(BaseModel):
    """Where the version came from: the agent build tag, the agent's own
    version labels, and the run status."""
    agent_version: Optional[str] = None
    generated_from_version: Optional[str] = None
    target_model_version: Optional[str] = None
    status: Optional[str] = None


class EvolutionMetricsOut(BaseModel):
    """Model-scope evolution metrics for one version (T16).

    Sourced on demand from the version's Volume ``model.json``
    ``_vibe_session_metadata`` block (NOT Lakebase — the sync drops it). Adds
    no migration. Degrades cleanly with data-driven flags so the FE never has
    to fabricate values:

    * ``has_metadata`` — ``False`` when the envelope carried no
      ``_vibe_session_metadata`` (hand-edited / pre-metadata import). The
      ``size`` block still degrades to structure-derived counts; everything
      else is null/empty.
    * ``has_confidence`` — ``False`` for ECM and any run the quality judge
      didn't score. ``quality.confidence_score`` is then ``None``.
    * ``has_predecessor`` — ``False`` on a baseline/first version. The
      ``change`` deltas/previous_* are then ``None`` and ``version_trend`` is
      ``"baseline"``.
    """
    version_id: str
    size: EvolutionSizeOut = EvolutionSizeOut()
    quality: EvolutionQualityOut = EvolutionQualityOut()
    change: EvolutionChangeOut = EvolutionChangeOut()
    effort: EvolutionEffortOut = EvolutionEffortOut()
    provenance: EvolutionProvenanceOut = EvolutionProvenanceOut()
    has_metadata: bool = False
    has_confidence: bool = False
    has_predecessor: bool = False


# --- Vibe Inputs: re-link / review-queue / compile request-response shapes ---

class CarryForwardResultOut(BaseModel):
    """Result of running the re-link tiers across a version (Task 5 §3.4)."""
    version_id: str
    auto_linked: int = 0          # tiers 1+2
    needs_review: int = 0         # tiers 3+4
    deprecated: int = 0           # tier 5
    skipped_existing: int = 0     # already had a link to the target version
    link_ids_needing_review: list[str] = []


class ReanchorIn(BaseModel):
    """Move a flagged link to a user-chosen element on the same version. All
    element ids nullable; all-null = model-wide."""
    domain_id: Optional[str] = None
    subdomain_id: Optional[str] = None
    product_id: Optional[str] = None
    attribute_id: Optional[str] = None
    fk_link_id: Optional[str] = None


class ReviewQueueItemOut(BaseModel):
    link: VibeInputContextLinkOut
    input: VibeInputOut
    proposed_anchor_label: str        # hydrated, e.g. "Domain X › Product Y"
    tier: str                         # "merge_survivor" | "partial_ancestor"


class ReviewQueueOut(BaseModel):
    total: int = 0                    # count of needs_link_review links (progress)
    items: list[ReviewQueueItemOut] = []   # oldest-first; UI processes head-of-queue


class CompileIn(BaseModel):
    """Explicit selection of input ids to serialize. Empty = compile nothing."""
    input_ids: list[str] = []


class CompiledBlockOut(BaseModel):
    """Structured provenance for one included input. Provenance rides as
    metadata, never as inline markers in the markdown."""
    input_id: str
    origin: VibeInputOrigin
    priority: VibeInputPriority
    author: str
    confidence_score: Optional[float]   # null for user inputs; never coerced to 0
    section_path: list[str]             # e.g. ["Domain: Sales", "Product: Orders"]
    text: str


class CompileOut(BaseModel):
    markdown: str = ""                  # the single doc handed to the agent
    blocks: list[CompiledBlockOut] = []
    included_input_ids: list[str] = []  # excludes deprecated/missing
    excluded_input_ids: list[str] = []  # deprecated or not-on-this-version
    excluded_reasons: dict[str, str] = {}  # input_id -> reason


# --- Model Import ---

class BusinessDigest(BaseModel):
    """Business identity + context pulled out of a model.json payload.

    Drives two flows: seeding a brand-new Business on create-by-import,
    and diffing against an existing Business so the user can spot
    misrouted imports before they land.
    """
    business_name: str = ""
    industry_alignment: str = ""
    description: str = ""
    # Agent release that produced the model.json (top-level ``agent_version``;
    # empty for flat/hand-edited files). Surfaced in the import analysis.
    agent_version: str = ""
    # Draft detailed description assembled from the enriched context below —
    # the ``business_vibes`` seed the import pre-fills (editable).
    business_vibes: str = ""
    core_business_processes: str = ""
    data_domains: str = ""
    orgnaization_divisions: str = ""
    common_business_jargons: str = ""
    operational_systems_of_records: str = ""
    industry_governing_body: str = ""
    # Story-1: True when ``industry_alignment`` has no case-insensitive
    # match in the ``industries`` catalog. The Story-1 endpoint
    # auto-creates a stub ``Industry`` row when this is True, mirroring
    # ``initial_sync.py``'s auto-create path. UI surfaces this so the
    # user isn't surprised by silent catalog growth.
    industry_will_be_created: bool = False


class FieldMismatch(BaseModel):
    """A single field where the digest disagrees with the current Business."""
    field: str
    source_value: str
    current_value: str


class BusinessDigestDiff(BaseModel):
    """Diff envelope returned alongside ``ImportAnalyzeOut`` when importing
    into an existing business. ``mismatch_fields`` empty → safe to import
    without the warning panel."""
    digest: BusinessDigest
    mismatch_fields: list[FieldMismatch] = []


class ImportAnalyzeIn(BaseModel):
    """Request to analyze a model.json at a Volume path without importing."""
    volume_path: str


class ImportAnalyzeOut(BaseModel):
    """Result of analyzing a model.json before importing."""
    valid: bool
    inferred_version: str
    action: str  # "import_as_is" | "unsupported"
    message: str
    domain_count: int = 0
    product_count: int = 0
    attribute_count: int = 0
    fk_count: int = 0
    warnings: list[str] = []
    detected_agent_tag: str = ""
    compat_verdict: str = "unknown"
    latest_supported_tag: str = ""
    # Story-1 (create-by-import): populated when the model.json carries a
    # business identity. UI uses this to pre-fill the new-business form.
    business_digest: Optional[BusinessDigest] = None
    # Story-2 (import-into-existing): populated when ``business_id`` is
    # known. ``mismatch_fields`` non-empty → UI shows the warning panel.
    business_digest_diff: Optional[BusinessDigestDiff] = None


class ImportExecuteIn(BaseModel):
    """Request to execute an import. Volume path must match a prior analyze call."""
    volume_path: str
    # Story-2: explicit user opt-in to import even when the model.json's
    # business identity disagrees with the target Business. Server
    # returns 409 when mismatches exist and this flag is False.
    accept_business_mismatch: bool = False


class ImportCreateBusinessAndExecuteIn(BaseModel):
    """Story-1 request: create a Business from the model.json + import it.

    All ``*_override`` fields are optional. When provided they override
    the digest's values before the Business is created; otherwise the
    digest is used as-is.
    """
    volume_path: str
    business_name_override: Optional[str] = None
    industry_alignment_override: Optional[str] = None
    description_override: Optional[str] = None
    # The detailed description (business_vibes) the user reviewed — defaults to
    # the digest's assembled draft when omitted.
    business_vibes_override: Optional[str] = None


class ImportExecuteOut(BaseModel):
    version_id: str
    version: int
    domains: int
    products: int
    attributes: int
    fk_links: int
    warnings: list[str] = []
    detected_agent_tag: str = ""
    compat_verdict: str = "unknown"
    latest_supported_tag: str = ""


class ImportCreateBusinessAndExecuteOut(ImportExecuteOut):
    """Story-1 response: the regular execute envelope plus the new
    business id so the UI can redirect to it."""
    business_id: str


class ArtifactPreview(BaseModel):
    """A single companion artifact that the import will index."""
    path: str
    artifact_type: str
    size_bytes: Optional[int] = None


class ImportPreviewOut(BaseModel):
    """Preview of what an import will actually pull in from a Volume folder.

    Surfaces enough detail for the UI to show users what WILL be
    imported BEFORE they commit, and to warn when the agent's
    next-iteration suggestions can't be reconstructed (no
    ``next_vibes.{txt,json}`` at the source path).
    """
    model_json_found: bool
    next_vibes_status: str  # "txt" | "json" | "missing"
    next_vibes_path: Optional[str] = None
    companion_artifacts: list[ArtifactPreview] = []
    total_artifact_count: int = 0


# --- Next Vibes (agent-proposed follow-up operations) ---

class NextVibeItem(BaseModel):
    """A single agent-proposed follow-up operation.

    Parsed from the agent's `vibes/next_vibes.json` artifact — a big
    `vibe_modeling_instructions` blob split into ordered MUST DO / OPTIONAL
    steps the user can run as the next vibe.
    """
    id: str
    title: str
    description: str = ""
    priority: VibeInputPriority = VibeInputPriority.HIGH


class NextVibesOut(BaseModel):
    model_version_id: str
    items: list[NextVibeItem] = []
    summary: str = ""
    # 0..1 fraction (UI multiplies by 100 for the "%" label). Same
    # convention as ModelVersion.confidence_score and the agent's
    # model.json `confidence_score` field.
    confidence_score: Optional[float] = None
    status: str = ""  # agent's overall health label, e.g. "needs_work" / "healthy"
