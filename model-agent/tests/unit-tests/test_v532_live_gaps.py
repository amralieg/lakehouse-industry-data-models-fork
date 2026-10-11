"""v5.3.2: the gaps the live validation of 5.3.1 left open.

- A standalone install of a scoped model.json on its base kept the table and the metric view of a product the scoped run
  renamed or dropped (the run itself drops them; the install did not).
- The installer runs the artifact's SQL files, which carried no drop for those tables and views.
- Live R26 824350583887071, R27 818153627135066, R28 923117901254702 and R29 90080685367621: the verification sweep saw
  "(no actions logged)" after the VOV engine had applied every requirement, and issued a corrective for a rename that had
  already landed.
"""
import copy
import json
import logging
import sys
import types
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
import vibe_scope_deploy_harness as h  # noqa: E402

VIEWS = ["crew_roster_kpis", "flight_crew_coverage", "fleet_utilization", "crew_base_kpis"]
OWNED = {"skyline.crew", "skyline.flight", "skyline.fleet"}


@pytest.fixture(autouse=True)
def _reset():
    ah.set_vibe_scope_runtime(None)
    ah.vov_ledger_reset()
    yield
    ah.set_vibe_scope_runtime(None)
    ah.vov_ledger_reset()


def _base_with_dropped_view():
    base = h.base_model()
    base["model"]["metric_views"].append(h.metric_view("crew_base_kpis", "crew", "base", "crew", "base"))
    return base


def _scoped_root():
    root = h.scoped_final_model()
    root["_vibe_scope"] = h.scoped_facts()
    return root


def test_a_scoped_install_on_its_base_drops_the_tables_and_views_of_renamed_or_dropped_products(monkeypatch):
    base = _base_with_dropped_view()
    monkeypatch.setattr(ah, "_vibe_scope_install_base_model", lambda *a, **k: ah._vibe_scope_model_root(base))
    spark = h.FakeSpark(h.base_physical_tables(), views=VIEWS)
    rec, result, plan = h.run_install(_scoped_root(), spark, base_match=True, widgets={"_schema_ownership": {"owned": OWNED}})
    assert result["error"] is None
    assert sorted(s for s in spark.statements if s.startswith("DROP TABLE")) == [
        "DROP TABLE IF EXISTS `skyline`.`crew`.`base`", "DROP TABLE IF EXISTS `skyline`.`crew`.`member`"]
    assert [s for s in spark.statements if s.startswith("DROP VIEW")] == ["DROP VIEW IF EXISTS `skyline`.`_metrics`.`crew_base_kpis`"]
    assert "skyline.flight.scheduled_flight" in spark.tables and "skyline.fleet.aircraft" in spark.tables


def test_a_failed_metric_view_is_removed_from_the_installed_model_json():
    store = {}
    spark = h.FakeSpark(h.base_physical_tables(), views=VIEWS)
    rec, result, plan = h.run_install(_scoped_root(), spark, failed_views=("crew_roster_kpis",), workspace=h.FakeWorkspace(store))
    assert result["error"] is None
    assert store, "the failed-view cleanup read _parsed_root before its later assignment (UnboundLocalError) and never wrote model.json"
    names = [mv["view_name"] for mv in next(iter(store.values()))["model"]["metric_views"]]
    assert names and "crew_roster_kpis" not in names


def test_a_fresh_scoped_install_drops_nothing(monkeypatch):
    monkeypatch.setattr(ah, "_vibe_scope_install_base_model", lambda *a, **k: pytest.fail("a fresh install reads no base model"))
    spark = h.FakeSpark(h.base_physical_tables(), views=VIEWS)
    rec, result, plan = h.run_install(_scoped_root(), spark)
    assert result["error"] is None
    assert not [s for s in spark.statements if s.startswith(("DROP TABLE", "DROP VIEW", "DROP SCHEMA"))]


