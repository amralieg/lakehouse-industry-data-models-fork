"""Regression: orchestrator-routed runs have ``vibe_session_id_bigint``
left None on the Run row — each step's session id lives on the
matching RunOperation's ``rollback_state_json``. The drain must look
up the currently-running RunOperation and use its session_id_bigint
to query Delta. Prior to the fix the drain early-returned because
``run.vibe_session_id_bigint`` was None, leaving the UI's events feed
empty for the entire run.
"""

from __future__ import annotations

import json
from unittest.mock import MagicMock

from sqlmodel import Session, SQLModel, create_engine, select

from vibe_modeling.backend.progress_tracker import ProgressTracker, ProgressEvent
from vibe_modeling.backend.db_models import (  # noqa: F401 — register metadata
    AgentConfig,
    Run,
    RunOperation,
    RunProgressEvent,
)


def _setup_run_with_running_op(session_factory, *, op_session_bigint: int):
    """Create a Run with vibe_session_id_bigint=NULL (orchestrator
    pattern) and a single RunOperation in status='running' carrying
    the agent's session id in rollback_state_json."""
    with session_factory() as s:
        run = Run(
            business_id="biz-1",
            intent="new-base-model",
            status="running",
            parameters_json=json.dumps({"deployment_catalog": "cat"}),
            vibe_session_id=None,
            vibe_session_id_bigint=None,
            last_consumed_step_id=0,
        )
        s.add(run)
        s.flush()
        op = RunOperation(
            id="op-1",
            run_id=run.id,
            step_index=0,
            operation_name="generate_ecm",
            params_json="{}",
            status="running",
            rollback_state_json=json.dumps(
                {"session_id_bigint": op_session_bigint}
            ),
        )
        s.add(op)
        s.commit()
        return run.id


def test_drain_reads_session_from_active_runop(monkeypatch):
    """When Run.vibe_session_id_bigint is None, the drain must fall
    back to the running RunOperation's session_id_bigint and continue
    polling — NOT early-return with an empty events feed."""
    eng = create_engine("sqlite:///:memory:")
    SQLModel.metadata.create_all(eng)

    def session_factory():
        return Session(bind=eng)

    op_sid = 998877
    run_id = _setup_run_with_running_op(
        session_factory, op_session_bigint=op_sid,
    )

    captured_session_ids: list[int] = []

    def fake_poll_events(catalog, sid, last_step_id):
        captured_session_ids.append(sid)
        return [
            ProgressEvent(
                step_id=1, event_seq=1, stage_name="Vibe Session",
                step_name="Session Started", status="stage_in_progress",
                message="hi", progress_increment=0.0, result_json={},
            ),
        ]

    tracker = ProgressTracker(
        ws=MagicMock(), config=MagicMock(), session_factory=session_factory,
    )
    monkeypatch.setattr(tracker, "_poll_progress_events", fake_poll_events)
    monkeypatch.setattr(
        tracker, "_poll_session_status_by_id", lambda *a, **k: None
    )

    with session_factory() as session:
        tracker._sync_orch_progress_events(
            session.get(Run, run_id), session,
        )
        session.commit()

    assert captured_session_ids == [op_sid], (
        f"drain queried with sid={captured_session_ids!r} but should "
        f"have used the active RunOperation's session_id_bigint={op_sid}"
    )

    with session_factory() as verify:
        events = verify.exec(
            select(RunProgressEvent).where(RunProgressEvent.run_id == run_id)
        ).all()
        assert len(events) == 1
        assert events[0].step_id == 1


def test_drain_returns_quietly_when_no_running_runop(monkeypatch):
    """When Run.vibe_session_id_bigint is None AND there's no running
    RunOperation (e.g. between steps in the unified DAG), the drain
    must return without erroring — the next tick will retry."""
    eng = create_engine("sqlite:///:memory:")
    SQLModel.metadata.create_all(eng)

    def session_factory():
        return Session(bind=eng)

    with session_factory() as s:
        run = Run(
            business_id="biz-1",
            intent="new-base-model",
            status="running",
            parameters_json=json.dumps({"deployment_catalog": "cat"}),
        )
        s.add(run)
        s.commit()
        run_id = run.id

    tracker = ProgressTracker(
        ws=MagicMock(), config=MagicMock(), session_factory=session_factory,
    )
    poll_called = []
    monkeypatch.setattr(
        tracker, "_poll_progress_events",
        lambda *a, **k: poll_called.append(1) or [],
    )

    with session_factory() as session:
        tracker._sync_orch_progress_events(
            session.get(Run, run_id), session,
        )

    assert poll_called == [], (
        "drain must NOT poll when no session id can be resolved"
    )


def _capture_poll_catalog(monkeypatch, session_factory, *, params: dict, agentcfg_catalog: str):
    """Set up a running run+op (and an AgentConfig row), drain once, and
    return the catalog the drain passed to ``_poll_progress_events``."""
    op_sid = 555111
    with session_factory() as s:
        s.add(AgentConfig(deployment_catalog=agentcfg_catalog))
        run = Run(
            business_id="biz-1", intent="new-base-model", status="running",
            parameters_json=json.dumps(params),
            vibe_session_id=None, vibe_session_id_bigint=None,
            last_consumed_step_id=0,
        )
        s.add(run)
        s.flush()
        s.add(RunOperation(
            id="op-1", run_id=run.id, step_index=0,
            operation_name="generate_ecm", params_json="{}", status="running",
            rollback_state_json=json.dumps({"session_id_bigint": op_sid}),
        ))
        s.commit()
        run_id = run.id

    captured: list[str] = []

    def fake_poll_events(catalog, _sid, _last_step_id):
        captured.append(catalog)
        return []

    tracker = ProgressTracker(
        ws=MagicMock(), config=MagicMock(), session_factory=session_factory,
    )
    monkeypatch.setattr(tracker, "_poll_progress_events", fake_poll_events)
    monkeypatch.setattr(tracker, "_poll_session_status_by_id", lambda *_a, **_k: None)
    with session_factory() as session:
        run = session.get(Run, run_id)
        assert run is not None
        tracker._sync_orch_progress_events(run, session)
    return captured


def test_progress_catalog_prefers_run_params_over_agentconfig(monkeypatch):
    """The drain must poll the catalog THIS run was dispatched with
    (run params), not the AgentConfig default — the agent writes its
    ``_metamodel`` to the run's ``deployment_catalog``. Locks the
    params-over-AgentConfig contract (fix/progress-poll-run-catalog)."""
    eng = create_engine("sqlite:///:memory:")
    SQLModel.metadata.create_all(eng)

    def session_factory():
        return Session(bind=eng)

    captured = _capture_poll_catalog(
        monkeypatch, session_factory,
        params={"deployment_catalog": "params_catalog"},
        agentcfg_catalog="agentcfg_catalog",
    )
    assert captured == ["params_catalog"], (
        f"drain polled {captured!r}; must prefer the run's "
        f"params deployment_catalog over AgentConfig"
    )


def test_progress_catalog_falls_back_to_agentconfig_when_params_omit_catalog(monkeypatch):
    """When the run params carry no catalog (legacy / synthesized runs),
    the drain falls back to AgentConfig.deployment_catalog."""
    eng = create_engine("sqlite:///:memory:")
    SQLModel.metadata.create_all(eng)

    def session_factory():
        return Session(bind=eng)

    captured = _capture_poll_catalog(
        monkeypatch, session_factory,
        params={},
        agentcfg_catalog="agentcfg_catalog",
    )
    assert captured == ["agentcfg_catalog"], (
        f"drain polled {captured!r}; must fall back to AgentConfig "
        f"when run params omit the catalog"
    )
