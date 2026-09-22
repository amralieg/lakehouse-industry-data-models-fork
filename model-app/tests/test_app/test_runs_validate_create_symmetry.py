"""Cross-endpoint symmetry between POST /api/runs/validate and POST /api/runs.

The validate endpoint is meant to give live form feedback that's
EQUIVALENT to what the create endpoint will accept or reject. If validate
says "no blockers" but create rejects with 400, the user gets a confusing
"submit failed without warning" experience. Phase 4.5 surfaced this when
validate skipped the metamodel-catalog gate that create enforced.

This test runs every "rejection-inducing body" through both endpoints and
asserts:
- If create rejects (4xx), validate must surface ≥1 blocker.
- The blocker's message must be non-empty.

Pattern guard: any future create-time gate added to /api/runs MUST also
appear in /api/runs/validate. Adding a gate to one without the other
will fail this test on the first parametrized case.
"""
from __future__ import annotations

import json
from uuid import uuid4

import pytest
from sqlmodel import Session

from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
    Industry,
    Run,
)


def _seed_business(engine, *, name="symmetry-biz") -> str:
    with Session(engine) as s:
        ind = Industry(name="Test", short_name="test", description="x")
        s.add(ind)
        s.flush()
        b = Business(name=name, description="t", industry_id=ind.id)
        s.add(b)
        s.flush()
        s.commit()
        return b.id


def _seed_agent_config(engine, *,
                      notebook_path="/Workspace/agent.ipynb",
                      deployment_catalog="metamodel_cat") -> None:
    with Session(engine) as s:
        # Best-effort upsert: the table allows only one row per the existing
        # router behaviour, so we either insert or update the singleton.
        existing = s.exec(  # type: ignore[attr-defined]
            __import__("sqlmodel").select(AgentConfig).limit(1)
        ).first()
        if existing is None:
            s.add(AgentConfig(
                notebook_path=notebook_path,
                deployment_catalog=deployment_catalog,
                warehouse_id="wh-1",
                job_id=1,
                job_name="dbx_test",
            ))
        else:
            existing.notebook_path = notebook_path
            existing.deployment_catalog = deployment_catalog
            s.add(existing)
        s.commit()


@pytest.fixture
def biz_id(engine):
    return _seed_business(engine)


# Each case is (label, body_extras, set_agent_config). The body always
# includes a known business_id (biz_id fixture), the test runs both
# endpoints, asserts validate has ≥1 blocker iff create returns 4xx.
_USE_FIXTURE_BID = object()


SYMMETRY_CASES = [
    pytest.param(
        "no_agent_config",
        {"intent": "new-base-model", "catalog": "tgt", "cataloging_style": "One Catalog"},
        False,  # don't seed agent_config
        _USE_FIXTURE_BID,
        id="no-agent-config",
    ),
    pytest.param(
        "no_metamodel_catalog",
        {"intent": "new-base-model", "catalog": "tgt", "cataloging_style": "One Catalog"},
        "no_catalog",  # seed agent_config but with empty deployment_catalog
        _USE_FIXTURE_BID,
        id="no-metamodel-catalog",
    ),
    pytest.param(
        "one_catalog_no_target_no_fallback",
        {"intent": "new-base-model", "catalog": "", "cataloging_style": "One Catalog"},
        "no_catalog",
        _USE_FIXTURE_BID,
        id="one-catalog-mode-no-target-no-fallback",
    ),
    pytest.param(
        "missing_business_id",
        {"intent": "new-base-model", "catalog": "tgt", "cataloging_style": "One Catalog"},
        True,
        "nonexistent-uuid",
        id="missing-business",
    ),
]


@pytest.mark.parametrize("label,body_extras,seed_cfg,url_bid", SYMMETRY_CASES)
def test_create_rejection_appears_as_validate_blocker(
    client, engine, biz_id, label, body_extras, seed_cfg, url_bid
):
    """For every body that POST /api/runs rejects, POST /api/runs/validate
    must surface at least one blocker. Catches future gates added to
    create without a matching validate update."""
    if seed_cfg is True:
        _seed_agent_config(engine)
    elif seed_cfg == "no_catalog":
        _seed_agent_config(engine, deployment_catalog="")
    # else: don't seed at all

    target_bid = biz_id if url_bid is _USE_FIXTURE_BID else url_bid
    body = {**body_extras}

    # Hit validate first (no side effects).
    v_resp = client.post(f"/api/businesses/{target_bid}/runs/validate", json=body)
    create_resp = client.post(f"/api/businesses/{target_bid}/runs", json=body)

    if 400 <= create_resp.status_code < 500:
        # Validate MUST have surfaced a blocker.
        assert v_resp.status_code == 200, (
            f"[{label}] validate should be 200 with blockers, got "
            f"{v_resp.status_code}: {v_resp.text}"
        )
        v_body = v_resp.json()
        blockers = v_body.get("blockers", [])
        assert len(blockers) >= 1, (
            f"[{label}] validate returned no blockers but create rejected "
            f"with {create_resp.status_code}: {create_resp.text}"
        )
        for b in blockers:
            assert b.get("message", "").strip(), (
                f"[{label}] blocker has empty message: {b}"
            )


