"""Tests for the ``v_0_6_6`` migration (delete integrity + feedback retirement).

The FK re-pointing half (steps 4-5) is Postgres-only and validated on the
Lakebase fork rehearsal; SQLite exercises steps 1-3 (log-check + table drops +
self-FK index creation) plus the ``FK_RULES`` shape and drift locks. The
``db_models`` ondelete pairing is asserted separately by
``test_fk_rules_ondelete_drift`` via SQLAlchemy metadata introspection.
"""

from __future__ import annotations

from sqlalchemy import create_engine, inspect, text
from sqlalchemy.pool import StaticPool

from vibe_modeling.backend import migrations as runtime_migrations
from vibe_modeling.backend.migrations.v_0_6_6 import (
    FK_RULES,
    MIGRATION,
    SELF_FK_INDEX_COLUMNS,
    TRGM_INDEX_COLUMNS,
    apply,
)


def _fresh_engine():
    return create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )


def _seed_legacy_tables(engine) -> None:
    """Create + seed the legacy tables the migration drops, including a
    cross-business ``feedback.last_run_id`` shape (feedback owned by A,
    last_run_id -> B's run) - the row shape behind the live 409 on the
    'Real Estate Reference Model' business the task calls out."""
    with engine.begin() as conn:
        conn.execute(text(
            "CREATE TABLE feedback (id VARCHAR PRIMARY KEY, business_id VARCHAR, "
            "version_id VARCHAR, last_run_id VARCHAR, status VARCHAR)"
        ))
        conn.execute(text(
            "CREATE TABLE run_feedback_links (run_id VARCHAR, feedback_id VARCHAR)"
        ))
        conn.execute(text(
            "CREATE TABLE backfill_status (id INTEGER PRIMARY KEY, state VARCHAR)"
        ))
        conn.execute(text(
            "CREATE TABLE vibe_inputs (id VARCHAR PRIMARY KEY, origin VARCHAR)"
        ))
        # Feedback owned by business A, last_run_id points at business B's run.
        conn.execute(text(
            "INSERT INTO feedback (id, business_id, version_id, last_run_id, status) "
            "VALUES ('fb1', 'bizA', 'verA', 'runB', 'open')"
        ))
        conn.execute(text(
            "INSERT INTO run_feedback_links (run_id, feedback_id) VALUES ('runB', 'fb1')"
        ))
        conn.execute(text("INSERT INTO backfill_status (id, state) VALUES (1, 'ok')"))
        conn.execute(text(
            "INSERT INTO vibe_inputs (id, origin) VALUES ('vi1', 'user')"
        ))


def test_migration_drops_legacy_tables():
    engine = _fresh_engine()
    _seed_legacy_tables(engine)

    insp = inspect(engine)
    assert insp.has_table("feedback")
    assert insp.has_table("run_feedback_links")
    assert insp.has_table("backfill_status")

    apply(engine)

    insp = inspect(engine)
    assert not insp.has_table("feedback")
    assert not insp.has_table("run_feedback_links")
    assert not insp.has_table("backfill_status")
    # The cross-business feedback row is unrepresentable post-drop, so a
    # business-B delete can no longer 409 on feedback.last_run_id.


def test_migration_double_apply_idempotent():
    engine = _fresh_engine()
    _seed_legacy_tables(engine)
    apply(engine)
    # Second run must not raise even though the tables are already gone.
    apply(engine)
    insp = inspect(engine)
    assert not insp.has_table("feedback")


def test_migration_no_legacy_tables_is_noop():
    """A fresh install where the legacy tables never existed applies cleanly."""
    engine = _fresh_engine()
    with engine.begin() as conn:
        conn.execute(text(
            "CREATE TABLE vibe_inputs (id VARCHAR PRIMARY KEY, origin VARCHAR)"
        ))
    apply(engine)  # no feedback/run_feedback_links/backfill_status to drop
    assert not inspect(engine).has_table("feedback")


def test_migration_registered():
    versions = [m.version for m in runtime_migrations.MIGRATIONS]
    assert "0.6.6" in versions
    assert MIGRATION in runtime_migrations.MIGRATIONS
    # v_0_7_0 (version provenance) is registered after v_0_6_6.
    assert versions.index("0.6.6") < versions.index("0.7.0")


def _seed_element_tables(engine) -> None:
    """Minimal element tables carrying the SET NULL self-FK column, so the
    migration's CREATE INDEX steps have real tables to index."""
    with engine.begin() as conn:
        for table, column in SELF_FK_INDEX_COLUMNS:
            conn.execute(text(
                f"CREATE TABLE {table} (id VARCHAR PRIMARY KEY, {column} VARCHAR)"
            ))


