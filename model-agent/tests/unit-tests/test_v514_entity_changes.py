"""v5.1.4 K4: model.json `entity_changes`, a per-entity change map against the base version.

Written for every "vibe modeling of version" run, scoped or not, right after `_vibe_scope`. Each entry
covers a domain, subdomain, product, attribute, FK or metric view with a status (unchanged, modified,
renamed, moved, dropped, added, restored, merged, split) and its causes (VREQ ids, feedback item ids from
`_vibe_input_map`, P1-P5 kinds, pass labels). It reuses the fence index/digest code and the one rename
ledger. Behavioral tests run on the real airlines v1 model.json and fail on 56ce1eb (no entity_changes).
"""
import copy
import json
import logging
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
from notebook_source_util import notebook_concat_source  # noqa: E402

REPO = Path(__file__).resolve().parents[3]
RAW = json.loads((REPO / "data-models" / "airlines" / "v1" / "mvm" / "model.json").read_text())
VOV = "vibe modeling of version"
LOG = logging.getLogger("test_v514_entity_changes")


@pytest.fixture(autouse=True)
def _reset():
    ah.set_vibe_scope_runtime(None)
    yield
    ah.set_vibe_scope_runtime(None)


def _domain(root, name):
    return next(d for d in root["model"]["domains"] if d["name"] == name)


def _product(root, domain, name):
    return next(p for p in _domain(root, domain)["products"] if p["name"] == name)


def _entry(changes, kind, path=None, base_path=None):
    hits = [e for e in changes["entries"] if e["kind"] == kind and (path is None or e["path"] == path)
            and (base_path is None or e["base_path"] == base_path)]
    assert len(hits) == 1, (kind, path, base_path, hits)
    return hits[0]


def _widgets(**extra):
    wv = {"operation": VOV,
          "_vov_2_pipeline_result": {"outcomes": [{"status": "applied", "vreq_ids": ["VREQ-0001"], "target_entities": [["crew", "roster"]]}]},
          "_vov_2_raw_vreqs": [{"vreq_id": "VREQ-0001", "target": "crew.roster.approval_status"}],
          "_vibe_input_map": {"sha": "0" * 64, "chars": 42, "items": {"item-7": {"start": 0, "end": 42}},
                              "vreqs": {"VREQ-0001": {"item_ids": ["item-7"], "method": "exact", "merged_from": []}}}}
    wv.update(extra)
    return wv


def test_k4_unscoped_run_maps_every_change_with_its_cause():
    cur = copy.deepcopy(RAW)
    ah._v337_apply_rename_product(cur["model"], "crew", "member", "crew_member")
    crew = _domain(cur, "crew")
    crew["products"] = [p for p in crew["products"] if p["name"] != "licence"]
    ah._vov_record_change("drop", "crew", "licence", "engine:VREQ-0002")
    crew["products"].append({"name": "standby_pool", "primary_key": "standby_pool_id", "subdomain": "crew_records",
                             "attributes": [{"name": "standby_pool_id", "type": "BIGINT"}]})
    roster = _product(cur, "crew", "roster")
    next(a for a in roster["attributes"] if a["name"] == "approval_status")["type"] = "INT"
    roster["attributes"].append({"name": "backup_base_id", "type": "BIGINT", "foreign_key_to": "crew.base.base_id"})
    ah._vov_record_change("restore", "crew", "base", "pass:review_preservation_gate")
    mv = cur["model"]["metric_views"][0]
    mv["sql"] = mv["sql"] + "\n"
    changes = ah.vov_entity_changes(RAW, cur, _widgets())

    member = _entry(changes, "product", base_path="crew.member")
    assert (member["status"], member["path"]) == ("renamed", "crew.crew_member")
    pk = _entry(changes, "attribute", base_path="crew.member.member_id")
    assert (pk["status"], pk["path"]) == ("renamed", "crew.crew_member.crew_member_id")
    relink = _entry(changes, "fk", path="flight.dispatch_release.member_id")
    assert relink["status"] == "modified" and relink["base_target"] == "crew.member.member_id"
    assert relink["target"] == "crew.crew_member.crew_member_id"
    dropped = _entry(changes, "product", base_path="crew.licence")
    assert dropped["status"] == "dropped" and dropped["cause"] == ["engine:VREQ-0002"]
    assert _entry(changes, "product", path="crew.standby_pool")["status"] == "added"
    rost = _entry(changes, "product", path="crew.roster")
    assert rost["status"] == "modified" and {"VREQ-0001", "fb:item-7"} <= set(rost["cause"])
    status_attr = _entry(changes, "attribute", path="crew.roster.approval_status")
    assert status_attr["status"] == "modified" and status_attr["fields"] == ["type"] and "VREQ-0001" in status_attr["cause"]
    assert _entry(changes, "attribute", path="crew.roster.backup_base_id")["status"] == "added"
    assert _entry(changes, "fk", path="crew.roster.backup_base_id")["target"] == "crew.base.base_id"
    base = _entry(changes, "product", path="crew.base")
    assert base["status"] == "restored" and base["cause"] == ["pass:review_preservation_gate"]
    assert _entry(changes, "product", path="crew.pairing") == {"kind": "product", "status": "unchanged", "path": "crew.pairing",
                                                              "base_path": "crew.pairing", "cause": []}
    assert _entry(changes, "domain", path="crew")["status"] == "unchanged"
    assert _entry(changes, "metric_view", path=mv["view_name"])["status"] == "modified"
    assert sum(changes["counts"]["product"].values()) == 205 + 1
    assert not [e for e in changes["entries"] if e["kind"] in ("attribute", "fk") and e["status"] == "unchanged"]
    assert {e["status"] for e in changes["entries"]} <= {"unchanged", "modified", "renamed", "moved", "dropped", "added", "restored", "merged", "split"}


