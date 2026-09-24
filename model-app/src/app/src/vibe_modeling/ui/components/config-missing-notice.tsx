import { Link } from "@tanstack/react-router";
import { AlertTriangle } from "lucide-react";
import type { ConfigMissingItem } from "@/lib/api-error";

/**
 * The single renderer for the backend's `config_missing` error. Used by the
 * shared `notifyError`/`notifyConfigMissing` path in `lib/notify.ts` (toast)
 * so every config-gated surface - run create/validate, kickstart, download,
 * volume import, resync, initial-sync, oob - renders the SAME thing: the
 * backend's sentence plus one working Settings deep-link per missing item.
 *
 * NOTE: this file intentionally never calls `toast.*` - the toast lives in
 * `lib/notify.ts` (the only site the anti-drift grep guard allows). This is
 * the presentation component; `notifyConfigMissing` wraps it in a toast.
 */

/** Split a `settings_url` like "/settings?tab=platform" into router Link props. */
function toLinkTarget(url: string): {
  to: string;
  search: Record<string, string>;
} {
  const [path, query = ""] = url.split("?");
  const search: Record<string, string> = {};
  for (const pair of query.split("&")) {
    if (!pair) continue;
    const [k, v = ""] = pair.split("=");
    if (k) search[decodeURIComponent(k)] = decodeURIComponent(v);
  }
  return { to: path || "/settings", search };
}

export function ConfigMissingNotice({
  missing,
  message,
}: {
  missing: ConfigMissingItem[];
  message: string;
}) {
  return (
    <div className="space-y-2" data-testid="config-missing-notice">
      <div className="flex items-start gap-2">
        <AlertTriangle className="h-4 w-4 shrink-0 mt-0.5" />
        <p className="text-sm font-medium">{message}</p>
      </div>
      {missing.length > 0 && (
        <ul className="space-y-1 pl-6 text-sm">
          {missing.map((m) => {
            const target = toLinkTarget(m.settings_url);
            return (
              <li key={m.key} className="flex items-center gap-2">
                <span>{m.label}</span>
                {/* The router is strongly typed; a runtime-derived path/search
                    pair needs the cast. All config_missing URLs resolve under
                    the /settings route. */}
                <Link
                  to={target.to as never}
                  search={target.search as never}
                  className="underline underline-offset-2 hover:opacity-80"
                >
                  Configure
                </Link>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
