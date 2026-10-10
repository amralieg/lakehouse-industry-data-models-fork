"""v5.2.2: restructuring requirements land in an unscoped strict VOV, and a scoped install of a Dry Run lands on its base.

Live R10 53995095148222 (5.2.0, advertising v3 -> v4) asked for a product rename, a domain rename, a domain merge, a
two-product move and a description edit. The domain rename failed on every attempt and the merge was reported
applied although the project domain was untouched:
- "Rename the domain vendor to partner" parsed as a rename of a domain named "the";
- "Merge the domain project into client" did not parse at all;
- a domain rename or merge produced no rename pair, so the fence saw the follow-up FK retargets as frozen changes,
  and diff_within_summary_scope rejected the removed domain;
- the rename postcondition had no domain branch, so nothing caught the merge that never happened.

Live R7b 336135601582356 (5.2.1) installed the scoped Dry Run v6 on its installed base v5: the full-install clash
guard refused the four existing schemas, and the failed install left v6 registered as installed.
"""
import copy
import sys
import types
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402


def _attr(name, fk=""):
    return {"name": name, "type": "BIGINT" if name.endswith("_id") else "STRING", "foreign_key_to": fk}


def _model():
    return {"model": {"domains": [
        {"name": "vendor", "products": [
            {"name": "supplier", "primary_key": "supplier_id", "attributes": [_attr("supplier_id"), _attr("supplier_name")]},
            {"name": "publisher", "primary_key": "publisher_id", "attributes": [_attr("publisher_id"), _attr("supplier_id", "vendor.supplier.supplier_id")]},
        ]},
        {"name": "campaign", "products": [
            {"name": "ad", "primary_key": "ad_id", "attributes": [_attr("ad_id"), _attr("supplier_id", "vendor.supplier.supplier_id")]},
        ]},
        {"name": "performance", "products": [
            {"name": "tracking_pixel", "primary_key": "tracking_pixel_id", "attributes": [_attr("tracking_pixel_id"), _attr("ad_id", "campaign.ad.ad_id")]},
            {"name": "attribution_model", "primary_key": "attribution_model_id", "attributes": [_attr("attribution_model_id")]},
        ]},
        {"name": "media", "products": [
            {"name": "placement", "primary_key": "placement_id", "attributes": [_attr("placement_id")]},
        ]},
    ]}}


def _vreq(target, text):
    return types.SimpleNamespace(vreq_id="VREQ-0001", target=target, intent=text, source_quote=text)


@pytest.mark.parametrize("text,expected", [
    ("[vendor] Rename the domain vendor to partner.", ("vendor", "partner")),
    ("Rename the vendor domain to partner", ("vendor", "partner")),
    ("rename domain `vendor` to `partner`", ("vendor", "partner")),
    ("In the vendor domain, rename the domain to partner", None),
])
def test_a_domain_rename_never_reads_an_article_as_the_domain(text, expected):
    assert ah._v337_extract_domain_rename(text) == expected


@pytest.mark.parametrize("text,expected", [
    ("[project] Merge the domain project into client, so every project product now belongs to client.", ("project", "client")),
    ("merge domain project into the client domain", ("project", "client")),
    ("Merge the project domain into client", ("project", "client")),
    ("Fold project into client domain", ("project", "client")),
    ("Merge the domain into the client domain", None),
])
def test_merge_the_domain_x_into_y_parses(text, expected):
    assert ah._v337_extract_domain_merge(text) == expected


def test_domain_renames_and_merges_produce_a_pending_rename_pair():
    model = _model()
    rename = _vreq("vendor", "[vendor] Rename the domain vendor to partner.")
    merge = _vreq("vendor", "Merge the domain vendor into media, so every vendor product now belongs to media.")
    assert ah._v413_vreq_to_det_op(rename, model) == ("rename_domain", "vendor", "partner")
    assert ah._vov_rename_pairs_for_vreqs([rename, merge], model) == [("domain", "vendor", "partner"), ("domain", "vendor", "media")]
    assert ah._vov_pairs_touching([("domain", "vendor", "partner")], [("vendor", "*")]) == [("domain", "vendor", "partner")]
    assert ah._vov_pairs_touching([("domain", "vendor", "partner")], [("vendor", "supplier")]) == [("domain", "vendor", "partner")]
    assert ah._vov_pairs_touching([("domain", "vendor", "partner")], [("campaign", "ad")]) == []


