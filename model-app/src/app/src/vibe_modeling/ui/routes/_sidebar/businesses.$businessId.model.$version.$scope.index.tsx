import { createFileRoute, Link, useNavigate, useSearch } from "@tanstack/react-router";
import { Suspense, useState } from "react";
import { ErrorBoundary } from "react-error-boundary";
import { toast } from "sonner";
import { notifyError } from "@/lib/notify";
import { invalidateEntityLists } from "@/lib/delete-invalidation";
import {
  useGetBusinessSuspense,
  useGetModelSummarySuspense,
  useListVersionsSuspense,
  deleteVersion,
} from "@/lib/api";
import { isNotFoundError } from "@/lib/api-error";
import { selector } from "@/lib/selector";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Checkbox } from "@/components/ui/checkbox";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { useBreadcrumbs } from "@/components/explorer/breadcrumb-context";
import { Trash2, AlertTriangle } from "lucide-react";
import { ModelTabsShell } from "@/components/model/model-tabs-shell";
import { ModelSearch } from "@/components/model/model-search";
import { DomainSelect } from "@/components/diagram/domain-select";
import type { ModelViewTab } from "@/components/vibe-inputs/model-view";
import { useQueryClient } from "@tanstack/react-query";

const validTabs = ["overview", "diagram", "relationships", "ontology", "artifacts", "feedback", "statistics"] as const;
type ModelTab = (typeof validTabs)[number];

/** Domain-level tabs the domain page ($domainName.index.tsx) actually
 *  renders. Used to decide which tab survives a navigate-into-a-domain. */
const DOMAIN_LEVEL_TABS = new Set(["diagram", "relationships", "ontology"]);

export const Route = createFileRoute(
  "/_sidebar/businesses/$businessId/model/$version/$scope/"
)({
  validateSearch: (search: Record<string, unknown>): { tab: ModelTab } => ({
    tab: validTabs.includes(search.tab as ModelTab)
      ? (search.tab as ModelTab)
      : "overview",
  }),
  component: () => {
    const { businessId, version, scope } = Route.useParams();
    return (
      <div className="p-4 space-y-3">
        <ErrorBoundary
          // Re-throw non-404s so the parent generic boundary still
          // surfaces them. We only own the "version doesn't exist for
          // this business" empty-state.
          fallbackRender={({ error }) => {
            if (isNotFoundError(error)) {
              return (
                <ModelVersionMissing
                  businessId={businessId}
                  version={version}
                  scope={scope}
                />
              );
            }
            throw error;
          }}
        >
          <Suspense fallback={<PageSkeleton />}>
            <ModelVersionPage businessId={businessId} version={version} scope={scope} />
          </Suspense>
        </ErrorBoundary>
      </div>
    );
  },
});

function ModelVersionMissing({
  businessId,
  version,
  scope,
}: {
  businessId: string;
  version: string;
  scope: string;
}) {
  const scopeLabel = scope ? scope.toUpperCase() : "";
  return (
    <Card>
      <CardHeader>
        <CardTitle>Model version not found</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <p className="text-sm text-muted-foreground">
          Version v={version}
          {scopeLabel ? ` ${scopeLabel}` : ""} doesn't exist for this business.
        </p>
        <Button asChild variant="outline" size="sm">
          <Link
            to="/businesses/$businessId/explorer"
            params={{ businessId }}
          >
            Back to Explorer
          </Link>
        </Button>
      </CardContent>
    </Card>
  );
}

