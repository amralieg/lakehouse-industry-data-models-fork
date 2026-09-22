/**
 * Phase 7 drift-unification Item 5 — regression test for the
 * intent-slug ↔ agent-op-string round-trip and the display-label
 * coverage. The maps live in ``lib/intent.ts`` and are derived from the
 * Orval-generated ``Intent`` enum (single source of truth, sourced from
 * the OpenAPI spec which mirrors ``backend/models.py:Intent``).
 *
 * If a new intent lands on the BE, the FE will fail this test until the
 * developer extends ``INTENT_LABELS`` + ``INTENT_TO_AGENT_OP`` to cover
 * it — exactly the gate the previous duplicated switch/case lacked.
 */
import { describe, expect, it } from "vitest";
import { Intent } from "@/lib/api";
import {
  INTENT_LABELS,
  INTENT_TO_AGENT_OP,
  intentLabel,
  intentToRunType,
  runTypeToIntent,
} from "@/lib/intent";

const ALL_INTENTS = Object.values(Intent) as string[];

describe("intent mapping", () => {
  it("INTENT_LABELS covers every Intent slug from the OpenAPI enum", () => {
    for (const slug of ALL_INTENTS) {
      expect(
        INTENT_LABELS[slug as keyof typeof INTENT_LABELS],
        `missing display label for intent slug ${slug}`,
      ).toBeTruthy();
    }
  });

  it("INTENT_TO_AGENT_OP covers every Intent slug from the OpenAPI enum", () => {
    for (const slug of ALL_INTENTS) {
      expect(
        INTENT_TO_AGENT_OP[slug as keyof typeof INTENT_TO_AGENT_OP],
        `missing agent-op string for intent slug ${slug}`,
      ).toBeTruthy();
    }
  });

  it("intentToRunType + runTypeToIntent round-trip every Intent slug", () => {
    for (const slug of ALL_INTENTS) {
      const op = intentToRunType(slug);
      expect(op, `intentToRunType returned slug verbatim for ${slug}`).not.toBe(
        slug,
      );
      const back = runTypeToIntent(op);
      expect(back, `round-trip lost intent ${slug}`).toBe(slug);
    }
  });

  it("intentLabel falls back to the raw slug for unknown values", () => {
    expect(intentLabel("nonsense-slug")).toBe("nonsense-slug");
    expect(intentLabel("")).toBe("");
    expect(intentLabel(null)).toBe("");
    expect(intentLabel(undefined)).toBe("");
  });

  it("runTypeToIntent returns empty string for unknown agent-op values", () => {
    expect(runTypeToIntent("not a real op")).toBe("");
  });

  it("intentToRunType returns the input verbatim for unknown intent values", () => {
    expect(intentToRunType("not-a-real-intent")).toBe("not-a-real-intent");
  });
});
