"""Tests for the operation primitive contract and registry.

Exercises the surfaces in ``services/operations/`` and the validation
:class:`Issue` type in ``services/orchestrator/_types``. See
``docs/orchestrator-design.md`` §2 for the design.
"""

from __future__ import annotations

import dataclasses

import pytest
from pydantic import BaseModel

from vibe_modeling.backend.services.operations import (
    Operation,
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
    OperationResult,
    all_names,
    get,
    register,
)
from vibe_modeling.backend.services.operations import _registry as _registry_module
from vibe_modeling.backend.services.orchestrator import Issue, Severity


# --------------------------------------------------------------------------
# Fixtures
# --------------------------------------------------------------------------


class _DummyParams(BaseModel):
    """Minimal Pydantic schema used by the fake operations below."""

    pass


def _make_op(op_name: str) -> Operation:
    """Build a concrete :class:`Operation` subclass with every abstract
    method stubbed out, suitable for registry tests."""

    class _StubOp(Operation):
        name = op_name
        params_model = _DummyParams
        is_idempotent = True
        produces_version = False

        def dispatch(self, ctx, ws, session):  # pragma: no cover - stub
            return OperationDispatchHandle(
                databricks_run_id=None, vibe_session_id=None
            )

        def observe(self, handle, ctx, ws, session):  # pragma: no cover - stub
            return OperationObservation(
                progress_percent=0,
                progress_message="",
                is_terminal=False,
                terminal_result=None,
            )

        def rollback(self, ctx, rollback_state, ws, session):  # pragma: no cover - stub
            return None

    return _StubOp()


@pytest.fixture(autouse=True)
def _isolate_registry():
    """Each test starts with an empty registry; teardown restores the
    production registry so sibling test files that assume primitives
    are name-resolvable don't see a poisoned empty registry on
    test-order interleave."""
    _registry_module.reset_for_tests()
    yield
    _registry_module.reset_for_tests()
    _registry_module.restore_production_for_tests()


# --------------------------------------------------------------------------
# Registry
# --------------------------------------------------------------------------


def test_registry_register_and_get_roundtrip():
    op = _make_op("alpha")
    register(op)
    assert get("alpha") is op


def test_registry_duplicate_register_raises_value_error():
    register(_make_op("dup"))
    with pytest.raises(ValueError, match="already registered"):
        register(_make_op("dup"))


def test_registry_get_unknown_raises_key_error():
    with pytest.raises(KeyError, match="Unknown operation"):
        get("does_not_exist")


def test_registry_reset_for_tests_clears_registrations():
    register(_make_op("ephemeral"))
    assert "ephemeral" in all_names()
    _registry_module.reset_for_tests()
    assert all_names() == []
    with pytest.raises(KeyError):
        get("ephemeral")


# --------------------------------------------------------------------------
# Value types: construction and immutability
# --------------------------------------------------------------------------


def test_operation_context_constructable_and_frozen():
    ctx = OperationContext(
        run_id="r1",
        operation_id="op1",
        business_id="b1",
        parent_version_id=None,
        params={"k": "v"},
        inherited_params={"cataloging_style": "One Catalog"},
    )
    assert ctx.run_id == "r1"
    assert ctx.parent_version_id is None
    assert ctx.params == {"k": "v"}

    with pytest.raises(dataclasses.FrozenInstanceError):
        ctx.run_id = "r2"  # type: ignore[misc]


def test_operation_dispatch_handle_constructable_and_frozen():
    handle = OperationDispatchHandle(
        databricks_run_id=12345,
        vibe_session_id="sess-abc",
    )
    assert handle.databricks_run_id == 12345
    assert handle.vibe_session_id == "sess-abc"
    assert handle.extra == {}  # default factory

    with pytest.raises(dataclasses.FrozenInstanceError):
        handle.databricks_run_id = 999  # type: ignore[misc]


def test_operation_result_constructable_and_frozen():
    result = OperationResult(
        succeeded=True,
        output_version_id="v-42",
        output_artifacts=[{"artifact_type": "log", "file_path": "/tmp/x"}],
        rollback_state={"deleted_id": "v-42"},
        error=None,
    )
    assert result.succeeded is True
    assert result.output_version_id == "v-42"
    assert result.output_artifacts[0]["artifact_type"] == "log"

    with pytest.raises(dataclasses.FrozenInstanceError):
        result.succeeded = False  # type: ignore[misc]


def test_operation_observation_constructable_and_frozen():
    obs_progress = OperationObservation(
        progress_percent=42,
        progress_message="halfway",
        is_terminal=False,
        terminal_result=None,
    )
    assert obs_progress.progress_percent == 42
    assert obs_progress.is_terminal is False
    assert obs_progress.terminal_result is None

    terminal = OperationResult(
        succeeded=True,
        output_version_id=None,
        output_artifacts=[],
        rollback_state={},
        error=None,
    )
    obs_terminal = OperationObservation(
        progress_percent=100,
        progress_message="done",
        is_terminal=True,
        terminal_result=terminal,
    )
    assert obs_terminal.is_terminal is True
    assert obs_terminal.terminal_result is terminal

    with pytest.raises(dataclasses.FrozenInstanceError):
        obs_terminal.progress_percent = 0  # type: ignore[misc]


# --------------------------------------------------------------------------
# Issue / Severity
# --------------------------------------------------------------------------


def test_issue_constructable_with_blocker_severity():
    issue = Issue(
        field_path="deployment_catalog",
        step_index=1,
        message="Catalog name has invalid characters",
        severity="blocker",
    )
    assert issue.severity == "blocker"
    assert issue.step_index == 1


def test_issue_constructable_with_warning_severity():
    issue = Issue(
        field_path="schema_prefix",
        step_index=0,
        message="Should end in _ for readability",
        severity="warning",
    )
    assert issue.severity == "warning"


def test_issue_is_frozen():
    issue = Issue(
        field_path="x",
        step_index=0,
        message="m",
        severity="warning",
    )
    with pytest.raises(dataclasses.FrozenInstanceError):
        issue.severity = "blocker"  # type: ignore[misc]


