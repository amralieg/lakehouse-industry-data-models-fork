-- Schema for Domain: claimfinancials | Business: Pc_Insurance | Version: v1_mvm
-- Generated on: 2026-09-20 21:40:51

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_blog_v499`.`claimfinancials` COMMENT 'Provisional description for user-specified domain claim_financials. Awaiting a generated description of what this domain owns.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` (
    `reserve_id` BIGINT COMMENT 'Unique surrogate identifier for each reserve position record. One row per reserve type per claim exposure per accounting period. Grain: one reserve movement per claim exposure per period.',
    `accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this reserve position is recorded. Enables calendar year, accident year, and policy year reserve triangles.',
    `adjuster_id` BIGINT COMMENT 'Reference to the adjuster who authorized or last modified this reserve position. Required for reserve authority and audit trail.',
    `approved_by_party_id` BIGINT COMMENT 'Reference to the party (supervisor or manager) who approved this reserve movement when it exceeded adjuster authority limits. Null if no approval was required.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the claim exposure (coverage line within a claim) to which this reserve position belongs. Links reserve to a specific coverage and insured risk within the claim.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim record. Denormalized for direct claim-level aggregation and reporting without joining through claim exposure.',
    `coverage_id` BIGINT COMMENT 'Reference to the coverage under which this reserve is established. Supports reserve analysis by coverage type and line of business.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Multi-currency claim operations require currency master for exchange rate lookup, functional currency conversion, rounding rules, and financial consolidation.',
    `financial_transaction_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.financial_transaction. Business justification: Every reserve movement (case, IBNR, LAE) generates an atomic double-entry posting in financial_transaction.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Actuarial reserve adequacy analysis, NAIC Schedule P reporting, and regulatory reserve filings require joining reserve transactions to LOB master for proper line classification, loss',
    `litigation_id` BIGINT COMMENT 'Foreign key linking to claims.litigation. Business justification: Litigation reserves are a distinct reserve category (reserve_category field confirms this) set when a claim enters suit.',
    `policy_id` BIGINT COMMENT 'Foreign key linking to policy.policy. Business justification: Reserves are established against specific policies for loss reserve adequacy analysis, IBNR calculations, and statutory reserve reporting.',
    `policy_term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Reserves must link to policy term for accurate loss ratio calculations, earned premium matching, and Schedule P development triangle reporting by accident year and policy year.',
    `ri_claim_cession_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_claim_cession. Business justification: Ceded case reserves and IBNR are booked per claim-level cession for Schedule P and NAIC reporting.',
    `ri_recovery_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_recovery. Business justification: RI recoveries reduce ceded reserves; actuaries link ri_recovery to reserve movements for ceded IBNR runoff and Schedule P loss development analysis.',
    `riskexposure_auto_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.auto_risk. Business justification: Auto liability reserve adequacy benchmarking requires auto risk attributes (territory, use class, radius of operation) for actuarial development factor selection.',
    `riskexposure_insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Actuaries segment reserve adequacy by risk characteristics (construction type, protection class, vehicle type, driver profile) for accurate loss development and catastrophe',
    `accident_year` BIGINT COMMENT 'The calendar year in which the loss event occurred. Used for accident year (AY) loss triangle development and actuarial reserving analysis per NAIC Schedule P.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the reserve movement was approved by the authorizing supervisor or manager. Null if no approval was required for this movement.',
    `authority_limit_amount` DECIMAL(18,2) COMMENT 'Maximum reserve amount the authorizing adjuster is permitted to set without escalation per the claims reserving authority matrix. Supports reserve governance and SOX controls.',
    `basis` STRING COMMENT 'Indicates whether the reserve amounts are stated on a Gross (before reinsurance), Net (after reinsurance), or Ceded (reinsurer share only) basis for this record.. Valid values are `Gross|Net|Ceded`',
    `case_reserve_adequacy_flag` BOOLEAN COMMENT 'Actuarial or supervisory assessment of whether the case reserve is adequate relative to the expected ultimate loss. Used in reserve review and ORSA reporting.',
    `catastrophe_indicator` BOOLEAN COMMENT 'Indicates whether this reserve is associated with a declared catastrophe event. Enables CAT vs. non-CAT reserve segregation for PML analysis and reinsurance recovery tracking.',
    `reserve_category` STRING COMMENT 'Broad financial category of the reserve: Loss (indemnity), Expense (LAE/DCC/AO), Salvage (anticipated recovery from salvage), or Subrogation (anticipated recovery from third parties).. Valid values are `Loss|Expense|Salvage|Subrogation`',
    `ceded_closing_balance_amount` DECIMAL(18,2) COMMENT 'Portion of the closing reserve balance ceded to reinsurers. Net reserve equals closing balance minus ceded closing balance. Required for Schedule F statutory reporting.',
    `ceded_movement_amount` DECIMAL(18,2) COMMENT 'Incremental change in the ceded reserve portion during the accounting period. Supports net reserve calculation and reinsurance bordereaux reporting.',
    `ceded_opening_balance_amount` DECIMAL(18,2) COMMENT 'Portion of the opening reserve balance ceded to reinsurers under applicable treaties or facultative agreements. Used for net reserve and Schedule F reporting.',
    `closing_balance_amount` DECIMAL(18,2) COMMENT 'Reserve balance at the end of the accounting period for this claim exposure and reserve type. Equals opening balance plus movement amount. Gross of reinsurance.',
    `cost_center_code` STRING COMMENT 'Internal cost center to which this reserve is allocated for management accounting and expense reporting purposes. Supports departmental P&L and RBC capital allocation.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this reserve record was first created in the system. Used for audit trail, SOX compliance, and data lineage tracking in the lakehouse silver layer.',
    `development_period` BIGINT COMMENT 'Number of months elapsed from the accident year start to the end of the accounting period. Used to position this reserve in the loss development triangle (e.g., 12, 24, 36 months).',
    `effective_date` DATE COMMENT 'Date on which this reserve position becomes effective for financial reporting purposes. May differ from the transaction date for period-end adjustments and actuarial entries.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this reserve movement is posted in the statutory and GAAP accounting systems. Supports financial close and Schedule P reconciliation.',
    `ibnr_factor` DECIMAL(10,6) COMMENT 'Actuarial development factor applied to derive the IBNR reserve component. Sourced from the actuarial reserving system loss development triangle for the applicable LOB and accident year.',
    `loss_date` DATE COMMENT 'Date of the underlying loss event that gave rise to this claim and reserve. Denormalized from the claim for accident year triangle development without additional joins.',
    `method` STRING COMMENT 'Methodology used to establish or update this reserve: Case_Estimate (adjuster judgment), Formula (system-calculated), Actuarial (actuarial model output), Bulk (portfolio-level), or Tabular (mortality/morbidity table).. Valid values are `Case_Estimate|Formula|Actuarial|Bulk|Tabular`',
    `movement_amount` DECIMAL(18,2) COMMENT 'Incremental change to the reserve during the accounting period. Positive value indicates reserve strengthening; negative value indicates reserve release. Gross of reinsurance.',
    `movement_reason_code` STRING COMMENT 'Coded reason for the reserve movement in this period (e.g., NEW_RESERVE, STRENGTHENING, PARTIAL_RELEASE, FULL_RELEASE, PAYMENT_OFFSET, REOPEN). [ENUM-REF-CANDIDATE',
    `movement_reason_description` STRING COMMENT 'Free-text narrative provided by the adjuster or actuarial team explaining the basis for the reserve movement. Supports audit trail and reserve review documentation.',
    `number` STRING COMMENT 'Externally visible business identifier for this reserve record, typically assigned by the claims management system. Used in bordereaux and statutory reporting.',
    `opening_balance_amount` DECIMAL(18,2) COMMENT 'Reserve balance carried forward from the prior accounting period for this claim exposure and reserve type. Starting point for the period movement calculation.',
    `policy_year` BIGINT COMMENT 'The year in which the policy that generated this claim was written. Supports policy year (PY) reserve development triangles distinct from accident year analysis.',
    `reinsurance_recoverable_amount` DECIMAL(18,2) COMMENT 'Estimated reinsurance recoverable on this reserve position based on applicable treaty or facultative cession. Supports Schedule F reporting and net reserve calculation.',
    `report_date` DATE COMMENT 'Date the claim was first reported to the insurer (FNOL date). Used to compute report lag and support IBNR development analysis in actuarial reserving.',
    `requires_supervisor_approval` BOOLEAN COMMENT 'Indicates whether this reserve movement exceeded the adjuster authority limit and required supervisor or management approval before posting.',
    `reserve_status` STRING COMMENT 'Current lifecycle state of the reserve position. Open reserves are active; Closed reserves have been fully settled or released; Reopened indicates a previously closed reserve reactivated.. Valid values are `Open|Closed|Reopened|Pending|Voided`',
    `reserve_type` STRING COMMENT 'Classification of the reserve: Case (known reported loss), IBNR (Incurred But Not Reported), LAE (Loss Adjustment Expense), ULAE (Unallocated LAE), ALAE (Allocated LAE), or DCC (Defense & Cost Containment).. Valid values are `Case|IBNR|LAE|ULAE|ALAE|DCC`',
    `salvage_anticipated_amount` DECIMAL(18,2) COMMENT 'Estimated salvage recovery anticipated on this claim exposure. Reduces the net reserve position and is reported separately in NAIC statutory filings.',
    `source_system_code` STRING COMMENT 'Identifies the operational system that originated this reserve record: ClaimCenter, DuckCreek, Legacy, Manual (spreadsheet entry), or Actuarial (reserving system upload).. Valid values are `ClaimCenter|DuckCreek|Legacy|Manual|Actuarial`',
    `state_code` STRING COMMENT 'Two-letter US state code where the insured risk is located or the loss occurred. Required for state-level Schedule P statutory reporting and DOI regulatory filings.. Valid values are `^[A-Z]{2}$`',
    `subrogation_anticipated_amount` DECIMAL(18,2) COMMENT 'Estimated subrogation recovery anticipated on this claim exposure. Reduces the net reserve position and is tracked separately for recovery management and statutory reporting.',
    `transaction_date` DATE COMMENT 'Calendar date on which the reserve movement was entered into the claims management system. Used for CY (Calendar Year) reporting and reconciliation to the general ledger.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this reserve record. Used for incremental data pipeline processing, audit trail, and change data capture in the lakehouse.',
    CONSTRAINT pk_reserve PRIMARY KEY(`reserve_id`)
) COMMENT 'Grain: one row per financial movement per claim exposure. Each record represents a single reserve transaction (Case/IBNR/LAE) recorded per Claim Exposure and Accounting Period.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` (
    `claim_payment_id` BIGINT COMMENT 'Unique surrogate identifier for each claim payment disbursement record. Primary key. One row per payment per claim exposure per accounting period.',
    `accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this payment is recognized for statutory and GAAP financial reporting purposes.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Cat-event-level payment aggregation is required for reinsurance bordereaux reporting and treaty recovery billing.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the specific coverage line within the claim (Claim Exposure) against which this payment is charged. Grain anchor per VREQ-007.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim under which this payment is issued. Links payment to the reported loss event.',
    `claim_party_id` BIGINT COMMENT 'System user ID of the claims examiner or supervisor who authorized this payment within the authority limit matrix.',
    `claim_payee_party_id` BIGINT COMMENT 'Reference to the Party record identifying the individual or organization receiving this payment (claimant, vendor, attorney, lienholder, loss payee).',
    `claimant_id` BIGINT COMMENT 'Foreign key linking to claims.claimant. Business justification: Settlement payments are issued to specific claimants. This FK enables per-claimant payment reconciliation, release-signed-date validation before disbursement, 1099 reporting at the claimant',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: International claim payments require currency master for exchange rate application, withholding tax calculation, bank account validation, and functional currency conversion.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Payment authority limits, commission calculations, and loss ratio monitoring are configured by line of business.',
    `litigation_id` BIGINT COMMENT 'Foreign key linking to claims.litigation. Business justification: Settlement and verdict payments directly close or partially satisfy litigation matters. Linking payment to litigation enables litigation cost-to-close analysis, verdict vs.',
    `original_payment_claim_payment_id` BIGINT COMMENT 'Self-referencing identifier pointing to the original payment record when this row represents a reissue or replacement. Null for original disbursements.',
    `payee_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.payee. Business justification: claim_payment carries denormalized payee_name and payee_tax_number that duplicate the authoritative claimfinancials.payee master record.',
    `policy_id` BIGINT COMMENT 'Foreign key linking to policy.policy. Business justification: Payments are made under specific policies for deductible application, policy limit tracking, aggregate limit monitoring, and premium-to-loss reconciliation.',
    `policy_term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Payments must match to the policy term in force at loss date for accurate loss ratio, combined ratio, and loss development analysis by underwriting year.',
    `ri_claim_cession_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_claim_cession. Business justification: Ceded claim payments are billed to reinsurers against specific claim cessions via bordereaux and cash calls.',
    `ri_recovery_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_recovery. Business justification: RI recovery collections are reconciled against specific claim payments for cash application and aged-receivables reporting.',
    `accident_year` BIGINT COMMENT 'Four-digit calendar year in which the loss event occurred. Used for accident year (AY) loss development triangles and actuarial reserving.',
    `ap_batch_number` STRING COMMENT 'Identifier of the AP disbursement batch in which this payment was grouped for bank settlement. Used for batch reconciliation in Oracle/SAP AP module.',
    `authority_limit_amount` DECIMAL(18,2) COMMENT 'Maximum payment amount the authorizing user was permitted to approve per the claims authority matrix at the time of authorization.',
    `bank_account_code` STRING COMMENT 'Internal code identifying the company bank account from which the payment was funded. Supports multi-bank disbursement and reconciliation workflows.',
    `check_eft_reference` STRING COMMENT 'Check number or EFT transaction reference issued by the bank or payment processor. Used for bank reconciliation and stop-payment processing.',
    `cleared_date` DATE COMMENT 'Date the payment instrument cleared the bank. Null until the check or EFT is confirmed settled. Used for outstanding check reconciliation.',
    `cost_center_code` STRING COMMENT 'Internal cost center to which the payment expense is allocated for management accounting and expense ratio reporting.',
    `coverage_type_code` STRING COMMENT 'Code identifying the coverage part under which this payment is charged (e.g., HO-Dwelling, PAP-Liability, CGL-BI). Aligns payment to the policy coverage for Schedule P reporting.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this payment record was first created in the claims management system. Supports audit trail and SOX compliance.',
    `deductible_offset_amount` DECIMAL(18,2) COMMENT 'Amount of the payment attributable to the insureds deductible or Self-Insured Retention (SIR) that is to be collected back from the policyholder.',
    `gl_account_code` STRING COMMENT 'General Ledger account code to which this payment is posted in the statutory and GAAP accounting systems for financial reporting.',
    `gross_payment_amount` DECIMAL(18,2) COMMENT 'Total gross amount disbursed before any deductions, withholdings, or offsets. Denominated in the currency indicated by currency_code.',
    `is_1099_reportable` BOOLEAN COMMENT 'Indicates whether this payment must be reported to the IRS on Form 1099-MISC or 1099-NEC. Drives year-end tax reporting extract.',
    `is_final_payment` BOOLEAN COMMENT 'Indicates this payment closes the claim exposure financially. When true, triggers reserve release and exposure closure workflow in ClaimCenter.',
    `is_structured_settlement` BOOLEAN COMMENT 'Indicates whether this payment is part of a structured settlement annuity arrangement rather than a lump-sum disbursement.',
    `loss_category` STRING COMMENT 'Detailed loss sub-category classifying the nature of the payment: Bodily Injury (BI), Property Damage (PD), Medical Payments (MP), Uninsured Motorist (UM), etc.',
    `net_payment_amount` DECIMAL(18,2) COMMENT 'Actual amount disbursed to the payee after withholding and deductions. Net = gross_payment_amount minus withholding_amount.',
    `payment_authorization_code` STRING COMMENT 'Internal authorization or approval code assigned by the claims supervisor or authority matrix before payment release. Supports SOX payment controls.',
    `payment_date` DATE COMMENT 'Calendar date on which the payment was issued or disbursed to the payee. Used for calendar year (CY) and accident year (AY) loss reporting.',
    `payment_description` STRING COMMENT 'Free-text narrative describing the purpose or nature of the payment (e.g., Partial settlement for dwelling damage, Attorney fee disbursement).',
    `payment_method` STRING COMMENT 'Instrument or mechanism used to disburse funds to the payee (paper check, ACH, wire transfer, EFT, draft, or virtual card).. Valid values are `Check|ACH|Wire|EFT|Draft|Virtual Card`',
    `payment_number` STRING COMMENT 'Externally visible, human-readable payment reference number assigned by the claims payment system or AP module. Used for reconciliation and payee inquiries.',
    `payment_status` STRING COMMENT 'Current lifecycle state of the payment instrument. Tracks issuance through clearance, void, stop-payment, reissue, and return workflows in ClaimCenter.. Valid values are `Issued|Cleared|Voided|Stopped|Reissued|Returned`',
    `payment_type` STRING COMMENT 'Classification of the payment by financial category: indemnity (loss), medical, Loss Adjustment Expense (LAE), Defense & Cost Containment (DCC), Adjusting & Other (AO), or recovery offset.',
    `policy_year` BIGINT COMMENT 'Four-digit year of the policy period under which the loss is covered. Used for policy year (PY) loss development and reinsurance treaty year allocation.',
    `reinsurance_recoverable_amount` DECIMAL(18,2) COMMENT 'Portion of this payment expected to be recovered from reinsurers under applicable treaty or facultative agreements. Used for net loss reporting.',
    `reissue_date` DATE COMMENT 'Date a replacement payment was reissued after a void or stop-payment. Links to the original payment via original_payment_id for audit trail.',
    `remittance_memo` STRING COMMENT 'Short memo line printed on the check or included in the EFT remittance advice to the payee. Typically includes claim number and coverage description.',
    `siu_referral_flag` BOOLEAN COMMENT 'Indicates this payment was flagged for Special Investigations Unit (SIU) review due to suspected fraud. Payment may be held pending SIU clearance.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this payment record was ingested into the lakehouse Silver layer.. Valid values are `ClaimCenter|DuckCreek|Legacy|Manual`',
    `state_jurisdiction_code` STRING COMMENT 'Two-letter US state code of the jurisdiction governing this payment for regulatory reporting and state DOI compliance purposes.. Valid values are `^[A-Z]{2}$`',
    `stop_payment_flag` BOOLEAN COMMENT 'Indicates a stop-payment order has been placed on this check with the issuing bank. Triggers reissue workflow and outstanding check reconciliation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this payment record. Used for incremental data pipeline processing and audit trail.',
    `void_date` DATE COMMENT 'Date the payment was voided. Populated only when payment_status is Voided. Triggers reversal entries in the general ledger.',
    `withholding_amount` DECIMAL(18,2) COMMENT 'Amount withheld from the gross payment for tax withholding, Medicare Set-Aside (MSA), or other statutory deductions before net disbursement.',
    CONSTRAINT pk_claim_payment PRIMARY KEY(`claim_payment_id`)
) COMMENT 'Grain: one row per financial movement per claim exposure. Each record represents a single payment transaction recorded per Claim Exposure and Accounting Period.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` (
    `recovery_id` BIGINT COMMENT 'Unique surrogate identifier for each claim recovery transaction. One row per recovery transaction per claim exposure per accounting period.',
    `accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this recovery transaction is recognized for statutory and GAAP financial reporting.',
    `adjuster_id` BIGINT COMMENT 'Reference to the claims adjuster or recovery specialist responsible for managing and pursuing this recovery transaction.',
    `attorney_organization_id` BIGINT COMMENT 'Foreign key linking to party.organization. Business justification: Recovery (salvage, subrogation, reinsurance) often involves legal counsel. Law firms are organizations requiring full party attribution for vendor management, payment processing, and',
    `cession_id` BIGINT COMMENT 'Reference to the reinsurance cession record when recovery_type is reinsurance. Null for subrogation and salvage recoveries.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the specific coverage line within the claim (Claim Exposure) against which this recovery is applied.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim record. Denormalized for direct claim-level reporting and aggregation without joining through claim exposure.',
    `claim_payment_id` BIGINT COMMENT 'Reference to the original claim payment transaction that this recovery offsets. Links recovery to the indemnity payment for net loss calculation.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Subrogation and salvage recoveries must tie to the coverage that paid the original loss for proper reserve relief, reinsurance accounting, and statutory reporting.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Multi-currency recovery operations (reinsurance collections, subrogation from foreign insurers, salvage auctions) require currency master for demand amount conversion, collection tracking',
    `financial_transaction_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.financial_transaction. Business justification: Subrogation collections and salvage proceeds captured in recovery generate financial_transaction postings (recovery income, offset to paid losses).',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Subrogation and salvage recovery tracking, reinsurance recovery allocation, and net loss ratio calculation require LOB master for treaty participation rules, recovery expense',
    `litigation_id` BIGINT COMMENT 'Foreign key linking to claims.litigation. Business justification: Subrogation and other recoveries are frequently collected through litigation. recovery.litigation_flag confirms litigation is tracked on recoveries, but no FK exists.',
    `policy_id` BIGINT COMMENT 'Foreign key linking to policy.policy. Business justification: Recoveries (salvage and subrogation) reduce net incurred loss on specific policies. Policy linkage required for ultimate loss calculation, experience modification rating, and loss cost analysis.',
    `policy_term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Recoveries must link to policy term for accurate net loss ratio calculations and to match recovery timing with the original loss term for loss development analysis.',
    `responsible_party_id` BIGINT COMMENT 'Reference to the party from whom recovery is sought: tortfeasor for subrogation, salvage buyer for salvage, or reinsurer for reinsurance recovery.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the reinsurance agreement (treaty or facultative) under which a reinsurance recovery is claimed. Null for subrogation and salvage.',
    `ri_claim_cession_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_claim_cession. Business justification: Subrogation and salvage recoveries net against ceded losses at the claim-cession level for UNL calculation.',
    `riskexposure_insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Cross-LOB recovery reporting and Schedule P aggregation require linking recovery records to the parent insured risk.',
    `salvage_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.salvage. Business justification: Recovery is the transaction record for collected amounts. Salvage is the master record for salvage activity.',
    `subrogation_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.subrogation. Business justification: Recovery is the transaction record for collected amounts. Subrogation is the master record for a subrogation pursuit.',
    `accident_year` BIGINT COMMENT 'Calendar year in which the loss event occurred. Used for accident year (AY) loss development triangles and actuarial reserving analysis.',
    `bordereaux_period` STRING COMMENT 'YYYY-MM formatted period for which this recovery is included in reinsurance bordereaux reporting to the reinsurer. Applicable for reinsurance recoveries.. Valid values are `^[0-9]{4}-(0[1-9]|1[0-2])$`',
    `closed_date` DATE COMMENT 'Date on which the recovery file was formally closed, either after full collection, settlement, or abandonment of pursuit.',
    `collected_amount` DECIMAL(18,2) COMMENT 'Gross amount actually received from the responsible party or reinsurer prior to deducting collection expenses or attorney fees.',
    `collected_date` DATE COMMENT 'Date on which recovery funds were actually received and posted. Null if recovery has not yet been collected.',
    `collection_expense_amount` DECIMAL(18,2) COMMENT 'Costs incurred to pursue and collect the recovery, including attorney fees, court costs, and investigation expenses. Deducted to derive net recovery.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this recovery record was first created in the system. Used for audit trail, SOX compliance, and data lineage tracking.',
    `demand_amount` DECIMAL(18,2) COMMENT 'Gross amount formally demanded from the responsible party or reinsurer. Represents the maximum expected recovery before negotiation or adjustment.',
    `demand_date` DATE COMMENT 'Date on which the formal demand for recovery was first issued to the responsible party, tortfeasor, or reinsurer.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this recovery transaction is posted for statutory and GAAP financial reporting.',
    `litigation_flag` BOOLEAN COMMENT 'Indicates whether legal action has been filed to pursue this recovery. True when a lawsuit or arbitration proceeding is active.',
    `method` STRING COMMENT 'Mechanism used to pursue or collect the recovery. [ENUM-REF-CANDIDATE: demand_letter|litigation|negotiated_settlement|auction|bordereaux|direct_bill — promote to reference product]. Valid values are `demand_letter|litigation|negotiated_settlement|auction|bordereaux|direct_bill`',
    `net_amount` DECIMAL(18,2) COMMENT 'Net recovery amount after deducting collection expenses from collected amount. Used for statutory reporting and loss ratio calculations (NWP basis).',
    `notes` STRING COMMENT 'Free-text narrative capturing adjuster commentary, negotiation history, legal strategy notes, or other contextual information about this recovery.',
    `number` STRING COMMENT 'Externally visible business identifier for this recovery transaction, used in bordereaux reporting, correspondence, and audit trails.',
    `payment_reference` STRING COMMENT 'Check number, wire transfer reference, EFT trace number, or other payment instrument identifier for the collected recovery funds.',
    `policy_year` BIGINT COMMENT 'Year in which the policy that generated the claim was written. Used for policy year (PY) loss development and reinsurance treaty year allocation.',
    `recovery_status` STRING COMMENT 'Current lifecycle state of the recovery transaction: open (demand issued), collected (funds received), closed (finalized), void (cancelled), or disputed.. Valid values are `open|collected|closed|void|disputed`',
    `recovery_type` STRING COMMENT 'Classifies the nature of the recovery: subrogation (pursuit of third-party tortfeasor), salvage (sale of damaged property), reinsurance (ceded loss recovery), or other.. Valid values are `subrogation|salvage|reinsurance|other`',
    `ri_participation_pct` DECIMAL(7,4) COMMENT 'Percentage of the ceded loss recoverable from the reinsurer under the applicable treaty or facultative agreement (e.g., 0.7500 = 75%).',
    `ri_recovery_basis` STRING COMMENT 'Reinsurance structure under which the recovery is claimed: quota share (QS), excess of loss (XOL), stop loss (SL), or facultative (FAC).. Valid values are `quota_share|excess_of_loss|stop_loss|facultative`',
    `salvage_item_description` STRING COMMENT 'Description of the salvaged property or item sold, including condition, make/model for vehicles, or material type for property salvage.',
    `salvage_type` STRING COMMENT 'Classification of salvage recovery: total loss vehicle, damaged property, scrap material, or auction proceeds. Applicable only when recovery_type is salvage.. Valid values are `total_loss_vehicle|damaged_property|scrap|auction`',
    `siu_referral_flag` BOOLEAN COMMENT 'Indicates whether this recovery has been referred to the Special Investigations Unit (SIU) for fraud investigation or suspicious activity review.',
    `source_system_code` STRING COMMENT 'Identifies the operational system of record that originated this recovery transaction (e.g., ClaimCenter, ReinsurancePro, BillingCenter, or manual entry).. Valid values are `claimcenter|reins_pro|billing|manual`',
    `state_code` STRING COMMENT 'Two-letter US state code for the jurisdiction governing this recovery, used for statutory reporting and state DOI regulatory compliance.. Valid values are `^[A-Z]{2}$`',
    `statute_of_limitations_date` DATE COMMENT 'Date by which legal action must be filed to preserve the right of recovery. Critical for subrogation diary management and SIU oversight.',
    `subrogation_basis` STRING COMMENT 'Legal theory under which subrogation is pursued: tort (negligence), contract (breach), statutory (workers comp lien), or equitable subrogation.. Valid values are `tort|contract|statutory|equitable`',
    `transaction_date` DATE COMMENT 'The real-world date on which the recovery event occurred: demand issued, settlement agreed, payment received, or salvage sale completed.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this recovery record. Used for change data capture, audit trail, and incremental ETL processing.',
    CONSTRAINT pk_recovery PRIMARY KEY(`recovery_id`)
) COMMENT 'Grain: one row per financial movement per claim exposure. Each record represents a single recovery transaction (Subrogation/Salvage/Reinsurance) recorded per Claim Exposure and Accounting Period.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` (
    `subrogation_id` BIGINT COMMENT 'Unique surrogate identifier for the subrogation pursuit record. One row per subrogation action initiated against a liable third party arising from a paid claim.',
    `accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which the subrogation recovery is recognized for statutory and GAAP financial reporting. Aligns with Schedule P accident year reporting.',
    `attorney_organization_id` BIGINT COMMENT 'Foreign key linking to party.organization. Business justification: Law firms handling subrogation litigation are organizations in the party domain. Tracking counsel requires full organization details for billing, communication, and regulatory reporting.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the specific coverage line (claim exposure) within the claim that generated the subrogation opportunity. Enables per-coverage recovery tracking.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim from which this subrogation pursuit originates. Links the recovery action to the underlying loss event and paid indemnity.',
    `claimant_id` BIGINT COMMENT 'Foreign key linking to claims.claimant. Business justification: Subrogation recovery is pursued on behalf of the specific claimant who suffered the loss. Made-whole doctrine compliance and insured reimbursement calculations (insured_reimbursement_amount',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Cross-border subrogation pursuits against foreign liable parties require currency master for demand amount calculation, settlement negotiation, collection tracking, and insured reimbursement',
    `liable_party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Subrogation pursues recovery from liable third parties who are tracked as party entities. Demand letters, settlement negotiations, and litigation require full party attribution including address',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Subrogation teams are organized by LOB (auto vs. property), recovery benchmarks and pursuit strategies differ by LOB, and regulatory subrogation reporting requires LOB attribution.',
    `litigation_id` BIGINT COMMENT 'Foreign key linking to claims.litigation. Business justification: Subrogation pursued through suit requires reference to the litigation record. subrogation.suit_filed_date, litigation_status, and statute_of_limitations_date confirm litigation is tracked',
    `policy_id` BIGINT COMMENT 'Foreign key linking to policy.policy. Business justification: Subrogation pursuits are policy-specific for tracking recovery potential, adjusting loss experience, and calculating net incurred amounts.',
    `policy_term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Subrogation must link to policy term to match recovery collections with the original loss term for accurate loss development and net loss ratio reporting.',
    `riskexposure_insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Property subrogation (e.g., fire caused by contractor negligence) requires linking the pursuit record to the insured risk for cross-LOB subrogation reporting and reinsurance',
    `arbitration_award_amount` DECIMAL(18,2) COMMENT 'Dollar amount awarded by the arbitration panel in favor of the insurer. May differ from demand amount. Drives final collection and closure processing.',
    `arbitration_filing_date` DATE COMMENT 'Date the subrogation dispute was filed with the arbitration forum. Used to track filing deadlines and arbitration cycle times.',
    `arbitration_forum` STRING COMMENT 'Arbitration body used for intercompany dispute resolution. Arbitration Forums Inc. is standard for auto subrogation. Drives filing fee tracking and award enforcement.. Valid values are `Arbitration Forums|AAA|JAMS|State Court|None`',
    `closed_date` DATE COMMENT 'Date the subrogation pursuit was formally closed in the claims system. Used for cycle time reporting and recovery performance measurement.',
    `closure_reason` STRING COMMENT 'Reason the subrogation pursuit was closed. Required for recovery analytics, SIU referral decisions, and regulatory reporting. [ENUM-REF-CANDIDATE: promote to reference product if values expand]',
    `collected_amount` DECIMAL(18,2) COMMENT 'Total gross amount actually received from the liable party or their insurer to date. Cumulative across all payments. Used in net recovery and loss ratio calculations.',
    `collectible_amount` DECIMAL(18,2) COMMENT 'Estimated collectible portion of the demand amount after applying comparative negligence, policy limits of the liable party, and asset assessment. Used for reserve adequacy.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the subrogation record was first created in the claims management system. Used for audit trail, data lineage, and SOX compliance.',
    `demand_amount` DECIMAL(18,2) COMMENT 'Gross dollar amount demanded from the liable third party, typically equal to total indemnity paid plus allocated loss adjustment expenses (ALAE) on the claim.',
    `demand_date` DATE COMMENT 'Date the formal subrogation demand letter was issued to the liable party or their insurer. Starts the statute of limitations clock for recovery actions.',
    `insured_reimbursement_amount` DECIMAL(18,2) COMMENT 'Portion of the net recovery returned to the insured, typically representing their deductible or uninsured loss. Required by the made-whole doctrine in most jurisdictions.',
    `last_activity_date` DATE COMMENT 'Date of the most recent action taken on the subrogation file (demand, payment received, court filing, etc.). Used for diary management and dormant file identification.',
    `liable_party_claim_number` STRING COMMENT 'Claim number assigned by the liable partys insurer for the same loss event. Enables cross-carrier reconciliation and arbitration tracking.',
    `liable_party_insurer` STRING COMMENT 'Name of the insurance carrier for the liable third party. Used to route intercompany arbitration and direct demand letters to the correct carrier.',
    `liable_party_policy_number` STRING COMMENT 'Policy number of the liable third partys insurance coverage. Required for intercompany arbitration filings and demand correspondence.',
    `litigation_status` STRING COMMENT 'Current stage of legal proceedings for the subrogation pursuit. Drives reserve adequacy reviews and legal expense forecasting. [ENUM-REF-CANDIDATE: promote to reference product if stages expand]',
    `made_whole_indicator` BOOLEAN COMMENT 'Indicates whether the insured has been fully compensated for their loss before the insurer may retain subrogation proceeds. Required by the made-whole doctrine in most states.',
    `negligence_pct` DECIMAL(5,2) COMMENT 'Percentage of fault attributed to the liable third party as determined by investigation or adjudication. Drives the collectible amount calculation under comparative negligence statutes.',
    `net_recovery_amount` DECIMAL(18,2) COMMENT 'Net recovery after deducting recovery expenses from collected amount (collected_amount minus recovery_expense_amount). Represents the actual financial benefit to the insurer.',
    `next_action_date` DATE COMMENT 'Diary date for the next required action on the subrogation file. Drives case management queues and ensures statute of limitations compliance.',
    `notes` STRING COMMENT 'Free-text narrative capturing key developments, negotiation history, legal strategy, and adjuster observations for the subrogation pursuit. Supports case management and audit.',
    `number` STRING COMMENT 'Externally visible business identifier for the subrogation pursuit, used in demand letters, court filings, and bordereaux reporting. Format: SUBR-YYYY-NNNNNNN.. Valid values are `^SUBR-[0-9]{4}-[0-9]{7}$`',
    `opened_date` DATE COMMENT 'Date the subrogation pursuit was formally opened in the claims management system. Used as the start point for cycle time and recovery lag analysis.',
    `pursuit_status` STRING COMMENT 'Current workflow state of the subrogation pursuit. Drives case management queues and recovery reporting. [ENUM-REF-CANDIDATE: Open|Demand Issued|Negotiating|Settled|Collected|Closed - No Recovery|Referred to Litigation — promote to reference product]',
    `recovery_expense_amount` DECIMAL(18,2) COMMENT 'Total allocated expenses incurred in pursuing the subrogation recovery, including attorney fees, court costs, and investigation costs (DCC/ALAE). Deducted to compute net recovery.',
    `recovery_method` STRING COMMENT 'Mechanism used to pursue the subrogation recovery. Intercompany Arbitration applies to auto claims under Arbitration Forum agreements. Drives legal cost allocation.. Valid values are `Demand Letter|Arbitration|Litigation|Intercompany Arbitration|Negotiated Settlement`',
    `referral_date` DATE COMMENT 'Date the subrogation file was referred to outside counsel or a subrogation vendor for legal pursuit. Triggers DCC expense tracking and litigation status updates.',
    `reinsurance_recovery_indicator` BOOLEAN COMMENT 'Indicates whether a portion of the subrogation recovery must be remitted to reinsurers per cession agreements. Triggers reinsurance bordereaux reporting and recovery allocation.',
    `settlement_amount` DECIMAL(18,2) COMMENT 'Agreed gross settlement amount with the liable party. May differ from demand amount due to negotiation, comparative negligence, or policy limits of the liable party.',
    `settlement_date` DATE COMMENT 'Date a settlement agreement was reached with the liable party or their insurer. Triggers final payment processing and closure of the subrogation pursuit.',
    `siu_referral_indicator` BOOLEAN COMMENT 'Indicates whether the subrogation file has been referred to the Special Investigations Unit (SIU) for fraud investigation related to the liable party or loss circumstances.',
    `state_of_loss` STRING COMMENT 'Two-letter US state code where the loss occurred. Determines applicable subrogation statutes, comparative negligence rules, and statute of limitations periods.. Valid values are `^[A-Z]{2}$`',
    `statute_of_limitations_date` DATE COMMENT 'Date by which legal action must be filed to preserve the subrogation right. Calculated from loss date per applicable state statute. Critical for diary and case management.',
    `subrogation_type` STRING COMMENT 'Legal basis of the recovery action: Subrogation (insurer steps into insureds rights), Contribution (recovery from co-insurer), or Indemnification (contractual hold-harmless recovery).. Valid values are `Subrogation|Contribution|Indemnification`',
    `suit_filed_date` DATE COMMENT 'Date the subrogation lawsuit was filed in court. Marks the transition from pre-litigation to litigation phase and triggers enhanced reserve and expense tracking.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the subrogation record. Used for change data capture, audit trail, and incremental ETL processing in the lakehouse.',
    CONSTRAINT pk_subrogation PRIMARY KEY(`subrogation_id`)
) COMMENT 'Master record for a subrogation pursuit against a liable third party. Tracks demand amount, collected amount, attorney assignment, litigation status, settlement date, and net recovery after expenses per claim.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` (
    `salvage_id` BIGINT COMMENT 'Represents the salvage id value associated with the salvage entity in the claimfinancials domain.',
    `accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which salvage proceeds are recognized for statutory and GAAP reporting.',
    `buyer_party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Salvage buyers (auto auctions, scrap dealers) must be tracked as parties for 1099 tax reporting, OFAC screening, and fraud detection.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: salvage.catastrophe_code is a denormalized string representing the catastrophe_event entity.',
    `claim_exposure_id` BIGINT COMMENT 'Represents the claim exposure id value associated with the salvage entity in the claimfinancials domain.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim under which this salvage activity is recorded.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Salvage auction proceeds, storage costs, and net salvage calculations require currency master for multi-currency total loss settlements, reinsurance salvage share allocation, and functional',
    `insured_risk_id` BIGINT COMMENT 'Reference to the insured risk (vehicle, property, etc.) that is the subject of salvage disposition.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Salvage disposition processes and recovery rates differ materially by LOB (auto total-loss vs. commercial property salvage).',
    `policy_id` BIGINT COMMENT 'Foreign key linking to policy.policy. Business justification: Salvage items are recovered from specific policy losses for net loss calculation, total loss determination, and deductible application. Policy linkage required for accurate loss cost analysis.',
    `policy_term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Salvage must link to policy term to match salvage proceeds with the original loss term for accurate net loss ratio and loss development reporting.',
    `riskexposure_property_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.property_risk. Business justification: Salvage teams coordinate property demolition, environmental remediation, and land sale with specific property characteristics.',
    `riskexposure_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.vehicle. Business justification: Salvage vendors require VIN, title number, and vehicle specifications for auction processing and title transfer.',
    `vendor_payee_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.payee. Business justification: Salvage has vendor_name and vendor_code (STRING) for the salvage vendor (auction house, salvage yard). Vendors are payees. Adding vendor_payee_id FK normalizes vendor master data.',
    `assigned_date` DATE COMMENT 'Date the salvage item was formally assigned to the salvage vendor or auction house for disposition.',
    `auction_date` DATE COMMENT 'Date on which the salvaged item was auctioned or sold. Used to align proceeds recognition with the correct accounting period.',
    `auction_fee` DECIMAL(18,2) COMMENT 'Fee charged by the auction house or salvage vendor for facilitating the sale, deducted from gross proceeds to arrive at net salvage.',
    `auction_proceeds` DECIMAL(18,2) COMMENT 'Gross cash proceeds received from the auction or direct sale of the salvaged item before deducting storage, towing, and auction fees.',
    `buyer_type` STRING COMMENT 'Classification of the salvage buyer. Determines applicable title transfer rules and tax reporting obligations.. Valid values are `dealer|individual|insurer|scrap_yard|auction_house`',
    `certificate_number` STRING COMMENT 'Certificate of destruction or salvage certificate number issued by the state DMV or relevant authority for the disposed item.',
    `closed_date` DATE COMMENT 'Date the salvage activity was closed, indicating all proceeds collected, title transferred, and financials reconciled.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the salvage record was first created in the claims management system.',
    `disposition_method` STRING COMMENT 'Method by which the salvaged item is disposed of. Impacts net salvage calculation and title transfer obligations.. Valid values are `auction|direct_sale|scrap|donation|insurer_retained|third_party_buyer`',
    `gl_account_code` STRING COMMENT 'GL account code to which the net salvage proceeds are posted in the statutory and GAAP general ledger.',
    `insured_retained_indicator` BOOLEAN COMMENT 'Indicates whether the insured elected to retain the salvaged item, resulting in a deduction from the total-loss settlement payment.',
    `insured_retention_deduction` DECIMAL(18,2) COMMENT 'Amount deducted from the total-loss settlement when the insured elects to retain the salvaged item, equal to the salvage value estimate.',
    `item_description` STRING COMMENT 'Free-text description of the salvaged item including make, model, year, condition, or property type to support valuation and disposition.',
    `net_salvage_amount` DECIMAL(18,2) COMMENT 'Net proceeds from salvage after deducting storage, towing, and auction fees from gross auction proceeds. Credited against claim payments.',
    `notes` STRING COMMENT 'Free-text adjuster notes capturing disposition decisions, buyer negotiations, title issues, or other relevant salvage activity details.',
    `number` STRING COMMENT 'Externally visible business identifier for the salvage record, used in bordereaux, vendor communications, and regulatory filings.. Valid values are `^SAL-[0-9]{4}-[0-9]{6}$`',
    `reinsurance_recoverable_indicator` BOOLEAN COMMENT 'Indicates whether a portion of the net salvage proceeds is recoverable by or creditable to a reinsurer under treaty or facultative agreement.',
    `reinsurance_salvage_share` DECIMAL(18,2) COMMENT 'Portion of net salvage proceeds attributable to reinsurers under applicable treaty or facultative agreement, per SSAP No. 62R.',
    `salvage_status` STRING COMMENT 'Current lifecycle state of the salvage activity. Drives workflow in ClaimCenter Recovery module and financial recognition timing.. Valid values are `open|pending_auction|sold|title_transferred|closed|voided`',
    `salvage_type` STRING COMMENT 'Classification of the salvage by asset category. Determines applicable disposition rules, title transfer requirements, and accounting treatment.. Valid values are `total_loss_vehicle|total_loss_property|partial_salvage|marine_salvage|equipment`',
    `siu_referral_indicator` BOOLEAN COMMENT 'Indicates whether this salvage activity has been referred to the SIU for fraud investigation (e.g., staged total loss).',
    `state_code` STRING COMMENT 'Two-letter US state code where the salvage activity occurs, used for state DOI reporting and title transfer jurisdiction.. Valid values are `^[A-Z]{2}$`',
    `storage_cost` DECIMAL(18,2) COMMENT 'Cumulative cost of storing the salvaged item from date of loss to date of disposition, deducted from gross proceeds.',
    `storage_end_date` DATE COMMENT 'Date the salvaged item was removed from storage upon sale, transfer, or destruction.',
    `storage_location` STRING COMMENT 'Address or facility name where the salvaged item is stored pending auction or disposition.',
    `storage_start_date` DATE COMMENT 'Date the salvaged item entered storage, used to calculate accrued storage costs and vendor billing.',
    `title_number` STRING COMMENT 'State-issued salvage title number assigned to the vehicle or property after total-loss declaration, required for legal resale.',
    `title_received_date` DATE COMMENT 'Date the insurer physically received the signed title document from the insured, initiating the transfer process.',
    `title_transfer_date` DATE COMMENT 'Date on which the title of the salvaged item was legally transferred from the insured to the insurer or designated buyer.',
    `title_transfer_status` STRING COMMENT 'Status of the vehicle or property title transfer from the insured to the insurer or salvage buyer. Required for total-loss compliance.. Valid values are `not_required|pending|transferred|rejected`',
    `total_loss_indicator` BOOLEAN COMMENT 'Indicates whether the insured item was declared a total loss, triggering full salvage disposition and title transfer requirements.',
    `towing_cost` DECIMAL(18,2) COMMENT 'Cost of towing or transporting the salvaged item to the storage yard or auction facility, deducted from gross proceeds.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the salvage record, supporting audit trail and change tracking requirements.',
    `value_estimate` DECIMAL(18,2) COMMENT 'Appraised or estimated market value of the salvaged item prior to auction or sale, used to set reserve and evaluate offers.',
    `vin` STRING COMMENT '17-character Vehicle Identification Number for salvaged vehicles, used for title transfer, DMV reporting, and CLUE database updates.. Valid values are `^[A-HJ-NPR-Z0-9]{17}$`',
    CONSTRAINT pk_salvage PRIMARY KEY(`salvage_id`)
) COMMENT 'Grain: one row per salvage financial movement per claim exposure. Records proceeds recovered by taking title to damaged property. FK to claim_exposure_id and accounting_period_id. PK: salvage_id.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` (
    `claim_expense_id` BIGINT COMMENT 'Unique surrogate identifier for each claim expense transaction record. Primary key for the claim_expense table. One row per expense movement per claim exposure and accounting period.',
    `accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this expense transaction is recognized for statutory and GAAP financial reporting purposes.',
    `adjuster_id` BIGINT COMMENT 'Reference to the claims adjuster responsible for authorizing or submitting this expense. Links expense to the handling adjuster for workload and cost reporting.',
    `approved_by_party_id` BIGINT COMMENT 'Reference to the party (adjuster supervisor or manager) who approved this expense transaction. Required for audit trail and authority-level compliance.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Cat treaties frequently cover ALAE and ULAE. Insurers must aggregate LAE by cat event for reinsurance treaty billing and NAIC Schedule P cat reporting.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the claim exposure (coverage line within a claim) to which this expense is allocated. Links expense to the specific coverage and insured risk.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim record. Enables direct claim-level aggregation of all expense transactions without joining through claim exposure.',
    `claimant_id` BIGINT COMMENT 'Foreign key linking to claims.claimant. Business justification: Defense costs and medical expenses (is_dcc_expense flag confirms this) are incurred per claimant.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: LAE allocation to coverage line is required for Schedule P reporting, reinsurance bordereaux, and actuarial reserving.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Multi-currency claim expense processing (foreign adjuster fees, international expert invoices, cross-border legal costs) requires currency master for functional currency conversion',
    `financial_transaction_id` BIGINT COMMENT 'The native transaction identifier from the originating system of record (e.g., Guidewire ClaimCenter expense ID). Enables traceability back to the source system.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: LAE allocation, expense ratio monitoring, and reinsurance expense recovery require LOB master for ALAE vs ULAE classification rules, treaty expense participation, and regulatory',
    `litigation_id` BIGINT COMMENT 'Foreign key linking to claims.litigation. Business justification: Defense costs (is_dcc_expense flag) are billed against specific litigation matters. Legal bill review systems and litigation management platforms require linking DCC expenses to the',
    `original_expense_claim_expense_id` BIGINT COMMENT 'For reversal transactions, references the claim_expense_id of the original expense being reversed. Null for original (non-reversal) expense transactions.',
    `payee_id` BIGINT COMMENT 'Reference to the party record of the vendor or service provider who rendered the service and generated this expense (e.g., law firm, medical examiner, appraiser).',
    `policy_id` BIGINT COMMENT 'Foreign key linking to policy.policy. Business justification: Defense and cost containment expenses (ALAE/ULAE) are allocated to policies for combined ratio, expense ratio, and loss adjustment expense ratio analysis. Required for profitability measurement.',
    `policy_term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: LAE must match to policy term for accurate loss adjustment expense ratio calculations and to align expense recognition with earned premium by underwriting period.',
    `ri_claim_cession_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_claim_cession. Business justification: Ceded LAE (Loss Adjustment Expenses) are reported per claim cession in Schedule P Part 2 and reinsurer bordereaux.',
    `riskexposure_insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Expense management tracks inspection costs by property type, engineering report costs by construction class, and appraisal fees by vehicle type.',
    `accident_year` BIGINT COMMENT 'The calendar year in which the underlying loss event occurred. Used for accident-year LAE development triangles and actuarial reserving analysis.',
    `approval_date` DATE COMMENT 'Date on which the expense was approved by the authorized approver. Used for SLA measurement and audit trail documentation.',
    `approval_status` STRING COMMENT 'Approval workflow status for the expense. Expenses above authority thresholds require supervisor or management approval before payment can be issued.. Valid values are `pending|approved|rejected|escalated`',
    `check_number` STRING COMMENT 'Check or EFT reference number issued for payment of this expense. Used for bank reconciliation and positive pay verification. Null for non-check payments.',
    `cost_center_code` STRING COMMENT 'Internal cost center or department code responsible for this expense. Supports management reporting, expense allocation, and budget variance analysis.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this expense record was first created in the system. Used for audit trail, data lineage, and regulatory record-retention compliance.',
    `exchange_rate` DECIMAL(18,6) COMMENT 'Exchange rate applied to convert the expense from transaction currency to functional currency at the transaction date. Stored for audit and restatement purposes.',
    `expense_amount` DECIMAL(18,2) COMMENT 'Gross amount of the expense transaction in the policy currency before any adjustments or recoveries. Positive for charges; negative for reversals or credits.',
    `expense_date` DATE COMMENT 'The date on which the expense was incurred or the service was rendered. Used for accident-year and policy-year LAE allocation in Schedule P reporting.',
    `expense_description` STRING COMMENT 'Free-text description of the services rendered or expense incurred as provided by the adjuster or vendor. Used for audit review and dispute resolution.',
    `expense_number` STRING COMMENT 'Externally visible, human-readable identifier for this expense transaction. Used in vendor correspondence, GL postings, and audit trails.. Valid values are `^EXP-[0-9]{10}$`',
    `expense_status` STRING COMMENT 'Current workflow state of the expense transaction from initial entry through approval, payment, and potential voiding or dispute resolution.. Valid values are `draft|submitted|approved|paid|voided|disputed`',
    `expense_type` STRING COMMENT 'Detailed classification of the nature of the expense. Drives GL account mapping and regulatory cost categorization. [ENUM-REF-CANDIDATE: legal_fee|expert_witness|medical_exam|investigation|appraisal|court_cost|adjuster_fee|other — promote to reference',
    `functional_currency_amount` DECIMAL(18,2) COMMENT 'Expense amount converted to the company functional currency (USD) using the exchange rate at transaction date. Used for consolidated statutory and GAAP reporting.',
    `gl_account_code` STRING COMMENT 'The GL account code to which this expense is posted in the general ledger. Drives statutory Schedule P line assignment and GAAP income statement classification.',
    `invoice_date` DATE COMMENT 'Date printed on the vendor invoice. Used for accounts payable aging, payment terms calculation, and late-payment penalty assessment.',
    `invoice_number` STRING COMMENT 'The invoice or billing reference number issued by the vendor. Used for three-way matching (PO, receipt, invoice) and duplicate payment prevention.',
    `invoice_received_date` DATE COMMENT 'Date the invoice was received by the claims department. Used to measure vendor billing timeliness and trigger payment due-date calculations.',
    `is_dcc_expense` BOOLEAN COMMENT 'Indicates whether this expense is classified as Defense and Cost Containment (DCC) per NAIC Schedule P definitions. Distinct from AO (Adjusting and Other) expenses.',
    `is_recoverable` BOOLEAN COMMENT 'Indicates whether this expense is subject to reinsurance recovery under a treaty or facultative agreement. Drives cession and bordereaux reporting.',
    `lae_category` STRING COMMENT 'Classifies the expense into LAE sub-categories: ALAE (Allocated LAE), ULAE (Unallocated LAE), DCC (Defense and Cost Containment), or AO (Adjusting and Other). Required for Schedule P.. Valid values are `ALAE|ULAE|DCC|AO`',
    `payment_date` DATE COMMENT 'The date on which the expense was actually disbursed to the vendor or payee. Null if the expense has not yet been paid. Used for cash-basis reporting.',
    `payment_method` STRING COMMENT 'Method by which the expense was or will be disbursed to the vendor. Drives accounts payable processing and bank reconciliation workflows.. Valid values are `check|ach|wire|credit_card|eft`',
    `policy_year` BIGINT COMMENT 'The year in which the policy that generated the underlying claim was effective. Used for policy-year LAE development and reinsurance treaty year allocation.',
    `reinsurance_recoverable_amount` DECIMAL(18,2) COMMENT 'Portion of this expense recoverable from reinsurers under applicable treaty or facultative agreements. Used in Schedule F and bordereaux reporting.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates this transaction is a reversal of a previously posted expense. Reversals carry a negative amount and reference the original transaction via original_expense_id.',
    `service_end_date` DATE COMMENT 'End date of the service period covered by this expense. Together with service_start_date defines the billing period for period-based vendor engagements.',
    `service_start_date` DATE COMMENT 'Start date of the service period covered by this expense (e.g., legal retainer period, expert engagement). Used for period-based expense accrual.',
    `siu_referral_flag` BOOLEAN COMMENT 'Indicates this expense has been flagged for SIU review due to suspected fraud, inflated billing, or unusual vendor patterns. Triggers SIU workflow.',
    `source_system_code` STRING COMMENT 'Identifies the operational system of record from which this expense record was sourced. Supports data lineage, reconciliation, and multi-system integration audits.. Valid values are `ClaimCenter|DuckCreek|BillingCenter|Manual|Legacy`',
    `transaction_date` DATE COMMENT 'The date the expense transaction was entered or posted in the claims management system. May differ from expense_date for late-reported or backdated entries.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this expense record. Used for incremental data pipeline processing and change-data-capture audit trails.',
    CONSTRAINT pk_claim_expense PRIMARY KEY(`claim_expense_id`)
) COMMENT 'Grain: one row per financial movement per claim exposure. Each record represents a single expense transaction (LAE/DCC/AO) recorded per Claim Exposure and Accounting Period.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` (
    `accounting_period_id` BIGINT COMMENT 'Unique surrogate identifier for each accounting period record. Primary key. _canonical_skip_reason: REFERENCE_LOOKUP — this is a reference calendar/dimension table; per-role minimums are exempt.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Schedule P actuarial development, NAIC statutory filings, and IFRS17 period reporting require each claim accounting period to be anchored to the enterprise calendar dimension.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Multi-currency statutory reporting (GAAP, SAP, IFRS17) requires accounting periods to reference the enterprise currency master for FX rate application and functional-currency translation.',
    `prior_period_claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the immediately preceding accounting period. Supports period-over-period variance analysis, loss triangle chaining, and reserve roll-forward calculations.',
    `accident_year` BIGINT COMMENT 'Four-digit accident year for loss development triangles and IBNR estimation. Losses are bucketed by the year the loss event occurred, per actuarial reserving standards.',
    `bordereaux_period_code` STRING COMMENT 'Period code used in reinsurance bordereaux submissions to treaty reinsurers. Aligns cession, premium, and loss data to the reinsurers reporting calendar.',
    `calendar_year` BIGINT COMMENT 'Four-digit calendar year (January–December). Used for CY loss ratio, CY written premium, and CY combined ratio analytics per NAIC Schedule P.',
    `close_date` DATE COMMENT 'Date on which the accounting period was officially closed (soft close). After this date, new transactions require a journal entry adjustment or period reopening.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this accounting period record was first created in the data platform. Supports audit trail and SOX compliance.',
    `end_date` DATE COMMENT 'Last calendar date included in this accounting period (inclusive). Transactions with an effective date on or before this date fall within the period.',
    `fiscal_month` BIGINT COMMENT 'Month number (1–12) within the fiscal year. Used for monthly close cycles, premium booking, and loss reserve movements in the GL.',
    `fiscal_quarter` BIGINT COMMENT 'Quarter number (1–4) within the fiscal year. Used for quarterly statutory filings, NAIC quarterly statements, and interim GAAP reporting.',
    `fiscal_year` BIGINT COMMENT 'Four-digit fiscal year to which this period belongs (e.g., 2024). Aligns with the companys statutory and GAAP reporting year.',
    `fx_rate_to_usd` DECIMAL(18,8) COMMENT 'Exchange rate to USD applicable for this periods financial translations. Used for multi-currency consolidation in statutory and GAAP reporting.',
    `gl_period_code` STRING COMMENT 'Period code as defined in the General Ledger system (Oracle/SAP). Used to reconcile premium, loss, and expense transactions between the data warehouse and the GL.',
    `ifrs17_reporting_period` STRING COMMENT 'Period identifier as used in IFRS 17 insurance contract reporting (e.g., 2024-Q1). Supports CSM amortization, loss component tracking, and IFRS 17 disclosure requirements.',
    `is_quarter_end` BOOLEAN COMMENT 'True if this period is the last month of a fiscal quarter, triggering quarterly NAIC statement preparation and interim GAAP reporting.',
    `is_stub_period` BOOLEAN COMMENT 'True if this period is a partial period (fewer days than a standard month), such as a company formation period or mid-year fiscal year change.',
    `is_year_end` BOOLEAN COMMENT 'True if this period represents the final period of the fiscal or calendar year, triggering year-end statutory close, NAIC Annual Statement preparation, and RBC calculations.',
    `lock_date` DATE COMMENT 'Date on which the period was hard-locked, preventing any further postings. Supports SOX controls and statutory filing integrity.',
    `loss_development_lag` BIGINT COMMENT 'Number of months elapsed from the accident year start to this periods end date. Used to position the period on loss development triangles for IBNR and IBNER estimation.',
    `naic_statement_period` STRING COMMENT 'NAIC filing period designation: Q1, Q2, Q3 for quarterly statements, or ANNUAL for the year-end NAIC Annual Statement. Drives statutory reporting schedules.. Valid values are `Q1|Q2|Q3|ANNUAL`',
    `period_basis` STRING COMMENT 'Actuarial and statutory basis: CY (Calendar Year), AY (Accident Year), PY (Policy Year), or FY (Fiscal Year). Drives loss triangle bucketing and Schedule P reporting.. Valid values are `CY|AY|PY|FY`',
    `period_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying the period (e.g., CY-2024-03 for calendar year 2024 March). Used in GL, statutory, and bordereaux reporting.. Valid values are `^[A-Z]{2,4}-[0-9]{4}-[0-9]{2}$`',
    `period_days` BIGINT COMMENT 'Number of calendar days in this accounting period. Used for daily pro-rata premium earning, exposure day calculations, and IFRS 17 coverage unit computations.',
    `period_name` STRING COMMENT 'Human-readable label for the period (e.g., March 2024, Q1 2024, AY 2023). Used in reports, dashboards, and statutory filings.',
    `period_status` STRING COMMENT 'Current state of the period in the financial close lifecycle: OPEN (transactions posting), CLOSED (soft close), LOCKED (hard close, no further postings), REOPENED (adjustment window).. Valid values are `OPEN|CLOSED|LOCKED|REOPENED`',
    `period_type` STRING COMMENT 'Granularity of the period: MONTHLY for standard close cycles, QUARTERLY for interim reporting, SEMI_ANNUAL, or ANNUAL for year-end statutory filings.. Valid values are `MONTHLY|QUARTERLY|ANNUAL|SEMI_ANNUAL`',
    `policy_year` BIGINT COMMENT 'Four-digit policy year for policy-year loss development. Losses and premium are bucketed by the year the policy was written, used in Schedule P and reinsurance bordereaux.',
    `premium_earning_method` STRING COMMENT 'Method used to earn written premium into earned premium during this period: PRO_RATA (daily pro-rata), RULE_OF_78, DAILY, or MONTHLY. Drives UEP and EP calculations.. Valid values are `PRO_RATA|RULE_OF_78|DAILY|MONTHLY`',
    `reopen_date` DATE COMMENT 'Date on which a previously closed or locked period was reopened for adjustment postings. Null if the period has never been reopened.',
    `reporting_framework` STRING COMMENT 'Accounting framework under which this period is reported: SAP (Statutory Accounting Principles), GAAP (US GAAP/FASB), IFRS17 (IASB IFRS 17), or STATUTORY for state-specific filings.. Valid values are `SAP|GAAP|IFRS17|STATUTORY`',
    `schedule_p_period_label` STRING COMMENT 'Label used to identify this period on NAIC Schedule P loss development exhibits (e.g., 2024 1 Year, 2023 2 Years). Supports actuarial reserving and regulatory filing.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record that originated this period definition (e.g., ORACLE_GL, SAP_FI). Supports data lineage and reconciliation.',
    `start_date` DATE COMMENT 'First calendar date included in this accounting period. Transactions with an effective date on or after this date fall within the period.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this accounting period record. Supports change tracking, audit trail, and SOX compliance.',
    CONSTRAINT pk_accounting_period PRIMARY KEY(`accounting_period_id`)
) COMMENT 'Reference calendar for financial close cycles. Defines calendar year, accident year, policy year, and fiscal period boundaries used to bucket premium, loss, and expense transactions for statutory and GAAP reporting.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` (
    `financial_transaction_id` BIGINT COMMENT 'Unique surrogate key for each atomic double-entry posting generated by a claim financial event. One row per financial movement per claim exposure. Grain: one row per posting.',
    `accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this financial transaction is recognized for statutory and GAAP reporting purposes.',
    `catastrophe_event_id` BIGINT COMMENT 'Reference to the catastrophe event (CAT) associated with this financial transaction, if the underlying loss is part of a declared catastrophe. Supports CAT loss aggregation and PML reporting.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the specific coverage line within the claim (Claim Exposure) that this financial movement is attributed to. Drives per-coverage financial reporting.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim under which this financial movement was generated. Links the posting to the reported loss event.',
    `claimant_id` BIGINT COMMENT 'Foreign key linking to claims.claimant. Business justification: GL postings and bordereaux reporting require claimant-level financial transaction detail in multi-claimant losses.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Financial transactions carry gross, net, and ceded amounts requiring FX conversion for multi-currency GAAP and IFRS17 reporting.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Financial transactions must be allocated to LOB for GAAP/SAP income statement reporting, combined ratio analysis, and Schedule P regulatory filings.',
    `original_transaction_financial_transaction_id` BIGINT COMMENT 'For reversal or correction transactions, references the original financial_transaction_id that this entry offsets or corrects. Null for original (non-reversal) postings.',
    `party_id` BIGINT COMMENT 'System user ID of the adjuster, supervisor, or financial controller who authorized this financial transaction. Required for authority limit compliance and SOX audit trail.',
    `payment_id` BIGINT COMMENT 'Reference to the associated claim payment record when this financial transaction represents a disbursement. Links the GL posting to the payment instrument record for reconciliation.',
    `policy_id` BIGINT COMMENT 'Foreign key linking to policy.policy. Business justification: All claim financial movements (reserves, payments, recoveries) must tie to the originating policy for financial statement reconciliation, audit trail, and policy-level profitability analysis.',
    `policy_term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Financial transactions must link to policy term for accurate period-over-period loss development, earned premium matching, and underwriting year loss ratio analysis.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the reinsurance agreement (treaty or facultative) under which the ceded portion of this transaction is recoverable. Null if no reinsurance applies.',
    `ri_claim_cession_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_claim_cession. Business justification: Ceded loss payments, reserve movements, and recoveries post GL financial_transactions keyed to the claim cession.',
    `ri_premium_transaction_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_premium_transaction. Business justification: Ceded written and earned premium transactions post to the GL as financial_transactions.',
    `ri_recovery_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_recovery. Business justification: Each RI recovery cash collection posts a financial_transaction (debit cash, credit reinsurance recoverable).',
    `riskexposure_insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Statutory Schedule P reporting, loss development triangles, and reinsurance bordereau require GL postings to reference the insured risk for risk-class segmentation.',
    `salvage_id` BIGINT COMMENT 'Reference to the associated salvage record when this financial transaction represents a salvage recovery. Links the GL posting to the salvage disposition record.',
    `accident_year` BIGINT COMMENT 'The calendar year in which the loss event (accident) occurred. Used for accident year (AY) loss development triangles and actuarial reserving analysis per NAIC Schedule P.',
    `ap_batch_number` STRING COMMENT 'Identifier of the accounts payable batch run in which this financial transaction was processed and disbursed. Used for payment reconciliation and GL batch balancing.',
    `authority_limit_amount` DECIMAL(18,2) COMMENT 'The financial authority limit of the approving user at the time of authorization. Confirms the transaction was within delegated authority and supports SOX internal controls.',
    `calendar_year` BIGINT COMMENT 'The calendar year in which this financial transaction was posted. Used for calendar year (CY) incurred loss and paid loss reporting in statutory financial statements.',
    `ceded_amount` DECIMAL(18,2) COMMENT 'Portion of the gross amount ceded to reinsurers under applicable treaty or facultative agreements. Used for net retained loss calculation and reinsurance bordereaux reporting.',
    `cost_center_code` STRING COMMENT 'Organizational cost center to which this financial transaction is allocated for internal management accounting and expense reporting purposes.',
    `coverage_type_code` STRING COMMENT 'Code identifying the specific coverage type (e.g., BI, PD, COMP, COLL, MED_PAY, UM/UIM) associated with this financial posting. Enables coverage-level financial analysis.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this financial transaction record was first created in the claims management system. Supports audit trail and data lineage requirements.',
    `current_balance_amount` DECIMAL(18,2) COMMENT 'The reserve or financial balance on the claim exposure immediately after this transaction was applied. Supports outstanding loss reserve (OSLR) and IBNR reporting.',
    `deductible_offset_amount` DECIMAL(18,2) COMMENT 'Amount of the financial transaction attributable to the insureds deductible or self-insured retention (SIR), reducing the insurers net liability on this posting.',
    `effective_date` DATE COMMENT 'The date from which this financial transaction is effective for accounting and reserving purposes. May differ from transaction_date for backdated adjustments or period corrections.',
    `expense_category` STRING COMMENT 'For expense-type transactions, classifies the LAE component: DCC (Defense and Cost Containment), AO (Adjusting and Other), ULAE (Unallocated Loss Adjustment Expense). Null for non-expense transactions.. Valid values are `DCC|AO|ULAE|`',
    `gl_account_code` STRING COMMENT 'The GL account code to which this financial transaction is posted in the general ledger system (Oracle/SAP). Enables reconciliation between claims system and statutory financial statements.',
    `gross_amount` DECIMAL(18,2) COMMENT 'The full gross monetary amount of this financial posting before any reinsurance, deductible, or offset adjustments. Positive for charges/losses; negative for recoveries/credits.',
    `loss_category` STRING COMMENT 'Categorizes the financial movement by loss component: INDEMNITY (property/liability loss), MEDICAL (bodily injury medical), LAE (loss adjustment expense), ALAE (allocated LAE), ULAE (unallocated LAE), OTHER.. Valid values are `INDEMNITY|MEDICAL|LAE|ALAE|ULAE|OTHER`',
    `net_amount` DECIMAL(18,2) COMMENT 'Net retained amount after deducting ceded reinsurance and deductible offsets from the gross amount. Represents the insurers ultimate net loss (UNL) for this posting.',
    `policy_year` BIGINT COMMENT 'The year in which the policy that generated this claim was effective. Used for policy year (PY) loss development and underwriting year profitability analysis.',
    `posted_timestamp` TIMESTAMP COMMENT 'Date and time when this financial transaction was posted to the general ledger and claims system. Used for audit trail and reconciliation with GL batch runs.',
    `prior_balance_amount` DECIMAL(18,2) COMMENT 'The reserve or financial balance on the claim exposure immediately before this transaction was applied. Enables incremental change analysis and reserve development tracking.',
    `reinsurance_recoverable_indicator` BOOLEAN COMMENT 'Indicates whether any portion of this financial transaction is recoverable from reinsurers under a treaty or facultative agreement. Drives reinsurance bordereaux and Schedule F reporting.',
    `reserve_type` STRING COMMENT 'For reserve transactions, identifies the reserve category: CASE (case reserve set by adjuster), IBNR (incurred but not reported), IBNER (incurred but not enough reported), LAE (loss adjustment expense reserve). Null for non-reserve transactions.. Valid values are `CASE|IBNR|IBNER|LAE|`',
    `reversal_indicator` BOOLEAN COMMENT 'Indicates whether this transaction is a reversal (offsetting entry) of a previously posted financial transaction. True if this is a correcting reversal entry.',
    `siu_referral_flag` BOOLEAN COMMENT 'Indicates whether this financial transaction has been flagged for review by the Special Investigations Unit (SIU) due to suspected fraud or irregularity.',
    `source_system_code` STRING COMMENT 'Identifies the operational system of record that originated this financial transaction (e.g., CLAIMCENTER, DUCK_CREEK, GL, MANUAL, REINS_PRO). Supports data lineage and reconciliation.. Valid values are `CLAIMCENTER|DUCK_CREEK|GL|MANUAL|REINS_PRO`',
    `source_transaction_reference` STRING COMMENT 'The native transaction identifier or reference number from the originating source system (e.g., ClaimCenter transaction ID, GL journal entry number). Enables cross-system reconciliation.',
    `state_code` STRING COMMENT 'Two-letter US state code for the jurisdiction in which this financial transaction is reported. Required for state-level statutory reporting to Departments of Insurance (DOI).. Valid values are `^[A-Z]{2}$`',
    `transaction_date` DATE COMMENT 'The business date on which the financial event occurred (e.g., reserve change effective date, payment issue date, recovery receipt date). Principal real-world event date for this posting.',
    `transaction_description` STRING COMMENT 'Free-text narrative describing the reason for or nature of this financial posting (e.g., Initial case reserve set at FNOL, Partial indemnity payment to claimant). Supports adjuster notes.',
    `transaction_number` STRING COMMENT 'Externally visible, human-readable reference number assigned to this financial posting by the claims management or general ledger system. Used for audit trails and reconciliation.',
    `transaction_status` STRING COMMENT 'Current lifecycle state of the financial posting: PENDING (awaiting approval), POSTED (booked to GL), REVERSED (offset entry created), VOIDED (cancelled before posting), APPROVED (authorized, not yet posted).. Valid values are `PENDING|POSTED|REVERSED|VOIDED|APPROVED`',
    `transaction_subtype` STRING COMMENT 'Granular classification within the transaction type. Examples: CASE_RESERVE, IBNR_RESERVE, LAE_RESERVE, INDEMNITY_PAYMENT, MEDICAL_PAYMENT, SUBROGATION_RECOVERY, SALVAGE_RECOVERY, REINSURANCE_RECOVERY, DCC_EXPENSE, AO_EXPENSE.',
    `transaction_type` STRING COMMENT 'High-level category of the financial movement: RESERVE (case/IBNR/LAE reserve), PAYMENT (indemnity/LAE disbursement), RECOVERY (subrogation/salvage/reinsurance), or EXPENSE (DCC/AO/ULAE).. Valid values are `RESERVE|PAYMENT|RECOVERY|EXPENSE`',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this financial transaction record was last modified. Tracks corrections, reversals, and status changes for audit and reconciliation purposes.',
    CONSTRAINT pk_financial_transaction PRIMARY KEY(`financial_transaction_id`)
) COMMENT 'Grain: one row per financial movement per claim exposure. Each record represents a single financial transaction recorded per Claim Exposure and Accounting Period.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` (
    `reinsurance_recovery_id` BIGINT COMMENT 'Unique surrogate identifier for each reinsurance recovery billing record. One row per reinsurance recovery billing per claim exposure and treaty or facultative agreement.',
    `accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this recovery transaction is recognized for statutory and GAAP financial reporting.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Cat treaty recoveries are triggered by specific cat events. Reinsurance_recovery records must link to the triggering cat event for treaty-level settlement, cash call',
    `cession_id` BIGINT COMMENT 'Reference to the reinsurance cession record that establishes the cedants share ceded to the reinsurer under the applicable agreement.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the specific coverage line (claim exposure) within the claim to which this recovery applies.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim from which this reinsurance recovery originates.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Reinsurance recoveries frequently involve cross-currency settlements (USD cedant, London market reinsurer in GBP).',
    `financial_transaction_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.financial_transaction. Business justification: Reinsurance recovery billings and collections generate financial_transaction postings (ceded loss recoverable, cash received).',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Reinsurance recoveries are tracked by LOB for treaty compliance, Schedule F statutory filings, and bordereaux reporting to reinsurers.',
    `policy_id` BIGINT COMMENT 'Foreign key linking to policy.policy. Business justification: Reinsurance recoveries on claims must link to the ceded policy for treaty settlement, bordereaux reporting, and ceded loss ratio analysis. Required for reinsurance accounting and reconciliation.',
    `policy_term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: RI recoveries must match to policy term for accurate ceded loss ratio calculations, treaty performance analysis, and to align recovery timing with ceded premium by term.',
    `reinsurer_id` BIGINT COMMENT 'Foreign key linking to reinsurance.reinsurer. Business justification: Reinsurer AR aging, credit limit monitoring, and Schedule F reporting require grouping reinsurance_recovery records by reinsurer entity.',
    `reinsurer_party_id` BIGINT COMMENT 'Reference to the party record representing the reinsurer from whom recovery is sought.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the reinsurance agreement (treaty or facultative) under which this recovery is billed.',
    `ri_claim_cession_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_claim_cession. Business justification: reinsurance_recovery tracks cash collections against claim-level cessions for bordereaux reconciliation.',
    `ri_participant_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_participant. Business justification: Treaty participation shares determine each reinsurers recovery allocation. ri_participant defines signed-line percentages; linking reinsurance_recovery to ri_participant enables',
    `ri_recovery_id` BIGINT COMMENT 'FK to reinsurance.ri_recovery.ri_recovery_id — Links the cedant-side reinsurance recovery accrual to the reinsurance ceded-loss ledger so ceded recovery is booked once and reconciled, preventing double-counting of recoverables (VREQ-009/VREQ-014).',
    `riskexposure_insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Per-risk excess of loss reinsurance recovery billing requires the insured risk TIV, construction class, and territory for treaty layer determination and NAIC Schedule F reporting.',
    `accident_year` BIGINT COMMENT 'Calendar year in which the loss event occurred. Used for actuarial loss triangle development and reinsurance bordereaux reporting.',
    `agreement_type` STRING COMMENT 'Indicates whether the recovery is under a treaty (automatic) or facultative (individually negotiated) reinsurance agreement.. Valid values are `treaty|facultative`',
    `attachment_point` DECIMAL(18,2) COMMENT 'The loss threshold above which the reinsurers obligation begins under an Excess of Loss (XOL) or Stop Loss (SL) treaty layer.',
    `authorized_control_level_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer is an authorized (admitted) reinsurer for statutory credit purposes, affecting RBC and Schedule F treatment.',
    `billing_date` DATE COMMENT 'The date on which the reinsurance recovery was billed to the reinsurer. Principal business event date for this transaction.',
    `bordereaux_period` STRING COMMENT 'The reporting period (YYYY-MM or YYYY-Q#) in which this recovery is included in the reinsurance bordereaux submission to the reinsurer.. Valid values are `^[0-9]{4}-(Q[1-4]|[0-9]{2})$`',
    `cash_call_indicator` BOOLEAN COMMENT 'Indicates whether this recovery was billed as an interim cash call to the reinsurer prior to final claim settlement, as permitted under large-loss provisions.',
    `ceded_lae_amount` DECIMAL(18,2) COMMENT 'Loss Adjustment Expense (LAE) amount ceded to the reinsurer, including both Allocated LAE (ALAE) and Unallocated LAE (ULAE) where applicable.',
    `ceded_loss_amount` DECIMAL(18,2) COMMENT 'Gross indemnity loss amount ceded to the reinsurer under the applicable agreement for this claim exposure. Excludes LAE.',
    `cession_percentage` DECIMAL(7,4) COMMENT 'The percentage of the loss ceded to the reinsurer under the applicable agreement, expressed as a decimal (e.g., 0.7500 = 75%). Applicable primarily to quota share treaties.',
    `collateral_held_amount` DECIMAL(18,2) COMMENT 'Amount of collateral (letters of credit, trust funds) held from the reinsurer that can be applied against this outstanding recovery balance.',
    `collection_date` DATE COMMENT 'The date on which the recovery amount was actually received from the reinsurer. Null if not yet collected.',
    `commutation_indicator` BOOLEAN COMMENT 'Flags whether this recovery record has been settled via a commutation agreement, extinguishing future obligations between cedant and reinsurer.',
    `coverage_type_code` STRING COMMENT 'Code identifying the coverage type within the claim exposure (e.g., dwelling, liability, collision, comprehensive). Drives treaty layer applicability.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this reinsurance recovery record was first created in the Reinsurance Management System.',
    `days_overdue` BIGINT COMMENT 'Number of calendar days the outstanding recovery balance has been past the contractual due date. Used for Schedule F aging buckets and credit risk monitoring.',
    `disputed_amount` DECIMAL(18,2) COMMENT 'Portion of the billed recovery amount that the reinsurer has formally disputed. Tracked separately for collections and reserving purposes.',
    `due_date` DATE COMMENT 'Contractual due date by which the reinsurer is obligated to remit the recovery amount per the reinsurance agreement terms.',
    `gl_account_code` STRING COMMENT 'General Ledger account code to which this reinsurance recovery is posted in the statutory and GAAP financial statements.',
    `loss_date` DATE COMMENT 'Date of the underlying loss event. Used to determine which treaty year and layer applies for accident year (AY) and policy year (PY) reporting.',
    `notes` STRING COMMENT 'Free-text notes entered by reinsurance analysts documenting dispute details, collection actions, commutation terms, or other recovery-specific commentary.',
    `outstanding_balance` DECIMAL(18,2) COMMENT 'Unpaid balance owed by the reinsurer, calculated as recovery billed minus recovery collected. Used for Schedule F overdue reporting.',
    `overdue_indicator` BOOLEAN COMMENT 'Flags recoveries where the outstanding balance has exceeded the contractual due date. Drives NAIC Schedule F overdue reinsurance reporting.',
    `policy_year` BIGINT COMMENT 'Year in which the policy that generated the claim was written. Used for policy year (PY) reinsurance treaty allocation and bordereaux.',
    `recovery_billed_amount` DECIMAL(18,2) COMMENT 'Total amount billed to the reinsurer for this recovery, combining ceded loss and ceded LAE. Represents the gross recovery claim submitted.',
    `recovery_collected_amount` DECIMAL(18,2) COMMENT 'Actual amount received from the reinsurer to date. May be less than billed if partial payment or dispute exists.',
    `recovery_number` STRING COMMENT 'Externally-known business identifier for this recovery billing, used in bordereaux reporting and reinsurer correspondence. Assigned by the Reinsurance Management System.',
    `recovery_status` STRING COMMENT 'Current lifecycle state of the recovery billing. Tracks progression from initial billing through collection or write-off.. Valid values are `billed|collected|partial|disputed|written_off|void`',
    `recovery_type` STRING COMMENT 'Classifies the nature of the recovery: indemnity loss, Loss Adjustment Expense (LAE), combined loss and LAE, salvage share, or subrogation share.. Valid values are `loss|lae|combined|salvage|subrogation`',
    `reinsurer_limit` DECIMAL(18,2) COMMENT 'Maximum amount the reinsurer is obligated to pay under the applicable treaty layer or facultative certificate for this claim.',
    `retention_amount` DECIMAL(18,2) COMMENT 'The portion of the loss retained by the cedant (Pc_Insurance) after cession. For XOL treaties, this equals the Self-Insured Retention (SIR) or attachment point.',
    `settlement_reference` STRING COMMENT 'Reference number of the reinsurance settlement or cash call under which this recovery was remitted by the reinsurer.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this recovery record was sourced (e.g., SAPIENS for Sapiens ReinsurancePro, SICS, or MANUAL for manual entries).. Valid values are `RMS|SAPIENS|SICS|MANUAL`',
    `treaty_type` STRING COMMENT 'Specifies the treaty structure: Quota Share (QS), Excess of Loss (XOL), Stop Loss (SL), or Catastrophe Excess of Loss (CAT XL). Null for facultative agreements.. Valid values are `quota_share|excess_of_loss|stop_loss|cat_xl`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this reinsurance recovery record.',
    `written_off_amount` DECIMAL(18,2) COMMENT 'Amount of the recovery deemed uncollectible and written off, typically due to reinsurer insolvency or commutation agreement.',
    CONSTRAINT pk_reinsurance_recovery PRIMARY KEY(`reinsurance_recovery_id`)
) COMMENT 'One row per reinsurance recovery billing per claim exposure and treaty or facultative agreement. Tracks ceded loss amount, ceded LAE, recovery billed, recovery collected, and outstanding balance. Links claim to reinsurance cession.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` (
    `payee_id` BIGINT COMMENT 'Unique surrogate identifier for the payee master record. One row per party designated to receive claim payments. MASTER_PARTY role.',
    `claimant_id` BIGINT COMMENT 'Foreign key linking to claims.claimant. Business justification: Payee records are created from claimant records when payments are issued. Linking payee to claimant supports OFAC screening traceability, duplicate payee detection, 1099 reporting accuracy',
    `party_id` BIGINT COMMENT 'Reference to the enterprise Party master record for this payee, enabling linkage to the canonical party identity and deduplication via Customer/Party MDM.',
    `preferred_currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: International payee management requires currency master for payment processing in payees preferred currency, withholding tax calculation, bank account validation, and 1099/tax reporting.',
    `address_line1` STRING COMMENT 'Primary street address line for the payee. Used for check mailing, 1099 form delivery, and OFAC/fraud screening. Required for all check-based payment methods.',
    `address_line2` STRING COMMENT 'Secondary address line (suite, apartment, unit, floor) for the payee. Supplements address_line1 for complete mailing address on checks and 1099 forms.',
    `attorney_bar_number` STRING COMMENT 'State bar license number for payees classified as attorneys. Used to validate attorney payees in ClaimCenter and supports regulatory reporting of legal expense payments.',
    `backup_withholding_flag` BOOLEAN COMMENT 'Indicates whether the payee is subject to IRS backup withholding (currently 24%). Set when TIN is missing, unverified, or IRS notifies the payer of withholding obligation.',
    `bank_account_number` STRING COMMENT 'Payees bank account number for EFT/ACH disbursements. Stored in tokenized or encrypted form per PCI DSS and GLBA requirements. Required when payment_method is EFT or wire.',
    `bank_account_type` STRING COMMENT 'Type of bank account used for EFT disbursements: checking or savings. Required by NACHA for ACH transaction formatting and return code handling.. Valid values are `checking|savings`',
    `bank_name` STRING COMMENT 'Name of the financial institution holding the payees account. Used for EFT remittance documentation and payment reconciliation in the General Ledger.',
    `bank_routing_number` STRING COMMENT 'ABA routing transit number (9 digits) identifying the payees financial institution for ACH/EFT transactions. Required when payment_method is EFT or wire.. Valid values are `^[0-9]{9}$`',
    `city` STRING COMMENT 'City of the payees mailing address. Required for check issuance, 1099 reporting, and OFAC geographic screening.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for the payees mailing address (e.g., USA, CAN). Drives OFAC screening, foreign payment rules, and FATCA/FBAR reporting obligations.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the payee record was first created in the Claims Management System. Supports audit trail, SOX compliance, and data lineage tracking.',
    `do_not_pay_flag` BOOLEAN COMMENT 'Hard stop flag that prevents any payment from being issued to this payee. Set by compliance, SIU, or legal hold. Overrides all payment authorizations until manually cleared.',
    `effective_date` DATE COMMENT 'Date from which this payee record is valid and eligible to receive payments. Supports temporal validity tracking for payee lifecycle management and audit compliance.',
    `email` STRING COMMENT 'Primary email address for the payee. Used for EFT remittance advice delivery, payment notifications, and electronic 1099 delivery where consent is obtained.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `entity_type` STRING COMMENT 'Indicates whether the payee is a natural person (individual) or a legal entity (organization). Determines which tax identification type applies and governs 1099/W-9 requirements.. Valid values are `individual|organization`',
    `expiration_date` DATE COMMENT 'Date after which this payee record is no longer eligible to receive payments. Null indicates an open-ended active payee. Used for attorney retainer expiry and vendor contract end dates.',
    `fraud_indicator_flag` BOOLEAN COMMENT 'Indicates whether the Fraud Detection/SIU system has flagged this payee as a potential fraud risk based on pattern analysis, prior SIU findings, or external data sources (e.g., NICB).',
    `guardian_name` STRING COMMENT 'Full legal name of the court-appointed guardian or conservator when the payee is a minor or legally incapacitated. Payments are issued in the guardians name on behalf of the payee.',
    `is_1099_reportable` BOOLEAN COMMENT 'Indicates whether payments to this payee are subject to IRS 1099 reporting. Drives year-end tax reporting workflows and AP batch processing in the General Ledger system.',
    `is_minor` BOOLEAN COMMENT 'Indicates whether the payee is a minor (under 18). Triggers guardian/conservator payment controls, court approval requirements, and special handling in ClaimCenter payment workflows.',
    `is_structured_settlement` BOOLEAN COMMENT 'Indicates whether payments to this payee are part of a structured settlement annuity arrangement. Triggers specialized payment scheduling, tax treatment, and regulatory disclosure requirements.',
    `lien_holder_flag` BOOLEAN COMMENT 'Indicates whether the payee holds a lien or security interest on the insured property. When true, the payee must be co-payee on property damage payments per standard mortgage/lien clauses.',
    `payee_name` STRING COMMENT 'Full legal name of the payee as it must appear on the payment instrument (check or EFT). For individuals this is the legal name; for entities the registered business name.',
    `number` STRING COMMENT 'Externally visible, human-readable identifier assigned to the payee by the Claims Management System (e.g., PAY-000012345). Used on checks, EFT remittances, and 1099 filings.. Valid values are `^PAY-[0-9]{8,12}$`',
    `ofac_match_flag` BOOLEAN COMMENT 'Indicates whether the payee returned a potential match against the OFAC SDN list during screening. A true value triggers a compliance hold and manual review before payment release.',
    `ofac_screen_date` DATE COMMENT 'Most recent date on which the payee was screened against the OFAC SDN and consolidated sanctions lists. Supports periodic re-screening compliance requirements.',
    `ofac_screened` BOOLEAN COMMENT 'Indicates whether the payee has been screened against the OFAC Specially Designated Nationals (SDN) list. Payments to blocked persons are prohibited under U.S. sanctions law.',
    `payee_status` STRING COMMENT 'Current lifecycle state of the payee record. Blocked payees cannot receive payments until cleared by SIU or compliance review. Drives payment eligibility checks in ClaimCenter.. Valid values are `active|inactive|suspended|pending_verification|blocked`',
    `payee_type` STRING COMMENT 'Classifies the payees role in the payment transaction. Drives 1099 reporting rules, authority limits, and payment workflow routing within ClaimCenter.. Valid values are `claimant|attorney|vendor|lienholder|mortgagee|other`',
    `payment_method` STRING COMMENT 'Preferred or designated payment instrument for disbursements to this payee: check, EFT (ACH), wire transfer, Zelle, or other. Drives payment routing in BillingCenter and ClaimCenter.. Valid values are `check|eft|wire|zelle|other`',
    `phone` STRING COMMENT 'Primary contact phone number for the payee. Used for payment confirmation, returned check follow-up, and EFT pre-notification as required by NACHA rules.. Valid values are `^+?[0-9-s().]{7,20}$`',
    `postal_code` STRING COMMENT 'ZIP or ZIP+4 postal code for the payees mailing address. Required for check delivery, 1099 filing, and USPS address validation.. Valid values are `^[0-9]{5}(-[0-9]{4})?$`',
    `siu_referral_flag` BOOLEAN COMMENT 'Indicates whether this payee has been referred to the Special Investigations Unit (SIU) for fraud screening. A true value places a payment hold pending SIU clearance.',
    `source_system_code` STRING COMMENT 'Identifies the operational system of record that originated this payee record (e.g., CLAIMCENTER, BILLINGCENTER, MDM). Supports data lineage and master data reconciliation.. Valid values are `CLAIMCENTER|BILLINGCENTER|MDM|LEGACY`',
    `tax_id_type` STRING COMMENT 'Classifies the tax_id field: SSN (Social Security Number), FEIN (Federal Employer Identification Number), ITIN (Individual Taxpayer Identification Number), or EIN (Employer Identification Number).. Valid values are `SSN|FEIN|ITIN|EIN`',
    `tax_id_verified` BOOLEAN COMMENT 'Indicates whether the payees TIN has been validated against IRS TIN Matching or equivalent verification service. Required before issuing 1099 forms.',
    `tax_number` STRING COMMENT 'Federal tax identifier for the payee: Social Security Number (SSN) for individuals or Federal Employer Identification Number (FEIN) for organizations. Required for IRS 1099 reporting.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the payee record. Used for change data capture (CDC), audit trail, and downstream Silver layer incremental processing.',
    `vendor_code` STRING COMMENT 'Internal vendor identifier assigned by the Accounts Payable system (Oracle/SAP) for payees classified as vendors (e.g., repair shops, medical providers, appraisers). Enables AP reconciliation.',
    `w9_received` BOOLEAN COMMENT 'Indicates whether a completed IRS Form W-9 (Request for Taxpayer Identification Number and Certification) has been received from the payee. Required before releasing payments subject to backup withholding.',
    `w9_received_date` DATE COMMENT 'Date on which the IRS Form W-9 was received from the payee. Used to establish the effective date of TIN certification and backup withholding exemption.',
    CONSTRAINT pk_payee PRIMARY KEY(`payee_id`)
) COMMENT 'Master record for a party designated to receive claim payments. Captures payee name, tax ID (SSN/FEIN), address, bank account for EFT, 1099 reporting flag, and payee type (claimant, attorney, vendor, lienholder).';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_financial_transaction_id` FOREIGN KEY (`financial_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction`(`financial_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_original_payment_claim_payment_id` FOREIGN KEY (`original_payment_claim_payment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment`(`claim_payment_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_payee_id` FOREIGN KEY (`payee_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee`(`payee_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_claim_payment_id` FOREIGN KEY (`claim_payment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment`(`claim_payment_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_financial_transaction_id` FOREIGN KEY (`financial_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction`(`financial_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_salvage_id` FOREIGN KEY (`salvage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage`(`salvage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_subrogation_id` FOREIGN KEY (`subrogation_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation`(`subrogation_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_vendor_payee_id` FOREIGN KEY (`vendor_payee_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee`(`payee_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_financial_transaction_id` FOREIGN KEY (`financial_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction`(`financial_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_original_expense_claim_expense_id` FOREIGN KEY (`original_expense_claim_expense_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense`(`claim_expense_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_payee_id` FOREIGN KEY (`payee_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee`(`payee_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ADD CONSTRAINT `fk_claimfinancials_accounting_period_prior_period_claimfinancials_accounting_period_id` FOREIGN KEY (`prior_period_claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_original_transaction_financial_transaction_id` FOREIGN KEY (`original_transaction_financial_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction`(`financial_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_salvage_id` FOREIGN KEY (`salvage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage`(`salvage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_financial_transaction_id` FOREIGN KEY (`financial_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction`(`financial_transaction_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`claimfinancials` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`claimfinancials` SET TAGS ('dbx_domain' = 'claimfinancials');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` SET TAGS ('dbx_subdomain' = 'financial_positions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `reserve_id` SET TAGS ('dbx_business_glossary_term' = 'Reserve ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `approved_by_party_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `financial_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Financial Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `litigation_id` SET TAGS ('dbx_business_glossary_term' = 'Litigation Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `ri_claim_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Claim Cession Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `ri_recovery_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Recovery Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `riskexposure_auto_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Auto Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `riskexposure_insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Reserve Approval Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `authority_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Reserve Authority Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `authority_limit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `authority_limit_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `basis` SET TAGS ('dbx_business_glossary_term' = 'Reserve Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `basis` SET TAGS ('dbx_value_regex' = 'Gross|Net|Ceded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `case_reserve_adequacy_flag` SET TAGS ('dbx_business_glossary_term' = 'Case Reserve Adequacy Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `catastrophe_indicator` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `reserve_category` SET TAGS ('dbx_business_glossary_term' = 'Reserve Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `reserve_category` SET TAGS ('dbx_value_regex' = 'Loss|Expense|Salvage|Subrogation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `ceded_closing_balance_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Closing Reserve Balance Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `ceded_closing_balance_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `ceded_closing_balance_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `ceded_movement_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Reserve Movement Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `ceded_movement_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `ceded_movement_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `ceded_opening_balance_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Opening Reserve Balance Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `ceded_opening_balance_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `ceded_opening_balance_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `closing_balance_amount` SET TAGS ('dbx_business_glossary_term' = 'Closing Reserve Balance Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `closing_balance_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `closing_balance_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `development_period` SET TAGS ('dbx_business_glossary_term' = 'Development Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Reserve Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `ibnr_factor` SET TAGS ('dbx_business_glossary_term' = 'Incurred But Not Reported (IBNR) Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `loss_date` SET TAGS ('dbx_business_glossary_term' = 'Loss Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `method` SET TAGS ('dbx_business_glossary_term' = 'Reserve Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `method` SET TAGS ('dbx_value_regex' = 'Case_Estimate|Formula|Actuarial|Bulk|Tabular');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `movement_amount` SET TAGS ('dbx_business_glossary_term' = 'Reserve Movement Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `movement_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `movement_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `movement_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reserve Movement Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `movement_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Reserve Movement Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Reserve Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `opening_balance_amount` SET TAGS ('dbx_business_glossary_term' = 'Opening Reserve Balance Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `opening_balance_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `opening_balance_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `report_date` SET TAGS ('dbx_business_glossary_term' = 'Claim Report Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `requires_supervisor_approval` SET TAGS ('dbx_business_glossary_term' = 'Requires Supervisor Approval Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `reserve_status` SET TAGS ('dbx_business_glossary_term' = 'Reserve Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `reserve_status` SET TAGS ('dbx_value_regex' = 'Open|Closed|Reopened|Pending|Voided');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `reserve_type` SET TAGS ('dbx_business_glossary_term' = 'Reserve Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `reserve_type` SET TAGS ('dbx_value_regex' = 'Case|IBNR|LAE|ULAE|ALAE|DCC');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `salvage_anticipated_amount` SET TAGS ('dbx_business_glossary_term' = 'Salvage Anticipated Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `salvage_anticipated_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `salvage_anticipated_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'ClaimCenter|DuckCreek|Legacy|Manual|Actuarial');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `subrogation_anticipated_amount` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Anticipated Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `subrogation_anticipated_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `subrogation_anticipated_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Reserve Transaction Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` SET TAGS ('dbx_subdomain' = 'financial_positions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `claim_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Payment ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `claim_party_id` SET TAGS ('dbx_business_glossary_term' = 'Authorized By User ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `claim_party_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `claim_party_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `claim_payee_party_id` SET TAGS ('dbx_business_glossary_term' = 'Payee Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `claimant_id` SET TAGS ('dbx_business_glossary_term' = 'Claimant Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `litigation_id` SET TAGS ('dbx_business_glossary_term' = 'Litigation Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `original_payment_claim_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Original Payment ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `payee_id` SET TAGS ('dbx_business_glossary_term' = 'Payee Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `ri_claim_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Claim Cession Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `ri_recovery_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Recovery Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `ap_batch_number` SET TAGS ('dbx_business_glossary_term' = 'Accounts Payable (AP) Batch ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `authority_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Payment Authority Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `bank_account_code` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `bank_account_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `bank_account_code` SET TAGS ('dbx_pii_category' = 'financial');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `check_eft_reference` SET TAGS ('dbx_business_glossary_term' = 'Check / Electronic Funds Transfer (EFT) Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `check_eft_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `check_eft_reference` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `cleared_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Cleared Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `coverage_type_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `deductible_offset_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Offset Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `gross_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Payment Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `gross_payment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `gross_payment_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `is_1099_reportable` SET TAGS ('dbx_business_glossary_term' = 'IRS Form 1099 Reportable Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `is_final_payment` SET TAGS ('dbx_business_glossary_term' = 'Final Payment Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `is_structured_settlement` SET TAGS ('dbx_business_glossary_term' = 'Structured Settlement Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `loss_category` SET TAGS ('dbx_business_glossary_term' = 'Loss Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `net_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Payment Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `net_payment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `net_payment_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `payment_authorization_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Authorization Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `payment_description` SET TAGS ('dbx_business_glossary_term' = 'Payment Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'Check|ACH|Wire|EFT|Draft|Virtual Card');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `payment_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'Issued|Cleared|Voided|Stopped|Reissued|Returned');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `payment_type` SET TAGS ('dbx_business_glossary_term' = 'Payment Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `reissue_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Reissue Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `remittance_memo` SET TAGS ('dbx_business_glossary_term' = 'Remittance Memo');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `siu_referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Special Investigations Unit (SIU) Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'ClaimCenter|DuckCreek|Legacy|Manual');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `state_jurisdiction_code` SET TAGS ('dbx_business_glossary_term' = 'State Jurisdiction Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `state_jurisdiction_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `state_jurisdiction_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `stop_payment_flag` SET TAGS ('dbx_business_glossary_term' = 'Stop Payment Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `void_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Void Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `withholding_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `withholding_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `withholding_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` SET TAGS ('dbx_subdomain' = 'financial_positions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `recovery_id` SET TAGS ('dbx_business_glossary_term' = 'Recovery ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `attorney_organization_id` SET TAGS ('dbx_business_glossary_term' = 'Attorney Organization Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `cession_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Cession ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `claim_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Offset Claim Payment ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `financial_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Financial Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `litigation_id` SET TAGS ('dbx_business_glossary_term' = 'Litigation Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `responsible_party_id` SET TAGS ('dbx_business_glossary_term' = 'Responsible Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `ri_claim_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Claim Cession Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `riskexposure_insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `salvage_id` SET TAGS ('dbx_business_glossary_term' = 'Salvage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `subrogation_id` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Reporting Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(0[1-9]|1[0-2])$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `closed_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Closed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `collected_amount` SET TAGS ('dbx_business_glossary_term' = 'Recovery Collected Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `collected_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `collected_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `collected_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Collected Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `collection_expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Recovery Collection Expense Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `collection_expense_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `collection_expense_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `demand_amount` SET TAGS ('dbx_business_glossary_term' = 'Recovery Demand Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `demand_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `demand_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `demand_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Demand Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `litigation_flag` SET TAGS ('dbx_business_glossary_term' = 'Litigation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `method` SET TAGS ('dbx_business_glossary_term' = 'Recovery Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `method` SET TAGS ('dbx_value_regex' = 'demand_letter|litigation|negotiated_settlement|auction|bordereaux|direct_bill');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Recovery Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `net_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `net_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Recovery Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Recovery Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `payment_reference` SET TAGS ('dbx_business_glossary_term' = 'Recovery Payment Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `recovery_status` SET TAGS ('dbx_business_glossary_term' = 'Recovery Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `recovery_status` SET TAGS ('dbx_value_regex' = 'open|collected|closed|void|disputed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `recovery_type` SET TAGS ('dbx_business_glossary_term' = 'Recovery Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `recovery_type` SET TAGS ('dbx_value_regex' = 'subrogation|salvage|reinsurance|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `ri_participation_pct` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Participation Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `ri_recovery_basis` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recovery Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `ri_recovery_basis` SET TAGS ('dbx_value_regex' = 'quota_share|excess_of_loss|stop_loss|facultative');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `salvage_item_description` SET TAGS ('dbx_business_glossary_term' = 'Salvage Item Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `salvage_type` SET TAGS ('dbx_business_glossary_term' = 'Salvage Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `salvage_type` SET TAGS ('dbx_value_regex' = 'total_loss_vehicle|damaged_property|scrap|auction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `siu_referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Special Investigations Unit (SIU) Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'claimcenter|reins_pro|billing|manual');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `statute_of_limitations_date` SET TAGS ('dbx_business_glossary_term' = 'Statute of Limitations Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `subrogation_basis` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Legal Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `subrogation_basis` SET TAGS ('dbx_value_regex' = 'tort|contract|statutory|equitable');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Transaction Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` SET TAGS ('dbx_subdomain' = 'recovery_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `subrogation_id` SET TAGS ('dbx_business_glossary_term' = 'Subrogation ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `attorney_organization_id` SET TAGS ('dbx_business_glossary_term' = 'Attorney Organization Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `claimant_id` SET TAGS ('dbx_business_glossary_term' = 'Claimant Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `liable_party_id` SET TAGS ('dbx_business_glossary_term' = 'Liable Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `litigation_id` SET TAGS ('dbx_business_glossary_term' = 'Litigation Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `riskexposure_insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `arbitration_award_amount` SET TAGS ('dbx_business_glossary_term' = 'Arbitration Award Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `arbitration_award_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `arbitration_award_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `arbitration_filing_date` SET TAGS ('dbx_business_glossary_term' = 'Arbitration Filing Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `arbitration_forum` SET TAGS ('dbx_business_glossary_term' = 'Arbitration Forum');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `arbitration_forum` SET TAGS ('dbx_value_regex' = 'Arbitration Forums|AAA|JAMS|State Court|None');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `closed_date` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Closed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `closure_reason` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Closure Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `collected_amount` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Collected Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `collected_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `collected_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `collectible_amount` SET TAGS ('dbx_business_glossary_term' = 'Collectible Subrogation Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `collectible_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `collectible_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `demand_amount` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Demand Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `demand_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `demand_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `demand_date` SET TAGS ('dbx_business_glossary_term' = 'Demand Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `insured_reimbursement_amount` SET TAGS ('dbx_business_glossary_term' = 'Insured Reimbursement Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `insured_reimbursement_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `insured_reimbursement_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `last_activity_date` SET TAGS ('dbx_business_glossary_term' = 'Last Activity Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `liable_party_claim_number` SET TAGS ('dbx_business_glossary_term' = 'Liable Party Claim Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `liable_party_insurer` SET TAGS ('dbx_business_glossary_term' = 'Liable Party Insurer Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `liable_party_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Liable Party Policy Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `liable_party_policy_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `litigation_status` SET TAGS ('dbx_business_glossary_term' = 'Litigation Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `made_whole_indicator` SET TAGS ('dbx_business_glossary_term' = 'Made-Whole Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `negligence_pct` SET TAGS ('dbx_business_glossary_term' = 'Comparative Negligence Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `net_recovery_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Subrogation Recovery Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `net_recovery_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `net_recovery_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `next_action_date` SET TAGS ('dbx_business_glossary_term' = 'Next Action Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^SUBR-[0-9]{4}-[0-9]{7}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `opened_date` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Opened Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `pursuit_status` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Pursuit Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `recovery_expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Recovery Expense Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `recovery_expense_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `recovery_expense_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `recovery_method` SET TAGS ('dbx_business_glossary_term' = 'Recovery Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `recovery_method` SET TAGS ('dbx_value_regex' = 'Demand Letter|Arbitration|Litigation|Intercompany Arbitration|Negotiated Settlement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `referral_date` SET TAGS ('dbx_business_glossary_term' = 'Attorney Referral Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `reinsurance_recovery_indicator` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recovery Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Settlement Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `settlement_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `settlement_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `siu_referral_indicator` SET TAGS ('dbx_business_glossary_term' = 'Special Investigations Unit (SIU) Referral Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `state_of_loss` SET TAGS ('dbx_business_glossary_term' = 'State of Loss');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `state_of_loss` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `state_of_loss` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `statute_of_limitations_date` SET TAGS ('dbx_business_glossary_term' = 'Statute of Limitations Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `subrogation_type` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `subrogation_type` SET TAGS ('dbx_value_regex' = 'Subrogation|Contribution|Indemnification');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `suit_filed_date` SET TAGS ('dbx_business_glossary_term' = 'Suit Filed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` SET TAGS ('dbx_subdomain' = 'recovery_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `salvage_id` SET TAGS ('dbx_business_glossary_term' = 'Salvage ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `buyer_party_id` SET TAGS ('dbx_business_glossary_term' = 'Buyer Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `riskexposure_property_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Property Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `riskexposure_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `vendor_payee_id` SET TAGS ('dbx_business_glossary_term' = 'Vendor Payee Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `assigned_date` SET TAGS ('dbx_business_glossary_term' = 'Salvage Assigned Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `auction_date` SET TAGS ('dbx_business_glossary_term' = 'Salvage Auction Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `auction_fee` SET TAGS ('dbx_business_glossary_term' = 'Salvage Auction Fee');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `auction_fee` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `auction_fee` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `auction_proceeds` SET TAGS ('dbx_business_glossary_term' = 'Salvage Auction Proceeds');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `auction_proceeds` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `auction_proceeds` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `buyer_type` SET TAGS ('dbx_business_glossary_term' = 'Salvage Buyer Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `buyer_type` SET TAGS ('dbx_value_regex' = 'dealer|individual|insurer|scrap_yard|auction_house');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Salvage Certificate Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `closed_date` SET TAGS ('dbx_business_glossary_term' = 'Salvage Closed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `disposition_method` SET TAGS ('dbx_business_glossary_term' = 'Salvage Disposition Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `disposition_method` SET TAGS ('dbx_value_regex' = 'auction|direct_sale|scrap|donation|insurer_retained|third_party_buyer');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `insured_retained_indicator` SET TAGS ('dbx_business_glossary_term' = 'Insured Retained Salvage Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `insured_retention_deduction` SET TAGS ('dbx_business_glossary_term' = 'Insured Retention Deduction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `insured_retention_deduction` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `insured_retention_deduction` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `item_description` SET TAGS ('dbx_business_glossary_term' = 'Salvage Item Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `net_salvage_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Salvage Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `net_salvage_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `net_salvage_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Salvage Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Salvage Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^SAL-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `reinsurance_recoverable_indicator` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `reinsurance_salvage_share` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Salvage Share');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `reinsurance_salvage_share` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `reinsurance_salvage_share` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `salvage_status` SET TAGS ('dbx_business_glossary_term' = 'Salvage Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `salvage_status` SET TAGS ('dbx_value_regex' = 'open|pending_auction|sold|title_transferred|closed|voided');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `salvage_type` SET TAGS ('dbx_business_glossary_term' = 'Salvage Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `salvage_type` SET TAGS ('dbx_value_regex' = 'total_loss_vehicle|total_loss_property|partial_salvage|marine_salvage|equipment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `siu_referral_indicator` SET TAGS ('dbx_business_glossary_term' = 'Special Investigations Unit (SIU) Referral Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `storage_cost` SET TAGS ('dbx_business_glossary_term' = 'Salvage Storage Cost');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `storage_cost` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `storage_cost` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `storage_end_date` SET TAGS ('dbx_business_glossary_term' = 'Salvage Storage End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `storage_location` SET TAGS ('dbx_business_glossary_term' = 'Salvage Storage Location');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `storage_start_date` SET TAGS ('dbx_business_glossary_term' = 'Salvage Storage Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `title_number` SET TAGS ('dbx_business_glossary_term' = 'Salvage Title Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `title_received_date` SET TAGS ('dbx_business_glossary_term' = 'Title Received Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `title_transfer_date` SET TAGS ('dbx_business_glossary_term' = 'Title Transfer Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `title_transfer_status` SET TAGS ('dbx_business_glossary_term' = 'Title Transfer Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `title_transfer_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|transferred|rejected');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `total_loss_indicator` SET TAGS ('dbx_business_glossary_term' = 'Total Loss Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `towing_cost` SET TAGS ('dbx_business_glossary_term' = 'Salvage Towing Cost');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `towing_cost` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `towing_cost` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `value_estimate` SET TAGS ('dbx_business_glossary_term' = 'Salvage Value Estimate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `value_estimate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `value_estimate` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `vin` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identification Number (VIN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `vin` SET TAGS ('dbx_value_regex' = '^[A-HJ-NPR-Z0-9]{17}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` SET TAGS ('dbx_subdomain' = 'financial_positions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `claim_expense_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Expense ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `approved_by_party_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `claimant_id` SET TAGS ('dbx_business_glossary_term' = 'Claimant Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `financial_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Source System Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `litigation_id` SET TAGS ('dbx_business_glossary_term' = 'Litigation Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `original_expense_claim_expense_id` SET TAGS ('dbx_business_glossary_term' = 'Original Expense Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `payee_id` SET TAGS ('dbx_business_glossary_term' = 'Vendor ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `ri_claim_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Claim Cession Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `riskexposure_insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Expense Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Expense Approval Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|escalated');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `check_number` SET TAGS ('dbx_business_glossary_term' = 'Disbursement Check Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Expense Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `expense_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `expense_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `expense_date` SET TAGS ('dbx_business_glossary_term' = 'Expense Incurred Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `expense_description` SET TAGS ('dbx_business_glossary_term' = 'Expense Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `expense_number` SET TAGS ('dbx_business_glossary_term' = 'Expense Transaction Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `expense_number` SET TAGS ('dbx_value_regex' = '^EXP-[0-9]{10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `expense_status` SET TAGS ('dbx_business_glossary_term' = 'Expense Transaction Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `expense_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|approved|paid|voided|disputed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `expense_type` SET TAGS ('dbx_business_glossary_term' = 'Expense Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `functional_currency_amount` SET TAGS ('dbx_business_glossary_term' = 'Functional Currency Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `functional_currency_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `functional_currency_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `invoice_date` SET TAGS ('dbx_business_glossary_term' = 'Vendor Invoice Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Vendor Invoice Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `invoice_received_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Received Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `is_dcc_expense` SET TAGS ('dbx_business_glossary_term' = 'Defense and Cost Containment (DCC) Expense Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `is_recoverable` SET TAGS ('dbx_business_glossary_term' = 'Expense Recoverable Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `lae_category` SET TAGS ('dbx_business_glossary_term' = 'Loss Adjustment Expense (LAE) Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `lae_category` SET TAGS ('dbx_value_regex' = 'ALAE|ULAE|DCC|AO');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Expense Payment Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Expense Payment Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'check|ach|wire|credit_card|eft');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Expense Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Expense Reversal Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `service_end_date` SET TAGS ('dbx_business_glossary_term' = 'Service End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `service_start_date` SET TAGS ('dbx_business_glossary_term' = 'Service Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `siu_referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Special Investigations Unit (SIU) Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'ClaimCenter|DuckCreek|BillingCenter|Manual|Legacy');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Expense Transaction Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` SET TAGS ('dbx_subdomain' = 'financial_positions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `prior_period_claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `bordereaux_period_code` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Bordereaux Period Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `calendar_year` SET TAGS ('dbx_business_glossary_term' = 'Calendar Year (CY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `close_date` SET TAGS ('dbx_business_glossary_term' = 'Period Close Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Period End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `fiscal_month` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Month');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `fiscal_quarter` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Quarter');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `fx_rate_to_usd` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate to USD');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `gl_period_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Period Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `ifrs17_reporting_period` SET TAGS ('dbx_business_glossary_term' = 'IFRS 17 Reporting Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `is_quarter_end` SET TAGS ('dbx_business_glossary_term' = 'Quarter-End Period Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `is_stub_period` SET TAGS ('dbx_business_glossary_term' = 'Stub Period Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `is_year_end` SET TAGS ('dbx_business_glossary_term' = 'Year-End Period Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `lock_date` SET TAGS ('dbx_business_glossary_term' = 'Period Lock Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `loss_development_lag` SET TAGS ('dbx_business_glossary_term' = 'Loss Development Lag (Months)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `naic_statement_period` SET TAGS ('dbx_business_glossary_term' = 'NAIC Statement Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `naic_statement_period` SET TAGS ('dbx_value_regex' = 'Q1|Q2|Q3|ANNUAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `period_basis` SET TAGS ('dbx_business_glossary_term' = 'Period Basis (CY/AY/PY/FY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `period_basis` SET TAGS ('dbx_value_regex' = 'CY|AY|PY|FY');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `period_code` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `period_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,4}-[0-9]{4}-[0-9]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `period_days` SET TAGS ('dbx_business_glossary_term' = 'Period Days Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `period_name` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `period_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `period_status` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `period_status` SET TAGS ('dbx_value_regex' = 'OPEN|CLOSED|LOCKED|REOPENED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `period_type` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `period_type` SET TAGS ('dbx_value_regex' = 'MONTHLY|QUARTERLY|ANNUAL|SEMI_ANNUAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `premium_earning_method` SET TAGS ('dbx_business_glossary_term' = 'Premium Earning Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `premium_earning_method` SET TAGS ('dbx_value_regex' = 'PRO_RATA|RULE_OF_78|DAILY|MONTHLY');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `reopen_date` SET TAGS ('dbx_business_glossary_term' = 'Period Reopen Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `reporting_framework` SET TAGS ('dbx_business_glossary_term' = 'Reporting Framework');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `reporting_framework` SET TAGS ('dbx_value_regex' = 'SAP|GAAP|IFRS17|STATUTORY');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `schedule_p_period_label` SET TAGS ('dbx_business_glossary_term' = 'Schedule P Period Label');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Period Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` SET TAGS ('dbx_subdomain' = 'financial_positions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `financial_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Financial Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `claimant_id` SET TAGS ('dbx_business_glossary_term' = 'Claimant Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `original_transaction_financial_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Original Financial Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Authorized By User ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `payment_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Payment ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `ri_claim_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Claim Cession Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `ri_premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Premium Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `ri_recovery_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Recovery Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `riskexposure_insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `salvage_id` SET TAGS ('dbx_business_glossary_term' = 'Salvage ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `ap_batch_number` SET TAGS ('dbx_business_glossary_term' = 'Accounts Payable (AP) Batch ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `authority_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Authority Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `calendar_year` SET TAGS ('dbx_business_glossary_term' = 'Calendar Year (CY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `ceded_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded (Reinsurance) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `ceded_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `ceded_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `coverage_type_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `current_balance_amount` SET TAGS ('dbx_business_glossary_term' = 'Current Balance Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `current_balance_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `current_balance_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `deductible_offset_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Offset Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `deductible_offset_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `deductible_offset_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `expense_category` SET TAGS ('dbx_business_glossary_term' = 'Loss Adjustment Expense (LAE) Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `expense_category` SET TAGS ('dbx_value_regex' = 'DCC|AO|ULAE|');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Transaction Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `gross_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `gross_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `loss_category` SET TAGS ('dbx_business_glossary_term' = 'Loss Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `loss_category` SET TAGS ('dbx_value_regex' = 'INDEMNITY|MEDICAL|LAE|ALAE|ULAE|OTHER');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Transaction Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `net_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `net_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `posted_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Posted Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `prior_balance_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Balance Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `prior_balance_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `prior_balance_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `reinsurance_recoverable_indicator` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `reserve_type` SET TAGS ('dbx_business_glossary_term' = 'Reserve Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `reserve_type` SET TAGS ('dbx_value_regex' = 'CASE|IBNR|IBNER|LAE|');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `reversal_indicator` SET TAGS ('dbx_business_glossary_term' = 'Reversal Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `siu_referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Special Investigations Unit (SIU) Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'CLAIMCENTER|DUCK_CREEK|GL|MANUAL|REINS_PRO');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `source_transaction_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Transaction Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `transaction_description` SET TAGS ('dbx_business_glossary_term' = 'Transaction Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `transaction_number` SET TAGS ('dbx_business_glossary_term' = 'Financial Transaction Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_business_glossary_term' = 'Financial Transaction Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_value_regex' = 'PENDING|POSTED|REVERSED|VOIDED|APPROVED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `transaction_subtype` SET TAGS ('dbx_business_glossary_term' = 'Financial Transaction Subtype');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Financial Transaction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'RESERVE|PAYMENT|RECOVERY|EXPENSE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` SET TAGS ('dbx_subdomain' = 'recovery_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `reinsurance_recovery_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recovery ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `financial_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Financial Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `reinsurer_party_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `ri_claim_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Claim Cession Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `ri_participant_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Participant Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `riskexposure_insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'treaty|facultative');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Attachment Point');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `authorized_control_level_flag` SET TAGS ('dbx_business_glossary_term' = 'Authorized Control Level (ACL) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `billing_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Billing Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Reporting Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(Q[1-4]|[0-9]{2})$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `cash_call_indicator` SET TAGS ('dbx_business_glossary_term' = 'Cash Call Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `ceded_lae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Adjustment Expense (LAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_business_glossary_term' = 'Cession Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `collateral_held_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Held Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `collection_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Collection Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `commutation_indicator` SET TAGS ('dbx_business_glossary_term' = 'Commutation Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `coverage_type_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `days_overdue` SET TAGS ('dbx_business_glossary_term' = 'Days Overdue');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `disputed_amount` SET TAGS ('dbx_business_glossary_term' = 'Disputed Recovery Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `loss_date` SET TAGS ('dbx_business_glossary_term' = 'Loss Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Recovery Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `outstanding_balance` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Recovery Balance');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `overdue_indicator` SET TAGS ('dbx_business_glossary_term' = 'Overdue Recovery Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `recovery_billed_amount` SET TAGS ('dbx_business_glossary_term' = 'Recovery Billed Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `recovery_collected_amount` SET TAGS ('dbx_business_glossary_term' = 'Recovery Collected Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `recovery_number` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recovery Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `recovery_status` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recovery Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `recovery_status` SET TAGS ('dbx_value_regex' = 'billed|collected|partial|disputed|written_off|void');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `recovery_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recovery Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `recovery_type` SET TAGS ('dbx_value_regex' = 'loss|lae|combined|salvage|subrogation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `reinsurer_limit` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Cedant Retention Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `settlement_reference` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Settlement Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'RMS|SAPIENS|SICS|MANUAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `treaty_type` SET TAGS ('dbx_business_glossary_term' = 'Treaty Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `treaty_type` SET TAGS ('dbx_value_regex' = 'quota_share|excess_of_loss|stop_loss|cat_xl');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `written_off_amount` SET TAGS ('dbx_business_glossary_term' = 'Written-Off Recovery Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` SET TAGS ('dbx_subdomain' = 'recovery_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `payee_id` SET TAGS ('dbx_business_glossary_term' = 'Payee ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `claimant_id` SET TAGS ('dbx_business_glossary_term' = 'Claimant Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `preferred_currency_id` SET TAGS ('dbx_business_glossary_term' = 'Preferred Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `address_line1` SET TAGS ('dbx_business_glossary_term' = 'Payee Address Line 1');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `address_line1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `address_line2` SET TAGS ('dbx_business_glossary_term' = 'Payee Address Line 2');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `address_line2` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `attorney_bar_number` SET TAGS ('dbx_business_glossary_term' = 'Attorney Bar Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `backup_withholding_flag` SET TAGS ('dbx_business_glossary_term' = 'Backup Withholding Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `bank_account_type` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `bank_account_type` SET TAGS ('dbx_value_regex' = 'checking|savings');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `bank_account_type` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `bank_account_type` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `bank_name` SET TAGS ('dbx_business_glossary_term' = 'Bank Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `bank_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_business_glossary_term' = 'Bank Routing Number (ABA)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_value_regex' = '^[0-9]{9}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'Payee City');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Payee Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `do_not_pay_flag` SET TAGS ('dbx_business_glossary_term' = 'Do Not Pay Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Payee Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `email` SET TAGS ('dbx_business_glossary_term' = 'Payee Email Address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `entity_type` SET TAGS ('dbx_business_glossary_term' = 'Payee Entity Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `entity_type` SET TAGS ('dbx_value_regex' = 'individual|organization');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Payee Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `fraud_indicator_flag` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `guardian_name` SET TAGS ('dbx_business_glossary_term' = 'Guardian or Conservator Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `guardian_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `guardian_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `is_1099_reportable` SET TAGS ('dbx_business_glossary_term' = '1099 Reportable Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `is_minor` SET TAGS ('dbx_business_glossary_term' = 'Minor Payee Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `is_structured_settlement` SET TAGS ('dbx_business_glossary_term' = 'Structured Settlement Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `lien_holder_flag` SET TAGS ('dbx_business_glossary_term' = 'Lienholder Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `payee_name` SET TAGS ('dbx_business_glossary_term' = 'Payee Full Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `payee_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `payee_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Payee Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^PAY-[0-9]{8,12}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `ofac_match_flag` SET TAGS ('dbx_business_glossary_term' = 'Office of Foreign Assets Control (OFAC) Match Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `ofac_screen_date` SET TAGS ('dbx_business_glossary_term' = 'Office of Foreign Assets Control (OFAC) Screen Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `ofac_screened` SET TAGS ('dbx_business_glossary_term' = 'Office of Foreign Assets Control (OFAC) Screened Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `payee_status` SET TAGS ('dbx_business_glossary_term' = 'Payee Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `payee_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending_verification|blocked');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `payee_type` SET TAGS ('dbx_business_glossary_term' = 'Payee Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `payee_type` SET TAGS ('dbx_value_regex' = 'claimant|attorney|vendor|lienholder|mortgagee|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'check|eft|wire|zelle|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `phone` SET TAGS ('dbx_business_glossary_term' = 'Payee Phone Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `phone` SET TAGS ('dbx_value_regex' = '^+?[0-9-s().]{7,20}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Payee Postal Code (ZIP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `postal_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}(-[0-9]{4})?$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `siu_referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Special Investigations Unit (SIU) Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'CLAIMCENTER|BILLINGCENTER|MDM|LEGACY');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `tax_id_type` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number (TIN) Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `tax_id_type` SET TAGS ('dbx_value_regex' = 'SSN|FEIN|ITIN|EIN');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `tax_id_type` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `tax_id_type` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `tax_id_verified` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number (TIN) Verified Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `tax_id_verified` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `tax_id_verified` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `tax_number` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number (TIN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `tax_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `tax_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `vendor_code` SET TAGS ('dbx_business_glossary_term' = 'Vendor Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `w9_received` SET TAGS ('dbx_business_glossary_term' = 'W-9 Form Received Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `w9_received_date` SET TAGS ('dbx_business_glossary_term' = 'W-9 Form Received Date');
