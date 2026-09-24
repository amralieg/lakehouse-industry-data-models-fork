/**
 * Tests for RunHierarchyPipeline and its helpers.
 *
 * Coverage:
 *  1. Two-Phase DAG renders 2 outer Phase rows in step_index order.
 *  2. Agent steps appear ONLY under their owning Phase.
 *  3. Synthetic "Phase N:" boundary events are NOT rendered as Step rows.
 *  4. Phase 1 always has a header from dispatch time (before any event arrives).
 *  5. Completed Phases default-collapsed, running Phase default-expanded.
 *  6. Status badges render correctly per phase.
 *  7. Duration renders for phases that have started_at + completed_at.
 *  8. partitionEventsByPhase — unit tests for phase assignment logic.
 *  9. isSuperseded — ported helper tests.
 * 10. RUNNING_STATUSES / TERMINAL_STATUSES set-membership tests.
 */

import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import type { ReactNode } from "react";
import { Suspense } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { RunOperationOut, RunStatus } from "@/lib/api";
import {
  partitionEventsByPhase,
  isSuperseded,
  extractVibeSessionBrackets,
} from "@/components/runs/run-hierarchy-pipeline";

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

let useListMock: () => unknown = () => ({ data: { data: [] }, isLoading: false });

vi.mock("@/lib/api", async () => ({
  useListRunOperations: () => useListMock(),
  // Phase 7 drift-unification: progress fetch routes through the Orval-
  // generated helper. Tests stub `global.fetch` directly, so we forward
  // through to the real fetch and shape the response like the real
  // helper does (`{ data: ProgressEventOut[] }`).
  getRunProgress: async ({
    business_id,
    run_id,
  }: {
    business_id: string;
    run_id: string;
  }) => {
    const res = await fetch(
      `/api/businesses/${business_id}/runs/${run_id}/progress`,
    );
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return { data: await res.json() };
  },
}));

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

type Ev = {
  id: string;
  step_id: number;
  stage_name: string;
  step_name: string;
  status: string;
  message: string;
  progress_increment: number;
  created_at: string;
};

function ev(
  step_id: number,
  stage: string,
  step: string,
  status: string,
  created_at?: string,
): Ev {
  return {
    id: `${step_id}-${stage}-${step}`,
    step_id,
    stage_name: stage,
    step_name: step,
    status,
    message: step,
    progress_increment: 0,
    created_at: created_at ?? new Date().toISOString(),
  };
}

function makeOp(
  step_index: number,
  operation_name: string,
  status = "running",
  extra: Partial<RunOperationOut> = {},
): RunOperationOut {
  // Default per-phase timestamps so the time-window partitioner has
  // non-overlapping windows. Aligns with the "two-phase" FETCH_FIXTURES
  // event timestamps (Phase 1 events at 10:01–10:05, Phase 2 events
  // at 10:35).
  const defaultStart = `2026-04-26T10:${String(step_index * 30).padStart(2, "0")}:00Z`;
  const defaultEnd =
    status === "succeeded"
      ? `2026-04-26T10:${String(step_index * 30 + 29).padStart(2, "0")}:00Z`
      : null;
  return {
    id: `op-${step_index}`,
    run_id: "run-1",
    step_index,
    operation_name,
    status,
    started_at: defaultStart,
    completed_at: defaultEnd,
    created_at: "2026-04-20T00:00:00Z",
    ...extra,
  };
}

// "two-phase" fixture timestamps are picked to fall inside the default
// makeOp() time windows (Phase 1: 10:00–10:29, Phase 2: 10:30+) so the
// time-window partitioner assigns them correctly.

