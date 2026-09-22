"""DAG description: the ``OperationStep`` and ``Dag`` types.

Per ``docs/orchestrator-design.md`` §3, a ``Dag`` is an ordered, frozen
list of ``OperationStep``s. The validator (``validate.py``) walks the
list, looks each step up in the operation registry, and runs the step's
``params_model`` plus the DAG-level ``validate_cross_step`` rules.

Field-level + within-step validation lives on each operation's
``params_model`` (Pydantic). This module owns only the *cross-step*
invariants — rules that span more than one step.
"""

import re
from dataclasses import dataclass
from typing import Optional

from ._types import Issue


# Status tokens that, when seen after a ``<name>.`` in a ``skip_if``
# predicate, indicate the predicate references the terminal state of a
# prior step (e.g. ``"other_step.failed"`` / ``"my_step.succeeded"``).
# Predicates that don't use this shape (e.g. inherited-param checks like
# ``"cataloging_style != 'One Catalog'"``) won't match.
_SKIP_IF_STATUS_TOKENS = (
    "succeeded",
    "failed",
    "skipped",
    "completed",
    "rolled_back",
)
_SKIP_IF_STEP_REF_RE = re.compile(
    r"\b([A-Za-z_][A-Za-z0-9_]*)\.(?:" + "|".join(_SKIP_IF_STATUS_TOKENS) + r")\b"
)


# Carry-keys propagated from the Run intent (spec §2 OperationContext.
# inherited_params). When a step's literal ``params`` sets one of these
# AND the run-level ``inherited_params`` sets a different value, the DAG
# is internally inconsistent — the orchestrator can't honour both.
_INHERITED_PARAM_CARRY_KEYS = (
    "cataloging_style",
    "naming_convention",
    "primary_key_suffix",
    "schema_suffix",
    "tag_prefix",
    "tag_suffix",
    "table_id_type",
    "boolean_format",
    "date_format",
    "timestamp_format",
    "catalog_prefix",
    "catalog_suffix",
    "deployment_catalog",
)


@dataclass(frozen=True, slots=True)
class OperationStep:
    """Static description of a single use of an Operation.

    Per spec §2.1: an ``OperationStep`` is dumb data. It carries a
    primitive ``name`` (resolved against the registry at validation +
    dispatch time), the raw ``params`` dict (validated against the
    operation's ``params_model``), an optional ``skip_if`` predicate, and
    an optional ``needs_version_from`` cross-reference to a prior step
    whose ``output_version_id`` should become this step's
    ``parent_version_id``.

    The step does NOT validate itself — see ``validate_dag``.
    """

    name: str
    params: dict
    skip_if: Optional[str] = None
    needs_version_from: Optional[str] = None


