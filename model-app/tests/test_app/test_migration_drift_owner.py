"""Drift test between the runtime migration registry and the owner script.

This test replaces the deleted ``tests/test_app/test_migration_drift.py``,
which AST-parsed the (now-gone) ``core.lakebase._add_missing_columns``
function and compared its column list against the (also-renamed) owner
script ``scripts/apply_migrations_as_owner.py``.

The migration architecture changed in PR #176 (Phase 4 close-out):

- Runtime path: ``backend.migrations.registry.reconcile_schema()`` walks
  ``MIGRATIONS`` and applies any registered ``Migration`` whose version
  sorts strictly higher than the recorded ``LakebaseSchemaVersion``.
- Owner-script path: ``scripts/db/migrate.py`` runs out-of-band as the
  Lakebase project owner (when the app's runtime auto-migration can't
  ALTER tables it doesn't own — observed 2026-04-21 on the test workspace). It uses a
  hard-coded list of ``ADD COLUMN`` / ``ALTER COLUMN ... TYPE BIGINT`` /
  ``DROP NOT NULL`` triples.

Because the owner script copies the DDL by hand instead of importing
the registry, silent drift is possible: a new ``Migration`` lands in the
registry, ships through CI, gets deployed, and the next the test workspaces
owner-impersonation run silently misses the column. The previous app
process sees ``information_schema`` columns it expects, but a freshly
restarted process on a Lakebase project that pre-dates the new
migration finds the column missing and crashes on first query.

This file is the gate that prevents that regression. Each test below
fails loudly with a copy-pasteable diff if the owner script and the
registry disagree about additive ``ADD COLUMN`` migrations.

Scope notes
-----------

* The owner script's ``WIDEN_TO_BIGINT`` and ``DROP_NOT_NULL`` lists are
  one-off historical fixes (BIGINT widening for ``runs.last_consumed_step_id``
  + progress event ids; ``agent_config.agent_version`` nullability) that
  pre-date the registry. They are not produced by any registered
  migration; the test treats them as owner-script-only and asserts they
  stay that way (a future migration adding those operations would be a
  *real* coupling break and should be caught).
* Migration ``v_0_1_0`` is a full ``SQLModel.metadata.create_all`` and
  emits ``CREATE TABLE`` statements, not ``ALTER TABLE ADD COLUMN``.
  The owner script intentionally does not duplicate ``create_all`` — it
  only catches up additive column drift on already-installed tables.
  Tests therefore restrict the comparison to ``ALTER TABLE`` migrations.

If an operator ever changes the coupling (e.g., ``scripts/db/migrate.py``
starts importing from ``backend.migrations.registry`` directly), update
the tests here to enforce the *new* coupling shape rather than relaxing
this one.
"""

from __future__ import annotations

import ast
import inspect as _stdlib_inspect
import re
from pathlib import Path
from typing import Any, Iterable

import pytest

from vibe_modeling.backend import migrations as runtime_migrations
from vibe_modeling.backend.migrations.registry import Migration


# --- Owner-script loader ------------------------------------------------------


_OWNER_SCRIPT_PATH = (
    Path(__file__).resolve().parents[2] / "scripts" / "db" / "migrate.py"
)


def _load_owner_script_module() -> Any:
    """Import ``scripts/db/migrate.py`` without executing ``main()``.

    The script is a top-level file (not a package), and importing it the
    normal way would trigger SDK calls if invoked. We use
    ``importlib.util.spec_from_file_location`` to load the module
    *definitions* (the three lists at module scope) without crossing the
    ``if __name__ == "__main__"`` guard.
    """
    import importlib.util

    assert _OWNER_SCRIPT_PATH.exists(), (
        f"owner script not found at {_OWNER_SCRIPT_PATH}; the migration "
        "drift coupling has moved — update _OWNER_SCRIPT_PATH in this file."
    )
    spec = importlib.util.spec_from_file_location(
        "owner_migrate_script", str(_OWNER_SCRIPT_PATH)
    )
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


# --- DDL extraction from runtime migration source ----------------------------


