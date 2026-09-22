"""Shared bulk I/O for the model tree (Domain/Product/Attribute/ForeignKeyLink).

Three call sites used to do per-row SQLAlchemy ORM inserts/deletes over
model-scale data (6k-15k attributes) against a WAN-distant Lakebase Postgres:
industry kickstart's tree copy, force-resync's teardown, and
``sync_from_model_json``'s rebuild (shared by resync and run-completion
sync). Each per-row ``session.add()`` / ``session.delete()`` is a network
round trip; at 15k attributes that is the dominant cost. This module is the
one place that does the row-mechanics for all three, gated on DB dialect:

- Postgres gets set-based bulk SQL (one INSERT/DELETE statement per table,
  not one per row).
- SQLite (every unit test) keeps the pre-existing per-row ORM behavior as an
  explicit, intentional fallback - the default test engine
  (``tests/test_app/conftest.py::engine_fixture``) runs WITHOUT
  ``PRAGMA foreign_keys=ON``, so relying on DB-cascade deletes there would
  silently orphan rows instead of raising.

Column lists for the copy path are derived from SQLAlchemy table metadata at
call time (never hardcoded), so a future column addition is picked up by
both dialect paths automatically. Three columns are the deliberate exception,
excluded from every "copy source row's business content" list because the
pre-existing ``export_model_json`` -> ``sync_from_model_json`` round trip
(the behavior this module replaces) never carried them either:

- ``id`` - fresh per copied row; the whole point of a copy.
- ``created_at`` - the copy is a new row born now, not a historical replay.
- ``previous_element_id`` - a lineage pointer into the SOURCE version's own
  ancestry. Only ``ModelSyncService._link_previous_version`` (gated on
  ``run_id``) ever populates this, and the kickstart copy never passes one.

``Product.subdomain_id`` gets the same treatment: ``sync_from_model_json``
never sets it either (it is populated later by the subdomain-upsert lineage
pass, also gated on ``run_id``).
"""

from __future__ import annotations

from sqlalchemy import Column, MetaData, String, Table
from sqlalchemy import bindparam, func
from sqlalchemy import delete as sa_delete
from sqlalchemy import insert as sa_insert
from sqlalchemy import select as sa_select
from sqlalchemy import text
from sqlmodel import Session, select

from ..db_models import Attribute, Domain, ForeignKeyLink, Product

# Columns reset to their column default on every tree copy - see module
# docstring for why each one is excluded rather than copied verbatim.
_RESET_COLUMNS = {"id", "created_at", "previous_element_id"}
_PRODUCT_RESET_COLUMNS = _RESET_COLUMNS | {"subdomain_id"}


def _is_postgres(session: Session) -> bool:
    """Dialect gate: bulk set-based SQL on Postgres, ORM fallback on SQLite.

    Mirrors the ``engine.dialect.name == "postgresql"`` idiom used
    throughout ``migrations/`` (e.g. ``migrations/registry.py``).
    """
    return session.get_bind().dialect.name == "postgresql"


def _copy_columns(table_cls, *, exclude: set[str], remap: set[str]) -> list[str]:
    """Business-content column names to carry over from a source row to its
    copy: every column on ``table_cls`` except ``exclude`` (reset to
    default) and ``remap`` (a foreign key the caller rewrites to the new
    parent id separately). Derived from table metadata, never hardcoded."""
    return [
        c.name
        for c in table_cls.__table__.columns
        if c.name not in exclude and c.name not in remap
    ]


def _temp_map_table(name: str) -> Table:
    """Core ``Table`` handle for an already-created (via raw DDL) temp
    id-mapping table, so join/select statements against it go through
    SQLAlchemy Core's compiler - never a bare f-string identifier - even
    though the table itself lives outside any ``MetaData`` this module owns.
    """
    return Table(
        name,
        MetaData(),
        Column("old_id", String, primary_key=True),
        Column("new_id", String),
    )


def _domain_copy_insert(domain_map: Table):
    """Core ``INSERT INTO domains ... SELECT ...`` statement copying every
    business-content column of ``Domain`` (including the reserved-word
    ``references`` column) into fresh ids from ``domain_map``. Column
    identifiers come from ``Domain.__table__`` so SQLAlchemy's own dialect
    compiler quotes them, never a hand-built string."""
    d = Domain.__table__
    cols = _copy_columns(Domain, exclude=_RESET_COLUMNS, remap={"version_id"})
    return d.insert().from_select(
        ["id", "version_id", *cols],
        sa_select(
            domain_map.c.new_id,
            bindparam("tgt"),
            *[d.c[c] for c in cols],
        ).select_from(d.join(domain_map, domain_map.c.old_id == d.c.id)),
    )


