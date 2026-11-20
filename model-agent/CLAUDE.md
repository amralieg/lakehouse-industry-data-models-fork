# CLAUDE.md — Project Guardrails for the vibe-modelling-agent

These instructions apply to every session in this repository. Follow them verbatim.

---

## §-0. NEVER CHECK OUT `data-models/` — MAC-CRASH / DISK RULE (HARD — 2026-10-11)

`data-models/` is ~2.7 GB (4837+ files). Checking it out on one worktree has crashed this Mac and filled 11–18 GB across forks (`vibe-data-modeling-b2fix`, `-b3-pk`, `-b3-rename`, `-b3-sizing`, `-int2`). Recurrence after a sparse exclude is a CRITICAL failure. This rule outranks convenience, tests, worktree setup, and "I need one model.json".

**FORBIDDEN (no exceptions):**
- Materialize `data-models/` on disk in any clone, worktree, or `/tmp` snapshot of this repo.
- Put `data-models` in any sparse-checkout cone (`/data-models/`, `data-models`, or `git sparse-checkout add data-models`).
- `git sparse-checkout disable`, full `git checkout .`, `git restore data-models`, or `sparse-checkout set` from `ls` / a glob of top-level dirs (that list includes `data-models` and WILL crash the machine).
- Copy, rsync, or extract `data-models/` "for tests" or "for fixtures". Tests must use a tiny file under `model-agent/tests/`, never the published dump.

**REQUIRED, on EVERY session start in this repo and after EVERY `git worktree add` / clone / branch checkout:**

```
git sparse-checkout init --cone
git sparse-checkout set --cone docs model-agent model-app model-genie-skills model-installer model-viewer tools
test ! -e data-models
```

Pass those directory names as **separate argv words**. zsh does not split `$VAR`; a single string becomes one bogus cone path, then Git/Cursor rebuilds the cone from every top-level tracked dir and `data-models/` comes back.

If `data-models/` exists anywhere: `rm -rf` it immediately, then re-run `set --cone` with the seven dirs above. Sweep ALL worktrees of this repo in the same turn, plus `/tmp` copies. Verify `git sparse-checkout list` has no `data-models`.

The objects stay in `.git`. They must never be in the working tree.

---

## MISSION (read this first, every session — never forget it)

The single purpose of this agent is to PRODUCE A DATA MODEL THAT 100% ADHERES TO THE USER'S VIBES (hard floor 90% VERIFIED adherence), is production-ready, and is good enough to recommend to peers or propose as a global standard. This will run for HUNDREDS of industries.

The mission is judged by VERIFIED VIBE ADHERENCE = (VREQs verified-applied) / (VREQs extracted), with two mandatory halves: (a) EXTRACTION COMPLETENESS — every requirement in the vibe becomes a VREQ; (b) APPLICATION + VERIFICATION — every VREQ is actually applied AND deterministically provable against the real catalog. A "Max retries exhausted, proceeding" soft-accept is NOT applied.

NON-NEGOTIABLE OPERATING RULES FOR THIS MISSION:
- NEVER OVERFIT or HARDCODE any industry (gov_transport, airlines, automotive, healthcare, etc.). Every fix must be generic and read from the vibe / runtime / catalog, never from a baked-in name.
- For EVERY failed VREQ, examine its FULL LIFECYCLE: extracted? → applied to model dict? → physically built? → verified? Find the exact stage where it dropped and fix THAT stage's root cause.
- Three systemic failure classes drive non-adherence (diagnosed from the gov_transport v3.4.0 24-VREQ trace + live HEALTH sandbox, 2026-06-08):
  1. VERIFIER FALSE-NEGATIVES (the "lying scoreboard") — the model DID follow the vibe but the verifier scores it failed because its snapshot is lossy (missing `_metrics` schema MVs, missing column tags) and its matching is too literal (user display name "Vacancy Rate" vs physical `hr_vacancy_rate`). This is the LARGEST lever. Fix = ground every VREQ class against the REAL catalog with NAME NORMALIZATION (display→snake, domain-prefix-tolerant, substring/contains).
  2. GENUINE NAME/SHAPE SUBSTITUTION — generators that receive only a COUNT free-invent names. Fix = forward the user's EXACT named artifacts as a USER-KING mandate into the generator prompt.
  3. DEAD AGENTIC REPAIR — the SelfFixer (sandbox code-gen residual repair) ran inert because it was built with ai_agent=None. Fix = resolve a live AIAgent at the single shared entry point; the sandbox mechanism itself is proven working (HEALTH made 397 VOV_2_SANDBOX code-gen calls).
