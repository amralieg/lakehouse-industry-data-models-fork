/**
 * Pure derivation of the overview metrics band's four areas. Combines the
 * model summary (counts + per-domain change status + per-version review
 * counts), the parent-supplied feedback/runs counts, and — as of T11 — the
 * evolution metrics (T16) and next-vibe metrics (T13) endpoints. Kept
 * side-effect-free so the band renders the same shape in tests, and so the
 * "uncomputable → —" degradation rules live in one place rather than
 * scattered across JSX.
 *
 * Design-of-record: docs/design/model-overview/README.md (four areas: Change,
 * Quality, Review progress, Size + effort).
 *
 * What is and isn't derivable from the current backend surface:
 *  - Change: per-domain `change_status` gives added/changed/removed DOMAIN
 *    counts (model summary). The Δ-open-issues figure comes from the evolution
 *    progression (`errors_delta + warnings_delta`). `% of model touched` is the
 *    evolution per-product diff ratio (`change.model_touched_pct`, 0..100); it
 *    degrades to "—" only on a base version or a metadata-less import where
 *    evolution recorded none.
 *  - Quality: confidence + delta + a per-version sparkline now come from
 *    evolution (`quality.confidence_score`, `change.confidence_delta`,
 *    `change.version_history`). Open issues + severity split come from
 *    `quality.error_count / warning_count / info_count`. `next_vibes` Quality
 *    Score comes from the next-vibe-metrics endpoint. ECM versions carry no
 *    confidence (`has_confidence === false`) → confidence degrades to "—";
 *    a base version (`has_predecessor === false`) → no delta, no sparkline.
 *  - Review: `review_pct` + reviewed/needed counts are per-version and exclude
 *    "no review needed" products (the spine's getReviewProgress contract).
 *  - Size + effort: counts are exact; effort = tokens (evolution
 *    `estimated_input_tokens + estimated_output_tokens`) · processing hours
 *    (`duration_hours`) · runs count. Each effort figure degrades to "—" when
 *    evolution didn't record it (metadata-less imports).
 */

/** Internal sentinel marking a figure the current data can't compute. Never
 *  rendered directly — the band's `Unknown` token shows {@link ABSENT_METRIC}.
 *  Kept as a distinct, opaque value so callers compare against it
 *  (`x === UNCOMPUTABLE`) without coupling to the display glyph. */
export const UNCOMPUTABLE = Symbol("uncomputable");

/** The display glyph for an absent/uncomputable metric — the clean em-dash from
 *  the Statistics tab (size-effort-section.tsx), so the whole app shares one
 *  graceful-degradation style. */
export const ABSENT_METRIC = "—" as const;

export type ChangeStatus = "unchanged" | "new" | "modified" | "deleted";

/** Minimal shape this module reads off the model summary. Declared locally so
 *  it doesn't ride on the (T4-owned, currently stale) generated `api.ts`
 *  `ModelSummaryOut` type — every field is read defensively. */
export interface OverviewModel {
  version?: number;
  domain_count?: number;
  subdomain_count?: number;
  product_count?: number;
  attribute_count?: number;
  fk_count?: number;
  confidence_score?: number | null;
  review_pct?: number;
  reviewed_count?: number;
  review_needed_count?: number;
  no_review_needed_count?: number;
  domains?: Array<{ change_status?: ChangeStatus | string }>;
}

/** Minimal read-side view of `EvolutionMetricsOut` (api.ts). Declared locally
 *  and read defensively so the band doesn't couple to the generated type. */
export interface OverviewEvolution {
  has_confidence?: boolean;
  has_predecessor?: boolean;
  quality?: {
    confidence_score?: number | null;
    error_count?: number | null;
    warning_count?: number | null;
    info_count?: number | null;
  };
  change?: {
    confidence_delta?: number | null;
    errors_delta?: number | null;
    warnings_delta?: number | null;
    /** % of the model's products touched (NEW/MODIFIED/DELETED) vs the
     *  predecessor (0..100); null on a base version. */
    model_touched_pct?: number | null;
    /** Change-count breakdown behind `model_touched_pct` (NEW / MODIFIED /
     *  DELETED product counts); each null on a base version. */
    products_added?: number | null;
    products_modified?: number | null;
    products_removed?: number | null;
    version_history?: Array<{
      version?: string;
      confidence?: number | null;
    }>;
  };
  effort?: {
    estimated_input_tokens?: number | null;
    estimated_output_tokens?: number | null;
    duration_hours?: number | null;
  };
}

/** Minimal read-side view of `NextVibeMetricsOut` (api.ts). */
export interface OverviewNextVibe {
  has_data?: boolean;
  quality_score?: number | null;
}

/** One point on the confidence sparkline. */
export interface SparkPoint {
  label: string;
  value: number;
}

