"""Model evolution metrics (T16, "Model Evolution Metrics" epic).

Covers the ``evolution_metrics`` projection helper and the
``getEvolutionMetrics`` read endpoint:

* full mapping of an iterated MVM ``_vibe_session_metadata`` onto the size /
  quality / change / effort / provenance areas,
* the two degradation cases the FE depends on:
  - **ECM / unjudged** → ``has_confidence=False``, ``confidence_score`` null
    (never coerced to 0),
  - **baseline / first version** → ``has_predecessor=False``,
    ``version_trend="baseline"``, every delta/previous_* null,
* the metadata-less import → ``has_metadata=False`` with the size block still
  populated from the model structure,
* size fallback + ``avg_attributes_per_product`` derivation,
* the endpoint reading the Volume envelope on demand (monkeypatched loader),
  and 404 on an unknown version.

The fixtures below use the authoritative agent shape (current notebook
``_vibe_session_metadata`` assembly) so the contract stays anchored to what
the agent actually emits.
"""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from sqlmodel import Session

from vibe_modeling.backend import evolution_metrics as evo
from vibe_modeling.backend import explorer
from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    Domain,
    ModelVersion,
    Product,
)


# ---------------------------------------------------------------------------
# Representative agent metadata fixtures (real ``_vibe_session_metadata`` shape)
# ---------------------------------------------------------------------------


def _iterated_mvm_metadata() -> dict:
    """An MVM v2 run that improved on its v1 predecessor — the rich case."""
    return {
        "generated_from_version": "v2_mvm",
        "target_model_version": "3",
        "start_time": "2026-05-01T10:00:00",
        "end_time": "2026-05-01T10:18:00",
        "duration_hours": 0.3,
        "status": "needs_work",
        "confidence_score": 82,
        "summary": "Model quality: 82/100 (3 warnings, 0 errors).",
        "issues_addressed": ["unlinked_fk", "siloed_table"],
        "issues_not_addressed": ["denormalized_natural_key"],
        "model_stats_at_generation": {
            "domain_count": 8,
            "product_count": 47,
            "attribute_count": 523,
            "fk_count": 61,
            "unlinked_id_count": 3,
            "siloed_count": 1,
            "llm_fk_skip_count": 0,
        },
        "issue_counts": {"error": 0, "warning": 3, "info": 5, "warning_raw": 4},
        "progression": {
            "version_trend": "improved",
            "confidence_delta": 7,
            "warnings_delta": -2,
            "errors_delta": -1,
            "unlinked_delta": -2,
            "previous_version": "v1_mvm",
            "previous_confidence": 75,
            "previous_warnings": 5,
            "previous_errors": 1,
            "previous_unlinked": 5,
        },
        "version_history": [
            {
                "version": "v1_mvm",
                "confidence": 75,
                "errors": 1,
                "warnings": 5,
                "unlinked": 5,
                "trend": "baseline",
                "products": 44,
                "fks": 55,
            },
            {
                "version": "v2_mvm",
                "confidence": 82,
                "errors": 0,
                "warnings": 3,
                "unlinked": 3,
                "trend": "improved",
                "products": 47,
                "fks": 61,
            },
        ],
        "ai_usage": {
            "total_ai_calls": 120,
            "estimated_input_tokens": 450000,
            "estimated_output_tokens": 90000,
            "total_input_chars": 1800000,
            "total_output_chars": 360000,
            "estimated_total_cost_usd": 4.27,
            "per_model_cost_usd": {"databricks-claude-3-7-sonnet": 4.27},
        },
    }


