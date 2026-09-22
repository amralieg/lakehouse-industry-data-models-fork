"""Task 4 — model_sync rename/delete/merge lineage capture.

Unit tests with a mocked session (in-memory SQLite). Prior + new versions are
built via the real ``sync_from_model_json`` path; rename/merge/delete signals
are seeded as synthetic ``RunProgressEvent`` rows on the session, exactly as
the poll loop would have mirrored them from the agent's ``_vibe_progress``.

The lineage pass (``ModelSyncService._link_previous_version``) runs at the end
of ``sync_from_model_json`` when a ``run_id`` is threaded; with no ``run_id``
(imports / dev fixtures / base runs) it is a no-op.
"""

from __future__ import annotations

import json
import os
import sys

import pytest
from sqlmodel import Session, select

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from vibe_modeling.backend.db_models import (  # noqa: E402
    Attribute,
    Business,
    Domain,
    ModelVersion,
    Product,
    Run,
    RunElementLineage,
    RunProgressEvent,
    Subdomain,
)
from vibe_modeling.backend.model_sync import ModelSyncService  # noqa: E402


# --------------------------------------------------------------------------
# Fixtures / helpers
# --------------------------------------------------------------------------


@pytest.fixture(name="session")
def session_fixture(engine):
    with Session(engine) as session:
        yield session


def _make_business(session: Session) -> Business:
    biz = Business(name="acme")
    session.add(biz)
    session.flush()
    return biz


def _make_version(
    session: Session, business_id: str, version: int, scope: str = "ecm",
    base_version_id: str | None = None,
) -> ModelVersion:
    mv = ModelVersion(
        business_id=business_id,
        version=version,
        scope=scope,
        base_version_id=base_version_id,
    )
    session.add(mv)
    session.flush()
    return mv


def _make_run(session: Session, business_id: str, version_id: str) -> Run:
    run = Run(business_id=business_id, version_id=version_id, intent="vibe", status="running")
    session.add(run)
    session.flush()
    return run


def _seed_event(
    session: Session, run_id: str, stage: str, step: str, status: str,
    result: dict, event_seq: int = 1,
) -> None:
    session.add(RunProgressEvent(
        run_id=run_id,
        step_id=event_seq,
        event_seq=event_seq,
        stage_name=stage,
        step_name=step,
        status=status,
        result_json=json.dumps(result),
    ))
    session.flush()


def _model(domains: list[dict]) -> dict:
    return {"domains": domains}


def _domain(name: str, products: list[dict], **kw) -> dict:
    return {"name": name, "products": products, **kw}


def _product(name: str, primary_key: str = "", attributes: list[dict] | None = None,
             subdomain: str = "", **kw) -> dict:
    return {
        "product": name,
        "primary_key": primary_key,
        "subdomain": subdomain,
        "attributes": attributes or [],
        **kw,
    }


def _attr(name: str, foreign_key_to: str = "", **kw) -> dict:
    return {"attribute": name, "foreign_key_to": foreign_key_to, **kw}


def _svc(session: Session) -> ModelSyncService:
    return ModelSyncService(session)


def _domains_for(session: Session, version_id: str) -> dict[str, Domain]:
    rows = session.exec(select(Domain).where(Domain.version_id == version_id)).all()
    return {d.name: d for d in rows}


def _products_for(session: Session, version_id: str) -> dict[tuple[str, str], Product]:
    rows = session.exec(select(Product).where(Product.version_id == version_id)).all()
    out: dict[tuple[str, str], Product] = {}
    for p in rows:
        dom = session.get(Domain, p.domain_id)
        out[(dom.name, p.name)] = p
    return out


def _lineage_for(session: Session, version_id: str) -> list[RunElementLineage]:
    return list(session.exec(
        select(RunElementLineage).where(RunElementLineage.version_id == version_id)
    ).all())


# --------------------------------------------------------------------------
# Test 2 (tracer): exact FQN match → previous_element_id set, NO lineage row
# --------------------------------------------------------------------------


