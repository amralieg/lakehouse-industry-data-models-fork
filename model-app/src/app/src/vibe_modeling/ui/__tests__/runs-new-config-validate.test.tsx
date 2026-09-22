/**
 * Runs/new route - Track 4 findings #1 + #4 (validate blocker/warning banners)
 * and the shared config_missing renderer on hard submit (#2, run-submit path).
 *
 *  - Live validation now runs for every model-producing intent (base AND
 *    vibe), so config-missing blockers and the run-target-override divergence
 *    warning surface BEFORE submit even for the default vibe-iterate op.
 *  - A hard-submit 422 config_missing routes through the shared renderer
 *    (toast) rather than the raw `String(err)` inline banner.
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
import { Suspense } from "react";

vi.mock("sonner", () => ({
  toast: { error: vi.fn(), success: vi.fn(), warning: vi.fn(), info: vi.fn() },
}));

let versionsData: unknown[] = [];
const createRunMock = vi.fn();
const validateRunMock = vi.fn(
  async (): Promise<{ data: { blockers: unknown[]; warnings: unknown[] } }> => ({
    data: { blockers: [], warnings: [] },
  }),
);

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => ({
      data: { id: "biz-1", name: "Acme Corp", description: "An example business" },
    }),
    useListVersionsSuspense: () => ({ data: versionsData }),
    useListVibeInputs: () => ({ data: [] }),
    createRun: (...args: unknown[]) => (createRunMock as any)(...args),
    validateRun: (...args: unknown[]) => (validateRunMock as any)(...args),
  };
});

vi.mock("@/components/ui/markdown-toolbar", () => ({ MarkdownToolbar: () => null }));
vi.mock("@/components/runs/deployment-catalog-picker", () => ({
  DeploymentCatalogPicker: ({ value, onChange }: { value: string; onChange: (v: string) => void }) => (
    <input
      data-testid="catalog-picker"
      value={value}
      onChange={(e) => onChange(e.target.value)}
    />
  ),
}));

import { toast } from "sonner";
import { ApiError } from "@/lib/api";

const COMPLETED_VERSIONS = [
  {
    id: "v-1-mvm",
    version: 1,
    scope: "mvm",
    status: "completed",
    is_base: true,
    confidence_score: null,
    vibe_instructions: "",
    created_at: "2026-04-20T12:01:00Z",
    uc_catalog: "vibe_modeling",
    deployment_status: "deployed",
  },
];

function configMissingError() {
  return new ApiError(422, "Unprocessable Entity", {
    detail: {
      error: "config_missing",
      missing: [
        {
          key: "metamodel_catalog",
          label: "Metamodel catalog",
          settings_url: "/settings?tab=platform",
        },
      ],
      message: "Finish setup before running.",
    },
  });
}

beforeEach(() => {
  versionsData = [];
  createRunMock.mockReset();
  validateRunMock.mockClear();
  validateRunMock.mockImplementation(async () => ({ data: { blockers: [], warnings: [] } }));
});

afterEach(() => vi.restoreAllMocks());

async function renderRunsNew(searchString: string) {
  const { Route: RunsNewRoute } = await import(
    "@/routes/_sidebar/businesses.$businessId.runs.new"
  );
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const sidebarRoute = createRoute({
    getParentRoute: () => rootRoute,
    id: "/_sidebar",
    component: () => <Outlet />,
  });
  const runsNewClone = createRoute({
    getParentRoute: () => sidebarRoute,
    path: "/businesses/$businessId/runs/new",
    component: RunsNewRoute.options.component as any,
    validateSearch: RunsNewRoute.options.validateSearch as any,
  });
  const runsListRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/runs",
    component: () => <div data-testid="runs-stub" />,
  });
  const explorerRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/explorer",
    component: () => <div data-testid="explorer-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      sidebarRoute.addChildren([runsNewClone]),
      runsListRoute,
      explorerRoute,
    ]),
    history: createMemoryHistory({
      initialEntries: [`/businesses/biz-1/runs/new${searchString}`],
    }),
    defaultPendingMs: 0,
  });
  const qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000 },
      mutations: { retry: false },
    },
  });
  return render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={<div data-testid="suspense-fallback" />}>
        <RouterProvider router={router} />
      </Suspense>
    </QueryClientProvider>,
  );
}

describe("Runs/new validate banners (findings #1, #4)", () => {
  it("surfaces validate blockers AND warnings for the vibe-iterate intent", async () => {
    versionsData = COMPLETED_VERSIONS;
    validateRunMock.mockImplementation(async () => ({
      data: {
        blockers: [
          { field_path: "catalog", step_index: 0, message: "Metamodel catalog not configured", severity: "blocker" },
        ],
        warnings: [
          { field_path: "catalog", step_index: 0, message: "Run catalog diverges from the configured metamodel catalog", severity: "warning" },
        ],
      },
    }));

    await renderRunsNew("?businessId=biz-1&operationType=vibe-iterate");

    await waitFor(() => {
      expect(screen.getByTestId("validate-blockers")).toBeInTheDocument();
    });
    expect(screen.getByText(/Metamodel catalog not configured/i)).toBeInTheDocument();
    expect(screen.getByTestId("validate-warnings")).toBeInTheDocument();
    expect(
      screen.getByText(/diverges from the configured metamodel catalog/i),
    ).toBeInTheDocument();
    // validateRun was actually invoked for the vibe intent (broadened gate).
    expect(validateRunMock).toHaveBeenCalled();
  });
});

describe("Runs/new hard-submit config_missing (finding #2, run-submit path)", () => {
  it("routes a 422 config_missing through the shared toast renderer", async () => {
    versionsData = [];
    createRunMock.mockRejectedValue(configMissingError());

    await renderRunsNew("?businessId=biz-1&operationType=new base model");

    // Start Run opens the launch-confirmation dialog.
    const startBtn = await screen.findByRole("button", { name: /Start Run/i });
    await waitFor(() => expect(startBtn).not.toBeDisabled());
    await act(async () => {
      fireEvent.click(startBtn);
    });

    const launchBtn = await screen.findByRole("button", { name: /^Launch$/i });
    await act(async () => {
      fireEvent.click(launchBtn);
    });

    await waitFor(() => expect(createRunMock).toHaveBeenCalledTimes(1));
    // Shared renderer fires instead of `String(err)` inline text.
    await waitFor(() => expect(toast.error).toHaveBeenCalledTimes(1));
    expect(screen.queryByText(/ApiError|HTTP 422/i)).toBeNull();
  });
});
