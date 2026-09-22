/**
 * `<ReviewQueueDialog/>` (commit g) — resumable, live-queue link review.
 * Opens at the persisted index (clamped); accept/re-anchor/dismiss call the
 * right hooks; relationship items render the two-entity anchor; re-anchor opens
 * the ModelElementPicker; done state when the live queue is empty.
 */
import { describe, expect, it, vi, beforeEach } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReviewQueueItemOut, VibeInputOut, VibeInputContextLinkOut } from "@/lib/api";

const acceptMutate = vi.fn();
const reanchorMutate = vi.fn();
const dismissMutate = vi.fn();
vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useAcceptReviewLink: () => ({ mutate: acceptMutate, isPending: false }),
    useReanchorReviewLink: () => ({ mutate: reanchorMutate, isPending: false }),
    useDismissReviewLink: () => ({ mutate: dismissMutate, isPending: false }),
  };
});

import { ReviewQueueDialog } from "@/components/vibe-inputs/review-queue-dialog";

// Node 25's experimental localStorage shadows jsdom's but exposes no methods;
// install a Map-backed shim (mirrors theme-provider.test.tsx).
function installLocalStorageShim() {
  const store = new Map<string, string>();
  vi.stubGlobal("localStorage", {
    get length() {
      return store.size;
    },
    clear: () => store.clear(),
    getItem: (k: string) => (store.has(k) ? store.get(k)! : null),
    setItem: (k: string, v: string) => {
      store.set(k, String(v));
    },
    removeItem: (k: string) => {
      store.delete(k);
    },
    key: (i: number) => Array.from(store.keys())[i] ?? null,
  } satisfies Storage);
}
installLocalStorageShim();

const link = (over: Partial<VibeInputContextLinkOut> = {}): VibeInputContextLinkOut => ({
  id: "lk-1",
  input_id: "vi-1",
  version_id: "ver-1",
  domain_id: null,
  subdomain_id: null,
  product_id: null,
  attribute_id: null,
  fk_link_id: null,
  is_origin: false,
  needs_link_review: true,
  reviewed_by: null,
  reviewed_at: null,
  created_at: "2026-01-01T00:00:00",
  ...over,
});

const input = (over: Partial<VibeInputOut> = {}): VibeInputOut => ({
  id: "vi-1",
  business_id: "biz-1",
  origin: "user",
  author: "",
  text: "keep order ids stable",
  priority: "medium",
  confidence_score: null,
  consumed: false,
  status: "active",
  selected_for_run: false,
  deprecated_by: null,
  created_at: "2026-01-01T00:00:00",
  updated_at: "2026-01-01T00:00:00",
  anchor: { level: "element", domain_name: "Sales", path: ["Domain: Sales"] },
  ...over,
});

const item = (over: Partial<ReviewQueueItemOut> = {}): ReviewQueueItemOut => ({
  link: link(),
  input: input(),
  proposed_anchor_label: "Domain Sales › Product Orders",
  tier: "merge_survivor",
  ...over,
});

function renderDialog(items: ReviewQueueItemOut[], reanchorOptions: any[] = []) {
  const qc = new QueryClient();
  const onOpenChange = vi.fn();
  render(
    <QueryClientProvider client={qc}>
      <ReviewQueueDialog
        businessId="biz-1"
        open
        onOpenChange={onOpenChange}
        items={items}
        reanchorOptions={reanchorOptions}
      />
    </QueryClientProvider>,
  );
  return { onOpenChange };
}

describe("ReviewQueueDialog", () => {
  beforeEach(() => {
    acceptMutate.mockClear();
    reanchorMutate.mockClear();
    dismissMutate.mockClear();
    localStorage.clear();
  });

  it("accept calls the accept hook with the link id", () => {
    renderDialog([item()]);
    fireEvent.click(screen.getByRole("button", { name: /Accept link/ }));
    expect(acceptMutate).toHaveBeenCalledTimes(1);
    expect(acceptMutate.mock.calls[0][0].params).toEqual({
      business_id: "biz-1",
      link_id: "lk-1",
    });
  });

  it("dismiss calls the dismiss hook", () => {
    renderDialog([item()]);
    fireEvent.click(screen.getByRole("button", { name: /Dismiss/ }));
    expect(dismissMutate).toHaveBeenCalledTimes(1);
  });

  it("re-anchor opens the element picker and picks an element", () => {
    renderDialog(
      [item()],
      [{ label: "main.crm.customers", kind: "Product", ids: { product_id: "p-1" } }],
    );
    fireEvent.click(screen.getByRole("button", { name: /Re-anchor/ }));
    fireEvent.click(screen.getByText("main.crm.customers"));
    expect(reanchorMutate).toHaveBeenCalledTimes(1);
    expect(reanchorMutate.mock.calls[0][0].data).toEqual({ product_id: "p-1" });
  });

  it("renders the two-entity relationship anchor for fk-linked items", () => {
    renderDialog([
      item({
        link: link({ fk_link_id: "fk-1" }),
        proposed_anchor_label: "Relationship Order→Customer",
      }),
    ]);
    expect(screen.getByText("Relationship link")).toBeInTheDocument();
    expect(screen.getByText("Order")).toBeInTheDocument();
    expect(screen.getByText("Customer")).toBeInTheDocument();
  });

  it("shows the done state when the live queue is empty", () => {
    renderDialog([]);
    expect(screen.getByText("All links reviewed")).toBeInTheDocument();
  });

  it("clamps a stale persisted index into the current queue", () => {
    localStorage.setItem("vi_review_idx", "9");
    renderDialog([item(), item({ link: link({ id: "lk-2" }) })]);
    // Only 2 items; index clamps to 1 → header shows "2 of 2".
    expect(screen.getByText("2 of 2")).toBeInTheDocument();
  });
});
