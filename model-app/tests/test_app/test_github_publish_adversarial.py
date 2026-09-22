"""Adversarial tests for the GitHub publish flow + iter_bundle_files.

Independent skeptical-tester layer on top of ``test_github_publish.py``. These
probe the seams the happy-path tests don't: iter_bundle_files exactly-once
emission, collision dedupe under a companion named ``model.json``, multiple
colliding companions, prefix nesting, empty-artifacts, and the publish wire
boundary (base64 round-trips to the SAME bytes iter_bundle_files yields, the
model.json PUT lands at the FULL layout path not a flat one, the secret-PAT
guard wins even when a connection name is present, OBO client is the caller).
"""

from __future__ import annotations

import base64
import io
import json
import zipfile
from unittest.mock import MagicMock

import pytest
from fastapi import HTTPException
from sqlmodel import Session, select

from databricks.sdk.service.serving import ExternalFunctionRequestHttpMethod

from vibe_modeling.backend import model_export
from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
    ModelVersion,
    Run,
    RunArtifact,
)
from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend.services.github_publish import publish_model_version

from .test_github_publish import (
    _FakeRequestsResp,
    _FakeServingEndpoints,
    _FakeUserWs,
    _oauth_cfg,
    _seed,
)
from .test_model_export import SAMPLE_MODEL


# --- iter_bundle_files: a fake ws that records every downloaded path --------


class _RecordingWs:
    """A ws whose files.download returns per-path distinct bytes and records
    which paths were read, so we can assert exactly-once + correct bytes."""

    def __init__(self):
        self.downloaded: list[str] = []

    class _Files:
        def __init__(self, outer):
            self._outer = outer

        def download(self, path):
            self._outer.downloaded.append(path)
            return MagicMock(contents=io.BytesIO(f"data::{path}".encode()))

    @property
    def files(self):
        return _RecordingWs._Files(self)


def _art(path: str) -> RunArtifact:
    return RunArtifact(
        model_version_id="v", artifact_type="markdown", file_path=path
    )


LAYOUT = model_export.bundle_layout("Retail", "ecm", 2)
MODEL_JSON = {"model": {"type": "business", "name": "X", "domains": []}}


def _entries(ws, artifacts):
    return list(model_export.iter_bundle_files(ws, LAYOUT, MODEL_JSON, artifacts))


# --- model.json entry ------------------------------------------------------


def test_iter_emits_model_json_first_at_layout_path():
    ws = _RecordingWs()
    entries = _entries(ws, [])
    assert len(entries) == 1
    path, data = entries[0]
    assert path == LAYOUT.model_json_path == "retail/v2/ecm/model.json"
    # The bytes are the serialized model_json, not a download.
    assert json.loads(data.decode()) == MODEL_JSON
    assert ws.downloaded == []


def test_iter_empty_artifacts_yields_only_model_json():
    assert len(_entries(_RecordingWs(), [])) == 1
    assert len(_entries(_RecordingWs(), iter([]))) == 1


# --- exactly-once + correct bytes ------------------------------------------


def test_iter_yields_each_artifact_exactly_once_with_its_bytes():
    arts = [_art("/Volumes/a/report.md"), _art("/Volumes/a/ddl.sql")]
    ws = _RecordingWs()
    entries = _entries(ws, arts)
    paths = [p for p, _ in entries]
    assert paths == [
        "retail/v2/ecm/model.json",
        "retail/v2/ecm/report.md",
        "retail/v2/ecm/ddl.sql",
    ]
    # Each source path downloaded exactly once, in order.
    assert ws.downloaded == ["/Volumes/a/report.md", "/Volumes/a/ddl.sql"]
    # Bytes correspond to the right source file (no cross-wiring).
    by_path = dict(entries)
    assert by_path["retail/v2/ecm/report.md"] == b"data::/Volumes/a/report.md"
    assert by_path["retail/v2/ecm/ddl.sql"] == b"data::/Volumes/a/ddl.sql"


