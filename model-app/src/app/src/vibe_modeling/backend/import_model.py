"""Import a previously-vibed model from a Volume path into Lakebase.

Reads a model.json from a Databricks Volume, validates the schema against
known agent-version fingerprints, and inserts a new ModelVersion record with
deployment_status='draft' (user runs the install operation manually to push
to UC).

Research on 2026-04-19 confirmed the agent's model.json schema is
byte-identical across v0.3.x, v0.4.x, and v0.5.x — all three versions'
notebooks emit the same data_model structure. So detection is simplified:
we check that the file looks like a vibe-modeling-agent model.json at all,
rather than trying to distinguish versions from content.
"""

from __future__ import annotations

import io
import json
import logging
import re
from dataclasses import asdict, dataclass, field
from typing import Optional

from databricks.sdk import WorkspaceClient

from .fk import is_fk_attribute

logger = logging.getLogger(__name__)


# Required fields at each level for a model.json to be accepted.
# These come from byte-identical analysis of the v0.3.9, v0.4.3, v0.5.2
# notebook model.json writer code.
REQUIRED_MODEL_FIELDS = {"type", "name", "version", "description"}
REQUIRED_DOMAIN_FIELDS = {"name", "products"}
REQUIRED_PRODUCT_FIELDS = {"name"}


@dataclass
class ImportAnalysis:
    """Result of analyzing a model.json before actually importing."""
    valid: bool
    inferred_version: str  # "modern" (v0.3+) | "unknown"
    action: str  # "import_as_is" | "unsupported"
    message: str
    domain_count: int = 0
    product_count: int = 0
    attribute_count: int = 0
    fk_count: int = 0
    warnings: list[str] = field(default_factory=list)
    # The unwrapped `model` dict, ready for ModelSyncService.sync_from_model_json.
    # Omitted from the JSON response (transport field only).
    _model: Optional[dict] = None

    def to_dict(self) -> dict:
        d = asdict(self)
        d.pop("_model", None)
        return d


def detect_schema(model_json: dict) -> ImportAnalysis:
    """Heuristically validate that model_json looks like a vibe-modeling-agent output.

    The `model` block is wrapped under `{"model_requirements": ..., "_vibe_session_metadata": ..., "model": {...}}`
    in agent exports, but some older or manual exports pass the model directly.
    Handle both.

    Returns an ImportAnalysis with `valid=False` and `action="unsupported"` if the
    schema doesn't match known fingerprints.
    """
    # Unwrap the three-key root if present
    if "model" in model_json and isinstance(model_json["model"], dict):
        model = model_json["model"]
    else:
        model = model_json

    warnings: list[str] = []

    # Required top-level fields
    missing = REQUIRED_MODEL_FIELDS - set(model.keys())
    if missing:
        return ImportAnalysis(
            valid=False,
            inferred_version="unknown",
            action="unsupported",
            message=(
                f"model.json missing required fields: {sorted(missing)}. "
                f"Expected a vibe-modeling-agent export with keys: "
                f"{sorted(REQUIRED_MODEL_FIELDS)}. Future versions may support more "
                f"schemas; for now, please re-export from a v0.3+ agent."
            ),
        )

    # v0.3+ marker: type must be "business"
    if model.get("type") != "business":
        return ImportAnalysis(
            valid=False,
            inferred_version="unknown",
            action="unsupported",
            message=(
                f"model.json has type={model.get('type')!r}; expected 'business'. "
                f"This doesn't look like a vibe-modeling-agent export."
            ),
        )

    # v0.3+ marker: version matches v<N>_<mvm|ecm>
    if not re.match(r"^v\d+_(mvm|ecm)$", str(model.get("version", ""))):
        warnings.append(
            f"model.version={model.get('version')!r} doesn't match the v<N>_<mvm|ecm> "
            f"pattern; importing anyway"
        )

    # Domain-level structure sanity check
    domains = model.get("domains", [])
    if not isinstance(domains, list):
        return ImportAnalysis(
            valid=False,
            inferred_version="unknown",
            action="unsupported",
            message="model.domains must be a list",
        )

    domain_count = 0
    product_count = 0
    attribute_count = 0
    fk_count = 0

    for d in domains:
        if not isinstance(d, dict):
            warnings.append("skipping non-dict domain entry")
            continue
        domain_count += 1
        missing_d = REQUIRED_DOMAIN_FIELDS - set(d.keys())
        if missing_d:
            warnings.append(f"domain {d.get('name', '?')!r} missing {sorted(missing_d)}")
        for p in d.get("products", []) or []:
            if not isinstance(p, dict):
                continue
            product_count += 1
            missing_p = REQUIRED_PRODUCT_FIELDS - set(p.keys())
            if missing_p:
                warnings.append(
                    f"product in {d.get('name', '?')!r} missing {sorted(missing_p)}"
                )
            for a in p.get("attributes", []) or []:
                if not isinstance(a, dict):
                    continue
                attribute_count += 1
                if is_fk_attribute(a):
                    fk_count += 1

    if domain_count == 0:
        warnings.append("model has no domains — import will produce an empty version")

    # Surface the release/schema version in the success message when the file
    # carries one (top-level on the envelope). From v0.8.0 the git release tag
    # lives in ``release_version`` (``agent_version`` became an independent
    # agent-logic counter), so prefer it and fall back to ``agent_version``
    # for pre-v0.8.0 exports. Normalize to a leading ``v``.
    version_str = str(
        model_json.get("release_version") or model_json.get("agent_version") or ""
    ).strip()
    if version_str:
        label = version_str if version_str.startswith("v") else f"v{version_str}"
        message = f"Schema ({label}) is supported for importing."
    else:
        message = "Schema is supported for importing."

    return ImportAnalysis(
        valid=True,
        inferred_version="modern",  # v0.3+ all share the same schema
        action="import_as_is",
        message=message,
        domain_count=domain_count,
        product_count=product_count,
        attribute_count=attribute_count,
        fk_count=fk_count,
        warnings=warnings,
        _model=model,
    )


def read_model_json_from_volume(ws: WorkspaceClient, volume_path: str) -> dict:
    """Download a model.json from a UC Volume path via the Files API.

    Raises ValueError if the path is invalid or the file is not valid JSON.
    """
    if not volume_path.startswith("/Volumes/"):
        raise ValueError(
            f"Volume path must start with /Volumes/; got: {volume_path!r}"
        )

    try:
        resp = ws.files.download(volume_path)
    except Exception as e:
        raise ValueError(f"Could not read {volume_path}: {e}") from e

    # Read the streaming body
    try:
        data = resp.contents.read()
    except AttributeError:
        # Some SDK versions return a different shape — fallback
        data = getattr(resp, "contents", b"")
    if isinstance(data, (bytes, bytearray)):
        text = data.decode("utf-8")
    else:
        text = str(data)

    try:
        return json.loads(text)
    except json.JSONDecodeError as e:
        raise ValueError(
            f"{volume_path} is not valid JSON: {e}. "
            f"The import endpoint expects a model.json file produced by the vibe agent."
        ) from e
