"""Adversarial tests for the ``vibe_iterate`` operation primitive.

See ``docs/orchestrator-design.md`` §2 + §10 for the contract. The
primitive launches a Databricks job that runs the agent in
"vibe modeling of version" mode against an existing parent ModelVersion,
then materializes a new derived ModelVersion on success.

These tests are independent of the development implementation
(Skeptical Tester Pattern). Where the test needs to reference the
primitive class but the production module isn't present yet, a local
``# STUB-FOR-INTEGRATION`` shim raises so the test fails loudly on
``main`` and runs against the real implementation once it lands.
"""

from __future__ import annotations

import json
from typing import Any
from unittest.mock import MagicMock

import pytest
from pydantic import BaseModel, ValidationError
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Business,
    ModelVersion,
    Run,
    RunArtifact,
    RunProgressEvent,
)
from vibe_modeling.backend.version_resolution_parser import (
    STAGE_NAME as VR_STAGE_NAME,
    STEP_NAME as VR_STEP_NAME,
)
from vibe_modeling.backend.services.operations import (
    Operation,
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
    OperationResult,
)


# --------------------------------------------------------------------------
# Primitive import — try the real impl, fall back to a stub that fails the
# test loudly. This is the Skeptical Tester Pattern: on ``main`` (where the
# primitive doesn't exist yet) every test fails by assertion, not by an
# ImportError that tanks the whole module.
# --------------------------------------------------------------------------


try:
    from vibe_modeling.backend.services.operations.vibe_iterate import (  # type: ignore
        VibeIterate,
        VibeIterateParams,
    )
    PRIMITIVE_AVAILABLE = True
except Exception:  # pragma: no cover — STUB-FOR-INTEGRATION
    PRIMITIVE_AVAILABLE = False

    class VibeIterateParams(BaseModel):  # STUB-FOR-INTEGRATION
        # Real schema lives in the dev impl; these tests assert behaviour
        # via the public Operation contract, so the stub only needs to
        # exist as a name.
        pass

    class VibeIterate(Operation):  # STUB-FOR-INTEGRATION
        name = "vibe_iterate"
        params_model = VibeIterateParams
        is_idempotent = True
        produces_version = True

        def dispatch(self, ctx, ws, session):
            raise NotImplementedError(
                "vibe_iterate primitive is not implemented on this branch"
            )

        def observe(self, handle, ctx, ws, session):
            raise NotImplementedError(
                "vibe_iterate primitive is not implemented on this branch"
            )

        def rollback(self, ctx, rollback_state, ws, session):
            raise NotImplementedError(
                "vibe_iterate primitive is not implemented on this branch"
            )


pytestmark = pytest.mark.skipif(
    False,
    reason="vibe_iterate adversarial tests run on main and on dev branch",
)


# --------------------------------------------------------------------------
# Fixtures
# --------------------------------------------------------------------------


@pytest.fixture
def primitive() -> VibeIterate:
    return VibeIterate()


@pytest.fixture
def parent_version(engine, seed_business) -> str:
    """Create a parent ModelVersion the iterate op can derive from."""
    with Session(engine) as s:
        mv = ModelVersion(
            business_id=seed_business,
            version=1,
            status="completed",
            scope="ecm",
            uc_catalog="test_catalog",
        )
        s.add(mv)
        s.commit()
        s.refresh(mv)
        return mv.id


@pytest.fixture
def run_row(engine, seed_business) -> str:
    with Session(engine) as s:
        r = Run(
            business_id=seed_business,
            intent="vibe-iterate",
            status="pending",
            parameters_json="{}",
        )
        s.add(r)
        s.commit()
        s.refresh(r)
        return r.id


def _ctx(
    *,
    run_id: str,
    business_id: str,
    parent_version_id: str | None,
    params: dict | None = None,
    operation_id: str = "op-vibe-1",
) -> OperationContext:
    return OperationContext(
        run_id=run_id,
        operation_id=operation_id,
        business_id=business_id,
        parent_version_id=parent_version_id,
        params=params or {
            "vibe_instructions": "make the customer table denormalised",
            "deployment_catalog": "test_catalog",
        },
        inherited_params={"cataloging_style": "One Catalog"},
    )


# --------------------------------------------------------------------------
# Class-level contract attributes (§2)
# --------------------------------------------------------------------------


