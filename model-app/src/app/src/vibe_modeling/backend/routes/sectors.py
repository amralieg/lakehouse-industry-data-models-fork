"""Sector taxonomy endpoints (`/api/sectors/*`) — ADR D-047.

Sectors are the top level of the two-level taxonomy. The lower level
(industries / meta-businesses) are ``businesses`` rows with
``kind='industry'`` that carry ``sector_id``. This is the surface the
repurposed Settings/Sectors tab manages.
"""

from __future__ import annotations

from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException
from sqlmodel import func, select

from ..._metadata import api_prefix
from ..core import Dependencies
from ..db_models import Business, Sector
from ..models import SectorIn, SectorOut

router = APIRouter(prefix=api_prefix)


@router.get("/sectors", response_model=list[SectorOut], operation_id="listSectors")
def list_sectors(session: Dependencies.Session):
    """List all sectors, alphabetical by name (the convention every picker and
    settings table wants; ``display_order`` is kept for curated ordering)."""
    return session.exec(select(Sector).order_by(Sector.name)).all()


@router.post("/sectors", response_model=SectorOut, operation_id="createSector")
def create_sector(
    data: SectorIn,
    session: Dependencies.Session,
    _role: Dependencies.BusinessAdminOnly,
):
    """Create a new sector."""
    sector = Sector(
        name=data.name,
        short_name=data.short_name,
        description=data.description,
        display_order=data.display_order,
        is_active=data.is_active,
    )
    session.add(sector)
    session.commit()
    session.refresh(sector)
    return sector


@router.put("/sectors/{sector_id}", response_model=SectorOut, operation_id="updateSector")
def update_sector(
    sector_id: str,
    data: SectorIn,
    session: Dependencies.Session,
    _role: Dependencies.BusinessAdminOnly,
):
    """Update a sector."""
    sector = session.get(Sector, sector_id)
    if not sector:
        raise HTTPException(status_code=404, detail="Sector not found")
    sector.name = data.name
    sector.short_name = data.short_name
    sector.description = data.description
    sector.display_order = data.display_order
    sector.is_active = data.is_active
    sector.updated_at = datetime.now(timezone.utc)
    session.add(sector)
    session.commit()
    session.refresh(sector)
    return sector


@router.delete("/sectors/{sector_id}", operation_id="deleteSector")
def delete_sector(
    sector_id: str,
    session: Dependencies.Session,
    _role: Dependencies.BusinessAdminOnly,
):
    """Delete a sector.

    Rejects with 409 ``sector_in_use`` if any Business (real business or
    industry) references this sector via ``sector_id``; the caller reassigns
    those first rather than cascading FK damage.
    """
    sector = session.get(Sector, sector_id)
    if not sector:
        raise HTTPException(status_code=404, detail="Sector not found")

    in_use = session.exec(
        select(func.count()).select_from(Business).where(Business.sector_id == sector_id)
    ).one()
    if in_use > 0:
        raise HTTPException(
            status_code=409,
            detail={
                "error": "sector_in_use",
                "sector_id": sector_id,
                "name": sector.name,
                "business_count": in_use,
                "message": (
                    f"Sector '{sector.name}' is used by {in_use} business(es)/"
                    f"industr(ies); reassign those first."
                ),
            },
        )

    session.delete(sector)
    session.commit()
    return {"ok": True}
