/**
 * Re-export shim — the canonical pipeline component is ``RunHierarchyPipeline``
 * which renders a two-level tree (Phase → Step). Tests + consumers that import
 * ``RunPipelineView`` from this path continue to work without a rename.
 */
export { RunHierarchyPipeline as RunPipelineView } from "@/components/runs/run-hierarchy-pipeline";
