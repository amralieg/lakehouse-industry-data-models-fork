import { memo, useCallback, useState } from "react";
import { getSmoothStepPath, type EdgeProps } from "@xyflow/react";
import {
  getEdgeColor,
  EDGE_WIDTH,
  EDGE_SELECTED_WIDTH,
  EDGE_HOVER_WIDTH,
  EDGE_INTERACTION_WIDTH,
  getSelectionColor,
} from "./constants";


/**
 * Global SVG marker definitions for crow's feet notation.
 * Render this ONCE inside the ReactFlow component as a child.
 * It injects <defs> into the React Flow SVG canvas.
 */
export function CrowsFootMarkerDefs() {
  const edgeColor = getEdgeColor();
  const selectionColor = getSelectionColor();
  return (
    <svg>
      <defs>
        {/* Crow's feet (many) — at the source-entity ("many") end.
            Three lines fan out from the V tip back to the entity edge:
            top diagonal, bottom diagonal, and a middle horizontal line.
            Layout in viewBox (anchor at refX=6, line endpoint):
              x=0   wide ends at y=4.4 (top), y=10 (mid), y=15.6 (bottom)
                    — touching the entity edge
              x=8   V tip (single point at y=10) — depth 8 viewBox = 12.8
                    user-space, half-angle 35° (spread = 8·tan35° ≈ 5.6)
              x=10  inner bar, just forward of the V tip
            Render scale = markerWidth/viewBoxW = 24/15 = 1.6×. */}
        <marker
          id="cf-many"
          viewBox="0 0 15 20"
          refX="6"
          refY="10"
          markerWidth="24"
          markerHeight="32"
          orient="auto"
          markerUnits="userSpaceOnUse"
        >
          <path
            d="M 0,4.4 L 8,10 L 0,15.6 M 0,10 L 8,10"
            fill="none"
            stroke={edgeColor}
            strokeWidth={EDGE_WIDTH / 1.6}
            strokeLinecap="round"
            strokeLinejoin="round"
          />
          <line x1="10" y1="6.25" x2="10" y2="13.75" stroke={edgeColor} strokeWidth={EDGE_WIDTH / 1.6} strokeLinecap="round" />
        </marker>
        {/* One — at source/FK end (double bar) */}
        <marker
          id="cf-one"
          viewBox="0 0 10 20"
          refX="2"
          refY="10"
          markerWidth="10"
          markerHeight="15"
          orient="auto"
          markerUnits="userSpaceOnUse"
        >
          <line x1="3" y1="2" x2="3" y2="18" stroke={edgeColor} strokeWidth="1.5" strokeLinecap="round" />
          <line x1="7" y1="2" x2="7" y2="18" stroke={edgeColor} strokeWidth="1.5" strokeLinecap="round" />
        </marker>
        {/* Selected variants */}
        <marker
          id="cf-many-selected"
          viewBox="0 0 15 20"
          refX="6"
          refY="10"
          markerWidth="24"
          markerHeight="32"
          orient="auto"
          markerUnits="userSpaceOnUse"
        >
          <path
            d="M 0,4.4 L 8,10 L 0,15.6 M 0,10 L 8,10"
            fill="none"
            stroke={selectionColor}
            strokeWidth={EDGE_SELECTED_WIDTH / 1.6}
            strokeLinecap="round"
            strokeLinejoin="round"
          />
          <line x1="10" y1="6.25" x2="10" y2="13.75" stroke={selectionColor} strokeWidth={EDGE_SELECTED_WIDTH / 1.6} strokeLinecap="round" />
        </marker>
        <marker
          id="cf-one-selected"
          viewBox="0 0 10 20"
          refX="2"
          refY="10"
          markerWidth="10"
          markerHeight="15"
          orient="auto"
          markerUnits="userSpaceOnUse"
        >
          <line x1="3" y1="2" x2="3" y2="18" stroke={selectionColor} strokeWidth="1.5" strokeLinecap="round" />
          <line x1="7" y1="2" x2="7" y2="18" stroke={selectionColor} strokeWidth="1.5" strokeLinecap="round" />
        </marker>
      </defs>
    </svg>
  );
}

/**
 * Custom edge with crow's feet notation using shared global markers.
 */
/**
 * Build an SVG path command string for an orthogonal polyline from absolute
 * waypoints: `M x0 y0 L x1 y1 L x2 y2 ...`. The crow's-foot markers self-orient
 * on the first/last segment via `orient="auto"`, so no smoothing is needed.
 */
