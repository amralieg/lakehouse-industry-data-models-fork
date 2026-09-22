/**
 * Skeptical-tester pass for v0.7.1 fold POST-walkthrough fix Bug 2 — FE.
 *
 * SPEC_FIX1.md §Bug 2 (FE): when a ModelVersion's `sync_state !== 'ok'`,
 * the version detail page must render an Alert banner naming the
 * sync_error_text. When `sync_state === 'ok'`, no Alert renders.
 *
 * STUB-FOR-INTEGRATION: this test imports
 *   `@/components/versions/version-sync-state-banner` (or wherever the
 *   integrator places the component). On the pre-fold codebase the
 *   component does not exist and this file fails at module-resolve —
 *   that is the intended "red on main" signal for the skeptical pass.
 */

import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";

// The dev places this component anywhere they like, but the SPEC names
// `version.tsx` (or the equivalent TanStack route renderer). The
// banner should be a small focused component the route mounts above
// the model summary. We import the focused component, NOT the whole
// route — banner unit tests must stay surgical.
import { VersionSyncStateBanner } from "@/components/versions/version-sync-state-banner";

type MockVersion = {
  id: string;
  sync_state: string;
  sync_error_text: string | null;
  // Other fields the banner ignores; included so a future field-shape
  // tightening (Pick<...>) doesn't break the test fixtures.
  business_id: string;
  version: number;
  scope: string;
  status: string;
};

const baseVersion: MockVersion = {
  id: "v-abc",
  business_id: "biz-1",
  version: 2,
  scope: "ecm",
  status: "completed",
  sync_state: "ok",
  sync_error_text: null,
};

describe("VersionSyncStateBanner — sync_state surface", () => {
  it("renders the warning Alert when sync_state='incomplete_metadata'", () => {
    const version = {
      ...baseVersion,
      sync_state: "incomplete_metadata",
      sync_error_text: "schema apply failed: ApplySchemaError(catalog=...)",
    };

    render(<VersionSyncStateBanner version={version} />);

    // shadcn Alert renders with role="alert" by convention. Forgiving
    // matcher: either the role or the warning copy must surface.
    const alert = screen.queryByRole("alert");
    expect(alert).not.toBeNull();
    // The error text from the version row must be visible to the
    // operator — that's the whole point of surfacing this gap.
    expect(alert).toHaveTextContent("schema apply failed");
  });

  it("renders the warning Alert when sync_state='finalize_failed'", () => {
    const version = {
      ...baseVersion,
      sync_state: "finalize_failed",
      sync_error_text:
        "SQL error: [DELTA_CONCURRENT_APPEND.ROW_LEVEL_CHANGES]",
    };

    render(<VersionSyncStateBanner version={version} />);

    const alert = screen.queryByRole("alert");
    expect(alert).not.toBeNull();
    expect(alert).toHaveTextContent(/DELTA_CONCURRENT_APPEND/);
  });

  it("renders nothing when sync_state='ok'", () => {
    const { container } = render(
      <VersionSyncStateBanner version={baseVersion} />,
    );

    // Happy path: no alert anywhere in the rendered tree. Empty
    // textContent is the strongest "no banner" assertion.
    expect(screen.queryByRole("alert")).toBeNull();
    expect((container.textContent ?? "").trim()).toBe("");
  });

  it("renders nothing when sync_state is missing/undefined (legacy rows)", () => {
    // Rows written before the migration may serialize without the new
    // field. The banner must treat absent === 'ok' so those don't show
    // up as broken. The Pydantic ModelVersionOut surfaces the field
    // with a default, but defensively the FE should also handle
    // undefined.
    const version = { ...baseVersion } as Partial<MockVersion>;
    delete (version as Record<string, unknown>).sync_state;
    delete (version as Record<string, unknown>).sync_error_text;

    const { container } = render(
      <VersionSyncStateBanner
        version={version as unknown as MockVersion}
      />,
    );

    expect(screen.queryByRole("alert")).toBeNull();
    expect((container.textContent ?? "").trim()).toBe("");
  });

  it("renders the 'unknown' sync_state as a warning too", () => {
    // SPEC §Bug 2 line 105 lists 'unknown' as a possible value. Any
    // non-'ok' state must surface a banner so the operator sees that
    // something wasn't computed.
    const version = {
      ...baseVersion,
      sync_state: "unknown",
      sync_error_text: null,
    };

    render(<VersionSyncStateBanner version={version} />);

    const alert = screen.queryByRole("alert");
    expect(alert).not.toBeNull();
  });
});
