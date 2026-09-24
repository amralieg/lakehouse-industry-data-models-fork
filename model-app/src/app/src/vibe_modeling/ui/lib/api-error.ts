/**
 * Helpers for surfacing useful messages from the auto-generated `ApiError`
 * thrown by `lib/api.ts`. The default `err.message` is just
 * `"HTTP 422: Unprocessable Entity"`, which is technically correct but
 * useless to the user. The actual diagnostic — Pydantic validation msgs,
 * FastAPI's `detail` string, or a custom error body — sits on `err.body`.
 *
 * Use `apiErrorMessage(err)` (via `notifyError` in `lib/notify.ts`) at any
 * site that catches an `ApiError`. Falls back gracefully through the layers:
 *   1. FastAPI/Pydantic detail array → join the `msg` fields.
 *   2. FastAPI `{detail: "string"}` → return the string.
 *   3. Other Error → `err.message`.
 *   4. Anything else → a stable fallback string.
 */
import { ApiError } from "@/lib/api";

type PydanticErrorEntry = {
  msg?: string;
  loc?: unknown[];
};

function isPydanticErrorArray(v: unknown): v is PydanticErrorEntry[] {
  return (
    Array.isArray(v) &&
    v.length > 0 &&
    typeof v[0] === "object" &&
    v[0] !== null &&
    "msg" in (v[0] as object)
  );
}

/**
 * Unwrap an `ApiError`'s body-or-detail envelope: the backend's error payload
 * may arrive either as the body directly (`{ error, ... }` / `{ message, ... }`)
 * or wrapped under FastAPI's `detail` (`{ detail: { error, ... } }`). Both
 * `parse409` and `apiErrorMessage` need this same unwrap, so it lives in one
 * place - the single site that knows about the two possible shapes.
 *
 * Returns the inner record (either `body` itself or `body.detail`) when it's
 * an object, or `null` when there's nothing object-shaped to read.
 */
function unwrapEnvelope(err: ApiError): Record<string, unknown> | null {
  const body = err.body;
  if (!body || typeof body !== "object") return null;
  const record = body as Record<string, unknown>;
  if ("detail" in record && record.detail && typeof record.detail === "object") {
    return record.detail as Record<string, unknown>;
  }
  return record;
}

/**
 * Parse a 409 conflict `ApiError` into its typed error body, or `null` when it
 * isn't a 409 carrying the expected `error` discriminator.
 *
 * Unwraps the body-or-detail envelope via `unwrapEnvelope` and verifies
 * `error === errorLiteral` before returning the candidate record cast to `T`.
 * Callers own any further field coercion (e.g. reading a numeric count off
 * the returned object).
 */
export function parse409<T extends { error: string }>(
  err: unknown,
  errorLiteral: T["error"],
): T | null {
  if (!(err instanceof ApiError) || err.status !== 409) return null;
  const candidate = unwrapEnvelope(err);
  if (!candidate || candidate.error !== errorLiteral) return null;
  return candidate as unknown as T;
}

/** One missing configuration entry from a `config_missing` 422 payload. */
export interface ConfigMissingItem {
  key: string;
  label: string;
  settings_url: string;
}

/**
 * The backend's structured `config_missing` error, emitted with a 422 across
 * every config-gated surface (run create/validate, kickstart, download, volume
 * import, resync, initial-sync, oob). Shape:
 *   { detail: { error: "config_missing", missing: [{key,label,settings_url}], message } }
 */
export interface ConfigMissing {
  error: "config_missing";
  missing: ConfigMissingItem[];
  message: string;
}

/**
 * Parse an `ApiError` into its `config_missing` payload, or `null` when it
 * isn't one. Reuses `unwrapEnvelope` so the same body-or-`detail` unwrap that
 * `apiErrorMessage`/`parse409` use applies here - the single site that knows
 * the two envelope shapes. Deliberately does NOT gate on the HTTP status: the
 * discriminator (`error === "config_missing"`) is authoritative and the status
 * is a consistent 422 across surfaces.
 */
export function parseConfigMissing(err: unknown): ConfigMissing | null {
  if (!(err instanceof ApiError)) return null;
  const envelope = unwrapEnvelope(err);
  if (!envelope || envelope.error !== "config_missing") return null;
  const rawMissing = Array.isArray(envelope.missing) ? envelope.missing : [];
  const missing: ConfigMissingItem[] = rawMissing
    .filter((m): m is Record<string, unknown> => !!m && typeof m === "object")
    .map((m) => ({
      key: String(m.key ?? ""),
      label: String(m.label ?? m.key ?? ""),
      settings_url: String(m.settings_url ?? "/settings"),
    }));
  const message =
    typeof envelope.message === "string" && envelope.message.trim()
      ? envelope.message
      : "Required configuration is missing.";
  return { error: "config_missing", missing, message };
}

/**
 * Whether a thrown value represents an HTTP 404. Matches either the structured
 * `ApiError` (`.status === 404`), any object carrying a numeric `status` of
 * 404, or an `Error` whose message contains a standalone `404` (the `HTTP 404`
 * string formatting older fetch sites still use). The single 404 predicate for
 * every route that wants to render a friendly not-found instead of the generic
 * error boundary.
 */
export function isNotFoundError(error: unknown): boolean {
  if (error instanceof ApiError && error.status === 404) return true;
  if (error && typeof error === "object" && "status" in error) {
    if ((error as { status?: unknown }).status === 404) return true;
  }
  if (error instanceof Error && /\b404\b/.test(error.message)) return true;
  return false;
}

export function apiErrorMessage(err: unknown, fallback = "Request failed"): string {
  if (err instanceof ApiError) {
    const body = err.body as { detail?: unknown } | null;
    const detail = body?.detail;
    if (typeof detail === "string" && detail.trim()) {
      return detail;
    }
    if (isPydanticErrorArray(detail)) {
      // Join up to 3 validation messages so the toast stays compact.
      const msgs = detail
        .slice(0, 3)
        .map((e) => e.msg)
        .filter((m): m is string => typeof m === "string" && m.length > 0);
      if (msgs.length > 0) {
        return msgs.join("; ");
      }
    }
    // Object-shaped detail (or body) - e.g. a 409 conflict payload like
    // `{ message: "sector in use by 3 businesses" }` or `{ error: "..." }`.
    // Prefer `message`, then `error`, before falling back to the HTTP-level
    // message. Without this, object-detail 409s regress to "HTTP 409: Conflict".
    const envelope = unwrapEnvelope(err);
    if (envelope) {
      if (typeof envelope.message === "string" && envelope.message.trim()) {
        return envelope.message;
      }
      if (typeof envelope.error === "string" && envelope.error.trim()) {
        return envelope.error;
      }
    }
    // ApiError but no useful body → fall back to the HTTP-level message.
    return err.message || fallback;
  }
  if (err instanceof Error && err.message) {
    return err.message;
  }
  return fallback;
}
