import { useId, useMemo, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Check as CheckIcon, ChevronsUpDown, Plus as PlusIcon } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
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
import { listCatalogs } from "@/lib/api";

export type CatalogOption = {
  name: string;
  comment?: string;
  owner?: string;
};

export type DeploymentCatalogPickerProps = {
  value: string;
  onChange: (v: string) => void;
  disabled?: boolean;
  /** Escape hatch for tests — lets us inject catalogs directly and skip the
   *  `/api/catalogs` fetch so component tests don't depend on MSW or network
   *  mocking. Undefined means "fetch normally". */
  catalogsOverride?: CatalogOption[];
  /** If set (tests), skips the fetch entirely and forces the given state. */
  loadingOverride?: boolean;
  errorOverride?: boolean;
};

async function fetchCatalogs(): Promise<CatalogOption[]> {
  // Phase 7 drift-unification: route through the Orval-generated helper
  // so the request shape + error envelope track the OpenAPI spec. The
  // generated response type is `unknown[]` (the backend returns a list
  // of dicts not modeled in the schema), so we narrow at the boundary.
  const r = await listCatalogs();
  return r.data as CatalogOption[];
}

/**
 * Catalog picker for the Deployment Catalog field. Lists catalogs the app SP
 * can see (auto-filtered by UC), sorted alphabetically, with an inline filter
 * that matches case-insensitively anywhere in the catalog name.
 *
 * Falls back to a plain text input if the listing fails so a broken listing
 * endpoint doesn't block a run.
 *
 * Filters the list client-side (we do NOT rely on cmdk's built-in filter —
 * see #111: the cmdk `filter` prop had inconsistent behavior where typing a
 * matching substring would leave options in the DOM but mark them as hidden
 * in the a11y tree, showing "No catalogs match" even when matches existed).
 *
 * If the typed query doesn't exactly match any existing catalog, surfaces a
 * "Use '<input>'" option so users can commit a new catalog name without
 * having it pre-exist.
 */
