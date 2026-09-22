import { useMemo, useState } from "react";
import { Link } from "@tanstack/react-router";
import {
  ChevronDown,
  ChevronRight,
  CheckCircle2,
  Circle,
  Slash,
  Filter,
} from "lucide-react";
import {
  ReviewState,
  useListProductReviewsSuspense,
} from "@/lib/api";
import type {
  ChangeStatus,
  DomainDetailOut,
  DomainSummaryOut,
  ProductReviewOut,
  ProductSummaryOut,
} from "@/lib/api";
import { selector } from "@/lib/selector";
import { changeTextToneClass } from "@/lib/change-status";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  ReviewStateControl,
  type ReviewTarget,
} from "@/components/review/review-state-control";
import { useDomainDetail } from "../use-stats-data";
import type { StatsScope } from "../use-stats-data";

/**
 * Computed (read-only) fallback review state for a named product the review
 * list doesn't cover (e.g. a deleted-product placeholder with no DB row).
 * Mirrors the backend default rule (ADR D-044): an unchanged product with no
 * open issues needs no review; everything else needs review. The authoritative
 * effective state, when available, comes from `listProductReviews` keyed by the
 * product UUID — so a marked product shows its real state, not this default.
 */
/**
 * Synthetic bucket label for named products that carry no subdomain. It groups
 * those products in the breakdown UI but is NOT a real subdomain — the
 * "subdomains" count (here and in the Size section) counts NAMED subdomains
 * only, so the two surfaces agree. There's no DB id for this bucket, so it
 * exposes no cascade control.
 */
export const NO_SUBDOMAIN = "(no subdomain)";

function computedChip(
  status: ChangeStatus | undefined,
  hasPredecessor: boolean,
): ReviewState {
  const unchanged = hasPredecessor && (status === "unchanged" || status == null);
  if (unchanged) return ReviewState.no_review_needed;
  return ReviewState.not_reviewed;
}

/**
 * Aggregate review state for a group of products (a subdomain or a whole
 * domain), for the cascade control's button highlight only. "Reviewed" when
 * every product that needs review is reviewed; otherwise "Not reviewed". An
 * empty group reads as not_reviewed. The cascade control treats this as a
 * non-explicit (computed) state, so any choice still opens the confirm dialog.
 */
function aggregateState(items: { state: ReviewState }[]): ReviewState {
  const reviewable = items.filter(
    (p) => p.state !== ReviewState.no_review_needed,
  );
  if (reviewable.length === 0) return ReviewState.not_reviewed;
  return reviewable.every((p) => p.state === ReviewState.reviewed)
    ? ReviewState.reviewed
    : ReviewState.not_reviewed;
}

function ReviewChip({ state }: { state: ReviewState }) {
  if (state === ReviewState.reviewed) {
    return (
      <span className="inline-flex items-center gap-1 text-xs text-success">
        <CheckCircle2 className="h-3.5 w-3.5" />
        Reviewed
      </span>
    );
  }
  if (state === ReviewState.no_review_needed) {
    return (
      <span className="inline-flex items-center gap-1 text-xs text-muted-foreground">
        <Slash className="h-3.5 w-3.5" />
        No review needed
      </span>
    );
  }
  return (
    <span className="inline-flex items-center gap-1 text-xs text-muted-foreground">
      <Circle className="h-3.5 w-3.5 text-primary" />
      Needs review
    </span>
  );
}

function ChangeBadge({ status }: { status?: ChangeStatus }) {
  if (status === "new")
    return (
      <span className={`text-xs ${changeTextToneClass(status)}`}>+ added</span>
    );
  if (status === "modified")
    return (
      <span className={`text-xs ${changeTextToneClass(status)}`}>~ changed</span>
    );
  return <span className="text-xs text-muted-foreground">—</span>;
}

interface BreakdownProduct {
  /** Product UUID (the review write key); "" for placeholders with no DB row. */
  id: string;
  name: string;
  fqn: string;
  subdomain: string;
  status?: ChangeStatus;
  /** Effective review state (folded marks + default). */
  state: ReviewState;
  /** Whether `state` is a stored user mark vs a computed default. */
  isExplicit: boolean;
}

/**
 * Domain breakdown — THE actionable marking surface (T7).
 *
 * One row per named product, grouped by collapsible subdomain (from the domain
 * detail — T11's domain endpoint). Each row carries the product's review chip,
 * change badge, AND its own inline `<ReviewStateControl/>` — the product now
 * exposes its UUID (`ProductSummaryOut.id`) so a named row can mark itself
 * directly. A "Needs review only" filter hides reviewed / no-review-needed rows
 * and the subdomains that empty out.
 *
 * Effective review state comes from `listProductReviews` (UUID → state),
 * joined onto the named products by the product UUID. A product without a
 * review row (placeholder) falls back to the computed default and renders no
 * marking control.
 */
