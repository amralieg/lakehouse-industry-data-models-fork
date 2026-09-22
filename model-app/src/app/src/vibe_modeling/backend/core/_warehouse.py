"""Single source of truth for resolving the SQL warehouse id used by
the agent + sync paths.

Reads from AgentConfig (Lakebase row populated by agent_config service).
Returns "" when unconfigured — callers handle as a flag, never a real id.

Companion helper: ``routes._helpers.resolve_warehouse_id`` is the
route-layer counterpart that wraps the bootstrap primitive
(``_get_or_create_agent_config``) which lazily INSERTs a row seeded from
``AppConfig`` env vars when none exists. ``get_warehouse_id`` here is the
plain read for non-route paths (operations, sync, rollback) where bootstrap
has already happened upstream and an unconfigured row is a real "off"
signal that callers gate on. Keep these two distinct — they have different
preconditions, but they MUST stay in sync if the underlying
``AgentConfig.warehouse_id`` field semantics ever change.
"""
from typing import Any

from sqlmodel import select

from ..db_models import AgentConfig


def get_warehouse_id(session: Any) -> str:
    """Return the configured SQL warehouse id, or empty if not configured.

    Used for both Delta polling (observe) and Lakebase sync. An empty
    value disables both paths gracefully — observe() can't read agent
    state without a warehouse, so we fall back to "still running" until
    one is configured.
    """
    cfg = session.exec(select(AgentConfig).limit(1)).first()
    if cfg and cfg.warehouse_id:
        return cfg.warehouse_id
    return ""
