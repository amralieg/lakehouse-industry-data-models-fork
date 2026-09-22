"""Tests for the agent's ``Version Resolution`` / ``Version Collision
Auto-Resolved`` event parser.

Contract from ``tests/test_app/fixtures/progress_version_resolution.json``::

    parser_predicate_primary:
        stage_name == "Version Resolution" AND
        step_name == "Version Collision Auto-Resolved"

    parser_predicate_hardening:
        set(result_json.keys()) >= {"original_target", "new_target", "target_scope"}

Both predicates must hold for the parser to fire. When fired, the parser
records the agent's resolution on the run + scope so that
``observe_generation_op`` later allocates the agent's chosen ordinal
instead of recomputing via ``next_version_for_scope``. If a ``ModelVersion``
row already exists for this run + scope at the pre-allocated value, the
parser atomically re-stamps it + any dependent ``RunArtifact.file_path``
rows in a single transaction. If the existing MV row's version doesn't
match ``original_target``, the parser fails the run (no half-update).
"""

from __future__ import annotations

import json
import sys
import os
from datetime import datetime, timezone
from pathlib import Path

import pytest
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)

from vibe_modeling.backend.db_models import (
    Business,
    ModelVersion,
    Run,
    RunArtifact,
    RunOperation,
    RunProgressEvent,
)
from vibe_modeling.backend.progress_tracker import ProgressEvent
from vibe_modeling.backend.version_resolution_parser import (
    REQUIRED_KEYS,
    STAGE_NAME,
    STEP_NAME,
    apply_version_resolution,
    is_version_resolution_event,
    lookup_resolved_version,
)


FIXTURE_PATH = (
    Path(__file__).parent / "fixtures" / "progress_version_resolution.json"
)


@pytest.fixture
def fixture_event() -> dict:
    """The canonical contract input — the agent's verbatim emit shape."""
    with FIXTURE_PATH.open() as f:
        return json.load(f)


@pytest.fixture
def engine():
    eng = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(eng)
    return eng


@pytest.fixture
def seed_business(engine) -> str:
    with Session(engine) as s:
        b = Business(name="test eCommerce", description="x", industry_alignment="Retail")
        s.add(b)
        s.commit()
        s.refresh(b)
        return b.id


def _make_event_from_fixture(fx: dict) -> ProgressEvent:
    """Build a ProgressEvent from the fixture's verbatim emit shape."""
    return ProgressEvent(
        step_id=1700000000000,
        event_seq=42,
        stage_name=fx["stage_name"],
        step_name=fx["step_name"],
        status=fx["status"],
        message=fx["message"],
        progress_increment=fx["progress_increment"],
        result_json=dict(fx["result_json"]),
    )


# ---------------------------------------------------------------------------
# Predicate
# ---------------------------------------------------------------------------


class TestPredicate:
    """``is_version_resolution_event`` — primary + hardening predicate."""

    def test_canonical_fixture_matches(self, fixture_event):
        assert is_version_resolution_event(
            fixture_event["stage_name"],
            fixture_event["step_name"],
            fixture_event["result_json"],
        )

    def test_wrong_stage_does_not_match(self):
        assert not is_version_resolution_event(
            "Designing Domains",
            STEP_NAME,
            {"original_target": 1, "new_target": 3, "target_scope": "mvm"},
        )

    def test_wrong_step_does_not_match(self):
        assert not is_version_resolution_event(
            STAGE_NAME,
            "Some Other Step",
            {"original_target": 1, "new_target": 3, "target_scope": "mvm"},
        )

    def test_missing_original_target_does_not_match(self):
        assert not is_version_resolution_event(
            STAGE_NAME,
            STEP_NAME,
            {"new_target": 3, "target_scope": "mvm"},
        )

    def test_missing_new_target_does_not_match(self):
        assert not is_version_resolution_event(
            STAGE_NAME,
            STEP_NAME,
            {"original_target": 1, "target_scope": "mvm"},
        )

    def test_missing_target_scope_does_not_match(self):
        assert not is_version_resolution_event(
            STAGE_NAME,
            STEP_NAME,
            {"original_target": 1, "new_target": 3},
        )

    def test_none_result_json_does_not_match(self):
        assert not is_version_resolution_event(STAGE_NAME, STEP_NAME, None)

    def test_required_keys_constant_is_frozen(self):
        # Sanity: if the agent contract grows another required field, the
        # parser MUST be updated explicitly — don't let drift land.
        assert REQUIRED_KEYS == frozenset(
            {"original_target", "new_target", "target_scope"}
        )


