"""Migration 0.4.0 — add ModelVersion.sync_state + sync_error_text.

Surface post-run sync failures to the UI instead of silently logging.
The columns are populated at every catch site that previously just
called ``logger.exception(...)`` (vibe_iterate post-success sync,
``_terminal_success`` in _generation_common, and the
``_finalize_session_completion`` retry/fail path in progress_tracker);
callers default to ``sync_state='ok'`` so existing rows keep behaving
exactly as before.

Strictly additive — no existing column is touched. Idempotent because
both ALTERs use ``ADD COLUMN IF NOT EXISTS`` on Postgres and a PRAGMA
guard on SQLite (tests-only) that already lacks ``IF NOT EXISTS`` for
``ADD COLUMN``.

The DDL is written as full-statement string literals (rather than
f-strings) so the migration-drift test's regex can parse the table /
column / type triple straight out of the source AST.
"""

from __future__ import annotations

from sqlalchemy import text
from sqlalchemy.engine import Engine

from .registry import Migration


def apply(engine: Engine) -> None:
    """Add ``model_versions.sync_state`` and ``sync_error_text`` if missing."""
    dialect = engine.dialect.name
    with engine.begin() as conn:
        if dialect == "postgresql":
            conn.execute(
                text(
                    "ALTER TABLE model_versions "
                    "ADD COLUMN IF NOT EXISTS sync_state "
                    "VARCHAR DEFAULT 'ok' NOT NULL"
                )
            )
            conn.execute(
                text(
                    "ALTER TABLE model_versions "
                    "ADD COLUMN IF NOT EXISTS sync_error_text TEXT"
                )
            )
        else:
            # SQLite (tests-only). No ``IF NOT EXISTS`` for ADD COLUMN —
            # PRAGMA-check first.
            cols = conn.execute(
                text("PRAGMA table_info(model_versions)")
            ).fetchall()
            present = {row[1] for row in cols}
            if "sync_state" not in present:
                conn.execute(
                    text(
                        "ALTER TABLE model_versions "
                        "ADD COLUMN sync_state VARCHAR DEFAULT 'ok' NOT NULL"
                    )
                )
            if "sync_error_text" not in present:
                conn.execute(
                    text(
                        "ALTER TABLE model_versions "
                        "ADD COLUMN sync_error_text TEXT"
                    )
                )


MIGRATION = Migration(
    version="0.4.0",
    apply=apply,
    description=(
        "Add ModelVersion.sync_state + sync_error_text "
        "(post-run sync failure surfacing)"
    ),
)
