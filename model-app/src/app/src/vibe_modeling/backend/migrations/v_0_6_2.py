"""Migration 0.6.2 — Vibe Inputs redesign schema (single feature migration).

The SOLE migration for the whole Vibe Inputs redesign (the model-versioning work Tasks 2,
3 and 4). The redesign ships as one schema version, not a version bump per
task, so every new table + column lives here. Adds the durable Vibe Inputs
tables, the element-lineage table, the backfill health row, and the
element-lineage columns:

New tables (7):
  - ``vibe_inputs`` — umbrella durable-content row (user feedback +
    agent next-vibe); origin/author/priority/consumed/status lifecycle.
  - ``vibe_input_context_links`` — input↔(version+element) anchor with
    nullable element FKs (all-null = model-wide) and a UNIQUE(input_id,
    version_id) anchor rule.
  - ``run_input_links`` — immutable run↔input usage audit, composite PK.
    Logically replaces ``run_feedback_links`` (which is left in place for
    the Task 3 backfill).
  - ``subdomains`` — promoted optional subdomain element with a
    prior-version self-pointer.
  - ``domain_reviews`` — per-version domain review marker, UNIQUE(version_id,
    domain_id).
  - ``run_element_lineage`` — element rename/merge/delete edge table (the
    facts a single ``previous_element_id`` self-FK cannot express — merges
    N:1, deletes 1:0 — plus cheap rename audit rows). Task 4.
  - ``backfill_status`` — singleton health row for the Task-3 boot-time
    backfill (``state`` ∈ {``ok``, ``backfill_incomplete``} + per-source
    ``report_json``); durable + queryable so a fail-soft failure stays
    observable.

Changed tables (additive columns only):
  - ``domains``/``products``/``attributes``/``foreign_key_links``/``subdomains``
    gain a nullable ``previous_element_id`` self-FK (prior-version lineage).
  - ``products`` gains a nullable ``subdomain_id`` FK; the transitional
    ``subdomain`` string column is kept.

Strictly additive — no drops, no renames. Idempotent on both dialects
(Postgres: ``CREATE TABLE/INDEX IF NOT EXISTS`` + ``ADD COLUMN IF NOT
EXISTS``; SQLite: ``CREATE TABLE/INDEX IF NOT EXISTS`` + PRAGMA-guarded
``ADD COLUMN``). UNIQUE constraints ride the ``CREATE TABLE`` body so they
need no separate idempotency guard.
"""

from __future__ import annotations

from sqlalchemy import text
from sqlalchemy.engine import Engine

from .registry import Migration


# (table, column) pairs added via ALTER on pre-existing tables. The
# subdomains.previous_element_id column is created with the table, not here.
_ADD_COLUMNS = [
    ("domains", "previous_element_id"),
    ("products", "previous_element_id"),
    ("products", "subdomain_id"),
    ("attributes", "previous_element_id"),
    ("foreign_key_links", "previous_element_id"),
]

# Typed (non-VARCHAR) additive columns on pre-existing tables. selected_for_run
# rides the vibe_inputs CREATE TABLE body for fresh installs; this ALTER covers
# the case where vibe_inputs already exists from an earlier apply.
_ADD_BOOL_COLUMNS = [
    ("vibe_inputs", "selected_for_run"),
]

