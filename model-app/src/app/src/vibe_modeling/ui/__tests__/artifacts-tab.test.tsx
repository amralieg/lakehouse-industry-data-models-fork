import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactNode } from "react";

vi.mock("@/lib/api", async () => ({
  useListArtifactsSuspense: ({ params }: { params: { run_id: string } }) => ({
    data: [
      {
        id: "a1",
        run_id: params.run_id,
        artifact_type: "readme",
        file_path: "/Volumes/c/s/v/docs/readme.md",
        created_at: "2026-04-01",
      },
      {
        id: "a2",
        run_id: params.run_id,
        artifact_type: "json",
        file_path: "/Volumes/c/s/v/model.json",
        created_at: "2026-04-01",
      },
      {
        id: "a3",
        run_id: params.run_id,
        artifact_type: "binary",
        file_path: "/Volumes/c/s/v/export.parquet",
        created_at: "2026-04-01",
      },
      {
        id: "a4",
        run_id: params.run_id,
        artifact_type: "ddl",
        file_path: "/Volumes/c/s/v/ddl/customers.sql",
        created_at: "2026-04-01",
      },
      {
        id: "a5",
        run_id: params.run_id,
        artifact_type: "rdf",
        file_path: "/Volumes/c/s/v/ontology/model.ttl",
        created_at: "2026-04-01",
      },
    ],
  }),
  getArtifactContent: vi.fn().mockImplementation(
    (params: { artifact_id: string; format?: string }) => {
      if (params.format === "hex") {
        return Promise.resolve({
          data: {
            hex: "50415231deadbeef",
            size_bytes: 8,
            bytes_previewed: 8,
            truncated: false,
          },
        });
      }
      if (params.artifact_id === "a2") {
        return Promise.resolve({
          data: {
            content: '{"name": "model"}',
            truncated: false,
            size_bytes: 17,
          },
        });
      }
      if (params.artifact_id === "a4") {
        return Promise.resolve({
          data: {
            content:
              "CREATE TABLE customers (\n  id INTEGER PRIMARY KEY,\n  name TEXT NOT NULL\n);",
            truncated: false,
            size_bytes: 80,
          },
        });
      }
      if (params.artifact_id === "a5") {
        return Promise.resolve({
          data: {
            content:
              "@prefix ex: <http://example.org/> .\nex:Alice a ex:Person ;\n  ex:name \"Alice\" .",
            truncated: false,
            size_bytes: 80,
          },
        });
      }
      return Promise.resolve({
        data: {
          content:
            "# Sample README\n\nGenerated content.\n\n- bullet one\n- bullet two\n\n```\ncode block\n```",
          truncated: false,
          size_bytes: 80,
        },
      });
    },
  ),
}));

import { ArtifactsTab } from "@/components/artifacts/artifacts-tab";
import { getArtifactContent } from "@/lib/api";

function withQuery(ui: ReactNode) {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return <QueryClientProvider client={qc}>{ui}</QueryClientProvider>;
}

