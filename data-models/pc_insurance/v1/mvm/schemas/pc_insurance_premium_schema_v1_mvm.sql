-- Schema for Domain: premium | Business: Pc_Insurance | Version: v1_mvm
-- Generated on: 2026-09-20 21:40:52

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_blog_v499`.`premium` COMMENT 'Transactional ledger for all premium activity. Owns Premium Transaction (one row per financial transaction: Written, Earned, Unearned, Return) tied to Policy, Policy Term, Coverage, Insured Risk, and Accounting Period, with Charge, Tax, Fee, and';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` (
    `premium_transaction_id` BIGINT COMMENT 'Unique surrogate identifier for each premium financial movement record. Grain: one row per financial premium movement (Written, Earned, Unearned, Return). Primary key.',
    `accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this premium transaction is recognized for statutory and GAAP reporting purposes.',
    `agency_id` BIGINT COMMENT 'Foreign key linking to producers.agency. Business justification: Agency-bill premium reconciliation requires attributing premium transactions directly to the billing agency for agency account statements and premium trust accounting.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Premium transactions posted to accounting periods require calendar dimensions for fiscal/accident/policy year reporting.',
    `claim_id` BIGINT COMMENT 'Foreign key linking to claims.claim. Business justification: Retrospectively-rated policies (workers comp, general liability) adjust premium based on actual claim experience during the policy term.',
    `coverage_id` BIGINT COMMENT 'Reference to the specific coverage line within the policy term to which this premium transaction is allocated. Enables per-coverage premium analytics.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Premium transactions record amounts in specific currencies. Multi-currency operations require proper FK for FX validation, conversion, and regulatory reporting.',
    `distribution_channel_id` BIGINT COMMENT 'Foreign key linking to producers.distribution_channel. Business justification: Distribution channel written premium volume reporting is a core P&C management report for growth and profitability analysis by channel.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Premium transactions require geographic attribution for statutory state pages, territorial profitability analysis, regulatory reporting, and geographic concentration',
    `household_id` BIGINT COMMENT 'Foreign key linking to party.household. Business justification: Personal lines household-level premium aggregation reports (total written premium per household, retention analysis, cross-sell scoring) require direct household linkage on premium',
    `insured_risk_id` BIGINT COMMENT 'Reference to the insured risk or exposure unit (property, vehicle, driver) to which this premium transaction is allocated.',
    `line_id` BIGINT COMMENT 'Foreign key linking to policy.line. Business justification: P&C premium is written and earned at the line-of-business level on a policy. Line-level written premium reports, loss ratio monitoring by LOB, and reinsurance cession calculations require linking',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Normalize lob_code string to FK reference to shared.line_of_business master data. Premium transaction currently stores lob_code as string; replacing with FK enables consistent LOB',
    `location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.location. Business justification: Commercial lines CAT accumulation reports and exposure management aggregate written/earned premium by insured location.',
    `original_transaction_premium_transaction_id` BIGINT COMMENT 'Reference to the original premium transaction that this record reverses or corrects. Populated only when reversal_indicator is True. Supports audit trail.',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which this premium transaction was generated. Links the premium ledger entry to the master policy record.',
    `policy_term_id` BIGINT COMMENT 'Reference to the specific policy term (time-bounded period) to which this premium transaction belongs. Enables reconstruction of premium in force at any date.',
    `policy_transaction_id` BIGINT COMMENT 'Reference to the policy transaction (New Business, Renewal, Endorsement, Cancellation, Reinstatement) that triggered this premium movement.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer (agent or broker) associated with this premium transaction for commission settlement and distribution channel reporting.',
    `quote_id` BIGINT COMMENT 'Foreign key linking to coverage.quote. Business justification: Premium transactions originate from bound quotes; accounting audit trail requires quote reference for rate reconciliation, variance analysis between quoted and booked premium, and',
    `rate_table_id` BIGINT COMMENT 'Foreign key linking to premium.rate_table. Business justification: Links each premium transaction to the versioned rate table used to price it, enabling audit of which rate filing, base rate, and algorithm produced the written premium.',
    `territory_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.territory. Business justification: Written and earned premium must be aggregated by rating territory for state rate filings, loss ratio monitoring, and reinsurance bordereau reporting.',
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
    `transaction_type` STRING COMMENT 'Classifies the premium movement. Allowed values: Written, Earned, Unearned, Return.. Valid values are `^(Written|Earned|Unearned|Return)$`',
    `unearned_premium` DECIMAL(18,4) COMMENT 'Portion of written premium not yet earned as of the accounting period end date. Represents the UEP reserve liability on the balance sheet.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this premium transaction record was last modified. Supports audit trail, change detection, and incremental data loading.',
    CONSTRAINT pk_premium_transaction PRIMARY KEY(`premium_transaction_id`)
) COMMENT 'Grain: one row per financial transaction. Each record represents a single premium financial transaction (Written, Earned, Unearned, Return) tied to Policy, Policy Term, Coverage, Insured Risk, and Accounting Period.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` (
    `charge_id` BIGINT COMMENT 'Unique identifier for the charge component within a premium transaction.',
    `accounting_period_id` BIGINT COMMENT 'Foreign key to the accounting period in which this charge is recognized.',
    `agency_id` BIGINT COMMENT 'Foreign key linking to producers.agency. Business justification: Agency-bill reconciliation requires attributing charges directly to the billing agency. Agency bill statements aggregate charges by agency account; without a direct agency FK on charge',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Charges posted to accounting periods. FK enables period-based charge analysis, fiscal year reporting, and ensures charges align with calendar dimensions for financial statements.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Wind, hail, and hurricane surcharges are rated and reported by cat zone. Underwriters and actuaries aggregate charge amounts by cat zone for concentration monitoring and',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Individual rating charges (wind surcharges, earthquake deductible buybacks) are event-specific for post-catastrophe pricing adjustments, experience rating, and',
    `coverage_id` BIGINT COMMENT 'Foreign key to the coverage to which this charge applies, if coverage-specific.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Charges have amounts denominated in currency. FK enables currency validation, FX conversion for consolidated reporting, and ensures charge amounts reference valid active currencies for',
    `driver_id` BIGINT COMMENT 'Foreign key linking to riskexposure.driver. Business justification: Personal auto point surcharges, defensive driving credits, and good-student discounts are booked as named charges attributed to a specific driver.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Individual charges require geographic assignment for tax calculation, surplus lines allocation, territorial rating factors, and jurisdictional compliance.',
    `insured_risk_id` BIGINT COMMENT 'Foreign key to the insured risk to which this charge applies, if risk-specific.',
    `line_id` BIGINT COMMENT 'Foreign key linking to policy.line. Business justification: Surcharges, schedule credits/debits, and minimum premium charges apply at the policy line level in multi-line commercial policies.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Charges apply to specific lines of business. FK enables LOB-specific charge analysis, regulatory reporting by line, and ensures charges reference valid active LOBs.',
    `location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.location. Business justification: Commercial multi-location policies apply location-specific surcharges (protection class charges, earthquake zone loadings, flood zone assessments).',
    `peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Individual charges (earthquake coverage, flood buyback, wind deductible) are peril-specific for pricing transparency, regulatory compliance, coverage verification, and claims',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy to which this charge applies.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this charge is effective.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: Every charge (surcharge, credit, minimum premium) is generated by a specific policy transaction (endorsement, cancellation, renewal).',
    `producers_producer_id` BIGINT COMMENT 'Foreign key linking to producers.producers_producer. Business justification: Producer commission statement generation and commissionable charge reconciliation require tracing each charge to the writing producer.',
    `rate_table_id` BIGINT COMMENT 'Foreign key linking to premium.rate_table. Business justification: Links each charge component (base premium, surcharge, credit) to the specific rate table entry that produced it, supporting regulatory filing traceability and actuarial audit.',
    `territory_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.territory. Business justification: Rating charges (base premium, increased limits factors, deductible credits) are computed from territory-specific rate relativities.',
    `vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.vehicle. Business justification: Commercial auto policies apply per-vehicle charges such as safety equipment credits, anti-theft discounts, and radius-of-operation surcharges.',
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
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Tax amounts recorded in specific currencies. Multi-currency tax remittance requires proper FK for currency validation, FX conversion, and regulatory tax reporting across jurisdictions with',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Tax jurisdiction mapping requires geographic hierarchy for proper remittance, surplus lines stamping office allocation, multi-state tax apportionment, and regulatory',
    `insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Surplus lines stamping offices and state tax authorities require tax levy allocation to specific insured risks on multi-risk policies.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Tax rates and remittance vary by line of business. FK enables LOB-specific tax reporting, regulatory compliance by line, and ensures taxes reference valid LOBs for statutory reporting.',
    `location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.location. Business justification: Surplus lines tax stamping and state premium tax remittance are jurisdiction-specific and require the precise insured property address.',
    `original_tax_levy_id` BIGINT COMMENT 'Foreign key to the original tax levy record being adjusted or corrected, if this is an adjustment transaction. Null for original levies.',
    `peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophegeography_peril. Business justification: Surplus lines stamping fees and state-mandated levies are often peril-specific (flood vs. wind vs. earthquake).',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy associated with this tax levy for direct policy-level aggregation.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this tax levy was assessed.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: State surplus lines stamping and tax remittance filings require tracing each tax levy to the specific policy transaction that triggered it (new business, endorsement, cancellation',
    `state_reg_id` BIGINT COMMENT 'Foreign key linking to policy.state_reg. Business justification: Surplus lines stamping fees, guaranty fund assessments, and municipal taxes are governed by the state regulatory record for the policy.',
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
    `accounting_period_id` BIGINT COMMENT 'Foreign key to the accounting period in which this fee transaction is recognized for statutory and financial reporting.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Fees posted to accounting periods. FK enables period-based fee analysis, fiscal year fee revenue reporting, and ensures fees align with calendar dimensions for financial statements.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Policy fees denominated in currency. FK enables currency validation, FX conversion for consolidated fee revenue reporting, and ensures fee amounts reference valid active currencies for',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Policy fees vary by state and jurisdiction (inspection fees, filing fees, surplus lines fees).',
    `invoice_id` BIGINT COMMENT 'Foreign key to the billing invoice on which this fee appears; null if not yet invoiced.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Policy fees vary by line of business (e.g., surplus lines inspection fees, admitted policy fees).',
    `payment_plan_id` BIGINT COMMENT 'Foreign key to the payment plan under which this fee is financed; null for full-pay policies.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy to which this fee applies.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this fee was charged.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: Installment fees, reinstatement fees, and inspection fees are each triggered by a specific policy transaction.',
    `premium_transaction_id` BIGINT COMMENT 'Unique identifier of the fee transaction in the source operational system for audit and reconciliation.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key linking to producers.producers_producer. Business justification: Broker fee tracking and producer statement reconciliation require knowing which producer generated each policy fee.',
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
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy fee record was last updated in the source system.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding this fee transaction, for audit and customer service reference.',
    `reversal_date` DATE COMMENT 'Date on which the fee was reversed or refunded; null if not reversed.',
    `reversal_reason_code` STRING COMMENT 'Code indicating the reason for fee reversal or refund; null if not reversed.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system that originated this fee transaction.',
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
    `commission_rule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_rule. Business justification: Commission dispute resolution and audit trail require identifying which specific commission rule produced each commission amount.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: Commission audit and recalculation require tracing each commission record to the schedule that drove the rate.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Commission amounts in specific currencies. Multi-currency producer accounting requires proper FK for currency validation, FX conversion, and accurate producer compensation reporting across',
    `disbursement_id` BIGINT COMMENT 'Foreign key linking to billing.disbursement. Business justification: Commission records earned amounts; disbursement records actual payment to producer. Reconciliation of earned vs paid commission is critical for producer accounting, commission payable',
    `distribution_channel_id` BIGINT COMMENT 'Foreign key linking to producers.distribution_channel. Business justification: Distribution channel commission cost reporting is a standard P&C management report segmenting commission expense by channel (direct, independent agent, broker) for',
    `license_id` BIGINT COMMENT 'Foreign key linking to party.license. Business justification: Commission eligibility and payment often depend on active license status at transaction date.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Commission rates vary by line of business. FK enables LOB-specific producer compensation analysis, commission schedule management by line, and ensures commissions reference valid LOBs.',
    `original_commission_id` BIGINT COMMENT 'Foreign key to the original commission record that this transaction reverses or adjusts.',
    `payee_party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Commission disbursement requires identifying the payee party for 1099 tax reporting, W-9 verification, and OFAC screening — all named regulatory obligations.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy associated with this commission.',
    `policy_producer_id` BIGINT COMMENT 'Foreign key linking to policy.policy_producer. Business justification: Split-commission calculations and producer statement generation require knowing the specific policy_producer appointment record (split percentage, commission plan, of-record flag)',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this commission was earned.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: Commission chargeback processing and producer statement reconciliation require knowing which specific policy transaction (cancellation, endorsement, reinstatement) triggered each',
    `producer_appointment_id` BIGINT COMMENT 'Foreign key linking to producers.producer_appointment. Business justification: State DOI regulatory reporting requires verifying commission was paid only under a valid, active producer appointment.',
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
    `split_percentage` DECIMAL(5,2) COMMENT 'The percentage of the total commission allocated to this producer when commission is split among multiple producers.',
    `tax_withholding_amount` DECIMAL(15,2) COMMENT 'The amount of tax withheld from the commission payment, if applicable.',
    `tier_level` STRING COMMENT 'The producer tier or level within a tiered commission structure, affecting the commission rate.',
    `transaction_date` DATE COMMENT 'The date on which the commission transaction was recorded.',
    CONSTRAINT pk_commission PRIMARY KEY(`commission_id`)
) COMMENT 'Child of Premium Transaction. One row per producer commission calculation on a transaction: type (new/renewal/contingent), rate, basis, and computed payable. Calculation-only; commission settlement/payout is owned by the producers domain.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` (
    `rate_table_id` BIGINT COMMENT 'Unique identifier for the rate table version. Primary key.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Rate tables are versioned by regulatory filing period. Actuarial rate change reporting and period-over-period rate adequacy analysis require aligning rate table versions to calendar',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Rating tables are zone-specific with different base rates, territorial factors, and catastrophe loadings by geographic hazard.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Bound coverages must reference the filed rate table used for premium calculation to support premium audits, rate justification during regulatory examinations, and actuarial analysis of',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Rate tables denominated in specific currencies. FK enables currency-specific rating, FX conversion for international rating, and ensures rates reference valid currencies for underwriting and',
    `filing_organization_id` BIGINT COMMENT 'Foreign key linking to party.organization. Business justification: Rate tables are filed by or on behalf of specific carrier organizations or MGAs. Linking rate_table to organization supports regulatory compliance (which entity filed this rate)',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Rating tables are geography-specific with territorial base rates, protection class adjustments, jurisdiction-specific factors, and regulatory filing requirements.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Rate tables specific to line of business. FK enables LOB-specific rating, regulatory filing management by line, and ensures rates reference valid LOBs for underwriting and pricing.',
    `peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Rate tables are peril-specific (wind vs. earthquake vs. flood) with distinct actuarial bases, loss costs, regulatory filings, and coverage definitions.',
    `territory_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.territory. Business justification: Each rate table entry applies to a specific rating territory. Actuarial rate filings, state approval workflows, and territory-level loss-cost analyses require directly joining',
    `type_id` BIGINT COMMENT 'Foreign key linking to policy.policy_type. Business justification: Rate tables are filed, approved, and versioned per policy type (HO3, BOP, CPP, PAP). Actuarial rate adequacy reviews and state DOI filings require linking each rate table version to the',
    `actuarial_memo_reference` STRING COMMENT 'Reference number or document identifier for the actuarial memorandum supporting this rate table filing.',
    `approval_date` DATE COMMENT 'Date when the state regulator approved this rate table for use.',
    `approval_status` STRING COMMENT 'Current regulatory approval status of this rate table version.. Valid values are `draft|filed|approved|rejected|withdrawn|superseded`',
    `base_rate_amount` DECIMAL(15,4) COMMENT 'Primary rate value or starting premium amount before application of factors and adjustments.',
    `rate_table_code` STRING COMMENT 'Business identifier for the rate table, typically combining LOB, state, and version components for external reference.',
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
    `trend_factor` DECIMAL(5,4) COMMENT 'Actuarial trend adjustment factor applied to historical loss data to project future losses for this rate table.',
    `version_number` STRING COMMENT 'Sequential version identifier for this rate table edition, incremented with each filing or update.',
    `withdrawn_date` DATE COMMENT 'Date when this rate table version was removed from active use in the rating engine.',
    CONSTRAINT pk_rate_table PRIMARY KEY(`rate_table_id`)
) COMMENT 'Versioned rate table published by the rating engine for a specific LOB, state, and effective date. Stores base rates, factors, and minimum premiums. Provides the authoritative rate version used to price each Policy Term.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_original_transaction_premium_transaction_id` FOREIGN KEY (`original_transaction_premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_rate_table_id` FOREIGN KEY (`rate_table_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`rate_table`(`rate_table_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_rate_table_id` FOREIGN KEY (`rate_table_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`rate_table`(`rate_table_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_original_tax_levy_id` FOREIGN KEY (`original_tax_levy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy`(`tax_levy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_original_commission_id` FOREIGN KEY (`original_commission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`commission`(`commission_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`premium` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`premium` SET TAGS ('dbx_domain' = 'premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` SET TAGS ('dbx_subdomain' = 'transaction_recording');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `household_id` SET TAGS ('dbx_business_glossary_term' = 'Household Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `line_id` SET TAGS ('dbx_business_glossary_term' = 'Line Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `location_id` SET TAGS ('dbx_business_glossary_term' = 'Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `original_transaction_premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Original Premium Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `rate_table_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `territory_id` SET TAGS ('dbx_business_glossary_term' = 'Territory Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = '^(Written|Earned|Unearned|Return)$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `unearned_premium` SET TAGS ('dbx_business_glossary_term' = 'Unearned Premium (UEP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `unearned_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `unearned_premium` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` SET TAGS ('dbx_subdomain' = 'component_breakdown');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `charge_id` SET TAGS ('dbx_business_glossary_term' = 'Charge Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `driver_id` SET TAGS ('dbx_business_glossary_term' = 'Driver Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `line_id` SET TAGS ('dbx_business_glossary_term' = 'Line Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `location_id` SET TAGS ('dbx_business_glossary_term' = 'Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producers Producer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `rate_table_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `territory_id` SET TAGS ('dbx_business_glossary_term' = 'Territory Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ALTER COLUMN `vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` SET TAGS ('dbx_subdomain' = 'component_breakdown');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `tax_levy_id` SET TAGS ('dbx_business_glossary_term' = 'Tax Levy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `location_id` SET TAGS ('dbx_business_glossary_term' = 'Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `original_tax_levy_id` SET TAGS ('dbx_business_glossary_term' = 'Original Tax Levy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `peril_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophegeography Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `state_reg_id` SET TAGS ('dbx_business_glossary_term' = 'State Reg Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ALTER COLUMN `state_reg_id` SET TAGS ('dbx_pii_address' = 'true');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` SET TAGS ('dbx_subdomain' = 'component_breakdown');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `policy_fee_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Fee Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `payment_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Source Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producers Producer Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `reversal_date` SET TAGS ('dbx_business_glossary_term' = 'Reversal Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `reversal_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` SET TAGS ('dbx_subdomain' = 'component_breakdown');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `commission_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `commission_rule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Rule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `disbursement_id` SET TAGS ('dbx_business_glossary_term' = 'Disbursement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `license_id` SET TAGS ('dbx_business_glossary_term' = 'License Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `original_commission_id` SET TAGS ('dbx_business_glossary_term' = 'Original Commission Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `payee_party_id` SET TAGS ('dbx_business_glossary_term' = 'Payee Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `policy_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Producer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `producer_appointment_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Appointment Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `split_percentage` SET TAGS ('dbx_business_glossary_term' = 'Split Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `tax_withholding_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Withholding Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `tier_level` SET TAGS ('dbx_business_glossary_term' = 'Tier Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` SET TAGS ('dbx_subdomain' = 'transaction_recording');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `rate_table_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Table ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `filing_organization_id` SET TAGS ('dbx_business_glossary_term' = 'Filing Organization Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `territory_id` SET TAGS ('dbx_business_glossary_term' = 'Territory Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `type_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `actuarial_memo_reference` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Memo Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|filed|approved|rejected|withdrawn|superseded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `base_rate_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Rate Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `rate_table_code` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Code');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `trend_factor` SET TAGS ('dbx_business_glossary_term' = 'Trend Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ALTER COLUMN `withdrawn_date` SET TAGS ('dbx_business_glossary_term' = 'Withdrawn Date');
