-- Schema for Domain: claimfinancials | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-20 14:33:30

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_blog_v499`.`claimfinancials` COMMENT 'Provisional description for user-specified domain claim_financials. Awaiting a generated description of what this domain owns.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` (
    `reserve_id` BIGINT COMMENT 'Unique surrogate identifier for each reserve position record. One row per reserve type per claim exposure per accounting period. Grain: one reserve movement per claim exposure per period.',
    `adjuster_id` BIGINT COMMENT 'Reference to the adjuster who authorized or last modified this reserve position. Required for reserve authority and audit trail.',
    `approved_by_party_id` BIGINT COMMENT 'Reference to the party (supervisor or manager) who approved this reserve movement when it exceeded adjuster authority limits. Null if no approval was required.',
    `catastrophe_event_id` BIGINT COMMENT 'Reference to the catastrophe event record when the claim is associated with a declared CAT. Null for non-catastrophe claims. Supports CAT aggregate reserve reporting.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the claim exposure (coverage line within a claim) to which this reserve position belongs. Links reserve to a specific coverage and insured risk within the claim.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim record. Denormalized for direct claim-level aggregation and reporting without joining through claim exposure.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this reserve position is recorded. Enables calendar year, accident year, and policy year reserve triangles.',
    `coverage_id` BIGINT COMMENT 'Reference to the coverage under which this reserve is established. Supports reserve analysis by coverage type and line of business.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Multi-currency claim operations require currency master for exchange rate lookup, functional currency conversion, rounding rules, and financial consolidation.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Actuarial reserve adequacy analysis, NAIC Schedule P reporting, and regulatory reserve filings require joining reserve transactions to LOB master for proper line classification, loss',
    `reinsurance_cession_id` BIGINT COMMENT 'Foreign key linking to reinsurance.cession. Business justification: Reserves track ceded amounts (ceded_opening_balance_amount, ceded_movement_amount) requiring direct cession link for monthly reserve adequacy reporting and Schedule F preparation.',
    `riskexposure_insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Actuaries segment reserve adequacy by risk characteristics (construction type, protection class, vehicle type, driver profile) for accurate loss development and catastrophe',
    `underwriting_loss_history_id` BIGINT COMMENT 'Foreign key linking to coverage.loss_history. Business justification: Actuaries use prior loss history from underwriting submissions to calibrate reserve adequacy and IBNR estimates for similar risk profiles.',
    `underwriting_risk_score_id` BIGINT COMMENT 'Foreign key linking to coverage.underwriting_risk_score. Business justification: Actuaries stratify case reserves and IBNR by underwriting risk tier (COPE score, territory score, catastrophe score).',
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
) COMMENT 'Reserve: Case, IBNR, and LAE reserve amounts for claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` (
    `claim_payment_id` BIGINT COMMENT 'Unique surrogate identifier for each claim payment disbursement record. Primary key. One row per payment per claim exposure per accounting period.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the specific coverage line within the claim (Claim Exposure) against which this payment is charged. Grain anchor per VREQ-007.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim under which this payment is issued. Links payment to the reported loss event.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this payment is recognized for statutory and GAAP financial reporting purposes.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: International claim payments require currency master for exchange rate application, withholding tax calculation, bank account validation, and functional currency conversion.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Payment authority limits, commission calculations, and loss ratio monitoring are configured by line of business.',
    `original_payment_claim_payment_id` BIGINT COMMENT 'Self-referencing identifier pointing to the original payment record when this row represents a reissue or replacement. Null for original disbursements.',
    `party_id` BIGINT COMMENT 'System user ID of the claims examiner or supervisor who authorized this payment within the authority limit matrix.',
    `payee_party_id` BIGINT COMMENT 'Reference to the Party record identifying the individual or organization receiving this payment (claimant, vendor, attorney, lienholder, loss payee).',
    `riskexposure_insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Subrogation departments track recovery potential by specific vehicle VIN or property address.',
    `underwriting_loss_history_id` BIGINT COMMENT 'Foreign key linking to coverage.loss_history. Business justification: Underwriters verify CLUE/MVR loss runs against internal payment history. Business process: loss_history records from submissions reference actual historical claim_payment',
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
    `payee_name` STRING COMMENT 'Full legal name of the payment recipient as printed on the check or EFT remittance. May differ from the claimant name (e.g., attorney, lienholder, mortgagee).',
    `payee_tax_number` STRING COMMENT 'Federal Employer Identification Number (FEIN) or Social Security Number (SSN) of the payee for IRS 1099 reporting. Masked in non-privileged access tiers.',
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
) COMMENT 'Claim Payment: Payments made on claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` (
    `recovery_id` BIGINT COMMENT 'Unique surrogate identifier for each claim recovery transaction. One row per recovery transaction per claim exposure per accounting period.',
    `adjuster_id` BIGINT COMMENT 'Reference to the claims adjuster or recovery specialist responsible for managing and pursuing this recovery transaction.',
    `attorney_organization_id` BIGINT COMMENT 'Foreign key linking to party.organization. Business justification: Recovery (salvage, subrogation, reinsurance) often involves legal counsel. Law firms are organizations requiring full party attribution for vendor management, payment processing, and',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the specific coverage line within the claim (Claim Exposure) against which this recovery is applied.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim record. Denormalized for direct claim-level reporting and aggregation without joining through claim exposure.',
    `claim_payment_id` BIGINT COMMENT 'Reference to the original claim payment transaction that this recovery offsets. Links recovery to the indemnity payment for net loss calculation.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this recovery transaction is recognized for statutory and GAAP financial reporting.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Subrogation and salvage recoveries must tie to the coverage that paid the original loss for proper reserve relief, reinsurance accounting, and statutory reporting.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Multi-currency recovery operations (reinsurance collections, subrogation from foreign insurers, salvage auctions) require currency master for demand amount conversion, collection tracking',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Subrogation and salvage recovery tracking, reinsurance recovery allocation, and net loss ratio calculation require LOB master for treaty participation rules, recovery expense',
    `reinsurance_cession_id` BIGINT COMMENT 'Reference to the reinsurance cession record when recovery_type is reinsurance. Null for subrogation and salvage recoveries.',
    `responsible_party_id` BIGINT COMMENT 'Reference to the party from whom recovery is sought: tortfeasor for subrogation, salvage buyer for salvage, or reinsurer for reinsurance recovery.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the reinsurance agreement (treaty or facultative) under which a reinsurance recovery is claimed. Null for subrogation and salvage.',
    `riskexposure_property_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.property_risk. Business justification: Salvage teams track disposition of damaged buildings and subrogation pursues liable parties for property damage at specific locations.',
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
) COMMENT 'Recovery: Subrogation, salvage, and reinsurance recoveries on claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` (
    `subrogation_id` BIGINT COMMENT 'Unique surrogate identifier for the subrogation pursuit record. One row per subrogation action initiated against a liable third party arising from a paid claim.',
    `attorney_organization_id` BIGINT COMMENT 'Foreign key linking to party.organization. Business justification: Law firms handling subrogation litigation are organizations in the party domain. Tracking counsel requires full organization details for billing, communication, and regulatory reporting.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the specific coverage line (claim exposure) within the claim that generated the subrogation opportunity. Enables per-coverage recovery tracking.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim from which this subrogation pursuit originates. Links the recovery action to the underlying loss event and paid indemnity.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which the subrogation recovery is recognized for statutory and GAAP financial reporting. Aligns with Schedule P accident year reporting.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Cross-border subrogation pursuits against foreign liable parties require currency master for demand amount calculation, settlement negotiation, collection tracking, and insured reimbursement',
    `liable_party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Subrogation pursues recovery from liable third parties who are tracked as party entities. Demand letters, settlement negotiations, and litigation require full party attribution including address',
    `riskexposure_auto_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.auto_risk. Business justification: Subrogation adjusters reference insured vehicle details, driver information, and garaging location when pursuing third-party recoveries.',
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
    `lob_code` STRING COMMENT 'NAIC line of business code for the policy coverage generating the subrogation. Drives recovery strategy, arbitration eligibility, and statutory reporting segmentation.',
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
    `reinsurance_recovery_amount` DECIMAL(18,2) COMMENT 'Portion of the gross subrogation collected amount allocable to reinsurers per treaty or facultative cession terms. Reported on Schedule F and reinsurance bordereaux.',
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
    `salvage_id` BIGINT COMMENT 'Unique surrogate identifier for the salvage record. One row per salvage activity per claim exposure on a total-loss insured item.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the claim exposure (coverage line within a claim) that generated this salvage activity.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim under which this salvage activity is recorded.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which salvage proceeds are recognized for statutory and GAAP reporting.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Salvage auction proceeds, storage costs, and net salvage calculations require currency master for multi-currency total loss settlements, reinsurance salvage share allocation, and functional',
    `insured_risk_id` BIGINT COMMENT 'Reference to the insured risk (vehicle, property, etc.) that is the subject of salvage disposition.',
    `riskexposure_property_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.property_risk. Business justification: Salvage teams coordinate property demolition, environmental remediation, and land sale with specific property characteristics.',
    `riskexposure_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.vehicle. Business justification: Salvage vendors require VIN, title number, and vehicle specifications for auction processing and title transfer.',
    `vendor_payee_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.payee. Business justification: Salvage has vendor_name and vendor_code (STRING) for the salvage vendor (auction house, salvage yard). Vendors are payees. Adding vendor_payee_id FK normalizes vendor master data.',
    `assigned_date` DATE COMMENT 'Date the salvage item was formally assigned to the salvage vendor or auction house for disposition.',
    `auction_date` DATE COMMENT 'Date on which the salvaged item was auctioned or sold. Used to align proceeds recognition with the correct accounting period.',
    `auction_fee` DECIMAL(18,2) COMMENT 'Fee charged by the auction house or salvage vendor for facilitating the sale, deducted from gross proceeds to arrive at net salvage.',
    `auction_proceeds` DECIMAL(18,2) COMMENT 'Gross cash proceeds received from the auction or direct sale of the salvaged item before deducting storage, towing, and auction fees.',
    `buyer_name` STRING COMMENT 'Name of the individual or entity that purchased the salvaged item at auction or direct sale.',
    `buyer_type` STRING COMMENT 'Classification of the salvage buyer. Determines applicable title transfer rules and tax reporting obligations.. Valid values are `dealer|individual|insurer|scrap_yard|auction_house`',
    `catastrophe_code` STRING COMMENT 'ISO or internal catastrophe event code linking this salvage to a declared CAT event for PML aggregation and reinsurance recovery.',
    `certificate_number` STRING COMMENT 'Certificate of destruction or salvage certificate number issued by the state DMV or relevant authority for the disposed item.',
    `closed_date` DATE COMMENT 'Date the salvage activity was closed, indicating all proceeds collected, title transferred, and financials reconciled.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the salvage record was first created in the claims management system.',
    `disposition_method` STRING COMMENT 'Method by which the salvaged item is disposed of. Impacts net salvage calculation and title transfer obligations.. Valid values are `auction|direct_sale|scrap|donation|insurer_retained|third_party_buyer`',
    `gl_account_code` STRING COMMENT 'GL account code to which the net salvage proceeds are posted in the statutory and GAAP general ledger.',
    `insured_retained_indicator` BOOLEAN COMMENT 'Indicates whether the insured elected to retain the salvaged item, resulting in a deduction from the total-loss settlement payment.',
    `insured_retention_deduction` DECIMAL(18,2) COMMENT 'Amount deducted from the total-loss settlement when the insured elects to retain the salvaged item, equal to the salvage value estimate.',
    `item_description` STRING COMMENT 'Free-text description of the salvaged item including make, model, year, condition, or property type to support valuation and disposition.',
    `lob_code` STRING COMMENT 'NAIC or internal line of business code (e.g., PAP, CA, HO) for statutory reporting and Schedule P allocation of salvage recoveries.',
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
) COMMENT 'Master record for salvage activity on a total-loss insured item. Tracks salvage value estimate, auction proceeds, title transfer status, storage costs, net salvage amount, and disposition method per claim exposure.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` (
    `claim_expense_id` BIGINT COMMENT 'Unique surrogate identifier for each claim expense transaction record. Primary key for the claim_expense table. One row per expense movement per claim exposure and accounting period.',
    `adjuster_id` BIGINT COMMENT 'Reference to the claims adjuster responsible for authorizing or submitting this expense. Links expense to the handling adjuster for workload and cost reporting.',
    `approved_by_party_id` BIGINT COMMENT 'Reference to the party (adjuster supervisor or manager) who approved this expense transaction. Required for audit trail and authority-level compliance.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the claim exposure (coverage line within a claim) to which this expense is allocated. Links expense to the specific coverage and insured risk.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim record. Enables direct claim-level aggregation of all expense transactions without joining through claim exposure.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this expense transaction is recognized for statutory and GAAP financial reporting purposes.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: LAE allocation to coverage line is required for Schedule P reporting, reinsurance bordereaux, and actuarial reserving.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Multi-currency claim expense processing (foreign adjuster fees, international expert invoices, cross-border legal costs) requires currency master for functional currency conversion',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: LAE allocation, expense ratio monitoring, and reinsurance expense recovery require LOB master for ALAE vs ULAE classification rules, treaty expense participation, and regulatory',
    `original_expense_claim_expense_id` BIGINT COMMENT 'For reversal transactions, references the claim_expense_id of the original expense being reversed. Null for original (non-reversal) expense transactions.',
    `payee_id` BIGINT COMMENT 'Reference to the party record of the vendor or service provider who rendered the service and generated this expense (e.g., law firm, medical examiner, appraiser).',
    `riskexposure_insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Expense management tracks inspection costs by property type, engineering report costs by construction class, and appraisal fees by vehicle type.',
    `financial_transaction_id` BIGINT COMMENT 'The native transaction identifier from the originating system of record (e.g., Guidewire ClaimCenter expense ID). Enables traceability back to the source system.',
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
) COMMENT 'Claim Expense: LAE, DCC, and AO expenses on claim exposures. GRAIN: One row per financial movement per claim exposure. Grain: one row per financial movement per claim exposure.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` (
    `loss_triangle_id` BIGINT COMMENT 'Unique surrogate identifier for each loss development triangle row. One row per cohort, development period, and triangle type combination.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Actuarial loss development triangles are stratified by peril type for IBNR reserving and Schedule P reporting.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'References the accounting period (calendar quarter or year-end) as of which this triangle cell is evaluated.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Multi-currency loss triangles for international operations require currency master for consistent development factor calculation, ultimate loss estimation, and functional currency',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Loss triangles are segmented by geographic territory for state-specific reserve adequacy analysis and NAIC Schedule P regulatory filings.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Actuarial loss development analysis, IBNR estimation, and reserve adequacy testing require LOB master for development pattern selection, tail factor application, and regulatory',
    `loss_approved_by_party_id` BIGINT COMMENT 'References the appointed actuary or senior reviewer who approved this triangle cell for statutory filing. Required for NAIC Annual Statement certification.',
    `loss_party_id` BIGINT COMMENT 'References the actuary or analyst responsible for selecting development factors and ultimate estimates for this triangle cell. Required for ORSA and SOX sign-off.',
    `accident_half_year` STRING COMMENT 'Semi-annual sub-period within the cohort year (e.g., 2022-H1, 2022-H2) for lines requiring half-year granularity such as short-tail property.. Valid values are `^[0-9]{4}-(H1|H2)$`',
    `approval_date` DATE COMMENT 'Date on which the triangle cell was approved by the appointed actuary or senior reviewer for inclusion in the statutory or GAAP reserve filing.',
    `case_alae_reserve_amount` DECIMAL(18,2) COMMENT 'Outstanding case reserve for allocated loss adjustment expenses (ALAE) on known open claims in this cohort as of the evaluation date.',
    `case_reserve_amount` DECIMAL(18,2) COMMENT 'Outstanding case reserve (OSLR) held for known reported but unsettled claims in this cohort as of the evaluation date. Excludes IBNR.',
    `catastrophe_flag` BOOLEAN COMMENT 'True if the losses in this triangle cell include catastrophe (CAT) event losses. Enables CAT vs. non-CAT loss triangle segmentation for PML and AAL analysis.',
    `claim_count_closed` BIGINT COMMENT 'Cumulative count of claims closed (with or without payment) for this cohort as of the evaluation date. Used in closure rate and tail factor analysis.',
    `claim_count_open` BIGINT COMMENT 'Count of claims still open (RBNS) for this cohort as of the evaluation date. Derived operationally as reported minus closed; stored for audit and triangle integrity.',
    `claim_count_reported` BIGINT COMMENT 'Cumulative count of claims reported for this cohort as of the evaluation date. Used in frequency-severity analysis and IBNR count triangles.',
    `cohort_type` STRING COMMENT 'Defines the basis for grouping losses into cohort rows: Accident Year (AY), Policy Year (PY), Calendar Year (CY), or Report Year. Determines triangle orientation.. Valid values are `accident_year|policy_year|calendar_year|report_year`',
    `cohort_year` BIGINT COMMENT 'The four-digit year identifying the loss cohort row (e.g., accident year 2021, policy year 2020). Forms the vertical axis of the development triangle.',
    `company_code` STRING COMMENT 'Five-digit NAIC company code identifying the legal entity (insurance company) for which this triangle is reported. Required for statutory Schedule P filing.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this triangle record was first written to the data lakehouse. Supports audit trail and data lineage for statutory and SOX compliance.',
    `development_factor` DECIMAL(10,6) COMMENT 'Cumulative loss development factor (LDF) from this development period to ultimate, as selected by the actuary. Used to project ultimate losses from current incurred.',
    `development_period` BIGINT COMMENT 'Age of the cohort in months at the evaluation date (e.g., 12, 24, 36, 48). Forms the horizontal axis of the development triangle.',
    `earned_premium_amount` DECIMAL(18,2) COMMENT 'Earned premium for the cohort year used as the denominator in loss ratio calculations. Enables calendar-year and accident-year loss ratio derivation.',
    `evaluation_date` DATE COMMENT 'The as-of date at which losses in this triangle cell are measured. Typically a quarter-end or year-end date used for statutory and GAAP reserving.',
    `gross_net_indicator` STRING COMMENT 'Indicates whether the triangle amounts are gross of reinsurance, net of reinsurance, or represent the ceded portion only. Critical for Schedule F and reinsurance reporting.. Valid values are `gross|net_of_reinsurance|ceded`',
    `group_code` STRING COMMENT 'NAIC group code for the insurance holding company group. Enables consolidated group-level Schedule P and RBC reporting across affiliated entities.',
    `ibnr_alae_amount` DECIMAL(18,2) COMMENT 'Actuarial IBNR estimate for allocated loss adjustment expenses for this cohort. Combined with case ALAE reserve to form total ALAE reserve.',
    `ibnr_amount` DECIMAL(18,2) COMMENT 'Actuarial estimate of losses incurred but not yet reported (IBNR), including IBNER development, for this cohort as of the evaluation date.',
    `incurred_loss_amount` DECIMAL(18,2) COMMENT 'Total incurred losses = paid losses + case reserves for this cohort and development period. Excludes IBNR. Used in loss ratio and Schedule P reporting.',
    `is_diagonal` BOOLEAN COMMENT 'True if this cell falls on the latest diagonal of the triangle (most recent evaluation for each cohort year). Used to filter current reserve position for reporting.',
    `is_tail_period` BOOLEAN COMMENT 'True if this development period is beyond the last observed data point and the amount is a tail-factor projection rather than an observed value.',
    `lob_name` STRING COMMENT 'Human-readable name of the line of business corresponding to lob_code, such as Private Passenger Auto Liability or Commercial General Liability.',
    `paid_alae_amount` DECIMAL(18,2) COMMENT 'Cumulative paid allocated loss adjustment expenses (ALAE/DCC) for this cohort as of the evaluation date. Reported separately on NAIC Schedule P.',
    `paid_loss_amount` DECIMAL(18,2) COMMENT 'Cumulative loss payments made to claimants for this cohort as of the evaluation date, excluding loss adjustment expenses. Core Schedule P column.',
    `prior_period_ultimate_amount` DECIMAL(18,2) COMMENT 'Ultimate loss estimate for this cohort from the prior evaluation period. Enables period-over-period reserve development and redundancy/deficiency analysis.',
    `reinsurance_program_type` STRING COMMENT 'Identifies the reinsurance structure applied when gross_net_indicator is net or ceded. Supports Schedule F and reinsurance bordereaux reporting.. Valid values are `gross|quota_share|excess_of_loss|stop_loss|facultative`',
    `reserve_development_amount` DECIMAL(18,2) COMMENT 'Change in ultimate loss estimate from prior to current evaluation period (favorable = negative, adverse = positive). Key metric for Schedule P reserve adequacy.',
    `reserving_method` STRING COMMENT 'Actuarial method used to estimate ultimate losses for this triangle cell. [ENUM-REF-CANDIDATE: chain_ladder|bornhuetter_ferguson|cape_cod|frequency_severity|clark_ldf|benktander|average_hindsight — promote to reference product]. Valid values are `chain_ladder|bornhuetter_ferguson|cape_cod|frequency_severity|clark_ldf|benktander`',
    `source_system_code` STRING COMMENT 'Code identifying the operational source system that provided the underlying loss and premium data (e.g., ClaimCenter, reserving system). Supports data lineage.',
    `tail_factor` DECIMAL(10,6) COMMENT 'Selected tail factor applied beyond the last observed development period to project losses to ultimate. Critical for long-tail lines such as GL, WC, and D&O.',
    `triangle_run_number` BIGINT COMMENT 'References the actuarial reserving run or batch that produced this triangle snapshot, enabling version comparison across evaluation dates.',
    `triangle_status` STRING COMMENT 'Workflow status of this triangle cell within the actuarial reserving cycle. Approved and published cells are used for statutory filings; superseded cells are retained for audit.. Valid values are `draft|reviewed|approved|published|superseded`',
    `triangle_type` STRING COMMENT 'Identifies the financial measure populating this triangle cell. [ENUM-REF-CANDIDATE: paid_loss|incurred_loss|case_reserve|ibnr|paid_alae|incurred_alae|paid_ulae|lae_total — promote to reference product]',
    `ultimate_alae_amount` DECIMAL(18,2) COMMENT 'Actuarial estimate of total ultimate ALAE for this cohort = paid ALAE + case ALAE reserve + IBNR ALAE. Used in combined ratio and Schedule P analytics.',
    `ultimate_loss_amount` DECIMAL(18,2) COMMENT 'Actuarial estimate of total ultimate losses for this cohort = incurred losses + IBNR. The primary output of the reserving process used in Schedule P.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this triangle record. Used to detect restatements and track reserve revisions across actuarial review cycles.',
    `written_premium_amount` DECIMAL(18,2) COMMENT 'Direct written premium (DPW) for the cohort year. Used alongside earned premium for policy year and accident year loss ratio benchmarking.',
    CONSTRAINT pk_loss_triangle PRIMARY KEY(`loss_triangle_id`)
) COMMENT 'Actuarial loss development triangle per accident year, policy year, or calendar year cohort. Stores paid losses, incurred losses, case reserves, and IBNR by development period for Schedule P and reserving analytics.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` (
    `ibnr_estimate_id` BIGINT COMMENT 'Unique surrogate primary key for each IBNR/IBNER actuarial estimate record. One row per LOB, accident year, and valuation date combination per actuarial run.',
    `actuary_party_id` BIGINT COMMENT 'Reference to the Party record of the credentialed actuary (FCAS/ACAS) who reviewed and signed off on this IBNR estimate per NAIC actuarial opinion requirements.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: IBNR estimates are calculated separately by peril type for actuarial reserve adequacy and ultimate loss projections.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period (calendar quarter or year-end) in which this IBNR estimate was recorded for statutory and GAAP financial reporting.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Multi-currency IBNR calculations for international portfolios require currency master for earned premium conversion, ultimate loss estimation, and functional currency consolidation.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: IBNR calculations are performed by state/territory for regulatory reserve requirements and state-specific actuarial certifications.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Actuarial IBNR estimation by line of business is required for statutory reserve filings, NAIC Schedule P reporting, and reserve adequacy opinions.',
    `underwriting_risk_score_id` BIGINT COMMENT 'Foreign key linking to coverage.underwriting_risk_score. Business justification: Actuarial IBNR models segment by underwriting risk score band to reflect loss emergence patterns by risk tier.',
    `accident_year` BIGINT COMMENT 'The calendar year in which the insured loss events occurred. Used as the primary actuarial development dimension for loss triangles and IBNR estimation per Schedule P.',
    `actuarial_notes` STRING COMMENT 'Free-text field for the actuary to document material assumptions, data limitations, method selections, or qualifications associated with this IBNR estimate.',
    `actuarial_run_number` STRING COMMENT 'Identifier for the actuarial reserving system batch run that produced this estimate. Enables traceability back to the specific model run in the Data Warehouse/Actuarial Reserving System.. Valid values are `^RUN-[0-9]{8}-[A-Z0-9]{6}$`',
    `actuary_signoff_date` DATE COMMENT 'Date on which the credentialed actuary formally approved and signed off on this IBNR estimate for inclusion in the statutory actuarial opinion or management reserve review.',
    `age_to_age_factor` DECIMAL(10,6) COMMENT 'Selected cumulative loss development factor (LDF) from current age to ultimate, used to project reported or paid losses to their ultimate value in the chain ladder method.',
    `case_reserve_amt` DECIMAL(18,2) COMMENT 'Outstanding case reserves (OSLR) held by claims adjusters for known reported claims as of the valuation date. Excludes IBNR and LAE reserves.',
    `claim_count_reported` BIGINT COMMENT 'Number of claims reported to the insurer for this accident year and LOB as of the valuation date. Used in frequency-severity IBNR methods and claim count development.',
    `claim_count_ultimate` BIGINT COMMENT 'Actuarially selected ultimate number of claims expected for this accident year and LOB, including unreported claims. Used in frequency-severity IBNR estimation.',
    `committee_approval_date` DATE COMMENT 'Date on which the reserve committee or senior management formally approved this IBNR estimate for booking to the general ledger and statutory financial statements.',
    `company_code` STRING COMMENT 'Five-digit NAIC company code identifying the legal entity (insurance company) for which this IBNR estimate is prepared. Required for statutory filings.. Valid values are `^[0-9]{5}$`',
    `confidence_level` DECIMAL(5,4) COMMENT 'Statistical confidence level associated with the IBNR estimate (e.g., 0.75 = 75th percentile). Used in risk-based capital (RBC) and ORSA reserve adequacy assessments.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this IBNR estimate record was first created in the actuarial reserving system or data warehouse. Used for audit trail and SOX compliance.',
    `cumulative_ldf` DECIMAL(10,6) COMMENT 'Product of all age-to-age factors from current maturity to ultimate, including the tail factor. Applied to reported or paid losses to derive the selected ultimate.',
    `data_source_system` STRING COMMENT 'Operational system from which loss triangle data was sourced for this estimate (e.g., Data Warehouse/Actuarial Reserving System, ClaimCenter, manual upload).. Valid values are `reserving_system|data_warehouse|actuarial_workbench|manual`',
    `development_method` STRING COMMENT 'Actuarial method used to estimate IBNR (e.g., Chain Ladder, Bornhuetter-Ferguson, Cape Cod, Clark LDF, Frequency-Severity). [ENUM-REF-CANDIDATE: chain_ladder|bornhuetter_ferguson|cape_cod|clark_ldf|frequency_severity|expected_loss — promote to reference',
    `earned_premium_amt` DECIMAL(18,2) COMMENT 'Net earned premium for this accident year and LOB as of the valuation date, used as the denominator for loss ratio calculations and ELR derivation.',
    `estimate_number` STRING COMMENT 'Human-readable business identifier for this actuarial estimate record, used in actuarial opinion letters, Schedule P filings, and reserving committee presentations.. Valid values are `^IBNR-[0-9]{4}-[0-9]{2}-[A-Z0-9]{4,20}$`',
    `estimate_status` STRING COMMENT 'Workflow status of this actuarial estimate. Only approved estimates are used in statutory filings. Superseded records are retained for audit trail.. Valid values are `draft|under_review|approved|superseded|archived`',
    `estimate_type` STRING COMMENT 'Distinguishes the type of actuarial reserve estimate: pure IBNR (unreported claims), IBNER (development on known claims), total IBNR, or LAE IBNR.. Valid values are `IBNR|IBNER|total_IBNR|LAE_IBNR`',
    `expected_loss_ratio` DECIMAL(10,6) COMMENT 'A priori expected loss ratio used in Bornhuetter-Ferguson and Cape Cod methods, derived from pricing or industry benchmarks. Expressed as a decimal (e.g., 0.65 = 65%).',
    `high_estimate_amt` DECIMAL(18,2) COMMENT 'Upper bound of the actuarial range of reasonable IBNR estimates as required by ASOP No. 43. Supports reserve adequacy disclosures in the actuarial opinion.',
    `ibner_amt` DECIMAL(18,2) COMMENT 'Estimated development on known reported claims where current case reserves are expected to be inadequate. Subset of total IBNR for IBNER-specific tracking.',
    `ibnr_amt` DECIMAL(18,2) COMMENT 'Actuarially estimated reserve for losses incurred but not yet reported to the insurer as of the valuation date. Core output of this estimate record.',
    `ibnr_claim_count` BIGINT COMMENT 'Estimated number of claims incurred but not yet reported as of the valuation date. Equals ultimate claim count minus reported claim count.',
    `is_cat_included` BOOLEAN COMMENT 'Indicates whether catastrophe (CAT) losses are included in this IBNR estimate. Actuaries often produce separate ex-CAT and total estimates for Schedule P and PML analysis.',
    `is_reinsurance_net` BOOLEAN COMMENT 'Indicates whether this IBNR estimate is net of reinsurance recoveries (true) or gross of reinsurance (false). Both gross and net estimates are required for Schedule F and IFRS 17.',
    `lae_ibnr_amt` DECIMAL(18,2) COMMENT 'Actuarially estimated reserve for unallocated and allocated loss adjustment expenses (ULAE/ALAE) on unreported and underdeveloped claims as of the valuation date.',
    `lob_description` STRING COMMENT 'Human-readable name of the line of business corresponding to lob_code, such as Commercial Multi-Peril, Personal Auto Liability, or Homeowners.',
    `low_estimate_amt` DECIMAL(18,2) COMMENT 'Lower bound of the actuarial range of reasonable IBNR estimates as required by ASOP No. 43. Supports reserve adequacy disclosures in the actuarial opinion.',
    `paid_losses_amt` DECIMAL(18,2) COMMENT 'Cumulative loss payments made through the valuation date for this accident year and LOB, net of recoveries. Used in paid loss development triangle.',
    `percent_developed` DECIMAL(10,6) COMMENT 'Reciprocal of the cumulative LDF, representing the estimated proportion of ultimate losses already reported or paid as of the valuation date (e.g., 0.80 = 80% developed).',
    `prior_ibnr_amt` DECIMAL(18,2) COMMENT 'IBNR estimate from the immediately preceding valuation date for this accident year and LOB. Enables period-over-period reserve development and redundancy/deficiency analysis.',
    `reported_losses_amt` DECIMAL(18,2) COMMENT 'Cumulative paid losses plus case reserves (OSLR) as of the valuation date for this accident year and LOB. Serves as the starting point for IBNR development.',
    `reserve_change_amt` DECIMAL(18,2) COMMENT 'Change in IBNR estimate from prior valuation to current valuation (current minus prior). Positive indicates reserve strengthening; negative indicates redundancy release.',
    `reserving_basis` STRING COMMENT 'Accounting basis under which this IBNR estimate is prepared: Statutory Accounting Principles (SAP), US GAAP, IFRS 17, or internal management basis.. Valid values are `SAP|GAAP|IFRS17|management`',
    `tail_factor` DECIMAL(10,6) COMMENT 'Loss development factor applied beyond the last observed development period to account for late-emerging losses. Critical for long-tail lines such as GL, WC, and medical malpractice.',
    `triangle_maturity_months` BIGINT COMMENT 'Age of the accident year in months as of the valuation date (e.g., 12, 24, 36). Identifies the column position in the loss development triangle used for this estimate.',
    `ulr` DECIMAL(10,6) COMMENT 'Selected ultimate loss ratio for this accident year and LOB, calculated as ultimate loss amount divided by earned premium. Key actuarial KPI for reserving adequacy.',
    `ultimate_loss_amt` DECIMAL(18,2) COMMENT 'Actuary-selected ultimate loss estimate for this accident year and LOB, representing total expected losses at full development. Equals reported losses plus IBNR.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this IBNR estimate record. Tracks revisions during the review and approval workflow prior to statutory filing.',
    `valuation_date` DATE COMMENT 'The as-of date through which loss development data was compiled for this estimate. Defines the maturity of the accident year triangle used in the actuarial analysis.',
    CONSTRAINT pk_ibnr_estimate PRIMARY KEY(`ibnr_estimate_id`)
) COMMENT 'Actuarial IBNR and IBNER estimate per LOB, accident year, and valuation date. Records selected ultimate, expected loss ratio, development factor, tail factor, and actuary sign-off. SSOT for IBNR positions.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` (
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Unique surrogate identifier for each accounting period record. Primary key. _canonical_skip_reason: REFERENCE_LOOKUP — this is a reference calendar/dimension table; per-role minimums are exempt.',
    `prior_period_claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the immediately preceding accounting period. Supports period-over-period variance analysis, loss triangle chaining, and reserve roll-forward calculations.',
    `accident_year` BIGINT COMMENT 'Four-digit accident year for loss development triangles and IBNR estimation. Losses are bucketed by the year the loss event occurred, per actuarial reserving standards.',
    `bordereaux_period_code` STRING COMMENT 'Period code used in reinsurance bordereaux submissions to treaty reinsurers. Aligns cession, premium, and loss data to the reinsurers reporting calendar.',
    `calendar_year` BIGINT COMMENT 'Four-digit calendar year (January–December). Used for CY loss ratio, CY written premium, and CY combined ratio analytics per NAIC Schedule P.',
    `close_date` DATE COMMENT 'Date on which the accounting period was officially closed (soft close). After this date, new transactions require a journal entry adjustment or period reopening.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this accounting period record was first created in the data platform. Supports audit trail and SOX compliance.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for financial transactions booked in this period (e.g., USD). Supports multi-currency statutory and GAAP reporting.. Valid values are `^[A-Z]{3}$`',
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
    CONSTRAINT pk_claimfinancials_accounting_period PRIMARY KEY(`claimfinancials_accounting_period_id`)
) COMMENT 'Reference calendar for financial close cycles. Defines calendar year, accident year, policy year, and fiscal period boundaries used to bucket premium, loss, and expense transactions for statutory and GAAP reporting.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` (
    `financial_transaction_id` BIGINT COMMENT 'Unique surrogate key for each atomic double-entry posting generated by a claim financial event. One row per financial movement per claim exposure. Grain: one row per posting.',
    `catastrophe_event_id` BIGINT COMMENT 'Reference to the catastrophe event (CAT) associated with this financial transaction, if the underlying loss is part of a declared catastrophe. Supports CAT loss aggregation and PML reporting.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the specific coverage line within the claim (Claim Exposure) that this financial movement is attributed to. Drives per-coverage financial reporting.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim under which this financial movement was generated. Links the posting to the reported loss event.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this financial transaction is recognized for statutory and GAAP reporting purposes.',
    `original_transaction_financial_transaction_id` BIGINT COMMENT 'For reversal or correction transactions, references the original financial_transaction_id that this entry offsets or corrects. Null for original (non-reversal) postings.',
    `party_id` BIGINT COMMENT 'System user ID of the adjuster, supervisor, or financial controller who authorized this financial transaction. Required for authority limit compliance and SOX audit trail.',
    `payment_id` BIGINT COMMENT 'Reference to the associated claim payment record when this financial transaction represents a disbursement. Links the GL posting to the payment instrument record for reconciliation.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the reinsurance agreement (treaty or facultative) under which the ceded portion of this transaction is recoverable. Null if no reinsurance applies.',
    `salvage_id` BIGINT COMMENT 'Reference to the associated salvage record when this financial transaction represents a salvage recovery. Links the GL posting to the salvage disposition record.',
    `accident_year` BIGINT COMMENT 'The calendar year in which the loss event (accident) occurred. Used for accident year (AY) loss development triangles and actuarial reserving analysis per NAIC Schedule P.',
    `ap_batch_number` STRING COMMENT 'Identifier of the accounts payable batch run in which this financial transaction was processed and disbursed. Used for payment reconciliation and GL batch balancing.',
    `authority_limit_amount` DECIMAL(18,2) COMMENT 'The financial authority limit of the approving user at the time of authorization. Confirms the transaction was within delegated authority and supports SOX internal controls.',
    `calendar_year` BIGINT COMMENT 'The calendar year in which this financial transaction was posted. Used for calendar year (CY) incurred loss and paid loss reporting in statutory financial statements.',
    `ceded_amount` DECIMAL(18,2) COMMENT 'Portion of the gross amount ceded to reinsurers under applicable treaty or facultative agreements. Used for net retained loss calculation and reinsurance bordereaux reporting.',
    `cost_center_code` STRING COMMENT 'Organizational cost center to which this financial transaction is allocated for internal management accounting and expense reporting purposes.',
    `coverage_type_code` STRING COMMENT 'Code identifying the specific coverage type (e.g., BI, PD, COMP, COLL, MED_PAY, UM/UIM) associated with this financial posting. Enables coverage-level financial analysis.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this financial transaction record was first created in the claims management system. Supports audit trail and data lineage requirements.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the transaction amounts (e.g., USD, CAD, GBP). Required for multi-currency operations and statutory reporting.. Valid values are `^[A-Z]{3}$`',
    `current_balance_amount` DECIMAL(18,2) COMMENT 'The reserve or financial balance on the claim exposure immediately after this transaction was applied. Supports outstanding loss reserve (OSLR) and IBNR reporting.',
    `deductible_offset_amount` DECIMAL(18,2) COMMENT 'Amount of the financial transaction attributable to the insureds deductible or self-insured retention (SIR), reducing the insurers net liability on this posting.',
    `effective_date` DATE COMMENT 'The date from which this financial transaction is effective for accounting and reserving purposes. May differ from transaction_date for backdated adjustments or period corrections.',
    `expense_category` STRING COMMENT 'For expense-type transactions, classifies the LAE component: DCC (Defense and Cost Containment), AO (Adjusting and Other), ULAE (Unallocated Loss Adjustment Expense). Null for non-expense transactions.. Valid values are `DCC|AO|ULAE|`',
    `gl_account_code` STRING COMMENT 'The GL account code to which this financial transaction is posted in the general ledger system (Oracle/SAP). Enables reconciliation between claims system and statutory financial statements.',
    `gross_amount` DECIMAL(18,2) COMMENT 'The full gross monetary amount of this financial posting before any reinsurance, deductible, or offset adjustments. Positive for charges/losses; negative for recoveries/credits.',
    `lob_code` STRING COMMENT 'NAIC or internal line of business code classifying the coverage type associated with this financial transaction (e.g., HO, PAP, CGL, CA, WC, BOP). Supports Schedule P segmentation.',
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
) COMMENT 'One row per atomic double-entry posting generated by a claim financial event (reserve, payment, recovery, expense), keyed to claim exposure and accounting period. Grain: one row per financial movement per claim exposure.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` (
    `reinsurance_recovery_id` BIGINT COMMENT 'Unique surrogate identifier for each reinsurance recovery billing record. One row per reinsurance recovery billing per claim exposure and treaty or facultative agreement.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the specific coverage line (claim exposure) within the claim to which this recovery applies.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim from which this reinsurance recovery originates.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this recovery transaction is recognized for statutory and GAAP financial reporting.',
    `reinsurance_cession_id` BIGINT COMMENT 'Reference to the reinsurance cession record that establishes the cedants share ceded to the reinsurer under the applicable agreement.',
    `reinsurer_party_id` BIGINT COMMENT 'Reference to the party record representing the reinsurer from whom recovery is sought.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the reinsurance agreement (treaty or facultative) under which this recovery is billed.',
    `ri_recovery_id` BIGINT COMMENT 'FK to reinsurance.ri_recovery.ri_recovery_id — Links the cedant-side reinsurance recovery accrual to the reinsurance ceded-loss ledger so ceded recovery is booked once and reconciled, preventing double-counting of recoverables (VREQ-009/VREQ-014).',
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
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this recovery record (e.g., USD, GBP, EUR).. Valid values are `^[A-Z]{3}$`',
    `days_overdue` BIGINT COMMENT 'Number of calendar days the outstanding recovery balance has been past the contractual due date. Used for Schedule F aging buckets and credit risk monitoring.',
    `disputed_amount` DECIMAL(18,2) COMMENT 'Portion of the billed recovery amount that the reinsurer has formally disputed. Tracked separately for collections and reserving purposes.',
    `due_date` DATE COMMENT 'Contractual due date by which the reinsurer is obligated to remit the recovery amount per the reinsurance agreement terms.',
    `gl_account_code` STRING COMMENT 'General Ledger account code to which this reinsurance recovery is posted in the statutory and GAAP financial statements.',
    `lob_code` STRING COMMENT 'NAIC or internal Line of Business code for the underlying policy (e.g., HO, PAP, CGL, BOP, CA). Used for treaty allocation and Schedule F/P reporting. [ENUM-REF-CANDIDATE: HO|PAP|CGL|BOP|CA|WC|CPP|EPLI|DO|EO — promote to reference product]',
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

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` (
    `claim_financial_snapshot_id` BIGINT COMMENT 'Unique surrogate key for each point-in-time financial position record per claim exposure and valuation date. Grain: one row per claim exposure per valuation date.',
    `catastrophe_event_id` BIGINT COMMENT 'Reference to the catastrophe event record when the claim is CAT-designated. Links to PCS bulletin or internal CAT event for aggregate PML reporting.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the specific coverage line within the claim (Claim Exposure) for which this financial position is recorded.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim record for which this financial snapshot is captured.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period (calendar month/quarter/year) in which this snapshot is valued for statutory and GAAP reporting.',
    `coverage_id` BIGINT COMMENT 'Reference to the specific coverage (e.g., BI, PD, Comp, Collision) under which this claim exposure is adjudicated.',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which the claim was filed, enabling policy-year and underwriting-year loss aggregation.',
    `quote_id` BIGINT COMMENT 'Foreign key linking to coverage.quote. Business justification: Pricing actuaries perform quote-vs-actual loss ratio analysis to validate rating adequacy.',
    `reinsurance_cession_id` BIGINT COMMENT 'Reference to the specific reinsurance cession record for this claim exposure. Links to bordereaux reporting and RI recovery tracking.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the primary reinsurance agreement (treaty or facultative) under which ceded amounts are reported for this claim exposure.',
    `riskexposure_insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Catastrophe modelers aggregate incurred losses by geocoded property locations and construction types for event loss estimation.',
    `accident_year` BIGINT COMMENT 'The calendar year in which the loss event occurred. Used for Schedule P loss triangle development and actuarial reserving by accident year.',
    `case_reserve_amount` DECIMAL(18,2) COMMENT 'Outstanding case reserve (OSLR) set by the adjuster for this claim exposure as of the valuation date. Represents the estimated future loss payment.',
    `catastrophe_indicator` BOOLEAN COMMENT 'Indicates whether this claim exposure is associated with a declared catastrophe event. Drives CAT loss reporting and reinsurance CAT XL recovery.',
    `ceded_ibnr_amount` DECIMAL(18,2) COMMENT 'Portion of the IBNR reserve ceded to reinsurers as of the valuation date. Used for net IBNR and Schedule F reinsurance reporting.',
    `ceded_paid_amount` DECIMAL(18,2) COMMENT 'Cumulative loss payments ceded to and recovered from reinsurers on this claim exposure through the valuation date.',
    `ceded_reserve_amount` DECIMAL(18,2) COMMENT 'Portion of the outstanding case reserve ceded to reinsurers under treaty or facultative agreements as of the valuation date.',
    `claim_status` STRING COMMENT 'Current adjudication status of the claim as of the valuation date. Drives reserve adequacy assessment and closure rate analytics.. Valid values are `open|closed|reopened|pending|denied|litigated`',
    `coverage_type_code` STRING COMMENT 'Specific coverage type within the LOB (e.g., BI, PD, COMP, COLL, MED, UMBI) identifying the peril or benefit being claimed.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts in this snapshot (e.g., USD). Supports multi-currency reinsurance reporting.. Valid values are `^[A-Z]{3}$`',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Policyholder deductible applicable to this claim exposure. Reduces the insurers gross loss payment obligation.',
    `development_period` BIGINT COMMENT 'Number of months elapsed from the accident year start to the valuation date. Used as the x-axis in loss development triangles (e.g., 12, 24, 36 months).',
    `ibnr_reserve_amount` DECIMAL(18,2) COMMENT 'Actuarially allocated IBNR reserve for this claim exposure or cohort as of the valuation date. Includes IBNER development on known claims.',
    `lae_reserve_amount` DECIMAL(18,2) COMMENT 'Case reserve for allocated loss adjustment expenses (ALAE/DCC) associated with this claim exposure as of the valuation date.',
    `lob_code` STRING COMMENT 'NAIC line of business code classifying the coverage (e.g., 01=Fire, 05=CMP, 19=Auto Liability, 21=Workers Comp). Drives Schedule P grouping.',
    `net_incurred_amount` DECIMAL(18,2) COMMENT 'Net retained total incurred loss after reinsurance cessions and recoveries. Key metric for net loss ratio and RBC capital calculations.',
    `net_reserve_amount` DECIMAL(18,2) COMMENT 'Net retained case reserve after cessions to reinsurers (gross case reserve minus ceded reserve). Represents the companys retained liability.',
    `paid_lae_amount` DECIMAL(18,2) COMMENT 'Cumulative allocated loss adjustment expense (ALAE) payments made on this claim exposure through the valuation date.',
    `paid_loss_amount` DECIMAL(18,2) COMMENT 'Cumulative loss payments made on this claim exposure through the valuation date, net of recoveries. Excludes LAE payments.',
    `policy_limit_amount` DECIMAL(18,2) COMMENT 'Maximum coverage limit applicable to this claim exposure as of the loss date. Used to cap incurred amounts and assess limit adequacy.',
    `policy_year` BIGINT COMMENT 'The year in which the policy that generated this claim was written. Used for policy-year loss development and reinsurance treaty year allocation.',
    `prior_period_incurred_amount` DECIMAL(18,2) COMMENT 'Total incurred amount as of the immediately preceding valuation period. Enables period-over-period reserve development and redundancy/deficiency analysis.',
    `prior_period_paid_amount` DECIMAL(18,2) COMMENT 'Cumulative paid loss as of the immediately preceding valuation period. Used to compute incremental paid loss development in loss triangles.',
    `report_year` BIGINT COMMENT 'The calendar year in which the claim was first reported (FNOL). Used for reported-year loss triangles and IBNR analysis.',
    `reserve_basis` STRING COMMENT 'Identifies the reserving methodology basis for this snapshot record (case, IBNR, LAE, ULAE, or bulk). Supports actuarial triangle segmentation.. Valid values are `case|ibnr|lae|ulae|bulk`',
    `reserve_change_amount` DECIMAL(18,2) COMMENT 'Change in total incurred from prior period to current valuation date (current incurred minus prior incurred). Positive = strengthening; negative = release.',
    `salvage_reserve_amount` DECIMAL(18,2) COMMENT 'Estimated future salvage recovery reserved against this claim exposure as of the valuation date. Reduces net incurred loss.',
    `sir_amount` DECIMAL(18,2) COMMENT 'Self-insured retention amount applicable to this claim exposure for large commercial accounts. Insurer pays above the SIR threshold.',
    `snapshot_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this financial snapshot record was first created in the data warehouse. Supports audit trail and data lineage for statutory reporting.',
    `snapshot_status` STRING COMMENT 'Lifecycle status of this financial snapshot record indicating whether it is the current active position or has been superseded by a later valuation.. Valid values are `open|closed|reopened|voided|superseded`',
    `snapshot_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this financial snapshot record was last modified. Used to detect restatements and track reserve re-estimations over time.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record that originated this financial data (e.g., CLAIMCENTER, RESERVING_DW, ACTUARIAL). Supports data lineage.',
    `state_code` STRING COMMENT 'Two-letter US state code where the insured risk is located or the loss occurred. Required for state-level statutory reporting to DOI.. Valid values are `^[A-Z]{2}$`',
    `subrogation_reserve_amount` DECIMAL(18,2) COMMENT 'Estimated future subrogation recovery reserved against this claim exposure as of the valuation date. Reduces net incurred loss.',
    `total_incurred_amount` DECIMAL(18,2) COMMENT 'Total incurred loss = paid loss + case reserve + IBNR allocation as of the valuation date. Primary metric for Schedule P and loss ratio reporting.',
    `total_incurred_lae_amount` DECIMAL(18,2) COMMENT 'Total incurred LAE = paid LAE + LAE reserve as of the valuation date. Used for combined ratio and expense ratio statutory reporting.',
    `total_recovery_collected_amount` DECIMAL(18,2) COMMENT 'Cumulative subrogation, salvage, and other third-party recoveries actually collected on this claim exposure through the valuation date.',
    `ulae_reserve_amount` DECIMAL(18,2) COMMENT 'Allocated portion of the ULAE reserve for this claim exposure as of the valuation date. Covers overhead claims handling costs not directly assignable.',
    `valuation_date` DATE COMMENT 'The as-of date for this financial snapshot. All reserve, paid, and incurred amounts reflect the financial position as of this date.',
    CONSTRAINT pk_claim_financial_snapshot PRIMARY KEY(`claim_financial_snapshot_id`)
) COMMENT 'Point-in-time financial position per claim exposure as of a valuation date. Stores total incurred (paid + case reserve), IBNR allocation, ceded amounts, net retained position, and prior-period comparison for statutory reporting.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` (
    `lae_allocation_id` BIGINT COMMENT 'Unique surrogate identifier for each LAE allocation record. Grain: one row per ULAE allocation transaction per claim exposure per accounting period.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: LAE allocation methods vary by peril type with catastrophe losses requiring different ULAE/ALAE allocation rules than attritional losses.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the specific coverage line within a claim to which this LAE allocation is applied.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim associated with this LAE allocation, enabling claim-level aggregation of allocated ULAE.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this ULAE allocation is recorded for statutory and GAAP financial reporting.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: ULAE and ALAE allocation to coverage is required for actuarial reserving, reinsurance settlement, and Schedule P reporting.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: LAE allocation is performed by state for regulatory expense reporting and state-specific expense ratio analysis.',
    `original_allocation_lae_allocation_id` BIGINT COMMENT 'For reversal or adjustment records, references the original allocation being corrected, enabling audit trail of allocation amendments.',
    `accident_year` BIGINT COMMENT 'The calendar year in which the loss event occurred, used for accident-year loss development triangles and IBNR actuarial analysis.',
    `actuarial_review_flag` BOOLEAN COMMENT 'Indicates this allocation record has been flagged for actuarial review due to anomalous weight, amount, or method deviation.',
    `allocated_alae_amount` DECIMAL(18,4) COMMENT 'The dollar amount of ALAE directly assigned to this claim exposure, distinct from ULAE which is spread via actuarial method.',
    `allocated_ulae_amount` DECIMAL(18,4) COMMENT 'The dollar amount of ULAE allocated to this specific claim exposure for the accounting period using the selected actuarial method.',
    `allocation_basis_amount` DECIMAL(18,4) COMMENT 'The denominator value for this claim exposure used in the allocation calculation (e.g., paid loss amount, incurred loss amount, or claim count).',
    `allocation_basis_code` STRING COMMENT 'The denominator basis used to spread ULAE across claim exposures (e.g., paid losses, incurred losses, claim count, earned premium).. Valid values are `PAID_LOSS|INCURRED_LOSS|CLAIM_COUNT|EXPOSURE_UNIT|EARNED_PREMIUM`',
    `allocation_method_code` STRING COMMENT 'Actuarial method used to allocate ULAE to individual claim exposures. [ENUM-REF-CANDIDATE: PAID_TO_PAID|KITTEL|BORNHUETTER_FERGUSON|DEVELOPMENT|BUDGETED|OTHER — promote to reference product]. Valid values are `PAID_TO_PAID|KITTEL|BORNHUETTER_FERGUSON|DEVELOPMENT|BUDGETED|OTHER`',
    `allocation_method_name` STRING COMMENT 'Human-readable name of the actuarial allocation method applied (e.g., Paid-to-Paid, Kittel Method), for reporting and audit trail.',
    `allocation_number` STRING COMMENT 'Business-facing unique identifier for this allocation transaction, used in actuarial bordereaux and Schedule P reporting.',
    `allocation_run_date` DATE COMMENT 'The date on which the actuarial allocation batch run was executed, used for version control and audit of actuarial estimates.',
    `allocation_run_number` STRING COMMENT 'Identifier for the actuarial batch run that produced this allocation, enabling full traceability and re-run comparison across allocation cycles.',
    `allocation_status` STRING COMMENT 'Current lifecycle state of the allocation record within the actuarial reserving and GL posting workflow.. Valid values are `draft|posted|reversed|adjusted|voided`',
    `allocation_weight` DECIMAL(10,8) COMMENT 'The proportional weight assigned to this claim exposure in the ULAE allocation calculation, expressed as a decimal fraction (0 to 1).',
    `calendar_year` BIGINT COMMENT 'The calendar year in which this allocation transaction is recorded, supporting calendar-year statutory financial reporting.',
    `company_code` STRING COMMENT 'Legal entity or statutory company code for multi-company insurers, required for NAIC Annual Statement filing by legal entity.',
    `cost_center_code` STRING COMMENT 'Organizational cost center to which this LAE allocation is attributed for internal management reporting and expense allocation.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this allocation record was first created in the system, supporting audit trail and SOX compliance.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this allocation record (e.g., USD).. Valid values are `^[A-Z]{3}$`',
    `evaluation_date` DATE COMMENT 'The as-of date for which loss and expense data were evaluated in this allocation run, aligning with actuarial triangle evaluation dates.',
    `gl_account_code` STRING COMMENT 'The GL account code to which this LAE allocation is posted, enabling reconciliation to the statutory balance sheet and income statement.',
    `gross_net_indicator` STRING COMMENT 'Specifies whether this allocation represents gross (before reinsurance), net (after reinsurance), or ceded LAE for statutory reporting.. Valid values are `GROSS|NET|CEDED`',
    `lae_type_code` STRING COMMENT 'Classifies the LAE component being allocated: ULAE (Unallocated), ALAE (Allocated), DCC (Defense & Cost Containment), or AO (Adjusting & Other).. Valid values are `ULAE|ALAE|DCC|AO`',
    `lob_code` STRING COMMENT 'NAIC line of business code identifying the insurance line (e.g., HO, PAP, CGL, CA) for Schedule P and statutory reporting segmentation.',
    `notes` STRING COMMENT 'Free-text field for actuarial or accounting commentary on this allocation, including method overrides or period-end adjustments.',
    `policy_year` BIGINT COMMENT 'The year in which the policy was written, used for policy-year loss development and reinsurance treaty year attribution.',
    `posted_date` DATE COMMENT 'The date this allocation was posted to the General Ledger, used for reconciliation between actuarial and accounting records.',
    `reinsurance_net_indicator` BOOLEAN COMMENT 'Indicates whether the allocated LAE amount is net of reinsurance recoveries, distinguishing gross vs. net LAE for Schedule F reporting.',
    `reversal_indicator` BOOLEAN COMMENT 'Indicates whether this allocation record is a reversal of a prior allocation, supporting net-zero correction entries in the GL.',
    `source_system_code` STRING COMMENT 'Code identifying the originating system that produced this allocation record (e.g., actuarial reserving system, data warehouse).',
    `total_lae_amount` DECIMAL(18,4) COMMENT 'Sum of allocated ULAE and ALAE for this claim exposure and accounting period, used for combined LAE reporting on Schedule P.',
    `total_pool_basis_amount` DECIMAL(18,4) COMMENT 'The total denominator (basis) amount across all claim exposures in the allocation pool, used to verify allocation weight calculations.',
    `total_pool_ulae_amount` DECIMAL(18,4) COMMENT 'The total ULAE pool amount for the LOB and accounting period from which this allocation is drawn, enabling reconciliation to the pool total.',
    `transaction_date` DATE COMMENT 'The business effective date of this allocation transaction, used for period-end close and statutory financial statement preparation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this allocation record, used for incremental data loads and change tracking.',
    CONSTRAINT pk_lae_allocation PRIMARY KEY(`lae_allocation_id`)
) COMMENT 'Allocates unallocated LAE (ULAE) to individual claim exposures using an actuarial allocation method (paid-to-paid, Kittel, etc.). Records allocated ULAE amount, method code, allocation basis, and accounting period.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` (
    `payee_id` BIGINT COMMENT 'Unique surrogate identifier for the payee master record. One row per party designated to receive claim payments. MASTER_PARTY role.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Payee address determines tax jurisdiction for 1099 reporting, state withholding requirements, and escheatment rules.',
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

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` (
    `statutory_reserve_filing_id` BIGINT COMMENT 'Unique surrogate identifier for each statutory reserve filing record submitted to a state DOI or NAIC. Grain: one row per filing per LOB per state per accident year per accounting period.',
    `actuary_party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Statutory reserve filings require actuarial certification with full party attribution for regulatory compliance, professional credential verification, and audit trail.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period (calendar quarter or year-end) for which this reserve position is reported.',
    `coverage_type_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_type. Business justification: Schedule P filings aggregate reserves by coverage type (NAIC line code) for regulatory reporting.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Statutory reserve filings are state-specific regulatory submissions to insurance departments.',
    `original_filing_statutory_reserve_filing_id` BIGINT COMMENT 'Reference to the original statutory_reserve_filing_id that this record amends or supersedes, populated only when amended_filing_indicator is true.',
    `accident_year` BIGINT COMMENT 'The calendar year in which the insured loss events occurred, used as the primary cohort for Schedule P loss development and reserve adequacy analysis.',
    `actuary_certification_date` DATE COMMENT 'Date on which the appointed actuary signed and certified the reserve opinion included in this statutory filing.',
    `actuary_credential` STRING COMMENT 'Professional designation of the certifying actuary (e.g., FCAS, ACAS, MAAA) confirming qualification to opine on P&C reserves.. Valid values are `FCAS|ACAS|MAAA|FSA|ASA`',
    `amended_filing_indicator` BOOLEAN COMMENT 'Indicates whether this filing is an amendment to a previously submitted statutory reserve filing for the same period, LOB, and state.',
    `case_reserve_amount` DECIMAL(18,2) COMMENT 'Outstanding Loss Reserve (OSLR) established by adjusters for known, reported claims not yet settled, per LOB, state, and accident year.',
    `catastrophe_flag` BOOLEAN COMMENT 'Indicates whether the reserves in this filing include losses attributable to a designated catastrophe event, enabling CAT vs. non-CAT reserve segregation.',
    `claim_count_open` BIGINT COMMENT 'Number of open (unsettled) claims as of the evaluation date for the accident year and LOB, supporting reserve per-claim analysis.',
    `claim_count_reported` BIGINT COMMENT 'Cumulative number of claims reported through the evaluation date for the accident year and LOB.',
    `company_name` STRING COMMENT 'Legal name of the insurance company entity submitting the statutory reserve filing.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this statutory reserve filing record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts in this filing (typically USD for US statutory filings).. Valid values are `^[A-Z]{3}$`',
    `earned_premium_amount` DECIMAL(18,2) COMMENT 'Earned Premium (EP) for the accident year and LOB used as the denominator in loss ratio calculations for this filing.',
    `evaluation_date` DATE COMMENT 'The as-of date through which loss and reserve data are evaluated for this filing, typically the last day of the accounting period.',
    `filing_date` DATE COMMENT 'Date on which the statutory reserve filing was submitted to the state DOI or NAIC.',
    `filing_number` STRING COMMENT 'Externally assigned or internally generated unique filing reference number used to track this submission with the state DOI or NAIC.',
    `filing_status` STRING COMMENT 'Current lifecycle state of the statutory reserve filing with the regulatory authority.. Valid values are `draft|submitted|accepted|rejected|amended|superseded`',
    `filing_type` STRING COMMENT 'Classification of the filing as annual, quarterly, amended, or supplemental per NAIC statement requirements.. Valid values are `annual|quarterly|amended|supplemental`',
    `gross_net_indicator` STRING COMMENT 'Indicates whether reserve amounts are stated gross of reinsurance, net of reinsurance cessions, or represent the ceded portion only.. Valid values are `gross|net_of_reinsurance|ceded`',
    `ibnr_amount` DECIMAL(18,2) COMMENT 'Actuarially estimated reserve for losses incurred but not yet reported (IBNR) plus development on known claims (IBNER), per LOB, state, and accident year.',
    `incurred_loss_amount` DECIMAL(18,2) COMMENT 'Total incurred losses (paid losses plus case reserve plus IBNR) for the accident year and LOB as of the evaluation date.',
    `lae_reserve_amount` DECIMAL(18,2) COMMENT 'Reserve for unpaid Loss Adjustment Expenses (LAE), including both Allocated LAE (ALAE) and Unallocated LAE (ULAE), per LOB, state, and accident year.',
    `lob_code` STRING COMMENT 'NAIC or internal Line of Business code classifying the insurance product line (e.g., HO, PAP, CGL, CA, WC) for this reserve filing.',
    `lob_name` STRING COMMENT 'Human-readable name of the line of business corresponding to lob_code (e.g., Homeowners, Personal Auto, Commercial General Liability).',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC-assigned company code identifying the reporting insurance entity.. Valid values are `^[0-9]{5}$`',
    `naic_statement_period` STRING COMMENT 'NAIC reporting period label in YYYY-Q# or YYYY-YE format identifying the statutory statement period for this filing.. Valid values are `^[0-9]{4}-(Q1|Q2|Q3|Q4|YE)$`',
    `paid_lae_amount` DECIMAL(18,2) COMMENT 'Cumulative LAE payments made through the evaluation date for the accident year and LOB.',
    `paid_loss_amount` DECIMAL(18,2) COMMENT 'Cumulative loss payments made through the evaluation date for the accident year and LOB, used in loss development triangle construction.',
    `policy_year` BIGINT COMMENT 'The year in which the policies generating the losses were written, used as an alternative cohort basis for reserve analysis.',
    `prior_year_reserve_amount` DECIMAL(18,2) COMMENT 'Total reserve amount carried in the prior year-end filing for the same LOB, state, and accident year cohort, used to measure reserve development.',
    `rbc_impact_amount` DECIMAL(18,2) COMMENT 'Estimated impact of the reserve position on the companys Risk-Based Capital (RBC) ratio, used for solvency monitoring and ORSA reporting.',
    `regulatory_due_date` DATE COMMENT 'Statutory deadline by which this reserve filing must be submitted to the state DOI or NAIC to remain in compliance.',
    `reinsurance_recoverable_amount` DECIMAL(18,2) COMMENT 'Estimated reinsurance recoverables on unpaid losses and LAE ceded under treaties and facultative agreements for this LOB, state, and accident year.',
    `reporting_basis` STRING COMMENT 'Accounting basis under which reserves are stated: Statutory Accounting Principles (SAP), US GAAP, or IFRS 17.. Valid values are `SAP|GAAP|IFRS17`',
    `reserve_adequacy_opinion` STRING COMMENT 'Actuarial opinion on whether the carried reserves are adequate, reasonable, or require qualification per the appointed actuarys review.. Valid values are `adequate|inadequate|reasonable|qualified|adverse`',
    `reserve_development_amount` DECIMAL(18,2) COMMENT 'Change in total reserve from the prior year filing to the current filing for the same cohort, indicating favorable (negative) or adverse (positive) development.',
    `reserving_method` STRING COMMENT 'Actuarial method used to estimate IBNR and ultimate losses (e.g., Chain Ladder, Bornhuetter-Ferguson, Cape Cod, Expected Loss). [ENUM-REF-CANDIDATE: chain_ladder|bornhuetter_ferguson|cape_cod|expected_loss|frequency_severity|clark_ldf — promote to',
    `schedule_p_line` STRING COMMENT 'NAIC Schedule P line designation (e.g., Line 1 - Homeowners, Line 5 - Commercial Auto) to which this reserve filing maps for statutory reporting.',
    `source_system_code` STRING COMMENT 'Code identifying the operational source system (e.g., actuarial reserving system, data warehouse) from which this filing record was originated.',
    `total_reserve_amount` DECIMAL(18,2) COMMENT 'Sum of case reserve, IBNR, and LAE reserve representing the total unpaid loss and LAE obligation reported in this filing.',
    `ultimate_loss_estimate` DECIMAL(18,2) COMMENT 'Actuarial estimate of the ultimate net loss (UNL) for the accident year and LOB, representing the final expected total cost of all claims.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this statutory reserve filing record.',
    CONSTRAINT pk_statutory_reserve_filing PRIMARY KEY(`statutory_reserve_filing_id`)
) COMMENT 'Statutory reserve position submitted to state DOI or NAIC. Captures LOB, state, accident year, case reserve, IBNR, total incurred, filing date, actuary certification, and SAP vs GAAP basis for regulatory compliance.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` (
    `claimfinancials_bordereaux_line_id` BIGINT COMMENT 'Unique surrogate primary key for one claim line in a reinsurance bordereaux submission. Grain: one row per claim exposure per bordereaux reporting period per reinsurance agreement.',
    `bordereaux_id` BIGINT COMMENT 'Reference to the bordereaux batch submission header under which this line was transmitted to the reinsurer.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Reinsurance bordereaux reporting requires peril-level detail for treaty attachment point calculations and loss allocation.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the specific coverage-level exposure within the claim that drives this bordereaux line.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim record from which this bordereaux line is derived.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this bordereaux line is reported for reinsurer settlement.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Reinsurance bordereaux reporting requires coverage-level cession detail per treaty terms.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Bordereaux lines report geographic distribution of ceded losses for reinsurance settlement and treaty compliance.',
    `reinsurance_cession_id` BIGINT COMMENT 'Reference to the reinsurance cession record that governs the ceded share reported on this bordereaux line.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the reinsurance agreement (treaty or facultative) under which the loss is ceded on this line.',
    `accident_year` BIGINT COMMENT 'Calendar year in which the loss event occurred, used as the primary cohort for actuarial development and reinsurance treaty year matching.',
    `bordereaux_period_code` STRING COMMENT 'Coded reporting period (e.g., 2024-Q1 or 2024-M03) for which this bordereaux line is submitted to the reinsurer for settlement.. Valid values are `^[0-9]{4}-(Q[1-4]|M(0[1-9]|1[0-2]))$`',
    `bordereaux_type` STRING COMMENT 'Indicates whether this bordereaux line is a loss bordereaux, premium bordereaux, or combined bordereaux submission.. Valid values are `LOSS|PREMIUM|COMBINED`',
    `catastrophe_flag` BOOLEAN COMMENT 'Indicates whether the underlying loss event is designated as a catastrophe, triggering CAT XL treaty layers and separate bordereaux reporting.',
    `catastrophe_number` STRING COMMENT 'Industry-standard catastrophe serial number (e.g., ISO PCS CAT number) assigned to the loss event, used to aggregate CAT bordereaux lines.',
    `ceded_alae_amount` DECIMAL(18,2) COMMENT 'Reinsurers share of allocated loss adjustment expenses (defense, investigation costs) directly attributable to this claim exposure.',
    `ceded_case_reserve_amount` DECIMAL(18,2) COMMENT 'Reinsurers share of the outstanding case reserve for this claim exposure, representing the ceded portion of estimated future loss payments.',
    `ceded_lae_amount` DECIMAL(18,2) COMMENT 'Portion of loss adjustment expense ceded to the reinsurer under this agreement, recoverable alongside the ceded loss amount.',
    `ceded_loss_amount` DECIMAL(18,2) COMMENT 'Portion of the incurred loss ceded to the reinsurer under the applicable agreement for this bordereaux line, net of retention.',
    `ceded_paid_loss_amount` DECIMAL(18,2) COMMENT 'Portion of actual loss payments made to claimants that is recoverable from the reinsurer under this cession as of the evaluation date.',
    `cession_pct` DECIMAL(7,4) COMMENT 'Percentage of the gross loss ceded to the reinsurer under this agreement, expressed as a decimal (e.g., 0.7500 = 75%). Applies to quota share treaties.',
    `company_code` STRING COMMENT 'Internal legal entity or writing company code identifying the cedant entity responsible for this cession, for multi-company group reporting.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this bordereaux line record was first created in the data platform, used for audit trail and data lineage.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this bordereaux line (e.g., USD, GBP, EUR).. Valid values are `^[A-Z]{3}$`',
    `dispute_reason` STRING COMMENT 'Free-text or coded reason provided when the reinsurer disputes this bordereaux line, capturing the basis for the disagreement for resolution tracking.',
    `evaluation_date` DATE COMMENT 'As-of date for the financial values (reserves, payments) reported on this bordereaux line, enabling point-in-time reinsurer reconciliation.',
    `gross_incurred_loss_amount` DECIMAL(18,2) COMMENT 'Total gross incurred loss (paid plus case reserve) for this claim exposure before reinsurance, as of the evaluation date.',
    `gross_lae_amount` DECIMAL(18,2) COMMENT 'Total gross loss adjustment expense (ALAE + ULAE) incurred on this claim exposure before reinsurance, as of the evaluation date.',
    `line_number` BIGINT COMMENT 'Sequential line number within the bordereaux submission identifying the position of this claim entry in the batch.',
    `line_status` STRING COMMENT 'Current processing status of this bordereaux line in the reinsurer settlement workflow. [ENUM-REF-CANDIDATE: DRAFT|SUBMITTED|ACKNOWLEDGED|DISPUTED|SETTLED|VOIDED|AMENDED — promote to reference product]. Valid values are `DRAFT|SUBMITTED|ACKNOWLEDGED|DISPUTED|SETTLED|VOIDED`',
    `lob_code` STRING COMMENT 'NAIC line of business code classifying the underlying policy (e.g., HO, PAP, CGL, CA) for reinsurer reporting and treaty allocation.',
    `loss_date` DATE COMMENT 'Date of the underlying loss event (accident year anchor), used to determine which reinsurance treaty year applies to this cession.',
    `loss_development_amount` DECIMAL(18,2) COMMENT 'Change in ceded incurred loss between the current and prior bordereaux period for this claim line, representing adverse or favorable development.',
    `policy_number` STRING COMMENT 'Policy number of the underlying insured policy to which the claim and cession relate, as reported on the bordereaux.',
    `policy_year` BIGINT COMMENT 'Year in which the underlying policy was incepted, used for policy-year loss development and reinsurance treaty year determination.',
    `prior_period_ceded_loss_amount` DECIMAL(18,2) COMMENT 'Ceded loss amount reported on the immediately preceding bordereaux period for this claim line, enabling period-over-period development tracking.',
    `recovery_status` STRING COMMENT 'Status of the reinsurance recovery for this ceded claim line, indicating whether amounts have been collected, are outstanding, or are in dispute.. Valid values are `OPEN|COLLECTED|PARTIAL|DISPUTED|WRITTEN_OFF`',
    `report_date` DATE COMMENT 'Date the claim was first reported (FNOL date), used for claims-made policy triggers and reinsurance reporting lag analysis.',
    `ri_agreement_type` STRING COMMENT 'Indicates whether the reinsurance arrangement is a treaty (automatic) or facultative (individually negotiated) agreement.. Valid values are `TREATY|FACULTATIVE`',
    `ri_collected_amount` DECIMAL(18,2) COMMENT 'Amount actually received from the reinsurer against this bordereaux line to date, used to compute the outstanding reinsurance receivable.',
    `ri_limit_amount` DECIMAL(18,2) COMMENT 'Maximum reinsurance recovery available under the applicable treaty layer or facultative certificate for this claim exposure.',
    `ri_recoverable_amount` DECIMAL(18,2) COMMENT 'Total amount recoverable from the reinsurer on this line (ceded loss plus ceded LAE), representing the gross reinsurance asset on the balance sheet.',
    `ri_retention_amount` DECIMAL(18,2) COMMENT 'Dollar amount of the loss retained by the cedant (self-insured retention or treaty retention layer) before reinsurance recovery applies.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record (e.g., GUIDEWIRE_CC, SAPIENS_RI) from which this bordereaux line was extracted.',
    `submission_date` DATE COMMENT 'Date this bordereaux line was transmitted to the reinsurer as part of the settlement batch.',
    `treaty_type` STRING COMMENT 'Classification of the treaty structure: Quota Share (QS), Excess of Loss (XOL), Stop Loss (SL), Catastrophe XL (CAT XL), or Aggregate. [ENUM-REF-CANDIDATE: QS|XOL|SL|CAT_XL|AGGREGATE|RETRO — promote to reference product]. Valid values are `QS|XOL|SL|CAT_XL|AGGREGATE`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this bordereaux line record, supporting audit trail and change detection in the Silver layer.',
    CONSTRAINT pk_claimfinancials_bordereaux_line PRIMARY KEY(`claimfinancials_bordereaux_line_id`)
) COMMENT 'One row per claim line in a reinsurance bordereaux submission. Captures claim reference, ceded loss, ceded LAE, recovery status, treaty or facultative reference, and reporting period for reinsurer settlement.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_original_payment_claim_payment_id` FOREIGN KEY (`original_payment_claim_payment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment`(`claim_payment_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_claim_payment_id` FOREIGN KEY (`claim_payment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment`(`claim_payment_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_salvage_id` FOREIGN KEY (`salvage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage`(`salvage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_subrogation_id` FOREIGN KEY (`subrogation_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation`(`subrogation_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_vendor_payee_id` FOREIGN KEY (`vendor_payee_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee`(`payee_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_original_expense_claim_expense_id` FOREIGN KEY (`original_expense_claim_expense_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense`(`claim_expense_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_payee_id` FOREIGN KEY (`payee_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee`(`payee_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_financial_transaction_id` FOREIGN KEY (`financial_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction`(`financial_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ADD CONSTRAINT `fk_claimfinancials_loss_triangle_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ADD CONSTRAINT `fk_claimfinancials_ibnr_estimate_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ADD CONSTRAINT `fk_claimfinancials_claimfinancials_accounting_period_prior_period_claimfinancials_accounting_period_id` FOREIGN KEY (`prior_period_claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_original_transaction_financial_transaction_id` FOREIGN KEY (`original_transaction_financial_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction`(`financial_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_salvage_id` FOREIGN KEY (`salvage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage`(`salvage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ADD CONSTRAINT `fk_claimfinancials_claim_financial_snapshot_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ADD CONSTRAINT `fk_claimfinancials_lae_allocation_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ADD CONSTRAINT `fk_claimfinancials_lae_allocation_original_allocation_lae_allocation_id` FOREIGN KEY (`original_allocation_lae_allocation_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation`(`lae_allocation_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ADD CONSTRAINT `fk_claimfinancials_statutory_reserve_filing_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ADD CONSTRAINT `fk_claimfinancials_statutory_reserve_filing_original_filing_statutory_reserve_filing_id` FOREIGN KEY (`original_filing_statutory_reserve_filing_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing`(`statutory_reserve_filing_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ADD CONSTRAINT `fk_claimfinancials_claimfinancials_bordereaux_line_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`claimfinancials` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`claimfinancials` SET TAGS ('dbx_domain' = 'claimfinancials');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` SET TAGS ('dbx_subdomain' = 'financial_movements');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `reserve_id` SET TAGS ('dbx_business_glossary_term' = 'Reserve ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `approved_by_party_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `riskexposure_insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `underwriting_loss_history_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Loss History Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ALTER COLUMN `underwriting_risk_score_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Risk Score Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` SET TAGS ('dbx_subdomain' = 'financial_movements');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `claim_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Payment ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `original_payment_claim_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Original Payment ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Authorized By User ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `party_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `party_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `payee_party_id` SET TAGS ('dbx_business_glossary_term' = 'Payee Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `riskexposure_insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `underwriting_loss_history_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Loss History Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `payee_name` SET TAGS ('dbx_business_glossary_term' = 'Payee Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `payee_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `payee_name` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `payee_tax_number` SET TAGS ('dbx_business_glossary_term' = 'Payee Tax Identification Number (TIN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `payee_tax_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ALTER COLUMN `payee_tax_number` SET TAGS ('dbx_pii_identifier' = 'true');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` SET TAGS ('dbx_subdomain' = 'financial_movements');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `recovery_id` SET TAGS ('dbx_business_glossary_term' = 'Recovery ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `attorney_organization_id` SET TAGS ('dbx_business_glossary_term' = 'Attorney Organization Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `claim_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Offset Claim Payment ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Cession ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `responsible_party_id` SET TAGS ('dbx_business_glossary_term' = 'Responsible Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ALTER COLUMN `riskexposure_property_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Property Risk Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `attorney_organization_id` SET TAGS ('dbx_business_glossary_term' = 'Attorney Organization Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `liable_party_id` SET TAGS ('dbx_business_glossary_term' = 'Liable Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `riskexposure_auto_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Auto Risk Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `reinsurance_recovery_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recovery Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `reinsurance_recovery_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ALTER COLUMN `reinsurance_recovery_amount` SET TAGS ('dbx_pii_financial' = 'true');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk ID');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `buyer_name` SET TAGS ('dbx_business_glossary_term' = 'Salvage Buyer Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `buyer_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `buyer_type` SET TAGS ('dbx_business_glossary_term' = 'Salvage Buyer Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `buyer_type` SET TAGS ('dbx_value_regex' = 'dealer|individual|insurer|scrap_yard|auction_house');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `catastrophe_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Code');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` SET TAGS ('dbx_subdomain' = 'financial_movements');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `claim_expense_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Expense ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `approved_by_party_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `original_expense_claim_expense_id` SET TAGS ('dbx_business_glossary_term' = 'Original Expense Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `payee_id` SET TAGS ('dbx_business_glossary_term' = 'Vendor ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `riskexposure_insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ALTER COLUMN `financial_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Source System Transaction ID');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` SET TAGS ('dbx_subdomain' = 'actuarial_analysis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `loss_triangle_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Triangle ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `loss_approved_by_party_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `loss_party_id` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Analyst ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `accident_half_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Half-Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `accident_half_year` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(H1|H2)$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `case_alae_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Case Allocated Loss Adjustment Expense (ALAE) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `case_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Case Reserve Amount (Outstanding Loss Reserve)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `catastrophe_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Loss Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `claim_count_closed` SET TAGS ('dbx_business_glossary_term' = 'Closed Claim Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `claim_count_open` SET TAGS ('dbx_business_glossary_term' = 'Open Claim Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `claim_count_reported` SET TAGS ('dbx_business_glossary_term' = 'Reported Claim Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `cohort_type` SET TAGS ('dbx_business_glossary_term' = 'Cohort Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `cohort_type` SET TAGS ('dbx_value_regex' = 'accident_year|policy_year|calendar_year|report_year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `cohort_year` SET TAGS ('dbx_business_glossary_term' = 'Cohort Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `company_code` SET TAGS ('dbx_business_glossary_term' = 'NAIC Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `development_factor` SET TAGS ('dbx_business_glossary_term' = 'Age-to-Age Loss Development Factor (LDF)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `development_period` SET TAGS ('dbx_business_glossary_term' = 'Development Period (Months)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `earned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `evaluation_date` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `gross_net_indicator` SET TAGS ('dbx_business_glossary_term' = 'Gross/Net of Reinsurance Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `gross_net_indicator` SET TAGS ('dbx_value_regex' = 'gross|net_of_reinsurance|ceded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `group_code` SET TAGS ('dbx_business_glossary_term' = 'NAIC Group Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `ibnr_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred But Not Reported (IBNR) Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `ibnr_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred But Not Reported (IBNR) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `incurred_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `is_diagonal` SET TAGS ('dbx_business_glossary_term' = 'Is Latest Diagonal Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `is_tail_period` SET TAGS ('dbx_business_glossary_term' = 'Is Tail Period Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `lob_name` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `lob_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `paid_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `paid_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `prior_period_ultimate_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Period Ultimate Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `reinsurance_program_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Program Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `reinsurance_program_type` SET TAGS ('dbx_value_regex' = 'gross|quota_share|excess_of_loss|stop_loss|facultative');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `reserve_development_amount` SET TAGS ('dbx_business_glossary_term' = 'Reserve Development Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `reserving_method` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Reserving Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `reserving_method` SET TAGS ('dbx_value_regex' = 'chain_ladder|bornhuetter_ferguson|cape_cod|frequency_severity|clark_ldf|benktander');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `tail_factor` SET TAGS ('dbx_business_glossary_term' = 'Tail Development Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `triangle_run_number` SET TAGS ('dbx_business_glossary_term' = 'Triangle Run ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `triangle_status` SET TAGS ('dbx_business_glossary_term' = 'Triangle Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `triangle_status` SET TAGS ('dbx_value_regex' = 'draft|reviewed|approved|published|superseded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `triangle_type` SET TAGS ('dbx_business_glossary_term' = 'Triangle Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `ultimate_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `ultimate_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Net Loss (UNL) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ALTER COLUMN `written_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Written Premium (WP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` SET TAGS ('dbx_subdomain' = 'actuarial_analysis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `ibnr_estimate_id` SET TAGS ('dbx_business_glossary_term' = 'Incurred But Not Reported (IBNR) Estimate ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `actuary_party_id` SET TAGS ('dbx_business_glossary_term' = 'Signing Actuary Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `underwriting_risk_score_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Risk Score Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `actuarial_notes` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `actuarial_run_number` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Run ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `actuarial_run_number` SET TAGS ('dbx_value_regex' = '^RUN-[0-9]{8}-[A-Z0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `actuary_signoff_date` SET TAGS ('dbx_business_glossary_term' = 'Actuary Sign-Off Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `age_to_age_factor` SET TAGS ('dbx_business_glossary_term' = 'Age-to-Age Loss Development Factor (LDF)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `age_to_age_factor` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `case_reserve_amt` SET TAGS ('dbx_business_glossary_term' = 'Case Reserve Amount (OSLR)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `case_reserve_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `claim_count_reported` SET TAGS ('dbx_business_glossary_term' = 'Reported Claim Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `claim_count_ultimate` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Claim Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `committee_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Reserve Committee Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `company_code` SET TAGS ('dbx_business_glossary_term' = 'NAIC Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Reserve Confidence Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `cumulative_ldf` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Loss Development Factor (LDF) to Ultimate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `data_source_system` SET TAGS ('dbx_value_regex' = 'reserving_system|data_warehouse|actuarial_workbench|manual');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `development_method` SET TAGS ('dbx_business_glossary_term' = 'Loss Development Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `earned_premium_amt` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `earned_premium_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `estimate_number` SET TAGS ('dbx_business_glossary_term' = 'IBNR Estimate Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `estimate_number` SET TAGS ('dbx_value_regex' = '^IBNR-[0-9]{4}-[0-9]{2}-[A-Z0-9]{4,20}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `estimate_status` SET TAGS ('dbx_business_glossary_term' = 'IBNR Estimate Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `estimate_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|superseded|archived');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `estimate_type` SET TAGS ('dbx_business_glossary_term' = 'Reserve Estimate Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `estimate_type` SET TAGS ('dbx_value_regex' = 'IBNR|IBNER|total_IBNR|LAE_IBNR');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `expected_loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Expected Loss Ratio (ELR)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `high_estimate_amt` SET TAGS ('dbx_business_glossary_term' = 'High IBNR Estimate Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `high_estimate_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `ibner_amt` SET TAGS ('dbx_business_glossary_term' = 'Incurred But Not Enough Reported (IBNER) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `ibner_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `ibnr_amt` SET TAGS ('dbx_business_glossary_term' = 'Incurred But Not Reported (IBNR) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `ibnr_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `ibnr_claim_count` SET TAGS ('dbx_business_glossary_term' = 'IBNR Claim Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `is_cat_included` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Losses Included Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `is_reinsurance_net` SET TAGS ('dbx_business_glossary_term' = 'Net of Reinsurance Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `lae_ibnr_amt` SET TAGS ('dbx_business_glossary_term' = 'Loss Adjustment Expense (LAE) IBNR Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `lae_ibnr_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `lob_description` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `low_estimate_amt` SET TAGS ('dbx_business_glossary_term' = 'Low IBNR Estimate Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `low_estimate_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `paid_losses_amt` SET TAGS ('dbx_business_glossary_term' = 'Paid Losses Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `paid_losses_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `percent_developed` SET TAGS ('dbx_business_glossary_term' = 'Percent of Ultimate Developed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `prior_ibnr_amt` SET TAGS ('dbx_business_glossary_term' = 'Prior Period IBNR Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `prior_ibnr_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `reported_losses_amt` SET TAGS ('dbx_business_glossary_term' = 'Reported Losses Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `reported_losses_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `reserve_change_amt` SET TAGS ('dbx_business_glossary_term' = 'Reserve Development Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `reserve_change_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `reserving_basis` SET TAGS ('dbx_business_glossary_term' = 'Reserving Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `reserving_basis` SET TAGS ('dbx_value_regex' = 'SAP|GAAP|IFRS17|management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `tail_factor` SET TAGS ('dbx_business_glossary_term' = 'Tail Development Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `triangle_maturity_months` SET TAGS ('dbx_business_glossary_term' = 'Triangle Maturity in Months');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `ulr` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Loss Ratio (ULR)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `ultimate_loss_amt` SET TAGS ('dbx_business_glossary_term' = 'Selected Ultimate Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `ultimate_loss_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` SET TAGS ('dbx_subdomain' = 'financial_movements');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `prior_period_claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `bordereaux_period_code` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Bordereaux Period Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `calendar_year` SET TAGS ('dbx_business_glossary_term' = 'Calendar Year (CY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `close_date` SET TAGS ('dbx_business_glossary_term' = 'Period Close Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Period End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `fiscal_month` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Month');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `fiscal_quarter` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Quarter');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `fx_rate_to_usd` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate to USD');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `gl_period_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Period Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `ifrs17_reporting_period` SET TAGS ('dbx_business_glossary_term' = 'IFRS 17 Reporting Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `is_quarter_end` SET TAGS ('dbx_business_glossary_term' = 'Quarter-End Period Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `is_stub_period` SET TAGS ('dbx_business_glossary_term' = 'Stub Period Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `is_year_end` SET TAGS ('dbx_business_glossary_term' = 'Year-End Period Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `lock_date` SET TAGS ('dbx_business_glossary_term' = 'Period Lock Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `loss_development_lag` SET TAGS ('dbx_business_glossary_term' = 'Loss Development Lag (Months)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `naic_statement_period` SET TAGS ('dbx_business_glossary_term' = 'NAIC Statement Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `naic_statement_period` SET TAGS ('dbx_value_regex' = 'Q1|Q2|Q3|ANNUAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `period_basis` SET TAGS ('dbx_business_glossary_term' = 'Period Basis (CY/AY/PY/FY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `period_basis` SET TAGS ('dbx_value_regex' = 'CY|AY|PY|FY');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `period_code` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `period_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,4}-[0-9]{4}-[0-9]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `period_days` SET TAGS ('dbx_business_glossary_term' = 'Period Days Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `period_name` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `period_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `period_status` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `period_status` SET TAGS ('dbx_value_regex' = 'OPEN|CLOSED|LOCKED|REOPENED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `period_type` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `period_type` SET TAGS ('dbx_value_regex' = 'MONTHLY|QUARTERLY|ANNUAL|SEMI_ANNUAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `premium_earning_method` SET TAGS ('dbx_business_glossary_term' = 'Premium Earning Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `premium_earning_method` SET TAGS ('dbx_value_regex' = 'PRO_RATA|RULE_OF_78|DAILY|MONTHLY');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `reopen_date` SET TAGS ('dbx_business_glossary_term' = 'Period Reopen Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `reporting_framework` SET TAGS ('dbx_business_glossary_term' = 'Reporting Framework');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `reporting_framework` SET TAGS ('dbx_value_regex' = 'SAP|GAAP|IFRS17|STATUTORY');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `schedule_p_period_label` SET TAGS ('dbx_business_glossary_term' = 'Schedule P Period Label');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Period Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` SET TAGS ('dbx_subdomain' = 'financial_movements');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `financial_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Financial Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `original_transaction_financial_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Original Financial Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Authorized By User ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `payment_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Payment ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement ID');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `reinsurer_party_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Agreement ID');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `days_overdue` SET TAGS ('dbx_business_glossary_term' = 'Days Overdue');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `disputed_amount` SET TAGS ('dbx_business_glossary_term' = 'Disputed Recovery Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` SET TAGS ('dbx_subdomain' = 'financial_movements');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `claim_financial_snapshot_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Financial Snapshot ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `riskexposure_insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `case_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Case Reserve Amount (OSLR)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `catastrophe_indicator` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `ceded_ibnr_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Incurred But Not Reported (IBNR) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `ceded_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Paid Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `ceded_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `claim_status` SET TAGS ('dbx_business_glossary_term' = 'Claim Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `claim_status` SET TAGS ('dbx_value_regex' = 'open|closed|reopened|pending|denied|litigated');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `coverage_type_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `development_period` SET TAGS ('dbx_business_glossary_term' = 'Development Period (Months)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `ibnr_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred But Not Reported (IBNR) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `lae_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Loss Adjustment Expense (LAE) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `net_incurred_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Incurred Amount (NWP Basis)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `net_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `paid_lae_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Loss Adjustment Expense (LAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `paid_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `policy_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Policy Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `prior_period_incurred_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Period Total Incurred Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `prior_period_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Period Paid Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `report_year` SET TAGS ('dbx_business_glossary_term' = 'Report Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `reserve_basis` SET TAGS ('dbx_business_glossary_term' = 'Reserve Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `reserve_basis` SET TAGS ('dbx_value_regex' = 'case|ibnr|lae|ulae|bulk');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `reserve_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Reserve Change Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `salvage_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Salvage Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `sir_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `snapshot_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Snapshot Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `snapshot_status` SET TAGS ('dbx_business_glossary_term' = 'Snapshot Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `snapshot_status` SET TAGS ('dbx_value_regex' = 'open|closed|reopened|voided|superseded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `snapshot_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Snapshot Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `subrogation_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `total_incurred_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Incurred Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `total_incurred_lae_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Incurred Loss Adjustment Expense (LAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `total_recovery_collected_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Recovery Collected Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `ulae_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Unallocated Loss Adjustment Expense (ULAE) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` SET TAGS ('dbx_subdomain' = 'actuarial_analysis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `lae_allocation_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Adjustment Expense (LAE) Allocation ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `original_allocation_lae_allocation_id` SET TAGS ('dbx_business_glossary_term' = 'Original LAE Allocation ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `actuarial_review_flag` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Review Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `allocated_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `allocated_ulae_amount` SET TAGS ('dbx_business_glossary_term' = 'Allocated Unallocated Loss Adjustment Expense (ULAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `allocation_basis_amount` SET TAGS ('dbx_business_glossary_term' = 'ULAE Allocation Basis Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `allocation_basis_code` SET TAGS ('dbx_business_glossary_term' = 'ULAE Allocation Basis Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `allocation_basis_code` SET TAGS ('dbx_value_regex' = 'PAID_LOSS|INCURRED_LOSS|CLAIM_COUNT|EXPOSURE_UNIT|EARNED_PREMIUM');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `allocation_method_code` SET TAGS ('dbx_business_glossary_term' = 'ULAE Allocation Method Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `allocation_method_code` SET TAGS ('dbx_value_regex' = 'PAID_TO_PAID|KITTEL|BORNHUETTER_FERGUSON|DEVELOPMENT|BUDGETED|OTHER');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `allocation_method_name` SET TAGS ('dbx_business_glossary_term' = 'ULAE Allocation Method Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `allocation_method_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `allocation_number` SET TAGS ('dbx_business_glossary_term' = 'LAE Allocation Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `allocation_run_date` SET TAGS ('dbx_business_glossary_term' = 'ULAE Allocation Run Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `allocation_run_number` SET TAGS ('dbx_business_glossary_term' = 'ULAE Allocation Run ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `allocation_status` SET TAGS ('dbx_business_glossary_term' = 'LAE Allocation Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `allocation_status` SET TAGS ('dbx_value_regex' = 'draft|posted|reversed|adjusted|voided');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `allocation_weight` SET TAGS ('dbx_business_glossary_term' = 'ULAE Allocation Weight');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `allocation_weight` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `calendar_year` SET TAGS ('dbx_business_glossary_term' = 'Calendar Year (CY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `company_code` SET TAGS ('dbx_business_glossary_term' = 'Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `evaluation_date` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `gross_net_indicator` SET TAGS ('dbx_business_glossary_term' = 'Gross/Net/Ceded Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `gross_net_indicator` SET TAGS ('dbx_value_regex' = 'GROSS|NET|CEDED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `lae_type_code` SET TAGS ('dbx_business_glossary_term' = 'Loss Adjustment Expense (LAE) Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `lae_type_code` SET TAGS ('dbx_value_regex' = 'ULAE|ALAE|DCC|AO');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Allocation Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `posted_date` SET TAGS ('dbx_business_glossary_term' = 'GL Posted Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `reinsurance_net_indicator` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Net Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `reversal_indicator` SET TAGS ('dbx_business_glossary_term' = 'Reversal Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `total_lae_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Loss Adjustment Expense (LAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `total_pool_basis_amount` SET TAGS ('dbx_business_glossary_term' = 'Total ULAE Pool Basis Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `total_pool_ulae_amount` SET TAGS ('dbx_business_glossary_term' = 'Total ULAE Pool Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Allocation Transaction Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` SET TAGS ('dbx_subdomain' = 'recovery_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `payee_id` SET TAGS ('dbx_business_glossary_term' = 'Payee ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` SET TAGS ('dbx_subdomain' = 'actuarial_analysis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `statutory_reserve_filing_id` SET TAGS ('dbx_business_glossary_term' = 'Statutory Reserve Filing ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `actuary_party_id` SET TAGS ('dbx_business_glossary_term' = 'Actuary Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `coverage_type_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `original_filing_statutory_reserve_filing_id` SET TAGS ('dbx_business_glossary_term' = 'Original Filing ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `actuary_certification_date` SET TAGS ('dbx_business_glossary_term' = 'Actuary Certification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `actuary_credential` SET TAGS ('dbx_business_glossary_term' = 'Actuary Credential');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `actuary_credential` SET TAGS ('dbx_value_regex' = 'FCAS|ACAS|MAAA|FSA|ASA');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `actuary_credential` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `amended_filing_indicator` SET TAGS ('dbx_business_glossary_term' = 'Amended Filing Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `case_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Case Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `case_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `catastrophe_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `claim_count_open` SET TAGS ('dbx_business_glossary_term' = 'Open Claim Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `claim_count_reported` SET TAGS ('dbx_business_glossary_term' = 'Reported Claim Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `company_name` SET TAGS ('dbx_business_glossary_term' = 'Company Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `company_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `earned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `earned_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `evaluation_date` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `filing_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `filing_number` SET TAGS ('dbx_business_glossary_term' = 'Filing Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Filing Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `filing_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|accepted|rejected|amended|superseded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `filing_type` SET TAGS ('dbx_business_glossary_term' = 'Filing Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `filing_type` SET TAGS ('dbx_value_regex' = 'annual|quarterly|amended|supplemental');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `gross_net_indicator` SET TAGS ('dbx_business_glossary_term' = 'Gross/Net of Reinsurance Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `gross_net_indicator` SET TAGS ('dbx_value_regex' = 'gross|net_of_reinsurance|ceded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `ibnr_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred But Not Reported (IBNR) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `ibnr_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `incurred_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Incurred Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `incurred_loss_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `lae_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Loss Adjustment Expense (LAE) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `lae_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `lob_name` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `lob_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'NAIC Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `naic_statement_period` SET TAGS ('dbx_business_glossary_term' = 'NAIC Statement Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `naic_statement_period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(Q1|Q2|Q3|Q4|YE)$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `paid_lae_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Loss Adjustment Expense (LAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `paid_lae_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `paid_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `paid_loss_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `prior_year_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Year Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `prior_year_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `rbc_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Risk-Based Capital (RBC) Reserve Impact Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `rbc_impact_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `regulatory_due_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `reporting_basis` SET TAGS ('dbx_business_glossary_term' = 'Reporting Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `reporting_basis` SET TAGS ('dbx_value_regex' = 'SAP|GAAP|IFRS17');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `reserve_adequacy_opinion` SET TAGS ('dbx_business_glossary_term' = 'Reserve Adequacy Opinion');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `reserve_adequacy_opinion` SET TAGS ('dbx_value_regex' = 'adequate|inadequate|reasonable|qualified|adverse');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `reserve_development_amount` SET TAGS ('dbx_business_glossary_term' = 'Reserve Development Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `reserve_development_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `reserving_method` SET TAGS ('dbx_business_glossary_term' = 'Reserving Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `schedule_p_line` SET TAGS ('dbx_business_glossary_term' = 'Schedule P Line');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `total_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `total_reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `ultimate_loss_estimate` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Loss Estimate (ULR Basis)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `ultimate_loss_estimate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` SET TAGS ('dbx_subdomain' = 'recovery_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `claimfinancials_bordereaux_line_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Financials Bordereaux Line ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `bordereaux_id` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Submission ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `bordereaux_period_code` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Reporting Period Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `bordereaux_period_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(Q[1-4]|M(0[1-9]|1[0-2]))$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `bordereaux_type` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `bordereaux_type` SET TAGS ('dbx_value_regex' = 'LOSS|PREMIUM|COMBINED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `catastrophe_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `catastrophe_number` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `ceded_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `ceded_case_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Case Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `ceded_lae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Adjustment Expense (LAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `ceded_paid_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Paid Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `cession_pct` SET TAGS ('dbx_business_glossary_term' = 'Cession Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `company_code` SET TAGS ('dbx_business_glossary_term' = 'Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Dispute Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `evaluation_date` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `gross_incurred_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Incurred Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `gross_lae_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Loss Adjustment Expense (LAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `line_number` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Line Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `line_status` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Line Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `line_status` SET TAGS ('dbx_value_regex' = 'DRAFT|SUBMITTED|ACKNOWLEDGED|DISPUTED|SETTLED|VOIDED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `loss_date` SET TAGS ('dbx_business_glossary_term' = 'Loss Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `loss_development_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Development Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `policy_number` SET TAGS ('dbx_business_glossary_term' = 'Policy Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `prior_period_ceded_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Period Ceded Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `recovery_status` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recovery Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `recovery_status` SET TAGS ('dbx_value_regex' = 'OPEN|COLLECTED|PARTIAL|DISPUTED|WRITTEN_OFF');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `report_date` SET TAGS ('dbx_business_glossary_term' = 'Claim Report Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `ri_agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Agreement Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `ri_agreement_type` SET TAGS ('dbx_value_regex' = 'TREATY|FACULTATIVE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `ri_collected_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Collected Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `ri_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `ri_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `ri_retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Retention Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Submission Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `treaty_type` SET TAGS ('dbx_business_glossary_term' = 'Treaty Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `treaty_type` SET TAGS ('dbx_value_regex' = 'QS|XOL|SL|CAT_XL|AGGREGATE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
