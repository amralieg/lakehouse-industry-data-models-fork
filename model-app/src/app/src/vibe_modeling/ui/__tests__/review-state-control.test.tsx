/**
 * `<ReviewStateControl/>` (T4) — the reusable three-state review control.
 *  - product "Reviewed" → markProductReview with state=reviewed
 *  - product "Not reviewed" on an explicit mark → clearProductReview (revert to default)
 *  - domain "Reviewed" → does NOT cascade until the confirm dialog is confirmed
 *  - no_review_needed renders its read-only badge but stays overridable
 */
import { describe, expect, it, vi, beforeEach } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const markProductMutate = vi.fn();
const clearProductMutate = vi.fn();
const markDomainMutate = vi.fn();
const markSubdomainMutate = vi.fn();

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useMarkProductReview: () => ({ mutate: markProductMutate, isPending: false }),
    useClearProductReview: () => ({ mutate: clearProductMutate, isPending: false }),
    useMarkDomainReview: () => ({ mutate: markDomainMutate, isPending: false }),
    useMarkSubdomainReview: () => ({ mutate: markSubdomainMutate, isPending: false }),
  };
});

import { ReviewState } from "@/lib/api";
import {
  ReviewStateControl,
  type ReviewTarget,
} from "@/components/review/review-state-control";

const productTarget: ReviewTarget = {
  level: "product",
  id: "prod-1",
  name: "customers",
  businessId: "biz-1",
  versionInt: 2,
  scope: "mvm",
};

const domainTarget: ReviewTarget = {
  ...productTarget,
  level: "domain",
  id: "dom-1",
  name: "Sales",
};

function renderControl(props: Partial<React.ComponentProps<typeof ReviewStateControl>>) {
  const qc = new QueryClient();
  render(
    <QueryClientProvider client={qc}>
      <ReviewStateControl
        target={productTarget}
        state={ReviewState.not_reviewed}
        {...props}
      />
    </QueryClientProvider>,
  );
}

beforeEach(() => {
  markProductMutate.mockReset();
  clearProductMutate.mockReset();
  markDomainMutate.mockReset();
  markSubdomainMutate.mockReset();
});

describe("ReviewStateControl — product", () => {
  it("marks a product reviewed", () => {
    renderControl({ state: ReviewState.not_reviewed });
    fireEvent.click(screen.getByRole("button", { name: /^reviewed/i }));
    expect(markProductMutate).toHaveBeenCalledTimes(1);
    const [vars] = markProductMutate.mock.calls[0];
    expect(vars.params.product_id).toBe("prod-1");
    // The mark now keys on the version's natural composite key, never the UUID.
    expect(vars.params.version_int).toBe(2);
    expect(vars.params.scope).toBe("mvm");
    expect(vars.params).not.toHaveProperty("version_id");
    expect(vars.data.state).toBe(ReviewState.reviewed);
  });

  it("clears an explicit mark when set back to not-reviewed", () => {
    renderControl({ state: ReviewState.reviewed, isExplicit: true });
    fireEvent.click(screen.getByRole("button", { name: /not reviewed/i }));
    expect(clearProductMutate).toHaveBeenCalledTimes(1);
    expect(markProductMutate).not.toHaveBeenCalled();
  });

  it("stores an explicit not_reviewed override on a computed default", () => {
    // no_review_needed is a computed default (isExplicit=false); choosing
    // Not reviewed must persist the override rather than clear (nothing to clear).
    renderControl({ state: ReviewState.no_review_needed, isExplicit: false });
    fireEvent.click(screen.getByRole("button", { name: /not reviewed/i }));
    expect(clearProductMutate).not.toHaveBeenCalled();
    expect(markProductMutate).toHaveBeenCalledTimes(1);
    expect(markProductMutate.mock.calls[0][0].data.state).toBe(
      ReviewState.not_reviewed,
    );
  });

  it("renders the read-only no_review_needed badge", () => {
    renderControl({ state: ReviewState.no_review_needed });
    expect(screen.getByText(/no review needed/i)).toBeInTheDocument();
  });
});

describe("ReviewStateControl — domain cascade gating", () => {
  it("does NOT cascade on click; only after dialog confirm", () => {
    renderControl({ target: domainTarget, state: ReviewState.not_reviewed, cascadeCount: 5 });

    fireEvent.click(screen.getByRole("button", { name: /^reviewed/i }));
    // The cascade endpoint must not be hit yet — only the dialog opened.
    expect(markDomainMutate).not.toHaveBeenCalled();
    // "5 products" appears in the warning copy (a <strong>) and the confirm
    // button; assert the warning copy specifically.
    expect(screen.getByText("5 products")).toBeInTheDocument();

    // Confirm.
    fireEvent.click(screen.getByRole("button", { name: /mark 5 products/i }));
    expect(markDomainMutate).toHaveBeenCalledTimes(1);
    expect(markDomainMutate.mock.calls[0][0].params.domain_id).toBe("dom-1");
    expect(markDomainMutate.mock.calls[0][0].data.state).toBe(ReviewState.reviewed);
  });

  it("does NOT cascade if the dialog is cancelled", () => {
    renderControl({ target: domainTarget, state: ReviewState.not_reviewed, cascadeCount: 5 });
    fireEvent.click(screen.getByRole("button", { name: /^reviewed/i }));
    fireEvent.click(screen.getByRole("button", { name: /cancel/i }));
    expect(markDomainMutate).not.toHaveBeenCalled();
  });
});
