"""Top-level import routes (no business prefix).

These power Story 1 — create-business-by-importing — where the user
picks a model.json off Volumes and the server creates the Business +
the first ModelVersion in a single round-trip.

Story 2 (import-into-existing-business) keeps living under
``/businesses/{id}/import/*`` in ``businesses.py``: the per-business
prefix makes sense when the business already exists and the import is
"just another version".
"""

from __future__ import annotations

import json
import logging
import re
from datetime import datetime, timezone
from typing import Optional

from fastapi import APIRouter, HTTPException, Request
from sqlmodel import Session, select

from ..._metadata import api_prefix
from ..agent_compat import (
    SUPPORTED_TAGS,
    classify_tag,
    describe_incompatibility,
    detect_tag_from_model_json,
    extract_version_provenance,
    latest_supported_tag,
)
from .._query_helpers import (
    BusinessNameConflict,
    ensure_business_name_available,
    next_version_for_scope,
    resolve_lineage_parent,
)
from ..core import Dependencies, resolve_metamodel_catalog
from ..core._warehouse import get_warehouse_id
from ..db_models import (
    Business,
    BusinessContext,
    Industry,
    ModelVersion,
)
from ..import_model import detect_schema, read_model_json_from_volume
from ..model_sync import (
    NEXT_VIBES_JSON_RELATIVE_PATHS,
    NEXT_VIBES_TXT_RELATIVE_PATHS,
    ModelSyncService,
    ingest_next_vibes,
)
from ..models import (
    ArtifactPreview,
    BusinessDigest,
    ImportAnalyzeIn,
    ImportAnalyzeOut,
    ImportCreateBusinessAndExecuteIn,
    ImportCreateBusinessAndExecuteOut,
    ImportPreviewOut,
)
from ..services.artifact_indexer import (
    infer_artifact_type,
    walk_volume_dir_with_size,
)
from ..services.business_digest import extract_business_digest

logger = logging.getLogger(__name__)

router = APIRouter(prefix=api_prefix)


def _extract_gfv_tag(payload: dict) -> str:
    """Pull a parent-version lineage tag out of a model.json payload.

    The agent's ``_vibe_session_metadata.generated_from_version`` field
    turns out to label the OUTPUT version of the run (e.g. ``"v2_ecm"``
    for v2 ECM's own file), not the parent. ``progression.previous_version``
    is also unreliable — it's ``"unknown"`` for every Zalando file we
    looked at. So neither field is usable as a lineage pointer today.

    Hand-edited files MAY carry a real parent pointer at the top-level
    or inside the inner ``model`` block (older convention). Keep those
    lookups for compat. The dominant case — agent-produced files —
    falls through to the version-decrement heuristic in
    :func:`_infer_lineage_parent_id`.

    Returns the tag string (e.g. ``"v1_ecm"``) or ``""`` if absent.
    """
    if not isinstance(payload, dict):
        return ""
    for blob in (payload, payload.get("model") or {}):
        if isinstance(blob, dict) and blob.get("generated_from_version"):
            return str(blob["generated_from_version"])
    return ""


def _infer_lineage_parent_id(
    session: Session,
    business_id: str,
    scope: str,
    new_version_num: int,
) -> Optional[str]:
    """Heuristic: assume the imported version was vibed from ``version - 1``.

    Used when the explicit ``generated_from_version`` tag in the model.json
    didn't resolve (the agent currently stamps it with the OUTPUT label,
    not a parent pointer). When ``new_version_num > 1`` and a same-scope
    version with ``version = new_version_num - 1`` already exists for this
    business, link to it as the parent — that matches the dominant
    vibe-progression case (v1 → v2 → v3).

    Returns the parent's ``id`` or ``None`` when no suitable predecessor
    exists.
    """
    if new_version_num <= 1 or not scope:
        return None
    from .._query_helpers import resolve_model_version
    parent = resolve_model_version(session, business_id, new_version_num - 1, scope)
    return parent.id if parent is not None else None


def _find_industry(session: Session, industry_alignment: str) -> Optional[Industry]:
    """Case-insensitive lookup against ``short_name`` then ``name``.

    Returns the full row (callers may need ``id`` AND need to know
    whether they're auto-creating) rather than just the id like
    ``_resolve_industry_id`` in ``businesses.py``. Kept here rather than
    unified into that helper to avoid changing the existing helper's
    return type — its callers only need the id.
    """
    text = (industry_alignment or "").strip()
    if not text:
        return None
    text_lower = text.lower()
    row = session.exec(
        select(Industry).where(Industry.short_name.ilike(text_lower))
    ).first()
    if row is None:
        row = session.exec(
            select(Industry).where(Industry.name.ilike(text_lower))
        ).first()
    return row


