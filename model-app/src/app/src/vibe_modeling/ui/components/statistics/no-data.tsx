import { Slash } from "lucide-react";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";

/**
 * The quiet "n/a" degradation token from the Statistics design.
 *
 * Per the design-of-record (docs/design/statistics-tab/README.md →
 * "Graceful degradation"), when a metric cannot be computed we render a
 * `slash` icon + italic "n/a" with a tooltip explaining why — never an empty
 * panel or an error. The dependent graphic is hidden by the caller; this token
 * is what takes its place.
 */
export function NoData({ reason }: { reason: string }) {
  return (
    <TooltipProvider delayDuration={200}>
      <Tooltip>
        <TooltipTrigger asChild>
          <span
            data-testid="no-data"
            className="inline-flex items-center gap-1 text-muted-foreground italic cursor-help"
          >
            <Slash className="h-3.5 w-3.5" />
            n/a
          </span>
        </TooltipTrigger>
        <TooltipContent>
          <p className="text-xs">{reason}</p>
        </TooltipContent>
      </Tooltip>
    </TooltipProvider>
  );
}
