/**
 * Track 6 item 3 (0.6.6 bug bash): neither runs route called
 * `useBreadcrumbs`, so the top breadcrumb bar rendered empty on the runs
 * list and run detail pages. Both routes now wire the
 * `[business -> Runs (-> Run)]` trail, matching the pattern already used
 * by the explorer/model routes (business crumb links to
 * `/businesses/$businessId`, which redirects to the explorer).
 *
 * These tests mount the real `BreadcrumbProvider` + `useBreadcrumbItems`
 * consumer (rendered the same way `HeaderBreadcrumbs` renders them in
 * `sidebar-layout.tsx`) so the assertions cover the actual crumb labels
 * and link targets, not just that `useBreadcrumbs` was called.
 */
import { describe, expect, it, vi } from "vitest";
import { screen, waitFor } from "@testing-library/react";
import { QueryClient } from "@tanstack/react-query";
import type { ReactNode } from "react";

let businessData: any = {};
let runData: any = {};

vi.mock("sonner", () => ({ toast: { error: () => {}, success: () => {} } }));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => ({ data: businessData }),
    useGetRunSuspense: () => ({ data: runData }),
    useListRunsSuspense: () => ({ data: [] }),
    useListVersionsSuspense: () => ({ data: [] }),
    useListIndustriesSuspense: () => ({ data: [] }),
  };
});

vi.mock("@/lib/hooks", async () => {
  const actual = await vi.importActual<typeof import("@/lib/hooks")>("@/lib/hooks");
  return {
    ...actual,
    useAgentReady: () => ({ data: { ready: true } }),
  };
});

import {
  BreadcrumbProvider,
  useBreadcrumbItems,
} from "@/components/explorer/breadcrumb-context";
import { renderWithRouter } from "./helpers/router-wrapper";
import { BusinessDetail } from "@/routes/_sidebar/businesses.$businessId.runs.index";
import { RunDetail } from "@/routes/_sidebar/businesses.$businessId.runs.$runId";

const makeBusiness = (overrides: Partial<any> = {}): any => ({
  id: "biz-1",
  name: "Acme",
  description: "An acme business.",
  kind: "business",
  industry_alignment: null,
  sector_id: null,
  model_count: 0,
  created_at: "2026-04-20T00:00:00Z",
  ...overrides,
});

const makeRun = (overrides: Partial<any> = {}): any => ({
  id: "run-1",
  business_id: "biz-1",
  version_id: null,
  intent: "new-base-model",
  status: "running",
  databricks_run_id: 42,
  vibe_session_id: null,
  run_page_url: null,
  progress_percent: 30,
  progress_message: "Working...",
  error_message: "",
  parameters_json: null,
  vibe_instructions_text: "",
  vibe_instructions_volume_path: "",
  started_at: "2026-04-20T12:00:00Z",
  completed_at: null,
  created_at: "2026-04-20T11:59:00Z",
  ...overrides,
});

/** Mirrors `HeaderBreadcrumbs` (`sidebar-layout.tsx`) rendering: a link
 *  per crumb that has a `to`, plain text for the active (last) crumb. */
function BreadcrumbBar() {
  const items = useBreadcrumbItems();
  if (items.length === 0) return <div data-testid="breadcrumb-empty" />;
  return (
    <nav data-testid="breadcrumb-bar">
      {items.map((item, i) => (
        <span key={i}>
          {item.to ? (
            <a
              data-testid={`crumb-link-${i}`}
              href={item.to.replace(
                "$businessId",
                (item.params as any)?.businessId ?? "",
              )}
            >
              {item.label}
            </a>
          ) : (
            <span data-testid={`crumb-text-${i}`}>{item.label}</span>
          )}
        </span>
      ))}
    </nav>
  );
}

function withBreadcrumbs(children: ReactNode) {
  return (
    <BreadcrumbProvider>
      <BreadcrumbBar />
      {children}
    </BreadcrumbProvider>
  );
}

function makeClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000 },
      mutations: { retry: false },
    },
  });
}

describe("Runs list breadcrumbs (Track 6 item 3)", () => {
  it("renders [business.name, Runs] with the business crumb linking to /businesses/$businessId", async () => {
    businessData = makeBusiness({ name: "Acme" });
    renderWithRouter(withBreadcrumbs(<BusinessDetail businessId="biz-1" />), {
      queryClient: makeClient(),
    });

    await waitFor(() => {
      expect(screen.getByTestId("crumb-link-0")).toHaveTextContent("Acme");
    });
    expect(screen.getByTestId("crumb-link-0")).toHaveAttribute(
      "href",
      "/businesses/biz-1",
    );
    expect(screen.getByTestId("crumb-text-1")).toHaveTextContent("Runs");
  });

  it("still returns to the business for an industry (kind='industry')", async () => {
    businessData = makeBusiness({ name: "Food & Beverage", kind: "industry" });
    renderWithRouter(withBreadcrumbs(<BusinessDetail businessId="biz-2" />), {
      queryClient: makeClient(),
    });

    await waitFor(() => {
      expect(screen.getByTestId("crumb-link-0")).toHaveTextContent(
        "Food & Beverage",
      );
    });
    expect(screen.getByTestId("crumb-link-0")).toHaveAttribute(
      "href",
      "/businesses/biz-2",
    );
  });
});

describe("Run detail breadcrumbs (Track 6 item 3)", () => {
  // RunDetail's children (LineageCard, RunHierarchyPipeline, ArtifactsTab)
  // hit the raw fetch client for their own endpoints - stub every path so
  // they resolve empty instead of erroring, mirroring run-detail.test.tsx.
  function stubAllFetch() {
    vi.stubGlobal(
      "fetch",
      vi.fn(async () => ({ ok: true, status: 200, json: async () => [] })),
    );
  }

  it("renders the three-crumb trail [business, Runs, <Intent> run]", async () => {
    businessData = makeBusiness({ name: "Acme" });
    runData = makeRun({ intent: "new-base-model" });
    stubAllFetch();

    renderWithRouter(
      withBreadcrumbs(<RunDetail businessId="biz-1" runId="run-1" />),
      { queryClient: makeClient() },
    );

    await waitFor(() => {
      expect(screen.getByTestId("crumb-link-0")).toHaveTextContent("Acme");
    });
    expect(screen.getByTestId("crumb-link-0")).toHaveAttribute(
      "href",
      "/businesses/biz-1",
    );
    expect(screen.getByTestId("crumb-link-1")).toHaveTextContent("Runs");
    expect(screen.getByTestId("crumb-link-1")).toHaveAttribute(
      "href",
      "/businesses/biz-1/runs",
    );
    expect(screen.getByTestId("crumb-text-2")).toHaveTextContent(/run$/i);
  });
});
