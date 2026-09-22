import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactNode, useState } from "react";

vi.mock("@/lib/api", async () => {
  return {
    createVibeInput: vi.fn().mockResolvedValue({ data: { id: "vi1", text: "mock" } }),
    listVibeInputsKey: (params: unknown) => ["/api/businesses/{business_id}/inputs", params],
    VibeInputOrigin: { user: "user", agent_next_vibe: "agent_next_vibe" },
    VibeInputPriority: { high: "high", medium: "medium", low: "low" },
  };
});

import { AddFeedbackButton } from "@/components/feedback/add-feedback-button";
import type { FeedbackContext } from "@/lib/api";

function withQuery(ui: ReactNode) {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return <QueryClientProvider client={qc}>{ui}</QueryClientProvider>;
}

describe("AddFeedbackButton — F underline + controllable open", () => {
  it("underlines the F in the default label", () => {
    const { container } = render(
      withQuery(
        <AddFeedbackButton businessId="b1" getContext={() => ({ context_version: 1, view_mode: "" })} />,
      ),
    );
    // Visible underline. The `<u>` element is rendered inside the trigger
    // button so the F shortcut is discoverable.
    const u = container.querySelector("button u");
    expect(u).not.toBeNull();
    expect(u?.textContent).toBe("F");
  });

  it("opens the dialog on click when uncontrolled", () => {
    render(
      withQuery(
        <AddFeedbackButton
          businessId="b1"
          getContext={() => ({ context_version: 1, view_mode: "overview" })}
        />,
      ),
    );
    fireEvent.click(screen.getByRole("button", { name: /add feedback/i }));
    expect(screen.getByRole("button", { name: /save feedback/i })).toBeInTheDocument();
  });

  it("delegates open/close to the parent when controlled", () => {
    function Parent() {
      const [open, setOpen] = useState(false);
      const [ctx] = useState<FeedbackContext>({ context_version: 1, view_mode: "overview" });
      return (
        <>
          <button data-testid="parent-open" onClick={() => setOpen(true)}>
            open
          </button>
          <AddFeedbackButton
            businessId="b1"
            getContext={() => ctx}
            open={open}
            onOpenChange={setOpen}
            context={ctx}
          />
        </>
      );
    }
    render(withQuery(<Parent />));

    // Dialog is closed initially — Save button is not in the DOM.
    expect(screen.queryByRole("button", { name: /save feedback/i })).toBeNull();

    // Parent calls setOpen(true) — dialog appears.
    fireEvent.click(screen.getByTestId("parent-open"));
    expect(screen.getByRole("button", { name: /save feedback/i })).toBeInTheDocument();
  });

  it("clicking the trigger in controlled mode notifies the parent", () => {
    const onOpenChange = vi.fn();
    render(
      withQuery(
        <AddFeedbackButton
          businessId="b1"
          getContext={() => ({ context_version: 1, view_mode: "" })}
          open={false}
          onOpenChange={onOpenChange}
          context={{ context_version: 1, view_mode: "" }}
        />,
      ),
    );
    fireEvent.click(screen.getByRole("button", { name: /add feedback/i }));
    expect(onOpenChange).toHaveBeenCalledWith(true);
  });

  describe("F-key shortcut", () => {
    it("opens the dialog when 'f' is pressed", () => {
      render(
        withQuery(
          <AddFeedbackButton
            businessId="b1"
            getContext={() => ({ context_version: 1, view_mode: "diagram" })}
          />,
        ),
      );
      fireEvent.keyDown(window, { key: "f" });
      expect(screen.getByRole("button", { name: /save feedback/i })).toBeInTheDocument();
    });

    it("notifies the controlled parent on 'F' key", () => {
      const onOpenChange = vi.fn();
      render(
        withQuery(
          <AddFeedbackButton
            businessId="b1"
            getContext={() => ({ context_version: 1, view_mode: "" })}
            open={false}
            onOpenChange={onOpenChange}
            context={{ context_version: 1, view_mode: "" }}
          />,
        ),
      );
      fireEvent.keyDown(window, { key: "F" });
      expect(onOpenChange).toHaveBeenCalledWith(true);
    });

    it("ignores 'f' when modifier keys are held", () => {
      const onOpenChange = vi.fn();
      render(
        withQuery(
          <AddFeedbackButton
            businessId="b1"
            getContext={() => ({ context_version: 1, view_mode: "" })}
            open={false}
            onOpenChange={onOpenChange}
            context={{ context_version: 1, view_mode: "" }}
          />,
        ),
      );
      fireEvent.keyDown(window, { key: "f", metaKey: true });
      fireEvent.keyDown(window, { key: "f", ctrlKey: true });
      fireEvent.keyDown(window, { key: "F", shiftKey: true });
      expect(onOpenChange).not.toHaveBeenCalled();
    });

    it("ignores 'f' when an INPUT or TEXTAREA is focused", () => {
      const onOpenChange = vi.fn();
      render(
        withQuery(
          <>
            <textarea data-testid="ta" defaultValue="" />
            <input data-testid="inp" />
            <AddFeedbackButton
              businessId="b1"
              getContext={() => ({ context_version: 1, view_mode: "" })}
              open={false}
              onOpenChange={onOpenChange}
              context={{ context_version: 1, view_mode: "" }}
            />
          </>,
        ),
      );
      (screen.getByTestId("ta") as HTMLTextAreaElement).focus();
      fireEvent.keyDown(window, { key: "f" });
      (screen.getByTestId("inp") as HTMLInputElement).focus();
      fireEvent.keyDown(window, { key: "f" });
      expect(onOpenChange).not.toHaveBeenCalled();
    });

    it("ignores 'f' when focus is inside a [role=dialog]", () => {
      const onOpenChange = vi.fn();
      render(
        withQuery(
          <>
            <div role="dialog">
              <button data-testid="dialog-btn">inside</button>
            </div>
            <AddFeedbackButton
              businessId="b1"
              getContext={() => ({ context_version: 1, view_mode: "" })}
              open={false}
              onOpenChange={onOpenChange}
              context={{ context_version: 1, view_mode: "" }}
            />
          </>,
        ),
      );
      (screen.getByTestId("dialog-btn") as HTMLButtonElement).focus();
      fireEvent.keyDown(window, { key: "f" });
      expect(onOpenChange).not.toHaveBeenCalled();
    });
  });
});
