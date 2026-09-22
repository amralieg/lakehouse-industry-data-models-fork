/**
 * Adversarial tests for the D-09 user-visible watchdog UI (#51).
 *
 * The run progress card must surface:
 * - A Cancel button enabled while the run is `running` or `stale`,
 *   hidden / disabled once the run is in any terminal state. Clicking
 *   it must POST `/api/runs/{id}/cancel` (NOT `/cancel-with-rollback`).
 * - A state pill rendering one of: "Warming up", "Active", "Stale",
 *   "Failed", "Done".
 * - The `last_poll_error` string in a visible (red) element when the
 *   field is non-empty; absent when it is the empty string.
 * - An elapsed-time counter formatted as MM:SS or HH:MM:SS depending
 *   on `elapsed_seconds`.
 *
 * Each test is a focused failure case. The component is rendered at
 * its public boundary (`RunDetail`) so we assert outputs (DOM /
 * fetched URL) rather than internal calls.
 */

import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, screen, waitFor } from "@testing-library/react";

vi.mock("sonner", () => ({
  toast: {
    success: vi.fn(),
    error: vi.fn(),
  },
}));

vi.mock("@/lib/api", async () => {
  const actual =
    await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    cancelRun: vi.fn(),
    cancelRunWithRollback: vi.fn(),
    retryRun: vi.fn(),
    resumeUnifiedRun: vi.fn(),
  };
});

import {
  cancelRun,
  cancelRunWithRollback,
  type RunOut,
} from "@/lib/api";
import { RunDetail } from "@/routes/_sidebar/businesses.$businessId.runs.$runId";
import { renderWithRouter } from "./helpers/router-wrapper";

const mockedCancel = vi.mocked(cancelRun);
const mockedCancelRollback = vi.mocked(cancelRunWithRollback);

type FetchMock = ReturnType<typeof vi.fn>;

interface WatchdogFields {
  watchdog_state?: string;
  watchdog_warm_up_seconds_remaining?: number;
  last_jobs_api_state?: string;
  last_poll_error?: string;
  elapsed_seconds?: number;
}

// Stub every fetch call the page might make so the page hydrates with
// our `RunOut + watchdog signals` envelope. The same pattern as
// run-detail.test.tsx.
function stubAllFetch(run: RunOut & WatchdogFields): FetchMock {
  const fn = vi.fn(async (url: RequestInfo) => {
    const u = String(url);
    if (u.includes("/lineage")) {
      return {
        ok: true,
        status: 200,
        json: async () => ({
          run_id: run.id,
          intent: run.intent,
          business_id: run.business_id,
          source_version: null,
          generated_version: null,
          operates_on_version: null,
        }),
      };
    }
    if (u.includes("/artifacts")) {
      return { ok: true, status: 200, json: async () => [] };
    }
    if (u.includes("/progress")) {
      return { ok: true, status: 200, json: async () => [] };
    }
    // the model-versioning work #52: LineageCard now reads RunOperation rows + the
    // versions list to derive Source/Generated. Both endpoints must
    // resolve to an iterable (`[]`) so the page hydrates without a
    // "object is not iterable" render error.
    if (u.includes("/operations")) {
      return { ok: true, status: 200, json: async () => [] };
    }
    if (u.includes("/businesses/") && u.includes("/versions")) {
      return { ok: true, status: 200, json: async () => [] };
    }
    return { ok: true, status: 200, json: async () => run };
  }) as FetchMock;
  vi.stubGlobal("fetch", fn);
  return fn;
}

function makeRun(
  overrides: Partial<RunOut & WatchdogFields> = {},
): RunOut & WatchdogFields {
  return {
    id: "run-1",
    business_id: "biz-1",
    version_id: null,
    intent: "new-base-model",
    status: "running",
    databricks_run_id: 42,
    vibe_session_id: null,
    run_page_url: null,
    progress_percent: 30,
    progress_message: "Working...",
    error_message: "",
    parameters_json: JSON.stringify({ operation: "new base model" }),
    vibe_instructions_text: "",
    vibe_instructions_volume_path: "",
    started_at: "2026-04-25T11:30:00Z",
    completed_at: null,
    created_at: "2026-04-25T11:29:00Z",
    // Watchdog signals — defaults represent a healthy "armed and active"
    // run so individual tests can override only the field they care about.
    watchdog_state: "armed",
    watchdog_warm_up_seconds_remaining: 0,
    last_jobs_api_state: "RUNNING/",
    last_poll_error: "",
    elapsed_seconds: 65,
    ...overrides,
  };
}

