import { useCallback, type RefObject } from "react";
import {
  Bold,
  Italic,
  Heading2,
  Heading3,
  List,
  ListOrdered,
} from "lucide-react";
import { cn } from "@/lib/utils";

interface MarkdownToolbarProps {
  textareaRef: RefObject<HTMLTextAreaElement | null>;
  /** Called after inserting markdown to update parent state */
  onUpdate: (value: string) => void;
  className?: string;
}

type WrapAction = { type: "wrap"; before: string; after: string };
type LineAction = { type: "line-prefix"; prefix: string };
type Action = WrapAction | LineAction;

const actions: { icon: typeof Bold; label: string; action: Action }[] = [
  { icon: Heading2, label: "Heading 2", action: { type: "line-prefix", prefix: "## " } },
  { icon: Heading3, label: "Heading 3", action: { type: "line-prefix", prefix: "### " } },
  { icon: Bold, label: "Bold", action: { type: "wrap", before: "**", after: "**" } },
  { icon: Italic, label: "Italic", action: { type: "wrap", before: "_", after: "_" } },
  { icon: List, label: "Bullet list", action: { type: "line-prefix", prefix: "- " } },
  { icon: ListOrdered, label: "Numbered list", action: { type: "line-prefix", prefix: "1. " } },
];

/**
 * Markdown formatting toolbar for a textarea.
 * Wraps selected text or inserts at cursor. Does not render a preview.
 */
export function MarkdownToolbar({ textareaRef, onUpdate, className }: MarkdownToolbarProps) {
  const apply = useCallback(
    (action: Action) => {
      const ta = textareaRef.current;
      if (!ta) return;

      const start = ta.selectionStart;
      const end = ta.selectionEnd;
      const text = ta.value;
      const selected = text.slice(start, end);

      let replacement: string;
      let cursorPos: number;

      if (action.type === "wrap") {
        if (selected) {
          replacement = `${action.before}${selected}${action.after}`;
          cursorPos = start + replacement.length;
        } else {
          replacement = `${action.before}${action.after}`;
          cursorPos = start + action.before.length;
        }
        const newValue = text.slice(0, start) + replacement + text.slice(end);
        onUpdate(newValue);
        requestAnimationFrame(() => {
          ta.focus();
          ta.setSelectionRange(cursorPos, cursorPos);
        });
      } else {
        // Line prefix — find start of line
        const lineStart = text.lastIndexOf("\n", start - 1) + 1;
        const lineEnd = text.indexOf("\n", end);
        const actualEnd = lineEnd === -1 ? text.length : lineEnd;
        const line = text.slice(lineStart, actualEnd);

        // Toggle: if line already starts with prefix, remove it
        if (line.startsWith(action.prefix)) {
          replacement = line.slice(action.prefix.length);
          cursorPos = start - action.prefix.length;
        } else {
          replacement = `${action.prefix}${line}`;
          cursorPos = start + action.prefix.length;
        }

        const newValue = text.slice(0, lineStart) + replacement + text.slice(actualEnd);
        onUpdate(newValue);
        requestAnimationFrame(() => {
          ta.focus();
          ta.setSelectionRange(
            Math.max(lineStart, cursorPos),
            Math.max(lineStart, cursorPos),
          );
        });
      }
    },
    [textareaRef, onUpdate],
  );

  return (
    <div className={cn("flex items-center gap-0.5 border-b border-input px-1 py-1", className)}>
      {actions.map(({ icon: Icon, label, action }) => (
        <button
          key={label}
          type="button"
          title={label}
          onClick={() => apply(action)}
          className="p-1.5 rounded hover:bg-muted transition-colors text-muted-foreground hover:text-foreground"
        >
          <Icon className="h-3.5 w-3.5" />
        </button>
      ))}
    </div>
  );
}
