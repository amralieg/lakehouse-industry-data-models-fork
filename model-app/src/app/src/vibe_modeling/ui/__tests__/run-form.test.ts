/**
 * Unit tests for the New Run form blockers helper.
 *
 * The drift bug (the model-versioning work, Phase 5): two booleans were derived inline in
 * `runs.new.tsx` and re-tested in the Submit `disabled` prop, with copy-paste
 * comments. Adding a third gate meant remembering both call sites; risking a
 * disabled button whose inline reason banner didn't actually trigger.
 */
import { describe, expect, it } from "vitest";
import { deriveRunFormBlockers, type RunFormState } from "../lib/run-form";

const baseState: RunFormState = {
  isBase: false,
  isVibe: false,
  contextMode: "text",
  businessContextText: "",
  businessContextPath: "",
  inputCount: 0,
};

describe("deriveRunFormBlockers", () => {
  it("returns no blockers for an irrelevant intent (neither base nor vibe)", () => {
    const out = deriveRunFormBlockers(baseState);
    expect(out).toEqual({
      baseContextMissing: false,
      vibeContentMissing: false,
      hasBlocker: false,
    });
  });

  describe("new-base-model", () => {
    it("blocks when text mode + empty text", () => {
      const out = deriveRunFormBlockers({ ...baseState, isBase: true });
      expect(out.baseContextMissing).toBe(true);
      expect(out.hasBlocker).toBe(true);
    });

    it("treats whitespace-only text as empty", () => {
      const out = deriveRunFormBlockers({
        ...baseState,
        isBase: true,
        businessContextText: "   \n  ",
      });
      expect(out.baseContextMissing).toBe(true);
    });

    it("clears when text mode has non-empty content", () => {
      const out = deriveRunFormBlockers({
        ...baseState,
        isBase: true,
        businessContextText: "We sell widgets",
      });
      expect(out.baseContextMissing).toBe(false);
    });

    it("blocks when path mode + empty path", () => {
      const out = deriveRunFormBlockers({
        ...baseState,
        isBase: true,
        contextMode: "path",
      });
      expect(out.baseContextMissing).toBe(true);
    });

    it("clears when path mode has a path even if text is empty", () => {
      const out = deriveRunFormBlockers({
        ...baseState,
        isBase: true,
        contextMode: "path",
        businessContextPath: "/Volumes/.../context.md",
      });
      expect(out.baseContextMissing).toBe(false);
    });
  });

  describe("vibe runs", () => {
    it("blocks when no Vibe Inputs are selected", () => {
      const out = deriveRunFormBlockers({ ...baseState, isVibe: true });
      expect(out.vibeContentMissing).toBe(true);
      expect(out.hasBlocker).toBe(true);
    });

    it("clears when at least one Vibe Input is selected", () => {
      const out = deriveRunFormBlockers({
        ...baseState,
        isVibe: true,
        inputCount: 1,
      });
      expect(out.vibeContentMissing).toBe(false);
    });
  });
});