# Regex that matches a fully-formed ``ALTER TABLE ... ADD COLUMN ...`` SQL
# statement, run against a string literal lifted from the Python source via
# ``ast.literal_eval``. The literal already has its Python quotes stripped
# and any escapes resolved, so the SQL ``TEXT DEFAULT ''`` survives intact
# (its inner ``''`` is just two single-quote chars, not the boundary of a
# Python string).
#
# We tolerate the optional ``IF NOT EXISTS`` qualifier so the Postgres
# branch (``ADD COLUMN IF NOT EXISTS``) and the SQLite branch (``ADD
# COLUMN``) of a dialect-split migration parse to the same triple.
_ADD_COLUMN_RE = re.compile(
    r"""
    ALTER\s+TABLE\s+
    "?(?P<table>[A-Za-z_][A-Za-z0-9_]*)"?
    \s+ADD\s+COLUMN\s+
    (?:IF\s+NOT\s+EXISTS\s+)?
    "?(?P<column>[A-Za-z_][A-Za-z0-9_]*)"?
    \s+(?P<col_type>.+?)
    \s*$
    """,
    re.IGNORECASE | re.VERBOSE | re.DOTALL,
)


# Counterpart for ``ALTER TABLE ... ALTER COLUMN ... DROP NOT NULL``.
# Yields ``(table, column)`` pairs that can be compared positionally
# against the owner script's ``DROP_NOT_NULL`` list.
_DROP_NOT_NULL_RE = re.compile(
    r"""
    ALTER\s+TABLE\s+
    "?(?P<table>[A-Za-z_][A-Za-z0-9_]*)"?
    \s+ALTER\s+COLUMN\s+
    "?(?P<column>[A-Za-z_][A-Za-z0-9_]*)"?
    \s+DROP\s+NOT\s+NULL
    \s*;?\s*$
    """,
    re.IGNORECASE | re.VERBOSE | re.DOTALL,
)


# Counterpart for subtractive ``ALTER TABLE ... DROP COLUMN ...``. We
# tolerate the optional ``IF EXISTS`` qualifier so the Postgres branch
# (``DROP COLUMN IF EXISTS``) and the SQLite branch (``DROP COLUMN``)
# of a dialect-split migration parse to the same pair. No type spec —
# DROP COLUMN takes a column name only.
_DROP_COLUMN_RE = re.compile(
    r"""
    ALTER\s+TABLE\s+
    "?(?P<table>[A-Za-z_][A-Za-z0-9_]*)"?
    \s+DROP\s+COLUMN\s+
    (?:IF\s+EXISTS\s+)?
    "?(?P<column>[A-Za-z_][A-Za-z0-9_]*)"?
    \s*;?\s*$
    """,
    re.IGNORECASE | re.VERBOSE | re.DOTALL,
)


def _iter_string_literals(src: str) -> Iterable[str]:
    """Yield every string literal in ``src`` with Python escapes resolved.

    Walks the AST so multi-line strings and concatenated string segments
    each show up as a single literal we can regex against.
    """
    tree = ast.parse(src)
    for node in ast.walk(tree):
        if isinstance(node, ast.Constant) and isinstance(node.value, str):
            yield node.value


def _normalise_type(col_type: str) -> str:
    """Squash whitespace + case so ``TEXT DEFAULT ''`` compares cleanly."""
    return re.sub(r"\s+", " ", col_type).strip().upper().rstrip(";")


def _migration_source(migration: Migration) -> str:
    """Return the source code of the module that defines ``migration``.

    We parse source rather than executing the migration against an
    in-memory engine because ``v_0_1_0`` populates SQLModel's metadata
    with the *current* schema — including columns later migrations add —
    and so a downstream ``CREATE TABLE`` from ``create_all`` would beat
    each ``v_>=_0_2_0`` ``ALTER TABLE`` to the punch and the ALTER would
    be skipped (the column already exists). Source-level extraction
    sidesteps this circularity entirely.
    """
    # Migration is a frozen dataclass holding a callable; getmodule() on
    # the callable is enough to find the module's source file.
    module = _stdlib_inspect.getmodule(migration.apply)
    assert module is not None, (
        f"could not resolve source module for migration {migration.version}"
    )
    return _stdlib_inspect.getsource(module)


