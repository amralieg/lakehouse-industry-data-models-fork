"""Adversarial tests for the ``snapshot_version`` operation primitive.

See ``docs/orchestrator-design.md`` §2 + §10. ``snapshot_version`` is a
new primitive — there is no existing equivalent. Its contract:

* takes a ModelVersion id + a label, zips that version's Volume directory,
  records RunArtifact rows pointing at the snapshot zip, and reports them
  via ``OperationResult.output_artifacts``.
* is non-job (in-process) — ``observe()`` MUST return is_terminal=True.
* does NOT produce a new ModelVersion (``produces_version=False``).
* rollback deletes ONLY the artifact rows it added; the source
  ``ModelVersion`` stays put.

Tests are independent of the dev implementation; the local
``# STUB-FOR-INTEGRATION`` shim raises so failures on ``main`` are loud.
"""

from __future__ import annotations

from unittest.mock import MagicMock

import pytest
from pydantic import BaseModel, ValidationError
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    ModelVersion,
    Run,
    RunArtifact,
)
from vibe_modeling.backend.services.operations import (
    Operation,
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
    OperationResult,
)


# --------------------------------------------------------------------------
# Primitive import — STUB-FOR-INTEGRATION fallback.
# --------------------------------------------------------------------------


try:
    from vibe_modeling.backend.services.operations.snapshot_version import (  # type: ignore
        SnapshotVersion,
        SnapshotVersionParams,
    )
    PRIMITIVE_AVAILABLE = True
except Exception:  # pragma: no cover — STUB-FOR-INTEGRATION
    PRIMITIVE_AVAILABLE = False

    class SnapshotVersionParams(BaseModel):  # STUB-FOR-INTEGRATION
        pass

    class SnapshotVersion(Operation):  # STUB-FOR-INTEGRATION
        name = "snapshot_version"
        params_model = SnapshotVersionParams
        is_idempotent = False
        produces_version = False

        def dispatch(self, ctx, ws, session):
            raise NotImplementedError(
                "snapshot_version primitive is not implemented on this branch"
            )

        def observe(self, handle, ctx, ws, session):
            raise NotImplementedError(
                "snapshot_version primitive is not implemented on this branch"
            )

        def rollback(self, ctx, rollback_state, ws, session):
            raise NotImplementedError(
                "snapshot_version primitive is not implemented on this branch"
            )


# --------------------------------------------------------------------------
# Fixtures
# --------------------------------------------------------------------------


@pytest.fixture
def primitive() -> SnapshotVersion:
    return SnapshotVersion()


@pytest.fixture
def model_version(engine, seed_business) -> str:
    with Session(engine) as s:
        mv = ModelVersion(
            business_id=seed_business,
            version=1,
            status="completed",
            scope="ecm",
            uc_catalog="test_cat",
        )
        s.add(mv)
        s.commit()
        s.refresh(mv)
        return mv.id


@pytest.fixture
def run_row(engine, seed_business) -> str:
    with Session(engine) as s:
        r = Run(
            business_id=seed_business,
            intent="snapshot",
            status="pending",
            parameters_json="{}",
        )
        s.add(r)
        s.commit()
        s.refresh(r)
        return r.id


def _ctx(
    *,
    run_id: str,
    business_id: str,
    parent_version_id: str | None,
    params: dict | None = None,
    op_id: str = "op-snap-1",
) -> OperationContext:
    return OperationContext(
        run_id=run_id,
        operation_id=op_id,
        business_id=business_id,
        parent_version_id=parent_version_id,
        params=params or {"label": "milestone_v1"},
        inherited_params={},
    )


def _entry(name: str, is_dir: bool) -> MagicMock:
    """A directory entry mock shaped for the public ``walk_volume_dir``.

    The public walker reads ``entry.name`` (not ``entry.path``) and builds
    the absolute path itself as ``f"{root}/{name}"``; it also recurses per
    directory. Tests therefore describe a tree of *relative* file paths and
    this helper materialises the per-name SDK-style entries.
    """
    e = MagicMock()
    e.name = name
    e.is_directory = is_dir
    e.file_size = None
    return e


