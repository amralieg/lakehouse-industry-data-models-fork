/**
 * PublishVersionDialog tests (Story 10 / Track D).
 *
 * Covers the three load-bearing behaviours of the publish action:
 *   1. PRE-CHECK: the trigger is disabled (with a Settings link in its
 *      tooltip) when the GitHub config has no `connection_name`.
 *   2. 422 DEGRADE: a `github_connection_missing` / `github_pat_not_implemented`
 *      422 surfaces a clean Settings link inline rather than a raw error.
 *   3. SUCCESS: a successful publish renders the PR link + number + branch.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, screen, waitFor } from "@testing-library/react";

let githubConfig: { connection_name: string } = { connection_name: "" };

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    // selector() unwraps the { data } envelope, so the hook returns the
    // config object directly under `data`.
    useGetGithubConfig: () => ({ data: githubConfig }),
    usePublishModelVersion: vi.fn(),
    usePreviewPublishModelVersion: vi.fn(),
  };
});

import {
  ApiError,
  usePreviewPublishModelVersion,
  usePublishModelVersion,
  type PublishPreviewOut,
} from "@/lib/api";
import { PublishVersionDialog } from "@/components/overview/publish-version-dialog";
import { renderWithRouter } from "./helpers/router-wrapper";

const mockedUsePublish = vi.mocked(usePublishModelVersion);
const mockedUsePreview = vi.mocked(usePreviewPublishModelVersion);

/** Default the preview hook to a no-op resolving mutation so the publish-only
 * tests don't have to wire it. Individual preview tests override this. */
function stubPreview(
  result: PublishPreviewOut | null = null,
  { reject = false }: { reject?: boolean } = {},
) {
  const mutateAsync = vi.fn(() =>
    reject
      ? Promise.reject(new ApiError(500, "Internal", { detail: "boom" }))
      : Promise.resolve({ data: result }),
  );
  mockedUsePreview.mockReturnValue({
    mutateAsync,
    isPending: false,
  } as unknown as ReturnType<typeof usePreviewPublishModelVersion>);
  return mutateAsync;
}

function mountPublish(mutateAsync = vi.fn(), defaultTargetPath?: string) {
  mockedUsePublish.mockReturnValue({
    mutateAsync,
    isPending: false,
  } as unknown as ReturnType<typeof usePublishModelVersion>);
  if (!mockedUsePreview.getMockImplementation()) stubPreview();
  return renderWithRouter(
    <PublishVersionDialog
      businessId="b1"
      versionId="v-abc"
      versionNum={3}
      scope="mvm"
      defaultTargetPath={defaultTargetPath}
    />,
  );
}

async function openConfirmBody() {
  const btn = await screen.findByTestId("publish-version");
  await act(async () => {
    fireEvent.click(btn);
  });
  return screen.findByTestId("publish-version-confirm");
}