export function ModelVersionPage({
  businessId,
  version,
  scope,
}: {
  businessId: string;
  version: string;
  /** Required model scope ("ecm" | "mvm"). Tests may also pass an empty
   *  string for legacy fixtures; downstream lookups gracefully degrade. */
  scope: string;
}) {
  const navigate = useNavigate();
  const { tab } = useSearch({
    from: "/_sidebar/businesses/$businessId/model/$version/$scope/",
  });

  const setTab = (value: ModelViewTab) => {
    navigate({
      to: ".",
      search: { tab: value as ModelTab },
      replace: true,
    });
  };

  // Business + versions are resolved here (not just in the shell) because the
  // breadcrumb trail and the DeleteVersionButton both need them; react-query
  // dedupes with the shell's identical fetches.
  const { data: business } = useGetBusinessSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  const { data: versions } = useListVersionsSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  // Same dedupe reasoning: the title's domain-select (item 3B) needs the
  // domain list, which only the shell fetched before this.
  const { data: model } = useGetModelSummarySuspense({
    params: { business_id: businessId, version_int: Number(version), scope },
    ...selector(),
  });

  // Two MV rows can share `version` if their `scope` differs (the model-versioning work),
  // so use `(version, scope)` as the natural key. Fall back to the
  // version-only match if scope is unknown (legacy callers).
  const currentVersion =
    versions.find(
      (v: any) => v.version === Number(version) && (v.scope || "") === scope,
    ) ?? versions.find((v: any) => v.version === Number(version));
  const scopeLabel = scope ? scope.toUpperCase() : "";

  const domainList = (model.domains ?? [])
    .filter((d) => d.change_status !== "deleted")
    .map((d) => ({ name: d.name, division: d.division ?? "" }));

  // Item 3B: picking a domain from the title dropdown navigates DOWN into
  // the domain page (push, not replace, so back returns here). Picking
  // "All domains" is a no-op - we're already on the all-domains page.
  // Preserve the current tab where the domain page has an equivalent tab,
  // else land on its default ("products").
  const handleDomainNavigate = (domain: string | null) => {
    if (domain === null) return;
    navigate({
      to: "/businesses/$businessId/model/$version/$scope/$domainName",
      params: { businessId, version, scope, domainName: domain },
      search: { tab: DOMAIN_LEVEL_TABS.has(tab) ? (tab as "diagram" | "relationships" | "ontology") : "products" },
    });
  };

  useBreadcrumbs([
    {
      label: business.name,
      to: "/businesses/$businessId",
      params: { businessId },
    },
    {
      label: "Explorer",
      to: "/businesses/$businessId/explorer",
      params: { businessId },
    },
    { label: scopeLabel ? `v${version} ${scopeLabel}` : `v${version}` },
  ]);

  return (
    <ModelTabsShell
      businessId={businessId}
      version={version}
      scope={scope}
      tab={tab}
      onTabChange={setTab}
      searchTrigger={<ModelSearch businessId={businessId} version={version} scope={scope} />}
      domainSelectorSlot={
        <DomainSelect
          domains={domainList}
          value={null}
          onChange={handleDomainNavigate}
          className="w-56 h-8 text-sm"
        />
      }
      onDomainNavigate={handleDomainNavigate}
      showDomainSelect={false}
      versionActions={
        <DeleteVersionButton
          businessId={businessId}
          businessName={business.name}
          version={version}
          scope={scope}
          versions={versions}
          currentVersionId={(currentVersion as any)?.id}
          currentUcCatalog={(currentVersion as any)?.uc_catalog ?? ""}
        />
      }
    />
  );
}

