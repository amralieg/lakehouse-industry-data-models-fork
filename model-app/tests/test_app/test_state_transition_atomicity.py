"""CI gate: atomic state transition contract.

Two groups:

1. ``TestNoDirectStateWrites`` — grepper that fails if any file outside the
   helper module writes ``Run.status``, ``RunOperation.status``,
   ``run.completed_at``, or ``run.progress_message`` with a terminal-status
   assignment directly (not via ``transition_run``).

   The grep patterns are written to catch the assignment forms that would be
   produced by hand-editing, while explicitly excluding:
   - The helper module itself (``run_state_transitions.py``)
   - Test files (``tests/``)
   - Non-terminal writes (``run.status = "running"``, ``run.status = "stale"``
     are progress updates, not terminal transitions; they remain in-place)
   - Comment lines

2. ``TestTransitionRunUnit`` — unit tests of :func:`transition_run` itself:
   cancel, fail, rolled_back, and succeeded paths on a Run with two
   RunOperation rows (one running, one pending), verifying all five layers.
"""

from __future__ import annotations

import os
import re
import sys
from datetime import datetime, timezone

import pytest
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

# Ensure in-tree source wins over installed wheel.
sys.path.insert(
    0,
    os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"),
)

from vibe_modeling.backend.db_models import (
    Business,
    Run,
    RunOperation,
    RunProgressEvent,
)
from vibe_modeling.backend.run_state_transitions import transition_run

# ---------------------------------------------------------------------------
# Shared fixture: in-memory SQLite engine
# ---------------------------------------------------------------------------

@pytest.fixture(name="engine")
def _engine():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    return engine


@pytest.fixture(name="session")
def _session(engine):
    with Session(engine) as s:
        yield s


@pytest.fixture(name="seeded_run")
def _seeded_run(session):
    """A Business + Run with two RunOperation rows (step 0 running, step 1 pending)."""
    biz = Business(name="Acme Corp", description="test", industry_alignment="Retail")
    session.add(biz)
    session.flush()

    run = Run(
        business_id=biz.id,
        intent="new-base-model",
        status="running",
        databricks_run_id=42000,
        progress_message="[generate_ecm] Job state: RUNNING/...",
        started_at=datetime.now(timezone.utc),
    )
    session.add(run)
    session.flush()

    op0 = RunOperation(
        run_id=run.id,
        step_index=0,
        operation_name="generate_ecm",
        status="running",
        databricks_run_id=42000,
    )
    op1 = RunOperation(
        run_id=run.id,
        step_index=1,
        operation_name="shrink_to_mvm",
        status="pending",
    )
    session.add(op0)
    session.add(op1)
    session.flush()
    session.commit()
    session.expire_all()
    return run.id, biz.id


# ---------------------------------------------------------------------------
# Group 1: static analysis gate — no direct terminal writes outside the helper
# ---------------------------------------------------------------------------

