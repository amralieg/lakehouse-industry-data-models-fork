import { useState } from "react";
import { Link, useNavigate } from "@tanstack/react-router";
import { useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import {
  Beaker,
  Clock,
  Check,
  Download,
  RefreshCw,
  Sparkles,
  Trash,
} from "lucide-react";
import {
  createRun,
  forceResyncVersion,
  Intent,
  useListRunsForVersion,
  type RunListOut,
} from "@/lib/api";
import { selector } from "@/lib/selector";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { LaunchRunDialog } from "@/components/runs/launch-run-dialog";
import { PublishVersionDialog } from "@/components/overview/publish-version-dialog";
import { formatRelative } from "@/lib/date";

/**
 * Compact command strip — replaces the old space-wasting "Actions on …" and
 * "Runs for this version" cards (design: `.cmd-strip`). One bordered row:
 *   left  — a "Manage" overline + the version-lifecycle actions
 *           (Install / Uninstall / Generate samples / Re-sync, plus the
 *           ECM-only "Prepare new Vibe" entry to the compose surface);
 *           preserves the same dialogs + logic the cards used.
 *   right — run-status summary ("N runs · latest <ago>") + an "Installed"
 *           success badge when deployed.
 *
 * Design-of-record: docs/design/model-overview/README.md.
 */
export function CommandStrip({
  businessId,
  businessName,
  versionId,
  versionNum,
  scope,
  deploymentStatus,
  defaultTargetPath,
}: {
  businessId: string;
  businessName?: string;
  versionId: string;
  versionNum: number;
  scope?: string;
  deploymentStatus: string;
  /** Pre-fill for the publish dialog's editable bundle-root (ADR D-049). */
  defaultTargetPath?: string;
}) {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [launching, setLaunching] = useState<string>("");
  const [error, setError] = useState("");
  const [pending, setPending] = useState<{ op: Intent; label: string } | null>(
    null,
  );
  const [resyncOpen, setResyncOpen] = useState(false);
  const [resyncing, setResyncing] = useState(false);

  const { data: runs } = useListRunsForVersion({
    params: { version_id: versionId },
    query: {
      // Active runs flip status often; idle runs don't. 3s while anything is
      // in flight, off entirely once everything is terminal (mirrors the old
      // RunsForVersionCard cadence).
      refetchInterval: (query) => {
        const rows = query.state.data?.data;
        if (!rows) return 5000;
        const active = rows.some(
          (r) =>
            r.status === "running" ||
            r.status === "pending" ||
            r.status === "stale",
        );
        return active ? 3000 : false;
      },
      staleTime: 0,
      ...selector<RunListOut[]>().query,
    },
  });

  const handleResync = async () => {
    setResyncing(true);
    setError("");
    try {
      await forceResyncVersion({ business_id: businessId, version_id: versionId });
      // Resync rewrites domains/products/attributes/FKs and re-materializes
      // the agent next-vibe inputs — invalidate everything keyed off this
      // business so the summary, version list, runs, and next-vibes views all
      // re-fetch.
      await queryClient.invalidateQueries();
      setResyncOpen(false);
    } catch (err: unknown) {
      const e = err as { body?: { detail?: string }; message?: string };
      setError(e?.body?.detail || e?.message || String(err));
    } finally {
      setResyncing(false);
    }
  };

  const runLaunch = async (op: Intent, label: string) => {
    setLaunching(label);
    setError("");
    try {
      const res = await createRun(
        { business_id: businessId },
        { intent: op, version_id: versionId },
      );
      // Non-blocking gates (e.g. re-installing an already-deployed version)
      // surface here instead of a debounced pre-submit validate call - this
      // strip launches runs directly, with no live-validate step beforehand.
      for (const w of res.data.warnings ?? []) {
        const message = (w as { message?: string }).message;
        if (message) toast.warning(message);
      }
      navigate({
        to: "/businesses/$businessId/runs/$runId",
        params: { businessId, runId: res.data.id },
      });
    } catch (err: unknown) {
      const e = err as { body?: { detail?: string }; message?: string };
      setError(e?.body?.detail || e?.message || String(err));
      setLaunching("");
      setPending(null);
    }
  };

  const requestLaunch = (op: Intent, label: string) => {
    setError("");
    setPending({ op, label });
  };

  const isInstalled = deploymentStatus === "deployed";
  const versionLabel = scope
    ? `v${versionNum} ${scope.toUpperCase()}`
    : `v${versionNum}`;

  const runRows = runs ?? [];
  const latest = runRows[0];
  const latestAt = latest?.started_at || latest?.created_at;

  return (
    <div
      data-testid="overview-command-strip"
      className="flex flex-wrap items-center gap-x-3 gap-y-2 rounded-md border border-border bg-card px-3 py-1.5"
    >
      <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
        Manage
      </span>
      <div className="flex flex-wrap items-center gap-1.5">
        <Button
          variant="outline"
          size="sm"
          disabled={!!launching}
          onClick={() => requestLaunch(Intent.install, "install")}
          title={
            isInstalled
              ? "Re-install this version into Unity Catalog"
              : "Install this model version into Unity Catalog"
          }
        >
          <Download
            className={`h-4 w-4 mr-1.5 ${launching === "install" ? "animate-spin" : ""}`}
          />
          {launching === "install"
            ? "Starting..."
            : isInstalled
              ? "Re-install"
              : "Install"}
        </Button>
        <Button
          variant="ghost"
          size="sm"
          disabled={!!launching || !isInstalled}
          onClick={() => requestLaunch(Intent.uninstall, "uninstall")}
          title={
            isInstalled
              ? "Uninstall this version from Unity Catalog"
              : "Version is not installed"
          }
        >
          <Trash
            className={`h-4 w-4 mr-1.5 ${launching === "uninstall" ? "animate-spin" : ""}`}
          />
          {launching === "uninstall" ? "Starting..." : "Uninstall"}
        </Button>
        <Button
          variant="ghost"
          size="sm"
          disabled={!!launching || !isInstalled}
          onClick={() => requestLaunch(Intent["generate-samples"], "samples")}
          title={
            isInstalled
              ? "Generate sample rows for each installed table"
              : "Install the version first"
          }
        >
          <Beaker
            className={`h-4 w-4 mr-1.5 ${launching === "samples" ? "animate-spin" : ""}`}
          />
          {launching === "samples" ? "Starting..." : "Generate samples"}
        </Button>
        {/* "Prepare new Vibe" is ECM-only — you vibe from ECM, which regenerates
            the MVM in the same run. It opens the prepare/compose surface (pick
            inputs, then Start run) rather than launching a run directly with
            nothing selected. The combined ECM+MVM operation is still selectable
            on the run form. */}
        {scope === "ecm" && (
          <Button
            variant="ghost"
            size="sm"
            data-testid="prepare-new-vibe"
            disabled={!!launching}
            asChild
            title="Prepare a new vibe: pick inputs on the compose surface, then start the run"
          >
            <Link
              to="/businesses/$businessId/model/$version/$scope/inputs"
              params={{ businessId, version: String(versionNum), scope }}
            >
              <Sparkles className="h-4 w-4 mr-1.5" />
              Prepare new Vibe
            </Link>
          </Button>
        )}
        <Button
          variant="ghost"
          size="sm"
          disabled={!!launching || resyncing}
          onClick={() => {
            setError("");
            setResyncOpen(true);
          }}
          title="Re-read this version's generated model and suggestions from the source files into the app"
        >
          <RefreshCw
            className={`h-4 w-4 mr-1.5 ${resyncing ? "animate-spin" : ""}`}
          />
          {resyncing ? "Re-syncing..." : "Re-sync"}
        </Button>
        <PublishVersionDialog
          businessId={businessId}
          versionId={versionId}
          versionNum={versionNum}
          scope={scope}
          defaultTargetPath={defaultTargetPath}
        />
      </div>

      <div className="ml-auto flex items-center gap-3">
        {runRows.length > 0 ? (
          <Link
            to="/businesses/$businessId/runs/$runId"
            params={{ businessId, runId: latest?.id ?? "" }}
            className="flex items-center gap-1.5 whitespace-nowrap text-xs text-muted-foreground hover:text-foreground"
            title="Open the latest run for this version"
          >
            <Clock className="h-3.5 w-3.5" />
            <span>
              <strong className="text-foreground">{runRows.length}</strong>{" "}
              {runRows.length === 1 ? "run" : "runs"}
              {latestAt && (
                <>
                  {" · latest "}
                  <span className="text-foreground">{formatRelative(latestAt)}</span>
                </>
              )}
            </span>
          </Link>
        ) : (
          <span className="flex items-center gap-1.5 whitespace-nowrap text-xs text-muted-foreground">
            <Clock className="h-3.5 w-3.5" />
            No runs yet
          </span>
        )}
        {isInstalled && (
          <Badge
            variant="outline"
            className="gap-1 border-success/40 bg-success/15 text-success"
          >
            <Check className="h-3 w-3" />
            Installed
          </Badge>
        )}
      </div>

      {error && (
        <p className="basis-full pt-0.5 text-xs text-destructive">{error}</p>
      )}

      <LaunchRunDialog
        open={pending !== null}
        operationType={pending?.op ?? ""}
        businessName={businessName ?? "this business"}
        versionLabel={versionLabel}
        submitting={!!launching}
        onConfirm={() => {
          if (pending) void runLaunch(pending.op, pending.label);
        }}
        onCancel={() => {
          if (!launching) setPending(null);
        }}
      />
      <Dialog
        open={resyncOpen}
        onOpenChange={(open) => {
          if (!resyncing) setResyncOpen(open);
        }}
      >
        <DialogContent className={resyncing ? "[&>button]:hidden" : ""}>
          <DialogHeader>
            <DialogTitle>Re-sync model data from source?</DialogTitle>
            <DialogDescription>
              This re-reads the generated model and suggestions for{" "}
              {versionLabel} from the source files and refreshes the app's copy.
              Useful when the underlying files changed but the app still shows
              stale data.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <DialogClose asChild>
              <Button variant="outline" disabled={resyncing}>
                Cancel
              </Button>
            </DialogClose>
            <Button onClick={handleResync} disabled={resyncing}>
              {resyncing ? "Re-syncing..." : "Re-sync"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
