import { ReviewState } from "@/lib/api";

/** Canonical human label for each of the three review states (ADR D-044). */
export function reviewStateLabel(state: ReviewState): string {
  switch (state) {
    case ReviewState.reviewed:
      return "Reviewed";
    case ReviewState.no_review_needed:
      return "No review needed";
    case ReviewState.not_reviewed:
    default:
      return "Not reviewed";
  }
}

/**
 * Badge variant + token classes per state. Reuses existing semantic tokens —
 * no new colors: reviewed → success, no_review_needed → muted (read-only
 * computed default), not_reviewed → warning-tinted outline.
 */
export function reviewStateBadgeClass(state: ReviewState): string {
  switch (state) {
    case ReviewState.reviewed:
      return "border-success/40 bg-success/10 text-success";
    case ReviewState.no_review_needed:
      return "border-border bg-muted text-muted-foreground";
    case ReviewState.not_reviewed:
    default:
      return "border-warning/40 bg-warning/10 text-warning";
  }
}
