"""Write a model.json's structure into the agent's ``_metamodel.*`` Delta tables.

The agent's Phase 1 (vibe-iterate, shrink, enlarge) reads its system of
record from ``<deployment_catalog>._metamodel.{business,domain,product,attribute}``.
Imports bypass the agent entirely, so without this writer an imported
model can never be the input to a subsequent vibe-iterate run.

This module produces INSERT rows matching the agent's column shape
(verified against ``vibe_modeling_test._metamodel.*`` on the test workspace
2026-05-11). It does not DELETE / UPDATE / TRUNCATE — every call only
appends new rows. Re-importing the same scope/version would produce
duplicates; callers are expected to bump the version per import or
clean the prior rows out-of-band.

Best-effort: every failure is logged and swallowed so the import's
HTTP response is not affected. The Run's progress_message can be
checked for "_metamodel writes failed" to detect partial state.
"""
from __future__ import annotations

import logging
import time
from datetime import datetime, timezone
from typing import Any, Optional

from databricks.sdk import WorkspaceClient

from ..core._names import (
    escape_sql_literal as _esc,
    metamodel_display_business,
)

logger = logging.getLogger(__name__)


def _sql_str(v: Any) -> str:
    """Quote a Python value as a SQL VARCHAR literal. ``None`` → ``NULL``."""
    if v is None:
        return "NULL"
    return f"'{_esc(str(v))}'"


def _sql_double(v: Any) -> str:
    if v is None:
        return "NULL"
    try:
        return f"{float(v)}"
    except (TypeError, ValueError):
        return "NULL"


def _sql_bigint(v: Any) -> str:
    if v is None:
        return "NULL"
    try:
        return f"{int(v)}"
    except (TypeError, ValueError):
        return "NULL"


def _sql_ts(v: Optional[datetime]) -> str:
    if v is None:
        return "NULL"
    # Spark/DB SQL TIMESTAMP literal: 'YYYY-MM-DD HH:MM:SS.ffffff'
    return f"TIMESTAMP '{v.strftime('%Y-%m-%d %H:%M:%S.%f')}'"


# Default rows-per-INSERT. The _metamodel tables are append-only and a
# single multi-row INSERT lands all rows in one warehouse round-trip.
#
# Live retime (2026-07) measured this path at a FLAT ~2.05s/statement —
# per-statement warehouse round-trip + Delta commit latency, independent
# of how many rows the statement carries. A 200-row chunk therefore left
# real throughput on the table: a 6450-attribute-row kickstart model took
# 36 statements x 2.05s = 74s. There is no documented hard limit on
# Databricks SQL statement text length in the Statement Execution API;
# 6450 rows at ~200 bytes/row is ~1.3MB, comfortably inside normal HTTP
# body limits. 10,000 keeps a single statement per table for every
# realistic model size (collapsing the kickstart case to ~4 statements
# total, ~8s) while still bounding statement size for any pathologically
# large future model instead of going fully unbounded.
DEFAULT_CHUNK_SIZE = 10_000


def _exec(ws: WorkspaceClient, warehouse_id: str, statement: str) -> None:
    """Execute one SQL statement, raising on error.

    Wrapper around ``statement_execution.execute_statement`` that
    surfaces SQL errors with a useful message — Lakebase/Databricks
    silently swallows them otherwise on the legacy ``execute_statement``
    return shape.
    """
    r = ws.statement_execution.execute_statement(
        statement=statement, warehouse_id=warehouse_id, wait_timeout="50s",
    )
    if r.status and r.status.error:
        raise RuntimeError(
            f"SQL error executing INSERT: {r.status.error.message!r}; "
            f"statement={statement[:200]!r}"
        )