def test_migration_creates_self_fk_indexes():
    """Every SET NULL self-FK column is indexed post-migration (the fork-blocking
    perf fix: unindexed child column => seq-scan per parent row on SET NULL)."""
    engine = _fresh_engine()
    _seed_element_tables(engine)

    apply(engine)

    insp = inspect(engine)
    for table, column in SELF_FK_INDEX_COLUMNS:
        index_names = {ix["name"] for ix in insp.get_indexes(table)}
        assert f"ix_{table}_{column}" in index_names, (
            f"missing ix_{table}_{column} after migration"
        )


def test_migration_index_creation_idempotent():
    """Re-applying the migration does not error on the already-present indexes."""
    engine = _fresh_engine()
    _seed_element_tables(engine)
    apply(engine)
    apply(engine)  # second run: CREATE INDEX IF NOT EXISTS is a no-op
    insp = inspect(engine)
    for table, column in SELF_FK_INDEX_COLUMNS:
        names = {ix["name"] for ix in insp.get_indexes(table)}
        assert f"ix_{table}_{column}" in names


def test_self_fk_index_columns_shape():
    """Lock the indexed self-FK set: exactly the five previous_element_id
    columns, matching the SET NULL self-FK rows in FK_RULES."""
    assert set(SELF_FK_INDEX_COLUMNS) == {
        ("domains", "previous_element_id"),
        ("subdomains", "previous_element_id"),
        ("products", "previous_element_id"),
        ("attributes", "previous_element_id"),
        ("foreign_key_links", "previous_element_id"),
    }
    # Every indexed column is a self-referential SET NULL FK in FK_RULES.
    # (businesses.source_industry_id is also a SET NULL self-FK but is already
    # indexed by v_0_6_4, so this is a subset check, not equality.)
    set_null_self = {
        (c, col) for (c, col, parent, action) in FK_RULES
        if action == "SET NULL" and c == parent
    }
    assert set(SELF_FK_INDEX_COLUMNS) <= set_null_self


def test_fk_rules_shape_and_counts():
    """FK_RULES is the single source of truth - lock its size + action split so
    a stray add/remove is a visible, deliberate change (design's 28/9 split)."""
    cascade = [r for r in FK_RULES if r[3] == "CASCADE"]
    set_null = [r for r in FK_RULES if r[3] == "SET NULL"]
    assert len(cascade) == 28
    assert len(set_null) == 9
    assert len(FK_RULES) == 37
    # Every action is one of the two supported verbs.
    assert all(r[3] in ("CASCADE", "SET NULL") for r in FK_RULES)
    # No duplicate (child, column) pairs - one rule per FK column.
    pairs = [(r[0], r[1]) for r in FK_RULES]
    assert len(pairs) == len(set(pairs))
    # The self-FK that must be ADD-only is present and SET NULL.
    assert ("businesses", "source_industry_id", "businesses", "SET NULL") in FK_RULES


def test_owner_script_imports_same_fk_rules():
    """The owner script IMPORTS FK_RULES (single source of truth) rather than
    re-declaring it - assert object identity so a copied literal is caught."""
    import importlib.util
    from pathlib import Path

    owner_path = (
        Path(__file__).resolve().parents[2] / "scripts" / "db" / "migrate.py"
    )
    spec = importlib.util.spec_from_file_location("owner_migrate_script", str(owner_path))
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    assert module.FK_RULES is FK_RULES
    # The self-FK index list is likewise imported, not re-declared.
    assert module.SELF_FK_INDEX_COLUMNS is SELF_FK_INDEX_COLUMNS
    # ...as is the trigram index column list.
    assert module.TRGM_INDEX_COLUMNS is TRGM_INDEX_COLUMNS


def test_trgm_index_columns_shape():
    """Lock the trigram-indexed set: exactly the two attribute columns the
    search UNION's attribute branch filters on (name, column_name)."""
    assert TRGM_INDEX_COLUMNS == [
        ("attributes", "name"),
        ("attributes", "column_name"),
    ]


def test_migration_skips_trgm_on_sqlite():
    """SQLite has no pg_trgm/GIN - the trigram step must not even attempt to
    run there (it's gated behind ``is_postgres``, same as FK re-pointing)."""
    engine = _fresh_engine()
    with engine.begin() as conn:
        conn.execute(text(
            "CREATE TABLE attributes (id VARCHAR PRIMARY KEY, "
            "previous_element_id VARCHAR, name VARCHAR, column_name VARCHAR)"
        ))
    # Must apply cleanly with no pg_trgm-related error on SQLite.
    apply(engine)
    apply(engine)
