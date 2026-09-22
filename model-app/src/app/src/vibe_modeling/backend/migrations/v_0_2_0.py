"""Migration 0.2.0 — add Run.business_context_text column.

Additive: inserts an empty-default TEXT column on the ``runs`` table so
the run-detail UI can surface the business context the user typed at
run-creation time. Runs created before this migration (or runs whose
intent doesn't carry user-typed text — revert, import, install,
uninstall) get an empty string.
"""

from __future__ import annotations

from sqlalchemy import text
from sqlalchemy.engine import Engine

from .registry import Migration


def apply(engine: Engine) -> None:
    """Add the ``business_context_text`` column to ``runs`` if absent.

    Written as an idempotent ADD COLUMN ... IF NOT EXISTS so reconcile
    can retry safely after a partial failure. SQLite doesn't support
    IF NOT EXISTS for ALTER TABLE, so we catch the OperationalError
    that fires when the column already exists and swallow it.
    """
    dialect = engine.dialect.name
    with engine.begin() as conn:
        if dialect == "postgresql":
            conn.execute(
                text(
                    "ALTER TABLE runs "
                    "ADD COLUMN IF NOT EXISTS business_context_text TEXT DEFAULT ''"
                )
            )
        else:
            # SQLite path (test-only). ALTER TABLE doesn't support IF NOT
            # EXISTS; check information manually via PRAGMA.
            cols = conn.execute(text("PRAGMA table_info(runs)")).fetchall()
            col_names = {row[1] for row in cols}  # row[1] == column name
            if "business_context_text" not in col_names:
                conn.execute(
                    text(
                        "ALTER TABLE runs ADD COLUMN business_context_text TEXT DEFAULT ''"
                    )
                )


MIGRATION = Migration(
    version="0.2.0",
    apply=apply,
    description="Add Run.business_context_text (additive, nullable-equivalent TEXT)",
)
