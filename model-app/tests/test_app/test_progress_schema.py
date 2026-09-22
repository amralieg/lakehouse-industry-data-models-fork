"""Tests for progress_schema — legacy STRING vs VARIANT _vibe_progress compat (#115)."""

import os
import sys
from unittest.mock import MagicMock

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest

from vibe_modeling.backend import progress_schema
from vibe_modeling.backend.progress_schema import (
    detect_result_json_type,
    ensure_progress_schema,
)


def _mk_exec_result(rows: list[list] | None, *, error_message: str | None = None):
    """Build a fake `execute_statement` result object."""
    result = MagicMock()
    if error_message is not None:
        result.status = MagicMock()
        result.status.error = MagicMock()
        result.status.error.message = error_message
        result.result = None
        return result
    result.status = MagicMock()
    result.status.error = None
    if rows is None:
        result.result = None
    else:
        result.result = MagicMock()
        result.result.data_array = rows
    return result


@pytest.fixture(autouse=True)
def _clear_cache():
    """Reset per-catalog cache between tests so each test starts clean."""
    progress_schema._reset_cache_for_testing()
    yield
    progress_schema._reset_cache_for_testing()


class TestDetectResultJsonType:
    def test_returns_variant_when_variant(self):
        ws = MagicMock()
        ws.statement_execution.execute_statement.return_value = _mk_exec_result(
            [["VARIANT"]]
        )
        assert detect_result_json_type(ws, "wh-1", "my_cat") == "VARIANT"

    def test_returns_string_when_string(self):
        ws = MagicMock()
        ws.statement_execution.execute_statement.return_value = _mk_exec_result(
            [["STRING"]]
        )
        assert detect_result_json_type(ws, "wh-1", "my_cat") == "STRING"

    def test_returns_missing_when_no_rows(self):
        ws = MagicMock()
        ws.statement_execution.execute_statement.return_value = _mk_exec_result([])
        assert detect_result_json_type(ws, "wh-1", "my_cat") == "MISSING"

    def test_returns_missing_on_sql_error(self):
        ws = MagicMock()
        ws.statement_execution.execute_statement.return_value = _mk_exec_result(
            None, error_message="boom"
        )
        assert detect_result_json_type(ws, "wh-1", "my_cat") == "MISSING"

    def test_queries_information_schema(self):
        """The detector must target information_schema.columns."""
        ws = MagicMock()
        ws.statement_execution.execute_statement.return_value = _mk_exec_result(
            [["VARIANT"]]
        )
        detect_result_json_type(ws, "wh-1", "my_cat")
        call = ws.statement_execution.execute_statement.call_args
        sql = call.kwargs.get("statement", "")
        assert "information_schema" in sql
        assert "_metamodel" in sql
        assert "_vibe_progress" in sql
        assert "result_json" in sql
        assert call.kwargs.get("warehouse_id") == "wh-1"


class TestEnsureProgressSchemaVariant:
    def test_variant_no_drop(self):
        """VARIANT schema: detector runs but DROP must not be issued."""
        ws = MagicMock()
        ws.statement_execution.execute_statement.return_value = _mk_exec_result(
            [["VARIANT"]]
        )
        ensure_progress_schema(ws, "wh-1", "my_cat")
        # Only the detect query ran, no DROP.
        calls = ws.statement_execution.execute_statement.call_args_list
        assert len(calls) == 1
        assert "DROP" not in calls[0].kwargs.get("statement", "")


class TestEnsureProgressSchemaMissing:
    def test_missing_no_drop(self):
        """No table yet — agent will create it correctly."""
        ws = MagicMock()
        ws.statement_execution.execute_statement.return_value = _mk_exec_result([])
        ensure_progress_schema(ws, "wh-1", "my_cat")
        calls = ws.statement_execution.execute_statement.call_args_list
        assert len(calls) == 1
        assert "DROP" not in calls[0].kwargs.get("statement", "")


