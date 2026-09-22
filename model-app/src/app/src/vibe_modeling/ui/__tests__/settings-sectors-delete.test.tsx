/**
 * `SectorsSection` delete-flow coverage (ADR D-047).
 *
 * The Settings → Industries tab now manages the Sector taxonomy. This test
 * gates the per-row delete affordance:
 *   1. Happy path — confirm dialog → `useDeleteSector.mutateAsync` →
 *      `listSectorsKey` invalidated → success toast.
 *   2. 409 sector_in_use — toast surfaces the structured detail.message,
 *      the row stays in the table, and no invalidation fires.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, screen, waitFor } from "@testing-library/react";
import { QueryClient } from "@tanstack/react-query";

interface SectorRow {
  id: string;
  name: string;
  short_name: string;
  description: string;
  display_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

let sectorsData: SectorRow[] = [];

const deleteSecMock = vi.fn().mockResolvedValue({ data: { ok: true } });

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListSectorsSuspense: () => ({ data: sectorsData }),
    listSectorsKey: () => ["listSectors"],
    useDeleteSector: () => ({
      mutateAsync: (vars: { params: { sector_id: string } }) =>
        deleteSecMock(vars.params),
    }),
    useCreateSector: () => ({ mutateAsync: vi.fn() }),
    useUpdateSector: () => ({ mutateAsync: vi.fn() }),
  };
});

vi.mock("@/lib/selector", () => ({
  selector: () => ({}),
  default: () => ({}),
}));

vi.mock("sonner", () => ({
  toast: { error: vi.fn(), success: vi.fn() },
}));

vi.mock("@/lib/notify", () => ({
  notifyError: vi.fn(),
}));

import { SectorsSection } from "@/routes/_sidebar/settings";
import { toast } from "sonner";
import { notifyError } from "@/lib/notify";
import { ApiError } from "@/lib/api";
import { renderWithRouter } from "./helpers/router-wrapper";

function makeSector(overrides: Partial<SectorRow>): SectorRow {
  return {
    id: "sec-1",
    name: "Retail & E-Commerce",
    short_name: "retail",
    description: "",
    display_order: 0,
    is_active: true,
    created_at: "2026-04-20T00:00:00Z",
    updated_at: "2026-04-20T00:00:00Z",
    ...overrides,
  };
}

let qc: QueryClient;

async function renderSection() {
  qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000 },
      mutations: { retry: false },
    },
  });
  const result = renderWithRouter(<SectorsSection />, { queryClient: qc });
  await waitFor(() => {
    expect(screen.getByTitle("Delete sector")).toBeInTheDocument();
  });
  return result;
}

beforeEach(() => {
  sectorsData = [];
  deleteSecMock.mockReset();
  deleteSecMock.mockResolvedValue({ data: { ok: true } });
  vi.mocked(toast.error).mockReset();
  vi.mocked(toast.success).mockReset();
  vi.mocked(notifyError).mockReset();
});

afterEach(() => {
  vi.clearAllMocks();
});

describe("SectorsSection — delete affordance", () => {
  it("invalidates listSectorsKey and shows success toast on a clean delete", async () => {
    sectorsData = [makeSector({})];
    await renderSection();
    const invalidateSpy = vi.spyOn(qc, "invalidateQueries");

    fireEvent.click(screen.getByTitle("Delete sector"));
    await waitFor(() => {
      expect(
        screen.getByText(/Delete "Retail & E-Commerce"\?/i),
      ).toBeInTheDocument();
    });

    // Click "Delete" — only the action button has plain text "Delete".
    fireEvent.click(screen.getByRole("button", { name: /^Delete$/ }));

    await waitFor(() => {
      expect(deleteSecMock).toHaveBeenCalledTimes(1);
    });
    expect(deleteSecMock.mock.calls[0][0]).toEqual({ sector_id: "sec-1" });

    await waitFor(() => {
      expect(vi.mocked(toast.success)).toHaveBeenCalledWith(
        'Sector "Retail & E-Commerce" deleted',
      );
    });
    expect(invalidateSpy).toHaveBeenCalledWith({
      queryKey: ["listSectors"],
    });
    expect(vi.mocked(toast.error)).not.toHaveBeenCalled();
  });

  it("surfaces the 409 sector_in_use message and keeps the row", async () => {
    sectorsData = [makeSector({})];
    // Real ApiError shape - body carries {detail: {error, sector_id, name,
    // business_count, message}} (matches the orval-generated client).
    const apiError = new ApiError(409, "Conflict", {
      detail: {
        error: "sector_in_use",
        sector_id: "sec-1",
        name: "Retail & E-Commerce",
        business_count: 2,
        message:
          "Sector 'Retail & E-Commerce' is used by 2 business(es)/industr(ies); reassign those first.",
      },
    });
    deleteSecMock.mockRejectedValueOnce(apiError);

    await renderSection();
    const invalidateSpy = vi.spyOn(qc, "invalidateQueries");

    fireEvent.click(screen.getByTitle("Delete sector"));
    await waitFor(() => {
      expect(
        screen.getByText(/Delete "Retail & E-Commerce"\?/i),
      ).toBeInTheDocument();
    });
    fireEvent.click(screen.getByRole("button", { name: /^Delete$/ }));

    await waitFor(() => {
      expect(vi.mocked(notifyError)).toHaveBeenCalledWith(
        apiError,
        expect.objectContaining({ fallback: expect.stringContaining("Retail & E-Commerce") }),
      );
    });
    expect(vi.mocked(toast.success)).not.toHaveBeenCalled();
    expect(vi.mocked(toast.error)).not.toHaveBeenCalled();
    expect(invalidateSpy).not.toHaveBeenCalled();
    expect(
      screen.getAllByText("Retail & E-Commerce").length,
    ).toBeGreaterThanOrEqual(1);
  });
});
