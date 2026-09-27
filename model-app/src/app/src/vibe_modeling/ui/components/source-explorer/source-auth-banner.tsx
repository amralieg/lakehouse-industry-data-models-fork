import { AlertTriangle } from "lucide-react";
import { useGetSourceCapabilities } from "@/lib/api";

/**
 * Read-auth status banner for GitHub source browsing.
 *
 * The backend resolves `auth_mode` per request from the installation's source
 * read-auth config: `github_app` or `token` (both 5,000 req/hr) once configured,
 * otherwise `anonymous` (60 req/hr). `auth_error` carries a leak-free reason when
 * a configured mode could not be applied and the read degraded to anonymous.
 *
 * This banner surfaces:
 * - the config error, when resolution failed (highest priority), and
 * - the 60-requests/hour caution while browsing anonymously.
 * It renders nothing once an authenticated mode clears the limit cleanly.
 *
 * Single source of truth: the Settings -> Sources tab and the Industries
 * "Download from source" dialog both mount THIS component - no per-surface
 * copies.
 */
export function SourceAuthBanner() {
  const { data: result } = useGetSourceCapabilities({ query: { retry: false } });
  const authMode = result?.data?.auth_mode;
  const authError = result?.data?.auth_error;

  if (authError) {
    return (
      <div className="flex items-start gap-2 rounded-md border border-warning/40 bg-warning/5 px-3 py-2 text-xs max-w-4xl">
        <AlertTriangle className="h-4 w-4 text-warning shrink-0 mt-0.5" />
        <span className="text-warning">
          Source read access is misconfigured, so browsing fell back to
          unauthenticated (60 requests/hour). {authError} Fix it in Settings →
          Sources → Source read access.
        </span>
      </div>
    );
  }

  if (authMode !== "anonymous") return null;

  return (
    <div className="flex items-start gap-2 rounded-md border border-warning/40 bg-warning/5 px-3 py-2 text-xs max-w-4xl">
      <AlertTriangle className="h-4 w-4 text-warning shrink-0 mt-0.5" />
      <span className="text-warning">
        Browsing unauthenticated - GitHub limits this to 60 requests/hour.
        Configure a GitHub App or a personal access token to raise the limit to
        5,000/hour in Settings → Sources → Source read access.
      </span>
    </div>
  );
}
