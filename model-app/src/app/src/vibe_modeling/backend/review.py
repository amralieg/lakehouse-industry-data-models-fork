"""Product-canonical review state: default-state rule, cascade fan-out, and
the product-level progress measure (ADR D-044).

Review state is stored sparsely in ``product_reviews``: a row exists only on
an explicit user mark. For any product without a stored row the *effective*
state is computed:

    no_review_needed  iff  ChangeStatus == unchanged AND no open issues
    not_reviewed      otherwise

Both signals reuse existing infrastructure — no new change/issue tracking:

* **"unchanged"** comes from the live per-product change diff already computed
  by ``explorer._compute_diff`` (the source behind the UI change icons). Its
  ``products`` map is keyed by ``(domain_name, product_name)`` and holds only
  NEW/MODIFIED entries; absence ⇒ ``unchanged``.
* **"has open issues"** comes from open agent-origin (``agent_next_vibe``)
  ``VibeInput`` rows anchored to the product via ``VibeInputContextLink``.
  This source is seeded/empty until a separate ingestion epic lands, so the
  issue-gate is EXPECTED to be inert now (degrades to "no issues") — that is
  correct, not a bug.

Progress is product-level: ``reviewed ÷ review-needed``, where review-needed
excludes products whose effective state is ``no_review_needed``. Domain /
subdomain percentages are derived rollups over the same per-product states —
there is no stored aggregate.
"""

from __future__ import annotations

from dataclasses import dataclass

from sqlmodel import select

from .db_models import (
    Domain as DbDomain,
    Product as DbProduct,
    ProductReview,
    VibeInput,
    VibeInputContextLink,
)
from .models import ChangeStatus, ReviewState


# Effective states that count toward the "review-needed" denominator.
# ``no_review_needed`` is the only state excluded from progress.
_REVIEW_NEEDED_STATES = {ReviewState.REVIEWED, ReviewState.NOT_REVIEWED}


@dataclass(frozen=True)
class ProductReviewView:
    """The effective review state of a single product for a version."""

    product_id: str
    domain_id: str
    state: ReviewState
    # True when the state is a stored user mark; False when computed.
    is_explicit: bool


def compute_default_state(
    *,
    is_unchanged: bool,
    has_open_issues: bool,
) -> ReviewState:
    """The computed default for an unmarked product.

    ``no_review_needed`` iff the product is unchanged since the previous
    version AND has no open anchored issues; ``not_reviewed`` otherwise.
    Always user-overridable (an explicit ``product_reviews`` row wins over
    this default).
    """
    if is_unchanged and not has_open_issues:
        return ReviewState.NO_REVIEW_NEEDED
    return ReviewState.NOT_REVIEWED


def _open_issue_product_ids(session, version_id: str) -> set[str]:
    """Product ids with at least one open agent-origin issue on this version.

    "Open" = active, non-consumed ``agent_next_vibe`` ``VibeInput`` anchored
    to the product via a ``VibeInputContextLink`` on the same version. Returns
    an empty set until the next_vibes ingestion epic seeds these inputs — the
    degradation is intentional (see module docstring).
    """
    rows = session.exec(
        select(VibeInputContextLink.product_id)
        .join(VibeInput, VibeInput.id == VibeInputContextLink.input_id)
        .where(
            VibeInputContextLink.version_id == version_id,
            VibeInputContextLink.product_id.is_not(None),
            VibeInput.origin == VibeInputOrigin_AGENT,
            VibeInput.status == VibeInputStatus_ACTIVE,
            VibeInput.consumed == False,  # noqa: E712
        )
    ).all()
    return {pid for pid in rows if pid}


# String literals mirroring the model enums — kept module-local so the query
# above stays a pure value comparison against the string columns.
VibeInputOrigin_AGENT = "agent_next_vibe"
VibeInputStatus_ACTIVE = "active"


def effective_states(
    session,
    version_id: str,
    change_status: dict[tuple[str, str], ChangeStatus],
    has_predecessor: bool = True,
) -> list[ProductReviewView]:
    """Resolve the effective review state of every product on a version.

    ``change_status`` is ``explorer._compute_diff(...)["products"]`` — a
    ``(domain_name, product_name) -> ChangeStatus`` map holding only the
    changed products (absence ⇒ unchanged). For each DB product we look up an
    explicit ``product_reviews`` row first; if none, we compute the default
    from the change diff + the open-issue gate.

    ``has_predecessor=False`` (a base / first version) means "unchanged since
    previous" is undefined — nothing can be ``no_review_needed`` by the
    change signal, so every unmarked product defaults to ``not_reviewed``.
    """
    domain_rows = session.exec(
        select(DbDomain).where(DbDomain.version_id == version_id)
    ).all()
    domain_name_by_id = {d.id: d.name for d in domain_rows}

    product_rows = session.exec(
        select(DbProduct).where(DbProduct.version_id == version_id)
    ).all()

    explicit = {
        r.product_id: ReviewState(r.state)
        for r in session.exec(
            select(ProductReview).where(ProductReview.version_id == version_id)
        ).all()
    }

    open_issue_pids = _open_issue_product_ids(session, version_id)

    views: list[ProductReviewView] = []
    for p in product_rows:
        if p.id in explicit:
            views.append(
                ProductReviewView(
                    product_id=p.id,
                    domain_id=p.domain_id,
                    state=explicit[p.id],
                    is_explicit=True,
                )
            )
            continue
        domain_name = domain_name_by_id.get(p.domain_id, "")
        status = change_status.get((domain_name, p.name), ChangeStatus.UNCHANGED)
        is_unchanged = has_predecessor and status == ChangeStatus.UNCHANGED
        state = compute_default_state(
            is_unchanged=is_unchanged,
            has_open_issues=p.id in open_issue_pids,
        )
        views.append(
            ProductReviewView(
                product_id=p.id,
                domain_id=p.domain_id,
                state=state,
                is_explicit=False,
            )
        )
    return views


def _progress(views: list[ProductReviewView]) -> tuple[float, int, int, int]:
    """Return ``(pct, reviewed, review_needed, no_review_needed)``.

    ``pct`` = reviewed ÷ review-needed (0.0 when nothing needs review).
    """
    reviewed = sum(1 for v in views if v.state == ReviewState.REVIEWED)
    no_review_needed = sum(
        1 for v in views if v.state == ReviewState.NO_REVIEW_NEEDED
    )
    review_needed = sum(1 for v in views if v.state in _REVIEW_NEEDED_STATES)
    pct = (reviewed / review_needed) if review_needed else 0.0
    return pct, reviewed, review_needed, no_review_needed


def compute_progress(
    session,
    version_id: str,
    change_status: dict[tuple[str, str], ChangeStatus],
    has_predecessor: bool = True,
) -> tuple[float, int, int, int]:
    """Product-level review progress for the whole version.

    Returns ``(review_pct, reviewed_count, review_needed_count,
    no_review_needed_count)``.
    """
    return _progress(
        effective_states(session, version_id, change_status, has_predecessor)
    )


def compute_progress_by_domain(
    session,
    version_id: str,
    change_status: dict[tuple[str, str], ChangeStatus],
    has_predecessor: bool = True,
) -> dict[str, tuple[float, int, int, int]]:
    """Derived per-domain rollup: ``domain_id -> (pct, reviewed,
    review_needed, no_review_needed)``. No stored aggregate."""
    views = effective_states(session, version_id, change_status, has_predecessor)
    by_domain: dict[str, list[ProductReviewView]] = {}
    for v in views:
        by_domain.setdefault(v.domain_id, []).append(v)
    return {did: _progress(vs) for did, vs in by_domain.items()}