def test_exact_match_sets_pointer_no_lineage_row(session):
    biz = _make_business(session)
    prior = _make_version(session, biz.id, 1)
    new = _make_version(session, biz.id, 2, base_version_id=prior.id)
    run = _make_run(session, biz.id, new.id)

    model = _model([_domain("party", [_product("individual")])])
    svc = _svc(session)
    svc.sync_from_model_json(prior.id, model)
    svc.sync_from_model_json(new.id, model, run_id=run.id)

    prior_p = _products_for(session, prior.id)[("party", "individual")]
    new_p = _products_for(session, new.id)[("party", "individual")]
    assert new_p.previous_element_id == prior_p.id
    # Domain also links.
    assert _domains_for(session, new.id)["party"].previous_element_id == \
        _domains_for(session, prior.id)["party"].id
    # 1:1 lives only on the self-FK — no lineage row.
    assert _lineage_for(session, new.id) == []


# --------------------------------------------------------------------------
# Test 1: rename → pointer set + rename lineage row (+ PK attr links)
# --------------------------------------------------------------------------


def test_rename_sets_pointer_and_audit_row(session):
    biz = _make_business(session)
    prior = _make_version(session, biz.id, 1)
    new = _make_version(session, biz.id, 2, base_version_id=prior.id)
    run = _make_run(session, biz.id, new.id)

    prior_model = _model([_domain("billing", [
        _product("account", primary_key="account_id",
                 attributes=[_attr("account_id")]),
    ])])
    new_model = _model([_domain("billing", [
        _product("billing_account", primary_key="billing_account_id",
                 attributes=[_attr("billing_account_id")]),
    ])])
    svc = _svc(session)
    svc.sync_from_model_json(prior.id, prior_model)
    _seed_event(session, run.id, "QA", "Auto-Remediation Complete", "ok", {
        "rename_log": [{
            "domain": "billing", "old_name": "account", "new_name": "billing_account",
            "old_pk": "account_id", "new_pk": "billing_account_id", "reason": "qa",
        }],
    })
    svc.sync_from_model_json(new.id, new_model, run_id=run.id)

    prior_p = _products_for(session, prior.id)[("billing", "account")]
    new_p = _products_for(session, new.id)[("billing", "billing_account")]
    assert new_p.previous_element_id == prior_p.id

    rows = _lineage_for(session, new.id)
    rename_rows = [r for r in rows if r.change_kind == "rename"]
    assert len(rename_rows) == 1
    assert rename_rows[0].old_element_id == prior_p.id
    assert rename_rows[0].new_element_id == new_p.id
    # No false delete.
    assert [r for r in rows if r.change_kind == "delete"] == []

    # Renamed PK attribute links (old_pk → new_pk).
    new_attr = next(
        a for a in session.exec(select(Attribute).where(Attribute.product_id == new_p.id)).all()
    )
    assert new_attr.previous_element_id is not None


# --------------------------------------------------------------------------
# Test 6: base run → all NULL, zero lineage rows
# --------------------------------------------------------------------------


def test_base_run_all_null_no_rows(session):
    biz = _make_business(session)
    base = _make_version(session, biz.id, 1)  # base_version_id=None
    run = _make_run(session, biz.id, base.id)
    model = _model([_domain("party", [_product("individual")])])
    _svc(session).sync_from_model_json(base.id, model, run_id=run.id)

    for p in _products_for(session, base.id).values():
        assert p.previous_element_id is None
    for d in _domains_for(session, base.id).values():
        assert d.previous_element_id is None
    assert _lineage_for(session, base.id) == []


# --------------------------------------------------------------------------
# Test 7: no run_id → no-op
# --------------------------------------------------------------------------


def test_no_run_id_is_noop(session):
    biz = _make_business(session)
    prior = _make_version(session, biz.id, 1)
    new = _make_version(session, biz.id, 2, base_version_id=prior.id)
    model = _model([_domain("party", [_product("individual")])])
    svc = _svc(session)
    svc.sync_from_model_json(prior.id, model)
    svc.sync_from_model_json(new.id, model)  # no run_id

    for p in _products_for(session, new.id).values():
        assert p.previous_element_id is None
    assert _lineage_for(session, new.id) == []