// State-pill labels expected on the rendered card. The contract names
// 5 distinct user-facing labels — these are the strings the UI must
// surface (case-insensitive). Tests use this as the assertion alphabet.
//
// We deliberately use `\b`-anchored matches so the pill assertion fails
// when a test case finds only the existing run-status badge (which
// contains the lowercase enum name like "stale" / "failed" but never
// the user-facing label "Stale" / "Failed" with this exact case at the
// pill location).
const PILL_LABELS: Record<string, RegExp> = {
  warming_up: /\bWarming up\b/,
  armed: /\bActive\b/,
  tripped_stale: /\bStale\b/,
  tripped_failed: /\bFailed\b/,
  disarmed: /\bDone\b/,
};


// ---------------------------------------------------------------------------
// 1. Cancel button availability
// ---------------------------------------------------------------------------

describe("Watchdog signals — Cancel button availability", () => {
  beforeEach(() => {
    vi.unstubAllGlobals();
    mockedCancel.mockReset();
    mockedCancelRollback.mockReset();
  });
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it("renders an enabled Cancel button when the run is running", async () => {
    stubAllFetch(makeRun({ status: "running" }));
    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    const btn = await screen.findByRole("button", { name: /^Cancel$/ });
    expect(btn).toBeInTheDocument();
    expect(btn).not.toBeDisabled();
  });

  it("renders an enabled Cancel button when the run is stale", async () => {
    stubAllFetch(
      makeRun({ status: "stale", watchdog_state: "tripped_stale" }),
    );
    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    const btn = await screen.findByRole("button", { name: /^Cancel$/ });
    expect(btn).toBeInTheDocument();
    expect(btn).not.toBeDisabled();
  });

  it("does not render a Cancel button on a completed run", async () => {
    stubAllFetch(
      makeRun({
        status: "completed",
        watchdog_state: "disarmed",
        completed_at: "2026-04-25T11:45:00Z",
      }),
    );
    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    // Wait for the page to hydrate before asserting absence.
    await waitFor(() =>
      expect(screen.getByText(/Run:/i)).toBeInTheDocument(),
    );
    expect(
      screen.queryByRole("button", { name: /^Cancel$/ }),
    ).not.toBeInTheDocument();
  });
});


// ---------------------------------------------------------------------------
// 2. Cancel click hits POST /api/runs/{id}/cancel (not cancel-with-rollback)
// ---------------------------------------------------------------------------

describe("Watchdog signals — Cancel click endpoint", () => {
  beforeEach(() => {
    vi.unstubAllGlobals();
    mockedCancel.mockReset();
    mockedCancelRollback.mockReset();
  });
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it("clicking Cancel triggers cancelRunWithRollback (single-path cancel as of v0.4.0)", async () => {
    // v0.4.0 update: the two-button cancel dialog was retired in favour
    // of a single rollback-by-default action. Every Cancel click now
    // routes through POST /runs/{id}/cancel-with-rollback, which v0.4.0
    // #2b made uniformly reliable across cataloging styles.
    mockedCancelRollback.mockResolvedValue({
      data: { ok: true, status: "cancelled", ops_applied: [] },
    } as unknown as Awaited<ReturnType<typeof cancelRunWithRollback>>);

    stubAllFetch(
      makeRun({
        status: "running",
        parameters_json: JSON.stringify({ operation: "new base model" }),
      }),
    );

    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    const cancelBtn = await screen.findByRole("button", { name: /^Cancel$/ });
    await act(async () => {
      fireEvent.click(cancelBtn);
    });

    const confirm = await screen.findByRole("button", { name: /^Cancel run$/ });
    await act(async () => {
      fireEvent.click(confirm);
    });

    await waitFor(() => {
      expect(mockedCancelRollback).toHaveBeenCalledTimes(1);
    });
    expect(mockedCancelRollback).toHaveBeenCalledWith({ business_id: "biz-1", run_id: "run-1" });
    expect(mockedCancel).not.toHaveBeenCalled();
  });
});


