"""next_vibes "expected work" metrics layer (T13, ADR D-044).

Covers the ``next_vibe_metrics`` helper and the two read endpoints
(``getNextVibeMetrics`` / ``getDomainNextVibeMetrics``):

* per-category open counts (model scope),
* scope filtering (model vs domain; domain via direct ``domain_id`` AND via
  the product → domain map for product/attribute anchors),
* quality-score aggregation (mean of in-scope open ``confidence_score``),
* the empty → degraded case (``has_data=False``, zeros/null) — the
  pre-ingestion default,
* that only open (active, non-consumed) agent inputs count, and user-origin
  inputs are excluded.

Precise-count tests hand-build rows so the anchor placement is deterministic;
a seeder-driven test asserts the helper agrees with the seeder's own
``category_counts`` on the model scope.
"""

import os
import sys
from pathlib import Path
from typing import Any, Optional

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from sqlmodel import Session

from vibe_modeling.backend import next_vibe_metrics as nv
from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    Domain,
    ModelVersion,
    Product,
    VibeInput,
    VibeInputContextLink,
)
from vibe_modeling.backend.models import (
    NextVibeCategory,
    VibeInputOrigin,
    VibeInputPriority,
    VibeInputStatus,
)


_SEEDER_PATH = (
    Path(__file__).resolve().parents[2] / "scripts" / "dev" / "seed_vibe_inputs.py"
)


def _load_seeder() -> Any:
    import importlib.util

    spec = importlib.util.spec_from_file_location("seed_vibe_inputs", str(_SEEDER_PATH))
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def _add_agent_input(
    session: Session,
    *,
    business_id: str,
    version_id: str,
    category: Optional[NextVibeCategory],
    confidence: Optional[float],
    domain_id: Optional[str] = None,
    product_id: Optional[str] = None,
    attribute_id: Optional[str] = None,
    status: str = VibeInputStatus.ACTIVE.value,
    consumed: bool = False,
    origin: str = VibeInputOrigin.AGENT_NEXT_VIBE.value,
) -> str:
    vi = VibeInput(
        business_id=business_id,
        origin=origin,
        author="",
        text="finding",
        category=category.value if category else None,
        priority=VibeInputPriority.MEDIUM.value,
        confidence_score=confidence,
        consumed=consumed,
        status=status,
    )
    session.add(vi)
    session.flush()
    link = VibeInputContextLink(
        input_id=vi.id,
        version_id=version_id,
        domain_id=domain_id,
        product_id=product_id,
        attribute_id=attribute_id,
        is_origin=True,
    )
    session.add(link)
    session.flush()
    return vi.id


@pytest.fixture
def model(engine):
    """Business + completed v1 ECM with 2 domains. Sales has 1 product (with 1
    attribute); Ops has 1 product. Returns a dict of ids."""
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
        sp = Product(version_id=mv.id, domain_id=sales.id, name="orders")
        op = Product(version_id=mv.id, domain_id=ops.id, name="tickets")
        s.add(sp)
        s.add(op)
        s.commit()
        sa = Attribute(product_id=sp.id, name="order_id")
        s.add(sa)
        s.commit()
        return {
            "bid": b.id,
            "vid": mv.id,
            "sales_id": sales.id,
            "ops_id": ops.id,
            "sales_product_id": sp.id,
            "ops_product_id": op.id,
            "sales_attr_id": sa.id,
        }


# --- empty / degraded -------------------------------------------------------


def test_empty_degrades_to_no_data(engine, model):
    with Session(engine) as s:
        m = nv.compute_metrics(s, model["vid"])
    assert m.total_open == 0
    assert m.quality_score is None
    assert m.has_data is False
    assert m.counts == {
        "static_analysis": 0,
        "priority_remediation": 0,
        "other": 0,
    }


def test_empty_domain_degrades(engine, model):
    with Session(engine) as s:
        m = nv.compute_metrics_for_domain(s, model["vid"], model["sales_id"])
    assert m.total_open == 0 and m.quality_score is None and m.has_data is False


# --- model-scope counts + quality aggregation -------------------------------