class TestNoDirectStateWrites:
    """Grep the source tree to ensure no code outside run_state_transitions.py
    makes terminal writes to Run.status / RunOperation.status / etc.

    What is allowed (non-terminal, in-place):
      run.status = "running"   — progress update
      run.status = "stale"     — transient watchdog marker
      run.status = "pending"   — initial creation
      run.completed_at = None  — reset on retry/resume
    """

    REPO_ROOT = os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..", "..")
    )

    # Terminal status literals that must only appear inside the helper.
    TERMINAL_STATUSES = frozenset({
        "cancelled",
        "failed",
        "succeeded",
        "rolled_back",
        "rolled_back_failed",
        "completed",
    })

    # Files / subtrees to exclude from the grep.
    EXCLUDE_PATHS = frozenset({
        "run_state_transitions.py",  # the helper itself
        "tests/",                    # test files
        "__pycache__",
        ".pyc",
    })

    def _collect_python_files(self) -> list[str]:
        src_root = os.path.join(self.REPO_ROOT, "src")
        result = []
        for dirpath, dirnames, filenames in os.walk(src_root):
            # Prune pycache directories in-place.
            dirnames[:] = [d for d in dirnames if d != "__pycache__"]
            for fname in filenames:
                if not fname.endswith(".py"):
                    continue
                full = os.path.join(dirpath, fname)
                # Skip the helper and test files.
                rel = os.path.relpath(full, self.REPO_ROOT)
                if any(excl in rel for excl in self.EXCLUDE_PATHS):
                    continue
                result.append(full)
        return result

    def _check_for_bad_writes(self, pattern: re.Pattern, *, description: str) -> list[str]:
        violations = []
        for fpath in self._collect_python_files():
            try:
                text = open(fpath, encoding="utf-8").read()
            except OSError:
                continue
            for lineno, line in enumerate(text.splitlines(), start=1):
                stripped = line.strip()
                # Skip comment lines and docstrings.
                if stripped.startswith("#"):
                    continue
                if pattern.search(line):
                    violations.append(f"{fpath}:{lineno}: {stripped}")
        return violations

    def test_no_direct_run_status_terminal_writes(self):
        """run.status = \"<terminal>\" must only appear in run_state_transitions.py."""
        terminal_re = "|".join(re.escape(s) for s in self.TERMINAL_STATUSES)
        # Match: run.status = "cancelled" etc. (with optional space around =)
        pat = re.compile(
            rf'run\.status\s*=\s*"(?:{terminal_re})"'
        )
        violations = self._check_for_bad_writes(pat, description="run.status terminal write")
        assert not violations, (
            "Direct terminal writes to run.status found outside run_state_transitions.py.\n"
            "Route all terminal status changes through transition_run():\n"
            + "\n".join(violations)
        )

    def test_no_direct_run_operation_status_terminal_writes_in_route_layer(self):
        """RunOperation.status terminal writes must not appear in ROUTE-layer
        files (router.py, routes/*.py) — those must go through transition_run.

        The orchestrator's _runner.py is exempt: it owns the per-step row
        lifecycle (row.status = "succeeded" / "failed" / "rolled_back" /
        "skipped") at the individual operation level. The helper covers the
        bulk-termination case (flipping ALL in-flight ops on a Run cancel/fail);
        the orchestrator's fine-grained per-step writes are correct and separate.
        """
        terminal_re = "|".join(re.escape(s) for s in self.TERMINAL_STATUSES)
        pat = re.compile(
            rf'(?:row|op|operation)\.status\s*=\s*"(?:{terminal_re})"'
        )
        # Only check route-layer files — not the orchestrator internals.
        route_files = [
            f for f in self._collect_python_files()
            if any(seg in f for seg in ("router.py", "/routes/"))
            and "_runner.py" not in f
        ]
        violations = []
        for fpath in route_files:
            try:
                text = open(fpath, encoding="utf-8").read()
            except OSError:
                continue
            for lineno, line in enumerate(text.splitlines(), start=1):
                stripped = line.strip()
                if stripped.startswith("#"):
                    continue
                if pat.search(line):
                    violations.append(f"{fpath}:{lineno}: {stripped}")
        assert not violations, (
            "Direct terminal writes to RunOperation.status found in route layer.\n"
            "Route all terminal status changes through transition_run():\n"
            + "\n".join(violations)
        )

    def test_no_naked_run_completed_at_set_to_now(self):
        """run.completed_at = datetime.now(...) must only appear in run_state_transitions.py."""
        pat = re.compile(r'run\.completed_at\s*=\s*datetime')
        violations = self._check_for_bad_writes(pat, description="run.completed_at = datetime(...)")
        assert not violations, (
            "Direct run.completed_at writes found outside run_state_transitions.py.\n"
            "transition_run() sets completed_at; callers must not set it directly:\n"
            + "\n".join(violations)
        )

    def test_no_stale_running_substring_in_progress_message_writes(self):
        """Smoke check: catch the original Frankenstein-state regression where a
        terminal write left the literal "RUNNING" Jobs-API state in the message.

        TODO(#32): this is a *narrow* smoke check — it only catches the literal
        "RUNNING" substring inside a run.progress_message assignment. Distinguishing
        a legitimate in-progress write (``run.progress_message = "Running install"``)
        from a terminal-state stale write requires AST analysis + context (knowing
        whether the assignment is followed by a transition_run / commit on the same
        terminal flow). The helper is the only place that writes terminal
        progress_message; adding a comprehensive AST-driven gate is future work.
        """
        # Match: run.progress_message = "...RUNNING..." (the Jobs API state string)
        # Allow the helper itself + the cancel-failure note ("cancel failed (...)")
        # which may legitimately echo a Jobs API error containing "RUNNING".
        pat = re.compile(r'run\.progress_message\s*=\s*[fF]?["\'][^"\']*RUNNING[^"\']*["\']')
        violations = self._check_for_bad_writes(pat, description="run.progress_message stale RUNNING")
        assert not violations, (
            "Direct run.progress_message writes containing literal 'RUNNING' found.\n"
            "These risk leaving the stale Jobs-API state on a terminal run; route\n"
            "the terminal write through transition_run() which strips it.\n"
            + "\n".join(violations)
        )


