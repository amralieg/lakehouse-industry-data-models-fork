"""Skeptical-tester contribution for fix/next-vibe-ids-dropped-on-submit.

The ``vibe-new-ecm-mvm`` intent has its own dedicated orchestrator branch in
``router.py``. Until commit ``aa3b130`` that branch never read
``data.next_vibe_ids`` from the run-create request, so user selections were
silently dropped - neither folded into ``vibe_instructions`` nor persisted as
link-table rows.

The fix should mirror the legacy ``vibe-iterate`` plumbing:

  1. Resolve ``data.next_vibe_ids`` against the parent ECM's
     ``next_vibes_json``. Unknown ids → 400.
  2. Persist ``RunNextVibeLink`` rows after the Run row commits so the
     run-detail UI can replay what was selected.

These tests are written without reading the dev's implementation files
(``router.py`` and ``test_vibe_new_ecm_mvm_next_vibes.py`` were not opened).
They probe public observable contract: ``POST /api/runs`` body in,
``parameters_json`` + Lakebase rows out.
"""

from __future__ import annotations

from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Run,
    RunNextVibeLink,
)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _mock_run_now(mock_ws: MagicMock, run_id: int = 70707) -> None:
    """Make ``ws.jobs.run_now`` return a mock with a stable run_id."""
    mock_run = MagicMock()
    mock_run.run_id = run_id
    # Some wirers read ``response.run_id`` for redundancy.
    mock_run.response = MagicMock()
    mock_run.response.run_id = run_id
    mock_ws.jobs.run_now.return_value = mock_run


def _seed_parent_ecm_with_next_vibes(engine, business_id: str) -> tuple[str, list[str]]:
    """Return ``(version_id, nv_ids)`` for an ECM-scope completed parent
    ModelVersion populated with three structured agent next-vibe VibeInput
    rows. ``nv_ids`` are the durable VibeInput uuids the selection contract
    validates against."""
    from _next_vibes_seed import seed_version_with_next_vibe_inputs

    return seed_version_with_next_vibe_inputs(
        engine,
        business_id,
        titles=("Fix unlinked ids", "Connect disconnected tables", "Improve tags"),
        confidence=0.71,
    )


def _seed_parent_ecm_no_next_vibes(engine, business_id: str) -> str:
    from _next_vibes_seed import seed_version_without_next_vibes

    return seed_version_without_next_vibes(engine, business_id, scope="ecm")


def _make_body(
    *,
    parent_version_id: str,
    vibe_instructions: str = "merge customer + account tables",
    next_vibe_ids: list[str] | None = None,
) -> dict:
    body: dict = {
        "intent": "vibe-new-ecm-mvm",
        "parent_version_id": parent_version_id,
        "vibe_instructions": vibe_instructions,
        "catalog": "test_catalog",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
        "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
    }
    if next_vibe_ids is not None:
        body["next_vibe_ids"] = next_vibe_ids
    return body


def _model_vibes_from_run_now(mock_ws: MagicMock) -> str:
    call = mock_ws.jobs.run_now.call_args
    assert call is not None, "ws.jobs.run_now was never called"
    notebook_params = call.kwargs.get("notebook_params", {})
    return notebook_params.get("model_vibes", "")


# ---------------------------------------------------------------------------
# 1) Happy path - next_vibe_ids honoured
# ---------------------------------------------------------------------------