def _ws_with_volume_files(
    file_listing: list[str] | Exception,
) -> MagicMock:
    """Build a WorkspaceClient mock exposing a recursive Volume tree.

    ``file_listing`` is a list of file paths *relative* to the version dir
    (e.g. ``"model.json"``, ``"docs/data_model.xlsx"``). The mock's
    ``list_directory_contents`` is a directory-keyed ``side_effect`` that
    returns the immediate children (files + sub-dirs) of whatever root the
    public walker recurses into — mirroring the real non-recursive Files
    API. An ``Exception`` short-circuits to a raising stub.
    """
    ws = MagicMock()
    if isinstance(file_listing, Exception):
        ws.files.list_directory_contents.side_effect = file_listing
        return ws

    # Build a per-directory child index keyed by the directory's relative
    # path ("" == the version root). Each child is (name, is_directory).
    children: dict[str, dict[str, bool]] = {}
    for rel in file_listing:
        parts = rel.split("/")
        for depth in range(len(parts)):
            parent = "/".join(parts[:depth])
            name = parts[depth]
            is_dir = depth < len(parts) - 1
            children.setdefault(parent, {})
            # A name may appear as both dir and file across entries; dir wins.
            children[parent][name] = children[parent].get(name, False) or is_dir

    def _list(root: str):
        # Resolve the directory's relative key. The walker always passes an
        # absolute path; the relative remainder after the common root is what
        # we key on. We detect the version-dir root as the longest registered
        # prefix and strip it.
        rel_key = _relative_dir_key(root, children)
        entries = children.get(rel_key, {})
        return [_entry(name, is_dir) for name, is_dir in entries.items()]

    ws.files.list_directory_contents.side_effect = _list

    body = MagicMock()
    body.contents.read.return_value = b"<file content>"
    ws.files.download.return_value = body
    return ws


def _relative_dir_key(abs_root: str, children: dict[str, dict[str, bool]]) -> str:
    """Map an absolute directory path back to its relative tree key.

    The first ``list_directory_contents`` call is the version dir itself
    (relative key ``""``); deeper calls append ``/<subdir>`` segments. We
    recover the relative key by stripping the longest sub-path that the tree
    knows about from the tail of ``abs_root``.
    """
    abs_root = abs_root.rstrip("/")
    # The version root maps to "". Any deeper call ends with one of the
    # registered relative directory keys.
    candidates = sorted(
        (k for k in children if k), key=len, reverse=True
    )
    for key in candidates:
        if abs_root.endswith("/" + key) or abs_root == key:
            return key
    return ""


# --------------------------------------------------------------------------
# Class-level contract attributes (§2)
# --------------------------------------------------------------------------


def test_class_attributes(primitive):
    """§2 contract attributes for snapshot_version.

    ``is_idempotent`` is ``False`` because dispatch writes a new
    timestamped zip + RunArtifact row on every successful run
    (externally-visible non-idempotent effect, per the reconciliation
    rubric). The resume guard still dedupes a re-call with the same
    ``(run_id, operation_id)``; the boolean governs the orchestrator's
    automatic-retry policy, not the in-process dedupe.
    """
    assert PRIMITIVE_AVAILABLE, (
        "vibe_modeling.backend.services.operations.snapshot_version must "
        "exist and export SnapshotVersion + SnapshotVersionParams"
    )
    assert primitive.name == "snapshot_version"
    assert primitive.is_idempotent is False
    assert primitive.produces_version is False
    assert issubclass(primitive.params_model, BaseModel)
    assert primitive.__class__.__module__.startswith(
        "vibe_modeling.backend.services.operations"
    )


# --------------------------------------------------------------------------
# 1. Version doesn't exist → dispatch raises informative error.
# --------------------------------------------------------------------------


