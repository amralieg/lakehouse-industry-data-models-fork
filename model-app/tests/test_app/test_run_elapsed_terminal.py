"""elapsed_seconds must FREEZE at completed_at for terminal runs.

Pre-fix it was always ``now - started_at``, so a completed June run reported
~30 days and kept ticking. The end anchor is ``completed_at`` once set, and
``now`` only while the run is still in flight.
"""

from __future__ import annotations

from datetime import datetime, timedelta, timezone
from unittest.mock import MagicMock

from sqlmodel import Session

from vibe_modeling.backend.db_models import Business, Run
from vibe_modeling.backend.routes._helpers import _build_run_out


def _run(engine, **kw) -> str:
    with Session(engine) as s:
        b = Business(name="Elapsed Co", description="d")
        s.add(b)
        s.flush()
        r = Run(business_id=b.id, intent="vibe-iterate", **kw)
        s.add(r)
        s.commit()
        s.refresh(r)
        return r.id


def test_elapsed_frozen_at_completed_at_for_terminal_run(engine):
    started = datetime.now(timezone.utc) - timedelta(days=30)
    completed = started + timedelta(seconds=120)
    rid = _run(engine, status="completed", started_at=started, completed_at=completed)
    with Session(engine) as s:
        out = _build_run_out(s.get(Run, rid), ws=MagicMock(), session=s, warnings=[])
    # Frozen at the true 120s duration, NOT ~30 days and NOT ticking.
    assert out.elapsed_seconds == 120


def test_elapsed_live_while_running(engine):
    started = datetime.now(timezone.utc) - timedelta(seconds=60)
    rid = _run(engine, status="running", started_at=started, completed_at=None)
    with Session(engine) as s:
        out = _build_run_out(s.get(Run, rid), ws=MagicMock(), session=s, warnings=[])
    # No completed_at yet -> live elapsed (about 60s, allow scheduling slack).
    assert 55 <= out.elapsed_seconds <= 120