def test_class_attributes_match_design_table(primitive):
    """§2 table: vibe_iterate produces a version and is NOT idempotent.

    Per spec §2 ("if True, orchestrator may retry on transient errors")
    plus the reconciliation rubric — creating a new ModelVersion has
    externally-visible non-idempotent effects, so ``is_idempotent`` is
    ``False``. Verifies the primitive ships at the expected import
    location — a stub-from-test cannot satisfy this. Fails on ``main``
    because the module doesn't exist yet.
    """
    assert PRIMITIVE_AVAILABLE, (
        "vibe_modeling.backend.services.operations.vibe_iterate must "
        "exist and export VibeIterate + VibeIterateParams"
    )
    assert primitive.name == "vibe_iterate"
    assert primitive.is_idempotent is False
    assert primitive.produces_version is True
    assert issubclass(primitive.params_model, BaseModel)
    # The class must come from the production module, not the stub.
    assert primitive.__class__.__module__.startswith(
        "vibe_modeling.backend.services.operations"
    ), f"primitive class came from {primitive.__class__.__module__!r}, not the production module"


# --------------------------------------------------------------------------
# 1. Job fails after creating new version → rollback deletes version
#    AND un-supersedes the prior version (status: superseded → completed).
# --------------------------------------------------------------------------


def test_rollback_deletes_new_version_and_unsupersedes_parent(
    engine, primitive, seed_business, parent_version, run_row
):
    """Job failed AFTER materialising a new version → rollback cleans both
    the new MV row and reverts the parent's superseded status to completed.
    """
    with Session(engine) as s:
        # Simulate post-success state: parent superseded by new MV.
        parent = s.exec(select(ModelVersion).where(ModelVersion.id == parent_version)).one()
        parent.status = "superseded"
        s.add(parent)

        new_mv = ModelVersion(
            business_id=seed_business,
            version=2,
            status="completed",
            scope="ecm",
            base_version_id=parent_version,
        )
        s.add(new_mv)
        s.commit()
        s.refresh(new_mv)
        new_mv_id = new_mv.id

    rollback_state = {
        "new_version_id": new_mv_id,
        "superseded_parent_ids": [parent_version],
    }

    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=parent_version,
    )
    with Session(engine) as s:
        primitive.rollback(ctx, rollback_state, MagicMock(), s)
        s.commit()

    with Session(engine) as s:
        gone = s.exec(select(ModelVersion).where(ModelVersion.id == new_mv_id)).first()
        parent_after = s.exec(
            select(ModelVersion).where(ModelVersion.id == parent_version)
        ).one()
    assert gone is None, "new ModelVersion row must be deleted by rollback"
    assert parent_after.status == "completed", (
        "parent.status must revert from 'superseded' to 'completed' after rollback"
    )


# --------------------------------------------------------------------------
# 2. Parent version doesn't exist → params validation OR dispatch surfaces
#    an informative error and leaves no partial state.
# --------------------------------------------------------------------------


def test_dispatch_on_missing_parent_raises_informative_error(
    engine, primitive, seed_business, run_row
):
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id="ghost-version-id-does-not-exist",
    )
    with Session(engine) as s:
        with pytest.raises(Exception) as exc_info:
            primitive.dispatch(ctx, MagicMock(), s)
        assert not isinstance(exc_info.value, NotImplementedError), (
            "dispatch must implement the missing-parent check, not NotImplementedError"
        )
        # The error message must mention what's wrong — opaque KeyError
        # leaves the operator guessing.
        assert any(
            tok in str(exc_info.value).lower()
            for tok in ("parent", "version", "not found", "missing", "unknown")
        ), f"error must mention the missing parent version: {exc_info.value!r}"

        # No partial state — no Run rows mutated to running, no new MV
        # created.
        run_after = s.exec(select(Run).where(Run.id == run_row)).one()
        assert run_after.status in ("pending", "failed"), (
            f"run status must not have advanced to running on dispatch failure: "
            f"{run_after.status}"
        )
        new_versions = s.exec(
            select(ModelVersion).where(ModelVersion.business_id == seed_business)
        ).all()
        # No parent was seeded for this test — dispatch should fail BEFORE
        # creating any new MV row. (The test fixture deliberately does not
        # seed a parent so the impl's missing-parent gate is exercised.)
        assert len(new_versions) == 0


# --------------------------------------------------------------------------
# 3. Vibe instructions > 1800 chars are offloaded to a Volume file.
#    The widget value must be the path, not the inline text.
# --------------------------------------------------------------------------


