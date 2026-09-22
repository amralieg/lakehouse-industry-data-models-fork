"""v5.0.3 VoV mechanical-path DOMAIN ops [v503-vov-domain-ops] — the true root-cause fix.

The VoV structural path classifies each instruction via `_v337_classify_op` and applies it
via `_v337_apply_*` (the deterministic mechanical path, NOT the LLM-fallback engine). Before
v5.0.3 that path handled move_product / rename_product / rename_attribute / split / reverse /
add_fk but had NO domain-rename and NO domain-merge handler, so a "rename the X domain to Y"
or "fold X into Y as a subdomain" VREQ classified as None and was SILENTLY DROPPED — the
"renames not applied" catastrophe (model kept the old domain names end-to-end).

This locks the fix: domain rename + merge are classified from the instruction text
(INDUSTRY-AGNOSTIC regex, no domain-name literals) and applied on the nested model root with
full FK re-pointing, product fold-as-subdomain, and zero data loss.
"""
from __future__ import annotations

import ast
import re

from notebook_source_util import notebook_concat_source

_FNS = [
    "_v337_extract_domain_rename",
    "_v337_extract_domain_merge",
    "_v337_extract_move_target",
    "_v337_extract_col_rename",
    "_v337_extract_split",
    "_v337_extract_reverse_fk",
    "_v301_extract_rename_target",
    "_v337_parse_fk_fqn",
    "_v337_iter_products",
    "_v337_domain_rewire_prefix",
    "_v337_apply_rename_domain",
    "_v337_apply_merge_domain",
    "_v337_classify_op",
]

_SOURCE = notebook_concat_source()
_LINES = _SOURCE.splitlines(keepends=True)
_TREE = ast.parse(_SOURCE)
_FUNC_TYPES = (ast.FunctionDef, ast.AsyncFunctionDef)


def _last_span(name):
    node = None
    for n in _TREE.body:
        if isinstance(n, _FUNC_TYPES) and n.name == name:
            node = n
        elif isinstance(n, ast.Assign) and any(
                isinstance(t, ast.Name) and t.id == name for t in n.targets):
            node = n
    if node is None:
        raise LookupError(name)
    return "".join(_LINES[node.lineno - 1:node.end_lineno])


def _build():
    g = {"re": re, "sanitize_name": lambda n, strip_stop_words=True: n}
    exec(compile("\n\n".join(_last_span(n) for n in _FNS), "slice", "exec"), g)
    return g


_NS = _build()
_classify = _NS["_v337_classify_op"]
_ren = _NS["_v337_apply_rename_domain"]
_mrg = _NS["_v337_apply_merge_domain"]


def _model():
    return {"model": {"domains": [
        {"name": "claims", "database_name": "claims", "products": [
            {"name": "claim", "primary_key": "claim_id",
             "attributes": [{"name": "claim_id", "type": "BIGINT"}]}]},
        {"name": "claimfinancials", "database_name": "claimfinancials", "products": [
            {"name": "reserve", "primary_key": "reserve_id", "attributes": [
                {"name": "reserve_id", "type": "BIGINT"},
                {"name": "claim_id", "type": "BIGINT", "foreign_key_to": "claims.claim.claim_id"}]}]},
        {"name": "other", "database_name": "other", "products": [
            {"name": "misc", "primary_key": "misc_id", "attributes": [
                {"name": "misc_id", "type": "BIGINT"},
                {"name": "reserve_ref", "type": "BIGINT",
                 "foreign_key_to": "claimfinancials.reserve.reserve_id"}]}]},
    ]}}


def test_classify_domain_rename_plain():
    txt = "RENAME the `claims` domain to `claim`. Keep all its products and FKs."
    assert _classify("", "", txt, txt) == ("rename_domain", "claims", "claim")


def test_classify_domain_rename_with_parenthetical():
    txt = "RENAME the `riskexposure` domain (aka risk_exposure) to `risk`."
    assert _classify("", "", txt, txt) == ("rename_domain", "riskexposure", "risk")


def test_classify_domain_merge_subdomain_phrasing():
    txt = ("The `claimfinancials` domain (aka claim_financials) is NOT a top-level domain; "
           "it is a SUBDOMAIN of claims. Move every product into the `claim` domain.")
    assert _classify("", "", txt, txt) == ("merge_domain", "claimfinancials", "claims")


def test_classify_move_product_not_misfired_to_domain_op():
    op = _classify("move_product", "coverage.submission",
                   "move to the underwriting domain because UW lifecycle",
                   "move to the underwriting domain")
    assert op and op[0] == "move_product" and op[3] == "underwriting"


def test_apply_rename_domain_repoints_fk():
    m = _model()["model"]
    _ren(m, "claims", "claim")
    names = [d["name"] for d in m["domains"]]
    assert "claim" in names and "claims" not in names
    fk = m["domains"][1]["products"][0]["attributes"][1]["foreign_key_to"]
    assert fk == "claim.claim.claim_id"


def test_apply_merge_domain_folds_without_data_loss():
    m = _model()["model"]
    _ren(m, "claims", "claim")
    p_before = sum(len(d["products"]) for d in m["domains"])
    _mrg(m, "claimfinancials", "claim")
    names = [d["name"] for d in m["domains"]]
    p_after = sum(len(d["products"]) for d in m["domains"])
    claim_dom = next(d for d in m["domains"] if d["name"] == "claim")
    folded = [p for p in claim_dom["products"] if p.get("subdomain") == "claimfinancials"]
    ext = next(d for d in m["domains"] if d["name"] == "other")["products"][0]["attributes"][1]["foreign_key_to"]
    assert "claimfinancials" not in names, "source domain must be dropped after fold"
    assert p_after == p_before, "merge must not lose any product"
    assert len(folded) == 1, "folded product must carry subdomain=claimfinancials"
    assert ext == "claim.reserve.reserve_id", "external FK into folded product must re-point"


def test_rename_onto_existing_domain_defers_to_merge():
    """rename X->Y where Y already exists must NOT clobber; returns None so caller merges."""
    m = _model()["model"]
    assert _ren(m, "claimfinancials", "claims") is None
