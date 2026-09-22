"""Installation drift detection + reconcile (#69).

Two surfaces:

- ``GET /api/model-versions/{id}/installation-status``: cheap probe used
  by the model-version Overview page on mount. Compares the schemas
  Lakebase has on file (from ``Domain.database_name``) against the
  catalog's actual schema list.
- ``POST /api/model-versions/{id}/reconcile-installation``: when the UI
  detects drift, the user clicks Reconcile and Lakebase's
  ``deployment_status`` is flipped to match the catalog reality.

Plus: the orchestrator's ``Uninstall`` primitive now flips Lakebase
``deployment_status='uninstalled'`` on terminal SUCCESS, so a
completed uninstall stops showing the phantom "Installed" badge.
"""
from __future__ import annotations

from types import SimpleNamespace
from unittest.mock import MagicMock
from uuid import uuid4

import pytest
from sqlmodel import Session

import json

from vibe_modeling.backend.db_models import (
    Business,
    Domain,
    Industry,
    ModelVersion,
    Run,
    RunOperation,
)
from vibe_modeling.backend.services.operations._protocol import (
    OperationContext,
    OperationDispatchHandle,
)
from vibe_modeling.backend.services.operations.uninstall import Uninstall


def _seed_business(engine, *, name="drift-biz") -> str:
    with Session(engine) as s:
        ind = Industry(name="Test", short_name="test", description="x")
        s.add(ind)
        s.flush()
        b = Business(name=name, description="t", industry_id=ind.id)
        s.add(b)
        s.commit()
        return b.id


def _seed_version(
    engine, business_id, *, version=1, scope="ecm",
    deployment_status="deployed", catalog="vibe_modeling_test",
    # Bare, unprefixed logical names - matches the agent's own
    # `database_name` convention (see modelling_agent's Stage 4 docs,
    # e.g. `"database_name": "party_db"`). The scope prefix
    # ("ecm_"/"mvm_") is only ever applied at physical install time for
    # the default "One Catalog" cataloging style; see
    # `_scope_short`/`_expected_schema_candidates_for_version` in
    # routes/versions.py.
    domains=("customer", "inventory"),
) -> str:
    with Session(engine) as s:
        mv = ModelVersion(
            business_id=business_id,
            version=version,
            scope=scope,
            status="completed",
            deployment_status=deployment_status,
            uc_catalog=catalog,
        )
        s.add(mv)
        s.flush()
        for db_name in domains:
            s.add(Domain(
                version_id=mv.id,
                name=db_name,
                database_name=db_name,
            ))
        s.commit()
        return mv.id


def _stub_schemas(mock_ws, names: list[str]) -> None:
    mock_ws.schemas.list.return_value = iter(
        [SimpleNamespace(name=n) for n in names]
    )


def _seed_generation_op(
    engine, business_id, version_id, *, dispatched_widgets: dict
) -> None:
    """Attach a generation RunOperation to ``version_id`` carrying the
    ``dispatched_widgets_json`` audit blob the drift probe reads to learn
    the model's real schema_prefix / schema_suffix (E-03 populates this
    for every model-producing op)."""
    with Session(engine) as s:
        run = Run(
            business_id=business_id,
            intent="new-base-model",
            status="succeeded",
            parameters_json="{}",
        )
        s.add(run)
        s.commit()
        s.refresh(run)
        ro = RunOperation(
            run_id=run.id,
            step_index=0,
            operation_name="generate_ecm",
            params_json="{}",
            status="succeeded",
            output_version_id=version_id,
            dispatched_widgets_json=json.dumps(dispatched_widgets),
        )
        s.add(ro)
        s.commit()


def _seed_gen_and_install_ops(
    engine, business_id, version_id, *, gen_widgets: dict, install_widgets: dict
) -> None:
    """Attach BOTH a generation op (links via ``output_version_id``) and an
    install op (links via ``parent_version_id``) to ``version_id`` — the
    real One-Catalog shape where the generation op may carry an empty
    schema_prefix and the install op carries the computed ``ecm_``/``mvm_``."""
    with Session(engine) as s:
        run = Run(
            business_id=business_id,
            intent="new-base-model",
            status="succeeded",
            parameters_json="{}",
        )
        s.add(run)
        s.commit()
        s.refresh(run)
        s.add(RunOperation(
            run_id=run.id, step_index=0, operation_name="generate_ecm",
            params_json="{}", status="succeeded",
            output_version_id=version_id,
            dispatched_widgets_json=json.dumps(gen_widgets),
        ))
        s.add(RunOperation(
            run_id=run.id, step_index=1, operation_name="install",
            params_json="{}", status="succeeded",
            parent_version_id=version_id,
            dispatched_widgets_json=json.dumps(install_widgets),
        ))
        s.commit()


