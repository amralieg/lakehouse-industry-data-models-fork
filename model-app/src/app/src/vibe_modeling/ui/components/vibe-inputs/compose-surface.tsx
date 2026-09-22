import { Suspense, useMemo, useState } from "react";
import { useNavigate } from "@tanstack/react-router";
import { useQueryClient, QueryErrorResetBoundary } from "@tanstack/react-query";
import { ErrorBoundary } from "react-error-boundary";
import { notifyError } from "@/lib/notify";
import { Skeleton } from "@/components/ui/skeleton";
import { Button } from "@/components/ui/button";
import { AlertTriangle, ArrowRight } from "lucide-react";
import {
  useListVibeInputsSuspense,
  useGetModelSummarySuspense,
  useGetReviewQueueSuspense,
  useCreateVibeInput,
  useUpdateVibeInput,
  useSetVibeInputSelection,
  deleteVibeInput,
  listVibeInputsKey,
  VibeInputPriority,
  type VibeInputOut,
} from "@/lib/api";
import { selector } from "@/lib/selector";
import { useDebouncedValue } from "@/lib/hooks";
import { FiltersBar, DEFAULT_FILTERS, applyFilters, type InputFilters } from "./filters-bar";
import { SectionTree } from "./section-tree";
import { CompiledPreview } from "./compiled-preview";
import { FollowingPane } from "./following-pane";
import { InputMarkdownEditorDialog } from "./input-markdown-editor-dialog";
import { ReviewQueueDialog } from "./review-queue-dialog";
import { invalidateVibeInputQueries } from "./query-keys";
import { invalidateEntityLists } from "@/lib/delete-invalidation";
import type { SectionAnchorIds } from "./section-tree-model";

export interface ComposeSurfaceProps {
  businessId: string;
  version: string;
  scope: string;
  /** The resolved DB version id (origin link anchor + queue scope). */
  versionId: string;
}

export function ComposeSurface(props: ComposeSurfaceProps) {
  return (
    <QueryErrorResetBoundary>
      {({ reset }) => (
        <ErrorBoundary
          onReset={reset}
          fallbackRender={({ resetErrorBoundary }) => (
            <div className="p-6 text-sm">
              <p className="text-destructive">Couldn't load inputs.</p>
              <Button variant="outline" size="sm" className="mt-2" onClick={resetErrorBoundary}>
                Try again
              </Button>
            </div>
          )}
        >
          <Suspense fallback={<Skeleton className="m-4 h-[70vh] w-auto" />}>
            <ComposeSurfaceContent {...props} />
          </Suspense>
        </ErrorBoundary>
      )}
    </QueryErrorResetBoundary>
  );
}

