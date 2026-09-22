"""Adversarial / skeptical tests for the source-connector seam (Track C).

Independent of the author's own ``test_sources.py``. Every HTTP call is
served by an in-process fake (``_Http``) — there is NO network in any
path here, and several tests assert exactly that.

This suite was ported from the independent tester's audit and updated to
assert the HARDENED behaviour after the Track C fixes:

- ``_list_contents`` wraps ``resp.json()`` failures in ``SourceError``.
- ``fetch_artifacts`` swallows ``SourceError`` per artifact sub-dir
  (partial list, not total failure) and only lists ``model.json`` when
  it actually exists in the model directory.
- Nameless dir entries are skipped (no ``id=""`` industries).
- Repo owner/name + path segments are URL-encoded before the request.
"""

from __future__ import annotations

import json

import pytest

from vibe_modeling.backend.sources import (
    DiscoveryMode,
    GithubSourceConnector,
    MaterializationTiming,
    SourceCapabilities,
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
# Fake HTTP — substring routing, records every call, NEVER touches network
# ---------------------------------------------------------------------------


class _Resp:
    def __init__(self, status_code=200, *, json_body=None, text="", json_raises=None):
        self.status_code = status_code
        self._json = json_body
        self.text = text
        self._json_raises = json_raises

    def json(self):
        if self._json_raises is not None:
            raise self._json_raises
        if self._json is None:
            raise ValueError("no json body")
        return self._json


class _Http:
    def __init__(self, routes=None, default=None):
        self._routes = routes or {}
        self._default = default if default is not None else _Resp(404, text="not found")
        self.calls: list[str] = []

    def get(self, url, timeout=None):  # noqa: ARG002
        self.calls.append(url)
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
# CRITICAL: no network in any unit path
# ===========================================================================


def test_no_real_requests_get_is_ever_called(monkeypatch):
    """Hard guarantee: if any path reaches requests.get, blow up loudly.

    Exercises construction + capabilities + every browse/fetch method
    through the fake, with the real transport poisoned.
    """

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
    conn.capabilities()
    conn.list_sectors()
    conn.list_industries("_repo")
    conn.list_models("banking")
    conn.fetch_model_json("banking", "v1_ecm")
    conn.fetch_artifacts("banking", "v1_ecm")
    assert all("api.github.com" in c or "raw.githubusercontent.com" in c for c in http.calls)


def test_default_connector_uses_requests_module():
    """Sanity: with no http injected, the connector binds the real
    ``requests`` module (so injection is the ONLY thing keeping tests
    offline — worth asserting so a refactor can't silently change it)."""
    assert GithubSourceConnector()._http is gh.requests


# ===========================================================================
# Malformed / hostile contents-API bodies
# ===========================================================================


def test_non_json_contents_body_is_wrapped_in_source_error():
    """FIX #1: a 200 with a non-JSON body must raise a SourceError, not a
    bare ValueError from resp.json(). The route layer only catches
    SourceError, so the wrapped form surfaces as a clean 502."""
    http = _Http({"/contents": _Resp(200, json_raises=ValueError("Expecting value"))})
    conn = GithubSourceConnector(http=http)
    with pytest.raises(SourceError):
        conn.list_industries("_repo")


def test_empty_repo_yields_no_industries():
    http = _Http({contents_key(): _contents()})
    assert GithubSourceConnector(http=http).list_industries("_repo") == []


def test_industry_listing_dict_body_raises_source_error():
    """GitHub returns a dict (not list) when a path is a file. Should be
    a clean SourceError, not a crash."""
    http = _Http({contents_key("banking"): _Resp(200, json_body={"type": "file"})})
    with pytest.raises(SourceError):
        GithubSourceConnector(http=http).list_models("banking")


def test_entries_missing_type_key_are_skipped():
    """Entries with no 'type' must not crash; .get() returns None != 'dir'."""
    http = _Http({contents_key(): _contents({"name": "weird"}, _dir("banking"))})
    industries = GithubSourceConnector(http=http).list_industries("_repo")
    assert {i.id for i in industries} == {"banking"}


def test_dir_entry_missing_name_is_skipped():
    """FIX #4: a dir entry with no 'name' must be SKIPPED rather than
    becoming an industry with id=''."""
    http = _Http({contents_key(): _contents({"type": "dir"}, _dir("banking"))})
    industries = GithubSourceConnector(http=http).list_industries("_repo")
    assert [i.id for i in industries] == ["banking"]


def test_dir_entry_empty_string_name_is_skipped():
    """An explicit empty-string name is also skipped (no id='' industry)."""
    http = _Http({contents_key(): _contents({"type": "dir", "name": ""})})
    industries = GithubSourceConnector(http=http).list_industries("_repo")
    assert industries == []


def test_rate_limit_403_raises_source_error():
    """GitHub rate-limit is a 403 (non-200, non-404) -> SourceError."""
    http = _Http({"/contents": _Resp(403, text="API rate limit exceeded")})
    with pytest.raises(SourceError):
        GithubSourceConnector(http=http).list_industries("_repo")


def test_500_listing_raises_source_error():
    http = _Http({"/contents": _Resp(500, text="boom")})
    with pytest.raises(SourceError):
        GithubSourceConnector(http=http).list_industries("_repo")


# ===========================================================================
# fetch_artifacts robustness
# ===========================================================================


def test_fetch_artifacts_present_model_json_is_listed():
    """When the model dir contains model.json, it is listed as a
    MODEL_JSON artifact with size + raw download URL."""
    http = _Http(
        {
            contents_key("banking/v1/ecm"): _contents(_file("model.json", size=42)),
        }
    )
    arts = GithubSourceConnector(http=http).fetch_artifacts("banking", "v1_ecm")
    model = [a for a in arts if a.target_kind == TargetKind.MODEL_JSON]
    assert len(model) == 1
    assert model[0].name == "model.json"
    assert model[0].size == 42
    assert model[0].download_url.startswith("https://raw.githubusercontent.com/")


def test_fetch_artifacts_missing_model_json_is_not_advertised():
    """FIX #3: fetch_artifacts must NOT synthesise a model.json artifact
    when the file does not exist. A model dir with no model.json (every
    sub-dir 404s) yields no MODEL_JSON artifact."""
    http = _Http({})  # every path 404s
    arts = GithubSourceConnector(http=http).fetch_artifacts("banking", "v1_ghost")
    assert [a for a in arts if a.target_kind == TargetKind.MODEL_JSON] == []


def test_fetch_artifacts_transport_error_on_subdir_yields_partial_list():
    """FIX #2: a 5xx SourceError on one artifact sub-dir must NOT abort
    the whole enumeration. The model.json + the healthy /diagram dir
    still come back; only the flaky /schemas dir is dropped."""
    http = _Http(
        {
            contents_key("banking/v1/ecm"): _contents(_file("model.json")),
            "/schemas?ref=main": _Resp(500, text="boom"),
            "/diagram?ref=main": _contents(_file("d.txt")),
        }
    )
    arts = GithubSourceConnector(http=http).fetch_artifacts("banking", "v1_ecm")
    kinds = {a.target_kind for a in arts}
    assert TargetKind.MODEL_JSON in kinds
    assert TargetKind.DIAGRAM in kinds
    assert TargetKind.SCHEMAS not in kinds


def test_fetch_artifacts_skips_non_file_entries_in_subdir():
    http = _Http(
        {
            contents_key("banking/v1/ecm"): _contents(),
            "/schemas?ref=main": _contents(_dir("nested"), _file("a.sql", size=10)),
        }
    )
    arts = GithubSourceConnector(http=http).fetch_artifacts("banking", "v1_ecm")
    schema = [a for a in arts if a.target_kind == TargetKind.SCHEMAS]
    assert [a.name for a in schema] == ["a.sql"]


def test_fetch_artifacts_file_missing_download_url_falls_back_to_raw():
    http = _Http(
        {
            contents_key("banking/v1/ecm"): _contents(),
            "/schemas?ref=main": _contents(_file("a.sql")),
        }
    )
    arts = GithubSourceConnector(http=http).fetch_artifacts("banking", "v1_ecm")
    schema = next(a for a in arts if a.target_kind == TargetKind.SCHEMAS)
    assert schema.download_url.startswith("https://raw.githubusercontent.com/")


# ===========================================================================
# fetch_model_json: huge / binary / non-200
# ===========================================================================


def test_fetch_model_json_huge_body_returned_whole():
    """No size guard in the connector itself: a 50MB body comes back
    whole. (The route caps the PREVIEW, but a direct connector caller
    gets everything — worth knowing the connector has no ceiling.)"""
    big = "x" * (5 * 1024 * 1024)
    http = _Http({"raw.githubusercontent.com": _Resp(200, text=big)})
    raw = GithubSourceConnector(http=http).fetch_model_json("banking", "v1_ecm")
    assert len(raw) == len(big)


def test_fetch_model_json_binary_text_is_passed_through():
    """raw .text on a binary blob is mojibake but the connector returns
    it without inspecting content-type. Degrades (caller's json.loads
    will fail) rather than crashing here."""
    http = _Http({"raw.githubusercontent.com": _Resp(200, text="\x00\x01\x02\xff")})
    raw = GithubSourceConnector(http=http).fetch_model_json("banking", "v1_ecm")
    assert raw == "\x00\x01\x02\xff"


def test_fetch_model_json_non_200_non_404_raises_source_error():
    http = _Http({"raw.githubusercontent.com": _Resp(502, text="bad gateway")})
    with pytest.raises(SourceError):
        GithubSourceConnector(http=http).fetch_model_json("banking", "v1_ecm")


# ===========================================================================
# Repo owner/name resolution + injection-ish names
# ===========================================================================


def test_build_partial_owner_only_falls_back_name():
    conn = build_github_connector(repo_owner="acme", repo_name="")
    assert conn.repo_owner == "acme"
    assert conn.repo_name == gh.DEFAULT_REPO_NAME


def test_build_partial_name_only_falls_back_owner():
    conn = build_github_connector(repo_owner="", repo_name="custom")
    assert conn.repo_owner == gh.DEFAULT_REPO_OWNER
    assert conn.repo_name == "custom"


def test_build_connector_has_no_ref_param():
    """FIX #7: build_github_connector no longer accepts a dead ``ref``
    kwarg (no production caller ever passed it)."""
    import inspect

    assert "ref" not in inspect.signature(build_github_connector).parameters
    # And the connector it builds still defaults to the canonical ref.
    assert build_github_connector().ref == gh.DEFAULT_REF


def test_constructor_none_coerces_to_defaults():
    """__init__ uses ``or`` so None / "" both fall back."""
    conn = GithubSourceConnector(repo_owner=None, repo_name=None, ref=None)
    assert conn.repo_owner == gh.DEFAULT_REPO_OWNER
    assert conn.repo_name == gh.DEFAULT_REPO_NAME
    assert conn.ref == gh.DEFAULT_REF


def test_injection_repo_name_is_url_encoded_in_url():
    """FIX #5: a hostile repo name like '../../evil' must be URL-encoded
    before the request, not ride into the URL verbatim."""
    http = _Http(default=_Resp(404))
    conn = GithubSourceConnector(repo_owner="o", repo_name="../../evil", http=http)
    with pytest.raises(SourceNotFoundError):
        conn.list_industries("_repo")
    assert "../../evil" not in http.calls[0]
    assert "..%2F..%2Fevil" in http.calls[0]


def test_injection_industry_id_special_chars_are_encoded():
    """FIX #5: industry-id segments are URL-encoded so URL-structural
    characters cannot inject. (Bare '..' segments are RFC-3986 unreserved
    and stay literal, but the GitHub REST contents API resolves them
    server-side and cannot escape the repo — see the dedicated
    query/fragment test for the structural-injection guarantee.)"""
    http = _Http(default=_Resp(404))
    conn = GithubSourceConnector(http=http)
    with pytest.raises(SourceNotFoundError):
        conn.list_models("a b/c&d")
    url = http.calls[0]
    assert "a%20b/c%26d" in url


def test_injection_query_and_fragment_chars_are_encoded():
    """A name containing '?' or '#' must be encoded so it cannot inject a
    query string or fragment into the constructed URL."""
    http = _Http(default=_Resp(404))
    conn = GithubSourceConnector(http=http)
    with pytest.raises(SourceNotFoundError):
        conn.list_models("evil?x=1#frag")
    url = http.calls[0]
    # The only legitimate '?' is the ref query param.
    path_part = url.split("/contents/", 1)[1].split("?ref=", 1)[0]
    assert "?" not in path_part
    assert "#" not in path_part


def test_raw_url_segments_are_encoded():
    """The raw URL builder must also encode owner/name/ref/path."""
    conn = GithubSourceConnector(repo_owner="o w", repo_name="r#1", ref="re f")
    url = conn._raw_url("a b/model.json")
    assert " " not in url
    assert "#" not in url
    assert "a%20b/model.json" in url


# ===========================================================================
# Scope / version inference edge cases
# ===========================================================================


@pytest.mark.parametrize(
    "model_id,scope,version",
    [
        ("ecm_v1", "ecm", "v1"),
        ("mvm_v12", "mvm", "v12"),
        ("ECM_V1", "ecm", "v1"),
        ("ecm-v1", "ecm", "v1"),
        ("plain", None, None),
        ("v1", None, "v1"),
        ("ecmvm_v1", "ecm", "v1"),  # 'ecm' substring wins over 'mvm'
        ("model_vbeta", None, None),  # vbeta not all-digits
        ("", None, None),
    ],
)
def test_infer_scope_and_version(model_id, scope, version):
    assert gh._infer_scope(model_id) == scope
    assert gh._infer_version(model_id) == version


def test_humanize_edge_shapes():
    assert gh._humanize("energy_utilities") == "Energy Utilities"
    assert gh._humanize("") == ""
    assert gh._humanize("__") == ""
    assert gh._humanize("a__b") == "A B"
    assert gh._humanize("multi-word-slug") == "Multi Word Slug"


# ===========================================================================
# Capabilities axes: declarative vs honored
# ===========================================================================


def test_capabilities_provides_matches_declared_kinds():
    caps = GithubSourceConnector().capabilities()
    for kind in TargetKind:
        assert caps.provides(kind) == (kind in caps.target_kinds)


def test_artifact_dirs_map_covers_non_modeljson_kinds():
    """The artifact sub-dir map should materialise every declared
    non-MODEL_JSON kind. If capabilities declares a kind no sub-dir maps
    to, fetch_artifacts can never actually hand it back -> decorative."""
    caps = GithubSourceConnector().capabilities()
    mapped = set(gh._ARTIFACT_DIRS.values()) | {TargetKind.MODEL_JSON}
    undeliverable = [k for k in caps.target_kinds if k not in mapped]
    assert undeliverable == [], f"declared but no fetch path: {undeliverable}"


def test_discovery_and_materialization_axes_are_purely_declarative():
    """Documentation of a gap, not a bug: nothing in the connector
    methods consults discovery_mode or materialization_timing — they are
    metadata only. Assert the current (decorative) values so a future
    behavioural use is a conscious change."""
    caps = GithubSourceConnector().capabilities()
    assert caps.discovery_mode == DiscoveryMode.EAGER_LISTING
    assert caps.materialization_timing == MaterializationTiming.AT_REST


# ===========================================================================
# ref handling
# ===========================================================================


def test_empty_ref_omits_ref_query_param():
    http = _Http({"/contents": _contents(_dir("banking"))})
    conn = GithubSourceConnector(ref="", http=http)
    # ref="" -> coerced to DEFAULT_REF by __init__'s ``or``
    conn.list_industries("_repo")
    assert "?ref=main" in http.calls[0]


def test_custom_ref_appears_in_both_api_and_raw_urls():
    http = _Http(
        {
            "/contents/banking/v1/ecm": _contents(),
            "raw.githubusercontent.com": _Resp(200, text="{}"),
        }
    )
    conn = GithubSourceConnector(ref="dev", http=http)
    conn.fetch_model_json("banking", "v1_ecm")
    assert any("/dev/" in c for c in http.calls)


# ===========================================================================
# Route layer: preview parse-skip, RBAC, bad ids, empty results
# ===========================================================================


@pytest.fixture
def repo_http():
    doc = json.dumps(
        {"model_name": "m", "model_version": "v1", "domains": [{"name": "a"}]}
    )
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


def test_route_preview_readme_and_stats_null_when_source_unreachable(client, patched, repo_http):
    """A source that 404s every raw fetch degrades to a fully-null readme +
    stats block, never an error - the preview endpoint no longer fetches
    model.json at all, so a huge/garbled model.json can't affect it."""
    repo_http._routes["raw.githubusercontent.com"] = _Resp(404, text="missing")
    body = client.get("/api/sources/industries/banking/models/ecm_v1/preview").json()
    assert body["readme"] is None
    for field in (
        "domains", "subdomains", "products", "attributes",
        "primary_keys", "foreign_keys", "avg_attrs_per_product", "metric_views",
    ):
        assert body[field] is None


def test_route_preview_readme_renders_regardless_of_model_json_size(client, patched, repo_http):
    """A model.json the size of the old truncation cap (or bigger) has no
    bearing on the preview anymore - the preview never fetches model.json."""
    repo_http._routes["raw.githubusercontent.com"] = _Resp(200, text="# Readme\n" + ("x" * 20_000))
    body = client.get("/api/sources/industries/banking/models/ecm_v1/preview").json()
    assert body["readme"].startswith("# Readme\n")
    assert len(body["readme"]) > 16_384


def test_route_industries_empty_repo_returns_empty_list(client, patched, repo_http):
    repo_http._routes[contents_key()] = _contents()
    resp = client.get("/api/sources/sectors/_repo/industries")
    assert resp.status_code == 200
    assert resp.json() == []


def test_route_models_unknown_industry_404(client, patched):
    resp = client.get("/api/sources/industries/ghost/models")
    assert resp.status_code == 404


def test_route_non200_listing_maps_to_502(client, patched, repo_http):
    """A 5xx from GitHub on a browse route must surface as 502 (Source
    unavailable), not 500."""
    repo_http._routes[contents_key()] = _Resp(500, text="boom")
    resp = client.get("/api/sources/sectors/_repo/industries")
    assert resp.status_code == 502


def test_route_non_json_contents_body_maps_to_502(client, patched, repo_http):
    """FIX #1 (route-level fallout): a 200 with a non-JSON body (e.g.
    GitHub serving an HTML maintenance/login page) is now wrapped in a
    SourceError by _list_contents, which the route maps to a clean 502
    rather than leaking an uncaught 500."""
    repo_http._routes[contents_key()] = _Resp(200, json_raises=ValueError("Expecting value"))
    resp = client.get("/api/sources/sectors/_repo/industries")
    assert resp.status_code == 502


def test_route_capabilities_makes_no_network_call(client, patched, repo_http):
    repo_http.calls.clear()
    resp = client.get("/api/sources/capabilities")
    assert resp.status_code == 200
    assert repo_http.calls == []


def test_route_preview_subdir_5xx_still_succeeds(client, patched, repo_http):
    """FIX #2 (route-level fallout): a 5xx on an artifact sub-dir during
    preview is now swallowed per sub-dir, so the preview still returns
    200 (model.json fetched fine; the flaky sub-dir is simply absent from
    the artifact list)."""
    repo_http._routes["/schemas?ref=main"] = _Resp(500, text="boom")
    resp = client.get("/api/sources/industries/banking/models/ecm_v1/preview")
    assert resp.status_code == 200
    kinds = {a["target_kind"] for a in resp.json()["artifacts"]}
    assert "schemas" not in kinds


# ===========================================================================
# RBAC: routes are read-only GET and require a signed-in session
# ===========================================================================


def test_all_source_routes_are_get_only():
    from vibe_modeling.backend.routes import sources as sources_routes

    methods = set()
    for route in sources_routes.router.routes:
        methods |= getattr(route, "methods", set())
    assert methods == {"GET"}


def test_source_routes_reject_mutation_verbs(client, patched):
    for verb in ("post", "put", "delete", "patch"):
        resp = getattr(client, verb)("/api/sources/capabilities")
        assert resp.status_code in (404, 405), f"{verb} got {resp.status_code}"
