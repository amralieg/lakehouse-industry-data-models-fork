"""Adversarial audit of the Track D export surface (commit 387fabc).

Written by an INDEPENDENT skeptical tester — distrusts the implementation.
Targets:
  * backend/model_export.py (export_model_json, bundle_layout/BundleLayout,
    build_bundle_zip_bytes)
  * the export GETs on routes/versions.py
  * shared backend/_artifact_io.write_artifacts_to_zip

THE critical contract: export_model_json -> sync_from_model_json -> re-export
must preserve every field on non-trivial models. These tests push hard on
fields the happy-path test never exercises (tags / value_regex / glossary,
composite-ish PKs, cross-domain FKs, subdomains, empty domains, attribute-less
products, unicode, special chars), plus zip-dedupe / tenancy / lookup edges.
"""

from __future__ import annotations

import io
import json
import zipfile
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    Domain,
    ForeignKeyLink,
    ModelVersion,
    Product,
    RunArtifact,
)
from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend import model_export
from vibe_modeling.backend._artifact_io import write_artifacts_to_zip


# ---------------------------------------------------------------------------
# A deliberately nasty model: multiple domains, cross-domain 3-part FKs and a
# 2-part FK, full attribute metadata (tags / value_regex / glossary), a
# subdomain, an empty domain, a product with no attributes, unicode + special
# chars in names and descriptions.
# ---------------------------------------------------------------------------

NASTY_MODEL = {
    "type": "business",
    "name": "Nâsty Rétail © Inc.",
    "version": "v5_ecm",
    "description": 'Has "quotes", commas, and ünicode — plus a newline\nhere.',
    "domains": [
        {
            "name": "salés",
            "division": "Commercial & Ops",
            "description": "Sales — with em-dash and 'apostrophes'.",
            "database_name": "sales_db",
            "references": "ref://sales",
            "products": [
                {
                    "product": "order_líne",
                    "table_name": "fact_order_line",
                    "description": "Order lines, 100% complete.",
                    "type": "fact",
                    "data_type": "transactional",
                    "primary_key": "order_line_id",
                    "subdomain": "fulfillment",
                    "reference": "ref://order_line",
                    "attributes": [
                        {
                            "attribute": "order_line_id",
                            "column_name": "order_line_id",
                            "type": "bigint",
                            "description": "PK — surrogate key.",
                            "business_glossary_term": "Order Line Identifier",
                            "tags": "id,core",
                            "value_regex": r"^\d+$",
                        },
                        {
                            "attribute": "customer_id",
                            "column_name": "cust_id",
                            "type": "bigint",
                            "description": "FK across domains.",
                            "business_glossary_term": "Customer",
                            "tags": "fk,dimension",
                            "value_regex": "",
                            "foreign_key_to": "customér.profile.customer_id",
                        },
                        {
                            "attribute": "promo_code",
                            "column_name": "promo_code",
                            "type": "string",
                            "description": "2-part FK (no domain prefix).",
                            "tags": "fk",
                            "value_regex": r"^[A-Z]{2,8}$",
                            "foreign_key_to": "promotion.promo_code",
                        },
                    ],
                },
                {
                    # Product with NO attributes.
                    "product": "empty_product",
                    "description": "Has zero attributes.",
                    "type": "fact",
                    "primary_key": "",
                    "attributes": [],
                },
            ],
        },
        {
            "name": "customér",
            "division": "Commercial",
            "description": "Customer domain (unicode é).",
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
                            "tags": "id",
                            "value_regex": "",
                        },
                    ],
                },
            ],
        },
        {
            # EMPTY domain — zero products.
            "name": "empty_domain",
            "division": "",
            "description": "No products here.",
            "products": [],
        },
    ],
}


def _seed(engine, model: dict, *, version: int = 5, scope: str = "ecm"):
    """Seed Business + ModelVersion + sync `model`. Returns (biz_id, ver_id)."""
    with Session(engine) as session:
        biz = Business(
            name=model.get("name", "biz"),
            industry_alignment="Retail",
            description=model.get("description", ""),
        )
        session.add(biz)
        session.flush()
        mv = ModelVersion(
            business_id=biz.id, version=version, scope=scope, status="completed"
        )
        session.add(mv)
        session.flush()
        ModelSyncService(session).sync_from_model_json(mv.id, model)
        session.commit()
        return biz.id, mv.id


# ---------------------------------------------------------------------------
# 1. THE round-trip contract: full field preservation on a nasty model.
# ---------------------------------------------------------------------------

def _index(env: dict) -> dict:
    m = env["model"] if "model" in env else env
    out = {}
    for d in m["domains"]:
        for p in d.get("products", []):
            for a in p.get("attributes", []):
                out[(d["name"], p["product"], a["attribute"])] = a
    return out


