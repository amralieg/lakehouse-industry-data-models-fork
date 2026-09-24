"""``SourceConnector`` ABC and its value types (Wave 1, Track C).

A *source* is anything that can present a browsable catalog of data
models organised as a two-or-three level taxonomy:

    sector → industry → model

Concrete sources (GitHub today; the lakehouse metamodel / Volume later)
subclass :class:`SourceConnector` and implement the browse + fetch
methods. There is intentionally **no source registry** — callers
construct the one connector they need (see
``github.build_github_connector``) and ask it what it can do via
:meth:`SourceConnector.capabilities`.

Capabilities carry the three axes the plan calls out:

- **target kind** (:class:`TargetKind`) — what *kinds of elements* a
  source can hand back (whole models, just schemas, diagrams, …). A
  source declares this so a caller never asks for an element kind the
  source can't materialise.
- **discovery mode** (:class:`DiscoveryMode`) — how the catalog is
  enumerated (eager directory listing vs. lazy/on-demand).
- **materialization timing** (:class:`MaterializationTiming`) — when the
  bytes behind a model actually exist (already published at rest vs.
  generated on request).

The browse methods return lightweight reference objects
(:class:`SourceSector` / :class:`SourceIndustry` / :class:`SourceModelRef`);
the fetch methods return the heavier payloads (:class:`ModelArtifact` and
the raw ``model.json`` text). Read-only for now — publish/write comes in
a later wave via the UC connection.
"""

from __future__ import annotations

import abc
from enum import Enum
from typing import Literal

from pydantic import BaseModel, Field


class TargetKind(str, Enum):
    """A kind of element a source can provide.

    A source declares the subset it supports in
    :attr:`SourceCapabilities.target_kinds`, so a caller can tell up
    front whether (say) raw SQL schemas or rendered diagrams are
    obtainable, rather than fetching and getting an empty result.
    """

    MODEL_JSON = "model_json"
    """The canonical ``model.json`` document (the modelling unit)."""

    SCHEMAS = "schemas"
    """Generated SQL DDL schema files."""

    DIAGRAM = "diagram"
    """DBML / rendered diagram artifacts."""

    DOCS = "docs"
    """Human-readable docs (CSV/XLSX exports, release notes)."""

    METRICS = "metrics"
    """BI-ready metric-view definitions."""

    ONTOLOGY = "ontology"
    """Ontology / semantic tag artifacts."""

    VIBES = "vibes"
    """Agent ``vibes`` (the iteration inputs that produced the model)."""


class DiscoveryMode(str, Enum):
    """How a source enumerates its catalog."""

    EAGER_LISTING = "eager_listing"
    """The full tree can be listed by walking the source (e.g. a repo
    directory tree or a Volume listing)."""

    LAZY = "lazy"
    """Levels are resolved on demand; a full eager walk is not
    guaranteed to be cheap or available."""


class MaterializationTiming(str, Enum):
    """When the bytes behind a model actually exist."""

    AT_REST = "at_rest"
    """Models are already published and stored; a fetch is a read."""

    ON_DEMAND = "on_demand"
    """Models are generated/assembled when requested (a future
    metamodel/agent source)."""


class SourceCapabilities(BaseModel):
    """Self-description a source returns from
    :meth:`SourceConnector.capabilities`.

    ``provides_sectors`` records whether the source has a real top-level
    *sector* grouping. A flat source (the GitHub repo lists industries at
    its root) sets this ``False`` and synthesises a single implicit
    sector so the three-level browse contract still holds.
    """

    source_kind: str = Field(description="Stable identifier of the source implementation, e.g. 'github'.")
    target_kinds: list[TargetKind] = Field(description="Element kinds this source can provide.")
    discovery_mode: DiscoveryMode
    materialization_timing: MaterializationTiming
    provides_sectors: bool = Field(
        description="True if the source has a native sector level; False if sectors are synthesised."
    )
    read_only: bool = Field(default=True, description="True while publish/write is not yet supported.")
    auth_mode: Literal["github_app", "anonymous"] = Field(
        default="anonymous",
        description=(
            "Transport identity the connector browses with. 'anonymous' means "
            "unauthenticated (60 req/hr, rate-limited); 'github_app' means the "
            "deployment's GitHub App installation token (5,000 req/hr). Resolved "
            "per request: 'github_app' when the deployment has GitHub App "
            "credentials configured, else 'anonymous'."
        ),
    )

    def provides(self, kind: TargetKind) -> bool:
        """Whether this source can hand back the given element kind."""
        return kind in self.target_kinds


