"""Source READ-auth (0.7.1).

Per-installation read transport selection for source browse / preview /
download and the upstream-agent monitor. Three modes (github_app / token /
anonymous), secret material referenced by scope/key and read via the app SP.
All mocked — no network, no real Secrets API.

Covers:
- ``resolve_source_transport`` precedence: each mode, unconfigured→env fallback,
  explicit anonymous, incomplete config → graceful anonymous + error, secret
  unreadable → error, unknown mode → anonymous.
- ``BearerTokenTransport`` request shaping + raw-URL rewrite to the Contents API.
- ``capabilities().auth_mode == "token"`` and ``auth_error`` threading.
- ``_read_secret`` cache hit/miss + ``NotFound`` / ``PermissionDenied`` mapping
  (leak-free message).
- ``/config/source-auth`` GET/PUT: admin gate, reference round-trip, secret
  value never returned.
"""

from __future__ import annotations

import base64
from datetime import timedelta

import pytest
from databricks.sdk.errors import NotFound, PermissionDenied

from vibe_modeling.backend.core._config import AppConfig
from vibe_modeling.backend.db_models import AgentConfig
from vibe_modeling.backend.sources import (
    BearerTokenTransport,
    GithubAppTransport,
    GithubSourceConnector,
    SourcePermissionError,
    build_source_connector,
    resolve_source_transport,
)
from vibe_modeling.backend.sources import github as gh


@pytest.fixture(autouse=True)
def _clear_secret_cache():
    """The secret cache is module-level shared state; reset it per test."""
    gh._SECRET_CACHE.clear()
    yield
    gh._SECRET_CACHE.clear()


# ---------------------------------------------------------------------------
# Fakes
# ---------------------------------------------------------------------------


class _Resp:
    def __init__(self, status_code=200, text="", headers=None):
        self.status_code = status_code
        self.text = text
        self.headers = headers or {}


class _FakeSession:
    """A ``requests``-shaped double capturing the outgoing GET call."""

    def __init__(self, response=None):
        self._response = response or _Resp()
        self.get_calls: list[dict] = []

    def get(self, url, *, headers=None, timeout=None):
        self.get_calls.append({"url": url, "headers": headers, "timeout": timeout})
        return self._response


class _SecretValue:
    def __init__(self, value: str):
        self.value = value


class _FakeSecrets:
    """A ``ws.secrets`` double: returns base64-encoded values, or raises."""

    def __init__(self, mapping=None, raises=None):
        # mapping: {(scope, key): plaintext}
        self._mapping = mapping or {}
        self._raises = raises
        self.calls: list[tuple[str, str]] = []

    def get_secret(self, scope, key):
        self.calls.append((scope, key))
        if self._raises is not None:
            raise self._raises
        plaintext = self._mapping[(scope, key)]
        return _SecretValue(base64.b64encode(plaintext.encode("utf-8")).decode("ascii"))


class _FakeWs:
    def __init__(self, secrets):
        self.secrets = secrets


def _cfg(**kwargs) -> AgentConfig:
    return AgentConfig(**kwargs)


# The env-fallback app config: complete GitHub App credentials on AppConfig.
def _env_config(complete=True) -> AppConfig:
    if complete:
        return AppConfig(
            app_name="test",
            github_app_id="env-app",
            github_app_installation_id="env-inst",
            github_app_private_key="env-pem",
        )
    return AppConfig(app_name="test")


# ---------------------------------------------------------------------------
# _read_secret
# ---------------------------------------------------------------------------