@dataclass(frozen=True, slots=True)
class Dag:
    """Ordered DAG of operation steps for a single Run.

    ``steps`` is a frozen tuple — the orchestrator may pass a Dag across
    threads/tasks, and immutability sidesteps a class of bugs where a
    factory accidentally mutates a step list after handing it off.

    No fan-out / no parallel branches in v1 (spec §3): every Dag is a
    linear sequence. The orchestrator guarantees serial execution within
    a single Run.

    ``inherited_params`` mirrors the ``OperationContext.inherited_params``
    carry-keys that the orchestrator threads into every op (spec §2.4).
    The factory may stamp them on the Dag so the validator can detect
    cross-layer contradictions between a step's literal ``params`` and
    the run-level inherited values. Empty dict by default — legacy
    factories that don't set it skip the rule.
    """

    intent: str
    steps: tuple[OperationStep, ...]
    inherited_params: dict = None  # type: ignore[assignment]

    def __post_init__(self) -> None:
        # Frozen dataclasses can't reassign in __post_init__ via simple
        # attribute access; route through object.__setattr__ to honour
        # ``frozen=True``. Default mutable arguments are a footgun on a
        # frozen dataclass — keep the public API a plain ``dict`` while
        # ensuring every instance has its own.
        if self.inherited_params is None:
            object.__setattr__(self, "inherited_params", {})

    def validate_cross_step(self) -> list[Issue]:
        """Cross-step invariants. Pure — returns ``Issue``s, never raises.

        The rules in scope here are exactly the ones that a single
        ``OperationStep`` cannot check on its own:

        - **Zero-step DAG** is a blocker. A Dag with no steps produces a
          Run with no work — almost certainly a programming error in
          the factory.
        - ``needs_version_from`` MUST reference a step that comes
          strictly before this one. References to a later step or to a
          name that does not appear at all in the DAG are blockers.
        - ``needs_version_from`` MUST be unambiguous: if multiple prior
          steps share that ``name``, the orchestrator does not know
          which one's ``output_version_id`` to inherit. That's a
          blocker.
        - **``skip_if`` step reference** — when a predicate uses the
          ``<step>.<status>`` shape (e.g. ``"other_step.failed"``),
          ``<step>`` MUST appear elsewhere in the DAG.
        - **``inherited_params`` contradiction** — when the Dag-level
          ``inherited_params`` sets a carry-key (e.g.
          ``cataloging_style="One Catalog"``) and a step's literal
          ``params`` sets a different value for the same key, the
          orchestrator cannot honour both. That's a blocker.

        Field-level + within-step rules (regex, enums, "One Catalog
        requires schema_prefix") are owned by each step's
        ``params_model`` per spec §2.4 and run from
        ``services.orchestrator.validate.validate_dag``.
        """
        issues: list[Issue] = []

        # Zero-step DAG — a degenerate, almost-certainly-buggy state.
        # Surface as a single DAG-level blocker (step_index=-1 per the
        # ``Issue`` contract for findings that span no specific step).
        if not self.steps:
            issues.append(
                Issue(
                    field_path="steps",
                    step_index=-1,
                    message="DAG has zero steps; nothing to dispatch",
                    severity="blocker",
                )
            )
            # Nothing else to check on an empty step list.
            return issues

        for i, step in enumerate(self.steps):
            if step.needs_version_from:
                prior = self.steps[:i]
                target = step.needs_version_from
                prior_count = sum(1 for s in prior if s.name == target)

                if prior_count == 0:
                    # Either the named step does not exist anywhere, or
                    # it appears later in the DAG (which is the same
                    # problem for the orchestrator: at dispatch time for
                    # step i, the later step has not produced a version
                    # yet).
                    issues.append(
                        Issue(
                            field_path=f"steps[{i}].needs_version_from",
                            step_index=i,
                            message=(
                                f"References unknown or later step '{target}'"
                            ),
                            severity="blocker",
                        )
                    )
                elif prior_count > 1:
                    issues.append(
                        Issue(
                            field_path=f"steps[{i}].needs_version_from",
                            step_index=i,
                            message=(
                                f"Ambiguous: prior steps named '{target}' "
                                f"appear {prior_count} times"
                            ),
                            severity="blocker",
                        )
                    )

            # ``skip_if`` step reference: the runner currently treats any
            # non-empty ``skip_if`` as "skip", but DAG factories may
            # encode predicates that reference other steps via the
            # ``<step>.<status>`` shape (e.g. ``"prep.failed"``). If the
            # referenced step doesn't appear anywhere in the DAG, the
            # predicate is meaningless and the DAG is malformed.
            if step.skip_if:
                step_names = {s.name for s in self.steps}
                for match in _SKIP_IF_STEP_REF_RE.finditer(step.skip_if):
                    referenced = match.group(1)
                    if referenced not in step_names:
                        issues.append(
                            Issue(
                                field_path=f"steps[{i}].skip_if",
                                step_index=i,
                                message=(
                                    f"References unknown step "
                                    f"'{referenced}' in skip_if predicate"
                                ),
                                severity="blocker",
                            )
                        )

            # ``inherited_params`` contradiction: when both the Dag-level
            # inherited carry-keys and the step's literal ``params`` set
            # the same key to different values, the orchestrator cannot
            # honour both — at dispatch time it threads
            # ``inherited_params`` into the OperationContext while the
            # step's params shape goes into ``params``, and the
            # primitive sees two competing values for the same logical
            # setting (e.g. ``cataloging_style``).
            if self.inherited_params:
                for key in _INHERITED_PARAM_CARRY_KEYS:
                    if key not in self.inherited_params:
                        continue
                    if key not in step.params:
                        continue
                    inherited_v = self.inherited_params[key]
                    step_v = step.params[key]
                    if inherited_v != step_v:
                        issues.append(
                            Issue(
                                field_path=f"steps[{i}].params.{key}",
                                step_index=i,
                                message=(
                                    f"Contradicts inherited_params: "
                                    f"step has {key}={step_v!r} but "
                                    f"inherited_params has "
                                    f"{key}={inherited_v!r}"
                                ),
                                severity="blocker",
                            )
                        )

        return issues
