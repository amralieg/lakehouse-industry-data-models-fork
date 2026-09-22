import { Link } from "@tanstack/react-router";
import { useGetSourceCapabilitiesSuspense } from "@/lib/api";
import { selector } from "@/lib/selector";
import { Github, Info } from "lucide-react";

/**
 * Small info line above the source tree. Consumes ``getSourceCapabilities``.
 *
 * An un-configured GitHub connection is NOT an error for browse: the backend
 * falls back to the default public repo, so capabilities still resolve. We
 * surface the source kind + a pointer to Settings -> GitHub as an info line,
 * never a block (Story 3, states section).
 */
export function SourceCapabilityBanner() {
  const { data: caps } = useGetSourceCapabilitiesSuspense(selector());

  return (
    <div className="flex items-center gap-2 rounded-md border border-border bg-muted/40 px-3 py-2 text-xs text-muted-foreground">
      <Info className="h-3.5 w-3.5 shrink-0" />
      <span>
        Browsing source{" "}
        <span className="font-medium text-foreground">{caps.source_kind}</span>
        {caps.read_only ? " (read-only)" : ""}.
      </span>
      <Link
        to="/settings"
        search={{ tab: "sources" }}
        className="ml-auto flex items-center gap-1 text-foreground hover:underline"
      >
        <Github className="h-3.5 w-3.5" />
        Configure source
      </Link>
    </div>
  );
}