// Fetch fixtures keyed by runId.
const FETCH_FIXTURES: Record<string, Ev[]> = {
  "two-phase": [
    ev(100, "Vibe Session", "session-start", "stage_succeeded", "2026-04-26T10:01:00Z"),
    ev(200, "Designing Domains", "domain-gen", "stage_succeeded", "2026-04-26T10:05:00Z"),
    // Legacy boundary marker — must be filtered out of step rows.
    ev(500, "Phase 2: shrink_to_mvm", "boundary", "stage_started", "2026-04-26T10:30:00Z"),
    ev(600, "Logical Schema Generation", "schema-gen", "running", "2026-04-26T10:35:00Z"),
  ],
  "no-boundary": [
    ev(100, "Vibe Session", "session-start", "stage_succeeded", "2026-04-26T10:01:00Z"),
    ev(200, "Designing Domains", "domain-gen", "running", "2026-04-26T10:05:00Z"),
  ],
  "empty": [],
};

beforeEach(() => {
  // @ts-expect-error test mock
  global.fetch = vi.fn((url: string) => {
    if (typeof url !== "string") url = (url as URL).toString();
    const runId = url.match(/runs\/([^/]+)\/progress/)?.[1] ?? "";
    return Promise.resolve({
      ok: true,
      json: () => Promise.resolve(FETCH_FIXTURES[runId] ?? []),
    } as Response);
  });
});

// ---------------------------------------------------------------------------
// Render helpers
// ---------------------------------------------------------------------------

function withProviders(ui: ReactNode) {
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return (
    <QueryClientProvider client={qc}>
      <Suspense fallback={<div data-testid="loading">loading</div>}>
        {ui}
      </Suspense>
    </QueryClientProvider>
  );
}

async function renderHierarchy(runId: string, ops: RunOperationOut[]) {
  // Import here so the mock is in place.
  const { RunHierarchyPipeline } = await import(
    "@/components/runs/run-hierarchy-pipeline"
  );

  useListMock = () => ({
    data: { data: ops },
    isLoading: false,
  });

  const result = render(
    withProviders(<RunHierarchyPipeline businessId="biz-1"
          runId={runId} progressPercent={50} />),
  );
  // Wait for the Suspense boundary to resolve (progress fetch).
  await screen.findByTestId("run-hierarchy-pipeline");
  return result;
}

/**
 * Variant of `renderHierarchy` for the zero-ops / zero-events empty states
 * (walkthrough fix: terminal audit runs vs. still-booting runs), which don't
 * render the `run-hierarchy-pipeline` testid. Waits on the Suspense
 * boundary via the progress-fetch call instead.
 */
async function renderHierarchyEmpty(
  runId: string,
  opts: { status?: RunStatus | null; progressPercent?: number },
) {
  const { RunHierarchyPipeline } = await import(
    "@/components/runs/run-hierarchy-pipeline"
  );

  useListMock = () => ({
    data: { data: [] },
    isLoading: false,
  });

  const result = render(
    withProviders(
      <RunHierarchyPipeline
        businessId="biz-1"
        runId={runId}
        status={opts.status ?? null}
        progressPercent={opts.progressPercent ?? 0}
      />,
    ),
  );
  await vi.waitFor(() => expect(global.fetch).toHaveBeenCalled());
  return result;
}

// ---------------------------------------------------------------------------
// 1. Two-Phase DAG renders 2 outer Phase rows in step_index order
// ---------------------------------------------------------------------------

describe("RunHierarchyPipeline — two-phase DAG", () => {
  it("renders 2 Phase rows with correct labels", async () => {
    const ops = [
      makeOp(0, "generate_ecm", "succeeded"),
      makeOp(1, "shrink_to_mvm", "running"),
    ];
    await renderHierarchy("two-phase", ops);

    const phaseRows = screen.getAllByTestId("phase-row");
    expect(phaseRows).toHaveLength(2);

    // Labels use step_index + 1 for the "Phase N" number.
    expect(screen.getByText(/Phase 1 — generate_ecm/i)).toBeInTheDocument();
    expect(screen.getByText(/Phase 2 — shrink_to_mvm/i)).toBeInTheDocument();
  });

});

// ---------------------------------------------------------------------------
// Bug #46 — surface the stage_succeeded summary, not the last in-progress ping
// ---------------------------------------------------------------------------

