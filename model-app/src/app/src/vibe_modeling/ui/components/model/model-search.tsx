import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "@tanstack/react-router";
import { Search, Database, Table2, Columns3 } from "lucide-react";
import {
  Command,
  CommandInput,
  CommandList,
  CommandEmpty,
  CommandGroup,
  CommandItem,
} from "@/components/ui/command";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";
import { useSearchModelElements, type ModelSearchHitOut } from "@/lib/api";
import { selector } from "@/lib/selector";
import { useDebouncedValue } from "@/lib/hooks";

/**
 * Model-wide element search. A header trigger (and a Cmd/Ctrl-K shortcut) opens
 * a command palette that queries the version-scoped `searchModelElements`
 * endpoint (debounced) and lists matches grouped by kind. Selecting a hit
 * navigates, all URL-driven so the destination view is shareable:
 *   - domain  -> the single-domain diagram
 *   - table   -> the single-domain diagram, focused on the product node
 *   - column  -> the tabular product page, the matched column highlighted
 *
 * Scope is naturally the current (version, scope) because the box lives in the
 * model chrome.
 */
export function ModelSearch({
  businessId,
  version,
  scope,
}: {
  businessId: string;
  version: string;
  scope: string;
}) {
  const navigate = useNavigate();
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState("");
  const debouncedQuery = useDebouncedValue(query, 250);
  const trimmed = debouncedQuery.trim();

  // Cmd/Ctrl-K toggles the palette from anywhere on the model page.
  useEffect(() => {
    const onKeyDown = (e: KeyboardEvent) => {
      if (e.key === "k" && (e.metaKey || e.ctrlKey)) {
        e.preventDefault();
        setOpen((v) => !v);
      }
    };
    document.addEventListener("keydown", onKeyDown);
    return () => document.removeEventListener("keydown", onKeyDown);
  }, []);

  // `search_model_elements` (backend/explorer.py) matches on attribute name
  // columns backed by pg_trgm GIN indexes on Postgres. Trigram indexes need
  // 3+ characters to be effective; below that the planner falls back to a
  // sequential scan and the query cost model degrades sharply. Gate the
  // request client-side rather than relying on debounce alone - debounce
  // bounds request *rate*, not the per-request cost of a short query.
  const MIN_QUERY_LENGTH = 3;
  const meetsMinLength = trimmed.length >= MIN_QUERY_LENGTH;

  const { data: hits } = useSearchModelElements({
    params: { business_id: businessId, version_int: Number(version), scope, q: trimmed, limit: 20 },
    query: { enabled: open && meetsMinLength, ...selector<ModelSearchHitOut[]>().query },
  });

  const groups = useMemo(() => {
    const domains: ModelSearchHitOut[] = [];
    const tables: ModelSearchHitOut[] = [];
    const columns: ModelSearchHitOut[] = [];
    for (const hit of hits ?? []) {
      if (hit.type === "domain") domains.push(hit);
      else if (hit.type === "product") tables.push(hit);
      else if (hit.type === "attribute") columns.push(hit);
    }
    return { domains, tables, columns };
  }, [hits]);

  const go = (hit: ModelSearchHitOut) => {
    setOpen(false);
    setQuery("");
    if (hit.type === "domain") {
      navigate({
        to: "/businesses/$businessId/model/$version/$scope/$domainName",
        params: { businessId, version, scope, domainName: hit.domain_name },
        search: { tab: "diagram" },
      });
    } else if (hit.type === "product" && hit.product_name) {
      navigate({
        to: "/businesses/$businessId/model/$version/$scope/$domainName",
        params: { businessId, version, scope, domainName: hit.domain_name },
        search: { tab: "diagram", focusProduct: hit.product_name },
      });
    } else if (hit.type === "attribute" && hit.product_name && hit.attribute_name) {
      navigate({
        to: "/businesses/$businessId/model/$version/$scope/$domainName/$productName",
        params: {
          businessId,
          version,
          scope,
          domainName: hit.domain_name,
          productName: hit.product_name,
        },
        search: { highlightColumn: hit.attribute_name },
      });
    }
  };

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="inline-flex items-center gap-2 rounded-md border border-input bg-background px-2.5 py-1 text-xs text-muted-foreground hover:bg-accent hover:text-accent-foreground"
        title="Search the model (Cmd/Ctrl-K)"
      >
        <Search className="h-3.5 w-3.5" />
        <span className="hidden sm:inline">Search model</span>
        <kbd className="hidden rounded border border-border bg-muted px-1 font-mono text-[10px] sm:inline">
          ⌘K
        </kbd>
      </button>
      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="overflow-hidden p-0">
          {/* Visually-hidden title + description satisfy Radix Dialog's a11y
              contract (DialogTitle required; aria-describedby) without adding a
              visible header above the command input. */}
          <DialogHeader className="sr-only">
            <DialogTitle>Search the model</DialogTitle>
            <DialogDescription>
              Search domains, tables, and columns by name.
            </DialogDescription>
          </DialogHeader>
          {/* shouldFilter=false: the server already ranked + filtered the hits;
              cmdk's default client filter would drop server matches whose label
              does not contain the query (e.g. a table-name-only match). */}
          <Command
            shouldFilter={false}
            className="[&_[cmdk-group-heading]]:px-2 [&_[cmdk-group-heading]]:font-medium [&_[cmdk-group-heading]]:text-muted-foreground [&_[cmdk-group]]:px-2 [&_[cmdk-input-wrapper]_svg]:h-5 [&_[cmdk-input-wrapper]_svg]:w-5 [&_[cmdk-input]]:h-12 [&_[cmdk-item]]:px-2 [&_[cmdk-item]]:py-3 [&_[cmdk-item]_svg]:h-5 [&_[cmdk-item]_svg]:w-5"
          >
            <CommandInput
              placeholder="Search domains, tables, columns..."
              value={query}
              onValueChange={setQuery}
            />
            <CommandList>
          <CommandEmpty>
            {trimmed.length === 0
              ? "Type to search the model."
              : !meetsMinLength
                ? `Type at least ${MIN_QUERY_LENGTH} characters.`
                : "No matches."}
          </CommandEmpty>
          {groups.domains.length > 0 && (
            <CommandGroup heading="Domains">
              {groups.domains.map((hit) => (
                <SearchHitItem key={`d:${hit.domain_name}`} hit={hit} icon={<Database className="h-4 w-4" />} onSelect={go} />
              ))}
            </CommandGroup>
          )}
          {groups.tables.length > 0 && (
            <CommandGroup heading="Tables">
              {groups.tables.map((hit) => (
                <SearchHitItem key={`p:${hit.domain_name}.${hit.product_name}`} hit={hit} icon={<Table2 className="h-4 w-4" />} onSelect={go} />
              ))}
            </CommandGroup>
          )}
          {groups.columns.length > 0 && (
            <CommandGroup heading="Columns">
              {groups.columns.map((hit) => (
                <SearchHitItem
                  key={`a:${hit.domain_name}.${hit.product_name}.${hit.attribute_name}`}
                  hit={hit}
                  icon={<Columns3 className="h-4 w-4" />}
                  onSelect={go}
                />
              ))}
            </CommandGroup>
            )}
            </CommandList>
          </Command>
        </DialogContent>
      </Dialog>
    </>
  );
}

function SearchHitItem({
  hit,
  icon,
  onSelect,
}: {
  hit: ModelSearchHitOut;
  icon: React.ReactNode;
  onSelect: (hit: ModelSearchHitOut) => void;
}) {
  return (
    <CommandItem
      // cmdk uses `value` for its own keyboard nav; keep it unique per hit.
      value={`${hit.type}:${hit.sublabel}:${hit.label}`}
      onSelect={() => onSelect(hit)}
    >
      <span className="mr-2 text-muted-foreground">{icon}</span>
      <span className="font-medium">{hit.label}</span>
      {hit.sublabel && (
        <span className="ml-2 truncate text-xs text-muted-foreground">{hit.sublabel}</span>
      )}
    </CommandItem>
  );
}
