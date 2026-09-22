import { Suspense, useMemo, useState } from "react";
import { ErrorBoundary } from "react-error-boundary";
import { useNavigate } from "@tanstack/react-router";
import { useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import {
  ApiError,
  useGetSourceCapabilitiesSuspense,
  getSourceCapabilitiesKey,
  useListBusinessesSuspense,
  BusinessKind,
  type DownloadIndustryModelOut,
  type SourceCapabilities,
  type TargetKind,
} from "@/lib/api";
import { invalidateBusinessLists } from "@/lib/business-cache";
import { sourceErrorCopy } from "@/lib/source-error-copy";
import { selector } from "@/lib/selector";
import type { SourceModelSelection } from "@/lib/source-selection";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { SourceCapabilityBanner } from "@/components/source-explorer/source-capability-banner";
import { SourceAuthBanner } from "@/components/source-explorer/source-auth-banner";
import {
  SourceTree,
  type SourceTreeSelection,
} from "@/components/source-explorer/source-tree";
import { SourceModelPreview } from "@/components/source-explorer/source-model-preview";
import { DownloadIndustryDialog } from "@/components/import/download-industry-dialog";
import { DownloadCompleteDialog } from "@/components/source-explorer/download-complete-dialog";
import { FolderTree } from "lucide-react";

interface Props {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

/**
 * SourceExplorerDialog — hosts the source-explorer composition (capability
 * banner + browse tree + model preview + the per-model download dialog) inside
 * a large modal launched from the Industries page. The source explorer is no
 * longer a standalone navigable route; this dialog is the only entry point.
 *
 * The per-model `DownloadIndustryDialog` opens stacked on top of this dialog;
 * after each successful download it stays open and this dialog's "already
 * downloaded" badges refresh, supporting the repeatable additive flow (pick a
 * model, download, pick the next).
 */
export function SourceExplorerDialog({ open, onOpenChange }: Props) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-5xl h-[80vh] flex flex-col overflow-hidden">
        <DialogHeader>
          <DialogTitle>Download from source</DialogTitle>
          <DialogDescription>
            Browse published industry models in the source repository. Select a
            model to preview its structure and artifacts, then download it into
            your workspace as an industry.
          </DialogDescription>
        </DialogHeader>
        <div className="flex-1 min-h-0 overflow-auto">
          <ErrorBoundary FallbackComponent={SourceExplorerError}>
            <Suspense fallback={<Skeleton className="h-9 w-full" />}>
              <SourceExplorerBody onClose={() => onOpenChange(false)} />
            </Suspense>
          </ErrorBoundary>
        </div>
      </DialogContent>
    </Dialog>
  );
}

