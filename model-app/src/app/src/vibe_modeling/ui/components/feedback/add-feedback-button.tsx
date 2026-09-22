import { useCallback, useEffect, useState, type ReactNode } from "react";
import { MessageSquarePlus } from "lucide-react";
import { Button } from "@/components/ui/button";
import { FeedbackDialog } from "./feedback-dialog";
import type { FeedbackContext } from "@/lib/api";

interface AddFeedbackButtonProps {
  businessId: string;
  versionId?: string;
  /** Function called at click time to snapshot the current view state. */
  getContext: () => FeedbackContext;
  variant?: "default" | "outline" | "ghost";
  size?: "default" | "sm" | "icon";
  /** Optional override for the button label. Defaults to "Add <u>F</u>eedback". */
  label?: ReactNode;
  className?: string;
  /** Controlled open state. When provided alongside `onOpenChange`, the
   *  parent owns the dialog and is responsible for snapshotting context
   *  before opening. Otherwise the button manages state internally. */
  open?: boolean;
  onOpenChange?: (next: boolean) => void;
  /** Optional context override. When provided, takes precedence over the
   *  internal context state — used by parents that capture context at
   *  trigger sites outside the button (page-level F shortcut, diagram
   *  double-click). */
  context?: FeedbackContext;
}

/**
 * Button that opens a feedback dialog pre-populated with the current view context.
 *
 * The context is captured lazily at click time via `getContext` so the button
 * doesn't need to re-render on every selection change in its parent. When
 * the parent supplies `open` + `onOpenChange`, it can also drive the dialog
 * from a keyboard shortcut or another trigger and pass the captured context
 * via the `context` prop.
 */
export function AddFeedbackButton({
  businessId,
  versionId,
  getContext,
  variant = "outline",
  size = "sm",
  label,
  className,
  open: openProp,
  onOpenChange,
  context: contextProp,
}: AddFeedbackButtonProps) {
  const isControlled = openProp !== undefined && onOpenChange !== undefined;
  const [internalOpen, setInternalOpen] = useState(false);
  const [internalContext, setInternalContext] = useState<FeedbackContext>({
    context_version: 1,
    view_mode: "",
  });

  const open = isControlled ? openProp! : internalOpen;
  const context = contextProp ?? internalContext;

  const handleOpenChange = (next: boolean) => {
    if (isControlled) {
      onOpenChange!(next);
    } else {
      setInternalOpen(next);
    }
  };

  const handleClick = useCallback(() => {
    if (isControlled) {
      onOpenChange!(true);
      return;
    }
    setInternalContext(getContext());
    setInternalOpen(true);
  }, [isControlled, onOpenChange, getContext]);

  useEffect(() => {
    function onKeyDown(e: KeyboardEvent) {
      if (e.key !== "f" && e.key !== "F") return;
      if (e.metaKey || e.ctrlKey || e.altKey || e.shiftKey) return;
      const active = document.activeElement as HTMLElement | null;
      if (active) {
        const tag = active.tagName;
        if (tag === "INPUT" || tag === "TEXTAREA") return;
        if (active.isContentEditable) return;
        if (active.closest('[role="dialog"]')) return;
      }
      e.preventDefault();
      handleClick();
    }
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [handleClick]);

  const renderedLabel = label ?? (
    <span>Add <u>F</u>eedback</span>
  );

  return (
    <>
      <Button variant={variant} size={size} onClick={handleClick} className={className}>
        <MessageSquarePlus className="h-4 w-4 mr-1.5" />
        {renderedLabel}
      </Button>
      <FeedbackDialog
        open={open}
        onOpenChange={handleOpenChange}
        businessId={businessId}
        versionId={versionId}
        context={context}
      />
    </>
  );
}
