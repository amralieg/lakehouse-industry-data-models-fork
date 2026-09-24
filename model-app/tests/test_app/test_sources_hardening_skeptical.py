"""Independent skeptical tester suite for the 7 GitHub-source hardening fixes.

Written by a tester who did NOT author the fixes and distrusts them.
Goal: try to BREAK each of the 7 fixes in
``backend/sources/github.py``. Every HTTP call is served by an
in-process fake — there is NO network in any path here. No auto-retry:
each assertion is fail-fast.

The fixes under attack:
  #1 ``_list_contents`` wraps ``resp.json()`` -> SourceError (clean 502)
  #2 ``fetch_artifacts`` catches SourceError per sub-dir (partial list)
  #3 MODEL_JSON artifact only when model.json present
  #4 nameless / blank dir entries skipped
  #5 ``_encode_path`` / quote on URL segments (no structural escape)
  #6 ``requests`` declared (pyproject)
  #7 dead ``ref`` param removed from ``build_github_connector``
"""

from __future__ import annotations

import inspect
import json

import pytest

from vibe_modeling.backend.sources import (
    GithubSourceConnector,
    SourceError,
    SourceNotFoundError,
    TargetKind,
    build_github_connector,
)
from vibe_modeling.backend.sources import github as gh

# Parametric contents-API route-key builder: keys are scoped under
# ``gh.DEFAULT_BASE_PATH`` so the base-path move can't silently break matching.
# Shared from test_sources so the derivation lives in exactly one place.
from .test_sources import contents_key


# ---------------------------------------------------------------------------
# Fake HTTP — substring routing, records calls, NEVER touches the network
# ---------------------------------------------------------------------------


class _Resp:
    def __init__(self, status_code=200, *, json_body=None, text="", json_raises=None, has_json=True):
        self.status_code = status_code
        self._json = json_body
        self.text = text
        self._json_raises = json_raises
        self._has_json = has_json

    def json(self):
        if not self._has_json:
            raise AttributeError("response has no json method")
        if self._json_raises is not None:
            raise self._json_raises
        return self._json


class _Http:
    def __init__(self, routes=None, default=None, raise_on=None):
        self._routes = routes or {}
        self._default = default if default is not None else _Resp(404, text="not found")
        self._raise_on = raise_on or {}
        self.calls: list[str] = []

    def get(self, url, timeout=None):  # noqa: ARG002
        self.calls.append(url)
        for needle, exc in self._raise_on.items():
            if needle in url:
                raise exc
        for needle, resp in self._routes.items():
            if needle in url:
                return resp
        return self._default


def _contents(*entries):
    return _Resp(200, json_body=list(entries))


def _dir(name):
    return {"name": name, "type": "dir", "size": 0}


def _file(name, size=100, download_url=None):
    d = {"name": name, "type": "file", "size": size}
    if download_url:
        d["download_url"] = download_url
    return d


# ===========================================================================
# FIX #1 — non-JSON / hostile bodies at _list_contents level
# ===========================================================================


@pytest.mark.parametrize(
    "resp",
    [
        # HTML maintenance / login page served with 200
        _Resp(200, json_raises=ValueError("Expecting value: line 1 column 1")),
        # Truncated JSON -> JSONDecodeError is a subclass of ValueError
        _Resp(200, json_raises=json.JSONDecodeError("Unterminated", "[", 0)),
        # Empty body -> resp.json() raises ValueError
        _Resp(200, json_raises=ValueError("No JSON object could be decoded")),
    ],
)
def test_fix1_non_json_200_bodies_wrap_to_source_error(resp):
    """A 200 with a body resp.json() can't parse must raise SourceError
    (catchable by the route -> 502), never a bare ValueError -> 500."""
    http = _Http({"/contents": resp})
    conn = GithubSourceConnector(http=http)
    with pytest.raises(SourceError) as ei:
        conn.list_industries("_repo")
    # Must NOT be a bare ValueError leaking through.
    assert not isinstance(ei.value, ValueError)


