-- Schema for Domain: party | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-20 14:33:31

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_blog_v499`.`party` COMMENT 'SSOT for all persons and organizations the insurer interacts with: policyholders, named/additional insureds, claimants, producers, adjusters, and payees. Owns identity, demographics, KYC, and deduplication.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` (
    `party_id` BIGINT COMMENT 'Unique surrogate key for every person or organization in the MDM party master. One row per party. Role = MASTER_PARTY primary key.',
    `master_party_id` BIGINT COMMENT 'References the surviving golden-record party_id when this record has been merged into another. Null if this record is itself the golden record. Supports MDM deduplication lineage.',
    `address_line1` STRING COMMENT 'First line of the partys primary mailing/residence address (street number and name). Used for policy issuance, billing, regulatory filings, and territory rating.',
    `address_line2` STRING COMMENT 'Second line of the partys primary address (suite, apartment, unit, floor). Supplementary to address_line1 for complete mailing address.',
    `city` STRING COMMENT 'City or municipality of the partys primary address. Used in territory rating, catastrophe aggregation, and regulatory jurisdiction determination.',
    `clue_report_date` DATE COMMENT 'Date the most recent CLUE loss history report was ordered for this party. Used in personal lines underwriting to assess prior claims history. Governed by FCRA.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for the partys primary address (e.g., USA, CAN). Required for international commercial lines and OFAC/sanctions screening.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the party record was first created in the MDM system. Immutable audit field. RECORD_AUDIT_CREATED per MASTER_PARTY canonical category.',
    `credit_score` BIGINT COMMENT 'Insurance-based credit score used in personal lines rating (HO, PAP) where state-permitted. Sourced from credit bureaus under FCRA. Range typically 150–950. Null where prohibited by state DOI.',
    `credit_score_date` DATE COMMENT 'Date the insurance credit score was last obtained from the credit bureau. Used to determine score freshness and re-pull schedules per FCRA and state DOI requirements.',
    `date_of_birth` DATE COMMENT 'Date of birth for a natural person. Used in age-based rating, MVR eligibility, KYC identity verification, and OFAC/sanctions screening. Null for ORGANIZATION.',
    `date_of_death` DATE COMMENT 'Date of death for a natural person, populated when confirmed. Triggers policy lifecycle actions (cancellation, beneficiary notification) and stops billing. Null if living or ORGANIZATION.',
    `date_of_incorporation` DATE COMMENT 'Date the organization was legally incorporated or formed. Used to calculate years_in_business and validate commercial underwriting eligibility. Null for INDIVIDUAL.',
    `do_not_contact_flag` BOOLEAN COMMENT 'Indicates the party has opted out of marketing and non-essential communications. Enforced in outbound campaign and billing communication workflows per TCPA and GLBA opt-out rules.',
    `family_name` STRING COMMENT 'Surname/family name of a natural person. Null for ORGANIZATION party type. Used in KYC, CLUE, MVR, and OFAC screening.',
    `fraud_indicator_flag` BOOLEAN COMMENT 'Set to True when the SIU or fraud detection system has flagged this party for suspected fraudulent activity. Triggers enhanced review on new submissions and claims.',
    `full_name` STRING COMMENT 'Golden-record display name. For individuals: concatenated given + family name. For organizations: legal entity name. Primary IDENTITY_LABEL per MDM golden record.',
    `gender` STRING COMMENT 'Self-reported gender of a natural person: M=Male, F=Female, X=Non-binary/Other, U=Unknown. Used in auto rating where state-permitted. Null for ORGANIZATION.. Valid values are `M|F|X|U`',
    `given_name` STRING COMMENT 'First/given name of a natural person. Null for ORGANIZATION party type. Used in correspondence, KYC matching, and CLUE/MVR lookups.',
    `golden_record_flag` BOOLEAN COMMENT 'True if this party record is the MDM-designated master (golden) record after deduplication. False for duplicate or candidate records pending merge resolution.',
    `kyc_status` STRING COMMENT 'Current KYC/AML verification status of the party. VERIFIED = identity confirmed; FAILED = verification failed; REVIEW = under enhanced due diligence. Required for GLBA and BSA/AML compliance.. Valid values are `PENDING|VERIFIED|FAILED|EXEMPT|REVIEW`',
    `kyc_verified_date` DATE COMMENT 'Date on which the partys identity was most recently verified through the KYC process. Used to determine re-verification schedules and compliance audit trails.',
    `legal_entity_name` STRING COMMENT 'Registered legal name of an organization as filed with the state or federal authority. Null for INDIVIDUAL party type. Used in commercial lines underwriting and FEIN matching.',
    `marital_status` STRING COMMENT 'Marital status of a natural person used in personal lines rating (HO, PAP). Null for ORGANIZATION. [ENUM-REF-CANDIDATE: SINGLE|MARRIED|DIVORCED|WIDOWED|SEPARATED|UNKNOWN — promote to reference product]. Valid values are `SINGLE|MARRIED|DIVORCED|WIDOWED|SEPARATED|UNKNOWN`',
    `naics_code` STRING COMMENT 'NAICS code classifying the industry of an organization party. Used in commercial lines underwriting, CGL class rating, BOP eligibility, and actuarial segmentation.. Valid values are `^[0-9]{2,6}$`',
    `ofac_match_flag` BOOLEAN COMMENT 'Indicates whether the party returned a potential match on the OFAC SDN or consolidated sanctions list. True triggers manual review and blocks policy binding until cleared.',
    `ofac_screened_date` DATE COMMENT 'Most recent date the party was screened against the OFAC Specially Designated Nationals (SDN) list. Required for regulatory compliance before policy binding.',
    `organization_type` STRING COMMENT 'Legal structure of an organization party. Drives commercial lines eligibility, CGL/BOP underwriting rules, and FEIN validation. Null for INDIVIDUAL. [ENUM-REF-CANDIDATE: CORPORATION|LLC|PARTNERSHIP|SOLE_PROP|TRUST|NONPROFIT|GOVERNMENT|OTHER — promote to',
    `party_status` STRING COMMENT 'Current MDM lifecycle state of the party record. ACTIVE = in use; INACTIVE = no current relationships; DECEASED = confirmed death; MERGED = superseded by survivor; SUSPENDED = under review.. Valid values are `ACTIVE|INACTIVE|DECEASED|MERGED|SUSPENDED`',
    `party_type` STRING COMMENT 'Discriminator distinguishing a natural person (INDIVIDUAL) from a legal entity (ORGANIZATION). Drives which subtype attributes are populated and which KYC rules apply.. Valid values are `INDIVIDUAL|ORGANIZATION`',
    `postal_code` STRING COMMENT 'US ZIP or ZIP+4 postal code for the partys primary address. Used in territory rating, catastrophe zone mapping, and USPS address validation.. Valid values are `^d{5}(-d{4})?$`',
    `preferred_contact_method` STRING COMMENT 'Partys stated preference for receiving communications: EMAIL, PHONE, MAIL, TEXT, or PORTAL. Drives outbound communication routing in PAS and billing systems.. Valid values are `EMAIL|PHONE|MAIL|TEXT|PORTAL`',
    `preferred_language` STRING COMMENT 'ISO 639-1 language code (optionally with BCP-47 region tag, e.g., en-US, es-MX) indicating the partys preferred language for documents and communications.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `primary_email` STRING COMMENT 'Primary electronic mail address for the party. Used for policy documents, billing notices, FNOL acknowledgements, and regulatory correspondence. PRIMARY_CONTACT field per MASTER_PARTY role.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_phone` STRING COMMENT 'Primary telephone number in E.164 format. Used for FNOL intake, billing collections, underwriting contact, and fraud/SIU outreach.. Valid values are `^+?[1-9]d{1,14}$`',
    `privacy_opt_out_flag` BOOLEAN COMMENT 'Indicates the party has exercised their right to opt out of information sharing with non-affiliated third parties under GLBA/CCPA. Restricts data sharing in downstream systems.',
    `sic_code` STRING COMMENT 'Four-digit SIC code for an organization party. Legacy classification used alongside NAICS in commercial underwriting, ISO rating, and NAIC statutory reporting.. Valid values are `^[0-9]{4}$`',
    `source_system_code` STRING COMMENT 'Identifies the operational system of record that originated this party record (e.g., PAS = Guidewire PolicyCenter, CLAIMS = ClaimCenter). Used for MDM lineage and deduplication.',
    `source_system_party_code` STRING COMMENT 'The partys native identifier in the originating operational system (e.g., Guidewire contact ID, ClaimCenter party ID). Enables cross-system reconciliation and MDM matching.',
    `state_code` STRING COMMENT 'Two-letter US state or territory code (USPS abbreviation) for the partys primary address. Determines applicable DOI jurisdiction, rate filings, and statutory requirements.. Valid values are `^[A-Z]{2}$`',
    `state_of_incorporation` STRING COMMENT 'Two-letter US state code where the organization was legally incorporated. Relevant for surplus lines eligibility, admitted vs non-admitted determination, and regulatory filings.. Valid values are `^[A-Z]{2}$`',
    `tax_id_type` STRING COMMENT 'Classifies the tax identifier held in the party identifier table: Social Security Number (SSN), Federal Employer Identification Number (FEIN), Individual Taxpayer Identification Number (ITIN), or other.. Valid values are `SSN|FEIN|ITIN|EIN|OTHER`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the party record in the MDM system. Used for change data capture, audit trails, and downstream incremental loads.',
    `years_in_business` BIGINT COMMENT 'Number of years the organization has been in continuous operation. Used in commercial lines underwriting as a risk factor for BOP, CGL, and E&O eligibility.',
    CONSTRAINT pk_party PRIMARY KEY(`party_id`)
) COMMENT 'SSOT master record for every person or organization the insurer interacts with. One row per party. Owns golden-record identity, KYC status, dedup keys, and MDM flags. Tax IDs and external keys live in identifier, not here.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` (
    `role_id` BIGINT COMMENT 'Unique surrogate identifier for a party role assignment. One row per party-role assignment instance.',
    `claim_id` BIGINT COMMENT 'Reference to the claim under which this role is assigned, when the role is claim-scoped (e.g., claimant, adjuster, payee on a specific claim).',
    `commission_id` BIGINT COMMENT 'Foreign key linking to premium.commission. Business justification: Producer roles (agents, brokers, MGAs) are the natural owners of commission records. While commission already links to producer_id, party_role.role_id provides granular tracking of which',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Party roles (insured, agent, claimant) operate within specific LOB contexts. Underwriting rules, commission structures, and role eligibility vary by LOB.',
    `party_id` BIGINT COMMENT 'Reference to the party (person or organization) holding this role. Links to the Party master record.',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which this role is assigned, when the role is policy-scoped (e.g., policyholder, named insured, additional insured).',
    `acord_role_code` STRING COMMENT 'Standardized ACORD data standard role code for this party role assignment. Enables interoperability with trading partners, MGAs, and reinsurers using ACORD XML/JSON.',
    `assignment_reason` STRING COMMENT 'Business reason that triggered the creation of this role assignment. Supports audit trails and lifecycle analysis across the policy and claims lifecycle. [ENUM-REF-CANDIDATE',
    `consent_obtained_date` DATE COMMENT 'Date on which the required consent was obtained from the party for this role. Null if consent has not yet been obtained or is not required.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this party role assignment record was first created in the data platform. Supports audit trails and data lineage per SOX and NAIC requirements.',
    `do_not_contact_flag` BOOLEAN COMMENT 'Indicates that this party has requested no outbound contact in this role. Enforces compliance with TCPA, CAN-SPAM, and state do-not-call regulations.',
    `effective_date` DATE COMMENT 'Date on which this party role assignment becomes effective. Used to reconstruct roles in force at any given date, including the loss date.',
    `expiration_date` DATE COMMENT 'Date on which this party role assignment expires or is terminated. Null indicates the role is open-ended and currently active.',
    `fraud_score` DECIMAL(5,2) COMMENT 'Numeric fraud risk score assigned to this party in this role by the fraud detection system. Higher values indicate greater fraud risk. Range 0.00 to 100.00.',
    `guardian_flag` BOOLEAN COMMENT 'Indicates whether this party is acting as a legal guardian for a minor or incapacitated insured in this role. Affects claims payment authorization and policy management.',
    `interest_type_code` STRING COMMENT 'Specifies the nature of the insurable interest held by the party in this role. Relevant for property and auto lines where multiple parties have financial interests.. Valid values are `OWNER|MORTGAGEE|LOSS_PAYEE|LIENHOLDER|LESSOR|TRUSTEE`',
    `is_consent_required` BOOLEAN COMMENT 'Flags whether this party role requires explicit consent for data processing or communications under GLBA, GDPR, or CCPA privacy regulations.',
    `is_primary_role` BOOLEAN COMMENT 'Indicates whether this is the primary instance of the role type for the associated policy or claim. True for the first named insured or lead claimant.',
    `kyc_verified` BOOLEAN COMMENT 'Indicates whether Know Your Customer identity verification has been completed for this party in this role. Required for producers and high-value policyholders.',
    `kyc_verified_date` DATE COMMENT 'Date on which KYC verification was completed for this party role. Used for compliance audit trails and periodic re-verification scheduling.',
    `language_preference` STRING COMMENT 'Preferred language for communications with this party in this role, expressed as a BCP 47 language tag (e.g., en-US, es-MX). Supports regulatory plain-language requirements.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `litigation_flag` BOOLEAN COMMENT 'Indicates whether this party role is involved in active litigation related to a claim or policy dispute. Triggers legal hold and restricts certain automated communications.',
    `notes` STRING COMMENT 'Free-text notes or remarks entered by underwriters, adjusters, or administrators regarding this specific party role assignment. Supports audit and workflow context.',
    `notification_preference` STRING COMMENT 'Preferred communication channel for this party in this role. Drives billing notices, policy documents, and claims correspondence delivery.. Valid values are `EMAIL|MAIL|PHONE|PORTAL|NONE`',
    `ofac_match_flag` BOOLEAN COMMENT 'Indicates whether the OFAC screening returned a potential match for this party. A True value triggers a compliance hold and manual review workflow.',
    `ofac_screen_date` DATE COMMENT 'Most recent date on which the OFAC screening was performed for this party in this role. Supports periodic re-screening compliance requirements.',
    `ofac_screened` BOOLEAN COMMENT 'Indicates whether this party has been screened against the OFAC Specially Designated Nationals list for this role assignment. Mandatory for regulatory compliance.',
    `power_of_attorney_flag` BOOLEAN COMMENT 'Indicates whether this party is acting under a power of attorney on behalf of another party in this role. Triggers additional documentation and authorization requirements.',
    `relationship_to_insured` STRING COMMENT 'Describes the relationship of this party to the primary named insured. Used for household underwriting, rating, and claims adjudication. [ENUM-REF-CANDIDATE: SELF|SPOUSE|CHILD|PARENT|SIBLING|EMPLOYEE|PARTNER|OTHER — 8 candidates stripped; promote to',
    `represented_by_counsel` BOOLEAN COMMENT 'Indicates whether this party is represented by legal counsel in this role. When True, all communications must be directed to the attorney of record.',
    `role_status` STRING COMMENT 'Current lifecycle state of this party role assignment. Drives eligibility checks, billing, and claims adjudication workflows.. Valid values are `ACTIVE|INACTIVE|PENDING|SUSPENDED|TERMINATED`',
    `sequence_number` BIGINT COMMENT 'Ordinal position when multiple parties hold the same role type on the same policy or claim (e.g., first named insured = 1, second named insured = 2).',
    `siu_referral_flag` BOOLEAN COMMENT 'Indicates whether this party role has been referred to the Special Investigations Unit for fraud investigation. Relevant for claimant and adjuster roles.',
    `source_system_role_code` STRING COMMENT 'The native identifier for this role assignment in the originating source system (e.g., Guidewire PolicyCenter contact role ID). Supports lineage and reconciliation.',
    `subtype_code` STRING COMMENT 'Further classifies the role within its type. For example, distinguishes First Party from Third Party claimants, or Primary from Secondary named insureds.. Valid values are `FIRST_PARTY|THIRD_PARTY|PRIMARY|SECONDARY|CONTINGENT`',
    `tax_identification_number` STRING COMMENT 'Federal tax identifier for this party in this role. May be an SSN for individuals or FEIN for organizations. Required for 1099 and statutory reporting.',
    `tax_reporting_required` BOOLEAN COMMENT 'Indicates whether IRS tax reporting (e.g., 1099 issuance) is required for payments made to this party in this role. Relevant for payee, claimant, and producer roles.',
    `termination_reason` STRING COMMENT 'Business reason for the termination or expiration of this role assignment. Null if the role is still active. Supports regulatory and audit reporting. [ENUM-REF-CANDIDATE: CANCELLATION|NON_RENEWAL|ENDORSEMENT_REMOVAL|CLAIM_CLOSED|DEATH|COURT_ORDER|OTHER —',
    `type_code` STRING COMMENT 'Classifies the functional role the party plays in the insurance lifecycle. [ENUM-REF-CANDIDATE: POLICYHOLDER|NAMED_INSURED|ADDITIONAL_INSURED|CLAIMANT|PRODUCER|ADJUSTER|PAYEE|MORTGAGEE|LOSS_PAYEE|ADDITIONAL_INTEREST — promote to reference product]',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this party role assignment record was last modified in the data platform. Supports change tracking, audit trails, and incremental data loading.',
    `w9_on_file` BOOLEAN COMMENT 'Indicates whether a valid IRS Form W-9 has been collected and is on file for this party role. Required before issuing payments to producers, vendors, and claimants.',
    `w9_received_date` DATE COMMENT 'Date on which the IRS Form W-9 was received from this party for this role. Supports tax compliance audit trails and payment hold management.',
    CONSTRAINT pk_role PRIMARY KEY(`role_id`)
) COMMENT 'Assigns a role to a party with effective and expiration dates. One row per party-role assignment. Roles include policyholder, named insured, additional insured, claimant, producer, adjuster, and payee. Never embeds role on the party record.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` (
    `individual_id` BIGINT COMMENT 'Unique surrogate key identifying a natural person in the party master. One row per individual. MASTER_PARTY role; canonical-attrs-enforced.',
    `party_id` BIGINT COMMENT 'Foreign key reference to the parent Party record in the enterprise party master. Links the individual subtype to its supertype party record.',
    `birth_date` DATE COMMENT 'Individuals date of birth in ISO 8601 format. Used for age-based rating, eligibility screening, MVR ordering, and FCRA-compliant underwriting.',
    `citizenship_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the individuals country of citizenship. Used for KYC, OFAC screening, and international policy eligibility.. Valid values are `^[A-Z]{3}$`',
    `clue_consent_flag` BOOLEAN COMMENT 'Indicates whether the individual has consented to a CLUE report pull for prior loss history. Required under FCRA before accessing LexisNexis CLUE data.',
    `communication_preference` STRING COMMENT 'Individuals preferred channel for receiving policy documents, billing notices, and claims correspondence. Drives document delivery routing in the PAS and billing system.. Valid values are `email|mail|phone|text|portal`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this individual record was first created in the lakehouse silver layer. Used for audit trail, data lineage, and GDPR right-to-erasure tracking.',
    `credit_score` BIGINT COMMENT 'Insurance-based credit score obtained from a consumer reporting agency. Used as a rating variable in personal lines where permitted by state DOI. Governed by FCRA.',
    `credit_score_date` DATE COMMENT 'Date on which the insurance credit score was last obtained. Used to determine score currency and trigger re-pull at renewal per underwriting guidelines.',
    `credit_score_source` STRING COMMENT 'Name of the consumer reporting agency or scoring model that provided the insurance credit score. Required for FCRA adverse action notices and audit trails.. Valid values are `LexisNexis|Equifax|Experian|TransUnion|FICO|other`',
    `deceased_date` DATE COMMENT 'Date of death for the individual if known. Triggers policy lifecycle actions (cancellation, beneficiary notification) and stops renewal processing.',
    `do_not_contact_flag` BOOLEAN COMMENT 'Indicates the individual has opted out of marketing and non-essential communications. Enforced per TCPA, CAN-SPAM, and state privacy regulations including CCPA.',
    `drivers_license_expiry_date` DATE COMMENT 'Expiration date of the individuals driver license. Used to flag expired licenses during auto underwriting eligibility checks and renewal processing.',
    `drivers_license_number` STRING COMMENT 'State-issued driver license number for the individual. Required for MVR ordering, auto underwriting eligibility, and claims investigation in personal and commercial auto lines.',
    `drivers_license_state` STRING COMMENT 'Two-letter USPS state code of the jurisdiction that issued the individuals driver license. Required to route MVR orders to the correct state DMV.. Valid values are `^[A-Z]{2}$`',
    `employer_name` STRING COMMENT 'Name of the individuals current employer. Used in commercial lines underwriting, group policy eligibility verification, and workers compensation exposure assessment.',
    `first_name` STRING COMMENT 'Legal given name of the individual as it appears on government-issued identification. Used for policy issuance, claims, and regulatory reporting.',
    `fraud_indicator_flag` BOOLEAN COMMENT 'Flag set by the SIU or fraud detection system indicating the individual has an active fraud alert or prior confirmed fraud history. Triggers referral to SIU on new submissions.',
    `gender_code` STRING COMMENT 'Gender of the individual as reported. M=Male, F=Female, X=Non-binary/Other, U=Unknown. Used in auto and life rating where permitted by state DOI regulations.. Valid values are `M|F|X|U`',
    `golden_record_flag` BOOLEAN COMMENT 'Indicates this individual record is the master golden record in the MDM after deduplication. Non-golden records are survivorship candidates linked to the golden record.',
    `kyc_status` STRING COMMENT 'Current KYC verification status for the individual. Required for GLBA compliance and OFAC/AML screening before policy binding or claim payment disbursement.. Valid values are `pending|verified|failed|exempt`',
    `kyc_verified_date` DATE COMMENT 'Date on which the individuals identity was last successfully verified through the KYC process. Used to determine re-verification cadence per compliance policy.',
    `last_name` STRING COMMENT 'Legal surname of the individual as it appears on government-issued identification. Used for policy issuance, claims, and regulatory reporting.',
    `marital_status_code` STRING COMMENT 'Marital status of the individual. S=Single, M=Married, D=Divorced, W=Widowed, P=Domestic Partner. Used as a rating variable in personal auto and homeowners lines.. Valid values are `S|M|D|W|P`',
    `middle_name` STRING COMMENT 'Legal middle name or initial of the individual. Used for identity disambiguation and matching against MVR and CLUE reports.',
    `mvr_consent_flag` BOOLEAN COMMENT 'Indicates whether the individual has provided written consent for the insurer to order an MVR report. Required under FCRA before pulling driving history for underwriting.',
    `mvr_order_date` DATE COMMENT 'Date on which the most recent MVR report was ordered for this individual. Used to determine MVR currency and trigger re-order at renewal per underwriting guidelines.',
    `name_prefix` STRING COMMENT 'Honorific or title prefix for the individuals name (e.g., Mr., Dr.). Used in correspondence, policy documents, and declarations pages.. Valid values are `Mr.|Mrs.|Ms.|Dr.|Prof.`',
    `name_suffix` STRING COMMENT 'Generational or professional suffix appended to the individuals legal name (e.g., Jr., Sr., II). Used for precise identity matching and document generation.. Valid values are `Jr.|Sr.|II|III|IV|Esq.`',
    `occupation_code` STRING COMMENT 'Standardized occupation classification code for the individual. Used as a rating variable in personal lines and for SIC/NAICS alignment in commercial underwriting.',
    `occupation_description` STRING COMMENT 'Free-text description of the individuals occupation or job title as self-reported on the application. Supplements the occupation code for underwriting review.',
    `ofac_screen_date` DATE COMMENT 'Date of the most recent OFAC screening for this individual. Used to determine whether a re-screen is required at renewal or prior to claim payment.',
    `ofac_screened_flag` BOOLEAN COMMENT 'Indicates whether the individual has been screened against the OFAC Specially Designated Nationals list. Mandatory before policy issuance and claim payment.',
    `preferred_language_code` STRING COMMENT 'BCP 47 language tag representing the individuals preferred communication language (e.g., en-US, es-MX). Used for policy document generation and claims correspondence.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `prior_carrier_name` STRING COMMENT 'Name of the individuals most recent prior insurance carrier. Used in underwriting to verify continuous coverage and assess prior loss history context.',
    `prior_policy_expiry_date` DATE COMMENT 'Expiration date of the individuals most recent prior policy. Used to calculate coverage lapse duration and apply lapse surcharges per underwriting guidelines.',
    `residency_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the individuals country of primary residence. Used for jurisdictional rating, regulatory compliance, and tax reporting.. Valid values are `^[A-Z]{3}$`',
    `residency_state_code` STRING COMMENT 'Two-letter USPS state code of the individuals state of primary residence. Determines applicable state DOI regulations, rating territory, and statutory form requirements.. Valid values are `^[A-Z]{2}$`',
    `siu_referral_date` DATE COMMENT 'Date on which this individual was most recently referred to the Special Investigations Unit for fraud investigation. Null if no referral has occurred.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record that originated this individual record (e.g., PAS=PolicyCenter, CLAIMS=ClaimCenter, MDM=Party MDM). Used for data lineage.. Valid values are `PAS|CLAIMS|BILLING|MDM|PRODUCER|MANUAL`',
    `source_system_person_code` STRING COMMENT 'Native identifier for this individual in the originating operational system (e.g., Guidewire PolicyCenter contact ID). Used for cross-system reconciliation and ETL lineage.',
    `ssn_hash` STRING COMMENT 'One-way cryptographic hash of the individuals SSN. Used for identity deduplication and CLUE/MVR ordering without storing the raw SSN in the lakehouse.',
    `ssn_last_four` STRING COMMENT 'Last four digits of the individuals SSN retained for identity verification and customer service purposes per GLBA data minimization requirements.. Valid values are `^[0-9]{4}$`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this individual record in the lakehouse silver layer. Used for change data capture, audit trail, and SCD Type 1/2 processing.',
    `years_continuously_insured` BIGINT COMMENT 'Number of years the individual has maintained continuous insurance coverage without a lapse. Used as a rating and eligibility variable in personal lines underwriting.',
    CONSTRAINT pk_individual PRIMARY KEY(`individual_id`)
) COMMENT 'Person-specific subtype of party. Stores legal name, date of birth, gender, marital status, driver license number, and MVR consent flag for natural persons underwritten or involved in claims. External IDs live in identifier.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` (
    `organization_id` BIGINT COMMENT 'Unique surrogate identifier for the organization record in the party master data management system. Primary key for the organization entity.',
    `mailing_address_id` BIGINT COMMENT 'Foreign key linking to party.address. Business justification: Organization embeds mailing address fields that duplicate the address table structure. The address table is the SSOT for all addresses and provides geocoding, territory codes, CAT zones, and',
    `parent_organization_id` BIGINT COMMENT 'Self-referencing identifier pointing to the immediate parent organization in a corporate hierarchy. Supports enterprise account management, consolidated TIV, and group policy structures.',
    `party_id` BIGINT COMMENT 'Foreign key reference to the parent Party record in the enterprise party master. Links the organization subtype to its supertype party record.',
    `primary_ultimate_parent_organization_id` BIGINT COMMENT 'Identifier of the top-level ultimate parent in the corporate ownership hierarchy. Used for enterprise-wide exposure aggregation, PML modeling, and group reinsurance treaty application.',
    `annual_payroll` DECIMAL(18,2) COMMENT 'Organizations total annual payroll in USD. Primary rating basis for Workers Compensation (WC) and a secondary factor for CGL and employer liability lines.',
    `annual_revenue` DECIMAL(18,2) COMMENT 'Organizations most recently reported annual gross revenue in USD. Used as a rating basis for CGL, E&O, D&O, and EPLI lines, and for exposure-based premium calculations.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the organization record was first created in the system. Supports audit trail, data lineage, and regulatory record-keeping requirements under SOX and GLBA.',
    `credit_score` BIGINT COMMENT 'Commercial credit score from a recognized bureau (e.g., D&B Paydex, Experian Business). Used in commercial lines underwriting for financial stability assessment and pricing.',
    `credit_score_source` STRING COMMENT 'Source bureau or model that produced the commercial credit score. Required for FCRA compliance, adverse action notices, and audit of underwriting decisions.. Valid values are `dun_bradstreet|experian|equifax|fico|internal`',
    `dba_name` STRING COMMENT 'Trade name or doing-business-as name used by the organization in commercial operations, which may differ from the registered legal name.',
    `duns_number` STRING COMMENT 'Nine-digit Dun & Bradstreet Data Universal Numbering System (DUNS) number for the organization. Used for commercial credit scoring, financial strength assessment, and third-party data enrichment.. Valid values are `^[0-9]{9}$`',
    `employee_count` BIGINT COMMENT 'Total number of full-time equivalent employees. Used in underwriting for WC classification, EPLI exposure assessment, and BOP eligibility determination.',
    `entity_type` STRING COMMENT 'Legal structure of the organization (e.g., corporation, LLC, partnership). Drives underwriting eligibility, policy form selection, and liability exposure assessment.',
    `fein` STRING COMMENT 'IRS-issued Federal Employer Identification Number (FEIN) uniquely identifying the organization for tax and regulatory purposes. Required for commercial policy issuance and 1099 reporting.. Valid values are `^[0-9]{2}-[0-9]{7}$`',
    `financial_statement_date` DATE COMMENT 'Date of the most recent financial statement used to derive annual revenue and payroll figures. Ensures underwriting data currency and supports audit trail for rating basis.',
    `fraud_indicator` BOOLEAN COMMENT 'Flag set by the SIU or fraud detection system indicating the organization has been associated with suspected or confirmed fraudulent activity. Triggers underwriting referral.',
    `incorporation_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code where the organization is incorporated. Required for international commercial accounts, reinsurance counterparties, and OFAC/sanctions screening.. Valid values are `^[A-Z]{3}$`',
    `incorporation_date` DATE COMMENT 'Date the organization was legally incorporated or formed. Used in underwriting to assess years in business, business continuity risk, and eligibility for certain commercial lines.',
    `incorporation_state` STRING COMMENT 'Two-letter US state code where the organization is legally incorporated or registered. Used for jurisdictional underwriting rules, admitted vs. surplus lines determination, and regulatory compliance.. Valid values are `^[A-Z]{2}$`',
    `kyc_status` STRING COMMENT 'Current KYC verification status for the organization. Tracks AML/BSA compliance screening outcome. Policies cannot be bound for organizations with failed or pending KYC status.. Valid values are `pending|verified|failed|exempt`',
    `kyc_verified_date` DATE COMMENT 'Date on which the organizations KYC verification was last completed or refreshed. Drives periodic re-verification schedules per AML/BSA compliance requirements.',
    `legal_name` STRING COMMENT 'Full legal name of the organization as registered with the state or federal authority. Used on policy declarations, certificates of insurance, and regulatory filings.',
    `naic_code` STRING COMMENT 'Five-digit NAIC company code assigned to insurance carriers and reinsurers. Used for statutory reporting, Schedule F, and reinsurance counterparty identification.. Valid values are `^[0-9]{5}$`',
    `naics_code` STRING COMMENT 'Six-digit NAICS code identifying the organizations primary industry. Supplements SIC for modern commercial underwriting, risk classification, and regulatory reporting.. Valid values are `^[0-9]{6}$`',
    `naics_description` STRING COMMENT 'Plain-text description of the organizations primary business activity corresponding to the NAICS code. Provides human-readable context for underwriters and auditors.',
    `ofac_screen_date` DATE COMMENT 'Date of the most recent OFAC SDN screening for the organization. Supports compliance audit and triggers re-screening when the record is updated or a policy is renewed.',
    `ofac_screened` BOOLEAN COMMENT 'Indicates whether the organization has been screened against the OFAC Specially Designated Nationals (SDN) list. Must be true before policy binding per regulatory requirements.',
    `preferred_language` STRING COMMENT 'BCP 47 language tag representing the organizations preferred language for communications (e.g., en-US, es-MX). Drives document generation and customer service routing.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `primary_email` STRING COMMENT 'Primary business email address for the organization. Used for policy document delivery, billing notices, claims correspondence, and regulatory communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_phone` STRING COMMENT 'Primary business telephone number for the organization. Used for underwriting contact, claims notification, billing, and producer communication.. Valid values are `^+?[0-9-s().]{7,20}$`',
    `publicly_traded` BOOLEAN COMMENT 'Indicates whether the organizations securities are publicly traded on a recognized exchange. Relevant for D&O, EPLI, and E&O underwriting and for financial disclosure requirements.',
    `revenue_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the annual revenue and payroll amounts. Defaults to USD for domestic accounts; required for multinational commercial programs.. Valid values are `^[A-Z]{3}$`',
    `sic_code` STRING COMMENT 'Four-digit SIC code classifying the organization by primary business activity. Used in commercial underwriting, rating, and ISO classification for CGL and BOP lines.. Valid values are `^[0-9]{4}$`',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record that originated this organization record (e.g., PAS, CMS, MDM). Supports data lineage, deduplication, and master data governance.. Valid values are `pas|cms|billing|agency_mgmt|mdm|reinsurance`',
    `source_system_ref_code` STRING COMMENT 'Native identifier of this organization record in the originating source system. Enables cross-system reconciliation, deduplication, and lineage tracing in the MDM and data lakehouse.',
    `stock_ticker` STRING COMMENT 'Exchange ticker symbol for publicly traded organizations. Used in D&O underwriting, financial strength monitoring, and market capitalization-based exposure assessment.. Valid values are `^[A-Z]{1,5}$`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the organization record. Used for change data capture, MDM synchronization, and audit trail maintenance per SOX and GLBA requirements.',
    `website_url` STRING COMMENT 'Official website URL of the organization. Used in commercial underwriting for business activity verification, cyber risk assessment, and e-commerce exposure evaluation.',
    `years_in_business` BIGINT COMMENT 'Number of years the organization has been in continuous operation. Key underwriting factor for commercial lines eligibility, experience rating, and risk assessment.',
    CONSTRAINT pk_organization PRIMARY KEY(`organization_id`)
) COMMENT 'Legal-entity subtype of party. Stores legal name, FEIN, NAIC code, SIC/NAICS code, entity type (corp, LLC, partnership), state of incorporation, and D&B DUNS for commercial insureds and counterparties.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` (
    `address_id` BIGINT COMMENT 'Unique surrogate identifier for each address record in the party domain. Primary key. One row per address per party.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Underwriting eligibility decisions, moratorium enforcement, and concentration management require direct cat_zone assignment to addresses.',
    `flood_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.flood_zone. Business justification: NFIP compliance, mandatory flood insurance determination, and flood coverage pricing require linking property addresses to FEMA flood zones.',
    `party_id` BIGINT COMMENT 'Reference to the party (person or organization) that owns this address. Links address to the Party master record.',
    `acord_address_type_code` STRING COMMENT 'ACORD standard address type code from the ACORD data dictionary. Enables interoperability with ACORD 125/126/140 forms and carrier/agency data exchanges.',
    `address_status` STRING COMMENT 'Current operational status of the address record. Active addresses receive policy documents and billing. Returned_mail triggers address update workflow in the PAS.. Valid values are `active|inactive|unverified|returned_mail|do_not_mail`',
    `address_type` STRING COMMENT 'Classifies the purpose of the address: mailing for correspondence, billing for invoices, risk for insured property location, garaging for auto, loss for claim site.',
    `care_of_name` STRING COMMENT 'In-care-of name for mail delivery when correspondence is directed through a third party (e.g., attorney, trustee, mortgagee). Common for additional insured notices.',
    `census_tract` STRING COMMENT 'US Census Bureau census tract code for the address. Used for demographic risk analysis, CRA compliance, and actuarial territory segmentation in pricing models.',
    `city` STRING COMMENT 'City or municipality name of the address. Used for territory rating, catastrophe aggregation, and regulatory jurisdiction determination.',
    `coastal_indicator` BOOLEAN COMMENT 'Flags whether the address is within a defined coastal zone subject to enhanced windstorm, storm surge, or tidal flood exposure. Used in underwriting eligibility screening.',
    `congressional_district` STRING COMMENT 'US Congressional district code for the address. Used for regulatory reporting, legislative tracking, and state DOI jurisdictional filings.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 three-letter country code (e.g., USA, CAN). Required for international policies, reinsurance bordereaux, and IFRS 17 reporting.. Valid values are `^[A-Z]{3}$`',
    `county` STRING COMMENT 'County or parish name for the address. Used for territory rating, surplus lines stamping, local tax jurisdiction, and catastrophe exposure aggregation.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this address record was first created in the system. Supports audit trail, data lineage, and SOX/MAR compliance for record creation tracking.',
    `distance_to_coast_miles` DECIMAL(7,2) COMMENT 'Straight-line distance in miles from the address to the nearest coastline. Used in windstorm rating, coastal surcharge calculation, and catastrophe model inputs.',
    `distance_to_fire_station_miles` DECIMAL(7,2) COMMENT 'Distance in miles from the address to the nearest responding fire station. Used in ISO PPC determination and property rating for rural or semi-rural locations.',
    `do_not_mail_indicator` BOOLEAN COMMENT 'Suppresses physical mail delivery to this address per party preference or returned mail. Compliance with GLBA and state DOI notice delivery requirements.',
    `dpv_confirmation_code` STRING COMMENT 'USPS DPV result: Y=confirmed deliverable, S=primary match only, D=default match, N=not confirmed. Validates address deliverability for policy documents and billing.. Valid values are `Y|S|D|N`',
    `effective_date` DATE COMMENT 'Date from which this address record is valid for the party. Supports point-in-time reconstruction of the address in force at policy inception or loss date.',
    `expiration_date` DATE COMMENT 'Date on which this address record ceases to be valid. Null indicates currently active. Enables historical address reconstruction for claims and regulatory audits.',
    `fips_code` STRING COMMENT 'Five-digit FIPS county code (2-digit state + 3-digit county). Used for catastrophe modeling, PML aggregation, and regulatory geographic reporting.. Valid values are `^[0-9]{5}$`',
    `fire_protection_class` STRING COMMENT 'ISO Public Protection Classification (PPC) code (1-10) for the address. Directly impacts property insurance rating; class 1 is best, 10 is unprotected.',
    `geocode_quality` STRING COMMENT 'Precision level of the geocoded coordinates. Rooftop is highest precision; zip_centroid is lowest. Drives confidence weighting in catastrophe PML and AAL models.',
    `geocode_source` STRING COMMENT 'Name of the geocoding service or vendor that produced the latitude/longitude (e.g., Google Maps API, HERE, TomTom, ESRI). Supports data lineage and quality audits.',
    `iso_territory_code` STRING COMMENT 'ISO-assigned rating territory code for this address. Used by the rating engine to apply territory-specific loss costs and rate factors per ISO circulars.',
    `latitude` DECIMAL(9,6) COMMENT 'Geographic latitude coordinate in decimal degrees (WGS84). Enables precise catastrophe hazard scoring, PML modeling, and territory assignment for insured locations.',
    `line1` STRING COMMENT 'Primary street address line including house/building number and street name. Used for mail delivery, risk location identification, and regulatory filings.',
    `line2` STRING COMMENT 'Secondary address line for suite, apartment, unit, floor, or building designator. Supplements address_line1 for complete delivery address.',
    `longitude` DECIMAL(9,6) COMMENT 'Geographic longitude coordinate in decimal degrees (WGS84). Paired with latitude for precise catastrophe hazard scoring and exposure aggregation.',
    `po_box` STRING COMMENT 'Post Office box number when the mailing address is a PO Box rather than a street address. Used for billing and correspondence when party does not receive street delivery.',
    `postal_code` STRING COMMENT 'Non-US postal code for international addresses (e.g., Canadian postal code, UK postcode). Distinct from zip_code which is US-specific. Used for international risk rating.',
    `primary_indicator` BOOLEAN COMMENT 'Flags this as the primary address for the party when multiple addresses of the same type exist. Exactly one address per party per type should be primary at any time.',
    `province` STRING COMMENT 'Province or region name for non-US addresses (e.g., Canadian provinces, Mexican states). Required for international policies and IFRS 17 geographic segmentation.',
    `seasonal_indicator` BOOLEAN COMMENT 'Indicates the address is a seasonal or secondary residence (e.g., vacation home). Relevant for homeowners underwriting, vacancy conditions, and occupancy rating.',
    `source_system_address_code` STRING COMMENT 'Native address identifier from the originating operational system (e.g., Guidewire internal ID). Enables reconciliation between the lakehouse and the system of record.',
    `state_code` STRING COMMENT 'Two-letter US state or territory code (USPS abbreviation). Drives regulatory jurisdiction, rate filings, DOI compliance, and statutory reporting by state.. Valid values are `^[A-Z]{2}$`',
    `time_zone` STRING COMMENT 'IANA time zone identifier for the address location (e.g., America/New_York). Used for loss date/time determination, FNOL timestamping, and notice deadline calculations.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this address record. Used for change data capture, MDM deduplication refresh, and audit trail in the party data domain.',
    `usps_standardized_indicator` BOOLEAN COMMENT 'Indicates whether the address has been validated and standardized against the USPS Coding Accuracy Support System (CASS). Ensures deliverability and geocoding accuracy.',
    `wind_pool_indicator` BOOLEAN COMMENT 'Indicates whether this address falls within a state wind pool or FAIR plan territory (e.g., Texas Windstorm, Florida Citizens). Affects coverage eligibility and reinsurance.',
    `zip_code` STRING COMMENT 'Five-digit US ZIP code for the address. Used for territory rating, catastrophe zone assignment, and USPS mail delivery routing.. Valid values are `^[0-9]{5}$`',
    `zip_plus4` STRING COMMENT 'Four-digit ZIP+4 extension providing carrier route precision for USPS delivery. Enhances geocoding accuracy for catastrophe modeling and territory rating.. Valid values are `^[0-9]{4}$`',
    CONSTRAINT pk_address PRIMARY KEY(`address_id`)
) COMMENT 'Physical and mailing addresses for a party. One row per address per party. Stores address type (mailing, risk, billing), street, city, state, ZIP+4, county, country, geocode, and effective dates.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` (
    `contact_id` BIGINT COMMENT 'Unique surrogate identifier for each contact point record in the party contact master. One row per contact point per party.',
    `party_id` BIGINT COMMENT 'Reference to the Party record that owns this contact point. Links contact to the party master for identity resolution and KYC.',
    `acord_contact_type_code` STRING COMMENT 'ACORD standard contact type code from the ACORD data dictionary (e.g., ACORD 125/126 PhoneInfo/EmailInfo type codes). Enables interoperability with trading partners.',
    `best_contact_time_end` STRING COMMENT 'Latest time of day (HH:MM, 24-hour local) the party prefers to be contacted via this channel. Supports TCPA-compliant outbound call scheduling.. Valid values are `^([01]d|2[0-3]):[0-5]d$`',
    `best_contact_time_start` STRING COMMENT 'Earliest time of day (HH:MM, 24-hour local) the party prefers to be contacted via this channel. Supports TCPA-compliant outbound call scheduling.. Valid values are `^([01]d|2[0-3]):[0-5]d$`',
    `consent_source` STRING COMMENT 'Channel or mechanism through which opt-in consent was captured (e.g., web_form, agent_recorded, ivr, written). Supports GLBA and TCPA audit trail requirements.. Valid values are `web_form|agent_recorded|ivr|written|email_reply|other`',
    `contact_status` STRING COMMENT 'Current lifecycle status of this contact point. Bounced indicates delivery failure; opted_out reflects GLBA/TCPA suppression. Drives communication eligibility.. Valid values are `active|inactive|unverified|bounced|opted_out`',
    `contact_type` STRING COMMENT 'Classification of the communication channel for this contact point (e.g., phone, email, fax, sms, postal_address, web_portal). Drives routing in PAS and CMS.. Valid values are `phone|email|fax|sms|postal_address|web_portal`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code associated with this contact point. Used for international dialing prefix resolution and regulatory jurisdiction mapping.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this contact point record was first created in the system. Supports audit trail, GLBA data retention, and MDM lineage requirements.',
    `do_not_contact_flag` BOOLEAN COMMENT 'Hard suppression flag indicating the party must not be contacted via this channel regardless of opt-in status. Overrides all outbound communication triggers.',
    `do_not_contact_reason` STRING COMMENT 'Reason code explaining why the do_not_contact_flag is set. Supports legal hold, regulatory order, and SIU fraud investigation suppression scenarios.. Valid values are `legal_hold|regulatory_order|party_request|deceased|fraud_flag|other`',
    `effective_date` DATE COMMENT 'Date from which this contact point is considered active and valid for the party. Supports point-in-time reconstruction of contact data for policy and claims history.',
    `email_address` STRING COMMENT 'Structured email address for the party when contact_type is email. Stored separately for validation, opt-in tracking, and GLBA compliance.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `email_bounce_code` STRING COMMENT 'SMTP bounce code or classification (e.g., 550 hard bounce, 421 soft bounce) returned when an email delivery attempt failed. Used to update contact_status to bounced.',
    `expiration_date` DATE COMMENT 'Date on which this contact point ceases to be valid. Null indicates the contact point is currently active. Enables temporal querying of contact history.',
    `is_preferred` BOOLEAN COMMENT 'Indicates whether this is the partys overall preferred contact method across all contact types. Used by PAS and CMS to select the default outreach channel.',
    `is_primary` BOOLEAN COMMENT 'Indicates whether this contact point is the primary contact for the party within its contact_type. Only one record per party per contact_type should be primary.',
    `is_verified_mobile` BOOLEAN COMMENT 'Indicates whether a phone contact point has been confirmed as a mobile/wireless number via carrier lookup. Critical for TCPA autodialer and text message compliance.',
    `is_wireless` BOOLEAN COMMENT 'Indicates whether the phone number is a wireless (cell) number as determined by carrier lookup. Distinct from is_verified_mobile; set by automated number type detection.',
    `language_preference` STRING COMMENT 'Preferred language for communications via this contact point in BCP 47 format (e.g., en-US, es-MX). Supports state DOI language access requirements.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `last_contact_date` DATE COMMENT 'Most recent date on which a successful outbound or inbound communication was recorded via this contact point. Used for contact recency analytics and dormancy detection.',
    `last_contact_outcome` STRING COMMENT 'Result of the most recent communication attempt via this contact point (e.g., reached, no_answer, voicemail, bounced). Informs next-best-action in claims and billing.. Valid values are `reached|no_answer|voicemail|bounced|refused|other`',
    `notes` STRING COMMENT 'Free-text notes recorded by an agent or adjuster about this contact point (e.g., call-back instructions, seasonal address). Stored in PAS and CMS contact objects.',
    `opt_in_flag` BOOLEAN COMMENT 'Indicates whether the party has affirmatively opted in to receive communications via this contact point. Required for GLBA and TCPA compliance tracking.',
    `opt_in_timestamp` TIMESTAMP COMMENT 'Date and time when the party provided opt-in consent for this contact point. Retained as evidence of consent for GLBA and TCPA regulatory audits.',
    `opt_out_flag` BOOLEAN COMMENT 'Indicates whether the party has explicitly opted out of communications via this contact point. Suppresses outbound contact in PAS, CMS, and Billing systems.',
    `opt_out_timestamp` TIMESTAMP COMMENT 'Date and time when the party revoked consent or opted out for this contact point. Triggers suppression in all downstream communication systems.',
    `phone_extension` STRING COMMENT 'Optional telephone extension appended to the phone number for commercial parties, brokers, or agency contacts in the Producer Management System.. Valid values are `^d{1,10}$`',
    `phone_number` STRING COMMENT 'Structured phone number in E.164 format for the party when contact_type is phone or sms. Used for FNOL intake, billing, and claims communication.. Valid values are `^+?[1-9]d{1,14}$`',
    `source_system_contact_code` STRING COMMENT 'Native identifier of this contact record in the originating operational system (e.g., Guidewire ContactID). Enables cross-system reconciliation and MDM deduplication.',
    `subtype` STRING COMMENT 'Secondary classification refining the contact type (e.g., home, work, mobile, billing, claims, underwriting). [ENUM-REF-CANDIDATE: home|work|mobile|billing|claims|underwriting|other — promote to reference product]',
    `time_zone` STRING COMMENT 'IANA time zone identifier for this contact point (e.g., America/New_York). Used to schedule compliant outbound calls within TCPA permitted calling hours.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this contact point record. Used for change data capture, MDM synchronization, and audit trail compliance.',
    `usage_purpose` STRING COMMENT 'Business purpose for which this contact point is used (e.g., billing notices, claims FNOL, policy documents, marketing). Drives targeted communication routing.',
    `value` STRING COMMENT 'The actual contact point value: phone number, email address, fax number, SMS number, or postal address string depending on contact_type. Contains PII.',
    `verification_date` DATE COMMENT 'Date on which the contact point was last verified through a validation process such as email ping, carrier lookup, or agent confirmation.',
    `verification_method` STRING COMMENT 'Method used to verify this contact point (e.g., carrier_lookup for phone, email_ping for email, agent_confirmed for manual review). Supports MDM data quality.. Valid values are `carrier_lookup|email_ping|agent_confirmed|document|ivr|other`',
    `verification_status` STRING COMMENT 'Indicates whether this contact point has been validated (e.g., email deliverability check, phone number validation via carrier lookup). Used in KYC and MDM.. Valid values are `verified|unverified|failed|pending`',
    CONSTRAINT pk_contact PRIMARY KEY(`contact_id`)
) COMMENT 'Communication contact points for a party: phone, email, fax, and preferred contact method. One row per contact point per party. Tracks opt-in/opt-out flags, contact type, and effective dates for GLBA compliance.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` (
    `identifier_id` BIGINT COMMENT 'Surrogate primary key uniquely identifying one party identifier record. One row per identifier per party. Grain: one row per external or internal identifier assigned to a party.',
    `identifier_mdm_golden_party_id` BIGINT COMMENT 'The MDM golden record identifier assigned to the party after deduplication and survivorship processing. Links this identifier to the authoritative master party record across all source systems.',
    `identifier_party_id` BIGINT COMMENT 'Reference to the party record that owns this identifier. Links the identifier back to the master party in the Customer/Party MDM.',
    `identifier_pas_party_id` BIGINT COMMENT 'The party identifier as assigned by the Policy Administration System (Guidewire PolicyCenter or Duck Creek Policy). Used for cross-reference between the data lakehouse and the PAS.',
    `clue_report_ordered` BOOLEAN COMMENT 'Indicates whether a CLUE (Comprehensive Loss Underwriting Exchange) report has been ordered for this party identifier. Used in personal lines underwriting to retrieve prior loss history.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this identifier record was first created in the data platform. Supports audit trail, data lineage, and SOX compliance. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `dedup_match_key` STRING COMMENT 'Normalized, standardized form of the identifier value used for fuzzy matching and deduplication in the Party MDM. Strips formatting characters (dashes, spaces) for consistent comparison.',
    `effective_date` DATE COMMENT 'Date on which this identifier became valid and effective. Used for temporal queries to determine which identifier was active at a given point in time.',
    `expiration_date` DATE COMMENT 'Date on which this identifier expires or ceases to be valid. Null for identifiers with no expiry (e.g., SSN, FEIN). Used for license renewal tracking and compliance monitoring.',
    `fraud_indicator` BOOLEAN COMMENT 'Flag set by the Fraud Detection/SIU system indicating this identifier has been associated with suspected or confirmed fraudulent activity. Triggers enhanced review in underwriting and claims.',
    `identifier_status` STRING COMMENT 'Current lifecycle status of this identifier record: active (in use), inactive (superseded), expired (past validity), revoked (cancelled by issuing authority), pending_verification (awaiting confirmation).. Valid values are `active|inactive|expired|revoked|pending_verification`',
    `is_masked` BOOLEAN COMMENT 'Indicates whether the identifier_value stored is a masked or tokenized representation rather than the full plaintext value. True when only last-4 digits or a token is stored for PCI/GLBA compliance.',
    `is_primary` BOOLEAN COMMENT 'Indicates whether this is the primary identifier for the party within its identifier type. True if this is the preferred or golden record identifier used for cross-system matching and deduplication.',
    `issuing_authority` STRING COMMENT 'Name of the government agency, regulatory body, or internal system that issued this identifier (e.g., IRS, SSA, NIPR, state DMV, state DOI, NAIC, internal MDM system).',
    `issuing_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the country that issued this identifier (e.g., USA, CAN, GBR). Required for passports and foreign national identifiers.. Valid values are `^[A-Z]{3}$`',
    `issuing_state_code` STRING COMMENT 'Two-letter US state or territory code of the jurisdiction that issued this identifier. Applicable for driver licenses, state-issued producer licenses, and state DOI registrations.. Valid values are `^[A-Z]{2}$`',
    `kyc_status` STRING COMMENT 'Know Your Customer compliance status for this identifier as part of anti-money laundering and fraud screening. Tracks whether the identifier has passed identity verification per GLBA and BSA/AML requirements.. Valid values are `passed|failed|pending|not_required|escalated`',
    `license_class` STRING COMMENT 'Classification of the license associated with this identifier (e.g., producer license class: P&C, Life, Health; driver license class: A, B, C, M). Applicable for DLN and producer license identifier types.',
    `license_number` STRING COMMENT 'State-issued insurance producer license number or driver license number depending on identifier_type_code. For DLN type, used in MVR ordering and auto underwriting. For producer, used in DOI compliance.',
    `license_state_code` STRING COMMENT 'Two-letter US state code of the jurisdiction under which the license was issued. Distinct from issuing_state_code when a producer holds licenses in multiple states.. Valid values are `^[A-Z]{2}$`',
    `masked_value` DECIMAL(18,2) COMMENT 'Partially masked display version of the identifier for UI and reporting use (e.g., ***-**-1234 for SSN, **-***1234 for FEIN). Allows display without exposing the full sensitive value.',
    `mvr_order_date` DATE COMMENT 'Date on which the most recent MVR was ordered for this driver license identifier. Used to determine MVR currency and whether a refresh is required per underwriting guidelines.',
    `mvr_ordered` BOOLEAN COMMENT 'Indicates whether a Motor Vehicle Record (MVR) has been ordered for this driver license identifier. Applicable when identifier_type_code = DLN. Used in personal and commercial auto underwriting.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code assigned to an insurance carrier or reinsurer. Populated when identifier_type_code = NAIC_CODE. Used in statutory reporting and Schedule F/P filings.. Valid values are `^[0-9]{5}$`',
    `notes` STRING COMMENT 'Free-text notes or comments recorded by underwriters, compliance officers, or MDM stewards regarding this identifier (e.g., reason for revocation, manual override justification, discrepancy notes).',
    `npn` STRING COMMENT 'NIPR-assigned National Producer Number for licensed insurance producers and agencies. Populated when identifier_type_code = NPN. Required for producer appointment and commission processing.. Valid values are `^[0-9]{1,10}$`',
    `ofac_check_status` STRING COMMENT 'Result of OFAC SDN (Specially Designated Nationals) screening for this identifier. Required for sanctions compliance. Cleared = no match; Flagged = potential match requiring review.. Valid values are `cleared|flagged|pending|not_checked`',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record that originated this identifier record (e.g., PAS for PolicyCenter, MDM for party master, PRODUCER_MGMT for agency system, FRAUD_SIU for SIU system).',
    `source_system_party_ref` STRING COMMENT 'The party or entity reference key as it exists in the originating source system. Enables cross-system reconciliation and deduplication between PAS, MDM, billing, and claims systems.',
    `tin_match_status` STRING COMMENT 'Result of IRS TIN matching for SSN/FEIN identifiers. Used for 1099 reporting compliance and backup withholding determination. Values: matched, not_matched, pending, not_checked.. Valid values are `matched|not_matched|pending|not_checked`',
    `tin_type` STRING COMMENT 'Specifies the type of IRS Taxpayer Identification Number: SSN (Social Security Number), FEIN (Federal Employer Identification Number), ITIN (Individual Taxpayer Identification Number), or EIN (Employer Identification Number).. Valid values are `SSN|FEIN|ITIN|EIN`',
    `type_code` STRING COMMENT 'Classifies the kind of identifier: SSN (Social Security Number), FEIN (Federal Employer Identification Number), NPN (National Producer Number), NAIC Code, DLN (Driver License Number), PASSPORT, PAS_PARTY_ID, MDM_GOLDEN_ID.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this identifier record was last modified. Used for change data capture, incremental ETL processing, and audit trail maintenance per SOX and GLBA requirements.',
    `value` STRING COMMENT 'The actual identifier string (e.g., SSN digits, FEIN digits, NPN number, driver license number, passport number, PAS party ID, MDM golden record ID). Stored encrypted at rest per GLBA and GDPR/CCPA.',
    `verification_date` DATE COMMENT 'Date on which the identifier was last verified against the issuing authority or third-party source. Supports compliance audit trails and re-verification scheduling.',
    `verification_source` STRING COMMENT 'Name of the system or service used to verify this identifier (e.g., NIPR, IRS TIN Match, SSA, LexisNexis, Equifax, state DMV MVR, CLUE). Supports audit and compliance documentation.',
    `verification_status` STRING COMMENT 'Indicates whether this identifier has been validated against the issuing authority or a third-party verification service (e.g., NIPR NPN check, IRS TIN match, SSA SSN verification, CLUE, MVR).. Valid values are `verified|unverified|failed|not_required`',
    CONSTRAINT pk_identifier PRIMARY KEY(`identifier_id`)
) COMMENT 'External and internal identifiers assigned to a party: SSN, FEIN, NPN, NAIC code, driver license, passport, PAS party ID, MDM golden ID. One row per identifier per party. Supports deduplication and cross-system matching.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` (
    `relationship_id` BIGINT COMMENT 'Unique surrogate identifier for a directed party-to-party relationship record. One row per relationship instance in the Party MDM.',
    `from_party_id` BIGINT COMMENT 'Surrogate key of the originating (subject) party in the directed relationship, e.g., the policyholder or parent organization.',
    `party_group_id` BIGINT COMMENT 'Identifier for a commercial group or affiliated enterprise to which both parties belong. Supports group policy pricing, NAIC group reporting, and affiliated transaction rules.',
    `household_id` BIGINT COMMENT 'Identifier linking parties that belong to the same household unit. Used for multi-policy household bundling, cross-sell analytics, and personal lines rating.',
    `to_party_id` BIGINT COMMENT 'Surrogate key of the target (object) party in the directed relationship, e.g., the additional insured or subsidiary organization.',
    `relationship_category` STRING COMMENT 'Broad grouping of the relationship type: Personal (family/household), Commercial (business hierarchy), Legal (trust/guardianship), or Financial (guarantor/beneficiary).. Valid values are `PERSONAL|COMMERCIAL|LEGAL|FINANCIAL`',
    `control_flag` BOOLEAN COMMENT 'Indicates whether the from-party exercises a controlling interest over the to-party for regulatory group reporting and affiliated transaction disclosures.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this relationship record was first created in the data platform. Supports audit trail, data lineage, and SOX compliance.',
    `effective_date` DATE COMMENT 'Calendar date on which the relationship became or becomes legally and operationally effective. Used for point-in-time reconstruction of party relationships.',
    `expiration_date` DATE COMMENT 'Calendar date on which the relationship ceases to be effective. Null indicates an open-ended relationship with no scheduled end date.',
    `fraud_indicator_flag` BOOLEAN COMMENT 'Flag set by the SIU or fraud detection system indicating this relationship has been flagged for potential fraud, e.g., staged household relationships to obtain discounts.',
    `is_bidirectional` BOOLEAN COMMENT 'Indicates whether the relationship is symmetric (True) or strictly directed (False). Symmetric relationships such as spouse do not require a reciprocal row.',
    `is_primary` BOOLEAN COMMENT 'Indicates whether the from-party is the primary party in this relationship type (e.g., primary named insured vs. additional insured). True = primary.',
    `jurisdiction_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction governing the relationship. Supports international and surplus lines business.. Valid values are `^[A-Z]{3}$`',
    `jurisdiction_state_code` STRING COMMENT 'Two-letter US state code of the jurisdiction governing the relationship. Drives state-specific underwriting rules, regulatory filings, and DOI compliance.. Valid values are `^[A-Z]{2}$`',
    `legal_basis_code` STRING COMMENT 'Legal instrument or authority establishing the relationship, e.g., MARRIAGE certificate, COURT_ORDER, CORPORATE_FILING. Required for KYC and regulatory compliance.. Valid values are `MARRIAGE|ADOPTION|CONTRACT|COURT_ORDER|STATUTE|CORPORATE_FILING`',
    `legal_basis_date` DATE COMMENT 'Date the legal instrument establishing the relationship was executed or issued, e.g., date of marriage, date of court order, date of corporate filing.',
    `legal_basis_reference` STRING COMMENT 'Document reference number or identifier for the legal instrument establishing the relationship, e.g., marriage certificate number, court order docket number.',
    `notes` STRING COMMENT 'Free-text field for underwriter or compliance officer annotations about the relationship, such as special circumstances, exceptions, or documentation notes.',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage of ownership or controlling interest held by the from-party over the to-party. Applicable for parent-subsidiary and investor relationships. Range 0.00–100.00.',
    `relationship_status` STRING COMMENT 'Current lifecycle state of the relationship record. ACTIVE means the relationship is in force; TERMINATED means it has ended; PENDING means awaiting verification.. Valid values are `ACTIVE|INACTIVE|PENDING|TERMINATED`',
    `role_from` STRING COMMENT 'The specific role the from-party plays within this relationship instance, e.g., POLICYHOLDER, PARENT, EMPLOYER. Complements relationship_type_code for granular role tracking.. Valid values are `POLICYHOLDER|NAMED_INSURED|PARENT|EMPLOYER|GUARANTOR|PRODUCER`',
    `role_to` STRING COMMENT 'The specific role the to-party plays within this relationship instance, e.g., ADDITIONAL_INSURED, SUBSIDIARY, EMPLOYEE. Enables multi-role party resolution.. Valid values are `ADDITIONAL_INSURED|NAMED_INSURED|SUBSIDIARY|EMPLOYEE|BENEFICIARY|SUB_PRODUCER`',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record that originated this relationship record, e.g., MDM (Party MDM), PAS (PolicyCenter), CLAIMS (ClaimCenter).. Valid values are `MDM|PAS|CLAIMS|BILLING|PRODUCER_MGMT`',
    `source_system_relationship_code` STRING COMMENT 'Native identifier of this relationship record in the originating source system. Enables lineage tracing and reconciliation back to Guidewire PolicyCenter or Duck Creek.',
    `termination_date` DATE COMMENT 'Actual date the relationship was terminated or dissolved, which may differ from the scheduled expiration date (e.g., divorce decree date, corporate dissolution date).',
    `termination_reason_code` STRING COMMENT 'Coded reason explaining why the relationship was terminated. Supports audit, compliance, and underwriting eligibility re-evaluation.. Valid values are `DIVORCE|DISSOLUTION|DECEASED|POLICY_CANCEL|MUTUAL_AGREEMENT|OTHER`',
    `type_code` STRING COMMENT 'Classifies the nature of the directed relationship between two parties. Drives underwriting, coverage eligibility, and KYC rules. [ENUM-REF-CANDIDATE: promote to reference product for full list]. Valid values are `SPOUSE|PARENT_SUBSIDIARY|EMPLOYER_EMPLOYEE|NAMED_INSURED_ADDITIONAL|GUARANTOR_BENEFICIARY|OTHER`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this relationship record was last modified in the data platform. Used for change data capture and incremental processing in the Databricks Silver layer.',
    `uw_impact_flag` BOOLEAN COMMENT 'Indicates whether this relationship has a material impact on underwriting eligibility or rating, e.g., a parent-subsidiary relationship affecting group pricing or a household relationship affecting multi-car discount.',
    `verification_date` DATE COMMENT 'Date on which the relationship was last verified by the KYC/compliance process. Null if never verified.',
    `verification_status` STRING COMMENT 'KYC/AML verification status of the relationship. VERIFIED means supporting documentation has been reviewed and accepted by the underwriting or compliance team.. Valid values are `UNVERIFIED|PENDING|VERIFIED|REJECTED`',
    `verified_by` STRING COMMENT 'Name or user identifier of the compliance officer or underwriter who verified the relationship. Supports audit trail and SOX controls.',
    CONSTRAINT pk_relationship PRIMARY KEY(`relationship_id`)
) COMMENT 'Directed relationship between two parties: spouse, parent-subsidiary, named insured to additional insured, employer-employee. One row per relationship. Carries relationship type, effective dates, and primary-party flag.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` (
    `kyc_verification_id` BIGINT COMMENT 'Unique surrogate identifier for each KYC verification record. One row per KYC check performed on a party. Grain: one row per KYC verification event per party.',
    `claim_id` BIGINT COMMENT 'Reference to the claim that triggered this KYC verification, when applicable (e.g., FNOL claimant screening or SIU referral). Null for verifications not associated with a specific claim.',
    `jurisdiction_geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: KYC regulatory compliance reporting requires tracking verification jurisdiction by state/country geography.',
    `kyc_analyst_party_id` BIGINT COMMENT 'Identifier of the compliance analyst or underwriter who performed or reviewed this KYC verification. Required for manual review cases and audit accountability. Links to the Party or User record.',
    `kyc_override_approver_party_id` BIGINT COMMENT 'Identifier of the senior compliance officer or manager who approved the override of a KYC verification result. Populated only when override_reason is present. Supports SOX audit controls.',
    `kyc_party_id` BIGINT COMMENT 'Reference to the party (person or organization) subject to this KYC verification. Links to the Party master record in the Party domain.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to coverage.submission. Business justification: KYC/OFAC screening performed during underwriting (pre-bind) requires linkage to submission for regulatory audit trail, SIU referral tracking, and compliance with AML requirements at',
    `adverse_media_summary` STRING COMMENT 'Brief narrative summary of adverse media findings when is_adverse_media is true. Captures the nature of the negative news (e.g., fraud allegation, regulatory sanction) for analyst review and documentation.',
    `analyst_decision` STRING COMMENT 'Final decision made by the compliance analyst after reviewing the KYC verification results. APPROVE=cleared to proceed; REJECT=relationship declined; ESCALATE=referred to senior compliance; DEFER=pending additional info.. Valid values are `APPROVE|REJECT|ESCALATE|DEFER`',
    `analyst_notes` STRING COMMENT 'Free-text notes entered by the compliance analyst documenting the rationale for the decision, exceptions granted, or additional context observed during the KYC review process.',
    `beneficial_owner_count` BIGINT COMMENT 'Number of beneficial owners identified and verified for a legal entity party. Per FinCEN CDD Rule, includes all natural persons owning 25% or more equity interest plus one control person.',
    `beneficial_owner_verified` BOOLEAN COMMENT 'Indicates whether the beneficial ownership of the party (for legal entities) has been verified per FinCEN CDD Rule requirements. Mandatory for legal entity customers with 25%+ ownership threshold.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this KYC verification record was first created in the system. Provides the audit trail creation marker required for SOX and regulatory compliance reporting.',
    `data_source_code` STRING COMMENT 'Code identifying the originating system or data source for this KYC verification record (e.g., MDM_KYC, PAS_UW, CLAIMS_FNOL). Supports data lineage and source-system reconciliation in the lakehouse.',
    `due_diligence_level` STRING COMMENT 'Level of due diligence applied for this KYC verification. SIMPLIFIED=low-risk customers; STANDARD=normal CDD; ENHANCED=high-risk, PEP, or OFAC-adjacent parties. Aligns with FinCEN CDD Rule tiers.. Valid values are `SIMPLIFIED|STANDARD|ENHANCED`',
    `escalation_reason` STRING COMMENT 'Narrative reason for escalating this KYC case to senior compliance or a Suspicious Activity Report (SAR) filing. Populated when analyst_decision is ESCALATE. Supports AML investigation workflow.',
    `expiration_date` DATE COMMENT 'Date on which this KYC verification result expires and a refresh is required. Drives periodic review scheduling. Null if the verification has no defined expiry per risk tier.',
    `identity_document_expiry_date` DATE COMMENT 'Expiration date of the identity document used during verification. An expired document may invalidate the KYC result and trigger a re-verification requirement.',
    `identity_document_issuing_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the authority that issued the identity document used in verification. Used for sanctions screening and cross-border risk assessment.. Valid values are `^[A-Z]{3}$`',
    `identity_document_number` STRING COMMENT 'The document number from the identity document used for verification (e.g., passport number, driver license number, FEIN). Stored as restricted PII per GLBA and FCRA requirements.',
    `identity_document_type` STRING COMMENT 'Type of identity document presented or verified during the KYC check. PASSPORT, DRIVERS_LICENSE, NATIONAL_ID, STATE_ID, MILITARY_ID for individuals; FEIN (Federal Employer Identification Number) for organizations.. Valid values are `PASSPORT|DRIVERS_LICENSE|NATIONAL_ID|STATE_ID|MILITARY_ID|FEIN`',
    `is_adverse_media` BOOLEAN COMMENT 'Indicates whether adverse media (negative news coverage related to financial crime, fraud, sanctions, or regulatory action) was found for this party during the KYC screening process.',
    `is_pep` BOOLEAN COMMENT 'Indicates whether the party has been identified as a Politically Exposed Person (PEP) — a current or former senior government official or close associate. Triggers enhanced due diligence requirements.',
    `next_review_date` DATE COMMENT 'Date on which the next periodic KYC review is scheduled for this party, based on risk tier and due diligence level. Drives compliance workflow queues and regulatory review cycle management.',
    `ofac_hit_reference` STRING COMMENT 'OFAC SDN list entry reference number or identifier when a hit or potential hit is recorded. Populated only when ofac_screening_status is HIT or POTENTIAL_HIT. Used for regulatory escalation.',
    `ofac_screening_status` STRING COMMENT 'Result of screening the party against the OFAC Specially Designated Nationals (SDN) and blocked persons list. CLEAR=no match; HIT=confirmed match; POTENTIAL_HIT=possible match requiring review.. Valid values are `CLEAR|HIT|POTENTIAL_HIT|NOT_SCREENED`',
    `override_reason` STRING COMMENT 'Documented reason when a KYC verification result is overridden by a compliance officer (e.g., false positive OFAC hit, known PEP with approved exception). Required for audit trail when verification_status is WAIVED.',
    `pep_category` STRING COMMENT 'Classification of the PEP relationship when is_pep is true. DOMESTIC=domestic official; FOREIGN=foreign official; INTERNATIONAL_ORGANIZATION=IO official; CLOSE_ASSOCIATE=known associate; FAMILY_MEMBER=immediate family.. Valid values are `DOMESTIC|FOREIGN|INTERNATIONAL_ORGANIZATION|CLOSE_ASSOCIATE|FAMILY_MEMBER`',
    `review_date` DATE COMMENT 'Date on which the compliance analyst completed their manual review and recorded the analyst_decision. Distinct from verification_date which is when the automated check ran.',
    `risk_tier` STRING COMMENT 'Customer risk classification assigned as a result of the KYC process. Determines due diligence level, review frequency, and monitoring intensity. Aligns with FATF risk-based approach.. Valid values are `LOW|MEDIUM|HIGH|VERY_HIGH`',
    `sar_filed` BOOLEAN COMMENT 'Indicates whether a Suspicious Activity Report (SAR) was filed with FinCEN as a result of this KYC verification finding. Triggers restricted access controls on the record per BSA requirements.',
    `sar_reference_number` STRING COMMENT 'FinCEN-assigned reference number for the Suspicious Activity Report filed in connection with this KYC verification. Populated only when sar_filed is true. Strictly access-controlled.',
    `siu_case_number` STRING COMMENT 'Case reference number assigned by the SIU system when this KYC verification triggered a fraud investigation referral. Populated only when siu_referral is true.',
    `siu_referral` BOOLEAN COMMENT 'Indicates whether this KYC verification result triggered a referral to the Special Investigations Unit (SIU) for potential insurance fraud investigation. Integrates with the Fraud Detection/SIU System.',
    `third_party_provider` STRING COMMENT 'Name of the external vendor or service used to perform the KYC verification (e.g., LexisNexis, Experian, Equifax, Refinitiv World-Check). Populated when verification_method is THIRD_PARTY_SERVICE.',
    `third_party_reference_code` STRING COMMENT 'Unique transaction or case reference number returned by the third-party KYC provider for this verification. Used for reconciliation, dispute resolution, and audit trail with the external vendor.',
    `trigger_event` STRING COMMENT 'Business event that initiated this KYC verification. NEW_BUSINESS=new policy application; RENEWAL=policy renewal; ENDORSEMENT=mid-term change; CLAIM_FNOL=first notice of loss; PERIODIC_REVIEW=scheduled refresh; RISK_CHANGE=risk profile change.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this KYC verification record. Tracks when analyst decisions, overrides, or status changes were last applied. Required for data lineage in the Silver layer.',
    `verification_date` DATE COMMENT 'Calendar date on which the KYC verification check was performed. Used for regulatory reporting, periodic review scheduling, and compliance audit trails.',
    `verification_method` STRING COMMENT 'Mechanism used to perform the verification. Examples: DOCUMENT_REVIEW=physical/digital ID doc; DATABASE_LOOKUP=internal/external data match; THIRD_PARTY_SERVICE=vendor API; BIOMETRIC=fingerprint/facial; CREDIT_BUREAU=bureau pull.. Valid values are `DOCUMENT_REVIEW|DATABASE_LOOKUP|THIRD_PARTY_SERVICE|MANUAL_REVIEW|BIOMETRIC|CREDIT_BUREAU`',
    `verification_result` STRING COMMENT 'Detailed outcome of the verification check. CLEAR=no issues found; MATCH=identity confirmed; NO_MATCH=identity not confirmed; PARTIAL_MATCH=partial data match requiring review; INCONCLUSIVE=insufficient data.. Valid values are `CLEAR|MATCH|NO_MATCH|PARTIAL_MATCH|INCONCLUSIVE`',
    `verification_status` STRING COMMENT 'Current outcome or workflow state of this KYC verification. PASS=cleared; FAIL=failed check; REVIEW=manual review required; PENDING=in progress; EXPIRED=result past validity window; WAIVED=exempted per policy.. Valid values are `PASS|FAIL|REVIEW|PENDING|EXPIRED|WAIVED`',
    `verification_timestamp` TIMESTAMP COMMENT 'Exact date and time the KYC verification was executed, including timezone offset. Provides precise audit trail for regulatory and compliance purposes beyond the calendar date.',
    `verification_type` STRING COMMENT 'Category of KYC check performed. IDENTITY=identity document check; OFAC_SCREENING=sanctions list; PEP_SCREENING=politically exposed person; ADVERSE_MEDIA=negative news; EDU=enhanced due diligence; PERIODIC_REVIEW=scheduled refresh.. Valid values are `IDENTITY|OFAC_SCREENING|PEP_SCREENING|ADVERSE_MEDIA|ENHANCED_DUE_DILIGENCE|PERIODIC_REVIEW`',
    `watchlist_hit_detail` STRING COMMENT 'Description of any watchlist match found beyond OFAC screening, including the list name and entry reference. Populated when watchlist_screened is true and a match was identified.',
    `watchlist_screened` BOOLEAN COMMENT 'Indicates whether the party was screened against applicable government and industry watchlists beyond OFAC (e.g., FBI Most Wanted, Interpol, EU Consolidated List, UN Sanctions). Supports comprehensive AML compliance.',
    CONSTRAINT pk_kyc_verification PRIMARY KEY(`kyc_verification_id`)
) COMMENT 'KYC and identity-verification record for a party. Tracks verification method, verification date, result (pass/fail/review), OFAC screening status, PEP flag, adverse-media flag, and the analyst who performed the check.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` (
    `consent_record_id` BIGINT COMMENT 'Unique surrogate identifier for each consent or opt-out event record. One row per consent event per party per consent type. Primary key of this table.',
    `consent_guardian_party_id` BIGINT COMMENT 'Reference to the Party record of the parent or legal guardian who provided consent on behalf of a minor. Null when is_minor is false or guardian consent is not required.',
    `consent_party_id` BIGINT COMMENT 'Reference to the Party who granted, withheld, or revoked consent. Links to the Party master record in the Customer/Party MDM.',
    `party_document_id` BIGINT COMMENT 'Reference identifier for the specific consent notice, privacy policy, or disclosure document presented to the party. Links to the Document & Forms Management system for audit retrieval.',
    `prior_consent_record_id` BIGINT COMMENT 'Reference to the previous consent record that this event supersedes or replaces. Enables a linked-list audit chain of consent history for a party and consent type over time.',
    `role_id` BIGINT COMMENT 'Reference to the specific Party Role (policyholder, claimant, producer, etc.) under which consent was captured, enabling role-scoped consent tracking.',
    `agent_npn` STRING COMMENT 'The National Producer Number (NPN) of the producer or agent who facilitated the consent capture on behalf of the party. Null for self-service digital channels.. Valid values are `^[0-9]{1,10}$`',
    `consent_action` STRING COMMENT 'The action taken by the party on this consent event: granted (affirmative consent), revoked (withdrawal), opted_out (negative election), renewed (re-affirmation), or pending (awaiting confirmation).. Valid values are `granted|revoked|opted_out|renewed|pending`',
    `consent_channel` STRING COMMENT 'The interface or channel through which the party provided or withdrew consent. [ENUM-REF-CANDIDATE: web|mobile_app|ivr|agent|paper|email|sms|chat|kiosk — promote to reference product if more than 6 values needed]',
    `consent_language` STRING COMMENT 'IETF BCP 47 language tag (e.g., en-US, es-MX) of the consent notice presented to the party. Supports multilingual compliance and state DOI requirements for non-English disclosures.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `consent_method` STRING COMMENT 'The mechanism by which consent was obtained: opt_in (affirmative click/signature), opt_out (negative election), double_opt_in (confirmed via follow-up), implied (by contract), or written (signed document).. Valid values are `opt_in|opt_out|double_opt_in|implied|written`',
    `consent_status` STRING COMMENT 'Current lifecycle state of this consent record. Active means the consent is in force; superseded means a newer record has replaced it; expired means the consent lapsed past its expiration date.. Valid values are `active|inactive|expired|superseded`',
    `consent_text_hash` STRING COMMENT 'SHA-256 hash of the exact consent notice text presented to the party. Provides tamper-evident proof of the specific language used, supporting regulatory audit without storing full text.. Valid values are `^[a-fA-F0-9]{64}$`',
    `consent_timestamp` TIMESTAMP COMMENT 'The precise date and time (with timezone offset) when the party performed the consent action. This is the principal real-world event time, distinct from the record audit timestamp.',
    `consent_type` STRING COMMENT 'Category of consent or opt-out captured. Examples: marketing communications, electronic policy delivery, telematics data collection, credit pull authorization, Motor Vehicle Record (MVR) pull, data sharing.. Valid values are `marketing|electronic_delivery|telematics|credit_pull|mvr_pull|data_sharing`',
    `consent_version` STRING COMMENT 'Version identifier of the consent notice, disclosure form, or privacy policy presented to the party at the time of consent. Enables tracking of which notice language was in effect.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this consent record was first written to the data store. Audit trail field distinct from consent_timestamp (the business event time). Set once and never updated.',
    `credit_pull_permissible_purpose` STRING COMMENT 'The FCRA-defined permissible purpose for which a credit report pull is authorized (e.g., underwriting, rating, renewal). Required for FCRA compliance when consent_type is credit_pull.. Valid values are `underwriting|rating|renewal|claims|collections`',
    `data_categories_covered` STRING COMMENT 'Comma-delimited list of personal data categories covered by this consent (e.g., driving behavior, credit score, location data, health data). Required for GDPR Article 13 transparency.',
    `data_use_purpose` STRING COMMENT 'Specific stated purpose for which data will be used under this consent (e.g., underwriting rating, claims processing, marketing, telematics scoring). Aligns with GDPR purpose limitation principle.',
    `device_fingerprint` STRING COMMENT 'Hashed or tokenized identifier of the device used to submit consent. Supports fraud detection and non-repudiation for digital consent events. Stored as a hash, not raw device data.',
    `do_not_contact_flag` BOOLEAN COMMENT 'Indicates the party has requested no contact for any purpose beyond contractual necessity. Distinct from suppression_flag which is channel/purpose-specific. Overrides all outreach.',
    `effective_date` DATE COMMENT 'The date from which this consent record is legally binding and operationally in force. May differ from consent_timestamp if there is a processing lag or future-dated activation.',
    `electronic_delivery_format` STRING COMMENT 'The agreed electronic format for policy document delivery when consent_type is electronic_delivery. Populated per state e-delivery statutes and NAIC Model Electronic Transactions Act.. Valid values are `pdf|html|email|portal|sms`',
    `expiration_date` DATE COMMENT 'The date on which this consent record expires and must be re-obtained. Null indicates open-ended consent with no scheduled expiry. Used for periodic re-consent workflows.',
    `ip_address` STRING COMMENT 'The IP address of the device from which the party submitted the consent action online. Used for fraud detection, audit, and jurisdictional determination. May be PII under GDPR/CCPA.',
    `is_minor` BOOLEAN COMMENT 'Indicates whether the consenting party is a minor (under 18 or applicable age of majority). Triggers parental/guardian consent requirements under COPPA, GDPR Article 8, and state regulations.',
    `jurisdiction_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction governing this consent record. Supports GDPR applicability determination for international or EU-exposed business.. Valid values are `^[A-Z]{3}$`',
    `jurisdiction_state` STRING COMMENT 'Two-letter US state code of the jurisdiction governing this consent record. Determines which state DOI regulations and privacy laws (e.g., CCPA for CA) apply to this consent event.. Valid values are `^[A-Z]{2}$`',
    `mvr_pull_state` STRING COMMENT 'Two-letter US state code of the DMV from which the Motor Vehicle Record (MVR) pull is authorized. Populated only when consent_type is mvr_pull. Drives state-specific MVR ordering.. Valid values are `^[A-Z]{2}$`',
    `notes` STRING COMMENT 'Free-text notes entered by the capturing agent, compliance officer, or system regarding special circumstances of this consent event (e.g., verbal consent noted, exception approved).',
    `opt_out_reason` STRING COMMENT 'Free-text or coded reason provided by the party when revoking consent or opting out. Supports customer experience analysis and regulatory response documentation.',
    `policy_number` STRING COMMENT 'The externally-known policy number associated with this consent event, when consent is captured in the context of a specific policy (e.g., telematics enrollment, electronic delivery election at bind).',
    `proof_of_consent_ref` STRING COMMENT 'Reference to the stored evidence of consent (e.g., signed form scan ID, recorded call ID, e-signature token, screenshot hash). Supports regulatory audit and non-repudiation.',
    `regulatory_basis` STRING COMMENT 'The primary legal or regulatory framework under which this consent was obtained or is required. Drives compliance reporting and data handling obligations. Examples: GLBA, CCPA, GDPR, FCRA, TCPA.. Valid values are `GLBA|CCPA|GDPR|FCRA|TCPA|state_doi`',
    `revocation_timestamp` TIMESTAMP COMMENT 'The precise date and time when the party revoked or withdrew consent. Null if consent has not been revoked. Supports GDPR right-to-withdraw and CCPA opt-out audit trails.',
    `source_transaction_code` STRING COMMENT 'The unique transaction or session identifier from the originating source system at the time consent was captured. Enables cross-system audit trail reconciliation.',
    `suppression_flag` BOOLEAN COMMENT 'Indicates whether this party is suppressed from the associated data use (e.g., marketing suppression list, do-not-call registry). Drives downstream campaign and outreach exclusion logic.',
    `telematics_program_code` STRING COMMENT 'Identifier of the telematics or usage-based insurance (UBI) program for which consent was obtained. Populated only when consent_type is telematics. Links to the telematics program configuration.',
    `third_party_sharing_flag` BOOLEAN COMMENT 'Indicates whether this consent authorizes sharing of the partys data with third parties (e.g., reinsurers, data vendors, ISO/CLUE). Drives GLBA opt-out and CCPA sale-of-data controls.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this consent record was last modified in the data store (e.g., status updated to superseded or expired). Supports audit trail and change data capture.',
    `verification_timestamp` TIMESTAMP COMMENT 'The date and time when the consent event was independently verified (e.g., double opt-in confirmation received). Null if verified_flag is false or verification is not required.',
    `verified_flag` BOOLEAN COMMENT 'Indicates whether the consent event has been independently verified (e.g., double opt-in email confirmation received, recorded call reviewed). Supports quality assurance and regulatory defensibility.',
    CONSTRAINT pk_consent_record PRIMARY KEY(`consent_record_id`)
) COMMENT 'Captures explicit consent or opt-out events for a party: marketing, electronic delivery, telematics, credit pull, MVR pull. One row per consent event. Stores consent type, channel, timestamp, and regulatory basis (GLBA/CCPA/GDPR).';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` (
    `merge_event_id` BIGINT COMMENT 'Unique surrogate identifier for each Master Data Management (MDM) party merge event. One row per merge operation in the Party MDM deduplication process.',
    `merge_approved_by_party_id` BIGINT COMMENT 'Foreign key to the Party (operator/user) who reviewed and approved the merge decision. Required for audit trail and SOX compliance.',
    `merge_reversed_by_party_id` BIGINT COMMENT 'Foreign key to the Party (operator/user) who authorized and executed the reversal of this merge event. Null if no reversal has occurred.',
    `merge_survivor_party_id` BIGINT COMMENT 'Foreign key to the Party record designated as the golden/survivor record after the merge. All downstream references are repointed to this party.',
    `primary_merged_party_id` BIGINT COMMENT 'Foreign key to the Party record identified as the duplicate and absorbed into the survivor. This party is retired after the merge operation completes.',
    `affected_billing_account_count` BIGINT COMMENT 'Number of billing accounts linked to the merged party that were consolidated under the survivor party as part of this merge operation.',
    `affected_claim_count` BIGINT COMMENT 'Number of claims linked to the merged (duplicate) party that were repointed to the survivor party as a result of this merge operation.',
    `affected_policy_count` BIGINT COMMENT 'Number of active or historical policies linked to the merged (duplicate) party that were repointed to the survivor party as a result of this merge operation.',
    `batch_run_code` STRING COMMENT 'Identifier of the MDM deduplication batch job run that generated this merge event, if the merge was produced by an automated batch matching process rather than a real-time request.',
    `conflict_resolution_notes` STRING COMMENT 'Operator-entered notes describing how conflicting attribute values between the survivor and merged party were resolved. Null if no conflicts were detected.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this merge event record was first created in the data platform. Serves as the audit trail creation marker per SOX and GLBA requirements.',
    `data_conflict_flag` BOOLEAN COMMENT 'Indicates whether conflicting attribute values (e.g., different addresses, DOBs, or contact details) were detected between the survivor and merged party records during the merge.',
    `fraud_indicator_flag` BOOLEAN COMMENT 'Indicates whether the Fraud Detection or SIU system flagged this merge event as potentially suspicious, such as an attempt to obscure a partys claims or underwriting history.',
    `kyc_review_completed_flag` BOOLEAN COMMENT 'Indicates whether the post-merge KYC review has been completed for the survivor party. Relevant only when kyc_review_required_flag is true.',
    `kyc_review_required_flag` BOOLEAN COMMENT 'Indicates whether the merge triggered a KYC re-verification requirement for the survivor party, typically when identity attributes differ between the two records.',
    `match_rule_set` STRING COMMENT 'Identifier or name of the matching rule set or algorithm version applied by the MDM engine to compute the match score (e.g., RULE_SET_V3_NAME_DOB_SSN).',
    `match_score` DECIMAL(5,2) COMMENT 'Probabilistic similarity score (0.00–100.00) produced by the MDM matching algorithm comparing the survivor and merged party records. Higher scores indicate stronger duplicate confidence.',
    `merge_approved_timestamp` TIMESTAMP COMMENT 'Date and time when an authorized operator approved the merge operation. Null if the merge is automated and requires no human approval step.',
    `merge_channel` STRING COMMENT 'The processing channel through which the merge was initiated: batch deduplication job, real-time event trigger, API call from an integrated system, or manual entry via the MDM user interface.. Valid values are `batch|real_time|api|manual_ui`',
    `merge_executed_timestamp` TIMESTAMP COMMENT 'Date and time when the merge operation was physically applied in the MDM system, retiring the duplicate party and consolidating records under the survivor.',
    `merge_reason_code` STRING COMMENT 'Standardized code classifying the root cause of the duplicate. Drives reporting on data quality issues and MDM process improvement. [ENUM-REF-CANDIDATE: promote to reference product if codes expand]. Valid values are `duplicate_name_address|duplicate_ssn_fein|duplicate_contact|data_entry_error|system_migration|other`',
    `merge_reason_description` STRING COMMENT 'Free-text narrative explaining the specific circumstances that led to the duplicate party records and the rationale for selecting the survivor record.',
    `merge_request_code` STRING COMMENT 'Externally visible business identifier for the merge request ticket or workflow instance, as assigned by the MDM or deduplication system (e.g., MDM-2024-00123).',
    `merge_requested_timestamp` TIMESTAMP COMMENT 'Date and time when the merge request was first submitted into the MDM workflow queue, in ISO 8601 format with timezone offset.',
    `merge_status` STRING COMMENT 'Current lifecycle state of the merge operation. Pending awaits approval; approved is authorized but not yet executed; completed is fully applied; reversed is undone; failed encountered an error.. Valid values are `pending|approved|completed|reversed|failed`',
    `merge_type` STRING COMMENT 'Indicates whether the merge was initiated manually by an operator, triggered automatically by the MDM matching engine, or surfaced as a system suggestion pending human review.. Valid values are `manual|automated|system_suggested`',
    `merged_party_pre_merge_status` STRING COMMENT 'Lifecycle status of the duplicate party record immediately before the merge was executed. Preserved for audit and potential reversal.. Valid values are `active|inactive|suspended|deceased|unknown`',
    `notes` STRING COMMENT 'General free-text notes entered by the operator or MDM system regarding this merge event, including any special handling instructions or escalation context.',
    `regulatory_notification_required_flag` BOOLEAN COMMENT 'Indicates whether the merge of these party records triggers a regulatory notification obligation, such as under GLBA, GDPR/CCPA, or state DOI market conduct requirements.',
    `regulatory_notification_sent_flag` BOOLEAN COMMENT 'Indicates whether the required regulatory notification has been dispatched following the merge. Relevant only when regulatory_notification_required_flag is true.',
    `reversal_reason` STRING COMMENT 'Free-text explanation of why a completed merge was reversed. Null if no reversal has occurred. Required for data governance and audit compliance.',
    `reversal_timestamp` TIMESTAMP COMMENT 'Date and time when a completed merge was reversed (un-merged). Null if the merge has not been reversed. Supports audit trail for erroneous merges.',
    `siu_referral_flag` BOOLEAN COMMENT 'Indicates whether this merge event was referred to the Special Investigations Unit (SIU) for further review due to suspected fraud or identity manipulation.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system that originated or triggered the merge request (e.g., MDM for the party master, PAS for the policy system, CLAIMS for the claims system).. Valid values are `MDM|PAS|CLAIMS|BILLING|PRODUCER_MGMT|MANUAL`',
    `source_system_merge_ref` STRING COMMENT 'The native identifier or transaction reference for this merge event as recorded in the originating source system, enabling cross-system traceability.',
    `survivor_party_pre_merge_status` STRING COMMENT 'Lifecycle status of the survivor party record immediately before the merge was executed. Preserved for audit and potential reversal.. Valid values are `active|inactive|suspended|deceased|unknown`',
    `survivor_selection_basis` STRING COMMENT 'Criterion used to designate the survivor record: most recently updated, most data-complete, most associated policies, operator override, or system default rule.. Valid values are `most_recent|most_complete|most_policies|operator_override|system_default`',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this merge event record was last modified in the data platform. Tracks status transitions, reversals, and operator updates for audit compliance.',
    CONSTRAINT pk_merge_event PRIMARY KEY(`merge_event_id`)
) COMMENT 'MDM deduplication event that merges a survivor party with one or more duplicate parties. One row per merge operation. Stores survivor party, merged party, merge date, merge reason, and the operator who approved the merge.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` (
    `segment_id` BIGINT COMMENT 'Unique surrogate identifier for a party segment assignment record. One row per segment assignment per party. Primary key of the segment table.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Customer segmentation strategies (preferred, standard, non-standard) are defined per LOB with distinct underwriting appetite, pricing tiers, and profitability targets.',
    `party_id` BIGINT COMMENT 'Reference to the party record being segmented. Links this segment assignment to the Party master in the Party domain SSOT.',
    `assigned_by` STRING COMMENT 'User ID or system process name that created or last modified this segment assignment. Supports audit trail and SOX compliance for underwriting decisions.',
    `assignment_method` STRING COMMENT 'Method by which this segment was assigned to the party: automated rules engine, manual underwriter override, predictive model scoring, or imported from external system.. Valid values are `automated_rules|manual_override|model_scored|imported`',
    `assignment_reason` STRING COMMENT 'Free-text or coded reason explaining why this segment was assigned or changed (e.g., credit score improvement, loss history review, annual re-segmentation cycle). Supports audit and compliance.',
    `cat_zone` STRING COMMENT 'Catastrophe zone designation for the partys primary location. Used in CAT XL treaty cession eligibility, PML aggregation, and reinsurance bordereaux reporting.. Valid values are `^[A-Z0-9_]{2,20}$`',
    `clue_indicator` STRING COMMENT 'Summary indicator of the partys CLUE loss history report result at time of segmentation. Influences underwriting tier and rate plan. CLUE is a LexisNexis product used in P&C underwriting.. Valid values are `clean|minor_activity|moderate_activity|significant_activity|not_ordered`',
    `segment_code` STRING COMMENT 'Short alphanumeric code uniquely identifying the segment classification (e.g., PERS_PREF, COMM_STD, HNW). Used in rating, underwriting appetite rules, and marketing targeting.. Valid values are `^[A-Z0-9_]{2,30}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this segment assignment record was first created in the system. Supports audit trail, SOX compliance, and data lineage tracking per MAR requirements.',
    `credit_score_band` STRING COMMENT 'Banded credit quality tier derived from the partys insurance credit score at time of segmentation. Used in personal lines rating and underwriting eligibility per state DOI rules.. Valid values are `exceptional|very_good|good|fair|poor|not_scored`',
    `distribution_channel` STRING COMMENT 'Distribution channel through which the party was acquired or is primarily serviced. Influences commission schedules, marketing campaigns, and segment-level profitability analysis.. Valid values are `independent_agent|captive_agent|direct|broker|digital|affinity`',
    `effective_date` DATE COMMENT 'Date from which this segment assignment is in effect for the party. Supports point-in-time reconstruction of the partys segment at any policy effective date or loss date.',
    `employee_count_band` STRING COMMENT 'Banded employee headcount of the commercial party at time of segmentation. Relevant for WC, EPLI, and GL class plan assignment and underwriting appetite screening.. Valid values are `1_to_9|10_to_49|50_to_249|250_to_999|1000_plus`',
    `expiration_date` DATE COMMENT 'Date on which this segment assignment expires or is superseded. Null indicates the assignment is currently open-ended and active. Enables temporal querying of segment history.',
    `fraud_indicator` STRING COMMENT 'Fraud risk classification for the party as flagged by the SIU/Fraud Detection system. Influences underwriting acceptance, claims handling, and regulatory reporting obligations.. Valid values are `none|watch_list|suspected|confirmed|cleared`',
    `kyc_status` STRING COMMENT 'Current KYC verification status of the party as recorded in the Party MDM. Drives underwriting eligibility and compliance holds. Required under GLBA and state DOI market conduct rules.. Valid values are `verified|pending|failed|exempt|not_required`',
    `loss_ratio_band` STRING COMMENT 'Banded historical loss ratio for the party at time of segmentation. Derived from actuarial reserving data. Informs renewal pricing, tier migration, and non-renewal decisions.. Valid values are `under_40pct|40_to_60pct|60_to_80pct|80_to_100pct|over_100pct`',
    `market_segment` STRING COMMENT 'Marketing-oriented segment grouping used for campaign targeting and distribution channel alignment. Distinct from underwriting tier; reflects revenue and growth strategy.. Valid values are `mass_market|middle_market|large_account|small_business|micro_business`',
    `mvr_indicator` STRING COMMENT 'Summary indicator of the partys MVR result at time of segmentation. Applicable for personal and commercial auto lines. Drives tier assignment and surcharge eligibility.. Valid values are `clean|minor_violations|major_violations|dui|not_ordered`',
    `naics_code` STRING COMMENT 'NAICS industry classification code for commercial party segments. Used in commercial lines underwriting appetite, SIC/NAICS-based eligibility rules, and actuarial class plan assignment.. Valid values are `^[0-9]{2,6}$`',
    `segment_name` STRING COMMENT 'Human-readable name of the segment classification assigned to the party (e.g., Personal Lines Preferred, Commercial Lines Standard, High-Net-Worth).',
    `party_type_at_assignment` STRING COMMENT 'Whether the party was classified as an individual (person) or organization at the time this segment was assigned. Supports personal vs. commercial lines segmentation logic.. Valid values are `individual|organization`',
    `policy_count_band` STRING COMMENT 'Banded count of active policies held by the party at time of segmentation. Supports multi-policy discount eligibility, cross-sell targeting, and account rounding strategies.. Valid values are `single_policy|2_to_3|4_to_6|7_plus`',
    `preferred_program_code` STRING COMMENT 'Code identifying the specific underwriting program or product tier the party qualifies for (e.g., HNW_PLATINUM, BOP_GOLD, PAP_PREFERRED). Links to rate plan and form set selection.. Valid values are `^[A-Z0-9_]{2,20}$`',
    `profitability_tier` STRING COMMENT 'Actuarially derived profitability classification for the party based on historical loss ratio and expense ratio. Used in renewal underwriting decisions and retention strategy.. Valid values are `highly_profitable|profitable|break_even|unprofitable|unknown`',
    `regulatory_classification` STRING COMMENT 'Regulatory market classification applicable to the partys segment: admitted, non-admitted, surplus lines, or residual market. Drives statutory reporting and stamping office obligations.. Valid values are `admitted|non_admitted|surplus_lines|residual_market|not_applicable`',
    `revenue_band` STRING COMMENT 'Annual revenue band of the commercial party at time of segmentation. Used to classify commercial accounts into market segments and determine eligibility for BOP, CPP, or large-account programs.. Valid values are `micro|small|mid_market|large|enterprise`',
    `review_date` DATE COMMENT 'Scheduled date for the next periodic review of this segment assignment. Supports annual re-segmentation cycles, renewal underwriting workflows, and actuarial cohort refresh.',
    `risk_score` DECIMAL(7,4) COMMENT 'Numeric risk score assigned to the party at the time of segmentation, derived from underwriting workbench scoring models. Higher values indicate higher risk. Range typically 0.0000–9999.9999.',
    `segment_status` STRING COMMENT 'Current lifecycle status of this segment assignment record: active (in force), inactive (expired), superseded (replaced by a newer assignment), or pending review.. Valid values are `active|inactive|superseded|pending_review`',
    `segment_type` STRING COMMENT 'Functional category of the segmentation: underwriting appetite, marketing targeting, billing tier, regulatory classification, or actuarial cohort. Determines which business process consumes this segment.. Valid values are `underwriting|marketing|billing|regulatory|actuarial`',
    `sic_code` STRING COMMENT 'SIC code for commercial party segments. Legacy classification used alongside NAICS in ISO commercial lines rating manuals and NAIC statutory reporting.. Valid values are `^[0-9]{4}$`',
    `source_system_ref` STRING COMMENT 'Native identifier of this segment record in the originating source system. Enables reconciliation between the lakehouse silver layer and the operational system of record.',
    `state_of_domicile` STRING COMMENT 'Two-letter US state code of the partys primary domicile at time of segmentation. Drives state-specific underwriting rules, rate filings, and DOI regulatory compliance.. Valid values are `^[A-Z]{2}$`',
    `territory_code` STRING COMMENT 'Rating territory code assigned to the party based on domicile or primary risk location. Used in ISO territory-based rating plans and catastrophe exposure aggregation.. Valid values are `^[A-Z0-9]{2,10}$`',
    `tier` STRING COMMENT 'Underwriting quality tier assigned to the party within the segment: preferred, standard, non-standard, high-net-worth, ultra-high-net-worth, or declined. Drives rate plan selection.. Valid values are `preferred|standard|non_standard|high_net_worth|ultra_high_net_worth|declined`',
    `tiv_band` STRING COMMENT 'Banded Total Insured Value of the partys insurable assets at time of segmentation. Used in property underwriting appetite, CAT exposure aggregation, and PML modeling.. Valid values are `under_500k|500k_to_2m|2m_to_10m|10m_to_50m|over_50m`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this segment assignment record. Used for incremental ETL processing, change data capture, and audit trail maintenance.',
    `uw_appetite_flag` BOOLEAN COMMENT 'Indicates whether this segment falls within the insurers current underwriting appetite. True = in-appetite; False = out-of-appetite or restricted. Used in submission triage and eligibility screening.',
    `years_as_customer` BIGINT COMMENT 'Number of complete years the party has been a policyholder with the insurer at time of segmentation. Used in loyalty-based pricing, NCB eligibility, and retention analytics.',
    CONSTRAINT pk_segment PRIMARY KEY(`segment_id`)
) COMMENT 'Business segmentation classification assigned to a party: personal lines, commercial lines, preferred, standard, non-standard, high-net-worth. One row per segment assignment per party. Supports underwriting appetite and marketing targeting.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` (
    `party_document_id` BIGINT COMMENT 'Unique surrogate identifier for each party document record in the Silver layer. Primary key. One row per document per party.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Documents are often coverage-specific: ISO forms, endorsement forms, coverage certificates, valuation reports.',
    `insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Underwriting and claims require linking risk-specific documents (inspection reports, appraisals, engineering surveys, loss control recommendations) directly to insured_risk.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Insurance documents (ACORD forms, endorsements, certificates) are LOB-specific with distinct form libraries, retention schedules, and regulatory filing requirements.',
    `party_id` BIGINT COMMENT 'Reference to the Party record that owns this document. Links the document to the person or organization in the Party master.',
    `superseded_by_document_party_document_id` BIGINT COMMENT 'Reference to the newer document_id that replaces this document when a revised version is received. Null if this is the current active version. Enables version chain traversal.',
    `acord_form_edition` STRING COMMENT 'Edition date or version of the ACORD form (e.g., 2016/03). Ensures the correct form version is used for regulatory and underwriting compliance.',
    `acord_form_number` STRING COMMENT 'ACORD standard form number associated with the document (e.g., 125, 126, 140). Null for non-ACORD documents. Enables ISO/ACORD forms library alignment.',
    `claim_number` STRING COMMENT 'Claim number to which this document is associated, if applicable (e.g., FNOL intake form, adjuster report, SIU referral). Null for non-claim documents.',
    `clue_report_number` STRING COMMENT 'Reference number for a CLUE loss history report obtained from LexisNexis. Null for non-CLUE documents. Used in personal lines underwriting risk evaluation.',
    `coi_holder_name` STRING COMMENT 'Name of the certificate holder on a Certificate of Insurance document. Null for non-CoI documents. Required for additional insured and lender tracking.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this document record was first created in the Silver layer data product. Audit trail field per SOX and MAR requirements.',
    `party_document_description` STRING COMMENT 'Free-text description of the document content, purpose, or any special notes added by the underwriter, adjuster, or KYC analyst during intake or review.',
    `effective_date` DATE COMMENT 'Date from which the document is considered valid and in force (e.g., issue date on a government ID or Certificate of Insurance).',
    `expiry_date` DATE COMMENT 'Date on which the document expires and is no longer valid. Null for documents with no expiration. Drives renewal alerts and KYC re-verification.',
    `file_format` STRING COMMENT 'Format or MIME type of the stored document file. Drives rendering, OCR processing, and archival decisions. [ENUM-REF-CANDIDATE: PDF|TIFF|JPEG|PNG|DOCX|XML|CSV|OTHER — 8 candidates stripped; promote to reference product]',
    `file_name` STRING COMMENT 'Original file name of the document as uploaded or received (e.g., acord125_submission_2024.pdf). Used for retrieval and display in document management.',
    `file_size_bytes` BIGINT COMMENT 'Size of the document file in bytes. Used for storage capacity planning and to detect truncated or corrupt uploads.',
    `is_kyc_document` BOOLEAN COMMENT 'Indicates whether this document is used to satisfy KYC identity verification requirements for the party. Drives compliance reporting and onboarding workflows.',
    `is_primary` BOOLEAN COMMENT 'Indicates whether this is the primary or authoritative version of the document for the party and document type. True for the current active version.',
    `is_sensitive` BOOLEAN COMMENT 'Indicates whether the document contains sensitive PII, PHI, or legally privileged content requiring restricted access controls under GLBA or GDPR.',
    `issuing_authority` STRING COMMENT 'Name of the government body, agency, or organization that issued the document (e.g., US Department of State, California DMV, ISO).',
    `issuing_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the authority that issued the document (e.g., USA, CAN, GBR). Required for KYC and OFAC screening.. Valid values are `^[A-Z]{3}$`',
    `issuing_state` STRING COMMENT 'Two-letter US state or territory code of the issuing authority (e.g., CA, NY, TX). Applicable for state-issued IDs, driver licenses, and producer licenses.. Valid values are `^[A-Z]{2}$`',
    `kyc_verification_method` STRING COMMENT 'Method used to verify the document for KYC purposes: manual review, automated OCR/AI, or third-party verification service (e.g., LexisNexis, Experian).. Valid values are `MANUAL|AUTOMATED|THIRD_PARTY|NOT_APPLICABLE`',
    `language_code` STRING COMMENT 'ISO 639-1 language code of the document content (e.g., en, es, fr). Supports multilingual document management and regulatory translation requirements.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `mvr_order_number` STRING COMMENT 'Order or reference number from the MVR vendor for Motor Vehicle Record documents. Null for non-MVR documents. Used for PAP and CA underwriting.',
    `number` STRING COMMENT 'Externally-known identifier assigned to the document by the issuing authority or source system (e.g., passport number, driver license number, ACORD form number).',
    `page_count` BIGINT COMMENT 'Number of pages in the document. Used for completeness validation (e.g., ensuring all pages of an ACORD application are present).',
    `party_document_status` STRING COMMENT 'Current lifecycle state of the document within the KYC and underwriting workflow. Drives eligibility and compliance checks.. Valid values are `RECEIVED|UNDER_REVIEW|VERIFIED|REJECTED|EXPIRED|ARCHIVED`',
    `party_document_type` STRING COMMENT 'Classification of the document by business purpose. [ENUM-REF-CANDIDATE: GOVT_ID|PROOF_OF_ADDRESS|ACORD_APPLICATION|COI|MVR|LOSS_RUN|POLICY_DEC|OTHER — promote to reference product]',
    `policy_number` STRING COMMENT 'Policy number to which this document is associated, if applicable (e.g., a declarations page or endorsement form). Null for party-level documents not tied to a specific policy.',
    `purge_date` DATE COMMENT 'Scheduled date on which the document is eligible for deletion or archival per the retention_category policy. Null for permanent retention documents.',
    `received_date` DATE COMMENT 'Calendar date the document was received by the insurer from the party or source system. Used for SLA tracking and KYC timeliness.',
    `rejection_reason` STRING COMMENT 'Reason the document was rejected during verification. Populated only when document_status is REJECTED. Supports SIU and fraud detection workflows.. Valid values are `EXPIRED|ILLEGIBLE|MISMATCH|FRAUDULENT|INCOMPLETE|NOT_APPLICABLE`',
    `retention_category` STRING COMMENT 'Records retention classification governing how long the document must be kept per regulatory and statutory requirements (e.g., NAIC, state DOI, SOX, GLBA).. Valid values are `PERMANENT|7_YEAR|5_YEAR|3_YEAR|1_YEAR|DESTROY_ON_EXPIRY`',
    `source_system_doc_code` STRING COMMENT 'Native document identifier from the originating operational system (e.g., Guidewire PolicyCenter document GUID). Enables lineage tracing back to the system of record.',
    `storage_uri` STRING COMMENT 'Fully qualified URI pointing to the document file in the document management or object storage system (e.g., S3 path, SharePoint URL). Confidential due to access control.',
    `submission_number` STRING COMMENT 'Underwriting submission number to which this document is associated (e.g., ACORD application submitted for a new risk). Null for documents not tied to a submission.',
    `subtype` STRING COMMENT 'Granular classification within the document type (e.g., PASSPORT under GOVT_ID, ACORD_125 under ACORD_APPLICATION). [ENUM-REF-CANDIDATE: promote to reference product]',
    `tags` STRING COMMENT 'Comma-separated business tags applied to the document for search and categorization (e.g., renewal,endorsement,high-value). Supports document retrieval workflows.',
    `title` STRING COMMENT 'Human-readable name or label for the document (e.g., John Smith Passport, ACORD 125 Commercial Lines Application). Used for display and search.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this document record was last modified in the Silver layer. Tracks status changes, verification updates, and version replacements.',
    `verified_by` STRING COMMENT 'Name or user identifier of the underwriter, adjuster, or KYC analyst who verified the document. Supports audit trail and compliance review.',
    `verified_date` DATE COMMENT 'Date the document was verified as authentic and acceptable by the underwriting or KYC team. Null if not yet verified.',
    `version_number` BIGINT COMMENT 'Sequential version number of the document, incremented each time a new version is received or generated. Version 1 is the original. Supports document lifecycle management.',
    CONSTRAINT pk_party_document PRIMARY KEY(`party_document_id`)
) COMMENT 'Documents associated with a party: government-issued ID, proof of address, ACORD applications, CoI, MVR report, loss runs. One row per document. Stores document type, source system, storage URI, received date, and expiry date.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` (
    `loss_payee_id` BIGINT COMMENT 'Unique surrogate identifier for each loss payee or mortgagee interest record. One row per interest attachment on a party and policy or insured risk.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Loss payees (mortgagees, lienholders) are often specific to individual coverages rather than entire policies. Mortgagee on building coverage, lienholder on auto physical damage.',
    `insured_risk_id` BIGINT COMMENT 'Reference to the specific Insured Risk (property, vehicle, etc.) to which this loss payee interest is attached. Null when attached at policy level only.',
    `lender_address_id` BIGINT COMMENT 'Foreign key linking to party.address. Business justification: Loss payee embeds lender address fields that should be normalized to the address table. The address table is the SSOT for all addresses.',
    `party_id` BIGINT COMMENT 'Reference to the Party record representing the lender, mortgagee, or loss payee entity holding the financial interest.',
    `policy_id` BIGINT COMMENT 'Reference to the Policy to which this loss payee interest is attached. Null when interest is attached at insured risk level only.',
    `acord_form_type` STRING COMMENT 'ACORD standard form type used to evidence this loss payee or mortgagee interest (e.g., ACORD 25 Certificate of Liability, ACORD 28 Evidence of Property Insurance).. Valid values are `ACORD_25|ACORD_28|ACORD_27|ACORD_75|other`',
    `cancellation_notice_date` DATE COMMENT 'Date on which the cancellation or non-renewal notice was sent to this loss payee or mortgagee. Required for regulatory compliance and audit.',
    `cancellation_notice_sent` BOOLEAN COMMENT 'Indicates whether the required cancellation or non-renewal notice has been sent to this loss payee or mortgagee per the policy terms and state regulations.',
    `certificate_issue_date` DATE COMMENT 'Date on which the Certificate of Insurance (CoI) was issued to this loss payee or mortgagee. Used for compliance tracking and renewal notifications.',
    `certificate_number` STRING COMMENT 'Certificate of Insurance (CoI) number issued to this loss payee or mortgagee as evidence of coverage per ACORD 28 or equivalent form.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this loss payee interest record was first created in the system. Used for audit trail and SOX compliance.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code applicable to monetary fields on this loss payee record. Defaults to USD for domestic US policies.. Valid values are `^[A-Z]{3}$`',
    `effective_date` DATE COMMENT 'Date on which this loss payee or mortgagee interest becomes active and enforceable on the policy or insured risk.',
    `endorsement_number` STRING COMMENT 'Policy endorsement number under which this loss payee or mortgagee interest was added or modified on the policy.',
    `escrow_account_number` STRING COMMENT 'Lender escrow account number used to collect and remit insurance premium payments on behalf of the mortgagor. Supports billing integration with lender.',
    `expiration_date` DATE COMMENT 'Date on which this loss payee or mortgagee interest expires or is removed. Null indicates the interest remains active through the policy term.',
    `form_number` STRING COMMENT 'ISO or proprietary form number of the loss payable or mortgagee endorsement attached to the policy (e.g., ISO CP 12 18, PP 03 03).',
    `interest_rank` BIGINT COMMENT 'Ordinal rank of this interest when multiple loss payees or mortgagees exist on the same insured risk (e.g., first mortgagee = 1, second mortgagee = 2).',
    `interest_status` STRING COMMENT 'Current lifecycle status of the loss payee or mortgagee interest record. Drives whether the interest is honored in claims payment and certificate issuance.. Valid values are `active|inactive|pending|cancelled|expired`',
    `interest_type` STRING COMMENT 'Classification of the financial interest held by the party on the policy or insured risk. Drives certificate of insurance (CoI) and claims payment routing.. Valid values are `mortgagee|loss_payee|additional_insured|lienholder|lessor|certificate_holder`',
    `joint_payee_required` BOOLEAN COMMENT 'Indicates whether claim payments must be made jointly to both the insured and this loss payee or mortgagee rather than solely to the insured.',
    `lender_email` STRING COMMENT 'Email address of the lender or mortgagee institution used for electronic certificate of insurance delivery and claims payment notifications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `lender_fein` STRING COMMENT 'IRS-assigned Federal Employer Identification Number (FEIN) of the lending institution. Required for tax reporting on claim payments and 1099 issuance.. Valid values are `^[0-9]{2}-[0-9]{7}$`',
    `lender_name` STRING COMMENT 'Legal name of the lending institution, mortgagee, or lienholder as it must appear on the policy declarations and loss payment instruments.',
    `lender_phone` STRING COMMENT 'Primary contact telephone number for the lender or mortgagee institution used for claims notification and certificate of insurance correspondence.. Valid values are `^+?[0-9-s().]{7,20}$`',
    `lender_reference_number` STRING COMMENT 'Secondary lender-assigned reference or account number (e.g., investor loan number, servicer reference) distinct from the primary loan number.',
    `loan_number` STRING COMMENT 'Lender-assigned loan or mortgage account number associated with the insured risk. Used to route claim payments and satisfy lender reporting requirements.',
    `loss_payable_clause_type` STRING COMMENT 'Type of loss payable clause attached to the policy for this interest: Standard, Lenders (protects lender independently), Open, or Union mortgage clause.. Valid values are `standard|lenders|open|union`',
    `naic_lender_code` STRING COMMENT 'NAIC-assigned code identifying the lender or financial institution for statutory reporting and Schedule F bordereaux purposes.',
    `notes` STRING COMMENT 'Free-text underwriter or policy service notes regarding special conditions, lender instructions, or exceptions applicable to this loss payee interest.',
    `notification_days` BIGINT COMMENT 'Number of days advance notice required to be given to the lender or mortgagee before policy cancellation or non-renewal takes effect.',
    `notification_required` BOOLEAN COMMENT 'Indicates whether the lender or mortgagee must be notified of policy changes, cancellations, or non-renewals per the loss payable clause or lender agreement.',
    `payment_payable_to` STRING COMMENT 'Full legal name(s) as they must appear on claim payment instruments (checks or EFT) issued jointly or solely to this loss payee or mortgagee.',
    `payment_threshold_amount` DECIMAL(18,2) COMMENT 'Minimum claim payment amount above which joint payee or mortgagee co-endorsement is required per the lender agreement or loss payable clause.',
    `premium_billed_to_lender` BOOLEAN COMMENT 'Indicates whether the insurance premium is billed directly to the lender via escrow rather than to the policyholder. Drives billing system routing.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this loss payee interest record originated (e.g., PAS for PolicyCenter, MDM for Party Master).. Valid values are `PAS|CMS|BILLING|MDM|MANUAL`',
    `source_system_ref_code` STRING COMMENT 'Native identifier of this loss payee interest record in the originating operational system (e.g., Guidewire PolicyCenter internal ID) for lineage and reconciliation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this loss payee interest record. Used for change tracking, audit trail, and downstream incremental processing.',
    CONSTRAINT pk_loss_payee PRIMARY KEY(`loss_payee_id`)
) COMMENT 'Loss payee or mortgagee interest attached to a party and a policy or insured risk. One row per interest. Stores interest type (mortgagee, loss payee, additional insured), lender name, loan number, and effective dates.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` (
    `license_id` BIGINT COMMENT 'Unique surrogate identifier for a professional license record held by a party. Primary key of the license table; one row per license per party.',
    `issuing_geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Producer license validation by operating territory and regulatory compliance tracking require linking licenses to issuing state geography.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Producer licenses authorize specific LOBs (personal auto, commercial property, workers compensation). Regulatory compliance requires validating agent LOB authority before binding.',
    `party_id` BIGINT COMMENT 'Reference to the party (person or organization) who holds this license. Links the license to the Party master record.',
    `adjuster_type` STRING COMMENT 'Sub-type of adjuster license indicating the adjusters operational role. Populated only when license_type is adjuster. Drives claim assignment eligibility rules.. Valid values are `staff|independent|public|catastrophe|auto_damage`',
    `background_check_date` DATE COMMENT 'Date on which the most recent background check was completed for this license. Used to determine if a re-check is required at renewal per state DOI requirements.',
    `background_check_status` STRING COMMENT 'Status of the criminal background check conducted as part of the license application or renewal process. Required by many state DOIs for producer and adjuster licensing.. Valid values are `passed|failed|pending|waived|not_required`',
    `ce_credits_completed` BIGINT COMMENT 'Number of continuing education (CE) credit hours completed by the licensee in the current renewal cycle. Compared against ce_credits_required to assess compliance.',
    `ce_credits_required` BIGINT COMMENT 'Total number of continuing education (CE) credit hours required by the issuing state for the current renewal cycle. Varies by state and license class.',
    `class` STRING COMMENT 'Sub-classification of the license type as defined by the issuing state (e.g., Property, Casualty, Life, Health, Personal Lines, Commercial Lines). Drives appointment eligibility.',
    `continuing_education_due_date` DATE COMMENT 'Date by which the licensee must complete required continuing education (CE) credit hours to maintain license validity. Drives CE compliance tracking and renewal alerts.',
    `contractor_license_number` STRING COMMENT 'State-issued contractor license number for parties who are licensed contractors (e.g., restoration vendors). Populated only when license_type is contractor. Used in claims vendor management.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this license record was first created in the data platform. Supports audit trail, data lineage, and GDPR/CCPA record-keeping obligations.',
    `disciplinary_action_description` STRING COMMENT 'Free-text description of any regulatory disciplinary actions, fines, or sanctions associated with this license. Populated only when disciplinary_action_indicator is True.',
    `disciplinary_action_indicator` BOOLEAN COMMENT 'Indicates whether the licensee has any regulatory disciplinary actions, fines, or sanctions on record with the issuing DOI (True) or not (False). Sourced from NIPR PDB.',
    `effective_date` DATE COMMENT 'Date from which this license record is considered effective in the insurers systems. May differ from issue_date if the license was backdated or loaded from a historical feed.',
    `errors_omissions_carrier` STRING COMMENT 'Name of the insurance carrier providing the licensees Errors and Omissions (E&O) professional liability coverage. Required for producer appointment eligibility verification.',
    `errors_omissions_expiry_date` DATE COMMENT 'Expiration date of the licensees Errors and Omissions (E&O) professional liability policy. Drives alerts when E&O coverage is about to lapse, which may affect appointment status.',
    `errors_omissions_policy_number` STRING COMMENT 'Policy number of the licensees Errors and Omissions (E&O) professional liability insurance. Verified during producer appointment and renewal processes.',
    `ethics_ce_credits_completed` BIGINT COMMENT 'Number of ethics-specific continuing education (CE) credit hours completed by the licensee in the current renewal cycle. Compared against ethics_ce_credits_required.',
    `ethics_ce_credits_required` BIGINT COMMENT 'Number of ethics-specific continuing education (CE) credit hours mandated by the issuing state within the renewal cycle. Many states require a separate ethics CE component.',
    `expiry_date` DATE COMMENT 'Date on which this license expires and must be renewed to remain valid. Null for licenses with no fixed expiration. Drives renewal workflow and appointment eligibility.',
    `fein` STRING COMMENT 'Federal Employer Identification Number of the licensed entity when the licensee is an organization (agency or firm). Used for tax reporting and IRS compliance.. Valid values are `^[0-9]{2}-[0-9]{7}$`',
    `is_resident_license` BOOLEAN COMMENT 'Indicates whether this is a resident (home-state) license (True) or a non-resident license (False). Non-resident licenses are issued under reciprocity agreements.',
    `issue_date` DATE COMMENT 'Date on which the issuing state DOI originally granted this license. Used to calculate license tenure and continuing education (CE) cycle start.',
    `issuing_state_code` STRING COMMENT 'Two-letter US state or territory code of the Department of Insurance that issued this license (e.g., CA, TX, NY). Aligns with NAIC state coding standards.. Valid values are `^[A-Z]{2}$`',
    `license_status` STRING COMMENT 'Current regulatory status of the license as reported by the issuing DOI or NIPR. Drives eligibility for producer appointments and claim adjuster assignments.. Valid values are `active|expired|suspended|revoked|cancelled|pending`',
    `license_type` STRING COMMENT 'Category of professional license held by the party. Distinguishes producer, adjuster, contractor, surplus lines, and other license types. [ENUM-REF-CANDIDATE: promote to reference product if types expand]. Valid values are `producer|adjuster|contractor|surplus_lines|public_adjuster|reinsurance_intermediary`',
    `nipr_last_verified_date` DATE COMMENT 'Date on which this license record was last verified against the NIPR Producer Database (PDB). Supports ongoing compliance monitoring and stale-data detection.',
    `nipr_verification_status` STRING COMMENT 'Result of the most recent NIPR PDB verification check for this license. mismatch indicates discrepancies between internal records and NIPR data requiring remediation.. Valid values are `verified|unverified|mismatch|not_found`',
    `notes` STRING COMMENT 'Free-text field for underwriting or compliance notes related to this license record, such as conditions, restrictions, or manual override explanations. For internal use only.',
    `npn` STRING COMMENT 'Unique National Producer Number assigned by NIPR to identify a licensed producer across all states. Used for cross-state appointment validation and NIPR PDB lookups.. Valid values are `^[0-9]{1,10}$`',
    `number` STRING COMMENT 'Official license number assigned by the issuing state Department of Insurance (DOI) or regulatory authority. Used for NIPR validation and DOI compliance checks.',
    `reciprocity_state_codes` STRING COMMENT 'Comma-delimited list of two-letter state codes where this license is recognized under reciprocity agreements. Enables multi-state appointment eligibility without separate applications.',
    `renewal_date` DATE COMMENT 'Date on which the license was most recently renewed by the issuing DOI. Tracks renewal history and supports continuing education (CE) compliance monitoring.',
    `resident_state_code` STRING COMMENT 'Two-letter US state code of the licensees home state of residence. Distinguishes resident licenses from non-resident licenses for NIPR and reciprocity tracking.. Valid values are `^[A-Z]{2}$`',
    `source_system_license_key` STRING COMMENT 'Natural key or record identifier for this license in the originating source system (e.g., NIPR PDB record ID, PAS license record ID). Supports reconciliation and deduplication.',
    `ssn_last4` STRING COMMENT 'Last four digits of the licensees Social Security Number, stored for identity verification purposes only. Full SSN must not be stored per GLBA and GDPR/CCPA data minimization.. Valid values are `^[0-9]{4}$`',
    `surplus_lines_authorized` BOOLEAN COMMENT 'Indicates whether the licensee is authorized to place surplus lines business in the issuing state (True) or not (False). Required for non-admitted market placements.',
    `surplus_lines_number` STRING COMMENT 'State-issued surplus lines license number, distinct from the standard producer license number. Required for stamping office filings and surplus lines tax remittance.',
    `termination_date` DATE COMMENT 'Date on which the license was terminated, revoked, or surrendered prior to its natural expiry. Null if the license has not been terminated. Required for DOI market conduct reporting.',
    `termination_reason` STRING COMMENT 'Reason code explaining why the license was terminated or revoked. Populated only when termination_date is set. Supports regulatory and compliance reporting.. Valid values are `voluntary_surrender|revocation|non_renewal|disciplinary|death|other`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this license record was last modified in the data platform. Used for change detection, incremental ETL processing, and audit trail compliance.',
    CONSTRAINT pk_license PRIMARY KEY(`license_id`)
) COMMENT 'Professional licenses held by a party: producer license, adjuster license, contractor license. One row per license. Stores license type, license number, issuing state, issue date, expiry date, and active status for NIPR/DOI compliance.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` (
    `household_id` BIGINT COMMENT 'Primary key for household',
    `master_household_id` BIGINT COMMENT 'Reference to the master household record if this household has been merged or is a duplicate.',
    `primary_address_id` BIGINT COMMENT 'Foreign key linking to party.address. Business justification: Household needs FK to address for primary address. The household table has denormalized address fields (primary_address_line_1, primary_address_line_2, primary_city, primary_state_province',
    `primary_contact_party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Household needs FK to party for primary contact. The household table has primary_phone_number and primary_email_address, but these are household-level summary fields that may differ from',
    `adult_count` BIGINT COMMENT 'Number of adults aged 18 or older in the household, used for underwriting and rating purposes.',
    `catastrophe_zone_code` STRING COMMENT 'Catastrophe zone identifier for the household location used in exposure aggregation and reinsurance reporting.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the household record was first created in the system.',
    `credit_score` BIGINT COMMENT 'Insurance credit score for the household used in underwriting and rating decisions where permitted by regulation.',
    `credit_score_date` DATE COMMENT 'Date when the credit score was obtained or last refreshed for the household.',
    `deduplication_key` STRING COMMENT 'Composite key used for household matching and deduplication across systems and data sources.',
    `dependent_count` BIGINT COMMENT 'Number of dependents under age 18 in the household, used for underwriting and rating purposes.',
    `do_not_contact_flag` BOOLEAN COMMENT 'Indicates whether the household has requested no marketing or non-essential contact.',
    `effective_date` DATE COMMENT 'Date when this version of the household record became effective for temporal tracking.',
    `established_date` DATE COMMENT 'Date when the household was first established as a customer or prospect in the system.',
    `expiration_date` DATE COMMENT 'Date when this version of the household record expires or is superseded, null if current.',
    `external_reference_id` STRING COMMENT 'External system identifier used for integration and cross-system reconciliation of household records.',
    `first_policy_effective_date` DATE COMMENT 'Date when the first policy for this household became effective, used for tenure and loyalty analysis.',
    `household_name` STRING COMMENT 'Primary display name for the household, typically derived from the primary policyholder or head of household.',
    `household_number` STRING COMMENT 'Business-facing unique household identifier used in customer communications and policy documents.',
    `household_status` STRING COMMENT 'Current lifecycle status of the household record in the system.',
    `household_type` STRING COMMENT 'Classification of the household structure for underwriting and risk segmentation purposes.',
    `kyc_verification_date` DATE COMMENT 'Date when the most recent KYC verification was completed for the household.',
    `kyc_verification_status` STRING COMMENT 'Status of identity verification and anti-money laundering checks for the household.',
    `last_contact_date` DATE COMMENT 'Date of the most recent interaction or communication with the household.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the household record was last updated or modified.',
    `marketing_opt_in_flag` BOOLEAN COMMENT 'Indicates whether the household has consented to receive marketing communications.',
    `member_count` BIGINT COMMENT 'Total number of individuals associated with this household for underwriting and risk assessment.',
    `paperless_delivery_flag` BOOLEAN COMMENT 'Indicates whether the household has elected to receive policy documents and communications electronically.',
    `primary_email_address` STRING COMMENT 'Primary email address for household communications and policy correspondence.',
    `primary_language_code` STRING COMMENT 'Two-letter ISO language code representing the preferred communication language for the household.',
    `primary_phone_number` STRING COMMENT 'Primary contact telephone number for the household in E.164 format.',
    `risk_territory_code` STRING COMMENT 'Underwriting territory code assigned to the household location for rating and catastrophe exposure analysis.',
    `source_system_code` STRING COMMENT 'Code identifying the originating system or channel where the household record was created.',
    CONSTRAINT pk_household PRIMARY KEY(`household_id`)
) COMMENT 'Master reference table for household. Referenced by household_id.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` (
    `party_group_id` BIGINT COMMENT 'Primary key for party_group',
    `parent_group_id` BIGINT COMMENT 'Reference to the parent party group for hierarchical group structures.',
    `primary_contact_party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Party group needs FK to party for primary contact. The party_group table has primary_contact_name, primary_contact_email, and primary_contact_phone which are party attributes and should be',
    `active_policy_count` BIGINT COMMENT 'Number of currently active insurance policies associated with this party group.',
    `address_line_1` STRING COMMENT 'Primary street address line for the party group headquarters or main office.',
    `address_line_2` STRING COMMENT 'Secondary address line for suite, floor, or building information.',
    `city` STRING COMMENT 'City name for the party group address.',
    `commission_override_percentage` DECIMAL(5,2) COMMENT 'Special commission rate override applicable to policies written under this party group.',
    `country_code` STRING COMMENT 'Three-letter ISO country code for the party group address.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the party group record was first created in the system.',
    `credit_rating` STRING COMMENT 'External credit rating assigned to the party group by a recognized rating agency.',
    `data_classification_level` STRING COMMENT 'Security classification level assigned to this party group record.',
    `effective_date` DATE COMMENT 'Date when the party group relationship became active and eligible for group benefits.',
    `expiration_date` DATE COMMENT 'Date when the party group relationship expires or is scheduled to terminate.',
    `group_code` STRING COMMENT 'Business-assigned unique code identifying the party group for external reference and reporting.',
    `group_discount_percentage` DECIMAL(5,2) COMMENT 'Percentage discount applied to premiums for members of this party group.',
    `group_name` STRING COMMENT 'Full legal or business name of the party group.',
    `group_status` STRING COMMENT 'Current lifecycle status of the party group within the insurers system.',
    `group_type` STRING COMMENT 'Classification of the party group structure indicating its organizational nature.',
    `industry_classification_code` STRING COMMENT 'Standard industry classification code such as NAICS or SIC for the party group.',
    `kyc_verification_date` DATE COMMENT 'Date when the most recent KYC verification was completed.',
    `kyc_verification_status` STRING COMMENT 'Status of Know Your Customer verification process for anti-money laundering compliance.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when the party group record was last updated.',
    `marketing_opt_in_flag` BOOLEAN COMMENT 'Indicates whether the party group has consented to receive marketing communications.',
    `notes` STRING COMMENT 'Free-form text field for additional comments or special instructions related to the party group.',
    `postal_code` STRING COMMENT 'Postal or ZIP code for the party group address.',
    `preferred_communication_method` STRING COMMENT 'Preferred channel for communicating with the party group.',
    `renewal_date` DATE COMMENT 'Next scheduled renewal date for the party group agreement.',
    `risk_tier` STRING COMMENT 'Underwriting risk classification assigned to the party group based on loss history and exposure.',
    `state_province_code` STRING COMMENT 'Two-letter state or province code for the party group address.',
    `tax_identification_number` STRING COMMENT 'Federal or state tax identification number for the party group.',
    `total_member_count` BIGINT COMMENT 'Total number of individual parties or entities that are members of this party group.',
    `website_url` STRING COMMENT 'Official website URL for the party group.',
    CONSTRAINT pk_party_group PRIMARY KEY(`party_group_id`)
) COMMENT 'Master reference table for party_group. Referenced by group_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ADD CONSTRAINT `fk_party_party_master_party_id` FOREIGN KEY (`master_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ADD CONSTRAINT `fk_party_role_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ADD CONSTRAINT `fk_party_individual_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ADD CONSTRAINT `fk_party_organization_mailing_address_id` FOREIGN KEY (`mailing_address_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`address`(`address_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ADD CONSTRAINT `fk_party_organization_parent_organization_id` FOREIGN KEY (`parent_organization_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`organization`(`organization_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ADD CONSTRAINT `fk_party_organization_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ADD CONSTRAINT `fk_party_organization_primary_ultimate_parent_organization_id` FOREIGN KEY (`primary_ultimate_parent_organization_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`organization`(`organization_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ADD CONSTRAINT `fk_party_address_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ADD CONSTRAINT `fk_party_contact_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ADD CONSTRAINT `fk_party_identifier_identifier_mdm_golden_party_id` FOREIGN KEY (`identifier_mdm_golden_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ADD CONSTRAINT `fk_party_identifier_identifier_party_id` FOREIGN KEY (`identifier_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ADD CONSTRAINT `fk_party_identifier_identifier_pas_party_id` FOREIGN KEY (`identifier_pas_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ADD CONSTRAINT `fk_party_relationship_from_party_id` FOREIGN KEY (`from_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ADD CONSTRAINT `fk_party_relationship_party_group_id` FOREIGN KEY (`party_group_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party_group`(`party_group_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ADD CONSTRAINT `fk_party_relationship_household_id` FOREIGN KEY (`household_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`household`(`household_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ADD CONSTRAINT `fk_party_relationship_to_party_id` FOREIGN KEY (`to_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ADD CONSTRAINT `fk_party_kyc_verification_kyc_analyst_party_id` FOREIGN KEY (`kyc_analyst_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ADD CONSTRAINT `fk_party_kyc_verification_kyc_override_approver_party_id` FOREIGN KEY (`kyc_override_approver_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ADD CONSTRAINT `fk_party_kyc_verification_kyc_party_id` FOREIGN KEY (`kyc_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ADD CONSTRAINT `fk_party_consent_record_consent_guardian_party_id` FOREIGN KEY (`consent_guardian_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ADD CONSTRAINT `fk_party_consent_record_consent_party_id` FOREIGN KEY (`consent_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ADD CONSTRAINT `fk_party_consent_record_party_document_id` FOREIGN KEY (`party_document_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party_document`(`party_document_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ADD CONSTRAINT `fk_party_consent_record_prior_consent_record_id` FOREIGN KEY (`prior_consent_record_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`consent_record`(`consent_record_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ADD CONSTRAINT `fk_party_consent_record_role_id` FOREIGN KEY (`role_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`role`(`role_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ADD CONSTRAINT `fk_party_merge_event_merge_approved_by_party_id` FOREIGN KEY (`merge_approved_by_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ADD CONSTRAINT `fk_party_merge_event_merge_reversed_by_party_id` FOREIGN KEY (`merge_reversed_by_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ADD CONSTRAINT `fk_party_merge_event_merge_survivor_party_id` FOREIGN KEY (`merge_survivor_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ADD CONSTRAINT `fk_party_merge_event_primary_merged_party_id` FOREIGN KEY (`primary_merged_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ADD CONSTRAINT `fk_party_segment_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ADD CONSTRAINT `fk_party_party_document_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ADD CONSTRAINT `fk_party_party_document_superseded_by_document_party_document_id` FOREIGN KEY (`superseded_by_document_party_document_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party_document`(`party_document_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ADD CONSTRAINT `fk_party_loss_payee_lender_address_id` FOREIGN KEY (`lender_address_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`address`(`address_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ADD CONSTRAINT `fk_party_loss_payee_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ADD CONSTRAINT `fk_party_license_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` ADD CONSTRAINT `fk_party_household_master_household_id` FOREIGN KEY (`master_household_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`household`(`household_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` ADD CONSTRAINT `fk_party_household_primary_address_id` FOREIGN KEY (`primary_address_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`address`(`address_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` ADD CONSTRAINT `fk_party_household_primary_contact_party_id` FOREIGN KEY (`primary_contact_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ADD CONSTRAINT `fk_party_party_group_parent_group_id` FOREIGN KEY (`parent_group_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party_group`(`party_group_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ADD CONSTRAINT `fk_party_party_group_primary_contact_party_id` FOREIGN KEY (`primary_contact_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`party` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`party` SET TAGS ('dbx_domain' = 'party');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` SET TAGS ('dbx_subdomain' = 'identity_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `master_party_id` SET TAGS ('dbx_business_glossary_term' = 'Master Party Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `address_line1` SET TAGS ('dbx_business_glossary_term' = 'Primary Address Line 1');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `address_line1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `address_line2` SET TAGS ('dbx_business_glossary_term' = 'Primary Address Line 2');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `address_line2` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'Primary Address City');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `clue_report_date` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Loss Underwriting Exchange (CLUE) Report Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `credit_score` SET TAGS ('dbx_business_glossary_term' = 'Insurance Credit Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `credit_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `credit_score_date` SET TAGS ('dbx_business_glossary_term' = 'Insurance Credit Score Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_business_glossary_term' = 'Date of Birth');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `date_of_death` SET TAGS ('dbx_business_glossary_term' = 'Date of Death');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `date_of_death` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `date_of_death` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `date_of_incorporation` SET TAGS ('dbx_business_glossary_term' = 'Date of Incorporation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `do_not_contact_flag` SET TAGS ('dbx_business_glossary_term' = 'Do Not Contact Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `family_name` SET TAGS ('dbx_business_glossary_term' = 'Family Name (Last Name)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `family_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `family_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `fraud_indicator_flag` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `full_name` SET TAGS ('dbx_business_glossary_term' = 'Party Full Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `full_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `full_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `gender` SET TAGS ('dbx_business_glossary_term' = 'Gender');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `gender` SET TAGS ('dbx_value_regex' = 'M|F|X|U');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `gender` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `gender` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `given_name` SET TAGS ('dbx_business_glossary_term' = 'Given Name (First Name)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `given_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `given_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `golden_record_flag` SET TAGS ('dbx_business_glossary_term' = 'Golden Record Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `kyc_status` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `kyc_status` SET TAGS ('dbx_value_regex' = 'PENDING|VERIFIED|FAILED|EXEMPT|REVIEW');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `kyc_verified_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Verification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `legal_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `legal_entity_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `legal_entity_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `marital_status` SET TAGS ('dbx_business_glossary_term' = 'Marital Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `marital_status` SET TAGS ('dbx_value_regex' = 'SINGLE|MARRIED|DIVORCED|WIDOWED|SEPARATED|UNKNOWN');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `marital_status` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `marital_status` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System (NAICS) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `naics_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2,6}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `ofac_match_flag` SET TAGS ('dbx_business_glossary_term' = 'Office of Foreign Assets Control (OFAC) Match Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `ofac_screened_date` SET TAGS ('dbx_business_glossary_term' = 'Office of Foreign Assets Control (OFAC) Screened Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `organization_type` SET TAGS ('dbx_business_glossary_term' = 'Organization Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `party_status` SET TAGS ('dbx_business_glossary_term' = 'Party Lifecycle Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `party_status` SET TAGS ('dbx_value_regex' = 'ACTIVE|INACTIVE|DECEASED|MERGED|SUSPENDED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `party_type` SET TAGS ('dbx_business_glossary_term' = 'Party Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `party_type` SET TAGS ('dbx_value_regex' = 'INDIVIDUAL|ORGANIZATION');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code (ZIP Code)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `postal_code` SET TAGS ('dbx_value_regex' = '^d{5}(-d{4})?$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `preferred_contact_method` SET TAGS ('dbx_business_glossary_term' = 'Preferred Contact Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `preferred_contact_method` SET TAGS ('dbx_value_regex' = 'EMAIL|PHONE|MAIL|TEXT|PORTAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `preferred_language` SET TAGS ('dbx_business_glossary_term' = 'Preferred Language');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `preferred_language` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `primary_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Email Address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `primary_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `primary_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `primary_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `primary_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Phone Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `primary_phone` SET TAGS ('dbx_value_regex' = '^+?[1-9]d{1,14}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `primary_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `primary_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `privacy_opt_out_flag` SET TAGS ('dbx_business_glossary_term' = 'Privacy Opt-Out Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification (SIC) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `sic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `source_system_party_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Party Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `state_of_incorporation` SET TAGS ('dbx_business_glossary_term' = 'State of Incorporation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `state_of_incorporation` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `state_of_incorporation` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `tax_id_type` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `tax_id_type` SET TAGS ('dbx_value_regex' = 'SSN|FEIN|ITIN|EIN|OTHER');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `tax_id_type` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `tax_id_type` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party` ALTER COLUMN `years_in_business` SET TAGS ('dbx_business_glossary_term' = 'Years in Business');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` SET TAGS ('dbx_subdomain' = 'identity_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `role_id` SET TAGS ('dbx_business_glossary_term' = 'Party Role ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `commission_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `acord_role_code` SET TAGS ('dbx_business_glossary_term' = 'ACORD Role Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `assignment_reason` SET TAGS ('dbx_business_glossary_term' = 'Role Assignment Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `consent_obtained_date` SET TAGS ('dbx_business_glossary_term' = 'Consent Obtained Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `do_not_contact_flag` SET TAGS ('dbx_business_glossary_term' = 'Do Not Contact Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Role Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Role Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `fraud_score` SET TAGS ('dbx_business_glossary_term' = 'Fraud Risk Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `fraud_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `guardian_flag` SET TAGS ('dbx_business_glossary_term' = 'Legal Guardian Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `interest_type_code` SET TAGS ('dbx_business_glossary_term' = 'Insurable Interest Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `interest_type_code` SET TAGS ('dbx_value_regex' = 'OWNER|MORTGAGEE|LOSS_PAYEE|LIENHOLDER|LESSOR|TRUSTEE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `is_consent_required` SET TAGS ('dbx_business_glossary_term' = 'Consent Required Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `is_primary_role` SET TAGS ('dbx_business_glossary_term' = 'Is Primary Role Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `kyc_verified` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Verified Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `kyc_verified_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Verification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `language_preference` SET TAGS ('dbx_business_glossary_term' = 'Language Preference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `language_preference` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `litigation_flag` SET TAGS ('dbx_business_glossary_term' = 'Litigation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Role Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `notification_preference` SET TAGS ('dbx_business_glossary_term' = 'Notification Preference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `notification_preference` SET TAGS ('dbx_value_regex' = 'EMAIL|MAIL|PHONE|PORTAL|NONE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `ofac_match_flag` SET TAGS ('dbx_business_glossary_term' = 'OFAC Match Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `ofac_screen_date` SET TAGS ('dbx_business_glossary_term' = 'OFAC Screen Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `ofac_screened` SET TAGS ('dbx_business_glossary_term' = 'OFAC Screened Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `power_of_attorney_flag` SET TAGS ('dbx_business_glossary_term' = 'Power of Attorney Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `relationship_to_insured` SET TAGS ('dbx_business_glossary_term' = 'Relationship to Named Insured');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `represented_by_counsel` SET TAGS ('dbx_business_glossary_term' = 'Represented by Counsel Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `role_status` SET TAGS ('dbx_business_glossary_term' = 'Role Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `role_status` SET TAGS ('dbx_value_regex' = 'ACTIVE|INACTIVE|PENDING|SUSPENDED|TERMINATED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Role Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `siu_referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Special Investigations Unit (SIU) Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `source_system_role_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Role ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `subtype_code` SET TAGS ('dbx_business_glossary_term' = 'Role Subtype Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `subtype_code` SET TAGS ('dbx_value_regex' = 'FIRST_PARTY|THIRD_PARTY|PRIMARY|SECONDARY|CONTINGENT');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `tax_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Tax Reporting Required Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Role Termination Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `type_code` SET TAGS ('dbx_business_glossary_term' = 'Role Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `w9_on_file` SET TAGS ('dbx_business_glossary_term' = 'W-9 On File Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ALTER COLUMN `w9_received_date` SET TAGS ('dbx_business_glossary_term' = 'W-9 Received Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` SET TAGS ('dbx_subdomain' = 'identity_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `individual_id` SET TAGS ('dbx_business_glossary_term' = 'Individual ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `birth_date` SET TAGS ('dbx_business_glossary_term' = 'Date of Birth (DOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `birth_date` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `birth_date` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `citizenship_country_code` SET TAGS ('dbx_business_glossary_term' = 'Citizenship Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `citizenship_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `citizenship_country_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `citizenship_country_code` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `clue_consent_flag` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Loss Underwriting Exchange (CLUE) Consent Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `communication_preference` SET TAGS ('dbx_business_glossary_term' = 'Communication Preference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `communication_preference` SET TAGS ('dbx_value_regex' = 'email|mail|phone|text|portal');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `credit_score` SET TAGS ('dbx_business_glossary_term' = 'Insurance Credit Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `credit_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `credit_score` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `credit_score_date` SET TAGS ('dbx_business_glossary_term' = 'Insurance Credit Score Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `credit_score_source` SET TAGS ('dbx_business_glossary_term' = 'Insurance Credit Score Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `credit_score_source` SET TAGS ('dbx_value_regex' = 'LexisNexis|Equifax|Experian|TransUnion|FICO|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `deceased_date` SET TAGS ('dbx_business_glossary_term' = 'Deceased Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `deceased_date` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `deceased_date` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `do_not_contact_flag` SET TAGS ('dbx_business_glossary_term' = 'Do Not Contact Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `drivers_license_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Driver License Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `drivers_license_expiry_date` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `drivers_license_number` SET TAGS ('dbx_business_glossary_term' = 'Driver License Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `drivers_license_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `drivers_license_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `drivers_license_state` SET TAGS ('dbx_business_glossary_term' = 'Driver License Issuing State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `drivers_license_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `drivers_license_state` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `employer_name` SET TAGS ('dbx_business_glossary_term' = 'Employer Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `employer_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `employer_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `first_name` SET TAGS ('dbx_business_glossary_term' = 'First Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `fraud_indicator_flag` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `fraud_indicator_flag` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `gender_code` SET TAGS ('dbx_business_glossary_term' = 'Gender Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `gender_code` SET TAGS ('dbx_value_regex' = 'M|F|X|U');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `gender_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `gender_code` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `golden_record_flag` SET TAGS ('dbx_business_glossary_term' = 'Golden Record Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `kyc_status` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `kyc_status` SET TAGS ('dbx_value_regex' = 'pending|verified|failed|exempt');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `kyc_verified_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Verification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `last_name` SET TAGS ('dbx_business_glossary_term' = 'Last Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `marital_status_code` SET TAGS ('dbx_business_glossary_term' = 'Marital Status Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `marital_status_code` SET TAGS ('dbx_value_regex' = 'S|M|D|W|P');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `marital_status_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `marital_status_code` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `middle_name` SET TAGS ('dbx_business_glossary_term' = 'Middle Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `middle_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `middle_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `mvr_consent_flag` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Consent Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `mvr_order_date` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Order Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `name_prefix` SET TAGS ('dbx_business_glossary_term' = 'Name Prefix');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `name_prefix` SET TAGS ('dbx_value_regex' = 'Mr.|Mrs.|Ms.|Dr.|Prof.');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `name_prefix` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `name_prefix` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `name_suffix` SET TAGS ('dbx_business_glossary_term' = 'Name Suffix');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `name_suffix` SET TAGS ('dbx_value_regex' = 'Jr.|Sr.|II|III|IV|Esq.');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `name_suffix` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `name_suffix` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `occupation_code` SET TAGS ('dbx_business_glossary_term' = 'Occupation Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `occupation_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `occupation_description` SET TAGS ('dbx_business_glossary_term' = 'Occupation Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `occupation_description` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `ofac_screen_date` SET TAGS ('dbx_business_glossary_term' = 'Office of Foreign Assets Control (OFAC) Screen Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `ofac_screened_flag` SET TAGS ('dbx_business_glossary_term' = 'Office of Foreign Assets Control (OFAC) Screened Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `preferred_language_code` SET TAGS ('dbx_business_glossary_term' = 'Preferred Language Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `preferred_language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_business_glossary_term' = 'Prior Insurance Carrier Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `prior_policy_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `residency_country_code` SET TAGS ('dbx_business_glossary_term' = 'Residency Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `residency_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `residency_country_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `residency_country_code` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `residency_state_code` SET TAGS ('dbx_business_glossary_term' = 'Residency State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `residency_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `residency_state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `siu_referral_date` SET TAGS ('dbx_business_glossary_term' = 'Special Investigations Unit (SIU) Referral Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `siu_referral_date` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'PAS|CLAIMS|BILLING|MDM|PRODUCER|MANUAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `source_system_person_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Person ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `ssn_hash` SET TAGS ('dbx_business_glossary_term' = 'Social Security Number (SSN) Hash');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `ssn_hash` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `ssn_hash` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `ssn_last_four` SET TAGS ('dbx_business_glossary_term' = 'Social Security Number (SSN) Last Four Digits');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `ssn_last_four` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `ssn_last_four` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `ssn_last_four` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`individual` ALTER COLUMN `years_continuously_insured` SET TAGS ('dbx_business_glossary_term' = 'Years Continuously Insured');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` SET TAGS ('dbx_subdomain' = 'identity_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Organization ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `mailing_address_id` SET TAGS ('dbx_business_glossary_term' = 'Mailing Address Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `mailing_address_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `mailing_address_id` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `parent_organization_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Organization ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `primary_ultimate_parent_organization_id` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Parent Organization ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `annual_payroll` SET TAGS ('dbx_business_glossary_term' = 'Annual Payroll');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `annual_payroll` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `annual_revenue` SET TAGS ('dbx_business_glossary_term' = 'Annual Revenue');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `annual_revenue` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `credit_score` SET TAGS ('dbx_business_glossary_term' = 'Commercial Credit Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `credit_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `credit_score_source` SET TAGS ('dbx_business_glossary_term' = 'Credit Score Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `credit_score_source` SET TAGS ('dbx_value_regex' = 'dun_bradstreet|experian|equifax|fico|internal');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `dba_name` SET TAGS ('dbx_business_glossary_term' = 'Doing Business As (DBA) Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `dba_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `duns_number` SET TAGS ('dbx_business_glossary_term' = 'Dun & Bradstreet (D&B) DUNS Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `duns_number` SET TAGS ('dbx_value_regex' = '^[0-9]{9}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `employee_count` SET TAGS ('dbx_business_glossary_term' = 'Employee Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `entity_type` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `fein` SET TAGS ('dbx_business_glossary_term' = 'Federal Employer Identification Number (FEIN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `fein` SET TAGS ('dbx_value_regex' = '^[0-9]{2}-[0-9]{7}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `fein` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `fein` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `financial_statement_date` SET TAGS ('dbx_business_glossary_term' = 'Financial Statement Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `fraud_indicator` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `incorporation_country` SET TAGS ('dbx_business_glossary_term' = 'Country of Incorporation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `incorporation_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `incorporation_country` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `incorporation_date` SET TAGS ('dbx_business_glossary_term' = 'Date of Incorporation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `incorporation_state` SET TAGS ('dbx_business_glossary_term' = 'State of Incorporation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `incorporation_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `incorporation_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `kyc_status` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `kyc_status` SET TAGS ('dbx_value_regex' = 'pending|verified|failed|exempt');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `kyc_verified_date` SET TAGS ('dbx_business_glossary_term' = 'KYC Verification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `legal_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `legal_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `naic_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System (NAICS) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `naics_code` SET TAGS ('dbx_value_regex' = '^[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `naics_description` SET TAGS ('dbx_business_glossary_term' = 'NAICS Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `ofac_screen_date` SET TAGS ('dbx_business_glossary_term' = 'OFAC Screen Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `ofac_screened` SET TAGS ('dbx_business_glossary_term' = 'OFAC Screened Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `preferred_language` SET TAGS ('dbx_business_glossary_term' = 'Preferred Language');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `preferred_language` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `primary_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Email Address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `primary_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `primary_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `primary_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `primary_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Phone Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `primary_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9-s().]{7,20}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `primary_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `primary_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `publicly_traded` SET TAGS ('dbx_business_glossary_term' = 'Publicly Traded Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `revenue_currency` SET TAGS ('dbx_business_glossary_term' = 'Revenue Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `revenue_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification (SIC) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `sic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'pas|cms|billing|agency_mgmt|mdm|reinsurance');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `source_system_ref_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `stock_ticker` SET TAGS ('dbx_business_glossary_term' = 'Stock Ticker Symbol');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `stock_ticker` SET TAGS ('dbx_value_regex' = '^[A-Z]{1,5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `website_url` SET TAGS ('dbx_business_glossary_term' = 'Website URL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ALTER COLUMN `years_in_business` SET TAGS ('dbx_business_glossary_term' = 'Years in Business');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` SET TAGS ('dbx_subdomain' = 'identity_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `address_id` SET TAGS ('dbx_business_glossary_term' = 'Address ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `address_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `address_id` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `flood_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `acord_address_type_code` SET TAGS ('dbx_business_glossary_term' = 'Association for Cooperative Operations Research and Development (ACORD) Address Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `acord_address_type_code` SET TAGS ('dbx_pii_category' = 'address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `address_status` SET TAGS ('dbx_business_glossary_term' = 'Address Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `address_status` SET TAGS ('dbx_value_regex' = 'active|inactive|unverified|returned_mail|do_not_mail');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `address_status` SET TAGS ('dbx_classification' = 'restricted');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `address_status` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `address_status` SET TAGS ('dbx_pii_category' = 'address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `address_type` SET TAGS ('dbx_business_glossary_term' = 'Address Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `address_type` SET TAGS ('dbx_pii_category' = 'address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `care_of_name` SET TAGS ('dbx_business_glossary_term' = 'Care Of (C/O) Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `care_of_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `care_of_name` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `census_tract` SET TAGS ('dbx_business_glossary_term' = 'Census Tract');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'City');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `coastal_indicator` SET TAGS ('dbx_business_glossary_term' = 'Coastal Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `congressional_district` SET TAGS ('dbx_business_glossary_term' = 'Congressional District');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `county` SET TAGS ('dbx_business_glossary_term' = 'County');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `distance_to_coast_miles` SET TAGS ('dbx_business_glossary_term' = 'Distance to Coast (Miles)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `distance_to_fire_station_miles` SET TAGS ('dbx_business_glossary_term' = 'Distance to Fire Station (Miles)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `do_not_mail_indicator` SET TAGS ('dbx_business_glossary_term' = 'Do Not Mail Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `dpv_confirmation_code` SET TAGS ('dbx_business_glossary_term' = 'Delivery Point Validation (DPV) Confirmation Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `dpv_confirmation_code` SET TAGS ('dbx_value_regex' = 'Y|S|D|N');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Address Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Address Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `fips_code` SET TAGS ('dbx_business_glossary_term' = 'Federal Information Processing Standards (FIPS) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `fips_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `fire_protection_class` SET TAGS ('dbx_business_glossary_term' = 'Fire Protection Class (FPC)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `geocode_quality` SET TAGS ('dbx_business_glossary_term' = 'Geocode Quality');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `geocode_source` SET TAGS ('dbx_business_glossary_term' = 'Geocode Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `iso_territory_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'Latitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `line1` SET TAGS ('dbx_business_glossary_term' = 'Address Line 1');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `line1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `line2` SET TAGS ('dbx_business_glossary_term' = 'Address Line 2');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `line2` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'Longitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `po_box` SET TAGS ('dbx_business_glossary_term' = 'Post Office (PO) Box');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `po_box` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `po_box` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `primary_indicator` SET TAGS ('dbx_business_glossary_term' = 'Primary Address Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `province` SET TAGS ('dbx_business_glossary_term' = 'Province');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `seasonal_indicator` SET TAGS ('dbx_business_glossary_term' = 'Seasonal Address Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `source_system_address_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Address ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `source_system_address_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `source_system_address_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `time_zone` SET TAGS ('dbx_business_glossary_term' = 'Time Zone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `usps_standardized_indicator` SET TAGS ('dbx_business_glossary_term' = 'USPS Standardized Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `wind_pool_indicator` SET TAGS ('dbx_business_glossary_term' = 'Wind Pool Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `zip_code` SET TAGS ('dbx_business_glossary_term' = 'ZIP Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `zip_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `zip_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `zip_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `zip_plus4` SET TAGS ('dbx_business_glossary_term' = 'ZIP+4 Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `zip_plus4` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `zip_plus4` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ALTER COLUMN `zip_plus4` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` SET TAGS ('dbx_subdomain' = 'identity_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `contact_id` SET TAGS ('dbx_business_glossary_term' = 'Contact ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `acord_contact_type_code` SET TAGS ('dbx_business_glossary_term' = 'ACORD Contact Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `best_contact_time_end` SET TAGS ('dbx_business_glossary_term' = 'Best Contact Time End');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `best_contact_time_end` SET TAGS ('dbx_value_regex' = '^([01]d|2[0-3]):[0-5]d$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `best_contact_time_start` SET TAGS ('dbx_business_glossary_term' = 'Best Contact Time Start');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `best_contact_time_start` SET TAGS ('dbx_value_regex' = '^([01]d|2[0-3]):[0-5]d$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `consent_source` SET TAGS ('dbx_business_glossary_term' = 'Consent Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `consent_source` SET TAGS ('dbx_value_regex' = 'web_form|agent_recorded|ivr|written|email_reply|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `contact_status` SET TAGS ('dbx_business_glossary_term' = 'Contact Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `contact_status` SET TAGS ('dbx_value_regex' = 'active|inactive|unverified|bounced|opted_out');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `contact_type` SET TAGS ('dbx_business_glossary_term' = 'Contact Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `contact_type` SET TAGS ('dbx_value_regex' = 'phone|email|fax|sms|postal_address|web_portal');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `do_not_contact_flag` SET TAGS ('dbx_business_glossary_term' = 'Do Not Contact Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `do_not_contact_reason` SET TAGS ('dbx_business_glossary_term' = 'Do Not Contact Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `do_not_contact_reason` SET TAGS ('dbx_value_regex' = 'legal_hold|regulatory_order|party_request|deceased|fraud_flag|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'Email Address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `email_bounce_code` SET TAGS ('dbx_business_glossary_term' = 'Email Bounce Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `email_bounce_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `email_bounce_code` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `is_preferred` SET TAGS ('dbx_business_glossary_term' = 'Preferred Contact Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `is_primary` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `is_verified_mobile` SET TAGS ('dbx_business_glossary_term' = 'Verified Mobile Number Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `is_verified_mobile` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `is_verified_mobile` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `is_wireless` SET TAGS ('dbx_business_glossary_term' = 'Wireless Number Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `language_preference` SET TAGS ('dbx_business_glossary_term' = 'Language Preference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `language_preference` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `last_contact_date` SET TAGS ('dbx_business_glossary_term' = 'Last Contact Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `last_contact_outcome` SET TAGS ('dbx_business_glossary_term' = 'Last Contact Outcome');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `last_contact_outcome` SET TAGS ('dbx_value_regex' = 'reached|no_answer|voicemail|bounced|refused|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Contact Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `opt_in_flag` SET TAGS ('dbx_business_glossary_term' = 'Opt-In Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `opt_in_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Opt-In Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `opt_out_flag` SET TAGS ('dbx_business_glossary_term' = 'Opt-Out Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `opt_out_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Opt-Out Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `phone_extension` SET TAGS ('dbx_business_glossary_term' = 'Phone Extension');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `phone_extension` SET TAGS ('dbx_value_regex' = '^d{1,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `phone_extension` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `phone_extension` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `phone_number` SET TAGS ('dbx_business_glossary_term' = 'Phone Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `phone_number` SET TAGS ('dbx_value_regex' = '^+?[1-9]d{1,14}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `source_system_contact_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Contact ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `subtype` SET TAGS ('dbx_business_glossary_term' = 'Contact Subtype');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `time_zone` SET TAGS ('dbx_business_glossary_term' = 'Time Zone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `usage_purpose` SET TAGS ('dbx_business_glossary_term' = 'Contact Usage Purpose');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `value` SET TAGS ('dbx_business_glossary_term' = 'Contact Value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `value` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `value` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Contact Verification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `verification_method` SET TAGS ('dbx_business_glossary_term' = 'Contact Verification Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `verification_method` SET TAGS ('dbx_value_regex' = 'carrier_lookup|email_ping|agent_confirmed|document|ivr|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `verification_status` SET TAGS ('dbx_business_glossary_term' = 'Contact Verification Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`contact` ALTER COLUMN `verification_status` SET TAGS ('dbx_value_regex' = 'verified|unverified|failed|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` SET TAGS ('dbx_subdomain' = 'identity_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `identifier_id` SET TAGS ('dbx_business_glossary_term' = 'Identifier ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `identifier_mdm_golden_party_id` SET TAGS ('dbx_business_glossary_term' = 'Master Data Management (MDM) Golden Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `identifier_party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `identifier_pas_party_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Administration System (PAS) Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `clue_report_ordered` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Loss Underwriting Exchange (CLUE) Report Ordered Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `dedup_match_key` SET TAGS ('dbx_business_glossary_term' = 'Deduplication Match Key');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `fraud_indicator` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `identifier_status` SET TAGS ('dbx_business_glossary_term' = 'Identifier Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `identifier_status` SET TAGS ('dbx_value_regex' = 'active|inactive|expired|revoked|pending_verification');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `is_masked` SET TAGS ('dbx_business_glossary_term' = 'Is Masked Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `is_primary` SET TAGS ('dbx_business_glossary_term' = 'Is Primary Identifier Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `issuing_authority` SET TAGS ('dbx_business_glossary_term' = 'Issuing Authority');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `issuing_country_code` SET TAGS ('dbx_business_glossary_term' = 'Issuing Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `issuing_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `issuing_country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `issuing_state_code` SET TAGS ('dbx_business_glossary_term' = 'Issuing State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `issuing_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `issuing_state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `kyc_status` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `kyc_status` SET TAGS ('dbx_value_regex' = 'passed|failed|pending|not_required|escalated');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `license_class` SET TAGS ('dbx_business_glossary_term' = 'License Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `license_number` SET TAGS ('dbx_business_glossary_term' = 'License Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `license_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `license_state_code` SET TAGS ('dbx_business_glossary_term' = 'License State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `license_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `license_state_code` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `masked_value` SET TAGS ('dbx_business_glossary_term' = 'Masked Identifier Value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `masked_value` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `masked_value` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `mvr_order_date` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Order Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `mvr_ordered` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Ordered Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Identifier Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `npn` SET TAGS ('dbx_business_glossary_term' = 'National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `npn` SET TAGS ('dbx_value_regex' = '^[0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `ofac_check_status` SET TAGS ('dbx_business_glossary_term' = 'Office of Foreign Assets Control (OFAC) Check Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `ofac_check_status` SET TAGS ('dbx_value_regex' = 'cleared|flagged|pending|not_checked');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `source_system_party_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Party Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `tin_match_status` SET TAGS ('dbx_business_glossary_term' = 'Taxpayer Identification Number (TIN) Match Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `tin_match_status` SET TAGS ('dbx_value_regex' = 'matched|not_matched|pending|not_checked');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `tin_match_status` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `tin_match_status` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `tin_match_status` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `tin_type` SET TAGS ('dbx_business_glossary_term' = 'Taxpayer Identification Number (TIN) Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `tin_type` SET TAGS ('dbx_value_regex' = 'SSN|FEIN|ITIN|EIN');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `tin_type` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `tin_type` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `tin_type` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `type_code` SET TAGS ('dbx_business_glossary_term' = 'Identifier Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `value` SET TAGS ('dbx_business_glossary_term' = 'Identifier Value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `value` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `value` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Verification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `verification_source` SET TAGS ('dbx_business_glossary_term' = 'Verification Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `verification_status` SET TAGS ('dbx_business_glossary_term' = 'Verification Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`identifier` ALTER COLUMN `verification_status` SET TAGS ('dbx_value_regex' = 'verified|unverified|failed|not_required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` SET TAGS ('dbx_subdomain' = 'identity_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `relationship_id` SET TAGS ('dbx_business_glossary_term' = 'Party Relationship ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `from_party_id` SET TAGS ('dbx_business_glossary_term' = 'From Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `party_group_id` SET TAGS ('dbx_business_glossary_term' = 'Party Group ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `household_id` SET TAGS ('dbx_business_glossary_term' = 'Household ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `to_party_id` SET TAGS ('dbx_business_glossary_term' = 'To Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `relationship_category` SET TAGS ('dbx_business_glossary_term' = 'Party Relationship Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `relationship_category` SET TAGS ('dbx_value_regex' = 'PERSONAL|COMMERCIAL|LEGAL|FINANCIAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `control_flag` SET TAGS ('dbx_business_glossary_term' = 'Controlling Interest Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Relationship Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Relationship Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `fraud_indicator_flag` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `is_bidirectional` SET TAGS ('dbx_business_glossary_term' = 'Bidirectional Relationship Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `is_primary` SET TAGS ('dbx_business_glossary_term' = 'Primary Party Relationship Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `jurisdiction_country_code` SET TAGS ('dbx_business_glossary_term' = 'Relationship Jurisdiction Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `jurisdiction_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `jurisdiction_country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `jurisdiction_state_code` SET TAGS ('dbx_business_glossary_term' = 'Relationship Jurisdiction State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `jurisdiction_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `jurisdiction_state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `legal_basis_code` SET TAGS ('dbx_business_glossary_term' = 'Relationship Legal Basis Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `legal_basis_code` SET TAGS ('dbx_value_regex' = 'MARRIAGE|ADOPTION|CONTRACT|COURT_ORDER|STATUTE|CORPORATE_FILING');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `legal_basis_date` SET TAGS ('dbx_business_glossary_term' = 'Relationship Legal Basis Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `legal_basis_reference` SET TAGS ('dbx_business_glossary_term' = 'Relationship Legal Basis Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `legal_basis_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Relationship Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `relationship_status` SET TAGS ('dbx_business_glossary_term' = 'Party Relationship Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `relationship_status` SET TAGS ('dbx_value_regex' = 'ACTIVE|INACTIVE|PENDING|TERMINATED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `role_from` SET TAGS ('dbx_business_glossary_term' = 'From-Party Relationship Role');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `role_from` SET TAGS ('dbx_value_regex' = 'POLICYHOLDER|NAMED_INSURED|PARENT|EMPLOYER|GUARANTOR|PRODUCER');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `role_to` SET TAGS ('dbx_business_glossary_term' = 'To-Party Relationship Role');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `role_to` SET TAGS ('dbx_value_regex' = 'ADDITIONAL_INSURED|NAMED_INSURED|SUBSIDIARY|EMPLOYEE|BENEFICIARY|SUB_PRODUCER');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'MDM|PAS|CLAIMS|BILLING|PRODUCER_MGMT');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `source_system_relationship_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Relationship ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Relationship Termination Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `termination_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Relationship Termination Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `termination_reason_code` SET TAGS ('dbx_value_regex' = 'DIVORCE|DISSOLUTION|DECEASED|POLICY_CANCEL|MUTUAL_AGREEMENT|OTHER');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `type_code` SET TAGS ('dbx_business_glossary_term' = 'Party Relationship Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `type_code` SET TAGS ('dbx_value_regex' = 'SPOUSE|PARENT_SUBSIDIARY|EMPLOYER_EMPLOYEE|NAMED_INSURED_ADDITIONAL|GUARANTOR_BENEFICIARY|OTHER');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `uw_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Impact Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Relationship Verification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `verification_status` SET TAGS ('dbx_business_glossary_term' = 'Relationship Verification Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `verification_status` SET TAGS ('dbx_value_regex' = 'UNVERIFIED|PENDING|VERIFIED|REJECTED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`relationship` ALTER COLUMN `verified_by` SET TAGS ('dbx_business_glossary_term' = 'Relationship Verified By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` SET TAGS ('dbx_subdomain' = 'compliance_verification');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `kyc_verification_id` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Verification ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `jurisdiction_geography_id` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `kyc_analyst_party_id` SET TAGS ('dbx_business_glossary_term' = 'KYC Analyst ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `kyc_override_approver_party_id` SET TAGS ('dbx_business_glossary_term' = 'KYC Override Approver ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `kyc_party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `adverse_media_summary` SET TAGS ('dbx_business_glossary_term' = 'Adverse Media Summary');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `adverse_media_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `analyst_decision` SET TAGS ('dbx_business_glossary_term' = 'KYC Analyst Decision');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `analyst_decision` SET TAGS ('dbx_value_regex' = 'APPROVE|REJECT|ESCALATE|DEFER');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `analyst_notes` SET TAGS ('dbx_business_glossary_term' = 'KYC Analyst Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `analyst_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `beneficial_owner_count` SET TAGS ('dbx_business_glossary_term' = 'Beneficial Owner Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `beneficial_owner_verified` SET TAGS ('dbx_business_glossary_term' = 'Beneficial Owner Verified Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `data_source_code` SET TAGS ('dbx_business_glossary_term' = 'KYC Data Source Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `due_diligence_level` SET TAGS ('dbx_business_glossary_term' = 'Customer Due Diligence (CDD) Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `due_diligence_level` SET TAGS ('dbx_value_regex' = 'SIMPLIFIED|STANDARD|ENHANCED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `escalation_reason` SET TAGS ('dbx_business_glossary_term' = 'KYC Escalation Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'KYC Verification Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `identity_document_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Identity Document Expiry Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `identity_document_issuing_country` SET TAGS ('dbx_business_glossary_term' = 'Identity Document Issuing Country');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `identity_document_issuing_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `identity_document_issuing_country` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `identity_document_number` SET TAGS ('dbx_business_glossary_term' = 'Identity Document Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `identity_document_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `identity_document_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `identity_document_type` SET TAGS ('dbx_business_glossary_term' = 'Identity Document Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `identity_document_type` SET TAGS ('dbx_value_regex' = 'PASSPORT|DRIVERS_LICENSE|NATIONAL_ID|STATE_ID|MILITARY_ID|FEIN');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `is_adverse_media` SET TAGS ('dbx_business_glossary_term' = 'Adverse Media Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `is_pep` SET TAGS ('dbx_business_glossary_term' = 'Politically Exposed Person (PEP) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'KYC Next Scheduled Review Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `ofac_hit_reference` SET TAGS ('dbx_business_glossary_term' = 'Office of Foreign Assets Control (OFAC) Hit Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `ofac_hit_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `ofac_screening_status` SET TAGS ('dbx_business_glossary_term' = 'Office of Foreign Assets Control (OFAC) Screening Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `ofac_screening_status` SET TAGS ('dbx_value_regex' = 'CLEAR|HIT|POTENTIAL_HIT|NOT_SCREENED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `override_reason` SET TAGS ('dbx_business_glossary_term' = 'KYC Override Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `override_reason` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `pep_category` SET TAGS ('dbx_business_glossary_term' = 'Politically Exposed Person (PEP) Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `pep_category` SET TAGS ('dbx_value_regex' = 'DOMESTIC|FOREIGN|INTERNATIONAL_ORGANIZATION|CLOSE_ASSOCIATE|FAMILY_MEMBER');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'KYC Analyst Review Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `risk_tier` SET TAGS ('dbx_business_glossary_term' = 'KYC Risk Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `risk_tier` SET TAGS ('dbx_value_regex' = 'LOW|MEDIUM|HIGH|VERY_HIGH');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `sar_filed` SET TAGS ('dbx_business_glossary_term' = 'Suspicious Activity Report (SAR) Filed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `sar_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Suspicious Activity Report (SAR) Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `sar_reference_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `siu_case_number` SET TAGS ('dbx_business_glossary_term' = 'Special Investigations Unit (SIU) Case Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `siu_case_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `siu_referral` SET TAGS ('dbx_business_glossary_term' = 'Special Investigations Unit (SIU) Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `third_party_provider` SET TAGS ('dbx_business_glossary_term' = 'Third-Party KYC Provider');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `third_party_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Provider Reference ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `trigger_event` SET TAGS ('dbx_business_glossary_term' = 'KYC Trigger Event');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'KYC Verification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `verification_method` SET TAGS ('dbx_business_glossary_term' = 'KYC Verification Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `verification_method` SET TAGS ('dbx_value_regex' = 'DOCUMENT_REVIEW|DATABASE_LOOKUP|THIRD_PARTY_SERVICE|MANUAL_REVIEW|BIOMETRIC|CREDIT_BUREAU');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `verification_result` SET TAGS ('dbx_business_glossary_term' = 'KYC Verification Result');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `verification_result` SET TAGS ('dbx_value_regex' = 'CLEAR|MATCH|NO_MATCH|PARTIAL_MATCH|INCONCLUSIVE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `verification_status` SET TAGS ('dbx_business_glossary_term' = 'KYC Verification Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `verification_status` SET TAGS ('dbx_value_regex' = 'PASS|FAIL|REVIEW|PENDING|EXPIRED|WAIVED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `verification_timestamp` SET TAGS ('dbx_business_glossary_term' = 'KYC Verification Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `verification_type` SET TAGS ('dbx_business_glossary_term' = 'KYC Verification Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `verification_type` SET TAGS ('dbx_value_regex' = 'IDENTITY|OFAC_SCREENING|PEP_SCREENING|ADVERSE_MEDIA|ENHANCED_DUE_DILIGENCE|PERIODIC_REVIEW');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `watchlist_hit_detail` SET TAGS ('dbx_business_glossary_term' = 'Watchlist Hit Detail');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `watchlist_hit_detail` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ALTER COLUMN `watchlist_screened` SET TAGS ('dbx_business_glossary_term' = 'Watchlist Screened Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` SET TAGS ('dbx_subdomain' = 'compliance_verification');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_record_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Record ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_guardian_party_id` SET TAGS ('dbx_business_glossary_term' = 'Guardian Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `party_document_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Notice Document ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `prior_consent_record_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Consent Record ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `role_id` SET TAGS ('dbx_business_glossary_term' = 'Party Role ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `agent_npn` SET TAGS ('dbx_business_glossary_term' = 'Agent National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `agent_npn` SET TAGS ('dbx_value_regex' = '^[0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_action` SET TAGS ('dbx_business_glossary_term' = 'Consent Action');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_action` SET TAGS ('dbx_value_regex' = 'granted|revoked|opted_out|renewed|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_channel` SET TAGS ('dbx_business_glossary_term' = 'Consent Channel');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_language` SET TAGS ('dbx_business_glossary_term' = 'Consent Language Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_language` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_method` SET TAGS ('dbx_business_glossary_term' = 'Consent Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_method` SET TAGS ('dbx_value_regex' = 'opt_in|opt_out|double_opt_in|implied|written');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_status` SET TAGS ('dbx_business_glossary_term' = 'Consent Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_status` SET TAGS ('dbx_value_regex' = 'active|inactive|expired|superseded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_text_hash` SET TAGS ('dbx_business_glossary_term' = 'Consent Text Hash');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_text_hash` SET TAGS ('dbx_value_regex' = '^[a-fA-F0-9]{64}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Consent Event Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_type` SET TAGS ('dbx_business_glossary_term' = 'Consent Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_type` SET TAGS ('dbx_value_regex' = 'marketing|electronic_delivery|telematics|credit_pull|mvr_pull|data_sharing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `consent_version` SET TAGS ('dbx_business_glossary_term' = 'Consent Notice Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `credit_pull_permissible_purpose` SET TAGS ('dbx_business_glossary_term' = 'Credit Pull Permissible Purpose');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `credit_pull_permissible_purpose` SET TAGS ('dbx_value_regex' = 'underwriting|rating|renewal|claims|collections');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `data_categories_covered` SET TAGS ('dbx_business_glossary_term' = 'Data Categories Covered');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `data_use_purpose` SET TAGS ('dbx_business_glossary_term' = 'Data Use Purpose');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `device_fingerprint` SET TAGS ('dbx_business_glossary_term' = 'Device Fingerprint');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `device_fingerprint` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `device_fingerprint` SET TAGS ('dbx_pii_device' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `do_not_contact_flag` SET TAGS ('dbx_business_glossary_term' = 'Do Not Contact Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Consent Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `electronic_delivery_format` SET TAGS ('dbx_business_glossary_term' = 'Electronic Delivery Format');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `electronic_delivery_format` SET TAGS ('dbx_value_regex' = 'pdf|html|email|portal|sms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Consent Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `ip_address` SET TAGS ('dbx_business_glossary_term' = 'IP Address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `ip_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `ip_address` SET TAGS ('dbx_pii_ip' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `is_minor` SET TAGS ('dbx_business_glossary_term' = 'Minor Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `jurisdiction_country` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `jurisdiction_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `jurisdiction_country` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `jurisdiction_state` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `jurisdiction_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `jurisdiction_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `mvr_pull_state` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Pull State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `mvr_pull_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `mvr_pull_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Consent Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `opt_out_reason` SET TAGS ('dbx_business_glossary_term' = 'Opt-Out Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `policy_number` SET TAGS ('dbx_business_glossary_term' = 'Policy Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `proof_of_consent_ref` SET TAGS ('dbx_business_glossary_term' = 'Proof of Consent Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `regulatory_basis` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `regulatory_basis` SET TAGS ('dbx_value_regex' = 'GLBA|CCPA|GDPR|FCRA|TCPA|state_doi');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `revocation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Consent Revocation Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `source_transaction_code` SET TAGS ('dbx_business_glossary_term' = 'Source Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `suppression_flag` SET TAGS ('dbx_business_glossary_term' = 'Suppression Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `telematics_program_code` SET TAGS ('dbx_business_glossary_term' = 'Telematics Program ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `third_party_sharing_flag` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Sharing Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `verification_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Consent Verification Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`consent_record` ALTER COLUMN `verified_flag` SET TAGS ('dbx_business_glossary_term' = 'Consent Verified Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` SET TAGS ('dbx_subdomain' = 'compliance_verification');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merge_event_id` SET TAGS ('dbx_business_glossary_term' = 'Merge Event ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merge_approved_by_party_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merge_reversed_by_party_id` SET TAGS ('dbx_business_glossary_term' = 'Reversed By Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merge_survivor_party_id` SET TAGS ('dbx_business_glossary_term' = 'Survivor Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `primary_merged_party_id` SET TAGS ('dbx_business_glossary_term' = 'Merged (Duplicate) Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `affected_billing_account_count` SET TAGS ('dbx_business_glossary_term' = 'Affected Billing Account Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `affected_claim_count` SET TAGS ('dbx_business_glossary_term' = 'Affected Claim Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `affected_policy_count` SET TAGS ('dbx_business_glossary_term' = 'Affected Policy Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `batch_run_code` SET TAGS ('dbx_business_glossary_term' = 'MDM Batch Run ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `conflict_resolution_notes` SET TAGS ('dbx_business_glossary_term' = 'Conflict Resolution Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `data_conflict_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Conflict Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `fraud_indicator_flag` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `kyc_review_completed_flag` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Review Completed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `kyc_review_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Review Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `match_rule_set` SET TAGS ('dbx_business_glossary_term' = 'MDM Match Rule Set');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `match_score` SET TAGS ('dbx_business_glossary_term' = 'MDM Match Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merge_approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Merge Approved Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merge_channel` SET TAGS ('dbx_business_glossary_term' = 'Merge Channel');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merge_channel` SET TAGS ('dbx_value_regex' = 'batch|real_time|api|manual_ui');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merge_executed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Merge Executed Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merge_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Merge Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merge_reason_code` SET TAGS ('dbx_value_regex' = 'duplicate_name_address|duplicate_ssn_fein|duplicate_contact|data_entry_error|system_migration|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merge_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Merge Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merge_request_code` SET TAGS ('dbx_business_glossary_term' = 'Merge Request ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merge_requested_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Merge Requested Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merge_status` SET TAGS ('dbx_business_glossary_term' = 'Merge Event Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merge_status` SET TAGS ('dbx_value_regex' = 'pending|approved|completed|reversed|failed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merge_type` SET TAGS ('dbx_business_glossary_term' = 'Merge Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merge_type` SET TAGS ('dbx_value_regex' = 'manual|automated|system_suggested');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merged_party_pre_merge_status` SET TAGS ('dbx_business_glossary_term' = 'Merged Party Pre-Merge Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `merged_party_pre_merge_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|deceased|unknown');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Merge Event Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `regulatory_notification_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Notification Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `regulatory_notification_sent_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Notification Sent Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `reversal_reason` SET TAGS ('dbx_business_glossary_term' = 'Merge Reversal Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `reversal_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Merge Reversal Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `siu_referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Special Investigations Unit (SIU) Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'MDM|PAS|CLAIMS|BILLING|PRODUCER_MGMT|MANUAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `source_system_merge_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Merge Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `survivor_party_pre_merge_status` SET TAGS ('dbx_business_glossary_term' = 'Survivor Party Pre-Merge Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `survivor_party_pre_merge_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|deceased|unknown');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `survivor_selection_basis` SET TAGS ('dbx_business_glossary_term' = 'Survivor Selection Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `survivor_selection_basis` SET TAGS ('dbx_value_regex' = 'most_recent|most_complete|most_policies|operator_override|system_default');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`merge_event` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` SET TAGS ('dbx_subdomain' = 'compliance_verification');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `segment_id` SET TAGS ('dbx_business_glossary_term' = 'Segment ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `assigned_by` SET TAGS ('dbx_business_glossary_term' = 'Assigned By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `assignment_method` SET TAGS ('dbx_business_glossary_term' = 'Segment Assignment Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `assignment_method` SET TAGS ('dbx_value_regex' = 'automated_rules|manual_override|model_scored|imported');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `assignment_reason` SET TAGS ('dbx_business_glossary_term' = 'Segment Assignment Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `cat_zone` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `cat_zone` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `clue_indicator` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Loss Underwriting Exchange (CLUE) Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `clue_indicator` SET TAGS ('dbx_value_regex' = 'clean|minor_activity|moderate_activity|significant_activity|not_ordered');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `segment_code` SET TAGS ('dbx_business_glossary_term' = 'Segment Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `segment_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,30}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `credit_score_band` SET TAGS ('dbx_business_glossary_term' = 'Credit Score Band');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `credit_score_band` SET TAGS ('dbx_value_regex' = 'exceptional|very_good|good|fair|poor|not_scored');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `credit_score_band` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `distribution_channel` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `distribution_channel` SET TAGS ('dbx_value_regex' = 'independent_agent|captive_agent|direct|broker|digital|affinity');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `employee_count_band` SET TAGS ('dbx_business_glossary_term' = 'Employee Count Band');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `employee_count_band` SET TAGS ('dbx_value_regex' = '1_to_9|10_to_49|50_to_249|250_to_999|1000_plus');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `fraud_indicator` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `fraud_indicator` SET TAGS ('dbx_value_regex' = 'none|watch_list|suspected|confirmed|cleared');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `fraud_indicator` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `kyc_status` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `kyc_status` SET TAGS ('dbx_value_regex' = 'verified|pending|failed|exempt|not_required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `loss_ratio_band` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR) Band');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `loss_ratio_band` SET TAGS ('dbx_value_regex' = 'under_40pct|40_to_60pct|60_to_80pct|80_to_100pct|over_100pct');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `loss_ratio_band` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `market_segment` SET TAGS ('dbx_business_glossary_term' = 'Market Segment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `market_segment` SET TAGS ('dbx_value_regex' = 'mass_market|middle_market|large_account|small_business|micro_business');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `mvr_indicator` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `mvr_indicator` SET TAGS ('dbx_value_regex' = 'clean|minor_violations|major_violations|dui|not_ordered');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System (NAICS) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `naics_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2,6}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `segment_name` SET TAGS ('dbx_business_glossary_term' = 'Segment Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `segment_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `party_type_at_assignment` SET TAGS ('dbx_business_glossary_term' = 'Party Type at Assignment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `party_type_at_assignment` SET TAGS ('dbx_value_regex' = 'individual|organization');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `policy_count_band` SET TAGS ('dbx_business_glossary_term' = 'Policy Count Band');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `policy_count_band` SET TAGS ('dbx_value_regex' = 'single_policy|2_to_3|4_to_6|7_plus');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `preferred_program_code` SET TAGS ('dbx_business_glossary_term' = 'Preferred Program Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `preferred_program_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `profitability_tier` SET TAGS ('dbx_business_glossary_term' = 'Profitability Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `profitability_tier` SET TAGS ('dbx_value_regex' = 'highly_profitable|profitable|break_even|unprofitable|unknown');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `profitability_tier` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `regulatory_classification` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Classification');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `regulatory_classification` SET TAGS ('dbx_value_regex' = 'admitted|non_admitted|surplus_lines|residual_market|not_applicable');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `revenue_band` SET TAGS ('dbx_business_glossary_term' = 'Revenue Band');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `revenue_band` SET TAGS ('dbx_value_regex' = 'micro|small|mid_market|large|enterprise');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `revenue_band` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'Segment Review Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `segment_status` SET TAGS ('dbx_business_glossary_term' = 'Segment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `segment_status` SET TAGS ('dbx_value_regex' = 'active|inactive|superseded|pending_review');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `segment_type` SET TAGS ('dbx_business_glossary_term' = 'Segment Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `segment_type` SET TAGS ('dbx_value_regex' = 'underwriting|marketing|billing|regulatory|actuarial');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification (SIC) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `sic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `source_system_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `state_of_domicile` SET TAGS ('dbx_business_glossary_term' = 'State of Domicile');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `state_of_domicile` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `state_of_domicile` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `territory_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `tier` SET TAGS ('dbx_business_glossary_term' = 'Segment Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|non_standard|high_net_worth|ultra_high_net_worth|declined');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `tiv_band` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Band');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `tiv_band` SET TAGS ('dbx_value_regex' = 'under_500k|500k_to_2m|2m_to_10m|10m_to_50m|over_50m');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `tiv_band` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `uw_appetite_flag` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Appetite Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ALTER COLUMN `years_as_customer` SET TAGS ('dbx_business_glossary_term' = 'Years as Customer');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` SET TAGS ('dbx_subdomain' = 'compliance_verification');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `party_document_id` SET TAGS ('dbx_business_glossary_term' = 'Document ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `superseded_by_document_party_document_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Document ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `acord_form_edition` SET TAGS ('dbx_business_glossary_term' = 'ACORD Form Edition');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `acord_form_number` SET TAGS ('dbx_business_glossary_term' = 'ACORD Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `claim_number` SET TAGS ('dbx_business_glossary_term' = 'Claim Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `clue_report_number` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Loss Underwriting Exchange (CLUE) Report Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `coi_holder_name` SET TAGS ('dbx_business_glossary_term' = 'Certificate of Insurance (CoI) Holder Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `coi_holder_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `coi_holder_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `party_document_description` SET TAGS ('dbx_business_glossary_term' = 'Document Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Document Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Document Expiry Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `file_format` SET TAGS ('dbx_business_glossary_term' = 'File Format');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `file_name` SET TAGS ('dbx_business_glossary_term' = 'File Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `file_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `file_size_bytes` SET TAGS ('dbx_business_glossary_term' = 'File Size Bytes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `is_kyc_document` SET TAGS ('dbx_business_glossary_term' = 'Is Know Your Customer (KYC) Document Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `is_primary` SET TAGS ('dbx_business_glossary_term' = 'Is Primary Document Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `is_sensitive` SET TAGS ('dbx_business_glossary_term' = 'Is Sensitive Document Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `issuing_authority` SET TAGS ('dbx_business_glossary_term' = 'Issuing Authority');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `issuing_country` SET TAGS ('dbx_business_glossary_term' = 'Issuing Country');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `issuing_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `issuing_country` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `issuing_state` SET TAGS ('dbx_business_glossary_term' = 'Issuing State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `issuing_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `issuing_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `kyc_verification_method` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Verification Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `kyc_verification_method` SET TAGS ('dbx_value_regex' = 'MANUAL|AUTOMATED|THIRD_PARTY|NOT_APPLICABLE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Document Language Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `mvr_order_number` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Order Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Document Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `page_count` SET TAGS ('dbx_business_glossary_term' = 'Page Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `party_document_status` SET TAGS ('dbx_business_glossary_term' = 'Document Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `party_document_status` SET TAGS ('dbx_value_regex' = 'RECEIVED|UNDER_REVIEW|VERIFIED|REJECTED|EXPIRED|ARCHIVED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `party_document_type` SET TAGS ('dbx_business_glossary_term' = 'Document Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `policy_number` SET TAGS ('dbx_business_glossary_term' = 'Policy Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `purge_date` SET TAGS ('dbx_business_glossary_term' = 'Document Purge Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `received_date` SET TAGS ('dbx_business_glossary_term' = 'Document Received Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Document Rejection Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_value_regex' = 'EXPIRED|ILLEGIBLE|MISMATCH|FRAUDULENT|INCOMPLETE|NOT_APPLICABLE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `retention_category` SET TAGS ('dbx_business_glossary_term' = 'Document Retention Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `retention_category` SET TAGS ('dbx_value_regex' = 'PERMANENT|7_YEAR|5_YEAR|3_YEAR|1_YEAR|DESTROY_ON_EXPIRY');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `source_system_doc_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Document ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `storage_uri` SET TAGS ('dbx_business_glossary_term' = 'Storage URI');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `storage_uri` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `submission_number` SET TAGS ('dbx_business_glossary_term' = 'Submission Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `subtype` SET TAGS ('dbx_business_glossary_term' = 'Document Subtype');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `tags` SET TAGS ('dbx_business_glossary_term' = 'Document Tags');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Document Title');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `verified_by` SET TAGS ('dbx_business_glossary_term' = 'Verified By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `verified_date` SET TAGS ('dbx_business_glossary_term' = 'Document Verified Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Document Version Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` SET TAGS ('dbx_subdomain' = 'financial_interest');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `loss_payee_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Payee ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_address_id` SET TAGS ('dbx_business_glossary_term' = 'Lender Address Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_address_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_address_id` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `acord_form_type` SET TAGS ('dbx_business_glossary_term' = 'ACORD Form Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `acord_form_type` SET TAGS ('dbx_value_regex' = 'ACORD_25|ACORD_28|ACORD_27|ACORD_75|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `cancellation_notice_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Notice Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `cancellation_notice_sent` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Notice Sent Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `certificate_issue_date` SET TAGS ('dbx_business_glossary_term' = 'Certificate of Insurance (CoI) Issue Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Certificate of Insurance (CoI) Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `escrow_account_number` SET TAGS ('dbx_business_glossary_term' = 'Escrow Account Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `escrow_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `escrow_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `form_number` SET TAGS ('dbx_business_glossary_term' = 'Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `interest_rank` SET TAGS ('dbx_business_glossary_term' = 'Interest Rank');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `interest_status` SET TAGS ('dbx_business_glossary_term' = 'Interest Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `interest_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|cancelled|expired');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `interest_type` SET TAGS ('dbx_business_glossary_term' = 'Interest Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `interest_type` SET TAGS ('dbx_value_regex' = 'mortgagee|loss_payee|additional_insured|lienholder|lessor|certificate_holder');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `joint_payee_required` SET TAGS ('dbx_business_glossary_term' = 'Joint Payee Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_email` SET TAGS ('dbx_business_glossary_term' = 'Lender Email Address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_email` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_fein` SET TAGS ('dbx_business_glossary_term' = 'Lender Federal Employer Identification Number (FEIN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_fein` SET TAGS ('dbx_value_regex' = '^[0-9]{2}-[0-9]{7}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_fein` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_fein` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_name` SET TAGS ('dbx_business_glossary_term' = 'Lender Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_name` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_phone` SET TAGS ('dbx_business_glossary_term' = 'Lender Phone Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9-s().]{7,20}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Lender Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_reference_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `lender_reference_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `loan_number` SET TAGS ('dbx_business_glossary_term' = 'Loan Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `loan_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `loan_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `loss_payable_clause_type` SET TAGS ('dbx_business_glossary_term' = 'Loss Payable Clause Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `loss_payable_clause_type` SET TAGS ('dbx_value_regex' = 'standard|lenders|open|union');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `naic_lender_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Lender Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `notification_days` SET TAGS ('dbx_business_glossary_term' = 'Notification Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `notification_required` SET TAGS ('dbx_business_glossary_term' = 'Notification Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `payment_payable_to` SET TAGS ('dbx_business_glossary_term' = 'Payment Payable To');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `payment_payable_to` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `payment_payable_to` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `payment_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Payment Threshold Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `premium_billed_to_lender` SET TAGS ('dbx_business_glossary_term' = 'Premium Billed to Lender Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'PAS|CMS|BILLING|MDM|MANUAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `source_system_ref_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` SET TAGS ('dbx_subdomain' = 'financial_interest');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `license_id` SET TAGS ('dbx_business_glossary_term' = 'License ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `issuing_geography_id` SET TAGS ('dbx_business_glossary_term' = 'Issuing Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `adjuster_type` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `adjuster_type` SET TAGS ('dbx_value_regex' = 'staff|independent|public|catastrophe|auto_damage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `background_check_date` SET TAGS ('dbx_business_glossary_term' = 'Background Check Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `background_check_status` SET TAGS ('dbx_business_glossary_term' = 'Background Check Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `background_check_status` SET TAGS ('dbx_value_regex' = 'passed|failed|pending|waived|not_required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `ce_credits_completed` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Credits Completed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `ce_credits_required` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Credits Required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `class` SET TAGS ('dbx_business_glossary_term' = 'License Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `continuing_education_due_date` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `contractor_license_number` SET TAGS ('dbx_business_glossary_term' = 'Contractor License Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `contractor_license_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `contractor_license_number` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `disciplinary_action_description` SET TAGS ('dbx_business_glossary_term' = 'Disciplinary Action Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `disciplinary_action_indicator` SET TAGS ('dbx_business_glossary_term' = 'Disciplinary Action Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'License Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `errors_omissions_carrier` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Carrier Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `errors_omissions_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Expiry Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `errors_omissions_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `ethics_ce_credits_completed` SET TAGS ('dbx_business_glossary_term' = 'Ethics Continuing Education (CE) Credits Completed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `ethics_ce_credits_required` SET TAGS ('dbx_business_glossary_term' = 'Ethics Continuing Education (CE) Credits Required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'License Expiry Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `fein` SET TAGS ('dbx_business_glossary_term' = 'Federal Employer Identification Number (FEIN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `fein` SET TAGS ('dbx_value_regex' = '^[0-9]{2}-[0-9]{7}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `fein` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `fein` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `is_resident_license` SET TAGS ('dbx_business_glossary_term' = 'Resident License Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'License Issue Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `issuing_state_code` SET TAGS ('dbx_business_glossary_term' = 'Issuing State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `issuing_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `issuing_state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `license_status` SET TAGS ('dbx_business_glossary_term' = 'License Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `license_status` SET TAGS ('dbx_value_regex' = 'active|expired|suspended|revoked|cancelled|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `license_type` SET TAGS ('dbx_business_glossary_term' = 'License Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `license_type` SET TAGS ('dbx_value_regex' = 'producer|adjuster|contractor|surplus_lines|public_adjuster|reinsurance_intermediary');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `nipr_last_verified_date` SET TAGS ('dbx_business_glossary_term' = 'NIPR Last Verified Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `nipr_verification_status` SET TAGS ('dbx_business_glossary_term' = 'NIPR Verification Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `nipr_verification_status` SET TAGS ('dbx_value_regex' = 'verified|unverified|mismatch|not_found');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'License Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `npn` SET TAGS ('dbx_business_glossary_term' = 'National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `npn` SET TAGS ('dbx_value_regex' = '^[0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `npn` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'License Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `reciprocity_state_codes` SET TAGS ('dbx_business_glossary_term' = 'Reciprocity State Codes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `reciprocity_state_codes` SET TAGS ('dbx_pii_category' = 'address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `renewal_date` SET TAGS ('dbx_business_glossary_term' = 'License Renewal Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `resident_state_code` SET TAGS ('dbx_business_glossary_term' = 'Resident State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `resident_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `resident_state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `source_system_license_key` SET TAGS ('dbx_business_glossary_term' = 'Source System License Key');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `ssn_last4` SET TAGS ('dbx_business_glossary_term' = 'Social Security Number Last 4 Digits (SSN Last 4)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `ssn_last4` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `ssn_last4` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `ssn_last4` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `surplus_lines_authorized` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Authorized Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `surplus_lines_number` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines License Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `surplus_lines_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'License Termination Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'License Termination Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'voluntary_surrender|revocation|non_renewal|disciplinary|death|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` SET TAGS ('dbx_subdomain' = 'identity_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` ALTER COLUMN `household_id` SET TAGS ('dbx_business_glossary_term' = 'Household Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` ALTER COLUMN `primary_address_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Address Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` ALTER COLUMN `primary_address_id` SET TAGS ('dbx_classification' = 'restricted');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` ALTER COLUMN `primary_address_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` ALTER COLUMN `primary_address_id` SET TAGS ('dbx_pii_category' = 'address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` ALTER COLUMN `primary_contact_party_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` ALTER COLUMN `credit_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` ALTER COLUMN `dependent_count` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` ALTER COLUMN `household_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` ALTER COLUMN `primary_email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` ALTER COLUMN `primary_email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` ALTER COLUMN `primary_phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` ALTER COLUMN `primary_phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` SET TAGS ('dbx_subdomain' = 'identity_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `party_group_id` SET TAGS ('dbx_business_glossary_term' = 'Party Group Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `primary_contact_party_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `address_line_1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `address_line_1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `address_line_2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `address_line_2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `commission_override_percentage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `credit_rating` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `group_discount_percentage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `group_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `state_province_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `state_province_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_group` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_pii_identifier' = 'true');
