import { Suspense } from "react";
import { Link } from "@tanstack/react-router";
import { ErrorBoundary } from "react-error-boundary";
import { ChevronRight, Sparkles } from "lucide-react";
import {
  useGetNextVibesSuspense,
  type NextVibeItem,
  type NextVibesOut,
} from "@/lib/api";
import { selector } from "@/lib/selector";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";

interface NextVibesCardProps {
  businessId: string;
  modelVersionId: string;
}

export function NextVibesCard(props: NextVibesCardProps) {
  return (
    <ErrorBoundary fallback={null}>
      <Suspense fallback={<NextVibesSkeleton />}>
        <NextVibesCardInner {...props} />
      </Suspense>
    </ErrorBoundary>
  );
}

function NextVibesSkeleton() {
  return (
    <div className="space-y-3">
      <Skeleton className="h-6 w-60" />
      <Skeleton className="h-24 w-full" />
    </div>
  );
}

function NextVibesCardInner({ businessId, modelVersionId }: NextVibesCardProps) {
  const { data } = useGetNextVibesSuspense({
    params: { model_version_id: modelVersionId },
    ...selector<NextVibesOut>(),
  });

  // `items` is optional in the generated schema; normalize once. Each item is
  // one structured agent finding (static-analysis, priority-remediation, or
  // other-known-issue) read from the version's VibeInput rows.
  const items = data.items ?? [];

  if (!items.length) return null;

  const count = items.length;
  const hasMeta =
    (data.confidence_score !== null && data.confidence_score !== undefined) ||
    (data.status && data.status.length > 0);

  return (
    <details
      className="group"
      data-testid="next-vibes-card"
      open
    >
      <summary className="cursor-pointer list-none">
        <Card className="hover:bg-muted/20 transition-colors">
          <CardHeader className="flex flex-row items-center justify-between gap-2 space-y-0 py-3">
            <CardTitle className="text-base flex items-center gap-2">
              <Sparkles className="h-4 w-4 text-tertiary" />
              Suggested next vibes ({count})
            </CardTitle>
            <ChevronRight className="h-4 w-4 text-muted-foreground transition-transform group-open:rotate-90" />
          </CardHeader>
        </Card>
      </summary>
      <Card className="rounded-t-none border-t-0">
        <CardContent className="pt-4 space-y-3">
          {hasMeta && (
            <p className="text-xs text-muted-foreground">
              {data.status && (
                <span>
                  Status: <span className="font-medium">{data.status}</span>
                </span>
              )}
              {data.status && data.confidence_score != null && (
                <span className="mx-1.5">·</span>
              )}
              {data.confidence_score != null && (
                <span>
                  Confidence:{" "}
                  <span className="font-medium">
                    {Math.round(data.confidence_score * 100)}%
                  </span>
                </span>
              )}
            </p>
          )}
          {data.summary && (
            <p className="text-sm text-muted-foreground">{data.summary}</p>
          )}
          <ul className="space-y-3">
            {items.map((item) => (
              <NextVibeRow key={item.id} item={item} />
            ))}
          </ul>
          <div className="pt-1">
            <Link
              to="/businesses/$businessId/runs/new"
              params={{ businessId }}
              search={{
                operationType: "vibe modeling of version",
              }}
              className="text-sm text-tertiary hover:underline"
            >
              Use in vibe iterate →
            </Link>
          </div>
        </CardContent>
      </Card>
    </details>
  );
}

function NextVibeRow({ item }: { item: NextVibeItem }) {
  return (
    <li className="space-y-0.5">
      <p className="text-sm font-semibold">{item.title}</p>
      {item.description && (
        <p className="text-xs text-muted-foreground whitespace-pre-wrap break-words">
          {item.description}
        </p>
      )}
    </li>
  );
}
