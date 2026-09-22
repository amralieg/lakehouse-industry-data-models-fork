/**
 * `ProductTypeLegend` swatch-row tests.
 *
 * The legend mirrors `PRODUCT_TYPE_COLORS`: four canonical product
 * types (Master / Transactional / Reference / Association) plus an
 * explicit "Other" swatch for the gray default. We assert every label
 * renders and the swatch backgrounds match the source-of-truth hex
 * values.
 */
import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";

import { ProductTypeLegend } from "@/components/diagram/product-type-legend";
import { PRODUCT_TYPE_COLORS } from "@/components/diagram/constants";

describe("ProductTypeLegend", () => {
  it("renders 5 swatches with colors matching PRODUCT_TYPE_COLORS", () => {
    const { container } = render(<ProductTypeLegend />);

    const expected: { label: string; hex: string }[] = [
      { label: "Master", hex: PRODUCT_TYPE_COLORS.Master.hex },
      { label: "Transactional", hex: PRODUCT_TYPE_COLORS.Transactional.hex },
      { label: "Reference", hex: PRODUCT_TYPE_COLORS.Reference.hex },
      { label: "Association", hex: PRODUCT_TYPE_COLORS.Association.hex },
      { label: "Other", hex: PRODUCT_TYPE_COLORS.default.hex },
    ];

    for (const { label } of expected) {
      expect(screen.getByText(label)).toBeInTheDocument();
    }

    // Five swatches: each is an inline-block span with a background-color
    // style. Query them via the rounded-sm class used for the swatch.
    const swatches = container.querySelectorAll<HTMLElement>(".rounded-sm");
    expect(swatches.length).toBe(expected.length);
    expected.forEach(({ hex }, i) => {
      // jsdom normalizes the inline style to the literal value we set;
      // CSS hex strings stay as-is.
      expect(swatches[i].style.backgroundColor).toBe(hexToRgb(hex));
    });
  });
});

/**
 * jsdom converts inline `background-color: #xxxxxx` to the RGB form
 * when read back via `.style.backgroundColor`. Convert hex → "rgb(r, g, b)"
 * to compare against what jsdom returns.
 */
function hexToRgb(hex: string): string {
  const h = hex.replace("#", "");
  const r = parseInt(h.slice(0, 2), 16);
  const g = parseInt(h.slice(2, 4), 16);
  const b = parseInt(h.slice(4, 6), 16);
  return `rgb(${r}, ${g}, ${b})`;
}
