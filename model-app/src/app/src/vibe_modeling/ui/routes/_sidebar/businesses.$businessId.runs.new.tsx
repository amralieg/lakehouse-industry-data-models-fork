import { createFileRoute, Link, useNavigate, useParams, useSearch } from "@tanstack/react-router";
import { Suspense, useCallback, useEffect, useMemo, useRef, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Checkbox } from "@/components/ui/checkbox";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  ArrowLeft,
  ArrowRight,
  ChevronDown,
  ChevronRight,
  FolderOpen,
} from "lucide-react";
import {
  createRun,
  useGetBusinessSuspense,
  useGetCatalogSchemaWarning,
  useListVersionsSuspense,
  useListVibeInputs,
  validateRun,
  type IssueOut,
  type RunIn,
  type VibeInputOut,
} from "@/lib/api";
import { selector } from "@/lib/selector";
import { notifyConfigMissing } from "@/lib/notify";
import { apiErrorMessage } from "@/lib/api-error";
import { deriveRunFormBlockers } from "@/lib/run-form";
import { CompiledPreview } from "@/components/vibe-inputs/compiled-preview";
import { intentToRunType, runTypeToIntent } from "@/lib/intent";
import { Skeleton } from "@/components/ui/skeleton";
import { TagInput } from "@/components/ui/tag-input";
import { MarkdownEditor } from "@/components/ui/markdown-editor";
import { LaunchRunDialog } from "@/components/runs/launch-run-dialog";
import { DeploymentCatalogPicker } from "@/components/runs/deployment-catalog-picker";
import { VolumePicker } from "@/components/import/volume-picker";

const NAMING_CONVENTIONS = ["snake_case", "camelCase", "PascalCase"] as const;
const TABLE_ID_TYPES = ["BIGINT", "STRING", "INT"] as const;
const BOOLEAN_FORMATS = ["Boolean (True/False)", "Integer (1/0)", "String (Yes/No)"] as const;
const CATALOGING_STYLES = ["One Catalog", "Catalog per Division", "Catalog per Domain"] as const;
const YES_NO = ["Yes", "No"] as const;

/** Monolith dropdown values for org_divisions widget */
const ORG_DIVISIONS_PRESETS = [
  "Operations",
  "Operations and Business",
  "Operations, Business and Corporate",
] as const;

const CONVENTION_DEFAULTS = {
  naming_convention: "snake_case",
  primary_key_suffix: "_id",
  // Legacy single schema_prefix — still sent for non-unified ops (vibe/
  // shrink/etc). For `new base model` runs `ecm_schema_prefix` +
  // `mvm_schema_prefix` take over; see the Advanced accordion below.
  schema_prefix: "",
  // Per-scope prefixes for the unified ECM→MVM pipeline (#122). Defaults
  // mirror what the router computes from `cataloging_style` so the form
  // preview matches the server-side behaviour.
  ecm_schema_prefix: "ecm_",
  mvm_schema_prefix: "mvm_",
  schema_suffix: "",
  tag_prefix: "dbx_",
  tag_suffix: "",
  table_id_type: "BIGINT",
  boolean_format: "Boolean (True/False)",
  date_format: "yyyy-MM-dd",
  timestamp_format: "yyyy-MM-dd HH:mm:ss",
  cataloging_style: "One Catalog",
  catalog_prefix: "",
  catalog_suffix: "",
  org_divisions: "Operations",
  business_domains: "",
  classification_levels: "",
  housekeeping_columns: "No",
  history_tracking_columns: "No",
};

type RunsNewSearch = {
  operationType?: string;
  /** Pre-select a base version by its integer version. Pairs with
   *  ``sourceScope`` to disambiguate when the same number hosts both
   *  ECM and MVM rows. */
  sourceVersion?: number;
  /** Pre-select the scope of the base version. Defaults to ``mvm`` —
   *  the deployable scope and the most common iterate target. */
  sourceScope?: string;
};

export const Route = createFileRoute("/_sidebar/businesses/$businessId/runs/new")({
  validateSearch: (search: Record<string, unknown>): RunsNewSearch => ({
    operationType: search.operationType as string | undefined,
    sourceVersion:
      search.sourceVersion != null && search.sourceVersion !== ""
        ? Number(search.sourceVersion)
        : undefined,
    sourceScope: search.sourceScope as string | undefined,
  }),
  component: () => {
    const { businessId } = useParams({ from: "/_sidebar/businesses/$businessId/runs/new" });
    return (
      <div className="p-6 space-y-6">
        <div className="flex items-center gap-4">
          <Button variant="ghost" size="icon" asChild>
            <Link to="/businesses/$businessId/explorer" params={{ businessId }}>
              <ArrowLeft className="h-4 w-4" />
            </Link>
          </Button>
          <h1 className="text-2xl font-semibold tracking-tight">New Run</h1>
        </div>
        <Suspense fallback={<Skeleton className="h-96" />}>
          <NewRunForm />
        </Suspense>
      </div>
    );
  },
});

/** Default org_divisions per model scope */
function scopeDefaultDivisions(size: string): string {
  return size === "large model" ? "Operations, Business and Corporate" : "Operations";
}

