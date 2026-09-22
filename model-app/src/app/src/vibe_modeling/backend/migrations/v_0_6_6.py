"""Migration 0.6.6 - DB-level delete integrity + legacy feedback retirement
+ search trigram indexes.

Three tasks, one migration:

1. **DB-level delete referential integrity.** Every inbound FK that the
   collapsed delete paths rely on gets an explicit ``ON DELETE`` action
   (:data:`FK_RULES`): containment/ownership columns CASCADE, provenance/
   detachable references SET NULL. This replaces the hand-rolled cascade
   code that walked child tables in Python because the test workspace's live FKs were all
   NO ACTION.

2. **Legacy feedback subsystem retirement.** The ``feedback`` and
   ``run_feedback_links`` tables are dropped (their content was re-materialized
   into Vibe Inputs at the 0.6.3 cutover), along with ``backfill_status`` (its
   only purpose was reporting that backfill).

3. **Search trigram indexes.** ``pg_trgm`` GIN indexes on
   ``attributes.name`` / ``attributes.column_name`` (:data:`TRGM_INDEX_COLUMNS`,
   Postgres only, best-effort) give ``searchModelElements``'s attribute-name
   ILIKE filter a usable access path instead of a scan. Live EXPLAIN ANALYZE
   on a 15k-attribute production fork confirmed the index alone flips the
   attributes branch from a Parallel Seq Scan (350-368ms) to a bitmap index
   plan (10-20ms) - a query-shape rewrite of ``explorer.search_model_elements``
   was tried first but Postgres flattens it back to the same seq-scan plan, so
   it was reverted; the index is the entire fix.

Operation order (single ``engine.begin()`` transaction, idempotent,
re-runnable mid-failure):

1. Data check (log-only, both dialects): row counts of ``feedback`` /
   ``run_feedback_links`` plus ``vibe_inputs WHERE origin='user'`` so the
   operator can eyeball backfill coverage. Non-blocking.
2. ``DROP TABLE IF EXISTS run_feedback_links`` then ``feedback`` (child
   first) then ``backfill_status`` (both dialects, plain drops).
3. Index the SET NULL self-FK referencing columns (:data:`SELF_FK_INDEX_COLUMNS`,
   both dialects, ``CREATE INDEX IF NOT EXISTS``): an unindexed child column
   makes the SET NULL cascade seq-scan the child table per deleted parent row.
4. Pre-clean orphaned ``businesses.source_industry_id`` (Postgres only):
   NULL any value that does not point at a live business. MUST run before the
   FK loop adds ``source_industry_id``'s constraint - the column was declared
   but never enforced live, so orphaned values are expected, and an
   ``ADD CONSTRAINT`` would fail on the first orphan.
5. FK re-pointing (Postgres only): for each :data:`FK_RULES` row, discover the
   live constraint name(s) from ``pg_constraint`` (do NOT assume the default
   ``<child>_<column>_fkey`` name is what is installed), ``DROP CONSTRAINT``
   them, then ``ADD CONSTRAINT <child>_<column>_fkey ... ON DELETE <action>``.
   ``source_industry_id`` is ADD-only (no live constraint to drop).
6. Trigram indexes (Postgres only, best-effort): ``CREATE EXTENSION IF NOT
   EXISTS pg_trgm`` then ``CREATE INDEX IF NOT EXISTS ... USING gin (...
   gin_trgm_ops)`` for each :data:`TRGM_INDEX_COLUMNS` pair. Each statement
   runs inside its own SAVEPOINT so an unavailable extension (no superuser,
   not allow-listed) degrades this step only - it never fails steps 1-5 or
   aborts the migration.

SQLite gets steps 1-3 only. Fresh installs (both dialects) pick the rules up
from ``db_models`` ``ondelete=`` via ``v_0_1_0``'s ``create_all``; the SQLite
``fk_engine`` test fixture honors them with ``PRAGMA foreign_keys=ON``.

:data:`FK_RULES` is the single source of truth. The migration executes it, the
``db_models`` drift test asserts against it via SQLAlchemy metadata
introspection, and the owner script (``scripts/db/migrate.py``) IMPORTS it and
re-runs the same discover-drop-add sequence (transaction-wrapped, non-zero
exit on error). There is one definition and no mirror.
"""

