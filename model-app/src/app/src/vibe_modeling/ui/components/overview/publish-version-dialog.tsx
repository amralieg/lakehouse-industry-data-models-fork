import { useCallback, useEffect, useRef, useState } from "react";
import { Link } from "@tanstack/react-router";
import {
  AlertTriangle,
  ExternalLink,
  FileText,
  GitBranch,
  GitCompare,
  GitPullRequest,
  Settings,
  Upload,
} from "lucide-react";
import {
  ApiError,
  useGetGithubConfig,
  usePreviewPublishModelVersion,
  usePublishModelVersion,
  type DiffRowOut,
  type PublishModelVersionOut,
  type PublishPreviewOut,
} from "@/lib/api";
import { selector } from "@/lib/selector";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import {
  ChangeBadge,
  changeRowClassName,
} from "@/components/explorer/change-badge";

/**
 * Publish-to-GitHub action + confirm dialog for the version command strip
 * (Story 10 / Track D). Opens a PR carrying the version's model artifacts.
 *
 * Un-configured-connection degradation (the human-gated stop):
 *   - PRE-CHECK: reads `useGetGithubConfig` (NON-suspense, so it never blocks
 *     the command strip render) and disables the trigger with a tooltip
 *     linking to `/settings?tab=sources` when `connection_name` is empty.
 *   - DEGRADE on 422: if a publish call still 422s (race / mode mismatch),
 *     parses `detail.error` (`github_connection_missing` /
 *     `github_pat_not_implemented`) and shows a clean Settings link inline
 *     instead of a raw error.
 *
 * The GitHub publish config lives on the Settings "sources" tab (Track 4 IA).
 * `validateSearch` also redirects the legacy `?tab=github` deep-link to
 * `sources`, so older links stay robust.
 */
const SETTINGS_GITHUB_SEARCH = { tab: "sources" } as const;

function settingsLinkMessage(error?: string): string {
  if (error === "github_pat_not_implemented") {
    return "Personal-access-token publishing isn't available yet. Switch to an OAuth UC connection in Settings.";
  }
  // github_connection_missing and any other config-shaped 422.
  return "GitHub publishing isn't configured yet. Set up a UC HTTP connection in Settings, then try again.";
}

function DiffRows({ rows }: { rows: DiffRowOut[] }) {
  return (
    <>
      {rows.map((row, i) => (
        <div
          key={`${row.domain}/${row.product ?? ""}/${row.attribute ?? ""}/${i}`}
          className={`flex items-center gap-1.5 rounded-sm px-1 py-0.5 font-mono text-xs ${changeRowClassName(
            row.status,
          )}`}
        >
          <ChangeBadge status={row.status} />
          <span>
            {[row.domain, row.product, row.attribute].filter(Boolean).join(" / ")}
          </span>
        </div>
      ))}
    </>
  );
}

/**
 * Prepublish diff-preview render block (Story 3): a baseline indicator, a
 * warning chip on fallback/scope-mismatch, manual-pick + skip affordances when
 * no baseline resolved, and the flattened model.json diff (ChangeBadge + the
 * shared row tint). The "no changes" empty-state is driven by the diff counts
 * summing to 0 (a real all-unchanged diff), NOT by `diff === null` (which means
 * manual_needed). A preview error degrades to a soft banner and never blocks
 * publish.
 */
