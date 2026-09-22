"""Re-link tier resolver: carry a VibeInput's anchor forward to a new version.

Consumes Task 4 lineage (``previous_element_id`` self-FKs for 1:1 rename/exact
matches, ``RunElementLineage`` rows for merges/deletes) to decide how an
input's context anchor maps onto a target version W. See task5-backend-api.md §3.

The single entry point is :func:`relink_input`. It reads the input's newest
existing link (origin if that's all there is), resolves the anchor through the
ordered tiers, and *creates* a new link for W (never moves an existing link;
the origin link is immutable). Carry is idempotent: a pre-existing link to W
short-circuits to ``SKIPPED``.
"""

from __future__ import annotations

from enum import Enum
from typing import Optional

from sqlmodel import Session, select

from .db_models import (
    Attribute,
    Domain,
    ForeignKeyLink,
    Product,
    RunElementLineage,
    Subdomain,
    VibeInput,
    VibeInputContextLink,
)


class RelinkOutcome(str, Enum):
    AUTO = "auto"               # tiers 1+2 + model-wide
    REVIEW = "review"           # tiers 3+4
    DEPRECATED = "deprecated"   # tier 5
    SKIPPED = "skipped"         # already had a link to W


# Tier labels surfaced in the review queue (§4.3).
TIER_MERGE_SURVIVOR = "merge_survivor"
TIER_PARTIAL_ANCESTOR = "partial_ancestor"


def _newest_link(session: Session, input_id: str) -> Optional[VibeInputContextLink]:
    """The input's newest non-origin link if any, else the origin link."""
    links = session.exec(
        select(VibeInputContextLink)
        .where(VibeInputContextLink.input_id == input_id)
        .order_by(VibeInputContextLink.created_at)
    ).all()
    if not links:
        return None
    non_origin = [lk for lk in links if not lk.is_origin]
    if non_origin:
        return non_origin[-1]
    return links[-1]


def _is_model_wide(link: VibeInputContextLink) -> bool:
    return not any((link.domain_id, link.subdomain_id, link.product_id,
                    link.attribute_id, link.fk_link_id))


def _leaf(link: VibeInputContextLink) -> tuple[str, Optional[str]]:
    """The (element_type, element_id) of the deepest anchored element."""
    if link.fk_link_id:
        return ("fk_link", link.fk_link_id)
    if link.attribute_id:
        return ("attribute", link.attribute_id)
    if link.product_id:
        return ("product", link.product_id)
    if link.subdomain_id:
        return ("subdomain", link.subdomain_id)
    if link.domain_id:
        return ("domain", link.domain_id)
    return ("model_wide", None)


def _forward_via_pointer(
    session: Session, element_type: str, element_id: str, version_id: str
):
    """Find the version-W row whose ``previous_element_id`` points at element_id."""
    model = {
        "domain": Domain, "subdomain": Subdomain, "product": Product,
        "attribute": Attribute, "fk_link": ForeignKeyLink,
    }.get(element_type)
    if model is None:
        return None
    rows = session.exec(
        select(model).where(model.previous_element_id == element_id)
    ).all()
    for row in rows:
        if _row_on_version(session, model, row, version_id):
            return row
    return None


def _row_on_version(session: Session, model, row, version_id: str) -> bool:
    if model is Attribute:
        prod = session.get(Product, row.product_id)
        return bool(prod and prod.version_id == version_id)
    return getattr(row, "version_id", None) == version_id


def _anchor_kwargs_for(element_type: str, row, link: VibeInputContextLink) -> dict:
    """Build the element-id kwargs for a new link anchored at ``row``, keeping
    the parent ids consistent with the resolved leaf."""
    kwargs = {"domain_id": None, "subdomain_id": None, "product_id": None,
              "attribute_id": None, "fk_link_id": None}
    if element_type == "domain":
        kwargs["domain_id"] = row.id
    elif element_type == "subdomain":
        kwargs["subdomain_id"] = row.id
        kwargs["domain_id"] = row.domain_id
    elif element_type == "product":
        kwargs["product_id"] = row.id
        kwargs["domain_id"] = row.domain_id
    elif element_type == "attribute":
        kwargs["attribute_id"] = row.id
        kwargs["product_id"] = row.product_id
    elif element_type == "fk_link":
        kwargs["fk_link_id"] = row.id
    return kwargs


