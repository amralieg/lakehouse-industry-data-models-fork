import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { Suspense, useState } from "react";
import { notifyError } from "@/lib/notify";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Skeleton } from "@/components/ui/skeleton";
import { ArrowLeft } from "lucide-react";
import { createBusiness } from "@/lib/api";
import { SectorSelect } from "@/components/business/sector-select";
import { MarkdownEditor } from "@/components/ui/markdown-editor";

const SUMMARY_MAX_LENGTH = 2000;

export const Route = createFileRoute("/_sidebar/businesses/new")({
  component: () => (
    <div className="p-4 space-y-3">
      <div className="flex items-center gap-4">
        <Button variant="ghost" size="icon" asChild>
          <Link to="/businesses">
            <ArrowLeft className="h-4 w-4" />
          </Link>
        </Button>
        <h1 className="text-2xl font-semibold tracking-tight">New Business</h1>
      </div>
      <Suspense fallback={<Skeleton className="h-96 w-full max-w-4xl" />}>
        <NewBusinessForm />
      </Suspense>
    </div>
  ),
});

function NewBusinessForm() {
  const navigate = useNavigate();

  const [sectorId, setSectorId] = useState<string | null>(null);
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [businessVibes, setBusinessVibes] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      const result = await createBusiness({
        name,
        description,
        business_vibes: businessVibes,
        sector_id: sectorId,
      });
      navigate({
        to: "/businesses/$businessId",
        params: { businessId: result.data.id },
      });
    } catch (err) {
      notifyError(err, { fallback: "Failed to create business" });
      setSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4 max-w-4xl">
      <div className="space-y-2">
        <label className="text-sm font-medium">Business Name *</label>
        <Input
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="e.g. Contoso Retail"
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
        <label className="text-sm font-medium">Business summary *</label>
        <Textarea
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          placeholder="Short summary of the business — sets the model's industry & scale"
          rows={4}
          maxLength={SUMMARY_MAX_LENGTH}
          data-testid="business-description"
        />
        <p className="text-xs text-muted-foreground" data-testid="business-description-helper">
          Short summary (≤{SUMMARY_MAX_LENGTH} chars). Sets the model's industry
          alignment and complexity/size.
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

      <div className="flex gap-2 pt-2">
        <Button type="submit" disabled={!name || !description.trim() || submitting}>
          {submitting ? "Creating..." : "Create Business"}
        </Button>
        <Button variant="outline" asChild>
          <Link to="/businesses">Cancel</Link>
        </Button>
      </div>
    </form>
  );
}
