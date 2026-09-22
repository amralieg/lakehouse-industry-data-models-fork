"""Dialect-agnostic apply + idempotency test for migration v_0_6_2.

v_0_6_2 is the SINGLE feature migration for the whole Vibe Inputs redesign
(the model-versioning work Tasks 2/3/4): the redesign ships as one schema version, not a
version bump per task. It creates all 7 new tables (``vibe_inputs``,
``vibe_input_context_links``, ``run_input_links``, ``subdomains``,
``domain_reviews``, ``run_element_lineage``, ``backfill_status``) plus the
``previous_element_id`` lineage columns and ``products.subdomain_id`` in one
shot. It runs ``ALTER TABLE ... ADD COLUMN`` against the pre-existing element
tables — against a truly bare SQLite engine those ALTERs would fail because the
base tables don't exist — so the test first materializes the pre-migration
schema via ``SQLModel.metadata.create_all`` (mirroring conftest.py:118) and only
THEN calls ``apply()``. The value asserted is that ``apply()`` runs clean and is
idempotent on a realistic pre-existing schema, creates every table + index,
keeps the legacy tables (additive-only), and is the latest registered migration.
"""

from __future__ import annotations

from sqlalchemy import inspect
from sqlalchemy.pool import StaticPool
from sqlmodel import SQLModel, create_engine

from vibe_modeling.backend import migrations
from vibe_modeling.backend.migrations import v_0_6_2


NEW_TABLES = [
    "vibe_inputs",
    "vibe_input_context_links",
    "run_input_links",
    "subdomains",
    "domain_reviews",
    "run_element_lineage",
    "backfill_status",
]

NEW_COLUMNS = [
    ("domains", "previous_element_id"),
    ("products", "previous_element_id"),
    ("products", "subdomain_id"),
    ("attributes", "previous_element_id"),
    ("foreign_key_links", "previous_element_id"),
    ("subdomains", "previous_element_id"),
]

EXPECTED_INDEXES = {
    "run_element_lineage": {"run_id", "version_id", "element_type", "change_kind"},
}

KEPT_TABLES = ["run_next_vibe_links"]


def _fresh_engine():
    return create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )


def test_migration_version_string():
    assert v_0_6_2.MIGRATION.version == "0.6.2"


def test_migration_is_registered_in_order():
    # v_0_6_3 (review-state spine) now follows v_0_6_2. v_0_6_2 must remain
    # registered immediately before it.
    idx = migrations.MIGRATIONS.index(v_0_6_2.MIGRATION)
    assert migrations.MIGRATIONS[idx + 1].version == "0.6.3"


def test_migrations_are_ascending():
    versions = [m.version for m in migrations.MIGRATIONS]
    assert versions == sorted(versions, key=lambda v: tuple(int(x) for x in v.split(".")))


def test_apply_creates_new_tables_and_columns():
    engine = _fresh_engine()
    # Materialize the pre-migration schema first (the ALTERs need the base
    # element tables to exist).
    SQLModel.metadata.create_all(engine)
    v_0_6_2.MIGRATION.apply(engine)

    insp = inspect(engine)
    tables = set(insp.get_table_names())
    for t in NEW_TABLES:
        assert t in tables, f"migration did not create {t}"

    for table, col in NEW_COLUMNS:
        cols = {c["name"] for c in insp.get_columns(table)}
        assert col in cols, f"migration did not add {table}.{col}"


def test_apply_creates_indexes():
    engine = _fresh_engine()
    SQLModel.metadata.create_all(engine)
    v_0_6_2.MIGRATION.apply(engine)

    insp = inspect(engine)
    for table, expected_cols in EXPECTED_INDEXES.items():
        indexed_cols: set[str] = set()
        for ix in insp.get_indexes(table):
            indexed_cols.update(ix["column_names"])
        missing = expected_cols - indexed_cols
        assert not missing, f"{table} missing indexes for {missing}"


def test_apply_is_idempotent():
    engine = _fresh_engine()
    SQLModel.metadata.create_all(engine)
    v_0_6_2.MIGRATION.apply(engine)
    # Second apply must not raise (reconcile partial-failure retry).
    v_0_6_2.MIGRATION.apply(engine)

    insp = inspect(engine)
    tables = set(insp.get_table_names())
    for t in NEW_TABLES:
        assert t in tables


def test_additive_only_keeps_legacy_tables():
    engine = _fresh_engine()
    SQLModel.metadata.create_all(engine)
    v_0_6_2.MIGRATION.apply(engine)

    tables = set(inspect(engine).get_table_names())
    for t in KEPT_TABLES:
        assert t in tables, f"migration must not drop {t} (additive only)"
