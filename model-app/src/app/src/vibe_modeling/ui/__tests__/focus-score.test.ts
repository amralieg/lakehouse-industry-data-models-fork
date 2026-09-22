import { describe, it, expect } from "vitest";
import {
  focusScore,
  focusBlendText,
  FOCUS_WEIGHTS,
  QUALITY_SATURATION,
} from "@/components/statistics/focus-score";

describe("focusScore (T9 composite)", () => {
  it("is 0 when there is nothing to review, no open inputs, and no change", () => {
    const { score, parts } = focusScore({
      reviewed: 0,
      reviewNeeded: 0,
      openInputs: 0,
      pctChanged: 0,
    });
    expect(score).toBe(0);
    expect(parts).toEqual({ reviewGap: 0, quality: 0, change: 0 });
  });

  it("maxes out at 100 when every signal is at its ceiling", () => {
    const { score } = focusScore({
      reviewed: 0,
      reviewNeeded: 10,
      openInputs: QUALITY_SATURATION,
      pctChanged: 100,
    });
    expect(score).toBe(100);
  });

  it("review gap is the unreviewed fraction on a 0..100 scale", () => {
    // 4 of 10 reviewed → 60% gap.
    const { parts } = focusScore({
      reviewed: 4,
      reviewNeeded: 10,
      openInputs: 0,
      pctChanged: null,
    });
    expect(parts.reviewGap).toBe(60);
  });

  it("quality saturates at QUALITY_SATURATION open inputs", () => {
    expect(
      focusScore({ reviewed: 0, reviewNeeded: 0, openInputs: 5, pctChanged: 0 })
        .parts.quality,
    ).toBe(50);
    expect(
      focusScore({
        reviewed: 0,
        reviewNeeded: 0,
        openInputs: 999,
        pctChanged: 0,
      }).parts.quality,
    ).toBe(100);
  });

  it("treats a null pctChanged (base version) as zero change pressure", () => {
    const { parts } = focusScore({
      reviewed: 0,
      reviewNeeded: 0,
      openInputs: 0,
      pctChanged: null,
    });
    expect(parts.change).toBe(0);
  });

  it("composes with the documented weights", () => {
    const { score, parts } = focusScore({
      reviewed: 4, // 60 gap
      reviewNeeded: 10,
      openInputs: 8, // 80 quality
      pctChanged: 40, // 40 change
    });
    expect(parts).toEqual({ reviewGap: 60, quality: 80, change: 40 });
    const expected = Math.round(
      FOCUS_WEIGHTS.reviewGap * 60 +
        FOCUS_WEIGHTS.quality * 80 +
        FOCUS_WEIGHTS.change * 40,
    );
    expect(score).toBe(expected);
  });

  it("clamps over-reviewed (reviewed > needed) to no gap", () => {
    const { parts } = focusScore({
      reviewed: 20,
      reviewNeeded: 10,
      openInputs: 0,
      pctChanged: null,
    });
    expect(parts.reviewGap).toBe(0);
  });

  it("blend text exposes each signal and its weight for the tooltip", () => {
    const text = focusBlendText({ reviewGap: 60, quality: 80, change: 40 });
    expect(text).toContain("Review gap 60 ×0.40");
    expect(text).toContain("Quality 80 ×0.35");
    expect(text).toContain("Change 40 ×0.25");
  });
});