# ---------------------------------------------------------------------------
# Handler — atomic update path
# ---------------------------------------------------------------------------


def _seed_run_with_mv_and_artifacts(
    engine,
    business_id: str,
    *,
    op_name: str = "shrink_to_mvm",
    mv_scope: str = "mvm",
    mv_version: int = 1,
) -> tuple[str, str]:
    """Seed a Run + RunOperation (running) + ModelVersion + 2 RunArtifacts.

    Returns (run_id, mv_id). The artifacts have file paths embedding
    ``{mvm,ecm}_v{N}`` so the parser's path-rewrite has something to rewrite.
    """
    with Session(engine) as s:
        run = Run(
            business_id=business_id,
            intent="new-base-model",
            status="running",
            databricks_run_id=42,
            vibe_session_id="sid",
            parameters_json="{}",
            started_at=datetime.now(timezone.utc),
        )
        s.add(run)
        s.flush()
        s.add(RunOperation(
            run_id=run.id,
            step_index=0,
            operation_name=op_name,
            params_json="{}",
            status="running",
        ))
        mv = ModelVersion(
            business_id=business_id,
            version=mv_version,
            scope=mv_scope,
            status="completed",
        )
        s.add(mv)
        s.flush()
        # Link Run.version_id so the lookup helper finds it.
        run.version_id = mv.id
        s.add(run)
        # Add a RunArtifact whose path matches the scope being resolved.
        s.add(RunArtifact(
            run_id=run.id,
            model_version_id=mv.id,
            artifact_type="json",
            file_path=f"/Volumes/cat/_metamodel/vol_root/biz/test_{mv_scope}_v{mv_version}/model.json",
        ))
        # Add a sibling-scope artifact that should NOT be rewritten.
        other_scope = "ecm" if mv_scope == "mvm" else "mvm"
        s.add(RunArtifact(
            run_id=run.id,
            artifact_type="json",
            file_path=f"/Volumes/cat/_metamodel/vol_root/biz/test_{other_scope}_v{mv_version}/model.json",
        ))
        s.commit()
        return run.id, mv.id


