import { useCallback, useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { X } from "lucide-react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { PrioritySelect } from "@/components/vibe-inputs/priority-select";
import {
  createVibeInput,
  listVibeInputsKey,
  VibeInputOrigin,
  VibeInputPriority,
  type FeedbackContext,
} from "@/lib/api";
import { cn } from "@/lib/utils";

interface FeedbackDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  businessId: string;
  versionId?: string;
  context: FeedbackContext;
}

/**
 * Render a foreign-key edge id in human-readable form.
 *
 * The diagram layer uses ids in the shape
 *   `fk:<src_domain>.<src_product>.<src_col>><tgt_domain>.<tgt_product>.<tgt_col>`
 * which packs six fields into one string. Users composing feedback don't
 * benefit from seeing that raw form — they want to see "which tables and
 * which columns is this relationship about". This helper parses the id
 * and produces `<src_domain>.<src_product>.<src_col> → <tgt_domain>.<tgt_product>.<tgt_col>`;
 * if the id doesn't parse it falls back to the raw string so we never
 * silently drop information.
 */
function formatEdgeLabel(edgeId: string): string {
  const stripped = edgeId.startsWith("fk:") ? edgeId.slice(3) : edgeId;
  const arrowIdx = stripped.indexOf(">");
  if (arrowIdx === -1) return edgeId;
  const src = stripped.slice(0, arrowIdx);
  const tgt = stripped.slice(arrowIdx + 1);
  return `${src} → ${tgt}`;
}

/**
 * Movable, non-modal feedback dialog.
 *
 * Renders as a floating panel over the page without a backdrop so the user
 * can continue interacting with the visualization (zoom, pan, inspect) while
 * composing feedback. Drag handle on the header.
 */
