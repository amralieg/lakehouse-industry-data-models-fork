import { describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen } from "@testing-library/react";

import { LaunchRunDialog } from "@/components/runs/launch-run-dialog";

function setup(overrides: Partial<React.ComponentProps<typeof LaunchRunDialog>> = {}) {
  const onConfirm = vi.fn();
  const onCancel = vi.fn();
  const utils = render(
    <LaunchRunDialog
      open
      operationType="install model"
      businessName="Acme Retail"
      versionLabel="v3"
      onConfirm={onConfirm}
      onCancel={onCancel}
      {...overrides}
    />,
  );
  return { ...utils, onConfirm, onCancel };
}

describe("LaunchRunDialog", () => {
  it("renders metadata for the given operation", () => {
    setup();
    // Title
    expect(screen.getByRole("alertdialog")).toBeInTheDocument();
    expect(screen.getByText("Launch run?")).toBeInTheDocument();
    // Operation label from OPERATION_METADATA["install model"]
    expect(screen.getByText("Install model")).toBeInTheDocument();
    // Business name
    expect(screen.getByText("Acme Retail")).toBeInTheDocument();
    // Source version label (rendered when provided)
    expect(screen.getByText("Source version")).toBeInTheDocument();
    expect(screen.getByText("v3")).toBeInTheDocument();
    // SWAG fields removed
    expect(screen.queryByText("Expected duration")).not.toBeInTheDocument();
    expect(screen.queryByText(/Compute cost/)).not.toBeInTheDocument();
    // Honest compute + tokens warning
    expect(
      screen.getByText(/Databricks compute and LLM tokens/i),
    ).toBeInTheDocument();
  });

  it("invokes onConfirm when Launch is clicked", () => {
    const { onConfirm, onCancel } = setup();
    act(() => {
      fireEvent.click(screen.getByRole("button", { name: /^Launch$/ }));
    });
    expect(onConfirm).toHaveBeenCalledTimes(1);
    expect(onCancel).not.toHaveBeenCalled();
  });

  it("invokes onCancel when Cancel is clicked", () => {
    const { onConfirm, onCancel } = setup();
    act(() => {
      fireEvent.click(screen.getByRole("button", { name: /^Cancel$/ }));
    });
    expect(onCancel).toHaveBeenCalled();
    expect(onConfirm).not.toHaveBeenCalled();
  });

  it("invokes onCancel when Escape is pressed", () => {
    const { onConfirm, onCancel } = setup();
    act(() => {
      fireEvent.keyDown(document.activeElement ?? document.body, {
        key: "Escape",
        code: "Escape",
      });
    });
    expect(onCancel).toHaveBeenCalled();
    expect(onConfirm).not.toHaveBeenCalled();
  });

  it("disables both buttons and swaps the Launch label while submitting", () => {
    setup({ submitting: true });
    const launch = screen.getByRole("button", { name: /Starting/ });
    expect(launch).toBeDisabled();
    expect(screen.getByRole("button", { name: /^Cancel$/ })).toBeDisabled();
  });

});
