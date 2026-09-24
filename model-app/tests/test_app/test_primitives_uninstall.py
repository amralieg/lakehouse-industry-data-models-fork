"""Adversarial tests for the ``uninstall`` deployment primitive.

Per ``docs/orchestrator-design.md`` §10:

| Primitive | Failure mode 1 | Failure mode 2 |
|---|---|---|
| ``uninstall`` | catalog/schema missing → idempotent success | permission denied → fail, no rollback |

``uninstall`` itself IS the rollback for ``install``, so the primitive does
not own a ``rollback()`` method that does anything productive — replaying
it would just relaunch the same uninstall.
"""

from __future__ import annotations

import os
import sys
from unittest.mock import MagicMock, patch

import pytest

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)

from pydantic import ValidationError

from vibe_modeling.backend.services.operations import (
    OperationContext,
    OperationDispatchHandle,
)
from vibe_modeling.backend.services.operations import _registry as _registry_module
from vibe_modeling.backend.services.operations.uninstall import (
    Uninstall,
    UninstallParams,
)


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------


@pytest.fixture(autouse=True)
def _isolate_registry():
    _registry_module.reset_for_tests()
    yield
    # Restore the production registry so sibling test files that assume
    # primitives are name-resolvable don't see a poisoned empty registry
    # on test-order interleave. Idempotent.
    _registry_module.reset_for_tests()
    _registry_module.restore_production_for_tests()


@pytest.fixture
def uninstall_op() -> Uninstall:
    return Uninstall()


def _ctx(**overrides) -> OperationContext:
    base = dict(
        run_id="run-1",
        operation_id="op-1",
        business_id="biz-1",
        parent_version_id="mv-1",
        params={
            "business_name": "test_corp",
            "deployment_catalog": "test_cat",
            "scope": "ecm",
            "model_version": 1,
        },
        inherited_params={},
    )
    base.update(overrides)
    return OperationContext(**base)


def _mock_ws_with_state(lcs: str, rs: str = "", state_message: str = "") -> MagicMock:
    ws = MagicMock()
    ws.config.host = "https://test.databricks.com"
    job_run = MagicMock()
    job_run.state.life_cycle_state.value = lcs
    job_run.state.result_state.value = rs
    job_run.state.state_message = state_message
    ws.jobs.get_run.return_value = job_run
    return ws


# ---------------------------------------------------------------------------
# Contract surface
# ---------------------------------------------------------------------------


class TestUninstallContract:
    def test_name_is_uninstall(self, uninstall_op):
        assert uninstall_op.name == "uninstall"

    def test_does_not_produce_version(self, uninstall_op):
        assert uninstall_op.produces_version is False

    def test_params_model_is_uninstall_params(self, uninstall_op):
        assert uninstall_op.params_model is UninstallParams


# ---------------------------------------------------------------------------
# Pydantic params validation
# ---------------------------------------------------------------------------


class TestUninstallParamsValidation:
    def _good(self, **overrides) -> dict:
        base = {
            "business_name": "test_corp",
            "deployment_catalog": "test_cat",
            "scope": "ecm",
            "model_version": 1,
        }
        base.update(overrides)
        return base

    def test_happy_path_validates(self):
        UninstallParams(**self._good())

    def test_invalid_catalog_chars_rejected(self):
        # UC catalog naming bug class — keep this one.
        with pytest.raises(ValidationError):
            UninstallParams(**self._good(deployment_catalog="my catalog"))
        with pytest.raises(ValidationError):
            UninstallParams(**self._good(deployment_catalog="my-catalog"))


# ---------------------------------------------------------------------------
# Widget shape on dispatch
# ---------------------------------------------------------------------------


