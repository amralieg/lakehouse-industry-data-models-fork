import { useState } from "react";
import { Link } from "@tanstack/react-router";
import { ListTree, Layers, ChevronDown, ChevronRight, ExternalLink } from "lucide-react";
import type { ChangeStatus } from "@/lib/api";
import { statusDotClass } from "@/lib/change-status";

/** A single domain leaf in the scope tree. */
export interface ScopeTreeDomain {
  name: string;
  change_status?: ChangeStatus;
  /** Review percentage (0-100), or null when no review is needed (renders "—").
   *  Wired from the per-domain review-progress endpoint
   *  (`getReviewProgressByDomain`). */
  reviewPct?: number | null;
}

/** Current scope selection: "model" for the full-model view, or a domain name. */
export type Scope = "model" | { domain: string };

export function isModelScope(scope: Scope): scope is "model" {
  return scope === "model";
}

/** When present, domain names in the tree render as links to the model view. */
export interface ScopeTreeNavContext {
  businessId: string;
  versionInt: number;
  scope: string;
}

/**
 * The persistent two-level scope tree (Model + one leaf per domain) on the left
 * of the Statistics tab. Selecting a node rebinds the report pane — the tree
 * does not navigate; it drives a single `scope` state held by the parent.
 *
 * When `navContext` is supplied, each domain row gains a hover-visible external-
 * link icon that navigates to that domain's page in the model view.
 *
 * Intentionally 2 levels (model + domain). The footer note flags that the
 * subdomain/product level is a later extension, per the design-of-record.
 */
export function ScopeTree({
  domains,
  scope,
  onSelect,
  navContext,
}: {
  domains: ScopeTreeDomain[];
  scope: Scope;
  onSelect: (scope: Scope) => void;
  navContext?: ScopeTreeNavContext;
}) {
  const [domainsOpen, setDomainsOpen] = useState(true);

  const modelActive = isModelScope(scope);
  const activeDomain = isModelScope(scope) ? null : scope.domain;

  return (
    <nav
      aria-label="Scope"
      className="flex h-full flex-col overflow-y-auto border-r border-border"
    >
      <div className="flex items-center gap-1.5 px-3 pt-3 pb-2 text-xs font-semibold uppercase tracking-wide text-muted-foreground">
        <ListTree className="h-3.5 w-3.5" />
        Scope
      </div>

      <button
        type="button"
        aria-current={modelActive ? "true" : undefined}
        onClick={() => onSelect("model")}
        className={`mx-1.5 flex items-center gap-2 rounded-md px-2 py-1.5 text-left text-sm transition-colors ${
          modelActive
            ? "bg-primary/15 font-semibold text-foreground"
            : "hover:bg-accent"
        }`}
      >
        <Layers
          className={`h-[15px] w-[15px] ${modelActive ? "text-primary" : "text-muted-foreground"}`}
        />
        <span>Model</span>
        <span className="ml-auto text-xs text-muted-foreground">
          {domains.length}
        </span>
      </button>

      <button
        type="button"
        onClick={() => setDomainsOpen((o) => !o)}
        className="mx-1.5 mt-2 flex items-center gap-1.5 rounded-md px-2 py-1 text-left text-xs font-semibold uppercase tracking-wide text-muted-foreground hover:bg-accent"
      >
        {domainsOpen ? (
          <ChevronDown className="h-3.5 w-3.5" />
        ) : (
          <ChevronRight className="h-3.5 w-3.5" />
        )}
        Domains
        <span className="ml-auto normal-case font-normal">{domains.length}</span>
      </button>

      {domainsOpen && (
        <ul className="mt-0.5 flex flex-col">
          {domains.map((d) => {
            const active = activeDomain === d.name;
            return (
              <li key={d.name} className="group">
                <div className="mx-1.5 flex w-[calc(100%-0.75rem)] items-center">
                  <button
                    type="button"
                    aria-current={active ? "true" : undefined}
                    onClick={() => onSelect({ domain: d.name })}
                    className={`flex flex-1 min-w-0 items-center gap-2 rounded-md px-2 py-1.5 text-left text-sm transition-colors ${
                      active
                        ? "bg-primary/15 font-semibold text-foreground"
                        : "hover:bg-accent"
                    }`}
                  >
                    <span
                      aria-hidden
                      className={`h-2 w-2 shrink-0 rounded-full ${statusDotClass(d.change_status)}`}
                    />
                    <span className="truncate font-mono text-[13px]">{d.name}</span>
                    <span className="ml-auto text-xs text-muted-foreground">
                      {d.reviewPct == null ? "—" : `${Math.round(d.reviewPct)}%`}
                    </span>
                  </button>
                  {navContext && (
                    <Link
                      to="/businesses/$businessId/model/$version/$scope/$domainName"
                      params={{
                        businessId: navContext.businessId,
                        version: String(navContext.versionInt),
                        scope: navContext.scope,
                        domainName: d.name,
                      }}
                      search={{ tab: "products" }}
                      className="ml-0.5 shrink-0 rounded p-1 text-muted-foreground opacity-0 transition-opacity group-hover:opacity-60 hover:!opacity-100 hover:text-foreground"
                      aria-label={`Open ${d.name} in model view`}
                      title={`Open ${d.name} in model view`}
                    >
                      <ExternalLink className="h-3 w-3" />
                    </Link>
                  )}
                </div>
              </li>
            );
          })}
        </ul>
      )}

      <p className="mt-auto px-3 py-3 text-xs text-muted-foreground">
        Select a domain to see its breakdown.
      </p>
    </nav>
  );
}
