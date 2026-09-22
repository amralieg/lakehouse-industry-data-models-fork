"""Tests for model_export — reconstructing a model.json bundle from the
Lakebase version rows (the inverse of ModelSyncService.sync_from_model_json).

The round-trip invariant is the spine: a model.json synced into Lakebase via
``sync_from_model_json`` and then re-exported via ``export_model_json`` must
reproduce the same domain / product / attribute / FK structure. If the two
ever drift, an exported bundle would re-import into a different model.
"""

from __future__ import annotations

import pytest
from sqlmodel import Session

from vibe_modeling.backend.db_models import (
    Business,
    ModelVersion,
)
from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend import model_export


# ``engine`` (in-memory SQLite with all tables) + ``client`` come from
# tests/test_app/conftest.py so route tests share the same engine the API
# session override binds to.


# A small but representative model.json in the agent envelope shape that
# ``import_model.detect_schema`` accepts and ``sync_from_model_json`` consumes.
SAMPLE_MODEL = {
    "type": "business",
    "name": "Test Retail",
    "version": "v2_ecm",
    "description": "A retail demo model.",
    "domains": [
        {
            "name": "sales",
            "division": "Commercial",
            "description": "Sales domain.",
            "products": [
                {
                    "product": "order",
                    "description": "Customer orders.",
                    "type": "fact",
                    "primary_key": "order_id",
                    "tags": "core,transactional",
                    "attributes": [
                        {
                            "attribute": "order_id",
                            "type": "bigint",
                            "description": "PK.",
                            "tags": "id",
                        },
                        {
                            "attribute": "customer_id",
                            "type": "bigint",
                            "description": "FK to customer.",
                            "foreign_key_to": "customer.profile.customer_id",
                            "tags": "fk",
                        },
                    ],
                },
            ],
        },
        {
            "name": "customer",
            "division": "Commercial",
            "description": "Customer domain.",
            "products": [
                {
                    "product": "profile",
                    "description": "Customer profiles.",
                    "type": "dimension",
                    "primary_key": "customer_id",
                    "attributes": [
                        {
                            "attribute": "customer_id",
                            "type": "bigint",
                            "description": "PK.",
                        },
                    ],
                },
            ],
        },
    ],
}


def _seed_version(engine) -> tuple[str, str]:
    """Seed a Business + ModelVersion and sync SAMPLE_MODEL into Lakebase.

    Returns (business_id, version_id).
    """
    with Session(engine) as session:
        biz = Business(
            name="Test Retail",
            industry_alignment="Retail",
            description="A retail demo model.",
        )
        session.add(biz)
        session.flush()
        mv = ModelVersion(
            business_id=biz.id,
            version=2,
            scope="ecm",
            status="completed",
        )
        session.add(mv)
        session.flush()
        svc = ModelSyncService(session)
        svc.sync_from_model_json(mv.id, SAMPLE_MODEL)
        session.commit()
        return biz.id, mv.id


def test_export_roundtrips_structure(engine):
    business_id, version_id = _seed_version(engine)
    with Session(engine) as session:
        exported = model_export.export_model_json(session, version_id)

    # Envelope must carry an unwrappable ``model`` dict the importer accepts.
    assert isinstance(exported, dict)
    model = exported["model"] if "model" in exported else exported

    assert model["type"] == "business"
    assert model["name"] == "Test Retail"
    assert model["version"] == "v2_ecm"

    domains = {d["name"]: d for d in model["domains"]}
    assert set(domains) == {"sales", "customer"}
    assert domains["sales"]["division"] == "Commercial"
    assert domains["sales"]["description"] == "Sales domain."

    products = {p["product"]: p for p in domains["sales"]["products"]}
    assert "order" in products
    order = products["order"]
    assert order["primary_key"] == "order_id"
    assert order["type"] == "fact"

    attrs = {a["attribute"]: a for a in order["attributes"]}
    assert set(attrs) == {"order_id", "customer_id"}
    assert attrs["order_id"]["primary_key"] is True
    assert attrs["customer_id"]["foreign_key_to"] == "customer.profile.customer_id"
    assert attrs["order_id"]["foreign_key_to"] == ""


def test_export_reimports_identically(engine):
    """Export → re-sync into a fresh version → structure matches."""
    business_id, version_id = _seed_version(engine)
    with Session(engine) as session:
        exported = model_export.export_model_json(session, version_id)

        biz = session.get(Business, business_id)
        mv2 = ModelVersion(
            business_id=biz.id, version=3, scope="ecm", status="completed"
        )
        session.add(mv2)
        session.flush()
        svc = ModelSyncService(session)
        svc.sync_from_model_json(mv2.id, exported)
        session.commit()

        # Re-export the re-imported version; the two exports must be equal
        # on structure (the inverse round-trip is stable).
        re_exported = model_export.export_model_json(session, mv2.id)

    def _structure(env: dict) -> list:
        m = env["model"] if "model" in env else env
        out = []
        for d in sorted(m["domains"], key=lambda x: x["name"]):
            for p in sorted(d.get("products", []), key=lambda x: x["product"]):
                for a in sorted(p.get("attributes", []), key=lambda x: x["attribute"]):
                    out.append(
                        (
                            d["name"], p["product"], a["attribute"],
                            a.get("type", ""), a.get("foreign_key_to", ""),
                            a.get("primary_key", False),
                        )
                    )
        return out

    assert _structure(exported) == _structure(re_exported)


def test_export_missing_version_raises(engine):
    with Session(engine) as session:
        with pytest.raises(LookupError):
            model_export.export_model_json(session, "does-not-exist")


