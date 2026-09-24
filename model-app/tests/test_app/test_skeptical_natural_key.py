"""Skeptical tests for the ModelVersion natural-key contract (Streams A + B).

Contract clauses tested:
- ModelVersion.__table_args__ has UniqueConstraint(business_id, version, scope)
  named ``uq_model_versions_business_version_scope``.
- Two rows with the same (business_id, version, scope) raise IntegrityError.
- Two rows with same (business, version) but different scope succeed (so a
  unified `new-base-model` run can yield (v=1, ecm) and (v=1, mvm) for the
  same business).
- Per-scope counter: a vibe-iterate from (v=1, mvm) produces (v=2, mvm), and
  the (v=1, mvm) row still exists.
- shrink_to_mvm from (v=N, ecm) produces (v=N, mvm) — same version,
  flipped scope (per-scope counter, not max+1 globally).

The DB-level test is the primary contract gate. The "unified pipeline run"
clauses are exercised here via direct row inserts that mirror what the
post-completion ModelVersion sync should produce — full pipeline integration
is covered by the dev-agent's test_unified_ecm_mvm.py; we test the
DB-shape invariants the pipeline depends on.
"""

from __future__ import annotations

import pytest
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session, SQLModel, create_engine, select
from sqlalchemy.pool import StaticPool

from vibe_modeling.backend.db_models import (
    Business,
    ModelVersion,
)
from vibe_modeling.backend._query_helpers import next_version_for_scope


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


def test_unique_constraint_declared_with_scope():
    """Streams A+B — ModelVersion declares UniqueConstraint on
    (business_id, version, scope) with the contracted name."""
    table = ModelVersion.__table__  # type: ignore[attr-defined]
    matches = [
        c
        for c in table.constraints
        if c.__class__.__name__ == "UniqueConstraint"
        and getattr(c, "name", "") == "uq_model_versions_business_version_scope"
    ]
    assert matches, (
        "ModelVersion is missing the unique constraint on "
        "(business_id, version, scope) named uq_model_versions_business_version_scope"
    )
    cols = sorted(c.name for c in matches[0].columns)
    assert cols == sorted(["business_id", "version", "scope"]), (
        f"unique constraint columns wrong: {cols}"
    )


def test_two_rows_same_version_diff_scope_succeeds():
    """Streams A+B — Inserting (biz, v=1, ecm) AND (biz, v=1, mvm) succeeds."""
    engine = _new_engine()
    biz_id = _seed_business(engine)

    with Session(engine) as session:
        ecm = ModelVersion(business_id=biz_id, version=1, scope="ecm", status="completed")
        mvm = ModelVersion(business_id=biz_id, version=1, scope="mvm", status="completed")
        session.add(ecm)
        session.add(mvm)
        session.commit()

    with Session(engine) as session:
        rows = session.exec(
            select(ModelVersion).where(ModelVersion.business_id == biz_id)
        ).all()
        scope_versions = {(r.version, r.scope) for r in rows}
        assert scope_versions == {(1, "ecm"), (1, "mvm")}


def test_two_rows_same_version_same_scope_raises_integrity_error():
    """Streams A+B — Two rows with identical (biz, v=1, ecm) raise IntegrityError."""
    engine = _new_engine()
    biz_id = _seed_business(engine)

    with Session(engine) as session:
        session.add(
            ModelVersion(business_id=biz_id, version=1, scope="ecm", status="completed")
        )
        session.commit()

    with Session(engine) as session:
        session.add(
            ModelVersion(business_id=biz_id, version=1, scope="ecm", status="completed")
        )
        with pytest.raises(IntegrityError):
            session.commit()


def test_per_scope_counter_independent_for_ecm_and_mvm():
    """Stream B — `next_version_for_scope` numbers per scope, NOT globally.

    Seed (biz, 1, ecm) + (biz, 1, mvm); the next ECM is 2, the next MVM is 2 —
    each scope advances independently.
    """
    engine = _new_engine()
    biz_id = _seed_business(engine)

    with Session(engine) as session:
        session.add(
            ModelVersion(business_id=biz_id, version=1, scope="ecm", status="completed")
        )
        session.add(
            ModelVersion(business_id=biz_id, version=1, scope="mvm", status="completed")
        )
        session.commit()

    with Session(engine) as session:
        assert next_version_for_scope(session, biz_id, "ecm") == 2
        assert next_version_for_scope(session, biz_id, "mvm") == 2


