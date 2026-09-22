/**
 * Single hierarchical pipeline tree for the run-detail page.
 *
 * Replaces the two decoupled components that previously lived on the run-detail
 * page ("Pipeline Steps" = RunOperationsPipeline + "Pipeline Progress" =
 * ProgressPipeline). The tree has two levels:
 *
 *   Phase  — one per RunOperation (DAG node). Label: "Phase N — operation_name".
 *   Step   — grouped RunProgressEvent rows keyed by stage_name, nested under
 *            the Phase that owns them.
 *
 * Owning-Phase resolution: RunProgressEvent has no run_operation_id column.
 * We fall back to step_id-range association using phase boundary events
 * (stage_name matching /^Phase \d+:/) whose step_ids delimit each phase's
 * event window. Events with step_id ≥ boundary_N and < boundary_{N+1} belong
 * to Phase N; everything before boundary_1 belongs to Phase 1.
 *
 * Synthetic phase-boundary events are filtered out at render time (not stored).
 */

import { useSuspenseQuery } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  CheckCircle2,
  XCircle,
  Clock,
  Loader2,
  AlertTriangle,
  RotateCcw,
  ChevronDown,
  ChevronRight,
} from "lucide-react";
import { formatDuration } from "@/lib/date";
import { getRunProgress, useListRunOperations, type RunOperationOut, type RunStatus } from "@/lib/api";
import { isTerminalRunStatus } from "@/lib/run-status";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface ProgressEvent {
  id: string;
  step_id: number;
  stage_name: string;
  step_name: string;
  status: string;
  message: string;
  progress_increment: number;
  created_at: string;
}

interface PhaseStep {
  /** The agent's stage_name — displayed as our "Step" label. */
  name: string;
  events: ProgressEvent[];
  status: "completed" | "running" | "failed" | "pending" | "warning";
  startMs: number;
  /** null while still running or pending */
  endMs: number | null;
  /**
   * The most informative single-line message for this step:
   *  - Prefer the message of the terminal event (stage_succeeded /
   *    stage_failed / stage_warning) — agents typically use the close
   *    event to emit a high-level summary like
   *    "Generated 35 products across 8 domains".
   *  - Falls back to the latest event's message while still in flight.
   *
   * Without this, a stage that emits many in-progress events with the
   * same stage_name would collapse to whichever per-domain ping arrived
   * last, hiding the summary line. See bug #46.
   */
  summaryMessage: string;
}

// ---------------------------------------------------------------------------
// Status sets — mirrored from the former progress-pipeline.tsx
// ---------------------------------------------------------------------------

/** Agent status values that indicate the step is still active. */
export const RUNNING_STATUSES = new Set([
  "stage_started",
  "stage_in_progress",
  "running",
  "in_progress",
]);

/** Agent status values that indicate a non-fatal terminal signal. */
export const TERMINAL_OK_STATUSES = new Set([
  "stage_succeeded",
  "stage_ended",
  "completed",
  "done",
  "skipped",
  "stage_skipped",
]);

/**
 * Stages that completed with a non-fatal warning (e.g. partial
 * metric-view compile failures from LLM-hallucinated columns). Distinct
 * from ``TERMINAL_OK_STATUSES`` so we can render warnings with an
 * amber AlertTriangle and surface the structured ``result_json``
 * failure details. The agent never emits a close after a warning, so
 * these are terminal.
 */
export const WARNING_STATUSES = new Set(["stage_warning", "warning"]);

export const FAILED_STATUSES = new Set(["stage_failed", "failed", "error"]);

export const TERMINAL_STATUSES = new Set<string>([
  ...FAILED_STATUSES,
  ...TERMINAL_OK_STATUSES,
  ...WARNING_STATUSES,
]);

// ---------------------------------------------------------------------------
// Phase-boundary detection
// ---------------------------------------------------------------------------

/** Synthetic boundary events inserted by the backend on phase transitions. */
export const PHASE_BOUNDARY_REGEX = /^Phase \d+:/;

