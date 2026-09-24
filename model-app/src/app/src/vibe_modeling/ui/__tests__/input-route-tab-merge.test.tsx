/**
 * Input-review route ?tab= + shell wiring contract (Track 6 item 1, 1B).
 *
 * The input card is now backed by the full ModelTabsShell with a router-owned
 * `?tab=` param. This locks 1B's own contributions:
 *   - `tab` defaults to the anchor-focused Diagram and is validated
 *   - switching tabs MERGES the search (preserves `from`) - a replace-shape
 *     navigation would silently drop `from` and break the back link
 *   - the shell is handed showLifecycleActions=false and NO versionActions
 *     (a review surface offers no run/install or delete), plus the input's
 *     focusAnchor.
 *
 * The shell is stubbed so this test isolates the route's wiring; the shell's
 * own behavior (full tab set, warm gating, single-home feedback) is covered by
 * model-tabs-shell.test.tsx.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const navigateMock = vi.fn();
const searchState = { from: "feedback" as const, tab: "diagram" as const };
const shellProps: any = {};

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetVibeInputSuspense: () => ({
      data: { id: "in-1", text: "hi", origin: "user", priority: "medium", status: "active", anchor: { level: "domain", domain_name: "sales", path: ["sales"] } },
    }),
    useUpdateVibeInput: () => ({ mutate: vi.fn() }),
  };
});

vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>("@tanstack/react-router");
  return {
    ...actual,
    useNavigate: () => navigateMock,
    createFileRoute: () => (opts: any) => ({
      ...opts,
      useParams: () => ({ businessId: "biz-1", version: "1", scope: "ecm", inputId: "in-1" }),
      useSearch: () => searchState,
    }),
    Link: ({ children, ...props }: any) => <a {...props}>{children}</a>,
  };
});

// Stub the shell: capture the props the route hands it and expose a button
// that fires onTabChange so we can exercise the route's setTab directly
// (no Radix tab-click flakiness).
vi.mock("@/components/model/model-tabs-shell", () => ({
  ModelTabsShell: (props: any) => {
    Object.assign(shellProps, props);
    return (
      <button data-testid="go-overview" onClick={() => props.onTabChange("overview")}>
        shell
      </button>
    );
  },
}));
vi.mock("@/components/vibe-inputs/input-markdown-editor-dialog", () => ({
  InputMarkdownEditorDialog: () => <div />,
}));

import { Route } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.inputs.$inputId";

const InputDetailsRoute = (Route as any).component as () => React.ReactElement;

function makeClient() {
  return new QueryClient({
    defaultOptions: { queries: { retry: false, staleTime: 30_000 }, mutations: { retry: false } },
  });
}

function renderRoute() {
  return render(
    <QueryClientProvider client={makeClient()}>
      <InputDetailsRoute />
    </QueryClientProvider>,
  );
}

afterEach(() => {
  vi.clearAllMocks();
  for (const k of Object.keys(shellProps)) delete shellProps[k];
});

describe("input route ?tab= + shell wiring", () => {
  it("preserves `from` when switching tabs (merges, not replaces)", () => {
    renderRoute();
    fireEvent.click(screen.getByTestId("go-overview"));
    expect(navigateMock).toHaveBeenCalledTimes(1);
    const call = navigateMock.mock.calls[0][0];
    expect(typeof call.search).toBe("function");
    expect(call.replace).toBe(true);
    // Applying the functional updater to the current search keeps `from`.
    const merged = call.search({ from: "feedback", tab: "diagram" });
    expect(merged).toEqual({ from: "feedback", tab: "overview" });
  });

  it("hands the shell a review-surface config: no delete, no lifecycle actions", () => {
    renderRoute();
    expect(shellProps.showLifecycleActions).toBe(false);
    expect(shellProps.versionActions).toBeUndefined();
    // The input's anchor domain drives the focused diagram.
    expect(shellProps.focusAnchor?.domain).toBe("sales");
    // Router-owned tab flows through from the validated search.
    expect(shellProps.tab).toBe("diagram");
  });
});

describe("input route validateSearch", () => {
  const validate = (Route as any).options?.validateSearch ?? (Route as any).validateSearch;

  it("defaults tab to diagram and preserves from", () => {
    expect(validate({ from: "feedback" })).toEqual({ from: "feedback", tab: "diagram" });
  });

  it("keeps a valid tab and drops a non-feedback from", () => {
    expect(validate({ tab: "overview", from: "elsewhere" })).toEqual({ tab: "overview" });
  });

  it("coerces an invalid tab back to diagram", () => {
    expect(validate({ tab: "bogus" })).toEqual({ tab: "diagram" });
  });
});
