import { createFileRoute, Outlet } from "@tanstack/react-router";

export const Route = createFileRoute(
  "/_sidebar/businesses/$businessId/model/$version"
)({
  component: () => <Outlet />,
});
