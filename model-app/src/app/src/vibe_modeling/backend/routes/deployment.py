"""Deployment-verifier endpoints (`/api/businesses/.../deployment/*`).

Wraps the `DeploymentVerifier` service so the UI can compare a logical
ModelVersion in Lakebase against the UC schema actually deployed for it,
and check that the catalog is reachable in the first place.
"""

from __future__ import annotations

from fastapi import APIRouter, HTTPException
from sqlmodel import select

from ..._metadata import api_prefix
from ..core import Dependencies, resolve_version_volume_catalog
from ..db_models import ModelVersion
from ._helpers import resolve_warehouse_id

router = APIRouter(prefix=api_prefix)


@router.get(
    "/businesses/{business_id}/versions/{version_id}/deployment/catalog-check",
    response_model=dict,
    operation_id="checkDeploymentCatalog",
)
def check_deployment_catalog(
    business_id: str,
    version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
):
    """Check if the deployment catalog exists and is accessible."""
    from ..deployment_verifier import DeploymentVerifier

    mv = session.get(ModelVersion, version_id)
    if not mv or mv.business_id != business_id:
        raise HTTPException(status_code=404, detail="Version not found")

    # Where this version lives: its install catalog (mv.uc_catalog) when
    # installed, else the installation metamodel catalog for a draft.
    catalog = resolve_version_volume_catalog(mv, session)
    if not catalog:
        raise HTTPException(status_code=400, detail="No catalog configured")

    verifier = DeploymentVerifier(session, ws, resolve_warehouse_id(session, config))
    return verifier.check_catalog(catalog)


@router.get(
    "/businesses/{business_id}/versions/{version_id}/deployment/uc-schema",
    response_model=dict,
    operation_id="getDeployedUcSchema",
)
def get_deployed_uc_schema(
    business_id: str,
    version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
):
    """Query information_schema for the deployed UC schema of this version."""
    from ..deployment_verifier import DeploymentVerifier

    mv = session.get(ModelVersion, version_id)
    if not mv or mv.business_id != business_id:
        raise HTTPException(status_code=404, detail="Version not found")

    # Where this version lives: its install catalog (mv.uc_catalog) when
    # installed, else the installation metamodel catalog for a draft.
    catalog = resolve_version_volume_catalog(mv, session)
    if not catalog:
        raise HTTPException(status_code=400, detail="No catalog configured")

    verifier = DeploymentVerifier(session, ws, resolve_warehouse_id(session, config))
    # Derive schemas from the logical model's domains
    from ..db_models import Domain
    domains = session.exec(select(Domain).where(Domain.version_id == version_id)).all()
    schemas = [d.database_name or d.name for d in domains]

    return verifier.get_uc_schema(catalog, schemas)


@router.get(
    "/businesses/{business_id}/versions/{version_id}/deployment/compare",
    response_model=dict,
    operation_id="compareDeployment",
)
def compare_deployment(
    business_id: str,
    version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
):
    """Compare logical model (Lakebase) against deployed UC schema."""
    from ..deployment_verifier import DeploymentVerifier

    mv = session.get(ModelVersion, version_id)
    if not mv or mv.business_id != business_id:
        raise HTTPException(status_code=404, detail="Version not found")

    # Where this version lives: its install catalog (mv.uc_catalog) when
    # installed, else the installation metamodel catalog for a draft.
    catalog = resolve_version_volume_catalog(mv, session)
    if not catalog:
        raise HTTPException(status_code=400, detail="No catalog configured")

    verifier = DeploymentVerifier(session, ws, resolve_warehouse_id(session, config))
    return verifier.compare(version_id, catalog)
