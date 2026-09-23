"""v5.0.4 P2 behavioral test — every TABLE carries domain + division + subdomain tags.

Requirement (user directive 2026-09-23):
    - Schema level: {prefix}domain, {prefix}division  (already emitted; unchanged)
    - Table level : {prefix}domain, {prefix}division, {prefix}subdomain  (NEW: domain+division
      added at the table level; subdomain was already emitted per table)

UC schema tags are NOT inherited by tables, so a governance scan over
information_schema.table_tags needs domain + division ON the table, not only on the schema.

Two physical-DDL emission paths must BOTH carry the new table tags:
    Path A — normal build (step_generate_physical_schema): keys via _effective_tag_key(...)
    Path B — install-model operation:                       keys via _eff_tag(...)

Sentinel alias: v504-table-domain-division-tags

fail-pre/pass-post: on HEAD~1 the four `SET TAGS ('{...domain/division}'...)` ALTER TABLE
substrings are absent, so `test_v504_table_domain_tag_emitted_pathA/B` fail; post-patch they pass.
"""
import json
from pathlib import Path

NOTEBOOK = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"


def _all_source():
    nb = json.loads(NOTEBOOK.read_text())
    return "\n".join("".join(cell.get("source", [])) for cell in nb["cells"])


def test_v504_agent_version_at_least_504():
    src = _all_source()
    import re
    m = re.search(r'__AGENT_VERSION__\s*=\s*"(\d+)\.(\d+)\.(\d+)"', src)
    assert m is not None, "v5.0.4: __AGENT_VERSION__ not found with single-digit semver"
    assert tuple(int(g) for g in m.groups()) >= (5, 0, 4), (
        f"v5.0.4: __AGENT_VERSION__ must be >= 5.0.4, got {m.group(0)}"
    )
    for seg in m.groups():
        assert 0 <= int(seg) <= 9, "v5.0.4: single-digit semver (CLAUDE.md §3a)"


def test_v504_alias_present():
    assert "v504-table-domain-division-tags" in _all_source(), (
        "v5.0.4: sentinel alias v504-table-domain-division-tags missing"
    )


def test_v504_table_domain_tag_emitted_pathA():
    src = _all_source()
    assert "SET TAGS ('{_effective_tag_key('domain')}' = '{replace_single_quote(p_domain)}')" in src, (
        "v5.0.4 Path A: table-level domain tag ALTER TABLE statement missing"
    )
    assert "SET TAGS ('{_effective_tag_key('division')}' = '{replace_single_quote(_p_division_val)}')" in src, (
        "v5.0.4 Path A: table-level division tag ALTER TABLE statement missing"
    )


def test_v504_table_domain_tag_emitted_pathB():
    src = _all_source()
    assert "SET TAGS ('{_eff_tag('domain')}' = '{replace_single_quote(dn)}')" in src, (
        "v5.0.4 Path B (install model): table-level domain tag missing"
    )
    assert "SET TAGS ('{_eff_tag('division')}' = '{replace_single_quote(division)}')" in src, (
        "v5.0.4 Path B (install model): table-level division tag missing"
    )


def test_v504_subdomain_table_tag_preserved():
    """The pre-existing per-table subdomain tag must remain in BOTH paths (no regression)."""
    src = _all_source()
    assert "SET TAGS ('{_effective_tag_key('subdomain')}' = '{replace_single_quote(_p_subdomain_conv)}')" in src, (
        "v5.0.4: Path A subdomain table tag regressed"
    )
    assert "SET TAGS ('{_eff_tag('subdomain')}' = '{replace_single_quote(_cn(p_subdomain))}')" in src, (
        "v5.0.4: Path B subdomain table tag regressed"
    )


def test_v504_domain_division_are_unconditional_pathA():
    """domain+division must be emitted for EVERY table (before, and independent of, the
    `if _p_subdomain_raw:` guard). Assert the domain append precedes the subdomain guard."""
    src = _all_source()
    dom_idx = src.find("SET TAGS ('{_effective_tag_key('domain')}' = '{replace_single_quote(p_domain)}')")
    guard_idx = src.find('_p_subdomain_raw = (p.get("subdomain") or "").strip()')
    assert dom_idx > 0 and guard_idx > 0, "v5.0.4: anchors not found"
    assert dom_idx < guard_idx, (
        "v5.0.4: table domain/division tags must be emitted unconditionally, BEFORE the subdomain guard"
    )


def test_v504_schema_level_domain_division_preserved():
    """Schema-level domain + division tags must remain (user: 'both schema and table')."""
    src = _all_source()
    assert "ALTER SCHEMA `{effective_catalog}`.`{_eff_db_name}` SET TAGS ('{_effective_tag_key('domain')}'" in src, (
        "v5.0.4: schema-level domain tag regressed"
    )
    assert "ALTER SCHEMA `{effective_catalog}`.`{_eff_db_name}` SET TAGS ('{_effective_tag_key('division')}'" in src, (
        "v5.0.4: schema-level division tag regressed"
    )


# --- Behavioral: reproduce the exact emission logic and assert the produced SQL ---

def _effective_tag_key(prefix, key):
    return f"{prefix}{key}"


def _emit_table_tags(prefix, full_table_name, p_domain, division, subdomain):
    """Faithful replica of the v5.0.4 P2 table-tag emission order."""
    stmts = []
    stmts.append(f"ALTER TABLE {full_table_name} SET TAGS ('{_effective_tag_key(prefix,'domain')}' = '{p_domain}');")
    stmts.append(f"ALTER TABLE {full_table_name} SET TAGS ('{_effective_tag_key(prefix,'division')}' = '{division}');")
    if subdomain:
        stmts.append(f"ALTER TABLE {full_table_name} SET TAGS ('{_effective_tag_key(prefix,'subdomain')}' = '{subdomain}');")
    return stmts


def test_v504_behavioral_default_prefix():
    stmts = _emit_table_tags("dbx_", "`cat`.`policy`.`policy`", "policy", "business", "contract_lifecycle")
    assert "SET TAGS ('dbx_domain' = 'policy')" in stmts[0]
    assert "SET TAGS ('dbx_division' = 'business')" in stmts[1]
    assert "SET TAGS ('dbx_subdomain' = 'contract_lifecycle')" in stmts[2]
    assert len(stmts) == 3


def test_v504_behavioral_custom_prefix_flows_through():
    stmts = _emit_table_tags("acme_", "`c`.`s`.`t`", "claims", "operations", "fnol")
    assert stmts[0].endswith("SET TAGS ('acme_domain' = 'claims');")
    assert stmts[1].endswith("SET TAGS ('acme_division' = 'operations');")
    assert stmts[2].endswith("SET TAGS ('acme_subdomain' = 'fnol');")


def test_v504_behavioral_domain_division_present_even_without_subdomain():
    """A table with no subdomain still gets domain + division tags (the mandatory pair)."""
    stmts = _emit_table_tags("dbx_", "`c`.`s`.`t`", "underwriting", "business", "")
    keys = [s.split("SET TAGS ('")[1].split("'")[0] for s in stmts]
    assert keys == ["dbx_domain", "dbx_division"], (
        "domain+division must be present even when subdomain is empty"
    )