def test_dispatch_on_missing_version_raises(
    engine, primitive, seed_business, run_row
):
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id="this-version-does-not-exist",
    )
    ws = _ws_with_volume_files([])
    with Session(engine) as s:
        with pytest.raises(Exception) as exc_info:
            handle = primitive.dispatch(ctx, ws, s)
            # If dispatch did not raise, observe() must surface a terminal
            # failure with an informative error — but the spec says dispatch
            # raises directly for the "version doesn't exist" case.
            primitive.observe(handle, ctx, ws, s)
        msg = str(exc_info.value).lower()
        # The exception class must NOT be NotImplementedError — that's the
        # test stub talking, not the primitive doing real work.
        assert not isinstance(exc_info.value, NotImplementedError), (
            "dispatch must implement the missing-version check, not NotImplementedError"
        )
        assert any(
            tok in msg for tok in ("version", "not found", "missing", "unknown")
        ), f"error must mention the missing version: {exc_info.value!r}"


# --------------------------------------------------------------------------
# 2. Volume dir for the version is empty → succeeded=True with empty
#    artifact list (not an error — there's just nothing to snapshot).
# --------------------------------------------------------------------------


def test_empty_volume_dir_succeeds_with_empty_artifacts(
    engine, primitive, seed_business, model_version, run_row
):
    ws = _ws_with_volume_files([])
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=model_version,
    )
    with Session(engine) as s:
        handle = primitive.dispatch(ctx, ws, s)
        obs = primitive.observe(handle, ctx, ws, s)

    assert obs.is_terminal is True
    assert obs.terminal_result is not None
    assert obs.terminal_result.succeeded is True, (
        "an empty source dir is NOT a failure — the primitive must succeed "
        "with zero artifacts so the run completes cleanly"
    )
    assert obs.terminal_result.output_artifacts == [] or all(
        a.get("file_path") == "" for a in obs.terminal_result.output_artifacts
    )


# --------------------------------------------------------------------------
# 3. Zip creation fails (permission/disk) → succeeded=False with error.
# --------------------------------------------------------------------------


def test_zip_failure_returns_terminal_failure(
    engine, primitive, seed_business, model_version, run_row
):
    """Simulate the upload of the snapshot zip blowing up (permission or
    quota error from the Files API)."""
    ws = _ws_with_volume_files(["model.json"])
    ws.files.upload.side_effect = PermissionError("403: write denied")

    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=model_version,
    )
    with Session(engine) as s:
        handle = primitive.dispatch(ctx, ws, s)
        obs = primitive.observe(handle, ctx, ws, s)

    assert obs.is_terminal is True
    assert obs.terminal_result is not None
    assert obs.terminal_result.succeeded is False
    err = (obs.terminal_result.error or "").lower()
    assert any(tok in err for tok in ("permission", "denied", "403", "upload", "write")), (
        f"error must surface the underlying upload failure: "
        f"{obs.terminal_result.error!r}"
    )


# --------------------------------------------------------------------------
# 4. Snapshot label with special chars must be rejected or sanitized.
# --------------------------------------------------------------------------


@pytest.mark.parametrize(
    "evil_label",
    [
        "../../../etc/passwd",            # path traversal
        "label with spaces and\ttabs",    # whitespace control chars
        "label;rm -rf /",                 # shell injection
        "label\nwith\nnewlines",          # CR/LF injection
        "label/with/slashes",             # path separators
        "label\\with\\backslash",
        "",                               # empty
        " ",                              # whitespace only
        "a" * 257,                        # absurdly long
        "lab<el>",                        # XML/HTML special
    ],
)
def test_params_model_rejects_or_sanitizes_evil_labels(evil_label):
    """Either the params_model raises ValidationError, or it sanitizes the
    label such that the persisted value contains none of the dangerous
    characters. Both stances are acceptable."""
    try:
        p = SnapshotVersionParams(label=evil_label)
    except ValidationError:
        return  # rejection path is acceptable
    cleaned = p.label
    # If the impl chose to sanitize, the cleaned value must not contain
    # any of the obviously-dangerous characters / patterns.
    forbidden = ("/", "\\", "..", "\n", "\r", "\t", ";", "<", ">", " ")
    assert all(tok not in cleaned for tok in forbidden), (
        f"sanitised label {cleaned!r} still contains forbidden chars; "
        f"raw input was {evil_label!r}"
    )
    assert cleaned, "sanitized empty/whitespace-only label must not be persisted as-is"
    assert len(cleaned) <= 256, "sanitized label must be bounded in length"