from __future__ import annotations

import logging

from sqlalchemy import inspect, text
from sqlalchemy.engine import Connection, Engine

from .registry import Migration

logger = logging.getLogger(__name__)


# --- The single source of truth ----------------------------------------------
#
# ``(child_table, fk_column, parent_table, on_delete_action)``. The action is
# one of ``"CASCADE"`` or ``"SET NULL"``. Rules that stay NO ACTION are NOT
# listed here (they are the deliberate guards: ``businesses.industry_id`` /
# ``businesses.sector_id`` and the five ``vibe_input_context_links`` element
# anchors - see the design doc's "Keep NO ACTION" table). The parent column is
# always ``id`` (the app's UUID PK convention, D-045).
#
# CASCADE = composition (the child dies with the parent).
# SET NULL = provenance (the child row outlives the referent).

FK_RULES: list[tuple[str, str, str, str]] = [
    # --- CASCADE (composition) ---
    ("business_contexts", "business_id", "businesses", "CASCADE"),
    ("model_versions", "business_id", "businesses", "CASCADE"),
    ("runs", "business_id", "businesses", "CASCADE"),
    ("vibe_inputs", "business_id", "businesses", "CASCADE"),
    ("diagram_layouts", "business_id", "businesses", "CASCADE"),
    ("diagram_layouts", "version_id", "model_versions", "CASCADE"),
    ("domains", "version_id", "model_versions", "CASCADE"),
    ("subdomains", "version_id", "model_versions", "CASCADE"),
    ("subdomains", "domain_id", "domains", "CASCADE"),
    ("products", "version_id", "model_versions", "CASCADE"),
    ("products", "domain_id", "domains", "CASCADE"),
    ("products", "subdomain_id", "subdomains", "CASCADE"),
    ("attributes", "product_id", "products", "CASCADE"),
    ("foreign_key_links", "version_id", "model_versions", "CASCADE"),
    ("product_reviews", "version_id", "model_versions", "CASCADE"),
    ("product_reviews", "product_id", "products", "CASCADE"),
    ("vibe_input_context_links", "input_id", "vibe_inputs", "CASCADE"),
    ("vibe_input_context_links", "version_id", "model_versions", "CASCADE"),
    ("run_progress_events", "run_id", "runs", "CASCADE"),
    ("run_artifacts", "run_id", "runs", "CASCADE"),
    ("run_artifacts", "model_version_id", "model_versions", "CASCADE"),
    ("run_operations", "run_id", "runs", "CASCADE"),
    ("run_operations", "output_version_id", "model_versions", "CASCADE"),
    ("run_next_vibe_links", "run_id", "runs", "CASCADE"),
    ("run_input_links", "run_id", "runs", "CASCADE"),
    ("run_input_links", "input_id", "vibe_inputs", "CASCADE"),
    ("run_element_lineage", "run_id", "runs", "CASCADE"),
    ("run_element_lineage", "version_id", "model_versions", "CASCADE"),
    # --- SET NULL (provenance) ---
    ("runs", "version_id", "model_versions", "SET NULL"),
    ("run_operations", "parent_version_id", "model_versions", "SET NULL"),
    ("businesses", "source_industry_id", "businesses", "SET NULL"),
    ("model_versions", "context_id", "business_contexts", "SET NULL"),
    ("domains", "previous_element_id", "domains", "SET NULL"),
    ("subdomains", "previous_element_id", "subdomains", "SET NULL"),
    ("products", "previous_element_id", "products", "SET NULL"),
    ("attributes", "previous_element_id", "attributes", "SET NULL"),
    ("foreign_key_links", "previous_element_id", "foreign_key_links", "SET NULL"),
]


