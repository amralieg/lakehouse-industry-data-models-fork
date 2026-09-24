/**
 * Lock the `--primary` token contract for "active / running / in-progress"
 * semantic sites that previously used raw `text-blue-500` / `bg-blue-500/X` /
 * `border-blue-500/X`.
 *
 * These sites render the same DuBois hue today only because the literal
 * tailwind `blue-500` palette entry sits near `--primary`. If `--primary`
 * ever moves, the raw classes would desync — that's why they must be
 * migrated to the token.
 *
 * The test does two things:
 *   1. Renders the migrated React components and asserts the running-status
 *      / info-banner markup uses `text-primary` / `bg-primary/X` /
 *      `border-primary/X`, NOT the raw `blue-500` classes.
 *   2. Grep-locks the source files: no raw `text-blue-500` / `bg-blue-500`
 *      / `border-blue-500` may sneak back into the in-scope files.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { render, waitFor } from "@testing-library/react";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

import { InstallBundledAgentButton } from "@/components/settings/install-bundled-agent-button";
import {
  AgentReleaseCard,
  type AgentCompatInfo,
} from "@/components/settings/agent-release-card";

const UI_SRC_ROOT = resolve(__dirname, "..");

function readSource(relPath: string): string {
  return readFileSync(resolve(UI_SRC_ROOT, relPath), "utf8");
}

function jsonResponse(body: unknown) {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}

describe("token-blue500 sweep — `--primary` for active/running semantic", () => {
  beforeEach(() => {
    (globalThis as unknown as { fetch: typeof fetch }).fetch = vi
      .fn()
      .mockImplementation(async (url: string) => {
        if (url === "/api/admin/bundled-agent") {
          return jsonResponse({
            available: true,
            pinned_tag: "v0.5.8",
            supported_tags: ["v0.5.8"],
            file_name: "vibe_modelling_agent_v0.5.8.ipynb",
          });
        }
        throw new Error(`unexpected url: ${url}`);
      }) as unknown as typeof fetch;
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("InstallBundledAgentButton info banner uses primary token, not blue-500", async () => {
    const { container } = render(<InstallBundledAgentButton />);
    // Component renders null until the async info fetch resolves; wait for
    // the banner to appear.
    let banner: HTMLElement | null = null;
    await waitFor(() => {
      banner = container.querySelector("div.rounded-md");
      expect(banner).not.toBeNull();
    });
    const klass = banner!.className;
    expect(klass).toContain("border-primary/30");
    expect(klass).toContain("bg-primary/5");
    expect(klass).not.toMatch(/\bborder-blue-500\b/);
    expect(klass).not.toMatch(/\bbg-blue-500\b/);
  });

  it("AgentReleaseCard non-breaking info banner uses primary token", async () => {
    const fetcher = vi.fn(
      async (): Promise<AgentCompatInfo> => ({
        pinned_version: "v0.5.8",
        latest_known_upstream: "v0.5.10",
        newer_available: true,
        has_breaking_change: false,
        known_breaking_changes: [],
      }),
    );

    const { container } = render(<AgentReleaseCard fetcher={fetcher} />);

    let card: HTMLElement | null = null;
    await waitFor(() => {
      card = container.querySelector(
        '[data-testid="agent-release-card"]',
      ) as HTMLElement | null;
      expect(card).not.toBeNull();
    });
    const klass = card!.className;
    expect(klass).toContain("border-primary/30");
    expect(klass).toContain("bg-primary/5");
    expect(klass).not.toMatch(/\bborder-blue-500\b/);
    expect(klass).not.toMatch(/\bbg-blue-500\b/);
  });

  // ---------------------------------------------------------------------
  // Grep-lock: no raw blue-500 may sneak back into the in-scope files.
  // The run-hierarchy-pipeline rendering tests against a full Op tree live
  // in run-hierarchy-pipeline.test.tsx; for the className contract here we
  // use a source grep — cheap, refactor-resistant, and catches stray
  // re-introductions anywhere in the file.
  // ---------------------------------------------------------------------
  const IN_SCOPE_FILES = [
    "components/runs/run-hierarchy-pipeline.tsx",
    "components/settings/install-bundled-agent-button.tsx",
    "components/settings/agent-release-card.tsx",
  ];

  it.each(IN_SCOPE_FILES)(
    "%s contains no raw text-blue-500 / bg-blue-500 / border-blue-500 classes",
    (relPath) => {
      const src = readSource(relPath);
      expect(src).not.toMatch(/\btext-blue-500\b/);
      expect(src).not.toMatch(/\bbg-blue-500\b/);
      expect(src).not.toMatch(/\bborder-blue-500\b/);
    },
  );

  it("run-hierarchy-pipeline running step + spinner sites use text-primary", () => {
    const src = readSource("components/runs/run-hierarchy-pipeline.tsx");
    // Sanity: the running-status colour must use the primary token at all
    // five migrated sites (StepStatusIcon, EventIcon, stepNameColor map,
    // and the two standalone Loader2 spinners).
    const primaryMatches = src.match(/text-primary\b/g)?.length ?? 0;
    expect(primaryMatches).toBeGreaterThanOrEqual(5);
    expect(src).toContain('running: "text-primary"');
  });
});
