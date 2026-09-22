"""Tests for deployment_verifier.py — logical vs deployed model comparison."""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from unittest.mock import MagicMock

from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from vibe_modeling.backend.db_models import (
    Attribute, Business, Domain, ModelVersion, Product,
)
from vibe_modeling.backend.deployment_verifier import DeploymentVerifier


@pytest.fixture
def engine():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    return engine


@pytest.fixture
def mock_ws():
    return MagicMock()


def _make_sql_result(rows):
    result = MagicMock()
    result.status = MagicMock()
    result.status.error = None
    result.result.data_array = rows
    return result


def _make_empty_result():
    result = MagicMock()
    result.status = MagicMock()
    result.status.error = None
    result.result.data_array = []
    return result


def _seed_model(session):
    """Seed a business with a version, domain, product, and attributes."""
    b = Business(name="test_biz")
    session.add(b)
    session.flush()

    mv = ModelVersion(business_id=b.id, version=1, status="completed", uc_catalog="test_cat")
    session.add(mv)
    session.flush()

    d = Domain(
        version_id=mv.id, name="core", database_name="core_db",
        division="Eng", description="Core domain",
    )
    session.add(d)
    session.flush()

    p = Product(
        version_id=mv.id, domain_id=d.id, name="widget",
        table_name="widget", description="Widget records",
        type="Master", primary_key="widget_id",
    )
    session.add(p)
    session.flush()

    session.add(Attribute(
        product_id=p.id, name="widget_id", column_name="widget_id",
        type="BIGINT", description="PK",
    ))
    session.add(Attribute(
        product_id=p.id, name="name", column_name="name",
        type="STRING", description="Widget name",
    ))
    session.flush()

    return b, mv, d, p


class TestCatalogCheck:
    def test_catalog_exists(self, engine, mock_ws):
        mock_ws.statement_execution.execute_statement.return_value = (
            _make_sql_result([["test_cat"]])
        )
        with Session(engine) as session:
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.check_catalog("test_cat")

        assert result["exists"] is True
        assert result["catalog"] == "test_cat"
        assert result["error"] is None

    def test_catalog_not_found(self, engine, mock_ws):
        mock_ws.statement_execution.execute_statement.return_value = _make_empty_result()
        with Session(engine) as session:
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.check_catalog("missing_cat")

        assert result["exists"] is False

    def test_catalog_check_fallback(self, engine, mock_ws):
        """Falls back to information_schema if SHOW CATALOGS fails."""
        call_count = 0

        def side_effect(**kwargs):
            nonlocal call_count
            call_count += 1
            if call_count == 1:
                raise RuntimeError("SHOW CATALOGS not supported")
            return _make_sql_result([["test_cat"]])

        mock_ws.statement_execution.execute_statement.side_effect = side_effect
        with Session(engine) as session:
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.check_catalog("test_cat")

        assert result["exists"] is True
        assert call_count == 2


class TestUcSchema:
    def test_returns_structured_data(self, engine, mock_ws):
        """Returns tables, columns, PKs, FKs from information_schema queries."""
        call_count = 0

        def side_effect(**kwargs):
            nonlocal call_count
            call_count += 1
            sql = kwargs.get("statement", "")
            if "information_schema`.`tables" in sql:
                return _make_sql_result([
                    ["core_db", "widget", "BASE TABLE"],
                ])
            if "information_schema`.`columns" in sql:
                return _make_sql_result([
                    ["core_db", "widget", "widget_id", "BIGINT", "1"],
                    ["core_db", "widget", "name", "STRING", "2"],
                ])
            # PKs and FKs return empty
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = side_effect

        with Session(engine) as session:
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.get_uc_schema("test_cat", ["core_db"])

        assert len(result["tables"]) == 1
        assert result["tables"][0]["table"] == "widget"
        assert len(result["columns"]) == 2
        assert result["primary_keys"] == []
        assert result["foreign_keys"] == []

    def test_empty_schemas_returns_empty(self, engine, mock_ws):
        with Session(engine) as session:
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.get_uc_schema("test_cat", [])

        assert result == {"tables": [], "columns": [], "primary_keys": [], "foreign_keys": []}


