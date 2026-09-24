"""Endpoint test for the Statistics-report Excel export (T15).

Exercises the full assembly path through the TestClient — the same DB-backed
readers the live Statistics surfaces use (review progress + next_vibes +
evolution + domains) feed ``report_export.build_report_workbook`` — and verifies
the streamed ``.xlsx`` is a valid OOXML package with the expected structure and
the ``attachment`` content disposition. Opened with ONLY the stdlib so the
charts are proved native (no embedded images).
"""

import os
import sys
import zipfile
from io import BytesIO
from xml.sax.saxutils import escape as _xml_escape

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from sqlmodel import Session

from vibe_modeling.backend.db_models import (
    Business,
    Domain,
    ModelVersion,
    Product,
)
from vibe_modeling.backend.report_export import sanitize_sheet_names


@pytest.fixture
def synced_version(engine):
    """v1 ECM (base, no predecessor) with 2 domains feeding the export.
    Returns (business_id, version_int)."""
    with Session(engine) as s:
        b = Business(name="Acme Retail")
        s.add(b)
        s.commit()
        mv = ModelVersion(business_id=b.id, version=1, status="completed", scope="ecm")
        s.add(mv)
        s.commit()
        sales = Domain(version_id=mv.id, name="Sales")
        ops = Domain(version_id=mv.id, name="Ops & Logistics")
        s.add(sales)
        s.add(ops)
        s.commit()
        for i in range(3):
            s.add(Product(version_id=mv.id, domain_id=sales.id, name=f"s{i}"))
        s.add(Product(version_id=mv.id, domain_id=ops.id, name="o0"))
        s.commit()
        return b.id, 1


def _download(client, bid, version_int=1, scope="ecm"):
    r = client.get(
        f"/api/businesses/{bid}/versions/{version_int}/{scope}/statistics-report.xlsx"
    )
    assert r.status_code == 200, r.text
    return r


def test_export_streams_valid_xlsx(client, synced_version):
    bid, vint = synced_version
    r = _download(client, bid, vint)
    assert (
        r.headers["content-type"]
        == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )
    cd = r.headers["content-disposition"]
    assert "attachment" in cd and "statistics-report-v1-ecm.xlsx" in cd
    zf = zipfile.ZipFile(BytesIO(r.content))
    assert zf.testzip() is None
    assert "xl/workbook.xml" in zf.namelist()


def test_export_has_model_and_domain_tabs(client, synced_version):
    bid, vint = synced_version
    r = _download(client, bid, vint)
    zf = zipfile.ZipFile(BytesIO(r.content))
    wb_xml = zf.read("xl/workbook.xml").decode("utf-8")
    assert 'name="Model"' in wb_xml
    assert 'state="hidden"' in wb_xml  # the Data sheet
    for name in sanitize_sheet_names(["Sales", "Ops & Logistics"]):
        # Sheet names are XML-escaped in workbook.xml (e.g. & → &amp;).
        assert f'name="{_xml_escape(name)}"' in wb_xml


def test_export_base_version_degrades_change_to_na(client, synced_version):
    bid, vint = synced_version
    r = _download(client, bid, vint)
    zf = zipfile.ZipFile(BytesIO(r.content))
    # Base ECM version: no predecessor (change → n/a) and no confidence (ECM).
    shared = zf.read("xl/sharedStrings.xml").decode("utf-8")
    assert "n/a" in shared
    # No static-image chart fallback ever.
    assert not any(n.startswith("xl/media/") for n in zf.namelist())


def test_export_unknown_version_404(client, synced_version):
    bid, _ = synced_version
    r = client.get(f"/api/businesses/{bid}/versions/99/ecm/statistics-report.xlsx")
    assert r.status_code == 404
