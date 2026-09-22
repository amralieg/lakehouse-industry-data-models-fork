import { Link } from "@tanstack/react-router";
import { Construction } from "lucide-react";
import { HelpPage } from "@/components/help/help-page";
import { WorkflowDiagram } from "@/components/flow/workflow-diagram";
import { getHelpTopic } from "@/components/help/help-topics";

/** A single key cap, styled as a physical key. */
export function Kbd({ children }: { children: React.ReactNode }) {
  return (
    <kbd className="inline-flex h-6 min-w-[1.5rem] items-center justify-center rounded-sm border border-border bg-muted px-1.5 text-xs font-medium text-foreground">
      {children}
    </kbd>
  );
}

interface Shortcut {
  keys: string[];
  /** Rendered between key caps (e.g. "then", "+"). Defaults to "+". */
  joiner?: string;
  description: string;
}

interface ShortcutGroup {
  heading: string;
  note?: string;
  shortcuts: Shortcut[];
}

/** The app's real shortcuts, verbatim from the help-system brief. */
const SHORTCUT_GROUPS: ShortcutGroup[] = [
  {
    heading: "Global",
    shortcuts: [
      { keys: ["⌘ / Ctrl", "K"], description: "Open model search (jump to any domain, product, or attribute)" },
      { keys: ["⌘ / Ctrl", "B"], description: "Toggle the sidebar" },
      { keys: ["f"], description: "Add feedback / vibe input (when viewing a model)" },
    ],
  },
  {
    heading: "Editing (in an input or comment box)",
    shortcuts: [
      { keys: ["⌘ / Ctrl", "Enter"], description: "Save / submit" },
      { keys: ["Esc"], description: "Cancel / close the dialog" },
    ],
  },
];

function ShortcutRow({ shortcut }: { shortcut: Shortcut }) {
  const joiner = shortcut.joiner ?? "+";
  return (
    <div className="flex items-baseline justify-between gap-4 border-b border-border py-2 last:border-b-0">
      <span className="text-sm text-muted-foreground">{shortcut.description}</span>
      <span className="flex shrink-0 items-center gap-1">
        {shortcut.keys.map((k, i) => (
          <span key={i} className="flex items-center gap-1">
            {i > 0 && <span className="text-xs text-muted-foreground">{joiner}</span>}
            <Kbd>{k}</Kbd>
          </span>
        ))}
      </span>
    </div>
  );
}

export function ShortcutsContent() {
  return (
    <HelpPage
      title="Keyboard shortcuts"
      intro="Move faster with the keyboard. Shortcuts are context-sensitive — some only fire in a particular view."
      related={["flow"]}
    >
      <div className="space-y-8">
        {SHORTCUT_GROUPS.map((group) => (
          <section key={group.heading}>
            <h2 className="mb-1 text-sm font-semibold">{group.heading}</h2>
            {group.note && (
              <p className="mb-2 text-xs text-muted-foreground">{group.note}</p>
            )}
            <div className="rounded-sm border border-border px-3">
              {group.shortcuts.map((s, i) => (
                <ShortcutRow key={i} shortcut={s} />
              ))}
            </div>
          </section>
        ))}
        <p className="text-xs text-muted-foreground">
          Shortcuts are context-sensitive: <Kbd>f</Kbd> only fires while viewing a
          model, not while you are typing in an input or comment box.
        </p>
      </div>
    </HelpPage>
  );
}

export function FlowContent() {
  return (
    <HelpPage
      title="How the modeling flow works"
      intro="You shape a data model by giving an AI agent feedback and re-running. Here's the loop, end to end."
      related={["shortcuts", "vibes"]}
    >
      <WorkflowDiagram variant="expanded" className="mt-2" />
    </HelpPage>
  );
}

/** Shared coming-soon body for topics that share the template but aren't
 *  written yet. Reads the topic's own title/description from the registry. */
export function ComingSoonContent({ slug }: { slug: string }) {
  const topic = getHelpTopic(slug);
  return (
    <HelpPage
      title={topic?.title ?? "Help"}
      intro={topic?.description}
      related={["flow", "shortcuts"]}
    >
      <div className="flex items-start gap-3 rounded-sm border border-dashed border-border bg-muted/40 p-4">
        <Construction className="mt-0.5 h-5 w-5 shrink-0 text-muted-foreground" />
        <div className="space-y-1">
          <p className="text-sm font-medium">This page is coming soon.</p>
          <p className="text-sm text-muted-foreground">
            We're still writing it. In the meantime,{" "}
            <Link to="/help/$topic" params={{ topic: "flow" }} className="text-primary hover:underline">
              How the modeling flow works
            </Link>{" "}
            covers the end-to-end loop, and the{" "}
            <Link to="/help" className="text-primary hover:underline">
              help index
            </Link>{" "}
            lists everything available today.
          </p>
        </div>
      </div>
    </HelpPage>
  );
}
