"""Migration 0.7.1 — persist the upstream agent-release monitor cache.

Adds four nullable columns to ``agent_config`` (the singleton row) so the
agent-compat health surface (Surface 2) can live-read the canonical repo
notebook's version markers once and serve the result for 7 days:

* ``upstream_release_version`` — the upstream notebook's ``__RELEASE_VERSION__``
  (the app-agent interface identity, e.g. ``v0.8.0``).
* ``upstream_agent_version`` — the upstream ``__AGENT_VERSION__`` build counter
  (e.g. ``4.9.10``).
* ``upstream_checked_at`` — when the cache was last refreshed (TTL anchor).
* ``upstream_check_error`` — the last fetch error text, else NULL.

Strictly additive, all columns nullable. Idempotent + re-runnable on both
dialects: Postgres uses ``ADD COLUMN IF NOT EXISTS``; SQLite (tests) PRAGMA-
checks first since its ``ADD COLUMN`` lacks ``IF NOT EXISTS``. Guarded on table
existence so minimal migration-test fixtures are a no-op; a real install always
has ``agent_config`` from ``v_0_1_0``'s ``create_all``.

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
# and the migration test. Types (TEXT / TIMESTAMP) match the owner-script triples.
_NEW_COLUMNS: tuple[str, ...] = (
    "upstream_release_version",
    "upstream_agent_version",
    "upstream_checked_at",
    "upstream_check_error",
)

# Literal per-column DDL. Postgres uses ``ADD COLUMN IF NOT EXISTS`` (idempotent
# in one statement); SQLite lacks that qualifier, so its DDL is bare and guarded
# by a PRAGMA existence check in ``_add_nullable_column``. Both branches spell
# the same ``(agent_config, <column>, <type>)`` triple the drift gate compares.
_ADD_UPSTREAM_RELEASE_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS upstream_release_version TEXT"
)
_ADD_UPSTREAM_RELEASE_SQLITE = (
    "ALTER TABLE agent_config ADD COLUMN upstream_release_version TEXT"
)
_ADD_UPSTREAM_AGENT_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS upstream_agent_version TEXT"
)
_ADD_UPSTREAM_AGENT_SQLITE = (
    "ALTER TABLE agent_config ADD COLUMN upstream_agent_version TEXT"
)
_ADD_UPSTREAM_CHECKED_AT_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS upstream_checked_at TIMESTAMP"
)
_ADD_UPSTREAM_CHECKED_AT_SQLITE = (
    "ALTER TABLE agent_config ADD COLUMN upstream_checked_at TIMESTAMP"
)
_ADD_UPSTREAM_CHECK_ERROR_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS upstream_check_error TEXT"
)
_ADD_UPSTREAM_CHECK_ERROR_SQLITE = (
    "ALTER TABLE agent_config ADD COLUMN upstream_check_error TEXT"
)

_PG_DDL: dict[str, str] = {
    "upstream_release_version": _ADD_UPSTREAM_RELEASE_PG,
    "upstream_agent_version": _ADD_UPSTREAM_AGENT_PG,
    "upstream_checked_at": _ADD_UPSTREAM_CHECKED_AT_PG,
    "upstream_check_error": _ADD_UPSTREAM_CHECK_ERROR_PG,
}
_SQLITE_DDL: dict[str, str] = {
    "upstream_release_version": _ADD_UPSTREAM_RELEASE_SQLITE,
    "upstream_agent_version": _ADD_UPSTREAM_AGENT_SQLITE,
    "upstream_checked_at": _ADD_UPSTREAM_CHECKED_AT_SQLITE,
    "upstream_check_error": _ADD_UPSTREAM_CHECK_ERROR_SQLITE,
}


def _add_nullable_column(conn: Connection, column: str, is_postgres: bool) -> None:
    if is_postgres:
        conn.execute(text(_PG_DDL[column]))
        return
    # SQLite (tests): ADD COLUMN lacks IF NOT EXISTS, so check first.
    cols = conn.execute(text("PRAGMA table_info(agent_config)")).fetchall()
    present = {row[1] for row in cols}
    if column not in present:
        conn.execute(text(_SQLITE_DDL[column]))


def apply(engine: Engine) -> None:
    """Add the four nullable ``agent_config.upstream_*`` monitor-cache columns.

    Idempotent + re-runnable; one transaction, both dialects."""
    is_postgres = engine.dialect.name == "postgresql"
    with engine.begin() as conn:
        if not inspect(conn).has_table("agent_config"):
            return
        for column in _NEW_COLUMNS:
            _add_nullable_column(conn, column, is_postgres)


MIGRATION = Migration(
    version="0.7.1",
    apply=apply,
    description=(
        "Add nullable agent_config.upstream_release_version + "
        "upstream_agent_version + upstream_checked_at + upstream_check_error "
        "to cache the upstream agent-release monitor's live read of the "
        "canonical repo notebook (7-day TTL; pre-existing rows stay NULL)."
    ),
)
