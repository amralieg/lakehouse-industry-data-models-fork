/**
 * Runtime access to the diagram palette defined in globals.css.
 *
 * SVG and canvas layers can't use Tailwind utility classes, but they can read
 * CSS custom properties. This module resolves the `--diagram-*` variables off
 * the document root once and memoizes them, then exposes the palette in the
 * shapes the diagram components consume (hex strings, and rgba fills derived
 * from a base hex at a fixed opacity).
 */

/**
 * Fallback hex values, kept identical to the `--diagram-*` definitions in
 * globals.css. They are used only when `getComputedStyle` can't resolve a
 * variable — chiefly jsdom, which doesn't load the stylesheet. In the browser
 * the CSS variable always wins, so globals.css stays the single source.
 */
export const FALLBACKS: Record<string, string> = {
  "--diagram-product-master": "#3b82f6",
  "--diagram-product-transactional": "#10b981",
  "--diagram-product-reference": "#f59e0b",
  "--diagram-product-association": "#8b5cf6",
  "--diagram-product-default": "#6b7280",
  "--diagram-domain-1": "#3b82f6",
  "--diagram-domain-2": "#10b981",
  "--diagram-domain-3": "#f59e0b",
  "--diagram-domain-4": "#8b5cf6",
  "--diagram-domain-5": "#ec4899",
  "--diagram-domain-6": "#14b8a6",
  "--diagram-domain-7": "#f97316",
  "--diagram-domain-8": "#6366f1",
  "--diagram-domain-9": "#eab308",
  "--diagram-domain-10": "#a855f7",
  "--diagram-domain-11": "#06b6d4",
  "--diagram-domain-12": "#f43f5e",
  "--diagram-domain-external": "#9ca3af",
  "--diagram-edge": "#64748b",
  "--diagram-edge-selected": "#3b82f6",
  "--diagram-edge-intra": "#94a3b8",
  "--diagram-edge-cross": "#a855f7",
  "--diagram-edge-highlight": "#e94560",
  "--diagram-selection": "#ef4444",
  "--diagram-cross-domain-highlight": "#eab308",
  "--diagram-node-stroke-selected": "#ffffff",
  "--diagram-pk-icon": "#f59e0b",
  "--diagram-fk-icon": "#3b82f6",
  "--diagram-handle-fk-bg": "#60a5fa",
  "--diagram-handle-fk-border": "#3b82f6",
  "--diagram-handle-pk-bg": "#fbbf24",
  "--diagram-handle-pk-border": "#f59e0b",
};

function readVar(name: string): string {
  if (typeof document !== "undefined") {
    const resolved = getComputedStyle(document.documentElement)
      .getPropertyValue(name)
      .trim();
    if (resolved) return resolved;
  }
  return FALLBACKS[name] ?? "";
}

export function hexToRgba(hex: string, alpha: number): string {
  const h = hex.replace("#", "");
  const full =
    h.length === 3
      ? h.split("").map((c) => c + c).join("")
      : h;
  const r = parseInt(full.slice(0, 2), 16);
  const g = parseInt(full.slice(2, 4), 16);
  const b = parseInt(full.slice(4, 6), 16);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

let cache: ReturnType<typeof build> | null = null;

function build() {
  const domainHexes = [
    readVar("--diagram-domain-1"),
    readVar("--diagram-domain-2"),
    readVar("--diagram-domain-3"),
    readVar("--diagram-domain-4"),
    readVar("--diagram-domain-5"),
    readVar("--diagram-domain-6"),
    readVar("--diagram-domain-7"),
    readVar("--diagram-domain-8"),
    readVar("--diagram-domain-9"),
    readVar("--diagram-domain-10"),
    readVar("--diagram-domain-11"),
    readVar("--diagram-domain-12"),
  ];

  const externalHex = readVar("--diagram-domain-external");

  return {
    productType: {
      master: readVar("--diagram-product-master"),
      transactional: readVar("--diagram-product-transactional"),
      reference: readVar("--diagram-product-reference"),
      association: readVar("--diagram-product-association"),
      default: readVar("--diagram-product-default"),
    },
    domainPalette: domainHexes.map((hex) => ({
      bg: hexToRgba(hex, 0.15),
      border: hexToRgba(hex, 0.45),
      label: hex,
    })),
    externalDomain: {
      bg: hexToRgba(externalHex, 0.04),
      border: hexToRgba(externalHex, 0.4),
      label: externalHex,
      borderStyle: "dashed" as const,
    },
    edge: readVar("--diagram-edge"),
    edgeSelected: readVar("--diagram-edge-selected"),
    edgeIntra: readVar("--diagram-edge-intra"),
    edgeCross: readVar("--diagram-edge-cross"),
    edgeHighlight: readVar("--diagram-edge-highlight"),
    selection: readVar("--diagram-selection"),
    crossDomainHighlight: readVar("--diagram-cross-domain-highlight"),
    nodeStrokeSelected: readVar("--diagram-node-stroke-selected"),
    defaultDomain: readVar("--diagram-product-default"),
    pkIcon: readVar("--diagram-pk-icon"),
    fkIcon: readVar("--diagram-fk-icon"),
    handleFkBg: readVar("--diagram-handle-fk-bg"),
    handleFkBorder: readVar("--diagram-handle-fk-border"),
    handlePkBg: readVar("--diagram-handle-pk-bg"),
    handlePkBorder: readVar("--diagram-handle-pk-border"),
  };
}

/** Resolve the diagram palette from CSS variables (memoized after first read). */
export function diagramColors() {
  if (!cache) cache = build();
  return cache;
}
