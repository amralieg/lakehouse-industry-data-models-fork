import { useMemo, useState } from "react";
import {
  useListSourceSectorsSuspense,
  useListSourceIndustries,
  useListSourceModels,
  useListSectorsSuspense,
  type SourceCapabilities,
  type SourceModelRef,
} from "@/lib/api";
import { selector } from "@/lib/selector";
import type { SectorLike } from "@/lib/sector";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { cn } from "@/lib/utils";
import {
  Check,
  ChevronDown,
  ChevronRight,
  Factory,
  Layers,
  Table2,
} from "lucide-react";

/**
 * Identifies a model leaf the user picked in the source tree, carrying the
 * local sector hint resolved by display-name match (Story 4 pre-fill seed).
 */
export interface SourceTreeSelection {
  industryId: string;
  /** Source industry display name, used for the best-effort downloaded hint. */
  industryName: string;
  modelId: string;
  /** The selected leaf's scope (e.g. "ecm"), used for the per-scope
   * downloaded hint alongside the industry name. */
  scope: string | null;
  suggestedSectorId: string | null;
}

/** The trailing int of a "vN" version dir name; -1 for anything else. Used
 * only to sort version groups newest-first; ties keep the groups' first-seen
 * order in the flat model list. Mirrors the backend's `_version_num`. */
function versionNum(version: string): number {
  const digits = version.toLowerCase().startsWith("v") ? version.slice(1) : version;
  return /^\d+$/.test(digits) ? parseInt(digits, 10) : -1;
}

/**
 * SourceTree - folder-faithful Industry -> Version -> Scope browse.
 *
 * Sectors load via suspense (the top level always renders). Industries and
 * Models load lazily on expand via the non-suspense list hooks so collapsed
 * nodes don't fetch and a slow GitHub call only blocks its own subtree.
 *
 * The GitHub source has no native sector level (`capabilities.provides_sectors
 * === false`): the synthetic sector is hidden and industries render at the
 * root, reading the sector id off the fetched `sectors[0].id` (never
 * hardcoded). A future source with `provides_sectors === true` keeps the
 * outer sector tier.
 *
 * Selecting a model leaf calls `onSelect` with the `{industry, model}` ids
 * and a `suggestedSectorId` resolved by matching the source sector name
 * against the local sector catalog (display-name match per design Gap 3).
 */
export function SourceTree({
  selectedModelId,
  downloadedScopesByIndustry,
  capabilities,
  onSelect,
}: {
  selectedModelId?: string | null;
  /**
   * Map of lowercased industry name -> lowercased downloaded scopes, used to
   * flag a scope leaf as "already downloaded". The NAME axis stays
   * best-effort (the source industry name may differ from the resulting
   * business's inner-model name); the SCOPE axis is exact (from
   * `BusinessListOut.downloaded_scopes`, computed off the business's actual
   * ModelVersion rows).
   */
  downloadedScopesByIndustry?: ReadonlyMap<string, ReadonlySet<string>>;
  capabilities?: SourceCapabilities | null;
  onSelect: (selection: SourceTreeSelection) => void;
}) {
  const { data: sectors } = useListSourceSectorsSuspense(selector());
  const { data: localSectors } = useListSectorsSuspense(selector());

  if (sectors.length === 0) {
    return (
      <p className="px-2 py-4 text-sm text-muted-foreground">
        No sectors published in this source.
      </p>
    );
  }

  if (capabilities?.provides_sectors === false) {
    const sector = sectors[0];
    const suggestedSectorId = resolveLocalSectorId(sector.name, localSectors);
    return (
      <div className="space-y-0.5">
        <IndustriesList
          sectorId={sector.id}
          suggestedSectorId={suggestedSectorId}
          selectedModelId={selectedModelId}
          downloadedScopesByIndustry={downloadedScopesByIndustry}
          onSelect={onSelect}
          indent={false}
        />
      </div>
    );
  }

  return (
    <div className="space-y-0.5">
      {sectors.map((sector) => (
        <SectorNode
          key={sector.id}
          sectorId={sector.id}
          sectorName={sector.name}
          localSectors={localSectors}
          selectedModelId={selectedModelId}
          downloadedScopesByIndustry={downloadedScopesByIndustry}
          onSelect={onSelect}
        />
      ))}
    </div>
  );
}

/** Match a source sector name to a local sector id by case-insensitive name. */
function resolveLocalSectorId(
  sourceSectorName: string,
  localSectors: readonly SectorLike[],
): string | null {
  const target = sourceSectorName.trim().toLowerCase();
  const match = localSectors.find(
    (s) => s.name.trim().toLowerCase() === target,
  );
  return match ? match.id : null;
}

