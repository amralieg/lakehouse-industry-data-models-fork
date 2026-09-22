"""Skeptical-tester pass for the model-size + listVersions-superseded fixes.

Targets three intent-coupled fixes shipped on
``fix/vibe-new-ecm-mvm-model-size-and-listversions-enum``:

A. ``dag_for_vibe_new_ecm_mvm`` MUST hardcode the leading ``vibe_iterate``
   step's ``params['model_size']`` to ``"large model"`` regardless of what
   ``RunIn.model_size`` carries. The bug: the FE defaults ``model_size`` to
   ``"small model"`` for non-vibe-iterate intents, so without the hardcode
   the agent writes the new ECM under MVM scope and the subsequent shrink
   step has no ECM to shrink.

B. ``GET /api/businesses/{biz}/versions`` (operation_id ``listVersions``)
   MUST tolerate ``status='superseded'`` on any ``ModelVersion`` row. The
   FE's ``ModelStatus`` enum is regenerated from the BE Pydantic response
   model, so an enum mismatch turns a perfectly valid persisted row into a
   500 from FastAPI's ResponseValidationError.

C. The ``shrink_to_mvm`` step in the same DAG must keep its
   ``model_size == "small model"`` — that contract is hardcoded inside
   ``_shrink_to_mvm_params`` and is independent of fix A. This regression
   guard stops a future refactor that pipes ``req.model_size`` blindly
   into every step from silently flipping shrink to "large model".

The rules of engagement (Skeptical Tester pattern, docs/orchestrator-design.md
§9): we do NOT read the dev's implementation files. The DAG factory is
called via its public ``__all__`` export only.
"""

from __future__ import annotations

import pytest
from sqlmodel import Session

from vibe_modeling.backend.db_models import Business, ModelVersion
from vibe_modeling.backend.models import RunIn


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _make_business() -> Business:
    """A populated Business — the factory reads ``business.name`` /
    ``description`` to compose widget params, so a partial mock would
    blow up before the assertions ever run.
    """
    return Business(
        id="biz-skeptical",
        name="Skeptical Test Corp",
        description="A skeptical test company.",
        industry_alignment="Retail",
    )


def _make_req(**kwargs) -> RunIn:
    """Build a vibe-new-ecm-mvm RunIn with the minimum-viable defaults
    that the dev's existing wire test (``test_wire_vibe_new_ecm_mvm``)
    proves the factory accepts. ``model_size`` is the parameter under
    test — let the caller override it.
    """
    defaults = {
        "intent": "vibe-new-ecm-mvm",
        "parent_version_id": "parent-version-id",
        "vibe_instructions": "Add an HR domain with employees and roles.",
        "catalog": "test_catalog",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
        "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        "model_size": "large model",
        "generate_samples": False,
    }
    defaults.update(kwargs)
    return RunIn(**defaults)


def _build_dag(req: RunIn, business: Business):
    """Resolve the public DAG factory (per __all__) and call it.

    The factory's signature is documented as
    ``dag_for_vibe_new_ecm_mvm(req, business, business_context, agent_config)``
    in the change spec. The wire test proves both 2-arg and 4-arg call
    shapes work; we use the 2-arg form for parity with the dev's likely
    call site.
    """
    from vibe_modeling.backend.services.orchestrator.dag_factories import (
        dag_for_vibe_new_ecm_mvm,
    )

    return dag_for_vibe_new_ecm_mvm(req, business)


def _find_step(dag, name: str):
    """Return the first OperationStep with matching ``name`` from ``dag.steps``."""
    for s in dag.steps:
        if s.name == name:
            return s
    pytest.fail(
        f"step {name!r} not found in DAG; got steps={[s.name for s in dag.steps]}"
    )


# ---------------------------------------------------------------------------
# Section A: vibe_iterate model_size hardcode (the headline fix)
# ---------------------------------------------------------------------------