# --------------------------------------------------------------------------
# Test 9: genuine new element → NULL
# --------------------------------------------------------------------------


def test_genuine_new_element_null(session):
    biz = _make_business(session)
    prior = _make_version(session, biz.id, 1)
    new = _make_version(session, biz.id, 2, base_version_id=prior.id)
    run = _make_run(session, biz.id, new.id)
    prior_model = _model([_domain("party", [_product("individual")])])
    new_model = _model([
        _domain("party", [_product("individual")]),
        _domain("new", [_product("widget")]),
    ])
    svc = _svc(session)
    svc.sync_from_model_json(prior.id, prior_model)
    svc.sync_from_model_json(new.id, new_model, run_id=run.id)

    new_widget = _products_for(session, new.id)[("new", "widget")]
    assert new_widget.previous_element_id is None
    # No lineage row for the genuine new product.
    assert not any(r.new_element_id == new_widget.id for r in _lineage_for(session, new.id))


# --------------------------------------------------------------------------
# Test 3: merge → survivor pointer + N:1 merge rows
# --------------------------------------------------------------------------


def test_merge_records_n_to_one(session):
    biz = _make_business(session)
    prior = _make_version(session, biz.id, 1)
    new = _make_version(session, biz.id, 2, base_version_id=prior.id)
    run = _make_run(session, biz.id, new.id)

    prior_model = _model([
        _domain("order", [_product("channel"), _product("order_channel")]),
        _domain("partner", [_product("channel")]),
    ])
    # Survivor is order.order_channel; partner.channel + order.channel merge in.
    new_model = _model([
        _domain("order", [_product("order_channel")]),
        _domain("partner", []),
    ])
    svc = _svc(session)
    svc.sync_from_model_json(prior.id, prior_model)
    _seed_event(session, run.id, "QA", "Auto-Remediation Complete", "ok", {
        "consolidation_log": [{
            "domain": "order", "new_name": "order_channel",
            "merged_from": ["channel"], "reason": "consolidation",
        }, {
            "domain": "partner", "new_name": "order_channel",
            "merged_from": ["channel"], "reason": "consolidation",
        }],
    })
    svc.sync_from_model_json(new.id, new_model, run_id=run.id)

    survivor = _products_for(session, new.id)[("order", "order_channel")]
    prior_survivor = _products_for(session, prior.id)[("order", "order_channel")]
    assert survivor.previous_element_id == prior_survivor.id

    merge_rows = [r for r in _lineage_for(session, new.id) if r.change_kind == "merge"]
    assert len(merge_rows) == 2
    assert all(r.new_element_id == survivor.id for r in merge_rows)
    merged_old_ids = {r.old_element_id for r in merge_rows}
    assert _products_for(session, prior.id)[("order", "channel")].id in merged_old_ids
    assert _products_for(session, prior.id)[("partner", "channel")].id in merged_old_ids


# --------------------------------------------------------------------------
# Test 4: explicit delete
# --------------------------------------------------------------------------


def test_explicit_delete(session):
    biz = _make_business(session)
    prior = _make_version(session, biz.id, 1)
    new = _make_version(session, biz.id, 2, base_version_id=prior.id)
    run = _make_run(session, biz.id, new.id)
    prior_model = _model([_domain("legacy", [_product("thing"), _product("keep")])])
    new_model = _model([_domain("legacy", [_product("keep")])])
    svc = _svc(session)
    svc.sync_from_model_json(prior.id, prior_model)
    _seed_event(session, run.id, "Architect Review", "stage_succeeded", "stage_succeeded", {
        "architect_review_changes": {"products_removed": [{"domain": "legacy", "products": ["thing"]}]},
    })
    svc.sync_from_model_json(new.id, new_model, run_id=run.id)

    prior_thing = _products_for(session, prior.id)[("legacy", "thing")]
    delete_rows = [r for r in _lineage_for(session, new.id) if r.change_kind == "delete"]
    assert len(delete_rows) == 1
    assert delete_rows[0].old_element_id == prior_thing.id
    assert delete_rows[0].new_element_id is None
    assert delete_rows[0].reason == "removed"