function SectorNode({
  sectorId,
  sectorName,
  localSectors,
  selectedModelId,
  downloadedScopesByIndustry,
  onSelect,
}: {
  sectorId: string;
  sectorName: string;
  localSectors: readonly SectorLike[];
  selectedModelId?: string | null;
  downloadedScopesByIndustry?: ReadonlyMap<string, ReadonlySet<string>>;
  onSelect: (selection: SourceTreeSelection) => void;
}) {
  const [expanded, setExpanded] = useState(false);
  const suggestedSectorId = resolveLocalSectorId(sectorName, localSectors);

  return (
    <div>
      <button
        onClick={() => setExpanded((e) => !e)}
        className="flex w-full items-center gap-1.5 rounded-md px-1.5 py-1 text-sm hover:bg-sidebar-accent/50"
      >
        {expanded ? (
          <ChevronDown className="h-3.5 w-3.5 shrink-0" />
        ) : (
          <ChevronRight className="h-3.5 w-3.5 shrink-0" />
        )}
        <Layers className="h-3.5 w-3.5 shrink-0" />
        <span className="truncate font-medium">{sectorName}</span>
      </button>
      {expanded && (
        <IndustriesList
          sectorId={sectorId}
          suggestedSectorId={suggestedSectorId}
          selectedModelId={selectedModelId}
          downloadedScopesByIndustry={downloadedScopesByIndustry}
          onSelect={onSelect}
          indent
        />
      )}
    </div>
  );
}

function IndustriesList({
  sectorId,
  suggestedSectorId,
  selectedModelId,
  downloadedScopesByIndustry,
  onSelect,
  indent,
}: {
  sectorId: string;
  suggestedSectorId: string | null;
  selectedModelId?: string | null;
  downloadedScopesByIndustry?: ReadonlyMap<string, ReadonlySet<string>>;
  onSelect: (selection: SourceTreeSelection) => void;
  indent: boolean;
}) {
  const { data, isLoading, isError } = useListSourceIndustries({
    params: { sector_id: sectorId },
  });
  const industries = data?.data ?? [];

  if (isLoading) return <Skeleton className="ml-6 mr-2 h-8 w-full" />;
  if (isError) {
    return (
      <p className="ml-6 px-1.5 py-1 text-xs text-muted-foreground">
        Couldn't load industries.
      </p>
    );
  }
  if (industries.length === 0) {
    return (
      <p className="ml-6 px-1.5 py-1 text-xs text-muted-foreground">
        No industries in this sector.
      </p>
    );
  }

  return (
    <div
      className={cn(
        "mt-0.5 space-y-0.5",
        indent && "ml-4 border-l border-border/40 pl-2",
      )}
    >
      {industries.map((ind) => (
        <IndustryNode
          key={ind.id}
          industryId={ind.id}
          industryName={ind.name}
          suggestedSectorId={suggestedSectorId}
          selectedModelId={selectedModelId}
          downloadedScopesByIndustry={downloadedScopesByIndustry}
          onSelect={onSelect}
        />
      ))}
    </div>
  );
}

function IndustryNode({
  industryId,
  industryName,
  suggestedSectorId,
  selectedModelId,
  downloadedScopesByIndustry,
  onSelect,
}: {
  industryId: string;
  industryName: string;
  suggestedSectorId: string | null;
  selectedModelId?: string | null;
  downloadedScopesByIndustry?: ReadonlyMap<string, ReadonlySet<string>>;
  onSelect: (selection: SourceTreeSelection) => void;
}) {
  const [expanded, setExpanded] = useState(false);
  const downloadedScopes = downloadedScopesByIndustry?.get(
    industryName.trim().toLowerCase(),
  );

  return (
    <div>
      <button
        onClick={() => setExpanded((e) => !e)}
        className="flex w-full items-center gap-1.5 rounded-md px-1.5 py-1 text-xs hover:bg-sidebar-accent/50"
      >
        {expanded ? (
          <ChevronDown className="h-3 w-3 shrink-0" />
        ) : (
          <ChevronRight className="h-3 w-3 shrink-0" />
        )}
        <Factory className="h-3 w-3 shrink-0" />
        <span className="truncate">{industryName}</span>
      </button>
      {expanded && (
        <VersionsList
          industryId={industryId}
          industryName={industryName}
          suggestedSectorId={suggestedSectorId}
          selectedModelId={selectedModelId}
          downloadedScopes={downloadedScopes}
          onSelect={onSelect}
        />
      )}
    </div>
  );
}

/** Groups `listSourceModels(industryId)` by `model.version`, versions sorted
 * newest-first, and renders a `VersionNode` per group. A model with no
 * `version` groups under the empty-string key (rendered without a version
 * badge on its leaf) rather than being dropped. */
