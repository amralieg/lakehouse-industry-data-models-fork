"""Test the model_sync.py module — sync model data into Lakebase tables.

Tests cover both the Delta table loader (primary) and model.json loader (fallback),
plus the assembly logic that converts Delta query results into model dicts.
"""

import sys
import os
import json

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from unittest.mock import MagicMock, patch
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    Domain,
    ForeignKeyLink,
    ModelVersion,
    Product,
)
from vibe_modeling.backend.model_sync import ModelSyncService, _extract_confidence_score

FIXTURES_DIR = os.path.join(os.path.dirname(__file__), "..", "fixtures")


@pytest.fixture
def mock_model():
    """Load the mock_model.json fixture."""
    with open(os.path.join(FIXTURES_DIR, "mock_model.json")) as f:
        return json.load(f)


@pytest.fixture
def version_id(engine):
    """Create a business and model version, return version_id."""
    with Session(engine) as session:
        b = Business(name="Test Corp")
        session.add(b)
        session.flush()
        v = ModelVersion(business_id=b.id, version=1, status="completed")
        session.add(v)
        session.commit()
        session.refresh(v)
        return v.id


class TestModelSync:
    def test_sync_creates_domains(self, engine, mock_model, version_id):
        with Session(engine) as session:
            svc = ModelSyncService(session)
            svc.sync_from_model_json(version_id, mock_model)
            session.commit()

        with Session(engine) as session:
            domains = session.exec(select(Domain).where(Domain.version_id == version_id)).all()
            assert len(domains) == 2
            names = {d.name for d in domains}
            assert "sales" in names
            assert "inventory" in names

    def test_sync_creates_products(self, engine, mock_model, version_id):
        with Session(engine) as session:
            svc = ModelSyncService(session)
            svc.sync_from_model_json(version_id, mock_model)
            session.commit()

        with Session(engine) as session:
            products = session.exec(select(Product).where(Product.version_id == version_id)).all()
            assert len(products) == 3  # customer, customer_segment, product_catalog
            names = {p.name for p in products}
            assert "customer" in names
            assert "customer_segment" in names
            assert "product_catalog" in names

    def test_sync_creates_attributes(self, engine, mock_model, version_id):
        with Session(engine) as session:
            svc = ModelSyncService(session)
            svc.sync_from_model_json(version_id, mock_model)
            session.commit()

        with Session(engine) as session:
            attrs = session.exec(select(Attribute)).all()
            # customer: 4, customer_segment: 2, product_catalog: 4 = 10
            assert len(attrs) == 10

    def test_sync_creates_fk_links(self, engine, mock_model, version_id):
        with Session(engine) as session:
            svc = ModelSyncService(session)
            svc.sync_from_model_json(version_id, mock_model)
            session.commit()

        with Session(engine) as session:
            fk_links = session.exec(
                select(ForeignKeyLink).where(ForeignKeyLink.version_id == version_id)
            ).all()
            assert len(fk_links) == 1
            fk = fk_links[0]
            assert fk.source_domain == "sales"
            assert fk.source_product == "customer"
            assert fk.source_column == "segment_id"
            assert fk.target_domain == "sales"
            assert fk.target_product == "customer_segment"
            assert fk.target_column == "segment_id"

    def test_sync_idempotent(self, engine, mock_model, version_id):
        """Calling sync twice gives the same result (deletes and recreates)."""
        for _ in range(2):
            with Session(engine) as session:
                svc = ModelSyncService(session)
                svc.sync_from_model_json(version_id, mock_model)
                session.commit()

        with Session(engine) as session:
            domains = session.exec(select(Domain).where(Domain.version_id == version_id)).all()
            assert len(domains) == 2
            products = session.exec(select(Product).where(Product.version_id == version_id)).all()
            assert len(products) == 3

    def test_sync_version_isolation(self, engine, mock_model):
        """Two versions have independent records."""
        version_ids = []
        with Session(engine) as session:
            b = Business(name="Test Corp")
            session.add(b)
            session.flush()
            for i in range(2):
                v = ModelVersion(business_id=b.id, version=i + 1, status="completed")
                session.add(v)
                session.flush()
                version_ids.append(v.id)
            session.commit()

        for vid in version_ids:
            with Session(engine) as session:
                svc = ModelSyncService(session)
                svc.sync_from_model_json(vid, mock_model)
                session.commit()

        with Session(engine) as session:
            d1 = session.exec(select(Domain).where(Domain.version_id == version_ids[0])).all()
            d2 = session.exec(select(Domain).where(Domain.version_id == version_ids[1])).all()
            assert len(d1) == 2
            assert len(d2) == 2
            # They are different records
            ids1 = {d.id for d in d1}
            ids2 = {d.id for d in d2}
            assert ids1.isdisjoint(ids2)


# ---------------------------------------------------------------------------
# Delta table loading tests
# ---------------------------------------------------------------------------


def _make_sql_result(
    columns: list[str],
    rows: list[list],
    *,
    next_chunk_index=None,
    total_row_count=None,
    truncated: bool = False,
    statement_id: str = "stmt-1",
    state: str = "SUCCEEDED",
) -> MagicMock:
    """Build a mock SQL Statement Execution result with manifest and data.

    Emits the single-chunk shape by default (``next_chunk_index=None``,
    ``total_row_count`` inferred from ``rows``). Pass ``next_chunk_index`` to
    simulate the first of a multi-chunk INLINE result and ``truncated=True`` to
    exercise the truncation guard.
    """
    result = MagicMock()
    result.statement_id = statement_id
    result.status = MagicMock()
    result.status.error = None
    result.status.state = MagicMock()
    result.status.state.value = state
    col_mocks = [MagicMock(name=c) for c in columns]
    for cm, name in zip(col_mocks, columns):
        cm.name = name
    result.manifest.schema.columns = col_mocks
    result.manifest.truncated = truncated
    result.manifest.total_row_count = (
        total_row_count if total_row_count is not None else len(rows)
    )
    result.result.data_array = rows
    result.result.next_chunk_index = next_chunk_index
    return result


def _make_chunk(rows, *, next_chunk_index=None) -> MagicMock:
    """Build a mock follow-on result chunk (get_statement_result_chunk_n).

    ``rows`` may be ``None`` to simulate a chunk that carries no data_array.
    """
    chunk = MagicMock()
    chunk.data_array = rows
    chunk.next_chunk_index = next_chunk_index
    return chunk


