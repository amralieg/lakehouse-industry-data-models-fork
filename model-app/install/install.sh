#!/usr/bin/env bash
# End-to-end install for the Vibe Data Modeling app.
#
# Runs the full sequence:
#   1. databricks bundle deploy              (creates the App + its SP; the
#                                             artifacts hook in databricks.yml
#                                             renders src/app/.build/app.yml from
#                                             the VIBE_MODELING_* env vars this
#                                             script exports)
#   2. python install/provision_lakebase.py  (Lakebase project, endpoint, DB, roles)
#   3. python install/grant_catalog.py       (UC privileges for app SP — best-effort)
#   4. databricks apps start                 (bring compute up)
#   5. databricks apps deploy                (push the built source to the running app)
#
# The bundled vibe-modelling-agent notebook is installed by the App itself
# during its lifespan startup (see backend/core/_bundled_agent_init.py), so
# no separate post-deploy HTTP step is needed and there is no dependency on
# the operator's machine resolving the App's public URL.
#
# Steps 1 and 2 are in that order on purpose: provision needs the app's
# service principal, which doesn't exist until `bundle deploy` has registered
# the app. All steps are idempotent — safe to re-run on an already-installed
# workspace to pick up code or schema changes.
#
# Pre-requisites (all verified at step [0/5]; a missing critical one aborts,
# a below-minimum version warns):
#   - `databricks` CLI (>= 0.230.0) authenticated under the target profile
#   - `python` (>= 3.11), `jq` on PATH
#   - `apx`, `uv`, `bun` on PATH — the bundle build hook
#     (install/build_and_render.sh -> `apx build`) drives uv (wheel) and
#     bun (frontend); a missing one fails `bundle deploy` at step [1/5].
#   - **databricks-sdk and psycopg Python packages** in the active env
#     (provision_lakebase.py imports both; grant_catalog.py imports the SDK):
#       python -m pip install 'databricks-sdk>=0.61' 'psycopg[binary]'
#       uv pip install 'databricks-sdk>=0.61' 'psycopg[binary]'
#       pyenv activate vibe-modeling  # if using the project pyenv
#     install.sh fail-fasts at step 0 if either is missing.
#
# Usage:
#   install/install.sh [--profile <cli-profile>] \
#       [--app-name vibe-modeling] \
#       [--project vibe-modeling] \
#       [--catalog vibe_modeling] \
#       [--warehouse-id <sql-warehouse-id>]

set -euo pipefail

APP_NAME="vibe-modeling"
PROFILE=""
PROJECT="vibe-modeling"
CATALOG="vibe_modeling"
WAREHOUSE_ID=""

usage() {
  cat <<EOF
Usage: $0 [--profile <cli-profile>] [options]

Options:
  --profile <name>        Databricks CLI profile (optional; omit for ambient/DEFAULT auth)
  --app-name <name>       Databricks App resource name (default: $APP_NAME)
  --project <id>          Lakebase project ID         (default: $PROJECT)
  --catalog <name>        Unity Catalog name + Postgres database name (default: $CATALOG)
  --warehouse-id <id>     SQL warehouse ID for Delta polling (optional;
                          omit to configure via the first-run UI)
  -h | --help             Show this message
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) PROFILE="$2"; shift 2 ;;
    --app-name) APP_NAME="$2"; shift 2 ;;
    --project) PROJECT="$2"; shift 2 ;;
    --catalog) CATALOG="$2"; shift 2 ;;
    --warehouse-id) WAREHOUSE_ID="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

PROFILE_FLAGS=()
[[ -n "$PROFILE" ]] && PROFILE_FLAGS=(--profile "$PROFILE")

# CRITICAL tools. install.sh itself needs databricks/python/jq; the bundle
# build hook (install/build_and_render.sh -> `apx build`) needs apx/uv/bun.
# A missing one fails the deploy, so abort up front rather than mid-install.
for cmd in databricks python jq apx uv bun; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: required tool '$cmd' not found in PATH" >&2; exit 2; }
done

# CRITICAL Python deps. provision_lakebase.py imports databricks.sdk AND psycopg;
# grant_catalog.py imports databricks.sdk. Verify both before we waste a bundle
# deploy on an env that will crash at step [2/5].
for mod in databricks.sdk psycopg; do
  if ! python -c "import $mod" >/dev/null 2>&1; then
    cat >&2 <<EOF
ERROR: required Python package providing '$mod' is not installed in the active env.

Install the install-time deps (one of the following, per your env manager):
  python -m pip install 'databricks-sdk>=0.61' 'psycopg[binary]'
  uv pip install 'databricks-sdk>=0.61' 'psycopg[binary]'
  pyenv activate vibe-modeling   # if using the project's pyenv

