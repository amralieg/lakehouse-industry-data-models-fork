/**
 * `ModelVersionPage` (all-domains route) domain-title dropdown (item 3B,
 * 0.6.6).
 *
 * The domain dropdown moves to the page title via `ModelTabsShell`'s
 * `domainSelectorSlot`. Picking a domain navigates DOWN into the domain
 * route (push, preserving diagram/relationships/ontology; anything else
 * falls back to "products", the domain page's default tab). This test
 * stubs `ModelTabsShell` to render `domainSelectorSlot` directly and spies
 * on `useNavigate` so the assertions don't need the full shell/ModelView
 * chain.
 */
import { describe, expect, it, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";

const navigateSpy = vi.fn();

let lastShellProps: Record<string, unknown> = {};
vi.mock("@/components/model/model-tabs-shell", () => ({
  ModelTabsShell: (props: Record<string, unknown>) => {
    lastShellProps = props;
    return <div data-testid="shell-stub">{props.domainSelectorSlot as any}</div>;
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
        domains: [
          { name: "Sales", division: "Commercial", change_status: "unchanged" },
          { name: "Inventory", division: "Ops", change_status: "unchanged" },
        ],
      },
    }),
  };
});

vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return {
    ...actual,
    useSearch: () => ({ tab: "diagram" }),
    useNavigate: () => navigateSpy,
    Link: ({ children, ...props }: any) => <a {...props}>{children}</a>,
  };
});

import { ModelVersionPage } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.index";

function renderPage() {
  return render(<ModelVersionPage businessId="biz-1" version="1" scope="ecm" />);
}

describe("ModelVersionPage - domain-title dropdown navigates down (item 3B)", () => {
  it("passes showDomainSelect=false and an onDomainNavigate handler to the shell", () => {
    lastShellProps = {};
    renderPage();
    expect(lastShellProps.showDomainSelect).toBe(false);
    expect(typeof lastShellProps.onDomainNavigate).toBe("function");
  });

  it("navigates DOWN to the domain route (push) preserving a shared tab (diagram)", () => {
    navigateSpy.mockClear();
    renderPage();
    fireEvent.click(screen.getByRole("combobox"));
    fireEvent.click(screen.getByText("Sales"));
    expect(navigateSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        to: "/businesses/$businessId/model/$version/$scope/$domainName",
        params: { businessId: "biz-1", version: "1", scope: "ecm", domainName: "Sales" },
        search: { tab: "diagram" },
      }),
    );
    // Push, not replace: no `replace: true` in the navigate call.
    const call = navigateSpy.mock.calls.at(-1)?.[0];
    expect(call.replace).toBeUndefined();
  });

  it("does nothing when 'All domains' is picked (already on the all-domains page)", () => {
    navigateSpy.mockClear();
    renderPage();
    fireEvent.click(screen.getByRole("combobox"));
    fireEvent.click(screen.getByRole("option", { name: "All domains" }));
    expect(navigateSpy).not.toHaveBeenCalled();
  });
});