class _Rows:
    def __init__(self, rows):
        self.rows = rows
        self.queries = []

    def sql(self, query):
        self.queries.append(query)
        return types.SimpleNamespace(collect=lambda: self.rows)


def test_the_install_reads_the_base_model_from_its_registry_location(tmp_path):
    folder = tmp_path / "v1" / "mvm"
    folder.mkdir(parents=True)
    (folder / "model.json").write_text(json.dumps(h.base_model()))
    spark = _Rows([types.SimpleNamespace(location=str(folder))])
    root = ah._vibe_scope_install_base_model(spark, "skyline", "Skyline Air", {"_vibe_scope": {"base_version": "1"}}, "mvm")
    assert [d["name"] for d in root["domains"]] == [d["name"] for d in h.base_model()["model"]["domains"]]
    assert "version = '1'" in spark.queries[0] and "model_scope = 'mvm'" in spark.queries[0]
    missing = _Rows([types.SimpleNamespace(location=str(tmp_path / "nowhere"))])
    assert ah._vibe_scope_install_base_model(missing, "skyline", "Skyline Air", {"_vibe_scope": {"base_version": "1"}}, "mvm") is None
    assert ah._vibe_scope_install_base_model(spark, "skyline", "Skyline Air", {"_vibe_scope": {}}, "mvm") is None


def test_the_scoped_artifact_carries_the_drops_for_the_installer(monkeypatch):
    base = _base_with_dropped_view()
    ah.set_vibe_scope_runtime(ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "crew"), base, h.VOV, h.LOG))
    spark = h.FakeSpark(h.base_physical_tables(), views=VIEWS)
    wv = h.flat_widgets(_scoped_root(), spark=spark, facts=h.scoped_facts(), dry_run=True, statement_model=base)
    res = h.run_deploy_steps(wv, spark, _scoped_root(), lambda name, value: monkeypatch.setitem(ah.__dict__, name, value))
    files = {Path(p).name: t for p, t in res["artifacts"].items()}
    removed = files["skyline_air_vibe_scope_removed_v2_mvm.sql"]
    assert "EXECUTION ORDER: run this file LAST" in removed
    assert ah.parse_sql_statements(removed) == ["DROP TABLE IF EXISTS `skyline`.`crew`.`base`", "DROP TABLE IF EXISTS `skyline`.`crew`.`member`",
                                                "DROP VIEW IF EXISTS `skyline`.`_metrics`.`crew_base_kpis`"]
    assert not [s for s in res["statements"] if s.startswith(("DROP TABLE", "DROP VIEW"))]


def test_a_removed_product_the_model_still_references_is_not_dropped_by_the_artifact():
    base = _base_with_dropped_view()
    final = _scoped_root()
    sched = next(p for d in final["model"]["domains"] if d["name"] == "flight" for p in d["products"] if p["name"] == "scheduled_flight")
    sched["attributes"].append({"name": "home_base_id", "type": "BIGINT", "foreign_key_to": "crew.base.base_id"})
    plan = ah._scope_deploy_plan(h.scoped_facts(), final, h.LOG, use_runtime=False)
    resolver = ah.CatalogResolver(style="one_catalog", base_catalog=h.CATALOG, naming_convention="snake_case")
    stmts = ah._vibe_scope_removed_statements(plan, resolver, base, final, h.CATALOG)
    assert "DROP TABLE IF EXISTS `skyline`.`crew`.`member`;" in stmts
    assert not [s for s in stmts if "`crew`.`base`" in s and s.startswith("DROP TABLE")]


def _result(outcomes, vreqs):
    return types.SimpleNamespace(outcomes=outcomes, raw_vreqs=vreqs)


