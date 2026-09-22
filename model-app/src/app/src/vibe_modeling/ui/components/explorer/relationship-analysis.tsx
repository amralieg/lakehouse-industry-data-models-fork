import { useSuspenseQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Link2, ArrowRightLeft, RotateCw } from "lucide-react";
import { getRelationshipAnalysis } from "@/lib/api";

// Backend always populates these fields; the OpenAPI schema marks them
// optional, so we narrow at the fetcher boundary to the strict shape this
// component expects (parity with the prior hand-rolled `interface`).
type RelationshipData = {
  total_fk_count: number;
  cross_domain_fk_count: number;
  intra_domain_fk_count: number;
  domain_connectivity: Array<{
    source_domain: string;
    target_domain: string;
    fk_count: number;
  }>;
};

async function fetchRelationships(
  businessId: string,
  version: string,
  scope: string
): Promise<RelationshipData> {
  const resp = await getRelationshipAnalysis({
    business_id: businessId,
    version_int: Number(version),
    scope,
  });
  const d = resp.data;
  return {
    total_fk_count: d.total_fk_count ?? 0,
    cross_domain_fk_count: d.cross_domain_fk_count ?? 0,
    intra_domain_fk_count: d.intra_domain_fk_count ?? 0,
    domain_connectivity: (d.domain_connectivity ?? []).map((c) => ({
      source_domain: c.source_domain,
      target_domain: c.target_domain,
      fk_count: c.fk_count,
    })),
  };
}

export function RelationshipAnalysis({
  businessId,
  version,
  scope,
}: {
  businessId: string;
  version: string;
  scope: string;
}) {
  const { data } = useSuspenseQuery({
    queryKey: ["relationship-analysis", businessId, version, scope],
    queryFn: () => fetchRelationships(businessId, version, scope),
  });

  const maxFk = Math.max(...data.domain_connectivity.map((c) => c.fk_count), 1);

  return (
    <div className="space-y-6 mt-4">
      {/* FK stats */}
      <div className="grid grid-cols-3 gap-4">
        <Card>
          <CardContent className="flex items-center gap-3 py-4">
            <div className="text-muted-foreground">
              <Link2 className="h-5 w-5" />
            </div>
            <div>
              <div className="text-xl font-semibold">{data.total_fk_count}</div>
              <div className="text-xs text-muted-foreground">Total FKs</div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-3 py-4">
            <div className="text-muted-foreground">
              <ArrowRightLeft className="h-5 w-5" />
            </div>
            <div>
              <div className="text-xl font-semibold">
                {data.cross_domain_fk_count}
              </div>
              <div className="text-xs text-muted-foreground">Cross-domain</div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-3 py-4">
            <div className="text-muted-foreground">
              <RotateCw className="h-5 w-5" />
            </div>
            <div>
              <div className="text-xl font-semibold">
                {data.intra_domain_fk_count}
              </div>
              <div className="text-xs text-muted-foreground">Intra-domain</div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Domain connectivity chart */}
      {data.domain_connectivity.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="text-base">
              Domain Connectivity (top {data.domain_connectivity.length})
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {data.domain_connectivity.map((c) => (
                <div
                  key={`${c.source_domain}-${c.target_domain}`}
                  className="flex items-center gap-3"
                >
                  <div className="w-48 text-sm text-right truncate shrink-0">
                    <span className="font-medium">{c.source_domain}</span>
                    <span className="text-muted-foreground mx-1">↔</span>
                    <span className="font-medium">{c.target_domain}</span>
                  </div>
                  <div className="flex-1 bg-secondary rounded-full h-5 relative">
                    <div
                      className="bg-primary h-5 rounded-full transition-all"
                      style={{
                        width: `${Math.max((c.fk_count / maxFk) * 100, 4)}%`,
                      }}
                    />
                  </div>
                  <div className="w-8 text-sm font-medium text-right">
                    {c.fk_count}
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {data.domain_connectivity.length === 0 && data.total_fk_count > 0 && (
        <Card>
          <CardContent className="py-8 text-center text-muted-foreground">
            All {data.total_fk_count} foreign keys are within the same domains
            (no cross-domain relationships).
          </CardContent>
        </Card>
      )}

      {data.total_fk_count === 0 && (
        <Card>
          <CardContent className="py-8 text-center text-muted-foreground">
            No foreign key relationships found in this model version.
          </CardContent>
        </Card>
      )}
    </div>
  );
}
