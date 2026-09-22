"""``shrink_to_mvm`` — wrap the agent's ``shrink ecm`` op (MVM scope).

Phase 2 of the unified new-base-model DAG: take the parent ECM
ModelVersion and produce a Minimum Viable Model (MVM) version. The
agent reads the ECM's model.json off Volumes and writes the MVM to a
sibling per-scope folder. In One Catalog mode the agent installs the
MVM inline as well; otherwise the DAG's next step is an explicit
``install`` op.

See ``docs/orchestrator-design.md`` §10.
"""

from __future__ import annotations

from typing import Any, Literal, Optional

from pydantic import BaseModel, Field

from ...core._warehouse import get_warehouse_id
from ...db_models import Business, ModelVersion
from ._generation_common import (
    AGENT_OP_SHRINK_ECM,
    DEFAULT_BOOLEAN_FORMAT,
    DEFAULT_DATE_FORMAT,
    DEFAULT_HISTORY_TRACKING_COLUMNS,
    DEFAULT_HOUSEKEEPING_COLUMNS,
    DEFAULT_NAMING_CONVENTION,
    DEFAULT_ORG_DIVISIONS,
    DEFAULT_PRIMARY_KEY_SUFFIX,
    DEFAULT_TABLE_ID_TYPE,
    DEFAULT_TAG_PREFIX,
    DEFAULT_TIMESTAMP_FORMAT,
    SCOPE_LABEL_MVM,
    _ShadowCtx,
    dispatch_generation_op,
    get_agent_job_id,
    observe_generation_op,
    rollback_generation_op,
)
from ._protocol import (
    Operation,
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
)


class ShrinkToMvmParams(BaseModel):
    """Params for ``shrink_to_mvm``.

    ``parent_ecm_version_int`` is the version integer (1..N) the agent
    reads from. The DAG factory threads this through from the prior
    ``generate_ecm`` step's ``output_version_id`` — the validator
    resolves the int from the ModelVersion row.
    """

    # Optional in the params shape: when absent, dispatch resolves the
    # int from ``OperationContext.parent_version_id`` — the canonical
    # source per the Operation contract (§2). Keeping it here lets DAG
    # factories still pin a specific int without round-tripping through
    # the DB if they want to.
    parent_ecm_version_int: Optional[int] = Field(default=None, ge=1)
    business_name: str = Field(pattern=r"^[a-z][a-z0-9_]+$")
    deployment_catalog: str = Field(pattern=r"^[a-z][a-z0-9_]+$")
    cataloging_style: Literal[
        "One Catalog", "Catalog per Division", "Catalog per Domain",
    ]
    # MVM gets a distinct prefix so its inline install in One Catalog
    # mode doesn't collide with the ECM schema in the same catalog.
    mvm_schema_prefix: str = Field(default="mvm_", pattern=r"^[a-z][a-z0-9_]*_$|^$", max_length=32)
    schema_prefix: str = Field(default="mvm_", pattern=r"^[a-z][a-z0-9_]*_$|^$", max_length=32)
    business_description: str = ""
    context_file: str = ""
    model_vibes: str = ""
    industry_alignment: str = ""
    business_domains: str = ""
    org_divisions: str = DEFAULT_ORG_DIVISIONS
    naming_convention: str = DEFAULT_NAMING_CONVENTION
    primary_key_suffix: str = DEFAULT_PRIMARY_KEY_SUFFIX
    schema_suffix: str = ""
    tag_prefix: str = DEFAULT_TAG_PREFIX
    tag_suffix: str = ""
    table_id_type: str = DEFAULT_TABLE_ID_TYPE
    boolean_format: str = DEFAULT_BOOLEAN_FORMAT
    date_format: str = DEFAULT_DATE_FORMAT
    timestamp_format: str = DEFAULT_TIMESTAMP_FORMAT
    classification_levels: str = ""
    housekeeping_columns: str = DEFAULT_HOUSEKEEPING_COLUMNS
    history_tracking_columns: str = DEFAULT_HISTORY_TRACKING_COLUMNS
    catalog_prefix: str = ""
    catalog_suffix: str = ""
    generate_samples: bool = False
    model_folder: str = ""


class ShrinkToMvm(Operation):
    """Produce an MVM ModelVersion from a parent ECM via the agent's
    ``shrink ecm`` operation."""

    name = "shrink_to_mvm"
    params_model = ShrinkToMvmParams
    is_idempotent = False
    produces_version = True

    def dispatch(
        self,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationDispatchHandle:
        job_id = get_agent_job_id(session)
        if not job_id:
            raise RuntimeError(
                "shrink_to_mvm: AgentConfig missing or has no job_id; "
                "cannot launch a Databricks run."
            )
        warehouse_id = get_warehouse_id(session)
        business = session.get(Business, ctx.business_id)
        if business is None:
            raise RuntimeError(
                f"shrink_to_mvm: business_id {ctx.business_id!r} not found"
            )
        # Honour the user's MVM-specific schema_prefix override: the
        # widget the agent reads is `schema_prefix` regardless of which
        # primitive set it. Treat `mvm_schema_prefix` as authoritative
        # so DAG factories can keep the per-scope namespacing explicit
        # even if the user supplied a top-level `schema_prefix` for the
        # ECM step.
        params_for_widgets = dict(ctx.params)
        mvm_prefix = params_for_widgets.get("mvm_schema_prefix")
        if mvm_prefix is not None:
            params_for_widgets["schema_prefix"] = mvm_prefix

        # `shrink ecm` widget semantics: model_version is the BASE the
        # agent reads from (the ECM's version int). Resolve from params
        # if provided; otherwise look it up from the parent ModelVersion
        # row (the canonical source per the Operation contract — §2 says
        # ``parent_version_id`` lives on ``OperationContext``).
        parent_version_int = ctx.params.get("parent_ecm_version_int")
        if not parent_version_int and ctx.parent_version_id:
            parent_mv = session.get(ModelVersion, ctx.parent_version_id)
            if parent_mv is not None:
                parent_version_int = parent_mv.version
        if not parent_version_int:
            raise RuntimeError(
                "shrink_to_mvm: cannot resolve parent ECM version int — "
                "neither params['parent_ecm_version_int'] nor "
                "ctx.parent_version_id were usable."
            )

        # Pass the resolved parent version int through params so the
        # agent widget builder picks it up. Crash-recovery idempotency
        # (re-call with a pre-existing databricks_run_id) is handled by
        # the orchestrator at _runner.py:671-677 before op.dispatch() runs.
        params_for_widgets["model_version_int"] = parent_version_int
        ctx_for_dispatch = _ShadowCtx(ctx, params_for_widgets)
        return dispatch_generation_op(
            operation=AGENT_OP_SHRINK_ECM,
            data_model_scopes=SCOPE_LABEL_MVM,
            ctx=ctx_for_dispatch,
            ws=ws,
            session=session,
            business=business,
            job_id=job_id,
            warehouse_id=warehouse_id,
            model_version=str(int(parent_version_int)),
        )

    def observe(
        self,
        handle: OperationDispatchHandle,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationObservation:
        return observe_generation_op(
            handle=handle,
            ctx=ctx,
            ws=ws,
            session=session,
            scope_short="mvm",
        )

    def rollback(
        self,
        ctx: OperationContext,
        rollback_state: dict,
        ws: Any,
        session: Any,
    ) -> None:
        rollback_generation_op(
            ctx=ctx,
            rollback_state=rollback_state,
            ws=ws,
            session=session,
        )
