"""v5.0.0 — shrink derives domains_to_keep from the surviving products.

Root cause fixed: the shrink domain-analysis LLM sometimes returns a populated
`tables_to_keep` but OMITS the `domains_to_keep` key entirely (live evidence:
"Domains to KEEP (0): []" logged alongside 107 surviving products). `domains_to_keep`
was parsed ONLY from the LLM field, and the deterministic empty-keep fallback
repopulates it ONLY when `tables_to_keep` itself is empty. So with products present
but the key missing, `domains_to_keep` stayed empty, `surviving_domains` came out 0,
and `_run_resize_model` aborted at the empty-model gate:
"❌ Shrink produced an empty model (0 domains, 107 products)".

Fix: `_shrink_augment_domains_to_keep` derives the keep-set from the FINAL survivor
products (each (domain, product) mapped through `domain_relocations`) and is called at
the consumption point, right before `surviving_domains` is built, so domains_to_keep
can never disagree with tables_to_keep regardless of the upstream path.
"""
from __future__ import annotations

from notebook_source_util import exec_function_namespace, notebook_concat_source


def _fn():
    ns = exec_function_namespace("_shrink_augment_domains_to_keep")
    return ns["_shrink_augment_domains_to_keep"]


def test_empty_domains_to_keep_is_derived_from_survivors():
    """The exact production failure: 100+ survivors but LLM omitted domains_to_keep.
    Pre-fix this left domains_to_keep empty -> 0 surviving_domains -> abort."""
    fn = _fn()
    tables_to_keep = {("party", "party"), ("policy", "policy"), ("claims", "claim"),
                      ("premium", "premium_transaction")}
    kept, missing = fn(tables_to_keep, {}, set())
    assert kept == {"party", "policy", "claims", "premium"}
    assert missing == {"party", "policy", "claims", "premium"}
    # the whole point: surviving_domains would now be NON-empty
    assert kept, "domains_to_keep must be non-empty when products survive"


def test_relocations_are_followed_to_the_target_domain():
    """A product relocated to another domain must keep the TARGET domain, not the source."""
    fn = _fn()
    kept, _ = fn({("sales", "order")}, {("sales", "order"): "commercial"}, set())
    assert kept == {"commercial"}


def test_noop_when_domains_to_keep_already_complete():
    """When the LLM returns a correct domains_to_keep, the helper adds nothing."""
    fn = _fn()
    ttk = {("party", "party"), ("policy", "policy")}
    kept, missing = fn(ttk, {}, {"party", "policy", "shared"})
    assert missing == set()
    assert kept == {"party", "policy", "shared"}


def test_partial_domains_to_keep_is_augmented_not_replaced():
    """If the LLM lists some but not all survivor domains, the missing ones are added
    and the LLM-provided extras are preserved."""
    fn = _fn()
    ttk = {("party", "party"), ("policy", "policy"), ("claims", "claim")}
    kept, missing = fn(ttk, {}, {"party"})
    assert kept == {"party", "policy", "claims"}
    assert missing == {"policy", "claims"}


def test_empty_and_none_inputs_are_safe():
    fn = _fn()
    assert fn(set(), {}, set()) == (set(), set())
    assert fn(None, None, None) == (set(), set())


def test_call_site_uses_helper_before_surviving_domains():
    """Structural proof the guard runs at the consumption point: the helper must be
    called, passing tables_to_keep, BEFORE surviving_domains is built from domains_to_keep."""
    src = notebook_concat_source()
    call = "_shrink_augment_domains_to_keep(\n                tables_to_keep, domain_relocations, domains_to_keep)"
    assert call in src, "call site must invoke the helper with tables_to_keep"
    call_idx = src.index("domains_to_keep, _missing_dtk = _shrink_augment_domains_to_keep")
    surv_idx = src.index('surviving_domains = [d for d in domains_data if d["domain"] in domains_to_keep]')
    assert call_idx < surv_idx, "helper must run before surviving_domains is built"
    assert "shrink-domains-from-survivors FIRED" in src