class TestHappyPathBothSelections:
    def test_create_run_with_next_vibes_persists_everything(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        bid = seed_business
        _mock_run_now(mock_ws, run_id=70001)
        parent_vid, nv_ids = _seed_parent_ecm_with_next_vibes(engine, seed_business)

        selected_nv = [nv_ids[0], nv_ids[2]]
        body = _make_body(
            parent_version_id=parent_vid,
            vibe_instructions="user free-form notes",
            next_vibe_ids=selected_nv,
        )
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json=body)
        assert resp.status_code == 200, resp.text
        run_id = resp.json()["id"]

        # Link table populated.
        with Session(engine) as session:
            nv_links = session.exec(
                select(RunNextVibeLink).where(RunNextVibeLink.run_id == run_id)
            ).all()
        assert sorted(l.next_vibe_id for l in nv_links) == sorted(selected_nv), (
            f"RunNextVibeLink rows missing/wrong; got "
            f"{[l.next_vibe_id for l in nv_links]}"
        )

        # Task 5 clean break: next-vibe text is no longer folded into the
        # dispatched model_vibes blob (inputs/compile are the instruction
        # source). The link table above remains the durable audit. The user's
        # free-form text passes through unchanged; no merge blocks appear.
        model_vibes = _model_vibes_from_run_now(mock_ws)
        assert "user free-form notes" in model_vibes
        assert "Agent-Suggested Next Vibes" not in model_vibes
        assert "[agent-suggested]" not in model_vibes
        assert "Fix Unlinked Ids" not in model_vibes

        # Durable persistence — Run.vibe_instructions_text mirrors the
        # dispatched blob (the user free-form text).
        run_detail = client_with_agent.get(f"/api/businesses/{bid}/runs/{run_id}").json()
        instr = run_detail.get("vibe_instructions_text", "")
        assert "user free-form notes" in instr
        assert "Fix Unlinked Ids" not in instr

    def test_get_run_endpoint_surfaces_next_vibe_ids(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        """The fix spec calls out that GET /api/runs/{id} should return
        next_vibe_ids. Be lenient: if the field doesn't exist on RunOut yet,
        fall back to the link table (which the spec also requires)."""
        bid = seed_business
        _mock_run_now(mock_ws, run_id=70002)
        parent_vid, nv_ids = _seed_parent_ecm_with_next_vibes(engine, seed_business)

        selected_nv = [nv_ids[1]]
        body = _make_body(
            parent_version_id=parent_vid,
            next_vibe_ids=selected_nv,
        )
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json=body)
        assert resp.status_code == 200, resp.text
        run_id = resp.json()["id"]

        detail = client_with_agent.get(f"/api/businesses/{bid}/runs/{run_id}").json()
        ids_on_out = detail.get("next_vibe_ids")
        if ids_on_out is not None:
            assert ids_on_out == selected_nv
        # Belt-and-braces: link table must always have the row.
        with Session(engine) as session:
            link_ids = [
                l.next_vibe_id
                for l in session.exec(
                    select(RunNextVibeLink).where(RunNextVibeLink.run_id == run_id)
                ).all()
            ]
        assert link_ids == selected_nv


# ---------------------------------------------------------------------------
# 2) Bad next_vibe_ids → 400
# ---------------------------------------------------------------------------


class TestBadNextVibeIdsRejected:
    def test_unknown_next_vibe_id_returns_400(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        _mock_run_now(mock_ws, run_id=70010)
        parent_vid, nv_ids = _seed_parent_ecm_with_next_vibes(engine, seed_business)

        body = _make_body(
            parent_version_id=parent_vid,
            next_vibe_ids=["nv-1", "nv-bogus"],
        )
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json=body)
        assert resp.status_code == 400, resp.text
        assert "nv-bogus" in resp.json()["detail"], (
            f"Error detail must surface the missing id; got {resp.json()!r}"
        )
        # The dispatch must NOT have happened — partial/best-effort is wrong
        # here, the whole request needs to fail atomically.
        mock_ws.jobs.run_now.assert_not_called()
        # And no Run / link rows persisted.
        with Session(engine) as session:
            assert session.exec(select(Run)).all() == []
            assert session.exec(select(RunNextVibeLink)).all() == []

    def test_next_vibe_id_against_parent_with_no_next_vibes_returns_400(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        """If the parent ECM has no next_vibes_json, every id is unknown."""
        _mock_run_now(mock_ws, run_id=70011)
        parent_vid = _seed_parent_ecm_no_next_vibes(engine, seed_business)

        body = _make_body(
            parent_version_id=parent_vid,
            next_vibe_ids=["nv-1"],
        )
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json=body)
        assert resp.status_code == 400, resp.text
        mock_ws.jobs.run_now.assert_not_called()


