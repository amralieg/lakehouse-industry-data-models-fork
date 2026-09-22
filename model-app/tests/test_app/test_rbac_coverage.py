"""RBAC coverage — every mutating route must declare an auth marker.

Walks every route registered on the FastAPI app and asserts each has
either a role guard (``Dependencies.AdminOnly`` /
``Dependencies.BusinessAdminOnly`` / ``Dependencies.ModelerOnly``), or
appears on a curated allow-list of intentionally public / read-only
routes (``/api/version``, ``/api/current-user``, etc.).

The intent is to make adding a *new* mutating route without an explicit
auth declaration a hard test failure — so the next handler that lands
in ``routes/`` cannot silently be open to anonymous traffic.

Public-by-design routes are listed in ``_PUBLIC_ROUTES``. Read-only
GETs that intentionally don't gate — list endpoints, explorer endpoints
that the UI shows to every signed-in user — are listed in
``_READ_ONLY_ROUTES``. Both lists are minimal: anything not on them
must declare a role guard.
"""

from __future__ import annotations

import os
import sys

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)

import pytest
from fastapi import FastAPI
from fastapi.routing import APIRoute

from vibe_modeling.backend.core._roles import (
    require_admin,
    require_business_admin,
    require_modeler,
)
from vibe_modeling.backend.router import router
from vibe_modeling.backend import explorer as _explorer  # noqa: F401
from vibe_modeling.backend import diagram as _diagram  # noqa: F401
from vibe_modeling.backend.routes import (
    _dev_fixtures as _routes_dev_fixtures,
    businesses as _routes_businesses,
    config as _routes_config,
    deployment as _routes_deployment,
    industries as _routes_industries,
    industry_models as _routes_industry_models,
    platform as _routes_platform,
    sectors as _routes_sectors,
    sources as _routes_sources,
    versions as _routes_versions,
)


# Routes deliberately exposed to anonymous traffic — typically health,
# version, and identity introspection endpoints the UI calls before the
# user is signed in / before role data is available.
_PUBLIC_ROUTES: set[tuple[str, str]] = {
    ("GET", "/api/version"),
    ("GET", "/api/current-user"),
    ("GET", "/api/user/role"),
    # Soft-drain status — UI banner + the deploy poller poll this before
    # the user is authenticated. No mutation, no PII (just a bool +
    # an integer count).
    ("GET", "/api/health"),
}


