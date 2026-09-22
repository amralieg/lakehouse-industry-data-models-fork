"""Test the explorer.py module — model browsing, diff computation, and Lakebase loading."""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import json

import pytest
from sqlmodel import Session

from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    BusinessContext,
    Domain,
    ForeignKeyLink,
    ModelVersion,
    Product,
)
from vibe_modeling.backend.evolution_metrics import _structure_size_fallback
from vibe_modeling.backend.explorer import (
    _compute_diff,
    _find_model_json_path,
    _load_model_from_lakebase,
    count_fk_attributes,
    is_fk_attribute,
)
from vibe_modeling.backend.models import ChangeStatus


class TestFindModelJsonPathNestedFallback:
    """``_find_model_json_path`` Strategy 0 probes the nested (agent 4.9.8+)
    ``v{N}/{scope}/model.json`` first and falls back to the legacy flat
    ``{scope}_v{N}/model.json`` for pre-upgrade rows."""

    def _seed(self, engine):
        with Session(engine) as s:
            biz = Business(name="Acme", industry_alignment="x", description="d")
            s.add(biz)
            s.flush()
            mv = ModelVersion(
                business_id=biz.id, version=2, scope="ecm",
                status="completed", uc_catalog="cat",
            )
            s.add(mv)
            s.commit()
            return biz.id

    def test_nested_probed_before_flat(self, engine):
        from unittest.mock import MagicMock
        from databricks.sdk.errors import NotFound

        business_id = self._seed(engine)
        nested = "/Volumes/cat/_metamodel/vol_root/business/acme/v2/ecm/model.json"
        flat = "/Volumes/cat/_metamodel/vol_root/business/acme/ecm_v2/model.json"
        probed: list[str] = []
        ws = MagicMock()

        def fake_get_metadata(path):
            probed.append(path)
            if path == flat:
                return MagicMock()
            raise NotFound("nope")

        ws.files.get_metadata.side_effect = fake_get_metadata

        with Session(engine) as s:
            resolved = _find_model_json_path(s, ws, business_id, 2, "ecm")

        # Flat artifact resolves via fallback; nested was probed strictly first.
        assert resolved == flat
        assert nested in probed and flat in probed
        assert probed.index(nested) < probed.index(flat)

    def test_nested_preferred_when_present(self, engine):
        from unittest.mock import MagicMock

        business_id = self._seed(engine)
        nested = "/Volumes/cat/_metamodel/vol_root/business/acme/v2/ecm/model.json"
        ws = MagicMock()
        ws.files.get_metadata.return_value = MagicMock()

        with Session(engine) as s:
            resolved = _find_model_json_path(s, ws, business_id, 2, "ecm")

        assert resolved == nested


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------


def _make_model(domains):
    """Build a minimal model dict for diff testing."""
    return {"domains": domains}


def _domain(name, products, division=""):
    return {"name": name, "division": division, "products": products}


def _product(name, attributes):
    return {"name": name, "table_name": name, "attributes": attributes}


def _attr(name, type_="STRING", fk="", desc=""):
    return {"name": name, "type": type_, "foreign_key_to": fk, "description": desc}


SIMPLE_MODEL = _make_model([
    _domain("sales", [
        _product("customer", [
            _attr("customer_id", "BIGINT"),
            _attr("name", "STRING"),
        ]),
    ]),
    _domain("inventory", [
        _product("product", [
            _attr("product_id", "BIGINT"),
        ]),
    ]),
])


# ---------------------------------------------------------------------------
# Diff computation
# ---------------------------------------------------------------------------


