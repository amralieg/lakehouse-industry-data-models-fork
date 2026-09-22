"""Tests for run-instructions form composition (fix K) and form durability
(fix L/M).

Fix K — backend: ``_generate_ecm_params`` in the unified DAG factory must
forward ``vibe_instructions`` ONLY through the ``model_vibes`` widget;
``business_description`` carries the durable business context (override or
``business.description``) only.  Duplicating per-run instructions into
``business_description`` wastes prompt budget by handing the agent the same
text twice in different widgets.

Fix L — documented as a UI-only change (``descriptionDirty`` flag in
``businesses.new.tsx``); no backend surface to test.

Fix M — documented as a combination of query-option change and a
``businessContextDirty`` flag in ``runs.new.tsx``; no backend surface to test.
"""

from __future__ import annotations

import pytest

from vibe_modeling.backend.db_models import Business
from vibe_modeling.backend.models import RunIn


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _make_business(*, description: str = "Retail Co operates 500 stores.") -> Business:
    return Business(
        id="biz-1",
        name="Retail Co",
        description=description,
        industry_alignment="Retail",
    )


def _make_req(**kwargs) -> RunIn:
    defaults = {
        "intent": "new-base-model",
        "catalog": "deploy_cat",
        "cataloging_style": "One Catalog",
        "business_context_text": "",
        "business_context_path": "",
        "vibe_instructions": "",
        "model_size": "large model",
        "generate_samples": False,
    }
    defaults.update(kwargs)
    return RunIn(**defaults)


def _call_generate_ecm_params(req: RunIn, business: Business) -> dict:
    from vibe_modeling.backend.services.orchestrator.dag_factories._unified import (
        _generate_ecm_params,
    )

    return _generate_ecm_params(
        req=req,
        business=business,
        business_context=None,
        cataloging_style="One Catalog",
        deployment_catalog="deploy_cat",
        ecm_prefix="ecm_",
    )


# ---------------------------------------------------------------------------
# Fix K — business_description widget composition (no duplication)
# ---------------------------------------------------------------------------


class TestGenerateEcmParamsBusinessDescription:
    """``_generate_ecm_params`` must keep per-run instructions out of
    ``business_description``; they belong solely in ``model_vibes``.
    """

    def test_vibe_instructions_not_appended_to_context_text(self):
        """Both context_text and vibe_instructions → business_description is
        ONLY the context text; instructions ride exclusively in model_vibes.
        """
        biz = _make_business()
        req = _make_req(
            business_context_text="Custom context from user.",
            vibe_instructions="Only include Sales domain.",
        )
        params = _call_generate_ecm_params(req, biz)
        assert params["business_description"] == "Custom context from user."
        assert "Run-specific instructions" not in params["business_description"]
        assert params["model_vibes"] == "Only include Sales domain."

    def test_vibe_instructions_not_appended_to_business_description_fallback(self):
        """No context_text but vibe_instructions → business_description is the
        durable business.description; vibe_instructions are NOT mixed in.
        """
        biz = _make_business(description="Retail Co operates 500 stores.")
        req = _make_req(
            business_context_text="",
            vibe_instructions="Focus on Finance domain only.",
        )
        params = _call_generate_ecm_params(req, biz)
        assert params["business_description"] == "Retail Co operates 500 stores."
        assert "Run-specific instructions" not in params["business_description"]
        assert params["model_vibes"] == "Focus on Finance domain only."

    def test_no_vibe_instructions_uses_context_text_only(self):
        """No vibe_instructions → business_description is just context_text."""
        biz = _make_business()
        req = _make_req(
            business_context_text="Inline context without instructions.",
            vibe_instructions="",
        )
        params = _call_generate_ecm_params(req, biz)
        assert params["business_description"] == "Inline context without instructions."
        assert "model_vibes" not in params

    def test_no_vibe_no_context_text_falls_back_to_business_description(self):
        """Neither vibe_instructions nor context_text → business_description
        widget is set from business.description.

        Contract: the DAG factory injects ``business_description`` whenever a
        durable base context is available (override or business.description),
        and only omits it when the business itself has no description either.
        """
        biz = _make_business(description="Default biz description.")
        req = _make_req(business_context_text="", vibe_instructions="")
        params = _call_generate_ecm_params(req, biz)
        assert params["business_description"] == "Default biz description."

    def test_no_vibe_no_context_no_business_description_omits_key(self):
        """Empty business.description AND empty inputs → key absent so the
        downstream dispatch fallback chain can run.
        """
        biz = _make_business(description="")
        req = _make_req(business_context_text="", vibe_instructions="")
        params = _call_generate_ecm_params(req, biz)
        assert "business_description" not in params

    def test_only_vibe_instructions_no_business_description_widget(self):
        """Vibe instructions with empty business.description → business_description
        widget is omitted (instructions go via model_vibes only).
        """
        biz = _make_business(description="")
        req = _make_req(
            business_context_text="",
            vibe_instructions="Constrain to HR only.",
        )
        params = _call_generate_ecm_params(req, biz)
        assert "business_description" not in params
        assert params["model_vibes"] == "Constrain to HR only."

    def test_model_vibes_widget_set_when_vibe_instructions_present(self):
        """``model_vibes`` is the sole widget carrying per-run instructions."""
        biz = _make_business()
        req = _make_req(
            business_context_text="Context.",
            vibe_instructions="My constraint.",
        )
        params = _call_generate_ecm_params(req, biz)
        assert params.get("model_vibes") == "My constraint."
        # Must NOT also be embedded in business_description.
        assert "My constraint." not in params["business_description"]

    def test_context_file_path_still_forwarded(self):
        """``context_file`` widget is forwarded even when vibe_instructions are set."""
        biz = _make_business()
        req = _make_req(
            business_context_text="",
            business_context_path="/Volumes/cat/schema/ctx.json",
            vibe_instructions="Constraint.",
        )
        params = _call_generate_ecm_params(req, biz)
        assert params["context_file"] == "/Volumes/cat/schema/ctx.json"
