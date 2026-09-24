"""Skeptical tests for the migrations framework contract (Stream A).

Contract clauses tested:
- migrations/__init__.py re-exports Migration, MIGRATIONS, INSTALL_POLICY,
  PRE_PROD_DESTRUCTIVE_RESET, LakebaseInstallError, reconcile_schema.
- MIGRATIONS is a list; first entry has version "0.1.0".
- reconcile_schema:
    * Empty DB + permissive policy → applies all migrations, writes version row.
    * Empty DB + strict policy + non-empty schema → raises LakebaseInstallError.
    * Stored version == latest → no-op.
    * Stored version older than latest → applies only post-installed migrations.
    * Stored version newer than latest → raises (refuses downgrade).
    * PRE_PROD_DESTRUCTIVE_RESET=True AND version mismatch (and not strict-fresh)
      → drops public schema then runs all migrations.
- LakebaseSchemaVersion is a SQLModel singleton (id=1) with version + applied_at.

These tests treat the stored-newer-than-latest comparison as string ordering on
semver because that's what the contract says — code uses ``installed > latest``
directly. If the implementation uses tuple-ordering or ``packaging.Version``,
the test "stored newer than latest raises" may need adjustment.
"""

from __future__ import annotations

from sqlalchemy import inspect
from sqlmodel import Session, SQLModel, create_engine, select
from sqlalchemy.pool import StaticPool

import pytest


def _new_engine():
    return create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )


def test_public_symbols_reexported():
    """Stream A — `migrations.__init__` re-exports the full public surface."""
    from vibe_modeling.backend import migrations

    for name in (
        "Migration",
        "MIGRATIONS",
        "INSTALL_POLICY",
        "PRE_PROD_DESTRUCTIVE_RESET",
        "LakebaseInstallError",
        "reconcile_schema",
    ):
        assert hasattr(migrations, name), f"migrations.__init__ missing {name}"


def test_first_migration_is_0_1_0():
    """Stream A — `MIGRATIONS[0].version == "0.1.0"` (initial schema)."""
    from vibe_modeling.backend import migrations

    assert isinstance(migrations.MIGRATIONS, list)
    assert migrations.MIGRATIONS, "MIGRATIONS is empty — initial migration not registered"
    assert migrations.MIGRATIONS[0].version == "0.1.0"


def test_lakebase_schema_version_table_shape():
    """Stream A — LakebaseSchemaVersion is a SQLModel singleton with version + applied_at."""
    from vibe_modeling.backend.db_models import LakebaseSchemaVersion
    from datetime import datetime

    # Table-mapped SQLModel
    assert hasattr(LakebaseSchemaVersion, "__tablename__")
    fields = LakebaseSchemaVersion.model_fields
    assert "id" in fields
    assert "version" in fields
    assert "applied_at" in fields
    # Default id=1 (singleton) — instantiate without args and the row should
    # have id=1.
    inst = LakebaseSchemaVersion()
    assert inst.id == 1
    assert isinstance(inst.applied_at, datetime)


def test_reconcile_fresh_db_permissive_applies_and_writes_version(monkeypatch):
    """Stream A — Empty DB + permissive policy applies all migrations and
    writes the version row to LakebaseSchemaVersion."""
    from vibe_modeling.backend import migrations
    from vibe_modeling.backend.migrations import registry as _reg
    from vibe_modeling.backend.db_models import LakebaseSchemaVersion

    monkeypatch.setattr(_reg, "INSTALL_POLICY", "permissive")
    monkeypatch.setattr(_reg, "PRE_PROD_DESTRUCTIVE_RESET", False)

    engine = _new_engine()
    migrations.reconcile_schema(engine)

    # Singleton row exists at id=1 with the latest version.
    insp = inspect(engine)
    assert insp.has_table("_lakebase_schema_version"), "schema version table not created"
    with Session(bind=engine) as session:
        row = session.exec(
            select(LakebaseSchemaVersion).where(LakebaseSchemaVersion.id == 1)
        ).first()
        assert row is not None, "no version row written after fresh reconcile"
        assert row.version == migrations.MIGRATIONS[-1].version


def test_reconcile_no_op_when_already_at_latest(monkeypatch):
    """Stream A — Stored version == latest → reconcile is a no-op (no migration
    applied a second time)."""
    from vibe_modeling.backend import migrations
    from vibe_modeling.backend.migrations import registry as _reg

    engine = _new_engine()
    monkeypatch.setattr(_reg, "INSTALL_POLICY", "permissive")
    monkeypatch.setattr(_reg, "PRE_PROD_DESTRUCTIVE_RESET", False)

    # Apply once.
    migrations.reconcile_schema(engine)

    # Spy: replace each migration's apply with a counter.
    calls = {"n": 0}

    def _spy(m_engine):  # pragma: no cover — counts only
        calls["n"] += 1

    spied = [
        type(m)(version=m.version, apply=_spy, description=m.description)
        for m in migrations.MIGRATIONS
    ]
    monkeypatch.setattr(_reg, "MIGRATIONS", spied)

    migrations.reconcile_schema(engine)
    assert calls["n"] == 0, "reconcile re-applied migrations even though already at latest"


