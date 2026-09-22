"""Tests for the Volume browse endpoint (``GET /api/uc/volumes/browse``).

Mocks the Databricks SDK at the route boundary (``Dependencies.Client``).
The mock_ws fixture's MagicMock returns sub-mocks for ``ws.catalogs.list``,
``ws.schemas.list``, ``ws.volumes.list``, and
``ws.files.list_directory_contents``. We program their return values per
test to cover the four levels of the path grammar.
"""

from __future__ import annotations

from datetime import datetime, timezone
from types import SimpleNamespace

import pytest
from databricks.sdk.errors.platform import PermissionDenied


@pytest.fixture
def mock_ws_volumes(mock_ws):
    """Default empty UC. Tests override per-attribute."""
    mock_ws.catalogs.list.return_value = []
    mock_ws.schemas.list.return_value = []
    mock_ws.volumes.list.return_value = []
    mock_ws.files.list_directory_contents.return_value = []
    return mock_ws


def _catalog(name):
    return SimpleNamespace(name=name, comment=None, owner=None)


def _schema(name):
    return SimpleNamespace(name=name, comment=None, owner=None)


def _volume(name):
    return SimpleNamespace(name=name, volume_type="MANAGED")


def _file_entry(name, *, is_directory=False, file_size=None, last_modified=None):
    return SimpleNamespace(
        name=name,
        is_directory=is_directory,
        file_size=file_size,
        last_modified=last_modified,
    )


def test_root_lists_catalogs(client, mock_ws_volumes):
    mock_ws_volumes.catalogs.list.return_value = [_catalog("main"), _catalog("dev")]

    r = client.get("/api/uc/volumes/browse?path=")
    assert r.status_code == 200, r.text
    body = r.json()

    assert body["path"] == ""
    assert body["parent"] is None
    assert body["truncated"] is False
    names = [e["name"] for e in body["entries"]]
    assert names == ["dev", "main"]  # alphabetical
    assert all(e["kind"] == "catalog" and e["is_dir"] for e in body["entries"])


def test_root_slash_also_lists_catalogs(client, mock_ws_volumes):
    mock_ws_volumes.catalogs.list.return_value = [_catalog("main")]
    r = client.get("/api/uc/volumes/browse?path=/")
    assert r.status_code == 200
    body = r.json()
    assert body["path"] == ""
    assert [e["name"] for e in body["entries"]] == ["main"]


def test_catalog_lists_schemas(client, mock_ws_volumes):
    mock_ws_volumes.schemas.list.return_value = [_schema("retail"), _schema("default")]

    r = client.get("/api/uc/volumes/browse?path=/main")
    assert r.status_code == 200, r.text
    body = r.json()

    assert body["path"] == "/main"
    assert body["parent"] == ""
    names = [e["name"] for e in body["entries"]]
    assert names == ["default", "retail"]
    assert all(e["kind"] == "schema" and e["is_dir"] for e in body["entries"])
    mock_ws_volumes.schemas.list.assert_called_once_with(catalog_name="main")


def test_schema_lists_volumes(client, mock_ws_volumes):
    mock_ws_volumes.volumes.list.return_value = [_volume("vibes"), _volume("artifacts")]

    r = client.get("/api/uc/volumes/browse?path=/main/retail")
    assert r.status_code == 200, r.text
    body = r.json()

    assert body["path"] == "/main/retail"
    assert body["parent"] == "/main"
    names = [e["name"] for e in body["entries"]]
    assert names == ["artifacts", "vibes"]
    assert all(e["kind"] == "volume" and e["is_dir"] for e in body["entries"])
    mock_ws_volumes.volumes.list.assert_called_once_with(
        catalog_name="main", schema_name="retail"
    )