def test_attribute_metadata_survives_full_roundtrip(engine):
    """tags / value_regex / business_glossary_term / column_name / type /
    description / foreign_key_to / primary_key on every attribute must survive
    export -> re-sync -> re-export unchanged."""
    biz_id, ver_id = _seed(engine, NASTY_MODEL)
    with Session(engine) as session:
        exported = model_export.export_model_json(session, ver_id)

        mv2 = ModelVersion(
            business_id=biz_id, version=6, scope="ecm", status="completed"
        )
        session.add(mv2)
        session.flush()
        ModelSyncService(session).sync_from_model_json(mv2.id, exported)
        session.commit()
        re_exported = model_export.export_model_json(session, mv2.id)

    a1 = _index(exported)
    a2 = _index(re_exported)
    assert set(a1) == set(a2), "attribute set changed across round-trip"

    fields = (
        "column_name", "type", "description", "business_glossary_term",
        "tags", "value_regex", "foreign_key_to", "references", "primary_key",
    )
    for key in a1:
        for f in fields:
            assert a1[key].get(f) == a2[key].get(f), (
                f"attribute {key} field {f!r} drifted: "
                f"{a1[key].get(f)!r} -> {a2[key].get(f)!r}"
            )


def test_cross_domain_fk_link_rows_roundtrip(engine):
    """The 3-part cross-domain FK must produce a ForeignKeyLink row on the
    re-synced version (not just survive on the attribute string)."""
    biz_id, ver_id = _seed(engine, NASTY_MODEL)
    with Session(engine) as session:
        exported = model_export.export_model_json(session, ver_id)
        mv2 = ModelVersion(
            business_id=biz_id, version=7, scope="ecm", status="completed"
        )
        session.add(mv2)
        session.flush()
        ModelSyncService(session).sync_from_model_json(mv2.id, exported)
        session.commit()

        links = session.exec(
            select(ForeignKeyLink).where(ForeignKeyLink.version_id == mv2.id)
        ).all()
        triples = {
            (l.source_domain, l.source_product, l.source_column,
             l.target_domain, l.target_product, l.target_column)
            for l in links
        }
    assert (
        "salés", "order_líne", "customer_id",
        "customér", "profile", "customer_id",
    ) in triples


def test_empty_domain_and_attributeless_product_survive(engine):
    """An empty domain (no products) and a product with zero attributes must
    both survive the round-trip — not get pruned."""
    biz_id, ver_id = _seed(engine, NASTY_MODEL)
    with Session(engine) as session:
        exported = model_export.export_model_json(session, ver_id)
    m = exported["model"]
    by_name = {d["name"]: d for d in m["domains"]}
    assert "empty_domain" in by_name, "empty domain dropped on export"
    assert by_name["empty_domain"]["products"] == []

    sales = by_name["salés"]
    prods = {p["product"]: p for p in sales["products"]}
    assert "empty_product" in prods, "attribute-less product dropped"
    assert prods["empty_product"]["attributes"] == []


def test_subdomain_survives_roundtrip(engine):
    """Product.subdomain must round-trip (export emits it, sync re-reads it)."""
    biz_id, ver_id = _seed(engine, NASTY_MODEL)
    with Session(engine) as session:
        exported = model_export.export_model_json(session, ver_id)
        mv2 = ModelVersion(
            business_id=biz_id, version=8, scope="ecm", status="completed"
        )
        session.add(mv2)
        session.flush()
        ModelSyncService(session).sync_from_model_json(mv2.id, exported)
        session.commit()
        prod = session.exec(
            select(Product).where(
                Product.version_id == mv2.id, Product.name == "order_líne"
            )
        ).first()
    assert prod is not None
    assert prod.subdomain == "fulfillment"


def test_unicode_and_special_chars_preserved(engine):
    """Unicode + quotes/commas/newlines in names and descriptions survive."""
    biz_id, ver_id = _seed(engine, NASTY_MODEL)
    with Session(engine) as session:
        exported = model_export.export_model_json(session, ver_id)
    m = exported["model"]
    assert m["name"] == "Nâsty Rétail © Inc."
    assert "ünicode" in m["description"] and "\n" in m["description"]
    names = {d["name"] for d in m["domains"]}
    assert {"salés", "customér", "empty_domain"} <= names


def test_two_part_fk_survives_on_attribute(engine):
    """A 2-part `table.column` FK (no domain) survives on the attribute even
    though it produces no ForeignKeyLink row."""
    biz_id, ver_id = _seed(engine, NASTY_MODEL)
    with Session(engine) as session:
        exported = model_export.export_model_json(session, ver_id)
    a = _index(exported)
    assert a[("salés", "order_líne", "promo_code")]["foreign_key_to"] == (
        "promotion.promo_code"
    )


