"""Regression: ``resolve_session_id_bigint`` is the *single* read path
the progress drain uses to figure out which BIGINT the agent is writing
under in the ``_vibe_progress`` / ``_business`` Delta tables. Adding a
new dispatch path must NOT also require coordinating a session_id_bigint
write contract — persisting the canonical UUID on
``RunOperation.vibe_session_id`` is sufficient, because the resolver
derives the BIGINT from it via the same ``session_id_to_bigint`` helper
the dispatcher uses to feed the agent's notebook widget.

Background: the original orchestrator-resume fix (#165) taught the drain
to read ``session_id_bigint`` from ``RunOperation.rollback_state_json``,
but only the ``vibe_iterate`` dispatcher actually wrote it there. Phase 2
(#142) introduced ``_generation_common.dispatch_generation_op`` for the
new generation primitives (generate_ecm, shrink_to_mvm, enlarge_to_ecm)
which leaves rollback_state_json empty (and Run.vibe_session_id_bigint
None) — leading to a silent drain early-return and an empty events
feed for any orchestrator-routed new-base-model run.

These tests pin the resolver's behaviour across all three dispatch
shapes plus the UUID-derivation path that fixes the regression.
"""

from __future__ import annotations

import json
from unittest.mock import MagicMock

import pytest

from vibe_modeling.backend.db_models import Run, RunOperation
from vibe_modeling.backend.job_launcher import session_id_to_bigint
from vibe_modeling.backend.progress_tracker import (
    ProgressEvent,
    ProgressTracker,
    resolve_session_id_bigint,
)


# --------------------------------------------------------------------
# Helper-level tests: pin every resolution path independently.
# --------------------------------------------------------------------


def test_resolves_from_run_when_legacy_bigint_set():
    """Legacy non-orchestrator path: Run.vibe_session_id_bigint wins."""
    run = Run(
        business_id="b", intent="new-base-model", status="running",
        vibe_session_id_bigint=42, vibe_session_id="legacy-ignored",
    )
    op = RunOperation(
        id="op", run_id=run.id, step_index=0, operation_name="x",
        status="running",
        vibe_session_id="some-other-uuid",
        rollback_state_json=json.dumps({"session_id_bigint": 999}),
    )
    assert resolve_session_id_bigint(run, op) == 42


def test_derives_bigint_from_uuid_on_runop_when_run_bigint_unset():
    """Phase 2 generation primitives path: only the UUID is persisted on
    the RunOperation, Run.vibe_session_id_bigint is None,
    rollback_state_json is empty. Resolver derives the BIGINT
    deterministically — no contract on the dispatcher.

    THIS is the case that broke the test workspace: ``_generation_common.dispatch_generation_op``
    persists the UUID via ``_persist_run_id`` and returns ``extra={}``.
    """
    uuid = "b13e0e83-e711-4dc0-9771-aff31b157f38"  # the actual the test workspace session
    expected = session_id_to_bigint(uuid)

    run = Run(
        business_id="b", intent="new-base-model", status="running",
        vibe_session_id_bigint=None,
    )
    op = RunOperation(
        id="op", run_id=run.id, step_index=0, operation_name="generate_ecm",
        status="running",
        vibe_session_id=uuid,
        rollback_state_json="{}",  # empty extra — exactly the failing shape
    )
    assert resolve_session_id_bigint(run, op) == expected


def test_falls_back_to_rollback_state_json_when_uuid_missing():
    """Legacy orchestrator-era contract: vibe_iterate persisted the
    derived BIGINT directly into rollback_state_json. Old run rows
    without a UUID column populated must keep working."""
    run = Run(
        business_id="b", intent="vibe-iterate", status="running",
        vibe_session_id_bigint=None,
    )
    op = RunOperation(
        id="op", run_id=run.id, step_index=0, operation_name="vibe_iterate",
        status="running",
        vibe_session_id=None,  # legacy: UUID not on the row
        rollback_state_json=json.dumps({"session_id_bigint": 12345}),
    )
    assert resolve_session_id_bigint(run, op) == 12345


def test_returns_zero_when_no_resolution_possible():
    """Between steps / before dispatch — no source has a value. Caller
    must treat 0 as "skip this tick" rather than as an error."""
    run = Run(
        business_id="b", intent="new-base-model", status="running",
        vibe_session_id_bigint=None,
    )
    assert resolve_session_id_bigint(run, None) == 0

    op_empty = RunOperation(
        id="op", run_id=run.id, step_index=0, operation_name="x",
        status="running",
        vibe_session_id=None,
        rollback_state_json="{}",
    )
    assert resolve_session_id_bigint(run, op_empty) == 0


def test_rollback_state_json_malformed_does_not_raise():
    """A garbled rollback_state_json blob must degrade to 0 rather than
    propagate the JSON exception up through the polling loop."""
    run = Run(
        business_id="b", intent="vibe-iterate", status="running",
        vibe_session_id_bigint=None,
    )
    op = RunOperation(
        id="op", run_id=run.id, step_index=0, operation_name="x",
        status="running",
        vibe_session_id=None,
        rollback_state_json="not json",
    )
    assert resolve_session_id_bigint(run, op) == 0


