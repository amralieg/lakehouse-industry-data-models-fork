"""Missing-file resilience for the shared Volume artifact indexer.

The import execute path indexes every sibling file under the model.json
folder. Volume listings are eventually-consistent: a subfolder the
top-level listing reports can 404 the instant the walker recurses into
it. The indexer must tolerate that — skip the vanished subtree, still
index the reachable files, and never raise into the import request (a
raise would wedge the synchronous create-business-and-execute call).
"""
from __future__ import annotations

import os
import sys
from unittest.mock import MagicMock

from sqlmodel import Session, SQLModel, create_engine, select

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)

from vibe_modeling.backend.db_models import RunArtifact
from vibe_modeling.backend.services.artifact_indexer import (
    index_artifacts_at_path,
    walk_volume_dir_with_size,
)


def _entry(name: str, *, is_dir: bool = False, size: int | None = 100):
    e = MagicMock()
    e.name = name
    e.is_directory = is_dir
    if size is None:
        del e.file_size
    else:
        e.file_size = size
    return e


def _session() -> Session:
    engine = create_engine("sqlite://")
    SQLModel.metadata.create_all(engine)
    return Session(engine)


def _wire(ws, layout):
    def _list(path: str):
        if path not in layout:
            raise FileNotFoundError(path)
        return iter(layout[path])
    ws.files.list_directory_contents.side_effect = _list


def test_walk_skips_subdir_that_vanishes_mid_walk():
    """A subdirectory present in the parent listing but missing when the
    walker recurses into it yields its reachable siblings, not an error."""
    ws = MagicMock()
    # /root lists model.json + a 'docs' subdir, but /root/docs 404s.
    _wire(ws, {
        "/root": [_entry("model.json"), _entry("docs", is_dir=True)],
        # "/root/docs" intentionally absent → raises FileNotFoundError.
    })
    files = walk_volume_dir_with_size(ws, "/root")
    paths = [p for p, _ in files]
    assert paths == ["/root/model.json"]


def test_index_skips_vanished_subtree_and_records_reachable_files():
    ws = MagicMock()
    _wire(ws, {
        "/root": [
            _entry("model.json"),
            _entry("readme.md"),
            _entry("diagram", is_dir=True),
        ],
        # diagram subtree vanished between listing and recursion.
    })
    with _session() as session:
        inserted = index_artifacts_at_path(
            ws, session,
            run_id=None,
            model_version_id="mv-1",
            volume_root_path="/root",
        )
        assert inserted == 2  # model.json + readme.md, diagram skipped
        rows = session.exec(
            select(RunArtifact).where(RunArtifact.model_version_id == "mv-1")
        ).all()
        assert {r.file_path for r in rows} == {
            "/root/model.json",
            "/root/readme.md",
        }


def test_index_never_raises_when_root_listing_fails():
    """Top-level listing failure → 0 rows, no exception into the caller."""
    ws = MagicMock()
    ws.files.list_directory_contents.side_effect = FileNotFoundError("/gone")
    with _session() as session:
        inserted = index_artifacts_at_path(
            ws, session,
            run_id=None,
            model_version_id="mv-2",
            volume_root_path="/gone",
        )
        assert inserted == 0


# ---------------------------------------------------------------------------
# Query-count regression: index_artifacts_at_path must be a small constant
# number of round trips regardless of file count, not one existing-row
# lookup per file.
# ---------------------------------------------------------------------------

def _count_statements(engine, fn):
    """Run ``fn()`` and count DB statements ``engine`` executes meanwhile."""
    from sqlalchemy import event

    count = 0

    def _before_cursor_execute(*_args, **_kwargs):
        nonlocal count
        count += 1

    event.listen(engine, "before_cursor_execute", _before_cursor_execute)
    try:
        fn()
    finally:
        event.remove(engine, "before_cursor_execute", _before_cursor_execute)
    return count


def _index_with_n_files(n: int) -> int:
    """Build a Volume listing of ``n`` flat files, index it against a fresh
    engine, and return the statement count the call issues."""
    engine = create_engine("sqlite://")
    SQLModel.metadata.create_all(engine)

    ws = MagicMock()
    entries = [_entry(f"doc_{i}.md") for i in range(n)]
    _wire(ws, {"/root": entries})

    with Session(engine) as session:
        count = _count_statements(
            engine,
            lambda: index_artifacts_at_path(
                ws, session,
                run_id=None,
                model_version_id="mv-count",
                volume_root_path="/root",
            ),
        )
    return count


def test_index_query_count_is_bounded_not_per_file():
    """Indexing N files must issue the same number of statements regardless
    of N - one existing-row select for the whole scope plus one bulk insert,
    not one ``session.exec(...).first()`` lookup per file. A regression back
    to the per-file lookup loop would show up here as growth between the
    1-file and 8-file runs.
    """
    count_1 = _index_with_n_files(1)
    count_8 = _index_with_n_files(8)
    assert count_8 == count_1, (
        f"index statement count grew with file count: {count_1} -> {count_8} "
        "(should stay O(1), not O(files))"
    )
