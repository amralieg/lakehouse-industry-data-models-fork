#!/usr/bin/env python3
"""Shrink the VoV-produced v3 P&C ECM to v3 MVM on cleaned agent v5.0.2.

Reads the completed v3 ECM in `vibe_pc_insurance_blog_v499` (the good output of the
v501 VoV run: claims->claim with claim_financials folded in as a subdomain,
risk_exposure->risk, catastrophe_geography->catastrophe; 12 domains / 226 products /
1256 FKs / 0 dangling) and produces the MVM scope at the SAME version 3. This run is
also the live proof for the cleaned single-path agent v5.0.2 (v270 bypass lifted +
redundant structural intercept removed): the shrink exercises the same verification
sweep -> Layer-1 mutation engine that the fix touched.

The eleven renamed domains are the §3b SSOT; the shrink keeps the FK-densest survivor
products so the MVM stays a connected core.
"""
import json
import os
import sys
import time
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vov_v2_marathon as M
# Reuse the VoV run's post-rename domains (§3b SSOT) and the blog business intent
# (DESC/VIBES) verbatim (DRY). Importing the VoV launcher pulls in the ECM launcher too,
# so the shrink's own M globals below are re-asserted AFTER this import to win.
import launch_pc_insurance_blog_vov_v501 as VOV

PROFILE = "my-uae"
AGENT_PATH = "/Users/user@example.com/dbx_vibe_modelling_agent_v502"
CATALOG = "vibe_pc_insurance_blog_v499"
BUSINESS = "pc_insurance"
MODEL_VERSION = "3"       # read v3 ECM -> write v3 MVM
BUDGET_S = 10800          # 3h - shrink is lighter than a fresh ECM build
JOB_TIMEOUT_S = 12600     # 3.5h outer job timeout
STALL_EMPTY_INFO_S = 2400

M.AGENT_PATH = AGENT_PATH
M.PULSE_FILE = os.path.expanduser("~/claude/vibe-agent/pc_insurance_blog_vov_shrink_v502_pulses.txt")
M.STATE_FILE = os.path.expanduser("~/claude/vibe-agent/pc_insurance_blog_vov_shrink_v502_state.json")
M.KILL_FILE = os.path.expanduser("~/claude/vibe-agent/pc_insurance_blog_vov_shrink_v502_KILL")
M.PULSE_S = 300
M._IND_PROFILE = {BUSINESS: PROFILE}
M.cat_name = lambda ind: CATALOG  # noqa: E731


def build_spec():
    params = {
        "operation": "shrink ecm",
        "business_name": BUSINESS,
        "business_description": VOV.ECM.DESC,
        "business_domains": VOV.DOMAINS,          # post-rename names (claim/risk/catastrophe)
        "org_divisions": "Operations, Business and Corporate",
        "model_vibes": VOV.ECM.VIBES,             # blog design intent preserved through the shrink
        "data_model_scopes": "Minimum Viable Model - MVM",
        "deployment_catalog": CATALOG,
        "model_version": MODEL_VERSION,           # read v3 ECM -> write v3 MVM
        "runtime_budget_seconds": str(BUDGET_S),
        "cataloging_style": "One Catalog",
        "vibe_session_id": "{{job.run_id}}",
        "databricks_task_run_id": "{{task.run_id}}",
    }
    return {
        "name": "dbx_vibe_pc_insurance_blog_v499_vov_mvm",
        "timeout_seconds": JOB_TIMEOUT_S,
        "max_concurrent_runs": 1,
        "max_retries": 0,
        "tasks": [{
            "task_key": "mvm",
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
            Path("/tmp/pc_blog_vov_shrink_v502_jobpatch.json").write_text(
                json.dumps({"job_id": job["job_id"], "new_settings": spec}))
            M.db(["jobs", "reset", "--json", "@/tmp/pc_blog_vov_shrink_v502_jobpatch.json"], PROFILE)
            return job["job_id"]
    Path("/tmp/pc_blog_vov_shrink_v502_jobspec.json").write_text(json.dumps(spec))
    return M.dbj(["jobs", "create", "--json", "@/tmp/pc_blog_vov_shrink_v502_jobspec.json"], PROFILE)["job_id"]


def info_log_bytes():
    base = "dbfs:/Volumes/%s/_metamodel/vol_root/logs/%s/v%s/mvm" % (CATALOG, BUSINESS, MODEL_VERSION)
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
        task = next((t for t in info.get("tasks", []) if t.get("k") == "mvm"), None)
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
    M.pulse("=== P&C BLOG VoV-SHRINK v%s ECM->MVM v5.0.2 START catalog=%s agent=%s ===" % (MODEL_VERSION, CATALOG, AGENT_PATH))
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
    Path("/tmp/pc_blog_vov_shrink_v502_run.json").write_text(json.dumps(state, indent=2))
    info = wait_terminal(run_id)
    M.pulse("TERMINAL lc=%s result=%s url=%s"
            % (info["lc"], info.get("result"), info.get("url")))
    state.update(terminal=info)
    Path("/tmp/pc_blog_vov_shrink_v502_run.json").write_text(json.dumps(state, indent=2, default=str))


if __name__ == "__main__":
    main()
