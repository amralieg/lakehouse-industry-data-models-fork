/**
 * Bounded transient-gateway retry (E-04). Locks:
 *   - a 502/503/504 is retried up to the bound, then rethrown;
 *   - a transient error that clears mid-way resolves with the eventual value;
 *   - a 4xx / app-500 / non-ApiError is rethrown immediately (no retry);
 *   - `onTransientError` fires for EVERY transient error (retried AND the
 *     final exhausted one) with the 1-based attempt number + `willRetry`.
 */
import { describe, expect, it, vi } from "vitest";
import { ApiError } from "@/lib/api";
import {
  isTransientGatewayError,
  retryOnTransientGateway,
} from "@/lib/retry-transient";

const instantSleep = () => Promise.resolve();

describe("isTransientGatewayError", () => {
  it("is true only for 502/503/504 ApiErrors", () => {
    expect(isTransientGatewayError(new ApiError(502, "Bad Gateway", null))).toBe(true);
    expect(isTransientGatewayError(new ApiError(503, "Unavailable", null))).toBe(true);
    expect(isTransientGatewayError(new ApiError(504, "Timeout", null))).toBe(true);
    expect(isTransientGatewayError(new ApiError(500, "Server Error", null))).toBe(false);
    expect(isTransientGatewayError(new ApiError(409, "Conflict", null))).toBe(false);
    expect(isTransientGatewayError(new Error("boom"))).toBe(false);
    expect(isTransientGatewayError("nope")).toBe(false);
  });
});

describe("retryOnTransientGateway", () => {
  it("returns immediately on first success (no retry)", async () => {
    const fn = vi.fn().mockResolvedValue("ok");
    const onTransientError = vi.fn();
    await expect(
      retryOnTransientGateway(fn, { onTransientError, sleep: instantSleep }),
    ).resolves.toBe("ok");
    expect(fn).toHaveBeenCalledTimes(1);
    expect(onTransientError).not.toHaveBeenCalled();
  });

  it("retries a 502 and resolves when it clears", async () => {
    const fn = vi
      .fn()
      .mockRejectedValueOnce(new ApiError(502, "Bad Gateway", null))
      .mockResolvedValue("recovered");
    const onTransientError = vi.fn();
    await expect(
      retryOnTransientGateway(fn, { onTransientError, sleep: instantSleep }),
    ).resolves.toBe("recovered");
    expect(fn).toHaveBeenCalledTimes(2);
    // Reported once (attempt 1, willRetry=true) even though the retry recovered.
    expect(onTransientError).toHaveBeenCalledTimes(1);
    expect(onTransientError).toHaveBeenCalledWith(1, expect.any(ApiError), true);
  });

  it("rethrows the transient error once retries are exhausted, reporting every attempt", async () => {
    const err = new ApiError(503, "Unavailable", null);
    const fn = vi.fn().mockRejectedValue(err);
    const onTransientError = vi.fn();
    await expect(
      retryOnTransientGateway(fn, { retries: 2, onTransientError, sleep: instantSleep }),
    ).rejects.toBe(err);
    // 1 initial + 2 retries.
    expect(fn).toHaveBeenCalledTimes(3);
    // Reported on all three, with willRetry false only on the final one.
    expect(onTransientError).toHaveBeenCalledTimes(3);
    expect(onTransientError).toHaveBeenNthCalledWith(1, 1, expect.any(ApiError), true);
    expect(onTransientError).toHaveBeenNthCalledWith(2, 2, expect.any(ApiError), true);
    expect(onTransientError).toHaveBeenNthCalledWith(3, 3, expect.any(ApiError), false);
  });

  it("does NOT retry a non-transient ApiError (409)", async () => {
    const err = new ApiError(409, "Conflict", { detail: { error: "business_name_taken" } });
    const fn = vi.fn().mockRejectedValue(err);
    const onTransientError = vi.fn();
    await expect(
      retryOnTransientGateway(fn, { onTransientError, sleep: instantSleep }),
    ).rejects.toBe(err);
    expect(fn).toHaveBeenCalledTimes(1);
    expect(onTransientError).not.toHaveBeenCalled();
  });

  it("does NOT retry an app-level 500 or a plain Error", async () => {
    const err500 = new ApiError(500, "Server Error", null);
    const fn500 = vi.fn().mockRejectedValue(err500);
    await expect(
      retryOnTransientGateway(fn500, { sleep: instantSleep }),
    ).rejects.toBe(err500);
    expect(fn500).toHaveBeenCalledTimes(1);

    const plain = new Error("network down");
    const fnPlain = vi.fn().mockRejectedValue(plain);
    await expect(
      retryOnTransientGateway(fnPlain, { sleep: instantSleep }),
    ).rejects.toBe(plain);
    expect(fnPlain).toHaveBeenCalledTimes(1);
  });

  it("honors a custom retries bound", async () => {
    const fn = vi.fn().mockRejectedValue(new ApiError(504, "Timeout", null));
    await expect(
      retryOnTransientGateway(fn, { retries: 4, sleep: instantSleep }),
    ).rejects.toBeInstanceOf(ApiError);
    expect(fn).toHaveBeenCalledTimes(5); // 1 + 4
  });
});
