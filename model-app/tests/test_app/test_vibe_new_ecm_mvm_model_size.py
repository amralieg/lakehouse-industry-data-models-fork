"""Lock the ``vibe-new-ecm-mvm`` Phase 1 ``model_size`` invariant.

The intent contract:
  - Phase 1 (``vibe_iterate``) MUST run as ECM (``model_size="large model"``)
  - Phase 2 (``shrink_to_mvm``) MUST run as MVM (hardcoded inside
    ``_shrink_to_mvm_params``)

The user has no choice for either phase. Before the fix, the DAG factory
forwarded ``req.model_size`` to the agent's ``vibe_iterate`` widget. The
form's Model Size combobox defaults to "Small Model (MVM)" for vibe
intents, so the agent wrote the new version under MVM scope and Phase 2
shrink couldn't find the expected ECM v=N.

These tests exercise the factory directly and lock the invariant: the
``vibe_iterate`` step's ``params['model_size']`` is always
``"large model"`` regardless of what the request carries.
"""

from __future__ import annotations

from typing import Any

import pytest

from vibe_modeling.backend.db_models import Business
from vibe_modeling.backend.models import Intent, RunIn
from vibe_modeling.backend.services.orchestrator.dag_factories import (
    dag_for_vibe_new_ecm_mvm,
)


def _make_business() -> Business:
    return Business(
        id="biz-test-1",
        name="Acme Corp",
        description="Adversarial test business",
        industry_alignment="Retail",
    )


def _make_req(model_size: str | None, **overrides: Any) -> RunIn:
    """Build a ``RunIn`` that the factory will accept.

    ``RunIn.model_size`` defaults to ``"small model"``; pass an explicit
    value to exercise both branches. ``vibe_instructions`` must be
    non-empty per the validator, but the factory doesn't enforce that —
    we leave it set so future tightening doesn't break this fixture.
    """
    body: dict[str, Any] = {
        "intent": Intent.VIBE_NEW_ECM_MVM,
        "vibe_instructions": "Re-vibe ECM, then shrink to MVM.",
        "catalog": "test_catalog",
        "cataloging_style": "One Catalog",
    }
    if model_size is not None:
        body["model_size"] = model_size
    body.update(overrides)
    return RunIn(**body)


@pytest.mark.parametrize(
    "model_size",
    [
        "small model",  # the form's default for vibe intents — the bug
        "large model",  # the correct value, must still be locked
        "tiny model",   # garbage — must not leak through
        "",             # empty string — was a falsy short-circuit before the fix
    ],
)
def test_phase1_model_size_locked_to_large_model_one_catalog(model_size: str) -> None:
    """Phase 1 (``vibe_iterate``) ``model_size`` must always be 'large model'.

    Asserted on the One-Catalog DAG shape (2 ops).
    """
    req = _make_req(model_size, cataloging_style="One Catalog")
    business = _make_business()

    dag = dag_for_vibe_new_ecm_mvm(req=req, business=business)

    assert dag.intent == "vibe-new-ecm-mvm"
    # 2-op shape: vibe_iterate → shrink_to_mvm
    assert len(dag.steps) == 2
    assert dag.steps[0].name == "vibe_iterate"
    # The lock: regardless of what the request carries, Phase 1 is ECM.
    assert dag.steps[0].params["model_size"] == "large model", (
        f"vibe_iterate.model_size leaked from req.model_size={model_size!r}"
    )


@pytest.mark.parametrize(
    "model_size",
    ["small model", "large model", "tiny model", ""],
)
@pytest.mark.parametrize(
    "cataloging_style",
    ["Catalog per Division", "Catalog per Domain"],
)
def test_phase1_model_size_locked_to_large_model_multi_catalog(
    model_size: str, cataloging_style: str,
) -> None:
    """Phase 1 lock holds for the multi-catalog DAG shape too."""
    req = _make_req(model_size, cataloging_style=cataloging_style)
    business = _make_business()

    dag = dag_for_vibe_new_ecm_mvm(req=req, business=business)

    # 2-op shape: vibe_iterate → shrink_to_mvm (agent inline-installs).
    assert len(dag.steps) == 2
    assert dag.steps[0].name == "vibe_iterate"
    assert dag.steps[0].params["model_size"] == "large model"


def test_phase1_does_not_forward_arbitrary_model_size_to_agent() -> None:
    """Belt-and-braces: the params dict carries the literal 'large model'.

    Guards against a future refactor that re-introduces ``req.model_size``
    forwarding via a new code path (e.g. ``out.update(req.dict())``).
    """
    req = _make_req("small model")
    business = _make_business()

    dag = dag_for_vibe_new_ecm_mvm(req=req, business=business)

    params = dag.steps[0].params
    # The literal value the agent expects for ECM scope.
    assert params.get("model_size") == "large model"
    # And it must be the ONLY ``model_size`` key — no shadow keys leaking
    # in from a hypothetical future bug.
    assert sum(1 for k in params if k == "model_size") == 1
