/**
 * Domain page (single-domain diagram route) column-mode preference WIRING
 * regression (0.6.6 bug bash, item 4C fix).
 *
 * Live-tester finding: with `diagram.default_column_mode_focal=hide` saved,
 * a fresh hard reload of a never-opened domain page still requested the
 * diagram with `column_mode=keys` - the hardcoded default. Root cause:
 * `useGetUserPreferences()` is a non-suspense query, so this route mounted
 * `DiagramViewer` (which seeds `columnMode` via a `useState` initializer
 * read ONCE) before the preference query resolved. The fix gates the
 * `DiagramViewer` mount on that query's `isLoading` (a Skeleton renders
 * instead while pending).
 *
 * This test stubs `DiagramViewer` to capture whether/how it's mounted, and
 * controls `useGetUserPreferences`'s loading/resolved states directly to
 * assert the route defers the mount and forwards the resolved value.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";
import { ErrorBoundary } from "react-error-boundary";

let userPreferencesHook: () => unknown = () => ({ data: undefined, isLoading: true });

const diagramProps: { current: Record<string, unknown> | null } = { current: null };
vi.mock("@/components/diagram/diagram-viewer", () => ({
  DiagramViewer: (props: Record<string, unknown>) => {
    diagramProps.current = props;
    return <div data-testid="diagram-viewer-stub" />;
  },
}));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => ({ data: { id: "biz-1", name: "Test Biz" } }),
    useGetDomainDetailSuspense: () => ({
      data: {
        name: "Sales",
        division: "Commercial",
        description: "",
        database_name: "",
        references: "",
        products: [],
      },
    }),
    useGetModelSummarySuspense: () => ({
      data: { name: "Test Model", version: 1, domains: [] },
    }),
    useGetExplorerVersionsSuspense: () => ({
      data: [{ id: "v-1", version: 1, scope: "ecm" }],
    }),
    useGetUserPreferences: () => userPreferencesHook(),
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

import { DomainDetail } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.$domainName.index";

afterEach(() => {
  userPreferencesHook = () => ({ data: undefined, isLoading: true });
});

function makeClient() {
  return new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
}

function renderDomainPage() {
  return render(
    <QueryClientProvider client={makeClient()}>
      <ErrorBoundary fallbackRender={({ error }) => <div role="alert">Error: {String(error)}</div>}>
        <Suspense fallback={<div data-testid="suspense-fallback" />}>
          <DomainDetail businessId="biz-1" version="1" scope="ecm" domainName="Sales" />
        </Suspense>
      </ErrorBoundary>
    </QueryClientProvider>,
  );
}

describe("Domain page - diagram.default_column_mode_focal wiring (item 4C regression)", () => {
  it("does not mount DiagramViewer (shows a Skeleton) while the preference query is loading", () => {
    userPreferencesHook = () => ({ data: undefined, isLoading: true });
    diagramProps.current = null;
    renderDomainPage();
    expect(screen.queryByTestId("diagram-viewer-stub")).not.toBeInTheDocument();
    expect(diagramProps.current).toBeNull();
  });

  it("mounts DiagramViewer with the resolved diagram.default_column_mode_focal value once loaded", () => {
    userPreferencesHook = () => ({
      data: {
        data: [{ key: "diagram.default_column_mode_focal", value: "hide", updated_at: "2026-07-01T00:00:00Z" }],
      },
      isLoading: false,
    });
    diagramProps.current = null;
    renderDomainPage();
    expect(screen.getByTestId("diagram-viewer-stub")).toBeInTheDocument();
    expect((diagramProps.current as Record<string, unknown> | null)?.initialColumnMode).toBe("hide");
  });

  it("mounts DiagramViewer with undefined initialColumnMode (own fallback) when no preference is set", () => {
    userPreferencesHook = () => ({ data: { data: [] }, isLoading: false });
    diagramProps.current = null;
    renderDomainPage();
    expect(screen.getByTestId("diagram-viewer-stub")).toBeInTheDocument();
    expect((diagramProps.current as Record<string, unknown> | null)?.initialColumnMode).toBeUndefined();
  });
});
