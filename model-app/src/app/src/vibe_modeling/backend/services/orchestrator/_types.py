"""Shared value types for the orchestrator service.

Currently exposes the validation :class:`Issue` type (see
``docs/orchestrator-design.md`` §2.4). The ``Dag`` and ``Orchestrator``
types come from a separate Phase 1 slice and will be added there.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Literal

Severity = Literal["warning", "blocker"]


@dataclass(frozen=True, slots=True)
class Issue:
    """A single validation finding raised against a DAG or one of its
    :class:`OperationStep`s.

    ``blocker`` issues reject ``POST /runs`` with HTTP 400. ``warning``
    issues are echoed back to the UI so it can render a "Submit anyway"
    confirmation; the run is still created. See §2.4 of the design doc for
    the full validation flow.
    """

    field_path: str
    """Dotted path to the offending field, e.g. ``"deployment_catalog"``
    or ``"params.schema_prefix"``. ``""`` when the issue is not bound to
    a specific field."""

    step_index: int
    """Index of the ``OperationStep`` that raised this issue. ``-1`` for
    DAG-level findings that span multiple steps."""

    message: str
    """Human-readable description rendered inline in the form."""

    severity: Severity
    """``"warning"`` or ``"blocker"``."""
