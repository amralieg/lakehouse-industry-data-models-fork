import { createFileRoute, useNavigate } from "@tanstack/react-router";
import React from "react";

export const Route = createFileRoute("/_sidebar/businesses/$businessId/")({
  component: () => {
    const { businessId } = Route.useParams();
    const navigate = useNavigate();
    React.useEffect(() => {
      navigate({
        to: "/businesses/$businessId/explorer",
        params: { businessId },
        replace: true,
      });
    }, [businessId, navigate]);
    return null;
  },
});
