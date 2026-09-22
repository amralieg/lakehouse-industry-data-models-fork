/**
 * ThemeProvider context tests.
 *
 * Single integration test exercising the full surface: localStorage
 * preference wins over default, the resolved theme reaches consumers via
 * useTheme, and the resolved theme is applied as a class on documentElement.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { ThemeProvider, useTheme } from "@/components/apx/theme-provider";

// Node 25 ships an experimental localStorage that shadows jsdom's
// implementation but exposes no methods (`.clear`, `.getItem`, `.setItem`
// are all undefined). We replace it with a minimal Map-backed shim so
// the provider's getItem/setItem calls succeed.
function installLocalStorageShim() {
  const store = new Map<string, string>();
  const shim: Storage = {
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
  };
  vi.stubGlobal("localStorage", shim);
  return shim;
}

function ThemeProbe() {
  const { theme } = useTheme();
  return <div data-testid="theme-probe">{theme}</div>;
}

describe("ThemeProvider", () => {
  beforeEach(() => {
    installLocalStorageShim();
    document.documentElement.classList.remove("light", "dark");
  });
  afterEach(() => {
    vi.unstubAllGlobals();
    document.documentElement.classList.remove("light", "dark");
  });

  it("resolves localStorage > default and applies the class", () => {
    const shim = installLocalStorageShim();
    shim.setItem("vite-ui-theme", "dark");
    render(
      <ThemeProvider defaultTheme="light">
        <ThemeProbe />
      </ThemeProvider>,
    );
    // Stored 'dark' wins over default 'light' for both consumer + DOM class.
    expect(screen.getByTestId("theme-probe")).toHaveTextContent("dark");
    expect(document.documentElement.classList.contains("dark")).toBe(true);
  });
});
