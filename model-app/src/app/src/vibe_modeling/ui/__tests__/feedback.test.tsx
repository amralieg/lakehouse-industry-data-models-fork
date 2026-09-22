import { describe, it, expect, vi, afterEach } from "vitest";
import { act, render, screen, fireEvent, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactNode } from "react";

// We're testing pure rendering + click handlers, not network calls.
// Mock the API layer so tests don't need a backend.
vi.mock("@/lib/api", async () => {
  return {
    createVibeInput: vi.fn().mockResolvedValue({ data: { id: "vi1", text: "mock" } }),
    listVibeInputsKey: (params: unknown) => ["/api/businesses/{business_id}/inputs", params],
    VibeInputOrigin: { user: "user", agent_next_vibe: "agent_next_vibe" },
    VibeInputPriority: { high: "high", medium: "medium", low: "low" },
  };
});

import { createVibeInput } from "@/lib/api";
import { FeedbackDialog } from "@/components/feedback/feedback-dialog";
import { AddFeedbackButton } from "@/components/feedback/add-feedback-button";

const mockedCreateVibeInput = vi.mocked(createVibeInput);

function withQuery(ui: ReactNode) {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return <QueryClientProvider client={qc}>{ui}</QueryClientProvider>;
}

describe("FeedbackDialog", () => {
  it("renders title and context badge when open", () => {
    render(
      withQuery(
        <FeedbackDialog
          open={true}
          onOpenChange={() => {}}
          businessId="b1"
          versionId="v1"
          context={{
            context_version: 1,
            view_mode: "er",
            domain_filter: "sales",
            selected_node_id: "sales.orders",
          }}
        />,
      ),
    );
    expect(screen.getByText("Add feedback")).toBeInTheDocument();
    // Context badges surface key:value pairs
    expect(screen.getByText(/view: er/i)).toBeInTheDocument();
    expect(screen.getByText(/domain: sales/i)).toBeInTheDocument();
    // Key renamed node → table (a node in the diagram *is* a table).
    expect(screen.getByText(/table: sales.orders/i)).toBeInTheDocument();
  });

  it("disables Save button when textarea is empty", () => {
    render(
      withQuery(
        <FeedbackDialog
          open={true}
          onOpenChange={() => {}}
          businessId="b1"
          versionId="v1"
          context={{ context_version: 1, view_mode: "" }}
        />,
      ),
    );
    const save = screen.getByRole("button", { name: /save feedback/i });
    expect(save).toBeDisabled();
  });

  it("enables Save button once text is entered", () => {
    render(
      withQuery(
        <FeedbackDialog
          open={true}
          onOpenChange={() => {}}
          businessId="b1"
          versionId="v1"
          context={{ context_version: 1, view_mode: "" }}
        />,
      ),
    );
    const textarea = screen.getByRole("textbox");
    fireEvent.change(textarea, { target: { value: "my feedback" } });
    const save = screen.getByRole("button", { name: /save feedback/i });
    expect(save).not.toBeDisabled();
  });

  it("disables Save when versionId is absent even with text", () => {
    render(
      withQuery(
        <FeedbackDialog
          open={true}
          onOpenChange={() => {}}
          businessId="b1"
          context={{ context_version: 1, view_mode: "" }}
        />,
      ),
    );
    fireEvent.change(screen.getByRole("textbox"), {
      target: { value: "feedback without a version" },
    });
    const save = screen.getByRole("button", { name: /save feedback/i });
    expect(save).toBeDisabled();
  });

  it("creates a VibeInput with text, version_id, origin, origin_context and default priority", async () => {
    const context = {
      context_version: 1,
      view_mode: "er",
      domain_filter: "sales",
      selected_node_id: "sales.orders",
    };
    render(
      withQuery(
        <FeedbackDialog
          open={true}
          onOpenChange={() => {}}
          businessId="b1"
          versionId="v1"
          context={context}
        />,
      ),
    );

    fireEvent.change(screen.getByRole("textbox"), {
      target: { value: "make orders richer" },
    });
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /save feedback/i }));
    });

    await waitFor(() => {
      expect(mockedCreateVibeInput).toHaveBeenCalledTimes(1);
    });
    const [params, body] = mockedCreateVibeInput.mock.calls[0];
    expect(params).toEqual({ business_id: "b1" });
    expect(body).toMatchObject({
      text: "make orders richer",
      version_id: "v1",
      origin: "user",
      priority: "medium",
      origin_context: context,
    });
  });

  it("passes the selected priority into the VibeInput body", async () => {
    render(
      withQuery(
        <FeedbackDialog
          open={true}
          onOpenChange={() => {}}
          businessId="b1"
          versionId="v1"
          context={{ context_version: 1, view_mode: "er" }}
        />,
      ),
    );

    fireEvent.change(screen.getByRole("textbox"), {
      target: { value: "high priority note" },
    });

    // The priority select exposes its options through a native-friendly trigger.
    fireEvent.click(screen.getByLabelText(/priority/i));
    fireEvent.click(await screen.findByRole("option", { name: /high/i }));

    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /save feedback/i }));
    });

    await waitFor(() => {
      expect(mockedCreateVibeInput).toHaveBeenCalled();
    });
    const lastCall = mockedCreateVibeInput.mock.calls.at(-1)!;
    expect(lastCall[1]).toMatchObject({ priority: "high" });
  });

  it("invalidates the vibe-inputs list on success", async () => {
    const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
    const invalidateSpy = vi.spyOn(qc, "invalidateQueries");
    render(
      <QueryClientProvider client={qc}>
        <FeedbackDialog
          open={true}
          onOpenChange={() => {}}
          businessId="b1"
          versionId="v1"
          context={{ context_version: 1, view_mode: "er" }}
        />
      </QueryClientProvider>,
    );

    fireEvent.change(screen.getByRole("textbox"), {
      target: { value: "shows up live" },
    });
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /save feedback/i }));
    });

    await waitFor(() => {
      expect(invalidateSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          queryKey: ["/api/businesses/{business_id}/inputs", { business_id: "b1" }],
        }),
      );
    });
  });

  it("surfaces the error and stays open when createVibeInput rejects with 500", async () => {
    mockedCreateVibeInput.mockRejectedValueOnce(
      new Error("HTTP 500: server exploded"),
    );
    const onOpenChange = vi.fn();
    render(
      withQuery(
        <FeedbackDialog
          open={true}
          onOpenChange={onOpenChange}
          businessId="b1"
          versionId="v1"
          context={{ context_version: 1, view_mode: "er" }}
        />,
      ),
    );

    fireEvent.change(screen.getByRole("textbox"), {
      target: { value: "this should fail" },
    });

    const save = screen.getByRole("button", { name: /save feedback/i });
    await act(async () => {
      fireEvent.click(save);
    });

    // Error message visible to the user.
    await waitFor(() => {
      expect(screen.getByText(/HTTP 500: server exploded/i)).toBeInTheDocument();
    });

    // Dialog must NOT close on error — onOpenChange(false) is only called
    // on success.
    expect(onOpenChange).not.toHaveBeenCalledWith(false);

    // Save button re-enabled (mutation no longer pending) so the user
    // can retry after fixing whatever was wrong.
    const saveAfter = screen.getByRole("button", { name: /save feedback/i });
    expect(saveAfter).not.toBeDisabled();
  });
});

