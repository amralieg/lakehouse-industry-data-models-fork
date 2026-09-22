"""Source-connector seam (Wave 1, Track C).

A general, source-agnostic abstraction for *browsing a catalog of
sectors / industries / models from an external source*. The first
concrete source is a public GitHub repository of industry data models
(``sources/github.py``); the seam is shaped so a future source — the
lakehouse metamodel / Volume — can implement the same
:class:`~vibe_modeling.backend.sources.base.SourceConnector` ABC without
a source registry.

A connector *declares its capabilities* (:class:`SourceCapabilities`)
so callers can discover, ahead of time, which taxonomy levels and
element kinds it can provide rather than probing and failing. See
``base.py`` for the contract and ``github.py`` for the GitHub
implementation.
"""

from __future__ import annotations

from .base import (
    DiscoveryMode,
    MaterializationTiming,
    ModelArtifact,
    SourceCapabilities,
    SourceConnector,
    SourceError,
    SourceIndustry,
    SourceModelRef,
    SourceNotFoundError,
    SourcePermissionError,
    SourceRateLimitError,
    SourceSector,
    TargetKind,
)
from .github import (
    BaselineResolution,
    GithubAppCredentials,
    GithubAppTransport,
    GithubSourceConnector,
    UcConnectionTransport,
    build_github_connector,
    find_latest_same_scope_version,
    model_id_to_relpath,
    parse_model_statistics,
)

__all__ = [
    "DiscoveryMode",
    "MaterializationTiming",
    "ModelArtifact",
    "SourceCapabilities",
    "SourceConnector",
    "SourceError",
    "SourceIndustry",
    "SourceModelRef",
    "SourceNotFoundError",
    "SourcePermissionError",
    "SourceRateLimitError",
    "SourceSector",
    "TargetKind",
    "GithubAppCredentials",
    "GithubAppTransport",
    "GithubSourceConnector",
    "UcConnectionTransport",
    "build_github_connector",
    "BaselineResolution",
    "find_latest_same_scope_version",
    "model_id_to_relpath",
    "parse_model_statistics",
]
