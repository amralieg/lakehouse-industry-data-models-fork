import { useCallback, useState } from "react";
import { FileText, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { notifyError } from "@/lib/notify";

/**
 * Self-contained "Export report" button for the Statistics tab.
 *
 * Fetches the version's Statistics report as an `.xlsx` from the export
 * endpoint and triggers a browser download. It does NOT use the generated API
 * client (the endpoint streams a binary file, not JSON), so it issues a plain
 * `fetch` against the same `/api` base every other client call uses, reads the
 * response as a Blob, and saves it via a temporary object URL.
 *
 * NOTE (T15): this component is intentionally LEFT UNMOUNTED. The orchestrator
 * wires it into the Statistics tab's page-action bar after the statistics
 * components (T6/T7) land, to avoid colliding with that surface. It is built
 * and unit-tested in isolation here.
 */
export function ExportReportButton({
  businessId,
  version,
  scope,
  variant = "outline",
  size = "sm",
  className,
}: {
  businessId: string;
  /** The version integer from the route (`$version`). */
  version: number;
  /** The model scope from the route ("ecm" | "mvm"). */
  scope: string;
  variant?: "default" | "outline" | "ghost";
  size?: "default" | "sm" | "icon";
  className?: string;
}) {
  const [busy, setBusy] = useState(false);

  const handleExport = useCallback(async () => {
    if (busy) return;
    setBusy(true);
    try {
      const res = await fetch(
        `/api/businesses/${businessId}/versions/${version}/${scope}/statistics-report.xlsx`,
        { headers: { Accept: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" } },
      );
      if (!res.ok) {
        throw new Error(`Export failed (${res.status})`);
      }
      const blob = await res.blob();
      const filename =
        parseFilename(res.headers.get("Content-Disposition")) ??
        `statistics-report-v${version}-${scope}.xlsx`;
      triggerDownload(blob, filename);
    } catch (err) {
      notifyError(err, { fallback: "Could not export the report" });
    } finally {
      setBusy(false);
    }
  }, [busy, businessId, version, scope]);

  return (
    <Button
      type="button"
      variant={variant}
      size={size}
      className={className}
      disabled={busy}
      onClick={handleExport}
    >
      {busy ? (
        <Loader2 className="mr-1 h-4 w-4 animate-spin" />
      ) : (
        <FileText className="mr-1 h-4 w-4" />
      )}
      Export report
    </Button>
  );
}

/** Pull the `filename="..."` out of a Content-Disposition header, if present. */
export function parseFilename(header: string | null): string | undefined {
  if (!header) return undefined;
  // RFC 5987 `filename*=` takes precedence over the plain `filename=`.
  const star = /filename\*=(?:UTF-8'')?["']?([^"';]+)/i.exec(header);
  if (star?.[1]) return decodeURIComponent(star[1]);
  const plain = /filename=["']?([^"';]+)/i.exec(header);
  return plain?.[1];
}

function triggerDownload(blob: Blob, filename: string) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}
