import { useMemo } from "react";
import { Link } from "@tanstack/react-router";
import { useQueries } from "@tanstack/react-query";
import { ArrowUpRight } from "lucide-react";
import {
  getDomainNextVibeMetrics,
  getDomainNextVibeMetricsKey,
} from "@/lib/api";
import type { ChangeStatus } from "@/lib/api";
import { statusDotClass } from "@/lib/change-status";
import { useReviewProgressByDomain, reviewPctTo100 } from "../use-stats-data";
import {
  Table,
  TableBody,
  TableCell,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  SortableTableHead,
  useTableSort,
} from "@/components/ui/sortable-table-head";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { focusScore, focusBlendText } from "../focus-score";
import type { StatsScope } from "../use-stats-data";

export interface FocusDomain {
  name: string;
  change_status?: ChangeStatus;
  productCount: number;
}

interface FocusRow {
  name: string;
  change_status?: ChangeStatus;
  productCount: number;
  /** Open AGENT vibe-run findings (origin=agent_next_vibe), NOT user feedback. */
  openFindings: number;
  /** Reviewed % for the domain (0..100), or null when nothing needs review. */
  reviewedPct: number | null;
  focus: number;
  blend: string;
  reason: string;
}

/** Focus-score color thresholds: ≥70 destructive / ≥45 warning / else muted. */
function focusToneClass(score: number): string {
  if (score >= 70) return "text-destructive";
  if (score >= 45) return "text-warning";
  return "text-muted-foreground";
}

function changeLabel(status: ChangeStatus | undefined, hasPredecessor: boolean) {
  if (!hasPredecessor) return "n/a";
  if (status === "new") return "new";
  if (status === "modified") return "changed";
  return "unchanged";
}

/**
 * "Where to focus" — the ranked TABLE (the decided triage object). Rows are the
 * live domains; default sorted by Focus descending. Clicking a row drills into
 * that domain (selects the tree node + rebinds the report).
 *
 * The Focus score is the T9 composite (`focusScore`); its blend is exposed in a
 * per-row tooltip. The "Changed" column is dropped on a base version
 * (!hasPredecessor), per the degradation rules.
 *
 * The review-gap signal is the real per-domain reviewed ÷ review-needed from
 * `getReviewProgressByDomain`; the "Open findings" column is AGENT vibe-run
 * findings (origin=agent_next_vibe), NOT user review feedback.
 */
