import { useEvolutionMetrics } from "../use-stats-data";
import type { StatsScope } from "../use-stats-data";
import type { ModelSummaryOut, DomainDetailOut } from "@/lib/api";

function Figure({ value, label }: { value: number | string; label: string }) {
  return (
    <div className="flex flex-col">
      <span className="text-lg font-bold tabular-nums">{value}</span>
      <span className="text-xs text-muted-foreground">{label}</span>
    </div>
  );
}

/**
 * Size (model) — the figure cluster from `getEvolutionMetrics` (T16) → `size`,
 * with a derived structural line. Falls back to the model summary's own counts
 * when evolution size is absent.
 */
export function SizeModelBody({
  scope,
  model,
}: {
  scope: StatsScope;
  model: ModelSummaryOut;
}) {
  const evo = useEvolutionMetrics(scope);
  const s = evo.size ?? {};

  const domains = s.domain_count ?? model.domain_count ?? 0;
  const products = s.product_count ?? model.product_count ?? 0;
  const attributes = s.attribute_count ?? model.attribute_count ?? 0;
  const fks = s.fk_count ?? model.fk_count ?? 0;
  const subdomains = model.subdomain_count ?? 0;
  const avgRaw =
    s.avg_attributes_per_product ?? (products > 0 ? attributes / products : 0);
  // Always render to 1 decimal regardless of source — the wire value may arrive
  // unrounded from older metrics, and the derived fallback is a raw ratio.
  const avg = Math.round(avgRaw * 10) / 10;
  const unlinked = s.unlinked_id_count ?? 0;
  const siloed = s.siloed_count ?? 0;

  return (
    <div className="space-y-3">
      <div className="grid grid-cols-3 gap-3 sm:grid-cols-5">
        <Figure value={domains} label="domains" />
        <Figure value={subdomains} label="subdomains" />
        <Figure value={products} label="products" />
        <Figure value={attributes} label="attributes" />
        <Figure value={fks} label="foreign keys" />
      </div>
      <div className="text-xs text-muted-foreground">
        {avg} avg attributes / product ·{" "}
        <span className={unlinked > 0 ? "text-warning" : ""}>
          {unlinked} unlinked ids
        </span>{" "}
        · {siloed} siloed tables
      </div>
    </div>
  );
}

/**
 * Effort (model-level ONLY) — AI calls, tokens, hours, cost, from
 * `getEvolutionMetrics` (T16) → `effort`. Degrades each missing figure to "—".
 */
export function EffortModelBody({ scope }: { scope: StatsScope }) {
  const evo = useEvolutionMetrics(scope);
  const e = evo.effort ?? {};

  const tokensIn = e.estimated_input_tokens;
  const tokensOut = e.estimated_output_tokens;
  const num = (v: number | null | undefined) =>
    v == null ? "—" : Math.round(v).toLocaleString();
  const tokens =
    tokensIn == null && tokensOut == null
      ? "—"
      : `${num(tokensIn)} in / ${num(tokensOut)} out`;

  return (
    <div className="flex flex-wrap items-end gap-x-6 gap-y-3">
      <Figure value={num(e.total_ai_calls)} label="AI calls" />
      <Figure value={tokens} label="tokens" />
      <Figure
        value={
          e.duration_hours == null
            ? "—"
            : `${Math.round(e.duration_hours * 10) / 10}h`
        }
        label="processing"
      />
      <Figure
        value={
          e.estimated_total_cost_usd == null
            ? "—"
            : `$${Math.round(e.estimated_total_cost_usd * 100) / 100}`
        }
        label="est. cost"
      />
      <span className="ml-auto self-center text-xs text-muted-foreground">
        model-level only
      </span>
    </div>
  );
}

/**
 * Size (domain) — figure cluster scoped to one domain, derived from the domain
 * detail (named products + attributes/fk counts). No Effort block at domain
 * scope (Effort is inherently model-level).
 */
export function SizeDomainBody({ detail }: { detail: DomainDetailOut }) {
  const products = detail.products ?? [];
  const subdomains = new Set(
    products.map((p) => p.subdomain).filter(Boolean),
  ).size;
  const attributes = products.reduce(
    (sum, p) => sum + (p.attribute_count ?? 0),
    0,
  );
  const fks = products.reduce((sum, p) => sum + (p.fk_count ?? 0), 0);

  return (
    <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
      <Figure value={products.length} label="products" />
      <Figure value={subdomains} label="subdomains" />
      <Figure value={attributes} label="attributes" />
      <Figure value={fks} label="foreign keys" />
    </div>
  );
}
