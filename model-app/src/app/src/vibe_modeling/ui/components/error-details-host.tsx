import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { useErrorDetails, closeDetails, copyToClipboard } from "@/lib/notify";

/**
 * Global details dialog for `notifyError`'s "Details" action - a
 * focus-trapped, wide, scrollable surface for long/multi-line errors that
 * don't fit in a toast. Mounted once in `routes/__root.tsx`; reads the
 * module-level store in `lib/notify.ts` via `useSyncExternalStore`.
 */
export function ErrorDetailsHost() {
  const text = useErrorDetails();

  const copy = () => {
    if (!text) return;
    void copyToClipboard(text);
  };

  return (
    <Dialog open={text != null} onOpenChange={(open) => !open && closeDetails()}>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>Error details</DialogTitle>
          <DialogDescription>
            Full error text, selectable and copyable.
          </DialogDescription>
        </DialogHeader>
        <pre className="max-h-[60vh] overflow-auto whitespace-pre-wrap rounded-md bg-muted p-3 text-sm select-text">
          {text}
        </pre>
        <div className="flex justify-end">
          <Button variant="outline" size="sm" onClick={copy}>
            Copy
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}
