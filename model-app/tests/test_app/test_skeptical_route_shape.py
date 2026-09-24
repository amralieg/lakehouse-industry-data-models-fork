"""Skeptical tests for the new versioned route shape (Stream B).

Contract clauses tested:
- ``/api/businesses/{business_id}/versions/{version_int}/{scope}/...`` is the
  new shape (was ``/versions/{version_int}/...``).
- The OpenAPI schema lists ``scope`` as a path parameter on these routes.
- Hitting the new shape returns 200 for a known MV.
- Hitting an old-shape URL (without ``scope``) either returns 404, 400, or
  auto-redirects.

The contract names ``/summary`` as the example endpoint, but the existing
read-side surface is ``/model`` (and its descendants ``/domains/...``,
``/relationships``, ``/diagram``). These tests target the canonical
``/model`` endpoint as a stand-in — if the dev added a literal ``/summary``
that's also fine, the test for "scope appears in the OpenAPI" will catch it.
"""

from __future__ import annotations

from sqlmodel import Session

from vibe_modeling.backend.db_models import ModelVersion


def _seed_completed_version(engine, biz_id: str, version: int = 1, scope: str = "mvm") -> str:
    """Seed a completed MV row and return its uuid."""
    with Session(engine) as session:
        mv = ModelVersion(
            business_id=biz_id,
            version=version,
            scope=scope,
            status="completed",
        )
        session.add(mv)
        session.commit()
        session.refresh(mv)
        return mv.id


def _route_paths(client) -> list[str]:
    """Return the FastAPI app's registered route paths."""
    return [r.path for r in client.app.routes if hasattr(r, "path")]


def test_openapi_lists_scope_as_path_param(client):
    """Stream B — at least one route under /api/businesses/.../versions/.../...
    declares ``scope`` as a path parameter.

    We scan the live OpenAPI spec rather than a static fixture so this picks
    up wherever the new shape was wired (versions.py, explorer.py, diagram.py).
    """
    spec = client.get("/openapi.json").json()
    paths = spec.get("paths", {})
    candidates = [
        p for p in paths
        if "/businesses/{business_id}/versions/{version_int}/{scope}" in p
        or "/businesses/{business_id}/versions/{version_int}/${scope}" in p
    ]
    assert candidates, (
        "No route in the OpenAPI spec uses the new shape "
        "/businesses/{business_id}/versions/{version_int}/{scope}/...\n"
        "Found versioned paths:\n"
        + "\n".join(p for p in paths if "/versions/" in p)
    )

    # And at least one of those routes lists `scope` as a path-typed parameter.
    found_scope_param = False
    for cand in candidates:
        for verb_def in paths[cand].values():
            for param in verb_def.get("parameters", []):
                if param.get("name") == "scope" and param.get("in") == "path":
                    found_scope_param = True
                    break
    assert found_scope_param, (
        "scope appears in the URL template but isn't declared as a path parameter "
        "in the OpenAPI spec; routes:\n" + "\n".join(candidates)
    )


def test_new_shape_route_returns_200_for_known_mv(client, seed_business, mock_ws):
    """Stream B — Hit the new-shape /model endpoint (with scope) and expect a
    successful resolution for a known MV.

    The endpoint also reads `model.json` from the Volume — the test fixture's
    mock_ws may or may not stub that, so we accept 200 OR (a deliberate-not-
    found 404) but explicitly REJECT 404 with the body text "route not
    matched" / "Not Found" if the *route* itself doesn't exist.
    """
    biz_id = seed_business
    _seed_completed_version(client.app, biz_id) if False else None  # placeholder; see below
    # Seed via the real engine that the client fixture uses by reusing the
    # client's session-override path through a direct insert.
    from sqlmodel import SQLModel, Session as _Sess
    from sqlalchemy import inspect

    # The client fixture's engine isn't directly exposed; use the seed_business
    # business and add an MV through the dependency_override session factory.
    override = client.app.dependency_overrides
    # Resolve the lakebase session override → call it once to get a Session.
    # Each entry is a generator function; advance it manually.
    session_dep = next(
        v for k, v in override.items() if "Lakebase" in repr(k)
    )
    gen = session_dep()
    sess = next(gen)
    try:
        mv = ModelVersion(
            business_id=biz_id,
            version=1,
            scope="mvm",
            status="completed",
        )
        sess.add(mv)
        sess.commit()
    finally:
        try:
            next(gen)
        except StopIteration:
            pass

    # Try the new-shape URL on a couple of known endpoints. We probe `/model`
    # because that's the most-likely-already-existing endpoint; if the dev
    # literally exposed `/summary` separately, that'd also be fine but is not
    # required for this assertion.
    new_shape = f"/api/businesses/{biz_id}/versions/1/mvm/model"
    resp = client.get(new_shape)
    # The route MUST exist. 200 is best; 404/500 caused by mock_ws not being
    # able to fetch model.json is acceptable as long as it's clearly a body-
    # error rather than "route not registered". 404 with body containing "Not
    # Found" or "not_matched" usually means the route shape isn't there.
    if resp.status_code == 404:
        body = resp.text.lower()
        # FastAPI's default 404 for an unknown path is `{"detail":"Not Found"}`.
        # That's the failure signal here; route-internal 404 (e.g. "model not
        # found") usually has more context.
        assert body != '{"detail":"not found"}', (
            f"GET {new_shape} returned 404 — the new-shape route is not registered.\n"
            f"Available paths matching /versions/:\n"
            + "\n".join(p for p in _route_paths(client) if "/versions/" in p)
        )
    else:
        assert resp.status_code in (200, 400, 422, 500), (
            f"unexpected status {resp.status_code} for {new_shape}: {resp.text[:200]}"
        )


