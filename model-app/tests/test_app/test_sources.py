"""Tests for the source-connector seam (Wave 1, Track C).

Two layers:

- Connector unit tests drive ``GithubSourceConnector`` against a fake
  HTTP session (``_FakeHttp``) — no network.
- Route tests drive ``/api/sources/*`` through the TestClient, injecting
  the same fake HTTP into the connector the route builds (by
  monkeypatching ``build_github_connector`` in ``routes.sources``).
"""

from __future__ import annotations

import json

import pytest

from vibe_modeling.backend.sources import (
    DiscoveryMode,
    GithubSourceConnector,
    MaterializationTiming,
    SourceCapabilities,
    SourceConnector,
    SourceError,
    SourceNotFoundError,
    SourceRateLimitError,
    TargetKind,
    build_github_connector,
)
from vibe_modeling.backend.sources import github as gh


# ---------------------------------------------------------------------------
# Parametric route-key helpers
# ---------------------------------------------------------------------------
#
# Every read the connector makes is scoped under ``gh.DEFAULT_BASE_PATH`` (the
# ``data-models/`` subtree of the repo). The fake-http layer routes by URL
# substring, so the contents-API route keys must carry that same base-path
# prefix. Deriving them from ``gh.DEFAULT_BASE_PATH`` (rather than hardcoding
# the literal) means a future base-path move updates every test in lockstep.


def scoped_path(path: str = "") -> str:
    """Prepend ``gh.DEFAULT_BASE_PATH`` to an industry-relative ``path``,
    mirroring ``GithubSourceConnector._repo_path``. An empty base path leaves
    the path at the repo root (the pre-move layout)."""
    base = gh.DEFAULT_BASE_PATH.strip("/")
    rel = path.strip("/")
    if not base:
        return rel
    return f"{base}/{rel}" if rel else base


def contents_key(path: str = "") -> str:
    """A fake-http substring route key for the contents-API listing of an
    industry-relative ``path``, scoped under ``gh.DEFAULT_BASE_PATH``."""
    seg = scoped_path(path)
    return f"/contents/{seg}?ref=main" if seg else "/contents?ref=main"


# ---------------------------------------------------------------------------
# Fake HTTP layer
# ---------------------------------------------------------------------------


class _FakeResp:
    def __init__(self, status_code: int, *, json_body=None, text: str = "", headers=None):
        self.status_code = status_code
        self._json = json_body
        self.text = text
        self.headers = headers or {}

    def json(self):
        if self._json is None:
            raise ValueError("no json body")
        return self._json


class _FakeHttp:
    """Routes URLs to canned responses. Keys are substring matches."""

    def __init__(self, routes: dict[str, _FakeResp]):
        self._routes = routes
        self.calls: list[str] = []

    def get(self, url: str, timeout=None):  # noqa: ARG002
        self.calls.append(url)
        for needle, resp in self._routes.items():
            if needle in url:
                return resp
        return _FakeResp(404, text="not found")


def _contents(*entries) -> _FakeResp:
    return _FakeResp(200, json_body=list(entries))


def _dir(name: str):
    return {"name": name, "type": "dir", "size": 0}


def _file(name: str, size: int = 100, download_url: str | None = None):
    d = {"name": name, "type": "file", "size": size}
    if download_url:
        d["download_url"] = download_url
    return d


@pytest.fixture
def fake_repo_http() -> _FakeHttp:
    """A small canned 3-level repo: 2 industries; banking/v1 has ecm + mvm scopes."""
    model_doc = json.dumps(
        {
            "model_name": "banking_ecm",
            "model_version": "v1",
            "domains": [{"name": "account"}, {"name": "loan"}, {"name": "risk"}],
        }
    )
    return _FakeHttp(
        {
            # root listing — scoped under gh.DEFAULT_BASE_PATH (the model tree).
            contents_key(): _contents(
                _dir("banking"),
                _dir("ecommerce"),
                {"name": "README.md", "type": "file", "size": 10},
                {"name": ".gitignore", "type": "file", "size": 5},
            ),
            # industry level: version dirs + an industry README (a file).
            contents_key("banking"): _contents(
                _dir("v1"), {"name": "README.md", "type": "file", "size": 10}
            ),
            # version level: scope dirs + a version readme (a file).
            contents_key("banking/v1"): _contents(
                _dir("ecm"), _dir("mvm"), {"name": "readme.md", "type": "file", "size": 1}
            ),
            contents_key("banking/v1/ecm"): _contents(
                _file("model.json", size=12345),
                _dir("schemas"),
                _dir("diagram"),
            ),
            contents_key("banking/v1/mvm"): _contents(
                _file("model.json", size=999),
            ),
            contents_key("banking/v1/ecm/schemas"): _contents(
                _file("banking_account_schema_v1_ecm.sql", size=457107),
                _file("banking_loan_schema_v1_ecm.sql", size=693248),
            ),
            contents_key("banking/v1/ecm/diagram"): _contents(
                _file("banking_dbml_v1_ecm.txt", size=4375675)
            ),
            "raw.githubusercontent.com": _FakeResp(200, text=model_doc),
        }
    )