Then re-run install.sh.
EOF
    exit 2
  fi
done

# NON-CRITICAL version checks: warn (don't block) if below the INSTALL.md
# minimums. Below-minimum often still works; surface it without aborting.
_below() { [[ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -1)" != "$1" ]]; }  # true if $2 < $1
CLI_VER=$(databricks version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
[[ -n "$CLI_VER" ]] && _below "0.230.0" "$CLI_VER" && \
  echo "WARN: databricks CLI $CLI_VER is below the recommended 0.230.0 (INSTALL.md); bundle features may misbehave." >&2
PY_VER=$(python -c 'import sys;print("%d.%d.%d"%sys.version_info[:3])' 2>/dev/null)
[[ -n "$PY_VER" ]] && _below "3.11.0" "$PY_VER" && \
  echo "WARN: python $PY_VER is below the required 3.11.0 (INSTALL.md)." >&2

cd "$(dirname "$0")/.."

echo "==> [0/5] Verifying credentials (profile: ${PROFILE:-<ambient>})"
ME=$(databricks current-user me ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --output json | jq -r .userName)
echo "    authenticated as: $ME"

# Export the install-time values the artifacts hook (databricks.yml ->
# install/build_and_render.sh) reads when rewriting src/app/.build/app.yml.
# Source src/app/app.yml is never modified.
#
# DATABASE_NAME drives the Postgres connection (the app's own state DB);
# DEPLOYMENT_CATALOG seeds AgentConfig.deployment_catalog on first boot.
# Both are derived from --catalog because by convention the Postgres DB
# name matches the UC catalog name, but they're distinct downstream.
export VIBE_MODELING_LAKEBASE_PROJECT="$PROJECT"
export VIBE_MODELING_DATABASE_NAME="$CATALOG"
export VIBE_MODELING_DEPLOYMENT_CATALOG="$CATALOG"
export VIBE_MODELING_WAREHOUSE_ID="$WAREHOUSE_ID"

# A first-time install deploys to a new workspace's production branch on
# purpose — that is an allowed production operation (not a dev redeploy).
# Opt in to the production guard explicitly.
export ALLOW_PRODUCTION_DEPLOY=1

echo
echo "==> [0/5] in-flight runs guard"
# install.sh is idempotent — operators re-run it to pick up code or
# schema changes. If the App already exists AND has in-flight runs,
# refuse to proceed: an atomic-replace App container swap can't hand
# off in-memory pollers cleanly, so the next deploy would silently
# orphan those runs until the new container's lifespan re-attaches.
# Delegates to scripts/_internal/in_flight_guard.sh (shared with redeploy.sh).
APP="$APP_NAME" PROFILE="$PROFILE" FORCE="${FORCE:-0}" \
  bash "$(pwd)/scripts/_internal/in_flight_guard.sh"

echo
echo "==> [1/5] databricks bundle deploy"
echo "    app_name=$APP_NAME, project=$PROJECT, UC catalog=$CATALOG, Lakebase DB=$CATALOG, warehouse_id=${WAREHOUSE_ID:-<unset, configure via UI>}"

# Clear stale local bundle state that pins a different workspace (a fresh-
# workspace install from a machine that deployed this bundle elsewhere fails
# with "workspace_id mismatch ... in provider_config"). Delegates to
# scripts/_internal/clear_stale_bundle_state.sh (shared with redeploy.sh).
PROFILE="$PROFILE" TARGET=dev REPO_ROOT="$(pwd)" \
  bash "$(pwd)/scripts/_internal/clear_stale_bundle_state.sh"

# Pre-build src/app/.build before bundle deploy.
# databricks CLI v1.10.0 resolves sync.include paths before running the
# artifacts.default.build hook; if .build is absent the deploy fails with
# "stat src/app/.build: no such file or directory".
bash install/build_and_render.sh

databricks bundle deploy ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --var "app_name=$APP_NAME"

echo
echo "    Capturing app service principal"
APP_SP=$(databricks apps get "$APP_NAME" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --output json | jq -r .service_principal_client_id)
if [[ -z "$APP_SP" || "$APP_SP" == "null" ]]; then
  echo "ERROR: could not read service_principal_client_id from app '$APP_NAME'" >&2
  exit 1
fi
echo "    app SP: $APP_SP"

echo
echo "==> [2/5] python install/provision_lakebase.py"
python install/provision_lakebase.py \
  ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} \
  --project "$PROJECT" \
  --catalog "$CATALOG" \
  --app-sp  "$APP_SP" \
  --grant-user "$ME"

echo
echo "==> [3/5] python install/grant_catalog.py"
python install/grant_catalog.py \
  ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} \
  --catalog "$CATALOG" \
  --app-sp  "$APP_SP"

echo
echo "==> [4/5] Starting app compute (if stopped)"
STATE=$(databricks apps get "$APP_NAME" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --output json | jq -r .compute_status.state)
if [[ "$STATE" != "ACTIVE" ]]; then
  databricks apps start "$APP_NAME" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} >/dev/null
  for _ in {1..24}; do
    STATE=$(databricks apps get "$APP_NAME" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --output json | jq -r .compute_status.state)
    [[ "$STATE" == "ACTIVE" ]] && break
    echo "    compute state: $STATE (waiting 10s)"
    sleep 10
  done
