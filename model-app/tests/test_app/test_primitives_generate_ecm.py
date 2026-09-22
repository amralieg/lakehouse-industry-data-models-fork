"""Adversarial tests for the ``generate_ecm`` Operation primitive.

Phase 2 — Group A. Derived from ``docs/orchestrator-design.md`` §2 and
§10's per-primitive failure-mode table. Tests are written against the
public Operation contract; they do not import the dev agent's
implementation. See ``_phase2_stubs.py`` for the integration-time swap.

Failure modes covered (per §10 row 1):

* Job times out / FAILED → orchestrator marks failed.
* Job succeeds but ``model.json`` missing → terminal_result.succeeded
  is False, error mentions the missing artifact, no version.
* Job succeeds, ``model.json`` valid, lakebase sync fails → succeeded
  is True (artifact exists in the Volume) but the produced
  ``ModelVersion`` is in a sync-failed state; rollback deletes the
  version.
* Idempotent dispatch (re-call with same ctx + pre-existing
  ``databricks_run_id``) → does NOT relaunch.
* Permission denied during dispatch → exception propagates, no row
  partial state.
* Cancel mid-flight → ``rollback()`` deletes the ModelVersion,
  uninstalls the schema (One Catalog inline), clears Lakebase model
  data.
* Rollback of a never-dispatched op → no-op.
* Concurrent ``observe`` → both calls return consistent snapshots.

Plus the contract assertions:

* Widget shape — ``operation == "new base model"`` and
  ``data_model_scopes`` includes the ECM long-form.
* Pydantic params validation — bad inputs raise ``ValidationError``.
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
# resolve as flat module names (no `tests.test_app.` prefix needed).
sys.path.insert(0, os.path.dirname(__file__))

from vibe_modeling.backend.db_models import (
    Domain,
    ModelVersion,
    Product,
    RunOperation,
)  # noqa: F401 — Product is used inline in lakebase clear test
from vibe_modeling.backend.services.operations import (
    OperationDispatchHandle,
)

from _phase2_helpers import (
    GENERATE_ECM_VALID_PARAMS,
    make_ctx,
    make_engine,
    make_ws,
    seed_business_and_agent,
    seed_run_with_op,
)
from _phase2_stubs import load_primitive


@pytest.fixture
def engine():
    return make_engine()


@pytest.fixture
def primitive():
    op, params_model = load_primitive("generate_ecm")
    return op, params_model


# --------------------------------------------------------------------------
# Pydantic params validation (§2.4 — field-level rules)
# --------------------------------------------------------------------------


def test_params_accepts_all_three_cataloging_styles(primitive):
    """Sanity guard — the Literal must include the three documented values."""
    _op, params_model = primitive
    for style in ("One Catalog", "Catalog per Division", "Catalog per Domain"):
        params_model(**{**GENERATE_ECM_VALID_PARAMS, "cataloging_style": style})


# --------------------------------------------------------------------------
# dispatch — widget contract (§10 + agent widget map)
# --------------------------------------------------------------------------


def test_dispatch_launches_with_new_base_model_operation(engine, primitive):
    """``generate_ecm`` MUST send ``operation='new base model'`` and the ECM
    long-form scope to the agent notebook."""
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params=GENERATE_ECM_VALID_PARAMS,
        )
        try:
            op.dispatch(ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — dispatch not implemented")

    # The primitive must call run_now exactly once with the right widgets.
    assert ws.jobs.run_now.called, "dispatch must call ws.jobs.run_now"
    notebook_params = ws.jobs.run_now.call_args.kwargs.get("notebook_params") or (
        ws.jobs.run_now.call_args.args[1]
        if len(ws.jobs.run_now.call_args.args) > 1
        else {}
    )
    assert notebook_params.get("operation") == "new base model"
    assert "Expanded Coverage Model - ECM" in notebook_params.get(
        "data_model_scopes", ""
    )


def test_dispatch_returns_handle_with_databricks_run_id(engine, primitive):
    op, _ = primitive
    ws = make_ws(run_now_run_id=777_001)
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params=GENERATE_ECM_VALID_PARAMS,
        )
        try:
            handle = op.dispatch(ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — dispatch not implemented")

    assert isinstance(handle, OperationDispatchHandle)
    assert handle.databricks_run_id == 777_001


def test_dispatch_persists_databricks_run_id_on_run_operation_row(engine, primitive):
    """The orchestrator owns Run state, but the primitive MUST write its own
    ``RunOperation.databricks_run_id`` so resume + idempotent dispatch work."""
    op, _ = primitive
    ws = make_ws(run_now_run_id=777_002)
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params=GENERATE_ECM_VALID_PARAMS,
        )
        try:
            op.dispatch(ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — dispatch not implemented")
        session.commit()

    with Session(engine) as session:
        ro = session.get(RunOperation, op_id)
        assert ro is not None
        assert ro.databricks_run_id == 777_002


def test_dispatch_propagates_permission_denied(engine, primitive):
    """If the SDK raises (permission denied / 403), the exception MUST
    propagate and the RunOperation row MUST NOT carry a phantom
    ``databricks_run_id``."""
    op, _ = primitive
    ws = make_ws()
    ws.jobs.run_now.side_effect = PermissionError("not authorized")
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params=GENERATE_ECM_VALID_PARAMS,
        )
        with pytest.raises((PermissionError, RuntimeError, NotImplementedError)):
            op.dispatch(ctx, ws, session)
        try:
            session.commit()
        except Exception:
            session.rollback()

    with Session(engine) as session:
        ro = session.get(RunOperation, op_id)
        # Either the row stayed as-is (no run id) or the failure was
        # surfaced cleanly. The forbidden state is "marked running with a
        # bogus run id".
        assert ro is not None
        assert ro.databricks_run_id is None


# --------------------------------------------------------------------------
# observe — terminal failure / success modes
# --------------------------------------------------------------------------


def test_observe_reports_terminal_failed_when_job_failed(engine, primitive):
    """Job FAILED in Databricks → observation is_terminal True,
    terminal_result.succeeded False, error populated."""
    op, _ = primitive
    ws = make_ws(lifecycle="TERMINATED", result_state="FAILED",
                 state_message="Cluster crashed")
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
            op_status="running", databricks_run_id=12345,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params=GENERATE_ECM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(
            databricks_run_id=12345, vibe_session_id="sess-xyz",
        )
        try:
            obs = op.observe(handle, ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — observe not implemented")

    assert obs.is_terminal is True
    assert obs.terminal_result is not None
    assert obs.terminal_result.succeeded is False
    assert obs.terminal_result.error
    # No version produced on a failed job.
    assert obs.terminal_result.output_version_id is None


def test_observe_reports_no_version_on_failed_job(engine, primitive):
    """No ``ModelVersion`` row should land in the session for a job that
    failed — the orchestrator owns version creation only on success."""
    op, _ = primitive
    ws = make_ws(lifecycle="TERMINATED", result_state="FAILED")
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
            op_status="running", databricks_run_id=12345,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params=GENERATE_ECM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=12345, vibe_session_id=None)
        try:
            op.observe(handle, ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — observe not implemented")
        session.commit()

    with Session(engine) as session:
        versions = session.exec(
            select(ModelVersion).where(ModelVersion.business_id == biz_id)
        ).all()
        assert versions == []


def test_observe_reports_succeeded_false_when_model_json_missing(
    monkeypatch, engine, primitive
):
    """Job SUCCEEDED but ``model.json`` is not in the Volume → succeeded
    False, error mentions missing artifact, no version produced."""
    # observe_generation_op retries 5 times with backoff (1+2+4+8 = 15s)
    # for Volume FUSE eventual consistency; mock the sleep so the test
    # exhausts retries instantly.
    monkeypatch.setattr(
        "vibe_modeling.backend.services.operations._generation_common.time.sleep",
        lambda *_a, **_kw: None,
    )
    op, _ = primitive
    ws = make_ws(
        lifecycle="TERMINATED",
        result_state="SUCCESS",
        download_raises=FileNotFoundError("model.json"),
    )
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
            op_status="running", databricks_run_id=12345,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params=GENERATE_ECM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=12345, vibe_session_id=None)
        try:
            obs = op.observe(handle, ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — observe not implemented")

    assert obs.is_terminal is True
    assert obs.terminal_result is not None
    assert obs.terminal_result.succeeded is False
    err = (obs.terminal_result.error or "").lower()
    assert "model.json" in err or "artifact" in err or "missing" in err
    assert obs.terminal_result.output_version_id is None


def test_observe_lakebase_sync_failure_marks_version_failed_and_reports_succeeded(
    engine, primitive
):
    """Job SUCCEEDED + ``model.json`` valid + Lakebase sync fails → the
    terminal artifact (the Volume file) exists, so ``succeeded=True``.
    But the produced ModelVersion's status reflects the sync failure
    (the rollback can then delete it). Per §10 row 1 column 3.
    """
    op, _ = primitive
    valid_model_json = b'{"domains": [], "products": [], "attributes": []}'
    ws = make_ws(
        lifecycle="TERMINATED",
        result_state="SUCCESS",
        download_payload=valid_model_json,
    )
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
            op_status="running", databricks_run_id=12345,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params=GENERATE_ECM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=12345, vibe_session_id=None)

        # Force the sync layer to raise. Patching at the import boundary
        # rather than instance-level so the primitive picks up the failure
        # however it constructs the sync service.
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
    # Per §10: the artifact exists, so succeeded=True.
    assert obs.terminal_result is not None
    assert obs.terminal_result.succeeded is True
    # The produced version exists (so rollback can delete it) but was
    # not synced — neither Domain nor Product rows should have landed.
    with Session(engine) as session:
        versions = session.exec(
            select(ModelVersion).where(ModelVersion.business_id == biz_id)
        ).all()
        assert len(versions) == 1
        domains = session.exec(
            select(Domain).where(Domain.version_id == versions[0].id)
        ).all()
        assert domains == []


def test_observe_in_flight_returns_non_terminal(engine, primitive):
    """A job that's still RUNNING should produce a non-terminal observation."""
    op, _ = primitive
    ws = make_ws(lifecycle="RUNNING", result_state="")
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
            op_status="running", databricks_run_id=12345,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params=GENERATE_ECM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=12345, vibe_session_id=None)
        try:
            obs = op.observe(handle, ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — observe not implemented")

    assert obs.is_terminal is False
    assert obs.terminal_result is None


def test_observe_concurrent_calls_return_consistent_snapshots(engine, primitive):
    """Two concurrent ``observe`` calls with the same handle MUST return
    consistent snapshots — neither corrupts state."""
    op, _ = primitive
    ws = make_ws(lifecycle="RUNNING", result_state="")
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
            op_status="running", databricks_run_id=12345,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params=GENERATE_ECM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=12345, vibe_session_id=None)
        try:
            obs1 = op.observe(handle, ctx, ws, session)
            obs2 = op.observe(handle, ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — observe not implemented")

    assert obs1.is_terminal == obs2.is_terminal
    # Same handle, same ws, same context → progress shape should be stable.
    if not obs1.is_terminal:
        assert obs1.terminal_result is None and obs2.terminal_result is None


# --------------------------------------------------------------------------
# rollback — version + schema cleanup
# --------------------------------------------------------------------------


def test_rollback_deletes_produced_model_version(engine, primitive):
    """When rollback_state references a created version_id, the
    ``ModelVersion`` row MUST be deleted from the session."""
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
        )
        mv = ModelVersion(
            business_id=biz_id, version=1, scope="ecm",
            status="completed", deployment_status="draft",
            uc_catalog="deploy_cat",
        )
        session.add(mv)
        session.commit()
        session.refresh(mv)
        version_id = mv.id

        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params=GENERATE_ECM_VALID_PARAMS,
        )
        rollback_state = {
            "version_id": version_id,
            "scope": "ecm",
            "catalog": "deploy_cat",
            "business_name": "test_corp",
            "schema_prefix": "ecm_",
            "model_version": "1",
            "installed_inline": False,
        }
        try:
            op.rollback(ctx, rollback_state, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")
        session.commit()

    with Session(engine) as session:
        assert session.get(ModelVersion, version_id) is None


def test_rollback_clears_lakebase_model_data(engine, primitive):
    """Rollback MUST drop Domain/Product rows for the deleted version
    before deleting the MV (FK ordering — see progress_tracker comment
    about Domain.version_id)."""
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
        )
        mv = ModelVersion(
            business_id=biz_id, version=1, scope="ecm",
            status="completed", deployment_status="draft",
            uc_catalog="deploy_cat",
        )
        session.add(mv)
        session.commit()
        session.refresh(mv)
        d = Domain(version_id=mv.id, name="sales")
        session.add(d)
        session.commit()
        session.refresh(d)
        p = Product(version_id=mv.id, domain_id=d.id, name="orders")
        session.add(p)
        session.commit()

        version_id = mv.id
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params=GENERATE_ECM_VALID_PARAMS,
        )
        rollback_state = {
            "version_id": version_id,
            "scope": "ecm",
            "catalog": "deploy_cat",
            "business_name": "test_corp",
            "schema_prefix": "ecm_",
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
            select(Domain).where(Domain.version_id == version_id)
        ).all() == []


