import { useState } from "react";
import {
  ChevronRight,
  ChevronDown,
  List,
  Database,
  LayoutGrid,
  Table2,
  Link2,
  Minus,
  Plus,
  CheckSquare,
  Square,
  MinusSquare,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { PrioritySelect } from "./priority-select";
import { VibeInputPriority, type VibeInputOut, type VibeInputContextLinkOut } from "@/lib/api";
import {
  buildSectionTree,
  allNodeIds,
  selectableSubtreeIds,
  subtreeSelectionState,
  type SectionNode,
  type SectionAnchorIds,
} from "./section-tree-model";
import { VibeInputCard } from "./vibe-input-card";

const KIND_ICON: Record<string, typeof List> = {
  "Model-wide": List,
  Domain: Database,
  Subdomain: LayoutGrid,
  Product: Table2,
  Relationship: Link2,
  Attribute: Minus,
};

export interface SectionTreeProps {
  inputs: readonly VibeInputOut[];
  /** Per-input selection (inputs selected for the next run). */
  includedIds: ReadonlySet<string>;
  /** Per-input links for state derivation (id → links). Optional. */
  linksByInput?: Record<string, readonly VibeInputContextLinkOut[]>;
  /** Review tooltip per input id. */
  reviewTitleByInput?: Record<string, string>;
  /** True when a filter/search is active → force-expand so matches are visible. */
  filterActive?: boolean;
  onToggleInclude: (input: VibeInputOut, included: boolean) => void;
  onCommitText: (input: VibeInputOut, text: string) => void;
  onOpenInModel: (input: VibeInputOut) => void;
  onExpand: (input: VibeInputOut) => void;
  onResolveReview: (input: VibeInputOut) => void;
  onFocus?: (input: VibeInputOut) => void;
  /** Create a new input anchored to a section. */
  onAddInput: (anchorIds: SectionAnchorIds, text: string, priority: VibeInputPriority) => void;
  /** Select or deselect every selectable input under a node's subtree. */
  onSelectSubtree?: (inputIds: string[], selected: boolean) => void;
  /** When false, cards hide the run-inclusion checkbox (review-only view). */
  selectable?: boolean;
  /** When provided, each card shows a delete action that soft-deletes it. */
  onDelete?: (input: VibeInputOut) => void;
}

export function SectionTree({
  inputs,
  includedIds,
  linksByInput,
  reviewTitleByInput,
  filterActive,
  onToggleInclude,
  onCommitText,
  onOpenInModel,
  onExpand,
  onResolveReview,
  onFocus,
  onAddInput,
  onSelectSubtree,
  selectable = true,
  onDelete,
}: SectionTreeProps) {
  const root = buildSectionTree(inputs);
  const [collapsed, setCollapsed] = useState<Record<string, boolean>>({});
  const [addingId, setAddingId] = useState<string | null>(null);

  const isCollapsed = (id: string) => (filterActive ? false : !!collapsed[id]);
  const expandAll = () => setCollapsed({});
  const collapseAll = () => {
    const m: Record<string, boolean> = {};
    for (const id of allNodeIds(root)) m[id] = true;
    setCollapsed(m);
  };

  const renderNode = (node: SectionNode): React.ReactNode => {
    const isAdding = addingId === node.id;
    // Only branches with inputs render — plus Model-wide always, plus the node
    // currently being added to.
    if (node.subtreeCount === 0 && !isAdding && node.id !== "model") return null;

    const Icon = KIND_ICON[node.kind] ?? Table2;
    const collapsedNow = isCollapsed(node.id);
    const indent = 8 + node.depth * 16;
    const selectableIds = selectableSubtreeIds(node);
    const selectState = subtreeSelectionState(node, includedIds);
    const SelectIcon =
      selectState === "all" ? CheckSquare : selectState === "some" ? MinusSquare : Square;

    return (
      <section key={node.id}>
        <div
          className="group flex items-center gap-1.5 rounded-sm py-1 hover:bg-accent/50"
          style={{ paddingLeft: indent }}
          onDoubleClick={() =>
            setCollapsed((c) => ({ ...c, [node.id]: !isCollapsed(node.id) }))
          }
        >
          <button
            type="button"
            onClick={() =>
              setCollapsed((c) => ({ ...c, [node.id]: !isCollapsed(node.id) }))
            }
            title={collapsedNow ? "Expand" : "Collapse"}
            aria-label={collapsedNow ? "Expand" : "Collapse"}
            className="text-muted-foreground hover:text-foreground"
          >
            {collapsedNow ? (
              <ChevronRight className="h-4 w-4" />
            ) : (
              <ChevronDown className="h-4 w-4" />
            )}
          </button>
          <Icon className="h-3.5 w-3.5 text-muted-foreground" />
          <span className="text-sm font-medium">{node.name}</span>
          <span
            className="ml-1 rounded-sm bg-muted px-1 text-[10px] text-muted-foreground"
            title={`${node.subtreeCount} input${node.subtreeCount === 1 ? "" : "s"} in this section`}
          >
            {node.subtreeCount}
          </span>
          {onSelectSubtree && selectableIds.length > 0 && (
            <button
              type="button"
              onClick={() =>
                onSelectSubtree(selectableIds, selectState !== "all")
              }
              title={
                selectState === "all"
                  ? "Deselect all under this branch"
                  : "Select all under this branch"
              }
              aria-label={
                selectState === "all"
                  ? "Deselect all under this branch"
                  : "Select all under this branch"
              }
              aria-pressed={selectState === "all"}
              data-select-state={selectState}
              className="ml-1 text-muted-foreground hover:text-foreground"
            >
              <SelectIcon className="h-3.5 w-3.5" />
            </button>
          )}
          <button
            type="button"
            onClick={() => {
              setAddingId(node.id);
              setCollapsed((c) => ({ ...c, [node.id]: false }));
            }}
            className="ml-auto mr-2 hidden items-center gap-1 text-xs text-primary hover:underline group-hover:inline-flex"
          >
            <Plus className="h-3 w-3" /> Add instruction
          </button>
        </div>

        {!collapsedNow && (
          <>
            {(node.inputs.length > 0 || isAdding) && (
              <div className="space-y-2 py-1" style={{ paddingLeft: indent + 30 }}>
                {node.inputs.map((input) => (
                  <VibeInputCard
                    key={input.id}
                    input={input}
                    included={includedIds.has(input.id)}
                    links={linksByInput?.[input.id]}
                    reviewTitle={reviewTitleByInput?.[input.id]}
                    onToggleInclude={(v) => onToggleInclude(input, v)}
                    onCommitText={(t) => onCommitText(input, t)}
                    onOpenInModel={() => onOpenInModel(input)}
                    onExpand={() => onExpand(input)}
                    onResolveReview={() => onResolveReview(input)}
                    onFocus={onFocus ? () => onFocus(input) : undefined}
                    selectable={selectable}
                    onDelete={onDelete ? () => onDelete(input) : undefined}
                  />
                ))}
                {isAdding && (
                  <AddInstructionComposer
                    name={node.name}
                    onAdd={(text, priority) => {
                      onAddInput(node.anchorIds, text, priority);
                      setAddingId(null);
                    }}
                    onCancel={() => setAddingId(null)}
                  />
                )}
              </div>
            )}
            {node.children.map((child) => renderNode(child))}
          </>
        )}
      </section>
    );
  };

  return (
    <div>
      <div className="flex items-center justify-between border-b border-border px-2 py-1.5">
        <span className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
          Model hierarchy
        </span>
        <div className="flex items-center gap-2 text-xs">
          <button type="button" onClick={expandAll} className="text-primary hover:underline">
            Expand all
          </button>
          <span className="text-muted-foreground">·</span>
          <button type="button" onClick={collapseAll} className="text-primary hover:underline">
            Collapse all
          </button>
        </div>
      </div>
      <div className="py-1">{renderNode(root)}</div>
    </div>
  );
}

/** Inline composer for a new instruction anchored to a section. Controlled
 *  value; ⌘↵ or Add commits, Esc cancels. */
function AddInstructionComposer({
  name,
  onAdd,
  onCancel,
}: {
  name: string;
  onAdd: (text: string, priority: VibeInputPriority) => void;
  onCancel: () => void;
}) {
  const [text, setText] = useState("");
  const [priority, setPriority] = useState<VibeInputPriority>(VibeInputPriority.medium);
  return (
    <div className="rounded-md border border-border bg-card p-2">
      <Textarea
        autoFocus
        value={text}
        onChange={(e) => setText(e.target.value)}
        placeholder={
          name === "Model-wide"
            ? "New model-wide instruction…"
            : `New instruction for ${name}…`
        }
        rows={2}
        className="text-sm"
        onKeyDown={(e) => {
          if (e.key === "Enter" && (e.metaKey || e.ctrlKey) && text.trim()) {
            e.preventDefault();
            onAdd(text.trim(), priority);
          }
          if (e.key === "Escape") onCancel();
        }}
      />
      <div className="mt-2 flex items-center justify-between">
        <span className="text-xs text-muted-foreground">
          Creates a new Vibe Input anchored to <b>{name}</b>
        </span>
        <div className="flex items-center gap-2">
          <PrioritySelect value={priority} onValueChange={setPriority} />
          <Button variant="ghost" size="sm" onClick={onCancel}>
            Cancel
          </Button>
          <Button size="sm" onClick={() => text.trim() && onAdd(text.trim(), priority)}>
            Add
          </Button>
        </div>
      </div>
    </div>
  );
}
