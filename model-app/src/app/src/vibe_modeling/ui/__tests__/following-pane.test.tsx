/**
 * `<FollowingPane/>` (commit e) — PERF-GATE: the real DiagramViewer is only
 * mounted when the pane is active AND a domain-scoped card is focused; it is
 * scoped via initialDomain and NEVER renders all-domains. Model-wide / no focus
 * → empty state. Inactive → unmounted.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactNode } from "react";
import type { VibeInputOut } from "@/lib/api";

const diagramProps: { current: Record<string, unknown> } = { current: {} };
vi.mock("@/components/diagram/diagram-viewer", () => ({
  DiagramViewer: (props: Record<string, unknown>) => {
    diagramProps.current = props;
    return <div data-testid="diagram-viewer-stub" />;
  },
}));

let userPreferencesHook: () => unknown = () => ({ data: { data: [] }, isLoading: false });

vi.mock("@/lib/api", async (importOriginal) => {
  const actual = await importOriginal<typeof import("@/lib/api")>();
  return {
    ...actual,
    useGetUserPreferences: () => userPreferencesHook(),
  };
});

const navigateSpy = vi.fn();
vi.mock("@tanstack/react-router", async (importOriginal) => {
  const actual = await importOriginal<typeof import("@tanstack/react-router")>();
  return {
    ...actual,
    useNavigate: () => navigateSpy,
  };
});

import { FollowingPane } from "@/components/vibe-inputs/following-pane";

function withQuery(ui: ReactNode) {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return <QueryClientProvider client={qc}>{ui}</QueryClientProvider>;
}

const mk = (over: Partial<VibeInputOut> = {}): VibeInputOut => ({
  id: "vi-1",
  business_id: "biz-1",
  origin: "user",
  author: "",
  text: "t",
  priority: "low",
  confidence_score: null,
  consumed: false,
  status: "active",
  selected_for_run: false,
  deprecated_by: null,
  created_at: "2026-01-01T00:00:00",
  updated_at: "2026-01-01T00:00:00",
  anchor: {
    level: "element",
    domain_name: "Sales",
    path: ["Domain: Sales"],
  },
  ...over,
});

const base = {
  businessId: "biz-1",
  version: "2",
  scope: "ecm",
  domains: [{ name: "Sales", division: "GTM" }],
};

describe("FollowingPane perf gate", () => {
  it("does not mount the diagram when inactive", () => {
    diagramProps.current = {};
    render(withQuery(<FollowingPane {...base} active={false} focusedInput={mk()} />));
    expect(screen.queryByTestId("diagram-viewer-stub")).not.toBeInTheDocument();
  });

  it("does not mount the diagram when no card is focused", () => {
    diagramProps.current = {};
    render(withQuery(<FollowingPane {...base} active focusedInput={null} />));
    expect(screen.queryByTestId("diagram-viewer-stub")).not.toBeInTheDocument();
    expect(screen.getByText(/Focus a domain or product card/)).toBeInTheDocument();
  });

  it("shows the empty state for a Model-wide focus (never all-domains)", () => {
    diagramProps.current = {};
    render(
      withQuery(
        <FollowingPane
          {...base}
          active
          focusedInput={mk({ anchor: { level: "model_wide", path: [] } })}
        />,
      ),
    );
    expect(screen.queryByTestId("diagram-viewer-stub")).not.toBeInTheDocument();
    expect(screen.getByText(/Focus a domain or product card/)).toBeInTheDocument();
  });

  it("mounts the diagram scoped to the focused domain when active + domain focus", () => {
    diagramProps.current = {};
    render(withQuery(<FollowingPane {...base} active focusedInput={mk()} />));
    expect(screen.getByTestId("diagram-viewer-stub")).toBeInTheDocument();
    expect(diagramProps.current.initialDomain).toBe("Sales");
    expect(screen.getByText(/Following · Domain: Sales/)).toBeInTheDocument();
  });
});

describe("FollowingPane - diagram.default_column_mode_focal wiring (item 4C regression)", () => {
  afterEach(() => {
    userPreferencesHook = () => ({ data: { data: [] }, isLoading: false });
  });

  it("does not mount DiagramViewer while the preference query is loading", () => {
    userPreferencesHook = () => ({ data: undefined, isLoading: true });
    diagramProps.current = {};
    render(withQuery(<FollowingPane {...base} active focusedInput={mk()} />));
    expect(screen.queryByTestId("diagram-viewer-stub")).not.toBeInTheDocument();
  });

  it("mounts DiagramViewer with the resolved preference once loaded", () => {
    userPreferencesHook = () => ({
      data: {
        data: [{ key: "diagram.default_column_mode_focal", value: "hide", updated_at: "2026-07-01T00:00:00Z" }],
      },
      isLoading: false,
    });
    diagramProps.current = {};
    render(withQuery(<FollowingPane {...base} active focusedInput={mk()} />));
    expect(screen.getByTestId("diagram-viewer-stub")).toBeInTheDocument();
    expect(diagramProps.current.initialColumnMode).toBe("hide");
  });
});

describe("FollowingPane - onDomainNavigate for related-domain clicks (item 3B)", () => {
  it("hides the toolbar's own domain dropdown and wires onDomainNavigate to route to the domain page", () => {
    navigateSpy.mockClear();
    diagramProps.current = {};
    render(withQuery(<FollowingPane {...base} active focusedInput={mk()} />));
    expect(diagramProps.current.showDomainSelect).toBe(false);
    expect(typeof diagramProps.current.onDomainNavigate).toBe("function");

    (diagramProps.current.onDomainNavigate as (d: string | null) => void)("Inventory");
    expect(navigateSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        to: "/businesses/$businessId/model/$version/$scope/$domainName",
        params: { businessId: "biz-1", version: "2", scope: "ecm", domainName: "Inventory" },
        search: { tab: "diagram" },
      }),
    );
  });

  it("is a no-op when called with null", () => {
    navigateSpy.mockClear();
    diagramProps.current = {};
    render(withQuery(<FollowingPane {...base} active focusedInput={mk()} />));
    (diagramProps.current.onDomainNavigate as (d: string | null) => void)(null);
    expect(navigateSpy).not.toHaveBeenCalled();
  });
});
