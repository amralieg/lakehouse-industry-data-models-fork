/**
 * Compiled-preview Markdown — the FE twin of the backend `compile_inputs`
 * (`backend/_compile.py`). `compilePreviewMarkdown` renders the selected Vibe
 * Inputs into the exact document the agent receives; it is what the New Run
 * page and the compose surface show as the read-only preview. The FE and BE
 * implementations produce a BYTE-IDENTICAL string for the same inputs and are
 * kept in lockstep by the frozen fixture (tests/fixtures/compile_blocks_fixture.json),
 * not by sharing code (BE is Python, FE is TS — the fixture is the contract).
 */

/** Collapse all internal whitespace runs to a single space, mirroring
 *  Python's `" ".join(s.split())`. Used to one-line short-input text. */
function normalizeWhitespace(s: string): string {
  return s.trim().split(/\s+/).join(" ");
}

/** One input as it reaches the compiled-preview helper. ``anchorPath`` is the
 *  already-resolved section labels (e.g. ["Domain: Sales"], ["Model-wide"]),
 *  mirroring the backend adapter so the same fixture applies to both sides. */
export interface CompileInputLike {
  priority: string;
  anchorPath: string[];
  text: string;
}

/** Long/rich detector: a newline OR length > 150 on the RAW text. Mirrors the
 *  backend `_is_rich` exactly. Detection runs on the raw text, never the
 *  collapsed text. (Canonical FE detector; re-export for the editor if needed.) */
export function isRichText(text: string): boolean {
  const t = text ?? "";
  return /\n/.test(t) || t.length > 150;
}

/** Outer-trim a rich block body: leading newlines only stripped (leading
 *  spaces/tabs survive), trailing run over the exact class `[ \t\r\n]` stripped.
 *  Byte-identical twin of the backend `_block_body` — do NOT use `\s` (a
 *  different char class) in the trailing regex. */
function blockBody(text: string): string {
  return (text ?? "").replace(/^\n+/, "").replace(/[ \t\r\n]+$/, "");
}

const HEADER_LEVELS: Record<string, number> = {
  "Domain": 2,
  "Subdomain": 3,
  "Product": 4,
  "Attribute": 5,
  "Relationship": 5,
};

function headerLevel(label: string): number {
  if (label === "Model-wide") return 2;
  const prefix = label.split(":", 1)[0];
  return HEADER_LEVELS[prefix] ?? 2;
}

/** Render ONE input to its bullet or block lines, mirroring the backend entry
 *  loop branch. Short → one-line bullet; rich → blank-fenced block with a
 *  `> Priority:` blockquote and the verbatim body. */
export function compileInputBlock(input: CompileInputLike): string[] {
  if (!isRichText(input.text)) {
    return [`- (${input.priority}) ${normalizeWhitespace(input.text)}`];
  }
  const body = blockBody(input.text);
  if (body === "") {
    return ["", `> Priority: ${input.priority}`, ""];
  }
  return ["", `> Priority: ${input.priority}`, "", ...body.split("\n"), ""];
}

/** Full-doc assembly mirroring `compile_inputs`: group by anchor, de-dup
 *  headers, order by (model-wide first, anchorPath, oneline(text).lower()), and
 *  join with "\n". Byte-identical to the backend `CompileOut.markdown`. */
export function compilePreviewMarkdown(inputs: readonly CompileInputLike[]): string {
  if (!inputs.length) return "";

  // model-wide sorts first; then by anchorPath labels (case-insensitive); then
  // by the oneline-collapsed text. RENDERING uses verbatim text — this split
  // matches the backend and is intentional. Comparison is code-point order
  // (plain `<`/`>` on lowercased strings) to match Python's tuple comparison,
  // NOT locale collation, so the BE/FE byte-parity holds.
  const cmp = (x: string, y: string) => (x < y ? -1 : x > y ? 1 : 0);
  const ordered = [...inputs].sort((a, b) => {
    const amw = a.anchorPath[0] === "Model-wide" ? 0 : 1;
    const bmw = b.anchorPath[0] === "Model-wide" ? 0 : 1;
    if (amw !== bmw) return amw - bmw;
    const aKeys = amw === 0 ? [] : a.anchorPath;
    const bKeys = bmw === 0 ? [] : b.anchorPath;
    for (let i = 0; i < Math.min(aKeys.length, bKeys.length); i++) {
      const c = cmp(aKeys[i].toLowerCase(), bKeys[i].toLowerCase());
      if (c !== 0) return c;
    }
    if (aKeys.length !== bKeys.length) return aKeys.length - bKeys.length;
    return cmp(
      normalizeWhitespace(a.text).toLowerCase(),
      normalizeWhitespace(b.text).toLowerCase(),
    );
  });

  const lines: string[] = [];
  let emitted: string[] = [];
  for (const input of ordered) {
    const headers = input.anchorPath;
    let common = 0;
    while (common < emitted.length && common < headers.length
      && emitted[common] === headers[common]) common++;
    emitted = [...headers];
    for (let i = common; i < headers.length; i++) {
      lines.push(`${"#".repeat(headerLevel(headers[i]))} ${headers[i]}`);
    }
    lines.push(...compileInputBlock(input));
  }
  return lines.join("\n");
}
