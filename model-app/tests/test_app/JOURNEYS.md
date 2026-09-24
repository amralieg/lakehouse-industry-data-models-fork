# Critical User Journeys

These are the end-to-end user journeys through the Vibe Modeling app,
derived from the white paper's two-step process (base model + vibe modeling)
and the app's actual UI/API surface.

## Journey 1: Create a New Business

1. GET `/api/businesses` → empty list
2. POST `/api/businesses` with name, description, industry alignment
3. Response has id, name, timestamps
4. GET `/api/businesses` → list contains the new business
5. GET `/api/businesses/{id}` → returns full business detail

## Journey 2: Edit a Business

1. Create a business
2. PUT `/api/businesses/{id}` with updated name, description, industry
3. GET `/api/businesses/{id}` → reflects the updated fields
4. `updated_at` has changed

## Journey 3: Delete a Business

1. Create a business
2. DELETE `/api/businesses/{id}` → `{"ok": true}`
3. GET `/api/businesses/{id}` → 404
4. GET `/api/businesses` → business no longer in list

## Journey 4: Configure Business Context

The business context is the "business portrait" from the white paper:
company info, industry, processes, jargon, governing body (context_json)
plus naming/type conventions (conventions_json).

1. Create a business
2. POST `/api/businesses/{id}/contexts` with version_label, context_json, conventions_json
3. Response has id, business_id, is_active=true
4. GET `/api/businesses/{id}/contexts` → list contains the context
5. Create a second context → both appear in list

## Journey 5: Start a New Base Model Run (White Paper Step 1)

This is the primary workflow: provide business context, trigger generation.

1. Create a business
2. POST `/api/runs` with business_id, run_type="new base model", catalog, model_size
3. Response has status="running", databricks_run_id set, started_at set
4. GET `/api/runs/{id}` → status still "running" (job in progress)
5. GET `/api/businesses/{id}/runs` → run appears in list
6. Simulate job completion (TERMINATED + SUCCESS)
7. GET `/api/runs/{id}` → status="completed", progress_percent=100, completed_at set

## Journey 6: Start a Vibe Modeling Run (White Paper Step 2)

Iterate on an existing model with natural language instructions.

1. Create a business
2. POST `/api/runs` with run_type="vibe modeling of version", vibe_instructions="Add a loyalty domain"
3. Response has status="running"
4. Parameters include the vibe instructions
5. Simulate job completion
6. GET `/api/runs/{id}` → status="completed"

## Journey 7: Monitor Run Progress

1. Create a business and start a run (running state)
2. GET `/api/runs/{id}` while job lifecycle is RUNNING → status stays "running"
3. Simulate TERMINATED + FAILED with error message
4. GET `/api/runs/{id}` → status="failed", error_message populated
5. run_page_url is present and contains workspace host + run ID

## Journey 8: Cancel a Running Run

1. Create a business and start a run (running state)
2. POST `/api/runs/{id}/cancel` → status="cancelled", completed_at set
3. Databricks cancel_run was called with the correct run ID
4. GET `/api/runs/{id}` → confirms cancelled state
5. POST `/api/runs/{id}/cancel` again → 400 (already cancelled)

## Journey 9: Retry a Failed Run

1. Create a business, start a run, simulate failure
2. GET `/api/runs/{id}` → status="failed"
3. POST `/api/runs/{id}/retry` → status="running", new databricks_run_id, error cleared
4. Simulate success on retry
5. GET `/api/runs/{id}` → status="completed"

## Journey 10: View Run Artifacts (endpoint exists, UI future)

1. Create a business, start a run
2. GET `/api/runs/{id}/artifacts` → empty list (no artifacts yet)
3. (Future: pipeline writes artifacts, they appear here)
