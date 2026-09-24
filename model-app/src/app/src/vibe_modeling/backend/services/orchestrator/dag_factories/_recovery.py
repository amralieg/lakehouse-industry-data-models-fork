"""DAG factories for the recovery-flavoured intents.

Two intents land here per ``docs/orchestrator-design.md`` §3 + §8:

* ``revert`` — 2-op DAG (``uninstall`` of the currently-deployed version,
  then ``install`` of the prior version we're restoring).
* ``import-from-volume`` — 1-op DAG. The ``import_from_volume`` primitive
  is synthetic (no agent job) and does the full read → ModelVersion
  insert → Lakebase sync inline; the factory just hands it the volume
  path.

Factories are pure: they take a small request payload + the resolved
:class:`Business` + a context carrying agent-derived values, and return
a frozen :class:`Dag`. The wirer (route handler) owns DB writes and
calls :func:`validate_dag` before passing the DAG to
:meth:`Orchestrator.start`.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Optional

from ..dag import Dag, OperationStep


@dataclass(frozen=True, slots=True)
class RevertRequest:
    """Inputs the revert factory needs.

    The route resolves these from the current vs. target ModelVersion
    rows (current = the version being un-installed; target = the prior
    version being re-installed) and the agent config. Keeping them in a
    typed payload — rather than a free-form dict — means the factory
    signature is unambiguous and a missing field fails at construction
    rather than buried inside an ``OperationStep.params``.
    """

    business_name: str
    """The agent-side business slug — lowercased, snake_case."""

    deployment_catalog: str
    """UC catalog the install/uninstall ops target."""

    current_model_version: int
    """Integer version (e.g. 3) being uninstalled."""

    target_model_version: int
    """Integer version (e.g. 2) being re-installed."""

    scope: str = "mvm"
    """``ecm`` or ``mvm``. Must match how the version was originally
    installed; both ops in the DAG use the same scope."""

    schema_prefix: str = ""
    """Schema prefix applied at install time — used by both ops to
    locate / re-create the same schemas. ``""`` for Catalog-per-* styles
    where the per-scope catalog already isolates ECM from MVM."""

    cataloging_style: str = "One Catalog"
    """One of ``One Catalog`` / ``Catalog per Division`` / ``Catalog per
    Domain``. Drives how install lays out schemas; uninstall re-derives
    from this same value to find them."""

    target_import_source_path: Optional[str] = None
    """``ModelVersion.import_source_path`` of the version being re-installed.
    Set for imported and reference-seeded versions whose model.json lives
    somewhere other than the agent-output convention path. Threaded through
    to the install step's ``context_file_override``."""


@dataclass(frozen=True, slots=True)
class ImportFromVolumeRequest:
    """Inputs the import-from-volume factory needs.

    The primitive resolves ``business_name`` / ``deployment_catalog``
    from :class:`OperationContext` when omitted (spec §2 — the context
    is the source of truth for org config). The factory only needs the
    volume path.
    """

    volume_path: str
    """Absolute UC Volume path ending in ``model.json``. Validated by
    the primitive's ``params_model``."""

    deployment_catalog: str = ""
    """Optional override; primitive resolves from inherited_params /
    business when blank."""

    business_name: str = ""
    """Optional override; primitive resolves from
    :attr:`OperationContext.business_id` when blank."""


def dag_for_revert(req: RevertRequest) -> Dag:
    """Build the 2-op revert DAG.

    Step 0: ``uninstall`` of the currently-deployed version. Strips the
    UC schemas the install laid down so the install on step 1 can lay
    them down freshly without colliding (especially in One Catalog mode
    where ECM and MVM share a catalog and only the schema prefix
    distinguishes them).

    Step 1: ``install`` of the prior version. Re-creates the same
    catalog/schema shape against the saved model.json for the target
    version. ``model_version`` here is the integer version being
    restored — the orchestrator does not pull it from a prior step
    because no prior step produced the version (the version exists
    already; we're re-deploying it).

    Per spec §3, the DAG carries no inter-step ``needs_version_from``:
    both ops operate on existing versions whose ids the route already
    knows. The :class:`Dag` is linear and the orchestrator runs the
    install only after the uninstall succeeds.
    """
    return Dag(
        intent="revert",
        steps=(
            OperationStep(
                name="uninstall",
                params={
                    "business_name": req.business_name,
                    "deployment_catalog": req.deployment_catalog,
                    "scope": req.scope,
                    "model_version": req.current_model_version,
                    "schema_prefix": req.schema_prefix,
                    "cataloging_style": req.cataloging_style,
                },
            ),
            OperationStep(
                name="install",
                params={
                    "business_name": req.business_name,
                    "deployment_catalog": req.deployment_catalog,
                    "scope": req.scope,
                    "model_version": req.target_model_version,
                    "schema_prefix": req.schema_prefix,
                    "cataloging_style": req.cataloging_style,
                    # Imported / reference-seeded versions live outside the
                    # agent-output convention path — route the actual
                    # model.json location to the install widget builder.
                    "context_file_override": req.target_import_source_path,
                },
                # Version is known up-front — not produced by step 0.
                needs_version_from=None,
            ),
        ),
    )


def dag_for_import_from_volume(req: ImportFromVolumeRequest) -> Dag:
    """Build the 1-op import-from-volume DAG.

    The ``import_from_volume`` primitive is synthetic and runs entirely
    inside ``dispatch`` — it reads the model.json off the Volume,
    inserts a fresh :class:`ModelVersion`, and syncs Lakebase. The
    factory hands it the volume path; the primitive's ``params_model``
    enforces the ``/Volumes/`` path-shape gate (spec §2.4 — field-level
    rules live with the primitive).
    """
    params: dict = {
        "volume_path": req.volume_path,
    }
    # Optional fields — only populate when set so the primitive's
    # context-resolution path stays the default.
    if req.deployment_catalog:
        params["deployment_catalog"] = req.deployment_catalog
    if req.business_name:
        params["business_name"] = req.business_name

    return Dag(
        intent="import-from-volume",
        steps=(
            OperationStep(
                name="import_from_volume",
                params=params,
            ),
        ),
    )
