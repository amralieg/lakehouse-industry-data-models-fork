/**
 * Diagram-layout polling helper.
 *
 * The diagram-layout endpoint is a 200/202 polling protocol: 200 returns
 * the layout JSON; 202 means "still computing" and carries an optional
 * heartbeat envelope used to render queue position + last-heartbeat time.
 *
 * The Orval-generated ``getDiagramLayout`` collapses this distinction
 * because its boundary is ``res.ok`` (200-299) — the 202 status is lost
 * by the time the helper returns. We keep the raw fetch here, in
 * ``lib/``, so the only ``fetch(`` call lives in one place rather than
 * scattered across ``components/diagram/`` (Phase 7 drift-unification —
 * components/ should not own raw API plumbing).
 *
 * The URL is constructed to match the OpenAPI spec exactly so generated
 * key collisions stay impossible.
 */

import type { DiagramLayoutResponse, DiagramPendingResponse } from "@/components/diagram/types";

export type DiagramLayoutPollResult =
  | { kind: "ready"; layout: DiagramLayoutResponse }
  | { kind: "pending"; info: DiagramPendingResponse | null };

export type FetchDiagramLayoutParams = {
  businessId: string;
  version: number;
  scope: string;
  domain?: string | null;
  columnMode: string;
  signal?: AbortSignal;
};

/**
 * Single-shot fetch for the diagram-layout endpoint. The caller is
 * responsible for retrying on `kind === "pending"` (the polling cadence
 * is owned by the caller — typically a 2s setTimeout loop).
 *
 * Throws on 4xx/5xx with the server-provided ``detail`` string when
 * available, falling back to ``HTTP <status>``.
 */
export async function fetchDiagramLayoutOnce(
  params: FetchDiagramLayoutParams,
): Promise<DiagramLayoutPollResult> {
  const search = new URLSearchParams();
  if (params.domain) search.set("domain", params.domain);
  search.set("column_mode", params.columnMode);
  const url = `/api/businesses/${params.businessId}/versions/${params.version}/${params.scope}/diagram?${search}`;

  const res = await fetch(url, { signal: params.signal });
  if (res.status === 202) {
    try {
      const body = (await res.json()) as Partial<DiagramPendingResponse> & {
        status?: string;
        key?: string;
      };
      if (
        body &&
        typeof body.last_heartbeat_ms === "number" &&
        typeof body.total_in_queue === "number"
      ) {
        return {
          kind: "pending",
          info: {
            status: "computing",
            key: body.key ?? "",
            last_heartbeat_ms: body.last_heartbeat_ms,
            queue_position: body.queue_position ?? null,
            total_in_queue: body.total_in_queue,
          } as DiagramPendingResponse,
        };
      }
      return { kind: "pending", info: null };
    } catch {
      // Non-JSON body on 202 — swallow and keep legacy behavior.
      return { kind: "pending", info: null };
    }
  }
  if (!res.ok) {
    let detail = `HTTP ${res.status}`;
    try {
      const body = await res.json();
      if (body?.detail) detail = body.detail;
    } catch {
      // Non-JSON error body — fall back to status code.
    }
    throw new Error(detail);
  }
  const wrapper: { data: DiagramLayoutResponse } | DiagramLayoutResponse =
    await res.json();
  const layout =
    "data" in wrapper && wrapper.data
      ? wrapper.data
      : (wrapper as DiagramLayoutResponse);
  return { kind: "ready", layout };
}