# Read-only routes that are visible to every signed-in user (any role).
# These are explorer / list / read endpoints — they don't mutate state
# and the UI shows them to viewers and modelers alike. Adding to this
# list is a deliberate signal that a route is read-only: if a future PR
# converts a GET to a mutator, the test should fail unless the role guard
# is added at the same time.
_READ_ONLY_ROUTES: set[tuple[str, str]] = {
    # Platform
    ("GET", "/api/user/preferences"),
    ("PUT", "/api/user/preferences/{key}"),  # per-user write to own row
    ("GET", "/api/catalogs"),
    ("GET", "/api/admin/bundled-agent"),  # info-only, no mutation
    # Client telemetry beacon — any signed-in user; logs a warning only
    # (no DB write, no mutation, no domain access). Used by the kickstart
    # dialog to record a transient gateway 502 in the app logs.
    ("POST", "/api/client-telemetry/gateway-error"),
    # Businesses + contexts (reads)
    ("GET", "/api/businesses"),
    ("GET", "/api/businesses/{business_id}"),
    ("GET", "/api/businesses/{business_id}/contexts"),
    # Import preview (no DB write — reads model.json from Volumes and
    # returns an analysis report. The corresponding /execute endpoint
    # IS gated.)
    ("POST", "/api/businesses/{business_id}/import/analyze"),
    # Explorer (reads)
    ("GET", "/api/businesses/{business_id}/explorer/versions"),
    ("GET", "/api/businesses/{business_id}/versions/{version_int}/{scope}/model"),
    # Model-wide element search - read-only name lookup over domains/products/
    # attributes, version-scoped; no mutation.
    ("GET", "/api/businesses/{business_id}/versions/{version_int}/{scope}/search"),
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/domains/{domain_name}",
    ),
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/domains/{domain_name}/products/{product_name}",
    ),
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/relationships",
    ),
    # Review state (reads — effective per-product states + progress rollup).
    # The mutating marks live under routes/vibe_inputs.py (a router this RBAC
    # walker does not include, matching the prior domain-review endpoints).
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/reviews",
    ),
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/review-progress",
    ),
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/review-progress/by-domain",
    ),
    # next_vibes "expected work" metrics (T13) — read-only aggregates over the
    # open agent-input backlog; no mutation. Model + per-domain scope.
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/next-vibe-metrics",
    ),
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/domains/{domain_name}/next-vibe-metrics",
    ),
    # Model evolution metrics (T16) — read-only projection of the version's
    # Volume model.json _vibe_session_metadata; no mutation. Model scope only.
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/evolution-metrics",
    ),
    # Statistics report Excel export (T15) — read-only render of the same
    # metrics readers into an .xlsx download; no mutation.
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/statistics-report.xlsx",
    ),
    # Diagram (reads — per (version, scope) variant only registered today)
    ("GET", "/api/businesses/{business_id}/versions/{version_int}/{scope}/diagram"),
    # Versions (per-business listing only — version detail is currently
    # served via /versions/{version_int}/model under the explorer surface)
    ("GET", "/api/businesses/{business_id}/versions"),
    # Model-version-scoped reads (joined view across runs / artifacts)
    ("GET", "/api/model-versions/{version_id}/runs"),
    ("GET", "/api/model-versions/{model_version_id}/next-vibes"),
    ("GET", "/api/businesses/{business_id}/model-versions/{model_version_id}/artifacts"),
    ("GET", "/api/businesses/{business_id}/model-versions/{model_version_id}/artifacts/download"),
    # Model export (inverse of import) — read-only reconstruction of a
    # version's model.json / publishable bundle. No mutation.
    ("GET", "/api/businesses/{business_id}/model-versions/{model_version_id}/export"),
    ("GET", "/api/businesses/{business_id}/model-versions/{model_version_id}/export/bundle"),
    ("GET", "/api/businesses/{business_id}/model-versions/{model_version_id}/artifacts/{artifact_id}/content"),
    ("GET", "/api/businesses/{business_id}/model-versions/{model_version_id}/artifacts/{artifact_id}/download"),
    # Drift probe — read-only catalog-vs-Lakebase comparison (#69).
    # The reconcile endpoint that follows IS gated (BusinessAdminOnly).
    ("GET", "/api/model-versions/{model_version_id}/installation-status"),
    # Runs (read endpoints — see router.py). Every run-scoped endpoint
    # nests under /api/businesses/{business_id}/runs/... so the bid in
    # the URL acts as the per-tenant scope check.
    ("GET", "/api/businesses/{business_id}/runs/{run_id}"),
    ("GET", "/api/businesses/{business_id}/runs/{run_id}/lineage"),
    ("GET", "/api/businesses/{business_id}/runs/{run_id}/progress"),
    # New-Run live form feedback — no DB write, just runs the validator
    # and returns warnings/blockers. The mutating sibling POST /runs is
    # role-gated separately.
    ("POST", "/api/businesses/{business_id}/runs/validate"),
    # Per-step orchestrator state — read-only projection of
    # ``RunOperation`` rows the run's owner already has access to view
    # via GET /runs/{run_id}.
    ("GET", "/api/businesses/{business_id}/runs/{run_id}/operations"),
    ("GET", "/api/businesses/{business_id}/runs"),
    ("GET", "/api/businesses/{business_id}/runs/{run_id}/artifacts"),
    ("GET", "/api/businesses/{business_id}/runs/{run_id}/artifacts/{artifact_id}/content"),
    ("GET", "/api/businesses/{business_id}/runs/{run_id}/artifacts/download"),
    ("GET", "/api/businesses/{business_id}/runs/{run_id}/artifacts/{artifact_id}/download"),
    # Industries (reads)
    ("GET", "/api/industries"),
    # Sectors (reads — list is open; create/update/delete are AdminOnly)
    ("GET", "/api/sectors"),
    # Config (reads — agent-config GET is open; mutations are AdminOnly)
    ("GET", "/api/config/agent"),
    # GitHub config (read is open; the PUT is AdminOnly)
    ("GET", "/api/config/github"),
    # Source explorer (Wave 1, Track C) — read-only browse of an external
    # catalog (GitHub today). No mutation in this story; publish/write lands
    # in a later wave behind the UC connection.
    ("GET", "/api/sources/capabilities"),
    ("GET", "/api/sources/sectors"),
    ("GET", "/api/sources/sectors/{sector_id}/industries"),
    ("GET", "/api/sources/industries/{industry_id}/models"),
    ("GET", "/api/sources/industries/{industry_id}/models/{model_id}/preview"),
    # Industry-model lifecycle router (Wave 2). Foundational health probe is
    # public-by-design (no-auth liveness); later lifecycle endpoints add their own guards.
    ("GET", "/api/industry-models/_health"),
    ("GET", "/api/config/agent/supported-version"),
    ("GET", "/api/config/agent-compat"),
    ("GET", "/api/config/agent/ready"),
    ("GET", "/api/config/agent/check-notebook"),
    ("GET", "/api/config/deployment-catalog"),
    ("GET", "/api/config/metamodel-catalog"),
    ("GET", "/api/config/warehouses"),
    ("GET", "/api/config/warehouse"),
    ("GET", "/api/config/oob-check"),
    # Deployment (reads only — uc-schema / compare / catalog-check)
    ("GET", "/api/businesses/{business_id}/versions/{version_id}/deployment/catalog-check"),
    ("GET", "/api/businesses/{business_id}/versions/{version_id}/deployment/uc-schema"),
    ("GET", "/api/businesses/{business_id}/versions/{version_id}/deployment/compare"),
}


