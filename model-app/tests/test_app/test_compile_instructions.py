"""Unit tests for the shared compile helper (`backend/_compile.py`).

Compile is pure/read-only: it serializes a selection of VibeInputs anchored to
a version into one markdown doc + structured provenance blocks. It records
nothing. See task5-backend-api.md §5.
"""

import sys
import os
import json

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from sqlmodel import Session, SQLModel, create_engine
from sqlalchemy.pool import StaticPool

from vibe_modeling.backend._compile import compile_inputs
from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    Domain,
    ForeignKeyLink,
    ModelVersion,
    Product,
    Subdomain,
    VibeInput,
    VibeInputContextLink,
)


@pytest.fixture(name="session")
def session_fixture():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    with Session(engine) as s:
        yield s


@pytest.fixture
def version(session) -> ModelVersion:
    b = Business(name="Acme")
    session.add(b)
    session.commit()
    mv = ModelVersion(business_id=b.id, version=1, status="completed", scope="ecm")
    session.add(mv)
    session.commit()
    return mv


def _input(session, business_id, text, *, origin="user", priority="high",
           author="alice@x.com", confidence=None) -> VibeInput:
    vi = VibeInput(
        business_id=business_id, text=text, origin=origin,
        priority=priority, author=author, confidence_score=confidence,
    )
    session.add(vi)
    session.commit()
    return vi


def _link(session, input_id, version_id, **anchor) -> VibeInputContextLink:
    link = VibeInputContextLink(input_id=input_id, version_id=version_id, **anchor)
    session.add(link)
    session.commit()
    return link


def test_model_wide_input_compiles_to_header_and_bullet(session, version):
    vi = _input(session, version.business_id, "Use snake_case everywhere")
    _link(session, vi.id, version.id, is_origin=True)  # all-null = model-wide

    out = compile_inputs(session, version.id, [vi.id])

    assert "## Model-wide" in out.markdown
    assert "- (high) Use snake_case everywhere" in out.markdown
    assert out.included_input_ids == [vi.id]
    assert out.excluded_input_ids == []
    assert len(out.blocks) == 1
    block = out.blocks[0]
    assert block.input_id == vi.id
    assert block.origin.value == "user"
    assert block.author == "alice@x.com"
    assert block.confidence_score is None
    assert block.section_path == ["Model-wide"]
    # Provenance is metadata, NOT inline in the markdown.
    assert "[scope]" not in out.markdown
    assert "alice@x.com" not in out.markdown


def test_empty_selection_returns_empty(session, version):
    out = compile_inputs(session, version.id, [])
    assert out.markdown == ""
    assert out.blocks == []
    assert out.included_input_ids == []


def _domain(session, version_id, name) -> Domain:
    d = Domain(version_id=version_id, name=name)
    session.add(d)
    session.commit()
    return d


def _product(session, version_id, domain_id, name) -> Product:
    p = Product(version_id=version_id, domain_id=domain_id, name=name)
    session.add(p)
    session.commit()
    return p


def test_section_ordering_model_wide_first_then_hierarchy_name_sorted(session, version):
    bid = version.business_id
    d_sales = _domain(session, version.id, "Sales")
    d_acct = _domain(session, version.id, "Accounting")
    p_orders = _product(session, version.id, d_sales.id, "Orders")

    mw = _input(session, bid, "global rule")
    _link(session, mw.id, version.id)
    i_sales = _input(session, bid, "sales rule")
    _link(session, i_sales.id, version.id, domain_id=d_sales.id)
    i_acct = _input(session, bid, "acct rule")
    _link(session, i_acct.id, version.id, domain_id=d_acct.id)
    i_orders = _input(session, bid, "orders rule")
    _link(session, i_orders.id, version.id, domain_id=d_sales.id, product_id=p_orders.id)

    out = compile_inputs(session, version.id,
                         [i_orders.id, i_acct.id, i_sales.id, mw.id])
    md = out.markdown

    # Model-wide header first.
    assert md.index("## Model-wide") < md.index("## Domain:")
    # Accounting before Sales (case-insensitive name sort).
    assert md.index("## Domain: Accounting") < md.index("## Domain: Sales")
    # Orders product nests under Sales with #### header.
    assert "#### Product: Orders" in md
    assert md.index("## Domain: Sales") < md.index("#### Product: Orders")