# --------------------------------------------------------------------------
# Test 5: set-difference backstop (empty_domains_removed count-only)
# --------------------------------------------------------------------------


def test_set_difference_domain_delete(session):
    biz = _make_business(session)
    prior = _make_version(session, biz.id, 1)
    new = _make_version(session, biz.id, 2, base_version_id=prior.id)
    run = _make_run(session, biz.id, new.id)
    prior_model = _model([
        _domain("keep", [_product("p")]),
        _domain("obsolete", [_product("q")]),
    ])
    new_model = _model([_domain("keep", [_product("p")])])
    svc = _svc(session)
    svc.sync_from_model_json(prior.id, prior_model)
    # Only signal is the count — no names.
    _seed_event(session, run.id, "QA", "Empty Domain Removal", "ok", {
        "empty_domains_removed": 1, "remaining_domains": 1,
    })
    svc.sync_from_model_json(new.id, new_model, run_id=run.id)

    prior_obsolete = _domains_for(session, prior.id)["obsolete"]
    delete_rows = [r for r in _lineage_for(session, new.id)
                   if r.change_kind == "delete" and r.element_type == "domain"]
    assert any(r.old_element_id == prior_obsolete.id for r in delete_rows)


# --------------------------------------------------------------------------
# Test 8: idempotent re-sync → count-stable
# --------------------------------------------------------------------------


def test_idempotent_resync(session):
    biz = _make_business(session)
    prior = _make_version(session, biz.id, 1)
    new = _make_version(session, biz.id, 2, base_version_id=prior.id)
    run = _make_run(session, biz.id, new.id)
    prior_model = _model([_domain("billing", [_product("account")])])
    new_model = _model([_domain("billing", [_product("billing_account")])])
    svc = _svc(session)
    svc.sync_from_model_json(prior.id, prior_model)
    _seed_event(session, run.id, "QA", "Auto-Remediation Complete", "ok", {
        "rename_log": [{"domain": "billing", "old_name": "account", "new_name": "billing_account"}],
    })
    svc.sync_from_model_json(new.id, new_model, run_id=run.id)
    first_count = len(_lineage_for(session, new.id))
    first_ptr = _products_for(session, new.id)[("billing", "billing_account")].previous_element_id

    svc.sync_from_model_json(new.id, new_model, run_id=run.id)
    assert len(_lineage_for(session, new.id)) == first_count
    assert _products_for(session, new.id)[("billing", "billing_account")].previous_element_id == first_ptr


# --------------------------------------------------------------------------
# Test 10: subdomain upsert + lineage
# --------------------------------------------------------------------------


def test_subdomain_upsert_and_lineage(session):
    biz = _make_business(session)
    prior = _make_version(session, biz.id, 1)
    new = _make_version(session, biz.id, 2, base_version_id=prior.id)
    run = _make_run(session, biz.id, new.id)
    prior_run = _make_run(session, biz.id, prior.id)
    prior_model = _model([_domain("party", [_product("individual", subdomain="identity")])])
    new_model = _model([_domain("party", [
        _product("individual", subdomain="identity"),
        _product("org", subdomain="newsub"),
    ])])
    svc = _svc(session)
    svc.sync_from_model_json(prior.id, prior_model, run_id=prior_run.id)
    svc.sync_from_model_json(new.id, new_model, run_id=run.id)

    subs = session.exec(select(Subdomain).where(Subdomain.version_id == new.id)).all()
    names = {s.name for s in subs}
    assert names == {"identity", "newsub"}

    ident = next(s for s in subs if s.name == "identity")
    newsub = next(s for s in subs if s.name == "newsub")
    prior_ident = session.exec(
        select(Subdomain).where(Subdomain.version_id == prior.id)
    ).first()
    assert ident.previous_element_id == prior_ident.id
    assert newsub.previous_element_id is None

    new_indiv = _products_for(session, new.id)[("party", "individual")]
    assert new_indiv.subdomain_id == ident.id