def _make_empty_result() -> MagicMock:
    """Build a mock SQL result with no rows."""
    result = MagicMock()
    result.statement_id = "stmt-empty"
    result.status = MagicMock()
    result.status.error = None
    result.status.state = MagicMock()
    result.status.state.value = "SUCCEEDED"
    result.manifest.schema.columns = []
    result.manifest.truncated = False
    result.manifest.total_row_count = 0
    result.result.data_array = []
    result.result.next_chunk_index = None
    return result


class TestAssembleModelDict:
    """Test _assemble_model_dict — converting Delta query rows to model.json shape."""

    def test_basic_assembly(self):
        svc = ModelSyncService(session=MagicMock())
        domain_rows = [
            {"domain": "sales", "division": "ops", "description": "Sales domain",
             "database_name": "sales_db", "reference": "ref1"},
        ]
        product_rows = [
            {"domain": "sales", "product": "customer", "table_name": "customer",
             "description": "Customer table", "type": "Master", "data_type": "master_data",
             "primary_key": "customer_id", "subdomain": "", "reference": ""},
        ]
        attribute_rows = [
            {"domain": "sales", "product": "customer", "attribute": "customer_id",
             "column_name": "customer_id", "type": "BIGINT", "description": "PK",
             "business_glossary_term": "", "tags": "", "value_regex": "",
             "foreign_key_to": "", "reference": ""},
            {"domain": "sales", "product": "customer", "attribute": "name",
             "column_name": "name", "type": "STRING", "description": "Customer name",
             "business_glossary_term": "", "tags": "", "value_regex": "",
             "foreign_key_to": "", "reference": ""},
        ]

        model = svc._assemble_model_dict(domain_rows, product_rows, attribute_rows)

        assert len(model["domains"]) == 1
        d = model["domains"][0]
        assert d["name"] == "sales"
        assert d["division"] == "ops"
        assert len(d["products"]) == 1
        p = d["products"][0]
        assert p["product"] == "customer"
        assert p["primary_key"] == "customer_id"
        assert len(p["attributes"]) == 2
        assert p["attributes"][0]["attribute"] == "customer_id"

    def test_cross_domain_fks(self):
        svc = ModelSyncService(session=MagicMock())
        domain_rows = [
            {"domain": "sales", "division": "", "description": "", "database_name": "", "reference": ""},
            {"domain": "accounts", "division": "", "description": "", "database_name": "", "reference": ""},
        ]
        product_rows = [
            {"domain": "sales", "product": "order", "table_name": "order",
             "description": "", "type": "", "data_type": "", "primary_key": "order_id",
             "subdomain": "", "reference": ""},
            {"domain": "accounts", "product": "account", "table_name": "account",
             "description": "", "type": "", "data_type": "", "primary_key": "account_id",
             "subdomain": "", "reference": ""},
        ]
        attribute_rows = [
            {"domain": "sales", "product": "order", "attribute": "account_id",
             "column_name": "account_id", "type": "BIGINT", "description": "",
             "business_glossary_term": "", "tags": "", "value_regex": "",
             "foreign_key_to": "accounts.account.account_id", "reference": ""},
        ]

        model = svc._assemble_model_dict(domain_rows, product_rows, attribute_rows)
        fk = model["domains"][0]["products"][0]["attributes"][0]
        assert fk["foreign_key_to"] == "accounts.account.account_id"

    def test_empty_data(self):
        svc = ModelSyncService(session=MagicMock())
        model = svc._assemble_model_dict([], [], [])
        assert model == {"domains": []}


class TestLoadModelFromDeltaTables:
    """Test the Delta table loading method with mocked SQL execution."""

    def test_loads_model_from_three_tables(self):
        mock_ws = MagicMock()
        domain_cols = ["domain", "division", "description", "database_name", "reference"]
        product_cols = ["domain", "product", "table_name", "description", "type",
                        "data_type", "primary_key", "subdomain", "reference"]
        attr_cols = ["domain", "product", "attribute", "column_name", "type",
                     "description", "business_glossary_term", "tags", "value_regex",
                     "foreign_key_to", "reference"]

        call_count = 0

        def mock_execute(**kwargs):
            nonlocal call_count
            call_count += 1
            sql = kwargs["statement"]
            # Agent v27+ writes to `domain`, `product`, `attribute` tables
            # (no underscore prefix); the app was updated to match. Route
            # via `.domain`/`.product`/`.attribute` (with the leading dot
            # from the fully qualified name) so this test doesn't collide
            # with substrings like "domain" in WHERE clauses.
            if ".`domain`" in sql:
                return _make_sql_result(domain_cols, [
                    ["customers", "ops", "Customer domain", "cust_db", ""],
                ])
            elif ".`product`" in sql:
                return _make_sql_result(product_cols, [
                    ["customers", "customer", "customer", "Main customer table",
                     "Master", "master_data", "customer_id", "", ""],
                ])
            elif ".`attribute`" in sql:
                return _make_sql_result(attr_cols, [
                    ["customers", "customer", "customer_id", "customer_id",
                     "BIGINT", "Primary key", "", "", "", "", ""],
                    ["customers", "customer", "name", "name",
                     "STRING", "Customer name", "", "", "", "", ""],
                ])
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = mock_execute
        svc = ModelSyncService(session=MagicMock(), ws=mock_ws, warehouse_id="wh-123")
        result = svc.load_model_from_delta_tables("cat", "biz", "v1", "MVM")

        assert result is not None
        assert len(result["domains"]) == 1
        assert result["domains"][0]["name"] == "customers"
        assert len(result["domains"][0]["products"]) == 1
        assert len(result["domains"][0]["products"][0]["attributes"]) == 2
        # All 3 tables were queried
        assert call_count == 3

    def test_model_scope_normalized_in_where(self):
        """The widget contract accepts the long form but Delta stores only
        the abbreviated form. Normalising at the query boundary is what
        unblocked v3 auto-sync — before this fix the WHERE clause carried
        `Minimum Viable Model - MVM` verbatim and matched zero rows."""
        mock_ws = MagicMock()
        mock_ws.statement_execution.execute_statement.return_value = _make_empty_result()
        svc = ModelSyncService(session=MagicMock(), ws=mock_ws, warehouse_id="wh-123")
        svc.load_model_from_delta_tables("cat", "biz", "v1", "Minimum Viable Model - MVM")

        sql = mock_ws.statement_execution.execute_statement.call_args.kwargs["statement"]
        assert "model_scope = 'mvm'" in sql
        assert "Minimum Viable Model" not in sql

    def test_short_scope_passes_through(self):
        mock_ws = MagicMock()
        mock_ws.statement_execution.execute_statement.return_value = _make_empty_result()
        svc = ModelSyncService(session=MagicMock(), ws=mock_ws, warehouse_id="wh-123")
        svc.load_model_from_delta_tables("cat", "biz", "v2", "ecm")
        sql = mock_ws.statement_execution.execute_statement.call_args.kwargs["statement"]
        assert "model_scope = 'ecm'" in sql


