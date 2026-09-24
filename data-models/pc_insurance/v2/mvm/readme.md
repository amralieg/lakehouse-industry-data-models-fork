# Pc_Insurance Lakehouse Data Model

**v3_mvm** generated using Vibe Modelling Agent on September 21, 2026 at 11:56 AM

This document outlines a vibed Lakehouse data model for the Pc_Insurance business that can be deployed to Databricks Platform. The model is structured into business-aligned domains and denormalized data products, optimized for analytical workloads.

## Table of Contents

- [Output Folder Structure](#output-folder-structure)
- [Model Metrics](#model-metrics)
- [Business Summary](#business-summary)
- [Business Domains & Subdomains](#business-domains--subdomains)
  - [Coverage](#domain-coverage)
  - [Reinsurance](#domain-reinsurance)
  - [Billing](#domain-billing)
  - [Catastrophe](#domain-catastrophe)
  - [Claim](#domain-claim)
  - [Claim](#domain-claim)
  - [Party](#domain-party)
  - [Policy](#domain-policy)
  - [Premium](#domain-premium)
  - [Producers](#domain-producers)
  - [Risk](#domain-risk)
  - [Shared](#domain-shared)
- [Metric Views](#metric-views)

## Output Folder Structure

All artifacts for version **v3_mvm** are organized as follows:

```
v3/mvm/
  schemas/          DDL SQL files (one per domain)
  metrics/          Metric view SQL files (one per domain)
  samples/          Sample data CSV files (one per data product)
  docs/             Excel workbook, model CSV, release notes
  diagram/          DBML schema
  vibes/            Current & next vibes context
  ontology/         RDF/Turtle ontology schema
  model.json        Full model with requirements, metadata, and model data
  readme.md         This file
```

| Folder | Contents |
|---|---|
| `schemas/` | `pc_insurance_<domain>_schema_v3_mvm.sql` (combined per-domain SQL: schemas/databases + tables with inline PKs + FKs + tags) |
| `schemas/` | `pc_insurance_catalogs_v3_mvm.sql` (catalog-level DDL) |
| `metrics/` | `pc_insurance_<domain>_metrics_v3_mvm.sql` (one file per domain) |
| `docs/` | `pc_insurance_model_v3_mvm.xlsx`, `pc_insurance_model_v3_mvm.csv`, `releasenotes.txt` |
| `diagram/` | `pc_insurance_dbml_v3_mvm.dbml` |
| `vibes/` | `current_vibes.txt`, `next_vibes.txt` |
| `/` | `model.json` (full model with requirements, metadata, and model data) |
| `ontology/` | `pc_insurance_rdf_v3_mvm.rdf` |
| `samples/` | One CSV file per data product (e.g., `customer.csv`, `order.csv`) |

## Model Metrics
| Metric | Value |
|---|---|
| Model Scope | MVM (Minimum Viable Model) |
| Total Domains | 12 |
| Total Subdomains | 21 |
| Total Products | 90 |
| Total Attributes | 3884 |
| Primary Keys | 91 |
| Foreign Keys | 893 |
| Avg Attributes/Product | 43.2 |
| Metric Views | 91 |

## Business Summary
| Business | Industry Alignment | Model Scope | Description | References | Version |
|---|---|---|---|---|---|
| Pc_Insurance | Property-and-Casualty-Insurance | MVM (Minimum Viable Model) | A Property & Casualty insurer underwriting personal and commercial lines. Prospects submit risk information, underwriters evaluate and price it, and quotes are bound into policies that renew, endorse, cancel, and reinstate over time. Policies carry coverages with limits, deductibles, exclusions, and conditions that attach to insured risks (properties, buildings, vehicles, drivers). Premium is booked as written, earned, unearned, and return transactions with charges, taxes, fees, and producer commission. Claims record loss events, claimants, and per-coverage exposures, with reserves, payments, recoveries, and expenses tracked as financial movements. Risk is distributed through agents and brokers and ceded through reinsurance treaties and facultative agreements, with catastrophe and geography used to aggregate exposure. | NAIC (National Association of Insurance Commissioners), State Departments of Insurance (DOI), NAIC Model Laws & Regulations, ISO (Insurance Services Office) forms & rating, ACORD (Association for Cooperative Operations Research and Development) data standards, NIPR (National Insurance Producer Registry), FIO (Federal Insurance Office), NFIP (National Flood Insurance Program - FEMA), Statutory Accounting Principles (SAP/SSAP), US GAAP (FASB), IFRS 17 (IASB), Sarbanes-Oxley (SOX), NAIC ORSA & RBC requirements, State Guaranty Associations, NCCI (National Council on Compensation Insurance), Surplus Lines Stamping Offices, Fair Credit Reporting Act (FCRA), Gramm-Leach-Bliley Act (GLBA), Solvency II (for international/EU business), Model Audit Rule (MAR), NAIC Market Conduct Standards, GDPR/CCPA (data privacy), PCI DSS (payment card security) | 3 |

## Business Domains & Subdomains

<a id="domain-coverage"></a>

### Domain: Coverage

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| coverage | operations | 2 | Bridge between the policy contract and the insured risk. Owns Coverage (one row per coverage per policy term) with attached Limit, Deductible, Exclusion, and Condition. | 16 |

**Subdomains:** policy_terms, underwriting_intake


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| policy_terms | condition | master_data | Contract condition attached to a coverage. Grain: one row per policy condition per coverage. Distinct from uw_condition (underwriting). Enforces obligations, warranties, or requirements the insured must meet for coverage to apply. | 34 |
| policy_terms | coverage | master_data | Grain: one row per coverage per policy term. Bridge between policy contract and insured risk. Links to Policy Term and Insured Risk. Parent of Limit, Deductible, Exclusion, and Condition. | 50 |
| policy_terms | deductible | master_data | One row per deductible per coverage. Stores the deductible type (flat, percentage, split, disappearing) and amount applied to a coverage on a policy term. Grain: one row per deductible per coverage. | 29 |
| policy_terms | exclusion | master_data | One row per exclusion per coverage. Stores exclusion form code, description, and effective dating attached to a specific coverage on a policy term. Grain: one row per exclusion per coverage. | 17 |
| policy_terms | limit | master_data | One row per limit per coverage. Stores per-occurrence, aggregate, and sublimit amounts attached to a coverage. Grain: one row per limit per coverage. | 11 |
| policy_terms | type | reference_data | Reference catalog of coverage types: coverage code, name, LOB, ISO coverage symbol, mandatory/optional flag. Standardizes coverage classification across lines. One row per coverage type. | 40 |
| underwriting_intake | binder | transactional_data | Temporary insurance contract issued upon bind confirmation, providing coverage before the formal policy is issued. Captures binder number, effective/expiration dates, LOB, and issuing authority. | 44 |
| underwriting_intake | inspection_order | transactional_data | External UW report/order covering property inspection AND motor vehicle record (absorbs underwriting_mvr_report). Grain: one row per order. Captures order_type (interior/exterior/COPE/MVR), vendor, order date, status, findings, violation/license data, and | 53 |
| underwriting_intake | loss_history | master_data | Prior loss record for a submission or insured risk from CLUE, MVR, or applicant disclosure: loss date, cause, paid amount, open/closed status. Grain: one row per prior loss. Used in appetite and pricing. | 51 |
| underwriting_intake | quote | transactional_data | Priced insurance proposal generated from a submission. Grain: one row per quote. Captures quoted premium, LOB, effective date, expiration date, quote status, and binding eligibility flag. | 45 |
| underwriting_intake | rating_worksheet | transactional_data | Detailed rating calculation produced by the rating engine for a quote or policy transaction: rate table version, base rate, surcharges, credits, and final rated premium. Grain: one row per rating run per quote. | 50 |
| underwriting_intake | submission | transactional_data | ACORD 125/126/140 submission record capturing prospect risk information submitted for UW evaluation. Grain: one row per submission. Tracks source, status, line of business, and submission date. | 47 |
| underwriting_intake | underwriting_risk_score | transactional_data | UW risk scoring result for a submission or insured risk. Grain: one row per scoring event. Captures model version, composite score, component scores (COPE, MVR, CLUE), and score band classification. | 52 |
| underwriting_intake | uw_condition | transactional_data | Condition or requirement imposed by the underwriter on a submission or quote (e.g., loss control survey required, protective device warranty). Tracks fulfillment status and due date. | 47 |
| underwriting_intake | uw_decision | transactional_data | Underwriter accept/decline/refer/modify decision for a submission or quote, including referral escalation (absorbs uw_referral): assigned UW, priority, SLA due date, resolution. Grain: one row per UW decision event. | 46 |
| underwriting_intake | uw_referral | transactional_data | Tracks submissions or quotes escalated beyond standard UW authority for senior review. Captures referral reason, assigned UW, priority, SLA due date, and resolution outcome. | 46 |

<a id="domain-reinsurance"></a>

### Domain: Reinsurance

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| reinsurance | operations | 2 | Manages risk transfer to reinsurers. Owns Reinsurance Agreement, Treaty (QS/XOL/SL/CAT XL), Facultative Agreement, Cession, and Reinsurance Recovery linked to ceded Policy and Claim. | 11 |

**Subdomains:** cession_financials, treaty_arrangements


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| cession_financials | bordereaux | transactional_data | Periodic bordereau submission record sent to reinsurers summarizing ceded premium and loss activity. One row per bordereaux run per treaty per reporting period. Captures submission date, period, status, and totals. | 48 |
| cession_financials | bordereaux_line | transactional_data | Individual line item within a bordereaux submission, representing one cession or claim cession. One row per cession per bordereaux. Stores ceded premium, ceded loss, ceded LAE, and policy/claim reference keys. Belongs to a parent bordereaux run. | 53 |
| cession_financials | cession | transactional_data | Records risk transfer of a policy term to a treaty layer or FAC. Grain: one row per policy term per treaty layer (or FAC). Direction flag (outward/retro) distinguishes cession from retrocession. | 50 |
| cession_financials | ri_claim_cession | transactional_data | Links a claim exposure to a reinsurance treaty layer or FAC agreement for loss recovery eligibility. One row per claim exposure per treaty layer. Stores ceded loss amount, ceded LAE, and UNL calculation basis. | 53 |
| cession_financials | ri_premium_transaction | transactional_data | Ceded premium ledger. One row per financial movement (written, earned, unearned, return, reinstatement) for a cession. FK to cession, accounting period, treaty layer. Reinstatement rows carry occurrence reference and reinstated limit. | 51 |
| cession_financials | ri_recovery | transactional_data | Single ceded loss ledger. Grain: one row per movement per ri_claim_cession per accounting period, discriminated by movement_type: case/IBNR/LAE reserve position, or cash recovery (loss/LAE/DCC, subrogation, salvage). | 49 |
| treaty_arrangements | fac_agreement | master_data | Facultative reinsurance agreement covering a single risk or policy. One row per FAC placement. Captures cedant, reinsurer, ceded percentage, premium rate, inception/expiry, and the linked policy or submission. | 52 |
| treaty_arrangements | reinsurer | master_data | Master record for each reinsurance counterparty (assuming company, Lloyd's syndicate, or pool). One row per reinsurer. Stores legal name, NAIC code, AM Best rating, domicile, and authorized/unauthorized status for Schedule F credit. | 39 |
| treaty_arrangements | ri_agreement | master_data | Master record for a reinsurance agreement between the cedant and one or more reinsurers. One row per agreement. Captures agreement type (Treaty/Facultative), status, inception/expiry, governing law, and currency. | 48 |
| treaty_arrangements | treaty | master_data | Defines a proportional or non-proportional treaty under a reinsurance agreement. One row per treaty. Captures treaty type (QS/XOL/SL/CAT XL), layer, retention, limit, ROL, and UNL basis. | 47 |
| treaty_arrangements | treaty_layer | master_data | Individual attachment/exhaustion layer within an XOL or CAT XL treaty. One row per layer per treaty. Stores attachment point, limit per occurrence, annual aggregate limit, and reinstatement terms. | 51 |

<a id="domain-billing"></a>

### Domain: Billing

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| billing | business | 3 | Manages invoicing, collections, disbursements, delinquency, and installment plan processing for policyholders and payees. Owns billing accounts, invoices, payment transactions, payment plans, returned payments, and write-offs. | 9 |

**Subdomains:** account_management, invoice_collections, payment_disbursement


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| account_management | account | master_data | Master billing account linking a policyholder or payee to invoicing and collections. One row per billing account. Tracks account type (direct bill, agency bill), status, payment method, and balance. | 44 |
| account_management | installment_plan | master_data | Installment schedule elected for a Policy Term with per-installment lines: number, due dates, billed/paid amounts, fees, and status. Feeds delinquency and cancellation-for-non-payment. | 44 |
| account_management | payment_plan | master_data | Installment plan template defining the number of installments, down payment percentage, installment frequency, and applicable fees for a billing account or policy. Master record for plan configuration. | 32 |
| invoice_collections | billing_transaction | transactional_data | Atomic financial movement posted to a billing account (charge, credit, payment, reversal, fee, tax, write-off). One row per financial movement. Single ledger SSOT for account balance; payment, invoice_item, and write_off post here via enforced FK for | 47 |
| invoice_collections | invoice | transactional_data | Billing document issued to a policyholder or agency for premium charges, fees, and taxes due. One row per invoice. Grain: one invoice per billing cycle per billing account. Tracks due date, amount billed, and status. | 48 |
| invoice_collections | invoice_item | transactional_data | Line-level detail on an invoice representing a single charge, tax, fee, or commission amount. One row per line item per invoice. Links to premium charge, coverage, and policy term for reconciliation. | 47 |
| payment_disbursement | billing_payment | transactional_data | Record of a payment received from a policyholder, agency, or third party against a billing account. One row per payment transaction. Captures payment method, amount, receipt date, and application status. | 52 |
| payment_disbursement | commission_payable | transactional_data | Payable record for producer commission earned on a policy or premium transaction, pending disbursement. One row per commission payable. Tracks producer, policy, earned amount, withheld amount, and settlement status. | 54 |
| payment_disbursement | disbursement | transactional_data | Outbound payment to a producer, claimant, or payee, including producer commission payable pending settlement. One row per disbursement. Captures payee party, producer, policy, disbursement type (commission, refund, return premium), earned/withheld amount | 57 |

<a id="domain-catastrophe"></a>

### Domain: Catastrophe

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| catastrophe | business | 2 | Provisional description for user-specified domain 'catastrophe_geography'. Awaiting a generated description of what this domain owns. | 6 |

**Subdomains:** catastrophe_exposure, peril_modeling


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| catastrophe_exposure | cat_zone | master_data | Insurer-defined CAT zone or territory used for exposure aggregation and PML modeling. One row per zone. Zones map to peril types (wind, quake, flood) and carry AAL and PML thresholds for reinsurance treaty attachment. | 40 |
| catastrophe_exposure | event | master_data | Master record of a named CAT event (hurricane, quake, wildfire, flood, tornado), one row per event. Captures event type, peril, date range, footprint, industry loss estimate, PML class, ISO CAT serial number, event name, and affected states for statutory | 45 |
| catastrophe_exposure | geography | reference_data | Enterprise geography hierarchy node (country, state, county, ZIP, CRESTA zone, census tract). One row per geography unit. Provides the spatial backbone for territory rating, CAT aggregation, and regulatory reporting. | 31 |
| peril_modeling | cat_model_peril_config | association_data | Governs which CAT model version is approved and calibrated for each peril. One row per model version per peril. Carries calibration date, validation status, regulatory approval, and supported return periods for the specific model-peril combination.. | 14 |
| peril_modeling | cat_model_version | reference_data | Reference record for a CAT model vendor version (e.g., RMS v23, AIR Touchstone 2024). One row per vendor per version. Tracks release date, supported perils, geographic coverage, and the effective date range for which results are authoritative. | 34 |
| peril_modeling | peril | reference_data | Reference catalog of insured perils (wind, hail, earthquake, flood, fire, theft, liability). One row per peril. Carries NAIC peril code, CAT vs. non-CAT flag, reinsurance treaty peril mapping, and ISO cause-of-loss code. | 36 |

<a id="domain-claim"></a>

### Domain: Claim

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| claim | business | 2 | Provisional description for user-specified domain 'claims'. Awaiting a generated description of what this domain owns. | 14 |

**Subdomains:** claim_lifecycle, financial_settlement


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| claim_lifecycle | adjuster | master_data | Staff or independent adjuster assigned to handle claims. Captures adjuster type (staff/IA/TPA), license number, state appointments, assignment capacity, and links to Party domain for identity. | 36 |
| claim_lifecycle | claim | master_data | Claim: A reported loss or demand for indemnification under a policy. GRAIN: One row per reported loss. Grain: one row per reported loss. | 42 |
| claim_lifecycle | claimant | master_data | Grain: one row per claimant per claim. Records each party asserting a loss under a claim, distinguishing First Party (insured) from Third Party (injured/damaged third party). Links Claim to Party. | 47 |
| claim_lifecycle | exposure | association_data | Claim Exposure: The coverage line within a claim, linking Claim to Coverage and Insured Risk. GRAIN: One row per coverage line per claim. Grain: one row per coverage line per claim. | 51 |
| claim_lifecycle | fnol | transactional_data | First Notice of Loss intake record. Grain: one row per FNOL submission. Captures report channel, reporter party, initial loss description, date/time of loss, and triage flags before a formal claim is opened. | 48 |
| claim_lifecycle | loss_event | master_data | Grain: one row per loss event. Represents a discrete occurrence (storm, accident, fire) that may give rise to one or more claims. Links to Catastrophe Event for cat-coded losses. | 56 |
| claim_lifecycle | status | master_data | One row per status change per claim. Tracks the full status lifecycle of a claim (e.g., Open, Pending, Closed, Reopened) with effective dating to reconstruct status at any point in time. | 16 |
| financial_settlement | claim_payment | transactional_data | Claim Payment: Payments made on claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure. | 52 |
| financial_settlement | claimfinancials_accounting_period | reference_data | Reference calendar for financial close cycles. Defines calendar year, accident year, policy year, and fiscal period boundaries used to bucket premium, loss, and expense transactions for statutory and GAAP reporting. | 36 |
| financial_settlement | expense | transactional_data | Claim Expense: LAE, DCC, and AO expenses on claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure. | 48 |
| financial_settlement | financial_snapshot | transactional_data | Point-in-time financial position per claim exposure as of a valuation date. Stores total incurred (paid + case reserve), IBNR allocation, ceded amounts, net retained position, and prior-period comparison for statutory reporting. | 51 |
| financial_settlement | recovery | transactional_data | Recovery: Subrogation, salvage, and reinsurance recoveries on claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure. | 45 |
| financial_settlement | reserve | transactional_data | Reserve: Case, IBNR, and LAE reserve amounts for claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure. | 51 |
| financial_settlement | salvage | master_data | Master record for salvage activity on a total-loss insured item. Tracks salvage value estimate, auction proceeds, title transfer status, storage costs, net salvage amount, and disposition method per claim exposure. | 48 |

<a id="domain-claim"></a>

### Domain: Claim

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| claim | business | 2 | Provisional description for user-specified domain 'claim_financials'. Awaiting a generated description of what this domain owns. | 14 |

**Subdomains:** claim_lifecycle, financial_settlement


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| claim_lifecycle | adjuster | master_data | Staff or independent adjuster assigned to handle claims. Captures adjuster type (staff/IA/TPA), license number, state appointments, assignment capacity, and links to Party domain for identity. | 36 |
| claim_lifecycle | claim | master_data | Claim: A reported loss or demand for indemnification under a policy. GRAIN: One row per reported loss. Grain: one row per reported loss. | 42 |
| claim_lifecycle | claimant | master_data | Grain: one row per claimant per claim. Records each party asserting a loss under a claim, distinguishing First Party (insured) from Third Party (injured/damaged third party). Links Claim to Party. | 47 |
| claim_lifecycle | exposure | association_data | Claim Exposure: The coverage line within a claim, linking Claim to Coverage and Insured Risk. GRAIN: One row per coverage line per claim. Grain: one row per coverage line per claim. | 51 |
| claim_lifecycle | fnol | transactional_data | First Notice of Loss intake record. Grain: one row per FNOL submission. Captures report channel, reporter party, initial loss description, date/time of loss, and triage flags before a formal claim is opened. | 48 |
| claim_lifecycle | loss_event | master_data | Grain: one row per loss event. Represents a discrete occurrence (storm, accident, fire) that may give rise to one or more claims. Links to Catastrophe Event for cat-coded losses. | 56 |
| claim_lifecycle | status | master_data | One row per status change per claim. Tracks the full status lifecycle of a claim (e.g., Open, Pending, Closed, Reopened) with effective dating to reconstruct status at any point in time. | 16 |
| financial_settlement | claim_payment | transactional_data | Claim Payment: Payments made on claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure. | 52 |
| financial_settlement | claimfinancials_accounting_period | reference_data | Reference calendar for financial close cycles. Defines calendar year, accident year, policy year, and fiscal period boundaries used to bucket premium, loss, and expense transactions for statutory and GAAP reporting. | 36 |
| financial_settlement | expense | transactional_data | Claim Expense: LAE, DCC, and AO expenses on claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure. | 48 |
| financial_settlement | financial_snapshot | transactional_data | Point-in-time financial position per claim exposure as of a valuation date. Stores total incurred (paid + case reserve), IBNR allocation, ceded amounts, net retained position, and prior-period comparison for statutory reporting. | 51 |
| financial_settlement | recovery | transactional_data | Recovery: Subrogation, salvage, and reinsurance recoveries on claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure. | 45 |
| financial_settlement | reserve | transactional_data | Reserve: Case, IBNR, and LAE reserve amounts for claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure. | 51 |
| financial_settlement | salvage | master_data | Master record for salvage activity on a total-loss insured item. Tracks salvage value estimate, auction proceeds, title transfer status, storage costs, net salvage amount, and disposition method per claim exposure. | 48 |

<a id="domain-party"></a>

### Domain: Party

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| party | business | 1 | SSOT for all persons and organizations the insurer interacts with: policyholders, named/additional insureds, claimants, producers, adjusters, and payees. Owns identity, demographics, KYC, and deduplication. | 3 |

**Subdomains:** party_core


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| party_core | address | master_data | Physical and mailing addresses for a party. One row per address per party. Stores address type (mailing, risk, billing), street, city, state, ZIP+4, county, country, geocode, and effective dates. | 43 |
| party_core | party | master_data | SSOT master record for every person or organization the insurer interacts with. One row per party. Owns golden-record identity, KYC status, dedup keys, and MDM flags. Tax IDs and external keys live in identifier, not here. | 44 |
| party_core | role | master_data | Assigns a role to a party with effective and expiration dates. One row per party-role assignment. Roles include policyholder, named insured, additional insured, claimant, producer, adjuster, and payee. Never embeds role on the party record. | 42 |

<a id="domain-policy"></a>

### Domain: Policy

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| policy | business | 1 | Authoritative record of the insurance contract lifecycle. Owns Policy (one row per policy), Policy Term (one row per policy per term), and Policy Transaction (NB, REN, END, CAN, RI, NR). | 3 |

**Subdomains:** policy_core


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| policy_core | policy | master_data | Grain: one row per policy. Master contract record linking a party (policyholder) to a line of business. Lifecycle managed via Policy Term and Policy Transaction children. | 45 |
| policy_core | policy_transaction | transactional_data | Grain: one row per policy transaction. Records lifecycle events: New Business, Renewal, Endorsement, Cancellation, Reinstatement, Non-renewal. Drives written premium change and coverage versioning. | 43 |
| policy_core | term | master_data | Grain: one row per policy per term. Time-bounded period of a policy (e.g., annual term). Effective dating enables reconstruction of coverages and premium in force at any date, including loss date. | 45 |

<a id="domain-premium"></a>

### Domain: Premium

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| premium | business | 3 | Transactional ledger for all premium activity. Owns Premium Transaction (one row per financial transaction: Written, Earned, Unearned, Return) tied to Policy, Policy Term, Coverage, Insured Risk, and Accounting Period, with Charge, Tax, Fee, and | 12 |

**Subdomains:** adjustable_rating, earning_calculation, transaction_booking


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| adjustable_rating | audit | transactional_data | Result of a final or interim audit for auditable policies (WC, GL, CGL). Captures audited exposure basis, audited premium, variance from estimated/deposit premium, and deposit reconciliation status. Triggers additional or return premium transactions. | 48 |
| adjustable_rating | ceded_premium | transactional_data | Records premium ceded to reinsurers under a Treaty or Facultative Agreement per Policy Term and Coverage; ceded written/earned/unearned by accounting period. Candidate for relocation to Reinsurance, which owns the cession ledger. | 46 |
| adjustable_rating | deposit_premium | transactional_data | Tracks the estimated deposit premium collected at policy inception for auditable or retro-rated policies. Stores deposit amount, basis of estimate, and reconciliation status against final audit or retro adjustment. | 49 |
| adjustable_rating | retrospective_adjustment | transactional_data | Records a retro premium adjustment for retrospectively-rated policies. Captures adjustment number, evaluation date, standard premium, loss conversion factor, retro premium computed, and variance from prior adjustment. | 51 |
| earning_calculation | earned_premium_schedule | transactional_data | Pro-rata or short-rate earning schedule for a Coverage within a Policy Term. Defines daily or monthly earned and unearned premium amounts used to compute EP at any in-force date. Supports IFRS 17 and Schedule P actuarial triangles. | 48 |
| earning_calculation | endorsement | transactional_data | Records the net premium change (additional or return) generated by a Policy Transaction endorsement, cancellation, or reinstatement. Links the endorsing Policy Transaction to the resulting Premium Transactions and charge breakdown. | 46 |
| earning_calculation | rate_table | reference_data | Versioned rate table published by the rating engine for a specific LOB, state, and effective date. Stores base rates, factors, and minimum premiums. Provides the authoritative rate version used to price each Policy Term. | 47 |
| transaction_booking | charge | transactional_data | Child of Premium Transaction. One row per charge component (base premium, surcharge, credit, minimum premium) within a transaction. Enables granular decomposition of gross written premium by rating element and LOB. | 51 |
| transaction_booking | commission | transactional_data | Child of Premium Transaction. One row per producer commission calculation on a transaction: type (new/renewal/contingent), rate, basis, and computed payable. Calculation-only; commission settlement/payout is owned by the producers domain. | 39 |
| transaction_booking | policy_fee | transactional_data | Child of Premium Transaction. One row per non-premium fee (policy fee, inspection fee, installment fee) charged on a transaction. Fees are non-taxable in most jurisdictions and tracked separately from taxable premium. | 41 |
| transaction_booking | premium_transaction | transactional_data | Grain: one row per financial premium transaction (Written, Earned, Unearned, Return). Tied to Policy, Policy Term, Coverage, Insured Risk, and Accounting Period. Parent of Charge, Tax, Fee, Commission. | 51 |
| transaction_booking | tax_levy | transactional_data | Child of Premium Transaction. One row per state or surplus-lines tax, stamping fee, or regulatory assessment applied to a premium transaction. Tracks tax type, jurisdiction, rate, and computed amount for statutory remittance. | 37 |

<a id="domain-producers"></a>

### Domain: Producers

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| producers | business | 2 | Provisional description for user-specified domain 'producers'. Awaiting a generated description of what this domain owns. | 6 |

**Subdomains:** commission_management, producer_network


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| commission_management | commission_schedule | master_data | Contractual commission rate set for a producer or agency by LOB, transaction type (NB/REN/END), and coverage type over an effective period. One row per schedule version. Holds all rate lines (base, contingent, override) as embedded detail. | 44 |
| commission_management | commission_transaction | transactional_data | One row per commission financial movement earned by a producer on a premium transaction. Captures earned amount, claw-back amount, transaction type, accounting period, and payment status. Child of premium transaction. | 46 |
| producer_network | agency | master_data | Master record for an insurance agency or brokerage firm. One row per agency. Captures agency name, FEIN, NAIC code, principal address, agency type, and parent agency hierarchy for MGA and wholesale relationships. | 32 |
| producer_network | distribution_channel | reference_data | Reference classification of how business reaches the insurer (captive, independent, broker, direct, MGA, wholesale, affinity, digital). One row per channel. Drives commission schedule selection and producer underwriting authority rules. | 36 |
| producer_network | producer | master_data | Master record for every licensed insurance producer (agent or broker). One row per producer. Stores NPN, license numbers, resident state, producer type, appointment status, and E&O coverage details. | 42 |
| producer_network | producer_appointment | master_data | One row per appointment per producer per line of business. Records the formal authorization granted to a producer to sell a specific LOB, with effective and termination dates governing the active appointment window. | 20 |

<a id="domain-risk"></a>

### Domain: Risk

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| risk | business | 2 | Provisional description for user-specified domain 'risk_exposure'. Awaiting a generated description of what this domain owns. | 7 |

**Subdomains:** exposure_supertype, vehicle_coverage


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| exposure_supertype | building | master_data | Grain: one row per building at a location. Physical building subtype beneath Location capturing construction, occupancy, and valuation attributes. FK to risk.location. Supports Property Risk hierarchy per VREQ-005. | 27 |
| exposure_supertype | insured_risk | master_data | Supertype master for every insurable object underwritten on a policy. One row per insured risk. Subtypes property_risk and auto_risk extend it via shared PK (explicit subtype FK). | 42 |
| exposure_supertype | location | master_data | Property Risk subtype. Grain: one row per insured location. Represents a distinct physical location under a Property Risk, linking to geography and catastrophe zone for territory and cat aggregation. | 66 |
| exposure_supertype | property_risk | master_data | Property-line subtype of insured_risk. One row per property risk. Captures COPE attributes (Construction, Occupancy, Protection, Exposure), ITV, year built, square footage, and ISO construction class for rating and CAT modeling. | 48 |
| vehicle_coverage | auto_risk | master_data | Auto Risk subtype of Insured Risk. Grain: one row per auto risk per policy term. Groups Vehicle and Driver records under a single insured risk. FK to insured_risk (supertype) and policy term. | 38 |
| vehicle_coverage | driver | master_data | Auto Risk subtype. One row per rated driver per auto risk. Captures license, experience, and MVR attributes for a driver associated with a specific auto risk exposure. FK to auto_risk and party. | 45 |
| vehicle_coverage | vehicle | master_data | Motor vehicle associated with an auto risk. One row per vehicle. Stores VIN, year, make, model, body type, ISO symbol, stated value, anti-theft device indicator, and safety rating for auto rating and claims. | 47 |

<a id="domain-shared"></a>

### Domain: Shared

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| shared | corporate | 1 | Cross-domain shared reference entities (currency, UoM, calendar, classification) consolidated for Single Source of Truth (SSOT). | 3 |

**Subdomains:** shared_core


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| shared_core | calendar | Master | Enterprise calendar reference of fiscal, accident, policy, and calendar-year periods. One row per period. Complements domain-local accounting_period tables by providing a single cross-domain date dimension. | 32 |
| shared_core | currency | Master | Reference catalog of ISO 4217 currencies used across premium, claim, billing, and reinsurance financial transactions. One row per currency code. Carries code, name, minor unit, and active flag. | 19 |
| shared_core | line_of_business | Master | Reference catalog of P&C lines of business (HO, PAP, CGL, BOP, CPP, WC, Commercial Auto, Umbrella). One row per LOB. SSOT for LOB codes referenced by policy, coverage, premium, claim, and reinsurance. | 29 |

## Metric Views

Total metric views generated: **91**. Showing top 20.

| # | View Name | Domain | Source Table | Description |
|---|---|---|---|---|
| 1 | coverage | coverage | coverage | Grain: one row per coverage per policy term. Core coverage portfolio metrics — in-force exposure, limit adequacy, deductible structure, premium by coverage, and cession rates for reinsurance monitoring. |
| 2 | coverage_binder | coverage | binder | Grain: one row per binder. Measures binding activity, premium at bind, commission costs, binding authority utilization, and binder-to-policy conversion across the underwriting workflow. |
| 3 | coverage_inspection_order | coverage | inspection_order | Grain: one row per inspection order. Measures inspection volume, completion rates, cycle times, risk quality findings, and vendor performance across the property and auto inspection workflow. |
| 4 | coverage_loss_history | coverage | loss_history | Grain: one row per prior loss record per insured risk. Measures prior loss frequency, severity, surcharge impact, and verification quality used in underwriting selection and experience rating. |
| 5 | coverage_quote | coverage | quote | Grain: one row per quote version. Measures quoting activity, premium adequacy, conversion, and producer performance across the quote-to-bind funnel. |
| 6 | coverage_rating_worksheet | coverage | rating_worksheet | Grain: one row per rating run per coverage. Measures rating engine output quality, premium components, modifier usage, override rates, and minimum premium application across the pricing workflow. |
| 7 | coverage_submission | coverage | submission | Grain: one row per submission. Tracks the top-of-funnel underwriting pipeline — volume, estimated premium, risk appetite, referral rates, and conversion signals from submission intake through eligibility determination. |
| 8 | coverage_underwriting_risk_score | coverage | underwriting_risk_score | Grain: one row per risk score run per insured risk. Measures composite and component risk scores, score distribution, override rates, and loss history inputs used in underwriting pricing and selection decisions. |
| 9 | coverage_uw_decision | coverage | uw_decision | Grain: one row per underwriting decision. Measures underwriting throughput, decision quality, SLA compliance, referral resolution, and risk tier distribution across the underwriting workflow. |
| 10 | coverage_uw_referral | coverage | uw_referral | Grain: one row per underwriting referral. Measures referral volume, resolution outcomes, SLA compliance, escalation patterns, and premium at risk across the referral management workflow. |
| 11 | reinsurance_bordereaux | reinsurance | bordereaux | Grain: one row per bordereaux submission — the periodic reinsurance accounting statement sent to reinsurers. Tracks ceded premium, losses, reserves, commissions, and net settlement balances per reporting period and reinsurer. |
| 12 | reinsurance_bordereaux_line | reinsurance | bordereaux_line | Grain: one row per bordereaux line item — the individual policy, claim, or risk detail within a bordereaux submission. Enables granular ceded premium and loss analysis by policy, coverage, peril, and reinsurance layer. |
| 13 | reinsurance_cession | reinsurance | cession | Grain: one row per reinsurance cession — the transfer of a specific risk or policy term to a reinsurance agreement. Tracks ceded premium, reserves, TIV, limits, and commission at the cession level across treaties and facultative agreements. |
| 14 | reinsurance_fac_agreement | reinsurance | fac_agreement | Grain: one row per facultative reinsurance agreement — a risk-specific placement covering a single policy or insured risk. Tracks ceded premium, limits, commissions, and placement terms for facultative program management. |
| 15 | reinsurance_reinsurer | reinsurance | reinsurer | Grain: one row per reinsurer entity. Tracks reinsurer credit quality, authorization status, collateral, and panel composition for counterparty risk management and regulatory compliance. |
| 16 | reinsurance_ri_agreement | reinsurance | ri_agreement | Grain: one row per reinsurance agreement — the master contract governing treaty or facultative placements. Tracks agreement terms, premium, limits, retention, commission, and program structure for reinsurance program governance. |
| 17 | reinsurance_ri_claim_cession | reinsurance | cession | Grain: one row per reinsurance claim cession — the linkage of a specific claim to a reinsurance agreement layer. Tracks ceded losses, LAE, reserves, recoveries, and recovery status per claim, cession, and accident year. |
| 18 | reinsurance_ri_premium_transaction | reinsurance | ri_premium_transaction | Grain: one row per reinsurance premium financial transaction. Tracks ceded written, earned, unearned, return premium, ceding commission, and profit commission across treaties, facultative agreements, reinsurers, and policy years. Core P&C reinsurance premium ledger. |
| 19 | reinsurance_ri_recovery | reinsurance | ri_recovery | Grain: one row per reinsurance recovery financial movement. Tracks billed, collected, and outstanding recovery amounts per claim, reinsurer, and accounting period. Core metric for reinsurance collectibility and cash management. |
| 20 | reinsurance_treaty | reinsurance | treaty | Grain: one row per reinsurance treaty — a standing agreement covering a portfolio of risks. Tracks treaty terms, premium, limits, retention, commission, and profit commission for treaty program management and renewal negotiations. |

*... and 71 more metric views. See the `metrics/` folder for full details.*