"""Tests for initial_sync.py — discovering businesses from Delta metamodel tables."""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from contextlib import contextmanager
from unittest.mock import MagicMock, patch

from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

from vibe_modeling.backend.db_models import Business, Industry, ModelVersion
from vibe_modeling.backend.initial_sync import InitialSyncService
from vibe_modeling.backend.model_sync import ModelSyncService


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


BUSINESS_COLS = ["business", "version", "model_scope", "processing_status",
                 "completed_percent", "completion_date"]


class TestDiscoverAndSync:

    def test_discovers_and_creates_business(self, engine, mock_ws):
        """Discovers a business from the metamodel business table and creates it in Lakebase."""
        rows = [
            ["retail_corp", "v1", "MVM", "done", "100.0", "2024-01-01"],
        ]

        call_count = 0

        def mock_execute(**kwargs):
            nonlocal call_count
            call_count += 1
            sql = kwargs["statement"]
            if "business" in sql and "DISTINCT" in sql:
                return _make_sql_result(BUSINESS_COLS, rows)
            # Domain/product/attribute queries return empty
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = mock_execute

        with Session(engine) as session:
            svc = InitialSyncService(session, mock_ws, "wh-123")
            summary = svc.discover_and_sync("test_catalog")
            session.commit()

        assert summary["businesses_discovered"] == 1
        assert summary["businesses_created"] == 1
        assert summary["errors"] == []

        with Session(engine) as session:
            businesses = session.exec(select(Business)).all()
            assert len(businesses) == 1
            assert businesses[0].name == "retail_corp"

    def test_auto_creates_industry(self, engine, mock_ws):
        """When no matching industry exists, creates a stub with is_auto_created=True."""
        rows = [
            ["fintech_startup", "v1", "MVM", "done", "100.0", "2024-01-01"],
        ]

        def mock_execute(**kwargs):
            sql = kwargs["statement"]
            if "DISTINCT" in sql:
                return _make_sql_result(BUSINESS_COLS, rows)
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = mock_execute

        with Session(engine) as session:
            svc = InitialSyncService(session, mock_ws, "wh-123")
            summary = svc.discover_and_sync("cat")
            session.commit()

        assert summary["industries_auto_created"] == 1

        with Session(engine) as session:
            industry = session.exec(
                select(Industry).where(Industry.short_name == "fintech_startup")
            ).first()
            assert industry is not None
            assert industry.is_auto_created is True
            assert industry.name == "Fintech Startup"

    def test_matches_existing_industry(self, engine, mock_ws):
        """When a matching industry exists by short_name, links to it without auto-creating."""
        rows = [
            ["banking", "v1", "MVM", "done", "100.0", "2024-01-01"],
        ]

        # Seed an industry
        with Session(engine) as session:
            session.add(Industry(name="Banking", short_name="banking"))
            session.commit()

        def mock_execute(**kwargs):
            sql = kwargs["statement"]
            if "DISTINCT" in sql:
                return _make_sql_result(BUSINESS_COLS, rows)
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = mock_execute

        with Session(engine) as session:
            svc = InitialSyncService(session, mock_ws, "wh-123")
            summary = svc.discover_and_sync("cat")
            session.commit()

        assert summary["industries_auto_created"] == 0
        assert summary["businesses_created"] == 1

        with Session(engine) as session:
            biz = session.exec(select(Business)).first()
            assert biz.industry_alignment == "Banking"
            ind = session.exec(select(Industry)).first()
            assert biz.industry_id == ind.id

    def test_skips_existing_business(self, engine, mock_ws):
        """Business that already exists in Lakebase is not duplicated."""
        with Session(engine) as session:
            session.add(Business(name="existing_biz"))
            session.commit()

        rows = [
            ["existing_biz", "v1", "MVM", "done", "100.0", "2024-01-01"],
        ]

        def mock_execute(**kwargs):
            sql = kwargs["statement"]
            if "DISTINCT" in sql:
                return _make_sql_result(BUSINESS_COLS, rows)
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = mock_execute

        with Session(engine) as session:
            svc = InitialSyncService(session, mock_ws, "wh-123")
            summary = svc.discover_and_sync("cat")
            session.commit()

        assert summary["businesses_existing"] == 1
        assert summary["businesses_created"] == 0

    def test_skips_incomplete_versions(self, engine, mock_ws):
        """Versions with completed_percent < 100 or no completion_date are skipped."""
        rows = [
            ["test_biz", "v1", "MVM", "running", "50.0", None],
            ["test_biz", "v2", "MVM", "done", "100.0", "2024-06-01"],
        ]

        def mock_execute(**kwargs):
            sql = kwargs["statement"]
            if "DISTINCT" in sql:
                return _make_sql_result(BUSINESS_COLS, rows)
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = mock_execute

        with Session(engine) as session:
            svc = InitialSyncService(session, mock_ws, "wh-123")
            summary = svc.discover_and_sync("cat")
            session.commit()

        # Only v2 should be synced
        assert summary["versions_synced"] == 0  # 0 because no model data from empty results

        with Session(engine) as session:
            versions = session.exec(select(ModelVersion)).all()
            assert len(versions) == 1
            assert versions[0].version == 2

    def test_completed_version_no_model_data_marks_sync_empty(self, engine, mock_ws):
        """G1 third site: a completed version whose sync_model returns False
        (no Volume, no Delta) must land sync_state=sync_empty rather than the
        default 'ok', and must not increment versions_synced."""
        rows = [
            ["empty_biz", "v1", "MVM", "done", "100.0", "2024-01-01"],
        ]

        def mock_execute(**kwargs):
            sql = kwargs["statement"]
            if "DISTINCT" in sql:
                return _make_sql_result(BUSINESS_COLS, rows)
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = mock_execute

        with Session(engine) as session:
            svc = InitialSyncService(session, mock_ws, "wh-123")
            summary = svc.discover_and_sync("cat")
            session.commit()

        assert summary["versions_synced"] == 0

        with Session(engine) as session:
            mv = session.exec(select(ModelVersion)).first()
            assert mv is not None
            assert mv.status == "completed"
            assert mv.sync_state == "sync_empty"
            assert mv.sync_error_text

    def test_completed_version_zero_domain_artifact_marks_sync_empty(self, engine, mock_ws):
        """G2 third site: a completed version whose artifact parses to 0 domains
        makes the post-sync gate raise _SyncEmptyError from inside sync_model.
        _sync_versions must catch it and land the version sync_empty — NOT let
        it escape to discover_and_sync's generic except (which only logs the
        error, leaving the flushed mv at completed/ok/0-domains once committed)."""
        rows = [
            ["empty_g2_biz", "v1", "MVM", "done", "100.0", "2024-01-01"],
        ]

        def mock_execute(**kwargs):
            sql = kwargs["statement"]
            if "DISTINCT" in sql:
                return _make_sql_result(BUSINESS_COLS, rows)
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = mock_execute

        with patch.object(ModelSyncService, "load_model_json_from_volumes",
                          return_value={"domains": []}):
            with Session(engine) as session:
                svc = InitialSyncService(session, mock_ws, "wh-123")
                summary = svc.discover_and_sync("cat")
                session.commit()

        assert summary["versions_synced"] == 0
        # The raise was handled in-loop, so it is NOT logged as a business error.
        assert summary["errors"] == []

        with Session(engine) as session:
            mv = session.exec(select(ModelVersion)).first()
            assert mv is not None
            assert mv.status == "completed"
            assert mv.sync_state == "sync_empty"
            assert mv.sync_error_text

    def test_table_not_found_returns_error(self, engine, mock_ws):
        """If business table doesn't exist, returns error in summary."""
        mock_ws.statement_execution.execute_statement.side_effect = RuntimeError(
            "TABLE_OR_VIEW_NOT_FOUND"
        )

        with Session(engine) as session:
            svc = InitialSyncService(session, mock_ws, "wh-123")
            summary = svc.discover_and_sync("nonexistent_catalog")

        assert len(summary["errors"]) == 1
        assert "not found" in summary["errors"][0]
        assert summary["businesses_discovered"] == 0

    def test_multiple_businesses_discovered(self, engine, mock_ws):
        """Discovers multiple businesses in one scan."""
        rows = [
            ["biz_a", "v1", "MVM", "done", "100.0", "2024-01-01"],
            ["biz_b", "v1", "ECM", "done", "100.0", "2024-02-01"],
            ["biz_b", "v2", "ECM", "done", "100.0", "2024-03-01"],
        ]

        def mock_execute(**kwargs):
            sql = kwargs["statement"]
            if "DISTINCT" in sql:
                return _make_sql_result(BUSINESS_COLS, rows)
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = mock_execute

        with Session(engine) as session:
            svc = InitialSyncService(session, mock_ws, "wh-123")
            summary = svc.discover_and_sync("cat")
            session.commit()

        assert summary["businesses_discovered"] == 2
        assert summary["businesses_created"] == 2

        with Session(engine) as session:
            businesses = session.exec(select(Business)).all()
            assert len(businesses) == 2
            # biz_b should have 2 versions
            biz_b = session.exec(
                select(Business).where(Business.name == "biz_b")
            ).first()
            versions = session.exec(
                select(ModelVersion).where(ModelVersion.business_id == biz_b.id)
            ).all()
            assert len(versions) == 2
