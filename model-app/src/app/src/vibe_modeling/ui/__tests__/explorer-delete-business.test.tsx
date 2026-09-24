/**
 * "Delete business" lives on the EXPLORER page (the business's main page),
 * not the Runs page. These tests lock that move:
 *   - the explorer header renders a "Delete business" button,
 *   - confirming always deletes with `cascade=true` (the endpoint requires it
 *     when the business has versions OR runs OR feedback; cascade on an empty
 *     business is a harmless no-op), then redirects to /businesses,
 *   - a delete failure surfaces a toast and stays on the page.
 *
 * The explorer calls the standalone `deleteBusiness` API function (not the
 * `useDeleteBusiness` hook), so we mock that function directly.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen, waitFor, act, within } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";

const businessData = {
  id: "biz-1",
  name: "Acme Co",
  description: "An acme business.",
  business_vibes: "",
  industry_alignment: "Retail",
  industry_id: null,
  created_at: "2024-01-01T00:00:00Z",
  updated_at: "2024-01-01T00:00:00Z",
};

let versionsData: any[] = [];
const deleteBusinessMock = vi.fn().mockResolvedValue({ data: {} });

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => ({ data: businessData }),
    useListIndustriesSuspense: () => ({ data: [] }),
    useGetExplorerVersionsSuspense: () => ({ data: versionsData }),
    useListSectorsSuspense: () => ({ data: [] }),
    deleteBusiness: (params: { business_id: string; cascade?: boolean }) =>
      deleteBusinessMock(params),
  };
});

vi.mock("@/components/explorer/breadcrumb-context", () => ({
  useBreadcrumbs: () => {},
}));

vi.mock("sonner", () => ({
  toast: { error: vi.fn(), success: vi.fn() },
}));

import { toast } from "sonner";

afterEach(() => {
  vi.clearAllMocks();
  versionsData = [];
});

async function renderExplorer() {
  const { Route: ExplorerRoute } = await import(
    "@/routes/_sidebar/businesses.$businessId.explorer"
  );
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const sidebarRoute = createRoute({
    getParentRoute: () => rootRoute,
    id: "/_sidebar",
    component: () => <Outlet />,
  });
  const explorerClone = createRoute({
    getParentRoute: () => sidebarRoute,
    path: "/businesses/$businessId/explorer",
    component: ExplorerRoute.options.component as any,
  });
  const businessesStub = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses",
    component: () => <div data-testid="businesses-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      sidebarRoute.addChildren([explorerClone]),
      businessesStub,
    ]),
    history: createMemoryHistory({
      initialEntries: ["/businesses/biz-1/explorer"],
    }),
    defaultPendingMs: 0,
  });
  const qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });
  render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={<div data-testid="suspense-fallback" />}>
        <RouterProvider router={router} />
      </Suspense>
    </QueryClientProvider>,
  );
  return qc;
}

async function openDeleteDialog() {
  const trigger = await screen.findByRole("button", { name: /delete business/i });
  await act(async () => {
    fireEvent.click(trigger);
  });
}

describe("Explorer page — Delete business", () => {
  it("renders the Delete business button in the header", async () => {
    await renderExplorer();
    expect(
      await screen.findByRole("button", { name: /delete business/i }),
    ).toBeInTheDocument();
  });

  it("cascades on confirm when the business has versions, then redirects", async () => {
    versionsData = [{ id: "v1", version: 1, scope: "mvm", status: "completed", created_at: "2024-01-01T00:00:00Z" }];
    const qc = await renderExplorer();
    const invalidateSpy = vi.spyOn(qc, "invalidateQueries");
    await openDeleteDialog();

    // Version-count detail is visible when versions exist.
    expect(screen.getByText(/will be removed from Lakebase/i)).toBeInTheDocument();

    await act(async () => {
      fireEvent.click(
        within(screen.getByRole("dialog")).getByRole("button", { name: /^delete business$/i }),
      );
    });

    await waitFor(() =>
      expect(deleteBusinessMock).toHaveBeenCalledWith({
        business_id: "biz-1",
        cascade: true,
      }),
    );
    // The reported bug: delete-then-navigate never invalidated the
    // businesses-list cache, so /businesses served a stale row on return.
    await waitFor(() =>
      expect(invalidateSpy).toHaveBeenCalledWith({
        predicate: expect.any(Function),
      }),
    );
    await waitFor(() =>
      expect(screen.getByTestId("businesses-stub")).toBeInTheDocument(),
    );
  });

  it("still deletes with cascade=true on an empty business (no 409 path)", async () => {
    versionsData = [];
    await renderExplorer();
    await openDeleteDialog();

    // Always-cascade warning is shown; the version-count line is omitted at 0.
    expect(
      screen.getByText(/permanently deletes this business/i),
    ).toBeInTheDocument();
    expect(screen.queryByText(/will be removed from Lakebase/i)).toBeNull();

    await act(async () => {
      fireEvent.click(
        within(screen.getByRole("dialog")).getByRole("button", { name: /^delete business$/i }),
      );
    });

    await waitFor(() =>
      expect(deleteBusinessMock).toHaveBeenCalledWith({
        business_id: "biz-1",
        cascade: true,
      }),
    );
  });

  it("surfaces a toast on delete failure and stays on the page", async () => {
    deleteBusinessMock.mockRejectedValueOnce(new Error("boom"));
    await renderExplorer();
    await openDeleteDialog();

    await act(async () => {
      fireEvent.click(
        within(screen.getByRole("dialog")).getByRole("button", { name: /^delete business$/i }),
      );
    });

    await waitFor(() => expect(toast.error).toHaveBeenCalled());
    expect(screen.queryByTestId("businesses-stub")).toBeNull();
  });
});