describe("FeedbackDialog fullscreen portal (item 5A, 0.6.6)", () => {
  /** Stub document.fullscreenElement (read-only getter in real DOM) for a test. */
  function setFullscreenElement(el: Element | null) {
    Object.defineProperty(document, "fullscreenElement", {
      configurable: true,
      value: el,
    });
  }

  afterEach(() => {
    setFullscreenElement(null);
  });

  it("renders into document.body when nothing is fullscreen", () => {
    render(
      withQuery(
        <FeedbackDialog
          open={true}
          onOpenChange={() => {}}
          businessId="b1"
          versionId="v1"
          context={{ context_version: 1, view_mode: "" }}
        />,
      ),
    );
    const title = screen.getByText("Add feedback");
    expect(document.body.contains(title)).toBe(true);
  });

  it("renders into document.fullscreenElement when one is set", () => {
    const fsRoot = document.createElement("div");
    document.body.appendChild(fsRoot);
    setFullscreenElement(fsRoot);

    render(
      withQuery(
        <FeedbackDialog
          open={true}
          onOpenChange={() => {}}
          businessId="b1"
          versionId="v1"
          context={{ context_version: 1, view_mode: "" }}
        />,
      ),
    );
    const title = screen.getByText("Add feedback");
    expect(fsRoot.contains(title)).toBe(true);
  });

  it("re-portals to document.body on a fullscreenchange exit", () => {
    const fsRoot = document.createElement("div");
    document.body.appendChild(fsRoot);
    setFullscreenElement(fsRoot);

    render(
      withQuery(
        <FeedbackDialog
          open={true}
          onOpenChange={() => {}}
          businessId="b1"
          versionId="v1"
          context={{ context_version: 1, view_mode: "" }}
        />,
      ),
    );
    expect(fsRoot.contains(screen.getByText("Add feedback"))).toBe(true);

    // Toolbar-driven fullscreen exit: fullscreenElement clears, event fires.
    act(() => {
      setFullscreenElement(null);
      document.dispatchEvent(new Event("fullscreenchange"));
    });

    const title = screen.getByText("Add feedback");
    expect(fsRoot.contains(title)).toBe(false);
    expect(document.body.contains(title)).toBe(true);
  });

  it("threads the fullscreen container into the priority SelectContent", () => {
    const fsRoot = document.createElement("div");
    document.body.appendChild(fsRoot);
    setFullscreenElement(fsRoot);

    render(
      withQuery(
        <FeedbackDialog
          open={true}
          onOpenChange={() => {}}
          businessId="b1"
          versionId="v1"
          context={{ context_version: 1, view_mode: "" }}
        />,
      ),
    );
    fireEvent.click(screen.getByRole("combobox", { name: /priority/i }));
    const highOption = screen.getByText("High");
    // The priority dropdown must mount inside the fullscreen root too, or it
    // would be invisible under the same top-layer restriction as the dialog.
    expect(fsRoot.contains(highOption)).toBe(true);
  });
});

describe("AddFeedbackButton", () => {
  it("captures context lazily at click time", () => {
    const getContext = vi.fn().mockReturnValue({
      context_version: 1,
      view_mode: "overview",
    });
    render(
      withQuery(
        <AddFeedbackButton businessId="b1" versionId="v1" getContext={getContext} />,
      ),
    );

    // getContext not called yet (button just mounted)
    expect(getContext).not.toHaveBeenCalled();

    // Click opens the dialog AND calls getContext exactly once
    fireEvent.click(screen.getByRole("button", { name: /add feedback/i }));
    expect(getContext).toHaveBeenCalledTimes(1);

    // Dialog is now visible (look for the Save button that only exists in the open dialog)
    expect(screen.getByRole("button", { name: /save feedback/i })).toBeInTheDocument();
  });

});
