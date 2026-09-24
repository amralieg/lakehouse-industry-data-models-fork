/**
 * Shared cache-invalidation helper for the `/api/businesses` list queries.
 *
 * The businesses list is queried in two shapes:
 *   - unfiltered:        ["/api/businesses", undefined]   (Businesses page)
 *   - kind-filtered:     ["/api/businesses", {kind: "industry"}]  (Industries page)
 *
 * Invalidating with the bare `listBusinessesKey()` produces
 * `["/api/businesses", undefined]`, which TanStack Query partial-matches only
 * against the unfiltered key. The `{kind:"industry"}` second element never
 * matches `undefined`, so the kind-filtered Industries list goes stale after a
 * download/kickstart/create and only refreshes on a manual page reload.
 *
 * This helper invalidates EVERY `/api/businesses` list query regardless of its
 * params via a queryKey-prefix predicate, so both the unfiltered and
 * kind-filtered lists refetch. Use it at every site that mutates the set of
 * businesses and expects the lists to refresh.
 */
import type { QueryClient } from "@tanstack/react-query";

export const BUSINESSES_QUERY_PATH = "/api/businesses";

/** Invalidate all `/api/businesses` list queries (unfiltered and kind-filtered). */
export function invalidateBusinessLists(queryClient: QueryClient) {
  return queryClient.invalidateQueries({
    predicate: (q) =>
      Array.isArray(q.queryKey) && q.queryKey[0] === BUSINESSES_QUERY_PATH,
  });
}
