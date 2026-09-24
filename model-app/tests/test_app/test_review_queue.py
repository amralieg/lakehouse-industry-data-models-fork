"""API tests for the resumable re-link review queue + carry-forward.

See task5-backend-api.md §3.4, §4.3.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Business,
    Domain,
    ModelVersion,
    Product,
    RunElementLineage,
    VibeInput,
    VibeInputContextLink,
)

HEADERS = {"X-Forwarded-Email": "rev@x.com"}


@pytest.fixture
def scenario(engine):
    """v1 with Sales.Orders; W where Orders is gone but Sales survives (pointer)
    → carry-forward should flag a partial-ancestor review. Returns ids dict."""
    with Session(engine) as s:
        b = Business(name="Acme")
        s.add(b)
        s.commit()
        v1 = ModelVersion(business_id=b.id, version=1, status="completed", scope="ecm")
        s.add(v1)
        s.commit()
        d1 = Domain(version_id=v1.id, name="Sales")
        s.add(d1)
        s.commit()
        p1 = Product(version_id=v1.id, domain_id=d1.id, name="Orders")
        s.add(p1)
        s.commit()
        w = ModelVersion(business_id=b.id, version=2, status="completed",
                         scope="ecm", base_version_id=v1.id)
        s.add(w)
        s.commit()
        d2 = Domain(version_id=w.id, name="Sales", previous_element_id=d1.id)
        s.add(d2)
        s.commit()
        # input anchored at Sales.Orders on v1
        vi = VibeInput(business_id=b.id, text="orders rule")
        s.add(vi)
        s.commit()
        s.add(VibeInputContextLink(input_id=vi.id, version_id=v1.id,
                                   domain_id=d1.id, product_id=p1.id, is_origin=True))
        s.commit()
        return {"bid": b.id, "v1": v1.id, "w": w.id, "d2": d2.id, "vi": vi.id}


def test_carry_forward_flags_partial_review(client, scenario):
    bid, w = scenario["bid"], scenario["w"]
    r = client.post(f"/api/businesses/{bid}/versions/{w}/inputs/carry-forward")
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["needs_review"] == 1
    assert body["auto_linked"] == 0
    assert len(body["link_ids_needing_review"]) == 1


def test_review_queue_lists_oldest_first_with_label_and_tier(client, scenario):
    bid, w = scenario["bid"], scenario["w"]
    client.post(f"/api/businesses/{bid}/versions/{w}/inputs/carry-forward")
    r = client.get(f"/api/businesses/{bid}/links/review-queue")
    assert r.status_code == 200
    body = r.json()
    assert body["total"] == 1
    item = body["items"][0]
    assert item["tier"] == "partial_ancestor"
    assert "Sales" in item["proposed_anchor_label"]
    assert item["input"]["id"] == scenario["vi"]


def test_accept_clears_flag_and_stamps_reviewer(client, scenario):
    bid, w = scenario["bid"], scenario["w"]
    client.post(f"/api/businesses/{bid}/versions/{w}/inputs/carry-forward")
    link_id = client.get(
        f"/api/businesses/{bid}/links/review-queue"
    ).json()["items"][0]["link"]["id"]
    r = client.post(f"/api/businesses/{bid}/links/{link_id}/review/accept",
                    headers=HEADERS)
    assert r.status_code == 200
    assert r.json()["needs_link_review"] is False
    assert r.json()["reviewed_by"] == "rev@x.com"
    # Queue now empty (resumability).
    assert client.get(f"/api/businesses/{bid}/links/review-queue").json()["total"] == 0


def test_reanchor_moves_anchor(client, scenario, engine):
    bid, w, d2 = scenario["bid"], scenario["w"], scenario["d2"]
    # add a product on W to reanchor to
    with Session(engine) as s:
        p2 = Product(version_id=w, domain_id=d2, name="NewOrders")
        s.add(p2)
        s.commit()
        p2_id = p2.id
    client.post(f"/api/businesses/{bid}/versions/{w}/inputs/carry-forward")
    link_id = client.get(
        f"/api/businesses/{bid}/links/review-queue"
    ).json()["items"][0]["link"]["id"]
    r = client.post(f"/api/businesses/{bid}/links/{link_id}/review/reanchor",
                    json={"domain_id": d2, "product_id": p2_id}, headers=HEADERS)
    assert r.status_code == 200
    assert r.json()["product_id"] == p2_id
    assert r.json()["needs_link_review"] is False


def test_reanchor_bad_element_400(client, scenario):
    bid, w = scenario["bid"], scenario["w"]
    client.post(f"/api/businesses/{bid}/versions/{w}/inputs/carry-forward")
    link_id = client.get(
        f"/api/businesses/{bid}/links/review-queue"
    ).json()["items"][0]["link"]["id"]
    r = client.post(f"/api/businesses/{bid}/links/{link_id}/review/reanchor",
                    json={"product_id": "does-not-exist"}, headers=HEADERS)
    assert r.status_code == 400


def test_dismiss_deletes_link_and_deprecates_when_no_head_link(client, scenario, engine):
    bid, w = scenario["bid"], scenario["w"]
    client.post(f"/api/businesses/{bid}/versions/{w}/inputs/carry-forward")
    link_id = client.get(
        f"/api/businesses/{bid}/links/review-queue"
    ).json()["items"][0]["link"]["id"]
    r = client.post(f"/api/businesses/{bid}/links/{link_id}/review/dismiss")
    assert r.status_code == 200
    # W is head; dismissing its only link → system-deprecate.
    assert r.json()["status"] == "deprecated"
    assert r.json()["deprecated_by"] is None
    with Session(engine) as s:
        assert s.get(VibeInputContextLink, link_id) is None


def test_dismiss_origin_409(client, scenario, engine):
    bid = scenario["bid"]
    with Session(engine) as s:
        origin = s.exec(
            select(VibeInputContextLink).where(
                VibeInputContextLink.input_id == scenario["vi"],
                VibeInputContextLink.is_origin == True,  # noqa: E712
            )
        ).first()
        origin_id = origin.id
    r = client.post(f"/api/businesses/{bid}/links/{origin_id}/review/dismiss")
    assert r.status_code == 409


def test_carry_forward_idempotent(client, scenario):
    bid, w = scenario["bid"], scenario["w"]
    client.post(f"/api/businesses/{bid}/versions/{w}/inputs/carry-forward")
    r = client.post(f"/api/businesses/{bid}/versions/{w}/inputs/carry-forward")
    body = r.json()
    assert body["skipped_existing"] == 1
    assert body["needs_review"] == 0


def test_dismiss_agent_next_vibe_origin_deprecates_not_409(client, scenario, engine):
    """E-06: an agent next-vibe's review target IS its origin link, so dismiss
    must reject the proposed next-vibe (deprecate the input + clear the review
    flag, keeping the origin anchor for audit) instead of returning 409."""
    bid, w = scenario["bid"], scenario["w"]
    with Session(engine) as s:
        vi = VibeInput(
            business_id=bid, text="agent proposed carry", origin="agent_next_vibe"
        )
        s.add(vi)
        s.commit()
        lk = VibeInputContextLink(
            input_id=vi.id, version_id=w, is_origin=True, needs_link_review=True
        )
        s.add(lk)
        s.commit()
        lk_id = lk.id
    r = client.post(f"/api/businesses/{bid}/links/{lk_id}/review/dismiss")
    assert r.status_code == 200, r.text
    assert r.json()["status"] == "deprecated"
    with Session(engine) as s:
        lk2 = s.get(VibeInputContextLink, lk_id)
        assert lk2 is not None                    # origin kept for audit
        assert lk2.needs_link_review is False      # cleared → leaves the queue
