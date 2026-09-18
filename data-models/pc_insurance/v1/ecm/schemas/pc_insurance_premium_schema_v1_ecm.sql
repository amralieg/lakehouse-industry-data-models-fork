-- Schema for Domain: premium | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-18 02:30:18

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_v499`.`premium` COMMENT 'SSOT for premium transactions: GWP, NWP, WP, EP, UEP, DAC, and billing. Owns rate calculations (RPP, ROL), installment schedules, payment applications, and billing events. Links rated risk exposures and premium back to the bound policy.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` (
    `written_premium_id` BIGINT COMMENT 'Unique identifier for the written premium transaction record.',
    `agency_id` BIGINT COMMENT 'Reference to the agency responsible for this written premium transaction.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Premium accounting requires calendar reference for fiscal period determination, month-end close processing, statutory reporting deadlines, and financial statement preparation.',
    `claim_id` BIGINT COMMENT 'Foreign key linking to claims.claim. Business justification: Audit premium adjustments and return premium on total loss claims require tracking which claim triggered the premium write-off.',
    `country_id` BIGINT COMMENT 'Foreign key linking to shared.country. Business justification: International premium transactions require country reference for currency determination, regulatory regime identification, reinsurance domicile rules, and sanctions compliance.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Premium transactions in multiple currencies require currency master reference for exchange rate application, rounding rules, display formatting, and financial consolidation.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Premium transactions must link to LOB master for statutory line classification, RBC factor application, loss ratio analysis, reinsurance treaty assignment, and regulatory reporting.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Reference to the specific coverage for which premium was written, if applicable at coverage level.',
    `policy_id` BIGINT COMMENT 'Reference to the policy for which this premium was written.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer, agent, or broker who originated this written premium transaction.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Premium transactions require state reference for regulatory reporting, rate filing compliance, statutory accounting by jurisdiction, and premium tax calculation.',
    `ceded_premium_amount` DECIMAL(18,2) COMMENT 'Portion of gross written premium ceded to reinsurers under treaty or facultative agreements.',
    `commission_amount` DECIMAL(18,2) COMMENT 'Total commission payable to producers, agents, or brokers for this written premium transaction.',
    `commission_rate` DECIMAL(5,4) COMMENT 'Commission percentage applied to the written premium to calculate commission amount.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this written premium record was first created in the system.',
    `experience_mod_factor` DECIMAL(5,4) COMMENT 'Experience modification factor applied to manual premium based on the insureds historical loss experience.',
    `exposure_basis` STRING COMMENT 'Unit of measure for exposure, such as per $100 payroll, per vehicle, per square foot, or per $1000 insured value.',
    `exposure_units` DECIMAL(18,4) COMMENT 'Quantity of exposure units used in premium calculation, such as payroll, vehicle count, or square footage.',
    `gwp_amount` DECIMAL(18,2) COMMENT 'Total premium written before any deductions for reinsurance or commissions.',
    `installment_count` BIGINT COMMENT 'Total number of installments in the payment plan for this written premium, if applicable.',
    `installment_fee_amount` DECIMAL(18,2) COMMENT 'Fee charged for installment payment plans, if applicable to this premium transaction.',
    `is_audit_premium` BOOLEAN COMMENT 'Indicates whether this written premium transaction resulted from a policy audit adjustment.',
    `is_installment_plan` BOOLEAN COMMENT 'Indicates whether this written premium is part of an installment payment plan.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this written premium record was last updated or modified.',
    `manual_premium_amount` DECIMAL(18,2) COMMENT 'Premium calculated using standard manual rates before application of experience modifications or schedule credits.',
    `nwp_amount` DECIMAL(18,2) COMMENT 'Net premium retained after ceding to reinsurers; calculated as GWP minus ceded premium.',
    `policy_fee_amount` DECIMAL(18,2) COMMENT 'Administrative or policy issuance fee charged in addition to premium.',
    `policy_term_effective_date` DATE COMMENT 'Start date of the policy term to which this written premium applies.',
    `policy_term_expiration_date` DATE COMMENT 'End date of the policy term to which this written premium applies.',
    `premium_basis_amount` DECIMAL(18,2) COMMENT 'Base amount used in premium calculation before application of rates, modifiers, and adjustments.',
    `premium_tax_amount` DECIMAL(18,2) COMMENT 'State or local premium tax assessed on this written premium transaction.',
    `product_code` STRING COMMENT 'Internal product code identifying the specific insurance product for this written premium.',
    `rate_effective_date` DATE COMMENT 'Date when the rating plan or rate table became effective for use in premium calculations.',
    `rate_version` STRING COMMENT 'Version identifier of the rating plan or rate table used for this premium calculation.',
    `rating_plan_code` STRING COMMENT 'Code identifying the rating plan or algorithm used to calculate this written premium.',
    `reversal_reason_code` STRING COMMENT 'Code indicating the reason for reversing or voiding this written premium transaction, if applicable.',
    `schedule_credit_amount` DECIMAL(18,2) COMMENT 'Credit applied to premium for favorable risk characteristics identified during underwriting.',
    `schedule_debit_amount` DECIMAL(18,2) COMMENT 'Debit applied to premium for unfavorable risk characteristics identified during underwriting.',
    `statutory_reporting_period` STRING COMMENT 'Quarterly statutory reporting period in YYYY-Q# format for NAIC annual statement reporting.. Valid values are `^d{4}-Q[1-4]$`',
    `total_billed_amount` DECIMAL(18,2) COMMENT 'Total amount billed to the policyholder including premium, taxes, and fees.',
    `transaction_booking_date` DATE COMMENT 'Date when this premium transaction was recorded in the financial system.',
    `transaction_effective_date` DATE COMMENT 'Date when this premium transaction becomes effective for accounting and coverage purposes.',
    `transaction_type` STRING COMMENT 'Type of premium transaction: new business, renewal, endorsement, cancellation, reinstatement, or audit adjustment.. Valid values are `new_business|renewal|endorsement|cancellation|reinstatement|audit_adjustment`',
    `underwriter_code` BIGINT COMMENT 'Reference to the underwriter who approved the policy and premium for this transaction.',
    `written_premium_status` STRING COMMENT 'Current lifecycle status of this written premium transaction in the premium ledger.. Valid values are `booked|pending|reversed|adjusted|voided`',
    CONSTRAINT pk_written_premium PRIMARY KEY(`written_premium_id`)
) COMMENT 'SSOT for gross written premium (GWP) transactions per policy term. Captures WP, NWP, ceded premium, and net retained amounts at policy/coverage level. Anchors the premium ledger for statutory and GAAP reporting.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` (
    `earned_premium_id` BIGINT COMMENT 'Unique identifier for the earned premium transaction record.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Earned premium accounting requires calendar reference for fiscal period close, revenue recognition timing, and financial statement preparation. Accounting_period denormalized, replace with FK.',
    `claim_id` BIGINT COMMENT 'Foreign key linking to claims.claim. Business justification: Loss ratio analysis and profitability reporting require matching earned premium to incurred losses at the policy-coverage level.',
    `country_id` BIGINT COMMENT 'Foreign key linking to shared.country. Business justification: Cross-border earned premium must reference country for IFRS17 revenue recognition, regulatory jurisdiction determination, and reinsurance domicile rules.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Earned premium in multiple currencies requires currency reference for exchange rate application, GAAP/IFRS revenue recognition, and financial consolidation.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Earned premium accounting requires LOB reference for loss ratio analysis, combined ratio calculation, statutory line reporting, and reinsurance cession determination.',
    `original_earned_premium_id` BIGINT COMMENT 'Reference to the original earned premium record if this is a reversal or adjustment.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Reference to the specific coverage under which premium is earned.',
    `policy_id` BIGINT COMMENT 'Reference to the policy for which premium is being earned.',
    `premium_transaction_id` BIGINT COMMENT 'Unique identifier of the transaction in the source system.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Earned premium accounting requires state jurisdiction reference for statutory reporting periods, guaranty fund assessments, premium tax accrual, and regulatory compliance.',
    `adjustment_description` STRING COMMENT 'Detailed explanation of any adjustment made to the earned premium calculation.',
    `adjustment_reason_code` STRING COMMENT 'Code indicating the reason for any adjustment to the earned premium calculation.',
    `calculation_timestamp` TIMESTAMP COMMENT 'Date and time when the earned premium calculation was performed.',
    `ceded_ep_amount` DECIMAL(18,2) COMMENT 'Portion of earned premium ceded to reinsurers during this period.',
    `commission_amount` DECIMAL(18,2) COMMENT 'Commission expense allocated to this earned premium transaction.',
    `commission_rate` DECIMAL(5,2) COMMENT 'Commission rate percentage applied to earned premium for producer compensation.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this earned premium record was first created in the system.',
    `dac_amount` DECIMAL(18,2) COMMENT 'Deferred acquisition costs amortized in proportion to earned premium.',
    `earned_premium_status` STRING COMMENT 'Current processing status of the earned premium record.. Valid values are `draft|posted|reversed|adjusted|final`',
    `earning_method` STRING COMMENT 'Method used to calculate earned premium over the exposure period.. Valid values are `pro_rata|short_rate|daily|monthly|custom`',
    `earning_percentage` DECIMAL(5,2) COMMENT 'Percentage of total premium earned during this accounting period.',
    `effective_date` DATE COMMENT 'Start date of the earning period for this premium transaction.',
    `ep_amount` DECIMAL(18,2) COMMENT 'Amount of premium earned during the accounting period.',
    `exchange_rate` DECIMAL(12,6) COMMENT 'Exchange rate applied to convert foreign currency premium to reporting currency.',
    `expiration_date` DATE COMMENT 'End date of the earning period for this premium transaction.',
    `exposure_days` BIGINT COMMENT 'Number of days of exposure covered by this earned premium transaction.',
    `gaap_revenue_amount` DECIMAL(18,2) COMMENT 'Earned premium recognized as revenue under GAAP accounting standards.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this earned premium is posted.',
    `gwp_amount` DECIMAL(18,2) COMMENT 'Total premium written before reinsurance cessions for this earning record.',
    `ifrs17_revenue_amount` DECIMAL(18,2) COMMENT 'Earned premium recognized under IFRS 17 premium allocation approach.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code identifying the insurer earning the premium.. Valid values are `^[0-9]{5}$`',
    `net_ep_amount` DECIMAL(18,2) COMMENT 'Earned premium retained by the insurer after reinsurance cessions.',
    `nwp_amount` DECIMAL(18,2) COMMENT 'Written premium after reinsurance cessions for this earning record.',
    `policy_term_months` BIGINT COMMENT 'Total duration of the policy term in months for earning calculation.',
    `posting_date` DATE COMMENT 'Date when the earned premium was posted to the general ledger.',
    `premium_tax_amount` DECIMAL(18,2) COMMENT 'Premium tax expense allocated to this earned premium transaction.',
    `premium_tax_rate` DECIMAL(5,2) COMMENT 'State premium tax rate applied to earned premium.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether this earned premium entry is a reversal of a prior transaction.',
    `statutory_line_code` STRING COMMENT 'NAIC statutory line of business code for regulatory reporting.',
    `transaction_type` STRING COMMENT 'Type of policy transaction that generated this earned premium entry.. Valid values are `new_business|renewal|endorsement|cancellation|reinstatement|audit`',
    `uep_amount` DECIMAL(18,2) COMMENT 'Remaining unearned premium balance after this earning transaction.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this earned premium record was last modified.',
    CONSTRAINT pk_earned_premium PRIMARY KEY(`earned_premium_id`)
) COMMENT 'Tracks EP recognized over the policy exposure period via pro-rata or short-rate earning methods. Supports UEP calculation, GAAP revenue recognition, and IFRS 17 premium allocation approach.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` (
    `premium_transaction_id` BIGINT COMMENT 'Unique identifier for the premium transaction record. Primary key.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Premium transactions must reference calendar for proper accounting period assignment, GL posting, and financial statement preparation. Accounting_period denormalized, replace with FK.',
    `claim_id` BIGINT COMMENT 'Foreign key linking to claims.claim. Business justification: Return premium transactions on total loss claims require linking the premium adjustment back to the claim.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Premium transactions must reference currency master for exchange rate application, payment processing, bank reconciliation, and multi-currency financial reporting.',
    `endorsement_id` BIGINT COMMENT 'Reference to the policy endorsement that triggered this premium transaction, if applicable.',
    `installment_schedule_id` BIGINT COMMENT 'Reference to the billing installment plan under which this premium transaction is scheduled for payment.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Premium transactions require LOB classification for accounting, reinsurance treaty assignment, commission calculation, and regulatory reporting. Lob_code denormalized, replace with FK.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Premium transactions allocate to coverages for general ledger accounting, loss ratio tracking by coverage, reinsurance cession calculations, and statutory reporting.',
    `policy_id` BIGINT COMMENT 'Reference to the policy to which this premium transaction applies.',
    `policy_transaction_id` BIGINT COMMENT 'Reference to the policy cancellation event that triggered this premium transaction, if applicable.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the agent, broker, or producer responsible for this premium transaction and entitled to commission.',
    `reversed_transaction_premium_transaction_id` BIGINT COMMENT 'Reference to the original premium transaction that this transaction reverses, if applicable.',
    `ri_treaty_id` BIGINT COMMENT 'Reference to the reinsurance treaty under which premium is ceded for this transaction, if applicable.',
    `risk_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Risk location state drives rate filing compliance, surplus lines tax calculation, regulatory jurisdiction determination, and catastrophe exposure tracking.',
    `audit_code` BIGINT COMMENT 'Reference to the premium audit that resulted in this additional or return premium transaction, if applicable.',
    `booking_date` DATE COMMENT 'Date on which the premium transaction was recorded in the financial ledger and accounting system.',
    `ceded_premium_amount` DECIMAL(18,2) COMMENT 'Portion of the gross written premium ceded to reinsurers under treaty or facultative agreements.',
    `commission_amount` DECIMAL(18,2) COMMENT 'Total commission payable to producers, agents, or brokers for this premium transaction.',
    `commission_rate` DECIMAL(5,4) COMMENT 'Percentage rate applied to calculate the commission amount payable to the producer for this transaction.',
    `coverage_part_code` STRING COMMENT 'Code identifying the specific coverage part or section of the policy to which this premium applies.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this premium transaction record was first created in the system.',
    `dac_amount` DECIMAL(18,2) COMMENT 'Acquisition costs deferred and amortized over the policy term in accordance with GAAP accounting.',
    `due_date` DATE COMMENT 'Date by which the premium payment is due from the policyholder.',
    `earned_premium_amount` DECIMAL(18,2) COMMENT 'Portion of the written premium that has been earned as of the transaction date based on policy exposure period.',
    `effective_date` DATE COMMENT 'Date on which the premium transaction becomes effective for policy coverage and accounting purposes.',
    `exchange_rate` DECIMAL(12,6) COMMENT 'Foreign exchange rate applied to convert transaction amounts to the reporting currency, if applicable.',
    `exposure_units` DECIMAL(18,4) COMMENT 'Number of exposure units used to calculate the premium for this transaction, such as payroll, sales, or vehicle count.',
    `fee_amount` DECIMAL(18,2) COMMENT 'Administrative fees, policy fees, or service charges included in this premium transaction.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this premium transaction is posted in the financial accounting system.',
    `gwp_amount` DECIMAL(18,2) COMMENT 'Total premium amount written before any deductions for reinsurance cessions or commissions.',
    `installment_number` BIGINT COMMENT 'Sequential number of the installment within the billing plan, if this transaction is part of an installment schedule.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this premium transaction record was last modified or updated.',
    `nwp_amount` DECIMAL(18,2) COMMENT 'Net premium retained by the insurer after deducting ceded reinsurance premium from gross written premium.',
    `payment_method` STRING COMMENT 'Method or instrument used by the policyholder to remit payment for this premium transaction. [ENUM-REF-CANDIDATE: check|credit_card|debit_card|ach|wire_transfer|cash|payroll_deduction — 7 candidates stripped; promote to reference product]',
    `payment_received_date` DATE COMMENT 'Date on which payment for this premium transaction was received from the policyholder or producer.',
    `rate_per_unit` DECIMAL(12,6) COMMENT 'Premium rate applied per unit of exposure to calculate the transaction premium amount.',
    `reason_code` STRING COMMENT 'Standardized code indicating the specific reason for the premium transaction, such as policy change, coverage adjustment, or billing correction.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether this transaction is a reversal or correction of a previously posted premium transaction.',
    `statutory_line_code` STRING COMMENT 'NAIC statutory line of business code for regulatory annual statement reporting.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Total premium taxes, fees, and surcharges assessed on this transaction by state or federal authorities.',
    `total_billed_amount` DECIMAL(18,2) COMMENT 'Total amount billed to the policyholder including premium, taxes, and fees.',
    `transaction_description` STRING COMMENT 'Free-text description providing additional context or explanation for this premium transaction.',
    `transaction_number` STRING COMMENT 'Business-facing unique identifier for this premium transaction, often displayed on billing statements and invoices.',
    `transaction_status` STRING COMMENT 'Current lifecycle status of the premium transaction in the billing and accounting system.. Valid values are `pending|posted|reversed|voided|cancelled`',
    `transaction_type` STRING COMMENT 'Classification of the premium transaction indicating the business event that triggered it. [ENUM-REF-CANDIDATE: new_business|endorsement|cancellation|reinstatement|renewal|audit_premium|return_premium|refund|write_off — 9 candidates stripped; promote to',
    `unearned_premium_amount` DECIMAL(18,2) COMMENT 'Portion of the written premium that remains unearned and represents future coverage obligation.',
    CONSTRAINT pk_premium_transaction PRIMARY KEY(`premium_transaction_id`)
) COMMENT 'Atomic premium ledger entry and single SSOT for every premium movement: new business, endorsement AP/RP, cancellation, reinstatement, audit, return premium, refund disbursement, and write-off.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` (
    `rate_element_id` BIGINT COMMENT 'Unique identifier for the rate element. Primary key.',
    `coverage_form_id` BIGINT COMMENT 'Reference to the insurance product to which this rate element applies.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Rate elements are LOB-specific for underwriting, actuarial rating, loss cost determination, and rate filing organization. Lob denormalized, replace with FK.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Rate elements are state-specific due to regulatory filing requirements, DOI approval processes, and jurisdiction-specific rating rules. State_code denormalized, replace with FK.',
    `calculation_formula` STRING COMMENT 'Mathematical formula or expression defining how this rate element is applied in premium computation.',
    `cat_loading_factor` DECIMAL(10,6) COMMENT 'Factor applied to load premium for catastrophe exposure, reflecting probable maximum loss and reinsurance costs.',
    `rate_element_category` STRING COMMENT 'Broader grouping of the rate element for reporting and rate filing purposes.. Valid values are `manual_rate|experience_rating|schedule_rating|catastrophe_loading|expense_provision|profit_margin`',
    `class_code` STRING COMMENT 'Risk classification code to which this rate element applies, such as NCCI class codes or ISO class codes.. Valid values are `^[A-Z0-9]{4,10}$`',
    `rate_element_code` STRING COMMENT 'Business identifier code for the rate element used in rating calculations and external references.. Valid values are `^[A-Z0-9_-]{3,20}$`',
    `coverage_code` STRING COMMENT 'ISO or proprietary coverage code to which this rate element applies.. Valid values are `^[A-Z0-9]{2,10}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this rate element record was first created in the system.',
    `credibility_factor` DECIMAL(10,6) COMMENT 'Statistical credibility weight applied to experience-based rate elements, ranging from 0 to 1.',
    `deductible_credit_factor` DECIMAL(10,6) COMMENT 'Factor applied to reduce premium when a deductible is selected, reflecting reduced insurer exposure.',
    `default_value` DECIMAL(18,6) COMMENT 'Default value applied when no specific rate element value is determined during rating.',
    `rate_element_description` STRING COMMENT 'Detailed business description of the rate element, its purpose, and how it is applied in premium calculations.',
    `effective_date` DATE COMMENT 'Date from which this rate element becomes active and applicable to new and renewal policies.',
    `expense_provision` DECIMAL(10,6) COMMENT 'Percentage or factor representing underwriting expenses, commissions, and overhead included in the rate element.',
    `expiration_date` DATE COMMENT 'Date on which this rate element ceases to be active and is no longer applicable to policies.',
    `filing_approval_date` DATE COMMENT 'Date on which the regulatory authority approved the rate filing containing this rate element.',
    `increased_limits_factor` DECIMAL(10,6) COMMENT 'Factor applied to adjust premium when policy limits exceed the base limit, reflecting increased exposure.',
    `is_filed` BOOLEAN COMMENT 'Indicates whether this rate element has been filed with and approved by the regulatory authority.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether this rate element must be applied in all rating scenarios or is optional based on underwriting discretion.',
    `loss_cost` DECIMAL(18,6) COMMENT 'Pure premium or expected loss per unit of exposure, excluding expenses and profit, used as the foundation for rate development.',
    `maximum_value` DECIMAL(18,6) COMMENT 'Maximum allowable value for this rate element as defined by regulatory or underwriting guidelines.',
    `minimum_value` DECIMAL(18,6) COMMENT 'Minimum allowable value for this rate element as defined by regulatory or underwriting guidelines.',
    `naics_code` STRING COMMENT 'Six-digit NAICS code representing the industry classification to which this rate element applies.. Valid values are `^[0-9]{6}$`',
    `rate_element_name` STRING COMMENT 'Human-readable name of the rate element describing its purpose in premium computation.',
    `notes` STRING COMMENT 'Additional notes, comments, or special instructions related to the application or interpretation of this rate element.',
    `profit_margin` DECIMAL(10,6) COMMENT 'Percentage or factor representing the profit and contingency margin included in the rate element.',
    `rate_basis` STRING COMMENT 'Unit of measure or basis on which the rate element is applied during premium computation. [ENUM-REF-CANDIDATE: per_100_payroll|per_1000_receipts|per_unit|per_vehicle|per_location|flat|percentage — 7 candidates stripped; promote to reference product]',
    `rate_element_status` STRING COMMENT 'Current lifecycle status of the rate element indicating its availability for use in rating.. Valid values are `active|inactive|pending_approval|superseded|withdrawn`',
    `rate_element_type` STRING COMMENT 'Classification of the rate element indicating its role in the rating algorithm.. Valid values are `base_rate|class_factor|territory_multiplier|schedule_credit|schedule_debit|experience_modifier`',
    `rate_filing_number` STRING COMMENT 'Regulatory filing reference number under which this rate element was approved by the state Department of Insurance.. Valid values are `^[A-Z0-9-]{5,30}$`',
    `rate_source` STRING COMMENT 'Origin of the rate element indicating whether it is from ISO, NCCI, proprietary development, or advisory organization.. Valid values are `ISO|NCCI|PROPRIETARY|ADVISORY|BUREAU`',
    `rate_table_name` STRING COMMENT 'Name of the rate table or rating manual section from which this rate element is derived.',
    `rate_value` DECIMAL(18,6) COMMENT 'Numeric value of the rate element used in premium calculation, expressed as a factor, multiplier, or absolute rate.',
    `rate_version` STRING COMMENT 'Version identifier for the rate element used to track changes and updates over time.. Valid values are `^[A-Z0-9.]{1,20}$`',
    `rating_tier` STRING COMMENT 'Underwriting tier or risk segment to which this rate element applies, reflecting risk quality.. Valid values are `preferred|standard|substandard|declined`',
    `rol_value` DECIMAL(10,6) COMMENT 'Rate on line value expressed as a percentage of limit, commonly used in reinsurance and catastrophe pricing.',
    `rpp_value` DECIMAL(18,6) COMMENT 'Rate per point value used in experience rating calculations, particularly for workers compensation.',
    `sic_code` STRING COMMENT 'Four-digit SIC code representing the industry classification to which this rate element applies.. Valid values are `^[0-9]{4}$`',
    `territory_code` STRING COMMENT 'Geographic territory code to which this rate element applies, used for territory-based rating.. Valid values are `^[A-Z0-9]{1,10}$`',
    `trend_factor` DECIMAL(10,6) COMMENT 'Factor applied to adjust historical loss costs for inflation, frequency, and severity trends.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this rate element record was last modified in the system.',
    CONSTRAINT pk_rate_element PRIMARY KEY(`rate_element_id`)
) COMMENT 'Master catalog of individual rating factors and their values used in premium computation: base rates, class factors, territory multipliers, schedule credits/debits, and ISO RPP elements. SSOT for rate content.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` (
    `rate_table_id` BIGINT COMMENT 'Unique identifier for the rate table version. Primary key.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Rate tables are organized by LOB for regulatory filing, rating plan management, and actuarial analysis. Lob denormalized, replace with FK.',
    `policy_rate_filing_id` BIGINT COMMENT 'Reference to the regulatory rate filing under which this rate table was approved.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Rate tables must link to state for regulatory filing tracking, DOI approval verification, jurisdiction-specific rating, and compliance auditing. State_code denormalized, replace with FK.',
    `actuarial_memo_reference` STRING COMMENT 'Reference to the actuarial memorandum or rate filing documentation supporting this rate table.',
    `approval_date` DATE COMMENT 'Date the state insurance department approved this rate table for use.',
    `approved_by_regulator` BOOLEAN COMMENT 'Indicates whether this rate table has received formal approval from the state insurance department.',
    `class_code` STRING COMMENT 'ISO or NCCI class code for which this rate table provides base rates or factors.',
    `rate_table_code` STRING COMMENT 'Unique business code identifying the rate table across systems and filings.',
    `coverage_code` STRING COMMENT 'ISO or company coverage code this rate table applies to, such as BI, PD, COLL, COMP.',
    `created_by_user` STRING COMMENT 'User identifier of the person who created this rate table version.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this rate table version was first created in the system.',
    `effective_date` DATE COMMENT 'Date when this rate table version becomes active and available for policy rating.',
    `expense_provision` DECIMAL(18,6) COMMENT 'Expense loading component included in the rate to cover underwriting, acquisition, and administrative costs.',
    `expiration_date` DATE COMMENT 'Date when this rate table version is no longer valid for new business or renewals. Null if still active.',
    `filing_number` STRING COMMENT 'State insurance department filing number or SERFF tracking number for this rate table submission.',
    `iso_content_flag` BOOLEAN COMMENT 'Indicates whether this rate table contains ISO-licensed rating content or proprietary company rates.',
    `iso_edition` STRING COMMENT 'ISO manual edition identifier if this rate table is based on ISO content.',
    `loss_cost` DECIMAL(18,6) COMMENT 'Pure premium or loss cost component of the rate, excluding expense and profit loads.',
    `maximum_rate` DECIMAL(18,6) COMMENT 'Maximum allowable rate value after all factors and modifiers are applied.',
    `minimum_rate` DECIMAL(18,6) COMMENT 'Minimum allowable rate value after all factors and modifiers are applied.',
    `rate_table_name` STRING COMMENT 'Business name of the rate table for identification and reference purposes.',
    `ncci_content_flag` BOOLEAN COMMENT 'Indicates whether this rate table contains NCCI-licensed workers compensation rating content.',
    `owner` STRING COMMENT 'Business unit or department responsible for maintaining and updating this rate table.',
    `profit_provision` DECIMAL(18,6) COMMENT 'Profit and contingency loading component included in the rate.',
    `rate_basis` STRING COMMENT 'Unit basis for rate application: per unit, per hundred exposure, per thousand, flat fee, or percentage.. Valid values are `per_unit|per_hundred|per_thousand|flat|percentage`',
    `rate_change_percent` DECIMAL(5,2) COMMENT 'Percentage change from the prior rate table version, used for regulatory filing documentation.',
    `rate_description` STRING COMMENT 'Detailed business description of what this rate table row represents and how it is applied in rating.',
    `rate_footnote` STRING COMMENT 'Additional notes, exceptions, or special instructions for applying this rate.',
    `rate_source` STRING COMMENT 'Origin of the rate content: ISO, NCCI, company proprietary, state manual, or advisory organization.. Valid values are `iso|ncci|company_proprietary|state_manual|advisory_organization`',
    `rate_table_status` STRING COMMENT 'Current lifecycle status of the rate table in the filing and approval workflow.. Valid values are `draft|pending_approval|approved|active|superseded|withdrawn`',
    `rate_table_type` STRING COMMENT 'Classification of rate content: base rates, factors, credits, debits, or modifiers. [ENUM-REF-CANDIDATE: base_rate|class_factor|territory_factor|schedule_credit|schedule_debit|experience_mod|increased_limit — 7 candidates stripped; promote to reference',
    `rate_unit_of_measure` STRING COMMENT 'Unit of measure for the rate value, defining how the rate is applied to exposure. [ENUM-REF-CANDIDATE: per_unit|per_hundred|per_thousand|per_vehicle|per_location|per_employee|flat — 7 candidates stripped; promote to reference product]',
    `rate_value` DECIMAL(18,6) COMMENT 'Numeric rate value, factor, credit, or debit stored in this rate table row.',
    `rate_version` BIGINT COMMENT 'Sequential version number for this rate table iteration within the same filing and effective period.',
    `rating_plan` STRING COMMENT 'Name or code of the rating plan or program this rate table supports, such as tiered or preferred programs.',
    `rating_tier` STRING COMMENT 'Tier level within a multi-tier rating plan, such as standard, preferred, or elite.',
    `rol_value` DECIMAL(18,6) COMMENT 'Rate on Line value used in excess and reinsurance pricing, expressed as premium divided by limit.',
    `rpp_value` DECIMAL(18,6) COMMENT 'ISO Rate Per Point value used in commercial lines rating calculations.',
    `territory_code` STRING COMMENT 'Geographic territory code for which this rate table provides territory-specific rates or factors.',
    `updated_by_user` STRING COMMENT 'User identifier of the person who last modified this rate table version.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this rate table version was last modified.',
    CONSTRAINT pk_rate_table PRIMARY KEY(`rate_table_id`)
) COMMENT 'Versioned rate table and single SSOT for all rate content: base rates, class/territory factors, schedule credits/debits, and ISO RPP elements, held as rows grouped by LOB, state, effective date, and filing across multi-tier plans.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` (
    `rating_worksheet_id` BIGINT COMMENT 'Unique identifier for the rating worksheet record. Primary key.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Rating calculations in multiple currencies require currency reference for proper premium calculation, display formatting, and quote presentation. Currency_code denormalized, replace with FK.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Rating worksheets must reference LOB for proper rating plan selection, premium calculation rules, and underwriting guidelines. Lob denormalized, replace with FK.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Rating worksheets must trace to specific coverages for audit trail, quote reconstruction, underwriting review, and regulatory rate verification.',
    `policy_id` BIGINT COMMENT 'Reference to the policy being rated or quoted.',
    `quote_id` BIGINT COMMENT 'Reference to the quote for which this rating worksheet was generated.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the rating worksheet was approved.',
    `approved_by` STRING COMMENT 'Name or identifier of the person who approved the rating worksheet.',
    `base_rate` DECIMAL(18,6) COMMENT 'The foundational rate per unit of exposure before application of modifiers and factors.',
    `calculation_notes` STRING COMMENT 'Free-text notes or comments regarding the rating calculation, exceptions, or underwriter rationale.',
    `calculation_timestamp` TIMESTAMP COMMENT 'Date and time when the rating calculation was executed.',
    `class_code` STRING COMMENT 'Risk classification code used in rating, such as NAICS, SIC, or ISO class code.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the rating worksheet record was first created in the system.',
    `cumulative_premium` DECIMAL(18,2) COMMENT 'Running total premium amount after applying all rating steps up to and including this step.',
    `deductible_credit` DECIMAL(18,2) COMMENT 'Premium credit applied for selection of higher deductibles.',
    `effective_date` DATE COMMENT 'Date from which the rated premium becomes effective for the policy or quote.',
    `experience_mod` DECIMAL(5,3) COMMENT 'Experience modification factor applied to adjust premium based on historical loss experience.',
    `expiration_date` DATE COMMENT 'Date on which the rated premium period ends.',
    `exposure_units` DECIMAL(18,2) COMMENT 'Quantity of exposure units used in the rating calculation, such as payroll amount or square footage.',
    `gwp` DECIMAL(18,2) COMMENT 'Total premium charged before any reinsurance cessions or adjustments.',
    `intermediate_premium` DECIMAL(18,2) COMMENT 'Premium amount calculated at this step before subsequent factors are applied.',
    `minimum_premium` DECIMAL(18,2) COMMENT 'Minimum premium amount required for this policy or coverage, regardless of calculated premium.',
    `minimum_premium_applied_flag` BOOLEAN COMMENT 'Indicates whether the minimum premium override was applied in the final calculation.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when the rating worksheet record was last modified.',
    `nwp` DECIMAL(18,2) COMMENT 'Premium retained after reinsurance cessions.',
    `product_code` STRING COMMENT 'Code identifying the insurance product being rated.',
    `rate_effective_date` DATE COMMENT 'Date on which the rating plan or rate table became effective.',
    `rate_source` STRING COMMENT 'Source of the rating data used, such as ISO, Verisk, proprietary, or state manual.. Valid values are `iso|verisk|proprietary|state_manual|ncci`',
    `rating_basis` STRING COMMENT 'The exposure basis used for rating, such as payroll, sales, area, number of vehicles, or TIV.',
    `rating_factor_code` STRING COMMENT 'Code identifying the specific rating factor or variable used in this step.',
    `rating_factor_type` STRING COMMENT 'Type of rating factor applied in this step, indicating how it modifies the premium. [ENUM-REF-CANDIDATE: base_rate|multiplier|additive|discount|surcharge|credit|debit — 7 candidates stripped; promote to reference product]',
    `rating_factor_value` DECIMAL(18,6) COMMENT 'Numeric value of the rating factor applied in this calculation step.',
    `rating_plan_code` STRING COMMENT 'Code identifying the rating plan or algorithm used for premium calculation.',
    `rating_plan_version` STRING COMMENT 'Version of the rating plan applied, ensuring rate adequacy and regulatory compliance.',
    `rating_status` STRING COMMENT 'Current lifecycle status of the rating worksheet in the underwriting workflow.. Valid values are `draft|calculated|approved|rejected|superseded`',
    `rating_step_name` STRING COMMENT 'Descriptive name of the rating step, such as Base Rate, Territory Factor, Experience Mod.',
    `rating_step_sequence` BIGINT COMMENT 'Sequential order of this rating step within the overall calculation workflow.',
    `schedule_credit_debit` DECIMAL(18,2) COMMENT 'Discretionary premium adjustment applied by underwriter based on risk characteristics.',
    `step_premium_adjustment` DECIMAL(18,2) COMMENT 'The incremental premium change resulting from this rating step.',
    `taxes_and_fees` DECIMAL(18,2) COMMENT 'Total amount of taxes, surcharges, and regulatory fees applied to the premium.',
    `territory_code` STRING COMMENT 'Geographic territory code used for rating purposes.',
    `total_charged_premium` DECIMAL(18,2) COMMENT 'Final premium amount charged to the policyholder, including all taxes and fees.',
    `underwriter_code` BIGINT COMMENT 'Reference to the underwriter who reviewed or approved this rating worksheet.',
    `worksheet_number` STRING COMMENT 'Business-facing unique identifier for the rating worksheet, used for audit and reference purposes.',
    `worksheet_version` BIGINT COMMENT 'Version number of the rating worksheet, incremented when recalculations occur.',
    CONSTRAINT pk_rating_worksheet PRIMARY KEY(`rating_worksheet_id`)
) COMMENT 'Step-by-step premium calculation audit trail for a quoted or bound risk. Captures each rating step, applied factor, intermediate result, and final charged premium. Supports UW review and rate adequacy audits.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` (
    `billing_account_id` BIGINT COMMENT 'Unique identifier for the billing account. Primary key.',
    `billing_country_id` BIGINT COMMENT 'Foreign key linking to shared.country. Business justification: International billing requires country reference for address validation, regulatory jurisdiction, postal code format, and payment processing rules.',
    `billing_currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Billing in multiple currencies requires currency master for exchange rates, payment processing, and account balance calculation. Billing_currency_code denormalized, replace with FK.',
    `billing_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Billing accounts need state reference for premium tax calculation, regulatory compliance, and address validation. Billing_state_code denormalized, replace with FK.',
    `insured_id` BIGINT COMMENT 'Reference to the party responsible for payment on this billing account.',
    `policy_id` BIGINT COMMENT 'Reference to the primary policy associated with this billing account.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the agent or broker servicing this billing account, relevant for agency bill arrangements.',
    `account_name` STRING COMMENT 'Descriptive name for the billing account, typically matching the payer or primary insured name.',
    `account_number` STRING COMMENT 'Externally visible unique account number used for customer communication and payment reference.. Valid values are `^[A-Z0-9]{8,20}$`',
    `account_status` STRING COMMENT 'Current lifecycle status of the billing account reflecting payment standing and operational state.. Valid values are `active|suspended|delinquent|closed|cancelled`',
    `account_type` STRING COMMENT 'Classification of the billing account based on the payer relationship and business segment.. Valid values are `individual|commercial|agency|group`',
    `autopay_flag` BOOLEAN COMMENT 'Indicates whether automatic payment is enabled for this billing account via bank draft or credit card.',
    `billing_address_line1` STRING COMMENT 'First line of the billing address to which statements and notices are sent.',
    `billing_address_line2` STRING COMMENT 'Second line of the billing address for suite, apartment, or additional location details.',
    `billing_city` STRING COMMENT 'City name for the billing address.',
    `billing_contact_email` STRING COMMENT 'Primary email address for billing communications, statements, and payment notifications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `billing_contact_phone` STRING COMMENT 'Primary phone number for billing inquiries and payment reminders.. Valid values are `^+?[0-9]{10,15}$`',
    `billing_method` STRING COMMENT 'Method by which premiums are billed: direct to insured, through agent, or other arrangement.. Valid values are `direct_bill|agency_bill|list_bill|account_current`',
    `billing_postal_code` STRING COMMENT 'Postal or ZIP code for the billing address.. Valid values are `^[0-9]{5}(-[0-9]{4})?$`',
    `cancellation_date` DATE COMMENT 'Date on which the billing account was cancelled due to non-payment, policy cancellation, or other reason.',
    `cancellation_reason_code` STRING COMMENT 'Code indicating the reason for billing account cancellation: non-payment, insured request, underwriting, etc.. Valid values are `^[A-Z0-9]{2,6}$`',
    `commission_rate_percent` DECIMAL(5,2) COMMENT 'Percentage commission rate applicable to premiums billed on this account for agency bill arrangements.',
    `created_by_user` STRING COMMENT 'User identifier of the person or system that created this billing account record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this billing account record was first created in the system.',
    `current_balance_amount` DECIMAL(15,2) COMMENT 'Current outstanding balance on the billing account, including all billed charges less payments and adjustments.',
    `delinquency_days` BIGINT COMMENT 'Number of days the account has been past due, calculated from the oldest unpaid invoice due date.',
    `effective_date` DATE COMMENT 'Date on which the billing account became active and billing commenced.',
    `expiration_date` DATE COMMENT 'Date on which the billing account is scheduled to expire or terminate, typically aligned with policy term.',
    `grace_period_days` BIGINT COMMENT 'Number of days after the due date during which payment may be received without penalty or cancellation.',
    `last_payment_amount` DECIMAL(15,2) COMMENT 'Amount of the most recent payment received and posted to this billing account.',
    `last_payment_date` DATE COMMENT 'Date on which the most recent payment was received and posted to this billing account.',
    `last_statement_date` DATE COMMENT 'Date on which the most recent billing statement was generated and sent to the payer.',
    `next_due_amount` DECIMAL(15,2) COMMENT 'Amount of the next scheduled installment payment due on this billing account.',
    `next_due_date` DATE COMMENT 'Date on which the next installment payment is due for this billing account.',
    `paperless_billing_flag` BOOLEAN COMMENT 'Indicates whether the payer has elected to receive billing statements electronically instead of by mail.',
    `past_due_amount` DECIMAL(15,2) COMMENT 'Portion of the current balance that is past the due date and subject to collection action.',
    `payment_frequency` STRING COMMENT 'Frequency at which premium installments are due on this billing account.. Valid values are `annual|semi_annual|quarterly|monthly|custom`',
    `payment_plan_code` STRING COMMENT 'Code identifying the installment payment plan: full pay, monthly, quarterly, or custom schedule.. Valid values are `^[A-Z0-9]{2,10}$`',
    `total_billed_amount` DECIMAL(15,2) COMMENT 'Cumulative amount billed to this account since inception, including all premium charges and fees.',
    `total_paid_amount` DECIMAL(15,2) COMMENT 'Cumulative amount paid by the payer on this account since inception, including all applied payments.',
    `unapplied_payment_amount` DECIMAL(15,2) COMMENT 'Total amount of payments received but not yet applied to specific invoices or charges.',
    `updated_by_user` STRING COMMENT 'User identifier of the person or system that last modified this billing account record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this billing account record was last modified.',
    CONSTRAINT pk_billing_account PRIMARY KEY(`billing_account_id`)
) COMMENT 'Master billing account grouping one or more policies under a single payer relationship. Manages payment plan, billing method (direct bill vs. agency bill), and account-level balance. SSOT for payer identity in billing.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` (
    `installment_schedule_id` BIGINT COMMENT 'Unique identifier for the installment schedule record.',
    `billing_account_id` BIGINT COMMENT 'Reference to the billing account associated with this installment schedule.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Installment payment plans must reference currency for proper billing, payment application, and exchange rate handling. Currency_code denormalized, replace with FK.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Payment plan eligibility and terms vary by LOB for risk management and regulatory compliance. Lob_code denormalized, replace with FK.',
    `policy_id` BIGINT COMMENT 'Reference to the policy for which this installment schedule applies.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Installment eligibility rules, cancellation for non-payment periods, and grace period requirements are state-regulated. State_code denormalized, replace with FK.',
    `autopay_discount_amount` DECIMAL(15,2) COMMENT 'Discount applied to total premium or fees when policyholder enrolls in autopay.',
    `autopay_enrolled_flag` BOOLEAN COMMENT 'Indicates whether the policyholder is enrolled in automatic payment for this schedule.',
    `billing_method` STRING COMMENT 'Method by which the policyholder is billed for installments.. Valid values are `direct_bill|agency_bill|list_bill|account_current`',
    `cancellation_for_nonpayment_days` BIGINT COMMENT 'Number of days after missed payment before policy is subject to cancellation for nonpayment.',
    `cancellation_reason_code` STRING COMMENT 'Code indicating the reason for schedule cancellation such as nonpayment, policy cancellation, or policyholder request.',
    `cancelled_timestamp` TIMESTAMP COMMENT 'Date and time when the installment schedule was cancelled.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the installment schedule record was first created in the system.',
    `down_payment_amount` DECIMAL(15,2) COMMENT 'Initial payment amount due at policy binding or schedule creation.',
    `down_payment_due_date` DATE COMMENT 'Date by which the down payment must be received.',
    `down_payment_percentage` DECIMAL(5,2) COMMENT 'Percentage of total premium required as down payment, typically expressed as a decimal.',
    `eligibility_criteria` STRING COMMENT 'Business rules or conditions that determine eligibility for this payment plan by LOB and state.',
    `first_installment_due_date` DATE COMMENT 'Due date for the first regular installment payment after down payment.',
    `grace_period_days` BIGINT COMMENT 'Number of days after due date during which payment may be received without penalty or cancellation.',
    `installment_count` BIGINT COMMENT 'Total number of installments in the schedule including down payment if applicable.',
    `installment_fee_amount` DECIMAL(15,2) COMMENT 'Fee charged per installment for payment plan administration.',
    `installment_frequency` STRING COMMENT 'Frequency at which installment payments are due.. Valid values are `monthly|quarterly|semi-annual|annual|bi-weekly`',
    `late_payment_fee_amount` DECIMAL(15,2) COMMENT 'Fee assessed when an installment payment is received after the grace period.',
    `maximum_premium_threshold` DECIMAL(15,2) COMMENT 'Maximum total premium amount allowed for this installment schedule.',
    `minimum_premium_threshold` DECIMAL(15,2) COMMENT 'Minimum total premium amount required to qualify for this installment schedule.',
    `notes` STRING COMMENT 'Free-form text for additional comments or special instructions related to the installment schedule.',
    `paperless_billing_flag` BOOLEAN COMMENT 'Indicates whether the policyholder has opted for electronic billing statements.',
    `paperless_discount_amount` DECIMAL(15,2) COMMENT 'Discount applied when policyholder opts for paperless billing.',
    `payment_method_preference` STRING COMMENT 'Preferred payment instrument for installment payments.. Valid values are `credit_card|debit_card|ach|check|wire_transfer|cash`',
    `payment_plan_code` STRING COMMENT 'Code identifying the payment plan type such as monthly, quarterly, semi-annual, or annual.',
    `payment_plan_name` STRING COMMENT 'Descriptive name of the payment plan for business user reference.',
    `reinstatement_fee_amount` DECIMAL(15,2) COMMENT 'Fee charged to reinstate a policy that was cancelled for nonpayment.',
    `schedule_effective_date` DATE COMMENT 'Date when the installment schedule becomes active and binding.',
    `schedule_expiration_date` DATE COMMENT 'Date when the installment schedule ends or final payment is due.',
    `schedule_number` STRING COMMENT 'Business identifier for the installment schedule, typically system-generated or policy-derived.',
    `schedule_status` STRING COMMENT 'Current lifecycle status of the installment schedule.. Valid values are `active|suspended|cancelled|completed|defaulted|pending`',
    `total_amount_due` DECIMAL(15,2) COMMENT 'Total amount due including premium and all fees across the entire schedule.',
    `total_fees_amount` DECIMAL(15,2) COMMENT 'Total fees to be collected across all installments.',
    `total_premium_amount` DECIMAL(15,2) COMMENT 'Total premium amount to be collected across all installments including down payment.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when the installment schedule record was last modified.',
    CONSTRAINT pk_installment_schedule PRIMARY KEY(`installment_schedule_id`)
) COMMENT 'Payment-plan definition and instantiated billing schedule for an account or policy: plan code/name, installment count, down payment, due dates, amounts, fees, and eligibility by LOB and state.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`premium`.`installment` (
    `installment_id` BIGINT COMMENT 'Unique identifier for the installment record within the billing schedule.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Individual installment billing requires currency reference for payment processing, exchange rate application, and account reconciliation. Currency_code denormalized, replace with FK.',
    `installment_schedule_id` BIGINT COMMENT 'Reference to the parent billing schedule that contains this installment.',
    `policy_id` BIGINT COMMENT 'Reference to the policy for which this installment is billed.',
    `autopay_flag` BOOLEAN COMMENT 'Indicates whether this installment is enrolled in automatic payment processing.',
    `billed_amount` DECIMAL(18,2) COMMENT 'Total amount billed for this installment, including premium and fees.',
    `billed_date` DATE COMMENT 'Date when the installment invoice was generated and sent to the policyholder.',
    `billing_notice_sent_flag` BOOLEAN COMMENT 'Indicates whether a billing notice has been sent to the policyholder for this installment.',
    `cancellation_effective_date` DATE COMMENT 'Date when the policy will be cancelled if this installment remains unpaid.',
    `cancellation_notice_date` DATE COMMENT 'Date when a cancellation notice was issued due to non-payment of this installment.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this installment record was first created in the system.',
    `days_overdue` BIGINT COMMENT 'Number of days the installment payment is past the grace period end date.',
    `delinquency_status` STRING COMMENT 'Classification of the installment based on payment timeliness and collection status.. Valid values are `current|overdue|in_grace|delinquent|written_off`',
    `due_date` DATE COMMENT 'Date by which the installment payment is due from the policyholder.',
    `fee_amount` DECIMAL(18,2) COMMENT 'Total fees charged on this installment (e.g., installment fee, service charge).',
    `grace_period_days` BIGINT COMMENT 'Number of days after due date before the installment is considered overdue.',
    `grace_period_end_date` DATE COMMENT 'Date when the grace period expires and the installment becomes overdue.',
    `installment_status` STRING COMMENT 'Current payment status of the installment in its lifecycle.. Valid values are `pending|billed|paid|partially_paid|overdue|cancelled`',
    `invoice_number` STRING COMMENT 'Unique invoice number generated for this installment billing.',
    `late_fee_amount` DECIMAL(18,2) COMMENT 'Late payment fee assessed if installment is paid after the due date.',
    `late_notice_sent_flag` BOOLEAN COMMENT 'Indicates whether a late payment notice has been sent for this overdue installment.',
    `number` BIGINT COMMENT 'Sequential number of this installment within the billing schedule (e.g., 1 of 12).',
    `outstanding_balance` DECIMAL(18,2) COMMENT 'Remaining unpaid balance on this installment (billed amount minus paid amount).',
    `paid_amount` DECIMAL(18,2) COMMENT 'Total amount paid by the policyholder toward this installment to date.',
    `paid_date` DATE COMMENT 'Date when the installment was fully paid by the policyholder.',
    `payment_channel` STRING COMMENT 'Channel or interface through which the installment payment was received.. Valid values are `online|mobile_app|agent|mail|phone|in_person`',
    `payment_method` STRING COMMENT 'Method or instrument used by the policyholder to pay this installment. [ENUM-REF-CANDIDATE: check|credit_card|debit_card|ach|wire|cash|money_order — 7 candidates stripped; promote to reference product]',
    `payment_reference_number` STRING COMMENT 'External reference number or transaction ID from the payment processor.',
    `premium_amount` DECIMAL(18,2) COMMENT 'Portion of the installment amount that represents pure insurance premium.',
    `reminder_notice_sent_flag` BOOLEAN COMMENT 'Indicates whether a payment reminder notice has been sent for this installment.',
    `reversal_date` DATE COMMENT 'Date when a payment reversal occurred on this installment.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether a payment on this installment has been reversed (e.g., chargeback, NSF).',
    `reversal_reason` STRING COMMENT 'Reason code or description for why a payment was reversed (e.g., NSF, chargeback, dispute).',
    `tax_amount` DECIMAL(18,2) COMMENT 'Total taxes (e.g., premium tax, surcharges) included in this installment.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this installment record was last modified.',
    `waived_date` DATE COMMENT 'Date when the installment was waived or forgiven.',
    `waived_flag` BOOLEAN COMMENT 'Indicates whether this installment has been waived or forgiven by the insurer.',
    `waived_reason` STRING COMMENT 'Reason or justification for waiving this installment (e.g., customer service, hardship).',
    CONSTRAINT pk_installment PRIMARY KEY(`installment_id`)
) COMMENT 'Individual installment due record within a schedule: due date, billed amount, paid amount, outstanding balance, and delinquency status. Drives billing notices, late fees, and cancellation-for-nonpayment workflows.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`premium`.`payment` (
    `payment_id` BIGINT COMMENT 'Unique identifier for the premium payment transaction record.',
    `billing_account_id` BIGINT COMMENT 'Reference to the billing account that made this payment.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Payment transactions must reference currency master for exchange rate application, bank reconciliation, and multi-currency payment processing. Currency_code denormalized, replace with FK.',
    `installment_schedule_id` BIGINT COMMENT 'Reference to the installment or payment plan this payment is associated with.',
    `policy_id` BIGINT COMMENT 'Reference to the policy for which this premium payment was received.',
    `premium_transaction_id` BIGINT COMMENT 'Unique transaction identifier assigned by the payment gateway or processor.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the agent or broker who facilitated or collected the payment.',
    `amount` DECIMAL(18,2) COMMENT 'Total monetary amount received in this payment transaction.',
    `applied_amount` DECIMAL(18,2) COMMENT 'Portion of the payment amount that has been applied to outstanding invoices or installments.',
    `authorization_code` STRING COMMENT 'Authorization or approval code returned by the payment processor for card transactions.',
    `bank_name` STRING COMMENT 'Name of the financial institution that processed the payment.',
    `bank_routing_number` STRING COMMENT 'Nine-digit ABA routing number for ACH or wire payments.. Valid values are `^[0-9]{9}$`',
    `channel` STRING COMMENT 'Interface or touchpoint through which the payment was submitted (web portal, mobile app, agent office, mail, phone, branch, lockbox). [ENUM-REF-CANDIDATE: web|mobile|agent|mail|phone|branch|lockbox — 7 candidates stripped; promote to reference product]',
    `cleared_date` DATE COMMENT 'Date the payment cleared the bank and funds were confirmed available.',
    `convenience_fee_amount` DECIMAL(18,2) COMMENT 'Additional fee charged to the payer for using a specific payment method or channel.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the payment record was first created in the system.',
    `deposit_date` DATE COMMENT 'Date the payment was deposited into the insurers bank account.',
    `effective_date` DATE COMMENT 'Date from which the payment is effective for premium credit or policy reinstatement purposes.',
    `installment_number` BIGINT COMMENT 'Sequence number of the installment this payment satisfies within the payment plan.',
    `method` STRING COMMENT 'Instrument or mechanism used to remit the payment (check, ACH, card, wire, cash). [ENUM-REF-CANDIDATE: check|ach|wire|credit_card|debit_card|cash|money_order — 7 candidates stripped; promote to reference product]',
    `modified_by` STRING COMMENT 'User ID or system identifier that last modified the payment record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the payment record was last modified.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding the payment transaction, exceptions, or special handling.',
    `number` STRING COMMENT 'Business-facing unique payment transaction number or receipt number.',
    `payer_account_number` STRING COMMENT 'Masked or tokenized account number from which the payment was drawn (last 4 digits of card or bank account).',
    `payer_name` STRING COMMENT 'Name of the individual or entity that remitted the payment.',
    `payment_date` DATE COMMENT 'Date the payment was received or posted to the account.',
    `payment_status` STRING COMMENT 'Current lifecycle status of the payment transaction in the billing workflow.. Valid values are `pending|applied|cleared|reversed|failed|suspended`',
    `payment_type` STRING COMMENT 'Classification of the payment purpose (premium, reinstatement, late fee, NSF fee, adjustment, refund).. Valid values are `premium|reinstatement|late_fee|nsfee|adjustment|refund`',
    `processing_fee_amount` DECIMAL(18,2) COMMENT 'Fee charged by the payment processor or gateway for handling the transaction.',
    `receipt_issued_date` DATE COMMENT 'Date the payment receipt was generated and issued to the payer.',
    `receipt_number` STRING COMMENT 'Official receipt number issued to the payer acknowledging the payment.',
    `reference_number` STRING COMMENT 'External reference number from the payment processor, bank, or payer (check number, ACH trace, card authorization code).',
    `reversal_date` DATE COMMENT 'Date the payment was reversed or returned, if applicable.',
    `reversal_reason` STRING COMMENT 'Explanation or code for why the payment was reversed, if applicable (NSF, stop payment, dispute).',
    `source` STRING COMMENT 'Origin or category of the payer (policyholder, third party, agent, reinsurer, subrogation recovery).. Valid values are `policyholder|third_party|agent|reinsurer|subrogation`',
    `unapplied_amount` DECIMAL(18,2) COMMENT 'Portion of the payment held in suspense, not yet matched to a policy or account balance.',
    `created_by` STRING COMMENT 'User ID or system identifier that created the payment record.',
    CONSTRAINT pk_payment PRIMARY KEY(`payment_id`)
) COMMENT 'Records each premium payment received: date, amount, method (check, ACH, card), and any unapplied suspense balance pending policy/account matching. Applied to installments via the payment_application junction.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` (
    `payment_application_id` BIGINT COMMENT 'Unique identifier for the payment application record. Primary key for the junction table linking premium payments to installments.',
    `installment_id` BIGINT COMMENT 'Foreign key reference to the premium installment schedule entry to which the payment is being applied.',
    `payment_id` BIGINT COMMENT 'Foreign key reference to the premium payment transaction that is being applied to one or more installments.',
    `premium_transaction_id` BIGINT COMMENT 'Unique transaction identifier from the source billing system. Enables traceability back to the originating system for reconciliation and troubleshooting.',
    `allocation_priority` BIGINT COMMENT 'Numeric priority order used to allocate payment across multiple installments or charge types. Lower numbers applied first per billing rules.',
    `application_date` DATE COMMENT 'Business date on which the payment was applied to the installment. May differ from payment received date due to batch processing or suspense clearing.',
    `application_method` STRING COMMENT 'Method by which the payment was applied to the installment: automatic system matching, manual CSR allocation, suspense clearing, reversal, or adjustment.. Valid values are `automatic|manual|suspense_clearing|reversal|adjustment`',
    `application_notes` STRING COMMENT 'Free-text notes entered by CSR or system explaining special circumstances of the payment application such as manual allocation reason or suspense research outcome.',
    `application_sequence` BIGINT COMMENT 'Sequential order in which this payment application was processed. Supports audit trail and reversal logic for multi-installment payments.',
    `application_status` STRING COMMENT 'Current lifecycle status of the payment application. Applied is normal state; reversed indicates the application was undone; pending for suspense items.. Valid values are `applied|reversed|pending|voided`',
    `application_timestamp` TIMESTAMP COMMENT 'Precise date and time when the payment application transaction was recorded in the billing system. Supports audit and reconciliation.',
    `applied_amount` DECIMAL(15,2) COMMENT 'Monetary amount from the payment that was applied to this specific installment. Sum of all applied amounts for a payment equals the payment total.',
    `applied_by_user_code` STRING COMMENT 'User ID of the CSR or system account that executed the payment application. Null for fully automated applications. Supports audit and quality review.',
    `applied_to_fee_flag` BOOLEAN COMMENT 'Indicates whether this application was allocated to fees such as late payment fees, NSF fees, or installment fees rather than premium principal.',
    `applied_to_interest_flag` BOOLEAN COMMENT 'Indicates whether this application was allocated to accrued interest charges on overdue installments rather than premium principal.',
    `applied_to_principal_flag` BOOLEAN COMMENT 'Indicates whether this application reduced the principal premium amount. True for standard applications; false for fee or interest applications.',
    `billing_account_number` STRING COMMENT 'Billing account number under which the installment and payment are managed. Denormalized for cash application and reconciliation reporting.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this payment application record was first created in the data warehouse. Supports data lineage and audit trail.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the applied amount. Typically USD for domestic P&C operations.. Valid values are `^[A-Z]{3}$`',
    `installment_balance_after` DECIMAL(15,2) COMMENT 'Outstanding balance of the installment immediately after this payment application. Should equal balance_before minus applied_amount.',
    `installment_balance_before` DECIMAL(15,2) COMMENT 'Outstanding balance of the installment immediately before this payment application. Enables balance reconciliation and audit trail.',
    `nsf_reversal_flag` BOOLEAN COMMENT 'Indicates whether this application was reversed due to a returned or dishonored payment such as NSF check or failed ACH. Triggers reinstatement of installment balance.',
    `policy_number` STRING COMMENT 'Policy number associated with the installment to which payment is applied. Denormalized for reporting and reconciliation convenience.',
    `reversal_date` DATE COMMENT 'Business date on which this payment application was reversed. Null if application remains in effect. Critical for earned premium and cash reconciliation.',
    `reversal_reason_code` STRING COMMENT 'Standardized code indicating why this payment application was reversed. Null if application has not been reversed. Used for audit and reporting.',
    `reversal_timestamp` TIMESTAMP COMMENT 'Precise date and time when the payment application was reversed. Null if not reversed. Supports audit trail and temporal queries.',
    `source_system_code` STRING COMMENT 'Code identifying the billing or payment system that originated this payment application record. Supports multi-system integration and data lineage.',
    `suspense_clearing_flag` BOOLEAN COMMENT 'Indicates whether this application cleared a payment from suspense account. True when unidentified payment is matched to installment after research.',
    `unapplied_amount` DECIMAL(15,2) COMMENT 'Portion of the payment that remains unapplied after this application. Tracks suspense balance and supports multi-step application workflows.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this payment application record was last modified in the data warehouse. Tracks changes such as status updates or reversals.',
    CONSTRAINT pk_payment_application PRIMARY KEY(`payment_application_id`)
) COMMENT 'Junction table resolving the many-to-many relationship between premium payments and installments. Records applied amount, application date, and sequence. Enables full cash application audit trail.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` (
    `dac_transaction_id` BIGINT COMMENT 'Unique identifier for the DAC transaction record.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: DAC accounting requires calendar reference for amortization period calculation, financial reporting, and GAAP/IFRS compliance. Accounting_period denormalized, replace with FK.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: DAC accounting in multiple currencies requires currency reference for proper GAAP/IFRS reporting, amortization calculation, and financial consolidation.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: DAC transactions require LOB reference for amortization period determination, recoverability testing, and financial reporting by line of business. Lob denormalized, replace with FK.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: DAC amortization tracks by coverage for GAAP accounting, profitability analysis by coverage type, and recoverability testing.',
    `policy_id` BIGINT COMMENT 'Reference to the policy for which DAC is capitalized or amortized.',
    `premium_transaction_id` BIGINT COMMENT 'Unique identifier of the transaction in the source system, used for reconciliation and audit trail purposes.',
    `accounting_standard` STRING COMMENT 'Accounting standard under which this DAC transaction is recorded: US GAAP ASC 944, IFRS 17, or Statutory Accounting Principles.. Valid values are `US_GAAP|IFRS_17|STAT`',
    `adjustment_amount` DECIMAL(18,2) COMMENT 'Amount of adjustment to previously recorded DAC, due to policy endorsements, premium adjustments, or actuarial recalculations.',
    `amortization_amount` DECIMAL(18,2) COMMENT 'Amount of DAC amortized in this transaction, expensed over the policy term in proportion to earned premium or expected gross profits.',
    `amortization_method` STRING COMMENT 'Method used to amortize DAC: straight-line over policy term, proportional to earned premium, or proportional to expected gross profits per US GAAP ASC 944.. Valid values are `straight_line|earned_premium|expected_gross_profit`',
    `amortization_period_months` BIGINT COMMENT 'Total number of months over which the DAC asset is amortized, typically matching the policy term.',
    `approval_date` DATE COMMENT 'Date when the DAC transaction was approved by an authorized user, part of the financial control workflow.',
    `approved_by_user_code` STRING COMMENT 'Identifier of the user who approved this DAC transaction, required for transactions above materiality thresholds per SOX controls.',
    `capitalized_amount` DECIMAL(18,2) COMMENT 'Total acquisition cost amount capitalized as a DAC asset for the policy, including commissions, underwriting expenses, and other deferrable costs.',
    `commission_amount` DECIMAL(18,2) COMMENT 'Commission paid to producers or agents, a primary component of deferrable acquisition costs capitalized as DAC.',
    `cost_center_code` STRING COMMENT 'Cost center or organizational unit code for financial reporting and expense allocation purposes.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this DAC transaction record was first created in the data warehouse.',
    `dac_balance` DECIMAL(18,2) COMMENT 'Remaining unamortized DAC asset balance after this transaction, representing future expense to be recognized.',
    `earned_premium_amount` DECIMAL(18,2) COMMENT 'Earned premium amount for the period, used as the basis for proportional DAC amortization when amortization method is earned premium.',
    `effective_date` DATE COMMENT 'Date from which the DAC transaction becomes effective for financial statement purposes.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this DAC transaction is posted in the financial accounting system.',
    `impairment_amount` DECIMAL(18,2) COMMENT 'Amount of DAC impairment recognized if the recoverability test indicates the asset is not recoverable from future profits.',
    `notes` STRING COMMENT 'Free-text notes or comments providing additional context about the DAC transaction, such as special adjustments or manual overrides.',
    `other_acquisition_cost_amount` DECIMAL(18,2) COMMENT 'Other deferrable acquisition costs not classified as commission or underwriting expense, included in DAC capitalization.',
    `policy_effective_date` DATE COMMENT 'Effective date of the underlying policy, used to calculate amortization schedules and DAC asset life.',
    `policy_expiration_date` DATE COMMENT 'Expiration date of the underlying policy, marking the end of the DAC amortization period.',
    `posted_by_user_code` STRING COMMENT 'Identifier of the user or system account that posted this DAC transaction to the financial ledger.',
    `product_code` STRING COMMENT 'Code identifying the specific insurance product associated with this DAC transaction.',
    `recoverability_test_date` DATE COMMENT 'Date when the DAC asset recoverability test was last performed to ensure the asset is not impaired per US GAAP ASC 944.',
    `recoverability_test_result` STRING COMMENT 'Result of the most recent DAC recoverability test: pass indicates no impairment, fail indicates write-down required.. Valid values are `pass|fail|not_tested`',
    `reversal_reason` STRING COMMENT 'Explanation for why a previously posted DAC transaction was reversed, such as data correction, policy cancellation, or accounting error.',
    `transaction_date` DATE COMMENT 'Business date when the DAC transaction occurred or was recognized for accounting purposes.',
    `transaction_number` STRING COMMENT 'Business-facing unique identifier for the DAC transaction, used in financial reporting and audit trails.',
    `transaction_status` STRING COMMENT 'Current lifecycle status of the DAC transaction in the financial ledger workflow.. Valid values are `draft|pending|posted|reversed|cancelled`',
    `transaction_type` STRING COMMENT 'Type of DAC transaction: capitalization of acquisition costs, amortization over policy term, write-off for lapsed policies, adjustment, or reversal.. Valid values are `capitalization|amortization|write_off|adjustment|reversal`',
    `underwriting_expense_amount` DECIMAL(18,2) COMMENT 'Underwriting and policy issuance expenses that are deferrable and included in the DAC capitalization.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this DAC transaction record was last modified in the data warehouse.',
    `write_off_amount` DECIMAL(18,2) COMMENT 'Amount of DAC written off due to policy cancellation, lapse, or other termination event before the end of the policy term.',
    `written_premium_amount` DECIMAL(18,2) COMMENT 'Written premium amount for the policy, used to calculate the DAC capitalization rate and amortization schedule.',
    CONSTRAINT pk_dac_transaction PRIMARY KEY(`dac_transaction_id`)
) COMMENT 'Deferred Acquisition Cost transaction recording capitalized and amortized DAC amounts per policy. Tracks DAC asset balance, amortization schedule, and write-off events per US GAAP ASC 944 and IFRS 17.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` (
    `minimum_earned_premium_id` BIGINT COMMENT 'Unique identifier for the minimum earned premium threshold record.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: MEP amounts must reference currency for proper calculation, regulatory compliance, and multi-currency policy handling. Currency_code denormalized, replace with FK.',
    `jurisdiction_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: MEP rules are jurisdiction-specific, driven by state regulatory mandates, filing requirements, and cancellation penalty rules. Jurisdiction_code denormalized, replace with FK.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: MEP rules vary by LOB for regulatory compliance and risk management. Lob denormalized, replace with FK.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Reference to the specific coverage to which this MEP threshold applies, if coverage-level MEP is enforced.',
    `policy_id` BIGINT COMMENT 'Reference to the policy to which this MEP threshold applies.',
    `applies_to_cancellation_type` STRING COMMENT 'Specifies the cancellation types to which this MEP threshold applies: insured-requested, underwriter-initiated, non-payment, or all.. Valid values are `insured_request|underwriter_cancellation|non_payment|all_cancellations`',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this MEP threshold record was first created in the system.',
    `effective_date` DATE COMMENT 'The date from which this MEP threshold becomes effective for the policy or coverage.',
    `expiration_date` DATE COMMENT 'The date on which this MEP threshold expires or is superseded by a new threshold.',
    `filing_approval_date` DATE COMMENT 'The date on which the state DOI approved the filing containing this MEP threshold.',
    `filing_reference_number` STRING COMMENT 'The regulatory filing reference number under which this MEP threshold was approved by the state DOI.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The date and time when this MEP threshold record was last updated.',
    `mep_amount` DECIMAL(15,2) COMMENT 'The minimum earned premium amount that must be retained upon policy cancellation or short-rate endorsement.',
    `mep_calculation_method` STRING COMMENT 'The method used to calculate the minimum earned premium: flat amount, percentage of written premium, or the greater of the two.. Valid values are `flat_amount|percentage_of_wp|greater_of_amount_or_percentage|short_rate_table|pro_rata_with_floor`',
    `mep_percentage` DECIMAL(5,2) COMMENT 'The minimum earned premium expressed as a percentage of the total written premium (WP) that must be retained.',
    `mep_waiver_reason_code` STRING COMMENT 'Code representing the reason for waiving or reducing the MEP threshold, if applicable.',
    `minimum_earned_premium_status` STRING COMMENT 'Current lifecycle status of this MEP threshold record.. Valid values are `active|inactive|pending_approval|superseded|expired`',
    `modified_by_user_code` STRING COMMENT 'The user ID of the person who last modified this MEP threshold record.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding this MEP threshold, including special conditions or business rationale.',
    `override_allowed_flag` BOOLEAN COMMENT 'Indicates whether underwriters are permitted to override this MEP threshold under specific circumstances.',
    `override_authority_level` STRING COMMENT 'The minimum authority level required to override this MEP threshold, if overrides are allowed.. Valid values are `underwriter|senior_underwriter|uw_manager|vp_underwriting|none`',
    `policy_term_months` BIGINT COMMENT 'The policy term length in months for which this MEP threshold is defined, if term-specific.',
    `product_code` STRING COMMENT 'The insurance product code to which this MEP threshold applies, linking to the product catalog.',
    `regulatory_mandate_flag` BOOLEAN COMMENT 'Indicates whether this MEP threshold is mandated by state or federal regulation (true) or is a contractual/company policy (false).',
    `short_rate_penalty_percentage` DECIMAL(5,2) COMMENT 'The short-rate penalty percentage applied in addition to the MEP when the insured cancels mid-term.',
    `version_number` BIGINT COMMENT 'Version number of this MEP threshold record, incremented with each modification for audit trail purposes.',
    CONSTRAINT pk_minimum_earned_premium PRIMARY KEY(`minimum_earned_premium_id`)
) COMMENT 'Defines the minimum earned premium (MEP) threshold per policy or coverage. Enforces MEP on short-rate cancellations and ensures minimum retained premium per regulatory and contractual requirements.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` (
    `surplus_lines_tax_id` BIGINT COMMENT 'Unique identifier for the surplus lines tax record.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Surplus lines tax amounts require currency reference for proper accounting, payment processing, and multi-currency tax calculation. Currency_code denormalized, replace with FK.',
    `policy_id` BIGINT COMMENT 'Reference to the non-admitted policy subject to surplus lines tax.',
    `tax_jurisdiction_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Surplus lines tax calculation is state-specific, requires state reference for tax rates, stamping office assignment, filing requirements, and regulatory compliance.',
    `adjustment_amount` DECIMAL(18,2) COMMENT 'Any adjustment amount applied to the original tax calculation due to endorsements, cancellations, or corrections.',
    `adjustment_reason` STRING COMMENT 'Explanation of the reason for any tax adjustment.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this surplus lines tax record was first created in the system.',
    `diligent_search_completed_flag` BOOLEAN COMMENT 'Indicates whether the required diligent search for admitted market coverage was completed before placing in surplus lines.',
    `diligent_search_date` DATE COMMENT 'Date on which the diligent search for admitted market coverage was completed.',
    `diligent_search_documentation_reference` STRING COMMENT 'Reference identifier to the diligent search documentation maintained for regulatory compliance.',
    `exemption_code` STRING COMMENT 'Code identifying any state-specific exemption or waiver applied to this surplus lines tax obligation.',
    `exemption_reason` STRING COMMENT 'Description of the reason for any exemption or waiver from surplus lines tax.',
    `filing_period_end_date` DATE COMMENT 'End date of the reporting period for which this surplus lines tax is being filed.',
    `filing_period_start_date` DATE COMMENT 'Start date of the reporting period for which this surplus lines tax is being filed.',
    `gwp_subject_to_tax` DECIMAL(18,2) COMMENT 'Total gross written premium amount on which surplus lines tax is calculated.',
    `home_state_allocation_percent` DECIMAL(5,4) COMMENT 'Percentage of premium allocated to the insured home state under NRRA multi-state allocation rules.',
    `interest_amount` DECIMAL(18,2) COMMENT 'Interest amount accrued on overdue surplus lines tax obligations.',
    `multi_state_allocation_flag` BOOLEAN COMMENT 'Indicates whether this policy requires multi-state premium allocation for surplus lines tax purposes.',
    `nonadmitted_insurer_naic_code` STRING COMMENT 'Five-digit NAIC company code identifying the nonadmitted insurer that issued the policy.. Valid values are `^[0-9]{5}$`',
    `nonadmitted_insurer_name` STRING COMMENT 'Legal name of the nonadmitted insurer that issued the surplus lines policy.',
    `notes` STRING COMMENT 'Free-form notes or comments related to the surplus lines tax record for internal reference.',
    `payment_reference_number` STRING COMMENT 'Reference number or transaction identifier for the tax and fee payment remittance.',
    `penalty_amount` DECIMAL(18,2) COMMENT 'Penalty amount assessed for late filing or late payment of surplus lines tax.',
    `policy_effective_date` DATE COMMENT 'Effective date of the non-admitted policy for which surplus lines tax is calculated.',
    `policy_expiration_date` DATE COMMENT 'Expiration date of the non-admitted policy.',
    `stamping_fee_amount` DECIMAL(18,2) COMMENT 'Calculated stamping office fee amount due for processing the surplus lines policy.',
    `stamping_fee_rate_percent` DECIMAL(5,4) COMMENT 'Stamping office fee rate expressed as a percentage of gross written premium.',
    `stamping_office_code` STRING COMMENT 'Code identifying the state-authorized surplus lines stamping office responsible for processing and collecting tax.',
    `stamping_office_name` STRING COMMENT 'Name of the surplus lines stamping office entity.',
    `surplus_lines_broker_license_number` STRING COMMENT 'License number of the surplus lines broker who placed the non-admitted policy.',
    `surplus_lines_broker_name` STRING COMMENT 'Name of the surplus lines broker responsible for placing the policy and remitting tax.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Calculated surplus lines tax amount due to the state.',
    `tax_calculation_date` DATE COMMENT 'Date on which the surplus lines tax and stamping fee were calculated.',
    `tax_filed_date` DATE COMMENT 'Actual date on which the surplus lines tax filing was submitted to the state or stamping office.',
    `tax_filing_due_date` DATE COMMENT 'Regulatory due date by which the surplus lines tax filing must be submitted to the state.',
    `tax_paid_date` DATE COMMENT 'Actual date on which the surplus lines tax and stamping fee payment was remitted.',
    `tax_payment_due_date` DATE COMMENT 'Regulatory due date by which the surplus lines tax and stamping fee payment must be remitted.',
    `tax_rate_percent` DECIMAL(5,4) COMMENT 'State-specific surplus lines tax rate expressed as a percentage of gross written premium.',
    `tax_status` STRING COMMENT 'Current lifecycle status of the surplus lines tax obligation.. Valid values are `pending|calculated|filed|paid|overdue|waived`',
    `total_tax_and_fee_amount` DECIMAL(18,2) COMMENT 'Combined total of surplus lines tax and stamping fee due.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this surplus lines tax record was last modified.',
    CONSTRAINT pk_surplus_lines_tax PRIMARY KEY(`surplus_lines_tax_id`)
) COMMENT 'Surplus lines tax and stamping fee record per non-admitted policy. Captures state-specific tax rates, stamping office fees, diligent search requirements, and remittance due dates per state DOI surplus lines regulations.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` (
    `finance_agreement_id` BIGINT COMMENT 'Unique identifier for the premium finance agreement record.',
    `billing_account_id` BIGINT COMMENT 'Reference to the billing account associated with this finance agreement.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Premium finance agreements must reference currency for interest calculation, payment processing, and multi-currency financing. Currency_code denormalized, replace with FK.',
    `insured_id` BIGINT COMMENT 'Reference to the insured party who is the borrower under this finance agreement.',
    `policy_id` BIGINT COMMENT 'Reference to the insurance policy being financed through this agreement.',
    `agreement_number` STRING COMMENT 'Externally-known unique identifier assigned by the finance company for this agreement.. Valid values are `^[A-Z0-9]{8,20}$`',
    `agreement_signed_date` DATE COMMENT 'Date when the finance agreement was executed and signed by all parties.',
    `agreement_status` STRING COMMENT 'Current lifecycle status of the premium finance agreement.. Valid values are `pending|active|paid_in_full|defaulted|cancelled|suspended`',
    `agreement_type` STRING COMMENT 'Classification of the finance agreement based on the type of policy or borrower segment.. Valid values are `standard|commercial|personal|specialty`',
    `annual_percentage_rate` DECIMAL(5,2) COMMENT 'Annualized interest rate charged on the financed amount, expressed as a percentage.',
    `cancellation_date` DATE COMMENT 'Date when the finance agreement was cancelled due to default, early payoff, or other reason.',
    `cancellation_notice_days` BIGINT COMMENT 'Number of days advance notice required before the finance company may cancel the policy for non-payment.',
    `cancellation_reason_code` STRING COMMENT 'Code indicating the reason the finance agreement was cancelled.. Valid values are `default|early_payoff|policy_cancelled|mutual_agreement|other`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this finance agreement record was first created in the system.',
    `default_date` DATE COMMENT 'Date when the finance agreement was declared in default due to non-payment or breach of terms.',
    `delinquency_days` BIGINT COMMENT 'Number of days the finance agreement has been in delinquent status due to missed payments.',
    `down_payment_amount` DECIMAL(15,2) COMMENT 'Initial payment made by the insured at the inception of the finance agreement.',
    `effective_date` DATE COMMENT 'Date when the finance agreement becomes binding and the financing begins.',
    `expiration_date` DATE COMMENT 'Date when the finance agreement is scheduled to conclude and all obligations are due.',
    `final_installment_due_date` DATE COMMENT 'Date when the final installment payment is due, completing the repayment schedule.',
    `finance_company_party_code` BIGINT COMMENT 'Reference to the third-party premium finance company providing the financing.',
    `financed_premium_amount` DECIMAL(15,2) COMMENT 'Total insurance premium amount being financed by the finance company.',
    `first_installment_due_date` DATE COMMENT 'Date when the first installment payment is due under the finance agreement.',
    `grace_period_days` BIGINT COMMENT 'Number of days after the due date during which payment may be made without penalty.',
    `installment_amount` DECIMAL(15,2) COMMENT 'Fixed amount due for each scheduled installment payment under the finance agreement.',
    `installment_frequency` STRING COMMENT 'Frequency at which installment payments are scheduled to be made.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `interest_rate_percent` DECIMAL(5,2) COMMENT 'Periodic interest rate applied to the outstanding balance, expressed as a percentage.',
    `last_payment_amount` DECIMAL(15,2) COMMENT 'Amount of the most recent payment received and applied to the finance agreement.',
    `last_payment_date` DATE COMMENT 'Date when the most recent payment was received and applied to the finance agreement.',
    `late_fee_amount` DECIMAL(15,2) COMMENT 'Fee charged for late or missed installment payments under the finance agreement terms.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this finance agreement record was last updated in the system.',
    `next_payment_due_amount` DECIMAL(15,2) COMMENT 'Amount due for the next scheduled installment payment.',
    `next_payment_due_date` DATE COMMENT 'Date when the next scheduled installment payment is due.',
    `number_of_installments` BIGINT COMMENT 'Total count of scheduled repayment installments over the term of the finance agreement.',
    `outstanding_balance_amount` DECIMAL(15,2) COMMENT 'Current unpaid principal and interest balance remaining on the finance agreement.',
    `past_due_amount` DECIMAL(15,2) COMMENT 'Total amount of installment payments that are overdue and unpaid.',
    `payoff_amount` DECIMAL(15,2) COMMENT 'Total amount required to satisfy and close the finance agreement, including principal, interest, and fees.',
    `payoff_date` DATE COMMENT 'Date when the finance agreement was paid in full and all obligations satisfied.',
    `power_of_attorney_flag` BOOLEAN COMMENT 'Indicates whether the finance company holds power of attorney to cancel the policy for non-payment.',
    `total_amount_financed` DECIMAL(15,2) COMMENT 'Net amount provided to the insured after down payment, equal to financed premium minus down payment.',
    `total_finance_charge_amount` DECIMAL(15,2) COMMENT 'Total interest and fees charged by the finance company over the life of the agreement.',
    `total_paid_amount` DECIMAL(15,2) COMMENT 'Cumulative amount paid by the insured toward the finance agreement to date.',
    `total_repayment_amount` DECIMAL(15,2) COMMENT 'Total amount the insured must repay including principal and finance charges.',
    CONSTRAINT pk_finance_agreement PRIMARY KEY(`finance_agreement_id`)
) COMMENT 'Records premium financing arrangements where a third-party premium finance company funds the policy premium. Tracks financed amount, interest rate, repayment schedule, and power-of-attorney cancellation rights.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` (
    `premium_rate_filing_id` BIGINT COMMENT 'Unique identifier for the premium rate filing record. Primary key.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Rate filings are LOB-specific regulatory submissions requiring LOB reference for statutory line classification and actuarial analysis. Lob denormalized, replace with FK.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Rate filings are state-specific regulatory submissions requiring state reference for DOI tracking, approval workflow, and compliance monitoring. State_code denormalized, replace with FK.',
    `actuarial_justification` STRING COMMENT 'Summary of the actuarial analysis and justification supporting the proposed rate change, including loss experience and trend factors.',
    `actuary_credential` STRING COMMENT 'Professional actuarial credential of the certifying actuary, such as FCAS, ACAS, FSA, ASA, MAAA.',
    `actuary_name` STRING COMMENT 'Name of the credentialed actuary who prepared and certified the rate filing analysis.',
    `affected_policy_count` BIGINT COMMENT 'Estimated number of policies that will be impacted by the rate change upon approval and implementation.',
    `approval_date` DATE COMMENT 'Date when the state Department of Insurance approved the rate filing. Null if not yet approved or if rejected.',
    `certification_date` DATE COMMENT 'Date when the actuary certified the rate filing analysis and supporting documentation.',
    `competitive_impact_analysis` STRING COMMENT 'Summary of the competitive market impact analysis showing how the proposed rates compare to market competitors.',
    `consumer_impact_statement` STRING COMMENT 'Statement describing the expected impact of the rate change on policyholders and consumers in the affected market.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the rate filing record was first created in the system.',
    `effective_date` DATE COMMENT 'Date when the approved rates become effective and can be applied to new and renewal policies.',
    `expiration_date` DATE COMMENT 'Date when the filed rates expire and can no longer be used, if applicable. Null for indefinite filings.',
    `filing_description` STRING COMMENT 'Detailed description of the rate filing purpose, scope, and key changes being proposed to the regulator.',
    `filing_fee_amount` DECIMAL(18,2) COMMENT 'Regulatory filing fee amount paid to the state Department of Insurance for processing the rate filing.',
    `filing_fee_paid_flag` BOOLEAN COMMENT 'Indicates whether the required filing fee has been paid to the state regulator. True if paid, False if outstanding.',
    `filing_method` STRING COMMENT 'Regulatory filing method required by the state: file and use, prior approval, use and file, flex rating, or no file required.. Valid values are `file_and_use|prior_approval|use_and_file|flex_rating|no_file`',
    `filing_number` STRING COMMENT 'Unique regulatory filing number assigned by the state Department of Insurance (DOI) or insurer for tracking the rate filing submission.',
    `filing_status` STRING COMMENT 'Current lifecycle status of the rate filing with the regulatory authority: draft, submitted, under review, approved, rejected, withdrawn, or deferred. [ENUM-REF-CANDIDATE: draft|submitted|under_review|approved|rejected|withdrawn|deferred — 7 candidates',
    `filing_type` STRING COMMENT 'Type of regulatory filing being submitted: rate change, new program introduction, rule modification, form filing, combined rate and rule, or withdrawal.. Valid values are `rate_change|new_program|rule_change|form_filing|rate_and_rule|withdrawal`',
    `indicated_rate_change_percentage` DECIMAL(10,4) COMMENT 'Actuarially indicated rate change percentage based on loss experience analysis, before any capping or phasing adjustments.',
    `insurer_response` STRING COMMENT 'Insurers formal response to regulator comments, questions, or objections during the filing review process.',
    `iso_program_code` STRING COMMENT 'ISO program code if the filing uses or references ISO rating content, forms, or rules.',
    `loss_ratio_target` DECIMAL(10,4) COMMENT 'Target loss ratio the rate filing is designed to achieve, expressed as a decimal (e.g., 0.6500 for 65%).',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the rate filing record was last modified or updated in the system.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code identifying the legal insurance entity submitting the rate filing.',
    `objection_period_end_date` DATE COMMENT 'Date when the regulatory objection period ends, after which the filing is deemed approved if no objections are raised.',
    `prior_filing_number` STRING COMMENT 'Filing number of the previous rate filing for this line of business and state, establishing the baseline for the current change.',
    `rate_change_percentage` DECIMAL(10,4) COMMENT 'Overall percentage change in rates being proposed in this filing, expressed as a decimal (e.g., 0.0750 for 7.5% increase, -0.0300 for 3% decrease).',
    `rate_change_type` STRING COMMENT 'Direction of the rate change: increase, decrease, no change, or variable by segment.. Valid values are `increase|decrease|no_change|variable`',
    `rate_impact_amount` DECIMAL(18,2) COMMENT 'Estimated dollar impact of the rate change on total written premium for the affected line of business and state.',
    `rate_manual_version` STRING COMMENT 'Version identifier of the rate manual or rating algorithm being filed for regulatory approval.',
    `regulator_comments` STRING COMMENT 'Comments, questions, or objections provided by the state Department of Insurance during the review process.',
    `rejection_date` DATE COMMENT 'Date when the state Department of Insurance rejected the rate filing. Null if approved or still under review.',
    `serff_tracking_number` STRING COMMENT 'SERFF system tracking number used by NAIC for electronic rate and form filing submissions to state regulators.',
    `submission_date` DATE COMMENT 'Date when the rate filing was officially submitted to the state Department of Insurance for review.',
    `superseded_filing_number` STRING COMMENT 'Filing number of any filing that this rate filing supersedes or replaces upon approval.',
    `supporting_document_count` BIGINT COMMENT 'Number of supporting documents submitted with the rate filing, including actuarial memoranda, rate manuals, and exhibits.',
    `withdrawal_date` DATE COMMENT 'Date when the insurer voluntarily withdrew the rate filing from regulatory review. Null if not withdrawn.',
    CONSTRAINT pk_premium_rate_filing PRIMARY KEY(`premium_rate_filing_id`)
) COMMENT 'Tracks state rate and rule filing submissions to DOI: filing number, LOB, effective date, approval status, SERFF tracking number, and rate change percentage. SSOT for regulatory rate approval lifecycle.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` (
    `agency_bill_statement_id` BIGINT COMMENT 'Unique identifier for the agency bill statement record.',
    `agency_id` BIGINT COMMENT 'Reference to the agency entity for which this bill statement is generated.',
    `billing_account_id` BIGINT COMMENT 'Reference to the billing account associated with this agency bill statement.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Agency billing statements require currency reference for commission calculation, payment processing, and multi-currency agency operations. Currency_code denormalized, replace with FK.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producing agent or broker receiving this statement.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Agency billing is often state-specific for regulatory reporting, commission tax calculation, and producer licensing compliance. State_code denormalized, replace with FK.',
    `adjustment_amount` DECIMAL(18,2) COMMENT 'Total adjustments applied to the statement, including endorsements, cancellations, and corrections from prior periods.',
    `balance_forward_amount` DECIMAL(18,2) COMMENT 'Outstanding balance carried forward from the previous agency bill statement period.',
    `billing_method` STRING COMMENT 'The billing arrangement method used for this statement, indicating whether the agency collects premium or the insurer bills directly.. Valid values are `direct_bill|agency_bill|list_bill|account_current`',
    `cancellation_count` BIGINT COMMENT 'Number of policy cancellations processed during the statement period that affected premium and are included in this bill.',
    `commission_amount` DECIMAL(18,2) COMMENT 'Total commission earned by the producer on the premiums included in this statement.',
    `commission_rate_percent` DECIMAL(5,2) COMMENT 'The average or blended commission rate percentage applied to calculate the commission amount for this statement.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this agency bill statement record was first created in the system.',
    `current_balance_amount` DECIMAL(18,2) COMMENT 'The current outstanding balance on the agency bill statement after applying all transactions and payments.',
    `delinquency_days` BIGINT COMMENT 'Number of days the statement balance is past due, calculated from the due date to the current date.',
    `due_date` DATE COMMENT 'The date by which the net amount due must be paid by the producer to avoid delinquency.',
    `endorsement_count` BIGINT COMMENT 'Number of policy endorsements processed during the statement period that affected premium and are included in this bill.',
    `fees_amount` DECIMAL(18,2) COMMENT 'Total fees charged on the policies included in this statement, such as policy fees or installment fees.',
    `gwp_amount` DECIMAL(18,2) COMMENT 'Total gross written premium for all policies included in this agency bill statement before any deductions.',
    `issued_by_user_code` STRING COMMENT 'Identifier of the system user or automated process that issued this agency bill statement.',
    `lob_summary` STRING COMMENT 'Comma-separated list or summary of lines of business included in this agency bill statement for reference and categorization.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this agency bill statement record was last modified or updated.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code identifying the insurance carrier issuing this agency bill statement.. Valid values are `^[0-9]{5}$`',
    `net_amount_due` DECIMAL(18,2) COMMENT 'The net balance owed by the producer to the insurer or vice versa after all premiums, commissions, taxes, fees, and adjustments.',
    `new_business_count` BIGINT COMMENT 'Number of new business policies written during the statement period and included in this bill.',
    `notes` STRING COMMENT 'Free-text notes or comments related to this agency bill statement, including special instructions or dispute details.',
    `nwp_amount` DECIMAL(18,2) COMMENT 'Net written premium after deducting commissions and other adjustments, representing the amount due to the insurer.',
    `payment_received_amount` DECIMAL(18,2) COMMENT 'Total payments received from the producer during the statement period, applied against the outstanding balance.',
    `payment_terms_days` BIGINT COMMENT 'Number of days from the statement date within which payment is expected, defining the payment terms for the producer.',
    `policy_count` BIGINT COMMENT 'Total number of policies included in this agency bill statement for the billing period.',
    `premium_tax_amount` DECIMAL(18,2) COMMENT 'Total premium taxes applicable to the policies included in this agency bill statement.',
    `producer_contact_email` STRING COMMENT 'Email address of the primary contact person at the producer agency for statement correspondence.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `producer_contact_name` STRING COMMENT 'Name of the primary contact person at the producer agency for inquiries related to this statement.',
    `producer_contact_phone` STRING COMMENT 'Phone number of the primary contact person at the producer agency for statement inquiries.',
    `reconciliation_status` STRING COMMENT 'Status indicating whether the agency bill statement has been reconciled with producer records and payments.. Valid values are `pending|reconciled|disputed|adjusted`',
    `renewal_count` BIGINT COMMENT 'Number of renewal policies processed during the statement period and included in this bill.',
    `statement_date` DATE COMMENT 'The date on which the agency bill statement was generated and issued to the producer.',
    `statement_delivery_method` STRING COMMENT 'The method by which this agency bill statement was delivered to the producer.. Valid values are `email|postal_mail|portal|fax`',
    `statement_format` STRING COMMENT 'The file format in which the agency bill statement was generated and delivered.. Valid values are `pdf|csv|xml|html`',
    `statement_number` STRING COMMENT 'Unique business identifier for the agency bill statement, typically formatted as a sequential or date-based code.',
    `statement_period_end_date` DATE COMMENT 'The ending date of the billing period covered by this agency bill statement.',
    `statement_period_start_date` DATE COMMENT 'The beginning date of the billing period covered by this agency bill statement.',
    `statement_status` STRING COMMENT 'Current lifecycle status of the agency bill statement indicating its payment and processing state.. Valid values are `draft|issued|paid|partially_paid|overdue|cancelled`',
    CONSTRAINT pk_agency_bill_statement PRIMARY KEY(`agency_bill_statement_id`)
) COMMENT 'Monthly agency bill statement sent to producing agents/brokers summarizing net premiums due, commissions retained, and balance owed. Supports agency bill reconciliation and producer account settlement.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ADD CONSTRAINT `fk_premium_earned_premium_original_earned_premium_id` FOREIGN KEY (`original_earned_premium_id`) REFERENCES `vibe_pc_insurance_v499`.`premium`.`earned_premium`(`earned_premium_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ADD CONSTRAINT `fk_premium_earned_premium_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_installment_schedule_id` FOREIGN KEY (`installment_schedule_id`) REFERENCES `vibe_pc_insurance_v499`.`premium`.`installment_schedule`(`installment_schedule_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_reversed_transaction_premium_transaction_id` FOREIGN KEY (`reversed_transaction_premium_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ADD CONSTRAINT `fk_premium_installment_schedule_billing_account_id` FOREIGN KEY (`billing_account_id`) REFERENCES `vibe_pc_insurance_v499`.`premium`.`billing_account`(`billing_account_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ADD CONSTRAINT `fk_premium_installment_installment_schedule_id` FOREIGN KEY (`installment_schedule_id`) REFERENCES `vibe_pc_insurance_v499`.`premium`.`installment_schedule`(`installment_schedule_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ADD CONSTRAINT `fk_premium_payment_billing_account_id` FOREIGN KEY (`billing_account_id`) REFERENCES `vibe_pc_insurance_v499`.`premium`.`billing_account`(`billing_account_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ADD CONSTRAINT `fk_premium_payment_installment_schedule_id` FOREIGN KEY (`installment_schedule_id`) REFERENCES `vibe_pc_insurance_v499`.`premium`.`installment_schedule`(`installment_schedule_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ADD CONSTRAINT `fk_premium_payment_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ADD CONSTRAINT `fk_premium_payment_application_installment_id` FOREIGN KEY (`installment_id`) REFERENCES `vibe_pc_insurance_v499`.`premium`.`installment`(`installment_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ADD CONSTRAINT `fk_premium_payment_application_payment_id` FOREIGN KEY (`payment_id`) REFERENCES `vibe_pc_insurance_v499`.`premium`.`payment`(`payment_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ADD CONSTRAINT `fk_premium_payment_application_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ADD CONSTRAINT `fk_premium_dac_transaction_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ADD CONSTRAINT `fk_premium_finance_agreement_billing_account_id` FOREIGN KEY (`billing_account_id`) REFERENCES `vibe_pc_insurance_v499`.`premium`.`billing_account`(`billing_account_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ADD CONSTRAINT `fk_premium_agency_bill_statement_billing_account_id` FOREIGN KEY (`billing_account_id`) REFERENCES `vibe_pc_insurance_v499`.`premium`.`billing_account`(`billing_account_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_v499`.`premium` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_v499`.`premium` SET TAGS ('dbx_domain' = 'premium');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` SET TAGS ('dbx_subdomain' = 'premium_accounting');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `written_premium_id` SET TAGS ('dbx_business_glossary_term' = 'Written Premium (WP) ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Country Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `ceded_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `experience_mod_factor` SET TAGS ('dbx_business_glossary_term' = 'Experience Modification (Mod) Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `exposure_basis` SET TAGS ('dbx_business_glossary_term' = 'Exposure Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `exposure_units` SET TAGS ('dbx_business_glossary_term' = 'Exposure Units');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `gwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `installment_count` SET TAGS ('dbx_business_glossary_term' = 'Installment Count');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `installment_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Installment Fee Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `is_audit_premium` SET TAGS ('dbx_business_glossary_term' = 'Is Audit Premium Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `is_installment_plan` SET TAGS ('dbx_business_glossary_term' = 'Is Installment Plan Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `manual_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Manual Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `nwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Written Premium (NWP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `policy_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Policy Fee Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `policy_term_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `policy_term_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `premium_basis_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Basis Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `premium_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Tax Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `product_code` SET TAGS ('dbx_business_glossary_term' = 'Product Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `rate_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Rate Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `rate_version` SET TAGS ('dbx_business_glossary_term' = 'Rate Version');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `rating_plan_code` SET TAGS ('dbx_business_glossary_term' = 'Rating Plan Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `rating_plan_code` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `rating_plan_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `reversal_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `schedule_credit_amount` SET TAGS ('dbx_business_glossary_term' = 'Schedule Credit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `schedule_debit_amount` SET TAGS ('dbx_business_glossary_term' = 'Schedule Debit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `statutory_reporting_period` SET TAGS ('dbx_business_glossary_term' = 'Statutory Reporting Period');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `statutory_reporting_period` SET TAGS ('dbx_value_regex' = '^d{4}-Q[1-4]$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `statutory_reporting_period` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `statutory_reporting_period` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `total_billed_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Billed Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `transaction_booking_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Booking Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `transaction_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'new_business|renewal|endorsement|cancellation|reinstatement|audit_adjustment');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `underwriter_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriter ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `written_premium_status` SET TAGS ('dbx_business_glossary_term' = 'Written Premium Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ALTER COLUMN `written_premium_status` SET TAGS ('dbx_value_regex' = 'booked|pending|reversed|adjusted|voided');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` SET TAGS ('dbx_subdomain' = 'premium_accounting');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `earned_premium_id` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Country Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `original_earned_premium_id` SET TAGS ('dbx_business_glossary_term' = 'Original Earned Premium (EP) Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Source Transaction Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `adjustment_description` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Description');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `adjustment_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `ceded_ep_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `dac_amount` SET TAGS ('dbx_business_glossary_term' = 'Deferred Acquisition Cost (DAC) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `earned_premium_status` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `earned_premium_status` SET TAGS ('dbx_value_regex' = 'draft|posted|reversed|adjusted|final');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `earning_method` SET TAGS ('dbx_business_glossary_term' = 'Premium Earning Method');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `earning_method` SET TAGS ('dbx_value_regex' = 'pro_rata|short_rate|daily|monthly|custom');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `earning_percentage` SET TAGS ('dbx_business_glossary_term' = 'Earning Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `earning_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `earning_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Earning Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `ep_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Currency Exchange Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Earning Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `exposure_days` SET TAGS ('dbx_business_glossary_term' = 'Exposure Days Count');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `gaap_revenue_amount` SET TAGS ('dbx_business_glossary_term' = 'Generally Accepted Accounting Principles (GAAP) Revenue Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `gwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `ifrs17_revenue_amount` SET TAGS ('dbx_business_glossary_term' = 'International Financial Reporting Standard 17 (IFRS 17) Revenue Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `net_ep_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `nwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Written Premium (NWP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `policy_term_months` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Duration in Months');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `posting_date` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Posting Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `posting_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `posting_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `premium_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Tax Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `premium_tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Premium Tax Rate Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Reversal Flag Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `statutory_line_code` SET TAGS ('dbx_business_glossary_term' = 'Statutory Line Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'new_business|renewal|endorsement|cancellation|reinstatement|audit');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `uep_amount` SET TAGS ('dbx_business_glossary_term' = 'Unearned Premium (UEP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` SET TAGS ('dbx_subdomain' = 'premium_accounting');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `endorsement_id` SET TAGS ('dbx_business_glossary_term' = 'Endorsement ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `installment_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Installment Plan ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Cancellation ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `reversed_transaction_premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Reversed Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `risk_state_id` SET TAGS ('dbx_business_glossary_term' = 'Risk State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `audit_code` SET TAGS ('dbx_business_glossary_term' = 'Premium Audit ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `booking_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Booking Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `ceded_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `coverage_part_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `coverage_part_code` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `coverage_part_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `dac_amount` SET TAGS ('dbx_business_glossary_term' = 'Deferred Acquisition Cost (DAC) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Premium Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `earned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Exchange Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `exposure_units` SET TAGS ('dbx_business_glossary_term' = 'Exposure Units');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Policy Fee Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `gwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `installment_number` SET TAGS ('dbx_business_glossary_term' = 'Installment Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `nwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Written Premium (NWP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `payment_received_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Received Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `rate_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Rate Per Unit');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `reason_code` SET TAGS ('dbx_business_glossary_term' = 'Transaction Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Reversal Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `statutory_line_code` SET TAGS ('dbx_business_glossary_term' = 'Statutory Line Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Tax Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `total_billed_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Billed Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `transaction_description` SET TAGS ('dbx_business_glossary_term' = 'Transaction Description');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `transaction_number` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_value_regex' = 'pending|posted|reversed|voided|cancelled');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ALTER COLUMN `unearned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Unearned Premium (UEP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` SET TAGS ('dbx_subdomain' = 'rating_calculation');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_element_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Element Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_business_glossary_term' = 'Product Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `calculation_formula` SET TAGS ('dbx_business_glossary_term' = 'Calculation Formula');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `cat_loading_factor` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Loading Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_element_category` SET TAGS ('dbx_business_glossary_term' = 'Rate Element Category');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_element_category` SET TAGS ('dbx_value_regex' = 'manual_rate|experience_rating|schedule_rating|catastrophe_loading|expense_provision|profit_margin');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `class_code` SET TAGS ('dbx_business_glossary_term' = 'Class Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `class_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_element_code` SET TAGS ('dbx_business_glossary_term' = 'Rate Element Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_element_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `coverage_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `coverage_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `coverage_code` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `coverage_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `credibility_factor` SET TAGS ('dbx_business_glossary_term' = 'Credibility Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `deductible_credit_factor` SET TAGS ('dbx_business_glossary_term' = 'Deductible Credit Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `default_value` SET TAGS ('dbx_business_glossary_term' = 'Default Rate Value');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_element_description` SET TAGS ('dbx_business_glossary_term' = 'Rate Element Description');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `expense_provision` SET TAGS ('dbx_business_glossary_term' = 'Expense Provision');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `filing_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `increased_limits_factor` SET TAGS ('dbx_business_glossary_term' = 'Increased Limits Factor (ILF)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `is_filed` SET TAGS ('dbx_business_glossary_term' = 'Filed Rate Element Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Rate Element Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `loss_cost` SET TAGS ('dbx_business_glossary_term' = 'Loss Cost');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `maximum_value` SET TAGS ('dbx_business_glossary_term' = 'Maximum Rate Value');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `minimum_value` SET TAGS ('dbx_business_glossary_term' = 'Minimum Rate Value');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System (NAICS) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `naics_code` SET TAGS ('dbx_value_regex' = '^[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_element_name` SET TAGS ('dbx_business_glossary_term' = 'Rate Element Name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_element_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_element_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Rate Element Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `profit_margin` SET TAGS ('dbx_business_glossary_term' = 'Profit and Contingency Margin');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_basis` SET TAGS ('dbx_business_glossary_term' = 'Rate Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_element_status` SET TAGS ('dbx_business_glossary_term' = 'Rate Element Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_element_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending_approval|superseded|withdrawn');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_element_type` SET TAGS ('dbx_business_glossary_term' = 'Rate Element Type');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_element_type` SET TAGS ('dbx_value_regex' = 'base_rate|class_factor|territory_multiplier|schedule_credit|schedule_debit|experience_modifier');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_filing_number` SET TAGS ('dbx_business_glossary_term' = 'Rate Filing Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_filing_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{5,30}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_source` SET TAGS ('dbx_business_glossary_term' = 'Rate Source');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_source` SET TAGS ('dbx_value_regex' = 'ISO|NCCI|PROPRIETARY|ADVISORY|BUREAU');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_table_name` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_table_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_table_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_value` SET TAGS ('dbx_business_glossary_term' = 'Rate Value');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_version` SET TAGS ('dbx_business_glossary_term' = 'Rate Version');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rate_version` SET TAGS ('dbx_value_regex' = '^[A-Z0-9.]{1,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rating_tier` SET TAGS ('dbx_business_glossary_term' = 'Rating Tier');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rating_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|substandard|declined');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rating_tier` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rating_tier` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rol_value` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL) Value');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `rpp_value` SET TAGS ('dbx_business_glossary_term' = 'Rate Per Point (RPP) Value');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification (SIC) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `sic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `territory_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `trend_factor` SET TAGS ('dbx_business_glossary_term' = 'Trend Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` SET TAGS ('dbx_subdomain' = 'rating_calculation');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_table_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `policy_rate_filing_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Filing Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `actuarial_memo_reference` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Memorandum Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `approved_by_regulator` SET TAGS ('dbx_business_glossary_term' = 'Approved by Regulator Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `class_code` SET TAGS ('dbx_business_glossary_term' = 'Class Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_table_code` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `coverage_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `coverage_code` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `coverage_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `expense_provision` SET TAGS ('dbx_business_glossary_term' = 'Expense Provision');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `filing_number` SET TAGS ('dbx_business_glossary_term' = 'Filing Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `iso_content_flag` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Content Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `iso_edition` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Edition');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `loss_cost` SET TAGS ('dbx_business_glossary_term' = 'Loss Cost');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `maximum_rate` SET TAGS ('dbx_business_glossary_term' = 'Maximum Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `minimum_rate` SET TAGS ('dbx_business_glossary_term' = 'Minimum Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_table_name` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_table_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_table_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `ncci_content_flag` SET TAGS ('dbx_business_glossary_term' = 'National Council on Compensation Insurance (NCCI) Content Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `owner` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Owner');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `profit_provision` SET TAGS ('dbx_business_glossary_term' = 'Profit and Contingency Provision');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_basis` SET TAGS ('dbx_business_glossary_term' = 'Rate Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_basis` SET TAGS ('dbx_value_regex' = 'per_unit|per_hundred|per_thousand|flat|percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_change_percent` SET TAGS ('dbx_business_glossary_term' = 'Rate Change Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_description` SET TAGS ('dbx_business_glossary_term' = 'Rate Description');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_footnote` SET TAGS ('dbx_business_glossary_term' = 'Rate Footnote');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_source` SET TAGS ('dbx_business_glossary_term' = 'Rate Source');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_source` SET TAGS ('dbx_value_regex' = 'iso|ncci|company_proprietary|state_manual|advisory_organization');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_table_status` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_table_status` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|approved|active|superseded|withdrawn');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_table_type` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Type');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Rate Unit of Measure');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_value` SET TAGS ('dbx_business_glossary_term' = 'Rate Value');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rate_version` SET TAGS ('dbx_business_glossary_term' = 'Rate Version Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rating_plan` SET TAGS ('dbx_business_glossary_term' = 'Rating Plan');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rating_plan` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rating_plan` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rating_tier` SET TAGS ('dbx_business_glossary_term' = 'Rating Tier');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rating_tier` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rating_tier` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rol_value` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL) Value');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `rpp_value` SET TAGS ('dbx_business_glossary_term' = 'Rate Per Point (RPP) Value');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `updated_by_user` SET TAGS ('dbx_business_glossary_term' = 'Updated By User');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` SET TAGS ('dbx_subdomain' = 'rating_calculation');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_worksheet_id` SET TAGS ('dbx_business_glossary_term' = 'Rating Worksheet Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_worksheet_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_worksheet_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `base_rate` SET TAGS ('dbx_business_glossary_term' = 'Base Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `calculation_notes` SET TAGS ('dbx_business_glossary_term' = 'Calculation Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `class_code` SET TAGS ('dbx_business_glossary_term' = 'Class Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `cumulative_premium` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `deductible_credit` SET TAGS ('dbx_business_glossary_term' = 'Deductible Credit');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `experience_mod` SET TAGS ('dbx_business_glossary_term' = 'Experience Modification Factor (Experience Mod)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `exposure_units` SET TAGS ('dbx_business_glossary_term' = 'Exposure Units');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `gwp` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `intermediate_premium` SET TAGS ('dbx_business_glossary_term' = 'Intermediate Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `minimum_premium` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `minimum_premium_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Applied Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `nwp` SET TAGS ('dbx_business_glossary_term' = 'Net Written Premium (NWP)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `product_code` SET TAGS ('dbx_business_glossary_term' = 'Product Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rate_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Rate Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rate_source` SET TAGS ('dbx_business_glossary_term' = 'Rate Source');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rate_source` SET TAGS ('dbx_value_regex' = 'iso|verisk|proprietary|state_manual|ncci');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_basis` SET TAGS ('dbx_business_glossary_term' = 'Rating Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_basis` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_basis` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_factor_code` SET TAGS ('dbx_business_glossary_term' = 'Rating Factor Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_factor_code` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_factor_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_factor_type` SET TAGS ('dbx_business_glossary_term' = 'Rating Factor Type');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_factor_type` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_factor_type` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_factor_value` SET TAGS ('dbx_business_glossary_term' = 'Rating Factor Value');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_factor_value` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_factor_value` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_plan_code` SET TAGS ('dbx_business_glossary_term' = 'Rating Plan Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_plan_code` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_plan_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_plan_version` SET TAGS ('dbx_business_glossary_term' = 'Rating Plan Version');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_plan_version` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_plan_version` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_status` SET TAGS ('dbx_business_glossary_term' = 'Rating Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_status` SET TAGS ('dbx_value_regex' = 'draft|calculated|approved|rejected|superseded');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_status` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_status` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_step_name` SET TAGS ('dbx_business_glossary_term' = 'Rating Step Name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_step_name` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_step_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_step_sequence` SET TAGS ('dbx_business_glossary_term' = 'Rating Step Sequence');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_step_sequence` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `rating_step_sequence` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `schedule_credit_debit` SET TAGS ('dbx_business_glossary_term' = 'Schedule Credit or Debit');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `step_premium_adjustment` SET TAGS ('dbx_business_glossary_term' = 'Step Premium Adjustment');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `taxes_and_fees` SET TAGS ('dbx_business_glossary_term' = 'Taxes and Fees');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `total_charged_premium` SET TAGS ('dbx_business_glossary_term' = 'Total Charged Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `underwriter_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `worksheet_number` SET TAGS ('dbx_business_glossary_term' = 'Worksheet Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ALTER COLUMN `worksheet_version` SET TAGS ('dbx_business_glossary_term' = 'Worksheet Version');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` SET TAGS ('dbx_subdomain' = 'payment_collection');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_account_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_country_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Country Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_currency_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_state_id` SET TAGS ('dbx_business_glossary_term' = 'Billing State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `insured_id` SET TAGS ('dbx_business_glossary_term' = 'Payer Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `account_name` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `account_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `account_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `account_number` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `account_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{8,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `account_status` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `account_status` SET TAGS ('dbx_value_regex' = 'active|suspended|delinquent|closed|cancelled');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `account_type` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Type');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `account_type` SET TAGS ('dbx_value_regex' = 'individual|commercial|agency|group');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `autopay_flag` SET TAGS ('dbx_business_glossary_term' = 'Automatic Payment (Autopay) Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Billing Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Billing Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_city` SET TAGS ('dbx_business_glossary_term' = 'Billing City');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Billing Contact Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Billing Contact Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_contact_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9]{10,15}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_method` SET TAGS ('dbx_business_glossary_term' = 'Billing Method');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_method` SET TAGS ('dbx_value_regex' = 'direct_bill|agency_bill|list_bill|account_current');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Billing Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_postal_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}(-[0-9]{4})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `billing_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Cancellation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `commission_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Record Created By User');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `current_balance_amount` SET TAGS ('dbx_business_glossary_term' = 'Current Balance Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `delinquency_days` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Days Count');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_business_glossary_term' = 'Grace Period Days');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `last_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Last Payment Received Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `last_payment_date` SET TAGS ('dbx_business_glossary_term' = 'Last Payment Received Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `last_statement_date` SET TAGS ('dbx_business_glossary_term' = 'Last Statement Issued Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `next_due_amount` SET TAGS ('dbx_business_glossary_term' = 'Next Payment Due Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `next_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Payment Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `paperless_billing_flag` SET TAGS ('dbx_business_glossary_term' = 'Paperless Billing Enrollment Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `past_due_amount` SET TAGS ('dbx_business_glossary_term' = 'Past Due Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly|custom');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `payment_plan_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `payment_plan_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `total_billed_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Billed Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `total_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Paid Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `unapplied_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Unapplied Payment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `updated_by_user` SET TAGS ('dbx_business_glossary_term' = 'Record Updated By User');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` SET TAGS ('dbx_subdomain' = 'payment_collection');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `installment_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Installment Schedule ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `billing_account_id` SET TAGS ('dbx_business_glossary_term' = 'Account ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `autopay_discount_amount` SET TAGS ('dbx_business_glossary_term' = 'Autopay Discount Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `autopay_enrolled_flag` SET TAGS ('dbx_business_glossary_term' = 'Autopay Enrolled Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `billing_method` SET TAGS ('dbx_business_glossary_term' = 'Billing Method');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `billing_method` SET TAGS ('dbx_value_regex' = 'direct_bill|agency_bill|list_bill|account_current');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `cancellation_for_nonpayment_days` SET TAGS ('dbx_business_glossary_term' = 'Cancellation for Nonpayment (CANC) Days');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `cancelled_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Cancelled Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `down_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Down Payment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `down_payment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Down Payment Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `down_payment_percentage` SET TAGS ('dbx_business_glossary_term' = 'Down Payment Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `down_payment_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `down_payment_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `eligibility_criteria` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Criteria');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `first_installment_due_date` SET TAGS ('dbx_business_glossary_term' = 'First Installment Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_business_glossary_term' = 'Grace Period Days');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `installment_count` SET TAGS ('dbx_business_glossary_term' = 'Installment Count');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `installment_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Installment Fee Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `installment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Installment Frequency');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `installment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi-annual|annual|bi-weekly');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `late_payment_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Late Payment Fee Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `maximum_premium_threshold` SET TAGS ('dbx_business_glossary_term' = 'Maximum Premium Threshold');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `minimum_premium_threshold` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Threshold');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `paperless_billing_flag` SET TAGS ('dbx_business_glossary_term' = 'Paperless Billing Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `paperless_discount_amount` SET TAGS ('dbx_business_glossary_term' = 'Paperless Discount Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `payment_method_preference` SET TAGS ('dbx_business_glossary_term' = 'Payment Method Preference');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `payment_method_preference` SET TAGS ('dbx_value_regex' = 'credit_card|debit_card|ach|check|wire_transfer|cash');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `payment_plan_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `payment_plan_name` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `payment_plan_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `payment_plan_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `reinstatement_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Fee Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `reinstatement_fee_amount` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `reinstatement_fee_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `schedule_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Schedule Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `schedule_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Schedule Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `schedule_number` SET TAGS ('dbx_business_glossary_term' = 'Schedule Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_business_glossary_term' = 'Schedule Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_value_regex' = 'active|suspended|cancelled|completed|defaulted|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `total_amount_due` SET TAGS ('dbx_business_glossary_term' = 'Total Amount Due');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `total_fees_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Fees Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `total_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` SET TAGS ('dbx_subdomain' = 'payment_collection');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `installment_id` SET TAGS ('dbx_business_glossary_term' = 'Installment Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `installment_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Schedule Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `autopay_flag` SET TAGS ('dbx_business_glossary_term' = 'Automatic Payment (Autopay) Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `billed_amount` SET TAGS ('dbx_business_glossary_term' = 'Installment Billed Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `billed_date` SET TAGS ('dbx_business_glossary_term' = 'Installment Billed Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `billing_notice_sent_flag` SET TAGS ('dbx_business_glossary_term' = 'Billing Notice Sent Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `cancellation_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Effective Date (CANC)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `cancellation_notice_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Notice Date (CANC)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `days_overdue` SET TAGS ('dbx_business_glossary_term' = 'Days Overdue');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `delinquency_status` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `delinquency_status` SET TAGS ('dbx_value_regex' = 'current|overdue|in_grace|delinquent|written_off');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Installment Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Installment Fee Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_business_glossary_term' = 'Grace Period Days');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `grace_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Grace Period End Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `grace_period_end_date` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `grace_period_end_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `installment_status` SET TAGS ('dbx_business_glossary_term' = 'Installment Payment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `installment_status` SET TAGS ('dbx_value_regex' = 'pending|billed|paid|partially_paid|overdue|cancelled');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Invoice Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `late_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Installment Late Fee Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `late_notice_sent_flag` SET TAGS ('dbx_business_glossary_term' = 'Late Notice Sent Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Installment Sequence Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `outstanding_balance` SET TAGS ('dbx_business_glossary_term' = 'Installment Outstanding Balance');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Installment Paid Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `paid_date` SET TAGS ('dbx_business_glossary_term' = 'Installment Paid Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `payment_channel` SET TAGS ('dbx_business_glossary_term' = 'Payment Channel');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `payment_channel` SET TAGS ('dbx_value_regex' = 'online|mobile_app|agent|mail|phone|in_person');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Installment Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `reminder_notice_sent_flag` SET TAGS ('dbx_business_glossary_term' = 'Reminder Notice Sent Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `reversal_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Reversal Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Payment Reversal Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `reversal_reason` SET TAGS ('dbx_business_glossary_term' = 'Payment Reversal Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Installment Tax Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `waived_date` SET TAGS ('dbx_business_glossary_term' = 'Installment Waived Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `waived_flag` SET TAGS ('dbx_business_glossary_term' = 'Installment Waived Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ALTER COLUMN `waived_reason` SET TAGS ('dbx_business_glossary_term' = 'Installment Waived Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` SET TAGS ('dbx_subdomain' = 'payment_collection');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `payment_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `billing_account_id` SET TAGS ('dbx_business_glossary_term' = 'Account Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `installment_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Payment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `applied_amount` SET TAGS ('dbx_business_glossary_term' = 'Applied Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `authorization_code` SET TAGS ('dbx_business_glossary_term' = 'Authorization Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `authorization_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `bank_name` SET TAGS ('dbx_business_glossary_term' = 'Bank Name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `bank_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `bank_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_business_glossary_term' = 'Bank Routing Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_value_regex' = '^[0-9]{9}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `channel` SET TAGS ('dbx_business_glossary_term' = 'Payment Channel');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `cleared_date` SET TAGS ('dbx_business_glossary_term' = 'Cleared Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `convenience_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Convenience Fee Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `deposit_date` SET TAGS ('dbx_business_glossary_term' = 'Deposit Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `installment_number` SET TAGS ('dbx_business_glossary_term' = 'Installment Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Modified By User');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Payment Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Payment Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `payer_account_number` SET TAGS ('dbx_business_glossary_term' = 'Payer Account Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `payer_account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `payer_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `payer_name` SET TAGS ('dbx_business_glossary_term' = 'Payer Name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `payer_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `payer_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'pending|applied|cleared|reversed|failed|suspended');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `payment_type` SET TAGS ('dbx_business_glossary_term' = 'Payment Type');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `payment_type` SET TAGS ('dbx_value_regex' = 'premium|reinstatement|late_fee|nsfee|adjustment|refund');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `processing_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Processing Fee Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `receipt_issued_date` SET TAGS ('dbx_business_glossary_term' = 'Receipt Issued Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `receipt_number` SET TAGS ('dbx_business_glossary_term' = 'Receipt Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `reversal_date` SET TAGS ('dbx_business_glossary_term' = 'Reversal Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `reversal_reason` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `source` SET TAGS ('dbx_business_glossary_term' = 'Payment Source');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `source` SET TAGS ('dbx_value_regex' = 'policyholder|third_party|agent|reinsurer|subrogation');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `unapplied_amount` SET TAGS ('dbx_business_glossary_term' = 'Unapplied Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` SET TAGS ('dbx_subdomain' = 'payment_collection');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `payment_application_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Application Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `installment_id` SET TAGS ('dbx_business_glossary_term' = 'Installment Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `payment_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Source Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `allocation_priority` SET TAGS ('dbx_business_glossary_term' = 'Allocation Priority');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `application_date` SET TAGS ('dbx_business_glossary_term' = 'Application Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `application_method` SET TAGS ('dbx_business_glossary_term' = 'Application Method');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `application_method` SET TAGS ('dbx_value_regex' = 'automatic|manual|suspense_clearing|reversal|adjustment');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `application_notes` SET TAGS ('dbx_business_glossary_term' = 'Application Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `application_sequence` SET TAGS ('dbx_business_glossary_term' = 'Application Sequence Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `application_status` SET TAGS ('dbx_business_glossary_term' = 'Application Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `application_status` SET TAGS ('dbx_value_regex' = 'applied|reversed|pending|voided');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `application_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Application Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `applied_amount` SET TAGS ('dbx_business_glossary_term' = 'Applied Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `applied_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Applied By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `applied_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `applied_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `applied_to_fee_flag` SET TAGS ('dbx_business_glossary_term' = 'Applied to Fee Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `applied_to_interest_flag` SET TAGS ('dbx_business_glossary_term' = 'Applied to Interest Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `applied_to_principal_flag` SET TAGS ('dbx_business_glossary_term' = 'Applied to Principal Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `billing_account_number` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `billing_account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `billing_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `installment_balance_after` SET TAGS ('dbx_business_glossary_term' = 'Installment Balance After Application');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `installment_balance_before` SET TAGS ('dbx_business_glossary_term' = 'Installment Balance Before Application');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `nsf_reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Non-Sufficient Funds (NSF) Reversal Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `policy_number` SET TAGS ('dbx_business_glossary_term' = 'Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `reversal_date` SET TAGS ('dbx_business_glossary_term' = 'Reversal Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `reversal_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `reversal_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Reversal Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `suspense_clearing_flag` SET TAGS ('dbx_business_glossary_term' = 'Suspense Clearing Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `unapplied_amount` SET TAGS ('dbx_business_glossary_term' = 'Unapplied Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment_application` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` SET TAGS ('dbx_subdomain' = 'premium_accounting');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `dac_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Deferred Acquisition Cost (DAC) Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Source Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `accounting_standard` SET TAGS ('dbx_business_glossary_term' = 'Accounting Standard');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `accounting_standard` SET TAGS ('dbx_value_regex' = 'US_GAAP|IFRS_17|STAT');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `accounting_standard` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `accounting_standard` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `amortization_amount` SET TAGS ('dbx_business_glossary_term' = 'Amortization Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `amortization_method` SET TAGS ('dbx_business_glossary_term' = 'Amortization Method');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `amortization_method` SET TAGS ('dbx_value_regex' = 'straight_line|earned_premium|expected_gross_profit');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `amortization_period_months` SET TAGS ('dbx_business_glossary_term' = 'Amortization Period (Months)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Approved By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `capitalized_amount` SET TAGS ('dbx_business_glossary_term' = 'Capitalized Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `dac_balance` SET TAGS ('dbx_business_glossary_term' = 'DAC Balance');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `earned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `impairment_amount` SET TAGS ('dbx_business_glossary_term' = 'Impairment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Transaction Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `other_acquisition_cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Other Acquisition Cost Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `policy_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `policy_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `posted_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Posted By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `posted_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `posted_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `product_code` SET TAGS ('dbx_business_glossary_term' = 'Product Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `recoverability_test_date` SET TAGS ('dbx_business_glossary_term' = 'Recoverability Test Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `recoverability_test_result` SET TAGS ('dbx_business_glossary_term' = 'Recoverability Test Result');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `recoverability_test_result` SET TAGS ('dbx_value_regex' = 'pass|fail|not_tested');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `reversal_reason` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'DAC Transaction Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `transaction_number` SET TAGS ('dbx_business_glossary_term' = 'DAC Transaction Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_business_glossary_term' = 'DAC Transaction Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_value_regex' = 'draft|pending|posted|reversed|cancelled');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'DAC Transaction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'capitalization|amortization|write_off|adjustment|reversal');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `underwriting_expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Expense Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `underwriting_expense_amount` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `underwriting_expense_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `write_off_amount` SET TAGS ('dbx_business_glossary_term' = 'Write-Off Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ALTER COLUMN `written_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Written Premium (WP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` SET TAGS ('dbx_subdomain' = 'rating_calculation');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `minimum_earned_premium_id` SET TAGS ('dbx_business_glossary_term' = 'Minimum Earned Premium (MEP) ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `jurisdiction_state_id` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `applies_to_cancellation_type` SET TAGS ('dbx_business_glossary_term' = 'Applies to Cancellation Type');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `applies_to_cancellation_type` SET TAGS ('dbx_value_regex' = 'insured_request|underwriter_cancellation|non_payment|all_cancellations');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `filing_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `filing_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Filing Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `mep_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Earned Premium (MEP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `mep_calculation_method` SET TAGS ('dbx_business_glossary_term' = 'MEP Calculation Method');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `mep_calculation_method` SET TAGS ('dbx_value_regex' = 'flat_amount|percentage_of_wp|greater_of_amount_or_percentage|short_rate_table|pro_rata_with_floor');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `mep_percentage` SET TAGS ('dbx_business_glossary_term' = 'Minimum Earned Premium (MEP) Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `mep_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `mep_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `mep_waiver_reason_code` SET TAGS ('dbx_business_glossary_term' = 'MEP Waiver Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `minimum_earned_premium_status` SET TAGS ('dbx_business_glossary_term' = 'MEP Threshold Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `minimum_earned_premium_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending_approval|superseded|expired');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Modified By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `override_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Override Allowed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `override_authority_level` SET TAGS ('dbx_business_glossary_term' = 'Override Authority Level');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `override_authority_level` SET TAGS ('dbx_value_regex' = 'underwriter|senior_underwriter|uw_manager|vp_underwriting|none');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `policy_term_months` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Months');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `product_code` SET TAGS ('dbx_business_glossary_term' = 'Product Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `regulatory_mandate_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Mandate Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `short_rate_penalty_percentage` SET TAGS ('dbx_business_glossary_term' = 'Short Rate Penalty Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `short_rate_penalty_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `short_rate_penalty_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` SET TAGS ('dbx_subdomain' = 'premium_accounting');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `surplus_lines_tax_id` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Tax ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `surplus_lines_tax_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `surplus_lines_tax_id` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `tax_jurisdiction_state_id` SET TAGS ('dbx_business_glossary_term' = 'Tax Jurisdiction State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `adjustment_reason` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `diligent_search_completed_flag` SET TAGS ('dbx_business_glossary_term' = 'Diligent Search Completed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `diligent_search_date` SET TAGS ('dbx_business_glossary_term' = 'Diligent Search Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `diligent_search_documentation_reference` SET TAGS ('dbx_business_glossary_term' = 'Diligent Search Documentation Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `exemption_code` SET TAGS ('dbx_business_glossary_term' = 'Exemption Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `exemption_reason` SET TAGS ('dbx_business_glossary_term' = 'Exemption Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `filing_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Period End Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `filing_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Period Start Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `gwp_subject_to_tax` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP) Subject to Tax');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `home_state_allocation_percent` SET TAGS ('dbx_business_glossary_term' = 'Home State Allocation Percent');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `interest_amount` SET TAGS ('dbx_business_glossary_term' = 'Interest Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `multi_state_allocation_flag` SET TAGS ('dbx_business_glossary_term' = 'Multi-State Allocation Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `nonadmitted_insurer_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Nonadmitted Insurer NAIC Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `nonadmitted_insurer_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `nonadmitted_insurer_name` SET TAGS ('dbx_business_glossary_term' = 'Nonadmitted Insurer Name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `nonadmitted_insurer_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `nonadmitted_insurer_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `penalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Penalty Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `policy_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `policy_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `stamping_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Stamping Fee Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `stamping_fee_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Stamping Fee Rate Percent');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `stamping_office_code` SET TAGS ('dbx_business_glossary_term' = 'Stamping Office Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `stamping_office_name` SET TAGS ('dbx_business_glossary_term' = 'Stamping Office Name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `stamping_office_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `stamping_office_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `surplus_lines_broker_license_number` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Broker License Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `surplus_lines_broker_license_number` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `surplus_lines_broker_license_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `surplus_lines_broker_name` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Broker Name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `surplus_lines_broker_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `surplus_lines_broker_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `tax_calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Tax Calculation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `tax_filed_date` SET TAGS ('dbx_business_glossary_term' = 'Tax Filed Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `tax_filing_due_date` SET TAGS ('dbx_business_glossary_term' = 'Tax Filing Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `tax_paid_date` SET TAGS ('dbx_business_glossary_term' = 'Tax Paid Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `tax_payment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Tax Payment Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `tax_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Tax Rate Percent');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `tax_status` SET TAGS ('dbx_business_glossary_term' = 'Tax Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `tax_status` SET TAGS ('dbx_value_regex' = 'pending|calculated|filed|paid|overdue|waived');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `total_tax_and_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Tax and Fee Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` SET TAGS ('dbx_subdomain' = 'payment_collection');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `finance_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Finance Agreement Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `billing_account_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `insured_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `agreement_number` SET TAGS ('dbx_business_glossary_term' = 'Finance Agreement Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `agreement_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{8,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `agreement_signed_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Signed Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `agreement_status` SET TAGS ('dbx_business_glossary_term' = 'Finance Agreement Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `agreement_status` SET TAGS ('dbx_value_regex' = 'pending|active|paid_in_full|defaulted|cancelled|suspended');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Finance Agreement Type');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'standard|commercial|personal|specialty');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `annual_percentage_rate` SET TAGS ('dbx_business_glossary_term' = 'Annual Percentage Rate (APR)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `annual_percentage_rate` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `annual_percentage_rate` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Finance Agreement Cancellation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `cancellation_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Notice Days Count');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_value_regex' = 'default|early_payoff|policy_cancelled|mutual_agreement|other');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `default_date` SET TAGS ('dbx_business_glossary_term' = 'Default Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `delinquency_days` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Days Count');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `down_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Down Payment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Finance Agreement Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Finance Agreement Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `final_installment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Final Installment Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `finance_company_party_code` SET TAGS ('dbx_business_glossary_term' = 'Finance Company Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `financed_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Financed Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `first_installment_due_date` SET TAGS ('dbx_business_glossary_term' = 'First Installment Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_business_glossary_term' = 'Grace Period Days Count');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `installment_amount` SET TAGS ('dbx_business_glossary_term' = 'Installment Payment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `installment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Installment Payment Frequency');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `installment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `interest_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Interest Rate Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `last_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Last Payment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `last_payment_date` SET TAGS ('dbx_business_glossary_term' = 'Last Payment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `late_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Late Fee Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `next_payment_due_amount` SET TAGS ('dbx_business_glossary_term' = 'Next Payment Due Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `next_payment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Payment Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `number_of_installments` SET TAGS ('dbx_business_glossary_term' = 'Number of Installments');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `outstanding_balance_amount` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Balance Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `past_due_amount` SET TAGS ('dbx_business_glossary_term' = 'Past Due Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `payoff_amount` SET TAGS ('dbx_business_glossary_term' = 'Payoff Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `payoff_date` SET TAGS ('dbx_business_glossary_term' = 'Payoff Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `power_of_attorney_flag` SET TAGS ('dbx_business_glossary_term' = 'Power of Attorney (POA) Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `total_amount_financed` SET TAGS ('dbx_business_glossary_term' = 'Total Amount Financed');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `total_finance_charge_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Finance Charge Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `total_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Paid Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ALTER COLUMN `total_repayment_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Repayment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` SET TAGS ('dbx_subdomain' = 'rating_calculation');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `premium_rate_filing_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Rate Filing ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `actuarial_justification` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Justification');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `actuary_credential` SET TAGS ('dbx_business_glossary_term' = 'Actuary Credential');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `actuary_name` SET TAGS ('dbx_business_glossary_term' = 'Actuary Name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `actuary_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `actuary_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `affected_policy_count` SET TAGS ('dbx_business_glossary_term' = 'Affected Policy Count');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `certification_date` SET TAGS ('dbx_business_glossary_term' = 'Certification Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `competitive_impact_analysis` SET TAGS ('dbx_business_glossary_term' = 'Competitive Impact Analysis');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `consumer_impact_statement` SET TAGS ('dbx_business_glossary_term' = 'Consumer Impact Statement');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `filing_description` SET TAGS ('dbx_business_glossary_term' = 'Filing Description');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `filing_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Filing Fee Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `filing_fee_paid_flag` SET TAGS ('dbx_business_glossary_term' = 'Filing Fee Paid Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `filing_method` SET TAGS ('dbx_business_glossary_term' = 'Filing Method');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `filing_method` SET TAGS ('dbx_value_regex' = 'file_and_use|prior_approval|use_and_file|flex_rating|no_file');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `filing_number` SET TAGS ('dbx_business_glossary_term' = 'Filing Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Filing Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `filing_type` SET TAGS ('dbx_business_glossary_term' = 'Filing Type');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `filing_type` SET TAGS ('dbx_value_regex' = 'rate_change|new_program|rule_change|form_filing|rate_and_rule|withdrawal');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `indicated_rate_change_percentage` SET TAGS ('dbx_business_glossary_term' = 'Indicated Rate Change Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `indicated_rate_change_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `indicated_rate_change_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `insurer_response` SET TAGS ('dbx_business_glossary_term' = 'Insurer Response');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `iso_program_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Program Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `loss_ratio_target` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR) Target');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `objection_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Objection Period End Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `prior_filing_number` SET TAGS ('dbx_business_glossary_term' = 'Prior Filing Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `rate_change_percentage` SET TAGS ('dbx_business_glossary_term' = 'Rate Change Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `rate_change_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `rate_change_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `rate_change_type` SET TAGS ('dbx_business_glossary_term' = 'Rate Change Type');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `rate_change_type` SET TAGS ('dbx_value_regex' = 'increase|decrease|no_change|variable');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `rate_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Rate Impact Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `rate_manual_version` SET TAGS ('dbx_business_glossary_term' = 'Rate Manual Version');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `regulator_comments` SET TAGS ('dbx_business_glossary_term' = 'Regulator Comments');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `rejection_date` SET TAGS ('dbx_business_glossary_term' = 'Rejection Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `serff_tracking_number` SET TAGS ('dbx_business_glossary_term' = 'System for Electronic Rate and Form Filing (SERFF) Tracking Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `superseded_filing_number` SET TAGS ('dbx_business_glossary_term' = 'Superseded Filing Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `supporting_document_count` SET TAGS ('dbx_business_glossary_term' = 'Supporting Document Count');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `supporting_document_count` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `supporting_document_count` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'Withdrawal Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` SET TAGS ('dbx_subdomain' = 'payment_collection');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `agency_bill_statement_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Bill Statement ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `agency_bill_statement_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `agency_bill_statement_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `billing_account_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Account ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `balance_forward_amount` SET TAGS ('dbx_business_glossary_term' = 'Balance Forward Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `billing_method` SET TAGS ('dbx_business_glossary_term' = 'Billing Method');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `billing_method` SET TAGS ('dbx_value_regex' = 'direct_bill|agency_bill|list_bill|account_current');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `cancellation_count` SET TAGS ('dbx_business_glossary_term' = 'Cancellation (CANC) Count');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `commission_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate Percent');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `current_balance_amount` SET TAGS ('dbx_business_glossary_term' = 'Current Balance Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `delinquency_days` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Days');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `endorsement_count` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Count');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `fees_amount` SET TAGS ('dbx_business_glossary_term' = 'Fees Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `gwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `issued_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Issued By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `issued_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `issued_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `lob_summary` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Summary');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `net_amount_due` SET TAGS ('dbx_business_glossary_term' = 'Net Amount Due');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `new_business_count` SET TAGS ('dbx_business_glossary_term' = 'New Business (NB) Count');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `nwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Written Premium (NWP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `payment_received_amount` SET TAGS ('dbx_business_glossary_term' = 'Payment Received Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `payment_terms_days` SET TAGS ('dbx_business_glossary_term' = 'Payment Terms Days');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `policy_count` SET TAGS ('dbx_business_glossary_term' = 'Policy Count');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `premium_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Tax Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `producer_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Producer Contact Email');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `producer_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `producer_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `producer_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `producer_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Producer Contact Name');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `producer_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `producer_contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `producer_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Producer Contact Phone');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `producer_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `producer_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'pending|reconciled|disputed|adjusted');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `renewal_count` SET TAGS ('dbx_business_glossary_term' = 'Renewal (REN) Count');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `statement_date` SET TAGS ('dbx_business_glossary_term' = 'Statement Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `statement_delivery_method` SET TAGS ('dbx_business_glossary_term' = 'Statement Delivery Method');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `statement_delivery_method` SET TAGS ('dbx_value_regex' = 'email|postal_mail|portal|fax');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `statement_format` SET TAGS ('dbx_business_glossary_term' = 'Statement Format');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `statement_format` SET TAGS ('dbx_value_regex' = 'pdf|csv|xml|html');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `statement_number` SET TAGS ('dbx_business_glossary_term' = 'Statement Number');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `statement_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Statement Period End Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `statement_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Statement Period Start Date');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `statement_status` SET TAGS ('dbx_business_glossary_term' = 'Statement Status');
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ALTER COLUMN `statement_status` SET TAGS ('dbx_value_regex' = 'draft|issued|paid|partially_paid|overdue|cancelled');