def _merge_survivor(session: Session, element_id: str, version_id: str):
    """The version-W survivor row for a merged-away element_id, if any."""
    edge = session.exec(
        select(RunElementLineage).where(
            RunElementLineage.version_id == version_id,
            RunElementLineage.old_element_id == element_id,
            RunElementLineage.change_kind == "merge",
        )
    ).first()
    if edge is None or not edge.new_element_id:
        return None
    model = {
        "domain": Domain, "subdomain": Subdomain, "product": Product,
        "attribute": Attribute, "fk_link": ForeignKeyLink,
    }.get(edge.element_type)
    if model is None:
        return None
    row = session.get(model, edge.new_element_id)
    if row is None:
        return None
    return (edge.element_type, row)


def _deepest_ancestor(session: Session, link: VibeInputContextLink, version_id: str):
    """Walk the anchor up the hierarchy; return the deepest ancestor that has a
    forward target on W. Returns (element_type, row) or None."""
    # Ancestor chain leaf-first, excluding the leaf itself (handled by tiers 1-3).
    chain: list[tuple[str, Optional[str]]] = []
    if link.attribute_id or link.fk_link_id:
        chain.append(("product", link.product_id))
        chain.append(("subdomain", link.subdomain_id))
        chain.append(("domain", link.domain_id))
    elif link.product_id:
        chain.append(("subdomain", link.subdomain_id))
        chain.append(("domain", link.domain_id))
    elif link.subdomain_id:
        chain.append(("domain", link.domain_id))
    for etype, eid in chain:
        if not eid:
            continue
        row = _forward_via_pointer(session, etype, eid, version_id)
        if row is not None:
            return (etype, row)
    return None


def _create_link(session: Session, input_id, version_id, kwargs, needs_review):
    link = VibeInputContextLink(
        input_id=input_id, version_id=version_id, is_origin=False,
        needs_link_review=needs_review, **kwargs,
    )
    session.add(link)
    return link


def relink_input(session: Session, vi: VibeInput, version_id: str) -> RelinkOutcome:
    """Carry ``vi``'s anchor forward to ``version_id`` via the ordered tiers.

    Creates at most one new link for ``version_id``. Idempotent: returns
    ``SKIPPED`` without creating a link if one to ``version_id`` already exists.
    Tier 5 deprecates the input (``deprecated_by=None``) and creates no link.
    Caller is responsible for committing.
    """
    existing = session.exec(
        select(VibeInputContextLink).where(
            VibeInputContextLink.input_id == vi.id,
            VibeInputContextLink.version_id == version_id,
        )
    ).first()
    if existing is not None:
        return RelinkOutcome.SKIPPED

    link = _newest_link(session, vi.id)
    if link is None:
        return RelinkOutcome.SKIPPED

    if _is_model_wide(link):
        kwargs = {"domain_id": None, "subdomain_id": None, "product_id": None,
                  "attribute_id": None, "fk_link_id": None}
        _create_link(session, vi.id, version_id, kwargs, needs_review=False)
        return RelinkOutcome.AUTO

    element_type, element_id = _leaf(link)

    # Tiers 1+2: forward pointer (exact-FQN or rename). Both auto-link.
    target = _forward_via_pointer(session, element_type, element_id, version_id)
    if target is not None:
        kwargs = _anchor_kwargs_for(element_type, target, link)
        _create_link(session, vi.id, version_id, kwargs, needs_review=False)
        return RelinkOutcome.AUTO

    # Tier 3: merge survivor → link + review.
    survivor = _merge_survivor(session, element_id, version_id)
    if survivor is not None:
        s_type, s_row = survivor
        kwargs = _anchor_kwargs_for(s_type, s_row, link)
        _create_link(session, vi.id, version_id, kwargs, needs_review=True)
        return RelinkOutcome.REVIEW

    # Tier 4: deepest matching ancestor still present → link + review.
    ancestor = _deepest_ancestor(session, link, version_id)
    if ancestor is not None:
        a_type, a_row = ancestor
        kwargs = _anchor_kwargs_for(a_type, a_row, link)
        _create_link(session, vi.id, version_id, kwargs, needs_review=True)
        return RelinkOutcome.REVIEW

    # Tier 5: deleted, no survivor → system-deprecate (no link, no consume).
    vi.status = "deprecated"
    vi.deprecated_by = None
    session.add(vi)
    return RelinkOutcome.DEPRECATED
