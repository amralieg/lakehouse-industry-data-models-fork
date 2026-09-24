"""Tests for the artifact list and download endpoints.

Covers:
- GET /runs/{run_id}/artifacts               (list)
- GET /runs/{run_id}/artifacts/{id}/download (single-file stream)
- GET /runs/{run_id}/artifacts/download      (bulk zip)
"""

import io
import zipfile
from unittest.mock import MagicMock

from sqlmodel import Session

from vibe_modeling.backend.db_models import ModelVersion, Run, RunArtifact


def _seed_run(engine, business_id: str) -> str:
    with Session(engine) as session:
        run = Run(
            business_id=business_id,
            intent="new-base-model",
            status="completed",
        )
        session.add(run)
        session.commit()
        session.refresh(run)
        return run.id


def _seed_artifact(
    engine,
    run_id: str,
    file_path: str,
    artifact_type: str = "readme",
    *,
    model_version_id: str | None = None,
) -> str:
    with Session(engine) as session:
        artifact = RunArtifact(
            run_id=run_id,
            artifact_type=artifact_type,
            file_path=file_path,
            model_version_id=model_version_id,
        )
        session.add(artifact)
        session.commit()
        session.refresh(artifact)
        return artifact.id


def _mock_download_map(mock_ws, files: dict[str, bytes]):
    """Wire mock_ws.files.download to return bytes keyed by path."""

    def _download(path: str):
        if path not in files:
            raise FileNotFoundError(path)
        resp = MagicMock()
        resp.contents.read.return_value = files[path]
        return resp

    mock_ws.files.download.side_effect = _download


class TestListArtifacts:
    def test_empty_list(self, client_with_agent, seed_business, engine):
        bid = seed_business
        run_id = _seed_run(engine, seed_business)
        r = client_with_agent.get(f"/api/businesses/{bid}/runs/{run_id}/artifacts")
        assert r.status_code == 200
        assert r.json() == []

    def test_lists_all_artifacts_for_run(
        self, client_with_agent, seed_business, engine
    ):
        bid = seed_business
        run_id = _seed_run(engine, seed_business)
        _seed_artifact(engine, run_id, "/Volumes/c/s/v/model.json", "json")
        _seed_artifact(engine, run_id, "/Volumes/c/s/v/readme.md", "readme")

        r = client_with_agent.get(f"/api/businesses/{bid}/runs/{run_id}/artifacts")
        assert r.status_code == 200
        items = r.json()
        assert len(items) == 2
        paths = {a["file_path"] for a in items}
        assert paths == {"/Volumes/c/s/v/model.json", "/Volumes/c/s/v/readme.md"}

    def test_scopes_to_run(self, client_with_agent, seed_business, engine):
        bid = seed_business
        run_a = _seed_run(engine, seed_business)
        run_b = _seed_run(engine, seed_business)
        _seed_artifact(engine, run_a, "/Volumes/c/s/v/a.md")
        _seed_artifact(engine, run_b, "/Volumes/c/s/v/b.md")

        r = client_with_agent.get(f"/api/businesses/{bid}/runs/{run_a}/artifacts")
        items = r.json()
        assert [a["file_path"] for a in items] == ["/Volumes/c/s/v/a.md"]


class TestDownloadArtifact:
    def test_downloads_text_file(
        self, client_with_agent, mock_ws, seed_business, engine
    ):
        bid = seed_business
        run_id = _seed_run(engine, seed_business)
        artifact_id = _seed_artifact(engine, run_id, "/Volumes/c/s/v/readme.md")
        _mock_download_map(mock_ws, {"/Volumes/c/s/v/readme.md": b"# Hello\n"})

        r = client_with_agent.get(
            f"/api/businesses/{bid}/runs/{run_id}/artifacts/{artifact_id}/download"
        )
        assert r.status_code == 200, r.text
        assert r.content == b"# Hello\n"
        assert "attachment" in r.headers["content-disposition"]
        assert "readme.md" in r.headers["content-disposition"]

    def test_downloads_binary_file(
        self, client_with_agent, mock_ws, seed_business, engine
    ):
        bid = seed_business
        run_id = _seed_run(engine, seed_business)
        path = "/Volumes/c/s/v/export.parquet"
        artifact_id = _seed_artifact(engine, run_id, path, "parquet")
        payload = b"PAR1\x00\x01\x02\x03binarydata"
        _mock_download_map(mock_ws, {path: payload})

        r = client_with_agent.get(
            f"/api/businesses/{bid}/runs/{run_id}/artifacts/{artifact_id}/download"
        )
        assert r.status_code == 200
        assert r.content == payload
        assert "export.parquet" in r.headers["content-disposition"]

    def test_inline_pdf_sets_mime_and_disposition(
        self, client_with_agent, mock_ws, seed_business, engine
    ):
        bid = seed_business
        run_id = _seed_run(engine, seed_business)
        path = "/Volumes/c/s/v/report.pdf"
        artifact_id = _seed_artifact(engine, run_id, path, "pdf")
        payload = b"%PDF-1.4 minimal"
        _mock_download_map(mock_ws, {path: payload})
        r = client_with_agent.get(
            f"/api/businesses/{bid}/runs/{run_id}/artifacts/{artifact_id}/download?inline=1"
        )
        assert r.status_code == 200
        assert r.content == payload
        assert r.headers["content-type"].startswith("application/pdf")
        assert "inline" in r.headers["content-disposition"]
        assert "report.pdf" in r.headers["content-disposition"]

    def test_unknown_artifact_404(
        self, client_with_agent, seed_business, engine
    ):
        bid = seed_business
        run_id = _seed_run(engine, seed_business)
        r = client_with_agent.get(
            f"/api/businesses/{bid}/runs/{run_id}/artifacts/does-not-exist/download"
        )
        assert r.status_code == 404

    def test_volume_read_failure_502(
        self, client_with_agent, mock_ws, seed_business, engine
    ):
        bid = seed_business
        run_id = _seed_run(engine, seed_business)
        artifact_id = _seed_artifact(engine, run_id, "/Volumes/c/s/v/readme.md")
        mock_ws.files.download.side_effect = RuntimeError("volume unreachable")

        r = client_with_agent.get(
            f"/api/businesses/{bid}/runs/{run_id}/artifacts/{artifact_id}/download"
        )
        assert r.status_code == 502


