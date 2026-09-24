"""Tests for oob_detector.py — out-of-band model version detection."""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from unittest.mock import MagicMock

from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

from vibe_modeling.backend.db_models import Business, ModelVersion
from vibe_modeling.backend.oob_detector import OobDetector


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


def _make_sql_result(columns, rows):
    result = MagicMock()
    result.status = MagicMock()
    result.status.error = None
    col_mocks = [MagicMock(name=c) for c in columns]
    for cm, name in zip(col_mocks, columns):
        cm.name = name
    result.manifest.schema.columns = col_mocks
    result.result.data_array = rows
    return result


def _make_empty_result():
    result = MagicMock()
    result.status = MagicMock()
    result.status.error = None
    result.manifest.schema.columns = []
    result.result.data_array = []
    return result


COLS = ["business", "version", "model_scope", "completion_date"]


class TestOobDetector:

    def test_detects_missing_version(self, engine, mock_ws):
        """Version in Delta but not in Lakebase is detected."""
        delta_rows = [
            ["acme_corp", "v1", "MVM", "2024-01-01"],
        ]
        mock_ws.statement_execution.execute_statement.return_value = (
            _make_sql_result(COLS, delta_rows)
        )

        with Session(engine) as session:
            detector = OobDetector(session, mock_ws, "wh-123")
            result = detector.detect("test_catalog")

        assert len(result["missing_versions"]) == 1
        assert result["missing_versions"][0]["business"] == "acme_corp"
        assert result["missing_versions"][0]["version"] == "v1"
        assert result["missing_versions"][0]["business_id"] is None
        assert result["errors"] == []

    def test_known_version_not_flagged(self, engine, mock_ws):
        """Version already in Lakebase is not reported as missing."""
        with Session(engine) as session:
            b = Business(name="acme_corp")
            session.add(b)
            session.flush()
            session.add(ModelVersion(business_id=b.id, version=1, status="completed"))
            session.commit()

        delta_rows = [
            ["acme_corp", "v1", "MVM", "2024-01-01"],
        ]
        mock_ws.statement_execution.execute_statement.return_value = (
            _make_sql_result(COLS, delta_rows)
        )

        with Session(engine) as session:
            detector = OobDetector(session, mock_ws, "wh-123")
            result = detector.detect("test_catalog")

        assert len(result["missing_versions"]) == 0

    def test_mixed_known_and_missing(self, engine, mock_ws):
        """Only unknown versions are detected."""
        with Session(engine) as session:
            b = Business(name="acme_corp")
            session.add(b)
            session.flush()
            session.add(ModelVersion(business_id=b.id, version=1, status="completed"))
            session.commit()

        delta_rows = [
            ["acme_corp", "v1", "MVM", "2024-01-01"],
            ["acme_corp", "v2", "MVM", "2024-06-01"],
        ]
        mock_ws.statement_execution.execute_statement.return_value = (
            _make_sql_result(COLS, delta_rows)
        )

        with Session(engine) as session:
            detector = OobDetector(session, mock_ws, "wh-123")
            result = detector.detect("test_catalog")

        assert len(result["missing_versions"]) == 1
        assert result["missing_versions"][0]["version"] == "v2"
        # business_id should be set since the business exists
        assert result["missing_versions"][0]["business_id"] is not None

    def test_table_not_found(self, engine, mock_ws):
        """If _business table doesn't exist, returns error."""
        mock_ws.statement_execution.execute_statement.side_effect = RuntimeError(
            "TABLE_OR_VIEW_NOT_FOUND"
        )

        with Session(engine) as session:
            detector = OobDetector(session, mock_ws, "wh-123")
            result = detector.detect("bad_catalog")

        assert len(result["errors"]) == 1
        assert "not found" in result["errors"][0]
        assert result["missing_versions"] == []

    def test_empty_delta_returns_no_missing(self, engine, mock_ws):
        """If Delta has no completed versions, nothing is missing."""
        mock_ws.statement_execution.execute_statement.return_value = _make_empty_result()

        with Session(engine) as session:
            detector = OobDetector(session, mock_ws, "wh-123")
            result = detector.detect("test_catalog")

        assert result["missing_versions"] == []
        assert result["errors"] == []

    def test_unknown_business_detected(self, engine, mock_ws):
        """Versions from a business not yet in Lakebase are detected with business_id=None."""
        delta_rows = [
            ["new_biz", "v1", "ECM", "2024-03-01"],
            ["new_biz", "v2", "ECM", "2024-04-01"],
        ]
        mock_ws.statement_execution.execute_statement.return_value = (
            _make_sql_result(COLS, delta_rows)
        )

        with Session(engine) as session:
            detector = OobDetector(session, mock_ws, "wh-123")
            result = detector.detect("test_catalog")

        assert len(result["missing_versions"]) == 2
        assert all(mv["business_id"] is None for mv in result["missing_versions"])