def test_the_engine_outcomes_reach_the_verification_sweep_log():
    vreq = ah.RawVREQ(vreq_id="VREQ-0001", intent="Rename the column dispatch_channel in finance.delivery_channel to send_channel",
                      target="finance.delivery_channel", source_quote="", source_chunk_id="c1")
    outcome = types.SimpleNamespace(batch_id="b1", vreq_ids=["VREQ-0001"], status="applied")
    wv = {}
    ah._vov_record_engine_actions(wv, _result([outcome], [vreq]))
    log = ah._build_execution_log(wv["_vibe_actions_executed_log"])
    assert log != "(no actions logged)", "live R26 to R29: the sweep saw no actions after the engine applied every requirement"
    assert "vov_engine scope=finance.delivery_channel" in log and "→ applied" in log


ROWS = ([{"domain": "finance", "description": ""}],
        [{"domain": "finance", "product": "delivery_channel", "primary_key": "delivery_channel_id"}],
        [{"domain": "finance", "product": "delivery_channel", "attribute": "delivery_channel_id"},
         {"domain": "finance", "product": "delivery_channel", "attribute": "send_channel"}])


@pytest.mark.parametrize("action", [
    {"action": "rename", "scope": "finance.delivery_channel.dispatch_channel", "name": "rename_dispatch_channel_to_send_channel",
     "target_state": "Column dispatch_channel in product finance.delivery_channel is renamed to send_channel, keeping its type"},
    {"action": "rename", "scope": "attribute", "name": "finance.delivery_channel.dispatch_channel",
     "target_state": "Column renamed from dispatch_channel to send_channel in finance.delivery_channel."},
])
def test_a_corrective_for_a_rename_that_landed_is_skipped(action):
    ah._vibe_scope_note_rename("attribute", "finance.delivery_channel.dispatch_channel", "finance.delivery_channel.send_channel", "VREQ-0001")
    assert ah._vibe_corrective_already_landed(action, *ROWS), "live R28 923117901254702 re-ran this rename through the LLM fallback"


def test_a_corrective_for_a_rename_that_did_not_land_still_runs():
    action = {"action": "rename", "scope": "attribute", "name": "finance.delivery_channel.dispatch_channel", "target_state": "send_channel"}
    assert not ah._vibe_corrective_already_landed(action, *ROWS)
    ah._vibe_scope_note_rename("attribute", "finance.delivery_channel.other_col", "finance.delivery_channel.send_channel", "VREQ-0002")
    assert not ah._vibe_corrective_already_landed(action, *ROWS)
    assert not ah._vibe_corrective_already_landed({"action": "add", "scope": "attribute", "name": "finance.delivery_channel.x"}, *ROWS)


def _tiny(fk):
    return {"model": {"domains": [
        {"name": "a", "products": [
            {"name": "p", "primary_key": "p_id", "attributes": [{"name": "p_id", "type": "BIGINT", "tags": "primary_key"}]},
            {"name": "q", "primary_key": "q_id", "attributes": [{"name": "q_id", "type": "BIGINT", "tags": "primary_key"},
                                                                  {"name": "p_ref", "type": "BIGINT", "foreign_key_to": fk}]}]},
        {"name": "b", "products": [
            {"name": "r", "primary_key": "r_id", "attributes": [{"name": "r_id", "type": "BIGINT", "tags": "primary_key"}]}]}],
        "metric_views": []}}


def test_an_fk_re_point_is_one_fk_entry_not_an_attribute_change():
    changed = [e for e in ah.vov_entity_changes(_tiny("a.p.p_id"), _tiny("b.r.r_id"), {"operation": h.VOV})["entries"]
               if e["status"] != "unchanged"]
    assert [(e["kind"], e["status"], e["path"]) for e in changed] == [("product", "modified", "a.q"), ("fk", "modified", "a.q.p_ref")], (
        "live R31 651583018997610 listed 54 FK re-points twice, once as an attribute change with no field")


def test_renamed_from_phrasing_parses():
    assert ah._v337_extract_col_rename("Column renamed from invoice_channel to dispatch_channel in finance.delivery_channel.") == (
        "invoice_channel", "dispatch_channel")
