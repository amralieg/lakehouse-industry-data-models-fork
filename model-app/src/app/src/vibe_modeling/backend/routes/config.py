"""Application configuration endpoints (`/api/config/*`).

Owns the agent notebook config + version compatibility surface, the
deployment-catalog setting, the warehouse picker, the initial-sync trigger,
and the out-of-band detection / import endpoints. All of these write or
read the singleton `AgentConfig` row (or its near neighbours), so they sit
in one module.
"""

from __future__ import annotations

import logging
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, HTTPException
from sqlmodel import select

from ..._metadata import api_prefix
from ..agent_compat import (
    KNOWN_UPSTREAM_CHANGES,
    is_newer_tag,
    latest_known_upstream_tag,
)
from ..core import Dependencies, resolve_metamodel_catalog
from ..db_models import AgentConfig
from ..models import (
    AgentCompatChange,
    AgentCompatOut,
    AgentConfigIn,
    AgentConfigOut,
    DeploymentCatalogIn,
    GithubConfigIn,
    GithubConfigOut,
    MetamodelCatalogIn,
    WarehouseOut,
)
from ..job_launcher import setup_agent_job
from ._helpers import (
    _build_dbx_job_url,
    _detect_notebook_identity,
    _get_or_create_agent_config,
    _preflight_notebook_access,
    _preflight_notebook_version,
    fetch_upstream_agent_identity,
    require_config,
)

# Canonical upstream repo the release monitor compares against. The compat
# surface reads the agent notebook from here (the previous agent repo is
# retired).
_UPSTREAM_REPO_URL = (
    "https://github.com/databricks-industry-solutions/lakehouse-industry-data-models"
)

# How long a live upstream-identity read is cached on the AgentConfig singleton
# before the next request re-fetches (Surface 2). Seven days keeps the Settings
# page off the GitHub round-trip on the common path while still catching an
# upstream release within a week.
_UPSTREAM_CACHE_TTL = timedelta(days=7)

logger = logging.getLogger(__name__)

router = APIRouter(prefix=api_prefix)


# Tags whose vendored notebooks ship without an embedded `__AGENT_VERSION__` /
# `AGENT_VERSION` / `__version__` marker. For these the reachability check
# downgrades from "warning, can't verify" to "OK, assuming pinned tag" — the
# user has no way to add a marker themselves and we already shipped the exact
# notebook in `src/app/vendored/agent/`. Currently empty: every supported tag
# from v0.6.9 onward (and v0.7.1 in particular) stamps `__AGENT_VERSION__`,
# so the no-marker fallback is unused. Add a tag here only after confirming
# a future upstream release truly has no embedded marker.
_NO_MARKER_TAGS: frozenset[str] = frozenset()


# --- Agent Config ---


@router.get("/config/agent", response_model=AgentConfigOut, operation_id="getAgentConfig")
def get_agent_config(
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
):
    """Get current agent configuration. Lazily seeds the row from env vars on
    first read, so the Settings page sees the install-time defaults even
    before the user has saved anything."""
    cfg = _get_or_create_agent_config(session, config)
    return AgentConfigOut(
        **cfg.model_dump(),
        job_url=_build_dbx_job_url(ws, cfg.job_id),
    )


@router.get("/config/github", response_model=GithubConfigOut, operation_id="getGithubConfig")
def get_github_config(session: Dependencies.Session, config: Dependencies.Config):
    """Get the installation's GitHub publish/browse config (ADR D-049).

    Reads the github_* columns off the AgentConfig singleton. The token is
    never returned (it lives in the UC connection or a secret scope); only the
    pointers (connection name / secret scope+key) are surfaced."""
    from ..sources.github import DEFAULT_REPO_NAME, DEFAULT_REPO_OWNER

    cfg = _get_or_create_agent_config(session, config)
    # OUTPUT-layer effective value: a fresh row is seeded with the defaults, but
    # pre-existing rows may have empty github fields. Fall back to the public
    # industry-models repo (the same repo build_github_connector uses) so the
    # Settings page + source explorer show the source that browsing actually
    # uses, without a read-path write.
    return GithubConfigOut(
        repo_owner=cfg.github_repo_owner or DEFAULT_REPO_OWNER,
        repo_name=cfg.github_repo_name or DEFAULT_REPO_NAME,
        auth_mode=cfg.github_auth_mode,
        connection_name=cfg.github_connection_name,
        secret_scope=cfg.github_secret_scope,
        secret_key=cfg.github_secret_key,
    )


