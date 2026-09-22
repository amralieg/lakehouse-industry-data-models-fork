import { createFileRoute } from "@tanstack/react-router";
import {
  FlowContent,
  ShortcutsContent,
  ComingSoonContent,
} from "@/components/help/help-content";
import { getHelpTopic } from "@/components/help/help-topics";
import { HelpPage } from "@/components/help/help-page";

export const Route = createFileRoute("/_sidebar/help/$topic")({
  component: HelpTopicPage,
});

function HelpTopicPage() {
  const { topic } = Route.useParams();

  if (topic === "flow") return <FlowContent />;
  if (topic === "shortcuts") return <ShortcutsContent />;

  // Known-but-unwritten topics render the shared coming-soon template.
  if (getHelpTopic(topic)) return <ComingSoonContent slug={topic} />;

  // Unknown slug — keep the reading chrome, don't crash.
  return (
    <HelpPage title="Topic not found" related={["flow", "shortcuts"]}>
      <p className="text-sm text-muted-foreground">
        We couldn't find that help topic. It may have moved or been renamed.
      </p>
    </HelpPage>
  );
}
