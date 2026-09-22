"""Regression tests for F9 / F10 / non-cascade gate cascade-delete bugs.

F10: ``DELETE /api/runs/{run_id}`` did not cascade RunOperation +
RunNextVibeLink rows, 500ing on the test workspace where those FKs lack ON DELETE
CASCADE.

F9: ``DELETE /api/businesses/{business_id}?cascade=true`` deleted
ModelVersions before Runs even though ``runs.version_id`` FKs into
``model_versions.id``, tripping the constraint when a run referenced
its produced version.

Non-cascade gate: ``DELETE /api/businesses/{business_id}`` only checked
for model versions before deleting, so a business with a failed run (no
version yet, just a Run row) would fall through to SQLModel default
relationship behaviour, attempt to NULL ``runs.business_id``, and 500
with a NotNullViolation. Now it returns 409 with a clear message
suggesting ``?cascade=true``.
"""

from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    BusinessContext,
    DiagramLayout,
    Domain,
    ForeignKeyLink,
    ModelVersion,
    Product,
    ProductReview,
    Run,
    RunArtifact,
    RunElementLineage,
    RunInputLink,
    RunNextVibeLink,
    RunOperation,
    RunProgressEvent,
    Subdomain,
    VibeInput,
    VibeInputContextLink,
)


def _seed_full_graph(engine) -> dict:
    """Seed a business with ONE row of EVERY child type and return key ids.

    Used by the count-based and FK-enforced full-graph delete tests. The
    graph is internally consistent (every FK points at a real parent row)
    so it can be deleted under strict FK enforcement.
    """
    with Session(engine) as s:
        b = Business(name="FullGraph Corp", description="d", industry_alignment="Retail")
        s.add(b)
        s.flush()

        mv = ModelVersion(business_id=b.id, version=1, scope="ecm", status="completed")
        s.add(mv)
        s.flush()

        dom = Domain(version_id=mv.id, name="Sales")
        s.add(dom)
        s.flush()

        sub = Subdomain(version_id=mv.id, domain_id=dom.id, name="Orders")
        s.add(sub)
        s.flush()

        prod = Product(
            domain_id=dom.id, version_id=mv.id, name="Order",
            subdomain_id=sub.id,
        )
        s.add(prod)
        s.flush()

        attr = Attribute(product_id=prod.id, name="order_id")
        s.add(attr)

        fkl = ForeignKeyLink(version_id=mv.id, source_product="Order", target_product="Customer")
        s.add(fkl)

        dl = DiagramLayout(business_id=b.id, version_id=mv.id, cache_key="ck")
        s.add(dl)

        run = Run(business_id=b.id, version_id=mv.id, intent="new-base-model", status="completed", parameters_json="{}")
        s.add(run)
        s.flush()

        vi = VibeInput(business_id=b.id, origin="user", text="hi")
        s.add(vi)
        s.flush()

        s.add(VibeInputContextLink(input_id=vi.id, version_id=mv.id, product_id=prod.id))
        s.add(RunInputLink(run_id=run.id, input_id=vi.id))
        s.add(RunElementLineage(run_id=run.id, version_id=mv.id, element_type="domain", change_kind="rename"))
        s.add(ProductReview(version_id=mv.id, product_id=prod.id, state="reviewed"))
        s.add(RunArtifact(run_id=run.id, model_version_id=mv.id, artifact_type="json", file_path="m.json"))
        s.add(RunProgressEvent(run_id=run.id, stage_name="x", step_name="y"))
        s.add(RunOperation(
            run_id=run.id, step_index=0, operation_name="generate_ecm",
            parent_version_id=mv.id, output_version_id=mv.id, status="succeeded",
        ))
        s.add(RunNextVibeLink(run_id=run.id, next_vibe_id="nv-1"))
        s.add(BusinessContext(business_id=b.id, version_label="seed"))
        s.commit()
        return {"business_id": b.id, "version_id": mv.id, "run_id": run.id}


_ALL_CHILD_MODELS = [
    ModelVersion, Domain, Subdomain, Product, Attribute, ForeignKeyLink,
    DiagramLayout, VibeInput, VibeInputContextLink, RunInputLink,
    RunElementLineage, ProductReview, RunArtifact,
    RunProgressEvent, RunOperation, RunNextVibeLink, BusinessContext, Run,
]


def _seed_business_fk(fk_engine) -> str:
    """Create a bare business in the FK-enforcing engine, return its id."""
    with Session(fk_engine) as s:
        b = Business(name="Test Corp", description="A test company", industry_alignment="Retail")
        s.add(b)
        s.commit()
        s.refresh(b)
        return b.id