class TestQueryDeltaTablePagination:
    """Delta result chunk pagination, truncation guard, and non-terminal polling
    (an internal tracker item - the TerraNova 13%/9% silent-truncation P1)."""

    COLS = ["domain", "product", "attribute"]

    def _svc(self, ws):
        return ModelSyncService(session=MagicMock(), ws=ws, warehouse_id="wh-1")

    def test_consumes_all_chunks(self):
        """Rows spanning three INLINE chunks are all fetched."""
        ws = MagicMock()
        first = _make_sql_result(
            self.COLS, [["d", "p", "a1"]], next_chunk_index=1, total_row_count=3
        )
        ws.statement_execution.execute_statement.return_value = first
        chunks = {
            1: _make_chunk([["d", "p", "a2"]], next_chunk_index=2),
            2: _make_chunk([["d", "p", "a3"]], next_chunk_index=None),
        }
        ws.statement_execution.get_statement_result_chunk_n.side_effect = (
            lambda _sid, idx: chunks[idx]
        )
        rows = self._svc(ws)._query_delta_table("c", "_metamodel", "attribute", "b", "v1")
        assert rows is not None
        assert [r["attribute"] for r in rows] == ["a1", "a2", "a3"]
        assert ws.statement_execution.get_statement_result_chunk_n.call_count == 2

    def test_mid_loop_empty_chunk_tolerated(self):
        """A follow-on chunk carrying zero rows does not break pagination."""
        ws = MagicMock()
        first = _make_sql_result(
            self.COLS, [["d", "p", "a1"]], next_chunk_index=1, total_row_count=2
        )
        ws.statement_execution.execute_statement.return_value = first
        chunks = {
            1: _make_chunk(None, next_chunk_index=2),
            2: _make_chunk([["d", "p", "a2"]], next_chunk_index=None),
        }
        ws.statement_execution.get_statement_result_chunk_n.side_effect = (
            lambda _sid, idx: chunks[idx]
        )
        rows = self._svc(ws)._query_delta_table("c", "_metamodel", "attribute", "b", "v1")
        assert rows is not None
        assert [r["attribute"] for r in rows] == ["a1", "a2"]

    def test_row_count_shortfall_raises(self):
        """Manifest declares more rows than were fetched (no further chunk)."""
        ws = MagicMock()
        first = _make_sql_result(
            self.COLS, [["d", "p", "a1"]], next_chunk_index=None, total_row_count=99
        )
        ws.statement_execution.execute_statement.return_value = first
        with pytest.raises(RuntimeError, match="total_row_count"):
            self._svc(ws)._query_delta_table("c", "_metamodel", "attribute", "b", "v1")

    def test_truncated_manifest_raises(self):
        ws = MagicMock()
        first = _make_sql_result(
            self.COLS, [["d", "p", "a1"]], next_chunk_index=None,
            total_row_count=1, truncated=True,
        )
        ws.statement_execution.execute_statement.return_value = first
        with pytest.raises(RuntimeError, match="truncated"):
            self._svc(ws)._query_delta_table("c", "_metamodel", "attribute", "b", "v1")

    def test_non_terminal_polls_then_reads(self):
        """A PENDING first response polls get_statement until SUCCEEDED."""
        ws = MagicMock()
        pending = _make_sql_result(self.COLS, [], state="PENDING")
        succeeded = _make_sql_result(
            self.COLS, [["d", "p", "a1"]], total_row_count=1, state="SUCCEEDED"
        )
        ws.statement_execution.execute_statement.return_value = pending
        ws.statement_execution.get_statement.return_value = succeeded
        with patch("vibe_modeling.backend.model_sync.time.sleep"):
            rows = self._svc(ws)._query_delta_table(
                "c", "_metamodel", "attribute", "b", "v1"
            )
        assert rows is not None
        assert [r["attribute"] for r in rows] == ["a1"]
        ws.statement_execution.get_statement.assert_called()

    def test_terminal_failure_raises(self):
        """A FAILED statement raises rather than returning a silent []."""
        ws = MagicMock()
        failed = _make_sql_result(self.COLS, [], state="FAILED")
        failed.status.error = None
        ws.statement_execution.execute_statement.return_value = failed
        with pytest.raises(RuntimeError, match="FAILED"):
            self._svc(ws)._query_delta_table("c", "_metamodel", "attribute", "b", "v1")

    def test_table_not_found_still_returns_none(self):
        """The TABLE_OR_VIEW_NOT_FOUND path is unchanged by pagination."""
        ws = MagicMock()
        result = _make_sql_result(self.COLS, [])
        result.status.error = MagicMock()
        result.status.error.message = "TABLE_OR_VIEW_NOT_FOUND: nope"
        ws.statement_execution.execute_statement.return_value = result
        assert self._svc(ws)._query_delta_table(
            "c", "_metamodel", "domain", "b", "v1"
        ) is None


# Minimal 1-domain payload for tests that isolate confidence / next-vibes /
# source-preference logic. sync_model's post-sync gate now raises
# _SyncEmptyError on a 0-domain source (B2), so these tests carry one domain
# rather than an empty `{"domains": []}`.
_MINIMAL_DOMAIN = {
    "name": "sales", "division": "", "description": "",
    "database_name": "", "references": "",
    "products": [{
        "product": "customer", "description": "", "type": "",
        "data_type": "", "primary_key": "id", "subdomain": "", "reference": "",
        "attributes": [
            {"attribute": "id", "type": "BIGINT", "description": "",
             "foreign_key_to": "", "business_glossary_term": "",
             "tags": "", "value_regex": "", "references": ""},
        ],
    }],
}