def _baseline_ecm_metadata() -> dict:
    """A first-version ECM run: the agent runs no quality judge (confidence 0)
    and there's no predecessor (trend "baseline", zero deltas, single-entry
    history)."""
    return {
        "generated_from_version": "v1_ecm",
        "target_model_version": "2",
        "duration_hours": 0.5,
        "status": "unknown",
        "confidence_score": 0,
        "summary": "",
        "issues_addressed": [],
        "issues_not_addressed": [],
        "model_stats_at_generation": {
            "domain_count": 12,
            "product_count": 95,
            "attribute_count": 1200,
            "fk_count": 130,
            "unlinked_id_count": 0,
            "siloed_count": 0,
            "llm_fk_skip_count": 0,
        },
        "issue_counts": {"error": 0, "warning": 0, "info": 0, "warning_raw": 0},
        "progression": {
            "version_trend": "baseline",
            "confidence_delta": 0,
            "warnings_delta": 0,
            "errors_delta": 0,
            "unlinked_delta": 0,
            "previous_version": "unknown",
            "previous_confidence": 0,
            "previous_warnings": 0,
            "previous_errors": 0,
            "previous_unlinked": 0,
        },
        "version_history": [
            {
                "version": "v1_ecm",
                "confidence": 0,
                "errors": 0,
                "warnings": 0,
                "unlinked": 0,
                "trend": "baseline",
                "products": 95,
                "fks": 130,
            }
        ],
        "ai_usage": {
            "total_ai_calls": 200,
            "estimated_input_tokens": 800000,
            "estimated_output_tokens": 150000,
            "estimated_total_cost_usd": 7.5,
            "per_model_cost_usd": {"databricks-claude-3-7-sonnet": 7.5},
        },
    }


def _model_structure() -> dict:
    """A tiny model-structure dict (the inner ``model`` block) for size
    fallback tests: 1 domain, 2 products, 3 attributes, 1 FK."""
    return {
        "domains": [
            {
                "name": "sales",
                "products": [
                    {
                        "name": "orders",
                        "attributes": [
                            {"name": "order_id"},
                            {"name": "customer_id", "foreign_key_to": "sales.customers.customer_id"},
                        ],
                    },
                    {
                        "name": "customers",
                        "attributes": [{"name": "customer_id"}],
                    },
                ],
            }
        ]
    }


# ---------------------------------------------------------------------------
# Helper: full mapping (iterated MVM)
# ---------------------------------------------------------------------------


class TestIteratedMapping:
    def test_flags(self):
        m = evo.compute_metrics(_iterated_mvm_metadata(), _model_structure(), agent_version="v0.9.8")
        assert m.has_metadata is True
        assert m.has_confidence is True
        assert m.has_predecessor is True

    def test_size_uses_agent_stats(self):
        m = evo.compute_metrics(_iterated_mvm_metadata(), _model_structure())
        assert m.size.domain_count == 8
        assert m.size.product_count == 47
        assert m.size.attribute_count == 523
        assert m.size.fk_count == 61
        assert m.size.unlinked_id_count == 3
        assert m.size.siloed_count == 1
        # Rounded to 1 decimal at the source so every consumer (Statistics
        # Size, Excel export) renders a clean figure (finding #2).
        assert m.size.avg_attributes_per_product == round(523 / 47, 1)

    def test_avg_attrs_rounds_to_one_decimal(self):
        # 161 / 4 = 40.25 → 40.2 (banker's rounding via round()); the raw IEEE
        # float must never reach the wire (finding #2).
        assert evo._avg_attrs(4, 161) == 40.2
        assert evo._avg_attrs(47, 523) == round(523 / 47, 1)
        assert evo._avg_attrs(0, 10) is None
        assert evo._avg_attrs(5, None) is None

    def test_quality(self):
        m = evo.compute_metrics(_iterated_mvm_metadata(), None)
        assert m.quality.confidence_score == 82
        assert m.quality.error_count == 0
        assert m.quality.warning_count == 3
        assert m.quality.info_count == 5
        assert m.quality.issues_addressed == ["unlinked_fk", "siloed_table"]
        assert m.quality.issues_not_addressed == ["denormalized_natural_key"]

    def test_change_deltas_and_history(self):
        m = evo.compute_metrics(_iterated_mvm_metadata(), None)
        assert m.change.version_trend == "improved"
        assert m.change.confidence_delta == 7
        assert m.change.warnings_delta == -2
        assert m.change.errors_delta == -1
        assert m.change.unlinked_delta == -2
        assert m.change.previous_confidence == 75
        assert m.change.previous_warnings == 5
        assert m.change.previous_errors == 1
        assert m.change.previous_unlinked == 5
        assert len(m.change.version_history) == 2
        last = m.change.version_history[-1]
        assert last.version == "v2_mvm"
        assert last.confidence == 82
        assert last.products == 47
        assert last.fks == 61
        assert last.trend == "improved"

    def test_effort(self):
        m = evo.compute_metrics(_iterated_mvm_metadata(), None)
        assert m.effort.total_ai_calls == 120
        assert m.effort.estimated_input_tokens == 450000
        assert m.effort.estimated_output_tokens == 90000
        assert m.effort.estimated_total_cost_usd == pytest.approx(4.27)
        assert m.effort.per_model_cost_usd == {"databricks-claude-3-7-sonnet": 4.27}
        assert m.effort.duration_hours == pytest.approx(0.3)

    def test_provenance(self):
        m = evo.compute_metrics(_iterated_mvm_metadata(), None, agent_version="v0.9.8")
        assert m.provenance.agent_version == "v0.9.8"
        assert m.provenance.generated_from_version == "v2_mvm"
        assert m.provenance.target_model_version == "3"
        assert m.provenance.status == "needs_work"


