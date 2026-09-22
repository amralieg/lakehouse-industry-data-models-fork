import { createFileRoute } from "@tanstack/react-router";
import { Suspense } from "react";
import { Skeleton } from "@/components/ui/skeleton";
import { useListVersionsSuspense, useGetBusinessSuspense } from "@/lib/api";
import { selector } from "@/lib/selector";
import { ComposeSurface } from "@/components/vibe-inputs/compose-surface";
import { useBreadcrumbs } from "@/components/explorer/breadcrumb-context";

export const Route = createFileRoute(
  "/_sidebar/businesses/$businessId/model/$version/$scope/inputs/",
)({
  component: ComposeRoute,
});

function ComposeRoute() {
  const { businessId, version, scope } = Route.useParams();
  return (
    <div className="h-[calc(100vh-3.5rem)]">
      <Suspense fallback={<Skeleton className="m-4 h-[70vh]" />}>
        <Resolved businessId={businessId} version={version} scope={scope} />
      </Suspense>
    </div>
  );
}

function Resolved({
  businessId,
  version,
  scope,
}: {
  businessId: string;
  version: string;
  scope: string;
}) {
  const { data: versions } = useListVersionsSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  const { data: business } = useGetBusinessSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  // Two MV rows can share `version` if scope differs — natural key (version,
  // scope), mirroring the model route.
  const current =
    versions.find((v: any) => v.version === Number(version) && (v.scope || "") === scope) ??
    versions.find((v: any) => v.version === Number(version));
  const versionId = (current as any)?.id ?? "";

  // Mirror the model page's chain, with the version crumb a link back to it
  // (the inputs page is otherwise a dead-end with no way back).
  const scopeLabel = scope ? scope.toUpperCase() : "";
  useBreadcrumbs([
    { label: business.name, to: "/businesses/$businessId", params: { businessId } },
    { label: "Explorer", to: "/businesses/$businessId/explorer", params: { businessId } },
    {
      label: scopeLabel ? `v${version} ${scopeLabel}` : `v${version}`,
      to: "/businesses/$businessId/model/$version/$scope",
      params: { businessId, version, scope },
      search: { tab: "overview" },
    },
    { label: "Inputs" },
  ]);

  return (
    <ComposeSurface
      businessId={businessId}
      version={version}
      scope={scope}
      versionId={versionId}
    />
  );
}