# Pre-clean the orphaned self-FK before its constraint is added. Exposed as a
# module constant so the owner script runs the identical statement ahead of its
# FK loop (single source of truth for the pre-clean, matching the migration).
PRECLEAN_SOURCE_INDUSTRY_SQL = (
    "UPDATE businesses SET source_industry_id = NULL "
    "WHERE source_industry_id IS NOT NULL "
    "AND source_industry_id NOT IN (SELECT id FROM businesses)"
)

# Tables dropped by this migration (child first for the plain-drop order).
_DROP_TABLES: tuple[str, ...] = ("run_feedback_links", "feedback", "backfill_status")

# Index the referencing column of every SET NULL self-FK. Without an index on
# the CHILD column, Postgres seq-scans the child table for each parent row
# deleted under ON DELETE SET NULL - on a 148k-row ``attributes`` table a single
# version delete blew past the statement timeout. `db_models` declares
# ``index=True`` on these (fresh installs get them via ``create_all``); the
# migration creates them on existing installs. Index names match SQLModel's
# ``ix_<table>_<column>`` convention so both paths converge and the IF NOT
# EXISTS is a true no-op. Single source of truth: the owner script imports this
# and the db_models drift test asserts the pairing.
SELF_FK_INDEX_COLUMNS: list[tuple[str, str]] = [
    ("domains", "previous_element_id"),
    ("subdomains", "previous_element_id"),
    ("products", "previous_element_id"),
    ("attributes", "previous_element_id"),
    ("foreign_key_links", "previous_element_id"),
]

# Trigram GIN indexes backing ``searchModelElements``' attribute-name ILIKE
# filter (Track 6). Postgres only: SQLite has no ``pg_trgm``/GIN equivalent and
# already resolves the (much smaller, SQLite-only) fixtures fine with a scan.
# ``(table, column)`` pairs; index name follows ``ix_trgm_<table>_<column>``.
# On a 15k-attribute production fork (~134k attribute rows), the attributes
# branch of the search UNION was a Parallel Seq Scan filtering
# ``name ILIKE '%q%' OR column_name ILIKE '%q%'`` over the whole table
# (350-368ms). A version-scoping query-shape rewrite was tried and reverted -
# Postgres flattens the join back to the same seq-scan plan regardless of
# shape - so these indexes are the fix: live EXPLAIN ANALYZE on the same fork
# confirmed a bitmap index plan (10-20ms) once they exist.
TRGM_INDEX_COLUMNS: list[tuple[str, str]] = [
    ("attributes", "name"),
    ("attributes", "column_name"),
]

# ``run_operations.dispatched_widgets_json`` — write-once audit trail of the
# exact widget map a dispatch() call handed to `jobs.run_now()` (e.g.
# `data_model_scopes`), distinct from `params_json` (DAG-plan-time params,
# re-validated + re-parsed on every dispatch/observe tick) and
# `rollback_state_json` (already overloaded between dispatch-extras and
# terminal-rollback-state). See `OperationDispatchHandle.dispatched_widgets`
# docstring for the full rationale.
_ADD_DISPATCHED_WIDGETS_PG = (
    "ALTER TABLE run_operations ADD COLUMN IF NOT EXISTS "
    "dispatched_widgets_json TEXT DEFAULT '{}'"
)
_ADD_DISPATCHED_WIDGETS_SQLITE = (
    "ALTER TABLE run_operations ADD COLUMN dispatched_widgets_json TEXT DEFAULT '{}'"
)


