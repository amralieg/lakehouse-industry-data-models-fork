import type { ReactNode } from "react";
import { Link } from "@tanstack/react-router";
import {
  GitBranch,
  Gauge,
  CheckCircle2,
  Database,
  ArrowUpRight,
  TrendingUp,
  TrendingDown,
} from "lucide-react";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import {
  UNCOMPUTABLE,
  ABSENT_METRIC,
  confidenceDeltaTone,
  type OverviewMetrics,
  type SparkPoint,
} from "./metrics";

/**
 * The overview metrics band — Direction A ("insight strip", the design's
 * default): a single dense 4-cell scoreboard, one hero metric + 1–2 supporting
 * figures per area. Hairline dividers between cells come from a `--border`
 * background showing through 1px grid gaps.
 *
 * The cells render real values for everything the evolution (T16) and
 * next-vibe (T13) endpoints provide: confidence + delta + a version sparkline,
 * open-issue severity split, the next_vibes Quality Score, the Δ-open-issues
 * figure, the `% of model touched` (evolution per-product diff), and the
 * tokens/hours effort. The remaining absent figures (em-dash) are gated by the
 * data-driven flags
 * (ECM has no confidence; a base version has no predecessor → no
 * sparkline/deltas/touched-%).
 *
 * Design-of-record: docs/design/model-overview/README.md.
 */
export function MetricsBand({
  metrics,
  businessId,
  version,
  scope,
}: {
  metrics: OverviewMetrics;
  businessId: string;
  version: string;
  scope: string;
}) {
  return (
    <div
      data-testid="overview-metrics-band"
      className="grid grid-cols-1 gap-px overflow-hidden rounded-md border border-border bg-border sm:grid-cols-2 xl:grid-cols-4"
    >
      <ChangeCell metrics={metrics} />
      <QualityCell
        metrics={metrics}
        businessId={businessId}
        version={version}
        scope={scope}
      />
      <ReviewCell
        metrics={metrics}
        businessId={businessId}
        version={version}
        scope={scope}
      />
      <SizeEffortCell metrics={metrics} />
    </div>
  );
}

function Cell({
  testid,
  icon,
  label,
  children,
}: {
  testid: string;
  icon: ReactNode;
  label: string;
  children: ReactNode;
}) {
  return (
    <div
      data-testid={testid}
      className="flex flex-col gap-2 bg-card px-4 py-3"
    >
      <div className="flex items-center gap-1.5 whitespace-nowrap text-xs font-medium uppercase tracking-wide text-muted-foreground">
        {icon}
        <span>{label}</span>
      </div>
      {children}
    </div>
  );
}

/** Hero value + optional unit, baseline-aligned. */
function Hero({
  value,
  unit,
  trailing,
}: {
  value: ReactNode;
  unit?: ReactNode;
  trailing?: ReactNode;
}) {
  return (
    <div className="flex items-baseline gap-1.5">
      <span className="text-2xl font-semibold tracking-tight">{value}</span>
      {unit && <span className="text-sm text-muted-foreground">{unit}</span>}
      {trailing}
    </div>
  );
}

/** Small placeholder for an uncomputable figure: the Statistics tab's clean
 *  em-dash, with a reason on hover so the absence is never mysterious. */
function Unknown({ reason }: { reason: string }) {
  return (
    <TooltipProvider delayDuration={200}>
      <Tooltip>
        <TooltipTrigger asChild>
          <span
            data-testid="metric-unknown"
            className="cursor-help text-muted-foreground"
          >
            {ABSENT_METRIC}
          </span>
        </TooltipTrigger>
        <TooltipContent>
          <p className="max-w-56 text-xs">{reason}</p>
        </TooltipContent>
      </Tooltip>
    </TooltipProvider>
  );
}

/**
 * Signed delta chip with a trending-up/down icon. Colour comes from `rule`:
 *   - "confidence": the design's ±5-point rule (green > +5, red < −5, else
 *     muted) — used for the confidence delta where small jitter is noise.
 *   - "issues": coloured by sign, where DOWN is the improvement (fewer issues
 *     → green, more → red) — no deadband, every change is signal.
 */
