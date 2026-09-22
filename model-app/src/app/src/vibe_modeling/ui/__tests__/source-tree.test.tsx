/**
 * `SourceTree` tests - folder-faithful Industry -> Version -> Scope browse.
 *
 * Mocks the `@/lib/api` hooks so the tree renders synchronously. We assert:
 *   1. Empty sectors -> "No sectors published in this source."
 *   2. `provides_sectors: false` (GitHub today) hides the synthetic sector and
 *      renders industries at the root.
 *   3. Happy path -> expand industry -> version -> scope, select a model leaf,
 *      and the `onSelect` payload carries the `suggestedSectorId` resolved by
 *      matching the source sector name against the local sector catalog.
 *   4. Two versions render as two groups, newest first.
 *   5. `provides_sectors: true` (a future source) keeps the outer sector tier.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, screen, waitFor } from "@testing-library/react";

// The suspense list hooks are called with `selector()`, which unwraps the
// `.data` envelope — so these mocks return the already-unwrapped array under
// `data`. The non-suspense `useListSourceIndustries`/`useListSourceModels`
// hooks are called WITHOUT a selector, so the component reads `data?.data`;
// those mocks keep the full `{ data: { data: [...] } }` envelope.
let sourceSectorsHook: () => unknown = () => ({ data: [] });
let localSectorsHook: () => unknown = () => ({ data: [] });
let sourceIndustriesHook: () => unknown = () => ({
  data: { data: [] },
  isLoading: false,
});
let sourceModelsHook: () => unknown = () => ({
  data: { data: [] },
  isLoading: false,
});

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListSourceSectorsSuspense: () => sourceSectorsHook(),
    useListSectorsSuspense: () => localSectorsHook(),
    useListSourceIndustries: () => sourceIndustriesHook(),
    useListSourceModels: () => sourceModelsHook(),
  };
});

import { SourceTree } from "@/components/source-explorer/source-tree";
import { renderWithRouter } from "./helpers/router-wrapper";

const GITHUB_CAPS = {
  source_kind: "github",
  discovery_mode: "eager_listing",
  materialization_timing: "at_rest",
  provides_sectors: false,
  read_only: true,
  target_kinds: [],
} as any;

beforeEach(() => {
  sourceSectorsHook = () => ({ data: [] });
  localSectorsHook = () => ({ data: [] });
  sourceIndustriesHook = () => ({ data: { data: [] }, isLoading: false });
  sourceModelsHook = () => ({ data: { data: [] }, isLoading: false });
});

afterEach(() => {
  vi.restoreAllMocks();
});

describe("SourceTree", () => {
  it("renders the empty state when the source has no sectors", async () => {
    renderWithRouter(<SourceTree onSelect={vi.fn()} />);
    expect(
      await screen.findByText("No sectors published in this source."),
    ).toBeInTheDocument();
  });

  it("hides the synthetic sector and renders industries at the root when provides_sectors is false", async () => {
    sourceSectorsHook = () => ({
      data: [{ id: "_repo", name: "owner/repo" }],
    });
    localSectorsHook = () => ({ data: [] });
    sourceIndustriesHook = () => ({
      data: { data: [{ id: "ind-bank", name: "Banking", sector_id: "_repo" }] },
      isLoading: false,
    });

    renderWithRouter(
      <SourceTree onSelect={vi.fn()} capabilities={GITHUB_CAPS} />,
    );

    expect(await screen.findByText("Banking")).toBeInTheDocument();
    expect(screen.queryByText("owner/repo")).not.toBeInTheDocument();
  });

  it("browses industry -> version -> scope and emits a selection with the mapped local sector", async () => {
    sourceSectorsHook = () => ({
      data: [{ id: "_repo", name: "Financial Services" }],
    });
    // Local sector with a name matching the source sector (case-insensitive).
    localSectorsHook = () => ({
      data: [{ id: "local-fin", name: "financial services" }],
    });
    sourceIndustriesHook = () => ({
      data: { data: [{ id: "ind-bank", name: "Banking", sector_id: "_repo" }] },
      isLoading: false,
    });
    // id is the fused `<version>_<scope>`, version is the dir name "v1" (NOT
    // "1"), scope is the explicit dir name.
    sourceModelsHook = () => ({
      data: {
        data: [
          {
            id: "v1_ecm",
            industry_id: "ind-bank",
            name: "Ecm V1",
            version: "v1",
            scope: "ecm",
          },
        ],
      },
      isLoading: false,
    });

    const onSelect = vi.fn();
    renderWithRouter(
      <SourceTree onSelect={onSelect} capabilities={GITHUB_CAPS} />,
    );

    // Expand industry (sector level is hidden for provides_sectors=false).
    fireEvent.click(await screen.findByText("Banking"));
    // Expand version.
    await waitFor(() => expect(screen.getByText("v1")).toBeInTheDocument());
    fireEvent.click(screen.getByText("v1"));
    // Select the scope leaf.
    await waitFor(() =>
      expect(screen.getByText("Ecm V1")).toBeInTheDocument(),
    );

    // The version badge on the leaf renders the dir name verbatim ("v1"), NOT
    // "vv1" - the component must not re-prefix a "v" onto an already-"vN"
    // version.
    expect(screen.queryByText("vv1")).not.toBeInTheDocument();
    // The scope badge renders the upper-cased scope.
    expect(screen.getByText("ECM")).toBeInTheDocument();

    fireEvent.click(screen.getByText("Ecm V1"));

    expect(onSelect).toHaveBeenCalledWith({
      industryId: "ind-bank",
      industryName: "Banking",
      modelId: "v1_ecm",
      scope: "ecm",
      suggestedSectorId: "local-fin",
    });
  });

  it("groups models into two version nodes, newest first", async () => {
    sourceSectorsHook = () => ({ data: [{ id: "_repo", name: "Repo" }] });
    localSectorsHook = () => ({ data: [] });
    sourceIndustriesHook = () => ({
      data: { data: [{ id: "ind-bank", name: "Banking", sector_id: "_repo" }] },
      isLoading: false,
    });
    sourceModelsHook = () => ({
      data: {
        data: [
          { id: "v1_ecm", industry_id: "ind-bank", name: "Ecm V1", version: "v1", scope: "ecm" },
          { id: "v2_ecm", industry_id: "ind-bank", name: "Ecm V2", version: "v2", scope: "ecm" },
        ],
      },
      isLoading: false,
    });

    renderWithRouter(<SourceTree onSelect={vi.fn()} capabilities={GITHUB_CAPS} />);
    fireEvent.click(await screen.findByText("Banking"));

    const v1 = await screen.findByText("v1");
    const v2 = await screen.findByText("v2");
    expect(v1).toBeInTheDocument();
    expect(v2).toBeInTheDocument();
    // Newest first in DOM order.
    expect(
      v2.compareDocumentPosition(v1) & Node.DOCUMENT_POSITION_FOLLOWING,
    ).toBeTruthy();
  });

  it("flags a scope leaf as 'Downloaded' only for the (industry, scope) present in the map", async () => {
    sourceSectorsHook = () => ({ data: [{ id: "_repo", name: "Repo" }] });
    localSectorsHook = () => ({ data: [] });
    sourceIndustriesHook = () => ({
      data: { data: [{ id: "ind-bank", name: "Banking", sector_id: "_repo" }] },
      isLoading: false,
    });
    sourceModelsHook = () => ({
      data: {
        data: [
          { id: "v1_ecm", industry_id: "ind-bank", name: "Retail Bank ECM", version: "v1", scope: "ecm" },
          { id: "v1_mvm", industry_id: "ind-bank", name: "Retail Bank MVM", version: "v1", scope: "mvm" },
        ],
      },
      isLoading: false,
    });

    // ECM downloaded, MVM not - only the ECM leaf should be flagged.
    renderWithRouter(
      <SourceTree
        onSelect={vi.fn()}
        capabilities={GITHUB_CAPS}
        downloadedScopesByIndustry={new Map([["banking", new Set(["ecm"])]])}
      />,
    );
    fireEvent.click(await screen.findByText("Banking"));
    fireEvent.click(await screen.findByText("v1"));
    await waitFor(() =>
      expect(screen.getByText("Retail Bank ECM")).toBeInTheDocument(),
    );

    const badges = screen.getAllByTestId("already-downloaded-badge");
    expect(badges).toHaveLength(1);
    expect(
      screen.getByText("Retail Bank ECM").closest("button"),
    ).toContainElement(badges[0]);
  });

  it("emits a null suggestedSectorId when no local sector name matches", async () => {
    sourceSectorsHook = () => ({
      data: [{ id: "_repo", name: "Healthcare" }],
    });
    localSectorsHook = () => ({ data: [{ id: "local-fin", name: "Finance" }] });
    sourceIndustriesHook = () => ({
      data: { data: [{ id: "ind-hc", name: "Hospitals", sector_id: "_repo" }] },
      isLoading: false,
    });
    sourceModelsHook = () => ({
      data: {
        data: [{ id: "m-2", industry_id: "ind-hc", name: "Patient", version: "v1", scope: "ecm" }],
      },
      isLoading: false,
    });

    const onSelect = vi.fn();
    renderWithRouter(
      <SourceTree onSelect={onSelect} capabilities={GITHUB_CAPS} />,
    );
    fireEvent.click(await screen.findByText("Hospitals"));
    await waitFor(() => expect(screen.getByText("v1")).toBeInTheDocument());
    fireEvent.click(screen.getByText("v1"));
    await waitFor(() => expect(screen.getByText("Patient")).toBeInTheDocument());
    fireEvent.click(screen.getByText("Patient"));

    expect(onSelect).toHaveBeenCalledWith({
      industryId: "ind-hc",
      industryName: "Hospitals",
      modelId: "m-2",
      scope: "ecm",
      suggestedSectorId: null,
    });
  });

  it("keeps the outer sector tier when the source declares provides_sectors: true", async () => {
    sourceSectorsHook = () => ({
      data: [{ id: "s-fin", name: "Financial Services" }],
    });
    localSectorsHook = () => ({ data: [] });
    sourceIndustriesHook = () => ({
      data: { data: [{ id: "ind-bank", name: "Banking", sector_id: "s-fin" }] },
      isLoading: false,
    });

    renderWithRouter(
      <SourceTree
        onSelect={vi.fn()}
        capabilities={{ ...GITHUB_CAPS, provides_sectors: true }}
      />,
    );

    expect(
      await screen.findByText("Financial Services"),
    ).toBeInTheDocument();
    expect(screen.queryByText("Banking")).not.toBeInTheDocument();
    fireEvent.click(screen.getByText("Financial Services"));
    expect(await screen.findByText("Banking")).toBeInTheDocument();
  });
});