def _enrich_digest_with_industry_flag(
    session: Session, digest: BusinessDigest,
) -> BusinessDigest:
    """Stamp ``industry_will_be_created`` based on the live catalog.

    Story-1 wants the analyze response to flag "this name is new" so the
    confirmation panel can say "Note: industry 'X' will be added on
    import." Mutates by returning a fresh model — Pydantic models are
    not frozen but ``model_copy`` keeps the call-site explicit.
    """
    if not digest.industry_alignment:
        return digest
    existing = _find_industry(session, digest.industry_alignment)
    return digest.model_copy(update={"industry_will_be_created": existing is None})


@router.post(
    "/import/analyze",
    response_model=ImportAnalyzeOut,
    operation_id="analyzeImportRoot",
)
def analyze_import_root(
    data: ImportAnalyzeIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Analyze a model.json before creating a Business from it.

    Mirror of the per-business analyze endpoint but operates on a raw
    Volume path with no target Business. Returns the same envelope,
    plus a populated ``business_digest`` so the UI can pre-fill the
    confirmation form. ``business_digest_diff`` is always None on this
    path — there's no target business to diff against.
    """
    try:
        model_json = read_model_json_from_volume(ws, data.volume_path)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    analysis = detect_schema(model_json)
    from ..core._defaults import SUPPORTED_AGENT_VERSION
    fallback_tag = SUPPORTED_AGENT_VERSION if analysis.valid else None
    detected_tag = detect_tag_from_model_json(model_json, fallback=fallback_tag)
    verdict = classify_tag(detected_tag)
    warnings = list(analysis.warnings)
    if analysis.valid and verdict in ("breaking", "unknown"):
        warnings.append(describe_incompatibility(detected_tag, verdict))
    elif analysis.valid and verdict == "needs-adapter":
        warnings.append(
            f"Agent tag {detected_tag!r} requires an adapter; import will "
            f"proceed with a runtime warning until an adapter ships."
        )

    digest = extract_business_digest(model_json) if analysis.valid else None
    if digest is not None:
        digest = _enrich_digest_with_industry_flag(session, digest)

    return ImportAnalyzeOut(
        valid=analysis.valid,
        inferred_version=analysis.inferred_version,
        action=analysis.action,
        message=analysis.message,
        domain_count=analysis.domain_count,
        product_count=analysis.product_count,
        attribute_count=analysis.attribute_count,
        fk_count=analysis.fk_count,
        warnings=warnings,
        detected_agent_tag=detected_tag,
        compat_verdict=verdict,
        latest_supported_tag=latest_supported_tag(),
        business_digest=digest,
        business_digest_diff=None,
    )


@router.get(
    "/import/preview",
    response_model=ImportPreviewOut,
    operation_id="getImportPreview",
)
def get_import_preview(
    volume_path: str,
    ws: Dependencies.Client,
):
    """Preview what an import will pull in BEFORE executing.

    Walks ``volume_path`` (the folder containing ``model.json`` — or the
    ``model.json`` path itself; we strip the trailing filename) and
    reports model.json presence, the next-vibes lookup status, and the
    typed companion artifacts. Read-only — no Lakebase writes.

    ``next_vibes_status`` mirrors :func:`load_next_vibes_from_root`'s
    priority order: ``"json"`` if any of the .json candidates resolves,
    ``"txt"`` if only a .txt does, ``"missing"`` otherwise. The UI
    surfaces a warning banner on ``"missing"`` so the user knows the
    agent's next-iteration suggestions cannot be reconstructed.
    """
    if not volume_path:
        raise HTTPException(status_code=400, detail="volume_path is required")
    # Accept either the model.json file path or the parent folder. We
    # always probe the parent — companion artifacts (vibes/, docs/,
    # diagram/, …) live as siblings of model.json.
    if volume_path.endswith("/model.json"):
        root = volume_path[: -len("/model.json")]
    else:
        root = volume_path.rstrip("/")

    files_with_size = walk_volume_dir_with_size(ws, root)

    model_json_found = False
    next_vibes_status = "missing"
    next_vibes_path: Optional[str] = None
    artifacts: list[ArtifactPreview] = []
    json_priority = tuple(f"{root}/{rel}" for rel in NEXT_VIBES_JSON_RELATIVE_PATHS)
    txt_priority = tuple(f"{root}/{rel}" for rel in NEXT_VIBES_TXT_RELATIVE_PATHS)
    by_path: dict[str, Optional[int]] = {p: s for p, s in files_with_size}
    for candidate in json_priority:
        if candidate in by_path:
            next_vibes_status = "json"
            next_vibes_path = candidate
            break
    if next_vibes_status == "missing":
        for candidate in txt_priority:
            if candidate in by_path:
                next_vibes_status = "txt"
                next_vibes_path = candidate
                break

    # The next-vibes file is reported separately via ``next_vibes_status``
    # / ``next_vibes_path``. Skip it in the companion list so the UI
    # doesn't double-count it.
    next_vibes_paths = set(json_priority) | set(txt_priority)

    for path, size in files_with_size:
        atype = infer_artifact_type(path, root=root)
        if atype == "model_json":
            model_json_found = True
            continue
        if path in next_vibes_paths:
            continue
        artifacts.append(
            ArtifactPreview(path=path, artifact_type=atype, size_bytes=size),
        )

    # Stable ordering for the UI: by type then path.
    artifacts.sort(key=lambda a: (a.artifact_type, a.path))

    return ImportPreviewOut(
        model_json_found=model_json_found,
        next_vibes_status=next_vibes_status,
        next_vibes_path=next_vibes_path,
        companion_artifacts=artifacts,
        total_artifact_count=len(artifacts),
    )


def _slugify_industry(name: str) -> str:
    """Best-effort slug for ``Industry.short_name``: lowercase, spaces
    and punctuation collapsed to hyphens. Matches the catalog's
    convention (``digital-fashion-commerce``). Identity-safe — the
    catalog only requires uniqueness within itself, no external
    consumer parses this."""
    s = name.strip().lower()
    s = re.sub(r"[^a-z0-9]+", "-", s).strip("-")
    return s or name.strip().lower()


@router.post(
    "/import/create-business-and-execute",
    response_model=ImportCreateBusinessAndExecuteOut,
    operation_id="createBusinessAndExecuteImport",
)
def create_business_and_execute_import(
    request: Request,
    data: ImportCreateBusinessAndExecuteIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.BusinessAdminOnly,
):
    """Create a Business from a model.json's business identity, then import.

    Story-1 entry point. Single transaction so partial state can't leak
    on failure — if the import sync raises, the Business creation rolls
    back too.

    Conflict semantics: if a Business with the same (case-insensitive)
    name already exists, returns 409 pointing the user at the existing
    business and Story 2. Auto-using the existing business would be a
    silent overwrite — the user picked "create new" deliberately.
    """
    from ._helpers import require_config

    # Hard-fail before creating the business when config is missing: a business
    # imported without a metamodel catalog can't be seeded or iterated.
    require_config(session, config, ["metamodel_catalog", "warehouse"], mode="raise")

    try:
        model_json = read_model_json_from_volume(ws, data.volume_path)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    analysis = detect_schema(model_json)
    if not analysis.valid:
        raise HTTPException(status_code=400, detail=analysis.message)

    digest = extract_business_digest(model_json)
    if digest is None:
        raise HTTPException(
            status_code=400,
            detail=(
                "model.json carries no business name. Create the business "
                "manually first and use the per-business import endpoint."
            ),
        )

    # Override resolution: explicit override > digest > error.
    business_name = (
        (data.business_name_override or "").strip()
        or digest.business_name
    )
    if not business_name:
        raise HTTPException(
            status_code=400, detail="business_name is required",
        )
    industry_alignment = (
        data.industry_alignment_override
        if data.industry_alignment_override is not None
        else digest.industry_alignment
    ).strip()
    description = (
        data.description_override
        if data.description_override is not None
        else digest.description
    ).strip()
    business_vibes = (
        data.business_vibes_override
        if data.business_vibes_override is not None
        else digest.business_vibes
    ).strip()
    if not description:
        raise HTTPException(
            status_code=400,
            detail=(
                "description is required — provide an override or import "
                "a model.json that carries a business description."
            ),
        )

    # Skip-if-exists: 409 with a hint, not silent reuse. Sanitization-aware
    # (agent_business_segment): a name that normalizes to an existing
    # business/industry is rejected even without a raw-name clash. The import
    # dialog reads the ``business_already_exists`` detail (business_id +
    # business_name) to offer the per-business import, so that shape is kept.
    try:
        ensure_business_name_available(session, business_name)
    except BusinessNameConflict as exc:
        existing = exc.existing
        raise HTTPException(
            status_code=409,
            detail={
                "error": "business_already_exists",
                "business_id": existing.id,
                "business_name": existing.name,
                "message": (
                    f"A business named '{existing.name}' already exists. "
                    f"Use the per-business import to add this model.json "
                    f"as a new version, or rename the business first."
                ),
            },
        ) from exc

    from ..core._defaults import SUPPORTED_AGENT_VERSION
    detected_tag = detect_tag_from_model_json(
        model_json, fallback=SUPPORTED_AGENT_VERSION
    )
    verdict = classify_tag(detected_tag)
    exec_warnings = list(analysis.warnings)
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
        adapter_warning = (
            f"Agent tag {detected_tag!r} classified as needs-adapter; "
            f"no adapter is implemented yet — importing with the compatible "
            f"code path. Verify the resulting model before deploying."
        )
        logger.warning("create_business_and_execute_import: %s", adapter_warning)
        exec_warnings.append(adapter_warning)

    # Resolve or auto-create the Industry. Mirrors ``initial_sync.py``'s
    # path: when the catalog doesn't recognize the name, we create a
    # stub row with ``is_auto_created=True`` so admins can prune later.
    industry_id: Optional[str] = None
    if industry_alignment:
        existing_industry = _find_industry(session, industry_alignment)
        if existing_industry is not None:
            industry_id = existing_industry.id
        else:
            new_industry = Industry(
                name=industry_alignment,
                short_name=_slugify_industry(industry_alignment),
                description="",
                is_auto_created=True,
                is_active=True,
            )
            session.add(new_industry)
            session.flush()  # assigns id
            industry_id = new_industry.id
            exec_warnings.append(
                f"Auto-created industry '{industry_alignment}' in the catalog "
                f"(was not present)."
            )

    # Create the Business. Single transaction with the ModelVersion +
    # sync below — failures roll back both.
    business = Business(
        name=business_name,
        description=description,
        business_vibes=business_vibes,
        industry_alignment=industry_alignment,
        industry_id=industry_id,
    )
    session.add(business)
    session.flush()

    # Seed BusinessContext from the digest. Mirrors what
    # ``businesses.create_business`` writes on the manual-create path so
    # the Explorer's context section has something before the first
    # vibe run. The model_sync that runs below will overlay the
    # business_context block carried in model.json's inner ``model``
    # dict (via the existing pipeline), but we still want a deterministic
    # seed row so context history isn't empty.
    seed_ctx = {
        "business_context": {
            "business_information": {
                "business": business_name,
                "industry_alignment": industry_alignment,
                "description": description,
            },
            "core_business_processes": digest.core_business_processes,
            "orgnaization_divisions": digest.orgnaization_divisions,
            "common_business_jargons": digest.common_business_jargons,
            "operational_systems_of_records": digest.operational_systems_of_records,
            "industry_governing_body": digest.industry_governing_body,
        }
    }
    session.add(BusinessContext(
        business_id=business.id,
        version_label="seed",
        context_json=json.dumps(seed_ctx),
        conventions_json="{}",
        is_active=True,
    ))

    # Infer scope from model.json's version string.
    version_str = str((analysis._model or {}).get("version", ""))
    m = re.match(r"^v\d+_(mvm|ecm)$", version_str)
    scope = m.group(1) if m else ""

    # Per-scope counter — fresh business, so this is always 1, but use
    # the shared helper so future logic (e.g. allowing both ECM + MVM
    # in one create call) stays correct.
    new_version_num = next_version_for_scope(session, business.id, scope)

    # Lineage: prefer an explicit ``generated_from_version`` tag if it
    # resolves to an existing version; fall back to the heuristic
    # "parent = (same scope, version - 1)" used by `_infer_lineage_parent_id`.
    inner_payload = analysis._model or {}
    gfv_tag = _extract_gfv_tag(inner_payload)
    lineage_parent_id = None
    if gfv_tag:
        parent = resolve_lineage_parent(session, business.id, gfv_tag)
        if parent is not None:
            lineage_parent_id = parent.id
    if lineage_parent_id is None:
        lineage_parent_id = _infer_lineage_parent_id(
            session, business.id, scope, new_version_num,
        )

    # Version provenance from the model.json envelope. Read from the outer
    # ``model_json`` — ``analysis._model`` is the already-unwrapped inner model
    # and no longer carries the top-level agent_version / release_version keys.
    agent_version, release_version = extract_version_provenance(model_json)

    now_ts = datetime.now(timezone.utc)
    mv = ModelVersion(
        business_id=business.id,
        version=new_version_num,
        status="completed",
        deployment_status="draft",
        scope=scope,
        base_version_id=lineage_parent_id,
        completion_date=now_ts,
        import_source_path=data.volume_path,
        imported_at=now_ts,
        agent_version=agent_version,
        release_version=release_version,
    )
    session.add(mv)
    session.flush()

    sync = ModelSyncService(session)
    sync.sync_from_model_json(mv.id, analysis._model or {})

    # Artifact indexing + next_vibes load — same logic as the
    # per-business execute. Non-fatal.
    volume_root_path = data.volume_path.rsplit("/", 1)[0] if "/" in data.volume_path else ""
    if volume_root_path:
        try:
            from ..services.artifact_indexer import index_artifacts_at_path
            index_artifacts_at_path(
                ws, session,
                run_id=None,
                model_version_id=mv.id,
                volume_root_path=volume_root_path,
            )
        except Exception:
            logger.exception(
                "create_business_and_execute_import: artifact indexing failed "
                "for version %s (non-fatal)", mv.id,
            )

        # The raw file is already indexed as a RunArtifact by
        # index_artifacts_at_path above, so we only materialize the structured
        # next-vibe inputs here (shared load-then-materialize helper).
        ingest_next_vibes(
            ws, session,
            version_dir=volume_root_path,
            version_id=mv.id,
            business_id=mv.business_id,
        )

    # Persist the Lakebase ModelVersion + child rows BEFORE the
    # external _metamodel.* Delta writes. The metamodel writer batches
    # its INSERTs (chunked multi-row statements) so even a large model
    # is a handful of warehouse round-trips, but it still targets an
    # external system over a SQL warehouse. Commit here so the import
    # survives a slow or failing metamodel write — write_metamodel does
    # not touch this session, so nothing is lost by committing first.
    session.commit()

    # _metamodel.* Delta writes - external system, non-fatal, post-commit.
    from ..services.import_metamodel_writer import seed_metamodel_one
    seed_metamodel_one(
        ws,
        catalog=resolve_metamodel_catalog(session),
        warehouse_id=get_warehouse_id(session),
        model_json=model_json,
        business_name=business.name,
        scope=scope,
        version=new_version_num,
        log_prefix="create_business_and_execute_import",
    )

    # Post-import diagram pre-compute. Best-effort.
    try:
        from ..diagram import (
            _invalidate_business_layouts,
            queue_layout_prefetch_for_version,
        )

        _invalidate_business_layouts(session, business.id, mv.id)
        # expire_on_commit=False: this factory feeds the same background ELK
        # prefetch worker (_background_compute) as the diagram route's own
        # session_factory - see diagram.py's get_diagram_layout for why.
        post_import_session_factory = lambda: Session(
            bind=request.app.state.engine, expire_on_commit=False,
        )
        queue_layout_prefetch_for_version(
            session, post_import_session_factory, ws,
            business_id=business.id,
            version_int=new_version_num,
            scope=scope,
        )
    except Exception:
        logger.exception(
            "Failed to queue post-import pre-computes (non-fatal)"
        )

    # Count what was inserted.
    from ..db_models import (
        Attribute as DbAttr,
        Domain as DbDomain,
        ForeignKeyLink,
        Product as DbProduct,
    )
    domains = session.exec(select(DbDomain).where(DbDomain.version_id == mv.id)).all()
    products = session.exec(select(DbProduct).where(DbProduct.version_id == mv.id)).all()
    attr_count = sum(
        1 for p in products
        for _ in session.exec(select(DbAttr).where(DbAttr.product_id == p.id)).all()
    )
    fks = session.exec(
        select(ForeignKeyLink).where(ForeignKeyLink.version_id == mv.id)
    ).all()

    return ImportCreateBusinessAndExecuteOut(
        business_id=business.id,
        version_id=mv.id,
        version=new_version_num,
        domains=len(domains),
        products=len(products),
        attributes=attr_count,
        fk_links=len(fks),
        warnings=exec_warnings,
        detected_agent_tag=detected_tag,
        compat_verdict=verdict,
        latest_supported_tag=latest_supported_tag(),
    )
