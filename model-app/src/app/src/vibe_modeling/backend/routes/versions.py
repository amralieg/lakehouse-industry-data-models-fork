"""Model-version read-side endpoints (`/api/businesses/.../versions/...`,
`/api/model-versions/...`).

Covers listing versions, the next-vibes inspection surface, the
delete-version flow (with optional reinstall-previous), manual sync / resync
into Lakebase, the admin-recovery `import-from-volume` endpoint, and the
per-version artifact listing the UI surfaces on the model-version page.
Anything that operates on a single ModelVersion row but is NOT a
`/runs/...` endpoint lives here.

Per-version artifact endpoints nest under
`/businesses/{business_id}/model-versions/{model_version_id}/artifacts...`
so the business id in the URL gates tenancy the same way it does for the
per-run sibling endpoints — see :func:`get_model_version_in_business`.
"""

from __future__ import annotations

import json
import logging
import time
from datetime import datetime, timezone
from typing import Literal, Optional

from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import StreamingResponse
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlmodel import select

from ..._metadata import api_prefix
from .._artifact_io import (
    build_artifact_content_response,
    build_artifact_download_response,
    build_artifacts_zip_bytes,
)
from .._query_helpers import (
    next_version_for_scope,
    resolve_model_version,
)
from ..agent_compat import (
    SUPPORTED_TAGS,
    classify_tag,
    describe_incompatibility,
    detect_tag_from_model_json,
    latest_supported_tag,
)
from ..core import Dependencies, resolve_version_volume_catalog
from ..core._names import agent_business_segment
from ..db_models import (
    Business,
    Domain,
    ModelVersion,
    Run,
    RunArtifact,
    RunOperation,
)
from ..job_launcher import (
    generate_session_id,
    launch_run,
    session_id_to_bigint,
)
from ..model_export import (
    bundle_layout,
    build_bundle_zip_bytes,
    export_model_json,
    resolve_bundle_root,
)
from ..model_sync import ModelSyncService, _SyncEmptyError, _version_root_in_volume
from ..models import (
    DeleteVersionOut,
    InstallationStatusOut,
    ModelVersionOut,
    NextVibesOut,
    ReconcileInstallationOut,
    RunArtifactOut,
)
from ..services.orchestrator.dag_factories import (
    dag_for_import_from_volume,
    dag_for_revert,
)
from ..services.orchestrator.dag_factories._recovery import (
    ImportFromVolumeRequest,
    RevertRequest,
)
from ..services.orchestrator.validate import validate_dag
from ..services import operations as _operations_pkg
from ._helpers import (
    _get_agent_config,
    _next_vibes_from_inputs,
    _offending_relation,
    delete_model_version,
    require_config,
    resolve_warehouse_id,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix=api_prefix)


def get_model_version_in_business(
    session, business_id: str, model_version_id: str
) -> ModelVersion:
    """Load a ``ModelVersion`` by id and assert it belongs to ``business_id``.

    Raises ``HTTPException(404, "ModelVersion not found")`` when:
      * no row exists for ``model_version_id``, or
      * the row exists but its ``business_id`` does not match.

    Both cases collapse to 404 (not 403) so the API does not leak the
    existence of model versions across businesses — a caller probing
    ``/businesses/{wrong}/model-versions/{mvid}/...`` should see the
    same response as if ``mvid`` did not exist at all. Mirrors
    :func:`router.get_run_in_business` for the per-run surface.
    """
    mv = session.get(ModelVersion, model_version_id)
    if not mv or mv.business_id != business_id:
        raise HTTPException(status_code=404, detail="ModelVersion not found")
    return mv


# --- Model Versions ---


@router.get(
    "/businesses/{business_id}/versions",
    response_model=list[ModelVersionOut],
    operation_id="listVersions",
)
def list_versions(business_id: str, session: Dependencies.Session):
    versions = session.exec(
        select(ModelVersion)
        .where(ModelVersion.business_id == business_id)
        .order_by(ModelVersion.version.desc())
    ).all()
    return versions


@router.get(
    "/model-versions/{model_version_id}/next-vibes",
    response_model=NextVibesOut,
    operation_id="getNextVibes",
)
def get_next_vibes(model_version_id: str, session: Dependencies.Session):
    """Return agent-proposed follow-up operations for a model version.

    Items are read from the structured ``VibeInput(origin=agent_next_vibe)``
    rows the sync-time materializer creates (the same rows the Model Evolution
    Metrics count) — ALL findings (static-analysis, priority-remediation, and
    other) surface as cards. Returns an empty list when the version has no
    captured next-vibes — callers should hide the UI section in that case
    rather than rendering an empty card.
    """
    mv = session.get(ModelVersion, model_version_id)
    if not mv:
        raise HTTPException(status_code=404, detail="Model version not found")

    return _next_vibes_from_inputs(session, model_version_id)