# ---------------------------------------------------------------------------
# Degradation: baseline ECM
# ---------------------------------------------------------------------------


class TestBaselineEcmDegradation:
    def test_no_confidence(self):
        """ECM emits confidence_score=0 (judge didn't run). Must surface as
        None — never a real 0 — with has_confidence=False."""
        m = evo.compute_metrics(_baseline_ecm_metadata(), None)
        assert m.quality.confidence_score is None
        assert m.has_confidence is False

    def test_no_predecessor(self):
        """Baseline trend + single-entry history ⇒ no predecessor. Deltas and
        previous_* are null (not 0)."""
        m = evo.compute_metrics(_baseline_ecm_metadata(), None)
        assert m.has_predecessor is False
        assert m.change.version_trend == "baseline"
        assert m.change.confidence_delta is None
        assert m.change.warnings_delta is None
        assert m.change.errors_delta is None
        assert m.change.previous_confidence is None
        assert m.change.previous_warnings is None
        # The single-entry history still surfaces (for a degenerate sparkline).
        assert len(m.change.version_history) == 1
        assert m.change.version_history[0].version == "v1_ecm"

    def test_size_still_populated(self):
        m = evo.compute_metrics(_baseline_ecm_metadata(), None)
        assert m.has_metadata is True
        assert m.size.product_count == 95
        assert m.size.fk_count == 130

    def test_effort_present_even_without_confidence(self):
        m = evo.compute_metrics(_baseline_ecm_metadata(), None)
        assert m.effort.total_ai_calls == 200
        assert m.effort.estimated_total_cost_usd == pytest.approx(7.5)


# ---------------------------------------------------------------------------
# Degradation: no metadata at all
# ---------------------------------------------------------------------------


class TestNoMetadataDegradation:
    def test_size_falls_back_to_structure(self):
        m = evo.compute_metrics(None, _model_structure(), agent_version="v0.9.8")
        assert m.has_metadata is False
        assert m.has_confidence is False
        assert m.has_predecessor is False
        assert m.size.domain_count == 1
        assert m.size.product_count == 2
        assert m.size.attribute_count == 3
        assert m.size.fk_count == 1
        assert m.size.avg_attributes_per_product == round(3 / 2, 1)
        # Static-analysis-only counts are NOT fabricated from structure.
        assert m.size.unlinked_id_count is None
        assert m.size.siloed_count is None
        # agent_version survives even without metadata.
        assert m.provenance.agent_version == "v0.9.8"

    def test_no_metadata_no_model(self):
        m = evo.compute_metrics(None, None)
        assert m.has_metadata is False
        assert m.size.product_count is None
        assert m.size.avg_attributes_per_product is None
        assert m.change.version_history == []

    def test_missing_agent_stats_uses_structure(self):
        """Metadata present but no model_stats_at_generation block ⇒ size from
        structure, has_metadata still True."""
        meta = _iterated_mvm_metadata()
        del meta["model_stats_at_generation"]
        m = evo.compute_metrics(meta, _model_structure())
        assert m.has_metadata is True
        assert m.size.product_count == 2  # structure-derived
        assert m.size.fk_count == 1