function SourceExplorerBody({ onClose }: { onClose: () => void }) {
  const [selection, setSelection] = useState<SourceTreeSelection | null>(null);
  const [downloadSelection, setDownloadSelection] =
    useState<SourceModelSelection | null>(null);
  const [downloadOpen, setDownloadOpen] = useState(false);
  const [completedResult, setCompletedResult] =
    useState<DownloadIndustryModelOut | null>(null);
  const [completeOpen, setCompleteOpen] = useState(false);
  const navigate = useNavigate();

  const { data: capabilities } = useGetSourceCapabilitiesSuspense(selector());

  // Cross-reference source models against existing kind='industry' businesses
  // to flag "already downloaded" leaves, per (industry name, scope). NOTE: the
  // NAME axis stays best-effort (the business is named from the unwrapped
  // model.name, which may differ from the source folder id's humanized
  // form); the SCOPE axis is exact, from BusinessListOut.downloaded_scopes.
  const { data: industries } = useListBusinessesSuspense({
    params: { kind: BusinessKind.industry },
    ...selector(),
  });
  const downloadedScopesByIndustry = useMemo(() => {
    const map = new Map<string, Set<string>>();
    for (const b of industries ?? []) {
      const key = b.name.trim().toLowerCase();
      const scopes = new Set((b.downloaded_scopes ?? []).map((s: string) => s.toLowerCase()));
      map.set(key, scopes);
    }
    return map;
  }, [industries]);

  const handleDownload = (sel: SourceModelSelection) => {
    setDownloadSelection(sel);
    setDownloadOpen(true);
  };

  const handleDownloaded = (out: DownloadIndustryModelOut) => {
    setCompletedResult(out);
    setCompleteOpen(true);
  };

  const handleViewIndustry = (out: DownloadIndustryModelOut) => {
    setCompleteOpen(false);
    onClose();
    navigate({
      to: "/businesses/$businessId/explorer",
      params: { businessId: out.business_id },
    });
  };

  const handleLocateArtifact = (_kind: TargetKind) => {
    toast.info("Browse the tree to locate this artifact in the source.");
  };

  return (
    <div className="p-1 space-y-4">
      <Suspense fallback={<Skeleton className="h-9 w-full" />}>
        <SourceCapabilityBanner />
      </Suspense>
      {/* Same anonymous-mode rate-limit banner as Settings -> Sources
          (single shared component), so the 60-req/hr caution shows here too. */}
      <SourceAuthBanner />

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-[minmax(0,320px)_1fr]">
        <Card>
          <CardContent className="py-4">
            <Suspense fallback={<TreeSkeleton />}>
              <SourceTree
                selectedModelId={selection?.modelId ?? null}
                downloadedScopesByIndustry={downloadedScopesByIndustry}
                capabilities={capabilities as SourceCapabilities}
                onSelect={setSelection}
              />
            </Suspense>
          </CardContent>
        </Card>

        <div>
          {selection ? (
            <Suspense fallback={<Skeleton className="h-80 w-full" />}>
              <SourceModelPreview
                industryId={selection.industryId}
                modelId={selection.modelId}
                suggestedSectorId={selection.suggestedSectorId}
                capabilities={capabilities as SourceCapabilities}
                alreadyDownloaded={
                  downloadedScopesByIndustry
                    .get(selection.industryName.trim().toLowerCase())
                    ?.has((selection.scope ?? "").toLowerCase()) ?? false
                }
                onDownload={handleDownload}
                onLocateArtifact={handleLocateArtifact}
              />
            </Suspense>
          ) : (
            <EmptyPreview />
          )}
        </div>
      </div>

      <DownloadIndustryDialog
        selection={downloadSelection}
        open={downloadOpen}
        onOpenChange={setDownloadOpen}
        onDownloaded={handleDownloaded}
      />

      <DownloadCompleteDialog
        result={completedResult}
        open={completeOpen}
        onOpenChange={setCompleteOpen}
        onViewIndustry={handleViewIndustry}
        onDownloadAnother={() => setCompleteOpen(false)}
      />
    </div>
  );
}

function EmptyPreview() {
  return (
    <Card>
      <CardContent className="flex flex-col items-center justify-center py-16 text-center">
        <FolderTree className="mb-4 h-12 w-12 text-muted-foreground" />
        <p className="text-muted-foreground">
          Select a model from the source tree to preview it.
        </p>
      </CardContent>
    </Card>
  );
}

function TreeSkeleton() {
  return (
    <div className="space-y-2">
      {[...Array(5)].map((_, i) => (
        <Skeleton key={i} className="h-6 w-full" />
      ))}
    </div>
  );
}

/**
 * Error boundary content for the source-explorer dialog body. Distinguishes
 * the backend's source-error statuses via the shared `sourceErrorCopy` helper:
 * 403 (`SourcePermissionError` — the source needs a GitHub App), 404
 * (`SourceNotFoundError` — a path no longer exists) and 502 (`Source
 * unavailable`) get tailored copy with a Retry that invalidates the capability
 * query. An un-configured GitHub App is NOT an error for browse (anonymous
 * fallback), so a healthy anonymous browse never lands here.
 *
 * Re-homed from the deleted `/sources` route; exported for direct unit testing
 * without mounting the full suspense graph.
 */
export function SourceExplorerError({
  error,
  resetErrorBoundary,
}: {
  error: Error;
  resetErrorBoundary?: () => void;
}) {
  const status = error instanceof ApiError ? error.status : 0;
  const queryClient = useQueryClient();

  const copy = sourceErrorCopy(status);
  const title = copy.title;
  const detail =
    copy.detail ?? (error instanceof Error ? error.message : "Unexpected error.");

  const onRetry = () => {
    queryClient.invalidateQueries({ queryKey: getSourceCapabilitiesKey() });
    invalidateBusinessLists(queryClient);
    resetErrorBoundary?.();
  };

  return (
    <div className="p-6 space-y-4">
      <h1 className="text-2xl font-semibold tracking-tight">{title}</h1>
      <p className="text-sm text-muted-foreground">{detail}</p>
      <div className="flex gap-2">
        <Button onClick={onRetry}>Retry</Button>
      </div>
    </div>
  );
}
