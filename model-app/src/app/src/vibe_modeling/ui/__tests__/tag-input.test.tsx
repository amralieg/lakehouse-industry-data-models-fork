import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { useState } from "react";
import { TagInput } from "@/components/ui/tag-input";

function Harness({
  initial = [],
  onSubmit,
}: {
  initial?: string[];
  onSubmit?: (e: React.FormEvent) => void;
}) {
  const [value, setValue] = useState<string[]>(initial);
  return (
    <form data-testid="harness-form" onSubmit={onSubmit ?? ((e) => e.preventDefault())}>
      <TagInput value={value} onChange={setValue} placeholder="Type a tag" />
      <button type="submit">Submit</button>
    </form>
  );
}

describe("TagInput Enter-key behavior (#130)", () => {
  it("commits tag on Enter when draft is non-empty, does not submit form", () => {
    const onSubmit = vi.fn();
    render(<Harness onSubmit={onSubmit} />);
    const input = screen.getByPlaceholderText("Type a tag") as HTMLInputElement;
    fireEvent.change(input, { target: { value: "marketing" } });
    fireEvent.keyDown(input, { key: "Enter" });
    // Tag appears in the DOM and form was NOT submitted
    expect(screen.getByText("marketing")).toBeInTheDocument();
    expect(onSubmit).not.toHaveBeenCalled();
  });

  it("does NOT submit form when Enter pressed on empty draft (prior regression)", () => {
    const onSubmit = vi.fn();
    render(<Harness onSubmit={onSubmit} />);
    const input = screen.getByPlaceholderText("Type a tag") as HTMLInputElement;
    fireEvent.keyDown(input, { key: "Enter" });
    expect(onSubmit).not.toHaveBeenCalled();
  });

  it("does NOT submit form when Enter pressed on whitespace-only draft", () => {
    const onSubmit = vi.fn();
    render(<Harness onSubmit={onSubmit} />);
    const input = screen.getByPlaceholderText("Type a tag") as HTMLInputElement;
    fireEvent.change(input, { target: { value: "   " } });
    fireEvent.keyDown(input, { key: "Enter" });
    expect(onSubmit).not.toHaveBeenCalled();
  });

  it("comma also commits and does not submit", () => {
    const onSubmit = vi.fn();
    render(<Harness onSubmit={onSubmit} />);
    const input = screen.getByPlaceholderText("Type a tag") as HTMLInputElement;
    fireEvent.change(input, { target: { value: "sales" } });
    fireEvent.keyDown(input, { key: "," });
    expect(screen.getByText("sales")).toBeInTheDocument();
    expect(onSubmit).not.toHaveBeenCalled();
  });

  it("Backspace on empty draft removes last tag", () => {
    const { container } = render(<Harness initial={["alpha", "beta"]} />);
    // Placeholder is suppressed when value has tags, so select the tag input by role.
    const input = container.querySelector('input') as HTMLInputElement;
    expect(screen.getByText("beta")).toBeInTheDocument();
    fireEvent.keyDown(input, { key: "Backspace" });
    expect(screen.queryByText("beta")).not.toBeInTheDocument();
    expect(screen.getByText("alpha")).toBeInTheDocument();
  });
});
