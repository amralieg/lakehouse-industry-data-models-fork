import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";

const toastError = vi.fn();
vi.mock("sonner", () => ({ toast: { error: (...a: unknown[]) => toastError(...a) } }));

import {
  ExportReportButton,
  parseFilename,
} from "@/components/report-export/export-report-button";

describe("parseFilename", () => {
  it("extracts a plain filename", () => {
    expect(
      parseFilename('attachment; filename="statistics-report-v4-mvm.xlsx"'),
    ).toBe("statistics-report-v4-mvm.xlsx");
  });

  it("prefers RFC 5987 filename*", () => {
    expect(
      parseFilename("attachment; filename=\"f.xlsx\"; filename*=UTF-8''r%C3%A9port.xlsx"),
    ).toBe("réport.xlsx");
  });

  it("returns undefined when absent", () => {
    expect(parseFilename(null)).toBeUndefined();
    expect(parseFilename("attachment")).toBeUndefined();
  });
});

describe("ExportReportButton", () => {
  let clickSpy: ReturnType<typeof vi.fn>;
  let createdAnchor: { href: string; download: string } | null;

  beforeEach(() => {
    toastError.mockClear();
    createdAnchor = null;
    clickSpy = vi.fn();

    // Object URL stubs (jsdom has no real impl).
    URL.createObjectURL = vi.fn(() => "blob:fake");
    URL.revokeObjectURL = vi.fn();

    // Capture the synthetic anchor used to trigger the download.
    const realCreate = document.createElement.bind(document);
    vi.spyOn(document, "createElement").mockImplementation((tag: string) => {
      const el = realCreate(tag);
      if (tag === "a") {
        const anchor = el as HTMLAnchorElement;
        anchor.click = clickSpy as unknown as () => void;
        createdAnchor = anchor;
      }
      return el;
    });
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("renders an outline Export report button with the file-text icon", () => {
    const { container } = render(
      <ExportReportButton businessId="b1" version={4} scope="mvm" />,
    );
    const btn = screen.getByRole("button", { name: /export report/i });
    expect(btn).toBeInTheDocument();
    // lucide renders an inline svg icon.
    expect(container.querySelector("svg")).not.toBeNull();
  });

  it("fetches the export endpoint and triggers a download", async () => {
    const blob = new Blob(["xlsx-bytes"]);
    const fetchMock = vi.fn().mockResolvedValue({
      ok: true,
      blob: () => Promise.resolve(blob),
      headers: {
        get: (k: string) =>
          k.toLowerCase() === "content-disposition"
            ? 'attachment; filename="statistics-report-v4-mvm.xlsx"'
            : null,
      },
    });
    vi.stubGlobal("fetch", fetchMock);

    render(<ExportReportButton businessId="b1" version={4} scope="mvm" />);
    fireEvent.click(screen.getByRole("button", { name: /export report/i }));

    await waitFor(() => expect(clickSpy).toHaveBeenCalled());
    expect(fetchMock).toHaveBeenCalledWith(
      "/api/businesses/b1/versions/4/mvm/statistics-report.xlsx",
      expect.any(Object),
    );
    expect(createdAnchor?.download).toBe("statistics-report-v4-mvm.xlsx");
    expect(URL.createObjectURL).toHaveBeenCalledWith(blob);
    expect(toastError).not.toHaveBeenCalled();
  });

  it("falls back to a default filename when the header is missing", async () => {
    const fetchMock = vi.fn().mockResolvedValue({
      ok: true,
      blob: () => Promise.resolve(new Blob(["x"])),
      headers: { get: () => null },
    });
    vi.stubGlobal("fetch", fetchMock);

    render(<ExportReportButton businessId="b9" version={2} scope="ecm" />);
    fireEvent.click(screen.getByRole("button", { name: /export report/i }));

    await waitFor(() => expect(clickSpy).toHaveBeenCalled());
    expect(createdAnchor?.download).toBe("statistics-report-v2-ecm.xlsx");
  });

  it("surfaces an error toast on a failed response and does not download", async () => {
    const fetchMock = vi.fn().mockResolvedValue({
      ok: false,
      status: 500,
      blob: () => Promise.resolve(new Blob()),
      headers: { get: () => null },
    });
    vi.stubGlobal("fetch", fetchMock);

    render(<ExportReportButton businessId="b1" version={4} scope="mvm" />);
    fireEvent.click(screen.getByRole("button", { name: /export report/i }));

    await waitFor(() => expect(toastError).toHaveBeenCalled());
    expect(clickSpy).not.toHaveBeenCalled();
  });
});