export function WhereToFocusBody({
  scope,
  domains,
  hasPredecessor,
  onDrill,
}: {
  scope: StatsScope;
  domains: FocusDomain[];
  hasPredecessor: boolean;
  onDrill: (domain: string) => void;
}) {
  // Fan out per-domain next_vibes metrics in parallel (non-suspense so the
  // table renders immediately; counts fill in as each resolves).
  const results = useQueries({
    queries: domains.map((d) => ({
      queryKey: getDomainNextVibeMetricsKey({
        business_id: scope.businessId,
        version_int: scope.versionInt,
        scope: scope.scope,
        domain_name: d.name,
      }),
      queryFn: () =>
        getDomainNextVibeMetrics({
          business_id: scope.businessId,
          version_int: scope.versionInt,
          scope: scope.scope,
          domain_name: d.name,
        }),
    })),
  });

  // Real per-domain review progress → the reviewGap signal in the focus score.
  const reviewByDomain = useReviewProgressByDomain(scope);

  const rows: FocusRow[] = useMemo(() => {
    return domains.map((d, i) => {
      // total_open = open AGENT vibe-run findings (origin=agent_next_vibe),
      // NOT user review feedback.
      const openFindings = results[i]?.data?.data?.total_open ?? 0;
      const review = reviewByDomain.get(d.name);
      const reviewed = review?.reviewed ?? 0;
      const reviewNeeded = review?.review_needed ?? 0;
      // Same 0..1→0..100 (and null-when-nothing-needs-review) rule as the tree.
      const reviewedPct = reviewPctTo100(review);
      // Change pressure: a coarse 100/50/0 from the change status (we have no
      // per-domain pct-touched figure on the FE).
      const pctChanged = !hasPredecessor
        ? null
        : d.change_status === "new"
          ? 100
          : d.change_status === "modified"
            ? 50
            : 0;
      const { score, parts } = focusScore({
        reviewed,
        reviewNeeded,
        openInputs: openFindings,
        pctChanged,
      });
      const reasonParts = [
        `${openFindings} ${openFindings === 1 ? "finding" : "findings"} open`,
      ];
      if (reviewNeeded > 0) {
        reasonParts.push(`${Math.round(reviewedPct ?? 0)}% reviewed`);
      }
      if (hasPredecessor) {
        reasonParts.push(`${changeLabel(d.change_status, hasPredecessor)}`);
      }
      return {
        name: d.name,
        change_status: d.change_status,
        productCount: d.productCount,
        openFindings,
        reviewedPct,
        focus: score,
        blend: focusBlendText(parts),
        reason: reasonParts.join(" · "),
      };
    });
  }, [domains, results, reviewByDomain, hasPredecessor]);

  const accessors = useMemo(
    () => ({
      domain: (r: FocusRow) => r.name,
      focus: (r: FocusRow) => r.focus,
      findings: (r: FocusRow) => r.openFindings,
      reviewed: (r: FocusRow) => r.reviewedPct ?? -1,
      changed: (r: FocusRow) =>
        r.change_status === "new" ? 2 : r.change_status === "modified" ? 1 : 0,
      products: (r: FocusRow) => r.productCount,
    }),
    [],
  );

  const { sorted, sortKey, sortDir, toggle } = useTableSort<FocusRow>({
    rows,
    accessors,
    initialKey: "focus",
    initialDir: "desc",
  });

  return (
    <Table data-testid="focus-table">
      <TableHeader>
        <TableRow>
          <SortableTableHead
            columnKey="domain"
            sortKey={sortKey}
            sortDir={sortDir}
            onToggle={toggle}
          >
            Domain
          </SortableTableHead>
          <SortableTableHead
            columnKey="focus"
            sortKey={sortKey}
            sortDir={sortDir}
            onToggle={toggle}
          >
            Focus
          </SortableTableHead>
          <SortableTableHead
            columnKey="findings"
            sortKey={sortKey}
            sortDir={sortDir}
            onToggle={toggle}
          >
            Open findings
          </SortableTableHead>
          <SortableTableHead
            columnKey="reviewed"
            sortKey={sortKey}
            sortDir={sortDir}
            onToggle={toggle}
          >
            Reviewed
          </SortableTableHead>
          {hasPredecessor && (
            <SortableTableHead
              columnKey="changed"
              sortKey={sortKey}
              sortDir={sortDir}
              onToggle={toggle}
            >
              Changed
            </SortableTableHead>
          )}
          <SortableTableHead
            columnKey="products"
            sortKey={sortKey}
            sortDir={sortDir}
            onToggle={toggle}
          >
            Products
          </SortableTableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {sorted.map((r) => (
          <TableRow
            key={r.name}
            data-testid={`focus-row-${r.name}`}
            className="group cursor-pointer hover:bg-accent"
            onClick={() => onDrill(r.name)}
          >
            <TableCell>
              <div className="flex items-center gap-2">
                <span
                  aria-hidden
                  className={`h-2 w-2 shrink-0 rounded-full ${statusDotClass(r.change_status)}`}
                />
                <div className="min-w-0">
                  <Link
                    to="/businesses/$businessId/model/$version/$scope/$domainName"
                    params={{
                      businessId: scope.businessId,
                      version: String(scope.versionInt),
                      scope: scope.scope,
                      domainName: r.name,
                    }}
                    search={{ tab: "products" }}
                    className="font-mono text-[13px] hover:underline hover:text-primary"
                    onClick={(e) => e.stopPropagation()}
                  >
                    {r.name}
                  </Link>
                  <div className="truncate text-xs text-muted-foreground">
                    {r.reason}
                  </div>
                </div>
              </div>
            </TableCell>
            <TableCell>
              <TooltipProvider delayDuration={200}>
                <Tooltip>
                  <TooltipTrigger asChild>
                    <span
                      className={`cursor-help tabular-nums font-semibold ${focusToneClass(r.focus)}`}
                    >
                      {r.focus}
                    </span>
                  </TooltipTrigger>
                  <TooltipContent>
                    <p className="text-xs">{r.blend}</p>
                  </TooltipContent>
                </Tooltip>
              </TooltipProvider>
            </TableCell>
            <TableCell>
              <span
                className={`tabular-nums ${r.openFindings >= 8 ? "text-destructive" : r.openFindings === 0 ? "text-muted-foreground" : ""}`}
              >
                {r.openFindings === 0 ? "clean" : `${r.openFindings} open`}
              </span>
            </TableCell>
            <TableCell className="tabular-nums">
              {r.reviewedPct == null ? (
                <span className="text-muted-foreground">—</span>
              ) : (
                <span
                  className={
                    r.reviewedPct >= 100
                      ? "text-success"
                      : r.reviewedPct === 0
                        ? "text-muted-foreground"
                        : ""
                  }
                >
                  {Math.round(r.reviewedPct)}%
                </span>
              )}
            </TableCell>
            {hasPredecessor && (
              <TableCell className="text-sm">
                {changeLabel(r.change_status, hasPredecessor)}
              </TableCell>
            )}
            <TableCell className="tabular-nums">
              <span className="flex items-center gap-1">
                {r.productCount}
                <ArrowUpRight className="h-3.5 w-3.5 text-muted-foreground opacity-0 transition-opacity group-hover:opacity-100 group-hover:text-primary" />
              </span>
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
