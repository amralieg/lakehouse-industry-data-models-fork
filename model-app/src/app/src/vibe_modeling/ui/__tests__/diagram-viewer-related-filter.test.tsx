/**
 * `DiagramViewer` related-domain client-side filtering (story
 * `choose-related-domains`).
 *
 * The backend returns the focal domain plus ALL related domains (each
 * related group flagged `is_external: true`). The viewer filters them
 * client-side via the RelatedDomainsSelect control: default = show all,
 * narrowing down hides the deselected related domains' groups/nodes/edges.
 *
 * We render the real <DiagramViewer> with `fetch` mocked to return a 200
 * focal layout (focal A + related B, C, with cross-domain edges), then
 * drive the control and assert which table nodes survive. React Flow needs
 * ResizeObserver + DOMMatrixReadOnly stubs in jsdom (mirrors
 * diagram-pending.test.tsx).
 */
import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, screen, waitFor, cleanup, fireEvent } from "@testing-library/react";
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

function node(id: string, domain: string, table: string) {
  return {
    id,
    domain,
    product: table,
    table_name: table,
    product_type: "Table",
    description: "",
    x: 0,
    y: 0,
    width: 200,
    height: 80,
    columns: [],
    column_count: 0,
    fk_count: 0,
  };
}

function group(domain: string, isExternal: boolean) {
  return {
    id: `g-${domain}`,
    domain,
    division: "Commercial",
    x: 0,
    y: 0,
    width: 300,
    height: 200,
    is_external: isExternal,
    product_count: 1,
  };
}

// Focal A (intra) + related B, C (external). Cross-domain edges A<->B, A<->C.
const layout = {
  nodes: [
    node("A.t_a", "A", "t_a"),
    node("B.t_b", "B", "t_b"),
    node("C.t_c", "C", "t_c"),
  ],
  edges: [
    {
      id: "e_ab",
      source_node: "A.t_a",
      source_column: "id",
      target_node: "B.t_b",
      target_column: "a_id",
    },
    {
      id: "e_ac",
      source_node: "A.t_a",
      source_column: "id",
      target_node: "C.t_c",
      target_column: "a_id",
    },
  ],
  groups: [group("A", false), group("B", true), group("C", true)],
  domain_filter: "A",
  show_columns: false,
  total_products: 3,
  total_edges: 2,
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

const baseProps = {
  businessId: "biz-1",
  version: "1",
  scope: "ecm",
  domains: [
    { name: "A", division: "Commercial" },
    { name: "B", division: "Commercial" },
    { name: "C", division: "Commercial" },
  ],
  initialDomain: "A",
};

beforeEach(() => {
  vi.useRealTimers();
});

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

describe("DiagramViewer — related-domain client-side filtering", () => {
  it("shows focal + all related table nodes by default", async () => {
    mockLayoutFetch();
    render(<DiagramViewer {...baseProps} />);
    await waitFor(() => {
      expect(screen.getByText("t_a")).toBeInTheDocument();
    });
    expect(screen.getByText("t_b")).toBeInTheDocument();
    expect(screen.getByText("t_c")).toBeInTheDocument();
  });

  it("hides a deselected related domain's nodes while keeping focal + the others", async () => {
    mockLayoutFetch();
    render(<DiagramViewer {...baseProps} />);
    await waitFor(() => {
      expect(screen.getByText("t_c")).toBeInTheDocument();
    });

    // Open the related-domains control and uncheck C (it's currently shown).
    fireEvent.click(screen.getByRole("combobox", { name: /Related domains/i }));
    fireEvent.click(screen.getByText("C"));

    await waitFor(() => {
      expect(screen.queryByText("t_c")).not.toBeInTheDocument();
    });
    // Focal A + still-selected B remain.
    expect(screen.getByText("t_a")).toBeInTheDocument();
    expect(screen.getByText("t_b")).toBeInTheDocument();
  });

  it("'Clear all' narrows to intra-domain only (focal A, no related)", async () => {
    mockLayoutFetch();
    render(<DiagramViewer {...baseProps} />);
    await waitFor(() => {
      expect(screen.getByText("t_b")).toBeInTheDocument();
    });

    fireEvent.click(screen.getByRole("combobox", { name: /Related domains/i }));
    fireEvent.click(screen.getByText(/Clear all/i));

    await waitFor(() => {
      expect(screen.queryByText("t_b")).not.toBeInTheDocument();
    });
    expect(screen.queryByText("t_c")).not.toBeInTheDocument();
    expect(screen.getByText("t_a")).toBeInTheDocument();
  });
});