def test_long_vibe_instructions_offloaded_to_volume(
    engine, primitive, seed_business, parent_version, run_row
):
    long_text = "x" * 2500  # well above VIBE_INSTRUCTIONS_INLINE_LIMIT=1800

    ws = MagicMock()
    # Capture the run_now widget params so we can assert on `model_vibes`.
    captured: dict[str, dict[str, str]] = {}

    def _run_now(**kw):
        captured["notebook_params"] = kw.get("notebook_params") or {}
        m = MagicMock()
        m.response.run_id = 12345
        return m

    ws.jobs.run_now.side_effect = _run_now
    # files.upload returns nothing meaningful; just record calls.
    ws.files.upload = MagicMock()

    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=parent_version,
        params={
            "vibe_instructions": long_text,
            "deployment_catalog": "test_catalog",
        },
    )
    with Session(engine) as s:
        try:
            primitive.dispatch(ctx, ws, s)
        except NotImplementedError:
            pytest.fail("vibe_iterate.dispatch must be implemented")

    # Either: (a) widget value is a `/Volumes/...` path AND files.upload
    # was called, or (b) the dispatch wrote the text to a Volume by some
    # equivalent route and stored the path on Run.vibe_instructions_volume_path.
    widget = (captured.get("notebook_params") or {}).get("model_vibes", "")
    assert ws.files.upload.called, (
        "long instructions must be offloaded via ws.files.upload"
    )
    assert widget.startswith("/Volumes/"), (
        f"widget value must be a Volume path for >1800-char instructions; "
        f"got {widget!r}"
    )
    assert long_text not in widget, (
        "widget value must NOT contain the raw text inline"
    )


# --------------------------------------------------------------------------
# 4. Idempotent dispatch — re-call with the same (run_id, op_id) reuses the
#    existing Databricks run instead of launching a duplicate.
# --------------------------------------------------------------------------


def test_dispatch_normalizes_business_name_for_volume_path(engine, primitive):
    """Regression for run e0af2ac4 (2026-05-07): vibe_iterate stashed the raw
    DB business.name (e.g. ``"Test Retail."``) in ``handle.extra["business_name"]``.

    The observe-side sync interpolates that value verbatim into
    ``/Volumes/{catalog}/_metamodel/vol_root/business/{biz}/{scope}_v{N}/model.json``.
    The agent writes the strip-rule form (``test_retail`` — trailing dot
    stripped, lower+space->_+strip non-alnum/_), so the unsanitized
    lookup 404s and the new ECM version's child rows never land in
    Lakebase.

    Dispatch MUST normalize via ``agent_business_segment`` so the lookup
    matches the agent's path exactly.
    """
    with Session(engine) as s:
        biz = Business(
            name="Test Retail.",
            description="Tricky name with space + trailing dot",
            industry_alignment="Retail",
        )
        s.add(biz)
        s.commit()
        s.refresh(biz)
        biz_id = biz.id

        parent = ModelVersion(
            business_id=biz_id, version=1, status="completed",
            scope="ecm", uc_catalog="vibe_modeling_test",
        )
        s.add(parent)
        s.commit()
        s.refresh(parent)
        parent_id = parent.id

        run = Run(
            business_id=biz_id, intent="vibe-new-ecm-mvm",
            status="pending", parameters_json="{}",
        )
        s.add(run)
        s.commit()
        s.refresh(run)
        run_id = run.id

    ws = MagicMock()
    m = MagicMock()
    m.response.run_id = 99999
    ws.jobs.run_now.return_value = m

    ctx = _ctx(
        run_id=run_id,
        business_id=biz_id,
        parent_version_id=parent_id,
        params={
            "vibe_instructions": "test normalization",
            "deployment_catalog": "vibe_modeling_test",
        },
    )

    with Session(engine) as s:
        handle = primitive.dispatch(ctx, ws, s)

    assert isinstance(handle, OperationDispatchHandle)
    assert handle.extra is not None
    assert handle.extra.get("business_name") == "test_retail", (
        "vibe_iterate.dispatch must store the agent-style normalized "
        "business name in extra['business_name'] (lowercase, spaces->_, "
        "non-alnum/_ stripped — trailing dot is removed). The downstream "
        f"Volume lookup interpolates this value verbatim. Got: "
        f"{handle.extra.get('business_name')!r}"
    )


