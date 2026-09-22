#!/usr/bin/env python3
"""Clean vibe-modeling-of-version (v1 -> v2) of the blog-aligned P&C ECM on agent v5.0.3.

v5.0.3 carries four INDUSTRY-AGNOSTIC FK/rename fixes (v503-fk-type-inherit,
v503-fk-colname, v503-rename-persist, v503-fk-cycle-safe). This run is the live proof.

ONE combined VoV run (user choice: seq=a) applies, in order of authority (§3c):
  A. FOUR structural vibes (3 renames + 1 merge/fold).
  B. Underwriting rebalance: move the 23-product UW-lifecycle set coverage -> underwriting.
  C. FOUR design vibes (CAT hierarchy, grain sentences, enum->reference, pipe-enum->reference).

Every product/attribute/FK is preserved; renamed-domain FKs are re-pointed by the shared
engine (v503-rename-persist). The 23-product move list and design intents below are USER
VIBE INPUT (P&C-specific); the agent code stays industry-agnostic.
"""
import json
import os
import sys
import time
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vov_v2_marathon as M
import launch_pc_insurance_blog_v499 as ECM

PROFILE = "my-uae"
AGENT_NAME = "dbx_vibe_modelling_agent_v505"


def _resolve_agent_path():
    # Resolve the deployed notebook under the CURRENT workspace user's home. Keeps the
    # committed file free of any hardcoded identity (PII-hook clean, portable to ANY
    # workspace) while pointing the job at the real notebook at runtime.
    import subprocess
    out = subprocess.check_output(
        ["databricks", "current-user", "me", "--profile", PROFILE], text=True)
    user = json.loads(out).get("userName")
    if not user:
        raise RuntimeError("could not resolve workspace userName")
    return "/Users/%s/%s" % (user, AGENT_NAME)


AGENT_PATH = _resolve_agent_path()
CATALOG = "vibe_pc_insurance_blog_v499"
BUSINESS = "pc_insurance"
BUDGET_S = 19800          # 5.5h - renames+merge+23-product move+4 design vibes+enum promotions
JOB_TIMEOUT_S = 21600     # 6h outer job timeout
STALL_EMPTY_INFO_S = 2400

# Post-rename / post-merge §3b domain list (claimfinancials folded into claim as subdomain).
DOMAINS = ("party, underwriting, policy, coverage, risk, premium, billing, "
           "claim, producers, reinsurance, catastrophe")

# 23-product UW-lifecycle move set (coverage -> underwriting), confirmed by the user.
_UW_MOVE = (
    "submission, submission_party, submission_document, submission_status_history, "
    "uw_decision, uw_referral, uw_condition, risk_appetite_rule, eligibility_check, "
    "eligibility, underwriting_risk_score, underwriting_mvr_report, quote, quote_coverage, "
    "quote_option, rating_worksheet, rating_factor, rating_rule_set, loss_history, "
    "inspection_order, clearance_check, bind_request, binder"
)

