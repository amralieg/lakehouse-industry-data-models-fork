"""Regression: force-resync (clear_version_data) must be FK-safe under
enforcement.

Track 4's per-version volume resolver made a DRAFT version's resync actually
reach ``clear_version_data`` (it previously no-op'd on an empty uc_catalog).
That exposed a latent FK-ordering bug: ``_delete_existing`` deleted the element
tree without first detaching the VibeInput anchors / product reviews / run
lineage that FK-reference it, so a seeded draft's resync tripped
``vibe_input_context_links_product_id_fkey`` on production Postgres and leaked
a raw DB error. This test reproduces it against the FK-enforcing engine.
"""

from __future__ import annotations

from unittest.mock import patch

import pytest
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    Domain,
    ModelVersion,
    Product,
    ProductReview,
    Subdomain,
    VibeInput,
    VibeInputContextLink,
)
from vibe_modeling.backend.model_sync import ModelSyncService


def _seed_version_with_anchored_product(session) -> str:
    biz = Business(name="Resync Co", kind="business")
    session.add(biz)
    session.flush()
    mv = ModelVersion(
        business_id=biz.id, version=1, scope="ecm", status="completed",
    )
    session.add(mv)
    session.flush()
    domain = Domain(version_id=mv.id, name="sales")
    session.add(domain)
    session.flush()
    # Subdomain: child of domain (subdomains.domain_id -> domains), parent of
    # product (products.subdomain_id -> subdomains). Exercises the full
    # leaf-to-root FK chain in the resync clear.
    subdomain = Subdomain(version_id=mv.id, domain_id=domain.id, name="accounts")
    session.add(subdomain)
    session.flush()
    product = Product(
        version_id=mv.id, domain_id=domain.id, subdomain_id=subdomain.id,
        name="customer",
    )
    session.add(product)
    session.flush()
    session.add(
        Attribute(version_id=mv.id, product_id=product.id, name="id", type="BIGINT")
    )
    vi = VibeInput(business_id=biz.id, text="anchored comment")
    session.add(vi)
    session.flush()
    # The anchor that FK-references the product being cleared.
    session.add(
        VibeInputContextLink(
            input_id=vi.id, version_id=mv.id, product_id=product.id
        )
    )
    session.add(
        ProductReview(version_id=mv.id, product_id=product.id, status="reviewed")
    )
    session.commit()
    return mv.id


def test_clear_version_data_is_fk_safe(fk_engine):
    """clear_version_data must clear a version's element tree under FK
    enforcement without a ForeignKeyViolation, even when a subdomain, an
    anchored VibeInput, and a product review reference the tree.

    Outcome-based (mechanism-agnostic): the current implementation detaches
    the anchor links (SET NULL) for later re-anchor and sweeps subdomains /
    product_reviews via DB cascades; an earlier implementation deleted them
    outright. Either way the invariants below must hold: no FK violation, the
    element tree is gone, no anchor link is left pointing at a deleted product,
    and the ModelVersion row survives for the re-sync to repopulate.
    """
    with Session(fk_engine) as session:
        version_id = _seed_version_with_anchored_product(session)
        # Must not raise IntegrityError (the reported production 500).
        try:
            ModelSyncService(session).clear_version_data(version_id)
            session.commit()
        except IntegrityError as exc:  # pragma: no cover - the bug being fixed
            pytest.fail(f"clear_version_data tripped an FK violation: {exc}")

        # Element tree is gone.
        assert session.exec(
            select(Product).where(Product.version_id == version_id)
        ).all() == []
        assert session.exec(
            select(Subdomain).where(Subdomain.version_id == version_id)
        ).all() == []
        assert session.exec(
            select(Domain).where(Domain.version_id == version_id)
        ).all() == []
        # No anchor link is left dangling at a deleted product (either the link
        # was deleted, or it was detached with product_id set NULL for reanchor).
        for link in session.exec(
            select(VibeInputContextLink).where(
                VibeInputContextLink.version_id == version_id
            )
        ).all():
            assert link.product_id is None
        # No product review is left pointing at a deleted product.
        for review in session.exec(
            select(ProductReview).where(ProductReview.version_id == version_id)
        ).all():
            assert session.get(Product, review.product_id) is None
        # The ModelVersion row itself survives (resync repopulates it).
        assert session.get(ModelVersion, version_id) is not None


def test_delete_existing_flushes_detach_before_raw_bulk_delete(fk_engine):
    """Structural regression trap for the Postgres FK-violation bug: the
    detach UPDATEs staged by ``_capture_and_detach_context_links`` (plain
    ORM ``session.add()``, never flushed by that call on its own) must be
    flushed to the DB BEFORE ``bulk_delete_version_elements`` runs its raw
    ``session.connection()`` DELETE against the same rows. On Postgres, a
    raw Core statement issued via ``session.connection()`` does not see
    this session's still-pending ORM state - only rows already flushed to
    the DB - so without the flush the DELETE sees the OLD (still anchored)
    foreign key value and trips a ``ForeignKeyViolation``.

    SQLite has no real FK enforcement in the test engine (see the module
    docstring on ``services/_bulk_model_io.py``), so the violation itself
    can't be reproduced here. Instead this test intercepts the real,
    un-shortened ``_delete_existing`` flow at the exact point
    ``bulk_delete_version_elements`` would run its raw delete, and reads
    the anchored link's ``product_id`` back through a RAW connection query
    (bypassing the ORM identity map, which would just report the in-memory
    value regardless of flush state). If the detach flush happened, the raw
    read sees NULL; if it did not, it still sees the stale anchored id -
    which is precisely the state a real Postgres DELETE would choke on.
    Simply counting/ordering ``Session.flush`` calls is NOT a safe way to
    write this test: unrelated autoflushes on the SELECTs earlier in
    ``_capture_and_detach_context_links`` happen unconditionally and make a
    call-order-only assertion pass even without the real fix - this was
    verified by hand while writing this test.
    """
    with Session(fk_engine) as session:
        version_id = _seed_version_with_anchored_product(session)
        link = session.exec(
            select(VibeInputContextLink).where(
                VibeInputContextLink.version_id == version_id
            )
        ).one()
        link_id = link.id

        seen: dict[str, object] = {}

        def _spy_bulk_delete(*args, **kwargs):
            row = session.connection().execute(
                text(
                    "SELECT product_id FROM vibe_input_context_links WHERE id = :id"
                ),
                {"id": link_id},
            ).fetchone()
            seen["db_product_id_at_delete_time"] = row[0]

        with patch(
            "vibe_modeling.backend.model_sync.bulk_delete_version_elements",
            side_effect=_spy_bulk_delete,
        ):
            service = ModelSyncService(session)
            # Exercise the real, un-shortened flow.
            service._delete_existing(version_id)

        assert seen["db_product_id_at_delete_time"] is None, (
            "the detach UPDATE was not flushed before the raw-connection "
            "bulk delete ran - a real Postgres DELETE at this point would "
            "still see the anchored FK value and raise ForeignKeyViolation"
        )
