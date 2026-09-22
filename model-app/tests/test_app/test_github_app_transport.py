"""GitHub App read-auth transport (0.7.0).

Source reads authenticate as the deployment's GitHub App: sign an RS256 JWT,
mint a 1h installation token, and call the REST API at 5,000 req/hr (immune to
the industry repo's SAML SSO). This suite covers, all mocked (no network):

- JWT sign (RS256, iss=app_id, iat=now-60, exp<=now+600) + token mint + the
  minted token applied as ``Authorization: Bearer`` on the subsequent GET.
- Module-level caching (two gets within TTL mint once) + refresh (frozen clock
  past ``expires_at - 300s`` re-mints; a 401 triggers one refresh+retry; a
  second 401 surfaces as ``SourcePermissionError`` at the connector layer).
- Raw-URL rewrite routed to the Contents API with the raw Accept header (the
  shared ``_translate_github_url``).
- ``build_github_connector`` transport precedence + ``capabilities().auth_mode``.
- ``AppConfig.github_app_credentials`` completeness gate.
"""

from __future__ import annotations

import json
from datetime import datetime, timedelta, timezone

import jwt
import pytest
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa

from vibe_modeling.backend.sources import (
    GithubAppCredentials,
    GithubAppTransport,
    GithubSourceConnector,
    SourcePermissionError,
    build_github_connector,
)
from vibe_modeling.backend.sources import github as gh


# ---------------------------------------------------------------------------
# RSA keypair (module-scoped: generation is the slow part)
# ---------------------------------------------------------------------------


@pytest.fixture(scope="module")
def rsa_keys() -> tuple[str, str]:
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    private_pem = key.private_bytes(
        serialization.Encoding.PEM,
        serialization.PrivateFormat.PKCS8,
        serialization.NoEncryption(),
    ).decode()
    public_pem = (
        key.public_key()
        .public_bytes(
            serialization.Encoding.PEM,
            serialization.PublicFormat.SubjectPublicKeyInfo,
        )
        .decode()
    )
    return private_pem, public_pem


@pytest.fixture(autouse=True)
def _clear_token_cache():
    gh._APP_TOKEN_CACHE.clear()
    yield
    gh._APP_TOKEN_CACHE.clear()


# ---------------------------------------------------------------------------
# Fakes
# ---------------------------------------------------------------------------


class _Resp:
    def __init__(self, status_code, *, json_body=None, text="", headers=None):
        self.status_code = status_code
        self._json = json_body
        self.text = text or (json.dumps(json_body) if json_body is not None else "")
        self.headers = headers or {}

    def json(self):
        if self._json is not None:
            return self._json
        return json.loads(self.text)


def _token_resp(token="tok-1", *, expires_in_s=3600, status=201) -> _Resp:
    exp = (datetime.now(timezone.utc) + timedelta(seconds=expires_in_s)).strftime(
        "%Y-%m-%dT%H:%M:%SZ"
    )
    return _Resp(status, json_body={"token": token, "expires_at": exp})


class _FakeSession:
    """A ``requests``-shaped double exposing queued ``get``/``post`` responses."""

    def __init__(self, *, post_responses=None, get_responses=None):
        self.post_responses = list(post_responses or [])
        self.get_responses = list(get_responses or [])
        self.post_calls: list[dict] = []
        self.get_calls: list[dict] = []

    def post(self, url, *, headers=None, timeout=None):
        self.post_calls.append({"url": url, "headers": headers})
        return self.post_responses.pop(0)

    def get(self, url, *, headers=None, timeout=None):
        self.get_calls.append({"url": url, "headers": headers})
        return self.get_responses.pop(0)


CREDS = GithubAppCredentials(
    app_id="123456", installation_id="99887766", private_key_pem="<pem>"
)


def _creds(private_pem: str) -> GithubAppCredentials:
    return GithubAppCredentials(
        app_id="123456", installation_id="99887766", private_key_pem=private_pem
    )


# ---------------------------------------------------------------------------
# JWT sign + token mint + bearer application
# ---------------------------------------------------------------------------


