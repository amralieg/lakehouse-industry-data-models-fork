"""Parser for the agent's ``Version Resolution`` / ``Version Collision Auto-Resolved``
progress event.

Background
----------
When the agent detects that the version it was about to write (e.g. ``v1_mvm``)
collides with an existing artifact on Volume, it auto-bumps to the next free
ordinal (e.g. ``v3_mvm``) and emits a single ``stage_warning`` event:

    _vibe_writer.emit_step(
        stage_name="Version Resolution",
        step_name="Version Collision Auto-Resolved",
        status="stage_warning",
        progress_increment=0.0,
        message=msg,
        result_json={
            "original_target": 1,
            "new_target": 3,
            "target_scope": "mvm",
            "source_version": 1,
            "source_scope": "ecm",
        },
    )

The App pre-allocates the output version at observe-time via
``next_version_for_scope``. Without parsing this event, that allocation
recomputes ``v1`` while the agent has already written to ``v3``, leaving the
``ModelVersion`` row out of sync with the Volume artifacts the agent
produced (the 2026-05-04 the test workspace incident).

Contract
--------
Predicate (BOTH must hold):

* Primary: ``stage_name == "Version Resolution"`` AND
  ``step_name == "Version Collision Auto-Resolved"``.
* Hardening: ``result_json`` contains all three of
  ``original_target``, ``new_target``, ``target_scope``.

When the predicate fires AND ``original_target != new_target``, the parser
records the resolution as the authoritative version for the run + scope.
Two consumers read this record:

1. ``_sync_orch_progress_events`` (this module): if a ``ModelVersion``
   row already exists for this run + scope at ``original_target``, atomically
   re-stamp it to ``new_target`` (and rewrite any ``RunArtifact.file_path``
   strings that embed the old version segment).
2. ``observe_generation_op`` (``services/operations/_generation_common.py``):
   on success, before computing ``next_version_for_scope``, call
   :func:`lookup_resolved_version` and prefer that ordinal when present.

Storage
-------
The parser does NOT add a column. The decision is durable inside the
already-persisted ``RunProgressEvent.result_json`` blob for this run.
:func:`lookup_resolved_version` re-queries that blob, which avoids a
Lakebase migration (per ``feedback_lakebase_branching_mandatory``).

Atomicity
---------
The handler runs inside the caller's open ``Session`` and never commits
on its own — the caller's ``_advance_tick`` commits once per tick. All
mutations (MV row, dependent RunArtifact rows) flow through that single
transaction. If we cannot atomically reach a consistent state (e.g. the
MV row's ``version`` doesn't match ``original_target`` — agent and App
disagree on the pre-allocated value), the handler fails the run via
``transition_run`` so we never produce a half-resolved state.
"""

from __future__ import annotations

import json
import logging
from typing import Optional, TYPE_CHECKING

from sqlmodel import Session, select

from .db_models import ModelVersion, Run, RunArtifact, RunOperation, RunProgressEvent

if TYPE_CHECKING:
    from .progress_tracker import ProgressEvent

logger = logging.getLogger(__name__)


# --- canonical contract constants ----------------------------------------

STAGE_NAME = "Version Resolution"
STEP_NAME = "Version Collision Auto-Resolved"

# result_json keys required for the parser to fire.
REQUIRED_KEYS = frozenset({"original_target", "new_target", "target_scope"})


def is_version_resolution_event(
    stage_name: str,
    step_name: str,
    result_json: Optional[dict],
) -> bool:
    """Return True iff the event matches the canonical contract.

    Both the primary predicate (stage + step) AND the hardening predicate
    (required result_json keys) must hold — a partial match is treated as a
    different event we don't yet understand and is ignored.
    """
    if stage_name != STAGE_NAME or step_name != STEP_NAME:
        return False
    if not isinstance(result_json, dict):
        return False
    return REQUIRED_KEYS.issubset(result_json.keys())


def _coerce_int(value) -> Optional[int]:
    """Parse ``1`` / ``"1"`` / ``"v1"`` → 1; otherwise None."""
    if value is None:
        return None
    if isinstance(value, bool):
        return None
    if isinstance(value, int):
        return value
    s = str(value).strip()
    if not s:
        return None
    if s[0] in ("v", "V"):
        s = s[1:]
    try:
        return int(s)
    except ValueError:
        return None


