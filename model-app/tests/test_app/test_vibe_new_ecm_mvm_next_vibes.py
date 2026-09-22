"""Regression — `vibe-new-ecm-mvm` must fold next_vibe_ids into the run.

The new combined intent (`vibe-new-ecm-mvm`) takes a dedicated orchestrator
branch in ``router.py`` (``_create_vibe_new_ecm_mvm_run_via_orchestrator``)
that, prior to this fix, **never read ``data.next_vibe_ids``**. The legacy
fold + RunNextVibeLink persistence lives in the simple-intent branch below
the early ``return`` for ``VIBE_NEW_ECM_MVM`` — so any user who picked
agent-suggested next-vibes on the New Run form for the combined intent saw
their selection silently dropped on submit.

The FE wires `next_vibe_ids` correctly (verified by the matching vitest
under ``runs-new-next-vibes-submission.test.tsx``); the bug was the BE
short-circuit. This test asserts the BE end-to-end contract:

  POST /runs {intent="vibe-new-ecm-mvm", next_vibe_ids=[…]} →
    - 200 OK
    - Run.vibe_instructions_text contains the expanded next-vibes block
    - RunNextVibeLink rows persisted for traceability
"""

from __future__ import annotations

import sys
import os
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from vibe_modeling.backend.db_models import (  # noqa: E402
    Run,
    RunNextVibeLink,
)


def _mock_run_now(mock_ws: MagicMock, run_id: int = 7777) -> None:
    mock_run = MagicMock()
    mock_run.run_id = run_id
    mock_ws.jobs.run_now.return_value = mock_run


@pytest.fixture
def parent_ecm_with_next_vibes(engine, seed_business) -> tuple[str, str, list[str]]:
    """Seed a completed ECM-scope ModelVersion with three structured agent
    next-vibe VibeInput rows. Returns ``(business_id, version_id, nv_ids)``
    where ``nv_ids`` are the durable VibeInput uuids the selection contract
    validates against."""
    from _next_vibes_seed import seed_version_with_next_vibe_inputs

    version_id, nv_ids = seed_version_with_next_vibe_inputs(
        engine,
        seed_business,
        titles=("Tag missing pks", "Fill descriptions", "Add fk to orders"),
        confidence=0.70,
    )
    return seed_business, version_id, nv_ids


def _post_body(
    *,
    business_id: str,
    parent_version_id: str,
    next_vibe_ids: list[str],
    vibe_instructions: str = "Re-vibe ECM, then shrink to MVM.",
) -> dict:
    return {
        "intent": "vibe-new-ecm-mvm",
        "parent_version_id": parent_version_id,
        "vibe_instructions": vibe_instructions,
        "catalog": "test_catalog",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
        "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        "next_vibe_ids": next_vibe_ids,
    }


class TestVibeNewEcmMvmFoldsNextVibes:
    """The vibe-new-ecm-mvm orchestrator branch must mirror vibe-iterate's
    next-vibe handling: validate + fold + persist links."""

    def test_selected_next_vibes_linked_but_not_folded(
        self, client_with_agent, mock_ws, engine, parent_ecm_with_next_vibes
    ):
        """Task 5 clean break: next-vibe selections are still validated +
        linked (RunNextVibeLink), but their text is no longer folded into the
        run instructions — inputs/compile are the instruction source. The
        user-typed instructions pass through unchanged."""
        biz_id, parent_vid, nv_ids = parent_ecm_with_next_vibes
        selected = [nv_ids[0], nv_ids[2]]
        _mock_run_now(mock_ws, run_id=7001)

        resp = client_with_agent.post(
            f"/api/businesses/{biz_id}/runs",
            json=_post_body(
                business_id=biz_id,
                parent_version_id=parent_vid,
                next_vibe_ids=selected,
                vibe_instructions="user-typed instructions",
            ),
        )
        assert resp.status_code == 200, resp.text
        run_id = resp.json()["id"]

        with Session(engine) as session:
            run = session.get(Run, run_id)
            assert run is not None
            assert "user-typed instructions" in (run.vibe_instructions_text or "")
            assert "Agent-Suggested Next Vibes" not in (run.vibe_instructions_text or "")
            assert "Tag Missing Pks" not in (run.vibe_instructions_text or "")

            links = session.exec(
                select(RunNextVibeLink).where(RunNextVibeLink.run_id == run_id)
            ).all()
            assert sorted(link.next_vibe_id for link in links) == sorted(selected), (
                f"RunNextVibeLink rows must persist for traceability; "
                f"got {[link.next_vibe_id for link in links]}"
            )

    def test_unknown_next_vibe_id_is_rejected(
        self, client_with_agent, mock_ws, parent_ecm_with_next_vibes
    ):
        """A next_vibe_id that doesn't match any parsed item must 400 —
        the user picked a stale row, the run should not silently drop it."""
        biz_id, parent_vid, _nv_ids = parent_ecm_with_next_vibes
        _mock_run_now(mock_ws)

        resp = client_with_agent.post(
            f"/api/businesses/{biz_id}/runs",
            json=_post_body(
                business_id=biz_id,
                parent_version_id=parent_vid,
                next_vibe_ids=["nv-999"],
            ),
        )
        assert resp.status_code == 400, resp.text
        assert "nv-999" in resp.text
        mock_ws.jobs.run_now.assert_not_called()
