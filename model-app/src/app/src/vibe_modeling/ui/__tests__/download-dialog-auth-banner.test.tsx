/**
 * Track 4 finding #6: the Industries "Download from source" dialog renders the
 * SAME anonymous-mode rate-limit banner as Settings -> Sources (one shared
 * `SourceAuthBanner`), instead of showing nothing.
 *
 * The dialog's browse composition (tree, preview, per-model download) is
 * mocked out so this test isolates the banner wiring on the dialog shell.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetSourceCapabilitiesSuspense: vi.fn(),
    useGetSourceCapabilities: vi.fn(),
    useListBusinessesSuspense: vi.fn(),
  };
});

// Isolate the shell: the browse-tree / preview / download children have their
// own coverage and pull heavier suspense graphs.
vi.mock("@/components/source-explorer/source-tree", () => ({ SourceTree: () => null }));
vi.mock("@/components/source-explorer/source-capability-banner", () => ({
  SourceCapabilityBanner: () => null,
}));
vi.mock("@/components/source-explorer/source-model-preview", () => ({
  SourceModelPreview: () => null,
}));
vi.mock("@/components/import/download-industry-dialog", () => ({
  DownloadIndustryDialog: () => null,
}));
vi.mock("@/components/source-explorer/download-complete-dialog", () => ({
  DownloadCompleteDialog: () => null,
}));

import {
  useGetSourceCapabilitiesSuspense,
  useGetSourceCapabilities,
  useListBusinessesSuspense,
} from "@/lib/api";
import { SourceExplorerDialog } from "@/components/source-explorer/source-explorer-dialog";

function setAuthMode(mode: string) {
  vi.mocked(useGetSourceCapabilities).mockReturnValue({
    data: { data: { auth_mode: mode } },
  } as any);
}

beforeEach(() => {
  vi.mocked(useGetSourceCapabilitiesSuspense).mockReturnValue({
    data: { source_kind: "github", read_only: true, auth_mode: "anonymous" },
  } as any);
  vi.mocked(useListBusinessesSuspense).mockReturnValue({ data: [] } as any);
});

afterEach(() => vi.restoreAllMocks());

function renderDialog() {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={qc}>
      <SourceExplorerDialog open onOpenChange={() => {}} />
    </QueryClientProvider>,
  );
}

describe("Download-from-source dialog auth banner", () => {
  it("shows the unauthenticated rate-limit banner when auth_mode is anonymous", async () => {
    setAuthMode("anonymous");
    renderDialog();
    await waitFor(() =>
      expect(
        screen.getByText(/Browsing unauthenticated - GitHub limits this to 60/i),
      ).toBeInTheDocument(),
    );
  });

  it("renders no banner for an authenticated (github_app) mode", async () => {
    setAuthMode("github_app");
    renderDialog();
    // The dialog itself renders (its browse copy is present)...
    await waitFor(() =>
      expect(screen.getByText(/Browse published industry models/i)).toBeInTheDocument(),
    );
    // ...but the anonymous banner does not.
    expect(screen.queryByText(/Browsing unauthenticated/i)).toBeNull();
  });
});
