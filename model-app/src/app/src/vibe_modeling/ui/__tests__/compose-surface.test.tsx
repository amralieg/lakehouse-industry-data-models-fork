/**
 * `<ComposeSurface/>` integration. Review banner shows iff the live queue has
 * items; segmented switch toggles preview/subgraph; deprecated section appears
 * only when non-empty; server-backed selection (default deselected) drives the
 * compiled preview count, the Start-run CTA, and the Selected filter; toggling a
 * card persists via the selection mutation.
 */
import { describe, expect, it, vi, beforeEach } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { VibeInputOut, ReviewQueueOut } from "@/lib/api";

// localStorage shim for the review dialog (Node 25).
function installLocalStorageShim() {
  const store = new Map<string, string>();
  vi.stubGlobal("localStorage", {
    get length() {
      return store.size;
    },
    clear: () => store.clear(),
    getItem: (k: string) => (store.has(k) ? store.get(k)! : null),
    setItem: (k: string, v: string) => store.set(k, String(v)),
    removeItem: (k: string) => store.delete(k),
    key: (i: number) => Array.from(store.keys())[i] ?? null,
  } satisfies Storage);
}
installLocalStorageShim();

let inputsData: VibeInputOut[] = [];
let queueData: ReviewQueueOut = { total: 0, items: [] };
const selectionMutate = vi.fn();
const createMutate = vi.fn();

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListVibeInputsSuspense: () => ({ data: inputsData }),
    useGetModelSummarySuspense: () => ({ data: { domains: [{ name: "Sales", division: "GTM" }] } }),
    useGetReviewQueueSuspense: () => ({ data: queueData }),
    useCreateVibeInput: () => ({ mutate: createMutate, isPending: false }),
    useUpdateVibeInput: () => ({ mutate: vi.fn(), isPending: false }),
    useSetVibeInputSelection: () => ({ mutate: selectionMutate, isPending: false }),
    useAcceptReviewLink: () => ({ mutate: vi.fn(), isPending: false }),
    useReanchorReviewLink: () => ({ mutate: vi.fn(), isPending: false }),
    useDismissReviewLink: () => ({ mutate: vi.fn(), isPending: false }),
  };
});

const navigateMock = vi.fn();
vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return { ...actual, useNavigate: () => navigateMock };
});

vi.mock("@/components/diagram/diagram-viewer", () => ({
  DiagramViewer: () => <div data-testid="diagram-viewer-stub" />,
}));

import { ComposeSurface } from "@/components/vibe-inputs/compose-surface";

const mk = (over: Partial<VibeInputOut> & { id: string }): VibeInputOut => ({
  business_id: "biz-1",
  origin: "user",
  author: "",
  text: "a rule",
  priority: "medium",
  confidence_score: null,
  consumed: false,
  status: "active",
  selected_for_run: false,
  deprecated_by: null,
  created_at: "2026-01-01T00:00:00",
  updated_at: "2026-01-01T00:00:00",
  anchor: { level: "model_wide", path: [] },
  ...over,
});

function renderSurface() {
  const qc = new QueryClient();
  render(
    <QueryClientProvider client={qc}>
      <ComposeSurface businessId="biz-1" version="2" scope="ecm" versionId="ver-1" />
    </QueryClientProvider>,
  );
}

