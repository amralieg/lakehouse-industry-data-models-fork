/**
 * Cross-component integration: the source-explorer dialog -> download dialog
 * handoff in ``source-explorer-dialog.tsx``.
 *
 * Drives the real ``SourceExplorerDialog``: expand the source tree to a model
 * leaf, select it, click Download in the preview, and assert the stacked
 * ``DownloadIndustryDialog`` mounts PRE-FILLED — the target sector pre-filled
 * from the display-name-matched ``suggested_sector_id`` and the Download submit
 * enabled (industry_id/model_id carried through, no "browse first" guidance).
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";
import type { ReactNode } from "react";

vi.mock("sonner", () => ({
  toast: { success: vi.fn(), warning: vi.fn(), error: vi.fn(), info: vi.fn() },
}));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  const rq =
    await vi.importActual<typeof import("@tanstack/react-query")>(
      "@tanstack/react-query",
    );
  const downloadIndustryModel = vi.fn();
  return {
    ...actual,
    downloadIndustryModel,
    useGetSourceCapabilitiesSuspense: vi.fn(),
    useListSourceSectorsSuspense: vi.fn(),
    useListSourceIndustries: vi.fn(),
    useListSourceModels: vi.fn(),
    useListSectorsSuspense: vi.fn(),
    useListBusinessesSuspense: vi.fn(),
    useGetSourceModelPreviewSuspense: vi.fn(),
    // useDownloadIndustryModel closes over the module-internal function, not
    // the exported binding - wrap a real useMutation so onSuccess still fires.
    useDownloadIndustryModel: () =>
      rq.useMutation({
        mutationFn: (vars: { params: unknown; data: unknown }) =>
          downloadIndustryModel(vars.data, vars.params),
      }),
  };
});

import {
  downloadIndustryModel,
  useGetSourceCapabilitiesSuspense,
  useListSourceSectorsSuspense,
  useListSourceIndustries,
  useListSourceModels,
  useListSectorsSuspense,
  useListBusinessesSuspense,
  useGetSourceModelPreviewSuspense,
} from "@/lib/api";
import { SourceExplorerDialog } from "@/components/source-explorer/source-explorer-dialog";

const m = {
  caps: vi.mocked(useGetSourceCapabilitiesSuspense),
  srcSectors: vi.mocked(useListSourceSectorsSuspense),
  srcIndustries: vi.mocked(useListSourceIndustries),
  srcModels: vi.mocked(useListSourceModels),
  localSectors: vi.mocked(useListSectorsSuspense),
  businesses: vi.mocked(useListBusinessesSuspense),
  preview: vi.mocked(useGetSourceModelPreviewSuspense),
  download: vi.mocked(downloadIndustryModel),
};

function wrap(ui: ReactNode) {
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const indexRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/",
    component: () => <>{ui}</>,
  });
  const explorerRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/explorer",
    component: () => <div data-testid="explorer-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([indexRoute, explorerRoute]),
    history: createMemoryHistory({ initialEntries: ["/"] }),
  });
  return (
    <QueryClientProvider client={qc}>
      <RouterProvider router={router as any} />
    </QueryClientProvider>
  );
}

beforeEach(() => {
  m.download.mockReset();
  m.caps.mockReturnValue({
    data: { source_kind: "github", read_only: true },
  } as any);
  m.srcSectors.mockReturnValue({
    data: [{ id: "ssec-retail", name: "Retail" }],
  } as any);
  m.localSectors.mockReturnValue({
    data: [
      { id: "sec-retail", name: "Retail", is_active: true },
      { id: "sec-fsi", name: "Financial Services", is_active: true },
    ],
  } as any);
  // No existing industries -> no "already downloaded" badges.
  m.businesses.mockReturnValue({ data: [] } as any);
  m.srcIndustries.mockReturnValue({
    data: { data: [{ id: "ind-1", name: "Grocery", sector_id: "ssec-retail" }] },
    isLoading: false,
    isError: false,
  } as any);
  m.srcModels.mockReturnValue({
    data: {
      data: [
        { id: "model-1", industry_id: "ind-1", name: "Grocery ECM", version: "v1", scope: "ecm" },
      ],
    },
    isLoading: false,
    isError: false,
  } as any);
  m.preview.mockReturnValue({
    data: {
      industry_id: "ind-1",
      model_id: "model-1",
      model_name: "Grocery",
      scope: "ecm",
      version: "v1",
      readme: null,
      domains: 4,
      artifacts: [],
    },
  } as any);
});

afterEach(() => vi.restoreAllMocks());

describe("source explorer dialog -> download dialog handoff", () => {
  it("hosts the tree and opens the download dialog pre-filled when Download clicked", async () => {
    render(wrap(<SourceExplorerDialog open onOpenChange={() => {}} />));

    // Expand sector -> industry -> version to reach the model leaf.
    fireEvent.click(await screen.findByText("Retail"));
    fireEvent.click(await screen.findByText("Grocery"));
    fireEvent.click(await screen.findByText("v1"));

    // Select the model leaf -> preview renders with its own Download button.
    fireEvent.click(await screen.findByText("Grocery ECM"));

    const previewDownload = await screen.findByRole("button", {
      name: /^download$/i,
    });
    await act(async () => {
      fireEvent.click(previewDownload);
    });

    // Stacked download dialog is mounted with a real selection: NOT the
    // "browse first" guidance, and the submit is enabled because the sector
    // pre-filled from the display-name match.
    await screen.findByText(/Materialize the selected source model/i);
    expect(
      screen.queryByText(/No source model selected/i),
    ).not.toBeInTheDocument();
    const submit = await screen.findByTestId("download-submit");
    await waitFor(() => expect(submit).not.toBeDisabled());
  });

  it("swaps the download dialog for the completion dialog on success, then navigates on View industry", async () => {
    m.download.mockResolvedValue({
      data: {
        business_id: "biz-1",
        business_name: "Grocery",
        version: 1,
        version_id: "v-1",
        scope: "ecm",
        domains: 4,
        products: 20,
        attribute_count: 80,
        fk_count: 5,
        on_conflict_applied: "none",
        warnings: [],
      },
    } as any);

    render(wrap(<SourceExplorerDialog open onOpenChange={() => {}} />));

    fireEvent.click(await screen.findByText("Retail"));
    fireEvent.click(await screen.findByText("Grocery"));
    fireEvent.click(await screen.findByText("v1"));
    fireEvent.click(await screen.findByText("Grocery ECM"));
    fireEvent.click(
      await screen.findByRole("button", { name: /^download$/i }),
    );

    await act(async () => {
      fireEvent.click(await screen.findByTestId("download-submit"));
    });

    // The download dialog is gone; the completion dialog took its place.
    await waitFor(() =>
      expect(
        screen.queryByText(/Materialize the selected source model/i),
      ).not.toBeInTheDocument(),
    );
    expect(
      await screen.findByRole("button", { name: /view industry/i }),
    ).toBeInTheDocument();

    fireEvent.click(screen.getByRole("button", { name: /view industry/i }));

    expect(await screen.findByTestId("explorer-stub")).toBeInTheDocument();
  });
});
