"""Seed fake VibeInputs (both origins) so the next_vibes-metrics work can be
developed and tested before the real ingestion epic lands.

The next_vibes-as-a-metric-source story (T12/T13) and ADR D-044 both depend on
``vibe_inputs`` being populated with two flavours of input:

  * **agent-origin** (``origin=agent_next_vibe``) — anchored to a model element
    via ``VibeInputContextLink``, each carrying a structured *category*
    (``NextVibeCategory``: static_analysis / priority_remediation / other), a
    *severity* (``priority``), and the model *Quality Score*
    (``confidence_score``). These feed the review "No review needed" issue-gate,
    the Statistics Quality Score, and the Work-ahead backlog.
  * **user-origin** (``origin=user``) — anchored to elements; ``category`` is
    null (feedback has no category). The annotation-volume signal.

Representation contract (the structured shape this epic defines; NOT a text
convention):

    a next_vibe finding = VibeInput{
        origin       = agent_next_vibe,
        category     = NextVibeCategory enum,
        priority     = severity (low | medium | high),
        confidence_score = quality score (0..1),
        text         = plain human description (no prefix),
    } anchored to its element via VibeInputContextLink.

    a feedback input = VibeInput{ origin = user, category = null }.

``VibeInput.category`` is a real nullable column (migration v_0_6_3); the enum
lives in ``backend/models.py`` as ``NextVibeCategory``. The metrics layer counts
agent inputs by that column — there is no text-prefix parsing.

This is a DB-session seeder built on the existing SQLModel rows. It follows the
same VibeInput/VibeInputContextLink composition the app uses, writing a
``VibeInput`` + a ``VibeInputContextLink`` directly; it spreads anchors across
elements and populates the structured category / severity / quality-score
fields. Seeded rows read back unchanged through
``GET /businesses/{id}/inputs`` (``listVibeInputs``).

Standalone usage against the dev/prod DB::

    PYENV_VERSION=vibe-modeling python scripts/dev/seed_vibe_inputs.py \
        --business-id <bid> --version-id <vid> --agent 12 --user 6

Programmatic usage (tests / fixtures)::

    from scripts.dev.seed_vibe_inputs import seed_vibe_inputs
    result = seed_vibe_inputs(session, business_id, version_id,
                              n_agent=12, n_user=6, quality_score=0.76)
"""

from __future__ import annotations

import argparse
import os
import sys
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Optional

sys.path.insert(
    0,
    os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"),
)

from sqlmodel import Session, select  # noqa: E402

from vibe_modeling.backend.db_models import (  # noqa: E402
    Attribute,
    Domain,
    ModelVersion,
    Product,
    VibeInput,
    VibeInputContextLink,
)
from vibe_modeling.backend.models import (  # noqa: E402
    NextVibeCategory,
    VibeInputOrigin,
    VibeInputPriority,
    VibeInputStatus,
)


def _now() -> datetime:
    return datetime.now(timezone.utc)


# Severity (priority) that pairs with each next-vibe category. Static-analysis
# findings are informational (low), prioritized remediations are actionable
# (high), other known issues sit in the middle (medium).
_CATEGORY_SEVERITY: dict[NextVibeCategory, VibeInputPriority] = {
    NextVibeCategory.STATIC_ANALYSIS: VibeInputPriority.LOW,
    NextVibeCategory.PRIORITY_REMEDIATION: VibeInputPriority.HIGH,
    NextVibeCategory.OTHER: VibeInputPriority.MEDIUM,
}

# Round-robin category cycle: a realistic mix weighted toward priority
# remediations (the actionable backlog) with a tail of SA + other.
_DEFAULT_CATEGORY_CYCLE: tuple[NextVibeCategory, ...] = (
    NextVibeCategory.PRIORITY_REMEDIATION,
    NextVibeCategory.STATIC_ANALYSIS,
    NextVibeCategory.PRIORITY_REMEDIATION,
    NextVibeCategory.OTHER,
    NextVibeCategory.STATIC_ANALYSIS,
)


@dataclass
class _Anchor:
    """One element anchor on a version (any subset of element ids; all-null =
    model-wide)."""

    domain_id: Optional[str] = None
    product_id: Optional[str] = None
    attribute_id: Optional[str] = None


@dataclass
class SeedResult:
    """What the seeder produced — ids so callers can read back / assert."""

    agent_input_ids: list[str] = field(default_factory=list)
    user_input_ids: list[str] = field(default_factory=list)
    link_ids: list[str] = field(default_factory=list)
    category_counts: dict[str, int] = field(default_factory=dict)

    @property
    def total(self) -> int:
        return len(self.agent_input_ids) + len(self.user_input_ids)


def _collect_anchors(session: Session, version_id: str) -> list[_Anchor]:
    """Element anchors on a version, leaf-first (attribute → product → domain),
    so inputs spread across the most specific elements available. Always
    appends a model-wide anchor so seeding still works on an element-less
    version."""
    anchors: list[_Anchor] = []

    products = session.exec(
        select(Product).where(Product.version_id == version_id)
    ).all()
    product_ids = [p.id for p in products]
    domain_by_product = {p.id: p.domain_id for p in products}

    if product_ids:
        attrs = session.exec(
            select(Attribute).where(Attribute.product_id.in_(product_ids))
        ).all()
        for a in attrs:
            dom = domain_by_product.get(a.product_id)
            anchors.append(
                _Anchor(domain_id=dom, product_id=a.product_id, attribute_id=a.id)
            )

    for p in products:
        anchors.append(_Anchor(domain_id=p.domain_id, product_id=p.id))

    domains = session.exec(
        select(Domain).where(Domain.version_id == version_id)
    ).all()
    for d in domains:
        anchors.append(_Anchor(domain_id=d.id))

    # Model-wide fallback (and a guaranteed anchor on element-less versions).
    anchors.append(_Anchor())
    return anchors