# ---------------------------------------------------------------------------
# Capabilities
# ---------------------------------------------------------------------------


def test_github_connector_is_a_source_connector():
    assert issubclass(GithubSourceConnector, SourceConnector)


def test_capabilities_declares_axes():
    caps = GithubSourceConnector().capabilities()
    assert isinstance(caps, SourceCapabilities)
    assert caps.source_kind == "github"
    assert caps.discovery_mode == DiscoveryMode.EAGER_LISTING
    assert caps.materialization_timing == MaterializationTiming.AT_REST
    assert caps.provides_sectors is False
    assert caps.read_only is True
    # 0.6.6 always browses anonymously (credentialed transport ships in 0.6.7).
    assert caps.auth_mode == "anonymous"
    # Declares the element kinds it can hand back.
    assert caps.provides(TargetKind.MODEL_JSON)
    assert caps.provides(TargetKind.SCHEMAS)
    assert TargetKind.DIAGRAM in caps.target_kinds


def test_capabilities_is_cheap_no_network():
    http = _FakeHttp({})
    GithubSourceConnector(http=http).capabilities()
    assert http.calls == []


# ---------------------------------------------------------------------------
# Browse
# ---------------------------------------------------------------------------


def test_list_sectors_returns_one_synthetic_sector():
    sectors = GithubSourceConnector(http=_FakeHttp({})).list_sectors()
    assert len(sectors) == 1
    assert sectors[0].synthetic is True


def test_list_industries_filters_non_industry_root(fake_repo_http):
    conn = GithubSourceConnector(http=fake_repo_http)
    sector_id = conn.list_sectors()[0].id
    industries = conn.list_industries(sector_id)
    names = {i.id for i in industries}
    assert names == {"banking", "ecommerce"}
    assert all(i.sector_id == sector_id for i in industries)


def test_list_industries_unknown_sector_raises(fake_repo_http):
    with pytest.raises(SourceNotFoundError):
        GithubSourceConnector(http=fake_repo_http).list_industries("nope")


def test_list_models_3level_explicit_scope_and_version(fake_repo_http):
    models = GithubSourceConnector(http=fake_repo_http).list_models("banking")
    by_id = {m.id: m for m in models}
    assert set(by_id) == {"v1_ecm", "v1_mvm"}
    assert by_id["v1_ecm"].scope == "ecm"
    assert by_id["v1_ecm"].version == "v1"
    assert by_id["v1_ecm"].name == "Ecm V1"
    assert by_id["v1_mvm"].scope == "mvm"
    assert by_id["v1_mvm"].version == "v1"


def test_list_models_unknown_industry_raises(fake_repo_http):
    with pytest.raises(SourceNotFoundError):
        GithubSourceConnector(http=fake_repo_http).list_models("nope")


def test_model_id_relpath_roundtrip():
    from vibe_modeling.backend.sources.github import model_id_to_relpath

    assert model_id_to_relpath("v1_ecm") == "v1/ecm"
    assert model_id_to_relpath("v1_mvm") == "v1/mvm"
    assert model_id_to_relpath("v1_ecm_x") == "v1/ecm_x"
    for bad in ("v1_", "ecm", ""):
        with pytest.raises(SourceNotFoundError):
            model_id_to_relpath(bad)


