/**
 * Render-stability helper.
 *
 * Bug 2 in Phase 4.5 (PR #151): two siblings each subscribed to a
 * `useGetAgentConfig` query that 404'd. React Query's retry+error path
 * re-fired both effects every render; the page never committed. The
 * existing 148 frontend tests caught nothing because none of them counted
 * renders.
 *
 * Usage in a page-tree test:
 *
 *   const counter = createRenderCounter("AgentConfigSection", 16);
 *   render(
 *     <RenderCounted counter={counter}>
 *       <AgentConfigSection />
 *     </RenderCounted>
 *   );
 *   await waitFor(() => expect(counter.count).toBeGreaterThan(0));
 *   await new Promise((r) => setTimeout(r, 200));
 *   expect(counter.count).toBeLessThanOrEqual(counter.max);
 *
 * The bound (`max`) accounts for StrictMode (×2) plus a few error-state
 * transitions. Bug-2 produced 100+ renders/sec for as long as the page
 * was mounted, so any reasonable bound trips immediately on regression.
 */
import { ReactNode } from "react";

export interface RenderCounter {
  /** Component name for error messages. */
  name: string;
  /** Maximum permitted renders before the test fails. */
  max: number;
  /** Live render count; read after `waitFor` settles. */
  count: number;
  /** Increment hook for the wrapper. */
  tick(): void;
}

export function createRenderCounter(name: string, max = 16): RenderCounter {
  const counter: RenderCounter = {
    name,
    max,
    count: 0,
    tick() {
      counter.count += 1;
      if (counter.count > counter.max + 50) {
        // Hard ceiling: if we somehow blow past the bound, throw to stop a
        // runaway loop from hanging the test runner.
        throw new Error(
          `RenderCounter[${counter.name}]: render count ${counter.count} ` +
          `exceeded hard ceiling ${counter.max + 50}. Likely a render loop.`,
        );
      }
    },
  };
  return counter;
}

/**
 * Wrapper that ticks a counter on every render of its subtree.
 *
 * Intentionally a *function component* (not memoized) so React always
 * re-renders the wrapper when its parent re-renders. Children are
 * rendered as-is — the wrapper itself does no DOM work.
 */
export function RenderCounted({
  counter,
  children,
}: {
  counter: RenderCounter;
  children: ReactNode;
}) {
  counter.tick();
  return <>{children}</>;
}
