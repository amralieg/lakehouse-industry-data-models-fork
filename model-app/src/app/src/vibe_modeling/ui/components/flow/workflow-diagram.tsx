import type { ComponentType } from "react";
import { useLayoutEffect, useRef, useState } from "react";
import {
  ArrowRight,
  RotateCcw,
  UploadCloud,
  Sparkles,
  Network,
  ListChecks,
  Play,
  GitCompareArrows,
} from "lucide-react";
import { cn } from "@/lib/utils";

/**
 * The canonical modeling-loop stages, shared by the home-page orientation
 * strip and the `/help/flow` page so the two diagrams read as the same
 * picture (the help version is the expanded telling). `phrase` is the terse
 * home-strip supporting line; `prose` is the fuller help-page paragraph.
 * Content is taken verbatim from the home-page and help-system briefs.
 */
export interface WorkflowStage {
  n: number;
  label: string;
  phrase: string;
  prose: string;
  Icon: ComponentType<{ className?: string }>;
}

export const WORKFLOW_STAGES: WorkflowStage[] = [
  {
    n: 1,
    label: "Start your model",
    phrase: "start from a template, an import, or a business description",
    prose:
      "Begin from an industry template (a Databricks published model), import an existing model, or describe a new business. The template is a starting line, not a finished model - it needs to be taught your terminology, products, processes and channels.",
    Icon: Sparkles,
  },
  {
    n: 2,
    label: "Review and give feedback",
    phrase: "Navigate the model and give anchored feedback",
    prose:
      "Explore domains, products (tables), attributes (columns), and the foreign-key relationships between them - via the diagram, ontology, explorer, and statistics views. As you go, attach descriptive feedback to any element - a domain, table, column, relationship, or the whole model. Nothing is lost to a chat log - every directive is captured, structured, and element-anchored.",
    Icon: Network,
  },
  {
    n: 3,
    label: "Curate vibes",
    phrase: "pick the inputs for the next run",
    prose:
      "Review all the pending feedbacks (yours plus the agent's suggested next steps) and select which go into the next run. Unused feedbacks can be reviewed and applied on later runs.",
    Icon: ListChecks,
  },
  {
    n: 4,
    label: "Re-run",
    phrase: "the agent produces a new version",
    prose:
      "The agent applies the selected inputs and produces a new model version, so every iteration is preserved and comparable to the previous one.",
    Icon: Play,
  },
  {
    n: 5,
    label: "Review what changed",
    phrase: "see the diff; mark domains reviewed",
    prose:
      "See the diff, mark domains as reviewed, and converge. Repeat the loop until the model reflects your business - then publish to Unity Catalog.",
    Icon: GitCompareArrows,
  },
];

/** Compact node used in the horizontal home-page strip. */
function StripNode({ stage }: { stage: WorkflowStage }) {
  const { Icon } = stage;
  return (
    <li className="flex min-w-0 flex-1 basis-[8rem] flex-col gap-1.5">
      <div className="flex items-center gap-2">
        <span className="flex h-7 w-7 shrink-0 items-center justify-center rounded-sm border border-border bg-muted text-muted-foreground">
          <Icon className="h-3.5 w-3.5" />
        </span>
        <span className="text-[10px] font-mono text-muted-foreground">
          {String(stage.n).padStart(2, "0")}
        </span>
      </div>
      <div className="min-w-0">
        <div className="text-sm font-medium leading-tight">{stage.label}</div>
        <div className="text-xs text-muted-foreground leading-snug">
          {stage.phrase}
        </div>
      </div>
    </li>
  );
}

/**
 * Terminal "Publish" node for the home-page strip. Same node visual as a
 * step (icon square + label + sub) but solid-filled and un-numbered so it
 * reads as the destination the loop feeds into, not another loop step and
 * not a clickable control.
 */
function TerminalStripNode() {
  return (
    <li className="flex min-w-0 flex-1 basis-[8rem] flex-col gap-1.5">
      <div className="flex items-center gap-2">
        <span className="flex h-7 w-7 shrink-0 items-center justify-center rounded-sm border border-foreground bg-foreground text-background">
          <UploadCloud className="h-3.5 w-3.5" />
        </span>
      </div>
      <div className="min-w-0">
        <div className="text-sm font-medium leading-tight">Publish</div>
        <div className="text-xs text-muted-foreground leading-snug">
          to Unity Catalog
        </div>
      </div>
    </li>
  );
}

/**
 * The workflow loop as a glanceable diagram. `variant="strip"` is the
 * terse, horizontal home-page band; `variant="expanded"` is the vertical,
 * prose-per-stage telling used on the help flow page.
 */