def _add_dispatched_widgets_column(conn: Connection, is_postgres: bool) -> None:
    # Guarded on table existence: minimal migration-test fixtures (see
    # test_v_0_6_6_migration.py) create only the tables their assertions
    # touch, not the full db_models schema. A real install always has
    # run_operations from v_0_1_0's create_all.
    if not inspect(conn).has_table("run_operations"):
        return
    if is_postgres:
        conn.execute(text(_ADD_DISPATCHED_WIDGETS_PG))
        return
    # SQLite (tests): ADD COLUMN lacks IF NOT EXISTS, so check first.
    cols = conn.execute(text("PRAGMA table_info(run_operations)")).fetchall()
    present = {row[1] for row in cols}
    if "dispatched_widgets_json" not in present:
        conn.execute(text(_ADD_DISPATCHED_WIDGETS_SQLITE))


def _log_data_check(conn: Connection) -> None:
    """Log row counts of the tables about to be dropped + backfill coverage.

    Non-blocking (both dialects): the backfill already ran at the 0.6.3
    cutover and the fork rehearsal does the authoritative comparison before
    production sees this. Guarded on table existence so it is a no-op on a
    fresh install where the legacy tables never existed.
    """
    insp = inspect(conn)

    def _count(table: str) -> int | None:
        if not insp.has_table(table):
            return None
        return conn.execute(text(f"SELECT count(*) FROM {table}")).scalar()

    fb = _count("feedback")
    rfl = _count("run_feedback_links")
    user_inputs = None
    if insp.has_table("vibe_inputs"):
        user_inputs = conn.execute(
            text("SELECT count(*) FROM vibe_inputs WHERE origin = 'user'")
        ).scalar()
    logger.info(
        "v_0_6_6 data check: feedback=%s run_feedback_links=%s "
        "vibe_inputs(origin='user')=%s (backfill coverage - non-blocking)",
        fb, rfl, user_inputs,
    )


def _discover_fk_constraints(conn: Connection, child: str, column: str) -> list[str]:
    """Return the live single-column FK constraint name(s) on ``child.column``.

    Reads ``pg_constraint`` rather than assuming the default
    ``<child>_<column>_fkey`` name - a constraint could have been created under
    a different name. Restricted to single-column FKs (``array_length = 1``);
    every rule column is single-column.
    """
    rows = conn.execute(
        text(
            """
            SELECT con.conname
            FROM pg_constraint con
            JOIN pg_class rel ON rel.oid = con.conrelid
            JOIN pg_attribute att
              ON att.attrelid = con.conrelid
             AND att.attnum = ANY (con.conkey)
            WHERE con.contype = 'f'
              AND rel.relname = :child
              AND att.attname = :column
              AND array_length(con.conkey, 1) = 1
            """
        ),
        {"child": child, "column": column},
    ).fetchall()
    return [r[0] for r in rows]


def _repoint_foreign_keys(conn: Connection) -> None:
    """Drop-and-recreate every FK in :data:`FK_RULES` with its ON DELETE action.

    Postgres only. Re-running drops the constraint this migration added and
    re-adds it; the end state is identical. ``source_industry_id`` has no live
    constraint to drop (the column was never enforced), so the DROP loop is
    simply empty for it and the ADD creates the constraint.
    """
    for child, column, parent, action in FK_RULES:
        for conname in _discover_fk_constraints(conn, child, column):
            conn.execute(text(f'ALTER TABLE {child} DROP CONSTRAINT "{conname}"'))
        conn.execute(
            text(
                f"ALTER TABLE {child} ADD CONSTRAINT {child}_{column}_fkey "
                f"FOREIGN KEY ({column}) REFERENCES {parent}(id) "
                f"ON DELETE {action}"
            )
        )


