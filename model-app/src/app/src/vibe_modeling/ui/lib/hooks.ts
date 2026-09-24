/**
 * Shared TanStack Query hooks layered over the Orval-generated client.
 *
 * Drift-unification (the model-versioning work, Phase 5): hand-rolled `useQuery({ queryFn })`
 * wrappers around `/api/...` endpoints duplicated across routes. Each duplicate
 * is its own queryKey + fetch implementation, which means cache-invalidation,
 * retry/staleTime tuning, and response shape decoding all drift over time.
 * The Orval client already covers every endpoint; this module just types the
 * payload and unwraps the `{ data: ... }` envelope so callers don't have to.
 */
import { useEffect, useState } from "react";
import { getAgentReadyKey, useGetAgentReady, useGetUserRole } from "@/lib/api";

/** Debounce a fast-changing value (e.g. a search box) before it drives an
 *  expensive effect / query key. Returns the value after `delayMs` of quiet. */
export function useDebouncedValue<T>(value: T, delayMs = 250): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const t = setTimeout(() => setDebounced(value), delayMs);
    return () => clearTimeout(t);
  }, [value, delayMs]);
  return debounced;
}

export type AgentReady = { ready: boolean; reason?: string };

/** Stable queryKey re-export so consumers can `invalidateQueries({ queryKey })`
 *  without coupling to the Orval-generated module. */
export const agentReadyQueryKey = getAgentReadyKey;

/**
 * Is the app in a state where runs can launch right now?
 *
 * Wraps the Orval-generated `useGetAgentReady` and unwraps the response
 * envelope so callers get `{ ready, reason? }` directly instead of
 * `{ data: { ready, reason? } }`. Reused on the Settings page (banner) and
 * the business runs page (gate on the New Run button) so they always agree.
 *
 * @param staleTime  How long the result is considered fresh (default 15s).
 *                   The two original sites used 15s and 30s respectively;
 *                   15s is the lower bound, fine for both.
 */
export function useAgentReady(staleTime = 15_000) {
  return useGetAgentReady<AgentReady>({
    query: {
      select: (resp) => resp.data as AgentReady,
      staleTime,
      retry: false,
    },
  });
}

/** The four application RBAC roles resolved by `/api/user/role`. */
export type AppRole = "app_admin" | "business_admin" | "modeler" | "viewer";

/**
 * The current user's resolved RBAC role, or `undefined` while loading / when
 * the endpoint errored. Wraps the Orval-generated `useGetUserRole` and unwraps
 * the `{ data: { role } }` envelope. RBAC is off by default server-side (every
 * user resolves to `app_admin`), so callers should treat `undefined` as "don't
 * gate" - only a positive non-admin role should ever tighten access.
 */
export function useUserRole(): AppRole | undefined {
  const { data } = useGetUserRole({
    query: { retry: false, staleTime: 60_000 },
  });
  const role = (data?.data as { role?: string } | undefined)?.role;
  return role as AppRole | undefined;
}
