"""Tests for the post-sync and post-import ELK pre-compute queueing.

When a new ModelVersion is created (either via a vibe run completion or an
import), the backend should:
  1. Invalidate cached diagram_layouts for prior versions of the same business
  2. Queue pre-compute jobs on the ELK prefetch pool for common views

We can't easily run the full ProgressTracker async loop in a test, so this
module verifies the import path (which calls the same helpers) and checks
the invalidation logic directly.
"""

import json
from unittest.mock import MagicMock, patch

from sqlmodel import Session, select

from vibe_modeling.backend import diagram
from vibe_modeling.backend.db_models import (
    Business,
    DiagramLayout,
    ModelVersion,
)
from vibe_modeling.backend.models import DiagramLayoutOut


def _mock_volume_download(mock_ws, content: dict):
    resp = MagicMock()
    resp.contents.read.return_value = json.dumps(content).encode("utf-8")
    mock_ws.files.download.return_value = resp


def _fixture_model() -> dict:
    return {
        "type": "business",
        "name": "precomp-test",
        "version": "v1_mvm",
        "description": "",
        "domains": [
            {
                "name": "sales",
                "products": [{"name": "orders", "attributes": []}],
            },
            {
                "name": "inventory",
                "products": [{"name": "products", "attributes": []}],
            },
        ],
    }


class TestPrecomputeOnImport:
    """Importing a model should queue pre-computes for common views."""

    def test_import_queues_precomputes(
        self, client_with_agent, mock_ws, seed_business
    ):
        _mock_volume_download(mock_ws, _fixture_model())

        # Patch the prefetch pool to capture what would be queued
        submitted: list[tuple] = []

        def fake_submit(fn, *args, **kwargs):
            submitted.append(args)
            return MagicMock()

        with patch.object(diagram._prefetch_pool, "submit", side_effect=fake_submit):
            r = client_with_agent.post(
                f"/api/businesses/{seed_business}/import/execute",
                json={"volume_path": "/Volumes/a/b/c.json", "accept_business_mismatch": True},
            )
            assert r.status_code == 200, r.text

        # Expected queue: 3 all-domains views (hide/keys/all) + 2 single-domain hides
        assert len(submitted) == 5

        # Extract (domain_filter, column_mode) tuples from the submitted calls
        # fake_submit captured args = (session, ws, business_id, version_int, scope, domain, column_mode, key)
        queued_pairs = {(call[5], call[6]) for call in submitted}
        assert (None, "hide") in queued_pairs
        assert (None, "keys") in queued_pairs
        assert (None, "all") in queued_pairs
        assert ("sales", "hide") in queued_pairs
        assert ("inventory", "hide") in queued_pairs

    def test_import_failure_to_queue_is_non_fatal(
        self, client_with_agent, mock_ws, seed_business
    ):
        """If the prefetch pool is down, the import should still succeed."""
        _mock_volume_download(mock_ws, _fixture_model())

        with patch.object(
            diagram._prefetch_pool, "submit", side_effect=RuntimeError("pool down")
        ):
            r = client_with_agent.post(
                f"/api/businesses/{seed_business}/import/execute",
                json={"volume_path": "/Volumes/a/b/c.json", "accept_business_mismatch": True},
            )
            # Import succeeds despite pool failure
            assert r.status_code == 200, r.text

    def test_import_invalidates_prior_versions(
        self, client_with_agent, mock_ws, seed_business, engine
    ):
        """Importing a new version should delete cached layouts for older versions."""
        _mock_volume_download(mock_ws, _fixture_model())

        # First import creates version 1
        with patch.object(diagram._prefetch_pool, "submit", return_value=MagicMock()):
            r1 = client_with_agent.post(
                f"/api/businesses/{seed_business}/import/execute",
                json={"volume_path": "/Volumes/a/b/c.json", "accept_business_mismatch": True},
            )
        v1_id = r1.json()["version_id"]

        # Seed a cache entry for version 1
        with Session(engine) as session:
            diagram._write_lakebase_layout(
                session, seed_business, v1_id, "v1_ck", DiagramLayoutOut(),
            )

        # Second import creates version 2, invalidating v1
        with patch.object(diagram._prefetch_pool, "submit", return_value=MagicMock()):
            client_with_agent.post(
                f"/api/businesses/{seed_business}/import/execute",
                json={"volume_path": "/Volumes/a/b/c.json", "accept_business_mismatch": True},
            )

        # v1 cache entries should be gone
        with Session(engine) as session:
            v1_layouts = session.exec(
                select(DiagramLayout).where(
                    DiagramLayout.business_id == seed_business,
                    DiagramLayout.version_id == v1_id,
                )
            ).all()
        assert len(v1_layouts) == 0


