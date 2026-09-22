import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useListSectorsSuspense } from "@/lib/api";
import { selector } from "@/lib/selector";

interface SectorSelectProps {
  /** Current ``sector_id`` (a Sector row id), or null/empty when unset. */
  value: string | null | undefined;
  onChange: (next: string | null) => void;
  placeholder?: string;
}

/**
 * Shared sector picker for the business + industry create forms (ADR D-047).
 *
 * Populated from ``useListSectorsSuspense`` (active rows only), the option
 * value is the Sector ``id`` (what ``Business.sector_id`` stores); the visible
 * label is the sector ``name``. A "None" option clears the selection.
 */
export function SectorSelect({
  value,
  onChange,
  placeholder = "Select a sector...",
}: SectorSelectProps) {
  const { data: sectors } = useListSectorsSuspense(selector());
  const active = (sectors ?? []).filter((s) => s.is_active);

  const NONE = "__none__";

  return (
    <Select
      value={value || NONE}
      onValueChange={(v) => onChange(v === NONE ? null : v)}
    >
      <SelectTrigger>
        <SelectValue placeholder={placeholder} />
      </SelectTrigger>
      <SelectContent>
        <SelectItem value={NONE}>None</SelectItem>
        {active.map((sec) => (
          <SelectItem key={sec.id} value={sec.id}>
            {sec.name}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  );
}
