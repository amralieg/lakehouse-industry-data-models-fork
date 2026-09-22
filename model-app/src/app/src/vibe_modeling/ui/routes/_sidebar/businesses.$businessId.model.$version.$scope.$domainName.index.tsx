import { createFileRoute, Link, useNavigate, useSearch } from "@tanstack/react-router";
import { Suspense, useCallback, useState } from "react";
import {
  useGetBusinessSuspense,
  useGetDomainDetailSuspense,
  useGetExplorerVersionsSuspense,
  useGetModelSummarySuspense,
  useGetUserPreferences,
} from "@/lib/api";
import type { ColumnDisplayMode } from "@/components/diagram/types";
import { selector } from "@/lib/selector";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { useBreadcrumbs } from "@/components/explorer/breadcrumb-context";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { Database, FolderOpen, GitGraph, Globe, Key, Layers, Link2 } from "lucide-react";
import { ChangeBadge, changeRowClassName } from "@/components/explorer/change-badge";
import { DiagramViewer } from "@/components/diagram/diagram-viewer";
import { DomainSelect } from "@/components/diagram/domain-select";
import { RelationshipAnalysis } from "@/components/explorer/relationship-analysis";
import { OntologyGraph } from "@/components/explorer/ontology-graph";
import { AddFeedbackButton } from "@/components/feedback/add-feedback-button";

// Focal (single-domain) default column-display mode preference key (item 4,
// 0.6.6). Kept in sync with the Settings > Diagram tab (settings.tsx) and
// the all-domains counterpart on the scope route ($scope.index.tsx).
const DIAGRAM_FOCAL_MODE_KEY = "diagram.default_column_mode_focal";

const validTabs = ["products", "diagram", "relationships", "ontology"] as const;
type DomainTab = (typeof validTabs)[number];

// Tabs this domain page shares with the scope-level page (item 3B). Picking
// "All domains" keeps these as-is; the domain-only "products" tab has no
// scope-level equivalent and maps to "overview" there.
const SHARED_WITH_SCOPE_TABS = new Set(["diagram", "relationships", "ontology"]);

export const Route = createFileRoute(
  "/_sidebar/businesses/$businessId/model/$version/$scope/$domainName/"
)({
  // `focusProduct` (optional) is set by model-wide search when landing on a
  // table hit: the diagram tab seeds to this domain and focuses that product
  // node. Bare domain hits omit it (plain single-domain diagram).
  validateSearch: (
    search: Record<string, unknown>,
  ): { tab: DomainTab; focusProduct?: string } => ({
    tab: validTabs.includes(search.tab as DomainTab)
      ? (search.tab as DomainTab)
      : "products",
    ...(typeof search.focusProduct === "string" && search.focusProduct
      ? { focusProduct: search.focusProduct }
      : {}),
  }),
  component: () => {
    const { businessId, version, scope, domainName } = Route.useParams();
    return (
      <div className="p-4 space-y-3">
        <Suspense fallback={<PageSkeleton />}>
          <DomainDetail
            businessId={businessId}
            version={version}
            scope={scope}
            domainName={domainName}
          />
        </Suspense>
      </div>
    );
  },
});

