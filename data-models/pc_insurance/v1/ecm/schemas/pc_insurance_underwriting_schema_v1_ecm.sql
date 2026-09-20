-- Schema for Domain: underwriting | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-20 14:33:32

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_blog_v499`.`underwriting` COMMENT 'Manages the front-of-pipe lifecycle from submission intake and clearance through risk appetite screening, eligibility, risk scoring, referral management, and quote generation. Owns ACORD 125/126/140 submission data, UW decisions, and bound quotes.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` (
    `uw_guideline_id` BIGINT COMMENT 'Unique identifier for the underwriting guideline document. Primary key.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Underwriting guidelines specify cat zone restrictions (cat_zone_restrictions field exists).',
    `classification_code_id` BIGINT COMMENT 'Foreign key linking to shared.classification_code. Business justification: Underwriting guidelines specify acceptable and prohibited classification codes for risk appetite enforcement.',
    `coverage_type_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_type. Business justification: Underwriting guidelines define risk appetite, eligibility criteria, and referral triggers by coverage type.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Guidelines are state/territory-specific (state_code field exists). Geography provides the jurisdictional context for regulatory compliance and territory-based underwriting',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Underwriting guidelines are established per line of business for risk appetite and eligibility rules.',
    `approval_date` DATE COMMENT 'Date when this guideline version was formally approved for use.',
    `approved_by` STRING COMMENT 'Name or identifier of the underwriting authority or executive who approved this guideline version.',
    `cat_zone_restrictions` STRING COMMENT 'List of catastrophe zones, flood zones, or high-hazard territories where coverage is restricted or requires special approval under this guideline.',
    `class_restrictions` STRING COMMENT 'List of restricted or prohibited risk classes, SIC codes, NAICS codes, or business types that are ineligible under this guideline.',
    `clue_required_flag` BOOLEAN COMMENT 'Indicates whether a CLUE report is required to assess prior loss history under this guideline.',
    `coverage_limits_max` DECIMAL(18,2) COMMENT 'Maximum allowable coverage limit amount for policies underwritten under this guideline.',
    `coverage_limits_min` DECIMAL(18,2) COMMENT 'Minimum allowable coverage limit amount for policies underwritten under this guideline.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this guideline record was first created in the system.',
    `credit_score_min_threshold` BIGINT COMMENT 'Minimum acceptable credit score for eligibility under this guideline. Null if no threshold applies.',
    `credit_score_required_flag` BOOLEAN COMMENT 'Indicates whether a credit-based insurance score is required for underwriting under this guideline.',
    `declination_reasons` STRING COMMENT 'Documented reasons for automatic declination or rejection of submissions that fail to meet guideline criteria.',
    `deductible_max` DECIMAL(18,2) COMMENT 'Maximum deductible amount allowed for policies under this guideline.',
    `deductible_min` DECIMAL(18,2) COMMENT 'Minimum deductible amount required for policies under this guideline.',
    `document_url` STRING COMMENT 'URL or file path to the full guideline document stored in the document management system.',
    `effective_date` DATE COMMENT 'Date when this guideline version becomes active and enforceable for underwriting decisions.',
    `eligibility_criteria` STRING COMMENT 'Detailed eligibility requirements including acceptable risk classes, occupancy types, construction standards, and other qualifying factors.',
    `expiration_date` DATE COMMENT 'Date when this guideline version ceases to be active. Null indicates open-ended guideline.',
    `guideline_code` STRING COMMENT 'Business identifier code for the underwriting guideline, used for external reference and system integration.. Valid values are `^[A-Z0-9]{6,20}$`',
    `guideline_name` STRING COMMENT 'Descriptive name of the underwriting guideline document.',
    `guideline_type` STRING COMMENT 'Classification of the guideline purpose: risk appetite, eligibility screening, pricing constraints, coverage requirements, referral rules, or declination criteria.. Valid values are `risk_appetite|eligibility|pricing|coverage|referral|declination`',
    `inspection_required_flag` BOOLEAN COMMENT 'Indicates whether a physical property or risk inspection is mandatory before binding under this guideline.',
    `loss_history_years` BIGINT COMMENT 'Number of years of prior loss history required for underwriting evaluation under this guideline.',
    `mandatory_endorsements` STRING COMMENT 'Required policy endorsements, forms, or coverage modifications that must be attached when this guideline applies.',
    `max_prior_claims_allowed` BIGINT COMMENT 'Maximum number of prior claims permitted within the loss history period for eligibility under this guideline.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this guideline record was last modified.',
    `mvr_required_flag` BOOLEAN COMMENT 'Indicates whether a motor vehicle record check is required for auto line underwriting under this guideline.',
    `notes` STRING COMMENT 'Additional notes, clarifications, or special instructions related to the application of this guideline.',
    `pricing_constraints` STRING COMMENT 'Pricing rules, rate caps, minimum premiums, and other actuarial constraints that apply to quotes generated under this guideline.',
    `referral_triggers` STRING COMMENT 'Conditions or thresholds that require underwriter referral or senior approval before binding, such as high TIV, adverse loss history, or non-standard risks.',
    `regulatory_filing_reference` STRING COMMENT 'Reference number or identifier for any state DOI filing or regulatory approval associated with this guideline.',
    `risk_appetite_description` STRING COMMENT 'Narrative description of acceptable risk criteria, target customer segments, and strategic underwriting objectives for this guideline.',
    `state_code` STRING COMMENT 'Two-letter US state code where this guideline is applicable for regulatory compliance.. Valid values are `^[A-Z]{2}$`',
    `tiv_max` DECIMAL(18,2) COMMENT 'Maximum total insured value allowed for property risks under this guideline without senior underwriter approval.',
    `tiv_min` DECIMAL(18,2) COMMENT 'Minimum total insured value required for property risks under this guideline.',
    `uw_guideline_status` STRING COMMENT 'Current lifecycle status of the guideline document.. Valid values are `draft|pending_approval|active|superseded|retired`',
    `version_number` STRING COMMENT 'Version identifier for the guideline document, supporting audit and change tracking.. Valid values are `^[0-9]+.[0-9]+$`',
    CONSTRAINT pk_uw_guideline PRIMARY KEY(`uw_guideline_id`)
) COMMENT 'Underwriting guideline document defining acceptable risk criteria, class restrictions, mandatory endorsements, and pricing constraints by LOB and state. Versioned and effective-dated for audit.';

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`underwriting` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`underwriting` SET TAGS ('dbx_domain' = 'underwriting');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `uw_guideline_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Guideline ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `uw_guideline_id` SET TAGS ('dbx_subdomain' = 'underwriting.uw_guideline');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `classification_code_id` SET TAGS ('dbx_business_glossary_term' = 'Classification Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `coverage_type_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `cat_zone_restrictions` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone Restrictions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `class_restrictions` SET TAGS ('dbx_business_glossary_term' = 'Class Restrictions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `clue_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Loss Underwriting Exchange (CLUE) Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `coverage_limits_max` SET TAGS ('dbx_business_glossary_term' = 'Maximum Coverage Limits');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `coverage_limits_min` SET TAGS ('dbx_business_glossary_term' = 'Minimum Coverage Limits');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `credit_score_min_threshold` SET TAGS ('dbx_business_glossary_term' = 'Minimum Credit Score Threshold');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `credit_score_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Credit Score Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `declination_reasons` SET TAGS ('dbx_business_glossary_term' = 'Declination Reasons');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `deductible_max` SET TAGS ('dbx_business_glossary_term' = 'Maximum Deductible');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `deductible_min` SET TAGS ('dbx_business_glossary_term' = 'Minimum Deductible');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `document_url` SET TAGS ('dbx_business_glossary_term' = 'Document Uniform Resource Locator (URL)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `eligibility_criteria` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Criteria');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `guideline_code` SET TAGS ('dbx_business_glossary_term' = 'Guideline Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `guideline_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{6,20}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `guideline_name` SET TAGS ('dbx_business_glossary_term' = 'Guideline Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `guideline_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `guideline_type` SET TAGS ('dbx_business_glossary_term' = 'Guideline Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `guideline_type` SET TAGS ('dbx_value_regex' = 'risk_appetite|eligibility|pricing|coverage|referral|declination');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `inspection_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Inspection Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `loss_history_years` SET TAGS ('dbx_business_glossary_term' = 'Loss History Years');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `mandatory_endorsements` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Endorsements');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `max_prior_claims_allowed` SET TAGS ('dbx_business_glossary_term' = 'Maximum Prior Claims Allowed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `mvr_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `pricing_constraints` SET TAGS ('dbx_business_glossary_term' = 'Pricing Constraints');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `referral_triggers` SET TAGS ('dbx_business_glossary_term' = 'Referral Triggers');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `regulatory_filing_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `risk_appetite_description` SET TAGS ('dbx_business_glossary_term' = 'Risk Appetite Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `tiv_max` SET TAGS ('dbx_business_glossary_term' = 'Maximum Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `tiv_min` SET TAGS ('dbx_business_glossary_term' = 'Minimum Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `uw_guideline_status` SET TAGS ('dbx_business_glossary_term' = 'Guideline Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `uw_guideline_status` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|active|superseded|retired');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');
