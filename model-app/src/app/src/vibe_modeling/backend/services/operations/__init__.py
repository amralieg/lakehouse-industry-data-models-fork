"""Public surface for the operation primitive contract.

See ``docs/orchestrator-design.md`` §2 for the full design.

Importing this package registers all Phase-2 primitives as a side effect
(each module calls :func:`_registry.register` at import time). DAG factories
under ``routes/`` reference primitives by string name, so the registry must
be populated before the first ``OperationStep.name`` lookup.
"""

from ._protocol import (
    Operation,
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
    OperationResult,
)
from ._registry import all_names, get, register

# --- Primitive registrations -----------------------------------------------
# Each module registers its singleton on import. Idempotent against
# re-import: `register` raises on duplicate names, but Python caches
# modules so a second import is a no-op. Tests that need a clean slate
# use `_registry.reset_for_tests()`.
from .enlarge_to_ecm import EnlargeToEcm  # noqa: E402
from .generate_ecm import GenerateEcm  # noqa: E402
from .shrink_to_mvm import ShrinkToMvm  # noqa: E402
from .install import Install  # noqa: E402
from .uninstall import Uninstall  # noqa: E402
from .generate_samples import GenerateSamples  # noqa: E402
from . import import_from_volume as _import_from_volume  # noqa: F401, E402
from . import snapshot_version as _snapshot_version  # noqa: F401, E402
from . import vibe_iterate as _vibe_iterate  # noqa: F401, E402

for _op_cls in (
    GenerateEcm, ShrinkToMvm, EnlargeToEcm,
    Install, Uninstall, GenerateSamples,
):
    try:
        register(_op_cls())
    except ValueError:
        pass

__all__ = [
    "EnlargeToEcm",
    "GenerateEcm",
    "GenerateSamples",
    "Install",
    "Operation",
    "OperationContext",
    "OperationDispatchHandle",
    "OperationObservation",
    "OperationResult",
    "ShrinkToMvm",
    "Uninstall",
    "all_names",
    "get",
    "register",
]
