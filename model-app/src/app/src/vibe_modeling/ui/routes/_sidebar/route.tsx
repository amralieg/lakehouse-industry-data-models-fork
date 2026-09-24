import SidebarLayout from "@/components/apx/sidebar-layout";
import { createFileRoute, Link, useLocation } from "@tanstack/react-router";
import { cn } from "@/lib/utils";
import { Building2, Factory } from "lucide-react";
import {
  Separator,
} from "@/components/ui/separator";
import {
  SidebarGroup,
  SidebarGroupContent,
  SidebarMenu,
  SidebarMenuItem,
} from "@/components/ui/sidebar";
import { BusinessTree } from "@/components/explorer/business-tree";
import { useGetBusiness, type BusinessOut } from "@/lib/api";
import { selector } from "@/lib/selector";

export const Route = createFileRoute("/_sidebar")({
  component: () => <Layout />,
});

type NavArea = "businesses" | "industries" | "settings" | "help";

/** Single resolver for which sidebar item highlights on a given path.
 *  Businesses and Industries share the `/businesses/$businessId/*` detail
 *  surface (an "industry" is a business with `kind === "industry"`), so the
 *  URL prefix alone can't tell them apart - the entity's `kind` decides.
 *  While `kind` is still loading (or unknown), default to "businesses" so
 *  there is no Industries flash on an industry page's first render. */
export function activeArea(path: string, businessKind: string | undefined): NavArea {
  if (path.startsWith("/settings")) return "settings";
  if (path.startsWith("/help")) return "help";
  if (path.startsWith("/industries")) return "industries";
  const businessMatch = path.match(/^\/businesses\/([^/]+)/);
  if (businessMatch) {
    const id = businessMatch[1];
    if (id !== "new" && businessKind === "industry") return "industries";
    return "businesses";
  }
  return "businesses";
}

export function Layout() {
  const location = useLocation();

  // Extract businessId from path if on a business route.
  // Exclude non-ID segments like "new" (the creation form) so we don't try
  // to fetch a business whose id is literally "new".
  const businessMatch = location.pathname.match(/^\/businesses\/([^/]+)/);
  const maybeBusinessId = businessMatch?.[1];
  const isSpecialSegment = maybeBusinessId === "new"; // add more as needed
  const businessId = !isSpecialSegment ? maybeBusinessId : undefined;
  const showBusinessTree = Boolean(businessId);

  // BusinessTree below suspense-fetches this same business id, so this
  // query joins an already-warm cache entry (no extra network round trip
  // once BusinessTree has resolved).
  const { data: business } = useGetBusiness<BusinessOut>({
    params: { business_id: businessId ?? "" },
    query: { enabled: !!businessId, ...selector<BusinessOut>().query },
  });
  const active = activeArea(location.pathname, business?.kind);

  const navItems = [
    {
      to: "/businesses",
      label: "Businesses",
      icon: <Building2 size={16} />,
      area: "businesses" as const,
    },
    {
      to: "/industries",
      label: "Industries",
      icon: <Factory size={16} />,
      area: "industries" as const,
    },
  ];

  return (
    <SidebarLayout>
      <SidebarGroup>
        <SidebarGroupContent>
          <SidebarMenu>
            {navItems.map((item) => (
              <SidebarMenuItem key={item.to}>
                <Link
                  to={item.to}
                  // TanStack's own active-matching is prefix-based and would
                  // independently mark "Businesses" current on every
                  // /businesses/$id/* page (including industries), stamping
                  // aria-current="page" on the wrong item regardless of the
                  // className below. `exact: true` confines that built-in
                  // resolution to the literal /businesses, /industries, and
                  // /settings paths - at those three, TanStack's own
                  // active-props spread *after* (and would win over) the
                  // explicit `aria-current` below, but `activeArea` always
                  // agrees with it there, so the override is a no-op. On
                  // every nested route TanStack's own resolution is false,
                  // so the explicit aria-current is the only source.
                  activeOptions={{ exact: true }}
                  aria-current={item.area === active ? "page" : undefined}
                  className={cn(
                    "flex items-center gap-2 p-2 rounded-lg",
                    item.area === active
                      ? "bg-sidebar-accent text-sidebar-accent-foreground"
                      : "text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground",
                  )}
                >
                  {item.icon}
                  <span>{item.label}</span>
                </Link>
              </SidebarMenuItem>
            ))}
          </SidebarMenu>
        </SidebarGroupContent>
      </SidebarGroup>

      {showBusinessTree && businessId && (
        <>
          <Separator className="my-1" />
          <SidebarGroup>
            <SidebarGroupContent>
              <BusinessTree businessId={businessId} />
            </SidebarGroupContent>
          </SidebarGroup>
        </>
      )}
    </SidebarLayout>
  );
}
