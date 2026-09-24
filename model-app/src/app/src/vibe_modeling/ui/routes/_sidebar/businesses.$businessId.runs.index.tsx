import { createFileRoute, Link } from "@tanstack/react-router";
import { Suspense, useState } from "react";
import { notifyError } from "@/lib/notify";
import {
  useGetBusinessSuspense,
  useListRunsSuspense,
  useListVersionsSuspense,
  useListIndustriesSuspense,
  updateBusiness,
} from "@/lib/api";
import { selector } from "@/lib/selector";
import { formatDate, formatDateTime } from "@/lib/date";
import { industryDisplayName } from "@/lib/industry";
import { SectorSelect } from "@/components/business/sector-select";
import { useBreadcrumbs } from "@/components/explorer/breadcrumb-context";
import { entityKindLabel, entityKindLabelLower } from "@/lib/entity-kind";
import { intentLabel } from "@/lib/intent";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Skeleton } from "@/components/ui/skeleton";
import { Progress } from "@/components/ui/progress";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import {
  Table,
  TableBody,
  TableCell,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  SortableTableHead,
  useTableSort,
} from "@/components/ui/sortable-table-head";
import { ArrowLeft, Play, Pencil, Clock, CheckCircle, XCircle, Loader2, Compass, AlertTriangle } from "lucide-react";
import { useQueryClient } from "@tanstack/react-query";
import { useAgentReady } from "@/lib/hooks";

export const Route = createFileRoute("/_sidebar/businesses/$businessId/runs/")({
  component: () => {
    const { businessId } = Route.useParams();
    return (
      <div className="p-6 space-y-6">
        <Suspense fallback={<PageSkeleton />}>
          <BusinessDetail businessId={businessId} />
        </Suspense>
      </div>
    );
  },
});

