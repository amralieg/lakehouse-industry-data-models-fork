"""Adversarial tests for the ``enlarge_to_ecm`` Operation primitive.

Phase 2 — Group A. Mirrors the structure of the other generation
primitive test files. See ``docs/orchestrator-design.md`` §10 for the
failure-mode table — enlarge's failure surface mirrors shrink's, so
the adversarial cases here exercise the same observable contract.
"""

from __future__ import annotations

import os
import sys
from unittest.mock import patch

import pytest
from pydantic import ValidationError
from sqlmodel import Session, select

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)
# Ensure tests/test_app/ is importable so the shared phase-2 helpers
# resolve as flat module names.
sys.path.insert(0, os.path.dirname(__file__))

from vibe_modeling.backend.db_models import (
    Domain,
    ModelVersion,
    RunOperation,
)
from vibe_modeling.backend.services.operations import (
    OperationDispatchHandle,
)

from _phase2_helpers import (
    ENLARGE_TO_ECM_VALID_PARAMS,
    make_ctx,
    make_engine,
    make_ws,
    parent_version,
    seed_business_and_agent,
    seed_run_with_op,
)
from _phase2_stubs import load_primitive


@pytest.fixture
def engine():
    return make_engine()


@pytest.fixture
def primitive():
    op, params_model = load_primitive("enlarge_to_ecm")
    return op, params_model


# --------------------------------------------------------------------------
# Pydantic params validation
# --------------------------------------------------------------------------


# --------------------------------------------------------------------------
# dispatch — widget contract
# --------------------------------------------------------------------------


def test_dispatch_launches_with_enlarge_mvm_operation(engine, primitive):
    """``enlarge_to_ecm`` must send ``operation='enlarge mvm'``."""
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="mvm", version=1)
        run_id, op_id = seed_run_with_op(
            session,
            business_id=biz_id,
            operation_name="enlarge_to_ecm",
            parent_version_id=parent_id,
            intent="enlarge",
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=ENLARGE_TO_ECM_VALID_PARAMS,
        )
        try:
            op.dispatch(ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — dispatch not implemented")

    assert ws.jobs.run_now.called
    notebook_params = ws.jobs.run_now.call_args.kwargs.get("notebook_params") or {}
    assert notebook_params.get("operation") == "enlarge mvm"


def test_dispatch_returns_handle_with_databricks_run_id(engine, primitive):
    op, _ = primitive
    ws = make_ws(run_now_run_id=779_001)
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="mvm")
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="enlarge_to_ecm",
            parent_version_id=parent_id, intent="enlarge",
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=ENLARGE_TO_ECM_VALID_PARAMS,
        )
        try:
            handle = op.dispatch(ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — dispatch not implemented")

    assert isinstance(handle, OperationDispatchHandle)
    assert handle.databricks_run_id == 779_001


def test_dispatch_propagates_permission_denied(engine, primitive):
    op, _ = primitive
    ws = make_ws()
    ws.jobs.run_now.side_effect = PermissionError("not authorized")
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="mvm")
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="enlarge_to_ecm",
            parent_version_id=parent_id, intent="enlarge",
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=ENLARGE_TO_ECM_VALID_PARAMS,
        )
        with pytest.raises((PermissionError, RuntimeError, NotImplementedError)):
            op.dispatch(ctx, ws, session)
        try:
            session.commit()
        except Exception:
            session.rollback()

    with Session(engine) as session:
        ro = session.get(RunOperation, op_id)
        assert ro is not None
        assert ro.databricks_run_id is None


