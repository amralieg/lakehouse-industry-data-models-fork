"""Stability lock for the derived-id uuid5 namespaces.

``model_sync`` derives agent next-vibe input ids (``VI_NV_NS``) and
context-link ids (``LINK_NS``) via ``uuid.uuid5`` at sync time. The
namespaces MUST stay fixed - a change silently re-keys every derived id and
strands existing rows. These literals lock the current values.
"""

from __future__ import annotations

import os
import sys
import uuid

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from vibe_modeling.backend.core._ids import VI_NV_NS, LINK_NS  # noqa: E402


def test_vi_nv_namespace_is_stable():
    assert str(uuid.uuid5(VI_NV_NS, "v1:3")) == "f806e818-47fb-5fec-a378-4e326b4312b7"


def test_link_namespace_is_stable():
    assert (
        str(uuid.uuid5(LINK_NS, "someinput:someversion"))
        == "c77d399f-db99-5ddb-9710-c27c901011c3"
    )