@pytest.mark.parametrize("parent_scope,expected_label", [
    ("ecm", "Expanded Coverage Model - ECM"),
    ("mvm", "Minimum Viable Model - MVM"),
])
def test_dispatch_scope_follows_parent_version(engine, primitive, parent_scope, expected_label):
    """A vibe-iterate must dispatch the PARENT version's scope, not the
    model_size default (which would send MVM and hard-fail the agent on an
    ECM-only version with "Version 'N' with model_scope 'mvm' does not exist").
    model_size is left at its default here, so a passing ECM case proves the
    parent scope overrides the model_size-derived label."""
    with Session(engine) as s:
        biz = Business(name=f"Scope {parent_scope} Co", description="d",
                       industry_alignment="Retail")
        s.add(biz)
        s.commit()
        s.refresh(biz)
        biz_id = biz.id
        parent = ModelVersion(
            business_id=biz_id, version=1, status="completed",
            scope=parent_scope, uc_catalog="vibe_modeling_test",
        )
        s.add(parent)
        s.commit()
        s.refresh(parent)
        parent_id = parent.id
        run = Run(business_id=biz_id, intent="vibe-iterate", status="pending",
                  parameters_json="{}")
        s.add(run)
        s.commit()
        s.refresh(run)
        run_id = run.id

    ws = MagicMock()
    m = MagicMock()
    m.response.run_id = 4242
    ws.jobs.run_now.return_value = m

    ctx = _ctx(
        run_id=run_id, business_id=biz_id, parent_version_id=parent_id,
        params={"vibe_instructions": "iterate it", "deployment_catalog": "vibe_modeling_test"},
    )
    with Session(engine) as s:
        primitive.dispatch(ctx, ws, s)

    notebook_params = ws.jobs.run_now.call_args.kwargs["notebook_params"]
    assert notebook_params["data_model_scopes"] == expected_label


# --------------------------------------------------------------------------
# 5. Concurrent observe() calls return consistent snapshots.
# --------------------------------------------------------------------------


def test_observe_concurrent_calls_consistent(
    engine, primitive, seed_business, parent_version, run_row
):
    """Two observe() calls in quick succession against the same handle
    must return the same is_terminal verdict (no race on terminal_result).
    """
    ws = MagicMock()
    state = MagicMock()
    state.life_cycle_state.value = "RUNNING"
    state.result_state.value = ""
    job_run = MagicMock()
    job_run.state = state
    ws.jobs.get_run.return_value = job_run

    handle = OperationDispatchHandle(
        databricks_run_id=12345, vibe_session_id="sess-1"
    )
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=parent_version,
    )
    with Session(engine) as s:
        obs1 = primitive.observe(handle, ctx, ws, s)
        obs2 = primitive.observe(handle, ctx, ws, s)

    assert obs1.is_terminal == obs2.is_terminal
    if obs1.is_terminal:
        assert obs1.terminal_result is not None
        assert obs2.terminal_result is not None
        assert obs1.terminal_result.succeeded == obs2.terminal_result.succeeded


# --------------------------------------------------------------------------
# 6. Job succeeds but model.json missing → succeeded=False, no version.
# --------------------------------------------------------------------------


def test_job_success_but_model_json_missing(
    monkeypatch, engine, primitive, seed_business, parent_version, run_row
):
    # _fetch_model_json retries with exponential backoff: 1+2+4+8=15s.
    # Mock time.sleep so the 5-attempt retry loop completes instantly.
    monkeypatch.setattr(
        "vibe_modeling.backend.services.operations.vibe_iterate.time.sleep",
        lambda *_a, **_kw: None,
    )

    ws = MagicMock()
    state = MagicMock()
    state.life_cycle_state.value = "TERMINATED"
    state.result_state.value = "SUCCESS"
    ws.jobs.get_run.return_value = MagicMock(state=state)

    # Simulate model.json not present — files.download raises.
    ws.files.download.side_effect = Exception("not found: model.json")

    handle = OperationDispatchHandle(
        databricks_run_id=42, vibe_session_id="sess-x"
    )
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=parent_version,
    )
    with Session(engine) as s:
        obs = primitive.observe(handle, ctx, ws, s)
        s.commit()
        assert obs.is_terminal is True
        assert obs.terminal_result is not None
        assert obs.terminal_result.succeeded is False, (
            "missing model.json must produce succeeded=False"
        )
        assert obs.terminal_result.output_version_id is None
        assert obs.terminal_result.error
        # No new ModelVersion rows.
        new = s.exec(
            select(ModelVersion).where(
                ModelVersion.business_id == seed_business,
                ModelVersion.id != parent_version,
            )
        ).all()
        assert new == []