def _extract_add_columns_from_source(src: str) -> list[tuple[str, str, str]]:
    """Pull every ``ALTER TABLE ... ADD COLUMN`` statement out of Python
    source as ``(table, column, normalised_type)`` triples.

    We iterate the source's string literals (each is a complete SQL
    statement) and regex each one. Dialect-split migrations (Postgres
    branch + SQLite branch with matching DDL) yield the same triple
    twice; we de-dupe in registration order so the run-time list
    matches the owner-script list one-to-one.
    """
    seen: set[tuple[str, str, str]] = set()
    out: list[tuple[str, str, str]] = []
    for literal in _iter_string_literals(src):
        m = _ADD_COLUMN_RE.search(literal)
        if m is None:
            continue
        triple = (
            m.group("table"),
            m.group("column"),
            _normalise_type(m.group("col_type")),
        )
        if triple in seen:
            continue
        seen.add(triple)
        out.append(triple)
    return out


def _runtime_alter_add_columns() -> list[tuple[str, str, str]]:
    """Walk every registered migration except ``v_0_1_0`` (the
    ``create_all`` bootstrap) and accumulate their ADD COLUMN triples in
    registration order, parsed from each migration's source.

    ``v_0_1_0`` is excluded because it emits ``CREATE TABLE`` from
    ``SQLModel.metadata.create_all``, not ``ALTER TABLE`` — its columns
    appear on fresh installs by definition and are out of scope for the
    owner script's catchup contract.
    """
    triples: list[tuple[str, str, str]] = []
    for m in runtime_migrations.MIGRATIONS:
        if m.version == "0.1.0":
            continue
        src = _migration_source(m)
        triples.extend(_extract_add_columns_from_source(src))
    return triples


def _owner_script_add_column_triples(
    owner_module: Any,
) -> list[tuple[str, str, str]]:
    """Convert ``MIGRATIONS = [(table, col, "TEXT DEFAULT ''"), ...]`` from
    the owner script into the same normalised triple shape as the
    runtime side."""
    return [
        (table, column, _normalise_type(col_type))
        for (table, column, col_type) in owner_module.MIGRATIONS
    ]


def _extract_drop_columns_from_source(src: str) -> list[tuple[str, str]]:
    """Pull every ``ALTER TABLE ... DROP COLUMN`` statement out of Python
    source as ``(table, column)`` pairs.

    Mirrors :func:`_extract_add_columns_from_source` but for the
    subtractive form. Dialect-split migrations (Postgres branch +
    SQLite branch with matching DDL) yield the same pair twice; we
    de-dupe in registration order so the run-time list maps one-to-one
    onto the owner-script ``DROP_COLUMNS`` list.
    """
    seen: set[tuple[str, str]] = set()
    out: list[tuple[str, str]] = []
    for literal in _iter_string_literals(src):
        m = _DROP_COLUMN_RE.search(literal)
        if m is None:
            continue
        pair = (m.group("table"), m.group("column"))
        if pair in seen:
            continue
        seen.add(pair)
        out.append(pair)
    return out


def _runtime_alter_drop_columns() -> list[tuple[str, str]]:
    """Walk every registered migration except ``v_0_1_0`` and accumulate
    DROP COLUMN pairs in registration order, parsed from each
    migration's source. ``v_0_1_0`` is excluded for the same reason as
    in :func:`_runtime_alter_add_columns`: it emits ``CREATE TABLE``
    only, never ``ALTER TABLE``.
    """
    pairs: list[tuple[str, str]] = []
    for m in runtime_migrations.MIGRATIONS:
        if m.version == "0.1.0":
            continue
        src = _migration_source(m)
        pairs.extend(_extract_drop_columns_from_source(src))
    return pairs


def _owner_script_drop_column_pairs(
    owner_module: Any,
) -> list[tuple[str, str]]:
    """Return ``DROP_COLUMNS = [(table, col), ...]`` from the owner script
    as plain ``(table, column)`` pairs. The owner script defines the
    list when the registry has at least one DROP COLUMN migration; the
    drift test treats a missing attribute as an empty list so legacy
    setups (no DROP COLUMN registered yet) don't fail import."""
    return list(getattr(owner_module, "DROP_COLUMNS", []))


