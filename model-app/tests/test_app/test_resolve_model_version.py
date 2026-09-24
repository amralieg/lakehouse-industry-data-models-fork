"""Unit tests for ``backend._query_helpers``.

Covers the scope-aware ``ModelVersion`` lookup helper, the per-scope
ordinal allocator, and the agent ``generated_from_version`` parser.
These are the single source of truth for the post-refactor natural key
``(business_id, version, scope)`` — every MV creation/lookup site now
routes through them.
"""

from __future__ import annotations

import os
import sys

import pytest
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)

from vibe_modeling.backend._query_helpers import (
    next_version_for_scope,
    parse_generated_from_version,
    resolve_lineage_parent,
    resolve_model_version,
)
from vibe_modeling.backend.db_models import Business, ModelVersion


@pytest.fixture
def engine():
    eng = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(eng)
    return eng


@pytest.fixture
def biz_id(engine):
    with Session(engine) as s:
        b = Business(name="acme")
        s.add(b)
        s.commit()
        s.refresh(b)
        return b.id


def _seed(session: Session, biz_id: str, *, version: int, scope: str) -> str:
    mv = ModelVersion(
        business_id=biz_id, version=version, scope=scope,
        status="completed", deployment_status="draft",
    )
    session.add(mv)
    session.commit()
    session.refresh(mv)
    return mv.id


# ---------------------------------------------------------------------------
# resolve_model_version
# ---------------------------------------------------------------------------


def test_resolve_returns_unique_row_for_business_version_scope(engine, biz_id):
    with Session(engine) as s:
        ecm_id = _seed(s, biz_id, version=1, scope="ecm")
        mvm_id = _seed(s, biz_id, version=1, scope="mvm")

        ecm = resolve_model_version(s, biz_id, 1, "ecm")
        mvm = resolve_model_version(s, biz_id, 1, "mvm")
        assert ecm is not None and ecm.id == ecm_id
        assert mvm is not None and mvm.id == mvm_id


def test_resolve_returns_none_when_missing(engine, biz_id):
    with Session(engine) as s:
        _seed(s, biz_id, version=1, scope="ecm")
        assert resolve_model_version(s, biz_id, 99, "ecm") is None
        assert resolve_model_version(s, biz_id, 1, "mvm") is None
        assert resolve_model_version(s, biz_id, 1, "") is None


def test_resolve_rejects_invalid_inputs(engine, biz_id):
    with Session(engine) as s:
        _seed(s, biz_id, version=1, scope="ecm")
        # Empty business id, scope, or non-positive version returns None
        # without ever touching the DB.
        assert resolve_model_version(s, "", 1, "ecm") is None
        assert resolve_model_version(s, biz_id, 0, "ecm") is None
        assert resolve_model_version(s, biz_id, -1, "ecm") is None


def test_resolve_isolates_businesses(engine, biz_id):
    with Session(engine) as s:
        other = Business(name="globex")
        s.add(other)
        s.commit()
        s.refresh(other)
        _seed(s, biz_id, version=1, scope="ecm")
        # `other` business has no rows; query must not return acme's row.
        assert resolve_model_version(s, other.id, 1, "ecm") is None


# ---------------------------------------------------------------------------
# next_version_for_scope
# ---------------------------------------------------------------------------


def test_next_version_starts_at_one(engine, biz_id):
    with Session(engine) as s:
        assert next_version_for_scope(s, biz_id, "ecm") == 1
        assert next_version_for_scope(s, biz_id, "mvm") == 1


def test_next_version_per_scope_increments_independently(engine, biz_id):
    with Session(engine) as s:
        _seed(s, biz_id, version=1, scope="ecm")
        # ECM next is 2, MVM next is still 1.
        assert next_version_for_scope(s, biz_id, "ecm") == 2
        assert next_version_for_scope(s, biz_id, "mvm") == 1
        _seed(s, biz_id, version=1, scope="mvm")
        # Adding MVM v=1 doesn't bump ECM's counter.
        assert next_version_for_scope(s, biz_id, "ecm") == 2
        assert next_version_for_scope(s, biz_id, "mvm") == 2


def test_next_version_picks_max_not_count(engine, biz_id):
    """Sparse history (gaps) must not reset to count+1."""
    with Session(engine) as s:
        _seed(s, biz_id, version=1, scope="ecm")
        _seed(s, biz_id, version=5, scope="ecm")
        # Two rows, max=5 → next is 6, not 3.
        assert next_version_for_scope(s, biz_id, "ecm") == 6


# ---------------------------------------------------------------------------
# parse_generated_from_version
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    "tag, expected",
    [
        ("v1_ecm", (1, "ecm")),
        ("v2_mvm", (2, "mvm")),
        ("v10_ecm", (10, "ecm")),
        ("v999_mvm", (999, "mvm")),
    ],
)
def test_parse_valid_tags(tag, expected):
    assert parse_generated_from_version(tag) == expected


@pytest.mark.parametrize(
    "tag",
    [
        "",
        "unknown",
        "v1",
        "v1_",
        "v_ecm",
        "1_ecm",
        "v1_xyz",
        "ECM_v1",
        None,
    ],
)
def test_parse_invalid_tags_returns_none(tag):
    assert parse_generated_from_version(tag) is None


# ---------------------------------------------------------------------------
# resolve_lineage_parent
# ---------------------------------------------------------------------------


def test_resolve_lineage_parent_finds_matching_row(engine, biz_id):
    with Session(engine) as s:
        ecm_id = _seed(s, biz_id, version=1, scope="ecm")
        mvm_id = _seed(s, biz_id, version=1, scope="mvm")

        p1 = resolve_lineage_parent(s, biz_id, "v1_ecm")
        p2 = resolve_lineage_parent(s, biz_id, "v1_mvm")
        assert p1 is not None and p1.id == ecm_id
        assert p2 is not None and p2.id == mvm_id


def test_resolve_lineage_parent_handles_missing_tag(engine, biz_id):
    with Session(engine) as s:
        _seed(s, biz_id, version=1, scope="ecm")
        assert resolve_lineage_parent(s, biz_id, "") is None
        assert resolve_lineage_parent(s, biz_id, "unknown") is None
        assert resolve_lineage_parent(s, biz_id, "v9_ecm") is None
