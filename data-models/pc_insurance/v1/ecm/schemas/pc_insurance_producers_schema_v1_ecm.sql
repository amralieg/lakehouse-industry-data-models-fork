-- Schema for Domain: producers | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-18 02:30:18

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_v499`.`producers` COMMENT 'Provisional description for user-specified domain producers. Awaiting a generated description of what this domain owns.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` (
    `producers_producer_id` BIGINT COMMENT 'Unique identifier for the producers_producer data product.',
    `agency_id` BIGINT COMMENT 'Reference to the parent agency or brokerage firm with which this individual producer is affiliated. Null for agency-level producer records. Supports hierarchical commission rollup.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: Producer master record references default commission schedule via string code. Adding proper FK enables referential integrity.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Producer licensing and regulatory compliance require tracking the producers domicile state. State DOI governs producer appointments, license renewals, and regulatory filings.',
    `aml_certification_date` DATE COMMENT 'Date on which the producer completed the most recent AML training certification. Used to track certification currency and trigger renewal reminders.',
    `anti_money_laundering_certified` BOOLEAN COMMENT 'Indicates whether the producer has completed required Anti-Money Laundering (AML) training certification. Mandatory for producers handling certain commercial and high-value personal lines.',
    `appointment_effective_date` DATE COMMENT 'Date on which the carriers appointment of the producer became effective with the state Department of Insurance. Marks the start of the producers authority to solicit business.',
    `appointment_status` STRING COMMENT 'Current lifecycle status of the producers appointment with the carrier. Determines whether the producer is authorized to bind new business or service existing policies.. Valid values are `active|inactive|suspended|terminated|pending`',
    `appointment_termination_date` DATE COMMENT 'Date on which the carriers appointment of the producer was terminated or expired. Null if the appointment is currently active. Required for NAIC termination filings.',
    `background_check_date` DATE COMMENT 'Date on which the most recent background check was completed for this producer. Used to determine if a refresh is required per carrier compliance policy.',
    `background_check_status` STRING COMMENT 'Status of the most recent background check conducted on the producer as part of the carriers onboarding and ongoing compliance program. Required by many state DOIs.. Valid values are `passed|failed|pending|waived|expired`',
    `binding_authority_granted` BOOLEAN COMMENT 'Indicates whether the producer has been granted binding authority to commit the carrier to coverage without prior underwriting review. Drives workflow routing in PolicyCenter.',
    `binding_authority_limit` DECIMAL(18,2) COMMENT 'Maximum single-risk premium or total insured value (TIV) in USD that the producer is authorized to bind without prior underwriting approval. Null if no binding authority is granted.',
    `business_address_city` STRING COMMENT 'City of the producers principal place of business address.',
    `business_address_line1` STRING COMMENT 'Primary street address line of the producers principal place of business. Used for regulatory correspondence, appointment filings, and commission payment mailing.',
    `business_address_state` STRING COMMENT 'Two-letter USPS state code for the producers principal place of business. Used for state-level regulatory filings and geographic distribution analytics.. Valid values are `^[A-Z]{2}$`',
    `business_address_zip` STRING COMMENT 'US ZIP or ZIP+4 postal code for the producers principal place of business. Used for geographic territory assignment and regulatory jurisdiction determination.. Valid values are `^[0-9]{5}(-[0-9]{4})?$`',
    `business_email` STRING COMMENT 'Primary business email address for the producer. Used for policy documents, commission statements, regulatory notices, and system-generated alerts from PolicyCenter or Duck Creek.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `business_phone` STRING COMMENT 'Primary business telephone number for the producers office. Used for underwriting communication, claims coordination, and regulatory correspondence.. Valid values are `^+?[0-9]{10,15}$`',
    `contingent_commission_eligible` BOOLEAN COMMENT 'Indicates whether the producer is eligible for contingent or profit-sharing commission based on loss ratio and volume performance thresholds defined in the producer agreement.',
    `continuing_education_compliant` BOOLEAN COMMENT 'Indicates whether the producer is current on state-mandated continuing education (CE) credit hours required for license renewal. Sourced from NIPR or AgentSync CE tracking.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the producer record was first created in the producer management system. Audit trail field aligned with SOX data lineage requirements.',
    `dba_name` STRING COMMENT 'Trade or DBA name under which the producer operates if different from the legal name. Used on customer-facing documents and marketing materials.',
    `e_and_o_carrier` STRING COMMENT 'Name of the insurance carrier providing the producers Errors and Omissions (E&O) professional liability coverage. Carrier requires active E&O as a condition of appointment.',
    `e_and_o_expiration_date` DATE COMMENT 'Expiration date of the producers E&O professional liability policy. Compliance monitoring must alert before expiration to prevent appointment suspension.',
    `e_and_o_limit_amount` DECIMAL(18,2) COMMENT 'Per-occurrence coverage limit of the producers E&O professional liability policy in USD. Carrier may require a minimum limit as a condition of appointment for certain LOBs.',
    `e_and_o_policy_number` STRING COMMENT 'Policy number of the producers active E&O professional liability insurance. Tracked to verify continuous coverage as a condition of maintaining carrier appointment.',
    `entity_type` STRING COMMENT 'Classification of the producer as an individual person or a business entity. Drives licensing requirements, commission structures, and regulatory reporting.. Valid values are `individual|agency|broker|managing_general_agent|surplus_lines_broker`',
    `fein` STRING COMMENT 'IRS-issued Federal Employer Identification Number for agency or corporate producer entities. Used for 1099 commission tax reporting and financial ledger payables processing.. Valid values are `^[0-9]{2}-[0-9]{7}$`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the producer record in the producer management system. Used for change data capture (CDC) and data lineage tracking in the Snowflake lakehouse.',
    `legal_name` STRING COMMENT 'Full legal name of the producer as registered with the state Department of Insurance. For individuals, this is the full personal name; for agencies, the registered business name.',
    `license_class` STRING COMMENT 'Classification of the producers license type as defined by the domicile state DOI (e.g., Property, Casualty, Personal Lines, Commercial Lines, Life, Accident & Health).',
    `license_expiration_date` DATE COMMENT 'Date on which the producers domicile state insurance license expires. Carrier compliance systems must monitor this date to suspend appointment before license lapse.',
    `license_number` STRING COMMENT 'State-issued insurance producer license number in the producers domicile state. Distinct from NPN; used for state-level regulatory filings and appointment verifications.',
    `lines_of_authority` STRING COMMENT 'Pipe-delimited list of lines of authority (LOA) for which the producer is licensed and appointed (e.g., Property|Casualty|Personal Lines). Governs which LOBs the producer may solicit.',
    `managing_general_agent_code` STRING COMMENT 'Code identifying the Managing General Agent (MGA) or wholesale broker through whom this producer accesses the carriers products, if applicable. Used for MGA commission override calculations.',
    `npn` STRING COMMENT 'NIPR-assigned National Producer Number uniquely identifying the producer across all US states. Mandatory for regulatory licensing verification and NAIC reporting.. Valid values are `^[0-9]{1,10}$`',
    `onboarding_date` DATE COMMENT 'Date on which the producer completed the carriers onboarding process and was first activated in the producer management system. Used for tenure analysis and cohort reporting.',
    `preferred_lob` STRING COMMENT 'Primary line of business (LOB) in which the producer specializes or generates the majority of written premium (e.g., Personal Auto, Homeowners, Commercial GL, BOP, WC). Used for territory and product alignment.',
    `producer_code` STRING COMMENT 'Carrier-assigned internal code uniquely identifying the producer within the policy administration system (Guidewire PolicyCenter or Duck Creek Policy). Used on policy DEC pages and commission statements.. Valid values are `^[A-Z0-9_-]{3,20}$`',
    `producer_type` STRING COMMENT 'Distribution channel classification indicating whether the producer is a captive agent (exclusive), independent agent, wholesale broker, or direct writer. Drives commission tier and appointment rules.. Valid values are `captive|independent|direct|wholesale|retail`',
    `ssn_last4` STRING COMMENT 'Last four digits of the individual producers SSN retained for identity verification and 1099 tax reporting. Full SSN must not be stored per PCI DSS and NIST SP 800-122 data minimization.. Valid values are `^[0-9]{4}$`',
    `surplus_lines_licensed` BOOLEAN COMMENT 'Indicates whether the producer holds a surplus lines license, authorizing placement of non-admitted coverage. Required for E&S market placements and surplus lines tax filings.',
    `termination_reason` STRING COMMENT 'Reason code for the termination of the producer appointment. Required for state DOI termination filings. For cause terminations trigger mandatory NAIC reporting within 30 days.. Valid values are `voluntary|for_cause|non_renewal|license_lapse|regulatory_action`',
    `uw_authority_level` STRING COMMENT 'Tiered underwriting authority level granted to the producer, controlling which risk classes and coverage limits the producer may quote and bind independently.. Valid values are `none|limited|standard|enhanced|full`',
    CONSTRAINT pk_producers_producer PRIMARY KEY(`producers_producer_id`)
) COMMENT 'SSOT master for every licensed insurance producer (agent or broker) appointed by the carrier. Owns producer identity, NPN, FEIN/SSN, entity type, and active status across all lines of business.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` (
    `producer_license_id` BIGINT COMMENT 'Unique surrogate identifier for a producer license record in the Pc_Insurance data platform. Primary key for the producer_license entity.',
    `eno_policy_id` BIGINT COMMENT 'Foreign key linking to producers.eno_policy. Business justification: Producer license tracks E&O coverage via string references. Adding proper FK to eno_policy enables referential integrity and eliminates redundant storage.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer (agent or broker) who holds this license. Links the license record to the producer master entity.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Every producer license is issued by a specific state DOI. License verification, renewal tracking, and regulatory reporting require state reference.',
    `appointment_date` DATE COMMENT 'Date on which Pc_Insurance filed or received confirmation of the producer appointment with the issuing state DOI for this license.',
    `appointment_required` BOOLEAN COMMENT 'Indicates whether the issuing state requires a formal carrier appointment in addition to this license before the producer may transact business on behalf of Pc_Insurance.',
    `appointment_status` STRING COMMENT 'Current status of the producers appointment with Pc_Insurance under this license and jurisdiction. Appointment is required before binding policies in states that mandate it.. Valid values are `appointed|not_appointed|terminated|pending`',
    `appointment_termination_date` DATE COMMENT 'Date on which the producers appointment with Pc_Insurance was terminated for this license and jurisdiction. Null if the appointment is still active.',
    `background_check_date` DATE COMMENT 'Date on which the most recent background check was completed for this producer in connection with this license or appointment. Used for compliance audit and renewal tracking.',
    `background_check_status` STRING COMMENT 'Status of the background check conducted on the producer as part of the licensing or appointment process. Required by many states and carriers per DOI and SOX compliance.. Valid values are `passed|failed|pending|waived|not_required`',
    `ce_compliance_status` STRING COMMENT 'Current compliance status of the producer with respect to continuing education (CE) requirements for this license. Drives renewal eligibility and compliance alerts.. Valid values are `compliant|non_compliant|exempt|pending_review`',
    `ce_credits_completed` BIGINT COMMENT 'Number of continuing education (CE) credit hours the producer has completed in the current renewal cycle toward satisfying the state DOI requirement for this license.',
    `ce_credits_required` BIGINT COMMENT 'Number of continuing education (CE) credit hours required by the issuing state DOI for renewal of this license within the current renewal cycle.',
    `ce_due_date` DATE COMMENT 'Deadline by which the producer must complete all required continuing education (CE) credits to qualify for license renewal in the issuing state.',
    `continuing_education_required` BOOLEAN COMMENT 'Indicates whether the issuing state requires the producer to complete continuing education (CE) credits as a condition of license renewal for this line of authority.',
    `doi_last_verified_date` DATE COMMENT 'Date on which this license record was last verified against the issuing state DOI or NIPR registry. Used to ensure data currency for compliance and appointment management.',
    `doi_verification_status` STRING COMMENT 'Status of the license verification against the issuing state Department of Insurance (DOI) records or NIPR. Flags discrepancies between internal records and official DOI data.. Valid values are `verified|unverified|discrepancy|pending_verification`',
    `effective_date` DATE COMMENT 'Date from which this producer license record is considered effective within Pc_Insurance systems. May differ from the DOI issue date if there was a processing lag.',
    `expiration_date` DATE COMMENT 'Date on which this producer license expires and must be renewed to remain in good standing with the issuing state DOI. Null if the license is perpetual.',
    `inactivation_date` DATE COMMENT 'Date on which this license record was marked inactive in Pc_Insurance systems due to expiration, revocation, or voluntary surrender. Null if the license remains active.',
    `issue_date` DATE COMMENT 'Date on which the state DOI originally issued this producer license. Used to calculate license tenure and seniority for compliance and commission purposes.',
    `license_number` STRING COMMENT 'Official license number assigned by the state Department of Insurance (DOI) to the producer. Used for regulatory verification and compliance tracking.',
    `license_status` STRING COMMENT 'Current regulatory status of the producer license as reported by the issuing state DOI. Drives eligibility to bind business in the jurisdiction.. Valid values are `active|expired|suspended|revoked|cancelled|pending`',
    `license_type` STRING COMMENT 'Classifies the license as individual, business entity, surplus lines, adjuster, or other category as defined by the issuing state DOI. [ENUM-REF-CANDIDATE: individual|business_entity|surplus_lines|adjuster|public_adjuster|managing_general_agent — promote. Valid values are `individual|business_entity|surplus_lines|adjuster|public_adjuster|managing_general_agent`',
    `line_of_authority` STRING COMMENT 'Specific line of authority granted by the DOI under this license (e.g., Property, Casualty, Life, Health, Personal Lines, Commercial Lines). Determines which products the producer may sell.',
    `lob_code` STRING COMMENT 'Standardized NAIC or internal Line of Business (LOB) code corresponding to the line of authority on this license. Used for regulatory reporting and system routing.. Valid values are `^[A-Z0-9]{2,10}$`',
    `naic_producer_code` STRING COMMENT 'National Association of Insurance Commissioners (NAIC) assigned producer code used for interstate licensing verification and regulatory reporting via the NIPR gateway.. Valid values are `^[0-9]{5,10}$`',
    `notes` STRING COMMENT 'Free-text field for compliance officers or producer management staff to record additional context, exceptions, or follow-up actions related to this producer license record.',
    `npn` STRING COMMENT 'Unique National Producer Number (NPN) assigned by NIPR/NAIC to the producer. Used for cross-state license verification, regulatory filings, and producer appointment records.. Valid values are `^[0-9]{1,10}$`',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this producer license record was first created in the Pc_Insurance data platform. Used for audit trail and data lineage per SOX and internal governance standards.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this producer license record was last modified in the Pc_Insurance data platform. Used for change tracking, audit trail, and incremental data pipeline processing.',
    `regulatory_action_date` DATE COMMENT 'Date of the most recent regulatory action taken against this producer license by the issuing state DOI. Null if no regulatory action has occurred.',
    `regulatory_action_description` STRING COMMENT 'Free-text description of the regulatory action taken against this producer license, including the nature of the violation and the DOI order or consent decree reference.',
    `regulatory_action_indicator` BOOLEAN COMMENT 'Indicates whether any regulatory action (e.g., suspension, revocation, fine, consent order) has been taken against this producer license by the issuing state DOI.',
    `renewal_date` DATE COMMENT 'Date on which the producer last successfully renewed this license with the issuing state DOI. Null if the license has never been renewed since original issuance.',
    `resident_nonresident_indicator` STRING COMMENT 'Indicates whether this license is a resident license (producer domiciled in the issuing state) or a non-resident license (producer licensed in another home state).. Valid values are `resident|nonresident`',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this license record was sourced (e.g., AgentSync, Vertafore Sircon, NIPR). Used for data lineage and reconciliation.',
    `source_system_license_code` STRING COMMENT 'Native identifier for this license record in the originating operational system (e.g., AgentSync license record ID or Vertafore Sircon record key). Supports data lineage and reconciliation.',
    `surplus_lines_eligible` BOOLEAN COMMENT 'Indicates whether this license authorizes the producer to place business with non-admitted surplus lines carriers in the issuing state jurisdiction.',
    `surplus_lines_license_number` STRING COMMENT 'Separate surplus lines license number issued by the state DOI when the producer is authorized to place non-admitted surplus lines business. Null if not applicable.',
    `termination_reason` STRING COMMENT 'Reason code explaining why this license or appointment was terminated or cancelled. Used for regulatory reporting and producer compliance audit trails.. Valid values are `voluntary|non_renewal|regulatory_action|carrier_initiated|deceased|other`',
    CONSTRAINT pk_producer_license PRIMARY KEY(`producer_license_id`)
) COMMENT 'State-issued insurance license held by a producer, including license number, line of authority (LOB), state jurisdiction, issue date, expiration date, and current status per DOI records.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` (
    `appointment_id` BIGINT COMMENT 'Unique surrogate identifier for a producer appointment record in the Pc_Insurance system.',
    `agency_id` BIGINT COMMENT 'Reference to the agency or brokerage organization through which the individual producer is affiliated for this appointment.',
    `commission_schedule_id` BIGINT COMMENT 'Reference to the commission schedule governing base and contingent commission rates applicable to this appointment.',
    `eno_policy_id` BIGINT COMMENT 'Foreign key linking to producers.eno_policy. Business justification: Appointment tracks E&O coverage requirements but currently stores only expiry date and limit. Adding FK to eno_policy enables full policy details retrieval and referential integrity.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Appointments grant producers authority to write specific lines of business. Underwriting authority validation and commission calculation require LOB reference.',
    `org_unit_id` BIGINT COMMENT 'Reference to the Pc_Insurance legal carrier entity (e.g., admitted vs. surplus lines subsidiary) issuing this appointment.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the licensed producer (agent or broker) receiving this carrier appointment.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Appointments are state-specific regulatory filings with state DOIs. Appointment tracking, termination reporting, and regulatory compliance require state reference.',
    `appointed_by_user` STRING COMMENT 'Username or employee ID of the carrier underwriting or producer management staff member who authorized this appointment.',
    `appointment_status` STRING COMMENT 'Current lifecycle state of the producer appointment as recognized by the carrier and state DOI.. Valid values are `active|pending|terminated|suspended|not_renewed`',
    `appointment_type` STRING COMMENT 'Classification of the producer appointment relationship. [ENUM-REF-CANDIDATE: agent|broker|managing_general_agent|surplus_lines_broker|reinsurance_intermediary|solicitor — promote to reference product]. Valid values are `agent|broker|managing_general_agent|surplus_lines_broker|reinsurance_intermediary`',
    `background_check_date` DATE COMMENT 'Date on which the most recent background check was completed for this producer appointment.',
    `background_check_status` STRING COMMENT 'Result of the carrier-required background screening conducted during producer onboarding prior to appointment activation.. Valid values are `passed|failed|pending|waived`',
    `base_commission_rate` DECIMAL(7,4) COMMENT 'Standard commission rate (as a decimal fraction) payable to the producer on new and renewal written premium under this appointment.',
    `binding_authority_limit` DECIMAL(18,2) COMMENT 'Maximum single-risk premium or TIV the producer may bind without prior UW referral under this appointment. Null if no binding authority.',
    `channel_type` STRING COMMENT 'Distribution channel classification for this appointment, used in commission and production analytics.. Valid values are `independent_agent|captive_agent|broker|direct|managing_general_agent|surplus_lines`',
    `contingent_commission_eligible` BOOLEAN COMMENT 'Indicates whether the producer is eligible for contingent or profit-sharing commission under this appointment.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this appointment record was first created in the Pc_Insurance data platform.',
    `doi_approval_date` DATE COMMENT 'Date the state DOI confirmed or approved the producer appointment filing. Null if pending or not required.',
    `doi_filing_date` DATE COMMENT 'Date the appointment was submitted to the state DOI for regulatory filing and approval.',
    `doi_filing_reference` STRING COMMENT 'State Department of Insurance confirmation or tracking number assigned when the appointment was filed with the regulator.',
    `effective_date` DATE COMMENT 'Date on which the carrier appointment becomes binding and the producer is authorized to solicit business.',
    `expiration_date` DATE COMMENT 'Date on which the carrier appointment expires or is scheduled to lapse. Null for perpetual appointments.',
    `is_binding_authority` BOOLEAN COMMENT 'Indicates whether the producer has been granted binding authority to commit coverage on behalf of Pc_Insurance without prior UW approval.',
    `is_surplus_lines` BOOLEAN COMMENT 'Indicates whether this appointment is for surplus lines (non-admitted) business, subject to separate state surplus lines regulations.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code identifying the Pc_Insurance legal entity under which this appointment is issued.. Valid values are `^[0-9]{5}$`',
    `notes` STRING COMMENT 'Free-text notes capturing special conditions, exceptions, or underwriting remarks associated with this producer appointment.',
    `number` STRING COMMENT 'Externally-known carrier-assigned appointment reference number used in DOI filings and bordereaux reporting.. Valid values are `^[A-Z0-9-]{4,30}$`',
    `producer_license_class` STRING COMMENT 'Class of the underlying producer license authorizing this appointment, e.g., property, casualty, surplus lines.. Valid values are `property|casualty|life|health|surplus_lines|variable`',
    `producer_license_number` STRING COMMENT 'State-issued insurance producer license number that underpins this appointment. Must be active in the appointment state.',
    `source` STRING COMMENT 'Indicates how this appointment was initiated: new business onboarding, renewal, transfer from another carrier entity, or reinstatement.. Valid values are `new_business|renewal|transfer|reinstatement`',
    `source_system_appointment_code` STRING COMMENT 'Native primary key or record identifier for this appointment in the originating producer management system of record.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this appointment record was sourced, e.g., AgentSync or Vertafore Sircon.. Valid values are `agentsync|sircon|guidewire|duck_creek|sapiens|manual`',
    `termination_date` DATE COMMENT 'Date on which the appointment was formally terminated prior to its scheduled expiration, if applicable.',
    `termination_reason` STRING COMMENT 'Reason code explaining why the appointment was terminated. Required for DOI termination filings per NAIC guidelines.. Valid values are `voluntary|non_renewal|regulatory_action|performance|fraud|other`',
    `training_completed` BOOLEAN COMMENT 'Indicates whether the producer has completed all mandatory carrier product and compliance training required for this appointment.',
    `training_completion_date` DATE COMMENT 'Date on which the producer completed all required carrier training for this appointment.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this appointment record in the Pc_Insurance data platform.',
    CONSTRAINT pk_appointment PRIMARY KEY(`appointment_id`)
) COMMENT 'Formal carrier appointment authorizing a producer to sell specific LOBs in a given state on behalf of Pc_Insurance. Tracks appointment status, effective/expiration dates, and DOI filing reference.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`producers`.`agency` (
    `agency_id` BIGINT COMMENT 'Unique surrogate identifier for the agency or brokerage firm record in the producers domain.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: Agency master record references default commission schedule via string code. Adding proper FK enables referential integrity.',
    `parent_agency_id` BIGINT COMMENT 'Self-referencing identifier linking this agency to its parent agency or network group, enabling hierarchical rollup of production, commission, and loss data.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Agency domicile state determines regulatory jurisdiction, licensing requirements, and tax obligations. Agency onboarding and compliance tracking require state reference.',
    `agency_status` STRING COMMENT 'Current lifecycle status of the agency appointment with Pc_Insurance, governing whether the agency may bind new business or renew policies.. Valid values are `active|inactive|suspended|terminated|pending_appointment`',
    `agency_type` STRING COMMENT 'Classification of the agency by distribution channel role. [ENUM-REF-CANDIDATE: independent_agent|captive_agent|broker|managing_general_agent|surplus_lines_broker|wholesale_broker — promote to reference product]. Valid values are `independent_agent|captive_agent|broker|managing_general_agent|surplus_lines_broker|wholesale_broker`',
    `annual_premium_volume` DECIMAL(18,2) COMMENT 'Most recently reported annual written premium (WP) volume placed by the agency across all carriers, used for producer tiering, contingent commission, and appetite decisions.',
    `appointment_effective_date` DATE COMMENT 'Date on which the agency appointment with Pc_Insurance became effective, marking the start of the contractual producer relationship and binding authority.',
    `appointment_termination_date` DATE COMMENT 'Date on which the agency appointment with Pc_Insurance was or will be terminated. Null for active appointments. Required for DOI termination notice filings.',
    `background_check_date` DATE COMMENT 'Date on which the most recent background check was completed for the agency principal(s), used to track compliance with periodic re-screening requirements.',
    `background_check_status` STRING COMMENT 'Status of the most recent background check conducted on the agency principal(s) as part of the producer onboarding and appointment compliance process.. Valid values are `passed|failed|pending|waived`',
    `binding_authority_flag` BOOLEAN COMMENT 'Indicates whether the agency has been granted binding authority by Pc_Insurance to commit coverage on behalf of the insurer without prior underwriting approval.',
    `binding_authority_limit` DECIMAL(18,2) COMMENT 'Maximum single-risk premium or total insured value (TIV) the agency is authorized to bind without prior underwriting approval, expressed in USD.',
    `agency_code` STRING COMMENT 'Externally-known alphanumeric code assigned to the agency by Pc_Insurance, used on policy declarations, bordereaux, and commission statements.. Valid values are `^[A-Z0-9]{4,20}$`',
    `contingent_commission_eligible` BOOLEAN COMMENT 'Indicates whether the agency is eligible for contingent or profit-sharing commission based on loss ratio (LR) and volume performance thresholds.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the agency record was first created in the producer management system, providing the audit trail start point for the agency lifecycle.',
    `dba_name` STRING COMMENT 'Trade or assumed name under which the agency operates if different from its legal name. DBA is registered with the state and used in consumer-facing communications.',
    `email_address` STRING COMMENT 'Primary business email address for the agency, used for policy documents, commission statements, renewal notices, and regulatory correspondence.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `eo_carrier_name` STRING COMMENT 'Name of the insurance carrier providing the agency Errors and Omissions (E&O) professional liability coverage, required for appointment and ongoing compliance.',
    `eo_coverage_amount` DECIMAL(18,2) COMMENT 'Per-occurrence limit of the agency E&O professional liability policy in USD. Pc_Insurance requires a minimum threshold for appointment eligibility.',
    `eo_expiration_date` DATE COMMENT 'Expiration date of the agency E&O professional liability policy. Pc_Insurance monitors this date to ensure continuous coverage and trigger renewal reminders.',
    `eo_policy_number` STRING COMMENT 'Policy number of the agency Errors and Omissions (E&O) professional liability insurance policy, used to verify coverage during appointment and renewal audits.',
    `fax_number` STRING COMMENT 'Business fax number for the agency, used for document transmission including policy applications, endorsement requests, and claims correspondence.. Valid values are `^+?[0-9-() ]{7,20}$`',
    `fein` STRING COMMENT 'IRS-issued Federal Employer Identification Number (FEIN) for the agency entity, required for tax reporting, commission 1099 issuance, and regulatory filings.. Valid values are `^[0-9]{2}-[0-9]{7}$`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the agency record in the producer management system, supporting audit trail, change detection, and incremental data pipeline processing.',
    `legal_name` STRING COMMENT 'Full legal registered name of the agency or brokerage firm as filed with the state Department of Insurance (DOI) and used on all regulatory and contractual documents.',
    `loss_ratio` DECIMAL(7,4) COMMENT 'Most recently calculated loss ratio (LR) for the agency book of business with Pc_Insurance, expressed as a decimal. Used for contingent commission eligibility and UW appetite review.',
    `managing_ga_flag` BOOLEAN COMMENT 'Indicates whether the agency operates as a Managing General Agent (MGA) with delegated underwriting authority, distinct from a standard retail or wholesale broker.',
    `naic_producer_code` STRING COMMENT 'NAIC-assigned producer code uniquely identifying the agency across all state DOI licensing systems and NAIC databases for regulatory reporting.. Valid values are `^[0-9]{5,10}$`',
    `network_code` STRING COMMENT 'Code identifying the independent agency network or cluster group (e.g., Keystone, Argo) to which the agency belongs, used for network-level commission and volume tracking.',
    `onboarding_completed_date` DATE COMMENT 'Date on which the agency completed all onboarding requirements including licensing verification, E&O confirmation, background check, and system credentialing.',
    `pc_insurance_gwp` DECIMAL(18,2) COMMENT 'Gross written premium (GWP) placed with Pc_Insurance by this agency in the most recent policy year, used for production performance tracking and commission tier qualification.',
    `phone_number` STRING COMMENT 'Primary business telephone number for the agency, used for underwriting communication, claims coordination, and producer management outreach.. Valid values are `^+?[0-9-() ]{7,20}$`',
    `preferred_lob_codes` STRING COMMENT 'Comma-separated list of line of business (LOB) codes the agency is authorized or preferred to write, such as GL, BOP, WC, CPP, APD. Used for appetite and routing.',
    `principal_address_line1` STRING COMMENT 'First line of the agency principal business address, used for regulatory correspondence, commission payments, and DOI licensing records.',
    `principal_address_line2` STRING COMMENT 'Second line of the agency principal business address (suite, floor, unit). Supplements address_line1 for complete mailing address.',
    `principal_city` STRING COMMENT 'City of the agency principal business address, used for geographic segmentation, state licensing jurisdiction determination, and regulatory filings.',
    `principal_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for the agency principal business address. Typically USA for domestic agencies; supports surplus lines and international brokers.. Valid values are `^[A-Z]{3}$`',
    `principal_postal_code` STRING COMMENT 'ZIP or ZIP+4 postal code for the agency principal business address, used for geographic rating territory assignment and regulatory correspondence.. Valid values are `^[0-9]{5}(-[0-9]{4})?$`',
    `surplus_lines_licensed` BOOLEAN COMMENT 'Indicates whether the agency holds a surplus lines broker license, authorizing placement of non-admitted coverage with eligible surplus lines insurers.',
    `termination_reason` STRING COMMENT 'Reason code for the termination of the agency appointment. Required for state DOI termination notice filings per NAIC Producer Licensing Model Act.. Valid values are `voluntary|non_renewal|cause|regulatory_action|merger_acquisition`',
    `territory_code` STRING COMMENT 'Pc_Insurance internal territory or region code assigned to the agency for field underwriting management, production tracking, and geographic performance reporting.',
    `website_url` STRING COMMENT 'Public website URL for the agency, used for producer directory listings, digital marketing attribution, and consumer-facing producer locator tools.. Valid values are `^https?://[^s]{3,255}$`',
    `years_in_business` BIGINT COMMENT 'Number of years the agency has been in operation since its founding date. Used in underwriting appetite scoring and producer tiering for contingent commission eligibility.',
    CONSTRAINT pk_agency PRIMARY KEY(`agency_id`)
) COMMENT 'Master record for an agency or brokerage firm through which producers operate. Captures agency name, FEIN, DBA, principal address, agency type, and E&O coverage details.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` (
    `agency_producer_id` BIGINT COMMENT 'Unique surrogate identifier for the agency-producer association record in the producers domain.',
    `agency_id` BIGINT COMMENT 'Reference to the agency entity with which the producer is associated.',
    `agency_producers_producer_id` BIGINT COMMENT 'Reference to the individual producer (agent or broker) associated with the agency.',
    `commission_schedule_id` BIGINT COMMENT 'Reference to the commission plan governing the producers compensation under this agency association.',
    `eno_policy_id` BIGINT COMMENT 'Foreign key linking to producers.eno_policy. Business justification: Agency-producer association tracks E&O coverage via string policy_number. Adding proper FK to eno_policy enables referential integrity and eliminates redundant storage of policy details.',
    `parent_producer_producers_producer_id` BIGINT COMMENT 'Reference to the supervising or parent producer within the agency hierarchy. Null if the producer is at the top of the hierarchy.',
    `appointment_date` DATE COMMENT 'Date the producer was formally appointed by the carrier or state DOI under this agency relationship.',
    `appointment_expiry_date` DATE COMMENT 'Date on which the producers state appointment under this agency expires and must be renewed to remain in good standing.',
    `appointment_number` STRING COMMENT 'State-issued or carrier-issued appointment number confirming the producers authority to represent the agency and bind business on behalf of the insurer.',
    `appointment_state` STRING COMMENT 'Two-letter US state code for the jurisdiction in which the producer is appointed under this agency association.. Valid values are `^[A-Z]{2}$`',
    `association_role` STRING COMMENT 'Role the producer holds within the agency, such as principal agent, sub-agent, or broker. [ENUM-REF-CANDIDATE: principal_agent|sub_agent|broker|managing_agent|surplus_lines_agent|appointed_agent — promote to reference product]. Valid values are `principal_agent|sub_agent|broker|managing_agent|surplus_lines_agent|appointed_agent`',
    `association_source` STRING COMMENT 'Source system or process through which this agency-producer association record was created or last updated (e.g., AgentSync, Vertafore Sircon, manual entry).. Valid values are `agentsync|vertafore_sircon|manual|api_feed|legacy_migration`',
    `association_status` STRING COMMENT 'Current lifecycle status of the producer-agency relationship (e.g., active, suspended, terminated).. Valid values are `active|inactive|suspended|terminated|pending`',
    `background_check_date` DATE COMMENT 'Date on which the most recent background check was completed for this producer under this agency association.',
    `background_check_status` STRING COMMENT 'Status of the most recent background check conducted on the producer as part of agency onboarding or periodic compliance review.. Valid values are `passed|failed|pending|waived`',
    `binding_authority_flag` BOOLEAN COMMENT 'Indicates whether the producer has delegated binding authority to commit coverage on behalf of the insurer without prior underwriting approval.',
    `binding_authority_limit` DECIMAL(18,2) COMMENT 'Maximum single-risk premium or Total Insured Value (TIV) the producer may bind under delegated authority without referral to underwriting.',
    `ce_credits_completed` BIGINT COMMENT 'Number of continuing education (CE) credit hours the producer has completed in the current compliance period under this agency association.',
    `ce_credits_required` BIGINT COMMENT 'Number of continuing education (CE) credit hours required for the producer to maintain compliance under this agency and state appointment.',
    `channel_type` STRING COMMENT 'Distribution channel classification for the producer within this agency (e.g., independent agent, captive agent, MGA, surplus lines broker).. Valid values are `independent_agent|captive_agent|broker|managing_general_agent|surplus_lines_broker`',
    `commission_split_pct` DECIMAL(5,4) COMMENT 'Decimal fraction (0.0000–1.0000) representing the producers share of the agency commission for business written under this association.',
    `contingent_commission_eligible` BOOLEAN COMMENT 'Indicates whether the producer is eligible for contingent or profit-sharing commission under this agency arrangement based on loss ratio and volume thresholds.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this agency-producer association record was first created in the system.',
    `effective_date` DATE COMMENT 'Date on which the producers association with the agency became or becomes effective.',
    `external_association_ref` STRING COMMENT 'Identifier for this agency-producer association in the source producer management system (AgentSync or Vertafore Sircon) for reconciliation and audit.',
    `hierarchy_level` BIGINT COMMENT 'Numeric level of the producer within the agency hierarchy (e.g., 1 = principal, 2 = senior agent, 3 = sub-agent). Used for commission override calculations.',
    `is_primary_agency` BOOLEAN COMMENT 'Indicates whether this agency is the producers primary or home agency, as opposed to a secondary or additional appointment.',
    `is_principal` BOOLEAN COMMENT 'Indicates whether the producer is the principal agent of the agency, holding primary authority and accountability within the agency hierarchy.',
    `lob_authorizations` STRING COMMENT 'Comma-separated list of Lines of Business (LOB) the producer is authorized to write under this agency (e.g., GL, WC, APD, BOP). Derived from appointment scope.',
    `mga_flag` BOOLEAN COMMENT 'Indicates whether the producer operates as a Managing General Agent (MGA) with delegated underwriting and binding authority under this agency.',
    `naic_pdb_status` STRING COMMENT 'Status of the producer in the NAIC Producer Database (PDB), reflecting any adverse licensing or regulatory history across all states.. Valid values are `clear|flagged|under_review|restricted`',
    `override_commission_pct` DECIMAL(5,4) COMMENT 'Additional override commission percentage earned by a principal or managing agent on business written by sub-agents within the hierarchy.',
    `record_version` BIGINT COMMENT 'Optimistic locking version counter incremented on each update to this association record, supporting concurrency control and change tracking.',
    `regulatory_action_flag` BOOLEAN COMMENT 'Indicates whether the producer has an open or historical regulatory action (e.g., DOI investigation, license suspension) relevant to this agency association.',
    `surplus_lines_licensed` BOOLEAN COMMENT 'Indicates whether the producer holds a surplus lines license under this agency association, permitting placement with non-admitted carriers.',
    `termination_date` DATE COMMENT 'Date on which the producers association with the agency was or is scheduled to be terminated. Null if still active.',
    `termination_notes` STRING COMMENT 'Free-text notes providing additional context for the termination of the producer-agency association, used for compliance documentation.',
    `termination_reason` STRING COMMENT 'Reason code for the termination of the producer-agency association. [ENUM-REF-CANDIDATE: voluntary|involuntary|license_lapse|e_and_o_lapse|regulatory_action|merger|other — promote to reference product]',
    `training_compliance_status` STRING COMMENT 'Indicates whether the producer has met all required continuing education (CE) and product training obligations under this agency association.. Valid values are `compliant|non_compliant|pending|exempt`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this agency-producer association record was last modified.',
    CONSTRAINT pk_agency_producer PRIMARY KEY(`agency_producer_id`)
) COMMENT 'Junction table associating producers to agencies, capturing role, start/end dates, and whether the producer is the principal or sub-agent within the agency hierarchy.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` (
    `eno_policy_id` BIGINT COMMENT 'Unique identifier for the eno_policy data product (auto-inserted during validation).',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: E&O policies track premium amounts and coverage limits in specific currencies. Financial reporting and compliance verification require currency reference. Removes denormalized currency_code.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the licensed producer or agency entity that holds this E&O policy.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: E&O policies have state-specific regulatory requirements and coverage terms. Producer compliance verification and appointment eligibility require state reference.',
    `additional_insured_indicator` BOOLEAN COMMENT 'Indicates whether the appointing carrier is listed as an additional insured on the producers E&O policy.',
    `aggregate_limit_amount` DECIMAL(18,2) COMMENT 'Maximum total dollar amount the E&O policy will pay across all covered claims within the policy period.',
    `annual_premium_amount` DECIMAL(18,2) COMMENT 'Total annual premium paid by the producer or agency for the E&O policy. Used in cost-of-distribution and producer profitability analysis.',
    `auto_renewal_indicator` BOOLEAN COMMENT 'Indicates whether the E&O policy is set to automatically renew upon expiration without requiring manual re-submission.',
    `cancellation_date` DATE COMMENT 'Date on which the E&O policy was cancelled mid-term, if applicable. Null if the policy was not cancelled before its expiration date.',
    `cancellation_reason` STRING COMMENT 'Reason code for mid-term cancellation of the E&O policy. Used in compliance reporting and producer risk assessment.. Valid values are `non_payment|underwriting|voluntary|regulatory|other`',
    `certificate_received_date` DATE COMMENT 'Date on which the certificate of insurance evidencing E&O coverage was received and logged by the carriers producer management team.',
    `compliance_status` STRING COMMENT 'Compliance determination for the E&O policy relative to carrier appointment requirements. Drives appointment eligibility and suspension workflows.. Valid values are `compliant|non_compliant|under_review|waived`',
    `compliance_verified_by` STRING COMMENT 'Name or user identifier of the compliance officer or system that last verified the E&O policy meets appointment requirements.',
    `compliance_verified_date` DATE COMMENT 'Most recent date on which the E&O policy was verified as compliant with carrier appointment requirements by the producer management team.',
    `coverage_form_type` STRING COMMENT 'Indicates whether the E&O policy is written on a claims-made or occurrence basis, which determines when coverage is triggered.. Valid values are `claims_made|occurrence`',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Dollar amount the insured producer or agency must pay out-of-pocket per claim before E&O coverage responds.',
    `effective_date` DATE COMMENT 'Date on which the E&O policy coverage becomes active and binding. Used to validate appointment eligibility windows.',
    `expiration_date` DATE COMMENT 'Date on which the E&O policy coverage terminates. Triggers compliance alerts and appointment suspension workflows.',
    `extended_reporting_period_days` BIGINT COMMENT 'Number of days after policy expiration during which claims arising from prior acts may still be reported under a claims-made E&O policy.',
    `insurer_naic_code` STRING COMMENT 'Five-digit NAIC company code identifying the E&O insurer. Used for statutory reporting and carrier validation.. Valid values are `^[0-9]{5}$`',
    `insurer_name` STRING COMMENT 'Legal name of the insurance carrier providing the E&O coverage to the producer or agency.',
    `lob_covered` STRING COMMENT 'Comma-delimited list of lines of business (e.g., P&C, Life, Health) for which the E&O policy provides professional liability coverage.',
    `minimum_required_limit_met` BOOLEAN COMMENT 'Indicates whether the policys per-occurrence and aggregate limits meet the carriers minimum E&O requirements for appointment.',
    `multi_state_indicator` BOOLEAN COMMENT 'Indicates whether the E&O policy provides coverage across multiple state jurisdictions beyond the primary filing state.',
    `named_insured` STRING COMMENT 'Legal name of the individual producer or agency entity listed as the named insured on the E&O policy declarations page.',
    `notes` STRING COMMENT 'Free-text field for compliance officers to record observations, exceptions, or follow-up actions related to the E&O policy.',
    `occurrence_limit_amount` DECIMAL(18,2) COMMENT 'Maximum dollar amount the E&O policy will pay for a single covered claim or occurrence. Validated against carrier minimum requirements.',
    `policy_number` STRING COMMENT 'Externally-assigned policy number issued by the E&O insurer, used for correspondence, audits, and appointment compliance verification.',
    `policy_status` STRING COMMENT 'Current lifecycle state of the E&O policy. Drives appointment eligibility and compliance holds within the producer management system.. Valid values are `active|expired|cancelled|pending|lapsed`',
    `policy_type` STRING COMMENT 'Classifies the E&O policy as individual producer, agency-level, group program, or excess layer coverage.. Valid values are `individual|agency|group|excess`',
    `prior_acts_coverage_indicator` BOOLEAN COMMENT 'Indicates whether the E&O policy includes prior acts coverage, extending protection to acts occurring before the retroactive date.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this E&O policy record was first created in the data platform. Supports audit trail and data lineage requirements.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this E&O policy record was last modified in the data platform. Used for change detection and incremental processing.',
    `renewal_reminder_days` BIGINT COMMENT 'Number of days before expiration that automated renewal reminder notifications are triggered to the producer and compliance team.',
    `retroactive_date` DATE COMMENT 'Earliest date from which acts, errors, or omissions are covered under a claims-made E&O policy. Null for occurrence-based forms.',
    `source_system_code` STRING COMMENT 'Identifies the operational system of record from which this E&O policy record was ingested (e.g., AgentSync, Vertafore Sircon).. Valid values are `agentsync|sircon|guidewire|duck_creek|manual`',
    `source_system_record_code` STRING COMMENT 'Native primary key or record identifier from the originating producer management system for lineage and reconciliation purposes.',
    `waiver_approved_by` STRING COMMENT 'Name or user identifier of the compliance authority who approved the E&O compliance waiver for this producer.',
    `waiver_expiration_date` DATE COMMENT 'Date on which the compliance waiver expires, after which the producer must provide a compliant E&O policy to maintain appointment.',
    `waiver_reason` STRING COMMENT 'Documented justification for granting a compliance waiver when the E&O policy does not meet standard appointment requirements.',
    CONSTRAINT pk_eno_policy PRIMARY KEY(`eno_policy_id`)
) COMMENT 'Errors and Omissions (E&O) insurance policy held by a producer or agency. Tracks insurer, policy number, coverage limit, effective/expiration dates, and compliance status required for appointment.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` (
    `commission_schedule_id` BIGINT COMMENT 'Unique surrogate identifier for a commission schedule record. Primary key for the commission_schedule product in the producers domain.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Commission schedules specify rates and thresholds in specific currencies. Multi-currency commission calculation and financial reporting require currency reference.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Commission rates are structured by line of business due to varying risk profiles and market dynamics. Commission calculation and profitability analysis require LOB reference.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Commission schedules vary by state due to regulatory requirements and market conditions. Commission calculation and regulatory filing require state reference. Removes denormalized state_code.',
    `superseded_by_commission_schedule_id` BIGINT COMMENT 'Reference to the commission_schedule_id of the newer schedule that replaced this one. Null if this is the current active version. Supports schedule lineage and audit trails.',
    `approval_date` DATE COMMENT 'Date on which this commission schedule received final approval from the designated authority. Null if approval is still pending or the schedule was rejected.',
    `approval_status` STRING COMMENT 'Internal approval workflow status for this commission schedule. Schedules must be approved before activation. Supports SOX-compliant change management and audit trail requirements.. Valid values are `pending|approved|rejected|withdrawn`',
    `approved_by` STRING COMMENT 'Name or employee identifier of the underwriting or finance authority who approved this commission schedule for activation. Required for SOX audit trail and governance compliance.',
    `base_commission_rate` DECIMAL(7,4) COMMENT 'Standard base commission rate expressed as a decimal percentage of Written Premium (WP) earned by the producer for qualifying policies under this schedule.',
    `cancellation_chargeback_rate` DECIMAL(7,4) COMMENT 'Rate at which previously paid commission is charged back to the producer upon policy cancellation (CANC). Applied to the unearned premium returned to the policyholder.',
    `channel` STRING COMMENT 'Distribution channel to which this commission schedule applies: independent agent, captive agent, direct, broker, or digital. Enables channel-specific commission differentiation.. Valid values are `independent_agent|captive_agent|direct|broker|digital`',
    `combined_ratio_threshold` DECIMAL(7,4) COMMENT 'Maximum permissible Combined Ratio (CR) for the producers portfolio to qualify for profit-sharing or contingent bonus. Incorporates both Loss Ratio (LR) and Expense Ratio (ER).',
    `contingent_bonus_rate` DECIMAL(7,4) COMMENT 'Additional contingent bonus rate payable on top of the base commission when the producer meets profitability or volume thresholds defined in the bonus tier configuration.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this commission schedule record was first created in the system. Supports audit trail, data lineage, and SOX compliance requirements.',
    `dac_eligible` BOOLEAN COMMENT 'Indicates whether commissions paid under this schedule qualify as Deferred Acquisition Costs (DAC) for GAAP accounting purposes under ASC 944, requiring capitalization and amortization.',
    `commission_schedule_description` STRING COMMENT 'Free-text narrative describing the business purpose, eligibility criteria, and special conditions of this commission schedule. Used in producer agreements and internal documentation.',
    `effective_date` DATE COMMENT 'Date on which this commission schedule becomes active and applicable to qualifying producer transactions. Policies bound on or after this date are subject to these rates.',
    `endorsement_rate` DECIMAL(7,4) COMMENT 'Commission rate applied to mid-term endorsement (ENDT) transactions that generate additional premium. Applied to the net additional premium resulting from the endorsement.',
    `expiration_date` DATE COMMENT 'Date on which this commission schedule ceases to be applicable. Null indicates an open-ended schedule with no defined end date. Superseded schedules retain history.',
    `filing_reference` STRING COMMENT 'State DOI filing reference number or SERFF tracking number associated with the regulatory submission of this commission schedule. Null if no filing is required.',
    `gl_account_code` STRING COMMENT 'General Ledger (GL) account code in Oracle Financials or SAP FI to which commission expenses under this schedule are posted. Ensures accurate financial reporting and cost allocation.. Valid values are `^[A-Z0-9-]{4,20}$`',
    `loss_ratio_threshold` DECIMAL(7,4) COMMENT 'Maximum permissible Loss Ratio (LR) expressed as a decimal that the producers book must not exceed to remain eligible for contingent bonus or profit-sharing commission under this schedule.',
    `max_volume_premium` DECIMAL(18,2) COMMENT 'Upper Written Premium (WP) volume cap in USD above which this schedule tier no longer applies and the producer advances to the next tier. Null indicates no upper cap.',
    `measurement_period` STRING COMMENT 'Time period over which producer volume, loss ratio, and profitability metrics are measured to determine eligibility and payout under this commission schedule.. Valid values are `annual|semi_annual|quarterly|monthly`',
    `min_policy_count` BIGINT COMMENT 'Minimum number of in-force policies the producer must maintain during the measurement period to qualify for this commission schedule or contingent bonus tier.',
    `min_volume_premium` DECIMAL(18,2) COMMENT 'Minimum Written Premium (WP) volume in USD that a producer must generate within the measurement period to qualify for this commission schedule or contingent bonus tier.',
    `new_business_rate` DECIMAL(7,4) COMMENT 'Specific commission rate applied to New Business (NB) policy transactions when the schedule differentiates NB from renewal rates. Overrides base_commission_rate for NB transactions.',
    `notes` STRING COMMENT 'Internal operational notes or comments regarding exceptions, amendments, or special handling instructions for this commission schedule. Not exposed in producer-facing documents.',
    `override_rate` DECIMAL(7,4) COMMENT 'Override percentage applied to the base commission rate for managing general agents or hierarchical producers who earn a spread on sub-producer business.',
    `payment_frequency` STRING COMMENT 'Frequency at which earned commissions under this schedule are calculated and disbursed to the producer, e.g., monthly, quarterly, semi-annual, or annual.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `producer_tier` STRING COMMENT 'Producer performance or appointment tier to which this schedule applies. Tier determines eligibility for enhanced base rates, contingent bonuses, and override percentages.. Valid values are `preferred|standard|provisional|elite`',
    `producer_type` STRING COMMENT 'Type of producer entity this schedule governs: independent agent, broker, Managing General Agent (MGA), MGA-E, or surplus lines broker. Affects regulatory disclosure and payout rules.. Valid values are `agent|broker|mga|mga_e|surplus_lines`',
    `profit_sharing_rate` DECIMAL(7,4) COMMENT 'Rate applied to the producers eligible profit base to calculate profit-sharing commission. Payable when the producers book achieves profitability targets defined by loss and combined ratio thresholds.',
    `regulatory_filing_required` BOOLEAN COMMENT 'Indicates whether this commission schedule must be filed with the applicable State Department of Insurance (DOI) prior to use, as required by state producer compensation disclosure regulations.',
    `renewal_rate` DECIMAL(7,4) COMMENT 'Specific commission rate applied to Renewal (REN) policy transactions. Typically lower than the New Business (NB) rate, reflecting reduced acquisition cost for retained policies.',
    `schedule_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this commission schedule, used in producer agreements, bordereaux, and system configuration references.. Valid values are `^[A-Z0-9_-]{3,30}$`',
    `schedule_name` STRING COMMENT 'Human-readable name describing this commission schedule, used in producer-facing documents, commission statements, and reporting dashboards.',
    `schedule_status` STRING COMMENT 'Current lifecycle status of the commission schedule: draft (pending approval), active (in force), suspended (temporarily halted), expired (past end date), or superseded (replaced by newer version).. Valid values are `draft|active|suspended|expired|superseded`',
    `schedule_type` STRING COMMENT 'Classifies the commission schedule as base, contingent, override, profit-sharing, or bonus. Drives calculation logic and payout eligibility rules in the commission engine.. Valid values are `base|contingent|override|profit_sharing|bonus`',
    `stat_expense_code` STRING COMMENT 'NAIC statutory expense code used to classify commission payments in the Annual Statement Underwriting and Investment Exhibit. Required for statutory financial reporting.. Valid values are `^[A-Z0-9]{2,10}$`',
    `transaction_type` STRING COMMENT 'Policy transaction type to which this schedule applies: New Business (NB), Renewal (REN), Endorsement (ENDT), Cancellation (CANC), or Reinstatement. Enables differential commission rates by transaction.. Valid values are `NB|REN|ENDT|CANC|REINSTATE`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this commission schedule record. Used for change detection, incremental data loads, and audit trail maintenance.',
    `version_number` BIGINT COMMENT 'Monotonically incrementing version number for this commission schedule. Enables tracking of rate changes and amendments over time while preserving historical rate configurations.',
    CONSTRAINT pk_commission_schedule PRIMARY KEY(`commission_schedule_id`)
) COMMENT 'Reference schedule defining base commission rates, contingent bonus tiers, and override percentages by LOB, policy transaction type (NB, REN), and producer tier. SSOT for commission rate configuration.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` (
    `commission_transaction_id` BIGINT COMMENT 'Unique surrogate identifier for each commission transaction record in the producers domain. Primary key for the commission_transaction data product.',
    `commission_schedule_id` BIGINT COMMENT 'Reference to the commission schedule that defines the applicable rate tiers and rules governing this transaction.',
    `commission_statement_id` BIGINT COMMENT 'Reference to the commission statement (remittance advice) on which this transaction was included and settled.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Commission transactions are denominated in specific currencies. Multi-currency accounting, payment processing, and financial reporting require currency reference.',
    `endorsement_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_endorsement. Business justification: Commissions on endorsements require direct linkage for proper accounting of mid-term premium changes, chargeback processing on cancellations, and reconciliation of',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Commission transactions are categorized by line of business for profitability analysis and producer performance reporting. LOB-level commission analysis requires LOB reference.',
    `original_transaction_id` BIGINT COMMENT 'For reversal or adjustment transactions, references the commission_transaction_id of the original transaction being corrected or reversed.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Commission transactions must link to specific coverages for accurate allocation on multi-coverage policies, reinsurance commission calculations, and coverage-specific',
    `policy_id` BIGINT COMMENT 'Reference to the policy that generated this commission transaction, linking commission to the underlying insured risk.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the licensed producer (agent or broker) who earned or was adjusted for this commission transaction.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Commission transactions are allocated to states for premium tax reporting and regulatory compliance. State-level commission analysis and tax filing require state reference.',
    `accounting_date` DATE COMMENT 'The date on which this commission transaction is recognized in the general ledger for statutory and GAAP financial reporting purposes.',
    `adjustment_amount` DECIMAL(18,2) COMMENT 'Dollar amount of any adjustment applied to the gross commission, including chargebacks on cancellations, pro-rata returns, or manual corrections. Negative for deductions.',
    `approval_status` STRING COMMENT 'Workflow approval state for this commission transaction: PENDING review, APPROVED for payment, REJECTED with reason, or ESCALATED to management.. Valid values are `PENDING|APPROVED|REJECTED|ESCALATED`',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when this commission transaction was approved for payment, providing an audit trail for SOX and internal controls compliance.',
    `approved_by` STRING COMMENT 'Username or employee ID of the internal staff member who approved this commission transaction for payment, supporting SOX audit trail requirements.',
    `cancellation_reason_code` STRING COMMENT 'Standardized code indicating the reason for policy cancellation when transaction_type is CANC, used to determine chargeback applicability and proration method.',
    `chargeback_amount` DECIMAL(18,2) COMMENT 'Amount clawed back from the producer due to policy cancellation, mid-term endorsement reduction, or non-payment of premium. Positive value represents a debit to the producer.',
    `commission_rate` DECIMAL(7,4) COMMENT 'The percentage rate applied to the GWP basis to calculate the gross commission amount, expressed as a decimal (e.g., 0.1200 = 12%).',
    `commission_type` STRING COMMENT 'Categorizes the nature of the commission: Standard, Contingent, Override, Bonus, Chargeback, or Supplemental. [ENUM-REF-CANDIDATE: STANDARD|CONTINGENT|OVERRIDE|BONUS|CHARGEBACK|SUPPLEMENTAL — promote to reference product]. Valid values are `STANDARD|CONTINGENT|OVERRIDE|BONUS|CHARGEBACK|SUPPLEMENTAL`',
    `contingent_commission_flag` BOOLEAN COMMENT 'Indicates whether this transaction includes a contingent (profit-sharing) commission component subject to loss ratio performance thresholds.',
    `cost_center_code` STRING COMMENT 'The financial cost center responsible for this commission expense, used for internal management reporting and expense allocation.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this commission transaction record was first created in the data platform, used for audit trail and data lineage tracking.',
    `dac_eligible_flag` BOOLEAN COMMENT 'Indicates whether this commission qualifies as a Deferred Acquisition Cost (DAC) under US GAAP ASC 944, requiring deferral and amortization over the policy term.',
    `earned_commission_amount` DECIMAL(18,2) COMMENT 'The portion of net commission recognized as earned in the current accounting period, pro-rated over the policy term for DAC and Earned Premium (EP) alignment.',
    `gl_account_code` STRING COMMENT 'The General Ledger (GL) account code to which this commission expense is posted in the statutory and GAAP financial ledger.',
    `gross_commission_amount` DECIMAL(18,2) COMMENT 'The total commission earned before any adjustments, chargebacks, or withholdings. Calculated as GWP basis multiplied by the commission rate.',
    `gwp_basis_amount` DECIMAL(18,2) COMMENT 'The Gross Written Premium (GWP) amount on which the commission rate is applied to calculate the earned commission for this transaction.',
    `net_commission_amount` DECIMAL(18,2) COMMENT 'The final commission amount payable to the producer after applying all adjustments and chargebacks. Equals gross commission plus adjustment amount.',
    `override_commission_amount` DECIMAL(18,2) COMMENT 'Additional override or bonus commission paid to a managing general agent (MGA) or supervising producer above the base commission rate.',
    `payment_date` DATE COMMENT 'The date on which the net commission amount was disbursed to the producer via check, ACH, or wire transfer.',
    `payment_method` STRING COMMENT 'The disbursement method used to pay the producer: ACH (direct deposit), CHECK, WIRE transfer, OFFSET against amounts owed, or CREDIT_MEMO.. Valid values are `ACH|CHECK|WIRE|OFFSET|CREDIT_MEMO`',
    `payment_status` STRING COMMENT 'Indicates whether the commission amount has been disbursed to the producer: UNPAID, PAID, PARTIALLY_PAID, or WITHHELD (e.g., pending E&O compliance).. Valid values are `UNPAID|PAID|PARTIALLY_PAID|WITHHELD`',
    `policy_effective_date` DATE COMMENT 'The date the underlying policy or endorsement became effective, used to align commission earning with the policy period for DAC and UEP calculations.',
    `policy_expiration_date` DATE COMMENT 'The date the underlying policy period ends, used to prorate earned commission over the policy term and compute Deferred Acquisition Cost (DAC).',
    `pro_rata_factor` DECIMAL(7,6) COMMENT 'The pro-rata fraction applied to compute earned or returned commission on mid-term endorsements and cancellations, based on days remaining in the policy term.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether this transaction is a reversal of a previously posted commission, used to identify offsetting entries in reconciliation and audit.',
    `source_system_code` STRING COMMENT 'Identifies the operational system of record that originated this commission transaction (e.g., GUIDEWIRE, DUCK_CREEK, SAPIENS, ORACLE, SAP).. Valid values are `GUIDEWIRE|DUCK_CREEK|SAPIENS|ORACLE|SAP`',
    `source_transaction_reference` STRING COMMENT 'The native transaction identifier from the originating system of record (e.g., Guidewire BillingCenter transaction ID), used for lineage and reconciliation.',
    `tax_withholding_amount` DECIMAL(18,2) COMMENT 'Federal or state income tax withheld from the commission payment for 1099 or backup withholding compliance, reported on IRS Form 1099-MISC.',
    `transaction_date` DATE COMMENT 'The business event date on which the commission was earned or adjusted, typically aligned to the policy effective date or endorsement effective date.',
    `transaction_number` STRING COMMENT 'Externally visible business reference number for this commission transaction, used in producer remittance advice and reconciliation.. Valid values are `^CT-[0-9]{10}$`',
    `transaction_status` STRING COMMENT 'Current lifecycle state of the commission transaction: PENDING (awaiting approval), APPROVED, PAID, REVERSED, VOIDED, or ON_HOLD. [ENUM-REF-CANDIDATE: PENDING|APPROVED|PAID|REVERSED|VOIDED|ON_HOLD — promote to reference product]. Valid values are `PENDING|APPROVED|PAID|REVERSED|VOIDED|ON_HOLD`',
    `transaction_type` STRING COMMENT 'Classifies the policy event that triggered this commission: New Business (NB), Renewal (REN), Endorsement (ENDT), Cancellation (CANC), Reinstatement, or Adjustment.. Valid values are `NB|REN|ENDT|CANC|REINSTATEMENT|ADJUSTMENT`',
    `unearned_commission_amount` DECIMAL(18,2) COMMENT 'The portion of net commission deferred as unearned, corresponding to the Unearned Premium (UEP) reserve for the unexpired policy period.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this commission transaction record was last modified, used for incremental data pipeline processing and audit trail.',
    `withholding_amount` DECIMAL(18,2) COMMENT 'Amount withheld from the producers commission payment for tax withholding, E&O premium offset, or compliance holds per regulatory or contractual requirements.',
    CONSTRAINT pk_commission_transaction PRIMARY KEY(`commission_transaction_id`)
) COMMENT 'Individual commission earned or adjusted for a producer on a specific policy transaction. FKs to producer, commission_schedule, and commission_statement. Captures GWP basis, rate, earned amount, type (NB, REN, ENDT, CANC), and payment status.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` (
    `commission_statement_id` BIGINT COMMENT 'Unique surrogate identifier for the commission statement record. Primary key for the commission_statement data product in the producers domain.',
    `agency_id` BIGINT COMMENT 'Reference to the agency or brokerage entity associated with this statement. Supports agency-level commission aggregation and reporting.',
    `commission_schedule_id` BIGINT COMMENT 'Reference to the commission schedule or rate table applied to calculate earned commissions on this statement. Governs base and contingent rates.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Commission statements are denominated in specific currencies. Multi-currency statement generation, payment processing, and reconciliation require currency reference.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Commission statements are often produced by line of business for producer performance tracking and profitability analysis. LOB-level statement generation requires LOB reference.',
    `producer_agreement_id` BIGINT COMMENT 'Reference to the executed producer appointment agreement governing the commission terms, rates, and conditions applicable to this statement.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the licensed producer (agent or broker) to whom this commission statement is issued. Links to the producer master record.',
    `adjustment_amt` DECIMAL(18,2) COMMENT 'Net miscellaneous adjustments applied to the statement, including corrections from prior periods, manual overrides, or regulatory-mandated recalculations.',
    `bonus_commission_amt` DECIMAL(18,2) COMMENT 'Discretionary or incentive bonus commission awarded to the producer for meeting new business, retention, or quality targets during the period.',
    `cancellation_count` BIGINT COMMENT 'Number of policy cancellations (CANC) attributed to this producer during the settlement period. Drives chargeback calculations and retention performance metrics.',
    `chargeback_amt` DECIMAL(18,2) COMMENT 'Commission previously paid that is reclaimed due to policy cancellations, mid-term endorsements, or return premium events during the settlement period.',
    `contingent_commission_amt` DECIMAL(18,2) COMMENT 'Profit-sharing or contingent commission earned based on loss ratio, volume, or growth performance thresholds agreed in the producer contract.',
    `cost_center_code` STRING COMMENT 'Financial cost center to which the commission expense is allocated for management accounting and expense ratio (ER) reporting purposes.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this commission statement record was first created in the system. Audit trail field for data lineage and SOX compliance.',
    `dac_eligible_amt` DECIMAL(18,2) COMMENT 'Portion of commission on this statement that qualifies as Deferred Acquisition Cost (DAC) under US GAAP ASC 944 or IFRS 17 for capitalization and amortization.',
    `dispute_reason` STRING COMMENT 'Free-text description of the reason provided by the producer or internal reviewer for disputing this commission statement. Populated when is_disputed is true.',
    `dispute_resolution_date` DATE COMMENT 'Date on which a disputed commission statement was formally resolved and approved for payment. Null if no dispute was raised or dispute is still open.',
    `earned_commission_amt` DECIMAL(18,2) COMMENT 'Total commission earned by the producer during the settlement period before adjustments, chargebacks, or contingent additions. Core gross commission figure.',
    `gl_account_code` STRING COMMENT 'General Ledger (GL) account code to which the commission expense on this statement is posted in the financial ledger. Supports statutory and GAAP financial reporting.',
    `gross_written_premium_amt` DECIMAL(18,2) COMMENT 'Total Gross Written Premium (GWP) on policies attributed to this producer during the settlement period. Basis for commission calculation.',
    `is_disputed` BOOLEAN COMMENT 'Indicates whether the producer has formally disputed any line items or the total amount on this commission statement. Triggers dispute resolution workflow.',
    `loss_ratio` DECIMAL(7,4) COMMENT 'Loss Ratio (LR) for the producers book of business during the settlement period. Used to determine eligibility for contingent commission and profit-sharing.',
    `net_payable_amt` DECIMAL(18,2) COMMENT 'Final net amount payable to the producer after summing earned, contingent, and bonus commissions and subtracting chargebacks and adjustments.',
    `new_business_policy_count` BIGINT COMMENT 'Count of newly bound policies (NB) attributed to this producer during the settlement period. Supports new business incentive and bonus commission calculations.',
    `notes` STRING COMMENT 'Free-text notes or remarks added by commission administrators regarding special circumstances, manual overrides, or producer communications related to this statement.',
    `payment_date` DATE COMMENT 'Date on which the commission payment was or is scheduled to be remitted to the producer. Used for cash flow and accounts payable reporting.',
    `payment_method` STRING COMMENT 'Method used to remit the net commission payable to the producer (ACH direct deposit, paper check, wire transfer, or offset against amounts owed).. Valid values are `ACH|check|wire|offset`',
    `payment_reference` STRING COMMENT 'Reference number of the payment transaction (ACH, check, wire) issued to settle this commission statement. Links to the accounts payable payment record.',
    `policy_count` BIGINT COMMENT 'Number of in-force or transacted policies attributed to this producer during the settlement period. Used for volume-based commission tier evaluation.',
    `prior_period_balance_amt` DECIMAL(18,2) COMMENT 'Outstanding balance carried forward from the previous settlement period, including unpaid amounts or disputed items not yet resolved.',
    `producer_type` STRING COMMENT 'Classification of the producer receiving this statement. Determines applicable commission schedules, regulatory disclosures, and tax reporting requirements.. Valid values are `agent|broker|managing_general_agent|surplus_lines_broker`',
    `regulatory_disclosure_required` BOOLEAN COMMENT 'Indicates whether this commission statement requires regulatory disclosure to the insured or state Department of Insurance per applicable market conduct rules.',
    `renewal_policy_count` BIGINT COMMENT 'Count of renewed policies (REN) attributed to this producer during the settlement period. Supports retention-based commission and No Claims Bonus (NCB) calculations.',
    `settlement_frequency` STRING COMMENT 'Frequency at which commission statements are generated and settled for this producer. Drives the statement cycle and payment schedule.. Valid values are `weekly|bi-weekly|monthly|quarterly`',
    `settlement_period_end_date` DATE COMMENT 'Last calendar date of the commission settlement period covered by this statement. Defines the inclusive end of the earning window.',
    `settlement_period_start_date` DATE COMMENT 'First calendar date of the commission settlement period covered by this statement. Defines the inclusive start of the earning window.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record that originated this commission statement (e.g., Duck Creek Billing, Guidewire BillingCenter, Sapiens IDIT).. Valid values are `DUCK_CREEK|GUIDEWIRE|SAPIENS|MANUAL`',
    `statement_date` DATE COMMENT 'The business date on which the commission statement was formally generated and issued to the producer. Represents the principal real-world event date.',
    `statement_number` STRING COMMENT 'Externally visible, human-readable identifier for the commission statement used in producer communications, remittance advice, and reconciliation.. Valid values are `^CS-[0-9]{4}-[0-9]{2}-[0-9]{6}$`',
    `statement_status` STRING COMMENT 'Current lifecycle state of the commission statement, from initial draft through issuance, dispute resolution, approval, payment, and voiding.. Valid values are `draft|issued|disputed|approved|paid|voided`',
    `statement_type` STRING COMMENT 'Classification of the statement indicating whether it is a standard periodic statement, a supplemental issuance, a correction of a prior statement, or a final settlement.. Valid values are `regular|supplemental|corrected|final`',
    `tax_form_type` STRING COMMENT 'IRS tax form type applicable to the commission payments on this statement (e.g., 1099-NEC for independent agents, W-2 for captive agents, none if below threshold).. Valid values are `1099-NEC|1099-MISC|W-2|none`',
    `tax_withheld_amt` DECIMAL(18,2) COMMENT 'Amount of income tax or backup withholding deducted from the commission payment per IRS or applicable state tax authority requirements.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this commission statement record. Supports audit trail, change detection, and incremental data pipeline processing.',
    CONSTRAINT pk_commission_statement PRIMARY KEY(`commission_statement_id`)
) COMMENT 'Periodic statement issued to a producer or agency summarizing commission transactions within a settlement period. FKs to producer. Tracks statement date, total earned, adjustments, net payable, and payment reference.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` (
    `contingent_bonus_id` BIGINT COMMENT 'Unique surrogate identifier for a contingent or profit-sharing bonus record for a producer or agency.',
    `agency_id` BIGINT COMMENT 'Reference to the agency entity associated with this contingent bonus, supporting agency-level aggregation.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Contingent bonuses are denominated in specific currencies. Multi-currency bonus calculation, payment processing, and financial reporting require currency reference.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Contingent bonuses are calculated based on line of business performance metrics (loss ratio, growth, volume). LOB-specific bonus calculation requires LOB reference.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer or agency for whom this contingent bonus is calculated.',
    `actual_lr` DECIMAL(7,4) COMMENT 'Actual Loss Ratio (LR) achieved by the producer during the measurement period, calculated as incurred losses divided by earned premium.',
    `adjustment_amount` DECIMAL(18,2) COMMENT 'Any positive or negative adjustment applied to the earned bonus amount for disputes, corrections, or contractual modifications prior to final payment.',
    `approval_date` DATE COMMENT 'Date on which the contingent bonus was approved by the authorized underwriting or finance authority for payment.',
    `approved_by` STRING COMMENT 'Name or employee identifier of the underwriting or finance authority who approved this contingent bonus for payment.',
    `bonus_number` STRING COMMENT 'Externally-known alphanumeric identifier for this contingent bonus record, used in producer statements and settlement documents.. Valid values are `^CB-[0-9]{4}-[0-9]{6}$`',
    `bonus_rate` DECIMAL(7,4) COMMENT 'Percentage rate applied to the eligible premium base to calculate the contingent bonus earned amount, expressed as a decimal (e.g., 0.05 = 5%).',
    `bonus_status` STRING COMMENT 'Current lifecycle state of the contingent bonus record: calculated, approved, disputed, paid, voided, or pending review.. Valid values are `calculated|approved|disputed|paid|voided|pending_review`',
    `bonus_type` STRING COMMENT 'Classification of the bonus arrangement: profit sharing, contingent commission, growth, retention, volume, or performance. [ENUM-REF-CANDIDATE: promote to reference product if values expand]. Valid values are `profit_sharing|contingent_commission|growth_bonus|retention_bonus|volume_bonus|performance_bonus`',
    `calculation_date` DATE COMMENT 'Date on which the contingent bonus amount was formally calculated based on the measurement period results.',
    `contract_reference` STRING COMMENT 'Reference number or identifier of the producer agency agreement or contingent commission contract governing this bonus arrangement.',
    `cost_center_code` STRING COMMENT 'Finance cost center code to which the contingent bonus expense is allocated for management reporting and statutory expense reporting.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this contingent bonus record was first created in the system, used for audit trail and data lineage.',
    `dispute_reason` STRING COMMENT 'Free-text description of the reason for a dispute raised against this contingent bonus calculation. Populated only when bonus_status is disputed.',
    `earned_amount` DECIMAL(18,2) COMMENT 'Gross contingent bonus amount earned by the producer based on the bonus rate applied to the eligible premium base after meeting all thresholds.',
    `ep_amount` DECIMAL(18,2) COMMENT 'Earned Premium (EP) for the producers book during the measurement period, used as the denominator in loss ratio calculations.',
    `gl_account_code` STRING COMMENT 'General Ledger (GL) account code in Oracle Financials or SAP FI to which the contingent bonus expense is posted.',
    `growth_qualified` BOOLEAN COMMENT 'Indicates whether the producer met the minimum GWP growth rate target during the measurement period to qualify for the growth component.',
    `growth_target_rate` DECIMAL(7,4) COMMENT 'Minimum GWP growth rate the producer must achieve to qualify for the growth component of the contingent bonus, expressed as a decimal.',
    `gwp_amount` DECIMAL(18,2) COMMENT 'Total Gross Written Premium (GWP) produced by the producer during the measurement period, used as the premium volume base for bonus calculation.',
    `gwp_growth_rate` DECIMAL(7,4) COMMENT 'Year-over-year GWP growth rate achieved by the producer during the measurement period, expressed as a decimal (e.g., 0.10 = 10%).',
    `incurred_losses_amount` DECIMAL(18,2) COMMENT 'Total incurred losses including paid losses and case reserves for the producers book during the measurement period.',
    `lae_amount` DECIMAL(18,2) COMMENT 'Total Loss Adjustment Expense (LAE) including ALAE and ULAE attributable to the producers book during the measurement period.',
    `lr_qualified` BOOLEAN COMMENT 'Indicates whether the producer met the LR threshold requirement during the measurement period. True if actual LR is at or below lr_threshold.',
    `lr_threshold` DECIMAL(7,4) COMMENT 'Maximum allowable Loss Ratio (LR) that the producer must achieve to qualify for the contingent bonus. Bonus is forfeited if actual LR exceeds this threshold.',
    `measurement_period_end_date` DATE COMMENT 'End date of the performance measurement period over which loss ratio, premium volume, and growth are evaluated for this bonus.',
    `measurement_period_start_date` DATE COMMENT 'Start date of the performance measurement period over which loss ratio, premium volume, and growth are evaluated for this bonus.',
    `net_payable_amount` DECIMAL(18,2) COMMENT 'Final net contingent bonus amount payable to the producer after applying all adjustments. Equals earned_amount plus adjustment_amount.',
    `notes` STRING COMMENT 'Free-text field for additional commentary, underwriter remarks, or audit notes related to this contingent bonus record.',
    `nwp_amount` DECIMAL(18,2) COMMENT 'Net Written Premium (NWP) after reinsurance cessions for the producer during the measurement period, used in net-basis bonus calculations.',
    `overall_qualified` BOOLEAN COMMENT 'Indicates whether the producer met ALL qualification criteria (LR, volume, growth) and is eligible to receive the contingent bonus payment.',
    `payment_date` DATE COMMENT 'Date on which the contingent bonus was disbursed to the producer or agency. Null if not yet paid.',
    `payment_method` STRING COMMENT 'Method by which the contingent bonus is disbursed to the producer: ACH, check, wire transfer, or credit memo applied to future commissions.. Valid values are `ach|check|wire|credit_memo`',
    `prior_year_gwp_amount` DECIMAL(18,2) COMMENT 'Producers GWP in the prior measurement period, used as the baseline for year-over-year growth rate calculation.',
    `program_year` BIGINT COMMENT 'Calendar or fiscal year of the contingent bonus program under which this record is calculated (e.g., 2024).',
    `tax_form_type` STRING COMMENT 'IRS tax form type applicable to this contingent bonus payment (e.g., 1099-NEC for independent producers, W-2 for captive agents).. Valid values are `1099-MISC|1099-NEC|W-2|none`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this contingent bonus record, used for audit trail and incremental data processing.',
    `volume_qualified` BOOLEAN COMMENT 'Indicates whether the producer met the minimum premium volume target during the measurement period to qualify for the volume component.',
    `volume_target_amount` DECIMAL(18,2) COMMENT 'Minimum GWP or NWP volume the producer must write during the measurement period to qualify for the volume component of the contingent bonus.',
    `withholding_tax_amount` DECIMAL(18,2) COMMENT 'Federal or state withholding tax amount deducted from the contingent bonus payment where applicable per IRS or state tax regulations.',
    CONSTRAINT pk_contingent_bonus PRIMARY KEY(`contingent_bonus_id`)
) COMMENT 'Contingent or profit-sharing bonus calculated for a producer or agency based on loss ratio, premium volume, and growth targets over a measurement period. Tracks earned amount, LR threshold, and payment status.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` (
    `producer_agreement_id` BIGINT COMMENT 'Unique surrogate identifier for the producer agreement record in the Pc_Insurance data platform.',
    `agency_id` BIGINT COMMENT 'Reference to the agency or brokerage entity that is the contracting party when the agreement is at the agency level rather than the individual producer level.',
    `commission_schedule_id` BIGINT COMMENT 'Reference to the commission plan that governs base and contingent commission rates, profit-sharing tiers, and override structures applicable to this agreement.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Producer agreements define which lines of business the producer is authorized to write. Authority validation and commission calculation require LOB reference.',
    `prior_agreement_producer_agreement_id` BIGINT COMMENT 'Reference to the predecessor producer agreement that this version supersedes, enabling version chain traversal for audit and compliance.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the licensed producer or agency that is party to this agreement.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Producer agreements specify governing law state and primary territory. Contract management, dispute resolution, and regulatory compliance require state reference.',
    `agreement_number` STRING COMMENT 'Externally visible, human-readable identifier assigned to this producer agreement, used on correspondence, bordereaux, and commission statements.. Valid values are `^PA-[0-9]{4}-[0-9]{6}$`',
    `agreement_status` STRING COMMENT 'Current lifecycle state of the producer agreement: draft, active, suspended, terminated, expired, or pending renewal.. Valid values are `draft|active|suspended|terminated|expired|pending_renewal`',
    `agreement_type` STRING COMMENT 'Classification of the contractual relationship: agency (appointed agent), broker, Managing General Agent (MGA), MGA with delegated authority, surplus lines broker, or direct writer.. Valid values are `agency|broker|mga|mga_delegated|surplus_lines|direct`',
    `appointment_state_codes` STRING COMMENT 'Pipe-delimited list of US state codes where the producer holds a valid insurance license and appointment with Pc_Insurance, e.g., CA|TX|NY.',
    `audit_rights_flag` BOOLEAN COMMENT 'Indicates whether Pc_Insurance retains the contractual right to audit the producers books, records, and premium trust accounts under this agreement.',
    `auto_renewal_flag` BOOLEAN COMMENT 'Indicates whether this producer agreement automatically renews for successive terms upon expiration unless either party provides written notice of non-renewal.',
    `base_commission_rate` DECIMAL(7,4) COMMENT 'Standard commission rate expressed as a decimal fraction of Written Premium (WP) payable to the producer for new business and renewals under this agreement.',
    `binding_authority_flag` BOOLEAN COMMENT 'Indicates whether the producer has delegated binding authority to commit coverage on behalf of Pc_Insurance without prior underwriting approval.',
    `binding_authority_limit` DECIMAL(18,2) COMMENT 'Maximum single-risk Total Insured Value (TIV) or premium amount in USD that the producer may bind without referral to Pc_Insurance underwriting.',
    `compliance_training_required_flag` BOOLEAN COMMENT 'Indicates whether the producer must complete Pc_Insurance-mandated compliance and product training as a condition of maintaining active agreement status.',
    `contingent_commission_flag` BOOLEAN COMMENT 'Indicates whether the producer is eligible for contingent or profit-sharing commission based on loss ratio or volume performance thresholds defined in the commission plan.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this producer agreement record was first created in the Pc_Insurance data platform, used for audit trail and data lineage.',
    `e_and_o_coverage_limit` DECIMAL(18,2) COMMENT 'Minimum required Errors and Omissions (E&O) professional liability coverage limit in USD that the producer must maintain as a condition of this agreement.',
    `e_and_o_expiration_date` DATE COMMENT 'Expiration date of the producers current Errors and Omissions (E&O) insurance policy on file with Pc_Insurance for compliance monitoring.',
    `e_and_o_required_flag` BOOLEAN COMMENT 'Indicates whether the producer is contractually required to maintain Errors and Omissions (E&O) professional liability insurance as a condition of this agreement.',
    `effective_date` DATE COMMENT 'Date on which the producer agreement becomes legally binding and the producer is authorized to transact business on behalf of Pc_Insurance.',
    `exclusivity_flag` BOOLEAN COMMENT 'Indicates whether the producer is contractually restricted from placing competing lines of business with other insurers for the LOBs covered by this agreement.',
    `execution_date` DATE COMMENT 'Date on which both parties signed and executed the producer agreement. May differ from effective_date if the agreement is backdated or post-dated.',
    `expiration_date` DATE COMMENT 'Date on which the producer agreement expires or is scheduled to terminate. Null for evergreen agreements with no fixed end date.',
    `insurer_signatory_name` STRING COMMENT 'Full name of the Pc_Insurance officer or authorized representative who executed this agreement on behalf of the company.',
    `last_compliance_review_date` DATE COMMENT 'Date of the most recent compliance review or market conduct audit conducted on this producer agreement by Pc_Insurance or a state regulator.',
    `lob_scope` STRING COMMENT 'Pipe-delimited list of Lines of Business (LOBs) the producer is authorized to write under this agreement, e.g., personal_auto|homeowners|commercial_gl|bop|wc.',
    `loss_ratio_threshold` DECIMAL(7,4) COMMENT 'Maximum permissible Loss Ratio (LR) expressed as a decimal fraction above which contingent commission is forfeited or binding authority may be suspended.',
    `ncb_eligible_flag` BOOLEAN COMMENT 'Indicates whether the producers book of business qualifies for No Claims Bonus (NCB) incentive adjustments under the commission plan.',
    `notice_period_days` BIGINT COMMENT 'Number of calendar days advance written notice required by either party to terminate this agreement, as specified in the contract terms.',
    `override_commission_rate` DECIMAL(7,4) COMMENT 'Additional override or bonus commission rate payable on top of the base rate, typically granted to Managing General Agents (MGAs) or high-volume producers.',
    `premium_trust_required_flag` BOOLEAN COMMENT 'Indicates whether the producer is required to maintain a separate premium trust account for policyholder funds collected on behalf of Pc_Insurance.',
    `premium_volume_minimum` DECIMAL(18,2) COMMENT 'Minimum annual Written Premium (WP) volume in USD the producer commits to place with Pc_Insurance to maintain agreement terms and avoid renegotiation.',
    `premium_volume_target` DECIMAL(18,2) COMMENT 'Annual Written Premium (WP) production target in USD agreed between Pc_Insurance and the producer for performance tracking and contingent commission qualification.',
    `producer_signatory_name` STRING COMMENT 'Full legal name of the individual who executed this agreement on behalf of the producer or agency.',
    `renewal_term_months` BIGINT COMMENT 'Duration in months of each automatic renewal term when auto_renewal_flag is true. Typically 12 months for annual agreements.',
    `sub_producer_allowed_flag` BOOLEAN COMMENT 'Indicates whether the producer is permitted to appoint sub-producers or sub-agents under this agreement to solicit business on their behalf.',
    `surplus_lines_flag` BOOLEAN COMMENT 'Indicates whether the producer is authorized to place surplus lines (non-admitted) business under this agreement, subject to state surplus lines regulations.',
    `termination_date` DATE COMMENT 'Actual date on which the producer agreement was terminated, cancelled, or non-renewed. Distinct from expiration_date which is the scheduled end date.',
    `termination_reason` STRING COMMENT 'Reason code for agreement termination when agreement_status is terminated or expired. [ENUM-REF-CANDIDATE: voluntary|non_renewal|regulatory_action|performance|fraud|mutual_consent|other — promote to reference product]',
    `territory_scope` STRING COMMENT 'Pipe-delimited list of US state codes or territories where the producer is authorized to solicit and bind business under this agreement, e.g., CA|TX|NY|FL.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this producer agreement record, used for change tracking, audit trail, and incremental data loading.',
    `version_number` BIGINT COMMENT 'Sequential version counter incremented each time the agreement terms are amended and a new version is executed. Version 1 is the original agreement.',
    CONSTRAINT pk_producer_agreement PRIMARY KEY(`producer_agreement_id`)
) COMMENT 'Contractual producer agreement between Pc_Insurance and a producer or agency defining compensation terms, binding authority, LOB scope, territory, and compliance obligations. Tracks version, effective dates, and signatory.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` (
    `binding_authority_id` BIGINT COMMENT 'Unique surrogate identifier for a delegated binding authority record granted to a producer or Managing General Agent (MGA).',
    `coverage_form_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_form. Business justification: Binding authority grants specify which coverage forms producers can bind. Essential for underwriting controls, compliance validation, and preventing unauthorized coverage binding.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Binding authority limits are denominated in specific currencies. Multi-currency authority validation and risk management require currency reference. Removes denormalized currency_code.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Binding authorities are granted for specific lines of business. Authority validation and underwriting control require LOB reference.',
    `producer_agreement_id` BIGINT COMMENT 'Foreign key linking to producers.producer_agreement. Business justification: Binding authority is granted under a producer agreement. Currently tracked via string reference (agreement_ref).',
    `producers_producer_id` BIGINT COMMENT 'Reference to the licensed producer, agent, broker, or MGA to whom this binding authority is delegated.',
    `admitted_carrier_flag` BOOLEAN COMMENT 'Indicates whether the insurer backing this binding authority is an admitted (licensed) carrier in the applicable state jurisdictions.',
    `aggregate_annual_limit` DECIMAL(18,2) COMMENT 'Maximum total gross written premium (GWP) or total insured value the producer may bind under this authority within a single policy year.',
    `approval_date` DATE COMMENT 'Date on which the binding authority was formally approved by the insurers underwriting authority committee.',
    `approved_by` STRING COMMENT 'Name or employee ID of the underwriting officer or delegated authority committee member who approved this binding authority.',
    `audit_frequency` STRING COMMENT 'Frequency at which the insurer conducts underwriting audits of policies bound under this authority to verify compliance with guidelines.. Valid values are `monthly|quarterly|semi_annual|annual|on_demand`',
    `authority_name` STRING COMMENT 'Descriptive name or title of the binding authority arrangement, e.g., Commercial Property MGA Facility 2024.',
    `authority_number` STRING COMMENT 'Externally-known unique reference number assigned to this binding authority agreement, used on bordereaux and regulatory filings.. Valid values are `^BA-[A-Z0-9]{4,20}$`',
    `authority_status` STRING COMMENT 'Current lifecycle state of the binding authority. Drives eligibility to bind new policies. [ENUM-REF-CANDIDATE: active|suspended|expired|terminated|pending_approval|under_review — promote to reference product]. Valid values are `active|suspended|expired|terminated|pending_approval|under_review`',
    `authority_type` STRING COMMENT 'Classification of the delegated authority arrangement. [ENUM-REF-CANDIDATE: MGA|Coverholder|Wholesale_Broker|Surplus_Lines|Program_Administrator|Lloyd_Coverholder — promote to reference product]. Valid values are `MGA|Coverholder|Wholesale_Broker|Surplus_Lines|Program_Administrator|Lloyd_Coverholder`',
    `cat_exposed_flag` BOOLEAN COMMENT 'Indicates whether risks bound under this authority may include catastrophe (CAT) exposed properties such as coastal wind or earthquake zones.',
    `commission_rate_pct` DECIMAL(7,4) COMMENT 'Standard commission rate (as a percentage of gross written premium) payable to the producer for policies bound under this authority.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this binding authority record was first created in the system of record, used for audit trail and data lineage.',
    `effective_date` DATE COMMENT 'Date on which the binding authority becomes operative and the producer may begin binding risks on behalf of the insurer.',
    `eligible_coverage_classes` STRING COMMENT 'Comma-delimited list of coverage class or program codes (e.g., personal_auto, commercial_property, inland_marine) permitted under this authority.',
    `eligible_lob_codes` STRING COMMENT 'Comma-delimited list of NAIC or ISO line-of-business codes (e.g., GL, CPP, BOP, WC, APD) that the producer is authorized to bind under this authority.',
    `eligible_risk_classes` STRING COMMENT 'Comma-delimited list of risk class or NAICS/SIC codes the producer may bind. Restricts authority to specific occupancy or industry segments.',
    `excluded_risk_classes` STRING COMMENT 'Comma-delimited list of NAICS/SIC or ISO risk class codes explicitly prohibited from being bound under this authority.',
    `excluded_zip_codes` STRING COMMENT 'Comma-delimited list of US ZIP codes or postal code prefixes explicitly excluded from the binding authority territory, e.g., CAT-prone coastal zones.',
    `expiration_date` DATE COMMENT 'Date on which the binding authority ceases to be valid. Null indicates an open-ended authority subject to termination notice.',
    `is_suspended` BOOLEAN COMMENT 'Indicates whether the binding authority is currently suspended. True prevents new policy binding; used for real-time eligibility checks.',
    `last_audit_date` DATE COMMENT 'Date of the most recent underwriting compliance audit conducted against this binding authority.',
    `loss_ratio_threshold_pct` DECIMAL(7,4) COMMENT 'Maximum permissible loss ratio (LR) on business bound under this authority before suspension or commission clawback is triggered.',
    `max_cat_tiv` DECIMAL(18,2) COMMENT 'Maximum aggregate total insured value (TIV) for CAT-exposed risks the producer may bind under this authority in a single policy year.',
    `max_deductible_amount` DECIMAL(18,2) COMMENT 'Maximum deductible or SIR permitted on any single policy bound under this authority, in the authority currency.',
    `max_policy_limit` DECIMAL(18,2) COMMENT 'The ceiling on the total insured value (TIV) or per-occurrence policy limit that the producer is authorized to bind on a single policy, in USD.',
    `max_single_risk_limit` DECIMAL(18,2) COMMENT 'Maximum sum insured (SI) the producer may bind for any single risk location or insured object, in USD. Distinct from aggregate policy limit.',
    `min_deductible_amount` DECIMAL(18,2) COMMENT 'Minimum deductible or self-insured retention (SIR) that must be applied to any policy bound under this authority, in the authority currency.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code of the insurer (carrier) on whose behalf the producer is authorized to bind policies under this authority.. Valid values are `^[0-9]{5}$`',
    `next_audit_date` DATE COMMENT 'Scheduled date for the next underwriting compliance audit of policies bound under this authority.',
    `notice_period_days` BIGINT COMMENT 'Number of calendar days advance notice required by either party to cancel or non-renew this binding authority agreement.',
    `profit_commission_rate_pct` DECIMAL(7,4) COMMENT 'Contingent profit commission rate payable to the producer if the loss ratio (LR) on bound business falls below the agreed threshold.',
    `program_code` STRING COMMENT 'Internal program or facility code linking this binding authority to a specific underwriting program, rate filing, or product configuration in PolicyCenter.',
    `rate_filing_reference` STRING COMMENT 'State DOI rate and form filing reference number applicable to the products bound under this authority, ensuring regulatory compliance.',
    `reinsurance_required_flag` BOOLEAN COMMENT 'Indicates whether facultative (FAC) or treaty reinsurance (RI) placement is mandatory before the producer may bind risks under this authority.',
    `renewal_type` STRING COMMENT 'Indicates whether this binding authority renews automatically (auto), requires manual review (manual), or will not be renewed (non_renew) at expiration.. Valid values are `auto|manual|non_renew`',
    `surplus_lines_flag` BOOLEAN COMMENT 'Indicates whether this binding authority covers surplus lines (non-admitted) business, triggering surplus lines tax and stamping office filing requirements.',
    `suspension_date` DATE COMMENT 'Date on which the binding authority was suspended, preventing new policy binding until reinstatement. Null if never suspended.',
    `suspension_reason` STRING COMMENT 'Free-text explanation of why the binding authority was suspended, e.g., regulatory action, loss ratio breach, or compliance failure.',
    `territory_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for the primary country jurisdiction of this binding authority, e.g., USA, CAN, GBR.. Valid values are `^[A-Z]{3}$`',
    `territory_states` STRING COMMENT 'Comma-delimited list of US state abbreviations (e.g., CA,TX,FL) defining the geographic territory within which the producer may bind risks.',
    `underwriting_guidelines_version` STRING COMMENT 'Version identifier of the underwriting guidelines document that governs risk selection and pricing for policies bound under this authority.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this binding authority record, supporting audit trail and change management requirements.',
    CONSTRAINT pk_binding_authority PRIMARY KEY(`binding_authority_id`)
) COMMENT 'Delegated binding authority granted to a producer or MGA specifying maximum policy limit, eligible LOBs, geographic territory, and risk class restrictions. Tracks authority ceiling, expiration, and suspension flags.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` (
    `onboarding_case_id` BIGINT COMMENT 'Unique surrogate identifier for the producer onboarding and compliance case record in the silver layer.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: Onboarding case references commission schedule via string code. Adding proper FK enables referential integrity and eliminates need to JOIN on business key.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer party record associated with this onboarding case.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Onboarding cases track producer resident state for licensing and appointment processing. State-specific onboarding workflows and regulatory compliance require state reference.',
    `application_received_date` DATE COMMENT 'Date the producer onboarding application was formally received and logged, marking the start of the onboarding case lifecycle.',
    `appointment_effective_date` DATE COMMENT 'Date the producer appointment becomes legally effective in each appointment state, enabling the producer to bind business on behalf of Pc_Insurance.',
    `appointment_filing_date` DATE COMMENT 'Date the producer appointment was formally filed with the applicable state Departments of Insurance following successful completion of all onboarding checks.',
    `appointment_state_codes` STRING COMMENT 'Pipe-delimited list of two-letter state codes where the producer is being appointed or has active appointments with Pc_Insurance, per DOI filing requirements.',
    `assigned_uw_reviewer` STRING COMMENT 'Name or employee identifier of the underwriting or compliance officer assigned to review and adjudicate the producer onboarding case.',
    `background_check_date` DATE COMMENT 'Date the background check screening was completed and results were received from the third-party screening provider during producer onboarding.',
    `background_check_provider` STRING COMMENT 'Name of the third-party vendor engaged to conduct the producer background screening, used for audit trail and vendor management tracking.',
    `background_check_status` STRING COMMENT 'Current status of the criminal background check conducted on the producer applicant as part of the onboarding compliance screening process.. Valid values are `not_started|in_progress|clear|adverse|pending_review`',
    `binding_authority_granted` BOOLEAN COMMENT 'Indicates whether the producer has been granted binding authority to commit Pc_Insurance to coverage without prior underwriting approval, per the producer agreement.',
    `binding_authority_limit` DECIMAL(18,2) COMMENT 'Maximum single-risk premium or total insured value the producer is authorized to bind without prior UW approval, expressed in USD per the producer agreement.',
    `case_closed_timestamp` TIMESTAMP COMMENT 'Timestamp when the onboarding case was formally closed, either through approval and system activation, rejection, or withdrawal.',
    `case_number` STRING COMMENT 'Externally visible business identifier for the onboarding case, used in correspondence and regulatory filings with state Departments of Insurance.. Valid values are `^OB-[0-9]{4}-[0-9]{6}$`',
    `case_opened_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the onboarding case record was created in the producer management system, serving as the audit creation marker.',
    `case_status` STRING COMMENT 'Current workflow state of the producer onboarding case lifecycle from application intake through appointment activation or rejection.. Valid values are `pending|in_review|approved|rejected|withdrawn|suspended`',
    `channel_type` STRING COMMENT 'Distribution channel classification for the producer, distinguishing independent agents, captive agents, brokers, and MGAs for commission structure and contract assignment.. Valid values are `independent_agent|captive_agent|broker|mga|direct`',
    `contingent_commission_eligible` BOOLEAN COMMENT 'Indicates whether the producer qualifies for contingent or profit-sharing commission arrangements based on loss ratio and volume performance thresholds.',
    `contracting_entity` STRING COMMENT 'Legal name of the Pc_Insurance entity or subsidiary with which the producer agreement is being executed, relevant for multi-company carrier groups.',
    `doi_disciplinary_review_date` DATE COMMENT 'Date the DOI disciplinary history and market-conduct review was completed for the producer applicant during the onboarding compliance process.',
    `doi_disciplinary_review_status` STRING COMMENT 'Status of the review of DOI disciplinary actions, market-conduct orders, and license revocations against the producer across all appointment states.. Valid values are `not_started|in_progress|clear|adverse|pending_review`',
    `e_o_coverage_verified` BOOLEAN COMMENT 'Indicates whether the producers Errors and Omissions (E&O) professional liability insurance coverage has been verified as meeting Pc_Insurance minimum requirements.',
    `e_o_policy_expiry_date` DATE COMMENT 'Expiration date of the producers E&O professional liability policy, used to trigger renewal verification and prevent appointment lapses.',
    `estimated_annual_premium_volume` DECIMAL(18,2) COMMENT 'Producers estimated annual gross written premium (GWP) volume to be placed with Pc_Insurance, used for capacity planning and commission tier assignment.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the onboarding case record, used for change tracking and audit trail compliance.',
    `license_verification_date` DATE COMMENT 'Date on which the most recent producer license verification was completed against NIPR or state DOI records during the onboarding process.',
    `license_verification_status` STRING COMMENT 'Current status of the producer license verification check performed via NIPR or state DOI systems to confirm active, valid licensure in all appointment states.. Valid values are `not_started|in_progress|verified|failed|expired`',
    `lob_authorizations` STRING COMMENT 'Pipe-delimited list of P&C lines of business the producer is authorized to sell, such as personal auto, homeowners, CGL, WC, BOP, and CPP.',
    `naic_producer_code` STRING COMMENT 'NAIC-assigned unique producer code used for interstate licensing, appointment filings, and statutory reporting across all state Departments of Insurance.. Valid values are `^[0-9]{7}$`',
    `npn` STRING COMMENT 'Unique National Producer Number assigned by NIPR/NAIC, used as the primary cross-state identifier for producer licensing and appointment verification.. Valid values are `^[0-9]{1,10}$`',
    `ofac_screening_date` DATE COMMENT 'Date the OFAC and sanctions screening was last performed on the producer applicant, required for BSA/AML compliance documentation.',
    `ofac_screening_status` STRING COMMENT 'Result of the OFAC Specially Designated Nationals (SDN) and sanctions list screening performed on the producer applicant as required by BSA/AML compliance.. Valid values are `not_started|clear|potential_match|confirmed_match|escalated`',
    `prior_carrier_loss_ratio` DECIMAL(5,4) COMMENT 'Historical loss ratio (LR) reported by the producer from prior carrier relationships, used by UW to assess book quality during onboarding risk evaluation.',
    `producer_agreement_type` STRING COMMENT 'Type of producer agreement governing the relationship, determining commission schedules, binding authority, and regulatory obligations.. Valid values are `standard_agency|broker|mga|surplus_lines|program_administrator`',
    `producer_dba_name` STRING COMMENT 'Trade or DBA name under which the producer operates, if different from the legal name. Required for agency and broker appointment filings.',
    `producer_legal_name` STRING COMMENT 'Full legal name of the producer entity or individual as submitted on the onboarding application, used for DOI appointment filings and NAIC records.',
    `producer_tax_number` STRING COMMENT 'Federal Employer Identification Number (FEIN) for agencies or Social Security Number (SSN) for individual producers, required for IRS 1099 commission reporting.. Valid values are `^[0-9]{2}-[0-9]{7}$|^[0-9]{3}-[0-9]{2}-[0-9]{4}$`',
    `producer_type` STRING COMMENT 'Classification of the producer entity type, distinguishing individual agents from agencies, brokers, MGAs, and surplus lines brokers for licensing and commission purposes.. Valid values are `individual|agency|broker|managing_general_agent|surplus_lines_broker`',
    `regulatory_compliance_notes` STRING COMMENT 'Free-text field capturing compliance officer observations, state DOI correspondence notes, or market-conduct findings relevant to the onboarding case review.',
    `rejection_reason_code` STRING COMMENT 'Standardized code indicating the primary reason an onboarding case was rejected, used for regulatory reporting and adverse action notification compliance.. Valid values are `adverse_background|license_invalid|ofac_match|doi_disciplinary|e_o_insufficient|incomplete_application`',
    `rejection_reason_notes` STRING COMMENT 'Free-text narrative providing additional detail on the reason for onboarding case rejection, supplementing the rejection reason code for underwriting and compliance review.',
    `system_activation_date` DATE COMMENT 'Date the producer was activated in Pc_Insurance operational systems (PolicyCenter, BillingCenter) enabling quoting, binding, and commission processing.',
    `years_in_business` BIGINT COMMENT 'Number of years the producer entity or individual has been actively operating in the P&C insurance distribution market, used in UW risk scoring.',
    CONSTRAINT pk_onboarding_case PRIMARY KEY(`onboarding_case_id`)
) COMMENT 'Single authoritative producer onboarding and compliance case covering application intake, background check, license verification, DOI disciplinary and market-conduct review, and OFAC/sanctions screening through appointment filing and system activation.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`producers`.`termination` (
    `termination_id` BIGINT COMMENT 'Unique surrogate identifier for a producer appointment or agreement termination record in the Producer Management and Licensing System.',
    `appointment_id` BIGINT COMMENT 'Reference to the producer appointment record being terminated. Links this termination to the originating appointment in the producer management system.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Terminations may be line-of-business specific when appointments are LOB-specific. Regulatory reporting and producer authority tracking require LOB reference. Removes denormalized lob_code.',
    `producer_agreement_id` BIGINT COMMENT 'Reference to the producer agency or broker agreement being terminated, if the termination applies to a contractual agreement rather than a state appointment.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Terminations are state-specific regulatory events requiring DOI notification. Regulatory reporting and compliance tracking require state reference. Removes denormalized state_of_appointment.',
    `termination_producers_producer_id` BIGINT COMMENT 'Reference to the producer (agent or broker) whose appointment or agreement is being terminated.',
    `termination_successor_producer_producers_producer_id` BIGINT COMMENT 'Reference to the producer appointed to service the terminated producers book of business following the termination.',
    `approval_date` DATE COMMENT 'Date on which the termination action was formally approved internally, prior to issuance of notice to the producer and regulatory filing.',
    `approved_by_user_code` BIGINT COMMENT 'Internal user or employee ID of the person who approved the termination action, supporting dual-control and SOX audit requirements.',
    `book_of_business_transfer_date` DATE COMMENT 'Date on which the terminated producers book of business was fully transferred to the successor producer or insurer servicing team.',
    `book_of_business_transfer_status` STRING COMMENT 'Status of the transfer of the terminated producers book of business (policies) to another appointed producer or to the insurers direct servicing team.. Valid values are `not_applicable|pending|in_progress|completed|cancelled`',
    `commission_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the pending commission amount (e.g., USD). Supports multi-currency operations for international entities.. Valid values are `^[A-Z]{3}$`',
    `commission_settlement_status` STRING COMMENT 'Status of the final commission settlement process following termination, tracking whether outstanding commissions have been paid, disputed, or written off.. Valid values are `not_applicable|pending|settled|disputed|written_off`',
    `contest_outcome` STRING COMMENT 'Result of the producers formal contest or appeal of the termination decision.. Valid values are `upheld|overturned|settled|withdrawn|pending`',
    `contest_resolution_date` DATE COMMENT 'Date on which a contested termination was resolved, either upholding the termination or reinstating the appointment. Null if not contested or unresolved.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this termination record was first created in the data platform, used for audit trail and data lineage tracking.',
    `e_and_o_coverage_expiry_date` DATE COMMENT 'Date on which the producers Errors and Omissions (E&O) professional liability coverage expires post-termination, relevant for tail coverage obligations.',
    `effective_date` DATE COMMENT 'The date on which the producer appointment or agreement termination becomes legally effective, as agreed or mandated by the applicable state DOI.',
    `initiated_by_party` STRING COMMENT 'Identifies which party initiated the termination: the insurer, the producer, a regulatory authority, or by mutual agreement.. Valid values are `insurer|producer|regulator|mutual`',
    `initiated_by_user_code` BIGINT COMMENT 'Internal user or employee ID of the person who initiated the termination action in the producer management system, for audit trail purposes.',
    `internal_notes` STRING COMMENT 'Confidential internal notes recorded by underwriting or compliance staff regarding the circumstances of the termination, not shared externally.',
    `is_contested` BOOLEAN COMMENT 'Indicates whether the producer has formally contested or appealed the termination, triggering a dispute resolution or regulatory review process.',
    `is_for_cause` BOOLEAN COMMENT 'Indicates whether the termination is for cause (e.g., fraud, misrepresentation, license violation), triggering mandatory state regulatory reporting obligations.',
    `is_regulatory_reportable` BOOLEAN COMMENT 'Indicates whether this termination must be reported to the state Department of Insurance (DOI) or NAIC within the mandated reporting window.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code identifying the insurer entity filing the termination, required for state DOI regulatory submissions.. Valid values are `^[0-9]{5}$`',
    `notice_date` DATE COMMENT 'Date on which formal written notice of termination was issued to the producer, used to calculate required notice periods per state regulation.',
    `notice_period_days` BIGINT COMMENT 'Number of calendar days of advance notice required by state regulation or contract before the termination becomes effective.',
    `number` STRING COMMENT 'Externally visible business identifier for this termination action, used in regulatory filings, correspondence, and bordereaux submissions.. Valid values are `^TERM-[0-9]{4}-[0-9]{6}$`',
    `pending_commission_amount` DECIMAL(18,2) COMMENT 'Total commission amount owed to the producer at the time of termination that remains unpaid, subject to final settlement per the agency agreement terms.',
    `reason_code` STRING COMMENT 'Standardized NAIC or state DOI reason code for the termination, used in regulatory filings and state notification submissions (e.g., NAIC reason codes for appointment terminations).. Valid values are `^[A-Z0-9]{2,10}$`',
    `reason_description` STRING COMMENT 'Free-text narrative explaining the business reason for the termination, supplementing the standardized reason code for internal documentation and audit purposes.',
    `regulatory_report_due_date` DATE COMMENT 'Deadline by which the termination must be reported to the applicable state DOI or NAIC, typically 30 days from the effective date per state statute.',
    `regulatory_report_status` STRING COMMENT 'Current status of the regulatory termination notification filing with the state DOI or NAIC, tracking compliance with mandatory reporting requirements.. Valid values are `not_required|pending|submitted|accepted|rejected`',
    `regulatory_report_submitted_date` DATE COMMENT 'Actual date on which the termination notification was submitted to the state DOI or NAIC, used to confirm timely compliance with reporting obligations.',
    `reinstatement_eligible` BOOLEAN COMMENT 'Indicates whether the terminated producer is eligible for future reinstatement of their appointment, based on the termination reason and regulatory standing.',
    `reinstatement_eligible_date` DATE COMMENT 'Earliest date on which the terminated producer may apply for reinstatement of their appointment, if applicable under state regulation or contract terms.',
    `rescission_date` DATE COMMENT 'Date on which a previously issued termination was rescinded or reversed, restoring the producer appointment. Null if the termination was not rescinded.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this termination record originated (e.g., AgentSync, Vertafore Sircon, Guidewire PolicyCenter).. Valid values are `AGENTSYNC|SIRCON|GUIDEWIRE_PC|DUCK_CREEK|SAPIENS`',
    `source_system_record_code` STRING COMMENT 'Native record identifier from the originating operational system (AgentSync, Vertafore Sircon, etc.) for lineage tracing and reconciliation.',
    `state_notification_required` BOOLEAN COMMENT 'Indicates whether the terminating state requires a formal notification filing with the DOI, distinct from the broader regulatory reportable flag.',
    `termination_status` STRING COMMENT 'Current workflow state of the termination action, tracking progress from initiation through regulatory confirmation or rescission.. Valid values are `pending|submitted|confirmed|rescinded|appealed`',
    `termination_type` STRING COMMENT 'Classifies the nature of the termination. [ENUM-REF-CANDIDATE: voluntary|involuntary|non_renewal|mutual_agreement|regulatory_action|death_disability — promote to reference product]. Valid values are `voluntary|involuntary|non_renewal|mutual_agreement|regulatory_action|death_disability`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this termination record in the data platform, supporting change tracking and audit compliance.',
    CONSTRAINT pk_termination PRIMARY KEY(`termination_id`)
) COMMENT 'Records the termination or non-renewal of a producer appointment or agreement, including termination reason code, for-cause flag, effective date, state notification requirement, and regulatory reporting status.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` (
    `producer_compliance_id` BIGINT COMMENT 'Unique surrogate identifier for the producer compliance onboarding and monitoring case record within the Pc_Insurance producer management system.',
    `compliance_reviewer_producers_producer_id` BIGINT COMMENT 'Identifier of the internal compliance officer or analyst assigned to review and adjudicate this producer compliance case. Links to the employee or user master record.',
    `compliance_owner_producers_producer_id` BIGINT COMMENT 'Reference to the producer (agent or broker) whose compliance case this record tracks. Links to the producer master record in the producer management system.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Compliance cases are state-specific for licensing verification and regulatory action tracking. State DOI compliance monitoring requires state reference. Removes denormalized license_state.',
    `activation_date` DATE COMMENT 'Date on which the producer was formally activated and authorized to bind business on behalf of Pc_Insurance following successful completion of all compliance checks.',
    `aml_training_date` DATE COMMENT 'Date on which the producer completed the most recent AML training course. Used to determine whether re-training is required based on the applicable refresh cycle.',
    `anti_money_laundering_trained` BOOLEAN COMMENT 'Indicates whether the producer has completed mandatory AML training as required by FinCEN and NAIC guidelines. Required for appointment in certain lines of business.',
    `appointed_lob_codes` STRING COMMENT 'Comma-separated list of NAIC line of business codes for which the producer is authorized to sell under this compliance case (e.g., 04=Fire, 05=Allied Lines, 17=CGL).',
    `appointment_eligibility_status` STRING COMMENT 'Overall eligibility determination for producer appointment based on the aggregate outcome of all compliance checks. Drives the final activation decision in the producer management system.. Valid values are `eligible|ineligible|conditional|under_review`',
    `background_check_date` DATE COMMENT 'Date on which the background check was completed and results were received from the screening vendor. Null if the check has not yet been completed.',
    `background_check_reference` STRING COMMENT 'Vendor-assigned reference or order number for the background check transaction. Used to retrieve detailed results from the screening vendor portal.',
    `background_check_status` STRING COMMENT 'Current status of the criminal background check conducted on the producer as part of the onboarding compliance process. Adverse findings require underwriting review.. Valid values are `not_started|in_progress|clear|adverse|pending_review`',
    `background_check_vendor` STRING COMMENT 'Name of the third-party screening vendor that performed the background check (e.g., Sterling, First Advantage). Used for vendor management and audit trail.',
    `case_close_date` DATE COMMENT 'Calendar date on which the compliance case reached final disposition (approved, rejected, or closed). Null if the case is still open.',
    `case_number` STRING COMMENT 'Externally visible, human-readable identifier assigned to this compliance onboarding case. Used in correspondence with the producer and state DOI filings.. Valid values are `^PC-[0-9]{4}-[0-9]{6}$`',
    `case_open_date` DATE COMMENT 'Calendar date on which the compliance case was formally opened and submitted for review. Serves as the start anchor for SLA and regulatory turnaround tracking.',
    `case_status` STRING COMMENT 'Current lifecycle state of the compliance case from initial submission through final disposition. Drives workflow routing in the producer management system.. Valid values are `pending|in_review|approved|rejected|suspended|closed`',
    `case_type` STRING COMMENT 'Categorizes the nature of the compliance case: initial producer appointment, license renewal, reinstatement after lapse, disciplinary review, or periodic audit.. Valid values are `initial_appointment|renewal|reinstatement|disciplinary_review|periodic_audit`',
    `ce_credit_hours_verified` DECIMAL(5,2) COMMENT 'Number of continuing education credit hours confirmed as completed by the producer for the current license period. Compared against state-mandated minimums.',
    `compliance_notes` STRING COMMENT 'Free-text field for compliance officer annotations, escalation notes, or exception documentation related to this producer compliance case. Restricted to authorized compliance staff.',
    `continuing_education_compliant` BOOLEAN COMMENT 'Indicates whether the producer has met all state-mandated continuing education (CE) credit hour requirements for the current license period as verified through NIPR or state DOI.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this compliance case record was first created in the data platform. Used for audit trail and data lineage purposes.',
    `doi_disciplinary_detail` STRING COMMENT 'Summary description of DOI disciplinary orders or regulatory actions against the producer, including state, order type, and effective date. Populated when doi_disciplinary_flag is true.',
    `doi_disciplinary_flag` BOOLEAN COMMENT 'Indicates whether the producer has any active or historical disciplinary orders on record with any state Department of Insurance. True triggers mandatory compliance review.',
    `doi_disciplinary_order_date` DATE COMMENT 'Date of the most recent DOI disciplinary order or regulatory action recorded against the producer. Used to assess recency and severity of compliance risk.',
    `e_o_coverage_verified` BOOLEAN COMMENT 'Indicates whether the producers Errors and Omissions (E&O) professional liability insurance coverage has been verified as active and meeting minimum limits required by Pc_Insurance.',
    `e_o_expiration_date` DATE COMMENT 'Expiration date of the producers E&O professional liability insurance policy. Triggers renewal alert workflow when within 60 days of expiry.',
    `e_o_policy_number` STRING COMMENT 'Policy number of the producers active E&O professional liability insurance policy. Required for appointment and verified during onboarding compliance review.',
    `ineligibility_reason` STRING COMMENT 'Free-text explanation of why the producer was determined ineligible for appointment. Populated when appointment_eligibility_status is ineligible or conditional.',
    `license_expiration_date` DATE COMMENT 'Expiration date of the producer license as recorded in NIPR or the state DOI system. Used to trigger renewal reminders and compliance alerts.',
    `license_verification_date` DATE COMMENT 'Date on which the most recent license verification check was completed against NIPR or state DOI records for this compliance case.',
    `license_verification_status` STRING COMMENT 'Current status of the license verification check performed against NIPR or state DOI records. A verified status is required before producer activation.. Valid values are `not_started|in_progress|verified|failed|expired`',
    `market_conduct_finding_detail` STRING COMMENT 'Narrative description of market conduct examination findings associated with the producer, including the examining state and finding category. Populated when flag is true.',
    `market_conduct_finding_flag` BOOLEAN COMMENT 'Indicates whether the producer has been cited in a state market conduct examination finding. True requires review by the compliance officer before appointment approval.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic compliance review of this producer, based on risk tier, license renewal cycle, or regulatory requirement. Drives automated review scheduling.',
    `nipr_transaction_number` STRING COMMENT 'Transaction identifier returned by NIPR when the appointment or license verification request was submitted. Used to reconcile NIPR responses with internal compliance records.',
    `ofac_match_detail` STRING COMMENT 'Descriptive detail of any OFAC match found during screening, including the matched list name and match score. Populated only when ofac_screening_status is match_found or escalated.',
    `ofac_screening_date` DATE COMMENT 'Date on which the most recent OFAC sanctions screening was performed for this producer. Periodic re-screening is required per AML compliance policy.',
    `ofac_screening_status` STRING COMMENT 'Result of the OFAC (Office of Foreign Assets Control) sanctions screening check. A clear status is required before the producer can be activated and bound to policies.. Valid values are `not_started|clear|match_found|false_positive|escalated`',
    `producer_license_number` STRING COMMENT 'State-issued insurance producer license number being verified as part of this compliance case. Sourced from NIPR or state DOI licensing database.',
    `review_completed_date` DATE COMMENT 'Date on which the assigned compliance reviewer completed their assessment of all checks and rendered an appointment eligibility determination for this case.',
    `state_appointment_filed` BOOLEAN COMMENT 'Indicates whether the formal producer appointment has been filed with the applicable state DOI through NIPR. Required in states that mandate company-filed appointments.',
    `state_appointment_filed_date` DATE COMMENT 'Date on which the producer appointment was filed with the state DOI via NIPR. Populated only when state_appointment_filed is true.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp of the most recent modification to this compliance case record. Supports incremental data pipeline processing and audit trail requirements.',
    CONSTRAINT pk_producer_compliance PRIMARY KEY(`producer_compliance_id`)
) COMMENT 'Compliance and onboarding case for a producer tracking background check, license verification, DOI disciplinary orders, market conduct findings, and OFAC/sanctions screening status through activation.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`producers`.`territory` (
    `territory_id` BIGINT COMMENT 'Unique identifier for the territory data product (auto-inserted during validation).',
    `agency_id` BIGINT COMMENT 'Reference to the agency or brokerage organization associated with this territory assignment.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: Territory assignments reference commission schedules via string code. Adding proper FK enables referential integrity and eliminates need to JOIN on business key.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer (agent or broker) to whom this geographic territory is assigned.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Territories are defined by state boundaries for producer assignment and commission allocation. Territory management and producer performance reporting require state reference.',
    `appointment_date` DATE COMMENT 'Date the producer was formally appointed by Pc_Insurance to write business in this territory, as filed with the state Department of Insurance (DOI).',
    `cat_zone_code` STRING COMMENT 'Designated Catastrophe (CAT) zone code (e.g., hurricane tier, earthquake zone, wildfire risk zone) assigned to this territory for PML and reinsurance purposes.',
    `channel_code` STRING COMMENT 'Distribution channel through which business is written in this territory: independent agent, captive agent, broker, direct, or Managing General Agent (MGA).. Valid values are `independent_agent|captive_agent|broker|direct|mgа`',
    `territory_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying the territory, used in bordereaux, commission statements, and regulatory filings.. Valid values are `^[A-Z0-9]{2,20}$`',
    `conflict_priority` BIGINT COMMENT 'Integer priority rank used to resolve overlapping territory assignments for the same geography and LOB. Lower value indicates higher precedence.',
    `county_fips_code` STRING COMMENT 'Five-digit Federal Information Processing Standards (FIPS) county code scoping the territory to a specific county within the state.. Valid values are `^[0-9]{5}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this territory assignment record was first created in the system, used for audit trail and data lineage in the Databricks Silver Layer.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code applicable to monetary limits (e.g., max_tiv, premium targets) for this territory. Typically USD for domestic P&C.. Valid values are `^[A-Z]{3}$`',
    `division_code` STRING COMMENT 'Internal division code (e.g., personal lines, commercial lines, specialty) used for production roll-up and P&L reporting in Oracle Financials GL.. Valid values are `^[A-Z0-9]{1,10}$`',
    `effective_date` DATE COMMENT 'Date on which the territory assignment becomes binding and the producer is authorized to solicit and bind business within the defined geographic scope.',
    `expiration_date` DATE COMMENT 'Date on which the territory assignment ends. Null indicates an open-ended assignment with no scheduled termination.',
    `geographic_scope` STRING COMMENT 'Granularity level of the geographic boundary definition: statewide, county, ZIP-code range, Metropolitan Statistical Area (MSA), or custom polygon.. Valid values are `statewide|county|zip_range|msa|custom`',
    `is_cat_exposed` BOOLEAN COMMENT 'Flags whether the territory falls within a designated Catastrophe (CAT) zone (e.g., hurricane, earthquake, wildfire), triggering underwriting restrictions.',
    `is_exclusive` BOOLEAN COMMENT 'Indicates whether the producer holds exclusive rights to solicit and bind business within this territory, preventing appointment of competing producers.',
    `iso_territory_code` STRING COMMENT 'Insurance Services Office (ISO) / Verisk territory code used for rate filings, loss cost multipliers, and actuarial territory relativities.. Valid values are `^[A-Z0-9]{1,10}$`',
    `lob_code` STRING COMMENT 'NAIC or internal Line of Business (LOB) code scoping the territory to specific insurance products (e.g., HO, AUTO, CGL, WC, BOP). [ENUM-REF-CANDIDATE: promote to reference product]',
    `lob_description` STRING COMMENT 'Human-readable description of the Line of Business (LOB) scope for this territory (e.g., Personal Auto, Commercial General Liability).',
    `market_segment` STRING COMMENT 'Broad market segment classification for the territory: personal lines, commercial lines, specialty, or excess and surplus (E&S) lines.. Valid values are `personal|commercial|specialty|excess_surplus`',
    `max_tiv` DECIMAL(18,2) COMMENT 'Maximum aggregate Total Insured Value (TIV) the producer is authorized to bind within this territory, enforcing capacity and concentration limits.',
    `msa_code` STRING COMMENT 'US Census Bureau Metropolitan Statistical Area (MSA) code when the territory is scoped to an MSA rather than individual counties or ZIP codes.. Valid values are `^[0-9]{5}$`',
    `naic_territory_code` STRING COMMENT 'National Association of Insurance Commissioners (NAIC) territory code used in statutory reporting and state rate filings.. Valid values are `^[0-9]{1,6}$`',
    `territory_name` STRING COMMENT 'Human-readable name of the territory (e.g., Northeast Commercial, Gulf Coast Personal Lines) used in producer portals and management reports.',
    `new_business_allowed` BOOLEAN COMMENT 'Indicates whether the producer is permitted to write New Business (NB) in this territory. May be restricted during CAT moratoriums or UW suspensions.',
    `notes` STRING COMMENT 'Free-text field for underwriting or territory management notes, such as special conditions, moratorium details, or conflict resolution decisions.',
    `rating_territory_code` STRING COMMENT 'Internal rating territory code used by the policy rating engine (Guidewire PolicyCenter / Duck Creek Rating) to apply territory-specific rate factors.. Valid values are `^[A-Z0-9]{1,10}$`',
    `region_code` STRING COMMENT 'Internal regional grouping code (e.g., NE, SE, MW, SW, W) used for production roll-up reporting and regional management oversight.. Valid values are `^[A-Z0-9]{1,10}$`',
    `renewal_allowed` BOOLEAN COMMENT 'Indicates whether policy renewals (REN) are permitted within this territory. May differ from new business authority during non-renewal orders.',
    `source_system_code` STRING COMMENT 'Identifies the operational system of record from which this territory record originated (e.g., AgentSync, Vertafore Sircon, Guidewire PolicyCenter).. Valid values are `agentsync|sircon|guidewire|duck_creek|sapiens|manual`',
    `source_system_record_code` STRING COMMENT 'Native primary key or record identifier from the originating source system, enabling traceability and reconciliation back to AgentSync, Sircon, or PolicyCenter.',
    `termination_date` DATE COMMENT 'Date the territory assignment was formally terminated. Null if the assignment is still active or has not yet been terminated.',
    `termination_reason` STRING COMMENT 'Reason code for the termination of the territory assignment, required for state DOI termination filings and producer management audit trails.. Valid values are `voluntary|non_renewal|performance|regulatory|merger_acquisition|other`',
    `territory_status` STRING COMMENT 'Current lifecycle state of the territory assignment. Controls whether the producer may bind new business within the defined geographic scope.. Valid values are `active|inactive|pending|suspended|expired`',
    `territory_type` STRING COMMENT 'Classification of the territory assignment indicating exclusivity and access rights granted to the producer. Drives conflict resolution and appointment rules.. Valid values are `exclusive|non_exclusive|preferred|restricted|open`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this territory assignment record, supporting change tracking and incremental load processing in the Silver Layer.',
    `uw_restriction_code` STRING COMMENT 'Current underwriting (UW) restriction level applied to this territory. Drives policy binding authority and referral requirements in PolicyCenter.. Valid values are `none|moratorium|restricted|suspended|referral_required`',
    `written_premium_target` DECIMAL(18,2) COMMENT 'Annual Written Premium (WP) production target assigned to the producer for this territory, used in performance tracking and commission tier calculations.',
    `zip_code_end` STRING COMMENT 'Ending ZIP code of the contiguous ZIP-code range defining the geographic boundary of this territory assignment.. Valid values are `^[0-9]{5}$`',
    `zip_code_start` STRING COMMENT 'Starting ZIP code of the contiguous ZIP-code range defining the geographic boundary of this territory assignment.. Valid values are `^[0-9]{5}$`',
    CONSTRAINT pk_territory PRIMARY KEY(`territory_id`)
) COMMENT 'Geographic territory assigned to a producer or agency by state, county, and ZIP-code range with LOB scope. Supports territory management, conflict resolution, and production roll-up.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` (
    `authority_territory_id` BIGINT COMMENT 'Unique surrogate identifier for this binding authority territory record',
    `binding_authority_id` BIGINT COMMENT 'Foreign key linking to the binding authority record granted to the producer or MGA',
    `state_id` BIGINT COMMENT 'Foreign key linking to the state or territory where this binding authority is operative',
    `aggregate_limit_per_state` DECIMAL(18,2) COMMENT 'Maximum total gross written premium or total insured value the producer may bind annually within this state',
    `compliance_status` STRING COMMENT 'Current regulatory compliance status of the binding authority within this state jurisdiction',
    `effective_date` DATE COMMENT 'Date on which the binding authority becomes operative in this specific state jurisdiction',
    `expiration_date` DATE COMMENT 'Date on which the binding authority ceases to be valid in this specific state jurisdiction',
    `max_policy_limit_per_state` DECIMAL(18,2) COMMENT 'State-specific ceiling on the total insured value or per-occurrence policy limit the producer may bind',
    `premium_tax_rate_override` DECIMAL(5,4) COMMENT 'State-specific premium tax rate override applicable to policies bound under this authority in this state',
    `state_approval_date` DATE COMMENT 'Date on which the state Department of Insurance approved this binding authority for operation in the state',
    `state_filing_reference` STRING COMMENT 'Regulatory filing reference number or approval code issued by the state DOI for this binding authority',
    `surplus_lines_eligible` BOOLEAN COMMENT 'Indicates whether this binding authority permits surplus lines placements within this specific state',
    CONSTRAINT pk_authority_territory PRIMARY KEY(`authority_territory_id`)
) COMMENT 'Represents the delegated binding authority granted to a producer within a specific state jurisdiction. Captures state-specific limits, effective dates, and regulatory compliance requirements for each producer-state combination..';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ADD CONSTRAINT `fk_producers_producers_producer_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ADD CONSTRAINT `fk_producers_producers_producer_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ADD CONSTRAINT `fk_producers_producer_license_eno_policy_id` FOREIGN KEY (`eno_policy_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`eno_policy`(`eno_policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ADD CONSTRAINT `fk_producers_producer_license_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ADD CONSTRAINT `fk_producers_appointment_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ADD CONSTRAINT `fk_producers_appointment_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ADD CONSTRAINT `fk_producers_appointment_eno_policy_id` FOREIGN KEY (`eno_policy_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`eno_policy`(`eno_policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ADD CONSTRAINT `fk_producers_appointment_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ADD CONSTRAINT `fk_producers_agency_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ADD CONSTRAINT `fk_producers_agency_parent_agency_id` FOREIGN KEY (`parent_agency_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ADD CONSTRAINT `fk_producers_agency_producer_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ADD CONSTRAINT `fk_producers_agency_producer_agency_producers_producer_id` FOREIGN KEY (`agency_producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ADD CONSTRAINT `fk_producers_agency_producer_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ADD CONSTRAINT `fk_producers_agency_producer_eno_policy_id` FOREIGN KEY (`eno_policy_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`eno_policy`(`eno_policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ADD CONSTRAINT `fk_producers_agency_producer_parent_producer_producers_producer_id` FOREIGN KEY (`parent_producer_producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ADD CONSTRAINT `fk_producers_eno_policy_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ADD CONSTRAINT `fk_producers_commission_schedule_superseded_by_commission_schedule_id` FOREIGN KEY (`superseded_by_commission_schedule_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_commission_statement_id` FOREIGN KEY (`commission_statement_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`commission_statement`(`commission_statement_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_original_transaction_id` FOREIGN KEY (`original_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`commission_transaction`(`commission_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_producer_agreement_id` FOREIGN KEY (`producer_agreement_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producer_agreement`(`producer_agreement_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ADD CONSTRAINT `fk_producers_contingent_bonus_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ADD CONSTRAINT `fk_producers_contingent_bonus_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ADD CONSTRAINT `fk_producers_producer_agreement_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ADD CONSTRAINT `fk_producers_producer_agreement_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ADD CONSTRAINT `fk_producers_producer_agreement_prior_agreement_producer_agreement_id` FOREIGN KEY (`prior_agreement_producer_agreement_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producer_agreement`(`producer_agreement_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ADD CONSTRAINT `fk_producers_producer_agreement_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ADD CONSTRAINT `fk_producers_binding_authority_producer_agreement_id` FOREIGN KEY (`producer_agreement_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producer_agreement`(`producer_agreement_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ADD CONSTRAINT `fk_producers_binding_authority_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ADD CONSTRAINT `fk_producers_onboarding_case_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ADD CONSTRAINT `fk_producers_onboarding_case_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ADD CONSTRAINT `fk_producers_termination_appointment_id` FOREIGN KEY (`appointment_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`appointment`(`appointment_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ADD CONSTRAINT `fk_producers_termination_producer_agreement_id` FOREIGN KEY (`producer_agreement_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producer_agreement`(`producer_agreement_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ADD CONSTRAINT `fk_producers_termination_termination_producers_producer_id` FOREIGN KEY (`termination_producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ADD CONSTRAINT `fk_producers_termination_termination_successor_producer_producers_producer_id` FOREIGN KEY (`termination_successor_producer_producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ADD CONSTRAINT `fk_producers_producer_compliance_compliance_reviewer_producers_producer_id` FOREIGN KEY (`compliance_reviewer_producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ADD CONSTRAINT `fk_producers_producer_compliance_compliance_owner_producers_producer_id` FOREIGN KEY (`compliance_owner_producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ADD CONSTRAINT `fk_producers_territory_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ADD CONSTRAINT `fk_producers_territory_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ADD CONSTRAINT `fk_producers_territory_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` ADD CONSTRAINT `fk_producers_authority_territory_binding_authority_id` FOREIGN KEY (`binding_authority_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`binding_authority`(`binding_authority_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_v499`.`producers` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_v499`.`producers` SET TAGS ('dbx_domain' = 'producers');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for producers_producer');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `aml_certification_date` SET TAGS ('dbx_business_glossary_term' = 'Anti-Money Laundering (AML) Certification Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `anti_money_laundering_certified` SET TAGS ('dbx_business_glossary_term' = 'Anti-Money Laundering (AML) Certified Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `appointment_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `appointment_status` SET TAGS ('dbx_business_glossary_term' = 'Producer Appointment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `appointment_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|terminated|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `appointment_termination_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Termination Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `background_check_date` SET TAGS ('dbx_business_glossary_term' = 'Background Check Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `background_check_status` SET TAGS ('dbx_business_glossary_term' = 'Background Check Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `background_check_status` SET TAGS ('dbx_value_regex' = 'passed|failed|pending|waived|expired');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `binding_authority_granted` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Granted Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Limit (USD)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_address_city` SET TAGS ('dbx_business_glossary_term' = 'Producer Business City');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_address_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_address_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Producer Business Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_address_state` SET TAGS ('dbx_business_glossary_term' = 'Producer Business State');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_address_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_address_state` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_address_state` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_address_zip` SET TAGS ('dbx_business_glossary_term' = 'Producer Business ZIP Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_address_zip` SET TAGS ('dbx_value_regex' = '^[0-9]{5}(-[0-9]{4})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_address_zip` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_address_zip` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_email` SET TAGS ('dbx_business_glossary_term' = 'Producer Business Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_phone` SET TAGS ('dbx_business_glossary_term' = 'Producer Business Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9]{10,15}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `business_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Eligible Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `continuing_education_compliant` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Compliant Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `continuing_education_compliant` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `continuing_education_compliant` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `dba_name` SET TAGS ('dbx_business_glossary_term' = 'Doing Business As (DBA) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `dba_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `e_and_o_carrier` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Carrier Name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `e_and_o_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `e_and_o_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Coverage Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `e_and_o_limit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `e_and_o_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `e_and_o_policy_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `entity_type` SET TAGS ('dbx_business_glossary_term' = 'Producer Entity Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `entity_type` SET TAGS ('dbx_value_regex' = 'individual|agency|broker|managing_general_agent|surplus_lines_broker');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `fein` SET TAGS ('dbx_business_glossary_term' = 'Federal Employer Identification Number (FEIN)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `fein` SET TAGS ('dbx_value_regex' = '^[0-9]{2}-[0-9]{7}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `fein` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `fein` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Producer Legal Name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `legal_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `legal_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `license_class` SET TAGS ('dbx_business_glossary_term' = 'License Class');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `license_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'License Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `license_number` SET TAGS ('dbx_business_glossary_term' = 'State Insurance License Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `license_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `lines_of_authority` SET TAGS ('dbx_business_glossary_term' = 'Lines of Authority (LOA)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `managing_general_agent_code` SET TAGS ('dbx_business_glossary_term' = 'Managing General Agent (MGA) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `managing_general_agent_code` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `managing_general_agent_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `npn` SET TAGS ('dbx_business_glossary_term' = 'National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `npn` SET TAGS ('dbx_value_regex' = '^[0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `npn` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `onboarding_date` SET TAGS ('dbx_business_glossary_term' = 'Producer Onboarding Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `preferred_lob` SET TAGS ('dbx_business_glossary_term' = 'Preferred Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `producer_code` SET TAGS ('dbx_business_glossary_term' = 'Producer Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `producer_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `producer_type` SET TAGS ('dbx_business_glossary_term' = 'Producer Distribution Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `producer_type` SET TAGS ('dbx_value_regex' = 'captive|independent|direct|wholesale|retail');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `ssn_last4` SET TAGS ('dbx_business_glossary_term' = 'Social Security Number (SSN) Last Four Digits');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `ssn_last4` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `ssn_last4` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `ssn_last4` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `surplus_lines_licensed` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Licensed Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Appointment Termination Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'voluntary|for_cause|non_renewal|license_lapse|regulatory_action');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `uw_authority_level` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Authority Level');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ALTER COLUMN `uw_authority_level` SET TAGS ('dbx_value_regex' = 'none|limited|standard|enhanced|full');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `producer_license_id` SET TAGS ('dbx_business_glossary_term' = 'Producer License ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `eno_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Eno Policy Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `appointment_date` SET TAGS ('dbx_business_glossary_term' = 'Carrier Appointment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `appointment_required` SET TAGS ('dbx_business_glossary_term' = 'Appointment Required Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `appointment_status` SET TAGS ('dbx_business_glossary_term' = 'Carrier Appointment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `appointment_status` SET TAGS ('dbx_value_regex' = 'appointed|not_appointed|terminated|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `appointment_termination_date` SET TAGS ('dbx_business_glossary_term' = 'Carrier Appointment Termination Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `background_check_date` SET TAGS ('dbx_business_glossary_term' = 'Background Check Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `background_check_status` SET TAGS ('dbx_business_glossary_term' = 'Background Check Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `background_check_status` SET TAGS ('dbx_value_regex' = 'passed|failed|pending|waived|not_required');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `ce_compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Compliance Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `ce_compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|exempt|pending_review');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `ce_credits_completed` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Credits Completed');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `ce_credits_required` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Credits Required');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `ce_due_date` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `continuing_education_required` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Required Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `continuing_education_required` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `continuing_education_required` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `doi_last_verified_date` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Last Verified Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `doi_verification_status` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Verification Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `doi_verification_status` SET TAGS ('dbx_value_regex' = 'verified|unverified|discrepancy|pending_verification');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'License Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'License Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `inactivation_date` SET TAGS ('dbx_business_glossary_term' = 'License Inactivation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'License Issue Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `license_number` SET TAGS ('dbx_business_glossary_term' = 'State Insurance License Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `license_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `license_status` SET TAGS ('dbx_business_glossary_term' = 'License Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `license_status` SET TAGS ('dbx_value_regex' = 'active|expired|suspended|revoked|cancelled|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `license_type` SET TAGS ('dbx_business_glossary_term' = 'License Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `license_type` SET TAGS ('dbx_value_regex' = 'individual|business_entity|surplus_lines|adjuster|public_adjuster|managing_general_agent');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `line_of_authority` SET TAGS ('dbx_business_glossary_term' = 'Line of Authority (LOA)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `lob_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `naic_producer_code` SET TAGS ('dbx_business_glossary_term' = 'NAIC Producer Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `naic_producer_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `naic_producer_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'License Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `npn` SET TAGS ('dbx_business_glossary_term' = 'National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `npn` SET TAGS ('dbx_value_regex' = '^[0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `npn` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `regulatory_action_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Action Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `regulatory_action_description` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Action Description');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `regulatory_action_indicator` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Action Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `renewal_date` SET TAGS ('dbx_business_glossary_term' = 'License Renewal Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `resident_nonresident_indicator` SET TAGS ('dbx_business_glossary_term' = 'Resident / Non-Resident License Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `resident_nonresident_indicator` SET TAGS ('dbx_value_regex' = 'resident|nonresident');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `source_system_license_code` SET TAGS ('dbx_business_glossary_term' = 'Source System License Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `surplus_lines_eligible` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Eligible Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `surplus_lines_license_number` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines License Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `surplus_lines_license_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `surplus_lines_license_number` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `surplus_lines_license_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'License or Appointment Termination Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'voluntary|non_renewal|regulatory_action|carrier_initiated|deceased|other');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `appointment_id` SET TAGS ('dbx_business_glossary_term' = 'Appointment ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `eno_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Eno Policy Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `org_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Entity ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `appointed_by_user` SET TAGS ('dbx_business_glossary_term' = 'Appointed By User');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `appointment_status` SET TAGS ('dbx_business_glossary_term' = 'Appointment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `appointment_status` SET TAGS ('dbx_value_regex' = 'active|pending|terminated|suspended|not_renewed');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `appointment_type` SET TAGS ('dbx_business_glossary_term' = 'Appointment Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `appointment_type` SET TAGS ('dbx_value_regex' = 'agent|broker|managing_general_agent|surplus_lines_broker|reinsurance_intermediary');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `background_check_date` SET TAGS ('dbx_business_glossary_term' = 'Background Check Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `background_check_status` SET TAGS ('dbx_business_glossary_term' = 'Background Check Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `background_check_status` SET TAGS ('dbx_value_regex' = 'passed|failed|pending|waived');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `base_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Base Commission Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `base_commission_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `channel_type` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `channel_type` SET TAGS ('dbx_value_regex' = 'independent_agent|captive_agent|broker|direct|managing_general_agent|surplus_lines');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Eligible Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `doi_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `doi_filing_date` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Filing Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `doi_filing_reference` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Filing Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `is_binding_authority` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `is_surplus_lines` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'NAIC Company Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Appointment Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Appointment Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{4,30}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `producer_license_class` SET TAGS ('dbx_business_glossary_term' = 'Producer License Class');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `producer_license_class` SET TAGS ('dbx_value_regex' = 'property|casualty|life|health|surplus_lines|variable');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `producer_license_number` SET TAGS ('dbx_business_glossary_term' = 'Producer License Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `producer_license_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `producer_license_number` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `producer_license_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `source` SET TAGS ('dbx_business_glossary_term' = 'Appointment Source');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `source` SET TAGS ('dbx_value_regex' = 'new_business|renewal|transfer|reinstatement');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `source_system_appointment_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Appointment ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'agentsync|sircon|guidewire|duck_creek|sapiens|manual');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Termination Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Appointment Termination Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'voluntary|non_renewal|regulatory_action|performance|fraud|other');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `training_completed` SET TAGS ('dbx_business_glossary_term' = 'Carrier Training Completed Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `training_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Training Completion Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `parent_agency_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Agency ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `parent_agency_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `parent_agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `agency_status` SET TAGS ('dbx_business_glossary_term' = 'Agency Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `agency_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|terminated|pending_appointment');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `agency_status` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `agency_status` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `agency_type` SET TAGS ('dbx_business_glossary_term' = 'Agency Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `agency_type` SET TAGS ('dbx_value_regex' = 'independent_agent|captive_agent|broker|managing_general_agent|surplus_lines_broker|wholesale_broker');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `agency_type` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `agency_type` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `annual_premium_volume` SET TAGS ('dbx_business_glossary_term' = 'Annual Premium Volume (WP)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `annual_premium_volume` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `appointment_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `appointment_termination_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Termination Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `background_check_date` SET TAGS ('dbx_business_glossary_term' = 'Background Check Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `background_check_status` SET TAGS ('dbx_business_glossary_term' = 'Background Check Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `background_check_status` SET TAGS ('dbx_value_regex' = 'passed|failed|pending|waived');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `binding_authority_flag` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `agency_code` SET TAGS ('dbx_business_glossary_term' = 'Agency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `agency_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `agency_code` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `agency_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Eligible Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `dba_name` SET TAGS ('dbx_business_glossary_term' = 'Doing Business As (DBA) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `dba_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'Agency Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `email_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `eo_carrier_name` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Carrier Name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `eo_carrier_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `eo_carrier_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `eo_coverage_amount` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Coverage Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `eo_coverage_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `eo_coverage_amount` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `eo_coverage_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `eo_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `eo_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `eo_policy_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `fax_number` SET TAGS ('dbx_business_glossary_term' = 'Agency Fax Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `fax_number` SET TAGS ('dbx_value_regex' = '^+?[0-9-() ]{7,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `fax_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `fax_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `fein` SET TAGS ('dbx_business_glossary_term' = 'Federal Employer Identification Number (FEIN)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `fein` SET TAGS ('dbx_value_regex' = '^[0-9]{2}-[0-9]{7}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `fein` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `fein` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Agency Legal Name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `legal_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `legal_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `legal_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `loss_ratio` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `managing_ga_flag` SET TAGS ('dbx_business_glossary_term' = 'Managing General Agent (MGA) Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `naic_producer_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Producer Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `naic_producer_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `network_code` SET TAGS ('dbx_business_glossary_term' = 'Agency Network Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `onboarding_completed_date` SET TAGS ('dbx_business_glossary_term' = 'Onboarding Completed Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `pc_insurance_gwp` SET TAGS ('dbx_business_glossary_term' = 'Pc_Insurance Gross Written Premium (GWP)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `pc_insurance_gwp` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `phone_number` SET TAGS ('dbx_business_glossary_term' = 'Agency Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `phone_number` SET TAGS ('dbx_value_regex' = '^+?[0-9-() ]{7,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `phone_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `preferred_lob_codes` SET TAGS ('dbx_business_glossary_term' = 'Preferred Lines of Business (LOB) Codes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `principal_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Principal Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `principal_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `principal_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `principal_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Principal Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `principal_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `principal_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `principal_city` SET TAGS ('dbx_business_glossary_term' = 'Principal City');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `principal_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `principal_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `principal_country_code` SET TAGS ('dbx_business_glossary_term' = 'Principal Country Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `principal_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `principal_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Principal Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `principal_postal_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}(-[0-9]{4})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `principal_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `principal_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `surplus_lines_licensed` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Licensed Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Appointment Termination Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'voluntary|non_renewal|cause|regulatory_action|merger_acquisition');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `website_url` SET TAGS ('dbx_business_glossary_term' = 'Agency Website URL');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `website_url` SET TAGS ('dbx_value_regex' = '^https?://[^s]{3,255}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ALTER COLUMN `years_in_business` SET TAGS ('dbx_business_glossary_term' = 'Years in Business');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `agency_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `agency_producer_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `agency_producer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `agency_producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `agency_producers_producer_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `agency_producers_producer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Plan ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `eno_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Eno Policy Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `parent_producer_producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `appointment_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `appointment_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `appointment_number` SET TAGS ('dbx_business_glossary_term' = 'Appointment Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `appointment_state` SET TAGS ('dbx_business_glossary_term' = 'Appointment State');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `appointment_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `association_role` SET TAGS ('dbx_business_glossary_term' = 'Association Role');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `association_role` SET TAGS ('dbx_value_regex' = 'principal_agent|sub_agent|broker|managing_agent|surplus_lines_agent|appointed_agent');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `association_source` SET TAGS ('dbx_business_glossary_term' = 'Association Source System');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `association_source` SET TAGS ('dbx_value_regex' = 'agentsync|vertafore_sircon|manual|api_feed|legacy_migration');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `association_status` SET TAGS ('dbx_business_glossary_term' = 'Association Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `association_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|terminated|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `background_check_date` SET TAGS ('dbx_business_glossary_term' = 'Background Check Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `background_check_status` SET TAGS ('dbx_business_glossary_term' = 'Background Check Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `background_check_status` SET TAGS ('dbx_value_regex' = 'passed|failed|pending|waived');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `binding_authority_flag` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `ce_credits_completed` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Credits Completed');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `ce_credits_required` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Credits Required');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `channel_type` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `channel_type` SET TAGS ('dbx_value_regex' = 'independent_agent|captive_agent|broker|managing_general_agent|surplus_lines_broker');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `commission_split_pct` SET TAGS ('dbx_business_glossary_term' = 'Commission Split Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `commission_split_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Eligible Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `external_association_ref` SET TAGS ('dbx_business_glossary_term' = 'External Association Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `hierarchy_level` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Level');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `is_primary_agency` SET TAGS ('dbx_business_glossary_term' = 'Is Primary Agency Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `is_primary_agency` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `is_primary_agency` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `is_principal` SET TAGS ('dbx_business_glossary_term' = 'Is Principal Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `lob_authorizations` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Authorizations');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `mga_flag` SET TAGS ('dbx_business_glossary_term' = 'Managing General Agent (MGA) Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `naic_pdb_status` SET TAGS ('dbx_business_glossary_term' = 'NAIC Producer Database (PDB) Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `naic_pdb_status` SET TAGS ('dbx_value_regex' = 'clear|flagged|under_review|restricted');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `override_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Override Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `override_commission_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `record_version` SET TAGS ('dbx_business_glossary_term' = 'Record Version');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `regulatory_action_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Action Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `surplus_lines_licensed` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Licensed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `termination_notes` SET TAGS ('dbx_business_glossary_term' = 'Termination Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `training_compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Training Compliance Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `training_compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|pending|exempt');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency_producer` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `eno_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for eno_policy');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `additional_insured_indicator` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Additional Insured Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `aggregate_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Annual Aggregate Coverage Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `aggregate_limit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `annual_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Annual Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `annual_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `auto_renewal_indicator` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Auto-Renewal Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Cancellation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Cancellation Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_value_regex' = 'non_payment|underwriting|voluntary|regulatory|other');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `certificate_received_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Certificate of Insurance Received Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Compliance Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|under_review|waived');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `compliance_verified_by` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Compliance Verified By');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `compliance_verified_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Compliance Verification Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `coverage_form_type` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Coverage Form Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `coverage_form_type` SET TAGS ('dbx_value_regex' = 'claims_made|occurrence');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `coverage_form_type` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `coverage_form_type` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Extended Reporting Period (ERP) Days');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `insurer_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Insurer National Association of Insurance Commissioners (NAIC) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `insurer_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `insurer_name` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Insurer Name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `insurer_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `insurer_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `lob_covered` SET TAGS ('dbx_business_glossary_term' = 'Lines of Business (LOB) Covered by Errors and Omissions (E&O) Policy');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `minimum_required_limit_met` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Minimum Required Limit Met Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `multi_state_indicator` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Multi-State Coverage Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `named_insured` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Named Insured');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `named_insured` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `occurrence_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Per-Occurrence Coverage Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `occurrence_limit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `policy_number` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `policy_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `policy_status` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `policy_status` SET TAGS ('dbx_value_regex' = 'active|expired|cancelled|pending|lapsed');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `policy_type` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `policy_type` SET TAGS ('dbx_value_regex' = 'individual|agency|group|excess');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `prior_acts_coverage_indicator` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Prior Acts Coverage Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `prior_acts_coverage_indicator` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `prior_acts_coverage_indicator` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `renewal_reminder_days` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Renewal Reminder Lead Days');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `retroactive_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Retroactive Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Record Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'agentsync|sircon|guidewire|duck_creek|manual');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Source System Record ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `waiver_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Compliance Waiver Approved By');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `waiver_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Compliance Waiver Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Compliance Waiver Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` SET TAGS ('dbx_subdomain' = 'compensation_processing');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `superseded_by_commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Commission Schedule ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Schedule Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Schedule Approval Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|withdrawn');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `base_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Base Commission Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `base_commission_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `cancellation_chargeback_rate` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Chargeback Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `cancellation_chargeback_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `channel` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `channel` SET TAGS ('dbx_value_regex' = 'independent_agent|captive_agent|direct|broker|digital');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `combined_ratio_threshold` SET TAGS ('dbx_business_glossary_term' = 'Combined Ratio (CR) Threshold');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `contingent_bonus_rate` SET TAGS ('dbx_business_glossary_term' = 'Contingent Bonus Commission Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `contingent_bonus_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `contingent_bonus_rate` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `contingent_bonus_rate` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `dac_eligible` SET TAGS ('dbx_business_glossary_term' = 'Deferred Acquisition Cost (DAC) Eligible Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `commission_schedule_description` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Description');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Schedule Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `endorsement_rate` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Commission Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `endorsement_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Schedule Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `filing_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{4,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `loss_ratio_threshold` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR) Threshold');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `max_volume_premium` SET TAGS ('dbx_business_glossary_term' = 'Maximum Volume Premium Cap');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `measurement_period` SET TAGS ('dbx_business_glossary_term' = 'Commission Measurement Period');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `measurement_period` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `min_policy_count` SET TAGS ('dbx_business_glossary_term' = 'Minimum Policy Count Threshold');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `min_volume_premium` SET TAGS ('dbx_business_glossary_term' = 'Minimum Volume Premium Threshold');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `new_business_rate` SET TAGS ('dbx_business_glossary_term' = 'New Business (NB) Commission Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `new_business_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `override_rate` SET TAGS ('dbx_business_glossary_term' = 'Override Commission Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `override_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Commission Payment Frequency');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `producer_tier` SET TAGS ('dbx_business_glossary_term' = 'Producer Tier');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `producer_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|provisional|elite');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `producer_type` SET TAGS ('dbx_business_glossary_term' = 'Producer Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `producer_type` SET TAGS ('dbx_value_regex' = 'agent|broker|mga|mga_e|surplus_lines');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `profit_sharing_rate` SET TAGS ('dbx_business_glossary_term' = 'Profit Sharing Commission Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `profit_sharing_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `regulatory_filing_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `renewal_rate` SET TAGS ('dbx_business_glossary_term' = 'Renewal (REN) Commission Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `renewal_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `schedule_code` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `schedule_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,30}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `schedule_name` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `schedule_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `schedule_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_value_regex' = 'draft|active|suspended|expired|superseded');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `schedule_type` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `schedule_type` SET TAGS ('dbx_value_regex' = 'base|contingent|override|profit_sharing|bonus');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `stat_expense_code` SET TAGS ('dbx_business_glossary_term' = 'Statutory Expense Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `stat_expense_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'NB|REN|ENDT|CANC|REINSTATE');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Schedule Version Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` SET TAGS ('dbx_subdomain' = 'compensation_processing');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `commission_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `commission_statement_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Statement ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `endorsement_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Endorsement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `original_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Original Commission Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `accounting_date` SET TAGS ('dbx_business_glossary_term' = 'Accounting Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `accounting_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `accounting_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Adjustment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Commission Approval Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'PENDING|APPROVED|REJECTED|ESCALATED');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Commission Approval Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `chargeback_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Chargeback Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `chargeback_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `chargeback_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `commission_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `commission_type` SET TAGS ('dbx_business_glossary_term' = 'Commission Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `commission_type` SET TAGS ('dbx_value_regex' = 'STANDARD|CONTINGENT|OVERRIDE|BONUS|CHARGEBACK|SUPPLEMENTAL');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `contingent_commission_flag` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `contingent_commission_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `contingent_commission_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `dac_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Deferred Acquisition Cost (DAC) Eligible Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `earned_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `earned_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `earned_commission_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `gross_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `gross_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `gross_commission_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `gwp_basis_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP) Basis Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `gwp_basis_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `gwp_basis_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `net_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `net_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `net_commission_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `override_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Override Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `override_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `override_commission_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Commission Payment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Commission Payment Method');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'ACH|CHECK|WIRE|OFFSET|CREDIT_MEMO');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Commission Payment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'UNPAID|PAID|PARTIALLY_PAID|WITHHELD');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `policy_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `policy_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `pro_rata_factor` SET TAGS ('dbx_business_glossary_term' = 'Pro-Rata Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Commission Reversal Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'GUIDEWIRE|DUCK_CREEK|SAPIENS|ORACLE|SAP');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `source_transaction_reference` SET TAGS ('dbx_business_glossary_term' = 'Source Transaction Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `tax_withholding_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Withholding Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `tax_withholding_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `tax_withholding_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Commission Transaction Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `transaction_number` SET TAGS ('dbx_business_glossary_term' = 'Commission Transaction Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `transaction_number` SET TAGS ('dbx_value_regex' = '^CT-[0-9]{10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_business_glossary_term' = 'Commission Transaction Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_value_regex' = 'PENDING|APPROVED|PAID|REVERSED|VOIDED|ON_HOLD');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Commission Transaction Type (NB/REN/ENDT/CANC)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'NB|REN|ENDT|CANC|REINSTATEMENT|ADJUSTMENT');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `unearned_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Unearned Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `unearned_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `unearned_commission_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `withholding_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Withholding Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `withholding_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ALTER COLUMN `withholding_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` SET TAGS ('dbx_subdomain' = 'compensation_processing');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `commission_statement_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Statement ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `producer_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Agreement ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `adjustment_amt` SET TAGS ('dbx_business_glossary_term' = 'Commission Adjustment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `adjustment_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `bonus_commission_amt` SET TAGS ('dbx_business_glossary_term' = 'Bonus Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `bonus_commission_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `cancellation_count` SET TAGS ('dbx_business_glossary_term' = 'Cancellation (CANC) Count');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `chargeback_amt` SET TAGS ('dbx_business_glossary_term' = 'Commission Chargeback Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `chargeback_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `contingent_commission_amt` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `contingent_commission_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `contingent_commission_amt` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `contingent_commission_amt` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `dac_eligible_amt` SET TAGS ('dbx_business_glossary_term' = 'Deferred Acquisition Cost (DAC) Eligible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `dac_eligible_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Commission Dispute Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `dispute_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Commission Dispute Resolution Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `earned_commission_amt` SET TAGS ('dbx_business_glossary_term' = 'Earned Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `earned_commission_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `gross_written_premium_amt` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `gross_written_premium_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `is_disputed` SET TAGS ('dbx_business_glossary_term' = 'Is Disputed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `net_payable_amt` SET TAGS ('dbx_business_glossary_term' = 'Net Commission Payable Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `net_payable_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `new_business_policy_count` SET TAGS ('dbx_business_glossary_term' = 'New Business (NB) Policy Count');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Commission Statement Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Commission Payment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Commission Payment Method');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'ACH|check|wire|offset');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `payment_reference` SET TAGS ('dbx_business_glossary_term' = 'Commission Payment Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `policy_count` SET TAGS ('dbx_business_glossary_term' = 'Policy Count');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `prior_period_balance_amt` SET TAGS ('dbx_business_glossary_term' = 'Prior Period Balance Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `prior_period_balance_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `producer_type` SET TAGS ('dbx_business_glossary_term' = 'Producer Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `producer_type` SET TAGS ('dbx_value_regex' = 'agent|broker|managing_general_agent|surplus_lines_broker');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `regulatory_disclosure_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Disclosure Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `renewal_policy_count` SET TAGS ('dbx_business_glossary_term' = 'Renewal (REN) Policy Count');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `settlement_frequency` SET TAGS ('dbx_business_glossary_term' = 'Commission Settlement Frequency');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `settlement_frequency` SET TAGS ('dbx_value_regex' = 'weekly|bi-weekly|monthly|quarterly');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `settlement_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Period End Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `settlement_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Period Start Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'DUCK_CREEK|GUIDEWIRE|SAPIENS|MANUAL');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_date` SET TAGS ('dbx_business_glossary_term' = 'Commission Statement Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_number` SET TAGS ('dbx_business_glossary_term' = 'Commission Statement Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_number` SET TAGS ('dbx_value_regex' = '^CS-[0-9]{4}-[0-9]{2}-[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_status` SET TAGS ('dbx_business_glossary_term' = 'Commission Statement Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_status` SET TAGS ('dbx_value_regex' = 'draft|issued|disputed|approved|paid|voided');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_type` SET TAGS ('dbx_business_glossary_term' = 'Commission Statement Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `statement_type` SET TAGS ('dbx_value_regex' = 'regular|supplemental|corrected|final');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `tax_form_type` SET TAGS ('dbx_business_glossary_term' = 'Tax Form Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `tax_form_type` SET TAGS ('dbx_value_regex' = '1099-NEC|1099-MISC|W-2|none');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `tax_withheld_amt` SET TAGS ('dbx_business_glossary_term' = 'Tax Withheld Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `tax_withheld_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` SET TAGS ('dbx_subdomain' = 'compensation_processing');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `contingent_bonus_id` SET TAGS ('dbx_business_glossary_term' = 'Contingent Bonus ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `contingent_bonus_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `contingent_bonus_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `actual_lr` SET TAGS ('dbx_business_glossary_term' = 'Actual Loss Ratio (LR)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Bonus Adjustment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Bonus Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `bonus_number` SET TAGS ('dbx_business_glossary_term' = 'Contingent Bonus Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `bonus_number` SET TAGS ('dbx_value_regex' = '^CB-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `bonus_rate` SET TAGS ('dbx_business_glossary_term' = 'Contingent Bonus Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `bonus_status` SET TAGS ('dbx_business_glossary_term' = 'Contingent Bonus Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `bonus_status` SET TAGS ('dbx_value_regex' = 'calculated|approved|disputed|paid|voided|pending_review');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `bonus_type` SET TAGS ('dbx_business_glossary_term' = 'Contingent Bonus Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `bonus_type` SET TAGS ('dbx_value_regex' = 'profit_sharing|contingent_commission|growth_bonus|retention_bonus|volume_bonus|performance_bonus');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Bonus Calculation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `contract_reference` SET TAGS ('dbx_business_glossary_term' = 'Producer Contract Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Bonus Dispute Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `earned_amount` SET TAGS ('dbx_business_glossary_term' = 'Contingent Bonus Earned Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `earned_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `ep_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `ep_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `growth_qualified` SET TAGS ('dbx_business_glossary_term' = 'Growth Qualification Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `growth_target_rate` SET TAGS ('dbx_business_glossary_term' = 'Growth Target Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `gwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `gwp_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `gwp_growth_rate` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP) Growth Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `incurred_losses_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred Losses Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `incurred_losses_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `lae_amount` SET TAGS ('dbx_business_glossary_term' = 'Loss Adjustment Expense (LAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `lae_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `lr_qualified` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR) Qualification Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `lr_threshold` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR) Threshold');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `measurement_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Measurement Period End Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `measurement_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Measurement Period Start Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `net_payable_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Payable Bonus Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `net_payable_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Bonus Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `nwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Written Premium (NWP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `nwp_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `overall_qualified` SET TAGS ('dbx_business_glossary_term' = 'Overall Qualification Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Bonus Payment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Bonus Payment Method');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'ach|check|wire|credit_memo');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `prior_year_gwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Year Gross Written Premium (GWP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `prior_year_gwp_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `program_year` SET TAGS ('dbx_business_glossary_term' = 'Bonus Program Year');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `tax_form_type` SET TAGS ('dbx_business_glossary_term' = 'Tax Form Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `tax_form_type` SET TAGS ('dbx_value_regex' = '1099-MISC|1099-NEC|W-2|none');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `volume_qualified` SET TAGS ('dbx_business_glossary_term' = 'Volume Qualification Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `volume_target_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Volume Target Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `volume_target_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `producer_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Agreement ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Plan ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `prior_agreement_producer_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Agreement ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `agreement_number` SET TAGS ('dbx_business_glossary_term' = 'Producer Agreement Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `agreement_number` SET TAGS ('dbx_value_regex' = '^PA-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `agreement_status` SET TAGS ('dbx_business_glossary_term' = 'Producer Agreement Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `agreement_status` SET TAGS ('dbx_value_regex' = 'draft|active|suspended|terminated|expired|pending_renewal');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Producer Agreement Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'agency|broker|mga|mga_delegated|surplus_lines|direct');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `appointment_state_codes` SET TAGS ('dbx_business_glossary_term' = 'Appointment State Codes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `appointment_state_codes` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `appointment_state_codes` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `audit_rights_flag` SET TAGS ('dbx_business_glossary_term' = 'Audit Rights Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `auto_renewal_flag` SET TAGS ('dbx_business_glossary_term' = 'Auto-Renewal Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `base_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Base Commission Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `base_commission_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `binding_authority_flag` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `compliance_training_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Compliance Training Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `contingent_commission_flag` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `contingent_commission_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `contingent_commission_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `e_and_o_coverage_limit` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Coverage Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `e_and_o_coverage_limit` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `e_and_o_coverage_limit` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `e_and_o_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `e_and_o_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Insurance Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `exclusivity_flag` SET TAGS ('dbx_business_glossary_term' = 'Exclusivity Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `execution_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Execution Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `insurer_signatory_name` SET TAGS ('dbx_business_glossary_term' = 'Insurer Signatory Name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `insurer_signatory_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `insurer_signatory_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `last_compliance_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Compliance Review Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `lob_scope` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Scope');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `loss_ratio_threshold` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR) Threshold');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `loss_ratio_threshold` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `ncb_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'No Claims Bonus (NCB) Eligible Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `notice_period_days` SET TAGS ('dbx_business_glossary_term' = 'Termination Notice Period (Days)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `override_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Override Commission Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `override_commission_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `premium_trust_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Premium Trust Account Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `premium_volume_minimum` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Volume Commitment');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `premium_volume_minimum` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `premium_volume_target` SET TAGS ('dbx_business_glossary_term' = 'Target Premium Volume');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `premium_volume_target` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `producer_signatory_name` SET TAGS ('dbx_business_glossary_term' = 'Producer Signatory Name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `producer_signatory_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `producer_signatory_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `producer_signatory_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `renewal_term_months` SET TAGS ('dbx_business_glossary_term' = 'Renewal Term (Months)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `sub_producer_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Sub-Producer Allowed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `surplus_lines_flag` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Authorization Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Termination Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Agreement Termination Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `territory_scope` SET TAGS ('dbx_business_glossary_term' = 'Territory Scope');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Agreement Version Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `binding_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_business_glossary_term' = 'Eligible Coverage Form Ids (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `producer_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Agreement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `admitted_carrier_flag` SET TAGS ('dbx_business_glossary_term' = 'Admitted Carrier Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `aggregate_annual_limit` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Annual Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `aggregate_annual_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `audit_frequency` SET TAGS ('dbx_business_glossary_term' = 'Audit Frequency');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `audit_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|on_demand');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `authority_name` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `authority_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `authority_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `authority_number` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `authority_number` SET TAGS ('dbx_value_regex' = '^BA-[A-Z0-9]{4,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `authority_status` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `authority_status` SET TAGS ('dbx_value_regex' = 'active|suspended|expired|terminated|pending_approval|under_review');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `authority_type` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `authority_type` SET TAGS ('dbx_value_regex' = 'MGA|Coverholder|Wholesale_Broker|Surplus_Lines|Program_Administrator|Lloyd_Coverholder');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `cat_exposed_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `commission_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `commission_rate_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `eligible_coverage_classes` SET TAGS ('dbx_business_glossary_term' = 'Eligible Coverage Classes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `eligible_coverage_classes` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `eligible_coverage_classes` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `eligible_lob_codes` SET TAGS ('dbx_business_glossary_term' = 'Eligible Lines of Business (LOB) Codes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `eligible_risk_classes` SET TAGS ('dbx_business_glossary_term' = 'Eligible Risk Classes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `excluded_risk_classes` SET TAGS ('dbx_business_glossary_term' = 'Excluded Risk Classes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `excluded_zip_codes` SET TAGS ('dbx_business_glossary_term' = 'Excluded ZIP Codes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `excluded_zip_codes` SET TAGS ('dbx_pii_category' = 'address');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `excluded_zip_codes` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `is_suspended` SET TAGS ('dbx_business_glossary_term' = 'Is Suspended Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `last_audit_date` SET TAGS ('dbx_business_glossary_term' = 'Last Audit Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `loss_ratio_threshold_pct` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR) Threshold Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `max_cat_tiv` SET TAGS ('dbx_business_glossary_term' = 'Maximum Catastrophe (CAT) Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `max_cat_tiv` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `max_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `max_policy_limit` SET TAGS ('dbx_business_glossary_term' = 'Maximum Policy Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `max_policy_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `max_single_risk_limit` SET TAGS ('dbx_business_glossary_term' = 'Maximum Single Risk Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `max_single_risk_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `min_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `next_audit_date` SET TAGS ('dbx_business_glossary_term' = 'Next Audit Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `notice_period_days` SET TAGS ('dbx_business_glossary_term' = 'Notice Period Days');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `profit_commission_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Rate Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `profit_commission_rate_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `program_code` SET TAGS ('dbx_business_glossary_term' = 'Program Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `rate_filing_reference` SET TAGS ('dbx_business_glossary_term' = 'Rate Filing Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `reinsurance_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `reinsurance_required_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `reinsurance_required_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `renewal_type` SET TAGS ('dbx_business_glossary_term' = 'Renewal Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `renewal_type` SET TAGS ('dbx_value_regex' = 'auto|manual|non_renew');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `surplus_lines_flag` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `suspension_date` SET TAGS ('dbx_business_glossary_term' = 'Suspension Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `suspension_reason` SET TAGS ('dbx_business_glossary_term' = 'Suspension Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `territory_country_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Country Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `territory_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `territory_states` SET TAGS ('dbx_business_glossary_term' = 'Territory States');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `underwriting_guidelines_version` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Guidelines Version');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `underwriting_guidelines_version` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `underwriting_guidelines_version` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `onboarding_case_id` SET TAGS ('dbx_business_glossary_term' = 'Onboarding Case ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `application_received_date` SET TAGS ('dbx_business_glossary_term' = 'Application Received Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `appointment_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `appointment_filing_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Filing Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `appointment_state_codes` SET TAGS ('dbx_business_glossary_term' = 'Appointment State Codes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `appointment_state_codes` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `appointment_state_codes` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `assigned_uw_reviewer` SET TAGS ('dbx_business_glossary_term' = 'Assigned Underwriting (UW) Reviewer');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `background_check_date` SET TAGS ('dbx_business_glossary_term' = 'Background Check Completion Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `background_check_provider` SET TAGS ('dbx_business_glossary_term' = 'Background Check Provider');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `background_check_status` SET TAGS ('dbx_business_glossary_term' = 'Background Check Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `background_check_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|clear|adverse|pending_review');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `binding_authority_granted` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Granted');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Limit (USD)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `case_closed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Case Closed Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `case_number` SET TAGS ('dbx_business_glossary_term' = 'Onboarding Case Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `case_number` SET TAGS ('dbx_value_regex' = '^OB-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `case_opened_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Case Opened Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `case_status` SET TAGS ('dbx_business_glossary_term' = 'Onboarding Case Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `case_status` SET TAGS ('dbx_value_regex' = 'pending|in_review|approved|rejected|withdrawn|suspended');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `channel_type` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `channel_type` SET TAGS ('dbx_value_regex' = 'independent_agent|captive_agent|broker|mga|direct');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Eligible');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `contingent_commission_eligible` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `contracting_entity` SET TAGS ('dbx_business_glossary_term' = 'Contracting Entity');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `contracting_entity` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `contracting_entity` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `doi_disciplinary_review_date` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Disciplinary Review Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `doi_disciplinary_review_status` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Disciplinary Review Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `doi_disciplinary_review_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|clear|adverse|pending_review');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `e_o_coverage_verified` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Coverage Verified');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `e_o_coverage_verified` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `e_o_coverage_verified` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `e_o_policy_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `estimated_annual_premium_volume` SET TAGS ('dbx_business_glossary_term' = 'Estimated Annual Premium Volume (GWP)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `estimated_annual_premium_volume` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `license_verification_date` SET TAGS ('dbx_business_glossary_term' = 'License Verification Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `license_verification_status` SET TAGS ('dbx_business_glossary_term' = 'License Verification Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `license_verification_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|verified|failed|expired');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `lob_authorizations` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Authorizations');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `naic_producer_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Producer Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `naic_producer_code` SET TAGS ('dbx_value_regex' = '^[0-9]{7}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `npn` SET TAGS ('dbx_business_glossary_term' = 'National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `npn` SET TAGS ('dbx_value_regex' = '^[0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `ofac_screening_date` SET TAGS ('dbx_business_glossary_term' = 'Office of Foreign Assets Control (OFAC) Screening Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `ofac_screening_status` SET TAGS ('dbx_business_glossary_term' = 'Office of Foreign Assets Control (OFAC) Sanctions Screening Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `ofac_screening_status` SET TAGS ('dbx_value_regex' = 'not_started|clear|potential_match|confirmed_match|escalated');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `prior_carrier_loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Prior Carrier Loss Ratio (LR)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `prior_carrier_loss_ratio` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `producer_agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Producer Agreement Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `producer_agreement_type` SET TAGS ('dbx_value_regex' = 'standard_agency|broker|mga|surplus_lines|program_administrator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `producer_dba_name` SET TAGS ('dbx_business_glossary_term' = 'Producer Doing Business As (DBA) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `producer_dba_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `producer_dba_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `producer_dba_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `producer_legal_name` SET TAGS ('dbx_business_glossary_term' = 'Producer Legal Name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `producer_legal_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `producer_legal_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `producer_tax_number` SET TAGS ('dbx_business_glossary_term' = 'Producer Tax Identification Number (FEIN/SSN)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `producer_tax_number` SET TAGS ('dbx_value_regex' = '^[0-9]{2}-[0-9]{7}$|^[0-9]{3}-[0-9]{2}-[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `producer_tax_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `producer_tax_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `producer_type` SET TAGS ('dbx_business_glossary_term' = 'Producer Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `producer_type` SET TAGS ('dbx_value_regex' = 'individual|agency|broker|managing_general_agent|surplus_lines_broker');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `regulatory_compliance_notes` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `rejection_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `rejection_reason_code` SET TAGS ('dbx_value_regex' = 'adverse_background|license_invalid|ofac_match|doi_disciplinary|e_o_insufficient|incomplete_application');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `rejection_reason_notes` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `system_activation_date` SET TAGS ('dbx_business_glossary_term' = 'System Activation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ALTER COLUMN `years_in_business` SET TAGS ('dbx_business_glossary_term' = 'Years in Business');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `termination_id` SET TAGS ('dbx_business_glossary_term' = 'Termination ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `appointment_id` SET TAGS ('dbx_business_glossary_term' = 'Appointment ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `producer_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Agreement ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `termination_producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `termination_successor_producer_producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Successor Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Approved By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `book_of_business_transfer_date` SET TAGS ('dbx_business_glossary_term' = 'Book of Business Transfer Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `book_of_business_transfer_status` SET TAGS ('dbx_business_glossary_term' = 'Book of Business Transfer Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `book_of_business_transfer_status` SET TAGS ('dbx_value_regex' = 'not_applicable|pending|in_progress|completed|cancelled');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `commission_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Commission Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `commission_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `commission_settlement_status` SET TAGS ('dbx_business_glossary_term' = 'Commission Settlement Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `commission_settlement_status` SET TAGS ('dbx_value_regex' = 'not_applicable|pending|settled|disputed|written_off');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `contest_outcome` SET TAGS ('dbx_business_glossary_term' = 'Contest Outcome');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `contest_outcome` SET TAGS ('dbx_value_regex' = 'upheld|overturned|settled|withdrawn|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `contest_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Contest Resolution Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `e_and_o_coverage_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Coverage Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `e_and_o_coverage_expiry_date` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `e_and_o_coverage_expiry_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `initiated_by_party` SET TAGS ('dbx_business_glossary_term' = 'Termination Initiating Party');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `initiated_by_party` SET TAGS ('dbx_value_regex' = 'insurer|producer|regulator|mutual');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `initiated_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Initiated By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `initiated_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `initiated_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `internal_notes` SET TAGS ('dbx_business_glossary_term' = 'Internal Termination Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `internal_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `is_contested` SET TAGS ('dbx_business_glossary_term' = 'Contested Termination Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `is_for_cause` SET TAGS ('dbx_business_glossary_term' = 'For-Cause Termination Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `is_regulatory_reportable` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reportable Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `notice_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Notice Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `notice_period_days` SET TAGS ('dbx_business_glossary_term' = 'Required Notice Period Days');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Termination Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^TERM-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `pending_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Pending Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `pending_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `reason_code` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `reason_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `reason_description` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason Description');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `regulatory_report_due_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Report Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `regulatory_report_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Report Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `regulatory_report_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|accepted|rejected');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `regulatory_report_submitted_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Report Submitted Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `reinstatement_eligible` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Eligible Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `reinstatement_eligible` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `reinstatement_eligible` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `reinstatement_eligible_date` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Eligible Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `reinstatement_eligible_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `reinstatement_eligible_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `rescission_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Rescission Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'AGENTSYNC|SIRCON|GUIDEWIRE_PC|DUCK_CREEK|SAPIENS');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `state_notification_required` SET TAGS ('dbx_business_glossary_term' = 'State Notification Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `termination_status` SET TAGS ('dbx_business_glossary_term' = 'Termination Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `termination_status` SET TAGS ('dbx_value_regex' = 'pending|submitted|confirmed|rescinded|appealed');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `termination_type` SET TAGS ('dbx_business_glossary_term' = 'Termination Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `termination_type` SET TAGS ('dbx_value_regex' = 'voluntary|involuntary|non_renewal|mutual_agreement|regulatory_action|death_disability');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `producer_compliance_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Compliance ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `compliance_reviewer_producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Reviewer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `compliance_owner_producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `compliance_owner_producers_producer_id` SET TAGS ('dbx_business_role' = 'compliance_owner');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `activation_date` SET TAGS ('dbx_business_glossary_term' = 'Producer Activation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `aml_training_date` SET TAGS ('dbx_business_glossary_term' = 'Anti-Money Laundering (AML) Training Completion Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `anti_money_laundering_trained` SET TAGS ('dbx_business_glossary_term' = 'Anti-Money Laundering (AML) Training Completed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `appointed_lob_codes` SET TAGS ('dbx_business_glossary_term' = 'Appointed Lines of Business (LOB) Codes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `appointment_eligibility_status` SET TAGS ('dbx_business_glossary_term' = 'Appointment Eligibility Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `appointment_eligibility_status` SET TAGS ('dbx_value_regex' = 'eligible|ineligible|conditional|under_review');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `background_check_date` SET TAGS ('dbx_business_glossary_term' = 'Background Check Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `background_check_reference` SET TAGS ('dbx_business_glossary_term' = 'Background Check Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `background_check_status` SET TAGS ('dbx_business_glossary_term' = 'Background Check Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `background_check_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|clear|adverse|pending_review');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `background_check_vendor` SET TAGS ('dbx_business_glossary_term' = 'Background Check Vendor');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `case_close_date` SET TAGS ('dbx_business_glossary_term' = 'Compliance Case Close Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `case_number` SET TAGS ('dbx_business_glossary_term' = 'Compliance Case Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `case_number` SET TAGS ('dbx_value_regex' = '^PC-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `case_open_date` SET TAGS ('dbx_business_glossary_term' = 'Compliance Case Open Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `case_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Case Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `case_status` SET TAGS ('dbx_value_regex' = 'pending|in_review|approved|rejected|suspended|closed');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `case_type` SET TAGS ('dbx_business_glossary_term' = 'Compliance Case Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `case_type` SET TAGS ('dbx_value_regex' = 'initial_appointment|renewal|reinstatement|disciplinary_review|periodic_audit');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `ce_credit_hours_verified` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Credit Hours Verified');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `compliance_notes` SET TAGS ('dbx_business_glossary_term' = 'Compliance Case Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `compliance_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `continuing_education_compliant` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Compliant Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `continuing_education_compliant` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `continuing_education_compliant` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `doi_disciplinary_detail` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Disciplinary Detail');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `doi_disciplinary_detail` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `doi_disciplinary_flag` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Disciplinary Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `doi_disciplinary_order_date` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Disciplinary Order Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `e_o_coverage_verified` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Coverage Verified');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `e_o_coverage_verified` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `e_o_coverage_verified` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `e_o_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `e_o_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `ineligibility_reason` SET TAGS ('dbx_business_glossary_term' = 'Ineligibility Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `license_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'License Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `license_verification_date` SET TAGS ('dbx_business_glossary_term' = 'License Verification Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `license_verification_status` SET TAGS ('dbx_business_glossary_term' = 'License Verification Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `license_verification_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|verified|failed|expired');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `market_conduct_finding_detail` SET TAGS ('dbx_business_glossary_term' = 'Market Conduct Finding Detail');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `market_conduct_finding_detail` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `market_conduct_finding_flag` SET TAGS ('dbx_business_glossary_term' = 'Market Conduct Finding Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Compliance Review Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `nipr_transaction_number` SET TAGS ('dbx_business_glossary_term' = 'National Insurance Producer Registry (NIPR) Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `ofac_match_detail` SET TAGS ('dbx_business_glossary_term' = 'OFAC Match Detail');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `ofac_match_detail` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `ofac_screening_date` SET TAGS ('dbx_business_glossary_term' = 'OFAC Screening Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `ofac_screening_status` SET TAGS ('dbx_business_glossary_term' = 'OFAC Screening Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `ofac_screening_status` SET TAGS ('dbx_value_regex' = 'not_started|clear|match_found|false_positive|escalated');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `producer_license_number` SET TAGS ('dbx_business_glossary_term' = 'Producer License Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `producer_license_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `producer_license_number` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `producer_license_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `review_completed_date` SET TAGS ('dbx_business_glossary_term' = 'Compliance Review Completed Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `state_appointment_filed` SET TAGS ('dbx_business_glossary_term' = 'State Appointment Filed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `state_appointment_filed_date` SET TAGS ('dbx_business_glossary_term' = 'State Appointment Filed Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `territory_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for territory');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `appointment_date` SET TAGS ('dbx_business_glossary_term' = 'Producer Appointment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `cat_zone_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `channel_code` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `channel_code` SET TAGS ('dbx_value_regex' = 'independent_agent|captive_agent|broker|direct|mgа');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `territory_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `conflict_priority` SET TAGS ('dbx_business_glossary_term' = 'Territory Conflict Priority');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `county_fips_code` SET TAGS ('dbx_business_glossary_term' = 'County FIPS Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `county_fips_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `division_code` SET TAGS ('dbx_business_glossary_term' = 'Division Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `division_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Territory Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Territory Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_value_regex' = 'statewide|county|zip_range|msa|custom');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `is_cat_exposed` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposed Territory Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `is_exclusive` SET TAGS ('dbx_business_glossary_term' = 'Exclusive Territory Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `iso_territory_code` SET TAGS ('dbx_business_glossary_term' = 'ISO Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `iso_territory_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `lob_description` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Description');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `market_segment` SET TAGS ('dbx_business_glossary_term' = 'Market Segment');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `market_segment` SET TAGS ('dbx_value_regex' = 'personal|commercial|specialty|excess_surplus');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `max_tiv` SET TAGS ('dbx_business_glossary_term' = 'Maximum Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `msa_code` SET TAGS ('dbx_business_glossary_term' = 'Metropolitan Statistical Area (MSA) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `msa_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `naic_territory_code` SET TAGS ('dbx_business_glossary_term' = 'NAIC Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `naic_territory_code` SET TAGS ('dbx_value_regex' = '^[0-9]{1,6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `territory_name` SET TAGS ('dbx_business_glossary_term' = 'Territory Name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `territory_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `territory_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `new_business_allowed` SET TAGS ('dbx_business_glossary_term' = 'New Business (NB) Allowed Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Territory Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `rating_territory_code` SET TAGS ('dbx_business_glossary_term' = 'Rating Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `rating_territory_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `rating_territory_code` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `rating_territory_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `region_code` SET TAGS ('dbx_business_glossary_term' = 'Region Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `region_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `renewal_allowed` SET TAGS ('dbx_business_glossary_term' = 'Renewal (REN) Allowed Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'agentsync|sircon|guidewire|duck_creek|sapiens|manual');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Territory Termination Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Territory Termination Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'voluntary|non_renewal|performance|regulatory|merger_acquisition|other');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `territory_status` SET TAGS ('dbx_business_glossary_term' = 'Territory Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `territory_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|suspended|expired');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `territory_type` SET TAGS ('dbx_business_glossary_term' = 'Territory Type');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `territory_type` SET TAGS ('dbx_value_regex' = 'exclusive|non_exclusive|preferred|restricted|open');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `uw_restriction_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Restriction Code');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `uw_restriction_code` SET TAGS ('dbx_value_regex' = 'none|moratorium|restricted|suspended|referral_required');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `written_premium_target` SET TAGS ('dbx_business_glossary_term' = 'Written Premium (WP) Target');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `zip_code_end` SET TAGS ('dbx_business_glossary_term' = 'ZIP Code Range End');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `zip_code_end` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `zip_code_end` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `zip_code_end` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `zip_code_start` SET TAGS ('dbx_business_glossary_term' = 'ZIP Code Range Start');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `zip_code_start` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `zip_code_start` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ALTER COLUMN `zip_code_start` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` SET TAGS ('dbx_subdomain' = 'agent_management');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` SET TAGS ('dbx_association_edges' = 'producers.binding_authority,shared.state');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` ALTER COLUMN `authority_territory_id` SET TAGS ('dbx_business_glossary_term' = 'Authority Territory Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` ALTER COLUMN `binding_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Authority Territory - Binding Authority Id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'Authority Territory - State Id');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` ALTER COLUMN `aggregate_limit_per_state` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Annual Limit Per State');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'State Compliance Status');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Territory Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Territory Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` ALTER COLUMN `max_policy_limit_per_state` SET TAGS ('dbx_business_glossary_term' = 'Maximum Policy Limit Per State');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` ALTER COLUMN `premium_tax_rate_override` SET TAGS ('dbx_business_glossary_term' = 'Premium Tax Rate Override');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` ALTER COLUMN `state_approval_date` SET TAGS ('dbx_business_glossary_term' = 'State Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` ALTER COLUMN `state_filing_reference` SET TAGS ('dbx_business_glossary_term' = 'State Filing Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` ALTER COLUMN `surplus_lines_eligible` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Eligible Flag');
