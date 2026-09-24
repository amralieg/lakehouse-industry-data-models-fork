/**
 * H1 heading style contract for the model + domain routes.
 *
 * D4 from the v0.4.2 live walkthrough: the model-version page
 * (/businesses/:id/model/:v/:scope) and the domain page
 * (/businesses/:id/model/:v/:scope/:domain) rendered their h1 at
 * `text-xl font-bold` while every other page heading in the app uses
 * `text-2xl font-semibold tracking-tight`. The two route components
 * carried pre-design-swap heading classes.
 *
 * This test reads the route source files and asserts the h1 line uses
 * the standard tokens, so any future change that re-introduces the
 * legacy `text-xl font-bold` classes (or any other deviation) at these
 * sites fails before merge.
 *
 * Source-file assertion (not full render) is deliberate: these routes
 * pull live data via Suspense + Tanstack Router loaders; the heading
 * style is a static className, so a className-string check is the
 * narrowest correct gate.
 */
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";

const ROUTES_DIR = resolve(
  __dirname,
  "..",
  "routes",
  "_sidebar",
);

const COMPONENTS_DIR = resolve(__dirname, "..", "components");

const STANDARD_H1 = "text-2xl font-semibold tracking-tight";

function readRoute(filename: string): string {
  return readFileSync(resolve(ROUTES_DIR, filename), "utf8");
}

describe("model + domain route h1 heading style", () => {
  it("model-version page uses the standard h1 tokens", () => {
    // The model page title h1 lives in the shared ModelTabsShell header
    // (extracted from the route so the input-review page inherits it too).
    const src = readFileSync(
      resolve(COMPONENTS_DIR, "model", "model-tabs-shell.tsx"),
      "utf8",
    );
    const h1Match = src.match(/<h1\s+className="([^"]+)"/);
    expect(h1Match, "model page must declare an <h1>").not.toBeNull();
    expect(h1Match![1]).toContain(STANDARD_H1);
    expect(h1Match![1]).not.toMatch(/\btext-xl\b/);
    expect(h1Match![1]).not.toMatch(/\bfont-bold\b/);
  });

  it("domain page uses the standard h1 tokens", () => {
    const src = readRoute(
      "businesses.$businessId.model.$version.$scope.$domainName.index.tsx",
    );
    const h1Match = src.match(/<h1\s+className="([^"]+)"/);
    expect(h1Match, "domain page must declare an <h1>").not.toBeNull();
    expect(h1Match![1]).toContain(STANDARD_H1);
    expect(h1Match![1]).not.toMatch(/\btext-xl\b/);
    expect(h1Match![1]).not.toMatch(/\bfont-bold\b/);
  });

  it("product page (sibling) already uses the standard tokens - regression lock", () => {
    const src = readRoute(
      "businesses.$businessId.model.$version.$scope.$domainName.$productName.tsx",
    );
    const h1Match = src.match(/<h1\s+className="([^"]+)"/);
    expect(h1Match, "product page must declare an <h1>").not.toBeNull();
    expect(h1Match![1]).toContain(STANDARD_H1);
  });
});