# ---------------------------------------------------------------------------
# 2. Lookup / tenancy / zero-row edges.
# ---------------------------------------------------------------------------

def test_export_missing_version_raises_lookup(engine):
    with Session(engine) as session:
        with pytest.raises(LookupError):
            model_export.export_model_json(session, "no-such-id")


def test_export_zero_row_version(engine):
    """A ModelVersion with no domains exports a valid empty envelope."""
    with Session(engine) as session:
        biz = Business(name="Empty Co", industry_alignment="X", description="")
        session.add(biz)
        session.flush()
        mv = ModelVersion(
            business_id=biz.id, version=1, scope="mvm", status="completed"
        )
        session.add(mv)
        session.commit()
        out = model_export.export_model_json(session, mv.id)
    assert out["model"]["domains"] == []
    assert out["model"]["version"] == "v1_mvm"
    assert out["model"]["name"] == "Empty Co"


def test_export_endpoint_tenancy_gate_json(client, engine):
    biz_id, ver_id = _seed(engine, NASTY_MODEL, version=2, scope="ecm")
    ok = client.get(f"/api/businesses/{biz_id}/model-versions/{ver_id}/export")
    assert ok.status_code == 200, ok.text
    wrong = client.get(
        f"/api/businesses/some-other-biz/model-versions/{ver_id}/export"
    )
    assert wrong.status_code == 404
    missing = client.get(
        f"/api/businesses/{biz_id}/model-versions/no-such-version/export"
    )
    assert missing.status_code == 404


def test_export_bundle_endpoint_tenancy_gate(client, engine):
    biz_id, ver_id = _seed(engine, NASTY_MODEL, version=3, scope="ecm")
    ok = client.get(
        f"/api/businesses/{biz_id}/model-versions/{ver_id}/export/bundle"
    )
    assert ok.status_code == 200, ok.text
    assert ok.headers["content-type"] == "application/zip"
    wrong = client.get(
        f"/api/businesses/other-biz/model-versions/{ver_id}/export/bundle"
    )
    assert wrong.status_code == 404


# ---------------------------------------------------------------------------
# 3. Bundle layout descriptor edges.
# ---------------------------------------------------------------------------

def test_bundle_layout_normalizes_industry_and_scope():
    layout = model_export.bundle_layout("Retail & Co!", "ECM", 4)
    assert layout.scope == "ecm"
    assert layout.dir.endswith("/v4/ecm")
    assert layout.model_json_path == f"{layout.dir}/model.json"
    # No raw unsafe chars leak into the path segment.
    assert " " not in layout.industry and "&" not in layout.industry


def test_bundle_layout_empty_industry_falls_back():
    layout = model_export.bundle_layout("", "mvm", 1)
    assert layout.industry == "model"
    assert layout.dir == "model/v1/mvm"


# ---------------------------------------------------------------------------
# 4. Bundle zip assembly: empty artifacts, model.json placement, nesting.
# ---------------------------------------------------------------------------

def test_bundle_zip_empty_artifacts(engine):
    biz_id, ver_id = _seed(engine, NASTY_MODEL)
    with Session(engine) as session:
        model_json = model_export.export_model_json(session, ver_id)
    layout = model_export.bundle_layout("retail", "ecm", 5)
    body = model_export.build_bundle_zip_bytes(MagicMock(), layout, model_json, [])
    with zipfile.ZipFile(io.BytesIO(body)) as zf:
        names = zf.namelist()
    assert names == ["retail/v5/ecm/model.json"]


def test_bundle_zip_nests_artifacts_under_dir(engine):
    biz_id, ver_id = _seed(engine, NASTY_MODEL)
    ws = MagicMock()
    ws.files.download.return_value.contents.read.return_value = b"hello"
    arts = [
        RunArtifact(
            run_id=None, model_version_id=ver_id,
            artifact_type="doc", file_path="/Volumes/x/y/report.md",
        ),
    ]
    with Session(engine) as session:
        model_json = model_export.export_model_json(session, ver_id)
    layout = model_export.bundle_layout("retail", "ecm", 5)
    body = model_export.build_bundle_zip_bytes(ws, layout, model_json, arts)
    with zipfile.ZipFile(io.BytesIO(body)) as zf:
        names = set(zf.namelist())
    assert "retail/v5/ecm/model.json" in names
    assert "retail/v5/ecm/report.md" in names


# ---------------------------------------------------------------------------
# 5. write_artifacts_to_zip: collision dedupe, missing path, prefix.
# ---------------------------------------------------------------------------

def _ws_returning(mapping: dict[str, bytes]) -> MagicMock:
    ws = MagicMock()

    def _download(path):
        resp = MagicMock()
        resp.contents.read.return_value = mapping[path]
        return resp

    ws.files.download.side_effect = _download
    return ws


