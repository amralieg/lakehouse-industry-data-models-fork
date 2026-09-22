"""Element rename/merge/delete lineage resolution (the model-versioning work Task 4).

When ``model_sync`` syncs version W of a model, this module:

1. Reads the agent's rename / consolidation / removal signals out of the
   durable ``RunProgressEvent`` rows already mirrored for the run (the poll
   loop is the single canonical reader of ``_vibe_progress``; we do NOT add a
   second Delta reader — see the design doc §1).
2. Resolves each version-W element to its prior-version (version V =
   ``base_version_id``) counterpart through ordered tiers
   (exact FQN → rename pointer → merge survivor → genuine new) and sets the
   ``previous_element_id`` self-FK for the 1:1 cases.
3. Writes ``RunElementLineage`` edge rows for the facts a single self-FK
   cannot express: merges (N:1) and deletes (1:0), plus cheap rename audit
   rows.
4. Upserts ``Subdomain`` rows from ``Product.subdomain`` (sync-time forward
   path) and links each Product's ``subdomain_id`` + the subdomain's own
   prior-version pointer.

Name comparison uses the same agent normalization rule as the rest of the
backend (``core._names.agent_business_segment``) so a rename caught at the
agent layer matches our prior-version index.
"""

from __future__ import annotations

import logging
import uuid
from typing import Optional

from sqlmodel import Session, select

from .core._names import agent_business_segment as _norm
from .db_models import (
    Attribute,
    Domain,
    ForeignKeyLink,
    ModelVersion,
    Product,
    RunElementLineage,
    RunProgressEvent,
    Subdomain,
)

logger = logging.getLogger(__name__)

# Stable namespace for the subdomain natural key. Task 3's historical backfill
# and this sync-time forward path MUST derive the same id from the same
# ``(version_id, domain_id, name)`` tuple so they converge and never
# double-create. uuid5 over a fixed namespace is the convergent key.
SD_NS = uuid.UUID("5b8f2c7a-1d3e-4a6b-9c2f-7e1a4d6b8c30")


def subdomain_id(version_id: str, domain_id: str, name: str) -> str:
    """Deterministic id for a ``(version, domain, name)`` subdomain."""
    return str(uuid.uuid5(SD_NS, f"{version_id}|{domain_id}|{_norm(name)}"))


# --------------------------------------------------------------------------
# Signal reading
# --------------------------------------------------------------------------


class _Signals:
    """Normalized rename / merge / deletion signals for a run.

    All name keys are normalized via :func:`_norm` so they match the
    prior-version index.
    """

    def __init__(self) -> None:
        # (domain_norm, old_name_norm) -> (new_name_norm, reason)
        self.product_renames: dict[tuple[str, str], tuple[str, str]] = {}
        # (old_pk_norm under (domain,new_product)) carried for attr tier 2:
        # (domain_norm, new_product_norm) -> (old_pk_norm, new_pk_norm)
        self.pk_renames: dict[tuple[str, str], tuple[str, str]] = {}
        # old_domain_norm -> new_domain_norm
        self.domain_renames: dict[str, str] = {}
        # (domain_norm, merged_old_norm) -> (survivor_new_norm, reason)
        self.product_merges: dict[tuple[str, str], tuple[str, str]] = {}
        # explicit product removals: set of (domain_norm, product_norm)
        self.products_removed: set[tuple[str, str]] = set()
        # explicit domain removals: set of domain_norm
        self.domains_removed: set[str] = set()


def _as_list(val) -> list:
    return val if isinstance(val, list) else []


def read_signals(session: Session, run_id: str) -> _Signals:
    """Union the rename/merge/removal signals across all of a run's events.

    Tolerant by design (design doc flag A): unknown shapes are skipped, never
    raised. The agent emits the same logical signal at more than one stage
    (architect review in stage 5, QA in stage 8); we union across all.
    """
    sig = _Signals()
    events = session.exec(
        select(RunProgressEvent).where(RunProgressEvent.run_id == run_id)
    ).all()
    for ev in events:
        try:
            rj = ev.result_json
            data = rj if isinstance(rj, dict) else _loads(rj)
        except Exception:
            continue
        if not isinstance(data, dict):
            continue
        _absorb_rename_log(sig, data.get("rename_log"))
        _absorb_rename_log(sig, data.get("duplicate_rename_log"))
        _absorb_rename_log(sig, data.get("renames_applied"))
        _absorb_consolidation(sig, data.get("consolidation_log"))
        _absorb_architect_review(sig, data.get("architect_review_changes"))
        _absorb_products_removed(sig, data.get("products_removed"))
        _absorb_domains_removed(sig, data.get("domains_removed"))
    return sig