@router.put("/config/github", response_model=GithubConfigOut, operation_id="updateGithubConfig")
def update_github_config(
    data: GithubConfigIn,
    session: Dependencies.Session,
    config: Dependencies.Config,
    _role: Dependencies.BusinessAdminOnly,
):
    """Update the installation's GitHub publish/browse config (admin only)."""
    cfg = _get_or_create_agent_config(session, config)
    cfg.github_repo_owner = data.repo_owner
    cfg.github_repo_name = data.repo_name
    cfg.github_auth_mode = data.auth_mode
    cfg.github_connection_name = data.connection_name
    cfg.github_secret_scope = data.secret_scope
    cfg.github_secret_key = data.secret_key
    cfg.updated_at = datetime.now(timezone.utc)
    session.add(cfg)
    session.commit()
    session.refresh(cfg)
    return GithubConfigOut(
        repo_owner=cfg.github_repo_owner,
        repo_name=cfg.github_repo_name,
        auth_mode=cfg.github_auth_mode,
        connection_name=cfg.github_connection_name,
        secret_scope=cfg.github_secret_scope,
        secret_key=cfg.github_secret_key,
    )


@router.get(
    "/config/agent/supported-version",
    response_model=dict,
    operation_id="getSupportedAgentVersion",
)
def get_supported_agent_version():
    """Return the exact agent release tag this app targets.

    See core/_defaults.SUPPORTED_AGENT_VERSION.
    """
    from ..core._defaults import SUPPORTED_AGENT_VERSION
    return {
        "version": SUPPORTED_AGENT_VERSION,
        "repo": "https://github.com/databricks-industry-solutions/lakehouse-industry-data-models",
        "repo_tag_url": (
            f"https://github.com/databricks-industry-solutions/lakehouse-industry-data-models/releases/tag/"
            f"{SUPPORTED_AGENT_VERSION}"
        ),
    }


def _fetch_upstream_agent_identity(config) -> tuple[str | None, str | None]:
    """Live-read the canonical upstream agent notebook, returning
    ``(release_version, agent_marker)``.

    Module-level seam: the endpoint calls this by name so tests monkeypatch it
    rather than hitting GitHub. Builds the connector with the DEFAULT repo
    (``databricks-industry-solutions/lakehouse-industry-data-models`` @ ``main``),
    authenticated as the deployment's GitHub App when its creds are configured on
    ``AppConfig`` (else anonymous), and reads the notebook via the repo-root
    fetch path.
    """
    from ..sources.github import build_github_connector

    connector = build_github_connector(app_credentials=config.github_app_credentials)
    return fetch_upstream_agent_identity(connector)


def _same_release(a: str | None, b: str | None) -> bool:
    """True when two release identities name the same release (v-prefix agnostic)."""
    return a is not None and a.lstrip("v").strip() == (b or "").lstrip("v").strip()


