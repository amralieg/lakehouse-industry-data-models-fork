"""Tests for model.json import (version detection + execution endpoint)."""

import json
from unittest.mock import MagicMock

from vibe_modeling.backend.agent_compat import classify_tag
from vibe_modeling.backend.import_model import detect_schema


# --- Schema detection ---


class TestDetectSchema:
    def test_valid_wrapped_model(self):
        """Agent exports wrap model under `{"model_requirements": ..., "model": ...}`."""
        data = {
            "model_requirements": {"business_name": "acme"},
            "_vibe_session_metadata": {"status": "success"},
            "model": {
                "type": "business",
                "name": "acme",
                "version": "v1_mvm",
                "description": "A retailer",
                "domains": [
                    {
                        "name": "sales",
                        "products": [
                            {
                                "name": "orders",
                                "attributes": [
                                    {"name": "id", "column_name": "id", "type": "BIGINT",
                                     "description": ""},
                                    {"name": "customer_id", "column_name": "customer_id",
                                     "type": "BIGINT", "description": "",
                                     "foreign_key_to": "sales.customers.id"},
                                ],
                            }
                        ],
                    }
                ],
            },
        }
        result = detect_schema(data)
        assert result.valid
        assert result.action == "import_as_is"
        assert result.inferred_version == "modern"
        assert result.domain_count == 1
        assert result.product_count == 1
        assert result.attribute_count == 2
        assert result.fk_count == 1
        assert result._model is not None  # unwrapped inner model

    def test_valid_unwrapped_model(self):
        """Some exports pass the inner model directly without the wrapper."""
        data = {
            "type": "business",
            "name": "acme",
            "version": "v2_ecm",
            "description": "",
            "domains": [],
        }
        result = detect_schema(data)
        assert result.valid
        assert result.action == "import_as_is"
        assert result.domain_count == 0
        # No domains → warning
        assert any("no domains" in w for w in result.warnings)

    def test_valid_message_carries_agent_version(self):
        """When the file stamps a version, the success message names it
        (normalized to a leading ``v``); otherwise it's version-free. From
        v0.8.0 ``release_version`` is preferred over ``agent_version``."""
        base = {"type": "business", "name": "x", "version": "v1_ecm",
                "description": "d", "domains": []}
        assert (
            detect_schema({"agent_version": "0.7.2", "model": base}).message
            == "Schema (v0.7.2) is supported for importing."
        )
        # Already-prefixed value is not double-prefixed.
        assert (
            detect_schema({"agent_version": "v0.8.0", "model": base}).message
            == "Schema (v0.8.0) is supported for importing."
        )
        # release_version wins over agent_version (v0.8.0 field split): the
        # 4.x agent-logic counter must never leak into the release label.
        assert (
            detect_schema(
                {"agent_version": "4.9.8", "release_version": "0.8.0", "model": base}
            ).message
            == "Schema (v0.8.0) is supported for importing."
        )
        # No version fields → plain message.
        assert detect_schema(base).message == "Schema is supported for importing."

    def test_invalid_missing_required_fields(self):
        data = {"foo": "bar"}
        result = detect_schema(data)
        assert not result.valid
        assert result.action == "unsupported"
        assert "missing required fields" in result.message

    def test_non_standard_version_string_warns_but_imports(self):
        data = {
            "type": "business",
            "name": "x",
            "version": "custom_version_string",
            "description": "",
            "domains": [],
        }
        result = detect_schema(data)
        assert result.valid
        # Warning about version format
        assert any("version" in w and "pattern" in w for w in result.warnings)

# --- Import endpoint ---


