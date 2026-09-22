"""Adversarial audit of the collision-proof zip arcname dedupe.

Written by an INDEPENDENT skeptical tester who distrusts the fix
(commit 1f9b1de). Target:
  * backend/_artifact_io.write_artifacts_to_zip  (set + increment-until-free)
  * build_artifacts_zip_bytes  (flat surface)
  * model_export.build_bundle_zip_bytes  (bundle / prefix surface)

Invariants every test asserts:
  * the resulting zip has NO duplicate arcnames
    (len(namelist) == len(set(namelist)))
  * NO bytes are lost: every input artifact maps to a distinct entry whose
    bytes equal the source bytes.
"""

from __future__ import annotations

import io
import zipfile
from collections import Counter
from unittest.mock import MagicMock

from vibe_modeling.backend._artifact_io import (
    build_artifacts_zip_bytes,
    dedupe_arcname,
    write_artifacts_to_zip,
)
from vibe_modeling.backend import model_export
from vibe_modeling.backend.db_models import RunArtifact


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _arts(paths):
    """RunArtifact rows with synthetic, per-path-distinct bytes.

    Each path's bytes are derived from the path so we can map an input back to
    its zip entry even after dedupe renames the arcname.
    """
    return [
        RunArtifact(
            run_id=None, model_version_id="v", artifact_type="t", file_path=p
        )
        for p in paths
    ]


def _ws_for(paths):
    """A ws whose download returns distinct bytes keyed off the FULL path.

    Note: paths must be unique for the byte map to be 1:1. Tests that want
    repeated *basenames* use distinct directories per entry.
    """
    mapping = {p: f"BYTES::{p}".encode() for p in paths}
    ws = MagicMock()

    def _download(path):
        resp = MagicMock()
        resp.contents.read.return_value = mapping[path]
        return resp

    ws.files.download.side_effect = _download
    return ws, mapping


def _read_zip(buf):
    buf.seek(0)
    with zipfile.ZipFile(buf) as zf:
        names = zf.namelist()
        contents = [zf.read(n) for n in names]
    return names, contents


def _assert_no_dupes_no_loss(names, contents, expected_payloads):
    # No duplicate arcnames.
    dupes = [n for n, c in Counter(names).items() if c > 1]
    assert not dupes, f"duplicate arcnames in zip: {dupes} (all: {names})"
    assert len(names) == len(set(names))
    # No bytes lost: every distinct input payload is present.
    got = Counter(contents)
    want = Counter(expected_payloads)
    assert got == want, (
        f"byte multiset mismatch.\n  missing: {want - got}\n  extra: {got - want}"
    )


def _run_flat(paths):
    ws, mapping = _ws_for(paths)
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w") as zf:
        write_artifacts_to_zip(zf, ws, _arts(paths))
    names, contents = _read_zip(buf)
    return names, contents, [mapping[p] for p in paths]


# ---------------------------------------------------------------------------
# Increment-loop attack chains (distinct dirs -> repeated basenames)
# ---------------------------------------------------------------------------


def test_chain_a_a_a1_a():
    # basenames: a.json, a.json, a_1.json, a.json
    paths = ["/d0/a.json", "/d1/a.json", "/d2/a_1.json", "/d3/a.json"]
    names, contents, payloads = _run_flat(paths)
    assert len(names) == 4, names
    _assert_no_dupes_no_loss(names, contents, payloads)


def test_chain_a_a1_a_a2_a1():
    # basenames: a.json, a_1.json, a.json, a_2.json, a_1.json
    paths = [
        "/d0/a.json",
        "/d1/a_1.json",
        "/d2/a.json",
        "/d3/a_2.json",
        "/d4/a_1.json",
    ]
    names, contents, payloads = _run_flat(paths)
    assert len(names) == 5, names
    _assert_no_dupes_no_loss(names, contents, payloads)


def test_chain_real_a1_a2_plus_two_a():
    # real a_1.json AND a_2.json already present, plus two a.json
    paths = [
        "/d0/a_1.json",
        "/d1/a_2.json",
        "/d2/a.json",
        "/d3/a.json",
    ]
    names, contents, payloads = _run_flat(paths)
    assert len(names) == 4, names
    _assert_no_dupes_no_loss(names, contents, payloads)


def test_chain_real_a1_first_then_a_collisions():
    # a.json, a_1.json (real), a.json -> second a.json must NOT clobber a_1.json
    paths = ["/d0/a.json", "/d1/a_1.json", "/d2/a.json"]
    names, contents, payloads = _run_flat(paths)
    assert len(names) == 3, names
    _assert_no_dupes_no_loss(names, contents, payloads)


# ---------------------------------------------------------------------------
# Extensionless / dotfile / multi-dot names
# ---------------------------------------------------------------------------


def test_extensionless_readme_chain():
    # README, README, README_1  -> the third must dodge the generated README_1
    paths = ["/d0/README", "/d1/README", "/d2/README_1"]
    names, contents, payloads = _run_flat(paths)
    assert len(names) == 3, names
    _assert_no_dupes_no_loss(names, contents, payloads)


