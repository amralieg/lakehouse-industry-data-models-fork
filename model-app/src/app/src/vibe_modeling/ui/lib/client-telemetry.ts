/**
 * Client → app-log breadcrumb for transient edge-proxy errors.
 *
 * A client-side auto-retry (see `retry-transient.ts`) recovers a 502/503/504
 * in the browser, so the failure never reaches `databricks apps logs` and a
 * real recurrence would be invisible server-side. `reportClientGatewayError`
 * records every occurrence in BOTH places: a `console.error` breadcrumb for
 * the browser, and a fire-and-forget beacon to the backend
 * (`POST /api/client-telemetry/gateway-error`) that logs a WARNING into the
 * app logs — even when a later retry recovers the request.
 */

export interface GatewayErrorReport {
  /** Gateway status the browser saw (502/503/504). */
  status: number;
  /** App request path that failed, e.g. `/api/.../kickstart`. */
  path: string;
  /** 1-based attempt number that failed. */
  attempt: number;
  /** Whether the client will auto-retry this attempt. */
  willRetry: boolean;
  /** Free-form context (e.g. kickstart industry id + new name). */
  context?: string;
}

/**
 * Record a transient gateway error in the console AND the app logs.
 *
 * Fire-and-forget: telemetry must never break the user's flow, so the backend
 * beacon is best-effort (network/parse errors swallowed) and the `console.error`
 * always fires regardless of whether the beacon lands. `keepalive` lets the
 * beacon survive a navigation that immediately follows a recovered retry.
 */
export function reportClientGatewayError(report: GatewayErrorReport): void {
  const { status, path, attempt, willRetry, context } = report;

  console.error(
    `[gateway-error] HTTP ${status} on ${path} ` +
      `(attempt ${attempt}, ${willRetry ? "will retry" : "giving up"})` +
      (context ? ` — ${context}` : ""),
  );

  try {
    void fetch("/api/client-telemetry/gateway-error", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        status,
        path,
        attempt,
        will_retry: willRetry,
        context,
      }),
      keepalive: true,
    }).catch(() => {
      /* best-effort telemetry — ignore network failures */
    });
  } catch {
    /* fetch unavailable (e.g. non-browser env) — ignore */
  }
}