VOV_VIBES = (
    "Apply the following changes to the existing v1 model. Group A (structural) and "
    "Group B (domain rebalance) are SURGICAL: preserve every product, attribute, and "
    "foreign key, and re-point FKs when a domain is renamed. Group C (design) is "
    "generative but must not drop existing data. Do NOT create empty domains.\n\n"

    "=== GROUP A — STRUCTURAL (highest priority) ===\n"
    "A1. `claimfinancials` (aka claim_financials) is NOT a top-level domain, it is a "
    "SUBDOMAIN of claims. Move every product in the `claimfinancials` domain into the "
    "`claim` domain (see A2) and mark them with subdomain `claim_financials`. After this "
    "there must be NO top-level `claimfinancials`/`claim_financials` domain.\n"
    "A2. RENAME the `claims` domain to `claim`. Keep all its products and FKs.\n"
    "A3. RENAME the `riskexposure` domain (aka risk_exposure) to `risk`. Keep all products/FKs.\n"
    "A4. RENAME the `catastrophegeography` domain (aka catastrophe_geography) to "
    "`catastrophe`. Keep all products/FKs.\n"
    "Re-point every foreign key that referenced the old domain names (claims, "
    "claimfinancials, riskexposure, catastrophegeography) to the new names.\n\n"

    "=== GROUP B — UNDERWRITING REBALANCE ===\n"
    "B1. The `coverage` domain is overloaded and the `underwriting` domain has only one "
    "product. MOVE the following underwriting-lifecycle products FROM the `coverage` "
    "domain INTO the `underwriting` domain, cascading their attributes and re-pointing "
    "every foreign key that references them: " + _UW_MOVE + ". "
    "Leave all remaining coverage-structure products (coverage, limit, deductible, "
    "exclusion, coverage_condition, coverage_form, part, coverage_endorsement, "
    "additional_interest, rate, coverage_type, coverage_peril, peril_link, "
    "coverage_interest, coverage_cession, type_peril, form_attachment, "
    "shared_limit_group, producer_coverage_authority, coverage_transaction, "
    "facultative_quotation, facultative_marketing) in `coverage`.\n\n"

    "=== GROUP C — DESIGN ===\n"
    "C1. CAT HIERARCHY: in the `catastrophe` domain, ensure a clean rollup hierarchy — "
    "catastrophe events roll up to CAT zones, which roll up to geographies/territories, "
    "and perils link to zones. Add any MISSING parent reference product and the FK links "
    "so every catastrophe level connects (no siloed CAT tables).\n"
    "C2. GRAIN SENTENCES: for every fact/transaction table (event, transaction, ledger, "
    "history, snapshot, and similar), append ONE sentence to its description stating its "
    "grain (e.g. 'Grain: one row per <business event> per <entity>.'). Do not change "
    "any columns.\n"
    "C3. ENUM->REFERENCE: every attribute whose description carries an "
    "`[ENUM-REF-CANDIDATE: ...]` marker must be promoted to a proper reference lookup. "
    "For each DISTINCT enumeration, create ONE SHARED reference product (data_type "
    "reference_data) with a BIGINT surrogate primary key and a name/code column, then "
    "re-point every consuming attribute to a foreign key to that reference product's PK "
    "and remove the marker. Reuse a single shared reference product across all consumers "
    "of the same enumeration — do NOT create a separate table per column.\n"
    "C4. PIPE-ENUM->REFERENCE: any attribute still carrying an oversized pipe-enum "
    "`value_regex` (more than 6 alternatives) must likewise be promoted to a shared "
    "reference product with a BIGINT PK and an FK from the consumer, clearing the "
    "value_regex.\n"
)

M.AGENT_PATH = AGENT_PATH
M.PULSE_FILE = os.path.expanduser("~/claude/vibe-agent/pc_insurance_blog_vov_v503_pulses.txt")
M.STATE_FILE = os.path.expanduser("~/claude/vibe-agent/pc_insurance_blog_vov_v503_state.json")
M.KILL_FILE = os.path.expanduser("~/claude/vibe-agent/pc_insurance_blog_vov_v503_KILL")
M.PULSE_S = 300
M._IND_PROFILE = {BUSINESS: PROFILE}
M.cat_name = lambda ind: CATALOG  # noqa: E731


def build_spec():
    params = {
        "operation": "vibe modeling of version",
        "business_name": BUSINESS,
        "business_description": ECM.DESC,
        "business_domains": DOMAINS,
        "org_divisions": "Operations, Business and Corporate",
        "model_vibes": VOV_VIBES,
        "data_model_scopes": "Expanded Coverage Model - ECM",
        "deployment_catalog": CATALOG,
        "model_version": "1",
        "runtime_budget_seconds": str(BUDGET_S),
        "cataloging_style": "One Catalog",
        "vibe_session_id": "{{job.run_id}}",
        "databricks_task_run_id": "{{task.run_id}}",
    }
    return {
        "name": "dbx_vibe_pc_insurance_blog_v499_vov_v503",
        "timeout_seconds": JOB_TIMEOUT_S,
        "max_concurrent_runs": 1,
        "max_retries": 0,
        "tasks": [{
            "task_key": "vov",
            "notebook_task": {"notebook_path": AGENT_PATH, "source": "WORKSPACE",
                              "base_parameters": params},
            "timeout_seconds": BUDGET_S,
            "max_retries": 0,
        }],
    }