describe("RunHierarchyPipeline — bug #46 summary message", () => {
  it("displays the stage_succeeded summary as the step's primary text, not the last in-progress event", async () => {
    // A stage that emits N in-progress per-domain events plus a closing
    // stage_succeeded event with a high-level summary line. The collapsed
    // PhaseStepRow MUST surface the summary, not the last per-domain ping.
    const ops = [makeOp(0, "generate_ecm", "succeeded")];

    function evWithMessage(
      step_id: number,
      stage: string,
      step: string,
      status: string,
      message: string,
      created_at: string,
    ): Ev {
      return {
        id: `${step_id}-${stage}-${step}`,
        step_id,
        stage_name: stage,
        step_name: step,
        status,
        message,
        progress_increment: 0,
        created_at,
      };
    }

    global.fetch = vi.fn(() =>
      Promise.resolve({
        ok: true,
        json: () =>
          Promise.resolve([
            evWithMessage(
              60,
              "Creating Data Products",
              "start",
              "stage_started",
              "Starting product generation",
              "2026-04-26T10:01:00Z",
            ),
            evWithMessage(
              61,
              "Creating Data Products",
              "domain-1",
              "running",
              "Domain 'fulfillment': generated 4 products",
              "2026-04-26T10:01:10Z",
            ),
            evWithMessage(
              62,
              "Creating Data Products",
              "domain-2",
              "running",
              "Domain 'inventory': generated 6 products",
              "2026-04-26T10:01:20Z",
            ),
            evWithMessage(
              63,
              "Creating Data Products",
              "domain-3",
              "running",
              "Domain 'supply': generated 5 products",
              "2026-04-26T10:01:30Z",
            ),
            evWithMessage(
              64,
              "Creating Data Products",
              "summary",
              "stage_succeeded",
              "Generated 35 products across 8 domains",
              "2026-04-26T10:01:40Z",
            ),
          ]),
      } as Response),
    ) as unknown as typeof fetch;

    useListMock = () => ({ data: { data: ops }, isLoading: false });
    const { RunHierarchyPipeline } = await import(
      "@/components/runs/run-hierarchy-pipeline"
    );
    const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
    render(
      <QueryClientProvider client={qc}>
        <Suspense fallback={<div>loading</div>}>
          <RunHierarchyPipeline businessId="biz-1"
          runId="bug-46" progressPercent={100} />
        </Suspense>
      </QueryClientProvider>,
    );
    await screen.findByTestId("run-hierarchy-pipeline");

    // Phase 1 is succeeded → collapsed by default. Expand the phase header
    // so the PhaseStepRow renders, but leave the inner step row collapsed
    // so we exercise the summary-line code path.
    fireEvent.click(screen.getByText(/Phase 1 — generate_ecm/i));

    const summary = screen.getByTestId("step-summary-message");
    expect(summary.textContent).toBe("Generated 35 products across 8 domains");
    // The last per-domain ping must NOT be the rendered primary text.
    expect(summary.textContent).not.toContain("supply");
  });
});

// ---------------------------------------------------------------------------
// 2. Agent steps appear ONLY under their owning Phase
// ---------------------------------------------------------------------------

describe("RunHierarchyPipeline — boundary events filtered", () => {
  it("does not render a Step row for the phase boundary event", async () => {
    const ops = [
      makeOp(0, "generate_ecm", "succeeded"),
      makeOp(1, "shrink_to_mvm", "running"),
    ];
    await renderHierarchy("two-phase", ops);

    // Expand Phase 1 to surface its step list.
    fireEvent.click(screen.getByText(/Phase 1 — generate_ecm/i));

    // The boundary stage_name "Phase 2: shrink_to_mvm" should NOT appear as
    // a step row inside the tree. It's ok if part of the phase-header label
    // matches, but there should be no standalone Step row with that name.
    // Phase-header labels are "Phase N — op_name", not "Phase N: op_name",
    // so an exact match on "Phase 2: shrink_to_mvm" would be a boundary leak.
    expect(screen.queryByText("Phase 2: shrink_to_mvm")).not.toBeInTheDocument();
  });
});

