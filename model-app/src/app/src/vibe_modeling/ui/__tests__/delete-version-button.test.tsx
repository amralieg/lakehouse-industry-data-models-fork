/**
 * Tests for the `DeleteVersionButton` on the model-version page.
 *
 * Covers:
 *   - renders "Delete this version" button when current version is the
 *     latest of its scope
 *   - click opens AlertDialog with warning panel
 *   - no prior version → no reinstall checkbox
 *   - prior version + uc_catalog → checkbox visible, defaults unchecked
 *   - prior version + no uc_catalog (import-only) → checkbox HIDDEN
 *   - submit without checkbox → calls deleteVersion(...) with
 *     `reinstall_previous: false`
 *   - submit with checkbox → calls deleteVersion(...) with
 *     `reinstall_previous: true`
 *   - failure → toast.error + dialog stays open
 *   - success → toast.success + sidebar list invalidated + navigate to
 *     explorer
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const navigateMock = vi.fn();
const deleteVersionMock = vi.fn();
const toastSuccessMock = vi.fn();
const toastErrorMock = vi.fn();

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    deleteVersion: (...args: unknown[]) => deleteVersionMock(...args),
  };
});

vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return {
    ...actual,
    useNavigate: () => navigateMock,
    Link: ({ children, ...props }: any) => <a {...props}>{children}</a>,
  };
});

vi.mock("sonner", () => ({
  toast: {
    success: (...args: unknown[]) => toastSuccessMock(...args),
    error: (...args: unknown[]) => toastErrorMock(...args),
  },
}));

const notifyErrorMock = vi.fn();
vi.mock("@/lib/notify", () => ({
  notifyError: (...args: unknown[]) => notifyErrorMock(...args),
}));

import { DeleteVersionButton } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.index";

function makeClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000 },
      mutations: { retry: false },
    },
  });
}

function renderButton(
  overrides: Partial<React.ComponentProps<typeof DeleteVersionButton>> = {},
) {
  const props: React.ComponentProps<typeof DeleteVersionButton> = {
    businessId: "biz-1",
    businessName: "Test Biz",
    version: "2",
    scope: "ecm",
    versions: [
      { id: "v-2", version: 2, scope: "ecm", status: "completed" },
      { id: "v-1", version: 1, scope: "ecm", status: "completed" },
    ],
    currentVersionId: "v-2",
    currentUcCatalog: "cat_a",
    ...overrides,
  };
  return render(
    <QueryClientProvider client={makeClient()}>
      <DeleteVersionButton {...props} />
    </QueryClientProvider>,
  );
}

beforeEach(() => {
  navigateMock.mockReset();
  deleteVersionMock.mockReset();
  toastSuccessMock.mockReset();
  toastErrorMock.mockReset();
  notifyErrorMock.mockReset();
});

afterEach(() => {
  vi.clearAllMocks();
});

describe("DeleteVersionButton", () => {
  it("renders the 'Delete this version' button", () => {
    renderButton();
    expect(
      screen.getByRole("button", { name: /Delete this version/i }),
    ).toBeInTheDocument();
  });

  it("does not render when the current version is not the latest of its scope", () => {
    renderButton({
      version: "1",
      currentVersionId: "v-1",
    });
    expect(
      screen.queryByRole("button", { name: /Delete this version/i }),
    ).toBeNull();
  });

  it("opens the dialog with the warning panel on click", async () => {
    renderButton();
    fireEvent.click(
      screen.getByRole("button", { name: /Delete this version/i }),
    );
    await waitFor(() => {
      expect(
        screen.getByRole("alertdialog", { name: /Delete v2 ECM of Test Biz/i }),
      ).toBeInTheDocument();
    });
    // Warning copy about cascade content.
    expect(
      screen.getByText(/permanently delete this version's domains/i),
    ).toBeInTheDocument();
  });

  it("hides the reinstall checkbox when there is no prior version", async () => {
    renderButton({
      versions: [
        { id: "v-2", version: 2, scope: "ecm", status: "completed" },
      ],
    });
    fireEvent.click(
      screen.getByRole("button", { name: /Delete this version/i }),
    );
    await waitFor(() => {
      expect(screen.getByRole("alertdialog")).toBeInTheDocument();
    });
    expect(screen.queryByRole("checkbox")).toBeNull();
  });

  it("hides the reinstall checkbox when the current version has no uc_catalog", async () => {
    renderButton({ currentUcCatalog: "" });
    fireEvent.click(
      screen.getByRole("button", { name: /Delete this version/i }),
    );
    await waitFor(() => {
      expect(screen.getByRole("alertdialog")).toBeInTheDocument();
    });
    expect(screen.queryByRole("checkbox")).toBeNull();
  });

  it("shows an unchecked reinstall checkbox when previous + uc_catalog present", async () => {
    renderButton();
    fireEvent.click(
      screen.getByRole("button", { name: /Delete this version/i }),
    );
    const checkbox = await screen.findByRole("checkbox");
    expect(checkbox).toBeInTheDocument();
    expect(checkbox).toHaveAttribute("aria-checked", "false");
    expect(
      screen.getByText(/Re-install v1 ECM as the current deployed version/i),
    ).toBeInTheDocument();
  });

  it("submits without reinstall_previous when the checkbox is unchecked", async () => {
    deleteVersionMock.mockResolvedValue({
      data: { deleted_version: 2, message: "ok" },
    });
    renderButton();
    fireEvent.click(
      screen.getByRole("button", { name: /Delete this version/i }),
    );
    const confirm = await screen.findByRole("button", { name: /^Delete$/i });
    fireEvent.click(confirm);
    await waitFor(() => {
      expect(deleteVersionMock).toHaveBeenCalledTimes(1);
    });
    expect(deleteVersionMock).toHaveBeenCalledWith({
      business_id: "biz-1",
      version_id: "v-2",
      reinstall_previous: false,
    });
  });

  it("submits with reinstall_previous=true when the checkbox is checked", async () => {
    deleteVersionMock.mockResolvedValue({
      data: { deleted_version: 2, message: "ok" },
    });
    renderButton();
    fireEvent.click(
      screen.getByRole("button", { name: /Delete this version/i }),
    );
    const checkbox = await screen.findByRole("checkbox");
    fireEvent.click(checkbox);
    const confirm = await screen.findByRole("button", { name: /^Delete$/i });
    fireEvent.click(confirm);
    await waitFor(() => {
      expect(deleteVersionMock).toHaveBeenCalledTimes(1);
    });
    expect(deleteVersionMock).toHaveBeenCalledWith({
      business_id: "biz-1",
      version_id: "v-2",
      reinstall_previous: true,
    });
  });

  it("surfaces failures via toast.error and keeps the dialog open", async () => {
    deleteVersionMock.mockRejectedValue(new Error("boom"));
    renderButton();
    fireEvent.click(
      screen.getByRole("button", { name: /Delete this version/i }),
    );
    const confirm = await screen.findByRole("button", { name: /^Delete$/i });
    fireEvent.click(confirm);
    await waitFor(() => {
      expect(notifyErrorMock).toHaveBeenCalled();
    });
    expect(notifyErrorMock.mock.calls[0][0]).toMatchObject({ message: expect.stringMatching(/boom/) });
    expect(notifyErrorMock.mock.calls[0][1]).toEqual({ title: "Delete failed" });
    // Dialog still open.
    expect(screen.getByRole("alertdialog")).toBeInTheDocument();
    expect(navigateMock).not.toHaveBeenCalled();
  });

  it("on success: toast + navigate to explorer", async () => {
    deleteVersionMock.mockResolvedValue({
      data: { deleted_version: 2, message: "Deleted version 2" },
    });
    renderButton();
    fireEvent.click(
      screen.getByRole("button", { name: /Delete this version/i }),
    );
    const confirm = await screen.findByRole("button", { name: /^Delete$/i });
    fireEvent.click(confirm);
    await waitFor(() => {
      expect(toastSuccessMock).toHaveBeenCalledWith("Version deleted");
    });
    expect(navigateMock).toHaveBeenCalledWith({
      to: "/businesses/$businessId/explorer",
      params: { businessId: "biz-1" },
    });
  });
});
