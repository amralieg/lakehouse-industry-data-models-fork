/**
 * Client → app-log gateway-error beacon (E-04 observability). Locks:
 *   - always emits a console.error breadcrumb;
 *   - POSTs the occurrence to /api/client-telemetry/gateway-error with the
 *     snake_case `will_retry` field the backend expects;
 *   - never throws when the beacon fetch rejects (best-effort telemetry).
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { reportClientGatewayError } from "@/lib/client-telemetry";

afterEach(() => {
  vi.restoreAllMocks();
});

describe("reportClientGatewayError", () => {
  it("logs to console and beacons the backend with the expected payload", () => {
    const errorSpy = vi.spyOn(console, "error").mockImplementation(() => {});
    const fetchSpy = vi
      .spyOn(globalThis, "fetch")
      .mockResolvedValue(new Response(null, { status: 200 }));

    reportClientGatewayError({
      status: 502,
      path: "/api/industry-models/ind-1/kickstart",
      attempt: 1,
      willRetry: true,
      context: "kickstart industry=ind-1",
    });

    expect(errorSpy).toHaveBeenCalledTimes(1);
    expect(String(errorSpy.mock.calls[0][0])).toContain("HTTP 502");

    expect(fetchSpy).toHaveBeenCalledTimes(1);
    const [url, init] = fetchSpy.mock.calls[0];
    expect(url).toBe("/api/client-telemetry/gateway-error");
    expect(init?.method).toBe("POST");
    const body = JSON.parse(String(init?.body));
    expect(body).toMatchObject({
      status: 502,
      path: "/api/industry-models/ind-1/kickstart",
      attempt: 1,
      will_retry: true,
      context: "kickstart industry=ind-1",
    });
  });

  it("never throws when the beacon fetch rejects", () => {
    vi.spyOn(console, "error").mockImplementation(() => {});
    vi.spyOn(globalThis, "fetch").mockRejectedValue(new Error("network down"));
    expect(() =>
      reportClientGatewayError({
        status: 503,
        path: "/api/x",
        attempt: 2,
        willRetry: false,
      }),
    ).not.toThrow();
  });
});
