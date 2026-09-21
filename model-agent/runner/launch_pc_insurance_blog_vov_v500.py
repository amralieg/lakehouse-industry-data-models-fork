#!/usr/bin/env python3
"""Vibe-modeling-of-version (v1 -> v2) of the blog-aligned P&C ECM on agent v5.0.0.

Applies four surgical structural vibes to the completed v1 ECM in
`vibe_pc_insurance_blog_v499` and writes v2 ECM in the same catalog:

  1. claim_financials is NOT a top-level domain -> fold its products into `claim`
     as a subdomain.
  2. rename `claims` -> `claim`.
  3. rename `risk_exposure` -> `risk`.
  4. rename `catastrophe_geography` -> `catastrophe`.

Standard VoV (user choice 1B): the four vibes are supreme (§3c) and v1's
auto-generated next_vibes.txt (53 connect_table FK priorities) is merged in
underneath them. The agent re-points every FK that referenced an old domain name.
"""
import json
import os
import sys
import time
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vov_v2_marathon as M
# Reuse the ECM run's business_description verbatim (DRY): VoV must preserve the same
# business intent. Importing the ECM launcher sets M.* as a side effect, so the VoV
# M globals below are re-asserted AFTER this import to win.
import launch_pc_insurance_blog_v499 as ECM

PROFILE = "my-uae"
# v500 = 5.0.0 (adds shrink-domains-from-survivors guard + #41 width + #43 max_workers).
AGENT_PATH = "/Users/user@example.com/dbx_vibe_modelling_agent_v500"
CATALOG = "vibe_pc_insurance_blog_v499"
BUSINESS = "pc_insurance"
BUDGET_S = 16200          # 4.5h - VoV refines 226 products + applies 4 vibes + 53 auto priorities
JOB_TIMEOUT_S = 18000     # 5h outer job timeout
STALL_EMPTY_INFO_S = 2400

# Post-rename target domains for §3b protection: claims->claim (absorbs claim_financials
# as a subdomain), risk_exposure->risk, catastrophe_geography->catastrophe. claim_financials
# is intentionally ABSENT (it becomes a subdomain of claim, not a top-level domain).
DOMAINS = ("party, underwriting, policy, coverage, risk, premium, billing, "
           "claim, producers, reinsurance, catastrophe")

VOV_VIBES = (
    "Apply these FOUR structural changes to the existing v1 model. These are surgical "
    "RENAMES and one MERGE: preserve every product, attribute, and foreign key. Do NOT "
    "create empty domains and do NOT drop any product or data.\n\n"
    "1. `claim_financials` is NOT a top-level domain, it is a SUBDOMAIN of claims. Move "
    "every product currently in the `claim_financials` domain into the `claim` domain "
    "(see change 2) and mark them with subdomain `claim_financials`. After this change "
    "there must be NO top-level `claim_financials` domain anywhere in the model.\n\n"
    "2. RENAME the `claims` domain to `claim`. Keep all of its existing products and "
    "foreign keys; the claim_financials products from change 1 join it as a subdomain.\n\n"
    "3. RENAME the `risk_exposure` domain to `risk`. Keep all of its products and "
    "foreign keys.\n\n"
    "4. RENAME the `catastrophe_geography` domain to `catastrophe`. Keep all of its "
    "products and foreign keys.\n\n"
    "Re-point every foreign key that referenced the old domain names "
    "(claims, claim_financials, risk_exposure, catastrophe_geography) to the new names. "
    "Leave all other domains (party, underwriting, policy, coverage, premium, billing, "
    "reinsurance, producers, shared) unchanged."
)

M.AGENT_PATH = AGENT_PATH
M.PULSE_FILE = os.path.expanduser("~/claude/vibe-agent/pc_insurance_blog_vov_v500_pulses.txt")
M.STATE_FILE = os.path.expanduser("~/claude/vibe-agent/pc_insurance_blog_vov_v500_state.json")
M.KILL_FILE = os.path.expanduser("~/claude/vibe-agent/pc_insurance_blog_vov_v500_KILL")
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
        "name": "dbx_vibe_pc_insurance_blog_v499_vov",
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
            Path("/tmp/pc_blog_vov_v500_jobpatch.json").write_text(
                json.dumps({"job_id": job["job_id"], "new_settings": spec}))
            M.db(["jobs", "reset", "--json", "@/tmp/pc_blog_vov_v500_jobpatch.json"], PROFILE)
            return job["job_id"]
    Path("/tmp/pc_blog_vov_v500_jobspec.json").write_text(json.dumps(spec))
    return M.dbj(["jobs", "create", "--json", "@/tmp/pc_blog_vov_v500_jobspec.json"], PROFILE)["job_id"]


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
    M.pulse("=== P&C BLOG VoV v1->v2 v5.0.0 START catalog=%s agent=%s ===" % (CATALOG, AGENT_PATH))
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
    Path("/tmp/pc_blog_vov_v500_run.json").write_text(json.dumps(state, indent=2))
    info = wait_terminal(run_id)
    M.pulse("TERMINAL lc=%s result=%s url=%s"
            % (info["lc"], info.get("result"), info.get("url")))
    state.update(terminal=info)
    Path("/tmp/pc_blog_vov_v500_run.json").write_text(json.dumps(state, indent=2, default=str))


if __name__ == "__main__":
    main()