# --------------------------------------------------------------------------
# 7. Lakebase sync fails after agent succeeded → succeeded=True (artifact
#    is in Volume), but version's sync indicator is failed; rollback
#    deletes the version.
# --------------------------------------------------------------------------


def test_lakebase_sync_failure_after_agent_success_rolls_back_version(
    engine, primitive, seed_business, parent_version, run_row
):
    """Build the post-success state where a new version exists but sync
    failed. Calling rollback() with the persisted rollback_state must
    delete the version row.
    """
    with Session(engine) as s:
        # Simulate the version was created during observe(), then sync failed.
        new_mv = ModelVersion(
            business_id=seed_business,
            version=2,
            status="failed",  # the post-observe code path marked it failed
            scope="ecm",
            base_version_id=parent_version,
        )
        s.add(new_mv)
        s.commit()
        s.refresh(new_mv)
        new_mv_id = new_mv.id

    rollback_state = {
        "new_version_id": new_mv_id,
        "superseded_parent_ids": [],
    }
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=parent_version,
    )
    with Session(engine) as s:
        primitive.rollback(ctx, rollback_state, MagicMock(), s)
        s.commit()

    with Session(engine) as s:
        still_there = s.exec(
            select(ModelVersion).where(ModelVersion.id == new_mv_id)
        ).first()
    assert still_there is None, (
        "rollback must delete the failed-sync version even though the agent "
        "succeeded (the artifact in Volume is the durable record)"
    )


# --------------------------------------------------------------------------
# 8. params_model rejects empty/whitespace vibe_instructions.
# --------------------------------------------------------------------------


def test_params_model_rejects_empty_vibe_instructions():
    with pytest.raises(ValidationError):
        VibeIterateParams(vibe_instructions="", deployment_catalog="cat_one")


def test_params_model_rejects_whitespace_vibe_instructions():
    with pytest.raises(ValidationError):
        VibeIterateParams(vibe_instructions="   \t\n  ", deployment_catalog="cat_one")


# --------------------------------------------------------------------------
# 9. params_model accepts a reasonable instructions string.
# --------------------------------------------------------------------------


def test_params_model_accepts_reasonable_instructions():
    p = VibeIterateParams(
        vibe_instructions="add a customer dimension and link it to orders",
        deployment_catalog="cat_one",
    )
    assert p.vibe_instructions  # non-empty after model post-init


# --------------------------------------------------------------------------
# 10. Rollback is idempotent — replay against an already-rolled-back state
#     is a no-op, never raises.
# --------------------------------------------------------------------------


def test_rollback_is_idempotent(
    engine, primitive, seed_business, parent_version, run_row
):
    # State references a version_id that does NOT exist (already deleted).
    rollback_state = {
        "new_version_id": "already-gone-id",
        "superseded_parent_ids": [parent_version],
    }
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=parent_version,
    )
    with Session(engine) as s:
        # Must not raise — §2 invariant: rollback is idempotent.
        primitive.rollback(ctx, rollback_state, MagicMock(), s)
        primitive.rollback(ctx, rollback_state, MagicMock(), s)


# --------------------------------------------------------------------------
# 11. Inline (≤1800-char) instructions are passed through directly without
#     hitting the Volume.
# --------------------------------------------------------------------------


def test_short_instructions_pass_inline(
    engine, primitive, seed_business, parent_version, run_row
):
    short_text = "rename customer to client"
    ws = MagicMock()
    captured: dict[str, dict[str, str]] = {}

    def _run_now(**kw):
        captured["notebook_params"] = kw.get("notebook_params") or {}
        m = MagicMock()
        m.response.run_id = 222
        return m

    ws.jobs.run_now.side_effect = _run_now
    ws.files.upload = MagicMock()

    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=parent_version,
        params={
            "vibe_instructions": short_text,
            "deployment_catalog": "test_catalog",
        },
    )
    with Session(engine) as s:
        primitive.dispatch(ctx, ws, s)

    assert not ws.files.upload.called, (
        "short instructions must NOT trigger a Volume upload"
    )
    widget = (captured.get("notebook_params") or {}).get("model_vibes", "")
    assert widget == short_text, (
        f"widget should carry inline text verbatim; got {widget!r}"
    )


# --------------------------------------------------------------------------
# 12. Output artifacts on success include a model.json entry.
# --------------------------------------------------------------------------


