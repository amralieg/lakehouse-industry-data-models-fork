import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, screen, waitFor, cleanup } from "@testing-library/react";
import { DiagramViewer, formatRelativeTime } from "@/components/diagram/diagram-viewer";

/**
 * Task #104 — verify the 202 "still computing" overlay surfaces the
 * heartbeat + queue info when the backend provides it, and falls back
 * to the legacy spinner text when the 202 body is the old opaque shape.
 */

// jsdom doesn't implement ResizeObserver; @xyflow/react pulls it in.
class ResizeObserverStub {
  observe() {}
  unobserve() {}
  disconnect() {}
}
(globalThis as any).ResizeObserver = ResizeObserverStub;

// jsdom doesn't implement DOMMatrixReadOnly either.
if (!(globalThis as any).DOMMatrixReadOnly) {
  (globalThis as any).DOMMatrixReadOnly = class {
    m22 = 1;
    constructor() {}
  };
}

function mockFetch(body: unknown, status = 202) {
  const impl = vi.fn(() =>
    Promise.resolve({
      status,
      ok: status >= 200 && status < 300,
      json: () => Promise.resolve(body),
    } as unknown as Response),
  );
  (globalThis as any).fetch = impl;
  return impl;
}

const baseProps = {
  businessId: "biz-1",
  version: "1",
  scope: "ecm",
  domains: [{ name: "sales", division: "Commercial" }],
};

beforeEach(() => {
  vi.useRealTimers();
});

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

describe("DiagramViewer — 202 heartbeat overlay (task #104)", () => {
  it("renders queue position + last-update when backend provides heartbeat", async () => {
    // Heartbeat was 5 seconds before "now" for a stable relative string.
    const nowMs = Date.now();
    mockFetch({
      status: "computing",
      key: "k",
      last_heartbeat_ms: nowMs - 5_000,
      queue_position: 3,
      total_in_queue: 7,
    });

    render(<DiagramViewer {...baseProps} />);

    // The overlay text combines position + total + relative update time.
    await waitFor(() => {
      expect(
        screen.getByText(/#3 of 7 in queue/i),
      ).toBeInTheDocument();
    });
    // Last-update label is present (exact seconds depend on clock drift
    // between setup and assertion, so match by pattern rather than exact
    // seconds).
    expect(screen.getByText(/last update/i)).toBeInTheDocument();
  });

  it("falls back to legacy 'Computing layout...' when 202 lacks queue info", async () => {
    // Legacy server-side shape: {status, key} with no heartbeat fields.
    mockFetch({ status: "computing", key: "k" });

    render(<DiagramViewer {...baseProps} />);

    await waitFor(() => {
      expect(screen.getByText(/Computing layout\.\.\./)).toBeInTheDocument();
    });
    // And must NOT surface the #N-of-M affordance.
    expect(screen.queryByText(/in queue/i)).not.toBeInTheDocument();
  });
});

describe("formatRelativeTime", () => {
  it("returns 'just now' within 2 seconds", () => {
    const now = 1_700_000_000_000;
    expect(formatRelativeTime(now - 500, now)).toBe("just now");
    expect(formatRelativeTime(now - 1_000, now)).toBe("just now");
  });

  it("returns 'Ns ago' under a minute", () => {
    const now = 1_700_000_000_000;
    expect(formatRelativeTime(now - 15_000, now)).toBe("15s ago");
  });

  it("returns 'Nm ago' under an hour", () => {
    const now = 1_700_000_000_000;
    expect(formatRelativeTime(now - 5 * 60_000, now)).toBe("5m ago");
  });

  it("returns 'Nh ago' beyond an hour", () => {
    const now = 1_700_000_000_000;
    expect(formatRelativeTime(now - 3 * 3_600_000, now)).toBe("3h ago");
  });

  it("clamps negative deltas to 'just now'", () => {
    const now = 1_700_000_000_000;
    // Server clock slightly ahead of client: delta < 0 -> "just now".
    expect(formatRelativeTime(now + 1_000, now)).toBe("just now");
  });
});