def test_list_models_skips_non_version_dirs():
    """A stray ``images`` dir + a README at the industry level are skipped;
    only ``vN`` version dirs are walked."""
    http = _FakeHttp(
        {
            contents_key("banking"): _contents(
                _dir("v1"),
                _dir("images"),
                {"name": "README.md", "type": "file", "size": 10},
            ),
            contents_key("banking/v1"): _contents(_dir("ecm")),
        }
    )
    models = GithubSourceConnector(http=http).list_models("banking")
    assert {m.id for m in models} == {"v1_ecm"}


def test_list_models_fetch_path_hits_nested_scope(fake_repo_http):
    conn = GithubSourceConnector(http=fake_repo_http)
    conn.fetch_model_json("banking", "v1_ecm")
    raw_calls = [c for c in fake_repo_http.calls if "raw.githubusercontent.com" in c]
    assert any(c.endswith("/banking/v1/ecm/model.json") for c in raw_calls), raw_calls


# ---------------------------------------------------------------------------
# Fetch
# ---------------------------------------------------------------------------


def test_fetch_model_json_returns_raw_text(fake_repo_http):
    raw = GithubSourceConnector(http=fake_repo_http).fetch_model_json("banking", "v1_ecm")
    assert json.loads(raw)["model_name"] == "banking_ecm"


def test_fetch_model_json_404_raises(fake_repo_http):
    fake_repo_http._routes["raw.githubusercontent.com"] = _FakeResp(404, text="missing")
    with pytest.raises(SourceNotFoundError):
        GithubSourceConnector(http=fake_repo_http).fetch_model_json("banking", "v1_ghost")


def test_fetch_artifacts_tags_kinds_and_includes_model_json(fake_repo_http):
    arts = GithubSourceConnector(http=fake_repo_http).fetch_artifacts("banking", "v1_ecm")
    paths = {a.path for a in arts}
    assert "banking/v1/ecm/schemas/banking_account_schema_v1_ecm.sql" in paths, paths
    kinds = {a.target_kind for a in arts}
    assert TargetKind.MODEL_JSON in kinds
    assert TargetKind.SCHEMAS in kinds
    assert TargetKind.DIAGRAM in kinds
    schema_arts = [a for a in arts if a.target_kind == TargetKind.SCHEMAS]
    assert len(schema_arts) == 2
    assert all(a.download_url and "raw.githubusercontent.com" in a.download_url for a in arts)


def test_fetch_readme_prefers_scope_readme(fake_repo_http):
    fake_repo_http._routes["raw.githubusercontent.com"] = _FakeResp(200, text="scope readme")
    readme = GithubSourceConnector(http=fake_repo_http).fetch_readme("banking", "v1_ecm")
    assert readme == "scope readme"


def test_fetch_readme_falls_back_to_version_readme():
    http = _FakeHttp(
        {
            "banking/v1/ecm/readme.md": _FakeResp(404, text="missing"),
            "banking/v1/readme.md": _FakeResp(200, text="version readme"),
        }
    )
    readme = GithubSourceConnector(http=http).fetch_readme("banking", "v1_ecm")
    assert readme == "version readme"


def test_fetch_readme_none_when_both_missing():
    http = _FakeHttp({})  # everything 404s
    readme = GithubSourceConnector(http=http).fetch_readme("banking", "v1_ecm")
    assert readme is None


def test_fetch_releasenotes_returns_none_on_404():
    http = _FakeHttp({})  # everything 404s
    notes = GithubSourceConnector(http=http).fetch_releasenotes("banking", "v1_ecm")
    assert notes is None


def test_fetch_releasenotes_returns_text():
    http = _FakeHttp({"docs/releasenotes.txt": _FakeResp(200, text="MODEL STATISTICS")})
    notes = GithubSourceConnector(http=http).fetch_releasenotes("banking", "v1_ecm")
    assert notes == "MODEL STATISTICS"


# ---------------------------------------------------------------------------
# parse_model_statistics - releasenotes.txt "MODEL STATISTICS" block
# ---------------------------------------------------------------------------


