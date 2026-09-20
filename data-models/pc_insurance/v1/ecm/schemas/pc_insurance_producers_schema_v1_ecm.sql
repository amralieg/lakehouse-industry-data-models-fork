-- Schema for Domain: producers | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-20 14:33:31

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_blog_v499`.`producers` COMMENT 'Provisional description for user-specified domain producers. Awaiting a generated description of what this domain owns.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` (
    `producers_producer_id` BIGINT COMMENT 'Unique surrogate identifier for each licensed insurance producer record. Primary key. One row per producer.',
    `distribution_channel_id` BIGINT COMMENT 'Reference to the distribution channel through which this producer operates (e.g., independent agent, direct, broker, MGA).',
    `party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Every producer is a party in the master registry. Links producer identity to KYC/OFAC screening, fraud indicators, license verification, contact management, and regulatory reporting.',
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
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Agencies have cat exposure concentration limits by zone. Underwriting monitors agency-level TIV accumulation in cat zones to enforce diversification requirements and prevent',
    `distribution_channel_id` BIGINT COMMENT 'Foreign key linking to producers.distribution_channel. Business justification: Agencies operate through a specific distribution channel (captive, independent, broker, direct). Replace STRING distribution_channel_code with FK. N:1 relationship.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Agencies are assigned service territories defined in geography hierarchy. Used for producer appointment validation (ensuring producer is appointed in geography where risk is',
    `parent_agency_id` BIGINT COMMENT 'Reference to the parent agency for hierarchical relationships such as MGA to sub-producer or wholesale to retail agency networks.',
    `party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Every agency is a legal entity in party registry. Links agency to organizational KYC, FEIN/NAIC validation, address standardization, OFAC screening, and consolidated party view.',
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
    `principal_address_line1` STRING COMMENT 'First line of the principal business address for the agency as registered with the state Department of Insurance (DOI).',
    `principal_address_line2` STRING COMMENT 'Second line of the principal business address including suite, floor, or building number.',
    `principal_city` STRING COMMENT 'City name for the principal business address of the agency.',
    `principal_country_code` STRING COMMENT 'Three-letter ISO country code for the principal business address of the agency.. Valid values are `^[A-Z]{3}$`',
    `principal_county` STRING COMMENT 'County name for the principal business address used for territory and catastrophe exposure aggregation.',
    `principal_postal_code` STRING COMMENT 'ZIP or ZIP+4 postal code for the principal business address of the agency.. Valid values are `^d{5}(-d{4})?$`',
    `principal_state_code` STRING COMMENT 'Two-letter state code for the principal business address and domicile state of the agency.. Valid values are `^[A-Z]{2}$`',
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
    `license_number` STRING COMMENT 'State-issued license number. Format varies by state Department of Insurance.',
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
    `agency_producers_producer_id` BIGINT COMMENT 'Foreign key to the producer in this agency relationship.',
    `agency_reporting_manager_producer_producers_producer_id` BIGINT COMMENT 'Producer ID of the direct manager or supervisor for this producer within the agency.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: The producer-agency affiliation relationship defines the commission schedule for that specific employment/contractor arrangement.',
    `party_id` BIGINT COMMENT 'Foreign key to the party master record for the producer.',
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
    `prior_appointment_id` BIGINT COMMENT 'Reference to the previous appointment record if this is a renewal or replacement.',
    `producer_license_id` BIGINT COMMENT 'Foreign key linking to producers.producer_license. Business justification: Appointments are granted based on a valid license in that state and LOB. Links the appointment to the underlying license that authorizes the producer to sell. N:1 relationship.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer who holds this appointment.',
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
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Commission rates vary by catastrophe zone to reflect risk-based pricing and producer incentives.',
    `distribution_channel_id` BIGINT COMMENT 'Foreign key linking to producers.distribution_channel. Business justification: Commission schedules are defined for specific distribution channels. Replace STRING distribution_channel_code with FK to distribution_channel. N:1 relationship.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Commission schedules are structured by LOB for rate differentiation, regulatory compliance, and profitability management.',
    `producers_producer_id` BIGINT COMMENT 'Producer to whom this commission schedule applies.',
    `superseded_by_schedule_id` BIGINT COMMENT 'Identifier of the commission schedule that replaces this one, if superseded.',
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
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for commission amounts and thresholds. Typically USD for US operations.',
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
    `coverage_type_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_type. Business justification: Commission rates vary by coverage type in P&C (e.g., 15% for auto liability, 12% for property, 8% for workers comp).',
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
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for commission amounts and thresholds.. Valid values are `USD|CAD|EUR|GBP|AUD`',
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
    `agency_id` BIGINT COMMENT 'Foreign key to the agency associated with this commission.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Foreign key to the accounting period in which this commission is recognized.',
    `commission_rule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_rule. Business justification: Each transaction is calculated by applying a specific rule within a schedule. The rule specifies the exact rate, tier, LOB, and conditions that produced the commission amount.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: Each transaction is calculated using a specific commission schedule. Replace STRING commission_schedule_code with FK to commission_schedule. N:1 relationship.',
    `commission_statement_id` BIGINT COMMENT 'Foreign key linking to producers.commission_statement. Business justification: Transactions roll up into periodic statements. Each transaction appears on exactly one statement for a given billing period. Standard transaction-to-statement aggregation link.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Commission transactions in multi-currency operations require currency reference for financial reporting, GL posting, and payment processing.',
    `original_transaction_id` BIGINT COMMENT 'Foreign key to the original commission transaction if this is a reversal, adjustment, or claw-back.',
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
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Accounting period to which this commission statement is assigned for financial reporting.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: Statements are generated based on a specific commission schedule that defines the rates and rules. N:1 relationship.',
    `distribution_channel_id` BIGINT COMMENT 'Foreign key linking to producers.distribution_channel. Business justification: Statements may be segmented by distribution channel for reporting and reconciliation. Replace STRING distribution_channel_code with FK. N:1 relationship.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Commission statements aggregate transactions by LOB for producer reporting, tax reporting (1099), and reconciliation.',
    `producers_producer_id` BIGINT COMMENT 'Producer or agent to whom this statement is issued.',
    `chargeback_amount` DECIMAL(18,2) COMMENT 'Total commission chargebacks for cancelled or returned policies during the statement period.',
    `contingent_commission` DECIMAL(18,2) COMMENT 'Performance-based bonus commission earned based on loss ratio, volume, or other criteria.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this commission statement record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts on this statement.. Valid values are `USD|CAD|GBP|EUR|AUD`',
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

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` (
    `commission_payment_id` BIGINT COMMENT 'Unique identifier for the commission payment record. Primary key.',
    `agency_id` BIGINT COMMENT 'Reference to the agency receiving this commission payment, if applicable.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this payment was recorded for financial reporting.',
    `commission_statement_id` BIGINT COMMENT 'Reference to the commission statement that this payment settles or partially settles.',
    `payee_party_id` BIGINT COMMENT 'Reference to the party master record for the payee receiving this disbursement.',
    `producers_producer_id` BIGINT COMMENT 'User identifier of the person who approved this commission payment for disbursement.',
    `ach_trace_number` STRING COMMENT 'ACH trace number for electronic payments, used for reconciliation and tracking.',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time when this commission payment was approved for disbursement.',
    `bank_account_number` STRING COMMENT 'Bank account number to which the payment was disbursed for electronic payments.',
    `bank_routing_number` STRING COMMENT 'Nine-digit ABA routing number for the payee bank account.. Valid values are `^[0-9]{9}$`',
    `check_number` STRING COMMENT 'Check number if payment method is check. Null for electronic payments.',
    `cleared_date` DATE COMMENT 'Date the payment cleared the bank or was confirmed as received by the payee.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this commission payment record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the payment amount.. Valid values are `^[A-Z]{3}$`',
    `form_1099_reportable_flag` BOOLEAN COMMENT 'Indicates whether this payment is reportable on IRS Form 1099-MISC or 1099-NEC for the producer.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this commission payment expense is posted.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this commission payment record was last modified.',
    `net_payment_amount` DECIMAL(18,2) COMMENT 'Net amount disbursed to the payee after all withholdings and adjustments.',
    `payee_address_line1` STRING COMMENT 'First line of the payee mailing address for check delivery or record keeping.',
    `payee_address_line2` STRING COMMENT 'Second line of the payee mailing address, such as suite or apartment number.',
    `payee_city` STRING COMMENT 'City of the payee mailing address.',
    `payee_country_code` STRING COMMENT 'Three-letter ISO country code for the payee mailing address.. Valid values are `^[A-Z]{3}$`',
    `payee_name` STRING COMMENT 'Full legal name of the payee as it appears on the payment instrument.',
    `payee_postal_code` STRING COMMENT 'Postal or ZIP code for the payee mailing address.',
    `payee_state_code` STRING COMMENT 'Two-letter state or province code for the payee mailing address.. Valid values are `^[A-Z]{2}$`',
    `payment_amount` DECIMAL(18,2) COMMENT 'Gross amount of the commission payment before any adjustments or withholdings.',
    `payment_date` DATE COMMENT 'Date the commission payment was issued or disbursed to the producer or agency.',
    `payment_memo` STRING COMMENT 'Free-text memo or note describing the purpose or details of this commission payment.',
    `payment_method` STRING COMMENT 'Method used to disburse the commission payment to the payee.. Valid values are `check|ach|wire|eft|direct_deposit|paypal`',
    `payment_number` STRING COMMENT 'Business-assigned unique number for this commission payment, used for tracking and reconciliation.',
    `payment_status` STRING COMMENT 'Current lifecycle status of the commission payment.. Valid values are `pending|approved|issued|cleared|cancelled|voided`',
    `reconciliation_date` DATE COMMENT 'Date on which this payment was reconciled with bank statements or producer acknowledgment.',
    `reconciliation_status` STRING COMMENT 'Status indicating whether this payment has been reconciled with bank statements and producer records.. Valid values are `unreconciled|reconciled|disputed|adjusted`',
    `reissue_flag` BOOLEAN COMMENT 'Indicates whether this payment is a reissue of a previously voided or lost payment.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system that originated this commission payment record.',
    `source_system_reference_code` STRING COMMENT 'Unique identifier for this payment in the source operational system, used for traceability.',
    `tax_year` BIGINT COMMENT 'Calendar year for which this payment is reported for tax purposes, used for 1099 reporting.',
    `void_date` DATE COMMENT 'Date the payment was voided or cancelled, if applicable.',
    `void_reason_code` STRING COMMENT 'Code indicating the reason the payment was voided, such as stop payment, duplicate, or error.',
    `wire_reference_number` STRING COMMENT 'Wire transfer reference number for wire payments, used for reconciliation.',
    `withholding_amount` DECIMAL(18,2) COMMENT 'Total amount withheld from the payment for tax, chargebacks, or other deductions.',
    CONSTRAINT pk_commission_payment PRIMARY KEY(`commission_payment_id`)
) COMMENT 'Actual disbursement made to a producer or agency against a commission statement. One row per payment. Records payment date, amount, payment method, check or ACH reference, and reconciliation status.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` (
    `contingent_commission_id` BIGINT COMMENT 'Unique identifier for the contingent commission agreement. Primary key.',
    `agency_id` BIGINT COMMENT 'Agency participating in the contingent commission agreement.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Contingent commission agreements are LOB-specific for performance measurement against loss ratio, combined ratio, and growth targets.',
    `premium_accounting_period_id` BIGINT COMMENT 'Foreign key linking to premium.premium_accounting_period. Business justification: Contingent commissions are earned based on performance period results but must be booked in specific carrier accounting periods for GL posting, statutory reporting, and GAAP',
    `producers_producer_id` BIGINT COMMENT 'Producer associated with the contingent commission agreement, if applicable.',
    `actual_combined_ratio` DECIMAL(5,4) COMMENT 'Actual combined ratio achieved during the performance period. Expressed as decimal.',
    `actual_growth_rate` DECIMAL(5,4) COMMENT 'Actual premium growth rate achieved during the performance period. Expressed as decimal.',
    `actual_loss_ratio` DECIMAL(5,4) COMMENT 'Actual loss ratio achieved during the performance period. Expressed as decimal.',
    `actual_retention_rate` DECIMAL(5,4) COMMENT 'Actual policy retention rate achieved during the performance period. Expressed as decimal.',
    `agreement_name` STRING COMMENT 'Descriptive name of the contingent commission agreement.',
    `agreement_number` STRING COMMENT 'Business identifier for the contingent commission agreement.',
    `agreement_status` STRING COMMENT 'Current lifecycle status of the contingent commission agreement.. Valid values are `draft|active|suspended|terminated|expired|pending_approval`',
    `agreement_type` STRING COMMENT 'Type of contingent commission agreement structure.. Valid values are `profit_sharing|volume_bonus|loss_ratio_based|growth_incentive|retention_bonus|combined_ratio_based`',
    `approval_date` DATE COMMENT 'Date when the contingent commission was approved for payment.',
    `approval_status` STRING COMMENT 'Approval status of the contingent commission calculation and payment.. Valid values are `pending|approved|rejected|under_review`',
    `approved_by` STRING COMMENT 'Name or identifier of the person who approved the contingent commission.',
    `calculation_basis` STRING COMMENT 'Basis for calculating contingent commission. GWP (Gross Written Premium), NWP (Net Written Premium), EP (Earned Premium).. Valid values are `gwp|nwp|ep|policy_count|retention_rate|new_business_premium`',
    `commission_rate` DECIMAL(5,4) COMMENT 'Contingent commission rate applied to the calculation basis. Expressed as decimal.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the contingent commission agreement record was first created.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for commission amounts.. Valid values are `^[A-Z]{3}$`',
    `earned_commission_amount` DECIMAL(15,2) COMMENT 'Total contingent commission amount earned for the performance period.',
    `effective_date` DATE COMMENT 'Date when the contingent commission agreement becomes binding.',
    `expiration_date` DATE COMMENT 'Date when the contingent commission agreement expires or terminates.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the contingent commission agreement record was last updated.',
    `maximum_commission_amount` DECIMAL(15,2) COMMENT 'Maximum contingent commission amount payable under the agreement.',
    `minimum_premium_threshold` DECIMAL(15,2) COMMENT 'Minimum premium volume required to qualify for contingent commission.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code for the writing company.. Valid values are `^[0-9]{5}$`',
    `notes` STRING COMMENT 'Additional notes or comments regarding the contingent commission agreement.',
    `outstanding_commission_amount` DECIMAL(15,2) COMMENT 'Contingent commission amount earned but not yet paid.',
    `paid_commission_amount` DECIMAL(15,2) COMMENT 'Total contingent commission amount paid to date.',
    `performance_met_flag` BOOLEAN COMMENT 'Indicates whether performance targets were met for contingent commission eligibility.',
    `performance_period_end_date` DATE COMMENT 'End date of the performance measurement period for the agreement.',
    `performance_period_start_date` DATE COMMENT 'Start date of the performance measurement period for the agreement.',
    `settlement_date` DATE COMMENT 'Date when contingent commission is calculated and settled for the performance period.',
    `settlement_frequency` STRING COMMENT 'Frequency at which contingent commission is calculated and paid.. Valid values are `annual|semi_annual|quarterly|monthly`',
    `source_system_code` STRING COMMENT 'Code identifying the source system that created or manages this agreement record.',
    `source_system_reference_code` STRING COMMENT 'Unique identifier from the source system for traceability and reconciliation.',
    `target_combined_ratio` DECIMAL(5,4) COMMENT 'Target combined ratio threshold for contingent commission eligibility. Expressed as decimal.',
    `target_growth_rate` DECIMAL(5,4) COMMENT 'Target premium growth rate for contingent commission eligibility. Expressed as decimal (e.g., 0.1000 for 10%).',
    `target_loss_ratio` DECIMAL(5,4) COMMENT 'Target loss ratio threshold for contingent commission eligibility. Expressed as decimal (e.g., 0.6500 for 65%).',
    `target_retention_rate` DECIMAL(5,4) COMMENT 'Target policy retention rate for contingent commission eligibility. Expressed as decimal.',
    `termination_reason` STRING COMMENT 'Reason for termination of the contingent commission agreement, if applicable.',
    `writing_company_code` STRING COMMENT 'Insurance company code offering the contingent commission agreement.',
    CONSTRAINT pk_contingent_commission PRIMARY KEY(`contingent_commission_id`)
) COMMENT 'Profit-sharing or contingent commission agreement between the insurer and an agency. One row per agreement per performance period. Stores target LR, target growth, earned amount, and calculation basis for year-end settlement.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` (
    `producers_producer_policy_id` BIGINT COMMENT 'Unique identifier for the producer-policy association record. Primary key.',
    `agency_id` BIGINT COMMENT 'Foreign key to the agency entity the producer represents on this policy.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: The producer-policy assignment specifies the commission schedule for that policy. Replace STRING commission_schedule_code with FK to commission_schedule. N:1 relationship.',
    `distribution_channel_id` BIGINT COMMENT 'Foreign key linking to producers.distribution_channel. Business justification: Producer-policy assignments occur through a specific distribution channel. Replace STRING distribution_channel_code with FK to distribution_channel. N:1 relationship.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Producer-policy assignments require LOB reference for commission rate lookup, authority verification, and license validation.',
    `current_policy_id` BIGINT COMMENT 'Foreign key to the policy record this producer is associated with.',
    `prior_producer_policy_id` BIGINT COMMENT 'Foreign key to the previous producer-policy record this assignment replaces, used to maintain historical chain of producer assignments.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key to the producer (agent, broker, MGA) associated with this policy.',
    `superseded_by_producer_policy_producers_producer_policy_id` BIGINT COMMENT 'Foreign key to the producer-policy record that supersedes this assignment, used to track broker of record changes and producer reassignments.',
    `appointment_verification_date` DATE COMMENT 'Date when the producer appointment was last verified for this policy.',
    `appointment_verified_flag` BOOLEAN COMMENT 'Indicates whether the producer appointment with the writing company has been verified for this policy.',
    `assignment_notes` STRING COMMENT 'Free-text notes or comments regarding this producer-policy assignment, including special arrangements or exceptions.',
    `assignment_reason_code` STRING COMMENT 'Code indicating the reason for this producer assignment: initial sale, broker of record change, servicing transfer, or split commission arrangement.',
    `assignment_source_code` STRING COMMENT 'Source system or process that created this producer-policy assignment: policy issuance, broker of record change, endorsement, renewal, or manual adjustment.. Valid values are `policy_issuance|bor_change|endorsement|renewal|manual_adjustment`',
    `assignment_status` STRING COMMENT 'Current lifecycle status of the producer assignment to this policy.. Valid values are `active|inactive|pending|terminated|suspended`',
    `binding_authority_flag` BOOLEAN COMMENT 'Indicates whether the producer has binding authority to commit coverage on behalf of the carrier for this policy.',
    `binding_authority_limit` DECIMAL(15,2) COMMENT 'Maximum premium or coverage limit the producer is authorized to bind without underwriter approval for this policy.',
    `commission_basis_code` STRING COMMENT 'Basis on which commission is calculated: written premium, earned premium, net premium, gross premium, or policy fee.. Valid values are `written_premium|earned_premium|net_premium|gross_premium|policy_fee`',
    `commission_rate` DECIMAL(5,4) COMMENT 'Commission rate percentage applicable to this producer for this policy, expressed as a decimal (e.g., 0.1250 for 12.50%).',
    `commission_split_percentage` DECIMAL(5,2) COMMENT 'Percentage of total commission allocated to this producer in split-commission scenarios. Sum across all producers on a policy equals 100.00.',
    `contingent_commission_eligible_flag` BOOLEAN COMMENT 'Indicates whether this producer-policy assignment is eligible for contingent or bonus commission based on performance metrics.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this producer-policy association record was first created in the system.',
    `effective_date` DATE COMMENT 'Date when the producer assignment to this policy becomes effective.',
    `expiration_date` DATE COMMENT 'Date when the producer assignment to this policy expires or is terminated. Null for active assignments.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this producer-policy association record was last updated.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code identifying the writing carrier for regulatory reporting purposes.. Valid values are `^[0-9]{5}$`',
    `npn` STRING COMMENT 'National Producer Number assigned by NIPR to uniquely identify the producer across all states.. Valid values are `^[0-9]{10}$`',
    `override_commission_flag` BOOLEAN COMMENT 'Indicates whether the commission rate for this producer-policy assignment overrides the default schedule rate.',
    `override_reason_code` STRING COMMENT 'Code indicating the reason for commission rate override, if applicable.',
    `policy_state_code` STRING COMMENT 'Two-letter state code where the policy is domiciled or written, used for regulatory and commission compliance.. Valid values are `^[A-Z]{2}$`',
    `policy_transaction_type` STRING COMMENT 'Type of policy transaction at the time this producer assignment was established: new business, renewal, endorsement, cancellation, or reinstatement.. Valid values are `new_business|renewal|endorsement|cancellation|reinstatement`',
    `primary_producer_flag` BOOLEAN COMMENT 'Indicates whether this producer is the primary producer of record for the policy. Only one producer per policy should have this flag set to true.',
    `producer_license_number` STRING COMMENT 'State-issued license number of the producer for the jurisdiction where the policy is written.',
    `producer_license_state_code` STRING COMMENT 'Two-letter state code where the producer holds the license applicable to this policy.. Valid values are `^[A-Z]{2}$`',
    `producer_role_code` STRING COMMENT 'Role the producer plays on this policy: writing agent, servicing agent, broker of record, sub-producer, referring agent, or managing general agent.. Valid values are `writing_agent|servicing_agent|broker_of_record|sub_producer|referring_agent|MGA`',
    `producer_role_description` STRING COMMENT 'Detailed description of the producer role and responsibilities on this policy.',
    `servicing_producer_flag` BOOLEAN COMMENT 'Indicates whether this producer is responsible for ongoing policy servicing and customer support.',
    `source_system_code` STRING COMMENT 'Code identifying the source system that originated this producer-policy assignment record (e.g., PAS, agency management system).',
    `source_system_reference_code` STRING COMMENT 'Unique identifier or reference key from the source system for traceability and reconciliation purposes.',
    `termination_date` DATE COMMENT 'Date when the producer assignment was terminated. Null for active assignments.',
    `termination_reason_code` STRING COMMENT 'Code indicating the reason for termination of this producer assignment: broker of record change, policy cancellation, producer termination, or voluntary withdrawal.',
    `writing_company_code` STRING COMMENT 'Code identifying the insurance company or carrier that issued the policy.',
    CONSTRAINT pk_producers_producer_policy PRIMARY KEY(`producers_producer_policy_id`)
) COMMENT 'Association linking a producer to a policy with role (writing agent, servicing agent, broker of record). One row per producer-policy-role. Supports split-commission scenarios and broker-of-record changes with effective dating.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` (
    `underwriting_authority_id` BIGINT COMMENT 'Unique identifier for the underwriting authority grant record.',
    `agency_id` BIGINT COMMENT 'Reference to the agency organization holding this authority.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Binding authority is explicitly restricted by catastrophe zone. Producers in coastal wind zones or earthquake zones require higher authority levels or mandatory referral.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Binding authority is granted per peril (wind, earthquake, flood, wildfire). Producers must have explicit peril-specific authority to bind coverage.',
    `coverage_type_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_type. Business justification: Underwriting authority rules specify which coverage types a producer/agency can bind without referral.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Authority grants are LOB-specific per regulatory and risk management requirements. LOB reference provides admitted/surplus lines status, state filing requirements, and default policy',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer or agent receiving this binding authority.',
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
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary thresholds and limits in this authority grant.. Valid values are `USD|CAD|EUR|GBP|AUD|MXN`',
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

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` (
    `producer_performance_id` BIGINT COMMENT 'Unique identifier for the producer performance record. Primary key.',
    `agency_id` BIGINT COMMENT 'Foreign key to the agency this producer is affiliated with during the evaluation period.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Performance metrics are measured and reported by LOB for tier assignment, contingent commission eligibility, and territory management.',
    `premium_accounting_period_id` BIGINT COMMENT 'Foreign key linking to premium.premium_accounting_period. Business justification: Producer performance metrics (GWP, loss ratio, retention rate) must align with carrier accounting periods for accurate commission calculations, contingent commission',
    `producer_tier_id` BIGINT COMMENT 'Foreign key linking to producers.producer_tier. Business justification: Performance evaluations assign a tier to the producer based on performance criteria. Replace STRING tier_assignment and tier_definition_code with FK to producer_tier. N:1 relationship.',
    `producers_producer_id` BIGINT COMMENT 'Identifier of the person or system that conducted the performance evaluation.',
    `approval_date` DATE COMMENT 'Date when the performance evaluation was approved by management.',
    `average_claim_severity` DECIMAL(18,2) COMMENT 'Average incurred loss per claim for policies produced by the producer during the evaluation period.',
    `average_policy_premium` DECIMAL(18,2) COMMENT 'Average written premium per policy for the producer during the evaluation period.',
    `cancellation_count` BIGINT COMMENT 'Number of policies cancelled during the evaluation period for this producer.',
    `claim_count` BIGINT COMMENT 'Number of claims reported for policies produced by the producer during the evaluation period.',
    `claim_frequency` DECIMAL(5,4) COMMENT 'Number of claims per policy in force for the producer during the evaluation period.',
    `combined_ratio` DECIMAL(5,2) COMMENT 'Sum of loss ratio and expense ratio for the producer during the evaluation period.',
    `commission_earned_amount` DECIMAL(18,2) COMMENT 'Total commission earned by the producer during the evaluation period.',
    `compliance_violations_count` BIGINT COMMENT 'Number of compliance violations recorded for the producer during the evaluation period.',
    `contingent_commission_amount` DECIMAL(18,2) COMMENT 'Contingent commission earned by the producer based on performance during the evaluation period.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts in this record.. Valid values are `^[A-Z]{3}$`',
    `customer_complaint_count` BIGINT COMMENT 'Number of customer complaints filed against the producer during the evaluation period.',
    `dwp_amount` DECIMAL(18,2) COMMENT 'Direct premium written by the producer before reinsurance during the evaluation period.',
    `earned_premium_amount` DECIMAL(18,2) COMMENT 'Total earned premium for policies produced by the producer during the evaluation period.',
    `endorsement_count` BIGINT COMMENT 'Number of policy endorsements processed by the producer during the evaluation period.',
    `eo_claim_count` BIGINT COMMENT 'Number of errors and omissions claims filed against the producer during the evaluation period.',
    `evaluation_date` DATE COMMENT 'Date when the performance evaluation was completed.',
    `evaluation_period_end_date` DATE COMMENT 'End date of the performance evaluation period.',
    `evaluation_period_start_date` DATE COMMENT 'Start date of the performance evaluation period.',
    `evaluation_status` STRING COMMENT 'Current status of the performance evaluation record.. Valid values are `draft|final|under_review|approved|appealed`',
    `expense_ratio` DECIMAL(5,2) COMMENT 'Ratio of underwriting expenses to written premium for the producer during the evaluation period.',
    `gwp_amount` DECIMAL(18,2) COMMENT 'Total gross written premium produced by the producer during the evaluation period.',
    `incurred_losses_amount` DECIMAL(18,2) COMMENT 'Total incurred losses for policies produced by the producer during the evaluation period.',
    `lob_mix_score` DECIMAL(5,2) COMMENT 'Score reflecting the diversity and strategic alignment of lines of business written by the producer.',
    `loss_ratio` DECIMAL(5,2) COMMENT 'Ratio of incurred losses to earned premium for policies produced by the producer during the evaluation period.',
    `new_business_count` BIGINT COMMENT 'Number of new business policies written by the producer during the evaluation period.',
    `npn` STRING COMMENT 'National Producer Number assigned by NIPR for the producer.. Valid values are `^[0-9]{10}$`',
    `nwp_amount` DECIMAL(18,2) COMMENT 'Net written premium after reinsurance cessions for the producer during the evaluation period.',
    `paid_losses_amount` DECIMAL(18,2) COMMENT 'Total paid losses for policies produced by the producer during the evaluation period.',
    `performance_score` DECIMAL(5,2) COMMENT 'Composite performance score calculated from weighted metrics for the producer during the evaluation period.',
    `period_type` STRING COMMENT 'Type of evaluation period: monthly, quarterly, semi-annual, or annual.. Valid values are `monthly|quarterly|semi-annual|annual`',
    `pif_count` BIGINT COMMENT 'Number of active policies in force at the end of the evaluation period for this producer.',
    `quote_count` BIGINT COMMENT 'Number of quotes generated by the producer during the evaluation period.',
    `quote_to_bind_ratio` DECIMAL(5,2) COMMENT 'Percentage of quotes that resulted in bound policies during the evaluation period.',
    `rank_within_agency` BIGINT COMMENT 'Producers rank within their agency based on performance score for the evaluation period.',
    `rank_within_region` BIGINT COMMENT 'Producers rank within their geographic region based on performance score for the evaluation period.',
    `renewal_count` BIGINT COMMENT 'Number of policies renewed by the producer during the evaluation period.',
    `retention_rate` DECIMAL(5,2) COMMENT 'Percentage of policies retained at renewal during the evaluation period.',
    `tier_effective_date` DATE COMMENT 'Date when the assigned tier becomes effective for the producer.',
    CONSTRAINT pk_producer_performance PRIMARY KEY(`producer_performance_id`)
) COMMENT 'Periodic operational scorecard and tier assignment for a producer or agency. One row per producer per period. Stores GWP, NWP, PIF count, LR, retention, new-business count, and the assigned tier (Preferred/Standard/Probationary) with the tier definition';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` (
    `producer_tier_id` BIGINT COMMENT 'Unique identifier for the producer tier classification definition. Primary key.',
    `approval_authority_level` STRING COMMENT 'Minimum management level required to approve producer assignment to this tier (manager, director, vp, svp, executive).. Valid values are `manager|director|vp|svp|executive`',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether management approval is required to assign a producer to this tier.',
    `auto_downgrade_eligible` BOOLEAN COMMENT 'Indicates whether producers in this tier are automatically downgraded to lower tiers upon failing to meet criteria.',
    `auto_upgrade_eligible` BOOLEAN COMMENT 'Indicates whether producers in this tier are automatically considered for upgrade to higher tiers upon meeting criteria.',
    `binding_authority_flag` BOOLEAN COMMENT 'Indicates whether producers in this tier have binding authority to issue policies without underwriter approval.',
    `binding_authority_limit` DECIMAL(15,2) COMMENT 'Maximum policy premium or sum insured that producers in this tier can bind without referral, in USD.',
    `bonus_eligible` BOOLEAN COMMENT 'Indicates whether producers in this tier qualify for performance bonus programs.',
    `commission_override_rate` DECIMAL(5,4) COMMENT 'Default commission rate override percentage applied to producers in this tier, expressed as decimal (e.g., 0.0250 for 2.5%).',
    `contingent_commission_eligible` BOOLEAN COMMENT 'Indicates whether producers in this tier are eligible for contingent commission programs.',
    `created_by_user` STRING COMMENT 'User identifier or name of the person who created this tier definition.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this tier definition record was first created in the system.',
    `dedicated_support_flag` BOOLEAN COMMENT 'Indicates whether producers in this tier receive dedicated account management or underwriting support.',
    `effective_date` DATE COMMENT 'Date when this tier definition becomes active and available for producer assignment.',
    `evaluation_period_months` BIGINT COMMENT 'Number of months over which producer performance is evaluated for tier assignment or maintenance.',
    `expiration_date` DATE COMMENT 'Date when this tier definition expires and is no longer available for new assignments. Null for open-ended tiers.',
    `lob_authorizations` STRING COMMENT 'Comma-separated list of line of business codes that producers in this tier are authorized to write.',
    `lob_restrictions` STRING COMMENT 'Comma-separated list of line of business codes that producers in this tier are restricted from writing.',
    `marketing_support_level` STRING COMMENT 'Level of marketing and promotional support provided to producers in this tier (basic, standard, premium, platinum).. Valid values are `basic|standard|premium|platinum`',
    `maximum_loss_ratio_threshold` DECIMAL(5,4) COMMENT 'Maximum acceptable loss ratio for producers in this tier, expressed as decimal (e.g., 0.6500 for 65%).',
    `minimum_gwp_threshold` DECIMAL(15,2) COMMENT 'Minimum annual gross written premium required to qualify for or maintain this tier, in USD.',
    `minimum_policy_count_threshold` BIGINT COMMENT 'Minimum number of active policies required to qualify for or maintain this tier.',
    `minimum_retention_rate_threshold` DECIMAL(5,4) COMMENT 'Minimum policy retention rate required to qualify for or maintain this tier, expressed as decimal (e.g., 0.8500 for 85%).',
    `modified_by_user` STRING COMMENT 'User identifier or name of the person who last modified this tier definition.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this tier definition record was last modified.',
    `notes` STRING COMMENT 'Free-form notes or comments about this tier definition, including special considerations or historical context.',
    `priority_service_flag` BOOLEAN COMMENT 'Indicates whether producers in this tier receive priority processing for quotes, endorsements, and claims.',
    `probation_period_months` BIGINT COMMENT 'Number of months a producer remains in probationary status before tier re-evaluation, if applicable.',
    `special_program_access` STRING COMMENT 'Comma-separated list of special underwriting programs or niche products accessible to producers in this tier.',
    `technology_access_level` STRING COMMENT 'Level of technology tools and digital platforms available to producers in this tier (basic, standard, advanced, premium).. Valid values are `basic|standard|advanced|premium`',
    `territory_restrictions` STRING COMMENT 'Comma-separated list of territory or state codes where producers in this tier have writing restrictions.',
    `tier_code` STRING COMMENT 'Short alphanumeric code uniquely identifying the tier (e.g., PREF, STD, PROB, ELITE, BRONZE).. Valid values are `^[A-Z0-9_]{2,10}$`',
    `tier_description` STRING COMMENT 'Detailed description of the tier classification, including eligibility criteria and benefits.',
    `tier_name` STRING COMMENT 'Full business name of the tier (e.g., Preferred, Standard, Probationary, Elite, Bronze).',
    `tier_rank` BIGINT COMMENT 'Numeric ranking of the tier within the hierarchy, where lower numbers indicate higher performance tiers.',
    `tier_status` STRING COMMENT 'Current lifecycle status of the tier definition (active, inactive, suspended, retired).. Valid values are `active|inactive|suspended|retired`',
    `training_access_level` STRING COMMENT 'Level of training programs and educational resources available to producers in this tier.. Valid values are `basic|standard|advanced|executive`',
    `underwriting_authority_level` STRING COMMENT 'Level of underwriting authority granted to producers in this tier (none, limited, standard, enhanced, full).. Valid values are `none|limited|standard|enhanced|full`',
    CONSTRAINT pk_producer_tier PRIMARY KEY(`producer_tier_id`)
) COMMENT 'Classification tier assigned to a producer or agency based on performance criteria (Preferred, Standard, Probationary). One row per tier definition. Drives commission override rates, underwriting authority levels, and marketing support.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` (
    `errors_omissions_policy_id` BIGINT COMMENT 'Unique identifier for the E&O insurance policy record.',
    `agency_id` BIGINT COMMENT 'Agency organization that holds this E&O policy.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: E&O policies specify lines of business covered for appointment compliance verification.',
    `producers_producer_id` BIGINT COMMENT 'Producer or agent who holds this E&O policy.',
    `aggregate_limit` DECIMAL(18,2) COMMENT 'Total maximum coverage amount for all claims during the policy period in USD.',
    `appointment_requirement_met` BOOLEAN COMMENT 'Indicates whether this E&O policy meets the minimum requirements for producer appointment.',
    `cancellation_date` DATE COMMENT 'Date when the E&O policy was cancelled if applicable.',
    `cancellation_reason` STRING COMMENT 'Reason for E&O policy cancellation if applicable.',
    `carrier_naic_code` STRING COMMENT 'Five-digit NAIC code identifying the E&O carrier.. Valid values are `^[0-9]{5}$`',
    `carrier_name` STRING COMMENT 'Name of the insurance carrier providing E&O coverage.',
    `certificate_document_reference` STRING COMMENT 'Document management system reference for the stored certificate of insurance.',
    `certificate_of_insurance_received` BOOLEAN COMMENT 'Indicates whether a certificate of insurance has been received for this E&O policy.',
    `certificate_received_date` DATE COMMENT 'Date when the certificate of insurance was received.',
    `claims_made_or_occurrence` STRING COMMENT 'Indicates whether the E&O policy is written on a claims-made or occurrence basis.. Valid values are `claims_made|occurrence`',
    `compliance_verification_date` DATE COMMENT 'Date when the E&O policy compliance was last verified.',
    `compliance_verified` BOOLEAN COMMENT 'Indicates whether the E&O policy has been verified for compliance with appointment requirements.',
    `coverage_limit` DECIMAL(18,2) COMMENT 'Maximum coverage amount provided by the E&O policy in USD.',
    `coverage_territory` STRING COMMENT 'Geographic territory where the E&O coverage applies.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Deductible amount the insured must pay before coverage applies in USD.',
    `effective_date` DATE COMMENT 'Date when the E&O policy coverage becomes active.',
    `exclusions` STRING COMMENT 'Description of major exclusions or limitations in the E&O policy coverage.',
    `expiration_date` DATE COMMENT 'Date when the E&O policy coverage terminates.',
    `extended_reporting_period` STRING COMMENT 'Extended reporting period option for claims-made coverage after policy expiration.. Valid values are `none|12_months|24_months|36_months|unlimited`',
    `lines_of_business_covered` STRING COMMENT 'Comma-separated list of insurance lines of business covered by this E&O policy.',
    `notes` STRING COMMENT 'Additional notes or comments regarding the E&O policy.',
    `payment_frequency` STRING COMMENT 'Frequency of premium payments for the E&O policy.. Valid values are `annual|semi_annual|quarterly|monthly`',
    `per_claim_limit` DECIMAL(18,2) COMMENT 'Maximum coverage amount per individual claim in USD.',
    `policy_form_number` STRING COMMENT 'Standard form number used for the E&O policy contract.',
    `policy_number` STRING COMMENT 'Unique policy number assigned by the E&O carrier.',
    `policy_status` STRING COMMENT 'Current status of the E&O policy.. Valid values are `active|expired|cancelled|pending|suspended|lapsed`',
    `policy_type` STRING COMMENT 'Type of E&O policy coverage structure.. Valid values are `individual|agency|corporate|group`',
    `premium_amount` DECIMAL(18,2) COMMENT 'Annual premium amount for the E&O policy in USD.',
    `prior_acts_coverage` BOOLEAN COMMENT 'Indicates whether the E&O policy includes coverage for acts prior to the policy effective date.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this E&O policy record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this E&O policy record was last updated in the system.',
    `renewal_date` DATE COMMENT 'Date when the E&O policy is scheduled for renewal.',
    `renewal_notice_sent_date` DATE COMMENT 'Date when renewal notice was sent to the producer or agency.',
    `retroactive_date` DATE COMMENT 'Date from which claims-made coverage applies retroactively.',
    `source_system_code` STRING COMMENT 'Code identifying the source system from which this E&O policy record originated.',
    `source_system_reference_code` STRING COMMENT 'Unique identifier for this E&O policy in the source system.',
    `state_filing_confirmation_number` STRING COMMENT 'Confirmation number received from state Department of Insurance for E&O policy filing.',
    `state_filing_date` DATE COMMENT 'Date when the E&O policy was filed with the state Department of Insurance.',
    `state_filing_required` BOOLEAN COMMENT 'Indicates whether this E&O policy must be filed with state Department of Insurance.',
    `verified_by` STRING COMMENT 'Name or identifier of the person who verified the E&O policy compliance.',
    CONSTRAINT pk_errors_omissions_policy PRIMARY KEY(`errors_omissions_policy_id`)
) COMMENT 'E&O insurance policy held by a producer or agency as required for appointment. One row per E&O policy. Tracks insurer, policy number, coverage limit, effective date, expiration date, and compliance verification status.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` (
    `producer_compliance_event_id` BIGINT COMMENT 'Unique surrogate identifier for each producer compliance event record. Primary key. One row per compliance-relevant event per producer.',
    `agency_id` BIGINT COMMENT 'Reference to the Agency with which the producer is affiliated at the time of this compliance event, if applicable.',
    `party_id` BIGINT COMMENT 'Reference to the Party record representing the individual or organization associated with this compliance event.',
    `producer_license_id` BIGINT COMMENT 'Foreign key linking to producers.producer_license. Business justification: Compliance events (license renewal, CE completion, background check, DOI actions) are tied to a specific license.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer (agent or broker) to whom this compliance event applies. Links to the Producer master record.',
    `appeal_filed` BOOLEAN COMMENT 'Indicates whether the producer has filed a formal appeal against this compliance event or DOI action.',
    `appeal_resolution` STRING COMMENT 'Outcome of the producers appeal against this compliance event. Populated only when appeal_filed is True and the appeal has been adjudicated.. Valid values are `UPHELD|OVERTURNED|MODIFIED|WITHDRAWN|PENDING`',
    `appeal_resolution_date` DATE COMMENT 'Date on which the appeal was formally resolved. Populated when appeal_resolution is not PENDING.',
    `appointment_eligibility_flag` BOOLEAN COMMENT 'Indicates whether the producer remains eligible for appointment following this compliance event. False if DOI action, adverse background check, or termination for cause.',
    `background_check_result` STRING COMMENT 'Outcome of the background check screening. ADVERSE results may trigger appointment ineligibility review per NAIC and state DOI guidelines.. Valid values are `CLEAR|ADVERSE|PENDING|INCONCLUSIVE`',
    `background_check_vendor` STRING COMMENT 'Name of the third-party vendor that conducted the background check. Populated for BACKGROUND_CHECK event types.',
    `ce_course_code` STRING COMMENT 'State-assigned or provider-assigned identifier for the CE course completed. Used for regulatory verification of CE compliance.',
    `ce_course_name` STRING COMMENT 'Name of the continuing education course completed by the producer. Populated for CE_COMPLETION event types.',
    `ce_credit_hours` DECIMAL(5,2) COMMENT 'Number of CE credit hours earned by the producer for this course or event. Contributes to the state-mandated CE hour requirement.',
    `ce_provider_name` STRING COMMENT 'Name of the approved CE provider or institution that delivered the course. Used for provider compliance verification.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this compliance event record was first created in the data platform. Used for audit trail and data lineage.',
    `doi_action_effective_date` DATE COMMENT 'Date on which the DOI regulatory action became effective. Used to determine the period during which the producer was subject to the action.',
    `doi_action_expiration_date` DATE COMMENT 'Date on which the DOI regulatory action expires or is lifted. Null if the action is permanent or ongoing.',
    `doi_action_number` STRING COMMENT 'Official reference or docket number assigned by the DOI for the regulatory action. Used for regulatory audit trail and cross-referencing.',
    `doi_action_type` STRING COMMENT 'Type of regulatory action taken by the DOI against the producer. Populated for DOI_ACTION event types. Drives appointment eligibility flags.. Valid values are `SUSPENSION|REVOCATION|FINE|CEASE_AND_DESIST|PROBATION|WARNING`',
    `event_date` DATE COMMENT 'The real-world date on which the compliance event occurred or was formally recorded (e.g., CE course completion date, DOI action effective date).',
    `event_notes` STRING COMMENT 'Free-text notes or narrative details recorded by compliance staff regarding this event. Supports audit trail and investigative context.',
    `event_status` STRING COMMENT 'Current lifecycle status of the compliance event. PENDING indicates initiated but not resolved; COMPLETED indicates successfully closed.. Valid values are `PENDING|IN_PROGRESS|COMPLETED|FAILED|WAIVED|APPEALED`',
    `event_subtype` STRING COMMENT 'Further classification within the event type (e.g., for DOI_ACTION: SUSPENSION, REVOCATION, FINE, CEASE_AND_DESIST; for CE_COMPLETION: ETHICS, FLOOD, GENERAL). [ENUM-REF-CANDIDATE: promote to reference product]',
    `event_timestamp` TIMESTAMP COMMENT 'Precise date and time the compliance event was captured or reported in the Producer/Agency Management System, including timezone offset.',
    `event_type` STRING COMMENT 'Category of the compliance event. Drives downstream eligibility and audit logic. [ENUM-REF-CANDIDATE: LICENSE_RENEWAL|CE_COMPLETION|BACKGROUND_CHECK|DOI_ACTION|TERMINATION_FOR_CAUSE|APPOINTMENT_CHANGE — promote to reference product]. Valid values are `LICENSE_RENEWAL|CE_COMPLETION|BACKGROUND_CHECK|DOI_ACTION|TERMINATION_FOR_CAUSE|APPOINTMENT_CHANGE`',
    `fine_amount` DECIMAL(15,2) COMMENT 'Monetary fine assessed against the producer as part of a DOI action. Expressed in USD. Populated for DOI_ACTION events with FINE subtype.',
    `license_expiration_date` DATE COMMENT 'Date on which the producer license expires or expired, as relevant to this compliance event. Used to track renewal deadlines.',
    `license_renewal_date` DATE COMMENT 'Date on which the producer license was successfully renewed. Populated for LICENSE_RENEWAL event types upon completion.',
    `nipr_transaction_number` STRING COMMENT 'Transaction identifier returned by NIPR upon successful submission of a compliance event or license transaction. Used for reconciliation.',
    `npn` STRING COMMENT 'NIPR-assigned National Producer Number uniquely identifying the licensed producer across all US states. Used for regulatory cross-referencing.. Valid values are `^[0-9]{1,10}$`',
    `regulatory_reported_date` DATE COMMENT 'Date on which this compliance event was reported to the state DOI or NIPR. Null if not yet reported or reporting not required.',
    `regulatory_reporting_required` BOOLEAN COMMENT 'Indicates whether this compliance event must be reported to the state DOI or NIPR. True for DOI actions and terminations for cause per NAIC Model Law.',
    `reported_by` STRING COMMENT 'The party or system that reported or initiated this compliance event. Supports audit trail and source-of-truth tracking.. Valid values are `PRODUCER|AGENCY|DOI|NIPR|INTERNAL_AUDIT|BACKGROUND_VENDOR`',
    `reporting_state_code` STRING COMMENT 'Two-letter US state code of the Department of Insurance or jurisdiction that issued, recorded, or is the subject of this compliance event.. Valid values are `^[A-Z]{2}$`',
    `source_event_reference` STRING COMMENT 'The native identifier of this event in the originating source system (e.g., NIPR transaction ID, DOI docket number, agency management system record ID).',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this compliance event was sourced (e.g., Producer/Agency Management System, NIPR feed, DOI portal).. Valid values are `PAS|AGENCY_MGMT|NIPR|DOI_PORTAL|BACKGROUND_VENDOR|MANUAL`',
    `termination_date` DATE COMMENT 'Date on which the producer appointment or contract was terminated for cause. Populated for TERMINATION_FOR_CAUSE event types.',
    `termination_reason` STRING COMMENT 'Narrative reason for producer termination for cause. Populated for TERMINATION_FOR_CAUSE events. Subject to state DOI reporting requirements.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this compliance event record was last modified in the data platform. Used for change tracking and audit trail.',
    CONSTRAINT pk_producer_compliance_event PRIMARY KEY(`producer_compliance_event_id`)
) COMMENT 'Record of a compliance-relevant event for a producer: license renewal, CE completion, background check, DOI action, or termination for cause. One row per event. Supports appointment eligibility and regulatory audit trails.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` (
    `broker_of_record_change_id` BIGINT COMMENT 'Unique surrogate identifier for each Broker of Record change request. One row per BOR change event on a policy.',
    `broker_approved_by_party_id` BIGINT COMMENT 'Reference to the internal party (underwriter or operations staff) who approved the BOR change within the insurers workflow.',
    `broker_incoming_agency_id` BIGINT COMMENT 'Reference to the agency associated with the incoming producer. Supports commission routing and agency-level reporting.',
    `broker_outgoing_agency_id` BIGINT COMMENT 'Reference to the agency associated with the outgoing producer. Used for commission clawback and reconciliation.',
    `broker_outgoing_producer_producers_producer_id` BIGINT COMMENT 'Reference to the producer who is being replaced as the Broker of Record. Null if no prior producer was assigned.',
    `broker_producers_producer_id` BIGINT COMMENT 'Reference to the producer (agent or broker) who is being designated as the new Broker of Record for the policy.',
    `broker_requested_by_party_id` BIGINT COMMENT 'Reference to the party (insured, incoming producer, or insurer representative) who initiated the BOR change request.',
    `distribution_channel_id` BIGINT COMMENT 'Foreign key linking to producers.distribution_channel. Business justification: BOR changes may involve a change in distribution channel. Replace STRING distribution_channel_code with FK to distribution_channel. N:1 relationship.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: BOR changes require LOB reference for commission split calculation, appointment verification, and license validation.',
    `policy_id` BIGINT COMMENT 'Reference to the policy on which the Broker of Record change is being executed.',
    `superseded_by_bor_change_id` BIGINT COMMENT 'Reference to a subsequent BOR change record that supersedes this one. Supports chained BOR change history on a single policy.',
    `approval_date` DATE COMMENT 'Date on which the insurer internally approved the Broker of Record change request after validating consent and producer appointment status.',
    `bor_letter_received_date` DATE COMMENT 'Date the signed Broker of Record letter (ACORD 36 or equivalent) was received by the insurer from the incoming producer.',
    `change_reason_code` STRING COMMENT 'Coded reason for the Broker of Record change. Supports market conduct analysis and producer retention reporting. [ENUM-REF-CANDIDATE: INSURED_REQUEST|PRODUCER_MERGER|PRODUCER_TERMINATION|SERVICE_DISSATISFACTION|AGENCY_TRANSFER|OTHER — promote to reference. Valid values are `INSURED_REQUEST|PRODUCER_MERGER|PRODUCER_TERMINATION|SERVICE_DISSATISFACTION|AGENCY_TRANSFER|OTHER`',
    `change_reason_description` STRING COMMENT 'Free-text narrative explaining the reason for the Broker of Record change, supplementing the coded reason for audit and compliance purposes.',
    `change_status` STRING COMMENT 'Current workflow status of the Broker of Record change request within the Producer/Agency Management System lifecycle.. Valid values are `Pending|Approved|Rejected|Cancelled|Superseded`',
    `commission_split_basis` STRING COMMENT 'Method used to calculate the commission split between incoming and outgoing producers when the BOR change occurs mid-term.. Valid values are `PRO_RATA|SHORT_RATE|FLAT|NEGOTIATED`',
    `commission_split_incoming_pct` DECIMAL(7,4) COMMENT 'Percentage of the policy commission allocated to the incoming producer for the period from the BOR effective date to the policy term end.',
    `commission_split_outgoing_pct` DECIMAL(7,4) COMMENT 'Percentage of the policy commission retained by the outgoing producer for the period from policy term start to the BOR effective date.',
    `consent_document_reference` STRING COMMENT 'Document management system reference or identifier for the insured consent letter or ACORD BOR form on file. Supports audit and market conduct exams.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this BOR change record was first created in the data platform. Used for audit trail and data lineage.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this record. Typically USD for domestic P&C business.. Valid values are `^[A-Z]{3}$`',
    `effective_date` DATE COMMENT 'Date on which the Broker of Record change takes effect for the policy. Governs commission splits and servicing rights from this date forward.',
    `incoming_commission_rate` DECIMAL(7,4) COMMENT 'Commission rate (as a decimal percentage) to be applied to the incoming producer from the BOR effective date. Expressed as a proportion (e.g., 0.1200 = 12%).',
    `incoming_producer_appointment_verified` BOOLEAN COMMENT 'Indicates whether the incoming producers appointment with the insurer in the policy state was verified as active at the time of the BOR change approval.',
    `incoming_producer_license_number` STRING COMMENT 'State-issued producer license number of the incoming producer in the policy state at the time of the BOR change. Required for appointment validation.',
    `incoming_producer_npn` STRING COMMENT 'NIPR-issued National Producer Number of the incoming producer at the time of the BOR change request. Stored for regulatory audit trail.. Valid values are `^[0-9]{1,10}$`',
    `insured_consent_date` DATE COMMENT 'Date on which the named insured provided written consent authorizing the Broker of Record change, as required by most state DOI regulations.',
    `insured_consent_method` STRING COMMENT 'Method by which the named insured provided consent for the BOR change. Required for state DOI market conduct compliance documentation.. Valid values are `WRITTEN_LETTER|ELECTRONIC_SIGNATURE|ACORD_FORM|VERBAL_RECORDED|PORTAL`',
    `mid_term_change_flag` BOOLEAN COMMENT 'Indicates whether the BOR change is effective mid-term (True) or at renewal (False). Drives commission split logic and endorsement processing.',
    `notes` STRING COMMENT 'Free-text operational notes entered by underwriting or operations staff regarding the BOR change, such as special handling instructions or compliance observations.',
    `outgoing_commission_rate` DECIMAL(7,4) COMMENT 'Commission rate that was in effect for the outgoing producer prior to the BOR change. Used for commission clawback and reconciliation calculations.',
    `outgoing_producer_npn` STRING COMMENT 'NIPR-issued National Producer Number of the outgoing producer at the time of the BOR change. Stored for regulatory audit trail.. Valid values are `^[0-9]{1,10}$`',
    `policy_state` STRING COMMENT 'Two-letter US state code of the policys principal garaging or risk location. Determines which state DOI rules govern the BOR change process.. Valid values are `^[A-Z]{2}$`',
    `policy_term_expiration_date` DATE COMMENT 'Expiration date of the current policy term at the time of the BOR change. Used to calculate remaining term for commission split purposes.',
    `policy_term_start_date` DATE COMMENT 'Start date of the current policy term at the time of the BOR change. Used to calculate pro-rata commission splits and earned premium attribution.',
    `rejection_date` DATE COMMENT 'Date on which the BOR change request was rejected. Populated only when change_status is Rejected.',
    `rejection_reason_code` STRING COMMENT 'Coded reason for rejection of the BOR change request. Populated only when change_status is Rejected.. Valid values are `NO_INSURED_CONSENT|PRODUCER_NOT_APPOINTED|DUPLICATE_REQUEST|POLICY_CANCELLED|COMPLIANCE_HOLD`',
    `renewal_bor_flag` BOOLEAN COMMENT 'Indicates whether this BOR change is designated to take effect at the next policy renewal rather than mid-term.',
    `request_date` DATE COMMENT 'Calendar date on which the Broker of Record change request was formally submitted by the incoming producer or insured.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this BOR change record originated (e.g., PAS, Agency Management System, manual entry).. Valid values are `PAS|AGENCY_MGMT|MANUAL|PORTAL`',
    `source_system_reference_code` STRING COMMENT 'Native identifier of this BOR change record in the originating source system. Enables lineage tracing back to the system of record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this BOR change record. Used for change data capture and audit trail.',
    `written_premium_at_change` DECIMAL(18,2) COMMENT 'Total written premium on the policy at the time of the BOR change. Used as the basis for commission split calculations and financial reporting.',
    CONSTRAINT pk_broker_of_record_change PRIMARY KEY(`broker_of_record_change_id`)
) COMMENT 'Formal BOR change request and approval record transferring a policy from one producer to another. One row per BOR change. Tracks requesting producer, outgoing producer, effective date, insured consent date, and commission split impact.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_coverage_appointment` (
    `agency_coverage_appointment_id` BIGINT COMMENT 'Unique identifier for the agency coverage appointment. Primary key.',
    `agency_id` BIGINT COMMENT 'Foreign key to agency. Part of the agency-coverage appointment relationship.',
    `coverage_type_id` BIGINT COMMENT 'Foreign key to coverage_type. Part of the agency-coverage appointment relationship.',
    `appointment_status` STRING COMMENT 'Current status of the agency appointment for this coverage type: active, suspended, terminated, pending. Tracks lifecycle state of the authorization.',
    `binding_authority_flag` BOOLEAN COMMENT 'Indicates whether the agency has binding authority to issue policies with this coverage type on behalf of the carrier without prior underwriter approval.',
    `commission_rate` DECIMAL(5,4) COMMENT 'Commission rate as a decimal percentage applied to written premium for this agency-coverage combination. Overrides agency default commission rate when specified.',
    `effective_date` DATE COMMENT 'Date from which this agency is authorized to write this coverage type and the commission rate becomes effective.',
    `expiration_date` DATE COMMENT 'Date when the agency appointment authority for this coverage type expires or was terminated.',
    `max_single_risk_limit` DECIMAL(15,2) COMMENT 'Maximum total insured value or coverage limit the agency is authorized to bind for a single risk under this coverage type without referral to underwriting.',
    `termination_reason_code` STRING COMMENT 'Standardized code indicating the reason for appointment termination for this coverage type: voluntary withdrawal, performance issues, regulatory action, carrier decision.',
    CONSTRAINT pk_agency_coverage_appointment PRIMARY KEY(`agency_coverage_appointment_id`)
) COMMENT 'Represents the appointment authority granting an agency the right to write a specific coverage type. Captures commission rate, binding authority, limits, and appointment status per agency-coverage combination. One row per agency per coverage type..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` (
    `producer_agency_appointment_id` BIGINT COMMENT 'Unique surrogate identifier for each producer-agency appointment record. Primary key.',
    `agency_id` BIGINT COMMENT 'Foreign key linking to the agency in this appointment relationship.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key linking to the producer in this appointment relationship.',
    `binding_authority_flag` BOOLEAN COMMENT 'Indicates whether the producer has delegated binding authority under this specific agency appointment to issue policies without underwriter approval.',
    `binding_authority_limit` DECIMAL(18,2) COMMENT 'Maximum single-risk premium or total insured value the producer may bind under this agency appointment without referral to underwriting. Null if no binding authority granted.',
    `commission_split_percentage` DECIMAL(7,4) COMMENT 'Percentage of commission allocated to this producer under this specific agency appointment, expressed as decimal. Used when commission is split between producer and agency or among multiple producers.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this producer-agency appointment record was created in the system.',
    `effective_date` DATE COMMENT 'Date when this producer-agency appointment became effective and the producer was authorized to write business for this agency.',
    `expiration_date` DATE COMMENT 'Date when this producer-agency appointment expires or was terminated. Null if appointment is currently active with no scheduled end date.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'System timestamp when this producer-agency appointment record was last modified.',
    `lob_authorizations` STRING COMMENT 'Comma-delimited list of lines of business codes the producer is authorized to write under this specific agency appointment. May be more restrictive than producers overall LOB authorizations.',
    `primary_agency_flag` BOOLEAN COMMENT 'Indicates whether this is the producers primary agency appointment. Used for default agency assignment and commission routing when producer writes business.',
    `relationship_status` STRING COMMENT 'Current lifecycle status of this specific producer-agency appointment: active, inactive, suspended, terminated, or pending activation.',
    `relationship_type` STRING COMMENT 'Classification of the producer-agency relationship: primary appointment, secondary appointment, sub-producer arrangement, or referral relationship.',
    `termination_reason_code` STRING COMMENT 'Standardized code indicating reason for termination of this producer-agency appointment: voluntary separation, performance issues, compliance violation, agency closure, or producer retirement.',
    CONSTRAINT pk_producer_agency_appointment PRIMARY KEY(`producer_agency_appointment_id`)
) COMMENT 'Association between a producer and an agency capturing appointment-specific authority, commission splits, and LOB restrictions. One row per producer per agency appointment.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ADD CONSTRAINT `fk_producers_producers_producer_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ADD CONSTRAINT `fk_producers_agency_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ADD CONSTRAINT `fk_producers_agency_parent_agency_id` FOREIGN KEY (`parent_agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ADD CONSTRAINT `fk_producers_producer_license_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ADD CONSTRAINT `fk_producers_agency_producer_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ADD CONSTRAINT `fk_producers_agency_producer_agency_producers_producer_id` FOREIGN KEY (`agency_producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ADD CONSTRAINT `fk_producers_agency_producer_agency_reporting_manager_producer_producers_producer_id` FOREIGN KEY (`agency_reporting_manager_producer_producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ADD CONSTRAINT `fk_producers_agency_producer_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ADD CONSTRAINT `fk_producers_producer_appointment_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ADD CONSTRAINT `fk_producers_producer_appointment_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ADD CONSTRAINT `fk_producers_producer_appointment_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ADD CONSTRAINT `fk_producers_producer_appointment_prior_appointment_id` FOREIGN KEY (`prior_appointment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment`(`producer_appointment_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ADD CONSTRAINT `fk_producers_producer_appointment_producer_license_id` FOREIGN KEY (`producer_license_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producer_license`(`producer_license_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ADD CONSTRAINT `fk_producers_producer_appointment_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ADD CONSTRAINT `fk_producers_commission_schedule_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ADD CONSTRAINT `fk_producers_commission_schedule_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ADD CONSTRAINT `fk_producers_commission_schedule_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ADD CONSTRAINT `fk_producers_commission_schedule_superseded_by_schedule_id` FOREIGN KEY (`superseded_by_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ADD CONSTRAINT `fk_producers_commission_rule_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ADD CONSTRAINT `fk_producers_commission_rule_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_commission_rule_id` FOREIGN KEY (`commission_rule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule`(`commission_rule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_commission_statement_id` FOREIGN KEY (`commission_statement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement`(`commission_statement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_original_transaction_id` FOREIGN KEY (`original_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction`(`commission_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ADD CONSTRAINT `fk_producers_commission_payment_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ADD CONSTRAINT `fk_producers_commission_payment_commission_statement_id` FOREIGN KEY (`commission_statement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement`(`commission_statement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ADD CONSTRAINT `fk_producers_commission_payment_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ADD CONSTRAINT `fk_producers_contingent_commission_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ADD CONSTRAINT `fk_producers_contingent_commission_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ADD CONSTRAINT `fk_producers_producers_producer_policy_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ADD CONSTRAINT `fk_producers_producers_producer_policy_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ADD CONSTRAINT `fk_producers_producers_producer_policy_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ADD CONSTRAINT `fk_producers_producers_producer_policy_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ADD CONSTRAINT `fk_producers_producers_producer_policy_superseded_by_producer_policy_producers_producer_policy_id` FOREIGN KEY (`superseded_by_producer_policy_producers_producer_policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy`(`producers_producer_policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ADD CONSTRAINT `fk_producers_underwriting_authority_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ADD CONSTRAINT `fk_producers_underwriting_authority_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ADD CONSTRAINT `fk_producers_producer_performance_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ADD CONSTRAINT `fk_producers_producer_performance_producer_tier_id` FOREIGN KEY (`producer_tier_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier`(`producer_tier_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ADD CONSTRAINT `fk_producers_producer_performance_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ADD CONSTRAINT `fk_producers_errors_omissions_policy_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ADD CONSTRAINT `fk_producers_errors_omissions_policy_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ADD CONSTRAINT `fk_producers_producer_compliance_event_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ADD CONSTRAINT `fk_producers_producer_compliance_event_producer_license_id` FOREIGN KEY (`producer_license_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producer_license`(`producer_license_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ADD CONSTRAINT `fk_producers_producer_compliance_event_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ADD CONSTRAINT `fk_producers_broker_of_record_change_broker_incoming_agency_id` FOREIGN KEY (`broker_incoming_agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ADD CONSTRAINT `fk_producers_broker_of_record_change_broker_outgoing_agency_id` FOREIGN KEY (`broker_outgoing_agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ADD CONSTRAINT `fk_producers_broker_of_record_change_broker_outgoing_producer_producers_producer_id` FOREIGN KEY (`broker_outgoing_producer_producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ADD CONSTRAINT `fk_producers_broker_of_record_change_broker_producers_producer_id` FOREIGN KEY (`broker_producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ADD CONSTRAINT `fk_producers_broker_of_record_change_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ADD CONSTRAINT `fk_producers_broker_of_record_change_superseded_by_bor_change_id` FOREIGN KEY (`superseded_by_bor_change_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change`(`broker_of_record_change_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_coverage_appointment` ADD CONSTRAINT `fk_producers_agency_coverage_appointment_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` ADD CONSTRAINT `fk_producers_producer_agency_appointment_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` ADD CONSTRAINT `fk_producers_producer_agency_appointment_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`producers` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`producers` SET TAGS ('dbx_domain' = 'producers');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `parent_agency_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Agency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Principal Address Line 1');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Principal Address Line 2');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_city` SET TAGS ('dbx_business_glossary_term' = 'Principal City');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_country_code` SET TAGS ('dbx_business_glossary_term' = 'Principal Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_county` SET TAGS ('dbx_business_glossary_term' = 'Principal County');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Principal Postal Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_postal_code` SET TAGS ('dbx_value_regex' = '^d{5}(-d{4})?$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_state_code` SET TAGS ('dbx_business_glossary_term' = 'Principal State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ALTER COLUMN `principal_state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `license_number` SET TAGS ('dbx_business_glossary_term' = 'License Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `license_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_identifier' = 'true');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `agency_producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `agency_reporting_manager_producer_producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Reporting Manager Producer Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Identifier');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `prior_appointment_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Appointment Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `producer_license_id` SET TAGS ('dbx_business_glossary_term' = 'Producer License Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `superseded_by_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Schedule ID');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `coverage_type_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|AUD');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `commission_rule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Rule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `commission_statement_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Statement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ALTER COLUMN `original_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Original Commission Transaction ID');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `chargeback_amount` SET TAGS ('dbx_business_glossary_term' = 'Chargeback Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `contingent_commission` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|CAD|GBP|EUR|AUD');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` SET TAGS ('dbx_subdomain' = 'compensation_processing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `commission_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Payment Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `commission_statement_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Statement Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_party_id` SET TAGS ('dbx_business_glossary_term' = 'Payee Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `ach_trace_number` SET TAGS ('dbx_business_glossary_term' = 'Automated Clearing House (ACH) Trace Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approved Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_business_glossary_term' = 'Bank Routing Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_value_regex' = '^[0-9]{9}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `check_number` SET TAGS ('dbx_business_glossary_term' = 'Check Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `cleared_date` SET TAGS ('dbx_business_glossary_term' = 'Cleared Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `form_1099_reportable_flag` SET TAGS ('dbx_business_glossary_term' = 'Form 1099 Reportable Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `net_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Payment Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Payee Address Line 1');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Payee Address Line 2');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_city` SET TAGS ('dbx_business_glossary_term' = 'Payee City');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_country_code` SET TAGS ('dbx_business_glossary_term' = 'Payee Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_name` SET TAGS ('dbx_business_glossary_term' = 'Payee Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Payee Postal Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_state_code` SET TAGS ('dbx_business_glossary_term' = 'Payee State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_state_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payee_state_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Payment Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payment_memo` SET TAGS ('dbx_business_glossary_term' = 'Payment Memo');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'check|ach|wire|eft|direct_deposit|paypal');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payment_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'pending|approved|issued|cleared|cancelled|voided');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'unreconciled|reconciled|disputed|adjusted');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `reissue_flag` SET TAGS ('dbx_business_glossary_term' = 'Reissue Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `tax_year` SET TAGS ('dbx_business_glossary_term' = 'Tax Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `void_date` SET TAGS ('dbx_business_glossary_term' = 'Void Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `void_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Void Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `wire_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Wire Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ALTER COLUMN `withholding_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` SET TAGS ('dbx_subdomain' = 'compensation_processing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `contingent_commission_id` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `premium_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `actual_combined_ratio` SET TAGS ('dbx_business_glossary_term' = 'Actual Combined Ratio (CR)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `actual_growth_rate` SET TAGS ('dbx_business_glossary_term' = 'Actual Growth Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `actual_loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Actual Loss Ratio (LR)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `actual_retention_rate` SET TAGS ('dbx_business_glossary_term' = 'Actual Retention Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `agreement_name` SET TAGS ('dbx_business_glossary_term' = 'Agreement Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `agreement_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `agreement_number` SET TAGS ('dbx_business_glossary_term' = 'Agreement Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `agreement_status` SET TAGS ('dbx_business_glossary_term' = 'Agreement Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `agreement_status` SET TAGS ('dbx_value_regex' = 'draft|active|suspended|terminated|expired|pending_approval');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Agreement Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'profit_sharing|volume_bonus|loss_ratio_based|growth_incentive|retention_bonus|combined_ratio_based');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|under_review');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `calculation_basis` SET TAGS ('dbx_business_glossary_term' = 'Calculation Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `calculation_basis` SET TAGS ('dbx_value_regex' = 'gwp|nwp|ep|policy_count|retention_rate|new_business_premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `earned_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `maximum_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `minimum_premium_threshold` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Threshold');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Agreement Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `outstanding_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `paid_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `performance_met_flag` SET TAGS ('dbx_business_glossary_term' = 'Performance Met Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `performance_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Performance Period End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `performance_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Performance Period Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `settlement_frequency` SET TAGS ('dbx_business_glossary_term' = 'Settlement Frequency');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `settlement_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `target_combined_ratio` SET TAGS ('dbx_business_glossary_term' = 'Target Combined Ratio (CR)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `target_growth_rate` SET TAGS ('dbx_business_glossary_term' = 'Target Growth Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `target_loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Target Loss Ratio (LR)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `target_retention_rate` SET TAGS ('dbx_business_glossary_term' = 'Target Retention Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ALTER COLUMN `writing_company_code` SET TAGS ('dbx_business_glossary_term' = 'Writing Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `producers_producer_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `current_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `prior_producer_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Producer Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `superseded_by_producer_policy_producers_producer_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Producer Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `appointment_verification_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Verification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `appointment_verified_flag` SET TAGS ('dbx_business_glossary_term' = 'Appointment Verified Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `assignment_notes` SET TAGS ('dbx_business_glossary_term' = 'Producer Assignment Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `assignment_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Producer Assignment Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `assignment_source_code` SET TAGS ('dbx_business_glossary_term' = 'Producer Assignment Source Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `assignment_source_code` SET TAGS ('dbx_value_regex' = 'policy_issuance|bor_change|endorsement|renewal|manual_adjustment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Producer Assignment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|terminated|suspended');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `binding_authority_flag` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `commission_basis_code` SET TAGS ('dbx_business_glossary_term' = 'Commission Basis Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `commission_basis_code` SET TAGS ('dbx_value_regex' = 'written_premium|earned_premium|net_premium|gross_premium|policy_fee');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `commission_split_percentage` SET TAGS ('dbx_business_glossary_term' = 'Commission Split Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `contingent_commission_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Eligible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Producer Assignment Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Producer Assignment Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `npn` SET TAGS ('dbx_business_glossary_term' = 'National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `npn` SET TAGS ('dbx_value_regex' = '^[0-9]{10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `override_commission_flag` SET TAGS ('dbx_business_glossary_term' = 'Override Commission Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `override_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Override Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `policy_state_code` SET TAGS ('dbx_business_glossary_term' = 'Policy State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `policy_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `policy_state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `policy_transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `policy_transaction_type` SET TAGS ('dbx_value_regex' = 'new_business|renewal|endorsement|cancellation|reinstatement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `primary_producer_flag` SET TAGS ('dbx_business_glossary_term' = 'Primary Producer Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `producer_license_number` SET TAGS ('dbx_business_glossary_term' = 'Producer License Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `producer_license_number` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `producer_license_state_code` SET TAGS ('dbx_business_glossary_term' = 'Producer License State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `producer_license_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `producer_license_state_code` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `producer_role_code` SET TAGS ('dbx_business_glossary_term' = 'Producer Role Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `producer_role_code` SET TAGS ('dbx_value_regex' = 'writing_agent|servicing_agent|broker_of_record|sub_producer|referring_agent|MGA');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `producer_role_description` SET TAGS ('dbx_business_glossary_term' = 'Producer Role Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `servicing_producer_flag` SET TAGS ('dbx_business_glossary_term' = 'Servicing Producer Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Producer Assignment Termination Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `termination_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Producer Assignment Termination Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ALTER COLUMN `writing_company_code` SET TAGS ('dbx_business_glossary_term' = 'Writing Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `underwriting_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Authority Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `coverage_type_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|AUD|MXN');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` SET TAGS ('dbx_subdomain' = 'compensation_processing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `producer_performance_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Performance ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `premium_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `producer_tier_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Tier Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Evaluator ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `average_claim_severity` SET TAGS ('dbx_business_glossary_term' = 'Average Claim Severity');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `average_policy_premium` SET TAGS ('dbx_business_glossary_term' = 'Average Written Premium (AWP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `cancellation_count` SET TAGS ('dbx_business_glossary_term' = 'Cancellation (CAN) Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `claim_count` SET TAGS ('dbx_business_glossary_term' = 'Claim Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `claim_frequency` SET TAGS ('dbx_business_glossary_term' = 'Claim Frequency');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `combined_ratio` SET TAGS ('dbx_business_glossary_term' = 'Combined Ratio (CR)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `commission_earned_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Earned Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `compliance_violations_count` SET TAGS ('dbx_business_glossary_term' = 'Compliance Violations Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `contingent_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `customer_complaint_count` SET TAGS ('dbx_business_glossary_term' = 'Customer Complaint Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `dwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Direct Premium Written (DPW) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `earned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `endorsement_count` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (END) Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `eo_claim_count` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Claim Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `evaluation_date` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `evaluation_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Period End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `evaluation_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Period Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `evaluation_status` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `evaluation_status` SET TAGS ('dbx_value_regex' = 'draft|final|under_review|approved|appealed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `expense_ratio` SET TAGS ('dbx_business_glossary_term' = 'Expense Ratio (ER)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `gwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `incurred_losses_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred Losses Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `lob_mix_score` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Mix Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `new_business_count` SET TAGS ('dbx_business_glossary_term' = 'New Business (NB) Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `npn` SET TAGS ('dbx_business_glossary_term' = 'National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `npn` SET TAGS ('dbx_value_regex' = '^[0-9]{10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `nwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Written Premium (NWP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `paid_losses_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Losses Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `performance_score` SET TAGS ('dbx_business_glossary_term' = 'Performance Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `period_type` SET TAGS ('dbx_business_glossary_term' = 'Period Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `period_type` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi-annual|annual');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `pif_count` SET TAGS ('dbx_business_glossary_term' = 'Policies In Force (PIF) Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `quote_count` SET TAGS ('dbx_business_glossary_term' = 'Quote Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `quote_to_bind_ratio` SET TAGS ('dbx_business_glossary_term' = 'Quote to Bind Ratio');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `rank_within_agency` SET TAGS ('dbx_business_glossary_term' = 'Rank Within Agency');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `rank_within_region` SET TAGS ('dbx_business_glossary_term' = 'Rank Within Region');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `renewal_count` SET TAGS ('dbx_business_glossary_term' = 'Renewal (REN) Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `retention_rate` SET TAGS ('dbx_business_glossary_term' = 'Retention Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ALTER COLUMN `tier_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Tier Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `producer_tier_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Tier Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `approval_authority_level` SET TAGS ('dbx_business_glossary_term' = 'Approval Authority Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `approval_authority_level` SET TAGS ('dbx_value_regex' = 'manager|director|vp|svp|executive');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `auto_downgrade_eligible` SET TAGS ('dbx_business_glossary_term' = 'Auto Downgrade Eligible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `auto_upgrade_eligible` SET TAGS ('dbx_business_glossary_term' = 'Auto Upgrade Eligible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `binding_authority_flag` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `bonus_eligible` SET TAGS ('dbx_business_glossary_term' = 'Bonus Eligible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `commission_override_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Override Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Eligible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `dedicated_support_flag` SET TAGS ('dbx_business_glossary_term' = 'Dedicated Support Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `evaluation_period_months` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Period Months');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `lob_authorizations` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Authorizations');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `lob_restrictions` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Restrictions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `marketing_support_level` SET TAGS ('dbx_business_glossary_term' = 'Marketing Support Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `marketing_support_level` SET TAGS ('dbx_value_regex' = 'basic|standard|premium|platinum');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `maximum_loss_ratio_threshold` SET TAGS ('dbx_business_glossary_term' = 'Maximum Loss Ratio (LR) Threshold');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `minimum_gwp_threshold` SET TAGS ('dbx_business_glossary_term' = 'Minimum Gross Written Premium (GWP) Threshold');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `minimum_policy_count_threshold` SET TAGS ('dbx_business_glossary_term' = 'Minimum Policy Count Threshold');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `minimum_retention_rate_threshold` SET TAGS ('dbx_business_glossary_term' = 'Minimum Retention Rate Threshold');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `modified_by_user` SET TAGS ('dbx_business_glossary_term' = 'Modified By User');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `priority_service_flag` SET TAGS ('dbx_business_glossary_term' = 'Priority Service Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `probation_period_months` SET TAGS ('dbx_business_glossary_term' = 'Probation Period Months');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `special_program_access` SET TAGS ('dbx_business_glossary_term' = 'Special Program Access');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `technology_access_level` SET TAGS ('dbx_business_glossary_term' = 'Technology Access Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `technology_access_level` SET TAGS ('dbx_value_regex' = 'basic|standard|advanced|premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `territory_restrictions` SET TAGS ('dbx_business_glossary_term' = 'Territory Restrictions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `tier_code` SET TAGS ('dbx_business_glossary_term' = 'Tier Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `tier_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `tier_description` SET TAGS ('dbx_business_glossary_term' = 'Tier Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `tier_name` SET TAGS ('dbx_business_glossary_term' = 'Tier Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `tier_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `tier_rank` SET TAGS ('dbx_business_glossary_term' = 'Tier Rank');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `tier_status` SET TAGS ('dbx_business_glossary_term' = 'Tier Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `tier_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|retired');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `training_access_level` SET TAGS ('dbx_business_glossary_term' = 'Training Access Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `training_access_level` SET TAGS ('dbx_value_regex' = 'basic|standard|advanced|executive');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `underwriting_authority_level` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Authority Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_tier` ALTER COLUMN `underwriting_authority_level` SET TAGS ('dbx_value_regex' = 'none|limited|standard|enhanced|full');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `errors_omissions_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `aggregate_limit` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Aggregate Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `appointment_requirement_met` SET TAGS ('dbx_business_glossary_term' = 'Appointment Requirement Met Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Cancellation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Cancellation Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `carrier_naic_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Carrier Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `carrier_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `carrier_name` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Carrier Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `carrier_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `certificate_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Certificate of Insurance (CoI) Document Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `certificate_of_insurance_received` SET TAGS ('dbx_business_glossary_term' = 'Certificate of Insurance (CoI) Received Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `certificate_received_date` SET TAGS ('dbx_business_glossary_term' = 'Certificate of Insurance (CoI) Received Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `claims_made_or_occurrence` SET TAGS ('dbx_business_glossary_term' = 'Claims Made or Occurrence Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `claims_made_or_occurrence` SET TAGS ('dbx_value_regex' = 'claims_made|occurrence');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `compliance_verification_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Compliance Verification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `compliance_verified` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Compliance Verified Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `coverage_limit` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Coverage Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `coverage_territory` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Coverage Territory');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `exclusions` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Exclusions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `extended_reporting_period` SET TAGS ('dbx_business_glossary_term' = 'Extended Reporting Period (ERP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `extended_reporting_period` SET TAGS ('dbx_value_regex' = 'none|12_months|24_months|36_months|unlimited');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `lines_of_business_covered` SET TAGS ('dbx_business_glossary_term' = 'Lines of Business (LOB) Covered');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Payment Frequency');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `per_claim_limit` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Per Claim Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `policy_form_number` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `policy_number` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `policy_status` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `policy_status` SET TAGS ('dbx_value_regex' = 'active|expired|cancelled|pending|suspended|lapsed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `policy_type` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `policy_type` SET TAGS ('dbx_value_regex' = 'individual|agency|corporate|group');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `prior_acts_coverage` SET TAGS ('dbx_business_glossary_term' = 'Prior Acts Coverage Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `renewal_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Renewal Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `renewal_notice_sent_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Renewal Notice Sent Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `retroactive_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Retroactive Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `state_filing_confirmation_number` SET TAGS ('dbx_business_glossary_term' = 'State Filing Confirmation Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `state_filing_confirmation_number` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `state_filing_date` SET TAGS ('dbx_business_glossary_term' = 'State Filing Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `state_filing_date` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `state_filing_required` SET TAGS ('dbx_business_glossary_term' = 'State Filing Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `state_filing_required` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ALTER COLUMN `verified_by` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Verified By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `producer_compliance_event_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Compliance Event ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `producer_license_id` SET TAGS ('dbx_business_glossary_term' = 'Producer License Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `appeal_filed` SET TAGS ('dbx_business_glossary_term' = 'Appeal Filed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `appeal_resolution` SET TAGS ('dbx_business_glossary_term' = 'Appeal Resolution Outcome');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `appeal_resolution` SET TAGS ('dbx_value_regex' = 'UPHELD|OVERTURNED|MODIFIED|WITHDRAWN|PENDING');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `appeal_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Appeal Resolution Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `appointment_eligibility_flag` SET TAGS ('dbx_business_glossary_term' = 'Appointment Eligibility Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `background_check_result` SET TAGS ('dbx_business_glossary_term' = 'Background Check Result');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `background_check_result` SET TAGS ('dbx_value_regex' = 'CLEAR|ADVERSE|PENDING|INCONCLUSIVE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `background_check_result` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `background_check_vendor` SET TAGS ('dbx_business_glossary_term' = 'Background Check Vendor Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `ce_course_code` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Course ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `ce_course_name` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Course Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `ce_course_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `ce_credit_hours` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Credit Hours');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `ce_provider_name` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Provider Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `ce_provider_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `doi_action_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Action Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `doi_action_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Action Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `doi_action_number` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Action Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `doi_action_type` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Action Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `doi_action_type` SET TAGS ('dbx_value_regex' = 'SUSPENSION|REVOCATION|FINE|CEASE_AND_DESIST|PROBATION|WARNING');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `event_date` SET TAGS ('dbx_business_glossary_term' = 'Compliance Event Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `event_notes` SET TAGS ('dbx_business_glossary_term' = 'Compliance Event Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `event_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Event Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `event_status` SET TAGS ('dbx_value_regex' = 'PENDING|IN_PROGRESS|COMPLETED|FAILED|WAIVED|APPEALED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `event_subtype` SET TAGS ('dbx_business_glossary_term' = 'Compliance Event Subtype');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `event_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Compliance Event Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `event_type` SET TAGS ('dbx_business_glossary_term' = 'Compliance Event Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `event_type` SET TAGS ('dbx_value_regex' = 'LICENSE_RENEWAL|CE_COMPLETION|BACKGROUND_CHECK|DOI_ACTION|TERMINATION_FOR_CAUSE|APPOINTMENT_CHANGE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `fine_amount` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Fine Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `fine_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `license_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'License Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `license_renewal_date` SET TAGS ('dbx_business_glossary_term' = 'License Renewal Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `nipr_transaction_number` SET TAGS ('dbx_business_glossary_term' = 'National Insurance Producer Registry (NIPR) Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `npn` SET TAGS ('dbx_business_glossary_term' = 'National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `npn` SET TAGS ('dbx_value_regex' = '^[0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `regulatory_reported_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reported Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `regulatory_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `reported_by` SET TAGS ('dbx_business_glossary_term' = 'Reported By Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `reported_by` SET TAGS ('dbx_value_regex' = 'PRODUCER|AGENCY|DOI|NIPR|INTERNAL_AUDIT|BACKGROUND_VENDOR');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `reporting_state_code` SET TAGS ('dbx_business_glossary_term' = 'Reporting State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `reporting_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `reporting_state_code` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `source_event_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Event Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'PAS|AGENCY_MGMT|NIPR|DOI_PORTAL|BACKGROUND_VENDOR|MANUAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Termination for Cause Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `broker_of_record_change_id` SET TAGS ('dbx_business_glossary_term' = 'Broker of Record (BOR) Change ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `broker_approved_by_party_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `broker_incoming_agency_id` SET TAGS ('dbx_business_glossary_term' = 'Incoming Agency ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `broker_outgoing_agency_id` SET TAGS ('dbx_business_glossary_term' = 'Outgoing Agency ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `broker_outgoing_producer_producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Outgoing Producer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `broker_producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Incoming Producer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `broker_requested_by_party_id` SET TAGS ('dbx_business_glossary_term' = 'Requested By Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `superseded_by_bor_change_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By BOR Change ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'BOR Change Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `bor_letter_received_date` SET TAGS ('dbx_business_glossary_term' = 'BOR Letter Received Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `change_reason_code` SET TAGS ('dbx_business_glossary_term' = 'BOR Change Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `change_reason_code` SET TAGS ('dbx_value_regex' = 'INSURED_REQUEST|PRODUCER_MERGER|PRODUCER_TERMINATION|SERVICE_DISSATISFACTION|AGENCY_TRANSFER|OTHER');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `change_reason_description` SET TAGS ('dbx_business_glossary_term' = 'BOR Change Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `change_status` SET TAGS ('dbx_business_glossary_term' = 'BOR Change Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `change_status` SET TAGS ('dbx_value_regex' = 'Pending|Approved|Rejected|Cancelled|Superseded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `commission_split_basis` SET TAGS ('dbx_business_glossary_term' = 'Commission Split Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `commission_split_basis` SET TAGS ('dbx_value_regex' = 'PRO_RATA|SHORT_RATE|FLAT|NEGOTIATED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `commission_split_incoming_pct` SET TAGS ('dbx_business_glossary_term' = 'Incoming Producer Commission Split Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `commission_split_incoming_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `commission_split_outgoing_pct` SET TAGS ('dbx_business_glossary_term' = 'Outgoing Producer Commission Split Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `commission_split_outgoing_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `consent_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Insured Consent Document Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'BOR Change Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `incoming_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Incoming Producer Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `incoming_commission_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `incoming_producer_appointment_verified` SET TAGS ('dbx_business_glossary_term' = 'Incoming Producer Appointment Verified Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `incoming_producer_license_number` SET TAGS ('dbx_business_glossary_term' = 'Incoming Producer License Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `incoming_producer_license_number` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `incoming_producer_npn` SET TAGS ('dbx_business_glossary_term' = 'Incoming Producer National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `incoming_producer_npn` SET TAGS ('dbx_value_regex' = '^[0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `insured_consent_date` SET TAGS ('dbx_business_glossary_term' = 'Insured Consent Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `insured_consent_method` SET TAGS ('dbx_business_glossary_term' = 'Insured Consent Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `insured_consent_method` SET TAGS ('dbx_value_regex' = 'WRITTEN_LETTER|ELECTRONIC_SIGNATURE|ACORD_FORM|VERBAL_RECORDED|PORTAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `mid_term_change_flag` SET TAGS ('dbx_business_glossary_term' = 'Mid-Term BOR Change Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'BOR Change Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `outgoing_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Outgoing Producer Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `outgoing_commission_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `outgoing_producer_npn` SET TAGS ('dbx_business_glossary_term' = 'Outgoing Producer National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `outgoing_producer_npn` SET TAGS ('dbx_value_regex' = '^[0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `policy_state` SET TAGS ('dbx_business_glossary_term' = 'Policy State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `policy_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `policy_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `policy_term_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `policy_term_start_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `rejection_date` SET TAGS ('dbx_business_glossary_term' = 'BOR Change Rejection Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `rejection_reason_code` SET TAGS ('dbx_business_glossary_term' = 'BOR Change Rejection Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `rejection_reason_code` SET TAGS ('dbx_value_regex' = 'NO_INSURED_CONSENT|PRODUCER_NOT_APPOINTED|DUPLICATE_REQUEST|POLICY_CANCELLED|COMPLIANCE_HOLD');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `renewal_bor_flag` SET TAGS ('dbx_business_glossary_term' = 'Renewal BOR Change Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `request_date` SET TAGS ('dbx_business_glossary_term' = 'BOR Change Request Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'PAS|AGENCY_MGMT|MANUAL|PORTAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `written_premium_at_change` SET TAGS ('dbx_business_glossary_term' = 'Written Premium (WP) at BOR Change');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ALTER COLUMN `written_premium_at_change` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_coverage_appointment` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_coverage_appointment` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_coverage_appointment` SET TAGS ('dbx_association_edges' = 'coverage.coverage_type,producers.agency');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_coverage_appointment` ALTER COLUMN `agency_coverage_appointment_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Coverage Appointment - Agency Coverage Appointment Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_coverage_appointment` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Coverage Appointment - Agency Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_coverage_appointment` ALTER COLUMN `coverage_type_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Coverage Appointment - Coverage Type Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_coverage_appointment` ALTER COLUMN `appointment_status` SET TAGS ('dbx_business_glossary_term' = 'Agency Coverage Appointment - Appointment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_coverage_appointment` ALTER COLUMN `binding_authority_flag` SET TAGS ('dbx_business_glossary_term' = 'Agency Coverage Appointment - Binding Authority Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_coverage_appointment` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Agency Coverage Appointment - Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_coverage_appointment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Agency Coverage Appointment - Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_coverage_appointment` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Agency Coverage Appointment - Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_coverage_appointment` ALTER COLUMN `max_single_risk_limit` SET TAGS ('dbx_business_glossary_term' = 'Agency Coverage Appointment - Max Single Risk Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_coverage_appointment` ALTER COLUMN `termination_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Agency Coverage Appointment - Termination Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` SET TAGS ('dbx_association_edges' = 'producers.producers_producer,producers.agency');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` ALTER COLUMN `producer_agency_appointment_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Agency Appointment Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Agency Appointment - Agency Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Agency Appointment - Producer Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` ALTER COLUMN `binding_authority_flag` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` ALTER COLUMN `commission_split_percentage` SET TAGS ('dbx_business_glossary_term' = 'Commission Split Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` ALTER COLUMN `lob_authorizations` SET TAGS ('dbx_business_glossary_term' = 'Line of Business Authorizations');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` ALTER COLUMN `primary_agency_flag` SET TAGS ('dbx_business_glossary_term' = 'Primary Agency Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` ALTER COLUMN `relationship_status` SET TAGS ('dbx_business_glossary_term' = 'Appointment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` ALTER COLUMN `relationship_type` SET TAGS ('dbx_business_glossary_term' = 'Appointment Relationship Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_agency_appointment` ALTER COLUMN `termination_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Appointment Termination Reason');