class TestUninstallDispatchWidgets:
    def _capture_launch(self, uninstall_op, ctx) -> dict:
        ws = MagicMock()
        ws.config.host = "https://t.databricks.com"
        captured: dict = {}

        def _fake_launch_run(ws_, job_id, widget_params, *args, **kwargs):
            captured.update(widget_params)
            return 12345

        with patch(
            "vibe_modeling.backend.services.operations.uninstall.launch_run",
            _fake_launch_run,
            create=True,
        ):
            uninstall_op.dispatch(ctx, ws, MagicMock())
        return captured

    def test_operation_widget_is_uninstall_model_version(self, uninstall_op):
        widgets = self._capture_launch(uninstall_op, _ctx())
        assert widgets["operation"] == "uninstall model version"

    def test_model_version_widget_present(self, uninstall_op):
        ctx = _ctx(
            params={
                "business_name": "test_corp",
                "deployment_catalog": "test_cat",
                "scope": "ecm",
                "model_version": 5,
            }
        )
        widgets = self._capture_launch(uninstall_op, ctx)
        # model_version widget is either "5" or "v5" — both forms appear in
        # the legacy code (router.py line 877 prefixes "v" only if missing).
        assert widgets["model_version"] in ("5", "v5")

    def test_deployment_catalog_widget_present(self, uninstall_op):
        widgets = self._capture_launch(uninstall_op, _ctx())
        assert widgets["deployment_catalog"] == "test_cat"


# ---------------------------------------------------------------------------
# Adversarial cases
# ---------------------------------------------------------------------------


class TestUninstallAdversarial:
    def test_catalog_already_missing_is_idempotent_success(self, uninstall_op):
        """Spec §10: catalog/schema already missing → idempotent success.

        The agent's uninstall job, when given a missing catalog, terminates
        with SUCCESS (it has nothing to do). The primitive must surface this
        as terminal succeeded=True, error empty/None.
        """
        ws = _mock_ws_with_state(
            "TERMINATED",
            "SUCCESS",
            state_message="Catalog 'gone_cat' not found, nothing to uninstall",
        )
        handle = OperationDispatchHandle(databricks_run_id=42, vibe_session_id=None)

        obs = uninstall_op.observe(handle, _ctx(), ws, MagicMock())
        assert obs.is_terminal is True
        assert obs.terminal_result is not None
        assert obs.terminal_result.succeeded is True
        assert not obs.terminal_result.error  # empty / None

    def test_schema_already_missing_is_idempotent_success(self, uninstall_op):
        """Same shape but the catalog exists and only the schema is gone.

        This is the second arm of the adversarial case — the production
        impl distinguishes "catalog gone" from "schema gone", but both
        must surface as idempotent success.
        """
        ws = _mock_ws_with_state(
            "TERMINATED",
            "SUCCESS",
            state_message="Schema 'test_cat.gone_schema' not found",
        )
        handle = OperationDispatchHandle(databricks_run_id=42, vibe_session_id=None)
        obs = uninstall_op.observe(handle, _ctx(), ws, MagicMock())
        assert obs.is_terminal is True
        assert obs.terminal_result.succeeded is True

    def test_permission_denied_propagates_clean(self, uninstall_op):
        """Spec §10: permission denied → fail, no rollback. Production impl
        either lets PermissionDenied propagate from launch_run OR catches it
        and surfaces as terminal succeeded=False with the error in the
        OperationResult.
        """
        from databricks.sdk.errors import PermissionDenied

        ws = MagicMock()
        ws.config.host = "https://t.databricks.com"
        session = MagicMock()

        def _fake_launch_run(*args, **kwargs):
            raise PermissionDenied("user lacks DROP SCHEMA on test_cat")

        with patch(
            "vibe_modeling.backend.services.operations.uninstall.launch_run",
            _fake_launch_run,
            create=True,
        ):
            with pytest.raises(PermissionDenied):
                uninstall_op.dispatch(_ctx(), ws, session)

    def test_job_failed_during_uninstall_is_terminal_failed(self, uninstall_op):
        """The uninstall job itself failed mid-execution (not a missing-schema
        case — an actual failure). succeeded=False, error populated.
        """
        ws = _mock_ws_with_state(
            "TERMINATED", "FAILED", state_message="DROP SCHEMA failed: in-use lock"
        )
        handle = OperationDispatchHandle(databricks_run_id=42, vibe_session_id=None)
        obs = uninstall_op.observe(handle, _ctx(), ws, MagicMock())
        assert obs.is_terminal is True
        assert obs.terminal_result.succeeded is False
        assert obs.terminal_result.error  # populated

    def test_job_times_out(self, uninstall_op):
        """Spec §10 / §6: a job that never reaches a terminal state, eventually
        times out. The primitive's observe() returns is_terminal=False until
        the orchestrator decides to give up — but if the impl exposes a
        timeout result, it must report succeeded=False with error populated.

        This test verifies the non-terminal state for an in-progress job
        (BLOCKED + WAITING_FOR_RETRY are still non-terminal per the watchdog
        contract — see progress_tracker._check_job_termination, line 664).
        """
        for lcs in ("BLOCKED", "WAITING_FOR_RETRY"):
            ws = _mock_ws_with_state(lcs)
            handle = OperationDispatchHandle(
                databricks_run_id=42, vibe_session_id=None
            )
            obs = uninstall_op.observe(handle, _ctx(), ws, MagicMock())
            assert obs.is_terminal is False, f"{lcs} should be non-terminal"

    def test_concurrent_uninstall_observes_terminal_success(self, uninstall_op):
        """Spec §10 adversarial: two ops on the same schema. The second one
        observes terminal SUCCESS because the first already removed the schema.

        We model this as a sequence of observe() calls — the second one sees
        TERMINATED+SUCCESS even though the underlying state_message reveals
        the schema was already gone before this run started.
        """
        ws = _mock_ws_with_state(
            "TERMINATED",
            "SUCCESS",
            state_message="Schema test_cat.ecm_v1 already absent — no-op",
        )
        handle_a = OperationDispatchHandle(databricks_run_id=10, vibe_session_id=None)
        handle_b = OperationDispatchHandle(databricks_run_id=11, vibe_session_id=None)

        obs_a = uninstall_op.observe(handle_a, _ctx(), ws, MagicMock())
        obs_b = uninstall_op.observe(handle_b, _ctx(), ws, MagicMock())

        # Both ops see terminal SUCCESS — neither is allowed to escalate
        # "schema already gone" to a failure.
        assert obs_a.is_terminal is True and obs_a.terminal_result.succeeded is True
        assert obs_b.is_terminal is True and obs_b.terminal_result.succeeded is True


