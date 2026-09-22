import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { Check, Circle } from "lucide-react";
import {
  ReviewState,
  useMarkProductReview,
  useClearProductReview,
  useMarkDomainReview,
  useMarkSubdomainReview,
  getReviewProgressKey,
  getReviewProgressByDomainKey,
  listProductReviewsKey,
} from "@/lib/api";
import { notifyError } from "@/lib/notify";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { CascadeConfirmDialog } from "./cascade-confirm-dialog";
import { reviewStateLabel, reviewStateBadgeClass } from "./review-state-labels";

export type ReviewTargetLevel = "product" | "domain" | "subdomain";

/** Identity of the element being marked, plus the read-context needed to
 *  invalidate the right review queries afterwards. */
export interface ReviewTarget {
  level: ReviewTargetLevel;
  /** DB UUID of the product / domain / subdomain. */
  id: string;
  /** Human name (used in the cascade dialog copy). */
  name?: string;
  businessId: string;
  /** version_int + scope — the natural version key the mark/clear/cascade
   *  endpoints (and the read endpoints we invalidate) all address. */
  versionInt: number;
  scope: string;
}

/**
 * Reusable three-state review control (ADR D-044).
 *
 * - **Product (leaf):** marks directly. "Reviewed" upserts a `reviewed` row;
 *   "Not reviewed" clears any explicit row back to the computed default (or
 *   upserts `not_reviewed` when the default is `no_review_needed`).
 * - **Domain / subdomain:** marking is a CASCADE — it routes through
 *   `<CascadeConfirmDialog/>` and only calls the cascade endpoint after the
 *   user confirms the scope ("this will mark N items").
 *
 * `no_review_needed` is a read-only computed default: it renders as a muted
 * badge, but the user can still override it by choosing a state.
 */
export function ReviewStateControl({
  target,
  state,
  isExplicit = false,
  cascadeCount = 0,
  className,
}: {
  target: ReviewTarget;
  /** Current effective state of the element. */
  state: ReviewState;
  /** Whether `state` is a stored user mark vs a computed default. */
  isExplicit?: boolean;
  /** For domain/subdomain: how many products the cascade will write. */
  cascadeCount?: number;
  className?: string;
}) {
  const queryClient = useQueryClient();
  const [cascade, setCascade] = useState<ReviewState | null>(null);

  const markProduct = useMarkProductReview();
  const clearProduct = useClearProductReview();
  const markDomain = useMarkDomainReview();
  const markSubdomain = useMarkSubdomainReview();

  const isCascadeLevel = target.level !== "product";

  const invalidate = () => {
    queryClient.invalidateQueries({
      queryKey: getReviewProgressKey({
        business_id: target.businessId,
        version_int: target.versionInt,
        scope: target.scope,
      }),
    });
    queryClient.invalidateQueries({
      queryKey: listProductReviewsKey({
        business_id: target.businessId,
        version_int: target.versionInt,
        scope: target.scope,
      }),
    });
    // Per-domain rollup feeds the scope tree % + the focus table review-gap;
    // a mark/cascade changes those, so refresh it too.
    queryClient.invalidateQueries({
      queryKey: getReviewProgressByDomainKey({
        business_id: target.businessId,
        version_int: target.versionInt,
        scope: target.scope,
      }),
    });
  };

  const pending =
    markProduct.isPending ||
    clearProduct.isPending ||
    markDomain.isPending ||
    markSubdomain.isPending;

  function applyProduct(next: ReviewState) {
    // "Not reviewed" on an explicitly-marked product reverts to its computed
    // default (clear); on an unmarked product it stores an explicit
    // not_reviewed override (so the user's intent sticks over a
    // no_review_needed default).
    if (next === ReviewState.not_reviewed && isExplicit) {
      clearProduct.mutate(
        {
          params: {
            business_id: target.businessId,
            version_int: target.versionInt,
            scope: target.scope,
            product_id: target.id,
          },
        },
        {
          onSuccess: () => {
            invalidate();
            toast.success("Review mark cleared");
          },
          onError: (err) => notifyError(err, { title: "Couldn't clear" }),
        },
      );
      return;
    }
    markProduct.mutate(
      {
        params: {
          business_id: target.businessId,
          version_int: target.versionInt,
          scope: target.scope,
          product_id: target.id,
        },
        data: { state: next },
      },
      {
        onSuccess: () => {
          invalidate();
          toast.success(`Marked ${reviewStateLabel(next).toLowerCase()}`);
        },
        onError: (err) => notifyError(err, { title: "Couldn't mark" }),
      },
    );
  }

  function runCascade(next: ReviewState) {
    const onSettled = {
      onSuccess: (res: { data: { affected?: number } }) => {
        invalidate();
        setCascade(null);
        toast.success(`Marked ${res.data.affected ?? cascadeCount} products`);
      },
      onError: (err: unknown) => notifyError(err, { title: "Cascade failed" }),
    };
    if (target.level === "domain") {
      markDomain.mutate(
        {
          params: {
            business_id: target.businessId,
            version_int: target.versionInt,
            scope: target.scope,
            domain_id: target.id,
          },
          data: { state: next },
        },
        onSettled,
      );
    } else {
      markSubdomain.mutate(
        {
          params: {
            business_id: target.businessId,
            version_int: target.versionInt,
            scope: target.scope,
            subdomain_id: target.id,
          },
          data: { state: next },
        },
        onSettled,
      );
    }
  }

  function choose(next: ReviewState) {
    if (next === state && isExplicit) return; // no-op: already in that mark
    if (isCascadeLevel) {
      setCascade(next); // open the confirmation gate; cascade fires on confirm
      return;
    }
    applyProduct(next);
  }

  const isReviewed = state === ReviewState.reviewed;
  const isNoReviewNeeded = state === ReviewState.no_review_needed;

  return (
    <div className={cn("flex items-center gap-2", className)}>
      <div
        role="group"
        aria-label="Review state"
        className="inline-flex overflow-hidden rounded-md border border-input"
      >
        <Button
          type="button"
          variant={isReviewed ? "default" : "ghost"}
          size="sm"
          disabled={pending}
          aria-pressed={isReviewed}
          className="rounded-none border-0"
          onClick={() => choose(ReviewState.reviewed)}
        >
          <Check className="mr-1 h-3.5 w-3.5" />
          Reviewed
        </Button>
        <Button
          type="button"
          variant={!isReviewed && !isNoReviewNeeded ? "default" : "ghost"}
          size="sm"
          disabled={pending}
          aria-pressed={!isReviewed && !isNoReviewNeeded}
          className="rounded-none border-0 border-l border-input"
          onClick={() => choose(ReviewState.not_reviewed)}
        >
          <Circle className="mr-1 h-3.5 w-3.5" />
          Not reviewed
        </Button>
      </div>

      {isNoReviewNeeded && (
        <Badge
          variant="outline"
          className={cn("text-xs font-normal", reviewStateBadgeClass(state))}
          title="Unchanged with no open issues — no review needed by default. Choose a state to override."
        >
          {reviewStateLabel(state)}
        </Badge>
      )}

      {isCascadeLevel && (
        <CascadeConfirmDialog
          open={cascade !== null}
          onOpenChange={(o) => {
            if (!o) setCascade(null);
          }}
          scopeLabel={target.level}
          scopeName={target.name ?? ""}
          itemCount={cascadeCount}
          state={cascade ?? ReviewState.reviewed}
          pending={pending}
          onConfirm={() => cascade !== null && runCascade(cascade)}
        />
      )}
    </div>
  );
}