@router.delete(
    "/businesses/{business_id}/versions/{version_id}",
    response_model=DeleteVersionOut,
    operation_id="deleteVersion",
)
def delete_version(
    business_id: str,
    version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    tracker: Dependencies.Tracker,
    _role: Dependencies.BusinessAdminOnly,
    reinstall_previous: bool = False,
):
    """Delete the latest version of its scope.

    Always: drops the ``ModelVersion`` row and its Lakebase cascade
    (``Domain`` → ``Product`` → ``Attribute``, ``ForeignKeyLink``,
    ``DiagramLayout``, ``RunArtifact``) plus the agent's
    ``_metamodel.{business,domain,product,attribute}`` rows when present.

    Optional: when ``reinstall_previous=true`` and a same-scope prior
    version exists with a matching catalog, dispatch the legacy
    uninstall → install orchestrator DAG to revive that previous version.
    """
    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")

    version = session.get(ModelVersion, version_id)
    if not version or version.business_id != business_id:
        raise HTTPException(status_code=404, detail="Version not found")

    # "Latest in its scope" is the bar — not "latest across both scopes".
    # The agent's version counter is per-scope (v1_ecm + v1_mvm can
    # coexist), so the previous gate that ordered ALL versions by
    # ``version desc`` would mark an ECM v2 row as non-latest just
    # because an MVM v3 also existed.
    current_scope = (version.scope or "").lower()
    same_scope_versions = session.exec(
        select(ModelVersion)
        .where(
            ModelVersion.business_id == business_id,
            ModelVersion.scope == version.scope,
            ModelVersion.status == "completed",
        )
        .order_by(ModelVersion.version.desc())
    ).all()
    if not same_scope_versions or same_scope_versions[0].id != version_id:
        raise HTTPException(
            status_code=400,
            detail="Can only delete the latest version in its scope",
        )

    prev_version = same_scope_versions[1] if len(same_scope_versions) >= 2 else None
    catalog = version.uc_catalog
    name = agent_business_segment(business.name)

    if reinstall_previous:
        if prev_version is None:
            raise HTTPException(
                status_code=400,
                detail="No previous version to reinstall",
            )
        if not catalog:
            raise HTTPException(
                status_code=400,
                detail="Version was never installed — nothing to reinstall over",
            )

    # --- Always-delete part --------------------------------------------------

    # Drop the agent's _metamodel.* rows for this version, if present.
    # Skipped silently for versions that were never written there
    # (import-only versions) — there's nothing to clean up.
    metamodel_deleted = False
    if catalog:
        sync = ModelSyncService(
            session, ws, warehouse_id=resolve_warehouse_id(session, config)
        )
        try:
            metamodel_deleted = sync.delete_metamodel_rows(
                catalog=catalog,
                business_name=name,
                version=str(version.version),
                model_scope=current_scope,
            )
        except Exception:
            logger.exception(
                "delete_version: failed to clean _metamodel.* rows for %s v%s (%s);"
                " Lakebase rows still deleted",
                name, version.version, current_scope,
            )

    deleted_version_number = version.version

    # Wrap the Lakebase cascade + its commit: the test workspace FKs lack ON DELETE
    # CASCADE, so a missed child (or a surviving inbound pointer) surfaces
    # as an IntegrityError on commit. Convert it to a clean 409 instead of
    # letting the bare DB error become a sanitized 500. Single transaction —
    # rollback leaves no partial delete behind.
    try:
        delete_model_version(session, version)

        # Drop the explorer cache so a subsequent fetch reads the post-delete state.
        from ..explorer import invalidate_model_cache
        invalidate_model_cache(business_id, deleted_version_number)

        # Commit the delete (for the reinstall path this also lets the
        # orchestrator dispatch see a clean state — the install primitive
        # cares about which versions exist).
        session.commit()
    except IntegrityError as exc:
        session.rollback()
        rel = _offending_relation(exc)
        raise HTTPException(
            status_code=409,
            detail=(
                "Could not delete version: it still has dependent records"
                + (f" ({rel})" if rel else "")
            ),
        )
    except SQLAlchemyError:
        session.rollback()
        raise HTTPException(
            status_code=409,
            detail="Could not delete version due to a database error",
        )

    if not reinstall_previous:
        return DeleteVersionOut(
            deleted_version=deleted_version_number,
            previous_version=prev_version.version if prev_version else None,
            run_id=None,
            reinstall_dispatched=False,
            metamodel_rows_cleaned=metamodel_deleted,
            message=f"Deleted version {deleted_version_number}",
        )

    # --- Optional reinstall --------------------------------------------------

    _get_agent_config(session)
    scope = current_scope if current_scope in ("ecm", "mvm") else "mvm"
    cataloging_style = "One Catalog"
    schema_prefix = f"{scope}_"

    revert_req = RevertRequest(
        business_name=name,
        deployment_catalog=catalog,
        current_model_version=deleted_version_number,
        target_model_version=prev_version.version,
        scope=scope,
        schema_prefix=schema_prefix,
        cataloging_style=cataloging_style,
        target_import_source_path=prev_version.import_source_path,
    )
    dag = dag_for_revert(revert_req)
    validation = validate_dag(dag, registry_get=_operations_pkg.get)
    if validation.blockers:
        raise HTTPException(
            status_code=400,
            detail={
                "error": "invalid reinstall DAG",
                "blockers": [
                    {
                        "field_path": iss.field_path,
                        "step_index": iss.step_index,
                        "message": iss.message,
                    }
                    for iss in validation.blockers
                ],
            },
        )

    sid = generate_session_id()
    sid_bigint = session_id_to_bigint(sid)
    run = Run(
        business_id=business_id,
        version_id=prev_version.id,
        # ``dag_for_revert`` is the underlying DAG (uninstall → install
        # of the prior version), so the persisted intent stays ``revert``
        # to match what the orchestrator later writes from ``dag.intent``.
        # The "reinstall" framing is a UX detail at the delete-dialog
        # level, not a separate orchestrator intent.
        intent="revert",
        status="pending",
        vibe_session_id=sid,
        vibe_session_id_bigint=sid_bigint,
        parameters_json=json.dumps({
            "deployment_catalog": catalog,
            "business_name": name,
            "deleted_version": deleted_version_number,
            "version_to_restore": prev_version.version,
        }),
        progress_message=f"Re-installing version {prev_version.version}...",
    )
    session.add(run)
    session.commit()
    session.refresh(run)

    try:
        tracker.orchestrator.start(run, dag, session)
        session.commit()
        session.refresh(run)
    except Exception as e:
        from ..run_state_transitions import transition_run
        reason = f"Failed to start reinstall orchestrator: {e}"
        run.error_message = reason
        session.add(run)
        transition_run(session, run, target_status="failed", reason=reason)
        session.commit()
        session.refresh(run)

    if run.status in ("running", "pending"):
        tracker.start_tracking(run.id)

    return DeleteVersionOut(
        deleted_version=deleted_version_number,
        previous_version=prev_version.version,
        run_id=run.id,
        reinstall_dispatched=True,
        metamodel_rows_cleaned=metamodel_deleted,
        message=(
            f"Deleted version {deleted_version_number}; "
            f"re-installing version {prev_version.version}..."
        ),
    )


# --- Per-version artifact listing (read-side, distinct from runs/.../artifacts) ---


@router.get(
    "/businesses/{business_id}/model-versions/{model_version_id}/artifacts",
    response_model=list[RunArtifactOut],
    operation_id="listArtifactsByVersion",
)
def list_artifacts_by_version(
    business_id: str,
    model_version_id: str,
    session: Dependencies.Session,
):
    """Artifacts the agent wrote for this model version.

    Unlike `/runs/{run_id}/artifacts` — which returns every file a run
    produced across *all* versions (the unified pipeline emits two) —
    this endpoint is scoped to the version the user is viewing, so the
    UI can surface artifacts on the model version page without mixing
    ECM and MVM outputs.
    """
    get_model_version_in_business(session, business_id, model_version_id)
    artifacts = session.exec(
        select(RunArtifact)
        .where(RunArtifact.model_version_id == model_version_id)
        .order_by(RunArtifact.created_at.desc())
    ).all()
    return artifacts


