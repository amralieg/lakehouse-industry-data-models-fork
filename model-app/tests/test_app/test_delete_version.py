"""Tests for ``DELETE /businesses/{business_id}/versions/{version_id}``.

The route is operation_id ``deleteVersion``. Its primary semantic is
"delete this version"; the legacy revert (uninstall → install previous)
is a follow-up opt-in via ``?reinstall_previous=true``.

Covers:
  - latest imported ECM v2 with no flag → 200, cascade rows gone,
    no orchestrator dispatch
  - latest deployed MVM v3 with reinstall_previous=true → version gone,
    orchestrator dispatched with uninstall→install DAG
  - reinstall_previous=true but no prior version → 400
  - reinstall_previous=true on a version with no uc_catalog → 400
  - non-latest in its scope → 400
  - cross-scope sanity: deleting ECM v1 while MVM v1 exists succeeds
"""

from __future__ import annotations

import os
import sys

sys.path.insert(
    0,
    os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"),
)

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    DiagramLayout,
    Domain,
    ForeignKeyLink,
    ModelVersion,
    Product,
    Run,
    RunArtifact,
)


def _seed_business_with_two_scoped_versions(
    engine,
    *,
    scope: str = "ecm",
    latest_deployed: bool = False,
    latest_imported: bool = False,
    latest_uc_catalog: str = "cat_a",
) -> tuple[str, dict[int, str]]:
    """Seed a Business + two same-scope ModelVersions (v1 + v2).

    Adds structure rows on v2 so the cascade has something to clean.
    """
    with Session(engine) as s:
        b = Business(
            name="delete_corp",
            description="t",
            industry_alignment="Retail",
        )
        s.add(b)
        s.flush()
        biz_id = b.id

        v_ids: dict[int, str] = {}
        for n in (1, 2):
            kwargs: dict = dict(
                business_id=biz_id,
                version=n,
                status="completed",
                scope=scope,
                uc_catalog=latest_uc_catalog if n == 2 else "cat_a",
                deployment_status=(
                    "deployed" if n == 2 and latest_deployed else "uninstalled"
                ),
            )
            if n == 2 and latest_imported:
                # Imports record source path + clear the catalog (route
                # accepts no catalog as "never installed").
                kwargs["uc_catalog"] = ""
                kwargs["import_source_path"] = (
                    "/Volumes/cat_a/_metamodel/vol_root/business/delete_corp/v2_ecm/model.json"
                )
                kwargs["deployment_status"] = "draft"
            mv = ModelVersion(**kwargs)
            s.add(mv)
            s.flush()
            v_ids[n] = mv.id

        # Structure rows + a layout + an artifact on v2 so we can prove
        # cascade actually fires.
        d = Domain(version_id=v_ids[2], name="dom_x", database_name="dom_x_v2")
        s.add(d)
        s.flush()
        p = Product(domain_id=d.id, version_id=v_ids[2], name="prod_x")
        s.add(p)
        s.flush()
        a = Attribute(product_id=p.id, name="col_x")
        s.add(a)
        fkl = ForeignKeyLink(
            version_id=v_ids[2],
            source_domain="dom_x", source_product="prod_x", source_column="col_x",
            target_domain="dom_x", target_product="prod_x", target_column="col_x",
        )
        s.add(fkl)
        dl = DiagramLayout(
            business_id=biz_id, version_id=v_ids[2],
            cache_key="k", layout_json="{}",
        )
        s.add(dl)
        ra = RunArtifact(
            run_id=None, model_version_id=v_ids[2],
            artifact_type="json", file_path="x.json",
        )
        s.add(ra)
        s.commit()

    return biz_id, v_ids


def _count_structure_rows(engine, version_id: str) -> dict[str, int]:
    with Session(engine) as s:
        domains = list(s.exec(select(Domain).where(Domain.version_id == version_id)).all())
        product_count = 0
        attr_count = 0
        for d in domains:
            prods = list(s.exec(select(Product).where(Product.domain_id == d.id)).all())
            product_count += len(prods)
            for p in prods:
                attrs = list(
                    s.exec(select(Attribute).where(Attribute.product_id == p.id)).all()
                )
                attr_count += len(attrs)
        return {
            "domains": len(domains),
            "products": product_count,
            "attributes": attr_count,
            "fk_links": len(list(
                s.exec(select(ForeignKeyLink).where(ForeignKeyLink.version_id == version_id)).all()
            )),
            "layouts": len(list(
                s.exec(select(DiagramLayout).where(DiagramLayout.version_id == version_id)).all()
            )),
            "artifacts": len(list(
                s.exec(select(RunArtifact).where(RunArtifact.model_version_id == version_id)).all()
            )),
        }


