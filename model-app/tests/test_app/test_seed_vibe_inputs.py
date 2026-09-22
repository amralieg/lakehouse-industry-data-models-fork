"""Tests for the fake-VibeInput seeder (``scripts/dev/seed_vibe_inputs.py``).

The seeder exists so the next_vibes-metrics work (story "Next vibes as a metric
source" + ADR D-044) can be developed against populated ``vibe_inputs`` before
the real ingestion epic lands. These tests assert it produces VibeInputs with
the correct ``origin``, element ``anchor`` (``VibeInputContextLink``), and the
structured ``category`` / ``priority`` / ``confidence_score`` fields — and that
the rows read back unchanged through the existing ``listVibeInputs`` route.

The seeder is a standalone script (not a package), so we load it via
``importlib`` from its file path — the same pattern
``test_migration_drift_owner.py`` uses for ``scripts/db/migrate.py``.
"""

import os
import sys
from pathlib import Path
from typing import Any

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from sqlmodel import Session, select

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
    VibeInputPriority,
)


_SEEDER_PATH = (
    Path(__file__).resolve().parents[2] / "scripts" / "dev" / "seed_vibe_inputs.py"
)


def _load_seeder() -> Any:
    """Load ``scripts/dev/seed_vibe_inputs.py`` without running ``main()``."""
    import importlib.util

    assert _SEEDER_PATH.exists(), (
        f"seeder not found at {_SEEDER_PATH}; it moved — update _SEEDER_PATH."
    )
    spec = importlib.util.spec_from_file_location("seed_vibe_inputs", str(_SEEDER_PATH))
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    # Register before exec so dataclass field-type resolution (which looks the
    # module up in sys.modules) works for the module-scope dataclasses.
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


seeder = _load_seeder()


# Severity each category is expected to pair with — declared HERE, independent
# of the seeder's internal table, so this is a real contract assertion (not a
# self-referential round-trip).
_EXPECTED_SEVERITY = {
    NextVibeCategory.STATIC_ANALYSIS.value: VibeInputPriority.LOW.value,
    NextVibeCategory.PRIORITY_REMEDIATION.value: VibeInputPriority.HIGH.value,
    NextVibeCategory.OTHER.value: VibeInputPriority.MEDIUM.value,
}


@pytest.fixture
def seeded_model(engine):
    """Business + completed version + 2 domains × 2 products × 2 attributes.

    Returns ``(business_id, version_id)`` so anchors exist to spread inputs
    across (domain / product / attribute levels)."""
    with Session(engine) as s:
        b = Business(name="Acme")
        s.add(b)
        s.commit()
        mv = ModelVersion(business_id=b.id, version=1, status="completed", scope="ecm")
        s.add(mv)
        s.commit()
        for di in range(2):
            d = Domain(version_id=mv.id, name=f"domain{di}")
            s.add(d)
            s.commit()
            for pi in range(2):
                p = Product(domain_id=d.id, version_id=mv.id, name=f"product{di}_{pi}")
                s.add(p)
                s.commit()
                for ai in range(2):
                    s.add(Attribute(product_id=p.id, name=f"attr{di}_{pi}_{ai}"))
                s.commit()
        return b.id, mv.id


@pytest.fixture
def seed_inputs(engine, seeded_model):
    """Reusable fixture: seed inputs and return (business_id, version_id, result).

    Other tests/dev surfaces can depend on this to get a populated
    ``vibe_inputs`` table without touching the seeder internals."""
    bid, vid = seeded_model
    with Session(engine) as s:
        result = seeder.seed_vibe_inputs(
            s, bid, vid, n_agent=10, n_user=5, quality_score=0.76
        )
    return bid, vid, result


def test_seeds_both_origins(engine, seed_inputs):
    bid, vid, result = seed_inputs
    assert len(result.agent_input_ids) == 10
    assert len(result.user_input_ids) == 5
    assert result.total == 15

    with Session(engine) as s:
        rows = s.exec(select(VibeInput).where(VibeInput.business_id == bid)).all()
        by_origin: dict[str, int] = {}
        for r in rows:
            by_origin[r.origin] = by_origin.get(r.origin, 0) + 1
        assert by_origin == {"agent_next_vibe": 10, "user": 5}


def test_every_input_has_origin_anchor_link(engine, seed_inputs):
    bid, vid, result = seed_inputs
    with Session(engine) as s:
        for iid in result.agent_input_ids + result.user_input_ids:
            links = s.exec(
                select(VibeInputContextLink).where(
                    VibeInputContextLink.input_id == iid
                )
            ).all()
            assert len(links) == 1, f"input {iid} should have exactly one origin link"
            link = links[0]
            assert link.is_origin is True
            assert link.version_id == vid


