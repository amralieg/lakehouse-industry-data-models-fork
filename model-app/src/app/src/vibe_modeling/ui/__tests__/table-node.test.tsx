import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { ReactFlowProvider } from "@xyflow/react";
import { TableNode } from "@/components/diagram/table-node";
import type { TableNodeData } from "@/components/diagram/table-node";
import { getProductTypeColors, NODE_MAX_VISIBLE_COLUMNS } from "@/components/diagram/constants";

/**
 * Normalize a color string the way the DOM does, so a hex literal compares
 * equal to the `rgb(...)` value the browser parses into `style.backgroundColor`.
 */
function normalizeColor(value: string): string {
  const probe = document.createElement("div");
  probe.style.backgroundColor = value;
  return probe.style.backgroundColor;
}

/** Resolved header background color for a node, read from its inline style. */
function headerBackground(container: HTMLElement): string {
  const headers = Array.from(container.querySelectorAll<HTMLElement>("div"));
  const header = headers.find((el) => el.style.backgroundColor);
  return header ? header.style.backgroundColor : "";
}

/**
 * TableNode renders inside a react-flow canvas, so wrap with ReactFlowProvider
 * to satisfy the library's hooks.
 */
function renderTableNode(data: TableNodeData) {
  return render(
    <ReactFlowProvider>
      {/* @ts-expect-error: NodeProps has extra runtime fields react-flow injects */}
      <TableNode id="sales.customer" data={data} type="tableNode" />
    </ReactFlowProvider>,
  );
}

const baseData: TableNodeData = {
  label: "customer",
  tableName: "customer",
  productType: "Master",
  description: "Customer master data",
  columns: [],
  columnCount: 5,
  fkCount: 1,
  domain: "sales",
  columnMode: "hide",
};

describe("TableNode ChangeBadge integration (#128)", () => {
  it("renders no ChangeBadge when changeStatus is undefined or 'unchanged'", () => {
    const { rerender } = renderTableNode(baseData);
    expect(screen.getByText("customer")).toBeInTheDocument();
    expect(screen.queryByText(/new in this version/i)).not.toBeInTheDocument();
    rerender(
      <ReactFlowProvider>
        {/* @ts-expect-error: NodeProps has extra runtime fields react-flow injects */}
        <TableNode id="sales.customer" data={{ ...baseData, changeStatus: "unchanged" }} type="tableNode" />
      </ReactFlowProvider>,
    );
    expect(screen.queryByText(/new in this version/i)).not.toBeInTheDocument();
  });

});


describe("TableNode per-column handles (keys/all regime, Increment 1)", () => {
  const cols = [
    { id: "sales.customer.id", name: "id", is_pk: true, is_fk: false, type: "bigint", description: "", fk_target: "" },
    { id: "sales.customer.region_id", name: "region_id", is_pk: false, is_fk: true, type: "bigint", description: "", fk_target: "geo.region.id" },
    { id: "sales.customer.name", name: "name", is_pk: false, is_fk: false, type: "string", description: "", fk_target: "" },
  ];

  it("renders per-column PK target + FK source handles in 'keys' mode", () => {
    const { container } = renderTableNode({
      ...baseData,
      columnMode: "keys",
      columns: cols,
    });
    const handleIds = Array.from(
      container.querySelectorAll<HTMLElement>(".react-flow__handle"),
    ).map((h) => h.getAttribute("data-handleid"));
    // The PK column carries a target handle, the FK column a source handle,
    // both keyed by the column id (smoothstep + handle anchoring path).
    expect(handleIds).toContain("sales.customer.id");
    expect(handleIds).toContain("sales.customer.region_id");
  });

  it("renders per-column handles in 'all' mode too", () => {
    const { container } = renderTableNode({
      ...baseData,
      columnMode: "all",
      columns: cols,
    });
    const handleIds = Array.from(
      container.querySelectorAll<HTMLElement>(".react-flow__handle"),
    ).map((h) => h.getAttribute("data-handleid"));
    expect(handleIds).toContain("sales.customer.id");
    expect(handleIds).toContain("sales.customer.region_id");
  });
});

describe("TableNode floating-edge attachment (hidden-columns regime, Increment 1)", () => {
  it("does not pin the hidden-columns handles to only the Right/Left sides", () => {
    const { container } = renderTableNode({
      ...baseData,
      columnMode: "hide",
      columns: [],
    });
    const handles = Array.from(
      container.querySelectorAll<HTMLElement>(".react-flow__handle"),
    );
    expect(handles.length).toBeGreaterThan(0);
    // Floating attachment: handles must NOT be locked to the right/left edge
    // only — the backend waypoints decide which of the four sides they leave
    // from. The old hard-coded Right-source / Left-target constraint is gone.
    const sides = handles.map((h) => {
      if (h.classList.contains("react-flow__handle-right")) return "right";
      if (h.classList.contains("react-flow__handle-left")) return "left";
      if (h.classList.contains("react-flow__handle-top")) return "top";
      if (h.classList.contains("react-flow__handle-bottom")) return "bottom";
      return "none";
    });
    expect(sides.every((s) => s === "right" || s === "left")).toBe(false);
  });
});