def test_mint_signs_rs256_jwt_and_applies_bearer_token(rsa_keys):
    private_pem, public_pem = rsa_keys
    session = _FakeSession(
        post_responses=[_token_resp("inst-tok")],
        get_responses=[_Resp(200, json_body=[])],
    )
    transport = GithubAppTransport(_creds(private_pem), session=session)

    transport.get(gh._API_BASE + "/repos/o/r/contents/data-models?ref=main")

    # One mint POST to the installation access-tokens endpoint.
    assert len(session.post_calls) == 1
    assert session.post_calls[0]["url"].endswith(
        "/app/installations/99887766/access_tokens"
    )
    # The mint bearer is a valid RS256 JWT with the required claims.
    auth = session.post_calls[0]["headers"]["Authorization"]
    assert auth.startswith("Bearer ")
    signed = auth[len("Bearer ") :]
    header = jwt.get_unverified_header(signed)
    assert header["alg"] == "RS256"
    claims = jwt.decode(signed, public_pem, algorithms=["RS256"])
    assert claims["iss"] == "123456"
    assert claims["exp"] - claims["iat"] == gh._JWT_TTL_S + gh._JWT_IAT_SKEW_S
    assert claims["exp"] - claims["iat"] <= 600 + 60
    # The minted installation token is applied as Bearer on the API GET.
    assert session.get_calls[0]["headers"]["Authorization"] == "Bearer inst-tok"
    assert session.get_calls[0]["headers"]["Accept"] == gh._GITHUB_JSON_MEDIA_TYPE


def test_mint_failure_raises_permission_error(rsa_keys):
    private_pem, _ = rsa_keys
    session = _FakeSession(post_responses=[_token_resp(status=404)])
    transport = GithubAppTransport(_creds(private_pem), session=session)
    with pytest.raises(SourcePermissionError):
        transport.get(gh._API_BASE + "/repos/o/r/contents/x")


def test_bad_pem_raises_permission_error_not_unhandled(rsa_keys):
    """A garbage/corrupt PEM makes jwt.encode raise a cryptography/ValueError.
    It must map to SourcePermissionError (-> HTTP 403 via _guard), NOT bubble up
    as an unhandled 500 - and never leak key material into the message."""
    # No post/get responses queued: signing must fail before any HTTP call.
    session = _FakeSession()
    bad = GithubAppCredentials(
        app_id="123456",
        installation_id="99887766",
        private_key_pem="-----BEGIN RSA PRIVATE KEY-----\nnot-a-real-key\n-----END RSA PRIVATE KEY-----",
    )
    transport = GithubAppTransport(bad, session=session)
    with pytest.raises(SourcePermissionError) as exc_info:
        transport.get(gh._API_BASE + "/repos/o/r/contents/x")
    # Signing failed before any network call; no key material in the message.
    assert session.post_calls == []
    assert "not-a-real-key" not in str(exc_info.value)


# ---------------------------------------------------------------------------
# Caching + refresh
# ---------------------------------------------------------------------------


def test_two_gets_within_ttl_mint_once(rsa_keys):
    private_pem, _ = rsa_keys
    session = _FakeSession(
        post_responses=[_token_resp("tok-1")],
        get_responses=[_Resp(200, json_body=[]), _Resp(200, json_body=[])],
    )
    transport = GithubAppTransport(_creds(private_pem), session=session)
    transport.get(gh._API_BASE + "/repos/o/r/contents/a")
    transport.get(gh._API_BASE + "/repos/o/r/contents/b")
    assert len(session.post_calls) == 1
    assert len(session.get_calls) == 2


def test_cache_shared_across_transport_instances(rsa_keys):
    """The cache is module-level: a fresh transport (built per request) reuses
    the token minted by an earlier instance for the same installation."""
    private_pem, _ = rsa_keys
    creds = _creds(private_pem)
    s1 = _FakeSession(
        post_responses=[_token_resp("tok-1")], get_responses=[_Resp(200, json_body=[])]
    )
    GithubAppTransport(creds, session=s1).get(gh._API_BASE + "/repos/o/r/contents/a")
    s2 = _FakeSession(get_responses=[_Resp(200, json_body=[])])
    GithubAppTransport(creds, session=s2).get(gh._API_BASE + "/repos/o/r/contents/b")
    assert len(s1.post_calls) == 1
    assert len(s2.post_calls) == 0  # reused the cached token, no re-mint
    assert s2.get_calls[0]["headers"]["Authorization"] == "Bearer tok-1"