function isPhaseBoundary(e: ProgressEvent): boolean {
  return PHASE_BOUNDARY_REGEX.test(e.stage_name || "");
}

/**
 * The agent emits a "Vibe Session" stage with two events bracketing each
 * phase: a `stage_started` at the very beginning ("Session Started") and a
 * terminal `stage_ended` at the very end carrying the final message
 * (success summary, or — on the failure path — the ValueError text from
 * `_finalize_common`'s hardcoded `stage_ended` literal). Rendered as a
 * peer step it lands at the top of the substep list with a green
 * checkmark, even on failure, which reads as "the error happened in
 * the first step." We render it as a top + bottom bracket around the
 * per-phase substep list instead. See F11/F12 in the walkthrough notes.
 */
export const VIBE_SESSION_STAGE = "Vibe Session";

function isVibeSessionEvent(e: ProgressEvent): boolean {
  return (e.stage_name || "") === VIBE_SESSION_STAGE;
}

// ---------------------------------------------------------------------------
// Supersession helper
// ---------------------------------------------------------------------------

/**
 * A running event whose step_id is older than the global max has been
 * implicitly superseded by newer events. Render as completed to avoid
 * stale spinners.
 */
export function isSuperseded(step: ProgressEvent, maxStepId: number): boolean {
  return RUNNING_STATUSES.has(step.status) && step.step_id < maxStepId;
}

// ---------------------------------------------------------------------------
// Grouping helpers
// ---------------------------------------------------------------------------

/**
 * For a set of events (already scoped to one Phase), group by stage_name into
 * PhaseStep entries.
 */
function groupEventsIntoSteps(
  events: ProgressEvent[],
  maxStepId: number,
  runTerminalAtMs: number | null,
): PhaseStep[] {
  const stepMap = new Map<string, ProgressEvent[]>();
  for (const e of events) {
    // Vibe Session is rendered as a top/bottom bracket around the substep
    // list in PhaseRow, not as a peer step. Drop it from the grouping
    // so it doesn't appear inside the list.
    if (isVibeSessionEvent(e)) continue;
    const key = e.stage_name || "Unknown";
    if (!stepMap.has(key)) stepMap.set(key, []);
    stepMap.get(key)!.push(e);
  }

  const realStepIds = events
    .map((e) => e.step_id)
    .filter((id) => id > 0)
    .sort((a, b) => a - b);
  const phaseMaxStepId =
    realStepIds.length > 0 ? realStepIds[realStepIds.length - 1] : 0;

  const syntheticCutoff =
    runTerminalAtMs !== null && runTerminalAtMs > phaseMaxStepId
      ? runTerminalAtMs
      : runTerminalAtMs !== null
        ? phaseMaxStepId + 1
        : null;
  const effectiveMax = syntheticCutoff ?? maxStepId;
  const allStepIds = syntheticCutoff !== null
    ? [...realStepIds, syntheticCutoff].sort((a, b) => a - b)
    : realStepIds;

  return Array.from(stepMap.entries()).map(([name, steps]) => {
    const isEffectivelyTerminal = (s: ProgressEvent) =>
      TERMINAL_STATUSES.has(s.status) || isSuperseded(s, effectiveMax);

    let status: PhaseStep["status"] = "pending";
    if (steps.some((s) => FAILED_STATUSES.has(s.status))) {
      status = "failed";
    } else if (steps.every(isEffectivelyTerminal)) {
      // Warning takes precedence over completed when any constituent
      // event is a non-fatal warning — surfaces partial-success state
      // (e.g. metric-view compile failures) the user must see.
      if (steps.some((s) => WARNING_STATUSES.has(s.status))) {
        status = "warning";
      } else {
        status = "completed";
      }
    } else if (
      steps.some(
        (s) => RUNNING_STATUSES.has(s.status) && !isSuperseded(s, effectiveMax),
      )
    ) {
      status = "running";
    }

    const stageStepIds = steps.map((s) => s.step_id).filter((id) => id > 0);
    const startMs = stageStepIds.length > 0 ? Math.min(...stageStepIds) : 0;
    const stageMaxMs = stageStepIds.length > 0 ? Math.max(...stageStepIds) : 0;

    let endMs: number | null = null;
    if (status === "completed" || status === "failed") {
      const lastEvent = steps.reduce(
        (a, b) => (a.step_id > b.step_id ? a : b),
        steps[0],
      );
      const lastIsExplicitTerminal =
        !!lastEvent && TERMINAL_STATUSES.has(lastEvent.status);
      if (lastIsExplicitTerminal) {
        endMs = stageMaxMs;
      } else {
        const nextGlobal = allStepIds.find((id) => id > stageMaxMs);
        endMs = nextGlobal ?? stageMaxMs;
      }
    }

    // Pick the most-informative single-line message for this step.
    // Prefer the terminal event's message (typically the agent's summary
    // line, e.g. "Generated 35 products across 8 domains"). Fall back to
    // the latest event by step_id while still running.
    const orderedByStepId = [...steps].sort((a, b) => a.step_id - b.step_id);
    const terminalEvent = [...orderedByStepId]
      .reverse()
      .find((s) => TERMINAL_STATUSES.has(s.status));
    const latestEvent = orderedByStepId[orderedByStepId.length - 1];
    const summaryEvent = terminalEvent ?? latestEvent;
    const summaryMessage = summaryEvent?.message || summaryEvent?.step_name || "";

    return { name, events: steps, status, startMs, endMs, summaryMessage };
  });
}

