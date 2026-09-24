/**
 * Skeptical-tester pass on the F11/F12 Vibe Session bracket change
 * (commit 8a368ae). DISTINCT from the dev's own additions in
 * run-hierarchy-pipeline.test.tsx.
 *
 * Spec being verified (read from the bug spec; impl was NOT read):
 *   1. `stage_name === "Vibe Session"` events are FILTERED OUT of the
 *      per-phase sub-step list. They never appear as a peer step row.
 *   2. A start bracket is rendered ABOVE the sub-step list, using the
 *      first Vibe Session event.
 *   3. An end bracket is rendered BELOW the sub-step list, using the
 *      terminal Vibe Session event.
 *   4. End-bracket color is driven by RunOperation.status:
 *        - status === "failed"   → failure styling  (red ✗ / XCircle)
 *        - status === "succeeded"/anything-else → success styling (green ✓)
 *      It is INDEPENDENT of the agent's `stage_ended` literal in the
 *      event status field.
 *   5. End-bracket message is the agent's terminal event message
 *      (carries error text on failure, summary on success).
 *
 * Edge cases:
 *   - A phase with no Vibe Session events at all (legacy / partial flush)
 *     must not crash and must render sub-steps in their natural order.
 *   - A phase with only a Session Started (no end bracket yet, process
 *     died) must not crash — start bracket renders, end bracket either
 *     absent or labelled "still running".
 */

import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import type { ReactNode } from "react";
import { Suspense } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { RunOperationOut } from "@/lib/api";

// ---------------------------------------------------------------------------
// Mocks (pattern lifted from run-hierarchy-pipeline.test.tsx — fixtures only,
// not implementation)
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

function makeOp(
  step_index: number,
  operation_name: string,
  status: string,
  extra: Partial<RunOperationOut> = {},
): RunOperationOut {
  // Wide window so all of our same-phase events fall inside.
  const start = `2026-04-26T10:${String(step_index * 30).padStart(2, "0")}:00Z`;
  const end =
    status === "succeeded" || status === "failed"
      ? `2026-04-26T10:${String(step_index * 30 + 29).padStart(2, "0")}:00Z`
      : null;
  return {
    id: `op-${step_index}`,
    run_id: "run-1",
    step_index,
    operation_name,
    status,
    started_at: start,
    completed_at: end,
    created_at: "2026-04-20T00:00:00Z",
    ...extra,
  };
}

const FETCH_FIXTURES: Record<string, Ev[]> = {
  // Failed phase: Vibe Session brackets + a successful sub-step + an
  // in-progress sub-step + Vibe Session end carrying the error text.
  "failed-phase": [
    ev(
      10,
      "Vibe Session",
      "Session Started",
      "stage_started",
      "Session started",
      "2026-04-26T10:00:30Z",
    ),
    ev(
      20,
      "Setup and Configuration",
      "init",
      "stage_succeeded",
      "Configured",
      "2026-04-26T10:01:00Z",
    ),
    ev(
      30,
      "Resize Model (Shrink)",
      "shrink",
      "stage_in_progress",
      "Shrinking ...",
      "2026-04-26T10:02:00Z",
    ),
    ev(
      40,
      "Vibe Session",
      "Session Ended",
      "stage_ended",
      "[ValueError] v0.9.1 SHRINK-NEW-SILO no candidate column",
      "2026-04-26T10:03:00Z",
    ),
  ],
  // Successful phase.
  "succeeded-phase": [
    ev(
      10,
      "Vibe Session",
      "Session Started",
      "stage_started",
      "Session started",
      "2026-04-26T10:00:30Z",
    ),
    ev(
      20,
      "Setup and Configuration",
      "init",
      "stage_succeeded",
      "Configured",
      "2026-04-26T10:01:00Z",
    ),
    ev(
      30,
      "Resize Model (Shrink)",
      "shrink",
      "stage_succeeded",
      "Shrunk OK",
      "2026-04-26T10:02:00Z",
    ),
    ev(
      40,
      "Vibe Session",
      "Session Ended",
      "stage_ended",
      "Pipeline completed",
      "2026-04-26T10:03:00Z",
    ),
  ],
  // Phase with no Vibe Session events at all (legacy or partial flush).
  "no-vibe-session": [
    ev(
      20,
      "Setup and Configuration",
      "init",
      "stage_succeeded",
      "Configured",
      "2026-04-26T10:01:00Z",
    ),
    ev(
      30,
      "Resize Model (Shrink)",
      "shrink",
      "stage_succeeded",
      "Shrunk OK",
      "2026-04-26T10:02:00Z",
    ),
  ],
  // Only a Session Started — no Session Ended (process died).
  "session-started-only": [
    ev(
      10,
      "Vibe Session",
      "Session Started",
      "stage_started",
      "Session started",
      "2026-04-26T10:00:30Z",
    ),
    ev(
      20,
      "Setup and Configuration",
      "init",
      "stage_succeeded",
      "Configured",
      "2026-04-26T10:01:00Z",
    ),
  ],
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
  // Import lazily so the mock above is in place first.
  const { RunHierarchyPipeline } = await import(
    "@/components/runs/run-hierarchy-pipeline"
  );

  useListMock = () => ({ data: { data: ops }, isLoading: false });

  const result = render(
    withProviders(<RunHierarchyPipeline businessId="biz-1"
          runId={runId} progressPercent={50} />),
  );
  await screen.findByTestId("run-hierarchy-pipeline");
  return result;
}