def test_model_scope_counts_by_category_and_mean_quality(engine, model):
    with Session(engine) as s:
        _add_agent_input(
            s, business_id=model["bid"], version_id=model["vid"],
            category=NextVibeCategory.STATIC_ANALYSIS, confidence=0.4,
            domain_id=model["sales_id"], product_id=model["sales_product_id"],
        )
        _add_agent_input(
            s, business_id=model["bid"], version_id=model["vid"],
            category=NextVibeCategory.PRIORITY_REMEDIATION, confidence=0.8,
            domain_id=model["ops_id"], product_id=model["ops_product_id"],
        )
        _add_agent_input(
            s, business_id=model["bid"], version_id=model["vid"],
            category=NextVibeCategory.PRIORITY_REMEDIATION, confidence=0.6,
            domain_id=model["sales_id"],
        )
        _add_agent_input(
            s, business_id=model["bid"], version_id=model["vid"],
            category=NextVibeCategory.OTHER, confidence=None,
        )
        s.commit()
        m = nv.compute_metrics(s, model["vid"])

    assert m.total_open == 4
    assert m.has_data is True
    assert m.counts == {
        "static_analysis": 1,
        "priority_remediation": 2,
        "other": 1,
    }
    # Mean over the 3 SCORED inputs only (the null-score OTHER is ignored).
    assert m.quality_score == pytest.approx((0.4 + 0.8 + 0.6) / 3)


def test_null_category_agent_input_counts_as_other(engine, model):
    with Session(engine) as s:
        _add_agent_input(
            s, business_id=model["bid"], version_id=model["vid"],
            category=None, confidence=0.5,
        )
        s.commit()
        m = nv.compute_metrics(s, model["vid"])
    assert m.total_open == 1
    assert m.counts["other"] == 1


# --- only open agent inputs count -------------------------------------------


def test_excludes_consumed_deprecated_and_user(engine, model):
    with Session(engine) as s:
        _add_agent_input(
            s, business_id=model["bid"], version_id=model["vid"],
            category=NextVibeCategory.PRIORITY_REMEDIATION, confidence=0.9,
        )  # the one open agent input
        _add_agent_input(
            s, business_id=model["bid"], version_id=model["vid"],
            category=NextVibeCategory.PRIORITY_REMEDIATION, confidence=0.1,
            consumed=True,
        )
        _add_agent_input(
            s, business_id=model["bid"], version_id=model["vid"],
            category=NextVibeCategory.STATIC_ANALYSIS, confidence=0.1,
            status=VibeInputStatus.DEPRECATED.value,
        )
        _add_agent_input(
            s, business_id=model["bid"], version_id=model["vid"],
            category=None, confidence=None, origin=VibeInputOrigin.USER.value,
        )
        s.commit()
        m = nv.compute_metrics(s, model["vid"])
    assert m.total_open == 1
    assert m.counts["priority_remediation"] == 1
    assert m.quality_score == pytest.approx(0.9)


# --- domain scope filtering -------------------------------------------------


def test_domain_scope_direct_and_via_product_map(engine, model):
    with Session(engine) as s:
        # Sales: one domain-level anchor + one attribute anchor (domain derived
        # via product map even though the link's domain_id is null).
        _add_agent_input(
            s, business_id=model["bid"], version_id=model["vid"],
            category=NextVibeCategory.STATIC_ANALYSIS, confidence=0.5,
            domain_id=model["sales_id"],
        )
        _add_agent_input(
            s, business_id=model["bid"], version_id=model["vid"],
            category=NextVibeCategory.PRIORITY_REMEDIATION, confidence=0.9,
            domain_id=None, product_id=model["sales_product_id"],
            attribute_id=model["sales_attr_id"],
        )
        # Ops: one product anchor with null domain_id (derived via product map).
        _add_agent_input(
            s, business_id=model["bid"], version_id=model["vid"],
            category=NextVibeCategory.OTHER, confidence=0.2,
            domain_id=None, product_id=model["ops_product_id"],
        )
        s.commit()
        sales = nv.compute_metrics_for_domain(s, model["vid"], model["sales_id"])
        ops = nv.compute_metrics_for_domain(s, model["vid"], model["ops_id"])
        whole = nv.compute_metrics(s, model["vid"])

    assert sales.total_open == 2
    assert sales.counts == {
        "static_analysis": 1,
        "priority_remediation": 1,
        "other": 0,
    }
    assert sales.quality_score == pytest.approx((0.5 + 0.9) / 2)

    assert ops.total_open == 1
    assert ops.counts["other"] == 1
    assert ops.quality_score == pytest.approx(0.2)

    assert whole.total_open == 3