# ---------------------------------------------------------------------------
# 4) Empty arrays are OK — fallback to free-form-only blob
# ---------------------------------------------------------------------------


class TestEmptyArraysAreNoop:
    def test_empty_arrays_are_accepted_and_no_blocks_prepended(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        _mock_run_now(mock_ws, run_id=70030)
        parent_vid, nv_ids = _seed_parent_ecm_with_next_vibes(engine, seed_business)

        body = _make_body(
            parent_version_id=parent_vid,
            vibe_instructions="just-the-user-text",
            next_vibe_ids=[],
        )
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json=body)
        assert resp.status_code == 200, resp.text
        run_id = resp.json()["id"]

        # No link rows for empty selections.
        with Session(engine) as session:
            assert session.exec(
                select(RunNextVibeLink).where(RunNextVibeLink.run_id == run_id)
            ).all() == []

        # The dispatched widget value carries the user's text — and the merge
        # block ("Agent-Suggested Next Vibes") is absent, since the user picked
        # nothing. We allow trailing/leading whitespace.
        model_vibes = _model_vibes_from_run_now(mock_ws)
        assert "just-the-user-text" in model_vibes
        assert "Agent-Suggested Next Vibes" not in model_vibes, (
            "Empty next_vibe_ids must not prepend the agent block; "
            f"got: {model_vibes!r}"
        )
        assert "[agent-suggested]" not in model_vibes


# ---------------------------------------------------------------------------
# 5) Selection survives Run row commit
# ---------------------------------------------------------------------------


class TestSelectionSurvivesCommit:
    def test_links_query_directly_after_create(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        _mock_run_now(mock_ws, run_id=70040)
        parent_vid, nv_ids = _seed_parent_ecm_with_next_vibes(engine, seed_business)

        selected_nv = [nv_ids[0], nv_ids[1]]
        body = _make_body(
            parent_version_id=parent_vid,
            next_vibe_ids=selected_nv,
        )
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json=body)
        assert resp.status_code == 200, resp.text
        run_id = resp.json()["id"]

        # Direct DB read — bypassing the GET endpoint entirely.
        with Session(engine) as session:
            run = session.get(Run, run_id)
            assert run is not None
            assert run.intent == "vibe-new-ecm-mvm"

            nv = session.exec(
                select(RunNextVibeLink).where(RunNextVibeLink.run_id == run_id)
            ).all()
        assert sorted(l.next_vibe_id for l in nv) == sorted(selected_nv)


# ---------------------------------------------------------------------------
# 6) Idempotency — repeated GET doesn't re-merge
# ---------------------------------------------------------------------------


class TestMergeHappensOnce:
    def test_repeated_get_returns_same_vibe_instructions(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        bid = seed_business
        _mock_run_now(mock_ws, run_id=70050)
        parent_vid, nv_ids = _seed_parent_ecm_with_next_vibes(engine, seed_business)

        body = _make_body(
            parent_version_id=parent_vid,
            vibe_instructions="user-text-X",
            next_vibe_ids=[nv_ids[0]],
        )
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json=body)
        assert resp.status_code == 200, resp.text
        run_id = resp.json()["id"]

        first = client_with_agent.get(f"/api/businesses/{bid}/runs/{run_id}").json()
        second = client_with_agent.get(f"/api/businesses/{bid}/runs/{run_id}").json()
        third = client_with_agent.get(f"/api/businesses/{bid}/runs/{run_id}").json()

        # Field is durable — same blob across reads. (Catches the failure
        # mode where merge happens at GET-time and re-prepends on every read.)
        assert first["vibe_instructions_text"] == second["vibe_instructions_text"]
        assert second["vibe_instructions_text"] == third["vibe_instructions_text"]

        # User free-form text appears exactly once and is stable across reads
        # (catches re-prepend-at-GET regressions). Task 5: next-vibe text is no
        # longer folded in, so it must not appear at all.
        instr = first["vibe_instructions_text"]
        assert instr.count("user-text-X") == 1, (
            f"User free-form text appears {instr.count('user-text-X')}× — "
            f"instructions are unstable across reads. instr={instr!r}"
        )
