import { describe, it, expect } from "vitest";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

import { FALLBACKS } from "@/components/diagram/diagram-colors";

/**
 * The diagram palette is declared in globals.css and mirrored by the FALLBACKS
 * map (used when getComputedStyle can't resolve the vars, e.g. jsdom). These two
 * must stay byte-identical, or unit tests pass against stale colors while the
 * browser renders the real ones. This test fails the moment they diverge.
 */
function readGlobalsDiagramVars(): Record<string, string> {
  const here = path.dirname(fileURLToPath(import.meta.url));
  const css = readFileSync(path.resolve(here, "../styles/globals.css"), "utf8");
  const vars: Record<string, string> = {};
  const re = /(--diagram-[a-z0-9-]+)\s*:\s*([^;]+);/gi;
  let m: RegExpExecArray | null;
  while ((m = re.exec(css)) !== null) {
    vars[m[1]] = m[2].trim().toLowerCase();
  }
  return vars;
}

describe("diagram palette ↔ FALLBACKS sync", () => {
  const cssVars = readGlobalsDiagramVars();

  it("globals.css defines a --diagram-* palette", () => {
    expect(Object.keys(cssVars).length).toBeGreaterThan(0);
  });

  it("every FALLBACKS entry matches its globals.css value", () => {
    for (const [name, hex] of Object.entries(FALLBACKS)) {
      expect(cssVars[name], `globals.css missing ${name}`).toBeDefined();
      expect(cssVars[name], `${name} drifted from globals.css`).toBe(hex.toLowerCase());
    }
  });

  it("every JS-consumed globals.css --diagram-* var has a FALLBACKS entry", () => {
    // The `--diagram-controls-*` vars are consumed only via CSS var() in
    // diagram.css, never resolved through the JS helper, so they need no
    // fallback. Every other --diagram-* var IS read in JS and must have one.
    for (const name of Object.keys(cssVars)) {
      if (name.startsWith("--diagram-controls-")) continue;
      expect(FALLBACKS[name], `FALLBACKS missing ${name}`).toBeDefined();
    }
  });
});
