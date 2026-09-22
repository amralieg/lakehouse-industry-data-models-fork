"""Migration 0.3.0 — drop Run.run_type and Run.rollback_plan columns.

Phase 5 Stage 1 retired the legacy state-machine columns from the
SQLModel definition (``db_models.Run``):

* ``run_type`` was a magic-string discriminator the poll-loop dispatched
  on. Its job is now done by ``Run.intent`` plus the operation log.
* ``rollback_plan`` was a JSON blob holding a single dispatch-time
  rollback recipe. Per-operation undo state now lives on
  ``RunOperation.rollback_state_json``, computed at apply time.

This migration removes the leftover columns from any Lakebase project
that pre-dates Phase 5. It is strictly subtractive: no other table or
column is touched.

Idempotent — re-running after a partial success is a no-op because both
ALTERs use ``DROP COLUMN IF EXISTS``. SQLite (test-only path) doesn't
support ``DROP COLUMN IF EXISTS`` until 3.35; we PRAGMA-check the
columns and only emit ``DROP COLUMN`` when present.
"""

from __future__ import annotations

from sqlalchemy import text
from sqlalchemy.engine import Engine

from .registry import Migration


_DOOMED_COLUMNS: tuple[str, ...] = ("run_type", "rollback_plan")


def apply(engine: Engine) -> None:
    """Drop ``runs.run_type`` and ``runs.rollback_plan`` if present.

    Both ALTERs run inside a single transaction on Postgres so a
    half-applied state can't leak; on SQLite (tests-only) we still
    issue them in order, since each is individually idempotent.
    """
    dialect = engine.dialect.name
    with engine.begin() as conn:
        if dialect == "postgresql":
            for column in _DOOMED_COLUMNS:
                conn.execute(
                    text(f"ALTER TABLE runs DROP COLUMN IF EXISTS {column}")
                )
        else:
            # SQLite path (test-only). DROP COLUMN landed in 3.35 and
            # IF EXISTS is not supported — manually check PRAGMA first.
            cols = conn.execute(text("PRAGMA table_info(runs)")).fetchall()
            present = {row[1] for row in cols}  # row[1] == column name
            for column in _DOOMED_COLUMNS:
                if column in present:
                    conn.execute(text(f"ALTER TABLE runs DROP COLUMN {column}"))


MIGRATION = Migration(
    version="0.3.0",
    apply=apply,
    description="Drop Run.run_type and Run.rollback_plan (Phase 5 state-machine retirement)",
)
