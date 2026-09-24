"""Drift lock: every Group B deployment primitive's widget map carries the
universal agent widgets — same set for install/uninstall/generate_samples.

Per the agent's integration guide (``modelling_agent/docs/integration-guide.md``
§"Widget values to pass as base_parameters"), ``data_model_scopes`` is a
UNIVERSAL widget — every operation reads it to decide whether it's acting
on the Expanded Coverage Model or the Minimum Viable Model. It is NOT
install-specific.

This was violated silently: ``uninstall.py``'s ``_build_uninstall_widgets``
omitted ``data_model_scopes`` entirely while ``install.py`` and
``generate_samples.py`` both set it. Live consequence: an ECM uninstall
dispatched without the widget, the agent's Model Scope selector fell back
to its own default (MVM), and the uninstall dropped the wrong business's
schemas (all 15 ``mvm_*`` schemas instead of the intended ``ecm_*`` ones).

Rather than asserting each op's widget map by hand (which is exactly how
the omission slipped through three separate hand-written tests), this
module enumerates the CANONICAL required-widget set once and checks every
Group B primitive's builder against it — so a future primitive that drops
a universal widget fails CI immediately instead of waiting for a live
walkthrough to notice.
"""

from __future__ import annotations

import os
import sys

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)
# Make the shared phase-2 helpers importable as flat module names.
sys.path.insert(0, os.path.dirname(__file__))

from sqlmodel import Session

from vibe_modeling.backend.services.operations.generate_samples import (
    GenerateSamplesParams,
    _build_generate_samples_widgets,
)
from vibe_modeling.backend.services.operations.install import (
    InstallParams,
    _build_install_widgets,
)
from vibe_modeling.backend.services.operations.uninstall import (
    UninstallParams,
    _build_uninstall_widgets,
)
from vibe_modeling.backend.services.operations import OperationDispatchHandle

from _phase2_helpers import (
    GENERATE_ECM_VALID_PARAMS,
    SHRINK_TO_MVM_VALID_PARAMS,
    make_ctx,
    make_engine,
    make_ws,
    parent_version,
    seed_business_and_agent,
    seed_run_with_op,
)
from _phase2_stubs import load_primitive

# The subset of widgets every Group B (deployment) primitive MUST set,
# per the integration guide's universal widget table. Primitive-specific
# widgets (e.g. install's ``context_file``, generate_samples' row-count
# override of ``generate_samples``) are intentionally NOT enumerated here
# — this is the floor every op shares, not each op's full contract.
_UNIVERSAL_REQUIRED_WIDGETS = frozenset(
    {
        "operation",
        "business_name",
        "deployment_catalog",
        "data_model_scopes",
        "model_version",
        "cataloging_style",
        "vibe_session_id",
    }
)

_SESSION_ID_BIGINT = "1234567890"


def _install_widgets(scope: str = "ecm") -> dict[str, str]:
    params = InstallParams(
        scope=scope,
        business_name="terra_nova",
        deployment_catalog="vibe_modeling_test",
        schema_prefix=f"{scope}_",
        model_version=1,
    )
    return _build_install_widgets(params, _SESSION_ID_BIGINT)


def _uninstall_widgets(scope: str = "ecm") -> dict[str, str]:
    params = UninstallParams(
        business_name="terra_nova",
        deployment_catalog="vibe_modeling_test",
        schema_prefix=f"{scope}_",
        scope=scope,
        model_version=1,
    )
    return _build_uninstall_widgets(params, _SESSION_ID_BIGINT)


def _generate_samples_widgets(scope: str = "ecm") -> dict[str, str]:
    params = GenerateSamplesParams(
        business_name="terra_nova",
        deployment_catalog="vibe_modeling_test",
        schema_prefix=f"{scope}_",
        scope=scope,
        model_version=1,
    )
    return _build_generate_samples_widgets(params, _SESSION_ID_BIGINT)


_GROUP_B_BUILDERS = {
    "install": _install_widgets,
    "uninstall": _uninstall_widgets,
    "generate_samples": _generate_samples_widgets,
}


class TestUniversalWidgetContract:
    """Every Group B primitive's widget map carries the full universal set."""

    def test_every_group_b_op_carries_the_universal_widgets(self):
        missing_by_op: dict[str, frozenset] = {}
        for op_name, builder in _GROUP_B_BUILDERS.items():
            widgets = builder()
            missing = _UNIVERSAL_REQUIRED_WIDGETS - widgets.keys()
            if missing:
                missing_by_op[op_name] = missing
        assert not missing_by_op, (
            f"Group B primitives missing universal widgets: {missing_by_op!r} "
            "— every deployment op must set the full universal widget set "
            "(see integration-guide.md's base_parameters table)."
        )

    def test_data_model_scopes_reflects_the_requested_scope_for_every_op(self):
        """Not just present — correct. An ECM request must carry the ECM
        label, not silently fall back to the agent's own MVM default."""
        for op_name, builder in _GROUP_B_BUILDERS.items():
            ecm_widgets = builder(scope="ecm")
            mvm_widgets = builder(scope="mvm")
            assert ecm_widgets["data_model_scopes"] == "Expanded Coverage Model - ECM", (
                f"{op_name}: ecm scope did not produce the ECM widget label"
            )
            assert mvm_widgets["data_model_scopes"] == "Minimum Viable Model - MVM", (
                f"{op_name}: mvm scope did not produce the MVM widget label"
            )

    def test_uninstall_ecm_dispatch_carries_ecm_scope_verbatim(self):
        """Regression for the live incident: an ECM uninstall (schema_prefix
        'ecm_') must dispatch with the ECM data_model_scopes label, not an
        omitted/defaulted one that lets the agent fall back to MVM and drop
        the wrong business's schemas."""
        widgets = _uninstall_widgets(scope="ecm")
        assert widgets["schema_prefix"] == "ecm_"
        assert widgets["data_model_scopes"] == "Expanded Coverage Model - ECM"
        assert widgets["operation"] == "uninstall model version"


