"""Initial sync — discovers businesses and model versions from Delta metamodel tables.

When the admin configures a deployment catalog, this module scans the
_metamodel.business table to discover all businesses and their completed
versions. For each discovered business it matches (or auto-creates) an
industry record, creates a Business in Lakebase, and triggers model sync
for each completed version.
"""

import logging
from typing import Optional

from databricks.sdk import WorkspaceClient
from sqlmodel import Session, select

from ._query_helpers import resolve_model_version
from .db_models import Business, Industry, ModelVersion
from .model_sync import ModelSyncService, _SyncEmptyError

logger = logging.getLogger(__name__)

# SQL state name returned when a table does not exist
_TABLE_NOT_FOUND = "TABLE_OR_VIEW_NOT_FOUND"


class InitialSyncService:
    """Discovers and imports businesses from a deployment catalog's metamodel tables."""

    def __init__(self, session: Session, ws: WorkspaceClient, warehouse_id: str):
        self._session = session
        self._ws = ws
        self._warehouse_id = warehouse_id

    def discover_and_sync(self, catalog: str) -> dict:
        """Scan _metamodel.business for all businesses and sync them.

        Returns a summary dict:
        {
            "businesses_discovered": int,
            "businesses_created": int,
            "businesses_existing": int,
            "versions_synced": int,
            "industries_auto_created": int,
            "errors": list[str],
        }
        """
        summary = {
            "businesses_discovered": 0,
            "businesses_created": 0,
            "businesses_existing": 0,
            "versions_synced": 0,
            "industries_auto_created": 0,
            "errors": [],
        }

        # Discover all unique businesses from _metamodel.business
        business_rows = self._query_businesses(catalog)
        if business_rows is None:
            summary["errors"].append(
                f"Table `{catalog}`._metamodel.business not found"
            )
            return summary

        # Group by business name to find unique businesses and their versions
        businesses: dict[str, list[dict]] = {}
        for row in business_rows:
            bname = row.get("business", "")
            if bname:
                businesses.setdefault(bname, []).append(row)

        summary["businesses_discovered"] = len(businesses)

        for bname, versions in businesses.items():
            try:
                created, industry_auto = self._ensure_business(bname, versions)
                if created:
                    summary["businesses_created"] += 1
                else:
                    summary["businesses_existing"] += 1
                if industry_auto:
                    summary["industries_auto_created"] += 1

                # Sync completed versions
                synced = self._sync_versions(catalog, bname, versions)
                summary["versions_synced"] += synced
            except Exception as e:
                logger.exception(f"Error syncing business {bname}")
                summary["errors"].append(f"{bname}: {str(e)}")

        return summary

    def _query_businesses(self, catalog: str) -> Optional[list[dict]]:
        """Query _metamodel.business for all rows (distinct businesses/versions)."""
        sql = (
            f"SELECT DISTINCT business, version, model_scope, processing_status, "
            f"completed_percent, CAST(completion_date AS STRING) as completion_date "
            f"FROM `{catalog}`.`_metamodel`.`business` "
            f"ORDER BY business, version"
        )
        try:
            result = self._ws.statement_execution.execute_statement(
                warehouse_id=self._warehouse_id,
                statement=sql,
                wait_timeout="30s",
            )
            status = result.status
            if status and status.error:
                error_msg = status.error.message or ""
                if _TABLE_NOT_FOUND in error_msg:
                    return None
                raise RuntimeError(f"SQL error: {error_msg}")

            manifest = result.manifest
            data = result.result
            if not manifest or not data or not data.data_array:
                return []

            columns = [col.name for col in manifest.schema.columns]
            return [dict(zip(columns, row)) for row in data.data_array]
        except Exception as e:
            if _TABLE_NOT_FOUND in str(e):
                return None
            raise

    def _ensure_business(
        self, business_name: str, versions: list[dict]
    ) -> tuple[bool, bool]:
        """Ensure a Business record exists in Lakebase. Returns (created, industry_auto_created)."""
        # Check if business already exists by name
        existing = self._session.exec(
            select(Business).where(Business.name == business_name)
        ).first()
        if existing:
            return False, False

        # Match industry by short_name
        industry = self._session.exec(
            select(Industry).where(Industry.short_name == business_name)
        ).first()

        industry_auto_created = False
        if not industry:
            # Auto-create a stub industry
            industry = Industry(
                name=business_name.replace("_", " ").title(),
                short_name=business_name,
                is_auto_created=True,
            )
            self._session.add(industry)
            self._session.flush()
            industry_auto_created = True

        business = Business(
            name=business_name,
            industry_alignment=industry.name,
            industry_id=industry.id,
        )
        self._session.add(business)
        self._session.flush()

        return True, industry_auto_created

    def _sync_versions(
        self, catalog: str, business_name: str, versions: list[dict]
    ) -> int:
        """Create ModelVersions and sync model structure for completed versions."""
        business = self._session.exec(
            select(Business).where(Business.name == business_name)
        ).first()
        if not business:
            return 0

        synced = 0
        for row in versions:
            # Only sync completed versions
            completed_pct = float(row.get("completed_percent", "0") or "0")
            completion_date = row.get("completion_date")
            if completed_pct < 100 or not completion_date:
                continue

            version_str = row.get("version", "v1")
            model_scope = row.get("model_scope", "")

            # Parse version number from string like "v1", "v2"
            try:
                version_num = int(version_str.lstrip("v"))
            except (ValueError, AttributeError):
                version_num = 1

            scope_abbr = "mvm" if "MVM" in model_scope or "mvm" in model_scope.lower() else "ecm" if model_scope else ""

            # Check if this version already exists. Since the agent stores
            # each scope under its own `{scope}_v{N}` folder (v0.5.9+) and
            # the DB natural key is now (business, version, scope), uniqueness
            # is checked per-scope: ECM v1 and MVM v1 are siblings, not
            # duplicates.
            existing_mv = resolve_model_version(
                self._session, business.id, version_num, scope_abbr,
            )
            if existing_mv:
                continue

            mv = ModelVersion(
                business_id=business.id,
                version=version_num,
                status="completed",
                deployment_status="deployed",
                scope=scope_abbr,
                uc_catalog=catalog,
            )
            self._session.add(mv)
            self._session.flush()

            from .progress_tracker import _supersede_deployed_siblings
            _supersede_deployed_siblings(self._session, mv)

            # Sync model structure (model.json primary, Delta fallback).
            # Two structurally-empty outcomes land the version in sync_empty
            # rather than a silent completed/ok/0-domains row (whose banner
            # would never fire once the route commits):
            #   G1 — sync_model() returns False (no Volume + no Delta).
            #   G2 — a 0-domain artifact makes the post-sync gate raise
            #        _SyncEmptyError from inside sync_model(); caught here so
            #        the raise doesn't escape to discover_and_sync's generic
            #        except (which only logs).
            sync = ModelSyncService(self._session, self._ws, self._warehouse_id)
            try:
                success = sync.sync_model(
                    mv.id, catalog, business_name, version_str, model_scope
                )
            except _SyncEmptyError as exc:
                self._mark_sync_empty(mv, str(exc))
                continue
            if success:
                synced += 1
            else:
                self._mark_sync_empty(
                    mv,
                    f"No model data found for {business_name}/{version_str} "
                    f"in Volumes or Delta",
                )

        return synced

    def _mark_sync_empty(self, mv: ModelVersion, reason: str) -> None:
        """Flag a completed version whose sync found no model structure.

        Covers both G1 (no Volume + no Delta) and G2 (0-domain artifact). A
        resync won't help until the agent's Volume output is populated.
        """
        mv.sync_state = "sync_empty"
        mv.sync_error_text = reason[:500]
        self._session.add(mv)
        self._session.flush()
        logger.warning(f"{reason} (marked sync_state=sync_empty)")
