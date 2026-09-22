"""v5.0.5 [v505-selffix-domain-ops] — the ACTUAL landing site for user-vibe domain renames/merge.

Root cause chain (found across live runs 242444766950014 / 649786335981780):
  * The user-vibe A-format directives ("RENAME the `X` domain to `Y`", "`X` is a SUBDOMAIN of
    `Y`") are NOT `PRIORITY N` lines, so `_v251_parse_priorities` never emits them and pass-1
    (`_v251_apply_pass1_priorities`) never applies them. v504's pass-1 handler was correct but
    on a path these directives never traverse.
  * They surface instead as unfulfilled USER REQs in the SelfFixer closed loop, which (pre-v505)
    sent them to the LLM sandbox. The LLM dropped the domain WITHOUT re-pointing FKs -> 65
    dangling FKs -> selffixer-invariants-guard REJECT -> the rename NEVER landed (13 domains kept
    their old names while `verifier-preserve-structure` falsely marked the renames fulfilled on a
    count-only 13->13 check).

v5.0.5 fix (one engine, no 2nd path): the SelfFixer's existing deterministic pre-check
`_v410_deterministic_selffix` -> `_v410_parse_req_to_action` (which already handles move/add_fk
via the `_v337` appliers) now also detects domain rename/merge from the REQ text (self-guarding
`_v337_extract_domain_*`, regex-only, industry-agnostic) and applies via the SAME proven `_v337`
domain appliers BEFORE any LLM call. Order-independent: the merge target resolves to whichever
candidate domain name in the directive currently EXISTS, so a sibling rename that already
consumed the primary target name does not break the fold.

This test drives the EXACT A1-A4 run text through the REAL `_v410_deterministic_selffix` in
THREE orderings and locks: all applied, renames land, merge folds with a subdomain tag, external
FKs re-point to the new names, ZERO dangling FKs, and convergence is order-independent.
"""
from __future__ import annotations

import ast
import re

from notebook_source_util import notebook_concat_source, assert_agent_version_at_least

_SRC = notebook_concat_source()
_LINES = _SRC.splitlines(keepends=True)
_TREE = ast.parse(_SRC)
_FUNCS = [
    "_v337_extract_domain_rename", "_v337_extract_domain_merge", "_v337_extract_move_target",
    "_v337_parse_fk_fqn", "_v337_iter_products", "_v337_domain_rewire_prefix",
    "_v337_apply_rename_domain", "_v337_apply_merge_domain", "_v337_apply_move_product",
    "_v251_model_root", "_v251_find_domain", "_v251_find_product", "_v410_resolve_pk",
    "_v327_infer_coltype", "_v410_parse_req_to_action", "_v410_deterministic_selffix",
]
_FT = (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)


def _ns():
    consts, fns = {}, {}
    for n in _TREE.body:
        if isinstance(n, _FT) and getattr(n, "name", None) in _FUNCS:
            fns[n.name] = "".join(_LINES[n.lineno - 1:n.end_lineno])
        elif isinstance(n, ast.Assign):
            for t in n.targets:
                if isinstance(t, ast.Name) and (t.id.isupper() or t.id.startswith("_V") or t.id.startswith("_v")):
                    consts.setdefault(t.id, "".join(_LINES[n.lineno - 1:n.end_lineno]))
    g = {"re": re}
    for b in consts.values():
        try:
            exec(compile(b, "c", "exec"), g)
        except Exception:
            pass
    exec(compile("\n\n".join(fns[n] for n in _FUNCS if n in fns), "f", "exec"), g)
    return g


_NS = _ns()
_selffix = _NS["_v410_deterministic_selffix"]


class _Log:
    def info(self, *a, **k):
        pass

    def warning(self, *a, **k):
        pass


def _model():
    return {"model": {"domains": [
        {"name": "claims", "database_name": "claims", "products": [
            {"name": "claim", "primary_key": "claim_id",
             "attributes": [{"name": "claim_id", "type": "BIGINT"}]}]},
        {"name": "claimfinancials", "database_name": "claimfinancials", "products": [
            {"name": "reserve", "primary_key": "reserve_id", "attributes": [
                {"name": "reserve_id", "type": "BIGINT"},
                {"name": "claim_id", "type": "BIGINT", "foreign_key_to": "claims.claim.claim_id"}]}]},
        {"name": "riskexposure", "database_name": "riskexposure", "products": [
            {"name": "property_risk", "primary_key": "property_risk_id",
             "attributes": [{"name": "property_risk_id", "type": "BIGINT"}]}]},
        {"name": "catastrophegeography", "database_name": "catastrophegeography", "products": [
            {"name": "peril", "primary_key": "peril_id", "attributes": [{"name": "peril_id", "type": "BIGINT"}]}]},
        {"name": "policy", "database_name": "policy", "products": [
            {"name": "policy", "primary_key": "policy_id", "attributes": [
                {"name": "policy_id", "type": "BIGINT"},
                {"name": "reserve_ref", "type": "BIGINT", "foreign_key_to": "claimfinancials.reserve.reserve_id"},
                {"name": "risk_ref", "type": "BIGINT", "foreign_key_to": "riskexposure.property_risk.property_risk_id"},
                {"name": "peril_ref", "type": "BIGINT", "foreign_key_to": "catastrophegeography.peril.peril_id"}]}]},
    ]}}