def _insert_batched(
    ws: WorkspaceClient,
    warehouse_id: str,
    *,
    table: str,
    columns: list[str],
    rows: list[list[str]],
    chunk_size: int,
) -> int:
    """Append ``rows`` to ``table`` via chunked multi-row INSERTs.

    Each ``row`` is a list of pre-quoted SQL value literals aligned with
    ``columns``. Rows are grouped into ``chunk_size``-sized batches; each
    batch is a single ``INSERT INTO ... VALUES (...), (...), ...``
    statement. No-op when ``rows`` is empty.

    Returns the number of INSERT statements issued (for the caller's
    statement-count evidence log).
    """
    if not rows:
        return 0
    step = chunk_size if chunk_size > 0 else len(rows)
    cols_clause = ", ".join(f"`{c}`" for c in columns)
    statements = 0
    for start in range(0, len(rows), step):
        chunk = rows[start:start + step]
        values_clause = ", ".join(f"({', '.join(r)})" for r in chunk)
        _exec(
            ws, warehouse_id,
            f"INSERT INTO {table} ({cols_clause}) VALUES {values_clause}",
        )
        statements += 1
    return statements


def _model_payload(model_json: dict) -> dict:
    """Unwrap ``{model_requirements, _vibe_session_metadata, model: {...}}``
    or accept a bare model dict. Mirrors ``import_model.detect_schema``.
    """
    if isinstance(model_json.get("model"), dict):
        return model_json["model"]
    return model_json


def _conventions_to_json(conventions: Any) -> str:
    """The agent stores ``model_conventions`` as a JSON STRING in the Delta
    business row. The model.json typically holds it as a dict — serialise.
    """
    if conventions is None:
        return ""
    if isinstance(conventions, str):
        return conventions
    try:
        import json as _json
        return _json.dumps(conventions, ensure_ascii=False)
    except Exception:
        return ""


