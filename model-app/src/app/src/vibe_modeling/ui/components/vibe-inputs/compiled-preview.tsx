import { useMemo } from "react";
import ReactMarkdown from "react-markdown";
import type { VibeInputOut } from "@/lib/api";
import {
  compilePreviewMarkdown,
  type CompileInputLike,
} from "@/lib/instructions";
import { anchorPathForCompile, isIncludedInCompile } from "./state";

export interface CompiledPreviewProps {
  /** The full input collection (already filtered to the current version's head
   *  scope by the caller's list query). */
  inputs: readonly VibeInputOut[];
  /** Ids selected for the next run. */
  includedIds: ReadonlySet<string>;
}

/**
 * Read-only compiled-instructions document. Mirrors the agent's view of the
 * selected inputs by reusing the byte-parity `compilePreviewMarkdown`
 * (lib/instructions.ts, the FE twin of the backend `compile_inputs`). The
 * source of truth is the cards; this pane never edits.
 *
 * Anchor-free inputs (no link on the head version), deprecated inputs, and
 * unselected inputs are excluded — same selection the server re-compiles
 * authoritatively on run launch.
 */
export function CompiledPreview({ inputs, includedIds }: CompiledPreviewProps) {
  const { markdown, count } = useMemo(() => {
    const selected: CompileInputLike[] = [];
    for (const vi of inputs) {
      if (!includedIds.has(vi.id)) continue;
      if (!isIncludedInCompile(vi)) continue;
      const anchorPath = anchorPathForCompile(vi);
      if (!anchorPath) continue;
      selected.push({ priority: vi.priority, anchorPath, text: vi.text });
    }
    return { markdown: compilePreviewMarkdown(selected), count: selected.length };
  }, [inputs, includedIds]);

  return (
    <div className="flex h-full flex-col">
      <div className="flex items-center justify-between border-b border-border px-4 py-2">
        <span className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
          Compiled instructions
        </span>
        <span
          className="rounded-sm bg-secondary px-1.5 py-0.5 text-[11px] text-secondary-foreground"
          data-testid="compiled-preview-count"
        >
          {count} selected
        </span>
      </div>
      <div className="min-h-0 flex-1 overflow-auto px-4 py-3">
        {count === 0 ? (
          <p className="text-sm text-muted-foreground">
            No inputs included. Check an instruction to add it to the run.
          </p>
        ) : (
          <div
            className="prose prose-sm dark:prose-invert max-w-none whitespace-pre-wrap text-sm"
            data-testid="compiled-preview-markdown"
          >
            <ReactMarkdown>{markdown}</ReactMarkdown>
          </div>
        )}
      </div>
    </div>
  );
}
