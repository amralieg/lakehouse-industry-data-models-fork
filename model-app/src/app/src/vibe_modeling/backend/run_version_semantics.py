"""Per-intent semantics for the agent's `model_version` widget.

The agent overloads a single widget with two different meanings depending on
the operation:

- ``new-base-model``  — widget is the OUTPUT version (always "v1").
- ``vibe-iterate``, ``vibe-new-ecm-mvm`` — widget is the INPUT (base)
  version; the agent writes the NEXT integer (e.g. v3 -> v4).
- ``install``, ``uninstall``, ``generate-samples`` — widget is the version
  being acted on (neither input nor output in the model-producing sense).

Reading the widget as the "version we just produced" silently reuses the base's
model data under the new version's row, which masquerades as a successful run
but leaves the two versions byte-identical in Lakebase. This module pins the
correct interpretation in one place so new call sites don't re-derive it.
"""

from typing import Optional

from .models import Intent


# Intents that produce a new ModelVersion artifact via the agent's
# VibeWriter (the runtime equivalent of the legacy
# ``MODEL_PRODUCING_OPS`` set).
MODEL_PRODUCING_INTENTS: frozenset[str] = frozenset({
    Intent.NEW_BASE_MODEL.value,
    Intent.VIBE_ITERATE.value,
    Intent.VIBE_NEW_ECM_MVM.value,
})


def parse_version(value) -> Optional[int]:
    """Parse "v3" / "3" / 3 into 3. Return None for empty / invalid."""
    if value is None:
        return None
    if isinstance(value, int):
        return value
    s = str(value).strip()
    if not s:
        return None
    if s[0] in ("v", "V"):
        s = s[1:]
    try:
        return int(s)
    except ValueError:
        return None


def input_version_for(intent: str, params: dict) -> Optional[int]:
    """Integer version the run reads FROM. None if no input version applies.

    ``new-base-model`` has no input — the agent starts fresh. Every other
    model-producing intent uses ``params["model_version"]`` as the base
    pointer. For lifecycle intents the widget still carries the target
    version (install / uninstall / samples act on an existing one), so we
    surface that.
    """
    if intent == Intent.NEW_BASE_MODEL.value:
        return None
    return parse_version(params.get("model_version"))


def output_version_for(
    intent: str,
    params: dict,
    *,
    new_version_num: Optional[int] = None,
) -> Optional[int]:
    """Integer version the run writes TO. None for non-model-producing intents.

    For ``new-base-model`` the widget already carries the output ("v1"). For
    vibe intents the widget carries the BASE, so the caller must pass
    ``new_version_num`` (what the app just allocated for the new
    ModelVersion). Lifecycle intents return None — they don't produce a new
    version.
    """
    if intent not in MODEL_PRODUCING_INTENTS:
        return None
    if intent == Intent.NEW_BASE_MODEL.value:
        return parse_version(params.get("model_version")) or 1
    return new_version_num