def test_extensionless_many():
    paths = [f"/d{i}/README" for i in range(5)]
    names, contents, payloads = _run_flat(paths)
    assert len(names) == 5, names
    _assert_no_dupes_no_loss(names, contents, payloads)


def test_dotfiles():
    # .gitignore has no "name.ext" split point (rpartition on '.').
    paths = ["/d0/.gitignore", "/d1/.gitignore", "/d2/.gitignore"]
    names, contents, payloads = _run_flat(paths)
    assert len(names) == 3, names
    _assert_no_dupes_no_loss(names, contents, payloads)


def test_multi_dot_names():
    # a.b.json collisions: rpartition keeps base="a.b", ext="json".
    paths = ["/d0/a.b.json", "/d1/a.b.json", "/d2/a.b_1.json"]
    names, contents, payloads = _run_flat(paths)
    assert len(names) == 3, names
    _assert_no_dupes_no_loss(names, contents, payloads)


def test_trailing_dot_name():
    # "a." -> rpartition('.') => base="a", ext="" ; candidate "a_1."
    paths = ["/d0/a.", "/d1/a.", "/d2/a_1."]
    names, contents, payloads = _run_flat(paths)
    assert len(names) == 3, names
    _assert_no_dupes_no_loss(names, contents, payloads)


# ---------------------------------------------------------------------------
# Unicode / spaces / very long names
# ---------------------------------------------------------------------------


def test_unicode_and_space_names():
    paths = [
        "/d0/réport final.md",
        "/d1/réport final.md",
        "/d2/réport final_1.md",
    ]
    names, contents, payloads = _run_flat(paths)
    assert len(names) == 3, names
    _assert_no_dupes_no_loss(names, contents, payloads)


def test_very_long_names():
    stem = "x" * 240
    paths = [f"/d0/{stem}.json", f"/d1/{stem}.json", f"/d2/{stem}.json"]
    names, contents, payloads = _run_flat(paths)
    assert len(names) == 3, names
    _assert_no_dupes_no_loss(names, contents, payloads)


# ---------------------------------------------------------------------------
# Loop performance + correctness at scale
# ---------------------------------------------------------------------------


def test_many_identical_basenames():
    n = 250
    paths = [f"/d{i}/dup.json" for i in range(n)]
    names, contents, payloads = _run_flat(paths)
    assert len(names) == n, len(names)
    _assert_no_dupes_no_loss(names, contents, payloads)


def test_many_with_seeded_reals():
    # Pre-seed real dup_1..dup_50, then 50 colliding dup.json. The increment
    # loop must skip every seeded real name.
    reals = [f"/r{i}/dup_{i}.json" for i in range(1, 51)]
    collisions = [f"/c{i}/dup.json" for i in range(50)]
    paths = reals + collisions
    names, contents, payloads = _run_flat(paths)
    assert len(names) == len(paths), len(names)
    _assert_no_dupes_no_loss(names, contents, payloads)


# ---------------------------------------------------------------------------
# Prefix (bundle) path: same collisions nested under layout.dir/
# ---------------------------------------------------------------------------


def _run_prefixed(paths, prefix):
    ws, mapping = _ws_for(paths)
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w") as zf:
        write_artifacts_to_zip(zf, ws, _arts(paths), prefix=prefix)
    names, contents = _read_zip(buf)
    return names, contents, [mapping[p] for p in paths]


def test_prefixed_collision_chain():
    paths = ["/d0/a.json", "/d1/a.json", "/d2/a_1.json", "/d3/a.json"]
    names, contents, payloads = _run_prefixed(paths, prefix="acme/ecm_v3/")
    assert len(names) == 4, names
    assert all(n.startswith("acme/ecm_v3/") for n in names), names
    _assert_no_dupes_no_loss(names, contents, payloads)


def test_flat_and_prefixed_dedupe_independent():
    # Run the SAME collision set flat and prefixed; both must be internally
    # consistent. Prefixing must not reintroduce nor mask a collision.
    paths = ["/d0/a.json", "/d1/a.json", "/d2/a.json"]
    fnames, fcontents, fpayloads = _run_flat(paths)
    pnames, pcontents, ppayloads = _run_prefixed(paths, prefix="root/")
    _assert_no_dupes_no_loss(fnames, fcontents, fpayloads)
    _assert_no_dupes_no_loss(pnames, pcontents, ppayloads)
    # Stripped basenames should match between flat and prefixed (prefix is a
    # pure namespace, doesn't change dedupe arithmetic).
    stripped = sorted(n[len("root/"):] for n in pnames)
    assert stripped == sorted(fnames), (stripped, fnames)


# ---------------------------------------------------------------------------
# Bundle surface: model.json pre-write vs a companion artifact named model.json
# ---------------------------------------------------------------------------


