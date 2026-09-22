/**
 * The ONE shared `config_missing` renderer (Track 4 finding #2).
 *
 * Covers the two halves every config-gated surface converges on:
 *   1. `parseConfigMissing` (lib/api-error) - unwraps the 422 envelope.
 *   2. `ConfigMissingNotice` (components/config-missing-notice) - renders the
 *      backend sentence + one working Settings deep-link per missing item.
 *   3. `notifyConfigMissing` (lib/notify) - raises the shared toast and reports
 *      whether it handled the error, so callers can fall back cleanly.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";
import type { ReactNode } from "react";

vi.mock("sonner", () => ({
  toast: { error: vi.fn(), success: vi.fn(), warning: vi.fn(), info: vi.fn() },
}));

import { toast } from "sonner";
import { ApiError } from "@/lib/api";
import { parseConfigMissing } from "@/lib/api-error";
import { ConfigMissingNotice } from "@/components/config-missing-notice";
import { notifyConfigMissing } from "@/lib/notify";

const MISSING = [
  { key: "metamodel_catalog", label: "Metamodel catalog", settings_url: "/settings?tab=platform" },
  { key: "warehouse", label: "SQL warehouse", settings_url: "/settings?tab=platform" },
];

function configMissingError() {
  return new ApiError(422, "Unprocessable Entity", {
    detail: {
      error: "config_missing",
      missing: MISSING,
      message: "Finish setup before running: 2 settings are missing.",
    },
  });
}

/** Router with a real `/settings` route so `<Link>` builds a resolvable href. */
function wrap(ui: ReactNode) {
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const indexRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/",
    component: () => <>{ui}</>,
  });
  const settingsRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/settings",
    component: () => <div data-testid="settings-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([indexRoute, settingsRoute]),
    history: createMemoryHistory({ initialEntries: ["/"] }),
  });
  return render(<RouterProvider router={router as any} />);
}

afterEach(() => vi.clearAllMocks());

describe("parseConfigMissing", () => {
  it("unwraps a 422 config_missing envelope", () => {
    const cm = parseConfigMissing(configMissingError());
    expect(cm).not.toBeNull();
    expect(cm?.message).toMatch(/Finish setup/);
    expect(cm?.missing.map((m) => m.key)).toEqual(["metamodel_catalog", "warehouse"]);
  });

  it("returns null for unrelated errors", () => {
    expect(parseConfigMissing(new Error("boom"))).toBeNull();
    expect(
      parseConfigMissing(new ApiError(409, "Conflict", { detail: { error: "other" } })),
    ).toBeNull();
  });
});

describe("ConfigMissingNotice", () => {
  it("lists every missing label and a working Settings deep-link", async () => {
    wrap(<ConfigMissingNotice missing={MISSING} message="Finish setup." />);
    await waitFor(() =>
      expect(screen.getByText("Finish setup.")).toBeInTheDocument(),
    );
    expect(screen.getByText("Metamodel catalog")).toBeInTheDocument();
    expect(screen.getByText("SQL warehouse")).toBeInTheDocument();
    const links = screen.getAllByRole("link", { name: /configure/i });
    expect(links).toHaveLength(2);
    // Deep-link resolves to the settings tab from settings_url.
    for (const link of links) {
      expect(link.getAttribute("href")).toBe("/settings?tab=platform");
    }
  });
});

describe("notifyConfigMissing", () => {
  it("raises the shared toast and returns true for config_missing", () => {
    expect(notifyConfigMissing(configMissingError())).toBe(true);
    expect(vi.mocked(toast.error)).toHaveBeenCalledTimes(1);
    // The toast body IS the shared ConfigMissingNotice element.
    const arg = vi.mocked(toast.error).mock.calls[0][0] as { type?: unknown };
    expect(arg.type).toBe(ConfigMissingNotice);
  });

  it("does nothing and returns false for other errors", () => {
    expect(notifyConfigMissing(new Error("nope"))).toBe(false);
    expect(vi.mocked(toast.error)).not.toHaveBeenCalled();
  });
});
