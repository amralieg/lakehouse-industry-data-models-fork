"""Skeptical tests for `resolve_model_version` (Stream B).

Contract clauses tested:
- Located in `vibe_modeling.backend._query_helpers`.
- Signature: ``resolve_model_version(session, business_id, version_int, scope)
  -> Optional[ModelVersion]``.
- Returns None when not found.
- Returns the unique row when found.
- Distinguishes scopes — resolves (biz, 1, ecm) separately from (biz, 1, mvm).
- Never raises on ambiguity (would imply a constraint bug).
"""

from __future__ import annotations

import inspect

from sqlmodel import Session, SQLModel, create_engine
from sqlalchemy.pool import StaticPool

from vibe_modeling.backend._query_helpers import resolve_model_version
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


def test_signature_matches_contract():
    """Stream B — the helper takes (session, business_id, version_int, scope)."""
    sig = inspect.signature(resolve_model_version)
    params = list(sig.parameters.keys())
    assert params == ["session", "business_id", "version_int", "scope"], (
        f"resolve_model_version signature drift: {params}"
    )


def test_returns_none_when_no_match():
    """Stream B — Returns None when no row matches."""
    engine = _new_engine()
    biz_id = _seed_business(engine)
    with Session(engine) as session:
        assert resolve_model_version(session, biz_id, 1, "ecm") is None


def test_returns_row_when_match_exists():
    """Stream B — Returns the matching row."""
    engine = _new_engine()
    biz_id = _seed_business(engine)

    with Session(engine) as session:
        mv = ModelVersion(business_id=biz_id, version=2, scope="mvm", status="completed")
        session.add(mv)
        session.commit()
        session.refresh(mv)
        target_id = mv.id

    with Session(engine) as session:
        got = resolve_model_version(session, biz_id, 2, "mvm")
        assert got is not None
        assert got.id == target_id
        assert got.scope == "mvm"
        assert got.version == 2


def test_distinguishes_ecm_vs_mvm_at_same_version():
    """Stream B — Resolves (biz, 1, ecm) and (biz, 1, mvm) as distinct rows."""
    engine = _new_engine()
    biz_id = _seed_business(engine)

    with Session(engine) as session:
        ecm = ModelVersion(business_id=biz_id, version=1, scope="ecm", status="completed")
        mvm = ModelVersion(business_id=biz_id, version=1, scope="mvm", status="completed")
        session.add(ecm)
        session.add(mvm)
        session.commit()
        session.refresh(ecm)
        session.refresh(mvm)
        ecm_id = ecm.id
        mvm_id = mvm.id

    with Session(engine) as session:
        got_ecm = resolve_model_version(session, biz_id, 1, "ecm")
        got_mvm = resolve_model_version(session, biz_id, 1, "mvm")
        assert got_ecm is not None and got_ecm.id == ecm_id
        assert got_mvm is not None and got_mvm.id == mvm_id
        assert got_ecm.id != got_mvm.id


def test_returns_none_for_unknown_scope():
    """Stream B — Returns None for an unknown scope, not the wrong row."""
    engine = _new_engine()
    biz_id = _seed_business(engine)

    with Session(engine) as session:
        session.add(
            ModelVersion(business_id=biz_id, version=1, scope="ecm", status="completed")
        )
        session.commit()

    with Session(engine) as session:
        # 'foo' isn't a real scope — must NOT silently return the ECM row.
        assert resolve_model_version(session, biz_id, 1, "foo") is None


def test_does_not_raise_on_ambiguity():
    """Stream B — never raises (e.g. on multiple rows). The unique constraint
    means there can't be more than one matching row, so .first() always returns
    a single Optional[ModelVersion].
    """
    engine = _new_engine()
    biz_id = _seed_business(engine)

    with Session(engine) as session:
        session.add(
            ModelVersion(business_id=biz_id, version=1, scope="ecm", status="completed")
        )
        session.commit()

    with Session(engine) as session:
        # Should not raise even with weird inputs.
        assert resolve_model_version(session, biz_id, -1, "ecm") is None
        assert resolve_model_version(session, "no-such-biz", 1, "ecm") is None
