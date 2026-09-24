import { describe, it, expect } from "vitest";
import { render } from "@testing-library/react";
import { ChangeBadge, changeRowClassName } from "@/components/explorer/change-badge";

describe("ChangeBadge", () => {
  it("returns null for unchanged status", () => {
    const { container } = render(<ChangeBadge status="unchanged" />);
    expect(container.innerHTML).toBe("");
  });

  it("renders badge for modified status", () => {
    render(<ChangeBadge status="modified" />);
    const badge = document.querySelector('[class*="bg-warning"]');
    expect(badge).toBeInTheDocument();
  });

  it("renders badge for deleted status", () => {
    render(<ChangeBadge status="deleted" />);
    const badge = document.querySelector('[class*="bg-destructive"]');
    expect(badge).toBeInTheDocument();
  });
});

describe("changeRowClassName", () => {
  it("returns empty string for unchanged", () => {
    expect(changeRowClassName("unchanged")).toBe("");
  });

  it("returns warning class for modified", () => {
    const cls = changeRowClassName("modified");
    expect(cls).toContain("bg-warning");
  });

  it("returns opacity class for deleted", () => {
    const cls = changeRowClassName("deleted");
    expect(cls).toContain("opacity-50");
    expect(cls).toContain("line-through");
  });
});
