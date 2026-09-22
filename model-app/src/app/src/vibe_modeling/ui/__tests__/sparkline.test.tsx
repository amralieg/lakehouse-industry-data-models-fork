import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { Sparkline } from "@/components/statistics/sparkline";

describe("Sparkline", () => {
  it("renders an svg with a polyline path for >= 2 points", () => {
    render(<Sparkline values={[1, 5, 3, 8]} label="Trend" />);
    const svg = screen.getByTestId("sparkline");
    expect(svg).toBeInTheDocument();
    expect(svg.querySelector("path")).not.toBeNull();
    expect(svg).toHaveAttribute("aria-label", "Trend");
  });

  it("renders just a dot (no path) for a single point", () => {
    render(<Sparkline values={[4]} />);
    const svg = screen.getByTestId("sparkline");
    expect(svg.querySelector("path")).toBeNull();
    expect(svg.querySelector("circle")).not.toBeNull();
  });

  it("renders nothing for an empty series", () => {
    const { container } = render(<Sparkline values={[]} />);
    expect(container.querySelector("svg")).toBeNull();
  });

  it("survives an all-equal series (flat line, no NaN coords)", () => {
    render(<Sparkline values={[3, 3, 3]} />);
    const path = screen.getByTestId("sparkline").querySelector("path");
    expect(path?.getAttribute("d")).not.toContain("NaN");
  });
});
