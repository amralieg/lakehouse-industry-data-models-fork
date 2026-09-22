/**
 * `apiErrorMessage` helper tests.
 *
 * The helper extracts a useful, user-facing message from an `ApiError`
 * thrown by the auto-generated API client. The default `err.message`
 * is just `"HTTP 422: Unprocessable Entity"`; we want the FastAPI
 * detail string or the Pydantic msg(s) instead.
 */
import { describe, expect, it } from "vitest";
import { apiErrorMessage, parse409 } from "@/lib/api-error";
import { ApiError } from "@/lib/api";

interface SampleConflict {
  error: "industry_already_exists";
  dependent_business_count?: number;
}

describe("parse409", () => {
  it("unwraps a conflict body nested under detail", () => {
    const err = new ApiError(409, "Conflict", {
      detail: { error: "industry_already_exists", dependent_business_count: 3 },
    });
    const parsed = parse409<SampleConflict>(err, "industry_already_exists");
    expect(parsed?.dependent_business_count).toBe(3);
  });

  it("unwraps a conflict body passed directly (no detail wrapper)", () => {
    const err = new ApiError(409, "Conflict", {
      error: "business_already_exists",
      business_id: "biz-1",
    });
    const parsed = parse409<{ error: string; business_id: string }>(
      err,
      "business_already_exists",
    );
    expect(parsed?.business_id).toBe("biz-1");
  });

  it("returns null for non-409, mismatched error literal, or non-ApiError", () => {
    expect(
      parse409(new ApiError(500, "boom", { error: "x" }), "x"),
    ).toBeNull();
    expect(
      parse409(
        new ApiError(409, "Conflict", { detail: { error: "other" } }),
        "industry_already_exists",
      ),
    ).toBeNull();
    expect(parse409(new Error("nope"), "x")).toBeNull();
    expect(parse409(new ApiError(409, "Conflict", null), "x")).toBeNull();
  });
});

describe("apiErrorMessage", () => {
  it("returns FastAPI detail string when provided", () => {
    const err = new ApiError(400, "Bad Request", { detail: "catalog already in use" });
    expect(apiErrorMessage(err)).toBe("catalog already in use");
  });

  it("joins Pydantic validation msgs from a detail array", () => {
    const err = new ApiError(422, "Unprocessable Entity", {
      detail: [
        { type: "string_too_short", loc: ["body", "name"], msg: "String should have at least 1 character" },
        { type: "missing", loc: ["body", "industry_alignment"], msg: "Field required" },
      ],
    });
    expect(apiErrorMessage(err)).toBe(
      "String should have at least 1 character; Field required",
    );
  });

  it("caps joined Pydantic msgs at 3 entries to keep toast compact", () => {
    const err = new ApiError(422, "Unprocessable Entity", {
      detail: [
        { msg: "first" },
        { msg: "second" },
        { msg: "third" },
        { msg: "fourth" },
      ],
    });
    expect(apiErrorMessage(err)).toBe("first; second; third");
  });

  it("falls back to the HTTP-level message when body has no detail", () => {
    const err = new ApiError(500, "Internal Server Error", null);
    expect(apiErrorMessage(err)).toBe("HTTP 500: Internal Server Error");
  });

  it("falls back to err.message for non-ApiError Error instances", () => {
    const err = new Error("network unreachable");
    expect(apiErrorMessage(err)).toBe("network unreachable");
  });

  it("falls back to the supplied default for non-Error throws", () => {
    expect(apiErrorMessage("not an error", "Save failed")).toBe("Save failed");
    expect(apiErrorMessage(null, "Save failed")).toBe("Save failed");
    expect(apiErrorMessage(undefined, "Save failed")).toBe("Save failed");
  });

  it("ignores empty-string detail and falls back", () => {
    const err = new ApiError(400, "Bad Request", { detail: "" });
    expect(apiErrorMessage(err)).toBe("HTTP 400: Bad Request");
  });

  it("ignores Pydantic array entries without a string msg", () => {
    const err = new ApiError(422, "Unprocessable Entity", {
      detail: [{ type: "missing", loc: ["body"] }],
    });
    expect(apiErrorMessage(err)).toBe("HTTP 422: Unprocessable Entity");
  });

  it("prefers detail.message for an object-shaped 409 (sector-in-use)", () => {
    const err = new ApiError(409, "Conflict", {
      detail: { message: "Sector in use by 3 businesses", error: "sector_in_use" },
    });
    expect(apiErrorMessage(err)).toBe("Sector in use by 3 businesses");
  });

  it("falls back to detail.error when there is no message", () => {
    const err = new ApiError(409, "Conflict", {
      detail: { error: "industry_already_exists" },
    });
    expect(apiErrorMessage(err)).toBe("industry_already_exists");
  });

  it("prefers message over error on an unwrapped (non-detail) object body", () => {
    const err = new ApiError(409, "Conflict", {
      message: "Version delete blocked",
      error: "version_in_use",
    });
    expect(apiErrorMessage(err)).toBe("Version delete blocked");
  });
});
