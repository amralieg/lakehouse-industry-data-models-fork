import { useCallback, useRef, useState, type KeyboardEvent } from "react";
import { X } from "lucide-react";
import { cn } from "@/lib/utils";

export interface TagInputProps {
  /** Current tags as an array of strings */
  value: string[];
  /** Called with updated tag array */
  onChange: (tags: string[]) => void;
  /** Placeholder when no tags and input is empty */
  placeholder?: string;
  /** Additional class names on the outer container */
  className?: string;
  /** Disable editing */
  disabled?: boolean;
}

/**
 * Tag/chip input — type a value, press Enter or comma to add as a chip.
 * Click × on a chip to remove it.
 */
export function TagInput({
  value,
  onChange,
  placeholder,
  className,
  disabled,
}: TagInputProps) {
  const [draft, setDraft] = useState("");
  const inputRef = useRef<HTMLInputElement>(null);

  const addTag = useCallback(
    (raw: string) => {
      const tag = raw.trim();
      if (!tag || value.includes(tag)) return;
      onChange([...value, tag]);
    },
    [value, onChange],
  );

  const removeTag = useCallback(
    (idx: number) => {
      onChange(value.filter((_, i) => i !== idx));
    },
    [value, onChange],
  );

  const handleKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter" || e.key === ",") {
      // Always suppress — an empty-draft Enter used to bubble to the
      // surrounding <form onSubmit> and launch the run immediately.
      e.preventDefault();
      if (draft.trim()) {
        addTag(draft);
        setDraft("");
      }
      return;
    }
    if (e.key === "Backspace" && !draft && value.length > 0) {
      removeTag(value.length - 1);
    }
  };

  return (
    <div
      className={cn(
        "flex flex-wrap items-center gap-1.5 rounded-md border border-input bg-background px-2 py-1.5 text-sm ring-offset-background",
        "focus-within:outline-none focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-1 focus-within:border-ring",
        disabled && "opacity-50 cursor-not-allowed",
        className,
      )}
      onClick={() => inputRef.current?.focus()}
    >
      {value.map((tag, i) => (
        <span
          key={tag}
          className="inline-flex items-center gap-1 rounded-sm bg-secondary px-2 py-0.5 text-xs font-medium text-secondary-foreground"
        >
          {tag}
          {!disabled && (
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                removeTag(i);
              }}
              className="ml-0.5 rounded-sm hover:bg-secondary-foreground/20 transition-colors"
            >
              <X className="h-3 w-3" />
            </button>
          )}
        </span>
      ))}
      <input
        ref={inputRef}
        value={draft}
        onChange={(e) => setDraft(e.target.value)}
        onKeyDown={handleKeyDown}
        onBlur={() => {
          if (draft.trim()) {
            addTag(draft);
            setDraft("");
          }
        }}
        placeholder={value.length === 0 ? placeholder : undefined}
        disabled={disabled}
        className="flex-1 min-w-[80px] bg-transparent outline-none placeholder:text-muted-foreground text-sm h-6"
      />
    </div>
  );
}