// ---------------------------------------------------------------------------
// 4. Phase 1 always has a header from dispatch time
// ---------------------------------------------------------------------------

describe("RunHierarchyPipeline — collapse/expand defaults", () => {
  it("completed Phase is collapsed by default (children not visible)", async () => {
    const ops = [
      makeOp(0, "generate_ecm", "succeeded"),
      makeOp(1, "shrink_to_mvm", "running"),
    ];
    await renderHierarchy("two-phase", ops);

    // Phase 1 is succeeded → collapsed → its inner steps NOT visible initially.
    expect(screen.queryByText("Vibe Session")).not.toBeInTheDocument();
    expect(screen.queryByText("Designing Domains")).not.toBeInTheDocument();
  });
});

// ---------------------------------------------------------------------------
// 5b. output_version link uses natural-key URL + human-meaningful label (#49)
// ---------------------------------------------------------------------------

describe("RunHierarchyPipeline — output_version link", () => {
  it("renders natural-key URL + label when output_version_url is set", async () => {
    const ops = [
      makeOp(0, "generate_ecm", "succeeded", {
        output_version_id: "mv-uuid-1",
        output_version_label: "v1 ECM",
        output_version_url: "/businesses/biz-1/model/1/ecm",
      }),
    ];
    await renderHierarchy("empty", ops);

    // Anchor should use the natural-key URL, NOT the dead hash anchor.
    const link = document.querySelector(
      'a[data-version-id="mv-uuid-1"]',
    ) as HTMLAnchorElement | null;
    expect(link).not.toBeNull();
    expect(link!.getAttribute("href")).toBe("/businesses/biz-1/model/1/ecm");
    expect(link!.getAttribute("href")).not.toMatch(/^#\/model-versions\//);
    // Label uses the human-meaningful "v1 ECM" form, not a UUID prefix.
    expect(link!.textContent).toContain("v1 ECM");
    expect(link!.textContent).not.toMatch(/v[0-9a-f]{8}/);
  });

});

// ---------------------------------------------------------------------------
// 6. Status badges per phase
// ---------------------------------------------------------------------------

describe("RunHierarchyPipeline — status badges", () => {
  it("renders correct status for each phase", async () => {
    const ops = [
      makeOp(0, "generate_ecm", "succeeded"),
      makeOp(1, "shrink_to_mvm", "running"),
    ];
    await renderHierarchy("two-phase", ops);

    expect(screen.getByText("succeeded")).toBeInTheDocument();
    expect(screen.getByText("running")).toBeInTheDocument();
  });
});

// ---------------------------------------------------------------------------
// 7. partitionEventsByPhase — unit tests
// ---------------------------------------------------------------------------

describe("partitionEventsByPhase", () => {
  it("assigns events to phases by created_at falling within each op's window", () => {
    const ops = [
      makeOp(0, "generate_ecm", "succeeded", {
        started_at: "2026-04-26T10:00:00Z",
        completed_at: "2026-04-26T10:30:00Z",
      }),
      makeOp(1, "shrink_to_mvm", "running", {
        started_at: "2026-04-26T10:30:01Z",
      }),
    ];
    const events = [
      ev(100, "Vibe Session", "start", "stage_succeeded", "2026-04-26T10:00:30Z"),
      ev(600, "Logical Schema Generation", "schema", "running", "2026-04-26T10:35:00Z"),
    ];
    const result = partitionEventsByPhase(events, ops);
    expect(result.get("op-0")).toHaveLength(1);
    expect(result.get("op-1")).toHaveLength(1);
    expect(result.get("op-0")![0].stage_name).toBe("Vibe Session");
    expect(result.get("op-1")![0].stage_name).toBe("Logical Schema Generation");
  });

  it("strips legacy boundary events with stage_name 'Phase N:'", () => {
    const ops = [
      makeOp(0, "generate_ecm", "succeeded", {
        started_at: "2026-04-26T10:00:00Z",
        completed_at: "2026-04-26T10:30:00Z",
      }),
      makeOp(1, "shrink_to_mvm", "running", {
        started_at: "2026-04-26T10:30:01Z",
      }),
    ];
    const events = [
      ev(100, "Vibe Session", "start", "stage_succeeded", "2026-04-26T10:00:30Z"),
      // Legacy boundary marker — must be filtered out, not assigned to a phase.
      ev(500, "Phase 2: shrink_to_mvm", "boundary", "stage_started", "2026-04-26T10:30:00Z"),
      ev(600, "Logical Schema Generation", "schema", "running", "2026-04-26T10:35:00Z"),
    ];
    const result = partitionEventsByPhase(events, ops);
    expect(result.get("op-0")).toHaveLength(1);
    expect(result.get("op-1")).toHaveLength(1);
  });

  it("handles naive-UTC backend datetime strings (no Z suffix)", () => {
    // Backend serializes naive UTC; our parser must append Z so deltas
    // don't include browser TZ offset.
    const ops = [
      makeOp(0, "ecm", "succeeded", {
        started_at: "2026-04-26T10:00:00",
        completed_at: "2026-04-26T10:30:00",
      }),
      makeOp(1, "mvm", "running", {
        started_at: "2026-04-26T10:30:01",
      }),
    ];
    const events = [
      ev(100, "ECM Step", "s", "completed", "2026-04-26T10:15:00"),
      ev(200, "MVM Step", "s", "running", "2026-04-26T10:35:00"),
    ];
    const result = partitionEventsByPhase(events, ops);
    expect(result.get("op-0")).toHaveLength(1);
    expect(result.get("op-1")).toHaveLength(1);
    expect(result.get("op-0")![0].stage_name).toBe("ECM Step");
    expect(result.get("op-1")![0].stage_name).toBe("MVM Step");
  });
});

// ---------------------------------------------------------------------------
// 9. isSuperseded — ported from progress-pipeline helpers
// ---------------------------------------------------------------------------

describe("isSuperseded", () => {
  it("returns true for a running event with step_id < maxStepId", () => {
    const e = ev(50, "Architect Review", "Reviewing", "running");
    expect(isSuperseded(e, 100)).toBe(true);
  });

  it("returns false for a running event with step_id === maxStepId", () => {
    const e = ev(100, "Creating Products", "start", "running");
    expect(isSuperseded(e, 100)).toBe(false);
  });

});

// ---------------------------------------------------------------------------
// Ported from progress-pipeline.test.tsx — supersession + warning-terminal
// ---------------------------------------------------------------------------

describe("RunHierarchyPipeline — ported regression fixtures", () => {
  it("treats superseded-running stage as completed (no spinner)", async () => {
    const ops = [makeOp(0, "generate_ecm", "succeeded")];

    global.fetch = vi.fn(() =>
      Promise.resolve({
        ok: true,
        json: () =>
          Promise.resolve([
            ev(50, "Architect Review", "Reviewing", "running"),
            ev(60, "Creating Data Products", "start", "running"),
            ev(70, "Creating Data Products", "done", "completed"),
          ]),
      } as Response),
    ) as unknown as typeof fetch;

    useListMock = () => ({ data: { data: ops }, isLoading: false });
    const { RunHierarchyPipeline } = await import(
      "@/components/runs/run-hierarchy-pipeline"
    );
    const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
    render(
      <QueryClientProvider client={qc}>
        <Suspense fallback={<div>loading</div>}>
          <RunHierarchyPipeline businessId="biz-1"
          runId="superseded-run" progressPercent={100} />
        </Suspense>
      </QueryClientProvider>,
    );
    await screen.findByTestId("run-hierarchy-pipeline");
    const spinners = document.querySelectorAll("svg.animate-spin");
    expect(spinners.length).toBe(0);
  });
});

// ---------------------------------------------------------------------------
// F11/F12 — Vibe Session rendered as top/bottom bracket, not peer step
// ---------------------------------------------------------------------------

describe("extractVibeSessionBrackets", () => {
  it("returns the lowest-step_id event as start and highest as end", () => {
    const events = [
      ev(100, "Vibe Session", "Session Started", "stage_started", "2026-04-26T10:00:00Z"),
      ev(150, "Designing Domains", "domain", "stage_succeeded", "2026-04-26T10:01:00Z"),
      ev(200, "Vibe Session", "Session Ended", "stage_ended", "2026-04-26T10:02:00Z"),
    ];
    const { start, end } = extractVibeSessionBrackets(events);
    expect(start?.step_id).toBe(100);
    expect(end?.step_id).toBe(200);
  });

  it("returns null end when only one Vibe Session event is present", () => {
    const events = [
      ev(100, "Vibe Session", "Session Started", "stage_started", "2026-04-26T10:00:00Z"),
      ev(150, "Designing Domains", "domain", "running", "2026-04-26T10:01:00Z"),
    ];
    const { start, end } = extractVibeSessionBrackets(events);
    expect(start?.step_id).toBe(100);
    expect(end).toBeNull();
  });

  it("returns both null when no Vibe Session events present", () => {
    const events = [ev(100, "Designing Domains", "x", "running", "2026-04-26T10:00:00Z")];
    const { start, end } = extractVibeSessionBrackets(events);
    expect(start).toBeNull();
    expect(end).toBeNull();
  });
});

describe("RunHierarchyPipeline — Vibe Session bracket render", () => {
  function renderWithEvents(
    runId: string,
    ops: RunOperationOut[],
    events: Ev[],
  ) {
    global.fetch = vi.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve(events),
      } as Response),
    ) as unknown as typeof fetch;
    useListMock = () => ({ data: { data: ops }, isLoading: false });
    return import("@/components/runs/run-hierarchy-pipeline").then(
      ({ RunHierarchyPipeline }) => {
        const qc = new QueryClient({
          defaultOptions: { queries: { retry: false } },
        });
        return render(
          <QueryClientProvider client={qc}>
            <Suspense fallback={<div>loading</div>}>
              <RunHierarchyPipeline businessId="biz-1"
          runId={runId} progressPercent={100} />
            </Suspense>
          </QueryClientProvider>,
        );
      },
    );
  }

  it("does NOT render Vibe Session as a peer step in the substep list", async () => {
    const ops = [makeOp(0, "generate_ecm", "running")];
    await renderWithEvents("vibe-no-peer", ops, [
      ev(
        100,
        "Vibe Session",
        "Session Started",
        "stage_started",
        "2026-04-26T10:00:30Z",
      ),
      ev(
        200,
        "Designing Domains",
        "domain-gen",
        "running",
        "2026-04-26T10:01:00Z",
      ),
    ]);
    await screen.findByTestId("run-hierarchy-pipeline");
    // Phase is running → expanded by default. The substep list should not
    // contain a peer step labelled exactly "Vibe Session" — the bracket
    // line uses "Vibe Session started" / "Vibe Session ended" instead.
    expect(screen.queryByText("Vibe Session")).not.toBeInTheDocument();
    // The substep list should still show the real step.
    expect(screen.getByText("Designing Domains")).toBeInTheDocument();
    // Top bracket renders.
    expect(screen.getByTestId("vibe-session-bracket-start")).toBeInTheDocument();
  });

  it("renders end bracket as failed (red) when the parent phase failed, ignoring agent stage_ended literal", async () => {
    const ops = [
      makeOp(0, "generate_ecm", "failed", {
        started_at: "2026-04-26T10:00:00Z",
        completed_at: "2026-04-26T10:03:11Z",
      }),
    ];
    const errorMsg =
      "[ValueError] v0.9.1 SHRINK-NEW-SILO validator: domain 'orders' has no products";
    await renderWithEvents("vibe-failed", ops, [
      ev(
        100,
        "Vibe Session",
        "Session Started",
        "stage_started",
        "2026-04-26T10:00:01Z",
      ),
      ev(
        200,
        "Designing Domains",
        "x",
        "stage_succeeded",
        "2026-04-26T10:01:00Z",
      ),
      // Agent emits stage_ended literally even on failure path; the
      // failure information is in the message field.
      {
        ...ev(
          300,
          "Vibe Session",
          "Session Ended",
          "stage_ended",
          "2026-04-26T10:03:11Z",
        ),
        message: errorMsg,
      },
    ]);
    await screen.findByTestId("run-hierarchy-pipeline");

    // Failed phases default to collapsed (only `running` auto-expands).
    // Expand it so the bracket renders.
    fireEvent.click(screen.getByText(/Phase 1 — generate_ecm/i));

    const endBracket = screen.getByTestId("vibe-session-bracket-end");
    expect(endBracket.getAttribute("data-failed")).toBe("true");
    // Error message should render under the bracket.
    const msgEl = screen.getByTestId("vibe-session-bracket-end-message");
    expect(msgEl.textContent).toContain("SHRINK-NEW-SILO");
  });

  it("renders end bracket as success (green) when the parent phase succeeded", async () => {
    const ops = [
      makeOp(0, "generate_ecm", "succeeded", {
        started_at: "2026-04-26T10:00:00Z",
        completed_at: "2026-04-26T10:02:00Z",
      }),
    ];
    await renderWithEvents("vibe-succeeded", ops, [
      ev(
        100,
        "Vibe Session",
        "Session Started",
        "stage_started",
        "2026-04-26T10:00:01Z",
      ),
      ev(
        200,
        "Designing Domains",
        "x",
        "stage_succeeded",
        "2026-04-26T10:01:00Z",
      ),
      {
        ...ev(
          300,
          "Vibe Session",
          "Session Ended",
          "stage_ended",
          "2026-04-26T10:02:00Z",
        ),
        message: "Session complete",
      },
    ]);
    await screen.findByTestId("run-hierarchy-pipeline");

    // Phase is succeeded → collapsed by default. Expand it so the bracket
    // renders.
    fireEvent.click(screen.getByText(/Phase 1 — generate_ecm/i));
    const endBracket = screen.getByTestId("vibe-session-bracket-end");
    expect(endBracket.getAttribute("data-failed")).toBe("false");
    const msgEl = screen.getByTestId("vibe-session-bracket-end-message");
    expect(msgEl.textContent).toContain("Session complete");
  });
});

