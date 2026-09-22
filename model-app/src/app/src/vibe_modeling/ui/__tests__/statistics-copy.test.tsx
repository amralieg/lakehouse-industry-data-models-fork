/**
 * Copy guards (F9/F11): the Statistics surfaces must not leak the internal
 * `next_vibes` token or dev-roadmap phrasing ("later extension") into rendered,
 * user-facing strings.
 */
import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";

const nextVibe = { has_data: false, counts: {}, total_open: 0 };

vi.mock("@/components/statistics/use-stats-data", async () => {
  const actual = await vi.importActual<
    typeof import("@/components/statistics/use-stats-data")
  >("@/components/statistics/use-stats-data");
  return {
    ...actual,
    useNextVibeMetrics: () => nextVibe,
  };
});

import { WorkAheadBody } from "@/components/statistics/sections/work-ahead-section";
import type { StatsScope } from "@/components/statistics/use-stats-data";

const scope: StatsScope = { businessId: "b1", versionInt: 1, scope: "ecm" };

describe("Statistics copy guards (F9/F11)", () => {
  it("Work Ahead empty state uses user-facing copy, not the internal next_vibes term", () => {
    render(<WorkAheadBody scope={scope} />);
    expect(
      screen.getByText(/no suggested next steps for this version/i),
    ).toBeInTheDocument();
    expect(screen.queryByText(/next_vibes/i)).toBeNull();
  });
});