# VERBATIM excerpt of the real
# advertising/v1/ecm/docs/releasenotes.txt (fetched 2026-07-07 from
# databricks-industry-solutions/lakehouse-industry-data-models @ main). Real
# files prefix the four count labels with "Total " (e.g. "Total Domains") -
# a fabricated fixture missed this and let the parser regress silently in
# the live app while this suite stayed green. Never hand-write this fixture;
# re-fetch verbatim if the format changes.
_SAMPLE_RELEASENOTES = """\
+==============================================================================+
| RELEASE NOTES                                                                |
| Business: Advertising                                                        |
| Version:  v1_ecm                                                             |
| Date:     2026-05-08 02:27:52                                                |
| Generated by Vibe Modelling Agent                                            |
+------------------------------------------------------------------------------+
|-----------------------------  MODEL STATISTICS  -----------------------------|
|                                                                              |
| Model Scope:         ECM (Expanded Coverage Model)                           |
| Total Domains:      13                                                       |
| Total Subdomains:   40                                                       |
| Total Products:     262                                                      |
| Total Attributes:   9284                                                     |
| Primary Keys:       261                                                      |
| Foreign Keys:       1544                                                     |
| Avg Attrs/Product:  35.4                                                     |
| Metric Views:       145                                                      |
|                                                                              |
+------------------------------------------------------------------------------+
|-------------------------  OUTPUT FOLDER STRUCTURE  --------------------------|
|                                                                              |
| v1_ecm/                                                                      |
|   model.json  - Full model (requirements + metadata + model)                 |
|   schemas/    - DDL SQL files (one per domain)                               |
|   metrics/    - Metric view SQL files (one per domain)                       |
"""


def test_parse_model_statistics_maps_every_label_by_name_not_order():
    """The real file's labels carry a "Total " prefix on the four counts
    (Domains/Subdomains/Products/Attributes) but NOT on the other four
    (Primary/Foreign Keys, Avg Attrs/Product, Metric Views) - both shapes
    must resolve to the same fields."""
    stats = gh.parse_model_statistics(_SAMPLE_RELEASENOTES)
    assert stats["domains"] == 13
    assert stats["subdomains"] == 40
    assert stats["products"] == 262
    assert stats["attributes"] == 9284
    assert stats["primary_keys"] == 261
    assert stats["foreign_keys"] == 1544
    assert stats["avg_attrs_per_product"] == 35.4
    assert stats["metric_views"] == 145


def test_parse_model_statistics_bare_labels_without_total_prefix_still_match():
    """A hypothetical doc without the "Total " prefix must still parse - the
    map itself is keyed on the bare label; the prefix is stripped, not
    required."""
    text = (
        "MODEL STATISTICS\n"
        "| Domains: 5 |\n"
        "| Subdomains: 6 |\n"
        "| Products: 7 |\n"
        "| Attributes: 8 |\n"
        "+----+\n"
    )
    stats = gh.parse_model_statistics(text)
    assert stats["domains"] == 5
    assert stats["subdomains"] == 6
    assert stats["products"] == 7
    assert stats["attributes"] == 8


def test_parse_model_statistics_absent_block_all_null():
    stats = gh.parse_model_statistics("no statistics block anywhere in this doc")
    assert set(stats.values()) == {None}


def test_parse_model_statistics_unparseable_value_is_null_not_a_crash():
    text = (
        "MODEL STATISTICS\n"
        "| Domains : not-a-number |\n"
        "| Avg Attrs/Product : also-not-a-number |\n"
        "+----+\n"
    )
    stats = gh.parse_model_statistics(text)
    assert stats["domains"] is None
    assert stats["avg_attrs_per_product"] is None


def test_parse_model_statistics_a_domain_named_samples_is_not_special_cased():
    """`samples` is a real domain name a release notes doc can carry (as free
    text elsewhere in the file) - the parser only reacts to the MODEL
    STATISTICS block structure, never to specific label/domain text content."""
    text = "MODEL STATISTICS\n| Domains : 3 |\n+----+\nDomains include: samples, orders\n"
    stats = gh.parse_model_statistics(text)
    assert stats["domains"] == 3


def test_non_200_listing_raises_source_error():
    http = _FakeHttp({"/contents": _FakeResp(500, text="boom")})
    with pytest.raises(SourceError):
        GithubSourceConnector(http=http).list_industries("_repo")


# ---------------------------------------------------------------------------
# build_github_connector defaults
# ---------------------------------------------------------------------------


