import { Badge } from "@/components/ui/badge";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import type { ChangeStatus } from "@/lib/api";
import {
  changeBadgeClassName,
  changeIcon,
  changeLabel,
} from "@/lib/change-status";

export { changeRowClassName } from "@/lib/change-status";

export function ChangeBadge({ status }: { status?: ChangeStatus }) {
  const Icon = changeIcon(status);
  if (!Icon) return null;

  return (
    <TooltipProvider delayDuration={200}>
      <Tooltip>
        <TooltipTrigger asChild>
          <Badge
            variant="outline"
            className={`${changeBadgeClassName(status)} text-xs gap-1 px-1.5 py-0`}
          >
            <Icon className="h-3 w-3" />
          </Badge>
        </TooltipTrigger>
        <TooltipContent>
          <p className="text-xs">{changeLabel(status)}</p>
        </TooltipContent>
      </Tooltip>
    </TooltipProvider>
  );
}
