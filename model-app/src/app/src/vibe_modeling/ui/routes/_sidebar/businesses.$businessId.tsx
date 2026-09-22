import { createFileRoute, Outlet } from "@tanstack/react-router";
import { useEffect } from "react";
import { setUserPreference } from "@/lib/api";
import { businessVisitKey } from "@/components/home/recent-items";

export const Route = createFileRoute("/_sidebar/businesses/$businessId")({
  component: () => {
    const { businessId } = Route.useParams();

    // Record a per-entity visit so the home "Jump back in" list can order by
    // recency. Version routes nest under this parent, so this fires for
    // business/industry/version entry alike. The upsert bumps `updated_at`.
    useEffect(() => {
      // Fire-and-forget; a failed visit write just means recency won't update.
      void setUserPreference({ key: businessVisitKey(businessId) }, { value: "1" }).catch(() => {});
    }, [businessId]);

    return <Outlet />;
  },
});