export function waypointsToPath(waypoints: [number, number][]): string {
  if (waypoints.length === 0) return "";
  const [first, ...rest] = waypoints;
  const head = `M ${first[0]} ${first[1]}`;
  const tail = rest.map(([x, y]) => `L ${x} ${y}`).join(" ");
  return tail ? `${head} ${tail}` : head;
}

/**
 * The cf-many ("crow's foot") marker anchors at refX=6 in a 15-unit viewBox
 * rendered 24px wide (scale 1.6×), so its prong wide-ends fall ~5px behind the
 * anchor point. When a waypoint endpoint sits exactly on the table edge the
 * prongs get pushed inside the box and read as "covered". Column-handle
 * (left/right) edges already sit a few px outside the box, which is why they
 * look right. Inset the source end of the polyline outward along its first
 * segment by the same clearance so top/bottom crow's feet land at the edge,
 * matching the sides. The cf-one (target) marker sits forward of its anchor,
 * so the target end needs no inset.
 */
const MANY_MARKER_CLEARANCE = 5;

function insetSourceForMarker(waypoints: [number, number][]): [number, number][] {
  if (waypoints.length < 2) return waypoints;
  const [p0, p1] = waypoints;
  const dx = p1[0] - p0[0];
  const dy = p1[1] - p0[1];
  const len = Math.hypot(dx, dy);
  if (len === 0) return waypoints;
  const d = Math.min(MANY_MARKER_CLEARANCE, len * 0.4);
  const moved: [number, number] = [p0[0] + (dx / len) * d, p0[1] + (dy / len) * d];
  return [moved, ...waypoints.slice(1)];
}

function CrowsFootEdgeComponent({
  id,
  sourceX,
  sourceY,
  targetX,
  targetY,
  sourcePosition,
  targetPosition,
  selected,
  data,
}: EdgeProps & { data?: { onEdgeClick?: (sourceNodeId: string, targetNodeId: string, edgeId: string) => void; sourceNodeId?: string; targetNodeId?: string; edgeId?: string; waypoints?: [number, number][] } }) {
  const [smoothPath] = getSmoothStepPath({
    sourceX,
    sourceY,
    targetX,
    targetY,
    sourcePosition,
    targetPosition,
    borderRadius: 8,
  });

  // Focal hidden-columns view: the backend hands us an orthogonal polyline in
  // absolute coords. Draw it directly; otherwise fall back to smoothstep
  // (overview + keys/all) so those views render byte-identically.
  const waypoints = data?.waypoints;
  const edgePath =
    waypoints && waypoints.length > 0
      ? waypointsToPath(insetSourceForMarker(waypoints))
      : smoothPath;

  const [hovered, setHovered] = useState(false);
  // Selected wins over hover; both use the selection color + heavier stroke so
  // the edge the user is about to (or did) act on stands out from its
  // overlapping neighbors. Hover is the pre-click cue that fixes "I clicked and
  // the wrong edge selected".
  const active = selected || hovered;
  const color = active ? getSelectionColor() : getEdgeColor();
  const width = selected
    ? EDGE_SELECTED_WIDTH
    : hovered
      ? EDGE_HOVER_WIDTH
      : EDGE_WIDTH;
  const suffix = active ? "-selected" : "";

  const handleClick = useCallback((e: React.MouseEvent) => {
    e.stopPropagation(); // prevent pane click from clearing selection
    if (data?.onEdgeClick && data?.sourceNodeId && data?.targetNodeId && data?.edgeId) {
      data.onEdgeClick(data.sourceNodeId, data.targetNodeId, data.edgeId);
    }
  }, [data]);

  return (
    <g
      onClick={handleClick}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      style={{ cursor: data?.onEdgeClick ? "pointer" : undefined }}
    >
      {/* Invisible wide interaction path FIRST so it sits under the visible
          stroke but still captures hover/click across a generous hit-area —
          the key to picking one edge out of a dense overlapping bundle. */}
      <path
        data-testid="edge-hit-target"
        d={edgePath}
        fill="none"
        stroke="transparent"
        strokeWidth={EDGE_INTERACTION_WIDTH}
        strokeLinecap="round"
      />
      <path
        id={id}
        d={edgePath}
        style={{ fill: "none", stroke: color, strokeWidth: width, pointerEvents: "none" }}
        markerStart={`url(#cf-many${suffix})`}
        markerEnd={`url(#cf-one${suffix})`}
      />
    </g>
  );
}

export const CrowsFootEdge = memo(CrowsFootEdgeComponent);
