/**
 * `DiagramViewer` initial column-mode seeding (item 4C, 0.6.6).
 *
 * `initialColumnMode` lets the two diagram route hosts seed the viewer from
 * the user's per-user preference (Settings > Diagram, item 4B). When the
 * prop is omitted (unset preference) the viewer must keep today's hardcoded
 * defaults: "keys" for a focal (single-domain) view, "hide" for the
 * all-domains view.
 */
import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, screen, waitFor, cleanup } from "@testing-library/react";
import { DiagramViewer } from "@/components/diagram/diagram-viewer";

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

const layout = {
  nodes: [],
  edges: [],
  groups: [],
  domain_filter: null,
  show_columns: false,
  total_products: 0,
  total_edges: 0,
};

function mockLayoutFetch() {
  const impl = vi.fn(() =>
    Promise.resolve({
      status: 200,
      ok: true,
      json: () => Promise.resolve(layout),
    } as unknown as Response),
  );
  (globalThis as any).fetch = impl;
  return impl;
}

const domains = [{ name: "A", division: "Commercial" }];

beforeEach(() => {
  vi.useRealTimers();
});

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

// The diagram toolbar renders the domain-picker combobox first, then the
// column-mode combobox (diagram-controls.tsx) - neither carries an
// accessible name, so select by render order.
async function columnModeSelectText() {
  await waitFor(() => {
    expect(screen.getAllByRole("combobox").length).toBeGreaterThanOrEqual(2);
  });
  const boxes = screen.getAllByRole("combobox");
  return boxes[boxes.length - 1].textContent;
}

describe("DiagramViewer - initialColumnMode seeding (item 4C, 0.6.6)", () => {
  it("seeds from initialColumnMode on the all-domains view (no initialDomain)", async () => {
    mockLayoutFetch();
    render(
      <DiagramViewer
        businessId="biz-1"
        version="1"
        scope="ecm"
        domains={domains}
        initialColumnMode="all"
      />,
    );
    expect(await columnModeSelectText()).toBe("Show all columns");
  });

  it("seeds from initialColumnMode on a focal (single-domain) view", async () => {
    mockLayoutFetch();
    render(
      <DiagramViewer
        businessId="biz-1"
        version="1"
        scope="ecm"
        domains={domains}
        initialDomain="A"
        initialColumnMode="hide"
      />,
    );
    expect(await columnModeSelectText()).toBe("Hide columns");
  });

  it("falls back to 'hide' on the all-domains view when initialColumnMode is omitted", async () => {
    mockLayoutFetch();
    render(
      <DiagramViewer
        businessId="biz-1"
        version="1"
        scope="ecm"
        domains={domains}
      />,
    );
    expect(await columnModeSelectText()).toBe("Hide columns");
  });

  it("falls back to 'keys' on a focal view when initialColumnMode is omitted", async () => {
    mockLayoutFetch();
    render(
      <DiagramViewer
        businessId="biz-1"
        version="1"
        scope="ecm"
        domains={domains}
        initialDomain="A"
      />,
    );
    expect(await columnModeSelectText()).toBe("Show keys (PK/FK)");
  });
});