class TestDeleteVersionDefault:
    """Default path: no ?reinstall_previous flag."""

    def test_delete_latest_imported_ecm_succeeds_no_orchestrator(
        self, fk_engine, fk_client
    ):
        # Runs under FK enforcement: the element tree, layout, and artifact all
        # die via the DB ``version_id`` ON DELETE CASCADE when the version row
        # goes.
        biz_id, v_ids = _seed_business_with_two_scoped_versions(
            fk_engine, scope="ecm", latest_imported=True
        )

        r = fk_client.delete(
            f"/api/businesses/{biz_id}/versions/{v_ids[2]}"
        )
        assert r.status_code == 200, r.text
        body = r.json()
        assert body["deleted_version"] == 2
        assert body["previous_version"] == 1
        # run_id None + reinstall_dispatched False is the observable proof that
        # no orchestrator DAG was dispatched on the default delete path.
        assert body["run_id"] is None
        assert body["reinstall_dispatched"] is False

        # Cascade rows gone.
        rows = _count_structure_rows(fk_engine, v_ids[2])
        assert rows == {
            "domains": 0, "products": 0, "attributes": 0,
            "fk_links": 0, "layouts": 0, "artifacts": 0,
        }
        # ModelVersion row gone.
        with Session(fk_engine) as s:
            assert s.get(ModelVersion, v_ids[2]) is None
            assert s.get(ModelVersion, v_ids[1]) is not None

    def test_delete_latest_when_only_version_in_scope(
        self, engine, client_with_agent
    ):
        """A single same-scope version still counts as "the latest"; the
        delete succeeds and reports previous_version=None."""
        with Session(engine) as s:
            b = Business(name="lone", description="t", industry_alignment="Retail")
            s.add(b)
            s.flush()
            mv = ModelVersion(
                business_id=b.id, version=1, status="completed", scope="mvm",
                uc_catalog="cat", deployment_status="uninstalled",
            )
            s.add(mv)
            s.commit()
            biz_id, vid = b.id, mv.id

        r = client_with_agent.delete(f"/api/businesses/{biz_id}/versions/{vid}")
        assert r.status_code == 200, r.text
        body = r.json()
        assert body["deleted_version"] == 1
        assert body["previous_version"] is None
        assert body["reinstall_dispatched"] is False

    def test_delete_non_latest_in_scope_rejected(
        self, engine, client_with_agent
    ):
        biz_id, v_ids = _seed_business_with_two_scoped_versions(engine, scope="ecm")
        r = client_with_agent.delete(
            f"/api/businesses/{biz_id}/versions/{v_ids[1]}"
        )
        assert r.status_code == 400, r.text
        assert "latest" in r.json()["detail"].lower()

        # Nothing was deleted.
        with Session(engine) as s:
            assert s.get(ModelVersion, v_ids[1]) is not None
            assert s.get(ModelVersion, v_ids[2]) is not None

    def test_cross_scope_does_not_block_delete(
        self, engine, client_with_agent
    ):
        """Business has ECM v1 + MVM v1. Deleting ECM v1 (latest in its
        scope) must succeed; MVM v1 is unaffected."""
        with Session(engine) as s:
            b = Business(name="cross", description="t", industry_alignment="Retail")
            s.add(b)
            s.flush()
            mv_ecm = ModelVersion(
                business_id=b.id, version=1, status="completed",
                scope="ecm", uc_catalog="cat", deployment_status="uninstalled",
            )
            mv_mvm = ModelVersion(
                business_id=b.id, version=1, status="completed",
                scope="mvm", uc_catalog="cat", deployment_status="uninstalled",
            )
            s.add(mv_ecm)
            s.add(mv_mvm)
            s.commit()
            biz_id, ecm_id, mvm_id = b.id, mv_ecm.id, mv_mvm.id

        r = client_with_agent.delete(f"/api/businesses/{biz_id}/versions/{ecm_id}")
        assert r.status_code == 200, r.text

        with Session(engine) as s:
            assert s.get(ModelVersion, ecm_id) is None
            assert s.get(ModelVersion, mvm_id) is not None

    def test_delete_clears_run_version_id_pointer(
        self, fk_engine, fk_client
    ):
        """A run that only REFERENCES the deleted version as a source
        (``Run.version_id`` pointer, no RunOperation that produced it) is kept;
        its ``version_id`` is SET NULL via the DB ON DELETE rule. Runs under FK
        enforcement so the SET NULL actually fires."""
        biz_id, v_ids = _seed_business_with_two_scoped_versions(fk_engine, scope="ecm")
        with Session(fk_engine) as s:
            r = Run(
                business_id=biz_id, version_id=v_ids[2],
                intent="vibe-iterate", status="completed",
                parameters_json="{}",
            )
            s.add(r)
            s.commit()
            run_id = r.id

        resp = fk_client.delete(
            f"/api/businesses/{biz_id}/versions/{v_ids[2]}"
        )
        assert resp.status_code == 200, resp.text

        with Session(fk_engine) as s:
            run = s.get(Run, run_id)
            assert run is not None
            assert run.version_id is None


