/**
 * T9 — the "Where to focus" composite score.
 *
 * A single 0–100 number that ranks domains by how much attention they need.
 * It blends three normalized signals, each already mapped to 0–100 so a higher
 * number always means "needs more focus":
 *
 *   - reviewGap  — how much of the domain is still unreviewed
 *                  = 100 × (reviewNeeded − reviewed) / reviewNeeded
 *                  (0 when nothing needs review or everything is reviewed)
 *   - quality    — open next_vibes inputs attributed to the domain, saturating
 *                  at QUALITY_SATURATION open inputs (≥ that ⇒ 100)
 *   - change     — % of the domain touched vs its predecessor (0 on a base
 *                  version / unchanged domain)
 *
 * WEIGHTS (TBD with the team — see ADR D-044 / design-of-record "Focus score").
 * We default to an equal-ish blend that leans slightly toward review gap,
 * because the report's primary job is to drive the review to completion:
 *
 *   reviewGap 0.40 · quality 0.35 · change 0.25   (sum = 1.0)
 *
 * The weights live in ONE place (`FOCUS_WEIGHTS`) so they are trivially
 * tunable, and the breakdown is exposed via `focusScore(...).parts` so the
 * UI tooltip can show exactly how the number was composed. If a signal is
 * unavailable (e.g. change on a base version) it contributes 0 and the
 * remaining weights are NOT renormalized — an absent signal genuinely means
 * "no focus pressure from that axis".
 */

/** Open-input count at which the quality signal saturates to 100. */
export const QUALITY_SATURATION = 10;

export const FOCUS_WEIGHTS = {
  reviewGap: 0.4,
  quality: 0.35,
  change: 0.25,
} as const;

export interface FocusInputs {
  /** Products reviewed in the domain. */
  reviewed: number;
  /** Products still needing review (excludes no-review-needed). */
  reviewNeeded: number;
  /** Open agent vibe-run findings (origin=agent_next_vibe) attributed to the
   *  domain, NOT user feedback. */
  openInputs: number;
  /** % of the domain touched vs predecessor (0..100); null on a base version. */
  pctChanged: number | null;
}

export interface FocusParts {
  /** Each signal already on a 0..100 scale (the value before weighting). */
  reviewGap: number;
  quality: number;
  change: number;
}

export interface FocusScore {
  /** The composite 0..100 score (rounded). */
  score: number;
  /** The three normalized signals (0..100) for the tooltip breakdown. */
  parts: FocusParts;
}

function clamp01to100(n: number): number {
  if (Number.isNaN(n)) return 0;
  return Math.max(0, Math.min(100, n));
}

/**
 * Pure composite focus score. Deterministic, no side effects — the single
 * source of truth for the "Where to focus" Focus column and the scope tree.
 */
export function focusScore(input: FocusInputs): FocusScore {
  const reviewGap =
    input.reviewNeeded > 0
      ? clamp01to100(
          (100 * (input.reviewNeeded - Math.min(input.reviewed, input.reviewNeeded))) /
            input.reviewNeeded,
        )
      : 0;

  const quality = clamp01to100(
    (100 * Math.max(0, input.openInputs)) / QUALITY_SATURATION,
  );

  const change = input.pctChanged == null ? 0 : clamp01to100(input.pctChanged);

  const composite =
    FOCUS_WEIGHTS.reviewGap * reviewGap +
    FOCUS_WEIGHTS.quality * quality +
    FOCUS_WEIGHTS.change * change;

  return {
    score: Math.round(clamp01to100(composite)),
    parts: { reviewGap, quality, change },
  };
}

/**
 * Human-readable one-line explanation of the blend, for the Focus tooltip.
 * e.g. "Review gap 60 ×0.40 · Quality 80 ×0.35 · Change 40 ×0.25".
 */
export function focusBlendText(parts: FocusParts): string {
  return (
    `Review gap ${Math.round(parts.reviewGap)} ×${FOCUS_WEIGHTS.reviewGap.toFixed(2)} · ` +
    `Quality ${Math.round(parts.quality)} ×${FOCUS_WEIGHTS.quality.toFixed(2)} · ` +
    `Change ${Math.round(parts.change)} ×${FOCUS_WEIGHTS.change.toFixed(2)}`
  );
}
