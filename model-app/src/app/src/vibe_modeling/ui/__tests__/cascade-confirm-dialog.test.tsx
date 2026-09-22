/**
 * `<CascadeConfirmDialog/>` (T4) — the cascade confirmation gate.
 * Asserts the scope copy ("this will mark N items") renders, and that
 * `onConfirm` fires ONLY on the confirm action — never on cancel/dismiss.
 */
import { describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import { ReviewState } from "@/lib/api";
import { CascadeConfirmDialog } from "@/components/review/cascade-confirm-dialog";

function renderDialog(props: Partial<React.ComponentProps<typeof CascadeConfirmDialog>> = {}) {
  const onConfirm = vi.fn();
  const onOpenChange = vi.fn();
  render(
    <CascadeConfirmDialog
      open
      onOpenChange={onOpenChange}
      scopeLabel="domain"
      scopeName="Sales"
      itemCount={7}
      state={ReviewState.reviewed}
      onConfirm={onConfirm}
      {...props}
    />,
  );
  return { onConfirm, onOpenChange };
}

describe("CascadeConfirmDialog", () => {
  it("surfaces the scope (N items) and the target name", () => {
    renderDialog();
    // "7 products" appears in both the warning copy and the confirm button;
    // assert the warning copy (a <strong>) specifically.
    expect(screen.getByText("7 products")).toBeInTheDocument();
    expect(screen.getByText("Sales")).toBeInTheDocument();
  });

  it("calls onConfirm only when the confirm action is pressed", () => {
    const { onConfirm } = renderDialog();
    expect(onConfirm).not.toHaveBeenCalled();
    fireEvent.click(screen.getByRole("button", { name: /mark 7 products/i }));
    expect(onConfirm).toHaveBeenCalledTimes(1);
  });

  it("does NOT call onConfirm when cancelled", () => {
    const { onConfirm, onOpenChange } = renderDialog();
    fireEvent.click(screen.getByRole("button", { name: /cancel/i }));
    expect(onConfirm).not.toHaveBeenCalled();
    // Cancel still closes the dialog via onOpenChange(false).
    expect(onOpenChange).toHaveBeenCalledWith(false);
  });

  it("singularizes the noun for a one-item cascade", () => {
    renderDialog({ itemCount: 1 });
    // Warning copy uses the singular noun (the <strong>).
    expect(screen.getByText("1 product")).toBeInTheDocument();
    expect(screen.queryByText("1 products")).not.toBeInTheDocument();
  });

  it("disables confirm + cancel while pending", () => {
    renderDialog({ pending: true });
    expect(screen.getByRole("button", { name: /marking/i })).toBeDisabled();
    expect(screen.getByRole("button", { name: /cancel/i })).toBeDisabled();
  });
});