class TestDeleteVersionReinstallPrevious:
    """Opt-in reinstall via ``?reinstall_previous=true``."""

    def test_reinstall_dispatches_orchestrator(
        self, engine, client_with_agent, mock_tracker
    ):
        # MVM v3 deployed → expect uninstall→install DAG.
        with Session(engine) as s:
            b = Business(name="reinst", description="t", industry_alignment="Retail")
            s.add(b)
            s.flush()
            biz_id = b.id
            ids: dict[int, str] = {}
            for n in (2, 3):
                mv = ModelVersion(
                    business_id=biz_id, version=n, status="completed",
                    scope="mvm", uc_catalog="reinst_cat",
                    deployment_status=("deployed" if n == 3 else "uninstalled"),
                )
                s.add(mv)
                s.flush()
                ids[n] = mv.id
            s.commit()

        r = client_with_agent.delete(
            f"/api/businesses/{biz_id}/versions/{ids[3]}"
            f"?reinstall_previous=true"
        )
        # Mock workspace will fail dispatch; orchestrator semantics let
        # the route still return 200 with the failed-run payload — but
        # the route DOES create a Run, attempt orchestrator.start, and
        # call start_tracking if pending/running. We assert observable
        # invariants: the row is gone, a Run was persisted, and the
        # response shape carries reinstall_dispatched=true.
        assert r.status_code == 200, r.text
        body = r.json()
        assert body["deleted_version"] == 3
        assert body["previous_version"] == 2
        assert body["reinstall_dispatched"] is True
        assert body["run_id"]

        with Session(engine) as s:
            assert s.get(ModelVersion, ids[3]) is None
            assert s.get(ModelVersion, ids[2]) is not None
            run = s.get(Run, body["run_id"])
            assert run is not None
            # Orchestrator.start overwrites run.intent from dag.intent,
            # which is "revert" for the uninstall→install DAG. Either
            # label is acceptable — what we care about is that a Run was
            # actually persisted and pointed at the reinstall target.
            assert run.intent in ("revert", "reinstall-previous")
            assert run.version_id == ids[2]

    def test_reinstall_without_previous_rejected(
        self, engine, client_with_agent
    ):
        """Only-version-of-its-scope + ``reinstall_previous=true`` → 400."""
        with Session(engine) as s:
            b = Business(name="solo", description="t", industry_alignment="Retail")
            s.add(b)
            s.flush()
            mv = ModelVersion(
                business_id=b.id, version=1, status="completed", scope="ecm",
                uc_catalog="cat", deployment_status="deployed",
            )
            s.add(mv)
            s.commit()
            biz_id, vid = b.id, mv.id

        r = client_with_agent.delete(
            f"/api/businesses/{biz_id}/versions/{vid}"
            f"?reinstall_previous=true"
        )
        assert r.status_code == 400
        assert "previous" in r.json()["detail"].lower()

        # Nothing was deleted.
        with Session(engine) as s:
            assert s.get(ModelVersion, vid) is not None

    def test_reinstall_without_uc_catalog_rejected(
        self, engine, client_with_agent
    ):
        """An import-only version (no uc_catalog) can't be the source of a
        reinstall (we don't know what catalog to install the previous
        version into) — 400."""
        biz_id, v_ids = _seed_business_with_two_scoped_versions(
            engine, scope="ecm", latest_imported=True,
        )

        r = client_with_agent.delete(
            f"/api/businesses/{biz_id}/versions/{v_ids[2]}"
            f"?reinstall_previous=true"
        )
        assert r.status_code == 400
        assert "never installed" in r.json()["detail"].lower()

        # Nothing was deleted.
        with Session(engine) as s:
            assert s.get(ModelVersion, v_ids[2]) is not None