export function WorkflowDiagram({
  variant = "strip",
  className,
}: {
  variant?: "strip" | "expanded";
  className?: string;
}) {
  // Icon-column size (h-10/w-10) the loop-rail geometry is tuned to; kept next
  // to the geometry so an icon-size change is caught here.
  const wrapperRef = useRef<HTMLDivElement>(null);
  const firstLoopIconRef = useRef<HTMLSpanElement>(null);
  const lastLoopIconRef = useRef<HTMLSpanElement>(null);
  // Measured loop-rail geometry: x = loop-step icon left edge, y2/y5 = the
  // icon centers of the first and last loop steps, all relative to the
  // wrapper. Measuring (rather than fixed CSS insets) keeps the rail anchored
  // to the icon centers even when a step's prose wraps to several lines.
  const [rail, setRail] = useState<{ x: number; y2: number; y5: number } | null>(
    null,
  );

  useLayoutEffect(() => {
    const measure = () => {
      const wrap = wrapperRef.current;
      const first = firstLoopIconRef.current;
      const last = lastLoopIconRef.current;
      if (!wrap || !first || !last) return;
      const w = wrap.getBoundingClientRect();
      const a = first.getBoundingClientRect();
      const b = last.getBoundingClientRect();
      setRail({
        x: a.left - w.left,
        y2: a.top - w.top + a.height / 2,
        y5: b.top - w.top + b.height / 2,
      });
    };
    measure();
    const ro = new ResizeObserver(measure);
    if (wrapperRef.current) ro.observe(wrapperRef.current);
    window.addEventListener("resize", measure);
    return () => {
      ro.disconnect();
      window.removeEventListener("resize", measure);
    };
  }, [variant]);

  if (variant === "expanded") {
    const loopStart = 1; // step 02 is the first loop step
    return (
      <div className={cn("space-y-3", className)}>
        <div ref={wrapperRef} className="relative">
          {/* Loop rail: 05 back to 02, drawn as an SVG path between the two
              icon centers in the left gutter. aria-hidden - the loop meaning
              is carried by the visible caption below. */}
          <svg
            aria-hidden
            className="pointer-events-none absolute inset-0 h-full w-full overflow-visible"
          >
            {rail && (
              <>
                <path
                  d={`M ${rail.x} ${rail.y5} H 14 V ${rail.y2} H ${rail.x}`}
                  className="stroke-border"
                  fill="none"
                  strokeWidth={1.5}
                  strokeDasharray="4 3"
                  strokeLinejoin="round"
                />
                <path
                  d={`M ${rail.x - 6} ${rail.y2 - 4} L ${rail.x} ${rail.y2} L ${rail.x - 6} ${rail.y2 + 4}`}
                  className="stroke-border"
                  fill="none"
                  strokeWidth={1.5}
                  strokeLinejoin="round"
                  strokeLinecap="round"
                />
              </>
            )}
          </svg>
          <ol className="space-y-3 pl-10">
            {WORKFLOW_STAGES.map((stage, i) => {
              const { Icon } = stage;
              return (
                <li key={stage.n} className="relative flex gap-4">
                  {/* Connector down the icon column; the last step's connector
                      continues into the Publish terminal below. */}
                  <span
                    aria-hidden
                    className="absolute left-[19px] top-10 bottom-[-0.75rem] w-px bg-border"
                  />
                  <span
                    ref={
                      i === loopStart
                        ? firstLoopIconRef
                        : i === WORKFLOW_STAGES.length - 1
                          ? lastLoopIconRef
                          : undefined
                    }
                    className="relative z-10 flex h-10 w-10 shrink-0 items-center justify-center rounded-sm border border-border bg-muted text-muted-foreground"
                  >
                    <Icon className="h-4 w-4" />
                  </span>
                  <div className="min-w-0 flex-1 pt-0.5">
                    <div className="flex items-baseline gap-2">
                      <span className="text-[11px] font-mono text-muted-foreground">
                        {String(stage.n).padStart(2, "0")}
                      </span>
                      <h3 className="text-sm font-semibold">{stage.label}</h3>
                    </div>
                    <p className="mt-1 max-w-[68ch] text-sm leading-relaxed text-muted-foreground">
                      {stage.prose}
                    </p>
                  </div>
                </li>
              );
            })}
            {/* Publish terminal node - solid, un-numbered; the flow ends here. */}
            <li className="relative flex gap-4">
              <span className="relative z-10 flex h-10 w-10 shrink-0 items-center justify-center rounded-sm border border-foreground bg-foreground text-background">
                <UploadCloud className="h-4 w-4" />
              </span>
              <div className="min-w-0 flex-1 pt-0.5">
                <h3 className="text-sm font-semibold">Publish</h3>
                <p className="mt-1 max-w-[68ch] text-sm leading-relaxed text-muted-foreground">
                  Publish to Unity Catalog
                </p>
              </div>
            </li>
          </ol>
          <p className="mt-3 flex items-center gap-1.5 pl-10 text-xs text-muted-foreground">
            <RotateCcw aria-hidden className="h-3.5 w-3.5 shrink-0" />
            <span>
              Step 05 loops back to step 02 - repeat until it reflects your
              business.
            </span>
          </p>
        </div>
      </div>
    );
  }

  // strip
  return (
    <div className={cn("space-y-3", className)}>
      <ol className="flex flex-wrap items-stretch gap-x-2 gap-y-4">
        {WORKFLOW_STAGES.map((stage) => (
          <div
            key={stage.n}
            className="flex min-w-0 flex-1 basis-[8rem] items-start gap-2"
          >
            <StripNode stage={stage} />
            <ArrowRight
              aria-hidden
              className="mt-1 hidden h-4 w-4 shrink-0 text-border sm:block"
            />
          </div>
        ))}
        {/* Publish is where the loop lands - a terminal node, not a pill. */}
        <div className="flex min-w-0 flex-1 basis-[8rem] items-start gap-2">
          <TerminalStripNode />
        </div>
      </ol>
      <div className="flex flex-wrap items-center gap-2 border-t border-dashed border-border pt-3 text-xs text-muted-foreground">
        <RotateCcw aria-hidden className="h-3.5 w-3.5" />
        <span>
          Step 05 loops back to step 02 - repeat until it reflects your
          business.
        </span>
      </div>
    </div>
  );
}

export default WorkflowDiagram;
