"""Migration 0.7.2 — persist the source READ-auth config on ``agent_config``.

Adds seven defaulted string columns to ``agent_config`` (the singleton row) so
source browse / preview / download and the upstream-agent monitor can select a
read transport per installation:

* ``source_auth_mode`` — '' (unconfigured → env → anonymous) | github_app |
  token | anonymous.
* ``source_github_app_id`` / ``source_github_app_installation_id`` — the
  GitHub App's non-secret identifiers.
* ``source_github_app_secret_scope`` / ``source_github_app_secret_key`` — the
  Databricks secret scope/key holding the App PEM (a reference, never the PEM).
* ``source_token_secret_scope`` / ``source_token_secret_key`` — the secret
  scope/key holding the PAT (a reference, never the token).

Strictly additive, all columns defaulted to ''. Idempotent + re-runnable on
both dialects: Postgres uses ``ADD COLUMN IF NOT EXISTS``; SQLite (tests)
PRAGMA-checks first since its ``ADD COLUMN`` lacks ``IF NOT EXISTS``. Guarded on
table existence so minimal migration-test fixtures are a no-op; a real install
always has ``agent_config`` from ``v_0_1_0``'s ``create_all``.

The DDL is written as string LITERALS (not f-strings) so the owner-script drift
gate (``tests/test_app/test_migration_drift_owner.py``) can regex the
``(table, column, type)`` triples straight out of this module and prove
``scripts/db/migrate.py`` mirrors them.
"""

from __future__ import annotations

from sqlalchemy import inspect, text
from sqlalchemy.engine import Connection, Engine

from .registry import Migration

# Columns added to ``agent_config``. Single source of truth for the apply loop
# and the migration test. Type (VARCHAR DEFAULT '') matches the owner-script
# triples.
_NEW_COLUMNS: tuple[str, ...] = (
    "source_auth_mode",
    "source_github_app_id",
    "source_github_app_installation_id",
    "source_github_app_secret_scope",
    "source_github_app_secret_key",
    "source_token_secret_scope",
    "source_token_secret_key",
)

# Literal per-column DDL. Postgres uses ``ADD COLUMN IF NOT EXISTS`` (idempotent
# in one statement); SQLite lacks that qualifier, so its DDL is bare and guarded
# by a PRAGMA existence check in ``_add_column``. Both branches spell the same
# ``(agent_config, <column>, VARCHAR DEFAULT '')`` triple the drift gate compares.
_ADD_SOURCE_AUTH_MODE_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS source_auth_mode VARCHAR DEFAULT ''"
)
_ADD_SOURCE_AUTH_MODE_SQLITE = (
    "ALTER TABLE agent_config ADD COLUMN source_auth_mode VARCHAR DEFAULT ''"
)
_ADD_SOURCE_GITHUB_APP_ID_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS source_github_app_id VARCHAR DEFAULT ''"
)
_ADD_SOURCE_GITHUB_APP_ID_SQLITE = (
    "ALTER TABLE agent_config ADD COLUMN source_github_app_id VARCHAR DEFAULT ''"
)
_ADD_SOURCE_GITHUB_APP_INSTALLATION_ID_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS "
    "source_github_app_installation_id VARCHAR DEFAULT ''"
)
_ADD_SOURCE_GITHUB_APP_INSTALLATION_ID_SQLITE = (
    "ALTER TABLE agent_config ADD COLUMN source_github_app_installation_id VARCHAR DEFAULT ''"
)
_ADD_SOURCE_GITHUB_APP_SECRET_SCOPE_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS "
    "source_github_app_secret_scope VARCHAR DEFAULT ''"
)
_ADD_SOURCE_GITHUB_APP_SECRET_SCOPE_SQLITE = (
    "ALTER TABLE agent_config ADD COLUMN source_github_app_secret_scope VARCHAR DEFAULT ''"
)
_ADD_SOURCE_GITHUB_APP_SECRET_KEY_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS "
    "source_github_app_secret_key VARCHAR DEFAULT ''"
)
_ADD_SOURCE_GITHUB_APP_SECRET_KEY_SQLITE = (
    "ALTER TABLE agent_config ADD COLUMN source_github_app_secret_key VARCHAR DEFAULT ''"
)
_ADD_SOURCE_TOKEN_SECRET_SCOPE_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS "
    "source_token_secret_scope VARCHAR DEFAULT ''"
)
_ADD_SOURCE_TOKEN_SECRET_SCOPE_SQLITE = (
    "ALTER TABLE agent_config ADD COLUMN source_token_secret_scope VARCHAR DEFAULT ''"
)
_ADD_SOURCE_TOKEN_SECRET_KEY_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS "
    "source_token_secret_key VARCHAR DEFAULT ''"
)
_ADD_SOURCE_TOKEN_SECRET_KEY_SQLITE = (
    "ALTER TABLE agent_config ADD COLUMN source_token_secret_key VARCHAR DEFAULT ''"
)