def test_dispatch_does_not_modify_parent_mvm_version(engine, primitive):
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="mvm", version=1)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="enlarge_to_ecm",
            parent_version_id=parent_id, intent="enlarge",
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=ENLARGE_TO_ECM_VALID_PARAMS,
        )
        try:
            op.dispatch(ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — dispatch not implemented")
        session.commit()

    with Session(engine) as session:
        parent = session.get(ModelVersion, parent_id)
        assert parent is not None
        assert parent.scope == "mvm"


# --------------------------------------------------------------------------
# observe — terminal failure / success modes
# --------------------------------------------------------------------------


def test_observe_reports_terminal_failed_when_job_failed(engine, primitive):
    op, _ = primitive
    ws = make_ws(lifecycle="TERMINATED", result_state="FAILED",
                 state_message="enlarge crashed")
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="mvm")
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="enlarge_to_ecm",
            parent_version_id=parent_id, op_status="running",
            databricks_run_id=33333, intent="enlarge",
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=ENLARGE_TO_ECM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=33333, vibe_session_id=None)
        try:
            obs = op.observe(handle, ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — observe not implemented")

    assert obs.is_terminal is True
    assert obs.terminal_result is not None
    assert obs.terminal_result.succeeded is False
    assert obs.terminal_result.error
    assert obs.terminal_result.output_version_id is None


def test_observe_succeeded_false_when_model_json_missing(
    monkeypatch, engine, primitive
):
    # observe_generation_op retries 5 times with backoff (15s total)
    # for Volume FUSE eventual consistency; mock sleep for fast tests.
    monkeypatch.setattr(
        "vibe_modeling.backend.services.operations._generation_common.time.sleep",
        lambda *_a, **_kw: None,
    )
    op, _ = primitive
    ws = make_ws(
        lifecycle="TERMINATED", result_state="SUCCESS",
        download_raises=FileNotFoundError("model.json"),
    )
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="mvm")
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="enlarge_to_ecm",
            parent_version_id=parent_id, op_status="running",
            databricks_run_id=33333, intent="enlarge",
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=ENLARGE_TO_ECM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=33333, vibe_session_id=None)
        try:
            obs = op.observe(handle, ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — observe not implemented")

    assert obs.is_terminal is True
    assert obs.terminal_result is not None
    assert obs.terminal_result.succeeded is False
    err = (obs.terminal_result.error or "").lower()
    assert "model.json" in err or "artifact" in err or "missing" in err


def test_observe_lakebase_sync_failure_keeps_succeeded_true(engine, primitive):
    op, _ = primitive
    valid_model_json = b'{"domains": [], "products": [], "attributes": []}'
    ws = make_ws(
        lifecycle="TERMINATED", result_state="SUCCESS",
        download_payload=valid_model_json,
    )
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="mvm")
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="enlarge_to_ecm",
            parent_version_id=parent_id, op_status="running",
            databricks_run_id=33333, intent="enlarge",
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=ENLARGE_TO_ECM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=33333, vibe_session_id=None)
        with patch(
            "vibe_modeling.backend.model_sync.ModelSyncService.sync_model",
            side_effect=RuntimeError("lakebase down"),
        ):
            try:
                obs = op.observe(handle, ctx, ws, session)
            except NotImplementedError:
                pytest.skip("Stub primitive — observe not implemented")
        session.commit()

    assert obs.is_terminal is True
    assert obs.terminal_result is not None
    assert obs.terminal_result.succeeded is True
    with Session(engine) as session:
        ecm_versions = session.exec(
            select(ModelVersion).where(
                ModelVersion.business_id == biz_id,
                ModelVersion.scope == "ecm",
            )
        ).all()
        assert len(ecm_versions) == 1


