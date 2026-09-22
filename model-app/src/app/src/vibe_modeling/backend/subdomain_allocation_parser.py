"""Parser for the agent's ``Subdomain Allocation`` ``stage_succeeded`` event.

Background
----------
Agent v0.7.x runs a per-domain LLM call that groups every product into a
subdomain bucket. The agent emits a single ``stage_succeeded`` event when
the allocation completes:

    _vw_orch.emit_step(
        stage_name="Subdomain Allocation",
        step_name="Allocate Subdomains",         # also seen as "Allocating Subdomains"
        status="stage_succeeded",
        progress_increment=1.0,
        message=f"Allocated to {unique} unique subdomains",
        result_json={
            "unique_subdomains": 34,
            "subdomains_by_domain": {
                "<domain_name>": {
                    "<subdomain_name>": ["<product_name>", ...],
                    ...
                },
                ...
            },
        },
    )

The agent additionally writes the same subdomain assignments into
``model.json`` per Product, so ``ModelSyncService`` already populates
``Product.subdomain`` at observe-time. This parser is the in-flight
backfill path: when the App fails to sync model.json (volume read error,
job-API failure, etc.) the parsed event remains the authoritative source
of subdomain assignments and can recover them by re-applying to the
matching ``Product`` rows.

Contract
--------
Predicate (BOTH must hold):

* Primary: ``stage_name == "Subdomain Allocation"`` AND
  ``status == "stage_succeeded"``.
* Hardening: ``result_json`` contains ``subdomains_by_domain`` and it
  is a non-empty dict.

When fired, the parser walks ``subdomains_by_domain`` as
``(domain_name → subdomain_name → [product_name, ...])`` and stamps
``Product.subdomain = <subdomain_name>`` on every matching Product row
(joined by ``Domain.name`` + ``Product.name`` against the run's
``ModelVersion``).

Storage
-------
No new Lakebase column. ``Product.subdomain`` already exists; the unique
subdomain count is derived at read-time via
``COUNT(DISTINCT Product.subdomain WHERE != '')``. This preserves the
existing migration-gating constraint (see
``feedback_lakebase_branching_mandatory``).

Atomicity
---------
The handler runs inside the caller's open ``Session`` and never commits
on its own — the caller's per-tick ``session.commit`` owns the
transaction (same pattern as ``version_resolution_parser``).

Guardrails
----------
Malformed ``result_json`` (missing key, wrong types, products not in the
DB) is logged as a warning and skipped — data quality is the agent's
responsibility, not ours. We never fail the run on a subdomain mismatch.
Re-firing is idempotent (we set the same string).
"""

from __future__ import annotations

import logging
from typing import TYPE_CHECKING, Optional

from sqlmodel import Session, select

from .db_models import Domain, ModelVersion, Product, Run, RunOperation

if TYPE_CHECKING:
    from .progress_tracker import ProgressEvent

logger = logging.getLogger(__name__)


STAGE_NAME = "Subdomain Allocation"
STATUS_NAME = "stage_succeeded"


def is_subdomain_allocation_event(
    stage_name: str,
    status: str,
    result_json: Optional[dict],
) -> bool:
    """Return True iff the event matches the canonical contract.

    Predicate matches the stage_succeeded terminal of the Subdomain
    Allocation stage with a populated ``subdomains_by_domain`` mapping.
    The agent uses ``step_name`` interchangeably as "Allocate Subdomains"
    or "Allocating Subdomains" across v0.7.0 / v0.7.1; we ignore the
    step name and key on (stage + status + payload shape).
    """
    if stage_name != STAGE_NAME or status != STATUS_NAME:
        return False
    if not isinstance(result_json, dict):
        return False
    sbd = result_json.get("subdomains_by_domain")
    if not isinstance(sbd, dict) or not sbd:
        return False
    return True


