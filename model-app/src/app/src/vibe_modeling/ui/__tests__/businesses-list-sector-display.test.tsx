/**
 * F1 render-site coverage: the Businesses-list "Sector" column resolves a
 * stored ``sector_id`` (a FK into ``sectors.id``) to the matching Sector's
 * ``name`` via ``sectorDisplayName`` rather than rendering the legacy
 * ``industry_alignment`` free-text.
 *
 *  - A ``sector_id`` that matches a catalog row shows that sector's name.
 *  - A null ``sector_id`` renders the em-dash placeholder.
 *  - A dangling ``sector_id`` (no matching row) also renders the placeholder
 *    rather than leaking the raw id.
 */
import { describe, expect, it, vi } from "vitest";
import { screen, waitFor } from "@testing-library/react";
import { QueryClient } from "@tanstack/react-query";

let businessesData: any[] = [];
let sectorsData: any[] = [];

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListBusinessesSuspense: () => ({ data: businessesData }),
    useListSectorsSuspense: () => ({ data: sectorsData }),
    useDeleteBusiness: () => ({ mutateAsync: vi.fn() }),
    useGetAgentConfig: () => ({ data: undefined, isError: true, isLoading: false }),
  };
});

vi.mock("@/lib/selector", () => ({
  selector: () => ({}),
  default: () => ({}),
}));

vi.mock("sonner", () => ({ toast: { error: vi.fn(), success: vi.fn() } }));

import { BusinessTable } from "@/routes/_sidebar/businesses.index";
import { renderWithRouter } from "./helpers/router-wrapper";

const makeBusiness = (overrides: Partial<any>): any => ({
  id: `biz-${overrides.sector_id ?? Math.random()}`,
  name: "Acme",
  industry_alignment: null,
  sector_id: null,
  model_count: 0,
  created_at: "2026-04-20T00:00:00Z",
  ...overrides,
});

async function renderTable() {
  const qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000 },
      mutations: { retry: false },
    },
  });
  renderWithRouter(<BusinessTable />, { queryClient: qc });
  await waitFor(() => {
    expect(screen.getByText("All Businesses")).toBeInTheDocument();
  });
}

describe("BusinessTable sector column display", () => {
  it("resolves a sector_id to the matching sector name", async () => {
    sectorsData = [
      { id: "sec-retail", name: "Retail & E-Commerce" },
      { id: "sec-fsi", name: "Financial Services" },
    ];
    businessesData = [
      makeBusiness({ name: "Acme Retail", sector_id: "sec-retail" }),
    ];

    await renderTable();

    expect(screen.getByText("Retail & E-Commerce")).toBeInTheDocument();
    expect(screen.queryByText("sec-retail")).toBeNull();
  });

  it("renders a placeholder when sector_id is null", async () => {
    sectorsData = [{ id: "sec-retail", name: "Retail & E-Commerce" }];
    businessesData = [makeBusiness({ name: "Unsectored", sector_id: null })];

    await renderTable();

    expect(screen.getByText("—")).toBeInTheDocument();
    expect(screen.queryByText("Retail & E-Commerce")).toBeNull();
  });

  it("renders a placeholder (not the raw id) for a dangling sector_id", async () => {
    sectorsData = [{ id: "sec-retail", name: "Retail & E-Commerce" }];
    businessesData = [
      makeBusiness({ name: "Dangling", sector_id: "sec-deleted" }),
    ];

    await renderTable();

    expect(screen.getByText("—")).toBeInTheDocument();
    expect(screen.queryByText("sec-deleted")).toBeNull();
  });
});
