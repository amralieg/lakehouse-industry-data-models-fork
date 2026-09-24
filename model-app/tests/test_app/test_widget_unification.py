"""Both wrappers must produce identical widget maps for the same logical input.

The two wrappers exist for historical reasons (different caller shapes).
After Phase 2 unification they delegate to core._widgets.build_widget_map.
This regression locks the contract: any future drift between them fails here.
"""
from types import SimpleNamespace

import pytest

from vibe_modeling.backend.job_launcher import map_run_params_to_widgets
from vibe_modeling.backend.services.operations._generation_common import (
    build_generation_widgets,
)


def _biz(name="Test Retail.", description="Test biz", industry_alignment="Retail"):
    return SimpleNamespace(
        name=name, description=description, industry_alignment=industry_alignment
    )


@pytest.mark.parametrize(
    "model_size,expected_scopes",
    [
        ("small model", "Minimum Viable Model - MVM"),
        ("large model", "Expanded Coverage Model - ECM"),
    ],
)
def test_wrappers_produce_identical_widget_maps(model_size, expected_scopes):
    biz = _biz()
    common_params = dict(
        operation="new base model",
        catalog="vibe_modeling_test",
        session_id="abc-123",
        vibe_instructions="Limit to 10 products per domain",
        business_context_path="",
        business_description_override="",
        model_version="",
        model_folder="",
        naming_convention="snake_case",
        primary_key_suffix="_id",
        schema_prefix="ecm_",
        schema_suffix="",
        tag_prefix="dbx_",
        tag_suffix="",
        table_id_type="BIGINT",
        boolean_format="Boolean (True/False)",
        date_format="yyyy-MM-dd",
        timestamp_format="yyyy-MM-dd HH:mm:ss",
        cataloging_style="One Catalog",
        catalog_prefix="",
        catalog_suffix="",
        org_divisions="Operations",
        business_domains="customer, product, inventory, store",
        classification_levels="",
        housekeeping_columns="No",
        history_tracking_columns="No",
        generate_samples=False,
    )
    out_jl = map_run_params_to_widgets(
        business=biz, model_size=model_size, **common_params
    )
    out_gc = build_generation_widgets(
        business=biz, data_model_scopes=expected_scopes, **common_params
    )
    assert out_jl == out_gc, (
        f"widget maps drifted: jl - gc = "
        f"{set(out_jl.items()) ^ set(out_gc.items())}"
    )
    # Sanity: business_name uses agent's rule
    assert out_jl["business_name"] == "test_retail"
    assert out_jl["data_model_scopes"] == expected_scopes


def test_widget_map_includes_all_expected_keys():
    """Lock the schema — adding/removing widgets is a deliberate act."""
    biz = _biz()
    out = map_run_params_to_widgets(
        operation="new base model",
        business=biz,
        catalog="vibe_modeling_test",
        session_id="abc",
    )
    expected_keys = {
        "operation", "business_name", "business_description", "context_file",
        "deployment_catalog", "data_model_scopes", "generate_samples",
        "model_vibes", "vibe_session_id", "industry_alignment",
        "business_domains", "org_divisions", "cataloging_style",
        "catalog_prefix", "catalog_suffix", "naming_convention",
        "primary_key_suffix", "schema_prefix", "schema_suffix",
        "tag_prefix", "tag_suffix", "table_id_type", "boolean_format",
        "date_format", "timestamp_format", "classification_levels",
        "housekeeping_columns", "history_tracking_columns",
    }
    assert set(out) == expected_keys, (
        f"unexpected: {set(out) - expected_keys}, "
        f"missing: {expected_keys - set(out)}"
    )


def test_business_name_uses_agent_rule_edge_cases():
    """Trailing dot, hyphen, internal punctuation — agent_business_segment handles all."""
    cases = [
        ("Test Retail.", "test_retail"),
        ("Acme.Inc", "acme_inc"),
        ("7-eleven", "_7_eleven"),
    ]
    for name, expected in cases:
        out = map_run_params_to_widgets(
            operation="new base model",
            business=_biz(name=name),
            catalog="cat",
            session_id="s",
        )
        assert out["business_name"] == expected, (
            f"{name!r} -> expected {expected!r}, got {out['business_name']!r}"
        )