# --- /installation-status -------------------------------------------------


def test_status_in_sync_when_all_schemas_present(client, engine, mock_ws):
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id)
    # Physical schemas carry the scope prefix the default "One Catalog"
    # install applies (`ecm_` here) - the bare `database_name` values
    # ("customer", "inventory") are the agent's logical names only.
    _stub_schemas(mock_ws, [
        "ecm_customer", "ecm_inventory", "_metamodel", "information_schema"
    ])

    resp = client.get(f"/api/model-versions/{mv_id}/installation-status")
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["in_sync"] is True
    assert body["lakebase_says_installed"] is True
    assert sorted(body["found_schemas"]) == ["ecm_customer", "ecm_inventory"]
    assert body["missing_schemas"] == []
    assert body["catalog_present"] is True


def test_status_probes_all_domains_no_cap_at_eight(client, engine, mock_ws):
    """Regression for the silent ``_DRIFT_MAX_SCHEMAS_PROBED = 8`` cap: an
    18-domain ECM (matching the live TerraNova aed5ac1a walkthrough, and
    the earlier 12-domain "Legal" model that reported "5 of 8 expected
    schemas") must report all 18 domains as expected, not 8. Only
    installs 15 of the 18 physical schemas so ``missing_schemas`` also
    proves the full set is actually being checked, not just counted."""
    biz_id = _seed_business(engine)
    domains = [f"domain_{i:02d}" for i in range(18)]
    mv_id = _seed_version(engine, biz_id, domains=tuple(domains))
    installed = [f"ecm_{d}" for d in domains[:15]]
    _stub_schemas(mock_ws, installed + ["_metamodel", "information_schema"])

    resp = client.get(f"/api/model-versions/{mv_id}/installation-status")
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert len(body["expected_schemas"]) == 18, (
        f"expected 18 expected_schemas, got {len(body['expected_schemas'])}: "
        f"{body['expected_schemas']!r}"
    )
    assert len(body["found_schemas"]) == 15
    assert len(body["missing_schemas"]) == 3
    assert body["in_sync"] is False


def test_status_in_sync_when_schemas_present_bare_no_prefix(client, engine, mock_ws):
    """Catalog-per-Division/Domain installs leave `schema_prefix` empty -
    the physical schema equals the domain's bare `database_name`. The
    probe must resolve this form too, not just the scope-prefixed one."""
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id)
    _stub_schemas(mock_ws, ["customer", "inventory", "information_schema"])

    resp = client.get(f"/api/model-versions/{mv_id}/installation-status")
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["in_sync"] is True
    assert sorted(body["found_schemas"]) == ["customer", "inventory"]
    assert body["missing_schemas"] == []


def test_status_drift_when_schemas_dropped_externally(client, engine, mock_ws):
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id)
    # Catalog only has system schemas — the model's schemas were dropped
    # externally (DBA, sibling vibe-iterate, etc).
    _stub_schemas(mock_ws, ["_metamodel", "information_schema"])

    resp = client.get(f"/api/model-versions/{mv_id}/installation-status")
    assert resp.status_code == 200
    body = resp.json()
    assert body["in_sync"] is False
    assert body["lakebase_says_installed"] is True
    # Neither form is present - the probe reports the scope-prefixed
    # (default "One Catalog") name as the actionable "expected" name.
    assert sorted(body["missing_schemas"]) == ["ecm_customer", "ecm_inventory"]
    assert body["found_schemas"] == []
    assert body["catalog_present"] is False


def test_status_in_sync_when_lakebase_already_uninstalled(
    client, engine, mock_ws
):
    """If Lakebase already says uninstalled, missing schemas are NOT drift —
    the records agree."""
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id, deployment_status="uninstalled")
    _stub_schemas(mock_ws, ["_metamodel"])

    resp = client.get(f"/api/model-versions/{mv_id}/installation-status")
    body = resp.json()
    assert body["in_sync"] is True
    assert body["lakebase_says_installed"] is False


