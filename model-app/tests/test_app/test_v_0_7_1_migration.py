"""Tests for the ``v_0_7_1`` migration (agent_config upstream-monitor cache).

SQLite exercises the additive column-add + idempotency + missing-table guard.
The real Postgres ``ADD COLUMN IF NOT EXISTS`` path is validated on a Lakebase
branch (dialect differs — SQLite cannot host the production migration).
"""

from __future__ import annotations

from sqlalchemy import create_engine, inspect, text
from sqlalchemy.pool import StaticPool

from vibe_modeling.backend import migrations as runtime_migrations
from vibe_modeling.backend.migrations.v_0_7_1 import MIGRATION, _NEW_COLUMNS, apply


def _fresh_engine():
    return create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )


def _seed_agent_config(engine) -> None:
    with engine.begin() as conn:
        conn.execute(text(
            "CREATE TABLE agent_config (id VARCHAR PRIMARY KEY, notebook_path VARCHAR)"
        ))
        conn.execute(text(
            "INSERT INTO agent_config (id, notebook_path) VALUES ('cfg1', '')"
        ))


def _columns(engine, table: str) -> set[str]:
    with engine.begin() as conn:
        rows = conn.execute(text(f"PRAGMA table_info({table})")).fetchall()
    return {r[1] for r in rows}


def test_adds_all_four_nullable_columns():
    engine = _fresh_engine()
    _seed_agent_config(engine)
    apply(engine)
    cols = _columns(engine, "agent_config")
    assert set(_NEW_COLUMNS) <= cols

    # Existing row: all four columns default NULL (cold cache).
    with engine.begin() as conn:
        row = conn.execute(text(
            "SELECT upstream_release_version, upstream_agent_version, "
            "upstream_checked_at, upstream_check_error FROM agent_config WHERE id='cfg1'"
        )).one()
    assert row == (None, None, None, None)


def test_idempotent_reruns():
    engine = _fresh_engine()
    _seed_agent_config(engine)
    apply(engine)
    apply(engine)  # must not raise (columns already present)
    assert set(_NEW_COLUMNS) <= _columns(engine, "agent_config")


def test_no_op_when_table_absent():
    engine = _fresh_engine()
    # No agent_config table: minimal fixtures create only what they assert.
    apply(engine)
    assert not inspect(engine).has_table("agent_config")


def test_registered_as_latest_migration():
    assert MIGRATION.version == "0.7.1"
    assert runtime_migrations.MIGRATIONS[-1].version == "0.7.1"
