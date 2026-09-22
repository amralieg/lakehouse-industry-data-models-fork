import logging
import sys

logging.basicConfig(level=logging.INFO, stream=sys.stderr, force=True)

from .core import create_app
from .router import router  # legacy router (still owns /runs/* — see PLAN task #33)
from . import explorer  # noqa: F401 — registers explorer routes on the shared router
from . import diagram  # noqa: F401 — registers diagram routes on the shared router
from .routes import (
    _dev_fixtures,
    businesses,
    config,
    deployment,
    import_root,
    industries,
    industry_models,
    platform,
    sectors,
    sources,
    uc_browse,
    versions,
    vibe_inputs,
)

app = create_app(
    routers=[
        router,
        platform.router,
        industries.router,
        sectors.router,
        config.router,
        businesses.router,
        versions.router,
        deployment.router,
        sources.router,
        industry_models.router,
        uc_browse.router,
        import_root.router,
        vibe_inputs.router,
        _dev_fixtures.router,
    ]
)
