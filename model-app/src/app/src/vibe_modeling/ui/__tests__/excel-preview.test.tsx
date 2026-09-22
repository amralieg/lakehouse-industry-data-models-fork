import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import * as XLSX from "xlsx";
import { ExcelPreview } from "@/components/artifacts/excel-preview";

function buildWorkbookBytes(
  sheets: Array<{ name: string; rows: unknown[][] }>,
): ArrayBuffer {
  const wb = XLSX.utils.book_new();
  for (const { name, rows } of sheets) {
    const ws = XLSX.utils.aoa_to_sheet(rows);
    XLSX.utils.book_append_sheet(wb, ws, name);
  }
  const out = XLSX.write(wb, { type: "array", bookType: "xlsx" });
  return out instanceof ArrayBuffer ? out : new Uint8Array(out).buffer;
}

describe("ExcelPreview", () => {
  const realFetch = globalThis.fetch;

  beforeEach(() => {
    vi.restoreAllMocks();
  });

  afterEach(() => {
    globalThis.fetch = realFetch;
  });

  it("renders a loading skeleton while fetching", () => {
    globalThis.fetch = vi.fn().mockReturnValue(new Promise(() => {})) as never;
    render(<ExcelPreview src="/api/.../download?inline=1" filename="data.xlsx" />);
    expect(screen.getByTestId("excel-preview-loading")).toBeInTheDocument();
  });

  it("renders the first sheet as an HTML table", async () => {
    const buf = buildWorkbookBytes([
      {
        name: "People",
        rows: [
          ["Name", "Score"],
          ["Alice", 42],
          ["Bob", 17],
        ],
      },
    ]);
    globalThis.fetch = vi.fn().mockResolvedValue({
      ok: true,
      arrayBuffer: () => Promise.resolve(buf),
    }) as never;

    render(<ExcelPreview src="/api/x" filename="data.xlsx" />);

    await waitFor(() => {
      expect(screen.getByTestId("excel-preview")).toBeInTheDocument();
    });
    expect(screen.getByRole("columnheader", { name: "Name" })).toBeInTheDocument();
    expect(screen.getByRole("columnheader", { name: "Score" })).toBeInTheDocument();
    expect(screen.getByRole("cell", { name: "Alice" })).toBeInTheDocument();
    expect(screen.getByRole("cell", { name: "42" })).toBeInTheDocument();
    expect(screen.getByRole("cell", { name: "Bob" })).toBeInTheDocument();
  });

  it("exposes a tablist with a tab per sheet when there are multiple sheets", async () => {
    const buf = buildWorkbookBytes([
      { name: "Alpha", rows: [["a"]] },
      { name: "Beta", rows: [["b"]] },
    ]);
    globalThis.fetch = vi.fn().mockResolvedValue({
      ok: true,
      arrayBuffer: () => Promise.resolve(buf),
    }) as never;

    render(<ExcelPreview src="/api/x" filename="multi.xlsx" />);

    await waitFor(() => {
      expect(screen.getByTestId("excel-preview")).toBeInTheDocument();
    });
    expect(screen.getByRole("tab", { name: "Alpha" })).toBeInTheDocument();
    expect(screen.getByRole("tab", { name: "Beta" })).toBeInTheDocument();
  });

  it("surfaces a fetch error to the user", async () => {
    globalThis.fetch = vi.fn().mockResolvedValue({
      ok: false,
      status: 500,
      arrayBuffer: () => Promise.resolve(new ArrayBuffer(0)),
    }) as never;

    render(<ExcelPreview src="/api/x" filename="broken.xlsx" />);

    await waitFor(() => {
      expect(
        screen.getByText(/Could not load spreadsheet preview/i),
      ).toBeInTheDocument();
    });
  });
});
