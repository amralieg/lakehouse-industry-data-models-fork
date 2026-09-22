"""Snapshot tests for the database engine URL builder.

The integration fixtures use SQLite in-memory and override the lakebase
dependency, so the production URL string `_build_engine_url` produces is
never exercised in normal tests. Bug 1 in Phase 4.5 (PR #150) was a
literal `localhost` in the URL falling to IPv6 `::1` on macOS dual-stack
systems and refusing the connection. Two months of unit-test coverage
never caught it.

This test runs the builder as a pure function with controlled inputs
and asserts that the dev-mode URL uses an IPv4 literal — no `localhost`,
no hostname that could resolve to `::1`. Production-mode URLs are
generated from a workspace SDK call so they're tested via mocks.

Pattern: any future change to the dev URL composition that introduces
a hostname-based component will fail this test on the next run.
"""
from __future__ import annotations

import os
from unittest.mock import MagicMock

import pytest

from vibe_modeling.backend.core.lakebase import (
    DatabaseConfig,
    _build_engine_url,
    _sqlite_fallback_url,
)


def test_dev_url_uses_ipv4_literal(monkeypatch):
    """Dev mode (APX_DEV_DB_PORT + APX_DEV_DB_PWD set) must use 127.0.0.1
    literal. The macOS dual-stack `localhost` → `::1` failure mode means
    any hostname-based form is unsafe."""
    monkeypatch.setenv("APX_DEV_DB_PWD", "test-pwd")
    db_config = DatabaseConfig()
    ws = MagicMock()
    url = _build_engine_url(db_config, ws, dev_port=4242)

    assert "@127.0.0.1:" in url, (
        f"Dev URL must use 127.0.0.1 literal, got: {url}"
    )
    assert "@localhost" not in url, (
        f"Dev URL must NOT use 'localhost' (IPv6 dual-stack risk), got: {url}"
    )
    assert "@::1" not in url, (
        f"Dev URL must NOT use '::1' (pglite is IPv4-only), got: {url}"
    )
    assert ":4242/" in url, (
        f"Dev URL should include the port, got: {url}"
    )


def test_dev_url_falls_back_to_sqlite_when_password_missing(monkeypatch):
    """If APX_DEV_DB_PORT is set but APX_DEV_DB_PWD is missing, the
    builder falls back to SQLite. This is the local-dev-without-pglite
    path; the SQLite URL must be a real file path the engine can open."""
    monkeypatch.delenv("APX_DEV_DB_PWD", raising=False)
    db_config = DatabaseConfig()
    ws = MagicMock()
    url = _build_engine_url(db_config, ws, dev_port=4242)

    assert url.startswith("sqlite:///"), (
        f"Without APX_DEV_DB_PWD, must fall back to SQLite, got: {url}"
    )


def test_sqlite_fallback_url_creates_real_file_path():
    """The SQLite fallback must produce a real path (not in-memory) so
    the data survives within the dev-server lifetime."""
    url = _sqlite_fallback_url()
    assert url.startswith("sqlite:///"), url
    # The path component should be absolute.
    path = url[len("sqlite:///"):]
    assert path.startswith("/"), (
        f"SQLite fallback path should be absolute, got: {path}"
    )


@pytest.mark.parametrize("hostname_form", ["localhost", "::1", "host.docker.internal"])
def test_dev_url_does_not_contain_problematic_hostnames(monkeypatch, hostname_form):
    """Pattern guard: explicitly fail if the dev URL ever introduces a
    hostname that could fail the dual-stack scenario or assume Docker
    networking. Catches any drift in the URL composition."""
    monkeypatch.setenv("APX_DEV_DB_PWD", "x")
    db_config = DatabaseConfig()
    url = _build_engine_url(db_config, MagicMock(), dev_port=5432)
    # The URL we generate includes the password (which won't equal these
    # hostnames in practice). We're checking the "@<host>:" segment.
    host_segment = url.split("@", 1)[1].split(":", 1)[0] if "@" in url else url
    assert host_segment != hostname_form, (
        f"Dev URL host must not be '{hostname_form}', got URL: {url}"
    )