class TestQueueLayoutPrefetchForVersionHelper:
    """Direct contract tests for ``diagram.queue_layout_prefetch_for_version``.

    The helper is the single source of truth for layout-prefetch fanout:
    one call site is the manual import route (covered above), the other is
    the orchestrator's per-op terminal-success path (covered indirectly via
    runs through ``test_orchestrator_runner``). These tests pin the helper's
    contract on its own so contract changes are surfaced without going
    through either caller.
    """

    def test_submits_overview_x_three_modes_plus_per_domain(self, engine):
        """For a business with N domains, fanout = 3 + N jobs."""
        with Session(engine) as s:
            biz = Business(name="Co", description="", industry_alignment="x")
            s.add(biz); s.commit(); s.refresh(biz)
            mv = ModelVersion(business_id=biz.id, version=1, scope="ecm", status="completed")
            s.add(mv); s.commit(); s.refresh(mv)
            from vibe_modeling.backend.db_models import Domain as DbDomain
            for name in ("alpha", "beta"):
                s.add(DbDomain(version_id=mv.id, name=name))
            s.commit()
            biz_id = biz.id

        ws = MagicMock()
        session_factory = lambda: Session(engine)

        with patch.object(diagram, "_in_progress", {}), \
             patch.object(diagram._prefetch_pool, "submit") as submit:
            with Session(engine) as s:
                submitted = diagram.queue_layout_prefetch_for_version(
                    s, session_factory, ws,
                    business_id=biz_id, version_int=1, scope="ecm",
                )

        # 3 column modes for overview + 2 per-domain hide-mode = 5 jobs.
        assert submitted == 5, submitted
        assert submit.call_count == 5

    def test_returns_zero_when_modelversion_missing(self, engine):
        """If the (business, version, scope) triple doesn't resolve to any
        ModelVersion, helper logs and returns 0 without submitting."""
        with Session(engine) as s:
            biz = Business(name="Co", description="", industry_alignment="x")
            s.add(biz); s.commit(); s.refresh(biz)
            biz_id = biz.id

        ws = MagicMock()
        session_factory = lambda: Session(engine)

        with patch.object(diagram._prefetch_pool, "submit") as submit:
            with Session(engine) as s:
                submitted = diagram.queue_layout_prefetch_for_version(
                    s, session_factory, ws,
                    business_id=biz_id, version_int=99, scope="ecm",
                )

        assert submitted == 0
        submit.assert_not_called()

    def test_skips_keys_already_in_flight(self, engine):
        """If a cache key is already in ``_in_progress``, that job is not
        re-submitted (count reflects only newly-submitted jobs)."""
        with Session(engine) as s:
            biz = Business(name="Co", description="", industry_alignment="x")
            s.add(biz); s.commit(); s.refresh(biz)
            mv = ModelVersion(business_id=biz.id, version=1, scope="ecm", status="completed")
            s.add(mv); s.commit(); s.refresh(mv)
            from vibe_modeling.backend.db_models import Domain as DbDomain
            s.add(DbDomain(version_id=mv.id, name="sales"))
            s.commit()
            biz_id = biz.id

        ws = MagicMock()
        session_factory = lambda: Session(engine)

        # Pre-seed _in_progress so the first overview-hide key is "already in flight".
        existing_key = diagram._cache_key(biz_id, 1, "ecm", None, "hide")
        with patch.object(diagram, "_in_progress", {existing_key: 0}), \
             patch.object(diagram._prefetch_pool, "submit") as submit:
            with Session(engine) as s:
                submitted = diagram.queue_layout_prefetch_for_version(
                    s, session_factory, ws,
                    business_id=biz_id, version_int=1, scope="ecm",
                )

        # 1 domain ("sales"), 3 overview keys + 1 per-domain hide = 4 total,
        # 1 already in flight (overview-hide) → 3 newly submitted.
        assert submitted == 3, submitted
        assert submit.call_count == 3