class TestComputeDiff:
    def test_no_previous_version_returns_empty(self):
        diff = _compute_diff(None, SIMPLE_MODEL)
        assert diff["domains"] == {}
        assert diff["products"] == {}
        assert diff["attributes"] == {}
        assert diff["deleted_domains"] == []

    def test_identical_models_no_changes(self):
        diff = _compute_diff(SIMPLE_MODEL, SIMPLE_MODEL)
        assert diff["domains"] == {}
        assert diff["products"] == {}
        assert diff["attributes"] == {}

    def test_new_domain_detected(self):
        old = _make_model([_domain("sales", [_product("customer", [_attr("id")])])])
        new = _make_model([
            _domain("sales", [_product("customer", [_attr("id")])]),
            _domain("hr", [_product("employee", [_attr("emp_id")])]),
        ])
        diff = _compute_diff(old, new)
        assert diff["domains"]["hr"] == ChangeStatus.NEW
        assert ("hr", "employee") in diff["products"]

    def test_deleted_domain_detected(self):
        old = _make_model([
            _domain("sales", [_product("customer", [_attr("id")])]),
            _domain("hr", [_product("employee", [_attr("emp_id")])]),
        ])
        new = _make_model([_domain("sales", [_product("customer", [_attr("id")])])])
        diff = _compute_diff(old, new)
        assert len(diff["deleted_domains"]) == 1
        assert diff["deleted_domains"][0].name == "hr"
        assert diff["deleted_domains"][0].change_status == ChangeStatus.DELETED

    def test_new_product_detected(self):
        old = _make_model([_domain("sales", [_product("customer", [_attr("id")])])])
        new = _make_model([_domain("sales", [
            _product("customer", [_attr("id")]),
            _product("order", [_attr("order_id")]),
        ])])
        diff = _compute_diff(old, new)
        assert diff["products"][("sales", "order")] == ChangeStatus.NEW

    def test_deleted_product_detected(self):
        old = _make_model([_domain("sales", [
            _product("customer", [_attr("id")]),
            _product("order", [_attr("order_id")]),
        ])])
        new = _make_model([_domain("sales", [_product("customer", [_attr("id")])])])
        diff = _compute_diff(old, new)
        assert "sales" in diff["deleted_products"]
        assert len(diff["deleted_products"]["sales"]) == 1
        assert diff["deleted_products"]["sales"][0].name == "order"

    def test_new_attribute_detected(self):
        old = _make_model([_domain("d", [_product("t", [_attr("a")])])])
        new = _make_model([_domain("d", [_product("t", [_attr("a"), _attr("b")])])])
        diff = _compute_diff(old, new)
        assert diff["attributes"][("d", "t", "b")] == ChangeStatus.NEW

    def test_deleted_attribute_detected(self):
        old = _make_model([_domain("d", [_product("t", [_attr("a"), _attr("b")])])])
        new = _make_model([_domain("d", [_product("t", [_attr("a")])])])
        diff = _compute_diff(old, new)
        assert ("d", "t") in diff["deleted_attributes"]
        deleted_names = [a.name for a in diff["deleted_attributes"][("d", "t")]]
        assert "b" in deleted_names

    def test_modified_attribute_type_change(self):
        old = _make_model([_domain("d", [_product("t", [_attr("a", "STRING")])])])
        new = _make_model([_domain("d", [_product("t", [_attr("a", "BIGINT")])])])
        diff = _compute_diff(old, new)
        assert diff["attributes"][("d", "t", "a")] == ChangeStatus.MODIFIED

    def test_modified_attribute_fk_change(self):
        old = _make_model([_domain("d", [_product("t", [_attr("a", fk="")])])])
        new = _make_model([_domain("d", [_product("t", [_attr("a", fk="d.t2.col")])])])
        diff = _compute_diff(old, new)
        assert diff["attributes"][("d", "t", "a")] == ChangeStatus.MODIFIED

    def test_modified_product_propagates_from_child(self):
        old = _make_model([_domain("d", [_product("t", [_attr("a", "STRING")])])])
        new = _make_model([_domain("d", [_product("t", [_attr("a", "BIGINT")])])])
        diff = _compute_diff(old, new)
        assert diff["products"][("d", "t")] == ChangeStatus.MODIFIED

    def test_modified_domain_propagates_from_child(self):
        old = _make_model([_domain("d", [_product("t", [_attr("a", "STRING")])])])
        new = _make_model([_domain("d", [_product("t", [_attr("a", "BIGINT")])])])
        diff = _compute_diff(old, new)
        assert diff["domains"]["d"] == ChangeStatus.MODIFIED

    def test_description_change_within_100_chars_not_detected(self):
        """Diff truncates descriptions to 100 chars for comparison."""
        old = _make_model([_domain("d", [_product("t", [
            _attr("a", desc="Short description"),
        ])])])
        new = _make_model([_domain("d", [_product("t", [
            _attr("a", desc="Short description, slightly different"),
        ])])])
        diff = _compute_diff(old, new)
        assert diff["attributes"].get(("d", "t", "a")) == ChangeStatus.MODIFIED


