/**
 * `<ReviewProgress/>` (T4) — product-level reviewed ÷ review-needed indicator.
 * Asserts it renders the ratio, EXCLUDES no_review_needed from the denominator
 * (reuses the backend `review_needed`), and shows the empty "nothing to review"
 * state when nothing needs review.
 */
import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import type { ReviewProgressOut } from "@/lib/api";

let progressFixture: ReviewProgressOut;

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetReviewProgressSuspense: () => ({ data: progressFixture }),
  };
});

import { ReviewProgress } from "@/components/review/review-progress";

function renderProgress(fixture: ReviewProgressOut) {
  progressFixture = fixture;
  render(<ReviewProgress businessId="biz-1" versionInt={2} scope="mvm" />);
}

describe("ReviewProgress", () => {
  it("renders reviewed / review-needed and the percentage", () => {
    renderProgress({
      version_id: "v",
      review_pct: 0.5,
      reviewed: 3,
      review_needed: 6,
      no_review_needed: 4,
      total: 10,
    });
    // Denominator is review_needed (6), NOT total (10) — no_review_needed excluded.
    expect(screen.getByText(/3 \/ 6 reviewed/)).toBeInTheDocument();
    expect(screen.getByText(/50%/)).toBeInTheDocument();
  });

  it("excludes no_review_needed from the bar and notes the exclusion", () => {
    renderProgress({
      version_id: "v",
      review_pct: 1,
      reviewed: 2,
      review_needed: 2,
      no_review_needed: 8,
      total: 10,
    });
    expect(screen.getByText(/2 \/ 2 reviewed/)).toBeInTheDocument();
    expect(screen.getByText(/8 unchanged products excluded/i)).toBeInTheDocument();
  });

  it("shows 'nothing to review' when review-needed is zero", () => {
    renderProgress({
      version_id: "v",
      review_pct: 0,
      reviewed: 0,
      review_needed: 0,
      no_review_needed: 5,
      total: 5,
    });
    expect(screen.getByText(/nothing to review/i)).toBeInTheDocument();
    expect(screen.queryByText(/reviewed \(/)).not.toBeInTheDocument();
  });
});
