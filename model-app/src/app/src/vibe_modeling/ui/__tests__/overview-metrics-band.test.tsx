/**
 * Render tests for the overview metrics band (Direction A). Asserts:
 *   - one cell per area (Change / Quality / Review / Size+effort),
 *   - a hero + supporting figures render per area,
 *   - the T11 evolution/next-vibe wiring renders real values: a confidence
 *     delta chip + version sparkline, the open-issue severity split, the
 *     next_vibes Quality Score, Δ-open-issues, and tokens/hours effort,
 *   - the ±5% colour rule on the confidence delta chip,
 *   - "??" degradation surfaces on an ECM (no confidence), a base version
 *     (no predecessor → no sparkline/delta/Δ-issues), and when evolution is
 *     absent (tokens/hours unknown),
 *   - the band exposes action links into the Feedback surface.
 */
import { describe, expect, it } from "vitest";
import { screen, within } from "@testing-library/react";
import { MetricsBand } from "@/components/overview/metrics-band";
import {
  deriveOverviewMetrics,
  type OverviewEvolution,
  type OverviewNextVibe,
} from "@/components/overview/metrics";
import { renderWithRouter } from "./helpers/router-wrapper";

const MVM = {
  version: 2,
  domain_count: 6,
  subdomain_count: 12,
  product_count: 40,
  attribute_count: 320,
  fk_count: 55,
  confidence_score: 0.82,
  review_pct: 0.34,
  reviewed_count: 14,
  review_needed_count: 41,
  domains: [
    { change_status: "new" },
    { change_status: "modified" },
    { change_status: "deleted" },
    { change_status: "unchanged" },
  ],
};

const EVOLUTION: OverviewEvolution = {
  has_confidence: true,
  has_predecessor: true,
  quality: {
    confidence_score: 82,
    error_count: 3,
    warning_count: 5,
    info_count: 2,
  },
  change: {
    confidence_delta: 7,
    errors_delta: -4,
    warnings_delta: 1,
    model_touched_pct: 42,
    products_added: 4,
    products_modified: 3,
    products_removed: 8,
    version_history: [
      { version: "v1", confidence: 70 },
      { version: "v2", confidence: 82 },
    ],
  },
  effort: {
    estimated_input_tokens: 1_200_000,
    estimated_output_tokens: 300_000,
    duration_hours: 1.5,
  },
};

// quality_score is 0..1 (mean of VibeInput confidence_scores), rendered ×100.
const NEXT_VIBE: OverviewNextVibe = { has_data: true, quality_score: 0.88 };

function renderBand(
  model: any,
  extras?: {
    feedbackCount?: number;
    runsCount?: number;
    evolution?: OverviewEvolution | null;
    nextVibe?: OverviewNextVibe | null;
  },
) {
  return renderWithRouter(
    <MetricsBand
      metrics={deriveOverviewMetrics(model, extras)}
      businessId="b1"
      version="2"
      scope="mvm"
    />,
  );
}