# ---------------------------------------------------------------------------
# Lakebase model loading
# ---------------------------------------------------------------------------


class TestLoadModelFromLakebase:
    def test_loads_model_from_lakebase(self, engine):
        """Verify _load_model_from_lakebase assembles a model dict from DB records."""
        with Session(engine) as session:
            b = Business(name="Test Corp", description="A test")
            session.add(b)
            session.flush()

            mv = ModelVersion(business_id=b.id, version=1, scope="mvm", status="completed")
            session.add(mv)
            session.flush()

            d = Domain(version_id=mv.id, name="sales", division="Commercial",
                       description="Sales domain")
            session.add(d)
            session.flush()

            p = Product(
                version_id=mv.id, domain_id=d.id, name="customer",
                table_name="customer", description="Customer data",
                type="Master", primary_key="customer_id",
            )
            session.add(p)
            session.flush()

            a = Attribute(
                product_id=p.id, name="customer_id", column_name="customer_id",
                type="BIGINT", description="PK",
            )
            session.add(a)
            session.commit()

            model = _load_model_from_lakebase(session, b.id, 1, "mvm")

        assert model is not None
        assert model["business_name"] == "Test Corp"
        assert len(model["domains"]) == 1
        assert model["domains"][0]["name"] == "sales"
        assert len(model["domains"][0]["products"]) == 1
        assert model["domains"][0]["products"][0]["name"] == "customer"
        assert len(model["domains"][0]["products"][0]["attributes"]) == 1

    def test_returns_none_for_missing_version(self, engine):
        with Session(engine) as session:
            model = _load_model_from_lakebase(session, "nonexistent", 1, "mvm")
        assert model is None

    def test_returns_none_for_version_with_no_domains(self, engine):
        with Session(engine) as session:
            b = Business(name="Empty Corp")
            session.add(b)
            session.flush()
            mv = ModelVersion(business_id=b.id, version=1, scope="mvm", status="completed")
            session.add(mv)
            session.commit()

            model = _load_model_from_lakebase(session, b.id, 1, "mvm")
        assert model is None


# ---------------------------------------------------------------------------
# Explorer API endpoints
# ---------------------------------------------------------------------------