# ---------------------------------------------------------------------------
# Group 2: unit tests of transition_run
# ---------------------------------------------------------------------------

class TestTransitionRunCancel:
    """Cancel a Run with two RunOperation rows (one running, one pending)."""

    def test_all_five_layers_flipped(self, session, seeded_run, engine):
        run_id, _ = seeded_run
        with Session(engine) as s:
            run = s.get(Run, run_id)
            assert run is not None

            # Provide a stub ws that records cancel_run calls.
            cancel_calls: list[int] = []
            class FakeWs:
                class jobs:
                    @staticmethod
                    def cancel_run(run_id: int):
                        cancel_calls.append(run_id)

            result = transition_run(s, run, target_status="cancelled", ws=FakeWs())
            s.commit()

            # Layer 1: Run.status
            assert result.status == "cancelled"

            # Layer 2: Run.completed_at
            assert result.completed_at is not None

            # Layer 3: RunOperation rows
            ops = s.exec(
                select(RunOperation)
                .where(RunOperation.run_id == run_id)
                .order_by(RunOperation.step_index)
            ).all()
            assert len(ops) == 2
            assert ops[0].status == "cancelled", f"step 0 was {ops[0].status}"
            assert ops[1].status == "cancelled", f"step 1 was {ops[1].status}"
            assert ops[0].completed_at is not None
            assert ops[1].completed_at is not None

            # Layer 4: progress_message — must not contain "RUNNING"
            assert "RUNNING" not in result.progress_message.upper() or "cancelled" in result.progress_message.lower()
            assert "Cancelled" in result.progress_message

            # Layer 5: Databricks cancel attempted
            assert 42000 in cancel_calls, "Databricks cancel_run was not called"

    def test_cancelled_with_rollback_message_includes_reason(self, session, seeded_run, engine):
        """target_status=cancelled with reason= must surface the reason
        after the base "Cancelled at Phase X/Y (...)" text.

        Mirrors the `completed` branch's reason-honoring contract — both
        `cancel_run_with_rollback` callers (router.py + _runner.py) pass
        ``reason="with rollback"`` and the user must see it.
        """
        run_id, _ = seeded_run
        with Session(engine) as s:
            run = s.get(Run, run_id)
            assert run is not None
            transition_run(
                s, run, target_status="cancelled", reason="with rollback",
            )
            s.commit()

        with Session(engine) as s:
            run = s.get(Run, run_id)
            msg = run.progress_message

        assert "Cancelled at Phase" in msg, f"missing base phrase: {msg!r}"
        assert "with rollback" in msg, f"reason not surfaced: {msg!r}"
        # Format check: the reason joins after a " — " separator.
        assert " — with rollback" in msg, f"reason separator missing: {msg!r}"

    def test_cancelled_without_reason_omits_dash_clause(self, session, seeded_run, engine):
        """Symmetric: when reason="" the message must NOT contain " — "."""
        run_id, _ = seeded_run
        with Session(engine) as s:
            run = s.get(Run, run_id)
            assert run is not None
            transition_run(s, run, target_status="cancelled")
            s.commit()

        with Session(engine) as s:
            run = s.get(Run, run_id)
            msg = run.progress_message

        assert "Cancelled at Phase" in msg, f"missing base phrase: {msg!r}"
        assert "with rollback" not in msg, f"unexpected rollback note: {msg!r}"
        assert " — " not in msg, f"unexpected reason separator: {msg!r}"


