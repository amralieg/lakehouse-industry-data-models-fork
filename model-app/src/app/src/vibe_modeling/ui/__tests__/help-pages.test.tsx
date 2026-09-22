/**
 * Help center — index + the two fully-written pages (flow, shortcuts) + the
 * shared coming-soon template. Guards the real shortcut content, the flow
 * stages, and the index topic list against drift, and fails on any DOM-nesting
 * warning (the kbd/badge caps sit inside text runs).
 */
import { describe, it, expect } from "vitest";
import { ReactNode } from "react";
import { render, screen } from "@testing-library/react";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";

import { HelpIndexPage } from "@/routes/_sidebar/help.index";
import {
  FlowContent,
  ShortcutsContent,
  ComingSoonContent,
} from "@/components/help/help-content";
import { HELP_TOPICS } from "@/components/help/help-topics";
import { useStrictConsole } from "./helpers/strict-console";

function withRouter(ui: ReactNode) {
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const subject = createRoute({
    getParentRoute: () => rootRoute,
    path: "/",
    component: () => <>{ui}</>,
  });
  const helpIndex = createRoute({
    getParentRoute: () => rootRoute,
    path: "/help",
    component: () => <div data-testid="help-index-stub" />,
  });
  const helpTopic = createRoute({
    getParentRoute: () => rootRoute,
    path: "/help/$topic",
    component: () => <div data-testid="help-topic-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([subject, helpIndex, helpTopic]),
    history: createMemoryHistory({ initialEntries: ["/"] }),
  });
  return <RouterProvider router={router} />;
}

describe("Help index", () => {
  const dom = useStrictConsole();

  it("lists every topic under its group, marking unwritten ones", async () => {
    render(withRouter(<HelpIndexPage />));
    await screen.findByText(HELP_TOPICS[0].title);
    for (const topic of HELP_TOPICS) {
      expect(screen.getByText(topic.title)).toBeInTheDocument();
    }
    expect(screen.getByText("Getting started")).toBeInTheDocument();
    expect(screen.getByText("Reference")).toBeInTheDocument();
    // Three topics are coming-soon.
    expect(screen.getAllByText(/coming soon/i).length).toBeGreaterThanOrEqual(3);
    expect(dom.messages).toEqual([]);
  });
});

describe("Shortcuts page", () => {
  const dom = useStrictConsole();

  it("renders the real shortcuts, grouped, with a context-sensitivity note", async () => {
    render(withRouter(<ShortcutsContent />));
    expect(await screen.findByText("Global")).toBeInTheDocument();
    expect(
      screen.getByText(/Open model search/i),
    ).toBeInTheDocument();
    expect(screen.getByText(/Toggle the sidebar/i)).toBeInTheDocument();
    expect(screen.getByText(/Cancel \/ close the dialog/i)).toBeInTheDocument();
    // Key caps rendered.
    expect(screen.getAllByText("K").length).toBeGreaterThanOrEqual(1);
    expect(screen.getByText("Esc")).toBeInTheDocument();
    expect(screen.getAllByText(/context-sensitive/i).length).toBeGreaterThanOrEqual(1);
    expect(dom.messages).toEqual([]);
  });
});

describe("Flow page", () => {
  const dom = useStrictConsole();

  it("renders the intro and the expanded stage prose", async () => {
    render(withRouter(<FlowContent />));
    expect(
      await screen.findByText(/Here's the loop, end to end/i),
    ).toBeInTheDocument();
    expect(screen.getByText(/Review and give feedback/i)).toBeInTheDocument();
    expect(screen.getByText(/mark domains as reviewed/i)).toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });
});

describe("Coming-soon template", () => {
  const dom = useStrictConsole();

  it("renders a known-but-unwritten topic without looking broken", async () => {
    render(withRouter(<ComingSoonContent slug="glossary" />));
    expect(await screen.findByText("Glossary")).toBeInTheDocument();
    expect(screen.getByText(/coming soon/i)).toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });
});
