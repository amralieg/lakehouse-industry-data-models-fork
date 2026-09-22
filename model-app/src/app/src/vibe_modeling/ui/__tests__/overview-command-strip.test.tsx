/**
 * Command-strip tests — the compact row that replaces the old "Actions on …"
 * and "Runs for this version" cards. Covers the lifecycle-action logic that
 * moved out of ActionsCard (enable/disable by deployment status, deferred
 * createRun behind the confirm dialog) plus the new run-status summary that
 * replaces the runs card.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, screen, waitFor } from "@testing-library/react";
import { toast } from "sonner";

let runsData: unknown[] = [];

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    createRun: vi.fn(),
    // CommandStrip subscribes to the version's runs for its status summary.
    useListRunsForVersion: () => ({ data: runsData }),
  };
});

vi.mock("sonner", async () => {
  const actual = await vi.importActual<typeof import("sonner")>("sonner");
  return {
    ...actual,
    toast: { ...actual.toast, warning: vi.fn() },
  };
});

import { createRun } from "@/lib/api";
import { CommandStrip } from "@/components/overview/command-strip";
import { renderWithRouter } from "./helpers/router-wrapper";

const mockedCreateRun = vi.mocked(createRun);

function renderStrip(deploymentStatus: string, scope = "mvm") {
  return renderWithRouter(
    <CommandStrip
      businessId="b1"
      versionId="v-abc"
      versionNum={3}
      scope={scope}
      deploymentStatus={deploymentStatus}
    />,
  );
}

describe("CommandStrip — lifecycle actions", () => {
  beforeEach(() => {
    mockedCreateRun.mockReset();
    vi.mocked(toast.warning).mockClear();
    runsData = [];
  });
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("replaces the Actions + Runs cards with one strip", async () => {
    renderStrip("draft");
    expect(await screen.findByTestId("overview-command-strip")).toBeInTheDocument();
  });

  it("enables Install but disables Uninstall + Generate samples on a draft version", async () => {
    renderStrip("draft");
    const install = await screen.findByRole("button", { name: /^Install$/ });
    expect(install).not.toBeDisabled();
    expect(screen.getByRole("button", { name: /^Uninstall$/ })).toBeDisabled();
    expect(screen.getByRole("button", { name: /Generate samples/ })).toBeDisabled();
  });

  it("enables all three actions once the version is deployed", async () => {
    renderStrip("deployed");
    expect(
      await screen.findByRole("button", { name: /Re-install/ }),
    ).not.toBeDisabled();
    expect(screen.getByRole("button", { name: /^Uninstall$/ })).not.toBeDisabled();
    expect(
      screen.getByRole("button", { name: /Generate samples/ }),
    ).not.toBeDisabled();
  });

  it("defers createRun until the confirm dialog's Launch is clicked", async () => {
    mockedCreateRun.mockResolvedValueOnce({
      data: { id: "run-42" },
    } as Awaited<ReturnType<typeof createRun>>);
    renderStrip("draft");

    const install = await screen.findByRole("button", { name: /^Install$/ });
    await act(async () => {
      fireEvent.click(install);
    });
    expect(await screen.findByRole("alertdialog")).toBeInTheDocument();
    expect(mockedCreateRun).not.toHaveBeenCalled();

    const launch = await screen.findByRole("button", { name: /^Launch$/ });
    await act(async () => {
      fireEvent.click(launch);
    });
    await waitFor(() => expect(mockedCreateRun).toHaveBeenCalledTimes(1));
    expect(mockedCreateRun).toHaveBeenCalledWith(
      { business_id: "b1" },
      { intent: "install", version_id: "v-abc" },
    );
  });

  it("surfaces a create-run warning (e.g. re-install clash) as a toast", async () => {
    mockedCreateRun.mockResolvedValueOnce({
      data: {
        id: "run-43",
        warnings: [
          {
            field_path: "version_id",
            message:
              "This version is already recorded as deployed to test_catalog; " +
              "re-installing without uninstalling first will fail the agent's clash check.",
            severity: "warning",
          },
        ],
      },
    } as unknown as Awaited<ReturnType<typeof createRun>>);
    renderStrip("deployed");

    const install = await screen.findByRole("button", { name: /Re-install/ });
    await act(async () => {
      fireEvent.click(install);
    });
    const launch = await screen.findByRole("button", { name: /^Launch$/ });
    await act(async () => {
      fireEvent.click(launch);
    });

    await waitFor(() =>
      expect(toast.warning).toHaveBeenCalledWith(
        "This version is already recorded as deployed to test_catalog; " +
          "re-installing without uninstalling first will fail the agent's clash check.",
      ),
    );
  });

  it("does not toast when the create-run response has no warnings", async () => {
    mockedCreateRun.mockResolvedValueOnce({
      data: { id: "run-44", warnings: [] },
    } as unknown as Awaited<ReturnType<typeof createRun>>);
    renderStrip("draft");

    const install = await screen.findByRole("button", { name: /^Install$/ });
    await act(async () => {
      fireEvent.click(install);
    });
    const launch = await screen.findByRole("button", { name: /^Launch$/ });
    await act(async () => {
      fireEvent.click(launch);
    });

    await waitFor(() => expect(mockedCreateRun).toHaveBeenCalledTimes(1));
    expect(toast.warning).not.toHaveBeenCalled();
  });

  it("shows the ECM-only 'Prepare new Vibe' entry on ECM, hides it on MVM", async () => {
    const { unmount } = renderStrip("draft", "ecm");
    expect(
      await screen.findByTestId("prepare-new-vibe"),
    ).toBeInTheDocument();
    unmount();

    renderStrip("draft", "mvm");
    expect(
      screen.queryByTestId("prepare-new-vibe"),
    ).not.toBeInTheDocument();
  });
});

describe("CommandStrip — run status summary", () => {
  beforeEach(() => {
    runsData = [];
  });

  it("shows 'No runs yet' with no runs", async () => {
    runsData = [];
    renderStrip("draft");
    expect(await screen.findByText(/No runs yet/)).toBeInTheDocument();
  });

  it("summarises the run count when runs exist", async () => {
    runsData = [
      { id: "r2", business_id: "b1", status: "completed", created_at: new Date().toISOString() },
      { id: "r1", business_id: "b1", status: "completed", created_at: new Date().toISOString() },
    ];
    renderStrip("draft");
    expect(await screen.findByText("2")).toBeInTheDocument();
    expect(screen.getByText(/runs/)).toBeInTheDocument();
  });

  it("shows the Installed badge only when deployed", async () => {
    renderStrip("deployed");
    expect(await screen.findByText("Installed")).toBeInTheDocument();
  });
});
