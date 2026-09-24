"""Boot-time schema migration registry for the Vibe Modeling app.

Three lifecycle phases govern how :func:`reconcile_schema` behaves:

1. **Pre-prod (today).** ``PRE_PROD_DESTRUCTIVE_RESET`` is ``True`` so the
   first thing reconcile does on a version mismatch is drop the public
   schema and re-apply every migration from scratch. Test data is
   disposable; we'd rather wipe than guess at a migration story we don't
   need yet.
2. **First publish (v1.0).** ``INSTALL_POLICY`` flips to ``"strict"``
   and ``PRE_PROD_DESTRUCTIVE_RESET`` is DELETED. Fresh installs require
   an empty Lakebase project — if any tables exist that we don't own,
   reconcile refuses rather than risk colliding with a user's schema.
3. **Subsequent publishes.** Reconcile reads the version row, applies
   only migrations whose version string sorts strictly higher than the
   installed one, and refuses to start if the installed version is
   newer than what the wheel knows about (operator must roll forward,
   never backward).

The destructive-reset branch — and every reference to
``PRE_PROD_DESTRUCTIVE_RESET`` in this file — gets removed when v1.0
ships. Search for the constant name to find the deletion sites.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Callable, Literal

from sqlalchemy import inspect, text
from sqlalchemy.engine import Engine
from sqlmodel import Session, select


# --- Lifecycle constants ------------------------------------------------------

# DELETE on v1.0 publish — keeps the destructive-reset branch wired in
# during pre-prod, where every schema mismatch is treated as "wipe and
# rebuild" because test data is disposable.
PRE_PROD_DESTRUCTIVE_RESET: bool = False

# ``permissive`` (today): fresh installs run all migrations regardless of
# what's in the public schema; the destructive-reset branch handles
# mismatches. ``strict`` (v1.0): fresh installs refuse if the public
# schema isn't empty.
INSTALL_POLICY: Literal["permissive", "strict"] = "permissive"


class LakebaseInstallError(RuntimeError):
    """Raised when reconcile_schema can't safely proceed.

    Distinct exception type so the lifespan can log a clear, actionable
    error rather than burying the cause in a generic boot-time stack
    trace. Operators should expect to see this when (a) the installed
    schema is newer than the wheel knows about, or (b) strict-mode
    install hit a non-empty public schema.
    """


@dataclass(frozen=True)
class Migration:
    """A single boot-time migration step.

    ``apply`` must be idempotent — reconcile may re-invoke a migration
    after a partial failure, and the destructive-reset branch always
    runs every migration from scratch. Raise on hard failure; reconcile
    will surface the exception to the lifespan.
    """

    version: str
    apply: Callable[[Engine], None]
    description: str


# Populated by ``backend.migrations.__init__`` after each
# ``v_X_Y_Z.MIGRATION`` is imported. Kept module-scoped so tests can
# monkeypatch the list to register synthetic migrations without
# reaching into the package's import side-effects.
MIGRATIONS: list[Migration] = []


# --- Helpers ------------------------------------------------------------------


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _is_postgres(engine: Engine) -> bool:
    """Reconcile branches twice on dialect:

    * destructive reset uses ``DROP TABLE ... CASCADE`` against
      ``pg_tables`` for Postgres, ``metadata.drop_all`` for SQLite;
    * strict-mode existence check only runs on Postgres (SQLite is
      tests-only and can't host a stray production schema).
    """
    return engine.dialect.name == "postgresql"


def _version_table_exists(engine: Engine) -> bool:
    """Inspector-based table existence check — works on both dialects.

    Avoids the engine.connect().__enter__() dance and the dialect-
    specific information_schema queries.
    """
    return inspect(engine).has_table("_lakebase_schema_version")


def _read_installed_version(engine: Engine) -> str | None:
    """Return the installed schema version, or ``None`` on a fresh DB.

    Returns ``None`` when the ``_lakebase_schema_version`` table doesn't
    exist OR when it exists but contains no rows / an empty version
    string. All three cases mean "treat as fresh install".
    """
    if not _version_table_exists(engine):
        return None

    # Importing inside the function keeps this module light — db_models
    # pulls in a chunk of the SQLModel metadata graph at import time.
    from ..db_models import LakebaseSchemaVersion

    with Session(bind=engine) as session:
        row = session.exec(
            select(LakebaseSchemaVersion).where(LakebaseSchemaVersion.id == 1)
        ).first()
        if row is None:
            return None
        return row.version or None


def _write_installed_version(engine: Engine, version: str) -> None:
    """Upsert the singleton row (id=1) with ``version`` and ``applied_at=now()``."""
    from ..db_models import LakebaseSchemaVersion

    with Session(bind=engine) as session:
        existing = session.exec(
            select(LakebaseSchemaVersion).where(LakebaseSchemaVersion.id == 1)
        ).first()
        if existing is None:
            session.add(LakebaseSchemaVersion(id=1, version=version, applied_at=_now()))
        else:
            existing.version = version
            existing.applied_at = _now()
            session.add(existing)
        session.commit()


def _list_public_tables(engine: Engine) -> list[str]:
    """Return every table name in the Postgres ``public`` schema.

    Used twice: the strict-mode existence check (must be empty on fresh
    install) and the destructive-reset wipe (drop them all). SQLite has
    no schemas; callers only invoke this on Postgres engines.
    """
    with engine.connect() as conn:
        rows = conn.execute(
            text("SELECT tablename FROM pg_tables WHERE schemaname = 'public'")
        ).fetchall()
    return [r[0] for r in rows]


def _drop_public_schema(engine: Engine) -> None:
    """Drop every table in the public schema.

    Postgres path: ``DROP TABLE IF EXISTS ... CASCADE`` per table read
    from ``pg_tables`` — CASCADE so we don't have to pre-compute FK
    order. SQLite path: ``SQLModel.metadata.drop_all`` — there's no
    ``public`` schema to enumerate, and drop_all already walks the
    metadata graph in dependency order.
    """
    if _is_postgres(engine):
        tables = _list_public_tables(engine)
        with engine.begin() as conn:
            for table in tables:
                conn.execute(text(f'DROP TABLE IF EXISTS "{table}" CASCADE'))
    else:
        # SQLite (tests). Use SQLModel's drop_all — no schema to enumerate.
        # Importing db_models registers every table on the metadata graph
        # so drop_all can walk it.
        from sqlmodel import SQLModel

        from .. import db_models  # noqa: F401
        SQLModel.metadata.drop_all(engine)


def _apply_migrations(engine: Engine, migrations: list[Migration]) -> None:
    """Apply each migration in order, then write the highest version.

    A failure in any migration aborts the run with the original
    exception; the version row is only updated if every migration
    succeeded. (Pre-prod's destructive-reset branch makes partial
    failure recoverable: re-running reconcile wipes and retries.)
    """
    if not migrations:
        return

    for m in migrations:
        m.apply(engine)

    _write_installed_version(engine, migrations[-1].version)


# --- Public entrypoint --------------------------------------------------------


def reconcile_schema(engine: Engine) -> None:
    """Boot-time schema reconciliation.

    Reads ``LakebaseSchemaVersion`` to find the installed version;
    applies any registered migration whose version sorts strictly higher
    than the installed one. Three lifecycle phases:

    1. **Pre-prod (today).** With ``PRE_PROD_DESTRUCTIVE_RESET=True``,
       any version mismatch (installed != latest known) drops every
       table in the public schema and re-runs all migrations from
       scratch. Test data is disposable.
    2. **First publish (v1.0).** ``INSTALL_POLICY="strict"``. On fresh
       install (no version row), refuse if the public schema has any
       tables we don't own. Otherwise apply every migration.
    3. **Subsequent publishes.** Read the installed version, apply only
       migrations whose version sorts strictly higher. Refuse if the
       installed version is newer than what the wheel knows about.

    Raises:
        LakebaseInstallError: when the install policy refuses to
            proceed (strict-mode non-empty DB; installed > latest).
    """
    # Tests monkeypatch ``MIGRATIONS`` on this module. Read the module's
    # current attribute (don't bind a snapshot at function-def time) so
    # those overrides take effect.
    from . import registry as _reg

    migrations = list(_reg.MIGRATIONS)
    if not migrations:
        # Defensive: no registered migrations means there's nothing to
        # do, but it's almost certainly a packaging bug. Log and return.
        return

    latest_version = migrations[-1].version
    installed = _read_installed_version(engine)

    # Case A: code knows about a version older than what's installed.
    if installed is not None and installed > latest_version:
        raise LakebaseInstallError(
            f"installed schema version {installed!r} is newer than the "
            f"latest migration this wheel knows about ({latest_version!r}). "
            f"Roll forward the wheel; reconcile will not downgrade."
        )

    # Case B: already at the latest version — no-op.
    if installed == latest_version:
        return

    # Case C: fresh install (no version row).
    if installed is None:
        if _reg.INSTALL_POLICY == "strict":
            if _is_postgres(engine):
                stray = _list_public_tables(engine)
                if stray:
                    raise LakebaseInstallError(
                        "first install requires an empty Lakebase project; "
                        f"found tables: {sorted(stray)}"
                    )
        _apply_migrations(engine, migrations)
        return

    # Case D: installed older than latest. Two sub-paths.
    if _reg.PRE_PROD_DESTRUCTIVE_RESET:
        # Wipe and re-apply from scratch.
        _drop_public_schema(engine)
        _apply_migrations(engine, migrations)
        return

    # Production-style partial upgrade: apply only migrations strictly
    # newer than the installed version.
    pending = [m for m in migrations if m.version > installed]
    _apply_migrations(engine, pending)
