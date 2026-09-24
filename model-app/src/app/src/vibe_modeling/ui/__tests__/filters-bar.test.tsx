/**
 * `<FiltersBar/>` + `filtersToQueryParams` (commit b). Each control updates the
 * filter state; state maps to server query params; "import" group; shown/total.
 */
import { describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import {
  FiltersBar,
  DEFAULT_FILTERS,
  filtersToQueryParams,
  applyFilters,
} from "@/components/vibe-inputs/filters-bar";
import type { VibeInputOut } from "@/lib/api";

function makeInput(over: Partial<VibeInputOut>): VibeInputOut {
  return {
    id: "i1",
    text: "instruction",
    origin: "user",
    priority: "medium",
    status: "active",
    consumed: false,
    selected_for_run: false,
    ...over,
  } as VibeInputOut;
}

describe("filtersToQueryParams", () => {
  it("maps active → status active + consumed false", () => {
    expect(filtersToQueryParams({ ...DEFAULT_FILTERS, state: "active" })).toEqual({
      status: "active",
      consumed: false,
    });
  });
  it("maps consumed → status active + consumed true", () => {
    expect(filtersToQueryParams({ ...DEFAULT_FILTERS, state: "consumed" })).toEqual({
      status: "active",
      consumed: true,
    });
  });
  it("maps needs_link_review → status active + needs_link_review", () => {
    expect(
      filtersToQueryParams({ ...DEFAULT_FILTERS, state: "needs_link_review" }),
    ).toEqual({ status: "active", needs_link_review: true });
  });
  it("maps deprecated → status deprecated", () => {
    expect(filtersToQueryParams({ ...DEFAULT_FILTERS, state: "deprecated" })).toEqual({
      status: "deprecated",
    });
  });
  it("passes through user/agent origin and priority and trimmed q", () => {
    expect(
      filtersToQueryParams({
        q: "  rename  ",
        origin: "agent_next_vibe",
        state: "all",
        priority: "high",
        selected: "all",
      }),
    ).toEqual({ q: "rename", origin: "agent_next_vibe", priority: "high" });
  });
  it("does not send a concrete origin for the import group (handled client-side)", () => {
    expect(filtersToQueryParams({ ...DEFAULT_FILTERS, origin: "import" })).toEqual({});
  });
});

describe("applyFilters — deprecated exclusivity (U-04)", () => {
  const active = makeInput({ id: "a", status: "active" });
  const consumed = makeInput({ id: "c", status: "active", consumed: true });
  const deprecated1 = makeInput({ id: "d1", status: "deprecated" });
  const deprecated2 = makeInput({ id: "d2", status: "deprecated" });
  const all = [active, consumed, deprecated1, deprecated2];
  const noSelection = new Set<string>();

  it("shows ONLY deprecated inputs when the Deprecated state filter is active", () => {
    const out = applyFilters(all, { ...DEFAULT_FILTERS, state: "deprecated" }, noSelection);
    expect(out.map((i) => i.id).sort()).toEqual(["d1", "d2"]);
    // No active-status item leaks through.
    expect(out.some((i) => i.status !== "deprecated")).toBe(false);
  });

  it("excludes deprecated inputs for the 'all' state", () => {
    const out = applyFilters(all, { ...DEFAULT_FILTERS, state: "all" }, noSelection);
    expect(out.some((i) => i.status === "deprecated")).toBe(false);
  });

  it("excludes deprecated inputs for the 'active' state", () => {
    const out = applyFilters(all, { ...DEFAULT_FILTERS, state: "active" }, noSelection);
    expect(out.map((i) => i.id)).toEqual(["a"]);
  });
});

describe("FiltersBar component", () => {
  it("search input updates q", () => {
    const onChange = vi.fn();
    render(
      <FiltersBar filters={DEFAULT_FILTERS} onChange={onChange} shown={3} total={9} />,
    );
    fireEvent.change(screen.getByLabelText("Search instructions"), {
      target: { value: "audit" },
    });
    expect(onChange).toHaveBeenCalledWith({ ...DEFAULT_FILTERS, q: "audit" });
  });

  it("shows the shown-of-total count", () => {
    render(
      <FiltersBar filters={DEFAULT_FILTERS} onChange={vi.fn()} shown={3} total={9} />,
    );
    expect(screen.getByTestId("filters-count")).toHaveTextContent("3 of 9 inputs");
  });

  it("selection filter updates the selected facet", () => {
    const onChange = vi.fn();
    render(
      <FiltersBar filters={DEFAULT_FILTERS} onChange={onChange} shown={3} total={9} />,
    );
    fireEvent.click(screen.getByLabelText("Filter by selection"));
    fireEvent.click(screen.getByRole("option", { name: "Selected" }));
    expect(onChange).toHaveBeenCalledWith({ ...DEFAULT_FILTERS, selected: "selected" });
  });
});
