"""Drift lock between ``FK_RULES`` and the ``db_models`` ``ondelete=`` pairing.

``FK_RULES`` (in ``migrations/v_0_6_6.py``) is the single source of truth for
per-FK ON DELETE actions. The runtime migration and owner script re-point live
Postgres constraints from it; fresh installs (both dialects) pick the actions up
from ``db_models`` ``ondelete=`` via ``create_all``. This test asserts the two
never drift, by INTROSPECTING SQLAlchemy metadata (``fk.ondelete``) rather than
scanning source, so it survives however the FK is spelled in the model.
"""

from __future__ import annotations

from sqlmodel import SQLModel

import vibe_modeling.backend.db_models  # noqa: F401 - registers tables on metadata
from vibe_modeling.backend.migrations.v_0_6_6 import FK_RULES, SELF_FK_INDEX_COLUMNS


def _normalise(action: str | None) -> str | None:
    if action is None:
        return None
    return " ".join(action.upper().split())


def _ondelete_for(child: str, column: str) -> tuple[str | None, str | None]:
    """Return ``(ondelete, referred_table)`` for the single-column FK on
    ``child.column`` from SQLAlchemy metadata, or ``(None, None)`` if absent."""
    table = SQLModel.metadata.tables[child]
    for fkc in table.foreign_key_constraints:
        cols = [c.name for c in fkc.columns]
        if cols == [column]:
            referred = list(fkc.elements)[0].column.table.name
            return _normalise(fkc.ondelete), referred
    return None, None


def test_fk_rules_ondelete_matches_db_models():
    """Every FK_RULES row must be reflected by a matching ``ondelete=`` +
    referred-table on the db_models column."""
    mismatches = []
    for child, column, parent, action in FK_RULES:
        found_action, referred = _ondelete_for(child, column)
        if found_action != _normalise(action) or referred != parent:
            mismatches.append(
                f"{child}.{column} -> expected {parent} ON DELETE {action}, "
                f"got {referred} ON DELETE {found_action}"
            )
    assert not mismatches, "FK_RULES vs db_models drift:\n" + "\n".join(mismatches)


def test_no_action_anchors_stay_no_action():
    """The deliberate NO-ACTION guards must NOT carry an ondelete (they are
    absent from FK_RULES on purpose - the design's 'Keep NO ACTION' table)."""
    no_action = [
        ("businesses", "industry_id"),
        ("businesses", "sector_id"),
        ("vibe_input_context_links", "domain_id"),
        ("vibe_input_context_links", "subdomain_id"),
        ("vibe_input_context_links", "product_id"),
        ("vibe_input_context_links", "attribute_id"),
        ("vibe_input_context_links", "fk_link_id"),
    ]
    for child, column in no_action:
        found_action, _referred = _ondelete_for(child, column)
        assert found_action is None, (
            f"{child}.{column} should stay NO ACTION but carries "
            f"ON DELETE {found_action}"
        )


def test_self_fk_index_columns_indexed_in_db_models():
    """Every column the migration indexes (`SELF_FK_INDEX_COLUMNS`) must also
    carry an index in db_models, so fresh installs (create_all) and existing
    installs (migration) converge. Locks the sibling-omission class: a SET NULL
    self-FK added without an index on the child column is a seq-scan trap.
    """
    missing = []
    for table_name, column in SELF_FK_INDEX_COLUMNS:
        table = SQLModel.metadata.tables[table_name]
        indexed_single_cols = {
            list(ix.columns)[0].name
            for ix in table.indexes
            if len(ix.columns) == 1
        }
        # A single-column Field(index=True) also sets Column.index; accept either.
        col_index = table.columns[column].index
        if column not in indexed_single_cols and not col_index:
            missing.append(f"{table_name}.{column}")
    assert not missing, (
        "SET NULL self-FK columns indexed by the migration but NOT by db_models "
        f"(fresh installs would miss the index): {missing}"
    )
