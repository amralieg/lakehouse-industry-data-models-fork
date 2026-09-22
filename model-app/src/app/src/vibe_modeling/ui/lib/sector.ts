import type { SectorOut } from "@/lib/api";

/**
 * Minimal shape needed to resolve a sector display name. Accepts the full
 * ``SectorOut`` rows from ``useListSectorsSuspense`` (or any subset carrying
 * ``id`` + ``name``).
 */
export type SectorLike = Pick<SectorOut, "id" | "name">;

/**
 * Resolve a stored ``Business.sector_id`` to the matching Sector's display
 * name. Render-time only — never mutates stored data.
 *
 * Returns the sector ``name`` when ``sector_id`` matches a row in the catalog;
 * returns ``null`` when the id is falsy or dangling (no matching row) so
 * callers can render an em-dash placeholder. Unlike the legacy
 * ``industry_alignment`` free-text, ``sector_id`` is a FK — there is no slug
 * to humanize, just an id to look up.
 */
export function sectorDisplayName(
  sectorId: string | null | undefined,
  sectors: readonly SectorLike[] | null | undefined,
): string | null {
  if (!sectorId) return null;
  const match = (sectors ?? []).find((s) => s.id === sectorId);
  return match ? match.name : null;
}