def test_iter_skips_artifacts_with_no_file_path():
    arts = [_art("/Volumes/a/report.md"), _art("")]
    arts[1].file_path = None
    ws = _RecordingWs()
    entries = _entries(ws, arts)
    assert [p for p, _ in entries] == [
        "retail/v2/ecm/model.json",
        "retail/v2/ecm/report.md",
    ]
    assert ws.downloaded == ["/Volumes/a/report.md"]


# --- collision dedupe ------------------------------------------------------


def test_iter_companion_named_model_json_does_not_collide():
    """A companion artifact literally named model.json must NOT overwrite or
    share the path of the reconstructed model.json entry."""
    arts = [_art("/Volumes/a/model.json")]
    entries = _entries(_RecordingWs(), arts)
    paths = [p for p, _ in entries]
    assert paths[0] == "retail/v2/ecm/model.json"
    # The companion deduped to model_1.json — distinct path.
    assert paths[1] == "retail/v2/ecm/model_1.json"
    assert len(set(paths)) == len(paths)
    # And the model.json entry still holds the reconstructed JSON, not the
    # artifact bytes.
    assert json.loads(dict(entries)[paths[0]].decode()) == MODEL_JSON
    assert dict(entries)[paths[1]] == b"data::/Volumes/a/model.json"


def test_iter_multiple_colliding_companions_get_incrementing_suffixes():
    arts = [
        _art("/Volumes/a/notes.md"),
        _art("/Volumes/b/notes.md"),
        _art("/Volumes/c/notes.md"),
    ]
    paths = [p for p, _ in _entries(_RecordingWs(), arts)]
    assert paths == [
        "retail/v2/ecm/model.json",
        "retail/v2/ecm/notes.md",
        "retail/v2/ecm/notes_1.md",
        "retail/v2/ecm/notes_2.md",
    ]
    assert len(set(paths)) == len(paths)


def test_iter_collision_with_no_extension():
    arts = [_art("/Volumes/a/LICENSE"), _art("/Volumes/b/LICENSE")]
    paths = [p for p, _ in _entries(_RecordingWs(), arts)]
    assert paths[1] == "retail/v2/ecm/LICENSE"
    assert paths[2] == "retail/v2/ecm/LICENSE_1"
    assert len(set(paths)) == len(paths)


# --- prefix nesting --------------------------------------------------------


def test_iter_nests_every_entry_under_layout_dir():
    arts = [_art("/Volumes/a/report.md")]
    entries = _entries(_RecordingWs(), arts)
    for p, _ in entries:
        assert p.startswith(LAYOUT.dir + "/"), p


def test_iter_industry_normalized_in_path():
    layout = model_export.bundle_layout("Acme & Co.", "MVM", 3)
    entries = list(
        model_export.iter_bundle_files(
            _RecordingWs(), layout, MODEL_JSON, [_art("/Volumes/a/x.md")]
        )
    )
    assert entries[0][0] == "acme_co/v3/mvm/model.json"
    assert entries[1][0] == "acme_co/v3/mvm/x.md"


# --- parity lock (anti-drift) ----------------------------------------------


def test_iter_zip_parity_with_companion_collision():
    """The anti-drift lock under the adversarial collision case: entries from
    iter_bundle_files == entries packed into the zip."""
    arts = [_art("/Volumes/a/model.json"), _art("/Volumes/b/model.json")]
    ws = _RecordingWs()
    iter_paths = [p for p, _ in _entries(ws, arts)]
    body = model_export.build_bundle_zip_bytes(
        _RecordingWs(), LAYOUT, MODEL_JSON, arts
    )
    with zipfile.ZipFile(io.BytesIO(body)) as zf:
        zip_paths = zf.namelist()
    assert sorted(iter_paths) == sorted(zip_paths)
    # Three distinct entries: model.json, model_1.json, model_2.json.
    assert len(zip_paths) == 3


