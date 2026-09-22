"""Element-identity ergonomics (ADR D-045): product reads serve id+name+fqn,
the review marks accept a UUID OR an FQN, per-domain review % is exposed, and
``% model touched`` is computed off the existing diff.

Backend-only contract + behavior coverage. The model is hydrated from the
Lakebase Domain/Product/Attribute rows (the same path the live explorer uses),
so the DB ids flow through to the Out projections.
"""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    Domain,
    ModelVersion,
    Product,
    ProductReview,
    Subdomain,
    VibeInput,
    VibeInputContextLink,
)

HEADERS = {"X-Forwarded-Email": "alice@x.com"}


@pytest.fixture
def model(engine):
    """v1 ECM base (no predecessor): Sales{orders, customers}, Ops{tickets}.
    'orders' has an FK to Sales.customers. Returns a dict of ids + the version
    int."""
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
        sub = Subdomain(version_id=mv.id, domain_id=sales.id, name="Commerce")
        s.add(sub)
        s.commit()
        orders = Product(version_id=mv.id, domain_id=sales.id, name="orders",
                         table_name="orders", subdomain="Commerce",
                         subdomain_id=sub.id)
        customers = Product(version_id=mv.id, domain_id=sales.id, name="customers",
                            table_name="customers")
        tickets = Product(version_id=mv.id, domain_id=ops.id, name="tickets",
                          table_name="tickets")
        s.add(orders)
        s.add(customers)
        s.add(tickets)
        s.commit()
        s.add(Attribute(product_id=orders.id, name="customer_id",
                        column_name="customer_id",
                        foreign_key_to="Sales.customers.id"))
        s.commit()
        return {
            "bid": b.id, "vid": mv.id, "version": 1, "scope": "ecm",
            "sales_id": sales.id, "ops_id": ops.id, "sub_id": sub.id,
            "orders_id": orders.id, "customers_id": customers.id,
            "tickets_id": tickets.id,
        }


# --- Task 1: id + name + fqn on product reads -------------------------------


def test_domain_detail_products_carry_id_and_fqn(client, model):
    bid = model["bid"]
    r = client.get(f"/api/businesses/{bid}/versions/1/ecm/domains/Sales")
    assert r.status_code == 200, r.text
    products = {p["name"]: p for p in r.json()["products"]}
    assert products["orders"]["id"] == model["orders_id"]
    assert products["orders"]["fqn"] == "Sales.orders"
    assert products["customers"]["fqn"] == "Sales.customers"
    # FK target key uses the canonical "<domain>.<table>" form.
    assert "Sales.customers" in products["orders"]["fk_targets"]


def test_product_detail_carries_id_fqn_and_attribute_ids(client, model):
    bid = model["bid"]
    r = client.get(f"/api/businesses/{bid}/versions/1/ecm/domains/Sales/products/orders")
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["id"] == model["orders_id"]
    assert body["fqn"] == "Sales.orders"
    attr = body["attributes"][0]
    assert attr["id"]  # non-empty UUID from the DB row
    assert attr["name"] == "customer_id"


def test_model_summary_domains_and_subdomains_carry_id(client, model):
    bid = model["bid"]
    r = client.get(f"/api/businesses/{bid}/versions/1/ecm/model")
    assert r.status_code == 200, r.text
    domains = {d["name"]: d for d in r.json()["domains"]}
    assert domains["Sales"]["id"] == model["sales_id"]
    subs = {sd["name"]: sd for sd in domains["Sales"]["subdomains"]}
    assert subs["Commerce"]["id"] == model["sub_id"]


def test_review_rows_self_describing(client, model):
    bid = model["bid"]
    r = client.get(f"/api/businesses/{bid}/versions/1/ecm/reviews")
    assert r.status_code == 200, r.text
    by_pid = {row["product_id"]: row for row in r.json()}
    orders = by_pid[model["orders_id"]]
    assert orders["product_name"] == "orders"
    assert orders["fqn"] == "Sales.orders"


# --- Task 2: mark by UUID or FQN resolves to the same row -------------------


def test_mark_by_fqn_equals_mark_by_uuid(client, model):
    bid, vint, scope = model["bid"], model["version"], model["scope"]
    by_uuid = client.post(
        f"/api/businesses/{bid}/versions/{vint}/{scope}/reviews/product/{model['orders_id']}",
        json={"state": "reviewed"}, headers=HEADERS,
    )
    assert by_uuid.status_code == 200, by_uuid.text
    by_fqn = client.post(
        f"/api/businesses/{bid}/versions/{vint}/{scope}/reviews/product/Sales.orders",
        json={"state": "reviewed"}, headers=HEADERS,
    )
    assert by_fqn.status_code == 200, by_fqn.text
    # Both resolve to the SAME product row (idempotent upsert → same id).
    assert by_fqn.json()["product_id"] == model["orders_id"]
    assert by_fqn.json()["id"] == by_uuid.json()["id"]
    assert by_fqn.json()["product_name"] == "orders"
    assert by_fqn.json()["fqn"] == "Sales.orders"


