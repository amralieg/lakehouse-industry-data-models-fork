"""Lakebase (Databricks Database) integration: config, engine, session, and dependency.

Supports three modes:
1. Production: Lakebase Autoscaling (w.postgres) via SDK OAuth
2. APX dev: pglite embedded DB via APX_DEV_DB_PORT/APX_DEV_DB_PWD
3. SQLite fallback: in-memory SQLite when neither is available (local dev without pglite)
"""

from __future__ import annotations

import os
import tempfile
from collections.abc import Generator
from contextlib import asynccontextmanager
from typing import Annotated, Any, AsyncGenerator, TypeAlias

from databricks.sdk import WorkspaceClient
from fastapi import FastAPI, Request
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict
from sqlalchemy import Engine, create_engine, event
from sqlmodel import Session, select, text

from ._base import LifespanDependency
from ._config import AppConfig, logger

from ..._metadata import app_slug


# --- Database Config ---


class DatabaseConfig(BaseSettings):
    model_config = SettingsConfigDict(env_prefix=f"{app_slug.upper()}_")

    lakebase_project: str = Field(
        description="Lakebase Autoscaling project ID",
        default="vibe-modeling",
    )
    lakebase_branch: str = Field(
        description=(
            "Lakebase Autoscaling branch within the project. Defaults to "
            "'production'. Override for migration-bearing deploys via "
            "a smoke branch (e.g. v0-6-1-smoke)."
        ),
        default="production",
    )
    database_name: str = Field(
        description="The Postgres database the app reads/writes (matches the UC catalog binding)",
        default="vibe_modeling",
    )


# --- Engine creation ---


def _get_dev_db_port() -> int | None:
    """Check for APX_DEV_DB_PORT environment variable for local development."""
    port = os.environ.get("APX_DEV_DB_PORT")
    return int(port) if port else None


def _get_endpoint_name(project: str, branch: str) -> str:
    """Build the Lakebase Autoscaling endpoint resource name."""
    return f"projects/{project}/branches/{branch}/endpoints/primary"


def _build_engine_url(
    db_config: DatabaseConfig, ws: WorkspaceClient, dev_port: int | None
) -> str:
    """Build the database engine URL for dev or production mode."""
    if dev_port:
        password = os.environ.get("APX_DEV_DB_PWD")
        if password is not None:
            # The apx-embedded pglite listens on 127.0.0.1 (IPv4 only). On
            # macOS dual-stack systems `localhost` resolves to ::1 first,
            # which the pglite process refuses, surfacing as a hard
            # `psycopg.OperationalError: Connection refused` and breaking
            # every DB-touching endpoint at boot. Use the literal IPv4
            # address so the connect path is unambiguous.
            logger.info(f"Using APX embedded database at 127.0.0.1:{dev_port}")
            return f"postgresql+psycopg://postgres:{password}@127.0.0.1:{dev_port}/postgres?sslmode=disable"
        logger.warning(
            f"APX_DEV_DB_PORT={dev_port} set but APX_DEV_DB_PWD missing — "
            "embedded DB likely failed to start. Falling back to SQLite."
        )
        return _sqlite_fallback_url()

    # Production mode: Lakebase Autoscaling via w.postgres
    project = db_config.lakebase_project
    branch = db_config.lakebase_branch
    endpoint_name = _get_endpoint_name(project, branch)
    logger.info(
        f"Using Lakebase Autoscaling project: {project} (branch: {branch})"
    )

    endpoint = ws.postgres.get_endpoint(name=endpoint_name)
    host = endpoint.status.hosts.host
    port = 5432
    database = db_config.database_name
    username = (
        ws.config.client_id if ws.config.client_id else ws.current_user.me().user_name
    )
    return f"postgresql+psycopg://{username}:@{host}:{port}/{database}"


_SQLITE_DB_PATH: str | None = None


def _sqlite_fallback_url() -> str:
    """Create a SQLite URL for local development fallback."""
    global _SQLITE_DB_PATH
    if _SQLITE_DB_PATH is None:
        db_dir = os.path.join(tempfile.gettempdir(), "vibe_modeling_dev")
        os.makedirs(db_dir, exist_ok=True)
        _SQLITE_DB_PATH = os.path.join(db_dir, "dev.db")
    logger.warning(f"Using SQLite fallback database at {_SQLITE_DB_PATH}")
    return f"sqlite:///{_SQLITE_DB_PATH}"


def create_db_engine(db_config: DatabaseConfig, ws: WorkspaceClient) -> Engine:
    """
    Create a SQLAlchemy engine.

    In APX dev mode: pglite embedded DB (no SSL).
    In production: Lakebase Autoscaling with SSL and OAuth token refresh.
    Fallback: SQLite when pglite is unavailable.
    """
    dev_port = _get_dev_db_port()
    engine_url = _build_engine_url(db_config, ws, dev_port)

    is_sqlite = engine_url.startswith("sqlite")

    if is_sqlite:
        from sqlalchemy.pool import StaticPool
        engine = create_engine(
            engine_url,
            connect_args={"check_same_thread": False},
            poolclass=StaticPool,
        )
    else:
        engine_kwargs: dict[str, Any] = {
            "pool_size": 4,
            "pool_recycle": 45 * 60,
            # Lakebase Autoscaling recycles/terminates idle server connections
            # (psycopg AdminShutdown: "terminating connection due to
            # administrator command"). Without pre-ping, a dead pooled
            # connection is handed out and the request 500s once. pre_ping does
            # a cheap liveness check and transparently reconnects.
            "pool_pre_ping": True,
        }
        if not dev_port or not os.environ.get("APX_DEV_DB_PWD"):
            engine_kwargs["connect_args"] = {"sslmode": "require"}
        engine = create_engine(engine_url, **engine_kwargs)

        if not dev_port:
            # Token refresh callback for Lakebase Autoscaling
            endpoint_name = _get_endpoint_name(
                db_config.lakebase_project, db_config.lakebase_branch
            )

            def before_connect(dialect, conn_rec, cargs, cparams):
                cred = ws.postgres.generate_database_credential(
                    endpoint=endpoint_name
                )
                cparams["password"] = cred.token
            event.listens_for(engine, "do_connect")(before_connect)

    return engine


