"""Platform / workspace bootstrap endpoints.

Covers identity, RBAC role lookup, per-user preferences, the workspace
catalog picker, and the bundled-agent install flow surfaced in the admin
console. These are the cross-cutting endpoints the UI hits to stand up the
shell of the app — none of them are scoped to a single business or run.
"""

from __future__ import annotations

import logging
from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from sqlmodel import select

from ..._metadata import api_prefix
from ..core import Dependencies
from ..db_models import UserPreference
from ..models import (
    BundledAgentInfoOut,
    InstallBundledAgentOut,
    UserPreferenceIn,
    UserPreferenceOut,
    VersionOut,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix=api_prefix)


@router.get("/version", response_model=VersionOut, operation_id="version")
async def version():
    return VersionOut.from_metadata()


class ClientGatewayErrorIn(BaseModel):
    """A transient edge-proxy failure (502/503/504) the browser observed on an
    app request, reported so it lands in the APP logs.

    A client-side auto-retry (E-04, kickstart POST) otherwise recovers the
    request in the browser and the 502 never reaches `databricks apps logs`,
    hiding a real recurrence. The client beacons every occurrence here - even
    ones a later retry recovers - so the edge condition stays observable
    server-side. Co-located here (not `models.py`): this is a platform-level
    observability contract with no DB/Out counterpart, mirroring the
    lifecycle-endpoint co-location convention in `routes.industry_models`.
    """

    status: int = Field(description="Gateway status the browser saw (502/503/504).")
    path: str = Field(description="App request path that failed, e.g. /api/.../kickstart.")
    attempt: int = Field(description="1-based attempt number that failed.")
    will_retry: bool = Field(
        default=False, description="Whether the client will auto-retry this attempt."
    )
    context: str | None = Field(
        default=None,
        description="Free-form context (e.g. kickstart industry id + new name).",
    )


class ClientTelemetryAck(BaseModel):
    """Ack for a client telemetry beacon (the event was logged server-side)."""

    logged: bool


@router.post(
    "/client-telemetry/gateway-error",
    response_model=ClientTelemetryAck,
    operation_id="reportClientGatewayError",
)
def report_client_gateway_error(
    data: ClientGatewayErrorIn, headers: Dependencies.Headers
) -> ClientTelemetryAck:
    """Record a browser-observed transient gateway error in the app logs.

    Emits one WARNING per occurrence (retried or not) so an E-04-style 502
    recurrence stays diagnosable in `databricks apps logs` even when a
    client-side retry recovers it. Deliberately does nothing else - no DB
    write, no fan-out - so the beacon is cheap and cannot itself fail the
    user's flow.
    """
    logger.warning(
        "client-reported gateway error: status=%s path=%s attempt=%s "
        "will_retry=%s user=%s context=%s",
        data.status,
        data.path,
        data.attempt,
        data.will_retry,
        headers.user_name or "anonymous",
        data.context,
    )
    return ClientTelemetryAck(logged=True)


@router.get("/current-user", operation_id="currentUser")
def me(headers: Dependencies.Headers):
    """Get current user info from Databricks Apps headers, or return anonymous."""
    if headers.user_name:
        return {
            "userName": headers.user_name,
            "displayName": headers.user_name,
            "emails": [{"value": headers.user_email}] if headers.user_email else [],
        }
    return {"userName": "anonymous", "displayName": "Anonymous User", "emails": []}


@router.get("/user/role", response_model=dict, operation_id="getUserRole")
def get_user_role(role: Dependencies.Role):
    """Get the current user's resolved RBAC role."""
    return {"role": role.value, "display_name": role.value.replace("_", " ").title()}


# --- User Preferences ---


@router.get(
    "/user/preferences",
    response_model=list[UserPreferenceOut],
    operation_id="getUserPreferences",
)
def get_user_preferences(session: Dependencies.Session, headers: Dependencies.Headers):
    """Get all preferences for the current user."""
    user_id = headers.user_name or "anonymous"
    prefs = session.exec(
        select(UserPreference).where(UserPreference.user_id == user_id)
    ).all()
    return prefs