class TestSyncModel:
    """Test the sync_model() entry point that tries model.json then falls back
    to the Delta metamodel tables (source preference inverted in 0.6.6)."""

    def test_prefers_model_json(self, engine, version_id):
        mock_ws = MagicMock()
        with Session(engine) as session:
            svc = ModelSyncService(session, mock_ws, "wh-123")
            with patch.object(svc, "load_model_from_delta_tables") as mock_delta, \
                 patch.object(svc, "load_model_json_from_volumes") as mock_volumes:
                mock_volumes.return_value = {"model": {"domains": [_MINIMAL_DOMAIN]}}
                result = svc.sync_model(version_id, "cat", "biz", "v1")
                assert result is True
                mock_volumes.assert_called_once()
                mock_delta.assert_not_called()

    def test_falls_back_to_delta(self, engine, version_id):
        mock_ws = MagicMock()
        with Session(engine) as session:
            svc = ModelSyncService(session, mock_ws, "wh-123")
            with patch.object(svc, "load_model_from_delta_tables") as mock_delta, \
                 patch.object(svc, "load_model_json_from_volumes") as mock_volumes:
                mock_volumes.return_value = None
                mock_delta.return_value = {"domains": [_MINIMAL_DOMAIN]}
                result = svc.sync_model(version_id, "cat", "biz", "v1")
                assert result is True
                mock_volumes.assert_called_once()
                mock_delta.assert_called_once()

    def test_volumes_fallback_unwraps_envelope(self, engine, version_id):
        """Regression: the Volumes path receives the agent's envelope
        (`{"model_requirements": ..., "_vibe_session_metadata": ...,
        "model": {"domains": [...]}}`). Before the unwrap fix, the sync
        read `domains` from the envelope root and wrote 0 rows silently."""
        envelope = {
            "model_requirements": {"business_name": "biz"},
            "_vibe_session_metadata": {"confidence_score": 0.9},
            "model": {
                "type": "business",
                "name": "biz",
                "version": "v1_mvm",
                "description": "Test",
                "domains": [{
                    "name": "sales",
                    "division": "ops",
                    "description": "",
                    "database_name": "sales",
                    "references": "",
                    "products": [{
                        "product": "customer",
                        "description": "",
                        "type": "reference",
                        "data_type": "master_data",
                        "primary_key": "customer_id",
                        "subdomain": "",
                        "reference": "",
                        "attributes": [
                            {"attribute": "customer_id", "type": "BIGINT",
                             "description": "PK", "foreign_key_to": "",
                             "business_glossary_term": "", "tags": "",
                             "value_regex": "", "references": ""},
                            {"attribute": "customer_name", "type": "STRING",
                             "description": "", "foreign_key_to": "",
                             "business_glossary_term": "", "tags": "",
                             "value_regex": "", "references": ""},
                        ],
                    }],
                }],
            },
        }
        with Session(engine) as session:
            svc = ModelSyncService(session, ws=None, warehouse_id="")
            with patch.object(svc, "load_model_from_delta_tables", return_value=None), \
                 patch.object(svc, "load_model_json_from_volumes", return_value=envelope):
                assert svc.sync_model(version_id, "cat", "biz", "v1", "mvm") is True
            session.commit()

        with Session(engine) as session:
            domains = session.exec(select(Domain).where(Domain.version_id == version_id)).all()
            assert len(domains) == 1
            assert domains[0].name == "sales"
            products = session.exec(select(Product).where(Product.version_id == version_id)).all()
            assert len(products) == 1
            assert products[0].name == "customer"
            attrs = session.exec(select(Attribute)).all()
            assert len(attrs) == 2

    def test_returns_false_when_no_data(self, engine, version_id):
        mock_ws = MagicMock()
        with Session(engine) as session:
            svc = ModelSyncService(session, mock_ws, "wh-123")
            with patch.object(svc, "load_model_from_delta_tables", return_value=None), \
                 patch.object(svc, "load_model_json_from_volumes", return_value=None):
                result = svc.sync_model(version_id, "cat", "biz", "v1")
                assert result is False

    def test_delta_data_syncs_to_lakebase(self, engine, version_id):
        """End-to-end: Delta table data → Lakebase records."""
        mock_ws = MagicMock()
        delta_model = {
            "domains": [{
                "name": "finance",
                "division": "corp",
                "description": "Finance domain",
                "database_name": "fin_db",
                "references": "",
                "products": [{
                    "product": "invoice",
                    "description": "Invoice table",
                    "type": "Transactional",
                    "data_type": "transactional_data",
                    "primary_key": "invoice_id",
                    "subdomain": "billing",
                    "reference": "",
                    "attributes": [
                        {"attribute": "invoice_id", "type": "BIGINT", "description": "PK",
                         "foreign_key_to": "", "business_glossary_term": "", "tags": "",
                         "value_regex": "", "references": ""},
                        {"attribute": "account_id", "type": "BIGINT", "description": "FK",
                         "foreign_key_to": "accounts.account.account_id",
                         "business_glossary_term": "", "tags": "", "value_regex": "", "references": ""},
                    ],
                }],
            }],
        }
        with Session(engine) as session:
            svc = ModelSyncService(session, mock_ws, "wh-123")
            with patch.object(svc, "load_model_from_delta_tables", return_value=delta_model):
                svc.sync_model(version_id, "cat", "biz", "v1")
            session.commit()

        with Session(engine) as session:
            domains = session.exec(select(Domain).where(Domain.version_id == version_id)).all()
            assert len(domains) == 1
            assert domains[0].name == "finance"

            products = session.exec(select(Product).where(Product.version_id == version_id)).all()
            assert len(products) == 1
            assert products[0].subdomain == "billing"

            attrs = session.exec(select(Attribute)).all()
            assert len(attrs) == 2

            fks = session.exec(select(ForeignKeyLink).where(
                ForeignKeyLink.version_id == version_id
            )).all()
            assert len(fks) == 1
            assert fks[0].target_domain == "accounts"


