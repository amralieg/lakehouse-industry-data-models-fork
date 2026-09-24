/**
 * FollowingPane — DiagramViewer remounts on focal domain change (fix regression).
 *
 * When `focusedInput` changes to a card anchored to a different domain,
 * `FollowingPane` re-renders in place with a new `initialDomain` prop.
 * Before the fix, `DiagramViewer`'s internal `selectedDomain` useState was
 * seeded only at mount (item 3B removed the resync fallback), so the diagram
 * kept showing the OLD domain. The fix adds `key={focusAnchor.domain}` so
 * React remounts DiagramViewer on every domain change.
 *
 * This test uses the REAL DiagramViewer (not a stub) with a mocked fetch,
 * mirrors with a new `focusedInput` domain, and asserts a fresh layout
 * request goes to the NEW domain rather than staying on the old one.
 */
import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, waitFor, cleanup } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { VibeInputOut } from "@/lib/api";

class ResizeObserverStub {
  observe() {}
  unobserve() {}
  disconnect() {}
}
(globalThis as any).ResizeObserver = ResizeObserverStub;

if (!(globalThis as any).DOMMatrixReadOnly) {
  (globalThis as any).DOMMatrixReadOnly = class {
    m22 = 1;
    constructor() {}
  };
}

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetUserPreferences: () => ({ data: { data: [] }, isLoading: false }),
  };
});

vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return { ...actual, useNavigate: () => vi.fn() };
});

import { FollowingPane } from "@/components/vibe-inputs/following-pane";

function mk(domainName: string): VibeInputOut {
  return {
    id: "vi-1",
    business_id: "biz-1",
    origin: "user",
    author: "",
    text: "t",
    priority: "low",
    confidence_score: null,
    consumed: false,
    status: "active",
    selected_for_run: false,
    deprecated_by: null,
    created_at: "2026-01-01T00:00:00",
    updated_at: "2026-01-01T00:00:00",
    anchor: {
      level: "element",
      domain_name: domainName,
      path: [`Domain: ${domainName}`],
    },
  };
}

function fetchUrls(impl: ReturnType<typeof vi.fn>) {
  return impl.mock.calls.map((c) => String(c[0]));
}

function mockLayoutFetch() {
  const impl = vi.fn((_url: string) =>
    Promise.resolve({
      status: 200,
      ok: true,
      json: () =>
        Promise.resolve({
          nodes: [],
          edges: [],
          groups: [],
          domain_filter: null,
          show_columns: false,
          total_products: 0,
          total_edges: 0,
        }),
    } as unknown as Response),
  );
  (globalThis as any).fetch = impl;
  return impl;
}

const base = {
  businessId: "biz-1",
  version: "1",
  scope: "ecm",
  domains: [
    { name: "Sales", division: "GTM" },
    { name: "Inventory", division: "Ops" },
  ],
};

beforeEach(() => {
  vi.useRealTimers();
});

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

describe("FollowingPane — DiagramViewer remounts on focal domain change", () => {
  it("re-fetches the layout for the NEW domain when focusedInput moves to a different domain", async () => {
    const fetchImpl = mockLayoutFetch();
    const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });

    const { rerender } = render(
      <QueryClientProvider client={qc}>
        <FollowingPane {...base} active focusedInput={mk("Sales")} />
      </QueryClientProvider>,
    );

    await waitFor(() => {
      expect(fetchUrls(fetchImpl).some((u) => u.includes("domain=Sales"))).toBe(true);
    });

    fetchImpl.mockClear();

    rerender(
      <QueryClientProvider client={qc}>
        <FollowingPane {...base} active focusedInput={mk("Inventory")} />
      </QueryClientProvider>,
    );

    await waitFor(() => {
      expect(fetchUrls(fetchImpl).some((u) => u.includes("domain=Inventory"))).toBe(true);
    });
    expect(fetchUrls(fetchImpl).some((u) => u.includes("domain=Sales"))).toBe(false);
  });
});
