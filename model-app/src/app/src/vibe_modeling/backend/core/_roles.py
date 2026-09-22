"""Role-based access control — resolves user roles from Databricks workspace groups.

Three workspace groups define permissions:
  - vibe-app-admins: full access including settings and group management
  - vibe-business-admins: manage businesses, approve syncs, manage model versions
  - vibe-modelers: navigate, run vibes, provide feedback

Users not in any group get read-only access.

The role resolver queries SCIM group membership via the SP client on first
request and caches the result for the session duration (per-request scope
in FastAPI means per HTTP request, which is fine — no mid-request user switch).
"""

from __future__ import annotations

import logging
import os
from enum import Enum
from typing import Annotated, TypeAlias

from databricks.sdk import WorkspaceClient
from fastapi import Depends, HTTPException, Request

from ._headers import DatabricksAppsHeaders, get_databricks_headers

logger = logging.getLogger(__name__)

# Feature flag: set VIBE_MODELING_RBAC_ENABLED=true to enforce group-based roles.
# When disabled (default), all users are treated as APP_ADMIN.
RBAC_ENABLED = os.environ.get("VIBE_MODELING_RBAC_ENABLED", "").lower() == "true"


class UserRole(str, Enum):
    """Application roles, ordered by privilege level."""
    APP_ADMIN = "app_admin"
    BUSINESS_ADMIN = "business_admin"
    MODELER = "modeler"
    VIEWER = "viewer"


# Account-level group names → role mapping
_GROUP_ROLE_MAP = {
    "vibe-app-admins": UserRole.APP_ADMIN,
    "vibe-business-admins": UserRole.BUSINESS_ADMIN,
    "vibe-modelers": UserRole.MODELER,
}


def resolve_user_role(
    request: Request,
    headers: Annotated[DatabricksAppsHeaders, Depends(get_databricks_headers)],
) -> UserRole:
    """Resolve the current user's highest-privilege role.

    When RBAC is disabled (default), all users get APP_ADMIN.
    When enabled, queries SCIM group membership via the SP client.
    """
    if not RBAC_ENABLED:
        return UserRole.APP_ADMIN

    # Prefer email (matches SCIM userName), fall back to preferred username
    user_name = headers.user_email or headers.user_name
    if not user_name:
        logger.debug("No user identity in headers, defaulting to APP_ADMIN (dev mode)")
        return UserRole.APP_ADMIN

    # Check request-scoped cache
    cache_key = f"_user_role_{user_name}"
    cached = getattr(request.state, cache_key, None)
    if cached is not None:
        return cached

    # Query SCIM via SP client
    ws: WorkspaceClient = request.app.state.workspace_client
    role = _resolve_from_scim(ws, user_name)

    # Cache on request state
    setattr(request.state, cache_key, role)
    return role


def _resolve_from_scim(ws: WorkspaceClient, user_name: str) -> UserRole:
    """Query workspace groups to determine the user's role.

    Uses users.list with attributes="id,userName,groups" so group memberships
    are returned inline — avoids users.get() which requires workspace admin.
    """
    try:
        users = list(ws.users.list(
            filter=f'userName eq "{user_name}"',
            attributes="id,userName,groups",
        ))
        if not users:
            logger.warning(f"SCIM user not found: {user_name}")
            return UserRole.VIEWER

        user_groups = set()
        for g in users[0].groups or []:
            if g.display:
                user_groups.add(g.display)

        # Return highest-privilege matching role
        for group_name, role in _GROUP_ROLE_MAP.items():
            if group_name in user_groups:
                return role

        return UserRole.VIEWER
    except Exception as e:
        logger.warning(f"SCIM group lookup failed for {user_name}: {e}")
        return UserRole.VIEWER


UserRoleDependency: TypeAlias = Annotated[UserRole, Depends(resolve_user_role)]


# ---------------------------------------------------------------------------
# Permission guards — use as FastAPI dependencies
# ---------------------------------------------------------------------------

def require_admin(role: UserRoleDependency) -> UserRole:
    """Guard: only app admins."""
    if role != UserRole.APP_ADMIN:
        raise HTTPException(status_code=403, detail="App admin access required")
    return role


def require_business_admin(role: UserRoleDependency) -> UserRole:
    """Guard: app admins or business admins."""
    if role not in (UserRole.APP_ADMIN, UserRole.BUSINESS_ADMIN):
        raise HTTPException(status_code=403, detail="Business admin access required")
    return role


def require_modeler(role: UserRoleDependency) -> UserRole:
    """Guard: app admins, business admins, or modelers."""
    if role == UserRole.VIEWER:
        raise HTTPException(status_code=403, detail="Modeler access required")
    return role


# Dependency type aliases for use in route signatures
RequireAdmin: TypeAlias = Annotated[UserRole, Depends(require_admin)]
RequireBusinessAdmin: TypeAlias = Annotated[UserRole, Depends(require_business_admin)]
RequireModeler: TypeAlias = Annotated[UserRole, Depends(require_modeler)]