class TestPostSyncGate:
    """HARD-FAIL post-sync sanity gate (an internal tracker item): sync_model
    raises when fewer elements are written than the source payload carries."""

    def _model(self):
        return {
            "domains": [{
                "name": "sales", "division": "", "description": "",
                "database_name": "", "references": "",
                "products": [{
                    "product": "customer", "description": "", "type": "",
                    "data_type": "", "primary_key": "id", "subdomain": "",
                    "reference": "",
                    "attributes": [
                        {"attribute": "id", "type": "BIGINT", "description": "",
                         "foreign_key_to": "", "business_glossary_term": "",
                         "tags": "", "value_regex": "", "references": ""},
                        {"attribute": "seg_id", "type": "BIGINT", "description": "",
                         "foreign_key_to": "d.p.c", "business_glossary_term": "",
                         "tags": "", "value_regex": "", "references": ""},
                    ],
                }],
            }],
        }

    def test_full_model_passes_gate(self, engine, version_id):
        mock_ws = MagicMock()
        with Session(engine) as session:
            svc = ModelSyncService(session, mock_ws, "wh-1")
            with patch.object(svc, "load_model_from_delta_tables", return_value=self._model()):
                assert svc.sync_model(version_id, "cat", "biz", "v1") is True

    def test_gate_raises_on_written_shortfall(self, engine, version_id):
        """If the writer reports fewer rows than the source carries, raise."""
        mock_ws = MagicMock()
        with Session(engine) as session:
            svc = ModelSyncService(session, mock_ws, "wh-1")
            with patch.object(svc, "load_model_from_delta_tables", return_value=self._model()), \
                 patch.object(svc, "sync_from_model_json",
                              return_value={"domains": 1, "products": 1,
                                            "attributes": 1, "fk_links": 0}):
                with pytest.raises(RuntimeError, match="post-sync sanity gate"):
                    svc.sync_model(version_id, "cat", "biz", "v1")

    def test_zero_domain_source_raises_sync_empty(self, engine, version_id):
        """G2: a payload that parsed to 0 domains must raise _SyncEmptyError,
        not pass vacuously (0 < 0 is False in the shortfall comparison)."""
        from vibe_modeling.backend.model_sync import _SyncEmptyError
        mock_ws = MagicMock()
        with Session(engine) as session:
            svc = ModelSyncService(session, mock_ws, "wh-1")
            with pytest.raises(_SyncEmptyError, match="0 domains"):
                svc._assert_sync_complete({"domains": []}, {})

    def test_zero_domain_via_sync_model_raises_sync_empty(self, engine, version_id):
        """Through the real sync_model path: an empty-domains model.json is
        loaded, written (0 rows), then the gate raises _SyncEmptyError."""
        from vibe_modeling.backend.model_sync import _SyncEmptyError
        mock_ws = MagicMock()
        with Session(engine) as session:
            svc = ModelSyncService(session, mock_ws, "wh-1")
            with patch.object(svc, "load_model_json_from_volumes",
                              return_value={"domains": []}):
                with pytest.raises(_SyncEmptyError):
                    svc.sync_model(version_id, "cat", "biz", "v1")

    def test_shortfall_raises_plain_runtimeerror_not_sync_empty(self, engine, version_id):
        """A genuine write shortfall (>=1 domain in source) must raise a plain
        RuntimeError so it lands incomplete_metadata, NOT _SyncEmptyError."""
        from vibe_modeling.backend.model_sync import _SyncEmptyError
        mock_ws = MagicMock()
        with Session(engine) as session:
            svc = ModelSyncService(session, mock_ws, "wh-1")
            with pytest.raises(RuntimeError) as exc_info:
                svc._assert_sync_complete(
                    self._model(),
                    {"domains": 1, "products": 0, "attributes": 0, "fk_links": 0},
                )
            assert not isinstance(exc_info.value, _SyncEmptyError)

    def test_count_source_elements_matches_writer_rules(self):
        from vibe_modeling.backend.model_sync import _count_source_elements
        counts = _count_source_elements(self._model())
        assert counts == {"domains": 1, "products": 1, "attributes": 2, "fk_links": 1}

    def test_count_source_unwraps_envelope(self):
        from vibe_modeling.backend.model_sync import _count_source_elements
        envelope = {"model_requirements": {}, "model": self._model()}
        assert _count_source_elements(envelope)["attributes"] == 2

    def test_sync_from_model_json_returns_counts(self, engine, version_id):
        with Session(engine) as session:
            svc = ModelSyncService(session)
            counts = svc.sync_from_model_json(version_id, self._model())
            session.commit()
        assert counts == {"domains": 1, "products": 1, "attributes": 2, "fk_links": 1}


class TestFieldParity:
    """Drift alarm (an internal tracker item): the 0.6.6 source inversion made
    model.json primary, so every field the Delta ``_assemble_model_dict`` path
    populates must be present in a real agent model.json (or on the documented
    accepted-delta allowlist), else a rendered column would silently blank."""

    # Fields ``_assemble_model_dict`` emits and ``sync_from_model_json`` reads,
    # keyed by level. model.json uses the SAME key except where noted.
    DOMAIN_FIELDS = ["division", "description", "database_name", "references"]
    PRODUCT_FIELDS = ["table_name", "description", "type", "data_type",
                      "primary_key", "subdomain", "reference"]
    ATTR_FIELDS = ["column_name", "type", "description", "business_glossary_term",
                   "tags", "value_regex", "foreign_key_to", "references"]

    # Fields the Delta path populates that a real agent model.json may omit and
    # that are cosmetic / agent-internal (documented accepted delta). Empty:
    # the advertising v0.7.1 model.json carries full parity.
    ACCEPTED_MISSING: set = set()

    def _real_model(self):
        with open(os.path.join(FIXTURES_DIR, "real_agent_model_sample.json")) as f:
            return json.load(f)["model"]

    def test_real_model_json_has_all_rendered_fields(self):
        model = self._real_model()
        domains = model["domains"]
        assert domains, "fixture must carry at least one domain"
        missing: set = set()
        for d in domains:
            assert "name" in d
            for f in self.DOMAIN_FIELDS:
                if f not in d:
                    missing.add(f"domain.{f}")
            for p in d.get("products", []):
                assert "name" in p or "product" in p
                for f in self.PRODUCT_FIELDS:
                    if f not in p:
                        missing.add(f"product.{f}")
                for a in p.get("attributes", []):
                    assert "name" in a or "attribute" in a
                    for f in self.ATTR_FIELDS:
                        if f not in a:
                            missing.add(f"attribute.{f}")
        unexpected = missing - self.ACCEPTED_MISSING
        assert not unexpected, (
            f"real model.json omits fields the Delta path populates: {sorted(unexpected)}. "
            f"If a field is cosmetic/agent-internal, add it to ACCEPTED_MISSING and "
            f"document the accepted delta; if it is rendered, the inversion must map it."
        )

    def test_real_model_json_syncs_full_structure(self, engine, version_id):
        """The real payload writes without a gate shortfall (parity holds end to end)."""
        model = self._real_model()
        with Session(engine) as session:
            svc = ModelSyncService(session, MagicMock(), "wh-1")
            with patch.object(svc, "load_model_json_from_volumes", return_value=model):
                assert svc.sync_model(version_id, "cat", "biz", "v1", "ecm") is True
            session.commit()
        with Session(engine) as session:
            attrs = session.exec(select(Attribute)).all()
            assert len(attrs) > 0
            # A populated rendered field survived the write (column_name).
            assert any(a.column_name for a in attrs)


