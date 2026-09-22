import {
  Target,
  Gauge,
  GitBranch,
  Database,
  Cpu,
  ListTree,
} from "lucide-react";
import type { DomainSummaryOut, ModelSummaryOut } from "@/lib/api";
import { ReviewProgress } from "@/components/review/review-progress";
import { AreaSection, SectionBoundary } from "./area-section";
import type { DegradationFlags } from "./area-section";
import type { StatsScope } from "./use-stats-data";
import { QualityModelBody, QualityDomainBody } from "./sections/quality-section";
import { ChangeModelBody, ChangeDomainBody } from "./sections/change-section";
import { WorkAheadBody } from "./sections/work-ahead-section";
import {
  SizeModelBody,
  EffortModelBody,
  SizeDomainBody,
} from "./sections/size-effort-section";
import { WhereToFocusBody, type FocusDomain } from "./sections/where-to-focus";
import { DomainBreakdownBody } from "./sections/domain-breakdown";
import { useDomainDetail } from "./use-stats-data";

export type { DegradationFlags } from "./area-section";

function BaseVersionNote() {
  return (
    <p
      data-testid="base-version-note"
      className="text-sm text-muted-foreground"
    >
      Base version — no predecessor.
    </p>
  );
}

/**
 * FULL-MODEL VIEW — sections in the documented order:
 * Review → Quality → Change → Where to focus → Work ahead → Size + Effort.
 */
export function ModelReport({
  scope,
  model,
  flags,
  onDrill,
}: {
  scope: StatsScope;
  model: ModelSummaryOut;
  flags: DegradationFlags;
  onDrill: (domain: string) => void;
}) {
  const focusDomains: FocusDomain[] = (model.domains ?? [])
    .filter((d) => d.change_status !== "deleted")
    .map((d) => ({
      name: d.name,
      change_status: d.change_status,
      productCount: d.product_count ?? 0,
    }));

  return (
    <div className="flex flex-col gap-3.5">
      <AreaSection icon={Target} label="Review progress" lead>
        <ReviewProgress
          businessId={scope.businessId}
          versionInt={scope.versionInt}
          scope={scope.scope}
        />
      </AreaSection>

      <AreaSection icon={Gauge} label="Quality">
        <SectionBoundary label="quality">
          <QualityModelBody scope={scope} flags={flags} />
        </SectionBoundary>
      </AreaSection>

      <AreaSection icon={GitBranch} label="Change">
        {flags.hasPredecessor ? (
          <SectionBoundary label="change">
            <ChangeModelBody scope={scope} hasConfidence={flags.hasConfidence} />
          </SectionBoundary>
        ) : (
          <BaseVersionNote />
        )}
      </AreaSection>

      <AreaSection icon={ListTree} label="Where to focus">
        <SectionBoundary label="where to focus">
          <WhereToFocusBody
            scope={scope}
            domains={focusDomains}
            hasPredecessor={flags.hasPredecessor}
            onDrill={onDrill}
          />
        </SectionBoundary>
      </AreaSection>

      <AreaSection icon={Database} label="Work ahead">
        <SectionBoundary label="work ahead">
          <WorkAheadBody scope={scope} />
        </SectionBoundary>
      </AreaSection>

      <AreaSection icon={Database} label="Size">
        <SectionBoundary label="size">
          <SizeModelBody scope={scope} model={model} />
        </SectionBoundary>
      </AreaSection>

      {/* Effort is MODEL-LEVEL ONLY (no domain equivalent). */}
      <AreaSection icon={Cpu} label="Effort">
        <SectionBoundary label="effort">
          <EffortModelBody scope={scope} />
        </SectionBoundary>
      </AreaSection>
    </div>
  );
}

/** Domain Size body needs the same domain detail the breakdown loads; this
 *  thin wrapper fetches it so Size can render its own boundary independently. */
function SizeDomainSection({
  scope,
  domain,
}: {
  scope: StatsScope;
  domain: string;
}) {
  const detail = useDomainDetail(scope, domain);
  return <SizeDomainBody detail={detail} />;
}

/**
 * DOMAIN VIEW — intentionally lighter & asymmetric, in the documented order:
 * Review → Domain breakdown → Quality → Change → Size. No Effort block.
 */
export function DomainReport({
  scope,
  domain,
  domainSummary,
  flags,
}: {
  scope: StatsScope;
  domain: string;
  /** The model-summary row for this domain — carries the DB ids + per-subdomain
   *  ids + product counts the breakdown's cascade controls need. Null if the
   *  domain isn't in the summary (degrades to no cascade controls). */
  domainSummary: DomainSummaryOut | null;
  flags: DegradationFlags;
}) {
  return (
    <div className="flex flex-col gap-3.5">
      <AreaSection icon={Target} label="Review progress" lead>
        <ReviewProgress
          businessId={scope.businessId}
          versionInt={scope.versionInt}
          scope={scope.scope}
        />
      </AreaSection>

      <AreaSection icon={ListTree} label="Domain breakdown">
        <SectionBoundary label="domain breakdown" fallbackHeight="h-32">
          <DomainBreakdownBody
            scope={scope}
            domain={domain}
            domainSummary={domainSummary}
            hasPredecessor={flags.hasPredecessor}
          />
        </SectionBoundary>
      </AreaSection>

      <AreaSection icon={Gauge} label="Quality">
        <SectionBoundary label="quality">
          <QualityDomainBody scope={scope} domain={domain} flags={flags} />
        </SectionBoundary>
      </AreaSection>

      <AreaSection icon={GitBranch} label="Change">
        {flags.hasPredecessor ? (
          <SectionBoundary label="change">
            <ChangeDomainBody scope={scope} domain={domain} />
          </SectionBoundary>
        ) : (
          <BaseVersionNote />
        )}
      </AreaSection>

      <AreaSection icon={Database} label="Size">
        <SectionBoundary label="size">
          <SizeDomainSection scope={scope} domain={domain} />
        </SectionBoundary>
      </AreaSection>
    </div>
  );
}
