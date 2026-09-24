/**
 * Pure derivation of the New Run form's submit-button blockers.
 *
 * Drift-unification (the model-versioning work, Phase 5): two booleans
 * (`baseContextMissing`, `vibeInstructionsMissing`) were derived inline
 * inside `routes/_sidebar/runs.new.tsx` and then re-tested in the Submit
 * `disabled` prop, with copy-paste comments explaining each gate. Adding a
 * third gate meant remembering to update both call sites and keeping the
 * disabled-reason banner in sync with the actual disabled condition.
 *
 * One pure function so the form just spreads the result and renders the
 * correct inline reason.
 */

export interface RunFormState {
  isBase: boolean;
  isVibe: boolean;
  contextMode: "text" | "path";
  businessContextText: string;
  businessContextPath: string;
  /** Count of Vibe Inputs selected on the compose surface that will be compiled
   *  into the run (the read-only compiled preview is their rendering). */
  inputCount: number;
}

export interface RunFormBlockers {
  /** new-base-model with neither freeform context nor a context path. */
  baseContextMissing: boolean;
  /** vibe-* run with no selected Vibe Inputs. The selected inputs (compiled
   *  server-side) are the content; an empty selection is the blocker. */
  vibeContentMissing: boolean;
  /** True when there is at least one blocker — handy as a single test
   *  for the `disabled` prop. Doesn't include external blockers like
   *  `submitting` or live-validate errors; those stay caller-owned. */
  hasBlocker: boolean;
}

/**
 * Compute submit blockers from the form state. Pure; no side effects.
 *
 * Intentionally does NOT include `submitting`, `eligibleBaseVersions.length === 0`,
 * or live `validateBlockers` — those are runtime/external concerns the form
 * combines with the result of this function. The split keeps this helper a
 * pure function of form-input state, which is testable in isolation and
 * doesn't drag the entire validator stack into a unit test.
 */
export function deriveRunFormBlockers(state: RunFormState): RunFormBlockers {
  const baseContextMissing =
    state.isBase
    && (
      (state.contextMode === "text" && state.businessContextText.trim() === "")
      || (state.contextMode === "path" && state.businessContextPath.trim() === "")
    );

  const vibeContentMissing = state.isVibe && state.inputCount === 0;

  return {
    baseContextMissing,
    vibeContentMissing,
    hasBlocker: baseContextMissing || vibeContentMissing,
  };
}