def test_the_fence_resolves_fk_retargets_through_a_pending_domain_rename():
    events = [ah._vov_rename_event("domain", "vendor", "partner", "pending")]
    assert ("partner", "supplier", "supplier_id") in ah._vov_resolve_rename_candidates("vendor", "supplier", "supplier_id", events)


@pytest.mark.parametrize("text,expected", [
    ("Move the products tracking_pixel and attribution_model from the performance domain to the media domain.", ("move_product", "performance", "tracking_pixel", "media")),
    ("Move the product tracking_pixel to the media domain", ("move_product", "performance", "tracking_pixel", "media")),
    ("Move the column ad_id of tracking_pixel to the media domain", None),
    ("Move the product tracking_pixel to the nowhere domain", None),
    ("Rewrite the description of tracking_pixel", None),
])
def test_a_free_text_move_of_a_named_product_is_deterministic(text, expected):
    assert ah._v337_classify_op("", "performance.tracking_pixel", text, "", _model()) == expected


def _renamed(model, lose=False, stale_fk=False):
    out = copy.deepcopy(model)
    vendor = next(d for d in out["model"]["domains"] if d["name"] == "vendor")
    vendor["name"] = "partner"
    if lose:
        vendor["products"].pop()
    for d in out["model"]["domains"]:
        for p in d["products"]:
            for a in p["attributes"]:
                if a["foreign_key_to"].startswith("vendor.") and not stale_fk:
                    a["foreign_key_to"] = "partner." + a["foreign_key_to"].split(".", 1)[1]
    return out


def test_the_rename_postcondition_checks_a_domain_rename_and_its_products():
    before, pair = _model(), [("domain", "vendor", "partner")]
    assert ah._vov_rename_postcondition(before, _renamed(before), pair) == (True, "")
    ok, diag = ah._vov_rename_postcondition(before, _renamed(before, lose=True), pair)
    assert not ok and "1 product(s) of vendor did not reach partner" in diag
    ok, diag = ah._vov_rename_postcondition(before, _renamed(before, stale_fk=True), pair)
    assert not ok and "foreign_key_to still point into domain vendor" in diag
    ok, diag = ah._vov_rename_postcondition(before, before, pair)
    assert not ok and "domain vendor still exists next to partner" in diag and "domain partner is missing" in diag


def test_the_scope_guard_accepts_a_rehomed_domain_and_rejects_a_lossy_one():
    before = _model()
    diff = ah.diff_models_summary(before, _renamed(before))
    assert diff["products_in_removed_domains"] == [("vendor", "publisher"), ("vendor", "supplier")]
    assert diff["products_in_added_domains"] == [("partner", "publisher"), ("partner", "supplier")]
    assert ah.diff_within_summary_scope(diff, "Renames the domain vendor to partner in place", ["partner"]) == (True, "")
    ok, diag = ah.diff_within_summary_scope(ah.diff_models_summary(before, _renamed(before, lose=True)), "Renames the domain vendor to partner", ["partner"])
    assert not ok and "domains_removed=['vendor']" in diag
    ok, diag = ah.diff_within_summary_scope(diff, "Renames a domain in place", ["partner"])
    assert not ok and "domains_removed=['vendor']" in diag


def test_the_serialized_ledger_keeps_only_events_that_landed():
    renames = [{"kind": "domain", "old": "vendor", "new": "partner"},
               {"kind": "domain", "old": "project", "new": "client"},
               {"kind": "product", "old": "campaign.ad", "new": "campaign.advert"},
               {"kind": "attribute", "old": "campaign.ad.ad_name", "new": "campaign.ad.ad_id"}]
    changes = [{"kind": "drop", "path": "vendor.supplier", "cause": "corrective:rename:vendor"},
               {"kind": "drop", "path": "performance.gone", "cause": "VREQ-1"},
               {"kind": "create", "path": "media.placement", "cause": "VREQ-2"},
               {"kind": "create", "path": "media.never_made", "cause": "VREQ-3"}]
    landed, kept = ah._vov_landed_events(renames, changes, _renamed(_model()))
    assert landed == [renames[0], renames[3]]
    assert kept == [changes[0], changes[1], changes[2]]
    landed, kept = ah._vov_landed_events(renames, changes, _model())
    assert landed == [renames[3]], "a rename the run reverted is not reported"
    assert kept == [changes[1], changes[2]], "a drop the run reverted is not reported"


class _Rows:
    def __init__(self, rows):
        self.rows = rows

    def collect(self):
        return self.rows


