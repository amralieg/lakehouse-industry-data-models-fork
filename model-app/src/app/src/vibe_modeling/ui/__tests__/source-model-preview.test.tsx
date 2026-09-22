/**
 * `SourceModelPreview` tests - Task 2 (README preview) + Task 2 addenda.
 *
 * Mocks `useGetSourceModelPreviewSuspense` so the component renders
 * synchronously. Asserts:
 *   1. The version badge renders the folder version VERBATIM ("v1"), never
 *      re-prefixed to "vv1" - mirrors `source-tree.test.tsx`'s version
 *      assertion for the same folder-path contract.
 *   2. The README renders as formatted markdown via `MarkdownView`.
 *   3. A null README renders the empty-state note, not an error or blank.
 *   4. The stats row renders only the non-null fields.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import type { ModelPreviewOut } from "@/lib/api";

let previewHook: () => unknown = () => ({ data: basePreview() });

function basePreview(overrides: Partial<ModelPreviewOut> = {}): ModelPreviewOut {
  return {
    industry_id: "banking",
    model_id: "v1_ecm",
    model_name: "Banking",
    scope: "ecm",
    version: "v1",
    readme: null,
    domains: null,
    subdomains: null,
    products: null,
    attributes: null,
    primary_keys: null,
    foreign_keys: null,
    avg_attrs_per_product: null,
    metric_views: null,
    artifacts: [],
    ...overrides,
  };
}

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetSourceModelPreviewSuspense: () => previewHook(),
  };
});

import { SourceModelPreview } from "@/components/source-explorer/source-model-preview";

afterEach(() => {
  vi.restoreAllMocks();
  previewHook = () => ({ data: basePreview() });
});

describe("SourceModelPreview", () => {
  it("renders the folder version verbatim, never re-prefixed", () => {
    previewHook = () => ({ data: basePreview({ version: "v1" }) });
    render(
      <SourceModelPreview industryId="banking" modelId="v1_ecm" onDownload={vi.fn()} />,
    );
    expect(screen.getByText("v1")).toBeInTheDocument();
    expect(screen.queryByText("vv1")).not.toBeInTheDocument();
  });

  it("renders the README as formatted markdown", () => {
    previewHook = () => ({
      data: basePreview({ readme: "# Banking ECM\n\nA short summary." }),
    });
    render(
      <SourceModelPreview industryId="banking" modelId="v1_ecm" onDownload={vi.fn()} />,
    );
    expect(
      screen.getByRole("heading", { name: "Banking ECM" }),
    ).toBeInTheDocument();
    expect(screen.getByText("A short summary.")).toBeInTheDocument();
  });

  it("renders the empty-state note when the README is null", () => {
    previewHook = () => ({ data: basePreview({ readme: null }) });
    render(
      <SourceModelPreview industryId="banking" modelId="v1_ecm" onDownload={vi.fn()} />,
    );
    expect(
      screen.getByText("No README published for this model."),
    ).toBeInTheDocument();
  });

  it("renders only the non-null stats fields", () => {
    previewHook = () => ({
      data: basePreview({ domains: 12, products: 100, attributes: null }),
    });
    render(
      <SourceModelPreview industryId="banking" modelId="v1_ecm" onDownload={vi.fn()} />,
    );
    expect(screen.getByText("12 domains")).toBeInTheDocument();
    expect(screen.getByText("100 products")).toBeInTheDocument();
    expect(screen.queryByText(/attributes/)).not.toBeInTheDocument();
  });

  it("hides the stats row entirely when every stat is null", () => {
    previewHook = () => ({ data: basePreview() });
    render(
      <SourceModelPreview industryId="banking" modelId="v1_ecm" onDownload={vi.fn()} />,
    );
    expect(screen.queryByText(/domains|products|attributes|PKs|FKs/)).not.toBeInTheDocument();
  });
});