# Role guard dependency callables — any route that depends on one of
# these (transitively) is considered RBAC-gated.
_ROLE_GUARDS = {require_admin, require_business_admin, require_modeler}


def _build_app() -> FastAPI:
    app = FastAPI()
    app.include_router(router)
    for r in (
        _routes_platform.router,
        _routes_industries.router,
        _routes_sectors.router,
        _routes_sources.router,
        _routes_industry_models.router,
        _routes_config.router,
        _routes_businesses.router,
        _routes_versions.router,
        _routes_deployment.router,
        _routes_dev_fixtures.router,
    ):
        app.include_router(r)
    return app


def _route_has_role_guard(route: APIRoute) -> bool:
    """Walk the route's dependency tree and return True if any of the
    role-guard callables is present. FastAPI builds a flat dependant
    chain we can traverse; we also check the endpoint signature in case
    the guard is declared as a parameter rather than a top-level
    Depends().
    """
    seen: set[int] = set()
    stack = [route.dependant]
    while stack:
        d = stack.pop()
        if id(d) in seen:
            continue
        seen.add(id(d))
        if d.call in _ROLE_GUARDS:
            return True
        # FastAPI exposes the nested dependants on `dependencies`.
        for child in getattr(d, "dependencies", []) or []:
            stack.append(child)
    return False


def _enumerate_routes(app: FastAPI) -> list[tuple[str, str, APIRoute]]:
    """Yield (method, path, route) for every concrete APIRoute on the app."""
    out: list[tuple[str, str, APIRoute]] = []
    for r in app.routes:
        if not isinstance(r, APIRoute):
            continue
        for method in r.methods or []:
            if method in ("HEAD", "OPTIONS"):
                continue
            out.append((method, r.path, r))
    return out


# ---------------------------------------------------------------------------
# Coverage tests
# ---------------------------------------------------------------------------


@pytest.fixture(scope="module")
def all_routes() -> list[tuple[str, str, APIRoute]]:
    return _enumerate_routes(_build_app())


def test_at_least_one_route_present(all_routes):
    """Sanity — if route discovery breaks, every other test in this file
    becomes a vacuous pass. Fail loud on an empty list."""
    assert len(all_routes) >= 50, (
        f"Discovered only {len(all_routes)} routes — registration likely broken."
    )