describe("TableNode fixed-height box (focal top/bottom anchor fix)", () => {
  // The diagram viewer now gives each table rfNode the backend-estimated
  // `height` (mirroring domain-group nodes), so backend-computed top/bottom
  // edge waypoints touch the rendered box. For that to hold visually, the
  // bordered root box must fill the node wrapper's height -> `h-full`.
  it("makes the bordered root box fill the node wrapper height (h-full)", () => {
    const { container } = renderTableNode(baseData);
    const root = container.querySelector<HTMLElement>("div.bg-card.border");
    expect(root).not.toBeNull();
    expect(root!.classList.contains("h-full")).toBe(true);
    expect(root!.classList.contains("overflow-hidden")).toBe(true);
  });

  // With a fixed height + overflow-hidden, rows beyond the backend's budgeted
  // NODE_MAX_VISIBLE_COLUMNS would be clipped. The node caps rendered rows to
  // that same constant and surfaces the remainder as a "+N more columns" row.
  it("caps rendered column rows at NODE_MAX_VISIBLE_COLUMNS and shows the overflow footer", () => {
    const total = NODE_MAX_VISIBLE_COLUMNS + 7;
    const cols = Array.from({ length: total }, (_, i) => ({
      id: `sales.customer.c${i}`,
      name: `c${i}`,
      is_pk: false,
      is_fk: false,
      type: "string",
      description: "",
      fk_target: "",
    }));
    const { container } = renderTableNode({
      ...baseData,
      columnMode: "all",
      columnCount: total,
      columns: cols,
    });
    const renderedNames = Array.from(
      container.querySelectorAll<HTMLElement>("span.font-mono"),
    ).length;
    expect(renderedNames).toBe(NODE_MAX_VISIBLE_COLUMNS);
    expect(screen.getByText(/\+7 more columns/)).toBeInTheDocument();
  });
});

describe("TableNode header (item 2, 0.6.6: no product-type tag)", () => {
  it("does not render the product-type text in the header", () => {
    render(
      <ReactFlowProvider>
        {/* @ts-expect-error: NodeProps has extra runtime fields react-flow injects */}
        <TableNode id="sales.customer" data={{ ...baseData, productType: "Master" }} type="tableNode" />
      </ReactFlowProvider>,
    );
    expect(screen.queryByText("Master")).not.toBeInTheDocument();
  });

  it("renders a long table name at full header width without a competing tag", () => {
    const longName = "a_very_long_entity_name_that_would_have_competed_with_the_tag";
    const { container } = renderTableNode({ ...baseData, tableName: longName, productType: "Dimension" });
    expect(screen.queryByText("Dimension")).not.toBeInTheDocument();
    const nameSpan = screen.getByText(longName);
    expect(nameSpan.classList.contains("text-right")).toBe(false);
    expect(nameSpan.classList.contains("flex-1")).toBe(true);
    void container;
  });

  it("still distinguishes header color by product type after tag removal", () => {
    const masterColor = normalizeColor(getProductTypeColors("Master").hex);
    const { container } = renderTableNode({ ...baseData, productType: "Master" });
    expect(headerBackground(container)).toBe(masterColor);
  });
});

describe("TableNode column type tags (walkthrough finding: keys mode is name+key-badge only)", () => {
  const cols = [
    { id: "sales.customer.id", name: "id", is_pk: true, is_fk: false, type: "BIGINT", description: "", fk_target: "" },
    { id: "sales.customer.region_id", name: "region_id", is_pk: false, is_fk: true, type: "BIGINT", description: "", fk_target: "geo.region.id" },
  ];

  it("does not render column type tags in 'keys' mode", () => {
    renderTableNode({ ...baseData, columnMode: "keys", columns: cols });
    expect(screen.queryByText("BIGINT")).not.toBeInTheDocument();
  });

  it("still renders column type tags in 'all' mode", () => {
    renderTableNode({ ...baseData, columnMode: "all", columns: cols });
    expect(screen.getAllByText("BIGINT").length).toBeGreaterThan(0);
  });
});

describe("TableNode product-type color resolution (case-insensitive)", () => {
  // Live the test workspace run on 2026-05-06 surfaced 24 of 62 products rendering as
  // gray because the agent's LLM emitted lowercase variants ("master",
  // "transactional") alongside the canonical "Master" / "Transactional".
  // The fix lowercase-normalizes at the boundary so both render correctly.
  // The header background is sourced from the `--diagram-product-*` tokens via
  // getProductTypeColors, applied as an inline color. Compare the rendered
  // color to the resolved token rather than a raw Tailwind class.
  const masterColor = normalizeColor(getProductTypeColors("Master").hex);
  const transactionalColor = normalizeColor(
    getProductTypeColors("Transactional").hex,
  );
  const defaultColor = normalizeColor(getProductTypeColors(null).hex);

  it("renders 'Master' header with the master token color (canonical)", () => {
    const { container } = renderTableNode({ ...baseData, productType: "Master" });
    expect(headerBackground(container)).toBe(masterColor);
  });

  it("renders lowercase 'master' header with the master token (case-insensitive)", () => {
    const { container } = renderTableNode({ ...baseData, productType: "master" });
    expect(headerBackground(container)).toBe(masterColor);
    expect(headerBackground(container)).not.toBe(defaultColor);
  });

  it("renders mixed-case 'TRANSACTIONAL' header with the transactional token", () => {
    const { container } = renderTableNode({ ...baseData, productType: "TRANSACTIONAL" });
    expect(headerBackground(container)).toBe(transactionalColor);
  });

  it("falls back to the default token for unrecognized type strings", () => {
    // 'master_data' and 'associative' are still treated as unknown — those
    // are agent-side data-quality issues, not capitalization variance.
    const { container } = renderTableNode({ ...baseData, productType: "master_data" });
    expect(headerBackground(container)).toBe(defaultColor);
  });

  it("falls back to the default token for empty / missing type", () => {
    const { container } = renderTableNode({ ...baseData, productType: "" });
    expect(headerBackground(container)).toBe(defaultColor);
  });
});