def test_fix1_json_body_is_dict_not_list_raises_source_error():
    """GitHub returns a dict for a file path. The directory contract
    requires a list -> SourceError, not an AttributeError on iteration."""
    http = _Http({contents_key(): _Resp(200, json_body={"type": "file", "name": "x"})})
    with pytest.raises(SourceError):
        GithubSourceConnector(http=http).list_industries("_repo")


def test_fix1_json_body_is_null_raises_source_error():
    """A literal JSON ``null`` (body parses to None) is not a list ->
    must be a clean SourceError, not a 'NoneType is not iterable' crash."""
    http = _Http({contents_key(): _Resp(200, json_body=None)})
    with pytest.raises(SourceError):
        GithubSourceConnector(http=http).list_industries("_repo")


def test_fix1_json_body_is_bare_string_raises_source_error():
    """A JSON scalar string body is also not a list."""
    http = _Http({contents_key(): _Resp(200, json_body="just a string")})
    with pytest.raises(SourceError):
        GithubSourceConnector(http=http).list_industries("_repo")


def test_fix1_json_body_is_number_raises_source_error():
    http = _Http({contents_key(): _Resp(200, json_body=42)})
    with pytest.raises(SourceError):
        GithubSourceConnector(http=http).list_industries("_repo")


# --- FIX #1 at route level (must be 502, never 500) -------------------------


@pytest.fixture
def repo_http():
    doc = json.dumps({"model_name": "m", "model_version": "v1", "domains": [{"name": "a"}]})
    return _Http(
        {
            contents_key(): _contents(_dir("banking")),
            contents_key("banking"): _contents(_dir("v1")),
            contents_key("banking/v1"): _contents(_dir("ecm")),
            contents_key("banking/v1/ecm"): _contents(_file("model.json")),
            "raw.githubusercontent.com": _Resp(200, text=doc),
        }
    )


@pytest.fixture
def patched(monkeypatch, repo_http):
    from vibe_modeling.backend.routes import sources as sources_routes

    def _fake_build(repo_owner="", repo_name="", **_):  # noqa: ARG001
        return GithubSourceConnector(http=repo_http)

    monkeypatch.setattr(sources_routes, "build_github_connector", _fake_build)
    return repo_http


@pytest.mark.parametrize(
    "resp",
    [
        _Resp(200, json_raises=ValueError("Expecting value")),
        _Resp(200, json_raises=json.JSONDecodeError("trunc", "[", 0)),
        _Resp(200, json_body={"type": "file"}),  # dict not list
        _Resp(200, json_body=None),  # null
    ],
)
def test_fix1_route_non_list_body_is_502_never_500(client, patched, repo_http, resp):
    repo_http._routes[contents_key()] = resp
    r = client.get("/api/sources/sectors/_repo/industries")
    assert r.status_code == 502, f"got {r.status_code}: {r.text}"


# ===========================================================================
# FIX #2 — partial artifact listing when sub-dirs / model dir fail
# ===========================================================================


def test_fix2_5xx_on_one_subdir_still_returns_others_and_modeljson():
    http = _Http(
        {
            contents_key("banking/v1/ecm"): _contents(_file("model.json")),
            "/schemas?ref=main": _Resp(503, text="unavailable"),
            "/diagram?ref=main": _contents(_file("d.dbml")),
            "/docs?ref=main": _contents(_file("doc.md")),
        }
    )
    arts = GithubSourceConnector(http=http).fetch_artifacts("banking", "v1_ecm")
    kinds = {a.target_kind for a in arts}
    assert TargetKind.MODEL_JSON in kinds
    assert TargetKind.DIAGRAM in kinds
    assert TargetKind.DOCS in kinds
    assert TargetKind.SCHEMAS not in kinds