def _format_diff(
    label_a: str,
    a: Iterable[tuple[str, str, str]],
    label_b: str,
    b: Iterable[tuple[str, str, str]],
) -> str:
    """Build a human-readable diff message for assertion failures."""
    set_a = set(a)
    set_b = set(b)
    only_a = sorted(set_a - set_b)
    only_b = sorted(set_b - set_a)
    lines = [f"{label_a} vs {label_b} drift:"]
    if only_a:
        lines.append(f"  in {label_a} but missing from {label_b}:")
        for t in only_a:
            lines.append(f"    {t}")
    if only_b:
        lines.append(f"  in {label_b} but missing from {label_a}:")
        for t in only_b:
            lines.append(f"    {t}")
    lines.append("")
    lines.append(
        "Fix by editing scripts/db/migrate.py to mirror the registry, OR "
        "by reworking the coupling so the owner script imports MIGRATIONS "
        "from vibe_modeling.backend.migrations.registry directly."
    )
    return "\n".join(lines)


# --- Tests --------------------------------------------------------------------


def test_owner_script_path_unchanged():
    """The drift test hard-codes the owner script's path. If the script
    moves, this test fails first with a clear pointer rather than the
    later assertions failing on an obscure import error."""
    assert _OWNER_SCRIPT_PATH.is_file(), (
        f"expected owner script at {_OWNER_SCRIPT_PATH}; if you moved or "
        "renamed scripts/db/migrate.py, update _OWNER_SCRIPT_PATH in this "
        "test and double-check the rename hasn't broken the test workspaces "
        "deploy runbooks."
    )


def test_owner_script_covers_every_runtime_alter_add_column():
    """Every ``ALTER TABLE ... ADD COLUMN`` the runtime registry would
    apply must also appear in the owner script's ``MIGRATIONS`` list.

    Subset (not equality) is the right shape because the owner script
    additionally carries historical ADD COLUMN entries that pre-date
    the registry — columns that were added to ``db_models`` directly
    (so fresh installs picked them up via ``create_all``) without a
    matching ``Migration`` ever being written. Those entries stay in
    the owner script as a catchup safety net for Lakebase projects
    that pre-date the column's introduction.

    The load-bearing direction of the coupling is forward: a NEW
    ``Migration`` lands in the registry → its ADD COLUMN must also
    land in ``scripts/db/migrate.py`` in the same commit. Otherwise
    the next owner-impersonation run on the test workspaces silently skips
    the column, and a freshly-restarted app process on a Lakebase
    project that pre-dates the new migration finds the column
    missing and crashes on first query.
    """
    owner_module = _load_owner_script_module()
    runtime_triples = _runtime_alter_add_columns()
    owner_triples = _owner_script_add_column_triples(owner_module)

    runtime_set = set(runtime_triples)
    owner_set = set(owner_triples)

    missing_from_owner = runtime_set - owner_set
    assert not missing_from_owner, _format_diff(
        "runtime registry", runtime_set, "scripts/db/migrate.py", owner_set
    )


def test_runtime_alter_add_columns_appear_in_owner_in_registry_order():
    """Migrations apply sequentially. Where the owner script lists a
    column the runtime registry also adds, those columns must appear
    in the owner script in the same relative order the registry
    applies them.

    The owner script's historical entries (columns that pre-date the
    registry) are filtered out before comparison — only the entries
    that the registry would actually emit are checked, and we just
    care that their relative ordering matches. Reordering is a real
    risk if a future migration depends on a column an earlier
    migration added.
    """
    owner_module = _load_owner_script_module()
    runtime_triples = _runtime_alter_add_columns()
    owner_triples = _owner_script_add_column_triples(owner_module)

    runtime_set = set(runtime_triples)
    owner_filtered = [t for t in owner_triples if t in runtime_set]

    assert runtime_triples == owner_filtered, (
        "Relative ordering of registry-emitted ADD COLUMN entries "
        "differs between runtime registry and scripts/db/migrate.py:\n"
        f"  runtime order:                   {runtime_triples}\n"
        f"  owner order (registry subset):   {owner_filtered}\n"
        "If a future migration depends on a column the previous one "
        "added, reordering the owner script can break it. Keep them "
        "in registration order."
    )


def _extract_drop_not_null_from_source(src: str) -> list[tuple[str, str]]:
    """Pull every ``ALTER COLUMN ... DROP NOT NULL`` statement out of
    Python source as ``(table, column)`` pairs. Dialect-split migrations
    yield the same pair on both branches; we de-dupe in source order.
    """
    seen: set[tuple[str, str]] = set()
    out: list[tuple[str, str]] = []
    for literal in _iter_string_literals(src):
        m = _DROP_NOT_NULL_RE.search(literal)
        if m is None:
            continue
        pair = (m.group("table"), m.group("column"))
        if pair in seen:
            continue
        seen.add(pair)
        out.append(pair)
    return out


