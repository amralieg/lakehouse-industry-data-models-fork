"""Tests for the ``searchModelElements`` endpoint (Track 6 item 2, backend).

Model-wide name search over domains, products/tables and attributes/columns,
version-scoped and ranked exact > prefix > substring, then domain > product >
attribute within a tier.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from sqlalchemy import event
from sqlmodel import Session

from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    Domain,
    ModelVersion,
    Product,
)


class TestSearchModelElements:
    @pytest.fixture
    def seeded(self, engine):
        """Seed a two-version business so scoping and ranking are exercised.

        v1 (mvm): domain ``sales`` -> product ``customer`` (table ``customer``)
        with attributes ``customer_id`` and ``customer_email``; a second domain
        ``customer_service`` (name collides with the product/attr substring).
        v2 (mvm): domain ``other`` -> product ``customer_archive`` with an
        attribute ``customer_ref`` - used to prove v2 rows never leak into a v1
        search.
        """
        with Session(engine) as session:
            b = Business(name="Search Corp", description="Testing search")
            session.add(b)
            session.flush()

            mv1 = ModelVersion(business_id=b.id, version=1, scope="mvm", status="completed")
            mv2 = ModelVersion(business_id=b.id, version=2, scope="mvm", status="completed")
            session.add(mv1)
            session.add(mv2)
            session.flush()

            sales = Domain(version_id=mv1.id, name="sales", division="Commercial")
            cust_svc = Domain(version_id=mv1.id, name="customer_service", division="Support")
            session.add(sales)
            session.add(cust_svc)
            session.flush()

            customer = Product(
                version_id=mv1.id, domain_id=sales.id, name="customer",
                table_name="customer", description="Customer master",
            )
            session.add(customer)
            session.flush()

            session.add(Attribute(
                product_id=customer.id, name="customer_id", column_name="customer_id",
                type="BIGINT",
            ))
            session.add(Attribute(
                product_id=customer.id, name="customer_email", column_name="email",
                type="STRING",
            ))

            # v2 rows - must never appear in a v1 search.
            other = Domain(version_id=mv2.id, name="other", division="Ops")
            session.add(other)
            session.flush()
            archive = Product(
                version_id=mv2.id, domain_id=other.id, name="customer_archive",
                table_name="customer_archive",
            )
            session.add(archive)
            session.flush()
            session.add(Attribute(
                product_id=archive.id, name="customer_ref", column_name="customer_ref",
                type="STRING",
            ))

            session.commit()
            return b.id

    def _search(self, client, business_id, q, scope="mvm", version=1, limit=None):
        url = f"/api/businesses/{business_id}/versions/{version}/{scope}/search?q={q}"
        if limit is not None:
            url += f"&limit={limit}"
        resp = client.get(url)
        assert resp.status_code == 200
        return resp.json()

    def test_domain_hit_shape(self, client, seeded):
        hits = self._search(client, seeded, "sales")
        assert len(hits) == 1
        hit = hits[0]
        assert hit["type"] == "domain"
        assert hit["domain_name"] == "sales"
        assert hit["product_name"] is None
        assert hit["attribute_name"] is None
        assert hit["label"] == "sales"
        assert hit["sublabel"] == "Commercial"

    def test_product_hit_shape(self, client, seeded):
        hits = self._search(client, seeded, "customer")
        product_hits = [h for h in hits if h["type"] == "product"]
        assert len(product_hits) == 1
        hit = product_hits[0]
        assert hit["domain_name"] == "sales"
        assert hit["product_name"] == "customer"
        assert hit["attribute_name"] is None
        assert hit["label"] == "customer"
        assert hit["sublabel"] == "sales"

    def test_product_matches_on_table_name(self, client, seeded):
        # ``customer`` product has table_name ``customer``; a table-name-only
        # search term still returns the product hit.
        hits = self._search(client, seeded, "customer")
        assert any(h["type"] == "product" and h["product_name"] == "customer" for h in hits)

    def test_attribute_hit_shape(self, client, seeded):
        hits = self._search(client, seeded, "customer_email")
        attr_hits = [h for h in hits if h["type"] == "attribute"]
        assert len(attr_hits) == 1
        hit = attr_hits[0]
        assert hit["domain_name"] == "sales"
        assert hit["product_name"] == "customer"
        assert hit["attribute_name"] == "customer_email"
        assert hit["label"] == "customer_email"
        assert hit["sublabel"] == "sales › customer"

    def test_attribute_matches_on_column_name(self, client, seeded):
        # ``customer_email`` attribute has column_name ``email``; a column-only
        # term returns it.
        hits = self._search(client, seeded, "email")
        assert any(
            h["type"] == "attribute" and h["attribute_name"] == "customer_email"
            for h in hits
        )

    def test_version_scoped(self, client, seeded):
        # v1 search must not surface v2's ``customer_archive`` / ``customer_ref``.
        hits = self._search(client, seeded, "customer", version=1)
        names = {(h["type"], h.get("product_name"), h.get("attribute_name")) for h in hits}
        assert ("product", "customer_archive", None) not in names
        assert ("attribute", "customer_archive", "customer_ref") not in names
        for h in hits:
            assert h["domain_name"] != "other"

    def test_version_scoped_v2_returns_own_rows(self, client, seeded):
        hits = self._search(client, seeded, "customer", version=2)
        assert any(h["type"] == "product" and h["product_name"] == "customer_archive" for h in hits)
        assert all(h["domain_name"] != "sales" for h in hits)

    def test_ranking_exact_before_prefix_before_substring(self, client, seeded):
        # For "customer": exact = product/domain "customer"?  The product name is
        # exactly "customer" (exact), the domain "customer_service" is a prefix
        # match, and the attributes "customer_id"/"customer_email" are prefix.
        hits = self._search(client, seeded, "customer")
        # First hit is the exact-name match.
        assert hits[0]["label"] == "customer"
        # Within the same tier, domain outranks product outranks attribute:
        # "customer_service" (domain, prefix) precedes the prefix attributes.
        labels = [h["label"] for h in hits]
        assert labels.index("customer_service") < labels.index("customer_id")

    def test_empty_query_returns_empty(self, client, seeded):
        hits = self._search(client, seeded, "")
        assert hits == []

    def test_whitespace_query_returns_empty(self, client, seeded):
        hits = self._search(client, seeded, "%20%20")
        assert hits == []

    def test_no_match_returns_empty(self, client, seeded):
        hits = self._search(client, seeded, "zzznotfound")
        assert hits == []

    def test_missing_version_returns_empty(self, client, seeded):
        hits = self._search(client, seeded, "customer", version=99)
        assert hits == []

    def test_limit_caps_results(self, client, seeded):
        hits = self._search(client, seeded, "customer", limit=1)
        assert len(hits) == 1

    def test_wildcard_input_is_literal(self, client, seeded):
        # A bare "%" must not act as match-all; nothing is named with a literal %.
        hits = self._search(client, seeded, "%25")  # url-encoded '%'
        assert hits == []

    def test_single_round_trip(self, client, seeded, engine):
        """The whole search is ONE SQL statement (version lookup folded into the
        UNION via a scalar subquery) - no per-element-type round-trips, no
        separate version-resolution query. Guards the latency fix."""
        selects: list[str] = []

        def _count(conn, cursor, statement, params, context, executemany):
            if statement.lstrip().upper().startswith("SELECT"):
                selects.append(statement)

        event.listen(engine, "before_cursor_execute", _count)
        try:
            resp = client.get(
                f"/api/businesses/{seeded}/versions/1/mvm/search?q=customer"
            )
            assert resp.status_code == 200
            assert len(resp.json()) > 0
        finally:
            event.remove(engine, "before_cursor_execute", _count)

        assert len(selects) == 1, (
            f"expected exactly 1 SELECT for the search, got {len(selects)}:\n"
            + "\n---\n".join(selects)
        )

    def test_split_domain_deduplicated(self, engine, client):
        """Split (domain × subdomain) rows share a name; one hit per domain."""
        with Session(engine) as session:
            b = Business(name="Split Corp")
            session.add(b)
            session.flush()
            mv = ModelVersion(business_id=b.id, version=1, scope="mvm", status="completed")
            session.add(mv)
            session.flush()
            for _ in range(3):
                session.add(Domain(version_id=mv.id, name="engagement", division="Commercial"))
            session.commit()
            bid = b.id
        hits = self._search(client, bid, "engagement")
        domain_hits = [h for h in hits if h["type"] == "domain"]
        assert len(domain_hits) == 1