class TestApplyVersionResolution:
    """Atomic update path: MV row exists at original_target, parser
    re-stamps both MV.version and any RunArtifact.file_path segments."""

    def test_atomic_mv_and_artifact_update(self, engine, seed_business, fixture_event):
        run_id, mv_id = _seed_run_with_mv_and_artifacts(
            engine, seed_business, mv_scope="mvm", mv_version=1,
        )
        ev = _make_event_from_fixture(fixture_event)
        with Session(engine) as s:
            run = s.get(Run, run_id)
            apply_version_resolution(s, run, ev)
            s.commit()
            s.refresh(run)
        with Session(engine) as s:
            mv = s.get(ModelVersion, mv_id)
            assert mv.version == 3  # bumped from 1 → 3
            artifacts = s.exec(
                select(RunArtifact).where(RunArtifact.run_id == run_id)
            ).all()
            # MVM artifact path was rewritten.
            mvm_paths = [a.file_path for a in artifacts if "mvm" in a.file_path]
            assert any("_mvm_v3/" in p for p in mvm_paths), mvm_paths
            assert not any("_mvm_v1/" in p for p in mvm_paths), mvm_paths
            # ECM sibling artifact was NOT touched (different scope).
            ecm_paths = [a.file_path for a in artifacts if "ecm" in a.file_path]
            assert all("_ecm_v1/" in p for p in ecm_paths), ecm_paths

    def test_nested_artifact_path_rewritten(self, engine, seed_business, fixture_event):
        """A nested (agent 4.9.8+) ``.../v{N}/{scope}/...`` artifact path is
        re-stamped on the version segment when the agent re-targets v1→v3."""
        with Session(engine) as s:
            run = Run(
                business_id=seed_business,
                intent="new-base-model",
                status="running",
                databricks_run_id=42,
                vibe_session_id="sid",
                parameters_json="{}",
                started_at=datetime.now(timezone.utc),
            )
            s.add(run)
            s.flush()
            s.add(RunOperation(
                run_id=run.id, step_index=0, operation_name="shrink_to_mvm",
                params_json="{}", status="running",
            ))
            mv = ModelVersion(
                business_id=seed_business, version=1, scope="mvm", status="completed",
            )
            s.add(mv)
            s.flush()
            run.version_id = mv.id
            s.add(run)
            s.add(RunArtifact(
                run_id=run.id, model_version_id=mv.id, artifact_type="json",
                file_path="/Volumes/cat/_metamodel/vol_root/business/biz/v1/mvm/model.json",
            ))
            s.commit()
            run_id, mv_id = run.id, mv.id

        ev = _make_event_from_fixture(fixture_event)
        with Session(engine) as s:
            run = s.get(Run, run_id)
            apply_version_resolution(s, run, ev)
            s.commit()
        with Session(engine) as s:
            mv = s.get(ModelVersion, mv_id)
            assert mv.version == 3
            arts = s.exec(
                select(RunArtifact).where(RunArtifact.run_id == run_id)
            ).all()
            paths = [a.file_path for a in arts]
            assert any("/v3/mvm/" in p for p in paths), paths
            assert not any("/v1/mvm/" in p for p in paths), paths

    def test_wrong_scope_is_noop(self, engine, seed_business, fixture_event):
        """MV row is ECM but event is for MVM scope — must not touch MV."""
        run_id, mv_id = _seed_run_with_mv_and_artifacts(
            engine,
            seed_business,
            op_name="generate_ecm",
            mv_scope="ecm",
            mv_version=1,
        )
        # Fixture is MVM; the running op is ECM — scope mismatch → no-op.
        ev = _make_event_from_fixture(fixture_event)
        with Session(engine) as s:
            run = s.get(Run, run_id)
            apply_version_resolution(s, run, ev)
            s.commit()
        with Session(engine) as s:
            mv = s.get(ModelVersion, mv_id)
            assert mv.version == 1  # unchanged
            run = s.get(Run, run_id)
            assert run.status == "running"  # not failed

    def test_mismatched_original_target_fails_run(self, engine, seed_business):
        """MV exists for the same scope but at a different version than
        the agent reports as original_target → fail the run (no
        half-update)."""
        run_id, mv_id = _seed_run_with_mv_and_artifacts(
            engine, seed_business, mv_scope="mvm", mv_version=5,
        )
        # Agent thinks original was v1; App has v5 → mismatch.
        ev = ProgressEvent(
            step_id=1, event_seq=1,
            stage_name=STAGE_NAME, step_name=STEP_NAME,
            status="stage_warning", message="x",
            progress_increment=0.0,
            result_json={
                "original_target": 1, "new_target": 3, "target_scope": "mvm",
                "source_version": 1, "source_scope": "ecm",
            },
        )
        with Session(engine) as s:
            run = s.get(Run, run_id)
            apply_version_resolution(s, run, ev)
            s.commit()
        with Session(engine) as s:
            run = s.get(Run, run_id)
            assert run.status == "failed", run.status
            assert "Version Resolution mismatch" in run.progress_message
            mv = s.get(ModelVersion, mv_id)
            # Must NOT have been re-stamped.
            assert mv.version == 5

    def test_original_equals_new_is_noop(self, engine, seed_business):
        """Agent emits the event but original_target == new_target →
        no MV mutation."""
        run_id, mv_id = _seed_run_with_mv_and_artifacts(
            engine, seed_business, mv_scope="mvm", mv_version=2,
        )
        ev = ProgressEvent(
            step_id=1, event_seq=1,
            stage_name=STAGE_NAME, step_name=STEP_NAME,
            status="stage_warning", message="x",
            progress_increment=0.0,
            result_json={
                "original_target": 2, "new_target": 2, "target_scope": "mvm",
                "source_version": 2, "source_scope": "mvm",
            },
        )
        with Session(engine) as s:
            run = s.get(Run, run_id)
            apply_version_resolution(s, run, ev)
            s.commit()
        with Session(engine) as s:
            mv = s.get(ModelVersion, mv_id)
            assert mv.version == 2  # unchanged

    def test_missing_required_keys_is_noop(self, engine, seed_business):
        """result_json missing a required key → predicate would fail
        upstream; if the handler is called anyway with a partial blob, it
        must NOT crash and NOT mutate state."""
        run_id, mv_id = _seed_run_with_mv_and_artifacts(
            engine, seed_business, mv_scope="mvm", mv_version=1,
        )
        ev = ProgressEvent(
            step_id=1, event_seq=1,
            stage_name=STAGE_NAME, step_name=STEP_NAME,
            status="stage_warning", message="x",
            progress_increment=0.0,
            # Missing target_scope — predicate-hardening would reject this.
            result_json={"original_target": 1, "new_target": 3},
        )
        with Session(engine) as s:
            run = s.get(Run, run_id)
            # Apply must be a no-op on malformed blobs.
            apply_version_resolution(s, run, ev)
            s.commit()
        with Session(engine) as s:
            mv = s.get(ModelVersion, mv_id)
            assert mv.version == 1
            run = s.get(Run, run_id)
            assert run.status == "running"

    def test_deferred_when_mv_not_yet_created(self, engine, seed_business, fixture_event):
        """The agent fires the event mid-run, before observe creates the
        MV row. The parser must NOT crash and must NOT fail the run —
        the durable RunProgressEvent row is the deferred record.
        """
        # Seed a Run + a running op but NO ModelVersion row.
        with Session(engine) as s:
            run = Run(
                business_id=seed_business,
                intent="new-base-model",
                status="running",
                databricks_run_id=42,
                vibe_session_id="sid",
                parameters_json="{}",
                started_at=datetime.now(timezone.utc),
            )
            s.add(run)
            s.flush()
            s.add(RunOperation(
                run_id=run.id, step_index=0, operation_name="shrink_to_mvm",
                params_json="{}", status="running",
            ))
            s.commit()
            run_id = run.id
        ev = _make_event_from_fixture(fixture_event)
        with Session(engine) as s:
            run = s.get(Run, run_id)
            apply_version_resolution(s, run, ev)
            s.commit()
        with Session(engine) as s:
            run = s.get(Run, run_id)
            assert run.status == "running"  # not failed