def test_status_skipped_when_no_catalog_recorded(client, engine, mock_ws):
    """A skipped probe (no catalog to check against) must report
    ``in_sync=None`` — honestly "unknown" — not ``True`` (a false
    "healthy" signal to any caller reading the raw response, e.g. an
    admin tool or a future non-dialog consumer of this endpoint)."""
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id, catalog="")
    _stub_schemas(mock_ws, [])

    resp = client.get(f"/api/model-versions/{mv_id}/installation-status")
    body = resp.json()
    assert body["in_sync"] is None
    assert body["skipped_reason"]


def test_status_skipped_when_listing_fails(client, engine, mock_ws):
    """Same "unknown, not healthy" contract when the catalog listing
    call itself raises — the probe never actually ran."""
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id)
    mock_ws.schemas.list.side_effect = RuntimeError("simulated SDK error")

    resp = client.get(f"/api/model-versions/{mv_id}/installation-status")
    assert resp.status_code == 200
    body = resp.json()
    assert body["in_sync"] is None
    assert "could not list schemas" in body["skipped_reason"]


def test_status_404_for_unknown_version(client, engine):
    resp = client.get(f"/api/model-versions/{uuid4()}/installation-status")
    assert resp.status_code == 404


# --- E-08: drift probe honors the dispatched schema_suffix / prefix -------


def test_status_honors_dispatched_schema_suffix_no_false_drift(
    client, engine, mock_ws
):
    """E-08 regression: a model installed with a ``schema_suffix`` (e.g.
    WT-Scratch's ``_wt``) creates physical schemas like ``ecm_customer_wt``.
    The legacy probe assumed a blank suffix and looked for ``ecm_customer``,
    false-flagging the install as drifted. With the dispatched affixes read
    from ``RunOperation.dispatched_widgets_json``, the ``_wt`` form is a
    candidate and the probe reports in-sync."""
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id)
    _seed_generation_op(
        engine, biz_id, mv_id,
        dispatched_widgets={"schema_prefix": "ecm_", "schema_suffix": "_wt"},
    )
    _stub_schemas(mock_ws, [
        "ecm_customer_wt", "ecm_inventory_wt", "_metamodel", "information_schema"
    ])

    resp = client.get(f"/api/model-versions/{mv_id}/installation-status")
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["in_sync"] is True, body
    assert sorted(body["found_schemas"]) == ["ecm_customer_wt", "ecm_inventory_wt"]
    assert body["missing_schemas"] == []


def test_status_reports_suffixed_name_as_expected_when_missing(
    client, engine, mock_ws
):
    """When none of the forms are present, the probe reports the DISPATCHED
    affixed name (the actionable physical name) as expected/missing — not
    the legacy blank-suffix form."""
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id)
    _seed_generation_op(
        engine, biz_id, mv_id,
        dispatched_widgets={"schema_prefix": "ecm_", "schema_suffix": "_wt"},
    )
    _stub_schemas(mock_ws, ["_metamodel", "information_schema"])

    resp = client.get(f"/api/model-versions/{mv_id}/installation-status")
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["in_sync"] is False
    assert sorted(body["missing_schemas"]) == ["ecm_customer_wt", "ecm_inventory_wt"]
    assert body["found_schemas"] == []


def test_status_honors_dispatched_non_default_prefix(client, engine, mock_ws):
    """A dispatched ``schema_prefix`` that isn't the scope default is still
    resolved — the probe reads the actual prefix the agent was handed."""
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id)
    _seed_generation_op(
        engine, biz_id, mv_id,
        dispatched_widgets={"schema_prefix": "wt_", "schema_suffix": ""},
    )
    _stub_schemas(mock_ws, ["wt_customer", "wt_inventory", "_metamodel"])

    resp = client.get(f"/api/model-versions/{mv_id}/installation-status")
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["in_sync"] is True, body
    assert sorted(body["found_schemas"]) == ["wt_customer", "wt_inventory"]


