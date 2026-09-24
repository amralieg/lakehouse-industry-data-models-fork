"""Unit tests for the Statistics-report Excel builder (T15).

The builder is a pure transform (``ReportData`` DTO → ``.xlsx`` bytes), so these
tests open the produced workbook with ONLY the stdlib (``zipfile`` +
``xml.etree``) — the reader-independent verification the T14 spike established.
That proves the charts are live native chart parts (``xl/charts/chart*.xml``)
rather than embedded images, the hidden Data sheet is flagged, the per-domain
tabs / autofilter / data bars / drill hyperlinks are present, and a baseline /
ECM fixture degrades to ``"n/a"`` with its chart omitted.
"""

from __future__ import annotations

import zipfile
from io import BytesIO
from xml.etree import ElementTree as ET

from vibe_modeling.backend.report_export import (
    DomainReport,
    ReportData,
    build_report_workbook,
    sanitize_sheet_names,
)


def _full_report() -> ReportData:
    """An MVM version with a predecessor and a confidence score — every
    measure computable, charts populated."""
    return ReportData(
        model_name="Test Retail",
        model_version="v4",
        scope="mvm",
        generated_at="2026-06-02",
        domain_count=4,
        product_count=92,
        attribute_count=410,
        fk_count=88,
        reviewed=53,
        review_needed=80,
        no_review_needed=12,
        confidence_score=78.0,
        quality_score=66.0,
        open_inputs=14,
        error_count=3,
        warning_count=11,
        has_confidence=True,
        has_predecessor=True,
        change_pct=37.0,
        domains=[
            DomainReport("Sales", 24, 18, 24, 0, 6, 82.0, 12.0, "changed", 71.0, "high change"),
            DomainReport("Customer", 30, 9, 30, 0, 11, 64.0, 41.0, "changed", 95.0, "needs review"),
            DomainReport("Inventory", 22, 22, 22, 0, 0, 91.0, 5.0, "unchanged", 28.0, "clean"),
            DomainReport("Finance", 16, 4, 16, 0, 8, 55.0, 33.0, "changed", 88.0, "open inputs"),
        ],
    )


def _baseline_ecm_report() -> ReportData:
    """An ECM base version: no confidence (ECM), no predecessor (base).
    Confidence + change must degrade to "n/a"; the quality chart is omitted
    because no domain carries a quality score."""
    return ReportData(
        model_name="Reference ECM",
        model_version="v1",
        scope="ecm",
        generated_at="2026-06-02",
        domain_count=2,
        product_count=18,
        attribute_count=64,
        fk_count=0,
        reviewed=0,
        review_needed=18,
        no_review_needed=0,
        confidence_score=None,
        quality_score=None,
        open_inputs=0,
        error_count=None,
        warning_count=None,
        has_confidence=False,
        has_predecessor=False,
        change_pct=None,
        domains=[
            DomainReport("Reference (ECM)", 8, 0, 8, 0, 0, None, None, "", None, ""),
            DomainReport("Lookup", 10, 0, 10, 0, 0, None, None, "", None, ""),
        ],
    )


def _open(report: ReportData) -> zipfile.ZipFile:
    data = build_report_workbook(report)
    assert isinstance(data, (bytes, bytearray)) and len(data) > 0
    zf = zipfile.ZipFile(BytesIO(data))
    assert zf.testzip() is None, "corrupt entry in produced .xlsx"
    return zf


def _sheet_xml(zf: zipfile.ZipFile) -> list[str]:
    return [
        zf.read(n).decode("utf-8")
        for n in zf.namelist()
        if n.startswith("xl/worksheets/sheet") and n.endswith(".xml")
    ]


# --- sheet-name sanitisation ------------------------------------------------


def test_sanitize_strips_forbidden_and_truncates():
    names = sanitize_sheet_names(["A/B:C*?", "x" * 50])
    assert all(not (set(n) & set("[]:*?/\\")) for n in names)
    assert all(len(n) <= 31 for n in names)
    assert names[0] == "ABC"


def test_sanitize_dedupes_after_truncation():
    long_a = "Domain " + "X" * 40 + " one"
    long_b = "Domain " + "X" * 40 + " two"  # collides on the first 31 chars
    names = sanitize_sheet_names([long_a, long_b])
    assert len(set(n.lower() for n in names)) == 2, "truncated names must be unique"
    assert all(len(n) <= 31 for n in names)


def test_sanitize_blank_name_falls_back():
    assert sanitize_sheet_names(["", "   "]) != ["", ""]