/** Parse a backend datetime string (naive UTC, may lack a `Z` suffix) into
 *  an epoch millisecond. Falls back to `Date.parse` for already-zoned
 *  strings. Returns NaN if unparsable. */
function parseBackendDate(s: string | null | undefined): number {
  if (!s) return NaN;
  // `2026-04-26T19:47:59.892815` (no TZ marker) — JS parses this as local
  // time. Backend stamps are naive UTC, so append `Z` if no offset is
  // present. See `feedback_naive_utc_tz.md`.
  const hasTz = /(?:Z|[+-]\d{2}:?\d{2})$/.test(s);
  return Date.parse(hasTz ? s : `${s}Z`);
}

/**
 * Partition all events (excluding boundary events) into per-phase buckets
 * by comparing each event's ``created_at`` against each RunOperation's
 * ``[started_at, completed_at)`` window.
 *
 * The agent reuses stage names across phases (e.g. "Logical Schema
 * Generation" appears in both ``generate_ecm`` and ``shrink_to_mvm``), so
 * partitioning by stage_name doesn't work. The legacy approach was to
 * detect boundary events with a "Phase N:" stage_name, but no producer
 * emits those — the orchestrator transitions phases without injecting a
 * synthetic event. The reliable signal is the wall-clock window: each
 * RunOperation has authoritative ``started_at``/``completed_at`` stamps,
 * and each event has ``created_at``.
 *
 * Returns a Map keyed by RunOperation.id, in step_index order. Boundary
 * events (legacy "Phase N:" stage_name) are still filtered out for
 * backwards compatibility but are not used to drive partitioning.
 */
