import type { ComponentType } from "react";
import { Workflow, Keyboard, MessagesSquare, BookOpen, FileUp } from "lucide-react";

/**
 * The in-app help catalogue. One entry per help page; the help index and the
 * "Related" footers both read from this single list so a new page is added in
 * exactly one place. `status: "ready"` pages are fully written; `"soon"`
 * pages render the same template with a coming-soon body.
 */
export interface HelpTopic {
  /** Route path segment under /help (e.g. "flow" → /help/flow). */
  slug: string;
  title: string;
  description: string;
  Icon: ComponentType<{ className?: string }>;
  group: "Getting started" | "Reference";
  status: "ready" | "soon";
}

export const HELP_TOPICS: HelpTopic[] = [
  {
    slug: "flow",
    title: "How the modeling flow works",
    description: "The iterate loop end to end — from a first model to publishing to Unity Catalog.",
    Icon: Workflow,
    group: "Getting started",
    status: "ready",
  },
  {
    slug: "vibes",
    title: "What you can ask the agent (vibes)",
    description: "The kinds of natural-language directives the agent understands, with examples.",
    Icon: MessagesSquare,
    group: "Getting started",
    status: "soon",
  },
  {
    slug: "shortcuts",
    title: "Keyboard shortcuts",
    description: "Every shortcut in the app, grouped by where it works.",
    Icon: Keyboard,
    group: "Reference",
    status: "ready",
  },
  {
    slug: "glossary",
    title: "Glossary",
    description: "Key terms — ECM, MVM, domain, product, attribute, vibe input, and more.",
    Icon: BookOpen,
    group: "Reference",
    status: "soon",
  },
  {
    slug: "import",
    title: "Importing an existing model",
    description: "Bring a pre-vibed model.json (or a Unity Catalog model — forthcoming) into the app.",
    Icon: FileUp,
    group: "Reference",
    status: "soon",
  },
];

export function getHelpTopic(slug: string): HelpTopic | undefined {
  return HELP_TOPICS.find((t) => t.slug === slug);
}