# --------------------------------------------------------------------------
# Test 11: partial signal (rename to absent element) → delete, no crash
# --------------------------------------------------------------------------


def test_partial_rename_to_absent_element(session):
    biz = _make_business(session)
    prior = _make_version(session, biz.id, 1)
    new = _make_version(session, biz.id, 2, base_version_id=prior.id)
    run = _make_run(session, biz.id, new.id)
    prior_model = _model([_domain("billing", [_product("account"), _product("keep")])])
    # new_name is NOT present in W.
    new_model = _model([_domain("billing", [_product("keep")])])
    svc = _svc(session)
    svc.sync_from_model_json(prior.id, prior_model)
    _seed_event(session, run.id, "QA", "Auto-Remediation Complete", "ok", {
        "rename_log": [{"domain": "billing", "old_name": "account", "new_name": "ghost"}],
    })
    svc.sync_from_model_json(new.id, new_model, run_id=run.id)

    prior_account = _products_for(session, prior.id)[("billing", "account")]
    delete_rows = [r for r in _lineage_for(session, new.id) if r.change_kind == "delete"]
    assert any(r.old_element_id == prior_account.id for r in delete_rows)


# --------------------------------------------------------------------------
# Test 12: prior version unsynced → suppress mass-delete
# --------------------------------------------------------------------------


def test_prior_unsynced_suppresses_delete(session):
    biz = _make_business(session)
    prior = _make_version(session, biz.id, 1)  # never synced — zero element rows
    new = _make_version(session, biz.id, 2, base_version_id=prior.id)
    run = _make_run(session, biz.id, new.id)
    new_model = _model([_domain("party", [_product("individual")])])
    svc = _svc(session)
    svc.sync_from_model_json(new.id, new_model, run_id=run.id)

    assert _lineage_for(session, new.id) == []
    for p in _products_for(session, new.id).values():
        assert p.previous_element_id is None


# --------------------------------------------------------------------------
# Test 13: event-drain race → synchronous final drain recovers the missed
# rename (§2.0a). Control: without the drain the false delete occurs.
# --------------------------------------------------------------------------


def _setup_undrained_rename(session):
    """Prior billing.account → new billing.billing_account, but the rename_log
    event is NOT yet in RunProgressEvent (simulating an undrained terminal
    Stage-8 event)."""
    biz = _make_business(session)
    prior = _make_version(session, biz.id, 1)
    new = _make_version(session, biz.id, 2, base_version_id=prior.id)
    run = _make_run(session, biz.id, new.id)
    svc = _svc(session)
    svc.sync_from_model_json(prior.id, _model([_domain("billing", [_product("account")])]))
    return biz, prior, new, run, svc


def test_drain_recovers_missed_rename(session):
    biz, prior, new, run, svc = _setup_undrained_rename(session)

    # The drainer mirrors the late terminal events (rename_log + Session Ended)
    # — exactly what the canonical _sync_orch_progress_events would do.
    def fake_drain(run_obj, sess):
        if svc._session_ended_mirrored(run_obj.id):
            return
        _seed_event(sess, run_obj.id, "QA", "Auto-Remediation Complete", "ok", {
            "rename_log": [{"domain": "billing", "old_name": "account",
                            "new_name": "billing_account"}],
        }, event_seq=10)
        _seed_event(sess, run_obj.id, "Vibe Session", "Session Ended", "ok", {}, event_seq=11)

    svc._drain_progress_fn = fake_drain
    svc.sync_from_model_json(new.id, _model([_domain("billing", [_product("billing_account")])]),
                             run_id=run.id)

    prior_p = _products_for(session, prior.id)[("billing", "account")]
    new_p = _products_for(session, new.id)[("billing", "billing_account")]
    assert new_p.previous_element_id == prior_p.id
    rows = _lineage_for(session, new.id)
    assert any(r.change_kind == "rename" for r in rows)
    assert not any(r.change_kind == "delete" for r in rows)
    assert new_p.previous_element_id is not None