def test_mark_by_table_name_resolves(client, model):
    bid, vint, scope = model["bid"], model["version"], model["scope"]
    r = client.post(
        f"/api/businesses/{bid}/versions/{vint}/{scope}/reviews/product/Sales.orders",
        json={"state": "reviewed"}, headers=HEADERS,
    )
    assert r.status_code == 200 and r.json()["product_id"] == model["orders_id"]


def test_clear_by_fqn(client, model):
    bid, vint, scope = model["bid"], model["version"], model["scope"]
    client.post(
        f"/api/businesses/{bid}/versions/{vint}/{scope}/reviews/product/{model['orders_id']}",
        json={"state": "reviewed"}, headers=HEADERS,
    )
    r = client.delete(
        f"/api/businesses/{bid}/versions/{vint}/{scope}/reviews/product/Sales.orders"
    )
    assert r.status_code == 200, r.text
    assert r.json()["product_id"] == model["orders_id"]


def test_mark_domain_by_name_cascades(client, model):
    bid, vint, scope = model["bid"], model["version"], model["scope"]
    r = client.post(
        f"/api/businesses/{bid}/versions/{vint}/{scope}/reviews/domain/Sales",
        json={"state": "reviewed"}, headers=HEADERS,
    )
    assert r.status_code == 200, r.text
    # Sales has 2 products → both marked.
    assert r.json()["affected"] == 2
    assert all(p["product_name"] for p in r.json()["products"])


def test_mark_subdomain_by_name_cascades(client, model):
    bid, vint, scope = model["bid"], model["version"], model["scope"]
    r = client.post(
        f"/api/businesses/{bid}/versions/{vint}/{scope}/reviews/subdomain/Commerce",
        json={"state": "reviewed"}, headers=HEADERS,
    )
    assert r.status_code == 200, r.text
    assert r.json()["affected"] == 1  # only 'orders' is in Commerce


# --- Task 3: per-domain review progress endpoint ----------------------------


def test_review_progress_by_domain(client, model, engine):
    bid, vid = model["bid"], model["vid"]
    # Mark both Sales products reviewed; leave Ops untouched.
    with Session(engine) as s:
        for pid in (model["orders_id"], model["customers_id"]):
            s.add(ProductReview(version_id=vid, product_id=pid,
                                state="reviewed", reviewer="x"))
        s.commit()
    r = client.get(f"/api/businesses/{bid}/versions/1/ecm/review-progress/by-domain")
    assert r.status_code == 200, r.text
    by_did = {row["domain_id"]: row for row in r.json()}
    sales = by_did[model["sales_id"]]
    assert sales["domain"] == "Sales"
    assert sales["reviewed"] == 2
    assert sales["review_needed"] == 2
    assert sales["review_pct"] == pytest.approx(1.0)
    ops = by_did[model["ops_id"]]
    assert ops["reviewed"] == 0
    assert ops["review_needed"] == 1
    assert ops["review_pct"] == 0.0


def test_review_progress_by_domain_excludes_no_review_needed(client, model, engine):
    bid, vid = model["bid"], model["vid"]
    with Session(engine) as s:
        # One Sales product reviewed, the other explicitly no_review_needed.
        s.add(ProductReview(version_id=vid, product_id=model["orders_id"],
                            state="reviewed", reviewer="x"))
        s.add(ProductReview(version_id=vid, product_id=model["customers_id"],
                            state="no_review_needed", reviewer="x"))
        s.commit()
    r = client.get(f"/api/businesses/{bid}/versions/1/ecm/review-progress/by-domain")
    sales = {row["domain_id"]: row for row in r.json()}[model["sales_id"]]
    # no_review_needed excluded from the denominator → 1/1.
    assert sales["review_needed"] == 1
    assert sales["reviewed"] == 1
    assert sales["no_review_needed"] == 1
    assert sales["review_pct"] == pytest.approx(1.0)


# --- Task 4: % model touched -----------------------------------------------


def test_model_touched_pct_null_on_base_version(client, model):
    """A base version (no predecessor) → null; no diff to compute against."""
    bid = model["bid"]
    r = client.get(f"/api/businesses/{bid}/versions/1/ecm/evolution-metrics")
    assert r.status_code == 200, r.text
    change = r.json()["change"]
    assert change["model_touched_pct"] is None
    # The breakdown counts mirror the pct: all null on a baseline.
    assert change["products_added"] is None
    assert change["products_modified"] is None
    assert change["products_removed"] is None
    assert r.json()["has_predecessor"] is False


def test_model_touched_pct_computed_from_diff():
    """% touched = (added+modified+removed) / |prev ∪ current|, reusing the
    existing diff. Unit-level over the canonical ``_compute_diff`` +
    ``_model_touched_pct`` so the metric never recomputes change
    independently."""
    from vibe_modeling.backend.explorer import _compute_diff, _model_touched_pct

    old = {"domains": [{"name": "Sales", "products": [
        {"name": "orders", "attributes": []},
        {"name": "customers", "attributes": []},
    ]}]}
    new = {"domains": [{"name": "Sales", "products": [
        {"name": "orders", "attributes": [
            {"name": "x", "type": "int"}  # NEW attribute → product MODIFIED
        ]},
        {"name": "customers", "attributes": []},  # unchanged
        {"name": "returns", "attributes": []},     # NEW product
    ]}]}
    diff = _compute_diff(old, new)
    # union = {orders, customers, returns} = 3; touched = orders(mod)+returns(new) = 2.
    assert _model_touched_pct(new, diff, has_predecessor=True) == round(100 * 2 / 3)
    # No predecessor → null regardless of diff.
    assert _model_touched_pct(new, diff, has_predecessor=False) is None