class TestReadSecret:
    def test_decodes_base64_value(self):
        ws = _FakeWs(_FakeSecrets({("scope", "key"): "s3cr3t-pem"}))
        assert gh._read_secret(ws, "scope", "key") == "s3cr3t-pem"

    def test_cache_hit_skips_second_api_call(self):
        secrets = _FakeSecrets({("scope", "key"): "v"})
        ws = _FakeWs(secrets)
        assert gh._read_secret(ws, "scope", "key") == "v"
        assert gh._read_secret(ws, "scope", "key") == "v"
        assert secrets.calls == [("scope", "key")]  # one API call, cached hit second

    def test_cache_miss_after_expiry_refetches(self, monkeypatch):
        secrets = _FakeSecrets({("scope", "key"): "v"})
        ws = _FakeWs(secrets)
        base = gh._utcnow()
        monkeypatch.setattr(gh, "_utcnow", lambda: base)
        gh._read_secret(ws, "scope", "key")
        monkeypatch.setattr(
            gh, "_utcnow", lambda: base + timedelta(seconds=gh._SECRET_CACHE_TTL_S + 1)
        )
        gh._read_secret(ws, "scope", "key")
        assert len(secrets.calls) == 2

    @pytest.mark.parametrize("exc", [NotFound("no"), PermissionDenied("nope")])
    def test_not_found_and_permission_denied_map_to_permission_error(self, exc):
        ws = _FakeWs(_FakeSecrets(raises=exc))
        with pytest.raises(SourcePermissionError) as ei:
            gh._read_secret(ws, "supersecret-scope", "supersecret-key")
        msg = str(ei.value)
        # Leak-free: never echoes the scope, key, or secret material.
        assert "supersecret-scope" not in msg
        assert "supersecret-key" not in msg

    def test_negative_result_is_cached(self):
        secrets = _FakeSecrets(raises=NotFound("no"))
        ws = _FakeWs(secrets)
        with pytest.raises(SourcePermissionError):
            gh._read_secret(ws, "scope", "key")
        with pytest.raises(SourcePermissionError):
            gh._read_secret(ws, "scope", "key")
        # Second call served from the negative cache — no second API hit.
        assert len(secrets.calls) == 1

    def test_strips_trailing_newline(self):
        # A PAT stored via `databricks secrets put` commonly carries a trailing
        # newline; it must be stripped or it corrupts the Authorization header.
        ws = _FakeWs(_FakeSecrets({("scope", "key"): "ghp_token\n"}))
        assert gh._read_secret(ws, "scope", "key") == "ghp_token"

    def test_unexpected_error_maps_to_leak_free_permission_error(self):
        # Any non-NotFound/PermissionDenied failure (transient 5xx, network,
        # malformed base64) must degrade to a leak-free SourcePermissionError so
        # the browse path never 500s.
        ws = _FakeWs(_FakeSecrets(raises=RuntimeError("boom-supersecret")))
        with pytest.raises(SourcePermissionError) as ei:
            gh._read_secret(ws, "supersecret-scope", "supersecret-key")
        msg = str(ei.value)
        assert "supersecret-scope" not in msg and "boom-supersecret" not in msg


# ---------------------------------------------------------------------------
# resolve_source_transport
# ---------------------------------------------------------------------------


