"""Sanitization-aware business/industry name-uniqueness guard.

The canonical ``ensure_business_name_available`` helper folds every creation
path onto ``agent_business_segment`` equality (the ``_metamodel`` key), so two
names that normalize to the same segment - differing only in case or
punctuation - are mutually exclusive even though they never clash on the raw
``Business.name`` unique constraint. These tests pin that behavior and the
409 detail object shape create/update now return (M2).
"""

from __future__ import annotations

import pytest
from sqlmodel import Session

from vibe_modeling.backend._query_helpers import (
    BusinessNameConflict,
    ensure_business_name_available,
)
from vibe_modeling.backend.db_models import Business


def _add(engine, name: str, kind: str = "business") -> Business:
    with Session(engine) as s:
        b = Business(name=name, kind=kind)
        s.add(b)
        s.commit()
        s.refresh(b)
        return b


class TestEnsureBusinessNameAvailable:
    def test_segment_collision_case_and_punctuation(self, engine):
        _add(engine, "Acme Retail")
        with Session(engine) as s:
            # Same segment via case + underscore folding.
            with pytest.raises(BusinessNameConflict):
                ensure_business_name_available(s, "acme_retail")
            # Same segment via punctuation collapse ("Acme & Co." -> "acme_co").
            _add(engine, "Acme & Co.")
        with Session(engine) as s:
            with pytest.raises(BusinessNameConflict):
                ensure_business_name_available(s, "Acme Co")

    def test_distinct_names_pass(self, engine):
        _add(engine, "Acme Retail")
        with Session(engine) as s:
            ensure_business_name_available(s, "Beta Logistics")  # no raise

    def test_exclude_id_allows_no_op_rename(self, engine):
        b = _add(engine, "Acme Retail")
        with Session(engine) as s:
            # Re-checking the same segment while excluding the owning row is a
            # legal no-op rename (e.g. "Acme Retail" -> "acme_retail").
            ensure_business_name_available(s, "acme_retail", exclude_id=b.id)

    def test_cross_kind_blocked_both_directions(self, engine):
        # Industry blocks a business with a colliding segment.
        _add(engine, "Mining Co", kind="industry")
        with Session(engine) as s:
            with pytest.raises(BusinessNameConflict):
                ensure_business_name_available(s, "mining_co")
        # ...and a business blocks a colliding industry.
        _add(engine, "Retail Group", kind="business")
        with Session(engine) as s:
            with pytest.raises(BusinessNameConflict):
                ensure_business_name_available(s, "retail_group")

    def test_conflict_carries_existing_row(self, engine):
        existing = _add(engine, "Acme Retail")
        with Session(engine) as s:
            with pytest.raises(BusinessNameConflict) as ei:
                ensure_business_name_available(s, "ACME  retail")
            assert ei.value.existing.id == existing.id
            assert ei.value.name == "ACME  retail"


class TestCreateUpdate409Shape:
    _DESC = {"description": "d"}

    def test_create_conflict_returns_object_detail(self, client):
        r1 = client.post("/api/businesses", json={"name": "Acme Retail", **self._DESC})
        assert r1.status_code == 200, r1.text
        r2 = client.post("/api/businesses", json={"name": "acme_retail", **self._DESC})
        assert r2.status_code == 409, r2.text
        detail = r2.json()["detail"]
        assert isinstance(detail, dict)
        assert detail["error"] == "business_name_taken"
        assert detail["name"] == "acme_retail"
        assert "message" in detail

    def test_update_conflict_returns_object_detail(self, client):
        client.post("/api/businesses", json={"name": "Acme Retail", **self._DESC})
        b2 = client.post(
            "/api/businesses", json={"name": "Beta Logistics", **self._DESC}
        ).json()
        r = client.put(f"/api/businesses/{b2['id']}", json={"name": "ACME retail", **self._DESC})
        assert r.status_code == 409, r.text
        detail = r.json()["detail"]
        assert detail["error"] == "business_name_taken"
        assert detail["name"] == "ACME retail"

    def test_update_no_op_rename_allowed(self, client):
        b = client.post(
            "/api/businesses", json={"name": "Acme Retail", **self._DESC}
        ).json()
        # Fold to the same segment on the SAME row - not a conflict.
        r = client.put(f"/api/businesses/{b['id']}", json={"name": "acme_retail", **self._DESC})
        assert r.status_code == 200, r.text
        assert r.json()["name"] == "acme_retail"