class TestVibeIterateStepHardcodesModelSize:
    """Phase 1 of vibe-new-ecm-mvm produces ECM. ECM = "large model"
    in the agent's vocabulary. The factory MUST stamp that on the
    ``vibe_iterate`` step regardless of ``req.model_size``."""

    @pytest.mark.parametrize(
        "input_size",
        ["small model", "large model", "tiny model", "", None],
    )
    @pytest.mark.parametrize(
        "cataloging_style",
        ["One Catalog", "Catalog per Domain"],
    )
    def test_vibe_iterate_step_always_large_model(
        self, input_size, cataloging_style
    ):
        """For every plausible client-provided model_size and for both
        cataloging styles (2-step and 4-step DAGs), step 0's
        ``params['model_size']`` is exactly ``"large model"``.
        """
        kwargs = {"cataloging_style": cataloging_style}
        if cataloging_style == "Catalog per Domain":
            # Per-domain catalogs forbid schema prefixes (mirrors wire test).
            kwargs["ecm_schema_prefix"] = ""
            kwargs["mvm_schema_prefix"] = ""
        # ``RunIn.model_size`` may not accept None on some Pydantic shapes
        # — fall through with a default if so. The bug under test is that
        # ANY non-"large" value leaks through the factory.
        if input_size is None:
            req = _make_req(**kwargs)
            # Force the field to None post-construction so the factory
            # sees a falsy non-default value.
            try:
                req.model_size = None  # type: ignore[assignment]
            except Exception:
                pass
        else:
            req = _make_req(model_size=input_size, **kwargs)

        biz = _make_business()
        dag = _build_dag(req, biz)
        step = _find_step(dag, "vibe_iterate")

        actual = step.params.get("model_size")
        assert actual == "large model", (
            f"vibe_iterate step must be hardcoded to 'large model' for "
            f"vibe-new-ecm-mvm Phase 1 (input model_size={input_size!r}, "
            f"cataloging_style={cataloging_style!r}); got {actual!r}. "
            f"This is the bug where req.model_size leaked into Phase 1 "
            f"and made the agent write the new version under MVM scope."
        )

    def test_one_catalog_two_step_shape_with_default_size(self):
        """Sanity: One Catalog + default model_size still yields the
        documented 2-step DAG (vibe_iterate → shrink_to_mvm)."""
        req = _make_req()
        biz = _make_business()
        dag = _build_dag(req, biz)
        names = [s.name for s in dag.steps]
        assert names == ["vibe_iterate", "shrink_to_mvm"], (
            f"One Catalog DAG shape regressed; got {names}"
        )

    def test_catalog_per_domain_two_step_shape_with_default_size(self):
        """Sanity: Catalog per Domain yields the same 2-step DAG as One
        Catalog (agent inline-installs in every cataloging_style)."""
        req = _make_req(
            cataloging_style="Catalog per Domain",
            ecm_schema_prefix="",
            mvm_schema_prefix="",
        )
        biz = _make_business()
        dag = _build_dag(req, biz)
        names = [s.name for s in dag.steps]
        assert names == ["vibe_iterate", "shrink_to_mvm"], (
            f"Catalog per Domain DAG shape regressed; got {names}"
        )


# ---------------------------------------------------------------------------
# Section C (numbered for proximity to A): shrink_to_mvm model_size guard
# ---------------------------------------------------------------------------


class TestShrinkStepDoesNotInheritUserModelSize:
    """The shrink step's params dict (``_shrink_to_mvm_params``) does NOT
    include ``model_size``: the ShrinkToMvm primitive has no ``model_size``
    field on its params_model — its size is implicit / hardcoded elsewhere.

    The fix in this commit must not regress that: a "fix" that pipes
    ``req.model_size`` blindly through every step would leak the FE
    default ("small model" or whatever) into the shrink params dict.
    The contract we lock here: either the field is absent OR it's
    exactly ``"small model"`` — anything carrying through ``req.model_size``
    means the bug regressed.
    """

    @pytest.mark.parametrize(
        "input_size",
        ["small model", "large model", "tiny model"],
    )
    @pytest.mark.parametrize(
        "cataloging_style",
        ["One Catalog", "Catalog per Domain"],
    )
    def test_shrink_step_does_not_carry_user_model_size(
        self, input_size, cataloging_style
    ):
        kwargs = {"cataloging_style": cataloging_style, "model_size": input_size}
        if cataloging_style == "Catalog per Domain":
            kwargs["ecm_schema_prefix"] = ""
            kwargs["mvm_schema_prefix"] = ""
        req = _make_req(**kwargs)
        biz = _make_business()
        dag = _build_dag(req, biz)
        step = _find_step(dag, "shrink_to_mvm")
        # If the field is present at all, it must be the locked-in
        # "small model" — never the user-supplied value (which would be
        # the bug). Absent is also OK (the primitive sets it internally).
        actual = step.params.get("model_size", None)
        assert actual in (None, "small model"), (
            f"shrink_to_mvm step is leaking user-supplied model_size into "
            f"its params dict (input={input_size!r}, "
            f"cataloging_style={cataloging_style!r}); got "
            f"{actual!r}. Either drop it from the dict or keep it at "
            f"'small model' regardless of req.model_size."
        )


