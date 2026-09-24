import { ThemeProvider } from "@/components/apx/theme-provider";
import { QueryClient } from "@tanstack/react-query";
import { createRootRouteWithContext, Outlet } from "@tanstack/react-router";
import { Toaster } from "sonner";
import { ErrorDetailsHost } from "@/components/error-details-host";

export const Route = createRootRouteWithContext<{
  queryClient: QueryClient;
}>()({
  component: () => (
    <ThemeProvider defaultTheme="dark" storageKey="apx-ui-theme">
      <Outlet />
      <Toaster richColors toastOptions={{ closeButton: true }} />
      <ErrorDetailsHost />
    </ThemeProvider>
  ),
});
