"""Source-explorer browse endpoints (`/api/sources/*`) — Wave 1, Track C.

Read-only GETs that drive a future FE *source explorer*: declare the
configured source's capabilities, then walk
sectors → industries → models and fetch a model preview. No mutation in
this story — publish/write comes in a later wave via the UC connection.

The source is resolved from the installation's ``agent_config`` GitHub
pointers (``github_repo_owner`` / ``github_repo_name``), falling back to
the default public repo when unset (see ``sources/github.py``). There is
no source registry: the GitHub connector is the only source today, and a
future lakehouse/Volume source would slot in behind the same
:class:`~vibe_modeling.backend.sources.base.SourceConnector` ABC.
"""

from __future__ import annotations

import logging

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

from ..._metadata import api_prefix
from ..core import Dependencies
from ..sources import (
    ModelArtifact,
    SourceCapabilities,
    SourceConnector,
    SourceError,
    SourceIndustry,
    SourceModelRef,
    SourceNotFoundError,
    SourcePermissionError,
    SourceRateLimitError,
    SourceSector,
    build_github_connector,
    model_id_to_relpath,
    parse_model_statistics,
)
from ..sources.github import _humanize
from ._helpers import _get_or_create_agent_config

logger = logging.getLogger(__name__)

router = APIRouter(prefix=api_prefix)


class ModelPreviewOut(BaseModel):
    """A preview of a model: its README rendered as markdown, folder-derived
    scope/version, companion artifacts, and (when available) the domain
    statistics parsed from the model's release notes."""

    industry_id: str
    model_id: str
    model_name: str | None = Field(default=None, description="Humanized industry name.")
    scope: str
    version: str
    readme: str | None = Field(
        default=None, description="Scope readme, falling back to the version readme; None if neither exists."
    )
    domains: int | None = None
    subdomains: int | None = None
    products: int | None = None
    attributes: int | None = None
    primary_keys: int | None = None
    foreign_keys: int | None = None
    avg_attrs_per_product: float | None = None
    metric_views: int | None = None
    artifacts: list[ModelArtifact]


def _connector(session, config) -> SourceConnector:
    """Build the source connector from the installation's GitHub config.

    Reads authenticate as the deployment's GitHub App (5,000 req/hr) when its
    credentials are configured on ``AppConfig``; otherwise they fall back to
    anonymous public browsing (60 req/hr). ``repo_owner`` / ``repo_name`` come
    from the per-install ``AgentConfig`` row. Transport selection is centralised
    in ``build_github_connector``."""
    cfg = _get_or_create_agent_config(session, config)
    return build_github_connector(
        repo_owner=cfg.github_repo_owner,
        repo_name=cfg.github_repo_name,
        app_credentials=config.github_app_credentials,
    )


def _guard(exc: SourceError) -> HTTPException:
    if isinstance(exc, SourceNotFoundError):
        return HTTPException(status_code=404, detail=str(exc))
    if isinstance(exc, SourceRateLimitError):
        # Actionable 429 instead of a generic 502: the message tells the user
        # to configure a GitHub App or wait for the reset.
        return HTTPException(status_code=429, detail=str(exc))
    if isinstance(exc, SourcePermissionError):
        # 403 (not 502): access denied. The user-facing copy lives in the
        # frontend (mapped on status); keep the detail technical here.
        return HTTPException(status_code=403, detail=str(exc))
    logger.warning("Source error: %s", exc)
    return HTTPException(status_code=502, detail=f"Source unavailable: {exc}")


@router.get(
    "/sources/capabilities",
    response_model=SourceCapabilities,
    operation_id="getSourceCapabilities",
)
def get_source_capabilities(
    session: Dependencies.Session,
    config: Dependencies.Config,
):
    """Declare what the configured source can provide — element kinds,
    discovery mode, materialization timing, whether it has a native
    sector level, and the transport identity (``auth_mode``). Cheap (no
    network)."""
    return _connector(session, config).capabilities()


@router.get(
    "/sources/sectors",
    response_model=list[SourceSector],
    operation_id="listSourceSectors",
)
def list_source_sectors(
    session: Dependencies.Session,
    config: Dependencies.Config,
):
    """List the source's top-level sectors (a flat source returns one
    synthetic sector)."""
    try:
        return _connector(session, config).list_sectors()
    except SourceError as exc:
        raise _guard(exc) from exc


@router.get(
    "/sources/sectors/{sector_id}/industries",
    response_model=list[SourceIndustry],
    operation_id="listSourceIndustries",
)
def list_source_industries(
    sector_id: str,
    session: Dependencies.Session,
    config: Dependencies.Config,
):
    """List industries within a sector."""
    try:
        return _connector(session, config).list_industries(sector_id)
    except SourceError as exc:
        raise _guard(exc) from exc


@router.get(
    "/sources/industries/{industry_id}/models",
    response_model=list[SourceModelRef],
    operation_id="listSourceModels",
)
def list_source_models(
    industry_id: str,
    session: Dependencies.Session,
    config: Dependencies.Config,
):
    """List the models published under an industry."""
    try:
        return _connector(session, config).list_models(industry_id)
    except SourceError as exc:
        raise _guard(exc) from exc


@router.get(
    "/sources/industries/{industry_id}/models/{model_id}/preview",
    response_model=ModelPreviewOut,
    operation_id="getSourceModelPreview",
)
def get_source_model_preview(
    industry_id: str,
    model_id: str,
    session: Dependencies.Session,
    config: Dependencies.Config,
):
    """Preview a model: its README rendered as markdown, folder-derived
    scope/version, companion artifacts, and best-effort domain statistics
    parsed from the model's release notes. Does NOT fetch model.json - the
    scope + version come from the folder path, and the name from
    ``_humanize(industry_id)``."""
    connector = _connector(session, config)
    try:
        version, scope = model_id_to_relpath(model_id).split("/", 1)
    except SourceNotFoundError as exc:
        raise _guard(exc) from exc

    try:
        artifacts = connector.fetch_artifacts(industry_id, model_id)
        readme = connector.fetch_readme(industry_id, model_id)
    except SourceError as exc:
        raise _guard(exc) from exc

    releasenotes = connector.fetch_releasenotes(industry_id, model_id)
    stats = parse_model_statistics(releasenotes) if releasenotes else {}

    return ModelPreviewOut(
        industry_id=industry_id,
        model_id=model_id,
        model_name=_humanize(industry_id),
        scope=scope,
        version=version,
        readme=readme,
        domains=stats.get("domains"),
        subdomains=stats.get("subdomains"),
        products=stats.get("products"),
        attributes=stats.get("attributes"),
        primary_keys=stats.get("primary_keys"),
        foreign_keys=stats.get("foreign_keys"),
        avg_attrs_per_product=stats.get("avg_attrs_per_product"),
        metric_views=stats.get("metric_views"),
        artifacts=artifacts,
    )
