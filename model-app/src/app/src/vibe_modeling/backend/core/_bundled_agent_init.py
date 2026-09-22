"""Lifespan: ensure the bundled agent notebook is installed on every boot.

If ``AgentConfig.notebook_path`` is empty (fresh install, manual reset, or
a Lakebase reprovision wiped the row), we install the bundled notebook
into a workspace path and wire up the persistent Databricks Job so the
app is usable from the first request — no external installer script
needed, no dependency on the operator's machine reaching the app's
public URL.

Idempotent: once ``notebook_path`` is set, the lifespan is a no-op so
admins who pointed AgentConfig at a custom notebook are not silently
overridden.

Best-effort: any failure logs a warning but does not crash the boot, so
the app still serves Settings for manual recovery.

Sibling caller — stays in sync with
``backend/routes/platform.py:install_bundled_agent`` (manual admin
re-install via Settings):

* Both call the same workspace-side helper
  (``install_bundled_agent_into_workspace``), so the install path
  ``/Users/<app-sp>/vibe-modelling-agent/`` is identical.
* This lifespan additionally writes ``AgentConfig.notebook_path`` and
  creates the persistent Job — appropriate at boot when the row is
  empty. The route deliberately does NOT touch AgentConfig: the admin
  copies the returned path into the Settings form and the existing
  ``PUT /config/agent`` flow (with its own preflight + job-setup) takes
  it from there. Don't merge the two responsibilities.
* Error surfaces differ on purpose: the lifespan logs and continues
  (no user to redirect at boot); the route raises HTTPException so the
  Settings UI can surface the failure inline.
"""

from __future__ import annotations

from contextlib import asynccontextmanager
from datetime import datetime, timezone
from typing import AsyncGenerator

from fastapi import FastAPI
from sqlmodel import Session

from ._base import LifespanDependency
from ._config import logger


class _BundledAgentInitDependency(LifespanDependency):
    @asynccontextmanager
    async def lifespan(self, app: FastAPI) -> AsyncGenerator[None, None]:
        ws = app.state.workspace_client
        engine = app.state.engine
        config = app.state.config

        try:
            # expire_on_commit=False: _ensure_bundled_agent_installed commits
            # after the notebook install, then reads AgentConfig attributes
            # again to call the slow setup_agent_job (Databricks Jobs API).
            # Under the default expire_on_commit=True that attribute read
            # would re-open a transaction that idles across the Jobs API
            # call - the same leak shape fixed in the kickstart background
            # and diagram-prefetch session_factory sites above.
            with Session(bind=engine, expire_on_commit=False) as session:
                _ensure_bundled_agent_installed(session, ws, config)
        except Exception:
            logger.exception(
                "Bundled-agent auto-install failed; the app will still boot. "
                "Open Settings -> Agent Configuration to install manually."
            )

        yield

    @staticmethod
    def __call__() -> None:
        # Boot-time only — no per-request resource to inject.
        return None


def _ensure_bundled_agent_installed(session: Session, ws, config) -> None:
    """Install the bundled agent + create the persistent Job if not yet set up."""
    from ..bundled_agent_install import (
        BundledAgentNotPackagedError,
        install_bundled_agent_into_workspace,
    )
    from ..job_launcher import setup_agent_job
    from ..routes._helpers import _get_or_create_agent_config

    cfg = _get_or_create_agent_config(session, config)
    if cfg.notebook_path:
        logger.debug(
            "Bundled-agent auto-install skipped: notebook_path already set to %s",
            cfg.notebook_path,
        )
        return

    try:
        result = install_bundled_agent_into_workspace(ws)
    except BundledAgentNotPackagedError as e:
        logger.warning("Bundled-agent auto-install: %s", e)
        return

    cfg.notebook_path = result.path
    cfg.updated_at = datetime.now(timezone.utc)
    session.add(cfg)
    session.commit()
    session.refresh(cfg)

    try:
        cfg.job_id = setup_agent_job(ws, cfg)
    except Exception as e:  # noqa: BLE001 — best-effort
        logger.warning(
            "Bundled-agent auto-install: notebook uploaded to %s but job creation failed: %s",
            result.path,
            e,
        )
        return

    session.add(cfg)
    session.commit()
    logger.info(
        "Bundled-agent auto-install: %s notebook=%s job_id=%s",
        "overwrote" if result.overwritten else "installed",
        result.path,
        cfg.job_id,
    )
