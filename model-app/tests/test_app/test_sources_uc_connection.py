"""Tests for the UC-HTTP-connection GitHub transport mechanics.

``UcConnectionTransport`` is NO LONGER selected for source reads (0.7.0 moved
reads to the deployment's GitHub App - see ``test_github_app_transport.py``).
The class is retained in the module for the future publish-PR path, so these
tests exercise its mechanics directly (URL translation + response/error mapping
against a fake OBO ``user_ws``, no network) by injecting it as the connector's
``http`` transport.
"""

from __future__ import annotations

import io
import json
from collections.abc import Callable

import pytest
from databricks.sdk.errors import NotFound, PermissionDenied, TooManyRequests

from vibe_modeling.backend.sources import (
    GithubSourceConnector,
    SourceError,
    SourceNotFoundError,
    SourceRateLimitError,
    UcConnectionTransport,
)
from vibe_modeling.backend.sources import github as gh


# ---------------------------------------------------------------------------
# Fake OBO user_ws
# ---------------------------------------------------------------------------


class _FakeRequestsResp:
    """Mimics the ``requests.Response`` that ``ServingEndpointsExt.http_request``
    returns (body on ``.text``)."""

    def __init__(self, body: str):
        self.text = body


class _FakeHttpResp:
    """Mimics a base ``HttpRequestResponse`` (a ``contents`` binary stream) - the
    fallback shape ``_read_uc_contents`` must still decode."""

    def __init__(self, body: str):
        self.contents = io.BytesIO(body.encode("utf-8"))


class _FakeServingEndpoints:
    def __init__(
        self,
        routes: dict[str, str | Exception],
        resp_cls: Callable[[str], object] = _FakeRequestsResp,
    ):
        # routes: substring-of-path -> str body OR an Exception instance to raise.
        self._routes = routes
        self._resp_cls = resp_cls
        self.calls: list[dict] = []

    def http_request(self, conn, method, path, *, headers=None, **extra):
        # Signature matches ``ServingEndpointsExt.http_request``: ``conn`` is
        # POSITIONAL and ``headers`` is a ``Dict[str, str]`` (the SDK does its own
        # JSON-encoding). A caller passing ``connection_name=`` or a stringified
        # ``headers`` would land in ``extra`` / fail here, surfacing the bug.
        self.calls.append(
            {
                "connection_name": conn,
                "method": method,
                "path": path,
                "headers": headers,
                "extra": extra,
            }
        )
        for needle, outcome in self._routes.items():
            if needle in path:
                if isinstance(outcome, Exception):
                    raise outcome
                return self._resp_cls(outcome)
        raise NotFound(f"no fake route for {path}")


class _FakeUserWs:
    def __init__(
        self,
        routes: dict[str, str | Exception],
        resp_cls: Callable[[str], object] = _FakeRequestsResp,
    ):
        self.serving_endpoints = _FakeServingEndpoints(routes, resp_cls=resp_cls)


def _dir(name: str):
    return {"name": name, "type": "dir", "size": 0}


# ---------------------------------------------------------------------------
# UcConnectionTransport URL translation
# ---------------------------------------------------------------------------


def test_translate_api_url_strips_host():
    url = gh._API_BASE + "/repos/o/r/contents/data-models/banking?ref=main"
    path, headers = gh._translate_github_url(url)
    assert path == "/repos/o/r/contents/data-models/banking?ref=main"
    assert headers == {}


def test_translate_raw_url_rewrites_to_contents_api_with_raw_accept():
    url = gh._RAW_BASE + "/o/r/main/data-models/banking/v1/ecm/model.json"
    path, headers = gh._translate_github_url(url)
    assert path == "/repos/o/r/contents/data-models/banking/v1/ecm/model.json?ref=main"
    assert headers == {"Accept": gh._GITHUB_RAW_MEDIA_TYPE}


# ---------------------------------------------------------------------------
# UcConnectionTransport through the connector (no network)
# ---------------------------------------------------------------------------


def _uc_connector(routes: dict[str, str | Exception]) -> tuple[GithubSourceConnector, _FakeUserWs]:
    ws = _FakeUserWs(routes)
    conn = GithubSourceConnector(
        repo_owner="o", repo_name="r",
        http=UcConnectionTransport(ws, "github_pr"),
    )
    return conn, ws


def test_uc_list_industries_routes_through_connection():
    body = json.dumps([_dir("banking"), _dir("ecommerce")])
    conn, ws = _uc_connector({"/contents/data-models?ref=main": body})
    sector_id = conn.list_sectors()[0].id
    industries = {i.id for i in conn.list_industries(sector_id)}
    assert industries == {"banking", "ecommerce"}
    # It went through the UC connection (not requests), with the connection name.
    assert ws.serving_endpoints.calls
    assert ws.serving_endpoints.calls[0]["connection_name"] == "github_pr"


