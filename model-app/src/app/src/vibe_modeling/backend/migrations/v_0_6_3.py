"""Migration 0.6.3 — Review-state spine + agent next-vibe category column.

Single migration for the 0.6.3 release. Three changes:

New table (1):
  - ``product_reviews`` — sparse three-state review marker
    ``(id, version_id FK, product_id FK, state {reviewed|not_reviewed|
    no_review_needed}, reviewer, reviewed_at)``, UNIQUE(version_id,
    product_id). A row exists only on an explicit user mark; absence ⇒ a
    computed default (see ``backend/review.py``). Supersedes the v_0_6_2
    ``domain_reviews`` table (ADR D-044): ``domain_reviews`` shipped in
    v_0_6_2 but its marking UI never went live, so we drop-replace rather
    than backfill.

Dropped table (1):
  - ``domain_reviews`` — the domain-binary marker from v_0_6_2.

Changed table (additive column only):
  - ``vibe_inputs`` gains a nullable ``category VARCHAR`` so an agent
    next-vibe finding carries its classification as a structured field
    (static_analysis / priority_remediation / other), mirrored by the
    ``NextVibeCategory`` enum on the Pydantic layer. Null for ``origin=user``
    inputs — feedback has no category. This is the structured source the
    metrics layer counts; the classification is NOT recovered from a text
    prefix.

Idempotent on both dialects: ``CREATE TABLE IF NOT EXISTS`` + ``DROP TABLE
IF EXISTS`` + ``ADD COLUMN`` (Postgres: ``ADD COLUMN IF NOT EXISTS``;
SQLite: PRAGMA-guarded ``ADD COLUMN``). The DROP runs after the CREATE so a
partial-failure retry is safe. The UNIQUE constraint rides the ``CREATE
TABLE`` body so it needs no separate idempotency guard. The migration emits
literal ALTER statements per dialect so the migration-drift test
(``tests/test_app/test_migration_drift_owner.py``) extracts the
``(vibe_inputs, category, VARCHAR)`` triple and couples it to the owner
script ``scripts/db/migrate.py``.
"""

from __future__ import annotations

from sqlalchemy import text
from sqlalchemy.engine import Engine

from .registry import Migration


_CREATE_TABLES = [
    """
    CREATE TABLE IF NOT EXISTS product_reviews (
        id VARCHAR NOT NULL PRIMARY KEY,
        version_id VARCHAR NOT NULL REFERENCES model_versions(id),
        product_id VARCHAR NOT NULL REFERENCES products(id),
        state VARCHAR NOT NULL DEFAULT 'not_reviewed',
        reviewer VARCHAR NOT NULL DEFAULT '',
        reviewed_at TIMESTAMP NOT NULL,
        CONSTRAINT uq_product_reviews_version_product
            UNIQUE (version_id, product_id)
    )
    """,
]

_CREATE_INDEXES = [
    "CREATE INDEX IF NOT EXISTS ix_product_reviews_version_id ON product_reviews (version_id)",
    "CREATE INDEX IF NOT EXISTS ix_product_reviews_product_id ON product_reviews (product_id)",
    "CREATE INDEX IF NOT EXISTS ix_product_reviews_state ON product_reviews (state)",
]

# domain_reviews is superseded by product_reviews. DROP after the CREATE so a
# reconcile partial-failure retry can't leave the schema without either table.
# CASCADE on Postgres so any dependent objects (indexes) go with it; SQLite
# drops indexes implicitly.
_DROP_TABLES_PG = [
    "DROP TABLE IF EXISTS domain_reviews CASCADE",
]
_DROP_TABLES_SQLITE = [
    "DROP TABLE IF EXISTS domain_reviews",
]

_ADD_COLUMN_PG = "ALTER TABLE vibe_inputs ADD COLUMN IF NOT EXISTS category VARCHAR"
_ADD_COLUMN_SQLITE = "ALTER TABLE vibe_inputs ADD COLUMN category VARCHAR"

# The full detailed business description → the agent's model_vibes channel on
# the initial run. Additive TEXT DEFAULT '' so EXISTING rows backfill to ''
# (not NULL) — BusinessOut.business_vibes is a non-null str.
_ADD_BUSINESS_VIBES_PG = "ALTER TABLE businesses ADD COLUMN IF NOT EXISTS business_vibes TEXT DEFAULT ''"
_ADD_BUSINESS_VIBES_SQLITE = "ALTER TABLE businesses ADD COLUMN business_vibes TEXT DEFAULT ''"

_CREATE_VIBE_INPUTS_CATEGORY_INDEX = (
    "CREATE INDEX IF NOT EXISTS ix_vibe_inputs_category ON vibe_inputs (category)"
)


def apply(engine: Engine) -> None:
    """Create product_reviews, drop the superseded domain_reviews table, and
    add the nullable vibe_inputs.category column."""
    dialect = engine.dialect.name
    with engine.begin() as conn:
        for ddl in _CREATE_TABLES:
            conn.execute(text(ddl))
        for ddl in _CREATE_INDEXES:
            conn.execute(text(ddl))
        drops = _DROP_TABLES_PG if dialect == "postgresql" else _DROP_TABLES_SQLITE
        for ddl in drops:
            conn.execute(text(ddl))
        if dialect == "postgresql":
            conn.execute(text(_ADD_COLUMN_PG))
            conn.execute(text(_ADD_BUSINESS_VIBES_PG))
        else:
            # SQLite (tests). PRAGMA-check first since SQLite ADD COLUMN
            # lacks IF NOT EXISTS.
            cols = conn.execute(text("PRAGMA table_info(vibe_inputs)")).fetchall()
            present = {row[1] for row in cols}
            if "category" not in present:
                conn.execute(text(_ADD_COLUMN_SQLITE))
            bcols = conn.execute(text("PRAGMA table_info(businesses)")).fetchall()
            if "business_vibes" not in {row[1] for row in bcols}:
                conn.execute(text(_ADD_BUSINESS_VIBES_SQLITE))
        conn.execute(text(_CREATE_VIBE_INPUTS_CATEGORY_INDEX))


MIGRATION = Migration(
    version="0.6.3",
    apply=apply,
    description=(
        "Review-state spine: add the sparse product-canonical "
        "product_reviews table; drop the superseded domain_reviews table "
        "(ADR D-044); add nullable vibe_inputs.category column (agent "
        "next-vibe classification: static_analysis / priority_remediation / "
        "other; null for origin=user)"
    ),
)