class TestImportEndpoint:
    def _mock_file_download(self, mock_ws, content: str):
        """Wire up ws.files.download() to return `content` as bytes."""
        resp = MagicMock()
        resp.contents.read.return_value = content.encode("utf-8")
        mock_ws.files.download.return_value = resp

    def test_analyze_success(self, client_with_agent, mock_ws, seed_business):
        self._mock_file_download(mock_ws, json.dumps({
            "type": "business",
            "name": "test",
            "version": "v1_mvm",
            "description": "",
            "domains": [{"name": "sales", "products": [{"name": "orders"}]}],
        }))

        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/analyze",
            json={"volume_path": "/Volumes/test/schema/vol/model.json"},
        )
        assert r.status_code == 200, r.text
        data = r.json()
        assert data["valid"]
        assert data["action"] == "import_as_is"
        assert data["domain_count"] == 1
        assert data["product_count"] == 1

    def test_analyze_bad_volume_path(self, client_with_agent, seed_business):
        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/analyze",
            json={"volume_path": "/not/a/volume/path.json"},
        )
        assert r.status_code == 400
        assert "/Volumes/" in r.json()["detail"]

    def test_analyze_invalid_json(self, client_with_agent, mock_ws, seed_business):
        self._mock_file_download(mock_ws, "not a json file")
        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/analyze",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 400
        assert "not valid JSON" in r.json()["detail"]

    def test_analyze_nonexistent_business(self, client_with_agent):
        r = client_with_agent.post(
            "/api/businesses/nope/import/analyze",
            json={"volume_path": "/Volumes/x/y/z.json"},
        )
        assert r.status_code == 404

    def test_execute_creates_version(self, client_with_agent, mock_ws, seed_business):
        self._mock_file_download(mock_ws, json.dumps({
            "type": "business",
            "name": "test",
            "version": "v1_mvm",
            "description": "",
            "domains": [
                {
                    "name": "sales",
                    "products": [
                        {
                            "name": "orders",
                            "table_name": "orders",
                            "primary_key": "id",
                            "attributes": [
                                {"name": "id", "column_name": "id", "type": "BIGINT",
                                 "description": ""},
                            ],
                        }
                    ],
                }
            ],
        }))

        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/execute",
            json={
                "volume_path": "/Volumes/test/schema/vol/model.json",
                # seed_business is "Test Corp" but the model.json says "test"
                # — opt into the Story-2 mismatch gate so the import lands.
                "accept_business_mismatch": True,
            },
        )
        assert r.status_code == 200, r.text
        data = r.json()
        assert data["version"] == 1
        assert data["domains"] == 1
        assert data["products"] == 1
        assert data["attributes"] == 1

        # Verify the version was created with deployment_status=draft
        versions = client_with_agent.get(
            f"/api/businesses/{seed_business}/versions"
        ).json()
        assert len(versions) == 1
        assert versions[0]["deployment_status"] == "draft"
        assert versions[0]["status"] == "completed"
        assert versions[0]["scope"] == "mvm"

    def test_execute_rejects_unsupported(self, client_with_agent, mock_ws, seed_business):
        self._mock_file_download(mock_ws, json.dumps({"random": "junk"}))

        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/execute",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 400

    def test_execute_increments_version(self, client_with_agent, mock_ws, seed_business):
        """Importing when a version already exists should bump the number."""
        # Create an existing version via the test endpoint
        from unittest.mock import MagicMock
        mock_run = MagicMock()
        mock_run.run_id = 1
        mock_ws.jobs.run_now.return_value = mock_run

        # Use the _test/create-version helper if available; otherwise import twice
        self._mock_file_download(mock_ws, json.dumps({
            "type": "business",
            "name": "x",
            "version": "v1_mvm",
            "description": "",
            "domains": [],
        }))
        r1 = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/execute",
            json={
                "volume_path": "/Volumes/a/b/c.json",
                "accept_business_mismatch": True,
            },
        )
        assert r1.json()["version"] == 1

        r2 = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/execute",
            json={
                "volume_path": "/Volumes/a/b/c.json",
                "accept_business_mismatch": True,
            },
        )
        assert r2.json()["version"] == 2


# --- Compatibility matrix ---


class TestAgentCompatMatrix:
    def test_classify_compatible(self):
        assert classify_tag("v0.5.2") == "compatible"
        assert classify_tag("v0.5.8") == "compatible"

    def test_classify_unknown_tag(self):
        assert classify_tag("v9.9.9") == "unknown"
        assert classify_tag("") == "unknown"
        assert classify_tag("not-a-tag") == "unknown"