function DeltaChip({
  delta,
  suffix,
  rule = "confidence",
}: {
  delta: number;
  suffix?: string;
  rule?: "confidence" | "issues";
}) {
  let effective: "good" | "bad" | "flat";
  if (rule === "confidence") {
    effective = confidenceDeltaTone(delta);
  } else {
    effective = delta < 0 ? "good" : delta > 0 ? "bad" : "flat";
  }
  const color =
    effective === "good"
      ? "text-success"
      : effective === "bad"
        ? "text-destructive"
        : "text-muted-foreground";
  const sign = delta > 0 ? "+" : delta < 0 ? "−" : "±";
  const magnitude = Math.abs(delta);
  const Icon = delta > 0 ? TrendingUp : delta < 0 ? TrendingDown : null;
  return (
    <span
      data-testid="metric-delta"
      className={`inline-flex items-center gap-0.5 text-xs font-medium ${color}`}
    >
      {Icon && <Icon className="h-3 w-3" />}
      {sign}
      {magnitude}
      {suffix}
    </span>
  );
}

/**
 * Confidence sparkline — SVG polyline + faint area fill + end dot, plotted
 * oldest → newest over the version_history confidence values (design
 * "Sparkline" primitive). Flat across a single distinct value still renders a
 * mid-height line so the cell isn't visually empty.
 */
function Sparkline({
  points,
  width = 120,
  height = 36,
}: {
  points: SparkPoint[];
  width?: number;
  height?: number;
}) {
  const pad = 3;
  const values = points.map((p) => p.value);
  const min = Math.min(...values);
  const max = Math.max(...values);
  const span = max - min || 1;
  const innerW = width - pad * 2;
  const innerH = height - pad * 2;
  const coords = points.map((p, i) => {
    const x =
      points.length === 1
        ? pad + innerW / 2
        : pad + (i / (points.length - 1)) * innerW;
    const y = pad + innerH - ((p.value - min) / span) * innerH;
    return { x, y };
  });
  const line = coords.map((c) => `${c.x},${c.y}`).join(" ");
  const area = `${pad},${height - pad} ${line} ${width - pad},${height - pad}`;
  const last = coords[coords.length - 1];
  const title = points.map((p) => `${p.label}: ${p.value}`).join("  ·  ");
  return (
    <svg
      data-testid="quality-sparkline"
      width={width}
      height={height}
      viewBox={`0 0 ${width} ${height}`}
      role="img"
      aria-label={`Confidence over versions: ${title}`}
      className="overflow-visible"
    >
      <title>{title}</title>
      <polygon points={area} className="fill-[var(--chart-2)]/15" />
      <polyline
        points={line}
        fill="none"
        className="stroke-[var(--chart-2)]"
        strokeWidth={1.5}
        strokeLinejoin="round"
        strokeLinecap="round"
      />
      <circle cx={last.x} cy={last.y} r={2.5} className="fill-[var(--chart-2)]" />
    </svg>
  );
}

function ActionLink({
  to,
  params,
  search,
  children,
}: {
  to: string;
  params: Record<string, string>;
  search: Record<string, string>;
  children: ReactNode;
}) {
  return (
    <Link
      // The route paths are typed; the band is generic so we widen here.
      to={to as never}
      params={params as never}
      search={search as never}
      className="inline-flex items-center gap-0.5 text-xs font-medium text-primary hover:underline"
    >
      {children}
      <ArrowUpRight className="h-3 w-3" />
    </Link>
  );
}

