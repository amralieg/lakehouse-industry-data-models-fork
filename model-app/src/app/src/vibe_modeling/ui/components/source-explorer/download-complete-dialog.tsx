import { AlertTriangle, CheckCircle2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import type { DownloadIndustryModelOut } from "@/lib/api";

/**
 * DownloadCompleteDialog - Task 5 (download-finished completion).
 *
 * Replaces the old sonner toast: the dialog itself IS the notification.
 * Summarizes what landed (industry, scope, version, domain/product/attribute/
 * FK counts sourced from the download's own `ImportAnalysis` threading, NOT
 * the source's release notes) and surfaces any materialization warnings
 * inline. Two actions: navigate to the new industry, or dismiss and pick
 * another scope from the still-open source explorer.
 */
export function DownloadCompleteDialog({
  result,
  open,
  onOpenChange,
  onViewIndustry,
  onDownloadAnother,
}: {
  result: DownloadIndustryModelOut | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onViewIndustry: (result: DownloadIndustryModelOut) => void;
  onDownloadAnother: () => void;
}) {
  if (!result) return null;

  const verb = result.on_conflict_applied === "added" ? "Added to" : "Downloaded";
  const warnings = result.warnings ?? [];

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <CheckCircle2 className="h-5 w-5 text-success" />
            {verb} {result.business_name}
          </DialogTitle>
          <DialogDescription>
            v{result.version} · {result.scope.toUpperCase()}
          </DialogDescription>
        </DialogHeader>

        <dl className="grid grid-cols-2 gap-x-4 gap-y-2 rounded-md border border-border bg-muted/30 p-3 text-sm">
          <Stat label="Domains" value={result.domains} />
          <Stat label="Products" value={result.products} />
          <Stat label="Attributes" value={result.attribute_count} />
          <Stat label="Foreign keys" value={result.fk_count} />
        </dl>

        {warnings.length > 0 && (
          <div className="space-y-1 rounded-md border border-amber-500/40 bg-amber-500/10 p-3 text-xs">
            {warnings.map((w, i) => (
              <div key={i} className="flex items-start gap-2">
                <AlertTriangle className="h-3.5 w-3.5 mt-0.5 shrink-0 text-amber-600 dark:text-amber-400" />
                <span>{w}</span>
              </div>
            ))}
          </div>
        )}

        <DialogFooter className="gap-2 sm:justify-between">
          <Button variant="outline" size="sm" onClick={onDownloadAnother}>
            Download another scope
          </Button>
          <Button size="sm" onClick={() => onViewIndustry(result)}>
            View industry
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

function Stat({ label, value }: { label: string; value: number }) {
  return (
    <div>
      <dt className="text-[10px] uppercase tracking-wide text-muted-foreground">
        {label}
      </dt>
      <dd className="font-medium">{value}</dd>
    </div>
  );
}
