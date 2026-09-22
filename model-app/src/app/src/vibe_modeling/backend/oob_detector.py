"""Out-of-band model detection — finds notebook runs that happened outside the app.

Compares completed versions in the Delta metamodel tables against what Lakebase
knows about. Returns a list of "missing" versions that exist in Delta but not
in Lakebase, so the app can offer to import them.
"""

import logging
from typing import Optional

from databricks.sdk import WorkspaceClient
from sqlmodel import Session, select

from .db_models import Business, ModelVersion

logger = logging.getLogger(__name__)

_TABLE_NOT_FOUND = "TABLE_OR_VIEW_NOT_FOUND"


class OobDetector:
    """Detects model versions in Delta metamodel tables that Lakebase doesn't know about."""

    def __init__(self, session: Session, ws: WorkspaceClient, warehouse_id: str):
        self._session = session
        self._ws = ws
        self._warehouse_id = warehouse_id

    def detect(self, catalog: str) -> dict:
        """Scan Delta for completed versions missing from Lakebase.

        Returns:
            {
                "missing_versions": [
                    {"business": str, "version": str, "model_scope": str,
                     "completion_date": str, "business_id": str | None},
                    ...
                ],
                "errors": [str],
            }
        """
        result = {"missing_versions": [], "errors": []}

        delta_rows = self._query_completed_versions(catalog)
        if delta_rows is None:
            result["errors"].append(
                f"Table `{catalog}`._metamodel.business not found"
            )
            return result

        # Build a set of (business_name, version_num) already in Lakebase
        known = self._known_versions()

        for row in delta_rows:
            bname = row.get("business", "")
            version_str = row.get("version", "v1")
            try:
                version_num = int(version_str.lstrip("v"))
            except (ValueError, AttributeError):
                version_num = 1

            if (bname, version_num) not in known:
                # Look up the business_id if this business exists in Lakebase
                business = self._session.exec(
                    select(Business).where(Business.name == bname)
                ).first()
                result["missing_versions"].append({
                    "business": bname,
                    "version": version_str,
                    "version_num": version_num,
                    "model_scope": row.get("model_scope", ""),
                    "completion_date": row.get("completion_date", ""),
                    "business_id": business.id if business else None,
                })

        return result

    def _query_completed_versions(self, catalog: str) -> Optional[list[dict]]:
        """Query _metamodel.business for completed versions only."""
        sql = (
            f"SELECT DISTINCT business, version, model_scope, "
            f"CAST(completion_date AS STRING) as completion_date "
            f"FROM `{catalog}`.`_metamodel`.`business` "
            f"WHERE CAST(completed_percent AS DOUBLE) >= 100 "
            f"AND completion_date IS NOT NULL "
            f"ORDER BY business, version"
        )
        try:
            resp = self._ws.statement_execution.execute_statement(
                warehouse_id=self._warehouse_id,
                statement=sql,
                wait_timeout="30s",
            )
            status = resp.status
            if status and status.error:
                error_msg = status.error.message or ""
                if _TABLE_NOT_FOUND in error_msg:
                    return None
                raise RuntimeError(f"SQL error: {error_msg}")

            manifest = resp.manifest
            data = resp.result
            if not manifest or not data or not data.data_array:
                return []

            columns = [col.name for col in manifest.schema.columns]
            return [dict(zip(columns, row)) for row in data.data_array]
        except Exception as e:
            if _TABLE_NOT_FOUND in str(e):
                return None
            raise

    def _known_versions(self) -> set[tuple[str, int]]:
        """Build a set of (business_name, version_num) already in Lakebase."""
        stmt = (
            select(Business.name, ModelVersion.version)
            .join(ModelVersion, ModelVersion.business_id == Business.id)
        )
        rows = self._session.exec(stmt).all()
        return {(name, ver) for name, ver in rows}
