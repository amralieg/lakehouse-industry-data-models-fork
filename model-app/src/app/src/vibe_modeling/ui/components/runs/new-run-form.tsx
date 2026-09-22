/**
 * Standalone "create new run" form component (spec §2.4 + §2.4.1).
 *
 * The full New Run page lives at ``routes/_sidebar/runs.new.tsx`` and
 * is a heavy, multi-section workflow. This component is the minimum
 * embeddable shell tests + lightweight callers (e.g. inline
 * "create-from-feedback" widgets) need: a single catalog input that
 * debounces (300ms) into ``POST /runs/validate``, surfaces inline
 * blockers + warnings, and disables Submit while blockers are present.
 *
 * The component is intentionally tiny — heavier flows (advanced
 * convention overrides, vibe instructions, deployment-catalog picker)
 * stay on the route. If you need a richer form, prefer
 * ``routes/_sidebar/runs.new.tsx``.
 */
import { useEffect, useRef, useState } from "react";
import { notifyError } from "@/lib/notify";
import {
  createRun,
  validateRun,
  type IssueOut,
  type RunIn,
} from "@/lib/api";

type Issue = IssueOut;

type Props = {
  businessId: string;
  /** Override default cataloging style for the validate body. */
  catalogingStyle?: string;
  /** Optional callback fired after a successful POST /runs. */
  onCreated?: (runId: string) => void;
};

const DEBOUNCE_MS = 300;

export function NewRunForm({
  businessId,
  catalogingStyle = "One Catalog",
  onCreated,
}: Props) {
  const [catalog, setCatalog] = useState("");
  const [warnings, setWarnings] = useState<Issue[]>([]);
  const [blockers, setBlockers] = useState<Issue[]>([]);
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  function scheduleValidate(nextCatalog: string) {
    if (debounceRef.current) {
      clearTimeout(debounceRef.current);
    }
    debounceRef.current = setTimeout(() => {
      // Phase 7 drift-unification: route through the Orval-generated
      // validateRun helper. The component remains testable under
      // ``vi.useFakeTimers()`` because validateRun is implemented atop
      // ``global.fetch`` — the existing test mocks fetch by URL and
      // body and continues to intercept correctly.
      const body: RunIn = {
        intent: "new-base-model",
        catalog: nextCatalog,
        cataloging_style: catalogingStyle,
      };
      validateRun({ business_id: businessId }, body)
        .then((resp) => {
          setWarnings(resp.data.warnings ?? []);
          setBlockers(resp.data.blockers ?? []);
        })
        .catch(() => {
          // Validation request errors don't block the form — they
          // surface again on the next keystroke.
        });
    }, DEBOUNCE_MS);
  }

  useEffect(
    () => () => {
      if (debounceRef.current) {
        clearTimeout(debounceRef.current);
      }
    },
    [],
  );

  const hasBlockers = blockers.length > 0;
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit() {
    setSubmitting(true);
    try {
      const body: RunIn = {
        intent: "new-base-model",
        catalog,
        cataloging_style: catalogingStyle,
      };
      const resp = await createRun({ business_id: businessId }, body);
      onCreated?.(resp.data.id);
    } catch (err) {
      notifyError(err, { fallback: "Failed to create run" });
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="space-y-3">
      <input
        type="text"
        value={catalog}
        onChange={(e) => {
          const next = e.target.value;
          setCatalog(next);
          scheduleValidate(next);
        }}
        placeholder="catalog"
        aria-label="catalog"
      />
      {blockers.map((b, i) => (
        <p
          key={`blocker-${i}`}
          data-severity="blocker"
          className="text-sm text-destructive"
        >
          {b.message}
        </p>
      ))}
      {warnings.map((w, i) => (
        <p
          key={`warning-${i}`}
          data-severity="warning"
          className="text-sm text-warning"
        >
          {w.message}
        </p>
      ))}
      <button type="button" onClick={handleSubmit} disabled={hasBlockers || submitting}>
        {submitting ? "Creating…" : "Create run"}
      </button>
    </div>
  );
}