def test_every_route_is_classified(all_routes):
    """Every (method, path) pair must be either:
      * RBAC-gated (declares one of the role guards), OR
      * on the public allow-list, OR
      * on the read-only allow-list.

    A new route that doesn't fit any of these is a coverage gap — the
    fix is to either add a guard to the handler or add the route to one
    of the allow-lists with a comment explaining why."""
    failures: list[str] = []
    for method, path, route in all_routes:
        key = (method, path)
        gated = _route_has_role_guard(route)
        public = key in _PUBLIC_ROUTES
        read_only = key in _READ_ONLY_ROUTES
        if not (gated or public or read_only):
            failures.append(f"  {method} {path}")
    assert not failures, (
        "The following routes have no auth marker and are not on the "
        "public / read-only allow-lists:\n" + "\n".join(failures) + "\n"
        "Either add `_role: Dependencies.{Admin,BusinessAdmin,Modeler}Only` "
        "to the handler, or append the route to _PUBLIC_ROUTES / "
        "_READ_ONLY_ROUTES in tests/test_app/test_rbac_coverage.py with "
        "a one-line justification."
    )


def test_allowlist_entries_are_real_routes(all_routes):
    """Any (method, path) on the allow-list that doesn't exist on the
    app is rotten — either the route was renamed or removed. Catching
    this prevents the allow-list from silently growing forever."""
    discovered = {(m, p) for m, p, _ in all_routes}
    for label, allowlist in (
        ("_PUBLIC_ROUTES", _PUBLIC_ROUTES),
        ("_READ_ONLY_ROUTES", _READ_ONLY_ROUTES),
    ):
        stale = allowlist - discovered
        assert not stale, (
            f"{label} contains entries that no longer exist on the app:\n"
            + "\n".join(f"  {m} {p}" for m, p in sorted(stale))
            + f"\nRemove them from {label} (in test_rbac_coverage.py)."
        )


def test_admin_only_routes_have_admin_guard(all_routes):
    """The endpoints that absolutely must be admin-only — seed-model and
    install-bundled-agent are the obvious ones — get an explicit
    cross-check so a refactor that swaps AdminOnly for ModelerOnly
    fails this test even though the broader coverage test still
    passes (any guard is better than none, but the wrong guard is
    a privilege escalation)."""
    must_be_admin: set[tuple[str, str]] = {
        ("POST", "/api/businesses/{business_id}/seed-model"),
        ("POST", "/api/admin/install-bundled-agent"),
        ("PUT", "/api/config/agent"),
        (
            "POST",
            "/api/businesses/{business_id}/versions/import-from-volume",
        ),
        ("DELETE", "/api/businesses/{business_id}/runs/{run_id}"),
    }
    by_key = {(m, p): r for m, p, r in all_routes}

    for method, path in must_be_admin:
        route = by_key.get((method, path))
        assert route is not None, (
            f"{method} {path} not found — the admin-only assertion list "
            f"is stale; update test_rbac_coverage.py."
        )
        # Walk the dependant chain looking for require_admin specifically.
        seen: set[int] = set()
        stack = [route.dependant]
        found_admin = False
        while stack:
            d = stack.pop()
            if id(d) in seen:
                continue
            seen.add(id(d))
            if d.call is require_admin:
                found_admin = True
                break
            for c in getattr(d, "dependencies", []) or []:
                stack.append(c)
        assert found_admin, (
            f"{method} {path} must be guarded by Dependencies.AdminOnly "
            f"(require_admin); currently has no admin guard in its "
            f"dependency chain."
        )


def test_route_walker_reports_total_count(all_routes, capsys):
    """Reporting hook — emits the total count to stdout so the CI log
    captures the number of routes the walker covered. Useful for
    spotting silent regressions in discovery (e.g. a router fails to
    register and the count drops)."""
    total = len(all_routes)
    gated = sum(1 for _, _, r in all_routes if _route_has_role_guard(r))
    public = sum(
        1 for m, p, _ in all_routes if (m, p) in _PUBLIC_ROUTES
    )
    read_only = sum(
        1 for m, p, _ in all_routes if (m, p) in _READ_ONLY_ROUTES
    )
    print(
        f"\nRBAC coverage: total={total} "
        f"role-gated={gated} public={public} read-only={read_only}"
    )
    # Also assert the counts add up — every route is in exactly one
    # bucket. (Read-only entries that also have a guard are fine; the
    # bucket-coverage test only asserts each route fits >= 1 bucket.)
    assert gated + public + read_only >= total, (
        f"Bucket coverage shortfall: gated={gated} + public={public} "
        f"+ read_only={read_only} < total={total}"
    )
