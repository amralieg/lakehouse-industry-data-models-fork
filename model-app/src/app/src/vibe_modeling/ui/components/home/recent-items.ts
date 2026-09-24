import type { ComponentType } from "react";
import { Building2, Factory, Boxes, Play } from "lucide-react";
import type { BusinessListOut, IndustryOut } from "@/lib/api";
import { ensureUtcIso } from "@/lib/date";

/** Preference-key prefix for a per-entity visit record. One row per visited
 *  business/industry/version; the upsert bumps `updated_at` on every visit, so
 *  the store doubles as an ordered recency signal. Shared between the recorder
 *  (`businesses.$businessId` route) and the home reader so the convention lives
 *  in one place. */
export const VISIT_BUSINESS_PREFIX = "visit:business:";

export function businessVisitKey(businessId: string): string {
  return `${VISIT_BUSINESS_PREFIX}${businessId}`;
}

/**
 * A single "Jump back in" entry. The shape is deliberately generic so a real
 * per-user "recently visited" feed can slot in behind it later without
 * touching the presentation: each item carries a display kind, title,
 * subtitle, a timestamp, and the deep-link target.
 *
 * TODO(recently-visited): v1 derives this list from the businesses/industries
 * list APIs, ordered by per-user visit time (falling back to creation time).
 * Replace `buildRecentItems` with a real per-user recency feed (e.g. GET
 * /api/me/recent) that returns model versions and runs too - the extra `kind`s
 * below are already wired through the presentation for that day.
 */
export type RecentKind =
  | "business"
  | "industry"
  | "model_version"
  | "run";

export interface RecentItem {
  key: string;
  kind: RecentKind;
  title: string;
  subtitle?: string;
  /** ISO timestamp used for the relative "when" and for sorting. */
  timestamp: string;
  /** Deep-link target. `businessId` is always present; the others are set
   *  only for the model/run/vibe kinds a richer feed will produce. */
  businessId: string;
  version?: number;
  scope?: string;
  runId?: string;
}

export const RECENT_KIND_META: Record<
  RecentKind,
  { label: string; Icon: ComponentType<{ className?: string }> }
> = {
  business: { label: "Business", Icon: Building2 },
  industry: { label: "Industry", Icon: Factory },
  model_version: { label: "Model version", Icon: Boxes },
  run: { label: "Run", Icon: Play },
};

function countLabel(n: number, singular: string): string {
  return `${n} ${singular}${n === 1 ? "" : "s"}`;
}

/**
 * v1 recency adapter: merge businesses and industries, newest first. This is
 * NOT a re-listing of everything - it's capped and ordered by recency to give
 * a returning user a one-click way back in.
 *
 * `visitTimes` maps a business/industry id to the ISO `updated_at` of its
 * `visit:business:<id>` preference. When an entity has been visited, its visit
 * time is the sort key AND the displayed "time ago"; never-visited entities
 * fall back to creation time so entities predating this feature still appear
 * (creation-ordered until first visited). Both inputs pass through
 * `ensureUtcIso` so the two sort bases share one epoch (see M3 / the helper's
 * docstring) - normalizing only one side would break visited-vs-never ordering.
 */
export function buildRecentItems(
  businesses: BusinessListOut[],
  industries: IndustryOut[],
  visitTimes: Map<string, string> = new Map(),
  limit = 8,
): RecentItem[] {
  const bizItems: RecentItem[] = businesses.map((b) => ({
    key: `business:${b.id}`,
    kind: "business",
    title: b.name,
    subtitle:
      (b.model_count ?? 0) > 0
        ? countLabel(b.model_count ?? 0, "model version")
        : "No models yet",
    timestamp: ensureUtcIso(visitTimes.get(b.id) ?? b.created_at),
    businessId: b.id,
  }));

  const industryItems: RecentItem[] = industries.map((i) => ({
    key: `industry:${i.id}`,
    kind: "industry",
    title: i.name,
    subtitle: "template",
    timestamp: ensureUtcIso(visitTimes.get(i.id) ?? i.updated_at ?? i.created_at),
    businessId: i.id,
  }));

  return [...bizItems, ...industryItems]
    .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
    .slice(0, limit);
}