class TestUnwrapSpecDescription:
    """REGRESSION (an internal tracker item, 2026-04-27): vibe-iterate
    sometimes serializes the entire add-domain spec dict into the
    ``description`` field. Defensive helper unwraps to the inner
    ``description`` string when the value looks like JSON."""

    def test_plain_string_passes_through(self):
        from vibe_modeling.backend.model_sync import _unwrap_spec_description
        assert _unwrap_spec_description("Plain text") == "Plain text"

    def test_empty_string_passes_through(self):
        from vibe_modeling.backend.model_sync import _unwrap_spec_description
        assert _unwrap_spec_description("") == ""

    def test_unwraps_json_with_description_key(self):
        from vibe_modeling.backend.model_sync import _unwrap_spec_description
        spec = '{"domain_name": "loyalty", "division": "business", "description": "Authoritative loyalty source", "products": ["loyalty_tier"]}'
        assert _unwrap_spec_description(spec) == "Authoritative loyalty source"

    def test_json_without_description_key_returns_original(self):
        """If the JSON shape doesn't carry a description, leave it
        alone — the caller can decide what to do."""
        from vibe_modeling.backend.model_sync import _unwrap_spec_description
        spec = '{"foo": "bar"}'
        assert _unwrap_spec_description(spec) == spec

    def test_malformed_json_returns_original(self):
        from vibe_modeling.backend.model_sync import _unwrap_spec_description
        bad = '{"not really json'
        assert _unwrap_spec_description(bad) == bad

    def test_non_string_coerces_safely(self):
        from vibe_modeling.backend.model_sync import _unwrap_spec_description
        assert _unwrap_spec_description(None) == ""
        assert _unwrap_spec_description(42) == "42"


class TestNextVibesTxtConversion:
    """Agent v0.6.0+ writes ``next_vibes.txt`` with a plain-text
    ``**PRIORITY N — kind: target** — description`` format. The sync-time
    parser builds the structured ``_next_vibe_metadata.findings`` payload the
    materializer consumes — no lossy instructions blob.
    """

    def test_priority_lines_become_findings(self):
        from vibe_modeling.backend.model_sync import _next_vibes_payload_from_txt

        text = (
            "**Model Quality Score: 76/100**\n\n"
            "**PRIORITY 1 — remove_fk: customer.profile** — remove FK on column fulfillment_location_id\n"
            "**PRIORITY 2 — connect_table: sale.order_line** — add column sku_id\n"
        )
        payload = _next_vibes_payload_from_txt(text)
        # Stored as 0..1 fraction so the UI's `* 100` rendering yields "76%".
        assert payload["_next_vibe_metadata"]["confidence_score"] == 0.76
        assert payload["_next_vibe_metadata"]["status"] == "needs_work"
        assert "business_context" not in payload
        findings = payload["_next_vibe_metadata"]["findings"]
        assert len(findings) == 2
        assert {f["target"] for f in findings} == {"customer.profile", "sale.order_line"}
        assert all(f["priority"] == "high" for f in findings)

    def test_no_priorities_returns_no_findings(self):
        from vibe_modeling.backend.model_sync import _next_vibes_payload_from_txt

        text = "**Model Quality Score: 90/100**\nNo actionable suggestions."
        payload = _next_vibes_payload_from_txt(text)
        assert payload["_next_vibe_metadata"]["findings"] == []
        assert payload["_next_vibe_metadata"]["confidence_score"] == 0.9
        assert payload["_next_vibe_metadata"]["status"] == "healthy"


class TestExtractConfidenceScore:
    def test_top_level_float(self):
        assert _extract_confidence_score({"confidence_score": 0.87}) == pytest.approx(0.87)

    def test_missing_returns_none(self):
        assert _extract_confidence_score({}) is None
        assert _extract_confidence_score({"confidence_score": None}) is None
        assert _extract_confidence_score({"confidence_score": "high"}) is None


