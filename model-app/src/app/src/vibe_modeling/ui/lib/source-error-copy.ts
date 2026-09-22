/**
 * Single source of truth for source-explorer / industry-import error copy,
 * keyed by HTTP status. Both the source-explorer dialog's error boundary
 * (`SourceExplorerError`) and the per-model download dialog
 * (`DownloadIndustryDialog`) render from this so the two surfaces never diverge.
 *
 * The 403 copy points at the GitHub App / source configuration - reads are no
 * longer per-user OAuth, so it must NOT say "authorize your GitHub account".
 */
export interface SourceErrorCopy {
  title: string;
  /** Null for the generic fallback - the caller substitutes the raw message. */
  detail: string | null;
}

export function sourceErrorCopy(status: number): SourceErrorCopy {
  if (status === 403) {
    return {
      title: "This source needs a GitHub App",
      detail:
        "The source repository denied access. The app's GitHub App credentials are missing or invalid, or the repository is private. Check Settings -> Sources (GitHub App configuration), then try again.",
    };
  }
  if (status === 404) {
    return {
      title: "Path not found in source",
      detail: "That path no longer exists in the source.",
    };
  }
  if (status === 502) {
    return {
      title: "Source unavailable",
      detail:
        "The source repository couldn't be reached. This is usually transient - try again.",
    };
  }
  return { title: "Couldn't load the source.", detail: null };
}