def test_terminal_success_uses_agent_resolved_version_when_collision_event_present(
    engine, primitive, seed_business, parent_version, run_row
):
    """Sibling-site coverage for `_generation_common._terminal_success`'s
    agent-Version-Resolution override (see backend.version_resolution_parser).

    When the agent emits a `Version Collision Auto-Resolved` event mid-run,
    vibe_iterate's observe path must consult `lookup_resolved_version` AFTER
    `next_version_for_scope` and apply the agent's chosen ordinal — otherwise
    the persisted ModelVersion.version drifts from the Volume folder the
    agent actually wrote (2026-05-04 the test workspace incident).
    """
    with Session(engine) as s:
        s.add(RunProgressEvent(
            run_id=run_row,
            step_id=1,
            event_seq=42,
            stage_name=VR_STAGE_NAME,
            step_name=VR_STEP_NAME,
            status="stage_warning",
            message="Version collision: v2 (ecm) already exists. Auto-assigned v7 (ecm).",
            progress_increment=0.0,
            result_json=json.dumps({
                "original_target": 2,
                "new_target": 7,
                "target_scope": "ecm",
                "source_version": 1,
                "source_scope": "ecm",
            }),
        ))
        s.commit()

    ws = MagicMock()
    state = MagicMock()
    state.life_cycle_state.value = "TERMINATED"
    state.result_state.value = "SUCCESS"
    ws.jobs.get_run.return_value = MagicMock(state=state)
    body = json.dumps({
        "model": {
            "type": "business", "name": "test", "version": "v7_ecm",
            "description": "x", "domains": [],
        }
    }).encode("utf-8")
    download = MagicMock()
    download.contents.read.return_value = body
    ws.files.download.return_value = download

    handle = OperationDispatchHandle(
        databricks_run_id=99, vibe_session_id="sess-vr-override"
    )
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=parent_version,
    )
    with Session(engine) as s:
        obs = primitive.observe(handle, ctx, ws, s)
        assert obs.is_terminal and obs.terminal_result and obs.terminal_result.succeeded
        new_mv = s.get(ModelVersion, obs.terminal_result.output_version_id)
        assert new_mv is not None
        assert new_mv.version == 7, (
            f"vibe_iterate observe must apply agent Version Resolution "
            f"override; expected v7 (agent-resolved), got v{new_mv.version}"
        )
        assert new_mv.scope == "ecm"


def test_terminal_success_result_includes_model_json_artifact(
    engine, primitive, seed_business, parent_version, run_row
):
    """When the agent terminates SUCCESS and model.json is fetchable,
    OperationResult.output_artifacts must list the model.json path.
    """
    ws = MagicMock()
    state = MagicMock()
    state.life_cycle_state.value = "TERMINATED"
    state.result_state.value = "SUCCESS"
    ws.jobs.get_run.return_value = MagicMock(state=state)

    # Provide a minimal valid model.json blob via files.download so the
    # impl can complete the success path.
    body = json.dumps({
        "model": {
            "type": "business",
            "name": "test",
            "version": "v1_ecm",
            "description": "x",
            "domains": [],
        }
    }).encode("utf-8")

    download = MagicMock()
    download.contents.read.return_value = body
    ws.files.download.return_value = download

    handle = OperationDispatchHandle(
        databricks_run_id=99, vibe_session_id="sess-success"
    )
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=parent_version,
    )
    with Session(engine) as s:
        obs = primitive.observe(handle, ctx, ws, s)

    if obs.is_terminal and obs.terminal_result and obs.terminal_result.succeeded:
        types = {a.get("artifact_type") for a in obs.terminal_result.output_artifacts}
        assert any("model" in (t or "").lower() or "json" in (t or "").lower()
                   for t in types), (
            f"on success, artifacts must include model.json; got {types!r}"
        )
        assert obs.terminal_result.output_version_id is not None, (
            "produces_version=True ⇒ output_version_id must be set on success"
        )


