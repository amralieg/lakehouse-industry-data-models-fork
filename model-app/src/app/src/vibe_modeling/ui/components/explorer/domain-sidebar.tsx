import { useState, useEffect, type ReactNode } from "react";
import { Link } from "@tanstack/react-router";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ChangeBadge } from "@/components/explorer/change-badge";
import { Database, FolderOpen, Layers, PanelRightClose, PanelRightOpen } from "lucide-react";

interface SubdomainEntry {
  name: string;
  product_count?: number;
}

interface DomainEntry {
  name: string;
  division?: string;
  product_count?: number;
  subdomains?: SubdomainEntry[];
  change_status?: string;
}

interface DomainSidebarProps {
  domains: DomainEntry[];
  businessId: string;
  version: string;
  scope: string;
  currentDomain?: string;
  children: ReactNode;
}

function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(() =>
    typeof window !== "undefined" ? window.matchMedia(query).matches : false
  );
  useEffect(() => {
    const mql = window.matchMedia(query);
    const handler = (e: MediaQueryListEvent) => setMatches(e.matches);
    mql.addEventListener("change", handler);
    return () => mql.removeEventListener("change", handler);
  }, [query]);
  return matches;
}

export function DomainSidebar({
  domains,
  businessId,
  version,
  scope,
  currentDomain,
  children,
}: DomainSidebarProps) {
  const isLarge = useMediaQuery("(min-width: 1280px)");
  const [expanded, setExpanded] = useState(isLarge);

  // Sync with screen size on mount and resize
  useEffect(() => {
    setExpanded(isLarge);
  }, [isLarge]);

  const activeDomains = domains.filter((d) => d.change_status !== "deleted");

  return (
    <div className="flex gap-0 relative">
      {/* Main content */}
      <div className="flex-1 min-w-0">{children}</div>

      {/* Toggle button */}
      <Button
        variant="ghost"
        size="icon"
        className="absolute top-0 right-0 z-10 h-8 w-8"
        onClick={() => setExpanded((v) => !v)}
        title={expanded ? "Hide domain navigator" : "Show domain navigator"}
      >
        {expanded ? (
          <PanelRightClose className="h-4 w-4" />
        ) : (
          <PanelRightOpen className="h-4 w-4" />
        )}
      </Button>

      {/* Sidebar */}
      {expanded && (
        <aside className="w-56 shrink-0 border-l pl-3 ml-3 space-y-1">
          <h3 className="text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2 mt-1">
            Domains
          </h3>

          {/* All Domains link */}
          <Link
            to="/businesses/$businessId/model/$version/$scope"
            params={{ businessId, version, scope }}
            search={{ tab: "overview" }}
            className={`flex items-center gap-2 px-2 py-1.5 rounded-md text-sm transition-colors ${
              !currentDomain
                ? "bg-accent text-accent-foreground font-medium"
                : "hover:bg-accent/50 text-muted-foreground"
            }`}
          >
            <Layers className="h-3.5 w-3.5 shrink-0" />
            <span className="truncate">All Domains</span>
            <Badge variant="outline" className="ml-auto text-[10px] px-1.5 py-0">
              {activeDomains.length}
            </Badge>
          </Link>

          {/* Domain list */}
          <div className="space-y-0.5">
            {activeDomains.map((d) => (
              <div key={d.name}>
                <Link
                  to="/businesses/$businessId/model/$version/$scope/$domainName"
                  params={{ businessId, version, scope, domainName: d.name }}
                  search={{ tab: "products" }}
                  className={`flex items-center gap-2 px-2 py-1.5 rounded-md text-sm transition-colors ${
                    currentDomain === d.name
                      ? "bg-accent text-accent-foreground font-medium"
                      : "hover:bg-accent/50 text-muted-foreground"
                  }`}
                >
                  <Database className="h-3.5 w-3.5 shrink-0" />
                  <span className="truncate">{d.name}</span>
                  <div className="ml-auto flex items-center gap-1 shrink-0">
                    <ChangeBadge status={d.change_status as any} />
                    {d.product_count != null && (
                      <Badge
                        variant="outline"
                        className="text-[10px] px-1.5 py-0"
                      >
                        {d.product_count}
                      </Badge>
                    )}
                  </div>
                </Link>
                {currentDomain === d.name &&
                  (d.subdomains ?? []).length > 0 && (
                    <div className="ml-5 mt-0.5 space-y-0.5">
                      {d.subdomains!.map((sd) => (
                        <div
                          key={sd.name}
                          className="flex items-center gap-2 px-2 py-1 text-xs text-muted-foreground"
                        >
                          <FolderOpen className="h-3 w-3 shrink-0" />
                          <span className="truncate">{sd.name}</span>
                          {sd.product_count != null && (
                            <Badge
                              variant="outline"
                              className="ml-auto text-[10px] px-1 py-0"
                            >
                              {sd.product_count}
                            </Badge>
                          )}
                        </div>
                      ))}
                    </div>
                  )}
              </div>
            ))}
          </div>
        </aside>
      )}
    </div>
  );
}