describe("MetricsBand — four areas", () => {
  it("renders one cell per area", async () => {
    renderBand(MVM, { feedbackCount: 7, runsCount: 3, evolution: EVOLUTION });
    expect(await screen.findByTestId("overview-metrics-band")).toBeInTheDocument();
    expect(screen.getByTestId("metric-change")).toBeInTheDocument();
    expect(screen.getByTestId("metric-quality")).toBeInTheDocument();
    expect(screen.getByTestId("metric-review")).toBeInTheDocument();
    expect(screen.getByTestId("metric-size-effort")).toBeInTheDocument();
  });

  it("Quality shows the confidence hero out of 100", async () => {
    renderBand(MVM, { evolution: EVOLUTION });
    const cell = await screen.findByTestId("metric-quality");
    expect(within(cell).getByText("82")).toBeInTheDocument();
    expect(within(cell).getByText(/\/ 100 confidence/)).toBeInTheDocument();
  });

  it("Review shows the % hero, reviewed/total and feedback supporting figures", async () => {
    renderBand(MVM, { feedbackCount: 7 });
    const cell = await screen.findByTestId("metric-review");
    expect(within(cell).getByText("34%")).toBeInTheDocument();
    expect(within(cell).getByText(/products/)).toBeInTheDocument();
    expect(within(cell).getByText(/feedback/)).toBeInTheDocument();
    expect(within(cell).getByText("14")).toBeInTheDocument();
    expect(within(cell).getByText("7")).toBeInTheDocument();
  });

  it("Change shows the per-domain add/change/remove supporting line", async () => {
    renderBand(MVM, { evolution: EVOLUTION });
    const cell = await screen.findByTestId("metric-change");
    expect(within(cell).getByText(/\+1 added/)).toBeInTheDocument();
    expect(within(cell).getByText(/~1 changed/)).toBeInTheDocument();
    expect(within(cell).getByText(/−1 removed/)).toBeInTheDocument();
  });

  it("Change shows the % model touched hero from evolution (no ?? when present)", async () => {
    renderBand(MVM, { evolution: EVOLUTION });
    const cell = await screen.findByTestId("metric-change");
    expect(within(cell).getByText("42%")).toBeInTheDocument();
    expect(within(cell).getByText("touched")).toBeInTheDocument();
    expect(within(cell).queryAllByTestId("metric-unknown")).toHaveLength(0);
  });

  it("Change shows the muted per-product breakdown next to % touched", async () => {
    renderBand(MVM, { evolution: EVOLUTION });
    const cell = await screen.findByTestId("metric-change");
    const breakdown = within(cell).getByTestId("metric-change-product-breakdown");
    expect(breakdown).toHaveTextContent("+4 · ~3 · −8");
    // Small + muted, no new colour tokens.
    expect(breakdown.className).toMatch(/text-xs/);
    expect(breakdown.className).toMatch(/text-muted-foreground/);
  });

  it("hides the per-product breakdown on a base version (no predecessor)", async () => {
    // No domain carries a change status → base version, change area collapses.
    const base = {
      ...MVM,
      domains: [{ change_status: "unchanged" }, { change_status: "unchanged" }],
    };
    renderBand(base);
    const cell = await screen.findByTestId("metric-change");
    expect(
      within(cell).queryByTestId("metric-change-product-breakdown"),
    ).not.toBeInTheDocument();
  });

  it("Change degrades % touched to ?? when evolution omits model_touched_pct", async () => {
    renderBand(MVM, {
      evolution: { ...EVOLUTION, change: { ...EVOLUTION.change, model_touched_pct: null } },
    });
    const cell = await screen.findByTestId("metric-change");
    expect(within(cell).getAllByTestId("metric-unknown").length).toBeGreaterThan(0);
  });

  it("suppresses the per-domain change line when % touched is uncomputable (finding #5)", async () => {
    // hasPredecessor is true (domains carry statuses), but evolution recorded no
    // model_touched_pct → "??". A concrete "~N changed domains" count must NOT
    // sit beside the uncomputable hero.
    renderBand(MVM, {
      evolution: { ...EVOLUTION, change: { ...EVOLUTION.change, model_touched_pct: null } },
    });
    const cell = await screen.findByTestId("metric-change");
    expect(within(cell).queryByText(/changed/)).not.toBeInTheDocument();
    expect(within(cell).queryByText(/domains/)).not.toBeInTheDocument();
  });

  it("Size+effort shows the domains·subdomains·products trio and columns/FKs", async () => {
    renderBand(MVM, { runsCount: 3, evolution: EVOLUTION });
    const cell = await screen.findByTestId("metric-size-effort");
    expect(within(cell).getByText("6")).toBeInTheDocument();
    expect(within(cell).getByText("12")).toBeInTheDocument();
    expect(within(cell).getByText("40")).toBeInTheDocument();
    expect(within(cell).getByText("320")).toBeInTheDocument();
    expect(within(cell).getByText("55")).toBeInTheDocument();
    expect(within(cell).getByText(/runs/)).toBeInTheDocument();
  });

  it("exposes action links into the Feedback surface", async () => {
    renderBand(MVM, { evolution: EVOLUTION });
    expect(await screen.findByText("View issues")).toBeInTheDocument();
    expect(screen.getByText(/Resume review|Review complete/)).toBeInTheDocument();
  });
});

describe("MetricsBand — T11 real values", () => {
  it("renders the confidence delta chip and version sparkline", async () => {
    renderBand(MVM, { evolution: EVOLUTION });
    const cell = await screen.findByTestId("metric-quality");
    expect(within(cell).getByTestId("quality-sparkline")).toBeInTheDocument();
    const delta = within(cell).getByTestId("metric-delta");
    // +7 is above +5 → good/green tone.
    expect(delta).toHaveTextContent("+7");
    expect(delta.className).toMatch(/text-success/);
  });

  it("colours the confidence delta red when it drops below −5", async () => {
    renderBand(MVM, {
      evolution: {
        ...EVOLUTION,
        change: { ...EVOLUTION.change, confidence_delta: -8 },
      },
    });
    const cell = await screen.findByTestId("metric-quality");
    const delta = within(cell).getByTestId("metric-delta");
    expect(delta).toHaveTextContent("−8");
    expect(delta.className).toMatch(/text-destructive/);
  });

  it("renders the open-issue total + severity split", async () => {
    renderBand(MVM, { evolution: EVOLUTION });
    const cell = await screen.findByTestId("metric-quality");
    const issues = within(cell).getByTestId("quality-open-issues");
    expect(issues).toHaveTextContent("10 open");
    expect(issues).toHaveTextContent("3 high");
    expect(issues).toHaveTextContent("5 med");
    expect(issues).toHaveTextContent("2 low");
  });

  it("renders the next_vibes Quality Score when seeded", async () => {
    renderBand(MVM, { evolution: EVOLUTION, nextVibe: NEXT_VIBE });
    const cell = await screen.findByTestId("metric-quality");
    expect(within(cell).getByTestId("quality-next-vibes-score")).toHaveTextContent(
      "88",
    );
  });

  it("renders Δ open issues from the evolution progression", async () => {
    renderBand(MVM, { evolution: EVOLUTION });
    const cell = await screen.findByTestId("metric-change");
    // -4 errors + 1 warning = -3 net; a drop is good → green.
    const delta = within(cell).getByTestId("metric-delta");
    expect(delta).toHaveTextContent("−3");
    expect(delta.className).toMatch(/text-success/);
  });

  it("renders tokens (compacted) and hours from evolution effort", async () => {
    renderBand(MVM, { runsCount: 3, evolution: EVOLUTION });
    const cell = await screen.findByTestId("metric-size-effort");
    expect(within(cell).getByText("1.5M")).toBeInTheDocument();
    expect(within(cell).getByText("1.5h")).toBeInTheDocument();
    expect(within(cell).queryAllByTestId("metric-unknown")).toHaveLength(0);
  });
});

