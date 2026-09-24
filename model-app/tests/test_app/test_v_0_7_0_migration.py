"""Tests for the ``v_0_7_0`` migration (ModelVersion version-provenance columns).

SQLite exercises the additive column-add + idempotency + missing-table guard.
The real Postgres ``ADD COLUMN IF NOT EXISTS`` path is validated on a Lakebase
branch (dialect differs — SQLite cannot host the production migration).
"""

from __future__ import annotations

from sqlalchemy import create_engine, inspect, text
from sqlalchemy.pool import StaticPool

from vibe_modeling.backend import migrations as runtime_migrations
from vibe_modeling.backend.migrations.v_0_7_0 import MIGRATION, _NEW_COLUMNS, apply


def _fresh_engine():
    return create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )


def _seed_model_versions(engine) -> None:
    with engine.begin() as conn:
        conn.execute(text(
            "CREATE TABLE model_versions (id VARCHAR PRIMARY KEY, business_id VARCHAR)"
        ))
        conn.execute(text(
            "INSERT INTO model_versions (id, business_id) VALUES ('mv1', 'biz1')"
        ))


def _columns(engine, table: str) -> set[str]:
    with engine.begin() as conn:
        rows = conn.execute(text(f"PRAGMA table_info({table})")).fetchall()
    return {r[1] for r in rows}


def test_adds_both_nullable_columns():
    engine = _fresh_engine()
    _seed_model_versions(engine)
    apply(engine)
    cols = _columns(engine, "model_versions")
    assert set(_NEW_COLUMNS) <= cols

    # Existing row: both columns default NULL (backfill = leave NULL).
    with engine.begin() as conn:
        row = conn.execute(
            text("SELECT agent_version, release_version FROM model_versions WHERE id='mv1'")
        ).one()
    assert row == (None, None)


def test_idempotent_reruns():
    engine = _fresh_engine()
    _seed_model_versions(engine)
    apply(engine)
    apply(engine)  # must not raise (columns already present)
    assert set(_NEW_COLUMNS) <= _columns(engine, "model_versions")


def test_no_op_when_table_absent():
    engine = _fresh_engine()
    # No model_versions table: minimal fixtures create only what they assert.
    apply(engine)
    assert not inspect(engine).has_table("model_versions")


def test_registered_in_order():
    assert MIGRATION.version == "0.7.0"
    # v_0_7_0 is registered; a later migration (v_0_7_1) now sorts after it.
    versions = [m.version for m in runtime_migrations.MIGRATIONS]
    assert "0.7.0" in versions
    assert versions == sorted(versions), "migrations must be registered in ascending order"
