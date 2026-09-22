"""v5.0.8 [v508-bulk-move] — deterministic bulk product move + truthful bulk-move verdict.

Root cause (live run 913158349928845): the user's B1 rebalance is ONE VReq that lists 23 bare
product names to MOVE from `coverage` INTO `underwriting`. No path decomposed it into per-product
moves, so it reached the LLM sandbox as one un-decomposable req and soft-accepted a NO-OP; the
state_diff verifier then scored it a coarse 'partial' (never requeued), and `underwriting` stayed
at 1 product. Singular carried move VReqs also got non-failed (state_diff) verdicts and never
reached the deterministic move applier.

v5.0.8 fix (one engine): `_v337_extract_bulk_move` parses 'MOVE ... FROM `SRC` domain INTO `DST`
domain: a, b, c' (list = longest colon-introduced identifier run; parenthetical keep-lists are
never captured). `_v410_deterministic_selffix` applies each via the SAME `_v337_apply_move_product`
(per-product FK re-point). `_verify_requirement` gains a TRUTHFUL top-level bulk-move verdict so a
state_diff strategy cannot pre-empt it: failed when none moved (-> requeues to the applier),
fulfilled when all listed-and-present products landed. Industry-agnostic (regex + live-model
intersection; zero P&C literals).
"""
from __future__ import annotations

import ast
import re
import textwrap

from notebook_source_util import notebook_concat_source, assert_agent_version_at_least

_SRC = notebook_concat_source()
_LINES = _SRC.splitlines(keepends=True)
_TREE = ast.parse(_SRC)
_FT = (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)

_FUNCS = [
    "_v337_extract_domain_rename", "_v337_extract_domain_merge", "_v337_extract_bulk_move",
    "_v337_extract_move_target", "_v337_parse_fk_fqn", "_v337_iter_products", "_v337_find_product",
    "_v337_domain_rewire_prefix", "_v337_rewire_fks",
    "_v337_apply_rename_domain", "_v337_apply_merge_domain", "_v337_apply_move_product",
    "_v251_model_root", "_v251_find_domain", "_v251_find_product", "_v251_product_list", "_v410_resolve_pk",
    "_v327_infer_coltype", "_v410_parse_req_to_action", "_v410_deterministic_selffix",
]


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
_bulk = _NS["_v337_extract_bulk_move"]
_selffix = _NS["_v410_deterministic_selffix"]

# slice the REAL v508 verifier verdict block
_START = next(i for i, l in enumerate(_LINES) if "v508-bulk-move]: TRUTHFUL" in l)
_END = next(i for i in range(_START, len(_LINES)) if "_v103_count_shape_re = re.compile" in _LINES[i])
_BLOCK = textwrap.dedent("".join(_LINES[_START:_END]))

_B1 = ("B1. The `coverage` domain is overloaded and the `underwriting` domain has only one product. "
       "MOVE the following underwriting-lifecycle products FROM the `coverage` domain INTO the "
       "`underwriting` domain, cascading their attributes and re-pointing every foreign key that "
       "references them: submission, uw_decision, quote, binder. "
       "Leave all remaining coverage-structure products (coverage, limit, deductible, exclusion) in `coverage`.")


class _Log:
    def info(self, *a, **k):
        pass

    def warning(self, *a, **k):
        pass


class _Req:
    def __init__(self, text, rid="VREQ-B1"):
        self.id = rid
        self.original_text = text


def _model():
    def _p(n):
        return {"name": n, "primary_key": n + "_id", "attributes": [{"name": n + "_id", "type": "BIGINT"}]}
    return {"model": {"domains": [
        {"name": "coverage", "database_name": "coverage", "products": [
            _p("coverage"), _p("limit"), _p("deductible"), _p("exclusion"),
            _p("submission"), _p("uw_decision"), _p("quote"), _p("binder")]},
        {"name": "underwriting", "database_name": "underwriting", "products": [_p("uw_guideline")]},
        {"name": "policy", "database_name": "policy", "products": [
            {"name": "policy", "primary_key": "policy_id", "attributes": [
                {"name": "policy_id", "type": "BIGINT"},
                {"name": "sub_ref", "type": "BIGINT", "foreign_key_to": "coverage.submission.submission_id"}]}]},
    ]}}


def _pdomain(m, prod):
    for d in m["model"]["domains"]:
        for p in d["products"]:
            if p["name"] == prod:
                return d["name"]
    return None


def _verdict(req_text, products_data):
    fn = "def _run(self, req, domains_data, products_data, attributes_data):\n" + \
         "    _v506_txt = req.original_text or ''\n" + \
         textwrap.indent(_BLOCK, "    ") + "    return None\n"
    g = dict(_NS)
    g["re"] = re
    exec(compile(fn, "v", "exec"), g)
    return g["_run"](type("S", (), {"logger": _Log()})(), _Req(req_text), [], products_data, [])


def _pdata(m):
    return [{"domain": d["name"], "product": p["name"]}
            for d in m["model"]["domains"] for p in d["products"]]


_MOVE = ["submission", "uw_decision", "quote", "binder"]
_KEEP = ["coverage", "limit", "deductible", "exclusion"]


def test_version_floor():
    assert_agent_version_at_least("5.0.8")


def test_extractor_parses_move_list_only():
    bm = _bulk(_B1)
    assert bm is not None, "bulk-move directive not recognised"
    assert bm[0] == "coverage" and bm[1] == "underwriting", bm
    assert set(bm[2]) == set(_MOVE), bm[2]
    # the parenthetical keep-list must NOT be swept into the move-list
    for k in _KEEP:
        assert k not in bm[2], "keep-list product %s wrongly captured" % k


def test_selffix_moves_every_listed_product():
    m = _model()
    ok, res = _selffix(m, {"id": "VREQ-B1", "text": _B1}, _Log())
    assert ok is True, "bulk move not applied: %s" % (res,)
    for p in _MOVE:
        assert _pdomain(m, p) == "underwriting", "%s not moved (in %s)" % (p, _pdomain(m, p))
    for k in _KEEP:
        assert _pdomain(m, k) == "coverage", "%s wrongly moved" % k
    # cross-domain FK re-pointed to the new home
    pol = m["model"]["domains"][2]["products"][0]["attributes"]
    fk = next(a["foreign_key_to"] for a in pol if a["name"] == "sub_ref")
    assert fk == "underwriting.submission.submission_id", fk


def test_verifier_failed_pre_then_fulfilled_post():
    m = _model()
    v0 = _verdict(_B1, _pdata(m))
    assert v0 is not None and v0["status"] == "failed", v0  # nothing moved yet
    _selffix(m, {"id": "VREQ-B1", "text": _B1}, _Log())
    v1 = _verdict(_B1, _pdata(m))
    assert v1 is not None and v1["status"] == "fulfilled", v1


def test_verifier_partial_when_some_moved():
    m = _model()
    # move only two of the four
    _NS["_v337_apply_move_product"](m["model"], "coverage", "submission", "underwriting")
    _NS["_v337_apply_move_product"](m["model"], "coverage", "quote", "underwriting")
    v = _verdict(_B1, _pdata(m))
    assert v is not None and v["status"] == "partial", v


def test_no_false_match_on_non_bulk_directives():
    for txt in [
        "RENAME the `claims` domain to `claim`. Keep all its products and FKs.",
        "`claimfinancials` is a SUBDOMAIN of claims. Move every product into the `claim` domain.",
        "PRIORITY 22 move_product coverage.uw_guideline: move the uw_guideline product to the underwriting domain.",
        "add a household table to the party domain",
    ]:
        assert _bulk(txt) is None, "false bulk-move match: %r" % txt