# CREATE TABLE bodies — identical DDL on both dialects (VARCHAR/BOOLEAN/
# FLOAT/TIMESTAMP are accepted by SQLite and Postgres alike).
_CREATE_TABLES = [
    """
    CREATE TABLE IF NOT EXISTS vibe_inputs (
        id VARCHAR NOT NULL PRIMARY KEY,
        business_id VARCHAR NOT NULL REFERENCES businesses(id),
        origin VARCHAR NOT NULL DEFAULT 'user',
        author VARCHAR NOT NULL DEFAULT '',
        text TEXT NOT NULL DEFAULT '',
        priority VARCHAR NOT NULL DEFAULT 'medium',
        confidence_score FLOAT,
        consumed BOOLEAN NOT NULL DEFAULT false,
        selected_for_run BOOLEAN NOT NULL DEFAULT false,
        status VARCHAR NOT NULL DEFAULT 'active',
        deprecated_by VARCHAR,
        created_at TIMESTAMP NOT NULL,
        updated_at TIMESTAMP NOT NULL
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS subdomains (
        id VARCHAR NOT NULL PRIMARY KEY,
        version_id VARCHAR NOT NULL REFERENCES model_versions(id),
        domain_id VARCHAR NOT NULL REFERENCES domains(id),
        name VARCHAR NOT NULL DEFAULT '',
        previous_element_id VARCHAR REFERENCES subdomains(id),
        created_at TIMESTAMP NOT NULL
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS vibe_input_context_links (
        id VARCHAR NOT NULL PRIMARY KEY,
        input_id VARCHAR NOT NULL REFERENCES vibe_inputs(id),
        version_id VARCHAR NOT NULL REFERENCES model_versions(id),
        domain_id VARCHAR REFERENCES domains(id),
        subdomain_id VARCHAR REFERENCES subdomains(id),
        product_id VARCHAR REFERENCES products(id),
        attribute_id VARCHAR REFERENCES attributes(id),
        fk_link_id VARCHAR REFERENCES foreign_key_links(id),
        is_origin BOOLEAN NOT NULL DEFAULT false,
        needs_link_review BOOLEAN NOT NULL DEFAULT false,
        reviewed_by VARCHAR,
        reviewed_at TIMESTAMP,
        created_at TIMESTAMP NOT NULL,
        CONSTRAINT uq_vibe_input_context_links_input_version
            UNIQUE (input_id, version_id)
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS run_input_links (
        run_id VARCHAR NOT NULL REFERENCES runs(id),
        input_id VARCHAR NOT NULL REFERENCES vibe_inputs(id),
        created_at TIMESTAMP NOT NULL,
        PRIMARY KEY (run_id, input_id)
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS domain_reviews (
        id VARCHAR NOT NULL PRIMARY KEY,
        version_id VARCHAR NOT NULL REFERENCES model_versions(id),
        domain_id VARCHAR NOT NULL REFERENCES domains(id),
        reviewer VARCHAR NOT NULL DEFAULT '',
        reviewed_at TIMESTAMP NOT NULL,
        CONSTRAINT uq_domain_reviews_version_domain
            UNIQUE (version_id, domain_id)
    )
    """,
    # Element rename/merge/delete lineage edge table (the facts a single
    # previous_element_id self-FK cannot express — merges N:1, deletes 1:0,
    # plus cheap rename audit rows). FKs ride the CREATE TABLE body.
    """
    CREATE TABLE IF NOT EXISTS run_element_lineage (
        id VARCHAR NOT NULL PRIMARY KEY,
        run_id VARCHAR NOT NULL REFERENCES runs(id),
        version_id VARCHAR NOT NULL REFERENCES model_versions(id),
        element_type VARCHAR NOT NULL DEFAULT '',
        change_kind VARCHAR NOT NULL DEFAULT '',
        old_element_id VARCHAR,
        new_element_id VARCHAR,
        old_fqn VARCHAR NOT NULL DEFAULT '',
        new_fqn VARCHAR NOT NULL DEFAULT '',
        reason VARCHAR NOT NULL DEFAULT '',
        created_at TIMESTAMP NOT NULL
    )
    """,
    # Singleton health row for the Task-3 boot-time backfill (state ∈
    # {ok, backfill_incomplete} + per-source report_json). Durable +
    # queryable so a fail-soft backfill failure stays observable.
    """
    CREATE TABLE IF NOT EXISTS backfill_status (
        id INTEGER NOT NULL PRIMARY KEY,
        state VARCHAR NOT NULL DEFAULT 'ok',
        report_json TEXT NOT NULL DEFAULT '{}',
        updated_at TIMESTAMP NOT NULL
    )
    """,
]

