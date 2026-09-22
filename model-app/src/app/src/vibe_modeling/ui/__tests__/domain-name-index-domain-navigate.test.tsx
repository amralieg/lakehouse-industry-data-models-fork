/**
 * Domain page (single-domain diagram route) title dropdown (item 3B,
 * 0.6.6).
 *
 * The domain dropdown moves to the page title, next to `<h1>{domain.name}</h1>`.
 * Picking another domain navigates DOWN (push, same tab - both levels share
 * diagram/relationships/ontology/products). Picking "All domains" navigates
 * UP to the scope route: "products" (domain-only) maps to "overview";
 * diagram/relationships/ontology are shared and kept as-is.
 */
import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";
import { ErrorBoundary } from "react-error-boundary";

const navigateSpy = vi.fn();
let searchHook: () => unknown = () => ({ tab: "diagram" });

vi.mock("@/components/diagram/diagram-viewer", () => ({
  DiagramViewer: () => <div data-testid="diagram-viewer-stub" />,
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
      data: {
        name: "Test Model",
        version: 1,
        domains: [
          { name: "Sales", division: "Commercial", change_status: "unchanged" },
          { name: "Inventory", division: "Ops", change_status: "unchanged" },
        ],
      },
    }),
    useGetExplorerVersionsSuspense: () => ({
      data: [{ id: "v-1", version: 1, scope: "ecm" }],
    }),
    useGetUserPreferences: () => ({ data: { data: [] }, isLoading: false }),
  };
});

vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return {
    ...actual,
    useSearch: () => searchHook(),
    useNavigate: () => navigateSpy,
    Link: ({ children, ...props }: any) => <a {...props}>{children}</a>,
  };
});

import { DomainDetail } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.$domainName.index";

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

beforeEach(() => {
  navigateSpy.mockClear();
  searchHook = () => ({ tab: "diagram" });
});

describe("Domain page - title dropdown navigation (item 3B)", () => {
  it("shows the current domain selected in the title dropdown", () => {
    renderDomainPage();
    expect(screen.getByRole("combobox")).toHaveTextContent("Sales");
  });

  it("navigates DOWN to another domain (push), preserving the current tab", () => {
    searchHook = () => ({ tab: "relationships" });
    renderDomainPage();
    fireEvent.click(screen.getByRole("combobox"));
    fireEvent.click(screen.getByRole("option", { name: /Inventory/ }));
    expect(navigateSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        to: "/businesses/$businessId/model/$version/$scope/$domainName",
        params: { businessId: "biz-1", version: "1", scope: "ecm", domainName: "Inventory" },
        search: { tab: "relationships" },
      }),
    );
    const call = navigateSpy.mock.calls.at(-1)?.[0];
    expect(call.replace).toBeUndefined();
  });

  it("navigates UP to the scope route on 'All domains', mapping products -> overview", () => {
    searchHook = () => ({ tab: "products" });
    renderDomainPage();
    fireEvent.click(screen.getByRole("combobox"));
    fireEvent.click(screen.getByRole("option", { name: "All domains" }));
    expect(navigateSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        to: "/businesses/$businessId/model/$version/$scope",
        params: { businessId: "biz-1", version: "1", scope: "ecm" },
        search: { tab: "overview" },
      }),
    );
  });

  it("navigates UP to the scope route on 'All domains', keeping a shared tab (diagram)", () => {
    searchHook = () => ({ tab: "diagram" });
    renderDomainPage();
    fireEvent.click(screen.getByRole("combobox"));
    fireEvent.click(screen.getByRole("option", { name: "All domains" }));
    expect(navigateSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        to: "/businesses/$businessId/model/$version/$scope",
        search: { tab: "diagram" },
      }),
    );
  });

  it("does nothing when the currently-viewed domain is re-picked", () => {
    renderDomainPage();
    fireEvent.click(screen.getByRole("combobox"));
    fireEvent.click(screen.getByRole("option", { name: /Sales/ }));
    expect(navigateSpy).not.toHaveBeenCalled();
  });
});