# --- full report: native charts, hidden sheet, tabs, filter, bars, links ----


def test_native_charts_present_no_images():
    zf = _open(_full_report())
    names = zf.namelist()
    charts = [n for n in names if n.startswith("xl/charts/chart") and n.endswith(".xml")]
    media = [n for n in names if n.startswith("xl/media/")]
    assert len(charts) >= 2, f"expected >=2 native chart parts, got {charts}"
    assert media == [], f"no chart should be a static image, found {media}"
    for c in charts:
        ET.fromstring(zf.read(c))  # well-formed native chart XML


def test_charts_recompute_from_data_sheet():
    zf = _open(_full_report())
    chart = next(
        zf.read(n).decode("utf-8")
        for n in zf.namelist()
        if n.startswith("xl/charts/chart") and n.endswith(".xml")
    )
    assert "Data!$" in chart, "chart series must reference the hidden Data sheet range"


def test_hidden_data_sheet_flagged():
    zf = _open(_full_report())
    wb_xml = zf.read("xl/workbook.xml").decode("utf-8")
    assert 'state="hidden"' in wb_xml


def test_model_sheet_is_first_and_visible():
    zf = _open(_full_report())
    wb_xml = zf.read("xl/workbook.xml").decode("utf-8")
    first_sheet = wb_xml.split("<sheet ", 1)[1]
    first_sheet = first_sheet.split("/>", 1)[0]
    assert 'name="Model"' in first_sheet
    assert "hidden" not in first_sheet


def test_per_domain_tabs_present():
    report = _full_report()
    zf = _open(report)
    wb_xml = zf.read("xl/workbook.xml").decode("utf-8")
    # Model + Data + one tab per domain.
    for name in sanitize_sheet_names([d.name for d in report.domains]):
        assert f'name="{name}"' in wb_xml, f"missing domain tab {name!r}"


def test_autofilter_databar_and_hyperlinks_present():
    zf = _open(_full_report())
    sheets = _sheet_xml(zf)
    assert any("<autoFilter" in s for s in sheets), "Where-to-focus autofilter missing"
    assert any("dataBar" in s for s in sheets), "Focus-score data bars missing"
    assert any("<hyperlink" in s for s in sheets), "drill hyperlinks missing"


def test_back_to_model_link_on_each_domain_tab():
    report = _full_report()
    zf = _open(report)
    sheets = _sheet_xml(zf)
    # Internal links are stored as a quoted location on the worksheet hyperlink
    # (location="'Model'!A1"), not as an external relationship — the back-to-
    # Model target must be present.
    assert any("location=\"'Model'!A1\"" in s for s in sheets), "back-to-Model link missing"
    # The drill links into domain tabs use the same quoted-internal form.
    domain_targets = [
        f"location=\"'{name}'!A1\""
        for name in sanitize_sheet_names([d.name for d in report.domains])
    ]
    joined = "".join(sheets)
    assert all(t in joined for t in domain_targets), "domain drill links missing"


# --- baseline / ECM degradation ---------------------------------------------


def test_baseline_ecm_writes_na_and_omits_quality_chart():
    report = _baseline_ecm_report()
    zf = _open(report)
    names = zf.namelist()
    charts = [n for n in names if n.startswith("xl/charts/chart") and n.endswith(".xml")]
    # No domain carries a quality score → the quality (line) chart is omitted.
    # The progress chart may still render (review split exists), so allow <=1.
    assert len(charts) <= 1, f"quality chart should be omitted, got {charts}"
    assert all(not n.startswith("xl/media/") for n in names), "no broken image placeholder"

    # The "n/a" literal is present (confidence + change degraded). It lives in
    # the shared-strings table.
    shared = zf.read("xl/sharedStrings.xml").decode("utf-8")
    assert "n/a" in shared, 'expected "n/a" degradation token in the workbook'


def test_baseline_ecm_still_valid_and_has_tabs():
    report = _baseline_ecm_report()
    zf = _open(report)
    wb_xml = zf.read("xl/workbook.xml").decode("utf-8")
    assert 'name="Model"' in wb_xml
    for name in sanitize_sheet_names([d.name for d in report.domains]):
        assert f'name="{name}"' in wb_xml


def test_empty_domains_report_still_opens():
    report = ReportData(
        model_name="Empty",
        model_version="v1",
        scope="mvm",
        generated_at="2026-06-02",
        reviewed=0,
        review_needed=0,
        no_review_needed=0,
        domains=[],
    )
    zf = _open(report)
    assert "xl/workbook.xml" in zf.namelist()