def test_reconcile_refuses_downgrade(monkeypatch):
    """Stream A — Stored version newer than latest → raises LakebaseInstallError."""
    from vibe_modeling.backend import migrations
    from vibe_modeling.backend.migrations import registry as _reg
    from vibe_modeling.backend.db_models import LakebaseSchemaVersion
    from datetime import datetime, timezone

    engine = _new_engine()
    monkeypatch.setattr(_reg, "INSTALL_POLICY", "permissive")
    monkeypatch.setattr(_reg, "PRE_PROD_DESTRUCTIVE_RESET", False)

    # Bootstrap the schema, then write a fake "future" version.
    migrations.reconcile_schema(engine)
    with Session(bind=engine) as session:
        row = session.exec(
            select(LakebaseSchemaVersion).where(LakebaseSchemaVersion.id == 1)
        ).first()
        assert row is not None
        row.version = "9.9.9"  # well above any reasonable latest
        row.applied_at = datetime.now(timezone.utc)
        session.add(row)
        session.commit()

    with pytest.raises(migrations.LakebaseInstallError):
        migrations.reconcile_schema(engine)


def test_reconcile_strict_policy_refuses_nonempty_schema(monkeypatch):
    """Stream A — strict policy refuses fresh install when public schema is
    non-empty.

    SQLite has no `public` schema, so the strict-fresh check only triggers on
    Postgres. We therefore monkeypatch `_is_postgres` to return True and
    `_list_public_tables` to return something non-empty.
    """
    from vibe_modeling.backend import migrations
    from vibe_modeling.backend.migrations import registry as _reg

    engine = _new_engine()  # SQLite — but we lie about its dialect.

    monkeypatch.setattr(_reg, "INSTALL_POLICY", "strict")
    monkeypatch.setattr(_reg, "PRE_PROD_DESTRUCTIVE_RESET", False)
    monkeypatch.setattr(_reg, "_is_postgres", lambda eng: True)
    monkeypatch.setattr(_reg, "_list_public_tables", lambda eng: ["stray_table"])

    with pytest.raises(migrations.LakebaseInstallError):
        migrations.reconcile_schema(engine)


def test_reconcile_destructive_reset_wipes_and_recreates(monkeypatch):
    """Stream A — PRE_PROD_DESTRUCTIVE_RESET=True + version mismatch drops the
    schema and re-applies all migrations from scratch.

    We seed a row in `businesses`, simulate a version mismatch (write an older
    version into the singleton), then call reconcile and assert the row is
    gone — the schema has been wiped + recreated.
    """
    from vibe_modeling.backend import migrations
    from vibe_modeling.backend.migrations import registry as _reg
    from vibe_modeling.backend.db_models import (
        Business,
        LakebaseSchemaVersion,
    )

    engine = _new_engine()
    monkeypatch.setattr(_reg, "INSTALL_POLICY", "permissive")
    monkeypatch.setattr(_reg, "PRE_PROD_DESTRUCTIVE_RESET", True)

    # Initial reconcile to bootstrap the schema.
    migrations.reconcile_schema(engine)

    # Seed a Business row that we expect to be wiped on the next reconcile.
    with Session(bind=engine) as session:
        b = Business(name="Pre-wipe Co", description="x")
        session.add(b)
        session.commit()
        seeded_id = b.id

    # Force a version mismatch by writing an older version into the singleton.
    with Session(bind=engine) as session:
        row = session.exec(
            select(LakebaseSchemaVersion).where(LakebaseSchemaVersion.id == 1)
        ).first()
        assert row is not None
        row.version = "0.0.1"  # older than 0.1.0 → mismatch
        session.add(row)
        session.commit()

    # Reconcile with destructive reset on.
    migrations.reconcile_schema(engine)

    # Schema rebuilt → the seeded business row should be gone.
    with Session(bind=engine) as session:
        survivor = session.get(Business, seeded_id)
    assert survivor is None, "destructive reset did not wipe the prior schema"

    # Version row reflects the new latest.
    with Session(bind=engine) as session:
        row = session.exec(
            select(LakebaseSchemaVersion).where(LakebaseSchemaVersion.id == 1)
        ).first()
        assert row is not None
        assert row.version == migrations.MIGRATIONS[-1].version
