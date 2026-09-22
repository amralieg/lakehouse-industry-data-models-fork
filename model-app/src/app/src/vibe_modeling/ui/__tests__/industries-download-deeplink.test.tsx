/**
 * The industries list "Download from source" header button opens the source
 * explorer DIALOG in place (the explorer is no longer a navigable route). No
 * navigation happens; the dialog mounts and hosts the browse tree.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, screen, waitFor } from "@testing-library/react";

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetAgentConfig: vi.fn(),
    useListBusinessesSuspense: vi.fn(),
    useListSectorsSuspense: vi.fn(),
    useDeleteBusiness: vi.fn(),
    useGetSourceCapabilitiesSuspense: vi.fn(),
    useListSourceSectorsSuspense: vi.fn(),
  };
});

import {
  useGetAgentConfig,
  useListBusinessesSuspense,
  useListSectorsSuspense,
  useDeleteBusiness,
  useGetSourceCapabilitiesSuspense,
  useListSourceSectorsSuspense,
} from "@/lib/api";
import { IndustriesIndexPage } from "@/routes/_sidebar/industries.index";
import { renderWithRouter } from "./helpers/router-wrapper";

beforeEach(() => {
  vi.mocked(useGetAgentConfig).mockReturnValue({
    data: { notebook_path: "/Workspace/agent" },
    isError: false,
    isLoading: false,
  } as any);
  vi.mocked(useListBusinessesSuspense).mockReturnValue({ data: [] } as any);
  vi.mocked(useListSectorsSuspense).mockReturnValue({ data: [] } as any);
  vi.mocked(useDeleteBusiness).mockReturnValue({ mutateAsync: vi.fn() } as any);
  // Source-explorer dialog body hooks (only run once the dialog opens).
  vi.mocked(useGetSourceCapabilitiesSuspense).mockReturnValue({
    data: { source_kind: "github", read_only: true },
  } as any);
  vi.mocked(useListSourceSectorsSuspense).mockReturnValue({ data: [] } as any);
});

afterEach(() => vi.restoreAllMocks());

describe("industries 'Download from source' button", () => {
  it("opens the source explorer dialog in place, with no navigation", async () => {
    const { router } = renderWithRouter(<IndustriesIndexPage />, {
      initialPath: "/industries",
    });

    // It is a button, not a link — no href to /sources.
    const trigger = await screen.findByRole("button", {
      name: /Download from source/i,
    });
    expect(screen.queryByRole("link", { name: /Download from source/i })).toBeNull();

    await act(async () => {
      fireEvent.click(trigger);
    });

    // The dialog opens (browse copy renders) and the URL did NOT change.
    await waitFor(() =>
      expect(
        screen.getByText(/Browse published industry models/i),
      ).toBeInTheDocument(),
    );
    expect(router.state.location.pathname).toBe("/industries");
  });
});