class TestSyncModelPopulatesConfidence:
    """Regression guard: `sync_model` must copy the agent's confidence score
    onto the ModelVersion row. Missed on recent runs because the write side
    was never wired up when the field was added to the DB model."""

    def test_sync_populates_confidence_from_model_json_top_level(self, engine, version_id):
        """External-import tool shape: flat model with top-level confidence_score.
        Kept as a legitimate input shape independent of the agent envelope."""
        model_data = {"domains": [_MINIMAL_DOMAIN], "confidence_score": 0.73}
        with Session(engine) as session:
            svc = ModelSyncService(session, ws=None, warehouse_id="")
            with patch.object(svc, "load_model_from_delta_tables", return_value=None), \
                 patch.object(svc, "load_model_json_from_volumes", return_value=model_data):
                assert svc.sync_model(version_id, "cat", "biz", "v1", "mvm") is True
            session.commit()

        with Session(engine) as session:
            mv = session.get(ModelVersion, version_id)
            assert mv is not None
            assert mv.confidence_score == pytest.approx(0.73)

    def test_sync_populates_confidence_from_vibe_session_metadata(self, engine, version_id):
        """Agent Volumes-fallback envelope shape: confidence lives in the
        envelope's `_vibe_session_metadata`, domains live under `.model`."""
        model_data = {
            "model_requirements": {"business_name": "biz"},
            "_vibe_session_metadata": {"confidence_score": 0.91},
            "model": {"domains": [_MINIMAL_DOMAIN]},
        }
        with Session(engine) as session:
            svc = ModelSyncService(session, ws=None, warehouse_id="")
            with patch.object(svc, "load_model_from_delta_tables", return_value=None), \
                 patch.object(svc, "load_model_json_from_volumes", return_value=model_data):
                svc.sync_model(version_id, "cat", "biz", "v1", "mvm")
            session.commit()

        with Session(engine) as session:
            mv = session.get(ModelVersion, version_id)
            assert mv.confidence_score == pytest.approx(0.91)

    def test_sync_from_delta_falls_back_to_next_vibes_confidence(self, engine, version_id):
        """Delta metamodel tables don't carry confidence — recover it from
        the sibling next_vibes.json artifact."""
        delta_data = {"domains": [_MINIMAL_DOMAIN]}
        next_vibes = {"_next_vibe_metadata": {"confidence_score": 88, "findings": []}}
        mock_ws = MagicMock()
        with Session(engine) as session:
            svc = ModelSyncService(session, mock_ws, "wh-123")
            with patch.object(svc, "load_model_from_delta_tables", return_value=delta_data), \
                 patch.object(svc, "load_next_vibes_from_volumes", return_value=(next_vibes, None)):
                svc.sync_model(version_id, "cat", "biz", "v1", "mvm")
            session.commit()

        with Session(engine) as session:
            mv = session.get(ModelVersion, version_id)
            assert mv.confidence_score == pytest.approx(0.88)

    def test_sync_leaves_confidence_null_when_absent(self, engine, version_id):
        with Session(engine) as session:
            svc = ModelSyncService(session, ws=None, warehouse_id="")
            with patch.object(svc, "load_model_from_delta_tables",
                              return_value={"domains": [_MINIMAL_DOMAIN]}):
                svc.sync_model(version_id, "cat", "biz", "v1", "mvm")
            session.commit()

        with Session(engine) as session:
            mv = session.get(ModelVersion, version_id)
            assert mv.confidence_score is None


_SYNC_NEXT_VIBES_TXT = (
    "**Model Quality Score: 76/100**\n\n"
    "**Static Analysis Findings (1 actionable):**\n"
    "  - [SA:unlinked_fk] Column customer.profile.region_id looks like an FK\n\n"
    "**PRIORITY 1 — remove_fk: customer.profile** — drop fulfillment_location_id\n\n"
    "Other known issues from static analysis (1):\n"
    "  - sale.order_line description is empty\n\n"
    "Deterministic score: 76/100\n"
)


class TestSyncModelMaterializesNextVibesDirectly:
    """The single MUST: a completed run sync ingests ``next_vibes.txt`` into
    structured ``VibeInput(origin=agent_next_vibe)`` rows DIRECTLY at sync
    time — no blob is written, and the materializer is the producer.
    """

    def test_sync_creates_structured_inputs_and_artifact_no_blob(
        self, engine, version_id
    ):
        from vibe_modeling.backend.db_models import (
            RunArtifact,
            VibeInput,
            VibeInputContextLink,
        )
        from vibe_modeling.backend.model_sync import _next_vibes_payload_from_txt
        from vibe_modeling.backend.models import VibeInputOrigin

        payload = _next_vibes_payload_from_txt(_SYNC_NEXT_VIBES_TXT)
        nv_path = "/Volumes/cat/_metamodel/vol_root/business/biz/mvm_v1/vibes/next_vibes.txt"
        delta_data = {"domains": [_MINIMAL_DOMAIN]}
        mock_ws = MagicMock()

        with Session(engine) as session:
            svc = ModelSyncService(session, mock_ws, "wh-1")
            with patch.object(svc, "load_model_from_delta_tables", return_value=delta_data), \
                 patch.object(
                     svc, "load_next_vibes_from_volumes",
                     return_value=(payload, nv_path),
                 ):
                assert svc.sync_model(version_id, "cat", "biz", "v1", "mvm") is True
            session.commit()

        with Session(engine) as session:
            # 1 SA + 1 PRIORITY + 1 other = 3 structured inputs, created DIRECTLY.
            rows = session.exec(
                select(VibeInput)
                .join(
                    VibeInputContextLink,
                    VibeInputContextLink.input_id == VibeInput.id,
                )
                .where(
                    VibeInputContextLink.version_id == version_id,
                    VibeInput.origin == VibeInputOrigin.AGENT_NEXT_VIBE.value,
                )
            ).all()
            assert len(rows) == 3
            assert all(r.confidence_score == pytest.approx(0.76) for r in rows)

            # The raw artifact is registered as a downloadable RunArtifact.
            arts = session.exec(
                select(RunArtifact).where(
                    RunArtifact.model_version_id == version_id,
                    RunArtifact.artifact_type == "next_vibes_txt",
                )
            ).all()
            assert len(arts) == 1
            assert arts[0].file_path == nv_path

            # No blob: the column is gone from the ORM model entirely.
            assert not hasattr(ModelVersion, "next_vibes_json")


class TestVolumePathCasing:
    """Regression: businesses whose name has spaces/caps/punctuation must
    resolve to the agent's sanitized folder segment on Volume reads, never the
    raw ``business_name`` (the 'Terranova Copy' perpetual re-sync bug — the app
    read ``.../business/Terranova Copy/...`` while the agent wrote
    ``.../business/terranova_copy/...``).
    """

    def test_load_model_json_uses_sanitized_segment(self):
        ws = MagicMock()
        requested: list[str] = []

        def fake_download(path):
            requested.append(path)
            raise FileNotFoundError()

        def fake_list(path):
            requested.append(path)
            raise FileNotFoundError()

        ws.files.download.side_effect = fake_download
        ws.files.list_directory_contents.side_effect = fake_list

        svc = ModelSyncService(session=MagicMock(), ws=ws, warehouse_id="w1")
        result = svc.load_model_json_from_volumes("cat", "Terranova Copy", "2", "ecm")

        assert result is None
        assert requested, "expected at least one Volume path probe"
        for p in requested:
            assert "terranova_copy" in p, p
            assert "Terranova Copy" not in p, p
            assert "Terranova" not in p, p
        # The canonical model.json probe hits the sanitized folder exactly.
        assert (
            "/Volumes/cat/_metamodel/vol_root/business/terranova_copy/ecm_v2/model.json"
            in requested
        )

    def test_load_next_vibes_uses_sanitized_segment(self):
        ws = MagicMock()
        requested: list[str] = []

        def fake_download(path):
            requested.append(path)
            raise FileNotFoundError()

        ws.files.download.side_effect = fake_download

        svc = ModelSyncService(session=MagicMock(), ws=ws, warehouse_id="w1")
        result = svc.load_next_vibes_from_volumes("cat", "Terranova Copy", "v2", "ecm")

        assert result == (None, None)
        assert requested, "expected at least one Volume path probe"
        for p in requested:
            assert "terranova_copy" in p, p
            assert "Terranova Copy" not in p, p
            assert "Terranova" not in p, p
        assert any(
            p.startswith(
                "/Volumes/cat/_metamodel/vol_root/business/terranova_copy/ecm_v2"
            )
            for p in requested
        )


