import { describe, it, expect, vi, afterEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactNode } from "react";

vi.mock("@tanstack/react-router", () => ({
  Link: ({ children, ...rest }: { children: ReactNode } & Record<string, unknown>) => {
    const { to, search, params, ...passthrough } = rest as {
      to?: string;
      search?: Record<string, unknown>;
      params?: Record<string, unknown>;
    } & Record<string, unknown>;
    return (
      <a
        href={to as string}
        data-search={JSON.stringify(search ?? {})}
        data-params={JSON.stringify(params ?? {})}
        {...(passthrough as Record<string, unknown>)}
      >
        {children}
      </a>
    );
  },
}));

import { NextVibesCard } from "@/components/next-vibes/next-vibes-card";

function withQuery(ui: ReactNode) {
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return <QueryClientProvider client={qc}>{ui}</QueryClientProvider>;
}

// The card now reads structured agent VibeInput rows: item ids are durable
// VibeInput uuids (not synthetic nv-N), and ALL finding categories surface
// (static-analysis, priority-remediation, and other-known-issue).
const SAMPLE_PAYLOAD = {
  model_version_id: "mv-1",
  summary: "",
  confidence_score: 0.71,
  status: "needs_work",
  items: [
    {
      id: "11111111-1111-1111-1111-111111111111",
      title: "remove_fk for customer.profile",
      description: "Investigate and resolve 36 unlinked _id columns.",
      priority: "high",
    },
    {
      id: "22222222-2222-2222-2222-222222222222",
      title: "Static analysis: unlinked_fk",
      description: "Column region_id looks like an FK.",
      priority: "low",
    },
    {
      id: "33333333-3333-3333-3333-333333333333",
      title: "Other known issue",
      description: "sale.order_line description is empty.",
      priority: "low",
    },
  ],
};

describe("NextVibesCard", () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("renders agent-suggested next vibes with item count and confidence/status", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        json: async () => SAMPLE_PAYLOAD,
      }),
    );

    render(
      withQuery(<NextVibesCard businessId="b1" modelVersionId="mv-1" />),
    );

    await waitFor(() =>
      expect(
        screen.getByText("remove_fk for customer.profile"),
      ).toBeInTheDocument(),
    );

    // Title shows item count — ALL findings surface (3).
    expect(
      screen.getByText(/Suggested next vibes \(3\)/),
    ).toBeInTheDocument();

    // Status + confidence are rendered.
    expect(screen.getByText(/needs_work/)).toBeInTheDocument();
    expect(screen.getByText(/71%/)).toBeInTheDocument();

    // Every finding category renders its title + description, not just
    // priority-remediation — static-analysis and other-known-issue too.
    expect(screen.getByText("Static analysis: unlinked_fk")).toBeInTheDocument();
    expect(screen.getByText("Other known issue")).toBeInTheDocument();
    expect(
      screen.getByText(/Investigate and resolve 36 unlinked _id columns/),
    ).toBeInTheDocument();
    expect(
      screen.getByText(/sale.order_line description is empty/),
    ).toBeInTheDocument();

    // Priority badge is intentionally suppressed for now (an internal tracker item).
    expect(screen.queryByText("must do")).not.toBeInTheDocument();
    expect(screen.queryByText("optional")).not.toBeInTheDocument();

    // "Use in vibe iterate" link points at the new-run form.
    const link = screen.getByRole("link", { name: /Use in vibe iterate/ });
    expect(link).toBeInTheDocument();
    expect(link.getAttribute("href")).toBe("/businesses/$businessId/runs/new");
    const params = JSON.parse(link.getAttribute("data-params") || "{}");
    expect(params).toMatchObject({ businessId: "b1" });
    const search = JSON.parse(link.getAttribute("data-search") || "{}");
    expect(search).toMatchObject({
      operationType: "vibe modeling of version",
    });
  });

  it("renders nothing when the agent returned no items", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        json: async () => ({
          model_version_id: "mv-1",
          items: [],
          summary: "",
          confidence_score: null,
          status: "",
        }),
      }),
    );

    const { container } = render(
      withQuery(<NextVibesCard businessId="b1" modelVersionId="mv-1" />),
    );

    await waitFor(() => {
      expect(container.querySelector('[data-testid="next-vibes-card"]')).toBeNull();
    });

    expect(screen.queryByText(/Suggested next vibes/)).not.toBeInTheDocument();
  });
});