def _add_link(
    session: Session,
    input_id: str,
    version_id: str,
    anchor: _Anchor,
) -> str:
    link = VibeInputContextLink(
        input_id=input_id,
        version_id=version_id,
        domain_id=anchor.domain_id,
        product_id=anchor.product_id,
        attribute_id=anchor.attribute_id,
        is_origin=True,
        needs_link_review=False,
    )
    session.add(link)
    session.flush()
    return link.id


def seed_vibe_inputs(
    session: Session,
    business_id: str,
    version_id: str,
    *,
    n_agent: int = 8,
    n_user: int = 4,
    quality_score: Optional[float] = 0.76,
    category_cycle: tuple[NextVibeCategory, ...] = _DEFAULT_CATEGORY_CYCLE,
    author: str = "seed-user@example.com",
    commit: bool = True,
) -> SeedResult:
    """Seed ``n_agent`` agent-origin + ``n_user`` user-origin VibeInputs anchored
    across the elements of ``version_id``.

    Each agent input carries a structured *category* (round-robin over
    ``category_cycle``) on ``VibeInput.category``, a matching *severity*
    (``priority``), the model *Quality Score* (``confidence_score``), and a
    plain-text human description. User inputs carry a null category, no
    confidence, and a medium priority — the annotation-volume signal.

    Returns a :class:`SeedResult` with the created ids and per-category counts.
    Set ``commit=False`` to leave the transaction open (e.g. inside a fixture
    that manages its own commit).
    """
    biz_version = session.exec(
        select(ModelVersion).where(
            ModelVersion.id == version_id,
            ModelVersion.business_id == business_id,
        )
    ).first()
    if biz_version is None:
        raise ValueError(
            f"version {version_id!r} not found for business {business_id!r}"
        )

    anchors = _collect_anchors(session, version_id)
    result = SeedResult()

    # --- agent-origin (next_vibe-type) -------------------------------------
    for i in range(n_agent):
        category = category_cycle[i % len(category_cycle)]
        severity = _CATEGORY_SEVERITY[category]
        anchor = anchors[i % len(anchors)]
        vi = VibeInput(
            business_id=business_id,
            origin=VibeInputOrigin.AGENT_NEXT_VIBE.value,
            author="",
            text=f"seeded agent finding #{i + 1}",
            category=category.value,
            priority=severity.value,
            confidence_score=quality_score,
            consumed=False,
            selected_for_run=False,
            status=VibeInputStatus.ACTIVE.value,
            created_at=_now(),
            updated_at=_now(),
        )
        session.add(vi)
        session.flush()
        result.agent_input_ids.append(vi.id)
        result.link_ids.append(_add_link(session, vi.id, version_id, anchor))
        result.category_counts[category.value] = (
            result.category_counts.get(category.value, 0) + 1
        )

    # --- user-origin (feedback) --------------------------------------------
    for j in range(n_user):
        anchor = anchors[j % len(anchors)]
        vi = VibeInput(
            business_id=business_id,
            origin=VibeInputOrigin.USER.value,
            author=author,
            text=f"seeded user feedback #{j + 1}",
            category=None,
            priority=VibeInputPriority.MEDIUM.value,
            confidence_score=None,
            consumed=False,
            selected_for_run=False,
            status=VibeInputStatus.ACTIVE.value,
            created_at=_now(),
            updated_at=_now(),
        )
        session.add(vi)
        session.flush()
        result.user_input_ids.append(vi.id)
        result.link_ids.append(_add_link(session, vi.id, version_id, anchor))

    if commit:
        session.commit()
    return result


def _resolve_head_version(session: Session, business_id: str) -> Optional[str]:
    mv = session.exec(
        select(ModelVersion)
        .where(
            ModelVersion.business_id == business_id,
            ModelVersion.status == "completed",
        )
        .order_by(ModelVersion.created_at.desc())
    ).first()
    return mv.id if mv is not None else None


def _build_engine():
    """Build an engine against the dev/prod Lakebase, reusing the app's engine
    builder so the standalone path doesn't drift from production config."""
    from databricks.sdk import WorkspaceClient

    from vibe_modeling.backend.core.lakebase import (
        DatabaseConfig,
        create_db_engine,
    )

    return create_db_engine(DatabaseConfig(), WorkspaceClient())


def main(argv: Optional[list[str]] = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--business-id", required=True)
    parser.add_argument(
        "--version-id",
        default=None,
        help="defaults to the business's latest completed version",
    )
    parser.add_argument("--agent", type=int, default=8, help="agent inputs")
    parser.add_argument("--user", type=int, default=4, help="user inputs")
    parser.add_argument(
        "--quality-score",
        type=float,
        default=0.76,
        help="0..1 fraction stamped on agent inputs' confidence_score",
    )
    args = parser.parse_args(argv)

    engine = _build_engine()
    with Session(engine) as session:
        version_id = args.version_id or _resolve_head_version(
            session, args.business_id
        )
        if version_id is None:
            print(
                "No version-id given and no completed version for business "
                f"{args.business_id!r}.",
                file=sys.stderr,
            )
            return 1
        result = seed_vibe_inputs(
            session,
            args.business_id,
            version_id,
            n_agent=args.agent,
            n_user=args.user,
            quality_score=args.quality_score,
        )
    print(
        f"Seeded {len(result.agent_input_ids)} agent + "
        f"{len(result.user_input_ids)} user inputs on version {version_id}. "
        f"Categories: {result.category_counts}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
