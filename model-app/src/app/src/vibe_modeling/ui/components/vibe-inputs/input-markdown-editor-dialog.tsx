import { useEffect, useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { FileText } from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { MarkdownEditor } from "@/components/ui/markdown-editor";
import { PrioritySelect } from "./priority-select";
import { useUpdateVibeInput, VibeInputPriority, type VibeInputOut } from "@/lib/api";
import { invalidateVibeInputQueries } from "./query-keys";

export interface InputMarkdownEditorDialogProps {
  businessId: string;
  /** The input being edited; `null` keeps the dialog closed. */
  input: VibeInputOut | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  /** Optional human anchor path for the header (e.g. "Domain: Sales"). */
  anchorLabel?: string;
}

/**
 * Full markdown editor escalated from a card or the details page. Reuses the
 * canonical `MarkdownEditor` (toolbar + live-preview-capable textarea, the one
 * place the controlled value / fill propagation is wired) inside a scrim
 * dialog. ⌘↵ saves durably via `useUpdateVibeInput`; Esc / Cancel discards.
 */
export function InputMarkdownEditorDialog({
  businessId,
  input,
  open,
  onOpenChange,
  anchorLabel,
}: InputMarkdownEditorDialogProps) {
  const queryClient = useQueryClient();
  const [draft, setDraft] = useState("");
  const [priority, setPriority] = useState<VibeInputPriority>(VibeInputPriority.medium);
  const update = useUpdateVibeInput();

  // Re-seed the draft whenever a new input opens. Controlled value throughout
  // (the textarea-fill bug fix): never `el.value =` / uncontrolled defaultValue.
  useEffect(() => {
    if (open && input) {
      setDraft(input.text);
      setPriority(input.priority);
    }
  }, [open, input?.id]); // eslint-disable-line react-hooks/exhaustive-deps

  const save = () => {
    if (!input) return;
    const text = draft.trim();
    const priorityChanged = priority !== input.priority;
    if ((!text || text === input.text) && !priorityChanged) {
      onOpenChange(false);
      return;
    }
    update.mutate(
      {
        params: { business_id: businessId, input_id: input.id },
        data: {
          ...(text && text !== input.text ? { text } : {}),
          priority,
        },
      },
      {
        onSuccess: () => {
          invalidateVibeInputQueries(queryClient, businessId);
          onOpenChange(false);
        },
      },
    );
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-3xl">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <FileText className="h-4 w-4" />
            Edit instruction
            {anchorLabel && (
              <span className="font-mono text-xs font-normal text-muted-foreground">
                {anchorLabel}
              </span>
            )}
          </DialogTitle>
        </DialogHeader>
        <div
          onKeyDown={(e) => {
            if (e.key === "Enter" && (e.metaKey || e.ctrlKey)) {
              e.preventDefault();
              save();
            }
          }}
        >
          <MarkdownEditor
            value={draft}
            onChange={setDraft}
            placeholder="Write the instruction in Markdown…"
            rows={14}
          />
          <div className="mt-2 flex items-center gap-2">
            <span className="text-xs text-muted-foreground">Priority</span>
            <PrioritySelect value={priority} onValueChange={setPriority} />
          </div>
          <p className="mt-2 text-xs text-muted-foreground">
            Saved durably to this input. Markdown · ⌘↵ to save.
          </p>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)} disabled={update.isPending}>
            Cancel
          </Button>
          <Button onClick={save} disabled={update.isPending}>
            {update.isPending ? "Saving…" : "Save"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
