"""Regression tests for PR #78 — explorer cache invalidation on writes.

Every write path that mutates Lakebase for a `(business_id, version)` must
drop the matching entry in `explorer._model_cache`, otherwise GET
`/api/businesses/{id}/versions/{N}/model` keeps serving the pre-write
snapshot for the process lifetime.
"""

import sys
import os
import json
from contextlib import contextmanager
from unittest.mock import MagicMock, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend import explorer as explorer_module
from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    Domain,
    ModelVersion,
    Product,
    Run,
)
from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend.progress_tracker import ProgressTracker


def _seed_v1_with_domain(session: Session, business_id: str, domain_name: str) -> str:
    mv = ModelVersion(
        business_id=business_id, version=1, scope="mvm", status="completed", uc_catalog="test_cat"
    )
    session.add(mv)
    session.flush()
    d = Domain(version_id=mv.id, name=domain_name, division="ops", description="seed")
    session.add(d)
    session.flush()
    p = Product(
        version_id=mv.id, domain_id=d.id, name="customer", table_name="customer",
        description="seed", type="Master", primary_key="customer_id",
    )
    session.add(p)
    session.flush()
    session.add(Attribute(
        product_id=p.id, name="customer_id", column_name="customer_id",
        type="BIGINT", description="PK",
    ))
    session.commit()
    return mv.id


def _overwrite_v1_domain(session: Session, business_id: str, new_domain_name: str) -> None:
    mv = session.exec(
        select(ModelVersion).where(
            ModelVersion.business_id == business_id,
            ModelVersion.version == 1,
        )
    ).first()
    for d in session.exec(select(Domain).where(Domain.version_id == mv.id)).all():
        for p in session.exec(select(Product).where(Product.domain_id == d.id)).all():
            for a in session.exec(select(Attribute).where(Attribute.product_id == p.id)).all():
                session.delete(a)
            session.delete(p)
        session.delete(d)
    session.flush()
    d = Domain(version_id=mv.id, name=new_domain_name, division="ops", description="overwritten")
    session.add(d)
    session.flush()
    p = Product(
        version_id=mv.id, domain_id=d.id, name="account", table_name="account",
        description="overwritten", type="Master", primary_key="account_id",
    )
    session.add(p)
    session.flush()
    session.add(Attribute(
        product_id=p.id, name="account_id", column_name="account_id",
        type="BIGINT", description="PK",
    ))
    session.commit()


@pytest.fixture(autouse=True)
def _clear_explorer_cache():
    explorer_module._model_cache.clear()
    yield
    explorer_module._model_cache.clear()



class TestForceResyncInvalidatesCache:
    """POST /businesses/{id}/versions/{vid}/resync must drop the cached model dict."""

    def test_resync_endpoint_invalidates_stale_cache(self, client, engine, seed_business):
        business_id = seed_business

        with Session(engine) as session:
            version_id = _seed_v1_with_domain(session, business_id, "sales_before")

        pre = client.get(f"/api/businesses/{business_id}/versions/1/mvm/model")
        assert pre.status_code == 200
        pre_names = {d["name"] for d in pre.json()["domains"]}
        assert "sales_before" in pre_names
        assert (business_id, 1, "mvm") in explorer_module._model_cache

        with Session(engine) as session:
            _overwrite_v1_domain(session, business_id, "sales_after")

        cached = pre.json()
        assert (business_id, 1, "mvm") in explorer_module._model_cache
        stale_names = {d["name"] for d in cached["domains"]}
        mid = client.get(f"/api/businesses/{business_id}/versions/1/mvm/model")
        assert stale_names == {d["name"] for d in mid.json()["domains"]}, (
            "Precondition: without invalidation, GET should serve stale cache."
        )

        with patch.object(
            ModelSyncService, "load_resync_sources",
            return_value=({"domains": []}, None, None),
        ), \
             patch.object(ModelSyncService, "clear_version_data", return_value=None), \
             patch.object(ModelSyncService, "sync_model", return_value=True):
            resp = client.post(f"/api/businesses/{business_id}/versions/{version_id}/resync")
        assert resp.status_code == 200, resp.text

        assert (business_id, 1, "mvm") not in explorer_module._model_cache

        post = client.get(f"/api/businesses/{business_id}/versions/1/mvm/model")
        assert post.status_code == 200
        post_names = {d["name"] for d in post.json()["domains"]}
        assert "sales_after" in post_names
        assert "sales_before" not in post_names