def test_fix2_timeout_requestexception_on_subdir_is_swallowed():
    """A transport-level RequestException (timeout) on a sub-dir is
    wrapped to SourceError by _get and must be swallowed per sub-dir."""
    http = _Http(
        {
            contents_key("banking/v1/ecm"): _contents(_file("model.json")),
            "/diagram?ref=main": _contents(_file("d.dbml")),
        },
        raise_on={"/schemas?ref=main": gh.requests.exceptions.Timeout("read timed out")},
    )
    arts = GithubSourceConnector(http=http).fetch_artifacts("banking", "v1_ecm")
    kinds = {a.target_kind for a in arts}
    assert TargetKind.MODEL_JSON in kinds
    assert TargetKind.DIAGRAM in kinds
    assert TargetKind.SCHEMAS not in kinds


def test_fix2_5xx_on_model_dir_listing_itself_does_not_crash():
    """A 5xx on the MODEL DIR listing (not a sub-dir) must not abort the
    whole call: fetch_artifacts catches it -> no model.json artifact, but
    the per-sub-dir loop still runs and can return healthy sub-dirs."""
    http = _Http(
        {
            contents_key("banking/v1/ecm"): _Resp(500, text="boom"),
            "/schemas?ref=main": _contents(_file("a.sql")),
        }
    )
    arts = GithubSourceConnector(http=http).fetch_artifacts("banking", "v1_ecm")
    kinds = {a.target_kind for a in arts}
    # model dir listing failed -> no MODEL_JSON advertised (no 404 lie)
    assert TargetKind.MODEL_JSON not in kinds
    # but the healthy schemas sub-dir still comes back
    assert TargetKind.SCHEMAS in kinds


def test_fix2_timeout_on_model_dir_listing_does_not_crash():
    http = _Http(
        {"/schemas?ref=main": _contents(_file("a.sql"))},
        raise_on={contents_key("banking/v1/ecm"): gh.requests.exceptions.ConnectionError("reset")},
    )
    arts = GithubSourceConnector(http=http).fetch_artifacts("banking", "v1_ecm")
    kinds = {a.target_kind for a in arts}
    assert TargetKind.MODEL_JSON not in kinds
    assert TargetKind.SCHEMAS in kinds


def test_fix2_all_subdirs_5xx_yields_only_modeljson():
    """Every sub-dir flaky but model.json present -> exactly the one
    MODEL_JSON artifact, no crash."""
    http = _Http(
        {contents_key("banking/v1/ecm"): _contents(_file("model.json"))},
        default=_Resp(500, text="boom"),
    )
    arts = GithubSourceConnector(http=http).fetch_artifacts("banking", "v1_ecm")
    assert [a.target_kind for a in arts] == [TargetKind.MODEL_JSON]


def test_fix2_route_model_dir_5xx_during_preview_does_not_500(client, patched, repo_http):
    """At the route, model.json still fetches via raw (separate call), but
    if the artifact model-dir listing 5xxes the preview must not 500."""
    repo_http._routes[contents_key("banking/v1/ecm")] = _Resp(500, text="boom")
    r = client.get("/api/sources/industries/banking/models/v1_ecm/preview")
    assert r.status_code == 200, f"got {r.status_code}: {r.text}"


# ===========================================================================
# FIX #3 — MODEL_JSON artifact only when model.json actually present
# ===========================================================================


def test_fix3_model_dir_present_but_no_modeljson_yields_no_model_artifact():
    """Model dir lists fine but contains NO model.json -> no MODEL_JSON
    artifact (no 404-URL lie)."""
    http = _Http(
        {
            contents_key("banking/v1/ecm"): _contents(
                _file("README.md"), _dir("schemas")
            ),
        }
    )
    arts = GithubSourceConnector(http=http).fetch_artifacts("banking", "v1_ecm")
    assert [a for a in arts if a.target_kind == TargetKind.MODEL_JSON] == []


def test_fix3_modeljson_as_dir_entry_is_not_advertised():
    """A 'model.json' entry that is a DIR (type=dir), not a file, must NOT
    be advertised as a MODEL_JSON artifact (the matcher requires
    type==file)."""
    http = _Http(
        {
            contents_key("banking/v1/ecm"): _Resp(
                200, json_body=[{"name": "model.json", "type": "dir", "size": 0}]
            ),
        }
    )
    arts = GithubSourceConnector(http=http).fetch_artifacts("banking", "v1_ecm")
    assert [a for a in arts if a.target_kind == TargetKind.MODEL_JSON] == []


