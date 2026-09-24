import { useEffect, useState } from "react";
import { AlertTriangle, Check, Download } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  ApiError,
  getBundledAgentInfo,
  installBundledAgent,
  type BundledAgentInfoOut,
  type InstallBundledAgentOut,
} from "@/lib/api";

type Props = {
  onInstalled?: (path: string) => void;
};

/**
 * Drift-unification (Phase 7): the live fetches go through the Orval-
 * generated `getBundledAgentInfo` + `installBundledAgent` helpers (which
 * are thin wrappers over `fetch`) rather than hand-rolled `fetch(...)` so
 * request shape + error envelope track the OpenAPI spec automatically. We
 * deliberately do NOT use the `useGetBundledAgentInfo` /
 * `useInstallBundledAgent` React Query hooks here because the existing
 * tests mock `global.fetch` directly and render this button without a
 * `QueryClientProvider`.
 */
export function InstallBundledAgentButton({ onInstalled }: Props) {
  const [info, setInfo] = useState<BundledAgentInfoOut | null>(null);
  const [infoLoading, setInfoLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const [result, setResult] = useState<InstallBundledAgentOut | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const resp = await getBundledAgentInfo();
        if (!cancelled) setInfo(resp.data);
      } catch {
        // On error: hide the button entirely (parity with the previous
        // defensive `setInfo({ available: false })` fallback — the
        // settings page renders a separate banner for the underlying
        // failure).
        if (!cancelled) setInfo({ available: false });
      } finally {
        if (!cancelled) setInfoLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  const handleInstall = async () => {
    setUploading(true);
    setError(null);
    setResult(null);
    try {
      const resp = await installBundledAgent();
      setResult(resp.data);
      onInstalled?.(resp.data.path);
    } catch (e) {
      if (e instanceof ApiError) {
        const body = e.body as { detail?: unknown } | null | undefined;
        setError(
          body && typeof body.detail === "string" ? body.detail : `HTTP ${e.status}`,
        );
      } else {
        setError(e instanceof Error ? e.message : String(e));
      }
    } finally {
      setUploading(false);
    }
  };

  if (infoLoading) return null;
  if (!info?.available) return null;

  const label = `Install bundled agent notebook (${info.pinned_tag})`;

  return (
    <div className="rounded-md border border-primary/30 bg-primary/5 p-3 text-xs space-y-2">
      <Button
        type="button"
        variant="outline"
        size="sm"
        onClick={handleInstall}
        disabled={uploading}
        aria-label={label}
      >
        <Download className="h-3.5 w-3.5 mr-1.5" />
        {uploading ? "Installing…" : label}
      </Button>
      {result && (
        <p className="text-green-600 flex items-start gap-1">
          <Check className="h-3 w-3 mt-0.5 shrink-0" />
          <span>
            {result.overwritten ? "Overwrote" : "Uploaded"}{" "}
            <span className="font-mono">{result.path}</span> ({result.version}).
          </span>
        </p>
      )}
      {error && (
        <p className="text-red-600 flex items-start gap-1">
          <AlertTriangle className="h-3 w-3 mt-0.5 shrink-0" />
          <span>{error}</span>
        </p>
      )}
    </div>
  );
}
