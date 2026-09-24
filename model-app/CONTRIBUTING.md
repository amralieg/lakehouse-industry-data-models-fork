# Contributing to model-app

`model-app` is a component of the Databricks industry data models initiative
(the `databricks-industry-solutions/lakehouse-industry-data-models` repository).
It is a Databricks App control plane for AI-assisted data modeling. Third-party
pull requests are welcome as a secondary use case; the primary maintainers are
the Databricks industry-solutions team.

## Local setup

The app is a Python + FastAPI backend with a React + TypeScript frontend, built
with [`apx`](https://github.com/databricks-solutions/apx).

Prerequisites:

- **Python 3.11** (a virtualenv via `pyenv`, `venv`, or `uv` is fine)
- **[uv](https://github.com/astral-sh/uv)** for Python dependency management
- **[Bun](https://bun.sh) 1.2+** for the frontend
- **[apx](https://github.com/databricks-solutions/apx)** to drive the dev loop and build

Install dependencies:

```bash
# Backend (from the repo root, or wherever your venv lives)
python -m pip install 'databricks-sdk>=0.74' 'psycopg[binary]' fastapi uvicorn pydantic-settings sqlmodel

# Frontend (from src/app)
cd src/app
bun install
```

The public tree pins the public npm registry (`registry.npmjs.org`) in
`src/app/bunfig.toml`. If your organization uses an internal npm proxy or
registry, repoint `src/app/bunfig.toml` to it and re-resolve `bun.lock`
(`bun install`) before building.

## Running the checks

These checks run without a Databricks workspace and are the bar for a PR:

```bash
# Python backend tests (from the repo root)
pytest tests/test_app

# Frontend type-check and unit tests (from src/app)
cd src/app
npx tsc --noEmit
npx vitest run
```

`apx dev check` runs the type/lint checks across both stacks if you have apx
installed.

## Pull request conventions

- Keep each PR focused on one change; describe what and why in the description.
- Match the surrounding code's style and conventions. Add or update tests for
  behavior you change.
- Ensure the checks above pass before requesting review.
- Note any change that affects install, configuration, or the public API surface.

## Contributor License Agreement

By submitting a contribution you certify that you have the right to submit it,
that you grant the project a license to use it under the repository's license,
and that it contains no confidential or proprietary information. Opening a pull
request is taken as acceptance of these terms.
