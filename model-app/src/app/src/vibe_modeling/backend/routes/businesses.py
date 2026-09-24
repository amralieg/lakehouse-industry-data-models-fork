"""Business CRUD + business-context + model-import endpoints (`/api/businesses/*`).

Covers the resource lifecycle for the `Business` table itself, the
business-context history we keep alongside it, and the
`/businesses/{id}/import/{analyze,execute}` flow that imports a model.json
from Volumes as a new ModelVersion. Model-version *versions* are split off
into `versions.py` since the read side is large.
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
    Run,
    Sector,
)
from ..import_model import detect_schema, read_model_json_from_volume
from ..model_sync import ModelSyncService, ingest_next_vibes
from ..models import (
    BusinessContextIn,
    BusinessContextOut,
    BusinessDigestDiff,
    BusinessIn,
    BusinessKind,
    BusinessListOut,
    BusinessOut,
    ImportAnalyzeIn,
    ImportAnalyzeOut,
    ImportExecuteIn,
    ImportExecuteOut,
)
from ..services.business_digest import (
    diff_business_digest,
    extract_business_digest,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix=api_prefix)


def _resolve_industry_id(session: Session, industry_alignment: str) -> Optional[str]:
    """Best-effort lookup of an ``Industry.id`` for free-text ``industry_alignment``.

    Case-insensitive match against ``short_name`` first (matches the
    canonical industry-catalog identifier — e.g. ``"digital-fashion-commerce"``
    for the Zalando import) then falls back to ``name`` for hand-typed labels
    like ``"Retail"``. Returns ``None`` when the text is empty or no industry
    row matches; callers must accept ``None`` as a normal "user hasn't picked
    an industry yet" state, not an error.
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
    return row.id if row else None


def _validate_sector_id(session: Session, sector_id: Optional[str]) -> None:
    """Reject a non-existent ``sector_id`` with a structured 404.

    ``sector_id`` is a FK into ``sectors.id`` (ADR D-047). A ``None``/blank id
    is the normal "no sector picked" state and is allowed through. A
    non-empty id that matches no Sector row is a dangling reference — fail
    loudly so the create/update path never persists it silently.
    """
    if not sector_id:
        return
    if session.get(Sector, sector_id) is None:
        raise HTTPException(
            status_code=404,
            detail={
                "error": "sector_not_found",
                "sector_id": sector_id,
                "message": f"No sector exists with id '{sector_id}'.",
            },
        )


# --- Businesses ---


@router.get(
    "/businesses",
    response_model=list[BusinessListOut],
    operation_id="listBusinesses",
)
def list_businesses(
    session: Dependencies.Session,
    kind: Optional[BusinessKind] = None,
):
    statement = select(Business)
    if kind is not None:
        statement = statement.where(Business.kind == kind)
    businesses = session.exec(statement.order_by(Business.name)).all()
    return [
        BusinessListOut(
            id=b.id, name=b.name,
            industry_alignment=b.industry_alignment,
            kind=b.kind,
            sector_id=b.sector_id,
            source_industry_id=b.source_industry_id,
            source_version=b.source_version,
            model_count=len(b.versions),
            downloaded_scopes=sorted({v.scope for v in b.versions if v.scope}),
            created_at=b.created_at,
        )
        for b in businesses
    ]


@router.get(
    "/businesses/{business_id}",
    response_model=BusinessOut,
    operation_id="getBusiness",
)
def get_business(business_id: str, session: Dependencies.Session):
    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")
    return business


@router.post(
    "/businesses",
    response_model=BusinessOut,
    operation_id="createBusiness",
)
def create_business(
    data: BusinessIn,
    session: Dependencies.Session,
    _role: Dependencies.BusinessAdminOnly,
):
    try:
        ensure_business_name_available(session, data.name)
    except BusinessNameConflict as exc:
        raise HTTPException(
            status_code=409,
            detail={"error": "business_name_taken", "name": data.name, "message": str(exc)},
        ) from exc
    _validate_sector_id(session, data.sector_id)
    business = Business(
        name=data.name,
        description=data.description,
        business_vibes=data.business_vibes,
        industry_alignment=data.industry_alignment,
        industry_id=_resolve_industry_id(session, data.industry_alignment),
        kind=data.kind,
        sector_id=data.sector_id,
    )
    session.add(business)
    session.commit()
    session.refresh(business)

    # Seed a BusinessContext row from the create-time fields so the Explorer
    # context section has something to show before the first vibe run. The
    # agent overwrites this on the first run's sync via model.json's
    # `business_context` block; seeding it here avoids the empty-context
    # surprise on a brand-new business page.
    seed_ctx = {
        "business_context": {
            "business_information": {
                "business": data.name,
                "industry_alignment": data.industry_alignment or "",
                "description": data.description or "",
            }
        }
    }
    session.add(BusinessContext(
        business_id=business.id,
        version_label="seed",
        context_json=json.dumps(seed_ctx),
        conventions_json="{}",
        is_active=True,
    ))
    session.commit()
    return business


