# Pc_Insurance Lakehouse Data Model

**v3_ecm** generated using Vibe Modelling Agent on September 21, 2026 at 08:20 AM

This document outlines a vibed Lakehouse data model for the Pc_Insurance business that can be deployed to Databricks Platform. The model is structured into business-aligned domains and denormalized data products, optimized for analytical workloads.

## Table of Contents

- [Output Folder Structure](#output-folder-structure)
- [Model Metrics](#model-metrics)
- [Business Summary](#business-summary)
- [Business Domains & Subdomains](#business-domains--subdomains)
  - [Coverage](#domain-coverage)
  - [Reinsurance](#domain-reinsurance)
  - [Underwriting](#domain-underwriting)
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

All artifacts for version **v3_ecm** are organized as follows:

```
v3/ecm/
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
| `schemas/` | `pc_insurance_<domain>_schema_v3_ecm.sql` (combined per-domain SQL: schemas/databases + tables with inline PKs + FKs + tags) |
| `schemas/` | `pc_insurance_catalogs_v3_ecm.sql` (catalog-level DDL) |
| `metrics/` | `pc_insurance_<domain>_metrics_v3_ecm.sql` (one file per domain) |
| `docs/` | `pc_insurance_model_v3_ecm.xlsx`, `pc_insurance_model_v3_ecm.csv`, `releasenotes.txt` |
| `diagram/` | `pc_insurance_dbml_v3_ecm.dbml` |
| `vibes/` | `current_vibes.txt`, `next_vibes.txt` |
| `/` | `model.json` (full model with requirements, metadata, and model data) |
| `ontology/` | `pc_insurance_rdf_v3_ecm.rdf` |
| `samples/` | One CSV file per data product (e.g., `customer.csv`, `order.csv`) |

## Model Metrics
| Metric | Value |
|---|---|
| Model Scope | ECM (Expanded Coverage Model) |
| Total Domains | 13 |
| Total Subdomains | 35 |
| Total Products | 226 |
| Total Attributes | 8802 |
| Primary Keys | 227 |
| Foreign Keys | 1256 |
| Avg Attributes/Product | 38.9 |
| Metric Views | 128 |

## Business Summary
| Business | Industry Alignment | Model Scope | Description | References | Version |
|---|---|---|---|---|---|
| Pc_Insurance | Property-and-Casualty-Insurance | ECM (Expanded Coverage Model) | A Property & Casualty insurer underwriting personal and commercial lines. Prospects submit risk information, underwriters evaluate and price it, and quotes are bound into policies that renew, endorse, cancel, and reinstate over time. Policies carry coverages with limits, deductibles, exclusions, and conditions that attach to insured risks (properties, buildings, vehicles, drivers). Premium is booked as written, earned, unearned, and return transactions with charges, taxes, fees, and producer commission. Claims record loss events, claimants, and per-coverage exposures, with reserves, payments, recoveries, and expenses tracked as financial movements. Risk is distributed through agents and brokers and ceded through reinsurance treaties and facultative agreements, with catastrophe and geography used to aggregate exposure. | NAIC (National Association of Insurance Commissioners), State Departments of Insurance (DOI), NAIC Model Laws & Regulations, ISO (Insurance Services Office) forms & rating, ACORD (Association for Cooperative Operations Research and Development) data standards, NIPR (National Insurance Producer Registry), FIO (Federal Insurance Office), NFIP (National Flood Insurance Program - FEMA), Statutory Accounting Principles (SAP/SSAP), US GAAP (FASB), IFRS 17 (IASB), Sarbanes-Oxley (SOX), NAIC ORSA & RBC requirements, State Guaranty Associations, NCCI (National Council on Compensation Insurance), Surplus Lines Stamping Offices, Fair Credit Reporting Act (FCRA), Gramm-Leach-Bliley Act (GLBA), Solvency II (for international/EU business), Model Audit Rule (MAR), NAIC Market Conduct Standards, GDPR/CCPA (data privacy), PCI DSS (payment card security) | 3 |

## Business Domains & Subdomains

<a id="domain-coverage"></a>

### Domain: Coverage

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| coverage | operations | 4 | Bridge between the policy contract and the insured risk. Owns Coverage (one row per coverage per policy term) with attached Limit, Deductible, Exclusion, and Condition. | 45 |

**Subdomains:** coverage_terms, placement_authority, rating_rules, submission_underwriting


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| coverage_terms | additional_interest | master_data | Additional interest or additional insured attached to a coverage: party reference, interest type (AI, loss payee, mortgagee, lienholder), certificate holder flag, and effective dates. | 35 |
| coverage_terms | coverage | master_data | Coverage: The bridge between the policy contract and insured risk, defining what is covered. GRAIN: One row per coverage per policy term. Grain: one row per coverage per policy term. | 44 |
| coverage_terms | coverage_condition | master_data | Condition attached to a coverage: coinsurance, reporting, inspection, warranty, or margin clause. SOLE owner of coinsurance percentage, agreed-value indicator, margin percentage, penalty method, plus clause text, compliance status, and effective dates. | 36 |
| coverage_terms | coverage_endorsement | transactional_data | Endorsement modifying a base coverage: endorsement number, form reference, effective date, premium impact, and change description. One row per endorsement per coverage. | 33 |
| coverage_terms | coverage_form | reference_data | ISO or manuscript form attached to a coverage or policy term. Tracks form number, edition date, form type (base, endorsement, exclusion), and filing status with the DOI. | 36 |
| coverage_terms | coverage_interest | association_data | One row per party-role per coverage. Captures the insurable interest a party holds in a specific coverage, including interest type, role, effective dates, and interest percentage. Enables multiple parties with different interests on one coverage.. | 11 |
| coverage_terms | coverage_transaction | association_data | Event recording a policy transaction's impact on a specific coverage. One row per coverage per transaction. Captures transaction-specific changes: premium delta, limit adjustments, effective dates, and status changes for audit and endorsement processing.. | 18 |
| coverage_terms | deductible | master_data | Deductible attached to a coverage: flat, percentage, SIR, or disappearing. Captures amount, basis, application method, and waiver flags. One row per deductible per coverage. | 35 |
| coverage_terms | exclusion | master_data | Exclusion attached to a coverage: ISO or manuscript exclusion code, description, endorsement reference, and effective dates. One row per exclusion per coverage. | 34 |
| coverage_terms | form_attachment | association_data | One row per form attached to a coverage. Captures the attachment of ISO/ACORD forms and endorsements to specific coverages, recording attachment sequence, effective dates, mandatory status, and premium impact per coverage.. | 12 |
| coverage_terms | limit | master_data | Limit attached to a coverage: occurrence limit, aggregate limit, per-person limit, split limits. Supports stacked, CSL, and sublimit structures. One row per limit per coverage. | 35 |
| coverage_terms | part | master_data | Named coverage part within a CPP or BOP (e.g., Commercial Property, CGL, Commercial Auto). Groups coverages under a single policy package. One row per coverage part per policy term. | 45 |
| coverage_terms | shared_limit_group | master_data | Master reference table for shared_limit_group. Referenced by shared_limit_group_id. | 25 |
| placement_authority | coverage_cession | association_data | One row per coverage per treaty layer. Records the reinsurance placement linking a ceded coverage to a specific treaty layer with cession terms, attachment point, limit, and retention amount.. | 12 |
| placement_authority | eligibility | association_data | Association between coverage types and reinsurance agreements defining which coverages are eligible for cession under each treaty or facultative agreement. One row per coverage type per agreement.. | 12 |
| placement_authority | facultative_marketing | association_data | Tracks facultative reinsurance marketing activity per submission. Each record links one submission to one reinsurer approached for facultative interest, capturing contact date, interest level, and indicative terms provided during the marketing phase.. | 10 |
| placement_authority | facultative_quotation | association_data | Captures each reinsurer's quoted terms for a specific facultative submission quote. Grain: one row per quote per reinsurer. Stores quoted share, premium, acceptance status, and quote date for facultative placement.. | 15 |
| placement_authority | producer_coverage_authority | association_data | Binding authority granted to a producer for a specific coverage type. Captures authority level, binding limits, effective dates, and referral thresholds per producer-coverage combination. One row per producer per coverage type per authority period.. | 9 |
| rating_rules | coverage_peril | reference_data | Reference catalog of insured perils: peril code, name, peril group (fire, wind, flood, theft, liability), CAT indicator, and NAIC peril classification. Referenced by coverage_peril_link and claims. One row per peril. | 29 |
| rating_rules | coverage_type | reference_data | Reference catalog of coverage types: coverage code, name, LOB, ISO coverage symbol, mandatory/optional flag. Standardizes coverage classification across lines. One row per coverage type. | 39 |
| rating_rules | peril_link | association_data | Association between a coverage and the perils it insures. Captures whether the peril is included or excluded, sublimit override, and deductible override at the peril level. One row per peril per coverage. | 42 |
| rating_rules | rate | transactional_data | Rate element applied to a coverage during pricing: rate code, rate basis, rate value, territory factor, class factor, and effective date. Supports reconstruction of premium at any point in time. | 40 |
| rating_rules | rating_rule_set | master_data | Master reference table for rating_rule_set. Referenced by rating_rule_set_id. | 39 |
| rating_rules | type_peril | association_data | Defines which perils are covered under each coverage type, with peril-specific deductible structures, sublimits, and coverage triggers. One row per coverage type per applicable peril.. | 10 |
| submission_underwriting | bind_request | transactional_data | Formal request to bind a quoted policy, submitted by producer or applicant. Grain: one row per bind request. Captures requested effective date, payment plan, and bind confirmation or rejection reason. | 45 |
| submission_underwriting | binder | transactional_data | Temporary insurance contract issued upon bind confirmation, providing coverage before the formal policy is issued. Captures binder number, effective/expiration dates, LOB, and issuing authority. | 42 |
| submission_underwriting | clearance_check | transactional_data | Submission screening result covering duplicate/clearance detection AND eligibility/risk-appetite evaluation (absorbs eligibility_check). Grain: one row per screening event per submission. | 42 |
| submission_underwriting | eligibility_check | transactional_data | Records the outcome of automated eligibility and risk appetite screening for a submission. Grain: one row per eligibility evaluation. Captures rule set version, pass/fail flags, and triggered rule IDs. | 35 |
| submission_underwriting | inspection_order | transactional_data | External UW report/order covering property inspection AND motor vehicle record (absorbs underwriting_mvr_report). Grain: one row per order. Captures order_type (interior/exterior/COPE/MVR), vendor, order date, status, findings, violation/license data, and | 49 |
| submission_underwriting | loss_history | master_data | Prior loss record for a submission or insured risk from CLUE, MVR, or applicant disclosure: loss date, cause, paid amount, open/closed status. Grain: one row per prior loss. Used in appetite and pricing. | 48 |
| submission_underwriting | quote | transactional_data | Priced insurance proposal generated from a submission. Grain: one row per quote. Captures quoted premium, LOB, effective date, expiration date, quote status, and binding eligibility flag. | 44 |
| submission_underwriting | quote_coverage | transactional_data | Coverage line proposed within a quote: quoted limit, deductible, form number, and coverage-level premium. Junction between quote and coverage form. Grain: one row per coverage per quote; prevents premium fan-out. | 49 |
| submission_underwriting | quote_option | transactional_data | Alternative pricing scenario or coverage option presented within a single quote (e.g., higher deductible, broader form). Enables multi-option proposals. One row per option per quote. | 41 |
| submission_underwriting | rating_factor | transactional_data | Individual rating factor applied within a rating worksheet (e.g., territory factor, class factor, experience mod, schedule credit). One row per factor per worksheet. Supports full rate reconstruction. | 32 |
| submission_underwriting | rating_worksheet | transactional_data | Detailed rating calculation produced by the rating engine for a quote or policy transaction: rate table version, base rate, surcharges, credits, and final rated premium. Grain: one row per rating run per quote. | 47 |
| submission_underwriting | risk_appetite_rule | reference_data | Business-managed, versioned, effective-dated UW governance (absorbs uw_guideline): eligibility/appetite rules, guideline criteria, class restrictions, mandatory-endorsement and pricing constraints by LOB, state, and class that trigger accept, decline, or | 36 |
| submission_underwriting | submission | transactional_data | ACORD 125/126/140 submission record capturing prospect risk information submitted for UW evaluation. Grain: one row per submission. Tracks source, status, line of business, and submission date. | 46 |
| submission_underwriting | submission_document | transactional_data | Document attached to a submission (ACORD applications, loss runs, photos, financials, schedules). Tracks document type, source, upload date, and review status. One row per document. | 47 |
| submission_underwriting | submission_party | association_data | Associates parties (applicant, named insured, additional insured, producer) to a submission with role and effective dates. Junction table carrying role-specific UW attributes per submission. | 44 |
| submission_underwriting | submission_status_history | transactional_data | Audit trail of submission status transitions (Received, In Review, Referred, Quoted, Bound, Declined, Withdrawn). One row per status change. Supports SLA tracking and workflow analytics. | 35 |
| submission_underwriting | underwriting_mvr_report | transactional_data | Motor Vehicle Record report ordered for a driver during auto UW. Captures report order date, source, violation count, license status, and UW impact flag. One row per MVR order. | 42 |
| submission_underwriting | underwriting_risk_score | transactional_data | UW risk scoring result for a submission or insured risk. Grain: one row per scoring event. Captures model version, composite score, component scores (COPE, MVR, CLUE), and score band classification. | 50 |
| submission_underwriting | uw_condition | transactional_data | Condition or requirement imposed by the underwriter on a submission or quote (e.g., loss control survey required, protective device warranty). Tracks fulfillment status and due date. | 44 |
| submission_underwriting | uw_decision | transactional_data | Underwriter accept/decline/refer/modify decision for a submission or quote, including referral escalation (absorbs uw_referral): assigned UW, priority, SLA due date, resolution. Grain: one row per UW decision event. | 43 |
| submission_underwriting | uw_referral | transactional_data | Tracks submissions or quotes escalated beyond standard UW authority for senior review. Captures referral reason, assigned UW, priority, SLA due date, and resolution outcome. | 43 |

<a id="domain-reinsurance"></a>

### Domain: Reinsurance

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| reinsurance | operations | 3 | Manages risk transfer to reinsurers. Owns Reinsurance Agreement, Treaty (QS/XOL/SL/CAT XL), Facultative Agreement, Cession, and Reinsurance Recovery linked to ceded Policy and Claim. | 19 |

**Subdomains:** agreement_structure, cession_recovery, statutory_reporting


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| agreement_structure | agreement_peril_coverage | association_data | Captures which perils are covered, excluded, or subject to special terms within each reinsurance agreement. One row per agreement per peril. Tracks inclusion/exclusion flags, peril-specific sublimits, retentions, and clauses.. | 14 |
| agreement_structure | fac_agreement | master_data | Facultative reinsurance agreement covering a single risk or policy. One row per FAC placement. Captures cedant, reinsurer, ceded percentage, premium rate, inception/expiry, and the linked policy or submission. | 49 |
| agreement_structure | reinsurer | master_data | Master record for each reinsurance counterparty (assuming company, Lloyd's syndicate, or pool). One row per reinsurer. Stores legal name, NAIC code, AM Best rating, domicile, and authorized/unauthorized status for Schedule F credit. | 40 |
| agreement_structure | ri_agreement | master_data | Master record for a reinsurance agreement between the cedant and one or more reinsurers. One row per agreement. Captures agreement type (Treaty/Facultative), status, inception/expiry, governing law, and currency. | 48 |
| agreement_structure | ri_participant | master_data | Allocation of a reinsurer's share within a treaty or FAC agreement. One row per reinsurer per agreement. Captures signed line percentage, written line percentage, and participation effective dates. | 37 |
| agreement_structure | treaty | master_data | Defines a proportional or non-proportional treaty under a reinsurance agreement. One row per treaty. Captures treaty type (QS/XOL/SL/CAT XL), layer, retention, limit, ROL, and UNL basis. | 46 |
| agreement_structure | treaty_layer | master_data | Individual attachment/exhaustion layer within an XOL or CAT XL treaty. One row per layer per treaty. Stores attachment point, limit per occurrence, annual aggregate limit, and reinstatement terms. | 49 |
| agreement_structure | treaty_layer_peril_term | association_data | Captures peril-specific reinsurance terms within a treaty layer. Each record links one treaty layer to one peril with attachment points, limits, retention, cession percentages, and rates that vary by peril.. | 13 |
| agreement_structure | treaty_zone_terms | association_data | Defines zone-specific reinsurance treaty terms for catastrophe exposure management. One row per treaty per cat zone. Captures zone-level cession percentages, retentions, attachment points, limits, and exclusions used for underwriting guidelines and | 12 |
| cession_recovery | reinsurance_cession | transactional_data | Records risk transfer of a policy term to a treaty layer or FAC. Grain: one row per policy term per treaty layer (or FAC). Direction flag (outward/retro) distinguishes cession from retrocession. | 50 |
| cession_recovery | ri_claim_cession | transactional_data | Links a claim exposure to a reinsurance treaty layer or FAC agreement for loss recovery eligibility. One row per claim exposure per treaty layer. Stores ceded loss amount, ceded LAE, and UNL calculation basis. | 49 |
| cession_recovery | ri_collateral | master_data | Tracks collateral (letters of credit, trust funds, funds withheld) posted by unauthorized reinsurers to support ceded reserves. One row per collateral instrument. Stores type, amount, expiry, and regulatory jurisdiction. | 45 |
| cession_recovery | ri_premium_transaction | transactional_data | Ceded premium ledger. One row per financial movement (written, earned, unearned, return, reinstatement) for a cession. FK to cession, accounting period, treaty layer. Reinstatement rows carry occurrence reference and reinstated limit. | 49 |
| cession_recovery | ri_recovery | transactional_data | Single ceded loss ledger. Grain: one row per movement per ri_claim_cession per accounting period, discriminated by movement_type: case/IBNR/LAE reserve position, or cash recovery (loss/LAE/DCC, subrogation, salvage). | 44 |
| cession_recovery | ri_reinstatement | transactional_data | Records the reinstatement of treaty limit after a loss occurrence exhausts a layer. One row per reinstatement event per treaty layer. Captures reinstatement premium, reinstated limit, occurrence reference, and effective date. | 47 |
| cession_recovery | ri_settlement | transactional_data | Net cash settlement between cedant and reinsurer, per reinsurer per period, netting ceded premium payable against loss recoverable. Includes profit commission (loss ratio, sliding-scale rate, commission amount) as a settlement component. | 51 |
| statutory_reporting | bordereaux | transactional_data | Periodic bordereau submission record sent to reinsurers summarizing ceded premium and loss activity. One row per bordereaux run per treaty per reporting period. Captures submission date, period, status, and totals. | 46 |
| statutory_reporting | reinsurance_bordereaux_line | transactional_data | Individual line item within a bordereaux submission, representing one cession or claim cession. One row per cession per bordereaux. Stores ceded premium, ceded loss, ceded LAE, and policy/claim reference keys. Belongs to a parent bordereaux run. | 50 |
| statutory_reporting | schedule_f_entry | transactional_data | Statutory Schedule F reporting entry per reinsurer per reporting year. One row per reinsurer per year. Captures assumed and ceded premium, losses, reserves, and collectibility status for NAIC Annual Statement filing. | 43 |

<a id="domain-underwriting"></a>

### Domain: Underwriting

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| underwriting | operations | 0 | Manages the front-of-pipe lifecycle from submission intake and clearance through risk appetite screening, eligibility, risk scoring, referral management, and quote generation. Owns ACORD 125/126/140 submission data, UW decisions, and bound quotes. | 1 |

**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
|  | uw_guideline | reference_data | Underwriting guideline document defining acceptable risk criteria, class restrictions, mandatory endorsements, and pricing constraints by LOB and state. Versioned and effective-dated for audit. | 42 |

<a id="domain-billing"></a>

### Domain: Billing

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| billing | business | 5 | Manages invoicing, collections, disbursements, delinquency, and installment plan processing for policyholders and payees. Owns billing accounts, invoices, payment transactions, payment plans, returned payments, and write-offs. | 21 |

**Subdomains:** account_management, commission_disbursement, delinquency_recovery, invoice_collections, payment_processing


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| account_management | account | master_data | Master billing account linking a policyholder or payee to invoicing and collections. One row per billing account. Tracks account type (direct bill, agency bill), status, payment method, and balance. | 42 |
| account_management | account_policy | association_data | Association linking a billing account to one or more policies. One row per billing-account-to-policy relationship. Supports agency bill and direct bill splits, and multi-policy billing account consolidation. | 33 |
| account_management | escrow_account | master_data | Escrow account record for mortgagee-billed policies where a lender collects and remits premium. One row per escrow account. Tracks lender party, escrow balance, disbursement schedule, and reconciliation status. | 40 |
| account_management | installment_plan | master_data | Installment schedule elected for a Policy Term with per-installment lines: number, due dates, billed/paid amounts, fees, and status. Feeds delinquency and cancellation-for-non-payment. | 45 |
| account_management | payment_method | master_data | Stored payment instrument on file for a billing account (credit card, ACH/EFT, check, escrow). One row per payment method per billing account. Captures instrument type, masked account details, expiry, and EFT authorization status. | 40 |
| account_management | payment_plan | master_data | Installment plan template defining the number of installments, down payment percentage, installment frequency, and applicable fees for a billing account or policy. Master record for plan configuration. | 33 |
| commission_disbursement | commission_payable | transactional_data | Payable record for producer commission earned on a policy or premium transaction, pending disbursement. One row per commission payable. Tracks producer, policy, earned amount, withheld amount, and settlement status. | 52 |
| commission_disbursement | disbursement | transactional_data | Outbound payment to a producer, claimant, or payee, including producer commission payable pending settlement. One row per disbursement. Captures payee party, producer, policy, disbursement type (commission, refund, return premium), earned/withheld amount | 41 |
| delinquency_recovery | billing_transaction | transactional_data | Atomic financial movement posted to a billing account (charge, credit, payment, reversal, fee, tax, write-off). One row per financial movement. Single ledger SSOT for account balance; payment, invoice_item, and write_off post here via enforced FK for | 41 |
| delinquency_recovery | delinquency | transactional_data | Delinquency lifecycle for a billing account that missed installments, including all workflow actions (past-due, cancellation, reinstatement, write-off trigger) and notices issued during collections. One row per delinquency event per account. | 45 |
| delinquency_recovery | delinquency_action | transactional_data | Individual workflow action taken within a delinquency process (notice issued, cancellation initiated, reinstatement offered, write-off triggered). One row per action per delinquency. Tracks action type, action date, and outcome. | 42 |
| delinquency_recovery | write_off | transactional_data | Record of a premium balance written off as uncollectible. One row per write-off transaction. Captures write-off amount, write-off reason (bad debt, small balance, regulatory), approval authority, and accounting period. | 45 |
| invoice_collections | invoice | transactional_data | Billing document issued to a policyholder or agency for premium charges, fees, and taxes due. One row per invoice. Grain: one invoice per billing cycle per billing account. Tracks due date, amount billed, and status. | 45 |
| invoice_collections | invoice_item | transactional_data | Line-level detail on an invoice representing a single charge, tax, fee, or commission amount. One row per line item per invoice. Links to premium charge, coverage, and policy term for reconciliation. | 45 |
| invoice_collections | notice | transactional_data | Regulatory or contractual notice generated and sent to a policyholder during the billing lifecycle (invoice notice, past-due notice, cancellation notice, reinstatement notice). One row per notice. Tracks notice type, send date, and delivery channel. | 43 |
| invoice_collections | notice_template | master_data | Master reference table for notice_template. Referenced by template_id. | 38 |
| payment_processing | installment_schedule | transactional_data | Scheduled installment records generated for a billing account under a payment plan. One row per installment. Tracks scheduled due date, scheduled amount, actual paid amount, and installment status (due, paid, past due). | 39 |
| payment_processing | payment | transactional_data | Record of a payment received from a policyholder, agency, or third party against a billing account. One row per payment transaction. Captures payment method, amount, receipt date, and application status. | 47 |
| payment_processing | payment_application | association_data | Links a payment to one or more invoices or invoice items, and holds all unapplied/suspense cash pending identification of the correct account or invoice. One row per application or suspense holding. | 43 |
| payment_processing | returned_payment | transactional_data | Record of a payment returned by the bank (NSF, stop payment, account closed). One row per returned payment event. Captures return reason code, return date, original payment reference, and any returned payment fee assessed. | 31 |
| payment_processing | suspense_item | transactional_data | Unallocated payment or credit held in suspense pending identification of the correct billing account or invoice. One row per suspense item. Tracks received amount, source, suspense reason, and resolution date. | 50 |

<a id="domain-catastrophe"></a>

### Domain: Catastrophe

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| catastrophe | business | 3 | Provisional description for user-specified domain 'catastrophe_geography'. Awaiting a generated description of what this domain owns. | 20 |

**Subdomains:** event_management, exposure_modeling, geographic_aggregation


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| event_management | cat_event_loss | transactional_data | CAT-attribution loss ESTIMATE per CAT event per LOB per geography (one row each). Holds modeled/actual gross, ceded, and net loss and IBNR loading for Schedule P CAT reporting only -- NOT the financial ledger; authoritative payments/reserves live in | 35 |
| event_management | cat_event_zone_impact | association_data | Records the impact of a catastrophe event on a specific CAT zone. One row per event per zone. Captures modeled loss, exposure metrics, physical parameters, and timestamps for loss estimation, reinsurance triggers, and regulatory reporting.. | 18 |
| event_management | cat_event_zone_xref | association_data | Association between a CAT event and the CAT zones it impacted. One row per CAT event per zone. Carries impact severity band, wind speed or shake intensity, and storm surge flag used to filter exposed policies for FNOL triage. | 40 |
| event_management | catastrophe_event | master_data | Master record of a named CAT event (hurricane, quake, wildfire, flood, tornado), one row per event. Captures event type, peril, date range, footprint, industry loss estimate, PML class, ISO CAT serial number, event name, and affected states for statutory | 42 |
| event_management | catastrophe_event_geography_exposure | association_data | Association between catastrophe events and affected geographies capturing exposure metrics. One row per catastrophe event per geography unit. Tracks TIV, policy count, insured risk count, concentration index, PML, AAL, and premium for each event-geography | 12 |
| event_management | iso_cat_serial | reference_data | ISO-assigned CAT serial number record for a recognized industry CAT event. One row per ISO CAT serial. Carries ISO serial number, event name, peril, date range, affected states, and industry insured loss estimate for statutory CAT reporting. | 37 |
| exposure_modeling | accumulation_limit | master_data | Insurer-defined maximum aggregate exposure limit per CAT zone, peril, and LOB. One row per zone per peril per LOB. Enforces underwriting appetite constraints; triggers referral or declination when TIV in zone exceeds the approved accumulation cap. | 42 |
| exposure_modeling | cat_model_version | reference_data | Reference record for a CAT model vendor version (e.g., RMS v23, AIR Touchstone 2024). One row per vendor per version. Tracks release date, supported perils, geographic coverage, and the effective date range for which results are authoritative. | 35 |
| exposure_modeling | exposure_summary | transactional_data | Single authoritative accumulation snapshot: aggregated TIV, policy count, and concentration by geography node, peril, and LOB as of an accounting date. One row per geography per peril per LOB per as-of date. | 32 |
| exposure_modeling | hazard_score | transactional_data | Point-in-time hazard score assigned to a geographic location for a specific peril by the CAT model (RMS/AIR). One row per location per peril per model version. Stores AAL, PML return periods, and hazard band for underwriting eligibility. | 39 |
| exposure_modeling | pml_return_period | transactional_data | Individual return-period result within a PML run. One row per PML run per return period (e.g., 100-yr, 250-yr, 500-yr). Stores gross loss, ceded loss, net retained loss, AAL, and coefficient of variation for reinsurance treaty sizing. | 39 |
| exposure_modeling | pml_run | transactional_data | A probabilistic PML modeling run executed against the exposure portfolio. One row per run. Captures model vendor, model version, run date, return period set, gross and net PML at each return period, and the exposure snapshot used as input. | 49 |
| exposure_modeling | policy_cat_exposure | association_data | Association linking an in-force policy to a CAT event or CAT zone for exposure tracking. One row per policy per CAT event or zone. Carries TIV, coverage type, and estimated gross loss used in FNOL triage and reinsurance bordereaux generation. | 47 |
| geographic_aggregation | cat_zone | master_data | Insurer-defined CAT zone or territory used for exposure aggregation and PML modeling. One row per zone. Zones map to peril types (wind, quake, flood) and carry AAL and PML thresholds for reinsurance treaty attachment. | 40 |
| geographic_aggregation | flood_zone | reference_data | FEMA National Flood Insurance Program (NFIP) flood zone classification. One row per FIRM panel zone. Carries flood zone designation (AE, VE, X), base flood elevation, FIRM panel number, and effective date for underwriting eligibility and rating. | 46 |
| geographic_aggregation | geography | reference_data | Enterprise geography hierarchy node (country, state, county, ZIP, CRESTA zone, census tract). One row per geography unit. Provides the spatial backbone for territory rating, CAT aggregation, and regulatory reporting. | 31 |
| geographic_aggregation | geography_hierarchy | reference_data | Parent-child closure table for the geography hierarchy. Stores ancestor-descendant pairs with depth level so any node can be rolled up to state, region, or national level for exposure aggregation and Schedule P reporting. | 24 |
| geographic_aggregation | location_geocode | master_data | Per-location SSOT for geocode and hazard: one row per insured location. Stores lat/long, FIPS, CRESTA zone, FEMA FIRM flood zone, base flood elevation, FIRM panel, fire protection class, and model-derived AAL/PML/hazard band per peril and CAT model | 47 |
| geographic_aggregation | peril | reference_data | Reference catalog of insured perils (wind, hail, earthquake, flood, fire, theft, liability). One row per peril. Carries NAIC peril code, CAT vs. non-CAT flag, reinsurance treaty peril mapping, and ISO cause-of-loss code. | 36 |
| geographic_aggregation | territory | reference_data | Rating territory as filed with the DOI per state and LOB. One row per territory per LOB per state. Carries territory code, effective date, filed rate relativities, residual-market/wind-pool designation flags, and links to the geography hierarchy for | 38 |

<a id="domain-claim"></a>

### Domain: Claim

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| claim | business | 5 | Provisional description for user-specified domain 'claims'. Awaiting a generated description of what this domain owns. | 31 |

**Subdomains:** actuarial_reporting, exposure_handling, financial_settlement, loss_intake, recovery_pursuit


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| actuarial_reporting | claimfinancials_accounting_period | reference_data | Reference calendar for financial close cycles. Defines calendar year, accident year, policy year, and fiscal period boundaries used to bucket premium, loss, and expense transactions for statutory and GAAP reporting. | 35 |
| actuarial_reporting | ibnr_estimate | transactional_data | Actuarial IBNR and IBNER estimate per LOB, accident year, and valuation date. Records selected ultimate, expected loss ratio, development factor, tail factor, and actuary sign-off. SSOT for IBNR positions. | 50 |
| actuarial_reporting | loss_triangle | transactional_data | Actuarial loss development triangle per accident year, policy year, or calendar year cohort. Stores paid losses, incurred losses, case reserves, and IBNR by development period for Schedule P and reserving analytics. | 47 |
| actuarial_reporting | statutory_reserve_filing | transactional_data | Statutory reserve position submitted to state DOI or NAIC. Captures LOB, state, accident year, case reserve, IBNR, total incurred, filing date, actuary certification, and SAP vs GAAP basis for regulatory compliance. | 48 |
| exposure_handling | adjuster | master_data | Staff or independent adjuster assigned to handle claims. Captures adjuster type (staff/IA/TPA), license number, state appointments, assignment capacity, and links to Party domain for identity. | 36 |
| exposure_handling | adjuster_assignment | transactional_data | Assignment of an adjuster to a claim or claim exposure. Grain: one row per assignment. Tracks assignment date, reassignment reason, workload at assignment, and primary vs supervisory role. FK to adjuster and claim. | 35 |
| exposure_handling | claim_exposure | association_data | Claim Exposure: The coverage line within a claim, linking Claim to Coverage and Insured Risk. GRAIN: One row per coverage line per claim. Grain: one row per coverage line per claim. | 42 |
| exposure_handling | litigation | master_data | Litigation record attached to a claim. Tracks lawsuit filing date, plaintiff attorney, defense counsel, court jurisdiction, trial date, verdict, and settlement amount. One row per lawsuit per claim. | 37 |
| exposure_handling | medical_bill | transactional_data | Medical bill submitted against a bodily injury or workers comp claim exposure. Grain: one row per bill. Captures provider, procedure codes, billed amount, allowed amount, paid amount, and bill review outcome. | 42 |
| exposure_handling | repair_estimate | transactional_data | Property or auto repair estimate associated with a claim exposure. Grain: one row per estimate. Captures estimator, repair facility, estimate date, line-item costs, agreed value, and supplement history. | 43 |
| exposure_handling | siu_referral | transactional_data | Special Investigations Unit referral for a claim suspected of fraud. Grain: one row per referral. Captures referral reason, SIU analyst assigned, investigation outcome, and disposition (confirmed fraud, cleared, pending). FK to claim. | 41 |
| financial_settlement | claim_expense | transactional_data | Claim Expense: LAE, DCC, and AO expenses on claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure. | 45 |
| financial_settlement | claim_financial_snapshot | transactional_data | Point-in-time financial position per claim exposure as of a valuation date. Stores total incurred (paid + case reserve), IBNR allocation, ceded amounts, net retained position, and prior-period comparison for statutory reporting. | 49 |
| financial_settlement | claim_payment | transactional_data | Claim Payment: Payments made on claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure. | 47 |
| financial_settlement | claimfinancials_bordereaux_line | transactional_data | One row per claim line in a reinsurance bordereaux submission. Captures claim reference, ceded loss, ceded LAE, recovery status, treaty or facultative reference, and reporting period for reinsurer settlement. | 47 |
| financial_settlement | financial_transaction | transactional_data | One row per atomic double-entry posting generated by a claim financial event (reserve, payment, recovery, expense), keyed to claim exposure and accounting period. Grain: one row per financial movement per claim exposure. | 45 |
| financial_settlement | lae_allocation | transactional_data | Allocates unallocated LAE (ULAE) to individual claim exposures using an actuarial allocation method (paid-to-paid, Kittel, etc.). Records allocated ULAE amount, method code, allocation basis, and accounting period. | 42 |
| financial_settlement | payee | master_data | Master record for a party designated to receive claim payments. Captures payee name, tax ID (SSN/FEIN), address, bank account for EFT, 1099 reporting flag, and payee type (claimant, attorney, vendor, lienholder). | 46 |
| financial_settlement | recovery | transactional_data | Recovery: Subrogation, salvage, and reinsurance recoveries on claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure. | 46 |
| financial_settlement | reinsurance_recovery | transactional_data | One row per reinsurance recovery billing per claim exposure and treaty or facultative agreement. Tracks ceded loss amount, ceded LAE, recovery billed, recovery collected, and outstanding balance. Links claim to reinsurance cession. | 46 |
| financial_settlement | reserve | transactional_data | Reserve: Case, IBNR, and LAE reserve amounts for claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure. | 50 |
| loss_intake | claim | master_data | Claim: A reported loss or demand for indemnification under a policy. GRAIN: One row per reported loss. Grain: one row per reported loss. | 45 |
| loss_intake | claim_document | transactional_data | Documents attached to a claim: police reports, medical records, repair estimates, photos, demand letters. Grain: one row per document. Captures document type, source, received date, and storage reference. | 33 |
| loss_intake | claim_note | transactional_data | Diary and activity notes recorded against a claim or claim exposure. Grain: one row per note entry. Captures author, note type (diary, coverage, legal, medical), entry timestamp, and visibility classification. | 34 |
| loss_intake | claim_status | transactional_data | Lifecycle status history for a claim. Grain: one row per status transition per claim. Tracks Open, Pending, Closed, Reopened, Denied, Litigated transitions with effective timestamps and reason codes. | 35 |
| loss_intake | claimant | master_data | Party involved in a claim as first-party insured or third-party claimant. Grain: one row per party per claim. Captures claimant type (FP/TP), injury or damage description, and links to Party domain. | 46 |
| loss_intake | fnol | transactional_data | First Notice of Loss intake record. Grain: one row per FNOL submission. Captures report channel, reporter party, initial loss description, date/time of loss, and triage flags before a formal claim is opened. | 46 |
| loss_intake | loss_event | master_data | Master record of a physical loss occurrence (storm, fire, collision, liability event). One row per occurrence. Links multiple claims arising from the same event. Supports CAT aggregation and PML analysis. | 46 |
| recovery_pursuit | salvage | master_data | Master record for salvage activity on a total-loss insured item. Tracks salvage value estimate, auction proceeds, title transfer status, storage costs, net salvage amount, and disposition method per claim exposure. | 47 |
| recovery_pursuit | salvage_disposition | master_data | Recovery-pursuit record per claim exposure covering both salvage disposition (auto total-loss, damaged goods) and subrogation against liable third parties. Grain: one row per recovery item. | 38 |
| recovery_pursuit | subrogation | master_data | Master record for a subrogation pursuit against a liable third party. Tracks demand amount, collected amount, attorney assignment, litigation status, settlement date, and net recovery after expenses per claim. | 46 |

<a id="domain-claim"></a>

### Domain: Claim

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| claim | business | 5 | Provisional description for user-specified domain 'claim_financials'. Awaiting a generated description of what this domain owns. | 31 |

**Subdomains:** actuarial_reporting, exposure_handling, financial_settlement, loss_intake, recovery_pursuit


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| actuarial_reporting | claimfinancials_accounting_period | reference_data | Reference calendar for financial close cycles. Defines calendar year, accident year, policy year, and fiscal period boundaries used to bucket premium, loss, and expense transactions for statutory and GAAP reporting. | 35 |
| actuarial_reporting | ibnr_estimate | transactional_data | Actuarial IBNR and IBNER estimate per LOB, accident year, and valuation date. Records selected ultimate, expected loss ratio, development factor, tail factor, and actuary sign-off. SSOT for IBNR positions. | 50 |
| actuarial_reporting | loss_triangle | transactional_data | Actuarial loss development triangle per accident year, policy year, or calendar year cohort. Stores paid losses, incurred losses, case reserves, and IBNR by development period for Schedule P and reserving analytics. | 47 |
| actuarial_reporting | statutory_reserve_filing | transactional_data | Statutory reserve position submitted to state DOI or NAIC. Captures LOB, state, accident year, case reserve, IBNR, total incurred, filing date, actuary certification, and SAP vs GAAP basis for regulatory compliance. | 48 |
| exposure_handling | adjuster | master_data | Staff or independent adjuster assigned to handle claims. Captures adjuster type (staff/IA/TPA), license number, state appointments, assignment capacity, and links to Party domain for identity. | 36 |
| exposure_handling | adjuster_assignment | transactional_data | Assignment of an adjuster to a claim or claim exposure. Grain: one row per assignment. Tracks assignment date, reassignment reason, workload at assignment, and primary vs supervisory role. FK to adjuster and claim. | 35 |
| exposure_handling | claim_exposure | association_data | Claim Exposure: The coverage line within a claim, linking Claim to Coverage and Insured Risk. GRAIN: One row per coverage line per claim. Grain: one row per coverage line per claim. | 42 |
| exposure_handling | litigation | master_data | Litigation record attached to a claim. Tracks lawsuit filing date, plaintiff attorney, defense counsel, court jurisdiction, trial date, verdict, and settlement amount. One row per lawsuit per claim. | 37 |
| exposure_handling | medical_bill | transactional_data | Medical bill submitted against a bodily injury or workers comp claim exposure. Grain: one row per bill. Captures provider, procedure codes, billed amount, allowed amount, paid amount, and bill review outcome. | 42 |
| exposure_handling | repair_estimate | transactional_data | Property or auto repair estimate associated with a claim exposure. Grain: one row per estimate. Captures estimator, repair facility, estimate date, line-item costs, agreed value, and supplement history. | 43 |
| exposure_handling | siu_referral | transactional_data | Special Investigations Unit referral for a claim suspected of fraud. Grain: one row per referral. Captures referral reason, SIU analyst assigned, investigation outcome, and disposition (confirmed fraud, cleared, pending). FK to claim. | 41 |
| financial_settlement | claim_expense | transactional_data | Claim Expense: LAE, DCC, and AO expenses on claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure. | 45 |
| financial_settlement | claim_financial_snapshot | transactional_data | Point-in-time financial position per claim exposure as of a valuation date. Stores total incurred (paid + case reserve), IBNR allocation, ceded amounts, net retained position, and prior-period comparison for statutory reporting. | 49 |
| financial_settlement | claim_payment | transactional_data | Claim Payment: Payments made on claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure. | 47 |
| financial_settlement | claimfinancials_bordereaux_line | transactional_data | One row per claim line in a reinsurance bordereaux submission. Captures claim reference, ceded loss, ceded LAE, recovery status, treaty or facultative reference, and reporting period for reinsurer settlement. | 47 |
| financial_settlement | financial_transaction | transactional_data | One row per atomic double-entry posting generated by a claim financial event (reserve, payment, recovery, expense), keyed to claim exposure and accounting period. Grain: one row per financial movement per claim exposure. | 45 |
| financial_settlement | lae_allocation | transactional_data | Allocates unallocated LAE (ULAE) to individual claim exposures using an actuarial allocation method (paid-to-paid, Kittel, etc.). Records allocated ULAE amount, method code, allocation basis, and accounting period. | 42 |
| financial_settlement | payee | master_data | Master record for a party designated to receive claim payments. Captures payee name, tax ID (SSN/FEIN), address, bank account for EFT, 1099 reporting flag, and payee type (claimant, attorney, vendor, lienholder). | 46 |
| financial_settlement | recovery | transactional_data | Recovery: Subrogation, salvage, and reinsurance recoveries on claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure. | 46 |
| financial_settlement | reinsurance_recovery | transactional_data | One row per reinsurance recovery billing per claim exposure and treaty or facultative agreement. Tracks ceded loss amount, ceded LAE, recovery billed, recovery collected, and outstanding balance. Links claim to reinsurance cession. | 46 |
| financial_settlement | reserve | transactional_data | Reserve: Case, IBNR, and LAE reserve amounts for claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure. | 50 |
| loss_intake | claim | master_data | Claim: A reported loss or demand for indemnification under a policy. GRAIN: One row per reported loss. Grain: one row per reported loss. | 45 |
| loss_intake | claim_document | transactional_data | Documents attached to a claim: police reports, medical records, repair estimates, photos, demand letters. Grain: one row per document. Captures document type, source, received date, and storage reference. | 33 |
| loss_intake | claim_note | transactional_data | Diary and activity notes recorded against a claim or claim exposure. Grain: one row per note entry. Captures author, note type (diary, coverage, legal, medical), entry timestamp, and visibility classification. | 34 |
| loss_intake | claim_status | transactional_data | Lifecycle status history for a claim. Grain: one row per status transition per claim. Tracks Open, Pending, Closed, Reopened, Denied, Litigated transitions with effective timestamps and reason codes. | 35 |
| loss_intake | claimant | master_data | Party involved in a claim as first-party insured or third-party claimant. Grain: one row per party per claim. Captures claimant type (FP/TP), injury or damage description, and links to Party domain. | 46 |
| loss_intake | fnol | transactional_data | First Notice of Loss intake record. Grain: one row per FNOL submission. Captures report channel, reporter party, initial loss description, date/time of loss, and triage flags before a formal claim is opened. | 46 |
| loss_intake | loss_event | master_data | Master record of a physical loss occurrence (storm, fire, collision, liability event). One row per occurrence. Links multiple claims arising from the same event. Supports CAT aggregation and PML analysis. | 46 |
| recovery_pursuit | salvage | master_data | Master record for salvage activity on a total-loss insured item. Tracks salvage value estimate, auction proceeds, title transfer status, storage costs, net salvage amount, and disposition method per claim exposure. | 47 |
| recovery_pursuit | salvage_disposition | master_data | Recovery-pursuit record per claim exposure covering both salvage disposition (auto total-loss, damaged goods) and subrogation against liable third parties. Grain: one row per recovery item. | 38 |
| recovery_pursuit | subrogation | master_data | Master record for a subrogation pursuit against a liable third party. Tracks demand amount, collected amount, attorney assignment, litigation status, settlement date, and net recovery after expenses per claim. | 46 |

<a id="domain-party"></a>

### Domain: Party

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| party | business | 3 | SSOT for all persons and organizations the insurer interacts with: policyholders, named/additional insureds, claimants, producers, adjusters, and payees. Owns identity, demographics, KYC, and deduplication. | 17 |

**Subdomains:** contact_compliance, identity_management, party_relationships


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| contact_compliance | address | master_data | Physical and mailing addresses for a party. One row per address per party. Stores address type (mailing, risk, billing), street, city, state, ZIP+4, county, country, geocode, and effective dates. | 43 |
| contact_compliance | consent_record | transactional_data | Captures explicit consent or opt-out events for a party: marketing, electronic delivery, telematics, credit pull, MVR pull. One row per consent event. Stores consent type, channel, timestamp, and regulatory basis (GLBA/CCPA/GDPR). | 42 |
| contact_compliance | contact | master_data | Communication contact points for a party: phone, email, fax, and preferred contact method. One row per contact point per party. Tracks opt-in/opt-out flags, contact type, and effective dates for GLBA compliance. | 39 |
| contact_compliance | license | master_data | Professional licenses held by a party: producer license, adjuster license, contractor license. One row per license. Stores license type, license number, issuing state, issue date, expiry date, and active status for NIPR/DOI compliance. | 43 |
| contact_compliance | party_document | master_data | Documents associated with a party: government-issued ID, proof of address, ACORD applications, CoI, MVR report, loss runs. One row per document. Stores document type, source system, storage URI, received date, and expiry date. | 46 |
| identity_management | identifier | master_data | External and internal identifiers assigned to a party: SSN, FEIN, NPN, NAIC code, driver license, passport, PAS party ID, MDM golden ID. One row per identifier per party. Supports deduplication and cross-system matching. | 36 |
| identity_management | individual | master_data | Person-specific subtype of party. Stores legal name, date of birth, gender, marital status, driver license number, and MVR consent flag for natural persons underwritten or involved in claims. External IDs live in identifier. | 45 |
| identity_management | kyc_verification | transactional_data | KYC and identity-verification record for a party. Tracks verification method, verification date, result (pass/fail/review), OFAC screening status, PEP flag, adverse-media flag, and the analyst who performed the check. | 45 |
| identity_management | merge_event | transactional_data | MDM deduplication event that merges a survivor party with one or more duplicate parties. One row per merge operation. Stores survivor party, merged party, merge date, merge reason, and the operator who approved the merge. | 37 |
| identity_management | organization | master_data | Legal-entity subtype of party. Stores legal name, FEIN, NAIC code, SIC/NAICS code, entity type (corp, LLC, partnership), state of incorporation, and D&B DUNS for commercial insureds and counterparties. | 40 |
| identity_management | party | master_data | SSOT master record for every person or organization the insurer interacts with. One row per party. Owns golden-record identity, KYC status, dedup keys, and MDM flags. Tax IDs and external keys live in identifier, not here. | 44 |
| party_relationships | household | master_data | Master reference table for household. Referenced by household_id. | 33 |
| party_relationships | loss_payee | master_data | Loss payee or mortgagee interest attached to a party and a policy or insured risk. One row per interest. Stores interest type (mortgagee, loss payee, additional insured), lender name, loan number, and effective dates. | 39 |
| party_relationships | party_group | master_data | Master reference table for party_group. Referenced by group_id. | 33 |
| party_relationships | relationship | master_data | Directed relationship between two parties: spouse, parent-subsidiary, named insured to additional insured, employer-employee. One row per relationship. Carries relationship type, effective dates, and primary-party flag. | 33 |
| party_relationships | role | master_data | Assigns a role to a party with effective and expiration dates. One row per party-role assignment. Roles include policyholder, named insured, additional insured, claimant, producer, adjuster, and payee. Never embeds role on the party record. | 41 |
| party_relationships | segment | master_data | Business segmentation classification assigned to a party: personal lines, commercial lines, preferred, standard, non-standard, high-net-worth. One row per segment assignment per party. Supports underwriting appetite and marketing targeting. | 41 |

<a id="domain-policy"></a>

### Domain: Policy

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| policy | business | 4 | Authoritative record of the insurance contract lifecycle. Owns Policy (one row per policy), Policy Term (one row per policy per term), and Policy Transaction (NB, REN, END, CAN, RI, NR). | 16 |

**Subdomains:** contract_lifecycle, coverage_structure, document_forms, party_interests


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| contract_lifecycle | policy | master_data | Policy: The master contract record representing an insurance agreement. GRAIN: One row per policy. Grain: one row per policy. | 42 |
| contract_lifecycle | policy_transaction | transactional_data | Lifecycle event applied to a policy term. One row per transaction. Type (NB, REN, END, CAN, RI, NR) with type-specific attributes: effective/processed date, reason code, premium impact, cancellation basis and return-premium method, reinstatement lapse | 40 |
| contract_lifecycle | policy_type | reference_data | Reference classification of policy types (HO3, HO6, PAP, BOP, CGL, CPP, CA, WC, EPLI, D&O, E&O). One row per policy type. Carries NAIC line code, ISO program code, personal/commercial flag, and monoline/package indicator. | 34 |
| contract_lifecycle | state_reg | master_data | State-specific regulatory attributes for a policy. One row per policy per state. Captures admitted/surplus lines status, stamping office filing number, state-mandated coverage flags, assigned risk pool indicator, and FAIR plan eligibility. | 39 |
| contract_lifecycle | term | master_data | Policy Term: A time-bounded period within a policy lifecycle. GRAIN: One row per policy per term. Grain: one row per policy per term. | 43 |
| coverage_structure | fee | transactional_data | Policy-level fees assessed at issuance or renewal (policy fee, inspection fee, installment fee, surplus lines tax). One row per fee per policy transaction. Carries fee type, amount, taxable flag, and remittance destination. | 34 |
| coverage_structure | line | master_data | Line-of-business breakdown within a policy. One row per LOB per policy term. Supports multi-line CPP and BOP structures. Carries NAIC LOB code, sub-line, program code, and LOB-level written premium for statutory Schedule P reporting. | 47 |
| coverage_structure | policy_condition | master_data | Policy-level conditions and warranties attached to the contract (e.g., protective safeguard warranty, occupancy condition). One row per condition per policy term. Distinct from coverage-level conditions; applies across all coverages on the term. | 30 |
| coverage_structure | reinsurance_link | association_data | Carries the reinsurance treaty and facultative agreement keys on the policy so cession and recovery records in the reinsurance domain can join back. One row per reinsurance placement per policy term. | 47 |
| document_forms | document_template | master_data | Master reference table for document_template. Referenced by template_id. | 37 |
| document_forms | policy_document | master_data | Documents and notices issued on a policy including application, binder, jacket, endorsement, certificate, declarations page (DEC), and regulatory notices. One row per document generated at a policy transaction. | 47 |
| document_forms | policy_form | master_data | ISO/ACORD forms and endorsement forms attached to a policy term. One row per form attachment. Records form number, edition date, form type (base, endorsement, exclusion), attachment sequence, and mandatory/optional flag per state filing. | 31 |
| party_interests | policy_interest | master_data | Additional interests on a policy (additional insured, loss payee, mortgagee, lienholder). One row per interest per policy term. Captures interest type, party reference, certificate number, effective dates, and notification requirements per ISO/ACORD | 35 |
| party_interests | policy_producer | association_data | Association linking a policy to its producing agent or broker. One row per producer role per policy. Captures producer NPN, agency code, distribution channel, split percentage, and effective dates. Feeds commission settlement in the producers domain. | 40 |
| party_interests | policy_producer_policy | association_data | Association between producers and policies capturing the producer's role, commission terms, and servicing rights. One row per producer per policy. Tracks writing, servicing, and split commission arrangements across the policy lifecycle.. | 11 |
| party_interests | policyholder | association_data | Association between a policy and the party acting as named insured/policyholder. One row per policyholder per policy. Carries role type, effective/expiration dates, and primary-insured flag. | 28 |

<a id="domain-premium"></a>

### Domain: Premium

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| premium | business | 2 | Transactional ledger for all premium activity. Owns Premium Transaction (one row per financial transaction: Written, Earned, Unearned, Return) tied to Policy, Policy Term, Coverage, Insured Risk, and Accounting Period, with Charge, Tax, Fee, and | 17 |

**Subdomains:** earning_rules, transaction_booking


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| earning_rules | earned_premium_schedule | transactional_data | Pro-rata or short-rate earning schedule for a Coverage within a Policy Term. Defines daily or monthly earned and unearned premium amounts used to compute EP at any in-force date. Supports IFRS 17 and Schedule P actuarial triangles. | 45 |
| earning_rules | minimum_earned_premium | reference_data | Defines the minimum earned premium threshold for a Coverage or Policy Term that applies on short-rate or flat cancellation. Ensures the insurer retains a floor amount regardless of cancellation timing or return premium calculation. | 36 |
| earning_rules | premium_accounting_period | reference_data | Reference calendar period (month, quarter, year) used to bucket premium, loss, and expense transactions for statutory and GAAP reporting. Supports CY, AY, and PY views required by Schedule P and IFRS 17. | 34 |
| earning_rules | rate_table | reference_data | Versioned rate table published by the rating engine for a specific LOB, state, and effective date. Stores base rates, factors, and minimum premiums. Provides the authoritative rate version used to price each Policy Term. | 48 |
| earning_rules | rate_table_authorization | association_data | Grants a producer or agency the authority to use a specific rate table for binding coverage. One row per producer-rate_table authorization. Tracks effective dates, expiration, override permissions, and deviation limits for that combination.. | 8 |
| earning_rules | rule | reference_data | Business rule governing how premium is computed, split, earned, or floored for a LOB, state, or coverage type. Stores rule type (pro-rata, short-rate, flat, minimum-earned), effective date range, threshold amounts, and conditions. | 37 |
| transaction_booking | audit | transactional_data | Result of a final or interim audit for auditable policies (WC, GL, CGL). Captures audited exposure basis, audited premium, variance from estimated/deposit premium, and deposit reconciliation status. Triggers additional or return premium transactions. | 45 |
| transaction_booking | bearing_coverage | association_data | Association table linking a Premium Transaction to the specific Coverage and Insured Risk it applies to. Grain: one row per coverage allocation per premium transaction. Prevents fan-out double-counting when premium splits across multiple coverages. | 37 |
| transaction_booking | ceded_premium | transactional_data | Records premium ceded to reinsurers under a Treaty or Facultative Agreement per Policy Term and Coverage; ceded written/earned/unearned by accounting period. Candidate for relocation to Reinsurance, which owns the cession ledger. | 46 |
| transaction_booking | charge | transactional_data | Child of Premium Transaction. One row per charge component (base premium, surcharge, credit, minimum premium) within a transaction. Enables granular decomposition of gross written premium by rating element and LOB. | 46 |
| transaction_booking | commission | transactional_data | Child of Premium Transaction. One row per producer commission calculation on a transaction: type (new/renewal/contingent), rate, basis, and computed payable. Calculation-only; commission settlement/payout is owned by the producers domain. | 42 |
| transaction_booking | deposit_premium | transactional_data | Tracks the estimated deposit premium collected at policy inception for auditable or retro-rated policies. Stores deposit amount, basis of estimate, and reconciliation status against final audit or retro adjustment. | 45 |
| transaction_booking | policy_fee | transactional_data | Child of Premium Transaction. One row per non-premium fee (policy fee, inspection fee, installment fee) charged on a transaction. Fees are non-taxable in most jurisdictions and tracked separately from taxable premium. | 40 |
| transaction_booking | premium_endorsement | transactional_data | Records the net premium change (additional or return) generated by a Policy Transaction endorsement, cancellation, or reinstatement. Links the endorsing Policy Transaction to the resulting Premium Transactions and charge breakdown. | 44 |
| transaction_booking | premium_transaction | transactional_data | Premium Transaction: A financial transaction recording premium movements (Written, Earned, Unearned, Return). GRAIN: One row per financial transaction. Grain: one row per financial transaction. | 50 |
| transaction_booking | retrospective_adjustment | transactional_data | Records a retro premium adjustment for retrospectively-rated policies. Captures adjustment number, evaluation date, standard premium, loss conversion factor, retro premium computed, and variance from prior adjustment. | 46 |
| transaction_booking | tax_levy | transactional_data | Child of Premium Transaction. One row per state or surplus-lines tax, stamping fee, or regulatory assessment applied to a premium transaction. Tracks tax type, jurisdiction, rate, and computed amount for statutory remittance. | 34 |

<a id="domain-producers"></a>

### Domain: Producers

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| producers | business | 2 | Provisional description for user-specified domain 'producers'. Awaiting a generated description of what this domain owns. | 21 |

**Subdomains:** agency_network, commission_management


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| agency_network | agency | master_data | Master record for an insurance agency or brokerage firm. One row per agency. Captures agency name, FEIN, NAIC code, principal address, agency type, and parent agency hierarchy for MGA and wholesale relationships. | 38 |
| agency_network | agency_coverage_appointment | association_data | Represents the appointment authority granting an agency the right to write a specific coverage type. Captures commission rate, binding authority, limits, and appointment status per agency-coverage combination. One row per agency per coverage type.. | 10 |
| agency_network | agency_producer | association_data | Association between a producer and an agency capturing the employment or affiliation relationship. One row per producer-agency pairing. Stores role, start date, end date, and primary-agency flag. | 39 |
| agency_network | broker_of_record_change | transactional_data | Formal BOR change request and approval record transferring a policy from one producer to another. One row per BOR change. Tracks requesting producer, outgoing producer, effective date, insured consent date, and commission split impact. | 41 |
| agency_network | distribution_channel | reference_data | Reference classification of how business reaches the insurer (captive, independent, broker, direct, MGA, wholesale, affinity, digital). One row per channel. Drives commission schedule selection and producer underwriting authority rules. | 35 |
| agency_network | errors_omissions_policy | master_data | E&O insurance policy held by a producer or agency as required for appointment. One row per E&O policy. Tracks insurer, policy number, coverage limit, effective date, expiration date, and compliance verification status. | 44 |
| agency_network | producer_agency_appointment | association_data | Association between a producer and an agency capturing appointment-specific authority, commission splits, and LOB restrictions. One row per producer per agency appointment. | 15 |
| agency_network | producer_appointment | master_data | Formal appointment and binding authority granted by the insurer to a producer to sell specific lines in a state. One row per producer per insurer per state per LOB. | 45 |
| agency_network | producer_compliance_event | transactional_data | Record of a compliance-relevant event for a producer: license renewal, CE completion, background check, DOI action, or termination for cause. One row per event. Supports appointment eligibility and regulatory audit trails. | 40 |
| agency_network | producer_license | master_data | Individual state license held by a producer. One row per producer per state per license class. Tracks license number, line of authority, issue date, expiration date, and DOI status for compliance and appointment eligibility. | 44 |
| agency_network | producer_tier | reference_data | Classification tier assigned to a producer or agency based on performance criteria (Preferred, Standard, Probationary). One row per tier definition. Drives commission override rates, underwriting authority levels, and marketing support. | 39 |
| agency_network | producers_producer | master_data | Master record for every licensed insurance producer (agent or broker). One row per producer. Stores NPN, license numbers, resident state, producer type, appointment status, and E&O coverage details. | 41 |
| agency_network | producers_producer_policy | association_data | Association linking a producer to a policy with role (writing agent, servicing agent, broker of record). One row per producer-policy-role. Supports split-commission scenarios and broker-of-record changes with effective dating. | 42 |
| agency_network | underwriting_authority | master_data | Defines the binding authority granted to a producer or agency by LOB, coverage type, and limit tier. One row per authority grant. Tracks max TIV, max single-risk limit, eligible states, and authority expiration date. | 46 |
| commission_management | commission_payment | transactional_data | Actual disbursement made to a producer or agency against a commission statement. One row per payment. Records payment date, amount, payment method, check or ACH reference, and reconciliation status. | 41 |
| commission_management | commission_rule | reference_data | Individual rate rule within a commission schedule. One row per rule. Specifies transaction type (NB, REN, END), LOB, coverage type, base rate, contingent rate, override rate, and effective date range. | 41 |
| commission_management | commission_schedule | master_data | Contractual commission rate set for a producer or agency by LOB, transaction type (NB/REN/END), and coverage type over an effective period. One row per schedule version. Holds all rate lines (base, contingent, override) as embedded detail. | 44 |
| commission_management | commission_statement | transactional_data | Periodic statement issued to a producer or agency summarizing commission transactions due for a billing cycle. One row per statement. Tracks statement date, total earned, total adjustments, net payable, and payment status. | 43 |
| commission_management | commission_transaction | transactional_data | One row per commission financial movement earned by a producer on a premium transaction. Captures earned amount, claw-back amount, transaction type, accounting period, and payment status. Child of premium transaction. | 45 |
| commission_management | contingent_commission | transactional_data | Profit-sharing or contingent commission agreement between the insurer and an agency. One row per agreement per performance period. Stores target LR, target growth, earned amount, and calculation basis for year-end settlement. | 44 |
| commission_management | producer_performance | transactional_data | Periodic operational scorecard and tier assignment for a producer or agency. One row per producer per period. Stores GWP, NWP, PIF count, LR, retention, new-business count, and the assigned tier (Preferred/Standard/Probationary) with the tier definition | 45 |

<a id="domain-risk"></a>

### Domain: Risk

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| risk | business | 2 | Provisional description for user-specified domain 'risk_exposure'. Awaiting a generated description of what this domain owns. | 13 |

**Subdomains:** exposure_profile, hazard_assessment


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| exposure_profile | auto_risk | master_data | Auto-line subtype of insured_risk. One row per auto risk unit. Captures garaging state, primary use, annual mileage, radius of operation, and links to vehicle and driver records for PAP and CA rating. | 40 |
| exposure_profile | building | master_data | Individual structure on an insured location. One row per building. Captures number of stories, roof type, roof year, frame type, sprinkler indicator, replacement cost value, and ISO building class for property rating. | 48 |
| exposure_profile | driver | master_data | Licensed operator associated with an auto risk. One row per driver. Captures license number/state, DOB, gender, marital status, years licensed, SR-22 indicator, and MVR order/receipt/status and clean-record fields (absorbed from mvr_report) for auto | 43 |
| exposure_profile | insured_risk | master_data | Supertype master for every insurable object underwritten on a policy. One row per insured risk. Subtypes property_risk and auto_risk extend it via shared PK (explicit subtype FK). | 41 |
| exposure_profile | location | master_data | Physical address and geocoded site associated with a property risk. One row per insured location. Stores street address, lat/long, FIPS code, territory code, flood zone, and links to geography hierarchy for CAT aggregation. | 47 |
| exposure_profile | property_risk | master_data | Property-line subtype of insured_risk. One row per property risk. Captures COPE attributes (Construction, Occupancy, Protection, Exposure), ITV, year built, square footage, and ISO construction class for rating and CAT modeling. | 46 |
| exposure_profile | vehicle | master_data | Motor vehicle associated with an auto risk. One row per vehicle. Stores VIN, year, make, model, body type, ISO symbol, stated value, anti-theft device indicator, and safety rating for auto rating and claims. | 43 |
| hazard_assessment | driver_violation | transactional_data | Single SSOT for loss, violation, accident, and prior-loss history attached to a driver or insured risk, sourced from CLUE, MVR, or self-reported application data. One row per incident. | 41 |
| hazard_assessment | exposure_schedule | master_data | Scheduled list of insured risks or values attached to a policy term for commercial lines (location schedule, fleet schedule). One row per schedule entry per risk unit. Captures effective/expiration dates, scheduled value, and risk unit reference. | 45 |
| hazard_assessment | risk_characteristic | master_data | Extensible per-risk attribute bag for line-specific characteristics not captured in core subtypes (pool presence, alarm type, business description, SIC/NAICS). One row per characteristic per insured risk. Enables new LOB onboarding without schema rebuild. | 46 |
| hazard_assessment | risk_improvement | transactional_data | Required or recommended risk improvement condition attached to an insured risk. One row per improvement item. Captures condition type, due date, compliance date, status, and premium impact for UW condition tracking. | 37 |
| hazard_assessment | risk_inspection | transactional_data | Physical or virtual inspection of an insured risk that produces exposure facts of record (condition, hazards, valuation checks). One row per inspection. Stores inspection type, ordered/completed dates, inspector party, findings summary, and recommendation | 45 |
| hazard_assessment | risk_score | transactional_data | Point-in-time risk score attached to an insured risk for exposure grading. One row per scoring event per risk. Stores score value, model version, score date, component scores, and referral threshold flag. | 42 |

<a id="domain-shared"></a>

### Domain: Shared

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| shared | corporate | 2 | Cross-domain shared reference entities (currency, UoM, calendar, classification) consolidated for Single Source of Truth (SSOT). | 5 |

**Subdomains:** business_classification, financial_reference


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| business_classification | classification_code | Master | Reference catalog of industry classification codes (ISO GL class, WC class, SIC, NAICS) used for rating and eligibility. One row per class code. SSOT consumed by underwriting, coverage rate, and premium. | 36 |
| business_classification | line_of_business | Master | Reference catalog of P&C lines of business (HO, PAP, CGL, BOP, CPP, WC, Commercial Auto, Umbrella). One row per LOB. SSOT for LOB codes referenced by policy, coverage, premium, claim, and reinsurance. | 29 |
| business_classification | unit_of_measure | Master | Reference catalog of units of measure (square footage, mileage, payroll, sales receipts) used as premium exposure bases. One row per UoM. SSOT for exposure-basis units across rating and premium audit. | 24 |
| financial_reference | calendar | Master | Enterprise calendar reference of fiscal, accident, policy, and calendar-year periods. One row per period. Complements domain-local accounting_period tables by providing a single cross-domain date dimension. | 32 |
| financial_reference | currency | Master | Reference catalog of ISO 4217 currencies used across premium, claim, billing, and reinsurance financial transactions. One row per currency code. Carries code, name, minor unit, and active flag. | 19 |

## Metric Views

Total metric views generated: **128**. Showing top 20.

| # | View Name | Domain | Source Table | Description |
|---|---|---|---|---|
| 1 | coverage | coverage | coverage | Core coverage-level metrics measuring written premium, limits, deductibles, and exposure. Used by underwriting, actuarial, and finance leadership to monitor the in-force book composition and pricing adequacy. |
| 2 | coverage_binder | coverage | binder | Measures binder issuance activity, premium at bind, commission costs, and binding authority utilization. Used by underwriting and operations leadership to monitor the bind pipeline and authority compliance. |
| 3 | coverage_cession | coverage | coverage_cession | Measures reinsurance cession activity at the coverage level — ceded premium, retention, and layer utilization. Used by reinsurance and finance leadership to monitor treaty utilization and net retained exposure. |
| 4 | coverage_clearance_check | coverage | clearance_check | Measures submission clearance outcomes, duplicate detection rates, and risk appetite screening results. Used by underwriting operations to monitor the effectiveness of the clearance gate and identify duplicate submission patterns. |
| 5 | coverage_loss_history | coverage | loss_history | Measures prior loss history used in underwriting — incurred amounts, paid amounts, reserves, and surcharges. Used by underwriting and actuarial leadership to assess risk quality, rating accuracy, and loss history impact on pricing. |
| 6 | coverage_quote | coverage | quote | Measures quoting activity, premium competitiveness, conversion signals, and referral rates. Used by underwriting and sales leadership to manage the quote-to-bind funnel and pricing adequacy. |
| 7 | coverage_rating_worksheet | coverage | rating_worksheet | Measures rating engine outputs, premium components, and rating override activity. Used by actuarial and underwriting leadership to monitor pricing adequacy, rating engine performance, and override rates. |
| 8 | coverage_submission | coverage | submission | Tracks the submission pipeline — volume, premium potential, clearance outcomes, and referral rates. Executives use this to monitor new business flow, underwriting capacity, and appetite alignment. |
| 9 | coverage_transaction | coverage | coverage_transaction | Measures coverage change activity — premium impacts, limit and deductible modifications, and coverage additions/removals. Used by underwriting and finance to track mid-term policy changes and their premium impact. |
| 10 | coverage_uw_decision | coverage | uw_decision | Measures underwriting decision outcomes, SLA performance, referral resolution, and pricing modifications. Used by underwriting leadership to monitor decision quality, turnaround time, and authority compliance. |
| 11 | coverage_uw_referral | coverage | uw_referral | Measures underwriting referral volume, resolution outcomes, SLA performance, and premium at risk. Used by underwriting leadership to manage referral queues, identify bottlenecks, and monitor authority escalation patterns. |
| 12 | reinsurance_bordereaux | reinsurance | bordereaux | Bordereaux-level metrics tracking ceded premium, loss, and commission reporting to reinsurers. Grain: one row per bordereaux submission. |
| 13 | reinsurance_cession | reinsurance | reinsurance_cession | Core cession-level metrics tracking the volume, premium, reserve, and financial performance of reinsurance cessions. Grain: one row per reinsurance cession transaction. |
| 14 | reinsurance_reinsurer | reinsurance | reinsurer | Reinsurer counterparty metrics tracking credit quality, authorization status, and collateral exposure by reinsurer. Grain: one row per reinsurer. |
| 15 | reinsurance_ri_claim_cession | reinsurance | ri_claim_cession | Claim-level reinsurance cession metrics tracking recoveries, reserves, and loss cession performance. Grain: one row per reinsurance claim cession. |
| 16 | reinsurance_ri_collateral | reinsurance | ri_collateral | Reinsurance collateral metrics tracking adequacy, deficiency, and expiry risk across collateral instruments. Grain: one row per collateral instrument. |
| 17 | reinsurance_ri_premium_transaction | reinsurance | ri_premium_transaction | Reinsurance premium transaction metrics tracking ceded premium flows, commission economics, and reinstatement activity. Grain: one row per reinsurance premium transaction. |
| 18 | reinsurance_ri_recovery | reinsurance | ri_recovery | Reinsurance recovery metrics tracking collection performance, outstanding balances, and dispute activity. Grain: one row per reinsurance recovery movement. |
| 19 | reinsurance_ri_settlement | reinsurance | ri_settlement | Reinsurance settlement metrics tracking net settlement amounts, commission economics, and settlement cycle performance. Grain: one row per reinsurance settlement. |
| 20 | reinsurance_schedule_f_entry | reinsurance | schedule_f_entry | Schedule F statutory reporting metrics tracking ceded premium, loss, reserve, and collectibility for regulatory filings. Grain: one row per Schedule F entry. |

*... and 108 more metric views. See the `metrics/` folder for full details.*