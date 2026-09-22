import type { VibeInputOut, VibeInputAnchorOut } from "@/lib/api";

/** Element-id payload to anchor a new input under a section. All optional;
 *  all-null = model-wide. Mirrors VibeInputIn's transient anchor fields. */
export interface SectionAnchorIds {
  domain_id?: string | null;
  subdomain_id?: string | null;
  product_id?: string | null;
  attribute_id?: string | null;
  fk_link_id?: string | null;
}

export interface SectionNode {
  /** Stable id for collapse state + keys. "model" for the model-wide root;
   *  otherwise the joined section path. */
  id: string;
  /** The section path label list (e.g. ["Domain: Sales", "Product: Orders"]).
   *  Model-wide is ["Model-wide"]. */
  path: string[];
  /** Display name (the leaf label without its "Kind: " prefix). */
  name: string;
  /** The label kind: "Model-wide" | "Domain" | "Subdomain" | "Product" |
   *  "Attribute" | "Relationship". Drives the level icon. */
  kind: string;
  depth: number;
  /** Inputs anchored directly at this node (not in a descendant). */
  inputs: VibeInputOut[];
  children: SectionNode[];
  /** Element ids to anchor a new input here. */
  anchorIds: SectionAnchorIds;
  /** Total inputs in this node's whole subtree. */
  subtreeCount: number;
}

const KIND_OF = (label: string): string => {
  if (label === "Model-wide") return "Model-wide";
  return label.split(":", 1)[0];
};

const NAME_OF = (label: string): string => {
  if (label === "Model-wide") return "Model-wide";
  const idx = label.indexOf(": ");
  return idx >= 0 ? label.slice(idx + 2) : label;
};

/** Collect the element ids that correspond to a given depth of the anchor. The
 *  anchor carries the leaf ids; the path index maps to which id is the leaf at
 *  that depth. We accumulate the ancestor ids from the anchor as we descend. */
function anchorIdsForPrefix(
  anchor: VibeInputAnchorOut,
  prefixLen: number,
): SectionAnchorIds {
  // The anchor's path is the full element chain. For a node at prefix depth d
  // (1-based over path), include only the ids up to that level. We can't always
  // tell which id belongs to which path segment by id alone, so we use the
  // kind of each path label to pick the matching id.
  const ids: SectionAnchorIds = {};
  const path = anchor.path ?? [];
  for (let i = 0; i < prefixLen; i++) {
    const kind = KIND_OF(path[i] ?? "");
    if (kind === "Domain") ids.domain_id = anchor.domain_id;
    else if (kind === "Subdomain") ids.subdomain_id = anchor.subdomain_id;
    else if (kind === "Product") ids.product_id = anchor.product_id;
    else if (kind === "Attribute") ids.attribute_id = anchor.attribute_id;
    else if (kind === "Relationship") ids.fk_link_id = anchor.fk_link_id;
  }
  return ids;
}

/**
 * Build the section tree from inputs' hydrated anchors. Only branches that
 * contain (non-deprecated, anchored) inputs are materialized, plus the
 * Model-wide root which always renders. Deprecated and anchor-free inputs are
 * excluded here (deprecated go in the separate Deprecated section).
 */
export function buildSectionTree(inputs: readonly VibeInputOut[]): SectionNode {
  const root: SectionNode = {
    id: "model",
    path: ["Model-wide"],
    name: "Model-wide",
    kind: "Model-wide",
    depth: 0,
    inputs: [],
    children: [],
    anchorIds: {},
    subtreeCount: 0,
  };

  for (const input of inputs) {
    if (input.status === "deprecated") continue;
    const anchor = input.anchor;
    if (!anchor) continue;
    if (anchor.level === "model_wide") {
      root.inputs.push(input);
      continue;
    }
    const path = anchor.path ?? [];
    if (path.length === 0) {
      root.inputs.push(input);
      continue;
    }
    // Descend/create the chain.
    let node = root;
    for (let i = 0; i < path.length; i++) {
      const label = path[i];
      const childPath = path.slice(0, i + 1);
      const childId = childPath.join(" › ");
      let child = node.children.find((c) => c.id === childId);
      if (!child) {
        child = {
          id: childId,
          path: childPath,
          name: NAME_OF(label),
          kind: KIND_OF(label),
          depth: i + 1,
          inputs: [],
          children: [],
          anchorIds: anchorIdsForPrefix(anchor, i + 1),
          subtreeCount: 0,
        };
        node.children.push(child);
      }
      node = child;
    }
    node.inputs.push(input);
  }

  sortAndCount(root);
  return root;
}

/** Recursively name-sort children and compute subtree counts. */
function sortAndCount(node: SectionNode): number {
  node.children.sort((a, b) => a.name.localeCompare(b.name));
  let count = node.inputs.length;
  for (const child of node.children) count += sortAndCount(child);
  node.subtreeCount = count;
  return count;
}

/** Every node id in the tree (for expand/collapse all). */
export function allNodeIds(node: SectionNode): string[] {
  const ids = [node.id];
  for (const child of node.children) ids.push(...allNodeIds(child));
  return ids;
}

/** Every selectable input id under a node's subtree: active, non-consumed
 *  inputs anchored at this node or any descendant. Consumed inputs are moot for
 *  selection so they're skipped. */
export function selectableSubtreeIds(node: SectionNode): string[] {
  const ids: string[] = [];
  const walk = (n: SectionNode) => {
    for (const input of n.inputs) {
      if (input.status === "deprecated" || input.consumed) continue;
      ids.push(input.id);
    }
    for (const child of n.children) walk(child);
  };
  walk(node);
  return ids;
}

/** Aggregate selection state of a node's selectable subtree against a selected
 *  set. "none" when nothing is selectable or selected, "all" when every
 *  selectable id is selected, "some" otherwise. */
export type SubtreeSelectionState = "none" | "some" | "all";

export function subtreeSelectionState(
  node: SectionNode,
  selectedIds: ReadonlySet<string>,
): SubtreeSelectionState {
  const ids = selectableSubtreeIds(node);
  if (ids.length === 0) return "none";
  let selected = 0;
  for (const id of ids) if (selectedIds.has(id)) selected++;
  if (selected === 0) return "none";
  if (selected === ids.length) return "all";
  return "some";
}
