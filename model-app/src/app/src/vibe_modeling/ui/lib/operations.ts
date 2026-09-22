/**
 * Centralized metadata for run operations — single source of truth for
 * user-facing labels and descriptions used by the run-launch confirmation
 * dialog.
 *
 * Keyed on the `OperationType` string values from the generated API client
 * (`src/app/src/vibe_modeling/ui/lib/api.ts`). We intentionally type the
 * keys as plain strings rather than the generated union so this file never
 * becomes a merge conflict with the generated client when ops are added.
 */

export interface OperationMetadata {
  label: string;
  description: string;
}

const NEW_BASE_MODEL: OperationMetadata = {
  label: "New Base Model",
  description: "Generates ECM + MVM + installs both. Full unified pipeline.",
};
const VIBE_ITERATE: OperationMetadata = {
  label: "Vibe Version",
  description: "Re-models from your vibe feedback.",
};
const SHRINK: OperationMetadata = {
  label: "Shrink to MVM",
  description: "Reduces ECM to minimum viable model.",
};
const ENLARGE: OperationMetadata = {
  label: "Enlarge to ECM",
  description: "Expands MVM back to ECM.",
};
const INSTALL: OperationMetadata = {
  label: "Install model",
  description: "Installs schemas to Unity Catalog.",
};
const UNINSTALL: OperationMetadata = {
  label: "Uninstall version",
  description: "Drops schemas from Unity Catalog.",
};
const GENERATE_SAMPLES: OperationMetadata = {
  label: "Generate samples",
  description: "Populates 10 rows per installed table.",
};

/**
 * Keyed by both the legacy human-readable run_type strings (still used by
 * the New Run form's Select) and the canonical Intent slugs (used by the
 * actions card on the model-version page after Phase 5). Either side
 * resolves to the same metadata object.
 */
export const OPERATION_METADATA: Record<string, OperationMetadata> = {
  // Legacy human-readable run_type values (form Select).
  "new base model": NEW_BASE_MODEL,
  "vibe modeling of version": VIBE_ITERATE,
  "shrink ecm": SHRINK,
  "enlarge mvm": ENLARGE,
  "install model": INSTALL,
  "uninstall model version": UNINSTALL,
  "generate sample data": GENERATE_SAMPLES,
  // Canonical Intent slugs (post-Phase-5 wire format).
  "new-base-model": NEW_BASE_MODEL,
  "vibe-iterate": VIBE_ITERATE,
  shrink: SHRINK,
  enlarge: ENLARGE,
  install: INSTALL,
  uninstall: UNINSTALL,
  "generate-samples": GENERATE_SAMPLES,
};

/**
 * Fallback metadata for operations not in the map — keeps the dialog
 * functional even if the API adds a new op before the UI ships a label.
 */
export function getOperationMetadata(op: string): OperationMetadata {
  return (
    OPERATION_METADATA[op] ?? {
      label: op,
      description: "This run will consume Databricks compute.",
    }
  );
}
