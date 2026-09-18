-- Schema for Domain: shared | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-18 02:30:19

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_v499`.`shared` COMMENT 'Cross-domain shared reference entities (currency, UoM, calendar, classification) consolidated for Single Source of Truth (SSOT).';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`shared`.`currency` (
    `currency_id` BIGINT COMMENT 'Unique identifier for the currency record. Primary key.',
    `country_code` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code for the primary country or region where this currency is the official tender.. Valid values are `^[A-Z]{3}$`',
    `country_name` STRING COMMENT 'Full name of the primary country or region where this currency is the official tender.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this currency record was first created in the system.',
    `display_format` STRING COMMENT 'Standard display format pattern for monetary amounts in this currency (e.g., $#,##0.00 for USD, €#.##0,00 for EUR).',
    `effective_date` DATE COMMENT 'Date when this currency became officially recognized and available for use in the system.',
    `expiration_date` DATE COMMENT 'Date when this currency was or will be retired or replaced (null for active currencies with no planned retirement).',
    `is_active` BOOLEAN COMMENT 'Indicates whether the currency is currently active and available for use in transactions.',
    `is_crypto` BOOLEAN COMMENT 'Indicates whether this is a cryptocurrency or digital asset rather than a fiat currency.',
    `iso_code` STRING COMMENT 'Three-letter alphabetic ISO 4217 currency code (e.g., USD, EUR, GBP, CAD, JPY).. Valid values are `^[A-Z]{3}$`',
    `minor_unit` BIGINT COMMENT 'Number of decimal places for the minor unit (e.g., 2 for cents in USD, 0 for JPY which has no minor unit).',
    `currency_name` STRING COMMENT 'Full official name of the currency (e.g., United States Dollar, Euro, British Pound Sterling).',
    `notes` STRING COMMENT 'Additional notes or comments about the currency, including special handling instructions or historical context.',
    `numeric_code` STRING COMMENT 'Three-digit numeric ISO 4217 currency code (e.g., 840 for USD, 978 for EUR).. Valid values are `^[0-9]{3}$`',
    `rounding_method` STRING COMMENT 'Standard rounding method applied to monetary calculations in this currency.. Valid values are `standard|up|down|half_up|half_down|half_even`',
    `sort_order` BIGINT COMMENT 'Numeric sort order for displaying currencies in user interfaces and reports (lower numbers appear first).',
    `symbol` STRING COMMENT 'Standard symbol or glyph representing the currency (e.g., $, €, £, ¥).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this currency record was last modified in the system.',
    CONSTRAINT pk_currency PRIMARY KEY(`currency_id`)
) COMMENT 'Reference catalog of ISO 4217 currency codes used across premium, claims, reserve, and reinsurance monetary amounts. Stores code, name, minor unit, and active flag.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`shared`.`state` (
    `state_id` BIGINT COMMENT 'Unique identifier for the state or territory record.',
    `country_id` BIGINT COMMENT 'Foreign key linking to shared.country. Business justification: States belong to countries - clear 1:N relationship. Adding FK to normalize the state-to-country relationship.',
    `active_indicator` BOOLEAN COMMENT 'Indicates whether the state record is currently active and available for policy issuance and regulatory operations.',
    `catastrophe_exposure_zone` STRING COMMENT 'Primary catastrophe exposure classification for the state used in underwriting and reinsurance placement. [ENUM-REF-CANDIDATE: Hurricane|Earthquake|Tornado|Flood|Wildfire|Multi-Peril|Low — 7 candidates stripped; promote to reference product]',
    `coastal_state_indicator` BOOLEAN COMMENT 'Indicates whether the state has coastal exposure requiring special wind and flood underwriting considerations.',
    `state_code` STRING COMMENT 'Two-letter postal abbreviation for the state or territory as defined by USPS.. Valid values are `^[A-Z]{2}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the state record was first created in the system.',
    `doi_contact_email` STRING COMMENT 'Primary contact email address for the state Department of Insurance.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `doi_contact_phone` STRING COMMENT 'Primary contact phone number for the state Department of Insurance.',
    `doi_mailing_address` STRING COMMENT 'Full mailing address for the state Department of Insurance used for regulatory correspondence and filings.',
    `doi_name` STRING COMMENT 'Official name of the state Department of Insurance or equivalent regulatory authority.',
    `doi_website_url` STRING COMMENT 'Official website URL for the state Department of Insurance for regulatory reference and filing access.. Valid values are `^https?://[a-zA-Z0-9.-]+.[a-zA-Z]{2,}(/.*)?$`',
    `effective_date` DATE COMMENT 'Date when the state record became effective in the system for operational use.',
    `expiration_date` DATE COMMENT 'Date when the state record expires or is no longer valid for operational use, null if indefinite.',
    `filing_system_type` STRING COMMENT 'Type of regulatory filing system used by the state for rate and form submissions.. Valid values are `SERFF|State Portal|Paper|Hybrid`',
    `fips_code` STRING COMMENT 'Two-digit FIPS code assigned by the US Census Bureau for state identification.. Valid values are `^[0-9]{2}$`',
    `form_filing_requirement` STRING COMMENT 'Regulatory requirement type for insurance form filings in the state.. Valid values are `Prior Approval|File and Use|Use and File|No File`',
    `guaranty_fund_participation` BOOLEAN COMMENT 'Indicates whether the state requires participation in the state guaranty fund for insurer insolvency protection.',
    `iso_program_participation` BOOLEAN COMMENT 'Indicates whether the state uses ISO rating programs and forms for property and casualty lines.',
    `licensing_authority` STRING COMMENT 'Name of the state authority responsible for producer and adjuster licensing and appointments.',
    `naic_code` STRING COMMENT 'NAIC-assigned code for state identification used in statutory reporting and regulatory filings.. Valid values are `^[0-9]{2}$`',
    `state_name` STRING COMMENT 'Full legal name of the state or territory.',
    `ncci_participation` BOOLEAN COMMENT 'Indicates whether the state participates in NCCI for workers compensation rating and statistical reporting.',
    `nipr_participation` BOOLEAN COMMENT 'Indicates whether the state participates in NIPR for streamlined producer licensing and appointment processing.',
    `premium_tax_rate` DECIMAL(5,4) COMMENT 'State premium tax rate applied to gross written premium for admitted carriers, expressed as a decimal.',
    `rate_filing_requirement` STRING COMMENT 'Regulatory requirement type for insurance rate filings in the state.. Valid values are `Prior Approval|File and Use|Use and File|No File|Flex Rating`',
    `region` STRING COMMENT 'Geographic region classification for the state or territory used for market segmentation and analysis. [ENUM-REF-CANDIDATE: Northeast|Southeast|Midwest|Southwest|West|Pacific|Territories — 7 candidates stripped; promote to reference product]',
    `residual_market_mechanism` STRING COMMENT 'Name of the state residual market mechanism or assigned risk pool for high-risk placements.',
    `stamping_office_name` STRING COMMENT 'Name of the authorized stamping office for surplus lines policy processing in the state.',
    `stamping_office_required` BOOLEAN COMMENT 'Indicates whether the state requires surplus lines policies to be stamped by a licensed stamping office.',
    `statutory_reporting_deadline` STRING COMMENT 'Annual statutory financial statement filing deadline for the state, typically March 1 or state-specific date.',
    `surplus_lines_eligible` BOOLEAN COMMENT 'Indicates whether the state permits surplus lines insurance placements for non-admitted carriers.',
    `surplus_lines_tax_rate` DECIMAL(5,4) COMMENT 'State surplus lines tax rate applied to non-admitted insurance placements, expressed as a decimal.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the state record was last modified in the system.',
    CONSTRAINT pk_state PRIMARY KEY(`state_id`)
) COMMENT 'Reference catalog of US states and territories used for filings, licensing, garaging, and jurisdiction. Stores FIPS code, postal abbreviation, DOI reference, and region.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`shared`.`country` (
    `country_id` BIGINT COMMENT 'Unique identifier for the country record. Primary key.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Country references its official/primary currency. The existing country.currency_code (STRING) should be replaced with a proper FK to currency.currency_id (BIGINT surrogate key).',
    `active_flag` BOOLEAN COMMENT 'Indicates whether the country is currently active for underwriting, claims processing, and reinsurance operations. Inactive countries are retained for historical policy and claims data.',
    `address_format_standard` STRING COMMENT 'Standard address format convention for the country. Used for policy declarations, claims correspondence, and regulatory filings to ensure proper mail delivery.',
    `cat_exposure_zone` STRING COMMENT 'Catastrophe risk exposure classification for the country. Used for CAT XL (Catastrophe Excess of Loss) treaty structuring, PML calculations, and underwriting guidelines.. Valid values are `high|moderate|low|minimal`',
    `continent_code` STRING COMMENT 'Two-letter continent code where the country is located. Used for high-level geographic risk aggregation and PML (Probable Maximum Loss) analysis. [ENUM-REF-CANDIDATE: AF|AN|AS|EU|NA|OC|SA — 7 candidates stripped; promote to reference product]',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this country record was first created in the data warehouse. Used for audit trail and data lineage tracking.',
    `data_privacy_regime` STRING COMMENT 'Primary data privacy and protection regulatory framework applicable in the country. Governs PII handling, consent requirements, and breach notification for policyholders and claimants.',
    `effective_date` DATE COMMENT 'Date when this country record became effective in the system. Used for temporal queries and historical reporting of country attributes.',
    `expiration_date` DATE COMMENT 'Date when this country record expires or was superseded. Null for currently active records. Used for slowly changing dimension management.',
    `full_name` STRING COMMENT 'Complete official name of the country including formal designations. Used for legal documents, treaties, and statutory reporting.',
    `iso_alpha_2_code` STRING COMMENT 'Two-letter country code as defined by ISO 3166-1 alpha-2 standard. Used for addresses, reinsurer domicile, and party identification.. Valid values are `^[A-Z]{2}$`',
    `iso_alpha_3_code` STRING COMMENT 'Three-letter country code as defined by ISO 3166-1 alpha-3 standard. Used for regulatory reporting and reinsurance bordereaux.. Valid values are `^[A-Z]{3}$`',
    `iso_numeric_code` STRING COMMENT 'Three-digit numeric country code as defined by ISO 3166-1 numeric standard. Used for systems requiring numeric identifiers.. Valid values are `^[0-9]{3}$`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this country record was last updated. Used for change tracking, audit compliance, and data quality monitoring.',
    `naic_country_code` STRING COMMENT 'Country code used in NAIC statutory reporting and annual statement filings. Required for Schedule P, Schedule F, and reinsurance disclosures.',
    `country_name` STRING COMMENT 'Official short name of the country in English as recognized by ISO 3166. Used for display in policy documents, claims correspondence, and regulatory filings.',
    `phone_country_code` STRING COMMENT 'International telephone dialing code prefix for the country. Used for FNOL (First Notice of Loss) contact validation and producer communication.. Valid values are `^+[0-9]{1,4}$`',
    `postal_code_format` STRING COMMENT 'Regular expression pattern defining valid postal code formats for the country. Used for address validation in policy issuance, claims processing, and producer onboarding.',
    `region_code` STRING COMMENT 'UN geographic region classification code. Used for regional risk aggregation, catastrophe modeling, and reinsurance treaty structuring.',
    `regulatory_jurisdiction_type` STRING COMMENT 'Classification of the country for insurance regulatory purposes. Determines surplus lines tax treatment, alien insurer requirements, and DOI (Department of Insurance) reporting obligations.. Valid values are `domestic|foreign_admitted|foreign_non_admitted|offshore`',
    `reinsurance_domicile_flag` BOOLEAN COMMENT 'Indicates whether the country is a recognized domicile for reinsurers. Used for credit for reinsurance determinations and collateral requirements under NAIC guidelines.',
    `sanctions_status` STRING COMMENT 'Current economic sanctions status applicable to the country. Impacts underwriting eligibility, reinsurance placement restrictions, and claims payment compliance under OFAC regulations.. Valid values are `none|partial|comprehensive|watchlist`',
    `sovereignty_status` STRING COMMENT 'Classification of the countrys political sovereignty status. Impacts regulatory jurisdiction, treaty applicability, and reinsurance placement authority.. Valid values are `independent|dependent_territory|special_administrative_region|disputed`',
    `subregion_code` STRING COMMENT 'UN geographic subregion classification code. Used for granular risk segmentation and regulatory compliance reporting.',
    CONSTRAINT pk_country PRIMARY KEY(`country_id`)
) COMMENT 'Reference catalog of ISO 3166 country codes used for addresses, reinsurers, and party identification. Stores alpha-2, alpha-3, numeric code, and name.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` (
    `org_unit_id` BIGINT COMMENT 'Unique identifier for the organizational unit. Primary key.',
    `country_id` BIGINT COMMENT 'Foreign key linking to shared.country. Business justification: Org unit is domiciled in a country (regulatory jurisdiction, legal entity location). The existing org_unit.country_code (STRING) should be replaced with a proper FK to country.country_id',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Org unit is often specialized by line of business (e.g., a branch that only writes Workers Comp, or a business unit focused on Commercial General Liability).',
    `parent_org_unit_id` BIGINT COMMENT 'Identifier of the parent organizational unit in the hierarchy, enabling multi-level organizational structures.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Org unit located in a US state (for US-based units). The existing org_unit.state_province (STRING) should be replaced with a proper FK to state.state_id (BIGINT surrogate key).',
    `address_line1` STRING COMMENT 'Primary street address line for the organizational unit physical location.',
    `address_line2` STRING COMMENT 'Secondary address line for suite, floor, or building information of the organizational unit location.',
    `budget_amount` DECIMAL(18,2) COMMENT 'Annual operating budget allocated to this organizational unit in the base currency.',
    `city` STRING COMMENT 'City name where the organizational unit is physically located.',
    `cost_center_code` STRING COMMENT 'General ledger cost center code used for financial accounting and expense allocation for this organizational unit.. Valid values are `^[A-Z0-9]{4,12}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this organizational unit record was first created in the system.',
    `org_unit_description` STRING COMMENT 'Detailed narrative describing the organizational unit purpose, scope of operations, and business responsibilities.',
    `effective_date` DATE COMMENT 'Date when this organizational unit became active and operational within the enterprise structure.',
    `expiration_date` DATE COMMENT 'Date when this organizational unit ceased operations or was closed. Null for currently active units.',
    `fein` STRING COMMENT 'Federal tax identification number assigned to this organizational unit for IRS reporting and tax purposes.. Valid values are `^d{2}-d{7}$`',
    `headcount` BIGINT COMMENT 'Number of full-time equivalent employees assigned to this organizational unit.',
    `hierarchy_level` BIGINT COMMENT 'Numeric level in the organizational hierarchy where 1 is the top level and higher numbers represent deeper nesting.',
    `is_licensed` BOOLEAN COMMENT 'Indicates whether this organizational unit holds active insurance licenses to transact business in its jurisdiction.',
    `manager_email` STRING COMMENT 'Primary email address of the organizational unit manager for business communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `manager_name` STRING COMMENT 'Full name of the individual responsible for managing this organizational unit.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this organizational unit record was last updated in the system.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code associated with this organizational unit for statutory reporting purposes.. Valid values are `^d{5}$`',
    `phone_number` STRING COMMENT 'Primary contact phone number for the organizational unit office or location.. Valid values are `^+?[1-9]d{1,14}$`',
    `postal_code` STRING COMMENT 'Postal or ZIP code for the organizational unit location.. Valid values are `^d{5}(-d{4})?$`',
    `profit_center_code` STRING COMMENT 'General ledger profit center code used for revenue and profitability tracking for this organizational unit.. Valid values are `^[A-Z0-9]{4,12}$`',
    `regulatory_jurisdiction` STRING COMMENT 'Primary state or federal regulatory authority governing this organizational unit operations and compliance.',
    `time_zone` STRING COMMENT 'IANA time zone identifier for the organizational unit location, used for scheduling and timestamp normalization.. Valid values are `^[A-Za-z/_]+$`',
    `unit_code` STRING COMMENT 'Short alphanumeric code uniquely identifying the organizational unit for reporting and system integration purposes.. Valid values are `^[A-Z0-9]{2,20}$`',
    `unit_name` STRING COMMENT 'Full business name of the organizational unit as used in internal communications and reporting.',
    `unit_status` STRING COMMENT 'Current operational status of the organizational unit in its lifecycle.. Valid values are `active|inactive|pending|closed|suspended`',
    `unit_type` STRING COMMENT 'Classification of the organizational unit indicating its role in the enterprise structure.. Valid values are `branch|region|division|business_unit|cost_center|profit_center`',
    CONSTRAINT pk_org_unit PRIMARY KEY(`org_unit_id`)
) COMMENT 'Reference hierarchy of internal organizational units (branch, region, business unit, cost center) used to attribute policies, claims, and financial transactions.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` (
    `lob_code_id` BIGINT COMMENT 'Unique identifier for the line of business code record.',
    `cat_exposure_flag` BOOLEAN COMMENT 'Indicates whether this line of business has significant catastrophe exposure requiring CAT modeling and reinsurance.',
    `claims_made_basis_flag` BOOLEAN COMMENT 'Indicates whether this line is typically written on a claims-made basis (true) versus occurrence basis (false).',
    `commission_rate_pct` DECIMAL(5,2) COMMENT 'Standard commission rate percentage paid to producers for new business in this line.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this line of business code record was first created in the system.',
    `lob_code_description` STRING COMMENT 'Detailed description of the line of business including coverage scope, typical insureds, and key characteristics.',
    `effective_date` DATE COMMENT 'Date when this line of business code became effective and available for policy issuance.',
    `expiration_date` DATE COMMENT 'Date when this line of business code expires or was discontinued (null if still active).',
    `gaap_accounting_line` STRING COMMENT 'GAAP accounting line classification for financial statement reporting under US GAAP or IFRS 17.',
    `is_admitted` BOOLEAN COMMENT 'Indicates whether this line of business is written on an admitted basis (true) or surplus lines basis (false).',
    `is_monoline` BOOLEAN COMMENT 'Indicates whether this line is typically written as a standalone monoline policy (true) or part of a package (false).',
    `is_package_eligible` BOOLEAN COMMENT 'Indicates whether this line can be included in commercial package policies (CPP, BOP).',
    `iso_line_code` STRING COMMENT 'ISO standard line of business code used for rating and statistical reporting.. Valid values are `^[A-Z0-9]{2,8}$`',
    `lob_abbreviation` STRING COMMENT 'Short abbreviation for the line of business used in operational systems and reporting.. Valid values are `^[A-Z]{2,6}$`',
    `lob_category` STRING COMMENT 'High-level category classifying the line of business (personal, commercial, specialty, reinsurance).. Valid values are `personal|commercial|specialty|reinsurance`',
    `lob_code` STRING COMMENT 'Standard code representing the line of business (e.g., GL, CGL, BOP, WC, APD, PIP).. Valid values are `^[A-Z0-9]{2,10}$`',
    `lob_name` STRING COMMENT 'Full descriptive name of the line of business (e.g., General Liability, Workers Compensation).',
    `lob_status` STRING COMMENT 'Current operational status of the line of business in the system.. Valid values are `active|inactive|suspended|discontinued`',
    `lob_type` STRING COMMENT 'Classification of the line by coverage type (property, casualty, liability, auto, workers compensation, package).. Valid values are `property|casualty|liability|auto|workers_comp|package`',
    `long_tail_flag` BOOLEAN COMMENT 'Indicates whether this is a long-tail line with extended claim development periods (e.g., GL, WC).',
    `loss_development_period_months` BIGINT COMMENT 'Typical loss development period in months for claims in this line of business.',
    `naic_line_code` STRING COMMENT 'Official NAIC statutory reporting line code for regulatory filings and annual statements.. Valid values are `^[0-9]{1,3}(.[0-9]{1,2})?$`',
    `regulatory_notes` STRING COMMENT 'Regulatory compliance notes including state-specific requirements, filing obligations, and restrictions.',
    `reinsurance_ceded_pct` DECIMAL(5,2) COMMENT 'Typical percentage of premium ceded to reinsurers for this line of business.',
    `renewal_commission_rate_pct` DECIMAL(5,2) COMMENT 'Standard commission rate percentage paid to producers for renewal business in this line.',
    `requires_state_filing` BOOLEAN COMMENT 'Indicates whether rates and forms for this line require state regulatory filing and approval.',
    `risk_based_capital_factor` DECIMAL(5,4) COMMENT 'NAIC risk-based capital factor applied to reserves and premiums for this line in RBC calculations.',
    `sort_order` BIGINT COMMENT 'Numeric sort order for displaying lines of business in user interfaces and reports.',
    `statutory_accounting_line` STRING COMMENT 'Statutory accounting line classification for annual statement reporting and reserve calculations.',
    `target_combined_ratio_pct` DECIMAL(5,2) COMMENT 'Target combined ratio percentage (loss ratio plus expense ratio) for profitability management.',
    `target_expense_ratio_pct` DECIMAL(5,2) COMMENT 'Target expense ratio percentage including commissions and operating expenses for this line.',
    `target_loss_ratio_pct` DECIMAL(5,2) COMMENT 'Target loss ratio percentage for underwriting and pricing this line of business.',
    `underwriting_notes` STRING COMMENT 'Special underwriting considerations, restrictions, or guidelines specific to this line of business.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this line of business code record was last modified.',
    CONSTRAINT pk_lob_code PRIMARY KEY(`lob_code_id`)
) COMMENT 'Reference catalog of lines of business and NAIC line codes (GL, CGL, BOP, WC, APD, PIP) used consistently across policy, coverage, premium, claims, and reserves.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` (
    `calendar_id` BIGINT COMMENT 'Unique identifier for the calendar record.',
    `accident_year` BIGINT COMMENT 'The accident year for loss reserving and actuarial analysis, representing the year in which a loss event occurred.',
    `accounting_period` STRING COMMENT 'The accounting period identifier in YYYY-MM format, used for general ledger posting and financial close processes.',
    `calendar_date` DATE COMMENT 'The specific date represented in this calendar record.',
    `cat_season_indicator` STRING COMMENT 'Indicates the active catastrophe season for this date, used for catastrophe exposure management and reinsurance treaty activation.. Valid values are `hurricane|wildfire|winter_storm|tornado|flood|none`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this calendar record was first created in the system, used for audit trail and data lineage tracking.',
    `day_name` STRING COMMENT 'The full name of the day of the week, used for human-readable reporting and operational dashboards. [ENUM-REF-CANDIDATE: Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday — 7 candidates stripped; promote to reference product]',
    `day_of_month` BIGINT COMMENT 'The day number within the calendar month (1-31), used for billing cycle and payment due date calculations.',
    `day_of_week` BIGINT COMMENT 'The day of the week as a numeric value (1=Monday, 7=Sunday), used for operational scheduling and claims intake patterns.',
    `day_of_year` BIGINT COMMENT 'The ordinal day number within the calendar year (1-366), used for daily premium earning and exposure calculations.',
    `days_in_month` BIGINT COMMENT 'The total number of days in the calendar month (28-31), used for pro-rata premium calculations and daily earning factors.',
    `days_in_year` BIGINT COMMENT 'The total number of days in the calendar year (365 or 366 for leap years), used for annual premium earning and exposure calculations.',
    `effective_date` DATE COMMENT 'The date from which this calendar record is effective, used for managing calendar dimension changes and historical accuracy.',
    `expiration_date` DATE COMMENT 'The date on which this calendar record expires or is superseded, used for managing calendar dimension changes and historical accuracy.',
    `fiscal_month` BIGINT COMMENT 'The fiscal month within the fiscal year (1-12), used for monthly accounting close and premium earning calculations.',
    `fiscal_period_end_date` DATE COMMENT 'The end date of the fiscal period to which this calendar date belongs, used for period cutoff and financial close validation.',
    `fiscal_period_start_date` DATE COMMENT 'The start date of the fiscal period to which this calendar date belongs, used for period-to-date calculations and reporting.',
    `fiscal_quarter` BIGINT COMMENT 'The fiscal quarter within the fiscal year (1-4), used for quarterly financial and regulatory reporting.',
    `fiscal_week` BIGINT COMMENT 'The fiscal week number within the fiscal year (1-53), used for operational reporting and performance tracking.',
    `fiscal_year` BIGINT COMMENT 'The fiscal year to which this date belongs, used for financial reporting and statutory compliance.',
    `holiday_name` STRING COMMENT 'The name of the holiday if this date is a recognized holiday, used for operational planning and customer communication.',
    `is_business_day` BOOLEAN COMMENT 'Indicates whether this date is a business day (excluding weekends and holidays), used for payment processing and SLA calculations.',
    `is_current` BOOLEAN COMMENT 'Indicates whether this calendar record is the current active version, used for filtering to the most recent calendar configuration.',
    `is_holiday` BOOLEAN COMMENT 'Indicates whether this date is a recognized company or statutory holiday, used for payment processing and service level agreements.',
    `is_leap_year` BOOLEAN COMMENT 'Indicates whether the calendar year is a leap year (366 days), used for accurate daily premium earning and exposure day calculations.',
    `is_month_end` BOOLEAN COMMENT 'Indicates whether this date is the last day of the calendar month, used for monthly accounting close and premium earning cutoffs.',
    `is_quarter_end` BOOLEAN COMMENT 'Indicates whether this date is the last day of the fiscal quarter, used for quarterly financial reporting and regulatory filings.',
    `is_weekend` BOOLEAN COMMENT 'Indicates whether this date falls on a weekend (Saturday or Sunday), used for operational scheduling and staffing models.',
    `is_year_end` BOOLEAN COMMENT 'Indicates whether this date is the last day of the fiscal year, used for annual statutory reporting and year-end close processes.',
    `month` BIGINT COMMENT 'The calendar month within the calendar year (1-12), used for policy effective dates and renewal cycles.',
    `month_name` STRING COMMENT 'The full name of the calendar month, used for human-readable reporting and executive dashboards. [ENUM-REF-CANDIDATE: January|February|March|April|May|June|July|August|September|October|November|December — 12 candidates stripped; promote to reference',
    `policy_year` BIGINT COMMENT 'The policy year for underwriting analysis, representing the year in which a policy was written or renewed.',
    `quarter` BIGINT COMMENT 'The calendar quarter within the calendar year (1-4), used for market analysis and external benchmarking.',
    `report_year` BIGINT COMMENT 'The report year for claims reporting analysis, representing the year in which a claim was reported to the insurer.',
    `statutory_reporting_period` STRING COMMENT 'The statutory reporting period identifier used for NAIC Annual Statement and quarterly filings, formatted as YYYY-QQ or YYYY-MM.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this calendar record was last modified, used for audit trail and change tracking.',
    `week` BIGINT COMMENT 'The calendar week number within the calendar year (1-53), used for operational scheduling and resource planning.',
    `year` BIGINT COMMENT 'The calendar year (Gregorian) to which this date belongs, used for policy term alignment and external reporting.',
    CONSTRAINT pk_calendar PRIMARY KEY(`calendar_id`)
) COMMENT 'Reference calendar of fiscal periods, accident years, and accounting months used for premium earning, reserve evaluation, and statutory reporting cadence.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` (
    `user_account_id` BIGINT COMMENT 'Primary key for user_account',
    `manager_user_account_id` BIGINT COMMENT 'Reference to the user account of the direct manager or supervisor.',
    `org_unit_id` BIGINT COMMENT 'Foreign key linking to shared.org_unit. Business justification: Users belong to organizational units (branch, region, business unit, cost center). Adding FK to link users to their org unit.',
    `created_by_user_id` BIGINT COMMENT 'Reference to the user account that created this user account record.',
    `deactivated_by_user_id` BIGINT COMMENT 'Reference to the user account that deactivated this user account.',
    `last_modified_by_user_id` BIGINT COMMENT 'Reference to the user account that most recently modified this user account record.',
    `account_expiration_date` DATE COMMENT 'Date when the user account access rights expire and require renewal or deactivation.',
    `account_locked_flag` BOOLEAN COMMENT 'Indicator whether the user account is locked due to security policy violations or administrative action.',
    `account_status` STRING COMMENT 'Current lifecycle status of the user account indicating availability and access rights.',
    `account_type` STRING COMMENT 'Classification of the user account based on role and access level within the organization.',
    `authentication_method` STRING COMMENT 'Primary authentication mechanism used for user account access.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the user account record was first created in the system.',
    `deactivated_timestamp` TIMESTAMP COMMENT 'Date and time when the user account was deactivated or terminated.',
    `deactivation_reason` STRING COMMENT 'Explanation or business justification for deactivating the user account.',
    `email_address` STRING COMMENT 'Primary email address associated with the user account for communication and authentication.',
    `employee_code` STRING COMMENT 'Unique identifier assigned to the user as an employee within the organization.',
    `failed_login_attempts` BIGINT COMMENT 'Count of consecutive unsuccessful login attempts since last successful authentication.',
    `first_name` STRING COMMENT 'Given name of the user.',
    `full_name` STRING COMMENT 'Complete legal name of the user.',
    `job_title` STRING COMMENT 'Official position or role title of the user within the organization.',
    `language_preference` STRING COMMENT 'Preferred language code for user interface and communication.',
    `last_login_timestamp` TIMESTAMP COMMENT 'Date and time of the most recent successful login to the user account.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when the user account record was most recently updated.',
    `last_name` STRING COMMENT 'Family name or surname of the user.',
    `license_expiration_date` DATE COMMENT 'Date when the professional insurance license expires and requires renewal.',
    `license_number` STRING COMMENT 'Professional insurance license number for agents, brokers, or adjusters.',
    `license_state` STRING COMMENT 'State or jurisdiction code where the professional insurance license was issued.',
    `multi_factor_enabled_flag` BOOLEAN COMMENT 'Indicator whether multi-factor authentication is enabled for enhanced account security.',
    `notes` STRING COMMENT 'Additional comments or administrative notes regarding the user account.',
    `password_last_changed_date` DATE COMMENT 'Date when the user account password was last updated or reset.',
    `phone_number` STRING COMMENT 'Primary contact phone number for the user.',
    `security_clearance_level` STRING COMMENT 'Maximum data classification level the user is authorized to access.',
    `time_zone` STRING COMMENT 'Time zone preference for the user account used for scheduling and timestamp display.',
    `username` STRING COMMENT 'Unique login identifier for the user account.',
    CONSTRAINT pk_user_account PRIMARY KEY(`user_account_id`)
) COMMENT 'Master reference table for user_account. Referenced by generated_by_user_id.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`shared`.`party` (
    `party_id` BIGINT COMMENT 'Primary key for party',
    `country_id` BIGINT COMMENT 'Foreign key linking to shared.country. Business justification: Party addresses reference countries. Currently party has country_code as STRING. Adding country_id FK to normalize country reference and enable joins to country table for ISO codes, full',
    `parent_party_id` BIGINT COMMENT 'Reference to the parent or owning party in a corporate or organizational hierarchy.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Party addresses reference states. Currently party has state_province as STRING. Adding state_id FK to normalize state reference and enable joins to state table for NAIC codes, DOI information',
    `address_line_1` STRING COMMENT 'Primary street address line including street number, street name, and unit or suite number.',
    `address_line_2` STRING COMMENT 'Secondary address line for additional location details such as building name, floor, or department.',
    `city` STRING COMMENT 'City or municipality name of the party address.',
    `commission_rate` DECIMAL(5,4) COMMENT 'Default commission percentage rate paid to the party for policies sold or serviced. Applicable to agents and brokers.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the party record was first created in the system.',
    `credit_score` BIGINT COMMENT 'Numerical credit rating score used for underwriting and pricing decisions.',
    `date_of_birth` DATE COMMENT 'Birth date of the individual party. Applicable only when party_type is individual.',
    `doing_business_as_name` STRING COMMENT 'Trade name or DBA name under which the party conducts business, if different from legal name.',
    `email_address` STRING COMMENT 'Primary email address for electronic communication with the party.',
    `established_date` DATE COMMENT 'Date the party was first established or incorporated as a legal entity.',
    `fax_number` STRING COMMENT 'Facsimile transmission number for document delivery to the party.',
    `first_name` STRING COMMENT 'Given or first name of the individual party. Applicable only when party_type is individual.',
    `gender` STRING COMMENT 'Gender identity of the individual party. Applicable only when party_type is individual.',
    `industry_code` STRING COMMENT 'Standard industry classification code for the organization party business sector.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when the party record was most recently updated or modified.',
    `last_name` STRING COMMENT 'Family or surname of the individual party. Applicable only when party_type is individual.',
    `legal_name` STRING COMMENT 'Full legal name of the party as registered with governing authorities or as appears on official identification documents.',
    `license_expiration_date` DATE COMMENT 'Date on which the party professional license expires and requires renewal.',
    `license_number` STRING COMMENT 'Professional license or certification number for parties acting as agents, brokers, or adjusters.',
    `license_state` STRING COMMENT 'State or jurisdiction that issued the professional license to the party.',
    `marital_status` STRING COMMENT 'Current marital status of the individual party, used for underwriting and rating purposes.',
    `middle_name` STRING COMMENT 'Middle name or initial of the individual party. Applicable only when party_type is individual.',
    `mobile_phone_number` STRING COMMENT 'Mobile or cellular telephone number for the party, used for SMS and mobile communication.',
    `national_producer_number` STRING COMMENT 'Unique identifier assigned by the National Association of Insurance Commissioners for licensed insurance producers.',
    `occupation` STRING COMMENT 'Primary occupation or profession of the individual party, used for risk assessment and underwriting.',
    `party_role` STRING COMMENT 'Primary business role the party plays in insurance operations: insured, claimant, agent, broker, reinsurer, or vendor.',
    `party_status` STRING COMMENT 'Current lifecycle status of the party record in the system.',
    `party_type` STRING COMMENT 'Classification of the party as individual person, organization, trust, estate, government entity, or other legal entity type.',
    `phone_number` STRING COMMENT 'Primary telephone contact number for the party, including country and area codes.',
    `postal_code` STRING COMMENT 'Postal or ZIP code for mail delivery to the party address.',
    `preferred_contact_method` STRING COMMENT 'Party preferred channel for receiving communications: email, phone, postal mail, SMS, or online portal.',
    `preferred_language` STRING COMMENT 'Two-letter ISO language code indicating the party preferred language for communication.',
    `relationship_end_date` DATE COMMENT 'Date the business relationship with this party ended or was terminated.',
    `relationship_manager_name` STRING COMMENT 'Name of the internal employee or representative assigned to manage the business relationship with this party.',
    `relationship_start_date` DATE COMMENT 'Date the business relationship with this party began.',
    `risk_rating` STRING COMMENT 'Underwriting risk classification assigned to the party based on loss history, credit, and other risk factors.',
    `suffix` STRING COMMENT 'Name suffix such as Jr., Sr., III, Esq. Applicable only when party_type is individual.',
    `tax_identification_number` STRING COMMENT 'Government-issued tax identifier: Social Security Number for individuals or Employer Identification Number for organizations.',
    `website_url` STRING COMMENT 'Primary website address for the organization party.',
    CONSTRAINT pk_party PRIMARY KEY(`party_id`)
) COMMENT 'Master reference table for party. Referenced by assigned_to_party_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ADD CONSTRAINT `fk_shared_state_country_id` FOREIGN KEY (`country_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`country`(`country_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ADD CONSTRAINT `fk_shared_country_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ADD CONSTRAINT `fk_shared_org_unit_country_id` FOREIGN KEY (`country_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`country`(`country_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ADD CONSTRAINT `fk_shared_org_unit_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ADD CONSTRAINT `fk_shared_org_unit_parent_org_unit_id` FOREIGN KEY (`parent_org_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`org_unit`(`org_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ADD CONSTRAINT `fk_shared_org_unit_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ADD CONSTRAINT `fk_shared_user_account_manager_user_account_id` FOREIGN KEY (`manager_user_account_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`user_account`(`user_account_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ADD CONSTRAINT `fk_shared_user_account_org_unit_id` FOREIGN KEY (`org_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`org_unit`(`org_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ADD CONSTRAINT `fk_shared_user_account_created_by_user_id` FOREIGN KEY (`created_by_user_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`user_account`(`user_account_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ADD CONSTRAINT `fk_shared_user_account_deactivated_by_user_id` FOREIGN KEY (`deactivated_by_user_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`user_account`(`user_account_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ADD CONSTRAINT `fk_shared_user_account_last_modified_by_user_id` FOREIGN KEY (`last_modified_by_user_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`user_account`(`user_account_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ADD CONSTRAINT `fk_shared_party_country_id` FOREIGN KEY (`country_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`country`(`country_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ADD CONSTRAINT `fk_shared_party_parent_party_id` FOREIGN KEY (`parent_party_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ADD CONSTRAINT `fk_shared_party_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_v499`.`shared` SET TAGS ('dbx_division' = 'corporate');
ALTER SCHEMA `vibe_pc_insurance_v499`.`shared` SET TAGS ('dbx_domain' = 'shared');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` SET TAGS ('dbx_subdomain' = 'reference_catalogs');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Primary Country Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `country_name` SET TAGS ('dbx_business_glossary_term' = 'Primary Country Name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `country_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `country_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `display_format` SET TAGS ('dbx_business_glossary_term' = 'Display Format Pattern');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Active Status Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `is_crypto` SET TAGS ('dbx_business_glossary_term' = 'Cryptocurrency Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `iso_code` SET TAGS ('dbx_business_glossary_term' = 'ISO (International Organization for Standardization) Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `iso_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `minor_unit` SET TAGS ('dbx_business_glossary_term' = 'Minor Unit Decimal Places');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `currency_name` SET TAGS ('dbx_business_glossary_term' = 'Currency Name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `currency_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `currency_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Currency Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `numeric_code` SET TAGS ('dbx_business_glossary_term' = 'ISO (International Organization for Standardization) Numeric Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `numeric_code` SET TAGS ('dbx_value_regex' = '^[0-9]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `rounding_method` SET TAGS ('dbx_business_glossary_term' = 'Rounding Method');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `rounding_method` SET TAGS ('dbx_value_regex' = 'standard|up|down|half_up|half_down|half_even');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `sort_order` SET TAGS ('dbx_business_glossary_term' = 'Display Sort Order');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `symbol` SET TAGS ('dbx_business_glossary_term' = 'Currency Symbol');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`currency` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` SET TAGS ('dbx_subdomain' = 'reference_catalogs');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Country Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `active_indicator` SET TAGS ('dbx_business_glossary_term' = 'Active Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `catastrophe_exposure_zone` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposure Zone');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `coastal_state_indicator` SET TAGS ('dbx_business_glossary_term' = 'Coastal State Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `doi_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Contact Email');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `doi_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `doi_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `doi_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `doi_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Contact Phone');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `doi_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `doi_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `doi_mailing_address` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Mailing Address');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `doi_mailing_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `doi_mailing_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `doi_name` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `doi_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `doi_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `doi_website_url` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Website URL');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `doi_website_url` SET TAGS ('dbx_value_regex' = '^https?://[a-zA-Z0-9.-]+.[a-zA-Z]{2,}(/.*)?$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `filing_system_type` SET TAGS ('dbx_business_glossary_term' = 'Filing System Type');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `filing_system_type` SET TAGS ('dbx_value_regex' = 'SERFF|State Portal|Paper|Hybrid');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `fips_code` SET TAGS ('dbx_business_glossary_term' = 'Federal Information Processing Standards (FIPS) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `fips_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `form_filing_requirement` SET TAGS ('dbx_business_glossary_term' = 'Form Filing Requirement');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `form_filing_requirement` SET TAGS ('dbx_value_regex' = 'Prior Approval|File and Use|Use and File|No File');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `guaranty_fund_participation` SET TAGS ('dbx_business_glossary_term' = 'Guaranty Fund Participation');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `iso_program_participation` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Program Participation');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `licensing_authority` SET TAGS ('dbx_business_glossary_term' = 'Licensing Authority');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `naic_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `state_name` SET TAGS ('dbx_business_glossary_term' = 'State Full Name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `state_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `state_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `ncci_participation` SET TAGS ('dbx_business_glossary_term' = 'National Council on Compensation Insurance (NCCI) Participation');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `nipr_participation` SET TAGS ('dbx_business_glossary_term' = 'National Insurance Producer Registry (NIPR) Participation');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `premium_tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Premium Tax Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `rate_filing_requirement` SET TAGS ('dbx_business_glossary_term' = 'Rate Filing Requirement');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `rate_filing_requirement` SET TAGS ('dbx_value_regex' = 'Prior Approval|File and Use|Use and File|No File|Flex Rating');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `residual_market_mechanism` SET TAGS ('dbx_business_glossary_term' = 'Residual Market Mechanism');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `stamping_office_name` SET TAGS ('dbx_business_glossary_term' = 'Stamping Office Name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `stamping_office_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `stamping_office_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `stamping_office_required` SET TAGS ('dbx_business_glossary_term' = 'Stamping Office Required');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `statutory_reporting_deadline` SET TAGS ('dbx_business_glossary_term' = 'Statutory Reporting Deadline');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `statutory_reporting_deadline` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `statutory_reporting_deadline` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `surplus_lines_eligible` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Eligible');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `surplus_lines_tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Tax Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`state` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` SET TAGS ('dbx_subdomain' = 'reference_catalogs');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Country Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `active_flag` SET TAGS ('dbx_business_glossary_term' = 'Active Country Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `address_format_standard` SET TAGS ('dbx_business_glossary_term' = 'Address Format Standard');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `address_format_standard` SET TAGS ('dbx_pii_category' = 'address');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `address_format_standard` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `cat_exposure_zone` SET TAGS ('dbx_business_glossary_term' = 'CAT (Catastrophe) Exposure Zone Classification');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `cat_exposure_zone` SET TAGS ('dbx_value_regex' = 'high|moderate|low|minimal');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `continent_code` SET TAGS ('dbx_business_glossary_term' = 'Continent Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `continent_code` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `continent_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `data_privacy_regime` SET TAGS ('dbx_business_glossary_term' = 'Data Privacy Regulatory Regime');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Country Record Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Country Record Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `full_name` SET TAGS ('dbx_business_glossary_term' = 'Country Full Official Name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `full_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `full_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `iso_alpha_2_code` SET TAGS ('dbx_business_glossary_term' = 'ISO (International Organization for Standardization) Alpha-2 Country Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `iso_alpha_2_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `iso_alpha_3_code` SET TAGS ('dbx_business_glossary_term' = 'ISO (International Organization for Standardization) Alpha-3 Country Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `iso_alpha_3_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `iso_numeric_code` SET TAGS ('dbx_business_glossary_term' = 'ISO (International Organization for Standardization) Numeric Country Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `iso_numeric_code` SET TAGS ('dbx_value_regex' = '^[0-9]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `naic_country_code` SET TAGS ('dbx_business_glossary_term' = 'NAIC (National Association of Insurance Commissioners) Country Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `country_name` SET TAGS ('dbx_business_glossary_term' = 'Country Official Name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `country_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `country_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `phone_country_code` SET TAGS ('dbx_business_glossary_term' = 'Telephone Country Dialing Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `phone_country_code` SET TAGS ('dbx_value_regex' = '^+[0-9]{1,4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `phone_country_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `phone_country_code` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `postal_code_format` SET TAGS ('dbx_business_glossary_term' = 'Postal Code Format Pattern');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `postal_code_format` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `postal_code_format` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `region_code` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `regulatory_jurisdiction_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Jurisdiction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `regulatory_jurisdiction_type` SET TAGS ('dbx_value_regex' = 'domestic|foreign_admitted|foreign_non_admitted|offshore');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `reinsurance_domicile_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Domicile Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `reinsurance_domicile_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `reinsurance_domicile_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `sanctions_status` SET TAGS ('dbx_business_glossary_term' = 'Economic Sanctions Status');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `sanctions_status` SET TAGS ('dbx_value_regex' = 'none|partial|comprehensive|watchlist');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `sovereignty_status` SET TAGS ('dbx_business_glossary_term' = 'Country Sovereignty Status');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `sovereignty_status` SET TAGS ('dbx_value_regex' = 'independent|dependent_territory|special_administrative_region|disputed');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`country` ALTER COLUMN `subregion_code` SET TAGS ('dbx_business_glossary_term' = 'Geographic Subregion Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` SET TAGS ('dbx_subdomain' = 'reference_catalogs');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `org_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Organizational Unit ID');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Country Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `parent_org_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Organizational Unit ID');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `address_line1` SET TAGS ('dbx_business_glossary_term' = 'Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `address_line2` SET TAGS ('dbx_business_glossary_term' = 'Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `budget_amount` SET TAGS ('dbx_business_glossary_term' = 'Budget Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'City');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4,12}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `org_unit_description` SET TAGS ('dbx_business_glossary_term' = 'Description');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `fein` SET TAGS ('dbx_business_glossary_term' = 'Federal Employer Identification Number (FEIN)');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `fein` SET TAGS ('dbx_value_regex' = '^d{2}-d{7}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `fein` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `fein` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `headcount` SET TAGS ('dbx_business_glossary_term' = 'Headcount');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `hierarchy_level` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Level');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `is_licensed` SET TAGS ('dbx_business_glossary_term' = 'Is Licensed');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `manager_email` SET TAGS ('dbx_business_glossary_term' = 'Manager Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `manager_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `manager_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `manager_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `manager_name` SET TAGS ('dbx_business_glossary_term' = 'Manager Name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `manager_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `manager_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^d{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `phone_number` SET TAGS ('dbx_business_glossary_term' = 'Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `phone_number` SET TAGS ('dbx_value_regex' = '^+?[1-9]d{1,14}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `phone_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `postal_code` SET TAGS ('dbx_value_regex' = '^d{5}(-d{4})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `profit_center_code` SET TAGS ('dbx_business_glossary_term' = 'Profit Center Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `profit_center_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4,12}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `regulatory_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Jurisdiction');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `time_zone` SET TAGS ('dbx_business_glossary_term' = 'Time Zone');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `time_zone` SET TAGS ('dbx_value_regex' = '^[A-Za-z/_]+$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `unit_code` SET TAGS ('dbx_business_glossary_term' = 'Organizational Unit Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `unit_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `unit_name` SET TAGS ('dbx_business_glossary_term' = 'Organizational Unit Name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `unit_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `unit_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `unit_status` SET TAGS ('dbx_business_glossary_term' = 'Organizational Unit Status');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `unit_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|closed|suspended');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `unit_type` SET TAGS ('dbx_business_glossary_term' = 'Organizational Unit Type');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`org_unit` ALTER COLUMN `unit_type` SET TAGS ('dbx_value_regex' = 'branch|region|division|business_unit|cost_center|profit_center');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` SET TAGS ('dbx_subdomain' = 'reference_catalogs');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code ID');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `cat_exposure_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposure Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `claims_made_basis_flag` SET TAGS ('dbx_business_glossary_term' = 'Claims Made Basis Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `commission_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Standard Commission Rate Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `lob_code_description` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Description');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `gaap_accounting_line` SET TAGS ('dbx_business_glossary_term' = 'Generally Accepted Accounting Principles (GAAP) Accounting Line');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `gaap_accounting_line` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `gaap_accounting_line` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `is_admitted` SET TAGS ('dbx_business_glossary_term' = 'Is Admitted Line Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `is_monoline` SET TAGS ('dbx_business_glossary_term' = 'Is Monoline Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `is_package_eligible` SET TAGS ('dbx_business_glossary_term' = 'Is Package Eligible Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `is_package_eligible` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `is_package_eligible` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `iso_line_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Line Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `iso_line_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,8}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `lob_abbreviation` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Abbreviation');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `lob_abbreviation` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `lob_category` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Category');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `lob_category` SET TAGS ('dbx_value_regex' = 'personal|commercial|specialty|reinsurance');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `lob_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `lob_name` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `lob_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `lob_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `lob_status` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Status');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `lob_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|discontinued');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `lob_type` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Type');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `lob_type` SET TAGS ('dbx_value_regex' = 'property|casualty|liability|auto|workers_comp|package');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `long_tail_flag` SET TAGS ('dbx_business_glossary_term' = 'Long Tail Line Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `loss_development_period_months` SET TAGS ('dbx_business_glossary_term' = 'Loss Development Period (Months)');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `naic_line_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Line Code');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `naic_line_code` SET TAGS ('dbx_value_regex' = '^[0-9]{1,3}(.[0-9]{1,2})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `regulatory_notes` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `reinsurance_ceded_pct` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Ceded Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `reinsurance_ceded_pct` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `reinsurance_ceded_pct` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `renewal_commission_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Renewal Commission Rate Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `requires_state_filing` SET TAGS ('dbx_business_glossary_term' = 'Requires State Filing Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `risk_based_capital_factor` SET TAGS ('dbx_business_glossary_term' = 'Risk-Based Capital (RBC) Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `sort_order` SET TAGS ('dbx_business_glossary_term' = 'Sort Order');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `statutory_accounting_line` SET TAGS ('dbx_business_glossary_term' = 'Statutory Accounting Line');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `statutory_accounting_line` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `statutory_accounting_line` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `target_combined_ratio_pct` SET TAGS ('dbx_business_glossary_term' = 'Target Combined Ratio (CR) Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `target_expense_ratio_pct` SET TAGS ('dbx_business_glossary_term' = 'Target Expense Ratio (ER) Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `target_loss_ratio_pct` SET TAGS ('dbx_business_glossary_term' = 'Target Loss Ratio (LR) Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `underwriting_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `underwriting_notes` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `underwriting_notes` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`lob_code` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` SET TAGS ('dbx_subdomain' = 'reference_catalogs');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `accounting_period` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `calendar_date` SET TAGS ('dbx_business_glossary_term' = 'Calendar Date');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `cat_season_indicator` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Season Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `cat_season_indicator` SET TAGS ('dbx_value_regex' = 'hurricane|wildfire|winter_storm|tornado|flood|none');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `day_name` SET TAGS ('dbx_business_glossary_term' = 'Day Name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `day_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `day_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `day_of_month` SET TAGS ('dbx_business_glossary_term' = 'Day of Month');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `day_of_week` SET TAGS ('dbx_business_glossary_term' = 'Day of Week');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `day_of_year` SET TAGS ('dbx_business_glossary_term' = 'Day of Year');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `days_in_month` SET TAGS ('dbx_business_glossary_term' = 'Days in Month');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `days_in_year` SET TAGS ('dbx_business_glossary_term' = 'Days in Year');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `fiscal_month` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Month');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `fiscal_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Period End Date');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `fiscal_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Period Start Date');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `fiscal_quarter` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Quarter');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `fiscal_week` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Week');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `holiday_name` SET TAGS ('dbx_business_glossary_term' = 'Holiday Name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `holiday_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `holiday_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `is_business_day` SET TAGS ('dbx_business_glossary_term' = 'Is Business Day Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `is_current` SET TAGS ('dbx_business_glossary_term' = 'Is Current Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `is_holiday` SET TAGS ('dbx_business_glossary_term' = 'Is Holiday Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `is_leap_year` SET TAGS ('dbx_business_glossary_term' = 'Is Leap Year Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `is_month_end` SET TAGS ('dbx_business_glossary_term' = 'Is Month End Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `is_quarter_end` SET TAGS ('dbx_business_glossary_term' = 'Is Quarter End Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `is_weekend` SET TAGS ('dbx_business_glossary_term' = 'Is Weekend Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `is_year_end` SET TAGS ('dbx_business_glossary_term' = 'Is Year End Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `month` SET TAGS ('dbx_business_glossary_term' = 'Calendar Month');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `month_name` SET TAGS ('dbx_business_glossary_term' = 'Month Name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `month_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `month_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `quarter` SET TAGS ('dbx_business_glossary_term' = 'Calendar Quarter');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `report_year` SET TAGS ('dbx_business_glossary_term' = 'Report Year');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `statutory_reporting_period` SET TAGS ('dbx_business_glossary_term' = 'Statutory Reporting Period');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `statutory_reporting_period` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `statutory_reporting_period` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `week` SET TAGS ('dbx_business_glossary_term' = 'Calendar Week');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`calendar` ALTER COLUMN `year` SET TAGS ('dbx_business_glossary_term' = 'Calendar Year');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` SET TAGS ('dbx_subdomain' = 'master_entities');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `user_account_id` SET TAGS ('dbx_business_glossary_term' = 'User Account Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `manager_user_account_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `manager_user_account_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `org_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Org Unit Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `employee_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `employee_code` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `failed_login_attempts` SET TAGS ('dbx_pii_category' = 'identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `failed_login_attempts` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `full_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `full_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `language_preference` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `language_preference` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `last_login_timestamp` SET TAGS ('dbx_pii_category' = 'identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `last_login_timestamp` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `license_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `username` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`user_account` ALTER COLUMN `username` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` SET TAGS ('dbx_subdomain' = 'master_entities');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Country Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `address_line_1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `address_line_1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `address_line_2` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `address_line_2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `commission_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `credit_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `credit_score` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `doing_business_as_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `doing_business_as_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `fax_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `fax_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `gender` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `gender` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `legal_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `legal_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `license_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `marital_status` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `marital_status` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `marital_status` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `middle_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `middle_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `mobile_phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `mobile_phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `national_producer_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `national_producer_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `occupation` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `preferred_language` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `preferred_language` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `relationship_manager_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `relationship_manager_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `risk_rating` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `risk_rating` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `risk_rating` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`shared`.`party` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_pii_identifier' = 'true');