# --------------------------------------------------------------------------
# E-03: dispatched_widgets audit trail for MODEL-producing ops.
#
# The write-once ``OperationDispatchHandle.dispatched_widgets`` powers the
# run-detail "What you submitted → Dispatched widgets" block. Only the
# Group B lifecycle ops (install/uninstall/generate_samples) used to set
# it, so model runs (generate_ecm / shrink_to_mvm / enlarge_to_ecm /
# vibe_iterate) showed an empty block. This locks the fix: every
# model-producing primitive must return a non-empty ``dispatched_widgets``
# that MATCHES the widget map actually handed to ``ws.jobs.run_now`` — the
# same notebook_params the agent receives.
# --------------------------------------------------------------------------


def _run_now_notebook_params(ws) -> dict:
    """Pull the notebook_params ``launch_run`` handed to ``ws.jobs.run_now``."""
    assert ws.jobs.run_now.called, "dispatch must call ws.jobs.run_now"
    call = ws.jobs.run_now.call_args
    return call.kwargs.get("notebook_params") or (
        call.args[1] if len(call.args) > 1 else {}
    )


def _dispatch_generation(op_name: str, params: dict, *, with_parent_scope=None):
    """Dispatch a generation-group primitive and return
    ``(handle, notebook_params)``."""
    op, _ = load_primitive(op_name)
    ws = make_ws(run_now_run_id=880_001)
    engine = make_engine()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = None
        if with_parent_scope is not None:
            parent_id = parent_version(session, biz_id, scope=with_parent_scope)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name=op_name,
            parent_version_id=parent_id,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id, params=params,
        )
        handle = op.dispatch(ctx, ws, session)
    return handle, _run_now_notebook_params(ws)


class TestDispatchedWidgetsForModelOps:
    """Every model-producing primitive records its dispatched widget map."""

    def test_generate_ecm_records_dispatched_widgets(self):
        handle, notebook_params = _dispatch_generation(
            "generate_ecm", GENERATE_ECM_VALID_PARAMS,
        )
        assert isinstance(handle, OperationDispatchHandle)
        assert handle.dispatched_widgets, (
            "generate_ecm must record a non-empty dispatched_widgets so the "
            "run-detail 'Dispatched widgets' block populates"
        )
        assert handle.dispatched_widgets == notebook_params, (
            "dispatched_widgets must be the exact map handed to run_now"
        )
        # Sanity: it's the model op's real widget set, not a stub.
        assert handle.dispatched_widgets.get("operation") == "new base model"

    def test_shrink_to_mvm_records_dispatched_widgets(self):
        handle, notebook_params = _dispatch_generation(
            "shrink_to_mvm", SHRINK_TO_MVM_VALID_PARAMS,
            with_parent_scope="ecm",
        )
        assert handle.dispatched_widgets, (
            "shrink_to_mvm must record a non-empty dispatched_widgets"
        )
        assert handle.dispatched_widgets == notebook_params
        assert handle.dispatched_widgets.get("operation") == "shrink ecm"

    def test_vibe_iterate_records_dispatched_widgets(self):
        # vibe_iterate self-registers on import rather than via the
        # phase-2 stub loader, so import the primitive class directly.
        from vibe_modeling.backend.services.operations.vibe_iterate import (
            VibeIterate,
        )

        op = VibeIterate()
        ws = make_ws(run_now_run_id=880_002)
        engine = make_engine()
        with Session(engine) as session:
            biz_id, _ = seed_business_and_agent(session)
            parent_id = parent_version(session, biz_id, scope="ecm")
            run_id, op_id = seed_run_with_op(
                session, business_id=biz_id, operation_name="vibe_iterate",
                parent_version_id=parent_id, intent="vibe-iterate",
            )
            ctx = make_ctx(
                run_id=run_id, operation_id=op_id, business_id=biz_id,
                parent_version_id=parent_id,
                params={
                    "vibe_instructions": "denormalise the customer table",
                    "deployment_catalog": "deploy_cat",
                },
                inherited_params={"cataloging_style": "One Catalog"},
            )
            handle = op.dispatch(ctx, ws, session)
        notebook_params = _run_now_notebook_params(ws)
        assert handle.dispatched_widgets, (
            "vibe_iterate must record a non-empty dispatched_widgets"
        )
        assert handle.dispatched_widgets == notebook_params
        assert handle.dispatched_widgets.get("operation") == (
            "vibe modeling of version"
        )
