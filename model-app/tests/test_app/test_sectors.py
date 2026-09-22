"""Tests for the Sector taxonomy endpoints (ADR D-047) + the seed.

Covers list/create/update/delete, the in-use 409 guard (a Business pointing at
the sector via ``sector_id``), the 404 path, and ``seed_sectors`` idempotency.
"""

from __future__ import annotations

from sqlmodel import Session, select

from vibe_modeling.backend.core.lakebase import seed_sectors
from vibe_modeling.backend.db_models import Business, Sector
from vibe_modeling.backend.sector_catalog import SECTOR_CATALOG


def _seed_sector(engine, **kwargs) -> str:
    defaults = dict(
        name="Financial Services",
        short_name="financial_services",
        description="",
        display_order=2,
        is_active=True,
    )
    defaults.update(kwargs)
    with Session(engine) as session:
        sec = Sector(**defaults)
        session.add(sec)
        session.commit()
        session.refresh(sec)
        return sec.id


def test_create_list_update_sector(client, engine):
    create = client.post(
        "/api/sectors",
        json={"name": "Manufacturing", "short_name": "manufacturing"},
    )
    assert create.status_code == 200, create.text
    sector_id = create.json()["id"]

    listed = client.get("/api/sectors")
    assert listed.status_code == 200
    assert any(s["id"] == sector_id for s in listed.json())

    updated = client.put(
        f"/api/sectors/{sector_id}",
        json={"name": "Manufacturing & Industrials", "short_name": "manufacturing"},
    )
    assert updated.status_code == 200, updated.text
    assert updated.json()["name"] == "Manufacturing & Industrials"


def test_delete_unused_sector_returns_ok_and_removes_row(client, engine):
    sector_id = _seed_sector(engine)
    resp = client.delete(f"/api/sectors/{sector_id}")
    assert resp.status_code == 200, resp.text
    assert resp.json() == {"ok": True}
    with Session(engine) as session:
        assert session.get(Sector, sector_id) is None


def test_delete_sector_referenced_by_business_returns_409(client, engine):
    sector_id = _seed_sector(engine, name="Healthcare", short_name="healthcare")
    with Session(engine) as session:
        session.add(Business(name="HealthBiz", description="x", sector_id=sector_id))
        session.commit()

    resp = client.delete(f"/api/sectors/{sector_id}")
    assert resp.status_code == 409, resp.text
    detail = resp.json()["detail"]
    assert detail["error"] == "sector_in_use"
    assert detail["sector_id"] == sector_id
    assert detail["business_count"] == 1

    with Session(engine) as session:
        assert session.get(Sector, sector_id) is not None


def test_delete_nonexistent_sector_returns_404(client):
    resp = client.delete("/api/sectors/does-not-exist")
    assert resp.status_code == 404
    assert resp.json()["detail"] == "Sector not found"


def test_seed_sectors_inserts_full_catalog_and_is_idempotent(engine):
    # Fresh engine fixture starts with no sectors.
    with Session(engine) as session:
        assert session.exec(select(Sector)).first() is None

    seed_sectors(engine)
    with Session(engine) as session:
        count = len(session.exec(select(Sector)).all())
    assert count == len(SECTOR_CATALOG) == 10

    # Second call short-circuits — no duplicates.
    seed_sectors(engine)
    with Session(engine) as session:
        assert len(session.exec(select(Sector)).all()) == 10
