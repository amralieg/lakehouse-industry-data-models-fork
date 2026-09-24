"""Tests for the empty-layout cache guard (an internal tracker item).

Root cause: an all-domains layout prefetched before the model finished
syncing produced an empty DiagramLayoutOut (no nodes, no groups) that was
persisted to Lakebase and served forever.

Three acceptance lines:
  (a) An empty/no-domains compute is NOT persisted to the cache.
  (b) After a model gains domains, the all-domains layout recomputes non-empty
      (no stale empty served).
  (c) The prefetch guard skips a no-domains model entirely.

Plus:
  (d) _invalidate_empty_layouts deletes zero-node rows and leaves non-empty
      rows untouched.
"""

import json
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from unittest.mock import MagicMock
from sqlmodel import Session, select

from vibe_modeling.backend import diagram as diagram_mod
from vibe_modeling.backend.diagram import (
    _ModelNotReadyError,
    _background_compute,
    _compute_layout,
    _invalidate_empty_layouts,
    queue_layout_prefetch_for_version,
)
from vibe_modeling.backend.db_models import (
    Business,
    DiagramLayout,
    Domain as DbDomain,
    ModelVersion,
)
from vibe_modeling.backend.models import DiagramLayoutOut


def _clear_caches():
    with diagram_mod._in_progress_lock:
        diagram_mod._in_progress.clear()
    with diagram_mod._cache_lock:
        diagram_mod._layout_cache.clear()


@pytest.fixture(autouse=True)
def _clean():
    _clear_caches()
    yield
    _clear_caches()


class TestComputeLayoutNotReady:
    """_compute_layout raises _ModelNotReadyError when the model has no domains."""

    def test_empty_domains_raises_not_ready(self):
        with pytest.raises(_ModelNotReadyError):
            _compute_layout({"domains": []}, None, None, "hide")

    def test_missing_domains_key_raises_not_ready(self):
        with pytest.raises(_ModelNotReadyError):
            _compute_layout({}, None, None, "hide")

    def test_model_with_domains_does_not_raise(self):
        model = {
            "domains": [
                {
                    "name": "sales",
                    "products": [
                        {
                            "name": "customer",
                            "table_name": "customer",
                            "primary_key": "customer_id",
                            "attributes": [
                                {"name": "customer_id", "type": "BIGINT", "foreign_key_to": ""},
                            ],
                        },
                    ],
                }
            ]
        }
        layout = _compute_layout(model, None, None, "hide")
        assert isinstance(layout, DiagramLayoutOut)
        assert len(layout.nodes) >= 1


class TestBackgroundComputeNoCache:
    """(a) When _compute_layout raises _ModelNotReadyError, nothing is written
    to the in-memory cache or Lakebase."""

    def test_empty_model_not_cached_in_memory(self, monkeypatch):
        write_calls = []

        def _fake_write(session, business_id, version_id, cache_key, layout):
            write_calls.append(layout)

        monkeypatch.setattr(diagram_mod, "_write_lakebase_layout", _fake_write)

        class _FakeSession:
            def __enter__(self):
                return self
            def __exit__(self, *a):
                return False
            def commit(self):
                pass

        def _factory():
            return _FakeSession()

        monkeypatch.setattr(
            diagram_mod, "_load_layout_inputs",
            lambda session, *a, **kw: ({"domains": []}, None, "mv-1"),
        )

        key = "test-no-cache-key"
        _background_compute(_factory, None, "biz-1", 1, "mvm", None, "hide", key)

        with diagram_mod._cache_lock:
            assert key not in diagram_mod._layout_cache, (
                "empty layout must NOT be stored in the in-memory cache"
            )
        assert write_calls == [], (
            "_write_lakebase_layout must NOT be called for an empty model"
        )

    def test_empty_model_key_removed_from_in_progress(self, monkeypatch):
        class _FakeSession:
            def __enter__(self):
                return self
            def __exit__(self, *a):
                return False
            def commit(self):
                pass

        def _factory():
            return _FakeSession()

        monkeypatch.setattr(
            diagram_mod, "_load_layout_inputs",
            lambda session, *a, **kw: ({"domains": []}, None, None),
        )
        monkeypatch.setattr(diagram_mod, "_write_lakebase_layout", lambda *a, **kw: None)

        key = "test-in-progress-cleanup"
        with diagram_mod._in_progress_lock:
            diagram_mod._in_progress[key] = diagram_mod._now_ms()

        _background_compute(_factory, None, "biz-1", 1, "mvm", None, "hide", key)

        with diagram_mod._in_progress_lock:
            assert key not in diagram_mod._in_progress, (
                "key must be removed from _in_progress even on _ModelNotReadyError"
            )

    def test_real_model_is_still_cached(self, monkeypatch, engine):
        """Regression: a model that DOES have domains must still be cached normally."""
        model = {
            "domains": [
                {
                    "name": "sales",
                    "products": [
                        {
                            "name": "customer",
                            "table_name": "customer",
                            "primary_key": "customer_id",
                            "attributes": [
                                {"name": "customer_id", "type": "BIGINT", "foreign_key_to": ""},
                            ],
                        },
                    ],
                }
            ]
        }

        write_calls = []

        def _fake_write(session, business_id, version_id, cache_key, layout):
            write_calls.append(layout)

        monkeypatch.setattr(diagram_mod, "_write_lakebase_layout", _fake_write)

        class _FakeSession:
            def __enter__(self):
                return self
            def __exit__(self, *a):
                return False
            def commit(self):
                pass

        def _factory():
            return _FakeSession()

        monkeypatch.setattr(
            diagram_mod, "_load_layout_inputs",
            lambda session, *a, **kw: (model, None, "mv-real"),
        )

        key = "test-real-model-cached"
        _background_compute(_factory, None, "biz-real", 1, "mvm", None, "hide", key)

        with diagram_mod._cache_lock:
            assert key in diagram_mod._layout_cache, (
                "a model with domains must still populate the in-memory cache"
            )
        assert len(write_calls) == 1, (
            "_write_lakebase_layout must be called for a model with domains"
        )
        assert isinstance(write_calls[0], DiagramLayoutOut)


