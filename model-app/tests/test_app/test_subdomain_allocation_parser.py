"""Tests for the agent's ``Subdomain Allocation`` ``stage_succeeded``
event parser.

Contract from ``tests/test_app/fixtures/progress_subdomain_allocation.json``::

    parser_predicate_primary:
        stage_name == "Subdomain Allocation" AND status == "stage_succeeded"
    parser_predicate_hardening:
        result_json["subdomains_by_domain"] is a non-empty dict

When fired, the parser walks ``subdomains_by_domain`` and stamps
``Product.subdomain`` on every Product row in the run's ModelVersion
that matches by ``(Domain.name, Product.name)``.
"""

from __future__ import annotations

import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

import pytest
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)

from vibe_modeling.backend.db_models import (
    Business,
    Domain,
    ModelVersion,
    Product,
    Run,
    RunOperation,
)
from vibe_modeling.backend.progress_tracker import ProgressEvent
from vibe_modeling.backend.subdomain_allocation_parser import (
    STAGE_NAME,
    STATUS_NAME,
    apply_subdomain_allocation,
    is_subdomain_allocation_event,
)


FIXTURE_PATH = (
    Path(__file__).parent / "fixtures" / "progress_subdomain_allocation.json"
)


@pytest.fixture
def fixture_event() -> dict:
    with FIXTURE_PATH.open() as f:
        return json.load(f)


@pytest.fixture
def engine():
    eng = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(eng)
    return eng


@pytest.fixture
def seed_business(engine) -> str:
    with Session(engine) as s:
        b = Business(name="test eCommerce", description="x", industry_alignment="Retail")
        s.add(b)
        s.commit()
        s.refresh(b)
        return b.id


def _make_event_from_fixture(fx: dict) -> ProgressEvent:
    return ProgressEvent(
        step_id=1700000000000,
        event_seq=99,
        stage_name=fx["stage_name"],
        step_name=fx["step_name"],
        status=fx["status"],
        message=fx["message"],
        progress_increment=fx["progress_increment"],
        result_json=dict(fx["result_json"]),
    )


def _seed_run_mv_products(
    engine,
    business_id: str,
    *,
    products_by_domain: dict[str, list[str]],
    mv_scope: str = "ecm",
    mv_version: int = 1,
) -> tuple[str, str]:
    """Seed a Run + ModelVersion + Domains + Products for the given
    ``{domain_name: [product_name, ...]}`` map. Returns (run_id, mv_id)."""
    with Session(engine) as s:
        run = Run(
            business_id=business_id,
            intent="new-base-model",
            status="running",
            databricks_run_id=42,
            vibe_session_id="sid",
            parameters_json="{}",
            started_at=datetime.now(timezone.utc),
        )
        s.add(run)
        s.flush()
        s.add(RunOperation(
            run_id=run.id,
            step_index=0,
            operation_name="generate_ecm",
            params_json="{}",
            status="running",
        ))
        mv = ModelVersion(
            business_id=business_id,
            version=mv_version,
            scope=mv_scope,
            status="completed",
        )
        s.add(mv)
        s.flush()
        run.version_id = mv.id
        s.add(run)

        for dname, products in products_by_domain.items():
            d = Domain(version_id=mv.id, name=dname)
            s.add(d)
            s.flush()
            for pname in products:
                p = Product(
                    domain_id=d.id,
                    version_id=mv.id,
                    name=pname,
                    table_name=pname,
                )
                s.add(p)
        s.commit()
        return run.id, mv.id


# ---------------------------------------------------------------------------
# Predicate
# ---------------------------------------------------------------------------


class TestPredicate:
    """``is_subdomain_allocation_event`` — keys on (stage, status, payload)."""

    def test_canonical_fixture_matches(self, fixture_event):
        assert is_subdomain_allocation_event(
            fixture_event["stage_name"],
            fixture_event["status"],
            fixture_event["result_json"],
        )

    def test_alternate_step_name_still_matches(self, fixture_event):
        # Agent v0.7.0 emits "Allocating Subdomains" from inner loop and
        # "Allocate Subdomains" from outer orchestrator. Parser ignores step.
        rj = dict(fixture_event["result_json"])
        assert is_subdomain_allocation_event(STAGE_NAME, STATUS_NAME, rj)

    def test_wrong_stage_does_not_match(self, fixture_event):
        assert not is_subdomain_allocation_event(
            "Designing Domains",
            STATUS_NAME,
            fixture_event["result_json"],
        )

    def test_wrong_status_does_not_match(self, fixture_event):
        assert not is_subdomain_allocation_event(
            STAGE_NAME,
            "stage_started",
            fixture_event["result_json"],
        )

    def test_warning_status_does_not_match(self, fixture_event):
        assert not is_subdomain_allocation_event(
            STAGE_NAME,
            "stage_warning",
            fixture_event["result_json"],
        )

    def test_none_result_json_does_not_match(self):
        assert not is_subdomain_allocation_event(
            STAGE_NAME, STATUS_NAME, None,
        )

    def test_missing_subdomains_by_domain_does_not_match(self):
        assert not is_subdomain_allocation_event(
            STAGE_NAME, STATUS_NAME, {"unique_subdomains": 5},
        )

    def test_empty_subdomains_by_domain_does_not_match(self):
        assert not is_subdomain_allocation_event(
            STAGE_NAME, STATUS_NAME, {"subdomains_by_domain": {}},
        )

    def test_non_dict_subdomains_by_domain_does_not_match(self):
        assert not is_subdomain_allocation_event(
            STAGE_NAME, STATUS_NAME, {"subdomains_by_domain": "not a dict"},
        )


