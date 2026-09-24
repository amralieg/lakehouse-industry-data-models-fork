/**
 * `DiagramControls` toolbar tests.
 *
 * Pure presentational toolbar — no fetches, no router. We pass mock
 * handlers for each callback prop and assert they fire with the right
 * argument shapes.
 */
import { describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import { DiagramControls } from "@/components/diagram/diagram-controls";

function defaultProps(overrides: Partial<Parameters<typeof DiagramControls>[0]> = {}) {
  return {
    domains: [{ name: "sales", division: "B2C" }],
    selectedDomain: null,
    onDomainChange: vi.fn(),
    columnMode: "hide" as const,
    onColumnModeChange: vi.fn(),
    totalProducts: 12,
    totalEdges: 8,
    visibleProducts: 12,
    visibleEdges: 8,
    relatedDomains: [{ name: "inv", division: "B2C" }],
    hiddenRelated: new Set<string>(),
    onHiddenRelatedChange: vi.fn(),
    isFullscreen: false,
    onToggleFullscreen: vi.fn(),
    ...overrides,
  };
}

describe("DiagramControls", () => {
  it("renders toolbar buttons (fullscreen + related-domains control) and totals", () => {
    render(<DiagramControls {...defaultProps()} />);
    // Fullscreen toggle (icon-only button — title attribute carries the label).
    expect(screen.getByTitle(/Fullscreen/i)).toBeInTheDocument();
    // Related-domains control trigger renders when there are related domains.
    expect(
      screen.getByRole("combobox", { name: /Related domains/i }),
    ).toBeInTheDocument();
    // Stats — formatted "12 tables / 8 relationships".
    expect(screen.getByText(/12 tables/)).toBeInTheDocument();
    expect(screen.getByText(/8 relationships/)).toBeInTheDocument();
  });

  it("does NOT render the related-domains control when there are no related domains", () => {
    render(<DiagramControls {...defaultProps({ relatedDomains: [] })} />);
    expect(
      screen.queryByRole("combobox", { name: /Related domains/i }),
    ).not.toBeInTheDocument();
  });

  it("fires onToggleFullscreen on click", () => {
    const onToggleFullscreen = vi.fn();
    render(<DiagramControls {...defaultProps({ onToggleFullscreen })} />);
    fireEvent.click(screen.getByTitle(/Fullscreen/i));
    expect(onToggleFullscreen).toHaveBeenCalledTimes(1);
  });

  it("fires onHiddenRelatedChange when a related domain is toggled", () => {
    const onHiddenRelatedChange = vi.fn();
    render(<DiagramControls {...defaultProps({ onHiddenRelatedChange })} />);
    fireEvent.click(screen.getByRole("combobox", { name: /Related domains/i }));
    fireEvent.click(screen.getByText("inv"));
    expect(onHiddenRelatedChange).toHaveBeenCalledTimes(1);
    const arg = onHiddenRelatedChange.mock.calls[0][0] as Set<string>;
    expect([...arg]).toEqual(["inv"]);
  });

  it("renders the selected-relationship + selected-table chips when set", () => {
    render(
      <DiagramControls
        {...defaultProps({
          selectedTable: "sales.customer",
          selectedRelationship: "customer → order",
        })}
      />,
    );
    expect(screen.getByText("sales.customer")).toBeInTheDocument();
    expect(screen.getByText("customer → order")).toBeInTheDocument();
  });

  it("shows fractional counts when some related domains are hidden and totals differ", () => {
    render(
      <DiagramControls
        {...defaultProps({
          hiddenRelated: new Set(["inv"]),
          visibleProducts: 5,
          totalProducts: 12,
          visibleEdges: 3,
          totalEdges: 8,
        })}
      />,
    );
    // "5 / 12 tables" — react renders this as separated text nodes.
    expect(screen.getByText(/\/ 12/)).toBeInTheDocument();
    expect(screen.getByText(/\/ 8/)).toBeInTheDocument();
  });

  it("renders feedbackSlot in the toolbar (item 5B, 0.6.6)", () => {
    render(
      <DiagramControls
        {...defaultProps({
          feedbackSlot: <button>Add feedback</button>,
        })}
      />,
    );
    expect(screen.getByRole("button", { name: "Add feedback" })).toBeInTheDocument();
  });

  it("renders nothing extra when feedbackSlot is omitted", () => {
    render(<DiagramControls {...defaultProps()} />);
    expect(screen.queryByRole("button", { name: "Add feedback" })).not.toBeInTheDocument();
  });
});
