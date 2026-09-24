"""Migration 0.5.0 — imports are syncs, not runs.

Reverses D-033's "synthetic Run per import" pattern. Imports of a
hand-vibed model.json from a Volume are a pure control-plane sync —
the model was vibed elsewhere, the app is just landing it in
Lakebase. No Run row, no progress events, no orchestrator dispatch.

Schema changes:

1. ``run_artifacts.run_id`` becomes nullable so the indexer can write
   rows for an imported ModelVersion without a parent Run. The agent-
   path still passes a real ``run_id`` (the producing Run); only the
   import path passes ``NULL``.
2. ``model_versions.import_source_path`` records the Volume path the
   model.json was imported from (NULL for agent-produced versions).
3. ``model_versions.imported_at`` records the import timestamp (NULL
   for agent-produced versions).

The two new columns are the durable provenance the synthetic Run row
used to carry in its ``progress_message``. Strictly additive on those
two columns; the ``run_id`` change is a constraint relaxation, never
data-destructive.

Idempotent on both dialects.
"""

from __future__ import annotations

from sqlalchemy import text
from sqlalchemy.engine import Engine

from .registry import Migration


def apply(engine: Engine) -> None:
    """Relax run_artifacts.run_id + add model_versions provenance columns."""
    dialect = engine.dialect.name
    with engine.begin() as conn:
        if dialect == "postgresql":
            conn.execute(
                text(
                    "ALTER TABLE run_artifacts "
                    "ALTER COLUMN run_id DROP NOT NULL"
                )
            )
            conn.execute(
                text(
                    "ALTER TABLE model_versions "
                    "ADD COLUMN IF NOT EXISTS import_source_path VARCHAR"
                )
            )
            conn.execute(
                text(
                    "ALTER TABLE model_versions "
                    "ADD COLUMN IF NOT EXISTS imported_at TIMESTAMP"
                )
            )
        else:
            # SQLite (tests-only). SQLite has no ALTER COLUMN DROP NOT NULL —
            # the column is recreated by SQLModel.metadata.create_all in the
            # test fixture against the updated model definition. For the
            # provenance columns, PRAGMA-check first since SQLite lacks
            # ADD COLUMN IF NOT EXISTS.
            cols = conn.execute(
                text("PRAGMA table_info(model_versions)")
            ).fetchall()
            present = {row[1] for row in cols}
            if "import_source_path" not in present:
                conn.execute(
                    text(
                        "ALTER TABLE model_versions "
                        "ADD COLUMN import_source_path VARCHAR"
                    )
                )
            if "imported_at" not in present:
                conn.execute(
                    text(
                        "ALTER TABLE model_versions "
                        "ADD COLUMN imported_at TIMESTAMP"
                    )
                )


MIGRATION = Migration(
    version="0.5.0",
    apply=apply,
    description=(
        "Relax run_artifacts.run_id to nullable and add "
        "ModelVersion.import_source_path + imported_at "
        "(imports are syncs, not runs)"
    ),
)
