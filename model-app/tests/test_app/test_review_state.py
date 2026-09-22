"""Unit tests for the product-canonical review spine (ADR D-044).

Covers backend/review.py (the default-state rule, effective-state resolution,
the product-level progress measure, and the per-domain rollup) and the cascade
write semantics + product mark endpoints in routes/vibe_inputs.py.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend import review as _review
from vibe_modeling.backend.db_models import (
    Business,
    Domain,
    ModelVersion,
    Product,
    ProductReview,
    Subdomain,
    VibeInput,
    VibeInputContextLink,
)
from vibe_modeling.backend.models import ChangeStatus, ReviewState

HEADERS = {"X-Forwarded-Email": "alice@x.com"}


# --- Default-state rule (pure) ----------------------------------------------


def test_default_unchanged_no_issues_is_no_review_needed():
    assert _review.compute_default_state(
        is_unchanged=True, has_open_issues=False
    ) == ReviewState.NO_REVIEW_NEEDED


def test_default_changed_is_not_reviewed():
    assert _review.compute_default_state(
        is_unchanged=False, has_open_issues=False
    ) == ReviewState.NOT_REVIEWED


def test_default_unchanged_with_open_issues_stays_not_reviewed():
    # Acceptance line: an unchanged product that still has open issues stays
    # not-reviewed and counts.
    assert _review.compute_default_state(
        is_unchanged=True, has_open_issues=True
    ) == ReviewState.NOT_REVIEWED


# --- effective_states + progress --------------------------------------------


@pytest.fixture
def two_domain_model(engine):
    """v1 ECM: Sales (2 products), Ops (1 product). Returns ids dict."""
    with Session(engine) as s:
        b = Business(name="Acme")
        s.add(b)
        s.commit()
        mv = ModelVersion(business_id=b.id, version=1, status="completed", scope="ecm")
        s.add(mv)
        s.commit()
        sales = Domain(version_id=mv.id, name="Sales")
        ops = Domain(version_id=mv.id, name="Ops")
        s.add(sales)
        s.add(ops)
        s.commit()
        p_a = Product(version_id=mv.id, domain_id=sales.id, name="A")
        p_b = Product(version_id=mv.id, domain_id=sales.id, name="B")
        p_c = Product(version_id=mv.id, domain_id=ops.id, name="C")
        s.add(p_a)
        s.add(p_b)
        s.add(p_c)
        s.commit()
        return {
            "business_id": b.id, "version_id": mv.id,
            "version_int": mv.version, "scope": mv.scope,
            "sales_id": sales.id, "ops_id": ops.id,
            "a": p_a.id, "b": p_b.id, "c": p_c.id,
        }


def test_effective_state_uses_change_diff_for_unmarked(two_domain_model, engine):
    ids = two_domain_model
    # Diff: Sales.A is MODIFIED, others absent (= unchanged).
    change = {("Sales", "A"): ChangeStatus.MODIFIED}
    with Session(engine) as s:
        views = _review.effective_states(s, ids["version_id"], change)
    by_pid = {v.product_id: v for v in views}
    assert by_pid[ids["a"]].state == ReviewState.NOT_REVIEWED  # changed
    assert by_pid[ids["b"]].state == ReviewState.NO_REVIEW_NEEDED  # unchanged, no issues
    assert by_pid[ids["c"]].state == ReviewState.NO_REVIEW_NEEDED
    assert all(v.is_explicit is False for v in views)


def test_explicit_mark_overrides_computed_default(two_domain_model, engine):
    ids = two_domain_model
    change = {}  # all unchanged → would default to no_review_needed
    with Session(engine) as s:
        s.add(ProductReview(version_id=ids["version_id"], product_id=ids["b"],
                            state="not_reviewed", reviewer="x"))
        s.commit()
        views = _review.effective_states(s, ids["version_id"], change)
    by_pid = {v.product_id: v for v in views}
    assert by_pid[ids["b"]].state == ReviewState.NOT_REVIEWED
    assert by_pid[ids["b"]].is_explicit is True
    assert by_pid[ids["a"]].state == ReviewState.NO_REVIEW_NEEDED


def test_open_issue_gate_keeps_unchanged_product_not_reviewed(two_domain_model, engine):
    ids = two_domain_model
    change = {}  # all unchanged
    with Session(engine) as s:
        # Open agent-origin issue anchored to product A.
        vi = VibeInput(business_id=ids["business_id"], origin="agent_next_vibe",
                       status="active", consumed=False, text="fix A")
        s.add(vi)
        s.commit()
        s.add(VibeInputContextLink(input_id=vi.id, version_id=ids["version_id"],
                                   product_id=ids["a"]))
        s.commit()
        views = _review.effective_states(s, ids["version_id"], change)
    by_pid = {v.product_id: v for v in views}
    # A has an open issue → stays not_reviewed even though unchanged.
    assert by_pid[ids["a"]].state == ReviewState.NOT_REVIEWED
    # B/C unchanged, no issue → no_review_needed.
    assert by_pid[ids["b"]].state == ReviewState.NO_REVIEW_NEEDED


def test_consumed_or_user_issues_do_not_gate(two_domain_model, engine):
    ids = two_domain_model
    change = {}
    with Session(engine) as s:
        # Consumed agent issue: not "open".
        vi1 = VibeInput(business_id=ids["business_id"], origin="agent_next_vibe",
                        status="active", consumed=True, text="done")
        # User-origin input: not an agent issue.
        vi2 = VibeInput(business_id=ids["business_id"], origin="user",
                        status="active", consumed=False, text="note")
        s.add(vi1)
        s.add(vi2)
        s.commit()
        s.add(VibeInputContextLink(input_id=vi1.id, version_id=ids["version_id"],
                                   product_id=ids["a"]))
        s.add(VibeInputContextLink(input_id=vi2.id, version_id=ids["version_id"],
                                   product_id=ids["a"]))
        s.commit()
        views = _review.effective_states(s, ids["version_id"], change)
    by_pid = {v.product_id: v for v in views}
    assert by_pid[ids["a"]].state == ReviewState.NO_REVIEW_NEEDED


def test_progress_excludes_no_review_needed(two_domain_model, engine):
    ids = two_domain_model
    # A changed (not_reviewed), B+C unchanged (no_review_needed). Mark A reviewed.
    change = {("Sales", "A"): ChangeStatus.MODIFIED}
    with Session(engine) as s:
        s.add(ProductReview(version_id=ids["version_id"], product_id=ids["a"],
                            state="reviewed", reviewer="x"))
        s.commit()
        pct, reviewed, review_needed, no_review_needed = _review.compute_progress(
            s, ids["version_id"], change
        )
    assert reviewed == 1
    assert review_needed == 1
    assert no_review_needed == 2
    assert pct == pytest.approx(1.0)


def test_domain_rollup(two_domain_model, engine):
    ids = two_domain_model
    change = {("Sales", "A"): ChangeStatus.MODIFIED,
              ("Sales", "B"): ChangeStatus.MODIFIED}
    with Session(engine) as s:
        s.add(ProductReview(version_id=ids["version_id"], product_id=ids["a"],
                            state="reviewed", reviewer="x"))
        s.commit()
        rollup = _review.compute_progress_by_domain(s, ids["version_id"], change)
    # Sales: 2 review-needed, 1 reviewed → 0.5.
    sales_pct, sales_reviewed, sales_needed, _ = rollup[ids["sales_id"]]
    assert sales_reviewed == 1
    assert sales_needed == 2
    assert sales_pct == pytest.approx(0.5)
    # Ops: C unchanged → no_review_needed → pct 0.0, needed 0.
    ops_pct, _, ops_needed, ops_nrn = rollup[ids["ops_id"]]
    assert ops_needed == 0
    assert ops_nrn == 1
    assert ops_pct == 0.0


# --- Write endpoints + cascade ----------------------------------------------


def test_mark_product_idempotent_and_clear(client, two_domain_model):
    ids = two_domain_model
    bid, vint, scope = ids["business_id"], ids["version_int"], ids["scope"]
    r = client.post(
        f"/api/businesses/{bid}/versions/{vint}/{scope}/reviews/product/{ids['a']}",
        json={"state": "reviewed"}, headers=HEADERS,
    )
    assert r.status_code == 200, r.text
    assert r.json()["state"] == "reviewed"
    assert r.json()["reviewer"] == "alice@x.com"
    assert r.json()["is_explicit"] is True
    # The resolved MV id is still surfaced in the response body.
    assert r.json()["version_id"] == ids["version_id"]
    first_id = r.json()["id"]
    # Re-mark with a different state → same row, updated.
    r2 = client.post(
        f"/api/businesses/{bid}/versions/{vint}/{scope}/reviews/product/{ids['a']}",
        json={"state": "not_reviewed"}, headers=HEADERS,
    )
    assert r2.json()["id"] == first_id
    assert r2.json()["state"] == "not_reviewed"
    # Clear → revert to computed default.
    r3 = client.delete(
        f"/api/businesses/{bid}/versions/{vint}/{scope}/reviews/product/{ids['a']}"
    )
    assert r3.status_code == 200


def test_mark_product_not_in_version_400(client, two_domain_model):
    ids = two_domain_model
    bid, vint, scope = ids["business_id"], ids["version_int"], ids["scope"]
    r = client.post(
        f"/api/businesses/{bid}/versions/{vint}/{scope}/reviews/product/nope",
        json={"state": "reviewed"}, headers=HEADERS,
    )
    assert r.status_code == 400


def test_mark_product_bad_version_404(client, two_domain_model):
    # A composite key that resolves to no MV → 404 (mirrors the read routes).
    ids = two_domain_model
    bid, scope = ids["business_id"], ids["scope"]
    r = client.post(
        f"/api/businesses/{bid}/versions/999/{scope}/reviews/product/{ids['a']}",
        json={"state": "reviewed"}, headers=HEADERS,
    )
    assert r.status_code == 404


def test_clear_missing_404(client, two_domain_model):
    ids = two_domain_model
    bid, vint, scope = ids["business_id"], ids["version_int"], ids["scope"]
    r = client.delete(
        f"/api/businesses/{bid}/versions/{vint}/{scope}/reviews/product/{ids['a']}"
    )
    assert r.status_code == 404


def test_cascade_domain_fans_out_to_products(client, two_domain_model, engine):
    ids = two_domain_model
    bid, vint, scope = ids["business_id"], ids["version_int"], ids["scope"]
    vid = ids["version_id"]
    r = client.post(
        f"/api/businesses/{bid}/versions/{vint}/{scope}/reviews/domain/{ids['sales_id']}",
        json={"state": "reviewed"}, headers=HEADERS,
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["affected"] == 2  # Sales has A + B
    assert {p["product_id"] for p in body["products"]} == {ids["a"], ids["b"]}
    # Persisted as explicit rows.
    with Session(engine) as s:
        rows = s.exec(
            select(ProductReview).where(ProductReview.version_id == vid)
        ).all()
        assert {r.product_id for r in rows} == {ids["a"], ids["b"]}
        assert all(r.state == "reviewed" for r in rows)


def test_cascade_subdomain_fans_out(client, two_domain_model, engine):
    ids = two_domain_model
    bid, vint, scope = ids["business_id"], ids["version_int"], ids["scope"]
    vid = ids["version_id"]
    with Session(engine) as s:
        sub = Subdomain(version_id=vid, domain_id=ids["sales_id"], name="SD")
        s.add(sub)
        s.commit()
        sub_id = sub.id
        # Put product A under the subdomain.
        p = s.get(Product, ids["a"])
        p.subdomain_id = sub_id
        s.add(p)
        s.commit()
    r = client.post(
        f"/api/businesses/{bid}/versions/{vint}/{scope}/reviews/subdomain/{sub_id}",
        json={"state": "no_review_needed"}, headers=HEADERS,
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["affected"] == 1
    assert body["products"][0]["product_id"] == ids["a"]
    assert body["products"][0]["state"] == "no_review_needed"


def test_cascade_domain_not_in_version_400(client, two_domain_model):
    ids = two_domain_model
    bid, vint, scope = ids["business_id"], ids["version_int"], ids["scope"]
    r = client.post(
        f"/api/businesses/{bid}/versions/{vint}/{scope}/reviews/domain/nope",
        json={"state": "reviewed"}, headers=HEADERS,
    )
    assert r.status_code == 400
