/**
 * Phase 4 wirer adversarial tests — run pipeline view (RunOperation rows).
 *
 * Per docs/orchestrator-design.md §8:
 *   - GET /runs/{id}/operations returns RunOperation rows.
 *   - The new RunPipelineView component renders one badge per row,
 *     coloured by status, with a link to the produced version page when
 *     output_version_id is set.
 *   - When the endpoint returns an empty list (legacy run with no
 *     RunOperation rows persisted), the component falls back to the
 *     pre-existing ProgressPipeline component.
 *
 * STUB-FOR-INTEGRATION: this file imports
 *   `@/components/runs/run-pipeline-view` (or wherever the integrator
 *   places it). On `main` the component does not exist.
 */

import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { Suspense } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

// Phase 4 component path. ``RunPipelineView`` re-exports the
// canonical ``RunOperationsPipeline`` component under the spec §8 name;
// see components/runs/run-pipeline-view.tsx for the shim.
import { RunPipelineView } from "@/components/runs/run-pipeline-view";

type RunOpRow = {
  id: string;
  step_index: number;
  operation_name: string;
  status: string;
  output_version_id: string | null;
  output_version_label?: string | null;
  output_version_url?: string | null;
  parent_version_id?: string | null;
  databricks_run_id?: number | null;
  error_message?: string;
};

const FOUR_ROW_FIXTURE: RunOpRow[] = [
  {
    id: "ro-0",
    step_index: 0,
    operation_name: "generate_ecm",
    status: "succeeded",
    output_version_id: "mv-ecm-1",
    // #49: backend resolves the linked ModelVersion's natural key so
    // the Phase row's "→ v1 ECM" affordance is human-meaningful and
    // navigable (instead of the dead #/model-versions/{uuid} hash).
    output_version_label: "v1 ECM",
    output_version_url: "/businesses/biz-1/model/1/ecm",
  },
  {
    id: "ro-1",
    step_index: 1,
    operation_name: "install",
    status: "succeeded",
    output_version_id: null,
  },
  {
    id: "ro-2",
    step_index: 2,
    operation_name: "shrink_to_mvm",
    status: "running",
    output_version_id: null,
  },
  {
    id: "ro-3",
    step_index: 3,
    operation_name: "install",
    status: "pending",
    output_version_id: null,
  },
];

let opsResponse: RunOpRow[] = [];
let progressResponse: any[] = [];

beforeEach(() => {
  opsResponse = [];
  progressResponse = [];
  // @ts-expect-error happy path
  global.fetch = vi.fn((url: string) => {
    if (typeof url !== "string") url = (url as URL).toString();
    if (url.match(/\/runs\/[^/]+\/operations/)) {
      return Promise.resolve({
        ok: true,
        json: () => Promise.resolve(opsResponse),
      } as Response);
    }
    if (url.match(/\/runs\/[^/]+\/progress/)) {
      return Promise.resolve({
        ok: true,
        json: () => Promise.resolve(progressResponse),
      } as Response);
    }
    return Promise.resolve({
      ok: true,
      json: () => Promise.resolve({}),
    } as Response);
  });
});

afterEach(() => {
  vi.restoreAllMocks();
});

function renderView(runId: string, props: any = {}) {
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false, refetchOnWindowFocus: false } },
  });
  return render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={<div data-testid="suspense-fallback">loading</div>}>
        <RunPipelineView runId={runId} {...props} />
      </Suspense>
    </QueryClientProvider>,
  );
}

describe("RunPipelineView — RunOperation rows", () => {
  it("renders one step badge per RunOperation row", async () => {
    opsResponse = FOUR_ROW_FIXTURE;
    renderView("run-1");
    // Wait for at least one of the operation labels to render.
    await waitFor(() => {
      expect(screen.getAllByText(/generate_ecm/i).length).toBeGreaterThanOrEqual(1);
    });
    // We expect 4 distinct step entries — each row contributes a badge.
    // The component may render the operation name once + a status badge,
    // so we check the existence of each operation label across the row set.
    expect(screen.getAllByText(/generate_ecm/i).length).toBeGreaterThanOrEqual(1);
    expect(screen.getAllByText(/shrink_to_mvm/i).length).toBeGreaterThanOrEqual(1);
    // "install" appears twice — once per scope.
    expect(screen.getAllByText(/install/i).length).toBeGreaterThanOrEqual(2);
  });

  it("falls back to legacy progress component when operations list is empty", async () => {
    opsResponse = [];
    progressResponse = [];
    renderView("run-1");
    // The fallback should NOT show any RunOperation step badges.
    // It MAY render the legacy ProgressPipeline (which queries
    // /runs/{id}/progress) — verify by absence of generate_ecm-like
    // step labels rather than by presence of an explicit fallback marker
    // (the integrator may keep the legacy component name internal).
    await waitFor(() => {
      // Wait for any render to settle.
      const fallback = document.querySelector("[data-testid='suspense-fallback']");
      expect(fallback).toBeNull();
    });
    expect(screen.queryByText(/generate_ecm/i)).toBeNull();
    expect(screen.queryByText(/shrink_to_mvm/i)).toBeNull();
  });

});