describe("PublishVersionDialog", () => {
  beforeEach(() => {
    mockedUsePublish.mockReset();
    mockedUsePreview.mockReset();
    githubConfig = { connection_name: "" };
  });
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("disables Publish with a Settings link when no connection_name is set", async () => {
    githubConfig = { connection_name: "" };
    mountPublish();

    const btn = await screen.findByTestId("publish-version");
    expect(btn).toBeDisabled();
    // Tooltip content links to the GitHub settings tab. Radix renders tooltip
    // content lazily on hover; the wrapper span exposes it.
    expect(screen.getByTestId("publish-version-disabled")).toBeInTheDocument();
  });

  it("enables Publish once a connection_name exists", async () => {
    githubConfig = { connection_name: "gh_oauth" };
    mountPublish();

    const btn = await screen.findByTestId("publish-version");
    expect(btn).not.toBeDisabled();
  });

  it("degrades a 422 github_connection_missing into a Settings link", async () => {
    githubConfig = { connection_name: "gh_oauth" };
    const mutateAsync = vi
      .fn()
      .mockRejectedValueOnce(
        new ApiError(422, "Unprocessable Entity", {
          detail: { error: "github_connection_missing" },
        }),
      );
    mountPublish(mutateAsync);

    const btn = await screen.findByTestId("publish-version");
    await act(async () => {
      fireEvent.click(btn);
    });
    const confirm = await screen.findByTestId("publish-version-confirm");
    await act(async () => {
      fireEvent.click(confirm);
    });

    const degraded = await screen.findByTestId("publish-version-degraded");
    expect(degraded).toBeInTheDocument();
    expect(
      screen.getByRole("link", { name: /Open GitHub settings/ }),
    ).toBeInTheDocument();
    // Degraded path must NOT show a raw error banner.
    expect(
      screen.queryByTestId("publish-version-error"),
    ).not.toBeInTheDocument();
  });

  it("renders the PR link, number, and branch on a successful publish", async () => {
    githubConfig = { connection_name: "gh_oauth" };
    const mutateAsync = vi.fn().mockResolvedValueOnce({
      data: {
        branch: "publish/v3-mvm",
        pr_number: 42,
        pr_url: "https://github.com/owner/repo/pull/42",
        files: ["models/m.json", "docs/README.md"],
      },
    });
    mountPublish(mutateAsync);

    const btn = await screen.findByTestId("publish-version");
    await act(async () => {
      fireEvent.click(btn);
    });
    const confirm = await screen.findByTestId("publish-version-confirm");
    await act(async () => {
      fireEvent.click(confirm);
    });

    await waitFor(() =>
      expect(screen.getByTestId("publish-version-success")).toBeInTheDocument(),
    );
    const prLink = screen.getByRole("link", { name: /PR #42 opened/ });
    expect(prLink).toHaveAttribute(
      "href",
      "https://github.com/owner/repo/pull/42",
    );
    expect(screen.getByText("publish/v3-mvm")).toBeInTheDocument();
    expect(screen.getByText("models/m.json")).toBeInTheDocument();
    expect(mutateAsync).toHaveBeenCalledWith({
      params: { business_id: "b1", version_id: "v-abc" },
      data: { target_path: undefined },
    });
  });

  it("pre-fills the target-path input from defaultTargetPath", async () => {
    githubConfig = { connection_name: "gh_oauth" };
    mountPublish(vi.fn(), "caps/ecm_v3");
    await openConfirmBody();
    const input = screen.getByTestId("publish-target-path") as HTMLInputElement;
    expect(input.value).toBe("caps/ecm_v3");
  });

  it("starts blank when no defaultTargetPath is provided", async () => {
    githubConfig = { connection_name: "gh_oauth" };
    mountPublish(vi.fn());
    await openConfirmBody();
    const input = screen.getByTestId("publish-target-path") as HTMLInputElement;
    expect(input.value).toBe("");
  });

  it("posts the edited target path", async () => {
    githubConfig = { connection_name: "gh_oauth" };
    const mutateAsync = vi.fn().mockResolvedValueOnce({
      data: {
        branch: "b",
        pr_number: 1,
        pr_url: "u",
        files: [],
        target_path: "edited/dir_v9",
      },
    });
    mountPublish(mutateAsync, "caps/ecm_v3");
    const confirm = await openConfirmBody();
    const input = screen.getByTestId("publish-target-path");
    await act(async () => {
      fireEvent.change(input, { target: { value: "edited/dir_v9" } });
    });
    await act(async () => {
      fireEvent.click(confirm);
    });
    expect(mutateAsync).toHaveBeenCalledWith({
      params: { business_id: "b1", version_id: "v-abc" },
      data: { target_path: "edited/dir_v9" },
    });
  });

  it("omits target_path when the input is cleared", async () => {
    githubConfig = { connection_name: "gh_oauth" };
    const mutateAsync = vi.fn().mockResolvedValueOnce({
      data: {
        branch: "b",
        pr_number: 1,
        pr_url: "u",
        files: [],
        target_path: "test_retail/mvm_v3",
      },
    });
    mountPublish(mutateAsync, "caps/ecm_v3");
    const confirm = await openConfirmBody();
    const input = screen.getByTestId("publish-target-path");
    await act(async () => {
      fireEvent.change(input, { target: { value: "   " } });
    });
    await act(async () => {
      fireEvent.click(confirm);
    });
    expect(mutateAsync).toHaveBeenCalledWith({
      params: { business_id: "b1", version_id: "v-abc" },
      data: { target_path: undefined },
    });
  });
});

// ---------------------------------------------------------------------------
// Prepublish diff-preview (Story 3)
// ---------------------------------------------------------------------------

const TIER1_PREVIEW: PublishPreviewOut = {
  baseline: { model_id: "ecm_v2", industry_id: "caps", scope: "ecm", version: "v2" },
  tier: "same_scope_latest",
  scope_mismatch: false,
  manual_needed: false,
  candidates: [],
  diff: {
    domains: [],
    products: [{ domain: "sales", product: "order", attribute: null, status: "modified" }],
    attributes: [{ domain: "sales", product: "order", attribute: "total", status: "new" }],
    counts: { new: 1, modified: 1, deleted: 0 },
  },
};

async function openDialog() {
  const btn = await screen.findByTestId("publish-version");
  await act(async () => {
    fireEvent.click(btn);
  });
}

describe("PublishVersionDialog — preview", () => {
  beforeEach(() => {
    mockedUsePublish.mockReset();
    mockedUsePreview.mockReset();
    githubConfig = { connection_name: "gh_oauth" };
  });
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("renders a baseline indicator and NO warning chip for same_scope_latest", async () => {
    stubPreview(TIER1_PREVIEW);
    mountPublish();
    await openDialog();
    await waitFor(() =>
      expect(screen.getByTestId("preview-baseline")).toBeInTheDocument(),
    );
    expect(screen.getByTestId("preview-baseline")).toHaveTextContent("ecm_v2");
    expect(screen.queryByTestId("preview-warning")).not.toBeInTheDocument();
  });

  it("renders a warning chip for fallback_unverified", async () => {
    stubPreview({ ...TIER1_PREVIEW, tier: "fallback_unverified" });
    mountPublish();
    await openDialog();
    await waitFor(() =>
      expect(screen.getByTestId("preview-warning")).toBeInTheDocument(),
    );
  });

  it("renders a warning chip when scope_mismatch is true (any tier)", async () => {
    stubPreview({ ...TIER1_PREVIEW, scope_mismatch: true });
    mountPublish();
    await openDialog();
    await waitFor(() =>
      expect(screen.getByTestId("preview-warning")).toBeInTheDocument(),
    );
  });

  it("renders manual-pick candidates and a skip affordance when manual_needed", async () => {
    stubPreview({
      baseline: null,
      tier: "none",
      scope_mismatch: false,
      manual_needed: true,
      candidates: [
        { model_id: "ecm_v1", name: "Ecm V1", scope: "ecm", version: "v1" },
      ],
      diff: null,
    });
    mountPublish();
    await openDialog();
    await waitFor(() =>
      expect(screen.getByTestId("preview-manual")).toBeInTheDocument(),
    );
    expect(screen.getByTestId("preview-skip")).toBeInTheDocument();
    expect(screen.getByText("Ecm V1")).toBeInTheDocument();
  });

  it("renders diff rows using the shared ChangeBadge + row class", async () => {
    stubPreview(TIER1_PREVIEW);
    mountPublish();
    await openDialog();
    const diff = await screen.findByTestId("preview-diff");
    // The flattened rows render the FQN path; the shared ChangeBadge tints the
    // row via changeRowClassName ("bg-success/5" for a new element).
    expect(diff).toHaveTextContent("sales / order / total");
    expect(diff.querySelector(".bg-success\\/5")).not.toBeNull();
  });

  it("renders the all-unchanged zero-diff empty-state by counts==0 (NOT manual)", async () => {
    stubPreview({
      ...TIER1_PREVIEW,
      diff: {
        domains: [],
        products: [],
        attributes: [],
        counts: { new: 0, modified: 0, deleted: 0 },
      },
    });
    mountPublish();
    await openDialog();
    await waitFor(() =>
      expect(screen.getByTestId("preview-no-changes")).toBeInTheDocument(),
    );
    // Distinct from the manual-needed render.
    expect(screen.queryByTestId("preview-manual")).not.toBeInTheDocument();
  });

  it("keeps the Publish confirm button ENABLED when preview errors (degrade-open)", async () => {
    stubPreview(null, { reject: true });
    mountPublish();
    await openDialog();
    const confirm = await screen.findByTestId("publish-version-confirm");
    // Even after the preview error settles, confirm is not disabled.
    await waitFor(() =>
      expect(screen.getByTestId("preview-error")).toBeInTheDocument(),
    );
    expect(confirm).not.toBeDisabled();
  });

  it("fetches the preview lazily — only after the dialog opens", async () => {
    const previewFn = stubPreview(TIER1_PREVIEW);
    mountPublish(vi.fn(), "caps/ecm_v3");
    // Not called on mount.
    expect(previewFn).not.toHaveBeenCalled();
    await openDialog();
    await waitFor(() => expect(previewFn).toHaveBeenCalled());
    expect(previewFn).toHaveBeenCalledWith({
      params: { business_id: "b1", version_id: "v-abc" },
      data: { target_path: "caps/ecm_v3", baseline_model_id: undefined },
    });
  });
});
