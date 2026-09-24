# Installing Vibe Data Modeling

Install the Vibe Data Modeling app on a Databricks workspace (AWS or Azure). End-to-end time: **~10 minutes**.

The canonical install path is [`install/install.sh`](install/install.sh) — it runs `bundle deploy`, provisions Lakebase, grants Unity Catalog privileges, starts the app, and pushes the built source. Idempotent — safe to re-run.

## TL;DR — copy-paste install

Once the prerequisites below are in place:

```bash
git clone https://github.com/databricks-industry-solutions/lakehouse-industry-data-models.git
cd lakehouse-industry-data-models/model-app

bash install/install.sh \
  --profile        my-workspace      \
  --app-name       vibe-modeling     \
  --project        vibe-modeling     \
  --catalog        vibe_modeling     \
  --warehouse-id   <sql-warehouse-id>
```

Substitute your CLI profile name and SQL warehouse ID. Total wall-clock: ~10 minutes on a fresh workspace. Skip `--warehouse-id` to configure it later via the first-run UI.

The five parameters above are the complete CLI surface of `install/install.sh`. Detailed semantics are in [Parameter reference](#parameter-reference) below.

## Privileges required

Pick **one** of the two paths below.

### Path A: Workspace Admin (simplest)

Workspace Admin on the target workspace covers every grant the installer needs by default. No extra setup. **Recommended for first installs.**

### Path B: Non-admin grant matrix

If you install as a non-admin identity, you need **all** of the following on the target workspace:

- **Create Databricks Apps** — [AWS](https://docs.databricks.com/aws/en/dev-tools/databricks-apps/get-started) · [Azure](https://learn.microsoft.com/en-us/azure/databricks/dev-tools/databricks-apps/get-started)
- **Create Lakebase Postgres projects** — [AWS](https://docs.databricks.com/aws/en/oltp/projects/get-started) · [Azure](https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/get-started)
- **Deploy Databricks Asset Bundles** to your `/Workspace/Users/<you>` tree — [AWS](https://docs.databricks.com/aws/en/dev-tools/bundles/) · [Azure](https://learn.microsoft.com/en-us/azure/databricks/dev-tools/bundles/)
- **Grant authority on the target Unity Catalog** — `install/install.sh` issues these grants automatically to the new App service principal:
  - `USE CATALOG`, `CREATE SCHEMA`, `BROWSE` on the catalog passed via `--catalog`
    (`BROWSE` is required by the agent's `_create_metrics_database_if_needed` step,
    which probes whether the `_metrics` schema already exists by reading catalog
    metadata)
  - If `_metamodel` already exists in that catalog (re-install case): `USE SCHEMA`, `CREATE TABLE`, `MODIFY`, `SELECT`, `READ VOLUME`, `WRITE VOLUME` at the schema level (the `*_VOLUME` privileges cascade to current and future volumes)

  To issue those, the installer's identity needs one of: **catalog ownership**, **`MANAGE` on the catalog**, or **metastore-admin**.
- **Permission to create UC catalogs** if `--catalog` points at one that doesn't exist yet — [AWS](https://docs.databricks.com/aws/en/catalogs/create-catalog) · [Azure](https://learn.microsoft.com/en-us/azure/databricks/catalogs/create-catalog).

If your identity lacks grant authority on the catalog, `install/install.sh` **logs the equivalent SQL to stdout and continues** — the install finishes, but a privileged user must run those `GRANT` statements before the app can list catalogs in the New Run picker. See [App SP catalog privileges](#app-sp-catalog-privileges) below for the canonical SQL.

## Prerequisites

### On your machine

| Tool | Min version | Purpose |
|------|-------------|---------|
| **Databricks CLI** | 0.230.0 | Bundle deploy, app lifecycle, current-user lookup — [install](https://docs.databricks.com/aws/en/dev-tools/cli/install) |
| **Python** | 3.11 | Runs `provision_lakebase.py` and `grant_catalog.py` |
| **apx** | — | Builds the app artifacts (`apx build`, driven by the bundle artifacts hook); orchestrates bun + uv |
| **Bun** | 1.2 | Frontend build (via `apx build`) |
| **uv** | — | Python build for the wheel artifact (via `apx build`) |
| **jq** | — | `install.sh` parses CLI JSON output (SP UUID, current user, app status) |
| **git** | — | Clone the repo |

`install.sh` aborts at step `[0/5]` if any of `databricks`, `python`, `jq`, `apx`, `uv`, or `bun` is missing from PATH.

Install the Python packages the install scripts import:

```bash
python -m pip install 'databricks-sdk>=0.61' 'psycopg[binary]'
```

`install.sh` fail-fasts at step 0 if `databricks-sdk` is not importable in the active Python env.

### SQL warehouse

The app polls Delta tables (`_business`, `_vibe_progress`) for run progress through a SQL warehouse. **Provision a SQL warehouse before installing**, then either:

- Pass its ID via `--warehouse-id` to `install.sh`, which exports `VIBE_MODELING_WAREHOUSE_ID` so the artifacts hook bakes it into `src/app/.build/app.yml`, **or**
- Skip `--warehouse-id` at install time and pick the warehouse from the dropdown on the app's first-run Settings page.

Serverless SQL warehouses are recommended — the app issues short, frequent statements and benefits from cold-start avoidance.

### Cloud and workspace

- **Lakebase is generally available on both AWS and Azure.** No preview enrollment required.
- The modeling agent notebook is **bundled inside the app wheel** (`src/app/vendored/agent/`, shipped in this repo). The app uploads it to `/Users/<app-sp>/vibe-modelling-agent/` on first boot via its FastAPI lifespan hook (`backend/core/_bundled_agent_init.py`) and creates the persistent Databricks Job. The first-run UI exposes an **Install bundled agent notebook** button as a one-click reinstall if you ever need it. No manual notebook import.

> **Metastores that use Default Storage:** if the target metastore uses Default Storage (no metastore-level storage root), the installer cannot create the UC catalog via API/CLI — catalog creation there is UI-only and requires metastore-admin rights. Create the catalog through the workspace UI (or ask a workspace/metastore admin) with the same name as your `--catalog` value (default `vibe_modeling`), in the same region as the workspace, then re-run the installer or `python install/grant_catalog.py --profile <p> --catalog <name> --app-sp <sp>` to apply the grants. The app boots and is healthy without the catalog; only **model-producing runs** (which write `_metamodel.*` into it) require it.

## Parameter reference

All flags below are accepted by [`install/install.sh`](install/install.sh). The order matches the script's `usage` block.

| Flag | Required | Default | What it controls | When to override |
|------|----------|---------|------------------|------------------|
| `--profile <name>` | **yes** | — | Databricks CLI profile name (must be pre-authenticated with `databricks auth login --profile <name>`). Drives every `databricks` CLI call inside `install.sh`. | Always — pick the profile pointing at your target workspace. |
| `--app-name <name>` | no | `vibe-modeling` | Databricks App resource name shown in the workspace **Apps** UI. The bundle deploys the App under this name; the App's service principal is bound to this name's lifecycle. | Use a suffix (e.g. `vibe-modeling-staging`) to run multiple installs on the same workspace. Note: the bundle storage path under `/Workspace/Users/<you>/.bundle/vibe-modeling/...` is always `vibe-modeling` (bundle name is fixed), so two co-existing installs share the same source path — fine for renames, not for true parallel installs. |
| `--project <id>` | no | `vibe-modeling` | Lakebase project ID. Must be unique in the workspace. The installer creates the project, its compute endpoint, and a database whose name matches `--catalog`. | If the default name is taken (or recently deleted — the name is locked for ~2 hours after delete), pick another. By convention, match `--app-name` for easier ops debugging. |
| `--catalog <name>` | no | `vibe_modeling` | Unity Catalog name AND Postgres database name. Underscores, not hyphens. The app uses this catalog for the agent's `_metamodel.*` artifacts (Delta tables, the `vol_root` volume) and the same name for its Lakebase Postgres state DB. The installer creates the catalog if absent (**not possible on a metastore that uses Default Storage** — create the catalog via the workspace UI first, see the note under [Cloud and workspace](#cloud-and-workspace)), grants the App SP `USE CATALOG` + `CREATE SCHEMA`, and (on re-install over an existing `_metamodel` schema) issues the schema-level grants listed in [App SP catalog privileges](#app-sp-catalog-privileges). | Override if your workspace governance reserves catalog naming, or if you want a non-default isolation domain for the agent's artifacts. |
| `--warehouse-id <id>` | no | _(unset)_ | SQL warehouse ID the app uses for Delta polling during vibe runs. Pre-populates `VIBE_MODELING_WAREHOUSE_ID`; the artifacts hook bakes it into `src/app/.build/app.yml`. | Pass at install time to skip the first-run UI configuration. Omit to choose interactively from the Settings page after the app boots. |
| `-h`, `--help` | no | — | Print the usage block and exit. | — |

`install/install.sh` propagates the install-time values via `VIBE_MODELING_LAKEBASE_PROJECT`, `VIBE_MODELING_DATABASE_NAME`, `VIBE_MODELING_DEPLOYMENT_CATALOG`, and `VIBE_MODELING_WAREHOUSE_ID` before running `databricks bundle deploy`. The bundle's `artifacts.default.build` hook (`install/build_and_render.sh`) renders those values into `src/app/.build/app.yml` during the build. The checked-in source `src/app/app.yml` is **never modified**. No manual file edits.

## Pre-install: authenticate the CLI

```bash
databricks auth login --host https://<your-workspace>.cloud.databricks.com --profile my-workspace
databricks current-user me --profile my-workspace   # confirm
```

The profile name you pass to `databricks auth login` is the same name you pass to `install.sh --profile`.

## Run the installer

```bash
bash install/install.sh --profile my-workspace
```

> Run repo scripts with a `bash <script>` prefix as shown — a fresh checkout may not carry the executable bit, so invoking `./install.sh` directly can fail with "permission denied". To run a script directly instead, `chmod +x` it first.

The five-phase script prints `[N/5]` markers and stops on the first failure:

1. `[0/5]` Verify the CLI profile and prerequisites: critical tools (`databricks`, `python`, `jq`, `apx`, `uv`, `bun`) and Python packages (`databricks-sdk`, `psycopg`) must be present or the script aborts; `databricks` CLI and `python` below their minimum versions warn but do not block.
2. `[1/5]` `databricks bundle deploy` — creates the App resource and its service principal.
3. `[2/5]` `python install/provision_lakebase.py` — Lakebase project, endpoint, database, role grants.
4. `[3/5]` `python install/grant_catalog.py` — UC privileges for the App SP (best-effort, logs SQL on permission failure).
5. `[4/5]` Start app compute, wait for `ACTIVE`.
6. `[5/5]` `databricks apps deploy` from `src/app/.build`, wait for `RUNNING`.

After `[5/5]`, install.sh runs a warn-only `[verify]` block (homepage `200`, `/api/industries` == 40, the catalog exists in Unity Catalog). These are eventually-consistent and best-effort, so a gap warns rather than fails. The final block prints the App URL, Lakebase project, UC catalog, database, warehouse, and SP — copy this for later reference.

## App SP catalog privileges

The app's service principal (SP) needs to list the catalog, create schemas, and read/write the tables and volumes the agent produces. At step `[3/5]`, `install/install.sh` creates the catalog, the `_metamodel` schema, and its `vol_root` MANAGED volume if absent (the app's industry-download writes artifacts to `/Volumes/<catalog>/_metamodel/vol_root/...` before any vibe run, so they must exist at install time), then issues the grants below automatically. This section is what you (or someone with grant authority) needs to run **only if** that step logged a permission warning.

Find the SP client ID:

```bash
databricks apps get vibe-modeling --profile <your-profile> --output json | jq -r .service_principal_client_id
```

Then issue:

```sql
GRANT USE CATALOG, CREATE SCHEMA, BROWSE ON CATALOG <catalog> TO `<sp-client-id>`;
```

The installer also creates `_metamodel` + `vol_root` and grants the SP at the schema level (so it can write download artifacts before any vibe run). If you are issuing grants by hand, also run:

```sql
CREATE SCHEMA IF NOT EXISTS <catalog>._metamodel;
CREATE VOLUME IF NOT EXISTS <catalog>._metamodel.vol_root;
GRANT USE SCHEMA, CREATE TABLE, MODIFY, SELECT, READ VOLUME, WRITE VOLUME
  ON SCHEMA <catalog>._metamodel TO `<sp-client-id>`;
```

`READ VOLUME` and `WRITE VOLUME` cascade to current and future volumes in the schema (including `_metamodel.vol_root`), so no separate per-volume grant is required.

The agent also creates `_metamodel` + `vol_root` idempotently (`CREATE ... IF NOT EXISTS`) on its first vibe run, so pre-creating them at install time is safe.

The app enforces this at dispatch time: `_check_metamodel_schema_present` (router.py)
checks whether `<catalog>._metamodel` and its `vol_root` MANAGED volume exist before
accepting a run submission. If either is absent, the app returns HTTP 400:
`"Catalog '<catalog>' has no _metamodel schema. Run the installer's catalog setup
(install/grant_catalog.py)"`. Running `grant_catalog.py` creates both and is the
canonical fix.

Re-running the grants is idempotent:

```bash
python install/grant_catalog.py --profile <your-profile> --catalog <catalog> --app-sp <sp-uuid>
```

**Symptom if the SP lacks `USE CATALOG`:** the New Run form's *Deployment Catalog* picker shows "No catalogs match" even when the catalog exists. The app's `/api/catalogs` endpoint filters via `w.catalogs.list()`, which only returns catalogs the SP can `USE CATALOG` on.

**Redeploy note:** the App SP is tied to the App resource's lifetime, not to each deploy. A source-only push (`databricks apps deploy …`, install.sh step `[5/5]`) reuses the existing SP — no grant changes. The SP rotates only when you delete and recreate the App; re-running `install/install.sh` against the recreated app re-issues the grants automatically.

## Verify the install

Wait ~30 seconds after `install.sh` finishes (gives the FastAPI lifespan hook time to upload the bundled notebook and create the Job), then:

```bash
PROFILE=my-workspace
APP_NAME=vibe-modeling

TOKEN=$(databricks auth token --profile "$PROFILE" | jq -r .access_token)
APP_URL=$(databricks apps get "$APP_NAME" --profile "$PROFILE" --output json | jq -r .url)

# App status should be RUNNING:
databricks apps get "$APP_NAME" --profile "$PROFILE" --output json | jq -r '.app_status.state'

# Homepage returns 200:
curl -s -o /dev/null -w '%{http_code}\n' -H "Authorization: Bearer $TOKEN" "$APP_URL/"

# Industries were seeded (expect 40):
curl -s -H "Authorization: Bearer $TOKEN" "$APP_URL/api/industries" | jq 'length'

# Businesses list loads (empty on a fresh install):
curl -s -H "Authorization: Bearer $TOKEN" "$APP_URL/api/businesses" | jq
```

Expected:

- `app_status.state` → `"RUNNING"`
- `/` → HTTP `200`
- `/api/industries` → `40`
- `/api/businesses` → `[]`

If any check fails, see [Troubleshooting](#troubleshooting).

## Open the app

```bash
databricks apps get vibe-modeling --profile <your-profile> --output json | jq -r .url
```

The Settings page is pre-populated by the lifespan hook — the bundled agent notebook is uploaded, the persistent Databricks Job (`dbx_vibe_modelling`, tagged `managed_by=vibe_modeling_app`) is created, and the metamodel catalog matches your `--catalog` choice. You only need to touch Settings if you want to swap in a custom notebook or change the deployment catalog / warehouse.

## Access model

By default, every user granted Databricks Apps access to the app is treated as an app admin, with full access to settings, businesses, model versions, and runs. This is the expected behavior for the current 0.x releases.

Setting `VIBE_MODELING_RBAC_ENABLED=true` (an app environment variable) enables group-based roles resolved from workspace group membership:

- `vibe-app-admins` — full access, including settings and group management
- `vibe-business-admins` — manage businesses, approve syncs, manage model versions
- `vibe-modelers` — navigate, run vibes, provide feedback

With RBAC enabled, a user who is in none of these groups gets read-only access. Finer role separation is planned future work.

Because the default grants every app user admin rights, either scope Databricks Apps access to trusted users, or set `VIBE_MODELING_RBAC_ENABLED=true` and place users in the appropriate groups.

## Upgrading an existing deployment

A fresh install needs nothing beyond the steps above: the schema migrations run on first boot and there is no legacy data to migrate.

When upgrading a deployment that already holds data:

1. **Migration-bearing deploys go to a fresh Lakebase branch, not `production`** — deploy and verify there, then promote (see the Deployment Guide). The schema reconciles on boot.
2. **Run the one-time guidance backfill** once, after the app has booted (schema reconciled), to fold legacy feedback / next-vibe rows into Vibe Inputs. It is idempotent and exits non-zero unless `backfill_status` reaches `ok`:

   ```bash
   DATABRICKS_CONFIG_PROFILE=<profile> \
     VIBE_MODELING_LAKEBASE_PROJECT=<project> \
     VIBE_MODELING_DATABASE_NAME=<db> \
     VIBE_MODELING_LAKEBASE_BRANCH=<branch> \
     python -m vibe_modeling.backend.migrations.backfill_vibe_inputs
   ```

## Enabling publish-to-GitHub (optional)

The app can publish a model version to a GitHub repository as a pull request. This feature is **optional and off by default** - it is not needed for the core install, and browsing/importing the public industry-model repo does not use it (those reads are unauthenticated public HTTP).

Publish runs on behalf of the acting user through a Unity Catalog HTTP connection named `github_pr`. That connection uses per-user OAuth (U2M), which is interactive, so it **cannot be created by `install/install.sh`, Terraform, or SQL** - you create it once by hand in Catalog Explorer. Because the bundle's default (`dev`) target declares no app resources, a fresh install deploys cleanly on any workspace whether or not `github_pr` exists.

To enable publish on a workspace:

1. Create the `github_pr` UC HTTP connection and grant it, following [`docs/github-integration-setup.md`](docs/github-integration-setup.md) (register a GitHub OAuth app, create the connection, grant `USE CONNECTION`, enable OBO on the app).
2. Deploy with the `github-publish` bundle target so the app re-applies the `USE_CONNECTION` grant on `github_pr` each deploy:

   ```bash
   databricks bundle deploy --target github-publish --profile <your-profile> --var "app_name=<app-name>"
   databricks apps deploy <app-name> \
     --source-code-path "/Workspace/Users/<you>/.bundle/vibe-modeling/github-publish/files/src/app/.build" \
     --profile <your-profile>
   ```

   The grant is the only difference from the default target. The connection name is referenced by name (`github_pr`); the bundle resource key (`github_conn`) is cosmetic.
3. Configure the GitHub tab in the app's Settings (connection name, repo owner/name) per Step E of the integration guide.

If you skip this, the Publish action stays disabled and returns `422 github_connection_missing` until configured - everything else works.

## Troubleshooting

### Redeploy appears to run old code

Databricks Apps installs the app wheel by version and skips reinstalling an unchanged one. Bump `version` in `src/app/pyproject.toml` before redeploying so the wheel reinstalls — the deploy log should read `Successfully installed vibe-modeling-<new-version>`, not `Requirements have not changed. Skipping installation`.

### `refusing to (re-)install — N in-flight run(s) on ...`

The installer refuses to (re-)deploy while runs are active. Atomic-replace App containers can't hand off in-memory pollers cleanly — pushing a new wheel would silently orphan in-flight runs until the new container's lifespan re-attaches. Cancel the runs in the UI (or wait for them to finish), then re-run install. For emergencies, set `FORCE=1` before invoking `install.sh` (`FORCE=1 bash install/install.sh ...`) — affected runs will lose their pollers and may need recovery via UI cancel-and-resume.

### `permission denied for schema public` on app startup

Re-run `install/install.sh --profile <your-profile>`. The provision step re-applies Lakebase schema grants idempotently.

### `Cannot deploy app … as it is not in RUNNING state`

`install/install.sh` handles compute startup; you only hit this running the steps manually. Run `databricks apps start <app-name> --profile <profile>` and wait 15 seconds before re-deploying.

### `project with such id already exists`

A Lakebase project with that name already exists, or was recently deleted (project names are locked for ~2 hours after deletion). Re-run with `--project <other-id>`.

### `Lakebase Autoscaling connection validation failed`

The `VIBE_MODELING_LAKEBASE_PROJECT` env var rendered into `src/app/.build/app.yml` doesn't match the `--project` value. Re-run `install/install.sh --profile <your-profile> --project <correct-id>` — the artifacts hook will re-render the file from the corrected env var.

### First model diagram takes minutes to load

Expected on the very first view after a deploy (ELK layout warm-up). Subsequent loads are sub-second. If it times out, raise the app compute size in the Databricks UI (`MEDIUM` → `LARGE`).

### `Connection 'github_pr' does not exist` during bundle deploy

You deployed the `github-publish` target on a workspace where the `github_pr` UC connection has not been created yet. The default install (`install/install.sh`, `dev` target) does not declare this resource and is unaffected. Either create the connection first (see [Enabling publish-to-GitHub](#enabling-publish-to-github-optional)) or deploy the default target.

### App SP can't see catalogs in the New Run picker

The auto-grant step at `[3/5]` likely logged a permission warning. Have a user with catalog ownership / `MANAGE` / metastore-admin run the SQL in [App SP catalog privileges](#app-sp-catalog-privileges), or re-run `python install/grant_catalog.py` from a privileged identity.

### `bundle deploy` fails with `workspace_id mismatch ... in provider_config`

The local DAB terraform state under `.databricks/bundle/dev/` is a cache that pins the workspace this bundle was last deployed to from this machine. Installing to a **different** workspace (e.g. a different workspace after previously deploying elsewhere) trips this mismatch. `install.sh` auto-detects a workspace switch and clears the stale local state before deploy; if you hit it running `databricks bundle deploy` directly, clear it yourself — `rm -rf .databricks/bundle/dev/terraform` — and redeploy. The authoritative state lives in the target workspace, so clearing the local cache is safe.
