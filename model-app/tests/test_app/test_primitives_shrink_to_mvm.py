"""Adversarial tests for the ``shrink_to_mvm`` Operation primitive.

Phase 2 — Group A. Mirrors the structure of
``test_primitives_generate_ecm.py`` and shares helpers from
``_phase2_helpers.py``. See ``docs/orchestrator-design.md`` §10 row 2
for the failure-mode table.
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
    SHRINK_TO_MVM_VALID_PARAMS,
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
    op, params_model = load_primitive("shrink_to_mvm")
    return op, params_model


# --------------------------------------------------------------------------
# Pydantic params validation
# --------------------------------------------------------------------------


# --------------------------------------------------------------------------
# dispatch — widget contract
# --------------------------------------------------------------------------


def test_dispatch_launches_with_shrink_ecm_operation(engine, primitive):
    """``shrink_to_mvm`` must send ``operation='shrink ecm'`` and the MVM
    long-form scope to the agent notebook."""
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="ecm", version=1)
        run_id, op_id = seed_run_with_op(
            session,
            business_id=biz_id,
            operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        try:
            op.dispatch(ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — dispatch not implemented")

    assert ws.jobs.run_now.called
    notebook_params = ws.jobs.run_now.call_args.kwargs.get("notebook_params") or {}
    assert notebook_params.get("operation") == "shrink ecm"
    assert "Minimum Viable Model - MVM" in notebook_params.get(
        "data_model_scopes", ""
    )


def test_dispatch_returns_handle_with_databricks_run_id(engine, primitive):
    op, _ = primitive
    ws = make_ws(run_now_run_id=778_001)
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        try:
            handle = op.dispatch(ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — dispatch not implemented")

    assert isinstance(handle, OperationDispatchHandle)
    assert handle.databricks_run_id == 778_001


def test_dispatch_propagates_permission_denied(engine, primitive):
    op, _ = primitive
    ws = make_ws()
    ws.jobs.run_now.side_effect = PermissionError("not authorized")
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
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


def test_dispatch_does_not_modify_parent_ecm_version(engine, primitive):
    """Per §10 row 2: a failed shrink leaves ECM untouched. Even on a
    *successful* dispatch we expect the parent ECM ``ModelVersion`` to be
    unaffected — shrink produces a new MVM row, never mutates the ECM."""
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="ecm", version=1)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        try:
            op.dispatch(ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — dispatch not implemented")
        session.commit()

    with Session(engine) as session:
        parent = session.get(ModelVersion, parent_id)
        assert parent is not None
        assert parent.scope == "ecm"
        assert parent.deployment_status == "draft"


# --------------------------------------------------------------------------
# observe — terminal failure / success modes
# --------------------------------------------------------------------------


def test_observe_reports_terminal_failed_when_job_failed(engine, primitive):
    op, _ = primitive
    ws = make_ws(lifecycle="TERMINATED", result_state="FAILED",
                 state_message="OOM in driver")
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id, op_status="running",
            databricks_run_id=22222,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=22222, vibe_session_id=None)
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
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id, op_status="running",
            databricks_run_id=22222,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=22222, vibe_session_id=None)
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
    """Per §10 row 1 column 3 (same pattern applies to MVM): artifact
    exists → succeeded=True; rollback deletes the version."""
    op, _ = primitive
    valid_model_json = b'{"domains": [], "products": [], "attributes": []}'
    ws = make_ws(
        lifecycle="TERMINATED", result_state="SUCCESS",
        download_payload=valid_model_json,
    )
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id, op_status="running",
            databricks_run_id=22222,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=22222, vibe_session_id=None)
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
    # MVM version exists (so rollback can delete it).
    with Session(engine) as session:
        mvm_versions = session.exec(
            select(ModelVersion).where(
                ModelVersion.business_id == biz_id,
                ModelVersion.scope == "mvm",
            )
        ).all()
        assert len(mvm_versions) == 1


def test_observe_in_flight_returns_non_terminal(engine, primitive):
    op, _ = primitive
    ws = make_ws(lifecycle="RUNNING", result_state="")
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id, op_status="running",
            databricks_run_id=22222,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=22222, vibe_session_id=None)
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
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id, op_status="running",
            databricks_run_id=22222,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=22222, vibe_session_id=None)
        try:
            obs1 = op.observe(handle, ctx, ws, session)
            obs2 = op.observe(handle, ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — observe not implemented")

    assert obs1.is_terminal == obs2.is_terminal


# --------------------------------------------------------------------------
# rollback
# --------------------------------------------------------------------------


def test_rollback_deletes_mvm_version(engine, primitive):
    """Rollback deletes the produced MVM ``ModelVersion`` row but MUST
    NOT touch the parent ECM."""
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="ecm", version=1)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        mvm = ModelVersion(
            business_id=biz_id, version=2, scope="mvm",
            status="completed", deployment_status="draft",
            uc_catalog="deploy_cat",
            base_version_id=parent_id,
        )
        session.add(mvm)
        session.commit()
        session.refresh(mvm)
        mvm_id = mvm.id

        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        rollback_state = {
            "version_id": mvm_id,
            "scope": "mvm",
            "catalog": "deploy_cat",
            "business_name": "test_corp",
            "schema_prefix": "mvm_",
            "model_version": "1",
            "installed_inline": False,
        }
        try:
            op.rollback(ctx, rollback_state, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")
        session.commit()

    with Session(engine) as session:
        assert session.get(ModelVersion, mvm_id) is None
        # ECM parent must remain.
        assert session.get(ModelVersion, parent_id) is not None


def test_rollback_uninstalls_mvm_schema_when_installed_inline(engine, primitive):
    """One-Catalog shrinks install MVM schema inline. Rollback must
    launch the uninstall job."""
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        mvm = ModelVersion(
            business_id=biz_id, version=2, scope="mvm",
            status="completed", deployment_status="deployed",
            uc_catalog="deploy_cat",
            base_version_id=parent_id,
        )
        session.add(mvm)
        session.commit()
        session.refresh(mvm)
        mvm_id = mvm.id

        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
            inherited_params={"cataloging_style": "One Catalog"},
        )
        rollback_state = {
            "version_id": mvm_id,
            "scope": "mvm",
            "catalog": "deploy_cat",
            "business_name": "test_corp",
            "schema_prefix": "mvm_",
            "model_version": "1",
            "installed_inline": True,
        }
        try:
            op.rollback(ctx, rollback_state, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")
        session.commit()

    assert ws.jobs.run_now.called, (
        "rollback for an inline-installed MVM must launch the uninstall job"
    )
    notebook_params = ws.jobs.run_now.call_args.kwargs.get("notebook_params") or {}
    op_widget = notebook_params.get("operation", "")
    assert "uninstall" in op_widget.lower()


def test_rollback_clears_lakebase_data_for_mvm_version(engine, primitive):
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        mvm = ModelVersion(
            business_id=biz_id, version=2, scope="mvm",
            status="completed", deployment_status="draft",
            uc_catalog="deploy_cat",
            base_version_id=parent_id,
        )
        session.add(mvm)
        session.commit()
        session.refresh(mvm)
        d = Domain(version_id=mvm.id, name="sales")
        session.add(d)
        session.commit()
        mvm_id = mvm.id

        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        rollback_state = {
            "version_id": mvm_id,
            "scope": "mvm",
            "catalog": "deploy_cat",
            "business_name": "test_corp",
            "schema_prefix": "mvm_",
            "model_version": "1",
            "installed_inline": False,
        }
        try:
            op.rollback(ctx, rollback_state, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")
        session.commit()

    with Session(engine) as session:
        assert session.exec(
            select(Domain).where(Domain.version_id == mvm_id)
        ).all() == []


def test_rollback_of_never_dispatched_op_is_noop(engine, primitive):
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
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
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        mvm = ModelVersion(
            business_id=biz_id, version=2, scope="mvm",
            status="completed", deployment_status="draft",
            uc_catalog="deploy_cat",
            base_version_id=parent_id,
        )
        session.add(mvm)
        session.commit()
        session.refresh(mvm)
        mvm_id = mvm.id
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        rollback_state = {
            "version_id": mvm_id,
            "scope": "mvm",
            "catalog": "deploy_cat",
            "business_name": "test_corp",
            "schema_prefix": "mvm_",
            "model_version": "1",
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
    assert op.name == "shrink_to_mvm"
    assert op.produces_version is True
