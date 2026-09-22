/**
 * `FirstRunGate` page-tree test.
 *
 * Audit risk #1: this gate sits on every fresh-install rendering of the
 * Businesses index. It reads `isError` of `useGetAgentConfig` with
 * `retry: false` — the *exact* shape of bug 2 (PR #151). No test
 * previously rendered it.
 *
 * Three invariants per render cycle:
 *  1. Renders finitely on a 404 (no render loop).
 *  2. Banner + "Open Settings" link visible when config missing.
 *  3. Banner gone (returns null) when config present.
 *
 * Plus the global `useStrictConsole` hook fails the test on any
 * `validateDOMNesting` warning.
 */
import { describe, it, expect, afterEach, vi } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";
import { ReactNode, StrictMode } from "react";

import { FirstRunGate } from "@/routes/_sidebar/businesses.index";
import { firstRunFetcher } from "./helpers/first-run";
import { useStrictConsole } from "./helpers/strict-console";
import { createRenderCounter, RenderCounted } from "./helpers/render-counter";

afterEach(() => {
  vi.restoreAllMocks();
  vi.unstubAllGlobals();
});

// FirstRunGate uses <Link to="/settings"> from TanStack Router. Wrap the
// subject in a tiny memory router so the link resolves; the actual
// destination route is stubbed.
function withRouter(ui: ReactNode) {
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const settingsRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/settings",
    component: () => <div data-testid="settings-stub" />,
  });
  const indexRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/",
    component: () => <>{ui}</>,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([indexRoute, settingsRoute]),
    history: createMemoryHistory({ initialEntries: ["/"] }),
  });
  return <RouterProvider router={router} />;
}

function makeClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000 },
      mutations: { retry: false },
    },
  });
}

describe("FirstRunGate (Phase 4.5 bug-2 shape guard)", () => {
  const dom = useStrictConsole();

  it("shows the gate banner with Settings link on a 404 (fresh install)", async () => {
    vi.stubGlobal("fetch", firstRunFetcher());
    const qc = makeClient();

    render(
      <QueryClientProvider client={qc}>
        {withRouter(<FirstRunGate />)}
      </QueryClientProvider>,
    );

    await waitFor(() => {
      expect(
        screen.getByText(/Finish setup before creating a business/i),
      ).toBeInTheDocument();
    });
    expect(screen.getByRole("link", { name: /Open Settings/i })).toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });

  it("renders nothing when the agent is configured", async () => {
    // The api.ts response handler wraps the body in { data: ... }, so the
    // fixture body should be the raw config object — not pre-wrapped.
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/config/agent": {
          status: 200,
          body: {
            notebook_path: "/Workspace/Users/me/agent",
            deployment_catalog: "vibe_modeling",
          },
        },
      }),
    );
    const qc = makeClient();
    render(
      <QueryClientProvider client={qc}>
        {withRouter(<FirstRunGate />)}
      </QueryClientProvider>,
    );

    // Gate should never render the banner when config has notebook_path.
    // Negative-assertion-only approach: wait for a microtask cycle for the
    // query to resolve, then confirm the banner stays absent.
    await new Promise((r) => setTimeout(r, 100));
    expect(
      screen.queryByText(/Finish setup before creating a business/i),
    ).not.toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });

  it("renders finitely under 404 — no infinite render loop", async () => {
    vi.stubGlobal("fetch", firstRunFetcher());
    const qc = makeClient();
    const counter = createRenderCounter("FirstRunGate", 16);

    render(
      <StrictMode>
        <QueryClientProvider client={qc}>
          {withRouter(
            <RenderCounted counter={counter}>
              <FirstRunGate />
            </RenderCounted>,
          )}
        </QueryClientProvider>
      </StrictMode>,
    );

    await waitFor(() => {
      expect(
        screen.getByText(/Finish setup before creating a business/i),
      ).toBeInTheDocument();
    });
    // Settle window: a render loop produces 100+ renders here; finite
    // commit produces ≤ 16 (StrictMode ×2 + a few error transitions).
    await new Promise((r) => setTimeout(r, 200));
    expect(counter.count).toBeLessThanOrEqual(counter.max);
  });
});