def test_zip_contents_match_iter_bytes():
    """Not just path parity — the zip stores the same BYTES iter yields."""
    arts = [_art("/Volumes/a/report.md")]
    iter_entries = dict(_entries(_RecordingWs(), arts))
    body = model_export.build_bundle_zip_bytes(
        _RecordingWs(), LAYOUT, MODEL_JSON, arts
    )
    with zipfile.ZipFile(io.BytesIO(body)) as zf:
        for name in zf.namelist():
            assert zf.read(name) == iter_entries[name]


# --- publish wire boundary -------------------------------------------------


def test_publish_put_content_base64_roundtrips_to_bundle_bytes(engine):
    """Each content PUT carries base64 that decodes to the exact bytes
    iter_bundle_files produced for that path."""
    bid, vid = _seed(engine, with_artifact=True)
    ws = _FakeUserWs()
    cfg = _oauth_cfg()
    with Session(engine) as session:
        publish_model_version(
            ws, cfg, session=session, business_id=bid, version_id=vid
        )
        # Recompute the canonical bundle to compare bytes.
        mj = model_export.export_model_json(session, vid)
        mv = session.get(ModelVersion, vid)
        arts = session.exec(
            select(RunArtifact).where(RunArtifact.model_version_id == vid)
        ).all()
        biz = session.get(Business, bid)
        root = model_export.resolve_bundle_root(
            override=None, business=biz, scope=mv.scope or "", version=mv.version
        )
        layout = model_export.bundle_layout(
            mv.scope or "", mv.scope or "", mv.version, dir_override=root
        )
        expected = {
            p: d for p, d in model_export.iter_bundle_files(ws, layout, mj, arts)
        }

    for c in ws.serving_endpoints.calls:
        if c["method"] is ExternalFunctionRequestHttpMethod.PUT:
            body = c["json"]
            # path is /repos/owner/repo/contents/<bundle_path>
            bundle_path = c["path"].split("/contents/", 1)[1]
            assert bundle_path in expected, bundle_path
            assert base64.b64decode(body["content"]) == expected[bundle_path]


def test_publish_put_path_is_full_layout_not_flat(engine):
    """The model.json PUT must target the nested layout path, not a bare
    model.json at repo root."""
    bid, vid = _seed(engine)
    ws = _FakeUserWs()
    with Session(engine) as session:
        publish_model_version(
            ws, _oauth_cfg(), session=session, business_id=bid, version_id=vid
        )
    put_paths = [
        c["path"]
        for c in ws.serving_endpoints.calls
        if c["method"] is ExternalFunctionRequestHttpMethod.PUT
    ]
    # No source_repo_path/override -> bundle root derives from the business
    # NAME ("Test Retail" -> "test_retail"), not industry_alignment (ADR D-049).
    assert any(
        p.endswith("/contents/test_retail/v2/ecm/model.json") for p in put_paths
    ), put_paths


def test_publish_exactly_one_pull_request(engine):
    bid, vid = _seed(engine, with_artifact=True)
    ws = _FakeUserWs()
    with Session(engine) as session:
        publish_model_version(
            ws, _oauth_cfg(), session=session, business_id=bid, version_id=vid
        )
    pulls = [c for c in ws.serving_endpoints.calls if c["path"].endswith("/pulls")]
    assert len(pulls) == 1
    assert pulls[0]["method"] is ExternalFunctionRequestHttpMethod.POST


def test_publish_obo_client_is_the_only_caller(engine):
    """All GitHub HTTP goes through the passed-in (OBO) user_ws. The fake's
    serving_endpoints recorded calls == total calls made."""
    bid, vid = _seed(engine, with_artifact=True)
    ws = _FakeUserWs()
    with Session(engine) as session:
        publish_model_version(
            ws, _oauth_cfg(), session=session, business_id=bid, version_id=vid
        )
    # default-branch GET + head-sha GET + ref POST + 2 PUTs + 1 pulls POST = 6
    assert len(ws.serving_endpoints.calls) == 6


# --- guard precedence + ordering -------------------------------------------


