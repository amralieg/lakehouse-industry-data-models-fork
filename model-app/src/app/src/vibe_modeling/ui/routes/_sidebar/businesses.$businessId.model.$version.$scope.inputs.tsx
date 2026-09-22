import { createFileRoute, Outlet } from "@tanstack/react-router";

/** Outlet for the Vibe Inputs compose surface + its card-details child. */
export const Route = createFileRoute(
  "/_sidebar/businesses/$businessId/model/$version/$scope/inputs",
)({
  component: () => <Outlet />,
});