@router.get(
    "/config/agent-compat",
    response_model=AgentCompatOut,
    operation_id="getAgentCompat",
)
def get_agent_compat(
    session: Dependencies.Session,
    config: Dependencies.Config,
) -> AgentCompatOut:
    """Upstream agent-availability monitor (Surface 2).

    Checks BOTH version numbers of the latest upstream agent against what the
    app pins and produces a three-way verdict:

    * upstream ``release_version`` NEWER than ``SUPPORTED_AGENT_VERSION`` →
      ``release_incompatible`` (``update_app_required=True``): the app's API
      calls target the pinned release and can't adapt, so the user must update
      the APP. No install offered.
    * same release, upstream ``agent_version`` NEWER than
      ``SUPPORTED_AGENT_MARKER`` → ``build_update_available``: same contract,
      newer build. Informational only.
    * otherwise → ``up_to_date``.

    The upstream identity is live-read from the canonical repo notebook and
    cached 7 days on the AgentConfig singleton. A stale/absent cache triggers a
    best-effort re-fetch: on any error the previously cached version values are
    kept and the error text is recorded, never a 500.

    The legacy ``latest_known_upstream`` / ``has_breaking_change`` /
    ``known_breaking_changes`` fields stay populated for back-compat consumers.
    """
    from ..core._defaults import SUPPORTED_AGENT_MARKER, SUPPORTED_AGENT_VERSION

    cfg = _get_or_create_agent_config(session, config)
    now = datetime.now(timezone.utc)

    checked_at = cfg.upstream_checked_at
    if checked_at is not None and checked_at.tzinfo is None:
        checked_at = checked_at.replace(tzinfo=timezone.utc)
    stale = checked_at is None or (now - checked_at) > _UPSTREAM_CACHE_TTL

    if stale:
        try:
            release, marker = _fetch_upstream_agent_identity(config)
            if release is None and marker is None:
                # A successful fetch that yields NO markers (empty body, or the
                # upstream notebook renamed/moved its version constants) must not
                # clobber a known-good cache: that would silently flip a cached
                # release_incompatible to up_to_date for the whole TTL. Keep the
                # prior values and record why, so the miss is visible.
                cfg.upstream_check_error = (
                    "Fetched the upstream notebook but found no "
                    "__RELEASE_VERSION__ / __AGENT_VERSION__ markers; kept the "
                    "previous cached values."
                )
            else:
                cfg.upstream_release_version = release
                cfg.upstream_agent_version = marker
                cfg.upstream_check_error = None
        except Exception as e:  # best-effort: keep cached values, record error
            cfg.upstream_check_error = f"{type(e).__name__}: {str(e)[:400]}"
        cfg.upstream_checked_at = now
        session.add(cfg)
        session.commit()
        session.refresh(cfg)

    pinned_release = SUPPORTED_AGENT_VERSION
    pinned_marker = SUPPORTED_AGENT_MARKER
    up_release = cfg.upstream_release_version
    up_marker = cfg.upstream_agent_version

    verdict = "up_to_date"
    update_app_required = False
    if up_release and is_newer_tag(up_release, pinned_release):
        verdict = "release_incompatible"
        update_app_required = True
    elif (
        up_marker
        and _same_release(up_release, pinned_release)
        and is_newer_tag(up_marker, pinned_marker)
    ):
        verdict = "build_update_available"

    newer = verdict != "up_to_date"

    # Back-compat: the legacy latest-upstream tag + known-breaking-change walk.
    # ``latest_known_upstream`` reflects the live upstream release when known,
    # else the in-tree matrix's latest tag.
    latest_up = up_release or latest_known_upstream_tag()
    breaking: list[AgentCompatChange] = []
    any_breaking = False
    for tag, entries in KNOWN_UPSTREAM_CHANGES.items():
        if not is_newer_tag(tag, pinned_release):
            continue
        if is_newer_tag(tag, latest_up):
            continue
        for e in entries:
            if e.get("severity") == "breaking":
                any_breaking = True
                breaking.append(
                    AgentCompatChange(
                        tag=tag,
                        severity=str(e.get("severity", "info")),
                        area=str(e.get("area", "")),
                        summary=str(e.get("summary", "")),
                    )
                )

    compare_url = ""
    if verdict == "release_incompatible" and up_release:
        compare_url = f"{_UPSTREAM_REPO_URL}/compare/{pinned_release}...{up_release}"

    return AgentCompatOut(
        pinned_version=pinned_release,
        latest_known_upstream=latest_up,
        newer_available=newer,
        has_breaking_change=any_breaking,
        known_breaking_changes=breaking,
        repo_compare_url=compare_url,
        pinned_release=pinned_release,
        pinned_agent_marker=pinned_marker,
        latest_upstream_release=up_release,
        latest_upstream_marker=up_marker,
        verdict=verdict,
        update_app_required=update_app_required,
        install_offered=False,
        checked_at=cfg.upstream_checked_at,
        check_error=cfg.upstream_check_error,
    )