def apply_version_resolution(
    session: Session,
    run: Run,
    ev: "ProgressEvent",
) -> None:
    """Apply the agent's auto-resolved version decision to the run state.

    Called from ``_sync_orch_progress_events`` once per matching event.

    The freshly-added ``RunProgressEvent`` row carries the decision blob
    so ``lookup_resolved_version`` can consult it at observe-time even
    if the ``ModelVersion`` row hasn't been created yet (agent emits
    the event mid-run; observe creates the MV row on success). This
    helper additionally re-stamps any MV row that already exists for
    this run + scope at the pre-allocated value.

    Failure semantics: if the MV row exists but is on an unexpected
    version, fail the run via ``transition_run`` so the user sees a
    deterministic error rather than silent drift (per
    ``feedback_state_atomicity``).
    """
    rj = ev.result_json or {}
    original_target = _coerce_int(rj.get("original_target"))
    new_target = _coerce_int(rj.get("new_target"))
    target_scope = (rj.get("target_scope") or "").strip().lower()

    if original_target is None or new_target is None or not target_scope:
        logger.warning(
            "version_resolution: malformed result_json on run %s: %r",
            run.id, rj,
        )
        return

    if original_target == new_target:
        # No-op: agent emitted the event but didn't actually re-target.
        # Still persisted as a RunProgressEvent row for audit.
        return

    # Resolve the running op's scope. If the scope on the event doesn't
    # match the currently-running phase's scope, treat as no-op — events
    # are per-scope and the wrong scope's resolution shouldn't bleed into
    # a sibling phase.
    op_scope = _running_op_scope(session, run)
    if op_scope and op_scope != target_scope:
        logger.debug(
            "version_resolution: event target_scope=%r doesn't match "
            "running op scope=%r on run %s — skipping mv update",
            target_scope, op_scope, run.id,
        )
        return

    mv = _lookup_run_mv_for_scope(session, run, target_scope)
    if mv is None:
        # Common case: MV row not yet created (observe-time hasn't run).
        # The decision is durable on the RunProgressEvent row that was
        # added immediately before this call; observe_generation_op
        # will read it via lookup_resolved_version.
        logger.info(
            "version_resolution: run %s scope=%s deferred — MV row not "
            "yet created; agent target v%d→v%d will be applied at observe",
            run.id, target_scope, original_target, new_target,
        )
        return

    if mv.version != original_target:
        # The agent and App disagree on what was pre-allocated. Don't
        # half-update — fail the run with an explicit error.
        from .run_state_transitions import transition_run
        reason = (
            f"Version Resolution mismatch on scope={target_scope}: agent "
            f"reported original_target=v{original_target} but App "
            f"allocated v{mv.version}. Refusing to half-update; manual "
            f"investigation required."
        )
        logger.error("version_resolution: %s (run=%s)", reason, run.id)
        transition_run(session, run, target_status="failed", reason=reason)
        return

    # Atomic re-stamp inside the caller's open transaction.
    # Flat layout (pre-4.9.8): "..._{scope}_v{N}".
    old_segment_ecm = f"_ecm_v{original_target}"
    old_segment_mvm = f"_mvm_v{original_target}"
    new_segment_ecm = f"_ecm_v{new_target}"
    new_segment_mvm = f"_mvm_v{new_target}"
    # Nested layout (agent 4.9.8+): ".../v{N}/{scope}/...". The version lives
    # in a standalone ``v{N}`` segment; scope is a sibling. Only the target
    # scope's dir is re-stamped (that's the run's produced scope).
    old_nested = f"/v{original_target}/{target_scope}/"
    new_nested = f"/v{new_target}/{target_scope}/"

    mv.version = new_target
    session.add(mv)

    # Rewrite any RunArtifact rows whose file_path embeds the original
    # version segment for THIS run, in either the nested (agent 4.9.8+) or
    # legacy flat layout. We rewrite the matching-scope segment defensively (a
    # unified run may have indexed both ECM and MVM artifacts under this run,
    # but only the matching scope segment appears in any given path).
    artifacts = session.exec(
        select(RunArtifact).where(RunArtifact.run_id == run.id)
    ).all()
    for art in artifacts:
        new_path = art.file_path
        if old_nested in new_path:
            new_path = new_path.replace(old_nested, new_nested)
        if target_scope == "mvm" and old_segment_mvm in new_path:
            new_path = new_path.replace(old_segment_mvm, new_segment_mvm)
        elif target_scope == "ecm" and old_segment_ecm in new_path:
            new_path = new_path.replace(old_segment_ecm, new_segment_ecm)
        if new_path != art.file_path:
            art.file_path = new_path
            session.add(art)

    logger.info(
        "version_resolution: applied on run %s scope=%s v%d→v%d "
        "(mv=%s, %d artifacts rewritten)",
        run.id, target_scope, original_target, new_target, mv.id,
        sum(1 for a in artifacts if (
            new_nested in a.file_path
            or (target_scope == "mvm" and new_segment_mvm in a.file_path)
            or (target_scope == "ecm" and new_segment_ecm in a.file_path)
        )),
    )


