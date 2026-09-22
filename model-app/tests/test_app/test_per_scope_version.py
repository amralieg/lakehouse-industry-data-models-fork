"""Tests for per-scope version computation across all MV creation sites.

Asserts the post-refactor invariants:

* Every site that creates a ``ModelVersion`` allocates ``version`` as
  ``max(version WHERE business=X AND scope=this_scope) + 1``.
* The unified-pipeline shrink writes the MVM at the SAME version int as
  the parent ECM (ECM v=N → MVM v=N).
* Vibe-iterate inherits the parent's scope and increments per-scope.
* The agent's ``generated_from_version`` tag round-trips through
  ``parse_generated_from_version``.
"""

from __future__ import annotations

import json
import os
import sys
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)
sys.path.insert(0, os.path.dirname(__file__))

from vibe_modeling.backend._query_helpers import (
    next_version_for_scope,
    parse_generated_from_version,
)
from vibe_modeling.backend.db_models import (
    Business,
    ModelVersion,
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


# ---------------------------------------------------------------------------
# next_version_for_scope spot-checks
# ---------------------------------------------------------------------------


def test_per_scope_counter_isolates_ecm_and_mvm():
    eng = make_engine()
    with Session(eng) as s:
        biz = Business(name="acme")
        s.add(biz)
        s.commit()
        s.refresh(biz)

        # No rows: both scopes start at 1.
        assert next_version_for_scope(s, biz.id, "ecm") == 1
        assert next_version_for_scope(s, biz.id, "mvm") == 1

        # Insert ECM v1 + MVM v1 (the unified-pipeline shrink shape).
        s.add(ModelVersion(business_id=biz.id, version=1, scope="ecm"))
        s.add(ModelVersion(business_id=biz.id, version=1, scope="mvm"))
        s.commit()

        # Next per-scope is 2 for both — they don't see each other's counter.
        assert next_version_for_scope(s, biz.id, "ecm") == 2
        assert next_version_for_scope(s, biz.id, "mvm") == 2


# ---------------------------------------------------------------------------
# Shrink to MVM observation creates MVM at parent ECM's version
# ---------------------------------------------------------------------------


def _terminal_success_jobs_state(ws: MagicMock) -> None:
    """Stub the WorkspaceClient so observe sees TERMINATED/SUCCESS."""
    state = MagicMock()
    state.state.life_cycle_state.value = "TERMINATED"
    state.state.result_state.value = "SUCCESS"
    state.state.state_message = ""
    ws.jobs.get_run.return_value = state


def _model_json_download(ws: MagicMock, payload: dict) -> None:
    resp = MagicMock()
    resp.contents.read.return_value = json.dumps(payload).encode()
    ws.files.download.side_effect = None
    ws.files.download.return_value = resp


def _no_session_row(ws: MagicMock) -> None:
    """Stub the SQL warehouse so the pipeline_error pre-check finds nothing."""
    result = MagicMock()
    result.status = MagicMock(error=None)
    result.result = MagicMock(data_array=[])
    ws.statement_execution.execute_statement.return_value = result


def test_shrink_writes_mvm_at_parent_ecm_version():
    """ECM v=N → MVM v=N. The agent does this on disk; the DB row mirrors it."""
    from vibe_modeling.backend.services.operations.shrink_to_mvm import ShrinkToMvm

    eng = make_engine()
    ws = make_ws(lifecycle="TERMINATED", result_state="SUCCESS")
    _model_json_download(ws, {"model": {
        "type": "business",
        "domains": [],
        "generated_from_version": "v3_ecm",
    }})
    _no_session_row(ws)

    with Session(eng) as session:
        biz_id, _ = seed_business_and_agent(session)
        # Parent ECM is at version=3 (not 1) — proves we mirror the parent's
        # exact integer, not "the next ordinal" or "1".
        parent_id = parent_version(session, biz_id, scope="ecm", version=3)
        run_id, op_id = seed_run_with_op(
            session,
            business_id=biz_id,
            operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        ctx = make_ctx(
            run_id=run_id,
            operation_id=op_id,
            business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )

        op = ShrinkToMvm()
        from vibe_modeling.backend.services.operations import (
            OperationDispatchHandle,
        )
        handle = OperationDispatchHandle(
            databricks_run_id=12345,
            vibe_session_id="abcd-efgh",
        )
        obs = op.observe(handle, ctx, ws, session)

        assert obs.is_terminal is True
        assert obs.terminal_result is not None
        assert obs.terminal_result.succeeded is True

        new_id = obs.terminal_result.output_version_id
        assert new_id is not None
        new_mv = session.get(ModelVersion, new_id)
        assert new_mv is not None, "new MVM row was not created"
        assert new_mv.scope == "mvm"
        # The critical assertion: same version int as the parent ECM.
        assert new_mv.version == 3, (
            f"shrink must mirror parent ECM's version int "
            f"(expected 3, got {new_mv.version})"
        )
        # Lineage from generated_from_version was resolved.
        assert new_mv.base_version_id == parent_id


# ---------------------------------------------------------------------------
# Vibe-iterate per-scope max+1
# ---------------------------------------------------------------------------


def test_vibe_iterate_allocates_per_scope_next():
    """Iterating MVM v=2 with siblings MVM v=1, v=2 lands at MVM v=3 — not at
    the global max+1 (which would be v=4 if an unrelated ECM v=3 existed)."""
    from vibe_modeling.backend.services.operations.vibe_iterate import VibeIterate

    eng = make_engine()
    ws = make_ws()
    # Make download return a model.json with the iterate's expected shape.
    payload = json.dumps({"model": {
        "type": "business",
        "domains": [],
        "generated_from_version": "v2_mvm",
    }}).encode()
    resp = MagicMock()
    resp.contents.read.return_value = payload
    ws.files.download.return_value = resp

    with Session(eng) as session:
        biz_id, _ = seed_business_and_agent(session)
        # Seed: ECM v=1, ECM v=2, ECM v=3, MVM v=1, MVM v=2.
        for v in (1, 2, 3):
            session.add(ModelVersion(
                business_id=biz_id, version=v, scope="ecm",
                status="completed", deployment_status="draft",
            ))
        for v in (1, 2):
            session.add(ModelVersion(
                business_id=biz_id, version=v, scope="mvm",
                status="completed", deployment_status="draft",
            ))
        session.commit()

        parent = session.exec(
            select(ModelVersion).where(
                ModelVersion.business_id == biz_id,
                ModelVersion.version == 2,
                ModelVersion.scope == "mvm",
            )
        ).first()
        assert parent is not None

        run_id, op_id = seed_run_with_op(
            session,
            business_id=biz_id,
            operation_name="vibe_iterate",
            parent_version_id=parent.id,
        )

        ctx = make_ctx(
            run_id=run_id,
            operation_id=op_id,
            business_id=biz_id,
            parent_version_id=parent.id,
            params={
                "vibe_instructions": "shrink the customer domain",
                "deployment_catalog": "deploy_cat",
                "business_name": "test_corp",
                "parent_version_int": 2,
            },
        )

        op = VibeIterate()
        from vibe_modeling.backend.services.operations import (
            OperationDispatchHandle,
        )
        handle = OperationDispatchHandle(
            databricks_run_id=99,
            vibe_session_id="zzz",
            extra={
                "deployment_catalog": "deploy_cat",
                "business_name": "test_corp",
                "parent_version_int": 2,
            },
        )

        # Drive _finalize_success directly so we don't need to mock the
        # full Jobs API + Delta polling chain. The unit under test is the
        # version-allocation logic.
        result = op._finalize_success(
            handle, ctx, ws, session, model_json={"model": {
                "type": "business",
                "domains": [],
                "generated_from_version": "v2_mvm",
            }},
        )

        assert result.succeeded is True
        new_mv = session.get(ModelVersion, result.output_version_id)
        assert new_mv is not None
        # Per-scope: MVM had v=1, v=2 → next is v=3. NOT v=4 (which would be
        # the global max+1 across both scopes).
        assert new_mv.scope == "mvm"
        assert new_mv.version == 3, (
            f"vibe-iterate must allocate per-scope (expected MVM v=3, "
            f"got v={new_mv.version})"
        )
        # Lineage points at the parent.
        assert new_mv.base_version_id == parent.id


# ---------------------------------------------------------------------------
# generated_from_version parsing
# ---------------------------------------------------------------------------


def test_generated_from_version_parses_v1_ecm():
    assert parse_generated_from_version("v1_ecm") == (1, "ecm")


def test_generated_from_version_parses_v2_mvm():
    assert parse_generated_from_version("v2_mvm") == (2, "mvm")


def test_generated_from_version_rejects_unknown():
    assert parse_generated_from_version("unknown") is None
    assert parse_generated_from_version("") is None
