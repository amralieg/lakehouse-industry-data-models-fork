import { PRODUCT_TYPE_COLORS } from "./constants";

const LEGEND_ENTRIES: { label: string; hex: string }[] = [
  { label: "Master", hex: PRODUCT_TYPE_COLORS.Master.hex },
  { label: "Transactional", hex: PRODUCT_TYPE_COLORS.Transactional.hex },
  { label: "Reference", hex: PRODUCT_TYPE_COLORS.Reference.hex },
  { label: "Association", hex: PRODUCT_TYPE_COLORS.Association.hex },
  { label: "Other", hex: PRODUCT_TYPE_COLORS.default.hex },
];

/**
 * Horizontal swatch legend for the product-type colors used in the
 * Diagram and Ontology tabs. The "Other" entry covers the gray
 * fallback for product types outside the canonical four.
 */
export function ProductTypeLegend({ className }: { className?: string }) {
  return (
    <div
      className={
        className ?? "flex items-center gap-3 text-[11px] text-muted-foreground"
      }
    >
      {LEGEND_ENTRIES.map(({ label, hex }) => (
        <span key={label} className="flex items-center gap-1">
          <span
            className="inline-block w-2.5 h-2.5 rounded-sm"
            style={{ backgroundColor: hex }}
          />
          {label}
        </span>
      ))}
    </div>
  );
}