def test_control_without_drain_produces_false_delete(session):
    biz, prior, new, run, svc = _setup_undrained_rename(session)
    # No drain → the rename_log never arrives → false delete + NULL pointer.
    svc.sync_from_model_json(new.id, _model([_domain("billing", [_product("billing_account")])]),
                             run_id=run.id)

    new_p = _products_for(session, new.id)[("billing", "billing_account")]
    assert new_p.previous_element_id is None
    delete_rows = [r for r in _lineage_for(session, new.id) if r.change_kind == "delete"]
    assert len(delete_rows) == 1


# --------------------------------------------------------------------------
# Test 16: subdomain sync is FK-safe under enforcement (E-B1 regression)
# --------------------------------------------------------------------------


def test_subdomain_sync_fk_safe_under_enforcement(fk_engine):
    """A subdomain-bearing model must sync under FOREIGN KEY enforcement.

    Regression for E-B1 (0.6.6 release walkthrough, WT-Scratch new-base-model):
    _upsert_subdomains added Subdomain rows unflushed and set
    product.subdomain_id in one interleaved pass, so autoflush emitted the
    product UPDATE ahead of the subdomain INSERT and violated
    products_subdomain_id_fkey (added by migration v_0_6_6), aborting the whole
    sync. The two-pass fix flushes subdomains parent-first. The default
    ``session`` fixture does not enforce FKs, so this uses ``fk_engine``.
    """
    with Session(fk_engine) as s:
        biz = _make_business(s)
        v = _make_version(s, biz.id, 1)
        run = _make_run(s, biz.id, v.id)
        model = _model([
            _domain("sales", [
                _product("order", subdomain="orderProcessing"),
                _product("quote", subdomain="orderProcessing"),
                _product("account", subdomain="accountManagement"),
            ]),
            _domain("ops", [
                _product("shipment", subdomain="movementTracking"),
                _product("route", subdomain="movementTracking"),
            ]),
        ])
        # Must not raise ForeignKeyViolation / IntegrityError.
        _svc(s).sync_from_model_json(v.id, model, run_id=run.id)

        subs = s.exec(select(Subdomain).where(Subdomain.version_id == v.id)).all()
        assert {sd.name for sd in subs} == {
            "orderProcessing", "accountManagement", "movementTracking",
        }
        sub_ids = {sd.id for sd in subs}
        prods = _products_for(s, v.id)
        assert len(prods) == 5
        for p in prods.values():
            assert p.subdomain_id in sub_ids


# --------------------------------------------------------------------------
# Test 17: subdomain upsert runs on the no-run_id (resync) path (E-B1b)
# --------------------------------------------------------------------------


def test_subdomain_upsert_runs_without_run_id(fk_engine):
    """A run_id-less sync (the force-resync recovery path) must still upsert
    subdomains — they are structural, not lineage-dependent. Regression for
    E-B1b: the upsert used to be gated inside the run_id-only lineage pass, so
    force-resync could never repair a subdomain-bearing model's subdomains.
    """
    with Session(fk_engine) as s:
        biz = _make_business(s)
        v = _make_version(s, biz.id, 1)
        model = _model([
            _domain("sales", [
                _product("order", subdomain="orderProcessing"),
                _product("account", subdomain="accountManagement"),
            ]),
        ])
        # No run_id — mirrors force_resync_version's sync_model() call.
        _svc(s).sync_from_model_json(v.id, model, run_id=None)

        subs = s.exec(select(Subdomain).where(Subdomain.version_id == v.id)).all()
        assert {sd.name for sd in subs} == {"orderProcessing", "accountManagement"}
        sub_ids = {sd.id for sd in subs}
        prods = _products_for(s, v.id)
        assert len(prods) == 2
        for p in prods.values():
            assert p.subdomain_id in sub_ids