def test_bundle_artifact_named_model_json_collides_with_prewrite():
    """build_bundle_zip_bytes writes layout.model_json_path (= dir/model.json)
    directly, OUTSIDE write_artifacts_to_zip's `seen` set. A companion artifact
    whose basename is `model.json` is written as `{dir}/model.json` -> SAME
    arcname. The dedupe set never saw the pre-write, so this silently produces
    a duplicate arcname / loses bytes."""
    layout = model_export.bundle_layout("Acme", "ecm", 3)
    paths = ["/some/dir/model.json"]
    ws, mapping = _ws_for(paths)
    model_json = {"model": {"type": "business", "name": "Acme", "domains": []}}
    body = model_export.build_bundle_zip_bytes(ws, layout, model_json, _arts(paths))
    names, contents = _read_zip(io.BytesIO(body))
    # The reconstructed model.json + the companion artifact are TWO inputs.
    assert len(names) == len(set(names)), (
        f"bundle produced a duplicate arcname (model.json pre-write collides "
        f"with a companion artifact named model.json): {names}"
    )
    assert mapping["/some/dir/model.json"] in contents, (
        "companion artifact bytes were lost to the model.json pre-write"
    )


def test_bundle_two_artifacts_named_model_json():
    """Two companion artifacts both named model.json, on top of the pre-written
    bundle model.json => three logical model.json entries; all must survive."""
    layout = model_export.bundle_layout("Acme", "mvm", 1)
    paths = ["/a/model.json", "/b/model.json"]
    ws, mapping = _ws_for(paths)
    model_json = {"model": {"type": "business", "name": "Acme", "domains": []}}
    body = model_export.build_bundle_zip_bytes(ws, layout, model_json, _arts(paths))
    names, contents = _read_zip(io.BytesIO(body))
    assert len(names) == len(set(names)), (
        f"bundle lost an entry to model.json collision: {names}"
    )
    for p in paths:
        assert mapping[p] in contents, f"lost companion bytes for {p}: {names}"


# ---------------------------------------------------------------------------
# Flat build_artifacts_zip_bytes surface parity
# ---------------------------------------------------------------------------


def test_build_artifacts_zip_bytes_chain():
    paths = ["/d0/a.json", "/d1/a.json", "/d2/a_1.json", "/d3/a.json"]
    ws, mapping = _ws_for(paths)
    body = build_artifacts_zip_bytes(ws, _arts(paths))
    names, contents = _read_zip(io.BytesIO(body))
    assert len(names) == 4, names
    _assert_no_dupes_no_loss(names, contents, [mapping[p] for p in paths])


def test_reserved_defaults_to_noop_on_flat_surface():
    """The new `reserved` param must default to a no-op: a flat zip built
    without passing `reserved` dedupes EXACTLY as before. Locks the contract
    that the bundle-only fix can't perturb the flat-download surface."""
    paths = ["/d0/a.json", "/d1/a.json", "/d2/a.json"]
    ws, mapping = _ws_for(paths)

    buf_default = io.BytesIO()
    with zipfile.ZipFile(buf_default, "w") as zf:
        write_artifacts_to_zip(zf, ws, _arts(paths))
    names_default, contents_default = _read_zip(buf_default)

    ws2, _ = _ws_for(paths)
    buf_explicit = io.BytesIO()
    with zipfile.ZipFile(buf_explicit, "w") as zf:
        write_artifacts_to_zip(zf, ws2, _arts(paths), reserved=None)
    names_explicit, _ = _read_zip(buf_explicit)

    assert names_default == names_explicit
    assert sorted(names_default) == sorted(["a.json", "a_1.json", "a_2.json"])
    _assert_no_dupes_no_loss(
        names_default, contents_default, [mapping[p] for p in paths]
    )


def test_reserved_set_not_mutated_by_helper():
    """The caller's `reserved` set must be copied, not mutated in place."""
    paths = ["/d0/model.json"]
    ws, _ = _ws_for(paths)
    reserved = {"model.json"}
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w") as zf:
        write_artifacts_to_zip(zf, ws, _arts(paths), reserved=reserved)
    assert reserved == {"model.json"}, f"helper mutated caller's set: {reserved}"


# ---------------------------------------------------------------------------
# Focused unit tests for the shared helper itself
# ---------------------------------------------------------------------------


def test_dedupe_arcname_free_name_unchanged():
    seen: set[str] = set()
    assert dedupe_arcname(seen, "model.json") == "model.json"
    assert seen == {"model.json"}


def test_dedupe_arcname_collision_suffixes_and_increments():
    seen: set[str] = set()
    assert dedupe_arcname(seen, "model.json") == "model.json"
    assert dedupe_arcname(seen, "model.json") == "model_1.json"
    assert dedupe_arcname(seen, "model.json") == "model_2.json"
    assert seen == {"model.json", "model_1.json", "model_2.json"}


def test_dedupe_arcname_extensionless():
    seen: set[str] = set()
    assert dedupe_arcname(seen, "README") == "README"
    assert dedupe_arcname(seen, "README") == "README_1"
    assert dedupe_arcname(seen, "README") == "README_2"
    assert seen == {"README", "README_1", "README_2"}


def test_dedupe_arcname_reserved_seeded():
    seen = {"model.json"}
    assert dedupe_arcname(seen, "model.json") == "model_1.json"
    assert "model.json" in seen and "model_1.json" in seen


def test_dedupe_arcname_skips_preexisting_suffix_slot():
    seen = {"model.json", "model_1.json"}
    assert dedupe_arcname(seen, "model.json") == "model_2.json"