def test_header_levels_only_emitted_when_populated(session, version):
    bid = version.business_id
    d_sales = _domain(session, version.id, "Sales")
    p_orders = _product(session, version.id, d_sales.id, "Orders")
    # Two inputs under the same product — the Domain/Product headers must not
    # repeat for the second input.
    i1 = _input(session, bid, "first")
    _link(session, i1.id, version.id, domain_id=d_sales.id, product_id=p_orders.id)
    i2 = _input(session, bid, "second")
    _link(session, i2.id, version.id, domain_id=d_sales.id, product_id=p_orders.id)

    out = compile_inputs(session, version.id, [i1.id, i2.id])
    md = out.markdown
    assert md.count("## Domain: Sales") == 1
    assert md.count("#### Product: Orders") == 1


def test_deprecated_input_excluded_with_reason(session, version):
    bid = version.business_id
    vi = _input(session, bid, "stale rule")
    vi.status = "deprecated"
    session.add(vi)
    session.commit()
    _link(session, vi.id, version.id)

    out = compile_inputs(session, version.id, [vi.id])
    assert vi.id in out.excluded_input_ids
    assert out.excluded_reasons[vi.id] == "deprecated"
    assert out.included_input_ids == []
    assert out.markdown == ""


def test_no_anchor_on_version_excluded(session, version):
    bid = version.business_id
    other = ModelVersion(business_id=bid, version=2, status="completed", scope="ecm")
    session.add(other)
    session.commit()
    vi = _input(session, bid, "anchored elsewhere")
    _link(session, vi.id, other.id)  # link on a different version

    out = compile_inputs(session, version.id, [vi.id])
    assert vi.id in out.excluded_input_ids
    assert out.excluded_reasons[vi.id] == "no_anchor_on_version"


def test_block_carries_confidence_for_agent_inputs(session, version):
    bid = version.business_id
    vi = _input(session, bid, "agent idea", origin="agent_next_vibe",
                priority="low", author="", confidence=0.82)
    _link(session, vi.id, version.id)

    out = compile_inputs(session, version.id, [vi.id])
    block = out.blocks[0]
    assert block.origin.value == "agent_next_vibe"
    assert block.priority.value == "low"
    assert block.confidence_score == 0.82
    assert "- (low) agent idea" in out.markdown


def test_round_trip_determinism(session, version):
    bid = version.business_id
    d = _domain(session, version.id, "Sales")
    i1 = _input(session, bid, "rule one")
    _link(session, i1.id, version.id, domain_id=d.id)
    i2 = _input(session, bid, "rule two")
    _link(session, i2.id, version.id, domain_id=d.id)

    a = compile_inputs(session, version.id, [i1.id, i2.id])
    b = compile_inputs(session, version.id, [i2.id, i1.id])
    assert a.markdown == b.markdown
    assert [bl.input_id for bl in a.blocks] == [bl.input_id for bl in b.blocks]


_LONG = (
    "Customers are the central entity of this model and every downstream "
    "domain references the customer identifier, so treat customer identity "
    "as the canonical join key."
)


def test_short_input_still_oneline_bullet(session, version):
    vi = _input(session, version.business_id, "Use snake_case   everywhere",
                priority="high")
    _link(session, vi.id, version.id)

    out = compile_inputs(session, version.id, [vi.id])

    assert out.markdown == "## Model-wide\n- (high) Use snake_case everywhere"
    assert "> Priority:" not in out.markdown


def test_long_single_paragraph_renders_as_block(session, version):
    vi = _input(session, version.business_id, _LONG, priority="medium")
    _link(session, vi.id, version.id)
    assert "\n" not in _LONG and len(_LONG) > 150

    out = compile_inputs(session, version.id, [vi.id])

    assert out.markdown == (
        "## Model-wide\n\n> Priority: medium\n\n" + _LONG + "\n"
    )