def _seed_failed_run_fk(fk_engine, business_id: str) -> str:
    """Create a failed run for ``business_id`` in the FK-enforcing engine."""
    with Session(fk_engine) as s:
        run = Run(
            business_id=business_id,
            intent="new-base-model",
            status="failed",
            error_message="Something went wrong",
            databricks_run_id=12345,
            parameters_json="{}",
        )
        s.add(run)
        s.commit()
        s.refresh(run)
        return run.id


def test_delete_business_cascade_full_graph_fk_enforced(fk_client, fk_engine):
    """Full-graph delete under PRAGMA foreign_keys=ON.

    Seeds one row of every child type and proves the DB ON DELETE cascade
    clears them all when the business is removed. A 200 proves the cascade
    graph is complete and correctly ordered.
    """
    ids = _seed_full_graph(fk_engine)
    bid = ids["business_id"]

    resp = fk_client.delete(f"/api/businesses/{bid}?cascade=true")
    assert resp.status_code == 200, resp.text

    with Session(fk_engine) as s:
        assert s.get(Business, bid) is None
        for model in _ALL_CHILD_MODELS:
            assert s.exec(select(model)).all() == [], model.__name__


def test_delete_business_cascade_409_not_500_and_rolls_back(
    fk_client, fk_engine, monkeypatch
):
    """Force an IntegrityError on the delete commit: the route maps it to a
    409 (not a bare 500), the detail mentions dependent records, and the
    rollback leaves the business + its children fully intact."""
    ids = _seed_full_graph(fk_engine)
    bid = ids["business_id"]

    from sqlalchemy.exc import IntegrityError
    from sqlmodel import Session as _RouteSession

    def _boom_commit(self, *args, **kwargs):
        raise IntegrityError(
            "DELETE FROM businesses",
            {},
            Exception(
                "update or delete on table violates foreign key constraint "
                '"vibe_input_context_links_product_id_fkey"'
            ),
        )

    # The route runs ``session.delete(business)`` then ``session.commit()``
    # inside a try that maps IntegrityError -> 409 + rollback. Patch commit on
    # the session class the route uses so the wrapper is exercised without the
    # deleted manual-cascade helper.
    monkeypatch.setattr(_RouteSession, "commit", _boom_commit)

    resp = fk_client.delete(f"/api/businesses/{bid}?cascade=true")
    assert resp.status_code == 409, resp.text
    assert "dependent records" in resp.json()["detail"]

    monkeypatch.undo()

    # Rollback left everything intact.
    with Session(fk_engine) as s:
        assert s.get(Business, bid) is not None
        assert s.exec(select(Subdomain)).all() != []
        assert s.exec(select(Domain)).all() != []
        assert s.exec(select(ModelVersion)).all() != []


def test_delete_business_cascade_nulls_source_industry_id(fk_client, fk_engine):
    """Deleting a downloaded industry NULLs source_industry_id on its
    kickstarted children rather than 500ing on the self-FK."""
    with Session(fk_engine) as s:
        industry = Business(name="Retail Industry", kind="industry")
        s.add(industry)
        s.flush()
        child = Business(
            name="Acme Retail", kind="business",
            source_industry_id=industry.id, source_version=1,
        )
        s.add(child)
        s.commit()
        industry_id = industry.id
        child_id = child.id

    resp = fk_client.delete(f"/api/businesses/{industry_id}?cascade=true")
    assert resp.status_code == 200, resp.text

    with Session(fk_engine) as s:
        assert s.get(Business, industry_id) is None
        surviving = s.get(Business, child_id)
        assert surviving is not None
        assert surviving.source_industry_id is None


def test_delete_run_cascades_run_operation(fk_client, fk_engine):
    """``delete_run`` rides ``run_id`` ON DELETE CASCADE, so a RunOperation
    child dies with its run under FK enforcement."""
    bid = _seed_business_fk(fk_engine)
    run_id = _seed_failed_run_fk(fk_engine, bid)

    with Session(fk_engine) as session:
        session.add(
            RunOperation(
                run_id=run_id,
                step_index=0,
                operation_name="generate_ecm",
                params_json='{"scope": "ecm"}',
                status="failed",
                error_message="agent crashed",
            )
        )
        session.commit()

    resp = fk_client.delete(f"/api/businesses/{bid}/runs/{run_id}")
    assert resp.status_code == 200, resp.text

    with Session(fk_engine) as session:
        assert session.get(Run, run_id) is None
        remaining = session.exec(
            select(RunOperation).where(RunOperation.run_id == run_id)
        ).all()
        assert remaining == []


def test_delete_run_cascades_run_next_vibe_link(fk_client, fk_engine):
    bid = _seed_business_fk(fk_engine)
    run_id = _seed_failed_run_fk(fk_engine, bid)

    with Session(fk_engine) as session:
        session.add(RunNextVibeLink(run_id=run_id, next_vibe_id="nv-1"))
        session.commit()

    resp = fk_client.delete(f"/api/businesses/{bid}/runs/{run_id}")
    assert resp.status_code == 200, resp.text

    with Session(fk_engine) as session:
        assert session.get(Run, run_id) is None
        remaining = session.exec(
            select(RunNextVibeLink).where(RunNextVibeLink.run_id == run_id)
        ).all()
        assert remaining == []