@router.put(
    "/user/preferences/{key}",
    response_model=UserPreferenceOut,
    operation_id="setUserPreference",
)
def set_user_preference(
    key: str,
    body: UserPreferenceIn,
    session: Dependencies.Session,
    headers: Dependencies.Headers,
):
    """Upsert a user preference."""
    user_id = headers.user_name or "anonymous"
    pref = session.get(UserPreference, (user_id, key))
    if pref:
        pref.value = body.value
        pref.updated_at = datetime.now(timezone.utc)
    else:
        pref = UserPreference(user_id=user_id, key=key, value=body.value)
        session.add(pref)
    session.commit()
    session.refresh(pref)
    return pref


# --- Workspace catalogs (used by run-form pickers) ---


@router.get(
    "/catalogs",
    response_model=list,
    operation_id="listCatalogs",
)
def list_catalogs(ws: Dependencies.Client):
    """Return the UC catalogs visible to the app service principal.

    Intended to populate catalog pickers in the UI. The list is naturally
    filtered by what the SP can `USE CATALOG` on — catalogs the SP cannot
    see are not returned by `w.catalogs.list()`. The UI can offer this list
    as a dropdown on the run-creation form so users don't have to type a
    catalog name from memory.
    """
    try:
        catalogs = list(ws.catalogs.list())
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to list catalogs: {e}") from e
    return [
        {
            "name": c.name,
            "comment": c.comment or "",
            "owner": c.owner or "",
        }
        for c in catalogs
        if c.name
    ]


# --- Bundled agent notebook ---


@router.get(
    "/admin/bundled-agent",
    response_model=BundledAgentInfoOut,
    operation_id="getBundledAgentInfo",
)
def get_bundled_agent_info():
    """Describe the vibe-modelling-agent notebook shipped alongside the app.

    Returns `available=False` if the wheel was built without the vendored
    notebook (e.g. legacy installs). The first-run gate hides the install
    button in that case.
    """
    from ..bundled_agent import resolve_bundled_agent
    agent = resolve_bundled_agent()
    if agent is None:
        return BundledAgentInfoOut(available=False)
    return BundledAgentInfoOut(
        available=True,
        pinned_tag=agent.pinned_tag,
        supported_tags=agent.supported_tags,
        file_name=agent.file_name,
    )


@router.post(
    "/admin/install-bundled-agent",
    response_model=InstallBundledAgentOut,
    operation_id="installBundledAgent",
)
def install_bundled_agent(
    ws: Dependencies.Client,
    _role: Dependencies.AdminOnly,
):
    """Upload the bundled vibe-modelling-agent notebook into the workspace.

    The file is written under `/Users/<app_sp_user>/vibe-modelling-agent/`.
    The same install logic runs unconditionally on every app boot via the
    ``_BundledAgentInitDependency`` lifespan, so a fresh deploy is usable
    immediately; this route exists so an admin can manually re-install
    via Settings (e.g. after the bundled tag bumps, or after deleting the
    workspace copy by hand).

    Sibling caller — stays in sync with
    ``backend/core/_bundled_agent_init.py:_ensure_bundled_agent_installed``
    (boot-time auto-install). Both call
    ``install_bundled_agent_into_workspace`` so the workspace install
    path is identical. This route deliberately does NOT update
    ``AgentConfig.notebook_path`` or create the Job: the admin copies
    the returned path into the Settings form and ``PUT /config/agent``
    (with its own preflight) takes it from there. Don't merge the two
    responsibilities — the lifespan owns the boot-time bootstrap; this
    route owns manual reinstall.
    """
    from ..bundled_agent_install import (
        BundledAgentNotPackagedError,
        install_bundled_agent_into_workspace,
    )

    try:
        result = install_bundled_agent_into_workspace(ws)
    except BundledAgentNotPackagedError as e:
        raise HTTPException(status_code=500, detail=str(e)) from e
    except RuntimeError as e:
        raise HTTPException(status_code=500, detail=str(e)) from e

    return InstallBundledAgentOut(
        path=result.path,
        version=result.version,
        overwritten=result.overwritten,
    )