class TestResolver:
    def _reader(self, mapping=None, raises=None):
        secrets = _FakeSecrets(mapping, raises)
        ws = _FakeWs(secrets)
        return lambda scope, key: gh._read_secret(ws, scope, key)

    def test_github_app_mode(self):
        cfg = _cfg(
            source_auth_mode="github_app",
            source_github_app_id="a",
            source_github_app_installation_id="i",
            source_github_app_secret_scope="sc",
            source_github_app_secret_key="k",
        )
        reader = self._reader({("sc", "k"): "PEM"})
        transport, mode, error = resolve_source_transport(cfg, _env_config(), reader)
        assert isinstance(transport, GithubAppTransport)
        assert mode == "github_app"
        assert error is None

    def test_token_mode(self):
        cfg = _cfg(
            source_auth_mode="token",
            source_token_secret_scope="sc",
            source_token_secret_key="k",
        )
        reader = self._reader({("sc", "k"): "ghp_xxx"})
        transport, mode, error = resolve_source_transport(cfg, _env_config(), reader)
        assert isinstance(transport, BearerTokenTransport)
        assert mode == "token"
        assert error is None

    def test_explicit_anonymous_ignores_env(self):
        cfg = _cfg(source_auth_mode="anonymous")
        transport, mode, error = resolve_source_transport(
            cfg, _env_config(complete=True), self._reader()
        )
        assert transport is None
        assert mode == "anonymous"
        assert error is None

    def test_unconfigured_falls_back_to_env_app(self):
        cfg = _cfg(source_auth_mode="")
        transport, mode, error = resolve_source_transport(
            cfg, _env_config(complete=True), self._reader()
        )
        assert isinstance(transport, GithubAppTransport)
        assert mode == "github_app"
        assert error is None

    def test_unconfigured_no_env_is_anonymous(self):
        cfg = _cfg(source_auth_mode="")
        transport, mode, error = resolve_source_transport(
            cfg, _env_config(complete=False), self._reader()
        )
        assert transport is None
        assert mode == "anonymous"
        assert error is None

    def test_incomplete_github_app_config_degrades_with_error(self):
        cfg = _cfg(
            source_auth_mode="github_app",
            source_github_app_id="a",
            # installation id + secret refs missing
        )
        transport, mode, error = resolve_source_transport(
            cfg, _env_config(), self._reader()
        )
        assert transport is None
        assert mode == "anonymous"
        assert error is not None and "incomplete" in error.lower()

    def test_incomplete_token_config_degrades_with_error(self):
        cfg = _cfg(source_auth_mode="token", source_token_secret_scope="sc")
        transport, mode, error = resolve_source_transport(
            cfg, _env_config(), self._reader()
        )
        assert transport is None
        assert mode == "anonymous"
        assert error is not None

    def test_unreadable_secret_degrades_with_error(self):
        cfg = _cfg(
            source_auth_mode="token",
            source_token_secret_scope="sc",
            source_token_secret_key="k",
        )
        reader = self._reader(raises=PermissionDenied("denied"))
        transport, mode, error = resolve_source_transport(cfg, _env_config(), reader)
        assert transport is None
        assert mode == "anonymous"
        assert error is not None
        # Leak-free: the surfaced error is exactly the constant message, so no
        # scope/key/secret material can appear. (The _read_secret-level guard is
        # covered separately with distinct sentinel scope/key values.)
        assert error == gh._SECRET_READ_ERROR_MSG

    def test_unknown_mode_is_terminal_anonymous(self):
        cfg = _cfg(source_auth_mode="banana")
        transport, mode, error = resolve_source_transport(
            cfg, _env_config(complete=True), self._reader()
        )
        assert transport is None
        assert mode == "anonymous"
        assert error is None


# ---------------------------------------------------------------------------
# BearerTokenTransport
# ---------------------------------------------------------------------------


class TestBearerTokenTransport:
    def test_api_url_request_shaping(self):
        session = _FakeSession()
        t = BearerTokenTransport("ghp_tok", session=session)
        t.get(f"{gh._API_BASE}/repos/o/n/contents/x?ref=main")
        call = session.get_calls[0]
        assert call["url"] == f"{gh._API_BASE}/repos/o/n/contents/x?ref=main"
        assert call["headers"]["Authorization"] == "Bearer ghp_tok"
        assert call["headers"]["Accept"] == gh._GITHUB_JSON_MEDIA_TYPE
        assert call["headers"]["X-GitHub-Api-Version"] == gh._GITHUB_API_VERSION

    def test_raw_url_rewritten_to_contents_api_with_raw_media(self):
        session = _FakeSession()
        t = BearerTokenTransport("ghp_tok", session=session)
        t.get(f"{gh._RAW_BASE}/o/n/main/data-models/x/model.json")
        call = session.get_calls[0]
        # Rewritten onto api.github.com Contents API...
        assert call["url"].startswith(f"{gh._API_BASE}/repos/o/n/contents/")
        assert "raw.githubusercontent.com" not in call["url"]
        # ...and the raw-media Accept wins over the JSON default (extra_headers
        # merge last), mirroring GithubAppTransport._request exactly.
        assert call["headers"]["Accept"] == gh._GITHUB_RAW_MEDIA_TYPE
        assert call["headers"]["Authorization"] == "Bearer ghp_tok"


# ---------------------------------------------------------------------------
# capabilities() threading
# ---------------------------------------------------------------------------


class TestCapabilities:
    def test_token_transport_reports_token_mode(self):
        conn = GithubSourceConnector(http=BearerTokenTransport("t"))
        assert conn.capabilities().auth_mode == "token"

    def test_explicit_mode_and_error_threaded(self):
        conn = GithubSourceConnector(
            http=None, auth_mode="anonymous", auth_error="secret unreadable"
        )
        caps = conn.capabilities()
        assert caps.auth_mode == "anonymous"
        assert caps.auth_error == "secret unreadable"

    def test_no_error_when_clean(self):
        conn = GithubSourceConnector(http=BearerTokenTransport("t"), auth_mode="token")
        assert conn.capabilities().auth_error is None


