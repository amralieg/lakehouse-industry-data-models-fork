# Model App

AI-assisted data modeling app for Databricks; part of the Databricks industry
data models initiative. It is a Databricks App control plane (React + FastAPI)
for generating, iterating on, and deploying business data models to Unity
Catalog.

## Installing in your workspace

See **[INSTALL.md](INSTALL.md)** for end-to-end install instructions on any
Databricks workspace (AWS or Azure). High-level flow:

```bash
# From this directory (model-app/), on a pre-authenticated CLI profile:
bash install/install.sh \
  --profile      <your-profile> \
  --app-name     vibe-modeling  \
  --project      vibe-modeling  \
  --catalog      vibe_modeling  \
  --warehouse-id <sql-warehouse-id>
```

The installer deploys the bundle, provisions Lakebase, grants the Unity Catalog
privileges the app needs, starts the app, and pushes the built source. It is
idempotent. Lakebase is generally available on both AWS and Azure, so no preview
enrollment is needed.

By default every user granted Databricks Apps access is treated as an app admin;
set `VIBE_MODELING_RBAC_ENABLED=true` for group-based roles. See the
[Access model](INSTALL.md#access-model) section of INSTALL.md.

## What's here

| Path | Description |
|------|-------------|
| `src/app/` | The Databricks App: React + FastAPI control plane, built with [`apx`](https://github.com/databricks-solutions/apx) |
| `src/app/src/vibe_modeling/backend/` | FastAPI backend (routes, run orchestration, model export, Unity Catalog integration) |
| `src/app/src/vibe_modeling/ui/` | React + TypeScript frontend and its `__tests__` |
| `src/app/vendored/agent/` | The bundled modeling agent notebook (`VERSIONS.json` + notebook), uploaded to the workspace on first boot |
| `install/` | Installer scripts (`install.sh`, Lakebase provisioning, catalog grants, build/render) |
| `examples/` | Example model outputs (NCDOT) and a business context input (`examples/maf.json`) |
| `tests/test_app/` | App backend test suite (no Spark or workspace required) |
| `databricks.yml`, `src/app/app.yml` | Databricks Asset Bundle and App configuration |

## How it works

The app drives a two-step, LLM-driven modeling process through a bundled agent
notebook:

**Step 1 - Base model (v0, the seed):** the modeler provides a business context
file (like `examples/maf.json`) with business info, model conventions, and
optional vibe instructions. The system decomposes along a fixed path:
Organization -> 3 Divisions (Operations, Business, Corporate) -> Domains ->
Products (tables) -> Attributes (columns). It links tables (in-domain first,
then cross-domain pairwise), enforces a DAG constraint on FK relationships, runs
quality checks, deploys to Unity Catalog, and produces a self-assessment with a
confidence score and recommendations.

**Step 2 - Vibe modeling (v1, v2, v3...):** the modeler writes natural-language
instructions ("Add a loyalty domain", "Rename mobile_number to msisdn
everywhere"). The system classifies intent into one of three modes - **surgical**
(fix specific things, leave the rest alone), **holistic** (apply a rule
everywhere, preserve structure), or **generative** (create or rebuild parts) -
then executes changes through specialized workers and re-validates through the
same quality pipeline.

Each version is a complete, deployable snapshot; no version is overwritten. The
model also generates an RDFS ontology alongside the physical schema.

## Local development

The app is built with [`apx`](https://github.com/databricks-solutions/apx)
(Python + FastAPI backend, React + shadcn/ui frontend). See
[CONTRIBUTING.md](CONTRIBUTING.md) for setup and the checks a change must pass.

```bash
# Backend tests (from this directory)
pytest tests/test_app

# Frontend type-check and unit tests (from src/app)
cd src/app
npx tsc --noEmit
npx vitest run
```

## Publishing to GitHub (optional)

The app can publish a model version to a GitHub repository as a pull request.
This is optional and off by default. See
[docs/github-integration-setup.md](docs/github-integration-setup.md) and the
"Enabling publish-to-GitHub" section of [INSTALL.md](INSTALL.md).

## Related

- **Industry models repository**: [databricks-industry-solutions/lakehouse-industry-data-models](https://github.com/databricks-industry-solutions/lakehouse-industry-data-models)
  - reference industry data models for customers, deployable via Databricks
  Asset Bundles. Models there may be generated and maintained with this app, but
  it is an independent resource.
- **Excel template**: a standardized spreadsheet that auto-generates README,
  JSON, DDL statements, tags, comments, and ontology - a primary input format
  for contributing industry models.

## Why data models

Well-structured data models reduce token usage and increase accuracy in
AI-generated responses: a data model gives an AI system the schema, relationships,
and semantics it would otherwise have to infer. This app makes building and
iterating on those models fast, so teams can build cheaper and more trustworthy
AI on top of well-modeled data - or generate a starting model from business
context.