class SourceSector(BaseModel):
    """Top level of the browse taxonomy."""

    id: str = Field(description="Stable id within the source (slug / path segment).")
    name: str
    synthetic: bool = Field(
        default=False,
        description="True when the source has no native sector level and this is a synthesised wrapper.",
    )


class SourceIndustry(BaseModel):
    """Second level — an industry within a sector."""

    id: str = Field(description="Stable id within the source (slug / path segment).")
    sector_id: str
    name: str


class SourceModelRef(BaseModel):
    """A lightweight pointer to a model, returned by ``list_models``.

    The heavier ``model.json`` text and companion artifacts are fetched
    separately via :meth:`SourceConnector.fetch_model_json` /
    :meth:`SourceConnector.fetch_artifacts`.
    """

    id: str = Field(description="Stable id within the industry (e.g. 'ecm_v1').")
    industry_id: str
    name: str
    scope: str | None = Field(
        default=None, description="Model scope when discernible from the id ('ecm' / 'mvm')."
    )
    version: str | None = Field(default=None, description="Version label when discernible (e.g. 'v1').")


class ModelArtifact(BaseModel):
    """A companion artifact alongside a model (schema file, diagram, …)."""

    name: str
    target_kind: TargetKind
    path: str = Field(description="Source-relative path used to fetch the artifact's bytes.")
    size: int | None = Field(default=None, description="Size in bytes when the source reports it.")
    download_url: str | None = Field(
        default=None, description="Direct read URL when the source exposes one (e.g. raw GitHub URL)."
    )


class SourceError(RuntimeError):
    """Base class for source-connector failures (transport, auth, parse)."""


class SourceNotFoundError(SourceError):
    """A requested sector / industry / model / artifact does not exist."""


class SourceRateLimitError(SourceError):
    """The source rejected the request because a rate limit was exhausted.

    Distinct from a generic transport failure so the route layer can map it to
    a 429 with an actionable message (configure auth, or wait for the reset)
    instead of a generic 502. ``reset_hint`` is a human-readable reset time
    when the source reports one.
    """

    def __init__(self, message: str, *, reset_hint: str = ""):
        super().__init__(message)
        self.reset_hint = reset_hint


class SourcePermissionError(SourceError):
    """The source rejected the request with 401/403 - the caller lacks access.

    Distinct from a generic transport failure so the route layer maps it to a
    403 (not a 502). For the GitHub-App read path the cause is one of: the app's
    GitHub App credentials are missing or invalid, or the target repository is
    private. Non-rate-limit 403s only - a rate-limited 403 is converted to
    :class:`SourceRateLimitError` earlier (see ``github._raise_if_rate_limited``).
    """


class SourceConnector(abc.ABC):
    """Read-only browse + fetch contract every source implements.

    Implementations must be safe to construct cheaply (no network in
    ``__init__``); all I/O happens in the methods below. The browse
    methods raise :class:`SourceNotFoundError` for a missing parent and
    :class:`SourceError` for transport/parse failures.
    """

    @abc.abstractmethod
    def capabilities(self) -> SourceCapabilities:
        """Declare what this source can do — taxonomy levels, element
        kinds, discovery mode, materialization timing. Cheap / no I/O."""

    @abc.abstractmethod
    def list_sectors(self) -> list[SourceSector]:
        """List the top-level sectors. A flat source returns a single
        synthesised sector (``synthetic=True``)."""

    @abc.abstractmethod
    def list_industries(self, sector_id: str) -> list[SourceIndustry]:
        """List industries within ``sector_id``."""

    @abc.abstractmethod
    def list_models(self, industry_id: str) -> list[SourceModelRef]:
        """List the models published under ``industry_id``."""

    @abc.abstractmethod
    def fetch_model_json(self, industry_id: str, model_id: str) -> str:
        """Return the raw ``model.json`` text for a model.

        Raw text (not a parsed dict) so the caller owns parsing and the
        seam stays agnostic to the model schema (which other modules own)."""

    @abc.abstractmethod
    def fetch_artifacts(self, industry_id: str, model_id: str) -> list[ModelArtifact]:
        """List the companion artifacts available for a model, each
        tagged with its :class:`TargetKind`."""

    @abc.abstractmethod
    def fetch_readme(self, industry_id: str, model_id: str) -> str | None:
        """Return the model's readme text, or ``None`` when it has none."""

    @abc.abstractmethod
    def fetch_releasenotes(self, industry_id: str, model_id: str) -> str | None:
        """Return the model's release-notes text (used for preview
        statistics), or ``None`` when it has none / is unreachable."""
