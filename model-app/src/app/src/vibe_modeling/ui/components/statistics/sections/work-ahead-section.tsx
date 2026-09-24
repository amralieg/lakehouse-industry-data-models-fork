import { useNextVibeMetrics } from "../use-stats-data";
import type { StatsScope } from "../use-stats-data";

interface Category {
  key: "static_analysis" | "priority_remediation" | "other";
  label: string;
  note: string;
  /** severity tone for the count + pill */
  tone: "destructive" | "warning" | "muted";
  pill: string;
}

/** The agent's next_vibes categories, in the documented order. */
const CATEGORIES: Category[] = [
  {
    key: "priority_remediation",
    label: "Priority remediations",
    note: "must-fix items the agent flagged for the next iteration",
    tone: "destructive",
    pill: "high",
  },
  {
    key: "static_analysis",
    label: "Static-analysis findings",
    note: "issues surfaced by the model's static analysis",
    tone: "warning",
    pill: "warning",
  },
  {
    key: "other",
    label: "Other known issues",
    note: "lower-priority improvements to consider",
    tone: "muted",
    pill: "low",
  },
];

function toneText(tone: Category["tone"]): string {
  if (tone === "destructive") return "text-destructive";
  if (tone === "warning") return "text-warning";
  return "text-muted-foreground";
}

function pillClass(tone: Category["tone"]): string {
  if (tone === "destructive")
    return "border-destructive/40 bg-destructive/10 text-destructive";
  if (tone === "warning") return "border-warning/40 bg-warning/10 text-warning";
  return "border-border bg-muted text-muted-foreground";
}

/**
 * Work ahead — the next_vibes remediation backlog for the next iteration,
 * broken out by the agent's categories. Counts come from `getNextVibeMetrics`
 * (T13) → `counts`.
 */
export function WorkAheadBody({ scope }: { scope: StatsScope }) {
  const nv = useNextVibeMetrics(scope);
  const counts = nv.counts ?? {};
  const total = counts.total ?? nv.total_open ?? 0;

  if (!nv.has_data) {
    return (
      <p className="text-sm text-muted-foreground">
        No suggested next steps for this version.
      </p>
    );
  }

  return (
    <div className="space-y-2">
      <p className="text-xs text-muted-foreground">
        Remediation backlog for the next iteration · {total} total
      </p>
      <ul className="divide-y divide-border rounded-md border border-border">
        {CATEGORIES.map((c) => {
          const count = (counts[c.key] as number | undefined) ?? 0;
          return (
            <li
              key={c.key}
              data-testid={`work-ahead-${c.key}`}
              className="flex items-center gap-3 px-3 py-2.5"
            >
              <span
                className={`w-8 text-xl font-bold tabular-nums ${toneText(c.tone)}`}
              >
                {count}
              </span>
              <div className="min-w-0 flex-1">
                <div className="text-sm font-medium">{c.label}</div>
                <div className="truncate text-xs text-muted-foreground">
                  {c.note}
                </div>
              </div>
              <span
                className={`rounded-full border px-2 py-0.5 text-xs ${pillClass(c.tone)}`}
              >
                {c.pill}
              </span>
            </li>
          );
        })}
      </ul>
    </div>
  );
}