/**
 * Expand the phase row so its sub-step list / brackets render.
 *
 * Failed/succeeded phases default-collapse; running ones default-expand.
 * For tests that care about rendered sub-steps (#1, #2), expand explicitly.
 */
function expandPhase(opName: string) {
  const header = screen.getByText(new RegExp(`Phase \\d+ — ${opName}`, "i"));
  fireEvent.click(header);
}

// ---------------------------------------------------------------------------
// 1. Failed phase — error text under bottom bracket, no peer Vibe Session row
// ---------------------------------------------------------------------------

describe("Vibe Session bracket — failed phase", () => {
  it("does not render Vibe Session as a peer sub-step row", async () => {
    const ops = [makeOp(0, "shrink_to_mvm", "failed")];
    await renderHierarchy("failed-phase", ops);
    expandPhase("shrink_to_mvm");

    // Whatever the impl renders for sub-steps, none of them should be
    // labelled with the agent's stage_name "Vibe Session". The brackets
    // themselves are NOT sub-step rows — they live above/below the list —
    // so a step row containing literal "Vibe Session" would be a
    // regression of the bracket extraction.
    const stepRows = screen.queryAllByTestId(/^step-row/);
    for (const row of stepRows) {
      expect(row.textContent ?? "").not.toMatch(/Vibe Session/);
    }
  });

  it("does not render a sub-step row containing the Session Ended message", async () => {
    // The error text must appear ONLY under the bracket, not as a peer
    // step row's summary (the old buggy behavior).
    const ops = [makeOp(0, "shrink_to_mvm", "failed")];
    await renderHierarchy("failed-phase", ops);
    expandPhase("shrink_to_mvm");

    const stepRows = screen.queryAllByTestId(/^step-row/);
    for (const row of stepRows) {
      expect(row.textContent ?? "").not.toMatch(/SHRINK-NEW-SILO/);
    }
  });

  it("renders the Session Ended error message under the (bottom) bracket", async () => {
    const ops = [makeOp(0, "shrink_to_mvm", "failed")];
    await renderHierarchy("failed-phase", ops);
    expandPhase("shrink_to_mvm");

    // The error text must be visible somewhere in the rendered tree —
    // it's the whole point of showing the bracket.
    expect(screen.getByText(/SHRINK-NEW-SILO/)).toBeInTheDocument();
  });

  it("bottom bracket has failure styling when parent op.status === 'failed'", async () => {
    const ops = [makeOp(0, "shrink_to_mvm", "failed")];
    await renderHierarchy("failed-phase", ops);
    expandPhase("shrink_to_mvm");

    // Look for an end-bracket element. Attempt several reasonable
    // testids since the impl wasn't read; if none matches we fall
    // back to checking by aria-label / role.
    const candidates = [
      "vibe-session-end-bracket",
      "vibe-session-end",
      "session-end-bracket",
    ];
    let endEl: HTMLElement | null = null;
    for (const id of candidates) {
      const found = screen.queryByTestId(id);
      if (found) {
        endEl = found;
        break;
      }
    }
    if (!endEl) {
      // Fall back: any element whose accessible label mentions "session" + "end"
      // or whose visible text contains the error message.
      const errorNode = screen.getByText(/SHRINK-NEW-SILO/);
      // The bracket container is an ancestor — walk up until we find one
      // that has class / data signal of "fail".
      let cursor: HTMLElement | null = errorNode;
      while (cursor && cursor !== document.body) {
        const cls = cursor.className?.toString() ?? "";
        const aria = cursor.getAttribute("aria-label") ?? "";
        const dataState = cursor.getAttribute("data-state") ?? "";
        if (
          /fail|red|destructive|error/.test(cls) ||
          /fail|error/i.test(aria) ||
          /fail|error/i.test(dataState)
        ) {
          endEl = cursor;
          break;
        }
        cursor = cursor.parentElement;
      }
    }

    expect(endEl).not.toBeNull();
    if (endEl) {
      const cls = endEl.className?.toString() ?? "";
      const aria = endEl.getAttribute("aria-label") ?? "";
      const dataState = endEl.getAttribute("data-state") ?? "";
      const failSignals =
        /fail|red|destructive|error/i.test(cls) ||
        /fail|error/i.test(aria) ||
        /fail|error/i.test(dataState);
      expect(failSignals).toBe(true);
    }
  });
});