def _loads(raw) -> dict:
    import json
    if not raw:
        return {}
    return json.loads(raw)


def _absorb_rename_log(sig: _Signals, entries) -> None:
    for e in _as_list(entries):
        if not isinstance(e, dict):
            continue
        dom = _norm(e.get("domain", ""))
        old = _norm(e.get("old_name", ""))
        new = _norm(e.get("new_name", ""))
        if not old or not new:
            continue
        sig.product_renames[(dom, old)] = (new, e.get("reason", "") or "")
        old_pk = _norm(e.get("old_pk", ""))
        new_pk = _norm(e.get("new_pk", ""))
        if old_pk and new_pk:
            sig.pk_renames[(dom, new)] = (old_pk, new_pk)


def _absorb_consolidation(sig: _Signals, entries) -> None:
    for e in _as_list(entries):
        if not isinstance(e, dict):
            continue
        dom = _norm(e.get("domain", ""))
        survivor = _norm(e.get("new_name") or e.get("survivor") or "")
        if not survivor:
            continue
        reason = e.get("reason", "") or "consolidation"
        merged = e.get("merged_from") or e.get("merged") or e.get("old_names") or []
        for m in _as_list(merged):
            old = _norm(m if isinstance(m, str) else m.get("name", "")) if m else ""
            if old:
                sig.product_merges[(dom, old)] = (survivor, reason)


def _absorb_architect_review(sig: _Signals, arc) -> None:
    if not isinstance(arc, dict):
        return
    for e in _as_list(arc.get("products_renamed")):
        if not isinstance(e, dict):
            continue
        dom = _norm(e.get("domain", ""))
        old = _norm(e.get("old") or e.get("old_name") or "")
        new = _norm(e.get("new") or e.get("new_name") or "")
        if old and new:
            sig.product_renames[(dom, old)] = (new, "architect_review")
    for e in _as_list(arc.get("domains_renamed")):
        if not isinstance(e, dict):
            continue
        old = _norm(e.get("old") or e.get("old_name") or "")
        new = _norm(e.get("new") or e.get("new_name") or "")
        if old and new:
            sig.domain_renames[old] = new
    _absorb_products_removed(sig, arc.get("products_removed"))
    _absorb_domains_removed(sig, arc.get("domains_removed"))


def _absorb_products_removed(sig: _Signals, removed) -> None:
    for e in _as_list(removed):
        if isinstance(e, str) and "." in e:
            dom, _, prod = e.partition(".")
            sig.products_removed.add((_norm(dom), _norm(prod)))
        elif isinstance(e, dict):
            dom = _norm(e.get("domain", ""))
            for p in _as_list(e.get("products")):
                if isinstance(p, str):
                    sig.products_removed.add((dom, _norm(p)))


def _absorb_domains_removed(sig: _Signals, removed) -> None:
    for e in _as_list(removed):
        if isinstance(e, str):
            sig.domains_removed.add(_norm(e))
        elif isinstance(e, dict) and e.get("domain"):
            sig.domains_removed.add(_norm(e["domain"]))


# --------------------------------------------------------------------------
# Indexing
# --------------------------------------------------------------------------


def _index_domains(session: Session, version_id: str) -> dict[str, Domain]:
    rows = session.exec(select(Domain).where(Domain.version_id == version_id)).all()
    return {_norm(d.name): d for d in rows}


def _index_products(
    session: Session, version_id: str, domains: dict[str, Domain],
) -> dict[tuple[str, str], Product]:
    id_to_norm = {d.id: dn for dn, d in domains.items()}
    rows = session.exec(select(Product).where(Product.version_id == version_id)).all()
    out: dict[tuple[str, str], Product] = {}
    for p in rows:
        dn = id_to_norm.get(p.domain_id)
        if dn is not None:
            out[(dn, _norm(p.name))] = p
    return out


def _index_attributes(
    session: Session, products: dict[tuple[str, str], Product],
) -> dict[tuple[str, str, str], Attribute]:
    out: dict[tuple[str, str, str], Attribute] = {}
    pid_to_key = {p.id: key for key, p in products.items()}
    if not products:
        return out
    rows = session.exec(
        select(Attribute).where(Attribute.product_id.in_([p.id for p in products.values()]))
    ).all()
    for a in rows:
        key = pid_to_key.get(a.product_id)
        if key is not None:
            out[(key[0], key[1], _norm(a.name))] = a
    return out


