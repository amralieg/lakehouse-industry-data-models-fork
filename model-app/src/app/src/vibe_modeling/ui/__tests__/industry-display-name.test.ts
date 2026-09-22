/**
 * Unit tests for the shared `industryDisplayName` resolver (lib/industry.ts).
 *
 * Behavior under test:
 *  - slug-match against catalog (case- and hyphen/space-insensitive) → catalog name
 *  - name-match against catalog → catalog name
 *  - no catalog match → title-cased hyphenated slug
 *  - falsy/blank passthrough
 */
import { describe, it, expect } from "vitest";
import { industryDisplayName, type IndustryLike } from "@/lib/industry";

const catalog: IndustryLike[] = [
  { name: "Food and Beverage", short_name: "food-and-beverage" },
  { name: "Retail & E-Commerce", short_name: "retail" },
  { name: "Energy - Utilities", short_name: "energy-utilities" },
];

describe("industryDisplayName", () => {
  describe("catalog short_name slug match", () => {
    it("resolves an exact short_name slug to the curated name", () => {
      expect(industryDisplayName("food-and-beverage", catalog)).toBe(
        "Food and Beverage",
      );
    });

    it("matches case-insensitively", () => {
      expect(industryDisplayName("FOOD-AND-BEVERAGE", catalog)).toBe(
        "Food and Beverage",
      );
    });

    it("matches hyphen↔space insensitively", () => {
      expect(industryDisplayName("food and beverage", catalog)).toBe(
        "Food and Beverage",
      );
    });

    it("matches underscore-delimited slugs", () => {
      expect(industryDisplayName("energy_utilities", catalog)).toBe(
        "Energy - Utilities",
      );
    });
  });

  describe("catalog name match", () => {
    it("resolves an exact display name to itself", () => {
      expect(industryDisplayName("Retail & E-Commerce", catalog)).toBe(
        "Retail & E-Commerce",
      );
    });

    it("resolves a short_name to its display name", () => {
      expect(industryDisplayName("retail", catalog)).toBe(
        "Retail & E-Commerce",
      );
    });

    it("humanizes a catalog entry whose name is itself a raw slug (F2)", () => {
      const slugCatalog: IndustryLike[] = [
        { name: "digital-fashion-commerce", short_name: "digital-fashion-commerce" },
      ];
      expect(
        industryDisplayName("digital-fashion-commerce", slugCatalog),
      ).toBe("Digital Fashion Commerce");
    });
  });

  describe("title-case fallback (no catalog match)", () => {
    it("title-cases a hyphenated slug with connector words", () => {
      expect(industryDisplayName("staffing-and-recruitment", catalog)).toBe(
        "Staffing and Recruitment",
      );
    });

    it("title-cases each word of a plain hyphenated slug", () => {
      expect(industryDisplayName("digital-fashion-commerce", catalog)).toBe(
        "Digital Fashion Commerce",
      );
    });

    it("capitalizes a leading connector word but lowercases interior ones", () => {
      expect(industryDisplayName("of-mice-and-men", catalog)).toBe(
        "Of Mice and Men",
      );
    });

    it("falls back when catalog is empty", () => {
      expect(industryDisplayName("food-and-beverage", [])).toBe(
        "Food and Beverage",
      );
    });

    it("handles null/undefined catalog", () => {
      expect(industryDisplayName("apparel-fashion", null)).toBe(
        "Apparel Fashion",
      );
      expect(industryDisplayName("apparel-fashion", undefined)).toBe(
        "Apparel Fashion",
      );
    });
  });

  describe("falsy passthrough", () => {
    it("returns empty string for null", () => {
      expect(industryDisplayName(null, catalog)).toBe("");
    });

    it("returns empty string for undefined", () => {
      expect(industryDisplayName(undefined, catalog)).toBe("");
    });

    it("returns the blank value as-is", () => {
      expect(industryDisplayName("   ", catalog)).toBe("   ");
    });
  });
});
