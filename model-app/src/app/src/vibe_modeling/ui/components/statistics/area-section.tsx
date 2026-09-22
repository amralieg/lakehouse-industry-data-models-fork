import { Suspense, type ReactNode } from "react";
import { QueryErrorResetBoundary } from "@tanstack/react-query";
import { ErrorBoundary } from "react-error-boundary";
import type { LucideIcon } from "lucide-react";
import { Skeleton } from "@/components/ui/skeleton";

/**
 * Degradation flags derived from the evolution-metrics endpoint, per the
 * design-of-record (docs/design/statistics-tab/README.md → "Graceful
 * degradation"). These drive the data-driven layout: when a value can't be
 * computed we render a quiet `NoData` token and hide the dependent graphic.
 *
 *   hasConfidence  — false for ECM (no confidence score).
 *   hasPredecessor — false for a base/first version (no Change area).
 */
export interface DegradationFlags {
  hasConfidence: boolean;
  hasPredecessor: boolean;
}

/**
 * A bordered area-section card. The lead section (Review) gets a slightly
 * stronger primary-tinted border and a primary eyebrow icon, per the design.
 * An optional right-hand `action` slot hosts a quiet navigation link.
 */
export function AreaSection({
  icon: Icon,
  label,
  lead = false,
  action,
  children,
}: {
  icon: LucideIcon;
  label: string;
  lead?: boolean;
  action?: ReactNode;
  children: ReactNode;
}) {
  return (
    <section
      data-testid={`stats-section-${label.toLowerCase().replace(/[^a-z0-9]+/g, "-")}`}
      className={`rounded-md border bg-card p-4 ${
        lead ? "border-primary/35" : "border-border"
      }`}
    >
      <div className="mb-3 flex items-center gap-1.5">
        <div className="flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wide text-muted-foreground">
          <Icon className={`h-[13px] w-[13px] ${lead ? "text-primary" : ""}`} />
          {label}
        </div>
        {action && <div className="ml-auto">{action}</div>}
      </div>
      {children}
    </section>
  );
}

/**
 * Wraps a data-bound section body in the project's standard
 * QueryErrorResetBoundary + ErrorBoundary + Suspense trio so each section
 * loads and fails independently — a single slow/broken endpoint never blanks
 * the whole report.
 */
export function SectionBoundary({
  label,
  children,
  fallbackHeight = "h-16",
}: {
  label: string;
  children: ReactNode;
  fallbackHeight?: string;
}) {
  return (
    <QueryErrorResetBoundary>
      {({ reset }) => (
        <ErrorBoundary
          onReset={reset}
          fallbackRender={({ resetErrorBoundary }) => (
            <button
              type="button"
              onClick={resetErrorBoundary}
              className="text-xs text-muted-foreground hover:text-foreground hover:underline"
            >
              Couldn't load {label} — retry
            </button>
          )}
        >
          <Suspense fallback={<Skeleton className={`${fallbackHeight} w-full`} />}>
            {children}
          </Suspense>
        </ErrorBoundary>
      )}
    </QueryErrorResetBoundary>
  );
}