export function partitionEventsByPhase(
  events: ProgressEvent[],
  operations: RunOperationOut[],
): Map<string, ProgressEvent[]> {
  const ops = [...operations].sort((a, b) => a.step_index - b.step_index);
  const result = new Map<string, ProgressEvent[]>();
  for (const op of ops) result.set(op.id, []);

  if (ops.length === 0) return result;

  const realEvents = events.filter((e) => !isPhaseBoundary(e));

  // Pre-compute each operation's [start, end) window in epoch ms. A
  // null `completed_at` (still running) maps to +Infinity. A null
  // `started_at` (pending) maps to +Infinity start so the op's window is
  // empty and never claims an event.
  const windows = ops.map((op) => {
    const start = parseBackendDate(op.started_at);
    const endRaw = parseBackendDate(op.completed_at);
    return {
      start: Number.isFinite(start) ? start : Number.POSITIVE_INFINITY,
      end: Number.isFinite(endRaw) ? endRaw : Number.POSITIVE_INFINITY,
    };
  });

  for (const e of realEvents) {
    const t = parseBackendDate(e.created_at);
    let opIdx = 0;
    if (Number.isFinite(t)) {
      // Find the last operation whose window starts at or before this
      // event's created_at — that's its phase. Walking forward keeps us
      // assigning events to the latest applicable op (events emitted
      // after a phase has completed but before the next phase started
      // are rare; they go to the most-recent started phase).
      for (let i = 0; i < ops.length; i++) {
        if (windows[i].start <= t) opIdx = i;
        else break;
      }
    }
    result.get(ops[opIdx].id)!.push(e);
  }

  return result;
}

// ---------------------------------------------------------------------------
// Data fetching
// ---------------------------------------------------------------------------

async function fetchProgress(
  businessId: string,
  runId: string,
): Promise<ProgressEvent[]> {
  // Phase 7 drift-unification: route through the Orval-generated helper so
  // the request shape + error envelope track the OpenAPI spec automatically.
  // The local ProgressEvent shape is a strict subset of ProgressEventOut, so
  // the cast below is safe.
  const resp = await getRunProgress({
    business_id: businessId,
    run_id: runId,
  });
  return resp.data as unknown as ProgressEvent[];
}

// ---------------------------------------------------------------------------
// Phase-level status icon
// ---------------------------------------------------------------------------

const phaseStatusConfig: Record<
  string,
  { icon: React.ReactNode; variant: "default" | "secondary" | "destructive" | "outline" }
> = {
  pending: { icon: <Clock className="h-3 w-3" />, variant: "outline" },
  running: { icon: <Loader2 className="h-3 w-3 animate-spin" />, variant: "default" },
  succeeded: { icon: <CheckCircle2 className="h-3 w-3" />, variant: "secondary" },
  failed: { icon: <XCircle className="h-3 w-3" />, variant: "destructive" },
  skipped: { icon: <Clock className="h-3 w-3" />, variant: "outline" },
  rolled_back: { icon: <RotateCcw className="h-3 w-3" />, variant: "outline" },
};

// ---------------------------------------------------------------------------
// Sub-components
// ---------------------------------------------------------------------------

function StepStatusIcon({ status }: { status: PhaseStep["status"] }) {
  if (status === "completed") return <CheckCircle2 className="w-4 h-4 text-green-500" />;
  if (status === "warning") return <AlertTriangle className="w-4 h-4 text-warning" />;
  if (status === "failed") return <XCircle className="w-4 h-4 text-red-500" />;
  if (status === "running") return <Loader2 className="w-4 h-4 text-primary animate-spin" />;
  return <div className="w-4 h-4 rounded-full border-2 border-border" />;
}

function EventIcon({ event, superseded }: { event: ProgressEvent; superseded: boolean }) {
  const status = event.status;
  if (FAILED_STATUSES.has(status)) {
    return <XCircle className="w-3 h-3 text-red-500 shrink-0 mt-0.5" />;
  }
  if (WARNING_STATUSES.has(status)) {
    return <AlertTriangle className="w-3 h-3 text-warning shrink-0 mt-0.5" />;
  }
  if (TERMINAL_OK_STATUSES.has(status) || superseded) {
    return <CheckCircle2 className="w-3 h-3 text-green-500/80 shrink-0 mt-0.5" />;
  }
  if (RUNNING_STATUSES.has(status)) {
    return <Loader2 className="w-3 h-3 text-primary animate-spin shrink-0 mt-0.5" />;
  }
  return <div className="w-3 h-3 rounded-full border border-border shrink-0 mt-0.5" />;
}