function VersionsList({
  industryId,
  industryName,
  suggestedSectorId,
  selectedModelId,
  downloadedScopes,
  onSelect,
}: {
  industryId: string;
  industryName: string;
  suggestedSectorId: string | null;
  selectedModelId?: string | null;
  downloadedScopes?: ReadonlySet<string>;
  onSelect: (selection: SourceTreeSelection) => void;
}) {
  const { data, isLoading, isError } = useListSourceModels({
    params: { industry_id: industryId },
  });
  const models = data?.data ?? [];

  const versionGroups = useMemo(() => {
    const groups = new Map<string, SourceModelRef[]>();
    for (const model of models) {
      const version = model.version ?? "";
      const list = groups.get(version) ?? [];
      list.push(model);
      groups.set(version, list);
    }
    return Array.from(groups.entries()).sort(
      ([a], [b]) => versionNum(b) - versionNum(a),
    );
  }, [models]);

  if (isLoading) return <Skeleton className="ml-6 mr-2 h-6 w-full" />;
  if (isError) {
    return (
      <p className="ml-6 px-1.5 py-1 text-[11px] text-muted-foreground">
        Couldn't load models.
      </p>
    );
  }
  if (models.length === 0) {
    return (
      <p className="ml-6 px-1.5 py-1 text-[11px] text-muted-foreground">
        No models in this industry.
      </p>
    );
  }

  return (
    <div className="ml-3 mt-0.5 space-y-0.5 border-l border-border/30 pl-2">
      {versionGroups.map(([version, versionModels]) => (
        <VersionNode
          key={version || "_unversioned"}
          version={version}
          models={versionModels}
          industryId={industryId}
          industryName={industryName}
          suggestedSectorId={suggestedSectorId}
          selectedModelId={selectedModelId}
          downloadedScopes={downloadedScopes}
          onSelect={onSelect}
        />
      ))}
    </div>
  );
}

function VersionNode({
  version,
  models,
  industryId,
  industryName,
  suggestedSectorId,
  selectedModelId,
  downloadedScopes,
  onSelect,
}: {
  version: string;
  models: SourceModelRef[];
  industryId: string;
  industryName: string;
  suggestedSectorId: string | null;
  selectedModelId?: string | null;
  downloadedScopes?: ReadonlySet<string>;
  onSelect: (selection: SourceTreeSelection) => void;
}) {
  const [expanded, setExpanded] = useState(false);

  return (
    <div>
      <button
        onClick={() => setExpanded((e) => !e)}
        className="flex w-full items-center gap-1.5 rounded px-1.5 py-1 text-left text-[11px] text-muted-foreground hover:bg-sidebar-accent/50"
      >
        {expanded ? (
          <ChevronDown className="h-3 w-3 shrink-0" />
        ) : (
          <ChevronRight className="h-3 w-3 shrink-0" />
        )}
        <Layers className="h-3 w-3 shrink-0" />
        <span className="truncate">{version || "Unversioned"}</span>
      </button>
      {expanded && (
        <div className="ml-3 mt-0.5 space-y-0.5 border-l border-border/20 pl-2">
          {models.map((model) => (
            <ScopeLeaf
              key={model.id}
              model={model}
              isActive={selectedModelId === model.id}
              downloaded={
                downloadedScopes?.has((model.scope ?? "").toLowerCase()) ?? false
              }
              onSelect={() =>
                onSelect({
                  industryId,
                  industryName,
                  modelId: model.id,
                  scope: model.scope ?? null,
                  suggestedSectorId,
                })
              }
            />
          ))}
        </div>
      )}
    </div>
  );
}

function ScopeLeaf({
  model,
  isActive,
  downloaded,
  onSelect,
}: {
  model: SourceModelRef;
  isActive: boolean;
  downloaded?: boolean;
  onSelect: () => void;
}) {
  return (
    <button
      onClick={onSelect}
      className={cn(
        "flex w-full items-center gap-1.5 rounded px-1.5 py-1 text-left text-[11px] transition-colors",
        isActive
          ? "bg-sidebar-accent/60 font-medium text-sidebar-accent-foreground"
          : "text-muted-foreground hover:bg-sidebar-accent/50",
      )}
    >
      <Table2 className="h-3 w-3 shrink-0" />
      <span className="truncate">{model.name}</span>
      {downloaded && (
        <Badge
          variant="outline"
          data-testid="already-downloaded-badge"
          className="ml-auto gap-0.5 px-1 py-0 text-[9px] text-green-600 dark:text-green-400"
        >
          <Check className="h-2.5 w-2.5" />
          Downloaded
        </Badge>
      )}
      {model.version && (
        <Badge
          variant="outline"
          className={cn("px-1 py-0 text-[9px]", !downloaded && "ml-auto")}
        >
          {model.version}
        </Badge>
      )}
      {model.scope && (
        <Badge variant="secondary" className="px-1 py-0 text-[9px]">
          {model.scope.toUpperCase()}
        </Badge>
      )}
    </button>
  );
}
