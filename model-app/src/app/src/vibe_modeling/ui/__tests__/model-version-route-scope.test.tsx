/**
 * Model-version route — `(version, scope)` URL contract.
 *
 * the model-versioning work: the canonical URL is `/businesses/{id}/model/{int}/{scope}`
 * where scope ∈ {ecm, mvm}. This test mounts the route's component
 * directly with both params and asserts the page renders the right
 * scope badge + uppercased scope label in the title block. It also
 * proves the route file's `Route.useParams()` consumer doesn't crash
 * when scope flows through.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";
import { ErrorBoundary } from "react-error-boundary";

let versionsHook: () => unknown = () => ({
  data: [
    {
      id: "v-1-ecm",
      version: 1,
      scope: "ecm",
      deployment_status: "draft",
      status: "completed",
    },
    {
      id: "v-1-mvm",
      version: 1,
      scope: "mvm",
      deployment_status: "deployed",
      status: "completed",
    },
  ],
});
let businessHook: () => unknown = () => ({
  data: { data: { id: "biz-1", name: "Test Biz" } },
});
let modelHook: () => unknown = () => ({
  data: {
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
  },
});
let feedbackHook: () => unknown = () => ({ data: [] });

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListVersionsSuspense: () => versionsHook(),
    useGetBusinessSuspense: () => businessHook(),
    useGetModelSummarySuspense: () => modelHook(),
    useListVibeInputsSuspense: () => feedbackHook(),
    useListVibeInputs: () => feedbackHook(),
    createRun: vi.fn(),
    deleteVersion: vi.fn(),
    getRun: vi.fn(),
    forceResyncVersion: vi.fn(async () => ({ data: {} })),
  };
});

vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return {
    ...actual,
    useSearch: () => ({ tab: "overview" }),
    useNavigate: () => vi.fn(),
    Link: ({ children, ...props }: any) => <a {...props}>{children}</a>,
  };
});

vi.mock("@/components/diagram/diagram-viewer", () => ({
  DiagramViewer: () => <div data-testid="diagram-viewer-stub" />,
}));
vi.mock("@/components/explorer/relationship-analysis", () => ({
  RelationshipAnalysis: () => <div data-testid="relationship-analysis-stub" />,
}));
vi.mock("@/components/explorer/ontology-graph", () => ({
  OntologyGraph: () => <div data-testid="ontology-graph-stub" />,
}));
vi.mock("@/components/artifacts/artifacts-tab", () => ({
  ArtifactsTab: () => <div data-testid="artifacts-tab-stub" />,
}));
vi.mock("@/components/feedback/feedback-list", () => ({
  FeedbackList: () => <div data-testid="feedback-list-stub" />,
}));
vi.mock("@/components/next-vibes/next-vibes-card", () => ({
  NextVibesCard: () => <div data-testid="next-vibes-card-stub" />,
}));
vi.mock("@/components/runs/launch-run-dialog", () => ({
  LaunchRunDialog: () => <div data-testid="launch-run-dialog-stub" />,
}));

import { ModelVersionPage } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.index";

beforeEach(() => {
  vi.stubGlobal(
    "fetch",
    vi.fn(async () => ({ ok: true, status: 200, json: async () => ({}) })),
  );
});

afterEach(() => {
  vi.unstubAllGlobals();
});

function makeClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000 },
      mutations: { retry: false },
    },
  });
}

function renderWithScope(scope: string) {
  return render(
    <QueryClientProvider client={makeClient()}>
      <ErrorBoundary fallbackRender={({ error }) => <div role="alert">Error: {String(error)}</div>}>
        <Suspense fallback={<div data-testid="suspense-fallback" />}>
          <ModelVersionPage businessId="biz-1" version="1" scope={scope} />
        </Suspense>
      </ErrorBoundary>
    </QueryClientProvider>,
  );
}

describe("ModelVersion route — scope param", () => {
  it("renders the ECM scope badge when scope='ecm'", async () => {
    renderWithScope("ecm");
    // The header title block surfaces the scope as an uppercase badge
    // alongside "Test Model v1".
    await waitFor(() => {
      expect(screen.getByText("ECM")).toBeInTheDocument();
    });
    expect(screen.queryByText("MVM")).not.toBeInTheDocument();
  });

  it("renders the MVM scope badge when scope='mvm'", async () => {
    renderWithScope("mvm");
    await waitFor(() => {
      expect(screen.getByText("MVM")).toBeInTheDocument();
    });
    expect(screen.queryByText("ECM")).not.toBeInTheDocument();
  });

  it("picks the (version, scope) row from the versions list when both share a number", async () => {
    // Both rows share version=1 — the page must select by scope, not just
    // version number, so the deployment_status badge reflects the right one.
    renderWithScope("mvm");
    // The MVM row had deployment_status="deployed"; that maps to the
    // user-facing "Installed" badge on the overview command strip.
    await waitFor(() => {
      expect(screen.getByText(/^installed$/i)).toBeInTheDocument();
    });
  });
});
