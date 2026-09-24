-- Schema for Domain: premium | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-20 14:33:31

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_blog_v499`.`premium` COMMENT 'Transactional ledger for all premium activity. Owns Premium Transaction (one row per financial transaction: Written, Earned, Unearned, Return) tied to Policy, Policy Term, Coverage, Insured Risk, and Accounting Period, with Charge, Tax, Fee, and';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` (
    `premium_transaction_id` BIGINT COMMENT 'Unique surrogate identifier for each premium financial movement record. Grain: one row per financial premium movement (Written, Earned, Unearned, Return). Primary key.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Premium transactions posted to accounting periods require calendar dimensions for fiscal/accident/policy year reporting.',
    `cat_model_version_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_model_version. Business justification: Premium transactions link to catastrophe model versions for pricing validation, rate adequacy monitoring, actuarial review of catastrophe loads, and regulatory filing',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Premium transactions require catastrophe zone assignment for exposure aggregation, PML calculations, concentration monitoring, and rate adequacy analysis.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Premium transactions must track catastrophe event attribution for loss ratio analysis, reinsurance bordereaux reporting, regulatory Schedule P filings, and post-event',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Premium transactions must identify covered peril for statutory line-of-business reporting, reinsurance treaty allocation, actuarial loss triangles, and Schedule P development.',
    `claim_id` BIGINT COMMENT 'Foreign key linking to claims.claim. Business justification: Retrospectively-rated policies (workers comp, general liability) adjust premium based on actual claim experience during the policy term.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this premium transaction is recognized for statutory and GAAP reporting purposes.',
    `coverage_id` BIGINT COMMENT 'Reference to the specific coverage line within the policy term to which this premium transaction is allocated. Enables per-coverage premium analytics.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Premium transactions record amounts in specific currencies. Multi-currency operations require proper FK for FX validation, conversion, and regulatory reporting.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Premium transactions require geographic attribution for statutory state pages, territorial profitability analysis, regulatory reporting, and geographic concentration',
    `insured_risk_id` BIGINT COMMENT 'Reference to the insured risk or exposure unit (property, vehicle, driver) to which this premium transaction is allocated.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Normalize lob_code string to FK reference to shared.line_of_business master data. Premium transaction currently stores lob_code as string; replacing with FK enables consistent LOB',
    `original_transaction_id` BIGINT COMMENT 'Reference to the original premium transaction that this record reverses or corrects. Populated only when reversal_indicator is True. Supports audit trail.',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which this premium transaction was generated. Links the premium ledger entry to the master policy record.',
    `policy_term_id` BIGINT COMMENT 'Reference to the specific policy term (time-bounded period) to which this premium transaction belongs. Enables reconstruction of premium in force at any date.',
    `policy_transaction_id` BIGINT COMMENT 'Reference to the policy transaction (New Business, Renewal, Endorsement, Cancellation, Reinstatement) that triggered this premium movement.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer (agent or broker) associated with this premium transaction for commission settlement and distribution channel reporting.',
    `quote_id` BIGINT COMMENT 'Foreign key linking to coverage.quote. Business justification: Premium transactions originate from bound quotes; accounting audit trail requires quote reference for rate reconciliation, variance analysis between quoted and booked premium, and',
    `rating_worksheet_id` BIGINT COMMENT 'Foreign key linking to coverage.rating_worksheet. Business justification: Premium transactions reference rating worksheets for rate reconciliation, audit defense of filed rates, and regulatory compliance verification.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to coverage.submission. Business justification: Premium transactions trace to originating submission for source-of-business reporting, producer commission attribution by submission channel, and new-business vs renewal premium',
    `unit_of_measure_id` BIGINT COMMENT 'Foreign key linking to shared.unit_of_measure. Business justification: Premium transactions record exposure amounts measured in units (vehicles, payroll, sales).',
    `coverage_transaction_id` BIGINT COMMENT '',
    `audit_basis` STRING COMMENT 'Exposure basis used for auditable policies (e.g., WC, CGL) to determine final earned premium: Payroll, Revenue, Units, Receipts, or None for non-auditable policies.. Valid values are `Payroll|Revenue|Units|Receipts|None`',
    `ceded_written_premium` DECIMAL(18,4) COMMENT 'Portion of gross written premium ceded to reinsurers under treaty or facultative agreements. Used for Schedule F and reinsurance bordereaux reporting.',
    `cost_center_code` STRING COMMENT 'Internal cost center or profit center code to which this premium transaction is allocated for management accounting and segment reporting purposes.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this premium transaction record was first created in the source system. Used for audit trail and data lineage.',
    `days_in_force` BIGINT COMMENT 'Number of days the coverage was in force during the accounting period for this premium transaction. Used in pro-rata earning and exposure calculations.',
    `direct_billed_indicator` BOOLEAN COMMENT 'Indicates whether this premium is billed directly to the policyholder (True) or through the producer/agency (False = agency billed). Drives billing workflow routing.',
    `earned_premium` DECIMAL(18,4) COMMENT 'Portion of written premium recognized as earned for the accounting period based on pro-rata or other earning methodology. Core input to loss ratio (LR) calculation.',
    `earning_method` STRING COMMENT 'Method used to recognize written premium as earned over the policy period: Pro-Rata (daily), 1/365, 1/24 (monthly), Flat (fully earned at inception), or Other.. Valid values are `Pro-Rata|1/365|1/24|Flat|Other`',
    `effective_date` DATE COMMENT 'Date from which this premium transaction takes effect for coverage and financial recognition purposes. Used to reconstruct premium in force at any given date.',
    `endorsement_type` STRING COMMENT 'Type of endorsement premium adjustment: Additional (increase), Return (decrease/credit), Flat (no change), Audit (audit-based adjustment), or None for non-endorsement transactions.. Valid values are `Additional|Return|Flat|Audit|None`',
    `expiration_date` DATE COMMENT 'Date on which the premium coverage period ends for this transaction. Used for unearned premium (UEP) calculation and pro-rata earning.',
    `exposure_amount` DECIMAL(18,4) COMMENT 'Quantitative exposure measure (e.g., payroll dollars, vehicle count, property TIV) underlying the premium calculation. Used for rate adequacy and actuarial analysis.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this premium transaction is posted in the statutory and GAAP accounting systems. Required for financial close and SOX compliance.',
    `gross_written_premium` DECIMAL(18,4) COMMENT 'Total gross written premium amount for this transaction before cessions, taxes, fees, and commissions. Core ledger amount for statutory and GAAP reporting.',
    `net_written_premium` DECIMAL(18,4) COMMENT 'Written premium net of reinsurance cessions. NWP = GWP minus ceded written premium. Used for net retention reporting and RBC calculations.',
    `notes` STRING COMMENT 'Free-text notes or comments entered by underwriters, billing staff, or system processes to explain the reason for or context of this premium transaction.',
    `payment_plan_code` STRING COMMENT 'Code identifying the installment or payment plan under which this premium is billed (e.g., Annual, Semi-Annual, Quarterly, Monthly, Pay-As-You-Go).',
    `posted_timestamp` TIMESTAMP COMMENT 'Date and time when this premium transaction was posted to the general ledger and accounting system. Distinct from the business event date.',
    `pro_rata_factor` DECIMAL(10,6) COMMENT 'Decimal factor (0.0 to 1.0) representing the proportion of the policy period elapsed as of the accounting period end date. Used to compute earned premium.',
    `rate` DECIMAL(18,6) COMMENT 'The rate applied to the exposure base to calculate the premium for this transaction. Expressed per unit of exposure (e.g., per $100 payroll, per $1000 TIV).',
    `rate_effective_date` DATE COMMENT 'Date on which the rate used for this premium transaction became effective. Required for rate adequacy monitoring and DOI rate filing compliance.',
    `return_premium` DECIMAL(18,4) COMMENT 'Premium amount returned to the policyholder due to cancellation, mid-term endorsement reduction, or audit adjustment. Negative financial movement in the ledger.',
    `reversal_indicator` BOOLEAN COMMENT 'Flag indicating whether this premium transaction is a reversal of a previously posted transaction. True = reversal entry; False = original entry.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record that originated this premium transaction (e.g., PAS for PolicyCenter, BILLING for BillingCenter, RATING for rating engine).. Valid values are `PAS|BILLING|RATING|MANUAL|REINSURANCE`',
    `state_code` STRING COMMENT 'Two-letter US state code where the risk is located or the policy is written. Required for state-level statutory reporting and DOI filings.. Valid values are `^[A-Z]{2}$`',
    `transaction_date` DATE COMMENT 'The business event date on which this premium movement was generated or triggered (e.g., policy effective date, endorsement effective date, cancellation date).',
    `transaction_number` STRING COMMENT 'Externally visible, human-readable identifier for this premium transaction as assigned by the Policy Administration System or billing system. Used in bordereaux and reconciliation.',
    `transaction_status` STRING COMMENT 'Current lifecycle state of the premium transaction in the accounting ledger: Pending (awaiting posting), Posted (booked to GL), Reversed, Voided, or Error.. Valid values are `Pending|Posted|Reversed|Voided|Error`',
    `transaction_type` STRING COMMENT 'Classification of the premium financial movement: Written (new/renewed/endorsed), Earned (pro-rata recognition), Unearned (UEP reserve), Return (cancellation/endorsement credit), or Adjustment.. Valid values are `Written|Earned|Unearned|Return|Adjustment`',
    `unearned_premium` DECIMAL(18,4) COMMENT 'Portion of written premium not yet earned as of the accounting period end date. Represents the UEP reserve liability on the balance sheet.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this premium transaction record was last modified. Supports audit trail, change detection, and incremental data loading.',
    CONSTRAINT pk_premium_transaction PRIMARY KEY(`premium_transaction_id`)
) COMMENT 'Premium Transaction: A financial transaction recording premium movements (Written, Earned, Unearned, Return). GRAIN: One row per financial transaction. Grain: one row per financial transaction.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` (
    `premium_accounting_period_id` BIGINT COMMENT 'Unique surrogate identifier for the accounting period record. Role: REFERENCE_LOOKUP — this is a calendar reference table; canonical minimums for transactional roles do not apply.',
    `prior_period_premium_accounting_period_id` BIGINT COMMENT 'Reference to the immediately preceding accounting period of the same type. Supports period-over-period comparisons and loss development triangle chaining.',
    `parent_period_id` BIGINT COMMENT 'Reference to the parent period in the hierarchy, e.g., a monthly periods parent is its quarter, a quarterly periods parent is its annual period.',
    `accident_year_ay` BIGINT COMMENT 'Accident Year (AY) associated with this period for loss development and IBNR reserving. Losses are assigned to the AY in which the loss event occurred.',
    `actuarial_reserve_cutoff_date` DATE COMMENT 'Date through which loss and IBNR reserve data is included in the actuarial reserve study for this period. Aligns with the loss triangle evaluation date.',
    `bordereaux_due_date` DATE COMMENT 'Date by which the reinsurance premium and loss bordereaux for this period must be submitted to reinsurers, per treaty and facultative agreement terms.',
    `calendar_year_cy` BIGINT COMMENT 'Calendar Year (CY) in which this period falls. Used for CY loss ratio, CY written premium, and Schedule P CY diagonal reporting.',
    `close_date` DATE COMMENT 'Date on which the accounting period was officially closed for premium, loss, and expense transaction posting. Null if the period has not yet been closed.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for premium and financial transactions posted in this period, e.g., USD. Supports multi-currency statutory reporting.. Valid values are `^[A-Z]{3}$`',
    `days_in_period` BIGINT COMMENT 'Total number of calendar days in this accounting period. Used as the denominator in pro-rata Earned Premium (EP) and Unearned Premium (UEP) calculations.',
    `earned_premium_basis` STRING COMMENT 'Method used to calculate Earned Premium (EP) within this period: PRO_RATA (proportional to days), DAILY (day-by-day), or MONTHLY (full-month convention).. Valid values are `PRO_RATA|DAILY|MONTHLY`',
    `end_date` DATE COMMENT 'Last calendar date of the accounting period (inclusive). Defines the upper bound for bucketing premium, loss, and expense transactions into this period.',
    `filing_status` STRING COMMENT 'Status of the statutory filing associated with this period: NOT_FILED, FILED, ACCEPTED, REJECTED, or AMENDED. Tracks compliance with NAIC and State DOI submission requirements.. Valid values are `NOT_FILED|FILED|ACCEPTED|REJECTED|AMENDED`',
    `fiscal_month` BIGINT COMMENT 'Month number (1–12) within the fiscal year. Null for QUARTERLY or ANNUAL period types. Used for monthly premium booking and earned premium calculations.',
    `fiscal_quarter` BIGINT COMMENT 'Quarter number (1–4) within the fiscal year. Null for MONTHLY or ANNUAL period types. Used for quarterly statutory and GAAP reporting.',
    `fiscal_year` BIGINT COMMENT 'Four-digit fiscal year to which this period belongs, e.g., 2024. Aligns with the statutory reporting year for NAIC Annual Statement filing.',
    `gl_period_code` STRING COMMENT 'Corresponding period code in the General Ledger (GL) system (Oracle/SAP), used to reconcile premium transactions to the statutory and GAAP trial balance.',
    `is_current_period` BOOLEAN COMMENT 'Indicates whether this is the currently active accounting period for premium transaction posting. True for exactly one OPEN period at any given time.',
    `is_ifrs17_reporting_period` BOOLEAN COMMENT 'Indicates whether this period is used for IFRS 17 Insurance Contracts reporting, including Contractual Service Margin (CSM) and Loss Component calculations.',
    `is_statutory_filing_period` BOOLEAN COMMENT 'Indicates whether this period corresponds to a statutory filing deadline (quarterly or annual NAIC statement). Drives automated Schedule P and Schedule F generation.',
    `lock_date` DATE COMMENT 'Date on which the period was hard-locked, preventing any further journal entries or premium transaction postings. Null if not yet locked.',
    `notes` STRING COMMENT 'Free-text notes or commentary about this accounting period, such as restatement explanations, special adjustments, or regulatory correspondence references.',
    `period_code` STRING COMMENT 'Business-facing unique code identifying the period, e.g., 2024-01 for January 2024, 2024-Q1 for first quarter, or 2024-ANNUAL for full year.. Valid values are `^[0-9]{4}-(0[1-9]|1[0-2]|Q[1-4]|ANNUAL)$`',
    `period_name` STRING COMMENT 'Human-readable label for the period, e.g., January 2024, Q1 2024, or Full Year 2024, used in reports and dashboards.',
    `period_status` STRING COMMENT 'Current state of the period in the financial close cycle: OPEN (transactions may post), CLOSED (soft close), LOCKED (hard close, no further postings), REOPENED (unlocked for adjustment).. Valid values are `OPEN|CLOSED|LOCKED|REOPENED`',
    `period_type` STRING COMMENT 'Granularity of the period: MONTHLY for a single calendar month, QUARTERLY for a three-month quarter, ANNUAL for a full calendar year.. Valid values are `MONTHLY|QUARTERLY|ANNUAL`',
    `policy_year_py` BIGINT COMMENT 'Policy Year (PY) associated with this period. Groups premium and losses by the year in which the policy was written, used for PY loss development triangles.',
    `regulatory_filing_deadline` DATE COMMENT 'Statutory deadline by which the NAIC Annual or Quarterly Statement covering this period must be filed with the applicable State Department of Insurance (DOI).',
    `reopen_date` DATE COMMENT 'Date on which a previously closed or locked period was reopened for corrective adjustments. Null if the period has never been reopened.',
    `reopen_reason` STRING COMMENT 'Free-text explanation for why a closed or locked period was reopened, e.g., audit adjustment, restatement, or regulatory correction. Null if never reopened.',
    `reporting_basis` STRING COMMENT 'Accounting basis under which this period is used: SAP (Statutory Accounting Principles), GAAP (US Generally Accepted Accounting Principles), or IFRS17 (IFRS 17 Insurance Contracts).. Valid values are `SAP|GAAP|IFRS17`',
    `schedule_p_year_type` STRING COMMENT 'Designates which Schedule P year-type view this period supports: CY (Calendar Year), AY (Accident Year), or PY (Policy Year), per NAIC Annual Statement Part 2 requirements.. Valid values are `CY|AY|PY`',
    `start_date` DATE COMMENT 'First calendar date of the accounting period (inclusive). Defines the lower bound for bucketing premium, loss, and expense transactions into this period.',
    CONSTRAINT pk_premium_accounting_period PRIMARY KEY(`premium_accounting_period_id`)
) COMMENT 'Reference calendar period (month, quarter, year) used to bucket premium, loss, and expense transactions for statutory and GAAP reporting. Supports CY, AY, and PY views required by Schedule P and IFRS 17.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` (
    `charge_id` BIGINT COMMENT 'Unique identifier for the charge component within a premium transaction.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Charges posted to accounting periods. FK enables period-based charge analysis, fiscal year reporting, and ensures charges align with calendar dimensions for financial statements.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Individual rating charges (wind surcharges, earthquake deductible buybacks) are event-specific for post-catastrophe pricing adjustments, experience rating, and',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Individual charges (earthquake coverage, flood buyback, wind deductible) are peril-specific for pricing transparency, regulatory compliance, coverage verification, and claims',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Foreign key to the accounting period in which this charge is recognized.',
    `coverage_id` BIGINT COMMENT 'Foreign key to the coverage to which this charge applies, if coverage-specific.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Charges have amounts denominated in currency. FK enables currency validation, FX conversion for consolidated reporting, and ensures charge amounts reference valid active currencies for',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Individual charges require geographic assignment for tax calculation, surplus lines allocation, territorial rating factors, and jurisdictional compliance.',
    `insured_risk_id` BIGINT COMMENT 'Foreign key to the insured risk to which this charge applies, if risk-specific.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Charges apply to specific lines of business. FK enables LOB-specific charge analysis, regulatory reporting by line, and ensures charges reference valid active LOBs.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy to which this charge applies.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this charge is effective.',
    `premium_transaction_id` BIGINT COMMENT 'Foreign key to the parent premium transaction that contains this charge.',
    `rating_worksheet_id` BIGINT COMMENT 'Foreign key linking to coverage.rating_worksheet. Business justification: Individual premium charges reference rating worksheets that calculated them for audit trail, rate justification to regulators, and insured disputes.',
    `amount` DECIMAL(18,2) COMMENT 'Monetary value of the charge component in the policy currency.',
    `basis_amount` DECIMAL(18,2) COMMENT 'Base amount to which the charge rate is applied to derive the charge amount.',
    `charge_category` STRING COMMENT 'High-level category of the charge: premium, fee, penalty, refund, or adjustment.. Valid values are `premium|fee|penalty|refund|adjustment`',
    `ceded_amount` DECIMAL(18,2) COMMENT 'Portion of the charge amount ceded to reinsurers under applicable reinsurance agreements.',
    `charge_status` STRING COMMENT 'Current lifecycle status of the charge: active, voided, reversed, adjusted, or pending.. Valid values are `active|voided|reversed|adjusted|pending`',
    `charge_type` STRING COMMENT 'Classification of the charge component: base premium, surcharge, credit, discount, minimum premium, flat charge, or adjustment. [ENUM-REF-CANDIDATE: base_premium|surcharge|credit|discount|minimum_premium|flat_charge|adjustment — 7 candidates stripped',
    `commission_amount` DECIMAL(18,2) COMMENT 'Commission amount payable to the producer based on this charge, if commissionable.',
    `commission_rate` DECIMAL(5,2) COMMENT 'Percentage rate applied to this charge to calculate producer commission, if commissionable.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this charge record was first created in the system.',
    `charge_description` STRING COMMENT 'Detailed business description of the charge component and its purpose.',
    `earned_amount` DECIMAL(18,2) COMMENT 'Portion of the charge amount that has been earned as of the accounting period date.',
    `effective_date` DATE COMMENT 'Date from which this charge becomes effective and applies to the policy or coverage.',
    `expiration_date` DATE COMMENT 'Date on which this charge expires and no longer applies to the policy or coverage.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this charge is posted for financial reporting.',
    `is_ceded` BOOLEAN COMMENT 'Indicates whether this charge is subject to reinsurance cession under a treaty or facultative agreement.',
    `is_commissionable` BOOLEAN COMMENT 'Indicates whether this charge is subject to producer commission calculation.',
    `is_earned` BOOLEAN COMMENT 'Indicates whether this charge has been earned as of the accounting period date.',
    `is_minimum_premium` BOOLEAN COMMENT 'Indicates whether this charge represents a minimum premium requirement for the policy or coverage.',
    `is_prorated` BOOLEAN COMMENT 'Indicates whether the charge amount has been prorated for a partial term or endorsement period.',
    `net_amount` DECIMAL(18,2) COMMENT 'Net charge amount retained by the insurer after reinsurance cession, calculated as charge amount minus ceded amount.',
    `number` STRING COMMENT 'Business identifier for the charge, unique within the premium transaction context.',
    `percentage` DECIMAL(5,2) COMMENT 'Percentage applied to the basis amount to calculate the charge, if applicable.',
    `proration_factor` DECIMAL(8,6) COMMENT 'Factor applied to prorate the charge for a partial term, typically a fraction of the full term.',
    `rate` DECIMAL(12,6) COMMENT 'Rate or factor applied to calculate the charge amount, if applicable.',
    `rating_element_code` STRING COMMENT 'Code identifying the rating element or factor that generated this charge, per the rating engine.',
    `rating_element_description` STRING COMMENT 'Human-readable description of the rating element or factor that generated this charge.',
    `reversal_reason_code` STRING COMMENT 'Code indicating the reason for voiding or reversing this charge, if applicable.',
    `reversal_reason_description` STRING COMMENT 'Human-readable description of the reason for voiding or reversing this charge.',
    `sequence` BIGINT COMMENT 'Ordering sequence of this charge within the premium transaction for display and calculation purposes.',
    `statutory_line_code` STRING COMMENT 'NAIC statutory line of business code for regulatory reporting and Schedule P aggregation.',
    `unearned_amount` DECIMAL(18,2) COMMENT 'Portion of the charge amount that remains unearned as of the accounting period date.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this charge record was last modified in the system.',
    CONSTRAINT pk_charge PRIMARY KEY(`charge_id`)
) COMMENT 'Child of Premium Transaction. One row per charge component (base premium, surcharge, credit, minimum premium) within a transaction. Enables granular decomposition of gross written premium by rating element and LOB.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` (
    `tax_levy_id` BIGINT COMMENT 'Unique identifier for the tax levy record. Primary key.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Taxes posted to accounting periods. FK enables period-based tax reporting, fiscal year tax remittance analysis, and ensures taxes align with calendar dimensions for regulatory reporting.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Catastrophe-related taxes (wind pool assessments, FAIR plan surcharges, beach plan levies) require zone attribution for proper levy calculation, regulatory reporting, and',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Foreign key to the accounting period in which this tax levy is recognized for statutory and financial reporting.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Tax amounts recorded in specific currencies. Multi-currency tax remittance requires proper FK for currency validation, FX conversion, and regulatory tax reporting across jurisdictions with',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Tax jurisdiction mapping requires geographic hierarchy for proper remittance, surplus lines stamping office allocation, multi-state tax apportionment, and regulatory',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Tax rates and remittance vary by line of business. FK enables LOB-specific tax reporting, regulatory compliance by line, and ensures taxes reference valid LOBs for statutory reporting.',
    `original_tax_levy_id` BIGINT COMMENT 'Foreign key to the original tax levy record being adjusted or corrected, if this is an adjustment transaction. Null for original levies.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy associated with this tax levy for direct policy-level aggregation.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this tax levy was assessed.',
    `premium_transaction_id` BIGINT COMMENT 'Foreign key to the parent premium transaction to which this tax levy applies.',
    `amount` DECIMAL(15,2) COMMENT 'The computed tax amount due, calculated as taxable premium amount multiplied by tax rate, in US dollars.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the tax levy record was first created in the data platform.',
    `tax_levy_description` STRING COMMENT 'Free-text description providing additional context or detail about the tax levy, such as special assessments or regulatory notes.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code of the insurer responsible for remitting the tax, used for statutory reporting and reconciliation.',
    `policy_transaction_type_code` STRING COMMENT 'Type of policy transaction that triggered the premium and associated tax levy: new business, renewal, endorsement, cancellation, or reinstatement.. Valid values are `NEW_BUSINESS|RENEWAL|ENDORSEMENT|CANCELLATION|REINSTATEMENT`',
    `source_system_code` STRING COMMENT 'Code identifying the source system that originated the tax levy record, such as billing system or policy administration system.',
    `stamping_office_code` STRING COMMENT 'Code identifying the surplus lines stamping office responsible for processing and collecting the tax, if applicable.',
    `surplus_lines_flag` BOOLEAN COMMENT 'Indicates whether this tax levy applies to a surplus lines policy, subject to surplus lines tax and stamping requirements.',
    `tax_adjustment_flag` BOOLEAN COMMENT 'Indicates whether this tax levy record represents an adjustment or correction to a previously recorded tax levy.',
    `tax_authority_name` STRING COMMENT 'Name of the regulatory or governmental authority to which the tax is remitted, such as State Department of Insurance or Surplus Lines Stamping Office.',
    `tax_calculation_method_code` STRING COMMENT 'Method used to calculate the tax levy: statutory rate, flat fee, tiered rate schedule, or minimum tax threshold.. Valid values are `STATUTORY_RATE|FLAT_FEE|TIERED_RATE|MINIMUM_TAX`',
    `tax_effective_date` DATE COMMENT 'The date on which the tax levy becomes effective, typically aligned with the premium transaction effective date.',
    `tax_exemption_flag` BOOLEAN COMMENT 'Indicates whether the premium transaction qualifies for a tax exemption under statutory or regulatory provisions.',
    `tax_exemption_reason_code` STRING COMMENT 'Code indicating the reason for tax exemption: exempt entity, reinsurance, export, federal program, or other statutory exemption.. Valid values are `EXEMPT_ENTITY|REINSURANCE|EXPORT|FEDERAL_PROGRAM|OTHER`',
    `tax_rate` DECIMAL(10,6) COMMENT 'The statutory tax rate applied to the taxable premium base, expressed as a decimal (e.g., 0.025 for 2.5 percent).',
    `tax_remittance_batch_code` STRING COMMENT 'Identifier of the remittance batch or payment run in which this tax levy was included for payment to the authority.',
    `tax_remittance_date` DATE COMMENT 'The actual date on which the tax was remitted to the taxing authority. Null if not yet remitted.',
    `tax_remittance_due_date` DATE COMMENT 'The statutory due date by which the tax must be remitted to the taxing authority to avoid penalties.',
    `tax_remittance_status` STRING COMMENT 'Current remittance status of the tax levy: pending, remitted, overdue, waived, or adjusted.. Valid values are `PENDING|REMITTED|OVERDUE|WAIVED|ADJUSTED`',
    `tax_reporting_category_code` STRING COMMENT 'Reporting category for statutory and regulatory tax filings: direct written premium, assumed reinsurance, or ceded reinsurance.. Valid values are `DIRECT_WRITTEN|ASSUMED_REINSURANCE|CEDED_REINSURANCE`',
    `tax_type_code` STRING COMMENT 'Classification of the tax levy: state premium tax, surplus lines tax, stamping fee, municipal tax, fire marshal tax, or guaranty fund assessment.. Valid values are `STATE_PREMIUM_TAX|SURPLUS_LINES_TAX|STAMPING_FEE|MUNICIPAL_TAX|FIRE_MARSHAL_TAX|GUARANTY_FUND_ASSESSMENT`',
    `taxable_premium_amount` DECIMAL(15,2) COMMENT 'The base premium amount subject to tax, after any exemptions or adjustments, in US dollars.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the tax levy record was last modified in the data platform.',
    CONSTRAINT pk_tax_levy PRIMARY KEY(`tax_levy_id`)
) COMMENT 'Child of Premium Transaction. One row per state or surplus-lines tax, stamping fee, or regulatory assessment applied to a premium transaction. Tracks tax type, jurisdiction, rate, and computed amount for statutory remittance.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` (
    `policy_fee_id` BIGINT COMMENT 'Unique identifier for the policy fee transaction record.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Fees posted to accounting periods. FK enables period-based fee analysis, fiscal year fee revenue reporting, and ensures fees align with calendar dimensions for financial statements.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Foreign key to the accounting period in which this fee transaction is recognized for statutory and financial reporting.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Policy fees denominated in currency. FK enables currency validation, FX conversion for consolidated fee revenue reporting, and ensures fee amounts reference valid active currencies for',
    `invoice_id` BIGINT COMMENT 'Foreign key to the billing invoice on which this fee appears; null if not yet invoiced.',
    `original_fee_id` BIGINT COMMENT 'Foreign key to the original policy fee record if this is a reversal or adjustment; null for original charges.',
    `payment_plan_id` BIGINT COMMENT 'Foreign key to the payment plan under which this fee is financed; null for full-pay policies.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy to which this fee applies.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this fee was charged.',
    `premium_transaction_id` BIGINT COMMENT 'Foreign key to the parent premium transaction that this fee is attached to.',
    `source_transaction_id` BIGINT COMMENT 'Unique identifier of the fee transaction in the source operational system for audit and reconciliation.',
    `billing_method` STRING COMMENT 'Method by which the fee is billed: direct bill to insured, agency bill through producer, list bill, or account current.. Valid values are `direct_bill|agency_bill|list_bill|account_current`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy fee record was first created in the source system.',
    `fee_amount` DECIMAL(15,2) COMMENT 'Monetary amount of the fee charged, in the policy currency.',
    `fee_basis` STRING COMMENT 'Basis on which the fee is calculated: flat amount, per policy, per vehicle, per location, per driver, per installment, or percentage of premium. [ENUM-REF-CANDIDATE: flat|per_policy|per_vehicle|per_location|per_driver|per_installment|percentage_of_premium',
    `fee_code` STRING COMMENT 'Standardized code identifying the type of fee charged, aligned with rating engine and billing system fee schedules.',
    `fee_description` STRING COMMENT 'Human-readable description of the fee, displayed on declarations pages and billing statements.',
    `fee_quantity` DECIMAL(10,2) COMMENT 'Quantity or count used to calculate the fee when charged on a per-unit basis; null for flat or percentage fees.',
    `fee_rate` DECIMAL(10,6) COMMENT 'Rate applied when fee is calculated as a percentage or per-unit charge; null for flat fees.',
    `fee_status` STRING COMMENT 'Current lifecycle status of the fee transaction: pending, posted, reversed, refunded, or written off.. Valid values are `pending|posted|reversed|refunded|written_off`',
    `fee_type` STRING COMMENT 'Classification of the fee by business purpose: policy fee, inspection fee, installment fee, service fee, late fee, reinstatement fee, endorsement fee, or cancellation fee.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this fee is posted for financial reporting.',
    `is_commission_bearing` BOOLEAN COMMENT 'Indicates whether producer commission is calculated on this fee; typically false for most policy fees.',
    `is_refundable` BOOLEAN COMMENT 'Indicates whether this fee is refundable upon policy cancellation or endorsement reversal.',
    `is_taxable` BOOLEAN COMMENT 'Indicates whether this fee is subject to state or local taxes; most policy fees are non-taxable.',
    `jurisdiction_code` STRING COMMENT 'Regulatory jurisdiction code for fee compliance and reporting, may include county or municipal codes.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy fee record was last updated in the source system.',
    `lob_code` STRING COMMENT 'Internal line of business code for management reporting and analytics.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding this fee transaction, for audit and customer service reference.',
    `reversal_date` DATE COMMENT 'Date on which the fee was reversed or refunded; null if not reversed.',
    `reversal_reason_code` STRING COMMENT 'Code indicating the reason for fee reversal or refund; null if not reversed.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system that originated this fee transaction.',
    `state_code` STRING COMMENT 'Two-letter US state or Canadian province code where the fee applies, for regulatory and tax jurisdiction purposes.',
    `statutory_line_code` STRING COMMENT 'NAIC statutory line of business code for regulatory reporting classification.',
    `transaction_booking_date` DATE COMMENT 'Date on which the fee transaction was recorded in the financial ledger.',
    `transaction_effective_date` DATE COMMENT 'Date on which the fee transaction becomes effective for policy accounting purposes.',
    `transaction_type` STRING COMMENT 'Type of financial movement: charge for new fee, reversal for cancellation, adjustment for correction, or refund for return.. Valid values are `charge|reversal|adjustment|refund`',
    `waived_flag` BOOLEAN COMMENT 'Indicates whether this fee was waived as part of underwriting discretion or customer service exception.',
    `waiver_authorized_by` STRING COMMENT 'User ID or name of the underwriter or manager who authorized the fee waiver; null if not waived.',
    `waiver_reason_code` STRING COMMENT 'Code indicating the reason for fee waiver; null if not waived.',
    CONSTRAINT pk_policy_fee PRIMARY KEY(`policy_fee_id`)
) COMMENT 'Child of Premium Transaction. One row per non-premium fee (policy fee, inspection fee, installment fee) charged on a transaction. Fees are non-taxable in most jurisdictions and tracked separately from taxable premium.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` (
    `commission_id` BIGINT COMMENT 'Unique identifier for the commission transaction record.',
    `agency_id` BIGINT COMMENT 'Foreign key to the agency associated with this commission.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Commissions posted to accounting periods. FK enables period-based producer accounting, fiscal year commission expense reporting, and ensures commissions align with calendar dimensions for',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Foreign key to the accounting period in which this commission is recognized.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Commission amounts in specific currencies. Multi-currency producer accounting requires proper FK for currency validation, FX conversion, and accurate producer compensation reporting across',
    `disbursement_id` BIGINT COMMENT 'Foreign key linking to billing.disbursement. Business justification: Commission records earned amounts; disbursement records actual payment to producer. Reconciliation of earned vs paid commission is critical for producer accounting, commission payable',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Producer commissions vary by geography due to market conditions, regulatory constraints, competitive positioning, and state-specific profitability.',
    `license_id` BIGINT COMMENT 'Foreign key linking to party.license. Business justification: Commission eligibility and payment often depend on active license status at transaction date.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Commission rates vary by line of business. FK enables LOB-specific producer compensation analysis, commission schedule management by line, and ensures commissions reference valid LOBs.',
    `original_commission_id` BIGINT COMMENT 'Foreign key to the original commission record that this transaction reverses or adjusts.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy associated with this commission.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this commission was earned.',
    `premium_transaction_id` BIGINT COMMENT 'Foreign key to the parent premium transaction that generated this commission.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key to the producer earning this commission.',
    `quote_id` BIGINT COMMENT 'Foreign key linking to coverage.quote. Business justification: Commission calculations reference quoted terms for rate structure, producer tier assignment, and override authorization.',
    `amount` DECIMAL(15,2) COMMENT 'The computed dollar amount of commission payable to the producer, calculated as basis amount multiplied by commission rate.',
    `basis` STRING COMMENT 'The premium or fee basis on which the commission is calculated: written premium, earned premium, policy fee, or installment fee.. Valid values are `written_premium|earned_premium|policy_fee|installment_fee`',
    `basis_amount` DECIMAL(15,2) COMMENT 'The dollar amount of premium or fee on which the commission is calculated.',
    `calculation_method` STRING COMMENT 'The method used to calculate the commission: flat rate, tiered structure, sliding scale, or manual override.. Valid values are `flat_rate|tiered|sliding_scale|manual_override`',
    `chargeback_indicator` BOOLEAN COMMENT 'Flag indicating whether this commission is a chargeback reversing a previously paid commission due to policy cancellation or return premium.',
    `chargeback_reason` STRING COMMENT 'Explanation for why the commission was charged back, typically due to policy cancellation, non-payment, or return premium.',
    `commission_status` STRING COMMENT 'Current lifecycle status of the commission: calculated, approved, pending payment, paid, reversed, or cancelled.. Valid values are `calculated|approved|pending_payment|paid|reversed|cancelled`',
    `commission_type` STRING COMMENT 'Type of commission: new business, renewal, endorsement, contingent, override, or bonus.. Valid values are `new_business|renewal|endorsement|contingent|override|bonus`',
    `contingent_indicator` BOOLEAN COMMENT 'Flag indicating whether this is a contingent commission based on volume, profitability, or other performance criteria.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this commission record was first created in the system.',
    `earned_date` DATE COMMENT 'The date on which the commission was earned, typically aligned with premium earning.',
    `effective_date` DATE COMMENT 'The date from which the commission becomes effective and eligible for payment.',
    `gl_account_code` STRING COMMENT 'The general ledger account code to which this commission expense is posted.',
    `modified_timestamp` TIMESTAMP COMMENT 'The timestamp when this commission record was last modified.',
    `net_payable_amount` DECIMAL(15,2) COMMENT 'The net commission amount payable to the producer after deductions, offsets, and withholdings.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding this commission transaction, including manual adjustments or special circumstances.',
    `override_indicator` BOOLEAN COMMENT 'Flag indicating whether this commission is an override commission paid to a managing or supervising producer.',
    `payment_date` DATE COMMENT 'The date on which the commission was paid to the producer.',
    `payment_method` STRING COMMENT 'The method used to pay the commission: ACH, wire transfer, check, offset against debit balance, or direct deposit.. Valid values are `ach|wire|check|offset|direct_deposit`',
    `payment_status` STRING COMMENT 'Payment status indicating whether the commission has been paid to the producer.. Valid values are `unpaid|paid|partially_paid|withheld|deferred`',
    `policy_transaction_type` STRING COMMENT 'The type of policy transaction that triggered this commission: new business, renewal, endorsement, cancellation, or reinstatement.. Valid values are `new_business|renewal|endorsement|cancellation|reinstatement`',
    `rate` DECIMAL(7,5) COMMENT 'The percentage rate applied to the basis to calculate the commission amount, expressed as a decimal.',
    `reversal_indicator` BOOLEAN COMMENT 'Flag indicating whether this commission transaction is a reversal of a prior commission entry.',
    `schedule_code` STRING COMMENT 'Code identifying the commission schedule or rate table used to calculate this commission.',
    `split_percentage` DECIMAL(5,2) COMMENT 'The percentage of the total commission allocated to this producer when commission is split among multiple producers.',
    `tax_withholding_amount` DECIMAL(15,2) COMMENT 'The amount of tax withheld from the commission payment, if applicable.',
    `tier_level` STRING COMMENT 'The producer tier or level within a tiered commission structure, affecting the commission rate.',
    `transaction_date` DATE COMMENT 'The date on which the commission transaction was recorded.',
    CONSTRAINT pk_commission PRIMARY KEY(`commission_id`)
) COMMENT 'Child of Premium Transaction. One row per producer commission calculation on a transaction: type (new/renewal/contingent), rate, basis, and computed payable. Calculation-only; commission settlement/payout is owned by the producers domain.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` (
    `earned_premium_schedule_id` BIGINT COMMENT 'Unique identifier for the earned premium schedule record. Primary key.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Earning schedules span accounting periods. FK enables period-based earning analysis, GAAP/IFRS17 reporting by period, and ensures schedules align with calendar dimensions for financial',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Earned premium schedules are peril-segregated for Schedule P reporting, loss ratio monitoring by peril, reinsurance accounting, and actuarial analysis.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period for which earned and unearned premium is calculated.',
    `coverage_id` BIGINT COMMENT 'Reference to the specific coverage for which this earning schedule applies.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Earning schedules track premium amounts in currency. FK enables FX-adjusted earning calculations, multi-currency GAAP/IFRS17 reporting, and ensures earned amounts reference valid currencies',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Earned premium schedules are geography-segregated for state-level statutory reporting, territorial profitability analysis, and regulatory compliance.',
    `insured_risk_id` BIGINT COMMENT 'Reference to the insured risk exposure associated with this earning schedule.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Earning patterns vary by line of business. FK enables LOB-specific earning analysis, GAAP/IFRS17 reporting by line, and ensures schedules reference valid LOBs for financial statements.',
    `policy_id` BIGINT COMMENT 'Reference to the policy contract for which premium is being earned.',
    `policy_term_id` BIGINT COMMENT 'Reference to the specific policy term period during which premium is earned.',
    `prior_schedule_id` BIGINT COMMENT 'Reference to the previous earning schedule that this schedule supersedes or adjusts.',
    `quote_id` BIGINT COMMENT 'Foreign key linking to coverage.quote. Business justification: Earned premium schedules are established at quote binding; earning patterns reference quoted term structure, effective dates, and premium allocation.',
    `adjustment_reason_code` STRING COMMENT 'Code indicating reason for schedule adjustment: endorsement, rate change, correction, audit, etc.',
    `cancellation_date` DATE COMMENT 'Date on which the policy or coverage was cancelled, affecting earned premium calculation.',
    `cancellation_reason_code` STRING COMMENT 'Code indicating reason for policy cancellation: non-payment, insured request, underwriting, etc.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this earning schedule record was first created in the system.',
    `cumulative_earned_amount` DECIMAL(18,2) COMMENT 'Total premium earned from effective date through the schedule date, cumulative sum.',
    `daily_earned_amount` DECIMAL(18,2) COMMENT 'Premium amount earned per day, used for daily pro-rata earning calculations.',
    `days_elapsed` BIGINT COMMENT 'Number of days elapsed from effective date to schedule date, used in pro-rata calculations.',
    `days_in_period` BIGINT COMMENT 'Total number of days in the coverage period for which premium is being earned.',
    `days_remaining` BIGINT COMMENT 'Number of days remaining from schedule date to expiration date, representing future coverage period.',
    `earned_premium_amount` DECIMAL(18,2) COMMENT 'Premium amount earned as of the schedule date, representing coverage provided to date.',
    `earning_method` STRING COMMENT 'Granularity at which premium is earned: daily, monthly, quarterly, annual, or event-based.. Valid values are `daily|monthly|quarterly|annual|event_based`',
    `earning_percentage` DECIMAL(5,2) COMMENT 'Percentage of total premium earned as of the schedule date, expressed as decimal.',
    `effective_date` DATE COMMENT 'Date from which this earning schedule becomes active and premium begins to earn.',
    `expiration_date` DATE COMMENT 'Date on which this earning schedule ends and premium is fully earned or terminated.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which earned and unearned premium amounts are posted.',
    `ifrs17_cohort_code` STRING COMMENT 'IFRS 17 cohort identifier for grouping contracts issued in same period with similar risk characteristics.',
    `is_minimum_earned` BOOLEAN COMMENT 'Indicates whether minimum earned premium rule applies, ensuring minimum premium is retained regardless of cancellation timing.',
    `is_prorated` BOOLEAN COMMENT 'Indicates whether premium earning is calculated using pro-rata method based on time elapsed.',
    `is_short_rate` BOOLEAN COMMENT 'Indicates whether premium earning uses short-rate method with penalty for mid-term cancellation.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Date and time when this earning schedule record was last modified or recalculated.',
    `minimum_earned_amount` DECIMAL(18,2) COMMENT 'Minimum premium amount that must be earned regardless of cancellation date, per policy terms.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding special earning rules, adjustments, or exceptions for this schedule.',
    `proration_factor` DECIMAL(10,8) COMMENT 'Decimal factor used to calculate earned premium, typically days elapsed divided by days in period.',
    `reporting_basis` STRING COMMENT 'Accounting basis for which this earning schedule is prepared: statutory, GAAP, IFRS 17, or tax.. Valid values are `statutory|gaap|ifrs17|tax`',
    `schedule_date` DATE COMMENT 'Specific date for which earned and unearned premium amounts are calculated in this schedule entry.',
    `schedule_number` STRING COMMENT 'Business identifier for the earning schedule, typically derived from policy and coverage identifiers.',
    `schedule_status` STRING COMMENT 'Current lifecycle status of the earning schedule: active, cancelled, expired, suspended, or adjusted.. Valid values are `active|cancelled|expired|suspended|adjusted`',
    `schedule_type` STRING COMMENT 'Method used to calculate earned premium: pro-rata, short-rate, or custom earning pattern.. Valid values are `pro_rata|short_rate|daily|monthly|annual|custom`',
    `short_rate_penalty_amount` DECIMAL(18,2) COMMENT 'Penalty amount applied when policy is cancelled mid-term using short-rate method, reducing return premium.',
    `short_rate_percentage` DECIMAL(5,2) COMMENT 'Percentage applied for short-rate cancellation, typically higher than pro-rata to penalize early termination.',
    `statutory_line_code` STRING COMMENT 'NAIC statutory accounting line code used for Schedule P and regulatory financial reporting.',
    `total_premium_amount` DECIMAL(18,2) COMMENT 'Total written premium amount subject to earning over the coverage period.',
    `unearned_premium_amount` DECIMAL(18,2) COMMENT 'Premium amount not yet earned as of the schedule date, representing future coverage obligation.',
    CONSTRAINT pk_earned_premium_schedule PRIMARY KEY(`earned_premium_schedule_id`)
) COMMENT 'Pro-rata or short-rate earning schedule for a Coverage within a Policy Term. Defines daily or monthly earned and unearned premium amounts used to compute EP at any in-force date. Supports IFRS 17 and Schedule P actuarial triangles.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` (
    `premium_endorsement_id` BIGINT COMMENT 'Unique identifier for the premium endorsement record.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Endorsements posted to accounting periods. FK enables period-based transaction analysis, fiscal year endorsement reporting, and ensures endorsements align with calendar dimensions for',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Mid-term endorsements post-catastrophe (coverage changes, cancellations, reinstatements) must link to triggering events for claims handling coordination, underwriting',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Endorsements adding or removing peril coverage require explicit peril linkage for coverage verification, claims adjudication, underwriting approval, and regulatory compliance.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Foreign key to the Accounting Period in which this endorsement premium change is booked.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Endorsement premium changes denominated in currency. FK enables currency validation, FX conversion for consolidated endorsement reporting, and ensures policy change amounts reference valid',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Endorsements changing risk location require geographic linkage for rate adjustment, territorial rating factor application, tax recalculation, and jurisdictional compliance.',
    `invoice_id` BIGINT COMMENT 'Foreign key to the Invoice generated for this endorsement, if billable.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Endorsements categorized by line of business. FK enables LOB-specific transaction analysis, regulatory reporting by line, and ensures endorsements reference valid LOBs for statutory',
    `party_id` BIGINT COMMENT 'Foreign key to the Underwriter who approved this endorsement.',
    `policy_id` BIGINT COMMENT 'Foreign key to the Policy being endorsed.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the Policy Term affected by this endorsement.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key to the Policy Transaction that triggered this premium endorsement (endorsement, cancellation, reinstatement).',
    `producers_producer_id` BIGINT COMMENT 'Foreign key to the Producer (agent or broker) of record at the time of endorsement.',
    `reversed_endorsement_id` BIGINT COMMENT 'Foreign key to the original Premium Endorsement record being reversed, if this is a reversal transaction.',
    `uw_decision_id` BIGINT COMMENT 'Foreign key linking to coverage.uw_decision. Business justification: Premium endorsements triggered by underwriting decisions (coverage changes, condition fulfillment, risk tier adjustments) require decision reference for audit trail, authority',
    `billing_status` STRING COMMENT 'Current billing status of the endorsement premium change.. Valid values are `Pending|Billed|Paid|Partially Paid|Refunded|Written Off`',
    `ceded_premium_change_amount` DECIMAL(18,2) COMMENT 'Portion of the premium change ceded to reinsurers under treaty or facultative agreements.',
    `commission_change_amount` DECIMAL(18,2) COMMENT 'Change in producer commission payable resulting from the endorsement premium change.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this premium endorsement record was first created in the data warehouse.',
    `days_in_term_remaining` BIGINT COMMENT 'Number of days remaining in the policy term from the endorsement effective date to term expiration.',
    `earned_premium_change_amount` DECIMAL(18,2) COMMENT 'Change in earned premium resulting from the endorsement, calculated based on the earning pattern.',
    `endorsement_number` STRING COMMENT 'Business identifier for the endorsement transaction, typically sequential within the policy term.',
    `fee_change_amount` DECIMAL(18,2) COMMENT 'Change in policy fees (policy fee, installment fee, service fee) resulting from the endorsement.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which the premium change is posted.',
    `gross_premium_change_amount` DECIMAL(18,2) COMMENT 'Gross premium change before deducting ceded reinsurance amounts.',
    `is_billable` BOOLEAN COMMENT 'Indicates whether this endorsement generates a billing transaction (true for additional premium, false for return premium credited).',
    `net_premium_change_amount` DECIMAL(18,2) COMMENT 'Net change in premium resulting from this endorsement; positive for additional premium, negative for return premium.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding the endorsement transaction.',
    `proration_factor` DECIMAL(10,6) COMMENT 'Decimal factor applied to calculate the prorated premium change (e.g., 0.5 for half-term).',
    `proration_method` STRING COMMENT 'Method used to calculate the premium change for mid-term endorsements or cancellations.. Valid values are `Pro-Rata|Short-Rate|Flat|Daily|Monthly`',
    `reversal_indicator` BOOLEAN COMMENT 'Indicates whether this endorsement record is a reversal of a prior endorsement.',
    `reversal_reason_code` STRING COMMENT 'Code indicating the reason for reversing the endorsement (e.g., data entry error, policy rescission).',
    `reversal_reason_description` STRING COMMENT 'Detailed description of why the endorsement was reversed.',
    `source_system_code` STRING COMMENT 'Code identifying the source system that originated this endorsement record (e.g., PolicyCenter, Duck Creek Policy).',
    `source_system_transaction_code` STRING COMMENT 'Unique transaction identifier from the source policy administration system.',
    `statutory_line_code` STRING COMMENT 'NAIC statutory accounting line code for regulatory reporting purposes.',
    `tax_change_amount` DECIMAL(18,2) COMMENT 'Change in taxes (premium tax, surplus lines tax, stamping fees) resulting from the endorsement.',
    `total_charge_change_amount` DECIMAL(18,2) COMMENT 'Total change in all charges (premium, taxes, fees) billed to the policyholder.',
    `transaction_effective_date` DATE COMMENT 'Date the endorsement transaction becomes effective for coverage and premium purposes.',
    `transaction_reason_code` STRING COMMENT 'Code indicating the business reason for the endorsement (e.g., coverage change, insured risk addition, address correction).',
    `transaction_reason_description` STRING COMMENT 'Detailed description of why the endorsement was issued.',
    `transaction_timestamp` TIMESTAMP COMMENT 'Timestamp when the endorsement transaction was processed in the system.',
    `transaction_type` STRING COMMENT 'Type of policy transaction that generated this premium change.. Valid values are `Endorsement|Cancellation|Reinstatement|Flat Cancellation|Pro-Rata Cancellation|Short-Rate Cancellation`',
    `unearned_premium_change_amount` DECIMAL(18,2) COMMENT 'Change in unearned premium reserve resulting from the endorsement.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this premium endorsement record was last updated in the data warehouse.',
    `written_premium_change_amount` DECIMAL(18,2) COMMENT 'Change in written premium booked at the transaction effective date.',
    CONSTRAINT pk_premium_endorsement PRIMARY KEY(`premium_endorsement_id`)
) COMMENT 'Records the net premium change (additional or return) generated by a Policy Transaction endorsement, cancellation, or reinstatement. Links the endorsing Policy Transaction to the resulting Premium Transactions and charge breakdown.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` (
    `rate_table_id` BIGINT COMMENT 'Unique identifier for the rate table version. Primary key.',
    `cat_model_version_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_model_version. Business justification: Rating tables reference specific catastrophe model versions for catastrophe load factors, territorial relativities, regulatory filing support, and actuarial',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Rating tables are zone-specific with different base rates, territorial factors, and catastrophe loadings by geographic hazard.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Rate tables are peril-specific (wind vs. earthquake vs. flood) with distinct actuarial bases, loss costs, regulatory filings, and coverage definitions.',
    `classification_code_id` BIGINT COMMENT 'Foreign key linking to shared.classification_code. Business justification: Rate tables vary by classification code (NCCI, ISO GL class). FK enables class-specific rating, regulatory filing validation, and ensures class_code_range references valid',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Rate tables denominated in specific currencies. FK enables currency-specific rating, FX conversion for international rating, and ensures rates reference valid currencies for underwriting and',
    `filing_organization_id` BIGINT COMMENT 'Foreign key linking to party.organization. Business justification: Rate tables are filed by or on behalf of specific carrier organizations or MGAs. Linking rate_table to organization supports regulatory compliance (which entity filed this rate)',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Rating tables are geography-specific with territorial base rates, protection class adjustments, jurisdiction-specific factors, and regulatory filing requirements.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Rate tables specific to line of business. FK enables LOB-specific rating, regulatory filing management by line, and ensures rates reference valid LOBs for underwriting and pricing.',
    `unit_of_measure_id` BIGINT COMMENT 'Foreign key linking to shared.unit_of_measure. Business justification: Rate tables specify rating basis measured in units (per vehicle, per $1000 payroll).',
    `actuarial_memo_reference` STRING COMMENT 'Reference number or document identifier for the actuarial memorandum supporting this rate table filing.',
    `approval_date` DATE COMMENT 'Date when the state regulator approved this rate table for use.',
    `approval_status` STRING COMMENT 'Current regulatory approval status of this rate table version.. Valid values are `draft|filed|approved|rejected|withdrawn|superseded`',
    `base_rate_amount` DECIMAL(15,4) COMMENT 'Primary rate value or starting premium amount before application of factors and adjustments.',
    `rate_table_code` STRING COMMENT 'Business identifier for the rate table, typically combining LOB, state, and version components for external reference.',
    `coverage_code` STRING COMMENT 'Specific coverage or peril this rate table applies to, such as liability, collision, comprehensive, or property.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this rate table record was first created in the data platform.',
    `credibility_factor` DECIMAL(5,4) COMMENT 'Actuarial credibility weight applied to experience data used to develop this rate table, ranging from 0 to 1.',
    `deductible_amount` DECIMAL(15,2) COMMENT 'Standard deductible level this rate table is designed for, if rate varies by deductible.',
    `effective_date` DATE COMMENT 'Date when this rate table version becomes active and available for policy rating.',
    `expense_provision_percentage` DECIMAL(5,2) COMMENT 'Percentage load for underwriting expenses, commissions, and overhead included in the rate.',
    `expiration_date` DATE COMMENT 'Date when this rate table version is superseded or withdrawn from use. Null indicates currently active.',
    `filing_date` DATE COMMENT 'Date when this rate table was submitted to the state regulator for approval.',
    `filing_number` STRING COMMENT 'State Department of Insurance filing reference number for regulatory approval of this rate table.',
    `is_file_and_use` BOOLEAN COMMENT 'Indicates whether this rate table was implemented under file-and-use regulatory framework, requiring filing before use but not prior approval.',
    `is_prior_approval` BOOLEAN COMMENT 'Indicates whether this rate table required prior regulatory approval before implementation.',
    `is_use_and_file` BOOLEAN COMMENT 'Indicates whether this rate table was implemented under use-and-file regulatory framework, allowing immediate use before approval.',
    `iso_program_code` STRING COMMENT 'ISO program or form edition code if this rate table is based on ISO advisory rates or forms.',
    `limit_amount` DECIMAL(15,2) COMMENT 'Standard coverage limit this rate table is designed for, if rate varies by limit.',
    `loss_cost_basis` DECIMAL(15,4) COMMENT 'Actuarial loss cost per exposure unit underlying this rate table, before expense and profit loads.',
    `maximum_premium_amount` DECIMAL(15,2) COMMENT 'Ceiling premium amount that cannot be exceeded for this rate table, if applicable.',
    `minimum_premium_amount` DECIMAL(15,2) COMMENT 'Floor premium amount that must be charged regardless of calculated premium for this rate table.',
    `modified_timestamp` TIMESTAMP COMMENT 'System timestamp when this rate table record was last updated in the data platform.',
    `rate_table_name` STRING COMMENT 'Human-readable name describing the rate table purpose and scope.',
    `notes` STRING COMMENT 'Free-text field for additional comments, special instructions, or context about this rate table version.',
    `profit_provision_percentage` DECIMAL(5,2) COMMENT 'Percentage load for underwriting profit and contingencies included in the rate.',
    `published_date` DATE COMMENT 'Date when this rate table version was released to the rating engine and made available for policy transactions.',
    `rate_change_percentage` DECIMAL(5,2) COMMENT 'Overall percentage increase or decrease from the prior rate table version, used for regulatory filing disclosure.',
    `rate_manual_edition` STRING COMMENT 'Edition or publication date of the rate manual or rating guide this table is published in.',
    `rate_source` STRING COMMENT 'Origin of the rate data: proprietary company rates, ISO advisory, NCCI, state-mandated manual, or competitor benchmark.. Valid values are `proprietary|iso_advisory|ncci|state_manual|competitor_benchmark`',
    `rate_table_status` STRING COMMENT 'Current operational status of this rate table version in the rating engine.. Valid values are `active|inactive|pending|superseded|withdrawn`',
    `rate_type` STRING COMMENT 'Classification of rate content: base rates, rating factors, minimum premiums, surcharges, discounts, or credits.. Valid values are `base|factor|minimum|surcharge|discount|credit`',
    `rating_algorithm_code` STRING COMMENT 'Identifier for the calculation method or formula used to apply this rate table during policy rating.',
    `state_code` STRING COMMENT 'Two-letter US state or territory code where this rate table is filed and approved for use.',
    `territory_definition` STRING COMMENT 'Geographic territory or rating zone structure this rate table applies to, such as county groups or ZIP code ranges.',
    `trend_factor` DECIMAL(5,4) COMMENT 'Actuarial trend adjustment factor applied to historical loss data to project future losses for this rate table.',
    `version_number` STRING COMMENT 'Sequential version identifier for this rate table edition, incremented with each filing or update.',
    `withdrawn_date` DATE COMMENT 'Date when this rate table version was removed from active use in the rating engine.',
    CONSTRAINT pk_rate_table PRIMARY KEY(`rate_table_id`)
) COMMENT 'Versioned rate table published by the rating engine for a specific LOB, state, and effective date. Stores base rates, factors, and minimum premiums. Provides the authoritative rate version used to price each Policy Term.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` (
    `audit_id` BIGINT COMMENT 'Unique identifier for the premium_audit data product (auto-inserted during validation).',
    `auditor_individual_id` BIGINT COMMENT 'Foreign key linking to party.individual. Business justification: Premium auditors are individuals. Linking premium_audit to individual (rather than just storing auditor_name as text) enables operational reporting (auditor workload, quality metrics)',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Audits completed in accounting periods. FK enables period-based audit reporting, fiscal year audit analysis, and ensures audits align with calendar dimensions for premium reconciliation.',
    `claim_expense_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.claim_expense. Business justification: Premium audits often incur adjuster fees, inspection costs, and other LAE that must be allocated to the audited policys claim experience for accurate loss ratio calculation and',
    `claim_id` BIGINT COMMENT 'Foreign key linking to claims.claim. Business justification: Premium audits frequently discover unreported claims or validate that reported losses align with audited exposure.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Audit premium amounts in currency. FK enables multi-currency audit reconciliation, FX conversion for consolidated audit reporting, and ensures audited amounts reference valid currencies for',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Premium audits verify geographic exposure distribution for multi-state accounts, proper rate application, territorial rating factors, and regulatory compliance.',
    `invoice_id` BIGINT COMMENT 'Foreign key linking to billing.invoice. Business justification: Premium audits generate additional premium invoices for audit adjustments. Billing operations must trace invoices back to the audit that triggered them for dispute resolution, audit',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Audits specific to line of business. FK enables LOB-specific audit analysis, exposure verification by line, and ensures audits reference valid LOBs for premium reconciliation.',
    `policy_id` BIGINT COMMENT 'Reference to the policy being audited.',
    `policy_term_id` BIGINT COMMENT 'Reference to the specific policy term under audit.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key linking to producers.producers_producer. Business justification: Premium audits on commercial policies are often conducted by producers with underwriting authority or by agency staff.',
    `quote_id` BIGINT COMMENT 'Foreign key linking to coverage.quote. Business justification: Premium audits reconcile actual exposures to original quote estimates; variance analysis requires quote reference for estimated vs audited exposure comparison.',
    `unit_of_measure_id` BIGINT COMMENT 'Foreign key linking to shared.unit_of_measure. Business justification: Premium audits verify exposure measured in units. FK enables unit-based audit reconciliation, conversion, and ensures exposure_basis_code references valid UOMs for premium adjustment',
    `additional_premium_amount` DECIMAL(15,2) COMMENT 'Additional premium owed by the policyholder if audited premium exceeds estimated premium.',
    `audit_number` STRING COMMENT 'Unique business identifier for this premium audit.',
    `audit_status` STRING COMMENT 'Current lifecycle status of the premium audit.. Valid values are `scheduled|in_progress|completed|cancelled|disputed`',
    `audit_type` STRING COMMENT 'Type of premium audit being performed.. Valid values are `final|interim|cancellation|reinstatement`',
    `audited_exposure` DECIMAL(18,2) COMMENT 'Actual exposure basis determined during the audit based on policyholder records.',
    `audited_premium_amount` DECIMAL(15,2) COMMENT 'Final premium amount calculated based on audited exposure.',
    `billing_adjustment_status` STRING COMMENT 'Status of billing adjustments triggered by the audit results.. Valid values are `not_required|pending|processed|failed`',
    `completion_date` DATE COMMENT 'Date when the audit was completed and finalized.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this audit record was first created in the system.',
    `deposit_reconciliation_status` STRING COMMENT 'Status of the deposit premium reconciliation process following the audit.. Valid values are `pending|reconciled|disputed|waived`',
    `dispute_flag` BOOLEAN COMMENT 'Indicates whether the policyholder has disputed the audit findings.',
    `dispute_reason` STRING COMMENT 'Reason provided by the policyholder for disputing the audit results.',
    `dispute_resolution_date` DATE COMMENT 'Date when the audit dispute was resolved.',
    `estimated_exposure` DECIMAL(18,2) COMMENT 'Original estimated exposure basis used to calculate deposit or estimated premium at policy inception.',
    `estimated_premium_amount` DECIMAL(15,2) COMMENT 'Original estimated or deposit premium amount charged at policy inception.',
    `exposure_basis_description` STRING COMMENT 'Description of the exposure basis used for premium calculation.',
    `exposure_variance` DECIMAL(18,2) COMMENT 'Difference between audited exposure and estimated exposure (audited minus estimated).',
    `exposure_variance_percentage` DECIMAL(5,2) COMMENT 'Percentage variance between audited and estimated exposure.',
    `is_minimum_premium_applied` BOOLEAN COMMENT 'Indicates whether the minimum premium was applied during the audit.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this audit record was last updated.',
    `method` STRING COMMENT 'Method used to conduct the audit (physical inspection, desk review, mail, phone, electronic).. Valid values are `physical|desk|mail|phone|electronic`',
    `minimum_premium_amount` DECIMAL(15,2) COMMENT 'Minimum premium threshold applicable to the policy, below which the audited premium cannot fall.',
    `notes` STRING COMMENT 'Free-text notes and observations recorded by the auditor during the audit process.',
    `period_end_date` DATE COMMENT 'End date of the policy period being audited.',
    `period_start_date` DATE COMMENT 'Start date of the policy period being audited.',
    `policyholder_signature_date` DATE COMMENT 'Date when the policyholder signed the audit acknowledgment or agreement.',
    `premium_variance_amount` DECIMAL(15,2) COMMENT 'Difference between audited premium and estimated premium (audited minus estimated). Positive indicates additional premium due; negative indicates return premium.',
    `return_premium_amount` DECIMAL(15,2) COMMENT 'Premium to be returned to the policyholder if audited premium is less than estimated premium.',
    `scheduled_date` DATE COMMENT 'Date when the audit was scheduled to occur.',
    `start_date` DATE COMMENT 'Date when the audit fieldwork or review began.',
    `waiver_flag` BOOLEAN COMMENT 'Indicates whether the audit requirement was waived for this policy.',
    `waiver_reason` STRING COMMENT 'Reason for waiving the audit requirement.',
    CONSTRAINT pk_audit PRIMARY KEY(`audit_id`)
) COMMENT 'Result of a final or interim audit for auditable policies (WC, GL, CGL). Captures audited exposure basis, audited premium, variance from estimated/deposit premium, and deposit reconciliation status. Triggers additional or return premium transactions.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` (
    `bearing_coverage_id` BIGINT COMMENT 'Unique identifier for the bearing coverage allocation record. Primary key.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Coverage allocations posted to accounting periods. FK enables period-based allocation reporting, fiscal year coverage analysis, and ensures allocations align with calendar dimensions for',
    `coverage_id` BIGINT COMMENT 'Foreign key to the specific coverage that this premium transaction applies to.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Coverage allocation amounts in currency. FK enables multi-currency allocation reporting, FX conversion for consolidated coverage analysis, and ensures allocated amounts reference valid',
    `insured_risk_id` BIGINT COMMENT 'Foreign key to the insured risk (property, vehicle, driver, etc.) that this premium transaction applies to.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Coverage allocations by line of business. FK enables LOB-specific allocation reporting, regulatory reporting by line, and ensures allocations reference valid LOBs for statutory',
    `original_bearing_coverage_id` BIGINT COMMENT 'Foreign key to the original bearing coverage record that this record reverses or adjusts.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy that this bearing coverage allocation is associated with.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term that this bearing coverage allocation is associated with.',
    `primary_premium_transaction_id` BIGINT COMMENT 'Foreign key to the premium transaction that this bearing coverage allocation applies to.',
    `premium_transaction_id` BIGINT COMMENT 'Unique identifier of this allocation record in the source system for traceability and reconciliation.',
    `allocated_amount` DECIMAL(15,2) COMMENT 'Dollar amount of premium allocated to this specific coverage from the parent premium transaction.',
    `allocation_basis` STRING COMMENT 'Basis for premium allocation: Total Insured Value (TIV), exposure units, coverage limit, rate, or manual entry.. Valid values are `tiv|exposure|limit|rate|manual`',
    `allocation_percentage` DECIMAL(7,4) COMMENT 'Percentage of the premium transaction allocated to this coverage, expressed as a decimal (e.g., 0.2500 for 25%).',
    `allocation_sequence` BIGINT COMMENT 'Sequence number for ordering multiple coverage allocations within a single premium transaction.',
    `allocation_status` STRING COMMENT 'Current status of this bearing coverage allocation: active, reversed, adjusted, voided, or pending.. Valid values are `active|reversed|adjusted|voided|pending`',
    `allocation_type` STRING COMMENT 'Method used to allocate premium to this coverage: direct assignment, proportional split, specific calculation, manual override, or system-calculated.. Valid values are `direct|proportional|specific|manual|system_calculated|override`',
    `ceded_amount` DECIMAL(15,2) COMMENT 'Dollar amount of the allocated premium that is ceded to reinsurers under treaty or facultative agreements.',
    `commission_amount` DECIMAL(15,2) COMMENT 'Dollar amount of producer commission calculated on this allocated premium.',
    `commission_rate` DECIMAL(7,4) COMMENT 'Commission rate applied to this allocated premium, expressed as a decimal (e.g., 0.1500 for 15%).',
    `coverage_description` STRING COMMENT 'Human-readable description of the coverage to which premium is allocated (e.g., Dwelling, Liability, Collision).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this bearing coverage allocation record was first created in the data warehouse.',
    `effective_date` DATE COMMENT 'Date from which this bearing coverage allocation becomes effective.',
    `expiration_date` DATE COMMENT 'Date on which this bearing coverage allocation expires or is superseded.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this allocated premium is posted for financial accounting.',
    `is_ceded` BOOLEAN COMMENT 'Indicates whether this allocated premium is subject to reinsurance cession (true) or retained net (false).',
    `is_commissionable` BOOLEAN COMMENT 'Indicates whether this allocated premium is subject to producer commission (true) or non-commissionable (false).',
    `is_primary_coverage` BOOLEAN COMMENT 'Indicates whether this is the primary coverage allocation for the premium transaction (true) or a secondary/split allocation (false).',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this bearing coverage allocation record was last updated in the data warehouse.',
    `net_amount` DECIMAL(15,2) COMMENT 'Net retained premium amount after reinsurance cession (allocated_amount minus ceded_amount).',
    `notes` STRING COMMENT 'Free-text notes or comments regarding this bearing coverage allocation, including manual override justifications or special handling instructions.',
    `reversal_date` DATE COMMENT 'Date on which this bearing coverage allocation was reversed or voided.',
    `reversal_reason_code` STRING COMMENT 'Code indicating the reason this allocation was reversed or voided (e.g., policy cancellation, endorsement correction).',
    `risk_type` STRING COMMENT 'Type of insured risk this allocation applies to: property, auto, liability, workers compensation, umbrella, inland marine, or other. [ENUM-REF-CANDIDATE: property|auto|liability|workers_comp|umbrella|inland_marine|other — 7 candidates stripped; promote to',
    `source_system_code` STRING COMMENT 'Code identifying the source system that created this bearing coverage allocation (e.g., PAS, billing system, rating engine).',
    `statutory_line_code` STRING COMMENT 'NAIC statutory line of business code for regulatory reporting and Schedule P classification.',
    `transaction_booking_date` DATE COMMENT 'Date on which this bearing coverage allocation was booked in the financial system.',
    CONSTRAINT pk_bearing_coverage PRIMARY KEY(`bearing_coverage_id`)
) COMMENT 'Association table linking a Premium Transaction to the specific Coverage and Insured Risk it applies to. Grain: one row per coverage allocation per premium transaction. Prevents fan-out double-counting when premium splits across multiple coverages.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` (
    `ceded_premium_id` BIGINT COMMENT 'Unique identifier for the ceded premium transaction record. Primary key.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Cessions posted to accounting periods. FK enables period-based reinsurance reporting, fiscal year cession analysis, and ensures cessions align with calendar dimensions for bordereaux',
    `cat_model_version_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_model_version. Business justification: Reinsurance cessions reference model versions for treaty pricing validation, exposure aggregation consistency, and reinsurer reporting requirements.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Ceded premium must track catastrophe event attribution for treaty settlement, reinstatement premium calculation, loss corridor analysis, and bordereaux reporting.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Reinsurance cessions are peril-segregated for treaty-specific coverage (wind-only treaties, earthquake facultative, flood exclusions) and settlement.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which the ceded premium transaction is recorded.',
    `coverage_id` BIGINT COMMENT 'Reference to the specific coverage line for which premium is ceded.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Ceded premium amounts in currency. Multi-currency reinsurance accounting requires proper FK for currency validation, FX conversion, and accurate bordereaux reporting to international',
    `fac_agreement_id` BIGINT COMMENT 'Reference to the facultative agreement if cession is facultative placement.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Reinsurance cessions require geographic attribution for treaty territory definitions, regulatory reporting, bordereaux preparation, and geographic concentration monitoring.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Cessions vary by line of business. FK enables LOB-specific reinsurance reporting, treaty management by line, and ensures cessions reference valid LOBs for bordereaux reporting.',
    `original_ceded_premium_id` BIGINT COMMENT 'Reference to the original ceded premium transaction if this is a reversal or adjustment.',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which premium is ceded to reinsurers.',
    `policy_term_id` BIGINT COMMENT 'Reference to the specific policy term period for which premium is ceded.',
    `rating_worksheet_id` BIGINT COMMENT 'Foreign key linking to coverage.rating_worksheet. Business justification: Ceded premium calculations reference rating worksheets to determine cession basis, validate treaty attachment points, and support reinsurance bordereaux reporting.',
    `reinsurer_id` BIGINT COMMENT 'Reference to the reinsurer receiving the ceded premium.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the reinsurance agreement (treaty or facultative) under which premium is ceded.',
    `premium_transaction_id` BIGINT COMMENT 'Unique identifier of the transaction in the source system for traceability and reconciliation.',
    `treaty_id` BIGINT COMMENT 'Reference to the treaty agreement if cession is under a treaty arrangement.',
    `bordereaux_reporting_flag` BOOLEAN COMMENT 'Indicates whether this ceded premium transaction is included in bordereaux reporting to the reinsurer.',
    `bordereaux_submission_date` DATE COMMENT 'Date on which the bordereaux report containing this ceded premium was submitted to the reinsurer.',
    `ceded_earned_premium` DECIMAL(18,2) COMMENT 'Amount of earned premium ceded to the reinsurer, recognized over the coverage period.',
    `ceded_unearned_premium` DECIMAL(18,2) COMMENT 'Amount of unearned premium ceded to the reinsurer, representing future coverage obligation.',
    `ceded_written_premium` DECIMAL(18,2) COMMENT 'Amount of written premium ceded to the reinsurer under the agreement.',
    `ceding_commission_amount` DECIMAL(18,2) COMMENT 'Dollar amount of ceding commission received from the reinsurer on ceded premium.',
    `ceding_commission_rate` DECIMAL(8,6) COMMENT 'Commission rate paid by the reinsurer to the ceding company on ceded premium.',
    `cession_basis` STRING COMMENT 'Basis on which premium is ceded: quota share, surplus, excess of loss, stop loss, or facultative.. Valid values are `quota_share|surplus|excess_of_loss|stop_loss|facultative`',
    `cession_number` STRING COMMENT 'Business identifier for the cession transaction, used for tracking and reconciliation.',
    `cession_rate` DECIMAL(8,6) COMMENT 'Percentage or rate at which premium is ceded to the reinsurer under the agreement.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the ceded premium record was first created in the system.',
    `effective_date` DATE COMMENT 'Date from which the ceded premium transaction becomes effective for accounting and reporting purposes.',
    `expiration_date` DATE COMMENT 'Date on which the ceded premium transaction expires or is no longer in force.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which the ceded premium transaction is posted.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the ceded premium record was last modified in the system.',
    `net_ceded_premium` DECIMAL(18,2) COMMENT 'Net premium ceded after deducting ceding commission and other adjustments.',
    `notes` STRING COMMENT 'Free-form text notes or comments related to the ceded premium transaction.',
    `profit_commission_amount` DECIMAL(18,2) COMMENT 'Dollar amount of profit commission earned on the ceded premium under the reinsurance agreement.',
    `profit_commission_rate` DECIMAL(8,6) COMMENT 'Profit commission rate applicable to the ceded premium under the reinsurance agreement.',
    `reversal_indicator` BOOLEAN COMMENT 'Indicates whether this ceded premium transaction is a reversal of a prior transaction.',
    `reversal_reason_code` STRING COMMENT 'Code indicating the reason for reversing the ceded premium transaction.',
    `settlement_date` DATE COMMENT 'Date on which the ceded premium transaction was settled with the reinsurer.',
    `settlement_status` STRING COMMENT 'Current settlement status of the ceded premium transaction with the reinsurer.. Valid values are `pending|settled|disputed|reversed`',
    `source_system_code` STRING COMMENT 'Code identifying the source system from which the ceded premium transaction originated.',
    `state_code` STRING COMMENT 'Two-letter state code where the underlying policy was issued or risk is located.. Valid values are `^[A-Z]{2}$`',
    `statutory_line_code` STRING COMMENT 'NAIC statutory line of business code for regulatory reporting purposes.',
    `transaction_date` DATE COMMENT 'Date on which the ceded premium transaction was recorded in the system.',
    `transaction_type` STRING COMMENT 'Type of ceded premium transaction: written, earned, unearned, return, adjustment, or reversal.. Valid values are `written|earned|unearned|return|adjustment|reversal`',
    CONSTRAINT pk_ceded_premium PRIMARY KEY(`ceded_premium_id`)
) COMMENT 'Records premium ceded to reinsurers under a Treaty or Facultative Agreement per Policy Term and Coverage; ceded written/earned/unearned by accounting period. Candidate for relocation to Reinsurance, which owns the cession ledger.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` (
    `minimum_earned_premium_id` BIGINT COMMENT 'Unique identifier for the minimum earned premium rule. Primary key.',
    `coverage_id` BIGINT COMMENT 'Reference to the coverage to which this minimum earned premium applies. Nullable if rule applies at policy term level.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Minimum premium amounts denominated in currency. FK enables currency-specific minimum premium rules, FX conversion for international policies, and ensures minimums reference valid currencies.',
    `policy_id` BIGINT COMMENT 'Reference to the policy to which this minimum earned premium rule applies.',
    `policy_term_id` BIGINT COMMENT 'Reference to the specific policy term for which this minimum earned premium threshold is defined.',
    `application_level` STRING COMMENT 'Level at which the minimum earned premium rule applies: policy term, coverage, or insured risk.. Valid values are `policy_term|coverage|insured_risk`',
    `applies_to_endorsement_flag` BOOLEAN COMMENT 'Indicates whether this minimum earned premium rule applies to endorsement transactions.',
    `applies_to_new_business_flag` BOOLEAN COMMENT 'Indicates whether this minimum earned premium rule applies to new business transactions.',
    `applies_to_renewal_flag` BOOLEAN COMMENT 'Indicates whether this minimum earned premium rule applies to renewal transactions.',
    `calculation_method` STRING COMMENT 'Method used to determine the minimum earned premium: fixed amount, percentage of written premium, or combination logic.. Valid values are `fixed_amount|percentage|greater_of_both|lesser_of_both`',
    `cancellation_type` STRING COMMENT 'Type of cancellation to which this minimum earned premium rule applies: flat, short-rate, pro-rata, or all cancellation types.. Valid values are `flat|short_rate|pro_rata|all`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this minimum earned premium rule record was first created in the system.',
    `effective_date` DATE COMMENT 'Date from which this minimum earned premium rule becomes active and enforceable.',
    `expiration_date` DATE COMMENT 'Date on which this minimum earned premium rule ceases to be active. Nullable for open-ended rules.',
    `filing_approval_date` DATE COMMENT 'Date on which the regulatory authority approved this minimum earned premium rule for use.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which minimum earned premium amounts are posted for financial reporting.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this minimum earned premium rule record was last updated.',
    `lob_code` STRING COMMENT 'Line of business code for which this minimum earned premium rule is defined.',
    `minimum_amount` DECIMAL(18,2) COMMENT 'The floor amount of earned premium that must be retained by the insurer regardless of cancellation timing or return premium calculation.',
    `minimum_days_in_force` BIGINT COMMENT 'Minimum number of days the policy must be in force before the minimum earned premium rule applies. Nullable if no threshold exists.',
    `minimum_earned_premium_status` STRING COMMENT 'Current lifecycle status of the minimum earned premium rule.. Valid values are `active|inactive|superseded|pending`',
    `notes` STRING COMMENT 'Free-text notes providing additional context or business rationale for this minimum earned premium rule.',
    `override_allowed_flag` BOOLEAN COMMENT 'Indicates whether underwriters are permitted to override this minimum earned premium rule with proper authorization.',
    `override_authority_level` STRING COMMENT 'Authority level required to override this minimum earned premium rule, such as senior underwriter or regional manager.',
    `percentage_of_written_premium` DECIMAL(5,2) COMMENT 'Minimum earned premium expressed as a percentage of the total written premium. Used when rule is percentage-based rather than fixed amount.',
    `proration_method` STRING COMMENT 'Method used to prorate the minimum earned premium when the policy term is partial or adjusted.. Valid values are `daily|monthly|annual|none`',
    `regulatory_filing_reference` STRING COMMENT 'Reference number or identifier of the regulatory filing that approved this minimum earned premium rule.',
    `rule_code` STRING COMMENT 'Business code identifying the minimum earned premium rule type or schedule.',
    `rule_name` STRING COMMENT 'Descriptive name of the minimum earned premium rule for business users.',
    `source_system_code` STRING COMMENT 'Code identifying the source system from which this minimum earned premium rule originated.',
    `state_code` STRING COMMENT 'Two-letter state or jurisdiction code where this minimum earned premium rule applies. Nullable for national rules.',
    `statutory_line_code` STRING COMMENT 'NAIC statutory line of business code for regulatory reporting of minimum earned premium.',
    `waiver_authorized_by` STRING COMMENT 'Name or identifier of the person who authorized the waiver of this minimum earned premium rule.',
    `waiver_date` DATE COMMENT 'Date on which the minimum earned premium rule was waived.',
    `waiver_reason_code` STRING COMMENT 'Code indicating the reason this minimum earned premium rule was waived, if applicable.',
    CONSTRAINT pk_minimum_earned_premium PRIMARY KEY(`minimum_earned_premium_id`)
) COMMENT 'Defines the minimum earned premium threshold for a Coverage or Policy Term that applies on short-rate or flat cancellation. Ensures the insurer retains a floor amount regardless of cancellation timing or return premium calculation.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` (
    `retrospective_adjustment_id` BIGINT COMMENT 'Unique identifier for the retrospective premium adjustment record.',
    `adjustment_invoice_id` BIGINT COMMENT 'Foreign key linking to billing.invoice. Business justification: Retrospective rating adjustments generate additional premium invoices. Billing must reference the retro adjustment for premium reconciliation, policyholder inquiries, and audit trails.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Retrospective adjustments posted to accounting periods. FK enables period-based retro analysis, fiscal year retro reporting, and ensures adjustments align with calendar dimensions for',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Retro adjustments require zone-level loss aggregation for experience rating, geographic profitability analysis, and underwriting review. Essential for large account management.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Retro-rated policies require catastrophe event linkage for loss development exclusions, final premium calculation, and policyholder reporting.',
    `claim_id` BIGINT COMMENT 'Foreign key linking to claims.claim. Business justification: Retrospective rating adjustments are calculated directly from incurred losses on specific claims.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Foreign key to the accounting period in which this adjustment is recorded.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Retrospective premium amounts in currency. FK enables multi-currency retro rating, FX conversion for consolidated retro reporting, and ensures adjustment amounts reference valid currencies',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Retro adjustments are geography-segregated for state-specific experience rating, regulatory compliance, and multi-state account management.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy subject to retrospective rating.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the specific policy term being adjusted.',
    `reversed_adjustment_id` BIGINT COMMENT 'Foreign key to the original retrospective adjustment record that this adjustment reverses, if applicable.',
    `uw_decision_id` BIGINT COMMENT 'Foreign key linking to coverage.uw_decision. Business justification: Retrospective premium adjustments triggered by underwriting decisions (risk tier changes, loss control condition waivers, experience modifier updates) require decision reference for',
    `adjustment_effective_date` DATE COMMENT 'Date from which the retrospective adjustment becomes effective for accounting and billing purposes.',
    `adjustment_number` STRING COMMENT 'Business identifier for this retrospective adjustment, typically sequential within the policy term.',
    `adjustment_sequence` BIGINT COMMENT 'Sequential order of this adjustment within the policy term, starting at 1 for the first adjustment.',
    `adjustment_status` STRING COMMENT 'Current lifecycle status of the retrospective adjustment in the billing and payment workflow.. Valid values are `draft|calculated|approved|billed|paid|reversed`',
    `adjustment_type` STRING COMMENT 'Classification of the adjustment: interim during policy term, final at expiration, supplemental for additional data, or corrective for errors.. Valid values are `interim|final|supplemental|corrective`',
    `adjustment_variance_amount` DECIMAL(18,2) COMMENT 'Difference between current and prior retrospective premium, representing the additional premium due or return premium owed.',
    `approved_by_user_code` STRING COMMENT 'Identifier of the underwriter or authorized user who approved this retrospective adjustment for billing.',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time when this retrospective adjustment was approved for billing and accounting.',
    `basic_premium_amount` DECIMAL(18,2) COMMENT 'The fixed component of retrospective premium covering insurer expenses and profit, not subject to loss adjustment.',
    `calculated_retro_premium_amount` DECIMAL(18,2) COMMENT 'Retrospective premium computed from the formula before applying minimum and maximum limits.',
    `calculation_method_code` STRING COMMENT 'Code identifying the specific retrospective rating formula or plan used for this adjustment.',
    `converted_losses_amount` DECIMAL(18,2) COMMENT 'Incurred losses multiplied by the loss conversion factor, representing the loss-based premium component.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this retrospective adjustment record was first created in the data platform.',
    `evaluation_date` DATE COMMENT 'Date on which the retrospective premium calculation was performed, typically at policy expiration or renewal.',
    `final_retro_premium_amount` DECIMAL(18,2) COMMENT 'Retrospective premium after applying minimum and maximum limits, representing the actual premium due.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this retrospective adjustment is posted for financial reporting.',
    `incurred_losses_amount` DECIMAL(18,2) COMMENT 'Total losses incurred during the policy term as of the evaluation date, including paid losses and outstanding reserves.',
    `is_maximum_applied` BOOLEAN COMMENT 'Flag indicating whether the maximum premium limit was applied in this adjustment calculation.',
    `is_minimum_applied` BOOLEAN COMMENT 'Flag indicating whether the minimum premium limit was applied in this adjustment calculation.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this retrospective adjustment record was most recently updated in the data platform.',
    `lob_code` STRING COMMENT 'Insurance line of business code for the retrospectively rated policy, typically Workers Compensation or Commercial Auto.',
    `loss_conversion_factor` DECIMAL(8,6) COMMENT 'Multiplier applied to incurred losses to convert them to premium equivalent, covering loss adjustment expenses and profit margin.',
    `loss_limitation_amount` DECIMAL(18,2) COMMENT 'Maximum loss amount per occurrence or in aggregate used in the retrospective premium calculation.',
    `loss_limitation_type` STRING COMMENT 'Type of loss limitation applied in the retrospective rating plan to cap individual claim or aggregate loss amounts.. Valid values are `per_occurrence|per_accident|aggregate|none`',
    `maximum_premium_amount` DECIMAL(18,2) COMMENT 'Ceiling amount for retrospective premium, expressed as a percentage of standard premium, protecting insured from catastrophic losses.',
    `minimum_premium_amount` DECIMAL(18,2) COMMENT 'Floor amount for retrospective premium, expressed as a percentage of standard premium, protecting insurer from low loss scenarios.',
    `notes` STRING COMMENT 'Free-text notes documenting special circumstances, calculation details, or business rationale for this adjustment.',
    `prior_retro_premium_amount` DECIMAL(18,2) COMMENT 'Retrospective premium amount from the previous adjustment, used to calculate the incremental change.',
    `reversal_indicator` BOOLEAN COMMENT 'Flag indicating whether this adjustment reverses a prior retrospective adjustment due to error or recalculation.',
    `reversal_reason_code` STRING COMMENT 'Code indicating the reason for reversing a prior retrospective adjustment, such as calculation error or updated loss data.',
    `source_system_code` STRING COMMENT 'Code identifying the upstream policy administration or billing system that originated this retrospective adjustment record.',
    `standard_premium_amount` DECIMAL(18,2) COMMENT 'The base premium amount before retrospective adjustment, calculated using standard rates and exposures.',
    `statutory_line_code` STRING COMMENT 'NAIC statutory accounting line code for regulatory reporting of retrospective premium adjustments.',
    `tax_multiplier` DECIMAL(8,6) COMMENT 'Factor applied to gross retrospective premium to account for premium taxes and assessments.',
    CONSTRAINT pk_retrospective_adjustment PRIMARY KEY(`retrospective_adjustment_id`)
) COMMENT 'Records a retro premium adjustment for retrospectively-rated policies. Captures adjustment number, evaluation date, standard premium, loss conversion factor, retro premium computed, and variance from prior adjustment.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` (
    `rule_id` BIGINT COMMENT 'Unique identifier for the premium_rule data product (auto-inserted during validation).',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Premium rules specific to line of business. FK enables LOB-specific rule application, regulatory compliance by line, and ensures rules reference valid LOBs for premium calculation.',
    `superseded_by_rule_id` BIGINT COMMENT 'Identifier of the rule that supersedes this rule. Null if this rule is current or has not been replaced.',
    `applies_to_cancellation` BOOLEAN COMMENT 'Indicates whether this rule applies to policy cancellation transactions.',
    `applies_to_endorsement` BOOLEAN COMMENT 'Indicates whether this rule applies to mid-term endorsement transactions.',
    `applies_to_new_business` BOOLEAN COMMENT 'Indicates whether this rule applies to new business policy transactions.',
    `applies_to_reinstatement` BOOLEAN COMMENT 'Indicates whether this rule applies to policy reinstatement transactions.',
    `applies_to_renewal` BOOLEAN COMMENT 'Indicates whether this rule applies to renewal policy transactions.',
    `approval_date` DATE COMMENT 'Date on which this rule was approved by the regulatory authority or internal governance body.',
    `approved_by` STRING COMMENT 'Name or identifier of the authority or individual who approved this rule for production use.',
    `calculation_method` STRING COMMENT 'Method by which premium is computed under this rule: formula-based, lookup table, factor application, percentage, tiered schedule, or flat amount.. Valid values are `formula|table|factor|percentage|tiered|flat-amount`',
    `rule_category` STRING COMMENT 'Functional category of the rule: earning method, calculation logic, split allocation, floor threshold, cap limit, or adjustment factor.. Valid values are `earning|calculation|split|floor|cap|adjustment`',
    `rule_code` STRING COMMENT 'Business-assigned unique code identifying the premium rule for reference in rating and policy administration systems.',
    `condition_expression` STRING COMMENT 'Logical condition that must be satisfied for this rule to apply. Expressed in rating engine syntax. Null indicates unconditional application.',
    `coverage_type_code` STRING COMMENT 'Specific coverage type code to which this rule applies. Null indicates rule applies to all coverages within the LOB.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this premium rule record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for monetary thresholds and amounts in this rule.. Valid values are `USD|CAD|EUR|GBP|AUD`',
    `rule_description` STRING COMMENT 'Detailed business description of the rule, its purpose, and its application context for underwriters and actuaries.',
    `effective_date` DATE COMMENT 'Date from which this premium rule becomes active and applicable to new and renewing policies.',
    `expiration_date` DATE COMMENT 'Date on which this premium rule ceases to be active. Null indicates the rule is open-ended and remains in force until superseded.',
    `formula_expression` STRING COMMENT 'Mathematical or logical expression defining the premium calculation when calculation_method is formula. Null for non-formula methods.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this premium rule record was last updated or modified.',
    `minimum_earned_percentage` DECIMAL(7,4) COMMENT 'Minimum percentage of premium that must be earned regardless of cancellation timing. Used for minimum-earned rules.',
    `rule_name` STRING COMMENT 'Human-readable name of the premium rule describing its purpose or application context.',
    `notes` STRING COMMENT 'Additional notes, comments, or special instructions related to the application or interpretation of this rule.',
    `percentage_rate` DECIMAL(7,4) COMMENT 'Percentage rate applied in the premium calculation or earning logic. Expressed as a decimal (e.g., 0.0850 for 8.5 percent).',
    `priority_sequence` BIGINT COMMENT 'Execution order when multiple rules apply to the same premium transaction. Lower numbers execute first.',
    `proration_method` STRING COMMENT 'Method used to prorate premium for partial periods: daily, monthly, annual, exact-days, or 30-360 day-count convention.. Valid values are `daily|monthly|annual|exact-days|30-360`',
    `regulatory_filing_reference` STRING COMMENT 'State Department of Insurance filing reference number or SERFF tracking number for this rule, if filed for regulatory approval.',
    `rule_status` STRING COMMENT 'Current lifecycle status of the rule: draft, pending-approval, active, suspended, expired, or superseded.. Valid values are `draft|pending-approval|active|suspended|expired|superseded`',
    `rule_type` STRING COMMENT 'Classification of the premium calculation or earning method: pro-rata, short-rate, flat, minimum-earned, deposit, audit, or installment. [ENUM-REF-CANDIDATE: pro-rata|short-rate|flat|minimum-earned|deposit|audit|installment — 7 candidates stripped',
    `short_rate_penalty_percentage` DECIMAL(7,4) COMMENT 'Penalty percentage applied when a policy is cancelled mid-term by the insured under short-rate rules. Null for pro-rata cancellations.',
    `source_system_code` STRING COMMENT 'Code identifying the source system from which this rule originated: rating engine, policy administration system, or actuarial workbench.',
    `state_code` STRING COMMENT 'Two-letter US state or jurisdiction code where this rule applies. Null indicates rule applies across all states.',
    `threshold_amount` DECIMAL(18,2) COMMENT 'Minimum or maximum premium amount threshold enforced by this rule. Used for floor and cap rules.',
    `threshold_type` STRING COMMENT 'Type of threshold enforced: minimum floor, maximum cap, or target benchmark.. Valid values are `minimum|maximum|target`',
    `version_number` BIGINT COMMENT 'Version number of this rule. Incremented when the rule is revised or amended.',
    CONSTRAINT pk_rule PRIMARY KEY(`rule_id`)
) COMMENT 'Business rule governing how premium is computed, split, earned, or floored for a LOB, state, or coverage type. Stores rule type (pro-rata, short-rate, flat, minimum-earned), effective date range, threshold amounts, and conditions.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` (
    `deposit_premium_id` BIGINT COMMENT 'Unique identifier for the deposit premium record. Primary key.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Deposits posted to accounting periods. FK enables period-based deposit analysis, fiscal year deposit reporting, and ensures deposits align with calendar dimensions for premium accounting.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Deposit premium estimates for large accounts require zone-level exposure distribution for audit planning, rate adequacy validation, and concentration monitoring.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Deposit premium estimates are peril-segregated for large commercial accounts with multiple coverage parts (property, wind, earthquake).',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this deposit premium was booked for financial reporting purposes.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Deposit premium amounts in currency. FK enables multi-currency deposit accounting, FX conversion for consolidated deposit reporting, and ensures deposit amounts reference valid active',
    `deposit_invoice_id` BIGINT COMMENT 'Foreign key linking to billing.invoice. Business justification: Deposit premium transactions generate invoices for initial deposit billing. Billing operations must link invoices to deposit records for audit reconciliation, final premium adjustment',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Deposits vary by line of business. FK enables LOB-specific deposit analysis, audit reconciliation by line, and ensures deposits reference valid LOBs for premium accounting.',
    `party_id` BIGINT COMMENT 'Reference to the underwriter who approved the deposit premium estimate and basis of calculation.',
    `policy_id` BIGINT COMMENT 'Reference to the policy for which this deposit premium was collected.',
    `policy_term_id` BIGINT COMMENT 'Reference to the specific policy term during which this deposit premium applies.',
    `policy_transaction_id` BIGINT COMMENT 'Reference to the policy transaction that triggered the deposit premium collection, typically New Business or Renewal.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer or agent who sold the policy and is associated with this deposit premium for commission calculation purposes.',
    `quote_id` BIGINT COMMENT 'Foreign key linking to coverage.quote. Business justification: Deposit premiums are established at quote binding based on estimated exposures; deposit terms reference quoted premium basis and audit provisions.',
    `actual_exposure_amount` DECIMAL(18,2) COMMENT 'The actual quantity of the exposure basis determined through audit, such as actual annual payroll or actual sales volume.',
    `adjustment_amount` DECIMAL(18,2) COMMENT 'The difference between the deposit premium and the final premium, representing additional premium due or return premium owed to the insured.',
    `adjustment_type` STRING COMMENT 'Classification of the premium adjustment: additional premium due from insured, return premium owed to insured, or no change required.. Valid values are `additional_due|return_premium|no_change`',
    `audit_completed_date` DATE COMMENT 'The date on which the premium audit was completed and final exposure data was captured.',
    `audit_required_flag` BOOLEAN COMMENT 'Indicates whether a premium audit is required at policy expiration to reconcile the deposit premium against actual exposure.',
    `audit_scheduled_date` DATE COMMENT 'The scheduled date for the premium audit to be conducted, typically within 90 days of policy expiration.',
    `audit_type` STRING COMMENT 'The method by which the premium audit will be conducted: physical on-site audit, mail audit, telephone audit, waived audit, or no audit required.. Valid values are `physical|mail|telephone|waived|none`',
    `basis_of_estimate` STRING COMMENT 'Description of the method or data used to estimate the deposit premium, such as prior year payroll, estimated sales, projected vehicle count, or underwriter judgment.',
    `billing_date` DATE COMMENT 'The date on which the deposit premium was billed to the insured or producer.',
    `collection_date` DATE COMMENT 'The date on which the deposit premium payment was received and collected by the insurer.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this deposit premium record was first created in the system.',
    `deposit_amount` DECIMAL(18,2) COMMENT 'The estimated deposit premium amount collected at policy inception or during the term, subject to later audit or retrospective adjustment.',
    `deposit_number` STRING COMMENT 'Business identifier for the deposit premium, often displayed on billing statements and declarations pages.',
    `deposit_percentage` DECIMAL(5,2) COMMENT 'The percentage of estimated final premium collected as deposit, typically ranging from 25 to 100 percent depending on line of business and underwriting requirements.',
    `deposit_status` STRING COMMENT 'Current lifecycle status of the deposit premium: estimated at binding, billed to insured, collected by billing system, reconciled against audit, adjusted, or refunded.. Valid values are `estimated|billed|collected|reconciled|adjusted|refunded`',
    `deposit_type` STRING COMMENT 'Classification of the deposit premium: initial deposit at inception, interim deposit during term, supplemental deposit for coverage changes, or adjustment deposit.. Valid values are `initial|interim|supplemental|adjustment`',
    `effective_date` DATE COMMENT 'The date from which this deposit premium becomes effective, typically the policy inception date or endorsement effective date.',
    `estimated_exposure_amount` DECIMAL(18,2) COMMENT 'The estimated quantity of the exposure basis used to calculate the deposit premium, such as estimated annual payroll or projected sales volume.',
    `estimated_exposure_basis` STRING COMMENT 'The exposure unit or rating basis used to calculate the deposit premium, such as payroll, sales, receipts, area, vehicle count, or number of employees.',
    `expiration_date` DATE COMMENT 'The date on which this deposit premium period ends, typically the policy expiration date or audit date.',
    `final_premium_amount` DECIMAL(18,2) COMMENT 'The final calculated premium amount based on actual exposure determined through audit or retrospective rating calculation.',
    `gl_account_code` STRING COMMENT 'The general ledger account code to which this deposit premium is posted for financial accounting purposes.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The timestamp when this deposit premium record was last updated or modified.',
    `maximum_deposit_amount` DECIMAL(18,2) COMMENT 'The contractual maximum deposit premium amount that can be collected, if applicable, as specified in the policy terms.',
    `minimum_deposit_amount` DECIMAL(18,2) COMMENT 'The contractual minimum deposit premium amount that must be collected regardless of actual exposure, as specified in the policy terms.',
    `notes` STRING COMMENT 'Free-form text field for additional notes, comments, or special instructions related to the deposit premium, audit requirements, or reconciliation process.',
    `reconciliation_date` DATE COMMENT 'The date on which the deposit premium was reconciled against the final premium and any adjustment was calculated.',
    `reconciliation_status` STRING COMMENT 'Current status of the deposit premium reconciliation process: pending audit, audit in progress, reconciliation completed, disputed by insured, or waived by underwriter.. Valid values are `pending|in_progress|completed|disputed|waived`',
    `retro_adjustment_date` DATE COMMENT 'The date on which the retrospective rating adjustment was calculated and applied to the deposit premium.',
    `retro_rated_flag` BOOLEAN COMMENT 'Indicates whether this deposit premium is subject to retrospective rating adjustment based on actual loss experience during the policy term.',
    `source_system_code` STRING COMMENT 'Code identifying the source system from which this deposit premium record originated, such as PolicyCenter, Duck Creek Policy, or legacy system identifier.',
    `statutory_line_code` STRING COMMENT 'The NAIC statutory accounting line code used for regulatory financial reporting of this deposit premium.',
    CONSTRAINT pk_deposit_premium PRIMARY KEY(`deposit_premium_id`)
) COMMENT 'Tracks the estimated deposit premium collected at policy inception for auditable or retro-rated policies. Stores deposit amount, basis of estimate, and reconciliation status against final audit or retro adjustment.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table_authorization` (
    `rate_table_authorization_id` BIGINT COMMENT 'Unique identifier for this rate table authorization record. Primary key.',
    `rate_table_id` BIGINT COMMENT 'Foreign key linking to the rate table version authorized for use by this producer.',
    `underwriting_authority_id` BIGINT COMMENT 'Foreign key linking to the underwriting authority grant that includes this rate table authorization.',
    `authorization_status` STRING COMMENT 'Current lifecycle status of this rate table authorization grant.',
    `deviation_percentage_limit` DECIMAL(5,2) COMMENT 'Maximum percentage the producer may deviate from the published rate table without referral.',
    `effective_date` DATE COMMENT 'Date when the producer may begin using this rate table under this authority grant.',
    `expiration_date` DATE COMMENT 'Date when the producer authority to use this rate table expires or is withdrawn.',
    `override_allowed_flag` BOOLEAN COMMENT 'Indicates whether the producer may override or deviate from the standard rates in this table.',
    CONSTRAINT pk_rate_table_authorization PRIMARY KEY(`rate_table_authorization_id`)
) COMMENT 'Grants a producer or agency the authority to use a specific rate table for binding coverage. One row per producer-rate_table authorization. Tracks effective dates, expiration, override permissions, and deviation limits for that combination..';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_original_transaction_id` FOREIGN KEY (`original_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ADD CONSTRAINT `fk_premium_premium_accounting_period_prior_period_premium_accounting_period_id` FOREIGN KEY (`prior_period_premium_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period`(`premium_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ADD CONSTRAINT `fk_premium_premium_accounting_period_parent_period_id` FOREIGN KEY (`parent_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period`(`premium_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_original_tax_levy_id` FOREIGN KEY (`original_tax_levy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy`(`tax_levy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_source_transaction_id` FOREIGN KEY (`source_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_original_commission_id` FOREIGN KEY (`original_commission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`commission`(`commission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ADD CONSTRAINT `fk_premium_earned_premium_schedule_prior_schedule_id` FOREIGN KEY (`prior_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule`(`earned_premium_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ADD CONSTRAINT `fk_premium_premium_endorsement_reversed_endorsement_id` FOREIGN KEY (`reversed_endorsement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement`(`premium_endorsement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ADD CONSTRAINT `fk_premium_bearing_coverage_original_bearing_coverage_id` FOREIGN KEY (`original_bearing_coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage`(`bearing_coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ADD CONSTRAINT `fk_premium_bearing_coverage_primary_premium_transaction_id` FOREIGN KEY (`primary_premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ADD CONSTRAINT `fk_premium_bearing_coverage_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_original_ceded_premium_id` FOREIGN KEY (`original_ceded_premium_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium`(`ceded_premium_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ADD CONSTRAINT `fk_premium_retrospective_adjustment_reversed_adjustment_id` FOREIGN KEY (`reversed_adjustment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment`(`retrospective_adjustment_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ADD CONSTRAINT `fk_premium_rule_superseded_by_rule_id` FOREIGN KEY (`superseded_by_rule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`rule`(`rule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table_authorization` ADD CONSTRAINT `fk_premium_rate_table_authorization_rate_table_id` FOREIGN KEY (`rate_table_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`rate_table`(`rate_table_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`premium` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`premium` SET TAGS ('dbx_domain' = 'premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` SET TAGS ('dbx_subdomain' = 'financial_transactions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `cat_model_version_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Model Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `original_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Original Premium Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `rating_worksheet_id` SET TAGS ('dbx_business_glossary_term' = 'Rating Worksheet Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `unit_of_measure_id` SET TAGS ('dbx_business_glossary_term' = 'Unit Of Measure Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `coverage_transaction_id` SET TAGS ('dbx_ssot_reference' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `audit_basis` SET TAGS ('dbx_business_glossary_term' = 'Audit Premium Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `audit_basis` SET TAGS ('dbx_value_regex' = 'Payroll|Revenue|Units|Receipts|None');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `ceded_written_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Written Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `ceded_written_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `ceded_written_premium` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `days_in_force` SET TAGS ('dbx_business_glossary_term' = 'Days In Force');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `direct_billed_indicator` SET TAGS ('dbx_business_glossary_term' = 'Direct Billed Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `earned_premium` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `earned_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `earned_premium` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `earning_method` SET TAGS ('dbx_business_glossary_term' = 'Premium Earning Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `earning_method` SET TAGS ('dbx_value_regex' = 'Pro-Rata|1/365|1/24|Flat|Other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Premium Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `endorsement_type` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Premium Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `endorsement_type` SET TAGS ('dbx_value_regex' = 'Additional|Return|Flat|Audit|None');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Premium Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Exposure Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `gross_written_premium` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `gross_written_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `gross_written_premium` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `net_written_premium` SET TAGS ('dbx_business_glossary_term' = 'Net Written Premium (NWP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `net_written_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `net_written_premium` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `payment_plan_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `posted_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Posted Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `pro_rata_factor` SET TAGS ('dbx_business_glossary_term' = 'Pro-Rata Earning Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `rate` SET TAGS ('dbx_business_glossary_term' = 'Premium Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `rate_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Rate Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `return_premium` SET TAGS ('dbx_business_glossary_term' = 'Return Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `return_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `return_premium` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `reversal_indicator` SET TAGS ('dbx_business_glossary_term' = 'Reversal Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'PAS|BILLING|RATING|MANUAL|REINSURANCE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `transaction_number` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_value_regex' = 'Pending|Posted|Reversed|Voided|Error');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'Written|Earned|Unearned|Return|Adjustment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `unearned_premium` SET TAGS ('dbx_business_glossary_term' = 'Unearned Premium (UEP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `unearned_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `unearned_premium` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` SET TAGS ('dbx_subdomain' = 'financial_transactions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `premium_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `prior_period_premium_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `parent_period_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `accident_year_ay` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `actuarial_reserve_cutoff_date` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Reserve Cutoff Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `bordereaux_due_date` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Bordereaux Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `calendar_year_cy` SET TAGS ('dbx_business_glossary_term' = 'Calendar Year (CY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `close_date` SET TAGS ('dbx_business_glossary_term' = 'Period Close Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `days_in_period` SET TAGS ('dbx_business_glossary_term' = 'Days in Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `earned_premium_basis` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `earned_premium_basis` SET TAGS ('dbx_value_regex' = 'PRO_RATA|DAILY|MONTHLY');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Period End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `filing_status` SET TAGS ('dbx_value_regex' = 'NOT_FILED|FILED|ACCEPTED|REJECTED|AMENDED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `fiscal_month` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Month');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `fiscal_quarter` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Quarter');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `gl_period_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Period Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `is_current_period` SET TAGS ('dbx_business_glossary_term' = 'Is Current Period Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `is_ifrs17_reporting_period` SET TAGS ('dbx_business_glossary_term' = 'Is IFRS 17 Reporting Period Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `is_statutory_filing_period` SET TAGS ('dbx_business_glossary_term' = 'Is Statutory Filing Period Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `lock_date` SET TAGS ('dbx_business_glossary_term' = 'Period Lock Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `period_code` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `period_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(0[1-9]|1[0-2]|Q[1-4]|ANNUAL)$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `period_name` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `period_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `period_status` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `period_status` SET TAGS ('dbx_value_regex' = 'OPEN|CLOSED|LOCKED|REOPENED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `period_type` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `period_type` SET TAGS ('dbx_value_regex' = 'MONTHLY|QUARTERLY|ANNUAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `policy_year_py` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `regulatory_filing_deadline` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Deadline');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `reopen_date` SET TAGS ('dbx_business_glossary_term' = 'Period Reopen Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `reopen_reason` SET TAGS ('dbx_business_glossary_term' = 'Period Reopen Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `reporting_basis` SET TAGS ('dbx_business_glossary_term' = 'Reporting Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `reporting_basis` SET TAGS ('dbx_value_regex' = 'SAP|GAAP|IFRS17');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `schedule_p_year_type` SET TAGS ('dbx_business_glossary_term' = 'Schedule P Year Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `schedule_p_year_type` SET TAGS ('dbx_value_regex' = 'CY|AY|PY');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Period Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` SET TAGS ('dbx_subdomain' = 'financial_transactions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `charge_id` SET TAGS ('dbx_business_glossary_term' = 'Charge Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `rating_worksheet_id` SET TAGS ('dbx_business_glossary_term' = 'Rating Worksheet Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Charge Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `basis_amount` SET TAGS ('dbx_business_glossary_term' = 'Charge Basis Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `charge_category` SET TAGS ('dbx_business_glossary_term' = 'Charge Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `charge_category` SET TAGS ('dbx_value_regex' = 'premium|fee|penalty|refund|adjustment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `ceded_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `charge_status` SET TAGS ('dbx_business_glossary_term' = 'Charge Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `charge_status` SET TAGS ('dbx_value_regex' = 'active|voided|reversed|adjusted|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `charge_type` SET TAGS ('dbx_business_glossary_term' = 'Charge Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `charge_description` SET TAGS ('dbx_business_glossary_term' = 'Charge Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `earned_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Charge Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Charge Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `is_ceded` SET TAGS ('dbx_business_glossary_term' = 'Is Ceded to Reinsurance Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `is_commissionable` SET TAGS ('dbx_business_glossary_term' = 'Is Commissionable Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `is_earned` SET TAGS ('dbx_business_glossary_term' = 'Is Earned Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `is_minimum_premium` SET TAGS ('dbx_business_glossary_term' = 'Is Minimum Premium Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `is_prorated` SET TAGS ('dbx_business_glossary_term' = 'Is Prorated Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Charge Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `percentage` SET TAGS ('dbx_business_glossary_term' = 'Charge Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `proration_factor` SET TAGS ('dbx_business_glossary_term' = 'Proration Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `rate` SET TAGS ('dbx_business_glossary_term' = 'Charge Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `rating_element_code` SET TAGS ('dbx_business_glossary_term' = 'Rating Element Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `rating_element_description` SET TAGS ('dbx_business_glossary_term' = 'Rating Element Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `reversal_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `reversal_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `sequence` SET TAGS ('dbx_business_glossary_term' = 'Charge Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `statutory_line_code` SET TAGS ('dbx_business_glossary_term' = 'Statutory Line Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `unearned_amount` SET TAGS ('dbx_business_glossary_term' = 'Unearned Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` SET TAGS ('dbx_subdomain' = 'financial_transactions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_levy_id` SET TAGS ('dbx_business_glossary_term' = 'Tax Levy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `original_tax_levy_id` SET TAGS ('dbx_business_glossary_term' = 'Original Tax Levy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Levy Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_levy_description` SET TAGS ('dbx_business_glossary_term' = 'Tax Levy Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `policy_transaction_type_code` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `policy_transaction_type_code` SET TAGS ('dbx_value_regex' = 'NEW_BUSINESS|RENEWAL|ENDORSEMENT|CANCELLATION|REINSTATEMENT');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Tax Levy Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `stamping_office_code` SET TAGS ('dbx_business_glossary_term' = 'Stamping Office Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `surplus_lines_flag` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_adjustment_flag` SET TAGS ('dbx_business_glossary_term' = 'Tax Adjustment Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_authority_name` SET TAGS ('dbx_business_glossary_term' = 'Tax Authority Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_authority_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_calculation_method_code` SET TAGS ('dbx_business_glossary_term' = 'Tax Calculation Method Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_calculation_method_code` SET TAGS ('dbx_value_regex' = 'STATUTORY_RATE|FLAT_FEE|TIERED_RATE|MINIMUM_TAX');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Tax Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_exemption_flag` SET TAGS ('dbx_business_glossary_term' = 'Tax Exemption Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_exemption_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Tax Exemption Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_exemption_reason_code` SET TAGS ('dbx_value_regex' = 'EXEMPT_ENTITY|REINSURANCE|EXPORT|FEDERAL_PROGRAM|OTHER');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Tax Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_remittance_batch_code` SET TAGS ('dbx_business_glossary_term' = 'Tax Remittance Batch Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_remittance_date` SET TAGS ('dbx_business_glossary_term' = 'Tax Remittance Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_remittance_due_date` SET TAGS ('dbx_business_glossary_term' = 'Tax Remittance Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_remittance_status` SET TAGS ('dbx_business_glossary_term' = 'Tax Remittance Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_remittance_status` SET TAGS ('dbx_value_regex' = 'PENDING|REMITTED|OVERDUE|WAIVED|ADJUSTED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_reporting_category_code` SET TAGS ('dbx_business_glossary_term' = 'Tax Reporting Category Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_reporting_category_code` SET TAGS ('dbx_value_regex' = 'DIRECT_WRITTEN|ASSUMED_REINSURANCE|CEDED_REINSURANCE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_type_code` SET TAGS ('dbx_business_glossary_term' = 'Tax Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_type_code` SET TAGS ('dbx_value_regex' = 'STATE_PREMIUM_TAX|SURPLUS_LINES_TAX|STAMPING_FEE|MUNICIPAL_TAX|FIRE_MARSHAL_TAX|GUARANTY_FUND_ASSESSMENT');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `taxable_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Taxable Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` SET TAGS ('dbx_subdomain' = 'financial_transactions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `policy_fee_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Fee Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `original_fee_id` SET TAGS ('dbx_business_glossary_term' = 'Original Fee Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `payment_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `source_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Source Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `billing_method` SET TAGS ('dbx_business_glossary_term' = 'Billing Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `billing_method` SET TAGS ('dbx_value_regex' = 'direct_bill|agency_bill|list_bill|account_current');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `fee_basis` SET TAGS ('dbx_business_glossary_term' = 'Fee Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `fee_code` SET TAGS ('dbx_business_glossary_term' = 'Fee Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `fee_description` SET TAGS ('dbx_business_glossary_term' = 'Fee Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `fee_quantity` SET TAGS ('dbx_business_glossary_term' = 'Fee Quantity');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Fee Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `fee_status` SET TAGS ('dbx_business_glossary_term' = 'Fee Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `fee_status` SET TAGS ('dbx_value_regex' = 'pending|posted|reversed|refunded|written_off');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `fee_type` SET TAGS ('dbx_business_glossary_term' = 'Fee Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `is_commission_bearing` SET TAGS ('dbx_business_glossary_term' = 'Is Commission Bearing Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `is_refundable` SET TAGS ('dbx_business_glossary_term' = 'Is Refundable Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `is_taxable` SET TAGS ('dbx_business_glossary_term' = 'Is Taxable Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `jurisdiction_code` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `reversal_date` SET TAGS ('dbx_business_glossary_term' = 'Reversal Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `reversal_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `statutory_line_code` SET TAGS ('dbx_business_glossary_term' = 'Statutory Line Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `transaction_booking_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Booking Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `transaction_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Transaction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'charge|reversal|adjustment|refund');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `waived_flag` SET TAGS ('dbx_business_glossary_term' = 'Waived Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `waiver_authorized_by` SET TAGS ('dbx_business_glossary_term' = 'Waiver Authorized By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `waiver_authorized_by` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `waiver_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` SET TAGS ('dbx_subdomain' = 'financial_transactions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `commission_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `disbursement_id` SET TAGS ('dbx_business_glossary_term' = 'Disbursement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `license_id` SET TAGS ('dbx_business_glossary_term' = 'License Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `original_commission_id` SET TAGS ('dbx_business_glossary_term' = 'Original Commission Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `basis` SET TAGS ('dbx_business_glossary_term' = 'Commission Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `basis` SET TAGS ('dbx_value_regex' = 'written_premium|earned_premium|policy_fee|installment_fee');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `basis_amount` SET TAGS ('dbx_business_glossary_term' = 'Basis Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Calculation Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `calculation_method` SET TAGS ('dbx_value_regex' = 'flat_rate|tiered|sliding_scale|manual_override');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `chargeback_indicator` SET TAGS ('dbx_business_glossary_term' = 'Chargeback Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `chargeback_reason` SET TAGS ('dbx_business_glossary_term' = 'Chargeback Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `commission_status` SET TAGS ('dbx_business_glossary_term' = 'Commission Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `commission_status` SET TAGS ('dbx_value_regex' = 'calculated|approved|pending_payment|paid|reversed|cancelled');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `commission_type` SET TAGS ('dbx_business_glossary_term' = 'Commission Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `commission_type` SET TAGS ('dbx_value_regex' = 'new_business|renewal|endorsement|contingent|override|bonus');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `contingent_indicator` SET TAGS ('dbx_business_glossary_term' = 'Contingent Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `earned_date` SET TAGS ('dbx_business_glossary_term' = 'Earned Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `net_payable_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Payable Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `override_indicator` SET TAGS ('dbx_business_glossary_term' = 'Override Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'ach|wire|check|offset|direct_deposit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'unpaid|paid|partially_paid|withheld|deferred');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `policy_transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `policy_transaction_type` SET TAGS ('dbx_value_regex' = 'new_business|renewal|endorsement|cancellation|reinstatement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `reversal_indicator` SET TAGS ('dbx_business_glossary_term' = 'Reversal Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `schedule_code` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `split_percentage` SET TAGS ('dbx_business_glossary_term' = 'Split Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `tax_withholding_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Withholding Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `tier_level` SET TAGS ('dbx_business_glossary_term' = 'Tier Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` SET TAGS ('dbx_subdomain' = 'financial_transactions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `earned_premium_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium Schedule ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `prior_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Schedule ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `adjustment_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `cumulative_earned_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Earned Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `daily_earned_amount` SET TAGS ('dbx_business_glossary_term' = 'Daily Earned Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `days_elapsed` SET TAGS ('dbx_business_glossary_term' = 'Days Elapsed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `days_in_period` SET TAGS ('dbx_business_glossary_term' = 'Days in Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `days_remaining` SET TAGS ('dbx_business_glossary_term' = 'Days Remaining');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `earned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `earning_method` SET TAGS ('dbx_business_glossary_term' = 'Earning Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `earning_method` SET TAGS ('dbx_value_regex' = 'daily|monthly|quarterly|annual|event_based');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `earning_percentage` SET TAGS ('dbx_business_glossary_term' = 'Earning Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `ifrs17_cohort_code` SET TAGS ('dbx_business_glossary_term' = 'IFRS 17 Cohort Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `is_minimum_earned` SET TAGS ('dbx_business_glossary_term' = 'Is Minimum Earned Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `is_prorated` SET TAGS ('dbx_business_glossary_term' = 'Is Prorated Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `is_short_rate` SET TAGS ('dbx_business_glossary_term' = 'Is Short Rate Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `minimum_earned_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Earned Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `proration_factor` SET TAGS ('dbx_business_glossary_term' = 'Proration Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `reporting_basis` SET TAGS ('dbx_business_glossary_term' = 'Reporting Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `reporting_basis` SET TAGS ('dbx_value_regex' = 'statutory|gaap|ifrs17|tax');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `schedule_date` SET TAGS ('dbx_business_glossary_term' = 'Schedule Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `schedule_number` SET TAGS ('dbx_business_glossary_term' = 'Schedule Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_business_glossary_term' = 'Schedule Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_value_regex' = 'active|cancelled|expired|suspended|adjusted');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `schedule_type` SET TAGS ('dbx_business_glossary_term' = 'Schedule Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `schedule_type` SET TAGS ('dbx_value_regex' = 'pro_rata|short_rate|daily|monthly|annual|custom');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `short_rate_penalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Short Rate Penalty Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `short_rate_percentage` SET TAGS ('dbx_business_glossary_term' = 'Short Rate Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `statutory_line_code` SET TAGS ('dbx_business_glossary_term' = 'Statutory Line Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `total_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ALTER COLUMN `unearned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Unearned Premium (UEP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` SET TAGS ('dbx_subdomain' = 'financial_transactions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `premium_endorsement_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Endorsement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `reversed_endorsement_id` SET TAGS ('dbx_business_glossary_term' = 'Reversed Endorsement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `uw_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Uw Decision Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `billing_status` SET TAGS ('dbx_business_glossary_term' = 'Billing Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `billing_status` SET TAGS ('dbx_value_regex' = 'Pending|Billed|Paid|Partially Paid|Refunded|Written Off');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `ceded_premium_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Premium Change Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `commission_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Change Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `days_in_term_remaining` SET TAGS ('dbx_business_glossary_term' = 'Days in Term Remaining');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `earned_premium_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Change Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `fee_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Change Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `gross_premium_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Premium Change Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `is_billable` SET TAGS ('dbx_business_glossary_term' = 'Is Billable');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `net_premium_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Premium Change Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `proration_factor` SET TAGS ('dbx_business_glossary_term' = 'Proration Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `proration_method` SET TAGS ('dbx_business_glossary_term' = 'Proration Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `proration_method` SET TAGS ('dbx_value_regex' = 'Pro-Rata|Short-Rate|Flat|Daily|Monthly');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `reversal_indicator` SET TAGS ('dbx_business_glossary_term' = 'Reversal Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `reversal_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `reversal_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `source_system_transaction_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `statutory_line_code` SET TAGS ('dbx_business_glossary_term' = 'Statutory Line Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `tax_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Change Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `total_charge_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Charge Change Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `transaction_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `transaction_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Transaction Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `transaction_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Transaction Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `transaction_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Transaction Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Transaction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'Endorsement|Cancellation|Reinstatement|Flat Cancellation|Pro-Rata Cancellation|Short-Rate Cancellation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `unearned_premium_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Unearned Premium (UEP) Change Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ALTER COLUMN `written_premium_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Written Premium (WP) Change Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` SET TAGS ('dbx_subdomain' = 'rating_rules');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `rate_table_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Table ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `cat_model_version_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Model Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `classification_code_id` SET TAGS ('dbx_business_glossary_term' = 'Classification Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `filing_organization_id` SET TAGS ('dbx_business_glossary_term' = 'Filing Organization Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `unit_of_measure_id` SET TAGS ('dbx_business_glossary_term' = 'Unit Of Measure Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `actuarial_memo_reference` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Memo Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|filed|approved|rejected|withdrawn|superseded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `base_rate_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Rate Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `rate_table_code` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `coverage_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `credibility_factor` SET TAGS ('dbx_business_glossary_term' = 'Credibility Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `expense_provision_percentage` SET TAGS ('dbx_business_glossary_term' = 'Expense Provision Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `filing_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `filing_number` SET TAGS ('dbx_business_glossary_term' = 'Filing Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `is_file_and_use` SET TAGS ('dbx_business_glossary_term' = 'Is File and Use');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `is_prior_approval` SET TAGS ('dbx_business_glossary_term' = 'Is Prior Approval');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `is_use_and_file` SET TAGS ('dbx_business_glossary_term' = 'Is Use and File');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `iso_program_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Program Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `loss_cost_basis` SET TAGS ('dbx_business_glossary_term' = 'Loss Cost Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `maximum_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `minimum_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `rate_table_name` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `rate_table_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `profit_provision_percentage` SET TAGS ('dbx_business_glossary_term' = 'Profit Provision Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `published_date` SET TAGS ('dbx_business_glossary_term' = 'Published Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `rate_change_percentage` SET TAGS ('dbx_business_glossary_term' = 'Rate Change Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `rate_manual_edition` SET TAGS ('dbx_business_glossary_term' = 'Rate Manual Edition');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `rate_source` SET TAGS ('dbx_business_glossary_term' = 'Rate Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `rate_source` SET TAGS ('dbx_value_regex' = 'proprietary|iso_advisory|ncci|state_manual|competitor_benchmark');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `rate_table_status` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `rate_table_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|superseded|withdrawn');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `rate_type` SET TAGS ('dbx_business_glossary_term' = 'Rate Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `rate_type` SET TAGS ('dbx_value_regex' = 'base|factor|minimum|surcharge|discount|credit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `rating_algorithm_code` SET TAGS ('dbx_business_glossary_term' = 'Rating Algorithm Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `territory_definition` SET TAGS ('dbx_business_glossary_term' = 'Territory Definition');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `trend_factor` SET TAGS ('dbx_business_glossary_term' = 'Trend Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `withdrawn_date` SET TAGS ('dbx_business_glossary_term' = 'Withdrawn Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` SET TAGS ('dbx_subdomain' = 'rating_rules');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for premium_audit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `auditor_individual_id` SET TAGS ('dbx_business_glossary_term' = 'Auditor Individual Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `claim_expense_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Expense Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Invoice Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Auditor Producer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `unit_of_measure_id` SET TAGS ('dbx_business_glossary_term' = 'Unit Of Measure Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `additional_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Additional Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `audit_number` SET TAGS ('dbx_business_glossary_term' = 'Audit Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `audit_status` SET TAGS ('dbx_business_glossary_term' = 'Audit Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `audit_status` SET TAGS ('dbx_value_regex' = 'scheduled|in_progress|completed|cancelled|disputed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `audit_type` SET TAGS ('dbx_business_glossary_term' = 'Audit Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `audit_type` SET TAGS ('dbx_value_regex' = 'final|interim|cancellation|reinstatement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `audited_exposure` SET TAGS ('dbx_business_glossary_term' = 'Audited Exposure');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `audited_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Audited Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `billing_adjustment_status` SET TAGS ('dbx_business_glossary_term' = 'Billing Adjustment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `billing_adjustment_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|processed|failed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'Audit Completion Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `deposit_reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Deposit Reconciliation Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `deposit_reconciliation_status` SET TAGS ('dbx_value_regex' = 'pending|reconciled|disputed|waived');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `dispute_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `estimated_exposure` SET TAGS ('dbx_business_glossary_term' = 'Estimated Exposure');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `estimated_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Estimated Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `exposure_basis_description` SET TAGS ('dbx_business_glossary_term' = 'Exposure Basis Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `exposure_variance` SET TAGS ('dbx_business_glossary_term' = 'Exposure Variance');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `exposure_variance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Exposure Variance Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `is_minimum_premium_applied` SET TAGS ('dbx_business_glossary_term' = 'Is Minimum Premium Applied Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `method` SET TAGS ('dbx_business_glossary_term' = 'Audit Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `method` SET TAGS ('dbx_value_regex' = 'physical|desk|mail|phone|electronic');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `minimum_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Audit Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Audit Period End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Audit Period Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `policyholder_signature_date` SET TAGS ('dbx_business_glossary_term' = 'Policyholder Signature Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `policyholder_signature_date` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `premium_variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Variance Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `return_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Return Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `scheduled_date` SET TAGS ('dbx_business_glossary_term' = 'Audit Scheduled Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Audit Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `waiver_flag` SET TAGS ('dbx_business_glossary_term' = 'Waiver Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` SET TAGS ('dbx_subdomain' = 'financial_transactions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `bearing_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Bearing Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `original_bearing_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Original Bearing Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `primary_premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Source Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `allocated_amount` SET TAGS ('dbx_business_glossary_term' = 'Allocated Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `allocation_basis` SET TAGS ('dbx_business_glossary_term' = 'Allocation Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `allocation_basis` SET TAGS ('dbx_value_regex' = 'tiv|exposure|limit|rate|manual');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `allocation_percentage` SET TAGS ('dbx_business_glossary_term' = 'Allocation Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `allocation_sequence` SET TAGS ('dbx_business_glossary_term' = 'Allocation Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `allocation_status` SET TAGS ('dbx_business_glossary_term' = 'Allocation Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `allocation_status` SET TAGS ('dbx_value_regex' = 'active|reversed|adjusted|voided|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `allocation_type` SET TAGS ('dbx_business_glossary_term' = 'Allocation Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `allocation_type` SET TAGS ('dbx_value_regex' = 'direct|proportional|specific|manual|system_calculated|override');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `ceded_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `coverage_description` SET TAGS ('dbx_business_glossary_term' = 'Coverage Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Allocation Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Allocation Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `is_ceded` SET TAGS ('dbx_business_glossary_term' = 'Is Ceded to Reinsurance Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `is_commissionable` SET TAGS ('dbx_business_glossary_term' = 'Is Commissionable Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `is_primary_coverage` SET TAGS ('dbx_business_glossary_term' = 'Is Primary Coverage Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Retained Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Allocation Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `reversal_date` SET TAGS ('dbx_business_glossary_term' = 'Reversal Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `reversal_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `risk_type` SET TAGS ('dbx_business_glossary_term' = 'Risk Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `statutory_line_code` SET TAGS ('dbx_business_glossary_term' = 'Statutory Line Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ALTER COLUMN `transaction_booking_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Booking Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` SET TAGS ('dbx_subdomain' = 'financial_transactions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `ceded_premium_id` SET TAGS ('dbx_business_glossary_term' = 'Ceded Premium Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `cat_model_version_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Model Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `fac_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Agreement Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `original_ceded_premium_id` SET TAGS ('dbx_business_glossary_term' = 'Original Ceded Premium Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `rating_worksheet_id` SET TAGS ('dbx_business_glossary_term' = 'Rating Worksheet Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Agreement Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Source Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `bordereaux_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Reporting Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `bordereaux_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Submission Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `ceded_earned_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Earned Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `ceded_unearned_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Unearned Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `ceded_written_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Written Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `ceding_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `cession_basis` SET TAGS ('dbx_business_glossary_term' = 'Cession Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `cession_basis` SET TAGS ('dbx_value_regex' = 'quota_share|surplus|excess_of_loss|stop_loss|facultative');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `cession_number` SET TAGS ('dbx_business_glossary_term' = 'Cession Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `cession_rate` SET TAGS ('dbx_business_glossary_term' = 'Cession Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `net_ceded_premium` SET TAGS ('dbx_business_glossary_term' = 'Net Ceded Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `profit_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `profit_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `reversal_indicator` SET TAGS ('dbx_business_glossary_term' = 'Reversal Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `reversal_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `settlement_status` SET TAGS ('dbx_business_glossary_term' = 'Settlement Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `settlement_status` SET TAGS ('dbx_value_regex' = 'pending|settled|disputed|reversed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `statutory_line_code` SET TAGS ('dbx_business_glossary_term' = 'Statutory Line Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Transaction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'written|earned|unearned|return|adjustment|reversal');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` SET TAGS ('dbx_subdomain' = 'rating_rules');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `minimum_earned_premium_id` SET TAGS ('dbx_business_glossary_term' = 'Minimum Earned Premium (MEP) Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `application_level` SET TAGS ('dbx_business_glossary_term' = 'Application Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `application_level` SET TAGS ('dbx_value_regex' = 'policy_term|coverage|insured_risk');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `applies_to_endorsement_flag` SET TAGS ('dbx_business_glossary_term' = 'Applies to Endorsement (END) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `applies_to_new_business_flag` SET TAGS ('dbx_business_glossary_term' = 'Applies to New Business (NB) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `applies_to_renewal_flag` SET TAGS ('dbx_business_glossary_term' = 'Applies to Renewal (REN) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Calculation Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `calculation_method` SET TAGS ('dbx_value_regex' = 'fixed_amount|percentage|greater_of_both|lesser_of_both');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `cancellation_type` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `cancellation_type` SET TAGS ('dbx_value_regex' = 'flat|short_rate|pro_rata|all');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `filing_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `minimum_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Earned Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `minimum_days_in_force` SET TAGS ('dbx_business_glossary_term' = 'Minimum Days In Force');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `minimum_earned_premium_status` SET TAGS ('dbx_business_glossary_term' = 'Rule Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `minimum_earned_premium_status` SET TAGS ('dbx_value_regex' = 'active|inactive|superseded|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `override_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Override Allowed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `override_authority_level` SET TAGS ('dbx_business_glossary_term' = 'Override Authority Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `percentage_of_written_premium` SET TAGS ('dbx_business_glossary_term' = 'Percentage of Written Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `proration_method` SET TAGS ('dbx_business_glossary_term' = 'Proration Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `proration_method` SET TAGS ('dbx_value_regex' = 'daily|monthly|annual|none');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `regulatory_filing_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `rule_code` SET TAGS ('dbx_business_glossary_term' = 'Minimum Earned Premium (MEP) Rule Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `rule_name` SET TAGS ('dbx_business_glossary_term' = 'Minimum Earned Premium (MEP) Rule Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `rule_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `statutory_line_code` SET TAGS ('dbx_business_glossary_term' = 'Statutory Line Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `waiver_authorized_by` SET TAGS ('dbx_business_glossary_term' = 'Waiver Authorized By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `waiver_date` SET TAGS ('dbx_business_glossary_term' = 'Waiver Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ALTER COLUMN `waiver_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` SET TAGS ('dbx_subdomain' = 'financial_transactions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `retrospective_adjustment_id` SET TAGS ('dbx_business_glossary_term' = 'Retrospective Adjustment Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `adjustment_invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Invoice Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `reversed_adjustment_id` SET TAGS ('dbx_business_glossary_term' = 'Reversed Adjustment Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `uw_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Uw Decision Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `adjustment_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `adjustment_number` SET TAGS ('dbx_business_glossary_term' = 'Retrospective Adjustment Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `adjustment_sequence` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `adjustment_status` SET TAGS ('dbx_business_glossary_term' = 'Retrospective Adjustment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `adjustment_status` SET TAGS ('dbx_value_regex' = 'draft|calculated|approved|billed|paid|reversed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `adjustment_type` SET TAGS ('dbx_business_glossary_term' = 'Retrospective Adjustment Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `adjustment_type` SET TAGS ('dbx_value_regex' = 'interim|final|supplemental|corrective');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `adjustment_variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Variance Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `basic_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Basic Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `calculated_retro_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Calculated Retrospective Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `calculation_method_code` SET TAGS ('dbx_business_glossary_term' = 'Retrospective Calculation Method Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `converted_losses_amount` SET TAGS ('dbx_business_glossary_term' = 'Converted Losses Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `evaluation_date` SET TAGS ('dbx_business_glossary_term' = 'Retrospective Evaluation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `final_retro_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Final Retrospective Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `incurred_losses_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred Losses Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `is_maximum_applied` SET TAGS ('dbx_business_glossary_term' = 'Maximum Premium Applied Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `is_minimum_applied` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Applied Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `loss_conversion_factor` SET TAGS ('dbx_business_glossary_term' = 'Loss Conversion Factor (LCF)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `loss_limitation_amount` SET TAGS ('dbx_business_glossary_term' = 'Loss Limitation Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `loss_limitation_type` SET TAGS ('dbx_business_glossary_term' = 'Loss Limitation Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `loss_limitation_type` SET TAGS ('dbx_value_regex' = 'per_occurrence|per_accident|aggregate|none');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `maximum_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `minimum_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Retrospective Adjustment Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `prior_retro_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Retrospective Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `reversal_indicator` SET TAGS ('dbx_business_glossary_term' = 'Reversal Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `reversal_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `standard_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Standard Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `statutory_line_code` SET TAGS ('dbx_business_glossary_term' = 'Statutory Line Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ALTER COLUMN `tax_multiplier` SET TAGS ('dbx_business_glossary_term' = 'Tax Multiplier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` SET TAGS ('dbx_subdomain' = 'rating_rules');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `rule_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for premium_rule');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `superseded_by_rule_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Rule Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `applies_to_cancellation` SET TAGS ('dbx_business_glossary_term' = 'Applies to Cancellation (CAN) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `applies_to_endorsement` SET TAGS ('dbx_business_glossary_term' = 'Applies to Endorsement (END) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `applies_to_new_business` SET TAGS ('dbx_business_glossary_term' = 'Applies to New Business (NB) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `applies_to_reinstatement` SET TAGS ('dbx_business_glossary_term' = 'Applies to Reinstatement (RI) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `applies_to_renewal` SET TAGS ('dbx_business_glossary_term' = 'Applies to Renewal (REN) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Rule Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Rule Approved By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Premium Calculation Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `calculation_method` SET TAGS ('dbx_value_regex' = 'formula|table|factor|percentage|tiered|flat-amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `rule_category` SET TAGS ('dbx_business_glossary_term' = 'Premium Rule Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `rule_category` SET TAGS ('dbx_value_regex' = 'earning|calculation|split|floor|cap|adjustment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `rule_code` SET TAGS ('dbx_business_glossary_term' = 'Premium Rule Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `condition_expression` SET TAGS ('dbx_business_glossary_term' = 'Rule Condition Expression');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `coverage_type_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Rule Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|AUD');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `rule_description` SET TAGS ('dbx_business_glossary_term' = 'Premium Rule Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Rule Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Rule Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `formula_expression` SET TAGS ('dbx_business_glossary_term' = 'Premium Formula Expression');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Rule Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `minimum_earned_percentage` SET TAGS ('dbx_business_glossary_term' = 'Minimum Earned Premium Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `rule_name` SET TAGS ('dbx_business_glossary_term' = 'Premium Rule Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `rule_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Premium Rule Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `percentage_rate` SET TAGS ('dbx_business_glossary_term' = 'Premium Percentage Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `priority_sequence` SET TAGS ('dbx_business_glossary_term' = 'Rule Priority Sequence');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `proration_method` SET TAGS ('dbx_business_glossary_term' = 'Premium Proration Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `proration_method` SET TAGS ('dbx_value_regex' = 'daily|monthly|annual|exact-days|30-360');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `regulatory_filing_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `rule_status` SET TAGS ('dbx_business_glossary_term' = 'Premium Rule Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `rule_status` SET TAGS ('dbx_value_regex' = 'draft|pending-approval|active|suspended|expired|superseded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `rule_type` SET TAGS ('dbx_business_glossary_term' = 'Premium Rule Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `short_rate_penalty_percentage` SET TAGS ('dbx_business_glossary_term' = 'Short Rate Penalty Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Threshold Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `threshold_type` SET TAGS ('dbx_business_glossary_term' = 'Premium Threshold Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `threshold_type` SET TAGS ('dbx_value_regex' = 'minimum|maximum|target');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Rule Version Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` SET TAGS ('dbx_subdomain' = 'financial_transactions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `deposit_premium_id` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `deposit_invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Deposit Invoice Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `actual_exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Exposure Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Adjustment Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `adjustment_type` SET TAGS ('dbx_business_glossary_term' = 'Premium Adjustment Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `adjustment_type` SET TAGS ('dbx_value_regex' = 'additional_due|return_premium|no_change');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `audit_completed_date` SET TAGS ('dbx_business_glossary_term' = 'Audit Completed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `audit_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Audit Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `audit_scheduled_date` SET TAGS ('dbx_business_glossary_term' = 'Audit Scheduled Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `audit_type` SET TAGS ('dbx_business_glossary_term' = 'Audit Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `audit_type` SET TAGS ('dbx_value_regex' = 'physical|mail|telephone|waived|none');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `basis_of_estimate` SET TAGS ('dbx_business_glossary_term' = 'Basis of Estimate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `billing_date` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium Billing Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `collection_date` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium Collection Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `deposit_amount` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `deposit_number` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `deposit_percentage` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `deposit_status` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `deposit_status` SET TAGS ('dbx_value_regex' = 'estimated|billed|collected|reconciled|adjusted|refunded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `deposit_type` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `deposit_type` SET TAGS ('dbx_value_regex' = 'initial|interim|supplemental|adjustment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `estimated_exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Estimated Exposure Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `estimated_exposure_basis` SET TAGS ('dbx_business_glossary_term' = 'Estimated Exposure Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `final_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Final Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `maximum_deposit_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Deposit Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `minimum_deposit_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Deposit Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|disputed|waived');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `retro_adjustment_date` SET TAGS ('dbx_business_glossary_term' = 'Retrospective Adjustment Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `retro_rated_flag` SET TAGS ('dbx_business_glossary_term' = 'Retrospectively Rated Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ALTER COLUMN `statutory_line_code` SET TAGS ('dbx_business_glossary_term' = 'Statutory Line Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table_authorization` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table_authorization` SET TAGS ('dbx_subdomain' = 'rating_rules');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table_authorization` SET TAGS ('dbx_association_edges' = 'premium.rate_table,producers.underwriting_authority');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table_authorization` ALTER COLUMN `rate_table_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Authorization ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table_authorization` ALTER COLUMN `rate_table_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Authorization - Rate Table Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table_authorization` ALTER COLUMN `underwriting_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Authorization - Underwriting Authority Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table_authorization` ALTER COLUMN `authorization_status` SET TAGS ('dbx_business_glossary_term' = 'Authorization Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table_authorization` ALTER COLUMN `deviation_percentage_limit` SET TAGS ('dbx_business_glossary_term' = 'Deviation Percentage Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table_authorization` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Authorization Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table_authorization` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Authorization Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table_authorization` ALTER COLUMN `override_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Override Allowed Flag');