def test_observe_in_flight_returns_non_terminal(engine, primitive):
    op, _ = primitive
    ws = make_ws(lifecycle="RUNNING", result_state="")
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="mvm")
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="enlarge_to_ecm",
            parent_version_id=parent_id, op_status="running",
            databricks_run_id=33333, intent="enlarge",
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=ENLARGE_TO_ECM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=33333, vibe_session_id=None)
        try:
            obs = op.observe(handle, ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — observe not implemented")

    assert obs.is_terminal is False
    assert obs.terminal_result is None


def test_observe_concurrent_calls_are_consistent(engine, primitive):
    op, _ = primitive
    ws = make_ws(lifecycle="RUNNING", result_state="")
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="mvm")
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="enlarge_to_ecm",
            parent_version_id=parent_id, op_status="running",
            databricks_run_id=33333, intent="enlarge",
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=ENLARGE_TO_ECM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=33333, vibe_session_id=None)
        try:
            obs1 = op.observe(handle, ctx, ws, session)
            obs2 = op.observe(handle, ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — observe not implemented")

    assert obs1.is_terminal == obs2.is_terminal


# --------------------------------------------------------------------------
# rollback
# --------------------------------------------------------------------------


def test_rollback_deletes_enlarged_ecm_version(engine, primitive):
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="mvm", version=1)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="enlarge_to_ecm",
            parent_version_id=parent_id, intent="enlarge",
        )
        enlarged = ModelVersion(
            business_id=biz_id, version=2, scope="ecm",
            status="completed", deployment_status="draft",
            uc_catalog="deploy_cat",
            base_version_id=parent_id,
        )
        session.add(enlarged)
        session.commit()
        session.refresh(enlarged)
        new_id = enlarged.id

        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=ENLARGE_TO_ECM_VALID_PARAMS,
        )
        rollback_state = {
            "version_id": new_id,
            "scope": "ecm",
            "catalog": "deploy_cat",
            "business_name": "test_corp",
            "schema_prefix": "ecm_",
            "model_version": "2",
            "installed_inline": False,
        }
        try:
            op.rollback(ctx, rollback_state, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")
        session.commit()

    with Session(engine) as session:
        assert session.get(ModelVersion, new_id) is None
        assert session.get(ModelVersion, parent_id) is not None


def test_rollback_uninstalls_schema_when_installed_inline(engine, primitive):
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="mvm", version=1)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="enlarge_to_ecm",
            parent_version_id=parent_id, intent="enlarge",
        )
        enlarged = ModelVersion(
            business_id=biz_id, version=2, scope="ecm",
            status="completed", deployment_status="deployed",
            uc_catalog="deploy_cat",
            base_version_id=parent_id,
        )
        session.add(enlarged)
        session.commit()
        session.refresh(enlarged)
        new_id = enlarged.id

        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=ENLARGE_TO_ECM_VALID_PARAMS,
            inherited_params={"cataloging_style": "One Catalog"},
        )
        rollback_state = {
            "version_id": new_id,
            "scope": "ecm",
            "catalog": "deploy_cat",
            "business_name": "test_corp",
            "schema_prefix": "ecm_",
            "model_version": "2",
            "installed_inline": True,
        }
        try:
            op.rollback(ctx, rollback_state, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")
        session.commit()

    assert ws.jobs.run_now.called, (
        "rollback for an inline-installed enlarge must launch the uninstall job"
    )
    notebook_params = ws.jobs.run_now.call_args.kwargs.get("notebook_params") or {}
    op_widget = notebook_params.get("operation", "")
    assert "uninstall" in op_widget.lower()


def test_rollback_clears_lakebase_data(engine, primitive):
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="mvm")
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="enlarge_to_ecm",
            parent_version_id=parent_id, intent="enlarge",
        )
        enlarged = ModelVersion(
            business_id=biz_id, version=2, scope="ecm",
            status="completed", deployment_status="draft",
            uc_catalog="deploy_cat",
            base_version_id=parent_id,
        )
        session.add(enlarged)
        session.commit()
        session.refresh(enlarged)
        d = Domain(version_id=enlarged.id, name="logistics")
        session.add(d)
        session.commit()
        new_id = enlarged.id

        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=ENLARGE_TO_ECM_VALID_PARAMS,
        )
        rollback_state = {
            "version_id": new_id,
            "scope": "ecm",
            "catalog": "deploy_cat",
            "business_name": "test_corp",
            "schema_prefix": "ecm_",
            "model_version": "2",
            "installed_inline": False,
        }
        try:
            op.rollback(ctx, rollback_state, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")
        session.commit()

    with Session(engine) as session:
        assert session.exec(
            select(Domain).where(Domain.version_id == new_id)
        ).all() == []


def test_rollback_of_never_dispatched_op_is_noop(engine, primitive):
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="mvm")
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="enlarge_to_ecm",
            parent_version_id=parent_id, intent="enlarge",
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=ENLARGE_TO_ECM_VALID_PARAMS,
        )
        try:
            op.rollback(ctx, {}, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")


def test_rollback_is_idempotent(engine, primitive):
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="mvm")
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="enlarge_to_ecm",
            parent_version_id=parent_id, intent="enlarge",
        )
        enlarged = ModelVersion(
            business_id=biz_id, version=2, scope="ecm",
            status="completed", deployment_status="draft",
            uc_catalog="deploy_cat",
            base_version_id=parent_id,
        )
        session.add(enlarged)
        session.commit()
        session.refresh(enlarged)
        new_id = enlarged.id
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=ENLARGE_TO_ECM_VALID_PARAMS,
        )
        rollback_state = {
            "version_id": new_id,
            "scope": "ecm",
            "catalog": "deploy_cat",
            "business_name": "test_corp",
            "schema_prefix": "ecm_",
            "model_version": "2",
            "installed_inline": False,
        }
        try:
            op.rollback(ctx, rollback_state, ws, session)
            session.commit()
            op.rollback(ctx, rollback_state, ws, session)
            session.commit()
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")


# --------------------------------------------------------------------------
# Class-level invariants
# --------------------------------------------------------------------------


def test_class_attributes_match_contract(primitive):
    op, _ = primitive
    assert op.name == "enlarge_to_ecm"
    assert op.produces_version is True


