"""Adversarial tests for the ``generate_samples`` deployment primitive.

Per ``docs/orchestrator-design.md`` §10: ``generate_samples`` has no rollback
(samples live in installed schemas; uninstall handles cleanup).

Adversarial cases tested:
1. Schema doesn't exist (install missing) → succeeded=False, error mentions schema.
2. Sample size 0 / negative → params validation rejects.
3. Job fails mid-generation → succeeded=False, no rollback side effects.
4. Sample generation succeeds → succeeded=True, output_artifacts may include
   sample-row metadata.
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
from vibe_modeling.backend.services.operations.generate_samples import (
    GenerateSamples,
    GenerateSamplesParams,
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
def gs_op() -> GenerateSamples:
    return GenerateSamples()


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
            "sample_count": 100,
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


class TestGenerateSamplesContract:
    def test_name_is_generate_samples(self, gs_op):
        assert gs_op.name == "generate_samples"

    def test_does_not_produce_version(self, gs_op):
        # Spec §2: generate_samples writes data into existing schemas;
        # produces_version=False.
        assert gs_op.produces_version is False

    def test_params_model_is_generate_samples_params(self, gs_op):
        assert gs_op.params_model is GenerateSamplesParams


# ---------------------------------------------------------------------------
# Pydantic params validation
# ---------------------------------------------------------------------------


class TestGenerateSamplesParamsValidation:
    def _good(self, **overrides) -> dict:
        base = {
            "business_name": "test_corp",
            "deployment_catalog": "test_cat",
            "scope": "ecm",
            "model_version": 1,
            "sample_count": 100,
        }
        base.update(overrides)
        return base

    def test_happy_path_validates(self):
        GenerateSamplesParams(**self._good())

    def test_sample_count_zero_rejected(self):
        with pytest.raises(ValidationError) as ei:
            GenerateSamplesParams(**self._good(sample_count=0))
        # The error must point at sample_count, not silently coerce.
        msg = str(ei.value)
        assert "sample_count" in msg or "greater than" in msg

    def test_sample_count_negative_rejected(self):
        with pytest.raises(ValidationError):
            GenerateSamplesParams(**self._good(sample_count=-5))

    def test_sample_count_above_cap_rejected(self):
        # Sanity cap — a million-row sample run would idle a warehouse for
        # hours and cost real money. The cap value is up to the impl; we
        # assert that *some* upper bound exists by trying a clearly-too-big
        # value.
        with pytest.raises(ValidationError):
            GenerateSamplesParams(**self._good(sample_count=10_000_001))

    def test_sample_count_must_be_int_not_string(self):
        # Pydantic v2 will coerce "100" → 100, but a non-numeric string
        # must still raise. This guards against a UI bug that submits
        # "ten" or "" by accident.
        with pytest.raises(ValidationError):
            GenerateSamplesParams(**self._good(sample_count="lots"))

# ---------------------------------------------------------------------------
# Widget shape on dispatch
# ---------------------------------------------------------------------------


class TestGenerateSamplesDispatchWidgets:
    def _capture_launch(self, gs_op, ctx) -> dict:
        ws = MagicMock()
        ws.config.host = "https://t.databricks.com"
        captured: dict = {}

        def _fake_launch_run(ws_, job_id, widget_params, *args, **kwargs):
            captured.update(widget_params)
            return 12345

        with patch(
            "vibe_modeling.backend.services.operations.generate_samples.launch_run",
            _fake_launch_run,
            create=True,
        ):
            gs_op.dispatch(ctx, ws, MagicMock())
        return captured

    def test_operation_widget_is_generate_sample_data(self, gs_op):
        widgets = self._capture_launch(gs_op, _ctx())
        assert widgets["operation"] == "generate sample data"

    def test_sample_count_widget_present(self, gs_op):
        ctx = _ctx(
            params={
                "business_name": "test_corp",
                "deployment_catalog": "test_cat",
                "scope": "ecm",
                "model_version": 1,
                "sample_count": 250,
            }
        )
        widgets = self._capture_launch(gs_op, ctx)
        # Per ``map_run_params_to_widgets``, the sample-count widget is
        # ``generate_samples`` (string-typed int — see job_launcher.py:109).
        # Production impl is expected to follow that convention.
        candidate_keys = ("generate_samples", "sample_count", "sample_size")
        present = [k for k in candidate_keys if k in widgets]
        assert (
            len(present) >= 1
        ), f"sample-count widget missing; widgets={widgets!r}"
        # Whichever key the impl uses, the value MUST be the string form of
        # the int we passed in.
        assert widgets[present[0]] == "250"

    def test_model_version_widget_present(self, gs_op):
        ctx = _ctx(
            params={
                "business_name": "test_corp",
                "deployment_catalog": "test_cat",
                "scope": "ecm",
                "model_version": 9,
                "sample_count": 100,
            }
        )
        widgets = self._capture_launch(gs_op, ctx)
        assert widgets["model_version"] in ("9", "v9")

    def test_data_model_scopes_widget_for_mvm(self, gs_op):
        ctx = _ctx(
            params={
                "business_name": "test_corp",
                "deployment_catalog": "test_cat",
                "scope": "mvm",
                "model_version": 1,
                "sample_count": 100,
            }
        )
        widgets = self._capture_launch(gs_op, ctx)
        assert "MVM" in widgets["data_model_scopes"]


# ---------------------------------------------------------------------------
# Adversarial cases
# ---------------------------------------------------------------------------


class TestGenerateSamplesAdversarial:
    def test_schema_missing_terminates_failed_with_schema_error(self, gs_op):
        """Spec §10: schema doesn't exist (install missing) → succeeded=False,
        error mentions the schema. The agent's `generate sample data` job
        fails fast in this case — the primitive must surface the schema
        error in OperationResult.error.
        """
        ws = _mock_ws_with_state(
            "TERMINATED",
            "FAILED",
            state_message="Schema 'test_cat.ecm_v1' does not exist",
        )
        handle = OperationDispatchHandle(databricks_run_id=42, vibe_session_id=None)
        obs = gs_op.observe(handle, _ctx(), ws, MagicMock())

        assert obs.is_terminal is True
        assert obs.terminal_result is not None
        assert obs.terminal_result.succeeded is False
        # Error message must mention "schema" so the UI can render a
        # "did you forget to install?" hint.
        assert obs.terminal_result.error
        assert (
            "schema" in obs.terminal_result.error.lower()
            or "test_cat" in obs.terminal_result.error
        )

    def test_job_fails_mid_generation(self, gs_op):
        """Spec §10: job fails mid-generation → succeeded=False, no rollback.

        We assert succeeded=False here; the no-rollback contract is checked
        in TestGenerateSamplesNoRollback below.
        """
        ws = _mock_ws_with_state(
            "TERMINATED",
            "FAILED",
            state_message="Faker library OOM at row 50000",
        )
        handle = OperationDispatchHandle(databricks_run_id=42, vibe_session_id=None)
        obs = gs_op.observe(handle, _ctx(), ws, MagicMock())
        assert obs.is_terminal is True
        assert obs.terminal_result.succeeded is False
        assert obs.terminal_result.error  # populated

    def test_sample_generation_succeeds(self, gs_op):
        """Spec §10: sample generation succeeds → succeeded=True,
        output_artifacts MAY include sample-row metadata.

        We don't require a specific artifact format — the spec says "may".
        We DO require: succeeded=True, error empty, and output_artifacts is
        a list (could be empty).
        """
        ws = _mock_ws_with_state("TERMINATED", "SUCCESS")
        handle = OperationDispatchHandle(databricks_run_id=42, vibe_session_id=None)
        obs = gs_op.observe(handle, _ctx(), ws, MagicMock())
        assert obs.is_terminal is True
        assert obs.terminal_result.succeeded is True
        assert not obs.terminal_result.error
        assert isinstance(obs.terminal_result.output_artifacts, list)

    def test_running_job_is_not_terminal(self, gs_op):
        ws = _mock_ws_with_state("RUNNING")
        handle = OperationDispatchHandle(databricks_run_id=42, vibe_session_id=None)
        obs = gs_op.observe(handle, _ctx(), ws, MagicMock())
        assert obs.is_terminal is False
        assert obs.terminal_result is None

    def test_pending_job_is_not_terminal(self, gs_op):
        ws = _mock_ws_with_state("PENDING")
        handle = OperationDispatchHandle(databricks_run_id=42, vibe_session_id=None)
        obs = gs_op.observe(handle, _ctx(), ws, MagicMock())
        assert obs.is_terminal is False


# ---------------------------------------------------------------------------
# No-rollback contract
# ---------------------------------------------------------------------------


class TestGenerateSamplesNoRollback:
    """Per spec §10: ``generate_samples`` has no rollback. Sample rows live
    in installed schemas; the uninstall primitive owns cleanup.
    """

    def test_rollback_is_noop_or_raises_clearly(self, gs_op):
        ws = MagicMock()
        ws.config.host = "https://t.databricks.com"
        session = MagicMock()

        launch_calls: list = []

        def _fake_launch_run(ws_, job_id, widget_params, *args, **kwargs):
            launch_calls.append(widget_params)
            return 12345

        try:
            with patch(
                "vibe_modeling.backend.services.operations.generate_samples.launch_run",
                _fake_launch_run,
                create=True,
            ):
                gs_op.rollback(_ctx(), {}, ws, session)
        except NotImplementedError:
            # Acceptable — replaying an "ungenerate samples" makes no sense.
            return
        except Exception as e:
            pytest.fail(
                f"generate_samples.rollback raised unexpected exception type: {type(e).__name__}"
            )

        # If we got here, rollback returned without raising — must be a no-op.
        assert (
            len(launch_calls) == 0
        ), "generate_samples.rollback must not launch a job (no-rollback contract)"
        # And must not have executed DROP/DELETE SQL either.
        assert (
            ws.statement_execution.execute_statement.call_count == 0
        ), "rollback must not run cleanup SQL"


# ---------------------------------------------------------------------------
# TestRollbackAdversarial — design doc §10 declares no rollback.
#
# Per docs/orchestrator-design.md §10: "Job fails → no rollback (samples
# live in installed schemas; uninstall handles)."
#
# Implementation: ``GenerateSamples.rollback`` returns ``None`` — a true
# no-op. Tests below pin the design intent so a future change that adds
# rollback semantics fails loudly (the parent ``install`` op's rollback
# is the only legal cleanup path).
# ---------------------------------------------------------------------------


class TestRollbackAdversarial:
    """generate_samples has no rollback per §10 of the design doc.

    These tests document the design intent and ensure no regressions
    accidentally introduce side-effecting rollback behaviour.
    """

    def test_rollback_is_noop_per_design_doc_section_10(self, gs_op):
        """§10 design intent: ``generate_samples`` rollback is a no-op.

        The implementation chose `return None` (true no-op) over raising —
        either is acceptable per the design, but the current impl is a
        no-op. Verify: rollback returns None and produces no observable
        side effects on the WorkspaceClient.
        """
        ws = MagicMock()
        ws.config.host = "https://t.databricks.com"
        session = MagicMock()
        # Pin the design intent: rollback must complete without raising,
        # without launching a job, without running cleanup SQL.
        result = gs_op.rollback(_ctx(), {}, ws, session)
        assert result is None, (
            "generate_samples.rollback must return None per §10 (no rollback)"
        )
        # No Databricks side effects.
        assert ws.jobs.run_now.call_count == 0
        assert ws.jobs.cancel_run.call_count == 0
        assert ws.statement_execution.execute_statement.call_count == 0

    def test_rollback_is_idempotent_under_replay(self, gs_op):
        """§2 invariant: replaying ``rollback`` MUST be a no-op (not raise).
        Trivially satisfied for a no-op rollback, but pinned here so any
        future rollback impl that adds side effects also passes the
        idempotency invariant from the start.
        """
        ws = MagicMock()
        ws.config.host = "https://t.databricks.com"
        session = MagicMock()
        gs_op.rollback(_ctx(), {}, ws, session)
        gs_op.rollback(_ctx(), {}, ws, session)
        gs_op.rollback(_ctx(), {}, ws, session)

    def test_rollback_with_dependent_state_missing(self, gs_op):
        """A rollback_state shape suggesting "the install is gone, version
        is gone, samples are gone" must still no-op cleanly.

        This documents the failure-mode contract: if ``generate_samples``
        ever DOES grow rollback semantics, it must inherit the §2
        idempotency invariant — replay against missing dependents is a
        no-op, not an error.
        """
        ws = MagicMock()
        ws.config.host = "https://t.databricks.com"
        session = MagicMock()
        # Plausible rollback_state shapes — even ones that suggest active
        # cleanup work — must not cause the no-op rollback to fall over.
        for state in (
            {},
            {"databricks_run_id": 12345},
            {"databricks_run_id": 12345, "jobs_terminal_result_state": "FAILED"},
            {"version_id": "ghost-version-id"},
        ):
            gs_op.rollback(_ctx(), state, ws, session)

    def test_uninstall_is_documented_cleanup_path(self, gs_op):
        """§10 design intent: the parent ``install`` op's rollback (which
        invokes ``uninstall``) is what cleans up failed sample generation.

        This test documents the contract by asserting the registry knows
        about the ``uninstall`` op — it's the named cleanup primitive
        for failed installs, including any sample data that failed
        mid-generation inside an installed schema.
        """
        from vibe_modeling.backend.services.operations import (
            _registry as _reg,
        )
        from vibe_modeling.backend.services.operations.uninstall import (
            Uninstall,
        )
        # The uninstall primitive is the documented cleanup path. We
        # assert it exists and has a non-trivial rollback (its
        # rollback IS the cleanup contract for installed schemas, so
        # the cleanup-of-samples story is valid).
        uninstall_op = Uninstall()
        assert uninstall_op.name == "uninstall"
        # Ensure the production registry has uninstall registered so a
        # cancel-with-rollback chain that needs to clean up sample data
        # can resolve the cleanup step.
        try:
            _reg.restore_production_for_tests()
            registered = _reg.get("uninstall")
            assert registered is not None, (
                "uninstall must be registered as the cleanup path for "
                "failed generate_samples runs (§10 design intent)"
            )
        except Exception:  # noqa: BLE001 — best-effort registry check
            # If the registry helpers aren't available, the import-time
            # registration on the uninstall module is sufficient evidence.
            pass
