"""Shared fixtures for app tests.

Creates a FastAPI TestClient that uses the real router.py routes with
dependency overrides: in-memory SQLite for Lakebase, mock Databricks SDK,
and a test AppConfig.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

# Tests assume the production behaviour where forwarded headers are honoured —
# they pass X-Forwarded-* values directly to TestClient. Force the C-08 gate
# ON so tests behave as if running behind the trusted Databricks Apps proxy.
# Tests covering the OFF path manage this env var explicitly.
os.environ.setdefault("TRUST_FORWARDED_HEADERS", "1")

import pytest
from unittest.mock import MagicMock

from fastapi import FastAPI
from fastapi.testclient import TestClient
from sqlmodel import SQLModel, Session, create_engine
from sqlalchemy.pool import StaticPool

from vibe_modeling.backend.router import router
from vibe_modeling.backend import explorer as _explorer  # noqa: F401 — register explorer routes
from vibe_modeling.backend import diagram as _diagram  # noqa: F401 — register diagram routes
from vibe_modeling.backend.routes import (
    _dev_fixtures as _routes_dev_fixtures,
    businesses as _routes_businesses,
    config as _routes_config,
    deployment as _routes_deployment,
    import_root as _routes_import_root,
    industries as _routes_industries,
    industry_models as _routes_industry_models,
    platform as _routes_platform,
    sectors as _routes_sectors,
    sources as _routes_sources,
    uc_browse as _routes_uc_browse,
    versions as _routes_versions,
    vibe_inputs as _routes_vibe_inputs,
)

# Routers registered on the per-resource modules (plan task #33). The legacy
# `router` still owns /runs/* — see backend/router.py.
_SUB_ROUTERS = (
    _routes_platform.router,
    _routes_industries.router,
    _routes_sectors.router,
    _routes_sources.router,
    _routes_industry_models.router,
    _routes_config.router,
    _routes_businesses.router,
    _routes_versions.router,
    _routes_deployment.router,
    _routes_uc_browse.router,
    _routes_import_root.router,
    _routes_dev_fixtures.router,
    _routes_vibe_inputs.router,
)
from vibe_modeling.backend.core._config import AppConfig
from vibe_modeling.backend.core._defaults import (
    _ConfigDependency,
    _WorkspaceClientDependency,
)
from vibe_modeling.backend.core._tracker import _TrackerDependency
from vibe_modeling.backend.core.lakebase import _LakebaseDependency
from vibe_modeling.backend.db_models import (
    AgentConfig,
    Attribute,
    Business,
    BusinessContext,
    Domain,
    ForeignKeyLink,
    ModelVersion,
    Product,
    Run,
    RunArtifact,
    RunProgressEvent,
)

@pytest.fixture(autouse=True)
def _isolate_diagram_prefetch(monkeypatch):
    """Neutralize the background diagram-layout prefetch + clear its caches
    around every test.

    The prefetch worker is a pure performance optimization (warm the diagram
    cache). It runs asynchronously and, as a side effect of ``_load_model``,
    repopulates ``explorer._model_cache``. A job queued by one test that
    completes during a later test then races assertions which expect that
    cache to stay empty after an invalidation (e.g. import-from-volume) — a
    flaky cross-test leak whose timing depends on whether the persistent ELK
    subprocess is already warm. Making ``_prefetch_pool.submit`` a no-op in
    tests removes the background recompute entirely; tests that exercise the
    prefetch path stub ``submit`` themselves and that stub overrides this one.
    """
    from vibe_modeling.backend import diagram as _diagram_mod

    def _clear() -> None:
        with _diagram_mod._in_progress_lock:
            _diagram_mod._in_progress.clear()
        with _diagram_mod._cache_lock:
            _diagram_mod._layout_cache.clear()

    class _NoopFuture:
        def result(self, timeout=None):
            return None

    _clear()
    monkeypatch.setattr(
        _diagram_mod._prefetch_pool, "submit", lambda *a, **kw: _NoopFuture()
    )
    yield
    _clear()


@pytest.fixture(autouse=True)
def _ensure_operations_registry():
    """Re-populate the operations registry between tests.

    Some primitive-level test modules call ``_registry.reset_for_tests()``
    in their own autouse fixtures to start with a clean slate. That
    leaves the registry empty for subsequent tests that exercise the
    Phase 4 ``POST /runs`` route (which looks primitives up via
    ``validate_dag_request``). Re-importing the operations package
    here is idempotent — ``register`` raises on duplicates, which we
    swallow so the same fixture is safe to run before every test.
    """
    from vibe_modeling.backend.services.operations import (
        EnlargeToEcm,
        GenerateEcm,
        GenerateSamples,
        Install,
        ShrinkToMvm,
        Uninstall,
        register,
    )

    for _op_cls in (
        GenerateEcm, ShrinkToMvm, EnlargeToEcm,
        Install, Uninstall, GenerateSamples,
    ):
        try:
            register(_op_cls())
        except ValueError:
            pass


@pytest.fixture(name="engine")
def engine_fixture():
    """In-memory SQLite engine with all tables created."""
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    return engine

@pytest.fixture(name="fk_engine")
def fk_engine_fixture():
    """In-memory SQLite engine with FOREIGN KEY enforcement turned ON.

    SQLite ignores FK constraints unless ``PRAGMA foreign_keys=ON`` is set
    per-connection. The default ``engine`` fixture (and the ~150 tests that
    rely on it) deliberately runs WITHOUT enforcement — they seed partial
    graphs and would break under strict FKs. This opt-in fixture is the
    only place we enforce them, so cascade-order regressions (the prod 500)
    are reproduced in tests. Do NOT fold this into ``engine``.
    """
    from sqlalchemy import event

    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )

    @event.listens_for(engine, "connect")
    def _enable_fk(dbapi_connection, _connection_record):
        cursor = dbapi_connection.cursor()
        cursor.execute("PRAGMA foreign_keys=ON")
        cursor.close()

    SQLModel.metadata.create_all(engine)
    return engine


@pytest.fixture(name="fk_client")
def fk_client_fixture(fk_engine, mock_ws, config):
    """TestClient bound to the FK-enforcing engine.

    Mirrors the ``client`` fixture's dependency overrides but points the
    session + a real Orchestrator-less tracker at ``fk_engine`` so the
    delete routes run against a database that actually enforces the FKs
    the manual cascade has to respect.
    """
    from unittest.mock import MagicMock as _MagicMock

    tracker = _MagicMock()
    tracker.start_tracking = _MagicMock()
    tracker.stop_tracking = _MagicMock()
    tracker.get_active_runs = _MagicMock(return_value=[])

    app = FastAPI()
    app.include_router(router)
    for _r in _SUB_ROUTERS:
        app.include_router(_r)

    def override_session():
        with Session(fk_engine) as session:
            yield session

    def override_config():
        return config

    def override_ws():
        return mock_ws

    def override_tracker():
        return tracker

    app.dependency_overrides[_LakebaseDependency.__call__] = override_session
    app.dependency_overrides[_ConfigDependency.__call__] = override_config
    app.dependency_overrides[_WorkspaceClientDependency.__call__] = override_ws
    app.dependency_overrides[_TrackerDependency.__call__] = override_tracker

    return TestClient(app)


@pytest.fixture(name="mock_ws")
def mock_ws_fixture():
    """Mock Databricks WorkspaceClient.

    Simulates an EMPTY Volume filesystem for existence probes:
    ``files.get_metadata`` raises ``NotFound`` by default, so Volume-probe
    code (e.g. explorer's ``_find_model_json_path``) falls through to its
    Lakebase/None branches the same way it would against a real workspace
    with no artifacts written. Tests that need a specific Volume file present
    override this side_effect. Without it, a bare MagicMock returns truthy
    sentinels for every ``get_metadata`` call, making draft versions (whose
    model.json/docs now resolve under the metamodel catalog) appear to have
    files that don't exist. ``list_directory_contents`` is left as a default
    MagicMock so directory-listing tests can set their own return_value.
    """
    from databricks.sdk.errors.platform import NotFound

    ws = MagicMock()
    ws.config.host = "https://test-workspace.databricks.com"
    ws.files.get_metadata.side_effect = NotFound("mock: no such file")
    return ws

@pytest.fixture(name="config")
def config_fixture():
    """Test AppConfig used by the client fixture's `config: Dependencies.Config` override.

    Carries non-empty ``deployment_catalog`` and ``warehouse_id`` so the lazy
    AgentConfig bootstrap can be observed end-to-end in route tests.
    """
    return AppConfig(
        app_name="test",
        warehouse_id="test-warehouse-id",
        deployment_catalog="test_deployment_catalog",
        poll_interval_seconds=1,
    )

@pytest.fixture(name="mock_tracker")
def mock_tracker_fixture(engine, mock_ws):
    """Mock ProgressTracker with a real Orchestrator.

    Phase 4 wirers route through ``tracker.orchestrator`` for the
    DAG-driven intents. We bind a real :class:`Orchestrator` to the
    in-memory test engine so route-level smoke tests can drive
    ``start`` + ``advance`` against the actual session, while the
    polling-loop methods (``start_tracking`` / ``stop_tracking``) remain
    mocks (the test client doesn't run an asyncio loop).

    The real Orchestrator covers both groups of wirers:

    - The simple intents (vibe-iterate / install / uninstall /
      generate-samples) dispatch via the registered single-step
      primitives.
    - The unified ``new-base-model`` intent dispatches its multi-step
      DAG against the same primitives.
    """
    from sqlmodel import Session as _Session

    from vibe_modeling.backend.services.orchestrator import Orchestrator

    tracker = MagicMock()
    tracker.start_tracking = MagicMock()
    tracker.stop_tracking = MagicMock()
    tracker.get_active_runs = MagicMock(return_value=[])

    def _session_factory() -> _Session:
        return _Session(bind=engine)

    tracker.orchestrator = Orchestrator(mock_ws, _session_factory)
    return tracker

@pytest.fixture(name="client")
def client_fixture(engine, mock_ws, config, mock_tracker):
    """FastAPI TestClient using the real router with dependency overrides."""
    app = FastAPI()
    app.include_router(router)
    for _r in _SUB_ROUTERS:
        app.include_router(_r)

    def override_session():
        with Session(engine) as session:
            yield session

    def override_config():
        return config

    def override_ws():
        return mock_ws

    def override_tracker():
        return mock_tracker

    app.dependency_overrides[_LakebaseDependency.__call__] = override_session
    app.dependency_overrides[_ConfigDependency.__call__] = override_config
    app.dependency_overrides[_WorkspaceClientDependency.__call__] = override_ws
    app.dependency_overrides[_TrackerDependency.__call__] = override_tracker

    return TestClient(app)

@pytest.fixture(name="client_with_agent")
def client_with_agent_fixture(engine, mock_ws, config, mock_tracker):
    """TestClient with an AgentConfig seeded in the DB, for testing run paths."""
    with Session(engine) as session:
        ac = AgentConfig(
            notebook_path="/Workspace/test/notebook",
            job_id=99,
            job_name="test_vibe_job",
            deployment_catalog="test_metamodel_catalog",
            # Warehouse is a run-preflight requirement (Track 4): a fully
            # configured agent has one, so run-path tests seed it here.
            warehouse_id="test-warehouse-id",
        )
        session.add(ac)
        session.commit()

    app = FastAPI()
    app.include_router(router)
    for _r in _SUB_ROUTERS:
        app.include_router(_r)

    def override_session():
        with Session(engine) as session:
            yield session

    def override_config():
        return config

    def override_ws():
        return mock_ws

    def override_tracker():
        return mock_tracker

    app.dependency_overrides[_LakebaseDependency.__call__] = override_session
    app.dependency_overrides[_ConfigDependency.__call__] = override_config
    app.dependency_overrides[_WorkspaceClientDependency.__call__] = override_ws
    app.dependency_overrides[_TrackerDependency.__call__] = override_tracker

    return TestClient(app)

@pytest.fixture
def seed_business(engine) -> str:
    """Create a business and return its id (no completed ModelVersion)."""
    with Session(engine) as session:
        b = Business(name="Test Corp", description="A test company", industry_alignment="Retail")
        session.add(b)
        session.commit()
        session.refresh(b)
        return b.id


@pytest.fixture
def seed_business_with_version(engine) -> str:
    """Create a business + one completed ModelVersion (v1, ECM), return id.

    Use for run-creation tests that submit a version-bound intent
    (``vibe-iterate`` / ``install`` / ``uninstall`` /
    ``generate-samples``). Without a resolvable completed ModelVersion the
    router 422s (post-uninstall-diagnosis 2026-05-18).
    """
    with Session(engine) as session:
        b = Business(name="Test Corp", description="A test company", industry_alignment="Retail")
        session.add(b)
        session.commit()
        session.refresh(b)
        mv = ModelVersion(
            business_id=b.id,
            version=1,
            status="completed",
            scope="ecm",
        )
        session.add(mv)
        session.commit()
        return b.id


@pytest.fixture
def seed_business_with_context(engine, seed_business) -> tuple[str, str]:
    """Create a business with a context, return (business_id, context_id)."""
    with Session(engine) as session:
        ctx = BusinessContext(
            business_id=seed_business,
            version_label="v1.0",
            context_json='{"business": "test"}',
            conventions_json='{"pk_suffix": "_id"}',
        )
        session.add(ctx)
        session.commit()
        session.refresh(ctx)
        return seed_business, ctx.id

@pytest.fixture
def seed_agent_config(engine) -> str:
    """Create an agent config and return its id."""
    with Session(engine) as session:
        ac = AgentConfig(
            notebook_path="/Workspace/test/notebook",
            job_id=99,
            job_name="test_vibe_job",
            deployment_catalog="test_metamodel_catalog",
            # Warehouse is a run-preflight requirement (Track 4): a fully
            # configured agent has one, so run-path tests seed it here.
            warehouse_id="test-warehouse-id",
        )
        session.add(ac)
        session.commit()
        session.refresh(ac)
        return ac.id

@pytest.fixture
def seed_run(engine, seed_business) -> tuple[str, str]:
    """Create a business with a pending run, return (business_id, run_id)."""
    with Session(engine) as session:
        run = Run(
            business_id=seed_business,
            intent="new-base-model",
            status="pending",
            parameters_json='{"operation": "new base model"}',
        )
        session.add(run)
        session.commit()
        session.refresh(run)
        return seed_business, run.id

@pytest.fixture
def seed_running_run(engine, seed_business) -> tuple[str, str]:
    """Create a business with a running run (has databricks_run_id), return (business_id, run_id)."""
    from datetime import datetime, timezone

    with Session(engine) as session:
        run = Run(
            business_id=seed_business,
            intent="new-base-model",
            status="running",
            databricks_run_id=12345,
            vibe_session_id="test-session-id",
            vibe_session_id_bigint=12345678,
            started_at=datetime.now(timezone.utc),
            parameters_json='{"operation": "new base model", "deployment_catalog": "test_cat"}',
        )
        session.add(run)
        session.commit()
        session.refresh(run)
        return seed_business, run.id

@pytest.fixture
def seed_failed_run(engine, seed_business) -> tuple[str, str]:
    """Create a business with a failed run, return (business_id, run_id)."""
    with Session(engine) as session:
        run = Run(
            business_id=seed_business,
            intent="new-base-model",
            status="failed",
            error_message="Something went wrong",
            databricks_run_id=12345,
            parameters_json='{"operation": "new base model"}',
        )
        session.add(run)
        session.commit()
        session.refresh(run)
        return seed_business, run.id
