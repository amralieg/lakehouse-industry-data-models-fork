/**
 * ModelSearch (Track 6 item 2) palette + navigation tests.
 *
 * The palette queries the version-scoped searchModelElements endpoint and lists
 * hits grouped by kind; selecting a hit navigates per element type (URL-driven).
 * Locks: Cmd/Ctrl-K opens it, grouped rendering, and per-type navigation
 * targets (domain -> domain diagram; table -> domain diagram focused on the
 * product; column -> product page with the column highlighted).
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ModelSearchHitOut } from "@/lib/api";

const navigateMock = vi.fn();
let hits: ModelSearchHitOut[] = [];
// Captures every call the component makes into the search hook, so tests can
// assert on the `enabled` gate (min-query-length fix) without the mock
// itself performing any actual fetch.
type SearchArgs = { params: { q: string }; query: { enabled: boolean } };
const searchCalls: SearchArgs[] = [];

// The pre-existing test suite below never types into the search box - it
// opens the palette and asserts against `hits` directly - so the default
// mock ignores `enabled` and always returns the fixture, matching the
// behavior those tests were written against. The min-query-length describe
// block further down overrides this implementation to actually honor
// `enabled` (mirroring what TanStack Query really does when a query is
// disabled) so it can assert results are gated, not just requested.
const useSearchModelElementsMock = vi.fn(
  (args: SearchArgs): { data: ModelSearchHitOut[] | undefined } => {
    searchCalls.push(args);
    return { data: hits };
  },
);

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useSearchModelElements: (args: SearchArgs) => useSearchModelElementsMock(args),
  };
});

vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>("@tanstack/react-router");
  return { ...actual, useNavigate: () => navigateMock };
});

import { ModelSearch } from "@/components/model/model-search";

function makeClient() {
  return new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
}

function renderSearch() {
  return render(
    <QueryClientProvider client={makeClient()}>
      <ModelSearch businessId="biz-1" version="2" scope="ecm" />
    </QueryClientProvider>,
  );
}

afterEach(() => {
  vi.clearAllMocks();
  hits = [];
  searchCalls.length = 0;
  useSearchModelElementsMock.mockImplementation((args: SearchArgs) => {
    searchCalls.push(args);
    return { data: hits };
  });
});

const DOMAIN_HIT: ModelSearchHitOut = { type: "domain", domain_name: "sales", label: "sales", sublabel: "Commercial" };
const PRODUCT_HIT: ModelSearchHitOut = { type: "product", domain_name: "sales", product_name: "orders", label: "orders", sublabel: "sales" };
const ATTR_HIT: ModelSearchHitOut = { type: "attribute", domain_name: "sales", product_name: "orders", attribute_name: "order_id", label: "order_id", sublabel: "sales › orders" };

describe("ModelSearch", () => {
  it("opens the palette with Cmd/Ctrl-K", () => {
    renderSearch();
    expect(screen.queryByPlaceholderText(/Search domains, tables, columns/i)).not.toBeInTheDocument();
    fireEvent.keyDown(document, { key: "k", metaKey: true });
    expect(screen.getByPlaceholderText(/Search domains, tables, columns/i)).toBeInTheDocument();
  });

  it("opens the palette from the header trigger", () => {
    renderSearch();
    fireEvent.click(screen.getByTitle(/Search the model/i));
    expect(screen.getByPlaceholderText(/Search domains, tables, columns/i)).toBeInTheDocument();
  });

  it("exposes an accessible dialog title + description (no a11y warning)", () => {
    renderSearch();
    fireEvent.click(screen.getByTitle(/Search the model/i));
    // Radix requires a DialogTitle (and a description for aria-describedby);
    // both are present but visually hidden.
    expect(screen.getByRole("dialog", { name: /Search the model/i })).toBeInTheDocument();
    expect(screen.getByText(/Search domains, tables, and columns by name/i)).toBeInTheDocument();
  });

  it("renders hits grouped by kind", () => {
    hits = [DOMAIN_HIT, PRODUCT_HIT, ATTR_HIT];
    renderSearch();
    fireEvent.click(screen.getByTitle(/Search the model/i));
    expect(screen.getByText("Domains")).toBeInTheDocument();
    expect(screen.getByText("Tables")).toBeInTheDocument();
    expect(screen.getByText("Columns")).toBeInTheDocument();
    expect(screen.getByText("order_id")).toBeInTheDocument();
  });

  it("navigates to the domain diagram for a domain hit", () => {
    hits = [DOMAIN_HIT];
    renderSearch();
    fireEvent.click(screen.getByTitle(/Search the model/i));
    fireEvent.click(screen.getByText("sales"));
    expect(navigateMock).toHaveBeenCalledWith({
      to: "/businesses/$businessId/model/$version/$scope/$domainName",
      params: { businessId: "biz-1", version: "2", scope: "ecm", domainName: "sales" },
      search: { tab: "diagram" },
    });
  });

  it("navigates to the domain diagram focused on the product for a table hit", () => {
    hits = [PRODUCT_HIT];
    renderSearch();
    fireEvent.click(screen.getByTitle(/Search the model/i));
    fireEvent.click(screen.getByText("orders"));
    expect(navigateMock).toHaveBeenCalledWith({
      to: "/businesses/$businessId/model/$version/$scope/$domainName",
      params: { businessId: "biz-1", version: "2", scope: "ecm", domainName: "sales" },
      search: { tab: "diagram", focusProduct: "orders" },
    });
  });

  it("navigates to the product page with the column highlighted for a column hit", () => {
    hits = [ATTR_HIT];
    renderSearch();
    fireEvent.click(screen.getByTitle(/Search the model/i));
    fireEvent.click(screen.getByText("order_id"));
    expect(navigateMock).toHaveBeenCalledWith({
      to: "/businesses/$businessId/model/$version/$scope/$domainName/$productName",
      params: { businessId: "biz-1", version: "2", scope: "ecm", domainName: "sales", productName: "orders" },
      search: { highlightColumn: "order_id" },
    });
  });
});

// ---------------------------------------------------------------------------
// Minimum query length gate (walkthrough finding): queries under 3 chars
// can't use the trigram index efficiently (~400ms full seq scan at 2 chars
// vs. 10-20ms indexed at 3+), so the request must not fire below that
// length - not fire-and-show-stale, not fire-and-error, just an idle hint.
// ---------------------------------------------------------------------------

describe("ModelSearch — minimum query length gate", () => {
  function typeAndSettle(value: string) {
    fireEvent.change(screen.getByPlaceholderText(/Search domains, tables, columns/i), {
      target: { value },
    });
    // Flush the 250ms debounce inside useDebouncedValue.
    act(() => {
      vi.advanceTimersByTime(300);
    });
  }

  beforeEach(() => {
    vi.useFakeTimers();
    // Unlike the default module-level mock, honor `enabled` here so these
    // tests exercise the real contract: a disabled query must not surface
    // data, matching what TanStack Query actually does in the app.
    useSearchModelElementsMock.mockImplementation((args: SearchArgs) => {
      searchCalls.push(args);
      return { data: args.query.enabled ? hits : undefined };
    });
  });
  afterEach(() => {
    vi.useRealTimers();
  });

  it("does not fire a request for a 2-character query", () => {
    renderSearch();
    fireEvent.click(screen.getByTitle(/Search the model/i));
    typeAndSettle("ab");

    expect(searchCalls.length).toBeGreaterThan(0);
    expect(searchCalls[searchCalls.length - 1].query.enabled).toBe(false);
    expect(screen.getByText(/type at least 3 characters/i)).toBeInTheDocument();
  });

  it("fires a request once the query reaches 3 characters", () => {
    hits = [DOMAIN_HIT];
    renderSearch();
    fireEvent.click(screen.getByTitle(/Search the model/i));
    typeAndSettle("abc");

    expect(searchCalls[searchCalls.length - 1].query.enabled).toBe(true);
    expect(searchCalls[searchCalls.length - 1].params.q).toBe("abc");
  });

  it("does not show stale results while below the minimum length", () => {
    hits = [DOMAIN_HIT];
    renderSearch();
    fireEvent.click(screen.getByTitle(/Search the model/i));
    typeAndSettle("abc");
    expect(screen.getByText("sales")).toBeInTheDocument();

    // Backspacing below the minimum must clear the previously-shown hit
    // rather than leaving it rendered as a stale result.
    typeAndSettle("ab");
    expect(screen.queryByText("sales")).not.toBeInTheDocument();
    expect(screen.getByText(/type at least 3 characters/i)).toBeInTheDocument();
  });

  it("still shows the idle hint for an empty query (unchanged)", () => {
    renderSearch();
    fireEvent.click(screen.getByTitle(/Search the model/i));
    expect(screen.getByText(/type to search the model/i)).toBeInTheDocument();
  });
});