@router.put(
    "/businesses/{business_id}",
    response_model=BusinessOut,
    operation_id="updateBusiness",
)
def update_business(
    business_id: str,
    data: BusinessIn,
    session: Dependencies.Session,
    _role: Dependencies.BusinessAdminOnly,
):
    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")
    # Patch-style update: every client-writable field is applied only when the
    # caller actually sent it. ``BusinessIn`` gives each field a default, so an
    # unconditional assignment would clobber the stored value (and cascade-NULL
    # derived columns) on every edit form that omits the field. For example, an
    # edit dialog that drops ``industry_alignment`` would also NULL the derived
    # ``industry_id``, and a runs-detail inline edit that never sends
    # ``business_vibes`` would wipe it. ``model_fields_set`` distinguishes
    # "present in request body" from "absent, use default", so an omitted field
    # is preserved while an explicit ``null``/``""`` is applied.
    if "name" in data.model_fields_set and data.name != business.name:
        try:
            ensure_business_name_available(session, data.name, exclude_id=business.id)
        except BusinessNameConflict as exc:
            raise HTTPException(
                status_code=409,
                detail={"error": "business_name_taken", "name": data.name, "message": str(exc)},
            ) from exc
        business.name = data.name
    if "description" in data.model_fields_set:
        business.description = data.description
    if "business_vibes" in data.model_fields_set:
        business.business_vibes = data.business_vibes
    if "industry_alignment" in data.model_fields_set:
        business.industry_alignment = data.industry_alignment
        # ``industry_id`` is derived from the alignment text, so it must move in
        # lockstep; recompute it inside this branch only.
        business.industry_id = _resolve_industry_id(session, data.industry_alignment)
    if "sector_id" in data.model_fields_set:
        _validate_sector_id(session, data.sector_id)
        business.sector_id = data.sector_id
    business.updated_at = datetime.now(timezone.utc)
    session.add(business)
    session.commit()
    session.refresh(business)
    return business


@router.delete(
    "/businesses/{business_id}",
    response_model=dict,
    operation_id="deleteBusiness",
)
def delete_business(
    business_id: str,
    session: Dependencies.Session,
    _role: Dependencies.BusinessAdminOnly,
    cascade: bool = False,
):
    """Delete a business. By default rejects if the business has any model
    versions or runs. Pass ?cascade=true (admin recovery flag) to remove it and
    all dependent data.

    The delete rides the DB ON DELETE rules: model versions and their element
    tree, runs and their run-scoped rows, vibe inputs and their context/run
    links, diagram caches, and business contexts all die via ``business_id`` /
    ``version_id`` / ``run_id`` CASCADE; ``source_industry_id`` on any business
    kickstarted from this one SET NULLs so kickstarted children survive with
    their provenance cleared."""
    from sqlalchemy.exc import IntegrityError, SQLAlchemyError

    from ._helpers import _offending_relation

    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")

    # The 409 confirm gate: refuse a bare delete when the business carries model
    # versions or runs so the caller must opt into ?cascade=true. Run is checked
    # alongside ModelVersion because it FKs back to ``businesses.id`` and can
    # exist without ever producing a version (a failed new-base-model run).
    if not cascade:
        if len(business.versions) > 0:
            raise HTTPException(
                status_code=409,
                detail="Cannot delete a business that has model versions; pass ?cascade=true to force",
            )
        if session.exec(select(Run.id).where(Run.business_id == business_id).limit(1)).first():
            raise HTTPException(
                status_code=409,
                detail="Cannot delete a business that has runs; pass ?cascade=true to force",
            )

    try:
        session.delete(business)
        session.commit()
    except IntegrityError as exc:
        session.rollback()
        rel = _offending_relation(exc)
        raise HTTPException(
            status_code=409,
            detail=(
                "Could not delete business: it still has dependent records"
                + (f" ({rel})" if rel else "")
            ),
        )
    except SQLAlchemyError:
        session.rollback()
        raise HTTPException(
            status_code=409,
            detail="Could not delete business due to a database error",
        )
    return {"ok": True, "cascaded": cascade}


# --- Business Contexts ---


@router.get(
    "/businesses/{business_id}/contexts",
    response_model=list[BusinessContextOut],
    operation_id="listContexts",
)
def list_contexts(business_id: str, session: Dependencies.Session):
    contexts = session.exec(
        select(BusinessContext)
        .where(BusinessContext.business_id == business_id)
        .order_by(BusinessContext.created_at.desc())
    ).all()
    return contexts


