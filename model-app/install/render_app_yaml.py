"""Substitute install-time values into ``src/app/app.yml`` env vars.

Driven by ``install/install.sh`` so a single CLI invocation produces an
``app.yml`` whose env block matches what was provisioned in Lakebase. The
matched env names are exactly the ones the app reads via
``DatabaseConfig`` and ``AppConfig`` (see ``backend/core/lakebase.py`` and
``backend/core/_config.py``):

  - ``VIBE_MODELING_LAKEBASE_PROJECT``    (Lakebase project id)
  - ``VIBE_MODELING_DATABASE_NAME``       (Postgres database name)
  - ``VIBE_MODELING_DEPLOYMENT_CATALOG``  (UC catalog seeded into AgentConfig)
  - ``VIBE_MODELING_WAREHOUSE_ID``        (SQL warehouse id, optional)

The render is line-oriented (no full YAML parser): for each known env
``name`` we rewrite the next ``value:`` line. Unrelated content — comments,
ordering, the ``command`` block, other env entries — is preserved verbatim.
Idempotent: re-running with the same inputs produces the same output.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

# Targets we know how to rewrite. Order is irrelevant; the rewriter
# matches each independently.
ENV_TARGETS = (
    "VIBE_MODELING_LAKEBASE_PROJECT",
    "VIBE_MODELING_DATABASE_NAME",
    "VIBE_MODELING_DEPLOYMENT_CATALOG",
    "VIBE_MODELING_WAREHOUSE_ID",
)


# Line patterns we look for. We match the canonical apx app.yml shape:
#
#   - name: VIBE_MODELING_LAKEBASE_PROJECT
#     value: "vibe-modeling"
#
# both the bullet form and inline form. The value line must immediately
# follow the name line (with optional blank/comment lines between).
_NAME_RE = re.compile(r'^(\s*-?\s*name:\s*)(\S+)\s*$')
_VALUE_RE = re.compile(r'^(\s*value:\s*)(.*)$')


def render(source: str, values: dict[str, str]) -> str:
    """Return ``source`` with the value of each env var in ``values`` rewritten."""
    lines = source.splitlines(keepends=True)
    out: list[str] = []
    pending_target: str | None = None
    for line in lines:
        if pending_target is not None:
            value_match = _VALUE_RE.match(line.rstrip("\n").rstrip("\r"))
            if value_match:
                indent = value_match.group(1)
                eol = line[len(line.rstrip("\r\n")):]  # preserve \n / \r\n
                replacement = values[pending_target]
                out.append(f'{indent}"{replacement}"{eol}')
                pending_target = None
                continue
            # Anything that isn't a `value:` line clears the pending state
            # so we don't mis-attribute a later value: line. The original
            # line passes through unchanged.
            pending_target = None

        name_match = _NAME_RE.match(line.rstrip("\n").rstrip("\r"))
        if name_match and name_match.group(2) in values:
            pending_target = name_match.group(2)
        out.append(line)

    return "".join(out)


def _parse_args(argv: list[str]) -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--in", dest="input", required=True, help="Path to source app.yml")
    p.add_argument("--out", dest="output", required=True, help="Path to write rendered app.yml")
    p.add_argument("--project", required=True, help="Lakebase project id")
    p.add_argument("--database", required=True, help="Postgres database name")
    p.add_argument(
        "--deployment-catalog",
        required=True,
        help="UC catalog the agent uses for _metamodel; seeds AgentConfig on first boot",
    )
    p.add_argument(
        "--warehouse-id",
        default="",
        help="SQL warehouse id (optional; empty leaves the user to configure via UI)",
    )
    return p.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = _parse_args(argv if argv is not None else sys.argv[1:])
    source = Path(args.input).read_text()
    values = {
        "VIBE_MODELING_LAKEBASE_PROJECT": args.project,
        "VIBE_MODELING_DATABASE_NAME": args.database,
        "VIBE_MODELING_DEPLOYMENT_CATALOG": args.deployment_catalog,
        "VIBE_MODELING_WAREHOUSE_ID": args.warehouse_id,
    }
    rendered = render(source, values)

    rewritten_targets = [k for k in ENV_TARGETS if f"name: {k}" in source]
    missing = [k for k in rewritten_targets if f'value: "{values[k]}"' not in rendered]
    if missing:
        print(
            f"ERROR: render_app_yaml could not rewrite {missing} — "
            f"app.yml shape changed?",
            file=sys.stderr,
        )
        return 1

    Path(args.output).write_text(rendered)
    return 0


if __name__ == "__main__":
    sys.exit(main())
