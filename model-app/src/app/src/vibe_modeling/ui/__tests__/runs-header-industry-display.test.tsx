/**
 * F1 render-site coverage (missed-sibling fix): the runs page business
 * header resolves ``industry_alignment`` via ``industryDisplayName``
 * rather than rendering the raw stored slug verbatim.
 */
import { describe, expect, it, vi } from "vitest";
import { screen, waitFor } from "@testing-library/react";
import { QueryClient } from "@tanstack/react-query";

let businessData: any = {};
let industriesData: any[] = [];

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => ({ data: businessData }),
    useListRunsSuspense: () => ({ data: [] }),
    useListVersionsSuspense: () => ({ data: [] }),
    useListIndustriesSuspense: () => ({ data: industriesData }),
  };
});

vi.mock("@/lib/hooks", async () => {
  const actual = await vi.importActual<typeof import("@/lib/hooks")>("@/lib/hooks");
  return {
    ...actual,
    useAgentReady: () => ({ data: { ready: true } }),
  };
});

vi.mock("@/lib/selector", () => ({
  selector: () => ({}),
  default: () => ({}),
}));

vi.mock("sonner", () => ({ toast: { error: vi.fn(), success: vi.fn() } }));

import { BusinessDetail } from "@/routes/_sidebar/businesses.$businessId.runs.index";
import { renderWithRouter } from "./helpers/router-wrapper";

const makeBusiness = (overrides: Partial<any>): any => ({
  id: "biz-1",
  name: "Acme",
  description: "An acme business.",
  industry_alignment: null,
  model_count: 0,
  created_at: "2026-04-20T00:00:00Z",
  ...overrides,
});

async function renderHeader() {
  const qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000 },
      mutations: { retry: false },
    },
  });
  renderWithRouter(<BusinessDetail businessId="biz-1" />, { queryClient: qc });
  await waitFor(() => {
    expect(screen.getByText("Acme")).toBeInTheDocument();
  });
}

describe("Runs page business-header industry display", () => {
  it("resolves a catalog-matching slug to the curated display name (F1)", async () => {
    industriesData = [
      { name: "Food and Beverage", short_name: "food-and-beverage" },
    ];
    businessData = makeBusiness({ industry_alignment: "food-and-beverage" });

    await renderHeader();

    expect(screen.getByText("Food and Beverage")).toBeInTheDocument();
    expect(screen.queryByText("food-and-beverage")).toBeNull();
  });

  it("title-cases a slug with no catalog match (F1 fallback)", async () => {
    industriesData = [];
    businessData = makeBusiness({ industry_alignment: "staffing-and-recruitment" });

    await renderHeader();

    expect(screen.getByText("Staffing and Recruitment")).toBeInTheDocument();
    expect(screen.queryByText("staffing-and-recruitment")).toBeNull();
  });
});
