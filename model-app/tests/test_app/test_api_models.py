"""Test Pydantic API models — keepers only.

Trimmed: tautological enum-value checks (`RunStatus.PENDING == "pending"`)
and `test_minimal/test_full/test_serialization` round-trips removed —
Pydantic guarantees those. What remains targets:

- The `RunIn` schema-prefix `None` default (router-defaults seam).
- `RunOut.vibe_session_id` field presence (UI consumes this).
- `Intent` absence-of-deploy negative test (guards C-04 regression).
- `BusinessContextIn` defaults (consumed by router create path).
"""

import sys
import os
from datetime import datetime, timezone

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from vibe_modeling.backend.models import (
    BusinessContextIn,
    Intent,
    RunIn,
    RunOut,
    RunStatus,
)


class TestEnums:
    def test_intent_no_deploy(self):
        values = {e.value for e in Intent}
        assert "deploy" not in values
        assert "undeploy" not in values


class TestRunIn:
    def test_ecm_and_mvm_schema_prefix_default_none(self):
        """Per-scope schema prefixes default to None so the router can
        derive sensible defaults from `cataloging_style`. Never forced into
        a literal empty string on the In model — that would prevent the
        router from distinguishing "user wants empty prefix" from "user
        didn't care, pick defaults for me"."""
        r = RunIn()
        assert r.ecm_schema_prefix is None
        assert r.mvm_schema_prefix is None
        # Legacy field also defaults to None for non-unified ops.
        assert r.schema_prefix is None

    def test_ecm_and_mvm_schema_prefix_user_override(self):
        """Explicit values (including empty string) round-trip intact."""
        r = RunIn(
            ecm_schema_prefix="custom_ecm_",
            mvm_schema_prefix="")
        assert r.ecm_schema_prefix == "custom_ecm_"
        assert r.mvm_schema_prefix == ""


class TestRunOut:
    def test_vibe_session_id_field(self):
        now = datetime.now(timezone.utc)
        r = RunOut(
            id="r1", business_id="b1", version_id=None,
            intent="new-base-model", status=RunStatus.RUNNING,
            databricks_run_id=None, vibe_session_id="test-session",
            progress_percent=0, progress_message="", error_message="",
            parameters_json="{}", started_at=None, completed_at=None, created_at=now,
        )
        assert r.vibe_session_id == "test-session"


class TestBusinessContextIn:
    def test_defaults(self):
        ctx = BusinessContextIn()
        assert ctx.context_json == "{}"
        assert ctx.conventions_json == "{}"
        assert ctx.is_active is True