class TestImportCompatEnforcement:
    def _mock_file_download(self, mock_ws, content: str):
        resp = MagicMock()
        resp.contents.read.return_value = content.encode("utf-8")
        mock_ws.files.download.return_value = resp

    def _payload(self, *, agent_tag: str | None = None) -> dict:
        payload: dict = {
            "model_requirements": {},
            "model": {
                "type": "business",
                "name": "acme",
                "version": "v1_mvm",
                "description": "",
                "domains": [
                    {
                        "name": "sales",
                        "products": [
                            {
                                "name": "orders",
                                "table_name": "orders",
                                "primary_key": "id",
                                "attributes": [
                                    {
                                        "name": "id",
                                        "column_name": "id",
                                        "type": "BIGINT",
                                        "description": "",
                                    }
                                ],
                            }
                        ],
                    }
                ],
            },
        }
        if agent_tag is not None:
            payload["agent_version"] = agent_tag
        return payload

    def test_compatible_tag_succeeds_and_surfaces_verdict(
        self, client_with_agent, mock_ws, seed_business
    ):
        self._mock_file_download(mock_ws, json.dumps(self._payload(agent_tag="v0.5.8")))
        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/execute",
            # _payload's business_name is "acme" while seed_business is
            # "Test Corp" — opt past the Story-2 mismatch gate to keep
            # this test focused on compat verdict.
            json={"volume_path": "/Volumes/a/b/c.json", "accept_business_mismatch": True},
        )
        assert r.status_code == 200, r.text
        data = r.json()
        assert data["detected_agent_tag"] == "v0.5.8"
        assert data["compat_verdict"] == "compatible"
        assert data["latest_supported_tag"] == "v0.8.0"

    def test_analyze_surfaces_verdict(
        self, client_with_agent, mock_ws, seed_business
    ):
        self._mock_file_download(mock_ws, json.dumps(self._payload(agent_tag="v0.5.7")))
        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/analyze",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 200, r.text
        data = r.json()
        assert data["detected_agent_tag"] == "v0.5.7"
        assert data["compat_verdict"] == "compatible"
        assert data["latest_supported_tag"] == "v0.8.0"

    def test_unknown_tag_rejected_with_422(
        self, client_with_agent, mock_ws, seed_business
    ):
        self._mock_file_download(mock_ws, json.dumps(self._payload(agent_tag="v9.9.9")))
        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/execute",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 422, r.text
        detail = r.json()["detail"]
        assert detail["error"] == "incompatible_agent_tag"
        assert detail["compat_verdict"] == "unknown"
        assert detail["detected_agent_tag"] == "v9.9.9"
        assert detail["latest_supported_tag"] == "v0.8.0"
        assert "v0.8.0" in detail["message"]

    def test_breaking_tag_rejected_with_422(
        self, client_with_agent, mock_ws, seed_business, monkeypatch
    ):
        from vibe_modeling.backend import agent_compat

        patched = dict(agent_compat._COMPAT_MATRIX)
        patched["v0.6.0"] = "breaking"
        monkeypatch.setattr(agent_compat, "_COMPAT_MATRIX", patched)
        monkeypatch.setattr(
            agent_compat,
            "SUPPORTED_TAGS",
            frozenset(patched.keys()),
        )

        self._mock_file_download(mock_ws, json.dumps(self._payload(agent_tag="v0.6.0")))
        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/execute",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 422, r.text
        detail = r.json()["detail"]
        assert detail["compat_verdict"] == "breaking"
        assert detail["detected_agent_tag"] == "v0.6.0"
        assert "breaking change" in detail["message"].lower()

    def test_needs_adapter_tag_imports_with_warning(
        self, client_with_agent, mock_ws, seed_business, monkeypatch
    ):
        from vibe_modeling.backend import agent_compat

        patched = dict(agent_compat._COMPAT_MATRIX)
        patched["v0.5.9"] = "needs-adapter"
        monkeypatch.setattr(agent_compat, "_COMPAT_MATRIX", patched)
        monkeypatch.setattr(
            agent_compat,
            "SUPPORTED_TAGS",
            frozenset(patched.keys()),
        )

        self._mock_file_download(mock_ws, json.dumps(self._payload(agent_tag="v0.5.9")))
        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/execute",
            json={"volume_path": "/Volumes/a/b/c.json", "accept_business_mismatch": True},
        )
        assert r.status_code == 200, r.text
        data = r.json()
        assert data["detected_agent_tag"] == "v0.5.9"
        assert data["compat_verdict"] == "needs-adapter"
        assert any("needs-adapter" in w for w in data["warnings"])

    def test_no_agent_tag_in_payload_falls_back_to_pinned(
        self, client_with_agent, mock_ws, seed_business
    ):
        """Existing model.json files without agent_version fall back to the app's pin."""
        from vibe_modeling.backend.core._defaults import SUPPORTED_AGENT_VERSION

        self._mock_file_download(mock_ws, json.dumps(self._payload(agent_tag=None)))
        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/execute",
            json={"volume_path": "/Volumes/a/b/c.json", "accept_business_mismatch": True},
        )
        assert r.status_code == 200, r.text
        data = r.json()
        assert data["detected_agent_tag"] == SUPPORTED_AGENT_VERSION
        assert data["compat_verdict"] == "compatible"