class _Spark:
    def __init__(self, status_rows):
        self.status_rows, self.sql_seen = status_rows, []

    def sql(self, statement):
        self.sql_seen.append(statement)
        if statement.startswith("SELECT deploy_status"):
            return _Rows(self.status_rows)
        if statement.startswith("SHOW SCHEMAS"):
            return _Rows([("customer",), ("order",)])
        return _Rows([])


class _Log:
    def __init__(self):
        self.lines = []

    def info(self, msg, *a, **k):
        self.lines.append(str(msg))

    warning = error = debug = info


@pytest.mark.parametrize("rows,expected", [([], None), ([("dry_run",)], "dry_run"), ([(None,)], "")])
def test_the_registry_status_before_an_install_is_read(rows, expected):
    assert ah._registry_deploy_status(_Spark(rows), "cat", "vs514 retail", "6", "mvm") == expected


@pytest.mark.parametrize("prior,statement", [
    (None, "DELETE FROM `cat`.`_metamodel`.`business`"),
    ("dry_run", "UPDATE `cat`.`_metamodel`.`business` SET deploy_status = 'dry_run'"),
    ("", "UPDATE `cat`.`_metamodel`.`business` SET deploy_status = NULL"),
])
def test_a_failed_install_reverts_its_registry_row(prior, statement):
    spark, log = _Spark([]), _Log()
    assert ah._registry_undo_failed_install(spark, "cat", "vs514 retail", "6", "mvm", prior, log) is True
    assert any(s.startswith(statement) for s in spark.sql_seen), spark.sql_seen
    assert any("install-registry-undo FIRED v5.2.2" in m for m in log.lines)
    if prior is None:
        assert [s.split("`")[5] for s in spark.sql_seen] == ["attribute", "product", "domain", "business"]


def test_an_unknown_prior_status_is_reported_not_guessed():
    spark, log = _Spark([]), _Log()
    assert ah._registry_undo_failed_install(spark, "cat", "vs514 retail", "6", "mvm", "unknown", log) is False
    assert spark.sql_seen == [] and any("could not be reverted" in m for m in log.lines)


def _snap(owned, foreign=()):
    return {"business": "vs514 retail", "target": "cat", "style": "one_catalog", "owned": {k: ["v5"] for k in owned},
            "foreign": {k: ["other"] for k in foreign}, "owned_catalogs": [], "foreign_catalogs": [], "metamodel": "cat._metamodel", "error": None}


def test_a_scoped_install_on_its_owned_base_passes_the_clash_check():
    log = _Log()
    wv = {"_schema_ownership": _snap(["cat.customer", "cat.order"]), "_scoped_install_base": True, "operation": "install model"}
    ah._check_physical_deployment_clash(_Spark([]), [("cat", "customer"), ("cat", "order")], wv, logger=log)
    assert any("scoped-install-clash FIRED v5.2.2" in m for m in log.lines)


def test_a_scoped_install_still_refuses_a_schema_another_business_owns():
    wv = {"_schema_ownership": _snap(["cat.customer"], ["cat.order"]), "_scoped_install_base": True, "operation": "install model"}
    with pytest.raises(ValueError, match="SCHEMA OWNERSHIP CLASH"):
        ah._check_physical_deployment_clash(_Spark([]), [("cat", "customer"), ("cat", "order")], wv, logger=_Log())


def test_a_full_install_over_existing_schemas_is_still_refused():
    with pytest.raises(ValueError, match="PHYSICAL DEPLOYMENT CLASH"):
        ah._check_physical_deployment_clash(_Spark([]), [("cat", "customer")], {"operation": "install model"}, logger=_Log())


def _mv(view, dom, prod, body):
    return {"view_name": view, "owner_domain": dom, "owner_product": prod,
            "sql": f"CREATE OR REPLACE VIEW `cat`.`_metrics`.`{view}`\nWITH METRICS\nLANGUAGE YAML\nAS $$\n{body}\n$$"}


def _model_with_views():
    model = _model()
    model["model"]["metric_views"] = [
        _mv("vendor_publisher", "vendor", "publisher", '  source: "`cat`.`vendor`.`publisher`"\n  joins:\n    - name: s\n      source: "`cat`.`vendor`.`supplier`"\n      on: source.supplier_id = s.supplier_id'),
        _mv("campaign_ad", "campaign", "ad", '  source: "`cat`.`campaign`.`ad`"\n  dimensions:\n    - name: "ad"\n      expr: ad_id'),
        _mv("performance_tracking_pixel", "performance", "tracking_pixel", '  source: "`cat`.`performance`.`tracking_pixel`"\n  joins:\n    - name: a\n      source: "`cat`.`campaign`.`ad`"\n      on: source.ad_id = a.ad_id'),
    ]
    return model


