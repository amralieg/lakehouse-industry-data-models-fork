/**
 * Regression lock for `invalidateBusinessLists`.
 *
 * Bug: the Industries list is a kind-filtered query
 * (`["/api/businesses", {kind:"industry"}]`). Invalidating with the bare
 * `listBusinessesKey()` -> `["/api/businesses", undefined]` does NOT partial-match
 * the filtered key, so the Industries list stayed stale ("No industries yet")
 * after a download/kickstart until a manual reload.
 *
 * `invalidateBusinessLists` must invalidate BOTH the unfiltered and the
 * kind-filtered `/api/businesses` queries via a queryKey-prefix predicate.
 * The negative assertion (the bare key misses the filtered query) pins the
 * exact behavior that caused the bug, so the fix can't silently regress.
 */
import { describe, expect, it } from "vitest";
import { QueryClient } from "@tanstack/react-query";
import { listBusinessesKey, BusinessKind } from "@/lib/api";
import { invalidateBusinessLists } from "@/lib/business-cache";

function seedClient() {
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: Infinity } },
  });
  const unfilteredKey = listBusinessesKey();
  const industryKey = listBusinessesKey({ kind: BusinessKind.industry });
  qc.setQueryData(unfilteredKey, { data: [] });
  qc.setQueryData(industryKey, { data: [] });
  return { qc, unfilteredKey, industryKey };
}

describe("invalidateBusinessLists", () => {
  it("invalidates BOTH the unfiltered and the kind-filtered business list queries", async () => {
    const { qc, unfilteredKey, industryKey } = seedClient();
    expect(qc.getQueryState(unfilteredKey)?.isInvalidated).toBe(false);
    expect(qc.getQueryState(industryKey)?.isInvalidated).toBe(false);

    await invalidateBusinessLists(qc);

    expect(qc.getQueryState(unfilteredKey)?.isInvalidated).toBe(true);
    expect(qc.getQueryState(industryKey)?.isInvalidated).toBe(true);
  });

  it("the bare listBusinessesKey() invalidation MISSES the kind-filtered query (the original bug)", async () => {
    const { qc, unfilteredKey, industryKey } = seedClient();

    await qc.invalidateQueries({ queryKey: listBusinessesKey() });

    expect(qc.getQueryState(unfilteredKey)?.isInvalidated).toBe(true);
    expect(qc.getQueryState(industryKey)?.isInvalidated).toBe(false);
  });
});
