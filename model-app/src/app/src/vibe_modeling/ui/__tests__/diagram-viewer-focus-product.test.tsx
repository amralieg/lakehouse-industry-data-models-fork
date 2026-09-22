/**
 * DiagramViewer focusProduct node focus (Track 6 item 2, 2C).
 *
 * A model-wide search "table" hit lands on the domain diagram with a
 * `focusProduct`. Once the layout resolves, the viewer selects that product's
 * node (observable via onSelectionChange). Unresolvable product names are a
 * no-op (ELK-timing domain-only fallback), so no selection fires.
 */
import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, waitFor, cleanup } from "@testing-library/react";
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

function makeLayout(nodes: any[]) {
  return {
    nodes,
    edges: [],
    groups: [],
    domain_filter: "sales",
    show_columns: false,
    total_products: nodes.length,
    total_edges: 0,
  };
}

function mockLayoutFetch(nodes: any[]) {
  (globalThis as any).fetch = vi.fn(() =>
    Promise.resolve({
      status: 200,
      ok: true,
      json: () => Promise.resolve(makeLayout(nodes)),
    } as unknown as Response),
  );
}

const NODE = {
  id: "sales.orders",
  domain: "sales",
  product: "orders",
  table_name: "orders",
  product_type: "",
  description: "",
  x: 0,
  y: 0,
  width: 200,
  height: 40,
  columns: [],
  column_count: 0,
  fk_count: 0,
};

const domains = [{ name: "sales", division: "Commercial" }];

beforeEach(() => vi.useRealTimers());
afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

describe("DiagramViewer - focusProduct (item 2, 2C)", () => {
  it("selects the matching product node once the layout resolves", async () => {
    mockLayoutFetch([NODE]);
    const onSelectionChange = vi.fn();
    render(
      <DiagramViewer
        businessId="biz-1"
        version="1"
        scope="ecm"
        domains={domains}
        initialDomain="sales"
        focusProduct="orders"
        onSelectionChange={onSelectionChange}
      />,
    );
    await waitFor(() => {
      expect(onSelectionChange).toHaveBeenCalledWith(
        expect.objectContaining({ nodeId: "sales.orders" }),
      );
    });
  });

  it("does not select anything when the product name is unresolvable (domain-only fallback)", async () => {
    mockLayoutFetch([NODE]);
    const onSelectionChange = vi.fn();
    render(
      <DiagramViewer
        businessId="biz-1"
        version="1"
        scope="ecm"
        domains={domains}
        initialDomain="sales"
        focusProduct="does_not_exist"
        onSelectionChange={onSelectionChange}
      />,
    );
    // Give the layout + focus effect time to run.
    await new Promise((r) => setTimeout(r, 400));
    for (const call of onSelectionChange.mock.calls) {
      expect(call[0].nodeId).toBeNull();
    }
  });
});