// ---------------------------------------------------------------------------
// 2. Successful phase — bracket has success styling, summary visible
// ---------------------------------------------------------------------------

describe("Vibe Session bracket — succeeded phase", () => {
  it("renders the success summary message under the bottom bracket", async () => {
    const ops = [makeOp(0, "generate_ecm", "succeeded")];
    await renderHierarchy("succeeded-phase", ops);
    expandPhase("generate_ecm");

    expect(screen.getByText(/Pipeline completed/)).toBeInTheDocument();
  });

  it("does not render Vibe Session as a peer sub-step row", async () => {
    const ops = [makeOp(0, "generate_ecm", "succeeded")];
    await renderHierarchy("succeeded-phase", ops);
    expandPhase("generate_ecm");

    const stepRows = screen.queryAllByTestId(/^step-row/);
    for (const row of stepRows) {
      expect(row.textContent ?? "").not.toMatch(/Vibe Session/);
    }
  });

  it("bottom bracket carries success signals (NOT failure) when op.status === 'succeeded'", async () => {
    const ops = [makeOp(0, "generate_ecm", "succeeded")];
    await renderHierarchy("succeeded-phase", ops);
    expandPhase("generate_ecm");

    // Walk up from the success message text and assert the bracket
    // container does NOT carry failure-styling signals.
    const summaryNode = screen.getByText(/Pipeline completed/);
    let cursor: HTMLElement | null = summaryNode;
    let bracketContainer: HTMLElement | null = null;
    while (cursor && cursor !== document.body) {
      const cls = cursor.className?.toString() ?? "";
      const aria = cursor.getAttribute("aria-label") ?? "";
      const role = cursor.getAttribute("role") ?? "";
      if (
        /success|green|ok|complete/i.test(cls) ||
        /success|complete/i.test(aria) ||
        role === "status"
      ) {
        bracketContainer = cursor;
        break;
      }
      cursor = cursor.parentElement;
    }

    if (bracketContainer) {
      const cls = bracketContainer.className?.toString() ?? "";
      const aria = bracketContainer.getAttribute("aria-label") ?? "";
      expect(/destructive|red|fail|error/i.test(cls)).toBe(false);
      expect(/fail|error/i.test(aria)).toBe(false);
    }
    // If we couldn't pin down a "success" container, at minimum the
    // failure signal must NOT appear next to the success summary.
    const html = summaryNode.parentElement?.outerHTML ?? "";
    expect(/destructive/i.test(html)).toBe(false);
  });
});

// ---------------------------------------------------------------------------
// 3. Edge — phase with NO Vibe Session events at all
// ---------------------------------------------------------------------------

