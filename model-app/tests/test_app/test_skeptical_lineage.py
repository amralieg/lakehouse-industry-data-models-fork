"""Skeptical tests for `parse_generated_from_version` and lineage resolution.

Contract clauses tested (Stream B):
- ``parse_generated_from_version("v1_ecm") == (1, "ecm")``
- ``parse_generated_from_version("v3_mvm") == (3, "mvm")``
- ``parse_generated_from_version("unknown") is None``
- ``parse_generated_from_version("") is None``
- ``parse_generated_from_version("v1") is None`` (missing scope)
- ``parse_generated_from_version("ecm_v1") is None`` (wrong order — that's a
  Volume folder format, not the metadata field format)
- During post-completion ModelVersion sync: when ``model.json`` includes
  ``generated_from_version: "v1_ecm"``, the new MV's ``base_version_id`` is
  set to the matching MV's UUID.
- ``resolve_lineage_parent`` is the helper that combines parse + resolve.

The post-completion sync clause is tested at the helper level
(``resolve_lineage_parent``) rather than driving the full pipeline — the
pipeline-level test is the dev's responsibility (test_unified_ecm_mvm /
test_lineage_resolution). Here we confirm the parse → resolve plumbing
returns the right row when fed a synthetic generated_from_version string.
"""

from __future__ import annotations

from sqlmodel import Session, SQLModel, create_engine
from sqlalchemy.pool import StaticPool

from vibe_modeling.backend._query_helpers import (
    parse_generated_from_version,
    resolve_lineage_parent,
)
from vibe_modeling.backend.db_models import Business, ModelVersion


def _new_engine():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    return engine


def _seed_business(engine, name: str = "Acme") -> str:
    with Session(engine) as session:
        b = Business(name=name, description="x")
        session.add(b)
        session.commit()
        session.refresh(b)
        return b.id


def test_parse_v1_ecm_returns_1_ecm():
    assert parse_generated_from_version("v1_ecm") == (1, "ecm")


def test_parse_v3_mvm_returns_3_mvm():
    assert parse_generated_from_version("v3_mvm") == (3, "mvm")


def test_parse_unknown_is_none():
    """The agent's "no parent" sentinel for new-base-model runs."""
    assert parse_generated_from_version("unknown") is None


def test_parse_empty_string_is_none():
    assert parse_generated_from_version("") is None


def test_parse_missing_scope_is_none():
    """Missing scope segment → not a valid lineage tag."""
    assert parse_generated_from_version("v1") is None


def test_parse_wrong_order_is_none():
    """`ecm_v1` is the Volume folder format (legacy?), not the metadata
    field format. Should not parse.

    NOTE: the actual Volume format is ``v{N}_{scope}`` (e.g. v1_ecm), so
    `ecm_v1` is just a typo / wrong-direction string. The contract says it
    should return None.
    """
    assert parse_generated_from_version("ecm_v1") is None


def test_parse_garbage_is_none():
    for v in ("garbage", "v_ecm", "vN_ecm", "v1_xyz", "v1.0_ecm", "v1-ecm"):
        assert parse_generated_from_version(v) is None, (
            f"expected None for {v!r}, got {parse_generated_from_version(v)!r}"
        )


def test_resolve_lineage_parent_v1_ecm_finds_parent():
    """Lineage helper resolves "v1_ecm" against an actual ECM row.

    This is the same plumbing the post-completion ModelVersion sync uses
    when reading `generated_from_version` out of model.json: parse it, then
    look up the MV row. Returning the parent here means
    ``base_version_id`` will be set to that parent's UUID at sync time.
    """
    engine = _new_engine()
    biz_id = _seed_business(engine)

    with Session(engine) as session:
        ecm = ModelVersion(business_id=biz_id, version=1, scope="ecm", status="completed")
        # Add an unrelated MVM at the same version to confirm scope is honoured.
        mvm = ModelVersion(business_id=biz_id, version=1, scope="mvm", status="completed")
        session.add(ecm)
        session.add(mvm)
        session.commit()
        session.refresh(ecm)
        ecm_id = ecm.id

    with Session(engine) as session:
        parent = resolve_lineage_parent(session, biz_id, "v1_ecm")
        assert parent is not None
        assert parent.id == ecm_id
        assert parent.scope == "ecm"


def test_resolve_lineage_parent_unknown_returns_none():
    """For new-base-model runs, ``generated_from_version=='unknown'`` →
    no parent → ``base_version_id`` stays None."""
    engine = _new_engine()
    biz_id = _seed_business(engine)
    with Session(engine) as session:
        assert resolve_lineage_parent(session, biz_id, "unknown") is None


def test_resolve_lineage_parent_returns_none_when_no_matching_row():
    """Parse succeeds but no row exists → still returns None (not a raise)."""
    engine = _new_engine()
    biz_id = _seed_business(engine)
    with Session(engine) as session:
        # No MV rows at all.
        assert resolve_lineage_parent(session, biz_id, "v1_ecm") is None
