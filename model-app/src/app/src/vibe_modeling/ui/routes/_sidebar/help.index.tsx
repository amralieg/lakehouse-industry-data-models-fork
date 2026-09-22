import { createFileRoute, Link } from "@tanstack/react-router";
import { ArrowRight } from "lucide-react";
import { HELP_TOPICS, type HelpTopic } from "@/components/help/help-topics";
import { Badge } from "@/components/ui/badge";

export const Route = createFileRoute("/_sidebar/help/")({
  component: HelpIndexPage,
});

const GROUP_ORDER: HelpTopic["group"][] = ["Getting started", "Reference"];

function TopicCard({ topic }: { topic: HelpTopic }) {
  const isSoon = topic.status === "soon";
  return (
    <Link
      to="/help/$topic"
      params={{ topic: topic.slug }}
      className="group flex items-start gap-3 rounded-md border border-border bg-card p-4 transition-colors hover:border-input hover:bg-accent"
    >
      <span className="mt-0.5 flex h-9 w-9 shrink-0 items-center justify-center rounded-sm border border-border bg-muted text-muted-foreground">
        <topic.Icon className="h-4 w-4" />
      </span>
      <div className="min-w-0 flex-1">
        <div className="flex items-center gap-2">
          <span className="text-sm font-medium">{topic.title}</span>
          {isSoon && (
            <Badge variant="outline" className="text-[10px] text-muted-foreground">
              Coming soon
            </Badge>
          )}
        </div>
        <p className="mt-0.5 text-xs leading-snug text-muted-foreground">
          {topic.description}
        </p>
      </div>
      <ArrowRight className="mt-1 h-4 w-4 shrink-0 text-muted-foreground opacity-0 transition-opacity group-hover:opacity-100" />
    </Link>
  );
}

export function HelpIndexPage() {
  return (
    <div className="mx-auto w-full max-w-3xl px-6 py-8">
      <header className="mb-8">
        <h1 className="text-2xl font-semibold tracking-tight">Help</h1>
        <p className="mt-2 max-w-[68ch] text-sm leading-relaxed text-muted-foreground">
          How Model Foundry works, and how to move quickly in it. Start with the
          modeling flow if you're new; use the reference pages to look things up.
        </p>
      </header>

      <div className="space-y-8">
        {GROUP_ORDER.map((group) => {
          const topics = HELP_TOPICS.filter((t) => t.group === group);
          if (topics.length === 0) return null;
          return (
            <section key={group}>
              <h2 className="mb-3 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                {group}
              </h2>
              <div className="grid gap-3 sm:grid-cols-2">
                {topics.map((t) => (
                  <TopicCard key={t.slug} topic={t} />
                ))}
              </div>
            </section>
          );
        })}
      </div>
    </div>
  );
}
