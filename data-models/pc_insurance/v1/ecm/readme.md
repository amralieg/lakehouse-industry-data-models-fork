# Pc_Insurance Lakehouse Data Model

**v1_ecm** generated using Vibe Modelling Agent on September 18, 2026 at 02:23 AM

This document outlines a vibed Lakehouse data model for the Pc_Insurance business that can be deployed to Databricks Platform. The model is structured into business-aligned domains and denormalized data products, optimized for analytical workloads.

## Table of Contents

- [Output Folder Structure](#output-folder-structure)
- [Model Metrics](#model-metrics)
- [Business Summary](#business-summary)
- [Business Domains & Subdomains](#business-domains--subdomains)
  - [Reinsurance](#domain-reinsurance)
  - [Claims](#domain-claims)
  - [Coverage](#domain-coverage)
  - [Policy](#domain-policy)
  - [Premium](#domain-premium)
  - [Producers](#domain-producers)
  - [Reservespayments](#domain-reservespayments)
  - [Riskexposure](#domain-riskexposure)
  - [Shared](#domain-shared)
- [Metric Views](#metric-views)

## Output Folder Structure

All artifacts for version **v1_ecm** are organized as follows:

```
v1/ecm/
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
| `schemas/` | `pc_insurance_<domain>_schema_v1_ecm.sql` (combined per-domain SQL: schemas/databases + tables with inline PKs + FKs + tags) |
| `schemas/` | `pc_insurance_catalogs_v1_ecm.sql` (catalog-level DDL) |
| `metrics/` | `pc_insurance_<domain>_metrics_v1_ecm.sql` (one file per domain) |
| `docs/` | `pc_insurance_model_v1_ecm.xlsx`, `pc_insurance_model_v1_ecm.csv`, `releasenotes.txt` |
| `diagram/` | `pc_insurance_dbml_v1_ecm.dbml` |
| `vibes/` | `current_vibes.txt`, `next_vibes.txt` |
| `/` | `model.json` (full model with requirements, metadata, and model data) |
| `ontology/` | `pc_insurance_rdf_v1_ecm.rdf` |
| `samples/` | One CSV file per data product (e.g., `customer.csv`, `order.csv`) |

## Model Metrics
| Metric | Value |
|---|---|
| Model Scope | ECM (Expanded Coverage Model) |
| Total Domains | 9 |
| Total Subdomains | 24 |
| Total Products | 170 |
| Total Attributes | 6775 |
| Primary Keys | 170 |
| Foreign Keys | 904 |
| Avg Attributes/Product | 39.9 |
| Metric Views | 120 |

## Business Summary
| Business | Industry Alignment | Model Scope | Description | References | Version |
|---|---|---|---|---|---|
| Pc_Insurance | Property-Casualty-Insurance | ECM (Expanded Coverage Model) | A Property & Casualty insurer that underwrites personal and commercial lines, binds policies with coverages and endorsements, prices premium against rated risk exposures, adjudicates and pays claims, holds and develops loss reserves, cedes risk through reinsurance treaties and facultative certificates, and distributes through agents and brokers who earn commission. | NAIC (National Association of Insurance Commissioners), State Departments of Insurance (DOI), NCCI (National Council on Compensation Insurance), ISO/Verisk (Insurance Services Office), A.M. Best and S&P Rating Agencies, FIO (Federal Insurance Office), IAIS (International Association of Insurance Supervisors), NFIP (National Flood Insurance Program), Statutory Accounting Principles (SAP/STAT), US GAAP and FASB, IFRS 17 for international entities, SOX (Sarbanes-Oxley), NIST and PCI DSS for data security, State Guaranty Associations | 1 |

## Business Domains & Subdomains

<a id="domain-reinsurance"></a>

### Domain: Reinsurance

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| reinsurance | operations | 3 | Owns RI treaty and facultative (FAC) placements, cession and bordereaux processing, XOL, QS, CAT XL, and CAT Bond structures. Tracks retention/limit layers, ceded premium, ceded loss, and recoverable balances per treaty or certificate. | 20 |

**Subdomains:** cession_processing, financial_settlement, treaty_management


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| cession_processing | bordereaux | transactional_data | Periodic bordereaux submission record sent to reinsurers summarizing ceded premium and loss activity for a treaty period. Captures bordereaux type (premium or loss), reporting period, submission date, and aggregate ceded amounts. | 44 |
| cession_processing | bordereaux_line | transactional_data | Individual line item within a bordereaux submission representing one cession or claim entry. Stores policy reference, ceded premium, ceded loss, ceded LAE, and line-level status for granular bordereaux reconciliation. | 48 |
| cession_processing | ceded_premium_transaction | transactional_data | Transactional record of each ceded premium movement (written, earned, return) under a treaty or FAC certificate. Tracks GWP ceded, NWP ceded, UEP ceded, DAC ceded, accounting period, and settlement status. | 45 |
| cession_processing | policy_cession | association_data | Junction table resolving the many-to-many relationship between policies and cessions. Tracks which policies are ceded under which cession records, with ceded share, effective period, and endorsement reference per policy-cession pairing. | 41 |
| cession_processing | reinsurance_cession | transactional_data | Transactional cession event linking a ceded policy or risk exposure to a treaty or FAC certificate via foreign keys. Captures ceded TIV, premium, limit, retention, effective date, share, per-policy endorsement reference, and cession basis (pro-rata or | 48 |
| financial_settlement | ceded_loss_transaction | transactional_data | Ledger of each ceded loss, LAE, and reserve movement (paid, case/OCR, IBNR, IBNER) reported to a reinsurer under a treaty or FAC. Single owner of ceded reserve balances after ri_loss_reserve merge. | 47 |
| financial_settlement | claim_ri_recovery | association_data | Junction table resolving the many-to-many relationship between claims and reinsurance recoveries. Links a specific claim to one or more treaty/FAC recoveries, capturing recovered amount, recovery basis, and payment reference per claim-recovery pairing. | 46 |
| financial_settlement | occurrence_loss | transactional_data | Aggregates losses from multiple claims into a single occurrence for XOL treaty application. Stores occurrence date, peril, total gross loss, total ceded loss, applicable treaty layer, and hours clause compliance flag. | 48 |
| financial_settlement | profit_commission | transactional_data | Tracks profit commission calculations and accruals owed to Pc_Insurance under QS treaties with profit commission clauses. Stores loss ratio threshold, sliding scale parameters, calculated commission rate, and accrued commission amount. | 44 |
| financial_settlement | reinstatement | transactional_data | Records reinstatement of treaty limit following a loss occurrence under XOL or CAT XL treaties. Captures reinstatement premium, reinstated limit, occurrence reference, reinstatement number, and effective date per treaty layer. | 40 |
| financial_settlement | ri_recoverable | transactional_data | Tracks outstanding reinsurance recoverable balances and ceded loss reserves (OCR, IBNR, IBNER) owed by reinsurers for paid and reserved losses under treaty and FAC agreements. | 43 |
| financial_settlement | ri_settlement | transactional_data | Records each account-current statement and cash settlement of net balances between Pc_Insurance and a reinsurer for a treaty period. | 41 |
| treaty_management | cat_bond | master_data | Master record for each catastrophe bond (CAT Bond) instrument issued or held by Pc_Insurance. Tracks trigger type (indemnity, parametric, index), attachment, exhaustion, coupon, maturity date, SPV details, and outstanding notional. | 42 |
| treaty_management | fac_certificate | master_data | Master record for each facultative (FAC) reinsurance certificate placed on a specific risk or policy. Tracks FAC type, ceded limit, ceded premium, reinsurer, and certificate status independent of treaty structures. | 44 |
| treaty_management | reinsurer | master_data | Master record for each reinsurance counterparty (reinsurer or retrocessionaire). Captures legal name, NAIC code, A.M. Best rating, domicile, authorized status, and credit limit for counterparty risk management. | 45 |
| treaty_management | ri_broker | master_data | Master record for each reinsurance intermediary (RI broker) involved in treaty or FAC placement. Captures broker legal name, Lloyd's registration, brokerage rate, contact details, and authorized markets for placement management. | 39 |
| treaty_management | ri_placement | transactional_data | Tracks the placement workflow for a treaty or FAC certificate from slip submission through binding. Captures placement stage, market approached, lead reinsurer, signed line percentage, brokerage, and binding date. | 46 |
| treaty_management | ri_treaty | master_data | Master record for each reinsurance treaty (XOL, QS, CAT XL, CAT Bond) placed by Pc_Insurance. Captures treaty type, structure, effective/expiry dates, reinsurer panel, retention, limit, and placement status. | 51 |
| treaty_management | treaty_layer | master_data | Defines each retention/limit layer within a treaty (e.g., first XOL layer, second XOL layer, QS tranche). Stores attachment point, limit, ROL, and layer sequence for multi-layer treaty structures. | 46 |
| treaty_management | treaty_reinsurer | association_data | Junction table linking a treaty to its participating reinsurers with each reinsurer's subscribed share percentage, signed line, written line, and participation status. Supports multi-reinsurer panel structures. | 44 |

<a id="domain-claims"></a>

### Domain: Claims

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| claims | business | 4 | Provisional description for user-specified domain 'claims'. Awaiting a generated description of what this domain owns. | 22 |

**Subdomains:** adjudication_operations, financial_settlement, loss_intake, special_handling


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| adjudication_operations | adjuster | master_data | Claims adjuster master: staff or independent adjuster name, license number, state appointments, adjuster type (staff/IA/TPA), specialization (CAT/auto/GL/WC), and current workload capacity. SSOT for adjuster identity. | 44 |
| adjudication_operations | adjuster_assignment | transactional_data | Assignment of an adjuster to a claim: assignment date, role (primary/supervisor/CAT/specialist), reassignment reason, and active flag. Tracks adjuster workload and claim ownership history. | 39 |
| adjudication_operations | claim_document | transactional_data | Document attached to a claim: document type (police report/medical record/estimate/DEC page), source system, file reference (OpenText/FileNet), upload date, author, and retention class. Supports adjudication and litigation. | 42 |
| adjudication_operations | claim_note | transactional_data | Structured diary and activity note on a claim: note type (diary/coverage/legal/medical), author, note date, body text, confidentiality flag, and linked activity. Supports adjudication audit trail and litigation management. | 38 |
| adjudication_operations | damage_estimate | transactional_data | Property or vehicle damage estimate: estimator type (staff/IA/vendor), estimate date, RCV amount, ACV amount, depreciation, repair vs. total-loss decision, and vendor reference. Supports APD and property claim settlement. | 41 |
| adjudication_operations | service_assignment | association_data | Association between claim and service_vendor capturing each engagement of a third-party vendor on a claim. Tracks assignment lifecycle, performance, and cost for vendor management and regulatory reporting.. | 10 |
| adjudication_operations | service_vendor | master_data | Third-party service vendor engaged on a claim: vendor type (body shop/restoration/IA/attorney/IME/nurse case manager), TIN, license, preferred-vendor flag, state approvals, and performance tier. SSOT for claim vendor master. | 46 |
| financial_settlement | claims_claim_payment | association_data | Junction table linking a claim (or claim-coverage line) to a disbursement: payee, payment amount, payment type (indemnity/ALAE/ULAE/subrogation recovery), check number, and payment date. Resolves the many-to-many claim-to-payment relationship. | 46 |
| financial_settlement | claims_loss_reserve | transactional_data | Case reserve for a claim or claim-coverage line: OCR amount, ALAE reserve, reserve type (case/IBNR/IBNER), set date, basis, and actuarial segment. SSOT for reserve development fed to actuarial reserving. | 35 |
| financial_settlement | claims_reserve_transaction | transactional_data | Audit-grade ledger of every reserve movement on a claim: prior amount, new amount, delta, transaction type (set/increase/decrease/close), and authorizing adjuster. Supports IBNR development and NAIC Schedule P triangles. | 42 |
| financial_settlement | disbursement | transactional_data | Financial disbursement record for a claim payment: payee party, bank/check details, gross amount, net amount, withholding, void flag, EFT/check indicator, and GL posting reference. SSOT for claim cash outflow. | 42 |
| loss_intake | claim | master_data | Master P&C claim record for a loss event: claim number, line of business, coverage type, loss cause, CAT code, open/closed status, adjuster assignment, and total incurred. SSOT for claim activity. | 46 |
| loss_intake | claim_coverage | association_data | Junction resolving the many-to-many claim-to-coverage relationship: applicable limit, deductible, SIR, coverage part, and coverage-level incurred amounts for each policy coverage triggered by the loss. | 40 |
| loss_intake | claim_peril_causation | association_data | Association between claim and peril capturing which perils contributed to a loss event. Records proximate vs concurrent cause determinations, contribution percentages for apportionment, and causation analysis required for coverage application and | 17 |
| loss_intake | claim_status_history | transactional_data | Immutable log of every claim status transition: prior status, new status, transition reason, effective timestamp, and acting user. Supports SLA compliance, adjudication audit, and regulatory reporting. | 34 |
| loss_intake | claimant | master_data | Party asserting a loss under a claim: name, role (insured, third-party, lienholder), contact details, injury/damage type, representation status, and attorney info. Supports BI, PD, PIP, and WC claimant tracking. | 43 |
| loss_intake | fnol | transactional_data | First Notice of Loss record capturing initial claim intake: date of loss, loss location, reported peril, claimant contact, policy reference, and FNOL channel. SSOT for claim origination events. | 42 |
| special_handling | attorney | master_data | Master reference table for attorney. Referenced by attorney_id. | 33 |
| special_handling | fraud_referral | transactional_data | Operational SIU fraud referral record for a claim: referral date, referral reason, SIU investigator assigned, investigation status, outcome (confirmed fraud/unfounded/pending), and recovery amount. Supports SIU workflow. | 49 |
| special_handling | litigation | transactional_data | Litigation record for a claim in suit: plaintiff attorney, defense counsel, court jurisdiction, suit filed date, trial date, verdict amount, settlement amount, and litigation status. Tracks legal exposure and LAE spend. | 38 |
| special_handling | medical_bill | transactional_data | Medical bill record for BI, PIP, MedPay, or WC claims: provider NPI, bill date, CPT codes, billed amount, allowed amount, paid amount, bill review outcome, and fee schedule applied. Supports medical cost containment. | 41 |
| special_handling | tpa | master_data | Master reference table for tpa. Referenced by tpa_id. | 39 |

<a id="domain-coverage"></a>

### Domain: Coverage

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| coverage | business | 3 | SSOT for coverage structures, endorsements, limits, deductibles, SIR, and exclusions attached to a policy. Manages LOB-specific forms (GL, CGL, BOP, WC, APD, BI/PD, UM/UIM, PIP, MedPay) and tracks TIV and ITV per insured location or vehicle. | 18 |

**Subdomains:** policy_binding, product_catalog, risk_valuation


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| policy_binding | additional_insured | master_data | Additional insured (AI) endorsement records granting third-party coverage rights on a policy. Captures AI name, relationship type (lessor, lender, owner), endorsement form, and scope of coverage granted. | 45 |
| policy_binding | amendment | transactional_data | Tracks mid-term amendments to coverage terms (limit changes, deductible changes, added/removed locations or vehicles) outside of a full endorsement cycle. Records change reason, effective date, and prior vs new values. | 44 |
| policy_binding | coverage_policy_coverage | association_data | Junction table resolving the M:N relationship between policies and coverage forms. Carries effective/expiration dates, coverage status, and sequence order. SSOT for which coverages are attached to a given policy term. | 47 |
| policy_binding | endorsement | transactional_data | ENDT records modifying, adding, or deleting coverage on a policy, including AI grants, subrogation waivers, and mid-term amendments. Captures endorsement type, form number, edition/effective date, premium impact, beneficiary/scope, and prior vs new values. | 45 |
| policy_binding | named_insured | master_data | Named insured parties listed on the declarations page (DEC) of a policy. Supports multiple named insureds per policy with role (first named, additional named), FEIN/SSN reference, and DBA name. | 44 |
| policy_binding | peril | association_data | Junction table associating coverage forms with the specific perils they insure or exclude. Carries insured/excluded flag, sublimit linkage, and peril-specific deductible override for each coverage-peril combination. | 2 |
| policy_binding | waiver_of_subrogation | master_data | Waiver of subrogation endorsement records granting a third party immunity from recovery actions. Captures beneficiary name, relationship, endorsement form number, and effective coverage scope. | 42 |
| product_catalog | coverage_form | master_data | Master catalog of ISO and proprietary coverage forms available for each LOB (GL, CGL, BOP, WC, APD, BI/PD, UM/UIM, PIP, MedPay). Defines form number, edition date, filing jurisdiction, and applicable line of business. | 43 |
| product_catalog | coverage_peril | reference_data | Reference catalog of insured and excluded perils (fire, wind, hail, flood, earthquake, theft, liability). Stores ISO peril code, peril category, CAT designation flag, and NFIP overlap indicator. | 65 |
| product_catalog | deductible | master_data | SSOT for deductible and self-insured retention (SIR) per attached coverage: flat, percentage, split, disappearing, and SIR-layer structures. Captures amount, basis, application method, defense-inside-SIR flag, aggregate SIR cap, and erosion basis. | 42 |
| product_catalog | exclusion | master_data | Coverage exclusions, sublimits, conditions, and warranties attached to a coverage form or endorsement. Records clause type, peril/property class scope, and sublimit amount. | 42 |
| product_catalog | limit | master_data | SSOT for coverage limit structures per attached coverage: per-occurrence, aggregate, per-person, split, CSL, and peril-specific sublimits modeled via self-referencing parent-limit link. | 45 |
| product_catalog | part | master_data | Represents a discrete coverage part within a policy (e.g., CGL Coverage Part, Commercial Property Part, WC and EL Part). Groups related coverage forms under a single insuring agreement within a CPP or BOP structure. | 46 |
| product_catalog | product | master_data | Master reference table for product. Referenced by product_id. | 43 |
| product_catalog | sir_layer | master_data | Self-Insured Retention layer record for large commercial and excess policies. Tracks SIR amount, defense-inside vs outside SIR flag, aggregate SIR cap, and erosion basis (paid vs incurred). | 47 |
| risk_valuation | cession | association_data | Represents the cession of a specific policy coverage to a reinsurer. Captures the reinsurer's participation share, ceded limits, recoverable balances, and settlement status for each coverage-reinsurer combination.. | 15 |
| risk_valuation | exposure | master_data | Junction resolving the M:N between coverage_policy_coverage and insured exposures (insured_location, scheduled_vehicle, scheduled_item). Carries applied limit, deductible, and coverage scope per exposure. | 38 |
| risk_valuation | itv_assessment | transactional_data | Insurance-to-Value (ITV) assessment records for insured property locations. Captures assessed replacement cost value (RCV), reported TIV, ITV ratio, assessment method (Marshall Swift, CoreLogic), and coinsurance penalty flag. | 43 |

<a id="domain-policy"></a>

### Domain: Policy

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| policy | business | 2 | SSOT for the policy lifecycle across personal and commercial lines: issuance, endorsements (ENDT), cancellations (CANC), renewals (REN), reinstatements, and declarations (DEC). Anchors the core lineage policy to coverage to insured risk and exposure. | 24 |

**Subdomains:** contract_administration, risk_evaluation


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| contract_administration | condition | master_data | Records special conditions, warranties, and UW requirements attached to a policy version: condition type, description, compliance due date, and whether the condition has been satisfied or is outstanding. | 38 |
| contract_administration | coverage_cession | association_data | Junction table resolving the M:N relationship between policy coverages and reinsurance cessions. Captures coverage-specific ceded limits, share percentages, layer allocations, and effective dates for each coverage-cession pairing.. | 14 |
| contract_administration | declarations | master_data | DEC page record for a policy version: summarizes insured name, policy number, LOB, coverage summary, TIV, total premium, and effective/expiration dates. Represents the formal policy document snapshot issued to the insured. | 42 |
| contract_administration | document | master_data | Metadata registry for policy documents: DEC page instance, ENDT, CANC notice, binder, and COI. Stores document type, DEC snapshot fields, certificate-holder details, generation date, delivery method, and CMS reference. | 46 |
| contract_administration | document_template | master_data | Master reference table for document_template. Referenced by template_id. | 40 |
| contract_administration | form_filing | association_data | Represents the regulatory filing and approval of a policy form in a specific state. Each record tracks the filing status, approval dates, and effective period for one form-state combination managed by compliance teams.. | 12 |
| contract_administration | insured | association_data | Association table linking insureds to a policy version with role (named insured, additional insured, loss payee, mortgagee). Supports multiple insured parties per policy and tracks role effective dates. | 2 |
| contract_administration | location_condition | association_data | Association between policy conditions and insured locations. Tracks compliance status, due dates, and satisfaction for underwriting requirements imposed on specific premises.. | 14 |
| contract_administration | policy | master_data | Master record for a P&C policy across personal and commercial lines. SSOT for policy identity, LOB and NAIC line code, term dates, and status. Anchors the lifecycle: NB, REN, ENDT, CANC, reinstatement, non-renewal. | 44 |
| contract_administration | policy_coverage | association_data | Junction table resolving the M:N relationship between policies and coverages. Carries coverage-specific limits, deductibles, SIR, and effective dates as they apply to a specific policy version. | 42 |
| contract_administration | policy_form | reference_data | Reference catalog of policy forms and ISO form numbers used across LOBs: form number, edition date, form type (base, endorsement, exclusion), applicable states, and regulatory filing status. | 24 |
| contract_administration | policy_insured | master_data | Master record for the named insured or additional insured on a policy. Captures party identity (individual or commercial entity), FEIN/SSN, DBA, and insured type. SSOT for insured party within the policy domain. | 71 |
| contract_administration | policy_producer | association_data | Junction table linking a policy to the writing producer (agent/broker) and servicing producer. Captures producer role, commission split percentage, appointment effective date, and producer code. | 44 |
| contract_administration | policy_transaction | master_data | Unified transaction ledger per policy version: transaction type (NB, ENDT, CANC, REN, reinstatement, non-renewal), effective date, premium impact, reason code, initiating party, form/ISO reference, and notice-compliance fields. | 43 |
| contract_administration | premium_cession_allocation | association_data | Association product representing the allocation of direct policy premium transactions to reinsurance ceded premium transactions. Each record links one policy transaction to one ceded premium transaction with cession-specific allocation attributes.. | 12 |
| contract_administration | status_history | transactional_data | Audit trail of all policy status transitions (active, cancelled, lapsed, expired, reinstated, non-renewed). Records prior status, new status, transition timestamp, and the triggering transaction reference. | 37 |
| contract_administration | vehicle_form_application | association_data | Association between policy forms and insured vehicles, tracking which forms apply to each vehicle with effective dates, mandatory status, and state-specific versions for regulatory compliance and coverage verification.. | 13 |
| contract_administration | version | transactional_data | Immutable snapshot of a policy at each transaction (NB, ENDT, REN, CANC, reinstatement). Tracks effective and expiration dates per version, enabling full audit lineage of policy changes over time. | 39 |
| risk_evaluation | binder | transactional_data | Temporary insurance binder record providing coverage confirmation prior to formal policy issuance. Captures binder number, effective date, expiration date, coverage summary, and binding authority used. | 41 |
| risk_evaluation | policy_rate_filing | reference_data | Reference record for approved rate and form filings with state DOIs. Tracks filing number, LOB, effective date, state, filing type (rate, rule, form), approval status, and SERFF tracking number. | 36 |
| risk_evaluation | quote | transactional_data | Pre-bind quote and temporary binder: rated premium, coverage options, TIV, quote and binder effective/expiration dates, binding authority, binder number, and status (draft, presented, bound, declined). | 47 |
| risk_evaluation | submission | transactional_data | Underwriting submission record representing an application for coverage: submission date, source channel, LOB, applicant details, risk information, and submission status (new, in-review, quoted, bound, declined). | 42 |
| risk_evaluation | underwriter | master_data | Master reference table for underwriter. Referenced by underwriter_id. | 27 |
| risk_evaluation | uw_decision | transactional_data | Underwriting decision record for a policy submission or renewal: UW action (accept, decline, refer, modify), decision date, UW authority level, reason codes, and any conditions or exclusions imposed. | 44 |

<a id="domain-premium"></a>

### Domain: Premium

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| premium | business | 3 | SSOT for premium transactions: GWP, NWP, WP, EP, UEP, DAC, and billing. Owns rate calculations (RPP, ROL), installment schedules, payment applications, and billing events. Links rated risk exposures and premium back to the bound policy. | 17 |

**Subdomains:** payment_collection, premium_accounting, rating_calculation


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| payment_collection | agency_bill_statement | transactional_data | Monthly agency bill statement sent to producing agents/brokers summarizing net premiums due, commissions retained, and balance owed. Supports agency bill reconciliation and producer account settlement. | 43 |
| payment_collection | billing_account | master_data | Master billing account grouping one or more policies under a single payer relationship. Manages payment plan, billing method (direct bill vs. agency bill), and account-level balance. SSOT for payer identity in billing. | 43 |
| payment_collection | finance_agreement | master_data | Records premium financing arrangements where a third-party premium finance company funds the policy premium. Tracks financed amount, interest rate, repayment schedule, and power-of-attorney cancellation rights. | 43 |
| payment_collection | installment | transactional_data | Individual installment due record within a schedule: due date, billed amount, paid amount, outstanding balance, and delinquency status. Drives billing notices, late fees, and cancellation-for-nonpayment workflows. | 38 |
| payment_collection | installment_schedule | master_data | Payment-plan definition and instantiated billing schedule for an account or policy: plan code/name, installment count, down payment, due dates, amounts, fees, and eligibility by LOB and state. | 40 |
| payment_collection | payment | transactional_data | Records each premium payment received: date, amount, method (check, ACH, card), and any unapplied suspense balance pending policy/account matching. Applied to installments via the payment_application junction. | 38 |
| payment_collection | payment_application | association_data | Junction table resolving the many-to-many relationship between premium payments and installments. Records applied amount, application date, and sequence. Enables full cash application audit trail. | 30 |
| premium_accounting | dac_transaction | transactional_data | Deferred Acquisition Cost transaction recording capitalized and amortized DAC amounts per policy. Tracks DAC asset balance, amortization schedule, and write-off events per US GAAP ASC 944 and IFRS 17. | 40 |
| premium_accounting | earned_premium | transactional_data | Tracks EP recognized over the policy exposure period via pro-rata or short-rate earning methods. Supports UEP calculation, GAAP revenue recognition, and IFRS 17 premium allocation approach. | 43 |
| premium_accounting | premium_transaction | transactional_data | Atomic premium ledger entry and single SSOT for every premium movement: new business, endorsement AP/RP, cancellation, reinstatement, audit, return premium, refund disbursement, and write-off. | 46 |
| premium_accounting | surplus_lines_tax | transactional_data | Surplus lines tax and stamping fee record per non-admitted policy. Captures state-specific tax rates, stamping office fees, diligent search requirements, and remittance due dates per state DOI surplus lines regulations. | 41 |
| premium_accounting | written_premium | transactional_data | SSOT for gross written premium (GWP) transactions per policy term. Captures WP, NWP, ceded premium, and net retained amounts at policy/coverage level. Anchors the premium ledger for statutory and GAAP reporting. | 45 |
| rating_calculation | minimum_earned_premium | master_data | Defines the minimum earned premium (MEP) threshold per policy or coverage. Enforces MEP on short-rate cancellations and ensures minimum retained premium per regulatory and contractual requirements. | 27 |
| rating_calculation | premium_rate_filing | master_data | Tracks state rate and rule filing submissions to DOI: filing number, LOB, effective date, approval status, SERFF tracking number, and rate change percentage. SSOT for regulatory rate approval lifecycle. | 40 |
| rating_calculation | rate_element | master_data | Master catalog of individual rating factors and their values used in premium computation: base rates, class factors, territory multipliers, schedule credits/debits, and ISO RPP elements. SSOT for rate content. | 44 |
| rating_calculation | rate_table | master_data | Versioned rate table and single SSOT for all rate content: base rates, class/territory factors, schedule credits/debits, and ISO RPP elements, held as rows grouped by LOB, state, effective date, and filing across multi-tier plans. | 42 |
| rating_calculation | rating_worksheet | transactional_data | Step-by-step premium calculation audit trail for a quoted or bound risk. Captures each rating step, applied factor, intermediate result, and final charged premium. Supports UW review and rate adequacy audits. | 45 |

<a id="domain-producers"></a>

### Domain: Producers

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| producers | business | 2 | Provisional description for user-specified domain 'producers'. Awaiting a generated description of what this domain owns. | 17 |

**Subdomains:** agent_management, compensation_processing


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| agent_management | agency | master_data | Master record for an agency or brokerage firm through which producers operate. Captures agency name, FEIN, DBA, principal address, agency type, and E&O coverage details. | 44 |
| agent_management | agency_producer | association_data | Junction table associating producers to agencies, capturing role, start/end dates, and whether the producer is the principal or sub-agent within the agency hierarchy. | 40 |
| agent_management | appointment | master_data | Formal carrier appointment authorizing a producer to sell specific LOBs in a given state on behalf of Pc_Insurance. Tracks appointment status, effective/expiration dates, and DOI filing reference. | 38 |
| agent_management | authority_territory | association_data | Represents the delegated binding authority granted to a producer within a specific state jurisdiction. Captures state-specific limits, effective dates, and regulatory compliance requirements for each producer-state combination.. | 12 |
| agent_management | binding_authority | master_data | Delegated binding authority granted to a producer or MGA specifying maximum policy limit, eligible LOBs, geographic territory, and risk class restrictions. Tracks authority ceiling, expiration, and suspension flags. | 48 |
| agent_management | eno_policy | master_data | Errors and Omissions (E&O) insurance policy held by a producer or agency. Tracks insurer, policy number, coverage limit, effective/expiration dates, and compliance status required for appointment. | 40 |
| agent_management | onboarding_case | transactional_data | Single authoritative producer onboarding and compliance case covering application intake, background check, license verification, DOI disciplinary and market-conduct review, and OFAC/sanctions screening through appointment filing and system activation. | 45 |
| agent_management | producer_agreement | master_data | Contractual producer agreement between Pc_Insurance and a producer or agency defining compensation terms, binding authority, LOB scope, territory, and compliance obligations. Tracks version, effective dates, and signatory. | 45 |
| agent_management | producer_compliance | master_data | Compliance and onboarding case for a producer tracking background check, license verification, DOI disciplinary orders, market conduct findings, and OFAC/sanctions screening status through activation. | 44 |
| agent_management | producer_license | master_data | State-issued insurance license held by a producer, including license number, line of authority (LOB), state jurisdiction, issue date, expiration date, and current status per DOI records. | 41 |
| agent_management | producers_producer | master_data | SSOT master for every licensed insurance producer (agent or broker) appointed by the carrier. Owns producer identity, NPN, FEIN/SSN, entity type, and active status across all lines of business. | 45 |
| agent_management | termination | transactional_data | Records the termination or non-renewal of a producer appointment or agreement, including termination reason code, for-cause flag, effective date, state notification requirement, and regulatory reporting status. | 43 |
| agent_management | territory | reference_data | Geographic territory assigned to a producer or agency by state, county, and ZIP-code range with LOB scope. Supports territory management, conflict resolution, and production roll-up. | 43 |
| compensation_processing | commission_schedule | reference_data | Reference schedule defining base commission rates, contingent bonus tiers, and override percentages by LOB, policy transaction type (NB, REN), and producer tier. SSOT for commission rate configuration. | 43 |
| compensation_processing | commission_statement | transactional_data | Periodic statement issued to a producer or agency summarizing commission transactions within a settlement period. FKs to producer. Tracks statement date, total earned, adjustments, net payable, and payment reference. | 44 |
| compensation_processing | commission_transaction | transactional_data | Individual commission earned or adjusted for a producer on a specific policy transaction. FKs to producer, commission_schedule, and commission_statement. Captures GWP basis, rate, earned amount, type (NB, REN, ENDT, CANC), and payment status. | 47 |
| compensation_processing | contingent_bonus | transactional_data | Contingent or profit-sharing bonus calculated for a producer or agency based on loss ratio, premium volume, and growth targets over a measurement period. Tracks earned amount, LR threshold, and payment status. | 44 |

<a id="domain-reservespayments"></a>

### Domain: Reservespayments

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| reservespayments | business | 3 | Provisional description for user-specified domain 'reserves_payments'. Awaiting a generated description of what this domain owns. | 20 |

**Subdomains:** payment_processing, recovery_operations, reserve_management


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| payment_processing | lae_allocation | transactional_data | Allocates LAE (ALAE and ULAE) costs to individual claims or claim groups. Captures expense category, allocated amount, allocation method, and period. Supports combined ratio (CR) and expense ratio (ER) reporting. | 47 |
| payment_processing | payee | master_data | Master record of all parties eligible to receive loss payments: claimants, attorneys, medical providers, repair vendors, and mortgagees. Stores payee type, tax ID (SSN/FEIN), banking details, and 1099 reporting flag. | 47 |
| payment_processing | payment_approval | transactional_data | Workflow record for payment requests requiring supervisory or management approval above adjuster authority. Tracks requested amount, approver, approval date, approval status, and override justification. | 45 |
| payment_processing | payment_authority | master_data | Defines payment authority limits by adjuster role, LOB, and coverage type. Stores approval threshold, escalation path, effective date, and delegated authority level. Governs payment approval workflow in ClaimCenter. | 44 |
| payment_processing | payment_transaction | transactional_data | Master record of every outbound loss payment issued (check, EFT, wire). Tracks payee, payment method, gross amount, void/reissue status, bank clearing date, and GL posting reference. Source: ClaimCenter / Oracle AP. | 48 |
| payment_processing | reservespayments_claim_payment | association_data | Junction table for the many-to-many relationship between claims and payments. Captures payment allocation per claim, coverage part, payment type (indemnity, ALAE, MedPay, PIP), and net-of-recovery amount. | 45 |
| payment_processing | structured_settlement | master_data | Records periodic-payment structured settlement agreements that replace lump-sum indemnity. Captures annuity provider, present value, payment schedule, guarantee period, and assignment to a qualified assignment company. | 45 |
| recovery_operations | recovery_transaction | transactional_data | Records all inbound recoveries against paid losses: subrogation (SubroFT), salvage, reinsurance recoverable, and second-injury fund. Tracks recovery type, gross recovery, net recovery, and collection status. | 51 |
| recovery_operations | reinsurance_recoverable | master_data | Tracks amounts recoverable from reinsurers on paid and reserved losses under treaty and facultative (FAC) agreements. Records cession reference, gross loss, RI share, collected amount, and collectability status. | 49 |
| recovery_operations | salvage_item | master_data | Tracks physical salvage property taken title to after a total-loss settlement. Records ACV at loss, salvage proceeds, disposal method (auction, scrap), and net salvage recovery credited back to the claim. | 47 |
| recovery_operations | subrogation_case | master_data | Master record for a subrogation pursuit against a liable third party. Tracks demand amount, collected amount, attorney assignment, statute of limitations date, settlement status, and net recovery after expenses. | 47 |
| reserve_management | actuarial_analyst | master_data | Master reference table for actuarial_analyst. Referenced by actuarial_analyst_id. | 31 |
| reserve_management | cat_event | master_data | Catastrophe event master: CAT code (ISO/PCS), event name, peril type, affected states/counties, open/close dates, industry loss estimate, and PML tier. SSOT for CAT claim aggregation and CAT XL triggering. | 40 |
| reserve_management | development_triangle | master_data | Stores loss development triangle data by LOB, accident year, and development age. Captures cumulative paid loss, cumulative incurred loss, and earned premium for each evaluation period. Source: Milliman Arius / WTW ResQ. | 46 |
| reserve_management | ibnr_estimate | master_data | Actuarial bulk-reserve SSOT for IBNR, IBNER, and unallocated ULAE positions by LOB, accident year, and evaluation date, with optional CAT-code tagging. | 46 |
| reserve_management | reserve_evaluation | transactional_data | Periodic actuarial reserve evaluation SSOT (quarterly/annual): gross and net reserve positions, ULR/loss ratio, embedded loss development triangles, actuarial opinion reference, and NAIC Schedule P / state DOI statutory exhibits, signed off for statutory | 44 |
| reserve_management | reserve_study | master_data | Master reference table for reserve_study. Referenced by reserve_study_id. | 42 |
| reserve_management | reservespayments_loss_reserve | master_data | SSOT for case reserves (OCR) established per claim. Tracks initial reserve, current reserve, IBNR allocation, IBNER adjustments, ALAE/ULAE splits, and reserve adequacy status per line of business. | 49 |
| reserve_management | reservespayments_reserve_transaction | transactional_data | Transactional ledger of every reserve movement (set, increase, decrease, close) against a loss reserve. Captures transaction date, amount delta, reserve type (loss vs ALAE), and authorizing adjuster. | 43 |
| reserve_management | stat_reserve_exhibit | transactional_data | Statutory reserve exhibit prepared for NAIC Annual Statement Schedule P and state DOI filings. Captures net and gross reserve positions, loss ratio, and actuarial opinion reference by LOB and accident year. | 47 |

<a id="domain-riskexposure"></a>

### Domain: Riskexposure

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| riskexposure | business | 3 | Provisional description for user-specified domain 'risk_exposure'. Awaiting a generated description of what this domain owns. | 24 |

**Subdomains:** asset_inventory, peril_assessment, underwriting_intelligence


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| asset_inventory | driver_assignment | association_data | Junction table assigning a driver (insured entity) to an insured vehicle on a policy. Captures principal vs. occasional driver designation, assignment effective date, and usage percentage. Supports auto rating and UW. | 35 |
| asset_inventory | gl_operation | master_data | General Liability operations record describing the business activities of a commercial insured risk unit. Stores ISO GL class code, operation description, receipts, area, payroll, and products-completed operations split. | 39 |
| asset_inventory | insured_entity | master_data | Master record for a named insured party (individual, household, or commercial entity) tied to a risk exposure. Captures legal name, FEIN or SSN, NAICS/SIC code, DBA, entity type, and underwriting tier. | 36 |
| asset_inventory | insured_location | master_data | Master SSOT for a physical premises or location insured under a P&C policy. Captures address, COPE attributes, occupancy, TIV, protection class, and geocode. | 46 |
| asset_inventory | insured_vehicle | master_data | Master SSOT for a motor vehicle insured under a personal or commercial auto policy. Stores VIN, year, make, model, body type, garaging address, usage, and symbol. | 43 |
| asset_inventory | risk_unit | master_data | Atomic unit of insurable risk on a policy (building, vehicle, employee class, or GL operation). Single SSOT for rated exposure quantity, SI, TIV, exposure base, payroll, and LOB risk characteristics. Anchors the policy-coverage-exposure FK lineage. | 43 |
| asset_inventory | scheduled_equipment | master_data | Scheduled inland marine or equipment floater item record. Captures equipment type, serial number, year, ACV, RCV, location, and blanket vs. specific coverage designation. Used for CPP and BOP equipment scheduling. | 45 |
| asset_inventory | scheduled_item | master_data | Individually scheduled personal or commercial property items (jewelry, fine art, equipment, tools). Stores item description, agreed value, appraisal date, serial number, and blanket vs scheduled coverage flag. | 46 |
| asset_inventory | tiv_schedule | master_data | Schedule of Total Insured Values for a commercial property or inland marine risk. Each row represents one scheduled item (building, contents, equipment) with its SI, RCV, ACV, and depreciation basis. | 43 |
| asset_inventory | wc_payroll_class | master_data | Master SSOT linking an employer risk unit to an NCCI or state WC classification code with payroll basis, rate, and manual premium. | 40 |
| peril_assessment | cat_zone | reference_data | Reference for catastrophe peril zones (hurricane, quake, flood, wildfire, hail) mapped to geography. Stores PML tier, CAT loading, FEMA/NFIP flood zone code, BFE, FIRM panel, and mandatory-purchase indicator for flood compliance. | 34 |
| peril_assessment | experience_mod | transactional_data | Experience modification factor (EMod) record for a WC or GL insured, including WC payroll classification linkage. Stores NCCI or state bureau EMod value, effective date, interstate designation, primary and excess loss components, and history. | 44 |
| peril_assessment | exposure_period | transactional_data | Tracks the effective date range during which a risk unit is on-risk within a policy term. Captures written exposure, earned exposure, and mid-term changes due to endorsements, cancellations, or reinstatements. | 43 |
| peril_assessment | flood_zone_assignment | transactional_data | FEMA/NFIP flood zone designation assigned to an insured location. Stores flood zone code, BFE (Base Flood Elevation), FIRM panel number, determination date, and mandatory purchase indicator for mortgage compliance. | 42 |
| peril_assessment | pml_estimate | transactional_data | Probable Maximum Loss estimate for a property or CAT-exposed risk unit. Stores PML percentage, scenario (1-in-100, 1-in-250), peril, model vendor (AIR, RMS, CoreLogic), run date, and gross vs. net of reinsurance values. | 38 |
| peril_assessment | risk_change_event | transactional_data | Transactional record of a mid-term change to a risk unit (e.g., location added, vehicle replaced, payroll updated, construction upgrade). Captures change type, effective date, prior and new values, and triggering endorsement. | 42 |
| peril_assessment | risk_characteristic | master_data | Stores LOB-specific underwriting characteristics for a risk unit (e.g., roof age, alarm type, sprinkler system, driver age, MVR points, years in business). Each row is one characteristic name-value pair per risk unit. | 40 |
| peril_assessment | risk_score | transactional_data | Underwriting risk score record for a risk unit derived from third-party models (ISO FireLine, Verisk Wildfire, LexisNexis, credit-based insurance score). Stores score value, model version, pull date, and score tier. | 44 |
| peril_assessment | sir_retention | master_data | Self-Insured Retention or large deductible program record for a commercial risk. Stores SIR amount, aggregate limit, collateral type, collateral amount, loss fund, and program administrator. Links to the risk unit and policy. | 41 |
| underwriting_intelligence | clue_report | transactional_data | Comprehensive Loss Underwriting Exchange (CLUE) property or auto loss history report for an insured entity or vehicle. Captures report date, prior carrier, prior losses, and CLUE score used in UW risk selection. | 41 |
| underwriting_intelligence | location_claimant_interest | association_data | Association between insured locations and claimants capturing property interest, loss exposure allocation, and claimant role at specific premises. Supports multi-party claims where multiple claimants assert interest in a single location or a claimant has | 10 |
| underwriting_intelligence | mvr_report | transactional_data | Motor Vehicle Report obtained for a driver risk unit. Stores pull date, license state, license number, violation count, accident count, MVR score, and source (CLUE Auto / state DMV). Used in personal and commercial auto UW. | 38 |
| underwriting_intelligence | uw_survey | transactional_data | Underwriting field survey or inspection record for a risk unit. Captures survey date, inspector, findings, recommended improvements, UW action (accept, decline, refer), and survey source (internal, ISO, third-party). | 47 |
| underwriting_intelligence | vehicle_claimant_involvement | association_data | Association representing the involvement of a claimant with a specific insured vehicle in a claim event. Captures driver status, occupant position, fault allocation, and injury details specific to the vehicle-claimant relationship.. | 10 |

<a id="domain-shared"></a>

### Domain: Shared

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| shared | corporate | 2 | Cross-domain shared reference entities (currency, UoM, calendar, classification) consolidated for Single Source of Truth (SSOT). | 8 |

**Subdomains:** master_entities, reference_catalogs


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| master_entities | party | master_data | Master reference table for party. Referenced by assigned_to_party_id. | 43 |
| master_entities | user_account | master_data | Master reference table for user_account. Referenced by generated_by_user_id. | 34 |
| reference_catalogs | calendar | reference_data | Reference calendar of fiscal periods, accident years, and accounting months used for premium earning, reserve evaluation, and statutory reporting cadence. | 38 |
| reference_catalogs | country | reference_data | Reference catalog of ISO 3166 country codes used for addresses, reinsurers, and party identification. Stores alpha-2, alpha-3, numeric code, and name. | 25 |
| reference_catalogs | currency | reference_data | Reference catalog of ISO 4217 currency codes used across premium, claims, reserve, and reinsurance monetary amounts. Stores code, name, minor unit, and active flag. | 18 |
| reference_catalogs | lob_code | reference_data | Reference catalog of lines of business and NAIC line codes (GL, CGL, BOP, WC, APD, PIP) used consistently across policy, coverage, premium, claims, and reserves. | 34 |
| reference_catalogs | org_unit | reference_data | Reference hierarchy of internal organizational units (branch, region, business unit, cost center) used to attribute policies, claims, and financial transactions. | 31 |
| reference_catalogs | state | reference_data | Reference catalog of US states and territories used for filings, licensing, garaging, and jurisdiction. Stores FIPS code, postal abbreviation, DOI reference, and region. | 34 |

## Metric Views

Total metric views generated: **120**. Showing top 20.

| # | View Name | Domain | Source Table | Description |
|---|---|---|---|---|
| 1 | reinsurance_bordereaux | reinsurance | bordereaux | Reinsurance bordereaux reporting metrics including premium and loss reporting performance, submission timeliness, and bordereaux accuracy for reinsurer relationship management. |
| 2 | reinsurance_ceded_premium_transaction | reinsurance | ceded_premium_transaction | Reinsurance premium transaction metrics including ceded premium flows, ceding commissions, and settlement performance for cash flow management and reinsurer accounting. |
| 3 | reinsurance_cession | reinsurance | reinsurance_cession | Granular reinsurance cession performance metrics including premium ceded, loss recoveries, and ceding commission economics for individual risk and treaty cession analysis. |
| 4 | reinsurance_claim_ri_recovery | reinsurance | claim_ri_recovery | Reinsurance claim recovery metrics including recoverable amounts, collection performance, and dispute resolution for measuring reinsurance program effectiveness and credit risk. |
| 5 | reinsurance_profit_commission | reinsurance | profit_commission | Reinsurance profit commission metrics including commission calculations, loss ratio performance, and sliding scale analysis for measuring treaty profitability and reinsurer alignment. |
| 6 | reinsurance_ri_recoverable | reinsurance | ri_recoverable | Reinsurance recoverable aging and credit risk metrics including outstanding balances, collection performance, and write-off analysis for managing reinsurer credit exposure. |
| 7 | reinsurance_ri_treaty | reinsurance | ri_treaty | Strategic reinsurance treaty performance metrics including capacity utilization, rate adequacy, and program efficiency for treaty portfolio management and renewal decisions. |
| 8 | claims_adjuster | claims | adjuster | Adjuster business metrics |
| 9 | claims_adjuster_assignment | claims | adjuster_assignment | Adjuster Assignment business metrics |
| 10 | claims_attorney | claims | attorney | Attorney business metrics |
| 11 | claims_claim | claims | claim | Claim business metrics |
| 12 | claims_claim_coverage | claims | claim_coverage | Claim Coverage business metrics |
| 13 | claims_claim_document | claims | claim_document | Claim Document business metrics |
| 14 | claims_claim_note | claims | claim_note | Claim Note business metrics |
| 15 | claims_claim_peril_causation | claims | claim_peril_causation | Claim Peril Causation business metrics |
| 16 | claims_claim_status_history | claims | claim_status_history | Claim Status History business metrics |
| 17 | claims_claimant | claims | claimant | Claimant business metrics |
| 18 | claims_claims_claim_payment | claims | claims_claim_payment | Claims Claim Payment business metrics |
| 19 | claims_claims_loss_reserve | claims | claims_loss_reserve | Claims Loss Reserve business metrics |
| 20 | claims_claims_reserve_transaction | claims | claims_reserve_transaction | Claims Reserve Transaction business metrics |

*... and 100 more metric views. See the `metrics/` folder for full details.*