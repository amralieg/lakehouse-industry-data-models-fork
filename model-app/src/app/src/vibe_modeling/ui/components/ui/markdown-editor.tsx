import * as React from "react";
import { useRef } from "react";
import { Textarea } from "@/components/ui/textarea";
import { MarkdownToolbar } from "@/components/ui/markdown-toolbar";

interface MarkdownEditorProps {
  /** Controlled value. */
  value: string;
  /** Called when the user edits the textarea OR clicks a toolbar action. */
  onChange: (value: string) => void;
  /** Placeholder for the textarea. */
  placeholder?: string;
  /** Visible rows for the textarea. */
  rows?: number;
  /** Optional `data-testid` forwarded to the inner textarea. */
  textareaTestId?: string;
}

/**
 * Wrapped markdown editor: a `MarkdownToolbar` over a controlled
 * `<Textarea>` inside a single focus-within ring container.
 *
 * Both surfaces ultimately call `onChange(string)` — the textarea via
 * React's `onChange`, the toolbar via its `onUpdate` callback. Callers
 * pass one `value` + one `onChange` and never need to plumb a textarea
 * ref to mediate between the toolbar and the textarea.
 *
 * This component is the single source of truth for the "toolbar + textarea
 * in a ring" pattern. Three inline copies of this wrapper previously lived
 * on the New Run form (Business Context, Run Instructions, Vibe
 * Instructions); they're now all routed through here so the React state
 * + chrome-devtools `fill()` propagation contract is wired once, not
 * three times.
 */
export const MarkdownEditor = React.forwardRef<
  HTMLTextAreaElement,
  MarkdownEditorProps
>(function MarkdownEditor(
  { value, onChange, placeholder, rows, textareaTestId },
  forwardedRef,
) {
  const internalRef = useRef<HTMLTextAreaElement>(null);
  // Bridge the forwarded ref (so callers can still focus / read selection
  // from outside) with our internal ref (so MarkdownToolbar can mutate
  // the selection after a toolbar click).
  const setRef = (el: HTMLTextAreaElement | null) => {
    (internalRef as { current: HTMLTextAreaElement | null }).current = el;
    if (typeof forwardedRef === "function") {
      forwardedRef(el);
    } else if (forwardedRef) {
      (forwardedRef as { current: HTMLTextAreaElement | null }).current = el;
    }
  };
  return (
    <div className="rounded-md border border-input overflow-hidden focus-within:ring-1 focus-within:ring-ring">
      <MarkdownToolbar textareaRef={internalRef} onUpdate={onChange} />
      <Textarea
        ref={setRef}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        rows={rows}
        data-testid={textareaTestId}
        className="border-0 focus-visible:ring-0 rounded-none"
      />
    </div>
  );
});