export function DeploymentCatalogPicker({
  value,
  onChange,
  disabled,
  catalogsOverride,
  loadingOverride,
  errorOverride,
}: DeploymentCatalogPickerProps) {
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState("");
  // Stable id for the trigger button so external code (and the a11y
  // assertion in our tests) can find it deterministically when the listbox
  // is open.
  const reactId = useId();
  const triggerId = `${reactId}-deployment-catalog-trigger`;

  const query = useQuery({
    queryKey: ["catalogs"],
    queryFn: fetchCatalogs,
    staleTime: 60_000,
    retry: false,
    // When an override is provided (tests) we don't want the real fetch to
    // run — gate the query with `enabled`.
    enabled: catalogsOverride === undefined,
  });

  const data = catalogsOverride ?? query.data;
  const isLoading = loadingOverride ?? (catalogsOverride === undefined && query.isLoading);
  const isError = errorOverride ?? (catalogsOverride === undefined && query.isError);

  const sorted = useMemo(() => {
    if (!data) return [];
    return [...data].sort((a, b) =>
      a.name.localeCompare(b.name, undefined, { sensitivity: "base" }),
    );
  }, [data]);

  const trimmedSearch = search.trim();
  const searchLower = trimmedSearch.toLowerCase();

  const filtered = useMemo(() => {
    if (!trimmedSearch) return sorted;
    return sorted.filter((c) => c.name.toLowerCase().includes(searchLower));
  }, [sorted, searchLower, trimmedSearch]);

  const exactMatch = useMemo(() => {
    if (!trimmedSearch) return false;
    return sorted.some(
      (c) => c.name.toLowerCase() === searchLower,
    );
  }, [sorted, searchLower, trimmedSearch]);

  // Offer a "Use '<input>'" affordance when the user has typed something that
  // isn't an exact match — lets them commit a brand-new catalog name. This
  // mirrors the pattern used elsewhere for free-form picker fields.
  const showCustomOption = Boolean(trimmedSearch) && !exactMatch;

  // Error or unset → plain input fallback so a listing failure doesn't block
  // a run. The live `value` is still driven by the parent.
  if (isError || (!isLoading && !data)) {
    return (
      <Input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder="e.g. my_catalog"
        disabled={disabled}
        data-testid="deployment-catalog-fallback-input"
      />
    );
  }
  // Loading → show the popover button but disable it and label as
  // "Loading…" so the user knows it's in flight, not broken. The
  // previous fallback to a plain <Input> made it look like the picker
  // disappeared while data loaded (Phase 4.5 walkthrough complaint).
  if (isLoading) {
    return (
      <Button
        type="button"
        variant="outline"
        disabled
        className="w-full justify-between font-normal"
        data-testid="deployment-catalog-loading"
      >
        <span className="text-muted-foreground">Loading catalogs…</span>
        <ChevronsUpDown className="h-4 w-4 opacity-50 shrink-0 ml-2" />
      </Button>
    );
  }

  const commitCustom = () => {
    if (!trimmedSearch) return;
    onChange(trimmedSearch);
    setOpen(false);
    setSearch("");
  };

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button
          id={triggerId}
          type="button"
          variant="outline"
          role="combobox"
          aria-expanded={open}
          aria-haspopup="listbox"
          aria-label="Deployment catalog"
          disabled={disabled}
          className="w-full justify-between font-normal"
        >
          <span className={value ? "" : "text-muted-foreground"}>
            {value || "Pick a catalog"}
          </span>
          <ChevronsUpDown className="h-4 w-4 opacity-50 shrink-0 ml-2" />
        </Button>
      </PopoverTrigger>
      <PopoverContent
        className="p-0 w-[var(--radix-popover-trigger-width)]"
        align="start"
      >
        {/* shouldFilter={false} — we filter ourselves in `filtered` above.
            Delegating to cmdk's filter has been unreliable (see #111).

            We drop `CommandGroup` here to fix the model-versioning work F4: cmdk renders
            groups as a `<div role="presentation">` containing a nested
            `<div role="group">` for the items, and inside a portalled Radix
            popover dialog, Chrome's a11y tree was attaching the options to
            the inner group rather than to the parent listbox. Result: an
            "empty listbox" in the a11y snapshot even though the DOM had
            `[role="option"]` nodes — invisible to keyboard / screen-reader
            users. Flattening items directly under `CommandList` puts the
            options where the listbox role expects them.

            We also keep `label="Catalogs"` on `Command` so cmdk wires up a
            non-empty accessible context for the input/list combobox pair. */}
        <Command shouldFilter={false} label="Catalogs">
          <CommandInput
            placeholder="Filter or type a new catalog name…"
            value={search}
            onValueChange={setSearch}
          />
          <CommandList>
            {filtered.length === 0 && !showCustomOption && (
              <CommandEmpty>No catalogs match.</CommandEmpty>
            )}
            {filtered.map((c) => (
              <CommandItem
                key={c.name}
                value={c.name}
                onSelect={() => {
                  onChange(c.name);
                  setOpen(false);
                  setSearch("");
                }}
                className="flex items-center justify-between"
              >
                <span className="truncate">{c.name}</span>
                {value === c.name && (
                  <CheckIcon className="h-4 w-4 shrink-0 ml-2" />
                )}
              </CommandItem>
            ))}
            {showCustomOption && (
              <CommandItem
                // Unique value so cmdk doesn't conflate with a real catalog
                // entry if the user typed a prefix of an existing name.
                value={`__use_custom__::${trimmedSearch}`}
                onSelect={commitCustom}
                className="flex items-center gap-2"
                data-testid="deployment-catalog-use-custom"
              >
                <PlusIcon className="h-4 w-4 shrink-0" />
                <span className="truncate">
                  Use &ldquo;{trimmedSearch}&rdquo;
                </span>
              </CommandItem>
            )}
          </CommandList>
        </Command>
      </PopoverContent>
    </Popover>
  );
}