def _product_copy_insert(domain_map: Table, product_map: Table):
    """Core ``INSERT INTO products ... SELECT ...`` statement, re-parenting
    each copied product to its remapped domain id."""
    p = Product.__table__
    cols = _copy_columns(
        Product, exclude=_PRODUCT_RESET_COLUMNS, remap={"version_id", "domain_id"}
    )
    return p.insert().from_select(
        ["id", "version_id", "domain_id", *cols],
        sa_select(
            product_map.c.new_id,
            bindparam("tgt"),
            domain_map.c.new_id,
            *[p.c[c] for c in cols],
        ).select_from(
            p.join(domain_map, domain_map.c.old_id == p.c.domain_id)
            .join(product_map, product_map.c.old_id == p.c.id)
        ),
    )


def _attribute_copy_insert(product_map: Table):
    """Core ``INSERT INTO attributes ... SELECT ...`` statement (including
    the reserved-word ``references`` column), with fresh ids from
    ``gen_random_uuid()`` embedded as a Core ``func`` call, not an outer
    f-string wrapping the whole statement."""
    a = Attribute.__table__
    cols = _copy_columns(Attribute, exclude=_RESET_COLUMNS, remap={"product_id"})
    return a.insert().from_select(
        ["id", "product_id", *cols],
        sa_select(
            func.gen_random_uuid(),
            product_map.c.new_id,
            *[a.c[c] for c in cols],
        ).select_from(a.join(product_map, product_map.c.old_id == a.c.product_id)),
    )


def _fk_link_copy_insert():
    """Core ``INSERT INTO foreign_key_links ... SELECT ...`` statement."""
    f = ForeignKeyLink.__table__
    cols = _copy_columns(ForeignKeyLink, exclude=_RESET_COLUMNS, remap={"version_id"})
    return f.insert().from_select(
        ["id", "version_id", *cols],
        sa_select(
            func.gen_random_uuid(),
            bindparam("tgt"),
            *[f.c[c] for c in cols],
        ).select_from(f).where(f.c.version_id == bindparam("src")),
    )


def _row_values(obj) -> dict:
    """Flatten an ORM instance into a column-name -> value dict for a raw
    multi-row INSERT. Safe here because every model this is used on (the
    four element tables, plus ``VibeInputContextLink`` in
    ``industry_kickstart``'s batched re-anchor insert) has Python attribute
    names matching their column names 1:1 (no ``sa_column`` aliasing)."""
    return {c.name: getattr(obj, c.name) for c in obj.__table__.columns}


# ---------------------------------------------------------------------------
# Copy: source ModelVersion's tree -> target ModelVersion, with fresh ids.
# ---------------------------------------------------------------------------


def copy_model_tree(
    session: Session, *, source_version_id: str, target_version_id: str
) -> dict[str, int]:
    """Copy domains -> products -> attributes -> fk_links from
    ``source_version_id`` into ``target_version_id`` with FRESH ids.

    Business-content columns are copied verbatim (see module docstring for
    the ``id``/``created_at``/``previous_element_id``/``subdomain_id``
    exceptions). ``ForeignKeyLink`` rows reference elements by NAME
    (``source_domain``/``source_product``/... are plain strings, not FKs),
    so they copy straight across with no id remap. Returns per-entity copied
    counts (``domains``/``products``/``attributes``/``fk_links``).
    """
    if _is_postgres(session):
        return _copy_model_tree_pg(session, source_version_id, target_version_id)
    return _copy_model_tree_orm(session, source_version_id, target_version_id)


