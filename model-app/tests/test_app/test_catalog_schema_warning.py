"""Tests for GET /api/uc/catalogs/{catalog_name}/schema-warning.

Verifies:
- Protected schemas (_metamodel, default, information_schema) are excluded.
- Count and names reflect only non-protected schemas.
- Missing catalog (NotFound) returns schema_count=0, schemas=[] — not 500.
- PermissionDenied returns schema_count=0, schemas=[] — not 500.
- An empty catalog (no schemas at all) returns schema_count=0, schemas=[].
"""

from __future__ import annotations

from types import SimpleNamespace

import pytest
from databricks.sdk.errors.platform import NotFound, PermissionDenied


def _schema(name: str):
    return SimpleNamespace(name=name)


@pytest.fixture
def mock_ws_schemas(mock_ws):
    mock_ws.schemas.list.return_value = []
    return mock_ws


def test_non_protected_schemas_counted(client, mock_ws_schemas):
    """Non-protected schemas are returned; protected ones are excluded."""
    mock_ws_schemas.schemas.list.return_value = [
        _schema("retail"),
        _schema("finance"),
        _schema("_metamodel"),
        _schema("default"),
        _schema("information_schema"),
    ]

    r = client.get("/api/uc/catalogs/my_catalog/schema-warning")
    assert r.status_code == 200, r.text
    body = r.json()

    assert body["catalog"] == "my_catalog"
    assert body["schema_count"] == 2
    assert sorted(body["schemas"]) == ["finance", "retail"]
    mock_ws_schemas.schemas.list.assert_called_once_with(catalog_name="my_catalog")


def test_only_protected_schemas_returns_zero(client, mock_ws_schemas):
    """A catalog with only protected schemas returns count=0."""
    mock_ws_schemas.schemas.list.return_value = [
        _schema("_metamodel"),
        _schema("default"),
        _schema("information_schema"),
    ]

    r = client.get("/api/uc/catalogs/clean_catalog/schema-warning")
    assert r.status_code == 200
    body = r.json()

    assert body["schema_count"] == 0
    assert body["schemas"] == []


def test_empty_catalog_returns_zero(client, mock_ws_schemas):
    """A catalog with no schemas at all returns count=0."""
    mock_ws_schemas.schemas.list.return_value = []

    r = client.get("/api/uc/catalogs/empty_catalog/schema-warning")
    assert r.status_code == 200
    body = r.json()

    assert body["catalog"] == "empty_catalog"
    assert body["schema_count"] == 0
    assert body["schemas"] == []


def test_not_found_returns_zero_not_500(client, mock_ws_schemas):
    """NotFound from the SDK is swallowed — returns 200 with schema_count=0."""
    mock_ws_schemas.schemas.list.side_effect = NotFound("catalog not found")

    r = client.get("/api/uc/catalogs/missing_catalog/schema-warning")
    assert r.status_code == 200, r.text
    body = r.json()

    assert body["catalog"] == "missing_catalog"
    assert body["schema_count"] == 0
    assert body["schemas"] == []


def test_permission_denied_returns_zero_not_500(client, mock_ws_schemas):
    """PermissionDenied from the SDK is swallowed — returns 200 with schema_count=0."""
    mock_ws_schemas.schemas.list.side_effect = PermissionDenied("access denied")

    r = client.get("/api/uc/catalogs/locked_catalog/schema-warning")
    assert r.status_code == 200, r.text
    body = r.json()

    assert body["catalog"] == "locked_catalog"
    assert body["schema_count"] == 0
    assert body["schemas"] == []


def test_schemas_sorted_alphabetically(client, mock_ws_schemas):
    """Returned schema names are sorted for stable display."""
    mock_ws_schemas.schemas.list.return_value = [
        _schema("zebra_domain"),
        _schema("apple_domain"),
        _schema("mango_domain"),
    ]

    r = client.get("/api/uc/catalogs/my_catalog/schema-warning")
    assert r.status_code == 200
    body = r.json()

    assert body["schemas"] == ["apple_domain", "mango_domain", "zebra_domain"]
    assert body["schema_count"] == 3


def test_schema_with_none_name_skipped(client, mock_ws_schemas):
    """SDK rows with name=None are skipped (defensive guard)."""
    mock_ws_schemas.schemas.list.return_value = [
        _schema("retail"),
        SimpleNamespace(name=None),
    ]

    r = client.get("/api/uc/catalogs/my_catalog/schema-warning")
    assert r.status_code == 200
    body = r.json()

    assert body["schema_count"] == 1
    assert body["schemas"] == ["retail"]