def validate_db(engine: Engine, db_config: DatabaseConfig) -> None:
    """Validate that the database connection works."""
    dev_port = _get_dev_db_port()
    is_sqlite = str(engine.url).startswith("sqlite")

    if is_sqlite:
        logger.info("Validating SQLite fallback database connection")
    elif dev_port:
        logger.info(f"Validating local dev database connection at 127.0.0.1:{dev_port}")
    else:
        logger.info(
            f"Validating Lakebase Autoscaling connection for project "
            f"{db_config.lakebase_project} (branch: {db_config.lakebase_branch})"
        )

    try:
        with Session(engine) as session:
            session.connection().execute(text("SELECT 1"))
            session.close()
    except Exception:
        raise ConnectionError("Failed to connect to the database")

    if is_sqlite:
        logger.info("SQLite fallback database connection validated successfully")
    elif dev_port:
        logger.info("Local dev database connection validated successfully")
    else:
        logger.info(
            f"Lakebase Autoscaling connection validated for project "
            f"{db_config.lakebase_project} (branch: {db_config.lakebase_branch})"
        )


# ---------------------------------------------------------------------------
# Boot-time schema reconciliation.
#
# Phase 4.5 closeout: the historical column-by-column ``_add_missing_columns``
# migration list is replaced by a versioned migration registry. See
# ``backend.migrations.reconcile_schema`` for the lifecycle phases and the
# pre-prod destructive-reset gate.
# ---------------------------------------------------------------------------


def initialize_models(engine: Engine) -> None:
    """Reconcile the database schema with the registered migrations.

    Delegates to ``backend.migrations.reconcile_schema``, which reads
    the ``_lakebase_schema_version`` row and applies any migrations
    newer than the installed version (or wipes-and-reapplies during
    pre-prod, see ``PRE_PROD_DESTRUCTIVE_RESET``).
    """
    # Import inside the function so the module remains importable when
    # the migrations sub-package is being patched in tests.
    from ..migrations import reconcile_schema

    logger.info("Reconciling database schema")
    reconcile_schema(engine)
    logger.info("Database schema reconciliation complete")


def seed_industries(engine: Engine) -> None:
    """Seed the industries table with the standard catalog if empty."""
    from ..db_models import Industry
    from ..industry_catalog import INDUSTRY_CATALOG

    with Session(bind=engine) as session:
        count = session.exec(select(Industry).limit(1)).first()
        if count is not None:
            return  # Already seeded

        logger.info("Seeding %d industries", len(INDUSTRY_CATALOG))
        for i, entry in enumerate(INDUSTRY_CATALOG):
            session.add(Industry(
                name=entry["name"],
                short_name=entry["short_name"],
                description=entry.get("description", ""),
                notable_businesses=entry.get("notable_businesses", ""),
                display_order=i,
                is_active=True,
            ))
        session.commit()
        logger.info("Industry seed complete")


def seed_sectors(engine: Engine) -> None:
    """Seed the sectors table with the SECTOR_MAP snapshot if empty (ADR D-047).

    Idempotent: a single existing row short-circuits, so this is safe to call
    on every boot (mirrors ``seed_industries``)."""
    from ..db_models import Sector
    from ..sector_catalog import SECTOR_CATALOG

    with Session(bind=engine) as session:
        existing = session.exec(select(Sector).limit(1)).first()
        if existing is not None:
            return  # Already seeded

        logger.info("Seeding %d sectors", len(SECTOR_CATALOG))
        for i, entry in enumerate(SECTOR_CATALOG):
            session.add(Sector(
                name=entry["name"],
                short_name=entry["short_name"],
                description=entry.get("description", ""),
                display_order=i,
                is_active=True,
            ))
        session.commit()
        logger.info("Sector seed complete")


# --- Dependency ---


class _LakebaseDependency(LifespanDependency):
    @asynccontextmanager
    async def lifespan(self, app: FastAPI) -> AsyncGenerator[None, None]:
        db_config = DatabaseConfig()
        ws = app.state.workspace_client

        engine = create_db_engine(db_config, ws)
        validate_db(engine, db_config)
        initialize_models(engine)
        seed_industries(engine)
        seed_sectors(engine)

        app.state.engine = engine
        yield
        engine.dispose()

    @staticmethod
    def __call__(request: Request) -> Generator[Session, None, None]:
        with Session(bind=request.app.state.engine) as session:
            yield session


LakebaseDependency: TypeAlias = Annotated[Session, _LakebaseDependency.depends()]
