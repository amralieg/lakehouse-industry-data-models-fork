import { Link } from "@tanstack/react-router";
import { ExternalLink, Link2 } from "lucide-react";
import { useGetDomainDetail, type DomainDetailOut } from "@/lib/api";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";

interface FkLinkProps {
  /** Raw `foreign_key_to` string, format "domain.table.column". */
  foreignKeyTo: string;
  businessId: string;
  version: string;
  scope: string;
  /** "text" (default) renders the "domain.table.column" label; "icon" renders
   *  a compact link glyph with the reference in a tooltip (the products-table
   *  cell variant). */
  variant?: "text" | "icon";
}

/**
 * Renders a navigable link to an attribute's foreign-key TARGET product.
 *
 * The single FK-navigation component (both the explorer text label and the
 * product-table icon share it). It resolves the FK's middle token to the
 * target product's route key before linking:
 *
 * Product routes are keyed by product `name` (see business-tree.tsx and the
 * `$productName` route), but an FK's `foreign_key_to` middle segment can hold
 * the product's *physical* `table_name` instead — those diverge once a product
 * is renamed (common on a v2 vibe iteration), so linking on the raw token
 * 404s. We look up the target domain's products for the CURRENT (version,
 * scope) and match the token against either `name` or `table_name`, then link
 * on the resolved `name`. If the token resolves to no product in this version
 * (e.g. the target lives in another scope or was removed) the reference renders
 * disabled with an explanatory tooltip rather than a dead link into a 404.
 */
export function FkLink({
  foreignKeyTo,
  businessId,
  version,
  scope,
  variant = "text",
}: FkLinkProps) {
  const parts = foreignKeyTo.split(".");
  const canResolve = parts.length >= 2;
  const domain = parts[0] ?? "";
  const table = parts[1] ?? "";
  const column = parts[2];

  // Called unconditionally (rules of hooks); gated via `enabled` so malformed
  // references don't fire a request. React Query dedupes by key, so many FK
  // cells pointing at the same domain share one fetch.
  const { data: domainDetail, isLoading } = useGetDomainDetail<DomainDetailOut>({
    params: {
      business_id: businessId,
      version_int: Number(version),
      scope,
      domain_name: domain,
    },
    query: {
      enabled: canResolve,
      select: (d: { data: DomainDetailOut }) => d.data,
    },
  });

  const label = `${domain}.${table}${column ? `.${column}` : ""}`;

  // Malformed (single-segment) reference — nothing to link to.
  if (!canResolve) {
    if (variant === "icon") {
      return <Link2 className="h-4 w-4 text-muted-foreground" />;
    }
    return <span className="text-muted-foreground">{foreignKeyTo}</span>;
  }

  const products = domainDetail?.products ?? [];
  const match = products.find(
    (p) => p.name === table || p.table_name === table,
  );
  const resolvedName = match?.name;

  // Resolved → active link on the product's route key (its `name`).
  if (resolvedName) {
    if (variant === "icon") {
      return (
        <TooltipProvider delayDuration={200}>
          <Tooltip>
            <TooltipTrigger asChild>
              <Link
                to="/businesses/$businessId/model/$version/$scope/$domainName/$productName"
                params={{
                  businessId,
                  version,
                  scope,
                  domainName: domain,
                  productName: resolvedName,
                }}
                className="inline-flex"
              >
                <Link2 className="h-4 w-4 text-info hover:text-info cursor-pointer" />
              </Link>
            </TooltipTrigger>
            <TooltipContent>
              <p className="font-mono text-xs">{foreignKeyTo}</p>
            </TooltipContent>
          </Tooltip>
        </TooltipProvider>
      );
    }
    return (
      <Link
        to="/businesses/$businessId/model/$version/$scope/$domainName/$productName"
        params={{
          businessId,
          version,
          scope,
          domainName: domain,
          productName: resolvedName,
        }}
        className="inline-flex items-center gap-1 text-info hover:underline"
      >
        <ExternalLink className="h-3 w-3" />
        <span>{label}</span>
      </Link>
    );
  }

  // Still loading the target domain — render a neutral, non-interactive token
  // (avoid flashing a link that might turn out to be unresolvable).
  if (isLoading) {
    if (variant === "icon") {
      return <Link2 className="h-4 w-4 text-muted-foreground animate-pulse" />;
    }
    return <span className="text-muted-foreground">{label}</span>;
  }

  // Settled, but the token resolves to no product in this version/scope —
  // disabled reference with an explanatory tooltip, not a dead 404 link.
  const disabledTip = `${foreignKeyTo} — target not found in this model version`;
  if (variant === "icon") {
    return (
      <TooltipProvider delayDuration={200}>
        <Tooltip>
          <TooltipTrigger asChild>
            <Link2
              className="h-4 w-4 text-muted-foreground/60 cursor-not-allowed"
              aria-disabled="true"
            />
          </TooltipTrigger>
          <TooltipContent>
            <p className="font-mono text-xs">{disabledTip}</p>
          </TooltipContent>
        </Tooltip>
      </TooltipProvider>
    );
  }
  return (
    <TooltipProvider delayDuration={200}>
      <Tooltip>
        <TooltipTrigger asChild>
          <span
            className="inline-flex items-center gap-1 text-muted-foreground cursor-not-allowed"
            aria-disabled="true"
          >
            <ExternalLink className="h-3 w-3" />
            <span>{label}</span>
          </span>
        </TooltipTrigger>
        <TooltipContent>
          <p className="font-mono text-xs">{disabledTip}</p>
        </TooltipContent>
      </Tooltip>
    </TooltipProvider>
  );
}