describe("Vibe Session bracket — no Vibe Session events (legacy)", () => {
  it("renders without crashing and shows the regular sub-steps", async () => {
    const ops = [makeOp(0, "generate_ecm", "succeeded")];
    await renderHierarchy("no-vibe-session", ops);
    // Expand to surface sub-steps.
    expandPhase("generate_ecm");

    // Sub-steps should appear in their natural order. We don't have
    // strong cross-row ordering hooks, but their messages should both
    // be present.
    expect(screen.getByText(/Configured/)).toBeInTheDocument();
    expect(screen.getByText(/Shrunk OK/)).toBeInTheDocument();
  });

  it("does not render a Session Ended bracket message that wasn't in the events", async () => {
    const ops = [makeOp(0, "generate_ecm", "succeeded")];
    await renderHierarchy("no-vibe-session", ops);
    expandPhase("generate_ecm");

    expect(screen.queryByText(/Pipeline completed/)).not.toBeInTheDocument();
    expect(screen.queryByText(/SHRINK-NEW-SILO/)).not.toBeInTheDocument();
  });
});

// ---------------------------------------------------------------------------
// 4. Edge — only Session Started, no Session Ended (process died)
// ---------------------------------------------------------------------------

describe("Vibe Session bracket — start only (no end yet)", () => {
  it("does not crash when only the Session Started event is present", async () => {
    const ops = [makeOp(0, "generate_ecm", "running")];
    // The first assertion is just that the suspense boundary resolves
    // without throwing.
    await renderHierarchy("session-started-only", ops);
    expect(screen.getByTestId("run-hierarchy-pipeline")).toBeInTheDocument();
  });

  it("does not surface a phantom Session Ended message", async () => {
    const ops = [makeOp(0, "generate_ecm", "running")];
    await renderHierarchy("session-started-only", ops);
    // Running phase default-expands so we don't need to click.
    expect(screen.queryByText(/SHRINK-NEW-SILO/)).not.toBeInTheDocument();
    expect(screen.queryByText(/Pipeline completed/)).not.toBeInTheDocument();
  });

  it("does not render a peer sub-step row labelled Vibe Session", async () => {
    const ops = [makeOp(0, "generate_ecm", "running")];
    await renderHierarchy("session-started-only", ops);
    const stepRows = screen.queryAllByTestId(/^step-row/);
    for (const row of stepRows) {
      // Even when only the start event exists, the filter should hold.
      expect(row.textContent ?? "").not.toMatch(/Vibe Session/);
    }
  });
});

// ---------------------------------------------------------------------------
// 5. extractVibeSessionBrackets helper — exported, so it's fair game.
// ---------------------------------------------------------------------------

describe("extractVibeSessionBrackets — pure helper", () => {
  it("returns both ends when both events are present", async () => {
    const { extractVibeSessionBrackets } = await import(
      "@/components/runs/run-hierarchy-pipeline"
    );
    const events = FETCH_FIXTURES["failed-phase"]!;
    const out = extractVibeSessionBrackets(events) as unknown as {
      start?: unknown;
      end?: unknown;
    };
    expect(out).toBeTruthy();
    // Whatever shape the result has, it must mention both ends in some
    // form. We don't lock the property names here — but if neither
    // contains "start"/"end" or similar, the helper is broken.
    const json = JSON.stringify(out ?? {}).toLowerCase();
    expect(json.includes("session started") || json.includes("start")).toBe(true);
    expect(
      json.includes("session ended") ||
        json.includes("end") ||
        json.includes("[valueerror]"),
    ).toBe(true);
  });

  it("returns no end when only Session Started is present", async () => {
    const { extractVibeSessionBrackets } = await import(
      "@/components/runs/run-hierarchy-pipeline"
    );
    const events = FETCH_FIXTURES["session-started-only"]!;
    const out = extractVibeSessionBrackets(events) as unknown as Record<
      string,
      unknown
    >;
    // We only assert that the helper returned without throwing AND that
    // the terminal-event message text is NOT in the serialized output
    // (because there isn't one).
    const json = JSON.stringify(out ?? {});
    expect(json).not.toMatch(/Pipeline completed/);
    expect(json).not.toMatch(/SHRINK-NEW-SILO/);
  });

  it("handles events with no Vibe Session entries at all", async () => {
    const { extractVibeSessionBrackets } = await import(
      "@/components/runs/run-hierarchy-pipeline"
    );
    const events = FETCH_FIXTURES["no-vibe-session"]!;
    // Must not throw.
    const out = extractVibeSessionBrackets(events);
    expect(out).toBeDefined();
  });
});
