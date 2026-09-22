import { Link } from "@tanstack/react-router";
import { ChevronRight } from "lucide-react";

interface Crumb {
  label: string;
  to?: string;
  params?: Record<string, string>;
  search?: Record<string, string>;
}

export function Breadcrumbs({ items }: { items: Crumb[] }) {
  return (
    <nav className="flex items-center gap-1 text-sm text-muted-foreground">
      {items.map((item, i) => (
        <span key={i} className="flex items-center gap-1">
          {i > 0 && <ChevronRight className="h-3 w-3" />}
          {item.to ? (
            <Link
              to={item.to}
              params={item.params}
              search={item.search as any}
              className="hover:text-foreground transition-colors"
            >
              {item.label}
            </Link>
          ) : (
            <span className="text-foreground font-medium">{item.label}</span>
          )}
        </span>
      ))}
    </nav>
  );
}