def _create_trgm_indexes(conn: Connection) -> None:
    """Create ``pg_trgm`` GIN indexes on the search-hot attribute columns.

    Best-effort: the extension may not be installable (no superuser / not
    allow-listed on the Lakebase instance). Logs either outcome and never
    raises - a missing trigram index degrades the attribute search branch
    back to a scan, it does not break it, so it must not fail the whole
    migration (which also carries the unrelated FK re-pointing).
    """
    # Each statement runs inside its own SAVEPOINT: this function is called
    # from within the migration's single outer transaction (alongside the
    # unrelated FK re-pointing), and on Postgres a failed statement aborts the
    # whole enclosing transaction unless it's isolated behind a savepoint. A
    # missing/unavailable pg_trgm extension must degrade this feature only,
    # not roll back steps 1-5.
    insp = inspect(conn)
    try:
        with conn.begin_nested():
            conn.execute(text("CREATE EXTENSION IF NOT EXISTS pg_trgm"))
        logger.info("v_0_6_6: pg_trgm extension present")
    except Exception:
        logger.warning(
            "v_0_6_6: could not create pg_trgm extension - skipping trigram "
            "indexes; attribute search falls back to a scan",
            exc_info=True,
        )
        return

    for table, column in TRGM_INDEX_COLUMNS:
        if not insp.has_table(table):
            continue
        index_name = f"ix_trgm_{table}_{column}"
        try:
            with conn.begin_nested():
                conn.execute(
                    text(
                        f"CREATE INDEX IF NOT EXISTS {index_name} ON {table} "
                        f"USING gin ({column} gin_trgm_ops)"
                    )
                )
            logger.info("v_0_6_6: created/confirmed %s", index_name)
        except Exception:
            logger.warning(
                "v_0_6_6: could not create %s - skipping", index_name,
                exc_info=True,
            )


def apply(engine: Engine) -> None:
    """Drop the legacy feedback tables and re-point every FK to its ON DELETE
    action. Idempotent + re-runnable; one transaction."""
    is_postgres = engine.dialect.name == "postgresql"
    with engine.begin() as conn:
        # Step 1: log-only data check (both dialects).
        _log_data_check(conn)

        # Step 2: drop the legacy tables (both dialects, child first).
        for table in _DROP_TABLES:
            conn.execute(text(f"DROP TABLE IF EXISTS {table}"))

        # Step 3: index the SET NULL self-FK referencing columns (both dialects,
        # idempotent). Without these the SET NULL cascade seq-scans the child
        # table per deleted parent row. Guarded on table existence (a real
        # install always has the element tables from v_0_1_0/v_0_6_2).
        insp = inspect(conn)
        for table, column in SELF_FK_INDEX_COLUMNS:
            if insp.has_table(table):
                conn.execute(text(
                    f"CREATE INDEX IF NOT EXISTS ix_{table}_{column} ON {table} ({column})"
                ))

        if is_postgres:
            # Step 4: pre-clean orphaned source_industry_id BEFORE the FK loop
            # adds its constraint (else the ADD fails on the first orphan).
            conn.execute(text(PRECLEAN_SOURCE_INDUSTRY_SQL))
            # Step 5: re-point every FK to its ON DELETE action.
            _repoint_foreign_keys(conn)
            # Step 6: trigram GIN indexes backing searchModelElements' attribute
            # ILIKE filter (best-effort, savepoint-isolated - see docstring).
            _create_trgm_indexes(conn)

        # Step 7 (both dialects, idempotent): add
        # run_operations.dispatched_widgets_json — the dispatched-widget-map
        # audit trail (bug bash item: uninstall dispatch carried
        # `data_model_scopes` to `jobs.run_now()` but the run detail API
        # had no way to surface it, forcing operators to the Jobs API
        # directly to verify what was actually dispatched).
        _add_dispatched_widgets_column(conn, is_postgres)


MIGRATION = Migration(
    version="0.6.6",
    apply=apply,
    description=(
        "DB-level delete integrity (per-FK ON DELETE CASCADE / SET NULL from "
        "FK_RULES; source_industry_id pre-clean + self-FK added), legacy "
        "feedback retirement (drop feedback / run_feedback_links / "
        "backfill_status), pg_trgm GIN indexes on attributes.name / "
        "attributes.column_name backing searchModelElements (best-effort, "
        "Postgres only), and run_operations.dispatched_widgets_json (audit "
        "trail of the widget map actually dispatched to jobs.run_now())."
    ),
)
