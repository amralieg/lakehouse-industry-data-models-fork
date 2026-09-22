"""Regression: progress bar must NOT advance past 1% (dispatch ack)
until at least one RunProgressEvent has been persisted for this run.

User feedback (2026-04-26): the bar showing 25% before any events
appeared in the events panel erodes trust. Bar must reflect
user-visible progress, not orchestrator dispatch state. Even when
the agent's `_business` session row reports `completed_percent=50`,
the bar stays at the floor (or 1% ack) until the events are
actually drained to Lakebase and visible in the panel.
"""

from __future__ import annotations

import json
from unittest.mock import MagicMock

from sqlmodel import Session, SQLModel, create_engine, select

from vibe_modeling.backend.progress_tracker import ProgressTracker, SessionStatus
from vibe_modeling.backend.db_models import (  # noqa: F401 — register metadata
    Run,
    RunOperation,
    RunProgressEvent,
)


def _make_run_with_two_phases(session_factory):
    with session_factory() as s:
        run = Run(
            business_id="biz-1",
            intent="new-base-model",
            status="running",
            parameters_json=json.dumps({"deployment_catalog": "cat"}),
            vibe_session_id="sid",
            vibe_session_id_bigint=4242,
            last_consumed_step_id=0,
            progress_percent=0,
        )
        s.add(run)
        s.flush()
        for i, name in enumerate(("generate_ecm", "shrink_to_mvm")):
            s.add(RunOperation(
                id=f"op-{i}",
                run_id=run.id,
                step_index=i,
                operation_name=name,
                params_json="{}",
                status=("running" if i == 0 else "pending"),
                rollback_state_json=json.dumps({"session_id_bigint": 4242}),
            ))
        s.commit()
        return run.id


def _patched_tracker(monkeypatch, session_factory, *, status: SessionStatus | None,
                     events: list):
    tracker = ProgressTracker(
        ws=MagicMock(), config=MagicMock(), session_factory=session_factory,
    )
    monkeypatch.setattr(
        tracker, "_poll_session_status_by_id", lambda *a, **k: status
    )
    monkeypatch.setattr(
        tracker, "_poll_progress_events", lambda *a, **k: events
    )
    monkeypatch.setattr(tracker, "_acknowledge_batch", lambda *a, **k: None)
    return tracker


def test_bar_stays_at_1pct_ack_when_no_events_drained_yet(monkeypatch):
    """Agent's session row says completed_percent=50, but no events
    have arrived in Lakebase yet. Bar MUST NOT advance past 1%."""
    eng = create_engine("sqlite:///:memory:")
    SQLModel.metadata.create_all(eng)

    def session_factory():
        return Session(bind=eng)

    run_id = _make_run_with_two_phases(session_factory)

    # Agent says it's 50% through phase 1, but we have no events yet.
    status = SessionStatus(
        session_id=4242, processing_status="ready",
        completed_percent=50.0, last_updated_at="", results_json=None,
        completion_date=None, business="biz", version="1", model_scope="ecm",
    )
    tracker = _patched_tracker(
        monkeypatch, session_factory, status=status, events=[]
    )

    with session_factory() as session:
        tracker._sync_orch_progress_events(session.get(Run, run_id), session)
        session.commit()

    with session_factory() as verify:
        run = verify.get(Run, run_id)
        assert run.progress_percent == 1, (
            f"bar advanced to {run.progress_percent}% before any events "
            f"landed in Lakebase — must be ≤1% (dispatch ack only)"
        )


def test_bar_advances_when_events_have_been_drained(monkeypatch):
    """Once at least one event is in Lakebase, the bar reflects
    floor + agent_pct × slice_pct as before."""
    from vibe_modeling.backend.progress_tracker import ProgressEvent

    eng = create_engine("sqlite:///:memory:")
    SQLModel.metadata.create_all(eng)

    def session_factory():
        return Session(bind=eng)

    run_id = _make_run_with_two_phases(session_factory)
    status = SessionStatus(
        session_id=4242, processing_status="ready",
        completed_percent=50.0, last_updated_at="", results_json=None,
        completion_date=None, business="biz", version="1", model_scope="ecm",
    )
    events = [
        ProgressEvent(
            step_id=1, event_seq=1, stage_name="Vibe Session",
            step_name="Session Started", status="stage_in_progress",
            message="hi", progress_increment=0.0, result_json={},
        ),
    ]
    tracker = _patched_tracker(
        monkeypatch, session_factory, status=status, events=events,
    )

    with session_factory() as session:
        tracker._sync_orch_progress_events(session.get(Run, run_id), session)
        session.commit()

    with session_factory() as verify:
        run = verify.get(Run, run_id)
        # 2-phase DAG, phase 1 running, agent at 50% → 25% overall.
        assert run.progress_percent == 25, (
            f"bar = {run.progress_percent}% (expected 25% — phase 1 of 2 "
            f"at 50% per-phase = 25% overall)"
        )


def test_message_uses_phase_vocabulary(monkeypatch):
    """Progress message uses 'Phase' for the outer level, not 'step'."""
    from vibe_modeling.backend.progress_tracker import ProgressEvent

    eng = create_engine("sqlite:///:memory:")
    SQLModel.metadata.create_all(eng)

    def session_factory():
        return Session(bind=eng)

    run_id = _make_run_with_two_phases(session_factory)
    status = SessionStatus(
        session_id=4242, processing_status="ready",
        completed_percent=50.0, last_updated_at="", results_json=None,
        completion_date=None, business="biz", version="1", model_scope="ecm",
    )
    events = [
        ProgressEvent(
            step_id=1, event_seq=1, stage_name="Vibe Session",
            step_name="Session Started", status="stage_in_progress",
            message="hi", progress_increment=0.0, result_json={},
        ),
    ]
    tracker = _patched_tracker(
        monkeypatch, session_factory, status=status, events=events,
    )

    with session_factory() as session:
        tracker._sync_orch_progress_events(session.get(Run, run_id), session)
        session.commit()

    with session_factory() as verify:
        run = verify.get(Run, run_id)
        # Should say "Phase 1/2", NOT "step 1/2".
        assert "Phase 1/2" in run.progress_message, (
            f"progress_message {run.progress_message!r} does not use the "
            f"required 'Phase N/total' vocabulary"
        )
        assert "step 1/2" not in run.progress_message.lower(), (
            f"progress_message {run.progress_message!r} still uses the "
            f"old 'step' vocabulary at the outer level"
        )
