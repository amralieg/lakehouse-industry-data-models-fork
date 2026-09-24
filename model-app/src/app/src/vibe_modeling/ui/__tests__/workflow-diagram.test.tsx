/**
 * Shared workflow diagram - the same five stages must render in both the terse
 * home-page strip and the expanded help-flow variant, so the two surfaces read
 * as the same picture. Guards the stage content and the loop-back / publish
 * affordances against silent drift. Publish is a terminal node (not a
 * clickable pill); the loop meaning is carried by a visible caption.
 */
import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";

import {
  WorkflowDiagram,
  WORKFLOW_STAGES,
} from "@/components/flow/workflow-diagram";
import { useStrictConsole } from "./helpers/strict-console";

describe("WorkflowDiagram", () => {
  const dom = useStrictConsole();

  it("renders all five stage labels in the strip variant", () => {
    render(<WorkflowDiagram variant="strip" />);
    for (const stage of WORKFLOW_STAGES) {
      expect(screen.getByText(stage.label)).toBeInTheDocument();
    }
    // Publish renders as a split terminal node (label + sub), not a pill.
    expect(screen.getByText("Publish")).toBeInTheDocument();
    expect(screen.getByText(/to Unity Catalog/i)).toBeInTheDocument();
    // The Publish node must not be a clickable control.
    const publish = screen.getByText("Publish");
    expect(publish.closest("button")).toBeNull();
    expect(publish.closest("a")).toBeNull();
    expect(dom.messages).toEqual([]);
  });

  it("renders stage prose, the Publish terminal, and the loop caption in the expanded variant", () => {
    const { container } = render(<WorkflowDiagram variant="expanded" />);
    // Every stage's fuller prose telling should be present.
    expect(
      screen.getByText(/Begin from an industry template/i),
    ).toBeInTheDocument();
    expect(screen.getByText(/produces a new model version/i)).toBeInTheDocument();
    // Publish is a terminal node with its full label, not a button/link.
    const publish = screen.getByText(/^Publish$/);
    expect(publish).toBeInTheDocument();
    expect(publish.closest("button")).toBeNull();
    expect(publish.closest("a")).toBeNull();
    expect(screen.getByText("Publish to Unity Catalog")).toBeInTheDocument();
    // The loop is iterative, not linear; the loop-back caption must show.
    expect(
      screen.getByText(/repeat until it reflects your business/i),
    ).toBeInTheDocument();
    // The decorative loop-back rail is drawn as an aria-hidden SVG, so the
    // visual affordance can't be silently dropped without this failing.
    expect(
      container.querySelector('svg.absolute[aria-hidden="true"]'),
    ).not.toBeNull();
    expect(dom.messages).toEqual([]);
  });
});