export function DeleteVersionButton({
  businessId,
  businessName,
  version,
  scope,
  versions,
  currentVersionId,
  currentUcCatalog,
}: {
  businessId: string;
  businessName: string;
  version: string;
  scope: string;
  versions: any[];
  currentVersionId: string | undefined;
  currentUcCatalog: string;
}) {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  // Per-scope "latest" check - the agent's version counter is per-scope
  // (v1_ecm + v1_mvm can coexist), so an ECM v2 is "latest" of its scope
  // even if MVM v3 exists.
  const completedVersions = versions
    .filter((v: any) => v.status === "completed")
    .filter((v: any) => !scope || (v.scope || "") === scope);
  const isLatest =
    completedVersions.length > 0 && completedVersions[0].version === Number(version);
  const prevVersion =
    completedVersions.length >= 2 ? completedVersions[1].version : null;

  // Reinstall option is only meaningful when there is a previous version
  // AND the current version has a deployment catalog (so we know where
  // to re-install). Imported-only versions (no uc_catalog) get the
  // checkbox hidden - the backend would reject them anyway.
  const canReinstallPrevious = prevVersion !== null && Boolean(currentUcCatalog);
  const scopeLabel = scope ? scope.toUpperCase() : "";

  const [dialogOpen, setDialogOpen] = useState(false);
  const [reinstallChecked, setReinstallChecked] = useState(false);
  const [deleting, setDeleting] = useState(false);

  const handleDelete = async () => {
    if (!currentVersionId) return;
    setDeleting(true);
    try {
      await deleteVersion({
        business_id: businessId,
        version_id: currentVersionId,
        reinstall_previous: reinstallChecked && canReinstallPrevious,
      });
      // Invalidate the version-list views the sidebar + explorer Suspend on,
      // plus the businesses/industries lists so `model_count` updates.
      await invalidateEntityLists(queryClient, "version", { businessId });
      toast.success("Version deleted");
      setDialogOpen(false);
      navigate({
        to: "/businesses/$businessId/explorer",
        params: { businessId },
      });
    } catch (err) {
      notifyError(err, { title: "Delete failed" });
      // Dialog stays open so the user can retry or cancel.
    } finally {
      setDeleting(false);
    }
  };

  // Hide the button when the version isn't the latest of its scope - // the backend rejects with 400 anyway, no point offering it.
  if (!isLatest) return null;

  return (
    <>
      <Button
        variant="destructive"
        size="sm"
        disabled={deleting}
        onClick={() => {
          setReinstallChecked(false);
          setDialogOpen(true);
        }}
      >
        <Trash2 className="h-4 w-4 mr-2" />
        Delete this version
      </Button>
      <AlertDialog
        open={dialogOpen}
        onOpenChange={(open) => {
          if (!deleting) setDialogOpen(open);
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>
              Delete v{version}
              {scopeLabel ? ` ${scopeLabel}` : ""} of {businessName}?
            </AlertDialogTitle>
            <AlertDialogDescription asChild>
              <div className="space-y-3">
                <div className="rounded-md border border-destructive/50 bg-destructive/10 p-3 text-sm flex items-start gap-2">
                  <AlertTriangle className="h-4 w-4 mt-0.5 text-destructive shrink-0" />
                  <span>
                    This will permanently delete this version's domains,
                    products, attributes, foreign keys, artifacts, and{" "}
                    <code>_metamodel.*</code> rows. This cannot be undone.
                  </span>
                </div>
                {canReinstallPrevious && (
                  <label className="flex items-start gap-2 text-sm cursor-pointer">
                    <Checkbox
                      checked={reinstallChecked}
                      onCheckedChange={(v) => setReinstallChecked(v === true)}
                      disabled={deleting}
                      className="mt-0.5"
                    />
                    <span>
                      Re-install v{prevVersion}
                      {scopeLabel ? ` ${scopeLabel}` : ""} as the current
                      deployed version after delete
                    </span>
                  </label>
                )}
              </div>
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={deleting}>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={(e) => {
                // Prevent the default close-on-click; the dialog stays
                // open on failure so the user can retry.
                e.preventDefault();
                handleDelete();
              }}
              disabled={deleting}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              {deleting ? "Deleting..." : "Delete"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}

function PageSkeleton() {
  return (
    <div className="space-y-6">
      <Skeleton className="h-8 w-64" />
      <Skeleton className="h-10 w-96" />
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
        {[...Array(5)].map((_, i) => (
          <Skeleton key={i} className="h-20" />
        ))}
      </div>
      <div className="grid grid-cols-3 gap-4">
        {[...Array(6)].map((_, i) => (
          <Skeleton key={i} className="h-32" />
        ))}
      </div>
    </div>
  );
}