// ---------------------------------------------------------------------------
// 3. State pill renders all 5 watchdog states
// ---------------------------------------------------------------------------

describe("Watchdog signals — state pill labels", () => {
  beforeEach(() => {
    vi.unstubAllGlobals();
    mockedCancel.mockReset();
    mockedCancelRollback.mockReset();
  });
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it.each([
    ["warming_up", "running", "warming_up"],
    ["armed", "running", "armed"],
    ["tripped_stale", "stale", "tripped_stale"],
    ["tripped_failed", "failed", "tripped_failed"],
    ["disarmed", "completed", "disarmed"],
  ])(
    "renders a recognisable label for watchdog_state=%s (run.status=%s)",
    async (_caseName, runStatus, watchdogState) => {
      stubAllFetch(
        makeRun({
          status: runStatus as RunOut["status"],
          watchdog_state: watchdogState as RunOut["watchdog_state"],
          completed_at:
            runStatus === "completed" ? "2026-04-25T11:45:00Z" : null,
          watchdog_warm_up_seconds_remaining:
            watchdogState === "warming_up" ? 60 : 0,
        }),
      );

      renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

      // Wait for hydration.
      await waitFor(() =>
        expect(screen.getByText(/Run:/i)).toBeInTheDocument(),
      );

      const re = PILL_LABELS[watchdogState];
      // findAllByText to avoid failing on duplicates (status badge +
      // watchdog pill may both render related text). The point is at
      // least one element on the page surfaces the watchdog state.
      const matches = await screen.findAllByText(re);
      expect(matches.length).toBeGreaterThan(0);
    },
  );
});


// ---------------------------------------------------------------------------
// 4. last_poll_error rendering
// ---------------------------------------------------------------------------

describe("Watchdog signals — last_poll_error rendering", () => {
  beforeEach(() => {
    vi.unstubAllGlobals();
    mockedCancel.mockReset();
  });
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it("renders a visible error string when last_poll_error is non-empty", async () => {
    const ERR = "conn refused (probe-12345)";
    stubAllFetch(
      makeRun({
        status: "running",
        watchdog_state: "armed",
        last_poll_error: ERR,
      }),
    );

    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    // ERR contains regex metacharacters (parens) so we use a function
    // matcher rather than `new RegExp(ERR)`.
    const errEl = await screen.findByText((content) => content.includes(ERR));
    expect(errEl).toBeVisible();
  });

  it("does not render last_poll_error text when the field is empty", async () => {
    const ERR = "conn refused (probe-99999)";
    stubAllFetch(
      makeRun({
        status: "running",
        watchdog_state: "armed",
        last_poll_error: "",
      }),
    );

    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    await waitFor(() =>
      expect(screen.getByText(/Run:/i)).toBeInTheDocument(),
    );
    expect(
      screen.queryByText((content) => content.includes(ERR)),
    ).not.toBeInTheDocument();
  });
});


// ---------------------------------------------------------------------------
// 5. Elapsed-time formatting
// ---------------------------------------------------------------------------

describe("Watchdog signals — elapsed_seconds formatting", () => {
  beforeEach(() => {
    vi.unstubAllGlobals();
    mockedCancel.mockReset();
  });
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it("renders 65 seconds as MM:SS = '01:05'", async () => {
    stubAllFetch(
      makeRun({
        status: "running",
        watchdog_state: "armed",
        elapsed_seconds: 65,
      }),
    );

    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    // Match the formatted string anywhere on the page. The label is
    // either "01:05" alone or wrapped (e.g. "Elapsed 01:05") — a
    // regex tolerant of surrounding text catches both.
    const el = await screen.findByText(/\b01:05\b/);
    expect(el).toBeVisible();
  });

  it("renders 3700 seconds as HH:MM:SS = '01:01:40'", async () => {
    stubAllFetch(
      makeRun({
        status: "running",
        watchdog_state: "armed",
        elapsed_seconds: 3700,
      }),
    );

    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    const el = await screen.findByText(/\b01:01:40\b/);
    expect(el).toBeVisible();
  });
});