@router.get(
    "/config/agent/ready",
    response_model=dict,
    operation_id="getAgentReady",
)
def get_agent_ready(
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
):
    """Summarise whether the app can launch runs right now. The UI uses this to
    gate the "New Run" button and show why it's disabled.

    Returns `{ready: bool, reason?: str}`. Intentionally consolidates three
    failure modes into a single boolean so the button can be disabled uniformly:
      1. No notebook saved yet (the bootstrapped AgentConfig row exists but
         ``notebook_path`` is empty)
      2. AgentConfig has no job_id (save completed but job creation failed)
      3. The app SP can no longer access the configured notebook path
    """
    cfg = _get_or_create_agent_config(session, config)
    if not cfg.notebook_path:
        return {"ready": False, "reason": "No agent notebook is configured. Go to Settings → Agent Configuration."}
    if not cfg.job_id:
        return {"ready": False, "reason": "Agent is configured but no Databricks job exists yet. Re-save the agent configuration."}
    if not resolve_metamodel_catalog(session, config):
        return {
            "ready": False,
            "reason": (
                "No metamodel catalog is configured. The agent writes its "
                "`_metamodel` schema and `vol_root` volume there. Set one in "
                "Settings → Platform before launching a run."
            ),
        }
    try:
        ws.workspace.get_status(cfg.notebook_path)
    except Exception as e:
        return {
            "ready": False,
            "reason": (
                f"The app service principal can no longer access the notebook "
                f"'{cfg.notebook_path}' ({str(e)[:120]}). Restore access or "
                f"point at a different notebook in Settings."
            ),
        }
    return {"ready": True}


@router.get(
    "/config/agent/check-notebook",
    response_model=dict,
    operation_id="checkAgentNotebook",
)
def check_agent_notebook(path: str, ws: Dependencies.Client):
    """Live check: can the app SP see the notebook at `path`? And does its
    declared version match the agent version the app targets?

    Returns one of:
    - `{ok: true, version: "v0.5.2"}` — reachable and version matches
    - `{ok: true, warning: "…"}` — reachable but no version marker (user should
      verify with agent maintainers that the notebook is the right tag)
    - `{ok: false, reason: "…"}` — unreachable, or version mismatch
    """
    from ..core._defaults import SUPPORTED_AGENT_VERSION
    if not path:
        return {"ok": False, "reason": "Notebook path is required."}
    try:
        ws.workspace.get_status(path)
    except Exception as e:
        return {"ok": False, "reason": str(e)[:200]}

    try:
        release, marker = _detect_notebook_identity(ws, path)
    except Exception as e:
        # Surface the read-side error verbatim so the user knows what
        # actually failed (e.g. SDK API misuse, transient export error,
        # permission edge case). The previous bare-except inside the
        # detector swallowed these as "no marker", masking real bugs.
        return {
            "ok": False,
            "reason": (
                f"Could not read the notebook source to verify the "
                f"version marker: {type(e).__name__}: {str(e)[:300]}"
            ),
        }
    if release is None:
        # Some upstream tags ship without an embedded version marker — for
        # those we know about, treat reachability + the pinned release as
        # enough rather than asking the user to "confirm with the agent
        # maintainers" (a dead-end action when we already shipped that exact
        # notebook in `src/app/vendored/agent/`).
        if SUPPORTED_AGENT_VERSION in _NO_MARKER_TAGS:
            return {
                "ok": True,
                "version": SUPPORTED_AGENT_VERSION,
                "message": (
                    f"Reachable; assuming {SUPPORTED_AGENT_VERSION} "
                    f"(no embedded marker)."
                ),
            }
        return {
            "ok": True,
            "warning": (
                f"Notebook is reachable, but has no `__RELEASE_VERSION__` / "
                f"`__AGENT_VERSION__` marker — the app can't verify it matches "
                f"release {SUPPORTED_AGENT_VERSION}. Confirm with the agent "
                f"maintainers."
            ),
        }
    # Gate on the release version (tracks the app-agent interface); the agent
    # marker is a per-fix build counter reported for display only.
    if release.lstrip("v") != SUPPORTED_AGENT_VERSION.lstrip("v"):
        build = f" (agent build {marker})" if marker else ""
        return {
            "ok": False,
            "reason": (
                f"Notebook declares release '{release}'{build} but this app "
                f"targets agent release '{SUPPORTED_AGENT_VERSION}'."
            ),
        }
    return {"ok": True, "version": SUPPORTED_AGENT_VERSION, "marker": marker}