def test_bundle_layout_descriptor():
    """The on-disk bundle layout is a single code-level descriptor:
    ``<industry>/v{N}/<scope>/`` (nested, agent 4.9.8+)."""
    layout = model_export.bundle_layout("Retail Industry", "ecm", 2)
    assert layout.dir == "retail_industry/v2/ecm"
    assert layout.model_json_path == "retail_industry/v2/ecm/model.json"


def test_build_bundle_zip_places_model_json(engine):
    """The zip bundle carries model.json at the layout path."""
    import io
    import json
    import zipfile
    from unittest.mock import MagicMock

    _business_id, version_id = _seed_version(engine)
    with Session(engine) as session:
        model_json = model_export.export_model_json(session, version_id)
    layout = model_export.bundle_layout("retail", "ecm", 2)
    body = model_export.build_bundle_zip_bytes(MagicMock(), layout, model_json, [])

    with zipfile.ZipFile(io.BytesIO(body)) as zf:
        names = zf.namelist()
        assert "retail/v2/ecm/model.json" in names
        parsed = json.loads(zf.read("retail/v2/ecm/model.json"))
        assert parsed["model"]["name"] == "Test Retail"


def test_export_endpoint_returns_model_json(client, engine):
    """The export route reconstructs the model.json for a synced version."""
    with Session(engine) as session:
        biz = Business(name="Retail Co", industry_alignment="Retail", description="d")
        session.add(biz)
        session.flush()
        mv = ModelVersion(business_id=biz.id, version=1, scope="ecm", status="completed")
        session.add(mv)
        session.flush()
        ModelSyncService(session).sync_from_model_json(mv.id, SAMPLE_MODEL)
        session.commit()
        bid, vid = biz.id, mv.id

    resp = client.get(
        f"/api/businesses/{bid}/model-versions/{vid}/export"
    )
    assert resp.status_code == 200, resp.text
    payload = resp.json()
    assert payload["model"]["type"] == "business"
    assert payload["model"]["version"] == "v1_ecm"

    # Wrong business id is a 404 (tenancy gate).
    resp404 = client.get(
        f"/api/businesses/not-the-owner/model-versions/{vid}/export"
    )
    assert resp404.status_code == 404

    # Bundle endpoint streams a zip carrying model.json at the layout path.
    import io
    import zipfile

    rbundle = client.get(
        f"/api/businesses/{bid}/model-versions/{vid}/export/bundle"
    )
    assert rbundle.status_code == 200, rbundle.text
    assert rbundle.headers["content-type"] == "application/zip"
    # The bundle root is derived via resolve_bundle_root (ADR D-049): with no
    # source_repo_path it falls back to the business NAME ("Retail Co" ->
    # "retail_co"), NOT industry_alignment ("Retail"), which is now dead here.
    with zipfile.ZipFile(io.BytesIO(rbundle.content)) as zf:
        assert "retail_co/v1/ecm/model.json" in zf.namelist()


# ---------------------------------------------------------------------------
# Query-count regression: export_model_json must be a small constant number
# of round trips regardless of domain/product/attribute count, not a
# per-domain-then-per-product lazy-load loop.
# ---------------------------------------------------------------------------

def _count_statements(engine, fn):
    """Run ``fn()`` and count DB statements ``engine`` executes meanwhile."""
    from sqlalchemy import event

    count = 0

    def _before_cursor_execute(*_args, **_kwargs):
        nonlocal count
        count += 1

    event.listen(engine, "before_cursor_execute", _before_cursor_execute)
    try:
        fn()
    finally:
        event.remove(engine, "before_cursor_execute", _before_cursor_execute)
    return count


def _model_with_n_domains(n: int) -> dict:
    """Build a flat model.json with ``n`` domains, each with 2 products of 2
    attributes, so export must group across a real domain/product spread."""
    domains = []
    for i in range(n):
        domains.append({
            "name": f"domain_{i}",
            "division": "",
            "description": "",
            "products": [
                {
                    "product": f"product_{i}_{j}",
                    "primary_key": "id",
                    "attributes": [
                        {"attribute": "id", "type": "string", "primary_key": True},
                        {"attribute": "name", "type": "string"},
                    ],
                }
                for j in range(2)
            ],
        })
    return {"domains": domains}


def _export_with_n_domains(engine, n: int) -> int:
    """Seed a fresh version with ``n`` domains and return the statement count
    ``export_model_json`` issues exporting it."""
    with Session(engine) as session:
        biz = Business(name=f"Export Query Count Co {n}")
        session.add(biz)
        session.flush()
        mv = ModelVersion(business_id=biz.id, version=1, scope="ecm", status="completed")
        session.add(mv)
        session.flush()
        ModelSyncService(session).sync_from_model_json(mv.id, _model_with_n_domains(n))
        session.commit()
        version_id = mv.id

    with Session(engine) as session:
        count = _count_statements(
            engine, lambda: model_export.export_model_json(session, version_id)
        )
    return count


def test_export_query_count_is_bounded_not_per_domain(engine):
    """Exporting N domains (each with products/attributes) must issue the
    same number of statements regardless of N - one select per element table
    (domains/products/attributes) plus the ModelVersion/Business point reads,
    not one select per domain plus one per product. A regression back to the
    per-domain-then-per-product lazy-load loop would show up here as growth
    between the 1-domain and 6-domain runs.
    """
    count_1 = _export_with_n_domains(engine, 1)
    count_6 = _export_with_n_domains(engine, 6)
    assert count_6 == count_1, (
        f"export statement count grew with domain count: {count_1} -> {count_6} "
        "(should stay O(1), not O(domains))"
    )
