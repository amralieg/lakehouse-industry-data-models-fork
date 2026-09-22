/**
 * `ModelVersionPage` (all-domains diagram route) column-mode preference
 * WIRING regression (0.6.6 bug bash, item 4C fix).
 *
 * Live-tester finding: with `diagram.default_column_mode=all` saved, a
 * fresh hard reload of a never-opened business/model still requested the
 * diagram with `column_mode=hide` - the hardcoded default. Root cause:
 * `useGetUserPreferences()` is a non-suspense query, so this route mounted
 * `ModelView` -> `DiagramViewer` (which seeds `columnMode` via a `useState`
 * initializer read ONCE) before the preference query resolved. The fix
 * threads `isLoading` from that query into a `columnModePending` prop so
 * `ModelView` defers mounting `DiagramViewer` until the preference is known.
 *
 * This test isolates the ROUTE's wiring: it stubs `ModelView` to capture
 * the props it's called with, and controls `useGetUserPreferences`'s
 * loading/resolved states directly (no real network timing needed) to
 * assert the route forwards `columnModePending` and the resolved
 * `initialColumnMode` correctly - this is the exact defect class the live
 * tester caught.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { render } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";
import { ErrorBoundary } from "react-error-boundary";

let userPreferencesHook: () => unknown = () => ({ data: undefined, isLoading: true });

let lastModelViewProps: Record<string, unknown> = {};
vi.mock("@/components/vibe-inputs/model-view", () => ({
  ModelView: (props: Record<string, unknown>) => {
    lastModelViewProps = props;
    return <div data-testid="model-view-stub" />;
  },
}));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListVersionsSuspense: () => ({
      data: [{ id: "v-1", version: 1, scope: "ecm", deployment_status: "draft" }],
    }),
    useGetBusinessSuspense: () => ({ data: { id: "biz-1", name: "Test Biz" } }),
    useGetModelSummarySuspense: () => ({
      data: {
        name: "Test Model",
        version: 1,
        domain_count: 0,
        product_count: 0,
        attribute_count: 0,
        fk_count: 0,
        confidence_score: null,
        domains: [],
      },
    }),
    useListVibeInputsSuspense: () => ({ data: [] }),
    useListVibeInputs: () => ({ data: [] }),
    useGetUserPreferences: () => userPreferencesHook(),
    getDiagramLayout: vi.fn(async () => ({ data: {} })),
  };
});

vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return {
    ...actual,
    useSearch: () => ({ tab: "diagram" }),
    useNavigate: () => vi.fn(),
    Link: ({ children, ...props }: any) => <a {...props}>{children}</a>,
  };
});

import { ModelVersionPage } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.index";

afterEach(() => {
  userPreferencesHook = () => ({ data: undefined, isLoading: true });
});

function makeClient() {
  return new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
}

function renderPage() {
  return render(
    <QueryClientProvider client={makeClient()}>
      <ErrorBoundary fallbackRender={({ error }) => <div role="alert">Error: {String(error)}</div>}>
        <Suspense fallback={<div data-testid="suspense-fallback" />}>
          <ModelVersionPage businessId="biz-1" version="1" scope="ecm" />
        </Suspense>
      </ErrorBoundary>
    </QueryClientProvider>,
  );
}

describe("ModelVersionPage - diagram.default_column_mode wiring (item 4C regression)", () => {
  it("forwards columnModePending=true to ModelView while the preference query is loading", () => {
    userPreferencesHook = () => ({ data: undefined, isLoading: true });
    lastModelViewProps = {};
    renderPage();
    expect(lastModelViewProps.columnModePending).toBe(true);
  });

  it("forwards the resolved diagram.default_column_mode value and columnModePending=false once loaded", () => {
    userPreferencesHook = () => ({
      data: { data: [{ key: "diagram.default_column_mode", value: "all", updated_at: "2026-07-01T00:00:00Z" }] },
      isLoading: false,
    });
    lastModelViewProps = {};
    renderPage();
    expect(lastModelViewProps.columnModePending).toBe(false);
    expect(lastModelViewProps.initialColumnMode).toBe("all");
  });

  it("resolves to undefined initialColumnMode (DiagramViewer's own fallback) when no preference is set", () => {
    userPreferencesHook = () => ({ data: { data: [] }, isLoading: false });
    lastModelViewProps = {};
    renderPage();
    expect(lastModelViewProps.columnModePending).toBe(false);
    expect(lastModelViewProps.initialColumnMode).toBeUndefined();
  });
});
