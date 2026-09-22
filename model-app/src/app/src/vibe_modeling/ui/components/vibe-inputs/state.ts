import type {
  VibeInputOut,
  VibeInputContextLinkOut,
  VibeInputAnchorOut,
} from "@/lib/api";
import type { ModelViewFocusAnchor } from "./model-view";

/** FE-derived state of a Vibe Input. There is no backend "state" field — it's
 *  a pure function of `status` + `consumed` + link `needs_link_review`. */
export type VibeInputState =
  | "active"
  | "consumed"
  | "needs_link_review"
  | "deprecated";

/**
 * Derive the input's display state. Precedence (highest first):
 *   deprecated > needs_link_review > consumed > active
 *
 * `links` are the input's context links (from `/links`, or hydrated in the
 * review queue). When links aren't loaded, pass `undefined`/`[]` and the
 * `needs_link_review` branch simply can't fire — the card falls back to the
 * other signals. This is the single source of truth so the card, the details
 * page, the filters, and the review banner all agree (no drift).
 */
export function deriveInputState(
  input: Pick<VibeInputOut, "status" | "consumed">,
  links?: readonly Pick<VibeInputContextLinkOut, "needs_link_review">[],
): VibeInputState {
  if (input.status === "deprecated") return "deprecated";
  if (links && links.some((l) => l.needs_link_review)) return "needs_link_review";
  if (input.consumed) return "consumed";
  return "active";
}

/**
 * The section-path labels the compile mirror groups by. Mirrors the backend
 * adapter: model-wide → `["Model-wide"]` (the API returns an empty `path` for
 * model-wide, distinct from a null anchor); element → the hydrated
 * `anchor.path` (already prefixed, e.g. `["Domain: Sales", "Product: Orders"]`).
 *
 * Returns `null` for an input with NO anchor on the head version (no link) —
 * such inputs are not compiled (and not shown in a section).
 */
export function anchorPathForCompile(input: VibeInputOut): string[] | null {
  const anchor = input.anchor;
  if (!anchor) return null;
  if (anchor.level === "model_wide") return ["Model-wide"];
  return anchor.path ?? [];
}

/** Whether an input is eligible for the compiled doc: not deprecated and has
 *  an anchor on the head version. (Inclusion in THIS run is the separate
 *  checkbox selection, handled by the caller.) */
export function isIncludedInCompile(input: VibeInputOut): boolean {
  return input.status !== "deprecated" && input.anchor != null;
}

/**
 * Map an input's hydrated anchor to the diagram `focusAnchor` shape. Drives
 * `DiagramViewer.initialDomain` (domain leaf) + element highlight on the
 * card-details page and the following pane. Model-wide / anchor-free → no
 * focusable domain (caller shows an empty state, never all-domains).
 */
export function anchorFromInput(
  input: Pick<VibeInputOut, "anchor">,
): ModelViewFocusAnchor | undefined {
  const a: VibeInputAnchorOut | null | undefined = input.anchor;
  if (!a || a.level === "model_wide") return undefined;
  if (!a.domain_name) return undefined;
  return {
    domain: a.domain_name,
    product: a.product_name ?? undefined,
    attribute: a.attribute_name ?? undefined,
    fkLabel: a.fk_label ?? undefined,
  };
}