- Run AUTONOMOUSLY: monitor → RCA every miss → generic root-cause fix → behavioral test (fail pre-patch, pass post-patch) → bump version → redeploy → re-run FROM V1 (no chaining) → loop until ALL targets ≥90% with zero §10.6 signatures. Do not stop until the goal is met.

---

## 1. Regression report after every delivery

AFTER FINISHING YOUR JOB, FIND EVERY SINGLE REGRESSION ERROR AND RACTIFY THE ROOT CAUSE BEFORE YOU DELIVER, AND THEN SHOW ME REGRESSION RESPORT WITH HOW CRITICAL THE ISSUE IS.

## 2. Databricks Serverless compatibility (hard constraint)

ALL THE CODE YOU GENERATE MUST ALWAYS WORKS WITH DATABRIKC SERVERLESS ENVIRONMENT, No Cache, persist, uncache, sparkcontext etc.

## 3. Root-cause fixes, not symptom fixes

WHEN I ASK YOU TO FIX A PROBLEM, ALWAY FIND THE ROOT CAUSE OF THE PROBLEM AND FIX IT, DO NOT JUST FIX THE SYMPTOM, YOU MUST FIX THE ROOT CAUSE.

## 3d. SEARCH-FIRST, REUSE-FIRST — NEVER INVENT WHAT ALREADY EXISTS

BEFORE PROPOSING OR WRITING ANY NEW CODE, YOU MUST:

1. **Search the existing codebase** for any function, class, prompt, schema, widget, or utility that already solves the problem or something close to it. Use `Grep` and `Glob` aggressively. Don't guess — verify.

2. **Extend or reuse first**. If existing code covers 70%+ of the need, refactor or extend it rather than duplicating. If it covers less, compose it with thin new code. Only when the existing code is genuinely unrelated or structurally wrong do you write something new.

3. **Honour DRY**. Two implementations of the same concept is a bug in this codebase. If you add a second parser, a second validator, a second log helper, a second cap calculator — you have failed this rule.

Real examples of violations to never repeat:
- Proposing regex extraction of user directives from `business_description` when `VibeOrchestrator` + `VIBE_PARSE_PROMPT` + `_VIBE_PARSE_RESPONSE_SCHEMA` already LLM-parse the same concepts into a structured `vibe_classification` dict consumed by every downstream stage.
- Writing a second "sample data" engine alongside the pool engine without first checking whether `_sample_numeric` / `_sample_temporal` / `_assemble_rows_from_pools` could be extended.
- Adding a new autofix pass that duplicates logic already present in `_pre_static_analysis_autofix`.

The search-first loop before every new solution is:
```
Grep for: the concept name, the likely function prefix, the widget name, the schema tag
→ read the top 3 matches
→ ask: can I extend this to cover my case?
→ if yes, extend
→ if no, compose with a thin wrapper
→ only if no existing code is usable, write net-new — and justify why
```

Failing this rule wastes cycles and creates parallel sub-systems that drift apart over time.

## 3a-bis. Count-fixation guidance (added 2026-04-25 from user feedback)

**Real users don't fixate on exact domain or product counts in the FREE-TEXT VIBE.** §3c (`model_vibes` natural-language count clamp) was originally added so a TEST RUN with `model_vibes="exactly 3 domains and ~15 products"` could finish in ~30 min instead of producing a 200-product behemoth. The vibe-derived count clamping is TEST INSTRUMENTATION, not a product requirement for vibe-based usage.