function ChangeCell({ metrics }: { metrics: OverviewMetrics }) {
  const c = metrics.change;
  return (
    <Cell
      testid="metric-change"
      icon={<GitBranch className="h-3.5 w-3.5" />}
      label="Change"
    >
      {c.hasPredecessor ? (
        <>
          <Hero
            value={
              c.pctTouched === UNCOMPUTABLE ? (
                <Unknown reason="% of model touched wasn't recorded for this version (metadata-less import or base version with no predecessor to diff against)." />
              ) : (
                `${c.pctTouched}%`
              )
            }
            unit="touched"
          />
          {c.productBreakdown && (
            <p
              data-testid="metric-change-product-breakdown"
              className="text-xs text-muted-foreground"
              title="Products added · modified · removed vs the previous version"
            >
              {`+${c.productBreakdown.added} · ~${c.productBreakdown.modified} · −${c.productBreakdown.removed}`}
            </p>
          )}
          {/* The per-domain +A·~M·−R breakdown comes from a different source
              (per-domain change_status) than `% touched` (evolution per-product
              diff). When touched is uncomputable, suppress this line too so a
              concrete change count doesn't sit beside an uncomputable em-dash
              (finding #5). */}
          {c.pctTouched !== UNCOMPUTABLE && (
            <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-muted-foreground">
              <span className="text-success">+{c.domainsAdded} added</span>
              <span className="text-warning">~{c.domainsChanged} changed</span>
              <span className="text-destructive">−{c.domainsRemoved} removed</span>
              <span className="text-muted-foreground/80">domains</span>
            </div>
          )}
          <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
            <span>Δ open issues vs prev:</span>
            {c.issueDelta === UNCOMPUTABLE ? (
              <Unknown reason="No predecessor issue counts to diff against." />
            ) : c.issueDelta === 0 ? (
              <span className="font-medium">±0</span>
            ) : (
              <DeltaChip delta={c.issueDelta} rule="issues" />
            )}
          </div>
        </>
      ) : (
        <>
          <Hero value="Base version" />
          <p className="text-xs text-muted-foreground">
            No predecessor to compare against — change metrics start from v2.
          </p>
        </>
      )}
    </Cell>
  );
}

function QualityCell({
  metrics,
  businessId,
  version,
  scope,
}: {
  metrics: OverviewMetrics;
  businessId: string;
  version: string;
  scope: string;
}) {
  const q = metrics.quality;
  return (
    <Cell
      testid="metric-quality"
      icon={<Gauge className="h-3.5 w-3.5" />}
      label="Quality"
    >
      {q.confidence === UNCOMPUTABLE ? (
        <>
          <Hero
            value={<Unknown reason="ECM versions carry no confidence score; the agent only scores MVM after architect review." />}
          />
          <p className="text-xs text-muted-foreground">Confidence not scored</p>
        </>
      ) : (
        <>
          <Hero
            value={q.confidence}
            unit="/ 100 confidence"
            trailing={
              q.confidenceDelta !== null ? (
                <DeltaChip delta={q.confidenceDelta} />
              ) : undefined
            }
          />
          {q.history.length >= 2 && <Sparkline points={q.history} />}
        </>
      )}

      <div className="flex items-center gap-2 text-xs text-muted-foreground">
        {q.openIssues === UNCOMPUTABLE ? (
          <span>
            Open issues:{" "}
            <Unknown reason="Open-issue counts come from the agent's quality scoring, which ECM versions don't carry." />
          </span>
        ) : (
          <span data-testid="quality-open-issues">
            <strong className="text-foreground">{q.openIssues}</strong> open
            {q.severity && (
              <span className="ml-1 text-muted-foreground/80">
                ({q.severity.high} high · {q.severity.medium} med ·{" "}
                {q.severity.low} low)
              </span>
            )}
          </span>
        )}
      </div>

      {q.qualityScore !== null && (
        <div
          className="text-xs text-muted-foreground"
          data-testid="quality-next-vibes-score"
        >
          Next-vibe Quality Score:{" "}
          <strong className="text-foreground">{q.qualityScore}</strong>/100
        </div>
      )}

      <ActionLink
        to="/businesses/$businessId/model/$version/$scope"
        params={{ businessId, version, scope }}
        search={{ tab: "feedback" }}
      >
        View issues
      </ActionLink>
    </Cell>
  );
}