class TestEnsureProgressSchemaStringDrop:
    def test_string_triggers_drop(self):
        """Legacy STRING schema: DROP TABLE IF EXISTS must fire."""
        ws = MagicMock()
        ws.statement_execution.execute_statement.side_effect = [
            _mk_exec_result([["STRING"]]),  # detect
            _mk_exec_result([]),              # drop result
        ]
        ensure_progress_schema(ws, "wh-1", "my_cat")
        calls = ws.statement_execution.execute_statement.call_args_list
        assert len(calls) == 2
        drop_sql = calls[1].kwargs.get("statement", "")
        assert "DROP TABLE IF EXISTS" in drop_sql
        assert "_metamodel" in drop_sql
        assert "_vibe_progress" in drop_sql
        assert "my_cat" in drop_sql

    def test_string_drop_failure_swallowed(self):
        """If DROP raises, no exception propagates — best-effort."""
        ws = MagicMock()
        # Detect returns STRING; DROP raises.
        ws.statement_execution.execute_statement.side_effect = [
            _mk_exec_result([["STRING"]]),
            RuntimeError("permission denied"),
        ]
        # Must not raise.
        ensure_progress_schema(ws, "wh-1", "my_cat")


class TestEnsureProgressSchemaStrategies:
    def test_off_skips_detect(self):
        ws = MagicMock()
        ensure_progress_schema(ws, "wh-1", "my_cat", strategy="off")
        ws.statement_execution.execute_statement.assert_not_called()

    def test_alter_warns_but_no_action(self, caplog):
        """strategy='alter' is reserved: no DROP, just a warning."""
        ws = MagicMock()
        ws.statement_execution.execute_statement.return_value = _mk_exec_result(
            [["STRING"]]
        )
        ensure_progress_schema(ws, "wh-1", "my_cat", strategy="alter")
        calls = ws.statement_execution.execute_statement.call_args_list
        # Only the detect — no DROP.
        assert len(calls) == 1
        assert "DROP" not in calls[0].kwargs.get("statement", "")


class TestEnsureProgressSchemaCache:
    def test_variant_caches_by_catalog(self):
        """Second call for same catalog short-circuits the SQL probe."""
        ws = MagicMock()
        ws.statement_execution.execute_statement.return_value = _mk_exec_result(
            [["VARIANT"]]
        )
        ensure_progress_schema(ws, "wh-1", "my_cat")
        ensure_progress_schema(ws, "wh-1", "my_cat")
        # Only one detect across two calls.
        assert ws.statement_execution.execute_statement.call_count == 1

    def test_string_drop_caches(self):
        """After a successful DROP, subsequent calls for same catalog are no-ops."""
        ws = MagicMock()
        ws.statement_execution.execute_statement.side_effect = [
            _mk_exec_result([["STRING"]]),
            _mk_exec_result([]),
        ]
        ensure_progress_schema(ws, "wh-1", "my_cat")
        ensure_progress_schema(ws, "wh-1", "my_cat")
        # Exactly two calls total: detect + drop. Second invocation is cached.
        assert ws.statement_execution.execute_statement.call_count == 2

    def test_different_catalogs_do_not_share_cache(self):
        ws = MagicMock()
        ws.statement_execution.execute_statement.return_value = _mk_exec_result(
            [["VARIANT"]]
        )
        ensure_progress_schema(ws, "wh-1", "cat_a")
        ensure_progress_schema(ws, "wh-1", "cat_b")
        assert ws.statement_execution.execute_statement.call_count == 2

    def test_failed_drop_does_not_cache(self):
        """A failed drop should allow retry on next launch."""
        ws = MagicMock()
        ws.statement_execution.execute_statement.side_effect = [
            _mk_exec_result([["STRING"]]),
            _mk_exec_result(None, error_message="denied"),
            # Second attempt: detect STRING again, drop succeeds.
            _mk_exec_result([["STRING"]]),
            _mk_exec_result([]),
        ]
        ensure_progress_schema(ws, "wh-1", "my_cat")
        ensure_progress_schema(ws, "wh-1", "my_cat")
        # Should have attempted both detect+drop twice since the first failed.
        assert ws.statement_execution.execute_statement.call_count == 4


class TestEnsureProgressSchemaGuards:
    def test_empty_catalog_is_noop(self):
        ws = MagicMock()
        ensure_progress_schema(ws, "wh-1", "")
        ws.statement_execution.execute_statement.assert_not_called()

    def test_empty_warehouse_is_noop(self):
        ws = MagicMock()
        ensure_progress_schema(ws, "", "my_cat")
        ws.statement_execution.execute_statement.assert_not_called()
