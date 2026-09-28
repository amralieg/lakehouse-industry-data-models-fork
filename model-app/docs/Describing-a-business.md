# Describing a business

The business description is the single most important input to Model Foundry. It tells the modeling agent how the business works - not how your databases represent it. The richer and more specific it is, the better the generated model.

You are not writing a data dictionary or an ERD. You are writing a semantic brief that lets the agent infer entities, relationships, lifecycles, events, and rules without seeing your schemas.

You don't need to write it from scratch. Hand this guide to a coding agent and ask it to draft the description for your company. It can supply industry-standard context (typical systems, common regulations, standard terminology); you fill in the internal specifics - especially your systems of record and the channels your model must separate.

---

## What to write

Write one focused paragraph per section, then concatenate. The agent reads the whole thing as a single narrative.

### 1. Company overview and segments

Who the company is and what it does. Name distinct lines of business separately - each major segment usually maps to clusters of data domains. Name acquired brands and recent acquisitions, because they signal where the model needs to reconcile overlapping data.

Cover:
- what the company makes, sells, or provides
- major business segments and how they differ from one another
- brands, subsidiaries, or acquired businesses in scope
- geographies and markets

### 2. Go-to-market channels

Channels drive some of the most important modeling decisions. The same "order" or "customer" concept often behaves structurally differently per channel. Call out any channel the model must separate cleanly, and note the data each channel produces.

Cover:
- how the company reaches customers (direct, dealer network, OEM supply, e-commerce, platform / marketplace, etc.)
- which channels require structurally different treatment (e.g., dealer stock orders vs. OEM engineered-to-order supply)
- feedback data flowing back from each channel (point-of-sale sell-out, warranty registration, telemetry, etc.)

### 3. Core business processes

Walk the value chain end to end: procure, engineer, make, move, sell, service. Each major process tends to become one or more data domains. Include priority initiatives and hard deadlines - a regulatory cutoff, a financial-close cycle, or a contract renewal date signals a domain that must exist.

Cover:
- the sequence of major activities from sourcing through to post-sale
- important sub-processes or structural splits within a step (e.g., first-party vs. marketplace fulfillment)
- current-state pain points or strategic initiatives that drive what the model must answer
- hard deadlines with business consequences

### 4. Industry terminology

Give the agent your vocabulary so tables, columns, and comments use terms your people actually recognize. Include acronyms with their expansions.

List terms flat, comma-separated:
`hin (hull identification number), engine_family, sku, mpn (manufacturer part number), pos (point of sale), sell_in, sell_out, bom, ecn...`

This directly improves the legibility of the generated output.

### 5. Systems of record

This section most improves the downstream assess loop. The agent uses named systems to reason about where data comes from and to flag domains that lack coverage. Name each system, its role, and its status.

Cover:
- each system name and the domain it owns (ERP, CRM, PLM, OMS, WMS, demand planning, etc.)
- whether it is the current source of truth, a legacy being replaced, or a target north-star state
- any migrations in progress and the direction of travel
- Delta Sharing feeds or third-party data sources
- application backends (e.g., Lakebase-backed operational apps)

### 6. Regulatory and compliance context

Regulations generate compliance domains, classification requirements, and mandatory attributes. List the standards that apply to your industry and geographies.

Skip this section if no meaningful regulatory requirements exist.

### 7. Data domains already in use

Tell the agent which domains you already recognize. This aligns the output with your mental model and helps the agent spot white space - domains you are missing. Flag where a domain splits structurally or carries event streams.

Example: `product_lifecycle, component_master, manufacturing, quality, supply_chain_planning, procurement, logistics, product_catalog, pricing, quote, sales_order (split OEM vs. stock), dealer (with POS event streams), customer, connected_product, billing, finance, compliance`

---

## What to leave out

Unless you are specifically mapping an existing physical layer, omit:

- database schemas, table names, column types
- ETL pipeline logic or job names
- API specifications or message formats
- infrastructure and platform topology
- current BI report organization

These matter later when mapping the conceptual model to physical data. They should not define the conceptual model itself.

---

## Worked example

The following is the description section for a fictional manufacturer, compressed to show structure. For a fuller, machine-readable business-context example - including the scalar config fields - see [`examples/maf.json`](../examples/maf.json).

---

> Harborline Marine & Power is a North American manufacturer of marine propulsion, onboard power, and recreational watercraft systems. The business operates three segments the data model must distinguish cleanly: **Marine Propulsion** (outboard, sterndrive, and inboard engines plus electric-drive systems across acquired brands Tidewater, Halyard, BlueFin, and the recently acquired electric-drive startup VoltWake); **Onboard Power & Systems** (marine generators, inverters, shore-power, battery management, and the NavHub telemetry platform); and **Recreational Craft** (pontoon, bay, and center-console boats sold as engineered configurations).
>
> Go-to-market is split across two channels the model must separate: (1) **Dealer / Replacement** - sold through ~600 independent marine dealers who hold inventory and feed back POS sell-out and warranty-registration data; and (2) **OEM / Boatbuilder** - propulsion and power systems spec'd into third-party boatbuilder production lines under multi-year supply agreements, engineered-to-order, with direct fulfillment.
>
> Core processes: component procurement; a multi-source component master (SAP + Legacy Parts Register, being rationalized into Teamcenter PLM); supplier consolidation (CFO priority: ~5 per category → ~2); BOM and ECN management; manufacturing across five plants; dealer and OEM fulfillment; warranty and returns; NavHub telemetry ingestion (hours, fault codes, GPS, fuel burn); EPA/CARB emissions certification with a model-year deadline.
>
> Industry jargon: hin (hull identification number), engine_family, emissions_family, sku, mpn (manufacturer part number), lpr (legacy parts register), outboard, sterndrive, rigging_kit, pitch, wot (wide-open throttle), nmea_2000, can_bus, bms (battery management system), soc (state of charge), pos (point of sale), sell_in, sell_out, oem_order, stock_order, dealer, boatbuilder, abyc, epa_marine, carb, bom, ecn, plm, mes.
>
> Systems of record: **SAP S/4HANA** (ERP, source of truth for parts, POs, BOM, financial close); **SQL Server OMS** (dealer and OEM orders, legacy); **Salesforce** (CRM + CPQ for OEM supply agreements); **Teamcenter PLM** (north-star for specifications, migration in progress); **PDM** (finished-good variants and options); **NavHub telemetry store** (connected-engine event streams on cloud object storage); **Blue Yonder** (demand planning); **Lakebase** (application backend for internal Rigging Configurator).
>
> Regulations: EPA/CARB marine emissions; US Coast Guard and ABYC electrical/fuel-system safety; NMEA 2000 interoperability; EU Recreational Craft Directive (RCD) and CE marking; California Prop 65; RoHS/REACH; SOX; PCI DSS; ISO 9001.
>
> Domains in use: product_lifecycle, component_master, manufacturing, quality, supply_chain_planning, procurement, logistics, product_catalog, pricing, quote, sales_order (OEM vs. stock), oem_program, dealer (with POS event streams), customer, connected_product (NavHub telemetry), billing, finance, compliance.

---

## Quality check

Before submitting, verify the description can answer these questions without referencing a database:

1. What are the fundamental things this business cares about?
2. Who participates - customers, suppliers, partners - and how do their roles differ?
3. How does money move? Who pays whom, and why?
4. What happens to key entities over time (lifecycles, state transitions, important events)?
5. Which concepts change meaning across business units, channels, or geographies?
6. What questions must the resulting model be able to answer?

If any of these are unanswerable from what you've written, add a sentence to the relevant section.
