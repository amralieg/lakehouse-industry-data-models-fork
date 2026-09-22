/**
 * `SortableTableHead` — the only behaviour worth pinning is that clicking
 * the header invokes `onToggle(columnKey)` with the right argument.
 * Sort-icon class assertions are visual fluff.
 */
import { describe, expect, it, vi } from "vitest";
import { fireEvent, render } from "@testing-library/react";

import { SortableTableHead } from "@/components/ui/sortable-table-head";
import { Table, TableBody, TableHeader, TableRow } from "@/components/ui/table";

function renderInTable(ui: React.ReactNode) {
  return render(
    <Table>
      <TableHeader>
        <TableRow>{ui}</TableRow>
      </TableHeader>
      <TableBody>
        <TableRow>
          <td>row</td>
        </TableRow>
      </TableBody>
    </Table>,
  );
}

describe("SortableTableHead", () => {
  it("calls onToggle with the columnKey on click", () => {
    const onToggle = vi.fn();
    const { container } = renderInTable(
      <SortableTableHead
        columnKey="created_at"
        sortKey={null}
        sortDir={null}
        onToggle={onToggle}
      >
        Created
      </SortableTableHead>,
    );
    const button = container.querySelector("button");
    expect(button).toBeTruthy();
    fireEvent.click(button!);
    expect(onToggle).toHaveBeenCalledWith("created_at");
  });
});
