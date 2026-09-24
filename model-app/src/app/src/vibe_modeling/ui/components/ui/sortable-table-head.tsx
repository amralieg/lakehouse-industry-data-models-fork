import * as React from "react";
import { ChevronDown, ChevronUp, ChevronsUpDown } from "lucide-react";
import { TableHead } from "@/components/ui/table";

export type SortDir = "asc" | "desc" | null;

/** Shared hook for client-side table sorting.
 *
 *  - Click a column header to cycle asc → desc → unsorted.
 *  - `toggle(key)` flips the state machine.
 *  - `sorted` returns the sorted rows in the current order (or the original
 *    array when unsorted), which keeps the rendering logic a one-liner.
 *
 *  Accepts an `accessor` per key because some columns are derived (e.g.
 *  computed duration, nullable dates) and a simple `row[key]` isn't enough.
 */
export function useTableSort<T>({
  rows,
  accessors,
  initialKey = null,
  initialDir = "asc",
}: {
  rows: T[];
  accessors: Record<string, (row: T) => number | string | Date | null | undefined>;
  initialKey?: string | null;
  initialDir?: Exclude<SortDir, null>;
}) {
  const [sortKey, setSortKey] = React.useState<string | null>(initialKey);
  const [sortDir, setSortDir] = React.useState<SortDir>(
    initialKey ? initialDir : null,
  );

  const toggle = React.useCallback(
    (key: string) => {
      if (sortKey !== key) {
        setSortKey(key);
        setSortDir("asc");
        return;
      }
      // Same key — cycle asc → desc → unsorted
      if (sortDir === "asc") setSortDir("desc");
      else if (sortDir === "desc") {
        setSortKey(null);
        setSortDir(null);
      } else setSortDir("asc");
    },
    [sortKey, sortDir],
  );

  const sorted = React.useMemo(() => {
    if (!sortKey || !sortDir) return rows;
    const acc = accessors[sortKey];
    const dir = sortDir === "asc" ? 1 : -1;
    return [...rows].sort((a, b) => {
      const va = acc(a);
      const vb = acc(b);
      if (va == null && vb == null) return 0;
      if (va == null) return dir;
      if (vb == null) return -dir;
      if (va instanceof Date && vb instanceof Date) {
        return (va.getTime() - vb.getTime()) * dir;
      }
      if (typeof va === "number" && typeof vb === "number") {
        return (va - vb) * dir;
      }
      return String(va).localeCompare(String(vb)) * dir;
    });
  }, [rows, sortKey, sortDir, accessors]);

  return { sorted, sortKey, sortDir, toggle };
}

export function SortableTableHead({
  columnKey,
  sortKey,
  sortDir,
  onToggle,
  className,
  children,
}: {
  columnKey: string;
  sortKey: string | null;
  sortDir: SortDir;
  onToggle: (key: string) => void;
  className?: string;
  children: React.ReactNode;
}) {
  const isActive = sortKey === columnKey && sortDir !== null;
  const Icon = !isActive
    ? ChevronsUpDown
    : sortDir === "asc"
      ? ChevronUp
      : ChevronDown;
  return (
    <TableHead className={className}>
      <button
        type="button"
        onClick={() => onToggle(columnKey)}
        className={`inline-flex items-center gap-1 hover:text-foreground transition-colors ${isActive ? "text-foreground" : "text-muted-foreground"}`}
      >
        {children}
        <Icon className="h-3 w-3" />
      </button>
    </TableHead>
  );
}