export function DomainDetail({
  businessId,
  version,
  scope,
  domainName,
}: {
  businessId: string;
  version: string;
  scope: string;
  domainName: string;
}) {
  const navigate = useNavigate();
  const { tab, focusProduct } = useSearch({
    from: "/_sidebar/businesses/$businessId/model/$version/$scope/$domainName/",
  });

  const setTab = (value: string) => {
    navigate({
      to: ".",
      search: { tab: value as DomainTab },
      replace: true,
    });
  };

  const { data: business } = useGetBusinessSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  const { data: domain } = useGetDomainDetailSuspense({
    params: {
      business_id: businessId,
      version_int: Number(version),
      scope,
      domain_name: domainName,
    },
    ...selector(),
  });
  const { data: model } = useGetModelSummarySuspense({
    params: { business_id: businessId, version_int: Number(version), scope },
    ...selector(),
  });
  // Resolve the ModelVersion UUID for the current `version` int so feedback
  // captured from this page records which version it was on. Match on
  // (version, scope) since a single number can host both ECM and MVM.
  const { data: _allVersions } = useGetExplorerVersionsSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  const currentVersionId =
    _allVersions.find(
      (v) => v.version === Number(version) && ((v as any).scope || "") === scope,
    )?.id ?? _allVersions.find((v) => v.version === Number(version))?.id;

  // DiagramViewer seeds columnMode via a useState initializer read ONCE at
  // mount, so mounting it before this preference resolves would
  // permanently lock it onto the hardcoded fallback - a later-resolving
  // initialColumnMode can't retroactively fix an already-mounted
  // useState. This gates the DiagramViewer mount below instead of racing
  // it (the fetch is tiny).
  const { data: userPrefs, isLoading: columnModePending } = useGetUserPreferences();
  const columnModePref = userPrefs?.data.find(
    (p) => p.key === DIAGRAM_FOCAL_MODE_KEY,
  )?.value as ColumnDisplayMode | undefined;

  const domainList = (model.domains ?? [])
    .filter((d) => d.change_status !== "deleted")
    .map((d) => ({ name: d.name, division: d.division ?? "" }));

  const scopeLabel = scope ? scope.toUpperCase() : "";

  useBreadcrumbs([
    {
      label: business.name,
      to: "/businesses/$businessId",
      params: { businessId },
    },
    {
      label: "Explorer",
      to: "/businesses/$businessId/explorer",
      params: { businessId },
    },
    {
      label: scopeLabel ? `v${version} ${scopeLabel}` : `v${version}`,
      to: "/businesses/$businessId/model/$version/$scope",
      params: { businessId, version, scope },
    },
    { label: domainName },
  ]);

  // Track the ER diagram's current selection (table or FK edge) so
  // "Add feedback" while viewing the diagram captures the specific
  // node/edge and not just the domain. The selection only applies while
  // the diagram tab is active - other tabs fall back to domain context.
  const [diagramSelection, setDiagramSelection] = useState<{
    nodeId: string | null;
    edgeId: string | null;
  }>({ nodeId: null, edgeId: null });
  const handleDiagramSelection = useCallback(
    (sel: { nodeId: string | null; edgeId: string | null }) => setDiagramSelection(sel),
    [],
  );

  const getFeedbackContext = useCallback(
    () => ({
      context_version: 1,
      view_mode: tab === "products" ? "domain_tables" : tab,
      domain_filter: domainName,
      // Include the diagram's current selection only when the diagram
      // tab is focused. Elsewhere the selection is stale and shouldn't
      // narrow the feedback scope from domain to a specific table/edge.
      selected_node_id: tab === "diagram" ? diagramSelection.nodeId : null,
      selected_edge_id: tab === "diagram" ? diagramSelection.edgeId : null,
    }),
    [tab, domainName, diagramSelection.nodeId, diagramSelection.edgeId],
  );

  // Item 3B: the title dropdown is the domain page's single domain picker
  // (the diagram toolbar's own is hidden via showDomainSelect={false}
  // below). Picking a domain navigates DOWN to it, preserving the current
  // tab (both pages share diagram/relationships/ontology). Picking "All
  // domains" navigates UP to the scope route - "products" has no
  // scope-level equivalent so it maps to "overview" there. Push (not
  // replace) so the back button walks the domain history.
  const handleDomainNavigate = (domain: string | null) => {
    if (domain === domainName) return;
    if (domain === null) {
      navigate({
        to: "/businesses/$businessId/model/$version/$scope",
        params: { businessId, version, scope },
        search: { tab: SHARED_WITH_SCOPE_TABS.has(tab) ? (tab as "diagram" | "relationships" | "ontology") : "overview" },
      });
      return;
    }
    navigate({
      to: "/businesses/$businessId/model/$version/$scope/$domainName",
      params: { businessId, version, scope, domainName: domain },
      search: { tab },
    });
  };

  return (
    <Tabs value={tab} onValueChange={setTab}>
      <div className="flex items-center gap-3 flex-wrap">
        <Database className="h-5 w-5" />
        <h1 className="text-2xl font-semibold tracking-tight">{domain.name}</h1>
        {domain.division && (
          <Badge variant="outline">{domain.division}</Badge>
        )}
        <DomainSelect
          domains={domainList}
          value={domainName}
          onChange={handleDomainNavigate}
          className="w-56 h-8 text-sm"
        />
        <TabsList>
          <TabsTrigger value="products">
            <Layers className="h-4 w-4 mr-1.5" />
            Products ({(domain.products ?? []).length})
          </TabsTrigger>
          <TabsTrigger value="diagram">
            <GitGraph className="h-4 w-4 mr-1.5" />
            Diagram
          </TabsTrigger>
          <TabsTrigger value="relationships">
            <Link2 className="h-4 w-4 mr-1.5" />
            Relationships
          </TabsTrigger>
          <TabsTrigger value="ontology">
            <Globe className="h-4 w-4 mr-1.5" />
            Ontology
          </TabsTrigger>
        </TabsList>
        {tab !== "diagram" && (
          <AddFeedbackButton
            businessId={businessId}
            versionId={currentVersionId}
            getContext={getFeedbackContext}
            className="ml-auto"
          />
        )}
      </div>
      {domain.description && (
        <p className="text-muted-foreground mt-1 text-sm leading-relaxed">
          {domain.description}
        </p>
      )}
      <div className="flex gap-4 mt-1 text-xs text-muted-foreground">
        {domain.database_name && <span>Schema: {domain.database_name}</span>}
        {domain.references && <span>Ref: {domain.references}</span>}
      </div>

      <TabsContent value="products">
        <ProductsTable
          products={domain.products ?? []}
          businessId={businessId}
          version={version}
          scope={scope}
          domainName={domainName}
        />
      </TabsContent>

      <TabsContent value="diagram">
        <div className="mt-2">
          {columnModePending ? (
            <Skeleton className="h-96 w-full" />
          ) : (
            <DiagramViewer
              // Item 3B: picking another domain (title dropdown, or a
              // related-domain-group click in the diagram) navigates to
              // this SAME route with a new `domainName` param - the router
              // re-renders this component in place rather than remounting
              // it, so `initialDomain`/`initialColumnMode` change as props
              // but DiagramViewer's internal useState-seeded state (which
              // now has no fallback to resync it, item 3B) would otherwise
              // freeze on the old domain. Keying on `domainName` forces a
              // fresh mount on every domain change, matching the reset a
              // cross-route navigation already gets for free.
              key={domainName}
              businessId={businessId}
              version={version}
              scope={scope}
              domains={domainList}
              initialDomain={domainName}
              initialColumnMode={columnModePref}
              focusProduct={focusProduct}
              onSelectionChange={handleDiagramSelection}
              onDomainNavigate={handleDomainNavigate}
              showDomainSelect={false}
              feedbackSlot={
                <AddFeedbackButton
                  businessId={businessId}
                  versionId={currentVersionId}
                  getContext={getFeedbackContext}
                />
              }
            />
          )}
        </div>
      </TabsContent>

      <TabsContent value="relationships">
        <Suspense fallback={<Skeleton className="h-64 w-full" />}>
          <RelationshipAnalysis
            businessId={businessId}
            version={version}
            scope={scope}
          />
        </Suspense>
      </TabsContent>

      <TabsContent value="ontology">
        <Suspense fallback={<Skeleton className="h-96 w-full" />}>
          <OntologyGraph businessId={businessId} version={version} scope={scope} domainFilter={domainName} />
        </Suspense>
      </TabsContent>
    </Tabs>
  );
}

