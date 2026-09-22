"""Model review % surfaced in ModelSummaryOut (product-canonical, ADR D-044).

Product-level fraction: reviewed ÷ review-needed products. ``no_review_needed``
products (explicit OR computed default) are excluded from the denominator.
Computed over this version's DB Product rows; resets per version. The
endpoint here exercises the base-version path (no predecessor), so every
product is "changed" relative to nothing → nothing auto-defaults to
no_review_needed; only explicit marks move the needle.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from sqlmodel import Session

from vibe_modeling.backend.db_models import (
    Business,
    Domain,
    ModelVersion,
    Product,
    ProductReview,
)


@pytest.fixture
def model_with_products(engine):
    """v1 ECM (base, no predecessor) with 2 domains: Sales (3 products), Ops
    (1 product). Returns (business_id, version_int, sales_pids, ops_pid, vid)."""
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
        sales_pids = []
        for i in range(3):
            p = Product(version_id=mv.id, domain_id=sales.id, name=f"s{i}")
            s.add(p)
            s.commit()
            sales_pids.append(p.id)
        ops_p = Product(version_id=mv.id, domain_id=ops.id, name="o0")
        s.add(ops_p)
        s.commit()
        return b.id, 1, sales_pids, ops_p.id, mv.id


def _summary(client, bid, version_int=1):
    r = client.get(f"/api/businesses/{bid}/versions/{version_int}/ecm/model")
    assert r.status_code == 200, r.text
    return r.json()


def test_review_pct_zero_when_none_reviewed(client, model_with_products):
    bid = model_with_products[0]
    body = _summary(client, bid)
    # Base version: 4 products all "changed" (no predecessor) → review-needed,
    # none reviewed.
    assert body["review_pct"] == 0.0
    assert body["reviewed_count"] == 0
    assert body["review_needed_count"] == 4
    assert body["no_review_needed_count"] == 0


def test_review_pct_product_weighted(client, model_with_products, engine):
    bid, _, sales_pids, ops_pid, vid = model_with_products
    # Mark Sales' 3 products reviewed → 3 of 4 → 0.75.
    with Session(engine) as s:
        for pid in sales_pids:
            s.add(ProductReview(version_id=vid, product_id=pid,
                                state="reviewed", reviewer="x"))
        s.commit()
    body = _summary(client, bid)
    assert body["review_pct"] == pytest.approx(0.75)
    assert body["reviewed_count"] == 3
    assert body["review_needed_count"] == 4


def test_review_pct_all_reviewed(client, model_with_products, engine):
    bid, _, sales_pids, ops_pid, vid = model_with_products
    with Session(engine) as s:
        for pid in [*sales_pids, ops_pid]:
            s.add(ProductReview(version_id=vid, product_id=pid,
                                state="reviewed", reviewer="x"))
        s.commit()
    body = _summary(client, bid)
    assert body["review_pct"] == pytest.approx(1.0)
    assert body["reviewed_count"] == 4


def test_no_review_needed_excluded_from_denominator(client, model_with_products, engine):
    bid, _, sales_pids, ops_pid, vid = model_with_products
    # Mark one product no_review_needed (explicit override) and two reviewed.
    with Session(engine) as s:
        s.add(ProductReview(version_id=vid, product_id=ops_pid,
                            state="no_review_needed", reviewer="x"))
        s.add(ProductReview(version_id=vid, product_id=sales_pids[0],
                            state="reviewed", reviewer="x"))
        s.add(ProductReview(version_id=vid, product_id=sales_pids[1],
                            state="reviewed", reviewer="x"))
        s.commit()
    body = _summary(client, bid)
    # review_needed = 3 (two reviewed + one still not_reviewed); reviewed = 2.
    assert body["review_needed_count"] == 3
    assert body["reviewed_count"] == 2
    assert body["no_review_needed_count"] == 1
    assert body["review_pct"] == pytest.approx(2 / 3)


def test_review_pct_resets_per_version(client, model_with_products, engine):
    bid, _, sales_pids, ops_pid, vid = model_with_products
    with Session(engine) as s:
        for pid in sales_pids:
            s.add(ProductReview(version_id=vid, product_id=pid,
                                state="reviewed", reviewer="x"))
        s.commit()
        mv2 = ModelVersion(business_id=bid, version=2, status="completed", scope="ecm")
        s.add(mv2)
        s.commit()
        d = Domain(version_id=mv2.id, name="Sales")
        s.add(d)
        s.commit()
        s.add(Product(version_id=mv2.id, domain_id=d.id, name="s0"))
        s.commit()
    body2 = _summary(client, bid, version_int=2)
    assert body2["review_pct"] == 0.0
    assert body2["reviewed_count"] == 0
