import { useEffect, useMemo, useState } from "react";
import { Skeleton } from "@/components/ui/skeleton";

const MAX_ROWS = 500;
const MAX_COLS = 50;

type SheetData = {
  name: string;
  rows: unknown[][];
  totalRows: number;
  totalCols: number;
};

type WorkbookSnapshot = {
  sheetNames: string[];
  sheets: Record<string, SheetData>;
};

export function ExcelPreview({
  src,
  filename,
}: {
  src: string;
  filename: string;
}) {
  const [workbook, setWorkbook] = useState<WorkbookSnapshot | null>(null);
  const [activeSheet, setActiveSheet] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    setError(null);
    setWorkbook(null);

    (async () => {
      try {
        const response = await fetch(src);
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }
        const buffer = await response.arrayBuffer();
        const XLSX = await import("xlsx");
        const wb = XLSX.read(buffer, { type: "array" });

        const sheets: Record<string, SheetData> = {};
        for (const name of wb.SheetNames) {
          const ws = wb.Sheets[name];
          if (!ws) continue;
          const all = XLSX.utils.sheet_to_json<unknown[]>(ws, {
            header: 1,
            defval: "",
            blankrows: false,
          });
          const totalRows = all.length;
          const totalCols = all.reduce(
            (m, row) => Math.max(m, Array.isArray(row) ? row.length : 0),
            0,
          );
          const rows = all.slice(0, MAX_ROWS).map((row) =>
            Array.isArray(row) ? row.slice(0, MAX_COLS) : [],
          );
          sheets[name] = { name, rows, totalRows, totalCols };
        }

        if (cancelled) return;
        setWorkbook({ sheetNames: wb.SheetNames, sheets });
        setActiveSheet(wb.SheetNames[0] ?? null);
        setLoading(false);
      } catch (err) {
        if (cancelled) return;
        setError(err instanceof Error ? err.message : String(err));
        setLoading(false);
      }
    })();

    return () => {
      cancelled = true;
    };
  }, [src]);

  const current = useMemo<SheetData | null>(() => {
    if (!workbook || !activeSheet) return null;
    return workbook.sheets[activeSheet] ?? null;
  }, [workbook, activeSheet]);

  if (loading) {
    return (
      <div data-testid="excel-preview-loading" className="space-y-2">
        <Skeleton className="h-6 w-48" />
        <Skeleton className="h-40 w-full rounded-md" />
      </div>
    );
  }

  if (error) {
    return (
      <p className="text-xs text-destructive">
        Could not load spreadsheet preview: {error}
      </p>
    );
  }

  if (!workbook || !current) {
    return (
      <p className="text-xs text-muted-foreground">
        Spreadsheet has no readable sheets. Download {filename} to inspect.
      </p>
    );
  }

  const truncatedRows = current.totalRows > current.rows.length;
  const truncatedCols =
    current.totalCols > (current.rows[0]?.length ?? 0) &&
    current.totalCols > MAX_COLS;
  const headerRow = current.rows[0] ?? [];
  const bodyRows = current.rows.slice(1);

  return (
    <div className="space-y-2" data-testid="excel-preview">
      {workbook.sheetNames.length > 1 && (
        <div
          role="tablist"
          aria-label={`Sheets in ${filename}`}
          className="flex flex-wrap gap-1 border-b border-border/60 pb-1"
        >
          {workbook.sheetNames.map((name) => {
            const isActive = name === activeSheet;
            return (
              <button
                key={name}
                type="button"
                role="tab"
                aria-selected={isActive}
                onClick={() => setActiveSheet(name)}
                className={
                  isActive
                    ? "px-2 py-0.5 text-[11px] rounded-md bg-primary/10 text-primary border border-primary/30"
                    : "px-2 py-0.5 text-[11px] rounded-md text-muted-foreground hover:bg-muted/60 border border-transparent"
                }
              >
                {name}
              </button>
            );
          })}
        </div>
      )}
      {(truncatedRows || truncatedCols) && (
        <p className="text-[10px] text-warning">
          {truncatedRows &&
            `Showing first ${current.rows.length} of ${current.totalRows} rows. `}
          {truncatedCols &&
            `Showing first ${MAX_COLS} of ${current.totalCols} columns. `}
          Download for the full sheet.
        </p>
      )}
      <div className="max-h-[min(28rem,70vh)] overflow-auto rounded-md border border-border/60 bg-background">
        <table className="border-collapse text-[11px] w-full">
          <thead className="sticky top-0 bg-muted/60">
            <tr>
              {headerRow.map((cell, idx) => (
                <th
                  key={idx}
                  className="border border-border px-2 py-1 text-left font-semibold"
                >
                  {formatCell(cell)}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {bodyRows.map((row, rowIdx) => (
              <tr key={rowIdx} className="odd:bg-muted/20">
                {Array.from({ length: headerRow.length }).map((_, colIdx) => (
                  <td
                    key={colIdx}
                    className="border border-border px-2 py-1 align-top"
                  >
                    {formatCell(row[colIdx])}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function formatCell(v: unknown): string {
  if (v === null || v === undefined) return "";
  if (typeof v === "string") return v;
  if (typeof v === "number" || typeof v === "boolean") return String(v);
  if (v instanceof Date) return v.toISOString();
  return JSON.stringify(v);
}