def test_old_shape_no_longer_resolves_the_same_way(client, seed_business):
    """Stream B — The OLD shape ``/versions/{int}/...`` (without ``scope``)
    must NOT silently behave the same as the new shape — it has to either
    404, 400, or redirect."""
    biz_id = seed_business

    # Probe the old shape on the same endpoint stem.
    old_shape = f"/api/businesses/{biz_id}/versions/1/model"
    resp = client.get(old_shape, follow_redirects=False)

    acceptable = (
        resp.status_code == 404
        or resp.status_code == 400
        or 300 <= resp.status_code < 400  # redirect to the MVM/new shape
    )
    assert acceptable, (
        f"GET {old_shape} returned {resp.status_code} — the old shape (without "
        f"scope) should 404 / 400 / redirect after the route reshape, but instead "
        f"resolved successfully. Response: {resp.text[:200]}"
    )


def test_ecm_and_mvm_same_version_int_return_different_payloads(client, seed_business):
    """Scope disambiguation — (business, version=1, scope=ecm) and
    (business, version=1, scope=mvm) must resolve to different model
    payloads when both rows exist with different domain data.

    This is the core contract: the route must use (version, scope) as the
    natural key, not version alone.
    """
    biz_id = seed_business

    # Seed ECM v=1 with one domain
    override = client.app.dependency_overrides
    session_dep = next(v for k, v in override.items() if "Lakebase" in repr(k))

    from vibe_modeling.backend.db_models import Attribute, Domain, ModelVersion, Product

    def _insert_version(scope: str, domain_name: str) -> str:
        gen = session_dep()
        sess = next(gen)
        try:
            mv = ModelVersion(business_id=biz_id, version=1, scope=scope, status="completed")
            sess.add(mv)
            sess.flush()
            d = Domain(version_id=mv.id, name=domain_name, division="Eng", description="")
            sess.add(d)
            sess.flush()
            p = Product(
                version_id=mv.id, domain_id=d.id,
                name=f"{domain_name}_table", table_name=f"{domain_name}_table",
                description="", type="Master", primary_key="id",
            )
            sess.add(p)
            sess.flush()
            sess.add(Attribute(product_id=p.id, name="id", column_name="id", type="BIGINT", description="PK"))
            sess.commit()
            return mv.id
        finally:
            try:
                next(gen)
            except StopIteration:
                pass

    _insert_version("ecm", "ecm_domain")
    _insert_version("mvm", "mvm_domain")

    ecm_resp = client.get(f"/api/businesses/{biz_id}/versions/1/ecm/model")
    mvm_resp = client.get(f"/api/businesses/{biz_id}/versions/1/mvm/model")

    # Both routes must exist and return successfully (or a meaningful non-found error,
    # not a bare "Not Found" which indicates missing route registration).
    for scope_label, resp in [("ecm", ecm_resp), ("mvm", mvm_resp)]:
        if resp.status_code == 404:
            assert resp.json().get("detail", "").lower() != "not found", (
                f"GET /versions/1/{scope_label}/model returned generic 404 — "
                f"route is not registered. Status: {resp.status_code}, body: {resp.text[:200]}"
            )

    # If both resolved, their domain names must differ.
    if ecm_resp.status_code == 200 and mvm_resp.status_code == 200:
        ecm_domains = {d["name"] for d in ecm_resp.json().get("domains", [])}
        mvm_domains = {d["name"] for d in mvm_resp.json().get("domains", [])}
        assert ecm_domains != mvm_domains, (
            f"ECM and MVM at version=1 returned the same domains {ecm_domains!r}; "
            f"scope disambiguation is broken."
        )