function ComposeSurfaceContent({ businessId, version, scope, versionId }: ComposeSurfaceProps) {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  const [filters, setFilters] = useState<InputFilters>(DEFAULT_FILTERS);
  const debouncedQ = useDebouncedValue(filters.q, 250);
  const [rightMode, setRightMode] = useState<"preview" | "subgraph">("preview");
  const [focusedId, setFocusedId] = useState<string | null>(null);
  const [editorInput, setEditorInput] = useState<VibeInputOut | null>(null);
  const [reviewOpen, setReviewOpen] = useState(false);

  // Scope the list to the version being viewed so the section tree shows (and
  // the backend hydrates anchors for) inputs anchored to THIS version — not the
  // global head. Without this, inputs added on a non-head version page render
  // with a null anchor and vanish from the tree.
  const { data: allInputs } = useListVibeInputsSuspense({
    params: { business_id: businessId, version_id: versionId },
    ...selector(),
  });
  const { data: model } = useGetModelSummarySuspense({
    params: { business_id: businessId, version_int: Number(version), scope },
    ...selector(),
  });
  const domains = useMemo(
    () =>
      (model.domains ?? [])
        .filter((d: any) => d.change_status !== "deleted")
        .map((d: any) => ({ name: d.name, division: d.division ?? "" })),
    [model],
  );

  const create = useCreateVibeInput();
  const update = useUpdateVibeInput();

  // Selection lives on the server (`selected_for_run`). The single-card toggle
  // and the select-all-under-branch action share one mutation key and reconcile
  // via a whole-list invalidate on settle, so a bulk call never clobbers an
  // in-flight single toggle.
  const inputsKey = listVibeInputsKey({ business_id: businessId, version_id: versionId });
  const selection = useSetVibeInputSelection({
    mutation: {
      mutationKey: ["set-vibe-input-selection", businessId, versionId],
      onMutate: async ({ data }) => {
        await queryClient.cancelQueries({ queryKey: inputsKey });
        const previous = queryClient.getQueryData<{ data: VibeInputOut[] }>(inputsKey);
        const ids = new Set(data.input_ids);
        queryClient.setQueryData<{ data: VibeInputOut[] }>(inputsKey, (curr) =>
          curr
            ? {
                data: curr.data.map((i) =>
                  ids.has(i.id) ? { ...i, selected_for_run: data.selected } : i,
                ),
              }
            : curr,
        );
        return { previous };
      },
      onError: (_err, _vars, context) => {
        const prev = (context as { previous?: { data: VibeInputOut[] } } | undefined)?.previous;
        if (prev) queryClient.setQueryData(inputsKey, prev);
      },
      onSettled: () => invalidateVibeInputQueries(queryClient, businessId),
    },
  });

  // The selected set is the single source of truth for the count, the compiled
  // preview, the branch select-all state, and the Start-run CTA.
  const selectedIds = useMemo(() => {
    const s = new Set<string>();
    for (const i of allInputs) {
      if (i.status === "deprecated" || i.consumed || !i.anchor) continue;
      if (i.selected_for_run) s.add(i.id);
    }
    return s;
  }, [allInputs]);
  const selectedCount = selectedIds.size;

  // Client-side filtering on the already-fetched list (server filtering is the
  // alternate path; for the compose surface we keep the full list to drive the
  // compiled preview and just narrow what the tree shows).
  const filtered = useMemo(
    () => applyFilters(allInputs, { ...filters, q: debouncedQ }, selectedIds),
    [allInputs, filters, debouncedQ, selectedIds],
  );
  const filterActive =
    debouncedQ.trim() !== "" ||
    filters.origin !== "all" ||
    filters.state !== "all" ||
    filters.priority !== "all" ||
    filters.selected !== "all";

  const focusedInput = focusedId ? allInputs.find((i) => i.id === focusedId) ?? null : null;

  const setSelection = (inputIds: string[], selected: boolean) => {
    if (inputIds.length === 0) return;
    selection.mutate({
      params: { business_id: businessId },
      data: { input_ids: inputIds, selected },
    });
  };

  const toggleInclude = (input: VibeInputOut, included: boolean) =>
    setSelection([input.id], included);

  const startRun = () => {
    navigate({
      to: "/businesses/$businessId/runs/new",
      params: { businessId },
      search: {
        operationType: "vibe modeling of version",
        sourceVersion: Number(version),
        sourceScope: scope,
      },
    });
  };

  const commitText = (input: VibeInputOut, text: string) => {
    update.mutate(
      { params: { business_id: businessId, input_id: input.id }, data: { text } },
      { onSuccess: () => invalidateVibeInputQueries(queryClient, businessId) },
    );
  };

  const addInput = (anchorIds: SectionAnchorIds, text: string, priority: VibeInputPriority) => {
    create.mutate(
      {
        params: { business_id: businessId },
        data: { text, priority, version_id: versionId, ...anchorIds },
      },
      { onSuccess: () => invalidateVibeInputQueries(queryClient, businessId) },
    );
  };

  const removeInput = (input: VibeInputOut) =>
    deleteVibeInput({ business_id: businessId, input_id: input.id })
      .then(() => invalidateEntityLists(queryClient, "vibeInput", { businessId }))
      .catch((e: unknown) => notifyError(e, { fallback: "Failed to delete input" }));

  const openInModel = (input: VibeInputOut) => {
    // The card-details route file is generated by the router plugin at
    // dev/build; until the route tree regenerates, navigate via the resolved
    // path string.
    navigate({
      to: `/businesses/${businessId}/model/${version}/${scope}/inputs/${input.id}`,
    });
  };

  return (
    <div className="flex h-full flex-col">
      <Suspense fallback={null}>
        <ReviewSection
          businessId={businessId}
          versionId={versionId}
          open={reviewOpen}
          onOpenChange={setReviewOpen}
        />
      </Suspense>
      <div className="flex items-center justify-between border-b border-border px-4 py-2">
        <span className="text-sm font-semibold tracking-tight">Compose inputs</span>
        <Button
          size="sm"
          disabled={selectedCount === 0}
          onClick={startRun}
          data-testid="start-run-cta"
        >
          Start run · {selectedCount} selected
          <ArrowRight className="ml-1 h-4 w-4" />
        </Button>
      </div>
      <div className="grid min-h-0 flex-1 grid-cols-[1.35fr_1fr]">
        {/* Left: filters + section tree */}
        <div className="flex min-h-0 flex-col border-r border-border">
          <FiltersBar
            filters={filters}
            onChange={setFilters}
            shown={filtered.length}
            total={
              filters.state === "deprecated"
                ? allInputs.filter((i) => i.status === "deprecated").length
                : allInputs.filter((i) => i.status !== "deprecated").length
            }
          />
          <div className="min-h-0 flex-1 overflow-auto p-2">
            <SectionTree
              inputs={filtered}
              includedIds={selectedIds}
              filterActive={filterActive}
              onToggleInclude={toggleInclude}
              onCommitText={commitText}
              onOpenInModel={openInModel}
              onExpand={setEditorInput}
              onResolveReview={() => setReviewOpen(true)}
              onFocus={(i) => setFocusedId(i.id)}
              onAddInput={addInput}
              onSelectSubtree={setSelection}
              onDelete={removeInput}
            />
            {/* The Deprecated filter routes deprecated inputs into the tree
                above, so the standalone group would duplicate them — only
                show it when the filter is NOT scoped to deprecated. */}
            {filters.state !== "deprecated" && (
              <DeprecatedSection inputs={allInputs} />
            )}
          </div>
        </div>

        {/* Right: segmented preview / subgraph */}
        <div className="flex min-h-0 flex-col bg-muted">
          <div className="flex items-center gap-1 border-b border-border p-2">
            <SegButton active={rightMode === "preview"} onClick={() => setRightMode("preview")}>
              Compiled preview
            </SegButton>
            <SegButton active={rightMode === "subgraph"} onClick={() => setRightMode("subgraph")}>
              Model subgraph
            </SegButton>
          </div>
          <div className="min-h-0 flex-1">
            {rightMode === "preview" ? (
              <CompiledPreview inputs={allInputs} includedIds={selectedIds} />
            ) : (
              <FollowingPane
                businessId={businessId}
                version={version}
                scope={scope}
                domains={domains}
                focusedInput={focusedInput}
                active={rightMode === "subgraph"}
              />
            )}
          </div>
        </div>
      </div>

      <InputMarkdownEditorDialog
        businessId={businessId}
        input={editorInput}
        open={editorInput != null}
        onOpenChange={(o) => !o && setEditorInput(null)}
        anchorLabel={editorInput?.anchor?.path?.join(" › ")}
      />
    </div>
  );
}

