# Mock Vibe Modelling Agent

A drop-in replacement for the vibe modelling agent notebook for **testing only**.
Produces the same Delta progress event sequence and `model.json` output shape as
the real v0.5.x agent, but completes in ~30 seconds instead of hours.

## When to use

- End-to-end test of the app's full vibe run lifecycle (launch, poll, handshake, sync)
- Exercising resume-after-restart and failure paths
- Integration tests that can't afford to run the real agent
- Local dev loop where you want to iterate on UI or sync logic without burning LLM credits

## Deploy to a workspace

```bash
# Import the notebook to your workspace
databricks workspace import \
  /Workspace/Shared/vibe-modeling/mock_vibe_agent \
  --file tests/fixtures/mock_vibe_agent/mock_vibe_agent.py \
  --language PYTHON \
  --profile <your-profile>
```

Then in the app's Settings, point `AgentConfig.notebook_path` at the mock's
workspace path instead of the real agent notebook.

## Mock modes

Controlled by the `mock_mode` widget on the notebook:

| Mode | Behavior |
|---|---|
| `success` (default) | Full successful run in ~30s. Writes canned model.json with 2 domains, 4 products, 10 attributes, 2 FKs. |
| `failure_at_stage_3` | Emits events for stages 1–2 successfully, then injects a `stage_failed` event at stage 3 (Designing Domains). |
| `failure_at_stage_12` | Fails at stage 12 (Physical Schema Construction). |
| `long_failure` | Sleeps 60+ seconds before failing — exercises the app's staleness-detection path. |

Set via `mock_event_delay_seconds` to slow individual events (default `0.5s` —
fast enough for quick tests, slow enough to see UI progress).

## Contract

Matches the real v0.5.x agent integration contract exactly:

- **`_business` Delta table** — handshake row with `session_id` (BIGINT), `processing_status` flipping `pending` → `done` → `ready`, `completed_percent` ticking to 100.0
- **`_vibe_progress` Delta table** — 20+ ordered `(stage_name, step_name)` events ending with `Vibe Session` / `Session Ended`
- **`model.json`** — written to `<TARGET_VOLUME>/model.json` at the same path convention as the real agent
- **Same 28 widgets** — reads all standard widgets, plus two mock-only controls

See the agent's `model.json` output shape for the full contract reference.

## Canned model.json

The mock always produces the same 2-domain model:

- `sales.customers` — PK `customer_id`, with `customer_name`, `customer_email`
- `sales.orders` — PK `order_id`, FK to `sales.customers.customer_id`
- `inventory.products` — PK `product_id`, with `product_name`
- `inventory.stock_levels` — PK `stock_id`, FK to `inventory.products.product_id`

This is deliberately small so tests are fast. For larger test fixtures, edit
`CANNED_MODEL` in `mock_vibe_agent.py` or build a separate fixture notebook.
