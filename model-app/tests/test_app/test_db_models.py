"""Test Lakebase database models — schema structure and load-bearing defaults.

Trimmed: tautological default-value / __tablename__ / FK-declaration tests
removed (Pydantic + SQLModel guarantee these). What remains targets:

- The schema-creation surface (all expected tables, all FK constraints) — would
  catch a missed migration / accidental table rename.
- BIGINT widening for `vibe_session_id_bigint` — real bug class (overflow).
- `intent` and `last_consumed_step_id` defaults — directly read by the
  orchestrator wiring.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from vibe_modeling.backend import db_models as db
from vibe_modeling.backend.db_models import Run


class TestRunDefaults:
    def test_intent_default(self):
        r = Run(business_id="fake-id")
        assert r.intent == ""

    def test_last_consumed_step_id_default(self):
        r = Run(business_id="fake-id")
        assert r.last_consumed_step_id == 0

    def test_vibe_session_id_bigint_widening(self):
        # vibe_session_id_bigint must accept values that overflow INT4.
        big = 2**40  # well above 2_147_483_647
        r = Run(business_id="fake-id", vibe_session_id="sid", vibe_session_id_bigint=big)
        assert r.vibe_session_id_bigint == big


class TestDatabaseSchema:
    def test_all_tables_created(self, engine):
        from sqlalchemy import inspect as sa_inspect
        insp = sa_inspect(engine)
        tables = insp.get_table_names()
        expected = [
            "businesses", "business_contexts", "agent_config",
            "model_versions", "runs", "run_artifacts", "run_progress_events",
            "domains", "products", "attributes", "foreign_key_links",
            # Vibe Inputs redesign (Task 2)
            "vibe_inputs", "vibe_input_context_links", "run_input_links",
            "subdomains", "product_reviews",
            # Vibe Inputs redesign (Task 4) — element rename/merge/delete lineage
            "run_element_lineage",
        ]
        for table in expected:
            assert table in tables, f"Table '{table}' not created"

    def test_foreign_key_constraints(self, engine):
        from sqlalchemy import inspect as sa_inspect
        insp = sa_inspect(engine)
        assert "businesses" in {fk["referred_table"] for fk in insp.get_foreign_keys("business_contexts")}
        assert "businesses" in {fk["referred_table"] for fk in insp.get_foreign_keys("runs")}
        assert "runs" in {fk["referred_table"] for fk in insp.get_foreign_keys("run_artifacts")}
        assert "runs" in {fk["referred_table"] for fk in insp.get_foreign_keys("run_progress_events")}
        assert "model_versions" in {fk["referred_table"] for fk in insp.get_foreign_keys("domains")}
        assert "domains" in {fk["referred_table"] for fk in insp.get_foreign_keys("products")}
        assert "products" in {fk["referred_table"] for fk in insp.get_foreign_keys("attributes")}
        assert "model_versions" in {fk["referred_table"] for fk in insp.get_foreign_keys("foreign_key_links")}

    def test_vibe_input_foreign_keys(self, engine):
        from sqlalchemy import inspect as sa_inspect
        insp = sa_inspect(engine)
        assert "businesses" in {fk["referred_table"] for fk in insp.get_foreign_keys("vibe_inputs")}

        ctx_referred = {fk["referred_table"] for fk in insp.get_foreign_keys("vibe_input_context_links")}
        for t in ("vibe_inputs", "model_versions", "domains", "subdomains",
                  "products", "attributes", "foreign_key_links"):
            assert t in ctx_referred, f"vibe_input_context_links missing FK→{t}"

        link_referred = {fk["referred_table"] for fk in insp.get_foreign_keys("run_input_links")}
        assert "runs" in link_referred
        assert "vibe_inputs" in link_referred

        sub_referred = {fk["referred_table"] for fk in insp.get_foreign_keys("subdomains")}
        assert "model_versions" in sub_referred
        assert "domains" in sub_referred

        rev_referred = {fk["referred_table"] for fk in insp.get_foreign_keys("product_reviews")}
        assert "model_versions" in rev_referred
        assert "products" in rev_referred

        assert "subdomains" in {fk["referred_table"] for fk in insp.get_foreign_keys("products")}

    def test_self_fk_previous_element_id(self, engine):
        from sqlalchemy import inspect as sa_inspect
        insp = sa_inspect(engine)
        for table in ("domains", "products", "attributes", "foreign_key_links", "subdomains"):
            referred = {fk["referred_table"] for fk in insp.get_foreign_keys(table)}
            assert table in referred, (
                f"{table}.previous_element_id self-FK→{table} missing"
            )


class TestRunElementLineageSchema:
    """Task 4 — the rename/merge/delete edge table."""

    def test_foreign_keys(self, engine):
        from sqlalchemy import inspect as sa_inspect
        insp = sa_inspect(engine)
        referred = {fk["referred_table"] for fk in insp.get_foreign_keys("run_element_lineage")}
        assert "runs" in referred
        assert "model_versions" in referred

    def test_defaults(self):
        row = db.RunElementLineage(
            run_id="run-1",
            version_id="ver-1",
            element_type="product",
            change_kind="delete",
            old_element_id="old-1",
            old_fqn="legacy.thing",
        )
        assert row.new_element_id is None
        assert row.new_fqn == ""
        assert row.reason == ""

    def test_nullable_element_ids(self):
        cols = db.RunElementLineage.__table__.c
        assert cols.old_element_id.nullable is True
        assert cols.new_element_id.nullable is True


class TestVibeInputDefaults:
    def test_defaults(self):
        v = db.VibeInput(business_id="biz-1")
        assert v.origin == "user"
        assert v.author == ""
        assert v.priority == "medium"
        assert v.consumed is False
        assert v.selected_for_run is False
        assert v.status == "active"
        assert v.deprecated_by is None
        assert v.confidence_score is None
        assert v.category is None


class TestVibeInputNullability:
    """N2: lock the nullability flag on every column this task adds, so a
    future accidental NOT NULL (or dropped NULL) is caught at the schema layer."""

    def test_vibe_input_nullable_columns(self):
        cols = db.VibeInput.__table__.c
        assert cols.deprecated_by.nullable is True
        assert cols.confidence_score.nullable is True
        # category is nullable — null for origin=user inputs (v_0_6_3).
        assert cols.category.nullable is True
        # author is NOT NULL with an empty-string default.
        assert cols.author.nullable is False
        assert db.VibeInput(business_id="biz-1").author == ""
        # selected_for_run is NOT NULL with a False default (run-selection flag).
        assert cols.selected_for_run.nullable is False
        assert db.VibeInput(business_id="biz-1").selected_for_run is False

    def test_previous_element_id_nullable(self):
        for model in (db.Domain, db.Product, db.Attribute, db.ForeignKeyLink, db.Subdomain):
            assert model.__table__.c.previous_element_id.nullable is True, (
                f"{model.__name__}.previous_element_id must be nullable"
            )

    def test_product_subdomain_id_nullable(self):
        assert db.Product.__table__.c.subdomain_id.nullable is True


class TestRunInputLinkCompositePK:
    def test_composite_pk(self):
        pk_cols = {c.name for c in db.RunInputLink.__table__.primary_key.columns}
        assert pk_cols == {"run_id", "input_id"}


class TestVibeInputContextLinkModelWide:
    """Edge case 1: an all-element-null context link (model-wide anchor) is a
    valid, persistable row."""

    def test_all_null_element_fks_persist_and_read_back(self, engine):
        from sqlmodel import Session, select

        with Session(engine) as session:
            biz = db.Business(name="ctx-biz")
            session.add(biz)
            session.commit()
            session.refresh(biz)

            mv = db.ModelVersion(business_id=biz.id)
            session.add(mv)
            session.commit()
            session.refresh(mv)

            vi = db.VibeInput(business_id=biz.id)
            session.add(vi)
            session.commit()
            session.refresh(vi)

            link = db.VibeInputContextLink(input_id=vi.id, version_id=mv.id)
            session.add(link)
            session.commit()

            got = session.exec(
                select(db.VibeInputContextLink).where(
                    db.VibeInputContextLink.input_id == vi.id
                )
            ).one()
            assert got.domain_id is None
            assert got.subdomain_id is None
            assert got.product_id is None
            assert got.attribute_id is None
            assert got.fk_link_id is None
            assert got.is_origin is False
            assert got.needs_link_review is False


class TestModelVersionProvenanceColumns:
    """v_0_7_0: nullable agent_version / release_version persist + read back,
    default NULL for pre-existing rows."""

    def test_defaults_null(self):
        mv = db.ModelVersion(business_id="fake-id")
        assert mv.agent_version is None
        assert mv.release_version is None

    def test_persist_and_read_back(self, engine):
        from sqlmodel import Session, select

        with Session(engine) as session:
            biz = db.Business(name="prov-biz")
            session.add(biz)
            session.flush()
            mv = db.ModelVersion(
                business_id=biz.id,
                version=1,
                agent_version="4.9.8",
                release_version="0.8.0",
            )
            session.add(mv)
            session.commit()
            mv_id = mv.id

        with Session(engine) as session:
            got = session.exec(
                select(db.ModelVersion).where(db.ModelVersion.id == mv_id)
            ).one()
            assert got.agent_version == "4.9.8"
            assert got.release_version == "0.8.0"

    def test_columns_present_on_table(self):
        cols = {c.name for c in db.ModelVersion.__table__.columns}
        assert {"agent_version", "release_version"} <= cols
