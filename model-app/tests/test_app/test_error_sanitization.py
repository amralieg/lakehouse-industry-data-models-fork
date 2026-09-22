"""Tests for error_sanitization.py — sensitive data stripping from error messages."""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from vibe_modeling.backend.error_sanitization import sanitize_error_message, MAX_ERROR_LENGTH


class TestSanitizeWorkspacePaths:
    def test_strips_workspace_path(self):
        msg = "File not found: /Workspace/Users/admin@company.com/notebook.py"
        result = sanitize_error_message(msg)
        assert "/Workspace/" not in result
        assert "@" not in result

    def test_strips_volumes_path(self):
        msg = "Cannot read /Volumes/catalog/_metamodel/vol_root/model.json"
        result = sanitize_error_message(msg)
        assert "/Volumes/" not in result

    def test_strips_dbfs_path(self):
        msg = "Error accessing dbfs:/mnt/data/secret_file.csv"
        result = sanitize_error_message(msg)
        assert "dbfs:/" not in result


class TestSanitizeCredentials:
    def test_strips_email(self):
        msg = "Permission denied for user admin@databricks.com on resource"
        result = sanitize_error_message(msg)
        assert "admin@databricks.com" not in result
        assert "[REDACTED]" in result

    def test_strips_dapi_token(self):
        # Build fake token dynamically to avoid tripping secret scanners
        fake_token = "dapi" + "1234567890abcdef" * 2 + "12"
        msg = f"Invalid token: {fake_token}"
        result = sanitize_error_message(msg)
        assert fake_token not in result

    def test_strips_bearer_token(self):
        msg = "Auth failed with Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.payload"
        result = sanitize_error_message(msg)
        assert "eyJhbGciOi" not in result

    def test_strips_long_hex_token(self):
        msg = f"Token {'a' * 48} is expired"
        result = sanitize_error_message(msg)
        assert "a" * 48 not in result


class TestMessageCap:
    def test_caps_at_max_length(self):
        msg = "x" * 1000
        result = sanitize_error_message(msg)
        assert len(result) == MAX_ERROR_LENGTH + 3  # +3 for "..."
        assert result.endswith("...")

    def test_short_message_unchanged(self):
        msg = "Simple error"
        result = sanitize_error_message(msg)
        assert result == "Simple error"


class TestPreservesNonSensitive:
    def test_preserves_sql_error(self):
        msg = "SQL error: TABLE_OR_VIEW_NOT_FOUND: Table `catalog`._metamodel._business"
        result = sanitize_error_message(msg)
        assert "TABLE_OR_VIEW_NOT_FOUND" in result

    def test_preserves_normal_path_text(self):
        msg = "Column 'name' is required but was not provided"
        result = sanitize_error_message(msg)
        assert result == msg


class TestMultiplePatterns:
    def test_strips_multiple_sensitive_items(self):
        fake_token = "dapi" + "0123456789abcdef" * 2 + "01"
        msg = (
            f"Error for user admin@corp.com accessing /Workspace/Users/admin/nb.py "
            f"with token {fake_token}"
        )
        result = sanitize_error_message(msg)
        assert "admin@corp.com" not in result
        assert "/Workspace/" not in result
        assert fake_token not in result
        assert result.count("[REDACTED]") >= 3