def test_refresh_when_clock_past_expiry_margin(rsa_keys, monkeypatch):
    private_pem, _ = rsa_keys
    t0 = datetime(2026, 1, 1, 12, 0, 0, tzinfo=timezone.utc)
    monkeypatch.setattr(gh, "_utcnow", lambda: t0)
    # Anchor the minted expires_at to the frozen clock, else the 1h TTL is
    # computed off the real wall clock and the margin check never trips.
    exp_str = (t0 + timedelta(hours=1)).strftime("%Y-%m-%dT%H:%M:%SZ")
    session = _FakeSession(
        post_responses=[
            _Resp(201, json_body={"token": "tok-1", "expires_at": exp_str}),
            _Resp(201, json_body={"token": "tok-2", "expires_at": exp_str}),
        ],
        get_responses=[_Resp(200, json_body=[]), _Resp(200, json_body=[])],
    )
    transport = GithubAppTransport(_creds(private_pem), session=session)
    transport.get(gh._API_BASE + "/repos/o/r/contents/a")
    # Advance to within the 300s refresh margin of the 1h token.
    monkeypatch.setattr(gh, "_utcnow", lambda: t0 + timedelta(seconds=3600 - 200))
    transport.get(gh._API_BASE + "/repos/o/r/contents/b")
    assert len(session.post_calls) == 2
    assert session.get_calls[1]["headers"]["Authorization"] == "Bearer tok-2"


def test_401_triggers_one_refresh_and_retry(rsa_keys):
    private_pem, _ = rsa_keys
    session = _FakeSession(
        post_responses=[_token_resp("tok-1"), _token_resp("tok-2")],
        get_responses=[_Resp(401, text="bad creds"), _Resp(200, json_body=[])],
    )
    transport = GithubAppTransport(_creds(private_pem), session=session)
    resp = transport.get(gh._API_BASE + "/repos/o/r/contents/a")
    assert resp.status_code == 200
    assert len(session.post_calls) == 2  # initial mint + one forced refresh
    assert len(session.get_calls) == 2
    assert session.get_calls[1]["headers"]["Authorization"] == "Bearer tok-2"


def test_second_401_surfaces_as_permission_error(rsa_keys):
    private_pem, _ = rsa_keys
    session = _FakeSession(
        post_responses=[_token_resp("tok-1"), _token_resp("tok-2")],
        get_responses=[_Resp(401, text="denied"), _Resp(401, text="denied")],
    )
    conn = GithubSourceConnector(
        repo_owner="o", repo_name="r",
        http=GithubAppTransport(_creds(private_pem), session=session),
    )
    with pytest.raises(SourcePermissionError):
        conn.list_industries(gh._REPO_SECTOR_ID)
    assert len(session.post_calls) == 2  # one refresh, no infinite loop
    assert len(session.get_calls) == 2


# ---------------------------------------------------------------------------
# Raw-URL rewrite -> Contents API with raw Accept (shared _translate_github_url)
# ---------------------------------------------------------------------------


def test_raw_url_routed_to_contents_api_with_raw_accept(rsa_keys):
    private_pem, _ = rsa_keys
    session = _FakeSession(
        post_responses=[_token_resp("tok-1")],
        get_responses=[_Resp(200, text='{"model": {}}')],
    )
    transport = GithubAppTransport(_creds(private_pem), session=session)
    transport.get(gh._RAW_BASE + "/o/r/main/data-models/banking/v1/ecm/model.json")
    call = session.get_calls[0]
    assert call["url"] == (
        gh._API_BASE
        + "/repos/o/r/contents/data-models/banking/v1/ecm/model.json?ref=main"
    )
    assert call["headers"]["Accept"] == gh._GITHUB_RAW_MEDIA_TYPE
    assert call["headers"]["Authorization"] == "Bearer tok-1"


class _StaticHttp:
    """A minimal requests-shaped transport that returns one response for every
    GET - isolates the connector's status mapping from the App token dance."""

    def __init__(self, status: int, *, text="denied"):
        self._status = status
        self._text = text

    def get(self, url, timeout=None):  # noqa: ARG002
        return _Resp(self._status, text=self._text)


