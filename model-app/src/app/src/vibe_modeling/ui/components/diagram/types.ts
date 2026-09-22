/**
 * TypeScript types for the diagram API response and column display mode.
 */

/** Column display mode: hide all, show only PK/FK, show all columns */
export type ColumnDisplayMode = "hide" | "keys" | "all";

export interface DiagramNodePort {
  id: string;
  name: string;
  is_pk: boolean;
  is_fk: boolean;
  type: string;
  description: string;
  fk_target: string;
}

export interface DiagramNode {
  id: string;
  domain: string;
  product: string;
  table_name: string;
  product_type: string;
  description: string;
  x: number;
  y: number;
  width: number;
  height: number;
  columns: DiagramNodePort[];
  column_count: number;
  fk_count: number;
  change_status?: "unchanged" | "new" | "modified";
}

export interface DiagramEdge {
  id: string;
  source_node: string;
  source_column: string;
  target_node: string;
  target_column: string;
  /**
   * Focal-view orthogonal routing (Increment 1). Absolute (x, y) polyline
   * points from the source anchor to the target anchor. Empty/absent means
   * "no backend routing" — the frontend falls back to its smoothstep path
   * (overview + keys/all focal views).
   */
  waypoints?: [number, number][];
}

export interface DiagramDomainGroup {
  id: string;
  domain: string;
  division: string;
  x: number;
  y: number;
  width: number;
  height: number;
  is_external: boolean;
  product_count: number;
}

export interface DiagramLayoutResponse {
  nodes: DiagramNode[];
  edges: DiagramEdge[];
  groups: DiagramDomainGroup[];
  domain_filter: string | null;
  show_columns: boolean;
  total_products: number;
  total_edges: number;
}

/**
 * 202 response body when the diagram layout is still computing.
 *
 * Carries a heartbeat timestamp + queue position so the spinner can show
 * "we're alive, you're #N in queue" instead of running forever with no
 * signal. See backend `DiagramPendingOut`. Added for task #104.
 */
export interface DiagramPendingResponse {
  status: "computing";
  key: string;
  /** ms-epoch of the most recent heartbeat for this key. */
  last_heartbeat_ms: number;
  /** 1-indexed position in the prefetch queue, or null if not queued. */
  queue_position: number | null;
  /** Total pending jobs the prefetch pool knows about. */
  total_in_queue: number;
}
