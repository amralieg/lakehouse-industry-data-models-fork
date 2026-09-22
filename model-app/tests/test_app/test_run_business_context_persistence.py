"""Tests for Run.business_context_text persistence and RunOut surfacing.

Covers:
1. POST /runs with business_context_text → persisted, returned in GET.
2. Old runs (no business_context_text) return "" in RunOut.
3. Migration 0.2.0 applies cleanly on a fresh schema AND on a schema
   already at 0.1.0 (additive partial-upgrade path).

Wiring audit for this test file:
- Intent: verify the full form→DB→API info-flow for business_context_text.
- Previous wiring: n/a (new field).
- New wiring: RunIn.business_context_text → Run.business_context_text →
              _build_run_out → RunOut.business_context_text.
- Dead-end check: field populated in POST /runs, readable in GET /runs/{id}.
"""

from __future__ import annotations

import json

import pytest
from sqlalchemy import inspect, text
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

from vibe_modeling.backend.db_models import AgentConfig, Business, Run
from vibe_modeling.backend.migrations import v_0_1_0, v_0_2_0
from vibe_modeling.backend.migrations.registry import (
    Migration,
    reconcile_schema,
    _now,
)


# --- Migration tests ----------------------------------------------------------


@pytest.fixture(name="fresh_engine")
def fresh_engine_fixture():
    """Bare in-memory SQLite; no tables, no version row."""
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    return engine


def test_migration_020_adds_column_on_fresh_schema(fresh_engine, monkeypatch):
    """v_0_2_0 applied after v_0_1_0 on a fresh DB produces the column."""
    from vibe_modeling.backend.migrations import registry as reg

    fake = [v_0_1_0.MIGRATION, v_0_2_0.MIGRATION]
    monkeypatch.setattr(reg, "MIGRATIONS", fake)
    monkeypatch.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", True)

    reconcile_schema(fresh_engine)

    cols = {
        row[1]
        for row in fresh_engine.connect().execute(
            text("PRAGMA table_info(runs)")
        ).fetchall()
    }
    assert "business_context_text" in cols, (
        "migration 0.2.0 must add business_context_text to runs"
    )


def test_migration_020_is_additive_on_schema_without_column(fresh_engine, monkeypatch):
    """v_0_2_0 adds the column on a DB that has the runs table but lacks the column.

    Simulates the production scenario where the schema already exists (0.1.0 era)
    but business_context_text was not yet there. We manually create the runs table
    WITHOUT the column to replicate the old shape, then apply v_0_2_0 and confirm
    it adds the column cleanly.
    """
    from vibe_modeling.backend.migrations import registry as reg

    # Manually create a minimal runs table WITHOUT business_context_text.
    with fresh_engine.begin() as conn:
        conn.execute(text(
            "CREATE TABLE runs ("
            "  id TEXT PRIMARY KEY, "
            "  business_id TEXT, "
            "  run_type TEXT DEFAULT '', "
            "  status TEXT DEFAULT 'pending', "
            "  parameters_json TEXT DEFAULT '{}', "
            "  vibe_instructions_text TEXT DEFAULT '', "
            "  vibe_instructions_volume_path TEXT DEFAULT ''"
            ")"
        ))

    cols_before = {
        row[1]
        for row in fresh_engine.connect()
        .execute(text("PRAGMA table_info(runs)"))
        .fetchall()
    }
    assert "business_context_text" not in cols_before, (
        "pre-condition: table must not have the column yet"
    )

    # Apply the migration — must add the column.
    v_0_2_0.apply(fresh_engine)

    cols_after = {
        row[1]
        for row in fresh_engine.connect()
        .execute(text("PRAGMA table_info(runs)"))
        .fetchall()
    }
    assert "business_context_text" in cols_after, (
        "migration 0.2.0 must add business_context_text when upgrading from an older schema"
    )


def test_migration_020_idempotent(fresh_engine, monkeypatch):
    """Applying 0.2.0 twice does not raise (idempotent via PRAGMA guard)."""
    from vibe_modeling.backend.migrations import registry as reg

    fake = [v_0_1_0.MIGRATION, v_0_2_0.MIGRATION]
    monkeypatch.setattr(reg, "MIGRATIONS", fake)
    monkeypatch.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", True)

    reconcile_schema(fresh_engine)
    # Second apply of v_0_2_0 in isolation must not raise.
    v_0_2_0.apply(fresh_engine)


# --- API persistence tests ---------------------------------------------------


def test_run_business_context_text_persisted_and_returned(
    client_with_agent, engine, seed_business, mock_ws
):
    """POST /runs with business_context_text is persisted and returned by GET."""
    bid = seed_business
    mock_ws.jobs.run_now.return_value = MagicMock(run_id=42)
    mock_ws.workspace.get_status.return_value = MagicMock()

    resp = client_with_agent.post(
        f"/api/businesses/{seed_business}/runs",
        json={
            "intent": "new-base-model",
            "catalog": "test_metamodel_catalog",
            "business_context_text": "  We focus on retail loyalty analytics.  ",
        },
        headers={
            "X-Forwarded-For": "127.0.0.1",
            "X-Forwarded-User": "test@example.com",
        },
    )
    assert resp.status_code == 200, resp.text
    body = resp.json()

    # RunOut must expose the trimmed text.
    assert body.get("business_context_text") == "We focus on retail loyalty analytics.", (
        f"RunOut.business_context_text mismatch: {body.get('business_context_text')!r}"
    )

    # GET the run back — same field must round-trip.
    run_id = body["id"]
    get_resp = client_with_agent.get(
        f"/api/businesses/{bid}/runs/{run_id}",
        headers={
            "X-Forwarded-For": "127.0.0.1",
            "X-Forwarded-User": "test@example.com",
        },
    )
    assert get_resp.status_code == 200, get_resp.text
    assert get_resp.json().get("business_context_text") == "We focus on retail loyalty analytics."


def test_run_business_context_text_empty_by_default(engine, seed_business):
    """A Run inserted without business_context_text returns '' in RunOut."""
    # Insert a Run row directly with the old shape (no business_context_text).
    with Session(engine) as session:
        run = Run(
            business_id=seed_business,
            intent="new-base-model",
            status="completed",
            parameters_json="{}",
        )
        session.add(run)
        session.commit()
        session.refresh(run)
        run_id = run.id

    # Read it back — the field must be "" (the column default), not None or missing.
    with Session(engine) as session:
        persisted = session.get(Run, run_id)
        assert persisted is not None
        assert persisted.business_context_text == "", (
            "legacy rows without business_context_text must default to empty string"
        )


# ---------------------------------------------------------------------------
# Helpers (MagicMock not imported at module top to avoid collisions with the
# test functions that monkeypatch it)
# ---------------------------------------------------------------------------

from unittest.mock import MagicMock  # noqa: E402 — placed here intentionally
