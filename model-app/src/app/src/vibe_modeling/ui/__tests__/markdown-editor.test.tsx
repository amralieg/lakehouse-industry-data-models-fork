/**
 * `MarkdownEditor` — toolbar + textarea wrapped in a focus-within ring.
 *
 * The component is the canonical home of the wrapped editor pattern that
 * was previously inlined three times on the New Run form (Business
 * Context, Run Instructions, Vibe Instructions). Tests below pin both
 * code paths that mutate `value`:
 *   1. Native input event on the textarea (the chrome-devtools / Puppeteer
 *      `fill()` path).
 *   2. Toolbar button click (the bold/heading/list affordances).
 */
import { describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen } from "@testing-library/react";
import { useState } from "react";

import { MarkdownEditor } from "@/components/ui/markdown-editor";

function setNativeValueAndDispatch(
  el: HTMLTextAreaElement,
  value: string,
) {
  const setter = Object.getOwnPropertyDescriptor(
    HTMLTextAreaElement.prototype,
    "value",
  )?.set;
  setter?.call(el, value);
  el.dispatchEvent(new Event("input", { bubbles: true }));
}

function Harness({ initial = "" }: { initial?: string }) {
  const [value, setValue] = useState(initial);
  return (
    <MarkdownEditor
      value={value}
      onChange={setValue}
      placeholder="probe-placeholder"
      rows={4}
    />
  );
}

describe("MarkdownEditor", () => {
  it("propagates a native `input` event on the inner textarea into onChange", () => {
    render(<Harness />);
    const ta = screen.getByPlaceholderText("probe-placeholder") as HTMLTextAreaElement;
    act(() => {
      setNativeValueAndDispatch(ta, "filled via native input");
    });
    expect(ta.value).toBe("filled via native input");
  });

  it("toolbar click mutates the controlled value through onChange", () => {
    render(<Harness initial="hello" />);
    const ta = screen.getByPlaceholderText("probe-placeholder") as HTMLTextAreaElement;
    ta.setSelectionRange(0, 5);
    fireEvent.click(screen.getByTitle("Bold"));
    expect(ta.value).toBe("**hello**");
  });

  it("typing into the textarea via React's synthetic onChange updates the value", () => {
    render(<Harness />);
    const ta = screen.getByPlaceholderText("probe-placeholder") as HTMLTextAreaElement;
    fireEvent.change(ta, { target: { value: "synthetic onChange" } });
    expect(ta.value).toBe("synthetic onChange");
  });

  it("forwards a ref to the underlying textarea", () => {
    const ref = { current: null as HTMLTextAreaElement | null };
    function Wrapper() {
      const [v, setV] = useState("");
      return (
        <MarkdownEditor
          ref={ref}
          value={v}
          onChange={setV}
          placeholder="probe"
        />
      );
    }
    render(<Wrapper />);
    expect(ref.current).toBeInstanceOf(HTMLTextAreaElement);
  });

  it("renders the toolbar buttons inside the wrapper", () => {
    render(<Harness />);
    const ta = screen.getByPlaceholderText("probe-placeholder");
    const wrapper = ta.closest("div.rounded-md.border.border-input")!;
    expect(wrapper).not.toBeNull();
    expect(wrapper.querySelector("button[title='Bold']")).not.toBeNull();
    expect(wrapper.querySelector("button[title='Heading 2']")).not.toBeNull();
    expect(wrapper.querySelector("button[title='Bullet list']")).not.toBeNull();
  });

  it("toolbar onUpdate and textarea onChange both route through the same callback", () => {
    const onChange = vi.fn();
    render(
      <MarkdownEditor
        value=""
        onChange={onChange}
        placeholder="probe"
      />,
    );
    const ta = screen.getByPlaceholderText("probe") as HTMLTextAreaElement;
    // Textarea path
    fireEvent.change(ta, { target: { value: "x" } });
    expect(onChange).toHaveBeenLastCalledWith("x");
    // Toolbar path — bold on empty selection inserts the wrapper marks
    ta.setSelectionRange(0, 0);
    fireEvent.click(screen.getByTitle("Bold"));
    expect(onChange).toHaveBeenLastCalledWith("****");
  });
});
