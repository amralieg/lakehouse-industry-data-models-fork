"""Excel export of the Statistics report (T15, story "Export the statistics
report").

A pure builder: :func:`build_report_workbook` takes a plain :class:`ReportData`
DTO (no DB session, no app state) and returns the ``.xlsx`` as bytes via
``xlsxwriter`` — built from scratch, with NATIVE recomputing charts (chart
parts bound to a hidden Data sheet, never embedded images). The endpoint in
``explorer`` assembles the DTO from the same readers the live Statistics
surfaces use (review progress, next_vibes metrics, evolution metrics, domains)
and streams the bytes back.

Workbook shape (mirrors the in-app scope tree):

* **Model** (visible, landing) — header (name / version / generated) + the four
  report areas (Review · Quality · Change · Size) and the **Where-to-focus**
  ranked table with an autofilter and Focus-score data bars; each row drills to
  that domain's tab via an ``internal:`` hyperlink.
* **Data** (hidden) — the per-domain numeric series the charts recompute from.
* **one tab per domain** — that domain's view + a "back to Model" link.

Degradation (baseline / ECM, per the T14 spike): an uncomputable measure is
written as the literal string ``"n/a"`` and the dependent chart is simply
OMITTED — never a broken placeholder.

Gotchas baked in (see ``scripts/spikes/xlsx_findings.md``):

* The landing ``Model`` sheet is created FIRST so it is the active sheet;
  ``xlsxwriter`` silently refuses to hide the active sheet, so ``Data`` (hidden)
  is created after it.
* Sheet names are sanitised to Excel's rules (<=31 chars, none of ``[]:*?/\\``)
  AND de-duplicated after truncation; the drill hyperlink targets are built from
  the SAME sanitised name so they never break.
* ``internal:`` hyperlink sheet names are single-quoted (required when the name
  contains spaces / parens, e.g. ``Reference (ECM)``).
"""

from __future__ import annotations

import io
from dataclasses import dataclass, field
from typing import Optional

import xlsxwriter

# ``n/a`` literal for any measure that can't be computed for this scope
# (baseline → no change; ECM → no confidence). Kept as the displayed string so
# data-bar conditional formats skip it automatically (text cells are ignored).
NA = "n/a"

# Forbidden characters in an Excel sheet name, plus the 31-char cap.
_FORBIDDEN = set("[]:*?/\\")
_MAX_SHEET_NAME = 31


@dataclass
class DomainReport:
    """One domain's row in the Where-to-focus table + its own tab.

    A ``None`` measure renders as ``"n/a"`` and drops out of charts/data bars.
    ``focus_score`` is the composite triage rank (higher = more attention).
    """

    name: str
    product_count: int = 0
    reviewed: int = 0
    review_needed: int = 0
    no_review_needed: int = 0
    # Domain-scope quality signal: open next_vibes inputs attributed here.
    open_inputs: int = 0
    quality_score: Optional[float] = None
    # Percent of the domain touched vs the predecessor; None on a base version.
    change_pct: Optional[float] = None
    change_label: str = ""  # "new" | "changed" | "unchanged" | "" (n/a)
    focus_score: Optional[float] = None
    reason: str = ""

    @property
    def review_pct(self) -> Optional[float]:
        """Reviewed ÷ review-needed (0..100), or None when nothing needs review."""
        if self.review_needed <= 0:
            return None
        return 100.0 * self.reviewed / self.review_needed


@dataclass
class ReportData:
    """Everything the workbook renders for one model version.

    Plain data only — assembled by the endpoint from the live readers so the
    builder stays a pure, DB-free, unit-testable transform.
    """

    model_name: str
    model_version: str
    scope: str  # "ecm" | "mvm"
    generated_at: str

    # Model-scope rollups (the four areas).
    domain_count: int = 0
    product_count: int = 0
    attribute_count: int = 0
    fk_count: int = 0

    reviewed: int = 0
    review_needed: int = 0
    no_review_needed: int = 0

    confidence_score: Optional[float] = None  # None on ECM (no confidence)
    quality_score: Optional[float] = None  # next_vibes static-analysis grade
    open_inputs: int = 0
    error_count: Optional[int] = None
    warning_count: Optional[int] = None

    # Degradation drivers.
    has_confidence: bool = True
    has_predecessor: bool = True
    # Percent of model touched vs predecessor; None on a base version.
    change_pct: Optional[float] = None

    domains: list[DomainReport] = field(default_factory=list)

    @property
    def review_pct(self) -> Optional[float]:
        if self.review_needed <= 0:
            return None
        return 100.0 * self.reviewed / self.review_needed


