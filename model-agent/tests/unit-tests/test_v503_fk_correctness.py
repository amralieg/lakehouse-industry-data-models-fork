"""v5.0.3 FK-correctness + rename-persistence: four INDUSTRY-AGNOSTIC fixes locked here.

All four derive purely from the live model (target PK type/name, FK graph topology,
rename maps) and contain ZERO industry literals, so they hold for any industry.

1. FK type inheritance [v503-fk-type-inherit]: an FK column MUST carry the SAME type as
   the PK it references. The create-new-FK site previously hardcoded 'BIGINT' regardless
   of the target PK type (the dominant v1->v2 adherence-gap class: STRING/DECIMAL PKs got
   BIGINT FKs -> type-mismatch joins). Now every FK write site coerces type := target PK
   type via the existing _get_pk_type_for_fk_target helper.

2. FK column naming [v503-fk-colname]: a newly-created FK column is named after the entity
   it references ("<target_product>_<target_pk>"), never a bare business noun.

3. Rename persistence [v503-rename-persist]: renames applied in one mutation batch are
   written back into the shared persistent_renames dict so LATER batches / carried
   next_vibes VREQs that still reference PRE-rename names resolve (the "stale reference"
   gap class). Previously the applier returned only an int and the maps were lost.

4. Cycle-safe FK add [v503-fk-cycle-safe]: adding an FK that would close a directed cycle
   in the FK graph is SKIPPED + logged honestly, instead of applied-then-silently-deleted
   by the downstream cycle breaker (a source of phantom-applied VREQs).
"""
from __future__ import annotations

import ast
import re
import hashlib

from notebook_source_util import notebook_concat_source

