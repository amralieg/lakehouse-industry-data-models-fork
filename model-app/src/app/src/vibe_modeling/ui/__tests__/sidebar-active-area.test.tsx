/**
 * Track 6 item 4 (0.6.6 bug bash): the sidebar's active-item highlight was
 * URL-prefix-only (`path.startsWith("/businesses")` etc.), so an industry
 * detail page - which lives under `/businesses/$businessId/*` because
 * industries share the business detail surface (`kind === "industry"`) -
 * wrongly highlighted "Businesses" instead of "Industries".
 *
 * `activeArea(path, businessKind)` is the single resolver route.tsx now
 * uses instead of per-item `match(path)` predicates. It's exported as a
 * pure function, so the resolution logic itself is covered directly; a
 * second block mounts `Layout` with a mocked `useGetBusiness` to confirm
 * the resolver is actually wired into the rendered active class.
 */
import { beforeAll, describe, expect, it, vi } from "vitest";
import { screen, waitFor } from "@testing-library/react";

// jsdom doesn't implement matchMedia; the shadcn Sidebar's `useIsMobile`
// hook calls it on mount (see domain-sidebar.test.tsx for the same shim).
beforeAll(() => {
  if (!window.matchMedia) {
    Object.defineProperty(window, "matchMedia", {
      writable: true,
      value: (query: string) => ({
        matches: false,
        media: query,
        onchange: null,
        addListener: () => {},
        removeListener: () => {},
        addEventListener: () => {},
        removeEventListener: () => {},
        dispatchEvent: () => false,
      }),
    });
  }
});

let businessKind: string | undefined = undefined;

vi.mock("@/components/explorer/business-tree", () => ({
  BusinessTree: () => <div data-testid="business-tree-stub" />,
}));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusiness: () => ({
      data: businessKind ? { kind: businessKind } : undefined,
    }),
    // The rendered `Layout` includes `SidebarLayout` -> `SidebarUserFooter`,
    // which suspense-fetches the current user - irrelevant to the
    // active-area assertions here, so stub it (same pattern as
    // sidebar-user-footer.test.tsx).
    useCurrentUserSuspense: () => ({
      data: { user_name: "test-user", display_name: "Test User" },
    }),
  };
});

import { activeArea, Layout } from "@/routes/_sidebar/route";
import { renderWithRouter } from "./helpers/router-wrapper";

describe("activeArea (Track 6 item 4)", () => {
  it("highlights Industries on a business route when kind is 'industry'", () => {
    expect(activeArea("/businesses/biz-1", "industry")).toBe("industries");
    expect(activeArea("/businesses/biz-1/runs", "industry")).toBe("industries");
    expect(activeArea("/businesses/biz-1/model/1/ecm", "industry")).toBe(
      "industries",
    );
  });

  it("highlights Businesses on a business route when kind is 'business'", () => {
    expect(activeArea("/businesses/biz-1", "business")).toBe("businesses");
    expect(activeArea("/businesses/biz-1/runs", "business")).toBe(
      "businesses",
    );
  });

  it("defaults to Businesses while kind is still loading (undefined) - no Industries flash", () => {
    expect(activeArea("/businesses/biz-1", undefined)).toBe("businesses");
  });

  it("highlights Industries on the list/new industry routes regardless of kind", () => {
    expect(activeArea("/industries", undefined)).toBe("industries");
    expect(activeArea("/industries/new", "business")).toBe("industries");
  });

  it("highlights Businesses on the business 'new' route (no id to resolve kind for)", () => {
    expect(activeArea("/businesses/new", "industry")).toBe("businesses");
  });

  it("highlights Settings on settings routes", () => {
    expect(activeArea("/settings", "industry")).toBe("settings");
  });

  it("highlights Businesses on the root path", () => {
    expect(activeArea("/", undefined)).toBe("businesses");
  });
});