def test_delete_business_cascade_with_run_referencing_version(fk_client, fk_engine):
    bid = _seed_business_fk(fk_engine)
    with Session(fk_engine) as session:
        mv = ModelVersion(business_id=bid, version=1)
        session.add(mv)
        session.commit()
        session.refresh(mv)
        run = Run(
            business_id=bid,
            version_id=mv.id,
            intent="new-base-model",
            status="completed",
            parameters_json="{}",
        )
        session.add(run)
        session.commit()
        run_id = run.id
        mv_id = mv.id

    resp = fk_client.delete(f"/api/businesses/{bid}?cascade=true")
    assert resp.status_code == 200, resp.text

    with Session(fk_engine) as session:
        assert session.get(Run, run_id) is None
        assert session.get(ModelVersion, mv_id) is None
        assert session.exec(
            select(Run).where(Run.business_id == bid)
        ).all() == []
        assert session.exec(
            select(ModelVersion).where(ModelVersion.business_id == bid)
        ).all() == []


def test_delete_business_cascade_with_run_operation_and_next_vibe(fk_client, fk_engine):
    bid = _seed_business_fk(fk_engine)
    with Session(fk_engine) as session:
        mv = ModelVersion(business_id=bid, version=1)
        session.add(mv)
        session.commit()
        session.refresh(mv)
        run = Run(
            business_id=bid,
            version_id=mv.id,
            intent="new-base-model",
            status="completed",
            parameters_json="{}",
        )
        session.add(run)
        session.commit()
        session.refresh(run)
        session.add(
            RunOperation(
                run_id=run.id,
                step_index=0,
                operation_name="generate_ecm",
                params_json="{}",
                status="succeeded",
            )
        )
        session.add(RunNextVibeLink(run_id=run.id, next_vibe_id="nv-1"))
        session.commit()
        run_id = run.id
        mv_id = mv.id

    resp = fk_client.delete(f"/api/businesses/{bid}?cascade=true")
    assert resp.status_code == 200, resp.text

    with Session(fk_engine) as session:
        assert session.get(Run, run_id) is None
        assert session.get(ModelVersion, mv_id) is None
        assert session.exec(
            select(RunOperation).where(RunOperation.run_id == run_id)
        ).all() == []
        assert session.exec(
            select(RunNextVibeLink).where(RunNextVibeLink.run_id == run_id)
        ).all() == []


def test_delete_business_cascade_clears_diagram_layouts(fk_client, fk_engine):
    bid = _seed_business_fk(fk_engine)
    with Session(fk_engine) as session:
        mv = ModelVersion(business_id=bid, version=1)
        session.add(mv)
        session.commit()
        session.refresh(mv)
        session.add(
            DiagramLayout(
                business_id=bid,
                version_id=mv.id,
                cache_key="test-cache-key",
            )
        )
        session.commit()
        mv_id = mv.id

    resp = fk_client.delete(f"/api/businesses/{bid}?cascade=true")
    assert resp.status_code == 200, resp.text

    with Session(fk_engine) as session:
        assert session.get(ModelVersion, mv_id) is None
        assert session.exec(
            select(DiagramLayout).where(DiagramLayout.version_id == mv_id)
        ).all() == []


def test_delete_business_without_cascade_409s_when_run_exists(
    client, engine, seed_failed_run,
):
    """Without ``?cascade=true``, a business with a failed-but-unversioned run
    must return 409, not 500. Pre-fix this fell through to the SQLModel
    default and tripped ``runs.business_id`` NOT NULL."""
    business_id, _run_id = seed_failed_run

    resp = client.delete(f"/api/businesses/{business_id}")

    assert resp.status_code == 409, resp.text
    assert "runs" in resp.json()["detail"].lower()
    assert "cascade=true" in resp.json()["detail"]
    # Business is still there.
    with Session(engine) as session:
        from vibe_modeling.backend.db_models import Business
        assert session.get(Business, business_id) is not None


def test_delete_business_without_cascade_409s_when_versions_exist(
    client, engine, seed_business,
):
    """Existing behaviour for the version case — message now mentions cascade=true."""
    with Session(engine) as session:
        session.add(
            ModelVersion(
                business_id=seed_business, version=1, scope="ecm",
                status="completed",
            )
        )
        session.commit()

    resp = client.delete(f"/api/businesses/{seed_business}")

    assert resp.status_code == 409, resp.text
    assert "model versions" in resp.json()["detail"].lower()
    assert "cascade=true" in resp.json()["detail"]