_REQS = {
    "A1": {"id": "VREQ-002", "text": "A1: The `claimfinancials` domain (aka claim_financials) is NOT a "
           "top-level domain — it is a SUBDOMAIN of claims. Move every product in the `claimfinancials` "
           "domain into the `claim` domain and mark them with subdomain `claim_financials`."},
    "A2": {"id": "VREQ-003", "text": "A2: RENAME the `claims` domain to `claim`. Keep all of its products "
           "and foreign keys intact."},
    "A3": {"id": "VREQ-004", "text": "A3: RENAME the `riskexposure` domain (aka risk_exposure) to `risk`. "
           "Keep all of its products and foreign keys intact."},
    "A4": {"id": "VREQ-005", "text": "A4: RENAME the `catastrophegeography` domain (aka catastrophe_geography) "
           "to `catastrophe`. Keep all of its products and re-point all FKs."},
}


def _dangling(m):
    root = m["model"] if "model" in m else m
    live = {(d["name"], p["name"]) for d in root["domains"] for p in d["products"]}
    out = []
    for d in root["domains"]:
        for p in d["products"]:
            for a in p["attributes"]:
                fk = a.get("foreign_key_to")
                if fk and len(fk.split(".")) >= 3 and (fk.split(".")[0], fk.split(".")[1]) not in live:
                    out.append(fk)
    return out


def _apply(order):
    m = _model()
    res = {k: _selffix(m, _REQS[k], _Log()) for k in order}
    return m, m["model"], [d["name"] for d in m["model"]["domains"]], res


_ORDERS = [["A1", "A2", "A3", "A4"], ["A2", "A1", "A3", "A4"], ["A4", "A3", "A2", "A1"]]


def test_version_floor():
    assert_agent_version_at_least("5.0.5")


def test_all_applied_every_order():
    for order in _ORDERS:
        _m, _r, _d, res = _apply(order)
        for k in ("A1", "A2", "A3", "A4"):
            assert res[k][0] is True, "%s not applied deterministically (order=%s): %s" % (k, order, res[k])


def test_renames_and_fold_land_every_order():
    for order in _ORDERS:
        _m, root, doms, _res = _apply(order)
        assert "claim" in doms and "claims" not in doms, (order, doms)
        assert "risk" in doms and "riskexposure" not in doms, (order, doms)
        assert "catastrophe" in doms and "catastrophegeography" not in doms, (order, doms)
        assert "claimfinancials" not in doms, (order, doms)
        claim = next(d for d in root["domains"] if d["name"] == "claim")
        assert any(p.get("subdomain") in ("claimfinancials", "claim_financials") for p in claim["products"]), \
            "fold subdomain tag missing (order=%s)" % (order,)


def test_zero_dangling_and_external_repoint_every_order():
    for order in _ORDERS:
        m, root, _d, _res = _apply(order)
        assert _dangling(m) == [], "dangling FKs (order=%s): %s" % (order, _dangling(m))
        pol = next(d for d in root["domains"] if d["name"] == "policy")["products"][0]["attributes"]
        fk = {a["name"]: a.get("foreign_key_to") for a in pol}
        assert fk["reserve_ref"] == "claim.reserve.reserve_id", (order, fk["reserve_ref"])
        assert fk["risk_ref"] == "risk.property_risk.property_risk_id", (order, fk["risk_ref"])
        assert fk["peril_ref"] == "catastrophe.peril.peril_id", (order, fk["peril_ref"])


def test_non_domain_reqs_not_misfired():
    """A product move / add-fk REQ must NOT be swallowed as a domain op (extractors self-guard)."""
    mrg, ren = _NS["_v337_extract_domain_merge"], _NS["_v337_extract_domain_rename"]
    for txt in [
        "move coverage.submission to the underwriting domain",
        "connect claims.fnol with an FK to party.party.party_id",
        "rename producers.producers_producer to producer",
    ]:
        assert mrg(txt) is None, "merge false-match: %r" % txt
        assert ren(txt) is None, "rename false-match: %r" % txt