def sanitize_sheet_names(names: list[str]) -> list[str]:
    """Map raw domain names to unique, Excel-legal sheet names.

    Strips forbidden chars, truncates to 31, then de-dupes collisions (two
    domains can collide after truncation) by appending a numeric suffix that
    keeps the result within the 31-char cap. Order-preserving — the caller
    zips the result back onto the domains so the tab name and its drill
    hyperlink target are always the SAME string.
    """
    out: list[str] = []
    seen: set[str] = set()
    for raw in names:
        base = "".join(c for c in (raw or "") if c not in _FORBIDDEN).strip()
        if not base:
            base = "Domain"
        candidate = base[:_MAX_SHEET_NAME]
        if candidate.lower() not in seen:
            seen.add(candidate.lower())
            out.append(candidate)
            continue
        # Collision after truncation: append " (n)" trimming the base to fit.
        n = 2
        while True:
            suffix = f" ({n})"
            trimmed = base[: _MAX_SHEET_NAME - len(suffix)]
            candidate = f"{trimmed}{suffix}"
            if candidate.lower() not in seen:
                seen.add(candidate.lower())
                out.append(candidate)
                break
            n += 1
    return out


def _ranked(domains: list[DomainReport]) -> list[DomainReport]:
    """Highest focus first; uncomputable focus (None) sinks to the bottom."""
    return sorted(
        domains,
        key=lambda d: (d.focus_score is None, -(d.focus_score or 0.0)),
    )


def _internal_link(sheet_name: str, cell: str = "A1") -> str:
    """Single-quoted ``internal:`` target — quotes required for spaces/parens."""
    return f"internal:'{sheet_name}'!{cell}"


