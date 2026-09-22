import { AlertTriangle } from "lucide-react";

import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";

/**
 * Warning banner shown on the version detail page when the post-run
 * Lakebase sync didn't fully complete.
 *
 * Backend marks ``ModelVersion.sync_state`` to one of:
 *   - ``ok``                  — happy path, no banner
 *   - ``incomplete_metadata`` — ``sync_model`` raised post-success
 *   - ``finalize_failed``     — ``_finalize_session_completion`` raised
 *   - ``unknown``             — reserved for future tagging
 *
 * Anything other than ``ok`` (or undefined, for legacy rows from
 * before the migration) renders the banner with the truncated
 * ``sync_error_text`` as the operator-facing hint.
 *
 * Kept as a focused leaf component so the route renderer can mount it
 * above the model summary without dragging the rest of the page into
 * its unit tests.
 */
export function VersionSyncStateBanner({
  version,
}: {
  version?: {
    sync_state?: string;
    sync_error_text?: string | null;
  } | null;
}) {
  const state = version?.sync_state ?? "ok";
  if (state === "ok") return null;

  const reason = version?.sync_error_text || "Reason not recorded.";

  return (
    <Alert
      variant="warning"
      className="mt-3"
      data-testid="sync-state-banner"
    >
      <AlertTriangle className="h-4 w-4" />
      <AlertTitle>This version's metadata is incomplete</AlertTitle>
      <AlertDescription>
        Some surfaces (diagrams, artifacts) may be unavailable. Reason:{" "}
        <span className="font-mono text-xs break-all">{reason}</span>
      </AlertDescription>
    </Alert>
  );
}
