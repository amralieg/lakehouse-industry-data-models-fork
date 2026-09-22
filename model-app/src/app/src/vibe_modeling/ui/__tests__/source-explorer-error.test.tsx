/**
 * `SourceExplorerError` tests — the source-explorer dialog's error boundary.
 *
 * Re-homed from the deleted `/sources` route into
 * `components/source-explorer/source-explorer-dialog.tsx`. It tailors copy per
 * backend status: 404 (`SourceNotFoundError`) and 502 (`Source unavailable`)
 * get specific titles; everything else gets a generic shell. A Retry button is
 * always present (the dialog itself is the way back to Industries, so there is
 * no in-boundary recovery link anymore).
 */
import { describe, it, expect } from "vitest";
import { screen } from "@testing-library/react";

import { ApiError } from "@/lib/api";
import { SourceExplorerError } from "@/components/source-explorer/source-explorer-dialog";
import { renderWithRouter } from "./helpers/router-wrapper";

describe("SourceExplorerError", () => {
  it("renders the 404 'path not found' copy", async () => {
    const err = new ApiError(404, "Not Found", { detail: "gone" });
    renderWithRouter(<SourceExplorerError error={err} />);
    expect(
      await screen.findByRole("heading", { name: /Path not found in source/i }),
    ).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Retry/i })).toBeInTheDocument();
  });

  it("renders the 502 'source unavailable' copy", async () => {
    const err = new ApiError(502, "Bad Gateway", null);
    renderWithRouter(<SourceExplorerError error={err} />);
    expect(
      await screen.findByRole("heading", { name: /Source unavailable/i }),
    ).toBeInTheDocument();
  });

  it("renders the 403 'needs a GitHub App' copy (not per-user OAuth)", async () => {
    const err = new ApiError(403, "Forbidden", { detail: "denied" });
    renderWithRouter(<SourceExplorerError error={err} />);
    expect(
      await screen.findByRole("heading", { name: /needs a GitHub App/i }),
    ).toBeInTheDocument();
    // The copy points at the GitHub App / source config, never "authorize your
    // GitHub account".
    expect(
      screen.getByText(/GitHub App credentials|Settings -> Sources/i),
    ).toBeInTheDocument();
    expect(screen.queryByText(/authorize your GitHub account/i)).toBeNull();
    expect(screen.getByRole("button", { name: /Retry/i })).toBeInTheDocument();
  });

  it("falls back to a generic title for other errors and keeps a Retry", async () => {
    const err = new ApiError(500, "Internal Server Error", null);
    renderWithRouter(<SourceExplorerError error={err} />);
    expect(
      await screen.findByRole("heading", { name: /Couldn['’]t load the source/i }),
    ).toBeInTheDocument();
    expect(
      screen.queryByRole("heading", { name: /Source unavailable/i }),
    ).not.toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Retry/i })).toBeInTheDocument();
  });
});