class TestExplorerEndpoints:
    """Test explorer API routes via the TestClient."""

    @pytest.fixture
    def seeded_model(self, engine):
        """Seed a business, version, domain, product, and attributes in Lakebase."""
        with Session(engine) as session:
            b = Business(name="Explorer Corp", description="Testing explorer")
            session.add(b)
            session.flush()

            ctx = BusinessContext(
                business_id=b.id,
                version_label="v1",
                context_json=json.dumps({
                    "business_context": {
                        "business_information": {
                            "business": "Explorer Corp",
                            "description": "Testing",
                            "industry_alignment": "Tech",
                            "core_business_processes": "Testing",
                            "orgnaization_divisions": "Engineering",
                            "data_domains": "Sales, Inventory",
                            "common_business_jargons": "",
                            "operational_systems_of_records": "",
                            "industry_governing_body": "",
                        },
                        "model_conventions": {"pk_suffix": "_id"},
                        "vibe_modeling_instructions": "Test instructions",
                    }
                }),
                conventions_json="{}",
            )
            session.add(ctx)

            mv = ModelVersion(business_id=b.id, version=1, scope="mvm", status="completed")
            session.add(mv)
            session.flush()

            d = Domain(version_id=mv.id, name="sales", division="Commercial",
                       description="Sales domain", database_name="sales_db")
            session.add(d)
            session.flush()

            p = Product(
                version_id=mv.id, domain_id=d.id, name="customer",
                table_name="customer", description="Customer master",
                type="Master", data_type="Structured", primary_key="customer_id",
            )
            session.add(p)
            session.flush()

            for attr_data in [
                {"name": "customer_id", "column_name": "customer_id",
                 "type": "BIGINT", "description": "PK"},
                {"name": "email", "column_name": "email",
                 "type": "STRING", "description": "Email address"},
            ]:
                session.add(Attribute(product_id=p.id, **attr_data))

            session.commit()
            return b.id

    def test_get_explorer_context_removed(self, client, seed_business):
        # Track 8 item 4: the Business Context card now reads business.name /
        # business.description / sector directly, never context_json. The
        # endpoint was the sole consumer and is retired as dead code.
        resp = client.get(f"/api/businesses/{seed_business}/explorer/context")
        assert resp.status_code == 404

    def test_get_explorer_versions(self, client, seeded_model):
        resp = client.get(f"/api/businesses/{seeded_model}/explorer/versions")
        assert resp.status_code == 200
        versions = resp.json()
        assert len(versions) == 1
        assert versions[0]["version"] == 1

    def test_get_model_summary(self, client, seeded_model):
        resp = client.get(f"/api/businesses/{seeded_model}/versions/1/mvm/model")
        assert resp.status_code == 200
        data = resp.json()
        assert data["domain_count"] == 1
        assert data["product_count"] == 1
        assert data["attribute_count"] == 2
        assert len(data["domains"]) == 1
        assert data["domains"][0]["name"] == "sales"

    def test_get_domain_detail(self, client, seeded_model):
        resp = client.get(f"/api/businesses/{seeded_model}/versions/1/mvm/domains/sales")
        assert resp.status_code == 200
        data = resp.json()
        assert data["name"] == "sales"
        assert len(data["products"]) == 1
        assert data["products"][0]["name"] == "customer"

    def test_get_domain_detail_not_found(self, client, seeded_model):
        resp = client.get(f"/api/businesses/{seeded_model}/versions/1/mvm/domains/nonexistent")
        assert resp.status_code == 404

    def test_get_product_detail(self, client, seeded_model):
        resp = client.get(
            f"/api/businesses/{seeded_model}/versions/1/mvm/domains/sales/products/customer"
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["name"] == "customer"
        assert data["primary_key"] == "customer_id"
        assert len(data["attributes"]) == 2

    def test_get_product_detail_not_found(self, client, seeded_model):
        resp = client.get(
            f"/api/businesses/{seeded_model}/versions/1/mvm/domains/sales/products/nonexistent"
        )
        assert resp.status_code == 404

    def test_product_attributes_sorted_pk_first(self, client, seeded_model):
        resp = client.get(
            f"/api/businesses/{seeded_model}/versions/1/mvm/domains/sales/products/customer"
        )
        data = resp.json()
        attrs = data["attributes"]
        # customer_id (PK) should be first
        assert attrs[0]["name"] == "customer_id"
        assert attrs[0]["is_primary_key"] is True


# ---------------------------------------------------------------------------
# Bug B (#185) — duplicate-named Domain rows collapsed at the loader
# ---------------------------------------------------------------------------


class TestDuplicateDomainCollapse:
    """When the upstream loader emits one ``Domain`` DB row per
    (logical_domain × subdomain) — observed for biz 297ae488 v=2 MVM,
    where 5 logical domains were persisted as 15 rows and the Ontology
    tab header reported ``15 domains`` while every other view said
    ``5 domains`` — ``_load_model_from_lakebase`` must merge them on
    ``name`` so all surfaces (overview, ontology, relationships,
    diagram, Phase X) see the same unique-domain count.
    """

    def _seed_split_domain(self, engine, n_subdomains: int):
        """Persist ``n_subdomains`` Domain rows that share a name and
        return the business id. Each row carries one Product so the
        post-merge product count equals ``n_subdomains``.
        """
        with Session(engine) as session:
            b = Business(name="Split Corp", description="Cross-domain rows")
            session.add(b)
            session.flush()
            mv = ModelVersion(
                business_id=b.id, version=1, scope="mvm", status="completed",
            )
            session.add(mv)
            session.flush()
            for i in range(n_subdomains):
                d = Domain(
                    version_id=mv.id,
                    name="customer_engagement",
                    division="Commercial",
                    description="Customer engagement domain",
                    database_name=f"customer_engagement_sd{i}",
                )
                session.add(d)
                session.flush()
                p = Product(
                    version_id=mv.id,
                    domain_id=d.id,
                    name=f"product_{i}",
                    table_name=f"product_{i}",
                    primary_key=f"product_{i}_id",
                    subdomain=f"subdomain_{i}",
                )
                session.add(p)
                session.flush()
                session.add(Attribute(
                    product_id=p.id,
                    name=f"product_{i}_id",
                    column_name=f"product_{i}_id",
                    type="BIGINT",
                ))
            session.commit()
            return b.id

    def test_load_collapses_duplicate_named_domain_rows(self, engine):
        """Three DB rows named ``customer_engagement`` collapse into one
        logical domain whose ``products`` list is the union of all rows'
        products.
        """
        biz_id = self._seed_split_domain(engine, n_subdomains=3)
        with Session(engine) as session:
            model = _load_model_from_lakebase(session, biz_id, 1, "mvm")
        assert model is not None
        assert len(model["domains"]) == 1, (
            f"Expected 1 logical domain after merge, got {len(model['domains'])}"
        )
        merged = model["domains"][0]
        assert merged["name"] == "customer_engagement"
        # All three rows' products survived the merge.
        assert len(merged["products"]) == 3
        product_names = {p["name"] for p in merged["products"]}
        assert product_names == {"product_0", "product_1", "product_2"}

    def test_summary_endpoint_reports_unique_domain_count(self, client, engine):
        """Cross-view consistency: ``getModelSummary`` must report the
        unique-domain count even when DB rows are split across
        subdomains, so Overview, Relationships, and the Ontology header
        all agree.
        """
        biz_id = self._seed_split_domain(engine, n_subdomains=3)
        resp = client.get(f"/api/businesses/{biz_id}/versions/1/mvm/model")
        assert resp.status_code == 200
        data = resp.json()
        assert data["domain_count"] == 1
        # The summary's ``domains`` array (used by the FE Ontology fetch
        # to enumerate per-domain detail calls) must also be deduped so
        # the FE doesn't render 3 separate domain blocks.
        assert len(data["domains"]) == 1
        assert data["domains"][0]["name"] == "customer_engagement"
        # Product count is the union across the merged rows.
        assert data["product_count"] == 3


# ---------------------------------------------------------------------------
# Canonical FK-attribute predicate / counter (0.6.3 consolidation)
# ---------------------------------------------------------------------------


class TestCountFkAttributes:
    """The single definition of "an FK attribute" used by every FK-counting
    surface. The predicate is ``parse_fk_target(...) is not None`` — a
    non-empty-but-malformed ``foreign_key_to`` (e.g. a single-part string with
    no ``.``) is NOT a real FK, and must be counted the same way everywhere so
    the old truthy-vs-parse divergence can never resurface.
    """

    def test_counts_only_parseable_fk_targets(self):
        attrs = [
            {"name": "a", "foreign_key_to": "sales.order.id"},   # 3-part: FK
            {"name": "b", "foreign_key_to": "order.id"},          # 2-part: FK
            {"name": "c", "foreign_key_to": ""},                  # empty: not FK
            {"name": "d"},                                         # missing: not FK
        ]
        assert count_fk_attributes(attrs) == 2

    def test_malformed_single_part_target_is_not_counted(self):
        """A non-empty single-part ``foreign_key_to`` is unparseable and must
        NOT be counted as an FK — locking the canonical predicate against the
        legacy truthy test that would have counted it."""
        attrs = [
            {"name": "ok", "foreign_key_to": "sales.order.id"},
            {"name": "bad", "foreign_key_to": "garbage"},  # truthy but unparseable
        ]
        assert is_fk_attribute(attrs[0]) is True
        assert is_fk_attribute(attrs[1]) is False
        assert count_fk_attributes(attrs) == 1

    def test_empty_iterable(self):
        assert count_fk_attributes([]) == 0


# ---------------------------------------------------------------------------
# Cross-endpoint FK-count consistency with deleted predecessor products
# (0.6.3 — the regression that would have caught the Ontology "1188" bug)
# ---------------------------------------------------------------------------


class TestFkCountCrossEndpointConsistency:
    """A v2 model whose v1 predecessor had a product that was deleted in v2.

    Every "foreign keys" surface (model-summary / relationships /
    domain-detail) must report the SAME canonical count for the CURRENT model,
    excluding the deleted predecessor product's FKs. v1's deleted ``legacy``
    product carries FK attributes; those must NOT leak into any v2 FK total.
    """

    @pytest.fixture
    def two_version_biz(self, engine):
        """Seed v1 (with a ``legacy`` product carrying 2 FK attrs) and v2
        (``legacy`` deleted; current products carry 3 FK attrs total, one of
        which has a malformed/unparseable ``foreign_key_to``)."""
        with Session(engine) as session:
            b = Business(name="FK Corp", description="FK consistency")
            session.add(b)
            session.flush()

            def _seed_version(version, products_by_domain):
                mv = ModelVersion(
                    business_id=b.id, version=version, scope="mvm",
                    status="completed",
                )
                session.add(mv)
                session.flush()
                for dname, products in products_by_domain.items():
                    d = Domain(version_id=mv.id, name=dname, division="Commercial",
                               description=f"{dname} domain", database_name=f"{dname}_db")
                    session.add(d)
                    session.flush()
                    for pname, attrs in products:
                        p = Product(
                            version_id=mv.id, domain_id=d.id, name=pname,
                            table_name=pname, primary_key=f"{pname}_id",
                        )
                        session.add(p)
                        session.flush()
                        for aname, fk in attrs:
                            session.add(Attribute(
                                product_id=p.id, name=aname, column_name=aname,
                                type="STRING", foreign_key_to=fk,
                            ))

            # v1: "legacy" product in sales carries 2 FK attrs that get deleted.
            _seed_version(1, {
                "sales": [
                    ("customer", [("customer_id", ""), ("region", "ops.region.id")]),
                    ("legacy", [("a_fk", "sales.customer.id"),
                                ("b_fk", "ops.region.id")]),
                ],
                "ops": [
                    ("region", [("region_id", "")]),
                ],
            })
            # v2: "legacy" deleted. Current FK attrs: customer.region (cross),
            # order.customer_ref (intra), order.broken (malformed/unparseable).
            _seed_version(2, {
                "sales": [
                    ("customer", [("customer_id", ""), ("region", "ops.region.id")]),
                    ("order", [("order_id", ""),
                               ("customer_ref", "sales.customer.id"),
                               ("broken", "garbage")]),
                ],
                "ops": [
                    ("region", [("region_id", "")]),
                ],
            })
            session.commit()
            return b.id

    def test_domain_detail_v2_includes_deleted_legacy_product(self, client, two_version_biz):
        """Sanity: ``get_domain_detail`` still surfaces the deleted ``legacy``
        product (so the diff/change UI works) — its FKs are the contamination
        the summary total must exclude."""
        resp = client.get(f"/api/businesses/{two_version_biz}/versions/2/mvm/domains/sales")
        assert resp.status_code == 200
        products = resp.json()["products"]
        by_name = {p["name"]: p for p in products}
        assert "legacy" in by_name
        assert by_name["legacy"]["change_status"] == "deleted"
        assert by_name["legacy"]["fk_count"] == 2

    def test_summary_fk_count_excludes_deleted_products(self, client, two_version_biz):
        """The canonical ``fk_count`` counts only the CURRENT model's parseable
        FK attrs: customer.region + order.customer_ref = 2. The malformed
        ``order.broken`` and the deleted ``legacy`` product's 2 FKs are out."""
        resp = client.get(f"/api/businesses/{two_version_biz}/versions/2/mvm/model")
        assert resp.status_code == 200
        assert resp.json()["fk_count"] == 2

    def test_all_fk_surfaces_agree(self, client, two_version_biz):
        """The centerpiece: model-summary fk_count == relationships total_fk
        == sum of domain-detail fk_count over NON-deleted products. All equal
        the canonical 2, with deleted-product FKs excluded everywhere."""
        base = f"/api/businesses/{two_version_biz}/versions/2/mvm"

        summary_fk = client.get(f"{base}/model").json()["fk_count"]
        rel_fk = client.get(f"{base}/relationships").json()["total_fk_count"]

        domain_sum = 0
        summary = client.get(f"{base}/model").json()
        for dom in summary["domains"]:
            detail = client.get(f"{base}/domains/{dom['name']}").json()
            domain_sum += sum(
                p["fk_count"] for p in detail["products"]
                if p.get("change_status") != "deleted"
            )

        assert summary_fk == rel_fk == domain_sum == 2

    def test_relationships_split_excludes_deleted_and_malformed(self, client, two_version_biz):
        """Relationships intra+cross split sums to the canonical total and the
        malformed FK never lands in either bucket."""
        rel = client.get(f"/api/businesses/{two_version_biz}/versions/2/mvm/relationships").json()
        assert rel["intra_domain_fk_count"] + rel["cross_domain_fk_count"] == rel["total_fk_count"]
        assert rel["total_fk_count"] == 2
        assert rel["intra_domain_fk_count"] == 1  # order.customer_ref
        assert rel["cross_domain_fk_count"] == 1  # customer.region -> ops

    def test_evolution_size_fk_count_matches_canonical_and_summary(self, client, two_version_biz):
        """Cross-MODULE contract: the evolution-metrics structure-size
        ``fk_count`` (the LIVE primary source for the Statistics Size & Effort
        FK number) is computed with the canonical predicate, so on a model
        carrying a malformed ``foreign_key_to`` it equals both
        ``count_fk_attributes`` over the same attrs AND the model-summary
        ``fk_count``. This locks the formerly-divergent truthy-after-strip
        path to the same answer as the Ontology/Overview count."""
        # Same shape the v2 fixture persists: 2 parseable FKs + 1 malformed.
        model = {
            "domains": [
                {"name": "sales", "products": [
                    {"name": "customer", "attributes": [
                        {"name": "customer_id", "foreign_key_to": ""},
                        {"name": "region", "foreign_key_to": "ops.region.id"},
                    ]},
                    {"name": "order", "attributes": [
                        {"name": "order_id", "foreign_key_to": ""},
                        {"name": "customer_ref", "foreign_key_to": "sales.customer.id"},
                        {"name": "broken", "foreign_key_to": "garbage"},
                    ]},
                ]},
                {"name": "ops", "products": [
                    {"name": "region", "attributes": [
                        {"name": "region_id", "foreign_key_to": ""},
                    ]},
                ]},
            ],
        }
        attrs = [
            a for d in model["domains"]
            for p in d["products"]
            for a in p["attributes"]
        ]
        canonical = count_fk_attributes(attrs)
        assert canonical == 2  # malformed "garbage" excluded

        evo_size = _structure_size_fallback(model)
        assert evo_size.fk_count == canonical

        summary_fk = client.get(
            f"/api/businesses/{two_version_biz}/versions/2/mvm/model"
        ).json()["fk_count"]
        assert evo_size.fk_count == summary_fk == 2
