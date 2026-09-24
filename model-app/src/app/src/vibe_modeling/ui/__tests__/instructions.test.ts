/**
 * Unit tests for the FE-side compiled-preview helpers (the byte-parity twin of
 * the backend `compile_inputs`). The parity guarantee is locked by the frozen
 * fixture (tests/fixtures/compile_blocks_fixture.json): the FE
 * `compilePreviewMarkdown` must reproduce the backend `CompileOut.markdown`
 * exactly for the same inputs.
 */
import { describe, expect, it } from "vitest";
import {
  compileInputBlock,
  compilePreviewMarkdown,
  isRichText,
} from "../lib/instructions";
import fixture from "../../../../../../tests/fixtures/compile_blocks_fixture.json";

describe("isRichText", () => {
  it("is rich when text contains a newline", () => {
    expect(isRichText("a\nb")).toBe(true);
    expect(isRichText("\n")).toBe(true);
  });

  it("is rich when length > 150, not at <= 150", () => {
    expect(isRichText("x".repeat(150))).toBe(false);
    expect(isRichText("x".repeat(151))).toBe(true);
  });

  it("is not rich for short, single-line, or empty text", () => {
    expect(isRichText("short rule")).toBe(false);
    expect(isRichText("")).toBe(false);
  });
});

describe("compileInputBlock", () => {
  it("renders a short input as a collapsed one-line bullet", () => {
    expect(
      compileInputBlock({ priority: "high", anchorPath: ["Model-wide"], text: "Use snake_case   everywhere" }),
    ).toEqual(["- (high) Use snake_case everywhere"]);
  });

  it("renders a rich input as a blank-fenced block with a priority blockquote and verbatim body", () => {
    const text = "# Heading\n\nbody one\n\nbody two";
    expect(
      compileInputBlock({ priority: "medium", anchorPath: ["Model-wide"], text }),
    ).toEqual(["", "> Priority: medium", "", "# Heading", "", "body one", "", "body two", ""]);
  });

  it("takes the empty-body branch for whitespace-only rich text", () => {
    expect(
      compileInputBlock({ priority: "low", anchorPath: ["Model-wide"], text: "\n" }),
    ).toEqual(["", "> Priority: low", ""]);
  });
});

describe("compilePreviewMarkdown", () => {
  it("groups, de-dups headers, and orders mixed short + rich sections", () => {
    const long =
      "Sales narrative that runs well past one hundred and fifty characters so it trips the rich detector and renders as a preserved multi-paragraph block under the Sales header.";
    const out = compilePreviewMarkdown([
      { priority: "high", anchorPath: ["Domain: Sales"], text: long },
      { priority: "medium", anchorPath: ["Domain: Sales"], text: "keep order ids stable" },
    ]);
    expect(out).toBe(
      "## Domain: Sales\n- (medium) keep order ids stable\n\n> Priority: high\n\n" + long + "\n",
    );
    expect(out.split("## Domain: Sales").length - 1).toBe(1);
  });
});

describe("compile preview matches frozen fixture", () => {
  for (const c of fixture.cases) {
    it(c.name, () => {
      expect(compilePreviewMarkdown(c.inputs)).toBe(c.expected_markdown);
      if (c.name === "ordering_stability_reversed_input_order_same_output") {
        expect(compilePreviewMarkdown([...c.inputs].reverse())).toBe(c.expected_markdown);
      }
    });
  }
});
