import type { ReactNode } from "react";
import { Link } from "@tanstack/react-router";
import { ArrowLeft, ArrowRight } from "lucide-react";
import { HELP_TOPICS, type HelpTopic } from "@/components/help/help-topics";

/**
 * Shared reading template for every help content page: a back-to-index
 * affordance, a title, an optional intro line, the body, and optional
 * "Related" links. A calm, document-like surface (comfortable ~68ch measure)
 * distinct from the dense working screens but built on the same tokens.
 */
export function HelpPage({
  title,
  intro,
  children,
  related,
}: {
  title: string;
  intro?: string;
  children: ReactNode;
  /** Slugs of related topics to surface at the foot of the page. */
  related?: string[];
}) {
  const relatedTopics: HelpTopic[] = (related ?? [])
    .map((slug) => HELP_TOPICS.find((t) => t.slug === slug))
    .filter((t): t is HelpTopic => Boolean(t));

  return (
    <div className="mx-auto w-full max-w-3xl px-6 py-8">
      <Link
        to="/help"
        className="mb-6 inline-flex items-center gap-1.5 text-sm text-muted-foreground transition-colors hover:text-foreground"
      >
        <ArrowLeft className="h-3.5 w-3.5" />
        All help topics
      </Link>

      <header className="mb-6">
        <h1 className="text-2xl font-semibold tracking-tight">{title}</h1>
        {intro && (
          <p className="mt-2 max-w-[68ch] text-sm leading-relaxed text-muted-foreground">
            {intro}
          </p>
        )}
      </header>

      <div className="max-w-[68ch] text-sm leading-relaxed">{children}</div>

      {relatedTopics.length > 0 && (
        <footer className="mt-10 border-t border-border pt-4">
          <div className="mb-2 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
            Related
          </div>
          <ul className="space-y-1">
            {relatedTopics.map((t) => (
              <li key={t.slug}>
                <Link
                  to="/help/$topic"
                  params={{ topic: t.slug }}
                  className="inline-flex items-center gap-1.5 text-sm text-primary hover:underline"
                >
                  <t.Icon className="h-3.5 w-3.5" />
                  {t.title}
                  <ArrowRight className="h-3 w-3" />
                </Link>
              </li>
            ))}
          </ul>
        </footer>
      )}
    </div>
  );
}

export default HelpPage;
