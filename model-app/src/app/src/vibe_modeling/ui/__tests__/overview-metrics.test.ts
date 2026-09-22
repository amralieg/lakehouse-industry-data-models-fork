/**
 * Pure-derivation tests for the overview metrics band. The degradation rules
 * (ECM → no confidence; base version → no Change diff / no sparkline / no
 * delta; missing effort → "??") all live in `deriveOverviewMetrics`, so
 * they're asserted here without any rendering. T11 adds the evolution +
 * next-vibe wiring: confidence/delta/sparkline, severity-split open issues,
 * Δ-issues, tokens/hours, and the next_vibes Quality Score.
 */
import { describe, expect, it } from "vitest";
import {
  deriveOverviewMetrics,
  confidenceDeltaTone,
  UNCOMPUTABLE,
  type OverviewEvolution,
  type OverviewNextVibe,
} from "@/components/overview/metrics";

const MVM_V2 = {
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
  no_review_needed_count: 3,
  domains: [
    { change_status: "new" },
    { change_status: "modified" },
    { change_status: "modified" },
    { change_status: "deleted" },
    { change_status: "unchanged" },
    { change_status: "unchanged" },
  ],
};

const EVOLUTION_V2: OverviewEvolution = {
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
    model_touched_pct: 37.5,
    products_added: 4,
    products_modified: 3,
    products_removed: 8,
    version_history: [
      { version: "v1", confidence: 70 },
      { version: "v2", confidence: 82 },
    ],
  },
  effort: {
    estimated_input_tokens: 120_000,
    estimated_output_tokens: 30_000,
    duration_hours: 1.5,
  },
};

const NEXT_VIBE_V2: OverviewNextVibe = {
  has_data: true,
  // 0..1 scale (mean of VibeInput confidence_scores) — scaled to 88 for display.
  quality_score: 0.88,
};

describe("deriveOverviewMetrics — size + effort", () => {
  it("carries exact counts and effort tokens/hours from evolution", () => {
    const m = deriveOverviewMetrics(MVM_V2, {
      runsCount: 3,
      evolution: EVOLUTION_V2,
    });
    expect(m.sizeEffort.domains).toBe(6);
    expect(m.sizeEffort.subdomains).toBe(12);
    expect(m.sizeEffort.products).toBe(40);
    expect(m.sizeEffort.columns).toBe(320);
    expect(m.sizeEffort.foreignKeys).toBe(55);
    expect(m.sizeEffort.runs).toBe(3);
    expect(m.sizeEffort.tokens).toBe(150_000);
    expect(m.sizeEffort.processingHours).toBe(1.5);
  });

  it("degrades tokens + hours to ?? when evolution is absent", () => {
    const m = deriveOverviewMetrics(MVM_V2, { runsCount: 3 });
    expect(m.sizeEffort.tokens).toBe(UNCOMPUTABLE);
    expect(m.sizeEffort.processingHours).toBe(UNCOMPUTABLE);
  });

  it("degrades tokens + hours to ?? when evolution recorded no effort", () => {
    const m = deriveOverviewMetrics(MVM_V2, {
      evolution: { ...EVOLUTION_V2, effort: {} },
    });
    expect(m.sizeEffort.tokens).toBe(UNCOMPUTABLE);
    expect(m.sizeEffort.processingHours).toBe(UNCOMPUTABLE);
  });
});

describe("deriveOverviewMetrics — quality", () => {
  it("uses the evolution confidence (already 0..100) when scored", () => {
    const q = deriveOverviewMetrics(MVM_V2, { evolution: EVOLUTION_V2 }).quality;
    expect(q.confidence).toBe(82);
  });

  it("falls back to the model-summary 0..1 score when evolution is absent", () => {
    expect(deriveOverviewMetrics(MVM_V2).quality.confidence).toBe(82);
  });

  it("degrades confidence to ?? for an ECM model (has_confidence false)", () => {
    const q = deriveOverviewMetrics(MVM_V2, {
      evolution: { ...EVOLUTION_V2, has_confidence: false },
    }).quality;
    expect(q.confidence).toBe(UNCOMPUTABLE);
    expect(q.openIssues).toBe(UNCOMPUTABLE);
    expect(q.severity).toBeNull();
    expect(q.history).toEqual([]);
    expect(q.confidenceDelta).toBeNull();
  });

  it("degrades confidence to ?? (summary fallback) for a null/zero score", () => {
    expect(
      deriveOverviewMetrics({ ...MVM_V2, confidence_score: null }).quality
        .confidence,
    ).toBe(UNCOMPUTABLE);
    expect(
      deriveOverviewMetrics({ ...MVM_V2, confidence_score: 0 }).quality
        .confidence,
    ).toBe(UNCOMPUTABLE);
  });

  it("exposes the confidence delta + per-version sparkline on a predecessor", () => {
    const q = deriveOverviewMetrics(MVM_V2, { evolution: EVOLUTION_V2 }).quality;
    expect(q.confidenceDelta).toBe(7);
    expect(q.history).toEqual([
      { label: "v1", value: 70 },
      { label: "v2", value: 82 },
    ]);
  });

  it("hides the sparkline + delta on a base version (has_predecessor false)", () => {
    const q = deriveOverviewMetrics(MVM_V2, {
      evolution: {
        ...EVOLUTION_V2,
        has_predecessor: false,
        change: { ...EVOLUTION_V2.change, version_history: [{ version: "v1", confidence: 70 }] },
      },
    }).quality;
    expect(q.history).toEqual([]);
    expect(q.confidenceDelta).toBeNull();
    // confidence + issues still show — base versions are still scored.
    expect(q.confidence).toBe(82);
    expect(q.openIssues).toBe(10);
  });

  it("splits open issues into high/med/low severity", () => {
    const q = deriveOverviewMetrics(MVM_V2, { evolution: EVOLUTION_V2 }).quality;
    expect(q.openIssues).toBe(10);
    expect(q.severity).toEqual({ high: 3, medium: 5, low: 2 });
  });

  it("surfaces the next_vibes Quality Score when seeded, else null", () => {
    expect(
      deriveOverviewMetrics(MVM_V2, { nextVibe: NEXT_VIBE_V2 }).quality
        .qualityScore,
    ).toBe(88);
    expect(deriveOverviewMetrics(MVM_V2).quality.qualityScore).toBeNull();
    expect(
      deriveOverviewMetrics(MVM_V2, {
        nextVibe: { has_data: false, quality_score: null },
      }).quality.qualityScore,
    ).toBeNull();
  });
});

