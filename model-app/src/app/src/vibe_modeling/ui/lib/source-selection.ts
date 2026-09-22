/**
 * source-selection.ts
 *
 * Shared type contract between Track A (source-explorer) and Track B (download-dialog).
 * This interface defines the data shape passed from source browsing to model download,
 * ensuring both tracks build against the same selection structure.
 */

/**
 * SourceModelSelection
 *
 * Represents a selected industry model ready for download.
 * This is the contract between the source explorer UI (Track A) and the download dialog (Track B).
 */
export interface SourceModelSelection {
  /** Industry ID in source registry */
  industry_id: string;

  /** Model ID within the selected industry */
  model_id: string;

  /** Optional sector ID hint for additional context */
  suggested_sector_id?: string | null;
}

/**
 * Mirror of the backend `agent_business_segment` (core/_names.py): normalize a
 * raw identifier to a safe path segment (lowercase, non-alnum -> `_`, collapse
 * runs, trim, prefix `_` if it starts with a digit). Kept in lockstep so the
 * pre-filled publish target matches exactly what the backend resolves when the
 * user doesn't edit it (ADR D-049).
 */
function agentBusinessSegment(name: string): string {
  let s = (name || "").toLowerCase().replace(/[^a-z0-9_]+/g, "_");
  s = s.replace(/_+/g, "_").replace(/^_+|_+$/g, "");
  if (/^[0-9]/.test(s)) s = `_${s}`;
  return s;
}

/**
 * Compute the publish dialog's default target path (the bundle root, up to and
 * including the version folder) from a downloaded industry's `source_repo_path`.
 * Mirrors `resolve_bundle_root` case 2: take the last `/`-segment of the repo
 * path, normalize it, and append `<scope>_v<version>`. Returns `undefined` when
 * `source_repo_path` is empty so the field starts blank and the backend falls
 * back to the business name.
 */
export function makeDefaultTargetPath(
  sourceRepoPath: string | null | undefined,
  scope: string | undefined,
  version: number,
): string | undefined {
  if (!sourceRepoPath) return undefined;
  const seg = sourceRepoPath.replace(/\/+$/, "").split("/").pop() ?? "";
  const industrySeg = agentBusinessSegment(seg) || "model";
  const scopeSeg = (scope || "").toLowerCase();
  return `${industrySeg}/${scopeSeg}_v${version}`;
}