function ReviewCell({
  metrics,
  businessId,
  version,
  scope,
}: {
  metrics: OverviewMetrics;
  businessId: string;
  version: string;
  scope: string;
}) {
  const r = metrics.review;
  return (
    <Cell
      testid="metric-review"
      icon={<CheckCircle2 className="h-3.5 w-3.5" />}
      label="Review progress"
    >
      <Hero value={`${r.pct}%`} unit="reviewed" />
      <div
        className="h-1.5 w-full overflow-hidden rounded-full bg-muted"
        role="progressbar"
        aria-valuenow={r.pct}
        aria-valuemin={0}
        aria-valuemax={100}
      >
        <div
          className="h-full rounded-full bg-primary transition-all"
          style={{ width: `${Math.min(100, Math.max(0, r.pct))}%` }}
        />
      </div>
      <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-muted-foreground">
        <span>
          <strong className="text-foreground">{r.reviewed}</strong>/
          {r.reviewNeeded} products
        </span>
        <span>
          <strong className="text-foreground">{r.feedbackCount}</strong> feedback
        </span>
      </div>
      <ActionLink
        to="/businesses/$businessId/model/$version/$scope"
        params={{ businessId, version, scope }}
        search={{ tab: "feedback" }}
      >
        {r.pct >= 100 ? "Review complete" : "Resume review"}
      </ActionLink>
    </Cell>
  );
}

function SizeEffortCell({ metrics }: { metrics: OverviewMetrics }) {
  const s = metrics.sizeEffort;
  return (
    <Cell
      testid="metric-size-effort"
      icon={<Database className="h-3.5 w-3.5" />}
      label="Size + effort"
    >
      <div className="flex items-end gap-4">
        <Stat value={s.domains} label="domains" />
        <Stat value={s.subdomains} label="subdomains" />
        <Stat value={s.products} label="products" />
      </div>
      <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-muted-foreground">
        <span>
          <strong className="text-foreground">{s.columns.toLocaleString()}</strong>{" "}
          columns
        </span>
        <span>
          <strong className="text-foreground">{s.foreignKeys.toLocaleString()}</strong>{" "}
          FKs
        </span>
      </div>
      <div className="flex flex-wrap items-center gap-x-3 gap-y-1 border-t border-border pt-2 text-xs text-muted-foreground">
        <span>
          Tokens:{" "}
          {s.tokens === UNCOMPUTABLE ? (
            <Unknown reason="Token spend wasn't recorded for this version (metadata-less import or pre-metrics run)." />
          ) : (
            <strong className="text-foreground">{formatTokens(s.tokens)}</strong>
          )}
        </span>
        <span>
          Hours:{" "}
          {s.processingHours === UNCOMPUTABLE ? (
            <Unknown reason="Processing time wasn't recorded for this version." />
          ) : (
            <strong className="text-foreground">{formatHours(s.processingHours)}</strong>
          )}
        </span>
        <span>
          <strong className="text-foreground">{s.runs}</strong> runs
        </span>
      </div>
    </Cell>
  );
}

/** Compact token count: 1_500_000 → "1.5M", 12_000 → "12K". */
function formatTokens(t: number): string {
  if (t >= 1_000_000) return `${(t / 1_000_000).toFixed(1)}M`;
  if (t >= 1_000) return `${(t / 1_000).toFixed(1)}K`;
  return t.toLocaleString();
}

/** Hours with one decimal, or minutes when under an hour. */
function formatHours(h: number): string {
  if (h < 1) return `${Math.round(h * 60)}m`;
  return `${h.toFixed(1)}h`;
}

function Stat({ value, label }: { value: number; label: string }) {
  return (
    <div className="flex flex-col">
      <span className="text-lg font-semibold leading-none">
        {value.toLocaleString()}
      </span>
      <span className="text-[11px] text-muted-foreground">{label}</span>
    </div>
  );
}
