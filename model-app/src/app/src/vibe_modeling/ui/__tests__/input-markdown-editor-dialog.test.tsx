/**
 * `<InputMarkdownEditorDialog/>` — full editor escalated from a card (commit h).
 * Reuses the real MarkdownEditor; controlled value (fill regression); ⌘↵ saves
 * via useUpdateVibeInput; Esc/Cancel discards.
 */
import { describe, expect, it, vi, beforeEach } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { VibeInputOut } from "@/lib/api";

const mutate = vi.fn();
vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useUpdateVibeInput: () => ({ mutate, isPending: false }),
  };
});

import { InputMarkdownEditorDialog } from "@/components/vibe-inputs/input-markdown-editor-dialog";

const input: VibeInputOut = {
  id: "vi-1",
  business_id: "biz-1",
  origin: "user",
  author: "a@b.c",
  text: "original text",
  priority: "medium",
  confidence_score: null,
  consumed: false,
  status: "active",
  selected_for_run: false,
  deprecated_by: null,
  created_at: "2026-01-01T00:00:00",
  updated_at: "2026-01-01T00:00:00",
  anchor: { level: "model_wide", path: [] },
};

function renderDialog(onOpenChange = vi.fn()) {
  const qc = new QueryClient();
  render(
    <QueryClientProvider client={qc}>
      <InputMarkdownEditorDialog
        businessId="biz-1"
        input={input}
        open
        onOpenChange={onOpenChange}
        anchorLabel="Model-wide"
      />
    </QueryClientProvider>,
  );
  return { onOpenChange };
}

describe("InputMarkdownEditorDialog", () => {
  beforeEach(() => mutate.mockClear());

  it("seeds the editor with the input text (controlled)", () => {
    renderDialog();
    const ta = screen.getByRole("textbox") as HTMLTextAreaElement;
    expect(ta.value).toBe("original text");
  });

  it("reflects every keystroke in the controlled value (fill regression)", () => {
    renderDialog();
    const ta = screen.getByRole("textbox") as HTMLTextAreaElement;
    fireEvent.change(ta, { target: { value: "edited body" } });
    expect((screen.getByRole("textbox") as HTMLTextAreaElement).value).toBe("edited body");
  });

  it("saves changed text via the mutation on ⌘↵", () => {
    renderDialog();
    const ta = screen.getByRole("textbox") as HTMLTextAreaElement;
    fireEvent.change(ta, { target: { value: "new content" } });
    fireEvent.keyDown(ta, { key: "Enter", metaKey: true });
    expect(mutate).toHaveBeenCalledTimes(1);
    expect(mutate.mock.calls[0][0]).toEqual({
      params: { business_id: "biz-1", input_id: "vi-1" },
      data: { text: "new content", priority: "medium" },
    });
  });

  it("does not mutate when text and priority are unchanged; just closes", () => {
    const { onOpenChange } = renderDialog();
    fireEvent.click(screen.getByRole("button", { name: "Save" }));
    expect(mutate).not.toHaveBeenCalled();
    expect(onOpenChange).toHaveBeenCalledWith(false);
  });

  it("seeds the priority select with the input's current priority", () => {
    renderDialog();
    expect(screen.getByLabelText("Priority")).toHaveTextContent("Medium");
  });

  it("saves a priority-only change even when text is unchanged", () => {
    renderDialog();
    fireEvent.click(screen.getByLabelText("Priority"));
    fireEvent.click(screen.getByRole("option", { name: "High" }));
    fireEvent.click(screen.getByRole("button", { name: "Save" }));
    expect(mutate).toHaveBeenCalledTimes(1);
    expect(mutate.mock.calls[0][0]).toEqual({
      params: { business_id: "biz-1", input_id: "vi-1" },
      data: { priority: "high" },
    });
  });

  it("Cancel discards without mutating", () => {
    const { onOpenChange } = renderDialog();
    const ta = screen.getByRole("textbox") as HTMLTextAreaElement;
    fireEvent.change(ta, { target: { value: "throwaway" } });
    fireEvent.click(screen.getByRole("button", { name: "Cancel" }));
    expect(mutate).not.toHaveBeenCalled();
    expect(onOpenChange).toHaveBeenCalledWith(false);
  });
});
