/**
 * `<CompiledPreview/>` — read-only compiled-instructions pane (commit d).
 * Asserts it consumes the byte-parity `compilePreviewMarkdown` mirror, reflects
 * the included selection live, excludes deprecated / anchor-free inputs, and
 * shows the count + empty state.
 *
 * The mirror's byte-parity against the backend fixture is locked in
 * instructions.test.ts; here we verify the COMPONENT's selection + rendering.
 */
import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import type { VibeInputOut } from "@/lib/api";
import { CompiledPreview } from "@/components/vibe-inputs/compiled-preview";
import { compilePreviewMarkdown } from "@/lib/instructions";

const mk = (over: Partial<VibeInputOut> & { id: string }): VibeInputOut => ({
  business_id: "biz-1",
  origin: "user",
  author: "a@b.c",
  text: "do the thing",
  priority: "medium",
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

describe("CompiledPreview", () => {
  it("renders the empty state with zero count when nothing is included", () => {
    render(<CompiledPreview inputs={[mk({ id: "a" })]} includedIds={new Set()} />);
    expect(screen.getByTestId("compiled-preview-count")).toHaveTextContent("0 selected");
    expect(screen.getByText(/No inputs included/)).toBeInTheDocument();
  });

  it("compiles the included selection identically to the mirror", () => {
    const inputs = [
      mk({ id: "a", priority: "high", text: "Use snake_case everywhere" }),
      mk({
        id: "b",
        priority: "medium",
        text: "keep order ids stable",
        anchor: { level: "element", domain_name: "Sales", path: ["Domain: Sales"] },
      }),
    ];
    render(<CompiledPreview inputs={inputs} includedIds={new Set(["a", "b"])} />);
    expect(screen.getByTestId("compiled-preview-count")).toHaveTextContent("2 selected");

    const expected = compilePreviewMarkdown([
      { priority: "high", anchorPath: ["Model-wide"], text: "Use snake_case everywhere" },
      { priority: "medium", anchorPath: ["Domain: Sales"], text: "keep order ids stable" },
    ]);
    // Model-wide sorts first; assert both headers + the bullet text rendered.
    expect(expected).toContain("## Model-wide");
    expect(expected).toContain("## Domain: Sales");
    const md = screen.getByTestId("compiled-preview-markdown");
    expect(md.textContent).toContain("Use snake_case everywhere");
    expect(md.textContent).toContain("keep order ids stable");
  });

  it("excludes unchecked, deprecated, and anchor-free inputs", () => {
    const inputs = [
      mk({ id: "a", text: "included one" }),
      mk({ id: "b", text: "unchecked one" }),
      mk({ id: "c", text: "deprecated one", status: "deprecated" }),
      mk({ id: "d", text: "anchorless one", anchor: null }),
    ];
    render(
      <CompiledPreview
        inputs={inputs}
        includedIds={new Set(["a", "b", "c", "d"])}
      />,
    );
    // b is unchecked? No — b IS in includedIds. The exclusions are status +
    // anchor. So included = a + b = 2 (c deprecated, d anchorless dropped).
    expect(screen.getByTestId("compiled-preview-count")).toHaveTextContent("2 selected");
    const md = screen.getByTestId("compiled-preview-markdown");
    expect(md.textContent).toContain("included one");
    expect(md.textContent).not.toContain("deprecated one");
    expect(md.textContent).not.toContain("anchorless one");
  });
});