def apply_subdomain_allocation(
    session: Session,
    run: Run,
    ev: "ProgressEvent",
) -> None:
    """Persist subdomain assignments from the event onto Product rows.

    Looks up the in-flight ``ModelVersion`` for this run (preferring
    ``RunOperation.output_version_id``, falling back to ``Run.version_id``);
    if no MV row exists yet, the assignments will be picked up at
    observe-time via ``ModelSyncService`` (model.json carries the same
    data per Product). Re-firing after the MV row appears is idempotent.
    """
    rj = ev.result_json or {}
    sbd = rj.get("subdomains_by_domain")
    if not isinstance(sbd, dict) or not sbd:
        logger.warning(
            "subdomain_allocation: malformed result_json on run %s: %r",
            run.id, rj,
        )
        return

    mv = _lookup_run_mv(session, run)
    if mv is None:
        # MV row not yet created — model_sync will hydrate Product.subdomain
        # from model.json on success. Nothing to backfill here yet.
        logger.info(
            "subdomain_allocation: run %s deferred — MV row not yet "
            "created; assignments will be applied by ModelSyncService",
            run.id,
        )
        return

    # Build a (domain_name → product_name → subdomain_name) lookup from the
    # event payload so we can stamp each matching Product row in one pass.
    product_subdomain: dict[tuple[str, str], str] = {}
    for domain_name, subdomain_map in sbd.items():
        if not isinstance(subdomain_map, dict):
            logger.warning(
                "subdomain_allocation: domain %r has non-dict allocation %r — skipping",
                domain_name, subdomain_map,
            )
            continue
        for subdomain_name, products in subdomain_map.items():
            if not isinstance(products, list):
                logger.warning(
                    "subdomain_allocation: domain=%r subdomain=%r expected list, got %r",
                    domain_name, subdomain_name, type(products).__name__,
                )
                continue
            for product_name in products:
                if not isinstance(product_name, str) or not product_name:
                    continue
                product_subdomain[(domain_name, product_name)] = subdomain_name

    if not product_subdomain:
        logger.warning(
            "subdomain_allocation: run %s — payload yielded zero (domain, product) entries",
            run.id,
        )
        return

    # Fetch all Domain + Product rows for this MV in two queries (avoid
    # an N+1 join). The (domain_name, product_name) join key matches the
    # agent's emit shape.
    domains = session.exec(
        select(Domain).where(Domain.version_id == mv.id)
    ).all()
    if not domains:
        logger.info(
            "subdomain_allocation: run %s mv=%s has no Domain rows yet — "
            "deferring to ModelSyncService",
            run.id, mv.id,
        )
        return

    domain_id_to_name = {d.id: d.name for d in domains}
    products = session.exec(
        select(Product).where(Product.version_id == mv.id)
    ).all()

    updated = 0
    unmatched_payload = 0
    for p in products:
        dname = domain_id_to_name.get(p.domain_id, "")
        target = product_subdomain.get((dname, p.name))
        if target is None:
            continue
        if p.subdomain != target:
            p.subdomain = target
            session.add(p)
            updated += 1

    # Track payload entries that didn't match any Product (informational).
    db_keys = {(domain_id_to_name.get(p.domain_id, ""), p.name) for p in products}
    for key in product_subdomain.keys():
        if key not in db_keys:
            unmatched_payload += 1

    logger.info(
        "subdomain_allocation: run %s mv=%s applied — %d products updated "
        "(%d payload entries had no matching Product row)",
        run.id, mv.id, updated, unmatched_payload,
    )


# --- internals -----------------------------------------------------------


def _lookup_run_mv(session: Session, run: Run) -> Optional[ModelVersion]:
    """Find the in-flight ModelVersion for this run.

    Prefer the running op's ``output_version_id`` (orchestrator-set on
    success). Fall back to ``Run.version_id`` (legacy). Either of the
    two paths suffices — we don't need to disambiguate by scope here
    because Product.subdomain is scope-agnostic at the row level.
    """
    rops = session.exec(
        select(RunOperation)
        .where(RunOperation.run_id == run.id)
        .where(RunOperation.output_version_id != None)  # noqa: E711
    ).all()
    for op in rops:
        mv = session.get(ModelVersion, op.output_version_id)
        if mv is not None:
            return mv
    if run.version_id:
        return session.get(ModelVersion, run.version_id)
    return None


__all__ = [
    "STAGE_NAME",
    "STATUS_NAME",
    "is_subdomain_allocation_event",
    "apply_subdomain_allocation",
]
