import { useCallback, useEffect, useState, type ReactNode } from "react";
import {
  useGetBusinessSuspense,
  useGetModelSummarySuspense,
  useListVersionsSuspense,
  useGetUserPreferences,
  getDiagramLayout,
} from "@/lib/api";
import type { FeedbackContext } from "@/lib/api";
import type { ColumnDisplayMode } from "@/components/diagram/types";
import { selector } from "@/lib/selector";
import { Badge } from "@/components/ui/badge";
import { VersionSyncStateBanner } from "@/components/versions/version-sync-state-banner";
import { ModelView, type ModelViewTab, type ModelViewFocusAnchor } from "@/components/vibe-inputs/model-view";
import { AddFeedbackButton } from "@/components/feedback/add-feedback-button";
import { StatisticsTab } from "@/components/statistics/statistics-tab";
import { makeDefaultTargetPath } from "@/lib/source-selection";
import { ModelOverview } from "@/components/model/model-overview";

// Per-user default column-display mode preference keys (item 4, 0.6.6). The
// all-domains view (index route, no focusAnchor) and the focal single-domain
// view (input route, focusAnchor.domain set) each have their own default, kept
// in sync with Settings > Diagram (settings.tsx) and the domain route.
const DIAGRAM_ALL_DOMAINS_MODE_KEY = "diagram.default_column_mode";
const DIAGRAM_FOCAL_MODE_KEY = "diagram.default_column_mode_focal";

/**
 * The full model-page orchestration around the shared `ModelView` tab bar:
 * the three suspense fetches (business, model summary, versions) + current
 * version resolution, the diagram-selection feedback context, the standard tab
 * bodies (Overview, Statistics, sync banner), the column-mode preference gate,
 * the ELK cache warm, and the single-home Add-feedback affordance. Both the
 * model-version route and the input-review route render this, so the input
 * surface inherits the FULL tab set (Overview / Diagram / Relationships /
 * Ontology / Artifacts / Feedback / Statistics) for free instead of a
 * hand-wired subset.
 *
 * What this does NOT own (stays per-route): the `?tab=` param (router-owned,
 * passed in as `tab` + `onTabChange`), `useBreadcrumbs`, and the destructive
 * `DeleteVersionButton` (injected via `versionActions` so the button and its
 * invalidation logic stay in the model-version route).
 *
 * Single-home Add-feedback (app-wide principle): ONE Add-feedback affordance
 * per surface. The shell builds it once (bound to the feedback context it
 * assembles) and places it by the active tab - into the diagram toolbar via
 * `ModelView.feedbackSlot` on the Diagram tab (where `ModelView` suppresses
 * `tabBarTrailing`), and into `tabBarTrailing` on every other tab. This is the
 * reference implementation of the single-home rule for non-diagram tabs.
 */
