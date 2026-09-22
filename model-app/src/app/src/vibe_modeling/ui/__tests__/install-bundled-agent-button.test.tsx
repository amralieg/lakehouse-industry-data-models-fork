import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { InstallBundledAgentButton } from "@/components/settings/install-bundled-agent-button";

type FetchCall = {
  url: string;
  init?: RequestInit;
};

const calls: FetchCall[] = [];
let resolveInstall: ((value: Response) => void) | null = null;

function installFetchStub(
  handler: (url: string, init?: RequestInit) => Promise<Response> | Response,
) {
  (globalThis as unknown as { fetch: typeof fetch }).fetch = vi
    .fn()
    .mockImplementation(async (url: string, init?: RequestInit) => {
      calls.push({ url, init });
      return handler(url, init);
    }) as unknown as typeof fetch;
}

function jsonResponse(body: unknown, init: Partial<ResponseInit> = {}) {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { "Content-Type": "application/json" },
    ...init,
  });
}

describe("InstallBundledAgentButton", () => {
  beforeEach(() => {
    calls.length = 0;
    resolveInstall = null;
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("renders install button for available bundled agent and calls onInstalled on success", async () => {
    installFetchStub(async (url) => {
      if (url === "/api/admin/bundled-agent") {
        return jsonResponse({
          available: true,
          pinned_tag: "v0.5.8",
          supported_tags: ["v0.5.8"],
          file_name: "vibe_modelling_agent_v0.5.8.ipynb",
        });
      }
      if (url === "/api/admin/install-bundled-agent") {
        return jsonResponse({
          path: "/Users/sp@example.com/vibe-modelling-agent/vibe_modelling_agent_v0.5.8.ipynb",
          version: "v0.5.8",
          overwritten: false,
        });
      }
      throw new Error(`unexpected url: ${url}`);
    });

    const onInstalled = vi.fn();
    render(<InstallBundledAgentButton onInstalled={onInstalled} />);

    const btn = await screen.findByRole("button", {
      name: /Install bundled agent notebook \(v0\.5\.8\)/,
    });
    expect(btn).not.toBeDisabled();

    await act(async () => {
      fireEvent.click(btn);
    });

    await waitFor(() => {
      expect(onInstalled).toHaveBeenCalledWith(
        "/Users/sp@example.com/vibe-modelling-agent/vibe_modelling_agent_v0.5.8.ipynb",
      );
    });
    expect(
      calls.some(
        (c) =>
          c.url === "/api/admin/install-bundled-agent" &&
          (c.init?.method ?? "").toUpperCase() === "POST",
      ),
    ).toBe(true);
  });

  it("disables the button while uploading", async () => {
    installFetchStub(async (url) => {
      if (url === "/api/admin/bundled-agent") {
        return jsonResponse({
          available: true,
          pinned_tag: "v0.5.8",
          supported_tags: ["v0.5.8"],
          file_name: "vibe_modelling_agent_v0.5.8.ipynb",
        });
      }
      if (url === "/api/admin/install-bundled-agent") {
        return new Promise<Response>((resolve) => {
          resolveInstall = resolve;
        });
      }
      throw new Error(`unexpected url: ${url}`);
    });

    render(<InstallBundledAgentButton />);

    const btn = await screen.findByRole("button", {
      name: /Install bundled agent notebook \(v0\.5\.8\)/,
    });
    await act(async () => {
      fireEvent.click(btn);
    });

    const disabled = await screen.findByRole("button", {
      name: /Install bundled agent notebook \(v0\.5\.8\)/,
    });
    expect(disabled).toBeDisabled();
    expect(disabled).toHaveTextContent(/Installing/);

    await act(async () => {
      resolveInstall?.(
        jsonResponse({
          path: "/Users/sp@example.com/vibe-modelling-agent/vibe_modelling_agent_v0.5.8.ipynb",
          version: "v0.5.8",
          overwritten: false,
        }),
      );
    });

    await waitFor(() => {
      expect(
        screen.getByRole("button", {
          name: /Install bundled agent notebook \(v0\.5\.8\)/,
        }),
      ).not.toBeDisabled();
    });
  });

  it("renders nothing when no bundled agent is available", async () => {
    installFetchStub(async (url) => {
      if (url === "/api/admin/bundled-agent") {
        return jsonResponse({ available: false });
      }
      throw new Error(`unexpected url: ${url}`);
    });

    const { container } = render(<InstallBundledAgentButton />);
    await waitFor(() => {
      expect(container.textContent ?? "").toBe("");
    });
  });

  it("displays the error message and re-enables the button when install returns 500", async () => {
    installFetchStub(async (url) => {
      if (url === "/api/admin/bundled-agent") {
        return jsonResponse({
          available: true,
          pinned_tag: "v0.5.8",
          supported_tags: ["v0.5.8"],
          file_name: "vibe_modelling_agent_v0.5.8.ipynb",
        });
      }
      if (url === "/api/admin/install-bundled-agent") {
        return new Response(
          JSON.stringify({ detail: "Workspace upload failed" }),
          {
            status: 500,
            headers: { "Content-Type": "application/json" },
          },
        );
      }
      throw new Error(`unexpected url: ${url}`);
    });

    const onInstalled = vi.fn();
    render(<InstallBundledAgentButton onInstalled={onInstalled} />);

    const btn = await screen.findByRole("button", {
      name: /Install bundled agent notebook \(v0\.5\.8\)/,
    });
    await act(async () => {
      fireEvent.click(btn);
    });

    // Error message visible (component reads `body.detail` for 500s).
    await waitFor(() => {
      expect(screen.getByText(/Workspace upload failed/i)).toBeInTheDocument();
    });

    // Button must be back to its enabled state so the user can retry.
    const btnAfter = await screen.findByRole("button", {
      name: /Install bundled agent notebook \(v0\.5\.8\)/,
    });
    expect(btnAfter).not.toBeDisabled();
    expect(btnAfter).not.toHaveTextContent(/Installing/);

    // Success callback must NOT have fired.
    expect(onInstalled).not.toHaveBeenCalled();
  });
});
