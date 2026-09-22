/**
 * `DownloadCompleteDialog` tests - Task 5 (download-finished completion).
 *
 * The dialog IS the notification (replaces the old success toast). Asserts:
 *   1. Renders name/scope/version/domains/products/attributes/FKs.
 *   2. Renders warnings inline when present.
 *   3. "View industry" calls onViewIndustry with the result.
 *   4. "Download another scope" calls onDownloadAnother, not onViewIndustry.
 *   5. Renders nothing when result is null.
 */
import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { fireEvent } from "@testing-library/react";
import type { DownloadIndustryModelOut } from "@/lib/api";
import { DownloadCompleteDialog } from "@/components/source-explorer/download-complete-dialog";

function result(overrides: Partial<DownloadIndustryModelOut> = {}): DownloadIndustryModelOut {
  return {
    business_id: "biz-1",
    business_name: "Banking",
    version: 1,
    version_id: "v-1",
    scope: "ecm",
    domains: 12,
    products: 100,
    attribute_count: 512,
    fk_count: 15,
    on_conflict_applied: "none",
    warnings: [],
    ...overrides,
  };
}

describe("DownloadCompleteDialog", () => {
  it("renders the industry name, scope, version, and all four counts", () => {
    render(
      <DownloadCompleteDialog
        result={result()}
        open
        onOpenChange={vi.fn()}
        onViewIndustry={vi.fn()}
        onDownloadAnother={vi.fn()}
      />,
    );
    expect(screen.getByText(/Banking/)).toBeInTheDocument();
    expect(screen.getByText(/v1/)).toBeInTheDocument();
    expect(screen.getByText(/ECM/)).toBeInTheDocument();
    expect(screen.getByText("12")).toBeInTheDocument();
    expect(screen.getByText("100")).toBeInTheDocument();
    expect(screen.getByText("512")).toBeInTheDocument();
    expect(screen.getByText("15")).toBeInTheDocument();
  });

  it("renders warnings inline when present", () => {
    render(
      <DownloadCompleteDialog
        result={result({ warnings: ["Could not fetch schemas/x.sql"] })}
        open
        onOpenChange={vi.fn()}
        onViewIndustry={vi.fn()}
        onDownloadAnother={vi.fn()}
      />,
    );
    expect(
      screen.getByText("Could not fetch schemas/x.sql"),
    ).toBeInTheDocument();
  });

  it("does not render a warnings block when there are none", () => {
    render(
      <DownloadCompleteDialog
        result={result({ warnings: [] })}
        open
        onOpenChange={vi.fn()}
        onViewIndustry={vi.fn()}
        onDownloadAnother={vi.fn()}
      />,
    );
    expect(screen.queryByText(/could not/i)).not.toBeInTheDocument();
  });

  it("'View industry' calls onViewIndustry with the result", () => {
    const onViewIndustry = vi.fn();
    const r = result();
    render(
      <DownloadCompleteDialog
        result={r}
        open
        onOpenChange={vi.fn()}
        onViewIndustry={onViewIndustry}
        onDownloadAnother={vi.fn()}
      />,
    );
    fireEvent.click(screen.getByRole("button", { name: /view industry/i }));
    expect(onViewIndustry).toHaveBeenCalledWith(r);
  });

  it("'Download another scope' calls onDownloadAnother, not onViewIndustry", () => {
    const onViewIndustry = vi.fn();
    const onDownloadAnother = vi.fn();
    render(
      <DownloadCompleteDialog
        result={result()}
        open
        onOpenChange={vi.fn()}
        onViewIndustry={onViewIndustry}
        onDownloadAnother={onDownloadAnother}
      />,
    );
    fireEvent.click(
      screen.getByRole("button", { name: /download another scope/i }),
    );
    expect(onDownloadAnother).toHaveBeenCalledTimes(1);
    expect(onViewIndustry).not.toHaveBeenCalled();
  });

  it("renders nothing when result is null", () => {
    const { container } = render(
      <DownloadCompleteDialog
        result={null}
        open
        onOpenChange={vi.fn()}
        onViewIndustry={vi.fn()}
        onDownloadAnother={vi.fn()}
      />,
    );
    expect(container).toBeEmptyDOMElement();
  });
});