def find_or_create_job(spec):
    jobs = M.dbj(["jobs", "list", "--limit", "100"], PROFILE)
    items = jobs if isinstance(jobs, list) else jobs.get("jobs", [])
    for job in items:
        if (job.get("settings", {}) or {}).get("name") == spec["name"]:
            Path("/tmp/pc_blog_vov_v503_jobpatch.json").write_text(
                json.dumps({"job_id": job["job_id"], "new_settings": spec}))
            M.db(["jobs", "reset", "--json", "@/tmp/pc_blog_vov_v503_jobpatch.json"], PROFILE)
            return job["job_id"]
    Path("/tmp/pc_blog_vov_v503_jobspec.json").write_text(json.dumps(spec))
    return M.dbj(["jobs", "create", "--json", "@/tmp/pc_blog_vov_v503_jobspec.json"], PROFILE)["job_id"]


def info_log_bytes():
    base = "dbfs:/Volumes/%s/_metamodel/vol_root/logs/%s/v2/ecm" % (CATALOG, BUSINESS)
    try:
        out = M.dbj(["fs", "ls", base], PROFILE, timeout=90)
        files = out if isinstance(out, list) else out.get("files", []) or []
        for entry in files:
            if "info" in (entry.get("name") or ""):
                return int(entry.get("file_size") or entry.get("size") or 0)
    except Exception:
        pass
    return None


def wait_terminal(run_id):
    started, last_pulse, empty_since = time.time(), 0, None
    while True:
        if os.path.exists(M.KILL_FILE):
            M.pulse("KILL file present — leaving run %s" % run_id)
            return {"lc": "ABORTED", "result": "KILLED"}
        try:
            info = M.get_run(PROFILE, run_id)
        except Exception as exc:
            M.pulse("poll err: %s" % str(exc)[:160])
            time.sleep(M.POLL_S)
            continue
        if info["lc"] in ("TERMINATED", "INTERNAL_ERROR", "SKIPPED"):
            return info
        task = next((t for t in info.get("tasks", []) if t.get("k") == "vov"), None)
        if task and task.get("lc") == "RUNNING":
            size = info_log_bytes()
            if not size:
                empty_since = empty_since or time.time()
                if time.time() - empty_since >= STALL_EMPTY_INFO_S:
                    M.pulse("STALL: info.log empty >%dm — canceling run %s"
                            % (STALL_EMPTY_INFO_S // 60, run_id))
                    M.db(["jobs", "cancel-run", str(run_id)], PROFILE)
                    return {"lc": "TERMINATED", "result": "CANCELED", "url": info.get("url"),
                            "tasks": info.get("tasks", [])}
            else:
                empty_since = None
        if time.time() - last_pulse >= M.PULSE_S:
            states = ", ".join("%s=%s/%s" % (t["k"], t["lc"] or "?", t["r"] or "-")
                               for t in info["tasks"])
            M.pulse("[%s] elapsed=%dm lc=%s [%s] info_bytes=%s"
                    % (BUSINESS, int((time.time() - started) / 60), info["lc"], states,
                       info_log_bytes()))
            last_pulse = time.time()
        time.sleep(M.POLL_S)


def main():
    Path(os.path.dirname(M.PULSE_FILE)).mkdir(parents=True, exist_ok=True)
    M.pulse("=== P&C BLOG VoV v1->v2 v5.0.3 START catalog=%s agent=%s ===" % (CATALOG, AGENT_PATH))
    job_id = find_or_create_job(build_spec())
    try:
        active = M.dbj(["jobs", "list-runs", "--job-id", str(job_id), "--active-only"], PROFILE)
        for run in (active if isinstance(active, list) else active.get("runs", [])):
            if run.get("run_id"):
                M.db(["jobs", "cancel-run", str(run["run_id"])], PROFILE)
    except Exception as exc:
        M.pulse("active-run cleanup skipped: %s" % exc)
    run_id = M.run_now(PROFILE, job_id)
    M.pulse("submitted job=%s run=%s" % (job_id, run_id))
    state = {"job_id": job_id, "run_id": run_id, "profile": PROFILE, "catalog": CATALOG}
    Path("/tmp/pc_blog_vov_v503_run.json").write_text(json.dumps(state, indent=2))
    info = wait_terminal(run_id)
    M.pulse("TERMINAL lc=%s result=%s url=%s"
            % (info["lc"], info.get("result"), info.get("url")))
    state.update(terminal=info)
    Path("/tmp/pc_blog_vov_v503_run.json").write_text(json.dumps(state, indent=2, default=str))


if __name__ == "__main__":
    main()