def build_report_workbook(report: ReportData) -> bytes:
    """Render ``report`` to an ``.xlsx`` and return the bytes."""
    buffer = io.BytesIO()
    wb = xlsxwriter.Workbook(buffer, {"in_memory": True})

    # --- formats ------------------------------------------------------------
    f_title = wb.add_format({"bold": True, "font_size": 16})
    f_meta = wb.add_format({"font_size": 10, "font_color": "#666666"})
    f_section = wb.add_format({"bold": True, "font_size": 12})
    f_hdr = wb.add_format({"bold": True, "bg_color": "#DDEBF7", "border": 1})
    f_label = wb.add_format({"bold": True})
    f_link = wb.add_format({"font_color": "#0563C1", "underline": 1})
    f_pct = wb.add_format({"num_format": '0"%"'})
    f_na = wb.add_format({"italic": True, "font_color": "#999999"})

    # Build the unique tab names ONCE; reuse for both the drill hyperlinks and
    # the per-domain sheets so they can't drift.
    sheet_names = sanitize_sheet_names([d.name for d in report.domains])
    name_for = dict(zip((d.name for d in report.domains), sheet_names))

    # --- Model (landing) sheet — created FIRST so it stays the active sheet --
    model = wb.add_worksheet("Model")

    # --- hidden Data sheet (feeds the charts) -------------------------------
    # Created AFTER Model: xlsxwriter silently ignores .hide() on the first
    # (active) sheet. Only domains with a computable review split feed the
    # progress chart; quality requires a quality_score.
    data = wb.add_worksheet("Data")
    data.hide()
    data.write_row(0, 0, ["Domain", "Reviewed", "Remaining", "Quality"])
    chartable = [
        d for d in report.domains if d.review_needed > 0 or d.no_review_needed > 0
    ]
    for i, d in enumerate(chartable, start=1):
        data.write(i, 0, d.name)
        data.write_number(i, 1, d.reviewed)
        data.write_number(i, 2, max(d.review_needed - d.reviewed, 0))
        if d.quality_score is not None:
            data.write_number(i, 3, d.quality_score)
        else:
            data.write_blank(i, 3, None)
    n_data = len(chartable)
    has_quality_series = any(d.quality_score is not None for d in chartable)

    # --- Model header -------------------------------------------------------
    scope_label = report.scope.upper()
    model.write(0, 0, f"Model Statistics Report — {report.model_name}", f_title)
    model.write(
        1,
        0,
        f"Version {report.model_version} ({scope_label})    Generated {report.generated_at}",
        f_meta,
    )

    # --- The four areas (compact summary block) -----------------------------
    row = 3
    model.write(row, 0, "Review", f_section)
    row += 1
    rp = report.review_pct
    model.write(row, 0, "Reviewed (% of products needing review)", f_label)
    if rp is None:
        model.write(row, 1, NA, f_na)
    else:
        model.write_number(row, 1, round(rp, 1), f_pct)
    row += 1
    model.write(row, 0, "Reviewed / Needs review / No review needed")
    model.write(
        row,
        1,
        f"{report.reviewed} / {report.review_needed} / {report.no_review_needed}",
    )
    row += 2

    model.write(row, 0, "Quality", f_section)
    row += 1
    model.write(row, 0, "Model confidence", f_label)
    if report.has_confidence and report.confidence_score is not None:
        model.write_number(row, 1, report.confidence_score)
    else:
        model.write(row, 1, NA, f_na)
    row += 1
    model.write(row, 0, "Quality score (next_vibes)", f_label)
    if report.quality_score is not None:
        model.write_number(row, 1, round(report.quality_score, 1))
    else:
        model.write(row, 1, NA, f_na)
    row += 1
    model.write(row, 0, "Open inputs / Errors / Warnings", f_label)
    model.write(
        row,
        1,
        f"{report.open_inputs} / "
        f"{report.error_count if report.error_count is not None else NA} / "
        f"{report.warning_count if report.warning_count is not None else NA}",
    )
    row += 2

    model.write(row, 0, "Change", f_section)
    row += 1
    model.write(row, 0, "Model touched", f_label)
    if report.has_predecessor and report.change_pct is not None:
        model.write_number(row, 1, round(report.change_pct, 1), f_pct)
    else:
        model.write(row, 1, NA, f_na)
        model.write(row, 2, "Base version — no predecessor", f_meta)
    row += 2

    model.write(row, 0, "Size", f_section)
    row += 1
    model.write(row, 0, "Domains / Products / Attributes / Foreign keys", f_label)
    model.write(
        row,
        1,
        f"{report.domain_count} / {report.product_count} / "
        f"{report.attribute_count} / {report.fk_count}",
    )
    row += 2

    # --- Charts (native, recompute from the hidden Data sheet) --------------
    # Omit entirely when there is no chartable data — never a broken placeholder.
    chart_anchor_row = row + 1
    if n_data > 0:
        progress = wb.add_chart({"type": "column", "subtype": "stacked"})
        progress.add_series({
            "name": "Reviewed",
            "categories": ["Data", 1, 0, n_data, 0],
            "values": ["Data", 1, 1, n_data, 1],
        })
        progress.add_series({
            "name": "Remaining",
            "categories": ["Data", 1, 0, n_data, 0],
            "values": ["Data", 1, 2, n_data, 2],
        })
        progress.set_title({"name": "Review progress by domain"})
        progress.set_size({"width": 480, "height": 288})
        model.insert_chart(chart_anchor_row, 0, progress)

        if has_quality_series:
            quality = wb.add_chart({"type": "line"})
            quality.add_series({
                "name": "Quality score",
                "categories": ["Data", 1, 0, n_data, 0],
                "values": ["Data", 1, 3, n_data, 3],
            })
            quality.set_title({"name": "Quality by domain"})
            quality.set_size({"width": 480, "height": 288})
            model.insert_chart(chart_anchor_row, 8, quality)
        row = chart_anchor_row + 16
    else:
        row = chart_anchor_row

    # --- Where to focus: ranked table + autofilter + data bars + drill links -
    model.write(row, 0, "Where to focus", f_section)
    row += 1
    headers = [
        "Domain",
        "Focus",
        "Reviewed",
        "Open inputs",
        "Changed",
        "Products",
        "Reason",
    ]
    tbl_top = row
    model.write_row(tbl_top, 0, headers, f_hdr)

    ranked = _ranked(report.domains)
    for offset, d in enumerate(ranked, start=1):
        r = tbl_top + offset
        sheet_name = name_for.get(d.name)
        if sheet_name:
            model.write_url(r, 0, _internal_link(sheet_name), f_link, d.name)
        else:
            model.write(r, 0, d.name)
        if d.focus_score is not None:
            model.write_number(r, 1, round(d.focus_score, 1))
        else:
            model.write(r, 1, NA, f_na)
        dpct = d.review_pct
        if dpct is None:
            model.write(r, 2, NA, f_na)
        else:
            model.write_number(r, 2, round(dpct, 1), f_pct)
        model.write_number(r, 3, d.open_inputs)
        if not report.has_predecessor:
            model.write(r, 4, NA, f_na)
        elif d.change_pct is not None:
            model.write_number(r, 4, round(d.change_pct, 1), f_pct)
        elif d.change_label:
            model.write(r, 4, d.change_label)
        else:
            model.write(r, 4, NA, f_na)
        model.write_number(r, 5, d.product_count)
        model.write(r, 6, d.reason, f_meta)

    last_row = tbl_top + len(ranked)
    if ranked:
        model.autofilter(tbl_top, 0, last_row, len(headers) - 1)
        # Data bars on Focus (col 1); "n/a" text cells are skipped automatically.
        model.conditional_format(
            tbl_top + 1,
            1,
            last_row,
            1,
            {"type": "data_bar", "bar_color": "#FFB628"},
        )
    model.set_column(0, 0, 26)
    model.set_column(1, 5, 13)
    model.set_column(6, 6, 34)

    # --- per-domain tabs ----------------------------------------------------
    for d in report.domains:
        sheet_name = name_for[d.name]
        ws = wb.add_worksheet(sheet_name)
        ws.write(0, 0, f"{d.name} — domain view", f_title)
        ws.write_url(2, 0, _internal_link("Model"), f_link, "← back to Model")

        rr = 4
        ws.write(rr, 0, "Products", f_hdr)
        ws.write_number(rr, 1, d.product_count)
        rr += 1
        ws.write(rr, 0, "Reviewed / Needs review / No review needed", f_hdr)
        ws.write(
            rr,
            1,
            f"{d.reviewed} / {d.review_needed} / {d.no_review_needed}",
        )
        rr += 1
        ws.write(rr, 0, "Review %", f_hdr)
        if d.review_pct is None:
            ws.write(rr, 1, NA, f_na)
        else:
            ws.write_number(rr, 1, round(d.review_pct, 1), f_pct)
        rr += 1
        ws.write(rr, 0, "Open inputs", f_hdr)
        ws.write_number(rr, 1, d.open_inputs)
        rr += 1
        ws.write(rr, 0, "Quality score", f_hdr)
        if d.quality_score is not None:
            ws.write_number(rr, 1, round(d.quality_score, 1))
        else:
            ws.write(rr, 1, NA, f_na)
        rr += 1
        ws.write(rr, 0, "Changed", f_hdr)
        if not report.has_predecessor:
            ws.write(rr, 1, NA, f_na)
            ws.write(rr, 2, "Base version — no predecessor", f_meta)
        elif d.change_pct is not None:
            ws.write_number(rr, 1, round(d.change_pct, 1), f_pct)
        elif d.change_label:
            ws.write(rr, 1, d.change_label)
        else:
            ws.write(rr, 1, NA, f_na)
        ws.set_column(0, 0, 40)
        ws.set_column(1, 2, 16)

    wb.close()
    buffer.seek(0)
    return buffer.getvalue()


__all__ = [
    "ReportData",
    "DomainReport",
    "build_report_workbook",
    "sanitize_sheet_names",
]
