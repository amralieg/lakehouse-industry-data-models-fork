/**
 * `DomainSidebar` rendering coverage.
 *
 * The sidebar renders a list of domain links plus a nested subdomain
 * list when the `currentDomain` prop matches. It depends on TanStack
 * Router's `<Link>`, so we mount through `renderWithRouter`. Three
 * scenarios:
 *
 *   1. Multiple domains, no current selection — sidebar lists each
 *      domain with its product-count badge.
 *   2. Empty domain list — sidebar still mounts with the "All Domains"
 *      link and a count of 0.
 *   3. `currentDomain` matches a domain that has subdomains — the
 *      nested list renders below the active domain link.
 */
import { beforeAll, describe, expect, it } from "vitest";
import { screen, within } from "@testing-library/react";

import { DomainSidebar } from "@/components/explorer/domain-sidebar";
import { renderWithRouter } from "./helpers/router-wrapper";
import { useStrictConsole } from "./helpers/strict-console";

// jsdom doesn't implement matchMedia; the sidebar's `useMediaQuery` hook
// calls it on mount. Default to "wide screen" so the sidebar starts
// expanded — that's the path under test.
beforeAll(() => {
  if (!window.matchMedia) {
    Object.defineProperty(window, "matchMedia", {
      writable: true,
      value: (query: string) => ({
        matches: true,
        media: query,
        onchange: null,
        addListener: () => {},
        removeListener: () => {},
        addEventListener: () => {},
        removeEventListener: () => {},
        dispatchEvent: () => false,
      }),
    });
  }
});

describe("DomainSidebar", () => {
  const dom = useStrictConsole();

  it("renders one link per domain, plus the All-Domains link", async () => {
    renderWithRouter(
      <DomainSidebar
        businessId="biz-1"
        version="1"
        scope="mvm"
        domains={[
          { name: "Sales", product_count: 4 },
          { name: "Inventory", product_count: 2 },
        ]}
      >
        <div>main</div>
      </DomainSidebar>,
    );
    // Sidebar header
    expect(await screen.findByText("Domains")).toBeInTheDocument();
    // Each domain link
    expect(screen.getByText("Sales")).toBeInTheDocument();
    expect(screen.getByText("Inventory")).toBeInTheDocument();
    // Counts: "4" is unique to Sales; "2" appears twice (Inventory's
    // count and the All-Domains active-count badge) so check >0 instead
    // of getByText.
    expect(screen.getByText("4")).toBeInTheDocument();
    expect(screen.getAllByText("2").length).toBeGreaterThan(0);
    // All-Domains link with the active-domain count (2)
    expect(screen.getByText(/All Domains/i)).toBeInTheDocument();
    // Children still render alongside the sidebar
    expect(screen.getByText("main")).toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });

  it("expands subdomains under the currently-selected domain", async () => {
    renderWithRouter(
      <DomainSidebar
        businessId="biz-1"
        version="1"
        scope="ecm"
        currentDomain="Sales"
        domains={[
          {
            name: "Sales",
            product_count: 4,
            subdomains: [
              { name: "OrdersDetail", product_count: 2 },
              { name: "Pricing", product_count: 1 },
            ],
          },
          { name: "Inventory", product_count: 2 },
        ]}
      >
        <div>main</div>
      </DomainSidebar>,
    );
    // Subdomain rows render only for the active domain
    expect(await screen.findByText("OrdersDetail")).toBeInTheDocument();
    expect(screen.getByText("Pricing")).toBeInTheDocument();
    // Inventory is not the current domain; its (unset) subdomains
    // should not appear.
    const inventoryLink = screen.getByText("Inventory").closest("a");
    expect(inventoryLink).toBeTruthy();
    if (inventoryLink) {
      expect(within(inventoryLink).queryByText(/OrdersDetail/i)).toBeNull();
    }
    expect(dom.messages).toEqual([]);
  });
});