class TestNestedReadFallback:
    """Volume readers probe the nested (agent 4.9.8+) ``v{N}/{scope}`` layout
    FIRST and fall back to the legacy flat ``{scope}_v{N}`` layout so a
    pre-upgrade row whose artifacts the current agent wrote flat still resolves.
    """

    _NESTED_MJ = (
        "/Volumes/cat/_metamodel/vol_root/business/terranova_copy/v2/ecm/model.json"
    )
    _FLAT_MJ = (
        "/Volumes/cat/_metamodel/vol_root/business/terranova_copy/ecm_v2/model.json"
    )

    def test_model_json_probes_nested_before_flat(self):
        ws = MagicMock()
        requested: list[str] = []

        def fake_download(path):
            requested.append(path)
            if path == self._FLAT_MJ:
                resp = MagicMock()
                resp.contents.read.return_value = json.dumps({"domains": []}).encode()
                return resp
            raise FileNotFoundError()

        def fake_list(path):
            requested.append(path)
            raise FileNotFoundError()

        ws.files.download.side_effect = fake_download
        ws.files.list_directory_contents.side_effect = fake_list

        svc = ModelSyncService(session=MagicMock(), ws=ws, warehouse_id="w1")
        result = svc.load_model_json_from_volumes("cat", "Terranova Copy", "2", "ecm")

        # Flat artifact still resolves via fallback.
        assert result == {"domains": []}
        # Nested model.json was probed strictly before the flat one.
        assert self._NESTED_MJ in requested
        assert self._FLAT_MJ in requested
        assert requested.index(self._NESTED_MJ) < requested.index(self._FLAT_MJ)

    def test_model_json_prefers_nested_when_present(self):
        ws = MagicMock()
        requested: list[str] = []

        def fake_download(path):
            requested.append(path)
            if path == self._NESTED_MJ:
                resp = MagicMock()
                resp.contents.read.return_value = json.dumps(
                    {"domains": [{"name": "d"}]}
                ).encode()
                return resp
            raise FileNotFoundError()

        ws.files.download.side_effect = fake_download
        ws.files.list_directory_contents.side_effect = FileNotFoundError()

        svc = ModelSyncService(session=MagicMock(), ws=ws, warehouse_id="w1")
        result = svc.load_model_json_from_volumes("cat", "Terranova Copy", "2", "ecm")

        assert result == {"domains": [{"name": "d"}]}
        # The flat model.json is never reached once nested resolves.
        assert self._FLAT_MJ not in requested

    def test_next_vibes_probes_nested_before_flat(self):
        ws = MagicMock()
        requested: list[str] = []
        flat_txt = (
            "/Volumes/cat/_metamodel/vol_root/business/terranova_copy/"
            "ecm_v2/vibes/next_vibes.txt"
        )

        def fake_download(path):
            requested.append(path)
            if path == flat_txt:
                resp = MagicMock()
                resp.contents.read.return_value = b"[P1] fix it (Score: 0.9)"
                return resp
            raise FileNotFoundError()

        ws.files.download.side_effect = fake_download

        svc = ModelSyncService(session=MagicMock(), ws=ws, warehouse_id="w1")
        payload, resolved = svc.load_next_vibes_from_volumes(
            "cat", "Terranova Copy", "2", "ecm"
        )

        # Flat next_vibes still resolves via fallback.
        assert payload is not None
        assert resolved == flat_txt
        # A nested candidate was probed before the flat one that resolved.
        nested_probes = [p for p in requested if "/v2/ecm/" in p]
        assert nested_probes
        assert requested.index(nested_probes[0]) < requested.index(flat_txt)


class TestVersionProvenanceCapture:
    """`_capture_run_metadata` stamps agent_version/release_version from the
    model.json envelope; a version-field-less payload leaves them untouched
    (no clobber-with-NULL on a Delta re-sync)."""

    def _fresh_version(self, engine):
        with Session(engine) as session:
            b = Business(name="Prov Corp")
            session.add(b)
            session.flush()
            v = ModelVersion(business_id=b.id, version=1, status="completed")
            session.add(v)
            session.commit()
            return v.id

    def test_capture_populates_from_4_9_8_envelope(self, engine):
        vid = self._fresh_version(engine)
        envelope = {
            "agent_version": "4.9.8",
            "release_version": "0.8.0",
            "type": "business",
            "domains": [],
        }
        with Session(engine) as session:
            svc = ModelSyncService(session)
            svc._capture_run_metadata(vid, "cat", "prov_corp", "v1", "ecm", envelope)
            session.commit()

        with Session(engine) as session:
            mv = session.get(ModelVersion, vid)
            assert mv.agent_version == "4.9.8"
            assert mv.release_version == "0.8.0"

    def test_delta_payload_does_not_clobber(self, engine):
        vid = self._fresh_version(engine)
        envelope = {"agent_version": "4.9.8", "release_version": "0.8.0", "type": "business"}
        with Session(engine) as session:
            svc = ModelSyncService(session)
            svc._capture_run_metadata(vid, "cat", "prov_corp", "v1", "ecm", envelope)
            session.commit()

        # A subsequent Delta-fallback sync carries no version fields — the
        # earlier provenance must survive.
        delta_payload = {"domains": []}
        with Session(engine) as session:
            svc = ModelSyncService(session)
            svc._capture_run_metadata(vid, "cat", "prov_corp", "v1", "ecm", delta_payload)
            session.commit()

        with Session(engine) as session:
            mv = session.get(ModelVersion, vid)
            assert mv.agent_version == "4.9.8"
            assert mv.release_version == "0.8.0"