@router.get(
    "/businesses/{business_id}/model-versions/{model_version_id}/artifacts/download",
    operation_id="downloadAllArtifactsByVersion",
)
def download_all_artifacts_by_version(
    business_id: str,
    model_version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Stream a zip of every artifact indexed for this model version."""
    get_model_version_in_business(session, business_id, model_version_id)
    artifacts = session.exec(
        select(RunArtifact)
        .where(RunArtifact.model_version_id == model_version_id)
        .order_by(RunArtifact.created_at.desc())
    ).all()
    if not artifacts:
        raise HTTPException(status_code=404, detail="No artifacts to download")

    body = build_artifacts_zip_bytes(ws, artifacts)
    filename = f"model-version-{model_version_id[:8]}-artifacts.zip"
    return StreamingResponse(
        iter([body]),
        media_type="application/zip",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


# --- Model export (inverse of import) --------------------------------------
#
# Reconstruct a ``model.json`` from a version's Lakebase rows so a model /
# industry version can later be published to GitHub. Read-only: no mutation.
# The serializer lives in ``model_export`` (mirrors ``sync_from_model_json``'s
# field map); the bundle layout (``<industry>/<scope>_vN/``) is a single
# code-level descriptor there.


@router.get(
    "/businesses/{business_id}/model-versions/{model_version_id}/export",
    response_model=dict,
    operation_id="exportModelJson",
)
def export_model_version_json(
    business_id: str,
    model_version_id: str,
    session: Dependencies.Session,
):
    """Reconstruct the ``model.json`` for a version from its Lakebase rows.

    The inverse of import: returns the agent-envelope ``model.json`` shape
    (``{"model": {...}}``) the import flow accepts, so the version round-trips.
    """
    get_model_version_in_business(session, business_id, model_version_id)
    return export_model_json(session, model_version_id)


@router.get(
    "/businesses/{business_id}/model-versions/{model_version_id}/export/bundle",
    operation_id="exportModelBundle",
)
def export_model_version_bundle(
    business_id: str,
    model_version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Stream a zip bundle (``<industry>/<scope>_vN/model.json`` + companion
    artifacts) for a version — the publishable inverse-of-import layout."""
    mv = get_model_version_in_business(session, business_id, model_version_id)
    business = session.get(Business, business_id)
    root = resolve_bundle_root(
        override=None, business=business, scope=mv.scope or "", version=mv.version
    )
    model_json = export_model_json(session, model_version_id)
    layout = bundle_layout(
        mv.scope or "", mv.scope or "", mv.version, dir_override=root
    )

    artifacts = session.exec(
        select(RunArtifact)
        .where(RunArtifact.model_version_id == model_version_id)
        .order_by(RunArtifact.created_at.desc())
    ).all()

    body = build_bundle_zip_bytes(ws, layout, model_json, artifacts)
    filename = f"{layout.industry}-{layout.scope}-v{layout.version}-bundle.zip"
    return StreamingResponse(
        iter([body]),
        media_type="application/zip",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


# Per-version, per-artifact preview + download.
#
# These mirror the run-scoped endpoints in router.py (``/runs/.../artifacts/
# {artifact_id}/{content,download}``) but key on ``model_version_id`` instead
# of ``run_id``. The import-from-Volume path writes RunArtifact rows with
# ``run_id=NULL`` (since v_0_5_0; imports are syncs, not runs), so the
# run-scoped endpoints can't surface preview/download for imported artifacts.
# Both surfaces share the helpers in ``_artifact_io`` so behaviour stays
# identical between run-produced and import-produced rows.


@router.get(
    "/businesses/{business_id}/model-versions/{model_version_id}/artifacts/{artifact_id}/content",
    response_model=dict,
    operation_id="getArtifactContentByVersion",
)
def get_artifact_content_by_version(
    business_id: str,
    model_version_id: str,
    artifact_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    content_format: Literal["text", "hex"] = Query(
        "text",
        alias="format",
        description='Use "text" for UTF-8 text bodies, "hex" for a short hex dump of any file.',
    ),
):
    """Read artifact bytes from its Volume path. See :func:`build_artifact_content_response`."""
    get_model_version_in_business(session, business_id, model_version_id)
    artifact = session.exec(
        select(RunArtifact).where(
            RunArtifact.id == artifact_id,
            RunArtifact.model_version_id == model_version_id,
        )
    ).first()
    if not artifact:
        raise HTTPException(status_code=404, detail="Artifact not found")
    return build_artifact_content_response(ws, artifact, content_format)


@router.get(
    "/businesses/{business_id}/model-versions/{model_version_id}/artifacts/{artifact_id}/download",
    operation_id="downloadArtifactByVersion",
)
def download_artifact_by_version(
    business_id: str,
    model_version_id: str,
    artifact_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    inline: bool = Query(
        False,
        description="If true, use Content-Disposition: inline and a browser-friendly Content-Type (PDF, images) for embedding in the UI.",
    ),
):
    """Stream a single artifact's raw bytes as a file download (or inline preview)."""
    get_model_version_in_business(session, business_id, model_version_id)
    artifact = session.exec(
        select(RunArtifact).where(
            RunArtifact.id == artifact_id,
            RunArtifact.model_version_id == model_version_id,
        )
    ).first()
    if not artifact:
        raise HTTPException(status_code=404, detail="Artifact not found")
    return build_artifact_download_response(ws, artifact, inline=inline)


# --- Manual model sync ---


@router.post(
    "/businesses/{business_id}/versions/{version_id}/sync",
    response_model=dict,
    operation_id="syncModelVersion",
)
def sync_model_version(
    business_id: str,
    version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.BusinessAdminOnly,
):
    """Manually trigger model sync into Lakebase for a version.

    Tries model.json from Volumes first, falls back to the Delta metamodel tables.
    """

    mv = session.get(ModelVersion, version_id)
    if not mv or mv.business_id != business_id:
        raise HTTPException(status_code=404, detail="Version not found")

    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")

    bname = agent_business_segment(business.name)
    vstr = f"v{mv.version}"

    # Per-version Volume catalog: the producing run's uc_catalog when known,
    # else the installation metamodel catalog. Passing bare mv.uc_catalog here
    # (the prior behavior) made sync a silent no-op for drafts whose uc_catalog
    # is "" - the kickstart-class bug this resolver fixes.
    catalog = resolve_version_volume_catalog(mv, session, config)
    sync = ModelSyncService(session, ws, resolve_warehouse_id(session, config))
    try:
        success = sync.sync_model(version_id, catalog, bname, vstr)
    except _SyncEmptyError:
        # G2: a 0-domain artifact was found — the post-sync gate raised.
        # sync_from_model_json cleared the version's rows before writing 0,
        # so roll back the uncommitted teardown to avoid data loss, then
        # return the same 404 as the G1 (no-data) case for consistency.
        session.rollback()
        raise HTTPException(
            status_code=404,
            detail="Model output is empty (0 domains) — nothing to sync",
        )
    if not success:
        raise HTTPException(status_code=404, detail="No model data found in Delta tables or Volumes")

    session.commit()
    return {"ok": True, "message": f"Synced model data for version {mv.version}"}


@router.post(
    "/businesses/{business_id}/versions/{version_id}/resync",
    response_model=dict,
    operation_id="forceResyncVersion",
)
def force_resync_version(
    business_id: str,
    version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.BusinessAdminOnly,
):
    """Force re-sync a model version (model.json primary, Delta fallback), clearing existing data first."""

    # Resync reads Delta/Volume via the warehouse; hard-fail with an actionable
    # 422 before doing work when it is unset (the metamodel-catalog case is
    # handled version-specifically below via resolve_version_volume_catalog).
    require_config(session, config, ["warehouse"], mode="raise")

    mv = session.get(ModelVersion, version_id)
    if not mv or mv.business_id != business_id:
        raise HTTPException(status_code=404, detail="Version not found")

    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")

    bname = agent_business_segment(business.name)
    vstr = f"v{mv.version}"
    # Per-version Volume catalog (the promoted canonical rule): mv.uc_catalog,
    # else the installation metamodel catalog.
    catalog = resolve_version_volume_catalog(mv, session, config)
    if not catalog:
        # No per-version catalog AND no installation metamodel catalog: this is
        # the config-missing case. Emit the structured 422 config_missing
        # (before any destructive teardown - never start a clear we can't
        # finish) rather than a bare 400.
        require_config(session, config, ["metamodel_catalog"], mode="raise")
        raise HTTPException(status_code=400, detail="No catalog configured for this version")

    sync = ModelSyncService(session, ws, resolve_warehouse_id(session, config))
    mv_scope = mv.scope or ""
    mv_version = mv.version

    # Close the preflight read transaction (mv/business/catalog/warehouse
    # lookups above) BEFORE the Volume/warehouse read below. Leaving it open
    # across that read means the network round-trip + JSON parse sits inside
    # an idle-open Postgres transaction for its whole duration — the same
    # read-then-release discipline applied to the seed/artifact-copy paths
    # elsewhere in this codebase. Nothing has been written yet, so this is a
    # no-op commit, purely to release the connection.
    session.commit()

    volume_started = time.monotonic()
    # Pass model_scope so the next_vibes loader looks in the right
    # ``v{N}/{scope}`` Volume folder instead of falling back to the
    # scopeless ``v{N}`` layout (which has no next_vibes artifact).
    model_data, next_vibes_payload, next_vibes_path = sync.load_resync_sources(
        catalog, bname, vstr, mv_scope
    )
    volume_elapsed = time.monotonic() - volume_started
    logger.info(
        "[resync] version=%s model.json/next-vibes Volume+warehouse read took %.2fs",
        version_id, volume_elapsed,
    )
    if not model_data:
        raise HTTPException(status_code=404, detail="No model data found in Delta tables or Volumes")

    # Write phase: teardown + rebuild + next-vibes capture, all with the
    # payloads already in hand — no further Volume/warehouse I/O below, so
    # this transaction is never idle waiting on a network read.
    write_started = time.monotonic()
    sync.clear_version_data(version_id)
    try:
        sync.sync_model(
            version_id, catalog, bname, vstr, model_scope=mv_scope,
            preloaded_model_data=model_data,
            next_vibes_preload=(next_vibes_payload, next_vibes_path),
        )
    except _SyncEmptyError:
        # G2: load_resync_sources returned a non-empty dict that parsed to 0
        # domains, so the post-sync gate raised. clear_version_data already
        # ran but nothing is committed — roll it back so the version keeps its
        # existing rows (no data loss), then return the same 404 as the G1
        # no-data case above rather than a 500.
        session.rollback()
        raise HTTPException(
            status_code=404,
            detail="Model output is empty (0 domains) — nothing to sync",
        )
    # A successful resync repairs the model, so clear any stale failure state
    # (incomplete_metadata / finalize_failed) — nothing else resets it, so the
    # warning banner would otherwise persist forever on a recovered version.
    mv_row = session.get(ModelVersion, version_id)
    if mv_row is not None and mv_row.sync_state != "ok":
        mv_row.sync_state = "ok"
        mv_row.sync_error_text = None
        session.add(mv_row)
    session.commit()
    write_elapsed = time.monotonic() - write_started
    logger.info(
        "[resync] version=%s DB write phase (clear+rebuild+capture) took %.2fs",
        version_id, write_elapsed,
    )

    # Drop the in-memory explorer cache so the next `/versions/{N}/model`
    # call reads the freshly-synced Lakebase state. Without this, resync
    # looks like a no-op from the UI for the lifetime of the process.
    from ..explorer import invalidate_model_cache
    invalidate_model_cache(business_id, mv_version)
    return {"ok": True, "message": f"Re-synced model data for version {mv_version}"}


@router.post(
    "/businesses/{business_id}/versions/import-from-volume",
    response_model=dict,
    operation_id="importVersionFromVolume",
)
def import_version_from_volume(
    business_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    tracker: Dependencies.Tracker,
    _role: Dependencies.AdminOnly,
    volume_path: str,
    new_version_number: Optional[int] = None,
    scope: str = "mvm",
    catalog: Optional[str] = None,
    base_version_id: Optional[str] = None,
    vibe_instructions: str = "",
):
    """Admin recovery: create a new ModelVersion on `business_id` populated
    from a model.json at `volume_path` (e.g.
    `/Volumes/vibe_model_test/_metamodel/vol_root/business/test_ecommerce/v3_mvm/model.json`).

    Useful when a vibe run produced a valid model in the Volume but the
    subsequent sync / job termination failed, leaving Lakebase without a
    corresponding ModelVersion row. Avoids re-running the pipeline.

    Phase 4 (Group B — recovery runs): the core read → ModelVersion
    insert → Lakebase sync now runs through the
    :class:`Orchestrator` (1-op DAG with the ``import_from_volume``
    primitive). The route still owns the surrounding admin features
    (agent-compat verdict, Delta write for cross-store consistency)
    since those are not part of the primitive's contract.

    - `new_version_number`: if omitted, uses max(existing version) + 1.
    """
    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")

    # Defence-in-depth: admin is already trusted, but a bad typo or a
    # copy-paste of an unrelated path shouldn't silently import into the
    # wrong business. Enforce a path shape that matches the agent's Volume
    # convention: must be an absolute UC Volume path ending in model.json,
    # and must not contain `..` traversal segments. The primitive's
    # ``params_model`` enforces a subset of these (``/Volumes/`` prefix +
    # no ``..`` segments); the route adds the ``model.json`` suffix gate.
    if (
        not volume_path.startswith("/Volumes/")
        or not volume_path.endswith("/model.json")
        or ".." in volume_path.split("/")
    ):
        raise HTTPException(
            status_code=422,
            detail=(
                "volume_path must be an absolute UC Volume path ending in "
                "/model.json (e.g. /Volumes/<catalog>/_metamodel/vol_root/"
                "business/<name>/v<N>_<scope>/model.json) with no `..` segments."
            ),
        )

    # Load model.json once for the agent-compat pre-check + the Delta
    # mirror later. The primitive will re-read inside dispatch — these
    # two reads see the same Volume snapshot in practice; the recovery
    # path is rare and not in any hot loop.
    try:
        resp = ws.files.download(volume_path)
        raw = resp.contents.read()
        doc = json.loads(raw)
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Could not read {volume_path}: {e}")

    # Accept either a flat model.json (domains at top level) or the
    # nested `{model: {...}}` wrapper that the current agent writes.
    model_payload = doc.get("model") if isinstance(doc, dict) and "model" in doc else doc
    if not isinstance(model_payload, dict) or "domains" not in model_payload:
        raise HTTPException(
            status_code=422,
            detail="model.json is missing a `domains` array (neither at top level nor under `model`).",
        )

    from ..core._defaults import SUPPORTED_AGENT_VERSION
    detected_tag = detect_tag_from_model_json(doc, fallback=SUPPORTED_AGENT_VERSION)
    verdict = classify_tag(detected_tag)
    if verdict in ("breaking", "unknown"):
        raise HTTPException(
            status_code=422,
            detail={
                "error": "incompatible_agent_tag",
                "detected_agent_tag": detected_tag,
                "compat_verdict": verdict,
                "latest_supported_tag": latest_supported_tag(),
                "supported_tags": sorted(SUPPORTED_TAGS),
                "message": describe_incompatibility(detected_tag, verdict),
            },
        )
    if verdict == "needs-adapter":
        logger.warning(
            "import_version_from_volume: tag %r classified as needs-adapter; "
            "proceeding without a shim (no adapter registered).",
            detected_tag,
        )

    # Resolve the new version number for the conflict pre-check. The
    # primitive will allocate ``next_version_for_scope`` itself (per the
    # post-refactor natural key (business, version, scope)), so when a
    # caller supplies an explicit number that doesn't match, we reject
    # early. The path's `scope` (default "mvm") is the scope the import
    # will land into; siblings in the OTHER scope don't influence the
    # ordinal.
    auto_new_version = next_version_for_scope(session, business_id, scope)
    if new_version_number is not None and new_version_number != auto_new_version:
        raise HTTPException(
            status_code=400,
            detail=(
                f"new_version_number={new_version_number} does not match the "
                f"next available number ({auto_new_version}) for scope={scope!r}. "
                f"The orchestrator-driven import allocates per-scope; remove the "
                f"override or set it to {auto_new_version}."
            ),
        )
    new_version_number = auto_new_version

    # Conflict if that (version, scope) somehow already exists (race
    # between the latest-lookup and the primitive's insert).
    existing = resolve_model_version(
        session, business_id, new_version_number, scope,
    )
    if existing:
        raise HTTPException(
            status_code=409,
            detail=(
                f"ModelVersion v{new_version_number} (scope={scope!r}) already "
                f"exists for this business."
            ),
        )

    # Resolve catalog — default to whatever the latest version (in any
    # scope) used. The latest row is the best signal of the catalog the
    # business is currently deployed into.
    if not catalog:
        latest_any = session.exec(
            select(ModelVersion)
            .where(ModelVersion.business_id == business_id)
            .order_by(ModelVersion.version.desc())
        ).first()
        catalog = None
        if latest_any:
            catalog = latest_any.uc_catalog or None

    # Build + validate the 1-op DAG.
    biz_name_slug = agent_business_segment(business.name)
    import_req = ImportFromVolumeRequest(
        volume_path=volume_path,
        deployment_catalog=catalog or "",
        business_name=biz_name_slug,
    )
    dag = dag_for_import_from_volume(import_req)
    validation = validate_dag(dag, registry_get=_operations_pkg.get)
    if validation.blockers:
        raise HTTPException(
            status_code=400,
            detail={
                "error": "invalid import-from-volume DAG",
                "blockers": [
                    {
                        "field_path": iss.field_path,
                        "step_index": iss.step_index,
                        "message": iss.message,
                    }
                    for iss in validation.blockers
                ],
            },
        )

    # Synthesize the Run row. The primitive is synchronous (does the
    # whole import in dispatch), so we drive start + advance inline and
    # return only after the version exists. ``parameters_json`` carries
    # the volume_path / scope / source markers the legacy admin endpoint
    # set — keeps the run history readable.
    now = datetime.now(timezone.utc)
    synthetic_run = Run(
        business_id=business_id,
        intent="import-from-volume",
        status="pending",
        progress_message="Importing from Volume",
        parameters_json=json.dumps({
            "volume_path": volume_path,
            "scope": scope,
            "source": "import_from_volume",
            "deployment_catalog": catalog or "",
        }),
        started_at=now,
    )
    session.add(synthetic_run)
    session.commit()
    session.refresh(synthetic_run)

    try:
        tracker.orchestrator.start(synthetic_run, dag, session)
        # The primitive runs entirely inside dispatch; one advance tick
        # observes its terminal-success and stamps run.version_id +
        # status="completed".
        tracker.orchestrator.advance(synthetic_run, session)
        session.commit()
        session.refresh(synthetic_run)
    except Exception as e:
        # Wiring audit (versions.py import orchestrator failure):
        #   Previous: direct synthetic_run.status write.
        #   New: transition_run stamps all five layers atomically.
        from ..run_state_transitions import transition_run
        reason = f"Import orchestrator failed: {e}"
        synthetic_run.error_message = reason
        session.add(synthetic_run)
        transition_run(session, synthetic_run, target_status="failed", reason=reason)
        session.commit()
        raise HTTPException(
            status_code=500,
            detail=f"Import failed: {synthetic_run.error_message}",
        )

    if synthetic_run.status != "completed" or not synthetic_run.version_id:
        # Primitive reported a soft failure (file-read / parse / schema
        # errors are surfaced as terminal-failed observations).
        raise HTTPException(
            status_code=502,
            detail=f"Import did not complete: {synthetic_run.error_message or 'unknown error'}",
        )

    mv = session.get(ModelVersion, synthetic_run.version_id)
    if mv is None:  # defensive — version_id pointed somewhere stale
        raise HTTPException(
            status_code=500,
            detail="Import completed but ModelVersion is missing",
        )

    # Post-process: the primitive lays down the bare ModelVersion +
    # Lakebase rows. The route still owns the catalog/scope rewrite +
    # supersession + Delta mirror — features that aren't part of the
    # primitive's contract but the legacy admin endpoint shipped.
    if catalog:
        mv.uc_catalog = catalog
        mv.deployment_status = "deployed"
    if scope and not mv.scope:
        mv.scope = scope
    if base_version_id:
        mv.base_version_id = base_version_id
    if vibe_instructions:
        mv.vibe_instructions = vibe_instructions
    session.add(mv)

    if mv.deployment_status == "deployed":
        from ..progress_tracker import _supersede_deployed_siblings
        _supersede_deployed_siblings(session, mv)

    # Drop the explorer cache for this version so a subsequent model fetch
    # reads fresh data rather than a pre-import snapshot.
    from ..explorer import invalidate_model_cache
    invalidate_model_cache(business_id, mv.version)

    # Mirror into Delta so a future `vibe modeling of version` run
    # targeting this version doesn't die on the agent's
    # `_version_exists` check.
    delta_written = False
    warehouse_id = resolve_warehouse_id(session, config)
    if warehouse_id and catalog:
        sync = ModelSyncService(session, ws, warehouse_id=warehouse_id)
        # Nested (agent 4.9.8+) canonical layout; the builder normalizes the
        # business segment the same way ``biz_name_slug`` does.
        delta_volume_path = _version_root_in_volume(
            catalog, business.name, str(mv.version), scope
        )
        try:
            delta_written = sync.write_model_to_delta(
                catalog=catalog,
                business_name=business.name,
                version=str(mv.version),
                model_scope=scope,
                volume_path=delta_volume_path,
                model_payload=model_payload,
            )
        except Exception:
            logger.exception(
                "import_version_from_volume: Delta write failed; Lakebase was still populated"
            )

    session.commit()
    return {
        "ok": True,
        "version_id": mv.id,
        "version": mv.version,
        "run_id": synthetic_run.id,
        "delta_written": delta_written,
        "detected_agent_tag": detected_tag,
        "compat_verdict": verdict,
        "latest_supported_tag": latest_supported_tag(),
    }


# --- Installation drift detection (#69) -----------------------------------


def _scope_short(scope: Optional[str]) -> str:
    """Match `progress_tracker.compute_install_catalog_and_prefix`'s scope
    normalisation: "ecm" unless the scope string mentions "mvm"-ish
    variants, in which case ("ecm" not in it) it's "mvm"."""
    return "ecm" if "ecm" in str(scope or "").lower() else "mvm"


def _dispatched_schema_affixes_for_version(
    session, version_id: str
) -> tuple[list[str], list[str]]:
    """Read the ``schema_prefix`` / ``schema_suffix`` actually dispatched to
    the agent for the op(s) that produced or installed ``version_id``.

    Sourced from ``RunOperation.dispatched_widgets_json`` — the write-once
    audit of the exact widget map handed to the agent (populated for every
    model-producing + install/uninstall op; see
    ``OperationDispatchHandle.dispatched_widgets``). This is how the drift
    probe learns the model's real physical-schema affixes instead of
    assuming the default ``"One Catalog"`` ``{scope}_`` prefix and a blank
    suffix.

    - A generation op links via ``output_version_id``; an install/uninstall
      op links via ``parent_version_id`` (it consumes, not produces, the
      version).
    - ``schema_prefix`` appears in both install and generation widgets;
      ``schema_suffix`` only in the generation/vibe-iterate widgets (install
      doesn't forward it), so we scan every linked op and union what we find.

    Returns ``(prefixes, suffixes)`` — de-duplicated, order-preserving, and
    EMPTY when no op carries a ``dispatched_widgets_json`` (pre-E-03
    installs, hand-built rows). Empty lists are the caller's signal to fall
    back to the legacy scope-prefixed / bare probing without regressing the
    currently-working cases.
    """
    try:
        rows = session.exec(
            select(RunOperation.dispatched_widgets_json).where(
                (RunOperation.output_version_id == version_id)
                | (RunOperation.parent_version_id == version_id)
            )
        ).all()
    except Exception as exc:  # noqa: BLE001 — best-effort enrichment only
        logger.debug(
            "Drift probe could not read dispatched widgets for %s: %s",
            version_id, exc,
        )
        return [], []

    prefixes: list[str] = []
    suffixes: list[str] = []
    for r in rows:
        blob = r if isinstance(r, str) else (r[0] if r else "")
        if not blob or blob == "{}":
            continue
        try:
            widgets = json.loads(blob)
        except (json.JSONDecodeError, TypeError):
            continue
        if not isinstance(widgets, dict):
            continue
        # ``schema_prefix``/``schema_suffix`` may legitimately be "" (the
        # explicit-empty override for Catalog-per-* installs). Distinguish
        # "key absent" (no signal) from "" (explicit empty is a real form).
        if "schema_prefix" in widgets:
            p = str(widgets.get("schema_prefix") or "")
            if p not in prefixes:
                prefixes.append(p)
        if "schema_suffix" in widgets:
            s = str(widgets.get("schema_suffix") or "")
            if s not in suffixes:
                suffixes.append(s)
    return prefixes, suffixes


def _expected_schema_candidates_for_version(
    session, version_id: str, scope: Optional[str]
) -> list[tuple[str, list[str]]]:
    """Return ``(default_expected, [candidate_forms])`` per domain.

    ``Domain.database_name`` is the agent's LOGICAL schema name, assigned
    at domain-design time (Stage 4 of the pipeline) before any deployment
    target is known - e.g. the agent's own docs show
    ``"database_name": "party_db"`` with no scope prefix. The PHYSICAL
    schema the agent creates at install time (Stage 12) is
    ``f"{schema_prefix}{database_name}{schema_suffix}"``.

    - ``schema_prefix`` is ``f"{scope_short}_"`` for the default
      ``"One Catalog"`` style (so an ECM and MVM install into the same
      catalog don't collide) and empty for ``Catalog per Division`` /
      ``Catalog per Domain`` (a dedicated per-scope catalog namespaces
      them instead). See ``progress_tracker.compute_install_catalog_and_prefix``.
    - ``schema_suffix`` is a user naming-standard affix (e.g. ``_wt``) the
      generation op forwards to the agent.

    We don't persist the cataloging_style, and the legacy probe assumed the
    ``{scope}_`` prefix with a BLANK suffix — so a model installed with a
    non-default prefix or ANY ``schema_suffix`` (e.g. WT-Scratch's ``_wt``)
    was false-flagged as drifted (the agent's real ``mvm_party_db_wt``
    never matched the probe's ``mvm_party_db``). We now read the affixes
    actually dispatched to the agent from ``RunOperation.dispatched_
    widgets_json`` and fold them into the candidate set. When no dispatched
    affixes are recorded (pre-E-03 installs), we degrade to the legacy
    ``{scope}_``-prefixed + bare forms so currently-working cases don't
    regress. The caller resolves each domain's forms against the live
    catalog listing and picks whichever is actually present.

    Every domain on the version is probed — no cap. A prior ``_DRIFT_
    MAX_SCHEMAS_PROBED = 8`` cap silently truncated wide models (e.g. an
    18-domain ECM only ever reported 8 expected schemas), making the
    drift probe blind to missing schemas past the 8th domain. A single
    ``ws.schemas.list`` call plus local set matching is sub-second
    regardless of domain count, so the "feels instant" rationale for the
    cap didn't cost anything to give up.
    """
    rows = session.exec(
        select(Domain.database_name).where(Domain.version_id == version_id)
    ).all()
    scope_prefix = f"{_scope_short(scope)}_"

    disp_prefixes, disp_suffixes = _dispatched_schema_affixes_for_version(
        session, version_id
    )
    # Prefixes to probe: always the scope-prefixed + bare legacy forms,
    # plus any prefix the agent was actually handed. Suffixes: always the
    # blank legacy form, plus any dispatched suffix.
    probe_prefixes: list[str] = [scope_prefix, ""]
    for p in disp_prefixes:
        if p not in probe_prefixes:
            probe_prefixes.append(p)
    probe_suffixes: list[str] = [""]
    for s in disp_suffixes:
        if s not in probe_suffixes:
            probe_suffixes.append(s)

    # The single most-actionable name to report as "expected"/"missing"
    # when NONE of the forms exist in the catalog. Prefer what the agent
    # was actually told to use (dispatched prefix+suffix); otherwise keep
    # the legacy scope-prefixed default.
    #
    # Pick the longest NON-EMPTY dispatched affix rather than row order:
    # a One-Catalog model links both a generation op (which may carry an
    # empty schema_prefix) and an install op (the computed "ecm_"/"mvm_"),
    # and row order could otherwise surface the bare name ("customer")
    # instead of the actionable physical name ("ecm_customer") in the
    # reconcile dialog. When the ONLY recorded prefix is explicitly empty
    # (a genuine Catalog-per-* install) keep "" — the bare name is correct
    # there. No dispatched affix at all → legacy scope-prefixed default.
    def _pick_default_affix(values: list[str], fallback: str) -> str:
        non_empty = [v for v in values if v]
        if non_empty:
            return max(non_empty, key=len)
        if values:  # explicitly recorded, all empty (Catalog-per-*)
            return ""
        return fallback

    default_prefix = _pick_default_affix(disp_prefixes, scope_prefix)
    default_suffix = _pick_default_affix(disp_suffixes, "")

    seen: list[tuple[str, list[str]]] = []
    seen_set: set[str] = set()
    for r in rows:
        # session.exec() yields the column value directly when selecting a
        # single column; play defensively in case it's a tuple.
        name = r if isinstance(r, str) else (r[0] if r else "")
        name = (name or "").strip()
        if not name or name in seen_set:
            continue
        seen_set.add(name)
        forms: list[str] = []
        for pfx in probe_prefixes:
            for sfx in probe_suffixes:
                form = f"{pfx}{name}{sfx}"
                if form not in forms:
                    forms.append(form)
        default_expected = f"{default_prefix}{name}{default_suffix}"
        seen.append((default_expected, forms))
    return seen


def _resolve_expected_and_found_schemas(
    ws, catalog: str, candidates: list[tuple[str, list[str]]]
) -> tuple[list[str], list[str]]:
    """Resolve each domain's candidate forms against the live catalog schema
    listing. Single SDK call; matching is done locally so a fat catalog
    with hundreds of schemas still returns in ms.

    For each domain, prefer whichever candidate form is actually present in
    the catalog. When none is present, report the domain's
    ``default_expected`` — the most actionable name for an operator staring
    at a missing-schema list (the dispatched affixes when known, else the
    default "One Catalog" scope-prefixed convention).

    Returns ``(expected_schemas, found_schemas)``.
    """
    if not catalog or not candidates:
        return [], []
    try:
        all_names = {s.name or "" for s in ws.schemas.list(catalog_name=catalog)}
    except Exception as exc:  # noqa: BLE001
        logger.warning(
            "Drift probe could not list schemas in %r: %s", catalog, exc
        )
        raise
    expected: list[str] = []
    found: list[str] = []
    for default_expected, forms in candidates:
        match = next((f for f in forms if f in all_names), None)
        if match is not None:
            expected.append(match)
            found.append(match)
        else:
            expected.append(default_expected)
    return expected, sorted(found)


@router.get(
    "/model-versions/{model_version_id}/installation-status",
    response_model=InstallationStatusOut,
    operation_id="getInstallationStatus",
)
def get_installation_status(
    model_version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Lightweight catalog-vs-Lakebase drift probe for a model version.

    Compares the schemas Lakebase recorded for ALL of this version's
    domains against the catalog's actual schema list. Used by the
    model-version Overview page to detect cases where Lakebase says
    "Installed" but the underlying physical schemas have been dropped
    or overwritten externally.

    Returns ``in_sync=False`` when Lakebase claims installed but ≥1
    expected schema is missing. The UI pops a non-dismissible reconcile
    dialog in that case. Returns ``in_sync=None`` when the probe could
    not run at all (no catalog recorded, no domains, or the catalog
    listing call itself failed) — an honest "unknown", never a false
    "healthy" (``True``) or a false-alarm forced reconcile (``False``).
    """
    mv = session.get(ModelVersion, model_version_id)
    if mv is None:
        raise HTTPException(status_code=404, detail="ModelVersion not found")

    install_catalog = (mv.uc_catalog or "").strip()
    lakebase_says = mv.deployment_status == "deployed"
    candidates = _expected_schema_candidates_for_version(
        session, model_version_id, mv.scope
    )

    # No catalog recorded means we never tried to install (or we have no
    # domains to check against) — we genuinely don't know whether this
    # version is in sync. ``in_sync=None`` says "unknown" honestly instead
    # of the previous ``True``, which read as a healthy signal to any
    # caller of this endpoint even though no probe ever ran (the FE
    # dialog treats anything other than an explicit ``False`` as "don't
    # force a reconcile", so this is also safe for that consumer).
    if not install_catalog or not candidates:
        return InstallationStatusOut(
            version_id=model_version_id,
            deployment_catalog=install_catalog,
            lakebase_says_installed=lakebase_says,
            expected_schemas=[default for default, _ in candidates],
            found_schemas=[],
            missing_schemas=[],
            catalog_present=False,
            in_sync=None,
            checked_at=datetime.now(timezone.utc),
            skipped_reason=(
                "no deployment_catalog or no domains recorded; cannot probe"
            ),
        )

    try:
        expected, found = _resolve_expected_and_found_schemas(
            ws, install_catalog, candidates
        )
    except Exception as exc:  # noqa: BLE001
        # SDK error — don't lie about drift, surface the skip cleanly.
        # Same "unknown, not healthy" reasoning as the skip branch above:
        # the probe never actually ran against a live catalog listing.
        fallback_expected = [default for default, _ in candidates]
        return InstallationStatusOut(
            version_id=model_version_id,
            deployment_catalog=install_catalog,
            lakebase_says_installed=lakebase_says,
            expected_schemas=fallback_expected,
            found_schemas=[],
            missing_schemas=fallback_expected,
            catalog_present=False,
            in_sync=None,
            checked_at=datetime.now(timezone.utc),
            skipped_reason=f"could not list schemas: {exc}",
        )

    missing = sorted(s for s in expected if s not in set(found))
    catalog_present = len(found) > 0
    # Drift = Lakebase says installed but the catalog disagrees.
    in_sync = (not lakebase_says) or (lakebase_says and not missing)

    return InstallationStatusOut(
        version_id=model_version_id,
        deployment_catalog=install_catalog,
        lakebase_says_installed=lakebase_says,
        expected_schemas=expected,
        found_schemas=found,
        missing_schemas=missing,
        catalog_present=catalog_present,
        in_sync=in_sync,
        checked_at=datetime.now(timezone.utc),
    )


@router.post(
    "/model-versions/{model_version_id}/reconcile-installation",
    response_model=ReconcileInstallationOut,
    operation_id="reconcileInstallation",
)
def reconcile_installation(
    model_version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    _role: Dependencies.BusinessAdminOnly,
):
    """Make Lakebase agree with the catalog for one model version.

    The user lands on this endpoint when the drift dialog detects
    Lakebase ↔ catalog disagreement. We re-probe the catalog and:

    - If at least one expected schema is present, leave
      ``deployment_status='deployed'`` (catalog reality matches the
      "installed" claim, even if some schemas were dropped externally).
    - Otherwise, flip to ``deployment_status='uninstalled'``: the
      catalog is empty, so the version is no longer installed.

    We do NOT touch the agent's ``_metamodel`` rows here — that's an
    upstream cleanup the user can drive via a fresh ``uninstall`` run
    once they want to reclaim those rows. The point of this endpoint
    is to make the *app's* view honest, fast.
    """
    mv = session.get(ModelVersion, model_version_id)
    if mv is None:
        raise HTTPException(status_code=404, detail="ModelVersion not found")

    install_catalog = (mv.uc_catalog or "").strip()
    candidates = _expected_schema_candidates_for_version(
        session, model_version_id, mv.scope
    )
    notes: list[str] = []

    if not install_catalog or not candidates:
        notes.append(
            "no deployment_catalog or no domains recorded; nothing to reconcile"
        )
        return ReconcileInstallationOut(
            version_id=model_version_id,
            previous_deployment_status=mv.deployment_status,
            new_deployment_status=mv.deployment_status,
            schemas_present=[],
            schemas_missing=[],
            notes=notes,
        )

    try:
        expected, found = _resolve_expected_and_found_schemas(
            ws, install_catalog, candidates
        )
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(
            status_code=502,
            detail=f"Could not list schemas in {install_catalog!r}: {exc}",
        )

    missing = sorted(s for s in expected if s not in set(found))
    previous = mv.deployment_status

    if found:
        # At least one expected schema exists — keep the "deployed"
        # marker. (Partial drift is still drift, but the user can clean
        # that up via a fresh uninstall + re-install.)
        if mv.deployment_status != "deployed":
            mv.deployment_status = "deployed"
            session.add(mv)
        notes.append(
            f"{len(found)}/{len(expected)} expected schemas present in catalog"
        )
    else:
        if mv.deployment_status != "uninstalled":
            mv.deployment_status = "uninstalled"
            session.add(mv)
        notes.append(
            "no expected schemas found; marked uninstalled"
        )

    session.commit()
    session.refresh(mv)

    return ReconcileInstallationOut(
        version_id=model_version_id,
        previous_deployment_status=previous,
        new_deployment_status=mv.deployment_status,
        schemas_present=found,
        schemas_missing=missing,
        notes=notes,
    )