describe("ComposeSurface", () => {
  beforeEach(() => {
    inputsData = [mk({ id: "a", text: "first rule" })];
    queueData = { total: 0, items: [] };
    selectionMutate.mockClear();
    createMutate.mockClear();
    navigateMock.mockClear();
  });

  it("Add Instruction with a non-default priority creates with that priority", () => {
    renderSurface();
    fireEvent.click(screen.getByText("Add instruction"));
    fireEvent.click(screen.getByLabelText("Priority"));
    fireEvent.click(screen.getByRole("option", { name: "High" }));
    const ta = screen.getByPlaceholderText(/New model-wide instruction/) as HTMLTextAreaElement;
    fireEvent.change(ta, { target: { value: "urgent instruction" } });
    fireEvent.click(screen.getByRole("button", { name: "Add" }));
    expect(createMutate).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ text: "urgent instruction", priority: "high" }),
      }),
      expect.anything(),
    );
  });

  it("hides the review banner when the queue is empty", () => {
    renderSurface();
    expect(screen.queryByText(/need link review/)).not.toBeInTheDocument();
  });

  it("shows the review banner when the live queue has items", () => {
    queueData = { total: 2, items: [] };
    renderSurface();
    expect(screen.getByText(/2 inputs need link review/)).toBeInTheDocument();
  });

  it("segmented switch toggles preview ↔ subgraph", () => {
    renderSurface();
    expect(screen.getByTestId("compiled-preview-count")).toBeInTheDocument();
    fireEvent.click(screen.getByRole("button", { name: "Model subgraph" }));
    expect(screen.queryByTestId("compiled-preview-count")).not.toBeInTheDocument();
    expect(screen.getByText(/Focus a domain or product card/)).toBeInTheDocument();
  });

  it("starts deselected: compiled preview counts only selected inputs", () => {
    inputsData = [
      mk({ id: "a" }),
      mk({ id: "b", selected_for_run: true }),
      mk({ id: "c", status: "deprecated" }),
    ];
    renderSurface();
    // Only b is selected_for_run; a is default-deselected, c deprecated.
    expect(screen.getByTestId("compiled-preview-count")).toHaveTextContent("1 selected");
  });

  it("toggling a card persists the selection via the mutation", () => {
    inputsData = [mk({ id: "a", text: "first rule" })];
    renderSurface();
    fireEvent.click(screen.getByLabelText("Include in next run"));
    expect(selectionMutate).toHaveBeenCalledWith({
      params: { business_id: "biz-1" },
      data: { input_ids: ["a"], selected: true },
    });
  });

  it("Start-run CTA is disabled at zero selected and enabled with a selection", () => {
    inputsData = [mk({ id: "a" })];
    renderSurface();
    const cta = screen.getByTestId("start-run-cta");
    expect(cta).toBeDisabled();
    expect(cta).toHaveTextContent("0 selected");

    inputsData = [mk({ id: "a", selected_for_run: true })];
    renderSurface();
    const enabled = screen.getAllByTestId("start-run-cta").at(-1)!;
    expect(enabled).not.toBeDisabled();
    expect(enabled).toHaveTextContent("1 selected");
    fireEvent.click(enabled);
    expect(navigateMock).toHaveBeenCalledWith(
      expect.objectContaining({
        to: "/businesses/$businessId/runs/new",
        params: { businessId: "biz-1" },
        search: expect.objectContaining({ sourceVersion: 2, sourceScope: "ecm" }),
      }),
    );
  });

  it("Selected filter narrows the tree to selected inputs", () => {
    inputsData = [
      mk({
        id: "a",
        text: "selected rule",
        selected_for_run: true,
        anchor: { level: "element", domain_name: "Sales", path: ["Domain: Sales"] },
      }),
      mk({
        id: "b",
        text: "unselected rule",
        anchor: { level: "element", domain_name: "Sales", path: ["Domain: Sales"] },
      }),
    ];
    renderSurface();
    expect(screen.getByText("unselected rule")).toBeInTheDocument();
    fireEvent.click(screen.getByLabelText("Filter by selection"));
    fireEvent.click(screen.getByRole("option", { name: "Selected" }));
    expect(screen.getByText("selected rule")).toBeInTheDocument();
    expect(screen.queryByText("unselected rule")).not.toBeInTheDocument();
  });

  it("deprecated section appears only when non-empty", () => {
    renderSurface();
    expect(screen.queryByText(/^Deprecated/)).not.toBeInTheDocument();
    inputsData = [mk({ id: "a" }), mk({ id: "d", status: "deprecated", text: "old rule" })];
    renderSurface();
    expect(screen.getByText(/Deprecated \(1\)/)).toBeInTheDocument();
  });
});
