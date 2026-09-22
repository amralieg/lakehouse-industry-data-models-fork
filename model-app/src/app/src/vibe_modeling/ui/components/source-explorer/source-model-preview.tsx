import {
  useGetSourceModelPreviewSuspense,
  type SourceCapabilities,
  type TargetKind,
} from "@/lib/api";
import { selector } from "@/lib/selector";
import type { SourceModelSelection } from "@/lib/source-selection";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { MarkdownView } from "@/components/ui/markdown-view";
import { ArtifactCatalogPanel } from "./artifact-catalog-panel";
import { Download } from "lucide-react";

/**
 * SourceModelPreview — Story 3 leaf panel.
 *
 * Loads ``getSourceModelPreview`` for the selected ``{industry_id, model_id}``
 * and renders the model header (scope/version read VERBATIM off the folder
 * path - the version dir is already "v1", never re-prefixed), the model's
 * README rendered as markdown, best-effort domain statistics, and the
 * ``ArtifactCatalogPanel`` (Story 5) off ``preview.artifacts``.
 *
 * The Download affordance produces a ``SourceModelSelection`` and hands it to
 * ``onDownload`` (Track B owns the actual download dialog — Track A only
 * exposes the selection). ``suggestedSectorId`` flows through from the tree
 * (the local sector matched to the source sector by display name).
 */
export function SourceModelPreview({
  industryId,
  modelId,
  suggestedSectorId,
  capabilities,
  alreadyDownloaded,
  onDownload,
  onLocateArtifact,
}: {
  industryId: string;
  modelId: string;
  suggestedSectorId?: string | null;
  capabilities?: SourceCapabilities | null;
  /**
   * Best-effort hint that this model's industry already exists in the
   * workspace (keyed on industry name, not scope — see source-tree). Drives an
   * informational note; the download itself stays enabled (the backend is the
   * authority and will 409 a true same-scope clash).
   */
  alreadyDownloaded?: boolean;
  /** Track B handoff: receives the locked selection contract. */
  onDownload?: (selection: SourceModelSelection) => void;
  /** Story 5 AC 2: scope the source tree to point at a missing artifact. */
  onLocateArtifact?: (kind: TargetKind) => void;
}) {
  const { data: preview } = useGetSourceModelPreviewSuspense({
    params: { industry_id: industryId, model_id: modelId },
    ...selector(),
  });

  const hasStats =
    preview.domains != null ||
    preview.subdomains != null ||
    preview.products != null ||
    preview.attributes != null ||
    preview.primary_keys != null ||
    preview.foreign_keys != null ||
    preview.avg_attrs_per_product != null ||
    preview.metric_views != null;

  const handleDownload = () => {
    onDownload?.({
      industry_id: preview.industry_id,
      model_id: preview.model_id,
      suggested_sector_id: suggestedSectorId ?? null,
    });
  };

  return (
    <Card>
      <CardHeader className="space-y-2">
        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0 space-y-1">
            <CardTitle className="truncate">
              {preview.model_name ?? preview.model_id}
            </CardTitle>
            <div className="flex flex-wrap items-center gap-1.5 text-xs text-muted-foreground">
              {preview.version && (
                <Badge variant="secondary" className="text-[10px]">
                  {preview.version}
                </Badge>
              )}
              {preview.scope && (
                <Badge variant="outline" className="text-[10px]">
                  {preview.scope.toUpperCase()}
                </Badge>
              )}
            </div>
            {hasStats && (
              <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-muted-foreground">
                {preview.domains != null && (
                  <span>{preview.domains} {preview.domains === 1 ? "domain" : "domains"}</span>
                )}
                {preview.subdomains != null && (
                  <span>{preview.subdomains} {preview.subdomains === 1 ? "subdomain" : "subdomains"}</span>
                )}
                {preview.products != null && (
                  <span>{preview.products} {preview.products === 1 ? "product" : "products"}</span>
                )}
                {preview.attributes != null && (
                  <span>{preview.attributes} attributes</span>
                )}
                {preview.primary_keys != null && (
                  <span>{preview.primary_keys} PKs</span>
                )}
                {preview.foreign_keys != null && (
                  <span>{preview.foreign_keys} FKs</span>
                )}
                {preview.avg_attrs_per_product != null && (
                  <span>{preview.avg_attrs_per_product} avg attrs/product</span>
                )}
                {preview.metric_views != null && (
                  <span>{preview.metric_views} metric views</span>
                )}
              </div>
            )}
          </div>
          <Button size="sm" onClick={handleDownload}>
            <Download className="h-4 w-4 mr-1.5" />
            {alreadyDownloaded ? "Download again" : "Download"}
          </Button>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        {alreadyDownloaded && (
          <p
            data-testid="already-downloaded-note"
            className="rounded-md border border-border bg-muted/40 px-3 py-2 text-xs text-muted-foreground"
          >
            A model for this industry is already in your workspace. Downloading
            a model whose scope is already present will be blocked — delete it
            in the app first to re-download.
          </p>
        )}
        <div>
          <h4 className="mb-1.5 text-xs font-medium uppercase tracking-wide text-muted-foreground">
            Artifacts
          </h4>
          <ArtifactCatalogPanel
            artifacts={preview.artifacts}
            capabilities={capabilities}
            onLocate={onLocateArtifact}
          />
        </div>

        <Separator />

        <div>
          <h4 className="mb-1.5 text-xs font-medium uppercase tracking-wide text-muted-foreground">
            Readme
          </h4>
          <div className="max-h-96 overflow-auto rounded-md border border-border bg-muted/40 p-3">
            {preview.readme ? (
              <MarkdownView content={preview.readme} />
            ) : (
              <p className="text-xs text-muted-foreground">
                No README published for this model.
              </p>
            )}
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
