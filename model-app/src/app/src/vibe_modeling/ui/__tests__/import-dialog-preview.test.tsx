/**
 * Preview surface coverage for `ImportModelDialog`.
 *
 * Asserts:
 *  - missing ``next_vibes`` renders the warning banner with the agreed copy;
 *  - found ``next_vibes`` (.txt or .json) renders the success line;
 *  - missing ``model.json`` disables the Analyze button so submit is blocked.
 */
import { beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    analyzeImport: vi.fn(),
    executeImport: vi.fn(),
    getImportPreview: vi.fn(),
  };
});

import { analyzeImport, executeImport, getImportPreview } from "@/lib/api";
import { ImportModelDialog } from "@/components/import/import-dialog";

const mockedAnalyze = vi.mocked(analyzeImport);
const mockedExecute = vi.mocked(executeImport);
const mockedPreview = vi.mocked(getImportPreview);

function withQuery(ui: React.ReactNode) {
  const qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });
  return <QueryClientProvider client={qc}>{ui}</QueryClientProvider>;
}

beforeEach(() => {
  mockedAnalyze.mockReset();
  mockedExecute.mockReset();
  mockedPreview.mockReset();
});

async function openAndTypePath(path: string) {
  render(
    withQuery(
      <ImportModelDialog
        businessId="biz-1"
        trigger={<button type="button">Open import</button>}
      />,
    ),
  );
  fireEvent.click(screen.getByRole("button", { name: /Open import/i }));
  const input = await screen.findByPlaceholderText(/\/Volumes\/catalog/);
  fireEvent.change(input, { target: { value: path } });
}

describe("ImportModelDialog — preview", () => {
  it("renders the missing-next-vibes warning banner with the agreed copy", async () => {
    mockedPreview.mockResolvedValue({
      data: {
        model_json_found: true,
        next_vibes_status: "missing",
        next_vibes_path: null,
        companion_artifacts: [],
        total_artifact_count: 0,
      },
    });

    await openAndTypePath("/Volumes/cat/sch/vibes/model.json");

    const warning = await screen.findByTestId(
      "preview-next-vibes-missing-warning",
    );
    expect(warning).toBeInTheDocument();
    expect(warning).toHaveTextContent(/next_vibes\.txt/);
    expect(warning).toHaveTextContent(/cannot be reconstructed/);
    // Analyze stays enabled — missing next_vibes does not block import.
    expect(screen.getByRole("button", { name: /^Analyze$/i })).not.toBeDisabled();
  });

  it("renders a success line when next_vibes.txt is found", async () => {
    mockedPreview.mockResolvedValue({
      data: {
        model_json_found: true,
        next_vibes_status: "txt",
        next_vibes_path: "/Volumes/c/s/v/vibes/next_vibes.txt",
        companion_artifacts: [
          { path: "/Volumes/c/s/v/readme.md", artifact_type: "readme", size_bytes: 100 },
        ],
        total_artifact_count: 1,
      },
    });

    await openAndTypePath("/Volumes/c/s/v/model.json");

    const success = await screen.findByTestId("preview-next-vibes-success");
    expect(success).toHaveTextContent(/Next vibes will be imported/);
    expect(success).toHaveTextContent(/\.txt/);
    expect(
      screen.queryByTestId("preview-next-vibes-missing-warning"),
    ).not.toBeInTheDocument();
  });

  it("renders a success line when next_vibes.json is found", async () => {
    mockedPreview.mockResolvedValue({
      data: {
        model_json_found: true,
        next_vibes_status: "json",
        next_vibes_path: "/Volumes/c/s/v/vibes/next_vibes.json",
        companion_artifacts: [],
        total_artifact_count: 0,
      },
    });

    await openAndTypePath("/Volumes/c/s/v/model.json");

    const success = await screen.findByTestId("preview-next-vibes-success");
    expect(success).toHaveTextContent(/\.json/);
  });

  it("blocks Analyze when model.json is missing at the path", async () => {
    mockedPreview.mockResolvedValue({
      data: {
        model_json_found: false,
        next_vibes_status: "missing",
        next_vibes_path: null,
        companion_artifacts: [],
        total_artifact_count: 0,
      },
    });

    await openAndTypePath("/Volumes/c/s/wrong/path");

    // Wait for the preview card to render its missing-model.json indicator.
    await screen.findByTestId("preview-model-json-missing");
    // Analyze button should be disabled.
    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: /^Analyze$/i }),
      ).toBeDisabled();
    });
  });

  it("does not fetch preview before the user has typed a /Volumes/ path", async () => {
    render(
      withQuery(
        <ImportModelDialog
          businessId="biz-1"
          trigger={<button type="button">Open import</button>}
        />,
      ),
    );
    fireEvent.click(screen.getByRole("button", { name: /Open import/i }));
    // Dialog rendered, no path typed. Preview fetch must not fire.
    await waitFor(() => {
      expect(mockedPreview).not.toHaveBeenCalled();
    });
  });
});
