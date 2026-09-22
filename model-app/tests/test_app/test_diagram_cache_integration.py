"""Integration tests for the three-tier diagram layout cache.

Verifies the Lakebase write and the invalidation path end-to-end against
the real `diagram_layouts` table using the test SQLite engine.
"""

from datetime import datetime, timezone
from sqlmodel import Session, select

from vibe_modeling.backend import diagram
from vibe_modeling.backend.db_models import (
    Business,
    DiagramLayout,
    ModelVersion,
)
from vibe_modeling.backend.models import (
    DiagramDomainGroup,
    DiagramEdge,
    DiagramLayoutOut,
    DiagramNode,
)


def _seed_business_and_version(engine, version_int: int = 1) -> tuple[str, str]:
    """Seed a Business + ModelVersion, return (business_id, version_id)."""
    with Session(engine) as session:
        biz = Business(name=f"CacheBiz{version_int}")
        session.add(biz)
        session.commit()
        session.refresh(biz)
        mv = ModelVersion(
            business_id=biz.id,
            version=version_int,
            status="completed",
            deployment_status="draft",
        )
        session.add(mv)
        session.commit()
        session.refresh(mv)
        return biz.id, mv.id


def _make_layout(nodes: int = 0) -> DiagramLayoutOut:
    return DiagramLayoutOut(
        nodes=[
            DiagramNode(
                id=f"d.p{i}", domain="d", product=f"p{i}", table_name=f"t{i}",
                x=i * 100, y=0, width=200, height=80,
            )
            for i in range(nodes)
        ],
        edges=[],
        groups=[DiagramDomainGroup(id="domain:d", domain="d", x=0, y=0, width=500, height=200)]
        if nodes else [],
        total_products=nodes,
        total_edges=0,
    )


class TestDiagramCacheLifecycle:
    """End-to-end: write, read, overwrite, invalidate."""

    def test_write_then_read_round_trip(self, engine):
        biz_id, version_id = _seed_business_and_version(engine)
        original = _make_layout(nodes=3)

        with Session(engine) as session:
            diagram._write_lakebase_layout(session, biz_id, version_id, "ck1", original)

        # Read from a fresh session to prove persistence
        with Session(engine) as session:
            read = diagram._read_lakebase_layout(session, biz_id, "ck1")
        assert read is not None
        assert read.total_products == 3
        assert len(read.nodes) == 3
        assert read.nodes[0].id == "d.p0"

    def test_upsert_does_not_duplicate(self, engine):
        biz_id, version_id = _seed_business_and_version(engine)

        with Session(engine) as session:
            diagram._write_lakebase_layout(
                session, biz_id, version_id, "ck1", _make_layout(nodes=1),
            )
            diagram._write_lakebase_layout(
                session, biz_id, version_id, "ck1", _make_layout(nodes=5),
            )
            rows = session.exec(
                select(DiagramLayout).where(DiagramLayout.cache_key == "ck1")
            ).all()
        assert len(rows) == 1

    def test_read_miss_returns_none(self, engine):
        biz_id, _ = _seed_business_and_version(engine)
        with Session(engine) as session:
            result = diagram._read_lakebase_layout(session, biz_id, "never-written")
        assert result is None

    def test_invalidation_keeps_current_version_only(self, engine):
        """Write layouts across two versions for the same business, then
        invalidate in favour of the newer version. Older version's layouts
        should be deleted; newer survives."""
        biz_id, v1_id = _seed_business_and_version(engine, version_int=1)
        # Add a second version under the same business
        with Session(engine) as session:
            biz = session.get(Business, biz_id)
            mv2 = ModelVersion(
                business_id=biz.id, version=2, status="completed",
                deployment_status="draft",
            )
            session.add(mv2)
            session.commit()
            v2_id = mv2.id

        with Session(engine) as session:
            # v1 has two cached views
            diagram._write_lakebase_layout(
                session, biz_id, v1_id, "v1_all_hide", _make_layout(nodes=2),
            )
            diagram._write_lakebase_layout(
                session, biz_id, v1_id, "v1_sales_hide", _make_layout(nodes=1),
            )
            # v2 has one cached view
            diagram._write_lakebase_layout(
                session, biz_id, v2_id, "v2_all_hide", _make_layout(nodes=4),
            )

        # Invalidate: keep v2
        with Session(engine) as session:
            diagram._invalidate_business_layouts(
                session, biz_id, keep_version_id=v2_id,
            )

        # Only v2 remains
        with Session(engine) as session:
            all_rows = session.exec(
                select(DiagramLayout).where(DiagramLayout.business_id == biz_id)
            ).all()
        assert len(all_rows) == 1
        assert all_rows[0].cache_key == "v2_all_hide"
        assert all_rows[0].version_id == v2_id

    def test_invalidation_for_business_with_no_layouts_is_noop(self, engine):
        """Calling invalidate on a business that has never cached anything must not raise."""
        biz_id, version_id = _seed_business_and_version(engine)
        with Session(engine) as session:
            diagram._invalidate_business_layouts(session, biz_id, keep_version_id=version_id)
        # No assertion needed — test passes if no exception raised

    def test_invalidation_scoped_to_single_business(self, engine):
        """Invalidating business A's layouts must not touch business B's."""
        biz_a, va = _seed_business_and_version(engine, version_int=1)
        biz_b, vb = _seed_business_and_version(engine, version_int=2)

        with Session(engine) as session:
            diagram._write_lakebase_layout(session, biz_a, va, "ck_a", _make_layout(nodes=1))
            diagram._write_lakebase_layout(session, biz_b, vb, "ck_b", _make_layout(nodes=2))

        with Session(engine) as session:
            # Invalidate A with a fake "keep" version id — should drop A's entries only
            diagram._invalidate_business_layouts(
                session, biz_a, keep_version_id="some-other-id",
            )

        with Session(engine) as session:
            a_rows = session.exec(
                select(DiagramLayout).where(DiagramLayout.business_id == biz_a)
            ).all()
            b_rows = session.exec(
                select(DiagramLayout).where(DiagramLayout.business_id == biz_b)
            ).all()
        assert len(a_rows) == 0
        assert len(b_rows) == 1