def test_anchors_spread_across_element_levels(engine, seed_inputs):
    """Inputs land on domain / product / attribute anchors, not all model-wide."""
    bid, vid, result = seed_inputs
    with Session(engine) as s:
        links = s.exec(
            select(VibeInputContextLink).where(
                VibeInputContextLink.version_id == vid
            )
        ).all()
        assert any(lk.attribute_id is not None for lk in links)
        assert any(lk.product_id is not None for lk in links)
        assert sum(1 for lk in links if lk.attribute_id is not None) >= 1


def test_agent_inputs_carry_structured_category_severity_score(engine, seed_inputs):
    """Agent inputs store a real ``category`` enum value, a severity-matched
    ``priority``, and the quality score — read straight off the column."""
    bid, vid, result = seed_inputs
    # All three categories represented across the seeded set.
    assert set(result.category_counts) == {
        NextVibeCategory.STATIC_ANALYSIS.value,
        NextVibeCategory.PRIORITY_REMEDIATION.value,
        NextVibeCategory.OTHER.value,
    }
    valid_categories = {c.value for c in NextVibeCategory}
    with Session(engine) as s:
        agents = s.exec(
            select(VibeInput).where(VibeInput.id.in_(result.agent_input_ids))
        ).all()
        for vi in agents:
            assert vi.category in valid_categories
            assert vi.priority == _EXPECTED_SEVERITY[vi.category], (
                f"category {vi.category!r} should pair with severity "
                f"{_EXPECTED_SEVERITY[vi.category]}, got {vi.priority}"
            )
            assert vi.confidence_score == 0.76
            # Plain-text description, no fabricated prefix tokens.
            assert not vi.text.startswith(("[SA]", "PRIORITY", "Other known issue"))


def test_user_inputs_are_annotation_signal(engine, seed_inputs):
    bid, vid, result = seed_inputs
    with Session(engine) as s:
        users = s.exec(
            select(VibeInput).where(VibeInput.id.in_(result.user_input_ids))
        ).all()
        for vi in users:
            assert vi.origin == "user"
            assert vi.author  # user inputs are attributed
            assert vi.confidence_score is None  # no quality score on user inputs
            assert vi.category is None  # feedback carries no category


def test_reads_back_via_list_endpoint(client, engine, seeded_model):
    """The durable rows surface through the existing listVibeInputs route with
    origin + category + hydrated element anchor — the same path T13 reads."""
    bid, vid = seeded_model
    with Session(engine) as s:
        seeder.seed_vibe_inputs(s, bid, vid, n_agent=6, n_user=3)

    resp = client.get(f"/api/businesses/{bid}/inputs?version_id={vid}")
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert len(body) == 9

    origins = {row["origin"] for row in body}
    assert origins == {"agent_next_vibe", "user"}

    # Every listed input has a hydrated anchor on the queried version.
    for row in body:
        assert row["anchor"] is not None, row
        assert row["anchor"]["level"] in ("element", "model_wide")

    valid_categories = {c.value for c in NextVibeCategory}
    agent_rows = [r for r in body if r["origin"] == "agent_next_vibe"]
    user_rows = [r for r in body if r["origin"] == "user"]
    assert agent_rows and user_rows
    for r in agent_rows:
        # Structured category surfaces on the wire, matched to severity + score.
        assert r["category"] in valid_categories
        assert r["priority"] == _EXPECTED_SEVERITY[r["category"]]
        assert r["confidence_score"] == 0.76
    for r in user_rows:
        assert r["category"] is None
        assert r["confidence_score"] is None


def test_filter_by_origin_via_list_endpoint(client, engine, seeded_model):
    bid, vid = seeded_model
    with Session(engine) as s:
        seeder.seed_vibe_inputs(s, bid, vid, n_agent=4, n_user=2)

    resp = client.get(f"/api/businesses/{bid}/inputs?origin=agent_next_vibe")
    assert resp.status_code == 200, resp.text
    rows = resp.json()
    assert len(rows) == 4
    assert all(r["origin"] == "agent_next_vibe" for r in rows)
    assert all(r["category"] is not None for r in rows)


def test_missing_version_raises(engine, seeded_model):
    bid, _vid = seeded_model
    with Session(engine) as s:
        with pytest.raises(ValueError):
            seeder.seed_vibe_inputs(s, bid, "nonexistent-version-id")
