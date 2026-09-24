/**
 * New Run form — 0.6.6 run-form fixes.
 *
 *  - E-10: the debounced POST /runs/validate body carries `input_ids` /
 *    `next_vibe_ids` for vibe intents, so vibe-new-ecm-mvm's Gate B can
 *    compile `vibe_instructions` server-side (otherwise it's a permanent
 *    blocker that disables Start Run).
 *  - E-01: switching Operation Type and back preserves the base-version
 *    selection — and with it the durable `selected_for_run` Vibe Inputs —
 *    instead of silently dropping the count to 0.
 *  - U-05: the File-Path business-context mode offers a Volume browser whose
 *    selection populates the path input (manual entry stays as fallback).
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";
import { Suspense } from "react";

const MVM_VERSION = {
  id: "v-2-mvm",
  version: 2,
  scope: "mvm",
  status: "completed",
  is_base: false,
  confidence_score: null,
  vibe_instructions: "",
  created_at: "2026-04-21T12:00:00Z",
  uc_catalog: "vibe_modeling",
  deployment_status: "draft",
};
const ECM_VERSION = {
  id: "v-1-ecm",
  version: 1,
  scope: "ecm",
  status: "completed",
  is_base: true,
  confidence_score: null,
  vibe_instructions: "",
  created_at: "2026-04-20T12:00:00Z",
  uc_catalog: "vibe_modeling",
  deployment_status: "draft",
};

const anchored = (id: string, selected: boolean) => ({
  id,
  text: `rule ${id}`,
  priority: "medium",
  anchor: { level: "model_wide", path: [] },
  consumed: false,
  selected_for_run: selected,
});

// Mutable per-test fixtures — the api mock reads these live.
let VERSIONS: unknown[] = [MVM_VERSION, ECM_VERSION];
let INPUTS_BY_VERSION: Record<string, unknown[]> = {};

const createRunMock = vi.fn(async () => ({ data: { id: "run-new" } }));
const validateRunMock = vi.fn(async () => ({ data: { blockers: [], warnings: [] } }));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => ({
      data: { id: "biz-1", name: "Acme Corp", description: "Retail blurb." },
    }),
    useListVersionsSuspense: () => ({ data: VERSIONS }),
    useListVibeInputs: (opts: any) => {
      const vid = opts?.params?.version_id as string | undefined;
      const rows = (vid && INPUTS_BY_VERSION[vid]) || [];
      return {
        data: opts?.query?.select ? opts.query.select({ data: rows }) : rows,
      };
    },
    createRun: (...args: unknown[]) => (createRunMock as any)(...args),
    validateRun: (...args: unknown[]) => (validateRunMock as any)(...args),
  };
});

vi.mock("@/components/ui/markdown-toolbar", () => ({ MarkdownToolbar: () => null }));
vi.mock("@/components/runs/deployment-catalog-picker", () => ({
  DeploymentCatalogPicker: ({ value, onChange }: any) => (
    <input data-testid="catalog-picker" value={value} onChange={(e) => onChange(e.target.value)} />
  ),
}));
// Stand in for the real VolumePicker (which has its own test) so U-05 can
// assert the wiring: opening it and selecting a path must populate the field.
vi.mock("@/components/import/volume-picker", () => ({
  VolumePicker: ({ open, onSelect }: any) =>
    open ? (
      <button
        type="button"
        data-testid="mock-volume-pick"
        onClick={() => onSelect("/Volumes/cat/sch/vibes/ctx.json")}
      >
        pick
      </button>
    ) : null,
}));

async function renderRunsNew(searchString: string) {
  const { Route: RunsNewRoute } = await import(
    "@/routes/_sidebar/businesses.$businessId.runs.new"
  );
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const sidebarRoute = createRoute({
    getParentRoute: () => rootRoute,
    id: "/_sidebar",
    component: () => <Outlet />,
  });
  const runsNewClone = createRoute({
    getParentRoute: () => sidebarRoute,
    path: "/businesses/$businessId/runs/new",
    component: RunsNewRoute.options.component as any,
    validateSearch: RunsNewRoute.options.validateSearch as any,
  });
  const inputsRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/model/$version/$scope/inputs",
    component: () => <div data-testid="inputs-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      sidebarRoute.addChildren([runsNewClone]),
      inputsRoute,
    ]),
    history: createMemoryHistory({
      initialEntries: [`/businesses/biz-1/runs/new${searchString}`],
    }),
    defaultPendingMs: 0,
  });
  const qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000 },
      mutations: { retry: false },
    },
  });
  return render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={<div data-testid="suspense-fallback" />}>
        <RouterProvider router={router} />
      </Suspense>
    </QueryClientProvider>,
  );
}

async function pickOperationType(label: RegExp) {
  const trigger = screen.getByRole("combobox", { name: "Operation Type" });
  await act(async () => {
    fireEvent.click(trigger);
  });
  const option = await screen.findByRole("option", { name: label });
  await act(async () => {
    fireEvent.click(option);
  });
}

beforeEach(() => {
  VERSIONS = [MVM_VERSION, ECM_VERSION];
  INPUTS_BY_VERSION = {};
  createRunMock.mockClear();
  validateRunMock.mockClear();
});
afterEach(() => vi.restoreAllMocks());

describe("E-10 — validate body carries input_ids for vibe intents", () => {
  it("sends input_ids + next_vibe_ids to /runs/validate for vibe-new-ecm-mvm", async () => {
    // The ECM base version (the only eligible source for the combined intent)
    // has two selected + anchored inputs.
    INPUTS_BY_VERSION = {
      "v-1-ecm": [anchored("vi-1", true), anchored("vi-2", true), anchored("vi-3", false)],
    };
    await renderRunsNew("?businessId=biz-1&operationType=vibe-new-ecm-mvm");

    await waitFor(() => {
      expect(screen.queryByText("Compiled instructions preview")).not.toBeNull();
    });

    // The validate effect debounces 300ms; wait for it to fire with the ids.
    await waitFor(
      () => {
        expect(validateRunMock).toHaveBeenCalled();
        const body = ((validateRunMock.mock.calls.at(-1) as unknown[] | undefined)?.[1] ?? {}) as Record<string, unknown>;
        expect(body.input_ids).toEqual(["vi-1", "vi-2"]);
        expect(body.next_vibe_ids).toEqual([]);
      },
      { timeout: 2000 },
    );
  });
});

describe("E-01 — Operation Type round-trip preserves the selection", () => {
  it("restores the base version (and its selected inputs) after switch and back", async () => {
    // MVM v2 holds two selected inputs; ECM v1 holds none.
    INPUTS_BY_VERSION = {
      "v-2-mvm": [anchored("vi-a", true), anchored("vi-b", true)],
      "v-1-ecm": [],
    };
    // Default op (no URL param, versions exist) is vibe-iterate → MVM v2.
    await renderRunsNew("?businessId=biz-1");

    await waitFor(() => {
      expect(screen.getByTestId("vibe-inputs-summary")).toHaveTextContent(
        "2 vibe inputs selected",
      );
    });

    // Switch to the combined intent — only ECM is eligible, so the picker
    // moves to ECM v1 (0 selected). Dropping the count here is defensible.
    await pickOperationType(/Vibe ECM \+ MVM/i);
    await waitFor(() => {
      expect(screen.getByTestId("vibe-inputs-summary")).toHaveTextContent(
        "0 vibe inputs selected",
      );
    });

    // Switch back to Vibe Modeling — the prior MVM v2 selection must return,
    // not silently stay at 0.
    await pickOperationType(/^Vibe Modeling$/i);
    await waitFor(() => {
      expect(screen.getByTestId("vibe-inputs-summary")).toHaveTextContent(
        "2 vibe inputs selected",
      );
    });
  });
});

describe("U-05 — File-Path business context has a Volume picker", () => {
  it("renders a Browse button and populates the path input on selection", async () => {
    // No versions → default op is new base model, which owns the File-Path
    // business-context toggle.
    VERSIONS = [];
    await renderRunsNew("?businessId=biz-1");

    // Switch business context to File-Path mode.
    const filePathToggle = await screen.findByRole("button", { name: /^File Path$/i });
    await act(async () => {
      fireEvent.click(filePathToggle);
    });

    const browseBtn = await screen.findByTestId("business-context-browse");
    expect(browseBtn).toBeInTheDocument();

    // Open the picker and select a file — the path input takes the value.
    await act(async () => {
      fireEvent.click(browseBtn);
    });
    const pick = await screen.findByTestId("mock-volume-pick");
    await act(async () => {
      fireEvent.click(pick);
    });

    await waitFor(() => {
      const input = document.querySelector(
        'input[placeholder*="business_context.json"]',
      ) as HTMLInputElement | null;
      expect(input?.value).toBe("/Volumes/cat/sch/vibes/ctx.json");
    });
  });
});
