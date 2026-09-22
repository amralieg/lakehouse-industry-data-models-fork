"""v5.0.6 [v506-verifier-domain-rename] — the TRUTHFUL domain rename/merge verdict.

Root cause chain (recurring 'renames never applied' catastrophe, live runs 242444766950014 /
649786335981780 / 783775596261108):
  * A domain-rename VReq carries preservation phrasing ("RENAME the `claims` domain to `claim`.
    Keep all its products and FKs"), so `_verify_state_diff` -> `[verifier-preserve-structure
    FIRED v4.0.6]` saw domains 13->13 + products preserved and returned FULFILLED.
  * A FULFILLED verdict EXCLUDES the VReq from the SelfFixer's unfulfilled set, so the v505
    deterministic domain applier (`_v410_deterministic_selffix`) NEVER received the req, and the
    domain kept its old name while the scoreboard lied that the rename landed.

v5.0.6 fix: `_verify_requirement` now checks the LIVE domain-name set FIRST (pre-empting the
preserve-structure lie). A rename is fulfilled ONLY when the new name is present AND the old name
is gone; a merge ONLY when the source is gone AND the target present. Otherwise FAILED -> the req
stays unfulfilled -> the SelfFixer deterministic pre-check lands it via the SAME `_v337` appliers.

This test slices the REAL shipped v506 verdict block out of the notebook, execs it against a stub
`self`/`req`, and locks fail-pre (old name still present -> failed) / pass-post (renamed/merged ->
fulfilled), plus that a non-domain REQ never reaches a domain verdict (falls through).
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

# --- load the REAL module-level extractors the verdict depends on ---
_EXTRACTORS = ["_v337_extract_domain_rename", "_v337_extract_domain_merge", "_v337_extract_bulk_move"]
_G = {"re": re}
for _n in _TREE.body:
    if isinstance(_n, _FT) and getattr(_n, "name", None) in _EXTRACTORS:
        exec(compile("".join(_LINES[_n.lineno - 1:_n.end_lineno]), "x", "exec"), _G)

# --- slice the REAL shipped v506 verdict block from _verify_requirement ---
_START = next(i for i, l in enumerate(_LINES) if "v506-verifier-domain-rename]: TRUTHFUL" in l)
_END = next(i for i in range(_START, len(_LINES)) if "_v103_count_shape_re = re.compile" in _LINES[i])
_BLOCK = textwrap.dedent("".join(_LINES[_START:_END]))


class _Log:
    def info(self, *a, **k):
        pass


class _Req:
    def __init__(self, text):
        self.id = "VREQ-TEST"
        self.original_text = text


def _verdict(req_text, domain_names):
    """Exec the REAL v506 block; return its verdict dict, or None if it falls through."""
    domains_data = [{"domain": d} for d in domain_names]
    ns = dict(_G)
    ns.update({"self": type("S", (), {"logger": _Log()})(), "req": _Req(req_text),
               "domains_data": domains_data, "products_data": [], "attributes_data": []})
    fn = "def _run(self, req, domains_data, products_data, attributes_data):\n" + \
         textwrap.indent(_BLOCK, "    ") + "    return None\n"
    g = dict(_G)
    exec(compile(fn, "v", "exec"), g)
    return g["_run"](ns["self"], ns["req"], domains_data, [], [])


_RENAME = "A2: RENAME the `claims` domain to `claim`. Keep all of its products and foreign keys intact."
_MERGE = ("A1: The `claimfinancials` domain is NOT a top-level domain — it is a SUBDOMAIN of `claim`. "
          "Move every product in the `claimfinancials` domain into the `claim` domain.")


def test_version_floor():
    assert_agent_version_at_least("5.0.6")


def test_rename_fail_pre():
    # old name still present, new absent -> the truthful verdict is FAILED (not the preserve lie)
    v = _verdict(_RENAME, ["claims", "policy", "risk"])
    assert v is not None and v["status"] == "failed", v
    assert "verifier-domain-rename FIRED v5.0.6" in v["evidence"]


def test_rename_pass_post():
    # after the applier ran: new present, old gone -> fulfilled
    v = _verdict(_RENAME, ["claim", "policy", "risk"])
    assert v is not None and v["status"] == "fulfilled", v


def test_rename_partial_both_present_is_failed():
    # both old and new present (rename not truly done) -> must NOT be called fulfilled
    v = _verdict(_RENAME, ["claims", "claim", "policy"])
    assert v is not None and v["status"] == "failed", v


def test_merge_fail_pre():
    v = _verdict(_MERGE, ["claimfinancials", "claim", "policy"])
    assert v is not None and v["status"] == "failed", v


def test_merge_pass_post():
    v = _verdict(_MERGE, ["claim", "policy"])
    assert v is not None and v["status"] == "fulfilled", v


def test_non_domain_req_falls_through():
    # a product move / add-fk / product rename must NOT get a domain verdict (returns None)
    for txt in [
        "move coverage.submission to the underwriting domain",
        "connect claims.fnol with an FK to party.party.party_id",
        "rename producers.producers_producer to producer",
        "add a household table to the party domain",
    ]:
        assert _verdict(txt, ["claims", "policy"]) is None, "false domain verdict: %r" % txt
