import { NoData } from "../no-data";
import {
  useNextVibeMetrics,
  useEvolutionMetrics,
  useDomainNextVibeMetrics,
  confidenceTo100,
} from "../use-stats-data";
import type { StatsScope } from "../use-stats-data";
import type { DegradationFlags } from "../area-section";

/** Thresholded hue for the next_vibes Quality Score: ≥75 success / ≥50 warning / else destructive. */
function scoreClass(score: number): string {
  if (score >= 75) return "text-success";
  if (score >= 50) return "text-warning";
  return "text-destructive";
}

/** A small score meter bar, hue matched to the score band. No new colors. */
function ScoreMeter({ value }: { value: number }) {
  const hue =
    value >= 75 ? "bg-success" : value >= 50 ? "bg-warning" : "bg-destructive";
  return (
    <div className="h-1.5 w-full overflow-hidden rounded-full bg-muted">
      <div
        className={`h-full rounded-full ${hue}`}
        style={{ width: `${Math.max(0, Math.min(100, value))}%` }}
      />
    </div>
  );
}

/**
 * Quality (model) — Model confidence · Quality Score · Issues.
 *
 * - Quality Score + open-input counts come from `getNextVibeMetrics` (T13).
 * - Confidence + issue counts (errors/warnings) come from `getEvolutionMetrics`
 *   (T16) → `quality`. Confidence degrades to NoData on ECM (!hasConfidence).
 */
export function QualityModelBody({
  scope,
  flags,
}: {
  scope: StatsScope;
  flags: DegradationFlags;
}) {
  const nv = useNextVibeMetrics(scope);
  const evo = useEvolutionMetrics(scope);
  const q = evo.quality ?? {};

  const qualityScore = nv.quality_score;
  const hasQuality = nv.has_data && qualityScore != null;
  const errors = q.error_count ?? 0;
  const warnings = q.warning_count ?? 0;
  const addressed = q.issues_addressed?.length ?? 0;
  const notAddressed = q.issues_not_addressed?.length ?? 0;
  const issuesTotal = addressed + notAddressed;

  return (
    <div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
      {/* Model confidence */}
      <div className="rounded-md bg-muted p-3">
        <div className="text-xs font-medium text-muted-foreground">
          Model confidence
        </div>
        {flags.hasConfidence ? (
          q.confidence_score != null ? (
            <div className="mt-1 text-2xl font-bold tabular-nums">
              {confidenceTo100(q.confidence_score)}
              <span className="text-sm font-normal text-muted-foreground">
                /100
              </span>
            </div>
          ) : (
            <div className="mt-1">
              <NoData reason="No confidence score on this version" />
            </div>
          )
        ) : (
          <div className="mt-1">
            <NoData reason="ECM models have no confidence score" />
          </div>
        )}
        <div className="mt-1 text-xs text-muted-foreground">
          black-box score · one per version
        </div>
      </div>

      {/* Quality score (next_vibes) */}
      <div className="rounded-md bg-muted p-3">
        <div className="text-xs font-medium text-muted-foreground">
          Quality score
        </div>
        {hasQuality ? (
          <>
            <div
              className={`mt-1 text-2xl font-bold tabular-nums ${scoreClass(qualityScore!)}`}
            >
              {Math.round(qualityScore!)}
              <span className="text-sm font-normal text-muted-foreground">
                /100
              </span>
            </div>
            <div className="mt-1.5">
              <ScoreMeter value={qualityScore!} />
            </div>
          </>
        ) : (
          <div className="mt-1">
            <NoData reason="No static analysis for this version" />
          </div>
        )}
        <div className="mt-1 text-xs text-muted-foreground">
          static analysis of what was generated
        </div>
      </div>

      {/* Issues */}
      <div className="rounded-md bg-muted p-3">
        <div className="text-xs font-medium text-muted-foreground">Issues</div>
        <div className="mt-1 flex items-baseline gap-3">
          <span className="text-xl font-bold tabular-nums text-destructive">
            {errors}
          </span>
          <span className="text-xs text-muted-foreground">errors</span>
          <span className="text-xl font-bold tabular-nums text-warning">
            {warnings}
          </span>
          <span className="text-xs text-muted-foreground">warnings</span>
        </div>
        {issuesTotal > 0 && (
          <>
            <div className="mt-2 flex h-1.5 w-full overflow-hidden rounded-full bg-muted-foreground/20">
              <div
                className="h-full bg-success"
                style={{ width: `${(addressed / issuesTotal) * 100}%` }}
              />
            </div>
            <div className="mt-1 text-xs text-muted-foreground">
              {addressed} addressed · {notAddressed} not yet
            </div>
          </>
        )}
      </div>
    </div>
  );
}

/**
 * Quality (domain) — open next_vibes inputs (the domain's quality signal) +
 * a structural-soundness line (unlinked ids · siloed) + model confidence as
 * muted context only.
 */
export function QualityDomainBody({
  scope,
  domain,
  flags,
}: {
  scope: StatsScope;
  domain: string;
  flags: DegradationFlags;
}) {
  const dnv = useDomainNextVibeMetrics(scope, domain);
  const evo = useEvolutionMetrics(scope);
  const size = evo.size ?? {};
  const q = evo.quality ?? {};

  const open = dnv.total_open ?? 0;
  const unlinked = size.unlinked_id_count ?? 0;
  const siloed = size.siloed_count ?? 0;

  return (
    <div className="space-y-3">
      <div>
        <div className="flex items-baseline gap-2">
          <span
            className={`text-2xl font-bold tabular-nums ${open >= 8 ? "text-destructive" : open > 0 ? "text-warning" : "text-success"}`}
          >
            {open}
          </span>
          <span className="text-sm text-muted-foreground">
            {open === 0 ? "clean — no open inputs" : "open inputs"}
          </span>
        </div>
        <div className="mt-0.5 text-xs text-muted-foreground">
          the domain's quality signal — count of inputs attributed here
        </div>
      </div>

      {/* Structural soundness (Data Modeler lens) — model-level structural counts. */}
      <div className="text-sm">
        {unlinked === 0 && siloed === 0 ? (
          <span className="text-success">No unlinked ids or siloed products</span>
        ) : (
          <span className={unlinked > 0 || siloed > 0 ? "text-warning" : ""}>
            {unlinked} unlinked {unlinked === 1 ? "id" : "ids"} · {siloed} siloed
          </span>
        )}
        <span className="ml-1 text-xs text-muted-foreground">
          (structural soundness · model-level)
        </span>
      </div>

      {/* Model confidence as muted context only (never a per-domain number). */}
      <div className="flex items-center gap-2 text-xs text-muted-foreground">
        <span>Model confidence (model-level):</span>
        {flags.hasConfidence && q.confidence_score != null ? (
          <span className="tabular-nums">{confidenceTo100(q.confidence_score)}/100</span>
        ) : (
          <NoData reason="ECM models have no confidence score" />
        )}
      </div>
    </div>
  );
}