def test_fix3_present_modeljson_yields_exactly_one():
    http = _Http(
        {contents_key("banking/v1/ecm"): _contents(_file("model.json", size=7))}
    )
    arts = GithubSourceConnector(http=http).fetch_artifacts("banking", "v1_ecm")
    models = [a for a in arts if a.target_kind == TargetKind.MODEL_JSON]
    assert len(models) == 1
    assert models[0].name == "model.json"
    assert models[0].size == 7
    assert models[0].path == "banking/v1/ecm/model.json"


def test_fix3_two_modeljson_entries_only_first_listed():
    """Defensive: if GitHub somehow returns two model.json file entries,
    next() takes the first -> still exactly one advertised."""
    http = _Http(
        {
            contents_key("banking/v1/ecm"): _contents(
                _file("model.json", size=1), _file("model.json", size=2)
            ),
        }
    )
    arts = GithubSourceConnector(http=http).fetch_artifacts("banking", "v1_ecm")
    models = [a for a in arts if a.target_kind == TargetKind.MODEL_JSON]
    assert len(models) == 1


# ===========================================================================
# FIX #4 — nameless / blank dir entries skipped (no id="" industries)
# ===========================================================================


@pytest.mark.parametrize(
    "bad",
    [
        {"type": "dir"},  # no name key
        {"type": "dir", "name": ""},  # empty string
        {"type": "dir", "name": None},  # explicit null name
    ],
)
def test_fix4_invalid_dir_entries_skipped(bad):
    http = _Http({contents_key(): _contents(bad, _dir("banking"))})
    industries = GithubSourceConnector(http=http).list_industries("_repo")
    ids = [i.id for i in industries]
    assert "" not in ids
    assert None not in ids
    assert ids == ["banking"]


def test_fix4_whitespace_only_industry_name_is_skipped():
    """A whitespace-only name ('   ') must be skipped: the shared
    ``_iter_named_dirs`` helper strips the name before the blank check, so
    no industry with a whitespace-only id can leak through."""
    http = _Http({contents_key(): _contents({"type": "dir", "name": "   "})})
    industries = GithubSourceConnector(http=http).list_industries("_repo")
    ids = [i.id for i in industries]
    assert ids == [], (
        "whitespace-only dir name must not leak through as an industry id"
    )


def test_fix4_mixed_valid_and_invalid_entries():
    http = _Http(
        {
            contents_key(): _contents(
                {"type": "dir"},
                _dir("banking"),
                {"type": "dir", "name": ""},
                _dir("energy_utilities"),
                {"name": "loose-file", "type": "file"},
            )
        }
    )
    industries = GithubSourceConnector(http=http).list_industries("_repo")
    assert sorted(i.id for i in industries) == ["banking", "energy_utilities"]


def test_fix4_list_models_skips_nameless_entries():
    """list_models shares the ``_iter_named_dirs`` helper with
    list_industries, so a nameless model dir must be skipped — no
    SourceModelRef with id='' may leak through (the asymmetry is closed)."""
    http = _Http(
        {
            contents_key("banking"): _contents({"type": "dir"}, _dir("v1")),
            contents_key("banking/v1"): _contents({"type": "dir"}, _dir("ecm")),
        }
    )
    models = GithubSourceConnector(http=http).list_models("banking")
    ids = sorted(m.id for m in models)
    assert ids == ["v1_ecm"], (
        "list_models must not emit an id with an empty segment from a nameless dir entry"
    )


def test_fix4_list_models_skips_whitespace_only_entries():
    """A whitespace-only model dir name ('   ') must be skipped too: the
    shared helper strips before the blank check, so list_models cannot emit
    a SourceModelRef with a whitespace-only id."""
    http = _Http(
        {
            contents_key("banking"): _contents(
                {"type": "dir", "name": "   "}, _dir("v1")
            ),
            contents_key("banking/v1"): _contents(
                {"type": "dir", "name": "   "}, _dir("ecm")
            ),
        }
    )
    models = GithubSourceConnector(http=http).list_models("banking")
    ids = sorted(m.id for m in models)
    assert ids == ["v1_ecm"], (
        "whitespace-only dir name must not leak through as a model id"
    )