# ---------------------------------------------------------------------------
# Lookup helpers — observe-time override
# ---------------------------------------------------------------------------


class TestLookupResolvedVersion:
    """``lookup_resolved_version`` reads the durable RunProgressEvent row
    so ``observe_generation_op`` can apply the agent's chosen ordinal at
    success-time even when the MV row didn't exist at parser-fire time."""

    def _seed_event(self, engine, run_id: str, *, scope: str, original: int, new: int):
        with Session(engine) as s:
            s.add(RunProgressEvent(
                run_id=run_id,
                step_id=1, event_seq=42,
                stage_name=STAGE_NAME, step_name=STEP_NAME,
                status="stage_warning", message="x",
                progress_increment=0.0,
                result_json=json.dumps({
                    "original_target": original,
                    "new_target": new,
                    "target_scope": scope,
                }),
            ))
            s.commit()

    def test_returns_new_target_when_present(self, engine, seed_business):
        with Session(engine) as s:
            run = Run(
                business_id=seed_business, intent="new-base-model",
                status="running", parameters_json="{}",
                started_at=datetime.now(timezone.utc),
            )
            s.add(run)
            s.commit()
            run_id = run.id
        self._seed_event(engine, run_id, scope="mvm", original=1, new=3)
        with Session(engine) as s:
            assert lookup_resolved_version(s, run_id, "mvm") == 3
            # Different scope returns None.
            assert lookup_resolved_version(s, run_id, "ecm") is None

    def test_returns_none_when_no_event(self, engine, seed_business):
        with Session(engine) as s:
            run = Run(
                business_id=seed_business, intent="new-base-model",
                status="running", parameters_json="{}",
                started_at=datetime.now(timezone.utc),
            )
            s.add(run)
            s.commit()
            run_id = run.id
        with Session(engine) as s:
            assert lookup_resolved_version(s, run_id, "mvm") is None

