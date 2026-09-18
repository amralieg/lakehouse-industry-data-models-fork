-- Schema for Domain: reservespayments | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-18 02:30:18

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_v499`.`reservespayments` COMMENT 'Provisional description for user-specified domain reserves_payments. Awaiting a generated description of what this domain owns.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` (
    `reservespayments_loss_reserve_id` BIGINT COMMENT 'Unique surrogate identifier for each loss reserve record. Primary key for the reservespayments_loss_reserve product.',
    `adjuster_id` BIGINT COMMENT 'Reference to the claims adjuster responsible for setting and maintaining the case reserve. Links to the adjuster/party master.',
    `cat_event_id` BIGINT COMMENT 'Foreign key linking to reservespayments.cat_event. Business justification: Loss reserves for CAT events need proper FK linkage to cat_event master. The cat_event_code string becomes redundant when FK allows JOIN.',
    `claim_coverage_id` BIGINT COMMENT 'Foreign key linking to claims.claim_coverage. Business justification: Reserve establishment in P&C is coverage-specific (BI reserve vs PD reserve). Adjusters set reserves at coverage level for Schedule P reporting, reinsurance allocation, and coverage',
    `claim_id` BIGINT COMMENT 'Reference to the claim for which this loss reserve is established. Links reserve to the originating claim event.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Reserve amounts in multi-currency operations require proper currency reference for financial consolidation, statutory reporting, and FX risk management.',
    `insured_entity_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_entity. Business justification: Entity-level reserve aggregation is required for experience rating, loss runs, large deductible programs, retrospective rating plans, and renewal underwriting decisions across all',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Loss reserves for property claims must link to specific locations for actuarial analysis, cat modeling, territorial rate adequacy studies, and Schedule P reporting by location',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Auto physical damage reserves require vehicle linkage for total loss determination, salvage valuation, subrogation demand calculation, and vehicle-level loss history for renewal',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Loss reserves must be classified by LOB for statutory reporting, rate adequacy analysis, reinsurance treaty application, and management reporting. Lob_code denormalizes LOB master.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Reference to the specific coverage part under which the loss reserve is held, enabling per-coverage reserve tracking.',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which the claim and reserve are established. Supports LOB segmentation and reserve adequacy analysis.',
    `risk_unit_id` BIGINT COMMENT 'Foreign key linking to riskexposure.risk_unit. Business justification: Reserves are established and tracked at the risk unit level to calculate accurate loss ratios, support rate adequacy analysis, and enable granular actuarial segmentation by class and',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Loss reserves must track jurisdictional state for statutory reporting, guaranty fund assessments, Schedule P filings, and state-specific reserve adequacy analysis.',
    `accident_year` BIGINT COMMENT 'Calendar year in which the loss event (Date of Loss) occurred. Primary dimension for loss development triangles and actuarial analysis.',
    `actuarial_segment_code` STRING COMMENT 'Code identifying the actuarial homogeneous risk segment to which this reserve belongs for loss development triangle construction.',
    `alae_reserve_amount` DECIMAL(18,2) COMMENT 'Reserve for Allocated Loss Adjustment Expenses (ALAE) directly attributable to this claim, such as defense and cost containment expenses.',
    `cat_event_indicator` BOOLEAN COMMENT 'Indicates whether this reserve is associated with a declared catastrophe (CAT) event. Enables CAT loss aggregation and PML reporting.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this loss reserve record was first created in the system. Audit trail for reserve establishment and data lineage.',
    `current_reserve_amount` DECIMAL(18,2) COMMENT 'Current gross Outstanding Case Reserve (OCR) balance as of the valuation date, reflecting all adjustments since establishment.',
    `date_of_loss` DATE COMMENT 'Date on which the insured loss event occurred. Foundational field for accident-year segmentation and coverage trigger determination.',
    `ibner_amount` DECIMAL(18,2) COMMENT 'Reserve for development on known claims where current case reserves are estimated to be inadequate (IBNER). Supplements OCR.',
    `ibnr_amount` DECIMAL(18,2) COMMENT 'Actuarially estimated reserve for claims Incurred But Not Reported (IBNR) as of the valuation date. Allocated at LOB or segment level.',
    `incurred_loss_amount` DECIMAL(18,2) COMMENT 'Total incurred loss = paid losses to date + current case reserve. Fundamental metric for loss ratio and reserve adequacy analysis.',
    `initial_reserve_amount` DECIMAL(18,2) COMMENT 'Gross case reserve amount set at the time the reserve was first established. Baseline for reserve development and adequacy tracking.',
    `large_loss_indicator` BOOLEAN COMMENT 'Flags reserves exceeding the company-defined large loss threshold. Triggers enhanced management review and reinsurance notification.',
    `large_loss_threshold_amount` DECIMAL(18,2) COMMENT 'Dollar threshold above which a reserve is classified as a large loss. Defined per LOB or treaty and used to trigger escalation workflows.',
    `last_reserve_change_date` DATE COMMENT 'Date of the most recent reserve adjustment. Supports reserve development tracking and adjuster activity monitoring.',
    `litigation_indicator` BOOLEAN COMMENT 'Indicates whether the claim associated with this reserve is in active litigation. Litigation claims typically carry higher ALAE reserves.',
    `net_reserve_amount` DECIMAL(18,2) COMMENT 'Net reserve after deducting reinsurance recoverables, salvage, and subrogation from gross reserve. Represents retained risk exposure.',
    `paid_alae_to_date` DECIMAL(18,2) COMMENT 'Cumulative ALAE payments made to date for this claim. Combined with paid losses to compute total incurred including LAE.',
    `paid_losses_to_date` DECIMAL(18,2) COMMENT 'Cumulative gross loss payments made against this claim as of the valuation date. Used to compute incurred losses and reserve development.',
    `policy_year` BIGINT COMMENT 'Year in which the policy that generated the claim was written or incepted. Used for policy-year loss development analysis.',
    `reinsurance_recoverable_amount` DECIMAL(18,2) COMMENT 'Estimated reinsurance recoverable on unpaid losses ceded under treaty or facultative (FAC) arrangements as of the valuation date.',
    `report_year` BIGINT COMMENT 'Calendar year in which the claim was first reported to the insurer (FNOL year). Used for report-year development triangles.',
    `reserve_adequacy_status` STRING COMMENT 'Actuarial or adjuster assessment of whether the current reserve is adequate, deficient, or redundant relative to ultimate loss estimate.. Valid values are `adequate|deficient|redundant|under_review`',
    `reserve_change_reason` STRING COMMENT 'Narrative or coded reason for the most recent reserve adjustment (e.g., new medical information, litigation update, coverage determination). [ENUM-REF-CANDIDATE: promote to reference product]',
    `reserve_closed_date` DATE COMMENT 'Date the reserve was closed or released to zero. Null if reserve remains open. Used for reserve development and closure analysis.',
    `reserve_established_date` DATE COMMENT 'Date the initial case reserve was first established following FNOL or claim adjudication. Principal business event date for the reserve lifecycle.',
    `reserve_method` STRING COMMENT 'Method used to establish or develop the reserve: case-by-case adjuster estimate, formula-based, actuarial bulk, or tabular method.. Valid values are `case_basis|formula|actuarial|bulk|tabular`',
    `reserve_number` STRING COMMENT 'Externally-known business identifier for the reserve record, used in bordereaux, actuarial reports, and statutory filings.. Valid values are `^RES-[0-9]{4}-[0-9]{8}$`',
    `reserve_status` STRING COMMENT 'Current lifecycle state of the loss reserve record. Drives reserve adequacy monitoring and statutory reporting workflows.. Valid values are `open|closed|reopened|pending_closure|transferred`',
    `reserve_type` STRING COMMENT 'Classification of the reserve: Outstanding Case Reserve (OCR), IBNR, IBNER, ALAE, ULAE, salvage, or subrogation. [ENUM-REF-CANDIDATE: case|ibnr|ibner|ulae|alae|salvage|subrogation — promote to reference product]',
    `salvage_reserve_amount` DECIMAL(18,2) COMMENT 'Estimated recoverable amount from salvage of damaged property. Offsets gross reserve for net reserve reporting.',
    `stat_line_code` STRING COMMENT 'NAIC statutory line of business code used for Schedule P and other statutory filings. Maps to NAIC Annual Statement line definitions.',
    `subrogation_reserve_amount` DECIMAL(18,2) COMMENT 'Estimated recoverable amount through subrogation rights against liable third parties. Reduces net reserve and improves loss ratio.',
    `ulae_reserve_amount` DECIMAL(18,2) COMMENT 'Reserve for Unallocated Loss Adjustment Expenses (ULAE) not directly tied to a specific claim, allocated proportionally from company-wide estimates.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this loss reserve record. Supports incremental data loading and audit trail requirements.',
    `valuation_date` DATE COMMENT 'Accounting period end date as of which the reserve balance is measured. Aligns with statutory and GAAP reporting periods.',
    CONSTRAINT pk_reservespayments_loss_reserve PRIMARY KEY(`reservespayments_loss_reserve_id`)
) COMMENT 'SSOT for case reserves (OCR) established per claim. Tracks initial reserve, current reserve, IBNR allocation, IBNER adjustments, ALAE/ULAE splits, and reserve adequacy status per line of business.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` (
    `reservespayments_reserve_transaction_id` BIGINT COMMENT 'Unique surrogate identifier for each reserve transaction record in the loss reserve ledger.',
    `adjuster_id` BIGINT COMMENT 'Reference to the claims adjuster who authorized or initiated this reserve transaction.',
    `cat_event_id` BIGINT COMMENT 'Foreign key linking to reservespayments.cat_event. Business justification: Reserve transactions for CAT events need proper FK linkage to cat_event master. The cat_code string becomes redundant when FK allows JOIN.',
    `claim_id` BIGINT COMMENT 'Reference to the claim against which this reserve transaction is posted.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Reserve transaction amounts require currency reference for GL posting, multi-currency accounting, and financial reporting. Replaces denormalized currency_code with proper FK.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Reserve development transactions must link to locations for cat event analysis, territorial loss trend monitoring, and location-specific reserve adequacy reviews required for',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Reserve transactions require LOB classification for GL posting, statutory reporting, and management analysis. Lob_code denormalizes LOB master data.',
    `reservespayments_loss_reserve_id` BIGINT COMMENT 'Reference to the parent loss reserve record that this transaction adjusts.',
    `reversed_transaction_reservespayments_reserve_transaction_id` BIGINT COMMENT 'Reference to the original reserve transaction that this entry reverses, enabling full audit chain reconstruction.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Reserve transactions require state reference for GL allocation, statutory reporting by jurisdiction, and state-specific accounting rules. State_code denormalizes state master.',
    `accident_year` BIGINT COMMENT 'The calendar year in which the loss event occurred, used for actuarial loss development triangles and IBNR estimation.',
    `authorization_date` DATE COMMENT 'The date on which the reserve transaction was formally authorized by the approving authority.',
    `authorization_level` STRING COMMENT 'The authority level required and applied to approve this reserve transaction per the insurers reserve authority matrix.. Valid values are `ADJUSTER|SUPERVISOR|MANAGER|DIRECTOR|EXECUTIVE`',
    `claim_office_code` STRING COMMENT 'Internal code identifying the claims handling office or unit responsible for managing the claim associated with this reserve.',
    `cost_center_code` STRING COMMENT 'Financial cost center to which this reserve transaction is allocated for management accounting and expense reporting.',
    `coverage_type` STRING COMMENT 'The specific coverage component to which this reserve applies (e.g., BI, PD, UM, UIM, PIP, MedPay, ALAE). [ENUM-REF-CANDIDATE: BI|PD|UM|UIM|PIP|MedPay|ALAE|GL|APD — promote to reference product]',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this reserve transaction record was first created in the system, used for audit trail and data lineage.',
    `date_of_loss` DATE COMMENT 'The Date of Loss (DOL) for the underlying claim, used for accident-year actuarial development triangles.',
    `delta_amount` DECIMAL(18,2) COMMENT 'The signed change in reserve amount for this transaction. Positive values indicate an increase; negative values indicate a decrease or release.',
    `effective_date` DATE COMMENT 'The accounting effective date for this reserve movement, which may differ from transaction date for period-end adjustments.',
    `gl_account_code` STRING COMMENT 'The General Ledger (GL) account code to which this reserve transaction is posted in the financial ledger.',
    `is_cat_event` BOOLEAN COMMENT 'Indicates whether this reserve transaction is associated with a declared Catastrophe (CAT) event, enabling CAT-specific reserve aggregation.',
    `net_reserve_delta` DECIMAL(18,2) COMMENT 'Reserve delta net of reinsurance recoverables, representing the insurers retained exposure change for this transaction.',
    `policy_number` STRING COMMENT 'The policy number under which the claim and reserve are recorded, supporting statutory reporting by policy.',
    `policy_year` BIGINT COMMENT 'The year in which the policy was written, used for policy-year actuarial development and statutory reporting.',
    `reinsurance_recoverable_amount` DECIMAL(18,2) COMMENT 'The portion of this reserve delta expected to be recovered from reinsurers under treaty or facultative (FAC) arrangements.',
    `report_year` BIGINT COMMENT 'The calendar year in which the claim was first reported to the insurer, used for report-year actuarial triangles.',
    `reserve_amount_after` DECIMAL(18,2) COMMENT 'Outstanding Case Reserve (OCR) balance immediately after this transaction is applied, representing the current reserve position.',
    `reserve_amount_before` DECIMAL(18,2) COMMENT 'Outstanding Case Reserve (OCR) balance immediately prior to this transaction, enabling point-in-time reserve reconstruction.',
    `reserve_close_date` DATE COMMENT 'The date on which the reserve was closed to zero, populated only for CLOSE transaction types. Null for all other transaction types.',
    `reserve_type` STRING COMMENT 'Categorizes the reserve component: Loss (indemnity), Allocated Loss Adjustment Expense (ALAE), Unallocated LAE (ULAE), Incurred But Not Reported (IBNR), or IBNER. [ENUM-REF-CANDIDATE: LOSS|ALAE|ULAE|IBNR|IBNER|SUBROGATION — promote to reference product]. Valid values are `LOSS|ALAE|ULAE|IBNR|IBNER|SUBROGATION`',
    `reversal_indicator` BOOLEAN COMMENT 'Indicates whether this transaction is a reversal of a previously posted reserve entry, used for audit and reconciliation.',
    `source_system_code` STRING COMMENT 'Identifies the operational system of record that originated this reserve transaction (e.g., Guidewire ClaimCenter, Duck Creek, Milliman Arius).. Valid values are `GUIDEWIRE|DUCK_CREEK|SAPIENS|ARIUS|RESQ|MANUAL`',
    `source_transaction_ref` STRING COMMENT 'The native transaction identifier from the originating system of record, enabling traceability back to the source.',
    `stat_line_code` STRING COMMENT 'NAIC statutory line of business code used for Annual Statement Schedule P and Schedule F reserve reporting.',
    `transaction_date` DATE COMMENT 'The business date on which the reserve movement was recorded, used for period-end reserve reporting and actuarial triangles.',
    `transaction_number` STRING COMMENT 'Externally visible business identifier for this reserve transaction, used in bordereaux and statutory reporting.. Valid values are `^RT-[0-9]{10}$`',
    `transaction_reason_code` STRING COMMENT 'Coded reason for the reserve movement (e.g., new information, litigation update, settlement negotiation, CAT event). [ENUM-REF-CANDIDATE: NEW_INFO|LITIGATION|SETTLEMENT|CAT|COVERAGE_CHANGE|SUBROGATION|AUDIT — promote to reference product]',
    `transaction_reason_notes` STRING COMMENT 'Free-text narrative provided by the adjuster explaining the business rationale for this reserve movement.',
    `transaction_status` STRING COMMENT 'Current workflow state of the reserve transaction within the claims reserving system.. Valid values are `PENDING|POSTED|REVERSED|VOIDED`',
    `transaction_timestamp` TIMESTAMP COMMENT 'Precise date and time the reserve transaction was entered into the claims system, supporting audit trail and intraday reconciliation.',
    `transaction_type` STRING COMMENT 'Classifies the nature of the reserve movement: initial set, upward development, downward development, closure, or reopening.. Valid values are `SET|INCREASE|DECREASE|CLOSE|REOPEN`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this reserve transaction record, supporting audit trail and change tracking.',
    CONSTRAINT pk_reservespayments_reserve_transaction PRIMARY KEY(`reservespayments_reserve_transaction_id`)
) COMMENT 'Transactional ledger of every reserve movement (set, increase, decrease, close) against a loss reserve. Captures transaction date, amount delta, reserve type (loss vs ALAE), and authorizing adjuster.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` (
    `ibnr_estimate_id` BIGINT COMMENT 'Unique surrogate primary key for the IBNR estimate record. Role: TRANSACTION_HEADER.',
    `actuarial_analyst_id` BIGINT COMMENT 'Reference to the internal party record of the credentialed actuary or actuarial analyst responsible for preparing and signing off on this IBNR estimate.',
    `cat_event_id` BIGINT COMMENT 'Foreign key linking to reservespayments.cat_event. Business justification: IBNR estimates for catastrophe events need proper FK linkage to cat_event master. The cat_code string becomes redundant when FK allows JOIN to cat_event.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Actuarial IBNR estimates require currency specification for statutory reserve filings, actuarial opinions, and multi-currency consolidation. Currency_code is denormalized reference.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: IBNR estimates for property lines require location-level exposure data (TIV, construction type, cat zone) for actuarial projections and to support territorial reserve adequacy',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: IBNR estimates are calculated and reported by line of business for actuarial analysis, statutory filings, and reserve adequacy. Replaces lob_code denormalization.',
    `reserve_study_id` BIGINT COMMENT 'Reference to the actuarial reserve study or analysis run that produced this IBNR estimate.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: State-level IBNR estimates are required for Schedule P statutory filings, state rate adequacy analysis, and regulatory reserve requirements. State_code is denormalized.',
    `user_account_id` BIGINT COMMENT 'Reference to the internal party record of the Appointed Actuary or senior reviewer who approved this IBNR estimate for statutory filing or financial reporting.',
    `accident_year` BIGINT COMMENT 'The calendar year in which the insured loss events are deemed to have occurred, used as the primary actuarial development dimension for IBNR triangles.',
    `actuarial_method` STRING COMMENT 'Primary actuarial method used to derive this estimate (e.g., Chain Ladder, Bornhuetter-Ferguson, Cape Cod, Clark LDF, Frequency-Severity). [ENUM-REF-CANDIDATE',
    `actuarial_notes` STRING COMMENT 'Free-text field for actuarial commentary, methodology rationale, data anomalies, or qualitative judgments supporting the IBNR estimate, as required by ASOP No. 43.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the IBNR estimate was formally approved by the Appointed Actuary or designated reviewer, marking readiness for statutory filing.',
    `case_reserve_amount` DECIMAL(18,2) COMMENT 'Total outstanding case reserves held on open claims for the LOB and accident year as of the evaluation date, representing the known but unpaid loss liability.',
    `ceded_reserve_amount` DECIMAL(18,2) COMMENT 'Portion of the IBNR reserve ceded to reinsurers under applicable treaty and facultative agreements, equal to gross minus net reserve amounts.',
    `confidence_level` DECIMAL(5,2) COMMENT 'Statistical confidence level (as a percentage, e.g., 75.00 for 75th percentile) at which the IBNR estimate is stated, per actuarial range analysis or stochastic modeling.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this IBNR estimate record was first created in the data platform, used for audit trail and data lineage tracking.',
    `data_source_system` STRING COMMENT 'Name of the actuarial reserving or source system from which this IBNR estimate was extracted (e.g., Milliman Arius, Willis Towers Watson ResQ, Snowflake).',
    `development_age_months` BIGINT COMMENT 'Age of the accident year in months as of the evaluation date, representing the maturity point on the actuarial loss development triangle (e.g., 12, 24, 36, 48).',
    `earned_premium_amount` DECIMAL(18,2) COMMENT 'Gross earned premium for the LOB and accident year used as the denominator in loss ratio calculations and as the exposure base for actuarial methods.',
    `estimate_reference_number` STRING COMMENT 'Externally-known alphanumeric identifier for this actuarial bulk-reserve estimate, used in bordereaux, statutory filings, and actuarial reports.. Valid values are `^IBNR-[0-9]{4}-[A-Z0-9]{6,12}$`',
    `estimate_status` STRING COMMENT 'Current lifecycle state of the IBNR estimate record within the actuarial review and approval workflow.. Valid values are `DRAFT|UNDER_REVIEW|APPROVED|FILED|SUPERSEDED|VOIDED`',
    `evaluation_date` DATE COMMENT 'The as-of date through which loss data was compiled and the IBNR estimate was evaluated, typically a quarter-end or year-end statutory date.',
    `expected_loss_ratio` DECIMAL(8,5) COMMENT 'A priori expected loss ratio used as the initial expected loss assumption in Bornhuetter-Ferguson and Cape Cod actuarial methods for this LOB and accident year.',
    `filing_period` STRING COMMENT 'Statutory reporting period for which this IBNR estimate is prepared, formatted as Q1-YYYY, Q2-YYYY, Q3-YYYY, Q4-YYYY, or ANNUAL-YYYY.. Valid values are `^(Q[1-4]|ANNUAL)-[0-9]{4}$`',
    `high_estimate_amount` DECIMAL(18,2) COMMENT 'Upper bound of the actuarial range of reasonable IBNR estimates, typically corresponding to a higher confidence percentile or adverse scenario.',
    `ibner_amount` DECIMAL(18,2) COMMENT 'Actuarial IBNER reserve amount representing development on known open claims that are expected to develop beyond current case reserves as of the evaluation date.',
    `ibnr_amount` DECIMAL(18,2) COMMENT 'Gross actuarial IBNR reserve amount in the reporting currency, representing estimated ultimate losses for claims not yet reported as of the evaluation date.',
    `is_cat_estimate` BOOLEAN COMMENT 'Indicates whether this IBNR estimate is specifically associated with a catastrophe event. True when cat_code is populated and the estimate is CAT-segregated.',
    `ldf_selected` DECIMAL(10,6) COMMENT 'Actuarially selected cumulative loss development factor (tail factor) applied to reported or paid losses to project to ultimate for this accident year and evaluation age.',
    `lob_name` STRING COMMENT 'Human-readable name of the Line of Business corresponding to lob_code (e.g., Commercial General Liability, Workers Compensation, Auto Physical Damage).',
    `low_estimate_amount` DECIMAL(18,2) COMMENT 'Lower bound of the actuarial range of reasonable IBNR estimates, typically corresponding to a lower confidence percentile or optimistic scenario.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code identifying the legal insurance entity for which this IBNR estimate is reported in statutory filings.. Valid values are `^[0-9]{5}$`',
    `net_of_reinsurance_amount` DECIMAL(18,2) COMMENT 'IBNR reserve amount net of reinsurance recoveries, reflecting the retained liability after cession under quota share, XOL, and facultative treaties.',
    `paid_losses_amount` DECIMAL(18,2) COMMENT 'Cumulative loss payments made for the LOB and accident year as of the evaluation date, used as the paid loss diagonal in actuarial development triangles.',
    `percent_unreported` DECIMAL(8,5) COMMENT 'Estimated proportion of ultimate losses not yet reported as of the evaluation date, derived as 1 minus the inverse of the selected cumulative LDF.',
    `prior_period_reserve_amount` DECIMAL(18,2) COMMENT 'Total bulk reserve amount from the immediately preceding evaluation period for the same LOB and accident year, used to compute reserve development and redundancy/deficiency.',
    `reported_losses_amount` DECIMAL(18,2) COMMENT 'Cumulative paid losses plus outstanding case reserves (OCR) for the LOB and accident year as of the evaluation date, forming the reported diagonal of the loss triangle.',
    `reserve_development_amount` DECIMAL(18,2) COMMENT 'Change in total reserve from prior period to current evaluation date (current minus prior). Positive indicates adverse development; negative indicates favorable development.',
    `reserve_type` STRING COMMENT 'Classifies the actuarial bulk reserve component: IBNR (Incurred But Not Reported), IBNER (Incurred But Not Enough Reported), ULAE, ALAE, OCR, or TOTAL.. Valid values are `IBNR|IBNER|ULAE|ALAE|OCR|TOTAL`',
    `statutory_basis` STRING COMMENT 'Accounting basis under which this IBNR estimate is prepared: SAP (Statutory Accounting Principles), GAAP (US Generally Accepted Accounting Principles), or IFRS 17.. Valid values are `SAP|GAAP|IFRS17|STAT`',
    `total_reserve_amount` DECIMAL(18,2) COMMENT 'Sum of IBNR, IBNER, and ULAE reserve amounts representing the total actuarial bulk reserve position for this LOB, accident year, and evaluation date.',
    `ulae_amount` DECIMAL(18,2) COMMENT 'Actuarial bulk reserve for Unallocated Loss Adjustment Expenses not directly assignable to individual claims, estimated as a loading on IBNR and IBNER.',
    `ultimate_loss_amount` DECIMAL(18,2) COMMENT 'Actuarially projected ultimate incurred loss amount for the LOB and accident year, equal to reported losses plus IBNR plus IBNER.',
    `ultimate_loss_ratio` DECIMAL(8,5) COMMENT 'Actuarially estimated ultimate loss ratio for this LOB and accident year as of the evaluation date, computed as ultimate losses divided by earned premium.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this IBNR estimate record was last modified in the data platform, supporting audit trail, change tracking, and incremental load processing.',
    CONSTRAINT pk_ibnr_estimate PRIMARY KEY(`ibnr_estimate_id`)
) COMMENT 'Actuarial bulk-reserve SSOT for IBNR, IBNER, and unallocated ULAE positions by LOB, accident year, and evaluation date, with optional CAT-code tagging.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` (
    `reserve_evaluation_id` BIGINT COMMENT 'Unique surrogate identifier for each periodic actuarial reserve evaluation record. Primary key for the reserve_evaluation data product in the reservespayments domain.',
    `cat_event_id` BIGINT COMMENT 'Foreign key linking to reservespayments.cat_event. Business justification: Reserve evaluations for CAT events need proper FK linkage to cat_event master. The cat_event_code string becomes redundant when FK allows JOIN.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Reserve evaluations for actuarial opinions and regulatory filings require proper currency reference for Schedule P and international operations. Replaces currency_code denormalization.',
    `insured_entity_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_entity. Business justification: Actuarial reserve evaluations and Schedule P reporting require entity-level aggregation for large account analysis, self-insured retention programs, and appointed actuary opinions',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Reserve evaluations segment by LOB for actuarial opinions, rate filing support, and regulatory reserve requirements. Lob_code is denormalized.',
    `reserve_study_id` BIGINT COMMENT 'Foreign key linking to reservespayments.reserve_study. Business justification: Reserve evaluations are produced as part of a reserve study and should reference the underlying study for analytical lineage.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Reserve evaluations must segment by state for regulatory filings, actuarial opinions, rate adequacy testing, and state-specific reserve requirements. Replaces state_code denormalization.',
    `accident_year` BIGINT COMMENT 'The calendar year in which the insured loss events occurred. Used as the primary axis for loss development triangles and NAIC Schedule P accident-year exhibits.',
    `accounting_basis` STRING COMMENT 'The accounting framework under which reserves are stated: SAP (Statutory Accounting Principles), US GAAP, or IFRS 17. Determines reserve measurement and disclosure requirements.. Valid values are `SAP|GAAP|IFRS17`',
    `actuarial_opinion_reference` STRING COMMENT 'Reference identifier or document number for the Appointed Actuarys Statement of Actuarial Opinion (SAO) that covers this reserve evaluation. Links to document management system.',
    `alae_reserve_amount` DECIMAL(18,2) COMMENT 'Reserve for Allocated Loss Adjustment Expenses directly attributable to specific claims, such as defense costs and expert fees. Reported separately per NAIC Schedule P.',
    `appointed_actuary_credential` STRING COMMENT 'Professional credential of the Appointed Actuary (e.g., FCAS, MAAA). Required for NAIC actuarial opinion qualification and state DOI regulatory filings.. Valid values are `FCAS|ACAS|MAAA|FSA|ASA`',
    `appointed_actuary_name` STRING COMMENT 'Full name of the Appointed Actuary who signed the Statement of Actuarial Opinion for this reserve evaluation, as required by NAIC Model Law.',
    `cat_reserve_amount` DECIMAL(18,2) COMMENT 'Portion of the total reserve attributable to catastrophe (CAT) events as designated by ISO/PCS or internal CAT codes. Reported separately for NAIC CAT exhibits and reinsurance recoverable analysis.',
    `company_naic_code` STRING COMMENT 'Five-digit NAIC company code identifying the legal insurance entity for which reserves are evaluated. Required for statutory filings and Schedule P exhibits.. Valid values are `^[0-9]{5}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this reserve evaluation record was first created in the data platform. Supports audit trail, SOX compliance, and data lineage tracking.',
    `ep_amount` DECIMAL(18,2) COMMENT 'Gross earned premium for the accident year and LOB as of the evaluation date. Denominator for ULR and LR calculations in actuarial reserve adequacy testing.',
    `evaluation_date` DATE COMMENT 'The as-of date for which loss reserves are evaluated, typically the last day of the reporting quarter or year-end. Anchors all reserve positions and development triangles.',
    `evaluation_period_type` STRING COMMENT 'Indicates whether this evaluation is a quarterly, annual, interim, or special (e.g., CAT event-driven) reserve review cycle.. Valid values are `quarterly|annual|interim|special`',
    `evaluation_reference_number` STRING COMMENT 'Externally-known alphanumeric identifier assigned to this reserve evaluation cycle, used in actuarial opinion filings, NAIC Schedule P submissions, and bordereaux reporting.. Valid values are `^RE-[0-9]{4}-[0-9]{2}-[A-Z0-9]{6}$`',
    `evaluation_status` STRING COMMENT 'Current workflow state of the reserve evaluation, from initial draft through actuarial sign-off, management approval, and statutory filing. Drives sign-off and audit controls.. Valid values are `draft|in_review|actuarial_signed|management_approved|filed|superseded`',
    `gross_case_reserve_amount` DECIMAL(18,2) COMMENT 'Total gross (before reinsurance) outstanding case reserve amount as of the evaluation date, representing the estimated liability for known reported claims. Expressed in USD.',
    `gross_ibner_amount` DECIMAL(18,2) COMMENT 'Gross IBNER component of the total IBNR reserve, representing development on known claims where current case reserves are estimated to be inadequate.',
    `gross_ibnr_amount` DECIMAL(18,2) COMMENT 'Gross IBNR reserve amount as of the evaluation date, covering losses incurred but not yet reported to the insurer. Includes pure IBNR and IBNER components.',
    `gross_total_reserve_amount` DECIMAL(18,2) COMMENT 'Sum of gross case reserves and gross IBNR/IBNER as of the evaluation date. Represents the total gross reserve position before reinsurance recoverables.',
    `incurred_losses_to_date` DECIMAL(18,2) COMMENT 'Cumulative gross incurred losses (paid plus case reserves) as of the evaluation date for the accident year and LOB. Primary input to the Bornhuetter-Ferguson and chain-ladder methods.',
    `lob_description` STRING COMMENT 'Human-readable description of the Line of Business corresponding to lob_code, such as Commercial General Liability or Workers Compensation.',
    `loss_ratio` DECIMAL(8,4) COMMENT 'Ratio of incurred losses to earned premium as of the evaluation date. Distinct from ULR in that it uses incurred-to-date rather than ultimate estimates. Used in combined ratio reporting.',
    `net_case_reserve_amount` DECIMAL(18,2) COMMENT 'Net (after reinsurance cession) outstanding case reserve amount as of the evaluation date. Reflects the insurers retained liability on known reported claims.',
    `net_ibnr_amount` DECIMAL(18,2) COMMENT 'Net IBNR reserve amount after reinsurance recoverables as of the evaluation date. Used for net reserve adequacy testing and statutory surplus calculations.',
    `net_total_reserve_amount` DECIMAL(18,2) COMMENT 'Total net reserve position (case + IBNR) after reinsurance recoverables as of the evaluation date. Key metric for statutory surplus and solvency reporting.',
    `opinion_type` STRING COMMENT 'The type of actuarial opinion rendered on reserve adequacy: reasonable, deficient, excessive, qualified, or no opinion. Directly reported in NAIC statutory filings.. Valid values are `reasonable|deficient|excessive|qualified|no_opinion`',
    `paid_losses_to_date` DECIMAL(18,2) COMMENT 'Cumulative gross losses paid from policy inception through the evaluation date for the accident year and LOB. Used as the base for loss development triangle construction.',
    `policy_year` BIGINT COMMENT 'The year in which the policies generating the evaluated losses were written or incepted. Supports policy-year loss development analysis alongside accident-year triangles.',
    `prior_evaluation_date` DATE COMMENT 'The as-of date of the immediately preceding reserve evaluation for the same accident year and LOB. Used to compute period-over-period reserve development.',
    `reserve_basis` STRING COMMENT 'The basis on which reserves are evaluated and triangles are constructed: accident year, policy year, report year, or calendar year. Determines triangle structure for Schedule P.. Valid values are `accident_year|policy_year|report_year|calendar_year`',
    `reserve_development_amount` DECIMAL(18,2) COMMENT 'Change in total reserve estimate from the prior evaluation period to the current evaluation date. Positive indicates adverse development; negative indicates favorable development.',
    `reserving_system_source` STRING COMMENT 'The actuarial reserving system from which this evaluation record was sourced (e.g., Milliman Arius, Willis Towers Watson ResQ). Supports data lineage and audit traceability.. Valid values are `milliman_arius|wtw_resq|internal_model|other`',
    `ri_recoverable_amount` DECIMAL(18,2) COMMENT 'Estimated reinsurance recoverable on unpaid losses and LAE as of the evaluation date. Equals gross total reserve minus net total reserve. Reported on NAIC Schedule F.',
    `schedule_p_line` STRING COMMENT 'The specific NAIC Schedule P line (e.g., Line 1 - Homeowners, Line 5 - CGL) to which this reserve evaluation maps for statutory annual statement filing purposes.',
    `ulae_reserve_amount` DECIMAL(18,2) COMMENT 'Reserve for Unallocated Loss Adjustment Expenses not directly tied to individual claims, such as general claims department overhead. Estimated via Kittel or similar methods.',
    `ulr` DECIMAL(8,4) COMMENT 'Ratio of the actuarial ultimate loss estimate to earned premium for the accident year and LOB. Key actuarial adequacy metric: ULR = ultimate_loss_estimate / ep_amount.',
    `ultimate_loss_estimate` DECIMAL(18,2) COMMENT 'Actuarially estimated ultimate loss amount for the accident year and LOB as of the evaluation date. Derived from loss development methods (chain-ladder, BF, Cape Cod).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this reserve evaluation record. Used for incremental data loads, change tracking, and audit compliance in the Databricks Silver layer.',
    CONSTRAINT pk_reserve_evaluation PRIMARY KEY(`reserve_evaluation_id`)
) COMMENT 'Periodic actuarial reserve evaluation SSOT (quarterly/annual): gross and net reserve positions, ULR/loss ratio, embedded loss development triangles, actuarial opinion reference, and NAIC Schedule P / state DOI statutory exhibits, signed off for statutory';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` (
    `reservespayments_claim_payment_id` BIGINT COMMENT 'Unique surrogate primary key for the claim-payment junction record. Identifies a single allocation of a payment to a specific claim and coverage part.',
    `adjuster_id` BIGINT COMMENT 'Reference to the claims adjuster responsible for this payment allocation. Links to the employee or vendor adjuster record for workload and performance reporting.',
    `claim_id` BIGINT COMMENT 'Foreign key reference to the parent claim record. Links the payment allocation to the specific loss event being indemnified.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Claim payment amounts require currency reference for international claims, FX conversion, bank reconciliation, and financial reporting. Currency_code denormalizes currency master.',
    `insured_entity_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_entity. Business justification: Entity-level payment history drives experience modification calculations, loss-sensitive pricing adjustments, dividend calculations, and large deductible program reconciliation',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Claim payments must be allocated to specific locations to calculate territorial loss costs, support rate filings, analyze loss patterns by construction type, and reconcile cat',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Auto claim payments require vehicle linkage for total loss settlement validation, salvage proceeds reconciliation, and vehicle-level loss history tracking for renewal rating and',
    `part_id` BIGINT COMMENT 'Reference to the specific coverage part (e.g., BI, PD, MedPay, PIP, ALAE) under which this payment allocation is made. Drives statutory and financial reporting.',
    `payee_id` BIGINT COMMENT 'Reference to the party record of the payment recipient. Links to the party master for payee name, tax ID, and address used on the disbursement instrument.',
    `user_account_id` BIGINT COMMENT 'Reference to the employee or adjuster who approved this payment allocation. Required for claims authority audit trail and SOX segregation-of-duties compliance.',
    `accident_year` BIGINT COMMENT 'Four-digit calendar year in which the loss event occurred. Primary dimension for actuarial loss development triangles and IBNR reserve estimation per NAIC Schedule P.',
    `accounting_date` DATE COMMENT 'Date on which this payment allocation is recognized in the general ledger. May differ from payment_date due to period-end cutoffs and accrual adjustments.',
    `allocated_gross_amount` DECIMAL(18,2) COMMENT 'Gross dollar amount of the payment allocated to this claim and coverage part before deducting recoveries, SIR, or deductibles. Basis for GWP loss ratio calculations.',
    `allocation_number` STRING COMMENT 'Human-readable business identifier for this claim-payment allocation line. Used in bordereaux, adjuster notes, and payment reconciliation reports.. Valid values are `^ALLOC-[0-9]{10}$`',
    `approval_status` STRING COMMENT 'Workflow approval state for this payment allocation. Payments above authority thresholds require supervisor or management approval before disbursement per SOX controls.. Valid values are `pending|approved|rejected|escalated`',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time the payment allocation was approved by the authorized approver. Supports SOX audit trail and claims payment timeliness regulatory reporting.',
    `bank_clearance_date` DATE COMMENT 'Date the payment instrument cleared the issuing bank account. Confirms actual cash outflow for treasury management and outstanding check reconciliation.',
    `cat_event_code` STRING COMMENT 'ISO or internal CAT event identifier linking this payment to a declared catastrophe (e.g., hurricane, wildfire, flood). Enables CAT loss aggregation and PML reporting.. Valid values are `^[A-Z0-9-]{1,20}$`',
    `check_number` STRING COMMENT 'Check number or EFT/wire reference number assigned by the bank or payment processor. Used for bank reconciliation, stop-payment requests, and audit trail.. Valid values are `^[A-Z0-9-]{1,20}$`',
    `cost_center_code` STRING COMMENT 'Internal cost center to which this payment is attributed for management accounting and expense allocation purposes. Supports departmental P&L reporting.. Valid values are `^[A-Z0-9-]{2,15}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this claim-payment junction record was first created in the system. Used for audit trail, data lineage, and SOX compliance.',
    `deductible_offset_amount` DECIMAL(18,2) COMMENT 'Portion of the gross payment amount withheld or offset against the insureds applicable deductible or SIR for this coverage part. Reduces insurer net payment.',
    `gl_account_code` STRING COMMENT 'GL account code to which this payment allocation is posted in the financial ledger. Ensures correct statutory and GAAP financial statement classification.. Valid values are `^[A-Z0-9-]{4,20}$`',
    `is_cat_loss` BOOLEAN COMMENT 'Flag indicating whether this payment is associated with a declared catastrophe event. Drives CAT XL reinsurance cession and regulatory CAT reporting.',
    `is_large_loss` BOOLEAN COMMENT 'Flag indicating whether this payment exceeds the insurers large-loss threshold, triggering enhanced management review, facultative reinsurance consideration, and actuarial flagging.',
    `lob_code` STRING COMMENT 'NAIC or internal line-of-business code (e.g., HO, AUTO, GL, WC, CPP) classifying the policy under which this payment is made. Required for statutory Schedule P reporting.. Valid values are `^[A-Z0-9]{2,10}$`',
    `loss_date` DATE COMMENT 'Date on which the underlying loss event occurred. Denormalized here for statutory accident-year reporting and actuarial loss development triangle construction.',
    `net_of_ri_amount` DECIMAL(18,2) COMMENT 'Net payment amount retained by the insurer after deducting reinsurance recoverables. Equals net_payment_amount minus reinsurance_recoverable_amount. Key NWP metric.',
    `net_payment_amount` DECIMAL(18,2) COMMENT 'Net dollar amount paid on this allocation after subtracting recoveries, SIR, and deductible offsets. Equals allocated_gross_amount minus recovery_amount and deductible_offset_amount.',
    `notes` STRING COMMENT 'Free-text adjuster or examiner notes describing the basis for this payment allocation, coverage determination rationale, or special handling instructions.',
    `payment_date` DATE COMMENT 'Calendar date on which the payment was issued or disbursed to the payee. Used for cash-basis accounting, statutory reporting, and aging analysis.',
    `payment_method` STRING COMMENT 'Instrument used to disburse the payment: physical check, electronic funds transfer (EFT), wire transfer, bank draft, or virtual card. Used for treasury and AP reconciliation.. Valid values are `check|eft|wire|draft|virtual_card`',
    `payment_status` STRING COMMENT 'Current lifecycle state of this payment allocation. Tracks whether the disbursement is pending approval, issued, cleared by the bank, voided, stopped, or returned.. Valid values are `pending|issued|cleared|voided|stopped|returned`',
    `payment_type` STRING COMMENT 'Categorizes the nature of the payment: indemnity (loss), ALAE, ULAE, MedPay, PIP, or recovery (subrogation/salvage). Drives statutory line-of-business reporting.',
    `policy_year` BIGINT COMMENT 'Four-digit year in which the policy that generated this claim was effective. Used for policy-year loss development analysis distinct from accident-year triangles.',
    `recovery_amount` DECIMAL(18,2) COMMENT 'Dollar amount recovered via subrogation, salvage, or other recovery channels applied against this allocation. Reduces net loss incurred on the claim.',
    `reinsurance_recoverable_amount` DECIMAL(18,2) COMMENT 'Portion of the gross payment amount recoverable from reinsurers under applicable treaty or facultative (FAC) agreements. Used in cession bordereaux and NWP calculation.',
    `report_date` DATE COMMENT 'Date the claim was first reported to the insurer (FNOL date). Used for report-year loss development and IBNR actuarial analysis alongside the loss date.',
    `reserve_type` STRING COMMENT 'Identifies the reserve category this payment draws against: case reserve (OCR), IBNR, IBNER, ULAE reserve, or ALAE reserve. Drives actuarial reserve adequacy reporting.. Valid values are `case_reserve|ibnr|ibner|ulae_reserve|alae_reserve`',
    `salvage_amount` DECIMAL(18,2) COMMENT 'Dollar amount recovered through salvage of damaged property associated with this claim payment. Reduces net incurred loss and is reported separately in NAIC statutory filings.',
    `subrogation_status` STRING COMMENT 'Current status of subrogation pursuit for this payment allocation. Tracks whether a recovery opportunity has been identified, is being pursued, collected, or closed.. Valid values are `not_applicable|identified|in_pursuit|collected|closed_no_recovery`',
    `transaction_timestamp` TIMESTAMP COMMENT 'Exact date and time the payment allocation transaction was recorded in the claims system. Serves as the principal business event timestamp for audit and reconciliation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this claim-payment junction record. Supports change data capture, audit trails, and incremental ETL processing.',
    `void_date` DATE COMMENT 'Date on which the payment was voided, if applicable. Null for active payments. Required for reissuance tracking and AP reconciliation under SOX controls.',
    `void_reason` STRING COMMENT 'Reason code explaining why the payment was voided. Supports audit, fraud detection, and reissuance workflows. Null when payment_status is not voided. [ENUM-REF-CANDIDATE: duplicate|stale|incorrect_payee|incorrect_amount|lost|reissued|other — 7 candidates',
    CONSTRAINT pk_reservespayments_claim_payment PRIMARY KEY(`reservespayments_claim_payment_id`)
) COMMENT 'Junction table for the many-to-many relationship between claims and payments. Captures payment allocation per claim, coverage part, payment type (indemnity, ALAE, MedPay, PIP), and net-of-recovery amount.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` (
    `payment_transaction_id` BIGINT COMMENT 'Unique surrogate identifier for each outbound loss payment transaction record in the Silver layer lakehouse.',
    `cat_event_id` BIGINT COMMENT 'Foreign key linking to reservespayments.cat_event. Business justification: Payment transactions for CAT losses need proper FK linkage to cat_event master. The cat_event_code string becomes redundant when FK allows JOIN.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim against which this payment is issued. Links payment to the claim adjudication lifecycle.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Payment transactions require currency reference for GL posting, bank reconciliation, multi-currency operations, and financial consolidation. Replaces denormalized currency_code.',
    `insured_entity_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_entity. Business justification: Large deductible programs, retrospective rating plans, and self-insured retention reconciliation require entity-level payment tracking to calculate premium adjustments and',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Payment transactions require location attribution for GL account posting, statutory reporting by state, territorial loss cost analysis, and cat event loss aggregation for',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Auto physical damage payments must reconcile to vehicle ACV, stated value, and loan/lease amounts; vehicle linkage enables total loss validation and salvage proceeds tracking.',
    `original_payment_payment_transaction_id` BIGINT COMMENT 'Self-referencing link to the original payment_transaction_id when this record is a reissue or replacement. Null for original payments.',
    `payee_id` BIGINT COMMENT 'Reference to the party (claimant, vendor, attorney, lienholder) receiving this payment. Satisfies PARTY_REFERENCE canonical category.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Payments must be allocated to specific coverages for GL accounting, Schedule P stat reporting by coverage type, and reinsurance recovery calculation.',
    `reservespayments_loss_reserve_id` BIGINT COMMENT 'Reference to the case reserve line from which this payment is drawn, enabling reserve-to-payment reconciliation and OCR tracking.',
    `accident_year` BIGINT COMMENT 'Calendar year in which the loss event (DOL) occurred. Used for actuarial loss development triangles, IBNR estimation, and Schedule P reporting.',
    `bank_account_number` STRING COMMENT 'Payee bank account number for EFT or wire disbursement. Stored in tokenized or masked form per PCI DSS. Null for check payments.',
    `bank_clearing_date` DATE COMMENT 'Date the payment instrument cleared the issuing bank account. Used for cash management, bank reconciliation, and float analysis.',
    `bank_routing_number` STRING COMMENT 'ABA routing transit number of the payee financial institution for EFT or wire. Null for check payments.. Valid values are `^[0-9]{9}$`',
    `check_number` STRING COMMENT 'Physical or virtual check number printed on the instrument. Null for EFT and wire payments. Used for bank reconciliation and stop-payment processing.',
    `cost_center_code` STRING COMMENT 'Organizational cost center to which the payment expense is allocated. Used for departmental expense reporting and management accounting.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this payment transaction record was first created in the source system. Satisfies RECORD_AUDIT_CREATED canonical category.',
    `deduction_amount` DECIMAL(18,2) COMMENT 'Total amount withheld from gross payment for SIR offsets, deductibles, liens, or tax withholding before net disbursement to payee.',
    `gl_account_code` STRING COMMENT 'Oracle Financials or SAP FI GL account code to which this payment is posted. Enables financial close reconciliation and statutory balance sheet mapping.',
    `gl_journal_reference` STRING COMMENT 'Reference to the GL journal entry created in Oracle Financials or SAP FI for this payment. Supports audit trail and financial reconciliation.',
    `gl_posting_date` DATE COMMENT 'Date the payment was posted to the general ledger. May differ from payment_date due to period-end cutoff rules and accounting close schedules.',
    `gross_amount` DECIMAL(18,2) COMMENT 'Total face value of the payment before any deductions, withholdings, or offsets. Represents the amount printed on the check or EFT instruction.',
    `is_1099_reportable` BOOLEAN COMMENT 'Indicates whether this payment must be reported to the IRS on Form 1099. Determined by payee type, payment type, and amount thresholds.',
    `is_cat_loss` BOOLEAN COMMENT 'Flags the payment as associated with a declared catastrophe event. Used for CAT loss aggregation, PML tracking, and CAT XL reinsurance recovery.',
    `line_of_business_code` STRING COMMENT 'NAIC line of business code classifying the insurance product line for this payment. Used in statutory Schedule P and combined ratio reporting.',
    `loss_category` STRING COMMENT 'Insurance loss category for statutory and GAAP reporting. Aligns with NAIC Schedule P loss development triangles and line-of-business reporting. [ENUM-REF-CANDIDATE: promote to reference product]',
    `net_amount` DECIMAL(18,2) COMMENT 'Actual amount disbursed to the payee after all deductions. Equals gross_amount minus deduction_amount. Used for GL posting and cash management.',
    `ofac_screening_status` STRING COMMENT 'Result of OFAC SDN list screening for the payee prior to payment release. Blocked payments require compliance review before disbursement.. Valid values are `pending|cleared|flagged|blocked`',
    `payee_tax_identification_number` STRING COMMENT 'Federal tax identifier (SSN or FEIN) of the payee. Required for IRS 1099 reporting on claim payments exceeding statutory thresholds.',
    `payee_type` STRING COMMENT 'Classification of the payee role in the claim. Determines payment workflow, tax reporting (1099), and OFAC screening requirements. [ENUM-REF-CANDIDATE: promote to reference product]',
    `payment_date` DATE COMMENT 'Calendar date on which the payment was issued or authorized for disbursement. Principal business event date for statutory and GAAP loss reporting.',
    `payment_method` STRING COMMENT 'Instrument or channel used to disburse funds to the payee. Drives bank file format selection and reconciliation workflow.. Valid values are `check|eft|wire|virtual_card|cash`',
    `payment_notes` STRING COMMENT 'Free-text adjuster or AP notes describing special payment instructions, lien conditions, co-payee requirements, or other disbursement details.',
    `payment_number` STRING COMMENT 'Externally visible, human-readable payment reference number assigned at issuance. Used on check stubs, EFT remittance advice, and correspondence.. Valid values are `^PAY-[0-9]{10}$`',
    `payment_status` STRING COMMENT 'Current lifecycle state of the payment instrument. Tracks progression from draft through issuance, bank clearing, void, or reissue.. Valid values are `draft|issued|cleared|voided|reissued|stopped`',
    `payment_type` STRING COMMENT 'Categorizes the economic nature of the payment. Distinguishes indemnity from ALAE, ULAE, subrogation recovery, salvage, and other LAE components. [ENUM-REF-CANDIDATE: indemnity|alae|ulae|subrogation_recovery|salvage|medical|legal_fee|expert_fee — promote',
    `policy_year` BIGINT COMMENT 'Year in which the policy that generated this claim was written. Supports policy-year loss development analysis distinct from accident-year triangles.',
    `reinsurance_recoverable_flag` BOOLEAN COMMENT 'Indicates whether any portion of this payment is recoverable from a reinsurer under a treaty or facultative certificate. Triggers RI cession processing.',
    `reissue_date` DATE COMMENT 'Date a replacement payment was reissued following a void or stop-payment. Links to the original payment via original_payment_number.',
    `ri_recoverable_amount` DECIMAL(18,2) COMMENT 'Portion of the gross payment expected to be recovered from reinsurers. Used in bordereaux processing and net loss reporting.',
    `sir_deductible_amount` DECIMAL(18,2) COMMENT 'Amount of the payment attributable to the insureds SIR or policy deductible. Reduces net insurer loss and may trigger deductible billing to insured.',
    `source_system_code` STRING COMMENT 'Identifies the operational system of record that originated this payment transaction record for lineage and reconciliation purposes.. Valid values are `guidewire_cc|duck_creek_claims|oracle_ap|sap_fi`',
    `subrogation_flag` BOOLEAN COMMENT 'Indicates this payment has an associated subrogation recovery opportunity. Triggers SubroFT workflow in ClaimCenter for third-party recovery pursuit.',
    `tax_withholding_amount` DECIMAL(18,2) COMMENT 'Federal or state tax withheld from the payment per IRS backup withholding rules. Reported on IRS Form 1099 for qualifying payees.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this payment transaction record. Satisfies RECORD_AUDIT_UPDATED canonical category.',
    `void_date` DATE COMMENT 'Date the payment was voided. Null for active payments. Triggers reversal GL entries and reserve reinstatement in ClaimCenter.',
    `void_reason` STRING COMMENT 'Reason code explaining why the payment was voided. Required for audit trail and stop-payment processing. Null for non-voided payments. [ENUM-REF-CANDIDATE: promote to reference product]',
    CONSTRAINT pk_payment_transaction PRIMARY KEY(`payment_transaction_id`)
) COMMENT 'Master record of every outbound loss payment issued (check, EFT, wire). Tracks payee, payment method, gross amount, void/reissue status, bank clearing date, and GL posting reference. Source: ClaimCenter / Oracle AP.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` (
    `recovery_transaction_id` BIGINT COMMENT 'Unique surrogate identifier for each recovery transaction record in the reserves and payments domain.',
    `cat_event_id` BIGINT COMMENT 'Foreign key linking to reservespayments.cat_event. Business justification: Recovery transactions for CAT events need proper FK linkage to cat_event master. The cat_event_code string becomes redundant when FK allows JOIN.',
    `claim_id` BIGINT COMMENT 'Reference to the claim against which this recovery is applied. Links recovery to the originating loss event.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Subrogation and salvage recovery amounts require currency reference for accounting, collection tracking, and financial reporting. Currency_code is denormalized.',
    `fac_certificate_id` BIGINT COMMENT 'Foreign key linking to reinsurance.fac_certificate. Business justification: Subrogation and salvage recoveries on facultatively reinsured claims must identify the fac certificate to allocate recovered amounts between cedant and fac reinsurer.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Subrogation and salvage recoveries must be allocated to locations for net loss ratio calculation, territorial rate adequacy analysis, and cat event loss reconciliation.',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Auto salvage proceeds must reconcile to vehicle valuation, title transfer documentation, and total loss settlement amounts; vehicle linkage enables salvage audit and subrogation',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Subrogation and salvage recoveries must be credited to the specific coverage that paid the loss for accurate loss ratio calculation, reserve release accounting, and',
    `policy_id` BIGINT COMMENT 'Reference to the insurance policy under which the underlying claim was filed and recovery is pursued.',
    `recovered_payment_transaction_id` BIGINT COMMENT 'Foreign key linking to reservespayments.payment_transaction. Business justification: Recovery transactions (subrogation, salvage, reinsurance recoveries) often relate to specific payment transactions that were previously issued.',
    `reinsurance_cession_id` BIGINT COMMENT 'Foreign key linking to reinsurance.cession. Business justification: Recovery transactions on ceded policies must identify the specific cession to allocate recovered amounts (subrogation/salvage) between cedant and reinsurer per cession terms.',
    `reinsurance_recoverable_id` BIGINT COMMENT 'Foreign key linking to reservespayments.reinsurance_recoverable. Business justification: When recovery_transaction.recovery_type = Reinsurance Recovery, it should link to the reinsurance_recoverable master record.',
    `reservespayments_claim_payment_id` BIGINT COMMENT 'Reference to the specific claim payment disbursement that this recovery offsets or partially recovers.',
    `ri_treaty_id` BIGINT COMMENT 'Reference to the reinsurance treaty or facultative (FAC) certificate under which the reinsurance recoverable is claimed. Null for non-reinsurance recovery types.',
    `salvage_item_id` BIGINT COMMENT 'Foreign key linking to reservespayments.salvage_item. Business justification: When recovery_transaction.recovery_type = Salvage, it should link to the salvage_item master record. This enables tracking which salvage item generated which recovery.',
    `subrogation_case_id` BIGINT COMMENT 'Foreign key linking to reservespayments.subrogation_case. Business justification: When recovery_transaction.recovery_type = Subrogation, it should link to the subrogation_case master record.',
    `accident_year` BIGINT COMMENT 'Four-digit year in which the underlying loss event (Date of Loss / DOL) occurred. Used for accident-year loss development and actuarial reserving triangles.',
    `accounting_period` STRING COMMENT 'Fiscal accounting period (YYYY-MM) in which the recovery is recognized for financial close and statutory reporting purposes.. Valid values are `^[0-9]{4}-(0[1-9]|1[0-2])$`',
    `at_fault_party_insurer` STRING COMMENT 'Name of the liability insurer of the at-fault third party. Used to direct subrogation demands and track inter-company recovery negotiations.',
    `at_fault_party_name` STRING COMMENT 'Legal name of the third party against whom subrogation or recovery action is pursued. Restricted PII when the party is an individual.',
    `at_fault_party_policy_number` STRING COMMENT 'Policy number of the at-fault third partys liability insurance. Used to identify the adverse carrier and track subrogation demand status.',
    `closed_date` DATE COMMENT 'Date on which the recovery transaction was closed, either through full collection, settlement, or write-off. Null if still open.',
    `collection_attorney_firm` STRING COMMENT 'Name of the external law firm or collection agency engaged to pursue the recovery action. Used for vendor management and ALAE expense tracking.',
    `collection_expense_amount` DECIMAL(18,2) COMMENT 'Allocated Loss Adjustment Expense (ALAE) incurred to collect this recovery, including attorney fees, investigation costs, and court costs.',
    `company_naic_code` STRING COMMENT 'Five-digit NAIC company code identifying the writing company entity. Required for statutory financial statements and Schedule F reinsurance reporting.. Valid values are `^[0-9]{5}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this recovery transaction record was first created in the system of record. Used for audit trail and data lineage.',
    `gl_account_code` STRING COMMENT 'General Ledger account code to which the recovery proceeds are posted in the financial ledger. Ensures proper accounting treatment per SAP/STAT and US GAAP.. Valid values are `^[A-Z0-9]{4,20}$`',
    `gross_recovery_amount` DECIMAL(18,2) COMMENT 'Total gross amount recovered before deducting collection expenses, attorney fees, or reinsurance shares. Represents the full inbound recovery value.',
    `initiated_date` DATE COMMENT 'Date on which the recovery action was formally initiated (e.g., subrogation demand letter sent, salvage auction listed, reinsurance proof of loss submitted).',
    `is_cat_event` BOOLEAN COMMENT 'Indicates whether the underlying claim is associated with a declared catastrophe (CAT) event. Used for CAT loss reporting and CAT XL reinsurance recovery tracking.',
    `is_intercompany` BOOLEAN COMMENT 'Indicates whether this recovery involves an affiliated entity within the same insurance group. Triggers intercompany elimination in consolidated financial statements.',
    `lob_code` STRING COMMENT 'NAIC or internal Line of Business code classifying the coverage under which the claim was filed (e.g., GL, APD, WC, PD, BI). Used for statutory reporting.. Valid values are `^[A-Z0-9]{2,10}$`',
    `net_recovery_amount` DECIMAL(18,2) COMMENT 'Net recovery amount after deducting collection expenses from gross recovery. Represents the actual benefit to the insurer for loss ratio and reserve release purposes.',
    `net_retained_recovery_amount` DECIMAL(18,2) COMMENT 'Recovery amount retained by the insurer after deducting both collection expenses and the reinsurance share. Used for net loss ratio and financial reporting.',
    `notes` STRING COMMENT 'Free-text narrative capturing adjuster comments, negotiation history, legal strategy notes, or other contextual information relevant to this recovery transaction.',
    `policy_year` BIGINT COMMENT 'Four-digit year in which the policy that generated the underlying claim was effective. Used for policy-year loss development and reinsurance treaty year allocation.',
    `recovery_basis` STRING COMMENT 'Accounting basis under which the recovery is recognized: cash (when received) or accrual (when probable and estimable). Aligns with statutory vs GAAP reporting.. Valid values are `CASH|ACCRUAL`',
    `recovery_date` DATE COMMENT 'Calendar date on which the recovery was received or recognized, used as the principal business event date for accounting and loss reporting.',
    `recovery_method` STRING COMMENT 'Mechanism by which the recovery proceeds were received: check, wire transfer, ACH, offset against payable, or credit note from reinsurer.. Valid values are `CHECK|WIRE|ACH|OFFSET|CREDIT_NOTE`',
    `recovery_reference_number` STRING COMMENT 'Externally visible alphanumeric identifier assigned to this recovery transaction, used in bordereaux, correspondence, and statutory reporting.. Valid values are `^REC-[0-9]{4}-[0-9]{8}$`',
    `recovery_status` STRING COMMENT 'Current lifecycle state of the recovery transaction: open, in collection, collected, closed, or written off. Drives reserve release and cash posting.. Valid values are `OPEN|IN_COLLECTION|COLLECTED|CLOSED|WRITTEN_OFF`',
    `recovery_type` STRING COMMENT 'Classification of the inbound recovery: subrogation (SubroFT), salvage, reinsurance recoverable, second-injury fund, or other. Drives accounting treatment and reporting.. Valid values are `SUBROGATION|SALVAGE|REINSURANCE|SECOND_INJURY_FUND|OTHER`',
    `reserve_release_amount` DECIMAL(18,2) COMMENT 'Amount of outstanding case reserve (OCR) released upon collection or closure of this recovery transaction. Used for reserve development reporting.',
    `ri_share_amount` DECIMAL(18,2) COMMENT 'Portion of the gross recovery that must be remitted to reinsurers per treaty or facultative (FAC) agreement terms. Reduces net recovery retained by the cedant.',
    `second_injury_fund_state` STRING COMMENT 'Two-letter state code of the Second Injury Fund from which recovery is sought in Workers Compensation (WC) claims. Null for non-WC or non-SIF recovery types.. Valid values are `^[A-Z]{2}$`',
    `state_code` STRING COMMENT 'Two-letter US state code where the underlying loss occurred or the policy was issued. Required for state-level statutory reporting to Departments of Insurance.. Valid values are `^[A-Z]{2}$`',
    `statute_of_limitations_date` DATE COMMENT 'Date by which legal action must be filed to preserve the recovery right. Critical for subrogation diary management and write-off decisions.',
    `subrogation_demand_amount` DECIMAL(18,2) COMMENT 'Full demand amount asserted against the at-fault third party in a subrogation (SubroFT) action. May exceed gross recovery if partial collection occurs.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this recovery transaction record. Used for change tracking and incremental ETL.',
    `write_off_amount` DECIMAL(18,2) COMMENT 'Amount of the expected recovery that was written off as uncollectible. Impacts net loss ratio and reserve release calculations.',
    `write_off_reason` STRING COMMENT 'Reason code explaining why a recovery was written off without full collection: uncollectible, statute expired, negotiated settlement, insolvency, or waived.. Valid values are `UNCOLLECTIBLE|STATUTE_EXPIRED|SETTLEMENT|INSOLVENCY|WAIVED`',
    CONSTRAINT pk_recovery_transaction PRIMARY KEY(`recovery_transaction_id`)
) COMMENT 'Records all inbound recoveries against paid losses: subrogation (SubroFT), salvage, reinsurance recoverable, and second-injury fund. Tracks recovery type, gross recovery, net recovery, and collection status.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` (
    `subrogation_case_id` BIGINT COMMENT 'Unique surrogate identifier for the subrogation case record on the Databricks Silver Layer.',
    `adjuster_id` BIGINT COMMENT 'Reference to the claims adjuster or subrogation specialist responsible for managing this recovery pursuit.',
    `attorney_id` BIGINT COMMENT 'Reference to the internal or external attorney assigned to manage litigation or formal legal pursuit of the subrogation case.',
    `claim_id` BIGINT COMMENT 'Reference to the underlying insurance claim from which this subrogation pursuit originates.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Subrogation case financial amounts (demand, collected, settlement) require currency reference for international recoveries and accounting. Replaces currency_code denormalization.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Property subrogation cases require location details (construction type, protection class, occupancy) for liability determination, demand calculation, and recovery potential',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Auto subrogation demands are based on vehicle damage estimates, repair costs, and total loss valuations; vehicle linkage enables demand calculation and recovery tracking.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Subrogation pursuit decisions depend on coverage-specific terms: waiver of subrogation endorsements block recovery rights, deductible reimbursement rules vary by coverage.',
    `policy_id` BIGINT COMMENT 'Reference to the insurance policy under which the originating claim was covered.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Subrogation cases require state reference for statute of limitations, recovery laws, arbitration forum rules, and court jurisdiction. State_code denormalizes state master.',
    `alae_paid_amount` DECIMAL(18,2) COMMENT 'Allocated Loss Adjustment Expense paid on the originating claim, included in the subrogation demand to the extent recoverable.',
    `arbitration_filing_date` DATE COMMENT 'Date on which the arbitration demand was formally filed with the selected arbitration forum.',
    `arbitration_forum` STRING COMMENT 'Arbitration forum selected for intercompany or third-party arbitration proceedings (e.g., AAIS, AAA, AICRB).. Valid values are `AAIS|AICRB|AAA|NCCI|none`',
    `attorney_firm_name` STRING COMMENT 'Name of the law firm retained to pursue subrogation recovery through litigation or formal legal demand.',
    `case_number` STRING COMMENT 'Externally visible alphanumeric identifier assigned to the subrogation case, used in correspondence and bordereaux reporting.. Valid values are `^SUBRO-[0-9]{4}-[0-9]{6}$`',
    `case_status` STRING COMMENT 'Current lifecycle state of the subrogation pursuit. [ENUM-REF-CANDIDATE: open|in_demand|in_litigation|settled|closed_recovered|closed_no_recovery — promote to reference product]. Valid values are `open|in_demand|in_litigation|settled|closed_recovered|closed_no_recovery`',
    `case_type` STRING COMMENT 'Classification of the subrogation pursuit by line of business or liability theory. [ENUM-REF-CANDIDATE: auto_liability|property_damage|workers_comp|general_liability|product_liability — promote to reference product]. Valid values are `auto_liability|property_damage|workers_comp|general_liability|product_liability`',
    `closed_date` DATE COMMENT 'Date on which the subrogation case was closed, either upon full recovery, settlement, or determination of no recovery.',
    `collected_amount` DECIMAL(18,2) COMMENT 'Total amount actually collected from the liable third party or their insurer to date across all recovery payments.',
    `court_jurisdiction` STRING COMMENT 'State or federal court jurisdiction in which the subrogation lawsuit has been or will be filed.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the subrogation case record was first created in the system of record.',
    `date_of_loss` DATE COMMENT 'Date on which the insured loss event occurred, establishing the basis for the subrogation right.',
    `deductible_reimbursed_amount` DECIMAL(18,2) COMMENT 'Portion of the net recovery returned to the insured as reimbursement of their deductible, per policy terms and state law.',
    `demand_amount` DECIMAL(18,2) COMMENT 'Total dollar amount formally demanded from the liable third party or their insurer, inclusive of losses and recoverable expenses.',
    `demand_sent_date` DATE COMMENT 'Date on which the formal demand letter was sent to the liable third party or their insurer.',
    `gross_paid_loss_amount` DECIMAL(18,2) COMMENT 'Total indemnity loss amount paid by the insurer on the originating claim, representing the maximum theoretical subrogation recovery base.',
    `liability_percentage` DECIMAL(5,2) COMMENT 'Percentage of fault attributed to the liable third party, used to calculate the proportionate recovery demand in comparative negligence states.',
    `litigation_filed_flag` BOOLEAN COMMENT 'Indicates whether a lawsuit has been formally filed in court to pursue the subrogation recovery.',
    `lob_code` STRING COMMENT 'NAIC or internal Line of Business code identifying the insurance product line under which the originating claim was filed.',
    `net_recovery_amount` DECIMAL(18,2) COMMENT 'Net recovery after deducting all pursuit expenses from the collected amount. Equals collected_amount minus recovery_expense_amount.',
    `notes` STRING COMMENT 'Free-text field for adjuster or attorney notes documenting key developments, negotiations, and decisions in the subrogation pursuit.',
    `opened_date` DATE COMMENT 'Date on which the subrogation case was formally opened and assigned for pursuit.',
    `priority_level` STRING COMMENT 'Operational priority assigned to the subrogation case to guide adjuster workload management and pursuit urgency.. Valid values are `high|medium|low`',
    `pursuit_method` STRING COMMENT 'Method selected to pursue recovery from the liable third party, such as demand letter, arbitration, or formal litigation.. Valid values are `demand_letter|arbitration|litigation|intercompany|waived`',
    `recovery_expense_amount` DECIMAL(18,2) COMMENT 'Total expenses incurred in pursuing the subrogation recovery, including attorney fees, court costs, and investigation costs.',
    `ri_recoverable_flag` BOOLEAN COMMENT 'Indicates whether a portion of the subrogation recovery is owed to reinsurers under applicable treaty or facultative agreements.',
    `ri_recovery_share_amount` DECIMAL(18,2) COMMENT 'Dollar amount of the net subrogation recovery attributable to reinsurers, calculated per treaty or facultative terms.',
    `settlement_amount` DECIMAL(18,2) COMMENT 'Agreed settlement amount accepted from the liable third party, which may be less than the full demand amount.',
    `settlement_date` DATE COMMENT 'Date on which a settlement agreement was executed with the liable third party or their insurer.',
    `settlement_status` STRING COMMENT 'Indicates whether a settlement agreement has been reached with the third party and the extent of that settlement.. Valid values are `not_settled|partial_settlement|full_settlement|waived`',
    `statute_of_limitations_date` DATE COMMENT 'Deadline by which legal action must be filed to preserve the subrogation right, per applicable state law.',
    `third_party_claim_number` STRING COMMENT 'Claim number assigned by the at-fault third partys insurer for the corresponding liability claim.',
    `third_party_insurer_name` STRING COMMENT 'Name of the insurance carrier providing liability coverage to the at-fault third party.',
    `third_party_name` STRING COMMENT 'Full legal name of the liable third party against whom subrogation is being pursued.',
    `third_party_policy_number` STRING COMMENT 'Policy number of the at-fault third partys liability insurance, used to facilitate demand and recovery negotiations.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the subrogation case record.',
    `waiver_reason` STRING COMMENT 'Reason code explaining why subrogation pursuit was waived or abandoned, required for regulatory and audit purposes.. Valid values are `uncollectible|cost_benefit|insured_fault|statute_expired|other`',
    CONSTRAINT pk_subrogation_case PRIMARY KEY(`subrogation_case_id`)
) COMMENT 'Master record for a subrogation pursuit against a liable third party. Tracks demand amount, collected amount, attorney assignment, statute of limitations date, settlement status, and net recovery after expenses.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` (
    `salvage_item_id` BIGINT COMMENT 'Unique surrogate identifier for a salvage item record in the reserves and payments domain.',
    `cat_event_id` BIGINT COMMENT 'Foreign key linking to reservespayments.cat_event. Business justification: Salvage items from CAT events need proper FK linkage to cat_event master. The cat_event_code string becomes redundant when FK allows JOIN.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim from which this salvage item originated following a total-loss or partial-loss settlement.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Salvage proceeds and valuations require currency reference for auction settlements, accounting entries, and financial reporting. Currency_code denormalizes currency master.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Property salvage items (damaged equipment, inventory, building materials) are tracked by location for disposal coordination, recovery allocation, and net loss calculation.',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Total loss vehicles require VIN-level salvage tracking for title transfer, auction lot assignment, salvage proceeds reconciliation, and branded title reporting to state DMV.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Salvage proceeds must be credited to the specific coverage (typically physical damage/property) for reserve release, loss settlement accounting, and reinsurance recovery',
    `service_vendor_id` BIGINT COMMENT 'Reference to the salvage vendor or disposal service provider in the vendor/party master, used for payment processing and vendor performance tracking.',
    `acv_at_loss` DECIMAL(18,2) COMMENT 'Actual Cash Value (ACV) of the property at the Date of Loss (DOL), representing the pre-loss fair market value used as the basis for total-loss settlement.',
    `adjuster_notes` STRING COMMENT 'Free-text notes entered by the claims adjuster regarding the salvage item condition, disposal challenges, vendor negotiations, or other relevant operational details.',
    `auction_lot_number` STRING COMMENT 'Lot number assigned by the auction house for salvage items disposed of through auction channels. Used for reconciliation of auction proceeds remittances.',
    `branded_title_flag` BOOLEAN COMMENT 'Indicates whether the salvage title carries a branded designation (e.g., salvage, rebuilt, flood, junk) as required by state DMV regulations.',
    `company_naic_code` STRING COMMENT 'Five-digit NAIC company code of the writing insurer entity, required for statutory financial reporting and state DOI salvage recovery disclosures.. Valid values are `^[0-9]{5}$`',
    `condition_at_title` STRING COMMENT 'Condition classification of the salvage item at the time title was acquired. [ENUM-REF-CANDIDATE: total_loss|major_damage|minor_damage|flood|fire|theft_recovery|hail|other — promote to reference product]',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the salvage item record was first created in the claims administration system, providing the audit trail start point for the salvage lifecycle.',
    `disposal_cost` DECIMAL(18,2) COMMENT 'Total costs incurred to dispose of the salvage item including towing, storage, auction fees, environmental remediation, and administrative expenses.',
    `disposal_date` DATE COMMENT 'Date on which the salvage item was physically disposed of through the selected disposal method, triggering recognition of salvage proceeds.',
    `disposal_method` STRING COMMENT 'Method used to dispose of the salvage item. [ENUM-REF-CANDIDATE: auction|scrap|direct_sale|donation|return_to_insured|parts_only|other — promote to reference product]',
    `environmental_hazard_flag` BOOLEAN COMMENT 'Indicates whether the salvage item presents environmental hazards (e.g., fuel leaks, refrigerants, asbestos) requiring special handling and disposal procedures.',
    `item_description` STRING COMMENT 'Free-text description of the salvage property including make, model, year, condition, and any distinguishing characteristics relevant to valuation and disposal.',
    `item_type` STRING COMMENT 'Category of the physical property taken into salvage title. [ENUM-REF-CANDIDATE: vehicle|real_property|personal_property|equipment|watercraft|aircraft|other — promote to reference product]',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the salvage item record, supporting audit trail requirements and incremental data lake ingestion.',
    `lob_code` STRING COMMENT 'NAIC Line of Business (LOB) code associated with the originating claim, used for statutory reporting and salvage recovery allocation by line.',
    `make` STRING COMMENT 'Manufacturer or brand of the salvage item (e.g., Ford, Caterpillar, Carrier). Primarily used for vehicle and equipment salvage valuation.',
    `model` STRING COMMENT 'Model designation of the salvage item as provided by the manufacturer, used in conjunction with make and year for ACV determination.',
    `net_salvage_recovery` DECIMAL(18,2) COMMENT 'Net amount credited back to the claim calculated as salvage proceeds minus disposal costs. Reduces the ultimate net loss and is reported in statutory bordereaux.',
    `odometer_reading` BIGINT COMMENT 'Odometer reading in miles at the time of loss for vehicle salvage items. Used in ACV calculation and auction valuation. Null for non-vehicle items.',
    `payment_reference_number` STRING COMMENT 'Reference number of the payment transaction received from the salvage vendor or auction house, used for cash reconciliation in the financial ledger.',
    `proceeds_received_date` DATE COMMENT 'Date on which salvage proceeds were received and posted to the insurers accounts receivable, triggering the net salvage credit to the claim reserve.',
    `reserve_credit_applied_flag` BOOLEAN COMMENT 'Indicates whether the net salvage recovery has been credited back to the claim loss reserve in the actuarial reserving system, reducing the outstanding case reserve.',
    `ri_recoverable_flag` BOOLEAN COMMENT 'Indicates whether a portion of the salvage recovery is ceded to reinsurers under applicable treaty or facultative arrangements, requiring bordereaux reporting.',
    `ri_salvage_credit` DECIMAL(18,2) COMMENT 'Portion of net salvage recovery attributable to reinsurers under applicable cession arrangements. Reduces the reinsurance recoverable balance on the claim.',
    `salvage_proceeds` DECIMAL(18,2) COMMENT 'Gross proceeds actually received from the disposal of the salvage item through auction, scrap, or direct sale before deducting disposal costs.',
    `salvage_reference_number` STRING COMMENT 'Externally-known unique identifier assigned to this salvage item by the salvage vendor, auction house, or internal salvage management system.',
    `salvage_status` STRING COMMENT 'Current lifecycle state of the salvage item from title acquisition through final disposal. [ENUM-REF-CANDIDATE: pending|titled|listed|sold|scrapped|donated|returned|closed — promote to reference product]',
    `salvage_value_estimate` DECIMAL(18,2) COMMENT 'Estimated recoverable value of the salvage item at time of title acquisition, used for initial reserve credit and net loss calculation prior to actual disposal.',
    `salvage_vendor_name` STRING COMMENT 'Name of the salvage vendor, auction house, or scrap dealer engaged to manage the disposal of the salvage item (e.g., Copart, IAA, local scrap yard).',
    `serial_number` STRING COMMENT 'Manufacturer serial number for non-vehicle salvage items such as equipment, electronics, or machinery. Supports title transfer and ownership verification.',
    `state_of_loss_code` STRING COMMENT 'Two-letter US state code where the insured loss occurred. Governs applicable salvage regulations and statutory reporting jurisdiction.. Valid values are `^[A-Z]{2}$`',
    `storage_location` STRING COMMENT 'Physical address or facility identifier where the salvage item is stored pending disposal. Used for logistics coordination and storage cost accrual.',
    `storage_start_date` DATE COMMENT 'Date the salvage item entered storage at the designated facility, used to calculate accrued storage costs and manage disposal timelines.',
    `title_acquired_date` DATE COMMENT 'Date on which the insurer formally acquired legal title to the salvage property following total-loss settlement payment to the insured.',
    `title_brand_type` STRING COMMENT 'Specific brand designation applied to the salvage title by the issuing state DMV. Affects resale value and auction proceeds estimation. [ENUM-REF-CANDIDATE: salvage|rebuilt|flood|junk|parts_only|lemon|none — 7 candidates stripped; promote to reference',
    `title_state_code` STRING COMMENT 'Two-letter US state code of the jurisdiction in which the salvage title was issued. Governs title transfer requirements and branded title regulations.. Valid values are `^[A-Z]{2}$`',
    `total_loss_settlement_date` DATE COMMENT 'Date the total-loss claim settlement was paid to the insured, triggering the insurers right to take salvage title to the damaged property.',
    `vin` STRING COMMENT '17-character Vehicle Identification Number (VIN) for salvage vehicles, conforming to ISO 3779. Null for non-vehicle salvage items.. Valid values are `^[A-HJ-NPR-Z0-9]{17}$`',
    `year_manufactured` BIGINT COMMENT 'Four-digit model year or year of manufacture of the salvage item, used for ACV calculation and depreciation schedules.',
    CONSTRAINT pk_salvage_item PRIMARY KEY(`salvage_item_id`)
) COMMENT 'Tracks physical salvage property taken title to after a total-loss settlement. Records ACV at loss, salvage proceeds, disposal method (auction, scrap), and net salvage recovery credited back to the claim.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` (
    `lae_allocation_id` BIGINT COMMENT 'Unique surrogate primary key for each LAE allocation record in the Databricks Silver layer.',
    `adjuster_id` BIGINT COMMENT 'Reference to the claims adjuster responsible for the claim driving this LAE allocation. Supports adjuster-level LAE productivity and expense analysis.',
    `cat_event_id` BIGINT COMMENT 'Foreign key linking to reservespayments.cat_event. Business justification: LAE allocations for CAT events need proper FK linkage to cat_event master. The cat_code string becomes redundant when FK allows JOIN to cat_event.',
    `claim_id` BIGINT COMMENT 'Reference to the individual claim to which this LAE allocation is attributed. Supports claim-level LAE analysis and combined ratio reporting.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: LAE allocation amounts require currency reference for expense accounting, statutory exhibits, and multi-currency operations. Replaces denormalized currency_code.',
    `fac_certificate_id` BIGINT COMMENT 'Foreign key linking to reinsurance.fac_certificate. Business justification: LAE allocation on facultatively reinsured claims requires identifying the fac certificate to calculate recoverable ALAE per certificate terms.',
    `insured_entity_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_entity. Business justification: Entity-level LAE tracking is required for large deductible programs, self-insured retention reconciliation, and experience modification calculations where LAE is included in',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: ALAE allocation to locations supports territorial expense ratio analysis, rate adequacy studies, and Schedule P reporting; location characteristics drive expense patterns.',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Auto claim expenses (appraisal, towing, storage) are allocated to vehicles for total incurred calculation, loss ratio analysis, and vehicle-level profitability assessment.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: LAE must be allocated to LOB for statutory expense exhibits, profitability analysis, and rate adequacy testing. Lob_code denormalizes LOB master.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: LAE (legal fees, adjuster costs) must be allocated to coverages for Schedule P stat reporting, reinsurance recovery (treaty terms specify ALAE/ULAE treatment by coverage)',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which the claim and associated LAE costs arise, enabling policy-level expense ratio analysis.',
    `reversed_allocation_id` BIGINT COMMENT 'Reference to the original LAE allocation record that this record reverses. Null when reversal_indicator is false. Supports audit trail and GL reconciliation.',
    `service_vendor_id` BIGINT COMMENT 'Reference to the external vendor (law firm, independent adjuster, expert witness, salvage company) whose invoice generated this ALAE cost.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: LAE allocation to state is required for statutory expense exhibits, state-specific cost analysis, and regulatory reporting. State_code is denormalized.',
    `accident_year` BIGINT COMMENT 'Calendar year in which the loss event (date of loss) occurred. Used for accident-year LAE development triangles in actuarial reserving.',
    `accounting_basis` STRING COMMENT 'Accounting framework under which this LAE allocation is recorded: Statutory (STAT/SAP), US GAAP, or IFRS 17 for international entities.. Valid values are `STAT|GAAP|IFRS`',
    `accounting_period_date` DATE COMMENT 'First day of the accounting period (month/quarter/year) to which this LAE allocation is posted in the general ledger for statutory and GAAP financials.',
    `allocated_amount` DECIMAL(18,2) COMMENT 'Gross allocated LAE amount in the reporting currency for this record. Core input to combined ratio (CR) and expense ratio (ER) calculations.',
    `allocation_basis` STRING COMMENT 'Statistical basis used when applying a pro-rata or exposure-based allocation method, such as claim count or earned premium (EP) weighting.. Valid values are `claim_count|earned_premium|incurred_loss|paid_loss|exposure_unit`',
    `allocation_date` DATE COMMENT 'The business event date on which the LAE cost was allocated to the claim or claim group. Used for period-matching in statutory and GAAP reporting.',
    `allocation_method` STRING COMMENT 'Method used to allocate LAE costs to claims or claim groups. Drives actuarial credibility and combined ratio (CR) accuracy per NAIC and FASB guidance.. Valid values are `direct|pro_rata|exposure_based|claim_count|paid_loss|actuarial`',
    `allocation_number` STRING COMMENT 'Externally visible business identifier for this LAE allocation record, used in bordereaux, statutory filings, and actuarial reports.. Valid values are `^LAE-[0-9]{4}-[0-9]{8}$`',
    `allocation_status` STRING COMMENT 'Current workflow state of the LAE allocation record, controlling whether it is included in statutory and GAAP financial reporting.. Valid values are `draft|pending|approved|posted|reversed|voided`',
    `authorization_date` DATE COMMENT 'Date on which the required authorization level approved this LAE allocation, providing an audit trail for SOX and regulatory compliance.',
    `authorization_level` STRING COMMENT 'Approval authority level required and applied for this LAE allocation, supporting SOX internal controls and claims expense governance.. Valid values are `adjuster|supervisor|manager|director|executive`',
    `company_naic_code` STRING COMMENT 'Five-digit NAIC company code identifying the writing company for statutory LAE reporting in the Annual Statement and Schedule P.. Valid values are `^[0-9]{5}$`',
    `cost_center_code` STRING COMMENT 'General ledger cost center to which the LAE expense is charged, enabling departmental expense tracking in Oracle Financials GL or SAP FI.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this LAE allocation record was first created in the system, providing the audit trail creation point for SOX and data governance.',
    `expense_category_code` STRING COMMENT 'Standardized code classifying the type of LAE expense (e.g., legal fees, expert witness, adjuster fees, salvage/subrogation costs). [ENUM-REF-CANDIDATE: legal|adjuster|expert_witness|salvage_subro|medical_review|other — promote to reference product]',
    `expense_category_description` STRING COMMENT 'Human-readable description of the LAE expense category, providing context for actuarial and finance reporting beyond the category code.',
    `gl_account_code` STRING COMMENT 'Chart-of-accounts code in Oracle Financials GL or SAP FI to which this LAE allocation is posted for GAAP and statutory financial reporting.',
    `is_cat_event` BOOLEAN COMMENT 'Indicates whether this LAE allocation is associated with a catastrophe (CAT) event, enabling separate CAT LAE tracking for reinsurance and regulatory reporting.',
    `lae_type` STRING COMMENT 'Distinguishes Allocated Loss Adjustment Expense (ALAE) directly tied to a specific claim from Unallocated Loss Adjustment Expense (ULAE) spread across claim groups.. Valid values are `ALAE|ULAE`',
    `lob_description` STRING COMMENT 'Human-readable description of the line of business associated with this LAE allocation, supporting management reporting and analytics.',
    `net_lae_amount` DECIMAL(18,2) COMMENT 'Net LAE amount after deducting reinsurance recoverables. Used in net combined ratio (CR) and net expense ratio (ER) statutory and GAAP reporting.',
    `notes` STRING COMMENT 'Free-text notes from the adjuster, actuary, or finance team providing context for the LAE allocation decision, methodology choice, or unusual circumstances.',
    `policy_year` BIGINT COMMENT 'Year in which the policy was effective at the time of loss. Used for policy-year LAE development analysis and rate adequacy studies.',
    `report_year` BIGINT COMMENT 'Calendar year in which the claim was first reported (FNOL). Supports report-year LAE development triangles for IBNR and ULAE estimation.',
    `reversal_indicator` BOOLEAN COMMENT 'Indicates this record is a reversal of a previously posted LAE allocation. When true, the reversed_allocation_id identifies the original record.',
    `ri_recoverable_lae_amount` DECIMAL(18,2) COMMENT 'Portion of the allocated LAE recoverable from reinsurers under treaty or facultative (FAC) agreements, used to derive net LAE for statutory reporting.',
    `service_type` STRING COMMENT 'Type of professional service generating the LAE cost. Supports granular expense ratio (ER) analysis by service category. [ENUM-REF-CANDIDATE: promote if values exceed 6]',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record that originated this LAE allocation record, supporting data lineage and reconciliation.. Valid values are `GUIDEWIRE_CC|DUCK_CREEK_CLAIMS|SAPIENS_IDIT|ORACLE_AP|SAP_FI|MANUAL`',
    `source_transaction_ref` STRING COMMENT 'Native transaction identifier from the originating source system (e.g., Guidewire ClaimCenter payment ID), enabling cross-system audit and reconciliation.',
    `stat_line_code` STRING COMMENT 'NAIC statutory line code used to map this LAE allocation to the correct line in the Annual Statement Expense Exhibit and Schedule P.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this LAE allocation record, supporting change tracking, audit compliance, and Silver layer incremental loads.',
    `vendor_invoice_number` STRING COMMENT 'Invoice reference number from the external vendor providing LAE services, used for accounts payable reconciliation and audit trail.',
    CONSTRAINT pk_lae_allocation PRIMARY KEY(`lae_allocation_id`)
) COMMENT 'Allocates LAE (ALAE and ULAE) costs to individual claims or claim groups. Captures expense category, allocated amount, allocation method, and period. Supports combined ratio (CR) and expense ratio (ER) reporting.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` (
    `payment_authority_id` BIGINT COMMENT 'Unique surrogate identifier for a payment authority limit record governing adjuster disbursement thresholds in ClaimCenter.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Payment authority limits require currency specification for multi-jurisdiction operations and proper approval threshold enforcement. Currency_code is denormalized.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Payment authority limits vary by line of business risk profile, loss severity patterns, and underwriting complexity. Replaces lob_code denormalization.',
    `payment_adjuster_id` BIGINT COMMENT 'Reference to the claims adjuster or adjuster role to whom this payment authority limit is assigned.',
    `payment_delegated_by_adjuster_id` BIGINT COMMENT 'Reference to the supervisor or manager who granted this delegated payment authority, providing audit trail for SOX compliance.',
    `payment_escalation_adjuster_id` BIGINT COMMENT 'Reference to the next-level adjuster, supervisor, or manager to whom payments exceeding this authority limit are automatically escalated.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Payment authority limits may vary by state regulatory requirements, licensing jurisdiction, and state-specific approval thresholds. Replaces state_code denormalization.',
    `tpa_id` BIGINT COMMENT 'Reference to the TPA entity when this authority record governs payment limits for a third-party administrator handling claims on behalf of the insurer.',
    `adjuster_role` STRING COMMENT 'Functional role of the adjuster to which this authority applies, e.g., Staff Adjuster, Senior Adjuster, Supervisor, Manager. [ENUM-REF-CANDIDATE: staff_adjuster|senior_adjuster|supervisor|manager|director|vp — promote to reference product]',
    `advance_payment_allowed` BOOLEAN COMMENT 'Indicates whether the adjuster is authorized to issue advance payments on open claims under this authority record.',
    `advance_payment_limit` DECIMAL(18,2) COMMENT 'Maximum dollar amount of an advance payment the adjuster may issue on an open claim when advance_payment_allowed is true.',
    `aggregate_payment_limit` DECIMAL(18,2) COMMENT 'Maximum cumulative payment amount the adjuster may approve on a single claim across all transactions before escalation is required.',
    `approval_workflow_code` STRING COMMENT 'Code referencing the specific ClaimCenter approval workflow rule set triggered when a payment approaches or exceeds this authority limit.',
    `approved_timestamp` TIMESTAMP COMMENT 'Timestamp when this payment authority record was formally approved by the designated authority owner, distinct from creation and update timestamps.',
    `authority_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this payment authority rule, used in bordereaux and audit references.. Valid values are `^PA-[A-Z0-9]{4,20}$`',
    `authority_level` STRING COMMENT 'Hierarchical authority tier assigned to this record, from Level 1 (lowest, e.g., staff adjuster) to Level 5 (highest, e.g., VP Claims). Drives escalation routing.. Valid values are `level_1|level_2|level_3|level_4|level_5`',
    `authority_name` STRING COMMENT 'Human-readable label for this payment authority limit record, e.g., Senior Adjuster BI Auto Limit.',
    `authority_notes` STRING COMMENT 'Free-text notes capturing special conditions, exceptions, or context for this payment authority record, e.g., temporary elevation during CAT response.',
    `authority_status` STRING COMMENT 'Current lifecycle state of the payment authority record, controlling whether it is enforceable in the claims payment workflow.. Valid values are `active|inactive|pending|suspended|expired`',
    `cat_event_limit` DECIMAL(18,2) COMMENT 'Special single-payment authority limit applicable during a declared CAT event, which may differ from the standard single_payment_limit.',
    `claim_office_code` STRING COMMENT 'Internal code identifying the claims handling office or unit to which this authority limit is scoped. Null indicates enterprise-wide applicability.',
    `claim_type` STRING COMMENT 'Distinguishes whether this authority applies to first-party, third-party, subrogation recovery payments, or all claim types.. Valid values are `first_party|third_party|subrogation|all`',
    `company_naic_code` STRING COMMENT 'Five-digit NAIC company code identifying the legal entity whose claims payment authority this record governs.. Valid values are `^[0-9]{5}$`',
    `coverage_type` STRING COMMENT 'Coverage category scoping this authority, e.g., BI, PD, PIP, MedPay, UM, UIM, APD, GL. Null indicates authority applies to all coverage types. [ENUM-REF-CANDIDATE: BI|PD|PIP|MedPay|UM|UIM|APD|GL|WC|PROP — promote to reference product]',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this payment authority record was first created in the system, providing audit trail for SOX and regulatory compliance.',
    `delegation_basis` STRING COMMENT 'Basis on which authority is delegated: by role (all holders of the role), individual (named adjuster), temporary delegation, TPA, or vendor.. Valid values are `role|individual|temporary|tpa|vendor`',
    `delegation_date` DATE COMMENT 'Date on which the payment authority was formally delegated or granted to the adjuster by the authorizing manager.',
    `dual_approval_threshold` DECIMAL(18,2) COMMENT 'Dollar amount at or above which dual approval is required for a payment, when requires_dual_approval is true.',
    `effective_date` DATE COMMENT 'Date on which this payment authority limit becomes enforceable in the claims payment workflow.',
    `escalation_path_description` STRING COMMENT 'Narrative description of the escalation chain for payments exceeding this authority, e.g., Supervisor → Manager → VP Claims.',
    `expiration_date` DATE COMMENT 'Date on which this payment authority limit ceases to be enforceable. Null indicates the authority is open-ended with no scheduled expiry.',
    `is_cat_authority` BOOLEAN COMMENT 'Indicates whether this authority record is specifically designated for CAT event claims handling, enabling surge-capacity payment processing.',
    `last_review_date` DATE COMMENT 'Date on which this payment authority record was most recently reviewed and approved by the designated authority owner.',
    `litigation_payment_allowed` BOOLEAN COMMENT 'Indicates whether this authority permits payment on litigated claims. Litigated claims often require elevated authority or legal department co-approval.',
    `next_review_date` DATE COMMENT 'Scheduled date by which this payment authority record must next be reviewed, computed from last_review_date and review_frequency.',
    `payment_type` STRING COMMENT 'Category of payment governed by this authority: indemnity loss, ALAE, general expense, recovery/subrogation, advance payment, or all types.. Valid values are `indemnity|alae|expense|recovery|advance|all`',
    `requires_dual_approval` BOOLEAN COMMENT 'Indicates whether payments at or near this authority limit require a second approver signature before disbursement, per SOX dual-control requirements.',
    `reserve_change_limit` DECIMAL(18,2) COMMENT 'Maximum dollar amount of a single reserve increase or decrease the adjuster may authorize without supervisor approval.',
    `review_frequency` STRING COMMENT 'Scheduled frequency at which this payment authority limit must be reviewed and reaffirmed by management per internal controls policy.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `settlement_authority_limit` DECIMAL(18,2) COMMENT 'Maximum total settlement amount the adjuster may approve to close a claim, distinct from single-payment limits.',
    `single_payment_limit` DECIMAL(18,2) COMMENT 'Maximum dollar amount the adjuster may approve for a single payment transaction without escalation. Core threshold enforced in ClaimCenter payment workflow.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this payment authority record originates, e.g., GUIDEWIRE_CC for ClaimCenter.. Valid values are `GUIDEWIRE_CC|DUCK_CREEK_CLAIMS|SAPIENS_IDIT|MANUAL`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this payment authority record, supporting change audit trail and SOX controls.',
    `version_number` BIGINT COMMENT 'Monotonically incrementing version counter for this payment authority record, enabling point-in-time reconstruction of authority limits for audit.',
    CONSTRAINT pk_payment_authority PRIMARY KEY(`payment_authority_id`)
) COMMENT 'Defines payment authority limits by adjuster role, LOB, and coverage type. Stores approval threshold, escalation path, effective date, and delegated authority level. Governs payment approval workflow in ClaimCenter.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` (
    `payment_approval_id` BIGINT COMMENT 'Unique surrogate identifier for the payment approval workflow record. Primary key for the payment_approval entity in the reserves_payments domain.',
    `cat_event_id` BIGINT COMMENT 'Foreign key linking to reservespayments.cat_event. Business justification: Payment approvals for CAT losses need proper FK linkage to cat_event master. The cat_event_code string becomes redundant when FK allows JOIN.',
    `claim_id` BIGINT COMMENT 'Reference to the claim against which the payment is being requested and routed for approval.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Payment approval amounts require currency reference for authority validation, multi-currency threshold comparison, and audit trail. Replaces currency_code denormalization.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Payment authority limits vary by location risk characteristics (cat zone, construction type, TIV); location linkage enables risk-based approval routing and large loss escalation.',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Auto total loss settlements require vehicle valuation data (ACV, stated value, loan amount) for approval authority determination and settlement validation.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Payment approval thresholds may differ by LOB complexity, loss severity, and risk characteristics. Lob_code is denormalized.',
    `payment_adjuster_id` BIGINT COMMENT 'Reference to the party record of the supervisor or manager designated to approve or deny this payment request.',
    `payment_authority_id` BIGINT COMMENT 'Foreign key linking to reservespayments.payment_authority. Business justification: Payment approvals should reference the specific payment_authority record that defines the approval threshold and escalation rules.',
    `payment_escalated_to_adjuster_id` BIGINT COMMENT 'Reference to the party record of the higher-level approver to whom the request was escalated when the original approver could not decide.',
    `payment_requestor_adjuster_id` BIGINT COMMENT 'Reference to the adjuster or staff member who initiated the payment approval request.',
    `payment_transaction_id` BIGINT COMMENT 'Reference to the payment transaction record requiring supervisory approval before disbursement can proceed.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Payment approvals may require state-specific workflows for regulatory compliance, licensing requirements, and jurisdictional authority validation. State_code is denormalized.',
    `approval_channel` STRING COMMENT 'Method or channel through which the approver rendered their decision (system workflow, email, phone, in-person, or delegated authority).. Valid values are `system|email|phone|in_person|delegated`',
    `approval_reference_number` STRING COMMENT 'Externally visible alphanumeric reference number uniquely identifying this approval request, used in correspondence and audit trails.. Valid values are `^PA-[0-9]{4}-[0-9]{8}$`',
    `approval_status` STRING COMMENT 'Current workflow state of the payment approval request. Drives downstream disbursement eligibility and audit reporting.. Valid values are `pending|approved|denied|escalated|withdrawn|expired`',
    `approval_type` STRING COMMENT 'Category of approval required based on payment amount, coverage type, or claim complexity. Determines routing and authority level.. Valid values are `supervisory|management|executive|committee|reinsurance|legal`',
    `approved_amount` DECIMAL(18,2) COMMENT 'Dollar amount authorized by the approver. May be less than requested amount in cases of partial approval. Null if not yet decided.',
    `claim_office_code` STRING COMMENT 'Code identifying the claims handling office or unit responsible for the claim associated with this payment approval request.',
    `cost_center_code` STRING COMMENT 'Financial cost center code used to allocate the approved payment expense to the appropriate business unit for management reporting.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time the payment approval record was first created in the system, used for audit trail and data lineage tracking.',
    `decision_timestamp` TIMESTAMP COMMENT 'Date and time the approver rendered a final decision (approved, denied, or escalated) on the payment request.',
    `denial_reason_code` STRING COMMENT 'Standardized code indicating the reason a payment approval was denied (e.g., coverage dispute, documentation incomplete, fraud referral). [ENUM-REF-CANDIDATE: promote to reference product]',
    `denial_reason_notes` STRING COMMENT 'Free-text narrative provided by the approver explaining the basis for denying the payment request, supplementing the denial reason code.',
    `escalation_level` BIGINT COMMENT 'Numeric count of escalation steps this approval request has undergone. Zero indicates no escalation; increments with each escalation event.',
    `expiry_date` DATE COMMENT 'Date after which the approval authorization expires if payment has not been disbursed. Prevents stale approvals from being executed.',
    `fraud_referral_flag` BOOLEAN COMMENT 'Indicates the payment was flagged for special investigation unit (SIU) review due to suspected fraud, requiring additional approval scrutiny.',
    `gl_account_code` STRING COMMENT 'GL account code to which the approved payment will be posted in the financial ledger upon disbursement.',
    `is_cat_loss` BOOLEAN COMMENT 'Indicates the payment is associated with a declared catastrophe event, which may trigger special authority or expedited approval protocols.',
    `is_large_loss` BOOLEAN COMMENT 'Flags the payment as a large loss requiring enhanced oversight, typically triggered when requested amount exceeds a defined threshold.',
    `is_override` BOOLEAN COMMENT 'Indicates whether this approval involved an override of a system-generated recommendation or standard authority limit.',
    `is_sla_breached` BOOLEAN COMMENT 'Indicates whether the approval decision was rendered after the SLA due date, triggering regulatory or operational escalation.',
    `litigation_flag` BOOLEAN COMMENT 'Indicates the underlying claim is in active litigation, requiring legal department review as part of the payment approval process.',
    `override_justification` STRING COMMENT 'Mandatory free-text explanation when an approver overrides a system recommendation or approves outside normal authority parameters.',
    `payment_category` STRING COMMENT 'Classification of the payment by loss category: indemnity, ALAE (Allocated Loss Adjustment Expense), ULAE, subrogation recovery, salvage, medical, or legal fee.',
    `reinsurance_recoverable_flag` BOOLEAN COMMENT 'Indicates a portion of the approved payment is expected to be recovered from a reinsurance treaty or facultative certificate.',
    `request_date` DATE COMMENT 'Calendar date on which the adjuster submitted the payment for supervisory or management approval.',
    `request_timestamp` TIMESTAMP COMMENT 'Precise date and time the payment approval request was submitted, used for SLA tracking and audit trail purposes.',
    `requested_amount` DECIMAL(18,2) COMMENT 'Gross dollar amount submitted by the adjuster for approval. May differ from final approved amount if partially approved.',
    `ri_recoverable_amount` DECIMAL(18,2) COMMENT 'Estimated dollar amount recoverable from reinsurers on the approved payment, used for net loss reporting and cession bordereaux.',
    `sir_deductible_amount` DECIMAL(18,2) COMMENT 'Dollar amount of the SIR or policy deductible to be applied against the approved payment, reducing the insurer net payment obligation.',
    `sla_due_date` DATE COMMENT 'Target date by which the approver must render a decision per internal SLA or state-mandated prompt payment requirements.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record that originated this payment approval record (e.g., Guidewire ClaimCenter, Duck Creek Claims).. Valid values are `GUIDEWIRE|DUCK_CREEK|SAPIENS|MANUAL`',
    `supporting_document_ref` STRING COMMENT 'Reference identifier to the document management system (e.g., OpenText or FileNet) for supporting documentation attached to the approval request.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time the payment approval record was last modified, supporting change tracking and data lineage in the Databricks Silver layer.',
    CONSTRAINT pk_payment_approval PRIMARY KEY(`payment_approval_id`)
) COMMENT 'Workflow record for payment requests requiring supervisory or management approval above adjuster authority. Tracks requested amount, approver, approval date, approval status, and override justification.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` (
    `payee_id` BIGINT COMMENT 'Unique surrogate identifier for the payee master record in the reserves and payments domain.',
    `country_id` BIGINT COMMENT 'Foreign key linking to shared.country. Business justification: International payees require country reference for OFAC screening, tax withholding rules, wire transfer routing, and sanctions compliance. Country_code denormalizes country master.',
    `preferred_currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Payee currency preference drives payment processing, FX conversion decisions, and international wire transfers. Preferred_currency_code denormalizes currency master data.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Payee address state is required for 1099 reporting, state tax withholding, escheatment rules, and regulatory compliance. State_code denormalizes state master.',
    `ach_authorization_date` DATE COMMENT 'Date on which the payee authorized ACH direct deposit, establishing the NACHA-required authorization record.',
    `address_line1` STRING COMMENT 'Primary street address line for the payee, used for check mailing and 1099 reporting.',
    `address_line2` STRING COMMENT 'Secondary address line (suite, unit, floor) for the payee mailing address.',
    `backup_withholding_flag` BOOLEAN COMMENT 'Indicates whether IRS-mandated backup withholding at the statutory rate applies to payments made to this payee.',
    `bank_account_number` STRING COMMENT 'Payee bank account number for ACH or wire disbursements. Stored encrypted; used only for EFT payment processing.',
    `bank_account_type` STRING COMMENT 'Type of bank account (checking or savings) used for ACH disbursements to this payee.. Valid values are `checking|savings`',
    `bank_name` STRING COMMENT 'Name of the financial institution holding the payee bank account, used for remittance documentation.',
    `bank_routing_number` STRING COMMENT 'ABA routing transit number identifying the payee financial institution for ACH and wire transfers.. Valid values are `^[0-9]{9}$`',
    `city` STRING COMMENT 'City of the payee mailing address used for check delivery and 1099 filing.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the payee master record was first created in the system, establishing the audit trail origin.',
    `dba_name` STRING COMMENT 'Trade or operating name used by the payee if different from the legal name. DBA is common for repair vendors and medical providers.',
    `email_address` STRING COMMENT 'Primary email address for the payee, used for electronic remittance advice (ERA) delivery and payment notifications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `entity_type` STRING COMMENT 'Indicates whether the payee is a natural person (individual) or a legal entity (organization), driving tax form and name field usage.. Valid values are `individual|organization`',
    `first_name` STRING COMMENT 'Given name of the individual payee. Populated only when entity_type is individual.',
    `form_1099_type` STRING COMMENT 'Specifies the IRS 1099 form variant applicable to this payee (e.g., 1099-MISC for miscellaneous income, 1099-NEC for non-employee compensation).. Valid values are `1099-MISC|1099-NEC|1099-B|1099-R|none`',
    `is_1099_reportable` BOOLEAN COMMENT 'Indicates whether payments to this payee must be reported to the IRS on Form 1099. Drives annual 1099 extract and filing.',
    `is_attorney` BOOLEAN COMMENT 'Indicates the payee is a legal representative (attorney or law firm) receiving settlement or fee payments on behalf of a claimant.',
    `is_claimant` BOOLEAN COMMENT 'Indicates the payee is a first-party or third-party claimant receiving indemnity loss payments.',
    `is_medical_provider` BOOLEAN COMMENT 'Indicates the payee is a licensed medical provider receiving direct payment for bodily injury (BI), PIP, or MedPay claim services.',
    `last_name` STRING COMMENT 'Family name of the individual payee. Populated only when entity_type is individual.',
    `legal_name` STRING COMMENT 'Full legal name of the payee as it must appear on checks and IRS 1099 forms. For individuals, this is the full name; for organizations, the registered legal name.',
    `license_number` STRING COMMENT 'State-issued professional or contractor license number for medical providers, repair vendors, or public adjusters.',
    `license_state` STRING COMMENT 'Two-letter state code of the jurisdiction that issued the payee professional or contractor license.. Valid values are `^[A-Z]{2}$`',
    `npi_number` STRING COMMENT 'CMS-issued National Provider Identifier for medical provider payees. Required for BI, PIP, and MedPay direct payment processing.. Valid values are `^[0-9]{10}$`',
    `number` STRING COMMENT 'Externally visible business identifier assigned to the payee, used on checks, EFT remittances, and 1099 filings.. Valid values are `^PAY-[0-9]{8,12}$`',
    `ofac_screen_date` DATE COMMENT 'Most recent date on which the payee was screened against the OFAC SDN and consolidated sanctions lists.',
    `ofac_screen_result` STRING COMMENT 'Outcome of the most recent OFAC sanctions screening. Confirmed matches block payment disbursement.. Valid values are `clear|potential_match|confirmed_match|pending_review`',
    `ofac_screened_flag` BOOLEAN COMMENT 'Indicates whether the payee has been screened against the OFAC Specially Designated Nationals (SDN) list prior to payment.',
    `payee_status` STRING COMMENT 'Current lifecycle status of the payee record, controlling eligibility to receive loss payments.. Valid values are `active|inactive|suspended|pending_verification|blocked`',
    `payee_type` STRING COMMENT 'Categorizes the payee by their role in the claim payment process. [ENUM-REF-CANDIDATE: claimant|attorney|medical_provider|repair_vendor|mortgagee|lienholder|public_adjuster|other — promote to reference product]',
    `payment_block_flag` BOOLEAN COMMENT 'Indicates that all payments to this payee are currently blocked, typically due to OFAC match, fraud investigation, or legal hold.',
    `payment_block_reason` STRING COMMENT 'Reason code explaining why payments to this payee are blocked. Required when payment_block_flag is true.. Valid values are `ofac_match|fraud_investigation|legal_hold|duplicate_payee|deceased|other`',
    `payment_method` STRING COMMENT 'Preferred disbursement method for loss payments to this payee (e.g., paper check, ACH direct deposit, wire transfer).. Valid values are `check|ach|wire|virtual_card|zelle`',
    `phone_number` STRING COMMENT 'Primary contact phone number for the payee, used for payment inquiries and check reissuance coordination.. Valid values are `^+?[0-9-s().]{7,20}$`',
    `postal_code` STRING COMMENT 'ZIP or ZIP+4 postal code for the payee mailing address.. Valid values are `^[0-9]{5}(-[0-9]{4})?$`',
    `source_system_code` STRING COMMENT 'Identifies the operational system of record from which this payee record originated (e.g., Guidewire ClaimCenter, Duck Creek Claims).. Valid values are `guidewire_cc|duck_creek_claims|sapiens_idit|manual|other`',
    `tax_id_type` STRING COMMENT 'Classifies the tax_id as SSN (Social Security Number), FEIN (Federal Employer Identification Number), ITIN, or EIN for correct IRS reporting.. Valid values are `SSN|FEIN|ITIN|EIN`',
    `tax_identification_number` STRING COMMENT 'IRS-issued Tax Identification Number: SSN for individuals or FEIN for organizations. Required for 1099 reporting and OFAC screening.. Valid values are `^[0-9]{9}$`',
    `tin_verification_date` DATE COMMENT 'Date on which the payee TIN was last verified through the IRS TIN matching program.',
    `tin_verified_flag` BOOLEAN COMMENT 'Indicates whether the payee TIN has been verified against IRS TIN matching program prior to issuing payment.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the payee master record, supporting audit and data lineage tracking.',
    `w9_received_date` DATE COMMENT 'Date on which the IRS Form W-9 was received from the payee, establishing the basis for backup withholding exemption.',
    `w9_received_flag` BOOLEAN COMMENT 'Indicates whether a completed IRS Form W-9 (Request for Taxpayer Identification Number) has been received from the payee.',
    CONSTRAINT pk_payee PRIMARY KEY(`payee_id`)
) COMMENT 'Master record of all parties eligible to receive loss payments: claimants, attorneys, medical providers, repair vendors, and mortgagees. Stores payee type, tax ID (SSN/FEIN), banking details, and 1099 reporting flag.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` (
    `reinsurance_recoverable_id` BIGINT COMMENT 'Unique surrogate identifier for each reinsurance recoverable record in the Pc_Insurance lakehouse silver layer.',
    `cat_event_id` BIGINT COMMENT 'Foreign key linking to reservespayments.cat_event. Business justification: Reinsurance recoverables for CAT events need proper FK linkage to cat_event master. The cat_event_code string becomes redundant when FK allows JOIN.',
    `claim_id` BIGINT COMMENT 'Reference to the underlying claim against which this reinsurance recoverable is tracked. Links to the claim master record in ClaimCenter or Duck Creek Claims.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: RI recoverable amounts require currency reference for bordereaux reporting, collection tracking, and multi-currency reinsurance accounting. Currency_code is denormalized.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Cat XL reinsurance recoveries are calculated based on location-level PML, treaty attachment points, and loss aggregation by event; location linkage enables cession calculation',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: RI recoverables must track LOB for treaty application, bordereaux reporting, and reinsurance accounting. Lob_code denormalizes LOB master.',
    `occurrence_loss_id` BIGINT COMMENT 'Foreign key linking to reinsurance.occurrence_loss. Business justification: Recoverables arising from catastrophic occurrences must link to occurrence_loss for occurrence-level aggregation, treaty exhaustion tracking, and reinstatement premium',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Reinsurance treaties specify coverage scope, exclusions, and LAE treatment by coverage type.',
    `policy_id` BIGINT COMMENT 'Reference to the insurance policy under which the underlying claim was filed and the reinsurance cession applies.',
    `reinsurer_id` BIGINT COMMENT 'Reference to the reinsurer counterparty (party master) from whom the recoverable amount is due. Supports multi-reinsurer panel structures.',
    `ri_treaty_id` BIGINT COMMENT 'Reference to the reinsurance treaty or facultative (FAC) certificate under which this recoverable is ceded. Null for facultative if a separate fac_certificate_id is used.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: RI recoverables must track state for unauthorized reinsurer collateral requirements, state-specific credit rules, and regulatory reporting. State_code is denormalized.',
    `treaty_layer_id` BIGINT COMMENT 'Foreign key linking to reinsurance.treaty_layer. Business justification: Recoverables calculated against multi-layer treaties must identify the specific layer for accurate attachment/exhaustion tracking and layer-specific settlement.',
    `accident_year` BIGINT COMMENT 'The calendar year in which the loss event (date of loss) occurred. Used for actuarial loss development triangles and NAIC statutory Schedule F reporting.',
    `accounting_basis` STRING COMMENT 'Accounting framework under which this recoverable is recognized and reported: STAT (Statutory Accounting Principles per NAIC SAP), GAAP (US GAAP ASC 944), or IFRS17 for international entities.. Valid values are `STAT|GAAP|IFRS17`',
    `authorized_reinsurer_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer is authorized (licensed) in the cedants domicile state. Unauthorized reinsurers require collateral (LOC or trust) per NAIC Credit for Reinsurance Model Law.',
    `bordereaux_period` STRING COMMENT 'The quarterly or monthly bordereaux reporting period (e.g., 2024-Q1 or 2024-03) in which this recoverable was included in the cession bordereau submitted to the reinsurer.. Valid values are `^[0-9]{4}-(Q[1-4]|[0-9]{2})$`',
    `cat_event_indicator` BOOLEAN COMMENT 'Flags whether the underlying loss is associated with a catastrophe (CAT) event. Drives CAT XL treaty layer activation, PML tracking, and CAT bond recoverable reporting.',
    `cession_reference` STRING COMMENT 'The cession or bordereau line reference assigned by the reinsurance management system (SICS/ReinsuranceMaster) linking this recoverable to its originating cession transaction.',
    `collateral_held_amount` DECIMAL(18,2) COMMENT 'Amount of collateral (letter of credit, trust fund, or funds withheld) held from the reinsurer to secure the recoverable, required for unauthorized reinsurers under NAIC Credit for Reinsurance rules.',
    `collateral_type` STRING COMMENT 'Type of collateral arrangement securing the recoverable from an unauthorized reinsurer: letter of credit (LOC), trust fund, funds withheld, cash deposit, or none for authorized reinsurers.. Valid values are `letter_of_credit|trust_fund|funds_withheld|cash_deposit|none`',
    `collectability_status` STRING COMMENT 'Assessment of the likelihood of collecting the outstanding recoverable from the reinsurer. Drives NAIC Schedule F Part 3 aged-debt disclosure and allowance for uncollectible RI.. Valid values are `collectible|potentially_uncollectible|uncollectible|in_dispute`',
    `collected_amount` DECIMAL(18,2) COMMENT 'Cumulative amount actually received from the reinsurer to date against this recoverable. Used to compute the outstanding balance and monitor collection performance.',
    `company_naic_code` STRING COMMENT 'Five-digit NAIC company code of the Pc_Insurance legal entity (cedant) that holds this recoverable. Required for NAIC Schedule F statutory filing and multi-entity group reporting.. Valid values are `^[0-9]{5}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this reinsurance recoverable record was first created in the system of record. Supports audit trail, data lineage, and SOX compliance requirements.',
    `date_of_loss` DATE COMMENT 'The date on which the insured loss event occurred (DOL). Used to determine treaty year applicability and to match the recoverable to the correct reinsurance period.',
    `dispute_reason` STRING COMMENT 'Free-text or coded description of the reason the reinsurer has disputed this recoverable (e.g., coverage interpretation, late reporting, policy conditions). Populated when collectability_status is in_dispute.',
    `gl_account_code` STRING COMMENT 'GL account code in Oracle Financials or SAP FI to which this reinsurance recoverable asset is posted. Supports financial close, balance sheet reconciliation, and SOX controls.',
    `gross_alae_amount` DECIMAL(18,2) COMMENT 'Gross ALAE (Allocated Loss Adjustment Expense) incurred on the underlying claim before reinsurance. Included in recoverable calculations where the treaty covers LAE.',
    `gross_loss_amount` DECIMAL(18,2) COMMENT 'Total gross incurred loss amount (paid plus outstanding case reserve) before any reinsurance recovery. Represents the cedants 100% share prior to cession. Basis for RI share calculation.',
    `last_collection_date` DATE COMMENT 'Date of the most recent cash receipt from the reinsurer against this recoverable. Used for aged-debt analysis and NAIC Schedule F Part 3 overdue recoverable identification.',
    `outstanding_recoverable_amount` DECIMAL(18,2) COMMENT 'Net amount still due from the reinsurer, calculated as total RI recoverable amount minus collected amount. Key balance sheet asset for STAT and GAAP reporting.',
    `policy_year` BIGINT COMMENT 'The year in which the policy that generated the underlying loss was written or incepted. Used alongside accident year for treaty period matching and bordereaux processing.',
    `recoverable_number` STRING COMMENT 'Externally-known business reference number uniquely identifying this recoverable record, used in bordereaux submissions and reinsurer correspondence.. Valid values are `^RI-REC-[0-9]{10}$`',
    `recoverable_status` STRING COMMENT 'Current lifecycle status of the recoverable. Drives collectability monitoring, aged-debt reporting, and STAT/GAAP balance sheet presentation. [ENUM-REF-CANDIDATE: open|collected|partially_collected|disputed|written_off|closed — promote to reference. Valid values are `open|collected|partially_collected|disputed|written_off|closed`',
    `recoverable_type` STRING COMMENT 'Classifies the nature of the recoverable: paid loss, case reserve (OCR), IBNR, ALAE, ULAE, or salvage/subrogation. Drives actuarial and statutory schedule presentation.. Valid values are `paid_loss|case_reserve|ibnr|alae|ulae|salvage_subrogation`',
    `reinsurance_type` STRING COMMENT 'Indicates whether the recoverable arises under a proportional/non-proportional treaty arrangement or a facultative (FAC) certificate placed on a specific risk.. Valid values are `treaty|facultative`',
    `reinsurer_credit_rating` STRING COMMENT 'A.M. Best or S&P financial strength rating of the reinsurer at the valuation date. Used to assess collectability risk and support NAIC Schedule F Part 3 disclosures.',
    `reinsurer_naic_code` STRING COMMENT 'Five-digit NAIC company code assigned to the reinsurer. Required for NAIC Schedule F statutory reporting and state DOI filings identifying authorized vs. unauthorized reinsurers.. Valid values are `^[0-9]{5}$`',
    `retention_amount` DECIMAL(18,2) COMMENT 'The cedants net retained loss amount after cession, representing the portion of gross loss not recoverable from the reinsurer. Equals gross loss minus RI recoverable loss amount.',
    `ri_recoverable_alae_amount` DECIMAL(18,2) COMMENT 'The ALAE portion of the total reinsurance recoverable, calculated as gross ALAE multiplied by the RI share where the treaty includes LAE coverage.',
    `ri_recoverable_loss_amount` DECIMAL(18,2) COMMENT 'The gross loss amount multiplied by the RI share percentage, representing the total loss amount recoverable from the reinsurer under this cession before any collections.',
    `ri_recoverable_total_amount` DECIMAL(18,2) COMMENT 'Sum of RI recoverable loss and RI recoverable ALAE amounts. Represents the total gross amount due from the reinsurer before collections and any collectability adjustments.',
    `ri_share_percent` DECIMAL(7,4) COMMENT 'The percentage of the gross loss ceded to the reinsurer under the applicable treaty or FAC certificate. For QS treaties this is the cession rate; for XOL it reflects the layer participation.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this recoverable record originated (e.g., SICS, Sapiens ReinsuranceMaster, Guidewire ClaimCenter). Supports data lineage.. Valid values are `SICS|REINS_MASTER|GUIDEWIRE_CC|DUCK_CREEK|SAPIENS_IDIT`',
    `treaty_type` STRING COMMENT 'Structure of the reinsurance arrangement: QS (Quota Share), XOL (Excess of Loss), CAT XL (Catastrophe Excess of Loss), surplus share, or facultative-obligatory.. Valid values are `quota_share|excess_of_loss|cat_xl|surplus_share|facultative_obligatory`',
    `uncollectible_amount` DECIMAL(18,2) COMMENT 'Amount of the outstanding recoverable deemed uncollectible due to reinsurer insolvency, dispute, or credit impairment. Reduces the net asset on the NAIC Schedule F Part 3 aged analysis.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this reinsurance recoverable record. Used for incremental ETL processing, change tracking, and audit trail in the Snowflake lakehouse.',
    `valuation_date` DATE COMMENT 'The as-of date at which the recoverable amounts (gross loss, RI share, collected) are evaluated. Aligns with actuarial valuation periods and quarterly STAT close cycles.',
    CONSTRAINT pk_reinsurance_recoverable PRIMARY KEY(`reinsurance_recoverable_id`)
) COMMENT 'Tracks amounts recoverable from reinsurers on paid and reserved losses under treaty and facultative (FAC) agreements. Records cession reference, gross loss, RI share, collected amount, and collectability status.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` (
    `structured_settlement_id` BIGINT COMMENT 'Unique surrogate identifier for the structured settlement record. Primary key for this entity.',
    `claim_id` BIGINT COMMENT 'Reference to the underlying claim for which this structured settlement was established in lieu of a lump-sum indemnity payment.',
    `claimant_id` BIGINT COMMENT 'Reference to the party record for the claimant or payee who is the beneficiary of the structured settlement periodic payments.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Structured settlement amounts require currency reference for present value calculation, annuity pricing, and financial reporting. Replaces denormalized currency_code.',
    `insured_entity_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_entity. Business justification: Workers compensation structured settlements require employer entity data for qualified assignment documentation, tax reporting, and experience modification calculation of present',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Structured settlements require LOB classification for financial reporting, profitability analysis, and management reporting. Replaces lob_code denormalization.',
    `payment_transaction_id` BIGINT COMMENT 'Reference to the originating payment transaction record that was converted or replaced by this structured settlement agreement.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Structured settlements are established under specific liability coverages (typically bodily injury).',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Structured settlements require state reference for court approval requirements, state tax treatment, and regulatory compliance. Replaces state_code denormalization.',
    `accident_year` BIGINT COMMENT 'Calendar year in which the loss event occurred, used for actuarial loss development, statutory reporting, and reserve triangulation.',
    `accounting_basis` STRING COMMENT 'Accounting framework under which the structured settlement liability is measured and reported: Statutory (STAT), US GAAP, or IFRS 17.. Valid values are `STAT|GAAP|IFRS17`',
    `agreement_date` DATE COMMENT 'Date on which the structured settlement agreement was formally executed and signed by all parties.',
    `annuity_contract_number` STRING COMMENT 'Policy or contract number assigned by the annuity provider for the annuity contract that funds the structured settlement periodic payments.',
    `annuity_cost_amount` DECIMAL(18,2) COMMENT 'Actual premium paid to the annuity provider to fund the structured settlement annuity contract, representing the insurers cost of settlement.',
    `annuity_provider_naic_code` STRING COMMENT 'National Association of Insurance Commissioners (NAIC) company code for the annuity provider issuing the structured settlement annuity contract.. Valid values are `^[0-9]{5}$`',
    `annuity_provider_name` STRING COMMENT 'Legal name of the life insurance company that issues and funds the annuity contract underlying the structured settlement.',
    `broker_name` STRING COMMENT 'Name of the structured settlement consultant or broker who facilitated the placement of the annuity and negotiation of the settlement terms.',
    `claimant_tax_identification_number` STRING COMMENT 'Social Security Number (SSN) or Federal Employer Identification Number (FEIN) of the claimant for IRS tax reporting on structured settlement payments.',
    `cola_rate` DECIMAL(6,4) COMMENT 'Annual cost-of-living adjustment (COLA) rate applied to periodic payments, expressed as a decimal (e.g., 0.0300 for 3%). Zero if no COLA applies.',
    `company_naic_code` STRING COMMENT 'Five-digit NAIC company code for the Pc_Insurance legal entity that is the settling insurer and obligor under this structured settlement.. Valid values are `^[0-9]{5}$`',
    `court_approval_date` DATE COMMENT 'Date on which a court of competent jurisdiction approved the structured settlement agreement, required for minor or incapacitated claimants.',
    `court_approval_required_flag` BOOLEAN COMMENT 'Indicates whether court approval is required for this structured settlement, typically for minor or incapacitated claimants under state law.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this structured settlement record was first created in the system of record.',
    `date_of_loss` DATE COMMENT 'Date on which the insured loss event occurred that gave rise to the claim settled through this structured settlement agreement.',
    `discount_rate` DECIMAL(6,4) COMMENT 'Actuarial discount rate used to calculate the present value of future periodic payments for reserving and financial reporting purposes.',
    `effective_date` DATE COMMENT 'Date on which the structured settlement becomes binding and periodic payments are scheduled to commence.',
    `gl_account_code` STRING COMMENT 'General Ledger (GL) account code in Oracle Financials or SAP FI to which the structured settlement liability and annuity cost are posted.',
    `guarantee_period_years` BIGINT COMMENT 'Number of years for which periodic payments are guaranteed regardless of the annuitants survival, providing a minimum payment floor.',
    `payment_end_date` DATE COMMENT 'Date on which the last scheduled periodic payment is due, or null for life-contingent settlements with no fixed end date.',
    `payment_frequency` STRING COMMENT 'Frequency at which periodic payments are disbursed to the claimant under the structured settlement schedule.. Valid values are `monthly|quarterly|semi_annual|annual|lump_sum|irregular`',
    `payment_start_date` DATE COMMENT 'Date on which the first periodic payment under the structured settlement is scheduled to be disbursed to the claimant.',
    `periodic_payment_amount` DECIMAL(18,2) COMMENT 'Base amount of each scheduled periodic payment disbursed to the claimant, before any cost-of-living adjustment (COLA) is applied.',
    `policy_number` STRING COMMENT 'Policy number of the insurance policy under which the claim giving rise to this structured settlement was filed.',
    `present_value_amount` DECIMAL(18,2) COMMENT 'Actuarially calculated present value of all future periodic payments under the structured settlement, used for reserving, accounting, and IFRS 17 liability measurement.',
    `qualified_assignment_company` STRING COMMENT 'Legal name of the qualified assignment company (QAC) that has assumed the periodic payment obligation from the insurer under IRC Section 130.',
    `qualified_assignment_flag` BOOLEAN COMMENT 'Indicates whether the periodic payment obligation has been assigned to a qualified assignment company under IRC Section 130, releasing the insurer from direct payment liability.',
    `ri_recoverable_amount` DECIMAL(18,2) COMMENT 'Portion of the annuity cost or present value recoverable from reinsurers under applicable treaty or facultative (FAC) arrangements.',
    `ri_recoverable_flag` BOOLEAN COMMENT 'Indicates whether any portion of the structured settlement present value or annuity cost is recoverable from a reinsurance treaty or facultative certificate.',
    `settlement_number` STRING COMMENT 'Externally-known unique reference number assigned to the structured settlement agreement, used in correspondence with claimants, annuity providers, and qualified assignment companies.. Valid values are `^SS-[0-9]{4}-[0-9]{8}$`',
    `settlement_status` STRING COMMENT 'Current lifecycle state of the structured settlement agreement. [ENUM-REF-CANDIDATE: draft|pending_approval|active|in_force|terminated|voided — promote to reference product]. Valid values are `draft|pending_approval|active|in_force|terminated|voided`',
    `settlement_type` STRING COMMENT 'Classification of the settlement payment structure. [ENUM-REF-CANDIDATE: periodic_payment|lump_sum_plus_periodic|life_contingent|life_with_period_certain|joint_and_survivor — promote to reference product]. Valid values are `periodic_payment|lump_sum_plus_periodic|life_contingent|life_with_period_certain|joint_and_survivor`',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this structured settlement record was sourced (e.g., Guidewire ClaimCenter, Duck Creek Claims).. Valid values are `GUIDEWIRE_CC|DUCK_CREEK_CLAIMS|SAPIENS_IDIT|MANUAL`',
    `termination_date` DATE COMMENT 'Date on which the structured settlement agreement ends, either upon expiry of the guarantee period, death of the annuitant, or other contractual termination event.',
    `total_payout_amount` DECIMAL(18,2) COMMENT 'Sum of all scheduled periodic payments over the full term of the structured settlement, representing the gross undiscounted obligation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this structured settlement record was last modified in the system of record.',
    CONSTRAINT pk_structured_settlement PRIMARY KEY(`structured_settlement_id`)
) COMMENT 'Records periodic-payment structured settlement agreements that replace lump-sum indemnity. Captures annuity provider, present value, payment schedule, guarantee period, and assignment to a qualified assignment company.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` (
    `development_triangle_id` BIGINT COMMENT 'Unique surrogate identifier for each loss development triangle record in the actuarial reserving system.',
    `cat_event_id` BIGINT COMMENT 'Foreign key linking to reservespayments.cat_event. Business justification: Development triangles for CAT events need proper FK linkage to cat_event master. The cat_event_code string becomes redundant when FK allows JOIN.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Development triangle amounts require currency reference for actuarial analysis, multi-currency consolidation, and rate filing support. Currency_code denormalizes currency master.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Development triangles are the primary actuarial tool for LOB-specific reserve analysis, loss development patterns, and rate adequacy. Lob_code is denormalized.',
    `reserve_study_id` BIGINT COMMENT 'Foreign key linking to reservespayments.reserve_study. Business justification: Development triangles are analytical artifacts produced as part of a reserve study.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Development triangles are segmented by state for rate filing support, state-specific loss development analysis, and regulatory actuarial exhibits. State_code is denormalized.',
    `accident_year` BIGINT COMMENT 'The calendar year in which the insured loss event occurred. Used as the primary origin period dimension in loss development triangles per actuarial convention.',
    `accounting_basis` STRING COMMENT 'Accounting framework under which the triangle data is prepared: STAT (Statutory Accounting Principles), GAAP (US Generally Accepted Accounting Principles), or IFRS.. Valid values are `STAT|GAAP|IFRS`',
    `actuarial_opinion_reference` STRING COMMENT 'Reference number or identifier of the actuarial opinion memorandum (AOM) or reserve study report in which this triangle was included and certified.',
    `actuarial_segment_code` STRING COMMENT 'Internal actuarial segment or homogeneous group code used to stratify the triangle for reserving purposes, such as by territory, class of business, or risk size.',
    `appointed_actuary_name` STRING COMMENT 'Name of the appointed actuary or actuarial analyst responsible for certifying or reviewing the ultimate loss estimates derived from this triangle.',
    `bf_ultimate_loss_estimate` DECIMAL(18,2) COMMENT 'Ultimate loss estimate produced by the Bornhuetter-Ferguson method, blending the development method projection with the a priori expected losses for this origin period.',
    `cat_event_indicator` BOOLEAN COMMENT 'Flag indicating whether this triangle cell includes catastrophe losses. When true, CAT losses may be separately triangulated or excluded for non-CAT reserve analysis.',
    `closed_claim_count` BIGINT COMMENT 'Number of closed claims for the origin period as of the evaluation date at the given development age. Used to compute closure rates and tail factor selections.',
    `company_naic_code` STRING COMMENT 'Five-digit NAIC company code identifying the legal insurance entity for which this triangle is prepared. Required for statutory Schedule P and annual statement filings.. Valid values are `^[0-9]{5}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this development triangle record was first created in the Silver layer of the Databricks lakehouse. Used for audit trail and data governance.',
    `cumulative_incurred_alae_amount` DECIMAL(18,2) COMMENT 'Total cumulative incurred ALAE (paid plus case reserves for ALAE) for the origin period at the given development age as of the evaluation date.',
    `cumulative_incurred_loss_amount` DECIMAL(18,2) COMMENT 'Total cumulative incurred losses (paid plus case reserves, excluding IBNR) for the origin period at the given development age as of the evaluation date.',
    `cumulative_ldf` DECIMAL(10,6) COMMENT 'Cumulative (age-to-ultimate) loss development factor for this origin period and development age. Product of all selected age-to-age LDFs from current age to ultimate.',
    `cumulative_paid_alae_amount` DECIMAL(18,2) COMMENT 'Total cumulative paid Allocated Loss Adjustment Expenses for the origin period at the given development age. Tracked separately from indemnity losses per NAIC STAT.',
    `cumulative_paid_loss_amount` DECIMAL(18,2) COMMENT 'Total cumulative paid losses (excluding LAE) for the origin period at the given development age as of the evaluation date. Core triangle cell value.',
    `development_age_months` BIGINT COMMENT 'Number of months elapsed from the start of the origin period (accident year, policy year, or report year) to the evaluation date. Standard triangle column dimension.',
    `ep_amount` DECIMAL(18,2) COMMENT 'Earned premium for the origin period used as the exposure base in loss ratio and Bornhuetter-Ferguson ultimate loss calculations for this triangle segment.',
    `evaluation_date` DATE COMMENT 'The as-of date at which loss data in this triangle cell was evaluated and extracted from the claims system. Defines the diagonal of the development triangle.',
    `evaluation_period_type` STRING COMMENT 'Frequency interval at which triangle evaluations are performed: annual, semi-annual, quarterly, or monthly. Determines the spacing of diagonals in the triangle.. Valid values are `annual|semi_annual|quarterly|monthly`',
    `expected_loss_ratio` DECIMAL(10,6) COMMENT 'A priori expected loss ratio used as the Bornhuetter-Ferguson method input for this origin period and LOB segment. Expressed as a decimal (e.g., 0.65 for 65%).',
    `ibner_amount` DECIMAL(18,2) COMMENT 'IBNER component representing expected adverse development on already-reported claims. Subset of total IBNR reflecting case reserve inadequacy for known claims.',
    `ibnr_amount` DECIMAL(18,2) COMMENT 'IBNR reserve for the origin period, calculated as ultimate loss estimate minus cumulative incurred losses. Represents unreported and development on reported claims.',
    `large_loss_indicator` BOOLEAN COMMENT 'Flag indicating whether this triangle cell includes large individual losses that may distort development patterns. Large losses are often capped or excluded in LDF selections.',
    `large_loss_threshold_amount` DECIMAL(18,2) COMMENT 'Dollar threshold above which an individual claim is classified as a large loss for this triangle segment. Used to define the capping level for LDF selection purposes.',
    `lob_description` STRING COMMENT 'Human-readable description of the Line of Business corresponding to lob_code, such as Commercial General Liability or Workers Compensation.',
    `open_claim_count` BIGINT COMMENT 'Number of open (unresolved) claims for the origin period as of the evaluation date at the given development age. Used in Bornhuetter-Ferguson and frequency-severity methods.',
    `policy_year` BIGINT COMMENT 'The year in which the policy that generated the loss was written or incepted. Used as an alternative origin period dimension alongside accident year.',
    `report_year` BIGINT COMMENT 'The calendar year in which the loss was first reported to the insurer. Used as an origin period dimension for claims-made and report-year triangles.',
    `reported_claim_count` BIGINT COMMENT 'Total number of claims reported (open plus closed) for the origin period as of the evaluation date. Used as the denominator in severity calculations.',
    `reserve_basis` STRING COMMENT 'Indicates whether the triangle data is on a gross (before reinsurance), net of reinsurance, or ceded basis. Critical for statutory and GAAP reserve reconciliation.. Valid values are `gross|net_of_ri|ceded`',
    `source_extract_timestamp` TIMESTAMP COMMENT 'Timestamp when the triangle data was extracted from the source actuarial reserving system. Used for data lineage, reconciliation, and audit trail in the Snowflake lakehouse.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system from which this triangle data was extracted (e.g., ARIUS for Milliman Arius, RESQ for WTW ResQ, CLAIMCENTER for Guidewire).. Valid values are `ARIUS|RESQ|CLAIMCENTER|DUCK_CREEK|SAPIENS|MANUAL`',
    `stat_line_code` STRING COMMENT 'NAIC statutory line of business code used for Schedule P and other statutory filings. Maps internal LOB codes to NAIC-defined reporting lines.',
    `tail_factor` DECIMAL(10,6) COMMENT 'Loss development factor applied beyond the last observed development age to project losses from the oldest observed age to ultimate. Critical for long-tail lines such as WC and CGL.',
    `triangle_reference_number` STRING COMMENT 'Externally-known alphanumeric identifier assigned to this triangle run or evaluation, used for cross-referencing actuarial reports and bordereaux.',
    `triangle_status` STRING COMMENT 'Lifecycle status of the development triangle record indicating whether it is a working draft, preliminary estimate, final actuarial selection, superseded, or archived.. Valid values are `draft|preliminary|final|superseded|archived`',
    `triangle_type` STRING COMMENT 'Classifies the triangle by the loss measure it tracks: paid loss, incurred loss, paid ALAE, incurred ALAE, paid LAE, or case reserve. [ENUM-REF-CANDIDATE: paid_loss|incurred_loss|paid_alae|incurred_alae|paid_lae|case_reserve — promote to reference product]. Valid values are `paid_loss|incurred_loss|paid_alae|incurred_alae|paid_lae|case_reserve`',
    `ultimate_loss_estimate` DECIMAL(18,2) COMMENT 'Projected ultimate loss amount for the origin period derived by applying the cumulative LDF to current paid or incurred losses. Primary output of the development method.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this development triangle record was last modified in the Silver layer. Tracks revisions to actuarial selections, corrections, or restatements.',
    `wp_amount` DECIMAL(18,2) COMMENT 'Gross written premium for the origin period associated with this triangle segment. Used as an alternative exposure base and for premium development triangles.',
    CONSTRAINT pk_development_triangle PRIMARY KEY(`development_triangle_id`)
) COMMENT 'Stores loss development triangle data by LOB, accident year, and development age. Captures cumulative paid loss, cumulative incurred loss, and earned premium for each evaluation period. Source: Milliman Arius / WTW ResQ.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` (
    `stat_reserve_exhibit_id` BIGINT COMMENT 'Unique surrogate identifier for each statutory reserve exhibit record in the NAIC Annual Statement Schedule P filing.',
    `cat_event_id` BIGINT COMMENT 'Foreign key linking to reservespayments.cat_event. Business justification: Statutory reserve exhibits for CAT events need proper FK linkage to cat_event master. The cat_event_code string becomes redundant when FK allows JOIN.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Statutory reserve exhibit amounts require currency specification for regulatory filings and multi-currency statutory reporting. Replaces currency_code denormalization.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Statutory reserve exhibits report reserves by NAIC line of business for regulatory filings and Schedule P. Lob_code denormalizes LOB master.',
    `reserve_evaluation_id` BIGINT COMMENT 'Reference to the actuarial reserve evaluation record that underpins this statutory exhibit entry.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Statutory reserve exhibits are filed by state with state-specific formats, reporting requirements, and regulatory deadlines. State_code denormalizes state master.',
    `accident_year` BIGINT COMMENT 'The accident year (AY) for which losses and reserves are reported on this exhibit row, per NAIC Schedule P segmentation.',
    `accounting_basis` STRING COMMENT 'Accounting framework under which this statutory exhibit is prepared: SAP (Statutory Accounting Principles), GAAP, or IFRS 17.. Valid values are `SAP|GAAP|IFRS17`',
    `actuarial_method` STRING COMMENT 'Primary actuarial method used to estimate ultimate losses and IBNR for this accident year and LOB. [ENUM-REF-CANDIDATE: promote to reference product if methods expand]',
    `actuarial_opinion_reference` STRING COMMENT 'Reference identifier linking this exhibit row to the appointed actuarys opinion and memorandum supporting the reserve adequacy certification.',
    `appointed_actuary_credential` STRING COMMENT 'Professional credential of the appointed actuary (e.g., FCAS, MAAA) as required by the NAIC Actuarial Opinion and Memorandum Regulation. [ENUM-REF-CANDIDATE: FCAS|ACAS|FSA|ASA|MAAA|PhD|other — 7 candidates stripped; promote to reference product]',
    `appointed_actuary_name` STRING COMMENT 'Full name of the appointed actuary who certified the reserve adequacy opinion supporting this statutory exhibit filing.',
    `cat_reserve_amount` DECIMAL(18,2) COMMENT 'Portion of the total reserve attributable to catastrophe (CAT) events for the accident year, disclosed separately for regulatory transparency.',
    `company_naic_code` STRING COMMENT 'Five-digit NAIC company code identifying the reporting insurance entity for statutory filing purposes.. Valid values are `^[0-9]{5}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this statutory reserve exhibit record was first created in the data platform, used for audit trail and data lineage.',
    `development_period_months` BIGINT COMMENT 'Number of months of development from the accident year origin to the valuation date, used to position the data point in the loss development triangle.',
    `ep_amount` DECIMAL(18,2) COMMENT 'Earned premium (EP) for the accident year used as the denominator in loss ratio calculations on this statutory exhibit.',
    `exhibit_reference_number` STRING COMMENT 'Externally-known alphanumeric identifier for this statutory reserve exhibit, used in DOI filings and NAIC Annual Statement submissions.. Valid values are `^STAT-[0-9]{4}-[A-Z0-9]{2,10}-[0-9]{4}$`',
    `exhibit_status` STRING COMMENT 'Current workflow state of the statutory reserve exhibit. [ENUM-REF-CANDIDATE: draft|under_review|certified|filed|amended|superseded — promote to reference product]. Valid values are `draft|under_review|certified|filed|amended|superseded`',
    `expected_loss_ratio` DECIMAL(10,6) COMMENT 'A priori expected loss ratio (ELR) used in Bornhuetter-Ferguson and Cape Cod actuarial methods for this accident year and LOB.',
    `filing_date` DATE COMMENT 'Date on which this statutory reserve exhibit was submitted to the NAIC or state DOI as part of the Annual Statement filing.',
    `filing_year` BIGINT COMMENT 'Calendar year of the NAIC Annual Statement filing to which this statutory reserve exhibit belongs (e.g., 2024).',
    `gross_case_reserve_amount` DECIMAL(18,2) COMMENT 'Outstanding case reserve (OCR) on a gross basis for known open claims in the accident year at the valuation date, before reinsurance.',
    `gross_ibnr_amount` DECIMAL(18,2) COMMENT 'Gross IBNR reserve for the accident year at the valuation date, representing estimated unreported losses and IBNER development, before reinsurance.',
    `gross_incurred_alae_amount` DECIMAL(18,2) COMMENT 'Gross incurred ALAE (paid ALAE plus ALAE case reserves) for the accident year at the valuation date, before reinsurance recoveries.',
    `gross_incurred_loss_amount` DECIMAL(18,2) COMMENT 'Gross incurred losses (paid plus case reserves) for the accident year at the valuation date, before reinsurance, per NAIC Schedule P reporting.',
    `gross_paid_alae_amount` DECIMAL(18,2) COMMENT 'Cumulative gross paid allocated loss adjustment expense (ALAE) for the accident year and development period, before reinsurance recoveries.',
    `gross_paid_loss_amount` DECIMAL(18,2) COMMENT 'Cumulative gross (before reinsurance) paid losses reported on this exhibit row for the accident year and development period, per NAIC Schedule P.',
    `gross_total_reserve_amount` DECIMAL(18,2) COMMENT 'Total gross reserve (case reserve plus IBNR) for the accident year at the valuation date, before reinsurance recoveries, as reported on the statutory exhibit.',
    `lob_description` STRING COMMENT 'Human-readable description of the NAIC line of business (LOB) reported on this exhibit row (e.g., Private Passenger Auto Liability, Workers Compensation).',
    `net_case_reserve_amount` DECIMAL(18,2) COMMENT 'Outstanding case reserve (OCR) on a net-of-reinsurance basis for the accident year at the valuation date.',
    `net_ibnr_amount` DECIMAL(18,2) COMMENT 'Net IBNR reserve (gross IBNR less reinsurance recoverable on IBNR) for the accident year at the valuation date.',
    `net_incurred_loss_amount` DECIMAL(18,2) COMMENT 'Net incurred losses (gross incurred less reinsurance recoverables) for the accident year at the valuation date, as reported on the statutory exhibit.',
    `net_loss_ratio` DECIMAL(10,6) COMMENT 'Net loss ratio (LR) for the accident year: net incurred losses divided by earned premium (EP), as reported on the statutory exhibit.',
    `net_paid_loss_amount` DECIMAL(18,2) COMMENT 'Cumulative net paid losses (gross paid losses less reinsurance recoveries received) for the accident year and development period.',
    `net_total_reserve_amount` DECIMAL(18,2) COMMENT 'Total net reserve (net case reserve plus net IBNR) for the accident year at the valuation date, as reported on the statutory exhibit.',
    `prior_valuation_date` DATE COMMENT 'The prior year-end valuation date used as the baseline for measuring reserve development on this statutory exhibit row.',
    `reserve_basis` STRING COMMENT 'The basis on which reserves are segmented and reported: accident year, policy year, or report year, per NAIC Schedule P requirements.. Valid values are `accident_year|policy_year|report_year`',
    `reserve_development_amount` DECIMAL(18,2) COMMENT 'Favorable or unfavorable reserve development for the accident year between the prior and current valuation dates, as disclosed on Schedule P.',
    `ri_recoverable_alae_amount` DECIMAL(18,2) COMMENT 'Estimated reinsurance recoverable on unpaid ALAE for the accident year at the valuation date.',
    `ri_recoverable_loss_amount` DECIMAL(18,2) COMMENT 'Estimated reinsurance (RI) recoverable on unpaid losses for the accident year at the valuation date, reducing gross reserves to net.',
    `schedule_p_part` STRING COMMENT 'Identifies the specific part of NAIC Annual Statement Schedule P this row populates (e.g., Part1=Summary, Part2=Paid, Part3=Incurred, Part4=Bulk/IBNR).. Valid values are `Part1|Part2|Part3|Part4|Part5|Part6`',
    `selected_ldf` DECIMAL(10,6) COMMENT 'Actuarially selected cumulative loss development factor (LDF) applied to current incurred losses to project ultimate losses for this accident year.',
    `ulr` DECIMAL(10,6) COMMENT 'Ultimate loss ratio (ULR) for the accident year: actuarially selected ultimate losses divided by earned premium (EP), per the actuarial opinion.',
    `ultimate_loss_estimate` DECIMAL(18,2) COMMENT 'Actuarially selected ultimate loss estimate for the accident year, representing the expected total cost of all claims including future development.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this statutory reserve exhibit record, supporting audit trail and amendment tracking.',
    `valuation_date` DATE COMMENT 'The as-of date at which reserves are measured and reported on this statutory exhibit, typically December 31 of the filing year.',
    CONSTRAINT pk_stat_reserve_exhibit PRIMARY KEY(`stat_reserve_exhibit_id`)
) COMMENT 'Statutory reserve exhibit prepared for NAIC Annual Statement Schedule P and state DOI filings. Captures net and gross reserve positions, loss ratio, and actuarial opinion reference by LOB and accident year.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` (
    `cat_event_id` BIGINT COMMENT 'Unique identifier for the cat_event data product (auto-inserted during validation).',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Catastrophe loss estimates require currency reference for industry loss comparisons, reinsurance treaty triggers, and financial reporting. Currency_code is denormalized.',
    `ri_treaty_id` BIGINT COMMENT 'Foreign key reference to the reinsurance treaty triggered by this catastrophe event, if applicable.',
    `affected_counties` STRING COMMENT 'Comma-separated list of county FIPS codes or county names within affected states where losses occurred.',
    `affected_states` STRING COMMENT 'Comma-separated list of US state codes where the catastrophe event caused insured losses (e.g., FL,GA,AL).',
    `alae_amount` DECIMAL(18,2) COMMENT 'Total allocated loss adjustment expenses incurred for claims associated with this catastrophe event, in USD.',
    `cat_bond_triggered_flag` BOOLEAN COMMENT 'Indicates whether this catastrophe event triggered any catastrophe bond or insurance-linked securities held by the company.',
    `cat_close_date` DATE COMMENT 'Date when the catastrophe event was officially closed for new claim associations. Nullable if still open.',
    `cat_code` STRING COMMENT 'Industry-standard catastrophe event code assigned by ISO Property Claim Services (PCS) or similar authority. Format: 2-letter state/region + 6-digit serial.. Valid values are `^[A-Z]{2}[0-9]{6}$`',
    `cat_event_status` STRING COMMENT 'Current lifecycle status of the catastrophe event for claims reporting and aggregation purposes.. Valid values are `open|closed|pending_closure|reopened|archived`',
    `cat_open_date` DATE COMMENT 'Date when the catastrophe event was officially opened for claims reporting and tracking by the insurer.',
    `cat_xl_triggered_flag` BOOLEAN COMMENT 'Indicates whether this catastrophe event triggered the companys catastrophe excess of loss reinsurance treaty.',
    `closed_claim_count` BIGINT COMMENT 'Total number of claims associated with this catastrophe event that have been closed with payment or denial.',
    `company_loss_estimate_amount` DECIMAL(18,2) COMMENT 'Estimated total gross loss for this insurer from the catastrophe event, in USD. Updated as claims develop.',
    `company_ultimate_loss_amount` DECIMAL(18,2) COMMENT 'Actuarial estimate of ultimate net loss to the company after all claims are settled and reinsurance recoveries applied, in USD.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this catastrophe event record was first created in the system.',
    `declaration_date` DATE COMMENT 'Date when the catastrophe event was officially declared by the company for internal tracking and reporting purposes.',
    `event_description` STRING COMMENT 'Detailed narrative description of the catastrophe event, including meteorological or geological characteristics and impact summary.',
    `event_end_date` DATE COMMENT 'Date when the catastrophe event concluded or ceased causing new losses. Nullable for ongoing events.',
    `event_start_date` DATE COMMENT 'Date when the catastrophe event began or first caused insured losses.',
    `geographic_scope` STRING COMMENT 'Classification of the catastrophe event geographic extent for exposure aggregation and reinsurance triggering.. Valid values are `local|regional|multi_state|national`',
    `ibnr_reserve_amount` DECIMAL(18,2) COMMENT 'Actuarial reserve estimate for losses incurred but not yet reported for this catastrophe event, in USD.',
    `industry_loss_estimate_amount` DECIMAL(18,2) COMMENT 'Estimated total insured loss across the entire insurance industry for this catastrophe event, in USD.',
    `industry_loss_estimate_date` DATE COMMENT 'Date when the industry loss estimate was published or last updated.',
    `industry_loss_estimate_source` STRING COMMENT 'Organization or entity that provided the industry loss estimate (e.g., ISO/PCS, AIR Worldwide, RMS).',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this catastrophe event record was last modified, reflecting the most recent claim or loss data update.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code identifying the legal entity reporting this catastrophe event for statutory purposes.. Valid values are `^[0-9]{5}$`',
    `cat_event_name` STRING COMMENT 'Common name or designation of the catastrophe event (e.g., Hurricane Katrina, California Wildfire 2020).',
    `net_loss_amount` DECIMAL(18,2) COMMENT 'Net incurred loss after reinsurance recoveries for this catastrophe event, in USD.',
    `open_claim_count` BIGINT COMMENT 'Total number of claims associated with this catastrophe event that remain open and under active adjustment.',
    `peril_type` STRING COMMENT 'Primary peril or cause of loss associated with the catastrophe event. [ENUM-REF-CANDIDATE: hurricane|tornado|wildfire|earthquake|flood|hail|winter_storm|wind|other — 9 candidates stripped; promote to reference product]',
    `pml_tier` STRING COMMENT 'Classification tier indicating the severity of the catastrophe event relative to the companys PML thresholds for reinsurance attachment.. Valid values are `tier_1|tier_2|tier_3|tier_4|non_pml`',
    `reported_claim_count` BIGINT COMMENT 'Total number of claims reported and associated with this catastrophe event as of the last update.',
    `ri_recoverable_amount` DECIMAL(18,2) COMMENT 'Total reinsurance recoverable amount expected or collected for losses from this catastrophe event, in USD.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system that created or manages this catastrophe event record (e.g., ClaimCenter, ISO/PCS feed).',
    `stat_reporting_required_flag` BOOLEAN COMMENT 'Indicates whether this catastrophe event meets thresholds requiring special statutory reporting to state insurance departments.',
    `total_case_reserve_amount` DECIMAL(18,2) COMMENT 'Sum of outstanding case reserves held for all open claims associated with this catastrophe event, in USD.',
    `total_incurred_loss_amount` DECIMAL(18,2) COMMENT 'Sum of paid losses and outstanding case reserves for all claims associated with this catastrophe event, in USD.',
    `total_paid_loss_amount` DECIMAL(18,2) COMMENT 'Sum of all loss payments made on claims associated with this catastrophe event, in USD.',
    `ulae_amount` DECIMAL(18,2) COMMENT 'Estimated unallocated loss adjustment expenses attributable to this catastrophe event, in USD.',
    CONSTRAINT pk_cat_event PRIMARY KEY(`cat_event_id`)
) COMMENT 'Catastrophe event master: CAT code (ISO/PCS), event name, peril type, affected states/counties, open/close dates, industry loss estimate, and PML tier. SSOT for CAT claim aggregation and CAT XL triggering.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study` (
    `reserve_study_id` BIGINT COMMENT 'Primary key for reserve_study',
    `accident_year` BIGINT COMMENT 'Calendar year in which the insured loss events occurred, used for cohort-based reserve analysis.',
    `actuarial_method` STRING COMMENT 'Actuarial technique applied in the study, such as chain ladder, Bornhuetter-Ferguson, expected loss ratio, or frequency-severity methods.',
    `actuary_credential` STRING COMMENT 'Professional actuarial designation held by the responsible actuary, such as Fellow or Associate of the Casualty Actuarial Society.',
    `actuary_name` STRING COMMENT 'Name of the credentialed actuary responsible for preparing and certifying the reserve study.',
    `alae_reserve_amount` DECIMAL(18,2) COMMENT 'Reserve for loss adjustment expenses directly attributable to individual claims, such as legal and expert fees.',
    `approval_date` DATE COMMENT 'Date when the reserve study was formally approved by management or the board for financial reporting.',
    `approved_by` STRING COMMENT 'Name or identifier of the executive or committee that approved the reserve study.',
    `case_reserve_amount` DECIMAL(18,2) COMMENT 'Sum of case reserves established by claims adjusters for known open claims as of the valuation date.',
    `claim_count` BIGINT COMMENT 'Number of claims included in the reserve study population for the specified cohort and coverage.',
    `closed_claim_count` BIGINT COMMENT 'Number of claims closed with payment or without payment as of the valuation date.',
    `confidence_level` DECIMAL(5,2) COMMENT 'Statistical confidence level percentage associated with the reserve estimate, typically ranging from 50 to 95 percent.',
    `coverage_type` STRING COMMENT 'Specific coverage or peril analyzed in the reserve study, providing granular segmentation within the line of business.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the reserve study record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in the reserve study.',
    `data_quality_rating` STRING COMMENT 'Actuarial assessment of the quality and credibility of the underlying claims data used in the reserve study.',
    `expected_loss_ratio` DECIMAL(7,4) COMMENT 'Ratio of expected ultimate losses to earned premium, used in Bornhuetter-Ferguson and expected loss ratio methods.',
    `ibnr_claim_count_estimate` BIGINT COMMENT 'Estimated number of claims incurred but not yet reported to the insurer as of the valuation date.',
    `ibnr_reserve_amount` DECIMAL(18,2) COMMENT 'Actuarial estimate of reserves for claims incurred but not yet reported, including development on known claims.',
    `line_of_business` STRING COMMENT 'Insurance line of business covered by this reserve study, such as commercial auto, workers compensation, general liability, or property.',
    `loss_development_factor` DECIMAL(10,4) COMMENT 'Multiplicative factor applied to paid or incurred losses to project ultimate losses, derived from historical development patterns.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the reserve study record was last modified or updated.',
    `open_claim_count` BIGINT COMMENT 'Number of claims still open and unpaid as of the valuation date, requiring case reserves.',
    `paid_loss_amount` DECIMAL(18,2) COMMENT 'Total loss payments made to date for the claims in the study population, excluding loss adjustment expenses.',
    `policy_year` BIGINT COMMENT 'Policy year for which reserves are being studied, representing the year policies were written.',
    `prior_reserve_amount` DECIMAL(18,2) COMMENT 'Reserve amount from the previous valuation or study, used for development and variance analysis.',
    `report_year` BIGINT COMMENT 'Calendar year in which claims were reported, used for report-year-based reserve development analysis.',
    `reserve_change_amount` DECIMAL(18,2) COMMENT 'Net change in reserve estimate from the prior valuation, indicating reserve strengthening or release.',
    `reserve_estimate_amount` DECIMAL(18,2) COMMENT 'Total reserve amount estimated by the study, representing the actuarial best estimate of unpaid claim liabilities.',
    `reserve_high_estimate_amount` DECIMAL(18,2) COMMENT 'Upper bound of the reserve estimate range, representing an optimistic or high-severity scenario.',
    `reserve_low_estimate_amount` DECIMAL(18,2) COMMENT 'Lower bound of the reserve estimate range, representing a conservative or pessimistic scenario.',
    `salvage_subrogation_amount` DECIMAL(18,2) COMMENT 'Anticipated recoveries from salvage and subrogation, reducing net reserve requirements.',
    `study_effective_date` DATE COMMENT 'Date when the reserve study becomes effective for financial reporting and reserving purposes.',
    `study_expiration_date` DATE COMMENT 'Date when the reserve study is superseded or no longer applicable for reserving purposes.',
    `study_name` STRING COMMENT 'Descriptive name of the reserve study for identification and reporting purposes.',
    `study_notes` STRING COMMENT 'Free-text commentary and assumptions documented by the actuary regarding methodology, data quality, or special considerations.',
    `study_number` STRING COMMENT 'Business identifier for the reserve study, externally referenced in actuarial reports and regulatory filings.',
    `study_status` STRING COMMENT 'Current lifecycle status of the reserve study indicating its approval and publication state.',
    `study_type` STRING COMMENT 'Classification of reserve study: case reserves, incurred but not reported, unallocated loss adjustment expense, allocated loss adjustment expense, salvage and subrogation, or unallocated reserves.',
    `ulae_reserve_amount` DECIMAL(18,2) COMMENT 'Reserve for loss adjustment expenses not attributable to individual claims, such as claims department overhead.',
    `ultimate_loss_estimate_amount` DECIMAL(18,2) COMMENT 'Actuarial estimate of total losses that will ultimately be paid for the cohort, including paid and unpaid amounts.',
    `valuation_date` DATE COMMENT 'As-of date for which reserves are estimated and reported in this study.',
    CONSTRAINT pk_reserve_study PRIMARY KEY(`reserve_study_id`)
) COMMENT 'Master reference table for reserve_study. Referenced by reserve_study_id.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` (
    `actuarial_analyst_id` BIGINT COMMENT 'Primary key for actuarial_analyst',
    `party_id` BIGINT COMMENT 'Company-issued employee identifier for the actuarial analyst.',
    `supervisor_analyst_id` BIGINT COMMENT 'Identifier of the supervising actuarial analyst for this analyst.',
    `analyst_type` STRING COMMENT 'Specialization area of the actuarial analyst within the organization.',
    `appointed_actuary_flag` BOOLEAN COMMENT 'Indicates whether the analyst is designated as the appointed actuary for statutory reporting purposes.',
    `continuing_education_hours` BIGINT COMMENT 'Total continuing education hours completed by the analyst in the current reporting period.',
    `cost_center_code` STRING COMMENT 'Financial cost center code to which the analyst salary and expenses are allocated.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the actuarial analyst record was first created in the system.',
    `credential_date` DATE COMMENT 'Date when the analyst achieved their current professional credential.',
    `credential_designation` STRING COMMENT 'Specific professional designation held by the actuarial analyst.',
    `credentialing_level` STRING COMMENT 'Professional actuarial credentialing level achieved by the analyst.',
    `department_code` STRING COMMENT 'Code identifying the department where the actuarial analyst is assigned.',
    `department_name` STRING COMMENT 'Name of the department where the actuarial analyst is assigned.',
    `email_address` STRING COMMENT 'Primary business email address for the actuarial analyst.',
    `employment_status` STRING COMMENT 'Current employment status of the actuarial analyst.',
    `first_name` STRING COMMENT 'Legal first name of the actuarial analyst.',
    `hire_date` DATE COMMENT 'Date when the actuarial analyst was hired by the organization.',
    `last_name` STRING COMMENT 'Legal last name of the actuarial analyst.',
    `last_training_date` DATE COMMENT 'Date of the most recent professional training or continuing education completed by the analyst.',
    `notes` STRING COMMENT 'Additional notes or comments regarding the actuarial analyst record.',
    `office_location` STRING COMMENT 'Physical office location or site where the actuarial analyst is based.',
    `phone_number` STRING COMMENT 'Primary business phone number for the actuarial analyst.',
    `primary_line_of_business` STRING COMMENT 'Primary insurance line of business the analyst specializes in analyzing.',
    `qualified_actuary_flag` BOOLEAN COMMENT 'Indicates whether the analyst meets regulatory requirements as a qualified actuary for statutory filings.',
    `remote_work_flag` BOOLEAN COMMENT 'Indicates whether the analyst is authorized to work remotely.',
    `security_clearance_level` STRING COMMENT 'Data security clearance level granted to the analyst for accessing sensitive information.',
    `signing_authority_flag` BOOLEAN COMMENT 'Indicates whether the analyst has authority to sign actuarial opinions and statements.',
    `termination_date` DATE COMMENT 'Date when the actuarial analyst employment ended, if applicable.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the actuarial analyst record was last updated in the system.',
    `work_schedule_type` STRING COMMENT 'Employment schedule type for the actuarial analyst.',
    `years_of_experience` DECIMAL(5,2) COMMENT 'Total years of actuarial experience accumulated by the analyst.',
    CONSTRAINT pk_actuarial_analyst PRIMARY KEY(`actuarial_analyst_id`)
) COMMENT 'Master reference table for actuarial_analyst. Referenced by actuarial_analyst_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ADD CONSTRAINT `fk_reservespayments_reservespayments_loss_reserve_cat_event_id` FOREIGN KEY (`cat_event_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`cat_event`(`cat_event_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ADD CONSTRAINT `fk_reservespayments_reservespayments_reserve_transaction_cat_event_id` FOREIGN KEY (`cat_event_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`cat_event`(`cat_event_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ADD CONSTRAINT `fk_reservespayments_reservespayments_reserve_transaction_reservespayments_loss_reserve_id` FOREIGN KEY (`reservespayments_loss_reserve_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve`(`reservespayments_loss_reserve_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ADD CONSTRAINT `fk_reservespayments_reservespayments_reserve_transaction_reversed_transaction_reservespayments_reserve_transaction_id` FOREIGN KEY (`reversed_transaction_reservespayments_reserve_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction`(`reservespayments_reserve_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ADD CONSTRAINT `fk_reservespayments_ibnr_estimate_actuarial_analyst_id` FOREIGN KEY (`actuarial_analyst_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst`(`actuarial_analyst_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ADD CONSTRAINT `fk_reservespayments_ibnr_estimate_cat_event_id` FOREIGN KEY (`cat_event_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`cat_event`(`cat_event_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ADD CONSTRAINT `fk_reservespayments_ibnr_estimate_reserve_study_id` FOREIGN KEY (`reserve_study_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study`(`reserve_study_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ADD CONSTRAINT `fk_reservespayments_reserve_evaluation_cat_event_id` FOREIGN KEY (`cat_event_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`cat_event`(`cat_event_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ADD CONSTRAINT `fk_reservespayments_reserve_evaluation_reserve_study_id` FOREIGN KEY (`reserve_study_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study`(`reserve_study_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ADD CONSTRAINT `fk_reservespayments_reservespayments_claim_payment_payee_id` FOREIGN KEY (`payee_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`payee`(`payee_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ADD CONSTRAINT `fk_reservespayments_payment_transaction_cat_event_id` FOREIGN KEY (`cat_event_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`cat_event`(`cat_event_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ADD CONSTRAINT `fk_reservespayments_payment_transaction_original_payment_payment_transaction_id` FOREIGN KEY (`original_payment_payment_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction`(`payment_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ADD CONSTRAINT `fk_reservespayments_payment_transaction_payee_id` FOREIGN KEY (`payee_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`payee`(`payee_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ADD CONSTRAINT `fk_reservespayments_payment_transaction_reservespayments_loss_reserve_id` FOREIGN KEY (`reservespayments_loss_reserve_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve`(`reservespayments_loss_reserve_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ADD CONSTRAINT `fk_reservespayments_recovery_transaction_cat_event_id` FOREIGN KEY (`cat_event_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`cat_event`(`cat_event_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ADD CONSTRAINT `fk_reservespayments_recovery_transaction_recovered_payment_transaction_id` FOREIGN KEY (`recovered_payment_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction`(`payment_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ADD CONSTRAINT `fk_reservespayments_recovery_transaction_reinsurance_recoverable_id` FOREIGN KEY (`reinsurance_recoverable_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable`(`reinsurance_recoverable_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ADD CONSTRAINT `fk_reservespayments_recovery_transaction_reservespayments_claim_payment_id` FOREIGN KEY (`reservespayments_claim_payment_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment`(`reservespayments_claim_payment_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ADD CONSTRAINT `fk_reservespayments_recovery_transaction_salvage_item_id` FOREIGN KEY (`salvage_item_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item`(`salvage_item_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ADD CONSTRAINT `fk_reservespayments_recovery_transaction_subrogation_case_id` FOREIGN KEY (`subrogation_case_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case`(`subrogation_case_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ADD CONSTRAINT `fk_reservespayments_salvage_item_cat_event_id` FOREIGN KEY (`cat_event_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`cat_event`(`cat_event_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ADD CONSTRAINT `fk_reservespayments_lae_allocation_cat_event_id` FOREIGN KEY (`cat_event_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`cat_event`(`cat_event_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ADD CONSTRAINT `fk_reservespayments_lae_allocation_reversed_allocation_id` FOREIGN KEY (`reversed_allocation_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation`(`lae_allocation_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ADD CONSTRAINT `fk_reservespayments_payment_approval_cat_event_id` FOREIGN KEY (`cat_event_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`cat_event`(`cat_event_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ADD CONSTRAINT `fk_reservespayments_payment_approval_payment_authority_id` FOREIGN KEY (`payment_authority_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority`(`payment_authority_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ADD CONSTRAINT `fk_reservespayments_payment_approval_payment_transaction_id` FOREIGN KEY (`payment_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction`(`payment_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ADD CONSTRAINT `fk_reservespayments_reinsurance_recoverable_cat_event_id` FOREIGN KEY (`cat_event_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`cat_event`(`cat_event_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ADD CONSTRAINT `fk_reservespayments_structured_settlement_payment_transaction_id` FOREIGN KEY (`payment_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction`(`payment_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ADD CONSTRAINT `fk_reservespayments_development_triangle_cat_event_id` FOREIGN KEY (`cat_event_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`cat_event`(`cat_event_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ADD CONSTRAINT `fk_reservespayments_development_triangle_reserve_study_id` FOREIGN KEY (`reserve_study_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study`(`reserve_study_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ADD CONSTRAINT `fk_reservespayments_stat_reserve_exhibit_cat_event_id` FOREIGN KEY (`cat_event_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`cat_event`(`cat_event_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ADD CONSTRAINT `fk_reservespayments_stat_reserve_exhibit_reserve_evaluation_id` FOREIGN KEY (`reserve_evaluation_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation`(`reserve_evaluation_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` ADD CONSTRAINT `fk_reservespayments_actuarial_analyst_supervisor_analyst_id` FOREIGN KEY (`supervisor_analyst_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst`(`actuarial_analyst_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_v499`.`reservespayments` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_v499`.`reservespayments` SET TAGS ('dbx_domain' = 'reservespayments');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` SET TAGS ('dbx_subdomain' = 'reserve_management');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `reservespayments_loss_reserve_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Reserve ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Claims Adjuster ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `cat_event_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `claim_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `claim_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `claim_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Entity Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `actuarial_segment_code` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Segment Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `alae_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Allocated Loss Adjustment Expense (ALAE) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `alae_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `cat_event_indicator` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `current_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Current Reserve Amount (Outstanding Case Reserve)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `current_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `date_of_loss` SET TAGS ('dbx_business_glossary_term' = 'Date of Loss (DOL)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `ibner_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred But Not Enough Reported (IBNER) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `ibner_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `ibnr_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred But Not Reported (IBNR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `ibnr_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `incurred_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `incurred_loss_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `initial_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Initial Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `initial_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `large_loss_indicator` SET TAGS ('dbx_business_glossary_term' = 'Large Loss Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `large_loss_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Large Loss Threshold Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `large_loss_threshold_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `last_reserve_change_date` SET TAGS ('dbx_business_glossary_term' = 'Last Reserve Change Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `litigation_indicator` SET TAGS ('dbx_business_glossary_term' = 'Litigation Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `net_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `net_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `paid_alae_to_date` SET TAGS ('dbx_business_glossary_term' = 'Paid Allocated Loss Adjustment Expense (ALAE) to Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `paid_alae_to_date` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `paid_losses_to_date` SET TAGS ('dbx_business_glossary_term' = 'Paid Losses to Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `paid_losses_to_date` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recoverable Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `report_year` SET TAGS ('dbx_business_glossary_term' = 'Report Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `reserve_adequacy_status` SET TAGS ('dbx_business_glossary_term' = 'Reserve Adequacy Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `reserve_adequacy_status` SET TAGS ('dbx_value_regex' = 'adequate|deficient|redundant|under_review');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `reserve_change_reason` SET TAGS ('dbx_business_glossary_term' = 'Reserve Change Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `reserve_closed_date` SET TAGS ('dbx_business_glossary_term' = 'Reserve Closed Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `reserve_established_date` SET TAGS ('dbx_business_glossary_term' = 'Reserve Established Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `reserve_method` SET TAGS ('dbx_business_glossary_term' = 'Reserve Method');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `reserve_method` SET TAGS ('dbx_value_regex' = 'case_basis|formula|actuarial|bulk|tabular');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `reserve_number` SET TAGS ('dbx_business_glossary_term' = 'Reserve Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `reserve_number` SET TAGS ('dbx_value_regex' = '^RES-[0-9]{4}-[0-9]{8}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `reserve_status` SET TAGS ('dbx_business_glossary_term' = 'Reserve Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `reserve_status` SET TAGS ('dbx_value_regex' = 'open|closed|reopened|pending_closure|transferred');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `reserve_type` SET TAGS ('dbx_business_glossary_term' = 'Reserve Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `salvage_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Salvage Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `salvage_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `salvage_reserve_amount` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `salvage_reserve_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `stat_line_code` SET TAGS ('dbx_business_glossary_term' = 'Statutory (STAT) Line of Business Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `subrogation_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Subrogation (SubroFT) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `subrogation_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `ulae_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Unallocated Loss Adjustment Expense (ULAE) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `ulae_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Reserve Valuation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` SET TAGS ('dbx_subdomain' = 'reserve_management');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `reservespayments_reserve_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Reserve Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `cat_event_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `reservespayments_loss_reserve_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Reserve ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `reversed_transaction_reservespayments_reserve_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Reversed Reserve Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `authorization_date` SET TAGS ('dbx_business_glossary_term' = 'Reserve Authorization Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `authorization_level` SET TAGS ('dbx_business_glossary_term' = 'Reserve Authorization Level');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `authorization_level` SET TAGS ('dbx_value_regex' = 'ADJUSTER|SUPERVISOR|MANAGER|DIRECTOR|EXECUTIVE');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `claim_office_code` SET TAGS ('dbx_business_glossary_term' = 'Claim Office Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `coverage_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `coverage_type` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `coverage_type` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `date_of_loss` SET TAGS ('dbx_business_glossary_term' = 'Date of Loss (DOL)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `delta_amount` SET TAGS ('dbx_business_glossary_term' = 'Reserve Delta Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `delta_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Reserve Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `is_cat_event` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `net_reserve_delta` SET TAGS ('dbx_business_glossary_term' = 'Net Reserve Delta Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `net_reserve_delta` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `policy_number` SET TAGS ('dbx_business_glossary_term' = 'Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `report_year` SET TAGS ('dbx_business_glossary_term' = 'Report Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `reserve_amount_after` SET TAGS ('dbx_business_glossary_term' = 'Reserve Amount After Transaction');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `reserve_amount_after` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `reserve_amount_before` SET TAGS ('dbx_business_glossary_term' = 'Reserve Amount Before Transaction');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `reserve_amount_before` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `reserve_close_date` SET TAGS ('dbx_business_glossary_term' = 'Reserve Close Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `reserve_type` SET TAGS ('dbx_business_glossary_term' = 'Reserve Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `reserve_type` SET TAGS ('dbx_value_regex' = 'LOSS|ALAE|ULAE|IBNR|IBNER|SUBROGATION');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `reversal_indicator` SET TAGS ('dbx_business_glossary_term' = 'Reversal Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'GUIDEWIRE|DUCK_CREEK|SAPIENS|ARIUS|RESQ|MANUAL');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `source_transaction_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Transaction Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `stat_line_code` SET TAGS ('dbx_business_glossary_term' = 'Statutory (STAT) Line Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Reserve Transaction Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `transaction_number` SET TAGS ('dbx_business_glossary_term' = 'Reserve Transaction Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `transaction_number` SET TAGS ('dbx_value_regex' = '^RT-[0-9]{10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `transaction_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reserve Transaction Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `transaction_reason_notes` SET TAGS ('dbx_business_glossary_term' = 'Reserve Transaction Reason Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_business_glossary_term' = 'Reserve Transaction Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_value_regex' = 'PENDING|POSTED|REVERSED|VOIDED');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `transaction_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Reserve Transaction Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Reserve Transaction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'SET|INCREASE|DECREASE|CLOSE|REOPEN');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` SET TAGS ('dbx_subdomain' = 'reserve_management');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `ibnr_estimate_id` SET TAGS ('dbx_business_glossary_term' = 'Incurred But Not Reported (IBNR) Estimate ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `actuarial_analyst_id` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Analyst ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `cat_event_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `reserve_study_id` SET TAGS ('dbx_business_glossary_term' = 'Reserve Study ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `user_account_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `actuarial_method` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Reserving Method');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `actuarial_notes` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `case_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Case Reserve (OCR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `case_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `ceded_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `ceded_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Confidence Level');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `development_age_months` SET TAGS ('dbx_business_glossary_term' = 'Development Age (Months)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `development_age_months` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `development_age_months` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `earned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `earned_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `estimate_reference_number` SET TAGS ('dbx_business_glossary_term' = 'IBNR Estimate Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `estimate_reference_number` SET TAGS ('dbx_value_regex' = '^IBNR-[0-9]{4}-[A-Z0-9]{6,12}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `estimate_status` SET TAGS ('dbx_business_glossary_term' = 'IBNR Estimate Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `estimate_status` SET TAGS ('dbx_value_regex' = 'DRAFT|UNDER_REVIEW|APPROVED|FILED|SUPERSEDED|VOIDED');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `evaluation_date` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `expected_loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Expected Loss Ratio (ELR)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `filing_period` SET TAGS ('dbx_business_glossary_term' = 'Statutory Filing Period');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `filing_period` SET TAGS ('dbx_value_regex' = '^(Q[1-4]|ANNUAL)-[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `high_estimate_amount` SET TAGS ('dbx_business_glossary_term' = 'High IBNR Estimate Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `high_estimate_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `ibner_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred But Not Enough Reported (IBNER) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `ibner_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `ibnr_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred But Not Reported (IBNR) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `ibnr_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `is_cat_estimate` SET TAGS ('dbx_business_glossary_term' = 'Is Catastrophe (CAT) Estimate Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `ldf_selected` SET TAGS ('dbx_business_glossary_term' = 'Selected Loss Development Factor (LDF)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `lob_name` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `lob_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `lob_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `low_estimate_amount` SET TAGS ('dbx_business_glossary_term' = 'Low IBNR Estimate Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `low_estimate_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `net_of_reinsurance_amount` SET TAGS ('dbx_business_glossary_term' = 'Net of Reinsurance (Net Written Premium) IBNR Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `net_of_reinsurance_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `net_of_reinsurance_amount` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `net_of_reinsurance_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `paid_losses_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Losses Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `paid_losses_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `percent_unreported` SET TAGS ('dbx_business_glossary_term' = 'Percent Unreported');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `prior_period_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Period Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `prior_period_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `reported_losses_amount` SET TAGS ('dbx_business_glossary_term' = 'Reported Losses Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `reported_losses_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `reserve_development_amount` SET TAGS ('dbx_business_glossary_term' = 'Reserve Development Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `reserve_development_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `reserve_type` SET TAGS ('dbx_business_glossary_term' = 'Reserve Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `reserve_type` SET TAGS ('dbx_value_regex' = 'IBNR|IBNER|ULAE|ALAE|OCR|TOTAL');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `statutory_basis` SET TAGS ('dbx_business_glossary_term' = 'Statutory Accounting Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `statutory_basis` SET TAGS ('dbx_value_regex' = 'SAP|GAAP|IFRS17|STAT');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `total_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Bulk Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `total_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `ulae_amount` SET TAGS ('dbx_business_glossary_term' = 'Unallocated Loss Adjustment Expense (ULAE) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `ulae_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `ultimate_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `ultimate_loss_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `ultimate_loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Loss Ratio (ULR)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` SET TAGS ('dbx_subdomain' = 'reserve_management');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `reserve_evaluation_id` SET TAGS ('dbx_business_glossary_term' = 'Reserve Evaluation ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `cat_event_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Entity Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `reserve_study_id` SET TAGS ('dbx_business_glossary_term' = 'Reserve Study Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_business_glossary_term' = 'Accounting Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_value_regex' = 'SAP|GAAP|IFRS17');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `actuarial_opinion_reference` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Opinion Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `alae_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Allocated Loss Adjustment Expense (ALAE) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `alae_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `appointed_actuary_credential` SET TAGS ('dbx_business_glossary_term' = 'Appointed Actuary Credential');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `appointed_actuary_credential` SET TAGS ('dbx_value_regex' = 'FCAS|ACAS|MAAA|FSA|ASA');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `appointed_actuary_name` SET TAGS ('dbx_business_glossary_term' = 'Appointed Actuary Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `appointed_actuary_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `appointed_actuary_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `appointed_actuary_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `cat_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `cat_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Company NAIC Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `ep_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `ep_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `evaluation_date` SET TAGS ('dbx_business_glossary_term' = 'Reserve Evaluation Date (As-of Date)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `evaluation_period_type` SET TAGS ('dbx_business_glossary_term' = 'Reserve Evaluation Period Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `evaluation_period_type` SET TAGS ('dbx_value_regex' = 'quarterly|annual|interim|special');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `evaluation_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Reserve Evaluation Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `evaluation_reference_number` SET TAGS ('dbx_value_regex' = '^RE-[0-9]{4}-[0-9]{2}-[A-Z0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `evaluation_status` SET TAGS ('dbx_business_glossary_term' = 'Reserve Evaluation Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `evaluation_status` SET TAGS ('dbx_value_regex' = 'draft|in_review|actuarial_signed|management_approved|filed|superseded');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `gross_case_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Outstanding Case Reserve (OCR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `gross_case_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `gross_ibner_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Incurred But Not Enough Reported (IBNER) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `gross_ibner_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `gross_ibnr_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Incurred But Not Reported (IBNR) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `gross_ibnr_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `gross_total_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Total Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `gross_total_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `incurred_losses_to_date` SET TAGS ('dbx_business_glossary_term' = 'Incurred Losses to Date Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `incurred_losses_to_date` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `lob_description` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Description');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `net_case_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Outstanding Case Reserve (OCR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `net_case_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `net_ibnr_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Incurred But Not Reported (IBNR) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `net_ibnr_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `net_total_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Total Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `net_total_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `opinion_type` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Opinion Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `opinion_type` SET TAGS ('dbx_value_regex' = 'reasonable|deficient|excessive|qualified|no_opinion');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `paid_losses_to_date` SET TAGS ('dbx_business_glossary_term' = 'Paid Losses to Date Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `paid_losses_to_date` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `prior_evaluation_date` SET TAGS ('dbx_business_glossary_term' = 'Prior Reserve Evaluation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `reserve_basis` SET TAGS ('dbx_business_glossary_term' = 'Reserve Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `reserve_basis` SET TAGS ('dbx_value_regex' = 'accident_year|policy_year|report_year|calendar_year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `reserve_development_amount` SET TAGS ('dbx_business_glossary_term' = 'Reserve Development Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `reserve_development_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `reserving_system_source` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Reserving System Source');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `reserving_system_source` SET TAGS ('dbx_value_regex' = 'milliman_arius|wtw_resq|internal_model|other');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `ri_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `ri_recoverable_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `schedule_p_line` SET TAGS ('dbx_business_glossary_term' = 'NAIC Schedule P Line');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `ulae_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Unallocated Loss Adjustment Expense (ULAE) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `ulae_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `ulr` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Loss Ratio (ULR)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `ultimate_loss_estimate` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Loss Estimate Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `ultimate_loss_estimate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` SET TAGS ('dbx_subdomain' = 'payment_processing');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `reservespayments_claim_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Payment Junction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Claims Adjuster ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Entity Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `part_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `payee_id` SET TAGS ('dbx_business_glossary_term' = 'Payee Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `user_account_id` SET TAGS ('dbx_business_glossary_term' = 'Approver Employee ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `accounting_date` SET TAGS ('dbx_business_glossary_term' = 'Accounting Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `accounting_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `accounting_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `allocated_gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Allocated Gross Payment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `allocated_gross_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `allocated_gross_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `allocation_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Allocation Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `allocation_number` SET TAGS ('dbx_value_regex' = '^ALLOC-[0-9]{10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Approval Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|escalated');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Payment Approval Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `bank_clearance_date` SET TAGS ('dbx_business_glossary_term' = 'Bank Clearance Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `cat_event_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `cat_event_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{1,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `check_number` SET TAGS ('dbx_business_glossary_term' = 'Check or EFT Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `check_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{1,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{2,15}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `deductible_offset_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Offset Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `deductible_offset_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `deductible_offset_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{4,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `is_cat_loss` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Loss Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `is_large_loss` SET TAGS ('dbx_business_glossary_term' = 'Large Loss Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `lob_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `loss_date` SET TAGS ('dbx_business_glossary_term' = 'Date of Loss (DOL)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `net_of_ri_amount` SET TAGS ('dbx_business_glossary_term' = 'Net of Reinsurance (RI) Payment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `net_of_ri_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `net_of_ri_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `net_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Payment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `net_payment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `net_payment_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Payment Allocation Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'check|eft|wire|draft|virtual_card');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'pending|issued|cleared|voided|stopped|returned');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `payment_type` SET TAGS ('dbx_business_glossary_term' = 'Payment Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `recovery_amount` SET TAGS ('dbx_business_glossary_term' = 'Recovery Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `recovery_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `recovery_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `report_date` SET TAGS ('dbx_business_glossary_term' = 'Claim Report Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `reserve_type` SET TAGS ('dbx_business_glossary_term' = 'Reserve Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `reserve_type` SET TAGS ('dbx_value_regex' = 'case_reserve|ibnr|ibner|ulae_reserve|alae_reserve');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `salvage_amount` SET TAGS ('dbx_business_glossary_term' = 'Salvage Recovery Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `salvage_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `salvage_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `subrogation_status` SET TAGS ('dbx_business_glossary_term' = 'Subrogation (SubroFT) Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `subrogation_status` SET TAGS ('dbx_value_regex' = 'not_applicable|identified|in_pursuit|collected|closed_no_recovery');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `transaction_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Transaction Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `void_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Void Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ALTER COLUMN `void_reason` SET TAGS ('dbx_business_glossary_term' = 'Payment Void Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` SET TAGS ('dbx_subdomain' = 'payment_processing');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `payment_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `cat_event_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Entity Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `original_payment_payment_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Original Payment Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `payee_id` SET TAGS ('dbx_business_glossary_term' = 'Payee Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `reservespayments_loss_reserve_id` SET TAGS ('dbx_business_glossary_term' = 'Reserve ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `bank_clearing_date` SET TAGS ('dbx_business_glossary_term' = 'Bank Clearing Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_business_glossary_term' = 'Bank Routing Number (ABA)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_value_regex' = '^[0-9]{9}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `check_number` SET TAGS ('dbx_business_glossary_term' = 'Check Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `check_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `check_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `deduction_amount` SET TAGS ('dbx_business_glossary_term' = 'Deduction Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `deduction_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `deduction_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `gl_journal_reference` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Journal Entry ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `gl_posting_date` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Posting Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `gl_posting_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `gl_posting_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Payment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `gross_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `gross_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `is_1099_reportable` SET TAGS ('dbx_business_glossary_term' = 'IRS 1099 Reportable Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `is_cat_loss` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Loss Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `line_of_business_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business Code (LOB)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `loss_category` SET TAGS ('dbx_business_glossary_term' = 'Loss Category');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Payment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `net_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `net_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `ofac_screening_status` SET TAGS ('dbx_business_glossary_term' = 'OFAC Screening Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `ofac_screening_status` SET TAGS ('dbx_value_regex' = 'pending|cleared|flagged|blocked');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `payee_tax_identification_number` SET TAGS ('dbx_business_glossary_term' = 'Payee Tax Identification Number (TIN)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `payee_tax_identification_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `payee_tax_identification_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `payee_type` SET TAGS ('dbx_business_glossary_term' = 'Payee Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'check|eft|wire|virtual_card|cash');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `payment_notes` SET TAGS ('dbx_business_glossary_term' = 'Payment Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `payment_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `payment_number` SET TAGS ('dbx_value_regex' = '^PAY-[0-9]{10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'draft|issued|cleared|voided|reissued|stopped');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `payment_type` SET TAGS ('dbx_business_glossary_term' = 'Payment Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `reinsurance_recoverable_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `reinsurance_recoverable_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `reinsurance_recoverable_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `reissue_date` SET TAGS ('dbx_business_glossary_term' = 'Reissue Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `ri_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `ri_recoverable_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `ri_recoverable_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `sir_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) / Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `sir_deductible_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `sir_deductible_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'guidewire_cc|duck_creek_claims|oracle_ap|sap_fi');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `subrogation_flag` SET TAGS ('dbx_business_glossary_term' = 'Subrogation (Subro) Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `tax_withholding_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Withholding Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `tax_withholding_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `tax_withholding_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `void_date` SET TAGS ('dbx_business_glossary_term' = 'Void Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ALTER COLUMN `void_reason` SET TAGS ('dbx_business_glossary_term' = 'Void Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` SET TAGS ('dbx_subdomain' = 'recovery_operations');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `recovery_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Recovery Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `cat_event_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `fac_certificate_id` SET TAGS ('dbx_business_glossary_term' = 'Fac Certificate Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `recovered_payment_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Recovered Payment Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `reinsurance_recoverable_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `reinsurance_recoverable_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `reinsurance_recoverable_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `reservespayments_claim_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Payment ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Treaty ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `salvage_item_id` SET TAGS ('dbx_business_glossary_term' = 'Salvage Item Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `salvage_item_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `salvage_item_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `subrogation_case_id` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Case Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `accounting_period` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `accounting_period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(0[1-9]|1[0-2])$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `at_fault_party_insurer` SET TAGS ('dbx_business_glossary_term' = 'At-Fault Party Insurer Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `at_fault_party_name` SET TAGS ('dbx_business_glossary_term' = 'At-Fault Party Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `at_fault_party_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `at_fault_party_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `at_fault_party_policy_number` SET TAGS ('dbx_business_glossary_term' = 'At-Fault Party Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `at_fault_party_policy_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `closed_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Closed Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `collection_attorney_firm` SET TAGS ('dbx_business_glossary_term' = 'Collection Attorney Firm Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `collection_expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Collection Expense Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `collection_expense_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `collection_expense_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Company NAIC Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `gross_recovery_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Recovery Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `gross_recovery_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `gross_recovery_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `initiated_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Initiated Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `is_cat_event` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `is_intercompany` SET TAGS ('dbx_business_glossary_term' = 'Intercompany Recovery Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `lob_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `net_recovery_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Recovery Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `net_recovery_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `net_recovery_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `net_retained_recovery_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Retained Recovery Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `net_retained_recovery_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `net_retained_recovery_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Recovery Transaction Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `recovery_basis` SET TAGS ('dbx_business_glossary_term' = 'Recovery Accounting Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `recovery_basis` SET TAGS ('dbx_value_regex' = 'CASH|ACCRUAL');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `recovery_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `recovery_method` SET TAGS ('dbx_business_glossary_term' = 'Recovery Collection Method');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `recovery_method` SET TAGS ('dbx_value_regex' = 'CHECK|WIRE|ACH|OFFSET|CREDIT_NOTE');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `recovery_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Recovery Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `recovery_reference_number` SET TAGS ('dbx_value_regex' = '^REC-[0-9]{4}-[0-9]{8}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `recovery_status` SET TAGS ('dbx_business_glossary_term' = 'Recovery Collection Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `recovery_status` SET TAGS ('dbx_value_regex' = 'OPEN|IN_COLLECTION|COLLECTED|CLOSED|WRITTEN_OFF');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `recovery_type` SET TAGS ('dbx_business_glossary_term' = 'Recovery Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `recovery_type` SET TAGS ('dbx_value_regex' = 'SUBROGATION|SALVAGE|REINSURANCE|SECOND_INJURY_FUND|OTHER');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `reserve_release_amount` SET TAGS ('dbx_business_glossary_term' = 'Reserve Release Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `reserve_release_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `reserve_release_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `ri_share_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Share Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `ri_share_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `ri_share_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `second_injury_fund_state` SET TAGS ('dbx_business_glossary_term' = 'Second Injury Fund State');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `second_injury_fund_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `statute_of_limitations_date` SET TAGS ('dbx_business_glossary_term' = 'Statute of Limitations Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `subrogation_demand_amount` SET TAGS ('dbx_business_glossary_term' = 'Subrogation (SubroFT) Demand Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `subrogation_demand_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `subrogation_demand_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `write_off_amount` SET TAGS ('dbx_business_glossary_term' = 'Recovery Write-Off Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `write_off_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `write_off_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `write_off_reason` SET TAGS ('dbx_business_glossary_term' = 'Recovery Write-Off Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ALTER COLUMN `write_off_reason` SET TAGS ('dbx_value_regex' = 'UNCOLLECTIBLE|STATUTE_EXPIRED|SETTLEMENT|INSOLVENCY|WAIVED');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` SET TAGS ('dbx_subdomain' = 'recovery_operations');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `subrogation_case_id` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Case ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Adjuster ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `attorney_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Attorney ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `alae_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Allocated Loss Adjustment Expense (ALAE) Paid Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `arbitration_filing_date` SET TAGS ('dbx_business_glossary_term' = 'Arbitration Filing Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `arbitration_forum` SET TAGS ('dbx_business_glossary_term' = 'Arbitration Forum');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `arbitration_forum` SET TAGS ('dbx_value_regex' = 'AAIS|AICRB|AAA|NCCI|none');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `attorney_firm_name` SET TAGS ('dbx_business_glossary_term' = 'Attorney Firm Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `attorney_firm_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `attorney_firm_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `case_number` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Case Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `case_number` SET TAGS ('dbx_value_regex' = '^SUBRO-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `case_status` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Case Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `case_status` SET TAGS ('dbx_value_regex' = 'open|in_demand|in_litigation|settled|closed_recovered|closed_no_recovery');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `case_type` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Case Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `case_type` SET TAGS ('dbx_value_regex' = 'auto_liability|property_damage|workers_comp|general_liability|product_liability');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `closed_date` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Case Closed Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `collected_amount` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Collected Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `court_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Court Jurisdiction');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `date_of_loss` SET TAGS ('dbx_business_glossary_term' = 'Date of Loss (DOL)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `deductible_reimbursed_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Reimbursed Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `demand_amount` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Demand Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `demand_sent_date` SET TAGS ('dbx_business_glossary_term' = 'Demand Letter Sent Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `gross_paid_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Paid Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `liability_percentage` SET TAGS ('dbx_business_glossary_term' = 'Third Party Liability Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `liability_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `liability_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `litigation_filed_flag` SET TAGS ('dbx_business_glossary_term' = 'Litigation Filed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `net_recovery_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Subrogation Recovery Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Case Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `opened_date` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Case Opened Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Case Priority Level');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `pursuit_method` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Pursuit Method');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `pursuit_method` SET TAGS ('dbx_value_regex' = 'demand_letter|arbitration|litigation|intercompany|waived');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `recovery_expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Recovery Expense Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `ri_recoverable_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recoverable Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `ri_recovery_share_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recovery Share Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Settlement Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Settlement Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `settlement_status` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Settlement Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `settlement_status` SET TAGS ('dbx_value_regex' = 'not_settled|partial_settlement|full_settlement|waived');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `statute_of_limitations_date` SET TAGS ('dbx_business_glossary_term' = 'Statute of Limitations Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `third_party_claim_number` SET TAGS ('dbx_business_glossary_term' = 'Third Party Claim Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `third_party_insurer_name` SET TAGS ('dbx_business_glossary_term' = 'Third Party Insurer Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `third_party_insurer_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `third_party_insurer_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `third_party_name` SET TAGS ('dbx_business_glossary_term' = 'Third Party Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `third_party_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `third_party_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `third_party_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Third Party Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `third_party_policy_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Waiver Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_value_regex' = 'uncollectible|cost_benefit|insured_fault|statute_expired|other');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` SET TAGS ('dbx_subdomain' = 'recovery_operations');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_item_id` SET TAGS ('dbx_business_glossary_term' = 'Salvage Item ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_item_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_item_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `cat_event_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `service_vendor_id` SET TAGS ('dbx_business_glossary_term' = 'Salvage Vendor ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `acv_at_loss` SET TAGS ('dbx_business_glossary_term' = 'Actual Cash Value (ACV) at Date of Loss');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `acv_at_loss` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `acv_at_loss` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `adjuster_notes` SET TAGS ('dbx_business_glossary_term' = 'Claims Adjuster Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `auction_lot_number` SET TAGS ('dbx_business_glossary_term' = 'Auction Lot Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `branded_title_flag` SET TAGS ('dbx_business_glossary_term' = 'Branded Title Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Company NAIC Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `condition_at_title` SET TAGS ('dbx_business_glossary_term' = 'Salvage Item Condition at Title Acquisition');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `disposal_cost` SET TAGS ('dbx_business_glossary_term' = 'Salvage Disposal Cost');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `disposal_cost` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `disposal_cost` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `disposal_date` SET TAGS ('dbx_business_glossary_term' = 'Salvage Disposal Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `disposal_method` SET TAGS ('dbx_business_glossary_term' = 'Salvage Disposal Method');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `environmental_hazard_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Hazard Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `item_description` SET TAGS ('dbx_business_glossary_term' = 'Salvage Item Description');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `item_type` SET TAGS ('dbx_business_glossary_term' = 'Salvage Item Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `make` SET TAGS ('dbx_business_glossary_term' = 'Salvage Item Make');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `model` SET TAGS ('dbx_business_glossary_term' = 'Salvage Item Model');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `net_salvage_recovery` SET TAGS ('dbx_business_glossary_term' = 'Net Salvage Recovery');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `net_salvage_recovery` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `net_salvage_recovery` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `odometer_reading` SET TAGS ('dbx_business_glossary_term' = 'Odometer Reading at Loss');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Salvage Proceeds Payment Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `proceeds_received_date` SET TAGS ('dbx_business_glossary_term' = 'Salvage Proceeds Received Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `reserve_credit_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Reserve Credit Applied Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `ri_recoverable_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recoverable Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `ri_salvage_credit` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Salvage Credit');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `ri_salvage_credit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `ri_salvage_credit` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_proceeds` SET TAGS ('dbx_business_glossary_term' = 'Salvage Proceeds');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_proceeds` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_proceeds` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Salvage Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_reference_number` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_reference_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_status` SET TAGS ('dbx_business_glossary_term' = 'Salvage Item Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_status` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_status` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_value_estimate` SET TAGS ('dbx_business_glossary_term' = 'Salvage Value Estimate');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_value_estimate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_value_estimate` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_vendor_name` SET TAGS ('dbx_business_glossary_term' = 'Salvage Vendor Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_vendor_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `salvage_vendor_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `serial_number` SET TAGS ('dbx_business_glossary_term' = 'Salvage Item Serial Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `state_of_loss_code` SET TAGS ('dbx_business_glossary_term' = 'State of Loss Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `state_of_loss_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `storage_location` SET TAGS ('dbx_business_glossary_term' = 'Salvage Storage Location');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `storage_location` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `storage_location` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `storage_start_date` SET TAGS ('dbx_business_glossary_term' = 'Salvage Storage Start Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `storage_start_date` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `storage_start_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `title_acquired_date` SET TAGS ('dbx_business_glossary_term' = 'Salvage Title Acquired Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `title_brand_type` SET TAGS ('dbx_business_glossary_term' = 'Salvage Title Brand Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `title_state_code` SET TAGS ('dbx_business_glossary_term' = 'Salvage Title State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `title_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `title_state_code` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `title_state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `total_loss_settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Total Loss Settlement Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `vin` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identification Number (VIN)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `vin` SET TAGS ('dbx_value_regex' = '^[A-HJ-NPR-Z0-9]{17}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ALTER COLUMN `year_manufactured` SET TAGS ('dbx_business_glossary_term' = 'Year Manufactured');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` SET TAGS ('dbx_subdomain' = 'payment_processing');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `lae_allocation_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Adjustment Expense (LAE) Allocation ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Claims Adjuster ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `cat_event_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `fac_certificate_id` SET TAGS ('dbx_business_glossary_term' = 'Fac Certificate Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Entity Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `reversed_allocation_id` SET TAGS ('dbx_business_glossary_term' = 'Reversed LAE Allocation ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `service_vendor_id` SET TAGS ('dbx_business_glossary_term' = 'Vendor ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_business_glossary_term' = 'Accounting Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_value_regex' = 'STAT|GAAP|IFRS');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `accounting_period_date` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `accounting_period_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `accounting_period_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `allocated_amount` SET TAGS ('dbx_business_glossary_term' = 'Allocated LAE Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `allocated_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `allocation_basis` SET TAGS ('dbx_business_glossary_term' = 'LAE Allocation Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `allocation_basis` SET TAGS ('dbx_value_regex' = 'claim_count|earned_premium|incurred_loss|paid_loss|exposure_unit');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `allocation_date` SET TAGS ('dbx_business_glossary_term' = 'LAE Allocation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `allocation_method` SET TAGS ('dbx_business_glossary_term' = 'LAE Allocation Method');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `allocation_method` SET TAGS ('dbx_value_regex' = 'direct|pro_rata|exposure_based|claim_count|paid_loss|actuarial');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `allocation_number` SET TAGS ('dbx_business_glossary_term' = 'Loss Adjustment Expense (LAE) Allocation Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `allocation_number` SET TAGS ('dbx_value_regex' = '^LAE-[0-9]{4}-[0-9]{8}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `allocation_status` SET TAGS ('dbx_business_glossary_term' = 'LAE Allocation Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `allocation_status` SET TAGS ('dbx_value_regex' = 'draft|pending|approved|posted|reversed|voided');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `authorization_date` SET TAGS ('dbx_business_glossary_term' = 'LAE Authorization Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `authorization_level` SET TAGS ('dbx_business_glossary_term' = 'LAE Authorization Level');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `authorization_level` SET TAGS ('dbx_value_regex' = 'adjuster|supervisor|manager|director|executive');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Company National Association of Insurance Commissioners (NAIC) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `expense_category_code` SET TAGS ('dbx_business_glossary_term' = 'LAE Expense Category Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `expense_category_description` SET TAGS ('dbx_business_glossary_term' = 'LAE Expense Category Description');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `is_cat_event` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `lae_type` SET TAGS ('dbx_business_glossary_term' = 'Loss Adjustment Expense (LAE) Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `lae_type` SET TAGS ('dbx_value_regex' = 'ALAE|ULAE');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `lob_description` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Description');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `net_lae_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Loss Adjustment Expense (LAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `net_lae_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'LAE Allocation Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `report_year` SET TAGS ('dbx_business_glossary_term' = 'Report Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `reversal_indicator` SET TAGS ('dbx_business_glossary_term' = 'LAE Allocation Reversal Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `ri_recoverable_lae_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recoverable LAE Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `ri_recoverable_lae_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `service_type` SET TAGS ('dbx_business_glossary_term' = 'LAE Service Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'GUIDEWIRE_CC|DUCK_CREEK_CLAIMS|SAPIENS_IDIT|ORACLE_AP|SAP_FI|MANUAL');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `source_transaction_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Transaction Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `stat_line_code` SET TAGS ('dbx_business_glossary_term' = 'Statutory (STAT) Line Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ALTER COLUMN `vendor_invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Vendor Invoice Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` SET TAGS ('dbx_subdomain' = 'payment_processing');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `payment_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Authority ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `payment_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `payment_delegated_by_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Delegated By Adjuster ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `payment_escalation_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Escalation Adjuster ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `tpa_id` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Administrator (TPA) ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `adjuster_role` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Role');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `advance_payment_allowed` SET TAGS ('dbx_business_glossary_term' = 'Advance Payment Allowed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `advance_payment_limit` SET TAGS ('dbx_business_glossary_term' = 'Advance Payment Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `advance_payment_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `aggregate_payment_limit` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Payment Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `aggregate_payment_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `approval_workflow_code` SET TAGS ('dbx_business_glossary_term' = 'Approval Workflow Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Authority Approved Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `authority_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Authority Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `authority_code` SET TAGS ('dbx_value_regex' = '^PA-[A-Z0-9]{4,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `authority_level` SET TAGS ('dbx_business_glossary_term' = 'Delegated Authority Level');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `authority_level` SET TAGS ('dbx_value_regex' = 'level_1|level_2|level_3|level_4|level_5');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `authority_name` SET TAGS ('dbx_business_glossary_term' = 'Payment Authority Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `authority_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `authority_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `authority_notes` SET TAGS ('dbx_business_glossary_term' = 'Payment Authority Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `authority_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Authority Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `authority_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|suspended|expired');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `cat_event_limit` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Payment Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `cat_event_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `claim_office_code` SET TAGS ('dbx_business_glossary_term' = 'Claim Office Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `claim_type` SET TAGS ('dbx_business_glossary_term' = 'Claim Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `claim_type` SET TAGS ('dbx_value_regex' = 'first_party|third_party|subrogation|all');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Company NAIC Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `coverage_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `coverage_type` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `coverage_type` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `delegation_basis` SET TAGS ('dbx_business_glossary_term' = 'Delegation Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `delegation_basis` SET TAGS ('dbx_value_regex' = 'role|individual|temporary|tpa|vendor');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `delegation_date` SET TAGS ('dbx_business_glossary_term' = 'Delegation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `dual_approval_threshold` SET TAGS ('dbx_business_glossary_term' = 'Dual Approval Threshold Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `dual_approval_threshold` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `escalation_path_description` SET TAGS ('dbx_business_glossary_term' = 'Escalation Path Description');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `is_cat_authority` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Authority Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Authority Review Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `litigation_payment_allowed` SET TAGS ('dbx_business_glossary_term' = 'Litigation Payment Allowed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Authority Review Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `payment_type` SET TAGS ('dbx_business_glossary_term' = 'Payment Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `payment_type` SET TAGS ('dbx_value_regex' = 'indemnity|alae|expense|recovery|advance|all');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `requires_dual_approval` SET TAGS ('dbx_business_glossary_term' = 'Requires Dual Approval Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `reserve_change_limit` SET TAGS ('dbx_business_glossary_term' = 'Reserve Change Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `reserve_change_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Authority Review Frequency');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `settlement_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Settlement Authority Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `settlement_authority_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `single_payment_limit` SET TAGS ('dbx_business_glossary_term' = 'Single Payment Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `single_payment_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'GUIDEWIRE_CC|DUCK_CREEK_CLAIMS|SAPIENS_IDIT|MANUAL');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Authority Version Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` SET TAGS ('dbx_subdomain' = 'payment_processing');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `payment_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Approval ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `cat_event_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `payment_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Approver Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `payment_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Authority Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `payment_escalated_to_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Escalated-To Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `payment_requestor_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Requestor Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `payment_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `approval_channel` SET TAGS ('dbx_business_glossary_term' = 'Approval Channel');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `approval_channel` SET TAGS ('dbx_value_regex' = 'system|email|phone|in_person|delegated');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `approval_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Approval Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `approval_reference_number` SET TAGS ('dbx_value_regex' = '^PA-[0-9]{4}-[0-9]{8}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Approval Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|denied|escalated|withdrawn|expired');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `approval_type` SET TAGS ('dbx_business_glossary_term' = 'Payment Approval Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `approval_type` SET TAGS ('dbx_value_regex' = 'supervisory|management|executive|committee|reinsurance|legal');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `approved_amount` SET TAGS ('dbx_business_glossary_term' = 'Approved Payment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `approved_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `claim_office_code` SET TAGS ('dbx_business_glossary_term' = 'Claim Office Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `decision_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Decision Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `denial_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Denial Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `denial_reason_notes` SET TAGS ('dbx_business_glossary_term' = 'Denial Reason Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `escalation_level` SET TAGS ('dbx_business_glossary_term' = 'Escalation Level');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `fraud_referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Fraud Referral Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `is_cat_loss` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Loss Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `is_large_loss` SET TAGS ('dbx_business_glossary_term' = 'Large Loss Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `is_override` SET TAGS ('dbx_business_glossary_term' = 'Override Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `is_sla_breached` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Breach Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `litigation_flag` SET TAGS ('dbx_business_glossary_term' = 'Litigation Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `override_justification` SET TAGS ('dbx_business_glossary_term' = 'Override Justification');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `payment_category` SET TAGS ('dbx_business_glossary_term' = 'Payment Category');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `reinsurance_recoverable_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recoverable Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `reinsurance_recoverable_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `reinsurance_recoverable_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `request_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Request Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `request_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Request Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `requested_amount` SET TAGS ('dbx_business_glossary_term' = 'Requested Payment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `requested_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `ri_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `ri_recoverable_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `sir_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `sir_deductible_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `sla_due_date` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'GUIDEWIRE|DUCK_CREEK|SAPIENS|MANUAL');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `supporting_document_ref` SET TAGS ('dbx_business_glossary_term' = 'Supporting Document Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `supporting_document_ref` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `supporting_document_ref` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` SET TAGS ('dbx_subdomain' = 'payment_processing');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `payee_id` SET TAGS ('dbx_business_glossary_term' = 'Payee ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Country Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `preferred_currency_id` SET TAGS ('dbx_business_glossary_term' = 'Preferred Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `ach_authorization_date` SET TAGS ('dbx_business_glossary_term' = 'ACH Authorization Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `address_line1` SET TAGS ('dbx_business_glossary_term' = 'Payee Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `address_line1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `address_line2` SET TAGS ('dbx_business_glossary_term' = 'Payee Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `address_line2` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `backup_withholding_flag` SET TAGS ('dbx_business_glossary_term' = 'Backup Withholding Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `bank_account_type` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `bank_account_type` SET TAGS ('dbx_value_regex' = 'checking|savings');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `bank_account_type` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `bank_account_type` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `bank_name` SET TAGS ('dbx_business_glossary_term' = 'Bank Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `bank_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `bank_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_business_glossary_term' = 'Bank Routing Number (ABA)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_value_regex' = '^[0-9]{9}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'Payee City');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `dba_name` SET TAGS ('dbx_business_glossary_term' = 'Doing Business As (DBA) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'Payee Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `entity_type` SET TAGS ('dbx_business_glossary_term' = 'Entity Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `entity_type` SET TAGS ('dbx_value_regex' = 'individual|organization');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `first_name` SET TAGS ('dbx_business_glossary_term' = 'Payee First Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `form_1099_type` SET TAGS ('dbx_business_glossary_term' = 'IRS Form 1099 Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `form_1099_type` SET TAGS ('dbx_value_regex' = '1099-MISC|1099-NEC|1099-B|1099-R|none');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `is_1099_reportable` SET TAGS ('dbx_business_glossary_term' = '1099 Reportable Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `is_attorney` SET TAGS ('dbx_business_glossary_term' = 'Attorney Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `is_claimant` SET TAGS ('dbx_business_glossary_term' = 'Claimant Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `is_medical_provider` SET TAGS ('dbx_business_glossary_term' = 'Medical Provider Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `is_medical_provider` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `is_medical_provider` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `last_name` SET TAGS ('dbx_business_glossary_term' = 'Payee Last Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Payee Legal Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `legal_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `legal_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `license_number` SET TAGS ('dbx_business_glossary_term' = 'Payee License Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `license_state` SET TAGS ('dbx_business_glossary_term' = 'Payee License State');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `license_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `npi_number` SET TAGS ('dbx_business_glossary_term' = 'National Provider Identifier (NPI) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `npi_number` SET TAGS ('dbx_value_regex' = '^[0-9]{10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Payee Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^PAY-[0-9]{8,12}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `ofac_screen_date` SET TAGS ('dbx_business_glossary_term' = 'OFAC Screen Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `ofac_screen_result` SET TAGS ('dbx_business_glossary_term' = 'OFAC Screen Result');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `ofac_screen_result` SET TAGS ('dbx_value_regex' = 'clear|potential_match|confirmed_match|pending_review');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `ofac_screened_flag` SET TAGS ('dbx_business_glossary_term' = 'OFAC Screened Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `payee_status` SET TAGS ('dbx_business_glossary_term' = 'Payee Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `payee_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending_verification|blocked');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `payee_type` SET TAGS ('dbx_business_glossary_term' = 'Payee Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `payment_block_flag` SET TAGS ('dbx_business_glossary_term' = 'Payment Block Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `payment_block_reason` SET TAGS ('dbx_business_glossary_term' = 'Payment Block Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `payment_block_reason` SET TAGS ('dbx_value_regex' = 'ofac_match|fraud_investigation|legal_hold|duplicate_payee|deceased|other');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'check|ach|wire|virtual_card|zelle');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `phone_number` SET TAGS ('dbx_business_glossary_term' = 'Payee Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `phone_number` SET TAGS ('dbx_value_regex' = '^+?[0-9-s().]{7,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Payee Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `postal_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}(-[0-9]{4})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'guidewire_cc|duck_creek_claims|sapiens_idit|manual|other');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tax_id_type` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number (TIN) Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tax_id_type` SET TAGS ('dbx_value_regex' = 'SSN|FEIN|ITIN|EIN');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tax_id_type` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tax_id_type` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number (TIN)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_value_regex' = '^[0-9]{9}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tin_verification_date` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number (TIN) Verification Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tin_verification_date` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tin_verification_date` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tin_verification_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tin_verification_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tin_verified_flag` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number (TIN) Verified Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tin_verified_flag` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tin_verified_flag` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tin_verified_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `tin_verified_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `w9_received_date` SET TAGS ('dbx_business_glossary_term' = 'IRS Form W-9 Received Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ALTER COLUMN `w9_received_flag` SET TAGS ('dbx_business_glossary_term' = 'IRS Form W-9 Received Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` SET TAGS ('dbx_subdomain' = 'recovery_operations');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `reinsurance_recoverable_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `reinsurance_recoverable_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `reinsurance_recoverable_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `cat_event_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `occurrence_loss_id` SET TAGS ('dbx_business_glossary_term' = 'Occurrence Loss Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `treaty_layer_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Layer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_business_glossary_term' = 'Accounting Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_value_regex' = 'STAT|GAAP|IFRS17');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_business_glossary_term' = 'Authorized Reinsurer Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Reporting Period');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(Q[1-4]|[0-9]{2})$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `cat_event_indicator` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `cession_reference` SET TAGS ('dbx_business_glossary_term' = 'Cession Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `collateral_held_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Held Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `collateral_held_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'letter_of_credit|trust_fund|funds_withheld|cash_deposit|none');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `collectability_status` SET TAGS ('dbx_business_glossary_term' = 'Collectability Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `collectability_status` SET TAGS ('dbx_value_regex' = 'collectible|potentially_uncollectible|uncollectible|in_dispute');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `collected_amount` SET TAGS ('dbx_business_glossary_term' = 'Collected Reinsurance Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `collected_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Company NAIC Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `date_of_loss` SET TAGS ('dbx_business_glossary_term' = 'Date of Loss (DOL)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `gross_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `gross_alae_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `gross_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Loss Amount (GWP Basis)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `gross_loss_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `last_collection_date` SET TAGS ('dbx_business_glossary_term' = 'Last Collection Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `outstanding_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Reinsurance Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `outstanding_recoverable_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `recoverable_number` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `recoverable_number` SET TAGS ('dbx_value_regex' = '^RI-REC-[0-9]{10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `recoverable_status` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `recoverable_status` SET TAGS ('dbx_value_regex' = 'open|collected|partially_collected|disputed|written_off|closed');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `recoverable_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `recoverable_type` SET TAGS ('dbx_value_regex' = 'paid_loss|case_reserve|ibnr|alae|ulae|salvage_subrogation');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `reinsurance_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `reinsurance_type` SET TAGS ('dbx_value_regex' = 'treaty|facultative');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `reinsurance_type` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `reinsurance_type` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `reinsurer_credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Credit Rating');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `reinsurer_credit_rating` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `reinsurer_credit_rating` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `reinsurer_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer NAIC Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `reinsurer_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `reinsurer_naic_code` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `reinsurer_naic_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Cedant Retention Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `retention_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `ri_recoverable_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recoverable ALAE Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `ri_recoverable_alae_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `ri_recoverable_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recoverable Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `ri_recoverable_loss_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `ri_recoverable_total_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Reinsurance (RI) Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `ri_recoverable_total_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `ri_share_percent` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Share Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'SICS|REINS_MASTER|GUIDEWIRE_CC|DUCK_CREEK|SAPIENS_IDIT');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `treaty_type` SET TAGS ('dbx_business_glossary_term' = 'Treaty Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `treaty_type` SET TAGS ('dbx_value_regex' = 'quota_share|excess_of_loss|cat_xl|surplus_share|facultative_obligatory');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `uncollectible_amount` SET TAGS ('dbx_business_glossary_term' = 'Uncollectible Reinsurance Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `uncollectible_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` SET TAGS ('dbx_subdomain' = 'payment_processing');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `structured_settlement_id` SET TAGS ('dbx_business_glossary_term' = 'Structured Settlement ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `claimant_id` SET TAGS ('dbx_business_glossary_term' = 'Claimant Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Entity Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `payment_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_business_glossary_term' = 'Accounting Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_value_regex' = 'STAT|GAAP|IFRS17');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `agreement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Agreement Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `annuity_contract_number` SET TAGS ('dbx_business_glossary_term' = 'Annuity Contract Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `annuity_cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Annuity Cost Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `annuity_cost_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `annuity_provider_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Annuity Provider NAIC Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `annuity_provider_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `annuity_provider_name` SET TAGS ('dbx_business_glossary_term' = 'Annuity Provider Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `annuity_provider_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `annuity_provider_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `broker_name` SET TAGS ('dbx_business_glossary_term' = 'Settlement Broker Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `broker_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `broker_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `claimant_tax_identification_number` SET TAGS ('dbx_business_glossary_term' = 'Claimant Tax Identification Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `claimant_tax_identification_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `claimant_tax_identification_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `cola_rate` SET TAGS ('dbx_business_glossary_term' = 'Cost-of-Living Adjustment (COLA) Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Company NAIC Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `court_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Court Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `court_approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Court Approval Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `date_of_loss` SET TAGS ('dbx_business_glossary_term' = 'Date of Loss (DOL)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `discount_rate` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `guarantee_period_years` SET TAGS ('dbx_business_glossary_term' = 'Guarantee Period (Years)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `payment_end_date` SET TAGS ('dbx_business_glossary_term' = 'Payment End Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|lump_sum|irregular');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `payment_start_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Start Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `periodic_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Periodic Payment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `periodic_payment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `policy_number` SET TAGS ('dbx_business_glossary_term' = 'Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `present_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Present Value Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `present_value_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `qualified_assignment_company` SET TAGS ('dbx_business_glossary_term' = 'Qualified Assignment Company Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `qualified_assignment_flag` SET TAGS ('dbx_business_glossary_term' = 'Qualified Assignment Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `ri_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `ri_recoverable_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `ri_recoverable_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recoverable Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `settlement_number` SET TAGS ('dbx_business_glossary_term' = 'Structured Settlement Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `settlement_number` SET TAGS ('dbx_value_regex' = '^SS-[0-9]{4}-[0-9]{8}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `settlement_status` SET TAGS ('dbx_business_glossary_term' = 'Structured Settlement Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `settlement_status` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|active|in_force|terminated|voided');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `settlement_type` SET TAGS ('dbx_business_glossary_term' = 'Structured Settlement Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `settlement_type` SET TAGS ('dbx_value_regex' = 'periodic_payment|lump_sum_plus_periodic|life_contingent|life_with_period_certain|joint_and_survivor');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'GUIDEWIRE_CC|DUCK_CREEK_CLAIMS|SAPIENS_IDIT|MANUAL');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Termination Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `total_payout_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Payout Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `total_payout_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` SET TAGS ('dbx_subdomain' = 'reserve_management');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `development_triangle_id` SET TAGS ('dbx_business_glossary_term' = 'Development Triangle ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `cat_event_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `reserve_study_id` SET TAGS ('dbx_business_glossary_term' = 'Reserve Study Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_business_glossary_term' = 'Accounting Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_value_regex' = 'STAT|GAAP|IFRS');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `actuarial_opinion_reference` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Opinion Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `actuarial_segment_code` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Segment Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `appointed_actuary_name` SET TAGS ('dbx_business_glossary_term' = 'Appointed Actuary Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `appointed_actuary_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `appointed_actuary_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `bf_ultimate_loss_estimate` SET TAGS ('dbx_business_glossary_term' = 'Bornhuetter-Ferguson (BF) Ultimate Loss Estimate');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `cat_event_indicator` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `closed_claim_count` SET TAGS ('dbx_business_glossary_term' = 'Closed Claim Count');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Company NAIC Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `cumulative_incurred_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Incurred Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `cumulative_incurred_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Incurred Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `cumulative_ldf` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Loss Development Factor (LDF)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `cumulative_paid_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Paid Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `cumulative_paid_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Paid Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `development_age_months` SET TAGS ('dbx_business_glossary_term' = 'Development Age (Months)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `development_age_months` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `development_age_months` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `ep_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `evaluation_date` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `evaluation_period_type` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Period Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `evaluation_period_type` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `expected_loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Expected Loss Ratio (ELR)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `ibner_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred But Not Enough Reported (IBNER) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `ibnr_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred But Not Reported (IBNR) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `large_loss_indicator` SET TAGS ('dbx_business_glossary_term' = 'Large Loss Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `large_loss_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Large Loss Threshold Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `lob_description` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Description');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `open_claim_count` SET TAGS ('dbx_business_glossary_term' = 'Open Claim Count');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `report_year` SET TAGS ('dbx_business_glossary_term' = 'Report Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `reported_claim_count` SET TAGS ('dbx_business_glossary_term' = 'Reported Claim Count');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `reserve_basis` SET TAGS ('dbx_business_glossary_term' = 'Reserve Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `reserve_basis` SET TAGS ('dbx_value_regex' = 'gross|net_of_ri|ceded');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `source_extract_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Source Extract Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'ARIUS|RESQ|CLAIMCENTER|DUCK_CREEK|SAPIENS|MANUAL');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `stat_line_code` SET TAGS ('dbx_business_glossary_term' = 'Statutory Line of Business Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `tail_factor` SET TAGS ('dbx_business_glossary_term' = 'Tail Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `triangle_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Triangle Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `triangle_status` SET TAGS ('dbx_business_glossary_term' = 'Triangle Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `triangle_status` SET TAGS ('dbx_value_regex' = 'draft|preliminary|final|superseded|archived');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `triangle_type` SET TAGS ('dbx_business_glossary_term' = 'Triangle Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `triangle_type` SET TAGS ('dbx_value_regex' = 'paid_loss|incurred_loss|paid_alae|incurred_alae|paid_lae|case_reserve');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `ultimate_loss_estimate` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Loss Estimate');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ALTER COLUMN `wp_amount` SET TAGS ('dbx_business_glossary_term' = 'Written Premium (WP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` SET TAGS ('dbx_subdomain' = 'reserve_management');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `stat_reserve_exhibit_id` SET TAGS ('dbx_business_glossary_term' = 'Statutory Reserve Exhibit ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `cat_event_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `reserve_evaluation_id` SET TAGS ('dbx_business_glossary_term' = 'Reserve Evaluation ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_business_glossary_term' = 'Accounting Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_value_regex' = 'SAP|GAAP|IFRS17');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `actuarial_method` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Method');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `actuarial_opinion_reference` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Opinion Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `appointed_actuary_credential` SET TAGS ('dbx_business_glossary_term' = 'Appointed Actuary Credential');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `appointed_actuary_name` SET TAGS ('dbx_business_glossary_term' = 'Appointed Actuary Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `appointed_actuary_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `appointed_actuary_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `appointed_actuary_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `cat_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Company NAIC Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `company_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `development_period_months` SET TAGS ('dbx_business_glossary_term' = 'Development Period (Months)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `ep_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `exhibit_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Statutory Exhibit Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `exhibit_reference_number` SET TAGS ('dbx_value_regex' = '^STAT-[0-9]{4}-[A-Z0-9]{2,10}-[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `exhibit_status` SET TAGS ('dbx_business_glossary_term' = 'Exhibit Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `exhibit_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|certified|filed|amended|superseded');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `expected_loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Expected Loss Ratio (ELR)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `filing_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `filing_year` SET TAGS ('dbx_business_glossary_term' = 'Filing Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `gross_case_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Case Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `gross_ibnr_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Incurred But Not Reported (IBNR) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `gross_incurred_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Incurred Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `gross_incurred_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Incurred Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `gross_paid_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Paid Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `gross_paid_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Paid Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `gross_total_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Total Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `lob_description` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Description');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `net_case_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Case Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `net_ibnr_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Incurred But Not Reported (IBNR) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `net_incurred_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Incurred Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `net_loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Net Loss Ratio (LR)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `net_paid_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Paid Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `net_total_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Total Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `prior_valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Prior Valuation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `reserve_basis` SET TAGS ('dbx_business_glossary_term' = 'Reserve Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `reserve_basis` SET TAGS ('dbx_value_regex' = 'accident_year|policy_year|report_year');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `reserve_development_amount` SET TAGS ('dbx_business_glossary_term' = 'Reserve Development Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `ri_recoverable_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recoverable Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `ri_recoverable_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recoverable Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `schedule_p_part` SET TAGS ('dbx_business_glossary_term' = 'Schedule P Part');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `schedule_p_part` SET TAGS ('dbx_value_regex' = 'Part1|Part2|Part3|Part4|Part5|Part6');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `selected_ldf` SET TAGS ('dbx_business_glossary_term' = 'Selected Loss Development Factor (LDF)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `ulr` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Loss Ratio (ULR)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `ultimate_loss_estimate` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Loss Estimate');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` SET TAGS ('dbx_subdomain' = 'reserve_management');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `cat_event_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for cat_event');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Excess of Loss (CAT XL) Treaty ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `affected_counties` SET TAGS ('dbx_business_glossary_term' = 'Affected Counties');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `affected_states` SET TAGS ('dbx_business_glossary_term' = 'Affected States');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `cat_bond_triggered_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Bond Triggered Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `cat_close_date` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Close Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `cat_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `cat_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `cat_event_status` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `cat_event_status` SET TAGS ('dbx_value_regex' = 'open|closed|pending_closure|reopened|archived');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `cat_open_date` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Open Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `cat_xl_triggered_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Excess of Loss (CAT XL) Triggered Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `closed_claim_count` SET TAGS ('dbx_business_glossary_term' = 'Closed Claim Count');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `company_loss_estimate_amount` SET TAGS ('dbx_business_glossary_term' = 'Company Loss Estimate Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `company_ultimate_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Company Ultimate Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `declaration_date` SET TAGS ('dbx_business_glossary_term' = 'Declaration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `event_description` SET TAGS ('dbx_business_glossary_term' = 'Event Description');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `event_end_date` SET TAGS ('dbx_business_glossary_term' = 'Event End Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `event_start_date` SET TAGS ('dbx_business_glossary_term' = 'Event Start Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_value_regex' = 'local|regional|multi_state|national');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `ibnr_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred But Not Reported (IBNR) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `industry_loss_estimate_amount` SET TAGS ('dbx_business_glossary_term' = 'Industry Loss Estimate Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `industry_loss_estimate_date` SET TAGS ('dbx_business_glossary_term' = 'Industry Loss Estimate Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `industry_loss_estimate_source` SET TAGS ('dbx_business_glossary_term' = 'Industry Loss Estimate Source');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `cat_event_name` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `cat_event_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `cat_event_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `net_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `open_claim_count` SET TAGS ('dbx_business_glossary_term' = 'Open Claim Count');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `peril_type` SET TAGS ('dbx_business_glossary_term' = 'Peril Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `pml_tier` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Tier');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `pml_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3|tier_4|non_pml');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `reported_claim_count` SET TAGS ('dbx_business_glossary_term' = 'Reported Claim Count');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `ri_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `stat_reporting_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Statutory (STAT) Reporting Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `stat_reporting_required_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `stat_reporting_required_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `total_case_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Case Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `total_incurred_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Incurred Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `total_paid_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Paid Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ALTER COLUMN `ulae_amount` SET TAGS ('dbx_business_glossary_term' = 'Unallocated Loss Adjustment Expense (ULAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study` SET TAGS ('dbx_subdomain' = 'reserve_management');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study` ALTER COLUMN `reserve_study_id` SET TAGS ('dbx_business_glossary_term' = 'Reserve Study Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study` ALTER COLUMN `actuary_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study` ALTER COLUMN `actuary_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study` ALTER COLUMN `actuary_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study` ALTER COLUMN `approved_by` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study` ALTER COLUMN `coverage_type` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study` ALTER COLUMN `coverage_type` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study` ALTER COLUMN `data_quality_rating` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study` ALTER COLUMN `data_quality_rating` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study` ALTER COLUMN `salvage_subrogation_amount` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study` ALTER COLUMN `salvage_subrogation_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study` ALTER COLUMN `study_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_study` ALTER COLUMN `study_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` SET TAGS ('dbx_subdomain' = 'reserve_management');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` ALTER COLUMN `actuarial_analyst_id` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Analyst Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` ALTER COLUMN `continuing_education_hours` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` ALTER COLUMN `continuing_education_hours` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` ALTER COLUMN `department_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` ALTER COLUMN `department_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
