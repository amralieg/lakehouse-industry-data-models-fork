import { AlertTriangle } from "lucide-react";
import { useGetSourceCapabilities } from "@/lib/api";

/**
 * Persistent unauthenticated rate-limit warning for GitHub source browsing.
 *
 * The backend resolves `auth_mode` per request: `github_app` when the
 * deployment's GitHub App credentials are configured (5,000 req/hr), otherwise
 * `anonymous`. This banner surfaces the 60-requests/hour caution ONLY for
 * `anonymous`; it renders nothing once the GitHub App clears the limit.
 *
 * Single source of truth: the Settings -> Sources tab and the Industries
 * "Download from source" dialog both mount THIS component - no per-surface
 * copies.
 */
export function SourceAuthBanner() {
  const { data: result } = useGetSourceCapabilities({ query: { retry: false } });
  const authMode = result?.data?.auth_mode;
  if (authMode !== "anonymous") return null;
  return (
    <div className="flex items-start gap-2 rounded-md border border-warning/40 bg-warning/5 px-3 py-2 text-xs max-w-4xl">
      <AlertTriangle className="h-4 w-4 text-warning shrink-0 mt-0.5" />
      <span className="text-warning">
        Browsing unauthenticated - GitHub limits this to 60 requests/hour.
        Configure a GitHub App to raise the limit to 5,000/hour.
      </span>
    </div>
  );
}
