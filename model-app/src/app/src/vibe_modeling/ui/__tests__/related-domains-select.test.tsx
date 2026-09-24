/**
 * `RelatedDomainsSelect` tests.
 *
 * Collapsed multi-select dropdown of related domains. State stores the set
 * of HIDDEN domains (empty = show all, the default). The control narrows a
 * single-domain view down from "focal + all related" to "focal + chosen
 * related".
 *
 * Like `domain-select.test.tsx`, the Popover portals its content into the
 * document, so checkboxes/options aren't queryable until the trigger is
 * clicked open.
 */
import { describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";

import {
  RelatedDomainsSelect,
  type RelatedDomainsSelectProps,
} from "@/components/diagram/related-domains-select";

function defaultProps(
  overrides: Partial<RelatedDomainsSelectProps> = {},
): RelatedDomainsSelectProps {
  return {
    relatedDomains: [
      { name: "inventory", division: "B2C" },
      { name: "shipping", division: "B2B" },
      { name: "billing", division: "Finance" },
    ],
    hiddenRelated: new Set<string>(),
    onHiddenRelatedChange: vi.fn(),
    ...overrides,
  };
}

describe("RelatedDomainsSelect", () => {
  it("is collapsed by default — trigger present, no checkboxes in DOM", () => {
    render(<RelatedDomainsSelect {...defaultProps()} />);
    // Trigger uses combobox role.
    const trigger = screen.getByRole("combobox", { name: /Related domains/i });
    expect(trigger).toBeInTheDocument();
    // Collapsed: no option rows / checkboxes rendered yet.
    expect(screen.queryByRole("checkbox")).not.toBeInTheDocument();
    expect(screen.queryByRole("option")).not.toBeInTheDocument();
  });

  it("default (empty hiddenRelated) → label 'Related: all'", () => {
    render(<RelatedDomainsSelect {...defaultProps()} />);
    expect(
      screen.getByRole("combobox", { name: /Related domains/i }),
    ).toHaveTextContent(/Related: all/i);
  });

  it("opening shows one row per related domain, all checked by default", () => {
    render(<RelatedDomainsSelect {...defaultProps()} />);
    fireEvent.click(screen.getByRole("combobox", { name: /Related domains/i }));
    const checkboxes = screen.getAllByRole("checkbox");
    expect(checkboxes).toHaveLength(3);
    // All shown (none hidden) → all checked.
    for (const cb of checkboxes) {
      expect(cb).toHaveAttribute("aria-checked", "true");
    }
    expect(screen.getByText("inventory")).toBeInTheDocument();
    expect(screen.getByText("shipping")).toBeInTheDocument();
    expect(screen.getByText("billing")).toBeInTheDocument();
  });

  it("toggling a shown domain fires onHiddenRelatedChange with a Set containing it", () => {
    const onHiddenRelatedChange = vi.fn();
    render(
      <RelatedDomainsSelect {...defaultProps({ onHiddenRelatedChange })} />,
    );
    fireEvent.click(screen.getByRole("combobox", { name: /Related domains/i }));
    fireEvent.click(screen.getByText("inventory"));
    expect(onHiddenRelatedChange).toHaveBeenCalledTimes(1);
    const arg = onHiddenRelatedChange.mock.calls[0][0] as Set<string>;
    expect(arg).toBeInstanceOf(Set);
    expect([...arg]).toEqual(["inventory"]);
  });

  it("toggling an already-hidden domain removes it → empty Set", () => {
    const onHiddenRelatedChange = vi.fn();
    render(
      <RelatedDomainsSelect
        {...defaultProps({
          hiddenRelated: new Set(["inventory"]),
          onHiddenRelatedChange,
        })}
      />,
    );
    fireEvent.click(screen.getByRole("combobox", { name: /Related domains/i }));
    fireEvent.click(screen.getByText("inventory"));
    const arg = onHiddenRelatedChange.mock.calls[0][0] as Set<string>;
    expect([...arg]).toEqual([]);
  });

  it("label reads 'Related: 2/3' with one hidden", () => {
    render(
      <RelatedDomainsSelect
        {...defaultProps({ hiddenRelated: new Set(["billing"]) })}
      />,
    );
    expect(
      screen.getByRole("combobox", { name: /Related domains/i }),
    ).toHaveTextContent(/Related: 2\/3/);
  });

  it("label reads 'Related: none' with all hidden", () => {
    render(
      <RelatedDomainsSelect
        {...defaultProps({
          hiddenRelated: new Set(["inventory", "shipping", "billing"]),
        })}
      />,
    );
    expect(
      screen.getByRole("combobox", { name: /Related domains/i }),
    ).toHaveTextContent(/Related: none/i);
  });

  it("'Select all' fires onHiddenRelatedChange with an empty Set", () => {
    const onHiddenRelatedChange = vi.fn();
    render(
      <RelatedDomainsSelect
        {...defaultProps({
          hiddenRelated: new Set(["inventory", "shipping"]),
          onHiddenRelatedChange,
        })}
      />,
    );
    fireEvent.click(screen.getByRole("combobox", { name: /Related domains/i }));
    fireEvent.click(screen.getByText(/Select all/i));
    const arg = onHiddenRelatedChange.mock.calls[0][0] as Set<string>;
    expect([...arg]).toEqual([]);
  });

  it("'Clear all' fires onHiddenRelatedChange with a Set of all names", () => {
    const onHiddenRelatedChange = vi.fn();
    render(
      <RelatedDomainsSelect {...defaultProps({ onHiddenRelatedChange })} />,
    );
    fireEvent.click(screen.getByRole("combobox", { name: /Related domains/i }));
    fireEvent.click(screen.getByText(/Clear all/i));
    const arg = onHiddenRelatedChange.mock.calls[0][0] as Set<string>;
    expect(new Set(arg)).toEqual(new Set(["inventory", "shipping", "billing"]));
  });

  it("search filters the list case-insensitively", () => {
    render(<RelatedDomainsSelect {...defaultProps()} />);
    fireEvent.click(screen.getByRole("combobox", { name: /Related domains/i }));
    const input = screen.getByPlaceholderText(/filter/i);
    fireEvent.change(input, { target: { value: "SHIP" } });
    expect(screen.getByText("shipping")).toBeInTheDocument();
    expect(screen.queryByText("inventory")).not.toBeInTheDocument();
    expect(screen.queryByText("billing")).not.toBeInTheDocument();
  });

  it("shows empty state when no domains match the search", () => {
    render(<RelatedDomainsSelect {...defaultProps()} />);
    fireEvent.click(screen.getByRole("combobox", { name: /Related domains/i }));
    const input = screen.getByPlaceholderText(/filter/i);
    fireEvent.change(input, { target: { value: "zzzz" } });
    expect(screen.getByText(/No domains match/i)).toBeInTheDocument();
  });
});
