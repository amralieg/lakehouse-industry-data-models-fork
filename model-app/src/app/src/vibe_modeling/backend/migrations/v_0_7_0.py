"""Migration 0.7.0 — persist agent/release version provenance on ModelVersion.

Adds two nullable columns to ``model_versions``:

* ``agent_version`` — the agent-logic counter (``4.x.y`` from the 0.8.0 agent
  line on) stamped in the model.json envelope.
* ``release_version`` — the public/compat release identity (``0.8.0``),
  decoupled from ``agent_version`` from the 0.8.0 agent line on.

Both are populated at sync/import time from the model.json envelope (via
``agent_compat.extract_version_provenance``); pre-existing rows stay NULL
(backfill = leave NULL — model.json is re-read to classify them on demand).

Strictly additive, both columns nullable. Idempotent + re-runnable on both
dialects: Postgres uses ``ADD COLUMN IF NOT EXISTS``; SQLite (tests) PRAGMA-
checks first since its ``ADD COLUMN`` lacks ``IF NOT EXISTS``. Guarded on table
existence so the minimal migration-test fixtures (which create only the tables
their assertions touch) are a no-op; a real install always has
``model_versions`` from ``v_0_1_0``'s ``create_all``.

The DDL is written as string LITERALS (not f-strings) so the owner-script
drift gate (``tests/test_app/test_migration_drift_owner.py``) can regex the
``(table, column, type)`` triples straight out of this module's source and
prove ``scripts/db/migrate.py`` mirrors them — an f-string like
``f"ALTER TABLE {table} ..."`` is invisible to that extractor and would let
the owner script silently drift, skipping the columns on the test workspaces
owner-path deploys.
"""

from __future__ import annotations

from sqlalchemy import inspect, text
from sqlalchemy.engine import Connection, Engine

from .registry import Migration

# Columns added to ``model_versions`` (both nullable TEXT, no default). Single
# source of truth for the apply loop and the migration test.
_NEW_COLUMNS: tuple[str, ...] = ("agent_version", "release_version")

# Literal per-column DDL. Postgres uses ``ADD COLUMN IF NOT EXISTS`` (idempotent
# in one statement); SQLite lacks that qualifier, so its DDL is bare and guarded
# by a PRAGMA existence check in ``_add_nullable_text_column``. Both branches
# spell the same ``(model_versions, <column>, TEXT)`` triple the owner-script
# drift gate compares against.
_ADD_AGENT_VERSION_PG = (
    "ALTER TABLE model_versions ADD COLUMN IF NOT EXISTS agent_version TEXT"
)
_ADD_AGENT_VERSION_SQLITE = (
    "ALTER TABLE model_versions ADD COLUMN agent_version TEXT"
)
_ADD_RELEASE_VERSION_PG = (
    "ALTER TABLE model_versions ADD COLUMN IF NOT EXISTS release_version TEXT"
)
_ADD_RELEASE_VERSION_SQLITE = (
    "ALTER TABLE model_versions ADD COLUMN release_version TEXT"
)

_PG_DDL: dict[str, str] = {
    "agent_version": _ADD_AGENT_VERSION_PG,
    "release_version": _ADD_RELEASE_VERSION_PG,
}
_SQLITE_DDL: dict[str, str] = {
    "agent_version": _ADD_AGENT_VERSION_SQLITE,
    "release_version": _ADD_RELEASE_VERSION_SQLITE,
}


def _add_nullable_text_column(conn: Connection, column: str, is_postgres: bool) -> None:
    if is_postgres:
        conn.execute(text(_PG_DDL[column]))
        return
    # SQLite (tests): ADD COLUMN lacks IF NOT EXISTS, so check first.
    cols = conn.execute(text("PRAGMA table_info(model_versions)")).fetchall()
    present = {row[1] for row in cols}
    if column not in present:
        conn.execute(text(_SQLITE_DDL[column]))


def apply(engine: Engine) -> None:
    """Add ``model_versions.agent_version`` + ``.release_version`` (nullable).

    Idempotent + re-runnable; one transaction, both dialects."""
    is_postgres = engine.dialect.name == "postgresql"
    with engine.begin() as conn:
        if not inspect(conn).has_table("model_versions"):
            return
        for column in _NEW_COLUMNS:
            _add_nullable_text_column(conn, column, is_postgres)


MIGRATION = Migration(
    version="0.7.0",
    apply=apply,
    description=(
        "Add nullable model_versions.agent_version + model_versions."
        "release_version to persist the agent-logic counter (4.x.y) and the "
        "public/compat release identity (0.8.0) stamped in the model.json "
        "envelope at sync/import time (pre-existing rows stay NULL)."
    ),
)
