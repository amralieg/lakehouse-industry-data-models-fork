"""next_vibes "expected work" metrics (T13, story "Next vibes as a metric
source", ADR D-044).

Aggregates the open agent-next-vibe backlog for a version into the Model
Quality Score + per-category counts the Statistics / Work-ahead surfaces
render. The source is the SAME open-agent-input population the review
issue-gate reads (``review._open_issue_product_ids``): active, non-consumed
``origin=agent_next_vibe`` ``VibeInput`` rows anchored to the version via a
``VibeInputContextLink``. The shared origin/status string literals are reused
from ``review`` so the two readers cannot drift.

Scope:

* **model** — every open agent input anchored anywhere on the version.
* **domain** — open agent inputs whose anchor resolves to a given domain.
  A link resolves to a domain when its ``domain_id`` matches directly, OR
  when its ``product_id`` belongs to that domain (the product → domain map,
  the same derivation the seeder uses for attribute/product anchors). An
  input is counted once per scope even if it carries multiple matching links.

Quality-score aggregation: the version-/domain-level representative score is
the **mean** of the in-scope open inputs' ``confidence_score`` (inputs with a
null score are ignored in the mean). ``None`` when no scored open input is in
scope. Mean (not max/latest) so a single noisy finding can't dominate and the
headline tracks the whole backlog's typical quality.

Degradation: with zero open agent inputs in scope the metrics are
all-zero/null with ``has_data=False`` — the expected pre-ingestion default,
not an error. ``has_data`` lets the caller tell "genuinely no expected work"
apart from "next_vibes not yet populated".
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Optional

from sqlmodel import select

from .db_models import Product as DbProduct, VibeInput, VibeInputContextLink
from .models import NextVibeCategory
from .review import VibeInputOrigin_AGENT, VibeInputStatus_ACTIVE


@dataclass
class NextVibeMetrics:
    """Aggregated open-backlog metrics for one scope. ``counts`` is keyed by
    ``NextVibeCategory`` value; uncategorised open inputs fall under
    ``other`` (a null category on an agent input is unexpected, but we keep
    the total honest rather than dropping the row)."""

    quality_score: Optional[float] = None
    counts: dict[str, int] = field(
        default_factory=lambda: {c.value: 0 for c in NextVibeCategory}
    )
    total_open: int = 0

    @property
    def has_data(self) -> bool:
        return self.total_open > 0


@dataclass(frozen=True)
class _OpenInput:
    """A deduped open agent input in scope (one row per input id)."""

    category: Optional[str]
    confidence_score: Optional[float]


def _open_agent_inputs(
    session, version_id: str, domain_id: Optional[str]
) -> list[_OpenInput]:
    """Distinct open agent inputs anchored to the scope on this version.

    ``domain_id=None`` ⇒ model scope (any anchor on the version). Otherwise the
    domain scope: anchors whose ``domain_id`` matches, or whose ``product_id``
    belongs to the domain (product → domain map). Deduped by input id so an
    input with several matching links counts once.
    """
    rows = session.exec(
        select(
            VibeInput.id,
            VibeInput.category,
            VibeInput.confidence_score,
            VibeInputContextLink.domain_id,
            VibeInputContextLink.product_id,
        )
        .join(VibeInput, VibeInput.id == VibeInputContextLink.input_id)
        .where(
            VibeInputContextLink.version_id == version_id,
            VibeInput.origin == VibeInputOrigin_AGENT,
            VibeInput.status == VibeInputStatus_ACTIVE,
            VibeInput.consumed == False,  # noqa: E712
        )
    ).all()

    product_domain: dict[str, Optional[str]] = {}
    if domain_id is not None:
        product_domain = {
            p.id: p.domain_id
            for p in session.exec(
                select(DbProduct).where(DbProduct.version_id == version_id)
            ).all()
        }

    by_id: dict[str, _OpenInput] = {}
    for input_id, category, score, link_domain_id, link_product_id in rows:
        if domain_id is not None:
            resolved = link_domain_id or product_domain.get(link_product_id)
            if resolved != domain_id:
                continue
        # First matching link wins; category/score are input-level so any link
        # for the same input carries identical values.
        by_id.setdefault(input_id, _OpenInput(category, score))
    return list(by_id.values())


def _aggregate(open_inputs: list[_OpenInput]) -> NextVibeMetrics:
    metrics = NextVibeMetrics()
    scores: list[float] = []
    for oi in open_inputs:
        metrics.total_open += 1
        key = oi.category if oi.category in metrics.counts else NextVibeCategory.OTHER.value
        metrics.counts[key] += 1
        if oi.confidence_score is not None:
            scores.append(oi.confidence_score)
    if scores:
        metrics.quality_score = sum(scores) / len(scores)
    return metrics


def compute_metrics(session, version_id: str) -> NextVibeMetrics:
    """Model-scope metrics: every open agent input on the version."""
    return _aggregate(_open_agent_inputs(session, version_id, None))


def compute_metrics_for_domain(
    session, version_id: str, domain_id: str
) -> NextVibeMetrics:
    """Domain-scope metrics: open agent inputs whose anchor resolves to
    ``domain_id`` (directly or via the product → domain map)."""
    return _aggregate(_open_agent_inputs(session, version_id, domain_id))


__all__ = [
    "NextVibeMetrics",
    "compute_metrics",
    "compute_metrics_for_domain",
]