class TestCompare:
    def test_matching_tables(self, engine, mock_ws):
        """Tables in both logical and UC are reported in 'both'."""
        with Session(engine) as session:
            _seed_model(session)
            session.commit()

        def side_effect(**kwargs):
            sql = kwargs.get("statement", "")
            if "information_schema`.`tables" in sql:
                return _make_sql_result([["core_db", "widget", "BASE TABLE"]])
            if "information_schema`.`columns" in sql:
                return _make_sql_result([
                    ["core_db", "widget", "widget_id", "BIGINT", "1"],
                    ["core_db", "widget", "name", "STRING", "2"],
                ])
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = side_effect

        with Session(engine) as session:
            mv = session.exec(
                __import__("sqlmodel", fromlist=["select"]).select(ModelVersion)
            ).first()
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.compare(mv.id, "test_cat")

        assert result["summary"]["matching"] == 1
        assert result["summary"]["model_only"] == 0
        assert result["summary"]["uc_only"] == 0
        assert len(result["tables"]["both"]) == 1
        # No column diffs since types match
        assert result["tables"]["both"][0]["column_diffs"] == []

    def test_model_only_table(self, engine, mock_ws):
        """Table in logical model but not deployed is reported as model_only."""
        with Session(engine) as session:
            _seed_model(session)
            session.commit()

        # UC returns no tables
        mock_ws.statement_execution.execute_statement.return_value = _make_empty_result()

        with Session(engine) as session:
            mv = session.exec(
                __import__("sqlmodel", fromlist=["select"]).select(ModelVersion)
            ).first()
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.compare(mv.id, "test_cat")

        assert result["summary"]["model_only"] == 1
        assert result["summary"]["uc_only"] == 0
        assert result["tables"]["model_only"][0]["table"] == "widget"

    def test_column_type_mismatch(self, engine, mock_ws):
        """Column type differences are detected."""
        with Session(engine) as session:
            _seed_model(session)
            session.commit()

        def side_effect(**kwargs):
            sql = kwargs.get("statement", "")
            if "information_schema`.`tables" in sql:
                return _make_sql_result([["core_db", "widget", "BASE TABLE"]])
            if "information_schema`.`columns" in sql:
                return _make_sql_result([
                    ["core_db", "widget", "widget_id", "BIGINT", "1"],
                    # name has a different type in UC
                    ["core_db", "widget", "name", "VARCHAR(255)", "2"],
                ])
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = side_effect

        with Session(engine) as session:
            mv = session.exec(
                __import__("sqlmodel", fromlist=["select"]).select(ModelVersion)
            ).first()
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.compare(mv.id, "test_cat")

        diffs = result["tables"]["both"][0]["column_diffs"]
        assert len(diffs) == 1
        assert diffs[0]["column"] == "name"
        assert diffs[0]["status"] == "type_mismatch"
        assert result["summary"]["with_diffs"] == 1

    def test_uc_only_table(self, engine, mock_ws):
        """Table deployed in UC but not in logical model is reported as uc_only."""
        with Session(engine) as session:
            _seed_model(session)
            session.commit()

        def side_effect(**kwargs):
            sql = kwargs.get("statement", "")
            if "information_schema`.`tables" in sql:
                return _make_sql_result([
                    ["core_db", "widget", "BASE TABLE"],
                    ["core_db", "extra_table", "BASE TABLE"],
                ])
            if "information_schema`.`columns" in sql:
                return _make_sql_result([
                    ["core_db", "widget", "widget_id", "BIGINT", "1"],
                    ["core_db", "widget", "name", "STRING", "2"],
                    ["core_db", "extra_table", "id", "INT", "1"],
                ])
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = side_effect

        with Session(engine) as session:
            mv = session.exec(
                __import__("sqlmodel", fromlist=["select"]).select(ModelVersion)
            ).first()
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.compare(mv.id, "test_cat")

        assert result["summary"]["uc_only"] == 1
        assert result["tables"]["uc_only"][0]["table"] == "extra_table"


class TestColumnDiff:
    def test_identical(self):
        diffs = DeploymentVerifier._column_diff(
            {"id": "BIGINT", "name": "STRING"},
            {"id": "BIGINT", "name": "STRING"},
        )
        assert diffs == []

    def test_case_insensitive(self):
        diffs = DeploymentVerifier._column_diff(
            {"id": "bigint"},
            {"id": "BIGINT"},
        )
        assert diffs == []

    def test_model_only_column(self):
        diffs = DeploymentVerifier._column_diff(
            {"id": "BIGINT", "extra": "STRING"},
            {"id": "BIGINT"},
        )
        assert len(diffs) == 1
        assert diffs[0]["status"] == "model_only"

    def test_uc_only_column(self):
        diffs = DeploymentVerifier._column_diff(
            {"id": "BIGINT"},
            {"id": "BIGINT", "extra": "STRING"},
        )
        assert len(diffs) == 1
        assert diffs[0]["status"] == "uc_only"

    def test_type_mismatch(self):
        diffs = DeploymentVerifier._column_diff(
            {"id": "BIGINT"},
            {"id": "INT"},
        )
        assert len(diffs) == 1
        assert diffs[0]["status"] == "type_mismatch"