_PG_DDL: dict[str, str] = {
    "source_auth_mode": _ADD_SOURCE_AUTH_MODE_PG,
    "source_github_app_id": _ADD_SOURCE_GITHUB_APP_ID_PG,
    "source_github_app_installation_id": _ADD_SOURCE_GITHUB_APP_INSTALLATION_ID_PG,
    "source_github_app_secret_scope": _ADD_SOURCE_GITHUB_APP_SECRET_SCOPE_PG,
    "source_github_app_secret_key": _ADD_SOURCE_GITHUB_APP_SECRET_KEY_PG,
    "source_token_secret_scope": _ADD_SOURCE_TOKEN_SECRET_SCOPE_PG,
    "source_token_secret_key": _ADD_SOURCE_TOKEN_SECRET_KEY_PG,
}
_SQLITE_DDL: dict[str, str] = {
    "source_auth_mode": _ADD_SOURCE_AUTH_MODE_SQLITE,
    "source_github_app_id": _ADD_SOURCE_GITHUB_APP_ID_SQLITE,
    "source_github_app_installation_id": _ADD_SOURCE_GITHUB_APP_INSTALLATION_ID_SQLITE,
    "source_github_app_secret_scope": _ADD_SOURCE_GITHUB_APP_SECRET_SCOPE_SQLITE,
    "source_github_app_secret_key": _ADD_SOURCE_GITHUB_APP_SECRET_KEY_SQLITE,
    "source_token_secret_scope": _ADD_SOURCE_TOKEN_SECRET_SCOPE_SQLITE,
    "source_token_secret_key": _ADD_SOURCE_TOKEN_SECRET_KEY_SQLITE,
}


def _add_column(conn: Connection, column: str, is_postgres: bool) -> None:
    if is_postgres:
        conn.execute(text(_PG_DDL[column]))
        return
    # SQLite (tests): ADD COLUMN lacks IF NOT EXISTS, so check first.
    cols = conn.execute(text("PRAGMA table_info(agent_config)")).fetchall()
    present = {row[1] for row in cols}
    if column not in present:
        conn.execute(text(_SQLITE_DDL[column]))


def apply(engine: Engine) -> None:
    """Add the seven defaulted ``agent_config.source_*`` read-auth columns.

    Idempotent + re-runnable; one transaction, both dialects."""
    is_postgres = engine.dialect.name == "postgresql"
    with engine.begin() as conn:
        if not inspect(conn).has_table("agent_config"):
            return
        for column in _NEW_COLUMNS:
            _add_column(conn, column, is_postgres)


MIGRATION = Migration(
    version="0.7.2",
    apply=apply,
    description=(
        "Add defaulted agent_config.source_auth_mode + source_github_app_id + "
        "source_github_app_installation_id + source_github_app_secret_scope + "
        "source_github_app_secret_key + source_token_secret_scope + "
        "source_token_secret_key to persist per-installation source READ-auth "
        "(pre-existing rows default to '' = unconfigured → env → anonymous)."
    ),
)
