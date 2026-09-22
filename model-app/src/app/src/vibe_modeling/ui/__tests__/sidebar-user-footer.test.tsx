/**
 * `SidebarUserFooter` tests.
 *
 * The footer wraps a `useCurrentUserSuspense` consumer in a `<Suspense>`
 * so the unauth/loading state shows a skeleton. We stub the suspense
 * hook directly via `vi.mock("@/lib/api")` (same pattern as
 * `model-version-page.test.tsx`) so the footer renders synchronously.
 *
 * The footer also depends on `<SidebarMenuButton>` which requires the
 * shadcn `<SidebarProvider>` context — tests mount inside one.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";

let userHook: () => unknown = () => ({
  data: { user_name: "Ada Lovelace", display_name: "Ada L." },
});

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useCurrentUserSuspense: () => userHook(),
  };
});

import SidebarUserFooter from "@/components/apx/sidebar-user-footer";
import { SidebarProvider } from "@/components/ui/sidebar";

// SidebarProvider's `useIsMobile` calls window.matchMedia which jsdom
// doesn't ship. Stub once for the suite.
beforeEach(() => {
  Object.defineProperty(window, "matchMedia", {
    configurable: true,
    writable: true,
    value: vi.fn((q: string) => ({
      matches: false,
      media: q,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    })),
  });
});

afterEach(() => {
  userHook = () => ({
    data: { user_name: "Ada Lovelace", display_name: "Ada L." },
  });
  vi.restoreAllMocks();
});

function renderFooter() {
  return render(
    <SidebarProvider>
      <SidebarUserFooter />
    </SidebarProvider>,
  );
}

describe("SidebarUserFooter", () => {
  it("renders the user's display name and user_name", () => {
    userHook = () => ({
      data: { user_name: "Ada Lovelace", display_name: "Ada L." },
    });
    renderFooter();
    expect(screen.getByText("Ada L.")).toBeInTheDocument();
    expect(screen.getByText("Ada Lovelace")).toBeInTheDocument();
  });

});