# ---------------------------------------------------------------------------
# Apply
# ---------------------------------------------------------------------------


class TestApplySubdomainAllocation:
    """Atomic apply path: matching Product rows get ``Product.subdomain``
    stamped from the event payload."""

    def test_well_formed_event_populates_subdomain(
        self, engine, seed_business, fixture_event,
    ):
        run_id, mv_id = _seed_run_mv_products(
            engine, seed_business,
            products_by_domain={
                "party": ["individual", "organization", "loyalty_enrollment"],
                "billing": ["invoice", "invoice_line", "payment"],
            },
        )
        ev = _make_event_from_fixture(fixture_event)
        with Session(engine) as s:
            run = s.get(Run, run_id)
            apply_subdomain_allocation(s, run, ev)
            s.commit()

        with Session(engine) as s:
            products = s.exec(
                select(Product).where(Product.version_id == mv_id)
            ).all()
            by_name = {p.name: p.subdomain for p in products}
            assert by_name == {
                "individual": "identity",
                "organization": "identity",
                "loyalty_enrollment": "engagement",
                "invoice": "invoicing",
                "invoice_line": "invoicing",
                "payment": "settlement",
            }
            # Derive unique-subdomain count read-time (no new column).
            unique = {p.subdomain for p in products if p.subdomain}
            assert len(unique) == 4

    def test_missing_products_in_db_warns_and_does_not_crash(
        self, engine, seed_business, fixture_event,
    ):
        # Payload references ``payment`` but the DB only has ``invoice``.
        run_id, mv_id = _seed_run_mv_products(
            engine, seed_business,
            products_by_domain={
                "party": ["individual"],
                "billing": ["invoice"],
            },
        )
        ev = _make_event_from_fixture(fixture_event)
        with Session(engine) as s:
            run = s.get(Run, run_id)
            apply_subdomain_allocation(s, run, ev)
            s.commit()

        with Session(engine) as s:
            products = s.exec(
                select(Product).where(Product.version_id == mv_id)
            ).all()
            # The two products that DO exist get stamped; missing ones
            # are silently skipped (counted as unmatched_payload in logs).
            by_name = {p.name: p.subdomain for p in products}
            assert by_name == {
                "individual": "identity",
                "invoice": "invoicing",
            }

    def test_malformed_result_json_warns_and_does_not_crash(
        self, engine, seed_business,
    ):
        run_id, mv_id = _seed_run_mv_products(
            engine, seed_business,
            products_by_domain={"party": ["individual"]},
        )
        # Predicate-failing payloads: missing key, wrong type.
        bad_events = [
            ProgressEvent(
                step_id=1, event_seq=1,
                stage_name=STAGE_NAME, step_name="x", status=STATUS_NAME,
                message="x", progress_increment=0.0,
                result_json={"unique_subdomains": 5},
            ),
            ProgressEvent(
                step_id=1, event_seq=1,
                stage_name=STAGE_NAME, step_name="x", status=STATUS_NAME,
                message="x", progress_increment=0.0,
                result_json={"subdomains_by_domain": "not_a_dict"},
            ),
            ProgressEvent(
                step_id=1, event_seq=1,
                stage_name=STAGE_NAME, step_name="x", status=STATUS_NAME,
                message="x", progress_increment=0.0,
                result_json=None,
            ),
        ]
        for ev in bad_events:
            with Session(engine) as s:
                run = s.get(Run, run_id)
                # Must not crash, must not fail the run.
                apply_subdomain_allocation(s, run, ev)
                s.commit()

        with Session(engine) as s:
            products = s.exec(
                select(Product).where(Product.version_id == mv_id)
            ).all()
            # Nothing was stamped.
            assert all(p.subdomain == "" for p in products)
            assert s.get(Run, run_id).status == "running"  # not failed

    def test_partial_payload_shape_is_resilient(
        self, engine, seed_business,
    ):
        """Inner shape errors (a domain mapping a non-dict, a subdomain mapping
        a non-list) must be skipped without crashing, with the rest applied."""
        run_id, mv_id = _seed_run_mv_products(
            engine, seed_business,
            products_by_domain={
                "party": ["individual"],
                "billing": ["invoice"],
            },
        )
        ev = ProgressEvent(
            step_id=1, event_seq=1,
            stage_name=STAGE_NAME, step_name="x", status=STATUS_NAME,
            message="x", progress_increment=0.0,
            result_json={
                "unique_subdomains": 2,
                "subdomains_by_domain": {
                    "party": {"identity": ["individual"]},
                    "billing": "junk_string_instead_of_dict",
                    "ghost_domain": {"x": "not_a_list"},
                },
            },
        )
        with Session(engine) as s:
            run = s.get(Run, run_id)
            apply_subdomain_allocation(s, run, ev)
            s.commit()

        with Session(engine) as s:
            products = s.exec(
                select(Product).where(Product.version_id == mv_id)
            ).all()
            by_name = {p.name: p.subdomain for p in products}
            assert by_name == {
                "individual": "identity",
                "invoice": "",  # billing payload was malformed → skipped
            }

    def test_refire_is_idempotent(self, engine, seed_business, fixture_event):
        run_id, mv_id = _seed_run_mv_products(
            engine, seed_business,
            products_by_domain={
                "party": ["individual", "organization", "loyalty_enrollment"],
                "billing": ["invoice", "invoice_line", "payment"],
            },
        )
        ev = _make_event_from_fixture(fixture_event)
        # Fire twice; second fire must be a no-op (same string).
        for _ in range(2):
            with Session(engine) as s:
                run = s.get(Run, run_id)
                apply_subdomain_allocation(s, run, ev)
                s.commit()

        with Session(engine) as s:
            products = s.exec(
                select(Product).where(Product.version_id == mv_id)
            ).all()
            by_name = {p.name: p.subdomain for p in products}
            assert by_name == {
                "individual": "identity",
                "organization": "identity",
                "loyalty_enrollment": "engagement",
                "invoice": "invoicing",
                "invoice_line": "invoicing",
                "payment": "settlement",
            }

    def test_deferred_when_mv_not_yet_created(
        self, engine, seed_business, fixture_event,
    ):
        """Event fires before observe creates the MV row. Parser must
        return cleanly without crashing — ModelSyncService will hydrate
        Product.subdomain from model.json on success."""
        with Session(engine) as s:
            run = Run(
                business_id=seed_business,
                intent="new-base-model",
                status="running",
                databricks_run_id=42,
                vibe_session_id="sid",
                parameters_json="{}",
                started_at=datetime.now(timezone.utc),
            )
            s.add(run)
            s.flush()
            s.add(RunOperation(
                run_id=run.id, step_index=0,
                operation_name="generate_ecm",
                params_json="{}", status="running",
            ))
            s.commit()
            run_id = run.id

        ev = _make_event_from_fixture(fixture_event)
        with Session(engine) as s:
            run = s.get(Run, run_id)
            apply_subdomain_allocation(s, run, ev)
            s.commit()

        with Session(engine) as s:
            assert s.get(Run, run_id).status == "running"

    def test_mv_with_no_domains_is_deferred(
        self, engine, seed_business, fixture_event,
    ):
        """MV row exists but Domain rows not yet created (model_sync still
        in flight). Parser must early-return without touching state."""
        with Session(engine) as s:
            run = Run(
                business_id=seed_business,
                intent="new-base-model",
                status="running",
                databricks_run_id=42,
                vibe_session_id="sid",
                parameters_json="{}",
                started_at=datetime.now(timezone.utc),
            )
            s.add(run)
            s.flush()
            s.add(RunOperation(
                run_id=run.id, step_index=0,
                operation_name="generate_ecm",
                params_json="{}", status="running",
            ))
            mv = ModelVersion(
                business_id=seed_business, version=1, scope="ecm",
                status="completed",
            )
            s.add(mv)
            s.flush()
            run.version_id = mv.id
            s.add(run)
            s.commit()
            run_id = run.id

        ev = _make_event_from_fixture(fixture_event)
        with Session(engine) as s:
            run = s.get(Run, run_id)
            apply_subdomain_allocation(s, run, ev)
            s.commit()

        with Session(engine) as s:
            assert s.get(Run, run_id).status == "running"
