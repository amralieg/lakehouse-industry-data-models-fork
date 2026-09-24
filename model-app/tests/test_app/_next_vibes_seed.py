"""Shared seeding helper for structured agent next-vibe VibeInput rows.

After the next-vibes blob retirement, the run-create / validate selection
contract validates ``next_vibe_ids`` against ``VibeInput(origin=agent_next_vibe)``
rows (by their durable uuid), not against synthetic ``nv-N`` ids parsed from a
JSON blob. Tests seed those rows via this helper and select by the returned
uuids.
"""

from __future__ import annotations

import os
import sys

sys.path.insert(
    0,
    os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"),
)

from sqlmodel import Session

from vibe_modeling.backend.db_models import (
    ModelVersion,
    VibeInput,
    VibeInputContextLink,
    _now,
)
from vibe_modeling.backend.models import (
    NextVibeCategory,
    VibeInputOrigin,
    VibeInputPriority,
    VibeInputStatus,
)


def seed_version_with_next_vibe_inputs(
    engine,
    business_id: str,
    *,
    scope: str = "ecm",
    titles: tuple[str, ...] = (
        "Fix unlinked ids",
        "Connect disconnected tables",
        "Improve tags",
    ),
    confidence: float | None = 0.71,
) -> tuple[str, list[str]]:
    """Create a completed ModelVersion with structured agent next-vibe rows.

    Returns ``(version_id, [vibe_input_id, ...])``. The ids are the durable
    VibeInput uuids the selection contract validates against.
    """
    with Session(engine) as session:
        mv = ModelVersion(
            business_id=business_id, version=1, status="completed", scope=scope
        )
        session.add(mv)
        session.flush()
        ids: list[str] = []
        for title in titles:
            vi = VibeInput(
                business_id=business_id,
                origin=VibeInputOrigin.AGENT_NEXT_VIBE.value,
                author="",
                text=f"{title}\n\nsome detail for {title}",
                category=NextVibeCategory.PRIORITY_REMEDIATION.value,
                priority=VibeInputPriority.HIGH.value,
                confidence_score=confidence,
                consumed=False,
                status=VibeInputStatus.ACTIVE.value,
                created_at=_now(),
                updated_at=_now(),
            )
            session.add(vi)
            session.flush()
            session.add(VibeInputContextLink(
                input_id=vi.id,
                version_id=mv.id,
                is_origin=True,
                created_at=_now(),
            ))
            ids.append(vi.id)
        session.commit()
        return mv.id, ids


def seed_version_without_next_vibes(engine, business_id: str, *, scope: str = "ecm") -> str:
    """Create a completed ModelVersion with NO agent next-vibe rows."""
    with Session(engine) as session:
        mv = ModelVersion(
            business_id=business_id, version=1, status="completed", scope=scope
        )
        session.add(mv)
        session.commit()
        session.refresh(mv)
        return mv.id