def test_status_default_expected_prefers_install_prefix_over_empty_gen_prefix(
    client, engine, mock_ws
):
    """Reviewer follow-up: a One-Catalog model links a generation op (which
    may carry an empty schema_prefix) AND an install op (the computed
    ``ecm_``). When ALL schemas are missing, the reconcile dialog must
    report the actionable ``ecm_``-prefixed name — not the bare
    ``customer`` that row-order (``disp_prefixes[0]``) would surface."""
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id)
    _seed_gen_and_install_ops(
        engine, biz_id, mv_id,
        gen_widgets={"schema_prefix": "", "schema_suffix": ""},
        install_widgets={"schema_prefix": "ecm_"},
    )
    _stub_schemas(mock_ws, ["_metamodel", "information_schema"])

    resp = client.get(f"/api/model-versions/{mv_id}/installation-status")
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["in_sync"] is False
    assert sorted(body["missing_schemas"]) == ["ecm_customer", "ecm_inventory"], (
        "all-missing case must report the install op's ecm_ prefix, not the "
        "generation op's empty-prefix bare name"
    )
    assert body["found_schemas"] == []


def test_status_falls_back_to_legacy_when_no_dispatched_widgets(
    client, engine, mock_ws
):
    """Graceful fallback: a version with NO dispatched_widgets_json
    (pre-E-03 installs) must degrade to the legacy scope-prefixed + bare
    probing rather than crash or false-flag — the currently-working cases
    are preserved."""
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id)
    # RunOperation exists but carries the default empty audit blob.
    _seed_generation_op(engine, biz_id, mv_id, dispatched_widgets={})
    _stub_schemas(mock_ws, ["ecm_customer", "ecm_inventory", "_metamodel"])

    resp = client.get(f"/api/model-versions/{mv_id}/installation-status")
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["in_sync"] is True
    assert sorted(body["found_schemas"]) == ["ecm_customer", "ecm_inventory"]


# --- /reconcile-installation ----------------------------------------------


def test_reconcile_marks_uninstalled_when_catalog_empty(
    client_with_agent, engine, mock_ws
):
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id)
    _stub_schemas(mock_ws, ["_metamodel"])

    resp = client_with_agent.post(
        f"/api/model-versions/{mv_id}/reconcile-installation"
    )
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["previous_deployment_status"] == "deployed"
    assert body["new_deployment_status"] == "uninstalled"
    assert body["schemas_present"] == []

    with Session(engine) as s:
        mv = s.get(ModelVersion, mv_id)
        assert mv.deployment_status == "uninstalled"


def test_reconcile_keeps_deployed_when_some_schemas_present(
    client_with_agent, engine, mock_ws
):
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id)
    # Half the schemas present
    _stub_schemas(mock_ws, ["ecm_customer", "_metamodel"])

    resp = client_with_agent.post(
        f"/api/model-versions/{mv_id}/reconcile-installation"
    )
    body = resp.json()
    assert body["new_deployment_status"] == "deployed"
    assert body["schemas_present"] == ["ecm_customer"]
    assert body["schemas_missing"] == ["ecm_inventory"]  # neither form present -> prefixed fallback


def test_reconcile_marks_deployed_when_lakebase_was_uninstalled(
    client_with_agent, engine, mock_ws
):
    """User dropped a schema externally then re-installed externally —
    Lakebase is now stale in the OTHER direction."""
    biz_id = _seed_business(engine)
    mv_id = _seed_version(
        engine, biz_id, deployment_status="uninstalled"
    )
    _stub_schemas(mock_ws, ["ecm_customer", "ecm_inventory"])

    resp = client_with_agent.post(
        f"/api/model-versions/{mv_id}/reconcile-installation"
    )
    body = resp.json()
    assert body["previous_deployment_status"] == "uninstalled"
    assert body["new_deployment_status"] == "deployed"


def test_reconcile_marks_deployed_for_iterate_born_draft_version_after_install(
    client_with_agent, engine, mock_ws
):
    """Regression companion to the vibe_iterate finalize fix. An
    iterate-produced version is now correctly born ``deployment_status=
    "draft"`` (it never inline-installs to UC, see
    ``services/operations/vibe_iterate.py``). That must not regress the
    legitimate path where the version *is* later installed for real: once
    an explicit ``install`` run has actually created the schemas, the
    drift reconciler still flips the still-"draft" Lakebase row to
    "deployed" to match reality, the same mechanism that already
    upgrades a stale "uninstalled" row (see
    ``test_reconcile_marks_deployed_when_lakebase_was_uninstalled``)."""
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id, deployment_status="draft")
    _stub_schemas(mock_ws, ["ecm_customer", "ecm_inventory"])

    resp = client_with_agent.post(
        f"/api/model-versions/{mv_id}/reconcile-installation"
    )
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["previous_deployment_status"] == "draft"
    assert body["new_deployment_status"] == "deployed"