def test_build_falls_back_to_default_repo():
    conn = build_github_connector(repo_owner="", repo_name="")
    assert conn.repo_owner == gh.DEFAULT_REPO_OWNER
    assert conn.repo_name == gh.DEFAULT_REPO_NAME
    assert conn.repo_owner == "databricks-industry-solutions"
    assert conn.repo_name == "lakehouse-industry-data-models"


def test_build_honours_explicit_repo():
    conn = build_github_connector(repo_owner="me", repo_name="mine")
    assert conn.repo_owner == "me"
    assert conn.repo_name == "mine"


# ---------------------------------------------------------------------------
# Base-path scoping (the data-models/ subtree move)
# ---------------------------------------------------------------------------


def test_reads_are_scoped_under_default_base_path(fake_repo_http):
    """With the default ``base_path`` every read is scoped beneath
    ``gh.DEFAULT_BASE_PATH``: the root-listing contents URL and a raw fetch URL
    both carry the base-path segment."""
    base = gh.DEFAULT_BASE_PATH.strip("/")
    assert base, "this test asserts a non-empty default base path"

    conn = GithubSourceConnector(http=fake_repo_http)
    conn.list_industries(conn.list_sectors()[0].id)
    conn.fetch_model_json("banking", "v1_ecm")

    contents_calls = [c for c in fake_repo_http.calls if "api.github.com" in c]
    raw_calls = [c for c in fake_repo_http.calls if "raw.githubusercontent.com" in c]
    assert contents_calls and raw_calls

    # Root listing scopes the contents API at the base path itself.
    assert any(c.endswith(f"/contents/{base}?ref=main") for c in contents_calls), contents_calls
    # The raw model.json fetch is nested beneath the base-path segment.
    assert all(f"/{base}/" in c for c in raw_calls), raw_calls


def test_empty_base_path_adds_no_prefix():
    """``base_path=""`` is the pre-move repo-root layout: the contents URL and
    the raw URL carry NO base-path prefix. Proves the prefix is genuinely
    parametric in the connector, not a hardcoded ``data-models`` literal."""
    http = _FakeHttp(
        {
            "/contents?ref=main": _contents(_dir("banking")),
            "raw.githubusercontent.com": _FakeResp(200, text="{}"),
        }
    )
    conn = GithubSourceConnector(base_path="", http=http)
    conn.list_industries(conn.list_sectors()[0].id)
    conn.fetch_model_json("banking", "v1_ecm")

    contents_call = next(c for c in http.calls if "api.github.com" in c)
    raw_call = next(c for c in http.calls if "raw.githubusercontent.com" in c)

    # Root listing sits directly at /contents (no intervening path segment).
    assert contents_call.endswith("/contents?ref=main"), contents_call
    # Raw URL: <ref>/banking/v1/ecm/model.json with no base-path segment
    # interposed between the ref and the industry id.
    assert raw_call.endswith(f"/{conn.ref}/banking/v1/ecm/model.json"), raw_call


# ---------------------------------------------------------------------------
# Route layer
# ---------------------------------------------------------------------------


@pytest.fixture
def patched_routes(monkeypatch, fake_repo_http):
    """Make the route build a connector backed by the fake HTTP."""
    from vibe_modeling.backend.routes import sources as sources_routes

    def _fake_build(repo_owner="", repo_name="", **_):  # noqa: ARG001
        return GithubSourceConnector(http=fake_repo_http)

    monkeypatch.setattr(sources_routes, "build_github_connector", _fake_build)
    return fake_repo_http


def test_route_capabilities(client, patched_routes):
    resp = client.get("/api/sources/capabilities")
    assert resp.status_code == 200
    body = resp.json()
    assert body["source_kind"] == "github"
    assert body["provides_sectors"] is False


def test_route_list_sectors(client, patched_routes):
    resp = client.get("/api/sources/sectors")
    assert resp.status_code == 200
    assert resp.json()[0]["synthetic"] is True


def test_route_list_industries(client, patched_routes):
    sector_id = client.get("/api/sources/sectors").json()[0]["id"]
    resp = client.get(f"/api/sources/sectors/{sector_id}/industries")
    assert resp.status_code == 200
    assert {i["id"] for i in resp.json()} == {"banking", "ecommerce"}


