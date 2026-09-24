import { Fragment, memo, useCallback } from "react";
import { Handle, Position, type NodeProps } from "@xyflow/react";
import { Key, ExternalLink } from "lucide-react";
import { getProductTypeColors, getPkIconColor, getFkIconColor, NODE_MAX_VISIBLE_COLUMNS } from "./constants";
import { diagramColors } from "./diagram-colors";
import type { DiagramNodePort, ColumnDisplayMode } from "./types";
import { ChangeBadge } from "@/components/explorer/change-badge";

export type TableNodeChangeStatus = "unchanged" | "new" | "modified";

/** Four-side floating-edge anchor points for the hidden-columns regime. */
const FLOATING_SIDES: { side: string; position: Position }[] = [
  { side: "left", position: Position.Left },
  { side: "right", position: Position.Right },
  { side: "top", position: Position.Top },
  { side: "bottom", position: Position.Bottom },
];

export interface TableNodeData {
  label: string;
  tableName: string;
  productType: string;
  description: string;
  columns: DiagramNodePort[];
  columnCount: number;
  fkCount: number;
  domain: string;
  columnMode: ColumnDisplayMode;
  onFkNavigate?: (targetNodeId: string) => void;
  onNodeClick?: (nodeId: string) => void;
  highlighted?: boolean;
  changeStatus?: TableNodeChangeStatus;
}

function TableNodeComponent({ data, id }: NodeProps & { data: TableNodeData }) {
  const colors = getProductTypeColors(data.productType);
  const palette = diagramColors();

  const showingColumns = data.columnMode !== "hide" && data.columns.length > 0;
  const candidateColumns =
    data.columnMode === "keys"
      ? data.columns.filter((c) => c.is_pk || c.is_fk)
      : data.columns;
  // Cap rendered rows to match the backend height estimate (which budgets at
  // most NODE_MAX_VISIBLE_COLUMNS rows). The node now renders at that fixed
  // height with overflow-hidden, so rows beyond the cap would be clipped.
  const visibleColumns = candidateColumns.slice(0, NODE_MAX_VISIBLE_COLUMNS);
  const hiddenColumnCount = data.columnCount - visibleColumns.length;

  const handleFkClick = useCallback(
    (e: React.MouseEvent, fkTarget: string) => {
      e.stopPropagation();
      if (!fkTarget || !data.onFkNavigate) return;
      const parts = fkTarget.split(".");
      if (parts.length >= 2) {
        data.onFkNavigate(`${parts[0]}.${parts[1]}`);
      }
    },
    [data.onFkNavigate]
  );

  const handleNodeClick = useCallback(
    (e: React.MouseEvent) => {
      e.stopPropagation();
      data.onNodeClick?.(id);
    },
    [data.onNodeClick, id]
  );

  // Build tooltip text for the table header
  const tableTooltip = [
    `${data.domain}.${data.tableName}`,
    data.description || undefined,
    `${data.columnCount} columns, ${data.fkCount} FKs`,
  ]
    .filter(Boolean)
    .join("\n");

  return (
    <div
      className="bg-card border rounded-md shadow-sm overflow-hidden cursor-pointer h-full"
      style={{ minWidth: 180, borderColor: colors.border }}
      title={tableTooltip}
      onClick={handleNodeClick}
    >
      {/* Header bar */}
      <div
        className={`${colors.text} px-3 py-1.5 text-xs font-semibold flex items-center gap-2`}
        style={{ backgroundColor: colors.bg }}
      >
        <span className="truncate flex-1">{data.tableName}</span>
        {data.changeStatus && data.changeStatus !== "unchanged" && (
          <ChangeBadge status={data.changeStatus} />
        )}
      </div>

      {/* Column rows */}
      {showingColumns ? (
        <div className="text-[11px] divide-y divide-border/50">
          {visibleColumns.map((col) => {
            const colTooltip = [
              col.name,
              col.is_pk ? "Primary Key" : col.is_fk ? `FK → ${col.fk_target}` : null,
              col.description || null,
            ].filter(Boolean).join("\n");

            return (
              <div
                key={col.id}
                className="flex items-center gap-1.5 px-2 py-0.5 hover:bg-accent/30 relative"
                title={colTooltip}
              >
                {col.is_pk ? (
                  <Key
                    className="h-3 w-3 shrink-0"
                    style={{ color: getPkIconColor() }}
                  />
                ) : col.is_fk ? (
                  <span
                    title={`Navigate to ${col.fk_target}`}
                    onClick={(e) => handleFkClick(e, col.fk_target)}
                    className="cursor-pointer hover:scale-125 transition-transform inline-flex"
                  >
                    <ExternalLink
                      className="h-3 w-3 shrink-0"
                      style={{ color: getFkIconColor() }}
                    />
                  </span>
                ) : (
                  <span className="w-3 shrink-0" />
                )}
                <span className="truncate flex-1 font-mono">{col.name}</span>
                {data.columnMode !== "keys" && (
                  <span className="text-muted-foreground text-[10px] shrink-0">
                    {col.type}
                  </span>
                )}
                {/* FK source handle (right side) */}
                {col.is_fk && (
                  <Handle
                    type="source"
                    position={Position.Right}
                    id={col.id}
                    className="!w-1.5 !h-1.5 !right-[-3px]"
                    style={{
                      backgroundColor: palette.handleFkBg,
                      borderColor: palette.handleFkBorder,
                    }}
                  />
                )}
                {/* PK target handle (left side) */}
                {col.is_pk && (
                  <Handle
                    type="target"
                    position={Position.Left}
                    id={col.id}
                    className="!w-1.5 !h-1.5 !left-[-3px]"
                    style={{
                      backgroundColor: palette.handlePkBg,
                      borderColor: palette.handlePkBorder,
                    }}
                  />
                )}
              </div>
            );
          })}
          {hiddenColumnCount > 0 && (
            <div className="px-2 py-0.5 text-muted-foreground text-[10px] text-center">
              +{hiddenColumnCount} more columns
            </div>
          )}
        </div>
      ) : (
        <div className="px-3 py-1.5 text-[11px] text-muted-foreground">
          {data.columnCount} columns, {data.fkCount} FKs
        </div>
      )}

      {/* Floating-edge attachment when columns are hidden: the focal view's
          orthogonal edges anchor on ANY of the four sides (the side is decided
          by the backend waypoints/anchors), so expose a source + target handle
          on each side instead of the old Right/Left-only constraint. The
          waypoint edge draws its own absolute path, so the specific handle it
          binds to does not constrain the rendered polyline. */}
      {!showingColumns &&
        FLOATING_SIDES.map(({ side, position }) => (
          <Fragment key={side}>
            <Handle
              type="source"
              position={position}
              id={`${id}__source__${side}`}
              className="!w-1.5 !h-1.5"
              style={{
                backgroundColor: palette.handleFkBg,
                borderColor: palette.handleFkBorder,
              }}
            />
            <Handle
              type="target"
              position={position}
              id={`${id}__target__${side}`}
              className="!w-1.5 !h-1.5"
              style={{
                backgroundColor: palette.handlePkBg,
                borderColor: palette.handlePkBorder,
              }}
            />
          </Fragment>
        ))}
    </div>
  );
}

export const TableNode = memo(TableNodeComponent);
