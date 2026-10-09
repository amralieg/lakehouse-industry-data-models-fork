"""v5.1.5: step_setup_and_clean must give the schema-ownership gate (decision 12A) the business name.

Live run 222415511766934 (R2, unscoped 'vibe modeling of version' of vs514 retail v1) failed in setup:
"SCHEMA OWNERSHIP CLASH ... for business '' would deploy into 4 existing schema(s) that this business
does not own ... the ownership read failed (the business name or the _metamodel tables are not
configured)". step_setup_and_clean called _early_clash_detection before it stored
widgets_values["business_name"], so _schema_ownership_snapshot read ownership for business '' and
refused the business's own schemas. Every VOV / shrink / enlarge into an existing catalog failed.
"""
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
import test_v514_schema_ownership_teardown as own  # noqa: E402
from notebook_source_util import notebook_concat_source, slice_function_source  # noqa: E402


def _setup_body():
    return slice_function_source("step_setup_and_clean", source=notebook_concat_source())


def test_the_business_name_is_stored_before_the_ownership_gate_runs():
    body = _setup_body()
    gate = body.index("_early_clash_detection(spark, config, widgets_values, logger)")
    stores = [i for i in range(len(body)) if body.startswith('widgets_values["business_name"] = business_name', i)]
    assert stores and min(stores) < gate, "the ownership gate runs before widgets_values carries the business name"


def test_without_the_business_name_the_gate_refuses_the_business_own_schemas():
    spark = own._spark(own.ALL_SCHEMAS, *own._history())
    wv = own._vov_wv(pins=("crew", "flight"))
    wv.pop("business_name")
    with pytest.raises(ValueError, match="SCHEMA OWNERSHIP CLASH"):
        ah._early_clash_detection(spark, own._config(), wv, own._Log())
    assert spark.drops() == []


def test_with_the_business_name_the_same_vov_tears_down_only_its_own_schemas():
    spark = own._spark(own.ALL_SCHEMAS, *own._history())
    ah._early_clash_detection(spark, own._config(), own._vov_wv(pins=("crew", "flight")), own._Log())
    assert {d.split("`.`")[1].split("`")[0] for d in spark.drops() if d.startswith("DROP SCHEMA")} == {"crew", "flight"}
