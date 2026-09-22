"""Unit tests for the three catalog resolvers in ``core._catalogs``.

Each resolver is the single implementation of one catalog concern; these
tests pin the configured / unconfigured / override permutations so a future
change that re-introduces a cross-concern fallback trips a test.
"""

from __future__ import annotations

from types import SimpleNamespace

from sqlmodel import Session, select

from vibe_modeling.backend.core._catalogs import (
    resolve_metamodel_catalog,
    resolve_run_target_catalog,
    resolve_version_volume_catalog,
)
from vibe_modeling.backend.db_models import AgentConfig


# --- resolve_metamodel_catalog (concern A) ---------------------------------


def test_metamodel_catalog_seeds_from_env_on_fresh_db(engine, config):
    with Session(engine) as session:
        assert resolve_metamodel_catalog(session, config) == "test_deployment_catalog"
        # get-or-create persisted exactly one row seeded from the env config.
        rows = session.exec(select(AgentConfig)).all()
        assert len(rows) == 1
        assert rows[0].deployment_catalog == "test_deployment_catalog"


def test_metamodel_catalog_empty_when_unconfigured(engine):
    from vibe_modeling.backend.core._config import AppConfig

    empty_cfg = AppConfig(app_name="test", warehouse_id="", deployment_catalog="")
    with Session(engine) as session:
        assert resolve_metamodel_catalog(session, empty_cfg) == ""


def test_metamodel_catalog_reads_existing_row_not_env(engine, config):
    with Session(engine) as session:
        session.add(AgentConfig(deployment_catalog="already_set"))
        session.commit()
        # Existing row is authoritative; the env seed is not consulted again.
        assert resolve_metamodel_catalog(session, config) == "already_set"


# --- resolve_run_target_catalog (concern C) --------------------------------


def test_run_target_prefers_deployment_catalog_field():
    data = SimpleNamespace(deployment_catalog="run_dep", catalog="run_cat")
    cfg = SimpleNamespace(deployment_catalog="configured")
    assert resolve_run_target_catalog(data, cfg) == "run_dep"


def test_run_target_falls_back_to_catalog_alias():
    data = SimpleNamespace(deployment_catalog="", catalog="run_cat")
    cfg = SimpleNamespace(deployment_catalog="configured")
    assert resolve_run_target_catalog(data, cfg) == "run_cat"


def test_run_target_defaults_to_metamodel_catalog():
    data = SimpleNamespace(deployment_catalog="", catalog="")
    cfg = SimpleNamespace(deployment_catalog="configured")
    assert resolve_run_target_catalog(data, cfg) == "configured"


def test_run_target_empty_when_nothing_set():
    data = SimpleNamespace(catalog="")
    assert resolve_run_target_catalog(data, None) == ""


def test_run_target_strips_whitespace():
    data = SimpleNamespace(deployment_catalog="  spaced  ", catalog="")
    assert resolve_run_target_catalog(data, None) == "spaced"


# --- resolve_version_volume_catalog (per-version, concern A) ----------------


def test_version_volume_prefers_own_uc_catalog(engine, config):
    mv = SimpleNamespace(uc_catalog="installed_cat")
    with Session(engine) as session:
        assert (
            resolve_version_volume_catalog(mv, session, config) == "installed_cat"
        )


def test_version_volume_falls_back_to_metamodel_for_drafts(engine, config):
    # Draft version with empty uc_catalog resolves to the installation
    # metamodel catalog so its artifacts are still reachable (kickstart-class
    # bug fix: an empty uc_catalog must not yield an empty path).
    mv = SimpleNamespace(uc_catalog="")
    with Session(engine) as session:
        assert (
            resolve_version_volume_catalog(mv, session, config)
            == "test_deployment_catalog"
        )


def test_version_volume_handles_none_mv(engine, config):
    with Session(engine) as session:
        assert (
            resolve_version_volume_catalog(None, session, config)
            == "test_deployment_catalog"
        )


# --- session-only (config omitted) read path -------------------------------


def test_metamodel_catalog_session_only_reads_existing_row(engine):
    with Session(engine) as session:
        session.add(AgentConfig(deployment_catalog="from_row"))
        session.commit()
        # config omitted: session-only read, no seed, no write.
        assert resolve_metamodel_catalog(session) == "from_row"


def test_metamodel_catalog_session_only_no_seed_on_fresh_db(engine):
    with Session(engine) as session:
        # No row and no config: returns "" and creates NOTHING (no read-path
        # write - the Track 4 no-read-path-writes rule).
        assert resolve_metamodel_catalog(session) == ""
        assert session.exec(select(AgentConfig)).all() == []


def test_version_volume_session_only_draft_fallback(engine):
    mv = SimpleNamespace(uc_catalog="")
    with Session(engine) as session:
        session.add(AgentConfig(deployment_catalog="mm_cat"))
        session.commit()
        assert resolve_version_volume_catalog(mv, session) == "mm_cat"