function ProductsTable({
  products,
  businessId,
  version,
  scope,
  domainName,
}: {
  products: any[];
  businessId: string;
  version: string;
  scope: string;
  domainName: string;
}) {
  // Group products by subdomain if any product has one
  const hasSubdomains = products.some((p) => p.subdomain);

  const groups: { subdomain: string; items: any[] }[] = [];
  if (hasSubdomains) {
    const map = new Map<string, any[]>();
    for (const p of products) {
      const key = p.subdomain || "";
      if (!map.has(key)) map.set(key, []);
      map.get(key)!.push(p);
    }
    // Ungrouped first, then alphabetical subdomains
    if (map.has("")) {
      groups.push({ subdomain: "", items: map.get("")! });
      map.delete("");
    }
    for (const [sd, items] of [...map.entries()].sort((a, b) =>
      a[0].localeCompare(b[0])
    )) {
      groups.push({ subdomain: sd, items });
    }
  } else {
    groups.push({ subdomain: "", items: products });
  }

  return (
    <div className="space-y-4">
      {groups.map((group) => (
        <div key={group.subdomain || "__ungrouped"}>
          {hasSubdomains && group.subdomain && (
            <div className="flex items-center gap-2 mb-1 mt-3">
              <FolderOpen className="h-4 w-4 text-muted-foreground" />
              <span className="text-sm font-semibold">{group.subdomain}</span>
              <Badge variant="outline" className="text-[10px] px-1.5 py-0">
                {group.items.length}
              </Badge>
            </div>
          )}
          {hasSubdomains && !group.subdomain && group.items.length > 0 && (
            <div className="flex items-center gap-2 mb-1">
              <span className="text-sm text-muted-foreground italic">
                Ungrouped
              </span>
              <Badge variant="outline" className="text-[10px] px-1.5 py-0">
                {group.items.length}
              </Badge>
            </div>
          )}
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Primary Key</TableHead>
                <TableHead className="text-center">Attrs</TableHead>
                <TableHead className="text-center">FKs</TableHead>
                <TableHead>Description</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {group.items.map((p) => (
                <ProductRow
                  key={p.name}
                  product={p}
                  businessId={businessId}
                  version={version}
                  scope={scope}
                  domainName={domainName}
                />
              ))}
            </TableBody>
          </Table>
        </div>
      ))}
    </div>
  );
}

