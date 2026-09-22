"""Operation registry: name → :class:`Operation` lookup.

DAGs reference operations by string name (see ``docs/orchestrator-design.md``
§2.2) so they remain serializable and survive process restarts. The registry
is a process-global dict populated at startup; operation modules call
:func:`register` from their import side effects in Phase 2.

The registry has no knowledge of validation, dispatch, or persistence — it
exists purely to keep ``OperationStep.name`` resolvable by both the
orchestrator and the validator without pulling primitive imports into route
handlers.
"""

from __future__ import annotations

from ._protocol import Operation

_OPERATIONS: dict[str, Operation] = {}


def register(op: Operation) -> None:
    """Register an :class:`Operation` instance by its ``name``.

    Raises:
        ValueError: if an operation with the same ``name`` is already
            registered. Operations are singletons; a second registration is
            always a programming error.
    """
    if op.name in _OPERATIONS:
        raise ValueError(f"Operation '{op.name}' already registered")
    _OPERATIONS[op.name] = op


def get(name: str) -> Operation:
    """Look up a registered :class:`Operation` by name.

    Raises:
        KeyError: if no operation has been registered under ``name``. The
            validator (§2.4) catches this and surfaces it as a blocker on
            the offending ``OperationStep`` before any RunOperation row is
            written.
    """
    if name not in _OPERATIONS:
        raise KeyError(f"Unknown operation: '{name}'")
    return _OPERATIONS[name]


def all_names() -> list[str]:
    """Return all registered operation names, sorted alphabetically."""
    return sorted(_OPERATIONS.keys())


def reset_for_tests() -> None:
    """Test-only: clear the registry so each test can populate fresh.

    Production code MUST NOT call this — the registry is meant to be
    populated once at startup and treated as immutable thereafter.
    """
    _OPERATIONS.clear()


def restore_production_for_tests() -> None:
    """Test-only: re-register all production primitives.

    Use in the teardown of any fixture that called :func:`reset_for_tests`
    so the next test file in the suite (which expects the production
    registry populated, e.g. for ``validate_dag`` to resolve primitive
    names by string) doesn't see a poisoned empty registry.

    Idempotent — already-registered primitives are skipped silently.
    """
    # Local import to avoid circulars (the primitive modules import this
    # registry at their own import time).
    from .enlarge_to_ecm import EnlargeToEcm
    from .generate_ecm import GenerateEcm
    from .generate_samples import GenerateSamples
    from .import_from_volume import ImportFromVolume
    from .install import Install
    from .shrink_to_mvm import ShrinkToMvm
    from .snapshot_version import SnapshotVersion
    from .uninstall import Uninstall
    from .vibe_iterate import VibeIterate

    for cls in (
        GenerateEcm,
        ShrinkToMvm,
        EnlargeToEcm,
        Install,
        Uninstall,
        GenerateSamples,
        ImportFromVolume,
        SnapshotVersion,
        VibeIterate,
    ):
        if cls().name not in _OPERATIONS:
            _OPERATIONS[cls().name] = cls()
