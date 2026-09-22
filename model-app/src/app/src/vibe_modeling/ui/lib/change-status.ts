import { ChangeStatus } from "@/lib/api";
import { Plus, Pencil, Trash2, type LucideIcon } from "lucide-react";

export interface ChangeStatusRepr {
  /** Outline badge fill + text + border. */
  badgeClassName: string;
  /** Table-row tint. */
  rowClassName: string;
  /** Status dot bg-* color. */
  dotClassName: string;
  /** Standalone text-* tone (inline markers without a badge chrome). */
  textToneClassName: string;
  /** Tooltip / aria label. */
  label: string;
  /** Marker icon, or null for unchanged. */
  icon: LucideIcon | null;
}

const REPR: Record<ChangeStatus, ChangeStatusRepr> = {
  [ChangeStatus.unchanged]: {
    badgeClassName: "",
    rowClassName: "",
    dotClassName: "bg-muted-foreground/50",
    textToneClassName: "text-muted-foreground",
    label: "",
    icon: null,
  },
  [ChangeStatus.new]: {
    badgeClassName: "bg-success/15 text-success border-success/40",
    rowClassName: "bg-success/5",
    dotClassName: "bg-success",
    textToneClassName: "text-success",
    label: "New in this version",
    icon: Plus,
  },
  [ChangeStatus.modified]: {
    badgeClassName: "bg-warning/15 text-warning border-warning/40",
    rowClassName: "bg-warning/5",
    dotClassName: "bg-warning",
    textToneClassName: "text-warning",
    label: "Changed from previous version",
    icon: Pencil,
  },
  [ChangeStatus.deleted]: {
    badgeClassName: "bg-destructive/15 text-destructive border-destructive/40",
    rowClassName: "opacity-50 line-through",
    // Deleted rows show strikethrough, never a colored dot — keep the
    // historical fall-through to muted so the dot taxonomy is unchanged.
    dotClassName: "bg-muted-foreground/50",
    textToneClassName: "text-destructive",
    label: "Removed in this version",
    icon: Trash2,
  },
};

function repr(status?: ChangeStatus): ChangeStatusRepr {
  return REPR[status ?? ChangeStatus.unchanged] ?? REPR[ChangeStatus.unchanged];
}

export const changeBadgeClassName = (s?: ChangeStatus) => repr(s).badgeClassName;
export const changeRowClassName = (s?: ChangeStatus) => repr(s).rowClassName;
export const statusDotClass = (s?: ChangeStatus) => repr(s).dotClassName;
export const changeTextToneClass = (s?: ChangeStatus) => repr(s).textToneClassName;
export const changeLabel = (s?: ChangeStatus) => repr(s).label;
export const changeIcon = (s?: ChangeStatus) => repr(s).icon;
