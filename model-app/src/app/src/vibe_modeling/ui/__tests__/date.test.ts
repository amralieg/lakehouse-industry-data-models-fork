/**
 * Pure-function tests for the locale-neutral date/time formatters in
 * `lib/date.ts`. The module previously had no test coverage; the audit
 * flagged it as "completely untested".
 */
import { describe, it, expect } from "vitest";
import {
  formatDate,
  formatDateTime,
  formatElapsedSeconds,
  formatDuration,
} from "@/lib/date";

describe("formatDate", () => {
  it("returns the fallback for null", () => {
    expect(formatDate(null)).toBe("—");
  });

  it("returns the fallback for invalid date strings", () => {
    expect(formatDate("not-a-date")).toBe("—");
  });

  it("formats an ISO 8601 string into yyyy-MM-dd", () => {
    // The sv-SE locale gives ISO-style output. Asserting by regex avoids
    // timezone flakiness on CI runners that aren't UTC.
    expect(formatDate("2026-04-19T16:17:32Z")).toMatch(/^\d{4}-\d{2}-\d{2}$/);
  });

  it("uses the caller-provided fallback when no value is given", () => {
    expect(formatDate(null, "n/a")).toBe("n/a");
  });
});

describe("formatDateTime", () => {
  it("formats a valid date as yyyy-MM-dd HH:mm:ss", () => {
    expect(formatDateTime("2026-04-19T16:17:32Z")).toMatch(
      /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/,
    );
  });
});

describe("formatElapsedSeconds", () => {
  it("returns MM:SS under 1 hour", () => {
    expect(formatElapsedSeconds(42)).toBe("00:42");
    expect(formatElapsedSeconds(727)).toBe("12:07");
  });

  it("returns HH:MM:SS at 1 hour or more", () => {
    expect(formatElapsedSeconds(3600)).toBe("01:00:00");
    expect(formatElapsedSeconds(45296)).toBe("12:34:56");
  });

  it("clamps negative or non-finite values to 00:00", () => {
    expect(formatElapsedSeconds(-5)).toBe("00:00");
    expect(formatElapsedSeconds(Number.NaN)).toBe("00:00");
    expect(formatElapsedSeconds(Number.POSITIVE_INFINITY)).toBe("00:00");
  });
});

describe("formatDuration", () => {
  it("returns ms for sub-second values", () => {
    expect(formatDuration(450)).toBe("450ms");
    expect(formatDuration(0)).toBe("0ms");
  });

  it("returns a compact m/s mix in the minute range", () => {
    expect(formatDuration(12_000)).toBe("12s");
    expect(formatDuration(204_000)).toBe("3m 24s");
    expect(formatDuration(120_000)).toBe("2m");
  });

  it("returns h/m for >=1 hour", () => {
    expect(formatDuration(4_320_000)).toBe("1h 12m");
    expect(formatDuration(3_600_000)).toBe("1h");
  });

  it("clamps negative inputs to 0", () => {
    expect(formatDuration(-1)).toBe("0ms");
  });
});
