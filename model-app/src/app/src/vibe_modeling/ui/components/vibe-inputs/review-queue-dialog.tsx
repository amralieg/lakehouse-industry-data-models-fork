import { useEffect, useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import {
  Link2,
  X,
  Check,
  CornerDownRight,
  Trash2,
  Sparkles,
  ArrowRight,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  useAcceptReviewLink,
  useReanchorReviewLink,
  useDismissReviewLink,
  type ReviewQueueItemOut,
  type ReanchorIn,
} from "@/lib/api";
import { invalidateVibeInputQueries } from "./query-keys";

const RESUME_KEY = "vi_review_idx";

/** A candidate element the user can re-anchor to. */
export interface ModelElementOption {
  label: string;
  kind: string;
  ids: ReanchorIn;
}

export interface ReviewQueueDialogProps {
  businessId: string;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  /** Live queue items (from useGetReviewQueue) — oldest-first. */
  items: readonly ReviewQueueItemOut[];
  /** Candidate elements for the re-anchor picker (from the model summary /
   *  section tree). */
  reanchorOptions?: readonly ModelElementOption[];
}

/**
 * Resumable, one-at-a-time link-review modal. The queue is a LIVE server read
 * (resolving an item removes it from the next fetch), so the persisted index is
 * just a cursor into the current items, clamped to the length. Accept /
 * Re-anchor (ModelElementPicker) / Dismiss call the real review hooks and
 * invalidate; reviewed_by/at are stamped server-side.
 */
export function ReviewQueueDialog({
  businessId,
  open,
  onOpenChange,
  items,
  reanchorOptions = [],
}: ReviewQueueDialogProps) {
  const queryClient = useQueryClient();
  const [idx, setIdx] = useState(() => readResumeIndex());
  const [reanchoring, setReanchoring] = useState(false);

  const accept = useAcceptReviewLink();
  const reanchor = useReanchorReviewLink();
  const dismiss = useDismissReviewLink();
  const pending = accept.isPending || reanchor.isPending || dismiss.isPending;

  // Clamp the cursor into the current (live) queue and persist it.
  const clamped = items.length === 0 ? 0 : Math.min(idx, items.length - 1);
  useEffect(() => {
    if (clamped !== idx) setIdx(clamped);
  }, [clamped, idx]);
  useEffect(() => {
    localStorage.setItem(RESUME_KEY, String(clamped));
  }, [clamped]);

  const done = items.length === 0;
  const item = items[clamped];
  const isRel = !!item?.link.fk_link_id;

  const onSettled = () => {
    invalidateVibeInputQueries(queryClient, businessId);
    setReanchoring(false);
  };

  const handleAccept = () => {
    if (!item) return;
    accept.mutate(
      { params: { business_id: businessId, link_id: item.link.id } },
      { onSuccess: onSettled },
    );
  };
  const handleDismiss = () => {
    if (!item) return;
    dismiss.mutate(
      { params: { business_id: businessId, link_id: item.link.id } },
      { onSuccess: onSettled },
    );
  };
  const handleReanchor = (ids: ReanchorIn) => {
    if (!item) return;
    reanchor.mutate(
      { params: { business_id: businessId, link_id: item.link.id }, data: ids },
      { onSuccess: onSettled },
    );
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-xl">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Link2 className="h-4 w-4" />
            Link review
            {!done && (
              <span className="text-xs font-normal text-muted-foreground">
                {clamped + 1} of {items.length}
              </span>
            )}
            <button
              type="button"
              aria-label="Close — back to inputs"
              onClick={() => onOpenChange(false)}
              className="ml-auto text-muted-foreground hover:text-foreground"
            >
              <X className="h-4 w-4" />
            </button>
          </DialogTitle>
        </DialogHeader>

        {done ? (
          <div className="flex flex-col items-center gap-3 py-8 text-center">
            <Check className="h-7 w-7 text-success" />
            <h2 className="text-lg font-semibold">All links reviewed</h2>
            <p className="text-sm text-muted-foreground">
              The model is ready for the next run.
            </p>
            <Button onClick={() => onOpenChange(false)}>Back to inputs</Button>
          </div>
        ) : (
          <div className="space-y-4">
            <Progress value={(clamped / items.length) * 100} />

            <div className="flex items-center gap-2">
              <span className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                Vibe Input
              </span>
              {isRel && (
                <Badge variant="outline" className="gap-1">
                  <Link2 className="h-3 w-3" /> Relationship link
                </Badge>
              )}
            </div>
            <p className="whitespace-pre-wrap text-sm">{item.input.text}</p>

            <div className="grid grid-cols-[1fr_auto_1fr] items-center gap-3">
              <div className="rounded-md bg-muted p-3">
                <div className="text-[11px] font-semibold uppercase text-muted-foreground">
                  Current anchor
                </div>
                <div className="mt-1 font-mono text-xs line-through text-muted-foreground">
                  {item.input.anchor?.path?.join(" › ") || "Model-wide"}
                </div>
                <div className="mt-1 text-xs text-muted-foreground">no longer matches</div>
              </div>
              <ArrowRight className="h-4 w-4 shrink-0 text-muted-foreground" />
              <div className="rounded-md border border-warning/40 bg-warning/10 p-3">
                <div className="text-[11px] font-semibold uppercase text-warning">
                  Proposed new anchor
                </div>
                {isRel ? (
                  <RelationshipAnchor label={item.proposed_anchor_label} />
                ) : (
                  <div className="mt-1 font-mono text-xs">{item.proposed_anchor_label}</div>
                )}
                <div className="mt-1 flex items-center gap-1 text-xs text-muted-foreground">
                  <Sparkles className="h-3 w-3" />
                  {item.tier === "merge_survivor" ? "merged by agent" : "re-anchored to ancestor"}
                </div>
              </div>
            </div>

            {reanchoring ? (
              <div className="space-y-2">
                <div className="text-xs font-medium">Pick a different element</div>
                <ModelElementPicker
                  options={reanchorOptions}
                  onPick={handleReanchor}
                  disabled={pending}
                />
                <Button variant="ghost" size="sm" onClick={() => setReanchoring(false)}>
                  Cancel re-anchor
                </Button>
              </div>
            ) : (
              <>
                <div className="flex items-center gap-2">
                  <Button onClick={handleAccept} disabled={pending} className="gap-1">
                    <Check className="h-4 w-4" /> Accept link
                  </Button>
                  <Button
                    variant="outline"
                    onClick={() => setReanchoring(true)}
                    disabled={pending}
                    className="gap-1"
                  >
                    <CornerDownRight className="h-4 w-4" /> Re-anchor
                  </Button>
                  <Button
                    variant="outline"
                    onClick={handleDismiss}
                    disabled={pending}
                    title="Deprecate this input — kept under Deprecated, not sent to the agent"
                    className="gap-1"
                  >
                    <Trash2 className="h-4 w-4" /> Dismiss
                  </Button>
                </div>
                <p className="text-xs text-muted-foreground">
                  <b>Accept</b> confirms the proposed link · <b>Re-anchor</b> points it at
                  another element · <b>Dismiss</b> deprecates the input (kept under
                  Deprecated, not sent to the agent).
                </p>
              </>
            )}

            <div className="flex items-center justify-between border-t border-border pt-3">
              <button
                type="button"
                onClick={() => onOpenChange(false)}
                className="text-xs text-muted-foreground hover:text-foreground"
              >
                Cancel — back to inputs
              </button>
              <span className="text-xs text-muted-foreground">Progress saved automatically</span>
            </div>
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
}

function readResumeIndex(): number {
  const raw = Number(localStorage.getItem(RESUME_KEY) ?? "0");
  return Number.isFinite(raw) && raw >= 0 ? raw : 0;
}

/** Relationship anchor: the proposed label is "Relationship A→B"; render the two
 *  entities joined by an arrow rather than a flat breadcrumb. */
function RelationshipAnchor({ label }: { label: string }) {
  const stripped = label.replace(/^Relationship\s+/, "");
  const [from, to] = stripped.split("→");
  if (!to) {
    return <div className="mt-1 font-mono text-xs">{label}</div>;
  }
  return (
    <div className="mt-1 flex items-center gap-1.5 font-mono text-xs">
      <span>{from.trim()}</span>
      <ArrowRight className="h-3 w-3 text-muted-foreground" />
      <span>{to.trim()}</span>
    </div>
  );
}

/** Picker for re-anchoring a flagged link to a chosen element. */
function ModelElementPicker({
  options,
  onPick,
  disabled,
}: {
  options: readonly ModelElementOption[];
  onPick: (ids: ReanchorIn) => void;
  disabled?: boolean;
}) {
  if (options.length === 0) {
    return (
      <p className="text-xs text-muted-foreground">No elements available to re-anchor to.</p>
    );
  }
  return (
    <div className="max-h-56 overflow-auto rounded-md border border-border">
      {options.map((opt) => (
        <button
          key={opt.label}
          type="button"
          disabled={disabled}
          onClick={() => onPick(opt.ids)}
          className="flex w-full items-center gap-2 px-2 py-1.5 text-left text-xs hover:bg-accent/50 disabled:opacity-50"
        >
          <span className="font-mono">{opt.label}</span>
          <span className="ml-auto text-muted-foreground">{opt.kind}</span>
        </button>
      ))}
    </div>
  );
}
