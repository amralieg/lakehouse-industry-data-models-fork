#!/usr/bin/env bash
# Build the apx artifacts and render src/app/.build/app.yml with the
# install-time env-var values. Invoked by databricks.yml's
# artifacts.default.build hook (and therefore by `databricks bundle deploy`).
#
# install/install.sh exports VIBE_MODELING_LAKEBASE_PROJECT,
# VIBE_MODELING_DATABASE_NAME, VIBE_MODELING_DEPLOYMENT_CATALOG, and
# VIBE_MODELING_WAREHOUSE_ID before invoking `bundle deploy`; this script
# reads them. When run outside install.sh (e.g. a direct
# `databricks bundle deploy`), the same defaults the canonical install
# would produce are applied.
#
# Source src/app/app.yml is never modified — only the build output
# src/app/.build/app.yml is rewritten.

set -euo pipefail

# Repo root is the parent of install/.
cd "$(dirname "$0")/.."

( cd src/app && apx build )

python install/render_app_yaml.py \
  --in  src/app/app.yml \
  --out src/app/.build/app.yml \
  --project            "${VIBE_MODELING_LAKEBASE_PROJECT:-vibe-modeling}" \
  --database           "${VIBE_MODELING_DATABASE_NAME:-vibe_modeling}" \
  --deployment-catalog "${VIBE_MODELING_DEPLOYMENT_CATALOG:-vibe_modeling}" \
  --warehouse-id       "${VIBE_MODELING_WAREHOUSE_ID:-}"
