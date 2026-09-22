"""Tests for the C-08 trust-forwarded-headers gate (`_headers.py`).

The gate decides per-process whether to honour X-Forwarded-* identity headers.
It must reject spoofed headers when off (local dev / tests) and pass them
through when on (Databricks Apps reverse proxy in front).
"""

from __future__ import annotations

import os
import sys

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

import vibe_modeling.backend.core._headers as _headers_mod
from vibe_modeling.backend.core._headers import (
    DatabricksAppsHeaders,
    HeadersDependency,
    get_databricks_headers,
    should_trust_forwarded_headers,
)


# ---------------------------------------------------------------------------
# Gate resolution
# ---------------------------------------------------------------------------


@pytest.fixture
def clean_env(monkeypatch):
    """Strip every env var the gate cares about before each test."""
    for var in ("TRUST_FORWARDED_HEADERS", "DATABRICKS_APP_NAME", "LOCAL_DEV_USER"):
        monkeypatch.delenv(var, raising=False)
    return monkeypatch


class TestShouldTrustForwardedHeaders:
    def test_default_off_in_non_databricks_env(self, clean_env):
        assert should_trust_forwarded_headers() is False

    def test_default_on_when_databricks_app_name_set(self, clean_env):
        clean_env.setenv("DATABRICKS_APP_NAME", "vibe-modeling")
        assert should_trust_forwarded_headers() is True

    @pytest.mark.parametrize("val,expected", [
        # truthy: explicit on overrides default off
        ("1", True), ("true", True), ("  True  ", True),
        # falsy: explicit off overrides databricks runtime
        ("0", False), ("false", False), ("", False),
        # unknown falls back to off (fail closed)
        ("maybe", False),
    ])
    def test_explicit_value_resolution(self, clean_env, val, expected):
        # Set DATABRICKS_APP_NAME so we can verify explicit-off overrides
        # the runtime default. For explicit-truthy it has no effect.
        clean_env.setenv("DATABRICKS_APP_NAME", "vibe-modeling")
        clean_env.setenv("TRUST_FORWARDED_HEADERS", val)
        assert should_trust_forwarded_headers() is expected


# ---------------------------------------------------------------------------
# get_databricks_headers — behaviour under each gate state
# ---------------------------------------------------------------------------


def _build_app() -> FastAPI:
    """Tiny app that echoes the headers the dependency resolved to."""
    app = FastAPI()

    @app.get("/whoami")
    def whoami(headers: HeadersDependency):
        return {
            "host": headers.host,
            "user_name": headers.user_name,
            "user_id": headers.user_id,
            "user_email": headers.user_email,
            "request_id": str(headers.request_id) if headers.request_id else None,
            "has_token": headers.token is not None,
        }

    return app


SPOOFED = {
    "X-Forwarded-Host": "evil.example.com",
    "X-Forwarded-Preferred-Username": "Admin",
    "X-Forwarded-User": "admin-id",
    "X-Forwarded-Email": "admin@databricks.com",
    "X-Forwarded-Access-Token": "stolen-token",
    "X-Request-Id": "00000000-0000-0000-0000-000000000001",
}


class TestGateOff:
    """When TRUST_FORWARDED_HEADERS is off, every X-Forwarded-* must be ignored."""

    def test_spoofed_headers_are_dropped(self, clean_env):
        clean_env.setenv("TRUST_FORWARDED_HEADERS", "0")
        client = TestClient(_build_app())
        body = client.get("/whoami", headers=SPOOFED).json()

        assert body["user_email"] is None
        assert body["user_name"] is None
        assert body["user_id"] is None
        assert body["host"] is None
        assert body["request_id"] is None
        assert body["has_token"] is False

    def test_no_headers_unauthenticated(self, clean_env):
        clean_env.setenv("TRUST_FORWARDED_HEADERS", "0")
        client = TestClient(_build_app())
        body = client.get("/whoami").json()
        assert body["user_email"] is None
        assert body["user_name"] is None

    def test_local_dev_user_substituted(self, clean_env):
        """When LOCAL_DEV_USER is set, the gate substitutes it as identity."""
        clean_env.setenv("TRUST_FORWARDED_HEADERS", "0")
        clean_env.setenv("LOCAL_DEV_USER", "dev@example.com")
        client = TestClient(_build_app())
        body = client.get("/whoami", headers=SPOOFED).json()
        # Spoof headers still ignored, but dev user fills in.
        assert body["user_email"] == "dev@example.com"
        assert body["user_name"] == "dev@example.com"
        # Token / host / request_id stay empty regardless.
        assert body["has_token"] is False
        assert body["host"] is None

    def test_default_off_outside_databricks(self, clean_env):
        """No env vars at all → gate defaults off → headers dropped."""
        client = TestClient(_build_app())
        body = client.get("/whoami", headers=SPOOFED).json()
        assert body["user_email"] is None


class TestGateOn:
    """When the gate is on, behaviour is unchanged from before C-08."""

    def test_headers_passed_through(self, clean_env):
        clean_env.setenv("TRUST_FORWARDED_HEADERS", "1")
        client = TestClient(_build_app())
        body = client.get("/whoami", headers=SPOOFED).json()

        assert body["user_email"] == "admin@databricks.com"
        assert body["user_name"] == "Admin"
        assert body["user_id"] == "admin-id"
        assert body["host"] == "evil.example.com"
        assert body["request_id"] == "00000000-0000-0000-0000-000000000001"
        assert body["has_token"] is True

    def test_databricks_runtime_auto_enables(self, clean_env):
        """DATABRICKS_APP_NAME set + TRUST_FORWARDED_HEADERS unset → on."""
        clean_env.setenv("DATABRICKS_APP_NAME", "vibe-modeling")
        client = TestClient(_build_app())
        body = client.get("/whoami", headers=SPOOFED).json()
        assert body["user_email"] == "admin@databricks.com"


# ---------------------------------------------------------------------------
# Direct unit tests on get_databricks_headers (no FastAPI plumbing)
# ---------------------------------------------------------------------------


class TestGetDatabricksHeadersDirect:
    def test_returns_empty_when_gate_off(self, clean_env):
        clean_env.setenv("TRUST_FORWARDED_HEADERS", "0")
        result = get_databricks_headers(
            host="h", user_name="u", user_id="uid",
            user_email="e", request_id="00000000-0000-0000-0000-000000000001",
            token="t",
        )
        assert result == DatabricksAppsHeaders(
            host=None, user_name=None, user_id=None,
            user_email=None, request_id=None, token=None,
        )

    def test_returns_dev_user_when_gate_off_and_dev_user_set(self, clean_env):
        clean_env.setenv("TRUST_FORWARDED_HEADERS", "0")
        clean_env.setenv("LOCAL_DEV_USER", "alice@example.com")
        result = get_databricks_headers(user_email="evil@example.com")
        assert result.user_email == "alice@example.com"
        assert result.user_name == "alice@example.com"
        assert result.token is None

    def test_passes_through_when_gate_on(self, clean_env):
        clean_env.setenv("TRUST_FORWARDED_HEADERS", "1")
        result = get_databricks_headers(
            host="h.example.com",
            user_name="alice",
            user_id="alice-id",
            user_email="alice@example.com",
            request_id="00000000-0000-0000-0000-000000000002",
            token="tok",
        )
        assert result.host == "h.example.com"
        assert result.user_email == "alice@example.com"
        assert result.user_id == "alice-id"
        assert result.token is not None
        assert result.token.get_secret_value() == "tok"