# ---------------------------------------------------------------------------
# Section B: listVersions response enum tolerates 'superseded'
# ---------------------------------------------------------------------------


class TestListVersionsAcceptsSuperseded:
    """The FE Base-Version dropdown calls ``listVersions``. Once a model
    has been vibed at least once, the parent row's status flips to
    ``'superseded'`` (vibe_iterate.py:609). If the response Pydantic
    enum doesn't include that literal, the endpoint 500s with a
    ResponseValidationError and the FE dropdown breaks for the entire
    business."""

    def test_listversions_with_only_superseded_returns_200(
        self, client, engine, seed_business
    ):
        """Single ModelVersion row, status='superseded' — the bug
        manifested even on a single-row response."""
        with Session(engine) as session:
            session.add(
                ModelVersion(
                    business_id=seed_business,
                    version=1,
                    status="superseded",
                    deployment_status="draft",
                    scope="ecm",
                    uc_catalog="cat",
                )
            )
            session.commit()

        resp = client.get(f"/api/businesses/{seed_business}/versions")
        assert resp.status_code == 200, (
            f"listVersions returned {resp.status_code} for a row with "
            f"status='superseded' — the response enum still rejects it. "
            f"body={resp.text!r}"
        )

    def test_listversions_includes_superseded_row_in_payload(
        self, client, engine, seed_business
    ):
        """The endpoint must SURFACE the superseded row, not silently
        filter it. The FE's "Base Version" picker needs to know the
        parent exists so it can be marked as superseded in the UI."""
        with Session(engine) as session:
            session.add(
                ModelVersion(
                    business_id=seed_business,
                    version=42,
                    status="superseded",
                    deployment_status="draft",
                    scope="ecm",
                    uc_catalog="cat",
                )
            )
            session.commit()

        resp = client.get(f"/api/businesses/{seed_business}/versions")
        assert resp.status_code == 200
        body = resp.json()
        versions = [row for row in body if row.get("version") == 42]
        assert len(versions) == 1, (
            f"superseded row was filtered out of the response; "
            f"got {len(versions)} rows with version=42 from {body!r}"
        )
        assert versions[0]["status"] == "superseded", (
            f"superseded row was coerced to a different status; got "
            f"{versions[0]!r}"
        )

    def test_listversions_with_mixed_statuses_returns_200(
        self, client, engine, seed_business
    ):
        """Mix several statuses on different versions — the response
        coercion runs for every row, so even one bad enum entry on a
        list of valid rows surfaces the bug."""
        rows = [
            (1, "completed"),
            (2, "superseded"),
            (3, "draft"),
            (4, "failed"),
            (5, "generating"),
        ]
        with Session(engine) as session:
            for v_int, status in rows:
                session.add(
                    ModelVersion(
                        business_id=seed_business,
                        version=v_int,
                        status=status,
                        deployment_status="draft",
                        scope="ecm",
                        uc_catalog="cat",
                    )
                )
            session.commit()

        resp = client.get(f"/api/businesses/{seed_business}/versions")
        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert len(body) == len(rows), (
            f"expected {len(rows)} rows, got {len(body)}: {body!r}"
        )
        # Every persisted status round-trips intact.
        seen = {row["version"]: row["status"] for row in body}
        for v_int, status in rows:
            assert seen.get(v_int) == status, (
                f"status round-trip mismatch: version={v_int} sent "
                f"status={status!r} but got {seen.get(v_int)!r}"
            )


# ---------------------------------------------------------------------------
# Section D: getExplorerVersions cross-check (no regression)
# ---------------------------------------------------------------------------


class TestExplorerVersionsUnchanged:
    """``getExplorerVersions`` is a separate endpoint with its own
    response model (``VersionTreeOut``). It already serializes ``status``
    as a free-form string so it shouldn't have been broken by the
    listVersions fix in either direction. This guard catches a future
    over-refactor that unifies the two response shapes and accidentally
    inherits the listVersions enum."""

    def test_explorer_versions_with_superseded_returns_200(
        self, client, engine, seed_business
    ):
        with Session(engine) as session:
            session.add(
                ModelVersion(
                    business_id=seed_business,
                    version=1,
                    status="superseded",
                    deployment_status="draft",
                    scope="ecm",
                    uc_catalog="cat",
                )
            )
            session.commit()

        resp = client.get(
            f"/api/businesses/{seed_business}/explorer/versions"
        )
        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert len(body) == 1
        assert body[0]["status"] == "superseded"
