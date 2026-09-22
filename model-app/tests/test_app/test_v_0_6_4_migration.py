"""Apply + idempotency test for migration v_0_6_4 (Industry Management spine).

v_0_6_4 is the single in-flight 0.6.4 migration. It:

* CREATEs the ``sectors`` table (two-level taxonomy top level, ADR D-047).
* Adds four columns to ``businesses``: ``kind`` (discriminator, NOT NULL
  DEFAULT 'business'), ``sector_id``, ``source_industry_id``, ``source_version``.
* Adds six GitHub-config columns to ``agent_config`` (ADR D-049).

The pre-migration engine builds minimal ``businesses`` + ``agent_config``
tables (so the ADDs have work and the PRAGMA guards see the absence) and omits
``sectors`` (so the CREATE has work). create_all is avoided because the current
SQLModel metadata already carries every v_0_6_4 column/table, which would mask
the ALTERs.
"""

from __future__ import annotations

from sqlalchemy import inspect, text
from sqlalchemy.pool import StaticPool
from sqlmodel import create_engine

from vibe_modeling.backend import migrations
from vibe_modeling.backend.migrations import v_0_6_3, v_0_6_4


def _fresh_engine():
    return create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )


def _pre_migration_engine():
    """businesses + agent_config without the v_0_6_4 columns; no sectors."""
    engine = _fresh_engine()
    with engine.begin() as conn:
        conn.execute(text("DROP TABLE IF EXISTS sectors"))
        conn.execute(text("CREATE TABLE businesses (id VARCHAR NOT NULL PRIMARY KEY)"))
        conn.execute(text("CREATE TABLE agent_config (id VARCHAR NOT NULL PRIMARY KEY)"))
    return engine


def test_migration_version_string():
    assert v_0_6_4.MIGRATION.version == "0.6.4"


def test_migration_is_registered():
    assert v_0_6_4.MIGRATION in migrations.MIGRATIONS


def test_follows_v_0_6_3():
    idx = migrations.MIGRATIONS.index(v_0_6_3.MIGRATION)
    assert migrations.MIGRATIONS[idx + 1] is v_0_6_4.MIGRATION


def test_migrations_are_ascending():
    versions = [m.version for m in migrations.MIGRATIONS]
    assert versions == sorted(
        versions, key=lambda v: tuple(int(x) for x in v.split("."))
    )


def test_apply_creates_sectors_table():
    engine = _pre_migration_engine()
    assert "sectors" not in set(inspect(engine).get_table_names())

    v_0_6_4.MIGRATION.apply(engine)

    insp = inspect(engine)
    assert "sectors" in set(insp.get_table_names())
    cols = {c["name"] for c in insp.get_columns("sectors")}
    assert {
        "id", "name", "short_name", "description",
        "display_order", "is_active", "created_at", "updated_at",
    } <= cols


def test_apply_adds_business_columns():
    engine = _pre_migration_engine()
    before = {c["name"] for c in inspect(engine).get_columns("businesses")}
    assert not ({"kind", "sector_id", "source_industry_id", "source_version"} & before)

    v_0_6_4.MIGRATION.apply(engine)

    after = {c["name"] for c in inspect(engine).get_columns("businesses")}
    assert {"kind", "sector_id", "source_industry_id", "source_version"} <= after


def test_kind_is_not_nullable_with_default():
    engine = _pre_migration_engine()
    v_0_6_4.MIGRATION.apply(engine)
    kind = next(
        c for c in inspect(engine).get_columns("businesses") if c["name"] == "kind"
    )
    assert kind["nullable"] is False
    # Existing rows backfill to 'business'.
    with engine.begin() as conn:
        conn.execute(text("INSERT INTO businesses (id) VALUES ('b1')"))
        val = conn.execute(text("SELECT kind FROM businesses WHERE id='b1'")).scalar()
    assert val == "business"


def test_provenance_columns_are_nullable():
    engine = _pre_migration_engine()
    v_0_6_4.MIGRATION.apply(engine)
    cols = {c["name"]: c for c in inspect(engine).get_columns("businesses")}
    for name in ("sector_id", "source_industry_id", "source_version"):
        assert cols[name]["nullable"] is True


def test_apply_adds_agent_config_github_columns():
    engine = _pre_migration_engine()
    v_0_6_4.MIGRATION.apply(engine)
    cols = {c["name"] for c in inspect(engine).get_columns("agent_config")}
    assert {
        "github_repo_owner", "github_repo_name", "github_auth_mode",
        "github_connection_name", "github_secret_scope", "github_secret_key",
    } <= cols


def test_apply_creates_indexes():
    engine = _pre_migration_engine()
    v_0_6_4.MIGRATION.apply(engine)
    insp = inspect(engine)
    biz_indexed: set[str] = set()
    for ix in insp.get_indexes("businesses"):
        biz_indexed.update(ix["column_names"])
    assert {"kind", "sector_id", "source_industry_id"} <= biz_indexed
    sector_indexed: set[str] = set()
    for ix in insp.get_indexes("sectors"):
        sector_indexed.update(ix["column_names"])
    assert "short_name" in sector_indexed


def test_apply_is_idempotent():
    engine = _pre_migration_engine()
    v_0_6_4.MIGRATION.apply(engine)
    # Second apply must not raise (reconcile partial-failure retry).
    v_0_6_4.MIGRATION.apply(engine)
    insp = inspect(engine)
    assert "sectors" in set(insp.get_table_names())
    biz_cols = {c["name"] for c in insp.get_columns("businesses")}
    assert {"kind", "sector_id", "source_industry_id", "source_version"} <= biz_cols