def test_priority_order_run_beats_uuid_beats_rollback():
    """When all three sources are set the resolver must prefer Run, then
    derive-from-UUID, then rollback_state_json. Future dispatchers can
    rely on this ordering for migrations that backfill one column at
    a time."""
    uuid = "b13e0e83-e711-4dc0-9771-aff31b157f38"
    derived = session_id_to_bigint(uuid)

    # All three set: Run wins.
    run_all = Run(business_id="b", intent="x", status="running",
                  vibe_session_id_bigint=111)
    op_all = RunOperation(id="op", run_id=run_all.id, step_index=0,
                          operation_name="x", status="running",
                          vibe_session_id=uuid,
                          rollback_state_json=json.dumps(
                              {"session_id_bigint": 333}))
    assert resolve_session_id_bigint(run_all, op_all) == 111

    # Run unset, UUID + rollback set: UUID-derived wins.
    run_no_bigint = Run(business_id="b", intent="x", status="running",
                        vibe_session_id_bigint=None)
    assert resolve_session_id_bigint(run_no_bigint, op_all) == derived

    # Run unset, UUID unset, rollback set: rollback wins.
    op_legacy = RunOperation(id="op", run_id=run_no_bigint.id, step_index=0,
                             operation_name="x", status="running",
                             vibe_session_id=None,
                             rollback_state_json=json.dumps(
                                 {"session_id_bigint": 333}))
    assert resolve_session_id_bigint(run_no_bigint, op_legacy) == 333


# --------------------------------------------------------------------
# Drain-level integration: the actual the test workspace failure mode end-to-end.
# Mirrors test_orch_progress_session_resolution.py, but uses the
# orchestrator-routed-with-only-UUID shape that broke the
# vibe-modeling-clean run today.
# --------------------------------------------------------------------


from sqlmodel import Session, SQLModel, create_engine, select  # noqa: E402

from vibe_modeling.backend.db_models import RunProgressEvent  # noqa: E402, F401


def test_drain_polls_with_uuid_derived_bigint_when_extra_is_empty(monkeypatch):
    """End-to-end: Run.vibe_session_id_bigint=None,
    RunOperation.rollback_state_json='{}' (the
    ``_generation_common.dispatch_generation_op`` shape), only the UUID
    on RunOperation.vibe_session_id is set. Drain must derive the
    BIGINT and successfully poll Delta — events must land in Lakebase.
    """
    eng = create_engine("sqlite:///:memory:")
    SQLModel.metadata.create_all(eng)

    def session_factory():
        return Session(bind=eng)

    uuid = "b13e0e83-e711-4dc0-9771-aff31b157f38"
    expected_bigint = session_id_to_bigint(uuid)

    with session_factory() as s:
        run = Run(
            business_id="biz-1",
            intent="new-base-model",
            status="running",
            parameters_json=json.dumps({"deployment_catalog": "cat"}),
            vibe_session_id=None,
            vibe_session_id_bigint=None,  # orchestrator pattern
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
            vibe_session_id=uuid,                  # UUID persisted
            rollback_state_json="{}",              # empty — _generation_common shape
        )
        s.add(op)
        s.commit()
        run_id = run.id

    captured_sids: list[int] = []

    def fake_poll_events(catalog, sid, last_step_id):
        captured_sids.append(sid)
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
        tracker._sync_orch_progress_events(session.get(Run, run_id), session)
        session.commit()

    assert captured_sids == [expected_bigint], (
        f"drain queried with sid={captured_sids!r}, expected the "
        f"UUID-derived BIGINT {expected_bigint}. Did dispatch_generation_op "
        f"regress the session_id contract again?"
    )
    with session_factory() as verify:
        events = verify.exec(
            select(RunProgressEvent).where(RunProgressEvent.run_id == run_id)
        ).all()
        assert len(events) == 1, (
            "Drained event should have been mirrored to Lakebase. "
            "Empty events feed = the bug is back."
        )


# --------------------------------------------------------------------
# Dispatch-side contract: every dispatch path must persist the UUID on
# the RunOperation row. The resolver depends on that single field.
# --------------------------------------------------------------------


@pytest.mark.parametrize(
    "module_path",
    [
        "vibe_modeling.backend.services.operations._generation_common",
        "vibe_modeling.backend.services.operations.vibe_iterate",
    ],
)
def test_dispatcher_modules_persist_uuid_on_runop(module_path):
    """Every dispatcher in the orchestrator path must call ``_persist_run_id``
    (or equivalent) to write ``vibe_session_id`` (the UUID) onto the
    active RunOperation. The resolver derives the BIGINT from that
    UUID — if any dispatcher stops persisting it, the drain silently
    breaks again. This is a structural assertion, not a behavioural
    one: just confirm the contract is referenced in the dispatcher's
    source.
    """
    import importlib

    mod = importlib.import_module(module_path)
    src = open(mod.__file__).read()
    assert "vibe_session_id" in src, (
        f"{module_path} does not reference vibe_session_id — it must "
        f"persist the UUID on RunOperation.vibe_session_id for the "
        f"central resolver to derive the BIGINT."
    )