describe("MetricsBand — degradation", () => {
  it("renders ?? for confidence on an ECM model (has_confidence false)", async () => {
    renderBand(MVM, {
      evolution: { ...EVOLUTION, has_confidence: false },
    });
    const cell = await screen.findByTestId("metric-quality");
    expect(within(cell).getByText("Confidence not scored")).toBeInTheDocument();
    expect(within(cell).getAllByTestId("metric-unknown").length).toBeGreaterThan(0);
    // No sparkline / score on an unscored version.
    expect(within(cell).queryByTestId("quality-sparkline")).not.toBeInTheDocument();
  });

  it("hides the segmented change bar on a base version (no predecessor)", async () => {
    renderBand({
      ...MVM,
      domains: [{ change_status: "unchanged" }, { change_status: "unchanged" }],
    });
    const cell = await screen.findByTestId("metric-change");
    expect(within(cell).getByText("Base version")).toBeInTheDocument();
    expect(within(cell).queryByText(/added/)).not.toBeInTheDocument();
    expect(within(cell).queryByText(/removed/)).not.toBeInTheDocument();
  });

  it("hides the sparkline + delta + Δ-issues on an evolution base version", async () => {
    renderBand(MVM, {
      evolution: {
        ...EVOLUTION,
        has_predecessor: false,
      },
    });
    const quality = await screen.findByTestId("metric-quality");
    // Confidence + issues still show, but no trend visuals.
    expect(within(quality).getByText("82")).toBeInTheDocument();
    expect(within(quality).queryByTestId("quality-sparkline")).not.toBeInTheDocument();
    expect(within(quality).queryByTestId("metric-delta")).not.toBeInTheDocument();
    const change = screen.getByTestId("metric-change");
    expect(within(change).queryByTestId("metric-delta")).not.toBeInTheDocument();
    expect(within(change).getAllByTestId("metric-unknown").length).toBeGreaterThan(0);
  });

  it("degrades tokens/hours to ?? when evolution is absent", async () => {
    renderBand(MVM, { runsCount: 3 });
    const size = await screen.findByTestId("metric-size-effort");
    // tokens + hours unknown (2). The Change cell's Δ-issues is also unknown,
    // and % touched — assert specifically on the size cell here.
    expect(within(size).getAllByTestId("metric-unknown").length).toBe(2);
  });

  it("renders absent metrics as the clean em-dash, never the cryptic ??", async () => {
    // ECM (no confidence) + no evolution → Quality confidence/open-issues and
    // Size tokens/hours all degrade. Every degraded figure must read as the
    // Statistics-tab em-dash, not "??".
    renderBand(MVM, { runsCount: 3, evolution: { ...EVOLUTION, has_confidence: false } });
    const unknowns = await screen.findAllByTestId("metric-unknown");
    expect(unknowns.length).toBeGreaterThan(0);
    for (const el of unknowns) {
      expect(el).toHaveTextContent("—");
      expect(el).not.toHaveTextContent("??");
    }
    expect(screen.queryByText("??")).not.toBeInTheDocument();
  });

  it("still renders real CHANGE values (touched %) — degradation copy untouched", async () => {
    // The CHANGE cell shows real data; the em-dash unification must not disturb
    // computable figures.
    renderBand(MVM, { evolution: EVOLUTION });
    const change = await screen.findByTestId("metric-change");
    expect(within(change).getByText("42%")).toBeInTheDocument();
    expect(within(change).getByText("touched")).toBeInTheDocument();
    expect(within(change).queryAllByTestId("metric-unknown")).toHaveLength(0);
    expect(within(change).queryByText("??")).not.toBeInTheDocument();
  });
});