def test_reconcile_502_when_listing_fails(
    client_with_agent, engine, mock_ws
):
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id)
    mock_ws.schemas.list.side_effect = RuntimeError("simulated SDK error")

    resp = client_with_agent.post(
        f"/api/model-versions/{mv_id}/reconcile-installation"
    )
    assert resp.status_code == 502


# --- Uninstall primitive flips Lakebase deployment_status -----------------


def _job_run(*, lcs="TERMINATED", rs="SUCCESS", msg=""):
    return SimpleNamespace(
        state=SimpleNamespace(
            life_cycle_state=SimpleNamespace(value=lcs),
            result_state=SimpleNamespace(value=rs),
            state_message=msg,
        ),
    )


def test_uninstall_observe_marks_version_uninstalled_on_success(engine):
    """Regression for the "phantom Installed" bug: after a successful
    uninstall via the orchestrator, the ModelVersion row must read
    ``deployment_status='uninstalled'`` so the UI badge updates."""
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id, scope="mvm")

    ws = MagicMock()
    ws.jobs.get_run.return_value = _job_run()

    handle = OperationDispatchHandle(
        databricks_run_id=42, vibe_session_id="sess-1"
    )
    ctx = OperationContext(
        run_id="run-x",
        operation_id="op-x",
        business_id=biz_id,
        parent_version_id=mv_id,
        params={
            "business_name": "drift_biz",
            "deployment_catalog": "vibe_modeling_test",
            "schema_prefix": "",
            "scope": "mvm",
            "model_version": 1,
            "cataloging_style": "One Catalog",
            "version_id": mv_id,
        },
        inherited_params={},
    )

    with Session(engine) as session:
        op = Uninstall()
        obs = op.observe(handle, ctx, ws, session)
        session.commit()

    assert obs.is_terminal is True
    assert obs.terminal_result.succeeded is True

    with Session(engine) as session:
        mv = session.get(ModelVersion, mv_id)
        assert mv.deployment_status == "uninstalled"


def test_uninstall_observe_no_op_when_version_id_missing(engine):
    """Old DAGs that don't pass ``version_id`` (back-compat) must not
    crash — they just skip the metadata update."""
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id, scope="mvm")

    ws = MagicMock()
    ws.jobs.get_run.return_value = _job_run()

    handle = OperationDispatchHandle(
        databricks_run_id=42, vibe_session_id="sess-1"
    )
    ctx = OperationContext(
        run_id="run-x",
        operation_id="op-x",
        business_id=biz_id,
        parent_version_id=mv_id,
        params={
            "business_name": "drift_biz",
            "deployment_catalog": "vibe_modeling_test",
            "schema_prefix": "",
            "scope": "mvm",
            "model_version": 1,
            "cataloging_style": "One Catalog",
            # version_id intentionally absent
        },
        inherited_params={},
    )

    with Session(engine) as session:
        op = Uninstall()
        obs = op.observe(handle, ctx, ws, session)

    assert obs.is_terminal is True
    assert obs.terminal_result.succeeded is True
    # Lakebase row UNCHANGED — old DAG, no metadata write.
    with Session(engine) as session:
        mv = session.get(ModelVersion, mv_id)
        assert mv.deployment_status == "deployed"


def test_uninstall_observe_does_not_flip_on_failure(engine):
    biz_id = _seed_business(engine)
    mv_id = _seed_version(engine, biz_id, scope="mvm")

    ws = MagicMock()
    ws.jobs.get_run.return_value = _job_run(rs="FAILED", msg="boom")

    handle = OperationDispatchHandle(
        databricks_run_id=42, vibe_session_id="sess-1"
    )
    ctx = OperationContext(
        run_id="run-x",
        operation_id="op-x",
        business_id=biz_id,
        parent_version_id=mv_id,
        params={
            "business_name": "drift_biz",
            "deployment_catalog": "vibe_modeling_test",
            "schema_prefix": "",
            "scope": "mvm",
            "model_version": 1,
            "cataloging_style": "One Catalog",
            "version_id": mv_id,
        },
        inherited_params={},
    )

    with Session(engine) as session:
        op = Uninstall()
        obs = op.observe(handle, ctx, ws, session)

    assert obs.is_terminal is True
    assert obs.terminal_result.succeeded is False
    with Session(engine) as session:
        mv = session.get(ModelVersion, mv_id)
        assert mv.deployment_status == "deployed"  # unchanged on failure
