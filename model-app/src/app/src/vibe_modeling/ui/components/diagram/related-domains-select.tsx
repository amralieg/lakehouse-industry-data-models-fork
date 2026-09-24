import { useId, useMemo, useState } from "react";
import { ChevronsUpDown } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Checkbox } from "@/components/ui/checkbox";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import {
  Command,
  CommandEmpty,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command";

export interface RelatedDomainOption {
  name: string;
  division: string;
}

export interface RelatedDomainsSelectProps {
  relatedDomains: RelatedDomainOption[];
  /** Domains currently HIDDEN. Empty = show all (the default). */
  hiddenRelated: Set<string>;
  onHiddenRelatedChange: (next: Set<string>) => void;
  /** Portal container for the popover (needed in fullscreen). */
  portalContainer?: HTMLElement | null;
}

/**
 * Collapsed multi-select dropdown of related (cross-domain) domains for the
 * single-domain ER view. Replaces the old binary "Hide Cross-Domain" toggle:
 * instead of all-or-nothing, the user narrows the view from "focal + all
 * related" down to "focal + a chosen subset of related".
 *
 * State is stored as the set of HIDDEN domain names (empty = show all), which
 * is the default and matches today's behaviour — this is a narrow-down
 * control. The UI presents it inverted: a checkbox is CHECKED when the domain
 * is SHOWN (i.e. NOT in `hiddenRelated`).
 *
 * Structure mirrors `deployment-catalog-picker.tsx` (Popover + Command with
 * `shouldFilter={false}` + a client-side `filtered` memo + a `useId` trigger),
 * but this picker is MULTI-select and keeps the popover open on toggle.
 *
 * Note: a newly-appearing related domain (one not present in a stale
 * `hiddenRelated` set) defaults to SHOWN — intentional, so default=show-all
 * holds even as the backend's related set changes.
 */
export function RelatedDomainsSelect({
  relatedDomains,
  hiddenRelated,
  onHiddenRelatedChange,
  portalContainer,
}: RelatedDomainsSelectProps) {
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState("");
  const reactId = useId();
  const triggerId = `${reactId}-related-domains-trigger`;

  const total = relatedDomains.length;
  const shown = total - hiddenRelated.size;
  const label =
    shown === total
      ? "Related: all"
      : shown === 0
        ? "Related: none"
        : `Related: ${shown}/${total}`;

  const trimmedSearch = search.trim();
  const searchLower = trimmedSearch.toLowerCase();
  const filtered = useMemo(() => {
    if (!trimmedSearch) return relatedDomains;
    return relatedDomains.filter((d) =>
      d.name.toLowerCase().includes(searchLower),
    );
  }, [relatedDomains, searchLower, trimmedSearch]);

  const toggle = (name: string) => {
    // Always build a NEW Set so memo/effect deps in the viewer fire.
    const next = new Set(hiddenRelated);
    if (next.has(name)) {
      next.delete(name);
    } else {
      next.add(name);
    }
    onHiddenRelatedChange(next);
  };

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button
          id={triggerId}
          type="button"
          variant="outline"
          size="sm"
          role="combobox"
          aria-expanded={open}
          aria-haspopup="listbox"
          aria-label="Related domains"
          className="h-8 text-xs"
        >
          {label}
          <ChevronsUpDown className="h-3.5 w-3.5 opacity-50 shrink-0 ml-1.5" />
        </Button>
      </PopoverTrigger>
      <PopoverContent
        className="p-0 w-64"
        align="start"
        container={portalContainer}
      >
        <Command shouldFilter={false} label="Related domains">
          <CommandInput
            placeholder="Filter related domains…"
            value={search}
            onValueChange={setSearch}
          />
          <div className="flex items-center justify-between gap-2 px-2 py-1.5 border-b text-xs">
            <button
              type="button"
              className="text-muted-foreground hover:text-foreground"
              onClick={() => onHiddenRelatedChange(new Set())}
            >
              Select all
            </button>
            <button
              type="button"
              className="text-muted-foreground hover:text-foreground"
              onClick={() =>
                onHiddenRelatedChange(
                  new Set(relatedDomains.map((d) => d.name)),
                )
              }
            >
              Clear all
            </button>
          </div>
          <CommandList>
            {filtered.length === 0 && (
              <CommandEmpty>No domains match.</CommandEmpty>
            )}
            {filtered.map((d) => (
              <CommandItem
                key={d.name}
                value={d.name}
                // Keep the popover open on toggle — multi-select.
                onSelect={() => toggle(d.name)}
                className="flex items-center gap-2"
              >
                <Checkbox checked={!hiddenRelated.has(d.name)} />
                <span className="truncate flex-1">{d.name}</span>
                {d.division && (
                  <Badge variant="outline" className="text-muted-foreground">
                    {d.division}
                  </Badge>
                )}
              </CommandItem>
            ))}
          </CommandList>
        </Command>
      </PopoverContent>
    </Popover>
  );
}
