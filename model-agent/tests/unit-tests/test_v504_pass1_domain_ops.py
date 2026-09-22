"""v5.0.4 [v504-pass1-domain-ops] — the true single-engine root-cause fix.

The VoV vibe parser mis-labels a DOMAIN directive ("RENAME the `X` domain to `Y`",
"`X` is a SUBDOMAIN of `Y`") as a product-level action (rename_product / update_description).
Before v5.0.4, `_v251_apply_pass1_priorities` — the ONE deterministic engine BOTH the priority
and the raw-vibe branches call — had no domain-rename/merge handler, so it "applied" a no-op and
marked the directive fulfilled while the domain kept its old name (the "renames not applied"
catastrophe). The LLM sandbox fallback then dropped the domain WITHOUT re-pointing FKs, producing
dangling-FK regressions the invariants-guard rejected, so the rename NEVER landed.

v5.0.4 reclassifies each priority from its TEXT (industry-agnostic, regex-only, self-guarding on
the literal word "domain"/"subdomain" so product/column renames and product moves never match)
and applies via the proven `_v337` domain appliers (full FK re-pointing, atomic fold). This test
drives the EXACT A1-A4 failure through the real `_v251_apply_pass1_priorities` and locks:
renames land, merge folds without data loss, external FKs re-point, ZERO dangling FKs.
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
    "_v337_extract_col_rename", "_v337_extract_split", "_v337_extract_reverse_fk",
    "_v301_extract_rename_target", "_v337_parse_fk_fqn", "_v337_iter_products",
    "_v337_domain_rewire_prefix", "_v337_apply_rename_domain", "_v337_apply_merge_domain",
    "_v251_model_root", "_v251_find_product", "_v251_find_attribute_row",
    "_v251_parse_priority_details", "_v415_complete_connect_details", "_v310_apply_rename_ledger",
    "_v251_prevalidate_priority", "_v251_apply_priority_deterministic", "_v251_apply_pass1_priorities",
]
_FT = (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)


def _build_ns():
    consts = {}
    fns = {}
    for n in _TREE.body:
        if isinstance(n, _FT) and getattr(n, "name", None) in _FUNCS:
            fns[n.name] = "".join(_LINES[n.lineno - 1:n.end_lineno])
        elif isinstance(n, ast.Assign):
            for t in n.targets:
                if isinstance(t, ast.Name) and (t.id.isupper() or t.id.startswith("_V") or t.id.startswith("_v")):
                    consts.setdefault(t.id, "".join(_LINES[n.lineno - 1:n.end_lineno]))
    g = {"re": re}
    for body in consts.values():
        try:
            exec(compile(body, "c", "exec"), g)
        except Exception:
            pass

    class VReqOutcome:  # minimal stand-in (the real one is a dataclass with the same attrs)
        def __init__(self, **kw):
            self.__dict__.update(kw)

    g.setdefault("VReqOutcome", VReqOutcome)
    g.setdefault("_LEGACY_ACTION_MAP", {})
    exec(compile("\n\n".join(fns[n] for n in _FUNCS if n in fns), "f", "exec"), g)
    return g


_NS = _build_ns()
_pass1 = _NS["_v251_apply_pass1_priorities"]


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


# The parser MIS-LABELS these (action=rename_product/update_description). priority_id orders
# A1 (fold) before A2 (rename) so the fold-into-claims lands before claims->claim.
_PRIOS = [
    {"priority_id": 2, "vreq_id": "VREQ-002", "action": "update_description", "target": "claimfinancials",
     "intent": "A1. The claimfinancials domain is a SUBDOMAIN of claims. Move every product in the "
               "claimfinancials domain into the claim domain."},
    {"priority_id": 3, "vreq_id": "VREQ-003", "action": "rename_product", "target": "claims",
     "intent": "A2. RENAME the claims domain to claim. Keep all its products and FKs."},
    {"priority_id": 4, "vreq_id": "VREQ-004", "action": "rename_product", "target": "riskexposure",
     "intent": "A3. RENAME the riskexposure domain to risk. Keep all products and FKs."},
    {"priority_id": 5, "vreq_id": "VREQ-005", "action": "update_description", "target": "catastrophegeography",
     "intent": "A4. RENAME the catastrophegeography domain to catastrophe. Keep all products and FKs."},
]


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


def _run():
    m = _model()
    new_model, outcomes, _residual = _pass1([dict(p) for p in _PRIOS], m, _Log())
    root = new_model["model"] if "model" in new_model else new_model
    doms = [d["name"] for d in root["domains"]]
    applied = {str(getattr(o, "vreq_ids", ("?",))[0]) for o in outcomes
               if getattr(o, "status", "") == "applied"}
    return root, doms, applied, _dangling(new_model)


def test_version_floor():
    assert_agent_version_at_least("5.0.4")


def test_all_four_domain_ops_applied():
    _root, _doms, applied, _ = _run()
    for vid in ("VREQ-002", "VREQ-003", "VREQ-004", "VREQ-005"):
        assert vid in applied, "%s not applied deterministically (applied=%s)" % (vid, sorted(applied))


def test_three_renames_landed():
    _root, doms, _a, _d = _run()
    assert "claim" in doms and "claims" not in doms, doms
    assert "risk" in doms and "riskexposure" not in doms, doms
    assert "catastrophe" in doms and "catastrophegeography" not in doms, doms


def test_merge_folded_without_data_loss():
    root, doms, _a, _d = _run()
    assert "claimfinancials" not in doms, "source domain not dropped after fold: %s" % doms
    claim = next(d for d in root["domains"] if d["name"] == "claim")
    folded = [p for p in claim["products"] if p.get("subdomain") in ("claimfinancials", "claim_financials")]
    assert len(folded) == 1, "folded reserve must survive with a subdomain tag"


def test_zero_dangling_fks_and_external_repoint():
    root, _doms, _a, dangling = _run()
    assert dangling == [], "dangling FKs after domain ops: %s" % dangling
    pol = next(d for d in root["domains"] if d["name"] == "policy")["products"][0]["attributes"]
    fkmap = {a["name"]: a.get("foreign_key_to") for a in pol}
    assert fkmap["reserve_ref"] == "claim.reserve.reserve_id", fkmap["reserve_ref"]
    assert fkmap["risk_ref"] == "risk.property_risk.property_risk_id", fkmap["risk_ref"]
    assert fkmap["peril_ref"] == "catastrophe.peril.peril_id", fkmap["peril_ref"]


def test_reclassify_does_not_misfire_on_non_domain_ops():
    """The domain reclassify must NOT swallow product renames, column renames, or product moves.
    The _v337 domain extractors self-guard on the literal word 'domain'/'subdomain', so these
    non-domain directives must return None (no false domain-op classification)."""
    _mrg = _NS["_v337_extract_domain_merge"]
    _ren = _NS["_v337_extract_domain_rename"]
    cases = [
        "rename producers.producers_producer to producer (drop redundant prefix)",
        "in claims.claim_exposure, rename column adjuster_id to assigned_adjuster_id",
        "move coverage.submission to the underwriting domain because UW lifecycle",
        "MOVE the following products FROM the coverage domain INTO the underwriting domain: quote, binder",
    ]
    for txt in cases:
        assert _mrg(txt) is None, "merge extractor false-matched: %r -> %r" % (txt, _mrg(txt))
        assert _ren(txt) is None, "rename extractor false-matched: %r -> %r" % (txt, _ren(txt))