@router.put("/config/agent", response_model=AgentConfigOut, operation_id="setAgentConfig")
def set_agent_config(
    data: AgentConfigIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.AdminOnly,
):
    """Configure the agent notebook path and create the persistent Databricks job."""
    _preflight_notebook_access(ws, data.notebook_path)
    _preflight_notebook_version(ws, data.notebook_path)

    cfg = _get_or_create_agent_config(session, config)
    cfg.notebook_path = data.notebook_path
    cfg.max_concurrent_runs = data.max_concurrent_runs
    cfg.collect_vibe_run_statistics = data.collect_vibe_run_statistics
    cfg.updated_at = datetime.now(timezone.utc)
    session.add(cfg)

    # Create or update the Databricks job. The reset/create flow inside
    # setup_agent_job reads agent_config.max_concurrent_runs so a settings
    # change here takes effect on the persistent job in the same request.
    try:
        job_id = setup_agent_job(ws, cfg)
        cfg.job_id = job_id
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create Databricks job: {e}")

    session.add(cfg)
    session.commit()
    session.refresh(cfg)
    return AgentConfigOut(
        **cfg.model_dump(),
        job_url=_build_dbx_job_url(ws, cfg.job_id),
    )


@router.post("/config/agent/verify", response_model=dict, operation_id="verifyAgentConfig")
def verify_agent_config(
    data: AgentConfigIn,
    ws: Dependencies.Client,
    _role: Dependencies.AdminOnly,
):
    """Verify the notebook path exists in the workspace (as seen by the app SP)."""
    _preflight_notebook_access(ws, data.notebook_path)
    return {"valid": True, "message": f"Notebook reachable at {data.notebook_path}"}


# --- Metamodel catalog (concern A) ---
#
# The setting formerly labeled "deployment catalog" is the METAMODEL catalog:
# the UC catalog holding the agent's `_metamodel` Delta schema + `vol_root`
# Volume, and the default target of a run's `deployment_catalog` widget (see
# core._catalogs). The DB column keeps its name (`deployment_catalog`); the
# API/UI vocabulary is `metamodel_catalog`. The `/config/metamodel-catalog`
# endpoints are canonical; the `/config/deployment-catalog` endpoints are kept
# one release as thin delegates for older clients and are deprecated.


@router.get(
    "/config/deployment-catalog",
    response_model=dict,
    operation_id="getDeploymentCatalog",
)
def get_deployment_catalog(
    session: Dependencies.Session,
    config: Dependencies.Config,
):
    """DEPRECATED alias of getMetamodelCatalog. Get the configured metamodel
    catalog under the legacy `deployment_catalog` key. Lazily seeded from the
    env var on first read. Prefer GET /config/metamodel-catalog."""
    cfg = _get_or_create_agent_config(session, config)
    return {
        "deployment_catalog": cfg.deployment_catalog,
        "is_configured": bool(cfg.deployment_catalog),
    }


@router.put(
    "/config/deployment-catalog",
    response_model=dict,
    operation_id="setDeploymentCatalog",
)
def set_deployment_catalog(
    data: DeploymentCatalogIn,
    session: Dependencies.Session,
    config: Dependencies.Config,
    _role: Dependencies.AdminOnly,
):
    """DEPRECATED alias of setMetamodelCatalog. Set the metamodel catalog via
    the legacy `deployment_catalog` key. Prefer PUT /config/metamodel-catalog."""
    cfg = _get_or_create_agent_config(session, config)
    cfg.deployment_catalog = data.deployment_catalog
    cfg.updated_at = datetime.now(timezone.utc)
    session.add(cfg)
    session.commit()
    session.refresh(cfg)
    return {
        "deployment_catalog": cfg.deployment_catalog,
        "is_configured": bool((cfg.deployment_catalog or "").strip()),
    }


@router.get(
    "/config/metamodel-catalog",
    response_model=dict,
    operation_id="getMetamodelCatalog",
)
def get_metamodel_catalog(
    session: Dependencies.Session,
    config: Dependencies.Config,
):
    """Get the configured metamodel catalog (concern A). Lazily seeded from the
    env var on first read. Delegates to the legacy deployment-catalog reader and
    re-keys the response under the concern-A vocabulary."""
    legacy = get_deployment_catalog(session, config)
    return {
        "metamodel_catalog": legacy["deployment_catalog"],
        "is_configured": legacy["is_configured"],
    }