# Explicit indexes for FK columns marked index=True on the SQLModel side.
# create_all only emits these at table-creation time, so the DDL-only
# Postgres path needs them issued explicitly.
_CREATE_INDEXES = [
    "CREATE INDEX IF NOT EXISTS ix_vibe_inputs_business_id ON vibe_inputs (business_id)",
    "CREATE INDEX IF NOT EXISTS ix_vibe_inputs_origin ON vibe_inputs (origin)",
    "CREATE INDEX IF NOT EXISTS ix_vibe_inputs_priority ON vibe_inputs (priority)",
    "CREATE INDEX IF NOT EXISTS ix_vibe_inputs_consumed ON vibe_inputs (consumed)",
    "CREATE INDEX IF NOT EXISTS ix_vibe_inputs_selected_for_run ON vibe_inputs (selected_for_run)",
    "CREATE INDEX IF NOT EXISTS ix_vibe_inputs_status ON vibe_inputs (status)",
    "CREATE INDEX IF NOT EXISTS ix_vibe_input_context_links_input_id ON vibe_input_context_links (input_id)",
    "CREATE INDEX IF NOT EXISTS ix_vibe_input_context_links_version_id ON vibe_input_context_links (version_id)",
    "CREATE INDEX IF NOT EXISTS ix_subdomains_version_id ON subdomains (version_id)",
    "CREATE INDEX IF NOT EXISTS ix_subdomains_domain_id ON subdomains (domain_id)",
    "CREATE INDEX IF NOT EXISTS ix_domain_reviews_version_id ON domain_reviews (version_id)",
    "CREATE INDEX IF NOT EXISTS ix_domain_reviews_domain_id ON domain_reviews (domain_id)",
    "CREATE INDEX IF NOT EXISTS ix_products_subdomain_id ON products (subdomain_id)",
    "CREATE INDEX IF NOT EXISTS ix_run_element_lineage_run_id ON run_element_lineage (run_id)",
    "CREATE INDEX IF NOT EXISTS ix_run_element_lineage_version_id ON run_element_lineage (version_id)",
    "CREATE INDEX IF NOT EXISTS ix_run_element_lineage_element_type ON run_element_lineage (element_type)",
    "CREATE INDEX IF NOT EXISTS ix_run_element_lineage_change_kind ON run_element_lineage (change_kind)",
]


def apply(engine: Engine) -> None:
    """Create the Vibe Inputs tables + element-lineage columns (additive)."""
    dialect = engine.dialect.name
    with engine.begin() as conn:
        for ddl in _CREATE_TABLES:
            conn.execute(text(ddl))

        if dialect == "postgresql":
            for table, column in _ADD_COLUMNS:
                conn.execute(
                    text(
                        f"ALTER TABLE {table} "
                        f"ADD COLUMN IF NOT EXISTS {column} VARCHAR"
                    )
                )
            for table, column in _ADD_BOOL_COLUMNS:
                conn.execute(
                    text(
                        f"ALTER TABLE {table} "
                        f"ADD COLUMN IF NOT EXISTS {column} "
                        f"BOOLEAN NOT NULL DEFAULT false"
                    )
                )
        else:
            # SQLite (tests). PRAGMA-check first since SQLite ADD COLUMN
            # lacks IF NOT EXISTS.
            for table, column in _ADD_COLUMNS:
                cols = conn.execute(text(f"PRAGMA table_info({table})")).fetchall()
                present = {row[1] for row in cols}
                if column not in present:
                    conn.execute(
                        text(f"ALTER TABLE {table} ADD COLUMN {column} VARCHAR")
                    )
            for table, column in _ADD_BOOL_COLUMNS:
                cols = conn.execute(text(f"PRAGMA table_info({table})")).fetchall()
                present = {row[1] for row in cols}
                if column not in present:
                    conn.execute(
                        text(
                            f"ALTER TABLE {table} ADD COLUMN {column} "
                            f"BOOLEAN NOT NULL DEFAULT false"
                        )
                    )

        for ddl in _CREATE_INDEXES:
            conn.execute(text(ddl))


MIGRATION = Migration(
    version="0.6.2",
    apply=apply,
    description=(
        "Vibe Inputs redesign (single feature migration): add vibe_inputs, "
        "vibe_input_context_links, run_input_links, subdomains, "
        "domain_reviews, run_element_lineage, backfill_status tables + "
        "previous_element_id lineage columns and products.subdomain_id "
        "(additive only)"
    ),
)