class TestPrefetchGuard:
    """(c) queue_layout_prefetch_for_version skips a no-domains model."""

    def _seed(self, engine, has_domains: bool) -> tuple[str, int, str]:
        with Session(engine) as session:
            biz = Business(name="PrefetchGuardBiz")
            session.add(biz)
            session.commit()
            session.refresh(biz)
            mv = ModelVersion(
                business_id=biz.id,
                version=1,
                scope="mvm",
                status="completed",
                deployment_status="draft",
            )
            session.add(mv)
            session.commit()
            session.refresh(mv)
            if has_domains:
                session.add(DbDomain(version_id=mv.id, name="sales"))
                session.commit()
            return biz.id, 1, "mvm"

    def test_no_domains_submits_zero_jobs(self, engine, monkeypatch):
        submitted = []

        class _TrackingFuture:
            def result(self, timeout=None):
                return None

        def _track_submit(fn, *args, **kwargs):
            submitted.append(fn)
            return _TrackingFuture()

        monkeypatch.setattr(diagram_mod._prefetch_pool, "submit", _track_submit)

        biz_id, version_int, scope = self._seed(engine, has_domains=False)
        ws = MagicMock()

        with Session(engine) as session:
            result = queue_layout_prefetch_for_version(
                session,
                lambda: Session(engine),
                ws,
                business_id=biz_id,
                version_int=version_int,
                scope=scope,
            )

        assert result == 0, "no jobs should be submitted for a no-domains model"
        assert submitted == [], "submit must not be called for a no-domains model"

    def test_with_domains_submits_jobs(self, engine, monkeypatch):
        submitted = []

        class _TrackingFuture:
            def result(self, timeout=None):
                return None

        def _track_submit(fn, *args, **kwargs):
            submitted.append(fn)
            return _TrackingFuture()

        monkeypatch.setattr(diagram_mod._prefetch_pool, "submit", _track_submit)

        biz_id, version_int, scope = self._seed(engine, has_domains=True)
        ws = MagicMock()

        with Session(engine) as session:
            result = queue_layout_prefetch_for_version(
                session,
                lambda: Session(engine),
                ws,
                business_id=biz_id,
                version_int=version_int,
                scope=scope,
            )

        assert result > 0, "at least one job should be submitted when domains exist"
        assert len(submitted) > 0


