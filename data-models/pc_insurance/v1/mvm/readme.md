# Pc_Insurance Lakehouse Data Model

**v1_mvm** generated using Vibe Modelling Agent on September 20, 2026 at 09:32 PM

This document outlines a vibed Lakehouse data model for the Pc_Insurance business that can be deployed to Databricks Platform. The model is structured into business-aligned domains and denormalized data products, optimized for analytical workloads.

## Table of Contents

- [Output Folder Structure](#output-folder-structure)
- [Model Metrics](#model-metrics)
- [Business Summary](#business-summary)
- [Business Domains & Subdomains](#business-domains--subdomains)
  - [Coverage](#domain-coverage)
  - [Reinsurance](#domain-reinsurance)
  - [Billing](#domain-billing)
  - [Catastrophegeography](#domain-catastrophegeography)
  - [Claimfinancials](#domain-claimfinancials)
  - [Claims](#domain-claims)
  - [Party](#domain-party)
  - [Policy](#domain-policy)
  - [Premium](#domain-premium)
  - [Producers](#domain-producers)
  - [Riskexposure](#domain-riskexposure)
  - [Shared](#domain-shared)
- [Metric Views](#metric-views)

## Output Folder Structure

All artifacts for version **v1_mvm** are organized as follows:

```
v1/mvm/
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
| `schemas/` | `pc_insurance_<domain>_schema_v1_mvm.sql` (combined per-domain SQL: schemas/databases + tables with inline PKs + FKs + tags) |
| `schemas/` | `pc_insurance_catalogs_v1_mvm.sql` (catalog-level DDL) |
| `metrics/` | `pc_insurance_<domain>_metrics_v1_mvm.sql` (one file per domain) |
| `docs/` | `pc_insurance_model_v1_mvm.xlsx`, `pc_insurance_model_v1_mvm.csv`, `releasenotes.txt` |
| `diagram/` | `pc_insurance_dbml_v1_mvm.dbml` |
| `vibes/` | `current_vibes.txt`, `next_vibes.txt` |
| `/` | `model.json` (full model with requirements, metadata, and model data) |
| `ontology/` | `pc_insurance_rdf_v1_mvm.rdf` |
| `samples/` | One CSV file per data product (e.g., `customer.csv`, `order.csv`) |

## Model Metrics
| Metric | Value |
|---|---|
| Model Scope | MVM (Minimum Viable Model) |
| Total Domains | 12 |
| Total Subdomains | 27 |
| Total Products | 120 |
| Total Attributes | 5138 |
| Primary Keys | 121 |
| Foreign Keys | 994 |
| Avg Attributes/Product | 42.8 |
| Metric Views | 85 |

## Business Summary
| Business | Industry Alignment | Model Scope | Description | References | Version |
|---|---|---|---|---|---|
| Pc_Insurance | Property-and-Casualty-Insurance | MVM (Minimum Viable Model) | A Property & Casualty insurer underwriting personal and commercial lines. Prospects submit risk information, underwriters evaluate and price it, and quotes are bound into policies that renew, endorse, cancel, and reinstate over time. Policies carry coverages with limits, deductibles, exclusions, and conditions that attach to insured risks (properties, buildings, vehicles, drivers). Premium is booked as written, earned, unearned, and return transactions with charges, taxes, fees, and producer commission. Claims record loss events, claimants, and per-coverage exposures, with reserves, payments, recoveries, and expenses tracked as financial movements. Risk is distributed through agents and brokers and ceded through reinsurance treaties and facultative agreements, with catastrophe and geography used to aggregate exposure. | NAIC (National Association of Insurance Commissioners), State Departments of Insurance (DOI), NAIC Model Laws & Regulations, ISO (Insurance Services Office) forms & rating, ACORD (Association for Cooperative Operations Research and Development) data standards, NIPR (National Insurance Producer Registry), FIO (Federal Insurance Office), NFIP (National Flood Insurance Program - FEMA), Statutory Accounting Principles (SAP/SSAP), US GAAP (FASB), IFRS 17 (IASB), Sarbanes-Oxley (SOX), NAIC ORSA & RBC requirements, State Guaranty Associations, NCCI (National Council on Compensation Insurance), Surplus Lines Stamping Offices, Fair Credit Reporting Act (FCRA), Gramm-Leach-Bliley Act (GLBA), Solvency II (for international/EU business), Model Audit Rule (MAR), NAIC Market Conduct Standards, GDPR/CCPA (data privacy), PCI DSS (payment card security) | 1 |

## Business Domains & Subdomains

<a id="domain-coverage"></a>

### Domain: Coverage

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| coverage | operations | 2 | Bridge between the policy contract and the insured risk. Owns Coverage (one row per coverage per policy term) with attached Limit, Deductible, Exclusion, and Condition. | 15 |

**Subdomains:** contract_terms, underwriting_evaluation


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| contract_terms | condition | master_data | One row per contract Condition per Coverage. Attaches named Conditions to a Coverage and Policy Term, completing the VREQ-004 quartet alongside Limit, Deductible, and Exclusion. | 39 |
| contract_terms | coverage | master_data | One row per coverage per policy term. Bridge between the policy contract and insured risk. Captures coverage type, LOB, form number, effective/expiration dates, and status. Links to Policy Term and Insured Risk. | 45 |
| contract_terms | deductible | master_data | Deductible attached to a coverage: flat, percentage, SIR, or disappearing. Captures amount, basis, application method, and waiver flags. One row per deductible per coverage. | 35 |
| contract_terms | exclusion | master_data | Exclusion attached to a coverage: ISO or manuscript exclusion code, description, endorsement reference, and effective dates. One row per exclusion per coverage. | 35 |
| contract_terms | limit | master_data | Limit attached to a coverage: occurrence limit, aggregate limit, per-person limit, split limits. Supports stacked, CSL, and sublimit structures. One row per limit per coverage. | 34 |
| contract_terms | rate | transactional_data | Rate element applied to a coverage during pricing: rate code, rate basis, rate value, territory factor, class factor, and effective date. Supports reconstruction of premium at any point in time. | 38 |
| underwriting_evaluation | bind_request | transactional_data | Formal request to bind a quoted policy, submitted by producer or applicant. Grain: one row per bind request. Captures requested effective date, payment plan, and bind confirmation or rejection reason. | 45 |
| underwriting_evaluation | binder | transactional_data | Temporary insurance contract issued upon bind confirmation, providing coverage before the formal policy is issued. Captures binder number, effective/expiration dates, LOB, and issuing authority. | 42 |
| underwriting_evaluation | loss_history | master_data | Prior loss record for a submission or insured risk from CLUE, MVR, or applicant disclosure: loss date, cause, paid amount, open/closed status. Grain: one row per prior loss. Used in appetite and pricing. | 51 |
| underwriting_evaluation | quote | transactional_data | One row per quote version. Captures quoted premium, commission, fees, taxes, rating engine version, rating tier, and binding status. Versioned so multiple quote iterations per submission are preserved. | 45 |
| underwriting_evaluation | quote_coverage | transactional_data | One row per coverage line on a quote. Captures quoted limit, deductible, premium, exclusion/condition codes, and coverage basis per insured risk. Links to bound coverage.coverage when quote is accepted. | 49 |
| underwriting_evaluation | rating_factor | transactional_data | One row per rating factor applied during premium calculation. Records factor name, value, basis, peril, and rating engine version. Supports full rate reconstruction and actuarial audit of any quoted or written premium. | 35 |
| underwriting_evaluation | submission | transactional_data | One row per submission (application for coverage). Entry point of the underwriting lifecycle. Captures applicant, producer, LOB, risk state, estimated premium, eligibility status, and links to bound policy when accepted. | 47 |
| underwriting_evaluation | uw_decision | transactional_data | One row per underwriting decision on a submission or quote. Records accept/decline/refer outcome, risk score, authority level, conditions, exclusions added, modified limits/deductibles, and SLA compliance. | 43 |
| underwriting_evaluation | uw_referral | transactional_data | One row per underwriting referral. Tracks referral reason, priority, assigned underwriter, escalation level, SLA due date, resolution outcome, and links to submission, quote, and policy for full audit trail. | 43 |

<a id="domain-reinsurance"></a>

### Domain: Reinsurance

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| reinsurance | operations | 2 | Manages risk transfer to reinsurers. Owns Reinsurance Agreement, Treaty (QS/XOL/SL/CAT XL), Facultative Agreement, Cession, and Reinsurance Recovery linked to ceded Policy and Claim. | 10 |

**Subdomains:** agreement_structure, financial_transactions


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| agreement_structure | fac_agreement | master_data | Facultative reinsurance agreement covering a single risk or policy. One row per FAC placement. Captures cedant, reinsurer, ceded percentage, premium rate, inception/expiry, and the linked policy or submission. | 53 |
| agreement_structure | reinsurer | master_data | Master record for each reinsurance counterparty (assuming company, Lloyd's syndicate, or pool). One row per reinsurer. Stores legal name, NAIC code, AM Best rating, domicile, and authorized/unauthorized status for Schedule F credit. | 40 |
| agreement_structure | ri_agreement | master_data | Master record for a reinsurance agreement between the cedant and one or more reinsurers. One row per agreement. Captures agreement type (Treaty/Facultative), status, inception/expiry, governing law, and currency. | 48 |
| agreement_structure | ri_participant | master_data | Allocation of a reinsurer's share within a treaty or FAC agreement. One row per reinsurer per agreement. Captures signed line percentage, written line percentage, and participation effective dates. | 39 |
| agreement_structure | treaty | master_data | Defines a proportional or non-proportional treaty under a reinsurance agreement. One row per treaty. Captures treaty type (QS/XOL/SL/CAT XL), layer, retention, limit, ROL, and UNL basis. | 46 |
| agreement_structure | treaty_layer | master_data | Individual attachment/exhaustion layer within an XOL or CAT XL treaty. One row per layer per treaty. Stores attachment point, limit per occurrence, annual aggregate limit, and reinstatement terms. | 49 |
| financial_transactions | cession | transactional_data | Records risk transfer of a policy term to a treaty layer or FAC. Grain: one row per policy term per treaty layer (or FAC). Direction flag (outward/retro) distinguishes cession from retrocession. | 56 |
| financial_transactions | ri_claim_cession | transactional_data | Links a claim exposure to a reinsurance treaty layer or FAC agreement for loss recovery eligibility. One row per claim exposure per treaty layer. Stores ceded loss amount, ceded LAE, and UNL calculation basis. | 53 |
| financial_transactions | ri_premium_transaction | transactional_data | Ceded premium ledger. One row per financial movement (written, earned, unearned, return, reinstatement) for a cession. FK to cession, accounting period, treaty layer. Reinstatement rows carry occurrence reference and reinstated limit. | 54 |
| financial_transactions | ri_recovery | transactional_data | Single ceded loss ledger. Grain: one row per movement per ri_claim_cession per accounting period, discriminated by movement_type: case/IBNR/LAE reserve position, or cash recovery (loss/LAE/DCC, subrogation, salvage). | 47 |

<a id="domain-billing"></a>

### Domain: Billing

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| billing | business | 4 | Manages invoicing, collections, disbursements, delinquency, and installment plan processing for policyholders and payees. Owns billing accounts, invoices, payment transactions, payment plans, returned payments, and write-offs. | 13 |

**Subdomains:** account_management, delinquency_workflow, installment_scheduling, invoice_processing


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| account_management | account | master_data | Master billing account linking a policyholder or payee to invoicing and collections. One row per billing account. Tracks account type (direct bill, agency bill), status, payment method, and balance. | 44 |
| account_management | account_policy | association_data | Association linking a billing account to one or more policies. One row per billing-account-to-policy relationship. Supports agency bill and direct bill splits, and multi-policy billing account consolidation. | 37 |
| account_management | payment_method | master_data | Stored payment instrument on file for a billing account (credit card, ACH/EFT, check, escrow). One row per payment method per billing account. Captures instrument type, masked account details, expiry, and EFT authorization status. | 39 |
| delinquency_workflow | delinquency | transactional_data | Delinquency lifecycle for a billing account that missed installments, including all workflow actions (past-due, cancellation, reinstatement, write-off trigger) and notices issued during collections. One row per delinquency event per account. | 51 |
| delinquency_workflow | delinquency_action | transactional_data | Individual workflow action taken within a delinquency process (notice issued, cancellation initiated, reinstatement offered, write-off triggered). One row per action per delinquency. Tracks action type, action date, and outcome. | 44 |
| installment_scheduling | installment_plan | master_data | Installment schedule elected for a Policy Term with per-installment lines: number, due dates, billed/paid amounts, fees, and status. Feeds delinquency and cancellation-for-non-payment. | 43 |
| installment_scheduling | installment_schedule | transactional_data | Scheduled installment records generated for a billing account under a payment plan. One row per installment. Tracks scheduled due date, scheduled amount, actual paid amount, and installment status (due, paid, past due). | 43 |
| installment_scheduling | payment_plan | master_data | Installment plan template defining the number of installments, down payment percentage, installment frequency, and applicable fees for a billing account or policy. Master record for plan configuration. | 32 |
| invoice_processing | disbursement | transactional_data | Outbound payment to a producer, claimant, or payee, including producer commission payable pending settlement. One row per disbursement. Captures payee party, producer, policy, disbursement type (commission, refund, return premium), earned/withheld amount | 56 |
| invoice_processing | invoice | transactional_data | Billing document issued to a policyholder or agency for premium charges, fees, and taxes due. One row per invoice. Grain: one invoice per billing cycle per billing account. Tracks due date, amount billed, and status. | 49 |
| invoice_processing | invoice_item | transactional_data | Line-level detail on an invoice representing a single charge, tax, fee, or commission amount. One row per line item per invoice. Links to premium charge, coverage, and policy term for reconciliation. | 53 |
| invoice_processing | payment | transactional_data | Record of a payment received from a policyholder, agency, or third party against a billing account. One row per payment transaction. Captures payment method, amount, receipt date, and application status. | 50 |
| invoice_processing | payment_application | association_data | Links a payment to one or more invoices or invoice items, and holds all unapplied/suspense cash pending identification of the correct account or invoice. One row per application or suspense holding. | 49 |

<a id="domain-catastrophegeography"></a>

### Domain: Catastrophegeography

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| catastrophegeography | business | 2 | Provisional description for user-specified domain 'catastrophe_geography'. Awaiting a generated description of what this domain owns. | 10 |

**Subdomains:** event_management, spatial_reference


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| event_management | accumulation_limit | master_data | Insurer-defined maximum aggregate exposure limit per CAT zone, peril, and LOB. One row per zone per peril per LOB. Enforces underwriting appetite constraints; triggers referral or declination when TIV in zone exceeds the approved accumulation cap. | 41 |
| event_management | cat_event_loss | transactional_data | CAT-attribution loss ESTIMATE per CAT event per LOB per geography (one row each). Holds modeled/actual gross, ceded, and net loss and IBNR loading for Schedule P CAT reporting only -- NOT the financial ledger; authoritative payments/reserves live in | 35 |
| event_management | cat_zone | master_data | Insurer-defined CAT zone or territory used for exposure aggregation and PML modeling. One row per zone. Zones map to peril types (wind, quake, flood) and carry AAL and PML thresholds for reinsurance treaty attachment. | 40 |
| event_management | catastrophe_event | master_data | Master record of a named CAT event (hurricane, quake, wildfire, flood, tornado), one row per event. Captures event type, peril, date range, footprint, industry loss estimate, PML class, ISO CAT serial number, event name, and affected states for statutory | 43 |
| event_management | pml_run | transactional_data | A probabilistic PML modeling run executed against the exposure portfolio. One row per run. Captures model vendor, model version, run date, return period set, gross and net PML at each return period, and the exposure snapshot used as input. | 49 |
| event_management | policy_cat_exposure | association_data | Association linking an in-force policy to a CAT event or CAT zone for exposure tracking. One row per policy per CAT event or zone. Carries TIV, coverage type, and estimated gross loss used in FNOL triage and reinsurance bordereaux generation. | 43 |
| spatial_reference | geography | reference_data | Enterprise geography hierarchy node (country, state, county, ZIP, CRESTA zone, census tract). One row per geography unit. Provides the spatial backbone for territory rating, CAT aggregation, and regulatory reporting. | 31 |
| spatial_reference | location_geocode | master_data | Per-location SSOT for geocode and hazard: one row per insured location. Stores lat/long, FIPS, CRESTA zone, FEMA FIRM flood zone, base flood elevation, FIRM panel, fire protection class, and model-derived AAL/PML/hazard band per peril and CAT model | 47 |
| spatial_reference | peril | reference_data | Reference catalog of insured perils (wind, hail, earthquake, flood, fire, theft, liability). One row per peril. Carries NAIC peril code, CAT vs. non-CAT flag, reinsurance treaty peril mapping, and ISO cause-of-loss code. | 36 |
| spatial_reference | territory | reference_data | Rating territory as filed with the DOI per state and LOB. One row per territory per LOB per state. Carries territory code, effective date, filed rate relativities, residual-market/wind-pool designation flags, and links to the geography hierarchy for | 38 |

<a id="domain-claimfinancials"></a>

### Domain: Claimfinancials

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| claimfinancials | business | 2 | Provisional description for user-specified domain 'claim_financials'. Awaiting a generated description of what this domain owns. | 10 |

**Subdomains:** financial_positions, recovery_management


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| financial_positions | accounting_period | reference_data | Reference calendar for financial close cycles. Defines calendar year, accident year, policy year, and fiscal period boundaries used to bucket premium, loss, and expense transactions for statutory and GAAP reporting. | 36 |
| financial_positions | claim_expense | transactional_data | One row per expense transaction per claim exposure and accounting period. Classifies LAE into ALAE/ULAE, DCC, and AO categories with vendor, invoice reference, approval status, and GL account. Grain: one row per expense movement. | 51 |
| financial_positions | claim_payment | transactional_data | One row per payment disbursement per claim exposure per accounting period. Records indemnity, medical, and LAE payments with payee, method, check/EFT reference, void/reissue/stop-payment status, and AP batch grouping (batch id, bank account, settlement | 52 |
| financial_positions | financial_transaction | transactional_data | One row per atomic double-entry posting generated by a claim financial event (reserve, payment, recovery, expense), keyed to claim exposure and accounting period. | 52 |
| financial_positions | recovery | transactional_data | One row per recovery transaction per claim exposure per accounting period. SSOT for ALL claim recoveries: recovery_type (subrogation, salvage, reinsurance), responsible party, demand/collected/net amounts. | 51 |
| financial_positions | reserve | transactional_data | One row per reserve position per claim exposure per accounting period. Tracks Case, IBNR, and LAE reserves with opening balance, incremental movement (strengthening/release with reason code and authorizing adjuster), and closing balance. | 53 |
| recovery_management | payee | master_data | Master record for a party designated to receive claim payments. Captures payee name, tax ID (SSN/FEIN), address, bank account for EFT, 1099 reporting flag, and payee type (claimant, attorney, vendor, lienholder). | 45 |
| recovery_management | reinsurance_recovery | transactional_data | One row per reinsurance recovery billing per claim exposure and treaty or facultative agreement. Tracks ceded loss amount, ceded LAE, recovery billed, recovery collected, and outstanding balance. Links claim to reinsurance cession. | 54 |
| recovery_management | salvage | master_data | Grain: one row per salvage financial movement per claim exposure. Records proceeds recovered by taking title to damaged property. FK to claim_exposure_id and accounting_period_id. PK: salvage_id. | 49 |
| recovery_management | subrogation | master_data | Master record for a subrogation pursuit against a liable third party. Tracks demand amount, collected amount, attorney assignment, litigation status, settlement date, and net recovery after expenses per claim. | 49 |

<a id="domain-claims"></a>

### Domain: Claims

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| claims | business | 2 | Provisional description for user-specified domain 'claims'. Awaiting a generated description of what this domain owns. | 9 |

**Subdomains:** adjuster_operations, loss_management


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| adjuster_operations | adjuster | master_data | Staff or independent adjuster assigned to handle claims. Captures adjuster type (staff/IA/TPA), license number, state appointments, assignment capacity, and links to Party domain for identity. | 33 |
| adjuster_operations | adjuster_assignment | transactional_data | Assignment of an adjuster to a claim or claim exposure. Grain: one row per assignment. Tracks assignment date, reassignment reason, workload at assignment, and primary vs supervisory role. FK to adjuster and claim. | 36 |
| adjuster_operations | litigation | master_data | Litigation record attached to a claim. Tracks lawsuit filing date, plaintiff attorney, defense counsel, court jurisdiction, trial date, verdict, and settlement amount. One row per lawsuit per claim. | 41 |
| loss_management | claim | master_data | Core claim record. Grain: one row per reported loss. Captures FNOL intake, line of business, accident date, report date, status, and FK links to policy, loss_event, and reinsurance cession keys for recovery linkage. | 52 |
| loss_management | claim_exposure | association_data | Coverage line within a claim. Grain: one row per coverage per claim. Junction between Claim and Coverage/Insured Risk. Drives all financial postings; prevents fan-out double-counting of reserves and payments. | 47 |
| loss_management | claim_status | transactional_data | Lifecycle status history for a claim. Grain: one row per status transition per claim. Tracks Open, Pending, Closed, Reopened, Denied, Litigated transitions with effective timestamps and reason codes. | 37 |
| loss_management | claimant | master_data | Party involved in a claim as first-party insured or third-party claimant. Grain: one row per party per claim. Captures claimant type (FP/TP), injury or damage description, and links to Party domain. | 42 |
| loss_management | fnol | transactional_data | First Notice of Loss intake record. Grain: one row per FNOL submission. Captures report channel, reporter party, initial loss description, date/time of loss, and triage flags before a formal claim is opened. | 50 |
| loss_management | loss_event | master_data | Master record of a physical loss occurrence (storm, fire, collision, liability event). One row per occurrence. Links multiple claims arising from the same event. Supports CAT aggregation and PML analysis. | 48 |

<a id="domain-party"></a>

### Domain: Party

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| party | business | 3 | SSOT for all persons and organizations the insurer interacts with: policyholders, named/additional insureds, claimants, producers, adjusters, and payees. Owns identity, demographics, KYC, and deduplication. | 12 |

**Subdomains:** compliance_verification, contact_information, identity_management


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| compliance_verification | household | master_data | One row per household grouping of parties. Effective-dated with member count, credit score, CAT zone, territory, and marketing preferences. Supports household-level underwriting and customer analytics. | 31 |
| compliance_verification | kyc_verification | transactional_data | One row per KYC verification event for a party. Records due-diligence level, OFAC/PEP screening, identity document details, analyst decision, SAR filing, and SIU referral. Links to submission and claim contexts. | 47 |
| compliance_verification | license | master_data | One row per party license (producer, adjuster, contractor). Tracks license number, type, state, effective/expiry dates, CE credits, NIPR verification, E&O coverage, and disciplinary actions. | 43 |
| compliance_verification | loss_payee | master_data | One row per loss payee or additional interest on a policy. Links party, policy, coverage, and insured risk. Captures lender details, loan number, loss-payable clause type, and cancellation notice requirements. | 40 |
| contact_information | address | master_data | One row per party address record. Effective-dated address with geocode, USPS standardization, fire protection class, coastal/wind indicators, and CAT zone linkage. Supports territory and catastrophe aggregation. | 42 |
| contact_information | contact | master_data | One row per party contact method. Stores phone, email, and other contact channels with opt-in/opt-out flags, verification status, and effective dating. Supports do-not-contact compliance. | 39 |
| contact_information | identifier | master_data | One row per party external identifier (SSN, TIN, NPN, license number, etc.). Effective-dated with masking, verification status, and MDM golden-record linkage. Supports KYC, OFAC, and deduplication workflows. | 37 |
| contact_information | relationship | master_data | One row per directed party-to-party relationship (spouse, employer, subsidiary, etc.). Effective-dated with ownership percentage, legal basis, and UW impact flag. Supports household and corporate hierarchy traversal. | 32 |
| identity_management | individual | master_data | One row per individual (person subtype of Party). Extends party.party with person-specific attributes: name parts, DOB, SSN hash, drivers license, MVR consent, credit score, and occupational data. | 46 |
| identity_management | organization | master_data | One row per organization (entity subtype of Party). Extends party.party with org-specific attributes: legal name, FEIN, NAICS/SIC, revenue, employee count, incorporation details, and parent hierarchy. | 40 |
| identity_management | party | master_data | One row per party (person or organization). Master identity record. Roles, addresses, contacts, and identifiers are child tables. Never embed role on this record; use party.role with effective/expiration dates. | 44 |
| identity_management | role | master_data | One row per party-role assignment. A party may hold many roles over time: policyholder, named insured, additional insured, claimant, producer, adjuster, payee. Effective and expiration dates govern each assignment. | 41 |

<a id="domain-policy"></a>

### Domain: Policy

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| policy | business | 3 | Authoritative record of the insurance contract lifecycle. Owns Policy (one row per policy), Policy Term (one row per policy per term), and Policy Transaction (NB, REN, END, CAN, RI, NR). | 12 |

**Subdomains:** contract_lifecycle, party_assignment, product_configuration


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| contract_lifecycle | document | master_data | One row per policy document issued. Tracks document type, delivery method, recipient party, delivery confirmation, storage URI, and supersession chain. Links to policy, term, and transaction for full audit trail. | 48 |
| contract_lifecycle | policy | master_data | One row per policy. Master policy record anchoring the full lifecycle. Carries policy number, status, effective/expiration dates, LOB, state, and carrier. FK lineage: Party -> Policy -> Policy Term -> Coverage. | 45 |
| contract_lifecycle | policy_transaction | transactional_data | One row per policy transaction. Records every lifecycle event: New Business, Renewal, Endorsement, Cancellation, Reinstatement, Non-renewal. Effective-dated so in-force state is reconstructable at any point in time. | 46 |
| contract_lifecycle | state_reg | master_data | One row per state regulatory record per policy transaction. Captures admitted status, DOI filing, surplus lines stamping, state/municipal tax amounts, guaranty fund assessments, and mandated coverage indicators. | 40 |
| contract_lifecycle | term | master_data | One row per policy per term. Time-bounded period of a policy (annual, short-rate, etc.). Enables reconstruction of coverages and premium in force at any date including loss date. Links Policy to Coverage via Coverage table. | 45 |
| contract_lifecycle | type | reference_data | One row per policy type definition (reference/lookup). Defines LOB category, term length, minimum/maximum premium, rating algorithm version, reinsurance eligibility, and state filing requirements. | 32 |
| party_assignment | interest | master_data | One row per additional interest on a policy term (mortgagee, lienholder, certificate holder). Links party, policy term, and insured risk with effective dating, coverage scope, and notification requirements. | 38 |
| party_assignment | policy_producer | association_data | One row per producer-policy assignment. Links producer to policy and term with role type, commission rate, split percentage, license details, and servicing rights. Supports multi-producer and split-commission scenarios. | 40 |
| party_assignment | policyholder | association_data | One row per party-policy holder assignment. Links party.role to a policy and term with effective dating, holder type, interest type, billing responsibility, and waiver of subrogation. Supports multiple named insureds. | 28 |
| product_configuration | fee | transactional_data | One row per fee transaction on a policy. Records policy fee, inspection fee, installment fee, and similar charges with amount, type, accounting period, GL account, and refund/waiver tracking. | 35 |
| product_configuration | form | master_data | One row per form attached to a policy term. Tracks ISO/ACORD form number, edition date, state filing, mandatory flag, premium-bearing flag, and attachment sequence. Links to policy document for the physical artifact. | 34 |
| product_configuration | line | master_data | One row per line of business per policy term. Captures LOB-level underwriting attributes: TIV, policy limit, deductible, rate factor, reinsurance treaty, CAT zone, and written premium. Child of policy term. | 47 |

<a id="domain-premium"></a>

### Domain: Premium

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| premium | business | 2 | Transactional ledger for all premium activity. Owns Premium Transaction (one row per financial transaction: Written, Earned, Unearned, Return) tied to Policy, Policy Term, Coverage, Insured Risk, and Accounting Period, with Charge, Tax, Fee, and | 6 |

**Subdomains:** component_breakdown, transaction_recording


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| component_breakdown | charge | transactional_data | Child of Premium Transaction. One row per charge component (base premium, surcharge, credit, minimum premium) within a transaction. Enables granular decomposition of gross written premium by rating element and LOB. | 54 |
| component_breakdown | commission | transactional_data | Child of Premium Transaction. One row per producer commission calculation on a transaction: type (new/renewal/contingent), rate, basis, and computed payable. Calculation-only; commission settlement/payout is owned by the producers domain. | 44 |
| component_breakdown | policy_fee | transactional_data | Child of Premium Transaction. One row per non-premium fee (policy fee, inspection fee, installment fee) charged on a transaction. Fees are non-taxable in most jurisdictions and tracked separately from taxable premium. | 39 |
| component_breakdown | tax_levy | transactional_data | Child of Premium Transaction. One row per state or surplus-lines tax, stamping fee, or regulatory assessment applied to a premium transaction. Tracks tax type, jurisdiction, rate, and computed amount for statutory remittance. | 36 |
| transaction_recording | premium_transaction | transactional_data | Grain: one row per financial premium transaction. Carries FKs to policy, policy term, coverage, insured risk, and accounting period. transaction_type enumerates Written, Earned, Unearned, Return. | 53 |
| transaction_recording | rate_table | reference_data | Versioned rate table published by the rating engine for a specific LOB, state, and effective date. Stores base rates, factors, and minimum premiums. Provides the authoritative rate version used to price each Policy Term. | 47 |

<a id="domain-producers"></a>

### Domain: Producers

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| producers | business | 2 | Provisional description for user-specified domain 'producers'. Awaiting a generated description of what this domain owns. | 11 |

**Subdomains:** agent_management, compensation_processing


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| agent_management | agency | master_data | Master record for an insurance agency or brokerage firm. One row per agency. Captures agency name, FEIN, NAIC code, principal address, agency type, and parent agency hierarchy for MGA and wholesale relationships. | 33 |
| agent_management | agency_producer | association_data | Association between a producer and an agency capturing the employment or affiliation relationship. One row per producer-agency pairing. Stores role, start date, end date, and primary-agency flag. | 39 |
| agent_management | distribution_channel | reference_data | Reference classification of how business reaches the insurer (captive, independent, broker, direct, MGA, wholesale, affinity, digital). One row per channel. Drives commission schedule selection and producer underwriting authority rules. | 34 |
| agent_management | producer_appointment | master_data | Formal appointment and binding authority granted by the insurer to a producer to sell specific lines in a state. One row per producer per insurer per state per LOB. | 46 |
| agent_management | producer_license | master_data | Individual state license held by a producer. One row per producer per state per license class. Tracks license number, line of authority, issue date, expiration date, and DOI status for compliance and appointment eligibility. | 44 |
| agent_management | producers_producer | master_data | Master record for every licensed insurance producer (agent or broker). One row per producer. Stores NPN, license numbers, resident state, producer type, appointment status, and E&O coverage details. | 42 |
| agent_management | underwriting_authority | master_data | Defines the binding authority granted to a producer or agency by LOB, coverage type, and limit tier. One row per authority grant. Tracks max TIV, max single-risk limit, eligible states, and authority expiration date. | 46 |
| compensation_processing | commission_rule | reference_data | Individual rate rule within a commission schedule. One row per rule. Specifies transaction type (NB, REN, END), LOB, coverage type, base rate, contingent rate, override rate, and effective date range. | 40 |
| compensation_processing | commission_schedule | master_data | Contractual commission rate set for a producer or agency by LOB, transaction type (NB/REN/END), and coverage type over an effective period. One row per schedule version. Holds all rate lines (base, contingent, override) as embedded detail. | 45 |
| compensation_processing | commission_statement | transactional_data | Periodic statement issued to a producer or agency summarizing commission transactions due for a billing cycle. One row per statement. Tracks statement date, total earned, total adjustments, net payable, and payment status. | 42 |
| compensation_processing | commission_transaction | transactional_data | One row per commission financial movement earned by a producer on a premium transaction. Captures earned amount, claw-back amount, transaction type, accounting period, and payment status. Child of premium transaction. | 46 |

<a id="domain-riskexposure"></a>

### Domain: Riskexposure

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| riskexposure | business | 2 | Provisional description for user-specified domain 'risk_exposure'. Awaiting a generated description of what this domain owns. | 9 |

**Subdomains:** exposure_assessment, risk_objects


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| exposure_assessment | risk_inspection | transactional_data | Physical or virtual inspection of an insured risk that produces exposure facts of record (condition, hazards, valuation checks). One row per inspection. Stores inspection type, ordered/completed dates, inspector party, findings summary, and recommendation | 44 |
| exposure_assessment | risk_score | transactional_data | Point-in-time risk score attached to an insured risk for exposure grading. One row per scoring event per risk. Stores score value, model version, score date, component scores, and referral threshold flag. | 45 |
| risk_objects | auto_risk | master_data | Auto-line subtype of insured_risk. One row per auto risk unit. Captures garaging state, primary use, annual mileage, radius of operation, and links to vehicle and driver records for PAP and CA rating. | 39 |
| risk_objects | building | master_data | Individual structure on an insured location. One row per building. Captures number of stories, roof type, roof year, frame type, sprinkler indicator, replacement cost value, and ISO building class for property rating. | 46 |
| risk_objects | driver | master_data | Licensed operator associated with an auto risk. One row per driver. Captures license number/state, DOB, gender, marital status, years licensed, SR-22 indicator, and MVR order/receipt/status and clean-record fields (absorbed from mvr_report) for auto | 42 |
| risk_objects | insured_risk | master_data | Supertype master for every insurable object underwritten on a policy. One row per insured risk. Subtypes property_risk and auto_risk extend it via shared PK (explicit subtype FK). | 43 |
| risk_objects | location | master_data | Physical address and geocoded site associated with a property risk. One row per insured location. Stores street address, lat/long, FIPS code, territory code, flood zone, and links to geography hierarchy for CAT aggregation. | 41 |
| risk_objects | property_risk | master_data | Property-line subtype of insured_risk. One row per property risk. Captures COPE attributes (Construction, Occupancy, Protection, Exposure), ITV, year built, square footage, and ISO construction class for rating and CAT modeling. | 45 |
| risk_objects | vehicle | master_data | Motor vehicle associated with an auto risk. One row per vehicle. Stores VIN, year, make, model, body type, ISO symbol, stated value, anti-theft device indicator, and safety rating for auto rating and claims. | 42 |

<a id="domain-shared"></a>

### Domain: Shared

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| shared | corporate | 1 | Cross-domain shared reference entities (currency, UoM, calendar, classification) consolidated for Single Source of Truth (SSOT). | 3 |

**Subdomains:** shared_core


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| shared_core | calendar | Master | Enterprise calendar reference of fiscal, accident, policy, and calendar-year periods. One row per period. Complements domain-local accounting_period tables by providing a single cross-domain date dimension. | 31 |
| shared_core | currency | Master | Reference catalog of ISO 4217 currencies used across premium, claim, billing, and reinsurance financial transactions. One row per currency code. Carries code, name, minor unit, and active flag. | 19 |
| shared_core | line_of_business | Master | Reference catalog of P&C lines of business (HO, PAP, CGL, BOP, CPP, WC, Commercial Auto, Umbrella). One row per LOB. SSOT for LOB codes referenced by policy, coverage, premium, claim, and reinsurance. | 29 |

## Metric Views

Total metric views generated: **85**. Showing top 20.

| # | View Name | Domain | Source Table | Description |
|---|---|---|---|---|
| 1 | coverage | coverage | coverage | Coverage-level KPIs tracking limits, deductibles, premium, and exposure units for portfolio risk and pricing analysis. |
| 2 | coverage_binder | coverage | binder | Binder lifecycle KPIs tracking temporary coverage issuance, conversion to policy, and binding authority utilization. |
| 3 | coverage_deductible | coverage | deductible | Deductible structure KPIs tracking deductible amounts, types, and waiver rates for claims cost-sharing analysis. |
| 4 | coverage_limit | coverage | limit | Limit structure KPIs tracking aggregate and per-occurrence limits, attachment points, and erosion for exposure management. |
| 5 | coverage_loss_history | coverage | loss_history | Prior loss KPIs tracking claim frequency, severity, and surcharge impact for underwriting risk assessment and pricing. |
| 6 | coverage_quote | coverage | quote | Quote performance KPIs tracking bind rates, premium adequacy, and distribution channel effectiveness for pricing and sales optimization. |
| 7 | coverage_submission | coverage | submission | Submission lifecycle KPIs tracking quote conversion, referral rates, and risk appetite scoring for underwriting pipeline management. |
| 8 | coverage_uw_decision | coverage | uw_decision | Underwriting decision KPIs tracking approval rates, referral reasons, risk tiers, and SLA compliance for underwriting efficiency. |
| 9 | reinsurance_cession | reinsurance | cession | Reinsurance cession transactions tracking ceded premium, limits, and reserves by treaty, facultative agreement, and reinsurer. Grain: one row per cession transaction. |
| 10 | reinsurance_reinsurer | reinsurance | reinsurer | Reinsurer master data tracking authorization status, financial ratings, credit limits, and collateral requirements. Grain: one row per reinsurer. |
| 11 | reinsurance_ri_agreement | reinsurance | ri_agreement | Reinsurance agreements defining treaty and facultative structures with limits, attachments, and commission terms. Grain: one row per reinsurance agreement. |
| 12 | reinsurance_ri_claim_cession | reinsurance | cession | Reinsurance claim cessions tracking ceded loss, reserves, and recoveries by claim exposure and reinsurer. Grain: one row per claim cession transaction. |
| 13 | reinsurance_ri_premium_transaction | reinsurance | ri_premium_transaction | Reinsurance premium transactions tracking ceded written, earned, and unearned premium with ceding commission and profit commission. Grain: one row per premium transaction. |
| 14 | reinsurance_ri_recovery | reinsurance | ri_recovery | Reinsurance recoveries tracking billed, collected, and outstanding recovery amounts by claim and reinsurer. Grain: one row per recovery transaction. |
| 15 | reinsurance_treaty | reinsurance | treaty | Reinsurance treaties defining proportional and non-proportional structures with layer limits, attachments, and commission terms. Grain: one row per treaty. |
| 16 | billing_account | billing | account | Billing account KPIs: balance, delinquency, payment behavior, and account health metrics. Grain: one row per billing account. |
| 17 | billing_delinquency | billing | delinquency | Delinquency KPIs: past-due accounts, aging, collections activity, and resolution rates. Grain: one row per delinquency case. |
| 18 | billing_disbursement | billing | disbursement | Disbursement KPIs: outbound payment volume, amounts, types, and payee analysis. Grain: one row per disbursement transaction. |
| 19 | billing_installment_plan | billing | installment_plan | Installment plan KPIs: plan performance, payment progress, delinquency rates, and plan completion. Grain: one row per installment plan. |
| 20 | billing_invoice | billing | invoice | Invoice KPIs: billing volume, amounts due, payment status, and aging. Grain: one row per invoice. |

*... and 65 more metric views. See the `metrics/` folder for full details.*