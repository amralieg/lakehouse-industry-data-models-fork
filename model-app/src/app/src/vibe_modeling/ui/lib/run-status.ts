/**
 * Canonical FE terminal-status set for ``Run.status``.
 *
 * A run is done — no further status transitions, no more polling needed —
 * once it lands in one of these states. Mirrors the backend's
 * ``_TERMINAL_RUN_STATUSES`` (``backend/run_state_transitions.py``) with one
 * intentional narrowing: the backend set also includes ``"rolled_back"``,
 * a value the FE-generated ``RunStatus`` enum (``lib/api.ts``) does not
 * define — no route ever assigns/reads it today, so it is left out here
 * rather than widening the FE enum for a value nothing produces.
 *
 * Before this module existed, four call sites each declared their own
 * inline terminal-status array; one of them (the ``RunHierarchyPipeline``
 * ``runTerminalAtMs`` computation) had drifted and omitted
 * ``"rolled_back_failed"``. Import ``isTerminalRunStatus`` instead of
 * re-declaring the list so the sites can't drift again.
 */
import type { RunStatus } from "@/lib/api";

export const TERMINAL_RUN_STATUSES = new Set<RunStatus>([
  "completed",
  "failed",
  "cancelled",
  "rolled_back_failed",
]);

export function isTerminalRunStatus(status: RunStatus | string): boolean {
  return TERMINAL_RUN_STATUSES.has(status as RunStatus);
}