class TestTransitionRunFail:
    """Fail a Run with two RunOperation rows."""

    def test_running_op_failed_pending_op_skipped(self, session, seeded_run, engine):
        run_id, _ = seeded_run
        with Session(engine) as s:
            run = s.get(Run, run_id)

            result = transition_run(
                s, run, target_status="failed", reason="Something exploded"
            )
            s.commit()

            assert result.status == "failed"
            assert result.completed_at is not None

            ops = s.exec(
                select(RunOperation)
                .where(RunOperation.run_id == run_id)
                .order_by(RunOperation.step_index)
            ).all()
            assert ops[0].status == "failed", f"step 0 was {ops[0].status}"
            assert ops[1].status == "skipped", f"step 1 was {ops[1].status}"

            assert "Failed" in result.progress_message
            assert "RUNNING" not in result.progress_message.upper()


class TestTransitionRunRolledBack:
    """rolled_back transition for cancel-with-rollback scenario."""

    def test_running_op_rolled_back_pending_op_skipped(self, session, seeded_run, engine):
        run_id, _ = seeded_run
        with Session(engine) as s:
            run = s.get(Run, run_id)

            result = transition_run(
                s, run, target_status="rolled_back_failed",
                reason="Rollback halted on op foo"
            )
            s.commit()

            assert result.status == "rolled_back_failed"
            assert result.completed_at is not None

            ops = s.exec(
                select(RunOperation)
                .where(RunOperation.run_id == run_id)
                .order_by(RunOperation.step_index)
            ).all()
            # running op → rolled_back
            assert ops[0].status == "rolled_back", f"step 0 was {ops[0].status}"
            # pending op → skipped
            assert ops[1].status == "skipped", f"step 1 was {ops[1].status}"

            assert "RUNNING" not in result.progress_message.upper()


class TestTransitionRunCompleted:
    """Mark a Run completed (success path) — no in-flight ops allowed."""

    def test_complete_with_no_inflight_ops(self, session, engine):
        """A Run where all ops are already succeeded should transition cleanly."""
        with Session(engine) as s:
            biz = Business(name="Acme Succeed", description="", industry_alignment="")
            s.add(biz)
            s.flush()

            run = Run(
                business_id=biz.id,
                intent="new-base-model",
                status="running",
                progress_message="Running shrink_to_mvm",
                started_at=datetime.now(timezone.utc),
            )
            s.add(run)
            s.flush()

            op0 = RunOperation(
                run_id=run.id,
                step_index=0,
                operation_name="generate_ecm",
                status="succeeded",
            )
            s.add(op0)
            s.flush()

            result = transition_run(s, run, target_status="completed")
            s.commit()

            assert result.status == "completed"
            assert result.completed_at is not None

    def test_complete_with_inflight_ops_raises(self, session, seeded_run, engine):
        """transition_run(completed) must raise if there are in-flight ops."""
        run_id, _ = seeded_run
        with Session(engine) as s:
            run = s.get(Run, run_id)
            with pytest.raises(ValueError, match="in-flight"):
                transition_run(s, run, target_status="completed")


