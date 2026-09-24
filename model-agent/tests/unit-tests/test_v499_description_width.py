"""v4.9.9 / issue #41: descriptions must be <= MAX_DESCRIPTION_CHARS and never cut mid-word.

Upstream issue #41 reported descriptions ending mid-word ("... rate case prudency d").
Root cause: FK justification descriptions were assembled with ``reasoning[:200]``, a hard
slice that ended mid-word. The fix introduces:

  * ``_trim_description_to_width`` -- trims to <=256 on a word/sentence boundary,
  * a deterministic width pass inside ``_pre_static_analysis_autofix`` (enforcement),
  * a ``description_over_width`` gate in ``run_metamodel_static_analysis`` (scoreboard).

These behavioral tests exercise the real notebook code loaded into ``agent_helpers``.
"""
import logging

logger = logging.getLogger("desc_width_test")
logger.addHandler(logging.NullHandler())


def test_helper_trims_to_width_on_word_boundary():
    from agent_helpers import _trim_description_to_width, MAX_DESCRIPTION_CHARS

    assert MAX_DESCRIPTION_CHARS == 256
    # A short description is returned unchanged.
    assert _trim_description_to_width("Unique identifier for the order.") == "Unique identifier for the order."

    # The exact shape reported in issue #41: FK prefix + long justification.
    long_reasoning = (
        "Foreign key linking to renewable.der_registry. Business justification: Risk "
        "scoring for DER assets considering technology obsolescence, performance "
        "degradation rates, grid integration challenges, and stranded asset risk. "
        "Supports investment planning, rate case prudency determinations, and long term "
        "capital allocation across the portfolio of distributed energy resources."
    )
    out = _trim_description_to_width(long_reasoning)
    assert len(out) <= MAX_DESCRIPTION_CHARS
    # Never ends mid-word: the final token (punctuation-stripped) is a whole source word.
    assert not out.endswith(" ")
    src_words = {w.strip(".!?,;:") for w in long_reasoning.split()}
    last_word = out.split()[-1].strip(".!?,;:")
    assert last_word in src_words, f"trim ended mid-word: {last_word!r}"
    # And it should be the clean sentence end within budget.
    assert out.endswith("stranded asset risk.")


def test_autofix_enforces_width_across_domain_table_attribute():
    from agent_helpers import _pre_static_analysis_autofix, MAX_DESCRIPTION_CHARS

    over = "word " * 120  # ~600 chars, ends mid-token when hard-sliced
    domains_data = [{"domain": "sales", "description": "Sales domain. " + over}]
    products_data = [{"domain": "sales", "product": "order", "description": "Order table. " + over}]
    attributes_data = [
        {"domain": "sales", "product": "order", "attribute": "order_id",
         "column_name": "order_id", "type": "BIGINT", "is_primary_key": True,
         "description": "Unique identifier for the order."},
        {"domain": "sales", "product": "order", "attribute": "notes",
         "column_name": "notes", "type": "STRING",
         "description": "Free-text notes. " + over},
    ]

    _pre_static_analysis_autofix(domains_data, products_data, attributes_data, {}, logger)

    for rec in [domains_data[0], products_data[0], attributes_data[1]]:
        d = rec["description"]
        assert len(d) <= MAX_DESCRIPTION_CHARS, (rec, len(d))
        assert not d.endswith(" ")
    # short one untouched
    assert attributes_data[0]["description"] == "Unique identifier for the order."


def test_gate_reports_over_width_descriptions():
    from agent_helpers import run_metamodel_static_analysis, MAX_DESCRIPTION_CHARS

    over = "x" * (MAX_DESCRIPTION_CHARS + 50)
    domains_data = [{"domain": "sales", "description": "Sales domain with a healthy description of the selling side."}]
    products_data = [{"domain": "sales", "product": "order",
                      "description": "Order table capturing each customer purchase order lifecycle."}]
    attributes_data = [
        {"domain": "sales", "product": "order", "attribute": "order_id",
         "column_name": "order_id", "type": "BIGINT", "is_primary_key": True,
         "description": "Unique identifier for the order placed by the customer."},
        {"domain": "sales", "product": "order", "attribute": "notes",
         "column_name": "notes", "type": "STRING", "description": over},
    ]
    result = run_metamodel_static_analysis(domains_data, products_data, attributes_data, {}, logger)
    cats = [i.get("category") for i in result.get("issues", [])]
    assert "description_over_width" in cats, cats