# --------------------------------------------------------------------------
# TestRollbackAdversarial — rollback edge cases per design doc §2 + §10.
#
# enlarge_to_ecm rollback contract (§10): "Job times out / fails →
# rollback deletes enlarged version + uninstalls schema".
#
# Implementation note: the actual `rollback_generation_op` ordering is
#   1. uninstall job (if installed_inline)
#   2. clear Lakebase model data
#   3. delete the ModelVersion row
# So the design-doc-suggested "uninstall raises AFTER version delete
# succeeds" scenario is inverted in the impl. Tests below cover the
# real ordering: uninstall raises FIRST, before version delete.
#
# Adversarial scenarios:
#   1. Rollback replay (idempotency invariant from §2).
#   2. Dependent ModelVersion already deleted between dispatch and rollback.
#   3. Rollback's underlying call raises → orchestrator handles.
#   4. Both version AND schema teardown happen for inline installs
#      (no leaked UC schema after a partial rollback).
#   5. Uninstall job raises → exception surfaces; version row stays put
#      (real impl order: uninstall happens BEFORE version delete).
# --------------------------------------------------------------------------


class TestRollbackAdversarial:
    """Adversarial rollback cases for enlarge_to_ecm.

    The rollback delegates to ``rollback_generation_op`` in
    ``_generation_common.py``. Scenarios below exercise the real impl
    ordering (uninstall → clear data → delete row), not the
    design-doc-prescribed ordering (which has clear data → delete row →
    uninstall). The divergence is flagged in the agent's report.
    """

    def test_rollback_replay_idempotent(self, engine, primitive):
        """§2 invariant: replaying ``rollback`` against an already-rolled-back
        state MUST be a no-op (not raise)."""
        op, _ = primitive
        ws = make_ws()
        with Session(engine) as session:
            biz_id, _ = seed_business_and_agent(session)
            parent_id = parent_version(session, biz_id, scope="mvm")
            run_id, op_id = seed_run_with_op(
                session,
                business_id=biz_id,
                operation_name="enlarge_to_ecm",
                parent_version_id=parent_id,
                intent="enlarge",
            )
            enlarged = ModelVersion(
                business_id=biz_id, version=2, scope="ecm",
                status="completed", deployment_status="draft",
                uc_catalog="deploy_cat",
                base_version_id=parent_id,
            )
            session.add(enlarged)
            session.commit()
            session.refresh(enlarged)
            new_id = enlarged.id
            ctx = make_ctx(
                run_id=run_id, operation_id=op_id, business_id=biz_id,
                parent_version_id=parent_id,
                params=ENLARGE_TO_ECM_VALID_PARAMS,
            )
            rollback_state = {
                "version_id": new_id,
                "scope": "ecm",
                "catalog": "deploy_cat",
                "business_name": "test_corp",
                "schema_prefix": "ecm_",
                "model_version": "2",
                "installed_inline": False,
            }
            # First call deletes; second call is a no-op (row already gone).
            op.rollback(ctx, rollback_state, ws, session)
            session.commit()
            op.rollback(ctx, rollback_state, ws, session)
            session.commit()

    def test_rollback_when_dependent_version_already_deleted(
        self, engine, primitive
    ):
        """The ModelVersion row may already be gone between dispatch and
        rollback (raced cleanup). Rollback must succeed without raising —
        §2 idempotency invariant."""
        op, _ = primitive
        ws = make_ws()
        with Session(engine) as session:
            biz_id, _ = seed_business_and_agent(session)
            parent_id = parent_version(session, biz_id, scope="mvm")
            run_id, op_id = seed_run_with_op(
                session,
                business_id=biz_id,
                operation_name="enlarge_to_ecm",
                parent_version_id=parent_id,
                intent="enlarge",
            )
            ctx = make_ctx(
                run_id=run_id, operation_id=op_id, business_id=biz_id,
                parent_version_id=parent_id,
                params=ENLARGE_TO_ECM_VALID_PARAMS,
            )
            rollback_state = {
                "version_id": "ghost-version-never-existed",
                "scope": "ecm",
                "catalog": "deploy_cat",
                "business_name": "test_corp",
                "schema_prefix": "ecm_",
                "model_version": "2",
                "installed_inline": False,
            }
            op.rollback(ctx, rollback_state, ws, session)
            session.commit()

    def test_rollback_propagates_uninstall_failure(self, engine, primitive):
        """When ``installed_inline=True`` and the uninstall job launch
        raises, ``rollback_generation_op`` re-raises as ``RuntimeError``
        so the orchestrator's ``_rollback_one`` can record the failure
        and halt the rollback chain.

        Real impl ordering: uninstall is step 1 — so a launch failure
        here means the version row is NOT yet deleted. The orchestrator
        will leave the row in place and surface the partial state to the
        operator. (This is the spec §6.2 "no Frankenstein states" rule.)
        """
        op, _ = primitive
        ws = make_ws()
        ws.jobs.run_now.side_effect = PermissionError("uninstall denied")
        with Session(engine) as session:
            biz_id, _ = seed_business_and_agent(session)
            parent_id = parent_version(session, biz_id, scope="mvm")
            run_id, op_id = seed_run_with_op(
                session,
                business_id=biz_id,
                operation_name="enlarge_to_ecm",
                parent_version_id=parent_id,
                intent="enlarge",
            )
            enlarged = ModelVersion(
                business_id=biz_id, version=2, scope="ecm",
                status="completed", deployment_status="deployed",
                uc_catalog="deploy_cat",
                base_version_id=parent_id,
            )
            session.add(enlarged)
            session.commit()
            session.refresh(enlarged)
            new_id = enlarged.id
            ctx = make_ctx(
                run_id=run_id, operation_id=op_id, business_id=biz_id,
                parent_version_id=parent_id,
                params=ENLARGE_TO_ECM_VALID_PARAMS,
                inherited_params={"cataloging_style": "One Catalog"},
            )
            rollback_state = {
                "version_id": new_id,
                "scope": "ecm",
                "catalog": "deploy_cat",
                "business_name": "test_corp",
                "schema_prefix": "ecm_",
                "model_version": "2",
                "installed_inline": True,
            }
            # Uninstall raises — rollback must propagate as RuntimeError
            # so the orchestrator's _rollback_one can catch it.
            with pytest.raises(RuntimeError):
                op.rollback(ctx, rollback_state, ws, session)

        # Real impl: uninstall is step 1, so the version row is NOT
        # deleted when uninstall raises. Verify.
        with Session(engine) as session:
            still_there = session.get(ModelVersion, new_id)
            assert still_there is not None, (
                "real-impl ordering: uninstall raises FIRST → version row "
                "must remain so the operator can see what's left to clean"
            )

    def test_rollback_uninstalls_schema_AND_deletes_version_when_inline(
        self, engine, primitive
    ):
        """§10: rollback must do BOTH — delete the version AND uninstall
        the schema. A partial rollback (version deleted, schema left)
        would leak UC schemas.
        """
        op, _ = primitive
        ws = make_ws()
        with Session(engine) as session:
            biz_id, _ = seed_business_and_agent(session)
            parent_id = parent_version(session, biz_id, scope="mvm")
            run_id, op_id = seed_run_with_op(
                session,
                business_id=biz_id,
                operation_name="enlarge_to_ecm",
                parent_version_id=parent_id,
                intent="enlarge",
            )
            enlarged = ModelVersion(
                business_id=biz_id, version=2, scope="ecm",
                status="completed", deployment_status="deployed",
                uc_catalog="deploy_cat",
                base_version_id=parent_id,
            )
            session.add(enlarged)
            session.commit()
            session.refresh(enlarged)
            new_id = enlarged.id
            ctx = make_ctx(
                run_id=run_id, operation_id=op_id, business_id=biz_id,
                parent_version_id=parent_id,
                params=ENLARGE_TO_ECM_VALID_PARAMS,
                inherited_params={"cataloging_style": "One Catalog"},
            )
            rollback_state = {
                "version_id": new_id,
                "scope": "ecm",
                "catalog": "deploy_cat",
                "business_name": "test_corp",
                "schema_prefix": "ecm_",
                "model_version": "2",
                "installed_inline": True,
            }
            op.rollback(ctx, rollback_state, ws, session)
            session.commit()

        # Both effects observed: uninstall job launched + version gone.
        assert ws.jobs.run_now.called, (
            "rollback for installed_inline must launch the uninstall job "
            "(schema cleanup half of the contract)"
        )
        notebook_params = ws.jobs.run_now.call_args.kwargs.get("notebook_params") or {}
        assert "uninstall" in notebook_params.get("operation", "").lower(), (
            "uninstall job must use the uninstall widget"
        )
        with Session(engine) as session:
            assert session.get(ModelVersion, new_id) is None, (
                "rollback must delete the enlarged version (row cleanup half "
                "of the contract)"
            )
