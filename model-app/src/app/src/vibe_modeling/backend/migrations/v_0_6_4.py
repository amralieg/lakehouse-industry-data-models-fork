"""Migration 0.6.4 — Industry Management schema spine.

The single, in-flight 0.6.4 migration. Additive only; while 0.6.4 stays
unreleased, later 0.6.4 work folds its additive schema into THIS file
(idempotent), not a new migration. See the plan's version-cohesion rule.

New table (1):
  - ``sectors`` — the top level of the two-level taxonomy (ADR D-047).
    Repurposes the flat-industry classification as the *higher* level;
    the lower level (the meta-businesses, surfaced as "Industries") are
    ``businesses`` rows with ``kind='industry'`` (ADR D-046). Shaped like
    the legacy ``industries`` table so the Settings UI can be retargeted
    onto it: ``(id, name, short_name, description, display_order,
    is_active, created_at, updated_at)``. Seeded at boot from a snapshot
    of the runner SECTOR_MAP (see ``sector_catalog.py`` + ``seed_sectors``).

Changed table (additive columns only) — ``businesses``:
  - ``kind VARCHAR NOT NULL DEFAULT 'business'`` — the discriminator
    separating real businesses from industries (meta-businesses). Existing
    rows backfill to ``'business'``. Mirrored by the ``BusinessKind`` enum
    on the Pydantic layer. "meta-business" framing never reaches the UI.
  - ``sector_id VARCHAR`` (nullable FK -> ``sectors.id``) — the industry's
    place in the taxonomy. Nullable at the column level; NOT NULL is
    enforced at the application layer on industry *import* only (existing
    businesses legitimately have no sector).
  - ``source_industry_id VARCHAR`` (nullable SELF-FK -> ``businesses.id``)
    — provenance for a business kickstarted from an industry (ADR D-050).
    Self-FK keyed by the UUID PK (D-045).
  - ``source_version INTEGER`` (nullable) — the industry model version a
    kickstart snapshotted from.
  - ``source_repo_path VARCHAR`` (nullable) — the repo path an industry was
    downloaded from (ADR D-049); pre-fills the publish target. NULL when the
    business was never downloaded.

Changed table (additive columns only) — ``agent_config`` (singleton):
  - GitHub publish/browse configuration (ADR D-049), so the whole epic's
    schema lands in this one migration and no later track has to touch
    ``migrations/``: ``github_repo_owner``, ``github_repo_name`` (the
    installation's publish target repo); ``github_auth_mode`` ('' |
    'oauth_u2m' | 'secret_pat'); ``github_connection_name`` (the UC HTTP
    connection for OAuth U2M); ``github_secret_scope`` + ``github_secret_key``
    (the PAT-fallback secret). All VARCHAR DEFAULT ''.

Legacy ``industries`` table + ``businesses.industry_id`` /
``industry_alignment`` are intentionally LEFT UNTOUCHED (no migration):
deprecated, not surfaced, retired by a future migration once nothing reads
them.

Dropped column — ``model_versions.next_vibes_json``:
  - The lossy agent-next-vibes blob is retired. The sync-time materializer
    (``model_sync.materialize_next_vibe_inputs``) now produces structured
    ``VibeInput(origin=agent_next_vibe)`` rows directly, and the read-side
    ``getNextVibes`` card + the run-create validators read those rows, so
    nothing consumes the blob. Dropped dialect-aware + idempotent.

Idempotent on both dialects: ``CREATE TABLE IF NOT EXISTS`` + per-dialect
``ADD COLUMN`` (Postgres ``ADD COLUMN IF NOT EXISTS``; SQLite PRAGMA-guarded)
+ per-dialect ``DROP COLUMN`` (Postgres ``DROP COLUMN IF EXISTS``; SQLite
PRAGMA-guarded). The ADD COLUMNs and the DROP COLUMN are mirrored in the
owner script ``scripts/db/migrate.py`` so the migration-drift test
(``tests/test_app/test_migration_drift_owner.py``) stays green.
"""

from __future__ import annotations

from sqlalchemy import text
from sqlalchemy.engine import Engine

from .registry import Migration


_CREATE_TABLES = [
    """
    CREATE TABLE IF NOT EXISTS sectors (
        id VARCHAR NOT NULL PRIMARY KEY,
        name VARCHAR NOT NULL DEFAULT '',
        short_name VARCHAR NOT NULL DEFAULT '',
        description TEXT DEFAULT '',
        display_order INTEGER NOT NULL DEFAULT 0,
        is_active BOOLEAN NOT NULL DEFAULT true,
        created_at TIMESTAMP NOT NULL,
        updated_at TIMESTAMP NOT NULL
    )
    """,
]

_CREATE_INDEXES = [
    "CREATE INDEX IF NOT EXISTS ix_sectors_short_name ON sectors (short_name)",
    "CREATE INDEX IF NOT EXISTS ix_businesses_kind ON businesses (kind)",
    "CREATE INDEX IF NOT EXISTS ix_businesses_sector_id ON businesses (sector_id)",
    "CREATE INDEX IF NOT EXISTS ix_businesses_source_industry_id ON businesses (source_industry_id)",
]

