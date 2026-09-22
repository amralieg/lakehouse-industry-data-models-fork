# components/model

Shared model-page chrome. Both the model-version route and the input-review
route render these, so the orchestration around the `ModelView` tab bar lives
in ONE place instead of being duplicated per route.

- `model-tabs-shell.tsx` - `ModelTabsShell`: the full model-page orchestration
  around `ModelView` (business/model/versions fetches, current-version
  resolution, diagram-selection feedback context, column-mode preference gate,
  gated ELK cache warm, single-home Add-feedback, and the standard tab bodies).
  Router-owned `?tab=` and the destructive `DeleteVersionButton` stay in the
  route files (the latter injected via `versionActions`).
- `model-overview.tsx` - `ModelOverview` (shared Overview tab body: drift
  reconcile prompt, metrics band, domain cards, next-vibes). `showLifecycleActions`
  gates the run/install `CommandStrip` (input-review surface passes `false`).
- `model-search.tsx` - `ModelSearch`: model-wide element search (Cmd/Ctrl-K
  command palette + header trigger) over domains/tables/columns, mounted in the
  shell header (searchTrigger) and wired to per-element-type navigation.
