"""Tests for the GitHub config endpoints (ADR D-049).

GET lazily seeds the AgentConfig singleton with the public industry-models repo
(decision 27) and returns the effective source repo; PUT persists the github_*
columns and GET reflects them. The token itself is never carried by the API -
only the connection name / secret pointers.
"""

from __future__ import annotations

from sqlmodel import Session

from vibe_modeling.backend.db_models import AgentConfig
from vibe_modeling.backend.sources.github import (
    DEFAULT_REPO_NAME,
    DEFAULT_REPO_OWNER,
)


def test_get_github_config_returns_seeded_default_source(client):
    """A fresh AgentConfig row is seeded with the public industry-models repo,
    so GET returns it (not empty). Other fields stay empty."""
    resp = client.get("/api/config/github")
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["repo_owner"] == DEFAULT_REPO_OWNER
    assert body["repo_name"] == DEFAULT_REPO_NAME
    assert body["auth_mode"] == ""
    assert body["connection_name"] == ""


def test_fresh_row_persists_seeded_repo(client, engine):
    """The seed is a real ROW-CREATION write: the stored columns carry the
    defaults (not just the OUTPUT fallback)."""
    client.get("/api/config/github")
    with Session(engine) as s:
        row = s.exec(__import__("sqlmodel").select(AgentConfig)).first()
    assert row is not None
    assert row.github_repo_owner == DEFAULT_REPO_OWNER
    assert row.github_repo_name == DEFAULT_REPO_NAME


def test_output_falls_back_for_preexisting_empty_row(client, engine):
    """A pre-existing row with empty github fields (created before the seed)
    still surfaces the default source via the OUTPUT layer - no read-path
    write occurs (the stored empty fields stay empty)."""
    with Session(engine) as s:
        s.add(AgentConfig(github_repo_owner="", github_repo_name=""))
        s.commit()
    body = client.get("/api/config/github").json()
    assert body["repo_owner"] == DEFAULT_REPO_OWNER
    assert body["repo_name"] == DEFAULT_REPO_NAME
    # No read-path write: the stored columns remain empty.
    with Session(engine) as s:
        row = s.exec(__import__("sqlmodel").select(AgentConfig)).first()
    assert row.github_repo_owner == ""
    assert row.github_repo_name == ""


def test_put_github_config_persists_and_reflects(client):
    payload = {
        "repo_owner": "databricks-industry-solutions",
        "repo_name": "lakehouse-business-data-models",
        "auth_mode": "oauth_u2m",
        "connection_name": "github_pr",
        "secret_scope": "",
        "secret_key": "",
    }
    put = client.put("/api/config/github", json=payload)
    assert put.status_code == 200, put.text
    assert put.json() == payload

    got = client.get("/api/config/github")
    assert got.status_code == 200
    assert got.json() == payload