def _view(model, name):
    return next(mv for mv in model["model"]["metric_views"] if mv["view_name"] == name)


def test_a_domain_rename_carries_its_metric_views():
    model = _model_with_views()
    assert ah._v337_apply_rename_domain(model["model"], "vendor", "partner") is not None
    mv = _view(model, "vendor_publisher")
    assert (mv["owner_domain"], mv["owner_product"]) == ("partner", "publisher")
    assert "`cat`.`partner`.`publisher`" in mv["sql"] and "`cat`.`partner`.`supplier`" in mv["sql"] and "`vendor`" not in mv["sql"]
    assert _view(model, "campaign_ad")["sql"] == _view(_model_with_views(), "campaign_ad")["sql"]


def test_a_domain_merge_carries_its_metric_views():
    model = _model_with_views()
    assert ah._v337_apply_merge_domain(model["model"], "vendor", "media") is not None
    mv = _view(model, "vendor_publisher")
    assert (mv["owner_domain"], mv["owner_product"]) == ("media", "publisher")
    assert "`cat`.`media`.`publisher`" in mv["sql"] and "`cat`.`media`.`supplier`" in mv["sql"]


def test_a_product_move_carries_its_metric_view():
    model = _model_with_views()
    assert ah._v337_apply_move_product(model["model"], "performance", "tracking_pixel", "media") is not None
    mv = _view(model, "performance_tracking_pixel")
    assert (mv["owner_domain"], mv["owner_product"]) == ("media", "tracking_pixel")
    assert "`cat`.`media`.`tracking_pixel`" in mv["sql"] and "`cat`.`campaign`.`ad`" in mv["sql"]


def test_a_product_rename_carries_its_views_and_the_renamed_key():
    model = _model_with_views()
    assert ah._v337_apply_rename_product(model["model"], "campaign", "ad", "advert") is not None
    own, joined = _view(model, "campaign_ad"), _view(model, "performance_tracking_pixel")
    assert (own["owner_domain"], own["owner_product"]) == ("campaign", "advert")
    assert "`cat`.`campaign`.`advert`" in own["sql"] and "expr: advert_id" in own["sql"]
    assert "`cat`.`campaign`.`advert`" in joined["sql"] and "a.advert_id" in joined["sql"] and "source.ad_id" in joined["sql"]


def test_an_attribute_rename_carries_the_column_into_metric_views():
    model = _model_with_views()
    assert ah._v337_apply_rename_attribute(model["model"], "campaign", "ad", "ad_id", "advert_key") is not None
    assert "expr: advert_key" in _view(model, "campaign_ad")["sql"]
    assert "a.advert_key" in _view(model, "performance_tracking_pixel")["sql"]


def test_a_frozen_metric_view_is_left_to_the_fence_p5():
    model = _model_with_views()
    spec = ah.parse_vibe_scope("Some Domains", "campaign")
    fence = ah.build_vibe_scope_fence(spec, model, "vibe modeling of version", _Log())
    ah.set_vibe_scope_runtime(fence)
    try:
        frozen_before = _view(model, "performance_tracking_pixel")["sql"]
        assert ah._v337_apply_rename_product(model["model"], "campaign", "ad", "advert") is not None
        assert _view(model, "performance_tracking_pixel")["sql"] == frozen_before
        assert "`cat`.`campaign`.`advert`" in _view(model, "campaign_ad")["sql"]
    finally:
        ah.set_vibe_scope_runtime(None)


def test_a_move_the_directive_expander_applies_leaves_the_llm_loop(monkeypatch):
    import test_v514_rename_integrity as RI
    text = "Move the product roster from the crew domain to the flight domain."
    vreq = ah.RawVREQ(vreq_id="VREQ-0001", intent=text, target="crew.roster", source_quote="- " + text, source_chunk_id="c1",
                      is_user_directive=True)
    monkeypatch.setitem(ah.__dict__, "extract_all", lambda *a, **k: [vreq])
    monkeypatch.setattr(ah, "logger", RI.LOG, raising=False)
    llm = RI._FakeLLM()
    result = ah.run_vov_pipeline("## crew\n- " + text + "\n", RI._engine(), llm, [], [], parallel=False, priority_reapply_loops=1)
    assert RI._has(result.final_model, "flight", "roster") and not RI._has(result.final_model, "crew", "roster")
    assert RI._statuses(result)["VREQ-0001"] == ["applied"]
    assert not [system for system, _user in llm.prompts if "group VREQs into BATCHES" in system]
