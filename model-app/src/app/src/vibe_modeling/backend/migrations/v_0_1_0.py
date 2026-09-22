"""Initial schema migration — Phase 4.5 closeout.

Single create-all of the SQLModel metadata graph. We start the migration
log at 0.1.0 (not 1.0.0) because the schema is still pre-prod —
``PRE_PROD_DESTRUCTIVE_RESET`` is gating destructive wipes against this
exact version while we iterate. v1.0.0 lands when the constant is
deleted.
"""

from __future__ import annotations

from sqlalchemy.engine import Engine
from sqlmodel import SQLModel

from .registry import Migration


def apply(engine: Engine) -> None:
    """Initial schema. Equivalent to ``SQLModel.metadata.create_all``.

    Importing :mod:`db_models` is required so every table is registered
    on the metadata graph before ``create_all`` walks it. Without the
    import, fresh installs would land with an empty database.
    """
    # Side-effect import: registers every table on SQLModel.metadata.
    from .. import db_models  # noqa: F401

    SQLModel.metadata.create_all(engine)


MIGRATION = Migration(
    version="0.1.0",
    apply=apply,
    description="Initial schema (Phase 4.5 closeout)",
)
