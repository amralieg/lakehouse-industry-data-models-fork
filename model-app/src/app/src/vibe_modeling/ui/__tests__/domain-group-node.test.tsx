/**
 * `DomainGroupNode` is a React Flow custom node. Like `TableNode`, it
 * needs a `<ReactFlowProvider>` wrapper so the library's hooks resolve.
 */
import { describe, expect, it, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { ReactFlowProvider } from "@xyflow/react";
import {
  DomainGroupNode,
  type DomainGroupData,
} from "@/components/diagram/domain-group-node";

function renderNode(data: DomainGroupData) {
  return render(
    <ReactFlowProvider>
      {/* @ts-expect-error: react-flow injects extra runtime fields */}
      <DomainGroupNode id="grp-1" data={data} type="domainGroup" />
    </ReactFlowProvider>,
  );
}

const baseData: DomainGroupData = {
  label: "Sales",
  domain: "sales",
  division: "B2C",
  isExternal: false,
  width: 400,
  height: 300,
  colorIndex: 0,
};

describe("DomainGroupNode", () => {
  it("renders the domain label and division as a header inside the boundary", () => {
    renderNode(baseData);
    expect(screen.getByText("Sales")).toBeInTheDocument();
    expect(screen.getByText(/\(B2C\)/)).toBeInTheDocument();
  });

  it("calls onDomainClick only when the node is external (dashed boundary)", () => {
    const onClick = vi.fn();
    const { rerender } = renderNode({
      ...baseData,
      isExternal: true,
      onDomainClick: onClick,
    });
    fireEvent.click(screen.getByText("Sales").closest("div")!.parentElement!);
    expect(onClick).toHaveBeenCalledWith("sales");

    onClick.mockReset();
    rerender(
      <ReactFlowProvider>
        {/* @ts-expect-error: react-flow injects extra runtime fields */}
        <DomainGroupNode
          id="grp-1"
          data={{ ...baseData, isExternal: false, onDomainClick: onClick }}
          type="domainGroup"
        />
      </ReactFlowProvider>,
    );
    fireEvent.click(screen.getByText("Sales").closest("div")!.parentElement!);
    expect(onClick).not.toHaveBeenCalled();
  });

});