def _runtime_alter_drop_not_null() -> list[tuple[str, str]]:
    """Walk every registered migration except ``v_0_1_0`` and accumulate
    DROP NOT NULL pairs in registration order."""
    pairs: list[tuple[str, str]] = []
    for m in runtime_migrations.MIGRATIONS:
        if m.version == "0.1.0":
            continue
        src = _migration_source(m)
        pairs.extend(_extract_drop_not_null_from_source(src))
    return pairs


def test_owner_script_covers_every_runtime_drop_not_null():
    """Every ``ALTER COLUMN ... DROP NOT NULL`` the runtime registry
    would apply must also appear in the owner script's ``DROP_NOT_NULL``
    list. Subset semantics mirror the ADD COLUMN test — the owner
    script may carry historical owner-only entries.
    """
    owner_module = _load_owner_script_module()
    runtime_pairs = _runtime_alter_drop_not_null()
    owner_pairs = set(owner_module.DROP_NOT_NULL)
    missing = set(runtime_pairs) - owner_pairs
    assert not missing, (
        f"DROP NOT NULL drift: runtime has {missing} that the owner "
        "script's DROP_NOT_NULL list does not. Add them to "
        "scripts/db/migrate.py."
    )


def test_owner_script_widen_lists_are_owner_only():
    """``WIDEN_TO_BIGINT`` is owner-script-only — no registered
    migration may emit ``ALTER COLUMN ... TYPE``. ``DROP_NOT_NULL`` is
    paired-checked in the test above; the registry-side DROP NOT NULL
    DDL must appear in the owner script too, but is also allowed to.

    Both lists must remain non-empty so silent deletion of historical
    fixes is loud.
    """
    owner_module = _load_owner_script_module()
    assert isinstance(owner_module.WIDEN_TO_BIGINT, list)
    assert owner_module.WIDEN_TO_BIGINT, (
        "owner script's WIDEN_TO_BIGINT list is empty; the historical "
        "BIGINT widening for runs.last_consumed_step_id and progress "
        "event ids should still be carried as a catchup."
    )
    assert isinstance(owner_module.DROP_NOT_NULL, list)
    assert owner_module.DROP_NOT_NULL, (
        "owner script's DROP_NOT_NULL list is empty; the historical "
        "agent_config.agent_version nullability fix should still be "
        "carried as a catchup."
    )

    widen_pattern = re.compile(
        r"\bALTER\s+COLUMN\b.*\bTYPE\b", re.IGNORECASE | re.DOTALL
    )
    for m in runtime_migrations.MIGRATIONS:
        if m.version == "0.1.0":
            continue  # create_all bootstrap — not a column-mutation migration.
        src = _migration_source(m)
        for literal in _iter_string_literals(src):
            match = widen_pattern.search(literal)
            assert match is None, (
                f"migration {m.version} contains DDL ({match.group(0)!r}) "
                "that matches an owner-script-only WIDEN operation. If "
                "this is intentional, extend test_migration_drift_owner "
                "to compare WIDEN_TO_BIGINT between registry and owner "
                "script the same way ADD COLUMN is compared today."
            )


def test_no_duplicate_columns_in_owner_script():
    """The owner script's ADD COLUMN list must not contain duplicate
    ``(table, column)`` pairs.

    Postgres ``ADD COLUMN IF NOT EXISTS`` would let duplicates pass
    silently, but a duplicate is almost always a copy-paste bug — the
    second entry's type spec gets ignored, masking a real type drift
    if the two entries disagree. Catching it here is cheap.
    """
    owner_module = _load_owner_script_module()
    seen: dict[tuple[str, str], str] = {}
    for table, column, col_type in owner_module.MIGRATIONS:
        key = (table, column)
        if key in seen:
            pytest.fail(
                f"duplicate ADD COLUMN entry in scripts/db/migrate.py for "
                f"{key}: first type {seen[key]!r}, second type {col_type!r}. "
                "Postgres swallows the duplicate via IF NOT EXISTS but the "
                "drift between the two type specs goes unnoticed."
            )
        seen[key] = col_type


