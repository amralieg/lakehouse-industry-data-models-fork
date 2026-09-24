import { describe, it, expect } from "vitest";
import { ChangeStatus } from "@/lib/api";
import {
  changeBadgeClassName,
  changeRowClassName,
  statusDotClass,
  changeLabel,
  changeIcon,
  changeTextToneClass,
} from "@/lib/change-status";
import { Pencil } from "lucide-react";

describe("change-status lib", () => {
  it("modified badge uses warning tone, not text-chart-2", () => {
    const cls = changeBadgeClassName(ChangeStatus.modified);
    expect(cls).toContain("text-warning");
    expect(cls).not.toContain("text-chart-2");
  });

  it("modified dot is bg-warning", () => {
    expect(statusDotClass(ChangeStatus.modified)).toBe("bg-warning");
  });

  it("modified text tone is warning, not chart-2 (the domain-breakdown fix)", () => {
    expect(changeTextToneClass(ChangeStatus.modified)).toBe("text-warning");
    expect(changeTextToneClass(ChangeStatus.modified)).not.toContain("chart-2");
  });

  it("new dot is bg-success", () => {
    expect(statusDotClass(ChangeStatus.new)).toBe("bg-success");
  });

  it("deleted dot falls through to muted (preserves prior behavior)", () => {
    expect(statusDotClass(ChangeStatus.deleted)).toBe("bg-muted-foreground/50");
  });

  it("unchanged dot is muted", () => {
    expect(statusDotClass(ChangeStatus.unchanged)).toBe("bg-muted-foreground/50");
    expect(statusDotClass(undefined)).toBe("bg-muted-foreground/50");
  });

  it("unchanged/undefined badge is empty and icon is null", () => {
    expect(changeBadgeClassName(ChangeStatus.unchanged)).toBe("");
    expect(changeBadgeClassName(undefined)).toBe("");
    expect(changeIcon(ChangeStatus.unchanged)).toBeNull();
    expect(changeIcon(undefined)).toBeNull();
  });

  it("modified icon is Pencil", () => {
    expect(changeIcon(ChangeStatus.modified)).toBe(Pencil);
  });

  it("rowClassName matches the badge taxonomy", () => {
    expect(changeRowClassName(ChangeStatus.unchanged)).toBe("");
    expect(changeRowClassName(ChangeStatus.modified)).toContain("bg-warning");
    expect(changeRowClassName(ChangeStatus.deleted)).toContain("opacity-50");
  });

  it("freezes the status->repr contract", () => {
    const snap = (Object.keys(ChangeStatus) as ChangeStatus[]).reduce(
      (acc, s) => {
        const icon = changeIcon(s);
        acc[s] = {
          badge: changeBadgeClassName(s),
          row: changeRowClassName(s),
          dot: statusDotClass(s),
          tone: changeTextToneClass(s),
          label: changeLabel(s),
          icon: icon ? icon.displayName ?? icon.name ?? "icon" : null,
        };
        return acc;
      },
      {} as Record<string, unknown>,
    );
    expect(snap).toMatchSnapshot();
  });

  it("re-export from change-badge still resolves to lib values", async () => {
    const mod = await import("@/components/explorer/change-badge");
    expect(mod.changeRowClassName(ChangeStatus.modified)).toContain("bg-warning");
    expect(mod.changeRowClassName(ChangeStatus.modified)).toBe(
      changeRowClassName(ChangeStatus.modified),
    );
  });
});
