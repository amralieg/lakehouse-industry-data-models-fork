/**
 * Shared ``SectorSelect`` dropdown (ADR D-047) — used by the New Business +
 * New Industry create forms.
 *
 * Tests:
 *  1. Renders one ``<SelectItem>`` per ACTIVE sector (inactive rows filtered),
 *     with the sector ``name`` as the visible label and the sector ``id`` as
 *     the option value.
 *  2. Picking a sector calls ``onChange`` with the sector's ``id``.
 *  3. The "None" option clears the selection — ``onChange(null)``.
 *
 * Radix portals its content into ``document.body``; we open the trigger via
 * click before querying for options (same pattern as ``industry-select``).
 */
import { describe, it, expect, vi, beforeEach } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import { Suspense } from "react";

let sectorsData: any[] = [];

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListSectorsSuspense: () => ({ data: sectorsData }),
  };
});

import { SectorSelect } from "@/components/business/sector-select";

const makeSector = (overrides: Partial<any>): any => ({
  id: `sec-${overrides.short_name ?? Math.random()}`,
  name: overrides.name ?? "Default",
  short_name: overrides.short_name ?? "default",
  description: "",
  display_order: 0,
  is_active: true,
  created_at: "2024-01-01T00:00:00Z",
  updated_at: "2024-01-01T00:00:00Z",
  ...overrides,
});

function renderHarness(value: string | null, onChange = vi.fn()) {
  return {
    onChange,
    ...render(
      <Suspense fallback={<div>loading</div>}>
        <SectorSelect value={value} onChange={onChange} />
      </Suspense>,
    ),
  };
}

beforeEach(() => {
  sectorsData = [];
});

describe("SectorSelect", () => {
  it("renders one option per active sector and filters out inactive rows", () => {
    sectorsData = [
      makeSector({ id: "sec-retail", name: "Retail", short_name: "retail" }),
      makeSector({ id: "sec-fsi", name: "Financial Services", short_name: "fsi" }),
      makeSector({
        id: "sec-hidden", name: "Hidden", short_name: "hidden", is_active: false,
      }),
    ];

    renderHarness(null);
    fireEvent.click(screen.getByRole("combobox"));

    // 2 active sectors + the "None" option.
    expect(screen.getAllByRole("option")).toHaveLength(3);
    expect(screen.getByRole("option", { name: "None" })).toBeInTheDocument();
    expect(screen.queryByRole("option", { name: /Hidden/ })).toBeNull();
  });

  it("uses the sector id as the option value (onChange gets the id, not the name)", () => {
    sectorsData = [
      makeSector({ id: "sec-fsi", name: "Financial Services", short_name: "fsi" }),
    ];

    const { onChange } = renderHarness(null);
    fireEvent.click(screen.getByRole("combobox"));

    fireEvent.click(screen.getByRole("option", { name: /Financial Services/ }));
    expect(onChange).toHaveBeenCalledWith("sec-fsi");
  });

  it("clears the selection when None is picked (onChange null)", () => {
    sectorsData = [
      makeSector({ id: "sec-retail", name: "Retail", short_name: "retail" }),
    ];

    const { onChange } = renderHarness("sec-retail");
    fireEvent.click(screen.getByRole("combobox"));

    fireEvent.click(screen.getByRole("option", { name: "None" }));
    expect(onChange).toHaveBeenCalledWith(null);
  });
});
