/**
 * `deriveInputState` truth table + anchor mappers (commit c/d shared helper).
 * Precedence: deprecated > needs_link_review > consumed > active.
 */
import { describe, expect, it } from "vitest";
import type { VibeInputOut } from "@/lib/api";
import {
  deriveInputState,
  anchorPathForCompile,
  isIncludedInCompile,
  anchorFromInput,
} from "@/components/vibe-inputs/state";

const base = (over: Partial<VibeInputOut> = {}): VibeInputOut => ({
  id: "vi-1",
  business_id: "biz-1",
  origin: "user",
  author: "a@b.c",
  text: "do the thing",
  priority: "medium",
  confidence_score: null,
  consumed: false,
  status: "active",
  selected_for_run: false,
  deprecated_by: null,
  created_at: "2026-01-01T00:00:00",
  updated_at: "2026-01-01T00:00:00",
  anchor: null,
  ...over,
});

describe("deriveInputState", () => {
  it("deprecated wins over everything", () => {
    expect(
      deriveInputState({ status: "deprecated", consumed: true }, [
        { needs_link_review: true },
      ]),
    ).toBe("deprecated");
  });

  it("needs_link_review wins over consumed when a link is flagged", () => {
    expect(
      deriveInputState({ status: "active", consumed: true }, [
        { needs_link_review: false },
        { needs_link_review: true },
      ]),
    ).toBe("needs_link_review");
  });

  it("consumed when no flagged links", () => {
    expect(
      deriveInputState({ status: "active", consumed: true }, [
        { needs_link_review: false },
      ]),
    ).toBe("consumed");
  });

  it("active by default", () => {
    expect(deriveInputState({ status: "active", consumed: false })).toBe("active");
  });

  it("cannot report needs_link_review without links loaded", () => {
    expect(deriveInputState({ status: "active", consumed: false }, [])).toBe("active");
    expect(deriveInputState({ status: "active", consumed: true })).toBe("consumed");
  });
});

describe("anchorPathForCompile", () => {
  it("returns null for an anchor-free input (no head link)", () => {
    expect(anchorPathForCompile(base({ anchor: null }))).toBeNull();
  });

  it("model-wide maps to [Model-wide]", () => {
    expect(
      anchorPathForCompile(base({ anchor: { level: "model_wide", path: [] } })),
    ).toEqual(["Model-wide"]);
  });

  it("element uses the hydrated section path", () => {
    expect(
      anchorPathForCompile(
        base({
          anchor: {
            level: "element",
            domain_name: "Sales",
            path: ["Domain: Sales", "Product: Orders"],
          },
        }),
      ),
    ).toEqual(["Domain: Sales", "Product: Orders"]);
  });
});

describe("isIncludedInCompile", () => {
  it("excludes deprecated", () => {
    expect(
      isIncludedInCompile(
        base({ status: "deprecated", anchor: { level: "model_wide", path: [] } }),
      ),
    ).toBe(false);
  });
  it("excludes anchor-free", () => {
    expect(isIncludedInCompile(base({ anchor: null }))).toBe(false);
  });
  it("includes active anchored", () => {
    expect(
      isIncludedInCompile(base({ anchor: { level: "model_wide", path: [] } })),
    ).toBe(true);
  });
});

describe("anchorFromInput", () => {
  it("returns undefined for model-wide / anchor-free", () => {
    expect(anchorFromInput(base({ anchor: null }))).toBeUndefined();
    expect(
      anchorFromInput(base({ anchor: { level: "model_wide", path: [] } })),
    ).toBeUndefined();
  });
  it("maps domain/product/attribute/fk leaves", () => {
    expect(
      anchorFromInput(
        base({
          anchor: {
            level: "element",
            domain_name: "Sales",
            product_name: "Orders",
            attribute_name: "order_id",
            fk_label: "order_id→customer_id",
            path: [],
          },
        }),
      ),
    ).toEqual({
      domain: "Sales",
      product: "Orders",
      attribute: "order_id",
      fkLabel: "order_id→customer_id",
    });
  });
});
