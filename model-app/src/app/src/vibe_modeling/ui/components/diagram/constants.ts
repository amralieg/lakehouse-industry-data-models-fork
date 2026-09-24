/**
 * Diagram rendering constants and color accessors.
 *
 * Sizes and layout tuning live here as literals. All color values resolve from
 * the `--diagram-*` custom properties in globals.css via the diagram-colors
 * helper, so the palette has a single source of truth and tracks the theme.
 */

import { diagramColors } from "./diagram-colors";

export interface ProductTypeColors {
  /** Header bar background — a resolved color string (hex or rgb). */
  bg: string;
  /** Header text utility class. */
  text: string;
  /** Border color — a resolved color string. */
  border: string;
  /** Node fill / legend swatch color. */
  hex: string;
}

const PRODUCT_TYPE_KEYS: Record<string, keyof ReturnType<typeof diagramColors>["productType"]> = {
  master: "master",
  transactional: "transactional",
  reference: "reference",
  association: "association",
};

function productColors(key: keyof ReturnType<typeof diagramColors>["productType"]): ProductTypeColors {
  const hex = diagramColors().productType[key];
  return { bg: hex, text: "text-white", border: hex, hex };
}

/**
 * Product-type colors keyed by canonical type name. Resolved lazily so the
 * CSS variables are read from the live document. Used by the legend and tests.
 */
export const PRODUCT_TYPE_COLORS: Record<string, ProductTypeColors> = {
  get Master() {
    return productColors("master");
  },
  get Transactional() {
    return productColors("transactional");
  },
  get Reference() {
    return productColors("reference");
  },
  get Association() {
    return productColors("association");
  },
  get default() {
    return productColors("default");
  },
};

/** Case-insensitive lookup that falls back to the gray default for unknown types. */
export function getProductTypeColors(
  productType: string | undefined | null,
): ProductTypeColors {
  if (!productType) return productColors("default");
  const key = PRODUCT_TYPE_KEYS[productType.trim().toLowerCase()];
  return key ? productColors(key) : productColors("default");
}

/**
 * Palette of soft colors for domain boundaries. Domains are assigned by index.
 * Each entry carries a tinted `bg`, a stronger `border`, and the solid `label`
 * color, all derived from one `--diagram-domain-N` base hue.
 */
export function getDomainPalette() {
  return diagramColors().domainPalette;
}

/** External domain styling (dashed border, muted fill). */
export function getExternalDomainStyle() {
  return diagramColors().externalDomain;
}

// --- Edge styling ---
export function getEdgeColor() {
  return diagramColors().edge;
}
export function getEdgeSelectedColor() {
  return diagramColors().edgeSelected;
}
export const EDGE_WIDTH = 1.5;
export const EDGE_SELECTED_WIDTH = 2.5;
// Width of the hovered (but not selected) edge — a visible cue that reads
// between the resting and selected weights.
export const EDGE_HOVER_WIDTH = 2.5;
// Width of the invisible interaction (hit-target) path drawn under every edge.
// Deliberately generous so a click near a dense/overlapping edge still lands on
// it without the cursor having to hit the ~1.5px visible stroke exactly.
export const EDGE_INTERACTION_WIDTH = 24;

// Cap on rendered column rows per table node. MUST match the backend's
// NODE_MAX_VISIBLE_COLUMNS in diagram.py: the backend estimates node height
// against this cap, and table nodes now render at that fixed height with
// overflow-hidden, so rendering more rows than the backend budgeted would
// clip them. Keep the two in lockstep.
export const NODE_MAX_VISIBLE_COLUMNS = 40;

// --- React Flow settings ---
export const MIN_ZOOM = 0.02;
export const MAX_ZOOM = 3;
export const FIT_VIEW_PADDING = 0.08;

// --- Selection styling ---
export function getSelectionColor() {
  return diagramColors().selection;
}
export function getCrossDomainHighlightColor() {
  return diagramColors().crossDomainHighlight;
}

// --- Column row styling ---
export function getPkIconColor() {
  return diagramColors().pkIcon;
}
export function getFkIconColor() {
  return diagramColors().fkIcon;
}
