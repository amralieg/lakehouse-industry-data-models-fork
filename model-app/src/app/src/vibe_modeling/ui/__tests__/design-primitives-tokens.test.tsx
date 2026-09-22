/**
 * Design system primitive token assertions.
 *
 * Locks the DESIGN.md "Databricks-like" contract on the shadcn primitives
 * so any drift (e.g. someone re-introduces shadow-lg on Card or text-base
 * on Input) is caught before merge — without going via a brittle full
 * markup snapshot.
 *
 * The assertions target token presence (or absence) rather than exact
 * className substrings so refactors that preserve the design intent stay
 * green.
 */
import { describe, expect, it } from "vitest";
import { render } from "@testing-library/react";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

describe("design primitives token contract", () => {
  it("button default is the DuBois primary action, 32px high, regular weight, no resting shadow", () => {
    const { container } = render(<Button>Save</Button>);
    const btn = container.querySelector("button")!;
    const klass = btn.className;
    // 32px control height — matches DuBois `du-bois-light-btn-primary`.
    expect(klass).toMatch(/\bh-8\b/);
    expect(klass).toMatch(/\brounded-md\b/);
    // Regular weight — DuBois primary buttons render at font-weight 400,
    // not 500. Locks against shadcn's font-medium default sneaking back in.
    expect(klass).toMatch(/\bfont-normal\b/);
    expect(klass).not.toMatch(/\bfont-medium\b/);
    expect(klass).not.toMatch(/\bshadow(-sm|-md|-lg|-xl|-2xl)?\b(?!.*hover)/);
    // Primary action uses the `--primary` token (DuBois blue). The brand
    // tertiary orange is reserved for identity, not for the default action.
    expect(klass).toContain("bg-primary");
    expect(klass).toContain("text-primary-foreground");
    expect(klass).not.toContain("bg-tertiary");
  });

  it("button sm + icon variants share the 32px height (uniform DuBois control row)", () => {
    // `sm` is compact-padding only — it must NOT be a shorter button. The
    // app sits sm buttons next to default buttons in toolbars (run header
    // actions, dialog footers); height drift breaks the control row.
    const { container: sm } = render(<Button size="sm">Cancel</Button>);
    expect(sm.querySelector("button")!.className).toMatch(/\bh-8\b/);
    expect(sm.querySelector("button")!.className).not.toMatch(/\bh-7\b/);
    const { container: icon } = render(<Button size="icon" aria-label="x" />);
    expect(icon.querySelector("button")!.className).toMatch(/\bh-8\b/);
    expect(icon.querySelector("button")!.className).toMatch(/\bw-8\b/);
  });

  it("button outline + secondary stay subordinate (no primary fill)", () => {
    const { container: outline } = render(
      <Button variant="outline">Cancel</Button>,
    );
    const { container: secondary } = render(
      <Button variant="secondary">Cancel</Button>,
    );
    for (const c of [outline, secondary]) {
      const klass = c.querySelector("button")!.className;
      expect(klass).not.toContain("bg-primary");
      expect(klass).not.toContain("bg-tertiary");
      expect(klass).toContain("border");
    }
  });

  it("input has 32px height, 6px radius, accent focus ring", () => {
    const { container } = render(<Input placeholder="search" />);
    const input = container.querySelector("input")!;
    const klass = input.className;
    expect(klass).toMatch(/\bh-8\b/);
    expect(klass).toMatch(/\brounded-md\b/);
    expect(klass).toMatch(/focus-visible:ring-2/);
    // No resting shadow — DESIGN.md "use depth sparingly".
    expect(klass).not.toMatch(/\bshadow-sm\b/);
  });

  it("card uses rounded-md and no resting shadow", () => {
    const { container } = render(<Card>x</Card>);
    const card = container.firstElementChild as HTMLElement;
    const klass = card.className;
    expect(klass).toMatch(/\brounded-md\b/);
    expect(klass).not.toMatch(/\brounded-(xl|2xl|3xl)\b/);
    expect(klass).not.toMatch(/\bshadow(-sm|-md|-lg|-xl)?\b/);
  });

  it("badge default is the quiet muted variant (no accent fill)", () => {
    const { container } = render(<Badge>v0.4.2</Badge>);
    const badge = container.firstElementChild as HTMLElement;
    const klass = badge.className;
    expect(klass).toMatch(/\brounded-sm\b/);
    // No resting shadow on resting badges; the accent is reserved for
    // primary actions, not metadata labels.
    expect(klass).not.toMatch(/\bshadow\b/);
    expect(klass).not.toContain("bg-primary");
    expect(klass).not.toContain("bg-tertiary");
  });
});