def _index_fks(session: Session, version_id: str) -> dict[tuple, ForeignKeyLink]:
    rows = session.exec(
        select(ForeignKeyLink).where(ForeignKeyLink.version_id == version_id)
    ).all()
    out: dict[tuple, ForeignKeyLink] = {}
    for fk in rows:
        out[(
            _norm(fk.source_domain), _norm(fk.source_product), _norm(fk.source_column),
            _norm(fk.target_domain), _norm(fk.target_product), _norm(fk.target_column),
        )] = fk
    return out


# --------------------------------------------------------------------------
# The pass
# --------------------------------------------------------------------------


def link_previous_version(
    session: Session,
    version_id: str,
    run_id: str,
) -> None:
    """Set ``previous_element_id`` pointers + write ``RunElementLineage`` rows.

    Parent-first: domains → products → attributes → FKs. Each level uses its
    parent's already-resolved mapping so a renamed domain re-roots its
    children. Idempotent: existing lineage rows for the version are cleared
    first and pointers recomputed from scratch. (Subdomains are upserted
    separately by the caller on every sync — see ``upsert_subdomains``.)
    """
    mv = session.get(ModelVersion, version_id)
    if mv is None:
        return

    # Idempotent re-sync: clear prior lineage rows for this version.
    for row in session.exec(
        select(RunElementLineage).where(RunElementLineage.version_id == version_id)
    ).all():
        session.delete(row)
    session.flush()

    # Subdomains are structural, not lineage-dependent, so their upsert is
    # driven by the caller (sync_from_model_json) on EVERY sync — including the
    # no-run_id force-resync path — not from this run_id-gated lineage pass.

    if mv.base_version_id is None:
        # Base run: no prior version, no lineage.
        return

    prior_id = mv.base_version_id
    new_domains = _index_domains(session, version_id)
    prior_domains = _index_domains(session, prior_id)

    # If the prior version was never synced (zero element rows), we cannot
    # distinguish "deleted" from "never synced" — suppress the delete
    # backstop entirely and leave all pointers NULL.
    prior_synced = bool(prior_domains)

    sig = read_signals(session, run_id)

    # ---- Domains ----
    dom_old_to_new: dict[str, str] = {}  # prior domain_norm -> new domain_norm
    for dn, dom in new_domains.items():
        prior = prior_domains.get(dn)
        if prior is None:
            # rename pointer: this domain was renamed FROM some old name.
            old = _rename_source(sig.domain_renames, dn)
            if old and old in prior_domains:
                prior = prior_domains[old]
        if prior is not None:
            dom.previous_element_id = prior.id
            session.add(dom)
            dom_old_to_new[_norm(prior.name)] = dn

    # ---- Products ----
    new_products = _index_products(session, version_id, new_domains)
    prior_products = _index_products(session, prior_id, prior_domains)
    prod_prior_resolved: dict[tuple[str, str], Product] = {}
    # Prior products consumed as a rename/merge source — excluded from the
    # delete backstop even if their FQN is absent from W.
    consumed_prior_ids: set[str] = set()
    for (dn, pn), prod in new_products.items():
        # tier 1: exact FQN; tier 2: rename pointer (survivor's own self for a
        # merge is found by exact/rename too — the merge rows are written in a
        # separate pass below so they fire regardless of how the survivor's own
        # 1:1 lineage resolves).
        prior = prior_products.get((dn, pn))
        kind = None
        reason = ""
        if prior is None:
            old = _rename_source_in_domain(sig.product_renames, dn, pn)
            if old:
                prior = _lookup_prior_product(prior_products, dom_old_to_new, dn, old)
                if prior is not None:
                    kind, reason = "rename", sig.product_renames[(dn, old)][1]
        if prior is not None:
            prod.previous_element_id = prior.id
            session.add(prod)
            prod_prior_resolved[(dn, pn)] = prior
            consumed_prior_ids.add(prior.id)
            if kind == "rename":
                _add_lineage(session, run_id, version_id, "product", "rename",
                             prior.id, prod.id, _fqn(prior_products, prior),
                             f"{dn}.{pn}", reason)

    # Merge rows (N:1): for each surviving product that is the named survivor of
    # a consolidation, record every merged-away prior id → survivor new id.
    for (dn, pn), prod in new_products.items():
        for (mdom, mold), mreason in _merges_into(sig.product_merges, dn, pn):
            merged_prior = _lookup_prior_product(prior_products, dom_old_to_new, mdom, mold)
            if merged_prior is None or merged_prior.id == prod.previous_element_id:
                continue
            consumed_prior_ids.add(merged_prior.id)
            _add_lineage(session, run_id, version_id, "product", "merge",
                         merged_prior.id, prod.id,
                         _fqn(prior_products, merged_prior), f"{dn}.{pn}", mreason)

    # ---- Attributes ----
    new_attrs = _index_attributes(session, new_products)
    prior_attrs = _index_attributes(session, prior_products)
    for (dn, pn, an), attr in new_attrs.items():
        prior_prod = prod_prior_resolved.get((dn, pn))
        if prior_prod is None:
            continue
        pdn, ppn = _key_for_product(prior_products, prior_prod)
        prior = prior_attrs.get((pdn, ppn, an))
        if prior is None:
            # tier 2: PK rename — old_pk -> new_pk on the renamed entry.
            pk = sig.pk_renames.get((dn, pn))
            if pk and pk[1] == an:
                prior = prior_attrs.get((pdn, ppn, pk[0]))
        if prior is not None:
            attr.previous_element_id = prior.id
            session.add(attr)

    # ---- FKs ----
    new_fks = _index_fks(session, version_id)
    prior_fks = _index_fks(session, prior_id)
    for key, fk in new_fks.items():
        prior = prior_fks.get(key)
        if prior is not None:
            fk.previous_element_id = prior.id
            session.add(fk)

    # ---- Deletions (set-difference backstop + explicit) ----
    if prior_synced:
        _record_deletions(
            session, run_id, version_id, sig,
            prior_domains, new_domains, dom_old_to_new,
            prior_products, new_products, consumed_prior_ids,
        )

    session.flush()