def test_multiline_input_preserves_newlines(session, version):
    text = (
        "# Billing area\n\nCustomers are billed monthly. Two sub-flows:\n\n"
        "- **Subscriptions** — recurring, see `billing_account`\n"
        "- **One-off** — invoiced on `invoice_id`"
    )
    vi = _input(session, version.business_id, text, priority="high")
    _link(session, vi.id, version.id)

    out = compile_inputs(session, version.id, [vi.id])

    assert out.markdown == "## Model-wide\n\n> Priority: high\n\n" + text + "\n"


def test_user_heading_in_body_not_downshifted(session, version):
    text = "# Heading\n\nbody paragraph that is here."
    vi = _input(session, version.business_id, text, priority="high")
    _link(session, vi.id, version.id)

    out = compile_inputs(session, version.id, [vi.id])

    assert "# Heading" in out.markdown
    assert "## Model-wide" in out.markdown
    assert "###### Heading" not in out.markdown


def test_mixed_short_and_rich_under_one_section(session, version):
    bid = version.business_id
    d = _domain(session, version.id, "Sales")
    short = _input(session, bid, "keep order ids stable", priority="medium")
    _link(session, short.id, version.id, domain_id=d.id)
    rich_text = (
        "Sales narrative that runs well past one hundred and fifty characters "
        "so it trips the rich detector and renders as a preserved "
        "multi-paragraph block under the Sales header."
    )
    rich = _input(session, bid, rich_text, priority="high")
    _link(session, rich.id, version.id, domain_id=d.id)

    out = compile_inputs(session, version.id, [rich.id, short.id])

    assert out.markdown == (
        "## Domain: Sales\n- (medium) keep order ids stable\n\n"
        "> Priority: high\n\n" + rich_text + "\n"
    )
    assert out.markdown.count("## Domain: Sales") == 1


def test_rich_block_fenced_by_blank_lines(session, version):
    vi = _input(session, version.business_id, _LONG, priority="medium")
    _link(session, vi.id, version.id)

    lines = compile_inputs(session, version.id, [vi.id]).markdown.split("\n")

    pri = lines.index("> Priority: medium")
    assert lines[pri - 1] == ""   # leading fence before priority
    assert lines[pri + 1] == ""   # blank between priority and body
    assert lines[-1] == ""        # trailing fence


def test_whitespace_only_rich_degenerate(session, version):
    vi = _input(session, version.business_id, "\n", priority="high")
    _link(session, vi.id, version.id)

    out = compile_inputs(session, version.id, [vi.id])

    assert out.markdown == "## Model-wide\n\n> Priority: high\n"


def test_block_body_strip_pair(session, version):
    vi = _input(session, version.business_id,
                "\n   keep spaces\nsecond   \n", priority="low")
    _link(session, vi.id, version.id)

    out = compile_inputs(session, version.id, [vi.id])

    assert out.markdown == (
        "## Model-wide\n\n> Priority: low\n\n   keep spaces\nsecond\n"
    )


def test_doc_trailing_newline_depends_on_last_entry(session, version):
    bid = version.business_id
    d_acct = _domain(session, version.id, "Accounting")
    d_sales = _domain(session, version.id, "Sales")
    rich_text = (
        "Accounting narrative long enough to exceed the one hundred and fifty "
        "character threshold so that it is detected as rich and rendered as a "
        "fenced markdown block."
    )
    rich = _input(session, bid, rich_text, priority="high")
    _link(session, rich.id, version.id, domain_id=d_acct.id)
    short = _input(session, bid, "trailing short rule", priority="medium")
    _link(session, short.id, version.id, domain_id=d_sales.id)

    out = compile_inputs(session, version.id, [rich.id, short.id])

    assert out.markdown == (
        "## Domain: Accounting\n\n> Priority: high\n\n" + rich_text + "\n\n"
        "## Domain: Sales\n- (medium) trailing short rule"
    )
    assert not out.markdown.endswith("\n")


def test_round_trip_determinism_with_rich(session, version):
    bid = version.business_id
    d = _domain(session, version.id, "Sales")
    rich = _input(session, bid, _LONG, priority="high")
    _link(session, rich.id, version.id, domain_id=d.id)
    short = _input(session, bid, "keep ids stable", priority="low")
    _link(session, short.id, version.id, domain_id=d.id)

    a = compile_inputs(session, version.id, [rich.id, short.id])
    b = compile_inputs(session, version.id, [short.id, rich.id])
    assert a.markdown == b.markdown