def write_metamodel(
    ws: WorkspaceClient,
    *,
    catalog: str,
    warehouse_id: str,
    model_json: dict,
    business_name: str,
    scope: str,
    version: int,
    chunk_size: int = DEFAULT_CHUNK_SIZE,
) -> dict:
    """Append rows for the imported model to ``<catalog>._metamodel.{business,
    domain,product,attribute}``.

    Domain/product/attribute rows are batched into chunked multi-row
    INSERTs (``chunk_size`` rows per statement) so a multi-thousand-row
    model lands in a handful of warehouse round-trips instead of one per
    row — the per-row path could exceed the Databricks Apps reverse-proxy
    timeout and wedge the import request.

    Returns a summary dict ``{"business": int, "domain": int, "product": int,
    "attribute": int, "errors": list[str]}``. Always returns; never raises.
    """
    summary = {
        "business": 0, "domain": 0, "product": 0, "attribute": 0,
        "errors": [],
    }
    if not ws or not catalog or not warehouse_id or not business_name or not scope:
        summary["errors"].append(
            "missing required arg: ws/catalog/warehouse_id/business_name/scope"
        )
        return summary

    started = time.monotonic()
    statement_count = 0
    try:
        model = _model_payload(model_json)
        # The agent stores the display-cased slug in _metamodel.business.business
        # (e.g. "Terranova_Copy"), not the raw lowercase segment. Use the
        # same transform so iterate preflights and agent reads find the row.
        agent_biz = metamodel_display_business(business_name) or business_name
        version_str = str(version)
        scope_str = scope.lower()
        now = datetime.now(timezone.utc)

        # 1. business row -------------------------------------------------
        bus_cols = [
            ("business", _sql_str(agent_biz)),
            ("version", _sql_str(version_str)),
            ("model_scope", _sql_str(scope_str)),
            ("industry_alignment", _sql_str(model.get("industry_alignment", ""))),
            ("description", _sql_str(model.get("description", ""))),
            ("catalog", _sql_str(catalog)),
            ("location", _sql_str(model.get("location", ""))),
            ("core_business_processes", _sql_str(model.get("core_business_processes", ""))),
            ("orgnaization_divisions", _sql_str(model.get("orgnaization_divisions", ""))),
            ("data_domains", _sql_str(model.get("data_domains", ""))),
            ("common_business_jargons", _sql_str(model.get("common_business_jargons", ""))),
            ("operational_systems_of_records", _sql_str(model.get("operational_systems_of_records", ""))),
            ("industry_governing_body", _sql_str(model.get("industry_governing_body", ""))),
            ("vibe_modelling_instructions", _sql_str(model.get("vibe_modelling_instructions", ""))),
            ("model_conventions", _sql_str(_conventions_to_json(model.get("model_conventions")))),
            ("completion_date", _sql_ts(now)),
            # session_id is unused for imports; the row is recognisable by
            # processing_status='done' + the import-shaped catalog string.
            ("session_id", _sql_bigint(0)),
            ("processing_status", _sql_str("done")),
            ("completed_percent", _sql_double(100.0)),
            ("session_started_at", _sql_ts(now)),
            ("last_updated_at", _sql_ts(now)),
            ("session_json", _sql_str("{}")),
            ("results_json", _sql_str("{}")),
        ]
        cols_clause = ", ".join(f"`{c}`" for c, _ in bus_cols)
        vals_clause = ", ".join(v for _, v in bus_cols)
        bus_sql = (
            f"INSERT INTO `{catalog}`.`_metamodel`.`business` "
            f"({cols_clause}) VALUES ({vals_clause})"
        )
        _exec(ws, warehouse_id, bus_sql)
        statement_count += 1
        summary["business"] = 1

        # 2-4. Collect domain / product / attribute rows, then emit each
        # table's rows as chunked multi-row INSERTs (see _insert_batched).
        # Column order is fixed per table so every row tuple aligns.
        domain_cols = [
            "business", "version", "model_scope", "domain", "division",
            "description", "database_name", "catalog", "reference", "tags",
        ]
        product_cols = [
            "business", "version", "model_scope", "domain", "subdomain",
            "product", "description", "type", "division", "function",
            "data_type", "source_domains", "association_edges", "primary_key",
            "reference", "table_name", "sample_path", "tags",
        ]
        attribute_cols = [
            "business", "version", "model_scope", "domain", "product",
            "attribute", "column_name", "type", "tags", "value_regex",
            "foreign_key_to", "business_glossary_term", "description",
            "reference",
        ]
        domain_rows: list[list[str]] = []
        product_rows: list[list[str]] = []
        attribute_rows: list[list[str]] = []

        domains = model.get("domains") or []
        for d in domains:
            if not isinstance(d, dict):
                continue
            d_name = d.get("name", "")
            domain_rows.append([
                _sql_str(agent_biz),
                _sql_str(version_str),
                _sql_str(scope_str),
                _sql_str(d_name),
                _sql_str(d.get("division", "")),
                _sql_str(d.get("description", "")),
                _sql_str(d.get("database_name", "")),
                _sql_str(catalog),
                _sql_str(d.get("references", "") or d.get("reference", "")),
                _sql_str(""),
            ])
            summary["domain"] += 1

            for p in d.get("products") or []:
                if not isinstance(p, dict):
                    continue
                p_name = p.get("name") or p.get("product") or ""
                product_rows.append([
                    _sql_str(agent_biz),
                    _sql_str(version_str),
                    _sql_str(scope_str),
                    _sql_str(d_name),
                    _sql_str(p.get("subdomain", "")),
                    _sql_str(p_name),
                    _sql_str(p.get("description", "")),
                    _sql_str(p.get("type", "")),
                    _sql_str(p.get("division", "")),
                    _sql_str(p.get("function", "")),
                    _sql_str(p.get("data_type", "")),
                    _sql_str(p.get("source_domains", "")),
                    _sql_str(p.get("association_edges", "")),
                    _sql_str(p.get("primary_key", "")),
                    _sql_str(p.get("references", "") or p.get("reference", "")),
                    _sql_str(p.get("table_name", "") or p_name),
                    _sql_str(p.get("sample_path", "")),
                    _sql_str(""),
                ])
                summary["product"] += 1

                for a in p.get("attributes") or []:
                    if not isinstance(a, dict):
                        continue
                    a_name = a.get("name") or a.get("attribute") or ""
                    attribute_rows.append([
                        _sql_str(agent_biz),
                        _sql_str(version_str),
                        _sql_str(scope_str),
                        _sql_str(d_name),
                        _sql_str(p_name),
                        _sql_str(a_name),
                        _sql_str(a.get("column_name", "") or a_name),
                        _sql_str(a.get("type", "")),
                        _sql_str(""),
                        _sql_str(a.get("value_regex", "")),
                        _sql_str(a.get("foreign_key_to", "")),
                        _sql_str(a.get("business_glossary_term", "")),
                        _sql_str(a.get("description", "")),
                        _sql_str(a.get("references", "") or a.get("reference", "")),
                    ])
                    summary["attribute"] += 1

        statement_count += _insert_batched(
            ws, warehouse_id,
            table=f"`{catalog}`.`_metamodel`.`domain`",
            columns=domain_cols, rows=domain_rows, chunk_size=chunk_size,
        )
        statement_count += _insert_batched(
            ws, warehouse_id,
            table=f"`{catalog}`.`_metamodel`.`product`",
            columns=product_cols, rows=product_rows, chunk_size=chunk_size,
        )
        statement_count += _insert_batched(
            ws, warehouse_id,
            table=f"`{catalog}`.`_metamodel`.`attribute`",
            columns=attribute_cols, rows=attribute_rows, chunk_size=chunk_size,
        )

        elapsed = time.monotonic() - started
        total_rows = (
            summary["business"] + summary["domain"] + summary["product"]
            + summary["attribute"]
        )
        logger.info(
            "import_metamodel_writer: wrote business=%d domain=%d product=%d attribute=%d "
            "for %s/%s/v%s in %s._metamodel (%d row(s), %d statement(s), %.1fs)",
            summary["business"], summary["domain"], summary["product"],
            summary["attribute"], agent_biz, scope_str, version_str, catalog,
            total_rows, statement_count, elapsed,
        )
    except Exception as e:
        logger.exception("import_metamodel_writer: failed (non-fatal)")
        summary["errors"].append(str(e))
    return summary