def _copy_model_tree_orm(
    session: Session, source_version_id: str, target_version_id: str
) -> dict[str, int]:
    """SQLite / non-Postgres fallback: per-row ORM copy.

    Ids are available immediately on construction (every element model uses
    a client-side ``default_factory``, not a DB-generated default), so no
    intermediate flush is needed to learn a parent id before building its
    children - unlike the pre-existing per-row loops this module replaces,
    which flushed defensively even though it was never required for that.
    """
    counts = {"domains": 0, "products": 0, "attributes": 0, "fk_links": 0}
    domain_cols = _copy_columns(Domain, exclude=_RESET_COLUMNS, remap={"version_id"})
    product_cols = _copy_columns(
        Product, exclude=_PRODUCT_RESET_COLUMNS, remap={"version_id", "domain_id"}
    )
    attribute_cols = _copy_columns(Attribute, exclude=_RESET_COLUMNS, remap={"product_id"})
    fk_link_cols = _copy_columns(ForeignKeyLink, exclude=_RESET_COLUMNS, remap={"version_id"})

    src_domains = session.exec(
        select(Domain).where(Domain.version_id == source_version_id)
    ).all()
    for d in src_domains:
        new_domain = Domain(
            version_id=target_version_id,
            **{c: getattr(d, c) for c in domain_cols},
        )
        session.add(new_domain)
        counts["domains"] += 1

        src_products = session.exec(
            select(Product).where(Product.domain_id == d.id)
        ).all()
        for p in src_products:
            new_product = Product(
                version_id=target_version_id,
                domain_id=new_domain.id,
                **{c: getattr(p, c) for c in product_cols},
            )
            session.add(new_product)
            counts["products"] += 1

            src_attrs = session.exec(
                select(Attribute).where(Attribute.product_id == p.id)
            ).all()
            for a in src_attrs:
                session.add(Attribute(
                    product_id=new_product.id,
                    **{c: getattr(a, c) for c in attribute_cols},
                ))
                counts["attributes"] += 1

    src_fks = session.exec(
        select(ForeignKeyLink).where(ForeignKeyLink.version_id == source_version_id)
    ).all()
    for f in src_fks:
        session.add(ForeignKeyLink(
            version_id=target_version_id,
            **{c: getattr(f, c) for c in fk_link_cols},
        ))
        counts["fk_links"] += 1

    session.flush()
    return counts


def _copy_model_tree_pg(
    session: Session, source_version_id: str, target_version_id: str
) -> dict[str, int]:
    """Postgres set-based copy: one INSERT...SELECT per table, id remapping
    done via temp mapping tables (dropped automatically at commit)."""
    conn = session.connection()
    counts = {
        "domains": conn.execute(
            text("SELECT count(*) FROM domains WHERE version_id = :src"),
            {"src": source_version_id},
        ).scalar()
        or 0,
        "products": conn.execute(
            text(
                "SELECT count(*) FROM products p "
                "JOIN domains d ON d.id = p.domain_id "
                "WHERE d.version_id = :src"
            ),
            {"src": source_version_id},
        ).scalar()
        or 0,
        "attributes": conn.execute(
            text(
                "SELECT count(*) FROM attributes a "
                "JOIN products p ON p.id = a.product_id "
                "JOIN domains d ON d.id = p.domain_id "
                "WHERE d.version_id = :src"
            ),
            {"src": source_version_id},
        ).scalar()
        or 0,
        "fk_links": conn.execute(
            text("SELECT count(*) FROM foreign_key_links WHERE version_id = :src"),
            {"src": source_version_id},
        ).scalar()
        or 0,
    }

    conn.execute(text("DROP TABLE IF EXISTS _bulk_domain_map"))
    conn.execute(text(
        "CREATE TEMP TABLE _bulk_domain_map (old_id text PRIMARY KEY, new_id text) "
        "ON COMMIT DROP"
    ))
    conn.execute(text(
        "INSERT INTO _bulk_domain_map "
        "SELECT id, gen_random_uuid()::text FROM domains WHERE version_id = :src"
    ), {"src": source_version_id})

    domain_map = _temp_map_table("_bulk_domain_map")
    conn.execute(_domain_copy_insert(domain_map), {"tgt": target_version_id})

    conn.execute(text("DROP TABLE IF EXISTS _bulk_product_map"))
    conn.execute(text(
        "CREATE TEMP TABLE _bulk_product_map (old_id text PRIMARY KEY, new_id text) "
        "ON COMMIT DROP"
    ))
    conn.execute(text(
        "INSERT INTO _bulk_product_map "
        "SELECT p.id, gen_random_uuid()::text FROM products p "
        "JOIN _bulk_domain_map dm ON dm.old_id = p.domain_id"
    ))

    product_map = _temp_map_table("_bulk_product_map")
    conn.execute(_product_copy_insert(domain_map, product_map), {"tgt": target_version_id})

    conn.execute(_attribute_copy_insert(product_map))

    conn.execute(
        _fk_link_copy_insert(), {"tgt": target_version_id, "src": source_version_id}
    )

    session.flush()
    return counts


