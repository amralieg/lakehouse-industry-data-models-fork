"""Catalog resolvers - one function per catalog-shaped concern.

The app touches four distinct catalog-shaped concerns that historically
shared one word ("deployment catalog") and, worse, shared ad-hoc inline
``x or y`` fallbacks that crossed concern boundaries. Each resolver below
is the ONE implementation of its concern's rule; inline cross-concern
fallbacks are banned elsewhere and drift-locked by test.

Concern table
=============
================  =========================================================
Concern           What it names / where the value lives
================  =========================================================
A. Metamodel      The UC catalog holding the agent's ``_metamodel`` Delta
   catalog         schema (``business``/``domain``/``product``/``attribute``/
                   ``_vibe_progress``) AND the ``_metamodel/vol_root`` Volume
                   (model.json, artifacts, vibe files). Installation-wide
                   admin setting stored in ``AgentConfig.deployment_catalog``
                   (DB column name unchanged; exposed to the API/UI as
                   ``metamodel_catalog``). Resolver:
                   :func:`resolve_metamodel_catalog`.
B. Install        Physical DDL target of an installed model version (real
   catalog         schemas/tables). Per model version, in
                   ``model_versions.uc_catalog``. ``""`` is a VALID state
                   meaning draft/never-installed - never a value to "fall
                   back" from. NO resolver by design: read ``mv.uc_catalog``
                   directly and treat ``""`` as draft.
C. Run metamodel  The ``deployment_catalog`` widget a specific run
   -target catalog dispatches. By agent contract this SELECTS where that
                   run's ``_metamodel`` lands (and, in One Catalog style
                   only, also the install target). Per run (form field),
                   defaulting to A. Resolver:
                   :func:`resolve_run_target_catalog`.
D. Lakebase       App state, deploy-time env. Out of scope here.
================  =========================================================

Agent-contract coupling (verified against the build mirror 2026-07-07,
``agent_source.py:32014-32023``, ``:5520-5576``): the ``{deployment_catalog}``
widget is the agent's ``_metamodel`` SELECTOR regardless of
``cataloging_style`` - ``business_catalog = deployment_catalog`` whenever the
widget is non-empty, and ``metamodel_db = f"{business_catalog}._metamodel"``.
Physical MODEL schemas are routed independently through ``CatalogResolver`` in
multi-catalog styles; the ``_metamodel`` control tables stay pinned at
``deployment_catalog._metamodel`` in every style. So a per-run override of the
widget is a designed mechanism (concern C), not an anomaly - it warrants an
informational visibility warning, never a block.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Any, Optional

if TYPE_CHECKING:  # pragma: no cover - typing only
    from ..db_models import AgentConfig, ModelVersion


def resolve_metamodel_catalog(session: Any, config: Any = None) -> str:
    """Concern A: the installation-wide metamodel catalog.

    Reads ``AgentConfig.deployment_catalog``. Returns ``""`` when
    unconfigured; callers that must not proceed on an empty value use
    :func:`routes._helpers.require_config` instead of inventing a fallback.

    Two call shapes:
    - ``config`` supplied (routes with ``Dependencies.Config``): goes through
      the get-or-create helper, which seeds a fresh row from the
      ``VIBE_MODELING_DEPLOYMENT_CATALOG`` env var on FIRST creation.
    - ``config`` omitted (read-only paths that don't thread ``AppConfig``,
      e.g. the model explorer): a session-only SELECT with NO seed and NO
      write - returns ``""`` when no row exists yet. This keeps read paths
      free of the singleton-seed write per the Track 4 no-read-path-writes
      rule.

    Feeds every ``_metamodel`` Delta/Volume path builder in
    :mod:`core._paths`.
    """
    if config is None:
        from sqlmodel import select

        from ..db_models import AgentConfig

        cfg = session.exec(select(AgentConfig).limit(1)).first()
        return (getattr(cfg, "deployment_catalog", "") or "").strip() if cfg else ""

    # Lazy import: ``core`` must not import ``routes`` at module load
    # (routes imports core), so defer the get-or-create helper to call time.
    from ..routes._helpers import _get_or_create_agent_config

    cfg = _get_or_create_agent_config(session, config)
    return (getattr(cfg, "deployment_catalog", "") or "").strip()


def resolve_run_target_catalog(
    data: Any, agent_config: Optional["AgentConfig"]
) -> str:
    """Concern C: the catalog a specific run dispatches its ``_metamodel`` to.

    Prefers the explicit run-form catalog (the ``deployment_catalog`` request
    field, then its legacy ``catalog`` alias), else the installation metamodel
    catalog (concern A) read from ``agent_config``. Returns ``""`` only when
    neither is set - ``require_config`` makes an empty dispatched widget
    unreachable so the agent never invents a catalog from the business name.

    This is the single implementation replacing the former
    ``_unified._resolve_deployment_catalog``, ``_simple._resolved_catalog``,
    and the inline ``data.catalog or agent_config.deployment_catalog`` chains
    at the run-dispatch / validate sites.
    """
    explicit = (getattr(data, "deployment_catalog", "") or "").strip()
    if not explicit:
        explicit = (getattr(data, "catalog", "") or "").strip()
    if explicit:
        return explicit
    return (getattr(agent_config, "deployment_catalog", "") or "").strip()


def resolve_version_volume_catalog(
    mv: Optional["ModelVersion"], session: Any, config: Any = None
) -> str:
    """The catalog a version's ``_metamodel`` Volume tree lives under.

    ``mv.uc_catalog`` when the version records a producing run's catalog,
    else the installation metamodel catalog (concern A). Documented meaning:
    "where this version's ``_metamodel`` artifacts (model.json, docs, vibe
    files) actually live". Used by artifact reads, resync, export/bundle
    roots, and the explorer docs directory.

    This promotes the previously-inline ``mv.uc_catalog or cfg.deployment_catalog``
    rule (formerly at ``versions.py``) to the one canonical site. Drafts whose
    ``uc_catalog`` is ``""`` correctly fall through to the installation catalog
    so their artifacts are still reachable - fixing the kickstart-class bug
    where an empty ``uc_catalog`` silently yielded no path.
    """
    own = (getattr(mv, "uc_catalog", "") or "").strip()
    if own:
        return own
    return resolve_metamodel_catalog(session, config)
