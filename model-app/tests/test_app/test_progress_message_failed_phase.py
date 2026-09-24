"""Tests for `_build_progress_message` failure-phase indexing.

Regression: when op[0] fails and op[1+] is auto-skipped before
transition_run runs, neither op is "running" anymore so the
running_op-based fallback (completed + 1) drifts to N/N. The user
saw "Failed at Phase 2/2" when reality is op[0] (Phase 1) failed
(run df815dab on 2026-05-18 walkthrough).
"""

from datetime import datetime, timezone
from unittest.mock import MagicMock

from sqlmodel import Session

from vibe_modeling.backend.db_models import Run, RunOperation
from vibe_modeling.backend.run_state_transitions import _build_progress_message


def _op(step_index: int, name: str, status: str) -> RunOperation:
    return RunOperation(
        run_id="r1",
        operation_name=name,
        step_index=step_index,
        status=status,
    )


def test_failed_message_uses_failed_op_step_index_not_skipped_tail():
    """op[0]=failed, op[1]=skipped → "Failed at Phase 1/2" (not 2/2)."""
    run = Run(business_id="b1", intent="new-base-model", status="failed")
    rows = [_op(0, "vibe_iterate", "failed"), _op(1, "shrink_to_mvm", "skipped")]
    session = MagicMock(spec=Session)
    session.exec.return_value.first.return_value = None
    msg = _build_progress_message(run, "failed", "Workload failed", None, rows, session)
    assert msg.startswith("Failed at Phase 1/2"), f"unexpected: {msg!r}"


def test_failed_message_first_op_only_failed():
    """Single-op DAG: op[0]=failed → "Failed at Phase 1/1"."""
    run = Run(business_id="b1", intent="install", status="failed")
    rows = [_op(0, "install", "failed")]
    session = MagicMock(spec=Session)
    session.exec.return_value.first.return_value = None
    msg = _build_progress_message(run, "failed", "boom", None, rows, session)
    assert msg.startswith("Failed at Phase 1/1"), f"unexpected: {msg!r}"


def test_failed_message_second_of_three_failed():
    """3-op DAG: op[0]=succeeded, op[1]=failed, op[2]=skipped → Phase 2/3."""
    run = Run(business_id="b1", intent="new-base-model", status="failed")
    rows = [
        _op(0, "generate_ecm", "succeeded"),
        _op(1, "shrink_to_mvm", "failed"),
        _op(2, "install", "skipped"),
    ]
    session = MagicMock(spec=Session)
    session.exec.return_value.first.return_value = None
    msg = _build_progress_message(run, "failed", "boom", None, rows, session)
    assert msg.startswith("Failed at Phase 2/3"), f"unexpected: {msg!r}"


def test_failed_message_falls_back_to_running_op_when_no_failed_status():
    """Safety net: if no op is in "failed" status (shouldn't happen but
    transition_run is called with `target_status="failed"` in some
    edge cases), the message uses running_op or completed+1 fallback."""
    run = Run(business_id="b1", intent="new-base-model", status="failed")
    running_op = _op(0, "generate_ecm", "running")
    rows = [running_op, _op(1, "shrink_to_mvm", "pending")]
    session = MagicMock(spec=Session)
    session.exec.return_value.first.return_value = None
    # running_op is set; current_phase = running_op.step_index + 1 = 1
    msg = _build_progress_message(run, "failed", "", running_op, rows, session)
    assert msg.startswith("Failed at Phase 1/2"), f"unexpected: {msg!r}"


def test_failed_message_empty_rows_uses_unknown_phase():
    """Defensive edge case: transition_run called with zero operations
    (synthetic-import path, malformed dispatch). The message must NOT
    crash and SHOULD surface ?/? so the operator knows the phase index
    isn't trustworthy."""
    run = Run(business_id="b1", intent="import-from-volume", status="failed")
    rows: list[RunOperation] = []
    session = MagicMock(spec=Session)
    session.exec.return_value.first.return_value = None
    msg = _build_progress_message(run, "failed", "no ops", None, rows, session)
    assert "Phase ?/?" in msg, f"unexpected: {msg!r}"
    assert "no ops" in msg, f"reason should propagate; got {msg!r}"


# ---------------------------------------------------------------------------
# an internal tracker item — explicit "not N/N" guard
# ---------------------------------------------------------------------------


def test_failed_message_does_not_say_phase_two_of_two_when_op_one_failed():
    """Pin the exact regression seen on run df815dab (2026-05-18 walkthrough):
    op[0]=vibe_iterate failed, op[1]=shrink_to_mvm skipped. The user saw
    "Failed at Phase 2/2 — Task run_agent failed" which misrepresents the
    failed phase. The terminal message MUST surface Phase 1/2 and MUST NOT
    contain "Phase 2/2".
    """
    run = Run(business_id="b1", intent="new-base-model", status="failed")
    rows = [
        _op(0, "vibe_iterate", "failed"),
        _op(1, "shrink_to_mvm", "skipped"),
    ]
    session = MagicMock(spec=Session)
    session.exec.return_value.first.return_value = None
    msg = _build_progress_message(
        run, "failed", "Task run_agent failed", None, rows, session
    )
    assert "Phase 1/2" in msg, f"expected Phase 1/2 in {msg!r}"
    assert "Phase 2/2" not in msg, (
        f"regression: message mislabels failed phase as 2/2: {msg!r}"
    )
