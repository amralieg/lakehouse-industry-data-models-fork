/**
 * `<PrioritySelect/>` - the shared high/medium/low control extracted from the
 * feedback dialog (Track 8 item 1) so create/edit/compose sites can't drift.
 */
import { describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import { PrioritySelect } from "@/components/vibe-inputs/priority-select";
import { VibeInputPriority } from "@/lib/api";

describe("PrioritySelect", () => {
  it("renders the three priority options", () => {
    render(<PrioritySelect value={VibeInputPriority.medium} onValueChange={vi.fn()} />);
    fireEvent.click(screen.getByLabelText("Priority"));
    expect(screen.getByRole("option", { name: "High" })).toBeInTheDocument();
    expect(screen.getByRole("option", { name: "Medium" })).toBeInTheDocument();
    expect(screen.getByRole("option", { name: "Low" })).toBeInTheDocument();
  });

  it("fires onValueChange with the selected priority", () => {
    const onValueChange = vi.fn();
    render(<PrioritySelect value={VibeInputPriority.medium} onValueChange={onValueChange} />);
    fireEvent.click(screen.getByLabelText("Priority"));
    fireEvent.click(screen.getByRole("option", { name: "Low" }));
    expect(onValueChange).toHaveBeenCalledWith("low");
  });
});