export function DomainBreakdownBody({
  scope,
  domain,
  domainSummary,
  hasPredecessor,
}: {
  scope: StatsScope;
  domain: string;
  /** Model-summary row for this domain — carries the domain DB id, per-subdomain
   *  ids, and product counts the cascade controls key on. Null degrades the
   *  cascade affordances away (product-level marking still works). */
  domainSummary: DomainSummaryOut | null;
  hasPredecessor: boolean;
}) {
  const detail: DomainDetailOut = useDomainDetail(scope, domain);
  const { data: reviews } = useListProductReviewsSuspense({
    params: {
      business_id: scope.businessId,
      version_int: scope.versionInt,
      scope: scope.scope,
    },
    ...selector(),
  });
  const [needsOnly, setNeedsOnly] = useState(false);
  const [collapsed, setCollapsed] = useState<Set<string>>(new Set());

  // Effective review state per product UUID (the authoritative fold of the
  // sparse marks with the computed default; ADR D-044).
  const reviewById = useMemo(() => {
    const m = new Map<string, ProductReviewOut>();
    for (const r of reviews) m.set(r.product_id, r);
    return m;
  }, [reviews]);

  const products: BreakdownProduct[] = useMemo(() => {
    return (detail.products ?? [])
      // Deleted products are reconstructed from the previous version for the
      // change view and have no product row (hence no id) in THIS version, so
      // they can't hold a review. They're not actionable in the review/marking
      // surface — exclude them here (removals are summarized in the Change
      // section; commenting on a removal is domain-level feedback, not a
      // per-product review).
      .filter((p: ProductSummaryOut) => p.change_status !== "deleted")
      .map((p: ProductSummaryOut) => {
      const id = p.id ?? "";
      const review = id ? reviewById.get(id) : undefined;
      const status = p.change_status;
      return {
        id,
        name: p.name,
        fqn: p.fqn ?? "",
        subdomain: p.subdomain || NO_SUBDOMAIN,
        status,
        state: review?.state ?? computedChip(status, hasPredecessor),
        isExplicit: review?.is_explicit ?? false,
      };
    });
  }, [detail.products, reviewById, hasPredecessor]);

  // Group by subdomain.
  const groups = useMemo(() => {
    const m = new Map<string, BreakdownProduct[]>();
    for (const p of products) {
      const list = m.get(p.subdomain) ?? [];
      list.push(p);
      m.set(p.subdomain, list);
    }
    return [...m.entries()].map(([name, items]) => ({ name, items }));
  }, [products]);

  const needFilter = (p: BreakdownProduct) =>
    !needsOnly || p.state === ReviewState.not_reviewed;

  const totalNeed = products.filter(
    (p) => p.state === ReviewState.not_reviewed,
  ).length;

  // Count NAMED subdomains only — the synthetic no-subdomain bucket isn't a
  // subdomain, so it's excluded here to agree with the Size section's count
  // (finding #4). It still renders as a collapsible group below.
  const namedSubdomainCount = groups.filter(
    (g) => g.name !== NO_SUBDOMAIN,
  ).length;

  // Subdomain name → DB id (the cascade write key), from the model-summary row.
  const subdomainIdByName = useMemo(() => {
    const m = new Map<string, string>();
    for (const sd of domainSummary?.subdomains ?? []) {
      if (sd.id) m.set(sd.name, sd.id);
    }
    return m;
  }, [domainSummary]);

  // Domain-level cascade target: marks every product in the domain after the
  // confirm dialog (ADR D-044). Present only when the domain id is known.
  const domainTarget: ReviewTarget | null = domainSummary?.id
    ? {
        level: "domain",
        id: domainSummary.id,
        name: domain,
        businessId: scope.businessId,
        versionInt: scope.versionInt,
        scope: scope.scope,
      }
    : null;
  const domainState = aggregateState(products);

  function toggleGroup(name: string) {
    setCollapsed((prev) => {
      const next = new Set(prev);
      if (next.has(name)) next.delete(name);
      else next.add(name);
      return next;
    });
  }

  return (
    <div className="space-y-4">
      {/* Toolbar — visually aligned with the app-wide FiltersBar pattern:
          border-b separator + gap-2 between controls. */}
      <div className="flex flex-wrap items-center gap-2 border-b border-border pb-3 mb-3 text-xs text-muted-foreground">
        <span>
          {products.length} products · {namedSubdomainCount} subdomains ·{" "}
          {totalNeed} need review
        </span>
        <div className="ml-auto flex items-center gap-2">
          {/* Domain-level cascade — marks every product in the domain via the
              confirm dialog. */}
          {domainTarget && (
            <span data-testid="breakdown-domain-cascade">
              <ReviewStateControl
                target={domainTarget}
                state={domainState}
                isExplicit={false}
                cascadeCount={products.length}
              />
            </span>
          )}
          <Button
            type="button"
            size="sm"
            variant={needsOnly ? "default" : "outline"}
            className="h-7"
            aria-pressed={needsOnly}
            onClick={() => setNeedsOnly((v) => !v)}
          >
            <Filter className="mr-1 h-3.5 w-3.5" />
            Needs review only
          </Button>
        </div>
      </div>

      {/* Grouped product rows — each row is its own marking surface. */}
      <div className="space-y-2" data-testid="breakdown-groups">
        {groups.map((g) => {
          const visible = g.items.filter(needFilter);
          if (visible.length === 0) return null;
          const open = !collapsed.has(g.name);
          // Subdomain-level cascade — only for NAMED subdomains with a known DB
          // id (the no-subdomain bucket has no id, so no cascade there).
          const sdId = subdomainIdByName.get(g.name);
          const subdomainTarget: ReviewTarget | null = sdId
            ? {
                level: "subdomain",
                id: sdId,
                name: g.name,
                businessId: scope.businessId,
                versionInt: scope.versionInt,
                scope: scope.scope,
              }
            : null;
          return (
            <div
              key={g.name}
              data-testid={`breakdown-subdomain-${g.name}`}
              className="overflow-hidden rounded-md border border-border"
            >
              <div
                data-testid={`breakdown-subdomain-header-${g.name}`}
                className="flex w-full items-center gap-2 bg-muted px-3 py-1.5 text-sm"
              >
                <button
                  type="button"
                  onClick={() => toggleGroup(g.name)}
                  className="flex flex-1 items-center gap-2 text-left hover:underline"
                >
                  {open ? (
                    <ChevronDown className="h-3.5 w-3.5" />
                  ) : (
                    <ChevronRight className="h-3.5 w-3.5" />
                  )}
                  <span className="font-mono text-[13px]">{g.name}</span>
                  <Badge variant="outline" className="text-xs font-normal">
                    {g.items.length}
                  </Badge>
                </button>
                {subdomainTarget && (
                  <ReviewStateControl
                    target={subdomainTarget}
                    state={aggregateState(g.items)}
                    isExplicit={false}
                    cascadeCount={g.items.length}
                  />
                )}
              </div>
              {open && (
                <ul className="divide-y divide-border">
                  {visible.map((p) => {
                    const target: ReviewTarget | null = p.id
                      ? {
                          level: "product",
                          id: p.id,
                          name: p.name,
                          businessId: scope.businessId,
                          versionInt: scope.versionInt,
                          scope: scope.scope,
                        }
                      : null;
                    return (
                      <li
                        key={p.id || p.name}
                        data-testid={`breakdown-product-${p.name}`}
                        className="flex flex-wrap items-center gap-x-3 gap-y-2 px-3 py-2"
                      >
                        {p.id ? (
                          <Link
                            to="/businesses/$businessId/model/$version/$scope/$domainName/$productName"
                            params={{
                              businessId: scope.businessId,
                              version: String(scope.versionInt),
                              scope: scope.scope,
                              domainName: domain,
                              productName: p.name,
                            }}
                            className="min-w-0 flex-1 truncate font-mono text-[13px] hover:underline hover:text-primary"
                          >
                            {p.name}
                          </Link>
                        ) : (
                          <span className="min-w-0 flex-1 truncate font-mono text-[13px]">
                            {p.name}
                          </span>
                        )}
                        <span className="flex w-20 items-center justify-end">
                          <ChangeBadge status={p.status} />
                        </span>
                        {target ? (
                          // The segmented control's active (filled) button +
                          // aria-pressed communicates current state — so no
                          // separate status chip (it duplicated the active
                          // button; see F12). The ChangeBadge above is distinct.
                          <ReviewStateControl
                            target={target}
                            state={p.state}
                            isExplicit={p.isExplicit}
                          />
                        ) : (
                          // Idless row (no product id → no control): fall back to
                          // the read-only chip so state is still visible.
                          <ReviewChip state={p.state} />
                        )}
                      </li>
                    );
                  })}
                </ul>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
