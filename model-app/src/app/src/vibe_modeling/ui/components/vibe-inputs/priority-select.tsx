import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { VibeInputPriority } from "@/lib/api";

/**
 * Shared high/medium/low priority `Select`, extracted from the feedback
 * dialog so the create/edit/compose priority controls can't drift from one
 * another. `container` forwards to the underlying `SelectContent` (Radix
 * portal target) so callers rendering inside a fullscreen element can keep
 * the dropdown attached to the right subtree.
 */
export function PrioritySelect({
  value,
  onValueChange,
  container,
}: {
  value: VibeInputPriority;
  onValueChange: (value: VibeInputPriority) => void;
  container?: HTMLElement | null;
}) {
  return (
    <Select value={value} onValueChange={(v) => onValueChange(v as VibeInputPriority)}>
      <SelectTrigger className="w-28" aria-label="Priority">
        <SelectValue />
      </SelectTrigger>
      <SelectContent container={container ?? undefined}>
        <SelectItem value={VibeInputPriority.high}>High</SelectItem>
        <SelectItem value={VibeInputPriority.medium}>Medium</SelectItem>
        <SelectItem value={VibeInputPriority.low}>Low</SelectItem>
      </SelectContent>
    </Select>
  );
}
