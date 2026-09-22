/**
 * `FkLink` rendering + navigation coverage.
 *
 * The component parses a "domain.table.column" string and links to the target
 * product page. Product routes are keyed by product `name`, but the FK's
 * middle token may be the product's physical `table_name` (they diverge after
 * a rename). So `FkLink` resolves the token against the target domain's
 * products (fetched via `useGetDomainDetail` for the current version+scope) and
 * links on the resolved `name`; an unresolvable token renders disabled rather
 * than a dead 404 link.
 *
 * We seed the react-query cache with the target domain so the resolution is
 * synchronous in the test (no network).
 */
import { describe, expect, it } from "vitest";
import { screen } from "@testing-library/react";
import { QueryClient } from "@tanstack/react-query";

import { FkLink } from "@/components/explorer/fk-link";
import {
  getDomainDetailKey,
  type DomainDetailOut,
  type ProductSummaryOut,
} from "@/lib/api";
import { renderWithRouter } from "./helpers/router-wrapper";
import { useStrictConsole } from "./helpers/strict-console";

function product(name: string, table_name: string): ProductSummaryOut {
  return { name, table_name, description: "" };
}

function seedDomain(
  qc: QueryClient,
  params: { business_id: string; version_int: number; scope: string; domain_name: string },
  detail: DomainDetailOut,
) {
  qc.setQueryData(getDomainDetailKey(params), { data: detail });
}

function makeClient(): QueryClient {
  return new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
}

describe("FkLink", () => {
  const dom = useStrictConsole();

  it("resolves a 3-part FK to the target product route (name === token)", async () => {
    const qc = makeClient();
    seedDomain(
      qc,
      { business_id: "biz-1", version_int: 1, scope: "ecm", domain_name: "sales" },
      { name: "sales", products: [product("orders", "orders")] },
    );
    renderWithRouter(
      <FkLink foreignKeyTo="sales.orders.customer_id" businessId="biz-1" version="1" scope="ecm" />,
      { queryClient: qc },
    );
    const link = await screen.findByRole("link");
    expect(link).toHaveTextContent("sales.orders.customer_id");
    expect(link).toHaveAttribute("href", "/businesses/biz-1/model/1/ecm/sales/orders");
    expect(dom.messages).toEqual([]);
  });

  it("resolves via table_name when the product was renamed (name !== token)", async () => {
    const qc = makeClient();
    seedDomain(
      qc,
      { business_id: "biz-1", version_int: 2, scope: "ecm", domain_name: "sales" },
      // FK token "orders" is the physical table_name; the product NAME is
      // "orders_v2" — the route key must be the name, not the token.
      { name: "sales", products: [product("orders_v2", "orders")] },
    );
    renderWithRouter(
      <FkLink foreignKeyTo="sales.orders.customer_id" businessId="biz-1" version="2" scope="ecm" />,
      { queryClient: qc },
    );
    const link = await screen.findByRole("link");
    expect(link).toHaveAttribute("href", "/businesses/biz-1/model/2/ecm/sales/orders_v2");
    expect(dom.messages).toEqual([]);
  });

  it("renders disabled (no link) when the token resolves to no product in this version", async () => {
    const qc = makeClient();
    seedDomain(
      qc,
      { business_id: "biz-1", version_int: 1, scope: "ecm", domain_name: "sales" },
      { name: "sales", products: [product("customers", "customers")] },
    );
    renderWithRouter(
      <FkLink foreignKeyTo="sales.orders.customer_id" businessId="biz-1" version="1" scope="ecm" />,
      { queryClient: qc },
    );
    // No navigable link — the reference is present but disabled.
    expect(await screen.findByText("sales.orders.customer_id")).toBeInTheDocument();
    expect(screen.queryByRole("link")).not.toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });

  it("falls back to plain text for malformed FK strings (single segment)", async () => {
    renderWithRouter(
      <FkLink foreignKeyTo="orphan" businessId="biz-1" version="1" scope="ecm" />,
    );
    expect(await screen.findByText("orphan")).toBeInTheDocument();
    expect(screen.queryByRole("link")).not.toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });
});