def test_write_artifacts_dedupes_same_filename(engine):
    """Three artifacts whose Volume paths share the same basename must produce
    three DISTINCT zip entries (no silent overwrite / data loss)."""
    ws = _ws_returning({
        "/a/model.json": b"AAA",
        "/b/model.json": b"BBB",
        "/c/model.json": b"CCC",
    })
    arts = [
        RunArtifact(run_id=None, model_version_id="v", artifact_type="t",
                    file_path=p)
        for p in ("/a/model.json", "/b/model.json", "/c/model.json")
    ]
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w") as zf:
        write_artifacts_to_zip(zf, ws, arts)
    buf.seek(0)
    with zipfile.ZipFile(buf) as zf:
        names = zf.namelist()
        contents = {n: zf.read(n) for n in names}
    assert len(names) == 3, f"collision lost an entry: {names}"
    assert len(set(names)) == 3, f"duplicate arcnames in zip: {names}"
    assert set(contents.values()) == {b"AAA", b"BBB", b"CCC"}, (
        "deduped entries clobbered each other's bytes"
    )


def test_write_artifacts_dedupe_does_not_collide_with_real_name(engine):
    """A genuine file literally named `model_1.json` must not be silently
    overwritten by the dedupe suffix of a colliding `model.json`."""
    ws = _ws_returning({
        "/a/model.json": b"FIRST",
        "/b/model.json": b"SECOND",
        "/c/model_1.json": b"REAL_ONE",
    })
    arts = [
        RunArtifact(run_id=None, model_version_id="v", artifact_type="t",
                    file_path=p)
        for p in ("/a/model.json", "/b/model.json", "/c/model_1.json")
    ]
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w") as zf:
        write_artifacts_to_zip(zf, ws, arts)
    buf.seek(0)
    with zipfile.ZipFile(buf) as zf:
        names = zf.namelist()
        contents = {n: zf.read(n) for n in names}
    assert len(names) == 3, f"a file was lost to a dedupe collision: {names}"
    assert len(set(names)) == 3, f"arcname collision in zip: {names}"
    # All three payloads must be present and distinct.
    assert set(contents.values()) == {b"FIRST", b"SECOND", b"REAL_ONE"}


def test_write_artifacts_skips_missing_path(engine):
    """Artifacts with no file_path are skipped, not crashed on."""
    ws = _ws_returning({"/a/keep.md": b"KEEP"})
    arts = [
        RunArtifact(run_id=None, model_version_id="v", artifact_type="t",
                    file_path=""),
        RunArtifact(run_id=None, model_version_id="v", artifact_type="t",
                    file_path=None),
        RunArtifact(run_id=None, model_version_id="v", artifact_type="t",
                    file_path="/a/keep.md"),
    ]
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w") as zf:
        write_artifacts_to_zip(zf, ws, arts)
    buf.seek(0)
    with zipfile.ZipFile(buf) as zf:
        names = zf.namelist()
    assert names == ["keep.md"]


def test_write_artifacts_empty_set(engine):
    ws = MagicMock()
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w") as zf:
        write_artifacts_to_zip(zf, ws, [])
    buf.seek(0)
    with zipfile.ZipFile(buf) as zf:
        assert zf.namelist() == []
    ws.files.download.assert_not_called()


def test_write_artifacts_prefix_nesting(engine):
    ws = _ws_returning({"/a/r.md": b"X"})
    arts = [RunArtifact(run_id=None, model_version_id="v", artifact_type="t",
                        file_path="/a/r.md")]
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w") as zf:
        write_artifacts_to_zip(zf, ws, arts, prefix="root/sub/")
    buf.seek(0)
    with zipfile.ZipFile(buf) as zf:
        assert zf.namelist() == ["root/sub/r.md"]


def test_flat_download_surface_regression(engine):
    """build_artifacts_zip_bytes (flat surface) must behave identically to
    write_artifacts_to_zip with empty prefix after the unify."""
    from vibe_modeling.backend._artifact_io import build_artifacts_zip_bytes

    ws = _ws_returning({"/a/one.md": b"1", "/b/one.md": b"2"})
    arts = [
        RunArtifact(run_id=None, model_version_id="v", artifact_type="t",
                    file_path=p)
        for p in ("/a/one.md", "/b/one.md")
    ]
    body = build_artifacts_zip_bytes(ws, arts)
    with zipfile.ZipFile(io.BytesIO(body)) as zf:
        names = zf.namelist()
        contents = {n: zf.read(n) for n in names}
    assert len(names) == 2 and len(set(names)) == 2
    assert set(contents.values()) == {b"1", b"2"}
