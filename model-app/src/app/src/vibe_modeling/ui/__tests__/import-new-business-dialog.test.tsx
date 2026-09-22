/**
 * Story-1 coverage: ``ImportNewBusinessDialog``.
 *
 * Volume-picker → analyze → digest confirmation → create. The dialog
 * uses TanStack Router's ``useNavigate`` on success; wrap in a tiny
 * memory router so the hook resolves.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";
import type { ReactNode } from "react";

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    analyzeImportRoot: vi.fn(),
    createBusinessAndExecuteImport: vi.fn(),
    getImportPreview: vi.fn(),
  };
});

vi.mock("sonner", () => ({
  toast: { error: vi.fn(), success: vi.fn(), warning: vi.fn(), info: vi.fn() },
}));

import { toast } from "sonner";
import {
  analyzeImportRoot,
  createBusinessAndExecuteImport,
  getImportPreview,
  ApiError,
} from "@/lib/api";
import { ImportNewBusinessDialog } from "@/components/import/import-new-business-dialog";

const mockedAnalyze = vi.mocked(analyzeImportRoot);
const mockedCreate = vi.mocked(createBusinessAndExecuteImport);
const mockedPreview = vi.mocked(getImportPreview);

const PREVIEW_FOUND = {
  data: {
    model_json_found: true,
    next_vibes_status: "txt",
    next_vibes_path: "/V/vibes/next_vibes.txt",
    companion_artifacts: [],
    total_artifact_count: 0,
  },
} as unknown as Awaited<ReturnType<typeof getImportPreview>>;

function makeRouter(ui: ReactNode) {
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const indexRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/",
    component: () => <>{ui}</>,
  });
  const explorerRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/explorer",
    component: () => <div data-testid="explorer-stub" />,
  });
  return createRouter({
    routeTree: rootRoute.addChildren([indexRoute, explorerRoute]),
    history: createMemoryHistory({ initialEntries: ["/"] }),
  });
}

function wrap(ui: ReactNode) {
  const qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });
  const router = makeRouter(ui);
  return (
    <QueryClientProvider client={qc}>
      <RouterProvider router={router as any} />
    </QueryClientProvider>
  );
}

beforeEach(() => {
  mockedAnalyze.mockReset();
  mockedCreate.mockReset();
  mockedPreview.mockReset();
  mockedPreview.mockResolvedValue(PREVIEW_FOUND);
});

afterEach(() => {
  vi.restoreAllMocks();
});

describe("ImportNewBusinessDialog", () => {
  it("pre-fills the form from the digest and submits the create call", async () => {
    mockedAnalyze.mockResolvedValue({
      data: {
        valid: true,
        message: "Detected 3 domains, 7 tables.",
        domain_count: 3,
        product_count: 7,
        attribute_count: 20,
        fk_count: 4,
        warnings: [],
        action: "import_as_is",
        inferred_version: "v1_ecm",
        business_digest: {
          business_name: "Quantum Co",
          industry_alignment: "Quantum Computing",
          description: "A quantum business",
          business_vibes: "## Detailed\nAssembled draft of the business.",
          agent_version: "27",
          core_business_processes: "qubits",
          orgnaization_divisions: "lab",
          common_business_jargons: "decoherence",
          operational_systems_of_records: "JIRA",
          industry_governing_body: "NIST",
          industry_will_be_created: true,
        },
      },
    } as unknown as Awaited<ReturnType<typeof analyzeImportRoot>>);
    mockedCreate.mockResolvedValue({
      data: {
        business_id: "biz-99",
        version_id: "v-1",
        version: 1,
        domains: 3,
        products: 7,
        attributes: 20,
        fk_links: 4,
      },
    } as unknown as Awaited<ReturnType<typeof createBusinessAndExecuteImport>>);

    render(
      wrap(
        <ImportNewBusinessDialog
          trigger={<button type="button">Open new biz import</button>}
        />,
      ),
    );

    fireEvent.click(
      await screen.findByRole("button", { name: /Open new biz import/i }),
    );
    const input = await screen.findByPlaceholderText(/\/Volumes\/catalog/);
    fireEvent.change(input, {
      target: { value: "/Volumes/cat/sch/vibes/model.json" },
    });
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /^Analyze$/i }));
    });

    // Dialog title matches the spec.
    expect(screen.getByText("Import a business")).toBeInTheDocument();

    // Digest fields pre-filled.
    const nameInput = await screen.findByDisplayValue("Quantum Co");
    expect(nameInput).toBeInTheDocument();
    // Industry combobox shows the typed/pre-filled value.
    expect(screen.getByText("Quantum Computing")).toBeInTheDocument();
    expect(screen.getByDisplayValue("A quantum business")).toBeInTheDocument();

    // Detailed-description (business_vibes) pre-filled via MarkdownEditor.
    expect(screen.getByTestId("business-vibes")).toHaveValue(
      "## Detailed\nAssembled draft of the business.",
    );

    // Agent version surfaced.
    expect(screen.getByTestId("agent-version-badge")).toHaveTextContent(
      "agent v27",
    );

    // industry_will_be_created note rendered.
    expect(
      screen.getByTestId("industry-will-be-created-note"),
    ).toBeInTheDocument();

    // Business context fields are NOT displayed in the dialog — they
    // belong to BusinessContext (per-run input), not Business identity.
    // Backend still seeds BusinessContext from the digest; dialog
    // intentionally hides them to keep create-business focused on the
    // three identity fields only.
    expect(screen.queryByText(/qubits/)).not.toBeInTheDocument();
    expect(screen.queryByText(/decoherence/)).not.toBeInTheDocument();

    const submit = screen.getByRole("button", {
      name: /Create business and import/i,
    });
    expect(submit).not.toBeDisabled();
    await act(async () => {
      fireEvent.click(submit);
    });

    await waitFor(() => {
      expect(mockedCreate).toHaveBeenCalledWith({
        volume_path: "/Volumes/cat/sch/vibes/model.json",
        business_name_override: "Quantum Co",
        industry_alignment_override: "Quantum Computing",
        description_override: "A quantum business",
        business_vibes_override: "## Detailed\nAssembled draft of the business.",
      });
    });
  });

  it("disables submit when the digest has no business_name and the user clears the field", async () => {
    mockedAnalyze.mockResolvedValue({
      data: {
        valid: true,
        message: "ok",
        domain_count: 0,
        product_count: 0,
        attribute_count: 0,
        fk_count: 0,
        warnings: [],
        action: "import_as_is",
        inferred_version: "v1_ecm",
        business_digest: {
          business_name: "Acme",
          industry_alignment: "",
          description: "Imported business description so the form is submittable",
          core_business_processes: "",
          orgnaization_divisions: "",
          common_business_jargons: "",
          operational_systems_of_records: "",
          industry_governing_body: "",
          industry_will_be_created: false,
        },
      },
    } as unknown as Awaited<ReturnType<typeof analyzeImportRoot>>);

    render(
      wrap(
        <ImportNewBusinessDialog
          trigger={<button type="button">Open</button>}
        />,
      ),
    );

    fireEvent.click(
      await screen.findByRole("button", { name: /^Open$/i }),
    );
    fireEvent.change(
      await screen.findByPlaceholderText(/\/Volumes\/catalog/),
      { target: { value: "/Volumes/x/y/z.json" } },
    );
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /^Analyze$/i }));
    });

    const nameInput = await screen.findByDisplayValue("Acme");
    const submit = screen.getByRole("button", {
      name: /Create business and import/i,
    });
    expect(submit).not.toBeDisabled();

    // Clear the field — submit should disable.
    fireEvent.change(nameInput, { target: { value: "" } });
    expect(submit).toBeDisabled();
  });

  it("disables submit when the digest carries an empty description (v0.4.0 #6)", async () => {
    mockedAnalyze.mockResolvedValue({
      data: {
        valid: true,
        message: "ok",
        domain_count: 1,
        product_count: 1,
        attribute_count: 1,
        fk_count: 0,
        warnings: [],
        action: "import_as_is",
        inferred_version: "v1_ecm",
        business_digest: {
          business_name: "NoDesc Co",
          industry_alignment: "Retail",
          description: "",
          core_business_processes: "",
          orgnaization_divisions: "",
          common_business_jargons: "",
          operational_systems_of_records: "",
          industry_governing_body: "",
          industry_will_be_created: false,
        },
      },
    } as unknown as Awaited<ReturnType<typeof analyzeImportRoot>>);

    render(
      wrap(
        <ImportNewBusinessDialog
          trigger={<button type="button">Open import</button>}
        />,
      ),
    );

    fireEvent.click(
      await screen.findByRole("button", { name: /^Open import$/i }),
    );
    fireEvent.change(
      await screen.findByPlaceholderText(/\/Volumes\/catalog/),
      { target: { value: "/Volumes/x/y/z.json" } },
    );
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /^Analyze$/i }));
    });

    // Name pre-filled, description empty from digest → submit disabled.
    await screen.findByDisplayValue("NoDesc Co");
    const submit = screen.getByRole("button", {
      name: /Create business and import/i,
    });
    expect(submit).toBeDisabled();

    // Typing a summary unblocks submit (business_vibes is optional).
    const summaryTextarea = screen.getByPlaceholderText(
      /Short summary \(2000 chars max recommended\)/i,
    );
    fireEvent.change(summaryTextarea, {
      target: { value: "Typed description after import" },
    });
    expect(submit).not.toBeDisabled();
  });

  it("shows an inline name-conflict error and keeps dialog state on 409", async () => {
    mockedAnalyze.mockResolvedValue({
      data: {
        valid: true,
        message: "Schema is supported for importing.",
        domain_count: 2,
        product_count: 4,
        attribute_count: 10,
        fk_count: 1,
        warnings: [],
        action: "import_as_is",
        inferred_version: "v1_ecm",
        business_digest: {
          business_name: "Dup Co",
          industry_alignment: "Retail",
          description: "A business that already exists by name",
          business_vibes: "draft vibes",
          agent_version: "27",
          industry_will_be_created: false,
        },
      },
    } as unknown as Awaited<ReturnType<typeof analyzeImportRoot>>);

    mockedCreate.mockRejectedValue(
      new ApiError(409, "Conflict", {
        detail: {
          error: "business_already_exists",
          business_id: "biz-existing",
          business_name: "Dup Co",
          message: 'A business named "Dup Co" already exists — rename it or use the per-business import.',
        },
      }),
    );

    render(
      wrap(
        <ImportNewBusinessDialog
          trigger={<button type="button">Open dup import</button>}
        />,
      ),
    );

    fireEvent.click(
      await screen.findByRole("button", { name: /^Open dup import$/i }),
    );
    fireEvent.change(
      await screen.findByPlaceholderText(/\/Volumes\/catalog/),
      { target: { value: "/Volumes/x/y/z.json" } },
    );
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /^Analyze$/i }));
    });

    const nameInput = await screen.findByDisplayValue("Dup Co");
    const submit = screen.getByRole("button", {
      name: /Create business and import/i,
    });
    await act(async () => {
      fireEvent.click(submit);
    });

    // Inline conflict error shows; dialog stays open with state intact.
    const conflict = await screen.findByTestId("business-name-conflict");
    expect(conflict).toHaveTextContent(/already exists/i);
    expect(nameInput).toHaveValue("Dup Co");
    // No reset: digest fields still present, no general "Try again".
    expect(screen.getByDisplayValue("A business that already exists by name")).toBeInTheDocument();
    expect(
      screen.queryByRole("button", { name: /^Try again$/i }),
    ).not.toBeInTheDocument();

    // Editing the name clears the inline error.
    fireEvent.change(nameInput, { target: { value: "Dup Co Renamed" } });
    expect(
      screen.queryByTestId("business-name-conflict"),
    ).not.toBeInTheDocument();
  });

  it("routes a 422 config_missing through the shared renderer, not a generic banner", async () => {
    mockedAnalyze.mockResolvedValue({
      data: {
        valid: true,
        message: "Schema is supported for importing.",
        domain_count: 1,
        product_count: 2,
        attribute_count: 5,
        fk_count: 0,
        warnings: [],
        action: "import_as_is",
        inferred_version: "v1_ecm",
        business_digest: {
          business_name: "New Co",
          industry_alignment: "Retail",
          description: "A brand new business from import",
          business_vibes: "draft vibes",
          agent_version: "27",
          industry_will_be_created: true,
        },
      },
    } as unknown as Awaited<ReturnType<typeof analyzeImportRoot>>);
    mockedCreate.mockRejectedValue(
      new ApiError(422, "Unprocessable Entity", {
        detail: {
          error: "config_missing",
          missing: [
            {
              key: "metamodel_catalog",
              label: "Metamodel catalog",
              settings_url: "/settings?tab=platform",
            },
          ],
          message: "Finish setup before importing.",
        },
      }),
    );

    render(
      wrap(
        <ImportNewBusinessDialog
          trigger={<button type="button">Open new import</button>}
        />,
      ),
    );
    fireEvent.click(
      await screen.findByRole("button", { name: /^Open new import$/i }),
    );
    fireEvent.change(
      await screen.findByPlaceholderText(/\/Volumes\/catalog/),
      { target: { value: "/Volumes/x/y/z.json" } },
    );
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /^Analyze$/i }));
    });
    const submit = await screen.findByRole("button", {
      name: /Create business and import/i,
    });
    await act(async () => {
      fireEvent.click(submit);
    });

    // Shared config_missing renderer fires (toast); the generic inline error
    // banner does NOT render, and no "Try again" reset button appears.
    await waitFor(() => expect(toast.error).toHaveBeenCalledTimes(1));
    expect(screen.queryByText(/Finish setup before importing/i)).toBeNull();
    expect(
      screen.queryByRole("button", { name: /^Try again$/i }),
    ).not.toBeInTheDocument();
  });

  it("surfaces the missing-next-vibes preview warning (F5) and still allows create", async () => {
    mockedPreview.mockResolvedValue({
      data: {
        model_json_found: true,
        next_vibes_status: "missing",
        next_vibes_path: null,
        companion_artifacts: [],
        total_artifact_count: 0,
      },
    } as unknown as Awaited<ReturnType<typeof getImportPreview>>);
    mockedAnalyze.mockResolvedValue({
      data: {
        valid: true,
        message: "ok",
        domain_count: 1,
        product_count: 1,
        attribute_count: 1,
        fk_count: 0,
        warnings: [],
        action: "import_as_is",
        inferred_version: "v1_ecm",
        business_digest: {
          business_name: "Acme",
          industry_alignment: "Retail",
          description: "A business with a description",
          core_business_processes: "",
          orgnaization_divisions: "",
          common_business_jargons: "",
          operational_systems_of_records: "",
          industry_governing_body: "",
          industry_will_be_created: false,
        },
      },
    } as unknown as Awaited<ReturnType<typeof analyzeImportRoot>>);

    render(
      wrap(<ImportNewBusinessDialog trigger={<button type="button">Open</button>} />),
    );
    fireEvent.click(await screen.findByRole("button", { name: /^Open$/i }));
    fireEvent.change(
      await screen.findByPlaceholderText(/\/Volumes\/catalog/),
      { target: { value: "/Volumes/c/s/v/model.json" } },
    );

    // Preview warning appears before analysis.
    const warning = await screen.findByTestId(
      "preview-next-vibes-missing-warning",
    );
    expect(warning).toHaveTextContent(/cannot be reconstructed/);

    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /^Analyze$/i }));
    });
    await screen.findByDisplayValue("Acme");
    // Missing next_vibes does NOT block create.
    expect(
      screen.getByRole("button", { name: /Create business and import/i }),
    ).not.toBeDisabled();
  });

  it("disables the create button and shows a busy label while the create is pending (F4)", async () => {
    mockedAnalyze.mockResolvedValue({
      data: {
        valid: true,
        message: "ok",
        domain_count: 1,
        product_count: 1,
        attribute_count: 1,
        fk_count: 0,
        warnings: [],
        action: "import_as_is",
        inferred_version: "v1_ecm",
        business_digest: {
          business_name: "Acme",
          industry_alignment: "Retail",
          description: "A business with a description",
          core_business_processes: "",
          orgnaization_divisions: "",
          common_business_jargons: "",
          operational_systems_of_records: "",
          industry_governing_body: "",
          industry_will_be_created: false,
        },
      },
    } as unknown as Awaited<ReturnType<typeof analyzeImportRoot>>);
    // A create call that never resolves → mutation stays pending.
    let resolveCreate: (v: unknown) => void = () => {};
    mockedCreate.mockReturnValue(
      new Promise((res) => {
        resolveCreate = res;
      }) as unknown as ReturnType<typeof createBusinessAndExecuteImport>,
    );

    render(
      wrap(<ImportNewBusinessDialog trigger={<button type="button">Open</button>} />),
    );
    fireEvent.click(await screen.findByRole("button", { name: /^Open$/i }));
    fireEvent.change(
      await screen.findByPlaceholderText(/\/Volumes\/catalog/),
      { target: { value: "/Volumes/c/s/v/model.json" } },
    );
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /^Analyze$/i }));
    });
    await screen.findByDisplayValue("Acme");

    const submit = screen.getByRole("button", {
      name: /Create business and import/i,
    });
    await act(async () => {
      fireEvent.click(submit);
    });

    // Busy state: label changes + button disabled while pending.
    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: /Creating business/i }),
      ).toBeDisabled();
    });

    await act(async () => {
      resolveCreate({ data: { business_id: "b1", version_id: "v1", version: 1, domains: 1, products: 1, attributes: 1, fk_links: 0 } });
    });
  });
});