export function FeedbackDialog({
  open,
  onOpenChange,
  businessId,
  versionId,
  context,
}: FeedbackDialogProps) {
  const [text, setText] = useState("");
  const [priority, setPriority] = useState<VibeInputPriority>(VibeInputPriority.medium);
  const [error, setError] = useState<string | null>(null);
  const [position, setPosition] = useState({ x: 24, y: 80 });
  const dragRef = useRef<{ startX: number; startY: number; startPos: { x: number; y: number } } | null>(null);
  const queryClient = useQueryClient();

  // The Fullscreen API only paints the fullscreen element's subtree; this
  // dialog is a fixed-position div rendered outside that subtree, so while a
  // fullscreen element is active it must be portaled INTO it (or it renders
  // invisibly behind the top layer). Recompute on open and on every
  // fullscreenchange so a toolbar-driven fullscreen exit re-parents an
  // already-open dialog back to document.body.
  const [portalTarget, setPortalTarget] = useState<HTMLElement>(
    () => (document.fullscreenElement as HTMLElement | null) ?? document.body,
  );

  useEffect(() => {
    function syncTarget() {
      setPortalTarget((document.fullscreenElement as HTMLElement | null) ?? document.body);
    }
    syncTarget();
    document.addEventListener("fullscreenchange", syncTarget);
    return () => document.removeEventListener("fullscreenchange", syncTarget);
  }, [open]);

  const mutation = useMutation({
    mutationFn: () =>
      createVibeInput(
        { business_id: businessId },
        {
          text,
          priority,
          version_id: versionId,
          origin: VibeInputOrigin.user,
          origin_context: context,
        },
      ),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: listVibeInputsKey({ business_id: businessId }) });
      setText("");
      setError(null);
      onOpenChange(false);
    },
    onError: (err: unknown) => {
      setError(err instanceof Error ? err.message : "Failed to save feedback");
    },
  });

  useEffect(() => {
    if (!open) return;
    function onKey(e: KeyboardEvent) {
      if (e.key === "Escape") {
        e.preventDefault();
        onOpenChange(false);
      }
    }
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [open, onOpenChange]);

  // Reset position when reopened
  useEffect(() => {
    if (open) {
      setPosition({ x: Math.max(24, window.innerWidth - 480), y: 80 });
    }
  }, [open]);

  const onPointerDown = useCallback((e: React.PointerEvent<HTMLDivElement>) => {
    // Only allow drag from the header, not from buttons
    if ((e.target as HTMLElement).closest("button")) return;
    e.currentTarget.setPointerCapture(e.pointerId);
    dragRef.current = {
      startX: e.clientX,
      startY: e.clientY,
      startPos: { ...position },
    };
  }, [position]);

  const onPointerMove = useCallback((e: React.PointerEvent<HTMLDivElement>) => {
    if (!dragRef.current) return;
    const dx = e.clientX - dragRef.current.startX;
    const dy = e.clientY - dragRef.current.startY;
    setPosition({
      x: Math.max(0, Math.min(window.innerWidth - 100, dragRef.current.startPos.x + dx)),
      y: Math.max(0, Math.min(window.innerHeight - 60, dragRef.current.startPos.y + dy)),
    });
  }, []);

  const onPointerUp = useCallback((e: React.PointerEvent<HTMLDivElement>) => {
    dragRef.current = null;
    e.currentTarget.releasePointerCapture(e.pointerId);
  }, []);

  if (!open) return null;

  const contextBadges: { key: string; label: string }[] = [];
  if (context.view_mode) contextBadges.push({ key: "view", label: context.view_mode });
  if (context.domain_filter) contextBadges.push({ key: "domain", label: context.domain_filter });
  if (context.selected_node_id) {
    contextBadges.push({ key: "table", label: context.selected_node_id });
  }
  if (context.selected_edge_id) {
    contextBadges.push({ key: "relationship", label: formatEdgeLabel(context.selected_edge_id) });
  }

  const panel = (
    <div
      className="fixed z-50 w-[440px] rounded-md border border-border bg-background shadow-md"
      style={{ left: position.x, top: position.y }}
    >
      <div
        className="flex items-center justify-between border-b border-border px-4 py-2 cursor-move select-none"
        onPointerDown={onPointerDown}
        onPointerMove={onPointerMove}
        onPointerUp={onPointerUp}
      >
        <h2 className="text-sm font-semibold">Add feedback</h2>
        <button
          type="button"
          onClick={() => onOpenChange(false)}
          className="rounded-sm p-1 hover:bg-muted transition-colors"
          aria-label="Close"
        >
          <X className="h-4 w-4" />
        </button>
      </div>

      <div className="p-4 space-y-3">
        {contextBadges.length > 0 && (
          <div className="flex flex-wrap gap-1.5">
            {contextBadges.map((b) => (
              <Badge key={b.key} variant="secondary" className="text-[10px]">
                {b.key}: {b.label}
              </Badge>
            ))}
          </div>
        )}

        <Textarea
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder="What's missing, wrong, or could be improved?"
          rows={6}
          autoFocus
          className={cn(error && "border-destructive")}
        />

        <div className="flex items-center gap-2">
          <span className="text-xs text-muted-foreground">Priority</span>
          <PrioritySelect value={priority} onValueChange={setPriority} container={portalTarget} />
        </div>

        {!versionId && (
          <p className="text-xs text-muted-foreground">
            Open a model version to add feedback.
          </p>
        )}

        {error && (
          <p className="text-xs text-destructive">{error}</p>
        )}

        <div className="flex justify-end gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => onOpenChange(false)}
            disabled={mutation.isPending}
          >
            Cancel
          </Button>
          <Button
            size="sm"
            onClick={() => {
              if (!text.trim()) {
                setError("Feedback text is required");
                return;
              }
              mutation.mutate();
            }}
            disabled={mutation.isPending || !text.trim() || !versionId}
          >
            {mutation.isPending ? "Saving..." : "Save feedback"}
          </Button>
        </div>
      </div>
    </div>
  );

  return createPortal(panel, portalTarget);
}