class TestInvalidateEmptyLayouts:
    """(d) _invalidate_empty_layouts cleans up zero-node rows without touching non-empty ones."""

    def _seed(self, engine) -> tuple[str, str]:
        with Session(engine) as session:
            biz = Business(name="EmptyLayoutBiz")
            session.add(biz)
            session.commit()
            session.refresh(biz)
            mv = ModelVersion(
                business_id=biz.id, version=1, status="completed",
                deployment_status="draft",
            )
            session.add(mv)
            session.commit()
            session.refresh(mv)
            return biz.id, mv.id

    def _write_row(self, engine, biz_id, version_id, cache_key, nodes_count):
        from vibe_modeling.backend.diagram import _write_lakebase_layout

        nodes = []
        if nodes_count > 0:
            from vibe_modeling.backend.models import DiagramNode
            nodes = [
                DiagramNode(
                    id=f"d.p{i}", domain="d", product=f"p{i}",
                    table_name=f"t{i}", x=0, y=0, width=200, height=80,
                )
                for i in range(nodes_count)
            ]
        layout = DiagramLayoutOut(nodes=nodes)
        with Session(engine) as session:
            _write_lakebase_layout(session, biz_id, version_id, cache_key, layout)

    def test_deletes_zero_node_rows(self, engine):
        biz_id, version_id = self._seed(engine)
        self._write_row(engine, biz_id, version_id, "empty-key", 0)

        with Session(engine) as session:
            count = _invalidate_empty_layouts(session, biz_id)

        assert count == 1

        with Session(engine) as session:
            rows = session.exec(
                select(DiagramLayout).where(DiagramLayout.business_id == biz_id)
            ).all()
        assert len(rows) == 0

    def test_leaves_non_empty_rows_untouched(self, engine):
        biz_id, version_id = self._seed(engine)
        self._write_row(engine, biz_id, version_id, "empty-key", 0)
        self._write_row(engine, biz_id, version_id, "real-key", 3)

        with Session(engine) as session:
            count = _invalidate_empty_layouts(session, biz_id)

        assert count == 1

        with Session(engine) as session:
            rows = session.exec(
                select(DiagramLayout).where(DiagramLayout.business_id == biz_id)
            ).all()
        assert len(rows) == 1
        assert rows[0].cache_key == "real-key"

    def test_version_scoped_cleanup(self, engine):
        biz_id, v1_id = self._seed(engine)
        with Session(engine) as session:
            mv2 = ModelVersion(
                business_id=biz_id, version=2, status="completed",
                deployment_status="draft",
            )
            session.add(mv2)
            session.commit()
            v2_id = mv2.id

        self._write_row(engine, biz_id, v1_id, "v1-empty", 0)
        self._write_row(engine, biz_id, v2_id, "v2-empty", 0)

        with Session(engine) as session:
            count = _invalidate_empty_layouts(session, biz_id, version_id=v1_id)

        assert count == 1

        with Session(engine) as session:
            rows = session.exec(
                select(DiagramLayout).where(DiagramLayout.business_id == biz_id)
            ).all()
        assert len(rows) == 1
        assert rows[0].cache_key == "v2-empty"

    def test_noop_on_business_with_no_empty_layouts(self, engine):
        biz_id, version_id = self._seed(engine)
        self._write_row(engine, biz_id, version_id, "real-key", 2)

        with Session(engine) as session:
            count = _invalidate_empty_layouts(session, biz_id)

        assert count == 0

        with Session(engine) as session:
            rows = session.exec(
                select(DiagramLayout).where(DiagramLayout.business_id == biz_id)
            ).all()
        assert len(rows) == 1


class TestStaleEmptyNotServed:
    """(b) After a model gains domains, the all-domains layout recomputes
    non-empty rather than serving a stale cached empty.

    This test exercises the full background_compute → cache path end-to-end:
    verifies that with the guard in place, a pre-sync empty is never cached,
    so a post-sync compute does land a real layout in the cache.
    """

    def test_post_sync_compute_overwrites_nothing(self, monkeypatch):
        real_model = {
            "domains": [
                {
                    "name": "sales",
                    "products": [
                        {
                            "name": "customer",
                            "table_name": "customer",
                            "primary_key": "customer_id",
                            "attributes": [
                                {"name": "customer_id", "type": "BIGINT", "foreign_key_to": ""},
                            ],
                        },
                    ],
                }
            ]
        }

        written_layouts = []

        def _fake_write(session, business_id, version_id, cache_key, layout):
            written_layouts.append(layout)

        monkeypatch.setattr(diagram_mod, "_write_lakebase_layout", _fake_write)

        class _FakeSession:
            def __enter__(self):
                return self
            def __exit__(self, *a):
                return False
            def commit(self):
                pass

        def _factory():
            return _FakeSession()

        key = "test-post-sync-key"

        monkeypatch.setattr(
            diagram_mod, "_load_layout_inputs",
            lambda session, *a, **kw: ({"domains": []}, None, "mv-1"),
        )
        _background_compute(_factory, None, "biz-1", 1, "mvm", None, "hide", key)

        with diagram_mod._cache_lock:
            assert key not in diagram_mod._layout_cache, (
                "pre-sync empty must NOT be in cache"
            )
        assert written_layouts == []

        monkeypatch.setattr(
            diagram_mod, "_load_layout_inputs",
            lambda session, *a, **kw: (real_model, None, "mv-1"),
        )
        _background_compute(_factory, None, "biz-1", 1, "mvm", None, "hide", key)

        with diagram_mod._cache_lock:
            cached = diagram_mod._layout_cache.get(key)
        assert isinstance(cached, DiagramLayoutOut), (
            "post-sync compute must populate the cache with a real layout"
        )
        assert len(cached.nodes) >= 1, (
            "cached layout must have nodes after the model synced"
        )
        assert len(written_layouts) == 1, (
            "_write_lakebase_layout must be called exactly once (post-sync)"
        )