fi
[[ "$STATE" == "ACTIVE" ]] || { echo "ERROR: compute did not reach ACTIVE (last: $STATE)" >&2; exit 1; }
echo "    compute state: ACTIVE"

echo
echo "==> [5/5] databricks apps deploy"
BUNDLE_PATH="/Workspace/Users/${ME}/.bundle/vibe-modeling/dev/files/src/app/.build"
databricks apps deploy "$APP_NAME" \
  --source-code-path "$BUNDLE_PATH" \
  ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} >/dev/null

echo "    waiting for app to reach RUNNING..."
for _ in {1..30}; do
  APP_STATE=$(databricks apps get "$APP_NAME" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --output json | jq -r .app_status.state)
  if [[ "$APP_STATE" == "RUNNING" ]]; then
    break
  fi
  if [[ "$APP_STATE" == "CRASHED" ]]; then
    echo "ERROR: app crashed. Last 60 lines of app logs:" >&2
    databricks apps logs "$APP_NAME" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --tail-lines 60 --source APP >&2 || true
    exit 1
  fi
  echo "    app_status: $APP_STATE"
  sleep 10
done

if [[ "$APP_STATE" != "RUNNING" ]]; then
  echo "ERROR: app did not reach RUNNING (last: $APP_STATE)" >&2
  exit 1
fi

APP_URL=$(databricks apps get "$APP_NAME" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --output json | jq -r .url)

# Post-install verification of the things INSTALL.md promises a fresh install
# yields. WARN-ONLY: the app is already RUNNING (hard-checked above); these are
# eventually-consistent (the lifespan hook seeds industries + the catalog grant
# is best-effort), so surface gaps without failing a deploy that did its job.
echo
echo "==> [verify] post-install checks (warn-only)"
VTOKEN=$(databricks auth token ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} 2>/dev/null | jq -r .access_token)
if [[ -n "$VTOKEN" && "$VTOKEN" != "null" ]]; then
  CODE=$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $VTOKEN" "$APP_URL/" || echo 000)
  [[ "$CODE" == "200" ]] && echo "    [ok]   homepage 200" \
    || echo "    [warn] homepage returned $CODE (expected 200)"
  INDC=$(curl -s -H "Authorization: Bearer $VTOKEN" "$APP_URL/api/industries" | jq 'length' 2>/dev/null || echo "?")
  [[ "$INDC" == "40" ]] && echo "    [ok]   industries seeded (40)" \
    || echo "    [warn] /api/industries returned '$INDC' (expected 40); the lifespan seed may still be running — re-check in ~30s"
  # Check actual Unity Catalog existence via the control plane, not the app's
  # /api/catalogs view: the deployment_catalog is a configured *name* that the
  # app reports as present regardless of whether the catalog exists, so an
  # app-side check gives a false "visible" on a fresh workspace where the
  # catalog has not been provisioned yet.
  if databricks catalogs get "$CATALOG" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} >/dev/null 2>&1; then
    echo "    [ok]   catalog '$CATALOG' exists in Unity Catalog"
  else
    echo "    [warn] catalog '$CATALOG' does not exist yet — model-producing runs will fail until it"
    echo "           is provisioned (see [3/5] output and INSTALL.md 'App SP catalog privileges')."
  fi
else
  echo "    [warn] could not mint a token for post-install checks; verify manually (INSTALL.md 'Verify the install')."
fi

cat <<EOF

Install complete.
  App name:          $APP_NAME
  App URL:           $APP_URL
  Lakebase project:  $PROJECT
  UC catalog:        $CATALOG
  Database name:     $CATALOG
  Warehouse ID:      ${WAREHOUSE_ID:-<unset — configure via first-run UI>}
  App SP:            $APP_SP

Next: open the app URL. The app installs the bundled agent notebook on its
own during boot (see backend/core/_bundled_agent_init.py). To swap in a
different notebook, go to Settings -> Agent Configuration.
EOF