def test_vibe_iterate_from_v1_mvm_produces_v2_mvm_old_row_intact():
    """Stream B — A vibe-iterate from (v=1, mvm) inserts (v=2, mvm) and the
    (v=1, mvm) parent row still exists afterwards.

    This is the per-scope counter behaviour at the DB-shape level — a route
    that allocates `next_version_for_scope(biz, "mvm")` after a parent row at
    v=1 mvm should land on v=2 mvm and not collide.
    """
    engine = _new_engine()
    biz_id = _seed_business(engine)

    # Seed parent.
    with Session(engine) as session:
        parent = ModelVersion(
            business_id=biz_id, version=1, scope="mvm", status="completed"
        )
        session.add(parent)
        session.commit()
        session.refresh(parent)
        parent_id = parent.id

    # Allocate next per-scope and insert child.
    with Session(engine) as session:
        next_v = next_version_for_scope(session, biz_id, "mvm")
        assert next_v == 2
        child = ModelVersion(
            business_id=biz_id,
            version=next_v,
            scope="mvm",
            status="completed",
            base_version_id=parent_id,
        )
        session.add(child)
        session.commit()

    # Both rows exist.
    with Session(engine) as session:
        rows = session.exec(
            select(ModelVersion)
            .where(ModelVersion.business_id == biz_id)
            .where(ModelVersion.scope == "mvm")
            .order_by(ModelVersion.version)
        ).all()
        assert [r.version for r in rows] == [1, 2]


def test_shrink_from_vN_ecm_produces_vN_mvm():
    """Stream B — shrink_to_mvm from (v=N, ecm) produces (v=N, mvm).

    Same version, scope flipped: per-scope counter, not max+1 globally.
    Seed (biz, 3, ecm) with no MVM rows; allocate next MVM → expect 1
    (per-scope counter starts at 1 for that scope), but ALSO the agent's
    shrink semantics is "v=N → v=N other scope" — so a sync that mirrors the
    agent will write v=3 mvm. Both behaviours are scope-independent; here we
    test that inserting (3, mvm) alongside (3, ecm) is permitted.
    """
    engine = _new_engine()
    biz_id = _seed_business(engine)

    with Session(engine) as session:
        ecm = ModelVersion(business_id=biz_id, version=3, scope="ecm", status="completed")
        session.add(ecm)
        session.commit()
        session.refresh(ecm)
        ecm_id = ecm.id

    # Insert the shrink result at the same version, MVM scope.
    with Session(engine) as session:
        mvm = ModelVersion(
            business_id=biz_id,
            version=3,
            scope="mvm",
            status="completed",
            base_version_id=ecm_id,
        )
        session.add(mvm)
        session.commit()  # must NOT raise — different scope from the ECM row.

    with Session(engine) as session:
        rows = session.exec(
            select(ModelVersion).where(ModelVersion.business_id == biz_id)
        ).all()
        scope_pairs = sorted((r.version, r.scope) for r in rows)
        assert scope_pairs == [(3, "ecm"), (3, "mvm")]


def test_import_from_volume_uses_per_scope_max_plus_1():
    """Stream B — An import-from-volume of an MVM uses per-scope max+1, NOT
    global max+1.

    Seed (biz, 5, ecm) — the global max is 5, but the per-scope MVM max is 0,
    so an MVM import should land at v=1, not v=6.
    """
    engine = _new_engine()
    biz_id = _seed_business(engine)

    with Session(engine) as session:
        session.add(
            ModelVersion(business_id=biz_id, version=5, scope="ecm", status="completed")
        )
        session.commit()

    with Session(engine) as session:
        next_mvm = next_version_for_scope(session, biz_id, "mvm")
        assert next_mvm == 1, (
            f"per-scope MVM next version should be 1 with no MVM rows, got {next_mvm}"
        )
        next_ecm = next_version_for_scope(session, biz_id, "ecm")
        assert next_ecm == 6