def seed_metamodel_one(
    ws: WorkspaceClient,
    *,
    catalog: str,
    warehouse_id: str,
    model_json: dict,
    business_name: str,
    scope: str,
    version: int,
    log_prefix: str,
) -> Optional[dict]:
    """Seed one version's ``_metamodel.*`` rows, non-fatal, with consistent
    logging. The single convergence point for EVERY iterable-version producer
    (import model.json, Volume-import, kickstart, download) so the seed
    contract can't drift between them.

    Callers own catalog/warehouse resolution and MUST have committed their
    Lakebase rows first: this targets an external SQL warehouse and must never
    be able to roll back the caller's transaction. Failure semantics (M1):

    - unconfigured catalog/warehouse -> INFO skip (a no-op, not a failure);
    - ``write_metamodel`` reports errors -> ERROR (a real, actionable failure,
      logged DISTINCT from the info skip so an operator can tell them apart);
    - any unexpected exception -> EXCEPTION; never re-raised.

    Returns the ``write_metamodel`` summary dict (whose ``errors`` list a caller
    can inspect to decide its own status), or ``None`` on the unconfigured
    skip. Never raises. Most callers ignore the return; the kickstart
    background task uses it to fail the audit run on a real seed error.
    """
    if not (catalog and warehouse_id):
        logger.info(
            "%s: skipping _metamodel seed - no deployment_catalog/warehouse configured",
            log_prefix,
        )
        return None
    try:
        summary = write_metamodel(
            ws,
            catalog=catalog,
            warehouse_id=warehouse_id,
            model_json=model_json,
            business_name=business_name,
            scope=scope,
            version=version,
        )
        if summary.get("errors"):
            logger.error(
                "%s: _metamodel seed had errors for %s/%s v%s: %s",
                log_prefix, business_name, scope, version, summary["errors"],
            )
        return summary
    except Exception as exc:
        logger.exception(
            "%s: _metamodel seed failed for %s/%s v%s (non-fatal)",
            log_prefix, business_name, scope, version,
        )
        return {"business": 0, "domain": 0, "product": 0, "attribute": 0,
                "errors": [str(exc)]}