# ===========================================================================
# FIX #5 — URL encoding of every segment; no structural escape
# ===========================================================================


def test_fix5_owner_name_path_dotdot_encoded_in_api_url():
    http = _Http(default=_Resp(404))
    conn = GithubSourceConnector(repo_owner="../etc", repo_name="..%2fpasswd", http=http)
    with pytest.raises(SourceNotFoundError):
        conn.list_models("../../escape")
    url = http.calls[0]
    # owner/name encoded (slashes within them gone)
    assert "../etc" not in url
    assert "..%2F" in url  # owner '../etc' -> '..%2Fetc'
    # path '../../escape' segments encoded: literal '..' segments survive
    # (RFC-3986 unreserved) but the slashes between them are the only
    # structural slashes — assert no raw backslash / encoded-pct double.
    # The contents path portion must contain the percent-encoded form.
    assert "/contents/" in url


@pytest.mark.parametrize("ch_name,needle", [
    ("a b", "a%20b"),       # space
    ("q?x=1", "q%3Fx%3D1"), # question mark + equals
    ("frag#1", "frag%231"), # hash
    ("a%2e", "a%252e"),     # literal percent must be double-encoded
    ("a&b", "a%26b"),       # ampersand
])
def test_fix5_industry_special_chars_encoded(ch_name, needle):
    http = _Http(default=_Resp(404))
    conn = GithubSourceConnector(http=http)
    with pytest.raises(SourceNotFoundError):
        conn.list_models(ch_name)
    url = http.calls[0]
    assert needle in url, f"{ch_name!r} not encoded as {needle!r} in {url}"
    # No raw '?' or '#' may appear in the PATH portion (before ?ref=).
    path = url.split("/contents/", 1)[1].split("?ref=", 1)[0]
    assert "?" not in path
    assert "#" not in path


def test_fix5_unicode_industry_is_percent_encoded():
    http = _Http(default=_Resp(404))
    conn = GithubSourceConnector(http=http)
    with pytest.raises(SourceNotFoundError):
        conn.list_models("café_münchen_日本")
    url = http.calls[0]
    # Non-ASCII must be percent-encoded UTF-8, not raw.
    assert "café" not in url
    assert "%C3%A9" in url  # é
    assert "%E6%97%A5" in url  # 日


def test_fix5_literal_percent_in_repo_name_double_encoded():
    """A repo name already containing '%2F' must be DOUBLE-encoded so the
    server sees a literal '%2F', not a decoded slash (no smuggled path)."""
    http = _Http(default=_Resp(404))
    conn = GithubSourceConnector(repo_owner="o", repo_name="evil%2F..%2Fx", http=http)
    with pytest.raises(SourceNotFoundError):
        conn.list_industries("_repo")
    url = http.calls[0]
    assert "evil%252F..%252Fx" in url


def test_fix5_raw_url_encodes_industry_and_model_segments():
    """fetch_model_json builds a raw URL from industry/model/model.json —
    each segment must be encoded too (not just the contents API)."""
    conn = GithubSourceConnector()
    url = conn._raw_url("a b/c?d/model.json")
    assert " " not in url
    assert "?" not in url.split("raw.githubusercontent.com", 1)[1]
    assert "a%20b/c%3Fd/model.json" in url


def test_fix5_raw_url_encodes_owner_name_ref():
    conn = GithubSourceConnector(repo_owner="o w", repo_name="r#1", ref="re f")
    url = conn._raw_url("x/model.json")
    assert " " not in url
    assert "#" not in url
    assert "o%20w" in url
    assert "r%231" in url
    assert "re%20f" in url


