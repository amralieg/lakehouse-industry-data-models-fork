/**
 * `CrowsFootEdge` and `CrowsFootMarkerDefs` tests.
 *
 * `CrowsFootEdge` is a React Flow custom edge: it expects EdgeProps and
 * renders an SVG `<path>` between source/target coordinates. We render
 * it inside an `<svg>` container with `<ReactFlowProvider>` so its
 * `getSmoothStepPath` import resolves.
 */
import { describe, expect, it, vi } from "vitest";
import { fireEvent, render } from "@testing-library/react";
import { ReactFlowProvider, Position } from "@xyflow/react";
import {
  CrowsFootEdge,
  CrowsFootMarkerDefs,
} from "@/components/diagram/crows-foot-edge";
import {
  EDGE_WIDTH,
  EDGE_HOVER_WIDTH,
  EDGE_INTERACTION_WIDTH,
} from "@/components/diagram/constants";

function renderEdge(extra: Partial<{ selected: boolean; data: any }> = {}) {
  return render(
    <ReactFlowProvider>
      <svg>
        <CrowsFootEdge
          id="e-1"
          source="a"
          target="b"
          sourceX={0}
          sourceY={0}
          targetX={100}
          targetY={50}
          sourcePosition={Position.Right}
          targetPosition={Position.Left}
          selected={extra.selected ?? false}
          data={extra.data}
        />
      </svg>
    </ReactFlowProvider>,
  );
}

/** The visible (rendered, marker-bearing) edge path and the invisible wide
 *  hit path are the only two <path> elements the edge draws. Return both. */
function edgePaths(container: HTMLElement) {
  const paths = Array.from(container.querySelectorAll("path"));
  const visible = paths.find((p) => p.getAttribute("marker-end")) ?? null;
  const hit = paths.find((p) => p.getAttribute("stroke") === "transparent") ?? null;
  return { visible, hit, all: paths };
}

describe("CrowsFootEdge", () => {
  it("invokes data.onEdgeClick when the edge group is clicked", () => {
    const onEdgeClick = vi.fn();
    const { container } = renderEdge({
      data: {
        onEdgeClick,
        sourceNodeId: "tbl.a",
        targetNodeId: "tbl.b",
        edgeId: "e-1",
      },
    });
    const group = container.querySelector("g")!;
    fireEvent.click(group);
    expect(onEdgeClick).toHaveBeenCalledWith("tbl.a", "tbl.b", "e-1");
  });

  it("draws a generous transparent hit-target (>=20px) for click targeting", () => {
    const { container } = renderEdge();
    const { hit } = edgePaths(container);
    expect(hit).not.toBeNull();
    expect(Number(hit!.getAttribute("stroke-width"))).toBeGreaterThanOrEqual(20);
  });

  it("thickens the visible edge on hover as a pre-click cue", () => {
    const { container } = renderEdge();
    const { visible } = edgePaths(container);
    const group = container.querySelector("g")!;

    expect((visible as SVGPathElement).style.strokeWidth).toBe(String(EDGE_WIDTH));
    fireEvent.mouseEnter(group);
    expect((visible as SVGPathElement).style.strokeWidth).toBe(String(EDGE_HOVER_WIDTH));
    fireEvent.mouseLeave(group);
    expect((visible as SVGPathElement).style.strokeWidth).toBe(String(EDGE_WIDTH));
  });
});

describe("CrowsFootEdge — waypoint polyline routing (Increment 1)", () => {
  const WAYPOINTS: [number, number][] = [
    [10, 20],
    [10, 60],
    [80, 60],
    [80, 120],
  ];

  it("draws the path 'd' from data.waypoints (absolute polyline), not smoothstep", () => {
    const { container } = renderEdge({ data: { waypoints: WAYPOINTS } });
    const { visible } = edgePaths(container);
    const d = visible!.getAttribute("d") ?? "";
    // The source (crow's-foot) endpoint is inset a few px along the first
    // segment for marker clearance, so the path starts just inside it (x is
    // unchanged on this vertical first run). The remaining waypoints — and the
    // straight-line polyline form (L commands, no curve) — are verbatim.
    expect(d).toMatch(/^M\s*10[ ,]/);
    for (const [x, y] of WAYPOINTS.slice(1)) {
      expect(d).toContain(`${x}`);
      expect(d).toContain(`${y}`);
    }
    expect(d).toContain("L");
    // No smoothstep arc syntax in a pure polyline.
    expect(d).not.toMatch(/[CQ]/);
  });

  it("keeps the crow's-foot markers on the waypoint edge", () => {
    const { container } = renderEdge({ data: { waypoints: WAYPOINTS } });
    const { visible } = edgePaths(container);
    expect(visible!.getAttribute("marker-start")).toContain("cf-many");
    expect(visible!.getAttribute("marker-end")).toContain("cf-one");
  });

  it("uses the SAME 'd' for the invisible wide hit path so clicks follow the polyline", () => {
    const { container } = renderEdge({ data: { waypoints: WAYPOINTS } });
    const { visible, hit } = edgePaths(container);
    expect(hit).not.toBeNull();
    expect(hit!.getAttribute("d")).toBe(visible!.getAttribute("d"));
    expect(hit!.getAttribute("stroke-width")).toBe(String(EDGE_INTERACTION_WIDTH));
  });

  it("still invokes onEdgeClick on a waypoint edge", () => {
    const onEdgeClick = vi.fn();
    const { container } = renderEdge({
      data: {
        waypoints: WAYPOINTS,
        onEdgeClick,
        sourceNodeId: "tbl.a",
        targetNodeId: "tbl.b",
        edgeId: "e-1",
      },
    });
    fireEvent.click(container.querySelector("g")!);
    expect(onEdgeClick).toHaveBeenCalledWith("tbl.a", "tbl.b", "e-1");
  });

  it("falls back to the smoothstep path when waypoints are empty/absent", () => {
    const empty = renderEdge({ data: { waypoints: [] } });
    const dEmpty = edgePaths(empty.container).visible!.getAttribute("d") ?? "";
    const absent = renderEdge({ data: {} });
    const dAbsent = edgePaths(absent.container).visible!.getAttribute("d") ?? "";
    // The smoothstep path for these coords starts at the source point and is
    // identical whether waypoints is [] or undefined (pure fallback).
    expect(dEmpty).toBe(dAbsent);
    expect(dEmpty).toMatch(/^M/);
    // It must NOT be the waypoint polyline (none of those coords are present).
    expect(dEmpty).not.toContain("120");
  });
});

describe("CrowsFootMarkerDefs", () => {
  it("emits all four marker definitions (default + selected variants)", () => {
    const { container } = render(<CrowsFootMarkerDefs />);
    const ids = Array.from(container.querySelectorAll("marker")).map(
      (m) => m.getAttribute("id"),
    );
    expect(ids).toEqual(
      expect.arrayContaining([
        "cf-many",
        "cf-one",
        "cf-many-selected",
        "cf-one-selected",
      ]),
    );
  });
});
