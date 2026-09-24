import { AlertTriangle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { parse409 } from "@/lib/api-error";

/**
 * Shape of the 409 body the backend raises when the target industry already
 * carries a model of the SAME scope. Under additive semantics a same-scope
 * re-download is blocked outright — there is no Replace / Add-another-version
 * / Create-distinct escape hatch. The user must delete the model in-app first.
 */
export interface IndustryModelAlreadyExistsBody {
  error: "industry_model_already_exists";
  scope?: string;
  message?: string;
}

/**
 * Parse a `downloadIndustryModel` error into the model-scope conflict body, or
 * null when it isn't a 409 same-scope clash. Mirrors the wrapping the FE
 * client uses (`ApiError.body` may be the payload directly or nested under
 * `detail`).
 */
export function parseDownloadConflict(
  err: unknown,
): IndustryModelAlreadyExistsBody | null {
  const candidate = parse409<IndustryModelAlreadyExistsBody>(
    err,
    "industry_model_already_exists",
  );
  if (!candidate) return null;
  return {
    error: "industry_model_already_exists",
    scope: typeof candidate.scope === "string" ? candidate.scope : undefined,
    message:
      typeof candidate.message === "string" ? candidate.message : undefined,
  };
}

interface Props {
  conflict: IndustryModelAlreadyExistsBody;
  onClose: () => void;
}

/**
 * In-dialog same-scope conflict notice. Rendered after a `downloadIndustryModel`
 * call returns 409 `industry_model_already_exists`. Additive semantics block a
 * same-scope re-download outright, so this is purely informational: it tells
 * the user the model is already downloaded and to delete it in-app to re-pull.
 * There are no resolution buttons — only a close affordance.
 */
export function DownloadConflictStep({ conflict, onClose }: Props) {
  const scopeLabel = conflict.scope ? conflict.scope.toUpperCase() : "model";

  return (
    <div
      data-testid="download-conflict-step"
      className="rounded-md border border-warning/40 bg-warning/5 p-4 space-y-4"
    >
      <div className="flex items-start gap-2">
        <AlertTriangle className="h-4 w-4 mt-0.5 text-warning shrink-0" />
        <div className="space-y-1">
          <p className="text-sm font-medium">
            This {scopeLabel} model is already downloaded
          </p>
          <p className="text-sm text-muted-foreground">
            {conflict.message ||
              "This model is already downloaded for the industry. Delete it in the app first to re-download."}
          </p>
        </div>
      </div>

      <div className="flex justify-end gap-2 pt-1">
        <Button variant="outline" size="sm" onClick={onClose}>
          Close
        </Button>
      </div>
    </div>
  );
}