# --- 504 / write_metamodel failure resilience ---


class TestImportSurvivesMetamodelFailure:
    """Regression guard: write_metamodel is an external SQL-warehouse call
    that can take 5+ minutes for large models. When it fails (504, network,
    SQL warehouse error) the Lakebase ModelVersion + child rows +
    RunArtifacts must already be committed and visible. Re-creates the
    bug that wiped 30 industry MVMs by mocking write_metamodel to raise
    and asserting the import response is 200 OK with the version persisted.
    """

    def _mock_file_download(self, mock_ws, content: str):
        from unittest.mock import MagicMock as _MagicMock
        resp = _MagicMock()
        resp.contents.read.return_value = content.encode("utf-8")
        mock_ws.files.download.return_value = resp

    def _model_json(self, *, business_name: str = "acme") -> dict:
        return {
            "model_requirements": {
                "business_name": business_name,
                "description": "504-regression payload",
            },
            "model": {
                "type": "business",
                "name": business_name,
                "version": "v1_mvm",
                "description": "504-regression payload",
                "industry_alignment": "Retail",
                "core_business_processes": "test",
                "orgnaization_divisions": "test",
                "common_business_jargons": "test",
                "operational_systems_of_records": "test",
                "industry_governing_body": "test",
                "domains": [
                    {
                        "name": "sales",
                        "products": [
                            {
                                "name": "orders",
                                "table_name": "orders",
                                "primary_key": "id",
                                "attributes": [
                                    {
                                        "name": "id",
                                        "column_name": "id",
                                        "type": "BIGINT",
                                        "description": "",
                                    },
                                    {
                                        "name": "customer_id",
                                        "column_name": "customer_id",
                                        "type": "BIGINT",
                                        "description": "",
                                    },
                                ],
                            }
                        ],
                    }
                ],
            },
        }

    def _enable_metamodel_path(self, engine):
        """Set warehouse_id on the seeded AgentConfig so write_metamodel
        is actually invoked (the default fixture leaves it empty, which
        short-circuits the writer)."""
        from sqlmodel import Session, select
        from vibe_modeling.backend.db_models import AgentConfig

        with Session(engine) as session:
            ac = session.exec(select(AgentConfig).limit(1)).first()
            assert ac is not None, "client_with_agent fixture should seed AgentConfig"
            ac.warehouse_id = "test_wh_id"
            session.add(ac)
            session.commit()

    def test_execute_import_survives_write_metamodel_failure(
        self, client_with_agent, mock_ws, seed_business, engine, monkeypatch
    ):
        from sqlmodel import Session, select
        from vibe_modeling.backend.db_models import (
            Attribute as DbAttr,
            Domain as DbDomain,
            ModelVersion,
            Product as DbProduct,
        )
        from vibe_modeling.backend.services import import_metamodel_writer

        self._enable_metamodel_path(engine)
        self._mock_file_download(mock_ws, json.dumps(self._model_json()))

        # Use BaseException to bypass the `except Exception` swallow
        # around write_metamodel — simulating the real production
        # failure mode where the Apps reverse proxy cancels the worker
        # task on 504 timeout and the cancellation propagates past the
        # non-fatal try/except. If the response transaction had only
        # committed AFTER write_metamodel, this would tear down the
        # session with the ModelVersion / Domain / Product / Attribute
        # rows still pending → silent rollback.
        class _SimulatedProxyCancel(BaseException):
            pass

        def boom(*_args, **_kwargs):
            raise _SimulatedProxyCancel(
                "simulated Apps reverse-proxy 504 cancellation"
            )

        monkeypatch.setattr(import_metamodel_writer, "write_metamodel", boom)

        # The request raises with BaseException (mimicking the proxy
        # cancellation). What matters for this regression is what the
        # session left in Lakebase, NOT whether the response came back —
        # in production, the client sees a 504 from the proxy either way.
        # The bug was that with the commit AFTER write_metamodel, the
        # session rollback wiped the ModelVersion + child rows. With
        # the commit BEFORE write_metamodel, they survive.
        try:
            client_with_agent.post(
                f"/api/businesses/{seed_business}/import/execute",
                json={
                    "volume_path": "/Volumes/test/schema/vol/model.json",
                    "accept_business_mismatch": True,
                },
            )
        except _SimulatedProxyCancel:
            pass

        # Open an INDEPENDENT session against the same engine and verify
        # the rows are persisted. If write_metamodel's failure had rolled
        # back the request transaction, this lookup would return nothing.
        with Session(engine) as verify:
            mv = verify.exec(
                select(ModelVersion).where(
                    ModelVersion.business_id == seed_business
                )
            ).first()
            assert mv is not None, "ModelVersion must be persisted despite metamodel write failure"
            assert mv.version == 1
            assert mv.status == "completed"

            domains = verify.exec(
                select(DbDomain).where(DbDomain.version_id == mv.id)
            ).all()
            assert len(domains) == 1

            products = verify.exec(
                select(DbProduct).where(DbProduct.version_id == mv.id)
            ).all()
            assert len(products) == 1

            attrs = verify.exec(
                select(DbAttr).where(DbAttr.product_id == products[0].id)
            ).all()
            assert len(attrs) == 2

    def test_create_business_and_execute_import_survives_write_metamodel_failure(
        self, client_with_agent, mock_ws, engine, monkeypatch
    ):
        from sqlmodel import Session, select
        from vibe_modeling.backend.db_models import (
            Attribute as DbAttr,
            Business,
            Domain as DbDomain,
            ModelVersion,
            Product as DbProduct,
        )
        from vibe_modeling.backend.services import import_metamodel_writer

        self._enable_metamodel_path(engine)
        self._mock_file_download(
            mock_ws,
            json.dumps(self._model_json(business_name="ACME Persisted Despite 504")),
        )

        # Use BaseException to bypass the `except Exception` swallow
        # around write_metamodel — simulating the real production
        # failure mode where the Apps reverse proxy cancels the worker
        # task on 504 timeout and the cancellation propagates past the
        # non-fatal try/except. If the response transaction had only
        # committed AFTER write_metamodel, this would tear down the
        # session with the ModelVersion / Domain / Product / Attribute
        # rows still pending → silent rollback.
        class _SimulatedProxyCancel(BaseException):
            pass

        def boom(*_args, **_kwargs):
            raise _SimulatedProxyCancel(
                "simulated Apps reverse-proxy 504 cancellation"
            )

        monkeypatch.setattr(import_metamodel_writer, "write_metamodel", boom)

        try:
            client_with_agent.post(
                "/api/import/create-business-and-execute",
                json={"volume_path": "/Volumes/test/schema/vol/model.json"},
            )
        except _SimulatedProxyCancel:
            pass

        with Session(engine) as verify:
            biz = verify.exec(
                select(Business).where(
                    Business.name == "ACME Persisted Despite 504"
                )
            ).first()
            assert biz is not None, "Business must be persisted despite metamodel write failure"
            mv = verify.exec(
                select(ModelVersion).where(ModelVersion.business_id == biz.id)
            ).first()
            assert mv is not None
            assert mv.version == 1
            domains = verify.exec(
                select(DbDomain).where(DbDomain.version_id == mv.id)
            ).all()
            products = verify.exec(
                select(DbProduct).where(DbProduct.version_id == mv.id)
            ).all()
            attrs = verify.exec(
                select(DbAttr).where(DbAttr.product_id == products[0].id)
            ).all()
            assert len(domains) == 1
            assert len(products) == 1
            assert len(attrs) == 2
