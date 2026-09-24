"""SNAPSHOT / SHRINK / ENLARGE were removed from the Intent enum
(v0.4.2 — no DAG factory, no UI surface). They must now be rejected at
the Pydantic boundary with a 422, BEFORE any handler runs. This locks
the contract so a future maintainer can't accidentally re-add them as
stub enum members without also wiring the DAG + UI.
"""

import pytest


REMOVED_INTENTS = ["snapshot", "shrink", "enlarge"]


class TestPostRunsRejectsRemovedIntents:
    @pytest.mark.parametrize("intent", REMOVED_INTENTS)
    def test_post_runs_returns_422(
        self, client_with_agent, seed_business, intent
    ):
        resp = client_with_agent.post(
            f"/api/businesses/{seed_business}/runs",
            json={"intent": intent, "catalog": "test_catalog"},
        )
        assert resp.status_code == 422, (
            f"intent {intent!r} must be rejected at the Pydantic boundary "
            f"with 422; got {resp.status_code}: {resp.text}"
        )
        body = resp.json()
        # FastAPI/Pydantic validation error shape: {"detail": [{"loc": [...],
        # "msg": ..., "type": "enum"}, ...]}
        detail = body.get("detail", [])
        assert isinstance(detail, list) and detail, (
            f"422 detail must be a non-empty list; got {body!r}"
        )
        assert any("intent" in err.get("loc", []) for err in detail), (
            f"422 must cite the intent field in loc; got {detail!r}"
        )


class TestValidateRejectsRemovedIntents:
    @pytest.mark.parametrize("intent", REMOVED_INTENTS)
    def test_validate_returns_422(
        self, client_with_agent, seed_business, intent
    ):
        resp = client_with_agent.post(
            f"/api/businesses/{seed_business}/runs/validate",
            json={"intent": intent, "catalog": "test_catalog"},
        )
        assert resp.status_code == 422, (
            f"validate({intent!r}) must be rejected at Pydantic boundary "
            f"with 422; got {resp.status_code}: {resp.text}"
        )
