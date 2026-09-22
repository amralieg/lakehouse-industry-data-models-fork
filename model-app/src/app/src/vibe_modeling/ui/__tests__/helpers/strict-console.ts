/**
 * Strict console helper: capture React DOM-nesting warnings as test
 * failures.
 *
 * Bug 3 in Phase 4.5 (`<Badge>` rendered as `<div>` inside `<p>` and
 * `<span>` parents) had been emitting `validateDOMNesting` warnings on
 * every render for months. Vitest doesn't fail on console.error by
 * default, so the suite stayed green.
 *
 * Usage:
 *
 *   import { useStrictConsole } from "./helpers/strict-console";
 *
 *   describe("MyPage", () => {
 *     const dom = useStrictConsole();
 *     it("renders without DOM-nesting warnings", () => {
 *       render(<MyPage />);
 *       expect(dom.messages).toEqual([]);
 *     });
 *   });
 *
 * Captures only nesting-related warnings — other console.error calls
 * (e.g. ErrorBoundary fallbacks the test is *expecting*) pass through
 * untouched.
 */
import { afterEach, beforeEach } from "vitest";

export interface StrictConsoleHandle {
  /** All captured DOM-nesting warning messages since the last beforeEach. */
  messages: string[];
}

const NESTING_MARKERS = [
  "validateDOMNesting",
  "cannot be a descendant",
  "cannot contain",
  "In HTML, ", // React 19 phrasing
];

/**
 * Install before/after hooks that capture DOM-nesting console.error
 * messages. Returns a handle whose `.messages` array fills as the test
 * runs and resets per-test.
 */
export function useStrictConsole(): StrictConsoleHandle {
  const handle: StrictConsoleHandle = { messages: [] };
  let original: typeof console.error;

  beforeEach(() => {
    handle.messages = [];
    original = console.error;
    console.error = (...args: unknown[]) => {
      const msg = args.map((a) => String(a)).join(" ");
      if (NESTING_MARKERS.some((marker) => msg.includes(marker))) {
        handle.messages.push(msg);
      }
      original.apply(console, args as []);
    };
  });

  afterEach(() => {
    console.error = original;
  });

  return handle;
}
