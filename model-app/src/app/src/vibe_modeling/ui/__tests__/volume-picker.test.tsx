/**
 * VolumePicker — drill from catalogs into a `.json` file and Select it.
 *
 * Fetch is mocked at the `global.fetch` level (drain-banner.test.tsx pattern).
 * The picker hits `GET /api/uc/volumes/browse?path=<p>`; we route per path
 * so tests can simulate the four UC levels deterministically.
 */

import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor, fireEvent } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

import { VolumePicker, childPathFor } from "@/components/import/volume-picker";

type Entry = {
  name: string;
  is_dir: boolean;
  kind: string;
  size_bytes: number | null;
  modified_at: string | null;
};

type Reply = { path: string; parent: string | null; entries: Entry[]; truncated: boolean };

let routes: Record<string, Reply> = {};

function buildRoutes(): Record<string, Reply> {
  return {
    "": {
      path: "",
      parent: null,
      entries: [
        { name: "main", is_dir: true, kind: "catalog", size_bytes: null, modified_at: null },
        { name: "dev", is_dir: true, kind: "catalog", size_bytes: null, modified_at: null },
      ],
      truncated: false,
    },
    "/main": {
      path: "/main",
      parent: "",
      entries: [
        { name: "retail", is_dir: true, kind: "schema", size_bytes: null, modified_at: null },
      ],
      truncated: false,
    },
    "/main/retail": {
      path: "/main/retail",
      parent: "/main",
      entries: [
        { name: "vibes", is_dir: true, kind: "volume", size_bytes: null, modified_at: null },
      ],
      truncated: false,
    },
    "/Volumes/main/retail/vibes": {
      path: "/Volumes/main/retail/vibes",
      parent: "/main/retail",
      entries: [
        { name: "sub", is_dir: true, kind: "dir", size_bytes: null, modified_at: null },
        { name: "model.json", is_dir: false, kind: "file", size_bytes: 4096, modified_at: "2026-05-01T12:00:00Z" },
        { name: "notes.txt", is_dir: false, kind: "file", size_bytes: 100, modified_at: "2026-05-01T12:00:00Z" },
      ],
      truncated: false,
    },
  };
}

beforeEach(() => {
  routes = buildRoutes();
  // @ts-expect-error happy path
  global.fetch = vi.fn(async (input: string | URL) => {
    const url = typeof input === "string" ? input : input.toString();
    const m = url.match(/\/api\/uc\/volumes\/browse\?path=(.*)$/);
    if (!m) {
      return new Response(JSON.stringify({ detail: "wrong url" }), { status: 404 });
    }
    const path = decodeURIComponent(m[1]);
    const reply = routes[path];
    if (!reply) {
      return new Response(JSON.stringify({ detail: "not seeded" }), { status: 404 });
    }
    return new Response(JSON.stringify(reply), {
      status: 200,
      headers: { "content-type": "application/json" },
    });
  });
});

afterEach(() => {
  vi.restoreAllMocks();
});

function renderPicker(overrides?: {
  onSelect?: (p: string) => void;
  onOpenChange?: (o: boolean) => void;
  open?: boolean;
}) {
  const onSelect = overrides?.onSelect ?? vi.fn();
  const onOpenChange = overrides?.onOpenChange ?? vi.fn();
  const open = overrides?.open ?? true;
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false, refetchOnWindowFocus: false } },
  });
  const utils = render(
    <QueryClientProvider client={qc}>
      <VolumePicker open={open} onOpenChange={onOpenChange} onSelect={onSelect} />
    </QueryClientProvider>,
  );
  return { ...utils, onSelect, onOpenChange };
}

