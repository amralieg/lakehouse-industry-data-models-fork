/**
 * Volume picker dialog — drill from catalogs → schemas → volumes → directory
 * contents and pick a `.json` file. The Import dialog populates its
 * Volume-path text input from `onSelect(path)`. Free-text input still works
 * for users who already know the path.
 *
 * Backend contract: `GET /api/uc/volumes/browse?path=<p>` — see
 * `backend/routes/uc_browse.py` for the path grammar. This component owns
 * its own fetch + react-query hook because the OpenAPI client is auto
 * regenerated on dev start; hand-editing `lib/api.ts` would drift on the
 * next regen. The shape mirrors what the generator produces.
 */

import { Suspense, useState } from "react";
import { useSuspenseQuery, QueryErrorResetBoundary } from "@tanstack/react-query";
import { ErrorBoundary } from "react-error-boundary";
import { ChevronRight, Folder, File, Database, AlertTriangle, Loader2 } from "lucide-react";

import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Skeleton } from "@/components/ui/skeleton";
import { ApiError } from "@/lib/api";

type VolumeBrowseKind = "catalog" | "schema" | "volume" | "dir" | "file";

export interface VolumeBrowseEntry {
  name: string;
  is_dir: boolean;
  kind: VolumeBrowseKind;
  size_bytes: number | null;
  modified_at: string | null;
}

interface VolumeBrowseOut {
  path: string;
  parent: string | null;
  entries: VolumeBrowseEntry[];
  truncated: boolean;
}

async function browseVolumes(path: string): Promise<VolumeBrowseOut> {
  const url = "/api/uc/volumes/browse?path=" + encodeURIComponent(path);
  const res = await fetch(url, { method: "GET" });
  if (!res.ok) {
    const body = await res.text();
    let parsed: unknown = body;
    try { parsed = JSON.parse(body); } catch { /* keep string */ }
    throw new ApiError(res.status, res.statusText, parsed);
  }
  return (await res.json()) as VolumeBrowseOut;
}

function useBrowseVolumesSuspense(path: string) {
  return useSuspenseQuery<VolumeBrowseOut, ApiError>({
    queryKey: ["/api/uc/volumes/browse", path],
    queryFn: () => browseVolumes(path),
  });
}

interface VolumePickerProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSelect: (path: string) => void;
}

