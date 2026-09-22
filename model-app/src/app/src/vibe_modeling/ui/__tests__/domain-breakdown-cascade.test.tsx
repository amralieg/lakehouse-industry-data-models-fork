/**
 * `<DomainBreakdownBody/>` cascade wiring (finding #3).
 *
 * The domain breakdown is the surface that makes the domain/subdomain cascade
 * affordance reachable: it mounts a domain-level `<ReviewStateControl/>` in the
 * toolbar and a subdomain-level one on each NAMED subdomain header. These tests
 * lock that the controls open the confirm dialog and fire the right cascade
 * hook (with the right id + count) on confirm, and do nothing on cancel.
 */
import { describe, expect, it, vi, beforeEach } from "vitest";
import { fireEvent, render, screen, within } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactNode } from "react";

vi.mock("@tanstack/react-router", async (orig) => {
  const actual = await (orig() as Promise<Record<string, unknown>>);
  return {
    ...actual,
    Link: ({ children }: { children: ReactNode }) => <a>{children}</a>,
  };
});

const markDomainMutate = vi.fn();
const markSubdomainMutate = vi.fn();
const markProductMutate = vi.fn();
const clearProductMutate = vi.fn();

const reviews: unknown[] = [];
const baseProducts = [
  {
    id: "p1",
    name: "customers",
    subdomain: "profile",
    change_status: "modified",
    attribute_count: 10,
    fk_count: 2,
  },
  {
    id: "p2",
    name: "addresses",
    subdomain: "profile",
    change_status: "modified",
    attribute_count: 5,
    fk_count: 1,
  },
  {
    id: "p3",
    name: "orphan",
    subdomain: "",
    change_status: "modified",
    attribute_count: 3,
    fk_count: 0,
  },
];
let domainDetail: { name: string; products: any[] } = {
  name: "customer",
  products: baseProducts,
};

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListProductReviewsSuspense: () => ({ data: reviews }),
    useGetDomainDetailSuspense: () => ({ data: domainDetail }),
    useMarkDomainReview: () => ({ mutate: markDomainMutate, isPending: false }),
    useMarkSubdomainReview: () => ({
      mutate: markSubdomainMutate,
      isPending: false,
    }),
    useMarkProductReview: () => ({ mutate: markProductMutate, isPending: false }),
    useClearProductReview: () => ({
      mutate: clearProductMutate,
      isPending: false,
    }),
  };
});

import type { DomainSummaryOut } from "@/lib/api";
import { DomainBreakdownBody } from "@/components/statistics/sections/domain-breakdown";
import type { StatsScope } from "@/components/statistics/use-stats-data";

const scope: StatsScope = { businessId: "biz-1", versionInt: 2, scope: "mvm" };

const domainSummary: DomainSummaryOut = {
  id: "dom-1",
  name: "customer",
  product_count: 3,
  subdomains: [{ id: "sd-profile", name: "profile", product_count: 2 }],
};

function renderBreakdown(summary: DomainSummaryOut | null = domainSummary) {
  const qc = new QueryClient();
  render(
    <QueryClientProvider client={qc}>
      <DomainBreakdownBody
        scope={scope}
        domain="customer"
        domainSummary={summary}
        hasPredecessor={true}
      />
    </QueryClientProvider>,
  );
}

beforeEach(() => {
  markDomainMutate.mockReset();
  markSubdomainMutate.mockReset();
  markProductMutate.mockReset();
  clearProductMutate.mockReset();
  domainDetail = { name: "customer", products: baseProducts };
});