export interface ChangeMetrics {
  /** True when this version has a predecessor to diff against. A base version
   *  (no domain carries a new/modified/deleted status) degrades the whole
   *  area: segmented bar + deltas are hidden. */
  hasPredecessor: boolean;
  domainsAdded: number;
  domainsChanged: number;
  domainsRemoved: number;
  /** % of the model's products touched vs the predecessor (NEW/MODIFIED/
   *  DELETED), from evolution `change.model_touched_pct`. "—" when evolution
   *  didn't record it (metadata-less import) or on a base version. */
  pctTouched: number | typeof UNCOMPUTABLE;
  /** Per-PRODUCT change-count breakdown behind `pctTouched` (added · modified ·
   *  removed), from evolution `change.products_*`. null on a base version or
   *  when evolution didn't record it — distinct from the per-DOMAIN
   *  `domainsAdded/Changed/Removed` that drive the segmented bar. */
  productBreakdown: { added: number; modified: number; removed: number } | null;
  /** Δ open issues vs predecessor (errors + warnings), or "—" when evolution
   *  didn't record a predecessor diff. Negative = fewer issues (an
   *  improvement). */
  issueDelta: number | typeof UNCOMPUTABLE;
}

export interface QualityMetrics {
  /** Confidence on a 0..100 scale, or "—" when the agent emitted none
   *  (ECM scope arrives with `has_confidence === false`). */
  confidence: number | typeof UNCOMPUTABLE;
  /** Signed delta vs the predecessor's confidence (0..100 points), or null on
   *  a base version / when confidence isn't scored. */
  confidenceDelta: number | null;
  /** Per-version confidence sparkline (oldest → newest). Empty on a base
   *  version or when no history is on the wire. */
  history: SparkPoint[];
  /** `next_vibes` Quality Score (0..100), or null until seeded. */
  qualityScore: number | null;
  /** Open-issue total, or "—" when not scored (no confidence). */
  openIssues: number | typeof UNCOMPUTABLE;
  /** Severity split of open issues (errors=high, warnings=med, info=low).
   *  null when issue counts aren't on the wire. */
  severity: { high: number; medium: number; low: number } | null;
}

export interface ReviewMetrics {
  /** 0..100 reviewed percentage. "no review needed" products are excluded
   *  from the denominator (spine getReviewProgress contract). */
  pct: number;
  reviewed: number;
  reviewNeeded: number;
  feedbackCount: number;
}

export interface SizeEffortMetrics {
  domains: number;
  subdomains: number;
  products: number;
  columns: number;
  foreignKeys: number;
  /** Runs that produced/touched this version. */
  runs: number;
  /** Total tokens (input + output), or "—" when evolution didn't record it. */
  tokens: number | typeof UNCOMPUTABLE;
  /** Processing hours, or "—" when evolution didn't record it. */
  processingHours: number | typeof UNCOMPUTABLE;
}

export interface OverviewMetrics {
  change: ChangeMetrics;
  quality: QualityMetrics;
  review: ReviewMetrics;
  sizeEffort: SizeEffortMetrics;
}

function n(v: number | undefined | null): number {
  return typeof v === "number" && Number.isFinite(v) ? v : 0;
}

/** A finite number or undefined/null/non-finite → undefined. */
function num(v: number | undefined | null): number | undefined {
  return typeof v === "number" && Number.isFinite(v) ? v : undefined;
}

/**
 * Color verdict for the quality confidence delta, per the design's ±5% rule:
 * green when up > +5, red when down < −5, yellow within ±5 (including 0).
 */
export type DeltaTone = "good" | "bad" | "flat";
export function confidenceDeltaTone(delta: number | null): DeltaTone {
  if (delta === null) return "flat";
  if (delta > 5) return "good";
  if (delta < -5) return "bad";
  return "flat";
}

/**
 * Derive the four metric areas. Counts the parent already has (feedback, runs)
 * plus the evolution + next-vibe metrics ride in via `extras` so this stays a
 * pure function with no data-fetching of its own. `evolution`/`nextVibe` are
 * optional: when absent (still loading, or endpoint errored) the figures they
 * back degrade to "—" / null exactly as before T11.
 */
