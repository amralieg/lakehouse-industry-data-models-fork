"""Unit tests for ``services.import_metamodel_writer.write_metamodel``.

Verifies the SQL INSERT statements the writer produces match the agent's
column shape for ``_metamodel.{business,domain,product,attribute}``.

The writer never raises — failures land in the returned ``summary["errors"]``.
"""
from __future__ import annotations

from unittest.mock import MagicMock

import pytest

from vibe_modeling.backend.services.import_metamodel_writer import write_metamodel


@pytest.fixture
def captured_ws():
    """A MagicMock ws whose ``statement_execution.execute_statement`` records
    every statement and returns a successful result."""
    ws = MagicMock()
    statements: list[str] = []

    def execute(*args, statement=None, warehouse_id=None, wait_timeout=None, **kwargs):
        statements.append(statement)
        result = MagicMock()
        result.status = None  # No status → success
        return result

    ws.statement_execution.execute_statement.side_effect = execute
    ws._captured_statements = statements  # attach for the test to inspect
    return ws


def _payload() -> dict:
    return {
        "model": {
            "type": "business",
            "name": "Mining Corp",
            "version": "v1_ecm",
            "description": "Description text",
            "industry_alignment": "mining",
            "location": "EU",
            "core_business_processes": "p1, p2",
            "orgnaization_divisions": "div1, div2",
            "data_domains": "extraction, processing",
            "common_business_jargons": "tonnage, grade",
            "operational_systems_of_records": "ERP, SCADA",
            "industry_governing_body": "ISO, OSHA",
            "vibe_modelling_instructions": "Mine carefully.",
            "model_conventions": {"primary_key_suffix": "_id"},
            "domains": [
                {
                    "name": "extraction",
                    "division": "Operations",
                    "description": "All extraction activity",
                    "database_name": "extraction",
                    "products": [
                        {
                            "name": "mine_site",
                            "table_name": "mine_site",
                            "primary_key": "mine_site_id",
                            "description": "A mine",
                            "type": "reference",
                            "subdomain": "underground",
                            "attributes": [
                                {"name": "mine_site_id", "column_name": "mine_site_id",
                                 "type": "BIGINT", "description": "PK"},
                                {"name": "country_code", "column_name": "country_code",
                                 "type": "STRING", "description": "ISO country",
                                 "foreign_key_to": "geo.country.country_code"},
                            ],
                        },
                    ],
                },
            ],
        },
    }


