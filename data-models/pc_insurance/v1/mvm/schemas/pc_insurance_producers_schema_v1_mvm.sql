-- Schema for Domain: producers | Business: Pc_Insurance | Version: v1_mvm
-- Generated on: 2026-09-20 21:40:52

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_blog_v499`.`producers` COMMENT 'Provisional description for user-specified domain producers. Awaiting a generated description of what this domain owns.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` (
    `producers_producer_id` BIGINT COMMENT 'Unique surrogate identifier for each licensed insurance producer record. Primary key. One row per producer.',
    `distribution_channel_id` BIGINT COMMENT 'Reference to the distribution channel through which this producer operates (e.g., independent agent, direct, broker, MGA).',
    `party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Every producer is a party in the master registry. Links producer identity to KYC/OFAC screening, fraud indicators, license verification, contact management, and regulatory reporting.',
    `territory_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.territory. Business justification: Territory-level production tracking and binding authority validation require knowing which rating territory a producer is authorized for.',
    `appointment_effective_date` DATE COMMENT 'Date the producers appointment with Pc_Insurance became effective. Marks the start of the producers authority to bind business.',
    `appointment_status` STRING COMMENT 'Current appointment status of the producer with the insurer. Drives eligibility to bind business. Lifecycle: pending -> active -> suspended/terminated.. Valid values are `active|inactive|terminated|pending|suspended`',
    `appointment_termination_date` DATE COMMENT 'Date the producers appointment with Pc_Insurance was terminated. Null if appointment is currently active.',
    `background_check_date` DATE COMMENT 'Date the most recent background check was completed. Used to determine if a refresh is required per appointment policy.',
    `background_check_status` STRING COMMENT 'Status of the most recent background check conducted on the producer as part of the appointment process.. Valid values are `passed|failed|pending|waived`',
    `bank_account_reference` STRING COMMENT 'Tokenized or masked reference to the producers bank account used for ACH commission disbursements. Full account data stored in payment vault.',
    `binding_authority_flag` BOOLEAN COMMENT 'Indicates whether the producer has delegated binding authority to issue policies on behalf of Pc_Insurance without prior underwriting approval.',
    `binding_authority_limit` DECIMAL(18,2) COMMENT 'Maximum single-risk premium or TIV the producer may bind without referral to underwriting. Null if binding_authority_flag is false.',
    `commission_schedule_code` STRING COMMENT 'Code identifying the commission schedule applicable to this producer. Drives commission calculation on premium transactions.',
    `contingent_commission_eligible` BOOLEAN COMMENT 'Indicates whether the producer is eligible for contingent (profit-sharing) commission based on loss ratio and volume performance.',
    `continuing_education_due_date` DATE COMMENT 'Date by which the producer must complete state-mandated continuing education (CE) credits to maintain licensure.',
    `continuing_education_hours_completed` DECIMAL(5,1) COMMENT 'Number of continuing education credit hours completed in the current CE cycle. Tracked against state-mandated minimums.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the producer record was first created in the Producer/Agency Management System. Audit trail field.',
    `default_commission_rate` DECIMAL(7,4) COMMENT 'Default commission rate (as a decimal, e.g., 0.1200 = 12%) applied to written premium for this producer absent a line-specific override.',
    `eo_carrier_name` STRING COMMENT 'Name of the insurance carrier providing the producers Errors & Omissions (E&O) professional liability coverage.',
    `eo_coverage_amount` DECIMAL(18,2) COMMENT 'Per-occurrence limit of the producers E&O professional liability policy in USD. Used to verify minimum coverage requirements.',
    `eo_expiration_date` DATE COMMENT 'Expiration date of the producers E&O professional liability policy. Triggers renewal reminder and potential appointment suspension.',
    `eo_policy_number` STRING COMMENT 'Policy number of the producers E&O professional liability insurance. Required for appointment and renewal.',
    `is_surplus_lines_licensed` BOOLEAN COMMENT 'Indicates whether the producer holds a surplus lines broker license, enabling placement of non-admitted coverage.',
    `license_class` STRING COMMENT 'Class or type of insurance license held (e.g., Property & Casualty, Life & Health, Personal Lines). Determines lines of business the producer may sell. [ENUM-REF-CANDIDATE: property_casualty|life_health|personal_lines|commercial_lines|surplus_lines —',
    `license_effective_date` DATE COMMENT 'Date the producers resident state license became effective. Used to verify active licensure at time of policy binding.',
    `license_expiration_date` DATE COMMENT 'Date the producers resident state license expires. Triggers renewal workflow and appointment suspension if not renewed.',
    `license_number` STRING COMMENT 'Primary state-issued insurance producer license number in the resident state. Additional non-resident licenses are tracked in the Producer Appointment table.',
    `lob_authorizations` STRING COMMENT 'Comma-delimited list of lines of business (LOB) codes the producer is authorized to write (e.g., HO, PAP, CGL, BOP, CA). Enforced at submission intake.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC code of the insurer entity appointing this producer. Used in Schedule F and state appointment filings.. Valid values are `^[0-9]{5}$`',
    `npn` STRING COMMENT 'NIPR-assigned National Producer Number uniquely identifying the producer across all US states. Used for license validation and regulatory reporting.. Valid values are `^[0-9]{1,10}$`',
    `payment_method` STRING COMMENT 'Method by which commission payments are disbursed to the producer (ACH direct deposit, paper check, or wire transfer).. Valid values are `ach|check|wire`',
    `producer_role` STRING COMMENT 'Functional role of the producer in the distribution channel. [ENUM-REF-CANDIDATE: agent|broker|managing_general_agent|surplus_lines_broker|independent_agent|captive_agent — promote to reference product]. Valid values are `agent|broker|managing_general_agent|surplus_lines_broker|independent_agent|captive_agent`',
    `producer_type` STRING COMMENT 'Indicates whether the producer is a natural person (individual) or a business entity (agency/firm). Drives licensing and appointment rules.. Valid values are `individual|entity`',
    `regulatory_action_flag` BOOLEAN COMMENT 'Indicates whether the producer has any open or historical regulatory actions, fines, or license sanctions on record.',
    `resident_state_code` STRING COMMENT 'Two-letter US state code of the producers resident (home) state for licensing purposes. Determines reciprocal licensing eligibility.. Valid values are `^[A-Z]{2}$`',
    `since_date` DATE COMMENT 'Date the producer first became appointed with Pc_Insurance. Used for tenure-based commission tier calculations and relationship analytics.',
    `surplus_lines_license_number` STRING COMMENT 'State-issued surplus lines broker license number. Null if producer is not surplus lines licensed.',
    `tax_identification_number` STRING COMMENT 'Federal Employer Identification Number (FEIN) for entity producers or Social Security Number (SSN) for individual producers. Used for IRS 1099 commission reporting.',
    `termination_reason` STRING COMMENT 'Reason code for appointment termination. Required for state DOI termination filings. Null if appointment is active.. Valid values are `voluntary|non_renewal|cause|regulatory|deceased|other`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the producer record was most recently modified. Used for change data capture and audit trail.',
    `w9_on_file` BOOLEAN COMMENT 'Indicates whether a valid IRS Form W-9 (or W-8 for foreign producers) is on file. Required before commission disbursement.',
    `writing_company_code` STRING COMMENT 'NAIC company code of the Pc_Insurance legal entity (writing company) to which this producer is appointed. Supports multi-company insurer groups.',
    CONSTRAINT pk_producers_producer PRIMARY KEY(`producers_producer_id`)
) COMMENT 'Master record for every licensed insurance producer (agent or broker). One row per producer. Stores NPN, license numbers, resident state, producer type, appointment status, and E&O coverage details.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` (
    `agency_id` BIGINT COMMENT 'Unique identifier for the insurance agency or brokerage firm. Primary key.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Agency-level premium volume reporting and binding authority limits are currency-denominated.',
    `distribution_channel_id` BIGINT COMMENT 'Foreign key linking to producers.distribution_channel. Business justification: Agencies operate through a specific distribution channel (captive, independent, broker, direct). Replace STRING distribution_channel_code with FK. N:1 relationship.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Agencies are assigned service territories defined in geography hierarchy. Used for producer appointment validation (ensuring producer is appointed in geography where risk is',
    `parent_agency_id` BIGINT COMMENT 'Reference to the parent agency for hierarchical relationships such as MGA to sub-producer or wholesale to retail agency networks.',
    `party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Every agency is a legal entity in party registry. Links agency to organizational KYC, FEIN/NAIC validation, address standardization, OFAC screening, and consolidated party view.',
    `principal_address_id` BIGINT COMMENT 'Foreign key linking to party.address. Business justification: Agency principal address drives geocoding, cat zone assignment, and state DOI regulatory address verification for agency licensing.',
    `territory_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.territory. Business justification: Agency book-of-business analysis, market conduct exams, and territory-level production reports require agencies to be linked to their primary operating territory.',
    `agency_status` STRING COMMENT 'Current lifecycle status of the agency relationship with the carrier: active, inactive, suspended, terminated, or pending appointment.. Valid values are `active|inactive|suspended|terminated|pending_appointment`',
    `agency_type` STRING COMMENT 'Classification of the agency business model: independent agent, captive agent, managing general agent (MGA), wholesale broker, retail broker, surplus lines broker, or direct writer.',
    `annual_premium_volume` DECIMAL(15,2) COMMENT 'Total annual written premium volume produced by the agency across all lines of business for the most recent calendar year.',
    `appointment_effective_date` DATE COMMENT 'Date when the agency appointment with the carrier became effective and the agency was authorized to bind business.',
    `appointment_termination_date` DATE COMMENT 'Date when the agency appointment with the carrier was terminated or expired, ending binding authority.',
    `binding_authority_flag` BOOLEAN COMMENT 'Indicates whether the agency has binding authority to issue policies on behalf of the carrier without prior underwriting approval.',
    `binding_authority_limit` DECIMAL(15,2) COMMENT 'Maximum total insured value or premium amount the agency is authorized to bind without carrier underwriting review.',
    `commission_schedule_code` STRING COMMENT 'Reference code to the commission rate schedule applicable to this agency for new business, renewals, and endorsements by line of business.',
    `contingent_commission_eligible` BOOLEAN COMMENT 'Indicates whether the agency is eligible for contingent or profit-sharing commission based on loss ratio and volume performance.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the agency record was first created in the system capturing the initial appointment or onboarding event.',
    `default_commission_rate` DECIMAL(5,4) COMMENT 'Default commission rate as a decimal percentage applied to written premium when no line-specific rate is defined in the commission schedule.',
    `eo_carrier_name` STRING COMMENT 'Name of the insurance carrier providing errors and omissions professional liability coverage for the agency.',
    `eo_coverage_amount` DECIMAL(15,2) COMMENT 'Total coverage limit amount for the agency errors and omissions professional liability insurance policy.',
    `eo_expiration_date` DATE COMMENT 'Expiration date of the agency errors and omissions professional liability insurance policy requiring renewal for continued appointment.',
    `eo_policy_number` STRING COMMENT 'Policy number for the agency errors and omissions professional liability insurance coverage required for appointment.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the agency record was most recently updated reflecting changes to appointment status, contact information, or authorization.',
    `lob_authorizations` STRING COMMENT 'Comma-separated list of lines of business the agency is authorized to write: personal auto, homeowners, commercial property, general liability, workers compensation, etc.',
    `mailing_address_same_as_principal` BOOLEAN COMMENT 'Indicates whether the mailing address is identical to the principal business address for correspondence and regulatory notices.',
    `policy_count` BIGINT COMMENT 'Total number of active policies in force written by the agency as of the most recent reporting period.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which the agency data originated: producer management system, policy administration system, or agency portal.',
    `surplus_lines_eligible` BOOLEAN COMMENT 'Indicates whether the agency is licensed and authorized to place surplus lines business with non-admitted carriers.',
    `surplus_lines_license_number` STRING COMMENT 'State-issued surplus lines broker license number authorizing the agency to place business with non-admitted carriers.',
    `termination_reason_code` STRING COMMENT 'Standardized code indicating the reason for agency appointment termination: voluntary, involuntary, non-renewal, regulatory action, merger, or acquisition.. Valid values are `voluntary|involuntary|non_renewal|regulatory|merger|acquisition`',
    `tier` STRING COMMENT 'Performance tier classification based on premium volume, loss ratio, and retention metrics used for contingent commission and incentive programs.. Valid values are `platinum|gold|silver|bronze|standard`',
    `writing_company_code` STRING COMMENT 'Internal carrier code identifying the specific insurance company entity the agency is appointed to represent for policy issuance.',
    CONSTRAINT pk_agency PRIMARY KEY(`agency_id`)
) COMMENT 'Master record for an insurance agency or brokerage firm. One row per agency. Captures agency name, FEIN, NAIC code, principal address, agency type, and parent agency hierarchy for MGA and wholesale relationships.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` (
    `producer_license_id` BIGINT COMMENT 'Unique identifier for the producer license record. Primary key. One row per producer per state per license class.',
    `license_id` BIGINT COMMENT 'Foreign key linking to party.license. Business justification: Regulatory compliance (NIPR reconciliation, DOI filings) requires linking producer-specific appointment licenses to the canonical party license record.',
    `party_id` BIGINT COMMENT 'Reference to the party master record for this producer.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer who holds this license.',
    `application_date` DATE COMMENT 'Date the producer submitted the license application to the state Department of Insurance.',
    `appointment_required` BOOLEAN COMMENT 'Indicates whether the state requires a carrier appointment for this license class.',
    `approval_date` DATE COMMENT 'Date the license application was approved by the state Department of Insurance.',
    `background_check_date` DATE COMMENT 'Date the most recent background check was completed for this license.',
    `background_check_required` BOOLEAN COMMENT 'Indicates whether the state requires a background check for this license.',
    `background_check_status` STRING COMMENT 'Status of the background check: passed, failed, pending, not required, or expired.. Valid values are `passed|failed|pending|not_required|expired`',
    `ce_due_date` DATE COMMENT 'Date by which continuing education requirements must be completed for renewal.',
    `ce_ethics_hours_required` DECIMAL(5,2) COMMENT 'Ethics-specific continuing education hours required for license renewal in this state.',
    `ce_hours_completed` DECIMAL(5,2) COMMENT 'Total continuing education hours completed toward current renewal cycle.',
    `ce_hours_required` DECIMAL(5,2) COMMENT 'Total continuing education hours required for license renewal in this state.',
    `denial_date` DATE COMMENT 'Date the license application was denied by the state Department of Insurance.',
    `denial_reason` STRING COMMENT 'Reason provided by the state Department of Insurance for denying the license application.',
    `doi_action_date` DATE COMMENT 'Date the regulatory action was taken by the state Department of Insurance.',
    `doi_action_description` STRING COMMENT 'Detailed description of the regulatory action taken by the state Department of Insurance.',
    `doi_action_flag` BOOLEAN COMMENT 'Indicates whether any regulatory action has been taken against this license by the state DOI.',
    `doi_action_type` STRING COMMENT 'Type of regulatory action taken: suspension, revocation, fine, probation, consent order, or cease and desist.. Valid values are `suspension|revocation|fine|probation|consent_order|cease_and_desist`',
    `effective_date` DATE COMMENT 'Date the license becomes active and the producer is authorized to transact insurance business.',
    `expiration_date` DATE COMMENT 'Date the license expires and must be renewed to remain valid.',
    `fingerprint_date` DATE COMMENT 'Date fingerprints were submitted to the state Department of Insurance.',
    `fingerprint_required` BOOLEAN COMMENT 'Indicates whether the state requires fingerprinting for this license.',
    `issue_date` DATE COMMENT 'Date the license was originally issued by the state Department of Insurance.',
    `license_class` STRING COMMENT 'Classification of the license: resident, non-resident, temporary, surplus lines, adjuster, or public adjuster.. Valid values are `resident|non-resident|temporary|surplus_lines|adjuster|public_adjuster`',
    `license_state_code` STRING COMMENT 'Two-letter state code where the license is issued. Resident or non-resident state.. Valid values are `^[A-Z]{2}$`',
    `license_status` STRING COMMENT 'Current status of the license with the state Department of Insurance. [ENUM-REF-CANDIDATE: active|inactive|expired|suspended|revoked|pending|denied — 7 candidates stripped; promote to reference product]',
    `license_type` STRING COMMENT 'Type of licensee: individual producer, business entity, or agency.. Valid values are `individual|business_entity|agency`',
    `loa_casualty` BOOLEAN COMMENT 'Indicates whether the license includes authority to sell casualty insurance lines.',
    `loa_health` BOOLEAN COMMENT 'Indicates whether the license includes authority to sell health insurance products.',
    `loa_life` BOOLEAN COMMENT 'Indicates whether the license includes authority to sell life insurance products.',
    `loa_personal_lines` BOOLEAN COMMENT 'Indicates whether the license includes authority to sell personal lines insurance.',
    `loa_property` BOOLEAN COMMENT 'Indicates whether the license includes authority to sell property insurance lines.',
    `loa_variable_annuity` BOOLEAN COMMENT 'Indicates whether the license includes authority to sell variable annuity products.',
    `nipr_transaction_number` STRING COMMENT 'Transaction identifier from NIPR for license application, renewal, or update.',
    `npn` STRING COMMENT 'National Producer Number assigned by NIPR. Unique federal identifier for licensed insurance producers.. Valid values are `^[0-9]{8,10}$`',
    `reciprocity_state_code` STRING COMMENT 'Two-letter state code of the resident state if this is a non-resident license granted through reciprocity.. Valid values are `^[A-Z]{2}$`',
    `renewal_date` DATE COMMENT 'Date the license was last renewed with the state Department of Insurance.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record for this license record.',
    `source_system_reference_code` STRING COMMENT 'Unique identifier for this license record in the source operational system.',
    `surplus_lines_eligible` BOOLEAN COMMENT 'Indicates whether the producer is eligible to place surplus lines business in this state.',
    `termination_date` DATE COMMENT 'Date the license was terminated, either voluntarily or by regulatory action.',
    `termination_reason` STRING COMMENT 'Reason for license termination: voluntary, non-renewal, regulatory action, death, retirement, or business closure.. Valid values are `voluntary|non_renewal|regulatory_action|death|retirement|business_closure`',
    CONSTRAINT pk_producer_license PRIMARY KEY(`producer_license_id`)
) COMMENT 'Individual state license held by a producer. One row per producer per state per license class. Tracks license number, line of authority, issue date, expiration date, and DOI status for compliance and appointment eligibility.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` (
    `agency_producer_id` BIGINT COMMENT 'Unique identifier for the agency-producer relationship record. Primary key.',
    `agency_id` BIGINT COMMENT 'Foreign key to the agency in this producer relationship.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: The producer-agency affiliation relationship defines the commission schedule for that specific employment/contractor arrangement.',
    `party_id` BIGINT COMMENT 'Foreign key to the party master record for the producer.',
    `primary_agency_producers_producer_id` BIGINT COMMENT 'Foreign key to the producer in this agency relationship.',
    `annual_production_target` DECIMAL(15,2) COMMENT 'Annual written premium production target assigned to the producer through this agency.',
    `appointment_effective_date` DATE COMMENT 'Date when the carrier appointment became effective for this producer-agency pairing.',
    `appointment_status` STRING COMMENT 'Status of the producers appointment with the carrier through this agency.. Valid values are `appointed|pending|denied|terminated|suspended`',
    `appointment_termination_date` DATE COMMENT 'Date when the carrier appointment was terminated for this producer-agency pairing.',
    `binding_authority_flag` BOOLEAN COMMENT 'Indicates whether the producer has authority to bind coverage on behalf of the carrier through this agency.',
    `binding_authority_limit` DECIMAL(15,2) COMMENT 'Maximum premium or coverage amount the producer can bind without referral through this agency.',
    `book_of_business_ownership` STRING COMMENT 'Indicates who owns the book of business generated by the producer through this agency.. Valid values are `producer|agency|shared|carrier`',
    `commission_split_percentage` DECIMAL(5,2) COMMENT 'Percentage of commission allocated to the producer in split arrangements with the agency.',
    `contingent_commission_eligible` BOOLEAN COMMENT 'Indicates whether the producer is eligible for contingent or bonus commission through this agency.',
    `contract_document_reference` STRING COMMENT 'Reference identifier or URI to the producer-agency contract or agreement document.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this agency-producer relationship record was first created in the system.',
    `default_commission_rate` DECIMAL(5,4) COMMENT 'Default commission percentage rate for this producer-agency pairing, expressed as decimal.',
    `desk_location` STRING COMMENT 'Physical desk or office location identifier within the agency premises.',
    `effective_date` DATE COMMENT 'Date when the producer-agency relationship became effective.',
    `eo_coverage_required` BOOLEAN COMMENT 'Indicates whether E&O insurance coverage is required for this producer-agency relationship.',
    `eo_coverage_verified_date` DATE COMMENT 'Date when E&O insurance coverage was last verified for this producer-agency pairing.',
    `expiration_date` DATE COMMENT 'Date when the producer-agency relationship ended or is scheduled to end. Null for open-ended relationships.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this agency-producer relationship record was last updated.',
    `lob_authorizations` STRING COMMENT 'Comma-separated list of LOB codes the producer is authorized to write through this agency.',
    `non_compete_clause_flag` BOOLEAN COMMENT 'Indicates whether a non-compete clause exists in the producer-agency agreement.',
    `non_compete_expiration_date` DATE COMMENT 'Date when the non-compete obligation expires after relationship termination.',
    `notes` STRING COMMENT 'Free-form text notes or comments about this producer-agency relationship.',
    `performance_tier` STRING COMMENT 'Performance classification or tier assigned to the producer within the agency structure.',
    `primary_agency_flag` BOOLEAN COMMENT 'Indicates whether this is the producers primary or home agency affiliation.',
    `record_version_number` BIGINT COMMENT 'Version number tracking changes to this relationship record for audit and concurrency control.',
    `relationship_status` STRING COMMENT 'Current status of the producer-agency relationship.. Valid values are `active|inactive|suspended|terminated|pending`',
    `relationship_type` STRING COMMENT 'Type of employment or affiliation relationship between producer and agency.. Valid values are `employee|independent_contractor|sub_agent|captive_agent|general_agent|managing_general_agent`',
    `source_system_code` STRING COMMENT 'Code identifying the source system that created or manages this agency-producer relationship record.',
    `source_system_reference_code` STRING COMMENT 'Unique identifier for this relationship record in the source system.',
    `termination_date` DATE COMMENT 'Actual date the relationship was terminated if ended before expiration.',
    `termination_reason_code` STRING COMMENT 'Standardized code indicating the reason for relationship termination.. Valid values are `voluntary_resignation|involuntary_termination|retirement|license_revocation|contract_expiration|performance`',
    `termination_reason_description` STRING COMMENT 'Detailed narrative explanation of the termination reason.',
    `territory_code` STRING COMMENT 'Geographic territory or region assigned to the producer within this agency.',
    `writing_authority_level` STRING COMMENT 'Level of underwriting and binding authority granted to the producer within this agency.. Valid values are `full|limited|referral_only|none`',
    CONSTRAINT pk_agency_producer PRIMARY KEY(`agency_producer_id`)
) COMMENT 'Association between a producer and an agency capturing the employment or affiliation relationship. One row per producer-agency pairing. Stores role, start date, end date, and primary-agency flag.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` (
    `producer_appointment_id` BIGINT COMMENT 'Unique identifier for the producer appointment record. Primary key.',
    `agency_id` BIGINT COMMENT 'Reference to the agency through which the producer is appointed.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: Appointments define the commission schedule that applies to the producer for that LOB/state/company combination. Replace STRING commission_schedule_code with FK.',
    `distribution_channel_id` BIGINT COMMENT 'Foreign key linking to producers.distribution_channel. Business justification: Appointments are made through a specific distribution channel. Replace STRING distribution_channel_code with FK to distribution_channel. N:1 relationship.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Appointments are granted by LOB per state regulatory requirements and carrier underwriting guidelines.',
    `party_id` BIGINT COMMENT 'Reference to the party record representing the producer.',
    `prior_appointment_producer_appointment_id` BIGINT COMMENT 'Reference to the previous appointment record if this is a renewal or replacement.',
    `producer_license_id` BIGINT COMMENT 'Foreign key linking to producers.producer_license. Business justification: Appointments are granted based on a valid license in that state and LOB. Links the appointment to the underlying license that authorizes the producer to sell. N:1 relationship.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer who holds this appointment.',
    `territory_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.territory. Business justification: Producer appointments are validated against territory-level binding authority limits and rate filings.',
    `appointment_agreement_date` DATE COMMENT 'Date when the appointment agreement was signed by both parties.',
    `appointment_agreement_number` STRING COMMENT 'Reference number of the legal contract governing this appointment.',
    `appointment_number` STRING COMMENT 'Unique business identifier for this appointment issued by the insurer or state DOI.',
    `appointment_source` STRING COMMENT 'Origin or method by which the producer appointment was established.. Valid values are `direct_hire|agency_transfer|acquisition|reciprocity|new_market_entry`',
    `appointment_state_code` STRING COMMENT 'Two-letter state code where the appointment is granted and registered.. Valid values are `^[A-Z]{2}$`',
    `appointment_status` STRING COMMENT 'Current lifecycle status of the producer appointment.. Valid values are `active|pending|suspended|terminated|expired|inactive`',
    `appointment_tier` STRING COMMENT 'Performance or volume tier assigned to the producer for this appointment.. Valid values are `platinum|gold|silver|bronze|standard`',
    `appointment_type` STRING COMMENT 'Classification of the appointment relationship between producer and insurer.. Valid values are `direct|sub_producer|managing_general_agent|surplus_lines|reinsurance_intermediary`',
    `binding_authority_flag` BOOLEAN COMMENT 'Indicates whether the producer has authority to bind coverage on behalf of the insurer.',
    `binding_authority_limit` DECIMAL(15,2) COMMENT 'Maximum policy limit or premium amount the producer can bind without underwriter approval.',
    `contingent_commission_eligible` BOOLEAN COMMENT 'Indicates whether the producer is eligible for contingent or profit-sharing commission.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this appointment record was first created in the system.',
    `default_commission_rate` DECIMAL(5,4) COMMENT 'Standard commission rate as a decimal percentage for policies written under this appointment.',
    `doi_reported_date` DATE COMMENT 'Date when the appointment was reported to the state Department of Insurance.',
    `effective_date` DATE COMMENT 'Date when the producer appointment becomes active and binding authority begins.',
    `eo_insurance_required_flag` BOOLEAN COMMENT 'Indicates whether the producer must maintain E&O insurance as a condition of appointment.',
    `eo_minimum_coverage_amount` DECIMAL(15,2) COMMENT 'Minimum E&O insurance coverage amount required to maintain the appointment.',
    `expiration_date` DATE COMMENT 'Date when the producer appointment expires or is scheduled to end.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this appointment record was last updated.',
    `lob_category` STRING COMMENT 'High-level category grouping the line of business.. Valid values are `personal_lines|commercial_lines|specialty_lines|life_health`',
    `lob_description` STRING COMMENT 'Full description of the line of business authorized under this appointment.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC code identifying the insurer granting the appointment.. Valid values are `^[0-9]{5}$`',
    `nipr_transaction_number` STRING COMMENT 'Unique transaction identifier assigned by NIPR for this appointment filing.',
    `npn` STRING COMMENT 'Ten-digit unique identifier assigned by NIPR to licensed insurance producers.. Valid values are `^[0-9]{10}$`',
    `regulatory_reporting_required` BOOLEAN COMMENT 'Indicates whether this appointment must be reported to state DOI or NIPR.',
    `renewal_flag` BOOLEAN COMMENT 'Indicates whether this appointment is a renewal of a prior appointment.',
    `resident_state_code` STRING COMMENT 'Two-letter code of the state where the producer holds resident license.. Valid values are `^[A-Z]{2}$`',
    `source_system_code` STRING COMMENT 'Code identifying the operational system from which this appointment record originated.',
    `source_system_reference_code` STRING COMMENT 'Primary key or unique identifier of this appointment in the source system.',
    `surplus_lines_flag` BOOLEAN COMMENT 'Indicates whether this appointment authorizes surplus lines business placement.',
    `surplus_lines_license_number` STRING COMMENT 'License number issued by the state for surplus lines authority.',
    `termination_date` DATE COMMENT 'Actual date when the appointment was terminated before its scheduled expiration.',
    `termination_for_cause_flag` BOOLEAN COMMENT 'Indicates whether the appointment was terminated for cause requiring regulatory reporting.',
    `termination_reason_code` STRING COMMENT 'Standardized code indicating the reason for appointment termination.. Valid values are `voluntary|for_cause|license_revoked|non_renewal|business_closure|regulatory_action`',
    `termination_reason_description` STRING COMMENT 'Detailed explanation of the reason for appointment termination.',
    `writing_company_code` STRING COMMENT 'Internal code identifying the insurance company granting the appointment.',
    CONSTRAINT pk_producer_appointment PRIMARY KEY(`producer_appointment_id`)
) COMMENT 'Formal appointment and binding authority granted by the insurer to a producer to sell specific lines in a state. One row per producer per insurer per state per LOB.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` (
    `distribution_channel_id` BIGINT COMMENT 'Unique identifier for the distribution channel. Primary key.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Distribution channels are configured with LOB authorizations for market segmentation and channel conflict management.',
    `agency_bill_flag` BOOLEAN COMMENT 'Indicates whether policies written through this channel use agency bill arrangements where the producer collects premium and remits to the insurer.',
    `appointment_required` BOOLEAN COMMENT 'Indicates whether producers must be formally appointed by the insurer to write business through this channel.',
    `background_check_required` BOOLEAN COMMENT 'Indicates whether producers must pass a background check before being authorized to write business through this channel.',
    `binding_authority_flag` BOOLEAN COMMENT 'Indicates whether producers in this channel have authority to bind coverage on behalf of the insurer without prior underwriting approval.',
    `binding_authority_limit` DECIMAL(15,2) COMMENT 'Maximum policy premium or total insured value that producers in this channel may bind without referral to underwriting.',
    `channel_code` STRING COMMENT 'Short alphanumeric code uniquely identifying the channel type for system integration and reporting.. Valid values are `^[A-Z0-9_]{2,10}$`',
    `channel_description` STRING COMMENT 'Detailed narrative describing the purpose, structure, and operational characteristics of this distribution channel.',
    `channel_name` STRING COMMENT 'Full business name of the distribution channel.',
    `channel_priority_rank` BIGINT COMMENT 'Numeric ranking indicating the strategic priority or preference of this channel relative to others for business development and resource allocation.',
    `channel_status` STRING COMMENT 'Current lifecycle status of the distribution channel indicating whether it is available for new business.. Valid values are `active|inactive|suspended|pending|terminated`',
    `channel_subtype` STRING COMMENT 'Secondary classification providing additional granularity within the primary channel type, such as affinity, digital, call center, or retail branch.',
    `channel_type` STRING COMMENT 'Primary classification of how business reaches the insurer: captive agent, independent agent, broker, direct-to-consumer, managing general agent, or wholesale.. Valid values are `captive|independent|broker|direct|mga|wholesale`',
    `commission_schedule_code` STRING COMMENT 'Reference code linking this channel to its default commission rate structure and payment terms.. Valid values are `^[A-Z0-9_]{2,15}$`',
    `contingent_commission_eligible` BOOLEAN COMMENT 'Indicates whether producers in this channel are eligible for performance-based contingent commission payments.',
    `continuing_education_required` BOOLEAN COMMENT 'Indicates whether producers in this channel must complete ongoing continuing education requirements to maintain their authorization.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this distribution channel record was first created in the data platform.',
    `default_commission_rate` DECIMAL(5,4) COMMENT 'Standard commission percentage paid to producers operating through this channel, expressed as a decimal fraction.',
    `direct_bill_flag` BOOLEAN COMMENT 'Indicates whether policies written through this channel are billed directly by the insurer or through agency bill arrangements.',
    `effective_date` DATE COMMENT 'Date when this distribution channel became active and available for producer appointments and policy binding.',
    `eo_insurance_required` BOOLEAN COMMENT 'Indicates whether producers operating through this channel must maintain errors and omissions professional liability coverage.',
    `expiration_date` DATE COMMENT 'Date when this distribution channel is scheduled to terminate or was terminated. Null for open-ended channels.',
    `geographic_scope` STRING COMMENT 'Description of the geographic territories or jurisdictions where this channel is authorized to operate, such as nationwide, regional, or state-specific.',
    `lob_authorizations` STRING COMMENT 'Comma-separated list of line-of-business codes that producers in this channel are authorized to write, such as HO, PAP, CGL, BOP, WC.',
    `minimum_eo_coverage_amount` DECIMAL(15,2) COMMENT 'Minimum required errors and omissions insurance coverage limit for producers in this channel, expressed in policy currency.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code assigned to the writing company for regulatory reporting and statutory filings.. Valid values are `^[0-9]{5}$`',
    `regulatory_reporting_required` BOOLEAN COMMENT 'Indicates whether activity through this channel triggers specific regulatory reporting obligations to state departments of insurance or NAIC.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this distribution channel data originated, such as producer management or policy administration system.. Valid values are `^[A-Z0-9_]{2,20}$`',
    `surplus_lines_eligible` BOOLEAN COMMENT 'Indicates whether this channel is authorized to place surplus lines or non-admitted business in jurisdictions where the carrier is not licensed.',
    `target_market_segment` STRING COMMENT 'Description of the primary customer demographic or market segment this channel is designed to serve, such as personal lines, small commercial, or middle market.',
    `termination_reason` STRING COMMENT 'Business reason for channel termination, such as strategic realignment, regulatory action, or performance issues.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp when this distribution channel record was last modified.',
    `writing_company_code` STRING COMMENT 'Internal code identifying the insurance company or carrier that underwrites policies through this channel.. Valid values are `^[A-Z0-9]{2,10}$`',
    CONSTRAINT pk_distribution_channel PRIMARY KEY(`distribution_channel_id`)
) COMMENT 'Reference classification of how business reaches the insurer (captive, independent, broker, direct, MGA, wholesale, affinity, digital). One row per channel. Drives commission schedule selection and producer underwriting authority rules.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` (
    `commission_schedule_id` BIGINT COMMENT 'Unique identifier for the commission schedule. Primary key.',
    `agency_id` BIGINT COMMENT 'Agency to which this commission schedule applies, if agency-level.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Commission schedules define payment currency for producer compensation. The existing currency_code plain-text column is a denormalization of shared.currency.',
    `distribution_channel_id` BIGINT COMMENT 'Foreign key linking to producers.distribution_channel. Business justification: Commission schedules are defined for specific distribution channels. Replace STRING distribution_channel_code with FK to distribution_channel. N:1 relationship.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Commission schedules are structured by LOB for rate differentiation, regulatory compliance, and profitability management.',
    `producers_producer_id` BIGINT COMMENT 'Producer to whom this commission schedule applies.',
    `superseded_by_schedule_commission_schedule_id` BIGINT COMMENT 'Identifier of the commission schedule that replaces this one, if superseded.',
    `territory_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.territory. Business justification: Commission schedules in P&C insurance are frequently territory-specific — coastal or wind-pool territories carry different commission structures than inland territories.',
    `approval_date` DATE COMMENT 'Date when this commission schedule was approved by management or underwriting authority.',
    `approved_by` STRING COMMENT 'Name or identifier of the person who approved this commission schedule.',
    `base_commission_rate` DECIMAL(7,5) COMMENT 'Base commission rate as a decimal percentage applied to written premium for this schedule.',
    `bonus_commission_rate` DECIMAL(7,5) COMMENT 'Bonus commission rate as a decimal percentage, awarded for exceptional performance or strategic initiatives.',
    `chargeback_period_days` BIGINT COMMENT 'Number of days from policy effective date during which cancellation triggers commission chargeback.',
    `chargeback_provision` BOOLEAN COMMENT 'Indicates whether commission is subject to chargeback if policy cancels within a specified period.',
    `commission_basis` STRING COMMENT 'Premium basis on which commission is calculated: written, earned, net, or gross premium.. Valid values are `written_premium|earned_premium|net_premium|gross_premium`',
    `contingent_commission_rate` DECIMAL(7,5) COMMENT 'Contingent commission rate as a decimal percentage, earned based on profitability or volume thresholds.',
    `coverage_type_code` STRING COMMENT 'Specific coverage type within the line of business for which this schedule applies, if coverage-specific.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this commission schedule record was first created in the system.',
    `effective_date` DATE COMMENT 'Date when this commission schedule becomes active and binding.',
    `expiration_date` DATE COMMENT 'Date when this commission schedule expires or is no longer in force. Null for open-ended schedules.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this commission schedule record was last updated or modified.',
    `loss_ratio_threshold` DECIMAL(5,4) COMMENT 'Maximum loss ratio threshold for contingent commission eligibility, expressed as a decimal.',
    `maximum_premium_threshold` DECIMAL(15,2) COMMENT 'Maximum written premium amount beyond which this commission schedule no longer applies or a different tier begins.',
    `minimum_premium_threshold` DECIMAL(15,2) COMMENT 'Minimum written premium amount required for this commission schedule to apply.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code identifying the insurer for regulatory reporting.',
    `new_business_credit_rate` DECIMAL(7,5) COMMENT 'Additional commission credit rate for new business production, expressed as a decimal percentage.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding special terms, exceptions, or conditions of this commission schedule.',
    `override_commission_rate` DECIMAL(7,5) COMMENT 'Override commission rate as a decimal percentage, typically for agency principals or managing general agents.',
    `payment_timing` STRING COMMENT 'Timing of commission payment: immediate upon booking, monthly, quarterly, annual, or upon premium collection.. Valid values are `immediate|monthly|quarterly|annual|upon_collection`',
    `renewal_credit_rate` DECIMAL(7,5) COMMENT 'Additional commission credit rate for renewal business, expressed as a decimal percentage.',
    `retention_rate_threshold` DECIMAL(5,4) COMMENT 'Minimum policy retention rate required for contingent commission eligibility, expressed as a decimal.',
    `schedule_code` STRING COMMENT 'Business identifier for the commission schedule, used for external reference and reporting.',
    `schedule_name` STRING COMMENT 'Descriptive name of the commission schedule for business users.',
    `schedule_status` STRING COMMENT 'Current lifecycle status of the commission schedule.. Valid values are `draft|active|suspended|expired|terminated`',
    `schedule_type` STRING COMMENT 'Type of commission schedule: standard, override, contingent, bonus, or special arrangement.. Valid values are `standard|override|contingent|bonus|special`',
    `source_system_code` STRING COMMENT 'Code identifying the operational system from which this commission schedule record originated.',
    `source_system_reference_code` STRING COMMENT 'Unique identifier of this commission schedule in the source operational system for traceability.',
    `state_code` STRING COMMENT 'Two-letter state code for which this commission schedule applies, if state-specific.',
    `termination_date` DATE COMMENT 'Date when this commission schedule was terminated before its natural expiration.',
    `termination_reason` STRING COMMENT 'Reason for early termination of this commission schedule: producer termination, contract renegotiation, regulatory change, etc.',
    `tier_level` BIGINT COMMENT 'Tier level within a multi-tier commission structure, where higher tiers may have different rates.',
    `transaction_type` STRING COMMENT 'Policy transaction type for which this commission rate applies: New Business, Renewal, Endorsement, Cancellation, Reinstatement.. Valid values are `NB|REN|END|CAN|RI`',
    `version_number` BIGINT COMMENT 'Version number of this commission schedule, incremented with each amendment or revision.',
    `volume_threshold_policy_count` BIGINT COMMENT 'Minimum number of policies required to qualify for this commission schedule or tier.',
    `writing_company_code` STRING COMMENT 'Insurance company code for which this commission schedule applies, if company-specific.',
    CONSTRAINT pk_commission_schedule PRIMARY KEY(`commission_schedule_id`)
) COMMENT 'Contractual commission rate set for a producer or agency by LOB, transaction type (NB/REN/END), and coverage type over an effective period. One row per schedule version. Holds all rate lines (base, contingent, override) as embedded detail.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` (
    `commission_rule_id` BIGINT COMMENT 'Unique identifier for the commission rule. Primary key.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key to the parent commission schedule that owns this rule.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Commission rules specify minimum and maximum commission amounts in a defined currency. The existing currency_code is a denormalized text field.',
    `distribution_channel_id` BIGINT COMMENT 'Foreign key linking to producers.distribution_channel. Business justification: Commission rules may vary by distribution channel. Replace STRING distribution_channel_code with FK to distribution_channel. N:1 relationship.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Commission rules are configured by LOB for rate differentiation, transaction type handling, and regulatory compliance.',
    `approval_date` DATE COMMENT 'Date this commission rule was approved by management or compliance.',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether this rule requires management or compliance approval before activation.',
    `approved_by` STRING COMMENT 'Name or identifier of the person who approved this commission rule for use.',
    `base_commission_rate` DECIMAL(7,5) COMMENT 'Standard commission rate expressed as a decimal percentage applied to written premium for this rule.',
    `chargeback_eligible_flag` BOOLEAN COMMENT 'Indicates whether commission paid under this rule is subject to chargeback if the policy cancels or premium is returned.',
    `chargeback_period_days` BIGINT COMMENT 'Number of days from policy effective date during which commission chargeback applies if the policy cancels.',
    `commission_basis_code` STRING COMMENT 'Premium basis on which commission is calculated: written premium, earned premium, billed premium, or collected premium.. Valid values are `written|earned|billed|collected`',
    `commission_split_flag` BOOLEAN COMMENT 'Indicates whether this rule supports splitting commission among multiple producers.',
    `contingent_commission_rate` DECIMAL(7,5) COMMENT 'Additional performance-based commission rate applied when volume, profitability, or retention thresholds are met.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this commission rule record was first created in the system.',
    `effective_date` DATE COMMENT 'Date this commission rule becomes active and begins applying to new transactions.',
    `expiration_date` DATE COMMENT 'Date this commission rule expires and ceases to apply; null indicates an open-ended rule.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this commission rule record was last updated or modified.',
    `loss_ratio_threshold` DECIMAL(5,4) COMMENT 'Maximum loss ratio threshold for contingent commission eligibility; expressed as a decimal percentage.',
    `maximum_commission_amount` DECIMAL(12,2) COMMENT 'Ceiling amount for commission payment; if calculated commission exceeds this, the maximum is paid instead.',
    `minimum_commission_amount` DECIMAL(12,2) COMMENT 'Floor amount for commission payment; if calculated commission is below this, the minimum is paid instead.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code identifying the insurer for regulatory reporting and commission allocation.',
    `override_commission_rate` DECIMAL(7,5) COMMENT 'Hierarchical override commission rate paid to managing producers or agency principals on downline production.',
    `payment_timing_code` STRING COMMENT 'Timing of commission payment under this rule: immediate upon transaction, monthly, quarterly, or annual settlement.. Valid values are `immediate|monthly|quarterly|annual`',
    `policy_state_code` STRING COMMENT 'Two-letter state or jurisdiction code where the policy is written; rule applies only to policies in this state.',
    `premium_tier_maximum` DECIMAL(12,2) COMMENT 'Maximum written premium threshold for this rule to apply; enables tiered commission structures.',
    `premium_tier_minimum` DECIMAL(12,2) COMMENT 'Minimum written premium threshold for this rule to apply; enables tiered commission structures.',
    `producer_type_code` STRING COMMENT 'Type of producer this rule applies to: agent, broker, managing general agent, or direct.. Valid values are `agent|broker|mga|direct`',
    `retention_rate_threshold` DECIMAL(5,4) COMMENT 'Minimum policy retention rate threshold for contingent commission eligibility; expressed as a decimal percentage.',
    `rule_description` STRING COMMENT 'Detailed explanation of the conditions and rates applied by this rule.',
    `rule_name` STRING COMMENT 'Business-friendly name or label for this commission rule.',
    `rule_notes` STRING COMMENT 'Free-text notes or comments about this commission rule for internal reference and documentation.',
    `rule_sequence_number` BIGINT COMMENT 'Ordering of this rule within the parent schedule for evaluation precedence.',
    `rule_status` STRING COMMENT 'Current lifecycle status of this commission rule: active, inactive, pending approval, expired, or superseded by a newer rule.. Valid values are `active|inactive|pending|expired|superseded`',
    `source_rule_reference` STRING COMMENT 'External reference or identifier for this rule in the source producer management or commission system.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system that created or manages this commission rule.',
    `split_percentage` DECIMAL(5,4) COMMENT 'Percentage of total commission allocated to this rule when commission splitting is enabled; expressed as a decimal.',
    `transaction_type_code` STRING COMMENT 'Policy transaction type this rule applies to: New Business, Renewal, Endorsement, Cancellation, Reinstatement, Non-renewal.. Valid values are `NB|REN|END|CAN|RI|NR`',
    `volume_threshold_amount` DECIMAL(15,2) COMMENT 'Cumulative premium volume threshold that must be met for contingent or bonus commission rates to apply.',
    `writing_company_code` STRING COMMENT 'Insurance company or carrier code this rule applies to, for multi-carrier agency environments.',
    CONSTRAINT pk_commission_rule PRIMARY KEY(`commission_rule_id`)
) COMMENT 'Individual rate rule within a commission schedule. One row per rule. Specifies transaction type (NB, REN, END), LOB, coverage type, base rate, contingent rate, override rate, and effective date range.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` (
    `commission_transaction_id` BIGINT COMMENT 'Unique identifier for the commission financial movement. Primary key.',
    `accounting_period_id` BIGINT COMMENT 'Foreign key to the accounting period in which this commission is recognized.',
    `agency_id` BIGINT COMMENT 'Foreign key to the agency associated with this commission.',
    `commission_rule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_rule. Business justification: Each transaction is calculated by applying a specific rule within a schedule. The rule specifies the exact rate, tier, LOB, and conditions that produced the commission amount.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: Each transaction is calculated using a specific commission schedule. Replace STRING commission_schedule_code with FK to commission_schedule. N:1 relationship.',
    `commission_statement_id` BIGINT COMMENT 'Foreign key linking to producers.commission_statement. Business justification: Transactions roll up into periodic statements. Each transaction appears on exactly one statement for a given billing period. Standard transaction-to-statement aggregation link.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Enables coverage-level commission allocation when commission rates vary by coverage type within a policy (e.g., different rates for property vs liability).',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Commission transactions in multi-currency operations require currency reference for financial reporting, GL posting, and payment processing.',
    `original_transaction_commission_transaction_id` BIGINT COMMENT 'Foreign key to the original commission transaction if this is a reversal, adjustment, or claw-back.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy generating this commission.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term associated with this commission.',
    `premium_transaction_id` BIGINT COMMENT 'Foreign key to the premium transaction that generated this commission.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key to the producer earning this commission.',
    `adjustment_amount` DECIMAL(18,2) COMMENT 'Adjustment amount applied to correct or modify the commission.',
    `claw_back_amount` DECIMAL(18,2) COMMENT 'Amount of commission reclaimed due to policy cancellation, return premium, or other reversal event.',
    `commission_basis` STRING COMMENT 'Basis on which commission is calculated: Gross Written Premium, Net Written Premium, Earned Premium, flat fee, or sliding scale.. Valid values are `gwp|nwp|ep|flat_fee|sliding_scale`',
    `commission_rate` DECIMAL(7,4) COMMENT 'Percentage rate applied to the premium to calculate the commission, expressed as a decimal.',
    `contingent_commission_flag` BOOLEAN COMMENT 'Indicates whether this commission is contingent on meeting performance or profitability targets.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this commission transaction record was first created in the system.',
    `earned_amount` DECIMAL(18,2) COMMENT 'Gross commission amount earned by the producer on the premium transaction.',
    `effective_date` DATE COMMENT 'Date when the commission becomes effective for accounting purposes.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this commission transaction is posted.',
    `lob_code` STRING COMMENT 'Code identifying the line of business for which this commission was earned.',
    `net_commission_amount` DECIMAL(18,2) COMMENT 'Net commission amount after applying claw-backs and adjustments.',
    `notes` STRING COMMENT 'Free-text notes or comments related to this commission transaction.',
    `npn` STRING COMMENT 'National Producer Number of the producer earning this commission, for regulatory reporting.',
    `override_flag` BOOLEAN COMMENT 'Indicates whether this commission is an override commission paid to a higher-level producer or manager.',
    `payment_date` DATE COMMENT 'Date when the commission was paid or is scheduled to be paid to the producer.',
    `payment_method` STRING COMMENT 'Method used to pay the commission to the producer.. Valid values are `ach|wire|check|eft|direct_deposit`',
    `payment_reference_number` STRING COMMENT 'External reference number for the payment transaction, such as check number or wire confirmation.',
    `payment_status` STRING COMMENT 'Current payment status of the commission transaction.. Valid values are `unpaid|scheduled|paid|withheld|disputed`',
    `policy_transaction_type` STRING COMMENT 'Type of policy transaction that triggered this commission: new business, renewal, endorsement, cancellation, or reinstatement.. Valid values are `new_business|renewal|endorsement|cancellation|reinstatement`',
    `reversal_reason_code` STRING COMMENT 'Code indicating the reason for commission reversal or claw-back, if applicable.',
    `reversal_reason_description` STRING COMMENT 'Detailed description of the reason for commission reversal or claw-back.',
    `source_system_code` STRING COMMENT 'Code identifying the source system that originated this commission transaction.',
    `source_transaction_reference` STRING COMMENT 'External reference identifier from the source system for this commission transaction.',
    `split_percentage` DECIMAL(5,2) COMMENT 'Percentage of the total commission allocated to this producer in a split commission scenario.',
    `state_code` STRING COMMENT 'Two-letter state code where the policy was written and commission earned.. Valid values are `^[A-Z]{2}$`',
    `tax_withholding_amount` DECIMAL(18,2) COMMENT 'Amount of tax withheld from the commission payment, if applicable.',
    `transaction_date` DATE COMMENT 'Date when the commission transaction was recorded in the system.',
    `transaction_number` STRING COMMENT 'Business identifier for this commission transaction, unique within the system.',
    `transaction_status` STRING COMMENT 'Current lifecycle status of the commission transaction.. Valid values are `pending|approved|paid|voided|disputed|reconciled`',
    `transaction_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the commission transaction was created.',
    `transaction_type` STRING COMMENT 'Type of commission financial movement: earned, claw-back, adjustment, reversal, advance, or chargeback.. Valid values are `earned|claw_back|adjustment|reversal|advance|chargeback`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this commission transaction record was last modified.',
    `writing_company_code` STRING COMMENT 'Code identifying the insurance company that wrote the policy and owes the commission.',
    CONSTRAINT pk_commission_transaction PRIMARY KEY(`commission_transaction_id`)
) COMMENT 'One row per commission financial movement earned by a producer on a premium transaction. Captures earned amount, claw-back amount, transaction type, accounting period, and payment status. Child of premium transaction.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` (
    `commission_statement_id` BIGINT COMMENT 'Unique identifier for the commission statement. Primary key.',
    `agency_id` BIGINT COMMENT 'Agency associated with the producer for this statement.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: Statements are generated based on a specific commission schedule that defines the rates and rules. N:1 relationship.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Commission statements carry multiple monetary totals (net_commission_payable, total_commission_earned, chargeback_amount) requiring a defined currency.',
    `distribution_channel_id` BIGINT COMMENT 'Foreign key linking to producers.distribution_channel. Business justification: Statements may be segmented by distribution channel for reporting and reconciliation. Replace STRING distribution_channel_code with FK. N:1 relationship.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Commission statements aggregate transactions by LOB for producer reporting, tax reporting (1099), and reconciliation.',
    `producers_producer_id` BIGINT COMMENT 'Producer or agent to whom this statement is issued.',
    `chargeback_amount` DECIMAL(18,2) COMMENT 'Total commission chargebacks for cancelled or returned policies during the statement period.',
    `contingent_commission` DECIMAL(18,2) COMMENT 'Performance-based bonus commission earned based on loss ratio, volume, or other criteria.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this commission statement record was first created in the system.',
    `dispute_date` DATE COMMENT 'Date the producer filed a dispute against this commission statement.',
    `dispute_flag` BOOLEAN COMMENT 'Indicates whether the producer has disputed any portion of this commission statement.',
    `dispute_resolution_date` DATE COMMENT 'Date the dispute was resolved and the statement was finalized.',
    `endorsement_commission` DECIMAL(18,2) COMMENT 'Commission earned on policy endorsements and mid-term changes during the statement period.',
    `eo_premium_deduction` DECIMAL(18,2) COMMENT 'Deduction for errors and omissions insurance premium paid on behalf of the producer.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this commission statement record was last updated.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC code identifying the insurance company for regulatory reporting.',
    `net_commission_payable` DECIMAL(18,2) COMMENT 'Net commission amount payable to the producer after all adjustments and deductions.',
    `new_business_commission` DECIMAL(18,2) COMMENT 'Commission earned on new business policies written during the statement period.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding this commission statement.',
    `npn` STRING COMMENT 'National Producer Number of the producer receiving this statement.',
    `payment_date` DATE COMMENT 'Date the commission payment was issued to the producer.',
    `payment_method` STRING COMMENT 'Method used to disburse the commission payment to the producer.. Valid values are `ach|wire|check|eft|direct_deposit`',
    `payment_reference_number` STRING COMMENT 'External reference number for the payment transaction such as check number or wire confirmation.',
    `payment_status` STRING COMMENT 'Current payment status indicating whether the net commission has been disbursed to the producer.. Valid values are `unpaid|pending|paid|partially_paid|failed`',
    `policy_count` BIGINT COMMENT 'Total number of policies contributing commission transactions to this statement.',
    `renewal_commission` DECIMAL(18,2) COMMENT 'Commission earned on policy renewals during the statement period.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system that originated this commission statement record.',
    `statement_date` DATE COMMENT 'Date the commission statement was generated and issued.',
    `statement_delivery_method` STRING COMMENT 'Method by which the commission statement was delivered to the producer.. Valid values are `email|mail|portal|fax`',
    `statement_document_reference` STRING COMMENT 'Reference identifier or URI to the generated commission statement document.',
    `statement_number` STRING COMMENT 'Externally visible unique identifier for the commission statement.',
    `statement_period_end_date` DATE COMMENT 'End date of the billing cycle covered by this statement.',
    `statement_period_start_date` DATE COMMENT 'Start date of the billing cycle covered by this statement.',
    `statement_status` STRING COMMENT 'Current lifecycle status of the commission statement.. Valid values are `draft|issued|paid|partially_paid|disputed|cancelled`',
    `statement_type` STRING COMMENT 'Type of commission statement indicating whether it is a regular periodic statement or a special issuance.. Valid values are `regular|supplemental|correction|final`',
    `tax_identification_number` STRING COMMENT 'Federal Employer Identification Number or Social Security Number for tax reporting purposes.',
    `total_adjustments` DECIMAL(18,2) COMMENT 'Total adjustments applied to earned commission including chargebacks, corrections, and bonuses.',
    `total_commission_earned` DECIMAL(18,2) COMMENT 'Total commission amount earned by the producer for the statement period before adjustments.',
    `total_deductions` DECIMAL(18,2) COMMENT 'Total deductions from commission including errors and omissions insurance premiums, fees, and withholdings.',
    `transaction_count` BIGINT COMMENT 'Total number of individual commission transactions included in this statement.',
    `writing_company_code` STRING COMMENT 'Code identifying the insurance company or carrier issuing this commission statement.',
    CONSTRAINT pk_commission_statement PRIMARY KEY(`commission_statement_id`)
) COMMENT 'Periodic statement issued to a producer or agency summarizing commission transactions due for a billing cycle. One row per statement. Tracks statement date, total earned, total adjustments, net payable, and payment status.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` (
    `underwriting_authority_id` BIGINT COMMENT 'Unique identifier for the underwriting authority grant record.',
    `agency_id` BIGINT COMMENT 'Reference to the agency organization holding this authority.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Binding authority is explicitly restricted by catastrophe zone. Producers in coastal wind zones or earthquake zones require higher authority levels or mandatory referral.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Underwriting authority limits (max_single_risk_limit, max_tiv, deductible_max/min, premium thresholds) are all currency-denominated monetary fields.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Authority grants are LOB-specific per regulatory and risk management requirements. LOB reference provides admitted/surplus lines status, state filing requirements, and default policy',
    `peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Binding authority is granted per peril (wind, earthquake, flood, wildfire). Producers must have explicit peril-specific authority to bind coverage.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer or agent receiving this binding authority.',
    `territory_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.territory. Business justification: Underwriting authorities in P&C are defined at territory level — a producer may have binding authority in territory 001 but require referral in territory 002 within the same',
    `approval_date` DATE COMMENT 'Date when the underwriting authority was approved by the carrier or underwriting management.',
    `approved_by` STRING COMMENT 'Name or identifier of the underwriting manager or executive who approved this authority grant.',
    `audit_frequency` STRING COMMENT 'Frequency at which policies bound under this authority must be audited: monthly, quarterly, semi-annual, annual, or per policy.. Valid values are `monthly|quarterly|semi_annual|annual|per_policy`',
    `audit_required` BOOLEAN COMMENT 'Indicates whether policies bound under this authority require post-binding underwriting audit or review.',
    `authority_status` STRING COMMENT 'Current lifecycle status of the underwriting authority grant.. Valid values are `active|suspended|revoked|expired|pending|inactive`',
    `authority_type` STRING COMMENT 'Classification of the authority level granted: binding, quoting, referral, limited binding, full binding, or conditional.. Valid values are `binding|quoting|referral|limited_binding|full_binding|conditional`',
    `blanket_coverage_allowed` BOOLEAN COMMENT 'Indicates whether the producer may bind blanket coverage policies under this authority.',
    `cancellation_allowed` BOOLEAN COMMENT 'Indicates whether this authority permits canceling policies.',
    `coinsurance_allowed` BOOLEAN COMMENT 'Indicates whether the producer may bind policies with coinsurance clauses under this authority.',
    `construction_restrictions` STRING COMMENT 'Construction types or building classes excluded from this authority per COPE criteria.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this authority record was first created in the data platform.',
    `deductible_max` DECIMAL(18,2) COMMENT 'Maximum deductible amount the producer may offer when binding coverage under this authority.',
    `deductible_min` DECIMAL(18,2) COMMENT 'Minimum deductible amount the producer must apply when binding coverage under this authority.',
    `effective_date` DATE COMMENT 'Date when the underwriting authority becomes active and binding authority may be exercised.',
    `eligible_states` STRING COMMENT 'Comma-separated list of state codes where this authority is valid and may be exercised.',
    `endorsement_allowed` BOOLEAN COMMENT 'Indicates whether this authority permits issuing policy endorsements.',
    `excluded_states` STRING COMMENT 'Comma-separated list of state codes explicitly excluded from this authority grant.',
    `expiration_date` DATE COMMENT 'Date when the underwriting authority expires and can no longer be exercised unless renewed.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this authority record was last updated in the data platform.',
    `limit_tier` STRING COMMENT 'Tiered classification of authority limits: tier 1 (lowest), tier 2, tier 3, tier 4, or unlimited.. Valid values are `tier_1|tier_2|tier_3|tier_4|unlimited`',
    `max_premium_threshold` DECIMAL(18,2) COMMENT 'Maximum written premium amount the producer may bind without underwriting referral.',
    `max_single_risk_limit` DECIMAL(18,2) COMMENT 'Maximum policy limit the producer may bind on a single insured risk without referral to underwriting.',
    `max_tiv` DECIMAL(18,2) COMMENT 'Maximum total insured value the producer may bind without underwriting referral.',
    `min_premium_threshold` DECIMAL(18,2) COMMENT 'Minimum written premium amount required for the producer to exercise binding authority on a policy.',
    `new_business_allowed` BOOLEAN COMMENT 'Indicates whether this authority permits binding new business policies.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding special conditions, exceptions, or clarifications for this authority grant.',
    `occupancy_restrictions` STRING COMMENT 'Specific occupancy types or uses excluded from this binding authority per Construction, Occupancy, Protection, Exposure (COPE) criteria.',
    `protection_class_max` BIGINT COMMENT 'Maximum ISO protection class rating allowed for binding under this authority without referral.',
    `protection_class_min` BIGINT COMMENT 'Minimum ISO protection class rating required for the producer to bind coverage under this authority.',
    `referral_criteria` STRING COMMENT 'Business rules or conditions that trigger mandatory referral to underwriting despite binding authority.',
    `reinstatement_allowed` BOOLEAN COMMENT 'Indicates whether this authority permits reinstating lapsed or canceled policies.',
    `renewal_allowed` BOOLEAN COMMENT 'Indicates whether this authority permits binding renewal policies.',
    `renewal_eligible` BOOLEAN COMMENT 'Indicates whether this authority grant is eligible for renewal upon expiration.',
    `revocation_date` DATE COMMENT 'Date when the underwriting authority was revoked or terminated prior to expiration.',
    `revocation_reason` STRING COMMENT 'Business reason or cause for revoking the underwriting authority prior to expiration.',
    `risk_class_restrictions` STRING COMMENT 'Comma-separated list of risk classes or NAICS codes for which this authority is restricted or excluded.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record where this authority grant was created.',
    `source_system_reference_code` STRING COMMENT 'Unique identifier or key for this authority record in the source operational system.',
    CONSTRAINT pk_underwriting_authority PRIMARY KEY(`underwriting_authority_id`)
) COMMENT 'Defines the binding authority granted to a producer or agency by LOB, coverage type, and limit tier. One row per authority grant. Tracks max TIV, max single-risk limit, eligible states, and authority expiration date.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ADD CONSTRAINT `fk_producers_producers_producer_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ADD CONSTRAINT `fk_producers_agency_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ADD CONSTRAINT `fk_producers_agency_parent_agency_id` FOREIGN KEY (`parent_agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ADD CONSTRAINT `fk_producers_producer_license_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ADD CONSTRAINT `fk_producers_agency_producer_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ADD CONSTRAINT `fk_producers_agency_producer_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ADD CONSTRAINT `fk_producers_agency_producer_primary_agency_producers_producer_id` FOREIGN KEY (`primary_agency_producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ADD CONSTRAINT `fk_producers_producer_appointment_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ADD CONSTRAINT `fk_producers_producer_appointment_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ADD CONSTRAINT `fk_producers_producer_appointment_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ADD CONSTRAINT `fk_producers_producer_appointment_prior_appointment_producer_appointment_id` FOREIGN KEY (`prior_appointment_producer_appointment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment`(`producer_appointment_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ADD CONSTRAINT `fk_producers_producer_appointment_producer_license_id` FOREIGN KEY (`producer_license_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producer_license`(`producer_license_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ADD CONSTRAINT `fk_producers_producer_appointment_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ADD CONSTRAINT `fk_producers_commission_schedule_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ADD CONSTRAINT `fk_producers_commission_schedule_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ADD CONSTRAINT `fk_producers_commission_schedule_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ADD CONSTRAINT `fk_producers_commission_schedule_superseded_by_schedule_commission_schedule_id` FOREIGN KEY (`superseded_by_schedule_commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ADD CONSTRAINT `fk_producers_commission_rule_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ADD CONSTRAINT `fk_producers_commission_rule_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_commission_rule_id` FOREIGN KEY (`commission_rule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule`(`commission_rule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_commission_statement_id` FOREIGN KEY (`commission_statement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement`(`commission_statement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_original_transaction_commission_transaction_id` FOREIGN KEY (`original_transaction_commission_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction`(`commission_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ADD CONSTRAINT `fk_producers_underwriting_authority_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ADD CONSTRAINT `fk_producers_underwriting_authority_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`producers` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`producers` SET TAGS ('dbx_domain' = 'producers');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `territory_id` SET TAGS ('dbx_business_glossary_term' = 'Territory Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `appointment_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `appointment_status` SET TAGS ('dbx_business_glossary_term' = 'Producer Appointment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `appointment_status` SET TAGS ('dbx_value_regex' = 'active|inactive|terminated|pending|suspended');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `appointment_termination_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Termination Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `background_check_date` SET TAGS ('dbx_business_glossary_term' = 'Background Check Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `background_check_status` SET TAGS ('dbx_business_glossary_term' = 'Background Check Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `background_check_status` SET TAGS ('dbx_value_regex' = 'passed|failed|pending|waived');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `binding_authority_flag` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `commission_schedule_code` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Eligible Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `continuing_education_due_date` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `continuing_education_hours_completed` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Hours Completed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `default_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Default Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `default_commission_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `eo_carrier_name` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Carrier Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `eo_carrier_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `eo_coverage_amount` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Coverage Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `eo_coverage_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `eo_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `eo_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `eo_policy_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `is_surplus_lines_licensed` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Licensed Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `license_class` SET TAGS ('dbx_business_glossary_term' = 'Producer License Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `license_effective_date` SET TAGS ('dbx_business_glossary_term' = 'License Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `license_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'License Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `license_number` SET TAGS ('dbx_business_glossary_term' = 'Producer License Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `license_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `lob_authorizations` SET TAGS ('dbx_business_glossary_term' = 'Lines of Business (LOB) Authorizations');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'NAIC Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `npn` SET TAGS ('dbx_business_glossary_term' = 'National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `npn` SET TAGS ('dbx_value_regex' = '^[0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `npn` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Commission Payment Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'ach|check|wire');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `producer_role` SET TAGS ('dbx_business_glossary_term' = 'Producer Role');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `producer_role` SET TAGS ('dbx_value_regex' = 'agent|broker|managing_general_agent|surplus_lines_broker|independent_agent|captive_agent');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `producer_type` SET TAGS ('dbx_business_glossary_term' = 'Producer Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `producer_type` SET TAGS ('dbx_value_regex' = 'individual|entity');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `regulatory_action_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Action Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `resident_state_code` SET TAGS ('dbx_business_glossary_term' = 'Resident State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `resident_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `resident_state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `since_date` SET TAGS ('dbx_business_glossary_term' = 'Producer Since Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `surplus_lines_license_number` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines License Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `surplus_lines_license_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `surplus_lines_license_number` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number (TIN / FEIN / SSN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Appointment Termination Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'voluntary|non_renewal|cause|regulatory|deceased|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `w9_on_file` SET TAGS ('dbx_business_glossary_term' = 'IRS W-9 On File Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `writing_company_code` SET TAGS ('dbx_business_glossary_term' = 'Writing Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `parent_agency_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Agency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_address_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Address Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_address_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_address_id` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `territory_id` SET TAGS ('dbx_business_glossary_term' = 'Territory Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `agency_status` SET TAGS ('dbx_business_glossary_term' = 'Agency Appointment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `agency_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|terminated|pending_appointment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `agency_type` SET TAGS ('dbx_business_glossary_term' = 'Agency Type Classification');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `annual_premium_volume` SET TAGS ('dbx_business_glossary_term' = 'Annual Premium Volume Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `appointment_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `appointment_termination_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Termination Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `binding_authority_flag` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `commission_schedule_code` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Eligible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `default_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Default Commission Rate Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `eo_carrier_name` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Carrier Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `eo_carrier_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `eo_coverage_amount` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Coverage Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `eo_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `eo_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `lob_authorizations` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Authorizations');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `mailing_address_same_as_principal` SET TAGS ('dbx_business_glossary_term' = 'Mailing Address Same As Principal Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `mailing_address_same_as_principal` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `mailing_address_same_as_principal` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `policy_count` SET TAGS ('dbx_business_glossary_term' = 'Policy Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `surplus_lines_eligible` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Eligible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `surplus_lines_license_number` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines License Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `surplus_lines_license_number` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `termination_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `termination_reason_code` SET TAGS ('dbx_value_regex' = 'voluntary|involuntary|non_renewal|regulatory|merger|acquisition');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `tier` SET TAGS ('dbx_business_glossary_term' = 'Agency Performance Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `tier` SET TAGS ('dbx_value_regex' = 'platinum|gold|silver|bronze|standard');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `writing_company_code` SET TAGS ('dbx_business_glossary_term' = 'Writing Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `producer_license_id` SET TAGS ('dbx_business_glossary_term' = 'Producer License Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `license_id` SET TAGS ('dbx_business_glossary_term' = 'License Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `application_date` SET TAGS ('dbx_business_glossary_term' = 'License Application Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `appointment_required` SET TAGS ('dbx_business_glossary_term' = 'Appointment Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'License Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `background_check_date` SET TAGS ('dbx_business_glossary_term' = 'Background Check Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `background_check_required` SET TAGS ('dbx_business_glossary_term' = 'Background Check Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `background_check_status` SET TAGS ('dbx_business_glossary_term' = 'Background Check Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `background_check_status` SET TAGS ('dbx_value_regex' = 'passed|failed|pending|not_required|expired');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `ce_due_date` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `ce_ethics_hours_required` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Ethics Hours Required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `ce_hours_completed` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Hours Completed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `ce_hours_required` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Hours Required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `denial_date` SET TAGS ('dbx_business_glossary_term' = 'License Denial Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `denial_reason` SET TAGS ('dbx_business_glossary_term' = 'License Denial Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `doi_action_date` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Action Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `doi_action_description` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Action Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `doi_action_flag` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Action Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `doi_action_type` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Action Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `doi_action_type` SET TAGS ('dbx_value_regex' = 'suspension|revocation|fine|probation|consent_order|cease_and_desist');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'License Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'License Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `fingerprint_date` SET TAGS ('dbx_business_glossary_term' = 'Fingerprint Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `fingerprint_date` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `fingerprint_date` SET TAGS ('dbx_pii_biometric' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `fingerprint_required` SET TAGS ('dbx_business_glossary_term' = 'Fingerprint Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `fingerprint_required` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `fingerprint_required` SET TAGS ('dbx_pii_biometric' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'License Issue Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `license_class` SET TAGS ('dbx_business_glossary_term' = 'License Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `license_class` SET TAGS ('dbx_value_regex' = 'resident|non-resident|temporary|surplus_lines|adjuster|public_adjuster');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `license_state_code` SET TAGS ('dbx_business_glossary_term' = 'License State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `license_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `license_state_code` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `license_status` SET TAGS ('dbx_business_glossary_term' = 'License Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `license_type` SET TAGS ('dbx_business_glossary_term' = 'License Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `license_type` SET TAGS ('dbx_value_regex' = 'individual|business_entity|agency');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `loa_casualty` SET TAGS ('dbx_business_glossary_term' = 'Line of Authority (LOA) Casualty');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `loa_health` SET TAGS ('dbx_business_glossary_term' = 'Line of Authority (LOA) Health');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `loa_health` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `loa_health` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `loa_health` SET TAGS ('dbx_pii_category' = 'health');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `loa_life` SET TAGS ('dbx_business_glossary_term' = 'Line of Authority (LOA) Life');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `loa_personal_lines` SET TAGS ('dbx_business_glossary_term' = 'Line of Authority (LOA) Personal Lines');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `loa_property` SET TAGS ('dbx_business_glossary_term' = 'Line of Authority (LOA) Property');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `loa_variable_annuity` SET TAGS ('dbx_business_glossary_term' = 'Line of Authority (LOA) Variable Annuity');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `nipr_transaction_number` SET TAGS ('dbx_business_glossary_term' = 'National Insurance Producer Registry (NIPR) Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `npn` SET TAGS ('dbx_business_glossary_term' = 'National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `npn` SET TAGS ('dbx_value_regex' = '^[0-9]{8,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `npn` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `npn` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `reciprocity_state_code` SET TAGS ('dbx_business_glossary_term' = 'Reciprocity State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `reciprocity_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `reciprocity_state_code` SET TAGS ('dbx_pii_category' = 'address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `renewal_date` SET TAGS ('dbx_business_glossary_term' = 'License Renewal Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `surplus_lines_eligible` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Eligible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'License Termination Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'License Termination Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'voluntary|non_renewal|regulatory_action|death|retirement|business_closure');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `agency_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Producer Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `primary_agency_producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `annual_production_target` SET TAGS ('dbx_business_glossary_term' = 'Annual Production Target');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `appointment_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `appointment_status` SET TAGS ('dbx_business_glossary_term' = 'Appointment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `appointment_status` SET TAGS ('dbx_value_regex' = 'appointed|pending|denied|terminated|suspended');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `appointment_termination_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Termination Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `binding_authority_flag` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `book_of_business_ownership` SET TAGS ('dbx_business_glossary_term' = 'Book of Business Ownership');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `book_of_business_ownership` SET TAGS ('dbx_value_regex' = 'producer|agency|shared|carrier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `commission_split_percentage` SET TAGS ('dbx_business_glossary_term' = 'Commission Split Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Eligible');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `contract_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Contract Document Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `default_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Default Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `desk_location` SET TAGS ('dbx_business_glossary_term' = 'Desk Location');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `eo_coverage_required` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Coverage Required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `eo_coverage_verified_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Coverage Verified Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `lob_authorizations` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Authorizations');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `non_compete_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Non-Compete Clause Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `non_compete_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Non-Compete Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `performance_tier` SET TAGS ('dbx_business_glossary_term' = 'Performance Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `primary_agency_flag` SET TAGS ('dbx_business_glossary_term' = 'Primary Agency Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `record_version_number` SET TAGS ('dbx_business_glossary_term' = 'Record Version Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `relationship_status` SET TAGS ('dbx_business_glossary_term' = 'Relationship Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `relationship_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|terminated|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `relationship_type` SET TAGS ('dbx_business_glossary_term' = 'Relationship Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `relationship_type` SET TAGS ('dbx_value_regex' = 'employee|independent_contractor|sub_agent|captive_agent|general_agent|managing_general_agent');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `termination_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `termination_reason_code` SET TAGS ('dbx_value_regex' = 'voluntary_resignation|involuntary_termination|retirement|license_revocation|contract_expiration|performance');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `termination_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `writing_authority_level` SET TAGS ('dbx_business_glossary_term' = 'Writing Authority Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `writing_authority_level` SET TAGS ('dbx_value_regex' = 'full|limited|referral_only|none');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `producer_appointment_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Appointment Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `prior_appointment_producer_appointment_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Appointment Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `producer_license_id` SET TAGS ('dbx_business_glossary_term' = 'Producer License Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `territory_id` SET TAGS ('dbx_business_glossary_term' = 'Territory Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `appointment_agreement_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Agreement Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `appointment_agreement_number` SET TAGS ('dbx_business_glossary_term' = 'Appointment Agreement Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `appointment_number` SET TAGS ('dbx_business_glossary_term' = 'Appointment Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `appointment_source` SET TAGS ('dbx_business_glossary_term' = 'Appointment Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `appointment_source` SET TAGS ('dbx_value_regex' = 'direct_hire|agency_transfer|acquisition|reciprocity|new_market_entry');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `appointment_state_code` SET TAGS ('dbx_business_glossary_term' = 'Appointment State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `appointment_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `appointment_state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `appointment_status` SET TAGS ('dbx_business_glossary_term' = 'Appointment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `appointment_status` SET TAGS ('dbx_value_regex' = 'active|pending|suspended|terminated|expired|inactive');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `appointment_tier` SET TAGS ('dbx_business_glossary_term' = 'Appointment Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `appointment_tier` SET TAGS ('dbx_value_regex' = 'platinum|gold|silver|bronze|standard');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `appointment_type` SET TAGS ('dbx_business_glossary_term' = 'Appointment Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `appointment_type` SET TAGS ('dbx_value_regex' = 'direct|sub_producer|managing_general_agent|surplus_lines|reinsurance_intermediary');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `binding_authority_flag` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Eligible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `default_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Default Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `doi_reported_date` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Reported Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `eo_insurance_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Insurance Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `eo_minimum_coverage_amount` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Minimum Coverage Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `lob_category` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `lob_category` SET TAGS ('dbx_value_regex' = 'personal_lines|commercial_lines|specialty_lines|life_health');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `lob_description` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `nipr_transaction_number` SET TAGS ('dbx_business_glossary_term' = 'National Insurance Producer Registry (NIPR) Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `npn` SET TAGS ('dbx_business_glossary_term' = 'National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `npn` SET TAGS ('dbx_value_regex' = '^[0-9]{10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `regulatory_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `renewal_flag` SET TAGS ('dbx_business_glossary_term' = 'Renewal Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `resident_state_code` SET TAGS ('dbx_business_glossary_term' = 'Resident State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `resident_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `resident_state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `surplus_lines_flag` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `surplus_lines_license_number` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines License Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `surplus_lines_license_number` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Termination Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `termination_for_cause_flag` SET TAGS ('dbx_business_glossary_term' = 'Termination For Cause Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `termination_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `termination_reason_code` SET TAGS ('dbx_value_regex' = 'voluntary|for_cause|license_revoked|non_renewal|business_closure|regulatory_action');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `termination_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `writing_company_code` SET TAGS ('dbx_business_glossary_term' = 'Writing Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `agency_bill_flag` SET TAGS ('dbx_business_glossary_term' = 'Agency Bill Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `appointment_required` SET TAGS ('dbx_business_glossary_term' = 'Producer Appointment Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `background_check_required` SET TAGS ('dbx_business_glossary_term' = 'Background Check Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `binding_authority_flag` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `channel_code` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `channel_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `channel_description` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `channel_name` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `channel_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `channel_priority_rank` SET TAGS ('dbx_business_glossary_term' = 'Channel Priority Rank');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `channel_status` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `channel_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending|terminated');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `channel_subtype` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Subtype');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `channel_type` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `channel_type` SET TAGS ('dbx_value_regex' = 'captive|independent|broker|direct|mga|wholesale');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `commission_schedule_code` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `commission_schedule_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,15}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Eligible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `continuing_education_required` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `default_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Default Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `default_commission_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `direct_bill_flag` SET TAGS ('dbx_business_glossary_term' = 'Direct Bill Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Channel Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `eo_insurance_required` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Insurance Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Channel Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `lob_authorizations` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Authorizations');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `minimum_eo_coverage_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Errors and Omissions (E&O) Coverage Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `regulatory_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `surplus_lines_eligible` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Eligible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `target_market_segment` SET TAGS ('dbx_business_glossary_term' = 'Target Market Segment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Channel Termination Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `writing_company_code` SET TAGS ('dbx_business_glossary_term' = 'Writing Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ALTER COLUMN `writing_company_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` SET TAGS ('dbx_subdomain' = 'compensation_processing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `superseded_by_schedule_commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Schedule ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `territory_id` SET TAGS ('dbx_business_glossary_term' = 'Territory Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `base_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Base Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `bonus_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Bonus Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `chargeback_period_days` SET TAGS ('dbx_business_glossary_term' = 'Chargeback Period Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `chargeback_provision` SET TAGS ('dbx_business_glossary_term' = 'Chargeback Provision');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `commission_basis` SET TAGS ('dbx_business_glossary_term' = 'Commission Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `commission_basis` SET TAGS ('dbx_value_regex' = 'written_premium|earned_premium|net_premium|gross_premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `contingent_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `coverage_type_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `loss_ratio_threshold` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR) Threshold');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `maximum_premium_threshold` SET TAGS ('dbx_business_glossary_term' = 'Maximum Premium Threshold');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `minimum_premium_threshold` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Threshold');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `new_business_credit_rate` SET TAGS ('dbx_business_glossary_term' = 'New Business (NB) Credit Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `override_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Override Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `payment_timing` SET TAGS ('dbx_business_glossary_term' = 'Payment Timing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `payment_timing` SET TAGS ('dbx_value_regex' = 'immediate|monthly|quarterly|annual|upon_collection');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `renewal_credit_rate` SET TAGS ('dbx_business_glossary_term' = 'Renewal (REN) Credit Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `retention_rate_threshold` SET TAGS ('dbx_business_glossary_term' = 'Retention Rate Threshold');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `schedule_code` SET TAGS ('dbx_business_glossary_term' = 'Schedule Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `schedule_name` SET TAGS ('dbx_business_glossary_term' = 'Schedule Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `schedule_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_business_glossary_term' = 'Schedule Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_value_regex' = 'draft|active|suspended|expired|terminated');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `schedule_type` SET TAGS ('dbx_business_glossary_term' = 'Schedule Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `schedule_type` SET TAGS ('dbx_value_regex' = 'standard|override|contingent|bonus|special');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `tier_level` SET TAGS ('dbx_business_glossary_term' = 'Tier Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Transaction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'NB|REN|END|CAN|RI');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `volume_threshold_policy_count` SET TAGS ('dbx_business_glossary_term' = 'Volume Threshold Policy Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `writing_company_code` SET TAGS ('dbx_business_glossary_term' = 'Writing Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` SET TAGS ('dbx_subdomain' = 'compensation_processing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `commission_rule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Rule ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Rule Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `base_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Base Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `chargeback_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Chargeback Eligible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `chargeback_period_days` SET TAGS ('dbx_business_glossary_term' = 'Chargeback Period Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `commission_basis_code` SET TAGS ('dbx_business_glossary_term' = 'Commission Basis Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `commission_basis_code` SET TAGS ('dbx_value_regex' = 'written|earned|billed|collected');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `commission_split_flag` SET TAGS ('dbx_business_glossary_term' = 'Commission Split Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `contingent_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Rule Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Rule Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `loss_ratio_threshold` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR) Threshold');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `maximum_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `minimum_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `override_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Override Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `payment_timing_code` SET TAGS ('dbx_business_glossary_term' = 'Commission Payment Timing Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `payment_timing_code` SET TAGS ('dbx_value_regex' = 'immediate|monthly|quarterly|annual');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `policy_state_code` SET TAGS ('dbx_business_glossary_term' = 'Policy State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `policy_state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `premium_tier_maximum` SET TAGS ('dbx_business_glossary_term' = 'Premium Tier Maximum');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `premium_tier_minimum` SET TAGS ('dbx_business_glossary_term' = 'Premium Tier Minimum');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `producer_type_code` SET TAGS ('dbx_business_glossary_term' = 'Producer Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `producer_type_code` SET TAGS ('dbx_value_regex' = 'agent|broker|mga|direct');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `retention_rate_threshold` SET TAGS ('dbx_business_glossary_term' = 'Retention Rate Threshold');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `rule_description` SET TAGS ('dbx_business_glossary_term' = 'Commission Rule Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `rule_name` SET TAGS ('dbx_business_glossary_term' = 'Commission Rule Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `rule_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `rule_notes` SET TAGS ('dbx_business_glossary_term' = 'Commission Rule Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `rule_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Rule Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `rule_status` SET TAGS ('dbx_business_glossary_term' = 'Commission Rule Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `rule_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|expired|superseded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `source_rule_reference` SET TAGS ('dbx_business_glossary_term' = 'Source Rule Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `split_percentage` SET TAGS ('dbx_business_glossary_term' = 'Commission Split Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `transaction_type_code` SET TAGS ('dbx_business_glossary_term' = 'Transaction Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `transaction_type_code` SET TAGS ('dbx_value_regex' = 'NB|REN|END|CAN|RI|NR');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `volume_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Volume Threshold Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `writing_company_code` SET TAGS ('dbx_business_glossary_term' = 'Writing Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` SET TAGS ('dbx_subdomain' = 'compensation_processing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `commission_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `commission_rule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Rule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `commission_statement_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Statement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `original_transaction_commission_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Original Commission Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Adjustment Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `claw_back_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Claw-Back Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `commission_basis` SET TAGS ('dbx_business_glossary_term' = 'Commission Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `commission_basis` SET TAGS ('dbx_value_regex' = 'gwp|nwp|ep|flat_fee|sliding_scale');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `contingent_commission_flag` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `earned_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Earned Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Commission Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `net_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Commission Transaction Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `npn` SET TAGS ('dbx_business_glossary_term' = 'National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `override_flag` SET TAGS ('dbx_business_glossary_term' = 'Commission Override Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Commission Payment Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Commission Payment Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'ach|wire|check|eft|direct_deposit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Commission Payment Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Commission Payment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'unpaid|scheduled|paid|withheld|disputed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `policy_transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `policy_transaction_type` SET TAGS ('dbx_value_regex' = 'new_business|renewal|endorsement|cancellation|reinstatement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `reversal_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Commission Reversal Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `reversal_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Commission Reversal Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `source_transaction_reference` SET TAGS ('dbx_business_glossary_term' = 'Source Transaction Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `split_percentage` SET TAGS ('dbx_business_glossary_term' = 'Commission Split Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `tax_withholding_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Withholding Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Commission Transaction Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `transaction_number` SET TAGS ('dbx_business_glossary_term' = 'Commission Transaction Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_business_glossary_term' = 'Commission Transaction Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_value_regex' = 'pending|approved|paid|voided|disputed|reconciled');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `transaction_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Commission Transaction Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Commission Transaction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'earned|claw_back|adjustment|reversal|advance|chargeback');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `writing_company_code` SET TAGS ('dbx_business_glossary_term' = 'Writing Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` SET TAGS ('dbx_subdomain' = 'compensation_processing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `commission_statement_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Statement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `chargeback_amount` SET TAGS ('dbx_business_glossary_term' = 'Chargeback Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `contingent_commission` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `dispute_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `dispute_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `endorsement_commission` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (END) Commission');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `eo_premium_deduction` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Premium Deduction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `net_commission_payable` SET TAGS ('dbx_business_glossary_term' = 'Net Commission Payable');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `new_business_commission` SET TAGS ('dbx_business_glossary_term' = 'New Business (NB) Commission');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Statement Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `npn` SET TAGS ('dbx_business_glossary_term' = 'National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'ach|wire|check|eft|direct_deposit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'unpaid|pending|paid|partially_paid|failed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `policy_count` SET TAGS ('dbx_business_glossary_term' = 'Policy Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `renewal_commission` SET TAGS ('dbx_business_glossary_term' = 'Renewal (REN) Commission');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_date` SET TAGS ('dbx_business_glossary_term' = 'Statement Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_delivery_method` SET TAGS ('dbx_business_glossary_term' = 'Statement Delivery Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_delivery_method` SET TAGS ('dbx_value_regex' = 'email|mail|portal|fax');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Statement Document Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_number` SET TAGS ('dbx_business_glossary_term' = 'Statement Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Statement Period End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Statement Period Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_status` SET TAGS ('dbx_business_glossary_term' = 'Statement Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_status` SET TAGS ('dbx_value_regex' = 'draft|issued|paid|partially_paid|disputed|cancelled');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_type` SET TAGS ('dbx_business_glossary_term' = 'Statement Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_type` SET TAGS ('dbx_value_regex' = 'regular|supplemental|correction|final');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `total_adjustments` SET TAGS ('dbx_business_glossary_term' = 'Total Adjustments');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `total_commission_earned` SET TAGS ('dbx_business_glossary_term' = 'Total Commission Earned');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `total_deductions` SET TAGS ('dbx_business_glossary_term' = 'Total Deductions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `transaction_count` SET TAGS ('dbx_business_glossary_term' = 'Transaction Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `writing_company_code` SET TAGS ('dbx_business_glossary_term' = 'Writing Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `underwriting_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Authority Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `territory_id` SET TAGS ('dbx_business_glossary_term' = 'Territory Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Authority Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `audit_frequency` SET TAGS ('dbx_business_glossary_term' = 'Audit Frequency');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `audit_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|per_policy');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `audit_required` SET TAGS ('dbx_business_glossary_term' = 'Audit Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `authority_status` SET TAGS ('dbx_business_glossary_term' = 'Authority Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `authority_status` SET TAGS ('dbx_value_regex' = 'active|suspended|revoked|expired|pending|inactive');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `authority_type` SET TAGS ('dbx_business_glossary_term' = 'Authority Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `authority_type` SET TAGS ('dbx_value_regex' = 'binding|quoting|referral|limited_binding|full_binding|conditional');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `blanket_coverage_allowed` SET TAGS ('dbx_business_glossary_term' = 'Blanket Coverage Allowed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `cancellation_allowed` SET TAGS ('dbx_business_glossary_term' = 'Cancellation (CAN) Allowed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `coinsurance_allowed` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Allowed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `construction_restrictions` SET TAGS ('dbx_business_glossary_term' = 'Construction Restrictions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `deductible_max` SET TAGS ('dbx_business_glossary_term' = 'Maximum Deductible');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `deductible_min` SET TAGS ('dbx_business_glossary_term' = 'Minimum Deductible');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Authority Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `eligible_states` SET TAGS ('dbx_business_glossary_term' = 'Eligible States');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `endorsement_allowed` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (END) Allowed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `excluded_states` SET TAGS ('dbx_business_glossary_term' = 'Excluded States');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Authority Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `limit_tier` SET TAGS ('dbx_business_glossary_term' = 'Limit Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `limit_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3|tier_4|unlimited');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `max_premium_threshold` SET TAGS ('dbx_business_glossary_term' = 'Maximum Premium Threshold');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `max_single_risk_limit` SET TAGS ('dbx_business_glossary_term' = 'Maximum Single Risk Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `max_tiv` SET TAGS ('dbx_business_glossary_term' = 'Maximum Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `min_premium_threshold` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Threshold');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `new_business_allowed` SET TAGS ('dbx_business_glossary_term' = 'New Business (NB) Allowed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Authority Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `occupancy_restrictions` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Restrictions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `protection_class_max` SET TAGS ('dbx_business_glossary_term' = 'Maximum Protection Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `protection_class_min` SET TAGS ('dbx_business_glossary_term' = 'Minimum Protection Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `referral_criteria` SET TAGS ('dbx_business_glossary_term' = 'Referral Criteria');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `reinstatement_allowed` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement (RI) Allowed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `renewal_allowed` SET TAGS ('dbx_business_glossary_term' = 'Renewal (REN) Allowed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `renewal_eligible` SET TAGS ('dbx_business_glossary_term' = 'Renewal Eligible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `revocation_date` SET TAGS ('dbx_business_glossary_term' = 'Authority Revocation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `revocation_reason` SET TAGS ('dbx_business_glossary_term' = 'Revocation Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `risk_class_restrictions` SET TAGS ('dbx_business_glossary_term' = 'Risk Class Restrictions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference Identifier (ID)');
