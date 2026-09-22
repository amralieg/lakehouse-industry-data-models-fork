"""Tests for core/_sql.py — safe SQL construction."""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from unittest.mock import MagicMock

import pytest

from vibe_modeling.backend.core._sql import (
    execute,
    like_pattern,
    safe_identifier,
)


class TestSafeIdentifier:
    def test_accepts_plain_identifier(self):
        assert safe_identifier("my_catalog") == "`my_catalog`"

    def test_accepts_underscore_prefix(self):
        assert safe_identifier("_metamodel") == "`_metamodel`"

    def test_accepts_alphanumeric(self):
        assert safe_identifier("col1") == "`col1`"

    def test_rejects_dotted(self):
        with pytest.raises(ValueError, match="unsafe SQL identifier"):
            safe_identifier("catalog.schema")

    def test_rejects_semicolon(self):
        with pytest.raises(ValueError):
            safe_identifier("x;DROP TABLE y")

    def test_rejects_empty(self):
        with pytest.raises(ValueError):
            safe_identifier("")

    def test_rejects_none(self):
        with pytest.raises(ValueError):
            safe_identifier(None)  # type: ignore[arg-type]

    def test_rejects_leading_digit(self):
        with pytest.raises(ValueError):
            safe_identifier("1abc")

    def test_rejects_backtick(self):
        with pytest.raises(ValueError):
            safe_identifier("a`b")

    def test_rejects_space(self):
        with pytest.raises(ValueError):
            safe_identifier("my table")


class TestLikePattern:
    def test_escapes_percent(self):
        assert like_pattern("100% off") == r"100\% off"

    def test_escapes_underscore(self):
        assert like_pattern("a_b") == r"a\_b"

    def test_escapes_backslash(self):
        # Python literal "a\\b" is the 3-char string a, \, b.
        # Helper doubles the backslash, then leaves the b alone.
        assert like_pattern("a\\b") == "a\\\\b"

    def test_escapes_all_three(self):
        # "%_\\" -> escape backslash first, then % and _.
        assert like_pattern("%_\\") == "\\%\\_\\\\"

    def test_passes_through_plain_text(self):
        assert like_pattern("acme retail") == "acme retail"

    def test_empty_string(self):
        assert like_pattern("") == ""


class TestExecute:
    def _ws(self):
        ws = MagicMock()
        ws.statement_execution.execute_statement.return_value = MagicMock(
            name="StatementResponse"
        )
        return ws

    def test_passes_sql_and_warehouse(self):
        ws = self._ws()
        execute(ws, "wh-123", "SELECT 1")
        ws.statement_execution.execute_statement.assert_called_once()
        kwargs = ws.statement_execution.execute_statement.call_args.kwargs
        assert kwargs["statement"] == "SELECT 1"
        assert kwargs["warehouse_id"] == "wh-123"
        assert kwargs["wait_timeout"] == "50s"
        assert kwargs["parameters"] is None

    def test_custom_wait_timeout(self):
        ws = self._ws()
        execute(ws, "wh-1", "SELECT 1", wait_timeout="10s")
        kwargs = ws.statement_execution.execute_statement.call_args.kwargs
        assert kwargs["wait_timeout"] == "10s"

    def test_named_parameters_become_sdk_items(self):
        from databricks.sdk.service.sql import StatementParameterListItem

        ws = self._ws()
        execute(
            ws,
            "wh-1",
            "SELECT * FROM t WHERE biz = :biz AND v = :v",
            params={"biz": "acme", "v": 3},
        )
        kwargs = ws.statement_execution.execute_statement.call_args.kwargs
        params = kwargs["parameters"]
        assert isinstance(params, list)
        assert len(params) == 2
        assert all(isinstance(p, StatementParameterListItem) for p in params)
        by_name = {p.name: p.value for p in params}
        assert by_name == {"biz": "acme", "v": "3"}  # int coerced to str

    def test_none_param_value_preserved(self):
        ws = self._ws()
        execute(ws, "wh-1", "SELECT :x", params={"x": None})
        kwargs = ws.statement_execution.execute_statement.call_args.kwargs
        assert kwargs["parameters"][0].value is None

    def test_returns_sdk_response(self):
        ws = self._ws()
        sentinel = ws.statement_execution.execute_statement.return_value
        result = execute(ws, "wh-1", "SELECT 1")
        assert result is sentinel

    def test_empty_params_mapping_yields_none(self):
        ws = self._ws()
        execute(ws, "wh-1", "SELECT 1", params={})
        kwargs = ws.statement_execution.execute_statement.call_args.kwargs
        # Empty mapping is falsy → no parameter list at all.
        assert kwargs["parameters"] is None
