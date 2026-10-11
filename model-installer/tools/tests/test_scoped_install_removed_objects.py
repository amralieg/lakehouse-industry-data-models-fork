"""A scoped artifact whose run renamed a product (or a whole domain) carries a
`*_vibe_scope_removed_*.sql` file with the drops for the old tables and views. The installer runs
it last, on the base version only, and then drops a schema those drops left empty.
"""
from installer_harness import (BASE_V1_TABLES, REGISTRY_COLUMNS, FakeUC, find_cell, load_pipeline,
                               pipeline_cfg, registry_row, scoped_folder)

MODEL_JSON = {"agent_version": "5.3.2", "model_requirements": {"business_name": "Demo Air"},
              "_vibe_scope": {"mode": "requested", "entries": ["sales"], "base_version": "1",
                              "operation": "vibe modeling of version"},
              "model": {"version": "v2_mvm", "domains": []}}
REMOVED = ("-- vibe_scope removed objects\n"
           "DROP TABLE IF EXISTS `demo`.`sales`.`customer`;\n"
           "DROP TABLE IF EXISTS `demo`.`legacy`.`old_thing`;\n")


def _install(tmp_path, rows):
    folder = scoped_folder(tmp_path, model_json=MODEL_JSON)
    (folder / "schemas" / "demo_vibe_scope_removed_v2_mvm.sql").write_text(REMOVED)
    tables = dict(BASE_V1_TABLES, **{"demo.legacy.old_thing": {"columns": ["old_thing_id"]}})
    spark = FakeUC(tables, columns=REGISTRY_COLUMNS, rows=rows)
    ns = load_pipeline(spark, extra_cells=("def uninstall(cfg)", "def guard_scoped_install"))
    cfg = pipeline_cfg(folder)
    plan = ns["build_plan"](cfg)
    model = ns["load_model_json"](cfg)
    ns["guard_scoped_install"](cfg, plan, model)
    final, _, _ = ns["install"](cfg, plan)
    return ns, cfg, plan, final, spark


def test_the_removed_file_runs_after_the_relink_and_empties_the_old_schema(tmp_path):
    ns, cfg, plan, final, spark = _install(tmp_path, [registry_row(1, business="Demo Air")])
    assert final == []
    assert len(plan["other"]) == 2
    assert "demo.sales.customer" not in spark.tables and "demo.legacy.old_thing" not in spark.tables
    assert spark.tables["demo.sales.order"]["fks"] == {"fk_order_customer": "demo.sales.customer_v2"}
    relink = spark.position("ADD CONSTRAINT `fk_order_customer`")[0]
    assert relink < spark.position("DROP TABLE IF EXISTS `demo`.`sales`.`customer`")[0]
    assert ns["drop_emptied_schemas"](cfg, plan) == ["demo.legacy"]
    assert "legacy" not in spark.schemas["demo"] and "sales" in spark.schemas["demo"]


def test_a_schema_that_still_holds_a_table_is_kept(tmp_path):
    ns, cfg, plan, final, spark = _install(tmp_path, [registry_row(1, business="Demo Air")])
    spark.tables["demo.legacy.someone_elses"] = {"columns": {"x"}, "fks": {}, "tags": {}, "types": {"x": "bigint"}}
    spark.schemas["demo"].add("legacy")
    assert ns["drop_emptied_schemas"](cfg, plan) == []
    assert "legacy" in spark.schemas["demo"]


def test_main_drops_emptied_schemas_only_for_a_scoped_artifact():
    main = find_cell("def main()")
    install_at = main.index("final, elapsed, timings = install(cfg, plan)")
    call_at = main.index("drop_emptied_schemas(cfg, plan)")
    assert install_at < call_at
    assert 'if (model or {}).get("vibe_scope"):' in main[install_at:call_at]
