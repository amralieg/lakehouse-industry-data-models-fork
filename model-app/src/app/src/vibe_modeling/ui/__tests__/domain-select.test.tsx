/**
 * `DomainSelect` shared component tests.
 *
 * The dropdown is the canonical domain-picker shared between the
 * Diagram and Ontology tabs. We assert the trigger renders, the
 * sentinel "All domains" option exists, each provided domain becomes
 * a selectable option, and `onChange` fires with `null` (for the
 * sentinel) or the picked name.
 *
 * Radix's portal renders SelectContent into document.body, so the
 * options aren't queryable until the trigger is opened — we drive
 * that with a click.
 */
import { describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";

import { DomainSelect } from "@/components/diagram/domain-select";

describe("DomainSelect", () => {
  it("renders an 'All domains' option plus one per domain", () => {
    render(
      <DomainSelect
        domains={[
          { name: "Sales", division: "B2C" },
          { name: "Inventory" },
        ]}
        value={null}
        onChange={() => {}}
      />,
    );
    // Trigger uses a combobox role from Radix.
    const trigger = screen.getByRole("combobox");
    expect(trigger).toBeInTheDocument();
    fireEvent.click(trigger);
    // Options are now in the portal.
    expect(
      screen.getByRole("option", { name: /All domains/i }),
    ).toBeInTheDocument();
    expect(screen.getByRole("option", { name: /Sales/i })).toBeInTheDocument();
    expect(
      screen.getByRole("option", { name: /Inventory/i }),
    ).toBeInTheDocument();
  });

  it("fires onChange(null) when 'All domains' is picked", () => {
    const onChange = vi.fn();
    render(
      <DomainSelect
        domains={[{ name: "Sales" }]}
        value="Sales"
        onChange={onChange}
      />,
    );
    fireEvent.click(screen.getByRole("combobox"));
    fireEvent.click(screen.getByRole("option", { name: /All domains/i }));
    expect(onChange).toHaveBeenCalledWith(null);
  });

  it("fires onChange(name) when a domain is picked", () => {
    const onChange = vi.fn();
    render(
      <DomainSelect
        domains={[{ name: "Sales" }, { name: "Inventory" }]}
        value={null}
        onChange={onChange}
      />,
    );
    fireEvent.click(screen.getByRole("combobox"));
    fireEvent.click(screen.getByRole("option", { name: /Inventory/i }));
    expect(onChange).toHaveBeenCalledWith("Inventory");
  });
});