class TestPartialHistoryPredecessor:
    def test_predecessor_via_history_when_trend_missing(self):
        """Older files may not stamp version_trend; a >1-entry history is the
        fallback predecessor signal."""
        meta = _iterated_mvm_metadata()
        del meta["progression"]["version_trend"]
        m = evo.compute_metrics(meta, None)
        assert m.has_predecessor is True


# ---------------------------------------------------------------------------
# Endpoint
# ---------------------------------------------------------------------------


@pytest.fixture
def model(engine):
    """Business + completed v1 MVM with one domain/product/attribute."""
    with Session(engine) as s:
        b = Business(name="Acme")
        s.add(b)
        s.commit()
        mv = ModelVersion(business_id=b.id, version=1, status="completed", scope="mvm")
        s.add(mv)
        s.commit()
        d = Domain(version_id=mv.id, name="sales")
        s.add(d)
        s.commit()
        p = Product(version_id=mv.id, domain_id=d.id, name="orders")
        s.add(p)
        s.commit()
        s.add(Attribute(product_id=p.id, name="order_id"))
        s.commit()
        return {"bid": b.id, "vid": mv.id}


_EXPECTED_TOP = {
    "version_id", "size", "quality", "change", "effort", "provenance",
    "has_metadata", "has_confidence", "has_predecessor",
}


def test_endpoint_iterated(client, engine, model, monkeypatch):
    """Endpoint reads the Volume envelope on demand and maps the iterated
    case. The envelope loader is monkeypatched (no real Volume in unit tests)."""
    envelope = {
        "agent_version": "v0.9.8",
        "_vibe_session_metadata": _iterated_mvm_metadata(),
        "model": _model_structure(),
    }
    monkeypatch.setattr(
        explorer, "_load_model_json_envelope", lambda *a, **k: envelope
    )
    r = client.get(f"/api/businesses/{model['bid']}/versions/1/mvm/evolution-metrics")
    assert r.status_code == 200, r.text
    body = r.json()
    assert set(body.keys()) == _EXPECTED_TOP
    assert body["version_id"] == model["vid"]
    assert body["has_metadata"] is True
    assert body["has_confidence"] is True
    assert body["has_predecessor"] is True
    assert body["size"]["product_count"] == 47
    assert body["quality"]["confidence_score"] == 82
    assert body["change"]["version_trend"] == "improved"
    assert body["change"]["confidence_delta"] == 7
    assert len(body["change"]["version_history"]) == 2
    assert body["effort"]["total_ai_calls"] == 120
    assert body["provenance"]["agent_version"] == "v0.9.8"


def test_endpoint_baseline_ecm_degraded(client, engine, monkeypatch):
    with Session(engine) as s:
        b = Business(name="EcmCorp")
        s.add(b)
        s.commit()
        mv = ModelVersion(business_id=b.id, version=1, status="completed", scope="ecm")
        s.add(mv)
        s.commit()
        bid = b.id
    envelope = {
        "agent_version": "v0.9.8",
        "_vibe_session_metadata": _baseline_ecm_metadata(),
        "model": {"domains": []},
    }
    monkeypatch.setattr(
        explorer, "_load_model_json_envelope", lambda *a, **k: envelope
    )
    r = client.get(f"/api/businesses/{bid}/versions/1/ecm/evolution-metrics")
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["has_confidence"] is False
    assert body["quality"]["confidence_score"] is None
    assert body["has_predecessor"] is False
    assert body["change"]["version_trend"] == "baseline"
    assert body["change"]["confidence_delta"] is None


def test_endpoint_no_volume_falls_back_to_lakebase(client, engine, model, monkeypatch):
    """No Volume artifact ⇒ envelope None ⇒ size degrades to the
    Lakebase-reconstructed structure with has_metadata=False."""
    monkeypatch.setattr(
        explorer, "_load_model_json_envelope", lambda *a, **k: None
    )
    r = client.get(f"/api/businesses/{model['bid']}/versions/1/mvm/evolution-metrics")
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["has_metadata"] is False
    # Lakebase has 1 domain / 1 product / 1 attribute for this version.
    assert body["size"]["domain_count"] == 1
    assert body["size"]["product_count"] == 1
    assert body["size"]["attribute_count"] == 1


def test_endpoint_unknown_version_404(client, model):
    r = client.get(f"/api/businesses/{model['bid']}/versions/99/mvm/evolution-metrics")
    assert r.status_code == 404