_CONSTS = [
    "_MUT_ENTITY_SYNONYMS",
    "_MUT_OPERATION_SYNONYMS",
    "_P091_IDENTIFIER_RE",
    "_P091_PROSE_TOKENS",
]
_ENGINE_FNS = [
    "_is_user_pinned_domain",
    "_guard_user_pinned_domain_drop",
    "_preseed_rename_maps",
    "_p091_is_valid_identifier",
    "_p091_reject_name_mutation",
    "_get_pk_type_for_fk_target",
    "_get_pk_type_for_fk_target_impl",
    "_build_fk_adjacency",
    "_would_create_cycle",
    "_v503_enforce_fk_type",
    "_v503_canonical_fk_colname",
    "_v503_fk_would_cycle",
    "_llm_fallback_apply_mutations",
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


def _build_engine():
    g = {
        "re": re,
        "hashlib": hashlib,
        "_vibe_set_entity_tag": lambda ent, f, v: ent.__setitem__(f, v),
        "sanitize_attribute_type": lambda t: t,
        "_disk_cached_call": lambda tag, key, fn: fn(),  # bypass on-disk cache
        "strip_configured_pk_suffix": lambda a, c: a,
    }
    blob = "\n\n".join(_last_span(n) for n in (_CONSTS + _ENGINE_FNS))
    exec(compile(blob, "notebook_engine_slice", "exec"), g)
    return g


_NS = _build_engine()


class _Log:
    def __init__(self):
        self.lines = []
    def info(self, *a, **k): self.lines.append(str(a))
    def warning(self, *a, **k): self.lines.append(str(a))
    def error(self, *a, **k): pass


def _apply(muts, D, P, A, pr=None):
    return _NS["_llm_fallback_apply_mutations"](muts, D, P, A, [], _Log(), persistent_renames=pr)


def _two_domain(pk1_type, pk2_type):
    D = [{"domain": "d1", "description": "", "division": "", "database_name": ""},
         {"domain": "d2", "description": "", "division": "", "database_name": ""}]
    P = [{"domain": "d1", "product": "cust", "table_name": "cust", "subdomain": ""},
         {"domain": "d2", "product": "ord", "table_name": "ord", "subdomain": ""}]
    A = [{"domain": "d1", "product": "cust", "attribute": "cust_code", "type": pk1_type,
          "tags": "primary_key", "foreign_key_to": ""},
         {"domain": "d2", "product": "ord", "attribute": "ord_id", "type": pk2_type,
          "tags": "primary_key", "foreign_key_to": ""}]
    return D, P, A


def test_fk_type_inherits_string_pk():
    """create-new FK to a STRING PK -> FK column type == STRING (not hardcoded BIGINT)."""
    D, P, A = _two_domain("STRING", "BIGINT")
    _apply([{"entity_type": "link", "operation": "add",
             "entity_ref": "d2.ord.customer", "new_value": "d1.cust.cust_code"}], D, P, A)
    fk = [a for a in A if a["product"] == "ord" and a.get("foreign_key_to") == "d1.cust.cust_code"]
    assert fk, "FK column not created"
    assert fk[0]["type"] == "STRING", f"expected STRING, got {fk[0]['type']}"


def test_fk_type_inherits_bigint_pk_no_overcorrection():
    D, P, A = _two_domain("BIGINT", "BIGINT")
    _apply([{"entity_type": "link", "operation": "add",
             "entity_ref": "d2.ord.cust_id", "new_value": "d1.cust.cust_code"}], D, P, A)
    fk = [a for a in A if a["product"] == "ord" and a.get("foreign_key_to") == "d1.cust.cust_code"]
    assert fk and fk[0]["type"] == "BIGINT"


def test_fk_colname_coined_from_target_when_bare_noun():
    D, P, A = _two_domain("STRING", "BIGINT")
    _apply([{"entity_type": "link", "operation": "add",
             "entity_ref": "d2.ord.customer", "new_value": "d1.cust.cust_code"}], D, P, A)
    fk = [a for a in A if a["product"] == "ord" and a.get("foreign_key_to") == "d1.cust.cust_code"]
    assert fk
    nm = fk[0]["attribute"]
    assert nm.endswith("cust_code") or nm == "cust_cust_code", f"col not target-derived: {nm}"


def test_rename_persisted_back_to_shared_map():
    D = [{"domain": "claims", "description": "", "division": "", "database_name": ""},
         {"domain": "other", "description": "", "division": "", "database_name": ""}]
    P = [{"domain": "claims", "product": "claim", "table_name": "claim", "subdomain": ""},
         {"domain": "other", "product": "misc", "table_name": "misc", "subdomain": ""}]
    A = [{"domain": "claims", "product": "claim", "attribute": "claim_id", "type": "BIGINT",
          "tags": "primary_key", "foreign_key_to": ""},
         {"domain": "other", "product": "misc", "attribute": "note", "type": "STRING", "foreign_key_to": ""}]
    pr = {"domain": {}, "product": {}, "attribute": {}}
    _apply([{"entity_type": "domain", "operation": "modify",
             "entity_ref": "claims", "field": "domain", "new_value": "claim"}], D, P, A, pr)
    assert pr["domain"].get("claims") == "claim", f"rename not persisted: {pr['domain']}"
    # carried VREQ referencing the PRE-rename domain must still resolve + apply
    n = _apply([{"entity_type": "link", "operation": "add",
                 "entity_ref": "other.misc.claim_ref", "new_value": "claims.claim.claim_id"}], D, P, A, pr)
    assert n >= 1, "carried VREQ with pre-rename ref failed to apply"
    assert [a for a in A if a["product"] == "misc" and a.get("foreign_key_to")]


def test_cycle_closing_fk_skipped_honestly():
    """acc.txn_id -> b.txn already exists; adding txn -> a.acc closes a cycle -> SKIP."""
    D = [{"domain": "a", "description": "", "division": "", "database_name": ""},
         {"domain": "b", "description": "", "division": "", "database_name": ""}]
    P = [{"domain": "a", "product": "acc", "table_name": "acc", "subdomain": ""},
         {"domain": "b", "product": "txn", "table_name": "txn", "subdomain": ""}]
    A = [{"domain": "a", "product": "acc", "attribute": "acc_id", "type": "BIGINT",
          "tags": "primary_key", "foreign_key_to": ""},
         {"domain": "a", "product": "acc", "attribute": "txn_id", "type": "BIGINT",
          "foreign_key_to": "b.txn.txn_id"},
         {"domain": "b", "product": "txn", "attribute": "txn_id", "type": "BIGINT",
          "tags": "primary_key", "foreign_key_to": ""}]
    _apply([{"entity_type": "link", "operation": "modify",
             "entity_ref": "b.txn.acc_link", "new_value": "a.acc.acc_id"}], D, P, A)
    cyc = [a for a in A if a["product"] == "txn" and a.get("foreign_key_to") == "a.acc.acc_id"]
    assert not cyc, "cycle-closing FK was applied; must be skipped honestly"
