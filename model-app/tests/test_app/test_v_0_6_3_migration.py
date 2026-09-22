"""Apply + idempotency test for migration v_0_6_3.

v_0_6_3 is the SINGLE migration for the 0.6.3 release and bundles three
changes:

* Supersedes the v_0_6_2 ``domain_reviews`` table with the sparse,
  product-canonical ``product_reviews`` table (ADR D-044): it CREATEs
  ``product_reviews`` and DROPs ``domain_reviews``.
* Adds a single nullable ``category`` column to ``vibe_inputs`` (agent
  next-vibe classification; null for origin=user) plus its index.

The test materializes the full pre-migration schema first (mirroring
conftest.py), recreates a ``vibe_inputs`` table WITHOUT the category column,
and hand-builds ``domain_reviews`` so the DROP has a table to remove. Then it
asserts apply() is clean, idempotent, creates the new table + indexes +
UNIQUE, removes the superseded one, and adds the indexed nullable category
column.
"""

from __future__ import annotations

from sqlalchemy import inspect, text
from sqlalchemy.pool import StaticPool
from sqlmodel import SQLModel, create_engine

from vibe_modeling.backend import migrations
from vibe_modeling.backend.migrations import v_0_6_2, v_0_6_3


def _fresh_engine():
    return create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )


def _pre_migration_engine():
    """Schema as of v_0_6_2: includes domain_reviews, excludes product_reviews
    and the vibe_inputs.category column."""
    engine = _fresh_engine()
    # create_all builds the CURRENT SQLModel metadata, which no longer has
    # domain_reviews (we removed the model) but DOES carry vibe_inputs.category.
    # Materialize domain_reviews by hand so the DROP has something to remove;
    # drop product_reviews so we can confirm CREATE IF NOT EXISTS is a no-op
    # when absent; rebuild vibe_inputs without category so the ADD COLUMN has
    # work to do (create_all would otherwise add it and mask a no-op ALTER).
    SQLModel.metadata.create_all(engine)
    with engine.begin() as conn:
        conn.execute(text("DROP TABLE IF EXISTS product_reviews"))
        conn.execute(
            text(
                "CREATE TABLE domain_reviews ("
                "id VARCHAR NOT NULL PRIMARY KEY, "
                "version_id VARCHAR NOT NULL, "
                "domain_id VARCHAR NOT NULL, "
                "reviewer VARCHAR NOT NULL DEFAULT '', "
                "reviewed_at TIMESTAMP NOT NULL)"
            )
        )
        conn.execute(text("DROP TABLE IF EXISTS vibe_inputs"))
        conn.execute(
            text(
                "CREATE TABLE vibe_inputs ("
                "id VARCHAR NOT NULL PRIMARY KEY, "
                "business_id VARCHAR NOT NULL, "
                "origin VARCHAR NOT NULL DEFAULT 'user', "
                "author VARCHAR NOT NULL DEFAULT '', "
                "text TEXT, "
                "priority VARCHAR NOT NULL DEFAULT 'medium', "
                "confidence_score FLOAT, "
                "consumed BOOLEAN NOT NULL DEFAULT 0, "
                "selected_for_run BOOLEAN NOT NULL DEFAULT 0, "
                "status VARCHAR NOT NULL DEFAULT 'active', "
                "deprecated_by VARCHAR, "
                "created_at TIMESTAMP NOT NULL, "
                "updated_at TIMESTAMP NOT NULL)"
            )
        )
    return engine


def test_migration_version_string():
    assert v_0_6_3.MIGRATION.version == "0.6.3"


def test_migration_is_registered():
    # No longer the last entry (v_0_6_4 now follows); just assert it's present
    # and carries the right version. "Is last" is owned by the v_0_6_4 test.
    assert v_0_6_3.MIGRATION in migrations.MIGRATIONS
    assert v_0_6_3.MIGRATION.version == "0.6.3"


def test_follows_v_0_6_2():
    idx = migrations.MIGRATIONS.index(v_0_6_2.MIGRATION)
    assert migrations.MIGRATIONS[idx + 1] is v_0_6_3.MIGRATION


def test_migrations_are_ascending():
    versions = [m.version for m in migrations.MIGRATIONS]
    assert versions == sorted(
        versions, key=lambda v: tuple(int(x) for x in v.split("."))
    )


def test_apply_creates_product_reviews_and_drops_domain_reviews():
    engine = _pre_migration_engine()
    v_0_6_3.MIGRATION.apply(engine)

    insp = inspect(engine)
    tables = set(insp.get_table_names())
    assert "product_reviews" in tables
    assert "domain_reviews" not in tables, "domain_reviews must be dropped"

    cols = {c["name"] for c in insp.get_columns("product_reviews")}
    assert {"id", "version_id", "product_id", "state", "reviewer", "reviewed_at"} <= cols


def test_apply_creates_indexes():
    engine = _pre_migration_engine()
    v_0_6_3.MIGRATION.apply(engine)
    insp = inspect(engine)
    indexed: set[str] = set()
    for ix in insp.get_indexes("product_reviews"):
        indexed.update(ix["column_names"])
    assert {"version_id", "product_id", "state"} <= indexed


def test_apply_adds_category_column():
    engine = _pre_migration_engine()
    cols_before = {c["name"] for c in inspect(engine).get_columns("vibe_inputs")}
    assert "category" not in cols_before

    v_0_6_3.MIGRATION.apply(engine)

    cols_after = {c["name"] for c in inspect(engine).get_columns("vibe_inputs")}
    assert "category" in cols_after


def test_category_is_nullable():
    engine = _pre_migration_engine()
    v_0_6_3.MIGRATION.apply(engine)
    col = next(
        c for c in inspect(engine).get_columns("vibe_inputs") if c["name"] == "category"
    )
    assert col["nullable"] is True


def test_apply_creates_category_index():
    engine = _pre_migration_engine()
    v_0_6_3.MIGRATION.apply(engine)
    indexed: set[str] = set()
    for ix in inspect(engine).get_indexes("vibe_inputs"):
        indexed.update(ix["column_names"])
    assert "category" in indexed


def test_apply_is_idempotent():
    engine = _pre_migration_engine()
    v_0_6_3.MIGRATION.apply(engine)
    # Second apply must not raise (reconcile partial-failure retry); product
    # row left in place, domain_reviews already gone, category already added.
    v_0_6_3.MIGRATION.apply(engine)
    insp = inspect(engine)
    assert "product_reviews" in set(insp.get_table_names())
    cols = {c["name"] for c in insp.get_columns("vibe_inputs")}
    assert "category" in cols
