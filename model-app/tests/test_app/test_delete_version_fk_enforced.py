"""FK-enforced regression tests for ``DELETE .../versions/{version_id}``.

Runs the per-version delete under ``PRAGMA foreign_keys=ON`` (the ``fk_engine``
/ ``fk_client`` fixtures) to reproduce the production 500
(``ForeignKeyViolation "subdomains_domain_id_fkey"`` and friends) and prove the
manual cascade order + the GAP A inbound-pointer NULLing are correct.

Covers:
  - version with Subdomain + ProductReview + VibeInputContextLink → 200, gone
  - GAP A: a SURVIVING run's RunOperation.parent/output_version_id points at
    the deleted version → delete succeeds, RunOperation survives with FKs NULLed
"""

from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Business,
    ModelVersion,
    Product,
    ProductReview,
    Run,
    RunOperation,
    Subdomain,
    VibeInput,
    VibeInputContextLink,
)


def _seed_business_with_two_versions(engine) -> tuple[str, str, str]:
    """Seed a business with two completed ECM versions; return
    (business_id, v1_id, v2_id). v2 is latest-in-scope (the deletable one)."""
    with Session(engine) as s:
        b = Business(name="Ver Corp", description="d", industry_alignment="Retail")
        s.add(b)
        s.flush()
        v1 = ModelVersion(business_id=b.id, version=1, scope="ecm", status="completed")
        v2 = ModelVersion(business_id=b.id, version=2, scope="ecm", status="completed")
        s.add(v1)
        s.add(v2)
        s.commit()
        return b.id, v1.id, v2.id


def test_delete_version_clears_subdomain_review_and_context_link(fk_client, fk_engine):
    bid, _v1, v2 = _seed_business_with_two_versions(fk_engine)
    with Session(fk_engine) as s:
        from vibe_modeling.backend.db_models import Domain
        dom = Domain(version_id=v2, name="Sales")
        s.add(dom)
        s.flush()
        dom_id = dom.id
        sub = Subdomain(version_id=v2, domain_id=dom_id, name="Orders")
        s.add(sub)
        s.flush()
        prod = Product(domain_id=dom_id, version_id=v2, name="Order", subdomain_id=sub.id)
        s.add(prod)
        s.flush()
        s.add(ProductReview(version_id=v2, product_id=prod.id, state="reviewed"))
        vi = VibeInput(business_id=bid, origin="user", text="x")
        s.add(vi)
        s.flush()
        s.add(VibeInputContextLink(input_id=vi.id, version_id=v2, product_id=prod.id))
        s.commit()

    resp = fk_client.delete(f"/api/businesses/{bid}/versions/{v2}")
    assert resp.status_code == 200, resp.text

    with Session(fk_engine) as s:
        assert s.get(ModelVersion, v2) is None
        assert s.exec(select(Subdomain).where(Subdomain.version_id == v2)).all() == []
        assert s.exec(select(ProductReview).where(ProductReview.version_id == v2)).all() == []
        assert s.exec(select(VibeInputContextLink).where(VibeInputContextLink.version_id == v2)).all() == []


def test_delete_version_keeps_run_with_surviving_sibling_output(fk_client, fk_engine):
    """A run with TWO output ops - one producing the deleted version, one
    producing a surviving sibling - is NOT GC'd. The deleted-version op dies
    via ``output_version_id`` CASCADE; the surviving-output op stays with its
    ``parent_version_id`` (which pointed at the deleted version) SET NULL."""
    bid, v1, v2 = _seed_business_with_two_versions(fk_engine)
    with Session(fk_engine) as s:
        run = Run(business_id=bid, version_id=v1, intent="vibe-iterate", status="completed", parameters_json="{}")
        s.add(run)
        s.flush()
        # Op that PRODUCED the version being deleted (v2) -> cascades away.
        op_deleted = RunOperation(
            run_id=run.id, step_index=0, operation_name="generate_ecm",
            parent_version_id=v1, output_version_id=v2, status="succeeded",
        )
        # Op that produced a SURVIVING sibling (v1) but sources the deleted v2 ->
        # stays, parent pointer SET NULL.
        op_surviving = RunOperation(
            run_id=run.id, step_index=1, operation_name="shrink_to_mvm",
            parent_version_id=v2, output_version_id=v1, status="succeeded",
        )
        s.add(op_deleted)
        s.add(op_surviving)
        s.commit()
        op_deleted_id = op_deleted.id
        op_surviving_id = op_surviving.id
        run_id = run.id

    resp = fk_client.delete(f"/api/businesses/{bid}/versions/{v2}")
    assert resp.status_code == 200, resp.text

    with Session(fk_engine) as s:
        assert s.get(ModelVersion, v2) is None
        # Run kept: it still owns a surviving output.
        assert s.get(Run, run_id) is not None
        # Deleted-version op is gone via output_version_id CASCADE.
        assert s.get(RunOperation, op_deleted_id) is None
        # Surviving-output op stays; its parent pointer (deleted v2) SET NULL,
        # its output pointer (surviving v1) intact.
        surviving = s.get(RunOperation, op_surviving_id)
        assert surviving is not None
        assert surviving.parent_version_id is None
        assert surviving.output_version_id == v1
