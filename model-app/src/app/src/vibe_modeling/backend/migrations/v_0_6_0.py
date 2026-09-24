"""Migration 0.6.0 — operator-controlled agent job max_concurrent_runs.

Adds ``agent_config.max_concurrent_runs`` so operators can raise the
persistent agent job's concurrency cap from the Settings page. The
default (and minimum supported by the API) is 3 — below that the
documented benign overlaps (unified-pipeline phase transition and
cancel-with-rollback cleanup) collide.

Strictly additive on a single column. Idempotent on both dialects.
"""

from __future__ import annotations

from sqlalchemy import text
from sqlalchemy.engine import Engine

from .registry import Migration


def apply(engine: Engine) -> None:
    """Add agent_config.max_concurrent_runs (default 3, NOT NULL)."""
    dialect = engine.dialect.name
    with engine.begin() as conn:
        if dialect == "postgresql":
            conn.execute(
                text(
                    "ALTER TABLE agent_config "
                    "ADD COLUMN IF NOT EXISTS max_concurrent_runs "
                    "INTEGER NOT NULL DEFAULT 3"
                )
            )
        else:
            # SQLite (tests). PRAGMA-check first since SQLite ADD COLUMN
            # lacks IF NOT EXISTS.
            cols = conn.execute(
                text("PRAGMA table_info(agent_config)")
            ).fetchall()
            present = {row[1] for row in cols}
            if "max_concurrent_runs" not in present:
                conn.execute(
                    text(
                        "ALTER TABLE agent_config "
                        "ADD COLUMN max_concurrent_runs "
                        "INTEGER NOT NULL DEFAULT 3"
                    )
                )


MIGRATION = Migration(
    version="0.6.0",
    apply=apply,
    description=(
        "Add agent_config.max_concurrent_runs (default 3, NOT NULL) "
        "for operator-controlled persistent agent job concurrency cap"
    ),
)
