import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, screen, waitFor } from "@testing-library/react";

vi.mock("sonner", () => ({
  toast: {
    success: vi.fn(),
    error: vi.fn(),
  },
}));

const mockedNotifyError = vi.fn();
vi.mock("@/lib/notify", () => ({
  notifyError: (...args: unknown[]) => mockedNotifyError(...args),
}));

vi.mock("@/lib/api", async () => {
  const actual =
    await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    cancelRunWithRollback: vi.fn(),
    retryRun: vi.fn(),
    resumeRun: vi.fn(),
  };
});

import {
  cancelRunWithRollback,
  resumeRun,
  retryRun,
  type RunOut,
} from "@/lib/api";
import { toast } from "sonner";
import { RunDetail } from "@/routes/_sidebar/businesses.$businessId.runs.$runId";
import { renderWithRouter } from "./helpers/router-wrapper";

const mockedCancelRollback = vi.mocked(cancelRunWithRollback);
const mockedResume = vi.mocked(resumeRun);
const mockedRetry = vi.mocked(retryRun);
const mockedToastError = vi.mocked(toast.error);

type FetchMock = ReturnType<typeof vi.fn>;

// Stub every fetch call the page might make. `useGetRunSuspense` hits
// `/api/runs/{id}` and expects a RunOut envelope; the LineageCard hits
// `/api/runs/{id}/lineage` (operates-on), `/api/runs/{id}/operations`
// (source/generated derivation — the model-versioning work #52), and
// `/api/businesses/{id}/versions` (id → (version, scope) lookup); the
// ProgressPipeline hits `/api/runs/{id}/progress`; ArtifactsTab pulls
// `/api/runs/{id}/artifacts`. Route based on URL path so one stub
// covers them all.
function stubAllFetch(run: RunOut): FetchMock {
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
    if (u.includes("/operations")) {
      return { ok: true, status: 200, json: async () => [] };
    }
    if (u.includes("/progress")) {
      return { ok: true, status: 200, json: async () => [] };
    }
    if (u.includes("/businesses/") && u.includes("/versions")) {
      return { ok: true, status: 200, json: async () => [] };
    }
    // Default: /api/runs/{id}
    return { ok: true, status: 200, json: async () => run };
  }) as FetchMock;
  vi.stubGlobal("fetch", fn);
  return fn;
}

function makeRun(overrides: Partial<RunOut> = {}): RunOut {
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
    parameters_json: JSON.stringify({
      operation: "new base model",
      ecm_mvm_unified: true,
      ecm_mvm_phase: "ecm",
    }),
    vibe_instructions_text: "",
    vibe_instructions_volume_path: "",
    started_at: "2026-04-20T12:00:00Z",
    completed_at: null,
    created_at: "2026-04-20T11:59:00Z",
    ...overrides,
  };
}

describe("RunDetail — Resume button visibility", () => {
  beforeEach(() => {
    vi.unstubAllGlobals();
    mockedCancelRollback.mockReset();
    mockedResume.mockReset();
  });
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it("hides Resume when the run is running", async () => {
    stubAllFetch(makeRun({ status: "running" }));
    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);
    await waitFor(() =>
      expect(screen.getByText(/Run:/i)).toBeInTheDocument(),
    );
    expect(screen.queryByRole("button", { name: /Resume/ })).not.toBeInTheDocument();
  });

  it("hides Resume for a non-unified failed run", async () => {
    stubAllFetch(
      makeRun({
        status: "failed",
        parameters_json: JSON.stringify({ operation: "new base model" }),
      }),
    );
    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);
    await waitFor(() =>
      expect(screen.getByText(/Run:/i)).toBeInTheDocument(),
    );
    expect(screen.queryByRole("button", { name: /Resume/ })).not.toBeInTheDocument();
  });

  it("shows Resume on a unified failed run", async () => {
    stubAllFetch(makeRun({ status: "failed" }));
    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    await waitFor(() =>
      expect(
        screen.getByRole("button", { name: /Resume/ }),
      ).toBeInTheDocument(),
    );
  });

  it("shows Resume on a unified stale run", async () => {
    stubAllFetch(makeRun({ status: "stale" }));
    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    await waitFor(() =>
      expect(
        screen.getByRole("button", { name: /Resume/ }),
      ).toBeInTheDocument(),
    );
  });

  it("fires resumeRun on dialog confirm", async () => {
    mockedResume.mockResolvedValue({
      data: { ok: true, next_phase: "mvm", status: "running" },
    } as Awaited<ReturnType<typeof resumeRun>>);
    stubAllFetch(makeRun({ status: "failed" }));

    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);
    const resume = await screen.findByRole("button", { name: /Resume/ });

    await act(async () => {
      fireEvent.click(resume);
    });

    // Dialog confirmation
    const confirm = await screen.findByRole("button", { name: /^Resume$/ });
    await act(async () => {
      fireEvent.click(confirm);
    });

    await waitFor(() => {
      expect(mockedResume).toHaveBeenCalledWith({ business_id: "biz-1", run_id: "run-1" });
    });
  });
});

