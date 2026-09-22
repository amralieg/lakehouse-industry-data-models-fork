import { AlertTriangle } from "lucide-react";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { reviewStateLabel } from "./review-state-labels";
import type { ReviewState } from "@/lib/api";

/**
 * Confirmation gate for a cascade mark (domain / subdomain).
 *
 * Marking an aggregation grain fans the chosen state out onto every product
 * beneath it (ADR D-044, server-side `_cascade_mark`). This dialog surfaces the
 * scope ("this will mark N items") and an explicit "are you sure" before the
 * cascade endpoint is ever called: `onConfirm` fires ONLY on the confirm
 * action, never on cancel or dismiss. The acceptance gate ("cascade only after
 * confirm") lives here.
 */
export function CascadeConfirmDialog({
  open,
  onOpenChange,
  scopeLabel,
  scopeName,
  itemCount,
  state,
  pending = false,
  onConfirm,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  /** "domain" | "subdomain" — the aggregation grain being marked. */
  scopeLabel: string;
  /** The human name of the domain/subdomain being marked. */
  scopeName: string;
  /** Number of product rows the cascade will write. */
  itemCount: number;
  /** The review state being applied. */
  state: ReviewState;
  pending?: boolean;
  onConfirm: () => void;
}) {
  const noun = itemCount === 1 ? "product" : "products";
  return (
    <AlertDialog
      open={open}
      onOpenChange={(next) => {
        // Never let a backdrop/escape dismiss while the cascade is in flight.
        if (!pending) onOpenChange(next);
      }}
    >
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>
            Mark {scopeLabel}{" "}
            <span className="font-mono">{scopeName}</span> as{" "}
            {reviewStateLabel(state)}?
          </AlertDialogTitle>
          <AlertDialogDescription asChild>
            <div className="space-y-3">
              <div className="flex items-start gap-2 rounded-md border border-warning/50 bg-warning/10 p-3 text-sm">
                <AlertTriangle className="mt-0.5 h-4 w-4 shrink-0 text-warning" />
                <span>
                  This will set the review state of{" "}
                  <strong>
                    {itemCount} {noun}
                  </strong>{" "}
                  in this {scopeLabel}, overriding any existing marks beneath
                  it.
                </span>
              </div>
            </div>
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel disabled={pending}>Cancel</AlertDialogCancel>
          <AlertDialogAction
            onClick={(e) => {
              // Keep the dialog open until the caller decides (mutation may
              // fail); the caller closes it on success.
              e.preventDefault();
              onConfirm();
            }}
            disabled={pending}
          >
            {pending ? "Marking…" : `Mark ${itemCount} ${noun}`}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
}