/**
 * Review banner (top) + queue dialog, driven by the LIVE review-queue total.
 * Suspends independently so a slow queue read doesn't block the compose
 * surface. The banner shows iff ≥1 link needs review; the dialog mounts only
 * when opened.
 */
function ReviewSection({
  businessId,
  versionId,
  open,
  onOpenChange,
}: {
  businessId: string;
  versionId: string;
  open: boolean;
  onOpenChange: (o: boolean) => void;
}) {
  const { data } = useGetReviewQueueSuspense({
    params: { business_id: businessId, version_id: versionId },
    ...selector(),
  });
  const total = data.total ?? 0;
  const items = data.items ?? [];
  return (
    <>
      {total > 0 && (
        <div className="flex items-center gap-2 border-b border-warning/40 bg-warning/10 px-4 py-2 text-sm">
          <AlertTriangle className="h-4 w-4 text-warning" />
          <span>
            {total} input{total === 1 ? "" : "s"} need link review after the last run.
          </span>
          <Button variant="outline" size="sm" className="ml-auto" onClick={() => onOpenChange(true)}>
            Open review queue
          </Button>
        </div>
      )}
      {open && (
        <ReviewQueueDialog
          businessId={businessId}
          open
          onOpenChange={onOpenChange}
          items={items}
        />
      )}
    </>
  );
}

function SegButton({
  active,
  onClick,
  children,
}: {
  active: boolean;
  onClick: () => void;
  children: React.ReactNode;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-pressed={active}
      className={
        "rounded-sm px-3 py-1 text-xs font-medium transition-colors " +
        (active
          ? "bg-background text-foreground shadow-sm"
          : "text-muted-foreground hover:text-foreground")
      }
    >
      {children}
    </button>
  );
}

/** Deprecated section — collapsed group at the bottom; only when non-empty. */
function DeprecatedSection({ inputs }: { inputs: readonly VibeInputOut[] }) {
  const [open, setOpen] = useState(false);
  const deprecated = inputs.filter((i) => i.status === "deprecated");
  if (deprecated.length === 0) return null;
  return (
    <div className="mt-4 border-t border-border pt-2">
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        className="text-xs font-semibold uppercase tracking-wide text-muted-foreground"
      >
        Deprecated ({deprecated.length})
      </button>
      {open && (
        <div className="mt-2 space-y-1">
          {deprecated.map((i) => (
            <div key={i.id} className="rounded-md border border-border bg-muted p-2 text-sm text-muted-foreground line-through">
              {i.text}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
