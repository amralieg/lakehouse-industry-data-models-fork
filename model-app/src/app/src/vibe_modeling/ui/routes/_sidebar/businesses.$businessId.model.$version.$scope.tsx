import { createFileRoute, Outlet } from "@tanstack/react-router";

/**
 * Outlet route for `(version, scope)` model pages. The `$scope` segment is
 * passed through to children via `Route.useParams()`. Validation against
 * the {ecm, mvm} set happens at the leaf components rather than here so a
 * stale link surfaces a useful error message in the page rather than a
 * router-level catch.
 */
export const Route = createFileRoute(
  "/_sidebar/businesses/$businessId/model/$version/$scope"
)({
  component: () => <Outlet />,
});