@router.put(
    "/config/metamodel-catalog",
    response_model=dict,
    operation_id="setMetamodelCatalog",
)
def set_metamodel_catalog(
    data: MetamodelCatalogIn,
    session: Dependencies.Session,
    config: Dependencies.Config,
    _role: Dependencies.AdminOnly,
):
    """Set the metamodel catalog (concern A). Delegates to the legacy
    deployment-catalog writer (same underlying column) and re-keys the
    response under the concern-A vocabulary."""
    legacy = set_deployment_catalog(
        DeploymentCatalogIn(deployment_catalog=data.metamodel_catalog),
        session,
        config,
        _role,
    )
    return {
        "metamodel_catalog": legacy["deployment_catalog"],
        "is_configured": legacy["is_configured"],
    }


# --- Warehouse ---


@router.get(
    "/config/warehouses",
    response_model=list[WarehouseOut],
    operation_id="listWarehouses",
)
def list_warehouses(ws: Dependencies.Client):
    """List available SQL warehouses in the workspace."""
    warehouses = ws.warehouses.list()
    return [
        WarehouseOut(
            id=wh.id,
            name=wh.name,
            state=wh.state.value if wh.state else "UNKNOWN",
            cluster_size=wh.cluster_size or "",
            warehouse_type=wh.warehouse_type.value if wh.warehouse_type else "",
        )
        for wh in warehouses
        if wh.id and wh.name
    ]


@router.get("/config/warehouse", response_model=dict, operation_id="getWarehouse")
def get_warehouse(session: Dependencies.Session, config: Dependencies.Config):
    """Get the configured warehouse ID. Lazily seeded from the env var on first read."""
    cfg = _get_or_create_agent_config(session, config)
    return {"warehouse_id": cfg.warehouse_id, "is_configured": bool(cfg.warehouse_id)}


@router.put("/config/warehouse", response_model=dict, operation_id="setWarehouse")
def set_warehouse(
    data: dict,
    session: Dependencies.Session,
    config: Dependencies.Config,
    _role: Dependencies.AdminOnly,
):
    """Set the SQL warehouse for Delta table polling and sync."""
    wh_id = data.get("warehouse_id", "")
    cfg = _get_or_create_agent_config(session, config)
    cfg.warehouse_id = wh_id
    cfg.updated_at = datetime.now(timezone.utc)
    session.add(cfg)
    session.commit()
    session.refresh(cfg)
    return {
        "warehouse_id": cfg.warehouse_id,
        "is_configured": bool((cfg.warehouse_id or "").strip()),
    }


@router.post(
    "/config/initial-sync",
    response_model=dict,
    operation_id="triggerInitialSync",
)
def trigger_initial_sync(
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.AdminOnly,
):
    """Trigger initial sync — discovers businesses from the deployment catalog."""
    from ..initial_sync import InitialSyncService

    require_config(session, config, ["metamodel_catalog", "warehouse"], mode="raise")
    cfg = _get_or_create_agent_config(session, config)

    svc = InitialSyncService(session, ws, cfg.warehouse_id)
    summary = svc.discover_and_sync(cfg.deployment_catalog)
    session.commit()
    return summary


# --- Out-of-band detection ---


@router.get("/config/oob-check", response_model=dict, operation_id="checkOobVersions")
def check_oob_versions(
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
):
    """Detect completed model versions in Delta that are missing from Lakebase."""
    from ..oob_detector import OobDetector

    require_config(session, config, ["metamodel_catalog", "warehouse"], mode="raise")
    cfg = _get_or_create_agent_config(session, config)

    detector = OobDetector(session, ws, cfg.warehouse_id)
    return detector.detect(cfg.deployment_catalog)


@router.post(
    "/config/oob-import",
    response_model=dict,
    operation_id="importOobVersions",
)
def import_oob_versions(
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.AdminOnly,
):
    """Import all detected out-of-band versions via InitialSyncService.

    This is equivalent to re-running initial sync — it discovers any new
    businesses/versions and imports them.
    """
    from ..initial_sync import InitialSyncService

    require_config(session, config, ["metamodel_catalog", "warehouse"], mode="raise")
    cfg = _get_or_create_agent_config(session, config)

    svc = InitialSyncService(session, ws, cfg.warehouse_id)
    summary = svc.discover_and_sync(cfg.deployment_catalog)
    session.commit()
    return summary
