/**
 * `MarkdownToolbar` rendering + click behaviour.
 *
 * The toolbar mutates a textarea by either wrapping the selection
 * (Bold/Italic) or prefixing the current line (H2/H3/list/ordered).
 * We mount the toolbar against a real textarea, drive selection
 * positions by setting `selectionStart`/`selectionEnd`, and assert that
 * each button calls `onUpdate` with the expected new value.
 */
import { describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import { useRef } from "react";

import { MarkdownToolbar } from "@/components/ui/markdown-toolbar";

function Harness({ initial = "" }: { initial?: string }) {
  // We track the current value via a mutable ref so our exposed
  // `onUpdate` mock can read what the toolbar produced.
  const taRef = useRef<HTMLTextAreaElement>(null);
  const updates: string[] = [];
  // Expose the textarea + the updates array via the global so the test
  // can drive it. Cleaner than rendering through state and re-mounting.
  (globalThis as unknown as { __mdHarness: unknown }).__mdHarness = {
    taRef,
    updates,
  };
  return (
    <div>
      <MarkdownToolbar
        textareaRef={taRef}
        onUpdate={(v) => updates.push(v)}
      />
      <textarea ref={taRef} defaultValue={initial} />
    </div>
  );
}

function getHarness() {
  return (globalThis as unknown as {
    __mdHarness: {
      taRef: React.RefObject<HTMLTextAreaElement>;
      updates: string[];
    };
  }).__mdHarness;
}

describe("MarkdownToolbar", () => {
  it("renders six toolbar buttons (H2, H3, Bold, Italic, list, ordered)", () => {
    render(<Harness />);
    expect(screen.getByTitle("Heading 2")).toBeInTheDocument();
    expect(screen.getByTitle("Heading 3")).toBeInTheDocument();
    expect(screen.getByTitle("Bold")).toBeInTheDocument();
    expect(screen.getByTitle("Italic")).toBeInTheDocument();
    expect(screen.getByTitle("Bullet list")).toBeInTheDocument();
    expect(screen.getByTitle("Numbered list")).toBeInTheDocument();
  });

  it("Bold wraps the selection in **...**", () => {
    render(<Harness initial="hello world" />);
    const { taRef, updates } = getHarness();
    const ta = taRef.current!;
    // Select the word "hello"
    ta.setSelectionRange(0, 5);
    fireEvent.click(screen.getByTitle("Bold"));
    expect(updates.at(-1)).toBe("**hello** world");
  });

  it("Heading 2 prefixes the current line with '## '", () => {
    render(<Harness initial="my title" />);
    const { taRef, updates } = getHarness();
    const ta = taRef.current!;
    ta.setSelectionRange(0, 0);
    fireEvent.click(screen.getByTitle("Heading 2"));
    expect(updates.at(-1)).toBe("## my title");
  });

  it("Bullet list prefixes the current line with '- '", () => {
    render(<Harness initial="item" />);
    const { taRef, updates } = getHarness();
    const ta = taRef.current!;
    ta.setSelectionRange(0, 0);
    fireEvent.click(screen.getByTitle("Bullet list"));
    expect(updates.at(-1)).toBe("- item");
  });

  it("toggles a line prefix off when clicked twice", () => {
    render(<Harness initial="## already a heading" />);
    const { taRef, updates } = getHarness();
    const ta = taRef.current!;
    ta.setSelectionRange(0, 0);
    fireEvent.click(screen.getByTitle("Heading 2"));
    // Second click after first inserts the prefix again, but since we
    // started with the prefix, the toggle removes it.
    expect(updates[0]).toBe("already a heading");
  });

  it("does nothing when textareaRef.current is null", () => {
    const onUpdate = vi.fn();
    const ref = { current: null as HTMLTextAreaElement | null };
    render(<MarkdownToolbar textareaRef={ref} onUpdate={onUpdate} />);
    fireEvent.click(screen.getByTitle("Bold"));
    expect(onUpdate).not.toHaveBeenCalled();
  });
});