function ProductRow({
  product: p,
  businessId,
  version,
  scope,
  domainName,
}: {
  product: any;
  businessId: string;
  version: string;
  scope: string;
  domainName: string;
}) {
  const isDeleted = p.change_status === "deleted";
  return (
    <TableRow
      className={`${isDeleted ? "" : "cursor-pointer"} ${changeRowClassName(p.change_status)}`}
    >
      <TableCell>
        <span className="inline-flex items-center gap-2">
          {isDeleted ? (
            <span className="font-medium line-through text-muted-foreground">
              {p.name}
            </span>
          ) : (
            <Link
              to="/businesses/$businessId/model/$version/$scope/$domainName/$productName"
              params={{
                businessId,
                version,
                scope,
                domainName,
                productName: p.name,
              }}
              className="font-medium hover:underline text-info"
            >
              {p.name}
            </Link>
          )}
          <ChangeBadge status={p.change_status} />
        </span>
      </TableCell>
      <TableCell>
        {p.type && <Badge variant="secondary">{p.type}</Badge>}
      </TableCell>
      <TableCell className="text-sm">
        {p.primary_key && (
          <span className="inline-flex items-center gap-1">
            <Key className="h-3 w-3 text-warning" />
            {p.primary_key}
          </span>
        )}
      </TableCell>
      <TableCell className="text-center">{p.attribute_count}</TableCell>
      <TableCell className="text-center">
        {(p.fk_count ?? 0) > 0 && (
          <TooltipProvider delayDuration={200}>
            <Tooltip>
              <TooltipTrigger asChild>
                <span className="inline-flex items-center gap-1 text-info cursor-default">
                  <Link2 className="h-3 w-3" />
                  {p.fk_count}
                </span>
              </TooltipTrigger>
              <TooltipContent side="left">
                <ul className="text-xs font-mono space-y-0.5">
                  {(p.fk_targets ?? []).map((t: string) => (
                    <li key={t}>{t}</li>
                  ))}
                </ul>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>
        )}
      </TableCell>
      <TableCell className="text-muted-foreground text-sm max-w-sm">
        <span className="line-clamp-2">{p.description}</span>
      </TableCell>
    </TableRow>
  );
}

function PageSkeleton() {
  return (
    <div className="space-y-6">
      <Skeleton className="h-8 w-64" />
      <Skeleton className="h-10 w-96" />
      <Skeleton className="h-96 w-full" />
    </div>
  );
}