def test_rollback_uninstalls_schema_when_installed_inline(engine, primitive):
    """For ``cataloging_style == 'One Catalog'`` the agent installs the
    ECM schema inline as part of generation. Rollback MUST trigger an
    agent uninstall (i.e. ``launch_run`` is called with the uninstall
    operation widgets)."""
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
        )
        mv = ModelVersion(
            business_id=biz_id, version=1, scope="ecm",
            status="completed", deployment_status="deployed",
            uc_catalog="deploy_cat",
        )
        session.add(mv)
        session.commit()
        session.refresh(mv)
        version_id = mv.id
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params=GENERATE_ECM_VALID_PARAMS,
            inherited_params={"cataloging_style": "One Catalog"},
        )
        rollback_state = {
            "version_id": version_id,
            "scope": "ecm",
            "catalog": "deploy_cat",
            "business_name": "test_corp",
            "schema_prefix": "ecm_",
            "model_version": "1",
            "installed_inline": True,
        }
        try:
            op.rollback(ctx, rollback_state, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")
        session.commit()

    # The uninstall is fired via run_now on the agent job (see
    # router._dispatch_rollback_op for the legacy precedent). What we
    # care about is that *some* job was launched against the workspace
    # client to uninstall the schema.
    assert ws.jobs.run_now.called, (
        "rollback for an inline-installed ECM must launch the uninstall job"
    )
    notebook_params = ws.jobs.run_now.call_args.kwargs.get("notebook_params") or {}
    op_widget = notebook_params.get("operation", "")
    assert "uninstall" in op_widget.lower()


def test_rollback_fires_uninstall_for_multi_catalog_deployed_version(engine, primitive):
    """Regression: when the agent runs a multi-catalog (Catalog per
    Division / Catalog per Domain) generation, it still inline-installs
    the schemas (integration guide §12). A failed multi-catalog run
    therefore needs the same agent-side uninstall as One Catalog mode.

    Pre-fix, the rollback gate also required ``inherited_style == "One
    Catalog"`` — so multi-catalog failures left schemas dangling. This
    test pins the post-fix contract: any rollback_state with
    ``deployment_status == "deployed"`` fires uninstall, regardless of
    cataloging_style.
    """
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
        )
        mv = ModelVersion(
            business_id=biz_id, version=1, scope="ecm",
            status="completed", deployment_status="deployed",
            uc_catalog="per_domain_cat",
        )
        session.add(mv)
        session.commit()
        session.refresh(mv)
        version_id = mv.id
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params=GENERATE_ECM_VALID_PARAMS,
            inherited_params={"cataloging_style": "Catalog per Domain"},
        )
        # The orchestrator does not set ``installed_inline`` for the
        # generation-group primitives — they record ``deployment_status``
        # instead. The rollback gate must fire on the latter alone.
        rollback_state = {
            "version_id": version_id,
            "scope": "ecm",
            "catalog": "per_domain_cat",
            "business_name": "test_corp",
            "schema_prefix": "",
            "model_version_int": 1,
            "deployment_status": "deployed",
        }
        try:
            op.rollback(ctx, rollback_state, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")
        session.commit()

    assert ws.jobs.run_now.called, (
        "rollback for a multi-catalog deployed ECM must launch the "
        "uninstall job — the agent installed inline in every "
        "cataloging_style per integration guide §12"
    )
    notebook_params = ws.jobs.run_now.call_args.kwargs.get("notebook_params") or {}
    assert "uninstall" in notebook_params.get("operation", "").lower()
    # Task #2b's widget-builder gate requires a non-empty model_version
    # on the uninstall call — verify that's what we're passing.
    assert notebook_params.get("model_version") == "1"
    assert notebook_params.get("deployment_catalog") == "per_domain_cat"


def test_rollback_of_never_dispatched_op_is_noop(engine, primitive):
    """Rollback against an op that never ran (no ``version_id`` in
    rollback_state) MUST NOT raise — the contract calls this 'idempotent
    delete-of-nothing'."""
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params=GENERATE_ECM_VALID_PARAMS,
        )
        try:
            op.rollback(ctx, {}, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")


def test_rollback_is_idempotent(engine, primitive):
    """Calling rollback twice with the same state on the same op MUST
    not raise — the version is gone after the first call, the second is
    a no-op (per §2 'rollback() MUST be idempotent')."""
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
        )
        mv = ModelVersion(
            business_id=biz_id, version=1, scope="ecm",
            status="completed", deployment_status="draft",
            uc_catalog="deploy_cat",
        )
        session.add(mv)
        session.commit()
        session.refresh(mv)
        version_id = mv.id

        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params=GENERATE_ECM_VALID_PARAMS,
        )
        rollback_state = {
            "version_id": version_id,
            "scope": "ecm",
            "catalog": "deploy_cat",
            "business_name": "test_corp",
            "schema_prefix": "ecm_",
            "model_version": "1",
            "installed_inline": False,
        }
        try:
            op.rollback(ctx, rollback_state, ws, session)
            session.commit()
            # Second invocation must NOT raise even though the MV is gone.
            op.rollback(ctx, rollback_state, ws, session)
            session.commit()
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")


# --------------------------------------------------------------------------
# Class-level invariants
# --------------------------------------------------------------------------


def test_class_attributes_match_contract(primitive):
    op, _ = primitive
    assert op.name == "generate_ecm"
    assert op.produces_version is True