export function BusinessDetail({ businessId }: { businessId: string }) {
  const { data: business } = useGetBusinessSuspense({ params: { business_id: businessId }, ...selector() });
  const { data: versions } = useListVersionsSuspense({ params: { business_id: businessId }, ...selector() });
  const { data: industries } = useListIndustriesSuspense(selector());
  const { data: agentReady } = useAgentReady();
  const queryClient = useQueryClient();
  const [editOpen, setEditOpen] = useState(false);
  const [editName, setEditName] = useState(business.name);
  const [editDesc, setEditDesc] = useState(business.description);
  const [editSectorId, setEditSectorId] = useState<string | null>(business.sector_id ?? null);
  const [saving, setSaving] = useState(false);
  // Industries share this detail surface (kind='industry'); follow the kind
  // discriminator for the user-facing noun instead of hardcoding "business".
  const kindLabel = entityKindLabel(business.kind);
  const kindLower = entityKindLabelLower(business.kind);
  useBreadcrumbs([
    { label: business.name, to: "/businesses/$businessId", params: { businessId } },
    { label: "Runs" },
  ]);
  const runsDisabledReason = agentReady && !agentReady.ready
    ? agentReady.reason || "Agent configuration is not ready."
    : null;
  const completedVersions = (versions ?? []).filter((v: any) => v.status === "completed");
  const latestVersion = completedVersions[0];
  const hasModel = completedVersions.length > 0;

  const handleUpdate = async () => {
    setSaving(true);
    try {
      await updateBusiness({ business_id: businessId }, {
        name: editName,
        description: editDesc,
        sector_id: editSectorId,
      });
      queryClient.invalidateQueries();
      setEditOpen(false);
    } catch (err) {
      notifyError(err, { fallback: `Failed to save ${kindLower}` });
    } finally {
      setSaving(false);
    }
  };

  return (
    <>
      <div className="flex items-start gap-4">
        <Button variant="ghost" size="icon" asChild className="mt-1">
          <Link to={business.kind === "industry" ? "/industries" : "/businesses"}>
            <ArrowLeft className="h-4 w-4" />
          </Link>
        </Button>
        <div className="flex-1 space-y-1">
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-semibold tracking-tight">{business.name}</h1>
            {business.industry_alignment && (
              <Badge variant="secondary">{industryDisplayName(business.industry_alignment, industries)}</Badge>
            )}
            <Button
              variant="ghost"
              size="icon"
              className="h-7 w-7"
              onClick={() => {
                setEditName(business.name);
                setEditDesc(business.description);
                setEditSectorId(business.sector_id ?? null);
                setEditOpen(true);
              }}
              title={`Edit ${kindLower}`}
            >
              <Pencil className="h-3.5 w-3.5" />
            </Button>
          </div>
          <p className="text-muted-foreground text-sm">
            {business.description || "No description"}
          </p>
        </div>
      </div>

      <div className="flex gap-2">
        {hasModel ? (
          <Button
            asChild
            variant="outline"
            title={
              latestVersion
                ? `Open the latest completed model (v${latestVersion.version})`
                : "Open the latest completed model"
            }
          >
            <Link to="/businesses/$businessId/explorer" params={{ businessId }}>
              <Compass className="h-4 w-4 mr-2" />
              Explore model{latestVersion ? ` (v${latestVersion.version})` : ""}
            </Link>
          </Button>
        ) : (
          <Button variant="outline" disabled title="No completed model yet">
            <Compass className="h-4 w-4 mr-2" />
            Explore model
          </Button>
        )}
        {runsDisabledReason ? (
          <Button variant="outline" disabled title={runsDisabledReason}>
            <Play className="h-4 w-4 mr-2" />
            New Run
          </Button>
        ) : (
          <Button asChild variant="outline">
            <Link
              to="/businesses/$businessId/runs/new"
              params={{ businessId }}
              search={{ operationType: undefined }}
            >
              <Play className="h-4 w-4 mr-2" />
              New Run
            </Link>
          </Button>
        )}
      </div>

      {runsDisabledReason && (
        <div className="flex items-start gap-2 rounded-md border border-warning/40 bg-warning/5 px-3 py-2 text-xs">
          <AlertTriangle className="h-4 w-4 text-warning shrink-0 mt-0.5" />
          <span className="text-warning">
            Runs are disabled: {runsDisabledReason}{" "}
            <Link to="/settings" search={{ tab: "agent" }} className="underline">
              Open Settings
            </Link>
          </span>
        </div>
      )}

      {/* Edit Dialog */}
      <Dialog open={editOpen} onOpenChange={setEditOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit {kindLabel}</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <label className="text-sm font-medium">Name</label>
              <Input value={editName} onChange={(e) => setEditName(e.target.value)} />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">Description *</label>
              <Textarea
                value={editDesc}
                onChange={(e) => setEditDesc(e.target.value)}
                rows={3}
                data-testid="business-description"
              />
              <p
                className="text-xs text-muted-foreground"
                data-testid="business-description-helper"
              >
                Required — this text is passed to the agent as business context.
              </p>
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">Sector</label>
              <Suspense fallback={<Skeleton className="h-9 w-full" />}>
                <SectorSelect value={editSectorId} onChange={setEditSectorId} />
              </Suspense>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setEditOpen(false)}>Cancel</Button>
            <Button
              onClick={handleUpdate}
              disabled={!editName || !editDesc.trim() || saving}
            >
              {saving ? "Saving..." : "Save"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Tabs defaultValue="runs">
        <TabsList>
          <TabsTrigger value="runs">Runs</TabsTrigger>
          <TabsTrigger value="versions">Versions</TabsTrigger>
        </TabsList>

        <TabsContent value="runs">
          <Suspense fallback={<TableSkeleton />}>
            <RunsTable businessId={businessId} />
          </Suspense>
        </TabsContent>

        <TabsContent value="versions">
          <Suspense fallback={<TableSkeleton />}>
            <VersionsTable businessId={businessId} />
          </Suspense>
        </TabsContent>
      </Tabs>
    </>
  );
}

const statusConfig: Record<string, { icon: React.ReactNode; variant: "default" | "secondary" | "destructive" | "outline" }> = {
  pending: { icon: <Clock className="h-3 w-3" />, variant: "outline" },
  running: { icon: <Loader2 className="h-3 w-3 animate-spin" />, variant: "default" },
  completed: { icon: <CheckCircle className="h-3 w-3" />, variant: "secondary" },
  failed: { icon: <XCircle className="h-3 w-3" />, variant: "destructive" },
  cancelled: { icon: <XCircle className="h-3 w-3" />, variant: "outline" },
};

function RunsTable({ businessId }: { businessId: string }) {
  const { data: runs } = useListRunsSuspense({ params: { business_id: businessId }, ...selector() });
  const { sorted, sortKey, sortDir, toggle } = useTableSort({
    rows: runs,
    initialKey: "started_at",
    initialDir: "desc",
    accessors: {
      intent: (r: any) => r.intent,
      status: (r: any) => r.status,
      progress_percent: (r: any) => r.progress_percent,
      started_at: (r: any) => (r.started_at ? new Date(r.started_at) : null),
      duration: (r: any) => {
        if (!r.started_at) return null;
        const end = r.completed_at ? new Date(r.completed_at).getTime() : Date.now();
        return end - new Date(r.started_at).getTime();
      },
    },
  });

  if (runs.length === 0) {
    return (
      <Card>
        <CardContent className="py-8 text-center text-muted-foreground">
          No runs yet. Start a new run to generate a data model.
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardContent className="pt-6">
        <Table>
          <TableHeader>
            <TableRow>
              <SortableTableHead columnKey="intent" sortKey={sortKey} sortDir={sortDir} onToggle={toggle}>Type</SortableTableHead>
              <SortableTableHead columnKey="status" sortKey={sortKey} sortDir={sortDir} onToggle={toggle}>Status</SortableTableHead>
              <SortableTableHead columnKey="progress_percent" sortKey={sortKey} sortDir={sortDir} onToggle={toggle}>Progress</SortableTableHead>
              <SortableTableHead columnKey="started_at" sortKey={sortKey} sortDir={sortDir} onToggle={toggle}>Started</SortableTableHead>
              <SortableTableHead columnKey="duration" sortKey={sortKey} sortDir={sortDir} onToggle={toggle}>Duration</SortableTableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {sorted.map((run) => {
              const cfg = statusConfig[run.status] || statusConfig.pending;
              return (
                <TableRow key={run.id}>
                  <TableCell>
                    <Link
                      to="/businesses/$businessId/runs/$runId"
                      params={{ businessId: run.business_id, runId: run.id }}
                      className="font-medium hover:underline"
                    >
                      {/* Phase 5: runs surface a canonical Intent slug;
                          render via the intent label helper. */}
                      {intentLabel(run.intent)}
                    </Link>
                  </TableCell>
                  <TableCell>
                    <Badge variant={cfg.variant} className="flex items-center gap-1 w-fit">
                      {cfg.icon}
                      {run.status}
                    </Badge>
                  </TableCell>
                  <TableCell className="w-32">
                    <Progress value={run.progress_percent} className="h-2" />
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {formatDateTime(run.started_at)}
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {run.started_at && run.completed_at
                      ? formatDuration(
                          new Date(run.completed_at).getTime() -
                            new Date(run.started_at).getTime()
                        )
                      : "—"}
                  </TableCell>
                </TableRow>
              );
            })}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}

function VersionsTable({ businessId }: { businessId: string }) {
  const { data: versions } = useListVersionsSuspense({ params: { business_id: businessId }, ...selector() });
  const { sorted, sortKey, sortDir, toggle } = useTableSort({
    rows: versions,
    initialKey: "version",
    initialDir: "desc",
    accessors: {
      version: (r: any) => r.version,
      status: (r: any) => r.status,
      uc_catalog: (r: any) => r.uc_catalog || "",
      created_at: (r: any) => new Date(r.created_at),
    },
  });

  if (versions.length === 0) {
    return (
      <Card>
        <CardContent className="py-8 text-center text-muted-foreground">
          No model versions yet.
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardContent className="pt-6">
        <Table>
          <TableHeader>
            <TableRow>
              <SortableTableHead columnKey="version" sortKey={sortKey} sortDir={sortDir} onToggle={toggle}>Version</SortableTableHead>
              <SortableTableHead columnKey="status" sortKey={sortKey} sortDir={sortDir} onToggle={toggle}>Status</SortableTableHead>
              <SortableTableHead columnKey="uc_catalog" sortKey={sortKey} sortDir={sortDir} onToggle={toggle}>Catalog</SortableTableHead>
              <SortableTableHead columnKey="created_at" sortKey={sortKey} sortDir={sortDir} onToggle={toggle}>Created</SortableTableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {sorted.map((v) => (
              <TableRow key={v.id}>
                <TableCell className="font-medium">v{v.version}</TableCell>
                <TableCell>
                  <Badge
                    variant={v.status === "completed" ? "secondary" : "outline"}
                  >
                    {v.status}
                  </Badge>
                </TableCell>
                <TableCell className="text-muted-foreground">
                  {v.uc_catalog || "—"}
                </TableCell>
                <TableCell className="text-muted-foreground">
                  {formatDate(v.created_at)}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}

function formatDuration(ms: number): string {
  const seconds = Math.floor(ms / 1000);
  if (seconds < 60) return `${seconds}s`;
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ${seconds % 60}s`;
  const hours = Math.floor(minutes / 60);
  return `${hours}h ${minutes % 60}m`;
}

function PageSkeleton() {
  return (
    <div className="space-y-6">
      <Skeleton className="h-10 w-64" />
      <Skeleton className="h-6 w-96" />
      <Skeleton className="h-64 w-full" />
    </div>
  );
}

function TableSkeleton() {
  return (
    <Card>
      <CardContent className="space-y-3 pt-6">
        {[...Array(3)].map((_, i) => (
          <Skeleton key={i} className="h-12 w-full" />
        ))}
      </CardContent>
    </Card>
  );
}
