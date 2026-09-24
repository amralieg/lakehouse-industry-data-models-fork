"""Unit tests for the shared require_config preflight helper."""

from __future__ import annotations

import pytest
from fastapi import HTTPException
from sqlmodel import Session

from vibe_modeling.backend.core._config import AppConfig
from vibe_modeling.backend.db_models import AgentConfig
from vibe_modeling.backend.routes._helpers import require_config


def _empty_config():
    return AppConfig(app_name="test", warehouse_id="", deployment_catalog="")


def _seed(session, **kw):
    session.add(AgentConfig(**kw))
    session.commit()


# --- collect mode ----------------------------------------------------------


def test_collect_returns_empty_when_all_present(engine):
    with Session(engine) as s:
        _seed(s, notebook_path="/nb", job_id=1, deployment_catalog="cat", warehouse_id="wh")
        out = require_config(
            s, None, ["agent_job", "metamodel_catalog", "warehouse"], mode="collect"
        )
        assert out == []


@pytest.mark.parametrize(
    "key,seed",
    [
        ("agent_job", dict(deployment_catalog="cat", warehouse_id="wh")),
        ("metamodel_catalog", dict(notebook_path="/nb", warehouse_id="wh")),
        ("warehouse", dict(notebook_path="/nb", deployment_catalog="cat")),
    ],
)
def test_collect_flags_each_missing_key(engine, key, seed):
    with Session(engine) as s:
        _seed(s, **seed)
        out = require_config(s, None, [key], mode="collect")
        assert len(out) == 1
        assert out[0].severity == "blocker"


def test_source_repo_effectively_always_present(engine):
    """source_repo is seeded on row creation and the connector falls back to
    the public repo, so require_config treats it as present even when the
    stored fields are empty (decision 27)."""
    with Session(engine) as s:
        _seed(s)  # empty github fields
        assert require_config(s, None, ["source_repo"], mode="collect") == []


# --- raise mode ------------------------------------------------------------


def test_raise_noop_when_present(engine):
    with Session(engine) as s:
        _seed(s, notebook_path="/nb", deployment_catalog="cat", warehouse_id="wh")
        # No raise → returns None.
        assert require_config(s, None, ["metamodel_catalog", "warehouse"], mode="raise") is None


def test_raise_422_config_missing_payload(engine):
    with Session(engine) as s:
        _seed(s, notebook_path="/nb")  # no catalog, no warehouse
        with pytest.raises(HTTPException) as exc:
            require_config(
                s, None, ["metamodel_catalog", "warehouse"], mode="raise"
            )
        assert exc.value.status_code == 422
        detail = exc.value.detail
        assert detail["error"] == "config_missing"
        keys = {m["key"] for m in detail["missing"]}
        assert keys == {"metamodel_catalog", "warehouse"}
        # Deep-link + label present for the FE.
        for m in detail["missing"]:
            assert m["settings_url"].startswith("/settings?tab=")
            assert m["label"]
        assert isinstance(detail["message"], str) and detail["message"]


def test_metamodel_catalog_seeded_from_env_counts_as_present(engine):
    # Fresh DB + a config carrying the env seed → get-or-create seeds the row,
    # so the metamodel catalog is considered present.
    cfg = AppConfig(app_name="test", warehouse_id="wh", deployment_catalog="seeded_cat")
    with Session(engine) as s:
        assert require_config(s, cfg, ["metamodel_catalog"], mode="collect") == []


def test_source_repo_present_with_partial_config(engine):
    # Even a partial config (owner set, name empty) resolves via the default
    # fallback, so source_repo is not flagged.
    with Session(engine) as s:
        _seed(s, github_repo_owner="acme")
        assert require_config(s, None, ["source_repo"], mode="collect") == []