@pytest.mark.parametrize("status", [401, 403])
def test_fetch_raw_permission_status_maps_to_permission_error(status):
    """_fetch_raw (the file-byte path) maps 401/403 to SourcePermissionError,
    mirroring _list_contents. The rate-limit 403 path is separate (has
    X-RateLimit-Remaining: 0) and is unaffected."""
    conn = GithubSourceConnector(repo_owner="o", repo_name="r", http=_StaticHttp(status))
    with pytest.raises(SourcePermissionError):
        conn.fetch_model_json("banking", "v1_ecm")


def test_app_transport_fetch_model_json_stays_on_api_host(rsa_keys):
    """A file byte fetch goes through api.github.com (authenticated 5,000/hr),
    never raw.githubusercontent.com."""
    private_pem, _ = rsa_keys
    doc = json.dumps({"model": {"name": "banking"}})
    session = _FakeSession(
        post_responses=[_token_resp("tok-1")], get_responses=[_Resp(200, text=doc)]
    )
    conn = GithubSourceConnector(
        repo_owner="o", repo_name="r",
        http=GithubAppTransport(_creds(private_pem), session=session),
    )
    assert conn.fetch_model_json("banking", "v1_ecm") == doc
    assert session.get_calls[0]["url"].startswith(gh._API_BASE)
    assert gh._RAW_BASE not in session.get_calls[0]["url"]


# ---------------------------------------------------------------------------
# build_github_connector transport precedence + capabilities auth_mode
# ---------------------------------------------------------------------------


def test_build_selects_app_transport_when_creds_complete():
    conn = build_github_connector(repo_owner="o", repo_name="r", app_credentials=CREDS)
    assert isinstance(conn._http, GithubAppTransport)
    assert conn.capabilities().auth_mode == "github_app"


def test_build_falls_back_anonymous_without_creds():
    conn = build_github_connector(repo_owner="o", repo_name="r", app_credentials=None)
    assert not isinstance(conn._http, GithubAppTransport)
    assert conn.capabilities().auth_mode == "anonymous"


def test_build_falls_back_anonymous_when_creds_incomplete():
    incomplete = GithubAppCredentials(
        app_id="123", installation_id="", private_key_pem="<pem>"
    )
    conn = build_github_connector(app_credentials=incomplete)
    assert conn.capabilities().auth_mode == "anonymous"


def test_explicit_http_override_wins_over_app_creds():
    sentinel = object()
    conn = build_github_connector(app_credentials=CREDS, http=sentinel)
    assert conn._http is sentinel
    assert conn.capabilities().auth_mode == "anonymous"


# ---------------------------------------------------------------------------
# Route capabilities reflect the resolved transport
# ---------------------------------------------------------------------------


def test_capabilities_route_reports_github_app(client, monkeypatch):
    import vibe_modeling.backend.routes.sources as routes_sources

    def _fake_connector(session, config):  # noqa: ARG001
        return build_github_connector(
            repo_owner="o", repo_name="r", app_credentials=CREDS
        )

    monkeypatch.setattr(routes_sources, "_connector", _fake_connector)
    resp = client.get("/api/sources/capabilities")
    assert resp.status_code == 200
    assert resp.json()["auth_mode"] == "github_app"


def test_capabilities_route_reports_anonymous_without_creds(client, monkeypatch):
    import vibe_modeling.backend.routes.sources as routes_sources

    def _fake_connector(session, config):  # noqa: ARG001
        return build_github_connector(repo_owner="o", repo_name="r")

    monkeypatch.setattr(routes_sources, "_connector", _fake_connector)
    resp = client.get("/api/sources/capabilities")
    assert resp.status_code == 200
    assert resp.json()["auth_mode"] == "anonymous"


def test_route_maps_permission_error_to_http_403(client, monkeypatch):
    """A SourcePermissionError from any browse route maps to HTTP 403 via
    ``_guard`` (one guard, all routes), NOT the generic 502."""
    import vibe_modeling.backend.routes.sources as routes_sources

    class _DenyingConnector:
        def list_sectors(self):
            raise SourcePermissionError("GitHub denied access (403) for '_repo'.")

    monkeypatch.setattr(
        routes_sources, "_connector", lambda session, config: _DenyingConnector()
    )
    resp = client.get("/api/sources/sectors")
    assert resp.status_code == 403