def upsert_subdomains(
    session: Session, version_id: str, prior_version_id: Optional[str],
) -> None:
    """Create one Subdomain per distinct ``(domain, Product.subdomain)`` and
    set each Product.subdomain_id + the subdomain's prior-version pointer.

    Natural key = ``(version_id, domain_id, name)`` via :func:`subdomain_id`
    so this converges with Task 3's historical backfill.
    """
    domains = session.exec(select(Domain).where(Domain.version_id == version_id)).all()
    dom_by_id = {d.id: d for d in domains}
    products = session.exec(select(Product).where(Product.version_id == version_id)).all()

    prior_by_name: dict[tuple[str, str], Subdomain] = {}
    if prior_version_id:
        for sd in session.exec(
            select(Subdomain).where(Subdomain.version_id == prior_version_id)
        ).all():
            pdom = session.get(Domain, sd.domain_id)
            pdom_name = _norm(pdom.name) if pdom else ""
            prior_by_name[(pdom_name, _norm(sd.name))] = sd

    # Two-pass, parent-before-child: materialise every referenced Subdomain
    # (and flush the INSERTs) before assigning any product.subdomain_id. A
    # single interleaved pass lets autoflush emit a product UPDATE ahead of its
    # subdomain INSERT, violating products_subdomain_id_fkey and aborting the
    # whole sync transaction.
    seen: dict[str, Subdomain] = {}
    product_subdomain: dict[str, str] = {}
    with session.no_autoflush:
        for p in products:
            name = (p.subdomain or "").strip()
            if not name:
                continue
            dom = dom_by_id.get(p.domain_id)
            if dom is None:
                continue
            sid = subdomain_id(version_id, p.domain_id, name)
            product_subdomain[p.id] = sid
            if sid in seen:
                continue
            sd = session.get(Subdomain, sid)
            if sd is None:
                sd = Subdomain(id=sid, version_id=version_id, domain_id=p.domain_id, name=name)
                prior = prior_by_name.get((_norm(dom.name), _norm(name)))
                if prior is not None:
                    sd.previous_element_id = prior.id
                session.add(sd)
            seen[sid] = sd
    session.flush()  # subdomain INSERTs land before any product FK references them

    for p in products:
        sid = product_subdomain.get(p.id)
        if sid is None:
            continue
        p.subdomain_id = sid
        session.add(p)
    session.flush()


# --------------------------------------------------------------------------
# helpers
# --------------------------------------------------------------------------


def _rename_source(rename_map: dict[str, str], new_name: str) -> Optional[str]:
    for old, new in rename_map.items():
        if new == new_name:
            return old
    return None