describe("VolumePicker", () => {
  it("renders the initial catalog list", async () => {
    renderPicker();
    await waitFor(() => {
      expect(screen.getByText("main")).toBeInTheDocument();
      expect(screen.getByText("dev")).toBeInTheDocument();
    });
    // Title visible
    expect(screen.getByText(/Browse Unity Catalog Volumes/i)).toBeInTheDocument();
  });

  it("drills into folders and updates the breadcrumb", async () => {
    renderPicker();
    // Wait for catalogs
    await waitFor(() => expect(screen.getByText("main")).toBeInTheDocument());

    fireEvent.click(screen.getByText("main"));
    await waitFor(() => expect(screen.getByText("retail")).toBeInTheDocument());

    // Breadcrumb shows catalogs > main
    const breadcrumb = screen.getByText("Catalogs").parentElement!;
    expect(breadcrumb.textContent).toContain("Catalogs");
    expect(breadcrumb.textContent).toContain("main");

    fireEvent.click(screen.getByText("retail"));
    await waitFor(() => expect(screen.getByText("vibes")).toBeInTheDocument());

    fireEvent.click(screen.getByText("vibes"));
    await waitFor(() => expect(screen.getByText("model.json")).toBeInTheDocument());
  });

  it("only .json files are selectable — Select disabled until one is clicked", async () => {
    renderPicker();
    // Drill all the way down to a volume directory.
    await waitFor(() => expect(screen.getByText("main")).toBeInTheDocument());
    fireEvent.click(screen.getByText("main"));
    await waitFor(() => expect(screen.getByText("retail")).toBeInTheDocument());
    fireEvent.click(screen.getByText("retail"));
    await waitFor(() => expect(screen.getByText("vibes")).toBeInTheDocument());
    fireEvent.click(screen.getByText("vibes"));
    await waitFor(() => expect(screen.getByText("model.json")).toBeInTheDocument());

    // Select button initially disabled.
    const selectBtn = screen.getByRole("button", { name: /^Select$/ });
    expect(selectBtn).toBeDisabled();

    // notes.txt's row button is disabled (non-json files are not pickable).
    const notesBtn = screen.getByText("notes.txt").closest("button")!;
    expect(notesBtn).toBeDisabled();

    // Click model.json — Select becomes enabled.
    fireEvent.click(screen.getByText("model.json"));
    await waitFor(() => expect(selectBtn).not.toBeDisabled());
  });

  it("onSelect fires with the full /Volumes/ path", async () => {
    const onSelect = vi.fn();
    renderPicker({ onSelect });

    await waitFor(() => expect(screen.getByText("main")).toBeInTheDocument());
    fireEvent.click(screen.getByText("main"));
    await waitFor(() => expect(screen.getByText("retail")).toBeInTheDocument());
    fireEvent.click(screen.getByText("retail"));
    await waitFor(() => expect(screen.getByText("vibes")).toBeInTheDocument());
    fireEvent.click(screen.getByText("vibes"));
    await waitFor(() => expect(screen.getByText("model.json")).toBeInTheDocument());

    fireEvent.click(screen.getByText("model.json"));
    fireEvent.click(screen.getByRole("button", { name: /^Select$/ }));

    expect(onSelect).toHaveBeenCalledWith("/Volumes/main/retail/vibes/model.json");
  });

  it("Cancel closes without calling onSelect", async () => {
    const onSelect = vi.fn();
    const onOpenChange = vi.fn();
    renderPicker({ onSelect, onOpenChange });

    await waitFor(() => expect(screen.getByText("main")).toBeInTheDocument());
    fireEvent.click(screen.getByRole("button", { name: /Cancel/i }));

    expect(onSelect).not.toHaveBeenCalled();
    expect(onOpenChange).toHaveBeenCalledWith(false);
  });
});

describe("childPathFor (path composition)", () => {
  it("composes catalog name from root", () => {
    expect(
      childPathFor("", {
        name: "main",
        is_dir: true,
        kind: "catalog",
        size_bytes: null,
        modified_at: null,
      }),
    ).toBe("/main");
  });

  it("composes schema under catalog", () => {
    expect(
      childPathFor("/main", {
        name: "retail",
        is_dir: true,
        kind: "schema",
        size_bytes: null,
        modified_at: null,
      }),
    ).toBe("/main/retail");
  });

  it("transitions to /Volumes/ form when entering a volume", () => {
    expect(
      childPathFor("/main/retail", {
        name: "vibes",
        is_dir: true,
        kind: "volume",
        size_bytes: null,
        modified_at: null,
      }),
    ).toBe("/Volumes/main/retail/vibes");
  });

  it("appends subdirectories inside a volume", () => {
    expect(
      childPathFor("/Volumes/main/retail/vibes", {
        name: "sub",
        is_dir: true,
        kind: "dir",
        size_bytes: null,
        modified_at: null,
      }),
    ).toBe("/Volumes/main/retail/vibes/sub");
  });
});