# ---------------------------------------------------------------------------
# AppConfig credential gate + convergent _connector wiring
# ---------------------------------------------------------------------------


def test_app_config_credentials_none_unless_all_three_set():
    from vibe_modeling.backend.core._config import AppConfig

    complete = AppConfig(
        github_app_id="a",
        github_app_installation_id="b",
        github_app_private_key="c",
    )
    creds = complete.github_app_credentials
    assert creds is not None
    assert creds.app_id == "a" and creds.installation_id == "b"
    assert creds.private_key_pem == "c"

    for kwargs in (
        {"github_app_id": "a", "github_app_installation_id": "b"},
        {"github_app_id": "a", "github_app_private_key": "c"},
        {"github_app_installation_id": "b", "github_app_private_key": "c"},
        {},
    ):
        assert AppConfig(**kwargs).github_app_credentials is None


def test_download_connector_forwards_app_credentials(monkeypatch):
    """``industry_download._connector`` forwards the deployment App credentials
    + the github_repo pointers to ``build_github_connector`` (one convergent
    construction, mirroring routes.sources._connector)."""
    import vibe_modeling.backend.services.industry_download as dl

    captured: dict = {}

    def _spy(repo_owner="", repo_name="", **kwargs):
        captured.update(kwargs)
        captured["repo_owner"] = repo_owner
        captured["repo_name"] = repo_name
        return GithubSourceConnector(repo_owner=repo_owner or "o", repo_name=repo_name or "r")

    monkeypatch.setattr(dl, "build_github_connector", _spy)

    class _Cfg:
        github_repo_owner = "acme"
        github_repo_name = "models"

    monkeypatch.setattr(
        "vibe_modeling.backend.routes._helpers._get_or_create_agent_config",
        lambda session, config: _Cfg(),
    )

    class _AppConfig:
        github_app_credentials = CREDS

    dl._connector(session=None, config=_AppConfig())
    assert captured["app_credentials"] is CREDS
    assert captured["repo_owner"] == "acme"
    assert captured["repo_name"] == "models"


def test_routes_connector_forwards_app_credentials(monkeypatch):
    """``routes.sources._connector`` forwards ``config.github_app_credentials``
    + the github_repo pointers into ``build_github_connector`` (the same
    convergent construction as the download helper)."""
    import vibe_modeling.backend.routes.sources as routes_sources

    captured: dict = {}

    def _spy(repo_owner="", repo_name="", **kwargs):
        captured.update(kwargs)
        captured["repo_owner"] = repo_owner
        captured["repo_name"] = repo_name
        return GithubSourceConnector(repo_owner=repo_owner or "o", repo_name=repo_name or "r")

    monkeypatch.setattr(routes_sources, "build_github_connector", _spy)

    class _Cfg:
        github_repo_owner = "acme"
        github_repo_name = "models"

    monkeypatch.setattr(routes_sources, "_get_or_create_agent_config", lambda session, config: _Cfg())

    class _AppConfig:
        github_app_credentials = CREDS

    routes_sources._connector(session=None, config=_AppConfig())
    assert captured["app_credentials"] is CREDS
    assert captured["repo_owner"] == "acme"
    assert captured["repo_name"] == "models"


def test_download_industry_model_maps_permission_error_to_http_403(monkeypatch):
    """A SourcePermissionError from the source (bad App creds / private repo)
    during a download maps to HTTP 403, not the generic 502."""
    from fastapi import HTTPException

    import vibe_modeling.backend.services.industry_download as dl

    class _DenyingConnector:
        def fetch_model_json(self, industry_id, model_id):
            raise SourcePermissionError("GitHub denied access (403) for '...'.")

    monkeypatch.setattr(dl, "build_github_connector", lambda *a, **k: _DenyingConnector())
    monkeypatch.setattr(
        "vibe_modeling.backend.routes._helpers._get_or_create_agent_config",
        lambda session, config: type("C", (), {"github_repo_owner": "", "github_repo_name": ""})(),
    )

    class _AppConfig:
        github_app_credentials = CREDS

    with pytest.raises(HTTPException) as exc_info:
        dl.download_industry_model(
            session=None, ws=None, config=_AppConfig(),
            sector_id="s", industry_id="banking", model_id="v1_ecm",
        )
    assert exc_info.value.status_code == 403