export function deriveOverviewMetrics(
  model: OverviewModel,
  extras: {
    feedbackCount?: number;
    runsCount?: number;
    evolution?: OverviewEvolution | null;
    nextVibe?: OverviewNextVibe | null;
  } = {},
): OverviewMetrics {
  const domains = model.domains ?? [];
  const added = domains.filter((d) => d.change_status === "new").length;
  const changed = domains.filter((d) => d.change_status === "modified").length;
  const removed = domains.filter((d) => d.change_status === "deleted").length;
  const hasPredecessor = added + changed + removed > 0;

  const ev = extras.evolution ?? null;
  const nv = extras.nextVibe ?? null;
  // The version-level predecessor flag (evolution) gates the sparkline +
  // deltas; it's distinct from the domain-level `hasPredecessor` that gates
  // the segmented change bar (a base version can still carry domain statuses
  // from an import, and vice-versa).
  const evHasPredecessor = ev?.has_predecessor === true;

  // --- Quality ------------------------------------------------------------
  // Prefer the evolution confidence (already 0..100) when scored; fall back to
  // the model summary's 0..1 score so the cell still lights up before/without
  // the evolution endpoint.
  let confidence: number | typeof UNCOMPUTABLE = UNCOMPUTABLE;
  if (ev) {
    if (ev.has_confidence === true) {
      const c = num(ev.quality?.confidence_score);
      confidence = c === undefined ? UNCOMPUTABLE : Math.round(c);
    }
  } else {
    const rawConfidence = model.confidence_score;
    confidence =
      typeof rawConfidence === "number" && rawConfidence > 0
        ? Math.round(rawConfidence * 100)
        : UNCOMPUTABLE;
  }

  // The sparkline + delta are a *confidence* timeline, so they need both a
  // scored predecessor AND a confidence on this version — an unscored (ECM)
  // version has no meaningful point to plot.
  const canTrendConfidence = evHasPredecessor && confidence !== UNCOMPUTABLE;

  const confidenceDelta = canTrendConfidence
    ? num(ev?.change?.confidence_delta) ?? null
    : null;

  const history: SparkPoint[] =
    canTrendConfidence && Array.isArray(ev?.change?.version_history)
      ? ev!
          .change!.version_history!.map((h) => ({
            label: h.version ?? "",
            value: num(h.confidence),
          }))
          .filter((p): p is SparkPoint => p.value !== undefined)
      : [];

  // Open issues + severity split (errors=high, warnings=med, info=low). Only
  // meaningful when the version was scored (has_confidence).
  let openIssues: number | typeof UNCOMPUTABLE = UNCOMPUTABLE;
  let severity: QualityMetrics["severity"] = null;
  if (ev?.has_confidence === true) {
    const high = n(ev.quality?.error_count);
    const medium = n(ev.quality?.warning_count);
    const low = n(ev.quality?.info_count);
    severity = { high, medium, low };
    openIssues = high + medium + low;
  }

  // The next-vibe quality_score arrives on a 0..1 scale (mean of VibeInput
  // confidence_scores) and is scaled to 0..100 for display — note the
  // asymmetry with the evolution confidence_score above, which is already
  // 0..100, and with the model-summary confidence fallback, which (like this)
  // is 0..1 and ×100'd.
  const rawQualityScore =
    nv?.has_data === true ? num(nv.quality_score) : undefined;
  const qualityScore =
    rawQualityScore === undefined ? null : Math.round(rawQualityScore * 100);

  // --- Change Δ issues ----------------------------------------------------
  const issueDelta = evHasPredecessor
    ? n(ev?.change?.errors_delta) + n(ev?.change?.warnings_delta)
    : UNCOMPUTABLE;

  // % of the model touched vs predecessor — from evolution's per-product diff
  // (`change.model_touched_pct`, already 0..100). "—" on a base version or
  // when evolution didn't record it.
  const rawTouched = num(ev?.change?.model_touched_pct);
  const pctTouched: number | typeof UNCOMPUTABLE =
    rawTouched === undefined ? UNCOMPUTABLE : Math.round(rawTouched);

  // Per-product change-count breakdown behind the %. Present only when
  // evolution recorded the (non-null) counts, i.e. on a non-baseline version.
  const pAdded = num(ev?.change?.products_added);
  const pModified = num(ev?.change?.products_modified);
  const pRemoved = num(ev?.change?.products_removed);
  const productBreakdown =
    pAdded === undefined && pModified === undefined && pRemoved === undefined
      ? null
      : { added: pAdded ?? 0, modified: pModified ?? 0, removed: pRemoved ?? 0 };

  // --- Size + effort ------------------------------------------------------
  let tokens: number | typeof UNCOMPUTABLE = UNCOMPUTABLE;
  if (ev?.effort) {
    const inTok = num(ev.effort.estimated_input_tokens);
    const outTok = num(ev.effort.estimated_output_tokens);
    if (inTok !== undefined || outTok !== undefined) {
      tokens = (inTok ?? 0) + (outTok ?? 0);
    }
  }
  const hrs = num(ev?.effort?.duration_hours);
  const processingHours = hrs === undefined ? UNCOMPUTABLE : hrs;

  const pct = Math.round(n(model.review_pct) * 100);

  return {
    change: {
      hasPredecessor,
      domainsAdded: added,
      domainsChanged: changed,
      domainsRemoved: removed,
      pctTouched,
      productBreakdown,
      issueDelta,
    },
    quality: {
      confidence,
      confidenceDelta,
      history,
      qualityScore,
      openIssues,
      severity,
    },
    review: {
      pct,
      reviewed: n(model.reviewed_count),
      reviewNeeded: n(model.review_needed_count),
      feedbackCount: n(extras.feedbackCount),
    },
    sizeEffort: {
      domains: n(model.domain_count),
      subdomains: n(model.subdomain_count),
      products: n(model.product_count),
      columns: n(model.attribute_count),
      foreignKeys: n(model.fk_count),
      runs: n(extras.runsCount),
      tokens,
      processingHours,
    },
  };
}
