import { Link } from "@tanstack/react-router";
import { Factory, Plus, FileUp, ArrowRight } from "lucide-react";
import { ImportNewBusinessDialog } from "@/components/import/import-new-business-dialog";

/**
 * The primary ways to start something new — shown quietly under "Jump back
 * in" for a returning user, and elevated in the empty state. `emphasis`
 * bumps the visual weight for the newcomer case.
 */
export function EntryPoints({ emphasis = false }: { emphasis?: boolean }) {
  const base =
    "group flex items-center gap-3 rounded-md border bg-card p-4 text-left transition-colors hover:bg-accent";
  const border = emphasis ? "border-input" : "border-border hover:border-input";

  const iconWrap =
    "flex h-9 w-9 shrink-0 items-center justify-center rounded-sm border border-border bg-muted text-muted-foreground";

  return (
    <div className="grid gap-3 sm:grid-cols-3">
      <Link to="/industries" className={`${base} ${border}`}>
        <span className={iconWrap}>
          <Factory className="h-4 w-4" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="block text-sm font-medium">Browse industries</span>
          <span className="block text-xs text-muted-foreground">
            Start from a template
          </span>
        </span>
        <ArrowRight className="h-4 w-4 shrink-0 text-muted-foreground opacity-0 transition-opacity group-hover:opacity-100" />
      </Link>

      <Link to="/businesses/new" className={`${base} ${border}`}>
        <span className={iconWrap}>
          <Plus className="h-4 w-4" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="block text-sm font-medium">New business</span>
          <span className="block text-xs text-muted-foreground">
            Describe it in your own words
          </span>
        </span>
        <ArrowRight className="h-4 w-4 shrink-0 text-muted-foreground opacity-0 transition-opacity group-hover:opacity-100" />
      </Link>

      <ImportNewBusinessDialog
        trigger={
          <button type="button" className={`${base} ${border} w-full`}>
            <span className={iconWrap}>
              <FileUp className="h-4 w-4" />
            </span>
            <span className="min-w-0 flex-1">
              <span className="block text-sm font-medium">Import a model</span>
              <span className="block text-xs text-muted-foreground">
                Bring a pre-vibed model.json
              </span>
            </span>
            <ArrowRight className="h-4 w-4 shrink-0 text-muted-foreground opacity-0 transition-opacity group-hover:opacity-100" />
          </button>
        }
      />
    </div>
  );
}

export default EntryPoints;
