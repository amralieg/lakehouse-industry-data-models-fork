"""v5.0.7 [v507-merge-as-subdomain] — fold a domain phrased as 'treat `X` as a SUBDOMAIN of Y'.

Root cause (live run 563191367211299): the three RENAMES landed deterministically via the v505
SelfFixer pre-check + the v506 truthful verifier, but the FOLD directive A1 ('Treat
`claimfinancials` as a SUBDOMAIN of claims. Move every product into the `claim` domain') was NOT
applied — `_v337_extract_domain_merge` only recognised '`X` is a subdomain' and '`X` domain ...
subdomain', so the 'treat `X` as a subdomain' construction fell through to the LLM sandbox, which
soft-accepted a NO-OP and left `claimfinancials` a top-level domain.

v5.0.7 fix (one engine, no new path): add the 'as ... subdomain' source pattern to the SAME
`_v337_extract_domain_merge` extractor used by the _v410 selffix pre-check and the v506 verifier,
and make the v506 verifier's merge target ORDER-INDEPENDENT (a sibling rename may rename the fold
target). This test locks: the extractor now matches the exact A1 text, the real
`_v410_deterministic_selffix` folds `claimfinancials` away with FK re-point + zero dangling, and
the fold is verified fulfilled even after the target domain was renamed.
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
    "_v337_extract_domain_rename", "_v337_extract_domain_merge", "_v337_extract_move_target",
    "_v337_parse_fk_fqn", "_v337_iter_products", "_v337_domain_rewire_prefix",
    "_v337_apply_rename_domain", "_v337_apply_merge_domain", "_v337_apply_move_product",
    "_v251_model_root", "_v251_find_domain", "_v251_find_product", "_v410_resolve_pk",
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
_selffix = _NS["_v410_deterministic_selffix"]
_merge = _NS["_v337_extract_domain_merge"]

# slice the REAL v506/v507 verifier verdict block
_START = next(i for i, l in enumerate(_LINES) if "v506-verifier-domain-rename]: TRUTHFUL" in l)
_END = next(i for i in range(_START, len(_LINES)) if "_v103_count_shape_re = re.compile" in _LINES[i])
_BLOCK = textwrap.dedent("".join(_LINES[_START:_END]))

_A1 = ("A1: Treat `claimfinancials` (aka claim_financials) as a SUBDOMAIN of claims rather than a "
       "top-level domain. Move every product in the `claimfinancials` domain into the `claim` domain "
       "and mark them with subdomain `claim_financials`.")


class _Log:
    def info(self, *a, **k):
        pass

    def warning(self, *a, **k):
        pass


class _Req:
    def __init__(self, text, rid="VREQ-002"):
        self.id = rid
        self.original_text = text


def _model():
    return {"model": {"domains": [
        {"name": "claims", "database_name": "claims", "products": [
            {"name": "claim", "primary_key": "claim_id",
             "attributes": [{"name": "claim_id", "type": "BIGINT"}]}]},
        {"name": "claimfinancials", "database_name": "claimfinancials", "products": [
            {"name": "reserve", "primary_key": "reserve_id", "attributes": [
                {"name": "reserve_id", "type": "BIGINT"},
                {"name": "claim_id", "type": "BIGINT", "foreign_key_to": "claims.claim.claim_id"}]}]},
        {"name": "policy", "database_name": "policy", "products": [
            {"name": "policy", "primary_key": "policy_id", "attributes": [
                {"name": "policy_id", "type": "BIGINT"},
                {"name": "reserve_ref", "type": "BIGINT", "foreign_key_to": "claimfinancials.reserve.reserve_id"}]}]},
    ]}}


def _dnames(m):
    return [d["name"] for d in m["model"]["domains"]]


def _dangling(m):
    root = m["model"]
    live = {(d["name"], p["name"]) for d in root["domains"] for p in d["products"]}
    out = []
    for d in root["domains"]:
        for p in d["products"]:
            for a in p["attributes"]:
                fk = a.get("foreign_key_to")
                if fk and len(fk.split(".")) >= 3 and (fk.split(".")[0], fk.split(".")[1]) not in live:
                    out.append(fk)
    return out


def _verdict(req_text, domain_names):
    domains_data = [{"domain": d} for d in domain_names]
    fn = "def _run(self, req, domains_data, products_data, attributes_data):\n" + \
         textwrap.indent(_BLOCK, "    ") + "    return None\n"
    g = dict(_NS)
    g["re"] = re
    exec(compile(fn, "v", "exec"), g)
    return g["_run"](type("S", (), {"logger": _Log()})(), _Req(req_text), domains_data, [], [])


def test_version_floor():
    assert_agent_version_at_least("5.0.7")


def test_extractor_matches_treat_as_subdomain():
    mg = _merge(_A1)
    assert mg is not None, "extractor still misses 'treat X as a subdomain'"
    assert mg[0] == "claimfinancials", mg
    assert mg[1] in ("claims", "claim"), mg


def test_selffix_folds_the_domain_away():
    m = _model()
    ok, _res = _selffix(m, {"id": "VREQ-002", "text": _A1}, _Log())
    assert ok is True, "fold not applied deterministically: %s" % (_res,)
    assert "claimfinancials" not in _dnames(m), _dnames(m)
    assert _dangling(m) == [], _dangling(m)
    # products landed in the target domain (claims), FK from policy re-pointed
    tgt = next(d for d in m["model"]["domains"] if d["name"] == "claims")
    assert any(p["name"] == "reserve" for p in tgt["products"]), [p["name"] for p in tgt["products"]]
    pol = next(d for d in m["model"]["domains"] if d["name"] == "policy")["products"][0]["attributes"]
    fk = next(a["foreign_key_to"] for a in pol if a["name"] == "reserve_ref")
    assert fk.startswith("claims.reserve."), fk


def test_verifier_fulfilled_after_target_renamed():
    # fold landed AND target 'claims' later renamed to 'claim' -> src gone, parsed tgt absent,
    # but 'claim' present in the directive and live -> order-independent verdict = fulfilled
    v = _verdict(_A1, ["claim", "policy"])
    assert v is not None and v["status"] == "fulfilled", v


def test_verifier_failed_when_not_folded():
    v = _verdict(_A1, ["claimfinancials", "claims", "policy"])
    assert v is not None and v["status"] == "failed", v


def test_extractor_no_false_match_on_non_merge():
    for txt in [
        "move coverage.submission to the underwriting domain",
        "rename the claims domain to claim",
        "add a subdomain column to the party table",
    ]:
        assert _merge(txt) is None, "false merge match: %r" % txt