export function VolumePicker({ open, onOpenChange, onSelect }: VolumePickerProps) {
  // Path is local component state so the dialog remembers where the user was
  // browsing if they close & re-open within the same session.
  const [path, setPath] = useState<string>("");
  const [selectedFile, setSelectedFile] = useState<string | null>(null);

  const handleSelect = () => {
    if (!selectedFile) return;
    onSelect(selectedFile);
    onOpenChange(false);
    // Don't reset path — keep last location for next open.
    setSelectedFile(null);
  };

  const handleCancel = () => {
    setSelectedFile(null);
    onOpenChange(false);
  };

  return (
    <Dialog
      open={open}
      onOpenChange={(v) => {
        if (!v) setSelectedFile(null);
        onOpenChange(v);
      }}
    >
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>Browse Unity Catalog Volumes</DialogTitle>
        </DialogHeader>

        <Breadcrumb path={path} onNavigate={(p) => { setPath(p); setSelectedFile(null); }} />

        <div className="max-h-[420px] min-h-[200px] overflow-y-auto rounded-md border">
          <QueryErrorResetBoundary>
            {({ reset }) => (
              <ErrorBoundary
                onReset={reset}
                resetKeys={[path]}
                fallbackRender={({ error, resetErrorBoundary }) => (
                  <PickerError error={error} onRetry={resetErrorBoundary} />
                )}
              >
                <Suspense fallback={<PickerSkeleton />}>
                  <EntryList
                    path={path}
                    selectedFile={selectedFile}
                    onNavigate={(p) => { setPath(p); setSelectedFile(null); }}
                    onPickFile={setSelectedFile}
                  />
                </Suspense>
              </ErrorBoundary>
            )}
          </QueryErrorResetBoundary>
        </div>

        {selectedFile && (
          <p className="text-xs text-muted-foreground truncate" title={selectedFile}>
            Selected: <span className="font-mono">{selectedFile}</span>
          </p>
        )}

        <DialogFooter>
          <Button variant="outline" onClick={handleCancel}>
            Cancel
          </Button>
          <Button
            onClick={handleSelect}
            disabled={!selectedFile}
          >
            Select
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

function Breadcrumb({
  path,
  onNavigate,
}: {
  path: string;
  onNavigate: (path: string) => void;
}) {
  const parts = path === "" ? [] : path.split("/").filter(Boolean);

  return (
    <div className="flex items-center gap-1 text-sm flex-wrap">
      <button
        type="button"
        onClick={() => onNavigate("")}
        className="hover:underline text-muted-foreground font-medium"
      >
        Catalogs
      </button>
      {parts.map((part, i) => {
        const upto = "/" + parts.slice(0, i + 1).join("/");
        const isLast = i === parts.length - 1;
        return (
          <span key={i} className="flex items-center gap-1">
            <ChevronRight className="h-3 w-3 text-muted-foreground shrink-0" />
            <button
              type="button"
              onClick={() => onNavigate(upto)}
              className={
                "hover:underline " +
                (isLast ? "font-medium" : "text-muted-foreground")
              }
              disabled={isLast}
            >
              {part}
            </button>
          </span>
        );
      })}
    </div>
  );
}

function EntryList({
  path,
  selectedFile,
  onNavigate,
  onPickFile,
}: {
  path: string;
  selectedFile: string | null;
  onNavigate: (path: string) => void;
  onPickFile: (path: string) => void;
}) {
  const { data } = useBrowseVolumesSuspense(path);

  if (data.entries.length === 0) {
    return (
      <p className="p-6 text-center text-sm text-muted-foreground">
        Nothing here yet.
      </p>
    );
  }

  return (
    <>
      <ul role="list" className="divide-y">
        {data.entries.map((entry) => {
          const childPath = childPathFor(path, entry);
          const isJson = !entry.is_dir && entry.name.toLowerCase().endsWith(".json");
          const isSelected = childPath === selectedFile;
          return (
            <li key={entry.name}>
              <button
                type="button"
                onClick={() => {
                  if (entry.is_dir) {
                    onNavigate(childPath);
                  } else if (isJson) {
                    onPickFile(childPath);
                  }
                }}
                disabled={!entry.is_dir && !isJson}
                className={
                  "w-full flex items-center gap-2 px-3 py-2 text-sm text-left " +
                  "hover:bg-accent disabled:opacity-50 disabled:hover:bg-transparent " +
                  (isSelected ? "bg-accent" : "")
                }
              >
                <EntryIcon kind={entry.kind} />
                <span className="flex-1 truncate">{entry.name}</span>
                {!entry.is_dir && entry.size_bytes != null && (
                  <span className="text-xs text-muted-foreground tabular-nums">
                    {formatSize(entry.size_bytes)}
                  </span>
                )}
                {entry.is_dir && (
                  <ChevronRight className="h-3 w-3 text-muted-foreground" />
                )}
              </button>
            </li>
          );
        })}
      </ul>
      {data.truncated && (
        <p className="px-3 py-2 text-xs text-muted-foreground border-t">
          Showing first 500 entries — refine by drilling into a sub-folder.
        </p>
      )}
    </>
  );
}

function EntryIcon({ kind }: { kind: VolumeBrowseKind }) {
  const cn = "h-4 w-4 shrink-0";
  if (kind === "catalog" || kind === "schema") {
    return <Database className={cn + " text-info"} />;
  }
  if (kind === "volume" || kind === "dir") {
    return <Folder className={cn + " text-warning"} />;
  }
  return <File className={cn + " text-muted-foreground"} />;
}

function PickerSkeleton() {
  return (
    <div className="p-3 space-y-2">
      <div className="flex items-center gap-2">
        <Loader2 className="h-3 w-3 animate-spin text-muted-foreground" />
        <span className="text-xs text-muted-foreground">Loading…</span>
      </div>
      {Array.from({ length: 4 }).map((_, i) => (
        <Skeleton key={i} className="h-6 w-full" />
      ))}
    </div>
  );
}

function PickerError({ error, onRetry }: { error: unknown; onRetry: () => void }) {
  let message = "Failed to load.";
  if (error instanceof ApiError) {
    if (error.status === 403) {
      message = "Access denied. The app service principal cannot read this path.";
    } else if (error.status === 404) {
      message = "Path not found.";
    } else {
      message = `Failed to load (HTTP ${error.status}).`;
    }
  } else if (error instanceof Error) {
    message = error.message;
  }
  return (
    <div className="p-4 text-sm space-y-2">
      <div className="flex items-start gap-2 text-destructive">
        <AlertTriangle className="h-4 w-4 mt-0.5 shrink-0" />
        <p>{message}</p>
      </div>
      <Button variant="outline" size="sm" onClick={onRetry}>
        Try again
      </Button>
    </div>
  );
}

/** Compose the child path given the parent and an entry.
 *
 * - At "" (catalog list), entries are catalogs → child is `/<name>`.
 * - At `/<c>` (schema list), child is `/<c>/<name>`.
 * - At `/<c>/<s>` (volume list), child is `/Volumes/<c>/<s>/<name>` — the
 *   key transition: from UC three-level namespace into Volume-path syntax.
 * - At `/Volumes/<c>/<s>/<v>[/sub]`, child is `<path>/<name>`.
 */
export function childPathFor(parent: string, entry: VolumeBrowseEntry): string {
  if (entry.kind === "volume") {
    // parent is "/<c>/<s>"; child becomes the canonical /Volumes/ form.
    return "/Volumes" + parent + "/" + entry.name;
  }
  if (parent === "") return "/" + entry.name;
  return parent + "/" + entry.name;
}

function formatSize(n: number): string {
  if (n < 1024) return `${n} B`;
  if (n < 1024 * 1024) return `${(n / 1024).toFixed(1)} KB`;
  if (n < 1024 * 1024 * 1024) return `${(n / 1024 / 1024).toFixed(1)} MB`;
  return `${(n / 1024 / 1024 / 1024).toFixed(2)} GB`;
}