export function ModelTabsShell({
  businessId,
  version,
  scope,
  tab,
  onTabChange,
  focusAnchor,
  versionActions,
  searchTrigger,
  domainSelectorSlot,
  onDomainNavigate,
  showDomainSelect,
  tabs,
  showLifecycleActions = true,
}: {
  businessId: string;
  version: string;
  scope: string;
  /** Router-owned `?tab=` value + setter. Each route wires its own so the
   *  shared shell never hardcodes a `from` route id. */
  tab: ModelViewTab;
  onTabChange: (tab: ModelViewTab) => void;
  /** Input route: single-domain focus. Index route: undefined (all-domains). */
  focusAnchor?: ModelViewFocusAnchor;
  /** Index route injects `DeleteVersionButton`; the input route omits it (a
   *  review surface offers no version deletion). Rendered in `tabBarTrailing`
   *  next to Add-feedback. */
  versionActions?: ReactNode;
  /** Item 2: the model-wide search trigger, mounted in the header region. */
  searchTrigger?: ReactNode;
  /** URL-driven domain-title dropdown (item 3B), rendered in the header next
   *  to the model title. Only the two model routes (all-domains index,
   *  domain page) pass this - the input-review route stays without it. */
  domainSelectorSlot?: ReactNode;
  /** Forwarded to `ModelView` -> `DiagramViewer` (item 3B): domain selection
   *  navigates via this callback instead of internal state. */
  onDomainNavigate?: (domain: string | null) => void;
  /** Forwarded to `ModelView` -> `DiagramViewer` (item 3B): hides the
   *  diagram toolbar's own domain dropdown once the title owns it. */
  showDomainSelect?: boolean;
  /** Which tabs to render. Defaults to the full set. */
  tabs?: readonly ModelViewTab[];
  /** Threaded to `ModelOverview`: the input surface passes `false` to suppress
   *  the run/install `CommandStrip`. */
  showLifecycleActions?: boolean;
}) {
  // Capture the diagram's current node/edge selection so the single Add-feedback
  // affordance can scope to a specific table or relationship on the diagram tab.
  const [diagramSelection, setDiagramSelection] = useState<{
    nodeId: string | null;
    edgeId: string | null;
  }>({ nodeId: null, edgeId: null });
  const handleDiagramSelection = useCallback(
    (sel: { nodeId: string | null; edgeId: string | null }) => setDiagramSelection(sel),
    [],
  );

  const getContext = useCallback((): FeedbackContext => {
    return {
      context_version: 1,
      view_mode: tab,
      // The diagram tab is the only one with a live node/edge selection.
      // Leave both fields unset on other tabs so the scope doesn't falsely
      // narrow to a stale selection.
      selected_node_id: tab === "diagram" ? diagramSelection.nodeId : null,
      selected_edge_id: tab === "diagram" ? diagramSelection.edgeId : null,
    };
  }, [tab, diagramSelection.nodeId, diagramSelection.edgeId]);

  const { data: business } = useGetBusinessSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  const { data: model } = useGetModelSummarySuspense({
    params: { business_id: businessId, version_int: Number(version), scope },
    ...selector(),
  });
  const { data: versions } = useListVersionsSuspense({
    params: { business_id: businessId },
    ...selector(),
  });

  // Non-suspense preference lookup gates the DiagramViewer mount (ModelView
  // defers the diagram tab while `columnModePending`), so its useState-once
  // column-mode seed reads the resolved preference instead of the fallback.
  // The focal single-domain view and the all-domains view use different keys.
  const focal = Boolean(focusAnchor?.domain);
  const { data: userPrefs, isLoading: columnModePending } = useGetUserPreferences();
  const columnModePref = userPrefs?.data.find(
    (p) => p.key === (focal ? DIAGRAM_FOCAL_MODE_KEY : DIAGRAM_ALL_DOMAINS_MODE_KEY),
  )?.value as ColumnDisplayMode | undefined;

  // Two MV rows can share `version` if their `scope` differs (the model-versioning work),
  // so use `(version, scope)` as the natural key. Fall back to the
  // version-only match if scope is unknown (legacy callers).
  const currentVersion =
    versions.find(
      (v: any) => v.version === Number(version) && (v.scope || "") === scope,
    ) ?? versions.find((v: any) => v.version === Number(version));
  const currentVersionId = (currentVersion as any)?.id as string | undefined;
  const scopeLabel = scope ? scope.toUpperCase() : "";

  const domainList = (model.domains ?? [])
    .filter((d) => d.change_status !== "deleted")
    .map((d) => ({ name: d.name, division: d.division ?? "" }));

  // Warm the diagram cache so the first Diagram tab open is fast. Gate the
  // scope: when a focusAnchor is set (input review), warm ONLY that domain's
  // single-domain layout - never the all-domains layout, or a large model
  // (TerraNova) would trigger an all-domains ELK compute from a single-input
  // review. When unset (all-domains scope page), warm the all-domains layout.
  // The all-domains warm always primes the "hide" variant (not the resolved
  // preference): warming a single fixed variant avoids a per-column-mode ELK
  // fan-out that starves the single-threaded worker, and every variant
  // computes cheaply on first request off a warm base.
  const warmDomain = focusAnchor?.domain;
  const warmColumnMode = focal ? (columnModePref ?? "keys") : "hide";
  useEffect(() => {
    getDiagramLayout({
      business_id: businessId,
      version_int: Number(version),
      scope,
      ...(warmDomain ? { domain: warmDomain } : {}),
      column_mode: warmColumnMode,
      prefetch: true,
    }).catch(() => {});
  }, [businessId, version, scope, warmDomain, warmColumnMode]);

  const addFeedback = (
    <AddFeedbackButton
      businessId={businessId}
      versionId={currentVersionId}
      getContext={getContext}
    />
  );

  return (
    <ModelView
      businessId={businessId}
      version={version}
      scope={scope}
      domains={domainList}
      tabs={tabs}
      value={tab}
      onTabChange={onTabChange}
      focusAnchor={focusAnchor}
      initialColumnMode={columnModePref}
      columnModePending={columnModePending}
      onDomainNavigate={onDomainNavigate}
      showDomainSelect={showDomainSelect}
      onSelectionChange={handleDiagramSelection}
      modelVersionId={currentVersionId ?? ""}
      feedbackSlot={addFeedback}
      headerSlot={
        <div className="flex items-center gap-2 min-w-0">
          <h1 className="text-2xl font-semibold tracking-tight flex items-center gap-2 whitespace-nowrap">
            {model.name} v{model.version}
            {scopeLabel && (
              <Badge
                className={scope === "ecm" ? "bg-muted text-foreground border-border" : "bg-info/10 text-info border-info/30"}
                variant="outline"
              >
                {scopeLabel}
              </Badge>
            )}
          </h1>
          {searchTrigger}
          {domainSelectorSlot}
        </div>
      }
      tabBarTrailing={
        <div className="flex items-center gap-2">
          {addFeedback}
          {versionActions}
        </div>
      }
      betweenSlot={
        currentVersion ? <VersionSyncStateBanner version={currentVersion} /> : null
      }
      overviewSlot={
        <ModelOverview
          businessId={businessId}
          businessName={business.name}
          version={version}
          scope={scope}
          versionId={currentVersionId}
          deploymentStatus={(currentVersion as any)?.deployment_status || "draft"}
          model={model}
          modelVersionId={currentVersionId ?? ""}
          defaultTargetPath={makeDefaultTargetPath(
            business.source_repo_path,
            scope,
            Number(version),
          )}
          showLifecycleActions={showLifecycleActions}
        />
      }
      statisticsSlot={
        <StatisticsTab
          model={model}
          scope={scope}
          businessId={businessId}
          versionInt={Number(version)}
        />
      }
    />
  );
}