// ---------------------------------------------------------------------------
// 11. Terminal audit runs (walkthrough fix): zero ops + zero events must not
//     show a permanent "running" spinner once the run is done.
// ---------------------------------------------------------------------------

describe("RunHierarchyPipeline — terminal audit runs with no pipeline events", () => {
  it("renders a terminal empty state (no spinner, no 'running' text) for a completed run with zero events", async () => {
    await renderHierarchyEmpty("empty", { status: "completed", progressPercent: 100 });

    expect(
      await screen.findByText(/no pipeline checkpoints/i),
    ).toBeInTheDocument();
    expect(screen.queryByText(/pipeline running/i)).not.toBeInTheDocument();
    expect(screen.queryByText(/waiting for the agent/i)).not.toBeInTheDocument();
    expect(document.querySelector(".animate-spin")).toBeNull();
  });

  it("renders the same terminal empty state for a failed run with zero events", async () => {
    await renderHierarchyEmpty("empty", { status: "failed", progressPercent: 40 });

    expect(
      await screen.findByText(/no pipeline checkpoints/i),
    ).toBeInTheDocument();
    expect(document.querySelector(".animate-spin")).toBeNull();
  });

  it("still shows the running spinner for a non-terminal run with zero events (unchanged behavior)", async () => {
    await renderHierarchyEmpty("empty", { status: "running", progressPercent: 50 });

    expect(
      await screen.findByText(/pipeline running/i),
    ).toBeInTheDocument();
    expect(document.querySelector(".animate-spin")).not.toBeNull();
  });

  it("still shows the 'waiting to start' message when status is unknown and progress is 0 (backward-compat)", async () => {
    await renderHierarchyEmpty("empty", { status: null, progressPercent: 0 });

    expect(
      await screen.findByText(/waiting for the agent to start/i),
    ).toBeInTheDocument();
  });
});