def test_params_model_accepts_clean_label():
    p = SnapshotVersionParams(label="milestone_v1_release")
    assert p.label == "milestone_v1_release"


# --------------------------------------------------------------------------
# 5. Rollback deletes ONLY the snapshot artifact rows, NOT the model
#    version itself.
# --------------------------------------------------------------------------


def test_rollback_deletes_only_artifact_rows_not_model_version(
    engine, primitive, seed_business, model_version, run_row
):
    # Create artifact rows the rollback should delete.
    artifact_ids: list[str] = []
    with Session(engine) as s:
        for path in (
            "/Volumes/test_cat/_metamodel/snapshots/milestone_v1/model.json",
            "/Volumes/test_cat/_metamodel/snapshots/milestone_v1/data.zip",
        ):
            a = RunArtifact(
                run_id=run_row,
                model_version_id=model_version,
                artifact_type="snapshot",
                file_path=path,
            )
            s.add(a)
            s.commit()
            s.refresh(a)
            artifact_ids.append(a.id)

    rollback_state = {"artifact_ids": artifact_ids}
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=model_version,
    )
    with Session(engine) as s:
        primitive.rollback(ctx, rollback_state, MagicMock(), s)
        s.commit()

    with Session(engine) as s:
        artifacts_after = s.exec(
            select(RunArtifact).where(RunArtifact.id.in_(artifact_ids))
        ).all()
        mv_after = s.exec(
            select(ModelVersion).where(ModelVersion.id == model_version)
        ).first()

    assert artifacts_after == [], (
        "rollback must delete the snapshot artifact rows"
    )
    assert mv_after is not None, (
        "ModelVersion must NOT be deleted by snapshot_version rollback — "
        "the version pre-existed and is owned by a different op"
    )


# --------------------------------------------------------------------------
# 6. observe() returns is_terminal=True without polling for non-job ops.
# --------------------------------------------------------------------------


def test_observe_is_terminal_without_polling(
    engine, primitive, seed_business, model_version, run_row
):
    ws = _ws_with_volume_files([])
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=model_version,
    )
    with Session(engine) as s:
        h = primitive.dispatch(ctx, ws, s)
        obs = primitive.observe(h, ctx, ws, s)
    assert obs.is_terminal is True
    assert not ws.jobs.get_run.called, (
        "snapshot_version is non-job; observe() must not poll the Jobs API"
    )


# --------------------------------------------------------------------------
# 7. produces_version=False ⇒ output_version_id is always None.
# --------------------------------------------------------------------------


def test_terminal_result_never_sets_output_version_id(
    engine, primitive, seed_business, model_version, run_row
):
    ws = _ws_with_volume_files(["model.json"])
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=model_version,
    )
    with Session(engine) as s:
        h = primitive.dispatch(ctx, ws, s)
        obs = primitive.observe(h, ctx, ws, s)
    assert obs.terminal_result is not None
    assert obs.terminal_result.output_version_id is None, (
        "produces_version=False ⇒ output_version_id must be None per §2 invariant"
    )


# --------------------------------------------------------------------------
# 8. Successful snapshot writes RunArtifact rows linked to the version.
# --------------------------------------------------------------------------


def test_successful_snapshot_records_artifact_rows(
    engine, primitive, seed_business, model_version, run_row
):
    ws = _ws_with_volume_files(["model.json", "docs/data_model.xlsx"])
    ws.files.upload = MagicMock()  # snapshot zip upload succeeds

    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=model_version,
        params={"label": "milestone_a"},
    )
    with Session(engine) as s:
        h = primitive.dispatch(ctx, ws, s)
        obs = primitive.observe(h, ctx, ws, s)
        s.commit()

    assert obs.terminal_result is not None
    assert obs.terminal_result.succeeded is True
    assert obs.terminal_result.output_artifacts, (
        "successful snapshot of a non-empty version must report at least "
        "one artifact"
    )
    for a in obs.terminal_result.output_artifacts:
        assert "file_path" in a
        assert "artifact_type" in a