def test_uc_fetch_model_json_uses_contents_api_raw_accept():
    doc = json.dumps({"model_name": "banking_ecm", "domains": []})
    conn, ws = _uc_connector(
        {"/repos/o/r/contents/data-models/banking/v1/ecm/model.json": doc}
    )
    assert conn.fetch_model_json("banking", "v1_ecm") == doc
    call = ws.serving_endpoints.calls[-1]
    assert call["path"].startswith(
        "/repos/o/r/contents/data-models/banking/v1/ecm/model.json"
    )
    assert "ref=main" in call["path"]
    # headers is a dict (the SDK JSON-encodes it), NOT a pre-serialized string.
    assert call["headers"] == {"Accept": gh._GITHUB_RAW_MEDIA_TYPE}


def test_uc_http_request_passes_connection_name_positionally_and_headers_as_dict():
    """Regression guard for the ``ServingEndpointsExt.http_request`` contract:
    ``conn`` is the first POSITIONAL arg (not a ``connection_name=`` kwarg) and
    ``headers`` is a ``Dict[str, str]`` (the SDK does its own JSON-encoding).
    Pre-fix code passed ``connection_name=`` + ``json.dumps(headers)`` and fails
    both assertions (the kwarg would also land in ``extra``)."""
    doc = json.dumps({"model_name": "banking_ecm", "domains": []})
    conn, ws = _uc_connector(
        {"/repos/o/r/contents/data-models/banking/v1/ecm/model.json": doc}
    )
    conn.fetch_model_json("banking", "v1_ecm")
    call = ws.serving_endpoints.calls[-1]
    # conn arrived positionally -> the fake bound it as ``conn``; nothing leaked
    # into **extra (e.g. a stray ``connection_name=`` kwarg).
    assert call["connection_name"] == "github_pr"
    assert call["extra"] == {}
    # headers is a dict, not a str.
    assert isinstance(call["headers"], dict)
    assert call["headers"] == {"Accept": gh._GITHUB_RAW_MEDIA_TYPE}


def test_uc_reads_requests_response_via_text():
    """``ServingEndpointsExt.http_request`` returns a ``requests.Response`` whose
    body is on ``.text``. The transport must read it from ``.text`` (pre-fix code
    read a non-existent ``.contents`` and returned an empty body)."""
    body = json.dumps([_dir("banking"), _dir("ecommerce")])
    conn, _ = _uc_connector({"/contents/data-models?ref=main": body})
    # _FakeRequestsResp exposes ``.text`` only (no ``.contents``).
    industries = {i.id for i in conn.list_industries(conn.list_sectors()[0].id)}
    assert industries == {"banking", "ecommerce"}


def test_uc_reads_httprequestresponse_contents_fallback():
    """A base ``HttpRequestResponse``-shaped return (``.contents`` stream, no
    ``.text``) is still decoded via the fallback path."""
    body = json.dumps([_dir("banking")])
    ws = _FakeUserWs({"/contents/data-models?ref=main": body}, resp_cls=_FakeHttpResp)
    conn = GithubSourceConnector(
        repo_owner="o", repo_name="r",
        http=UcConnectionTransport(ws, "github_pr"),
    )
    industries = {i.id for i in conn.list_industries(conn.list_sectors()[0].id)}
    assert industries == {"banking"}


def test_uc_industries_404_surfaces_restructured_message():
    """A 404 on the industries tree surfaces the actionable 'restructured'
    message rather than the opaque default 'Path not found' text."""
    conn, _ = _uc_connector({"/contents/data-models?ref=main": NotFound("Not Found")})
    with pytest.raises(SourceNotFoundError) as exc_info:
        conn.list_industries(conn.list_sectors()[0].id)
    assert "the source repo may have restructured" in str(exc_info.value)
    assert "data-models" in str(exc_info.value)


def test_uc_404_maps_to_not_found():
    conn, _ = _uc_connector(
        {"/contents/data-models/banking/v1/ecm/model.json": NotFound("Not Found")}
    )
    with pytest.raises(SourceNotFoundError):
        conn.fetch_model_json("banking", "v1_ecm")


def test_uc_too_many_requests_maps_to_rate_limit():
    conn, _ = _uc_connector(
        {"/contents/data-models?ref=main": TooManyRequests("rate limited")}
    )
    with pytest.raises(SourceRateLimitError):
        conn.list_industries(conn.list_sectors()[0].id)


def test_uc_permission_denied_maps_to_permission_error_not_rate_limit():
    """A genuine 403 (repo/scope) must NOT masquerade as a rate-limit 429; it is
    a SourcePermissionError (a SourceError) mapped to HTTP 403 by the route."""
    from vibe_modeling.backend.sources import SourcePermissionError

    conn, _ = _uc_connector(
        {"/contents/data-models?ref=main": PermissionDenied("Forbidden")}
    )
    with pytest.raises(SourceError) as exc_info:
        conn.list_industries(conn.list_sectors()[0].id)
    assert not isinstance(exc_info.value, SourceRateLimitError)
    assert isinstance(exc_info.value, SourcePermissionError)