# ---------------------------------------------------------------------------
# Structural predecessor lights up Change even when the agent metadata is
# baseline / missing a trend (regression: F8 — the whole Change/Evolution
# feature went dead because the endpoint AND-gated has_predecessor on the
# unreliable agent ``version_trend`` instead of treating a real version N-1
# as a predecessor).
# ---------------------------------------------------------------------------


@pytest.fixture
def two_versions(engine):
    """Business with a v1 + v2 MVM, each carrying Lakebase structure rows so
    ``_load_model`` / ``_load_prev_model`` resolve a real structural
    predecessor for v2. v2 adds a product vs v1 so the diff is non-empty."""
    with Session(engine) as s:
        b = Business(name="Evolve")
        s.add(b)
        s.commit()
        v1 = ModelVersion(business_id=b.id, version=1, status="completed", scope="mvm")
        s.add(v1)
        s.commit()
        d1 = Domain(version_id=v1.id, name="sales")
        s.add(d1)
        s.commit()
        p1 = Product(version_id=v1.id, domain_id=d1.id, name="orders")
        s.add(p1)
        s.commit()
        s.add(Attribute(product_id=p1.id, name="order_id"))
        s.commit()

        v2 = ModelVersion(
            business_id=b.id,
            version=2,
            status="completed",
            scope="mvm",
            base_version_id=v1.id,
        )
        s.add(v2)
        s.commit()
        d2 = Domain(version_id=v2.id, name="sales")
        s.add(d2)
        s.commit()
        p2a = Product(version_id=v2.id, domain_id=d2.id, name="orders")
        p2b = Product(version_id=v2.id, domain_id=d2.id, name="invoices")  # added in v2
        s.add(p2a)
        s.add(p2b)
        s.commit()
        s.add(Attribute(product_id=p2a.id, name="order_id"))
        s.add(Attribute(product_id=p2b.id, name="invoice_id"))
        s.commit()
        return {"bid": b.id, "v1": v1.id, "v2": v2.id}


def test_endpoint_structural_predecessor_lights_up_change(
    client, engine, two_versions, monkeypatch
):
    """A v2 with a real structural predecessor (v1) must report
    ``has_predecessor=True`` and a computed ``model_touched_pct`` even when the
    agent's ``_vibe_session_metadata`` is baseline / carries no usable trend.

    This is the F8 regression: vibed v2 models had a real v1 but the Change
    feature collapsed because the endpoint trusted only the agent trend."""
    envelope = {
        "agent_version": "v0.9.8",
        # Agent metadata claims baseline (no usable predecessor signal) — the
        # unreliable case the docstring warns about.
        "_vibe_session_metadata": _baseline_ecm_metadata(),
        "model": {"domains": []},
    }
    monkeypatch.setattr(
        explorer, "_load_model_json_envelope", lambda *a, **k: envelope
    )
    r = client.get(
        f"/api/businesses/{two_versions['bid']}/versions/2/mvm/evolution-metrics"
    )
    assert r.status_code == 200, r.text
    body = r.json()
    # Structural predecessor exists ⇒ the Change feature is live.
    assert body["has_predecessor"] is True
    # Touched % + breakdown computed from the real v1↔v2 structure diff.
    assert body["change"]["model_touched_pct"] is not None
    assert body["change"]["products_added"] == 1  # invoices added in v2
    assert body["change"]["products_modified"] == 0
    assert body["change"]["products_removed"] == 0


def test_endpoint_v1_baseline_has_no_predecessor(
    client, engine, model, monkeypatch
):
    """A first version (no structural prev, baseline agent metadata) stays
    ``has_predecessor=False`` — the fix must not flip base versions on."""
    envelope = {
        "agent_version": "v0.9.8",
        "_vibe_session_metadata": _baseline_ecm_metadata(),
        "model": {"domains": []},
    }
    monkeypatch.setattr(
        explorer, "_load_model_json_envelope", lambda *a, **k: envelope
    )
    r = client.get(f"/api/businesses/{model['bid']}/versions/1/mvm/evolution-metrics")
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["has_predecessor"] is False
    assert body["change"]["model_touched_pct"] is None
