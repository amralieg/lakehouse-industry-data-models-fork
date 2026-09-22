"""Install the bundled vibe-modelling-agent notebook into the workspace.

The agent notebook ships inside the wheel (see ``bundled_agent.py``).
Databricks Jobs cannot reference a notebook from inside a Python wheel,
so the App copies the wheel-internal ``.ipynb`` into a real workspace
path under the App service principal's home directory and points
``AgentConfig.notebook_path`` at that copy.

This module is the single source of truth for that copy. It's used in
two places:

  * The lifespan auto-install (``core/_bundled_agent_init.py``) — runs
    on every app boot, idempotent — so a fresh install always lands
    with ``AgentConfig.notebook_path`` populated and a Databricks Job
    wired up, with no external trigger needed.
  * The admin REST route (``routes/platform.py:install_bundled_agent``)
    — manual re-install via the Settings UI, kept for the case where
    an admin wants to refresh after the bundled version bumps or after
    deleting the workspace copy.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass

from databricks.sdk import WorkspaceClient
from databricks.sdk.service.workspace import ImportFormat

from .bundled_agent import resolve_bundled_agent

logger = logging.getLogger(__name__)


@dataclass(frozen=True)
class InstallResult:
    path: str
    version: str
    overwritten: bool


class BundledAgentNotPackagedError(RuntimeError):
    """Raised when the wheel was built without a vendored agent notebook."""


def install_bundled_agent_into_workspace(ws: WorkspaceClient) -> InstallResult:
    """Copy the bundled notebook from the wheel into the App SP's workspace home.

    Target: ``/Users/<sp-user-name>/vibe-modelling-agent/<file>.ipynb``.

    Raises:
        BundledAgentNotPackagedError: the wheel has no vendored notebook.
        RuntimeError: the App SP identity could not be resolved or the
            workspace upload failed.
    """
    agent = resolve_bundled_agent()
    if agent is None:
        raise BundledAgentNotPackagedError(
            "No bundled agent notebook is packaged with this app build. "
            "Re-run scripts/refresh_vendored_agent.sh and rebuild the wheel."
        )

    me = ws.current_user.me()
    user_name = getattr(me, "user_name", None) or ""
    if not user_name:
        raise RuntimeError(
            "Databricks returned a user with no user_name — cannot decide upload path."
        )

    folder = f"/Users/{user_name}/vibe-modelling-agent"
    target = f"{folder}/{agent.file_name}"

    try:
        ws.workspace.mkdirs(folder)
    except Exception as e:  # noqa: BLE001 — best-effort
        logger.info("workspace.mkdirs(%s) raised %s — continuing", folder, e)

    overwritten = False
    try:
        ws.workspace.get_status(target)
        overwritten = True
    except Exception:  # noqa: BLE001 — NotFound is the expected first-install case
        overwritten = False

    fmt = ImportFormat.JUPYTER if agent.file_name.endswith(".ipynb") else ImportFormat.SOURCE
    try:
        with agent.file_path.open("rb") as fh:
            ws.workspace.upload(
                path=target,
                content=fh,
                format=fmt,
                overwrite=True,
            )
    except Exception as e:
        raise RuntimeError(f"Failed to upload bundled agent to {target}: {e}") from e

    return InstallResult(path=target, version=agent.pinned_tag, overwritten=overwritten)