class TestImportFromVolumeInvalidatesCache:
    """POST /businesses/{id}/versions/import-from-volume must drop any cached entry
    for the version being created."""

    def test_import_endpoint_invalidates_stale_cache(self, client, engine, mock_ws, seed_business):
        business_id = seed_business

        explorer_module._model_cache[(business_id, 1, "mvm")] = {
            "business_name": "Test Corp",
            "version": 1,
            "domains": [{"name": "STALE_FROM_BEFORE_IMPORT", "products": []}],
        }

        imported_payload = {
            "type": "business",
            "name": "test_corp",
            "version": "v1_mvm",
            "description": "",
            "domains": [{
                "name": "imported_sales",
                "division": "ops",
                "description": "imported",
                "database_name": "db",
                "products": [{
                    "name": "order",
                    "table_name": "order",
                    "description": "imported",
                    "type": "Transactional",
                    "primary_key": "order_id",
                    "attributes": [
                        {"name": "order_id", "column_name": "order_id", "type": "BIGINT",
                         "description": "PK", "foreign_key_to": ""},
                    ],
                }],
            }],
        }
        resp_dl = MagicMock()
        resp_dl.contents.read.return_value = json.dumps(imported_payload).encode("utf-8")
        mock_ws.files.download.return_value = resp_dl

        # Path must carry the `{scope}_v{N}` segment so the import scope-
        # detector picks "mvm" — the import endpoint derives scope from the
        # volume path, not from the model.json `version` field.
        resp = client.post(
            f"/api/businesses/{business_id}/versions/import-from-volume",
            params={
                "volume_path": "/Volumes/cat/_metamodel/vol_root/business/test_corp/mvm_v1/model.json"
            },
        )
        assert resp.status_code == 200, resp.text
        assert resp.json()["version"] == 1

        assert (business_id, 1, "mvm") not in explorer_module._model_cache

        post = client.get(f"/api/businesses/{business_id}/versions/1/mvm/model")
        assert post.status_code == 200
        names = {d["name"] for d in post.json()["domains"]}
        assert "STALE_FROM_BEFORE_IMPORT" not in names
        assert "imported_sales" in names


class TestInProgressModelNotPoisoned:
    """The ModelVersion row is created mid-run, before its domains/products are
    synced. A model read in that window returns 0 domains; it must NOT be
    cached, and the completion-sync must invalidate — otherwise the stale-empty
    model is served as "all domains deleted" forever (the cache is busted only
    by manual version ops, not by run sync)."""

    def test_empty_model_load_is_not_cached(self, engine, seed_business, mock_ws):
        business_id = seed_business
        with Session(engine) as session:
            mv = ModelVersion(
                business_id=business_id, version=1, scope="mvm",
                status="running", uc_catalog="test_cat",
            )
            session.add(mv)
            session.commit()

        with Session(engine) as session:
            # Lakebase has no domains (mid-run) -> falls back to a structureless
            # Volume model.json. The guard must keep this out of the cache.
            with patch.object(explorer_module, "_find_model_json_path",
                              return_value="/Volumes/x/_metamodel/vol_root/model.json"), \
                 patch.object(explorer_module, "_read_volume_json",
                              return_value={"domains": []}):
                model = explorer_module._load_model(session, mock_ws, business_id, 1, "mvm")

        assert model.get("domains") == []
        assert (business_id, 1, "mvm") not in explorer_module._model_cache, (
            "a structureless (mid-sync) model load must not poison the cache"
        )

    def test_sync_invalidates_cached_model(self, engine, seed_business):
        business_id = seed_business
        with Session(engine) as session:
            mv = ModelVersion(
                business_id=business_id, version=1, scope="mvm",
                status="completed", uc_catalog="test_cat",
            )
            session.add(mv)
            session.commit()
            version_id = mv.id

        explorer_module._model_cache[(business_id, 1, "mvm")] = {"domains": [{"name": "stale"}]}
        with Session(engine) as session:
            ModelSyncService(session)._invalidate_model_cache(version_id)
        assert (business_id, 1, "mvm") not in explorer_module._model_cache, (
            "sync_model must invalidate the version's cached model"
        )
