"""STUB-FOR-INTEGRATION

Local stubs of the Phase 2 generation primitives so the adversarial test
suite can compile and fail (with NotImplementedError or ImportError)
against ``main`` while the dev agent's implementation is in flight on a
parallel branch.

At integration time the integrator replaces the imports below with the
real modules under
``vibe_modeling.backend.services.operations.{generate_ecm,shrink_to_mvm,
enlarge_to_ecm}``. Tests in this directory should import the primitive
classes via the ``_load_primitive`` helper here so the swap is
single-point.

Per the Skeptical Tester Pattern, these stubs are intentionally minimal:
they only satisfy the import surface the tests need. The real
implementations are not consulted to construct them.
"""

from __future__ import annotations

import importlib
from typing import Any

from pydantic import BaseModel, ConfigDict

from vibe_modeling.backend.services.operations import (
    Operation,
    OperationDispatchHandle,
    OperationObservation,
)


class _StubParams(BaseModel):
    """Permissive params model used only when the real op module is
    missing on ``main``. The real ``params_model`` is per-primitive and
    enforces the field-level rules tested in the validation suites."""

    model_config = ConfigDict(extra="allow")


class _StubGenerateEcm(Operation):
    name = "generate_ecm"
    params_model = _StubParams
    is_idempotent = False
    produces_version = True

    def dispatch(self, ctx, ws, session) -> OperationDispatchHandle:  # pragma: no cover - stub
        raise NotImplementedError("STUB: generate_ecm dispatch not implemented on main")

    def observe(self, handle, ctx, ws, session) -> OperationObservation:  # pragma: no cover - stub
        raise NotImplementedError("STUB: generate_ecm observe not implemented on main")

    def rollback(self, ctx, rollback_state, ws, session) -> None:  # pragma: no cover - stub
        raise NotImplementedError("STUB: generate_ecm rollback not implemented on main")


class _StubShrinkToMvm(Operation):
    name = "shrink_to_mvm"
    params_model = _StubParams
    is_idempotent = False
    produces_version = True

    def dispatch(self, ctx, ws, session) -> OperationDispatchHandle:  # pragma: no cover - stub
        raise NotImplementedError("STUB: shrink_to_mvm dispatch not implemented on main")

    def observe(self, handle, ctx, ws, session) -> OperationObservation:  # pragma: no cover - stub
        raise NotImplementedError("STUB: shrink_to_mvm observe not implemented on main")

    def rollback(self, ctx, rollback_state, ws, session) -> None:  # pragma: no cover - stub
        raise NotImplementedError("STUB: shrink_to_mvm rollback not implemented on main")


class _StubEnlargeToEcm(Operation):
    name = "enlarge_to_ecm"
    params_model = _StubParams
    is_idempotent = False
    produces_version = True

    def dispatch(self, ctx, ws, session) -> OperationDispatchHandle:  # pragma: no cover - stub
        raise NotImplementedError("STUB: enlarge_to_ecm dispatch not implemented on main")

    def observe(self, handle, ctx, ws, session) -> OperationObservation:  # pragma: no cover - stub
        raise NotImplementedError("STUB: enlarge_to_ecm observe not implemented on main")

    def rollback(self, ctx, rollback_state, ws, session) -> None:  # pragma: no cover - stub
        raise NotImplementedError("STUB: enlarge_to_ecm rollback not implemented on main")


_REAL_MODULE_PATHS = {
    "generate_ecm": "vibe_modeling.backend.services.operations.generate_ecm",
    "shrink_to_mvm": "vibe_modeling.backend.services.operations.shrink_to_mvm",
    "enlarge_to_ecm": "vibe_modeling.backend.services.operations.enlarge_to_ecm",
}

_STUB_CLASSES = {
    "generate_ecm": _StubGenerateEcm,
    "shrink_to_mvm": _StubShrinkToMvm,
    "enlarge_to_ecm": _StubEnlargeToEcm,
}

_REAL_CLASS_NAMES = {
    "generate_ecm": ("GenerateEcm", "GenerateECM"),
    "shrink_to_mvm": ("ShrinkToMvm", "ShrinkToMVM"),
    "enlarge_to_ecm": ("EnlargeToEcm", "EnlargeToECM"),
}

_REAL_PARAMS_NAMES = {
    "generate_ecm": ("GenerateEcmParams", "GenerateECMParams"),
    "shrink_to_mvm": ("ShrinkToMvmParams", "ShrinkToMVMParams"),
    "enlarge_to_ecm": ("EnlargeToEcmParams", "EnlargeToECMParams"),
}


def load_primitive(name: str) -> tuple[Any, type[BaseModel]]:
    """Return ``(operation_instance, params_model)`` for ``name``.

    Looks up the real module under
    ``vibe_modeling.backend.services.operations.{name}``. Raises
    ``ModuleNotFoundError`` (subclass of ``ImportError``) when the
    module is absent — this is the expected state on ``main`` until the
    dev agent's branch lands, and produces the FAIL-on-main signal the
    Skeptical Tester Pattern requires.

    The stub classes above remain in this file for documentation and
    future fallback use — they record the minimum surface the real
    implementation must expose at integration time.
    """
    if name not in _REAL_MODULE_PATHS:
        raise KeyError(f"Unknown primitive: {name!r}")
    module_path = _REAL_MODULE_PATHS[name]
    mod = importlib.import_module(module_path)

    op = None
    for cls_name in _REAL_CLASS_NAMES[name]:
        cls = getattr(mod, cls_name, None)
        if cls is not None:
            op = cls()
            break
    if op is None:
        raise ImportError(
            f"Module {module_path!r} loaded but does not expose any of "
            f"{_REAL_CLASS_NAMES[name]!r}"
        )

    params_model = None
    for params_name in _REAL_PARAMS_NAMES[name]:
        candidate = getattr(mod, params_name, None)
        if candidate is not None:
            params_model = candidate
            break
    if params_model is None:
        params_model = op.params_model
    return op, params_model
