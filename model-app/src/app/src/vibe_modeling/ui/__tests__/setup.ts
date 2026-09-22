import "@testing-library/jest-dom/vitest";
import { vi } from "vitest";

// jsdom doesn't implement ResizeObserver, and cmdk (used by Command / combobox
// widgets like the Deployment Catalog picker) calls it on mount. Without a
// polyfill the first render throws and every test using cmdk fails.
if (typeof globalThis.ResizeObserver === "undefined") {
  // Minimal no-op implementation — tests that depend on real resize events
  // are expected to mock separately.
  class ResizeObserverStub {
    observe() {}
    unobserve() {}
    disconnect() {}
  }
  (globalThis as unknown as { ResizeObserver: unknown }).ResizeObserver =
    ResizeObserverStub;
}

// jsdom is missing several DOM methods that Radix UI primitives (Select,
// Popover, Dialog) call during open/close transitions, and that cmdk's
// CommandItem uses for keyboard navigation. Without these polyfills the
// first interaction throws and any test driving a Radix dropdown fails.
// Stub once here so every test gets them — duplicating these in each
// test file drifts.
if (!(Element.prototype as unknown as { scrollIntoView?: unknown }).scrollIntoView) {
  Element.prototype.scrollIntoView = () => undefined;
}
if (!("hasPointerCapture" in Element.prototype)) {
  // @ts-expect-error jsdom polyfill
  Element.prototype.hasPointerCapture = () => false;
}
if (!("releasePointerCapture" in Element.prototype)) {
  // @ts-expect-error jsdom polyfill
  Element.prototype.releasePointerCapture = () => undefined;
}
if (!("setPointerCapture" in Element.prototype)) {
  // @ts-expect-error jsdom polyfill
  Element.prototype.setPointerCapture = () => undefined;
}

// @testing-library/react@16's ``waitFor`` checks for ``globalThis.jest`` when
// fake timers are in use. With vitest 4 (no ``jest`` global), waitFor falls
// back to real-timer polling — but real ``setInterval`` is also faked by
// ``vi.useFakeTimers()``, so the polling loop never fires and waitFor times
// out. Expose a minimal ``jest`` shim that proxies to ``vi`` so waitFor's
// fake-timer detection branch lights up. Tests that explicitly opt into
// ``vi.useFakeTimers()`` then drive ``waitFor`` deterministically.
if (typeof (globalThis as unknown as { jest?: unknown }).jest === "undefined") {
  (globalThis as unknown as { jest: unknown }).jest = {
    advanceTimersByTime: (ms: number) => vi.advanceTimersByTime(ms),
    runAllTimers: () => vi.runAllTimers(),
    runOnlyPendingTimers: () => vi.runOnlyPendingTimers(),
    getTimerCount: () => vi.getTimerCount(),
  };
}