def test_model_wide_anchor_excluded_from_domain_scope(engine, model):
    with Session(engine) as s:
        # all-null anchor (model-wide) — counts at model scope, not any domain.
        _add_agent_input(
            s, business_id=model["bid"], version_id=model["vid"],
            category=NextVibeCategory.OTHER, confidence=0.3,
        )
        s.commit()
        whole = nv.compute_metrics(s, model["vid"])
        sales = nv.compute_metrics_for_domain(s, model["vid"], model["sales_id"])
    assert whole.total_open == 1
    assert sales.total_open == 0 and sales.has_data is False


def test_link_with_domain_and_product_counted_once(engine, model):
    """A single link can carry BOTH a direct ``domain_id`` and a
    ``product_id`` in the same domain — the input must still count once in the
    domain scope (the ``setdefault`` dedup guards against a future where a
    second link is allowed). The DB enforces one link per (input, version), so
    this is the realistic "multiple anchor fields" case."""
    with Session(engine) as s:
        _add_agent_input(
            s, business_id=model["bid"], version_id=model["vid"],
            category=NextVibeCategory.PRIORITY_REMEDIATION, confidence=0.7,
            domain_id=model["sales_id"], product_id=model["sales_product_id"],
            attribute_id=model["sales_attr_id"],
        )
        s.commit()
        sales = nv.compute_metrics_for_domain(s, model["vid"], model["sales_id"])
        whole = nv.compute_metrics(s, model["vid"])
    assert sales.total_open == 1
    assert whole.total_open == 1


# --- seeder agreement (model scope) -----------------------------------------


def test_agrees_with_seeder_category_counts(engine, model):
    seeder = _load_seeder()
    with Session(engine) as s:
        result = seeder.seed_vibe_inputs(
            s, model["bid"], model["vid"], n_agent=10, n_user=5, quality_score=0.76
        )
        m = nv.compute_metrics(s, model["vid"])
    assert m.total_open == 10
    assert m.has_data is True
    # Categories the helper reports match the seeder's own tally.
    expected = {k: 0 for k in ("static_analysis", "priority_remediation", "other")}
    expected.update(result.category_counts)
    assert m.counts == expected
    # All agent inputs carry the same quality score → mean == that score.
    assert m.quality_score == pytest.approx(0.76)


# --- endpoints --------------------------------------------------------------


def _seed_for_client(engine, model):
    with Session(engine) as s:
        _add_agent_input(
            s, business_id=model["bid"], version_id=model["vid"],
            category=NextVibeCategory.STATIC_ANALYSIS, confidence=0.4,
            domain_id=model["sales_id"],
        )
        _add_agent_input(
            s, business_id=model["bid"], version_id=model["vid"],
            category=NextVibeCategory.PRIORITY_REMEDIATION, confidence=0.8,
            domain_id=model["ops_id"], product_id=model["ops_product_id"],
        )
        s.commit()


def test_endpoint_model_scope(client, engine, model):
    _seed_for_client(engine, model)
    r = client.get(
        f"/api/businesses/{model['bid']}/versions/1/ecm/next-vibe-metrics"
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["version_id"] == model["vid"]
    assert body["domain_id"] is None
    assert body["total_open"] == 2
    assert body["has_data"] is True
    assert body["counts"] == {
        "static_analysis": 1,
        "priority_remediation": 1,
        "other": 0,
        "total": 2,
    }
    assert body["quality_score"] == pytest.approx((0.4 + 0.8) / 2)


def test_endpoint_domain_scope(client, engine, model):
    _seed_for_client(engine, model)
    r = client.get(
        f"/api/businesses/{model['bid']}/versions/1/ecm/domains/Sales/next-vibe-metrics"
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["domain_id"] == model["sales_id"]
    assert body["total_open"] == 1
    assert body["counts"]["static_analysis"] == 1
    assert body["quality_score"] == pytest.approx(0.4)


def test_endpoint_empty_degraded(client, model):
    r = client.get(
        f"/api/businesses/{model['bid']}/versions/1/ecm/next-vibe-metrics"
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["has_data"] is False
    assert body["total_open"] == 0
    assert body["quality_score"] is None
    assert body["counts"] == {
        "static_analysis": 0,
        "priority_remediation": 0,
        "other": 0,
        "total": 0,
    }


def test_endpoint_unknown_version_404(client, model):
    r = client.get(
        f"/api/businesses/{model['bid']}/versions/99/ecm/next-vibe-metrics"
    )
    assert r.status_code == 404


def test_endpoint_unknown_domain_404(client, model):
    r = client.get(
        f"/api/businesses/{model['bid']}/versions/1/ecm/domains/Nope/next-vibe-metrics"
    )
    assert r.status_code == 404