def test_directory_lists_files_and_dirs(client, mock_ws_volumes):
    mod_dt = datetime(2026, 5, 1, 12, 0, tzinfo=timezone.utc)
    mock_ws_volumes.files.list_directory_contents.return_value = [
        _file_entry("subdir", is_directory=True),
        _file_entry("model.json", file_size=4096, last_modified=mod_dt),
        _file_entry("README.md", file_size=120, last_modified=mod_dt),
    ]

    r = client.get(
        "/api/uc/volumes/browse?path=/Volumes/main/retail/vibes"
    )
    assert r.status_code == 200, r.text
    body = r.json()

    assert body["path"] == "/Volumes/main/retail/vibes"
    assert body["parent"] == "/main/retail"

    entries = body["entries"]
    # dirs first, then files alphabetical
    assert [e["name"] for e in entries] == ["subdir", "model.json", "README.md"]

    subdir = next(e for e in entries if e["name"] == "subdir")
    assert subdir["kind"] == "dir"
    assert subdir["is_dir"] is True
    assert subdir["size_bytes"] is None

    mj = next(e for e in entries if e["name"] == "model.json")
    assert mj["kind"] == "file"
    assert mj["is_dir"] is False
    assert mj["size_bytes"] == 4096
    assert mj["modified_at"].startswith("2026-05-01T12:00:00")

    mock_ws_volumes.files.list_directory_contents.assert_called_once_with(
        "/Volumes/main/retail/vibes"
    )


def test_directory_handles_epoch_millis_modified(client, mock_ws_volumes):
    mock_ws_volumes.files.list_directory_contents.return_value = [
        _file_entry("x.json", file_size=10, last_modified=1746100800000),
    ]
    r = client.get(
        "/api/uc/volumes/browse?path=/Volumes/main/retail/vibes/sub"
    )
    assert r.status_code == 200
    entries = r.json()["entries"]
    assert entries[0]["modified_at"] is not None


def test_json_file_appears_with_kind_file(client, mock_ws_volumes):
    """The picker filters by kind=file + name.endswith('.json') on the client.
    Verify the endpoint emits both signals so client-side filtering works."""
    mock_ws_volumes.files.list_directory_contents.return_value = [
        _file_entry("model.json", file_size=2048),
        _file_entry("notes.txt", file_size=500),
        _file_entry("nested", is_directory=True),
    ]
    r = client.get("/api/uc/volumes/browse?path=/Volumes/c/s/v")
    assert r.status_code == 200
    json_files = [
        e for e in r.json()["entries"]
        if e["kind"] == "file" and e["name"].endswith(".json")
    ]
    assert len(json_files) == 1
    assert json_files[0]["name"] == "model.json"


def test_permission_denied_returns_403_with_no_leakage(client, mock_ws_volumes):
    mock_ws_volumes.volumes.list.side_effect = PermissionDenied("secret detail")

    r = client.get("/api/uc/volumes/browse?path=/main/locked")
    assert r.status_code == 403
    detail = r.json().get("detail", "")
    assert "secret detail" not in detail
    assert detail == "Access denied"


def test_too_many_entries_marks_truncated(client, mock_ws_volumes):
    """501 catalogs → response capped at 500 with truncated=True."""
    mock_ws_volumes.catalogs.list.return_value = [
        _catalog(f"cat_{i:04d}") for i in range(501)
    ]
    r = client.get("/api/uc/volumes/browse?path=")
    assert r.status_code == 200
    body = r.json()
    assert body["truncated"] is True
    assert len(body["entries"]) == 500


def test_invalid_volumes_path_too_short_returns_400(client, mock_ws_volumes):
    r = client.get("/api/uc/volumes/browse?path=/Volumes/main")
    assert r.status_code == 400


def test_invalid_three_segment_non_volumes_path_returns_400(client, mock_ws_volumes):
    """Three non-Volumes segments aren't allowed — the UI must use /Volumes/."""
    r = client.get("/api/uc/volumes/browse?path=/main/retail/vibes")
    assert r.status_code == 400


def test_parent_inside_volume_subdir(client, mock_ws_volumes):
    mock_ws_volumes.files.list_directory_contents.return_value = []
    r = client.get(
        "/api/uc/volumes/browse?path=/Volumes/main/retail/vibes/a/b"
    )
    assert r.status_code == 200
    assert r.json()["parent"] == "/Volumes/main/retail/vibes/a"


def test_trailing_slash_normalized(client, mock_ws_volumes):
    mock_ws_volumes.schemas.list.return_value = [_schema("retail")]
    r = client.get("/api/uc/volumes/browse?path=/main/")
    assert r.status_code == 200
    body = r.json()
    assert body["path"] == "/main"
    assert [e["name"] for e in body["entries"]] == ["retail"]
