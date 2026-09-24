/**
 * Business Context card (Track 8 item 4) - renders name + business.description
 * + sector, never the retired `context_json`-derived fields. Never
 * header-only when a description is present (the TerraNova repro).
 */
import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

let sectorsData: Array<{ id: string; name: string }> = [];

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListSectorsSuspense: () => ({ data: sectorsData }),
  };
});

import { ContextSection } from "@/routes/_sidebar/businesses.$businessId.explorer";

function renderCard(business: { name: string; description?: string | null; sector_id?: string | null }) {
  const qc = new QueryClient();
  return render(
    <QueryClientProvider client={qc}>
      <ContextSection business={business} kindLabel="Business" />
    </QueryClientProvider>,
  );
}

describe("ContextSection (Business Context card)", () => {
  it("renders the name, description, and sector - never header-only", () => {
    sectorsData = [{ id: "sec-1", name: "Mining" }];
    renderCard({
      name: "TerraNova",
      description: "An 811-char summary of the mining operation...",
      sector_id: "sec-1",
    });
    expect(screen.getByText("TerraNova")).toBeInTheDocument();
    expect(
      screen.getByText("An 811-char summary of the mining operation..."),
    ).toBeInTheDocument();
    expect(screen.getByText("Mining")).toBeInTheDocument();
  });

  it("omits the description and sector lines when absent, but still shows the name", () => {
    sectorsData = [];
    renderCard({ name: "Empty Co", description: "", sector_id: null });
    expect(screen.getByText("Empty Co")).toBeInTheDocument();
    expect(screen.queryByText("Description")).toBeNull();
    expect(screen.queryByText("Sector")).toBeNull();
  });

  it("never renders any context_json-derived field", () => {
    sectorsData = [];
    renderCard({ name: "Acme", description: "Acme summary", sector_id: null });
    expect(screen.queryByText("Industry Alignment")).toBeNull();
    expect(screen.queryByText("Core Business Processes")).toBeNull();
    expect(screen.queryByText("Vibe Modeling Instructions")).toBeNull();
    expect(screen.queryByText("Model Conventions")).toBeNull();
  });
});
