"""Stable id derivations shared across the backend.

The agent's notebook widgets accept ``vibe_session_id`` as a BIGINT-as-string.
The app generates UUIDs (variable shape, 36 chars), so we hash the UUID via
SHA-256 and truncate to a positive 63-bit BIGINT — the agent does the
inverse to look up its session row. Both sides MUST agree on this rule, so
the helper lives in ``core/`` next to the other widget-shaping helpers and
is re-exported from ``job_launcher`` for back-compat with existing callers.
"""

from __future__ import annotations

import hashlib
import uuid


def session_id_to_bigint(sid: str) -> int:
    """Convert a UUID string to a positive 63-bit BIGINT via SHA-256."""
    return int(hashlib.sha256(sid.encode()).hexdigest(), 16) & 0x7FFFFFFFFFFFFFFF


# --- uuid5 namespaces for derived Vibe Input ids -----------------------------
#
# Fixed so derived ids are stable across runs (the derived ids MUST NOT change).
# ``VI_NV_NS`` (agent next-vibe input id) and ``LINK_NS`` (context-link id) are
# LIVE: ``model_sync`` derives ids from them at sync time. ``VI_USER_NS`` has no
# caller today; kept here for provenance / possible future reuse.
VI_USER_NS = uuid.UUID("3f4a0b8e-1c2d-5e6f-8a9b-0c1d2e3f4a5b")
VI_NV_NS = uuid.UUID("7c8d9e0f-2a3b-5c6d-8e9f-0a1b2c3d4e5f")
LINK_NS = uuid.UUID("e9f0a1b2-3c4d-5e6f-8a0b-1c2d3e4f5a6b")
