import { StrictMode } from "react";
import { createRoot } from "react-dom/client";

import "@/styles/globals.css";
import { routeTree } from "@/types/routeTree.gen";

import { RouterProvider, createRouter } from "@tanstack/react-router";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

// Create a new query client with sensible defaults: cache responses for 30s
// before refetching, and retry once on error. Without these, every render of
// a component subscribed to a 4xx-erroring query re-fetches in a tight loop,
// blanking pages whose tree includes such queries.
//
// `refetchOnWindowFocus: false` is intentional, not a default. Several forms
// (notably the New Run form, the model-versioning work fix M) keep `useState`-managed text
// content the user has typed but not yet submitted. The default React Query
// behaviour refetches suspense queries on window-focus events, which can
// briefly re-suspend the component tree and remount the form — wiping any
// unsaved typed content. We disable focus-driven refetches globally so
// in-progress forms survive popover/dropdown focus changes.
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30 * 1000,
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

const router = createRouter({
  routeTree,
  context: {
    queryClient,
  },
  defaultPreload: "intent",
  // Since we're using React Query, we don't want loader calls to ever be stale
  // This will ensure that the loader is always called when the route is preloaded or visited
  defaultPreloadStaleTime: 0,
  scrollRestoration: true,
});

// Register things for typesafety
declare module "@tanstack/react-router" {
  interface Register {
    router: typeof router;
  }
}

const rootElement = document.getElementById("root")!;

if (!rootElement.innerHTML) {
  const root = createRoot(rootElement);
  root.render(
    <StrictMode>
      <QueryClientProvider client={queryClient}>
        <RouterProvider router={router} />
      </QueryClientProvider>
    </StrictMode>,
  );
}
