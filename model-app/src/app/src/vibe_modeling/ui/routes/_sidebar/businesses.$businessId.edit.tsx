import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { Suspense, useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Skeleton } from "@/components/ui/skeleton";
import { ArrowLeft, Save } from "lucide-react";
import {
  useGetBusinessSuspense,
  updateBusiness,
  getBusinessKey,
} from "@/lib/api";
import { invalidateBusinessLists } from "@/lib/business-cache";
import { selector } from "@/lib/selector";
import { useBreadcrumbs } from "@/components/explorer/breadcrumb-context";
import { SectorSelect } from "@/components/business/sector-select";
import { MarkdownEditor } from "@/components/ui/markdown-editor";

const DESCRIPTION_MAX_LENGTH = 2000;

export const Route = createFileRoute(
  "/_sidebar/businesses/$businessId/edit"
)({
  component: () => {
    const { businessId } = Route.useParams();
    return (
      <div className="p-4 space-y-3">
        <Suspense fallback={<Skeleton className="h-96 w-full max-w-4xl" />}>
          <EditBusinessForm businessId={businessId} />
        </Suspense>
      </div>
    );
  },
});

function EditBusinessForm({ businessId }: { businessId: string }) {
  const { data: business } = useGetBusinessSuspense({
    params: { business_id: businessId },
    ...selector(),
  });

  useBreadcrumbs([
    {
      label: business.name,
      to: "/businesses/$businessId",
      params: { businessId },
    },
    { label: "Edit" },
  ]);

  const [name, setName] = useState(business.name);
  const [description, setDescription] = useState(business.description || "");
  const [businessVibes, setBusinessVibes] = useState(business.business_vibes || "");
  const [sectorId, setSectorId] = useState<string | null>(business.sector_id ?? null);

  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const mutation = useMutation({
    mutationFn: () =>
      updateBusiness(
        { business_id: businessId },
        { name, description, business_vibes: businessVibes, sector_id: sectorId },
      ),
    onSuccess: async () => {
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: getBusinessKey({ business_id: businessId }) }),
        invalidateBusinessLists(queryClient),
      ]);
      navigate({
        to: "/businesses/$businessId/explorer",
        params: { businessId },
      });
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    mutation.mutate();
  };

  return (
    <>
      <div className="flex items-center gap-4">
        <Button variant="ghost" size="icon" asChild>
          <Link
            to="/businesses/$businessId/explorer"
            params={{ businessId }}
          >
            <ArrowLeft className="h-4 w-4" />
          </Link>
        </Button>
        <h1 className="text-2xl font-semibold tracking-tight">Edit Business</h1>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4 max-w-4xl">
        <div className="space-y-2">
          <label className="text-sm font-medium">Name *</label>
          <Input
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
          />
        </div>

        <div className="space-y-2">
          <label className="text-sm font-medium">Sector</label>
          <p className="text-xs text-muted-foreground">
            Pick the sector this business belongs to (taxonomy placement).
          </p>
          <Suspense fallback={<Skeleton className="h-9 w-full" />}>
            <SectorSelect value={sectorId} onChange={setSectorId} />
          </Suspense>
        </div>

        <div className="space-y-2">
          <div className="flex items-baseline justify-between">
            <label className="text-sm font-medium">Business summary *</label>
            <span
              className={`text-xs tabular-nums ${
                description.length > DESCRIPTION_MAX_LENGTH * 0.9
                  ? "text-warning"
                  : "text-muted-foreground"
              }`}
            >
              {description.length} / {DESCRIPTION_MAX_LENGTH}
            </span>
          </div>
          <Textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Short summary of the business — sets the model's industry & scale"
            rows={4}
            maxLength={DESCRIPTION_MAX_LENGTH}
            data-testid="business-description"
          />
          <p className="text-xs text-muted-foreground" data-testid="business-description-helper">
            Required — short summary (≤{DESCRIPTION_MAX_LENGTH} chars). Sets the
            model's industry alignment and complexity/size.
          </p>
        </div>

        <div className="space-y-2">
          <label
            className="text-sm font-medium"
            title="The full detailed description — process, key entities, differentiators, critical business components. This is the primary instruction set for the initial model."
          >
            Detailed description
          </label>
          <MarkdownEditor
            value={businessVibes}
            onChange={setBusinessVibes}
            placeholder="Process, key entities, differentiators, critical business components… (Markdown, any length)"
            rows={14}
            textareaTestId="business-vibes"
          />
          <p className="text-xs text-muted-foreground">
            Markdown, any length — the primary instructions for the initial model.
            Cover processes, key entities, differentiators, and critical components.
          </p>
        </div>

        {mutation.isError && (
          <p className="text-sm text-destructive">
            Failed to save:{" "}
            {mutation.error instanceof Error ? mutation.error.message : "unknown error"}
          </p>
        )}

        <div className="flex gap-2 pt-2">
          <Button type="submit" disabled={!name || !description.trim() || mutation.isPending}>
            <Save className="h-4 w-4 mr-2" />
            {mutation.isPending ? "Saving..." : "Save Changes"}
          </Button>
          <Button variant="outline" asChild>
            <Link
              to="/businesses/$businessId/explorer"
              params={{ businessId }}
            >
              Cancel
            </Link>
          </Button>
        </div>
      </form>
    </>
  );
}