function PreviewSection({
  data,
  error,
  onPickBaseline,
  onSkip,
}: {
  data: PublishPreviewOut | null;
  error: boolean;
  onPickBaseline: (id: string) => void;
  onSkip: () => void;
}) {
  if (error) {
    return (
      <div
        className="rounded-md border border-warning/40 bg-warning/10 p-2 text-xs"
        data-testid="preview-error"
      >
        Couldn&apos;t preview changes — you can still publish.
      </div>
    );
  }
  if (!data) return null;

  const warn = data.tier === "fallback_unverified" || data.scope_mismatch;

  if (data.manual_needed) {
    return (
      <div
        className="space-y-2 rounded-md border border-border bg-muted/30 p-2 text-xs"
        data-testid="preview-manual"
      >
        <p className="font-medium">
          No matching baseline was found in the repository.
        </p>
        {data.candidates && data.candidates.length > 0 && (
          <div className="space-y-1">
            <p className="text-muted-foreground">Pick a version to diff against:</p>
            <div className="flex flex-wrap gap-1.5">
              {data.candidates.map((c) => (
                <Button
                  key={c.model_id}
                  variant="outline"
                  size="sm"
                  className="h-6 px-2 text-xs"
                  onClick={() => onPickBaseline(c.model_id)}
                >
                  {c.name}
                </Button>
              ))}
            </div>
          </div>
        )}
        <Button
          variant="ghost"
          size="sm"
          className="h-6 px-2 text-xs"
          data-testid="preview-skip"
          onClick={onSkip}
        >
          Skip diff &amp; publish
        </Button>
      </div>
    );
  }

  const diff = data.diff;
  const counts = diff?.counts ?? {};
  const total =
    (counts.new ?? 0) + (counts.modified ?? 0) + (counts.deleted ?? 0);

  return (
    <div className="space-y-2 text-xs">
      <div className="flex items-center gap-2">
        {data.baseline && (
          <span
            className="inline-flex items-center gap-1 text-muted-foreground"
            data-testid="preview-baseline"
          >
            <GitCompare className="h-3.5 w-3.5" />
            Baseline: <code className="font-mono">{data.baseline.model_id}</code>
          </span>
        )}
        {warn && (
          <span
            className="inline-flex items-center gap-1 rounded-sm border border-warning/40 bg-warning/10 px-1.5 py-0.5 text-warning"
            data-testid="preview-warning"
          >
            <AlertTriangle className="h-3 w-3" />
            {data.scope_mismatch ? "Different scope" : "Unverified baseline"}
          </span>
        )}
      </div>

      {diff && total === 0 ? (
        <p className="text-muted-foreground" data-testid="preview-no-changes">
          No changes from the baseline.
        </p>
      ) : diff ? (
        <div
          className="max-h-48 space-y-0.5 overflow-auto rounded-sm border border-border bg-muted/40 p-2"
          data-testid="preview-diff"
        >
          <DiffRows rows={diff.domains ?? []} />
          <DiffRows rows={diff.products ?? []} />
          <DiffRows rows={diff.attributes ?? []} />
        </div>
      ) : null}
    </div>
  );
}