@router.post(
    "/businesses/{business_id}/contexts",
    response_model=BusinessContextOut,
    operation_id="createContext",
)
def create_context(
    business_id: str,
    data: BusinessContextIn,
    session: Dependencies.Session,
    _role: Dependencies.ModelerOnly,
):
    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")
    context = BusinessContext(
        business_id=business_id,
        version_label=data.version_label,
        context_json=data.context_json,
        conventions_json=data.conventions_json,
        is_active=data.is_active,
    )
    session.add(context)
    session.commit()
    session.refresh(context)
    return context


# --- Model Import ---


@router.post(
    "/businesses/{business_id}/import/analyze",
    response_model=ImportAnalyzeOut,
    operation_id="analyzeImport",
)
def analyze_import(
    business_id: str,
    data: ImportAnalyzeIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Analyze a model.json at the given Volume path without importing.

    Returns a structured report indicating whether the file matches a known
    vibe-modeling-agent schema, with counts and warnings so the user can confirm.
    """
    biz = session.exec(select(Business).where(Business.id == business_id)).first()
    if not biz:
        raise HTTPException(status_code=404, detail="Business not found")

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
    digest_diff: Optional[BusinessDigestDiff] = None
    if digest is not None:
        mismatches = diff_business_digest(
            digest,
            current_name=biz.name,
            current_industry_alignment=biz.industry_alignment,
        )
        digest_diff = BusinessDigestDiff(
            digest=digest, mismatch_fields=mismatches,
        )

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
        business_digest_diff=digest_diff,
    )


@router.post(
    "/businesses/{business_id}/import/execute",
    response_model=ImportExecuteOut,
    operation_id="executeImport",
)
def execute_import(
    request: Request,
    business_id: str,
    data: ImportExecuteIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.ModelerOnly,
):
    """Import a previously-vibed model.json from a Volume as a new ModelVersion.

    The imported version is marked deployment_status='draft' — user runs the
    install operation manually to push to UC.
    """
    from ._helpers import require_config

    # Hard-fail before importing when config is missing: an import that can't
    # seed _metamodel leaves a version that can't be iterated.
    require_config(session, config, ["metamodel_catalog", "warehouse"], mode="raise")

    biz = session.exec(select(Business).where(Business.id == business_id)).first()
    if not biz:
        raise HTTPException(status_code=404, detail="Business not found")

    try:
        model_json = read_model_json_from_volume(ws, data.volume_path)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    analysis = detect_schema(model_json)
    if not analysis.valid:
        raise HTTPException(status_code=400, detail=analysis.message)

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
        logger.warning("import/execute: %s", adapter_warning)
        exec_warnings.append(adapter_warning)

    # Story-2: refuse the import when the model.json's business identity
    # disagrees with the target Business unless the user has explicitly
    # opted in (UI checkbox). The agent stamps both `business_name` and
    # `industry_alignment` into the file, so importing one business's
    # model into another's row is the kind of "looks right but isn't"
    # mistake the diff catches. Runs AFTER the compat check — a
    # structurally-incompatible file is the harder failure mode and we
    # want its 422 to surface even when names also disagree.
    digest = extract_business_digest(model_json)
    if digest is not None and not data.accept_business_mismatch:
        mismatches = diff_business_digest(
            digest,
            current_name=biz.name,
            current_industry_alignment=biz.industry_alignment,
        )
        if mismatches:
            raise HTTPException(
                status_code=409,
                detail={
                    "error": "business_identity_mismatch",
                    "message": (
                        f"model.json describes business "
                        f"'{digest.business_name}' (industry: "
                        f"'{digest.industry_alignment}') but the target "
                        f"business is '{biz.name}' (industry: "
                        f"'{biz.industry_alignment}'). Re-submit with "
                        f"accept_business_mismatch=true to import anyway."
                    ),
                    "mismatch_fields": [m.model_dump() for m in mismatches],
                },
            )

    # Infer scope from the "v<N>_<mvm|ecm>" version string if present.
    version_str = str((analysis._model or {}).get("version", ""))
    m = re.match(r"^v\d+_(mvm|ecm)$", version_str)
    scope = m.group(1) if m else ""

    # Per-scope ordinal: ECM and MVM number independently so the natural
    # key (business, version, scope) stays unique.
    new_version_num = next_version_for_scope(session, business_id, scope)

    # Lineage: explicit tag first, version-decrement heuristic second.
    from .import_root import _extract_gfv_tag, _infer_lineage_parent_id
    inner_payload = analysis._model or {}
    gfv_tag = _extract_gfv_tag(inner_payload)
    lineage_parent_id = None
    if gfv_tag:
        parent = resolve_lineage_parent(session, business_id, gfv_tag)
        if parent is not None:
            lineage_parent_id = parent.id
    if lineage_parent_id is None:
        lineage_parent_id = _infer_lineage_parent_id(
            session, business_id, scope, new_version_num,
        )

    # Import is a synchronous Volume → Lakebase sync — the model was
    # vibed elsewhere and we're just landing it. Provenance lives on
    # ModelVersion (import_source_path + imported_at); no Run row,
    # no progress events, no orchestrator dispatch.
    # Version provenance from the model.json envelope. Read from the outer
    # ``model_json`` — ``analysis._model`` is the already-unwrapped inner model
    # and no longer carries the top-level agent_version / release_version keys.
    agent_version, release_version = extract_version_provenance(model_json)

    now_ts = datetime.now(timezone.utc)
    mv = ModelVersion(
        business_id=business_id,
        version=new_version_num,
        status="completed",
        deployment_status="draft",  # Import does NOT write to UC; user installs manually
        scope=scope,
        base_version_id=lineage_parent_id,
        completion_date=now_ts,
        import_source_path=data.volume_path,
        imported_at=now_ts,
        agent_version=agent_version,
        release_version=release_version,
    )
    session.add(mv)
    session.flush()  # assigns mv.id

    sync = ModelSyncService(session)
    sync.sync_from_model_json(mv.id, analysis._model or {})

    # Compute the Volume folder that holds model.json so we can index
    # sibling artifacts (diagram/, docs/, ontology/, schemas/, metrics/,
    # vibes/, top-level readme.md).
    volume_root_path = data.volume_path.rsplit("/", 1)[0] if "/" in data.volume_path else ""
    if volume_root_path:
        # Index every artifact under the volume root as a RunArtifact row.
        # No producing Run for imports — run_id stays NULL; the artifact
        # tab keys off model_version_id.
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
                "execute_import: artifact indexing failed for version %s "
                "(non-fatal)", mv.id,
            )

        # Materialize structured agent next-vibe inputs when the import folder
        # ships a next-vibes artifact. The raw file is already indexed as a
        # RunArtifact by index_artifacts_at_path above, so we only materialize
        # the structured rows here (shared load-then-materialize helper). Falls
        # through silently when the file is absent - the common case for
        # hand-curated imports.
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

    # Write the imported model's structure into the agent's
    # ``_metamodel.{business,domain,product,attribute}`` Delta tables so
    # subsequent vibe-iterate / shrink / enlarge runs can read this model
    # as their input. Non-fatal, post-commit (external SQL warehouse, so a
    # failure here cannot roll back the import). The single shared seed path.
    from ..services.import_metamodel_writer import seed_metamodel_one
    seed_metamodel_one(
        ws,
        catalog=resolve_metamodel_catalog(session),
        warehouse_id=get_warehouse_id(session),
        model_json=model_json,
        business_name=biz.name,
        scope=scope,
        version=new_version_num,
        log_prefix="execute_import",
    )

    # Invalidate stale layouts for prior versions and queue pre-computes
    # for the newly imported version so the first diagram view is fast.
    # Non-blocking — uses the ELK prefetch thread pool.
    try:
        from ..diagram import (
            _invalidate_business_layouts,
            queue_layout_prefetch_for_version,
        )

        _invalidate_business_layouts(session, business_id, mv.id)

        # Pre-compute runs asynchronously after this handler returns, so the
        # request-scoped `session` will already be closed by the time the
        # worker picks the job up. Hand the helper a factory that opens its
        # own session bound to the app engine. Lazy evaluation keeps tests
        # that stub _prefetch_pool.submit happy even if they don't set up
        # app.state.engine.
        # expire_on_commit=False: this factory feeds the same background ELK
        # prefetch worker (_background_compute) as the diagram route's own
        # session_factory - see diagram.py's get_diagram_layout for why.
        post_import_session_factory = lambda: Session(
            bind=request.app.state.engine, expire_on_commit=False,
        )
        queue_layout_prefetch_for_version(
            session, post_import_session_factory, ws,
            business_id=business_id,
            version_int=new_version_num,
            scope=scope,
        )
    except Exception:
        # Pre-compute is best-effort; never fail the import because of it
        logger.exception("Failed to queue post-import pre-computes (non-fatal)")

    # Count what was inserted for the response
    from ..db_models import Attribute as DbAttr, Domain as DbDomain, ForeignKeyLink, Product as DbProduct
    domains = session.exec(select(DbDomain).where(DbDomain.version_id == mv.id)).all()
    products = session.exec(select(DbProduct).where(DbProduct.version_id == mv.id)).all()
    attr_count = sum(
        1 for p in products
        for _ in session.exec(select(DbAttr).where(DbAttr.product_id == p.id)).all()
    )
    fks = session.exec(
        select(ForeignKeyLink).where(ForeignKeyLink.version_id == mv.id)
    ).all()

    return ImportExecuteOut(
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
