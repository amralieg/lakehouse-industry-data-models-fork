import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

interface DomainSelectProps {
  domains: { name: string; division?: string }[];
  value: string | null;
  onChange: (next: string | null) => void;
  /** Portal container for the dropdown content (needed in fullscreen). */
  portalContainer?: HTMLElement | null;
  className?: string;
}

const ALL_SENTINEL = "__all__";

/**
 * Domain dropdown shared between the Diagram and Ontology tabs.
 *
 * The first option ("All domains") maps to a `null` value via the
 * `__all__` sentinel — keeping the value type as `string | null` lets
 * callers branch on a real domain name vs. the unfiltered case.
 */
export function DomainSelect({
  domains,
  value,
  onChange,
  portalContainer,
  className,
}: DomainSelectProps) {
  return (
    <Select
      value={value ?? ALL_SENTINEL}
      onValueChange={(v) => onChange(v === ALL_SENTINEL ? null : v)}
    >
      <SelectTrigger className={className ?? "w-[220px] h-8 text-sm"}>
        <SelectValue placeholder="All domains" />
      </SelectTrigger>
      <SelectContent container={portalContainer}>
        <SelectItem value={ALL_SENTINEL}>All domains</SelectItem>
        {domains.map((d) => (
          <SelectItem key={d.name} value={d.name}>
            {d.name}
            {d.division && (
              <span className="text-muted-foreground ml-1">({d.division})</span>
            )}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  );
}
