import { memo } from "react";
import type { NodeProps } from "@xyflow/react";
import { getDomainPalette, getExternalDomainStyle } from "./constants";

export interface DomainGroupData {
  label: string;
  domain: string;
  division: string;
  isExternal: boolean;
  width: number;
  height: number;
  colorIndex: number;
  onDomainClick?: (domain: string) => void;
}

function DomainGroupNodeComponent({ data }: NodeProps & { data: DomainGroupData }) {
  const domainPalette = getDomainPalette();
  const palette = data.isExternal
    ? getExternalDomainStyle()
    : domainPalette[data.colorIndex % domainPalette.length];

  const borderStyle = data.isExternal ? "dashed" : "solid";

  const handleClick = () => {
    if (data.isExternal && data.onDomainClick) {
      data.onDomainClick(data.domain);
    }
  };

  return (
    <div
      style={{
        width: data.width,
        height: data.height,
        backgroundColor: palette.bg,
        borderColor: palette.border,
        borderWidth: 2,
        borderStyle,
        borderRadius: 8,
        position: "relative",
      }}
      className={data.isExternal ? "cursor-pointer hover:opacity-80" : ""}
      onClick={handleClick}
    >
      {/* Domain label */}
      <div
        className="absolute top-2 left-3 flex items-center gap-2 text-xs font-semibold"
        style={{ color: palette.label }}
      >
        <span>{data.label}</span>
        {data.division && (
          <span className="opacity-60 font-normal">({data.division})</span>
        )}
      </div>
    </div>
  );
}

export const DomainGroupNode = memo(DomainGroupNodeComponent);
