"""Migration 0.6.1 — operator-controlled vibe-run statistics opt-in.

Adds ``agent_config.collect_vibe_run_statistics`` so operators can opt
in to emitting identity-bearing job tags (business name, session id,
notebook path) on persistent agent job runs. Default ``false`` — on
upgrade, existing deployments stop emitting identity tags until the
operator flips the toggle in Settings.

Strictly additive on a single column. Idempotent on both dialects.
"""

from __future__ import annotations

from sqlalchemy import text
from sqlalchemy.engine import Engine

from .registry import Migration


def apply(engine: Engine) -> None:
    """Add agent_config.collect_vibe_run_statistics (default false, NOT NULL)."""
    dialect = engine.dialect.name
    with engine.begin() as conn:
        if dialect == "postgresql":
            conn.execute(
                text(
                    "ALTER TABLE agent_config "
                    "ADD COLUMN IF NOT EXISTS collect_vibe_run_statistics "
                    "BOOLEAN NOT NULL DEFAULT false"
                )
            )
        else:
            # SQLite (tests). PRAGMA-check first since SQLite ADD COLUMN
            # lacks IF NOT EXISTS.
            cols = conn.execute(
                text("PRAGMA table_info(agent_config)")
            ).fetchall()
            present = {row[1] for row in cols}
            if "collect_vibe_run_statistics" not in present:
                conn.execute(
                    text(
                        "ALTER TABLE agent_config "
                        "ADD COLUMN collect_vibe_run_statistics "
                        "BOOLEAN NOT NULL DEFAULT false"
                    )
                )


MIGRATION = Migration(
    version="0.6.1",
    apply=apply,
    description=(
        "Add agent_config.collect_vibe_run_statistics (default false, "
        "NOT NULL) for operator-controlled identity-tag opt-in"
    ),
)