# ---------------------------------------------------------------------------
# No-rollback contract
# ---------------------------------------------------------------------------


class TestUninstallNoRollback:
    """Per spec §10: ``uninstall`` IS the rollback. There is no productive
    rollback method — replaying it would just queue another uninstall.
    """

    def test_rollback_is_noop_or_raises_clearly(self, uninstall_op):
        """The contract permits two implementations:
          (a) rollback() raises NotImplementedError / a specific spec error
              (the orchestrator's reverse-walk SKIPS uninstall ops anyway).
          (b) rollback() is an explicit no-op (returns None without doing
              anything).

        Either is acceptable; an UNCONTROLLED side effect (re-launching an
        uninstall job from rollback) is NOT.
        """
        ws = MagicMock()
        ws.config.host = "https://t.databricks.com"
        session = MagicMock()

        launch_calls: list = []

        def _fake_launch_run(ws_, job_id, widget_params, *args, **kwargs):
            launch_calls.append(widget_params)
            return 33333

        try:
            with patch(
                "vibe_modeling.backend.services.operations.uninstall.launch_run",
                _fake_launch_run,
                create=True,
            ):
                uninstall_op.rollback(_ctx(), {}, ws, session)
        except NotImplementedError:
            # Acceptable per (a).
            return
        except Exception as e:
            # Anything else is NOT acceptable — the spec's "no rollback" must
            # not surface as an undocumented exception type.
            pytest.fail(
                f"uninstall.rollback raised unexpected exception type: {type(e).__name__}"
            )

        # If we got here, rollback returned without raising — must be no-op.
        assert (
            len(launch_calls) == 0
        ), "uninstall.rollback must not launch a job (no-rollback contract)"
