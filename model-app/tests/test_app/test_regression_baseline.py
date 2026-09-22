"""Regression baseline tests — capture API response shapes as snapshots.

These tests verify the structure (keys, types, nesting) of API responses.
If a future change alters a response shape, these tests fail, requiring
explicit review of the change. This is the "did I accidentally break the
API contract?" safety net.

Note: These test response *structure*, not specific values. Value assertions
are in the unit and flow tests.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import json

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    AgentConfig,
    Attribute,
    Business,
    BusinessContext,
    Domain,
    ModelVersion,
    Product,
    Run,
    RunProgressEvent,
)


@pytest.fixture
def seeded_app(engine):
    """Seed a complete application state for regression testing."""
    with Session(engine) as session:
        # Agent config
        ac = AgentConfig(
            notebook_path="/Workspace/test/notebook",
            job_id=99,
            job_name="test_vibe_job",
            deployment_catalog="test_metamodel_catalog",
        )
        session.add(ac)

        # Business
        b = Business(
            name="Regression Corp",
            description="For regression testing",
            industry_alignment="Technology",
        )
        session.add(b)
        session.flush()

        # Context
        ctx = BusinessContext(
            business_id=b.id,
            version_label="v1.0",
            context_json=json.dumps({
                "business_context": {
                    "business_information": {
                        "business": "Regression Corp",
                        "description": "For regression testing",
                        "industry_alignment": "Technology",
                        "core_business_processes": "Testing",
                        "orgnaization_divisions": "Engineering",
                        "data_domains": "Core",
                        "common_business_jargons": "",
                        "operational_systems_of_records": "",
                        "industry_governing_body": "",
                    },
                    "model_conventions": {"pk_suffix": "_id"},
                }
            }),
            conventions_json="{}",
        )
        session.add(ctx)

        # Model version
        mv = ModelVersion(business_id=b.id, version=1, scope="mvm", status="completed")
        session.add(mv)
        session.flush()

        # Domain + Product + Attributes
        d = Domain(
            version_id=mv.id, name="core", division="Engineering",
            description="Core domain", database_name="core_db",
        )
        session.add(d)
        session.flush()

        p = Product(
            version_id=mv.id, domain_id=d.id, name="widget",
            table_name="widget", description="Widget records",
            type="Master", primary_key="widget_id",
        )
        session.add(p)
        session.flush()

        session.add(Attribute(
            product_id=p.id, name="widget_id", column_name="widget_id",
            type="BIGINT", description="PK",
        ))

        # Run with progress events
        run = Run(
            business_id=b.id,
            intent="new-base-model",
            status="completed",
            databricks_run_id=12345,
            vibe_session_id="test-session",
            progress_percent=100,
            progress_message="Complete",
            parameters_json='{"operation": "new base model"}',
        )
        session.add(run)
        session.flush()

        event = RunProgressEvent(
            run_id=run.id,
            step_id=1,
            event_seq=1,
            stage_name="Pipeline",
            step_name="Generate",
            status="completed",
            message="Done",
            progress_increment=100.0,
            result_json="{}",
        )
        session.add(event)

        session.commit()
        return {
            "business_id": b.id,
            "version_id": mv.id,
            "version_int": mv.version,
            "scope": mv.scope,
            "run_id": run.id,
        }


# ---------------------------------------------------------------------------
# Response shape assertions
# ---------------------------------------------------------------------------


def _assert_keys(data: dict, required_keys: set, msg: str = ""):
    """Assert that data contains exactly the required keys."""
    actual = set(data.keys())
    missing = required_keys - actual
    extra = actual - required_keys
    assert not missing, f"{msg} Missing keys: {missing}"
    assert not extra, f"{msg} Unexpected keys: {extra}"


class TestBusinessResponseShape:
    EXPECTED_KEYS = {
        "id", "name", "description", "business_vibes", "industry_alignment",
        "kind", "sector_id", "source_industry_id", "source_version",
        "source_repo_path",
        "created_at", "updated_at",
    }
    LIST_KEYS = {
        "id", "name", "industry_alignment", "kind", "sector_id",
        "source_industry_id", "source_version",
        "model_count", "downloaded_scopes", "created_at",
    }

    def test_business_detail_shape(self, client, seeded_app):
        resp = client.get(f"/api/businesses/{seeded_app['business_id']}")
        assert resp.status_code == 200
        _assert_keys(resp.json(), self.EXPECTED_KEYS, "BusinessOut")

    def test_business_list_shape(self, client, seeded_app):
        resp = client.get("/api/businesses")
        assert resp.status_code == 200
        items = resp.json()
        assert len(items) > 0
        _assert_keys(items[0], self.LIST_KEYS, "BusinessListOut")

    # M2: create/update now return an OBJECT detail on a name clash (was a
    # plain string). Pin the object shape so it can't silently regress.
    NAME_CONFLICT_DETAIL_KEYS = {"error", "name", "message"}

    def test_create_name_conflict_detail_shape(self, client):
        assert client.post(
            "/api/businesses", json={"name": "Shape Co", "description": "d"}
        ).status_code == 200
        resp = client.post("/api/businesses", json={"name": "shape_co", "description": "d"})
        assert resp.status_code == 409, resp.text
        detail = resp.json()["detail"]
        assert isinstance(detail, dict)
        _assert_keys(detail, self.NAME_CONFLICT_DETAIL_KEYS, "create 409 detail")
        assert detail["error"] == "business_name_taken"

    def test_update_name_conflict_detail_shape(self, client):
        client.post("/api/businesses", json={"name": "Shape Co", "description": "d"})
        other = client.post(
            "/api/businesses", json={"name": "Other Co", "description": "d"}
        ).json()
        resp = client.put(
            f"/api/businesses/{other['id']}", json={"name": "shape_co", "description": "d"}
        )
        assert resp.status_code == 409, resp.text
        detail = resp.json()["detail"]
        assert isinstance(detail, dict)
        _assert_keys(detail, self.NAME_CONFLICT_DETAIL_KEYS, "update 409 detail")
        assert detail["error"] == "business_name_taken"


class TestModelVersionOutProvenanceShape:
    """v_0_7_0: ModelVersionOut gains agent_version/release_version — additive,
    both optional and defaulting to None so existing clients stay valid."""

    def test_new_fields_present_and_optional(self):
        from vibe_modeling.backend.models import ModelVersionOut

        fields = ModelVersionOut.model_fields
        assert "agent_version" in fields
        assert "release_version" in fields
        # Additive: optional with a None default, so a payload without them
        # still validates.
        assert fields["agent_version"].default is None
        assert fields["release_version"].default is None
        out = ModelVersionOut.model_validate(
            {
                "id": "v1",
                "business_id": "b1",
                "version": 1,
                "status": "completed",
                "deployment_status": "draft",
                "base_version_id": None,
                "vibe_instructions": "",
                "context_id": None,
                "confidence_score": None,
                "uc_catalog": "",
                "completion_date": None,
                "created_at": "2026-01-01T00:00:00Z",
            }
        )
        assert out.agent_version is None
        assert out.release_version is None


class TestPublishResponseShape:
    """The publish endpoint response gains ``target_path`` (the resolved bundle
    root used) alongside the branch/PR fields (ADR D-049)."""

    EXPECTED_KEYS = {"branch", "pr_number", "pr_url", "files", "target_path"}

    def test_publish_out_model_fields(self):
        from vibe_modeling.backend.routes.industry_models import (
            PublishModelVersionOut,
        )

        assert set(PublishModelVersionOut.model_fields) == self.EXPECTED_KEYS


class TestRunResponseShape:
    EXPECTED_KEYS = {
        "id", "business_id", "version_id", "status",
        "databricks_run_id", "vibe_session_id", "run_page_url",
        "progress_percent", "progress_message", "error_message",
        "parameters_json", "vibe_instructions_text",
        "vibe_instructions_volume_path",
        # Migration 0.2.0: the user-typed business context the run was
        # created with. Empty string for legacy runs and ops that don't
        # carry user-typed context (revert, import, install, etc.).
        "business_context_text",
        "started_at", "completed_at", "created_at",
        # Phase 4 (orchestrator refactor §8): durable label set on
        # the Run row at create time. Empty string for legacy runs.
        "intent",
        # D-09 watchdog signals (plan task #51): two persisted fields
        # (last_jobs_api_state, last_poll_error) and three derived fields
        # (watchdog_state, watchdog_warm_up_seconds_remaining,
        # elapsed_seconds). All five are required on RunOut.
        "watchdog_state", "watchdog_warm_up_seconds_remaining",
        "last_jobs_api_state", "last_poll_error", "elapsed_seconds",
        # Phase 4 (orchestrator design §2.4 + §8): validator warnings
        # echoed back on POST /runs and surfaced on GET /runs/{id} as
        # an empty list when no warnings were produced at create time.
        "warnings",
        # v0.4.0 #4b: agent-emitted Version Resolution events for this
        # run (auto-collision-resolved). Empty list on the happy path;
        # derived from the run's RunProgressEvent rows.
        "version_resolutions",
    }

    def test_run_detail_shape(self, client, seeded_app):
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/runs/{seeded_app['run_id']}")
        assert resp.status_code == 200
        _assert_keys(resp.json(), self.EXPECTED_KEYS, "RunOut")


class TestProgressEventShape:
    EXPECTED_KEYS = {
        "id", "run_id", "step_id", "event_seq", "stage_name",
        "step_name", "status", "message", "progress_increment",
        "result_json", "created_at",
    }

    def test_progress_events_shape(self, client, seeded_app):
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/runs/{seeded_app['run_id']}/progress")
        assert resp.status_code == 200
        events = resp.json()
        assert len(events) > 0
        _assert_keys(events[0], self.EXPECTED_KEYS, "ProgressEventOut")


class TestAgentConfigShape:
    EXPECTED_KEYS = {
        "id", "notebook_path", "job_id",
        "job_name", "job_url",
        # deployment_catalog STAYS (legacy FE surfaces read it); metamodel_catalog
        # is its concern-A rename, mirrored to the same value (Track 4).
        "deployment_catalog", "metamodel_catalog", "warehouse_id",
        "max_concurrent_runs",
        "collect_vibe_run_statistics",
        "created_at", "updated_at",
    }

    def test_agent_config_shape(self, client, seeded_app):
        resp = client.get("/api/config/agent")
        assert resp.status_code == 200
        _assert_keys(resp.json(), self.EXPECTED_KEYS, "AgentConfigOut")


class TestExplorerResponseShapes:
    def test_model_summary_shape(self, client, seeded_app):
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/versions/1/mvm/model")
        assert resp.status_code == 200
        data = resp.json()
        expected = {
            "name", "version", "description", "industry_alignment",
            "core_business_processes", "vibe_modeling_instructions",
            "domain_count", "subdomain_count", "product_count",
            "attribute_count", "fk_count", "confidence_score",
            "review_pct", "reviewed_count", "review_needed_count",
            "no_review_needed_count", "domains",
        }
        _assert_keys(data, expected, "ModelSummaryOut")

        # Domain summary shape
        assert len(data["domains"]) > 0
        domain_keys = {
            "id", "name", "division", "description", "database_name",
            "references", "product_count", "subdomains", "change_status",
        }
        _assert_keys(data["domains"][0], domain_keys, "DomainSummaryOut")

    def test_evolution_metrics_shape(self, client, seeded_app):
        """T16 model-scope evolution metrics. seeded_app has no Volume
        model.json → the metadata-less degraded shape: size from the
        Lakebase structure, every flag False."""
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/versions/1/mvm/evolution-metrics")
        assert resp.status_code == 200
        data = resp.json()
        expected = {
            "version_id", "size", "quality", "change", "effort",
            "provenance", "has_metadata", "has_confidence", "has_predecessor",
        }
        _assert_keys(data, expected, "EvolutionMetricsOut")
        _assert_keys(
            data["size"],
            {
                "domain_count", "product_count", "attribute_count", "fk_count",
                "unlinked_id_count", "siloed_count", "avg_attributes_per_product",
            },
            "EvolutionSizeOut",
        )
        _assert_keys(
            data["quality"],
            {
                "confidence_score", "error_count", "warning_count", "info_count",
                "issues_addressed", "issues_not_addressed",
            },
            "EvolutionQualityOut",
        )
        _assert_keys(
            data["change"],
            {
                "version_trend", "model_touched_pct",
                "products_added", "products_modified", "products_removed",
                "confidence_delta",
                "warnings_delta", "errors_delta", "unlinked_delta",
                "previous_confidence", "previous_warnings", "previous_errors",
                "previous_unlinked", "version_history",
            },
            "EvolutionChangeOut",
        )
        _assert_keys(
            data["effort"],
            {
                "total_ai_calls", "estimated_input_tokens",
                "estimated_output_tokens", "estimated_total_cost_usd",
                "per_model_cost_usd", "duration_hours",
            },
            "EvolutionEffortOut",
        )
        _assert_keys(
            data["provenance"],
            {
                "agent_version", "generated_from_version",
                "target_model_version", "status",
            },
            "EvolutionProvenanceOut",
        )
        assert data["has_metadata"] is False
        assert data["has_confidence"] is False
        assert data["has_predecessor"] is False
        # Size still degrades to the Lakebase-reconstructed structure.
        assert data["size"]["domain_count"] == 1
        assert data["size"]["product_count"] == 1

    def test_relationship_analysis_shape(self, client, seeded_app):
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/versions/1/mvm/relationships")
        assert resp.status_code == 200
        data = resp.json()
        expected = {
            "total_fk_count", "cross_domain_fk_count",
            "intra_domain_fk_count", "domain_connectivity",
        }
        _assert_keys(data, expected, "RelationshipAnalysisOut")

    def test_domain_detail_shape(self, client, seeded_app):
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/versions/1/mvm/domains/core")
        assert resp.status_code == 200
        data = resp.json()
        expected = {"name", "division", "description", "database_name", "references", "products"}
        _assert_keys(data, expected, "DomainDetailOut")

        # Product summary shape
        product_keys = {
            "id", "fqn", "name", "table_name", "description", "type", "data_type",
            "primary_key", "subdomain", "reference", "attribute_count",
            "fk_count", "fk_targets", "change_status",
        }
        _assert_keys(data["products"][0], product_keys, "ProductSummaryOut")

    def test_product_detail_shape(self, client, seeded_app):
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/versions/1/mvm/domains/core/products/widget")
        assert resp.status_code == 200
        data = resp.json()
        expected = {
            "id", "fqn", "name", "table_name", "description", "type", "data_type",
            "primary_key", "reference", "domain_name", "attributes",
        }
        _assert_keys(data, expected, "ProductDetailOut")

        # Attribute shape
        attr_keys = {
            "id", "name", "column_name", "type", "description",
            "business_glossary_term", "tags", "value_regex",
            "foreign_key_to", "references", "is_primary_key",
            "is_foreign_key", "change_status",
        }
        _assert_keys(data["attributes"][0], attr_keys, "AttributeOut")

    def test_version_tree_shape(self, client, seeded_app):
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/explorer/versions")
        assert resp.status_code == 200
        versions = resp.json()
        assert len(versions) > 0
        expected = {
            "id", "version", "status", "deployment_status",
            "base_version_id", "vibe_instructions", "confidence_score",
            "scope", "created_at", "is_base",
        }
        _assert_keys(versions[0], expected, "VersionTreeOut")

    def test_next_vibe_metrics_shape(self, client, seeded_app):
        """T13 model-scope metrics. seeded_app has no agent inputs → the
        degraded (pre-ingestion) shape: zeros, null score, has_data=False."""
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/versions/1/mvm/next-vibe-metrics")
        assert resp.status_code == 200
        data = resp.json()
        expected = {
            "version_id", "domain_id", "quality_score",
            "counts", "total_open", "has_data",
        }
        _assert_keys(data, expected, "NextVibeMetricsOut")
        count_keys = {"static_analysis", "priority_remediation", "other", "total"}
        _assert_keys(data["counts"], count_keys, "NextVibeCategoryCountsOut")
        assert data["domain_id"] is None
        assert data["has_data"] is False
        assert data["total_open"] == 0
        assert data["quality_score"] is None

    def test_domain_next_vibe_metrics_shape(self, client, seeded_app):
        """T13 domain-scope metrics — same shape, domain_id populated."""
        bid = seeded_app["business_id"]
        resp = client.get(
            f"/api/businesses/{bid}/versions/1/mvm/domains/core/next-vibe-metrics"
        )
        assert resp.status_code == 200
        data = resp.json()
        expected = {
            "version_id", "domain_id", "quality_score",
            "counts", "total_open", "has_data",
        }
        _assert_keys(data, expected, "NextVibeMetricsOut")
        assert data["domain_id"] is not None
        assert data["has_data"] is False


class TestVibeInputsResponseShapes:
    """Response-shape baselines for the Task 5 Vibe Inputs endpoints (§2).

    Catches silent contract breaks on the new surface. Uses the shared
    seeded_app (business + completed version + one domain).
    """

    HEADERS = {"X-Forwarded-Email": "baseline@x.com"}

    def _create(self, client, bid, vid, **extra):
        r = client.post(
            f"/api/businesses/{bid}/inputs",
            json={"text": "rule", "version_id": vid, **extra},
            headers=self.HEADERS,
        )
        assert r.status_code == 200, r.text
        return r.json()

    def test_input_out_shape(self, client, seeded_app):
        bid, vid = seeded_app["business_id"], seeded_app["version_id"]
        body = self._create(client, bid, vid)
        _assert_keys(body, {
            "id", "business_id", "origin", "author", "text", "category",
            "priority", "confidence_score", "consumed", "selected_for_run",
            "status", "deprecated_by", "created_at", "updated_at", "anchor",
        }, "VibeInputOut")
        # User-origin create carries a null category (feedback has no category).
        assert body["category"] is None
        # createVibeInput does not hydrate the anchor (list-only).
        assert body["anchor"] is None

    def test_list_input_out_anchor_hydrated(self, client, seeded_app, engine):
        bid, vid = seeded_app["business_id"], seeded_app["version_id"]
        # Resolve the seeded domain + product ids on the head version.
        from vibe_modeling.backend.db_models import Domain, Product
        with Session(engine) as session:
            d = session.exec(select(Domain).where(Domain.version_id == vid)).first()
            p = session.exec(select(Product).where(Product.version_id == vid)).first()
            domain_id, product_id = d.id, p.id
            domain_name, product_name = d.name, p.name

        # 1) Element-anchored input (domain + product).
        elem = self._create(
            client, bid, vid, text="product rule",
            domain_id=domain_id, product_id=product_id,
        )
        # 2) Model-wide input (link with all-null element ids).
        wide = self._create(client, bid, vid, text="model-wide rule")
        # 3) Input with NO link on the head version: create it, then delete
        #    its head-version link so it has no presence on the current model.
        orphan = self._create(client, bid, vid, text="orphan rule")
        links = client.get(
            f"/api/businesses/{bid}/inputs/{orphan['id']}/links"
        ).json()
        from vibe_modeling.backend.db_models import VibeInputContextLink
        with Session(engine) as session:
            for lk in links:
                session.delete(session.get(VibeInputContextLink, lk["id"]))
            session.commit()

        items = client.get(f"/api/businesses/{bid}/inputs").json()
        by_id = {it["id"]: it for it in items}

        a_elem = by_id[elem["id"]]["anchor"]
        assert a_elem is not None
        assert a_elem["level"] == "element"
        assert a_elem["domain_id"] == domain_id
        assert a_elem["domain_name"] == domain_name
        assert a_elem["product_id"] == product_id
        assert a_elem["product_name"] == product_name
        assert f"Product: {product_name}" in a_elem["path"]

        a_wide = by_id[wide["id"]]["anchor"]
        assert a_wide is not None
        assert a_wide["level"] == "model_wide"
        assert a_wide["path"] == []
        assert a_wide["product_id"] is None

        assert by_id[orphan["id"]]["anchor"] is None

    def test_link_out_shape(self, client, seeded_app):
        bid, vid = seeded_app["business_id"], seeded_app["version_id"]
        vi = self._create(client, bid, vid)
        links = client.get(f"/api/businesses/{bid}/inputs/{vi['id']}/links").json()
        _assert_keys(links[0], {
            "id", "input_id", "version_id", "domain_id", "subdomain_id",
            "product_id", "attribute_id", "fk_link_id", "is_origin",
            "needs_link_review", "reviewed_by", "reviewed_at", "created_at",
        }, "VibeInputContextLinkOut")

    def test_compile_out_shape(self, client, seeded_app):
        bid, vid = seeded_app["business_id"], seeded_app["version_id"]
        vi = self._create(client, bid, vid)
        body = client.post(
            f"/api/businesses/{bid}/versions/{vid}/inputs/compile",
            json={"input_ids": [vi["id"]]},
        ).json()
        _assert_keys(body, {
            "markdown", "blocks", "included_input_ids",
            "excluded_input_ids", "excluded_reasons",
        }, "CompileOut")

    def test_carry_forward_out_shape(self, client, seeded_app):
        bid, vid = seeded_app["business_id"], seeded_app["version_id"]
        body = client.post(
            f"/api/businesses/{bid}/versions/{vid}/inputs/carry-forward"
        ).json()
        _assert_keys(body, {
            "version_id", "auto_linked", "needs_review", "deprecated",
            "skipped_existing", "link_ids_needing_review",
        }, "CarryForwardResultOut")

    def test_review_queue_out_shape(self, client, seeded_app):
        bid = seeded_app["business_id"]
        body = client.get(f"/api/businesses/{bid}/links/review-queue").json()
        _assert_keys(body, {"total", "items"}, "ReviewQueueOut")

    def test_product_review_out_shape(self, client, seeded_app, engine):
        from sqlmodel import select as _select

        from vibe_modeling.backend.db_models import Product as _P
        bid, vid = seeded_app["business_id"], seeded_app["version_id"]
        vint, scope = seeded_app["version_int"], seeded_app["scope"]
        with Session(engine) as s:
            prod = s.exec(_select(_P).where(_P.version_id == vid)).first()
            pid = prod.id
        body = client.post(
            f"/api/businesses/{bid}/versions/{vint}/{scope}/reviews/product/{pid}",
            json={"state": "reviewed"}, headers=self.HEADERS,
        ).json()
        _assert_keys(body, {
            "id", "version_id", "product_id", "product_name", "fqn", "state",
            "reviewer", "reviewed_at", "is_explicit",
        }, "ProductReviewOut")


class TestPublishPreviewResponseShape:
    """The publish-preview endpoint (Story 3): tiered baseline diff, model.json
    only, degrade-open. Locks the wire contract (operation_id
    ``previewPublishModelVersion``, response ``PublishPreviewOut``) and the
    no-UserClient guard that keeps it smoke-testable."""

    def _seed(self, engine, *, name="Preview Corp", scope="ecm"):
        from vibe_modeling.backend.model_sync import ModelSyncService
        from .test_model_export import SAMPLE_MODEL

        with Session(engine) as session:
            biz = Business(name=name, industry_alignment="Retail", description="demo")
            session.add(biz)
            session.flush()
            mv = ModelVersion(business_id=biz.id, version=2, scope=scope, status="completed")
            session.add(mv)
            session.flush()
            ModelSyncService(session).sync_from_model_json(mv.id, SAMPLE_MODEL)
            session.commit()
            return biz.id, mv.id

    def _app(self, engine, fake_http):
        from fastapi import FastAPI
        from fastapi.testclient import TestClient

        from vibe_modeling.backend.core._config import AppConfig
        from vibe_modeling.backend.core._defaults import _ConfigDependency
        from vibe_modeling.backend.core._roles import require_modeler
        from vibe_modeling.backend.core.lakebase import _LakebaseDependency
        from vibe_modeling.backend.routes.industry_models import router as im_router
        from vibe_modeling.backend.services import publish_preview as svc
        from vibe_modeling.backend.sources.github import GithubSourceConnector

        svc.build_github_connector = lambda repo_owner="", repo_name="", **_: GithubSourceConnector(  # noqa: E731
            http=fake_http
        )

        app = FastAPI()
        app.include_router(im_router)

        def override_session():
            with Session(engine) as session:
                yield session

        app.dependency_overrides[_LakebaseDependency.__call__] = override_session
        app.dependency_overrides[_ConfigDependency.__call__] = lambda: AppConfig(app_name="test")
        app.dependency_overrides[require_modeler] = lambda: object()
        return TestClient(app)

    def test_publish_preview_endpoint_shape_tier1(self, engine):
        from .test_publish_preview import (
            _SAMPLE_BASELINE_DOC,
            _industry_listing_http,
        )

        bid, vid = self._seed(engine)
        http = _industry_listing_http("preview_corp", {"v1": ["ecm"]}, model_doc=_SAMPLE_BASELINE_DOC)
        client = self._app(engine, http)
        body = client.post(
            f"/api/businesses/{bid}/model-versions/{vid}/publish-preview", json={}
        ).json()
        _assert_keys(body, {
            "baseline", "tier", "scope_mismatch", "manual_needed",
            "candidates", "diff",
        }, "PublishPreviewOut")
        assert body["tier"] == "same_scope_latest"
        assert body["baseline"]["model_id"] == "v1_ecm"
        assert body["manual_needed"] is False
        assert set(body["diff"]["counts"]) == {"new", "modified", "deleted"}

    def test_publish_preview_endpoint_manual_needed_no_500(self, engine):
        from .test_publish_preview import _industry_listing_http

        bid, vid = self._seed(engine)
        http = _industry_listing_http("preview_corp", {})  # empty industry -> Tier 3
        client = self._app(engine, http)
        resp = client.post(
            f"/api/businesses/{bid}/model-versions/{vid}/publish-preview", json={}
        )
        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert body["manual_needed"] is True
        assert body["diff"] is None

    def test_publish_preview_endpoint_requires_no_userclient(self, engine):
        # The route resolves with ONLY Session + Config + ModelerOnly overridden
        # (no UserClient override) -> 200. A future regression that adds a
        # Dependencies.UserClient param would 500 under this public-only client.
        from .test_publish_preview import (
            _SAMPLE_BASELINE_DOC,
            _industry_listing_http,
        )

        bid, vid = self._seed(engine)
        http = _industry_listing_http("preview_corp", {"v1": ["ecm"]}, model_doc=_SAMPLE_BASELINE_DOC)
        client = self._app(engine, http)
        resp = client.post(
            f"/api/businesses/{bid}/model-versions/{vid}/publish-preview", json={}
        )
        assert resp.status_code == 200, resp.text

    def test_publish_preview_route_has_no_userclient_dep(self):
        # Signature-level guard: the route fn must not depend on UserClient.
        import inspect

        from vibe_modeling.backend.core import Dependencies
        from vibe_modeling.backend.routes.industry_models import (
            preview_publish_model_version_endpoint,
        )

        sig = inspect.signature(preview_publish_model_version_endpoint)
        annotations = [p.annotation for p in sig.parameters.values()]
        assert Dependencies.UserClient not in annotations


class TestDiagramOverviewPathUnchanged:
    """The overview / all-domains diagram path (``domain is None``) must stay
    byte-unchanged after Increment 1: its edges carry the additive focal-view
    routing fields at their backward-compatible empty defaults (the FE then
    falls back to its smoothstep path)."""

    def test_extract_layout_edges_have_empty_focal_fields(self):
        from vibe_modeling.backend.diagram import _extract_layout

        elk_result = {
            "children": [{
                "id": "domain:sales", "x": 0, "y": 0, "width": 400, "height": 300,
                "children": [{"id": "sales.customer", "x": 0, "y": 0,
                              "width": 200, "height": 80}],
            }],
        }
        metadata = {
            "domain:sales": {"domain": "sales", "division": "", "is_external": False,
                             "product_count": 1},
            "sales.customer": {"domain": "sales", "product": "customer",
                               "table_name": "customer", "product_type": "",
                               "description": "", "columns": [], "column_count": 1,
                               "fk_count": 1},
        }
        edges = [{"source_node": "sales.customer", "source_column": "segment_id",
                  "target_node": "sales.customer_segment", "target_column": "segment_id"}]
        layout = _extract_layout(elk_result, metadata, edges)
        assert len(layout.edges) == 1
        e = layout.edges[0]
        assert e.waypoints == []

    def test_layout_algorithm_version_is_7(self):
        # v5 (Increment 1): focal pipeline. v6: focal nodes carry display
        # metadata + height, invalidating v5 layouts cached with empty columns.
        # v7 (0.6.6 item 1): deterministic column ordering (PK, FK, rest; each
        # alpha), invalidating v6 layouts cached with source-order columns.
        from vibe_modeling.backend.diagram import _LAYOUT_ALGORITHM_VERSION

        assert _LAYOUT_ALGORITHM_VERSION == 7


class TestCatalogSchemaWarningResponseShape:
    """Pin the response shape of GET /api/uc/catalogs/{catalog_name}/schema-warning.

    Any change to the three-field contract (``catalog``, ``schema_count``,
    ``schemas``) will surface here before it silently breaks the FE warning
    banner that reads these fields by name.
    """

    EXPECTED_KEYS = {"catalog", "schema_count", "schemas"}

    def test_response_shape(self, client, mock_ws):
        from types import SimpleNamespace

        mock_ws.schemas.list.return_value = [
            SimpleNamespace(name="retail"),
            SimpleNamespace(name="_metamodel"),
        ]

        resp = client.get("/api/uc/catalogs/my_catalog/schema-warning")
        assert resp.status_code == 200, resp.text
        body = resp.json()
        _assert_keys(body, self.EXPECTED_KEYS, "CatalogSchemaWarningOut")
        assert body["catalog"] == "my_catalog"
        assert isinstance(body["schema_count"], int)
        assert isinstance(body["schemas"], list)
