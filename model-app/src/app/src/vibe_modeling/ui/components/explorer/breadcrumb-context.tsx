import { createContext, useContext, useState, useEffect, type ReactNode } from "react";

interface Crumb {
  label: string;
  to?: string;
  params?: Record<string, string>;
  search?: Record<string, string>;
}

interface BreadcrumbContextType {
  items: Crumb[];
  setItems: (items: Crumb[]) => void;
}

const BreadcrumbContext = createContext<BreadcrumbContextType>({
  items: [],
  setItems: () => {},
});

export function BreadcrumbProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<Crumb[]>([]);
  return (
    <BreadcrumbContext.Provider value={{ items, setItems }}>
      {children}
    </BreadcrumbContext.Provider>
  );
}

/** Set breadcrumb items from a route component. Clears on unmount.
 *  Callers pass a fresh array literal each render, so a referential
 *  dep would fire the effect every render. Stringifying the items
 *  gives a deep-equal dep at the cost of one JSON serialise per
 *  render — fine for breadcrumb-sized payloads, and stable across
 *  re-renders that didn't change crumb content. */
export function useBreadcrumbs(items: Crumb[]) {
  const { setItems } = useContext(BreadcrumbContext);
  // eslint-disable-next-line react-hooks/exhaustive-deps -- intentional deep-equal dep via JSON.stringify
  useEffect(() => {
    setItems(items);
    return () => setItems([]);
  }, [JSON.stringify(items)]);
}

export function useBreadcrumbItems() {
  return useContext(BreadcrumbContext).items;
}
