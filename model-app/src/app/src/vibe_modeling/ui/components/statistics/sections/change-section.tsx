import { ArrowUp, ArrowDown, Minus } from "lucide-react";
import { Sparkline } from "../sparkline";
import { useEvolutionMetrics } from "../use-stats-data";
import type { StatsScope } from "../use-stats-data";
import type { VersionHistoryEntryOut } from "@/lib/api";

/** A signed delta chip; `goodUp` decides which direction is "good" (green). */
function Delta({
  value,
  goodUp = true,
}: {
  value: number | null | undefined;
  goodUp?: boolean;
}) {
  if (value == null || value === 0) {
    return (
      <span className="inline-flex items-center gap-0.5 text-xs text-muted-foreground tabular-nums">
        <Minus className="h-3 w-3" />0
      </span>
    );
  }
  const up = value > 0;
  const good = up === goodUp;
  const Icon = up ? ArrowUp : ArrowDown;
  return (
    <span
      className={`inline-flex items-center gap-0.5 text-xs tabular-nums ${good ? "text-success" : "text-destructive"}`}
    >
      <Icon className="h-3 w-3" />
      {Math.abs(value)}
    </span>
  );
}

interface Series {
  key: string;
  label: string;
  /** token class for the sparkline stroke */
  color: string;
  goodUp: boolean;
  pick: (h: VersionHistoryEntryOut) => number | null | undefined;
}

/** The Evolution series, in the documented order. */
const SERIES: Series[] = [
  { key: "confidence", label: "Confidence", color: "text-chart-2", goodUp: true, pick: (h) => h.confidence },
  { key: "errors", label: "Errors", color: "text-destructive", goodUp: false, pick: (h) => h.errors },
  { key: "warnings", label: "Warnings", color: "text-warning", goodUp: false, pick: (h) => h.warnings },
  { key: "products", label: "Products", color: "text-chart-5", goodUp: true, pick: (h) => h.products },
  { key: "fks", label: "Foreign keys", color: "text-chart-5", goodUp: true, pick: (h) => h.fks },
];

/**
 * Change vs predecessor (model). Left: confidence/errors deltas headline.
 * Right: the Evolution small-multiples — one sparkline per series over the
 * `version_history`, with the latest value + signed delta.
 *
 * Confidence is dropped from Evolution on ECM (!hasConfidence). The whole
 * section only renders when `hasPredecessor` — the parent collapses it to a
 * base-version note otherwise.
 */
export function ChangeModelBody({
  scope,
  hasConfidence,
}: {
  scope: StatsScope;
  hasConfidence: boolean;
}) {
  const evo = useEvolutionMetrics(scope);
  const change = evo.change ?? {};
  const history = change.version_history ?? [];

  const series = SERIES.filter(
    (s) => hasConfidence || s.key !== "confidence",
  );

  return (
    <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
      {/* Headline deltas vs predecessor. */}
      <div className="space-y-2">
        <div className="text-xs uppercase tracking-wide text-muted-foreground">
          vs predecessor
        </div>
        {hasConfidence && (
          <div className="flex items-center justify-between border-b border-border pb-2 text-sm">
            <span>Confidence</span>
            <Delta value={change.confidence_delta} goodUp />
          </div>
        )}
        <div className="flex items-center justify-between border-b border-border pb-2 text-sm">
          <span>Errors</span>
          <Delta value={change.errors_delta} goodUp={false} />
        </div>
        <div className="flex items-center justify-between border-b border-border pb-2 text-sm">
          <span>Warnings</span>
          <Delta value={change.warnings_delta} goodUp={false} />
        </div>
        <div className="flex items-center justify-between text-sm">
          <span>Unlinked ids</span>
          <Delta value={change.unlinked_delta} goodUp={false} />
        </div>
      </div>

      {/* Evolution small-multiples. */}
      <div>
        <div className="mb-2 text-xs uppercase tracking-wide text-muted-foreground">
          Evolution · latest + Δ
        </div>
        {history.length < 2 ? (
          <p className="text-sm text-muted-foreground">
            Not enough version history for trends yet.
          </p>
        ) : (
          <ul className="space-y-1.5" data-testid="evolution-sparklines">
            {series.map((s) => {
              const vals = history
                .map((h) => s.pick(h))
                .filter((v): v is number => v != null);
              const latest = vals[vals.length - 1];
              const prev = vals.length > 1 ? vals[vals.length - 2] : undefined;
              const delta = latest != null && prev != null ? latest - prev : null;
              return (
                <li
                  key={s.key}
                  data-testid={`evolution-row-${s.key}`}
                  className="flex items-center gap-2 text-sm"
                >
                  <span className="w-24 shrink-0 text-muted-foreground">
                    {s.label}
                  </span>
                  <Sparkline
                    values={vals}
                    className={s.color}
                    label={`${s.label} over versions`}
                  />
                  <span className="ml-auto w-10 text-right tabular-nums">
                    {latest ?? "—"}
                  </span>
                  <span className="w-10 text-right">
                    <Delta value={delta} goodUp={s.goodUp} />
                  </span>
                </li>
              );
            })}
          </ul>
        )}
      </div>
    </div>
  );
}

/**
 * Change (domain) — scoped delta summary. The per-domain change endpoints are
 * not exposed separately; we surface the model-level progression context plus
 * the domain's change status from the scope tree (passed by the parent).
 */
export function ChangeDomainBody({
  scope,
  domain,
}: {
  scope: StatsScope;
  domain: string;
}) {
  const evo = useEvolutionMetrics(scope);
  const trend = evo.change?.version_trend;
  return (
    <div className="space-y-2 text-sm">
      <p className="text-muted-foreground">
        Change for <span className="font-mono">{domain}</span> within this
        version{trend ? ` — model trend: ${trend}` : ""}.
      </p>
      <p className="text-xs text-muted-foreground">
        See the Domain breakdown above for per-product change badges.
      </p>
    </div>
  );
}
