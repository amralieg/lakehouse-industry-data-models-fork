import { ReactNode, Suspense } from "react";
import { render, RenderResult } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";
import { ErrorBoundary } from "react-error-boundary";

export interface RenderWithRouterOptions {
  initialPath?: string;
  queryClient?: QueryClient;
}

export interface RenderWithRouterResult extends RenderResult {
  queryClient: QueryClient;
  router: ReturnType<typeof buildRouter>;
}

function buildRouter(ui: ReactNode, initialPath: string) {
  const rootRoute = createRootRoute({
    component: () => (
      <ErrorBoundary fallbackRender={({ error }) => <div role="alert">{String(error)}</div>}>
        <Suspense fallback={<div data-testid="router-suspense-fallback" />}>
          <Outlet />
        </Suspense>
      </ErrorBoundary>
    ),
  });

  const matchAllRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "$",
    component: () => <>{ui}</>,
  });

  const runDetailRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/runs/$runId",
    component: () => <div data-testid="run-detail-stub" />,
  });

  // Sibling route to support Back-to-runs Links rendered by RunDetail's
  // surrounding chrome (and any other component that links to the
  // business-scoped runs list).
  const businessRunsRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/runs",
    component: () => <div data-testid="business-runs-stub" />,
  });

  // (the model-versioning work) ModelVersion is keyed on `(version, scope)`, so the
  // routable URL includes a `$scope` segment. Tests that mount UI which
  // navigates to a model page rely on this stub matching the production
  // shape — without it the link click would land on `matchAllRoute` and
  // the assertion on `router.state.location.pathname` would still see
  // the matched path but no semantic round-trip.
  const modelVersionRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/model/$version/$scope",
    component: () => <div data-testid="model-version-stub" />,
  });

  // Sub-page of the model: domain → product. Tests for FkLink and the
  // products table assert the click pathname includes the scope segment.
  const productDetailRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/model/$version/$scope/$domainName/$productName",
    component: () => <div data-testid="product-detail-stub" />,
  });

  const routeTree = rootRoute.addChildren([
    runDetailRoute,
    businessRunsRoute,
    modelVersionRoute,
    productDetailRoute,
    matchAllRoute,
  ]);

  return createRouter({
    routeTree,
    history: createMemoryHistory({ initialEntries: [initialPath] }),
    defaultPendingMs: 0,
  });
}

export function renderWithRouter(
  ui: ReactNode,
  opts: RenderWithRouterOptions = {},
): RenderWithRouterResult {
  const queryClient =
    opts.queryClient ??
    new QueryClient({
      defaultOptions: {
        queries: { retry: false },
        mutations: { retry: false },
      },
    });
  const router = buildRouter(ui, opts.initialPath ?? "/");

  const result = render(
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} />
    </QueryClientProvider>,
  );

  return { ...result, queryClient, router };
}
