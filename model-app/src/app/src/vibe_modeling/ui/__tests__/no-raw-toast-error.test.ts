/**
 * Anti-drift guard: every error toast must go through `notifyError()`
 * (`lib/notify.ts`) instead of a raw `toast.error(...)` call, so the
 * persistent-toast + Copy/Details behavior and the object-detail 409
 * extraction can't be silently reintroduced or bypassed at a new site.
 * There is no lint infra in this repo (see Track 8 design), so this vitest
 * grep scans the UI source tree directly.
 */
import { describe, expect, it } from "vitest";
import { readFileSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";

const UI_ROOT = join(__dirname, "..");
const ALLOWED_FILE = join(UI_ROOT, "lib", "notify.ts");

function walk(dir: string, out: string[] = []): string[] {
  for (const entry of readdirSync(dir)) {
    if (entry === "node_modules" || entry === "__tests__") continue;
    const full = join(dir, entry);
    const stat = statSync(full);
    if (stat.isDirectory()) {
      walk(full, out);
    } else if (/\.(tsx?|jsx?)$/.test(entry)) {
      out.push(full);
    }
  }
  return out;
}

describe("no raw toast.error sites outside lib/notify.ts", () => {
  it("finds no toast.error( call outside the shared helper", () => {
    const offenders: string[] = [];
    for (const file of walk(UI_ROOT)) {
      if (file === ALLOWED_FILE) continue;
      const contents = readFileSync(file, "utf8");
      if (/toast\.error\(/.test(contents)) {
        offenders.push(file);
      }
    }
    expect(offenders).toEqual([]);
  });
});
