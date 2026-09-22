/**
 * `<SectionTree/>` + `buildSectionTree` (commit b). Only branches with inputs
 * render (+ Model-wide always); collapse folds the subtree; Expand/Collapse
 * all; filter active force-expands; +Add instruction opens a composer that
 * creates with the right anchor ids on ⌘↵.
 */
import { describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen, within } from "@testing-library/react";
import type { VibeInputOut } from "@/lib/api";
import { SectionTree } from "@/components/vibe-inputs/section-tree";
import {
  buildSectionTree,
  selectableSubtreeIds,
  subtreeSelectionState,
} from "@/components/vibe-inputs/section-tree-model";

const mk = (over: Partial<VibeInputOut> & { id: string }): VibeInputOut => ({
  business_id: "biz-1",
  origin: "user",
  author: "",
  text: "rule",
  priority: "low",
  confidence_score: null,
  consumed: false,
  status: "active",
  selected_for_run: false,
  deprecated_by: null,
  created_at: "2026-01-01T00:00:00",
  updated_at: "2026-01-01T00:00:00",
  anchor: { level: "model_wide", path: [] },
  ...over,
});

const salesInput = mk({
  id: "vi-sales",
  text: "sales rule",
  anchor: {
    level: "element",
    domain_id: "dom-sales",
    domain_name: "Sales",
    path: ["Domain: Sales"],
  },
});

const ordersInput = mk({
  id: "vi-orders",
  text: "orders rule",
  anchor: {
    level: "element",
    domain_id: "dom-sales",
    domain_name: "Sales",
    product_id: "prod-orders",
    product_name: "Orders",
    path: ["Domain: Sales", "Product: Orders"],
  },
});

describe("buildSectionTree", () => {
  it("nests products under domains and counts the subtree", () => {
    const root = buildSectionTree([
      mk({ id: "m", text: "model rule" }),
      salesInput,
      ordersInput,
    ]);
    expect(root.subtreeCount).toBe(3);
    expect(root.inputs).toHaveLength(1);
    const sales = root.children.find((c) => c.name === "Sales")!;
    expect(sales.subtreeCount).toBe(2);
    expect(sales.inputs).toHaveLength(1);
    const orders = sales.children.find((c) => c.name === "Orders")!;
    expect(orders.anchorIds).toEqual({ domain_id: "dom-sales", product_id: "prod-orders" });
  });

  it("excludes deprecated and anchor-free inputs", () => {
    const root = buildSectionTree([
      mk({ id: "d", status: "deprecated", anchor: { level: "element", domain_name: "X", path: ["Domain: X"] } }),
      mk({ id: "a", anchor: null }),
    ]);
    expect(root.subtreeCount).toBe(0);
    expect(root.children).toHaveLength(0);
  });
});

describe("subtree selection helpers", () => {
  it("collects active, non-consumed input ids across the subtree", () => {
    const root = buildSectionTree([
      mk({ id: "m", text: "model rule" }),
      salesInput,
      ordersInput,
      mk({ id: "consumed", consumed: true, anchor: salesInput.anchor }),
    ]);
    expect(selectableSubtreeIds(root).sort()).toEqual(["m", "vi-orders", "vi-sales"]);
    const sales = root.children.find((c) => c.name === "Sales")!;
    expect(selectableSubtreeIds(sales).sort()).toEqual(["vi-orders", "vi-sales"]);
  });

  it("reports none/some/all selection state", () => {
    const root = buildSectionTree([salesInput, ordersInput]);
    expect(subtreeSelectionState(root, new Set())).toBe("none");
    expect(subtreeSelectionState(root, new Set(["vi-sales"]))).toBe("some");
    expect(subtreeSelectionState(root, new Set(["vi-sales", "vi-orders"]))).toBe("all");
  });
});

function defaultHandlers() {
  return {
    includedIds: new Set<string>(),
    onToggleInclude: vi.fn(),
    onCommitText: vi.fn(),
    onOpenInModel: vi.fn(),
    onExpand: vi.fn(),
    onResolveReview: vi.fn(),
    onAddInput: vi.fn(),
    onSelectSubtree: vi.fn(),
  };
}