class TestWriteMetamodel:
    def test_writes_business_domain_product_attribute_rows(self, captured_ws):
        out = write_metamodel(
            captured_ws,
            catalog="vibe_modeling_test",
            warehouse_id="abc123",
            model_json=_payload(),
            business_name="Mining Corp",
            scope="ecm",
            version=1,
        )
        assert out["business"] == 1
        assert out["domain"] == 1
        assert out["product"] == 1
        assert out["attribute"] == 2
        assert out["errors"] == []

        # Statements are batched per table: 1 business + 1 domain INSERT
        # (multi-row) + 1 product INSERT + 1 attribute INSERT. Batching
        # collapses what used to be one round-trip per row into one per
        # table-chunk so a multi-thousand-row import returns before the
        # Databricks Apps reverse-proxy timeout instead of wedging.
        stmts = captured_ws._captured_statements
        assert len(stmts) == 4  # business, domain, product, attribute (1 chunk each)
        biz_sql = stmts[0]
        assert biz_sql.startswith("INSERT INTO `vibe_modeling_test`.`_metamodel`.`business`")
        # Business identifier is display-cased to match agent's _metamodel column.
        assert "'Mining_Corp'" in biz_sql
        # version is a STRING in the agent's schema.
        assert "'1'" in biz_sql
        assert "'ecm'" in biz_sql
        # processing_status is 'done' for imports.
        assert "'done'" in biz_sql
        # completed_percent is 100 (the writer emits the float).
        assert "100.0" in biz_sql
        # model_conventions was serialised to JSON-string.
        assert '\"primary_key_suffix\": \"_id\"' in biz_sql or '"primary_key_suffix": "_id"' in biz_sql

        # Domain INSERT carries the right columns.
        domain_sql = stmts[1]
        assert domain_sql.startswith("INSERT INTO `vibe_modeling_test`.`_metamodel`.`domain`")
        assert "'extraction'" in domain_sql
        assert "'Operations'" in domain_sql

        # Product INSERT.
        product_sql = stmts[2]
        assert product_sql.startswith("INSERT INTO `vibe_modeling_test`.`_metamodel`.`product`")
        assert "'mine_site'" in product_sql
        assert "'mine_site_id'" in product_sql  # primary_key

        # Attribute INSERT batches both attribute rows into one multi-row
        # VALUES list; foreign_key_to populated for the FK column.
        attr_sql = stmts[3]
        assert attr_sql.startswith("INSERT INTO `vibe_modeling_test`.`_metamodel`.`attribute`")
        assert "'country_code'" in attr_sql
        assert "'mine_site_id'" in attr_sql
        assert "'geo.country.country_code'" in attr_sql
        # Multi-row VALUES → two value tuples → the join comma is present.
        assert "), (" in attr_sql

    def test_batches_rows_into_bounded_chunks(self, captured_ws):
        """A model with more rows than the chunk size must split each
        table's INSERT into multiple bounded statements — not one giant
        statement, and not one per row. Bounds the synchronous work so
        the import returns promptly on large models."""
        # 250 products in one domain, no attributes — with a 200-row chunk
        # the product INSERT splits into 2 statements (200 + 50).
        products = [
            {"name": f"p{i}", "table_name": f"p{i}", "attributes": []}
            for i in range(250)
        ]
        payload = {
            "model": {
                "name": "Big Corp", "version": "v1_ecm",
                "domains": [{"name": "d0", "products": products}],
            }
        }
        out = write_metamodel(
            captured_ws,
            catalog="cat", warehouse_id="wh",
            model_json=payload, business_name="Big Corp",
            scope="ecm", version=1, chunk_size=200,
        )
        assert out["product"] == 250
        assert out["errors"] == []
        stmts = captured_ws._captured_statements
        product_stmts = [s for s in stmts if "`_metamodel`.`product`" in s]
        # 250 products / 200-row chunk → 2 INSERTs (not 250, not 1).
        assert len(product_stmts) == 2

    def test_seed_statement_count_is_bounded_at_representative_scale(self, captured_ws):
        """A kickstart-scale model (~150 products, ~6.5k attributes - the
        scope this repo's perf work profiled) must issue a small, bounded
        number of warehouse round trips, not one per row. Regression guard:
        a change that reverts to a per-row INSERT loop would blow this
        assertion up from dozens of statements to thousands."""
        n_products = 150
        attrs_per_product = 43  # 150 * 43 = 6450, representative of ~6.5k
        products = [
            {
                "name": f"p{i}", "table_name": f"p{i}",
                "attributes": [
                    {"name": f"p{i}_a{j}", "column_name": f"p{i}_a{j}", "type": "STRING"}
                    for j in range(attrs_per_product)
                ],
            }
            for i in range(n_products)
        ]
        payload = {
            "model": {
                "name": "Kickstart Corp", "version": "v1_ecm",
                "domains": [{"name": "d0", "products": products}],
            }
        }
        out = write_metamodel(
            captured_ws,
            catalog="cat", warehouse_id="wh",
            model_json=payload, business_name="Kickstart Corp",
            scope="ecm", version=1,
        )
        assert out["product"] == n_products
        assert out["attribute"] == n_products * attrs_per_product
        assert out["errors"] == []

        stmts = captured_ws._captured_statements
        # 1 business + 1 domain + ceil(150/10000) product + ceil(6450/10000)
        # attribute = 1 + 1 + 1 + 1 = 4 - three orders of magnitude below
        # the 6602-row total, proving the batching is not per-row.
        assert len(stmts) <= 40, (
            f"expected a bounded statement count, got {len(stmts)} for "
            f"{out['attribute']} attribute rows"
        )
        total_rows = out["business"] + out["domain"] + out["product"] + out["attribute"]
        assert len(stmts) < total_rows / 100

    def test_missing_args_returns_error_without_raising(self, captured_ws):
        out = write_metamodel(
            captured_ws,
            catalog="",
            warehouse_id="abc",
            model_json=_payload(),
            business_name="x",
            scope="ecm",
            version=1,
        )
        assert out["business"] == 0
        assert out["errors"], "expected an error message for missing catalog"
        captured_ws.statement_execution.execute_statement.assert_not_called()

    def test_apostrophe_in_text_is_escaped(self, captured_ws):
        p = _payload()
        p["model"]["description"] = "It's a test — apostrophe ok"
        out = write_metamodel(
            captured_ws,
            catalog="cat",
            warehouse_id="wh",
            model_json=p,
            business_name="biz",
            scope="ecm",
            version=1,
        )
        assert out["business"] == 1
        biz_sql = captured_ws._captured_statements[0]
        # Single quotes must be doubled to avoid breaking the literal.
        assert "It''s a test" in biz_sql

    def test_seed_writes_display_cased_business(self, captured_ws):
        """W1 regression guard: the ``business`` column must be written with
        the agent's display-casing (``Terranova_Copy``) not the raw lowercase
        slug (``terranova_copy``). Pre-fix code fails this assertion."""
        out = write_metamodel(
            captured_ws,
            catalog="cat",
            warehouse_id="wh",
            model_json={"model": {"name": "Terranova Copy", "version": "v1_ecm", "domains": []}},
            business_name="terranova_copy",
            scope="ecm",
            version=1,
        )
        assert out["errors"] == []
        biz_sql = captured_ws._captured_statements[0]
        assert "'Terranova_Copy'" in biz_sql, (
            f"expected display-cased value in SQL, got: {biz_sql[:300]}"
        )
        assert "'terranova_copy'" not in biz_sql, (
            "lowercase slug must not appear in business column after W1 fix"
        )

    def test_sql_error_status_appends_to_errors(self):
        """If the warehouse returns an error status, write_metamodel should
        surface it via summary["errors"] without raising."""
        ws = MagicMock()

        def execute(*args, statement=None, **kwargs):
            r = MagicMock()
            r.status = MagicMock()
            r.status.error = MagicMock()
            r.status.error.message = "syntax error near INSERT"
            return r

        ws.statement_execution.execute_statement.side_effect = execute
        out = write_metamodel(
            ws,
            catalog="c", warehouse_id="w",
            model_json=_payload(), business_name="b", scope="ecm", version=1,
        )
        assert out["business"] == 0
        assert out["errors"]
        assert "syntax error" in out["errors"][0]
