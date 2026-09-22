/**
 * Run-intent / agent-operation mapping helpers.
 *
 * The ``Intent`` slug values come from the Orval-generated enum in
 * ``lib/api.ts`` (auto-derived from the OpenAPI spec, which is sourced
 * from ``backend/models.py:Intent``). This module owns the FE-side
 * mappings to and from the agent-side operation strings the legacy form
 * Select still uses ("new base model", "vibe modeling of version", …).
 *
 * Drift-unification (Phase 7, Item 5): the agent-op strings are the same
 * vocabulary as ``backend/router.py:_INTENT_TO_AGENT_OP``. Keep them in
 * sync — anywhere a string literal matches an entry below, prefer
 * ``intentToRunType`` / ``runTypeToIntent`` so a future rename only has
 * to touch one place.
 */
import { Intent } from "@/lib/api";

/** Display label for each intent slug. Used by ``intentLabel``. */
export const INTENT_LABELS: Record<Intent, string> = {
  "new-base-model": "New base model",
  "vibe-iterate": "Vibe iterate",
  "vibe-new-ecm-mvm": "Vibe ECM + MVM",
  install: "Install model",
  uninstall: "Uninstall model",
  "generate-samples": "Generate samples",
  "import-from-volume": "Import from volume",
  revert: "Revert version",
};

/**
 * FE Select value (legacy human-readable agent-op vocabulary) for each
 * Intent slug. The Select is the FE-only contract — it pre-existed the
 * orchestrator refactor and the labels were already reviewed/translated.
 * The BE has a *similar* map (``backend/router.py:_INTENT_TO_AGENT_OP``)
 * for agent-side operation tagging on multi-step pipelines, but it
 * collapses ``vibe-new-ecm-mvm`` onto ``"vibe modeling of version"``
 * (because the lead step IS the vibe op). The FE keeps the standalone
 * ``"vibe new ecm + mvm"`` Select value because users distinguish the
 * two flows visually.
 */
export const INTENT_TO_AGENT_OP: Record<Intent, string> = {
  "new-base-model": "new base model",
  "vibe-iterate": "vibe modeling of version",
  "vibe-new-ecm-mvm": "vibe new ecm + mvm",
  install: "install model",
  uninstall: "uninstall model version",
  "generate-samples": "generate sample data",
  revert: "revert model version",
  "import-from-volume": "import model version",
};

/** Reverse of ``INTENT_TO_AGENT_OP`` — derived once at module load. */
const AGENT_OP_TO_INTENT: Record<string, Intent> = (() => {
  const map: Record<string, Intent> = {};
  for (const [intent, op] of Object.entries(INTENT_TO_AGENT_OP) as [
    Intent,
    string,
  ][]) {
    map[op] = intent;
  }
  return map;
})();

/**
 * Render an intent slug as a human-friendly label. Falls back to the
 * raw slug if it isn't in the map so a newly-added intent shows up
 * verbatim rather than as an empty string.
 */
export const intentLabel = (intent: string | null | undefined): string =>
  intent ? (INTENT_LABELS[intent as Intent] ?? intent) : "";

/**
 * Translate a legacy ``run_type`` Select value (agent-side wording,
 * e.g. ``"new base model"``) into the canonical Intent slug
 * (``"new-base-model"``). Empty string for unknown values so a typo
 * lights up as a downstream validation failure rather than a silent
 * default.
 */
export function runTypeToIntent(runType: string): string {
  return AGENT_OP_TO_INTENT[runType] ?? "";
}

/**
 * Reverse of ``runTypeToIntent`` — converts an Intent slug
 * (``"vibe-iterate"``) back into the human-readable run_type Select
 * value (``"vibe modeling of version"``). Used when normalising the
 * ``operationType`` URL param (callers may pass either form). Unknown
 * values are returned as-is so a typo lights up as an empty Select
 * rather than silently coerced.
 */
export function intentToRunType(value: string): string {
  return INTENT_TO_AGENT_OP[value as Intent] ?? value;
}
