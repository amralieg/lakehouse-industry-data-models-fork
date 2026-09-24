/**
 * Bounded auto-retry for requests that fail with a *transient* gateway error.
 *
 * A 502 / 503 / 504 is emitted by the Databricks Apps edge proxy, not by our
 * app: the request never reached a definitive application response (the
 * `ApiError` body is empty - which is why it surfaces as the useless raw
 * `"HTTP 502: Bad Gateway"`). These clear on an immediate retry (cold worker /
 * momentary proxy hiccup). By contrast a 4xx or an app-level 500 is a
 * deterministic answer from the app and MUST surface unretried.
 *
 * The kickstart POST returned an intermittent inline `HTTP 502:` on the first
 * attempt during the 0.6.6 walkthrough (E-04) and succeeded on manual retry.
 * The synchronous kickstart path does only Lakebase reads/writes (no external
 * Databricks call - lighter than the download POST, which never 502'd), and
 * the engine already pre-pings stale pooled connections, so the 502 is not
 * app-attributable; a bounded client retry absorbs the transient instead of
 * dumping a raw gateway status on the user.
 */
import { ApiError } from "@/lib/api";

/** Gateway/proxy statuses that indicate a transient, retry-safe failure. */
const TRANSIENT_GATEWAY_STATUSES = new Set([502, 503, 504]);

/** True when `err` is a transient gateway `ApiError` (502/503/504). */
export function isTransientGatewayError(err: unknown): boolean {
  return err instanceof ApiError && TRANSIENT_GATEWAY_STATUSES.has(err.status);
}

export interface RetryOptions {
  /** Extra attempts after the first (default 2 → up to 3 total). */
  retries?: number;
  /** Base backoff in ms; grows linearly per attempt (default 400 → 400, 800). */
  delayMs?: number;
  /**
   * Called on EVERY transient gateway error caught, before the retry decision.
   * `attempt` is the 1-based number of the attempt that just failed;
   * `willRetry` is `false` on the final, exhausted attempt. Use it to log/beacon
   * each occurrence (so it stays observable even when a later retry recovers)
   * and to drive UI state.
   */
  onTransientError?: (attempt: number, err: ApiError, willRetry: boolean) => void;
  /** Injectable sleep (tests pass an instant one). */
  sleep?: (ms: number) => Promise<void>;
}

const defaultSleep = (ms: number) => new Promise<void>((r) => setTimeout(r, ms));

/**
 * Run `fn`, retrying only on a transient gateway error, with a bounded number
 * of attempts and a linear backoff. Any non-transient error (4xx, app 500,
 * non-`ApiError`) is rethrown immediately. The last transient error is
 * rethrown once retries are exhausted so the caller can surface a friendly
 * message.
 *
 * `onTransientError` fires for every transient error (retried or exhausted),
 * so the caller can record each 502/503/504 occurrence even when a subsequent
 * retry succeeds - the retry must not silently swallow a real recurrence.
 *
 * Safe for a non-idempotent create (e.g. kickstart): a unique-name constraint
 * means a retry can never double-create. Worst case the first (502'd) attempt
 * actually committed and the retry returns a 409 - the caller distinguishes
 * that via `onTransientError` having fired.
 */
export async function retryOnTransientGateway<T>(
  fn: () => Promise<T>,
  opts: RetryOptions = {},
): Promise<T> {
  const retries = opts.retries ?? 2;
  const delayMs = opts.delayMs ?? 400;
  const sleep = opts.sleep ?? defaultSleep;

  let attempt = 0;
  for (;;) {
    attempt += 1;
    try {
      return await fn();
    } catch (err) {
      if (!isTransientGatewayError(err)) throw err;
      const willRetry = attempt <= retries;
      opts.onTransientError?.(attempt, err as ApiError, willRetry);
      if (!willRetry) throw err;
      await sleep(delayMs * attempt);
    }
  }
}