describe("DomainBreakdownBody — cascade controls", () => {
  it("counts NAMED subdomains only (excludes the no-subdomain bucket)", () => {
    renderBreakdown();
    // 3 products, 1 named subdomain (profile) + 1 orphan in the no-subdomain
    // bucket → header reads "1 subdomains", not 2.
    expect(screen.getByText(/3 products · 1 subdomains/)).toBeInTheDocument();
  });

  it("does not render a redundant status chip on a product row — the segmented control conveys state (F12)", () => {
    renderBreakdown();
    const row = screen.getByTestId("breakdown-product-customers");
    // The segmented control (active filled button + aria-pressed) already
    // communicates current state, so the row must NOT carry a duplicate
    // "Needs review" status chip (F12 — user-flagged redundancy).
    expect(within(row).queryByText(/needs review/i)).toBeNull();
    // The control itself is present (state is conveyed by it).
    expect(
      within(row).getByRole("button", { name: /^reviewed/i }),
    ).toBeInTheDocument();
    expect(
      within(row).getByRole("button", { name: /not reviewed/i }),
    ).toBeInTheDocument();
  });

  it("domain mark opens the dialog and cascades on confirm with the domain id + count", () => {
    renderBreakdown();
    const domainCascade = screen.getByTestId("breakdown-domain-cascade");
    fireEvent.click(
      within(domainCascade).getByRole("button", { name: /^reviewed/i }),
    );
    // Dialog open, nothing fired yet.
    expect(markDomainMutate).not.toHaveBeenCalled();
    expect(screen.getByText("3 products")).toBeInTheDocument();

    fireEvent.click(screen.getByRole("button", { name: /mark 3 products/i }));
    expect(markDomainMutate).toHaveBeenCalledTimes(1);
    const params = markDomainMutate.mock.calls[0][0].params;
    expect(params.domain_id).toBe("dom-1");
    // Cascade keys on the version's natural composite key, never the UUID.
    expect(params.version_int).toBe(2);
    expect(params.scope).toBe("mvm");
    expect(params).not.toHaveProperty("version_id");
  });

  it("subdomain mark cascades on confirm with the subdomain id + product count", () => {
    renderBreakdown();
    const sdHeader = screen.getByTestId("breakdown-subdomain-header-profile");
    fireEvent.click(
      within(sdHeader).getByRole("button", { name: /^reviewed/i }),
    );
    expect(markSubdomainMutate).not.toHaveBeenCalled();

    fireEvent.click(screen.getByRole("button", { name: /mark 2 products/i }));
    expect(markSubdomainMutate).toHaveBeenCalledTimes(1);
    expect(markSubdomainMutate.mock.calls[0][0].params.subdomain_id).toBe(
      "sd-profile",
    );
  });

  it("cancel does nothing", () => {
    renderBreakdown();
    const sdHeader = screen.getByTestId("breakdown-subdomain-header-profile");
    fireEvent.click(
      within(sdHeader).getByRole("button", { name: /^reviewed/i }),
    );
    fireEvent.click(screen.getByRole("button", { name: /cancel/i }));
    expect(markSubdomainMutate).not.toHaveBeenCalled();
    expect(markDomainMutate).not.toHaveBeenCalled();
  });

  it("the no-subdomain bucket exposes no cascade control", () => {
    renderBreakdown();
    const orphanHeader = screen.getByTestId(
      "breakdown-subdomain-header-(no subdomain)",
    );
    // Its header has only the collapse toggle, no Reviewed/Not-reviewed group.
    expect(
      within(orphanHeader).queryByRole("button", { name: /^reviewed/i }),
    ).toBeNull();
  });

  it("excludes deleted products from the breakdown rows and the need-review count", () => {
    // A deleted product is reconstructed from the predecessor for the change
    // view; it has no review row in THIS version and isn't an actionable
    // review target, so it must not appear as a row nor inflate the counts.
    domainDetail = {
      name: "customer",
      products: [
        ...baseProducts,
        {
          id: "p-del",
          name: "retired_table",
          subdomain: "profile",
          change_status: "deleted",
          attribute_count: 4,
          fk_count: 0,
        },
      ],
    };
    renderBreakdown();

    // Deleted product is not rendered as a row.
    expect(screen.queryByTestId("breakdown-product-retired_table")).toBeNull();
    // Header still reads 3 products (the deleted one is excluded) and the
    // need-review count counts only the 3 actionable (not-reviewed) products.
    expect(
      screen.getByText(/3 products · 1 subdomains · 3 need review/),
    ).toBeInTheDocument();
  });

  it("without a domain summary, no cascade controls mount (product marking still works)", () => {
    renderBreakdown(null);
    // No domain-level control in the toolbar, no subdomain control on the header.
    expect(screen.queryByTestId("breakdown-domain-cascade")).toBeNull();
    const sdHeader = screen.getByTestId("breakdown-subdomain-header-profile");
    expect(
      within(sdHeader).queryByRole("button", { name: /^reviewed/i }),
    ).toBeNull();
  });

  it("product with id renders name as an anchor; product without id renders as plain span", () => {
    domainDetail = {
      name: "customer",
      products: [
        { ...baseProducts[0] },
        { id: "", name: "legacy_table", subdomain: "profile", change_status: "modified", attribute_count: 2, fk_count: 0 },
      ],
    };
    renderBreakdown();
    // 'customers' has id "p1" → rendered as <a> anchor (mocked Link).
    const customersRow = screen.getByTestId("breakdown-product-customers");
    const customersEl = within(customersRow).getByText("customers");
    expect(customersEl.tagName.toLowerCase()).toBe("a");
    // 'legacy_table' has no id → rendered as plain <span>, not a link.
    const legacyRow = screen.getByTestId("breakdown-product-legacy_table");
    const legacyEl = within(legacyRow).getByText("legacy_table");
    expect(legacyEl.tagName.toLowerCase()).toBe("span");
  });
});
