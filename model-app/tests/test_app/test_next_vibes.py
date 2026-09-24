"""Tests for the agent-proposed next-vibes endpoint and the sync-time capture
that feeds it.

``getNextVibes`` now reads the structured ``VibeInput(origin=agent_next_vibe)``
rows the sync-time materializer creates (joined via ``VibeInputContextLink``),
not a JSON blob. ``load_next_vibes_from_volumes`` returns ``(payload, path)``.
"""

import json
from unittest.mock import MagicMock

from sqlmodel import Session

from vibe_modeling.backend.db_models import (
    Business,
    ModelVersion,
    VibeInput,
    VibeInputContextLink,
    _now,
)
from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend.models import (
    NextVibeCategory,
    VibeInputOrigin,
    VibeInputPriority,
    VibeInputStatus,
)


def _seed_version(engine) -> str:
    with Session(engine) as session:
        b = Business(name="Acme")
        session.add(b)
        session.flush()
        mv = ModelVersion(business_id=b.id, version=1, status="completed")
        session.add(mv)
        session.commit()
        session.refresh(mv)
        return mv.id


def _seed_agent_input(
    engine,
    version_id: str,
    *,
    text: str,
    priority: str = VibeInputPriority.HIGH.value,
    category: str = NextVibeCategory.PRIORITY_REMEDIATION.value,
    confidence: float | None = None,
    status: str = VibeInputStatus.ACTIVE.value,
) -> str:
    with Session(engine) as session:
        mv = session.get(ModelVersion, version_id)
        vi = VibeInput(
            business_id=mv.business_id,
            origin=VibeInputOrigin.AGENT_NEXT_VIBE.value,
            author="",
            text=text,
            category=category,
            priority=priority,
            confidence_score=confidence,
            consumed=False,
            status=status,
            created_at=_now(),
            updated_at=_now(),
        )
        session.add(vi)
        session.flush()
        session.add(VibeInputContextLink(
            input_id=vi.id,
            version_id=version_id,
            is_origin=True,
            created_at=_now(),
        ))
        session.commit()
        return vi.id


class TestGetNextVibesEndpoint:
    def test_empty_when_version_has_no_next_vibes(self, client, engine):
        version_id = _seed_version(engine)
        response = client.get(f"/api/model-versions/{version_id}/next-vibes")
        assert response.status_code == 200
        body = response.json()
        assert body["model_version_id"] == version_id
        assert body["items"] == []
        assert body["summary"] == ""
        assert body["confidence_score"] is None

    def test_returns_404_for_unknown_version(self, client):
        response = client.get("/api/model-versions/does-not-exist/next-vibes")
        assert response.status_code == 404

    def test_surfaces_all_findings_as_items(self, client, engine):
        version_id = _seed_version(engine)
        # Static-analysis, priority-remediation, and other findings ALL surface.
        _seed_agent_input(
            engine, version_id,
            text="remove_fk for customer.profile\n\nremove FK on fulfillment_location_id",
            priority=VibeInputPriority.HIGH.value,
            category=NextVibeCategory.PRIORITY_REMEDIATION.value,
            confidence=0.71,
        )
        _seed_agent_input(
            engine, version_id,
            text="Static analysis: unlinked_fk\n\nColumn region_id looks like an FK",
            priority=VibeInputPriority.LOW.value,
            category=NextVibeCategory.STATIC_ANALYSIS.value,
            confidence=0.71,
        )
        _seed_agent_input(
            engine, version_id,
            text="Other known issue\n\norder_line description is empty",
            priority=VibeInputPriority.LOW.value,
            category=NextVibeCategory.OTHER.value,
            confidence=0.71,
        )

        response = client.get(f"/api/model-versions/{version_id}/next-vibes")
        assert response.status_code == 200
        body = response.json()

        assert len(body["items"]) == 3
        assert body["confidence_score"] == 0.71
        assert body["status"] == "needs_work"  # < 0.8
        titles = [it["title"] for it in body["items"]]
        assert "remove_fk for customer.profile" in titles
        assert "Static analysis: unlinked_fk" in titles
        assert "Other known issue" in titles

    def test_item_id_is_vibe_input_uuid(self, client, engine):
        version_id = _seed_version(engine)
        vi_id = _seed_agent_input(
            engine, version_id,
            text="connect_table for sale.order_line\n\nadd sku_id",
        )
        response = client.get(f"/api/model-versions/{version_id}/next-vibes")
        body = response.json()
        assert body["items"][0]["id"] == vi_id
        assert body["items"][0]["title"] == "connect_table for sale.order_line"
        assert body["items"][0]["description"] == "add sku_id"

    def test_deprecated_inputs_excluded(self, client, engine):
        version_id = _seed_version(engine)
        _seed_agent_input(
            engine, version_id, text="active one\n\nkeep me",
            status=VibeInputStatus.ACTIVE.value,
        )
        _seed_agent_input(
            engine, version_id, text="deprecated one\n\ndrop me",
            status=VibeInputStatus.DEPRECATED.value,
        )
        response = client.get(f"/api/model-versions/{version_id}/next-vibes")
        body = response.json()
        assert len(body["items"]) == 1
        assert body["items"][0]["title"] == "active one"


class TestLoadNextVibesFromVolumes:
    def test_returns_none_without_ws(self):
        svc = ModelSyncService(session=MagicMock(), ws=None, warehouse_id="w1")
        assert svc.load_next_vibes_from_volumes("cat", "biz", "1", "mvm") == (None, None)

    def test_tries_vibes_subfolder_first(self):
        ws = MagicMock()
        payload = {"_next_vibe_metadata": {"summary": "x", "findings": []}}

        resp = MagicMock()
        resp.contents.read.return_value = json.dumps(payload).encode()
        ws.files.download.side_effect = lambda path: (
            resp if path.endswith("/vibes/next_vibes.json") else
            _raise(FileNotFoundError())
        )

        svc = ModelSyncService(session=MagicMock(), ws=ws, warehouse_id="w1")
        result, path = svc.load_next_vibes_from_volumes("cat", "biz", "v1", "mvm")
        assert result == payload
        assert path.endswith("/vibes/next_vibes.json")

    def test_falls_back_to_version_root(self):
        ws = MagicMock()
        payload = {"_next_vibe_metadata": {"summary": "ok", "findings": []}}

        resp = MagicMock()
        resp.contents.read.return_value = json.dumps(payload).encode()

        def fake_download(path: str):
            if path.endswith("/vibes/next_vibes.json"):
                raise FileNotFoundError()
            if path.endswith("/next_vibes.json"):
                return resp
            raise FileNotFoundError()

        ws.files.download.side_effect = fake_download

        svc = ModelSyncService(session=MagicMock(), ws=ws, warehouse_id="w1")
        result, path = svc.load_next_vibes_from_volumes("cat", "biz", "1", "ecm")
        assert result == payload
        assert path.endswith("/next_vibes.json")

    def test_returns_none_when_missing(self):
        ws = MagicMock()
        ws.files.download.side_effect = FileNotFoundError()
        svc = ModelSyncService(session=MagicMock(), ws=ws, warehouse_id="w1")
        assert svc.load_next_vibes_from_volumes("cat", "biz", "1", "mvm") == (None, None)


def _raise(exc: BaseException):
    raise exc
