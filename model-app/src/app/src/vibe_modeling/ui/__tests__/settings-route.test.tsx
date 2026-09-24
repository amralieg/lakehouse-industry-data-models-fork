/**
 * `AgentConfigSection` page-tree test — the bug-2 site itself.
 *
 * Phase 4.5 bug 2 (PR #151): two siblings each subscribed to
 * `useGetAgentConfig` and re-rendered each other indefinitely on a 404.
 * The fix made `MetamodelCatalogField` take props instead of
 * subscribing.
 *
 * This test mounts the full `AgentConfigSection` tree with a 404-stubbed
 * `/api/config/agent` and asserts:
 *  - The form mounts (no infinite-loop fallback).
 *  - Render count stays bounded.
 *  - No `validateDOMNesting` warnings.
 *
 * If anyone re-introduces a second subscriber to the same query, the
 * render-count assertion blows up immediately.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor, fireEvent } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { StrictMode } from "react";

import { AgentConfigSection, DiagramSettingsSection } from "@/routes/_sidebar/settings";
import { firstRunFetcher } from "./helpers/first-run";
import { useStrictConsole } from "./helpers/strict-console";
import { createRenderCounter, RenderCounted } from "./helpers/render-counter";

afterEach(() => {
  vi.restoreAllMocks();
  vi.unstubAllGlobals();
});

function makeClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000 },
      mutations: { retry: false },
    },
  });
}

describe("AgentConfigSection (Phase 4.5 bug-2 site)", () => {
  const dom = useStrictConsole();

  it("mounts the form with the agent unconfigured (404 on /api/config/agent)", async () => {
    vi.stubGlobal("fetch", firstRunFetcher());
    const qc = makeClient();

    render(
      <QueryClientProvider client={qc}>
        <AgentConfigSection />
      </QueryClientProvider>,
    );

    await waitFor(() => {
      expect(screen.getByText(/Agent Configuration/i)).toBeInTheDocument();
    });
    expect(screen.getByText(/Notebook Path/i)).toBeInTheDocument();
    // Metamodel catalog moved to the Platform tab (MetamodelCatalogCard) in
    // 0.6.6; the Agent section no longer renders it.
    expect(dom.messages).toEqual([]);
  });

  it("renders finitely under 404 — no dual-subscriber render loop", async () => {
    vi.stubGlobal("fetch", firstRunFetcher());
    const qc = makeClient();
    // Bound is generous: StrictMode ×2 + multiple effect transitions
    // (config loads, agentReady loads, supported-version loads). The
    // pre-fix bug produced 100+ renders/sec — any finite bound trips it.
    const counter = createRenderCounter("AgentConfigSection", 24);

    render(
      <StrictMode>
        <QueryClientProvider client={qc}>
          <RenderCounted counter={counter}>
            <AgentConfigSection />
          </RenderCounted>
        </QueryClientProvider>
      </StrictMode>,
    );

    await waitFor(() => {
      expect(screen.getByText(/Agent Configuration/i)).toBeInTheDocument();
    });
    // Settle window — give the query layer time to fully resolve so any
    // runaway re-render would be observable.
    await new Promise((r) => setTimeout(r, 250));
    expect(counter.count).toBeLessThanOrEqual(counter.max);
  });

  it("hydrates form from a successful config load without DOM warnings", async () => {
    // api.ts wraps the response in { data: ... } itself, so the fixture
    // body is the raw config object.
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/config/agent": {
          status: 200,
          body: {
            notebook_path: "/Workspace/Users/me/agent",
            deployment_catalog: "vibe_modeling",
            job_id: 12345,
            job_name: "vibe-modelling-agent",
            updated_at: "2026-04-01T00:00:00Z",
          },
        },
      }),
    );
    const qc = makeClient();

    render(
      <QueryClientProvider client={qc}>
        <AgentConfigSection />
      </QueryClientProvider>,
    );

    await waitFor(() => {
      expect(
        screen.getByDisplayValue("/Workspace/Users/me/agent"),
      ).toBeInTheDocument();
    });
    // The metamodel catalog is no longer part of this section (moved to the
    // Platform tab); only the notebook path hydrates here.
    expect(dom.messages).toEqual([]);
  });

  it("renders the Concurrent runs input with min=3 and the inline help text", async () => {
    vi.stubGlobal("fetch", firstRunFetcher());
    const qc = makeClient();

    render(
      <QueryClientProvider client={qc}>
        <AgentConfigSection />
      </QueryClientProvider>,
    );

    await waitFor(() => {
      expect(screen.getByLabelText(/Concurrent runs/i)).toBeInTheDocument();
    });
    const input = screen.getByLabelText(
      /Concurrent runs/i,
    ) as HTMLInputElement;
    expect(input.type).toBe("number");
    expect(input.min).toBe("3");
    // Inline help references both the floor and the rationale.
    expect(
      screen.getByText(/unified-pipeline phase transition/i),
    ).toBeInTheDocument();
    expect(
      screen.getByText(/cancel-with-rollback cleanup overlaps/i),
    ).toBeInTheDocument();
  });

  it("hydrates max_concurrent_runs from the loaded config", async () => {
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/config/agent": {
          status: 200,
          body: {
            notebook_path: "/Workspace/Users/me/agent",
            deployment_catalog: "vibe_modeling",
            job_id: 12345,
            job_name: "vibe-modelling-agent",
            max_concurrent_runs: 7,
            updated_at: "2026-04-01T00:00:00Z",
          },
        },
      }),
    );
    const qc = makeClient();

    render(
      <QueryClientProvider client={qc}>
        <AgentConfigSection />
      </QueryClientProvider>,
    );

    await waitFor(() => {
      expect(
        screen.getByDisplayValue("/Workspace/Users/me/agent"),
      ).toBeInTheDocument();
    });
    const input = screen.getByLabelText(
      /Concurrent runs/i,
    ) as HTMLInputElement;
    expect(input.value).toBe("7");
  });

  it("rejects sub-3 values on Save with an inline error and does not call the API", async () => {
    // Stub /api/config/agent with a saved row so the form is in
    // "config-loaded" mode (Save is enabled when dirty). Track POST/PUT
    // hits separately so we can assert the API was not invoked.
    // NB: the check-notebook endpoint includes "/api/config/agent" as a
    // substring; route it explicitly so our PUT-spy handler doesn't also
    // intercept the GET check-notebook calls fired on blur.
    const putSpy = vi.fn();
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/config/agent/check-notebook": {
          status: 200,
          body: { ok: true, version: "v0.7.1" },
        },
        "/api/config/agent": (url: string, init?: RequestInit) => {
          if (init && (init.method === "PUT" || init.method === "POST")) {
            putSpy(url, init);
            return Promise.resolve({
              ok: true,
              status: 200,
              json: async () => ({}),
            });
          }
          return Promise.resolve({
            ok: true,
            status: 200,
            json: async () => ({
              notebook_path: "/Workspace/Users/me/agent",
              deployment_catalog: "vibe_modeling",
              job_id: 12345,
              job_name: "vibe-modelling-agent",
              max_concurrent_runs: 5,
              updated_at: "2026-04-01T00:00:00Z",
            }),
          });
        },
      }),
    );
    const qc = makeClient();

    render(
      <QueryClientProvider client={qc}>
        <AgentConfigSection />
      </QueryClientProvider>,
    );

    const input = (await screen.findByLabelText(
      /Concurrent runs/i,
    )) as HTMLInputElement;
    // Wait until the form is hydrated (input reflects the loaded 5).
    await waitFor(() => expect(input.value).toBe("5"));

    // Set value below the floor.
    fireEvent.change(input, { target: { value: "2" } });
    await waitFor(() => expect(input.value).toBe("2"));

    // Submit by dispatching the form's submit event directly. jsdom does
    // not run HTML5 native validation before custom submit handlers, so
    // our React onSubmit runs and the inline error path fires.
    const form = input.closest("form")!;
    fireEvent.submit(form);

    // Inline error appears mentioning the floor.
    await waitFor(() => {
      expect(
        screen.getByText(/Concurrent runs must be at least 3/i),
      ).toBeInTheDocument();
    });
    // The mutation should NOT have fired.
    expect(putSpy).not.toHaveBeenCalled();
  });
});

describe("AgentConfigSection — collect vibe run statistics toggle", () => {
  const dom = useStrictConsole();

  it("renders the toggle unchecked by default with the hover-tip text", async () => {
    vi.stubGlobal("fetch", firstRunFetcher());
    const qc = makeClient();

    render(
      <QueryClientProvider client={qc}>
        <AgentConfigSection />
      </QueryClientProvider>,
    );

    const toggle = (await screen.findByLabelText(
      /Collect vibe run statistics/i,
    )) as HTMLInputElement;
    expect(toggle.type).toBe("checkbox");
    expect(toggle.checked).toBe(false);
    // Tooltip body opens on hover (Radix portal). Open it and assert
    // the exact spec wording.
    fireEvent.pointerEnter(toggle);
    fireEvent.focus(toggle);
    await waitFor(() => {
      // Multiple matches possible — Radix mirrors the content for screen
      // readers. Use getAllByText so any of them satisfies the assertion.
      expect(
        screen.getAllByText(
          /Anonymous usage statistics for product improvement\. No sensitive information is collected\./,
        ).length,
      ).toBeGreaterThan(0);
    });
    expect(dom.messages).toEqual([]);
  });

  it("hydrates the toggle from the loaded config", async () => {
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/config/agent": {
          status: 200,
          body: {
            notebook_path: "/Workspace/Users/me/agent",
            deployment_catalog: "vibe_modeling",
            job_id: 12345,
            job_name: "vibe-modelling-agent",
            max_concurrent_runs: 5,
            collect_vibe_run_statistics: true,
            updated_at: "2026-04-01T00:00:00Z",
          },
        },
      }),
    );
    const qc = makeClient();

    render(
      <QueryClientProvider client={qc}>
        <AgentConfigSection />
      </QueryClientProvider>,
    );

    const toggle = (await screen.findByLabelText(
      /Collect vibe run statistics/i,
    )) as HTMLInputElement;
    await waitFor(() => expect(toggle.checked).toBe(true));
  });

  it("includes collect_vibe_run_statistics in the PUT payload on Save", async () => {
    const putSpy = vi.fn();
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/config/agent/check-notebook": {
          status: 200,
          body: { ok: true, version: "v0.7.1" },
        },
        "/api/config/agent": (url: string, init?: RequestInit) => {
          if (init && (init.method === "PUT" || init.method === "POST")) {
            putSpy(url, init);
            return Promise.resolve({
              ok: true,
              status: 200,
              json: async () => ({}),
            });
          }
          return Promise.resolve({
            ok: true,
            status: 200,
            json: async () => ({
              notebook_path: "/Workspace/Users/me/agent",
              deployment_catalog: "vibe_modeling",
              job_id: 12345,
              job_name: "vibe-modelling-agent",
              max_concurrent_runs: 5,
              collect_vibe_run_statistics: false,
              updated_at: "2026-04-01T00:00:00Z",
            }),
          });
        },
      }),
    );
    const qc = makeClient();

    render(
      <QueryClientProvider client={qc}>
        <AgentConfigSection />
      </QueryClientProvider>,
    );

    const toggle = (await screen.findByLabelText(
      /Collect vibe run statistics/i,
    )) as HTMLInputElement;
    await waitFor(() => expect(toggle.checked).toBe(false));

    fireEvent.click(toggle);
    await waitFor(() => expect(toggle.checked).toBe(true));

    const form = toggle.closest("form")!;
    fireEvent.submit(form);

    await waitFor(() => expect(putSpy).toHaveBeenCalled());
    const [, init] = putSpy.mock.calls[0];
    const body = JSON.parse(init.body as string);
    expect(body.collect_vibe_run_statistics).toBe(true);
  });
});

describe("DiagramSettingsSection - column-mode preference (item 4, 0.6.6)", () => {
  it("renders two selects defaulting to hide (all-domains) / keys (single-domain) when unset", async () => {
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/user/preferences": { status: 200, body: [] },
      }),
    );
    const qc = makeClient();

    render(
      <QueryClientProvider client={qc}>
        <DiagramSettingsSection />
      </QueryClientProvider>,
    );

    await waitFor(() => {
      expect(screen.getByText(/Default columns - all-domains view/i)).toBeInTheDocument();
    });
    expect(screen.getByText(/Default columns - single-domain view/i)).toBeInTheDocument();
    const comboboxes = screen.getAllByRole("combobox");
    expect(comboboxes).toHaveLength(2);
    expect(comboboxes[0]).toHaveTextContent("Hide columns");
    expect(comboboxes[1]).toHaveTextContent("Keys only");
  });

  it("seeds from a stored preference when one exists", async () => {
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/user/preferences": {
          status: 200,
          body: [
            { key: "diagram.default_column_mode", value: "all", updated_at: "2026-07-01T00:00:00Z" },
            { key: "diagram.default_column_mode_focal", value: "hide", updated_at: "2026-07-01T00:00:00Z" },
          ],
        },
      }),
    );
    const qc = makeClient();

    render(
      <QueryClientProvider client={qc}>
        <DiagramSettingsSection />
      </QueryClientProvider>,
    );

    await waitFor(() => {
      const comboboxes = screen.getAllByRole("combobox");
      expect(comboboxes[0]).toHaveTextContent("All columns");
      expect(comboboxes[1]).toHaveTextContent("Hide columns");
    });
  });

  it("calls setUserPreference with the all-domains key on change", async () => {
    const putSpy = vi.fn();
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/user/preferences/diagram.default_column_mode": (url: string, init?: RequestInit) => {
          putSpy(url, init);
          return Promise.resolve({
            ok: true,
            status: 200,
            json: async () => ({ key: "diagram.default_column_mode", value: "all", updated_at: "2026-07-01T00:00:00Z" }),
          });
        },
        "/api/user/preferences": { status: 200, body: [] },
      }),
    );
    const qc = makeClient();

    render(
      <QueryClientProvider client={qc}>
        <DiagramSettingsSection />
      </QueryClientProvider>,
    );

    const comboboxes = await screen.findAllByRole("combobox");
    fireEvent.click(comboboxes[0]);
    fireEvent.click(await screen.findByText("All columns"));

    await waitFor(() => expect(putSpy).toHaveBeenCalled());
    const [url, init] = putSpy.mock.calls[0];
    expect(url).toContain("/api/user/preferences/diagram.default_column_mode");
    expect(JSON.parse(init.body as string)).toEqual({ value: "all" });
  });

  it("calls setUserPreference with the focal key on change", async () => {
    const putSpy = vi.fn();
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/user/preferences/diagram.default_column_mode_focal": (url: string, init?: RequestInit) => {
          putSpy(url, init);
          return Promise.resolve({
            ok: true,
            status: 200,
            json: async () => ({ key: "diagram.default_column_mode_focal", value: "hide", updated_at: "2026-07-01T00:00:00Z" }),
          });
        },
        "/api/user/preferences": { status: 200, body: [] },
      }),
    );
    const qc = makeClient();

    render(
      <QueryClientProvider client={qc}>
        <DiagramSettingsSection />
      </QueryClientProvider>,
    );

    const comboboxes = await screen.findAllByRole("combobox");
    fireEvent.click(comboboxes[1]);
    const options = await screen.findAllByRole("option", { name: "Hide columns" });
    fireEvent.click(options[0]);

    await waitFor(() => expect(putSpy).toHaveBeenCalled());
    const [url, init] = putSpy.mock.calls[0];
    expect(url).toContain("/api/user/preferences/diagram.default_column_mode_focal");
    expect(JSON.parse(init.body as string)).toEqual({ value: "hide" });
  });
});
