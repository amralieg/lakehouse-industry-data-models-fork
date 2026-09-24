"""Per-resource route modules split out of the legacy `router.py`.

Each module owns the endpoints for a single resource family and exposes a
`router` symbol — a `fastapi.APIRouter` already prefixed with the app's
`/api` prefix. The FastAPI app wires them up via `app.include_router(...)`
in `app.py`. The legacy `router.py` continues to host the `/runs/*`
endpoints (Phase 4 of the orchestrator refactor owns that surface).
"""

from . import (
    _dev_fixtures,
    businesses,
    config,
    deployment,
    industries,
    industry_models,
    platform,
    sectors,
    sources,
    versions,
)

__all__ = [
    "_dev_fixtures",
    "businesses",
    "config",
    "deployment",
    "industries",
    "industry_models",
    "platform",
    "sectors",
    "sources",
    "versions",
]