def test_terminal_success_never_stamps_deployed_even_with_catalog(
    engine, primitive, seed_business, parent_version, run_row
):
    """Regression (0.6.6 walkthrough, live-confirmed). vibe_iterate only
    rewrites DDL/model artifacts in Lakebase/Volumes; it never performs a
    physical UC install, unlike the generation primitives whose agent job
    inline-installs (Stages 12-14) for every cataloging_style. A prior
    version of this primitive stamped ``deployment_status="deployed"``
    whenever ``deployment_catalog`` was present, which lied about reality:
    a version was born "deployed" with completion_date set and no install
    ever run against it. Track 4's catalog-drift reconciler immediately
    (and correctly) found the expected schemas missing and flipped it to
    "uninstalled", a state that should never have existed per the
    state-atomicity rule (never create a state reconcile has to mop up).

    ``_ctx``'s default params include a non-empty ``deployment_catalog``,
    which is exactly the condition that used to trigger the bogus
    "deployed" stamp. The output version must be "draft" regardless.
    """
    ws = MagicMock()
    state = MagicMock()
    state.life_cycle_state.value = "TERMINATED"
    state.result_state.value = "SUCCESS"
    ws.jobs.get_run.return_value = MagicMock(state=state)

    body = json.dumps({
        "model": {
            "type": "business", "name": "test", "version": "v2_ecm",
            "description": "x", "domains": [],
        }
    }).encode("utf-8")
    download = MagicMock()
    download.contents.read.return_value = body
    ws.files.download.return_value = download

    handle = OperationDispatchHandle(
        databricks_run_id=99,
        vibe_session_id="sess-no-lie",
        extra={"deployment_catalog": "test_catalog"},
    )
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=parent_version,
        params={
            "vibe_instructions": "make the customer table denormalised",
            "deployment_catalog": "test_catalog",
        },
    )
    with Session(engine) as s:
        obs = primitive.observe(handle, ctx, ws, s)
        assert obs.is_terminal and obs.terminal_result and obs.terminal_result.succeeded
        new_mv = s.get(ModelVersion, obs.terminal_result.output_version_id)
        assert new_mv is not None
        assert new_mv.deployment_status == "draft", (
            "vibe_iterate must never stamp deployment_status='deployed' at "
            f"finalize (it doesn't install to UC); got {new_mv.deployment_status!r}"
        )
        # The resolved catalog is still recorded (it's where an explicit
        # `install` run would target), just not treated as already live.
        assert new_mv.uc_catalog == "test_catalog"


# --------------------------------------------------------------------------
# TestRollbackAdversarial — rollback edge cases per design doc §2 + §10.
#
# vibe_iterate rollback contract (§10): "Job fails after creating new
# version → rollback deletes version, un-supersedes prior".
#
# Adversarial scenarios:
#   1. Rollback replay (idempotency invariant from §2).
#   2. Dependent ModelVersion already deleted between dispatch and rollback.
#   3. Rollback raises mid-execution → orchestrator's _rollback_one catches.
#   4. Un-supersede works — parent's prior status is restored, never orphaned.
# --------------------------------------------------------------------------


