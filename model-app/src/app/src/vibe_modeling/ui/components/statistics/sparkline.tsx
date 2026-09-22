/**
 * A tiny inline SVG sparkline for the Change "Evolution" small-multiples.
 *
 * Flat (no axes / labels) per the design-of-record — hairline borders and the
 * trend line do the structural work. Color comes from a token class on the
 * stroke (`text-*`), never a hard-coded hex. Renders nothing meaningful with
 * fewer than two points (a single dot), and degrades gracefully on all-equal
 * series (a flat mid-line).
 */
export function Sparkline({
  values,
  className = "text-chart-2",
  width = 120,
  height = 28,
  label,
}: {
  values: number[];
  /** Token class controlling the stroke color (e.g. text-destructive). */
  className?: string;
  width?: number;
  height?: number;
  /** Accessible label, e.g. "Confidence over versions". */
  label?: string;
}) {
  const pts = values.filter((v) => Number.isFinite(v));
  if (pts.length === 0) {
    return null;
  }

  const min = Math.min(...pts);
  const max = Math.max(...pts);
  const span = max - min || 1;
  const pad = 2;
  const w = width - pad * 2;
  const h = height - pad * 2;

  const coords = pts.map((v, i) => {
    const x = pts.length === 1 ? w / 2 : (i / (pts.length - 1)) * w;
    // Invert Y so larger values sit higher.
    const y = h - ((v - min) / span) * h;
    return [x + pad, y + pad] as const;
  });

  const d = coords
    .map(([x, y], i) => `${i === 0 ? "M" : "L"}${x.toFixed(1)},${y.toFixed(1)}`)
    .join(" ");

  const last = coords[coords.length - 1];

  return (
    <svg
      data-testid="sparkline"
      role="img"
      aria-label={label}
      width={width}
      height={height}
      viewBox={`0 0 ${width} ${height}`}
      className={className}
    >
      {coords.length > 1 && (
        <path
          d={d}
          fill="none"
          stroke="currentColor"
          strokeWidth={1.5}
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      )}
      <circle cx={last[0]} cy={last[1]} r={1.8} fill="currentColor" />
    </svg>
  );
}