def _rename_source_in_domain(
    rename_map: dict[tuple[str, str], tuple[str, str]], dn: str, pn: str,
) -> Optional[str]:
    for (rdom, old), (new, _reason) in rename_map.items():
        if rdom == dn and new == pn:
            return old
    return None


def _merges_into(
    merge_map: dict[tuple[str, str], tuple[str, str]], dn: str, survivor: str,
) -> list[tuple[tuple[str, str], str]]:
    out: list[tuple[tuple[str, str], str]] = []
    for (mdom, mold), (surv, reason) in merge_map.items():
        if surv == survivor:
            out.append(((mdom, mold), reason))
    return out


def _lookup_prior_product(
    prior_products: dict[tuple[str, str], Product],
    dom_old_to_new: dict[str, str],
    domain_norm: str,
    product_norm: str,
) -> Optional[Product]:
    # Prior products are keyed by their OWN (prior) domain name. The new
    # domain may have been renamed; map back if needed.
    if (domain_norm, product_norm) in prior_products:
        return prior_products[(domain_norm, product_norm)]
    for prior_dom, new_dom in dom_old_to_new.items():
        if new_dom == domain_norm and (prior_dom, product_norm) in prior_products:
            return prior_products[(prior_dom, product_norm)]
    return None


def _key_for_product(
    prior_products: dict[tuple[str, str], Product], prod: Product,
) -> tuple[str, str]:
    for key, p in prior_products.items():
        if p.id == prod.id:
            return key
    return ("", _norm(prod.name))


def _fqn(prior_products: dict[tuple[str, str], Product], prod: Product) -> str:
    """The normalized "<domain>.<product>" storage FQN for a lineage edge.

    This is the single FQN builder for the lineage-storage boundary (the
    ``RunElementLineage.old_fqn``/``new_fqn`` columns). Distinct from the
    read/display FQN at the explorer serialization boundary because the parts
    here are already ``_norm``-normalized physical segments."""
    key = _key_for_product(prior_products, prod)
    return ".".join(key)


def _add_lineage(
    session: Session, run_id: str, version_id: str, element_type: str,
    change_kind: str, old_id: Optional[str], new_id: Optional[str],
    old_fqn: str, new_fqn: str, reason: str,
) -> None:
    session.add(RunElementLineage(
        run_id=run_id,
        version_id=version_id,
        element_type=element_type,
        change_kind=change_kind,
        old_element_id=old_id,
        new_element_id=new_id,
        old_fqn=old_fqn,
        new_fqn=new_fqn,
        reason=reason,
    ))


def _record_deletions(
    session: Session, run_id: str, version_id: str, sig: _Signals,
    prior_domains: dict[str, Domain], new_domains: dict[str, Domain],
    dom_old_to_new: dict[str, str],
    prior_products: dict[tuple[str, str], Product],
    new_products: dict[tuple[str, str], Product],
    consumed_prior_ids: set[str],
) -> None:
    """Record a delete row for every prior element with no surviving new
    counterpart (set-difference backstop, augmented by explicit signals).

    A prior row "survives" iff a version-W element resolved to it via tier 1/2
    (exact/rename) or it was recorded as a merge source — both tracked in
    ``consumed_prior_ids``. A rename whose new_name has no row in W therefore
    does NOT count as survival, so the prior row correctly falls into the
    delete set (design doc §2.4 partial-signal edge case)."""
    # Domains: a prior domain survives iff a new domain points back to it
    # (exact or rename). Note domain renames are recorded on the self-FK, so
    # the consumed check is via dom_old_to_new / new_domains.
    for dn, dom in prior_domains.items():
        survives = dn in new_domains or dn in dom_old_to_new
        if not survives:
            _add_lineage(session, run_id, version_id, "domain", "delete",
                         dom.id, None, dn, "",
                         "removed" if dn in sig.domains_removed else "set_difference")

    # Products.
    for (dn, pn), prod in prior_products.items():
        if prod.id in consumed_prior_ids:
            continue
        # Partial signal (design doc §4): the agent emitted a rename FROM this
        # prior row but the new_name has no row in W — record as a delete.
        renamed_to_absent = any(
            rdom == dn and old == pn for (rdom, old) in sig.product_renames.keys()
        )
        if renamed_to_absent:
            logger.info(
                "[lineage] run=%s rename target absent for %s.%s — recording delete",
                run_id, dn, pn,
            )
        reason = "removed" if (dn, pn) in sig.products_removed else "set_difference"
        _add_lineage(session, run_id, version_id, "product", "delete",
                     prod.id, None, f"{dn}.{pn}", "", reason)