# --------------------------------------------------------------------------
# 9. Rollback is idempotent.
# --------------------------------------------------------------------------


def test_rollback_idempotent(
    engine, primitive, seed_business, model_version, run_row
):
    rollback_state = {"artifact_ids": ["already-deleted-1", "already-deleted-2"]}
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=model_version,
    )
    with Session(engine) as s:
        primitive.rollback(ctx, rollback_state, MagicMock(), s)
        primitive.rollback(ctx, rollback_state, MagicMock(), s)


# --------------------------------------------------------------------------
# 10. Dispatch is idempotent against re-call with the same operation_id.
# --------------------------------------------------------------------------


def test_dispatch_idempotent_per_op(
    engine, primitive, seed_business, model_version, run_row
):
    """Re-running dispatch with the same (run_id, op_id) must not duplicate
    artifact rows."""
    ws = _ws_with_volume_files(["model.json"])
    ws.files.upload = MagicMock()

    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        parent_version_id=model_version,
        params={"label": "milestone_idemp"},
        op_id="op-idemp-1",
    )
    with Session(engine) as s:
        primitive.dispatch(ctx, ws, s)
        primitive.observe(
            OperationDispatchHandle(databricks_run_id=None, vibe_session_id=None),
            ctx, ws, s,
        )
        s.commit()

    ws2 = _ws_with_volume_files(["model.json"])
    ws2.files.upload = MagicMock()
    with Session(engine) as s:
        primitive.dispatch(ctx, ws2, s)
        s.commit()

    # Inspect: artifact rows in the DB should not have doubled.
    with Session(engine) as s:
        artifacts = s.exec(
            select(RunArtifact).where(
                RunArtifact.run_id == run_row,
                RunArtifact.model_version_id == model_version,
            )
        ).all()
    # Implementations typically write one zip artifact per snapshot.
    # Either zero (if dispatch defers writes to observe) or one — never two.
    assert len(artifacts) <= 1, (
        f"dispatch idempotency violated: re-call duplicated artifact rows "
        f"({len(artifacts)} found)"
    )


# --------------------------------------------------------------------------
# 11. params_model requires label.
# --------------------------------------------------------------------------


def test_params_model_requires_label():
    with pytest.raises(ValidationError):
        SnapshotVersionParams()  # type: ignore[call-arg]


# --------------------------------------------------------------------------
# TestRollbackAdversarial — rollback edge cases per design doc §2 + §10.
#
# snapshot_version rollback contract (§10): "File copy fails → no version
# impact; rollback deletes artifact rows".
#
# Adversarial scenarios:
#   1. Rollback replay (idempotency invariant from §2).
#   2. Artifact rows already deleted between dispatch and rollback.
#   3. Rollback's underlying call raises → orchestrator handles.
#   4. Rollback must NOT touch the parent ModelVersion.
# --------------------------------------------------------------------------


