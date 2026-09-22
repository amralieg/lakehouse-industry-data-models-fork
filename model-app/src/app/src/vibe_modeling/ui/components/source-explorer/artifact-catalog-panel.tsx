import { useMemo } from "react";
import type { ModelArtifact, SourceCapabilities, TargetKind } from "@/lib/api";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import {
  CheckCircle2,
  Crosshair,
  FileCode,
  FileText,
  GitBranch,
  Image,
  Layers,
  Network,
  type LucideIcon,
} from "lucide-react";

/**
 * ArtifactCatalogPanel — Story 5 (industry-artifact-import).
 *
 * DISTINCT surface from ``components/artifacts/artifacts-tab.tsx`` (which uses
 * ``useListArtifactsSuspense`` for LOCAL materialized run artifacts). This panel
 * renders the SOURCE-side artifact catalog PURELY off ``ModelPreviewOut.artifacts``
 * — no separate fetch. Do not unify the two.
 *
 * Each known artifact type renders one of two states:
 *   - found            : a matching ``ModelArtifact`` resolved in the source.
 *   - not-found-known  : a known type with no shipped artifact; offers a
 *                        "Locate in source" affordance (AC 2) so the user can
 *                        point at a file by navigating the structure.
 *
 * When the source tier doesn't support artifact detection, the whole panel
 * degrades to an "unavailable" line.
 */

interface KnownType {
  kind: TargetKind;
  label: string;
  icon: LucideIcon;
}

// The known-artifact catalog, in display order. ``model_json`` is the model
// itself (always present in a preview) so it's not listed as a discoverable
// side artifact; the discoverable side artifacts are the rest.
const KNOWN_TYPES: KnownType[] = [
  { kind: "schemas", label: "Schemas", icon: FileCode },
  { kind: "metrics", label: "Metrics", icon: Layers },
  { kind: "ontology", label: "Ontology", icon: Network },
  { kind: "diagram", label: "Diagram", icon: Image },
  { kind: "docs", label: "Docs", icon: FileText },
  { kind: "vibes", label: "Vibes", icon: GitBranch },
];

export function ArtifactCatalogPanel({
  artifacts,
  capabilities,
  onLocate,
}: {
  artifacts: ModelArtifact[];
  capabilities?: SourceCapabilities | null;
  /** Opens the source tree scoped for the user to point at a file (AC 2). */
  onLocate?: (kind: TargetKind) => void;
}) {
  // Tier gate: if the source advertises a set of target_kinds and it omits
  // every side-artifact type, artifact detection isn't supported here.
  const detectionUnsupported = useMemo(() => {
    if (!capabilities) return false;
    const supported = new Set(capabilities.target_kinds ?? []);
    return KNOWN_TYPES.every((t) => !supported.has(t.kind));
  }, [capabilities]);

  const byKind = useMemo(() => {
    const map = new Map<TargetKind, ModelArtifact[]>();
    for (const a of artifacts) {
      const list = map.get(a.target_kind) ?? [];
      list.push(a);
      map.set(a.target_kind, list);
    }
    return map;
  }, [artifacts]);

  if (detectionUnsupported) {
    return (
      <div className="rounded-md border border-border bg-muted/30 px-3 py-2 text-xs text-muted-foreground">
        Artifact detection unavailable for this source tier.
      </div>
    );
  }

  return (
    <div className="space-y-1">
      {KNOWN_TYPES.map((t) => {
        const found = byKind.get(t.kind) ?? [];
        return (
          <ArtifactRow
            key={t.kind}
            type={t}
            found={found}
            onLocate={onLocate}
          />
        );
      })}
    </div>
  );
}

function ArtifactRow({
  type,
  found,
  onLocate,
}: {
  type: KnownType;
  found: ModelArtifact[];
  onLocate?: (kind: TargetKind) => void;
}) {
  const Icon = type.icon;
  const isFound = found.length > 0;

  return (
    <div
      className={cn(
        "flex items-center gap-2 rounded-md px-2 py-1.5 text-xs",
        isFound ? "text-foreground" : "text-muted-foreground",
      )}
    >
      <Icon className="h-3.5 w-3.5 shrink-0" />
      <span className="font-medium">{type.label}</span>
      {isFound ? (
        <>
          <CheckCircle2 className="h-3.5 w-3.5 shrink-0 text-success" />
          <span className="truncate font-mono text-[11px] text-muted-foreground">
            {found.length === 1
              ? found[0].path
              : `${found.length} files`}
          </span>
        </>
      ) : (
        <>
          <Badge
            variant="outline"
            className="text-[10px] px-1 py-0 text-muted-foreground"
          >
            not found
          </Badge>
          {onLocate && (
            <Button
              size="sm"
              variant="ghost"
              className="ml-auto h-6 gap-1 px-2 text-[11px]"
              onClick={() => onLocate(type.kind)}
            >
              <Crosshair className="h-3 w-3" />
              Locate in source
            </Button>
          )}
        </>
      )}
    </div>
  );
}