describe("SectionTree component", () => {
  it("renders only branches with inputs, plus Model-wide", () => {
    render(<SectionTree inputs={[salesInput]} {...defaultHandlers()} />);
    expect(screen.getByText("Model-wide")).toBeInTheDocument();
    expect(screen.getByText("Sales")).toBeInTheDocument();
    expect(screen.queryByText("Orders")).not.toBeInTheDocument();
  });

  it("collapse folds the whole subtree", () => {
    render(<SectionTree inputs={[salesInput, ordersInput]} {...defaultHandlers()} />);
    expect(screen.getByText("orders rule")).toBeInTheDocument();
    // Collapse Sales.
    const salesRow = screen.getByText("Sales").closest("div")!;
    fireEvent.click(within(salesRow).getByLabelText("Collapse"));
    expect(screen.queryByText("orders rule")).not.toBeInTheDocument();
    expect(screen.queryByText("Orders")).not.toBeInTheDocument();
  });

  it("filter active force-expands (collapse state ignored)", () => {
    render(
      <SectionTree inputs={[salesInput, ordersInput]} filterActive {...defaultHandlers()} />,
    );
    // Even after clicking collapse, content stays visible because filterActive
    // forces expansion.
    const salesRow = screen.getByText("Sales").closest("div")!;
    fireEvent.click(within(salesRow).getByLabelText("Collapse"));
    expect(screen.getByText("orders rule")).toBeInTheDocument();
  });

  it("select-all-under-branch selects every selectable id in the subtree", () => {
    const handlers = defaultHandlers();
    render(<SectionTree inputs={[salesInput, ordersInput]} {...handlers} />);
    const salesRow = screen.getByText("Sales").closest(".group") as HTMLElement;
    fireEvent.click(within(salesRow).getByLabelText("Select all under this branch"));
    expect(handlers.onSelectSubtree).toHaveBeenCalledWith(
      expect.arrayContaining(["vi-sales", "vi-orders"]),
      true,
    );
    const [ids] = handlers.onSelectSubtree.mock.calls[0];
    expect(ids).toHaveLength(2);
  });

  it("deselects an all-selected branch", () => {
    const handlers = defaultHandlers();
    handlers.includedIds = new Set(["vi-sales", "vi-orders"]);
    render(<SectionTree inputs={[salesInput, ordersInput]} {...handlers} />);
    const salesRow = screen.getByText("Sales").closest(".group") as HTMLElement;
    fireEvent.click(within(salesRow).getByLabelText("Deselect all under this branch"));
    expect(handlers.onSelectSubtree).toHaveBeenCalledWith(expect.any(Array), false);
  });

  it("+Add instruction creates with the section anchor ids on ⌘↵", () => {
    const handlers = defaultHandlers();
    render(<SectionTree inputs={[salesInput]} {...handlers} />);
    const salesRow = screen.getByText("Sales").closest(".group") as HTMLElement;
    fireEvent.click(within(salesRow).getByText("Add instruction"));
    const ta = screen.getByPlaceholderText(/New instruction for Sales/) as HTMLTextAreaElement;
    fireEvent.change(ta, { target: { value: "new sales rule" } });
    fireEvent.keyDown(ta, { key: "Enter", metaKey: true });
    expect(handlers.onAddInput).toHaveBeenCalledWith(
      { domain_id: "dom-sales" },
      "new sales rule",
      "medium",
    );
  });

  it("+Add instruction passes the chosen non-default priority", () => {
    const handlers = defaultHandlers();
    render(<SectionTree inputs={[salesInput]} {...handlers} />);
    const salesRow = screen.getByText("Sales").closest(".group") as HTMLElement;
    fireEvent.click(within(salesRow).getByText("Add instruction"));
    fireEvent.click(screen.getByLabelText("Priority"));
    fireEvent.click(screen.getByRole("option", { name: "High" }));
    const ta = screen.getByPlaceholderText(/New instruction for Sales/) as HTMLTextAreaElement;
    fireEvent.change(ta, { target: { value: "urgent rule" } });
    fireEvent.click(screen.getByRole("button", { name: "Add" }));
    expect(handlers.onAddInput).toHaveBeenCalledWith(
      { domain_id: "dom-sales" },
      "urgent rule",
      "high",
    );
  });
});