const stepNameColor: Record<PhaseStep["status"], string> = {
  running: "text-primary",
  completed: "text-green-500",
  warning: "text-warning",
  failed: "text-red-500",
  pending: "text-muted-foreground",
};

function PhaseStepRow({
  step,
  isLast,
  maxStepId,
  nowMs,
}: {
  step: PhaseStep;
  isLast: boolean;
  maxStepId: number;
  nowMs: number;
}) {
  const [expanded, setExpanded] = useState(step.status === "running");
  const eventCount = step.events.length;

  let durationMs: number | null = null;
  if (step.startMs > 0) {
    if (step.endMs !== null) {
      durationMs = step.endMs - step.startMs;
    } else if (step.status === "running") {
      durationMs = nowMs - step.startMs;
    }
  }

  return (
    <div className="relative">
      {!isLast && (
        <div
          className={`absolute left-[19px] top-10 bottom-0 w-0.5 ${
            step.status === "completed"
              ? "bg-green-500/30"
              : step.status === "warning"
                ? "bg-warning/30"
                : "bg-border"
          }`}
        />
      )}
      <div className="relative flex gap-3">
        <div className="mt-1 shrink-0 z-10 bg-card">
          <StepStatusIcon status={step.status} />
        </div>
        <div className="flex-1 min-w-0 pb-4">
          <button
            onClick={() => eventCount > 0 && setExpanded(!expanded)}
            className="w-full flex items-center justify-between group text-left"
          >
            <div className="flex items-center gap-2">
              <span className={`text-sm font-medium ${stepNameColor[step.status]}`}>
                {step.name}
              </span>
              {durationMs !== null && (
                <span
                  className={`text-[11px] px-1.5 py-0.5 rounded tabular-nums ${
                    step.status === "running"
                      ? "text-primary bg-primary/10"
                      : "text-muted-foreground bg-muted"
                  }`}
                  title={
                    step.status === "running"
                      ? "Elapsed since step started"
                      : "Total step duration"
                  }
                >
                  {formatDuration(durationMs)}
                </span>
              )}
            </div>
            {eventCount > 0 && (
              expanded
                ? <ChevronDown className="w-3.5 h-3.5 text-muted-foreground" />
                : <ChevronRight className="w-3.5 h-3.5 text-muted-foreground" />
            )}
          </button>

          {!expanded && step.summaryMessage && (
            <p
              className="text-xs text-muted-foreground mt-0.5 truncate"
              data-testid="step-summary-message"
            >
              {step.summaryMessage}
            </p>
          )}

          {expanded && step.events.length > 0 && (
            <div className="mt-2 space-y-1">
              {step.events.map((evt) => (
                <div
                  key={evt.id}
                  className="flex items-start gap-2 py-1 px-2 rounded bg-muted/50 text-xs"
                >
                  <EventIcon event={evt} superseded={isSuperseded(evt, maxStepId)} />
                  <div className="min-w-0">
                    <span className="text-foreground/80 font-medium">{evt.step_name}</span>
                    {evt.message && evt.message !== evt.step_name && (
                      <span className="text-muted-foreground ml-1.5">— {evt.message}</span>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

/**
 * Pick the first (lowest step_id) and last (highest step_id) Vibe Session
 * events from a phase's event list. The agent emits one `stage_started`
 * at the start of the phase and one terminal `stage_ended` at the end,
 * but be defensive — the ordering and count are agent-side details we
 * shouldn't rely on. Returns `{ start, end }` where either may be null
 * if no Vibe Session events were observed for this phase.
 */
export function extractVibeSessionBrackets(
  events: ProgressEvent[],
): { start: ProgressEvent | null; end: ProgressEvent | null } {
  const vibe = events
    .filter(isVibeSessionEvent)
    .sort((a, b) => a.step_id - b.step_id);
  if (vibe.length === 0) return { start: null, end: null };
  const start = vibe[0];
  const end = vibe.length > 1 ? vibe[vibe.length - 1] : null;
  return { start, end };
}

function VibeSessionStartBracket({
  event,
  phaseStartMs,
}: {
  event: ProgressEvent;
  phaseStartMs: number | null;
}) {
  const evMs = parseBackendDate(event.created_at);
  let relative: string | null = null;
  if (
    phaseStartMs !== null &&
    Number.isFinite(phaseStartMs) &&
    Number.isFinite(evMs)
  ) {
    const delta = Math.max(0, evMs - phaseStartMs);
    relative = formatDuration(delta);
  }
  return (
    <div
      data-testid="vibe-session-bracket-start"
      className="flex items-center gap-2 px-2 pt-1 pb-2 text-xs text-muted-foreground"
    >
      <span className="font-medium tracking-tight">Vibe Session started</span>
      {relative && (
        <span className="tabular-nums text-[11px] opacity-70">· {relative}</span>
      )}
    </div>
  );
}

function VibeSessionEndBracket({
  event,
  phaseStartMs,
  phaseStatus,
}: {
  event: ProgressEvent;
  phaseStartMs: number | null;
  phaseStatus: string;
}) {
  // Bottom-bracket color is driven by the parent phase's RunOperation
  // status, NOT the agent's `stage_ended` literal. The agent hardcodes
  // `stage_ended` regardless of outcome (see `_finalize_common`); a
  // failed phase still emits `stage_ended` with the ValueError text in
  // `message`. Trusting the agent literal here was F11/F12 — it gave
  // every failed-phase summary a green checkmark.
  const failed = phaseStatus === "failed";
  const evMs = parseBackendDate(event.created_at);
  let duration: string | null = null;
  if (
    phaseStartMs !== null &&
    Number.isFinite(phaseStartMs) &&
    Number.isFinite(evMs)
  ) {
    const delta = Math.max(0, evMs - phaseStartMs);
    duration = formatDuration(delta);
  }
  const Icon = failed ? XCircle : CheckCircle2;
  const tone = failed ? "text-red-500" : "text-green-500";
  return (
    <div
      data-testid="vibe-session-bracket-end"
      data-failed={failed ? "true" : "false"}
      className="flex flex-col gap-0.5 px-2 pt-2 pb-1 text-xs text-muted-foreground"
    >
      <div className="flex items-center gap-2">
        <Icon className={`w-3 h-3 shrink-0 ${tone}`} />
        <span className="font-medium tracking-tight">Vibe Session ended</span>
        {duration && (
          <span className="tabular-nums text-[11px] opacity-70">· {duration}</span>
        )}
      </div>
      {event.message && (
        <p
          data-testid="vibe-session-bracket-end-message"
          className={`pl-5 text-[11px] ${failed ? "text-red-500/90" : "text-muted-foreground/90"} break-words`}
        >
          {event.message}
        </p>
      )}
    </div>
  );
}

function PhaseRow({
  op,
  steps,
  vibeSession,
  maxStepId,
  nowMs,
}: {
  op: RunOperationOut;
  steps: PhaseStep[];
  vibeSession: { start: ProgressEvent | null; end: ProgressEvent | null };
  maxStepId: number;
  nowMs: number;
}) {
  // Default collapsed for completed/pending phases, expanded for running.
  const defaultExpanded = op.status === "running";
  const [expanded, setExpanded] = useState(defaultExpanded);

  const cfg = phaseStatusConfig[op.status] || phaseStatusConfig.pending;
  const label = `Phase ${op.step_index + 1} — ${op.operation_name}`;

  return (
    <div
      data-testid="phase-row"
      data-phase-index={op.step_index}
      data-status={op.status}
      className="border rounded-md overflow-hidden"
    >
      {/* Phase header — always rendered, even for Phase 1 */}
      <button
        onClick={() => setExpanded((v) => !v)}
        className="w-full flex items-center gap-3 px-4 py-3 text-left hover:bg-muted/30 transition-colors"
        aria-expanded={expanded}
      >
        <Badge
          variant={cfg.variant}
          className="flex items-center gap-1 shrink-0"
          data-testid="phase-status-badge"
        >
          {cfg.icon}
          {op.status}
        </Badge>
        <span className="text-sm font-semibold flex-1 truncate">{label}</span>
        <div className="flex items-center gap-2 shrink-0">
          {op.error_message && (
            <span className="text-xs text-destructive flex items-center gap-1">
              <AlertTriangle className="h-3 w-3" />
              {op.error_message}
            </span>
          )}
          {op.databricks_run_id && op.run_page_url && (
            <a
              href={op.run_page_url}
              target="_blank"
              rel="noopener noreferrer"
              className="text-xs text-primary font-mono underline-offset-2 hover:underline"
              onClick={(e) => e.stopPropagation()}
              title="Open this phase's Databricks job run"
            >
              {op.databricks_run_id} ↗
            </a>
          )}
          {op.output_version_id && (
            <a
              href={op.output_version_url || "#"}
              className="text-xs text-muted-foreground font-mono underline-offset-2 hover:underline"
              data-version-id={op.output_version_id}
              onClick={(e) => e.stopPropagation()}
            >
              → {op.output_version_label || "v?"}
            </a>
          )}
          {expanded
            ? <ChevronDown className="w-4 h-4 text-muted-foreground" />
            : <ChevronRight className="w-4 h-4 text-muted-foreground" />
          }
        </div>
      </button>

      {/* Step children */}
      {expanded && (
        <div className="px-6 pt-2 pb-3 border-t bg-card/50">
          {vibeSession.start && (
            <VibeSessionStartBracket
              event={vibeSession.start}
              phaseStartMs={parseBackendDate(op.started_at)}
            />
          )}
          {steps.length === 0 ? (
            <p className="text-xs text-muted-foreground py-2">
              {op.status === "pending"
                ? "Waiting to start…"
                : "No progress events yet."}
            </p>
          ) : (
            steps.map((step, i) => (
              <PhaseStepRow
                key={step.name}
                step={step}
                isLast={i === steps.length - 1}
                maxStepId={maxStepId}
                nowMs={nowMs}
              />
            ))
          )}
          {vibeSession.end && (
            <VibeSessionEndBracket
              event={vibeSession.end}
              phaseStartMs={parseBackendDate(op.started_at)}
              phaseStatus={op.status}
            />
          )}
        </div>
      )}
    </div>
  );
}

// ---------------------------------------------------------------------------
// Main component
// ---------------------------------------------------------------------------

function RunHierarchyPipelineInner({
  businessId,
  runId,
  status,
  progressPercent,
  runTerminalAtMs,
  operations,
}: {
  businessId: string;
  runId: string;
  status: RunStatus | null;
  progressPercent: number;
  runTerminalAtMs: number | null;
  operations: RunOperationOut[];
}) {
  const { data: events } = useSuspenseQuery<ProgressEvent[]>({
    queryKey: ["run-progress", businessId, runId],
    queryFn: () => fetchProgress(businessId, runId),
    refetchInterval: 5000,
  });

  const sortedOps = [...operations].sort((a, b) => a.step_index - b.step_index);
  const maxStepId =
    events.length > 0 ? Math.max(...events.map((e) => e.step_id)) : 0;

  const hasRunning =
    sortedOps.some((op) => op.status === "running") ||
    events.some(
      (e) => RUNNING_STATUSES.has(e.status) && !isSuperseded(e, maxStepId),
    );

  const [, setNow] = useState(Date.now());
  useEffect(() => {
    if (!hasRunning) return;
    const id = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(id);
  }, [hasRunning]);
  const nowMs = Date.now();

  // Partition events by phase.
  const eventsByPhase = partitionEventsByPhase(events, sortedOps);

  if (sortedOps.length === 0) {
    // No RunOperation rows — legacy / non-orchestrator run or run not
    // yet dispatched.
    if (events.length === 0) {
      // A terminal run with zero RunOperations and zero progress events is
      // not "still booting" - it's an audit-only run (e.g. kickstart-from-
      // industry, download-industry) that never goes through the
      // orchestrator DAG / Delta progress path at all. Render a plain
      // terminal empty state instead of a permanent spinner.
      if (status !== null && isTerminalRunStatus(status)) {
        return (
          <Card>
            <CardContent className="py-8 text-center text-muted-foreground">
              This run has no pipeline checkpoints.
            </CardContent>
          </Card>
        );
      }
      const started = progressPercent > 0;
      return (
        <Card>
          <CardContent className="py-8 text-center text-muted-foreground">
            <Loader2 className="w-5 h-5 animate-spin mx-auto mb-2 text-primary" />
            {started
              ? "Pipeline running — first checkpoint not reached yet."
              : "Waiting for the agent to start the pipeline…"}
          </CardContent>
        </Card>
      );
    }
    // Events exist but no ops to partition them by. Render all events
    // as one synthetic flat list so the user can still see what
    // happened. Without this branch the card body is empty (the
    // "black bar" the user reported on a vibe-iterate run that
    // bypassed the orchestrator wirer).
    const flatSteps = groupEventsIntoSteps(events, maxStepId, runTerminalAtMs);
    return (
      <Card data-testid="run-hierarchy-pipeline">
        <CardContent className="pt-4 space-y-2 max-h-[calc(100vh-20rem)] overflow-y-auto">
          {flatSteps.map((step, i) => (
            <PhaseStepRow
              key={step.name}
              step={step}
              isLast={i === flatSteps.length - 1}
              maxStepId={maxStepId}
              nowMs={nowMs}
            />
          ))}
        </CardContent>
      </Card>
    );
  }

  return (
    <Card data-testid="run-hierarchy-pipeline">
      <CardContent className="pt-4 space-y-2 max-h-[calc(100vh-20rem)] overflow-y-auto">
        {sortedOps.map((op) => {
          const phaseEvents = eventsByPhase.get(op.id) ?? [];
          const phaseSteps = groupEventsIntoSteps(phaseEvents, maxStepId, runTerminalAtMs);
          const vibeSession = extractVibeSessionBrackets(phaseEvents);
          return (
            <PhaseRow
              key={op.id}
              op={op}
              steps={phaseSteps}
              vibeSession={vibeSession}
              maxStepId={maxStepId}
              nowMs={nowMs}
            />
          );
        })}
      </CardContent>
    </Card>
  );
}

/**
 * Top-level export. Fetches RunOperations then delegates to the suspense-based
 * inner component for progress events.
 */
export function RunHierarchyPipeline({
  businessId,
  runId,
  status = null,
  progressPercent = 0,
  runTerminalAtMs = null,
}: {
  businessId: string;
  runId: string;
  status?: RunStatus | null;
  progressPercent?: number;
  runTerminalAtMs?: number | null;
}) {
  const { data, isLoading } = useListRunOperations({
    params: { business_id: businessId, run_id: runId },
    query: {
      refetchInterval: (query) => {
        const raw = query.state.data?.data;
        const rows: RunOperationOut[] = Array.isArray(raw) ? raw : [];
        if (rows.length === 0) return false;
        const stillRunning = rows.some((r) =>
          ["pending", "running"].includes(r.status),
        );
        return stillRunning ? 4_000 : false;
      },
    },
  });

  const operations: RunOperationOut[] = Array.isArray(data?.data) ? data!.data : [];

  if (isLoading) {
    return (
      <Card>
        <CardContent className="py-8 text-center text-muted-foreground">
          <Loader2 className="w-5 h-5 animate-spin mx-auto mb-2 text-primary" />
          Loading pipeline…
        </CardContent>
      </Card>
    );
  }

  return (
    <RunHierarchyPipelineInner
      businessId={businessId}
      runId={runId}
      status={status}
      progressPercent={progressPercent}
      runTerminalAtMs={runTerminalAtMs}
      operations={operations}
    />
  );
}
