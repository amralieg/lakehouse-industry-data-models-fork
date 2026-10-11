"""Published industry models for tests, read from the git object store.

data-models/ is never checked out (repo CLAUDE.md, section -0): its objects stay in .git, so tests read one
model.json or one next_vibes.txt with `git show` into memory and never write it to disk.
"""
import functools
import json
import subprocess
from pathlib import Path

GIT_ROOT = Path(__file__).resolve().parents[3]
AIRLINES_V1_MVM = "data-models/airlines/v1/mvm/model.json"


@functools.lru_cache(maxsize=None)
def published_text(path, rev="HEAD"):
    return subprocess.check_output(["git", "show", f"{rev}:{path}"], cwd=str(GIT_ROOT)).decode("utf-8", errors="replace")


def published_json(path=AIRLINES_V1_MVM, rev="HEAD"):
    return json.loads(published_text(path, rev))


@functools.lru_cache(maxsize=None)
def published_paths(prefix, suffix, rev="HEAD"):
    out = subprocess.check_output(["git", "ls-tree", "-r", "--name-only", rev, prefix], cwd=str(GIT_ROOT)).decode("utf-8")
    return tuple(sorted(p for p in out.splitlines() if p.endswith(suffix)))