def test_change_breakdown_counts_from_diff():
    """The (added, modified, removed, current) breakdown reuses the same diff."""
    from vibe_modeling.backend.explorer import _compute_diff, _change_breakdown

    old = {"domains": [{"name": "Sales", "products": [
        {"name": "orders", "attributes": []},
        {"name": "customers", "attributes": []},
        {"name": "legacy", "attributes": []},
    ]}]}
    new = {"domains": [{"name": "Sales", "products": [
        {"name": "orders", "attributes": [{"name": "x", "type": "int"}]},  # MODIFIED
        {"name": "customers", "attributes": []},  # unchanged
        {"name": "returns", "attributes": []},  # NEW
    ]}]}  # 'legacy' removed
    diff = _compute_diff(old, new)
    added, modified, removed, current = _change_breakdown(new, diff)
    assert (added, modified, removed, current) == (1, 1, 1, 3)


def test_model_touched_pct_deletion_only_is_positive():
    """A deletion-only version (no new/modified) reads > 0, not 0."""
    from vibe_modeling.backend.explorer import _compute_diff, _model_touched_pct

    old = {"domains": [{"name": "Sales", "products": [
        {"name": "orders", "attributes": []},
        {"name": "customers", "attributes": []},
    ]}]}
    new = {"domains": [{"name": "Sales", "products": [
        {"name": "orders", "attributes": []},  # unchanged
    ]}]}  # 'customers' removed
    diff = _compute_diff(old, new)
    pct = _model_touched_pct(new, diff, has_predecessor=True)
    # touched = 1 removed; union = {orders, customers} = 2 → 50.
    assert pct == 50.0
    assert pct > 0


def test_model_touched_pct_bounded_0_to_100():
    """Always 0..100 — heavy deletion can't push the ratio over 100."""
    from vibe_modeling.backend.explorer import _compute_diff, _model_touched_pct

    old = {"domains": [{"name": "Sales", "products": [
        {"name": f"p{i}", "attributes": []} for i in range(10)
    ]}]}
    # Drop 9 of 10, modify the survivor, add one new.
    new = {"domains": [{"name": "Sales", "products": [
        {"name": "p0", "attributes": [{"name": "x", "type": "int"}]},  # MODIFIED
        {"name": "fresh", "attributes": []},  # NEW
    ]}]}
    diff = _compute_diff(old, new)
    pct = _model_touched_pct(new, diff, has_predecessor=True)
    # union = 9 removed + p0 + fresh = 11; touched = 9 + 1 + 1 = 11 → 100.
    assert pct == 100.0
    assert 0 <= pct <= 100


def test_model_touched_pct_null_when_union_empty():
    """Both versions empty → null (denom 0), never a divide-by-zero."""
    from vibe_modeling.backend.explorer import _compute_diff, _model_touched_pct

    old = {"domains": []}
    new = {"domains": []}
    diff = _compute_diff(old, new)
    assert _model_touched_pct(new, diff, has_predecessor=True) is None


# --- No N+1: list anchor hydration batches element lookups ------------------


def test_list_inputs_batches_anchor_element_lookups(client, model, engine, monkeypatch):
    """Hydrating N anchored inputs must not fan out to a per-input element
    fetch. Assert the per-grain prefetch runs a BOUNDED number of element
    ``session.get`` calls regardless of input count."""
    bid, vid = model["bid"], model["vid"]
    # Anchor 5 inputs to the same product on the same version.
    with Session(engine) as s:
        for i in range(5):
            vi = VibeInput(business_id=bid, origin="user", author="a",
                           text=f"note {i}", priority="medium")
            s.add(vi)
            s.flush()
            s.add(VibeInputContextLink(
                input_id=vi.id, version_id=vid, is_origin=True,
                domain_id=model["sales_id"], product_id=model["orders_id"],
            ))
        s.commit()

    import vibe_modeling.backend.routes.vibe_inputs as vi_mod

    calls = {"n": 0}
    real_prefetch = vi_mod._prefetch_anchor_elements

    def _counting_prefetch(session, links):
        calls["n"] += 1
        return real_prefetch(session, links)

    monkeypatch.setattr(vi_mod, "_prefetch_anchor_elements", _counting_prefetch)
    r = client.get(f"/api/businesses/{bid}/inputs?version_id={vid}")
    assert r.status_code == 200, r.text
    rows = r.json()
    assert len(rows) == 5
    # Every row hydrated with the product name from the single batch.
    assert all(row["anchor"]["product_name"] == "orders" for row in rows)
    # Prefetch is invoked exactly ONCE for the whole list (not per input).
    assert calls["n"] == 1