# ---------------------------------------------------------------------------
# Delete: a version's element rows (idempotent resync teardown).
# ---------------------------------------------------------------------------


def bulk_delete_version_elements(session: Session, version_id: str) -> None:
    """Delete a version's Domain/Product/Attribute/ForeignKeyLink rows.

    Postgres: two set-based DELETEs (``foreign_key_links`` then ``domains``,
    both filtered by ``version_id``) - the DB-declared cascades
    (``products.domain_id``, ``attributes.product_id``,
    ``subdomains.domain_id``, ``product_reviews.product_id``, all
    ``ON DELETE CASCADE``) do the rest, one round trip per statement instead
    of one per row.

    SQLite (unit tests): explicit per-row ORM delete, unchanged from the
    pre-bulk-I/O behavior. The default test engine
    (``tests/test_app/conftest.py::engine_fixture``) runs WITHOUT
    ``PRAGMA foreign_keys=ON``, so a raw DELETE relying on DB cascade there
    would silently leave orphaned rows instead of cleaning them up.

    Callers own the capture/detach of anchored ``VibeInputContextLink`` rows
    BEFORE calling this (that contract is untouched by this module) and the
    re-anchor AFTER the rebuild.
    """
    if _is_postgres(session):
        conn = session.connection()
        conn.execute(sa_delete(ForeignKeyLink).where(ForeignKeyLink.version_id == version_id))
        conn.execute(sa_delete(Domain).where(Domain.version_id == version_id))
        session.flush()
        return
    _delete_version_elements_orm(session, version_id)


def _delete_version_elements_orm(session: Session, version_id: str) -> None:
    fk_links = session.exec(
        select(ForeignKeyLink).where(ForeignKeyLink.version_id == version_id)
    ).all()
    for fk in fk_links:
        session.delete(fk)

    domains = session.exec(
        select(Domain).where(Domain.version_id == version_id)
    ).all()
    for domain in domains:
        products = session.exec(
            select(Product).where(Product.domain_id == domain.id)
        ).all()
        for product in products:
            attrs = session.exec(
                select(Attribute).where(Attribute.product_id == product.id)
            ).all()
            for attr in attrs:
                session.delete(attr)
            session.delete(product)
        session.delete(domain)

    session.flush()


# ---------------------------------------------------------------------------
# Insert: rebuild a version's element rows from freshly-built ORM objects.
# ---------------------------------------------------------------------------


def bulk_insert_elements(
    session: Session,
    *,
    domains: list[Domain],
    products: list[Product],
    attributes: list[Attribute],
    fk_links: list[ForeignKeyLink],
) -> None:
    """Write freshly-built Domain/Product/Attribute/ForeignKeyLink ORM
    objects into the DB. Callers build the full object graph first (ids are
    already assigned via each model's client-side ``default_factory`` before
    this is called, so parent ids are available with no DB round trip).

    Postgres: one multi-row INSERT per table (executemany), replacing what
    used to be a per-row ``session.add()`` interleaved with per-row
    ``flush()`` calls.

    SQLite (unit tests): ``session.add()`` for every object, one flush at
    the end - the same rows, same values, same order as the original
    per-row loop; only the flush cadence changes, which no test in this
    codebase depends on (ids never came from a DB-generated default here).
    """
    if _is_postgres(session):
        conn = session.connection()
        if domains:
            conn.execute(sa_insert(Domain), [_row_values(d) for d in domains])
        if products:
            conn.execute(sa_insert(Product), [_row_values(p) for p in products])
        if attributes:
            conn.execute(sa_insert(Attribute), [_row_values(a) for a in attributes])
        if fk_links:
            conn.execute(sa_insert(ForeignKeyLink), [_row_values(f) for f in fk_links])
        session.flush()
        return

    for d in domains:
        session.add(d)
    for p in products:
        session.add(p)
    for a in attributes:
        session.add(a)
    for f in fk_links:
        session.add(f)
    session.flush()
