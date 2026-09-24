/**
 * Tests that the "Version resolution" info note renders inside
 * WhatYouSubmitted when the run carries one or more
 * ``version_resolutions`` entries with ``original_target !== new_target``,
 * and that it does NOT render on the happy path (no resolutions, or
 * resolutions with equal original/new — which the backend already filters
 * but we defend against client-side too).
 */

import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";

import { WhatYouSubmitted } from "@/components/runs/what-you-submitted";
import type { RunOut } from "@/lib/api";

function baseRun(overrides: Partial<RunOut> = {}): RunOut {
  return {
    id: "r1",
    business_id: "b1",
    business_context_text: "",
    completed_at: null,
    created_at: "2026-05-18T00:00:00Z",
    databricks_run_id: 42,
    elapsed_seconds: 0,
    error_message: "",
    intent: "new-base-model",
    last_jobs_api_state: "",
    last_poll_error: "",
    parameters_json: "{}",
    progress_message: "",
    progress_percent: 0,
    run_page_url: null,
    started_at: null,
    status: "completed" as RunOut["status"],
    version_id: null,
    vibe_instructions_text: "",
    vibe_instructions_volume_path: "",
    vibe_session_id: null,
    warnings: [],
    watchdog_state: "disarmed" as RunOut["watchdog_state"],
    watchdog_warm_up_seconds_remaining: 0,
    version_resolutions: [],
    ...overrides,
  };
}

describe("WhatYouSubmitted — version resolution surface", () => {
  it("renders the requested→resolved line when fields differ", () => {
    const run = baseRun({
      version_resolutions: [
        { target_scope: "mvm", original_target: 1, new_target: 3 },
      ],
    });
    render(<WhatYouSubmitted run={run} />);
    const banner = screen.getByTestId("version-resolutions");
    expect(banner).toBeTruthy();
    expect(banner.textContent).toMatch(/Requested MVM v1/);
    expect(banner.textContent).toMatch(/Agent resolved to v3/);
    expect(banner.textContent).toMatch(/auto-collision-resolved/);
  });

  it("renders one entry per resolved scope", () => {
    const run = baseRun({
      version_resolutions: [
        { target_scope: "ecm", original_target: 2, new_target: 4 },
        { target_scope: "mvm", original_target: 2, new_target: 4 },
      ],
    });
    render(<WhatYouSubmitted run={run} />);
    const banner = screen.getByTestId("version-resolutions");
    expect(banner.textContent).toMatch(/Requested ECM v2/);
    expect(banner.textContent).toMatch(/Requested MVM v2/);
  });

  it("does NOT render the banner when version_resolutions is empty", () => {
    const run = baseRun({ version_resolutions: [] });
    render(<WhatYouSubmitted run={run} />);
    expect(screen.queryByTestId("version-resolutions")).toBeNull();
  });

  it("does NOT render the banner when original_target == new_target", () => {
    // Backend already filters these out, but defend client-side too.
    const run = baseRun({
      version_resolutions: [
        { target_scope: "mvm", original_target: 2, new_target: 2 },
      ],
    });
    render(<WhatYouSubmitted run={run} />);
    expect(screen.queryByTestId("version-resolutions")).toBeNull();
  });

  it("does NOT render the banner when the field is omitted from RunOut", () => {
    const run = baseRun();
    delete (run as Partial<RunOut>).version_resolutions;
    render(<WhatYouSubmitted run={run} />);
    expect(screen.queryByTestId("version-resolutions")).toBeNull();
  });
});