class TestRollbackAdversarial:
    """Adversarial rollback cases for vibe_iterate.

    All tests use the in-memory SQLite ``engine`` fixture and a
    :class:`MagicMock` ``WorkspaceClient``. No network, no Databricks.
    Per ``services/orchestrator/_runner.py::_rollback_one``, a rollback
    that raises is caught by the orchestrator and the chain halts — so
    "rollback raises" is the contract for surfacing mid-execution
    failures, not a bug.
    """

    def test_rollback_idempotent_under_replay(
        self, engine, primitive, seed_business, parent_version, run_row
    ):
        """§2 invariant: replaying ``rollback`` against an already-rolled-back
        op MUST be a no-op, not an error."""
        with Session(engine) as s:
            parent = s.exec(
                select(ModelVersion).where(ModelVersion.id == parent_version)
            ).one()
            parent.status = "superseded"
            s.add(parent)
            new_mv = ModelVersion(
                business_id=seed_business,
                version=2,
                status="completed",
                scope="ecm",
                base_version_id=parent_version,
            )
            s.add(new_mv)
            s.commit()
            s.refresh(new_mv)
            new_mv_id = new_mv.id

        rollback_state = {
            "new_version_id": new_mv_id,
            "parent_version_id": parent_version,
            "parent_prior_status": "completed",
        }
        ctx = _ctx(
            run_id=run_row,
            business_id=seed_business,
            parent_version_id=parent_version,
        )
        with Session(engine) as s:
            # First call — does the work.
            primitive.rollback(ctx, rollback_state, MagicMock(), s)
            s.commit()
            # Second call — must not raise; nothing left to do.
            primitive.rollback(ctx, rollback_state, MagicMock(), s)
            s.commit()

    def test_rollback_when_dependent_version_already_deleted(
        self, engine, primitive, seed_business, parent_version, run_row
    ):
        """Between dispatch and rollback, the new ModelVersion may already
        be gone (raced with another rollback, manual cleanup, etc.).
        Rollback against a state with a missing target row must succeed."""
        rollback_state = {
            "new_version_id": "deleted-already-id-9999",
            "parent_version_id": parent_version,
            "parent_prior_status": "completed",
        }
        ctx = _ctx(
            run_id=run_row,
            business_id=seed_business,
            parent_version_id=parent_version,
        )
        with Session(engine) as s:
            # Must NOT raise — design doc §2 idempotency invariant.
            primitive.rollback(ctx, rollback_state, MagicMock(), s)
            s.commit()

    def test_rollback_unsupersede_parent_restores_prior_status(
        self, engine, primitive, seed_business, parent_version, run_row
    ):
        """vibe_iterate-specific: if rollback orphans the parent (leaves it
        ``superseded`` after the new version is gone), that's a bug.
        The parent's prior status must be restored.
        """
        with Session(engine) as s:
            parent = s.exec(
                select(ModelVersion).where(ModelVersion.id == parent_version)
            ).one()
            parent.status = "superseded"
            s.add(parent)
            new_mv = ModelVersion(
                business_id=seed_business,
                version=2,
                status="completed",
                scope="ecm",
                base_version_id=parent_version,
            )
            s.add(new_mv)
            s.commit()
            s.refresh(new_mv)
            new_mv_id = new_mv.id

        rollback_state = {
            "new_version_id": new_mv_id,
            "parent_version_id": parent_version,
            "parent_prior_status": "completed",
        }
        ctx = _ctx(
            run_id=run_row,
            business_id=seed_business,
            parent_version_id=parent_version,
        )
        with Session(engine) as s:
            primitive.rollback(ctx, rollback_state, MagicMock(), s)
            s.commit()

        with Session(engine) as s:
            parent_after = s.exec(
                select(ModelVersion).where(ModelVersion.id == parent_version)
            ).one()
            new_after = s.exec(
                select(ModelVersion).where(ModelVersion.id == new_mv_id)
            ).first()
        assert new_after is None, "rollback must delete the new version"
        assert parent_after.status == "completed", (
            "rollback must restore the parent's prior status, not leave it "
            f"orphaned as 'superseded'; got {parent_after.status!r}"
        )

    def test_rollback_propagates_underlying_exception(
        self, monkeypatch, engine, primitive, seed_business, parent_version, run_row
    ):
        """When the rollback's underlying call raises (e.g. session.delete
        blew up), the exception must propagate so the orchestrator's
        ``_rollback_one`` can catch it (per
        ``services/orchestrator/_runner.py::_rollback_one``).

        The runner wraps rollback in a try/except: a rollback that swallows
        its own errors silently would leave the orchestrator thinking the
        chain succeeded when it didn't. Re-raising is the contract.
        """
        with Session(engine) as s:
            new_mv = ModelVersion(
                business_id=seed_business,
                version=2,
                status="completed",
                scope="ecm",
                base_version_id=parent_version,
            )
            s.add(new_mv)
            s.commit()
            s.refresh(new_mv)
            new_mv_id = new_mv.id

        rollback_state = {
            "new_version_id": new_mv_id,
            "parent_version_id": parent_version,
            "parent_prior_status": "completed",
        }
        ctx = _ctx(
            run_id=run_row,
            business_id=seed_business,
            parent_version_id=parent_version,
        )

        # Patch session.delete to blow up — simulate a Lakebase-side error
        # while removing the ModelVersion row.
        class _BoomSession:
            def __init__(self, real):
                self._real = real

            def __getattr__(self, name):
                return getattr(self._real, name)

            def get(self, *a, **kw):
                return self._real.get(*a, **kw)

            def delete(self, *a, **kw):
                raise RuntimeError("simulated DB delete failure")

            def flush(self, *a, **kw):
                return self._real.flush(*a, **kw)

            def add(self, *a, **kw):
                return self._real.add(*a, **kw)

        with Session(engine) as s:
            boom = _BoomSession(s)
            with pytest.raises(RuntimeError) as exc_info:
                primitive.rollback(ctx, rollback_state, MagicMock(), boom)
            # Must surface a meaningful error message — the orchestrator
            # uses ``f"{type(e).__name__}: {e}"`` to record it on the run.
            assert "delete" in str(exc_info.value).lower() or "fail" in str(
                exc_info.value
            ).lower()