export function PublishVersionDialog({
  businessId,
  versionId,
  versionNum,
  scope,
  defaultTargetPath,
}: {
  businessId: string;
  versionId: string;
  versionNum: number;
  scope?: string;
  /** Pre-fill for the editable publish target (bundle root incl. version
   * folder), derived from the business's source_repo_path (ADR D-049). */
  defaultTargetPath?: string;
}) {
  const [open, setOpen] = useState(false);
  const [result, setResult] = useState<PublishModelVersionOut | null>(null);
  // A config-shaped 422 (`github_connection_missing` / `github_pat_not_implemented`)
  // degrades to a Settings link; any other failure renders as a plain banner.
  const [degraded, setDegraded] = useState<string | null>(null);
  const [error, setError] = useState("");
  // The editable publish target (pre-confirm state only). Empty -> the backend
  // resolves the root from source_repo_path / the business name.
  const [targetPath, setTargetPath] = useState(defaultTargetPath ?? "");

  // PRE-CHECK: non-suspense read so the command strip never blocks on it.
  // `selector()` unwraps the `{ data }` envelope, so `config` is the
  // `GithubConfigOut` directly (mirrors the Settings sections).
  const { data: config } = useGetGithubConfig(selector());
  const connectionName = config?.connection_name ?? "";
  const configured = connectionName.trim().length > 0;

  const publish = usePublishModelVersion();

  // --- Prepublish diff-preview (Story 3) ----------------------------------
  // Lazy: fetched on dialog open / "Preview changes", debounced on targetPath
  // change. Degrade-open: a preview failure surfaces a soft banner and NEVER
  // disables confirm (confirm.disabled is driven only by publish.isPending).
  const preview = usePreviewPublishModelVersion();
  const [previewData, setPreviewData] = useState<PublishPreviewOut | null>(null);
  const [previewError, setPreviewError] = useState(false);
  const [chosenBaseline, setChosenBaseline] = useState<string | undefined>(
    undefined,
  );
  const [skipDiff, setSkipDiff] = useState(false);
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const runPreview = useCallback(
    async (path: string, baseline: string | undefined) => {
      setPreviewError(false);
      try {
        const res = await preview.mutateAsync({
          params: { business_id: businessId, version_id: versionId },
          data: {
            target_path: path.trim() || undefined,
            baseline_model_id: baseline,
          },
        });
        setPreviewData(res.data);
      } catch {
        // Degrade-open: never block publish on a preview failure.
        setPreviewError(true);
        setPreviewData(null);
      }
    },
    [preview, businessId, versionId],
  );

  const versionLabel = scope
    ? `v${versionNum} ${scope.toUpperCase()}`
    : `v${versionNum}`;

  const reset = () => {
    setResult(null);
    setDegraded(null);
    setError("");
    setTargetPath(defaultTargetPath ?? "");
    setPreviewData(null);
    setPreviewError(false);
    setChosenBaseline(undefined);
    setSkipDiff(false);
  };

  // Lazy preview: fire when the dialog opens, then debounce on subsequent
  // targetPath / chosen-baseline edits. The open transition fires immediately;
  // edits while open re-fetch after ~400ms of quiet.
  useEffect(() => {
    if (!open) return;
    if (debounceRef.current) clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => {
      void runPreview(targetPath, chosenBaseline);
    }, 400);
    return () => {
      if (debounceRef.current) clearTimeout(debounceRef.current);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, targetPath, chosenBaseline]);

  const handlePublish = async () => {
    reset();
    try {
      const res = await publish.mutateAsync({
        params: { business_id: businessId, version_id: versionId },
        data: { target_path: targetPath.trim() || undefined },
      });
      setResult(res.data);
    } catch (err: unknown) {
      if (err instanceof ApiError && err.status === 422) {
        const body = err.body as { detail?: { error?: string } } | undefined;
        setDegraded(body?.detail?.error ?? "github_connection_missing");
        return;
      }
      const e = err as { body?: { detail?: string }; message?: string };
      setError(e?.body?.detail || e?.message || String(err));
    }
  };

  const trigger = (
    <Button
      variant="ghost"
      size="sm"
      data-testid="publish-version"
      disabled={!configured}
      title={
        configured
          ? "Open a GitHub pull request with this version's model artifacts"
          : undefined
      }
    >
      <Upload className="h-4 w-4 mr-1.5" />
      Publish to GitHub
    </Button>
  );

  // Disabled buttons swallow pointer events, so the "configure first" tooltip
  // wraps the trigger in a focusable/hoverable span (asChild on a span).
  if (!configured) {
    return (
      <TooltipProvider>
        <Tooltip>
          <TooltipTrigger asChild>
            <span
              tabIndex={0}
              data-testid="publish-version-disabled"
              className="inline-flex"
            >
              {trigger}
            </span>
          </TooltipTrigger>
          <TooltipContent className="max-w-xs">
            <Link
              to="/settings"
              search={SETTINGS_GITHUB_SEARCH}
              className="underline underline-offset-2"
            >
              Configure GitHub publishing in Settings first
            </Link>
          </TooltipContent>
        </Tooltip>
      </TooltipProvider>
    );
  }

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (publish.isPending) return;
        setOpen(next);
        if (!next) reset();
      }}
    >
      <DialogTrigger asChild>{trigger}</DialogTrigger>
      <DialogContent
        className={publish.isPending ? "[&>button]:hidden" : ""}
        data-testid="publish-version-dialog"
      >
        <DialogHeader>
          <DialogTitle>Publish {versionLabel} to GitHub?</DialogTitle>
          <DialogDescription>
            Opens a pull request that adds this version's model artifacts to{" "}
            {connectionName
              ? `the configured repository (${connectionName})`
              : "the configured repository"}
            . One version per PR.
          </DialogDescription>
        </DialogHeader>

        {!result && !degraded && (
          <div className="space-y-1.5">
            <label
              htmlFor="publish-target-path"
              className="text-xs font-medium text-muted-foreground"
            >
              Publish target path
            </label>
            <Input
              id="publish-target-path"
              data-testid="publish-target-path"
              value={targetPath}
              onChange={(e) => setTargetPath(e.target.value)}
              placeholder="e.g. capital_markets/ecm_v3"
              disabled={publish.isPending}
            />
            <p className="text-xs text-muted-foreground">
              The bundle root (up to the version folder). Leave blank to use the
              default.
            </p>
          </div>
        )}

        {!result && !degraded && !skipDiff && (
          <PreviewSection
            data={previewData}
            error={previewError}
            onPickBaseline={(id) => setChosenBaseline(id)}
            onSkip={() => setSkipDiff(true)}
          />
        )}

        {result ? (
          <div
            className="space-y-3 text-sm"
            data-testid="publish-version-success"
          >
            <a
              href={result.pr_url}
              target="_blank"
              rel="noreferrer"
              className="inline-flex items-center gap-1.5 font-medium text-primary hover:underline"
            >
              <GitPullRequest className="h-4 w-4" />
              PR #{result.pr_number} opened
              <ExternalLink className="h-3.5 w-3.5" />
            </a>
            <p className="flex items-center gap-1.5 text-xs text-muted-foreground">
              <GitBranch className="h-3.5 w-3.5" />
              Branch <code className="font-mono">{result.branch}</code>
            </p>
            {result.files.length > 0 && (
              <div>
                <p className="mb-1 text-xs font-medium text-muted-foreground">
                  {result.files.length}{" "}
                  {result.files.length === 1 ? "file" : "files"} published
                </p>
                <ul className="max-h-40 space-y-0.5 overflow-auto rounded-sm border border-border bg-muted/40 p-2">
                  {result.files.map((f) => (
                    <li
                      key={f}
                      className="flex items-center gap-1.5 font-mono text-xs"
                    >
                      <FileText className="h-3 w-3 shrink-0 text-muted-foreground" />
                      {f}
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </div>
        ) : degraded ? (
          <div
            className="space-y-2 rounded-md border border-warning/40 bg-warning/10 p-3 text-sm"
            data-testid="publish-version-degraded"
          >
            <p>{settingsLinkMessage(degraded)}</p>
            <Link
              to="/settings"
              search={SETTINGS_GITHUB_SEARCH}
              className="inline-flex items-center gap-1.5 font-medium text-primary hover:underline"
            >
              <Settings className="h-3.5 w-3.5" />
              Open GitHub settings
            </Link>
          </div>
        ) : (
          error && (
            <p
              className="text-sm text-destructive"
              data-testid="publish-version-error"
            >
              {error}
            </p>
          )
        )}

        <DialogFooter>
          {result ? (
            <Button variant="outline" onClick={() => setOpen(false)}>
              Close
            </Button>
          ) : (
            <>
              <Button
                variant="outline"
                disabled={publish.isPending}
                onClick={() => setOpen(false)}
              >
                Cancel
              </Button>
              <Button
                disabled={publish.isPending}
                onClick={() => void handlePublish()}
                data-testid="publish-version-confirm"
              >
                {publish.isPending ? "Publishing..." : "Publish"}
              </Button>
            </>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