def test_route_list_industries_unknown_sector_404(client, patched_routes):
    resp = client.get("/api/sources/sectors/nope/industries")
    assert resp.status_code == 404


def test_route_list_models(client, patched_routes):
    resp = client.get("/api/sources/industries/banking/models")
    assert resp.status_code == 200
    assert {m["id"] for m in resp.json()} == {"v1_ecm", "v1_mvm"}


def test_route_model_preview(client, patched_routes):
    resp = client.get("/api/sources/industries/banking/models/v1_ecm/preview")
    assert resp.status_code == 200
    body = resp.json()
    assert body["model_name"] == "Banking"
    assert body["scope"] == "ecm"
    assert body["version"] == "v1"
    assert any(a["target_kind"] == "schemas" for a in body["artifacts"])


def test_route_model_preview_renders_readme(client, patched_routes, fake_repo_http):
    fake_repo_http._routes["raw.githubusercontent.com"] = _FakeResp(200, text="# Banking ECM\n")
    resp = client.get("/api/sources/industries/banking/models/v1_ecm/preview")
    assert resp.status_code == 200
    assert resp.json()["readme"] == "# Banking ECM\n"


def test_route_model_preview_missing_readme_is_null(client, patched_routes, fake_repo_http):
    fake_repo_http._routes["raw.githubusercontent.com"] = _FakeResp(404, text="missing")
    resp = client.get("/api/sources/industries/banking/models/v1_ecm/preview")
    assert resp.status_code == 200
    assert resp.json()["readme"] is None


def test_route_model_preview_stats_null_when_releasenotes_absent(client, patched_routes, fake_repo_http):
    fake_repo_http._routes["raw.githubusercontent.com"] = _FakeResp(404, text="missing")
    resp = client.get("/api/sources/industries/banking/models/v1_ecm/preview")
    assert resp.status_code == 200
    body = resp.json()
    for field in (
        "domains", "subdomains", "products", "attributes",
        "primary_keys", "foreign_keys", "avg_attrs_per_product", "metric_views",
    ):
        assert body[field] is None


def test_route_model_preview_missing_model_404(client, patched_routes):
    resp = client.get("/api/sources/industries/banking/models/ghost/preview")
    assert resp.status_code == 404


# ---------------------------------------------------------------------------
# Baseline resolver — find_latest_same_scope_version (Story 3)
# ---------------------------------------------------------------------------


def _industry_http(industry: str, version_scopes: dict[str, list[str]]) -> _FakeHttp:
    """Canned 3-level repo: ``industry`` lists ``version_scopes`` keys (version
    dirs), and each version dir lists its scope dirs."""
    routes: dict[str, _FakeResp] = {
        contents_key(industry): _contents(*[_dir(v) for v in version_scopes])
    }
    for version, scopes in version_scopes.items():
        routes[contents_key(f"{industry}/{version}")] = _contents(
            *[_dir(s) for s in scopes]
        )
    return _FakeHttp(routes)


def test_resolver_tier1_max_version():
    from vibe_modeling.backend.sources.github import (
        GithubSourceConnector,
        find_latest_same_scope_version,
    )

    conn = GithubSourceConnector(
        http=_industry_http("banking", {"v1": ["ecm", "mvm"], "v2": ["ecm"]})
    )
    res = find_latest_same_scope_version(conn, "banking", "ecm")
    assert res.model_id == "v2_ecm"
    assert res.tier == "same_scope_latest"
    assert res.scope_mismatch is False
    assert res.candidates == []


def test_resolver_tier1_tiebreak_on_id():
    # Two same-scope versions with the SAME _version_num -> deterministic
    # lexical-max id tie-break.
    from vibe_modeling.backend.sources.github import (
        GithubSourceConnector,
        find_latest_same_scope_version,
    )

    conn = GithubSourceConnector(
        http=_industry_http("banking", {"v1": ["ecm"], "v01": ["ecm"]})
    )
    res = find_latest_same_scope_version(conn, "banking", "ecm")
    # _version_num("v1")==_version_num("v01")==1 -> lexical-max id ("v1_ecm").
    assert res.model_id == "v1_ecm"
    assert res.tier == "same_scope_latest"