# Additive columns on businesses. Order here is the drift-test pairing order;
# keep it identical to the owner script's v_0_6_4 block in
# scripts/db/migrate.py.
_ADD_COLUMNS_PG = [
    "ALTER TABLE businesses ADD COLUMN IF NOT EXISTS kind VARCHAR NOT NULL DEFAULT 'business'",
    "ALTER TABLE businesses ADD COLUMN IF NOT EXISTS sector_id VARCHAR",
    "ALTER TABLE businesses ADD COLUMN IF NOT EXISTS source_industry_id VARCHAR",
    "ALTER TABLE businesses ADD COLUMN IF NOT EXISTS source_version INTEGER",
    "ALTER TABLE businesses ADD COLUMN IF NOT EXISTS source_repo_path VARCHAR",
]

# (column, SQLite DDL) pairs — SQLite ADD COLUMN lacks IF NOT EXISTS, so each
# is PRAGMA-guarded in apply().
_ADD_COLUMNS_SQLITE = [
    ("kind", "ALTER TABLE businesses ADD COLUMN kind VARCHAR NOT NULL DEFAULT 'business'"),
    ("sector_id", "ALTER TABLE businesses ADD COLUMN sector_id VARCHAR"),
    ("source_industry_id", "ALTER TABLE businesses ADD COLUMN source_industry_id VARCHAR"),
    ("source_version", "ALTER TABLE businesses ADD COLUMN source_version INTEGER"),
    ("source_repo_path", "ALTER TABLE businesses ADD COLUMN source_repo_path VARCHAR"),
]

# agent_config GitHub config (singleton). Same drift-test pairing order as the
# owner script's v_0_6_4 agent_config block.
_ADD_AGENT_CONFIG_PG = [
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS github_repo_owner VARCHAR DEFAULT ''",
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS github_repo_name VARCHAR DEFAULT ''",
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS github_auth_mode VARCHAR DEFAULT ''",
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS github_connection_name VARCHAR DEFAULT ''",
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS github_secret_scope VARCHAR DEFAULT ''",
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS github_secret_key VARCHAR DEFAULT ''",
]
_ADD_AGENT_CONFIG_SQLITE = [
    ("github_repo_owner", "ALTER TABLE agent_config ADD COLUMN github_repo_owner VARCHAR DEFAULT ''"),
    ("github_repo_name", "ALTER TABLE agent_config ADD COLUMN github_repo_name VARCHAR DEFAULT ''"),
    ("github_auth_mode", "ALTER TABLE agent_config ADD COLUMN github_auth_mode VARCHAR DEFAULT ''"),
    ("github_connection_name", "ALTER TABLE agent_config ADD COLUMN github_connection_name VARCHAR DEFAULT ''"),
    ("github_secret_scope", "ALTER TABLE agent_config ADD COLUMN github_secret_scope VARCHAR DEFAULT ''"),
    ("github_secret_key", "ALTER TABLE agent_config ADD COLUMN github_secret_key VARCHAR DEFAULT ''"),
]

# Subtractive: drop the lossy ``model_versions.next_vibes_json`` blob. The
# sync-time materializer now produces structured ``VibeInput(agent_next_vibe)``
# rows directly, so nothing reads the blob. Dialect-aware + idempotent (mirrors
# the v_0_3_0 pattern). Mirrored in the owner script's ``DROP_COLUMNS``.
_DROP_COLUMNS: tuple[str, ...] = ("next_vibes_json",)


def apply(engine: Engine) -> None:
    """Create the sectors table and add the four businesses discriminator/
    provenance columns. Idempotent on both dialects."""
    dialect = engine.dialect.name
    with engine.begin() as conn:
        for ddl in _CREATE_TABLES:
            conn.execute(text(ddl))
        if dialect == "postgresql":
            for ddl in _ADD_COLUMNS_PG:
                conn.execute(text(ddl))
            for ddl in _ADD_AGENT_CONFIG_PG:
                conn.execute(text(ddl))
        else:
            present = {
                row[1]
                for row in conn.execute(text("PRAGMA table_info(businesses)")).fetchall()
            }
            for column, ddl in _ADD_COLUMNS_SQLITE:
                if column not in present:
                    conn.execute(text(ddl))
            ac_present = {
                row[1]
                for row in conn.execute(text("PRAGMA table_info(agent_config)")).fetchall()
            }
            for column, ddl in _ADD_AGENT_CONFIG_SQLITE:
                if column not in ac_present:
                    conn.execute(text(ddl))
        for ddl in _CREATE_INDEXES:
            conn.execute(text(ddl))
        # Drop the retired next_vibes_json blob (after the add-columns block).
        if dialect == "postgresql":
            for column in _DROP_COLUMNS:
                conn.execute(
                    text(f"ALTER TABLE model_versions DROP COLUMN IF EXISTS {column}")
                )
        else:
            mv_present = {
                row[1]
                for row in conn.execute(text("PRAGMA table_info(model_versions)")).fetchall()
            }
            for column in _DROP_COLUMNS:
                if column in mv_present:
                    conn.execute(text(f"ALTER TABLE model_versions DROP COLUMN {column}"))


MIGRATION = Migration(
    version="0.6.4",
    apply=apply,
    description=(
        "Industry Management spine: create the sectors table (two-level "
        "taxonomy top level, ADR D-047); add businesses.kind discriminator "
        "(business|industry, ADR D-046), sector_id FK, source_industry_id "
        "self-FK + source_version (kickstart provenance, ADR D-050). Legacy "
        "industries table left untouched (deprecated). Also drops the retired "
        "model_versions.next_vibes_json blob (structured VibeInput rows replace it)."
    ),
)