def lookup_resolved_version(
    session: Session,
    run_id: str,
    target_scope: str,
) -> Optional[int]:
    """Return the agent-resolved version ordinal for ``run_id + scope``,
    or None if no Version Resolution event has been recorded.

    Consulted by ``observe_generation_op`` before falling back to
    ``next_version_for_scope``. This is the cross-layer unification:
    one source of truth (the RunProgressEvent blob) feeds both the
    in-flight MV re-stamp path and the observe-time allocation path.
    """
    if not run_id or not target_scope:
        return None
    scope = target_scope.strip().lower()
    rows = session.exec(
        select(RunProgressEvent)
        .where(RunProgressEvent.run_id == run_id)
        .where(RunProgressEvent.stage_name == STAGE_NAME)
        .where(RunProgressEvent.step_name == STEP_NAME)
        .order_by(RunProgressEvent.event_seq.desc())
    ).all()
    for r in rows:
        try:
            rj = json.loads(r.result_json or "{}")
        except (TypeError, ValueError):
            continue
        if (rj.get("target_scope") or "").strip().lower() != scope:
            continue
        new_target = _coerce_int(rj.get("new_target"))
        if new_target is not None:
            return new_target
    return None


# --- internals -----------------------------------------------------------


# Map of operation_name → short scope label. Mirrors the operations
# registry's ``scope_short`` argument to ``observe_generation_op``.
_OP_NAME_TO_SCOPE: dict[str, str] = {
    "generate_ecm": "ecm",
    "shrink_to_mvm": "mvm",
    "enlarge_to_ecm": "ecm",
    "vibe_iterate": "",  # scope depends on params; we read it from the MV
}


def _running_op_scope(session: Session, run: Run) -> str:
    """Best-effort: return the short scope of the currently-running op.

    Returns ``""`` when not derivable (e.g. vibe_iterate where the scope
    is parameterised). Callers treat ``""`` as "no constraint".
    """
    running = session.exec(
        select(RunOperation)
        .where(RunOperation.run_id == run.id)
        .where(RunOperation.status == "running")
        .order_by(RunOperation.step_index)
    ).first()
    if running is None:
        return ""
    return _OP_NAME_TO_SCOPE.get(running.operation_name, "")


def _lookup_run_mv_for_scope(
    session: Session,
    run: Run,
    target_scope: str,
) -> Optional[ModelVersion]:
    """Find the in-flight ModelVersion for this run + scope.

    The MV row is created at observe-time (see
    ``_generation_common._terminal_success``). When the agent's Version
    Resolution event fires before the App has reached observe (the
    typical case), no MV row exists yet and this returns None — the
    decision is then deferred to observe-time via
    :func:`lookup_resolved_version`.
    """
    # Prefer the running op's ``output_version_id`` (orchestrator-set on
    # success). Fall back to Run.version_id (legacy).
    running = session.exec(
        select(RunOperation)
        .where(RunOperation.run_id == run.id)
        .where(RunOperation.output_version_id != None)  # noqa: E711
    ).all()
    for op in running:
        mv = session.get(ModelVersion, op.output_version_id)
        if mv is not None and (mv.scope or "").lower() == target_scope:
            return mv
    if run.version_id:
        mv = session.get(ModelVersion, run.version_id)
        if mv is not None and (mv.scope or "").lower() == target_scope:
            return mv
    return None


__all__ = [
    "STAGE_NAME",
    "STEP_NAME",
    "REQUIRED_KEYS",
    "is_version_resolution_event",
    "apply_version_resolution",
    "lookup_resolved_version",
]
