import { describe, it, expect } from "vitest";
import { screen } from "@testing-library/react";

import { ApiError } from "@/lib/api";
import { BusinessExplorerError } from "@/routes/_sidebar/businesses.$businessId.explorer";
import { renderWithRouter } from "./helpers/router-wrapper";

/**
 * an internal tracker item — Business-404 page falls back to generic
 * "Something went wrong" error boundary.
 *
 * The fix: the explorer route wires `errorComponent: BusinessExplorerError`,
 * which renders a friendly "Business not found" card with a "See all
 * businesses" Link when the business query rejects with HTTP 404. Other
 * 4xx/5xx errors share the shell with a less-specific title.
 *
 * Asserts:
 *  - 404 → "Business not found" heading is visible.
 *  - "See all businesses" link is present (so the user can recover).
 *  - Non-404 errors do NOT mislabel themselves as "Business not found".
 */
describe("BusinessExplorerError (an internal tracker item)", () => {
  it("renders 'Business not found' and a 'See all businesses' link on 404", async () => {
    const err = new ApiError(404, "Not Found", { detail: "no such biz" });
    renderWithRouter(<BusinessExplorerError error={err} />);

    expect(
      await screen.findByRole("heading", { name: /Business not found/i }),
    ).toBeInTheDocument();
    expect(
      screen.getByRole("link", { name: /See all businesses/i }),
    ).toBeInTheDocument();
  });

  it("does not say 'Business not found' for non-404 errors", async () => {
    // 5xx (or any other status) shares the same shell but with a generic
    // title — the friendly 'not found' phrasing must NOT show up for
    // server errors so the operator isn't misled into thinking the
    // business was deleted.
    const err = new ApiError(500, "Internal Server Error", null);
    renderWithRouter(<BusinessExplorerError error={err} />);

    // Wait for the router to render the component.
    expect(
      await screen.findByRole("heading", {
        name: /Couldn['’]t load this business/i,
      }),
    ).toBeInTheDocument();
    expect(
      screen.queryByRole("heading", { name: /Business not found/i }),
    ).not.toBeInTheDocument();
    // Recovery affordance is still present on non-404 errors.
    expect(
      screen.getByRole("link", { name: /See all businesses/i }),
    ).toBeInTheDocument();
  });

  it("does not fall back to the generic ErrorBoundary 'Something went wrong' copy", async () => {
    // Pre-fix, the explorer route had no errorComponent so the
    // `renderWithRouter` wrapper's ErrorBoundary rendered the raw error
    // string. Verify the friendly shell wins instead.
    const err = new ApiError(404, "Not Found", null);
    renderWithRouter(<BusinessExplorerError error={err} />);
    // Wait for the friendly heading so we know the router has rendered.
    await screen.findByRole("heading", { name: /Business not found/i });
    expect(screen.queryByText(/Something went wrong/i)).not.toBeInTheDocument();
  });
});