def test_k4_merge_split_move_and_unrecorded_rename_are_classified():
    cur = copy.deepcopy(RAW)
    crew = _domain(cur, "crew")
    crew["products"] = [p for p in crew["products"] if p["name"] != "licence"]
    for d in cur["model"]["domains"]:
        for p in d["products"]:
            for a in p["attributes"]:
                if str(a.get("foreign_key_to") or "").startswith("crew.licence."):
                    a["foreign_key_to"] = "crew.medical_certificate.medical_certificate_id"
    absence = _product(cur, "crew", "absence")
    moved = [a for a in absence["attributes"] if a["name"] in ("base_id", "cost_centre_id")]
    absence["attributes"] = [a for a in absence["attributes"] if a not in moved]
    crew["products"].append({"name": "absence_detail", "primary_key": "absence_detail_id", "subdomain": "compliance_training",
                             "attributes": [{"name": "absence_detail_id", "type": "BIGINT"}, {"name": "absence_id", "type": "BIGINT"}] + moved})
    roster = _product(cur, "crew", "roster")
    roster["name"] = "crew_roster"
    ah._v337_apply_move_product(cur["model"], "crew", "pairing", "flight")
    changes = ah.vov_entity_changes(RAW, cur, {"operation": VOV})
    merged = _entry(changes, "product", base_path="crew.licence")
    assert (merged["status"], merged["path"]) == ("merged", "crew.medical_certificate")
    split = _entry(changes, "product", base_path="crew.absence")
    assert split["status"] == "split" and split["target"] == ["crew.absence_detail"]
    child = _entry(changes, "product", path="crew.absence_detail")
    assert child["status"] == "added" and "split_of:crew.absence" in child["cause"]
    inferred = _entry(changes, "product", base_path="crew.roster")
    assert (inferred["status"], inferred["path"], inferred["cause"]) == ("renamed", "crew.crew_roster", ["inferred:attribute_overlap"])
    move = _entry(changes, "product", base_path="crew.pairing")
    assert (move["status"], move["path"]) == ("moved", "flight.pairing")
    assert not [e for e in changes["entries"] if e["kind"] == "product" and e["status"] == "added" and e["path"] in ("crew.crew_roster", "flight.pairing")]


def test_k4_scoped_run_reads_the_fence_base_and_reports_p_kinds():
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "crew"), RAW, VOV, LOG)
    ah.set_vibe_scope_runtime(fence)
    cur = copy.deepcopy(RAW)
    ah._v337_apply_rename_product(cur["model"], "crew", "member", "crew_member")
    fence.splice_and_verify(cur, LOG)
    changes = ah._vov_entity_changes_for_run(cur["model"], {"operation": VOV, "base_version_for_review": "1"}, LOG)
    assert changes["base_version"] == "1"
    relink = _entry(changes, "fk", path="flight.dispatch_release.member_id")
    assert relink["status"] == "modified" and "P1" in relink["cause"]
    assert _entry(changes, "product", path="flight.dispatch_release")["status"] == "modified"
    assert _entry(changes, "product", base_path="crew.member")["status"] == "renamed"


def test_k4_is_written_only_for_vibe_modeling_of_version_and_tolerates_a_missing_input_map():
    assert ah._vov_entity_changes_for_run(RAW["model"], {"operation": "new base model"}, LOG) is None
    wv = {"operation": VOV, "business_context_raw": copy.deepcopy(RAW), "_vibe_input_map": {"items": {}, "vreqs": "not-a-dict"}}
    changes = ah._vov_entity_changes_for_run(copy.deepcopy(RAW["model"]), wv, LOG)
    assert changes["counts"]["product"] == {"unchanged": 205} and changes["counts"]["domain"] == {"unchanged": 15}
    assert set(changes["counts"]) == {"domain", "product", "subdomain", "metric_view"}
    assert ah._vov_entity_changes_for_run(RAW["model"], {"operation": VOV}, LOG) is None


def test_k4_entity_changes_sits_right_after_vibe_scope_in_model_json():
    src = notebook_concat_source()
    i = src.index('**({"_vibe_scope": _vs_facts} if _vs_facts is not None else {}),')
    j = src.index('**({"entity_changes": _entity_changes} if _entity_changes is not None else {}),', i)
    k = src.index('"model_requirements": model_requirements,', i)
    assert i < j < k and src[i:j].count("\n") == 1