def test_secret_pat_guard_wins_even_with_connection_name(engine):
    """secret_pat is checked before the oauth/connection guard: a config that
    is somehow secret_pat AND has a connection name still gets the not-
    implemented 422, never tries to publish."""
    bid, vid = _seed(engine)
    cfg = AgentConfig(
        github_auth_mode="secret_pat",
        github_connection_name="github_pr",
        github_secret_scope="s",
        github_secret_key="k",
    )
    ws = _FakeUserWs()
    with Session(engine) as session:
        with pytest.raises(HTTPException) as ei:
            publish_model_version(
                ws, cfg, session=session, business_id=bid, version_id=vid
            )
    assert ei.value.status_code == 422
    assert ei.value.detail["error"] == "github_pat_not_implemented"
    # No GitHub call attempted.
    assert ws.serving_endpoints.calls == []


def test_guard_fires_before_any_http_call(engine):
    bid, vid = _seed(engine)
    ws = _FakeUserWs()
    with Session(engine) as session:
        with pytest.raises(HTTPException):
            publish_model_version(
                ws,
                AgentConfig(github_auth_mode="oauth_u2m", github_connection_name=""),
                session=session,
                business_id=bid,
                version_id=vid,
            )
    assert ws.serving_endpoints.calls == []


def test_publish_unknown_version_is_404_not_502(engine):
    bid, _vid = _seed(engine)
    ws = _FakeUserWs()
    with Session(engine) as session:
        with pytest.raises(HTTPException) as ei:
            publish_model_version(
                ws,
                _oauth_cfg(),
                session=session,
                business_id=bid,
                version_id="nope",
            )
    assert ei.value.status_code == 404


def test_publish_version_belongs_to_other_business_is_404(engine):
    """Tenancy gate: a real version id under the WRONG business_id is 404."""
    bid, vid = _seed(engine)
    ws = _FakeUserWs()
    with Session(engine) as session:
        with pytest.raises(HTTPException) as ei:
            publish_model_version(
                ws,
                _oauth_cfg(),
                session=session,
                business_id="someone-else",
                version_id=vid,
            )
    assert ei.value.status_code == 404
    assert ws.serving_endpoints.calls == []


# --- audit provenance ------------------------------------------------------


def test_audit_run_carries_full_pr_provenance(engine):
    bid, vid = _seed(engine, with_artifact=True)
    ws = _FakeUserWs()
    with Session(engine) as session:
        result = publish_model_version(
            ws, _oauth_cfg(), session=session, business_id=bid, version_id=vid
        )
    with Session(engine) as session:
        run = session.exec(
            select(Run).where(Run.intent == "publish-to-github")
        ).one()
    assert run.status == "completed"
    assert run.progress_percent == 100
    assert run.business_id == bid
    assert run.version_id == vid
    assert run.started_at is not None and run.completed_at is not None
    params = json.loads(run.parameters_json)
    assert params["source"] == "github_publish"
    assert params["pr_number"] == result.pr_number == 7
    assert params["pr_url"] == result.pr_url
    assert params["branch"] == result.branch
    assert params["files"] == result.files
    # files provenance includes the nested model.json + the artifact.
    assert any(p.endswith("model.json") for p in params["files"])


def test_failed_pull_request_records_no_audit_run(engine):
    """If the PR POST returns an empty body (no number/url), the publish still
    records a run but with pr_number 0 — surfacing what actually happened
    rather than silently succeeding. Probes the degenerate-response path."""

    class _NoPullWs(_FakeUserWs):
        def __init__(self):
            super().__init__()
            base = self.serving_endpoints.http_request

            def patched(conn, method, path, *, json=None, **kw):
                if path.endswith("/pulls"):
                    self.serving_endpoints.calls.append(
                        {"connection_name": conn, "method": method,
                         "path": path, "json": json}
                    )
                    return _FakeRequestsResp({})
                return base(conn, method, path, json=json, **kw)

            self.serving_endpoints.http_request = patched

    bid, vid = _seed(engine)
    ws = _NoPullWs()
    with Session(engine) as session:
        result = publish_model_version(
            ws, _oauth_cfg(), session=session, business_id=bid, version_id=vid
        )
    assert result.pr_number == 0
    assert result.pr_url == ""