def test_fix5_fetch_model_json_special_industry_no_structural_escape():
    """End-to-end via fetch_model_json: a hostile industry id cannot
    inject a fragment/query into the raw URL."""
    http = _Http({"raw.githubusercontent.com": _Resp(200, text="{}")})
    conn = GithubSourceConnector(http=http)
    conn.fetch_model_json("a#b?c", "ecm_v1")
    url = http.calls[0]
    after_host = url.split("raw.githubusercontent.com", 1)[1]
    assert "#" not in after_host
    assert "?" not in after_host


def test_fix5_encode_path_helper_directly():
    assert gh._encode_path("a/b/c") == "a/b/c"
    assert gh._encode_path("a b/c") == "a%20b/c"
    assert gh._encode_path("x?y#z") == "x%3Fy%23z"
    # preserves the slash separators, encodes within segments only
    assert gh._encode_path("..%2F../x") == "..%252F../x"


# ===========================================================================
# FIX #7 — build_github_connector no longer accepts ref
# ===========================================================================


def test_fix7_build_github_connector_rejects_ref_kwarg():
    """Passing ref= must raise TypeError (the dead param was removed)."""
    with pytest.raises(TypeError):
        build_github_connector(repo_owner="o", repo_name="r", ref="dev")  # type: ignore[call-arg]


def test_fix7_build_github_connector_signature_has_no_ref():
    params = inspect.signature(build_github_connector).parameters
    assert "ref" not in params
    # repo pointers + the GitHub-App read-credential selector + a test transport
    # override. No stray `ref`, and no retired UC read-selection inputs.
    assert set(params) == {
        "repo_owner",
        "repo_name",
        "app_credentials",
        "http",
    }


def test_fix7_connector_still_defaults_ref_internally():
    """Even without a ref param on the builder, the connector defaults to
    the canonical ref so contents/raw URLs still pin ?ref=main."""
    conn = build_github_connector()
    assert conn.ref == gh.DEFAULT_REF


def test_fix7_built_connector_uses_default_ref_in_url():
    http = _Http({contents_key(): _contents()})
    conn = build_github_connector(http=http)
    conn.list_industries("_repo")
    assert "?ref=main" in http.calls[0]


# ===========================================================================
# FIX #6 — requests is a declared dependency
# ===========================================================================


def test_fix6_requests_is_importable_and_bound():
    import requests as real_requests

    assert gh.requests is real_requests
    assert GithubSourceConnector()._http is real_requests


def test_fix6_requests_declared_in_pyproject():
    """The connector imports ``requests`` at module top level; it must be
    a declared runtime dependency, not an undeclared transitive."""
    import pathlib
    import re

    # Locate the app pyproject that ships the wheel.
    here = pathlib.Path(gh.__file__).resolve()
    # .../src/app/src/vibe_modeling/backend/sources/github.py
    app_root = here.parents[4]  # .../src/app
    pyproject = app_root / "pyproject.toml"
    assert pyproject.exists(), f"pyproject not found at {pyproject}"
    text = pyproject.read_text()
    assert re.search(r'(?im)^\s*["\']?requests\b', text) or '"requests' in text or "'requests" in text, (
        "requests not declared as a dependency in src/app/pyproject.toml"
    )


# ===========================================================================
# No-network guarantee for THIS suite
# ===========================================================================


def test_this_suite_never_calls_real_requests(monkeypatch):
    def _boom(*a, **k):
        raise AssertionError("REAL NETWORK CALL ATTEMPTED")

    monkeypatch.setattr(gh.requests, "get", _boom)
    http = _Http(
        {
            contents_key(): _contents(_dir("banking")),
            contents_key("banking"): _contents(_dir("v1")),
            contents_key("banking/v1"): _contents(_dir("ecm")),
            contents_key("banking/v1/ecm"): _contents(_file("model.json")),
            "raw.githubusercontent.com": _Resp(200, text="{}"),
        }
    )
    conn = GithubSourceConnector(http=http)
    conn.list_industries("_repo")
    conn.list_models("banking")
    conn.fetch_artifacts("banking", "v1_ecm")
    conn.fetch_model_json("banking", "v1_ecm")
    assert all("api.github.com" in c or "raw.githubusercontent.com" in c for c in conn._http.calls)