def test_owner_script_covers_every_runtime_alter_drop_column():
    """Subtractive parity: every ``ALTER TABLE ... DROP COLUMN`` the
    runtime registry would apply must also appear in the owner
    script's ``DROP_COLUMNS`` list.

    Same coupling shape as the ADD COLUMN gate, just running in the
    other direction. If a future registry migration drops a column and
    the owner script doesn't, an the test workspaces owner-impersonation run
    against a Lakebase project that pre-dates the drop migration would
    silently leave the column behind. Eventually a fresh app process
    on that DB hits ORM-vs-schema drift on a SELECT or INSERT that
    touches every column on the table.
    """
    owner_module = _load_owner_script_module()
    runtime_pairs = _runtime_alter_drop_columns()
    owner_pairs = _owner_script_drop_column_pairs(owner_module)

    runtime_set = set(runtime_pairs)
    owner_set = set(owner_pairs)

    missing_from_owner = runtime_set - owner_set
    assert not missing_from_owner, (
        "DROP COLUMN drift between runtime registry and "
        "scripts/db/migrate.py:\n"
        f"  in runtime registry but missing from scripts/db/migrate.py:\n"
        + "\n".join(f"    {p}" for p in sorted(missing_from_owner))
        + "\nFix by appending the missing (table, column) pair to "
        "DROP_COLUMNS in scripts/db/migrate.py, in the same registration "
        "order the registry emits."
    )


def test_runtime_alter_drop_columns_appear_in_owner_in_registry_order():
    """Subtractive ordering: every DROP COLUMN the registry would emit
    must appear in ``DROP_COLUMNS`` in the same relative order.

    Reordering matters less for DROP than for ADD (a drop is a drop —
    it doesn't depend on a prior column existing), but a deterministic
    order keeps copy-paste reviews easy and future "drop-then-readd"
    migrations safe. Mirrors the ADD COLUMN ordering test.
    """
    owner_module = _load_owner_script_module()
    runtime_pairs = _runtime_alter_drop_columns()
    owner_pairs = _owner_script_drop_column_pairs(owner_module)

    runtime_set = set(runtime_pairs)
    owner_filtered = [p for p in owner_pairs if p in runtime_set]

    assert runtime_pairs == owner_filtered, (
        "Relative ordering of registry-emitted DROP COLUMN entries "
        "differs between runtime registry and scripts/db/migrate.py:\n"
        f"  runtime order:                   {runtime_pairs}\n"
        f"  owner order (registry subset):   {owner_filtered}\n"
        "Keep them in registration order."
    )


def test_no_duplicate_drop_columns_in_owner_script():
    """``DROP_COLUMNS`` must not contain duplicate ``(table, column)``
    pairs. Postgres ``DROP COLUMN IF EXISTS`` would swallow the
    duplicate silently, but it's almost always a copy-paste bug."""
    owner_module = _load_owner_script_module()
    drop_pairs = _owner_script_drop_column_pairs(owner_module)
    seen: set[tuple[str, str]] = set()
    for pair in drop_pairs:
        if pair in seen:
            pytest.fail(
                f"duplicate DROP COLUMN entry in scripts/db/migrate.py "
                f"for {pair}. Postgres swallows the duplicate via IF "
                "EXISTS but it's almost always a copy-paste bug."
            )
        seen.add(pair)


def test_drop_column_does_not_overlap_add_column():
    """A column can't simultaneously be in the registry's ADD COLUMN
    set AND the registry's DROP COLUMN set — that's nonsensical
    (you'd be re-adding a column the same registry then drops, or
    dropping a column the same registry then adds). The owner script
    inherits the same constraint.

    Catches a particularly nasty review escape: someone copies the
    wrong line out of a previous migration and ends up with a
    ``runs.business_context_text`` entry in both lists.
    """
    owner_module = _load_owner_script_module()
    add_pairs = {
        (table, column)
        for (table, column, _col_type) in owner_module.MIGRATIONS
    }
    drop_pairs = set(_owner_script_drop_column_pairs(owner_module))
    overlap = add_pairs & drop_pairs
    assert not overlap, (
        "scripts/db/migrate.py contains the same (table, column) in both "
        f"MIGRATIONS (ADD COLUMN) and DROP_COLUMNS: {sorted(overlap)}. "
        "A column can't be both added and dropped by the same owner script "
        "run; one of the two entries is wrong."
    )
