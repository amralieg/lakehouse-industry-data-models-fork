import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import {
  AgentReleaseCard,
  type AgentCompatInfo,
} from "@/components/settings/agent-release-card";

function fetcherReturning(info: AgentCompatInfo) {
  return vi.fn(async () => info);
}

// A fully-populated up_to_date baseline; individual tests override fields.
function baseInfo(overrides: Partial<AgentCompatInfo> = {}): AgentCompatInfo {
  return {
    pinned_version: "v0.8.0",
    latest_known_upstream: "v0.8.0",
    newer_available: false,
    has_breaking_change: false,
    known_breaking_changes: [],
    pinned_release: "v0.8.0",
    pinned_agent_marker: "4.9.9",
    latest_upstream_release: "v0.8.0",
    latest_upstream_marker: "4.9.9",
    verdict: "up_to_date",
    update_app_required: false,
    install_offered: false,
    checked_at: null,
    check_error: null,
    ...overrides,
  } as AgentCompatInfo;
}

describe("AgentReleaseCard", () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("renders the 'up to date' variant", async () => {
    render(<AgentReleaseCard fetcher={fetcherReturning(baseInfo())} />);

    const card = await screen.findByTestId("agent-release-card");
    expect(card).toHaveTextContent(/up to date/i);
    expect(card).toHaveTextContent("v0.8.0");
    expect(card).not.toHaveTextContent(/Update required/i);
    expect(card).not.toHaveTextContent(/newer agent build/i);
  });

  it("renders 'release_incompatible' prompting an APP update", async () => {
    const fetcher = fetcherReturning(
      baseInfo({
        latest_known_upstream: "v0.9.0",
        newer_available: true,
        verdict: "release_incompatible",
        update_app_required: true,
        latest_upstream_release: "v0.9.0",
        latest_upstream_marker: "5.0.0",
      }),
    );

    render(<AgentReleaseCard fetcher={fetcher} />);

    const card = await screen.findByTestId("agent-release-card");
    // Warning styling.
    expect(card.className).toContain("border-warning/40");
    expect(card.className).toContain("bg-warning/5");
    expect(card).toHaveAttribute("role", "alert");
    expect(card).toHaveTextContent(/Update required/i);
    // Tells the user to update the APP, and names both releases.
    expect(card).toHaveTextContent(/update the app/i);
    expect(card).toHaveTextContent("v0.9.0");
    expect(card).toHaveTextContent("v0.8.0");
  });

  it("surfaces known breaking changes under release_incompatible", async () => {
    const fetcher = fetcherReturning(
      baseInfo({
        latest_known_upstream: "v0.9.0",
        newer_available: true,
        has_breaking_change: true,
        verdict: "release_incompatible",
        update_app_required: true,
        latest_upstream_release: "v0.9.0",
        known_breaking_changes: [
          {
            tag: "v0.9.0",
            severity: "breaking",
            area: "volume-layout",
            summary: "Volume folder naming flipped.",
          },
        ],
      }),
    );

    render(<AgentReleaseCard fetcher={fetcher} />);

    const card = await screen.findByTestId("agent-release-card");
    expect(card).toHaveTextContent(/Known breaking changes/i);
    expect(card).toHaveTextContent(/v0\.9\.0/);
    expect(card).toHaveTextContent(/volume-layout/);
  });

  it("renders 'build_update_available' as informational (no button)", async () => {
    const fetcher = fetcherReturning(
      baseInfo({
        newer_available: true,
        verdict: "build_update_available",
        latest_upstream_release: "v0.8.0",
        latest_upstream_marker: "4.9.10",
      }),
    );

    render(<AgentReleaseCard fetcher={fetcher} />);

    const card = await screen.findByTestId("agent-release-card");
    expect(card.className).toContain("border-primary/30");
    expect(card).toHaveTextContent(/newer agent build/i);
    expect(card).toHaveTextContent("4.9.10");
    expect(card).toHaveTextContent(/no action needed/i);
    // No install button in this phase.
    expect(screen.queryByRole("button")).toBeNull();
    expect(card).not.toHaveTextContent(/Update required/i);
  });

  it("falls back to the verdict from legacy fields when `verdict` is absent", async () => {
    // Legacy (pre-Surface-2) shape: only newer_available + has_breaking_change.
    const fetcher = vi.fn(
      async (): Promise<AgentCompatInfo> =>
        ({
          pinned_version: "v0.5.8",
          latest_known_upstream: "v0.5.10",
          newer_available: true,
          has_breaking_change: false,
          known_breaking_changes: [],
        }) as AgentCompatInfo,
    );

    render(<AgentReleaseCard fetcher={fetcher} />);

    const card = await screen.findByTestId("agent-release-card");
    // No verdict + newer + non-breaking → build_update_available (primary tone).
    expect(card.className).toContain("border-primary/30");
  });

  it("renders nothing when the fetcher fails (passive surface)", async () => {
    const fetcher = vi.fn(async (): Promise<AgentCompatInfo> => {
      throw new Error("boom");
    });

    const { container } = render(<AgentReleaseCard fetcher={fetcher} />);
    await waitFor(() => {
      expect(fetcher).toHaveBeenCalled();
    });
    await waitFor(() => {
      expect(container.textContent ?? "").toBe("");
    });
  });
});