describe("confidenceDeltaTone — ±5% rule", () => {
  it("is good above +5, bad below −5, flat within ±5 (and for null)", () => {
    expect(confidenceDeltaTone(7)).toBe("good");
    expect(confidenceDeltaTone(6)).toBe("good");
    expect(confidenceDeltaTone(5)).toBe("flat");
    expect(confidenceDeltaTone(0)).toBe("flat");
    expect(confidenceDeltaTone(-5)).toBe("flat");
    expect(confidenceDeltaTone(-6)).toBe("bad");
    expect(confidenceDeltaTone(null)).toBe("flat");
  });
});

describe("deriveOverviewMetrics — change", () => {
  it("counts domain add/change/remove and marks a predecessor present", () => {
    const c = deriveOverviewMetrics(MVM_V2, { evolution: EVOLUTION_V2 }).change;
    expect(c.hasPredecessor).toBe(true);
    expect(c.domainsAdded).toBe(1);
    expect(c.domainsChanged).toBe(2);
    expect(c.domainsRemoved).toBe(1);
  });

  it("wires % model touched from evolution change.model_touched_pct (rounded)", () => {
    const c = deriveOverviewMetrics(MVM_V2, { evolution: EVOLUTION_V2 }).change;
    expect(c.pctTouched).toBe(38); // 37.5 → 38
  });

  it("degrades % model touched to ?? when evolution didn't record it / no evolution", () => {
    // No evolution payload at all.
    expect(deriveOverviewMetrics(MVM_V2).change.pctTouched).toBe(UNCOMPUTABLE);
    // Evolution present but model_touched_pct null (base version).
    expect(
      deriveOverviewMetrics(MVM_V2, {
        evolution: { ...EVOLUTION_V2, change: { ...EVOLUTION_V2.change, model_touched_pct: null } },
      }).change.pctTouched,
    ).toBe(UNCOMPUTABLE);
  });

  it("wires the per-product change breakdown from evolution change.products_*", () => {
    const c = deriveOverviewMetrics(MVM_V2, { evolution: EVOLUTION_V2 }).change;
    expect(c.productBreakdown).toEqual({ added: 4, modified: 3, removed: 8 });
  });

  it("leaves the product breakdown null on a base version / without evolution", () => {
    // No evolution payload at all.
    expect(deriveOverviewMetrics(MVM_V2).change.productBreakdown).toBeNull();
    // Evolution present but the counts are null (base version, mirrors the pct).
    expect(
      deriveOverviewMetrics(MVM_V2, {
        evolution: {
          ...EVOLUTION_V2,
          change: {
            ...EVOLUTION_V2.change,
            products_added: null,
            products_modified: null,
            products_removed: null,
          },
        },
      }).change.productBreakdown,
    ).toBeNull();
  });

  it("derives Δ open issues (errors + warnings) from the evolution progression", () => {
    const c = deriveOverviewMetrics(MVM_V2, { evolution: EVOLUTION_V2 }).change;
    // -4 errors + 1 warning = -3 net issues
    expect(c.issueDelta).toBe(-3);
  });

  it("degrades Δ issues to ?? without an evolution predecessor", () => {
    expect(deriveOverviewMetrics(MVM_V2).change.issueDelta).toBe(UNCOMPUTABLE);
    expect(
      deriveOverviewMetrics(MVM_V2, {
        evolution: { ...EVOLUTION_V2, has_predecessor: false },
      }).change.issueDelta,
    ).toBe(UNCOMPUTABLE);
  });

  it("degrades to a base version when no domain carries a change status", () => {
    const base = {
      ...MVM_V2,
      domains: [{ change_status: "unchanged" }, { change_status: "unchanged" }],
    };
    expect(deriveOverviewMetrics(base).change.hasPredecessor).toBe(false);
  });
});

describe("deriveOverviewMetrics — review", () => {
  it("scales review_pct to 0..100 and carries the spine counts + feedback", () => {
    const r = deriveOverviewMetrics(MVM_V2, { feedbackCount: 7 }).review;
    expect(r.pct).toBe(34);
    expect(r.reviewed).toBe(14);
    expect(r.reviewNeeded).toBe(41);
    expect(r.feedbackCount).toBe(7);
  });

  it("defaults missing review/feedback figures to 0 (fresh version)", () => {
    const r = deriveOverviewMetrics({ version: 1 }).review;
    expect(r.pct).toBe(0);
    expect(r.reviewed).toBe(0);
    expect(r.reviewNeeded).toBe(0);
    expect(r.feedbackCount).toBe(0);
  });
});