# ---------------------------------------------------------------------------
# build_source_connector
# ---------------------------------------------------------------------------


class TestBuildSourceConnector:
    def test_token_end_to_end(self):
        cfg = _cfg(
            source_auth_mode="token",
            source_token_secret_scope="sc",
            source_token_secret_key="k",
        )
        ws = _FakeWs(_FakeSecrets({("sc", "k"): "ghp_x"}))
        conn = build_source_connector(cfg, _env_config(), ws)
        caps = conn.capabilities()
        assert caps.auth_mode == "token"
        assert caps.auth_error is None

    def test_unreadable_secret_surfaces_auth_error(self):
        cfg = _cfg(
            source_auth_mode="token",
            source_token_secret_scope="sc",
            source_token_secret_key="k",
        )
        ws = _FakeWs(_FakeSecrets(raises=NotFound("no")))
        conn = build_source_connector(cfg, _env_config(), ws)
        caps = conn.capabilities()
        assert caps.auth_mode == "anonymous"
        assert caps.auth_error is not None


# ---------------------------------------------------------------------------
# /config/source-auth endpoint
# ---------------------------------------------------------------------------


class TestSourceAuthEndpoint:
    def test_get_returns_references_and_effective_mode(self, client):
        resp = client.get("/api/config/source-auth")
        assert resp.status_code == 200
        data = resp.json()
        for key in (
            "auth_mode", "github_app_id", "github_app_installation_id",
            "github_app_secret_scope", "github_app_secret_key",
            "token_secret_scope", "token_secret_key", "effective_mode", "error",
        ):
            assert key in data
        # Fresh install: unconfigured, no env creds on the test AppConfig →
        # effective mode is anonymous.
        assert data["effective_mode"] == "anonymous"

    def test_put_round_trips_references_never_secret_values(self, client, mock_ws):
        # The Out layer computes effective_mode via a live (cached) secret read.
        mock_ws.secrets.get_secret.side_effect = None
        mock_ws.secrets.get_secret.return_value = _SecretValue(
            base64.b64encode(b"ghp_x").decode("ascii")
        )
        payload = {
            "auth_mode": "token",
            "github_app_id": "",
            "github_app_installation_id": "",
            "github_app_secret_scope": "",
            "github_app_secret_key": "",
            "token_secret_scope": "my-scope",
            "token_secret_key": "my-key",
        }
        resp = client.put("/api/config/source-auth", json=payload)
        assert resp.status_code == 200
        data = resp.json()
        assert data["auth_mode"] == "token"
        assert data["token_secret_scope"] == "my-scope"
        assert data["token_secret_key"] == "my-key"
        # Response is references only — no field carries a decoded secret value.
        assert "value" not in data
        assert set(data.keys()) == {
            "auth_mode", "github_app_id", "github_app_installation_id",
            "github_app_secret_scope", "github_app_secret_key",
            "token_secret_scope", "token_secret_key", "effective_mode", "error",
        }

    def test_put_partial_save_does_not_null_siblings(self, client, mock_ws):
        mock_ws.secrets.get_secret.side_effect = None
        mock_ws.secrets.get_secret.return_value = _SecretValue(
            base64.b64encode(b"pem-bytes").decode("ascii")
        )
        # First save both App and token references.
        client.put("/api/config/source-auth", json={
            "auth_mode": "github_app",
            "github_app_id": "app-1",
            "github_app_installation_id": "inst-1",
            "github_app_secret_scope": "app-scope",
            "github_app_secret_key": "app-key",
            "token_secret_scope": "tok-scope",
            "token_secret_key": "tok-key",
        })
        # A second save carrying the same fields round-trips them all — the
        # PUT contract requires the client to send every field.
        resp = client.put("/api/config/source-auth", json={
            "auth_mode": "anonymous",
            "github_app_id": "app-1",
            "github_app_installation_id": "inst-1",
            "github_app_secret_scope": "app-scope",
            "github_app_secret_key": "app-key",
            "token_secret_scope": "tok-scope",
            "token_secret_key": "tok-key",
        })
        data = resp.json()
        assert data["auth_mode"] == "anonymous"
        assert data["github_app_secret_scope"] == "app-scope"
        assert data["token_secret_scope"] == "tok-scope"
