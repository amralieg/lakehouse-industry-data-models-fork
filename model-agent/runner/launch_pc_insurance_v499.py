#!/usr/bin/env python3
"""Full ECM run for a NEW industry (Property & Casualty insurance) on agent v4.9.9.

Proves the v4.9.9 fixes end to end on a large, previously-unmodelled industry:
  #41 - descriptions capped at 256 on a word boundary (no mid-word cuts), enforced
        by the generator prompt + deterministic autofix + a static-analysis gate.
  #43 - empty task lists no longer crash the parallel workers.

Industry and domains come verbatim from upstream issue #42 (P&C proposal), so the
eight named domains are immutable per the user-king authority rules.
"""
import json
import os
import sys
import time
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vov_v2_marathon as M

PROFILE = "my-uae"
AGENT_PATH = "/Users/user@example.com/dbx_vibe_modelling_agent_v499"
CATALOG = "vibe_pc_insurance_v499"
BUSINESS = "pc_insurance"
BUDGET_S = 12600          # 3.5h - ECM is the large scope
JOB_TIMEOUT_S = 14400     # 4h outer job timeout
STALL_EMPTY_INFO_S = 2400 # ECM ensemble/judge runs longer before the first info write

DESC = (
    "A Property & Casualty insurer that underwrites personal and commercial lines, "
    "binds policies with coverages and endorsements, prices premium against rated risk "
    "exposures, adjudicates and pays claims, holds and develops loss reserves, cedes "
    "risk through reinsurance treaties and facultative certificates, and distributes "
    "through agents and brokers who earn commission."
)
VIBES = (
    "Build a comprehensive, production-clean enterprise P&C model. Every table must "
    "carry a primary key. Model the real insurance lineage with foreign keys: policy -> "
    "coverage -> insured risk/exposure; premium transactions back to the rated policy; "
    "claim -> claimant, loss reserve, and payment; reinsurance treaty/cession back to "
    "the ceded policy or claim; producer -> commission and the policies they wrote. "
    "Keep every description concise - at most 256 characters and always ending on a "
    "complete word, never cut mid-word. Prefer proper junction tables for the "
    "many-to-many relationships (policy-coverage, treaty-cession, claim-payment)."
)

M.AGENT_PATH = AGENT_PATH
M.PULSE_FILE = os.path.expanduser("~/claude/vibe-agent/pc_insurance_v499_pulses.txt")
M.STATE_FILE = os.path.expanduser("~/claude/vibe-agent/pc_insurance_v499_state.json")
M.KILL_FILE = os.path.expanduser("~/claude/vibe-agent/pc_insurance_v499_KILL")
M.PULSE_S = 300
M._IND_PROFILE = {BUSINESS: PROFILE}
M.cat_name = lambda ind: CATALOG  # noqa: E731


def _catalog_exists():
    cats = M.dbj(["catalogs", "list"], PROFILE)
    items = cats if isinstance(cats, list) else cats.get("catalogs", [])
    return any(c.get("name") == CATALOG for c in items)


def prepare_fresh_catalog():
    """Default-Storage metastores reject a bare CREATE CATALOG, so bind an explicit
    managed location under an existing external location. Discovered at runtime."""
    if _catalog_exists():
        M.pulse("reusing existing catalog `%s`" % CATALOG)
    else:
        locs = M.dbj(["external-locations", "list"], PROFILE)
        items = locs if isinstance(locs, list) else locs.get("external_locations", [])
        bases = [e["url"].rstrip("/") for e in items
                 if not e.get("name", "").startswith("__databricks")]
        if not bases:
            raise RuntimeError("no external location to host the catalog on %s" % PROFILE)
        M.pulse("CREATE catalog `%s` at %s" % (CATALOG, bases[0]))
        M.db(["catalogs", "create", CATALOG, "--storage-root",
              "%s/%s" % (bases[0], CATALOG)], PROFILE)
    M._try(["schemas", "create", "_metamodel", CATALOG], PROFILE, ("already exists",))
    M._try(["volumes", "create", CATALOG, "_metamodel", "vol_root", "MANAGED"],
           PROFILE, ("already exists",))
    M.pulse("catalog `%s` ready (_metamodel.vol_root)" % CATALOG)


def build_spec():
    params = {
        "operation": "new base model",
        "business_name": BUSINESS,
        "business_description": DESC,
        # Verbatim from issue #42 (slashes rendered as snake_case); immutable per §3b.
        "business_domains": ("policy, coverage, risk_exposure, premium, claims, "
                             "reserves_payments, reinsurance, producers"),
        "org_divisions": "Operations, Business and Corporate",
        "model_vibes": VIBES,
        "data_model_scopes": "Expanded Coverage Model - ECM",
        "deployment_catalog": CATALOG,
        "model_version": "1",
        "runtime_budget_seconds": str(BUDGET_S),
        "cataloging_style": "One Catalog",
        "vibe_session_id": "{{job.run_id}}",
        "databricks_task_run_id": "{{task.run_id}}",
    }
    return {
        "name": "dbx_vibe_pc_insurance_v499_ecm",
        "timeout_seconds": JOB_TIMEOUT_S,
        "max_concurrent_runs": 1,
        "max_retries": 0,
        "tasks": [{
            "task_key": "ecm",
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
            Path("/tmp/pc_v499_jobpatch.json").write_text(
                json.dumps({"job_id": job["job_id"], "new_settings": spec}))
            M.db(["jobs", "reset", "--json", "@/tmp/pc_v499_jobpatch.json"], PROFILE)
            return job["job_id"]
    Path("/tmp/pc_v499_jobspec.json").write_text(json.dumps(spec))
    return M.dbj(["jobs", "create", "--json", "@/tmp/pc_v499_jobspec.json"], PROFILE)["job_id"]


def info_log_bytes():
    base = "dbfs:/Volumes/%s/_metamodel/vol_root/logs/%s/v1/ecm" % (CATALOG, BUSINESS)
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
        task = next((t for t in info.get("tasks", []) if t.get("k") == "ecm"), None)
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
    M.pulse("=== P&C INSURANCE ECM v4.9.9 START catalog=%s agent=%s ===" % (CATALOG, AGENT_PATH))
    prepare_fresh_catalog()
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
    Path("/tmp/pc_v499_run.json").write_text(json.dumps(state, indent=2))
    info = wait_terminal(run_id)
    M.pulse("TERMINAL lc=%s result=%s url=%s"
            % (info["lc"], info.get("result"), info.get("url")))
    state.update(terminal=info)
    Path("/tmp/pc_v499_run.json").write_text(json.dumps(state, indent=2, default=str))


if __name__ == "__main__":
    main()