class TestRollbackAdversarial:
    """Adversarial rollback cases for snapshot_version.

    Per design §10, snapshots have no version impact: rollback only
    undoes the bookkeeping rows, never the source ModelVersion. The
    physical zip on the Volume is intentionally left in place — re-running
    would just create a new timestamped name beside it.
    """

    def test_rollback_idempotent_under_replay(
        self, engine, primitive, seed_business, model_version, run_row
    ):
        """§2 invariant: replaying ``rollback`` against an already-rolled-back
        op MUST be a no-op (not raise)."""
        artifact_ids: list[str] = []
        with Session(engine) as s:
            a = RunArtifact(
                run_id=run_row,
                model_version_id=model_version,
                artifact_type="snapshot",
                file_path="/Volumes/test/snapshot.zip",
            )
            s.add(a)
            s.commit()
            s.refresh(a)
            artifact_ids.append(a.id)

        rollback_state = {"artifact_ids": artifact_ids}
        ctx = _ctx(
            run_id=run_row,
            business_id=seed_business,
            parent_version_id=model_version,
        )
        with Session(engine) as s:
            # First call deletes.
            primitive.rollback(ctx, rollback_state, MagicMock(), s)
            s.commit()
            # Second call — rows already gone, must not raise.
            primitive.rollback(ctx, rollback_state, MagicMock(), s)
            s.commit()

    def test_rollback_when_dependent_artifact_already_deleted(
        self, engine, primitive, seed_business, model_version, run_row
    ):
        """The artifact rows the rollback wants to delete may be gone before
        the rollback runs (raced cleanup, manual delete). Rollback must
        not raise — design doc §2 idempotency invariant."""
        rollback_state = {
            "artifact_ids": ["ghost-artifact-1", "ghost-artifact-2"]
        }
        ctx = _ctx(
            run_id=run_row,
            business_id=seed_business,
            parent_version_id=model_version,
        )
        with Session(engine) as s:
            primitive.rollback(ctx, rollback_state, MagicMock(), s)
            s.commit()

    def test_rollback_propagates_underlying_exception(
        self, engine, primitive, seed_business, model_version, run_row
    ):
        """When ``session.delete`` raises, the rollback must propagate the
        exception so ``services/orchestrator/_runner.py::_rollback_one``
        can catch it. Swallowing errors silently would leave the
        orchestrator thinking the chain succeeded when it didn't.
        """
        artifact_ids: list[str] = []
        with Session(engine) as s:
            a = RunArtifact(
                run_id=run_row,
                model_version_id=model_version,
                artifact_type="snapshot",
                file_path="/Volumes/test/snapshot.zip",
            )
            s.add(a)
            s.commit()
            s.refresh(a)
            artifact_ids.append(a.id)

        rollback_state = {"artifact_ids": artifact_ids}
        ctx = _ctx(
            run_id=run_row,
            business_id=seed_business,
            parent_version_id=model_version,
        )

        class _BoomSession:
            def __init__(self, real):
                self._real = real

            def __getattr__(self, name):
                return getattr(self._real, name)

            def get(self, *a, **kw):
                return self._real.get(*a, **kw)

            def delete(self, *a, **kw):
                raise RuntimeError("simulated artifact delete failure")

            def flush(self, *a, **kw):
                return self._real.flush(*a, **kw)

            def add(self, *a, **kw):
                return self._real.add(*a, **kw)

        with Session(engine) as s:
            boom = _BoomSession(s)
            with pytest.raises(RuntimeError):
                primitive.rollback(ctx, rollback_state, MagicMock(), boom)

    def test_rollback_does_not_touch_parent_model_version(
        self, engine, primitive, seed_business, model_version, run_row
    ):
        """snapshot_version-specific (§10): rollback deletes ONLY the
        artifact rows. The parent ModelVersion is untouched — snapshots
        are archival, not mutation. A rollback that deletes the version
        would corrupt the run / DAG semantics.
        """
        artifact_ids: list[str] = []
        with Session(engine) as s:
            for path in (
                "/Volumes/test/snap1.json",
                "/Volumes/test/snap2.zip",
            ):
                a = RunArtifact(
                    run_id=run_row,
                    model_version_id=model_version,
                    artifact_type="snapshot",
                    file_path=path,
                )
                s.add(a)
                s.commit()
                s.refresh(a)
                artifact_ids.append(a.id)

        rollback_state = {"artifact_ids": artifact_ids}
        ctx = _ctx(
            run_id=run_row,
            business_id=seed_business,
            parent_version_id=model_version,
        )
        with Session(engine) as s:
            primitive.rollback(ctx, rollback_state, MagicMock(), s)
            s.commit()

        with Session(engine) as s:
            mv_after = s.exec(
                select(ModelVersion).where(ModelVersion.id == model_version)
            ).first()
            arts_after = s.exec(
                select(RunArtifact).where(RunArtifact.id.in_(artifact_ids))
            ).all()
        assert mv_after is not None, (
            "snapshot_version rollback must NOT delete the parent ModelVersion "
            "(§10: rollback only undoes what dispatch did — artifact rows)"
        )
        assert arts_after == [], (
            "rollback must delete the artifact rows it produced"
        )
