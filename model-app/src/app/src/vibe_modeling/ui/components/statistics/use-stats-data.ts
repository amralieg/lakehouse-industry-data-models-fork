import {
  useGetNextVibeMetricsSuspense,
  useGetEvolutionMetricsSuspense,
  useGetDomainNextVibeMetricsSuspense,
  useGetDomainDetailSuspense,
  useGetReviewProgressByDomain,
} from "@/lib/api";
import type {
  NextVibeMetricsOut,
  EvolutionMetricsOut,
  DomainDetailOut,
  DomainReviewProgressOut,
} from "@/lib/api";
import { selector } from "@/lib/selector";

/** The scope identity every Statistics data hook keys on. */
export interface StatsScope {
  businessId: string;
  versionInt: number;
  /** "ecm" | "mvm" — the model-kind scope from the route. */
  scope: string;
}

/**
 * Normalize a confidence score to a 0–100 integer for display. The evolution
 * endpoint may report confidence as a 0..1 ratio or an already-0..100 number;
 * a value ≤ 1 is treated as a ratio. Single source of truth so every surface
 * renders confidence identically.
 */
export function confidenceTo100(score: number): number {
  return Math.round(score <= 1 ? score * 100 : score);
}

/** Model-level next_vibes metrics (quality score + open-input counts). */
export function useNextVibeMetrics(s: StatsScope): NextVibeMetricsOut {
  return useGetNextVibeMetricsSuspense({
    params: { business_id: s.businessId, version_int: s.versionInt, scope: s.scope },
    ...selector(),
  }).data;
}

/** Model-level evolution metrics (confidence, change, size, effort, flags). */
export function useEvolutionMetrics(s: StatsScope): EvolutionMetricsOut {
  return useGetEvolutionMetricsSuspense({
    params: { business_id: s.businessId, version_int: s.versionInt, scope: s.scope },
    ...selector(),
  }).data;
}

/** Per-domain next_vibes metrics (the domain's quality signal). */
export function useDomainNextVibeMetrics(
  s: StatsScope,
  domainName: string,
): NextVibeMetricsOut {
  return useGetDomainNextVibeMetricsSuspense({
    params: {
      business_id: s.businessId,
      version_int: s.versionInt,
      scope: s.scope,
      domain_name: domainName,
    },
    ...selector(),
  }).data;
}

/**
 * Per-domain review progress (reviewed ÷ review-needed per domain), keyed by
 * domain name. Non-suspense so the scope tree + focus table paint immediately
 * and fill the figures in when they resolve. The full `DomainReviewProgressOut`
 * row is returned so callers can derive both the display % (scope tree) and the
 * review-gap signal (focus score) from the same source. `review_pct` arrives as
 * a 0..1 ratio; scale to 0..100 with `reviewPctTo100` for display.
 */
export function useReviewProgressByDomain(
  s: StatsScope,
): Map<string, DomainReviewProgressOut> {
  const { data } = useGetReviewProgressByDomain({
    params: { business_id: s.businessId, version_int: s.versionInt, scope: s.scope },
    query: { ...selector<DomainReviewProgressOut[]>().query },
  });
  const rows = Array.isArray(data) ? data : [];
  const m = new Map<string, DomainReviewProgressOut>();
  for (const r of rows) m.set(r.domain ?? "", r);
  return m;
}

/**
 * Display review % (0..100) for a domain's progress row, or `null` when the
 * domain's products all need no review (`review_needed === 0`) — the scope tree
 * renders that as "—". `review_pct` is a 0..1 ratio on the wire.
 */
export function reviewPctTo100(
  row: DomainReviewProgressOut | undefined,
): number | null {
  if (!row || (row.review_needed ?? 0) === 0) return null;
  return (row.review_pct ?? 0) * 100;
}

/** Per-domain detail (named products + subdomain grouping for the breakdown). */
export function useDomainDetail(
  s: StatsScope,
  domainName: string,
): DomainDetailOut {
  return useGetDomainDetailSuspense({
    params: {
      business_id: s.businessId,
      version_int: s.versionInt,
      scope: s.scope,
      domain_name: domainName,
    },
    ...selector(),
  }).data;
}