describe("ArtifactsTab", () => {
  it("renders all artifacts grouped by type", () => {
    render(withQuery(<ArtifactsTab businessId="biz-1"
          runId="r1" />));
    expect(screen.getByText(/Artifacts \(5\)/)).toBeInTheDocument();
    expect(screen.getByText("readme.md")).toBeInTheDocument();
    expect(screen.getByText("model.json")).toBeInTheDocument();
    expect(screen.getByText("export.parquet")).toBeInTheDocument();
    expect(screen.getByText("customers.sql")).toBeInTheDocument();
    expect(screen.getByText("model.ttl")).toBeInTheDocument();
  });

  it("exposes a bulk download link", () => {
    render(withQuery(<ArtifactsTab businessId="biz-1"
          runId="run-abc-123" />));
    const bulk = screen.getByRole("link", { name: /download all/i });
    expect(bulk).toHaveAttribute(
      "href",
      "/api/businesses/biz-1/runs/run-abc-123/artifacts/download",
    );
  });

  it("exposes a per-artifact download link", () => {
    render(withQuery(<ArtifactsTab businessId="biz-1"
          runId="r1" />));
    const perFile = screen.getByRole("link", { name: /download readme\.md/i });
    expect(perFile).toHaveAttribute(
      "href",
      "/api/businesses/biz-1/runs/r1/artifacts/a1/download",
    );
  });

  it("expands text artifacts to show inline content", async () => {
    render(withQuery(<ArtifactsTab businessId="biz-1"
          runId="r1" />));
    const toggle = screen.getByRole("button", { name: /expand preview for readme\.md/i });
    fireEvent.click(toggle);
    await waitFor(() => {
      expect(getArtifactContent).toHaveBeenCalledWith({
        business_id: "biz-1",
        run_id: "r1",
        artifact_id: "a1",
        format: "text",
      });
    });
    expect(await screen.findByText(/Sample README/)).toBeInTheDocument();
  });

  it("renders markdown artifacts with heading, bullets, and code block", async () => {
    render(withQuery(<ArtifactsTab businessId="biz-1"
          runId="r1" />));
    const toggle = screen.getByRole("button", { name: /expand preview for readme\.md/i });
    fireEvent.click(toggle);
    const heading = await screen.findByRole("heading", {
      name: /Sample README/,
    });
    expect(heading.tagName).toBe("H1");
    expect(screen.getByText("bullet one")).toBeInTheDocument();
    expect(screen.getByText("bullet two")).toBeInTheDocument();
    const codeEl = screen.getByText(/code block/);
    expect(codeEl.tagName.toLowerCase()).toBe("code");
  });

  it("formats json artifacts in a readable <pre> block", async () => {
    render(withQuery(<ArtifactsTab businessId="biz-1"
          runId="r1" />));
    const toggle = screen.getByRole("button", { name: /expand preview for model\.json/i });
    fireEvent.click(toggle);
    const jsonPre = await screen.findByText((_, el) => {
      return el?.tagName === "PRE" && !!el?.textContent?.includes('"name"') && !!el?.textContent?.includes("model");
    });
    expect(jsonPre.tagName.toLowerCase()).toBe("pre");
  });

  it("highlights SQL artifacts with Prism token classes", async () => {
    const { container } = render(
      withQuery(<ArtifactsTab businessId="biz-1" runId="r1" />),
    );
    const toggle = screen.getByRole("button", {
      name: /expand preview for customers\.sql/i,
    });
    fireEvent.click(toggle);
    const block = await screen.findByTestId("highlighted-text");
    expect(block).toBeInTheDocument();
    await waitFor(() => {
      expect(container.querySelectorAll(".token").length).toBeGreaterThan(0);
    });
  });

  it("highlights Turtle artifacts with Prism token classes", async () => {
    const { container } = render(
      withQuery(<ArtifactsTab businessId="biz-1" runId="r1" />),
    );
    const toggle = screen.getByRole("button", {
      name: /expand preview for model\.ttl/i,
    });
    fireEvent.click(toggle);
    const block = await screen.findByTestId("highlighted-text");
    expect(block).toBeInTheDocument();
    await waitFor(() => {
      expect(container.querySelectorAll(".token").length).toBeGreaterThan(0);
    });
  });

  it("expands binary artifacts to show a hex preview", async () => {
    render(withQuery(<ArtifactsTab businessId="biz-1"
          runId="r1" />));
    const toggle = screen.getByRole("button", { name: /expand preview for export\.parquet/i });
    expect(toggle).not.toBeDisabled();
    fireEvent.click(toggle);
    await waitFor(() => {
      expect(getArtifactContent).toHaveBeenCalledWith({
        business_id: "biz-1",
        run_id: "r1",
        artifact_id: "a3",
        format: "hex",
      });
    });
    expect(await screen.findByText(/50415231deadbeef/i)).toBeInTheDocument();
    expect(screen.getByText(/Binary file/i)).toBeInTheDocument();
  });
});

describe("ArtifactsTab empty state", () => {
  it("renders a friendly empty message when no artifacts exist", async () => {
    vi.resetModules();
    vi.doMock("@/lib/api", () => ({
      useListArtifactsSuspense: () => ({ data: [] }),
      getArtifactContent: vi.fn(),
    }));
    const { ArtifactsTab: EmptyArtifactsTab } = await import(
      "@/components/artifacts/artifacts-tab"
    );
    render(withQuery(<EmptyArtifactsTab businessId="biz-1" runId="r-empty" />));
    expect(
      screen.getByText(/No artifacts were produced/i),
    ).toBeInTheDocument();
  });
});