class TestDownloadAllArtifactsZip:
    def test_zips_all_artifacts(
        self, client_with_agent, mock_ws, seed_business, engine
    ):
        bid = seed_business
        run_id = _seed_run(engine, seed_business)
        _seed_artifact(engine, run_id, "/Volumes/c/s/v/readme.md")
        _seed_artifact(engine, run_id, "/Volumes/c/s/v/model.json", "json")
        _mock_download_map(
            mock_ws,
            {
                "/Volumes/c/s/v/readme.md": b"# Hello\n",
                "/Volumes/c/s/v/model.json": b'{"a":1}',
            },
        )

        r = client_with_agent.get(f"/api/businesses/{bid}/runs/{run_id}/artifacts/download")
        assert r.status_code == 200, r.text
        assert r.headers["content-type"] == "application/zip"
        assert ".zip" in r.headers["content-disposition"]

        zf = zipfile.ZipFile(io.BytesIO(r.content))
        names = set(zf.namelist())
        assert names == {"readme.md", "model.json"}
        assert zf.read("readme.md") == b"# Hello\n"
        assert zf.read("model.json") == b'{"a":1}'

    def test_no_artifacts_returns_404(
        self, client_with_agent, seed_business, engine
    ):
        bid = seed_business
        run_id = _seed_run(engine, seed_business)
        r = client_with_agent.get(f"/api/businesses/{bid}/runs/{run_id}/artifacts/download")
        assert r.status_code == 404

    def test_duplicate_filenames_are_deduped(
        self, client_with_agent, mock_ws, seed_business, engine
    ):
        bid = seed_business
        run_id = _seed_run(engine, seed_business)
        _seed_artifact(engine, run_id, "/Volumes/c/s/v/dir1/schema.sql", "sql")
        _seed_artifact(engine, run_id, "/Volumes/c/s/v/dir2/schema.sql", "sql")
        _mock_download_map(
            mock_ws,
            {
                "/Volumes/c/s/v/dir1/schema.sql": b"-- a",
                "/Volumes/c/s/v/dir2/schema.sql": b"-- b",
            },
        )

        r = client_with_agent.get(f"/api/businesses/{bid}/runs/{run_id}/artifacts/download")
        assert r.status_code == 200
        zf = zipfile.ZipFile(io.BytesIO(r.content))
        names = zf.namelist()
        assert len(names) == 2
        assert "schema.sql" in names
        assert any(n.startswith("schema_") and n.endswith(".sql") for n in names)

    def test_volume_read_failure_502(
        self, client_with_agent, mock_ws, seed_business, engine
    ):
        bid = seed_business
        run_id = _seed_run(engine, seed_business)
        _seed_artifact(engine, run_id, "/Volumes/c/s/v/readme.md")
        mock_ws.files.download.side_effect = RuntimeError("volume unreachable")

        r = client_with_agent.get(f"/api/businesses/{bid}/runs/{run_id}/artifacts/download")
        assert r.status_code == 502


class TestDownloadAllArtifactsByVersionZip:
    def test_zips_artifacts_for_model_version(
        self, client_with_agent, mock_ws, seed_business, engine
    ):
        bid = seed_business
        run_id = _seed_run(engine, seed_business)
        with Session(engine) as session:
            mv = ModelVersion(
                business_id=seed_business, version=1, status="completed"
            )
            session.add(mv)
            session.commit()
            session.refresh(mv)
            mv_id = mv.id

        _seed_artifact(
            engine,
            run_id,
            "/Volumes/c/s/v/version-notes.md",
            "readme",
            model_version_id=mv_id,
        )
        _mock_download_map(
            mock_ws, {"/Volumes/c/s/v/version-notes.md": b"# Version\n"}
        )

        r = client_with_agent.get(
            f"/api/businesses/{bid}/model-versions/{mv_id}/artifacts/download"
        )
        assert r.status_code == 200, r.text
        assert r.headers["content-type"] == "application/zip"
        assert "model-version" in r.headers["content-disposition"].lower()

        zf = zipfile.ZipFile(io.BytesIO(r.content))
        assert zf.read("version-notes.md") == b"# Version\n"

    def test_no_artifacts_for_version_returns_404(
        self, client_with_agent, seed_business, engine
    ):
        bid = seed_business
        with Session(engine) as session:
            mv = ModelVersion(
                business_id=seed_business, version=1, status="completed"
            )
            session.add(mv)
            session.commit()
            session.refresh(mv)
            mv_id = mv.id

        r = client_with_agent.get(
            f"/api/businesses/{bid}/model-versions/{mv_id}/artifacts/download"
        )
        assert r.status_code == 404