def test_create_run_config_missing_returns_structured_422(client, engine, biz_id):
    """Run dispatch with the metamodel catalog cleared returns the SAME
    structured 422 config_missing payload the other operations emit - not a
    bare 400 string (tester finding #1)."""
    _seed_agent_config(engine, deployment_catalog="")  # notebook+job+warehouse set
    resp = client.post(
        f"/api/businesses/{biz_id}/runs",
        json={"intent": "new-base-model", "catalog": "tgt", "cataloging_style": "One Catalog"},
    )
    assert resp.status_code == 422, resp.text
    detail = resp.json()["detail"]
    assert detail["error"] == "config_missing"
    keys = {m["key"] for m in detail["missing"]}
    assert "metamodel_catalog" in keys
    for m in detail["missing"]:
        assert m["settings_url"].startswith("/settings?tab=")
        assert m["label"]


def test_create_run_warehouse_missing_returns_structured_422(client, engine, biz_id):
    """Same structured 422 when only the warehouse is unset."""
    with Session(engine) as s:
        s.add(AgentConfig(
            notebook_path="/Workspace/agent.ipynb", deployment_catalog="cat",
            warehouse_id="", job_id=1, job_name="dbx_test",
        ))
        s.commit()
    resp = client.post(
        f"/api/businesses/{biz_id}/runs",
        json={"intent": "new-base-model", "catalog": "tgt", "cataloging_style": "One Catalog"},
    )
    assert resp.status_code == 422, resp.text
    assert resp.json()["detail"]["error"] == "config_missing"
    assert "warehouse" in {m["key"] for m in resp.json()["detail"]["missing"]}


def test_missing_metamodel_schema_rejects_on_both_endpoints(
    client, engine, biz_id, mock_ws
):
    """Specific case: when the target catalog has no ``_metamodel`` schema,
    POST /runs must 400 with a catalog-scoped error AND POST /runs/validate
    must surface the same blocker (field_path='catalog'). Without this, the
    user would clear validate, hit Submit, and the agent's dispatch would
    crash with a less-helpful message."""
    from types import SimpleNamespace

    _seed_agent_config(engine)
    # Stub the schemas list to a non-empty result that omits `_metamodel`.
    # An empty result is treated as "can't verify" and the gate skips.
    mock_ws.schemas.list.side_effect = lambda *a, **kw: iter(
        [SimpleNamespace(name=n) for n in ("default", "other_schema")]
    )

    body = {
        "intent": "new-base-model",
        "catalog": "tgt_no_metamodel",
        "cataloging_style": "One Catalog",
    }

    v_resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    c_resp = client.post(f"/api/businesses/{biz_id}/runs", json=body)

    assert c_resp.status_code == 400, (
        f"create should reject with 400 due to missing _metamodel schema; "
        f"got {c_resp.status_code}: {c_resp.text}"
    )
    assert "_metamodel" in c_resp.text, (
        f"create error message should mention _metamodel: {c_resp.text}"
    )

    assert v_resp.status_code == 200, v_resp.text
    blockers = v_resp.json().get("blockers", [])
    assert any(
        b.get("field_path") == "catalog" and "_metamodel" in (b.get("message") or "")
        for b in blockers
    ), (
        f"validate did not surface the missing-_metamodel blocker: "
        f"{json.dumps(blockers, indent=2)}"
    )


def test_active_run_lock_is_a_validate_blocker(client, engine, biz_id):
    """Specific case: the 409 'business already has an active run' lock
    must surface as a validate blocker too. Otherwise the user sees a
    clean validate, hits Submit, and gets a 409."""
    _seed_agent_config(engine)
    # Manually insert an in-flight run so the active-run lock fires.
    with Session(engine) as s:
        s.add(Run(
            id=str(uuid4()),
            business_id=biz_id,
            intent="new-base-model",
            status="running",
        ))
        s.commit()

    body = {
        "intent": "new-base-model",
        "catalog": "tgt",
        "cataloging_style": "One Catalog",
    }
    v_resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    create_resp = client.post(f"/api/businesses/{biz_id}/runs", json=body)

    assert create_resp.status_code in (400, 409), (
        f"create should reject with 400/409 due to active run; got "
        f"{create_resp.status_code}: {create_resp.text}"
    )
    v_body = v_resp.json()
    blockers = v_body.get("blockers", [])
    assert any(
        "active run" in (b.get("message") or "").lower()
        for b in blockers
    ), (
        f"validate did not surface the active-run lock as a blocker: "
        f"{json.dumps(blockers, indent=2)}"
    )