function NewRunForm() {
  const navigate = useNavigate();
  const { businessId } = useParams({
    from: "/_sidebar/businesses/$businessId/runs/new",
  });
  const {
    operationType,
    sourceVersion,
    sourceScope,
  } = useSearch({ from: "/_sidebar/businesses/$businessId/runs/new" });
  // Suspense-driven loads. The QueryClient in `main.tsx` sets
  // `refetchOnWindowFocus: false` globally so opening a Popover (catalog
  // picker, etc.) does not re-suspend the form and wipe typed content
  // (the model-versioning work fix M).
  const { data: versions } = useListVersionsSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  const { data: business } = useGetBusinessSuspense({
    params: { business_id: businessId },
    ...selector(),
  });

  const hasVersions = versions.length > 0;
  const completedVersions = versions.filter((v) => v.status === "completed");
  const latestVersion = versions[0]; // sorted desc by version
  // The URL ``operationType`` param accepts either an OperationType
  // value (``"vibe modeling of version"``) or its Intent alias
  // (``"vibe-iterate"``). Normalise to OperationType so the Select
  // pre-populates correctly.
  const defaultRunType = operationType
    ? intentToRunType(operationType)
    : hasVersions
      ? "vibe modeling of version"
      : "new base model";

  const [runType, setRunType] = useState(defaultRunType);
  const [catalog, setCatalog] = useState(latestVersion?.uc_catalog || "");
  const [contextMode, setContextMode] = useState<"path" | "text">("text");
  const [businessContextPath, setBusinessContextPath] = useState("");
  // Volume browser dialog for the File-Path business-context mode. Manual
  // entry into the text input stays as the fallback (U-05).
  const [volumePickerOpen, setVolumePickerOpen] = useState(false);
  // Business Context starts empty; the effect below seeds it from
  // `business.description` on first render (and on subsequent business
  // identity changes) ONLY while the user has not yet edited the textarea.
  // Once `businessContextDirty` flips true, any future re-render of this
  // form (Suspense re-mount, business object identity change, etc.) will
  // NOT clobber what the user typed. This is the second layer of defence
  // for the model-versioning work fix M; the first layer is the QueryClient-wide
  // `refetchOnWindowFocus: false` in `main.tsx`.
  const [businessContextText, setBusinessContextText] = useState("");
  const [businessContextDirty, setBusinessContextDirty] = useState(false);
  useEffect(() => {
    if (!businessContextDirty && business?.description) {
      setBusinessContextText(business.description);
    }
  }, [business?.description, businessContextDirty]);
  const [modelSize, setModelSize] = useState("small model");
  // URL preselect: prefer (sourceVersion, sourceScope) over the latest row.
  // Default sourceScope to "mvm" — the deployable scope and the most common
  // iterate target. Falls back to the freshest completed version when no
  // preselect URL params are set.
  const initialBaseVersionId = (() => {
    if (sourceVersion != null) {
      const wantedScope = (sourceScope || "mvm").toLowerCase();
      const exact = completedVersions.find(
        (v) =>
          v.version === sourceVersion
          && ((v as any).scope || "").toLowerCase() === wantedScope,
      );
      if (exact) return exact.id;
      // Fall back to a same-version match in any scope so the user lands
      // somewhere reasonable rather than the wrong row.
      const anyScope = completedVersions.find((v) => v.version === sourceVersion);
      if (anyScope) return anyScope.id;
    }
    return completedVersions[0]?.id || "";
  })();
  const [baseVersionId, setBaseVersionId] = useState(initialBaseVersionId);
  // Remember the base-version selection per operation type so switching
  // Operation Type and back restores the prior selection instead of
  // silently losing it (E-01). The selected Vibe Inputs are durable
  // server-side (`selected_for_run`, keyed by version), so restoring the
  // version id re-derives the exact selection + count. Populated on
  // op-switch (handleRunTypeChange stashes the outgoing op's version) and
  // on explicit base-version picks, then read by the reconcile effect on
  // switch-back.
  const selectionByOpRef = useRef<Record<string, string>>({});
  // The run dispatches the inputs the user selected on the compose surface:
  // active, anchored, non-consumed, and `selected_for_run`. The server
  // re-compiles authoritatively from these ids on launch.
  const { data: vibeInputs } = useListVibeInputs({
    params: { business_id: businessId, version_id: baseVersionId, status: "active" },
    query: { enabled: Boolean(baseVersionId), select: (resp) => resp.data },
  });

  const { data: catalogWarningData } = useGetCatalogSchemaWarning({
    params: { catalog_name: catalog },
    query: { enabled: Boolean(catalog), select: (resp) => resp.data },
  });
  const catalogSchemaCount = catalogWarningData?.schema_count ?? 0;
  const baseInputs: VibeInputOut[] = (Array.isArray(vibeInputs) ? vibeInputs : []).filter(
    (vi) => !vi.consumed && vi.anchor != null && vi.selected_for_run,
  );
  const inputIds = baseInputs.map((vi) => vi.id);
  const includedInputIds = new Set(inputIds);
  const [vibeInstructions, setVibeInstructions] = useState("");
  const [generateSamples, setGenerateSamples] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");
  const [advancedOpen, setAdvancedOpen] = useState(false);
  // Dialog gate. Submit only actually fires createRun once the user confirms
  // via the LaunchRunDialog — preventing accidental submissions from stray
  // Enter presses (e.g. in the TagInput, see PR #115).
  const [confirmOpen, setConfirmOpen] = useState(false);

  // Convention overrides — initialized to defaults
  const [conventions, setConventions] = useState({ ...CONVENTION_DEFAULTS });
  // Multi-value fields stored as arrays, serialized to comma-separated on submit
  const [domainTags, setDomainTags] = useState<string[]>([]);
  const [classificationTags, setClassificationTags] = useState<string[]>([]);
  // Track whether user manually changed org_divisions
  const [orgDivisionsManual, setOrgDivisionsManual] = useState(false);

  const updateConvention = useCallback((key: keyof typeof CONVENTION_DEFAULTS, value: string) => {
    setConventions((prev) => ({ ...prev, [key]: value }));
  }, []);

  const handleModelSizeChange = useCallback((size: string) => {
    setModelSize(size);
    if (!orgDivisionsManual) {
      setConventions((prev) => ({ ...prev, org_divisions: scopeDefaultDivisions(size) }));
    }
  }, [orgDivisionsManual]);

  const isVibeIterate = runType === "vibe modeling of version";
  const isVibeCombined = runType === "vibe new ecm + mvm";
  // The combined "Vibe ECM + MVM" run reuses the same form fields as
  // vibe-iterate (parent_version_id, vibe_instructions, business_context_text,
  // catalog, cataloging_style, schema prefixes). Treat them identically for
  // form rendering and submission. The BE differentiates by intent slug; the
  // validate endpoint also enforces "parent must be ECM scope" for the
  // combined intent.
  const isVibe = isVibeIterate || isVibeCombined;
  const isBase = runType === "new base model";
  const isModelProducing = isBase || isVibe;
  const isSingleCatalog = conventions.cataloging_style === "One Catalog";

  // Eligible base versions per intent. The combined ECM+MVM run pipes its
  // input through the shrink step, which requires an ECM source. Vibe-iterate
  // accepts either scope (the user iterates the version they want).
  const eligibleBaseVersions = useMemo(() => {
    if (isVibeCombined) {
      return completedVersions.filter((v) => v.scope === "ecm");
    }
    return completedVersions;
  }, [completedVersions, isVibeCombined]);

  // Record the version a user explicitly picks under the current op so it
  // can be restored after an Operation Type round-trip (E-01).
  const handleBaseVersionChange = useCallback((id: string) => {
    setBaseVersionId(id);
    selectionByOpRef.current[runType] = id;
  }, [runType]);

  // Stash the current vibe selection under the outgoing op before switching,
  // so switching back can restore it (E-01).
  const handleRunTypeChange = useCallback((next: string) => {
    if (isVibe && baseVersionId) {
      selectionByOpRef.current[runType] = baseVersionId;
    }
    setRunType(next);
  }, [isVibe, baseVersionId, runType]);

  // Keep the base-version picker consistent with the chosen op:
  //  1. Restore the remembered selection for this op if it is eligible again
  //     (switching Operation Type back must not lose the prior selection —
  //     E-01). The selected Vibe Inputs come back with it because they are
  //     durable server-side, keyed by version.
  //  2. Otherwise, if the current selection is not eligible for this op
  //     (e.g. an MVM version while on the combined intent, which only accepts
  //     ECM), fall back to the first eligible version.
  useEffect(() => {
    if (!isVibe) return;
    const remembered = selectionByOpRef.current[runType];
    const rememberedValid =
      Boolean(remembered) && eligibleBaseVersions.some((v) => v.id === remembered);
    const currentValid = eligibleBaseVersions.some((v) => v.id === baseVersionId);
    if (rememberedValid && remembered !== baseVersionId) {
      setBaseVersionId(remembered);
    } else if (!currentValid) {
      setBaseVersionId(eligibleBaseVersions[0]?.id || "");
    }
  }, [eligibleBaseVersions, baseVersionId, isVibe, runType]);

  // Submit blockers derived from form state. Centralised in
  // `lib/run-form.ts` so the disabled-banner copy and the actual `disabled`
  // prop can never disagree, and so a third gate can be added without
  // touching the form file.
  //
  // - `baseContextMissing`: new-base-model's agent fails fast in widget
  //   '02. Description' / '11. Model JSON File Path' when the business has
  //   nothing to describe. Mirror that here so the user gets immediate
  //   feedback instead of a failed run with no progress events.
  // - `vibeContentMissing`: vibe ops require something to vibe on. The selected
  //   Vibe Inputs (compiled server-side from `input_ids`) are the content; an
  //   empty selection is the blocker, surfaced as an empty-state CTA.
  const { baseContextMissing, vibeContentMissing } = deriveRunFormBlockers({
    isBase,
    isVibe,
    contextMode,
    businessContextText,
    businessContextPath,
    inputCount: inputIds.length,
  });

  // Live validation state — debounced from form changes (spec §2.4 + §2.4.1).
  // Only exercised for the new-base-model intent in this wirer; other intents
  // will adopt the same hook once their wirers ship.
  const [validateBlockers, setValidateBlockers] = useState<IssueOut[]>([]);
  const [validateWarnings, setValidateWarnings] = useState<IssueOut[]>([]);
  const validateAbortRef = useRef<AbortController | null>(null);

  // Live validation runs for every model-producing intent (new-base-model,
  // vibe-iterate, vibe-new-ecm-mvm). It surfaces two classes of pre-submit
  // signal the user must see BEFORE launching: config-missing blockers (the
  // agent/warehouse/metamodel-catalog isn't set up) and the run-target-
  // override divergence warning (the run's catalog differs from the
  // configured metamodel catalog). Both come back from POST /runs/validate
  // regardless of intent, so gating validation to base-only hid them for the
  // common default op (vibe-iterate when the business already has versions).
  const validateEnabled = isBase || isVibe;
  useEffect(() => {
    if (!businessId || !validateEnabled) {
      setValidateBlockers([]);
      setValidateWarnings([]);
      return;
    }
    const intent = runTypeToIntent(runType);
    if (!intent) return;

    const ctl = new AbortController();
    validateAbortRef.current?.abort();
    validateAbortRef.current = ctl;

    const handle = window.setTimeout(async () => {
      const body: RunIn = {
        // Cast to satisfy the api.ts forward-ref type alias; backend
        // accepts the snake-case Intent enum value verbatim.
        intent: intent as RunIn["intent"],
        catalog,
        cataloging_style: conventions.cataloging_style,
        business_context_path: contextMode === "path" ? businessContextPath : "",
        business_context_text: contextMode === "text" ? businessContextText : "",
        ecm_schema_prefix: conventions.ecm_schema_prefix,
        mvm_schema_prefix: conventions.mvm_schema_prefix,
        // Vibe intents carry the parent version so the BE can validate it
        // (the combined intent additionally enforces "parent must be ECM
        // scope"). new-base-model has no parent.
        ...(isVibe && baseVersionId ? { version_id: baseVersionId } : {}),
        // Vibe intents MUST send the selected input ids so /validate can
        // compile `vibe_instructions` server-side. vibe-new-ecm-mvm builds
        // the full DAG and runs Gate B, which enforces the vibe_iterate
        // step's `vibe_instructions: min_length=1`; without the ids that
        // field compiles empty → a permanent blocker that disables Start Run
        // (E-10). Mirror the CREATE body so validate sees the same content.
        ...(isVibe ? { input_ids: inputIds, next_vibe_ids: [] } : {}),
      };
      try {
        const { data } = await validateRun(
          { business_id: businessId },
          body,
          { signal: ctl.signal },
        );
        if (!ctl.signal.aborted) {
          setValidateBlockers(data.blockers || []);
          setValidateWarnings(data.warnings || []);
        }
      } catch (err) {
        // Aborted (user kept typing) or network error — clear stale state
        // but don't surface the error inline; the hard submit will
        // re-validate and produce a real error if needed.
        if (!ctl.signal.aborted) {
          setValidateBlockers([]);
          setValidateWarnings([]);
        }
      }
    }, 300);
    return () => {
      window.clearTimeout(handle);
      ctl.abort();
    };
  }, [
    businessId,
    validateEnabled,
    isVibe,
    isVibeCombined,
    runType,
    catalog,
    conventions.cataloging_style,
    conventions.ecm_schema_prefix,
    conventions.mvm_schema_prefix,
    contextMode,
    businessContextPath,
    businessContextText,
    baseVersionId,
    // Re-validate when the compiled selection changes so Gate B's
    // vibe_instructions check re-runs with the current inputs (E-10).
    inputIds.join(","),
  ]);

  // Form submit only validates + opens the confirmation dialog. The actual
  // createRun call happens in `performRun` once the user confirms. This
  // makes the dialog a hard gate: an accidental Enter press (e.g. an empty
  // draft in a TagInput) can at worst surface a confirm prompt, never kick
  // off a real run.
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (submitting || confirmOpen) return;
    // Vibe runs dispatch the inputs selected on the compose surface. Block when
    // the selection is empty; the empty-state CTA points back to Compose.
    if (isVibe && inputIds.length === 0) {
      setError(
        "No inputs selected — choose inputs on the Compose surface to include in this run."
      );
      return;
    }
    if (isVibe && !baseVersionId) {
      setError("Select a base version to apply vibes to");
      return;
    }
    setError("");
    setConfirmOpen(true);
  };

  const performRun = async () => {
    setSubmitting(true);
    setError("");
    try {
      await createRun(
        { business_id: businessId },
        {
        // Phase 5 (orchestrator refactor §8): the wire only carries
        // the canonical Intent slug now; ``run_type`` was retired.
        intent: runTypeToIntent(runType) as RunIn["intent"],
        catalog,
        version_id: isVibe ? baseVersionId : undefined,
        business_context_path:
          (isBase || isVibeCombined) && contextMode === "path" ? businessContextPath : "",
        business_context_text:
          (isBase || isVibeCombined) && contextMode === "text" ? businessContextText : "",
        // New-base-model and vibe-new-ecm-mvm are both ECM → shrink-to-MVM
        // pipelines (PR #86 + the combined-intent factory). Phase 1 must
        // always run as ECM ("large model") for the shrink step to find
        // its source; the user has no choice for either intent, so we
        // hardcode and ignore any leftover Model Size form state.
        model_size: (isBase || isVibeCombined) ? "large model" : modelSize,
        // The base path keeps a per-run "Run Instructions" editor; the vibe
        // path retired its free-text editor (Vibe Inputs are the content,
        // compiled server-side from input_ids). Send the editor text only
        // where the editor still exists.
        vibe_instructions: isBase ? vibeInstructions : "",
        generate_samples: generateSamples,
        next_vibe_ids: [],
        // Vibe Inputs selected on the compose surface — the durable selection.
        // Server re-compiles authoritatively from these ids.
        input_ids: isVibe ? inputIds : [],
        // Convention overrides — sent independently of the Advanced
        // Options disclosure being currently open. Gating on `advancedOpen`
        // dropped pill-typed `business_domains` whenever the user collapsed
        // the panel before clicking Start Run (silent data loss). Send
        // every override that has a non-empty value; skip the rest so the
        // server uses its own defaults rather than echoing form-state
        // placeholders.
        // `conventions` is a Record<string, string>; non-empty
        // (after-trim) values get sent so the server uses its own
        // defaults for the rest.
        ...Object.fromEntries(
          Object.entries(conventions).filter(
            ([, v]) => typeof v === "string" && v.trim().length > 0,
          ),
        ),
        ...(domainTags.length > 0
          ? { business_domains: domainTags.join(", ") }
          : {}),
        ...(classificationTags.length > 0
          ? { classification_levels: classificationTags.join(", ") }
          : {}),
        },
      );
      setConfirmOpen(false);
      navigate({
        to: "/businesses/$businessId/runs",
        params: { businessId },
      });
    } catch (err) {
      // A hard-submit 422 config_missing renders via the ONE shared renderer
      // (rich toast + Settings deep-links); other failures stay inline.
      if (!notifyConfigMissing(err)) {
        setError(apiErrorMessage(err, "Failed to start run"));
      }
      setSubmitting(false);
      setConfirmOpen(false);
    }
  };

  return (
    <div className={isVibe ? "grid grid-cols-[1fr_380px] gap-4" : ""}>
    <Card>
      <CardHeader>
        <CardTitle>Run Configuration</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-5">
          {/* Shared: Operation Type + Namespace Style + Deployment Catalog.
              Namespace style is now in the main form (not Advanced) because
              picking "Catalog per Division" / "Catalog per Domain" changes
              whether "Deployment catalog" is even meaningful — the agent
              derives per-division/per-domain catalog names from the prefix
              and suffix in those modes. */}
          <div className="grid grid-cols-3 gap-4">
            <div className="space-y-2">
              <label className="text-sm font-medium">Operation Type</label>
              <Select value={runType} onValueChange={handleRunTypeChange}>
                <SelectTrigger aria-label="Operation Type">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="new base model">New Base Model</SelectItem>
                  {/* The remaining operations all require an existing model
                      version. Hide them entirely when the business has none
                      instead of letting the user pick a dead-end option. */}
                  {completedVersions.length > 0 && (
                    <>
                      <SelectItem value="vibe modeling of version">Vibe Modeling</SelectItem>
                      <SelectItem value="vibe new ecm + mvm">Vibe ECM + MVM</SelectItem>
                      <SelectItem value="install model">Install Model</SelectItem>
                      <SelectItem value="uninstall model version">Uninstall Model</SelectItem>
                      <SelectItem value="generate sample data">Generate Samples</SelectItem>
                    </>
                  )}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium">Namespace Style</label>
              <Select
                value={conventions.cataloging_style}
                onValueChange={(v) => updateConvention("cataloging_style", v)}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {CATALOGING_STYLES.map((s) => (
                    <SelectItem key={s} value={s}>{s}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <p className="text-[10px] text-muted-foreground">
                {isSingleCatalog
                  ? "All generated tables land in the single catalog below."
                  : "Targets are derived per division/domain via the catalog and schema prefix/suffix in Advanced options."}
              </p>
            </div>

            <div className="space-y-2">
              {/* Label flips to "Metamodel Catalog" in multi-catalog modes
                  because the agent uses this value as the metamodel root
                  (where _metamodel.* tables + the vol_root volume live);
                  per-domain / per-division deploy catalogs are derived
                  from Catalog Prefix/Suffix in Advanced Options. The
                  field is NOT ignored in those modes — it's used. */}
              <label className="text-sm font-medium">
                {isSingleCatalog ? "Deployment Catalog" : "Metamodel Catalog"}
              </label>
              <DeploymentCatalogPicker
                value={catalog}
                onChange={setCatalog}
              />
              {!isSingleCatalog && (
                <p className="text-[10px] text-muted-foreground">
                  Used as the metamodel root only. Per-domain deploy catalogs
                  derive from Catalog Prefix/Suffix in Advanced Options.
                </p>
              )}
            </div>
          </div>

          {/* ─── New Base Model fields ─── */}
          {isBase && (
            <>
              <div className="space-y-2">
                <div className="flex items-center gap-3">
                  <label className="text-sm font-medium">Business Context</label>
                  <div className="flex gap-1">
                    <button
                      type="button"
                      onClick={() => setContextMode("text")}
                      className={`px-3 py-0.5 text-xs rounded-md transition-colors ${contextMode === "text" ? "bg-primary text-primary-foreground" : "bg-muted text-muted-foreground hover:bg-muted/80"}`}
                    >
                      Write
                    </button>
                    <button
                      type="button"
                      onClick={() => setContextMode("path")}
                      className={`px-3 py-0.5 text-xs rounded-md transition-colors ${contextMode === "path" ? "bg-primary text-primary-foreground" : "bg-muted text-muted-foreground hover:bg-muted/80"}`}
                    >
                      File Path
                    </button>
                  </div>
                </div>
                {contextMode === "path" ? (
                  <>
                    <div className="flex gap-2">
                      <Input
                        value={businessContextPath}
                        onChange={(e) => setBusinessContextPath(e.target.value)}
                        placeholder="e.g. /Volumes/catalog/schema/vibes/business_context.json"
                      />
                      <Button
                        type="button"
                        variant="outline"
                        onClick={() => setVolumePickerOpen(true)}
                        className="shrink-0"
                        data-testid="business-context-browse"
                      >
                        <FolderOpen className="h-4 w-4 mr-1.5" />
                        Browse
                      </Button>
                    </div>
                    <p className="text-xs text-muted-foreground">
                      Volume path to a business context JSON file — type it or
                      Browse Unity Catalog volumes.
                      Leave empty to reuse context from the last run.
                    </p>
                    <VolumePicker
                      open={volumePickerOpen}
                      onOpenChange={setVolumePickerOpen}
                      onSelect={setBusinessContextPath}
                    />
                  </>
                ) : (
                  <>
                    <MarkdownEditor
                      value={businessContextText}
                      onChange={(v) => {
                        setBusinessContextText(v);
                        setBusinessContextDirty(true);
                      }}
                      placeholder={"Describe your business here. The AI will use this to generate domains, products, and attributes.\n\nFor example:\n- What does the business do?\n- What industry is it in?\n- What are the core business processes?\n- What data domains matter most?"}
                      rows={8}
                    />
                    <p className="text-xs text-muted-foreground">
                      Describe your business in plain text or markdown. The AI generates domains, products, and attributes from this description.
                    </p>
                  </>
                )}
              </div>

              <div className="space-y-2">
                <label className="text-sm font-medium">
                  Run Instructions{" "}
                  <span className="font-normal text-muted-foreground">(optional)</span>
                </label>
                <MarkdownEditor
                  value={vibeInstructions}
                  onChange={setVibeInstructions}
                  placeholder="Per-run constraints, scope tweaks, or guidance the agent reads after the business description. Leave empty for default behaviour."
                  rows={4}
                />
                <p className="text-xs text-muted-foreground">
                  Per-run instructions the agent reads AFTER the business description (constraints, scope tweaks, etc.).
                  Hard constraints belong here, not in the business description — the description is durable and reusable;
                  these instructions are submission-specific.
                </p>
              </div>

              <div className="rounded-md border border-input bg-muted/30 px-3 py-2 text-xs text-muted-foreground">
                A new base model run generates a complete <strong>ECM</strong>{" "}
                (Expanded Coverage Model) and then automatically{" "}
                <strong>shrinks it to an MVM</strong> (Minimum Viable Model).
                Both versions land in the deployment catalog and appear in the
                explorer when the run completes.
              </div>
            </>
          )}

          {/* ─── Vibe Modeling fields ─── */}
          {isVibe && (
            <>
              <div className="space-y-2">
                <label className="text-sm font-medium">Base Version</label>
                {eligibleBaseVersions.length > 0 ? (
                  <Select value={baseVersionId} onValueChange={handleBaseVersionChange}>
                    <SelectTrigger>
                      <SelectValue placeholder="Select a version to apply vibes to" />
                    </SelectTrigger>
                    <SelectContent>
                      {eligibleBaseVersions.map((v) => {
                        const scopeLabel = (v.scope || "mvm").toUpperCase();
                        return (
                          <SelectItem key={v.id} value={v.id}>
                            v{v.version} {scopeLabel}
                            {v.vibe_instructions ? " (vibed)" : ""}
                          </SelectItem>
                        );
                      })}
                    </SelectContent>
                  </Select>
                ) : (
                  <p className="text-sm text-muted-foreground py-2">
                    {isVibeCombined
                      ? "No completed ECM versions available. The combined ECM+MVM run pipes through shrink, which needs an ECM source. Run a new base model first."
                      : "No completed versions available. Create a new base model first."}
                  </p>
                )}
                <p className="text-xs text-muted-foreground">
                  {isVibeCombined
                    ? "Pick the ECM version to vibe. The run regenerates ECM and shrinks to MVM."
                    : "The existing model structure and business context will be loaded from this version."}
                </p>
              </div>

              {baseVersionId && (
                <div className="flex items-center justify-between rounded-md border border-border bg-muted/40 px-3 py-2 text-sm">
                  <span className="text-muted-foreground" data-testid="vibe-inputs-summary">
                    {inputIds.length} vibe input{inputIds.length === 1 ? "" : "s"} selected for this run
                  </span>
                  <Button asChild variant="outline" size="sm">
                    <Link
                      to="/businesses/$businessId/model/$version/$scope/inputs"
                      params={{
                        businessId,
                        version: String(
                          (versions.find((v) => v.id === baseVersionId) as any)?.version ?? "",
                        ),
                        scope:
                          ((versions.find((v) => v.id === baseVersionId) as any)?.scope || "ecm"),
                      }}
                    >
                      Edit inputs
                      <ArrowRight className="h-4 w-4 ml-1.5" />
                    </Link>
                  </Button>
                </div>
              )}

              {/* Model Size only matters for the legacy vibe-iterate intent.
                  vibe-new-ecm-mvm always starts as ECM (Phase 1) and shrinks
                  to MVM (Phase 2) by intent contract, so the user has no
                  choice — hide the combobox to avoid surfacing a knob that
                  the DAG factory ignores. Same logic as new-base-model. */}
              {isVibeIterate && (
                <div className="space-y-2">
                  <label className="text-sm font-medium">Model Size</label>
                  <Select value={modelSize} onValueChange={handleModelSizeChange}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="small model">Small Model (MVM)</SelectItem>
                      <SelectItem value="large model">Large Model (ECM)</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              )}
            </>
          )}

          {/* Advanced Options */}
          {isModelProducing && (
            <div className="border rounded-lg">
              <button
                type="button"
                onClick={() => setAdvancedOpen((v) => !v)}
                className="flex items-center gap-2 w-full px-4 py-2.5 text-sm font-medium text-left hover:bg-muted/50 transition-colors rounded-lg"
              >
                {advancedOpen ? <ChevronDown className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
                Advanced Options
                <span className="text-xs text-muted-foreground font-normal ml-1">
                  Naming, data types, cataloging, tracking
                </span>
              </button>

              {advancedOpen && (
                <div className="px-4 pb-4 space-y-5">
                  {/* Organization */}
                  <fieldset className="space-y-3">
                    <legend className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Organization</legend>
                    <div className="grid grid-cols-2 gap-3">
                      <div className="space-y-1">
                        <label
                          className="text-xs font-medium flex items-center gap-1"
                          title={
                            "Which organisational divisions the agent should cover. " +
                            "Pending confirmation with the agent maintainers whether " +
                            "divisions apply to `Minimum Viable Model - MVM` scope — " +
                            "treat this as informational on small models for now."
                          }
                        >
                          Organization Divisions
                          <span className="text-muted-foreground">(?)</span>
                        </label>
                        <Select
                          value={conventions.org_divisions}
                          onValueChange={(v) => {
                            updateConvention("org_divisions", v);
                            setOrgDivisionsManual(true);
                          }}
                        >
                          <SelectTrigger className="h-8 text-sm">
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            {ORG_DIVISIONS_PRESETS.map((d) => (
                              <SelectItem key={d} value={d}>{d}</SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                        {!orgDivisionsManual && (
                          <p className="text-[10px] text-muted-foreground">
                            Auto-set from model scope
                          </p>
                        )}
                      </div>
                      <div className="space-y-1">
                        <label className="text-xs font-medium">Business Domains</label>
                        <TagInput
                          value={domainTags}
                          onChange={setDomainTags}
                          placeholder="Type a domain, press Enter"
                        />
                        <p className="text-[10px] text-muted-foreground">
                          Comma-separated. Filtered by selected divisions at generation time.
                        </p>
                      </div>
                    </div>
                  </fieldset>

                  {/* Namespace Style — catalog + schema prefix/suffix in one
                      place. The top-level Namespace Style selector above is
                      the authoritative control; these prefixes/suffixes only
                      apply for multi-catalog styles. */}
                  <fieldset className="space-y-3">
                    <legend className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Namespace Style</legend>
                    <div className="grid grid-cols-2 gap-3">
                      <div className="space-y-1">
                        <label className="text-xs font-medium">Catalog Prefix</label>
                        <Input
                          value={conventions.catalog_prefix}
                          onChange={(e) => updateConvention("catalog_prefix", e.target.value)}
                          disabled={isSingleCatalog}
                          className="h-8 text-sm"
                        />
                      </div>
                      <div className="space-y-1">
                        <label className="text-xs font-medium">Catalog Suffix</label>
                        <Input
                          value={conventions.catalog_suffix}
                          onChange={(e) => updateConvention("catalog_suffix", e.target.value)}
                          disabled={isSingleCatalog}
                          className="h-8 text-sm"
                        />
                      </div>
                      {/* Schema Prefix — for `new base model` the unified
                          pipeline needs per-scope prefixes so the ECM and
                          MVM installs don't collide in a shared catalog
                          (#122). Other ops (vibe/shrink/install) still use
                          the single `schema_prefix` legacy field below. */}
                      {isBase ? (
                        <>
                          <div className="space-y-1">
                            <label className="text-xs font-medium">ECM Schema Prefix</label>
                            <Input
                              value={isSingleCatalog ? conventions.ecm_schema_prefix : ""}
                              onChange={(e) => updateConvention("ecm_schema_prefix", e.target.value)}
                              disabled={!isSingleCatalog}
                              placeholder={isSingleCatalog ? "ecm_" : "(per-scope catalog — no prefix)"}
                              className="h-8 text-sm"
                            />
                          </div>
                          <div className="space-y-1">
                            <label className="text-xs font-medium">MVM Schema Prefix</label>
                            <Input
                              value={isSingleCatalog ? conventions.mvm_schema_prefix : ""}
                              onChange={(e) => updateConvention("mvm_schema_prefix", e.target.value)}
                              disabled={!isSingleCatalog}
                              placeholder={isSingleCatalog ? "mvm_" : "(per-scope catalog — no prefix)"}
                              className="h-8 text-sm"
                            />
                          </div>
                        </>
                      ) : (
                        <div className="space-y-1">
                          <label className="text-xs font-medium">Schema Prefix</label>
                          <Input
                            value={conventions.schema_prefix}
                            onChange={(e) => updateConvention("schema_prefix", e.target.value)}
                            className="h-8 text-sm"
                          />
                        </div>
                      )}
                      <div className="space-y-1">
                        <label className="text-xs font-medium">Schema Suffix</label>
                        <Input
                          value={conventions.schema_suffix}
                          onChange={(e) => updateConvention("schema_suffix", e.target.value)}
                          className="h-8 text-sm"
                        />
                      </div>
                    </div>
                    {isSingleCatalog ? (
                      isBase && (
                        <p className="text-[10px] text-muted-foreground">
                          ECM and MVM land in the same catalog on One Catalog, so each scope gets a distinct schema prefix to avoid collisions. Catalog prefix/suffix only apply for "Catalog per Division" / "Catalog per Domain".
                        </p>
                      )
                    ) : (
                      isBase && (
                        <p className="text-[10px] text-muted-foreground">
                          Schema prefixes are disabled: each scope targets its own catalog (`&lt;base&gt;_ecm_v&lt;N&gt;` / `&lt;base&gt;_mvm_v&lt;N&gt;`), so prefixing is unnecessary.
                        </p>
                      )
                    )}
                    {isSingleCatalog && !isBase && (
                      <p className="text-[10px] text-muted-foreground">
                        Catalog prefix/suffix only apply when Namespace Style is
                        "Catalog per Division" or "Catalog per Domain". Change it above to edit those.
                      </p>
                    )}
                  </fieldset>

                  {/* Naming & Format — identifier conventions, excluding the
                      catalog/schema prefix/suffix which belong to Namespace Style. */}
                  <fieldset className="space-y-3">
                    <legend className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Naming &amp; Format</legend>
                    <div className="grid grid-cols-3 gap-3">
                      <div className="space-y-1">
                        <label className="text-xs font-medium">Naming Convention</label>
                        <Select
                          value={conventions.naming_convention}
                          onValueChange={(v) => updateConvention("naming_convention", v)}
                        >
                          <SelectTrigger className="h-8 text-sm">
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            {NAMING_CONVENTIONS.map((n) => (
                              <SelectItem key={n} value={n}>{n}</SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>
                      <div className="space-y-1">
                        <label className="text-xs font-medium">PK Suffix</label>
                        <Input
                          value={conventions.primary_key_suffix}
                          onChange={(e) => updateConvention("primary_key_suffix", e.target.value)}
                          className="h-8 text-sm"
                        />
                      </div>
                      <div className="space-y-1">
                        <label className="text-xs font-medium">Tag Prefix</label>
                        <Input
                          value={conventions.tag_prefix}
                          onChange={(e) => updateConvention("tag_prefix", e.target.value)}
                          className="h-8 text-sm"
                        />
                      </div>
                      <div className="space-y-1">
                        <label className="text-xs font-medium">Tag Suffix</label>
                        <Input
                          value={conventions.tag_suffix}
                          onChange={(e) => updateConvention("tag_suffix", e.target.value)}
                          className="h-8 text-sm"
                        />
                      </div>
                    </div>
                  </fieldset>

                  {/* Data Types */}
                  <fieldset className="space-y-3">
                    <legend className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Data Types</legend>
                    <div className="grid grid-cols-2 gap-3">
                      <div className="space-y-1">
                        <label className="text-xs font-medium">Table ID Type</label>
                        <Select
                          value={conventions.table_id_type}
                          onValueChange={(v) => updateConvention("table_id_type", v)}
                        >
                          <SelectTrigger className="h-8 text-sm">
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            {TABLE_ID_TYPES.map((t) => (
                              <SelectItem key={t} value={t}>{t}</SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>
                      <div className="space-y-1">
                        <label className="text-xs font-medium">Boolean Format</label>
                        <Select
                          value={conventions.boolean_format}
                          onValueChange={(v) => updateConvention("boolean_format", v)}
                        >
                          <SelectTrigger className="h-8 text-sm">
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            {BOOLEAN_FORMATS.map((b) => (
                              <SelectItem key={b} value={b}>{b}</SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>
                      <div className="space-y-1">
                        <label className="text-xs font-medium">Date Format</label>
                        <Input
                          value={conventions.date_format}
                          onChange={(e) => updateConvention("date_format", e.target.value)}
                          className="h-8 text-sm"
                        />
                      </div>
                      <div className="space-y-1">
                        <label className="text-xs font-medium">Timestamp Format</label>
                        <Input
                          value={conventions.timestamp_format}
                          onChange={(e) => updateConvention("timestamp_format", e.target.value)}
                          className="h-8 text-sm"
                        />
                      </div>
                    </div>
                  </fieldset>

                  {/* Tracking & Governance */}
                  <fieldset className="space-y-3">
                    <legend
                      className="text-xs font-semibold text-muted-foreground uppercase tracking-wider flex items-center gap-1 cursor-help"
                      title={
                        "Housekeeping columns (created_at, updated_at, _source), history tracking " +
                        "(SCD-2 valid_from/valid_to), and classification levels tag attributes with " +
                        "data-sensitivity labels. All three feed UC tags at deploy time — the agent " +
                        "applies them per attribute when generating table DDL."
                      }
                    >
                      Tracking &amp; Governance <span className="text-muted-foreground normal-case">(?)</span>
                    </legend>
                    <div className="grid grid-cols-3 gap-3">
                      <div className="space-y-1">
                        <label
                          className="text-xs font-medium cursor-help"
                          title="Adds created_at / updated_at / _source columns to every table."
                        >
                          Housekeeping Columns
                        </label>
                        <Select
                          value={conventions.housekeeping_columns}
                          onValueChange={(v) => updateConvention("housekeeping_columns", v)}
                        >
                          <SelectTrigger className="h-8 text-sm">
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            {YES_NO.map((v) => (
                              <SelectItem key={v} value={v}>{v}</SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>
                      <div className="space-y-1">
                        <label
                          className="text-xs font-medium cursor-help"
                          title="Adds SCD-2 history tracking columns (valid_from / valid_to / is_current)."
                        >
                          History Tracking
                        </label>
                        <Select
                          value={conventions.history_tracking_columns}
                          onValueChange={(v) => updateConvention("history_tracking_columns", v)}
                        >
                          <SelectTrigger className="h-8 text-sm">
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            {YES_NO.map((v) => (
                              <SelectItem key={v} value={v}>{v}</SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>
                      <div className="space-y-1">
                        <label
                          className="text-xs font-medium cursor-help"
                          title={
                            "Classification key=label pairs passed to the agent as UC tags. " +
                            "Format: key1=label1, key2=label2. Whether the agent enforces a " +
                            "restricted set of keys is pending confirmation with maintainers."
                          }
                        >
                          Classification Levels
                        </label>
                        <TagInput
                          value={classificationTags}
                          onChange={setClassificationTags}
                          placeholder="e.g. public=public, press Enter"
                        />
                        <p className="text-[10px] text-muted-foreground">
                          Key=value pairs (e.g. restricted=restricted)
                        </p>
                      </div>
                    </div>
                  </fieldset>

                  {/* Generate Samples */}
                  <div className="flex items-center gap-2 pt-1">
                    <Checkbox
                      id="generateSamples"
                      checked={generateSamples}
                      onCheckedChange={(v) => setGenerateSamples(v === true)}
                    />
                    <label htmlFor="generateSamples" className="text-xs font-medium">
                      Generate sample data (10 rows per table)
                    </label>
                  </div>
                </div>
              )}
            </div>
          )}

          {error && (
            <p className="text-sm text-destructive">{error}</p>
          )}

          {/* Live validate-debounce surface (orchestrator wirer §2.4.1) —
              exercised for new-base-model and vibe-new-ecm-mvm. The
              combined intent surfaces "parent must be ECM scope" here. */}
          {validateEnabled && validateBlockers.length > 0 && (
            <div
              data-testid="validate-blockers"
              className="rounded-md border border-destructive/50 bg-destructive/5 p-3 space-y-1"
            >
              <p className="text-sm font-medium text-destructive">
                Fix the following before submitting:
              </p>
              <ul className="text-xs text-destructive list-disc pl-5">
                {validateBlockers.map((b, i) => (
                  <li key={`${b.field_path}-${i}`}>
                    <span className="font-mono">{b.field_path || "form"}</span>: {b.message}
                  </li>
                ))}
              </ul>
            </div>
          )}
          {validateEnabled && validateWarnings.length > 0 && (
            <div
              data-testid="validate-warnings"
              className="rounded-md border border-amber-500/40 bg-amber-500/5 p-3 space-y-1"
            >
              <p className="text-sm font-medium text-amber-700 dark:text-amber-300">
                Warnings (you can still submit):
              </p>
              <ul className="text-xs text-amber-700 dark:text-amber-300 list-disc pl-5">
                {validateWarnings.map((w, i) => (
                  <li key={`${w.field_path}-${i}`}>
                    <span className="font-mono">{w.field_path || "form"}</span>: {w.message}
                  </li>
                ))}
              </ul>
            </div>
          )}

          {catalogSchemaCount > 0 && catalog && (
            <div
              data-testid="catalog-schema-warning"
              className="rounded-md border border-amber-500/40 bg-amber-500/5 p-3"
            >
              <p className="text-sm text-amber-700 dark:text-amber-300">
                Catalog &lsquo;{catalog}&rsquo; contains {catalogSchemaCount} schema{catalogSchemaCount === 1 ? "" : "s"} from prior deployments; the agent will drop them at run start.
              </p>
            </div>
          )}

          {baseContextMissing && (
            <div
              data-testid="base-context-missing"
              className="rounded-md border border-destructive/50 bg-destructive/5 p-3"
            >
              <p className="text-sm text-destructive">
                {contextMode === "text"
                  ? "Business Context is required — describe the business in the Write tab before starting."
                  : "Business Context is required — provide a model.json file path before starting."}
              </p>
            </div>
          )}

          {vibeContentMissing && (
            <div
              data-testid="vibe-content-missing"
              className="rounded-md border border-destructive/50 bg-destructive/5 p-3"
            >
              <p className="text-sm text-destructive">
                No inputs selected — choose inputs on the Compose surface (Edit inputs) to include in this run.
              </p>
            </div>
          )}

          <div className="flex gap-2 pt-2">
            <Button
              type="submit"
              disabled={
                submitting
                || (isVibe && eligibleBaseVersions.length === 0)
                || (validateEnabled && validateBlockers.length > 0)
                || baseContextMissing
                || vibeContentMissing
              }
            >
              {submitting ? "Starting..." : "Start Run"}
            </Button>
            <Button variant="outline" asChild>
              <Link to="/businesses/$businessId/explorer" params={{ businessId }}>
                Cancel
              </Link>
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
    <LaunchRunDialog
      open={confirmOpen}
      operationType={runType}
      businessName={business?.name ?? "this business"}
      versionLabel={
        isVibe
          ? (() => {
              const v = completedVersions.find((cv) => cv.id === baseVersionId);
              if (!v) return undefined;
              const scopeLabel = (v.scope || "mvm").toUpperCase();
              return `v${v.version} ${scopeLabel}`;
            })()
          : undefined
      }
      submitting={submitting}
      onConfirm={performRun}
      onCancel={() => {
        if (!submitting) setConfirmOpen(false);
      }}
    />
    {isVibe && (
      <div className="sticky top-4 self-start flex max-h-[calc(100vh-2rem)] flex-col gap-2">
        <label className="text-sm font-medium">Compiled instructions preview</label>
        {inputIds.length === 0 ? (
          <div
            data-testid="vibe-inputs-empty-state"
            className="flex flex-col items-start gap-3 rounded-md border border-input bg-muted/30 p-4 text-sm"
          >
            <p className="text-muted-foreground">
              No inputs selected — choose inputs on the Compose surface to include
              in this run.
            </p>
            {baseVersionId && (
              <Button asChild variant="outline" size="sm">
                <Link
                  to="/businesses/$businessId/model/$version/$scope/inputs"
                  params={{
                    businessId,
                    version: String(
                      (versions.find((v) => v.id === baseVersionId) as any)?.version ?? "",
                    ),
                    scope:
                      ((versions.find((v) => v.id === baseVersionId) as any)?.scope || "ecm"),
                  }}
                >
                  Choose inputs on the Compose surface
                  <ArrowRight className="h-4 w-4 ml-1.5" />
                </Link>
              </Button>
            )}
          </div>
        ) : (
          <div className="min-h-0 flex-1 overflow-auto rounded-md border border-input bg-muted/30">
            <CompiledPreview inputs={baseInputs} includedIds={includedInputIds} />
          </div>
        )}
        <p className="text-xs text-muted-foreground">
          Read-only preview of what the agent receives, compiled from the selected
          Vibe Inputs. Use <strong>Edit inputs</strong> to change the selection.
        </p>
      </div>
    )}
    </div>
  );
}
