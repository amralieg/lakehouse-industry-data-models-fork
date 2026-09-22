/**
 * `ArtifactCatalogPanel` tests — Story 5 (industry-artifact-import).
 *
 * The panel renders PURELY off `ModelPreviewOut.artifacts` (no fetch), so we
 * mount it directly with prop fixtures. We assert the two per-row states:
 *   1. found            — a known type with a matching `ModelArtifact`.
 *   2. not-found-known  — a known type with no artifact; "Locate in source".
 * Plus the tier-gate: when capabilities omit every side-artifact target_kind,
 * the panel degrades to the "unavailable" line.
 */
import { describe, expect, it, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { ArtifactCatalogPanel } from "@/components/source-explorer/artifact-catalog-panel";
import type { ModelArtifact, SourceCapabilities } from "@/lib/api";

function artifact(over: Partial<ModelArtifact>): ModelArtifact {
  return {
    name: "x",
    path: "x",
    target_kind: "schemas",
    ...over,
  };
}

describe("ArtifactCatalogPanel", () => {
  it("renders a found row with the artifact path and a not-found row with Locate", () => {
    const artifacts: ModelArtifact[] = [
      artifact({ target_kind: "schemas", path: "schemas/orders.json", name: "orders" }),
    ];
    const onLocate = vi.fn();
    render(<ArtifactCatalogPanel artifacts={artifacts} onLocate={onLocate} />);

    // found: schemas shows its path
    expect(screen.getByText("schemas/orders.json")).toBeInTheDocument();

    // not-found-known: metrics has no artifact -> Locate button present
    const locateButtons = screen.getAllByText("Locate in source");
    expect(locateButtons.length).toBeGreaterThan(0);
    fireEvent.click(locateButtons[0]);
    expect(onLocate).toHaveBeenCalled();
  });

  it("never renders a 'samples/' or '_manifest.json' row - the source never ships them", () => {
    render(<ArtifactCatalogPanel artifacts={[]} />);
    expect(screen.queryByText("samples/")).not.toBeInTheDocument();
    expect(screen.queryByText("_manifest.json")).not.toBeInTheDocument();
    expect(screen.queryByText("not shipped")).not.toBeInTheDocument();
  });

  it("survives re-render across the detection supported<->unsupported boundary (Rules of Hooks)", () => {
    // Locks the hook-order regression: every useMemo must run unconditionally
    // on every render. If a hook sits below the detectionUnsupported early
    // return, React throws "Rendered fewer/more hooks than expected" when
    // capabilities flip between renders on the SAME component instance.
    const unsupported: SourceCapabilities = {
      discovery_mode: "lazy",
      materialization_timing: "on_demand",
      provides_sectors: true,
      source_kind: "github",
      target_kinds: ["model_json"],
    };
    const supported: SourceCapabilities = {
      ...unsupported,
      target_kinds: ["model_json", "schemas"],
    };

    const { rerender } = render(
      <ArtifactCatalogPanel artifacts={[]} capabilities={supported} />,
    );
    expect(screen.getByText("Schemas")).toBeInTheDocument();

    // flip to unsupported on the same instance
    rerender(<ArtifactCatalogPanel artifacts={[]} capabilities={unsupported} />);
    expect(
      screen.getByText("Artifact detection unavailable for this source tier."),
    ).toBeInTheDocument();

    // flip back to supported on the same instance
    rerender(<ArtifactCatalogPanel artifacts={[]} capabilities={supported} />);
    expect(screen.getByText("Schemas")).toBeInTheDocument();
  });

  it("degrades to unavailable when the source tier supports no side artifacts", () => {
    render(
      <ArtifactCatalogPanel
        artifacts={[]}
        capabilities={{
          discovery_mode: "lazy",
          materialization_timing: "on_demand",
          provides_sectors: true,
          source_kind: "github",
          target_kinds: ["model_json"],
        }}
      />,
    );
    expect(
      screen.getByText("Artifact detection unavailable for this source tier."),
    ).toBeInTheDocument();
    expect(screen.queryByText("Schemas")).not.toBeInTheDocument();
  });
});