describe("RunDetail — Cancel dialog", () => {
  beforeEach(() => {
    vi.unstubAllGlobals();
    mockedCancelRollback.mockReset();
  });
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it("renders the single rollback-by-default cancel button on any running run", async () => {
    // v0.4.0 update: the dialog no longer offers a "Just cancel"
    // variant — every cancel now rolls back partial state per
    // feedback_state_atomicity + v0.4.0 #2b's uniform rollback fix.
    stubAllFetch(makeRun({ status: "running" }));

    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    const cancelToolbar = await screen.findByRole("button", { name: /^Cancel$/ });
    await act(async () => {
      fireEvent.click(cancelToolbar);
    });

    // Single confirm button + the warning copy reflects the new behaviour.
    await waitFor(() =>
      expect(
        screen.getByText(/Any partial work will be rolled back, and the run marked as canceled\./i),
      ).toBeInTheDocument(),
    );
    expect(screen.getByRole("button", { name: /Cancel run/ })).toBeInTheDocument();
    expect(
      screen.queryByRole("button", { name: /just cancel/i }),
    ).not.toBeInTheDocument();
    expect(
      screen.queryByRole("button", { name: /roll back partial state/i }),
    ).not.toBeInTheDocument();
  });

  // an internal tracker item — pre-fix the dialog said "Any partial work
  // will NOT be rolled back" which contradicted v0.4.0 #2b's behaviour
  // (cancel does in fact roll back). A loose `/will be rolled back/i`
  // regex matches the substring inside "will not be rolled back" too, so
  // the existing positive assertion alone wouldn't guard against
  // re-regression. Pin both the positive ("will be rolled back") AND
  // negative ("will not be rolled back") strings explicitly.
  it("dialog copy does NOT claim partial work will not be rolled back", async () => {
    stubAllFetch(makeRun({ status: "running" }));

    renderWithRouter(<RunDetail businessId="biz-1" runId="run-1" />);
    const cancelToolbar = await screen.findByRole("button", { name: /^Cancel$/ });
    await act(async () => {
      fireEvent.click(cancelToolbar);
    });

    await waitFor(() =>
      expect(screen.getByText(/Cancel run\?/i)).toBeInTheDocument(),
    );

    // Read the description body's textContent so we can make an exact-
    // substring assertion that doesn't accidentally match the negation form.
    const desc = screen.getByText(
      /Any partial work will be rolled back, and the run marked as canceled\./i,
    );
    const body = desc.textContent ?? "";
    expect(body).toContain("will be rolled back");
    expect(body).not.toMatch(/will not be rolled back/i);
    expect(body).not.toMatch(/won['’]t be rolled back/i);
  });

  it("calls cancelRunWithRollback when the confirm button is clicked", async () => {
    mockedCancelRollback.mockResolvedValue({
      data: { ok: true, status: "cancelled", ops_applied: [{ kind: "delete_model_version" }] },
    } as Awaited<ReturnType<typeof cancelRunWithRollback>>);
    stubAllFetch(makeRun({ status: "running" }));

    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    const cancelToolbar = await screen.findByRole("button", { name: /^Cancel$/ });
    await act(async () => {
      fireEvent.click(cancelToolbar);
    });

    const confirm = await screen.findByRole("button", { name: /^Cancel run$/ });
    await act(async () => {
      fireEvent.click(confirm);
    });

    await waitFor(() => {
      expect(mockedCancelRollback).toHaveBeenCalledWith({ business_id: "biz-1", run_id: "run-1" });
    });
  });
});

describe("RunDetail — Mutation error paths", () => {
  beforeEach(() => {
    vi.unstubAllGlobals();
    mockedCancelRollback.mockReset();
    mockedResume.mockReset();
    mockedRetry.mockReset();
    mockedToastError.mockReset();
    mockedNotifyError.mockReset();
  });
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it("fires toast.error and re-enables the cancel button when cancelRunWithRollback returns an error", async () => {
    // v0.4.0 update: single cancel path → cancelRunWithRollback is the
    // only path. 4xx and 5xx both surface as toast.error with the
    // server message; the toolbar Cancel button re-enables via the
    // `finally` block.
    const rollbackErr = new Error("Rollback step crashed: delete_volume");
    mockedCancelRollback.mockRejectedValue(rollbackErr);
    stubAllFetch(makeRun({ status: "running" }));

    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    const cancelToolbar = await screen.findByRole("button", { name: /^Cancel$/ });
    await act(async () => {
      fireEvent.click(cancelToolbar);
    });

    const confirm = await screen.findByRole("button", { name: /^Cancel run$/ });
    await act(async () => {
      fireEvent.click(confirm);
    });

    await waitFor(() => {
      expect(mockedNotifyError).toHaveBeenCalledWith(
        rollbackErr,
        { title: "Cancel-with-rollback failed" },
      );
    });
    expect(mockedToastError).not.toHaveBeenCalled();

    // Cancel button must be back to enabled.
    await waitFor(() => {
      const cancelAfter = screen.getByRole("button", { name: /^Cancel$/ });
      expect(cancelAfter).not.toBeDisabled();
    });
  });

  it("fires toast.error and re-enables Resume when resumeRun returns 500", async () => {
    const resumeErr = new Error("Dispatcher unavailable");
    mockedResume.mockRejectedValue(resumeErr);
    stubAllFetch(makeRun({ status: "failed" }));

    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    const resume = await screen.findByRole("button", { name: /Resume/ });
    await act(async () => {
      fireEvent.click(resume);
    });

    // Click the dialog's confirm button.
    const confirm = await screen.findByRole("button", { name: /^Resume$/ });
    await act(async () => {
      fireEvent.click(confirm);
    });

    await waitFor(() => {
      expect(mockedNotifyError).toHaveBeenCalledWith(
        resumeErr,
        expect.objectContaining({ fallback: expect.stringMatching(/resume/i) }),
      );
    });
    expect(mockedToastError).not.toHaveBeenCalled();

    // Toolbar Resume button is re-enabled.
    await waitFor(() => {
      const resumeAfter = screen.getByRole("button", { name: /Resume/ });
      expect(resumeAfter).not.toBeDisabled();
    });
  });

  it("re-enables Retry when retryRun returns 422 (validation failed)", async () => {
    // After the silent-error fix, `handleRetry` now wraps `retryRun` in a
    // try/catch. The rejection no longer escapes as an unhandledrejection;
    // it produces a `toast.error(...)` call. Test asserts the new behavior.
    const validationErr = new Error("Validation failed: catalog missing");
    Object.assign(validationErr, { status: 422 });
    mockedRetry.mockRejectedValue(validationErr);
    // The Retry button is only shown for failed/cancelled runs.
    stubAllFetch(
      makeRun({
        status: "failed",
        parameters_json: JSON.stringify({ operation: "new base model" }),
      }),
    );

    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    const retry = await screen.findByRole("button", { name: /Retry/ });
    await act(async () => {
      fireEvent.click(retry);
    });

    // The mutation must have been invoked.
    await waitFor(() => {
      expect(mockedRetry).toHaveBeenCalledWith({ business_id: "biz-1", run_id: "run-1" });
    });

    // notifyError fires with the error and a "Retry failed" title.
    await waitFor(() => {
      expect(mockedNotifyError).toHaveBeenCalledWith(
        validationErr,
        { title: "Retry failed" },
      );
    });
    expect(mockedToastError).not.toHaveBeenCalled();

    // Retry button re-enabled (acting flag flipped off in finally).
    const retryAfter = screen.getByRole("button", { name: /Retry/ });
    expect(retryAfter).not.toBeDisabled();
  });
});
