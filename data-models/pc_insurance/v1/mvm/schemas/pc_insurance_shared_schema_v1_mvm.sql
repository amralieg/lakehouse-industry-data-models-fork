-- Schema for Domain: shared | Business: Pc_Insurance | Version: v1_mvm
-- Generated on: 2026-09-20 21:40:53

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_blog_v499`.`shared` COMMENT 'Cross-domain shared reference entities (currency, UoM, calendar, classification) consolidated for Single Source of Truth (SSOT).';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` (
    `currency_id` BIGINT COMMENT 'Unique identifier for the currency. Primary key.',
    `currency_code` STRING COMMENT 'Three-letter alphabetic ISO 4217 currency code (e.g., USD, EUR, GBP, CAD, JPY).. Valid values are `^[A-Z]{3}$`',
    `country_code` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code of the primary issuing country (e.g., USA, GBR, JPN).. Valid values are `^[A-Z]{3}$`',
    `country_name` STRING COMMENT 'Full name of the primary country or territory that issues the currency.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the currency record was first created in the system.',
    `display_format` STRING COMMENT 'Standard display format pattern for currency amounts (e.g., $1,234.56 or 1.234,56 €).',
    `effective_date` DATE COMMENT 'Date when the currency became officially recognized and available for use in the system.',
    `expiration_date` DATE COMMENT 'Date when the currency was or will be withdrawn from circulation. Null for active currencies.',
    `is_active` BOOLEAN COMMENT 'Indicates whether the currency is currently active and in circulation for financial transactions.',
    `is_crypto` BOOLEAN COMMENT 'Indicates whether the currency is a cryptocurrency or digital asset rather than fiat currency.',
    `is_precious_metal` BOOLEAN COMMENT 'Indicates whether the currency represents a precious metal commodity (e.g., XAU for gold, XAG for silver).',
    `minor_unit` BIGINT COMMENT 'Number of decimal places for the currencys minor unit (e.g., 2 for USD cents, 0 for JPY).',
    `currency_name` STRING COMMENT 'Full official name of the currency (e.g., United States Dollar, Euro, British Pound Sterling).',
    `notes` STRING COMMENT 'Additional notes or comments about the currency, including special handling instructions or historical context.',
    `numeric_code` STRING COMMENT 'Three-digit numeric ISO 4217 currency code (e.g., 840 for USD, 978 for EUR).. Valid values are `^[0-9]{3}$`',
    `rounding_method` STRING COMMENT 'Standard rounding method applied to currency amounts (standard, up, down, nearest).. Valid values are `standard|up|down|nearest`',
    `sort_order` BIGINT COMMENT 'Numeric value used to control the display order of currencies in user interfaces and reports.',
    `symbol` STRING COMMENT 'Standard symbol used to represent the currency (e.g., $, €, £, ¥).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the currency record was last modified in the system.',
    CONSTRAINT pk_currency PRIMARY KEY(`currency_id`)
) COMMENT 'Reference catalog of ISO 4217 currencies used across premium, claim, billing, and reinsurance financial transactions. One row per currency code. Carries code, name, minor unit, and active flag.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` (
    `line_of_business_id` BIGINT COMMENT 'Unique identifier for the line of business. Primary key. One row per LOB.',
    `catastrophe_exposed` BOOLEAN COMMENT 'Indicates whether this line of business is exposed to catastrophe perils such as hurricane, earthquake, wildfire, requiring CAT modeling and PML analysis.',
    `combined_ratio_target_pct` DECIMAL(5,2) COMMENT 'Target combined ratio percentage for this line of business, calculated as loss ratio plus expense ratio, used for profitability assessment.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this line of business record was first created in the system.',
    `default_commission_pct` DECIMAL(5,2) COMMENT 'Standard commission percentage paid to producers for new business in this line of business, subject to producer appointment and agency agreement terms.',
    `default_policy_term_months` BIGINT COMMENT 'Standard policy term duration in months for this line of business, typically 12 months for annual policies or 6 months for semi-annual policies.',
    `line_of_business_description` STRING COMMENT 'Detailed business description of the line of business, including coverage scope, typical insured risks, and key characteristics.',
    `display_order` BIGINT COMMENT 'Numeric sequence for sorting and displaying lines of business in user interfaces, reports, and policy administration screens.',
    `effective_date` DATE COMMENT 'Date when this line of business became available for underwriting and policy issuance.',
    `expense_ratio_target_pct` DECIMAL(5,2) COMMENT 'Target expense ratio percentage for this line of business, including commission, underwriting expenses, and general overhead allocation.',
    `expiration_date` DATE COMMENT 'Date when this line of business was discontinued or withdrawn from the market. Null for active lines.',
    `is_admitted` BOOLEAN COMMENT 'Indicates whether this line of business is written on an admitted basis, subject to state guaranty fund protection and rate/form regulation.',
    `is_surplus_lines` BOOLEAN COMMENT 'Indicates whether this line of business is written on a surplus lines basis, requiring stamping office approval and diligent search documentation.',
    `iso_line_code` STRING COMMENT 'ISO standard code for the line of business, used for forms, rating, and industry benchmarking.. Valid values are `^[A-Z0-9]{2,6}$`',
    `line_of_business_status` STRING COMMENT 'Current operational status of the line of business, indicating whether it is actively written, inactive, discontinued, or pending regulatory approval.. Valid values are `Active|Inactive|Discontinued|Pending Approval`',
    `lob_abbreviation` STRING COMMENT 'Standard industry abbreviation for the line of business, such as HO, PAP, CGL, BOP, CPP, WC, CA.',
    `lob_category` STRING COMMENT 'High-level classification of the line of business into Personal Lines, Commercial Lines, Specialty Lines, or Surplus Lines.. Valid values are `Personal Lines|Commercial Lines|Specialty Lines|Surplus Lines`',
    `lob_code` STRING COMMENT 'Short alphanumeric code uniquely identifying the line of business. Used across policy, coverage, premium, claim, and reinsurance systems.. Valid values are `^[A-Z0-9]{2,10}$`',
    `lob_name` STRING COMMENT 'Full business name of the line of business, such as Homeowners, Personal Auto Policy, Commercial General Liability, Business Owners Policy.',
    `lob_type` STRING COMMENT 'Primary type classification of the line of business, indicating whether it is Property, Casualty, Liability, Auto, Workers Compensation, or Package coverage.. Valid values are `Property|Casualty|Liability|Auto|Workers Compensation|Package`',
    `loss_ratio_target_pct` DECIMAL(5,2) COMMENT 'Target loss ratio percentage for this line of business, used for pricing, underwriting guidelines, and profitability monitoring.',
    `minimum_premium_amount` DECIMAL(15,2) COMMENT 'Minimum premium amount in USD required to issue a policy for this line of business, enforced at underwriting and rating.',
    `naic_line_code` STRING COMMENT 'Official NAIC numeric code for the line of business, used in statutory reporting and Schedule P filings.. Valid values are `^[0-9]{2,3}$`',
    `regulatory_approval_date` DATE COMMENT 'Date when the line of business received regulatory approval from the state Department of Insurance for writing new business.',
    `reinsurance_treaty_applicable` BOOLEAN COMMENT 'Indicates whether this line of business is covered under one or more reinsurance treaties, requiring cession and bordereaux reporting.',
    `requires_state_filing` BOOLEAN COMMENT 'Indicates whether rates, forms, and policy language for this line of business require prior approval or filing with state regulators.',
    `schedule_p_line_number` STRING COMMENT 'NAIC Schedule P line number for statutory loss reserve reporting, used in annual statement filings and actuarial reserve analysis.. Valid values are `^[0-9]{1,2}$`',
    `supports_package_policy` BOOLEAN COMMENT 'Indicates whether this line of business can be combined with other lines into a package policy such as Commercial Package Policy or Business Owners Policy.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this line of business record was last modified.',
    CONSTRAINT pk_line_of_business PRIMARY KEY(`line_of_business_id`)
) COMMENT 'Reference catalog of P&C lines of business (HO, PAP, CGL, BOP, CPP, WC, Commercial Auto, Umbrella). One row per LOB. SSOT for LOB codes referenced by policy, coverage, premium, claim, and reinsurance.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` (
    `calendar_id` BIGINT COMMENT 'Unique identifier for the calendar period record. Primary key.',
    `accident_year` BIGINT COMMENT 'Four-digit accident year for loss reserving and IBNR calculations per NAIC Schedule P.',
    `close_date` DATE COMMENT 'Date when the period was closed for accounting purposes.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this calendar period record was first created in the system.',
    `day_count` BIGINT COMMENT 'Number of days in the period, used for premium earning and reserve calculations.',
    `end_date` DATE COMMENT 'Last date of the calendar period, inclusive.',
    `fiscal_month` BIGINT COMMENT 'Fiscal month number (1-12) within the fiscal year.',
    `fiscal_quarter` BIGINT COMMENT 'Fiscal quarter number (1-4) within the fiscal year.',
    `fiscal_year` BIGINT COMMENT 'Four-digit fiscal year as defined by the organizations fiscal calendar.',
    `fiscal_year_start_month` BIGINT COMMENT 'Calendar month (1-12) when the fiscal year begins for this organization.',
    `gaap_period_key` STRING COMMENT 'Period identifier for GAAP financial reporting and consolidation.',
    `ifrs17_period_key` STRING COMMENT 'Period identifier for IFRS 17 insurance contracts standard reporting.',
    `is_closed` BOOLEAN COMMENT 'Indicates whether the period is closed for financial transactions and reporting.',
    `is_current_period` BOOLEAN COMMENT 'Indicates whether this period includes the current system date.',
    `is_leap_year` BOOLEAN COMMENT 'Indicates whether the calendar year is a leap year (366 days).',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this calendar period record was last modified.',
    `month` BIGINT COMMENT 'Calendar month number (1-12) within the calendar year.',
    `naic_reporting_quarter` BIGINT COMMENT 'Quarter number (1-4) for NAIC quarterly statement filing.',
    `naic_reporting_year` BIGINT COMMENT 'Four-digit year for NAIC Annual Statement and Schedule P/F reporting.',
    `period_key` STRING COMMENT 'Business identifier for the period in standard format (e.g., 2024-Q1, 2024-01, AY2024, PY2024-01-01).',
    `period_name` STRING COMMENT 'Human-readable name of the period (e.g., January 2024, Q1 FY2024, Accident Year 2024).',
    `period_status` STRING COMMENT 'Current status of the period for transaction posting and reporting.. Valid values are `open|closed|locked|archived`',
    `period_type` STRING COMMENT 'Type of calendar period: Calendar Year (CY), Policy Year (PY), Accident Year (AY), Fiscal Year, Quarter, Month, or Week. [ENUM-REF-CANDIDATE',
    `policy_year` BIGINT COMMENT 'Four-digit policy year for premium and loss aggregation by policy effective date cohort.',
    `quarter` BIGINT COMMENT 'Calendar quarter number (1-4) within the calendar year.',
    `reporting_period_key` STRING COMMENT 'Standardized key for regulatory and statutory reporting (e.g., 2024Q1, 202401).',
    `sap_period_key` STRING COMMENT 'Period identifier for Statutory Accounting Principles reporting and compliance.',
    `start_date` DATE COMMENT 'First date of the calendar period, inclusive.',
    `valuation_date` DATE COMMENT 'Date used for reserve valuation, loss triangle development, and actuarial analysis for this period.',
    `week` BIGINT COMMENT 'ISO week number (1-53) within the calendar year.',
    `year` BIGINT COMMENT 'Four-digit calendar year (e.g., 2024).',
    CONSTRAINT pk_calendar PRIMARY KEY(`calendar_id`)
) COMMENT 'Enterprise calendar reference of fiscal, accident, policy, and calendar-year periods. One row per period. Complements domain-local accounting_period tables by providing a single cross-domain date dimension.';

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`shared` SET TAGS ('dbx_division' = 'corporate');
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`shared` SET TAGS ('dbx_domain' = 'shared');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` SET TAGS ('dbx_data_type' = 'Master');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` SET TAGS ('dbx_subdomain' = 'shared_core');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `country_name` SET TAGS ('dbx_business_glossary_term' = 'Country Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `country_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `display_format` SET TAGS ('dbx_business_glossary_term' = 'Display Format');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Active Status Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `is_crypto` SET TAGS ('dbx_business_glossary_term' = 'Cryptocurrency Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `is_precious_metal` SET TAGS ('dbx_business_glossary_term' = 'Precious Metal Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `minor_unit` SET TAGS ('dbx_business_glossary_term' = 'Minor Unit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `currency_name` SET TAGS ('dbx_business_glossary_term' = 'Currency Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `currency_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `numeric_code` SET TAGS ('dbx_business_glossary_term' = 'Numeric Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `numeric_code` SET TAGS ('dbx_value_regex' = '^[0-9]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `rounding_method` SET TAGS ('dbx_business_glossary_term' = 'Rounding Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `rounding_method` SET TAGS ('dbx_value_regex' = 'standard|up|down|nearest');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `sort_order` SET TAGS ('dbx_business_glossary_term' = 'Sort Order');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `symbol` SET TAGS ('dbx_business_glossary_term' = 'Currency Symbol');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`currency` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` SET TAGS ('dbx_data_type' = 'Master');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` SET TAGS ('dbx_subdomain' = 'shared_core');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `catastrophe_exposed` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposure Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `combined_ratio_target_pct` SET TAGS ('dbx_business_glossary_term' = 'Combined Ratio (CR) Target Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `default_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Default Commission Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `default_policy_term_months` SET TAGS ('dbx_business_glossary_term' = 'Default Policy Term in Months');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `line_of_business_description` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `display_order` SET TAGS ('dbx_business_glossary_term' = 'Display Order Sequence');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `expense_ratio_target_pct` SET TAGS ('dbx_business_glossary_term' = 'Expense Ratio (ER) Target Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `is_admitted` SET TAGS ('dbx_business_glossary_term' = 'Admitted Line Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `is_surplus_lines` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `iso_line_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Line Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `iso_line_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,6}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `line_of_business_status` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `line_of_business_status` SET TAGS ('dbx_value_regex' = 'Active|Inactive|Discontinued|Pending Approval');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `lob_abbreviation` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Abbreviation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `lob_category` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `lob_category` SET TAGS ('dbx_value_regex' = 'Personal Lines|Commercial Lines|Specialty Lines|Surplus Lines');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `lob_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `lob_name` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `lob_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `lob_type` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `lob_type` SET TAGS ('dbx_value_regex' = 'Property|Casualty|Liability|Auto|Workers Compensation|Package');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `loss_ratio_target_pct` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR) Target Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `minimum_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `naic_line_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Line Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `naic_line_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2,3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `regulatory_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `reinsurance_treaty_applicable` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty Applicable Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `requires_state_filing` SET TAGS ('dbx_business_glossary_term' = 'State Filing Requirement Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `requires_state_filing` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `schedule_p_line_number` SET TAGS ('dbx_business_glossary_term' = 'Schedule P Line Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `schedule_p_line_number` SET TAGS ('dbx_value_regex' = '^[0-9]{1,2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `supports_package_policy` SET TAGS ('dbx_business_glossary_term' = 'Package Policy Support Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` SET TAGS ('dbx_data_type' = 'Master');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` SET TAGS ('dbx_subdomain' = 'shared_core');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `close_date` SET TAGS ('dbx_business_glossary_term' = 'Period Close Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `day_count` SET TAGS ('dbx_business_glossary_term' = 'Day Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Period End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `fiscal_month` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Month');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `fiscal_quarter` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Quarter');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `fiscal_year_start_month` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year Start Month');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `gaap_period_key` SET TAGS ('dbx_business_glossary_term' = 'Generally Accepted Accounting Principles (GAAP) Period Key');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `ifrs17_period_key` SET TAGS ('dbx_business_glossary_term' = 'IFRS 17 Period Key');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `is_closed` SET TAGS ('dbx_business_glossary_term' = 'Is Closed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `is_current_period` SET TAGS ('dbx_business_glossary_term' = 'Is Current Period Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `is_leap_year` SET TAGS ('dbx_business_glossary_term' = 'Is Leap Year Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `month` SET TAGS ('dbx_business_glossary_term' = 'Calendar Month');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `naic_reporting_quarter` SET TAGS ('dbx_business_glossary_term' = 'NAIC Reporting Quarter');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `naic_reporting_year` SET TAGS ('dbx_business_glossary_term' = 'NAIC Reporting Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `period_key` SET TAGS ('dbx_business_glossary_term' = 'Period Key');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `period_name` SET TAGS ('dbx_business_glossary_term' = 'Period Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `period_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `period_status` SET TAGS ('dbx_business_glossary_term' = 'Period Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `period_status` SET TAGS ('dbx_value_regex' = 'open|closed|locked|archived');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `period_type` SET TAGS ('dbx_business_glossary_term' = 'Period Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `quarter` SET TAGS ('dbx_business_glossary_term' = 'Calendar Quarter');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `reporting_period_key` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Key');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `sap_period_key` SET TAGS ('dbx_business_glossary_term' = 'Statutory Accounting Principles (SAP) Period Key');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Period Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `week` SET TAGS ('dbx_business_glossary_term' = 'Calendar Week');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`shared`.`calendar` ALTER COLUMN `year` SET TAGS ('dbx_business_glossary_term' = 'Calendar Year');
