import { useEffect, useState } from "react";
import { AlertTriangle, ArrowUpCircle, Check } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { getAgentCompat, type AgentCompatOut } from "@/lib/api";

export type AgentCompatChange = {
  tag: string;
  severity: string;
  area: string;
  summary: string;
};

/**
 * The Surface-2 fields the backend added to `AgentCompatOut`. Declared as an
 * intersection so this card + its tests type-check before Orval regenerates
 * `lib/api.ts` (the generated type is not hand-edited). Once regenerated the
 * extra optionals are redundant-but-harmless.
 */
export type AgentCompatInfo = AgentCompatOut & {
  verdict?: string;
  update_app_required?: boolean;
  install_offered?: boolean;
  pinned_release?: string;
  pinned_agent_marker?: string;
  latest_upstream_release?: string | null;
  latest_upstream_marker?: string | null;
  checked_at?: string | null;
  check_error?: string | null;
};

type Verdict = "up_to_date" | "build_update_available" | "release_incompatible";

type Props = {
  /** Optional override for tests — replaces the live fetch. */
  fetcher?: () => Promise<AgentCompatInfo>;
};

/**
 * Derive the three-way verdict, tolerating a legacy response (pre-Surface-2)
 * that carries only `newer_available` + `has_breaking_change`.
 */
function resolveVerdict(info: AgentCompatInfo): Verdict {
  if (info.verdict === "release_incompatible" || info.verdict === "build_update_available" || info.verdict === "up_to_date") {
    return info.verdict;
  }
  if (!info.newer_available) return "up_to_date";
  return info.has_breaking_change ? "release_incompatible" : "build_update_available";
}

/**
 * Settings card surfacing whether the upstream agent has advanced past what
 * the app pins. Passive UI — no install action (deferred to a later phase).
 * Three verdicts:
 *  - `release_incompatible`: upstream shipped a newer release the app can't
 *    target — prompts the user to update the APP (warning styling).
 *  - `build_update_available`: same release, newer build — informational only.
 *  - `up_to_date`: subtle confirmation.
 *
 * The live fetch goes through the Orval-generated `getAgentCompat` helper; the
 * `fetcher` prop is the supported test seam (the existing tests render this card
 * without a `QueryClientProvider`, so `useGetAgentCompat` is deliberately not used).
 */
export function AgentReleaseCard({ fetcher }: Props = {}) {
  const [info, setInfo] = useState<AgentCompatInfo | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const load = fetcher ?? (async () => (await getAgentCompat()).data as AgentCompatInfo);
    void load()
      .then((body) => {
        if (!cancelled) setInfo(body);
      })
      .catch((e: unknown) => {
        if (!cancelled) {
          setError(e instanceof Error ? e.message : String(e));
        }
      });
    return () => {
      cancelled = true;
    };
  }, [fetcher]);

  if (error) {
    // Fail quiet on the Settings page — the card is advisory, not critical.
    return null;
  }
  if (!info) return null;

  const verdict = resolveVerdict(info);
  const pinnedRelease = info.pinned_release || info.pinned_version;
  const upstreamRelease = info.latest_upstream_release || info.latest_known_upstream;
  const upstreamMarker = info.latest_upstream_marker;
  const knownBreaking = info.known_breaking_changes;

  if (verdict === "up_to_date") {
    return (
      <div
        data-testid="agent-release-card"
        className="mb-4 rounded-md border border-green-500/30 bg-green-500/5 px-3 py-2 text-xs flex items-start gap-2"
      >
        <Check className="h-4 w-4 text-green-600 dark:text-green-400 shrink-0 mt-0.5" />
        <div className="text-muted-foreground">
          Agent is up to date. Pinned to{" "}
          <Badge variant="outline" className="ml-0.5 mr-0.5">
            {pinnedRelease}
          </Badge>
          — matches the latest upstream release.
        </div>
      </div>
    );
  }

  if (verdict === "release_incompatible") {
    return (
      <div
        role="alert"
        data-testid="agent-release-card"
        className="mb-4 rounded-md border border-warning/40 bg-warning/5 px-3 py-2 text-xs space-y-2"
      >
        <div className="flex items-start gap-2">
          <AlertTriangle className="h-4 w-4 text-warning shrink-0 mt-0.5" />
          <div className="flex-1">
            <p className="font-medium">Update required: a newer agent release is available</p>
            <div className="text-muted-foreground">
              A newer agent release (
              <Badge variant="outline" className="mx-0.5">
                {upstreamRelease}
              </Badge>
              ) is available. This app version targets release{" "}
              <Badge variant="outline" className="mx-0.5">
                {pinnedRelease}
              </Badge>{" "}
              and can't use it — update the app to adopt it.
            </div>
          </div>
        </div>
        {(knownBreaking?.length ?? 0) > 0 && (
          <div className="pl-6 space-y-1">
            <p className="text-[11px] uppercase tracking-wide text-muted-foreground">
              Known breaking changes
            </p>
            <ul className="list-disc pl-4 space-y-0.5">
              {knownBreaking!.map((c, idx) => (
                <li key={`${c.tag}-${c.area}-${idx}`}>
                  <span className="font-mono">{c.tag}</span>{" "}
                  <span className="text-muted-foreground">[{c.area}]</span> {c.summary}
                </li>
              ))}
            </ul>
          </div>
        )}
      </div>
    );
  }

  // build_update_available — informational, no action.
  return (
    <div
      data-testid="agent-release-card"
      className="mb-4 rounded-md border border-primary/30 bg-primary/5 px-3 py-2 text-xs flex items-start gap-2"
    >
      <ArrowUpCircle className="h-4 w-4 text-primary shrink-0 mt-0.5" />
      <div className="text-muted-foreground">
        A newer agent build is available
        {upstreamMarker ? (
          <>
            {" "}
            (
            <Badge variant="outline" className="mx-0.5">
              {upstreamMarker}
            </Badge>
            )
          </>
        ) : null}{" "}
        for the current release{" "}
        <Badge variant="outline" className="mx-0.5">
          {pinnedRelease}
        </Badge>
        . The app already supports this release — no action needed.
      </div>
    </div>
  );
}