**HARD CARVEOUT — `business_domains` WIDGET is NOT relaxed.** §3b stays absolute:
- If the user POPULATES the `business_domains` widget, the agent MUST produce EXACTLY those domains, verbatim. No additions, no removals, no renames. This is contractual, not a soft target.
- This applies regardless of what the free-text vibe says. The widget OUTRANKS the vibe.

**The PRIMARY goals are:**
1. **Quality models** — correct domain boundaries, healthy FK density, attribute completeness, accurate types, working metric views, no orphan tables, structural integrity (no cycles, no bidirectional FKs, no SSOT violations).
2. **Zero errors** — no NameError / NoneType / ValueError, no fidelity-gate failure, no install crash, no DDL [COLUMN_ALREADY_EXISTS], no unhandled exception path.

**De-prioritize (vibe-only):**
- VIBE COUNT VIOLATION enforcement when the count comes from FREE-TEXT vibes (not the widget). Already de-tautologized in v0.8.9 NEW-2.
- Vibe-derived product-count clamps that fight the LLM.
- Anything that adds code complexity to enforce "exactly N" from natural-language vibes.

**Relax (vibe-only):**
- Architect-gate failures for "tier-inappropriate" tiny vibes (v0.8.9 NEW-4 covers global; v0.9.4+ should NOT also patch per-domain — let those gates emit a warning, that's fine).
- §3c product-count over/undershoot when source is vibe — log INFO, do not error or trim aggressively.

**Keep absolute (widget-driven):**
- §3b `business_domains` widget — verbatim preservation (HARD).
- `must_have_data_products` widget — verbatim preservation (HARD).
- Structural-integrity invariants (no cycles, no orphans, no broken FKs) — these are quality, not count.

When triaging logs, PASS the count-related warnings ONLY if they originated from a FREE-TEXT vibe directive. Widget-driven count violations are still HARD failures. Burn cycles on NameErrors, install failures, fidelity drift, and unlinked _id columns first.

---

## 3a-bis. Global `__AGENT_VERSION__` constant — HARD RULE (added 2026-04-27)

EVERY VERSION OF THE AGENT MUST EXPOSE THE RUNNING VERSION AT TWO PLACES, OR THE FIX IS NOT DONE:

1. **First non-comment line of code in `agent/dbx_vibe_modelling_agent.ipynb` Cell 1:**
   ```python
   __AGENT_VERSION__ = "<single-digit-semver>"  # alias=agent-version-global
   ```
   - The literal MUST be the FIRST statement after the cell-header comment, BEFORE any other constant, import, or class definition.
   - The string value MUST follow §3a single-digit semver (e.g. `"0.6.9"`, `"0.7.0"`, `"1.0.0"` — never `"0.6.10"`, `"0.10.0"`).

2. **First top-level property of every generated `model.json`:**
   ```json
   {
     "agent_version": "<same-value-as-__AGENT_VERSION__>",
     "model_requirements": { ... },
     "_vibe_session_metadata": { ... },
     "model": { ... }
   }
   ```
   - The key is `agent_version` (snake_case, no leading underscore).
   - The value MUST equal `__AGENT_VERSION__` verbatim — no derivation, no prefix, no suffix.
   - Every model.json rewrite path (metric-view writeback, install metric-view cleanup, install location update) MUST refresh `agent_version` to the running agent's value so an older model.json gets re-stamped on rewrite. NEVER leave stale `agent_version`.

**Pre-deploy mutation rule:**
- BEFORE EVERY TEST CYCLE: bump `__AGENT_VERSION__` to the new single-digit semver, commit, deploy. The deployed notebook archive name MUST match (`dbx_vibe_modelling_agent_v<NN>` where `NN` is `__AGENT_VERSION__` minus dots — e.g. `0.6.9` → `_v69`, `1.0.0` → `_v100`).
- BEFORE EVERY TAG-TO-MAIN: decide the next semver, write it into `__AGENT_VERSION__` in the SAME commit that updates `readme.md`, then push. The tag and the constant must agree.
- The audit grep `grep -E '__AGENT_VERSION__\s*=\s*"<expected>"' agent/dbx_vibe_modelling_agent.ipynb` is part of §10.7 Step 6 deployed-archive verification.
- Behavioural test in `tests/unit-tests/test_v<NN>_behavioral.py` MUST assert: (a) constant equals expected, (b) it is the first non-comment code statement in Cell 1, (c) generated `model.json` has `agent_version` as the first key with the same value, (d) every rewrite path refreshes/prepends the key.

**Why this rule exists:**
- Audit cannot tell which agent version produced a given `model.json` from filename alone (versioned volume paths can be re-overwritten by a `vibe modeling of version` operation).
- Every regression report must cite the agent version that produced the artifact; a missing `agent_version` field is a §8.1 invariant violation that blocks honest scoring.
- The constant being the FIRST line of code makes a stale-deploy detectable by visual inspection without grep.

Violations that are §8.1 hard fails:
- Bumping `__AGENT_VERSION__` AFTER the deploy and forgetting to re-deploy → live notebook reports the OLD version while local says the NEW one.
- Forgetting to update `agent_version` in `model.json` rewrite paths → stale value persists across surgical/install passes.
- Two-digit semver segment (`"0.6.10"`) → §3a violation that propagates into model.json.
- Using `version` or `__version__` instead of the canonical `__AGENT_VERSION__` constant → audit grep fails.

## 10. HOW TO TEST — autonomous fix-and-verify loop (MUST follow on every task)

This is the canonical loop the user expects every coding task to follow. Do NOT ask the user to repeat any of these steps — execute them yourself and report progress.

### 10.6 What "no errors at all" means (NON-NEGOTIABLE)

The tester is "clean" only when ALL of these are true at run terminal:
- 0 lines matching `ERROR` in any error log.
- 0 lines matching §9.4 F1–F10/R1–R8/N1–N3 signatures.
- 0 `Max retries (3) exhausted` lines (R7/F2 silent-drop hatch).
- 0 `[CYCLE DETECTION] Found N cycle(s)` where N>0.
- 0 `Fidelity gates FAILED` lines.
- 0 `name '<X>' is not defined` `NameError` lines.
- 0 `[Metrics] Failed metric view` lines.
- 0 `Workload failed, see run output for details` parent-task lines (with no info log).
- All §9.5 positive signals firing where applicable.

If even one of these is non-zero, you have NOT completed the iteration — go back to step 6 in §10.2.

---

### 10.8 Anti-shortcuts (HARD invariants)

- ❌ NEVER deploy to canon path `agent/dbx_vibe_modelling_agent` directly. ALWAYS use `_v<NN>` suffix.
- ❌ NEVER reuse a catalog from a prior version's run. ALWAYS drop catalogs first.
- ❌ NEVER skip Step 6 (deployed-archive grep). Even if you "just deployed" — workspace eventual-consistency means the archive may not have the new content for several seconds.
- ❌ NEVER submit a run before ALL prior runs of this JOB are deleted (Step 3). Stale runs pollute audit triage.
- ❌ NEVER claim a fix is "verified" without a `[<alias> FIRED]` grep hit on the LIVE run's volume info.log.
- ❌ NEVER inflate honesty scores. If a fix didn't fire live, score it 0 for that iteration.
- ❌ NEVER skip writing the validation-report + model-quality-audit (§9.6) for a SUCCESS run. The audit IS the verification.

---

## 12. STRUCTURED QUALITY-GATE CATALOG (QGATE) — the honest scoreboard (added 2026-06-17)

Added after the gov_transport base-MVM "lying scoreboard" incident: the agent reported high adherence while the model degraded, because the VREQ verifier scored governance/tagging VREQs off a LOSSY snapshot (attribute tags/subdomain/division/descriptions omitted). It false-FAILED glossary/subdomain VREQs that were PHYSICALLY present (vibe_gov_transport_basemvm: 3031 glossary + 7 subdomain tags). This section is the permanent contract for structured quality.

### 12.1 The four-layer anti-lying architecture

1. **Deterministic gates** (`run_metamodel_static_analysis`) read the REAL model dict, so a gate verdict cannot false-negative or false-positive. 66 categories today.
2. **Agentic-loop wiring** (`_v366_sa_findings_requeue` `_fixable` whitelist) — every gate category is requeued to the SelfFixer closed loop so a discovered gap is REPAIRED, not merely reported. Curated completeness categories (descriptions/tags/types) requeue even at info severity.
3. **Authoritative verifier override** (`VibeOrchestrator._verify_bulk_coverage`, alias `verifier-bulk-coverage-authoritative`) — for glossary/subdomain/division coverage VREQs, the deterministic dict verdict runs FIRST in `_verify_deterministic` and OVERRIDES the LLM verdict. Conservative thresholds: coverage >=0.9 fulfilled, ==0 failed, else partial. rename/drop and non-coverage VREQs are deferred (no hijack).
4. **Physical ground-truth parity** (existing `gt-tag-enrich`/`gt-mv-enrich`/`gt-tag-verify`/`gt-mv-verify`) — post-build, query `information_schema.column_tags`, `information_schema.columns`, and the `_metrics` schema; verify tag/type/MV VREQs against the live catalog. This is the ultimate anti-lying check. DO NOT build a second physical-parity system — extend these.

The deterministic quality score (`_compute_deterministic_confidence_and_status`) is computed from ALL severity issues and is AUTHORITATIVE over the LLM self-score. Every new gate feeds it automatically.

### 12.3 Canonical division taxonomy — EXACTLY 3 (HARD)

Every domain MUST be classified into EXACTLY ONE of three canonical divisions: **`operations`, `business`, `corporate`**. No other value is allowed. Legacy synonyms (`supporting`, `support`, `back_office`, `backoffice`) fold to `corporate`. Balance rule (DOM-RUL-001): Operations + Business >= 80% of domains; Corporate <= 20%. No early corporate (DOM-RUL-003): no corporate domains until Operations >= 2 and Business >= 2. The taxonomy lives in `get_division_taxonomy`; prompts, normalizer, and gates all read it (never hardcode the set elsewhere).

### 12.4 Adding new gates (the standing instruction)

Whenever a production run surfaces a new structural/governance defect class: (1) add a deterministic gate in `run_metamodel_static_analysis` reading the real dict; (2) add its category to the `_fixable` whitelist so it self-repairs; (3) if it is a coverage VREQ class, extend `_verify_bulk_coverage` so the scoreboard is authoritative; (4) add the rule to `rules/vibe-data-modelling-rules.csv` under the `Quality Gate` group; (5) add a fail-pre/pass-post behavioral test (§8.10). "Add AS MANY static structure checks AS POSSIBLE" is a standing directive, not a one-time task.

---

## Where the removed rules went (trimmed 2026-11-20)

- Global rules (voice, honesty, chat format, Karpathy discipline, review method): `~/CLAUDE.md` and its skills. Personal per-repo rules (no versioning roadmap, main-only success gate, user vibes supreme, `business_domains` hard, single-digit semver, QGATE summary): `CLAUDE.local.md` (untracked, Amr's machine).
- Run validation (counts, structural checks, F1..N3 signatures, report format): skill `vibe-model-validation`. Release notes when tagging `main`: skill `release-notes`.
- Everything else, unchanged and verbatim, is in `model-agent/docs/claude-reference.md`. Read it when you:
  - tag a release (section 0) or promote to `main` (1a-bis);
  - need the full rule text of 3c, 3b or 3a, the review method (7) or the honesty invariants (8);
  - run the test loop or deploy recipe (10.1-10.5, 10.7, 10.9, 10.11), or monitor a live run (11, pulse rules);
  - add or audit a gate (12.2, the full gate catalog).
- Hard rules that stay in force even though their text moved: user vibes outrank every heuristic; user `business_domains` are never removed or renamed; every version segment is 0-9; every audited issue is fixed in the same version; commits to `main` only after live success.
