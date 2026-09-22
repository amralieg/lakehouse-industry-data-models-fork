/**
 * Home / landing page (route `/`). Replaces the old redirect-to-businesses.
 * Covers the two jobs the page must do: orient a newcomer (the workflow strip
 * + "Learn how it works" link) and resume a returning user ("Jump back in"
 * with recency-ordered items). Also the empty state for a fresh workspace.
 *
 * The suspense list hooks are mocked so the page renders synchronously; the
 * import dialog is stubbed to its trigger to avoid dragging its own fetches in.
 */
import { describe, it, expect, vi, beforeEach } from "vitest";
import { ReactNode } from "react";
import { render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";

let businessesData: unknown[] = [];
let industriesData: unknown[] = [];
let userPrefsData: unknown[] = [];

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListBusinessesSuspense: () => ({ data: businessesData }),
    useListIndustriesSuspense: () => ({ data: industriesData }),
    // ResumeSection reads visit times via the non-suspense preferences hook and
    // unwraps the envelope with a `select`, so the resolved `data` is the array.
    useGetUserPreferences: () => ({ data: userPrefsData }),
  };
});

vi.mock("@/components/import/import-new-business-dialog", () => ({
  ImportNewBusinessDialog: ({ trigger }: { trigger: ReactNode }) => <>{trigger}</>,
}));

import { HomePage } from "@/routes/_sidebar/index";
import { useStrictConsole } from "./helpers/strict-console";

function makeClient() {
  return new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
}

function withRouter(ui: ReactNode) {
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const mk = (path: string) =>
    createRoute({
      getParentRoute: () => rootRoute,
      path,
      component: () => <div data-testid={`stub-${path}`} />,
    });
  const subject = createRoute({
    getParentRoute: () => rootRoute,
    path: "/",
    component: () => <>{ui}</>,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      subject,
      mk("/help/$topic"),
      mk("/businesses/$businessId"),
      mk("/businesses/new"),
      mk("/industries"),
    ]),
    history: createMemoryHistory({ initialEntries: ["/"] }),
  });
  return (
    <QueryClientProvider client={makeClient()}>
      <RouterProvider router={router} />
    </QueryClientProvider>
  );
}

beforeEach(() => {
  businessesData = [];
  industriesData = [];
  userPrefsData = [];
});

describe("Home page", () => {
  const dom = useStrictConsole();

  it("always shows the orientation strip and a link into help", async () => {
    render(withRouter(<HomePage />));
    expect(
      await screen.findByText(/You build your data model through iterations/i),
    ).toBeInTheDocument();
    expect(
      screen.getByRole("link", { name: /Learn how it works/i }),
    ).toBeInTheDocument();
    // Strip stage labels present.
    expect(screen.getByText("Start your model")).toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });

  it("resumes a returning user with their recent work, newest first", async () => {
    businessesData = [
      {
        id: "biz-1",
        name: "Retail Bank",
        created_at: "2026-09-15T10:00:00Z",
        model_count: 3,
      },
      {
        id: "biz-2",
        name: "Vesta Markets",
        created_at: "2026-09-10T10:00:00Z",
        model_count: 6,
      },
    ];
    render(withRouter(<HomePage />));
    expect(await screen.findByText("Jump back in")).toBeInTheDocument();
    expect(screen.getByText("Retail Bank")).toBeInTheDocument();
    expect(screen.getByText("Vesta Markets")).toBeInTheDocument();
    expect(screen.getByText(/3 model versions/i)).toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });

  it("orders a recently visited business ahead of a more recently created one", async () => {
    // biz-1 was created after biz-2, so creation-order would rank it first.
    businessesData = [
      {
        id: "biz-1",
        name: "Retail Bank",
        created_at: "2026-09-15T10:00:00Z",
        model_count: 3,
      },
      {
        id: "biz-2",
        name: "Vesta Markets",
        created_at: "2026-09-10T10:00:00Z",
        model_count: 6,
      },
    ];
    // A visit to biz-2, newer than biz-1's creation time, must float it to top.
    userPrefsData = [
      { key: "visit:business:biz-2", value: "1", updated_at: "2026-09-20T10:00:00Z" },
    ];
    render(withRouter(<HomePage />));
    await screen.findByText("Jump back in");
    const titles = screen
      .getAllByText(/^(Retail Bank|Vesta Markets)$/)
      .map((el) => el.textContent);
    expect(titles).toEqual(["Vesta Markets", "Retail Bank"]);
    expect(dom.messages).toEqual([]);
  });

  it("hides Jump back in when there is no history, but keeps the entry points", async () => {
    render(withRouter(<HomePage />));
    // "Start something new" + entry points always render, so a newcomer can
    // start from the home page; the recency list does not.
    expect(await screen.findByText("Browse industries")).toBeInTheDocument();
    expect(screen.getByText("Import a model")).toBeInTheDocument();
    expect(screen.queryByText("Jump back in")).not.toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });
});