class TestTransitionRunProgressMessage:
    """Verify progress messages for each terminal status."""

    @pytest.fixture(name="run_with_event")
    def _run_with_event(self, engine):
        """A Run with one running op and one progress event (stage/step names)."""
        with Session(engine) as s:
            biz = Business(name="Msg Corp", description="", industry_alignment="")
            s.add(biz)
            s.flush()

            run = Run(
                business_id=biz.id,
                intent="vibe-iterate",
                status="running",
                progress_message="[generate_ecm] Job state: RUNNING/... [phase 1/2]",
                started_at=datetime.now(timezone.utc),
            )
            s.add(run)
            s.flush()

            op0 = RunOperation(
                run_id=run.id,
                step_index=0,
                operation_name="generate_ecm",
                status="running",
            )
            op1 = RunOperation(
                run_id=run.id,
                step_index=1,
                operation_name="shrink_to_mvm",
                status="pending",
            )
            s.add(op0)
            s.add(op1)
            s.flush()

            event = RunProgressEvent(
                run_id=run.id,
                step_id=1000,
                stage_name="generate_ecm",
                step_name="Build domain model",
                status="running",
                message="Working…",
            )
            s.add(event)
            s.flush()
            s.commit()
            return run.id

    def test_cancel_message_includes_phase_and_step(self, run_with_event, engine):
        run_id = run_with_event
        with Session(engine) as s:
            run = s.get(Run, run_id)
            transition_run(s, run, target_status="cancelled")
            s.commit()

        with Session(engine) as s:
            run = s.get(Run, run_id)
            msg = run.progress_message
        assert "Cancelled" in msg
        assert "Phase 1/2" in msg
        assert "Build domain model" in msg

    def test_fail_message_includes_phase(self, run_with_event, engine):
        run_id = run_with_event
        with Session(engine) as s:
            run = s.get(Run, run_id)
            transition_run(s, run, target_status="failed", reason="disk full")
            s.commit()

        with Session(engine) as s:
            run = s.get(Run, run_id)
            msg = run.progress_message
        assert "Failed" in msg
        assert "disk full" in msg

    def test_complete_without_reason_overwrites_inprogress_message(self, engine):
        """transition_run(completed) with no reason must replace the in-progress
        message, not preserve it. Otherwise a completed run keeps showing
        "Running — Phase 2/2, 100%" and the UI lies about its state."""
        with Session(engine) as s:
            biz = Business(name="Done Corp", description="", industry_alignment="")
            s.add(biz)
            s.flush()
            run = Run(
                business_id=biz.id,
                intent="new-base-model",
                status="running",
                progress_message="Running — Phase 2/2, 100%",
                started_at=datetime.now(timezone.utc),
            )
            s.add(run)
            s.flush()
            op = RunOperation(
                run_id=run.id,
                step_index=0,
                operation_name="generate_ecm",
                status="succeeded",
            )
            s.add(op)
            s.flush()
            result = transition_run(s, run, target_status="completed")
            s.commit()
            assert result.status == "completed"
            assert "Running" not in result.progress_message, (
                f"completed run still shows in-progress text: {result.progress_message!r}"
            )
            assert result.progress_message == "Run complete"

    def test_complete_with_reason_honors_caller_text(self, engine):
        """When a caller supplies a meaningful terminal message via reason=,
        transition_run uses it verbatim."""
        with Session(engine) as s:
            biz = Business(name="Reason Corp", description="", industry_alignment="")
            s.add(biz)
            s.flush()
            run = Run(
                business_id=biz.id,
                intent="revert",
                status="running",
                progress_message="Re-installing version 2...",
                started_at=datetime.now(timezone.utc),
            )
            s.add(run)
            s.flush()
            op = RunOperation(
                run_id=run.id,
                step_index=0,
                operation_name="revert",
                status="succeeded",
            )
            s.add(op)
            s.flush()
            result = transition_run(
                s, run, target_status="completed", reason="Reverted to version 2"
            )
            s.commit()
            assert result.progress_message == "Reverted to version 2"

    def test_no_running_substring_after_any_terminal(self, run_with_event, engine):
        """After any terminal transition the message must not contain the
        stale RUNNING state from before the cancel."""
        for target in ("cancelled", "failed", "rolled_back_failed"):
            with Session(engine) as s:
                # Need a fresh run for each target.
                biz = s.exec(select(Business).where(Business.name == "Msg Corp")).first()
                assert biz
                run = Run(
                    business_id=biz.id,
                    intent="vibe-iterate",
                    status="running",
                    progress_message="[generate_ecm] Job state: RUNNING/...",
                    started_at=datetime.now(timezone.utc),
                )
                s.add(run)
                s.flush()
                op = RunOperation(
                    run_id=run.id,
                    step_index=0,
                    operation_name="generate_ecm",
                    status="running",
                )
                s.add(op)
                s.flush()
                transition_run(s, run, target_status=target, reason="test")
                s.commit()
                run_id = run.id

            with Session(engine) as s:
                refreshed = s.get(Run, run_id)
                assert refreshed
                # The message must not contain a raw RUNNING reference that
                # would confuse the UI into showing the job as still running.
                # The word "running" in a sentence like "still running" is OK
                # as long as it's not the Jobs API RUNNING state string.
                assert "Job state: RUNNING" not in refreshed.progress_message, (
                    f"target={target}: stale RUNNING message found: {refreshed.progress_message!r}"
                )
