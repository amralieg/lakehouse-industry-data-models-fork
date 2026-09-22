import { Suspense } from "react";
import { QueryErrorResetBoundary } from "@tanstack/react-query";
import { ErrorBoundary } from "react-error-boundary";
import { CheckCircle2 } from "lucide-react";
import { useGetReviewProgressSuspense } from "@/lib/api";
import type { ReviewProgressOut } from "@/lib/api";
import { selector } from "@/lib/selector";
import { Progress } from "@/components/ui/progress";
import { Skeleton } from "@/components/ui/skeleton";

/**
 * Product-level review-progress indicator: reviewed ÷ review-needed.
 *
 * The denominator EXCLUDES `no_review_needed` products (ADR D-044) — it is the
 * backend's `review_needed`, which already folds them out. When nothing needs
 * review the bar shows an explicit "nothing to review" state rather than a
 * misleading 0%.
 *
 * Reusable: wired into the model overview today; T7's domain breakdown can
 * drop the same component in (each domain row is just another scope).
 */
function pct(p: ReviewProgressOut): number {
  // Backend `review_pct` is a 0..1 ratio; render as a whole percentage.
  return Math.round((p.review_pct ?? 0) * 100);
}

function ReviewProgressBody({
  businessId,
  versionInt,
  scope,
}: {
  businessId: string;
  versionInt: number;
  scope: string;
}) {
  const { data } = useGetReviewProgressSuspense({
    params: { business_id: businessId, version_int: versionInt, scope },
    ...selector(),
  });

  const reviewed = data.reviewed ?? 0;
  const reviewNeeded = data.review_needed ?? 0;
  const noReviewNeeded = data.no_review_needed ?? 0;
  const value = pct(data);

  // Everything is auto-resolved as no_review_needed (or the version is empty):
  // there is no meaningful percentage to show.
  if (reviewNeeded === 0) {
    return (
      <div data-testid="review-progress" className="space-y-1.5">
        <div className="flex items-center gap-1.5 text-sm text-muted-foreground">
          <CheckCircle2 className="h-4 w-4 text-success" />
          <span>Nothing to review</span>
        </div>
        {noReviewNeeded > 0 && (
          <p className="text-xs text-muted-foreground">
            {noReviewNeeded} unchanged{" "}
            {noReviewNeeded === 1 ? "product" : "products"} need no review.
          </p>
        )}
      </div>
    );
  }

  const complete = reviewed >= reviewNeeded;

  return (
    <div data-testid="review-progress" className="space-y-1.5">
      <div className="flex items-center justify-between text-sm">
        <span className="flex items-center gap-1.5 font-medium">
          {complete && <CheckCircle2 className="h-4 w-4 text-success" />}
          Review progress
        </span>
        <span className="tabular-nums text-muted-foreground">
          {reviewed} / {reviewNeeded} reviewed ({value}%)
        </span>
      </div>
      <Progress value={value} aria-label="Review progress" />
      {noReviewNeeded > 0 && (
        <p className="text-xs text-muted-foreground">
          {noReviewNeeded} unchanged{" "}
          {noReviewNeeded === 1 ? "product" : "products"} excluded (no review
          needed).
        </p>
      )}
    </div>
  );
}

export function ReviewProgress({
  businessId,
  versionInt,
  scope,
}: {
  businessId: string;
  versionInt: number;
  scope: string;
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
              Couldn't load review progress — retry
            </button>
          )}
        >
          <Suspense fallback={<Skeleton className="h-10 w-full" />}>
            <ReviewProgressBody
              businessId={businessId}
              versionInt={versionInt}
              scope={scope}
            />
          </Suspense>
        </ErrorBoundary>
      )}
    </QueryErrorResetBoundary>
  );
}