function activeLinkLabel(): string | undefined {
  const links = screen.getAllByRole("link");
  // Split into class tokens and match exactly - the inactive branch's
  // `hover:bg-sidebar-accent` token contains "bg-sidebar-accent" as a
  // substring, so a naive `.includes()` check would false-positive on it.
  const active = links.find((el) =>
    el.className.split(/\s+/).includes("bg-sidebar-accent"),
  );
  return active?.textContent ?? undefined;
}

function ariaCurrentLabel(): string | undefined {
  const links = screen.getAllByRole("link");
  const current = links.find((el) => el.getAttribute("aria-current") === "page");
  return current?.textContent ?? undefined;
}

describe("Layout - rendered active nav item (Track 6 item 4)", () => {
  it("highlights Industries when mounted on a business route whose kind is 'industry'", async () => {
    businessKind = "industry";
    renderWithRouter(<Layout />, { initialPath: "/businesses/biz-1" });
    await waitFor(() => {
      expect(activeLinkLabel()).toBe("Industries");
    });
  });

  it("highlights Businesses when mounted on a business route whose kind is 'business'", async () => {
    businessKind = "business";
    renderWithRouter(<Layout />, { initialPath: "/businesses/biz-1" });
    await waitFor(() => {
      expect(activeLinkLabel()).toBe("Businesses");
    });
  });

  // Tester finding (0.6.6 bug bash): TanStack's own prefix-based Link
  // active-matching independently stamped aria-current="page" on
  // "Businesses" for every /businesses/$id/* page - including industry
  // pages - regardless of the (correct) visual highlight computed from
  // `activeArea`. Screen readers / automation were told the wrong current
  // item. `aria-current` must track `activeArea`, not TanStack's own
  // resolution.
  it("puts aria-current=\"page\" on Industries, not Businesses, for an industry page", async () => {
    businessKind = "industry";
    renderWithRouter(<Layout />, { initialPath: "/businesses/biz-1" });
    await waitFor(() => {
      expect(ariaCurrentLabel()).toBe("Industries");
    });
    expect(ariaCurrentLabel()).not.toBe("Businesses");
  });

  it("puts aria-current=\"page\" on Businesses for a plain business page", async () => {
    businessKind = "business";
    renderWithRouter(<Layout />, { initialPath: "/businesses/biz-1" });
    await waitFor(() => {
      expect(ariaCurrentLabel()).toBe("Businesses");
    });
  });
});

// Help and Settings moved out of the sidebar nav and live only as top-bar
// icons (icon-only links carrying an aria-label, no visible text). The
// sidebar nav is now Businesses + Industries only. These assertions pin
// that end state so a future edit can't silently re-add a sidebar entry or
// drop a top-bar icon.
describe("Layout - Help/Settings live only in the top bar", () => {
  it("renders Help and Settings as top-bar icon links reachable by accessible name", async () => {
    businessKind = "business";
    renderWithRouter(<Layout />, { initialPath: "/businesses/biz-1" });
    await waitFor(() => {
      expect(screen.getByRole("link", { name: "Help" })).toBeInTheDocument();
    });
    expect(screen.getByRole("link", { name: "Settings" })).toBeInTheDocument();
  });

  it("does not render Help or Settings as sidebar nav items (no visible-text nav link)", async () => {
    businessKind = "business";
    renderWithRouter(<Layout />, { initialPath: "/businesses/biz-1" });
    await waitFor(() => {
      expect(screen.getByRole("link", { name: "Businesses" })).toBeInTheDocument();
    });
    const navLabels = screen
      .getAllByRole("link")
      .map((el) => el.textContent?.trim())
      .filter(Boolean);
    expect(navLabels).toContain("Businesses");
    expect(navLabels).toContain("Industries");
    // The top-bar Help/Settings icons carry no visible text, so any link
    // whose visible text is "Help"/"Settings" could only be a sidebar entry.
    expect(navLabels).not.toContain("Help");
    expect(navLabels).not.toContain("Settings");
  });
});