def test_resolver_tier2_lexical_newest_and_scope_mismatch():
    from vibe_modeling.backend.sources.github import (
        GithubSourceConnector,
        find_latest_same_scope_version,
    )

    conn = GithubSourceConnector(
        http=_industry_http("banking", {"v1": ["mvm"], "v2": ["mvm"]})
    )
    res = find_latest_same_scope_version(conn, "banking", "ecm")
    assert res.model_id == "v2_mvm"
    assert res.tier == "fallback_unverified"
    assert res.scope_mismatch is True


def test_resolver_tier3_empty_models():
    from vibe_modeling.backend.sources.github import (
        GithubSourceConnector,
        find_latest_same_scope_version,
    )

    conn = GithubSourceConnector(http=_industry_http("banking", {}))
    res = find_latest_same_scope_version(conn, "banking", "ecm")
    assert res.model_id is None
    assert res.tier == "none"
    assert res.scope_mismatch is False
    assert res.candidates == []


def test_resolver_propagates_source_not_found():
    # 404 from _list_contents (unknown industry) -> the resolver does NOT
    # swallow it; the service is the single catch point.
    from vibe_modeling.backend.sources.github import (
        GithubSourceConnector,
        find_latest_same_scope_version,
    )

    conn = GithubSourceConnector(http=_FakeHttp({}))  # everything 404s
    with pytest.raises(SourceNotFoundError):
        find_latest_same_scope_version(conn, "nope", "ecm")


def test_version_num_parse():
    from vibe_modeling.backend.sources.github import _version_num

    assert _version_num("v12") == 12
    assert _version_num("v") == -1
    assert _version_num(None) == -1


# ---------------------------------------------------------------------------
# Rate-limit mapping (Track 4): 403-with-rate-limit -> SourceRateLimitError
# ---------------------------------------------------------------------------


def test_rate_limited_403_raises_source_rate_limit_error():
    """A 403 with X-RateLimit-Remaining: 0 becomes a SourceRateLimitError with
    an actionable message + reset hint, not a generic SourceError."""
    http = _FakeHttp({
        "/contents": _FakeResp(
            403,
            text="API rate limit exceeded",
            headers={"X-RateLimit-Remaining": "0", "X-RateLimit-Reset": "1893456000"},
        ),
    })
    conn = GithubSourceConnector(http=http)
    with pytest.raises(SourceRateLimitError) as exc:
        conn.list_industries("_repo")
    msg = str(exc.value)
    assert "rate limit" in msg.lower()
    # Actionable copy points at configuring a GitHub App (reads are App-authed,
    # not per-user), not the retired "GitHub connection".
    assert "GitHub App" in msg
    assert exc.value.reset_hint  # a formatted UTC reset time


def test_rate_limited_429_also_maps():
    http = _FakeHttp({
        "/contents": _FakeResp(429, text="Too Many Requests", headers={"X-RateLimit-Remaining": "0"}),
    })
    with pytest.raises(SourceRateLimitError):
        GithubSourceConnector(http=http).list_industries("_repo")


def test_plain_403_without_rate_limit_is_not_rate_limit_error():
    # A 403 that is NOT a rate limit (e.g. a private repo auth failure) stays a
    # generic SourceError, not a 429.
    http = _FakeHttp({
        "/contents": _FakeResp(403, text="Forbidden", headers={"X-RateLimit-Remaining": "42"}),
    })
    with pytest.raises(SourceError) as exc:
        GithubSourceConnector(http=http).list_industries("_repo")
    assert not isinstance(exc.value, SourceRateLimitError)


def test_route_rate_limit_maps_to_429(client, monkeypatch):
    """The /sources route layer maps SourceRateLimitError to a 429."""
    import vibe_modeling.backend.routes.sources as routes_sources

    def _boom(session, config, user_ws=None):
        conn = GithubSourceConnector(http=_FakeHttp({
            "": _FakeResp(403, text="API rate limit exceeded",
                          headers={"X-RateLimit-Remaining": "0"}),
        }))
        return conn

    monkeypatch.setattr(routes_sources, "_connector", _boom)
    # list_sectors is synthetic (no network), so hit industries which does I/O.
    resp = client.get("/api/sources/sectors/_repo/industries")
    assert resp.status_code == 429, resp.text
    assert "rate limit" in resp.json()["detail"].lower()
