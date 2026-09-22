import type { IndustryOut } from "@/lib/api";

/**
 * Minimal shape needed to resolve an industry display name. Accepts the
 * full ``IndustryOut`` rows from ``useListIndustriesSuspense`` (or any
 * subset carrying ``name`` + ``short_name``).
 */
export type IndustryLike = Pick<IndustryOut, "name" | "short_name">;

/**
 * Canonicalize an industry string for case-insensitive, hyphen↔space
 * insensitive comparison: lowercased, hyphens/underscores → spaces,
 * collapsed whitespace, trimmed. ``"Food-And-Beverage "`` and
 * ``"food and beverage"`` both canonicalize to ``"food and beverage"``.
 */
function canonical(value: string): string {
  return value
    .trim()
    .toLowerCase()
    .replace(/[-_]+/g, " ")
    .replace(/\s+/g, " ");
}

const LOWER_WORDS = new Set([
  "a",
  "an",
  "and",
  "or",
  "of",
  "the",
  "to",
  "for",
  "in",
  "on",
  "&",
]);

/**
 * Title-case a raw kebab/underscore slug for display. Splits on hyphens,
 * underscores and whitespace; capitalizes each word except a small set of
 * connector words (which stay lowercase unless they lead). Single-letter
 * tokens and the first word are always capitalized.
 *
 * ``"food-and-beverage"`` → ``"Food and Beverage"``
 * ``"digital-fashion-commerce"`` → ``"Digital Fashion Commerce"``
 */
function titleCaseSlug(value: string): string {
  const words = value
    .trim()
    .split(/[-_\s]+/)
    .filter(Boolean);
  return words
    .map((word, i) => {
      const lower = word.toLowerCase();
      if (i > 0 && LOWER_WORDS.has(lower)) return lower;
      return lower.charAt(0).toUpperCase() + lower.slice(1);
    })
    .join(" ");
}

/**
 * A raw kebab/snake slug: all-lowercase, no whitespace, joined by hyphens
 * or underscores (``"food-and-beverage"``, ``"energy_utilities"``). Used to
 * decide whether a string still needs humanizing for display vs. is already
 * a curated display name (``"Food and Beverage"``, ``"Retail & E-Commerce"``).
 */
function looksLikeSlug(value: string): boolean {
  const v = value.trim();
  return /[-_]/.test(v) && !/\s/.test(v) && v === v.toLowerCase();
}

/**
 * Resolve a stored ``industry_alignment`` value to a user-facing display
 * name. Render-time only — never mutates stored data.
 *
 * Resolution order:
 *  1. If ``value`` matches a catalog entry's ``name`` or ``short_name``
 *     (case-insensitive, hyphen↔space insensitive), return that entry's
 *     curated ``name`` — humanized if the catalog name is itself a raw slug
 *     (auto-created import industries store a slug as their name).
 *  2. Otherwise title-case the raw hyphenated/underscored slug
 *     (``"food-and-beverage"`` → ``"Food and Beverage"``).
 *
 * Falsy / blank input is returned as-is so callers can guard rendering.
 */
export function industryDisplayName(
  value: string | null | undefined,
  industries: readonly IndustryLike[] | null | undefined,
): string {
  if (!value || !value.trim()) return value ?? "";

  const target = canonical(value);
  const match = (industries ?? []).find(
    (i) => canonical(i.name) === target || canonical(i.short_name) === target,
  );
  if (match) {
    return looksLikeSlug(match.name) ? titleCaseSlug(match.name) : match.name;
  }

  return titleCaseSlug(value);
}
