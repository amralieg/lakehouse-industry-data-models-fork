"""Table-driven tests for ``artifact_indexer.infer_artifact_type``.

Covers the folder-rule ladder (model.json, vibes/, docs/, ontology/,
schemas/, metrics/, diagram/, top-level readme) plus the Story-5 ``.txt``
parent-folder typing and the extension fallback. The ``root``-relative
matching is exercised so a path prefixed with the Volume version dir types
identically to a bare sub-path.
"""

from __future__ import annotations

import pytest

from vibe_modeling.backend.services.artifact_indexer import infer_artifact_type


_ROOT = "/Volumes/cat/_metamodel/vol_root/business/acme/ecm_v1"


@pytest.mark.parametrize(
    "sub, expected",
    [
        # Path-specific JSON / next-vibes
        ("model.json", "model_json"),
        ("vibes/next_vibes.json", "next_vibes_json"),
        # Markdown / structured folder rules
        ("vibes/notes.md", "vibes_doc"),
        ("docs/data_model.xlsx", "excel"),
        ("docs/glossary.csv", "csv"),
        ("docs/overview.md", "markdown"),
        ("ontology/model.ttl", "turtle"),
        ("schemas/ddl.sql", "sql_ddl"),
        ("metrics/kpis.sql", "metric_sql"),
        ("diagram/model.dbml", "dbml"),
        ("readme.md", "readme"),
        # Story-5: .txt parent-folder typing
        ("vibes/next_vibes.txt", "vibes_text"),
        ("vibes/running_log.txt", "vibes_text"),
        ("ontology/ontology.txt", "ontology_text"),
        ("docs/notes.txt", "text"),
        # .txt outside any known folder -> text fallback
        ("loose.txt", "text"),
        ("misc/loose.txt", "text"),
        # Extension fallbacks
        ("data.csv", "csv"),
        ("schema.sql", "sql"),
        ("image.png", "image"),
        ("graph.svg", "svg"),
        # Unknown extension -> other
        ("mystery.bin", "other"),
    ],
)
def test_infer_artifact_type_with_root(sub: str, expected: str) -> None:
    """A path nested under the Volume version dir types by its sub-path."""
    assert infer_artifact_type(f"{_ROOT}/{sub}", root=_ROOT) == expected


@pytest.mark.parametrize(
    "sub, expected",
    [
        ("vibes/next_vibes.txt", "vibes_text"),
        ("ontology/ontology.txt", "ontology_text"),
        ("docs/notes.txt", "text"),
        ("loose.txt", "text"),
        ("model.json", "model_json"),
    ],
)
def test_infer_artifact_type_without_root(sub: str, expected: str) -> None:
    """With no ``root`` the bare sub-path still matches the folder ladder."""
    assert infer_artifact_type(sub) == expected
