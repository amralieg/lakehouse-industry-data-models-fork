"""Unit tests for the re-link tier resolver (`backend/_relink.py`).

relink_input carries an input's anchor from its newest existing link forward
to a target version W using Task 4 lineage:

- model-wide → always auto-carry, no review
- Tier 1 exact-FQN (previous_element_id pointer, names identical) → auto, no review
- Tier 2 rename-pointer (pointer present, names differ) → auto, no review
- Tier 3 merge survivor (RunElementLineage change_kind='merge') → link + needs_review
- Tier 4 partial / deepest ancestor still present → link at ancestor + needs_review
- Tier 5 deleted, no survivor → status=deprecated, deprecated_by=None, not consumed

See task5-backend-api.md §3.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from sqlmodel import Session, SQLModel, create_engine, select
from sqlalchemy.pool import StaticPool

from vibe_modeling.backend._relink import (
    RelinkOutcome,
    relink_input,
)
from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    Domain,
    ModelVersion,
    Product,
    RunElementLineage,
    Subdomain,
    VibeInput,
    VibeInputContextLink,
)


@pytest.fixture(name="session")
def session_fixture():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    with Session(engine) as s:
        yield s


@pytest.fixture
def biz(session) -> Business:
    b = Business(name="Acme")
    session.add(b)
    session.commit()
    return b


def _ver(session, business_id, n, base=None) -> ModelVersion:
    mv = ModelVersion(business_id=business_id, version=n, status="completed",
                      scope="ecm", base_version_id=base)
    session.add(mv)
    session.commit()
    return mv


def _dom(session, version_id, name, prev=None) -> Domain:
    d = Domain(version_id=version_id, name=name, previous_element_id=prev)
    session.add(d)
    session.commit()
    return d


def _prod(session, version_id, domain_id, name, prev=None) -> Product:
    p = Product(version_id=version_id, domain_id=domain_id, name=name,
                previous_element_id=prev)
    session.add(p)
    session.commit()
    return p


def _input(session, business_id, text="rule") -> VibeInput:
    vi = VibeInput(business_id=business_id, text=text)
    session.add(vi)
    session.commit()
    return vi


def _link(session, input_id, version_id, *, is_origin=False, **anchor) -> VibeInputContextLink:
    lk = VibeInputContextLink(input_id=input_id, version_id=version_id,
                              is_origin=is_origin, **anchor)
    session.add(lk)
    session.commit()
    return lk


def _links_for(session, input_id):
    return session.exec(
        select(VibeInputContextLink).where(VibeInputContextLink.input_id == input_id)
    ).all()


def test_model_wide_always_auto_carries(session, biz):
    v1 = _ver(session, biz.id, 1)
    w = _ver(session, biz.id, 2, base=v1.id)
    vi = _input(session, biz.id)
    _link(session, vi.id, v1.id, is_origin=True)  # all-null = model-wide

    outcome = relink_input(session, vi, w.id)
    session.commit()

    assert outcome == RelinkOutcome.AUTO
    links = {lk.version_id: lk for lk in _links_for(session, vi.id)}
    assert w.id in links
    new = links[w.id]
    assert new.needs_link_review is False
    assert not any((new.domain_id, new.product_id, new.attribute_id))  # still model-wide
    # Origin link untouched.
    assert links[v1.id].is_origin is True


def test_tier1_exact_fqn_pointer_auto_no_review(session, biz):
    v1 = _ver(session, biz.id, 1)
    w = _ver(session, biz.id, 2, base=v1.id)
    d1 = _dom(session, v1.id, "Sales")
    d2 = _dom(session, w.id, "Sales", prev=d1.id)  # same name, pointer set
    vi = _input(session, biz.id)
    _link(session, vi.id, v1.id, is_origin=True, domain_id=d1.id)

    outcome = relink_input(session, vi, w.id)
    session.commit()

    assert outcome == RelinkOutcome.AUTO
    new = {lk.version_id: lk for lk in _links_for(session, vi.id)}[w.id]
    assert new.domain_id == d2.id
    assert new.needs_link_review is False


def test_tier2_rename_pointer_auto_no_review(session, biz):
    v1 = _ver(session, biz.id, 1)
    w = _ver(session, biz.id, 2, base=v1.id)
    d1 = _dom(session, v1.id, "Sales")
    p1 = _prod(session, v1.id, d1.id, "Orders")
    d2 = _dom(session, w.id, "Sales", prev=d1.id)
    p2 = _prod(session, w.id, d2.id, "SalesOrders", prev=p1.id)  # renamed, pointer set
    vi = _input(session, biz.id)
    _link(session, vi.id, v1.id, is_origin=True, domain_id=d1.id, product_id=p1.id)

    outcome = relink_input(session, vi, w.id)
    session.commit()

    assert outcome == RelinkOutcome.AUTO
    new = {lk.version_id: lk for lk in _links_for(session, vi.id)}[w.id]
    assert new.product_id == p2.id
    assert new.domain_id == d2.id
    assert new.needs_link_review is False


def test_tier3_merge_survivor_links_with_review(session, biz):
    v1 = _ver(session, biz.id, 1)
    w = _ver(session, biz.id, 2, base=v1.id)
    d1 = _dom(session, v1.id, "Sales")
    p_a = _prod(session, v1.id, d1.id, "Orders")
    d2 = _dom(session, w.id, "Sales", prev=d1.id)
    survivor = _prod(session, w.id, d2.id, "AllOrders")  # no pointer back to p_a
    # Merge edge: p_a merged into survivor.
    session.add(RunElementLineage(
        run_id="r1", version_id=w.id, element_type="product",
        change_kind="merge", old_element_id=p_a.id, new_element_id=survivor.id,
    ))
    session.commit()
    vi = _input(session, biz.id)
    _link(session, vi.id, v1.id, is_origin=True, domain_id=d1.id, product_id=p_a.id)

    outcome = relink_input(session, vi, w.id)
    session.commit()

    assert outcome == RelinkOutcome.REVIEW
    new = {lk.version_id: lk for lk in _links_for(session, vi.id)}[w.id]
    assert new.product_id == survivor.id
    assert new.needs_link_review is True


def test_tier4_partial_ancestor_links_with_review(session, biz):
    v1 = _ver(session, biz.id, 1)
    w = _ver(session, biz.id, 2, base=v1.id)
    d1 = _dom(session, v1.id, "Sales")
    p1 = _prod(session, v1.id, d1.id, "Orders")
    # Domain survives (pointer), product is gone with no survivor.
    d2 = _dom(session, w.id, "Sales", prev=d1.id)
    vi = _input(session, biz.id)
    _link(session, vi.id, v1.id, is_origin=True, domain_id=d1.id, product_id=p1.id)

    outcome = relink_input(session, vi, w.id)
    session.commit()

    assert outcome == RelinkOutcome.REVIEW
    new = {lk.version_id: lk for lk in _links_for(session, vi.id)}[w.id]
    assert new.domain_id == d2.id      # re-anchored to surviving ancestor
    assert new.product_id is None
    assert new.needs_link_review is True


def test_tier5_deleted_no_survivor_deprecates(session, biz):
    v1 = _ver(session, biz.id, 1)
    w = _ver(session, biz.id, 2, base=v1.id)
    d1 = _dom(session, v1.id, "Sales")
    p1 = _prod(session, v1.id, d1.id, "Orders")
    # Nothing in W points back; no domain survivor either.
    vi = _input(session, biz.id)
    _link(session, vi.id, v1.id, is_origin=True, domain_id=d1.id, product_id=p1.id)

    outcome = relink_input(session, vi, w.id)
    session.commit()

    assert outcome == RelinkOutcome.DEPRECATED
    assert vi.status == "deprecated"
    assert vi.deprecated_by is None
    assert vi.consumed is False
    # No link created for W.
    assert w.id not in {lk.version_id for lk in _links_for(session, vi.id)}


def test_carry_idempotent_when_link_exists(session, biz):
    v1 = _ver(session, biz.id, 1)
    w = _ver(session, biz.id, 2, base=v1.id)
    vi = _input(session, biz.id)
    _link(session, vi.id, v1.id, is_origin=True)
    _link(session, vi.id, w.id)  # already linked to W

    before = len(_links_for(session, vi.id))
    outcome = relink_input(session, vi, w.id)
    session.commit()

    assert outcome == RelinkOutcome.SKIPPED
    assert len(_links_for(session, vi.id)) == before


def test_tier4_attribute_reanchors_to_surviving_subdomain(session, biz):
    """An attribute anchor whose product is deleted-no-survivor but whose
    subdomain survives must re-anchor to the more-specific surviving subdomain
    (not skip straight to the domain)."""
    v1 = _ver(session, biz.id, 1)
    w = _ver(session, biz.id, 2, base=v1.id)
    d1 = _dom(session, v1.id, "Sales")
    p1 = _prod(session, v1.id, d1.id, "Orders")
    sd1 = Subdomain(version_id=v1.id, domain_id=d1.id, name="Fulfilment")
    session.add(sd1)
    session.commit()
    a1 = Attribute(product_id=p1.id, name="order_id")
    session.add(a1)
    session.commit()

    # W: domain + subdomain survive (pointers); product + attribute are gone
    # with no survivor.
    d2 = _dom(session, w.id, "Sales", prev=d1.id)
    sd2 = Subdomain(version_id=w.id, domain_id=d2.id, name="Fulfilment",
                    previous_element_id=sd1.id)
    session.add(sd2)
    session.commit()

    vi = _input(session, biz.id)
    _link(session, vi.id, v1.id, is_origin=True, domain_id=d1.id,
          subdomain_id=sd1.id, product_id=p1.id, attribute_id=a1.id)

    outcome = relink_input(session, vi, w.id)
    session.commit()

    assert outcome == RelinkOutcome.REVIEW
    new = {lk.version_id: lk for lk in _links_for(session, vi.id)}[w.id]
    # Re-anchored to the surviving subdomain, not the domain.
    assert new.subdomain_id == sd2.id
    assert new.domain_id == d2.id
    assert new.product_id is None
    assert new.attribute_id is None
    assert new.needs_link_review is True