def test_block_text_field_is_raw_not_oneline(session, version):
    text = "# Heading\n\nfirst paragraph.\n\nsecond paragraph here."
    vi = _input(session, version.business_id, text, priority="high")
    _link(session, vi.id, version.id)

    out = compile_inputs(session, version.id, [vi.id])

    assert out.blocks[0].text == text


_FIXTURE_PATH = os.path.join(
    os.path.dirname(__file__), "..", "fixtures", "compile_blocks_fixture.json"
)


def _load_fixture():
    with open(_FIXTURE_PATH, encoding="utf-8") as f:
        return json.load(f)


def _subdomain(session, version_id, domain_id, name) -> Subdomain:
    s = Subdomain(version_id=version_id, domain_id=domain_id, name=name)
    session.add(s)
    session.commit()
    return s


def _fk_link(session, version_id, label) -> ForeignKeyLink:
    # label is "<source_product>.<source_column>→<target_product>.<target_column>"
    src, tgt = label.split("→", 1)
    sp, sc = src.split(".", 1)
    tp, tc = tgt.split(".", 1)
    fk = ForeignKeyLink(
        version_id=version_id, source_product=sp, source_column=sc,
        target_product=tp, target_column=tc,
    )
    session.add(fk)
    session.commit()
    return fk


def _materialize(session, version, case_inputs):
    """Turn a fixture case's anchorPath+priority+text rows into the VibeInput +
    VibeInputContextLink rows compile_inputs expects, returning the input ids in
    the case's given order. Parent element rows (Domain/Subdomain/Product) are
    reused across inputs that share the same prefixed label prefix-tuple so
    headers de-dup exactly as the pinned expected_markdown."""
    bid = version.business_id
    domains: dict[str, Domain] = {}
    subdomains: dict[tuple, Subdomain] = {}
    products: dict[tuple, Product] = {}
    input_ids: list[str] = []
    for row in case_inputs:
        path = row["anchorPath"]
        anchor: dict = {}
        if path != ["Model-wide"]:
            dom = None
            for label in path:
                if label.startswith("Domain: "):
                    name = label[len("Domain: "):]
                    dom = domains.get(name)
                    if dom is None:
                        dom = _domain(session, version.id, name)
                        domains[name] = dom
                    anchor["domain_id"] = dom.id
                elif label.startswith("Subdomain: "):
                    name = label[len("Subdomain: "):]
                    key = (dom.id, name)
                    sub = subdomains.get(key)
                    if sub is None:
                        sub = _subdomain(session, version.id, dom.id, name)
                        subdomains[key] = sub
                    anchor["subdomain_id"] = sub.id
                elif label.startswith("Product: "):
                    name = label[len("Product: "):]
                    key = (dom.id, name)
                    prod = products.get(key)
                    if prod is None:
                        prod = _product(session, version.id, dom.id, name)
                        products[key] = prod
                    anchor["product_id"] = prod.id
                elif label.startswith("Relationship: "):
                    fk = _fk_link(session, version.id, label[len("Relationship: "):])
                    anchor["fk_link_id"] = fk.id
                else:
                    raise AssertionError(f"adapter: unhandled anchor label {label!r}")
        vi = _input(session, bid, row["text"], priority=row["priority"])
        _link(session, vi.id, version.id, **anchor)
        input_ids.append(vi.id)
    return input_ids


def test_compile_matches_frozen_fixture(session, version):
    fixture = _load_fixture()
    for case in fixture["cases"]:
        input_ids = _materialize(session, version, case["inputs"])
        out = compile_inputs(session, version.id, input_ids)
        assert out.markdown == case["expected_markdown"], case["name"]
        if case["name"] == "ordering_stability_reversed_input_order_same_output":
            rev = compile_inputs(session, version.id, list(reversed(input_ids)))
            assert rev.markdown == case["expected_markdown"], case["name"] + " (reversed)"
