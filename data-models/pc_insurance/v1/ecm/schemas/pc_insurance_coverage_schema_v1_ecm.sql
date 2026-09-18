-- Schema for Domain: coverage | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-18 02:30:17

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_v499`.`coverage` COMMENT 'SSOT for coverage structures, endorsements, limits, deductibles, SIR, and exclusions attached to a policy. Manages LOB-specific forms (GL, CGL, BOP, WC, APD, BI/PD, UM/UIM, PIP, MedPay) and tracks TIV and ITV per insured location or vehicle.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` (
    `coverage_policy_coverage_id` BIGINT COMMENT 'Unique surrogate primary key for the policy-coverage junction record. Identifies a single coverage form attached to a specific policy term.',
    `coverage_form_id` BIGINT COMMENT 'Foreign key reference to the coverage form or coverage type master record. Identifies the specific coverage being attached to the policy.',
    `part_id` BIGINT COMMENT 'Foreign key linking to coverage.part. Business justification: Coverage records should belong to a specific coverage part within a policy. Business semantics: A policy is divided into parts (e.g., CGL Coverage Part, Commercial Property Part), and each',
    `policy_id` BIGINT COMMENT 'Foreign key reference to the parent policy record. Identifies which policy this coverage attachment belongs to.',
    `risk_unit_id` BIGINT COMMENT 'Reference to the insured risk exposure (location, vehicle, or other insurable unit) to which this coverage is attached.',
    `version_id` BIGINT COMMENT 'Reference to the specific policy term (period) to which this coverage attachment applies. Supports multi-term policy structures.',
    `aggregate_limit` DECIMAL(18,2) COMMENT 'Maximum total amount the insurer will pay for all covered losses during the policy period under this coverage. Applies to GL, CGL, and similar liability lines.',
    `cancellation_date` DATE COMMENT 'Date on which this coverage attachment was cancelled, if applicable. Null for active coverages. Used for pro-rata or short-rate return premium calculation.',
    `cancellation_reason_code` STRING COMMENT 'Standardized code indicating the reason for coverage cancellation (e.g., non-payment, underwriting, insured request). Required for state DOI cancellation notice compliance.',
    `cat_exposed_flag` BOOLEAN COMMENT 'Indicates whether this coverage is exposed to catastrophe (CAT) perils such as hurricane, earthquake, or flood. Used for CAT modeling, PML estimation, and CAT XL treaty cession.',
    `coinsurance_percentage` DECIMAL(5,2) COMMENT 'Percentage of the property value the insured is required to carry as insurance. Used to calculate coinsurance penalties at time of loss for property coverages.',
    `coverage_basis` STRING COMMENT 'Trigger basis for coverage: occurrence (loss must occur during policy period) or claims-made (claim must be made during policy period). Critical for liability lines.. Valid values are `occurrence|claims_made|claims_made_reported|discovery`',
    `coverage_sequence_number` BIGINT COMMENT 'Ordinal position of this coverage within the policy. Used to order and display coverages on the Declarations (DEC) page and in bordereaux reporting.',
    `coverage_status` STRING COMMENT 'Current lifecycle state of this policy-coverage attachment. Drives eligibility for claims, billing, and reinsurance cession.. Valid values are `active|suspended|cancelled|expired|pending|lapsed`',
    `coverage_type_code` STRING COMMENT 'Standardized code identifying the type of coverage (e.g., GL, CGL, APD, BI, PD, UM, UIM, PIP, MedPay, WC). Aligns with ISO/NAIC LOB codes. [ENUM-REF-CANDIDATE: GL|CGL|APD|BI|PD|UM|UIM|PIP|MedPay|WC|BOP|CPP — promote to reference product]',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy-coverage junction record was first created in the data platform. Supports audit trail and data lineage requirements.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Dollar amount the insured must pay out-of-pocket before the insurers obligation begins for a covered loss under this coverage.',
    `deductible_type` STRING COMMENT 'Classification of the deductible structure applied to this coverage (flat dollar, percentage of loss, disappearing/franchise, or split deductible).. Valid values are `flat|percentage|disappearing|split|none`',
    `earned_premium_amount` DECIMAL(18,2) COMMENT 'Portion of the written premium that has been earned as of the reporting date, proportional to the expired coverage period. Used for financial reporting and loss ratio calculation.',
    `effective_date` DATE COMMENT 'Date on which this coverage attachment becomes effective and the insurer assumes risk. Aligns with policy inception or endorsement effective date.',
    `endorsement_flag` BOOLEAN COMMENT 'Indicates whether this coverage attachment was added or modified via a policy endorsement rather than being part of the original policy issuance.',
    `endorsement_number` STRING COMMENT 'Identifier of the endorsement transaction that created or last modified this coverage attachment. Links to the endorsement record for audit and DEC page generation.',
    `exclusion_codes` STRING COMMENT 'Pipe-delimited list of exclusion codes applicable to this coverage attachment (e.g., flood, earthquake, war, pollution). Drives claims eligibility determination.',
    `expiration_date` DATE COMMENT 'Date on which this coverage attachment expires and the insurers obligation under this coverage ends. Null for open-ended coverages.',
    `extended_reporting_period_days` BIGINT COMMENT 'Number of days in the Extended Reporting Period (tail coverage) for claims-made policies, allowing claims to be reported after policy expiration.',
    `itv_ratio` DECIMAL(7,4) COMMENT 'Insurance to Value ratio expressing the relationship between the coverage limit and the estimated replacement cost value of the insured property. Used for coinsurance and underwriting adequacy.',
    `lob_code` STRING COMMENT 'NAIC-aligned Line of Business code classifying the coverage for statutory reporting, rate filings, and actuarial segmentation.',
    `mandatory_coverage_flag` BOOLEAN COMMENT 'Indicates whether this coverage is statutorily or contractually required (e.g., state-mandated UM/UIM, PIP, or WC coverage). Prevents inadvertent removal during policy changes.',
    `occurrence_limit` DECIMAL(18,2) COMMENT 'Maximum amount the insurer will pay for a single occurrence or accident under this coverage. Core underwriting and claims adjudication field.',
    `pml_amount` DECIMAL(18,2) COMMENT 'Estimated Probable Maximum Loss for this coverage attachment, used in catastrophe modeling, reinsurance treaty sizing, and capital adequacy assessment.',
    `policy_transaction_type` STRING COMMENT 'Type of policy transaction that created or last modified this coverage attachment: New Business (NB), Renewal (REN), Endorsement (ENDT), Cancellation (CANC), reinstatement, or rewrite.. Valid values are `NB|REN|ENDT|CANC|reinstatement|rewrite`',
    `premium_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this coverage attachment (e.g., USD, CAD). Supports multi-currency operations.. Valid values are `^[A-Z]{3}$`',
    `rate_code` STRING COMMENT 'Rating code used by the rating engine to price this coverage. Links to the rate table and ISO/Verisk rating content used at time of quote and bind.',
    `rate_effective_date` DATE COMMENT 'Effective date of the rate filing or rate table version used to price this coverage. Required for regulatory rate filing compliance and actuarial audit.',
    `reinsurance_eligible_flag` BOOLEAN COMMENT 'Indicates whether this coverage attachment is eligible for cession under a reinsurance treaty or facultative certificate. Used in bordereaux and cession processing.',
    `retroactive_date` DATE COMMENT 'For claims-made coverages, the earliest date from which covered incidents are eligible. Losses occurring before this date are excluded.',
    `sir_amount` DECIMAL(18,2) COMMENT 'Self-Insured Retention amount the insured retains before the insurers coverage attaches. Distinct from a deductible; insured defends and pays within the SIR.',
    `source_system_code` STRING COMMENT 'Code identifying the policy administration system of record from which this coverage attachment record originated. Supports multi-system data lineage in the Snowflake lakehouse.. Valid values are `guidewire|duck_creek|sapiens_idit|legacy`',
    `source_system_coverage_ref` STRING COMMENT 'Native identifier of this coverage attachment record in the originating policy administration system (e.g., Guidewire PolicyCenter coverage public ID). Enables reconciliation and lineage tracing.',
    `sublimit_amount` DECIMAL(18,2) COMMENT 'Sublimit of liability within the overall coverage limit for a specific peril, category of property, or coverage extension (e.g., flood sublimit, mold sublimit).',
    `sublimit_description` STRING COMMENT 'Free-text description of the peril, property category, or coverage extension to which the sublimit applies (e.g., Flood, Earthquake, Business Income).',
    `tiv_amount` DECIMAL(18,2) COMMENT 'Total Insured Value for the risk exposure covered under this coverage attachment. Used for property lines, ITV calculation, and reinsurance cession.',
    `unearned_premium_amount` DECIMAL(18,2) COMMENT 'Portion of the written premium not yet earned as of the reporting date, representing the insurers liability for the unexpired coverage period.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy-coverage junction record was last updated in the data platform. Used for incremental load detection and change data capture.',
    `valuation_method` STRING COMMENT 'Method used to value a covered loss under this coverage: Actual Cash Value (ACV), Replacement Cost Value (RCV), agreed value, functional replacement, or stated amount.. Valid values are `ACV|RCV|agreed_value|functional_replacement|stated_amount`',
    `waiting_period_days` BIGINT COMMENT 'Number of days after a covered event before benefits under this coverage begin. Commonly applies to Business Interruption and Time Element coverages.',
    `written_premium_amount` DECIMAL(18,2) COMMENT 'Gross Written Premium allocated to this specific coverage attachment for the policy term. Used for premium allocation, statutory reporting, and reinsurance cession.',
    CONSTRAINT pk_coverage_policy_coverage PRIMARY KEY(`coverage_policy_coverage_id`)
) COMMENT 'Junction table resolving the M:N relationship between policies and coverage forms. Carries effective/expiration dates, coverage status, and sequence order. SSOT for which coverages are attached to a given policy term.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` (
    `coverage_form_id` BIGINT COMMENT 'Unique surrogate identifier for a coverage form record in the master catalog. Primary key for the coverage_form product.',
    `aggregate_limit_applicable` BOOLEAN COMMENT 'Indicates whether this coverage form supports a policy aggregate limit in addition to per-occurrence limits. Applicable to GL, CGL, and umbrella forms.',
    `approval_date` DATE COMMENT 'Date the state Department of Insurance formally approved the coverage form for use. Null if pending or not required.',
    `cat_exposed` BOOLEAN COMMENT 'Indicates whether this coverage form provides coverage for catastrophe (CAT) perils such as hurricane, earthquake, or flood. Used for PML modeling and CAT XL reinsurance cession.',
    `coinsurance_percent` DECIMAL(5,2) COMMENT 'Required coinsurance percentage for property forms with ITV provisions (e.g., 80%, 90%, 100%). Null for forms without coinsurance requirements.',
    `coverage_category` STRING COMMENT 'Broad insurance coverage category grouping the form for product management and regulatory reporting (e.g., liability, property, auto, workers_comp, umbrella).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this coverage form record was first created in the master catalog. Used for audit trail and data lineage tracking per SOX compliance requirements.',
    `default_deductible_amount` DECIMAL(18,2) COMMENT 'Default deductible amount applied to this coverage form when no specific deductible is selected at policy binding. Expressed in USD.',
    `default_limit_amount` DECIMAL(18,2) COMMENT 'Default per-occurrence or per-claim coverage limit amount associated with this form when no specific limit is selected at policy binding. Expressed in USD.',
    `document_template_code` STRING COMMENT 'Reference code linking this coverage form to its policy document template in the document management system (OpenText/FileNet) for automated DEC page and policy packet generation.',
    `edition_date` DATE COMMENT 'The edition date printed on the coverage form, indicating the version of the form language approved by the filing authority (e.g., 2013-04-01 for CG 00 01 04 13).',
    `effective_date` DATE COMMENT 'Date from which this coverage form version is available for new policy issuance and binding. Aligns with regulatory approval or insurer implementation date.',
    `expiration_date` DATE COMMENT 'Date after which this form version is no longer available for new policy issuance. Null for forms with no planned expiration. Superseded forms retain historical records.',
    `extended_reporting_period_days` BIGINT COMMENT 'Number of days for the basic extended reporting period (tail coverage) available under claims-made forms after policy expiration. Zero for occurrence-based forms.',
    `filing_date` DATE COMMENT 'Date the coverage form was submitted to the state Department of Insurance for approval or informational filing.',
    `filing_jurisdiction` STRING COMMENT 'Two-letter US state or territory code where this form has been filed and approved by the Department of Insurance (DOI). Use ALL for multi-state or nationwide approved forms.. Valid values are `^[A-Z]{2}$`',
    `filing_status` STRING COMMENT 'Current regulatory filing status of the form with the applicable state Department of Insurance. Tracks approval lifecycle for compliance and issuance eligibility.. Valid values are `approved|filed|objected|withdrawn|not_required`',
    `form_description` STRING COMMENT 'Detailed narrative description of the coverage forms insuring agreement, scope of coverage, and primary use case for underwriting and product management reference.',
    `form_name` STRING COMMENT 'Human-readable title of the coverage form as it appears on the declarations page or filing (e.g., Commercial General Liability Coverage Form).',
    `form_number` STRING COMMENT 'Externally recognized alphanumeric identifier assigned to the coverage form by ISO/Verisk or the insurers proprietary filing (e.g., CG 00 01, HO 00 03). Unique within edition.. Valid values are `^[A-Z0-9-.]{2,30}$`',
    `form_status` STRING COMMENT 'Current lifecycle state of the coverage form in the master catalog. Superseded forms remain for historical policy reference; withdrawn forms are no longer issuable.. Valid values are `active|inactive|superseded|withdrawn|pending_approval`',
    `form_type` STRING COMMENT 'Classifies the form as a base coverage form, endorsement (ENDT), exclusion, schedule, declarations page (DEC), or conditions form within the policy structure.. Valid values are `coverage|endorsement|exclusion|schedule|declaration|condition`',
    `is_base_form` BOOLEAN COMMENT 'Indicates whether this is a base coverage form (True) or a supplemental endorsement/exclusion form (False). Base forms define primary insuring agreements; endorsements modify them.',
    `is_iso_standard` BOOLEAN COMMENT 'Indicates whether this form is an unmodified ISO/Verisk standard form (True) or a proprietary/manuscript deviation (False). Impacts rate filing and actuarial credibility.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether this form is mandatory for all policies in the applicable LOB and jurisdiction, or optional/elective. Mandatory forms are auto-attached during policy issuance.',
    `iso_program_code` STRING COMMENT 'ISO/Verisk program or manual code associated with this form, used for cross-referencing ISO rating content, loss costs, and advisory prospective loss cost filings.',
    `lob_code` STRING COMMENT 'NAIC or insurer-assigned Line of Business code identifying the insurance line this form applies to (e.g., GL, CGL, BOP, WC, APD, BI/PD, UM/UIM, PIP, MedPay).',
    `lob_description` STRING COMMENT 'Full descriptive name of the line of business associated with this form (e.g., Commercial General Liability, Businessowners Policy, Workers Compensation).',
    `minimum_premium_amount` DECIMAL(18,2) COMMENT 'Minimum premium amount required when this coverage form is attached to a policy. Expressed in USD. Null if no minimum applies.',
    `naic_line_code` STRING COMMENT 'NAIC statutory line of business code used for Annual Statement reporting and regulatory filings (e.g., 17 for Other Liability, 19 for Workers Compensation).. Valid values are `^[0-9]{2,3}$`',
    `occurrence_claims_basis` STRING COMMENT 'Specifies the coverage trigger basis: occurrence (loss event date), claims-made (claim reported date), or reporting basis. Critical for reserve development and IBNR estimation.. Valid values are `occurrence|claims_made|reporting|not_applicable`',
    `origin` STRING COMMENT 'Identifies the originating standards body or source of the form: ISO/Verisk, AAIS, NCCI for WC, NFIP for flood, or insurer-proprietary/manuscript forms.. Valid values are `ISO|AAIS|proprietary|manuscript|NCCI|NFIP`',
    `policy_type_applicability` STRING COMMENT 'Indicates whether the form applies to personal lines, commercial lines, or both. Drives underwriting eligibility rules in PolicyCenter and Duck Creek Policy.. Valid values are `personal|commercial|both`',
    `premium_basis` STRING COMMENT 'The exposure base used to calculate premium for this form (e.g., payroll for WC, gross receipts for GL, area for property). Drives rating engine configuration.',
    `reinsurance_eligible` BOOLEAN COMMENT 'Indicates whether policies written on this form are eligible for cession under reinsurance treaties (QS, XOL, CAT XL) or facultative (FAC) placements.',
    `retroactive_date_required` BOOLEAN COMMENT 'Indicates whether a retroactive date must be specified for this form. Required for claims-made forms to define the earliest date of covered occurrences.',
    `sir_eligible` BOOLEAN COMMENT 'Indicates whether a Self-Insured Retention (SIR) can be applied to this coverage form in lieu of or in addition to a standard deductible. Relevant for large commercial accounts.',
    `source_system_code` STRING COMMENT 'Identifies the operational system of record from which this coverage form record originated (e.g., Guidewire PolicyCenter, Duck Creek Policy, ISO ISONet, Sapiens IDIT).. Valid values are `GUIDEWIRE|DUCK_CREEK|SAPIENS_IDIT|ISO_ISONET|MANUAL`',
    `source_system_form_code` STRING COMMENT 'Native identifier of this coverage form in the originating source system (e.g., Guidewire PolicyCenter internal form ID). Enables lineage tracing and reconciliation.',
    `state_specific_version` BOOLEAN COMMENT 'Indicates whether this form is a state-specific version with language deviating from the standard ISO form to comply with state DOI requirements or mandatory coverage provisions.',
    `tiv_applicable` BOOLEAN COMMENT 'Indicates whether Total Insured Value (TIV) must be declared for this form. Applicable to property forms where ITV (Insurance to Value) coinsurance provisions apply.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this coverage form record. Supports change data capture (CDC) for Snowflake data warehouse synchronization and audit compliance.',
    `valuation_basis` STRING COMMENT 'Specifies the loss settlement valuation method: Actual Cash Value (ACV), Replacement Cost Value (RCV), agreed value, or functional replacement cost. Drives claims payment calculation.. Valid values are `ACV|RCV|agreed_value|functional_replacement|not_applicable`',
    CONSTRAINT pk_coverage_form PRIMARY KEY(`coverage_form_id`)
) COMMENT 'Master catalog of ISO and proprietary coverage forms available for each LOB (GL, CGL, BOP, WC, APD, BI/PD, UM/UIM, PIP, MedPay). Defines form number, edition date, filing jurisdiction, and applicable line of business.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`part` (
    `part_id` BIGINT COMMENT 'Unique surrogate identifier for a coverage part record within the enterprise data platform. Primary key for the coverage_part product.',
    `coverage_form_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_form. Business justification: Coverage parts (e.g., CGL Coverage Part, Commercial Property Part) are discrete sections of a policy, each based on a specific ISO or proprietary form.',
    `policy_id` BIGINT COMMENT 'Reference to the parent policy to which this coverage part belongs. Links the coverage part to its governing policy contract.',
    `product_id` BIGINT COMMENT 'Reference to the insurance product definition that governs the forms, rules, and rating logic applicable to this coverage part.',
    `aggregate_limit` DECIMAL(18,2) COMMENT 'Maximum total amount the insurer will pay for all covered losses during the policy period under this coverage part. Key metric for reinsurance cession and PML analysis.',
    `cat_exposed_ind` BOOLEAN COMMENT 'Indicates whether this coverage part is exposed to catastrophe (CAT) perils such as hurricane, earthquake, or flood. Used for CAT modeling, PML analysis, and reinsurance treaty attachment.',
    `claims_made_ind` BOOLEAN COMMENT 'Indicates whether this coverage part is written on a claims-made basis (True) or occurrence basis (False). Determines IBNR reserving methodology and tail coverage requirements.',
    `coinsurance_pct` DECIMAL(5,2) COMMENT 'Coinsurance percentage requirement for this coverage part (e.g., 80%, 90%, 100%). Insured must maintain coverage at this percentage of replacement cost to avoid penalty at loss.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this coverage part record was first created in the system of record. Used for audit trail, data lineage, and regulatory compliance under SOX and state DOI requirements.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Dollar amount of the deductible applicable to this coverage part, representing the insureds retained share of each covered loss before insurer indemnification begins.',
    `deductible_type` STRING COMMENT 'Classification of the deductible structure applied to this coverage part (e.g., straight, franchise, aggregate, disappearing, per occurrence).. Valid values are `straight|franchise|aggregate|disappearing|per_occurrence`',
    `earned_premium` DECIMAL(18,2) COMMENT 'Portion of Written Premium (WP) earned as of the reporting date, based on pro-rata or other earning method. Used for Loss Ratio (LR) and Combined Ratio (CR) calculations.',
    `effective_date` DATE COMMENT 'Date on which this coverage part becomes effective and coverage obligations begin. Aligns with the policy inception or mid-term endorsement effective date.',
    `experience_mod_factor` DECIMAL(7,4) COMMENT 'Experience modification factor (EMF or e-mod) applied to this coverage part, reflecting the insureds historical loss experience relative to expected losses. Primarily used for WC.',
    `expiration_date` DATE COMMENT 'Date on which this coverage part expires and coverage obligations cease. Used for Unearned Premium (UEP) calculation and renewal processing.',
    `exposure_amount` DECIMAL(18,2) COMMENT 'Quantified exposure base value for this coverage part (e.g., total payroll in USD for WC, square footage for property, number of vehicles for APD). Used in premium rating.',
    `extended_reporting_period_days` BIGINT COMMENT 'Number of days in the Extended Reporting Period (ERP or tail coverage) for claims-made parts, allowing claims to be reported after policy expiration for incidents during the policy period.',
    `filing_jurisdiction` STRING COMMENT 'Two-letter US state code of the primary jurisdiction where this coverage parts form and rate are filed with the Department of Insurance (DOI).. Valid values are `^[A-Z]{2}$`',
    `inception_date` DATE COMMENT 'Original inception date of this coverage part, which may differ from effective_date for renewal or rewritten policies. Used for continuous coverage tracking.',
    `insuring_agreement_desc` STRING COMMENT 'Narrative description of the insuring agreement for this coverage part, summarizing the scope of coverage, perils insured, and key conditions as stated on the DEC page.',
    `itv_ratio` DECIMAL(7,4) COMMENT 'Insurance to Value (ITV) ratio for this coverage part, calculated as the insured value divided by the estimated replacement cost. Used to detect underinsurance and apply coinsurance penalties.',
    `lob_code` STRING COMMENT 'NAIC or ISO standard Line of Business code assigned to this coverage part, used for statutory reporting, rate filings, and actuarial segmentation.. Valid values are `^[A-Z0-9]{2,10}$`',
    `med_expense_limit` DECIMAL(18,2) COMMENT 'Per-person limit for medical payments coverage (MedPay) under this coverage part, payable regardless of fault for bodily injury on the insured premises.',
    `naic_line_code` STRING COMMENT 'NAIC statutory line of business code for this coverage part, used in Annual Statement Schedule P, Schedule F, and state regulatory filings.. Valid values are `^[0-9]{2,3}$`',
    `part_name` STRING COMMENT 'Human-readable name of the coverage part (e.g., Commercial General Liability Coverage Part, Commercial Property Coverage Part, Workers Compensation and Employers Liability Part).',
    `occurrence_limit` DECIMAL(18,2) COMMENT 'Maximum amount the insurer will pay for a single occurrence or accident under this coverage part. Core underwriting parameter for GL, CGL, APD, and property lines.',
    `part_number` STRING COMMENT 'Externally visible alphanumeric identifier for this coverage part, as printed on the Declarations (DEC) page and used in bordereaux and regulatory filings.. Valid values are `^[A-Z0-9-]{3,30}$`',
    `part_status` STRING COMMENT 'Current lifecycle state of the coverage part within the policy administration system. Drives billing, claims eligibility, and regulatory reporting.. Valid values are `active|pending|suspended|cancelled|expired`',
    `part_type` STRING COMMENT 'Classifies the coverage part by Line of Business (LOB) form type. [ENUM-REF-CANDIDATE: GL|CGL|CP|WC_EL|APD|BOP|CPP|IM|CRIME|UMBRELLA|OTHER — promote to reference product]',
    `personal_adv_injury_limit` DECIMAL(18,2) COMMENT 'Per-occurrence limit for personal and advertising injury coverage under a CGL part, covering offenses such as libel, slander, and copyright infringement.',
    `policy_term_months` BIGINT COMMENT 'Duration of the coverage part in whole months (typically 6 or 12). Used for pro-rata premium calculation, Earned Premium (EP), and Unearned Premium Reserve (UEP).',
    `premium_currency` STRING COMMENT 'ISO 4217 three-letter currency code for all premium and limit amounts on this coverage part (e.g., USD). Required for multi-currency and international program reporting.. Valid values are `^[A-Z]{3}$`',
    `products_completed_ops_limit` DECIMAL(18,2) COMMENT 'Separate aggregate limit applying to products and completed operations exposures under a CGL coverage part, as defined by ISO CG 00 01 form structure.',
    `rate_per_unit` DECIMAL(18,6) COMMENT 'Manual or filed rate applied per unit of exposure for this coverage part (e.g., rate per $100 of payroll, rate per $1,000 of TIV). Core rating parameter from ISO or NCCI filings.',
    `rating_basis` STRING COMMENT 'Exposure base used to rate this coverage part (e.g., payroll for WC, revenue for GL, area for property). Drives premium calculation and actuarial loss development.',
    `retroactive_date` DATE COMMENT 'For claims-made coverage parts, the retroactive date before which incidents are not covered. Null for occurrence-based parts. Critical for IBNR tail reserve calculations.',
    `schedule_mod_factor` DECIMAL(7,4) COMMENT 'Underwriter-applied schedule rating modification factor for this coverage part, reflecting risk-specific credits or debits relative to the manual rate. Subject to state DOI filing limits.',
    `sir_amount` DECIMAL(18,2) COMMENT 'Dollar amount of the Self-Insured Retention (SIR) for this coverage part. Unlike a deductible, the insured defends and pays claims within the SIR before insurer involvement.',
    `source_system_part_ref` STRING COMMENT 'Native identifier for this coverage part in the originating policy administration system (e.g., Guidewire PolicyCenter CoveragePartBean ID or Duck Creek Part GUID) for lineage tracing.',
    `state_filed_ind` BOOLEAN COMMENT 'Indicates whether the form and rate for this coverage part have been filed and approved by the applicable state Department of Insurance (DOI). Required for regulatory compliance tracking.',
    `terrorism_coverage_ind` BOOLEAN COMMENT 'Indicates whether terrorism coverage under TRIA (Terrorism Risk Insurance Act) is included in this coverage part. Required for TRIA certification and federal reporting.',
    `tiv_amount` DECIMAL(18,2) COMMENT 'Total Insured Value (TIV) for this coverage part, representing the aggregate replacement or actual cash value of all insured property or assets covered under the part.',
    `unearned_premium` DECIMAL(18,2) COMMENT 'Unearned Premium Reserve (UEP) for this coverage part as of the reporting date, representing the unexpired portion of written premium. Required for NAIC statutory balance sheet.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this coverage part record. Used for change data capture (CDC), audit trail, and Silver layer incremental processing in the Databricks Lakehouse.',
    `valuation_method` STRING COMMENT 'Method used to value insured property under this coverage part: Actual Cash Value (ACV), Replacement Cost Value (RCV), agreed value, functional replacement, or stated amount.. Valid values are `ACV|RCV|agreed_value|functional_replacement|stated_amount`',
    `written_premium` DECIMAL(18,2) COMMENT 'Gross Written Premium (GWP) attributed to this coverage part for the current policy term. Used for Gross Written Premium (GWP) reporting, bordereaux, and reinsurance cession calculations.',
    CONSTRAINT pk_part PRIMARY KEY(`part_id`)
) COMMENT 'Represents a discrete coverage part within a policy (e.g., CGL Coverage Part, Commercial Property Part, WC and EL Part). Groups related coverage forms under a single insuring agreement within a CPP or BOP structure.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` (
    `limit_id` BIGINT COMMENT 'Unique surrogate identifier for a coverage limit record in the Silver layer lakehouse.',
    `parent_limit_id` BIGINT COMMENT 'Self-referencing FK to the parent limit record, enabling hierarchical sublimit modeling (e.g., peril-specific sublimit under an aggregate).',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Reference to the parent coverage to which this limit structure is attached.',
    `aggregate_limit_amount` DECIMAL(18,2) COMMENT 'Maximum total amount payable under this coverage for all occurrences during the policy period. Distinct from per-occurrence limit_amount.',
    `amount` DECIMAL(18,2) COMMENT 'The principal monetary limit amount in the policy currency (e.g., per-occurrence limit, aggregate limit, per-person BI limit). Core financial fact for this limit record.',
    `amount_2` DECIMAL(18,2) COMMENT 'Second monetary limit used in split-limit structures (e.g., PD limit in a BI/PD split, or per-person limit alongside per-occurrence). Null for non-split limits.',
    `amount_3` DECIMAL(18,2) COMMENT 'Third monetary limit in a three-part split structure (e.g., per-person BI / per-occurrence BI / PD). Null for non-three-part split limits.',
    `application` STRING COMMENT 'Defines how the limit applies across insured units: per insured, per location, per vehicle, per project, per employee, or blanket across all units.. Valid values are `per_insured|per_location|per_vehicle|per_project|per_employee|blanket`',
    `basis` STRING COMMENT 'The trigger basis on which the limit applies: occurrence, claims-made, accident, policy period, per location, or per vehicle.. Valid values are `occurrence|claims_made|accident|policy_period|location|vehicle`',
    `cat_exposed_flag` BOOLEAN COMMENT 'Indicates whether this limit is exposed to catastrophe (CAT) perils such as hurricane, earthquake, or flood, used for CAT accumulation and PML reporting.',
    `limit_code` STRING COMMENT 'Externally-known alphanumeric code identifying this limit type, aligned with ISO form codes and carrier rating plans (e.g., OCC_LIMIT, AGG_LIMIT, PER_PERSON).. Valid values are `^[A-Z0-9_]{2,30}$`',
    `coinsurance_pct` DECIMAL(7,4) COMMENT 'Required coinsurance percentage (e.g., 0.80 = 80%) the insured must maintain relative to replacement cost value to avoid a coinsurance penalty at loss.',
    `coverage_form_code` STRING COMMENT 'ISO/Verisk or carrier-proprietary form code identifying the policy form under which this limit applies (e.g., CG 00 01, HO 00 03, CA 00 01).. Valid values are `^[A-Z]{2}[s][0-9]{2}[s][0-9]{2}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this limit record was first created in the Silver layer, used for audit trail and data lineage per SOX and NIST controls.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary limit amounts on this record (e.g., USD, CAD, GBP).. Valid values are `^[A-Z]{3}$`',
    `effective_date` DATE COMMENT 'Date on which this limit structure becomes effective, aligned with policy inception or endorsement effective date.',
    `endorsement_number` STRING COMMENT 'Identifier of the policy endorsement (ENDT) that introduced or modified this limit, enabling traceability to the endorsement transaction.',
    `expiration_date` DATE COMMENT 'Date on which this limit structure expires, aligned with policy expiration or endorsement termination date. Null for open-ended limits.',
    `iso_limit_symbol` STRING COMMENT 'ISO/Verisk rating symbol associated with this limit tier, used in ISO loss cost and rate filing calculations (e.g., auto liability symbol).. Valid values are `^[A-Z0-9]{1,10}$`',
    `itv_ratio` DECIMAL(7,4) COMMENT 'Insurance to Value (ITV) ratio: limit_amount divided by replacement cost value, used to detect underinsurance and apply coinsurance penalties.',
    `jurisdiction_state_code` STRING COMMENT 'Two-letter US state code of the jurisdiction governing this limit, used for state-specific minimum limit compliance and statutory reporting.. Valid values are `^[A-Z]{2}$`',
    `limit_status` STRING COMMENT 'Current lifecycle state of the limit record: active, inactive, superseded by endorsement, pending approval, or expired.. Valid values are `active|inactive|superseded|pending|expired`',
    `limit_type` STRING COMMENT 'Structural classification of the limit: per-occurrence, aggregate, per-person, split (BI/PD), Combined Single Limit (CSL), sublimit, or per-claim. [ENUM-REF-CANDIDATE: per_occurrence|aggregate|per_person|split|csl|sublimit|per_claim — promote to reference',
    `lob_code` STRING COMMENT 'NAIC or carrier Line of Business code classifying the coverage to which this limit belongs (e.g., GL, CGL, BOP, WC, APD, PIP).. Valid values are `^[A-Z0-9_]{2,20}$`',
    `med_expense_limit` DECIMAL(18,2) COMMENT 'Per-person medical payments (MedPay) limit. Applies to GL Coverage C, auto MedPay, and BOP medical expense coverages.',
    `naic_coverage_code` STRING COMMENT 'NAIC statistical coverage code associated with this limit for statutory reporting and Annual Statement Schedule P/T filings.. Valid values are `^[0-9]{3,6}$`',
    `limit_name` STRING COMMENT 'Human-readable name of the limit structure as displayed on the Declarations (DEC) page (e.g., Per-Occurrence Limit, Annual Aggregate Limit).',
    `peril_code` STRING COMMENT 'Code identifying the specific peril or cause of loss to which this limit applies (e.g., FIRE, WIND, FLOOD, THEFT, BI, PD). Null for all-peril limits.. Valid values are `^[A-Z0-9_]{2,20}$`',
    `personal_adv_injury_limit` DECIMAL(18,2) COMMENT 'Per-occurrence limit for personal and advertising injury coverage under CGL policies. Null for non-CGL coverages.',
    `pml_amount` DECIMAL(18,2) COMMENT 'Probable Maximum Loss (PML) estimate associated with this limit, used for reinsurance treaty sizing and CAT accumulation management.',
    `policy_transaction_type` STRING COMMENT 'Type of policy transaction that created or last modified this limit record: New Business (NB), Renewal (REN), Endorsement (ENDT), Reinstatement, or Cancellation (CANC).. Valid values are `new_business|renewal|endorsement|reinstatement|cancellation`',
    `products_completed_ops_aggregate` DECIMAL(18,2) COMMENT 'Separate aggregate limit for products and completed operations exposures under CGL policies, per ISO CGL form structure.',
    `reinstatable_flag` BOOLEAN COMMENT 'Indicates whether the limit can be reinstated after a loss payment (True), relevant for aggregate limits with reinstatement provisions.',
    `reinstatement_premium_pct` DECIMAL(7,4) COMMENT 'Percentage of original premium charged to reinstate the aggregate limit after a loss, expressed as a decimal (e.g., 1.0000 = 100% pro-rata).',
    `ri_retention_amount` DECIMAL(18,2) COMMENT 'Net retention amount kept by the cedant after reinsurance cession for this limit layer, used in XOL and QS treaty calculations.',
    `shared_limit_flag` BOOLEAN COMMENT 'Indicates whether this limit is shared across multiple coverages or insured locations on the same policy (True) or applies independently (False).',
    `sir_amount` DECIMAL(18,2) COMMENT 'Dollar amount of Self-Insured Retention (SIR) the insured must exhaust before the policy limit applies. Distinct from a deductible.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this limit record was sourced (e.g., Guidewire PolicyCenter, Duck Creek Policy, Sapiens IDIT).. Valid values are `guidewire_pc|duck_creek_policy|sapiens_idit|iso_isonet|manual`',
    `source_system_limit_code` STRING COMMENT 'Native primary key of this limit record in the originating operational system (e.g., Guidewire PolicyCenter internal limit GUID), used for reconciliation.',
    `state_minimum_flag` BOOLEAN COMMENT 'Indicates whether this limit equals the state-mandated minimum required by the applicable Department of Insurance (DOI), used for compliance monitoring.',
    `tiv_amount` DECIMAL(18,2) COMMENT 'Total Insured Value (TIV) of the insured property or schedule associated with this limit, used for ITV adequacy checks and CAT modeling.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this limit record in the Silver layer, used for incremental processing and change data capture.',
    `valuation_method` STRING COMMENT 'Method used to value a loss under this limit: Actual Cash Value (ACV), Replacement Cost Value (RCV), agreed value, functional replacement cost, or market value.. Valid values are `acv|rcv|agreed_value|functional_replacement|market_value`',
    `version_number` BIGINT COMMENT 'Monotonically increasing version counter for this limit record, incremented on each endorsement or mid-term change to support audit trail and temporal queries.',
    `xol_attachment_point` DECIMAL(18,2) COMMENT 'Dollar attachment point at which Excess of Loss (XOL) reinsurance coverage begins for this limit layer. Null for non-XOL structures.',
    CONSTRAINT pk_limit PRIMARY KEY(`limit_id`)
) COMMENT 'SSOT for coverage limit structures per attached coverage: per-occurrence, aggregate, per-person, split, CSL, and peril-specific sublimits modeled via self-referencing parent-limit link.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` (
    `deductible_id` BIGINT COMMENT 'Unique surrogate identifier for a deductible or Self-Insured Retention (SIR) record attached to a coverage on a policy. Primary key of the deductible product.',
    `effective_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Deductible effective dates determine which deductible applies to a claim based on loss date. New FK needed for temporal tracking and claims adjudication.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Reference to the coverage to which this deductible or SIR structure is attached. Links the deductible record to its parent coverage.',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which this deductible applies. Enables direct policy-level reporting without joining through coverage.',
    `aggregate_deductible_amount` DECIMAL(18,2) COMMENT 'Annual aggregate cap on the insureds total deductible obligation across all occurrences in the policy period. Once exhausted, the insurer pays subsequent losses without deductible offset.',
    `application_method` STRING COMMENT 'Defines how the deductible is applied: per_occurrence, per_claim, per_accident, aggregate (annual), or per_location. Drives claims payment calculations and bordereaux reporting.. Valid values are `per_occurrence|per_claim|per_accident|aggregate|per_location`',
    `buyback_available_flag` BOOLEAN COMMENT 'Indicates whether the insured has the option to purchase a deductible buyback endorsement to reduce or eliminate the deductible obligation for an additional premium.',
    `buyback_premium_amount` DECIMAL(18,2) COMMENT 'Additional premium charged to the insured to buy back (reduce or eliminate) the deductible. Applicable only when buyback_available_flag is True and the insured exercises the option.',
    `cat_deductible_flag` BOOLEAN COMMENT 'Indicates whether this deductible is a CAT-specific deductible triggered only by a declared catastrophe event (e.g., named storm, earthquake). Separate from the standard deductible.',
    `cat_peril_type` STRING COMMENT 'Specific catastrophe peril that triggers the CAT deductible. Applicable only when cat_deductible_flag is True. [ENUM-REF-CANDIDATE: named_storm|earthquake|flood|hail|wildfire|all_cat|tornado|ice_storm — promote to reference product]. Valid values are `named_storm|earthquake|flood|hail|wildfire|all_cat`',
    `deductible_code` STRING COMMENT 'Externally-known alphanumeric code identifying this deductible structure, used in policy declarations, bordereaux, and regulatory filings.. Valid values are `^[A-Z0-9_-]{2,30}$`',
    `coverage_form_code` STRING COMMENT 'ISO or proprietary form code identifying the coverage form to which this deductible applies (e.g., CG 00 01 for CGL, HO 00 03 for homeowners). Supports rate filing alignment.. Valid values are `^[A-Z0-9 ]{2,30}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this deductible record was first created in the data platform. Used for audit trail, data lineage, and SLA monitoring in the Silver layer.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which all deductible and SIR monetary amounts are denominated (e.g., USD, CAD, GBP).. Valid values are `^[A-Z]{3}$`',
    `deductible_status` STRING COMMENT 'Current lifecycle state of the deductible record: active (in force), inactive (expired or removed), superseded (replaced by endorsement), or pending (awaiting binding).. Valid values are `active|inactive|superseded|pending`',
    `deductible_type` STRING COMMENT 'Structural classification of the deductible: flat (fixed dollar), percentage (of loss or TIV), split (per-occurrence and aggregate), disappearing (reduces to zero at threshold), or SIR (Self-Insured Retention layer).. Valid values are `flat|percentage|split|disappearing|sir`',
    `defense_inside_sir_flag` BOOLEAN COMMENT 'Indicates whether defense costs (legal fees, investigation) are included within and erode the SIR layer (True) or are paid outside the SIR by the insurer (False).',
    `disappearing_max_amount` DECIMAL(18,2) COMMENT 'Loss threshold at which the deductible fully disappears (reduces to zero) in a disappearing deductible structure. Above this amount the insurer pays the full loss.',
    `disappearing_min_amount` DECIMAL(18,2) COMMENT 'Minimum loss threshold below which the full deductible applies in a disappearing (franchise) deductible structure. Below this point the insured bears the full deductible.',
    `effective_date` DATE COMMENT 'Date on which this deductible structure becomes binding and applicable to covered losses. Aligns with policy or endorsement effective date.',
    `endorsement_number` STRING COMMENT 'Policy endorsement number that introduced or modified this deductible structure. Null if the deductible was established at original policy issuance rather than via endorsement.',
    `erosion_basis` STRING COMMENT 'Defines what costs erode (count against) the deductible or SIR: loss_only (indemnity only), loss_and_alae (loss plus Allocated Loss Adjustment Expense), or loss_and_lae (loss plus all LAE).. Valid values are `loss_only|loss_and_alae|loss_and_lae`',
    `expiration_date` DATE COMMENT 'Date on which this deductible structure ceases to apply. Null for open-ended structures; typically aligns with policy expiration or endorsement end date.',
    `flat_amount` DECIMAL(18,2) COMMENT 'Fixed dollar amount the insured must pay per occurrence or per claim before the insurers obligation begins. Applicable when deductible_type is flat or split.',
    `lob_code` STRING COMMENT 'NAIC or internal Line of Business code associated with this deductible (e.g., GL, CGL, BOP, WC, APD, PIP). Supports statutory reporting and actuarial segmentation.. Valid values are `^[A-Z0-9_]{2,20}$`',
    `maximum_deductible_amount` DECIMAL(18,2) COMMENT 'Ceiling dollar amount for the deductible, capping the insureds per-occurrence or per-claim obligation even when a percentage calculation yields a higher result.',
    `minimum_deductible_amount` DECIMAL(18,2) COMMENT 'Floor dollar amount for the deductible, ensuring the insureds obligation does not fall below this value even when a percentage calculation yields a lower result.',
    `notes` STRING COMMENT 'Free-text underwriting or operational notes describing special conditions, negotiated terms, or exceptions applicable to this deductible or SIR structure.',
    `percentage_basis` STRING COMMENT 'The value base against which the percentage deductible is calculated: TIV (Total Insured Value), loss (actual loss amount), SI (Sum Insured), or AAV (Agreed Amount Value).. Valid values are `tiv|loss|si|aav`',
    `percentage_rate` DECIMAL(7,4) COMMENT 'Deductible expressed as a percentage (e.g., 2.0000 = 2%) applied to the loss amount, Total Insured Value (TIV), or sum insured. Used when deductible_type is percentage.',
    `rate_credit_factor` DECIMAL(7,4) COMMENT 'Multiplicative premium credit factor applied to the base rate as a result of the insured accepting this deductible or SIR level (e.g., 0.8500 = 15% credit). Used in premium rating.',
    `reinstatement_basis` STRING COMMENT 'Defines whether the aggregate deductible or SIR cap reinstates after exhaustion: automatic (reinstates without additional premium), paid (reinstates for additional premium), or none.. Valid values are `automatic|paid|none`',
    `sir_aggregate_cap` DECIMAL(18,2) COMMENT 'Maximum annual aggregate dollar amount the insured is obligated to fund under the SIR layer across all occurrences in the policy period.',
    `sir_amount` DECIMAL(18,2) COMMENT 'Dollar amount of the Self-Insured Retention layer the insured must fully exhaust before the insurers policy obligations are triggered. Distinct from a deductible in that the insurer has no duty to defend within the SIR.',
    `source_system_code` STRING COMMENT 'Identifies the operational system of record from which this deductible record originated: guidewire_pc (PolicyCenter), duck_creek, sapiens_idit, or manual entry.. Valid values are `guidewire_pc|duck_creek|sapiens_idit|manual`',
    `source_system_ref_code` STRING COMMENT 'Native primary key or reference identifier of this deductible record in the originating operational system of record. Supports data lineage and reconciliation with source systems.',
    `split_aggregate_amount` DECIMAL(18,2) COMMENT 'Annual aggregate dollar cap on the insureds total deductible obligation under a split deductible structure. Once reached, the insurer absorbs subsequent losses.',
    `split_per_occurrence_amount` DECIMAL(18,2) COMMENT 'Per-occurrence dollar deductible component of a split deductible structure. The insured pays this amount for each individual loss event.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this deductible record in the data platform. Supports change detection, incremental processing, and audit compliance.',
    `version_number` BIGINT COMMENT 'Monotonically increasing version counter for this deductible record. Increments with each endorsement or modification, enabling point-in-time reconstruction of the deductible structure.',
    `waiting_period_days` BIGINT COMMENT 'Number of days the insured must wait after a loss event before the insurers obligation begins. Common in business interruption and time-element coverages.',
    `waiver_of_deductible_flag` BOOLEAN COMMENT 'Indicates whether the deductible has been waived by endorsement or underwriting authority for this coverage. When True, the insured pays no deductible regardless of the stated amount.',
    CONSTRAINT pk_deductible PRIMARY KEY(`deductible_id`)
) COMMENT 'SSOT for deductible and self-insured retention (SIR) per attached coverage: flat, percentage, split, disappearing, and SIR-layer structures. Captures amount, basis, application method, defense-inside-SIR flag, aggregate SIR cap, and erosion basis.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` (
    `sir_layer_id` BIGINT COMMENT 'Unique surrogate identifier for the Self-Insured Retention layer record. Primary key for the sir_layer entity in the coverage domain.',
    `effective_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: SIR effective dates determine claims handling and reinsurance recovery timing. New FK needed for temporal tracking and coverage determination.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Reference to the specific coverage line to which this SIR layer applies, enabling per-coverage SIR tracking within a policy.',
    `policy_id` BIGINT COMMENT 'Reference to the parent policy to which this SIR layer is attached. Links the SIR configuration to the insured contract.',
    `sir_retention_id` BIGINT COMMENT 'FK to riskexposure.sir_retention.sir_retention_id — Links the coverage-side SIR layer to the risk-side SIR/large-deductible program so SIR erosion queries use a single authoritative retention record.',
    `aggregate_limit` DECIMAL(18,2) COMMENT 'Maximum total insurer indemnity across all occurrences within the policy period above the SIR, capping the insurers annual exposure.',
    `aggregate_sir_cap` DECIMAL(18,2) COMMENT 'Maximum cumulative SIR amount the insured is obligated to pay across all occurrences within the policy period before the insurer absorbs further losses.',
    `alae_treatment` STRING COMMENT 'Specifies how ALAE is handled relative to the SIR: included within the retention amount, excluded entirely, or allocated pro-rata between insured and insurer.. Valid values are `included|excluded|pro_rata`',
    `claims_made_flag` BOOLEAN COMMENT 'Indicates whether the underlying policy is written on a claims-made basis (True) or occurrence basis (False), affecting SIR trigger and erosion timing.',
    `collateral_amount` DECIMAL(18,2) COMMENT 'Dollar value of collateral posted by the insured to secure the SIR layer obligation, used for credit risk and financial security monitoring.',
    `collateral_expiry_date` DATE COMMENT 'Date on which the collateral instrument securing the SIR obligation expires, triggering renewal or replacement requirements to maintain coverage continuity.',
    `collateral_required` BOOLEAN COMMENT 'Indicates whether the insurer requires the insured to post collateral (letter of credit, surety bond, or cash deposit) to secure the SIR obligation.',
    `collateral_type` STRING COMMENT 'Type of financial security instrument posted by the insured to collateralize the SIR obligation, such as a letter of credit or surety bond.. Valid values are `letter_of_credit|surety_bond|cash_deposit|trust_fund|none`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this SIR layer record was first created in the data platform, providing the audit trail creation marker per SOX and data governance requirements.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code applicable to all monetary amounts on this SIR layer record (e.g., USD, CAD, GBP).. Valid values are `^[A-Z]{3}$`',
    `defense_inside_sir` BOOLEAN COMMENT 'Indicates whether Allocated Loss Adjustment Expenses (ALAE) and defense costs erode the SIR amount (True) or are paid outside and above the SIR (False).',
    `effective_date` DATE COMMENT 'Date on which the SIR layer becomes operative and the insured assumes the defined retention obligation under the policy.',
    `endorsement_number` STRING COMMENT 'Policy endorsement number that introduced or last modified this SIR layer, providing traceability to the specific policy change transaction.',
    `erosion_basis` STRING COMMENT 'Determines whether the SIR is eroded by paid losses only or by incurred losses (paid plus outstanding reserves), affecting when insurer coverage is triggered.. Valid values are `paid|incurred`',
    `expiration_date` DATE COMMENT 'Date on which the SIR layer ceases to be operative. Aligns with the policy period end date unless a mid-term endorsement changes the retention terms.',
    `extended_reporting_period_days` BIGINT COMMENT 'Number of days in the extended reporting period (tail coverage) during which claims may be reported and still erode the SIR after policy expiration.',
    `form_edition_date` DATE COMMENT 'Edition date of the ISO or proprietary SIR endorsement form, used to identify the specific version of the form language governing the retention terms.',
    `form_number` STRING COMMENT 'ISO or insurer-proprietary form number of the SIR endorsement attached to the policy, enabling regulatory filing traceability and form version control.',
    `insured_defense_obligation` STRING COMMENT 'Indicates who controls and funds the legal defense within the SIR layer: the insured independently, the insurer, or a shared arrangement.. Valid values are `insured_controls|insurer_controls|shared`',
    `insured_financial_rating` STRING COMMENT 'Credit or financial strength rating of the insured entity (e.g., A.M. Best, S&P), used to assess the insureds ability to fund the SIR obligation.',
    `layer_status` STRING COMMENT 'Current lifecycle state of the SIR layer record, indicating whether the retention arrangement is operative, suspended, or terminated.. Valid values are `active|suspended|expired|cancelled|pending`',
    `lob_code` STRING COMMENT 'NAIC-aligned Line of Business code identifying the coverage type to which this SIR layer applies, such as CGL, WC, or APD. [ENUM-REF-CANDIDATE: GL|CGL|BOP|WC|APD|BI_PD|UM_UIM|PIP|MedPay|CPP — 10 candidates stripped; promote to reference product]',
    `minimum_sir_premium` DECIMAL(18,2) COMMENT 'Minimum premium charged to the insured for the SIR layer arrangement, reflecting the insurers administrative and risk management costs for the retention structure.',
    `naic_line_code` STRING COMMENT 'NAIC statutory line of business code associated with this SIR layer, required for annual statement reporting and regulatory compliance.. Valid values are `^[0-9]{2,4}$`',
    `notes` STRING COMMENT 'Free-text underwriting or operational notes describing special conditions, negotiated terms, or exceptions applicable to this SIR layer arrangement.',
    `occurrence_limit` DECIMAL(18,2) COMMENT 'Maximum insurer indemnity per occurrence above the SIR. Establishes the ceiling of insurer liability once the SIR is fully eroded for a single loss event.',
    `reinsurance_applies_above_sir` BOOLEAN COMMENT 'Indicates whether reinsurance treaty or facultative coverage attaches above the SIR layer, affecting net retained loss calculations and cession reporting.',
    `retroactive_date` DATE COMMENT 'For claims-made policies, the earliest date from which covered incidents are eligible to erode the SIR. Null for occurrence-based policies.',
    `ri_attachment_point` DECIMAL(18,2) COMMENT 'Dollar threshold above the SIR at which reinsurance coverage attaches, defining the boundary between net retained risk and ceded risk.',
    `sir_aggregate_eroded_amount` DECIMAL(18,2) COMMENT 'Cumulative dollar amount of losses and/or ALAE that have eroded the aggregate SIR cap to date within the policy period, used for real-time retention monitoring.',
    `sir_amount` DECIMAL(18,2) COMMENT 'Per-occurrence dollar amount the insured must pay before the insurers coverage obligation is triggered. Core financial parameter of the SIR layer.',
    `sir_per_occurrence_eroded_amount` DECIMAL(18,2) COMMENT 'Dollar amount of losses and/or ALAE that have eroded the per-occurrence SIR for the most recently tracked loss event, supporting claim-level retention accounting.',
    `sir_premium_credit` DECIMAL(18,2) COMMENT 'Premium credit or reduction granted to the insured in exchange for accepting the SIR, representing the risk transfer value of the retention layer.',
    `sir_reference_number` STRING COMMENT 'Externally visible alphanumeric identifier for this SIR layer record, used in policy documents, endorsements, and bordereaux reporting.. Valid values are `^SIR-[A-Z0-9]{6,20}$`',
    `sir_type` STRING COMMENT 'Classifies the SIR structure as per-occurrence, per-claim, aggregate, or combined, determining how the retention threshold is measured and applied.. Valid values are `per_occurrence|per_claim|aggregate|combined`',
    `source_system_code` STRING COMMENT 'Identifies the originating policy administration system from which this SIR layer record was sourced, supporting data lineage and reconciliation.. Valid values are `GUIDEWIRE_PC|DUCK_CREEK|SAPIENS_IDIT|MANUAL`',
    `source_system_record_code` STRING COMMENT 'Native primary key or record identifier of this SIR layer in the originating policy administration system, enabling cross-system reconciliation.',
    `state_code` STRING COMMENT 'Two-letter US state code where the SIR layer is filed and operative, governing applicable state DOI regulations and SIR permissibility rules.. Valid values are `^[A-Z]{2}$`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this SIR layer record, supporting change tracking, audit compliance, and incremental data pipeline processing.',
    `uw_approval_date` DATE COMMENT 'Date on which the underwriter formally approved this SIR layer, establishing the authorization timestamp for audit and compliance purposes.',
    `uw_approval_required` BOOLEAN COMMENT 'Indicates whether this SIR layer configuration requires explicit underwriting authority approval before binding, based on retention size or risk class.',
    `uw_approved_by` STRING COMMENT 'Name or employee identifier of the underwriter who approved this SIR layer configuration, providing an audit trail for authority compliance.',
    CONSTRAINT pk_sir_layer PRIMARY KEY(`sir_layer_id`)
) COMMENT 'Self-Insured Retention layer record for large commercial and excess policies. Tracks SIR amount, defense-inside vs outside SIR flag, aggregate SIR cap, and erosion basis (paid vs incurred).';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` (
    `endorsement_id` BIGINT COMMENT 'Unique surrogate identifier for a coverage endorsement record in the Silver Layer lakehouse. Primary key for the coverage_endorsement product.',
    `coverage_form_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_form. Business justification: Endorsements are based on ISO or proprietary coverage forms from the master catalog.',
    `effective_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Endorsement effective dates are critical for coverage determination and claims adjudication. New FK needed for temporal tracking and mid-term change processing.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Reference to the specific coverage line being modified, added, or deleted by this endorsement. Ties the ENDT to its target coverage.',
    `policy_id` BIGINT COMMENT 'Reference to the parent policy to which this endorsement is attached. Links the endorsement to its governing policy contract.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key linking to producers.producers_producer. Business justification: Endorsements are frequently producer-initiated or processed. Essential for commission calculation on mid-term premium changes, producer activity tracking, and audit of who',
    `aggregate_limit_amount` DECIMAL(18,2) COMMENT 'Maximum total coverage limit for the policy period as established or modified by this endorsement. Applies to GL, CGL, and BOP aggregate caps.',
    `beneficiary_name` STRING COMMENT 'Name of the additional insured, loss payee, mortgagee, or other beneficiary granted rights under this endorsement. Required for AI grants and waiver of subrogation ENDTs.',
    `beneficiary_type` STRING COMMENT 'Classification of the party receiving rights under this endorsement. Determines the scope of coverage extension and claims payment priority.. Valid values are `additional_insured|loss_payee|mortgagee|named_insured|certificate_holder`',
    `coverage_territory` STRING COMMENT 'Geographic territory or jurisdiction to which this endorsements coverage applies. Uses ISO 3166-1 alpha-2 state/country codes. Drives regulatory filing and rate bureau alignment.. Valid values are `^[A-Z]{2,3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the endorsement record was first captured in the policy administration system. Supports audit trail and data lineage requirements.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts on this endorsement record (e.g., USD, CAD). Supports multi-currency commercial accounts.. Valid values are `^[A-Z]{3}$`',
    `endorsement_description` STRING COMMENT 'Free-text narrative describing the purpose and scope of the endorsement. Printed on the DEC page and used by claims adjusters and UW for coverage interpretation.',
    `effective_date` DATE COMMENT 'Date on which the endorsement becomes binding and coverage changes take effect. Used for EP proration, premium audit, and regulatory filings.',
    `endorsement_number` STRING COMMENT 'Externally visible alphanumeric identifier for the endorsement as printed on the declarations page. Used by agents, insureds, and regulators to reference a specific ENDT.. Valid values are `^ENDT-[A-Z0-9]{3,20}$`',
    `endorsement_status` STRING COMMENT 'Current workflow state of the endorsement record. Controls whether the ENDT is binding, pending UW approval, superseded by a later ENDT, or cancelled.. Valid values are `draft|pending_approval|active|superseded|cancelled|expired`',
    `endorsement_type` STRING COMMENT 'Categorical classification of the endorsement action. Drives processing logic for AI grants, SubroFT waivers, mid-term amendments, and coverage changes. [ENUM-REF-CANDIDATE. Valid values are `additional_insured|waiver_of_subrogation|coverage_add|coverage_delete|coverage_modify|limit_change`',
    `exclusion_description` STRING COMMENT 'Narrative description of any coverage exclusion added or removed by this endorsement. Used by claims adjusters for coverage determination and UW for risk selection.',
    `expiration_date` DATE COMMENT 'Date on which the endorsement ceases to be effective. Null for permanent ENDTs that run to policy expiry. Used for temporary coverage grants and time-limited waivers.',
    `issued_date` DATE COMMENT 'Calendar date on which the endorsement was formally issued and delivered to the insured or broker. Distinct from effective_date for retroactive or prospective ENDTs.',
    `itv_ratio` DECIMAL(5,4) COMMENT 'Ratio of insured value to estimated replacement cost value after endorsement. Used to identify coinsurance deficiencies and ensure adequate coverage per ISO ITV guidelines.',
    `lob_code` STRING COMMENT 'Line of Business to which this endorsement applies. Aligns with NAIC LOB codes and internal product taxonomy for statutory reporting and analytics. [ENUM-REF-CANDIDATE: GL|CGL|BOP|WC|APD|BI_PD|UM_UIM|PIP|MedPay|CPP|FAC — 11 candidates stripped; promote to',
    `new_deductible_amount` DECIMAL(18,2) COMMENT 'Deductible amount established by this endorsement. Drives claims payment net calculations and insured cost-sharing obligations post-endorsement.',
    `new_limit_amount` DECIMAL(18,2) COMMENT 'Coverage limit established by this endorsement after the change takes effect. Used for premium rating, TIV calculation, and reinsurance cession.',
    `occurrence_limit_amount` DECIMAL(18,2) COMMENT 'Maximum coverage limit per occurrence as established or modified by this endorsement. Distinct from aggregate limit; used for claims payment and reinsurance XOL attachment.',
    `policy_transaction_type` STRING COMMENT 'Type of policy transaction that generated this endorsement (New Business, Renewal, Mid-term ENDT, Cancellation, Reinstatement, Rewrite). Aligns with NAIC transaction reporting.. Valid values are `NB|REN|ENDT|CANC|REINSTATE|REWRITE`',
    `premium_impact_amount` DECIMAL(18,2) COMMENT 'Additional or return premium generated by this endorsement. Positive for additional premium, negative for return premium. Feeds BillingCenter and WP/EP accounting.',
    `premium_impact_type` STRING COMMENT 'Indicates whether the premium impact is an additional charge, return credit, flat (no change), or waived. Drives billing transaction type in BillingCenter.. Valid values are `additional|return|flat|waived`',
    `prior_deductible_amount` DECIMAL(18,2) COMMENT 'Deductible amount in force before this endorsement. Supports before/after audit trail for deductible changes and claims payment calculations.',
    `prior_limit_amount` DECIMAL(18,2) COMMENT 'Coverage limit in force immediately before this endorsement was applied. Enables before/after comparison for UW analysis, audit, and claims coverage determination.',
    `regulatory_filing_number` STRING COMMENT 'State DOI or SERFF filing number associated with this endorsement form. Required for approved form tracking and regulatory examination responses.',
    `regulatory_filing_required_flag` BOOLEAN COMMENT 'Indicates whether this endorsement form requires a state DOI filing before use. Supports compliance tracking for rate and form filing obligations.',
    `requested_by_party_type` STRING COMMENT 'Type of party who initiated the endorsement request. Supports producer commission attribution, UW workflow routing, and regulatory audit of mid-term changes.. Valid values are `insured|agent|broker|underwriter|system`',
    `retroactive_date` DATE COMMENT 'Retroactive date established or modified by this endorsement for claims-made policies. Critical for determining coverage applicability on CGL and professional liability forms.',
    `sir_amount` DECIMAL(18,2) COMMENT 'Self-Insured Retention dollar threshold established or modified by this endorsement. Applicable to commercial lines where the insured retains a layer of risk below the policy limit.',
    `source_system_code` STRING COMMENT 'Identifies the originating policy administration system that created this endorsement record. Supports data lineage, reconciliation, and Silver Layer provenance tracking.. Valid values are `GUIDEWIRE_PC|DUCK_CREEK|SAPIENS_IDIT|LEGACY`',
    `source_system_endt_ref` STRING COMMENT 'Native endorsement identifier from the originating policy administration system (e.g., Guidewire PolicyCenter job number). Enables cross-system reconciliation and traceability.',
    `subrogation_waiver_flag` BOOLEAN COMMENT 'Indicates whether this endorsement includes a waiver of subrogation rights against a specified party. Impacts recovery and SubroFT processes in ClaimCenter.',
    `tiv_impact_amount` DECIMAL(18,2) COMMENT 'Change in Total Insured Value resulting from this endorsement. Used for property CAT modeling, PML calculations, and reinsurance cession adjustments.',
    `transaction_reason_code` STRING COMMENT 'Coded reason for the endorsement transaction (e.g., insured request, UW correction, regulatory mandate, audit adjustment). Used for NAIC transaction reporting and analytics.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp of the most recent modification to the endorsement record. Used for change data capture, incremental ETL, and audit compliance.',
    `uw_approval_required_flag` BOOLEAN COMMENT 'Indicates whether this endorsement requires underwriter approval before binding. Drives workflow routing in PolicyCenter for non-standard or high-value ENDTs.',
    `uw_approved_by` STRING COMMENT 'Name or user ID of the underwriter who approved this endorsement. Supports UW authority audit trail and regulatory examination requirements.',
    `uw_approved_timestamp` TIMESTAMP COMMENT 'Date and time when the underwriter formally approved this endorsement. Provides a precise audit event for UW authority compliance and workflow SLA tracking.',
    `version_number` BIGINT COMMENT 'Sequential version counter incremented each time this endorsement record is amended. Supports optimistic concurrency control and historical version tracking in the lakehouse.',
    CONSTRAINT pk_endorsement PRIMARY KEY(`endorsement_id`)
) COMMENT 'ENDT records modifying, adding, or deleting coverage on a policy, including AI grants, subrogation waivers, and mid-term amendments. Captures endorsement type, form number, edition/effective date, premium impact, beneficiary/scope, and prior vs new values.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` (
    `exclusion_id` BIGINT COMMENT 'Unique surrogate identifier for a coverage exclusion, sublimit, condition, or warranty record in the P&C policy administration system.',
    `coverage_form_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_form. Business justification: Exclusions reference ISO or proprietary forms that define the exclusion language. The exclusion table has iso_form_number (STRING) but lacks FK to coverage_form catalog.',
    `effective_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Exclusion effective dates determine coverage applicability at time of loss. New FK needed for temporal tracking and claims adjudication.',
    `endorsement_id` BIGINT COMMENT 'Reference to the endorsement that introduced or modified this exclusion, if applicable. Null when the exclusion originates from the base coverage form.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Reference to the parent coverage form or endorsement to which this exclusion clause is attached.',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which this exclusion applies, enabling direct policy-level exclusion reporting without joining through coverage.',
    `bureau_filed_flag` BOOLEAN COMMENT 'Indicates whether this clause has been filed with and approved by a rating bureau (ISO/Verisk) or state Department of Insurance (DOI) for use.',
    `cat_peril_flag` BOOLEAN COMMENT 'Indicates whether this exclusion relates to a catastrophe (CAT) peril such as hurricane, earthquake, or flood, relevant for CAT modeling and reinsurance cession.',
    `claims_handling_note` STRING COMMENT 'Operational guidance for claims adjusters on how to apply this exclusion during adjudication, including coverage denial language and documentation requirements.',
    `clause_name` STRING COMMENT 'Human-readable name of the exclusion or condition clause as it appears on the policy form, e.g., Pollution Exclusion or War and Terrorism Exclusion.',
    `clause_status` STRING COMMENT 'Current lifecycle status of the exclusion clause: active (in force), inactive (not yet effective), pending (awaiting approval), superseded (replaced), or voided.. Valid values are `active|inactive|pending|superseded|voided`',
    `clause_summary` STRING COMMENT 'Plain-language summary of the clause for use in consumer-facing disclosures, declarations pages, and regulatory plain-language requirements.',
    `clause_text` STRING COMMENT 'Full verbatim text of the exclusion, sublimit, condition, or warranty clause as it appears in the policy form or endorsement wording.',
    `clause_type` STRING COMMENT 'Categorizes the clause as an exclusion (removes coverage), sublimit (caps coverage), condition (imposes obligation), warranty (guarantees a fact), or limitation.. Valid values are `exclusion|sublimit|condition|warranty|limitation`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this exclusion record was first created in the system of record, used for audit trail and data lineage in the Databricks Silver layer.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the sublimit amount, e.g., USD, CAD, GBP. Defaults to USD for domestic policies.. Valid values are `^[A-Z]{3}$`',
    `cyber_flag` BOOLEAN COMMENT 'Indicates whether this clause is a cyber or data breach exclusion, relevant for silent cyber exposure management and regulatory cyber reporting.',
    `effective_date` DATE COMMENT 'Date on which this exclusion clause becomes effective and enforceable under the policy or endorsement.',
    `expiration_date` DATE COMMENT 'Date on which this exclusion clause ceases to be effective. Null for clauses that persist for the full policy term.',
    `itv_impact_flag` BOOLEAN COMMENT 'Indicates whether this exclusion or sublimit affects the Insurance to Value (ITV) calculation for the insured property, relevant for coinsurance and valuation reporting.',
    `lob_code` STRING COMMENT 'NAIC or internal Line of Business code to which this exclusion applies, e.g., GL, CGL, BOP, WC, APD. [ENUM-REF-CANDIDATE: GL|CGL|BOP|WC|APD|BI|PD|UM|UIM|PIP|MedPay — promote to reference product]',
    `manuscript_flag` BOOLEAN COMMENT 'Indicates whether this exclusion clause is a manuscript (non-standard, bespoke) clause negotiated for this specific policy rather than a standard bureau form.',
    `naic_line_code` STRING COMMENT 'NAIC statutory line of business code associated with this exclusion for annual statement and statutory reporting purposes.. Valid values are `^[0-9]{2,4}$`',
    `number` STRING COMMENT 'Externally visible alphanumeric identifier for this exclusion clause, used on declarations pages and correspondence with insureds and brokers.. Valid values are `^EXC-[A-Z0-9]{4,20}$`',
    `peril_class` STRING COMMENT 'The peril or hazard category excluded or limited by this clause, e.g., flood, earthquake, pollution, terrorism, cyber, mold. [ENUM-REF-CANDIDATE: flood|earthquake|pollution|terrorism|cyber|mold|war|nuclear — promote to reference product]',
    `pollution_flag` BOOLEAN COMMENT 'Indicates whether this clause is an absolute or qualified pollution exclusion, relevant for environmental liability underwriting and claims adjudication.',
    `property_class` STRING COMMENT 'The class of property or liability to which the exclusion scope is restricted, e.g., real property, personal property, bodily injury (BI), property damage (PD).',
    `regulatory_approval_number` STRING COMMENT 'State DOI or NAIC filing approval number for this clause form, required for statutory compliance and rate/form filing documentation.',
    `reinsurance_impact_flag` BOOLEAN COMMENT 'Indicates whether this exclusion has a material impact on reinsurance treaty cession eligibility or facultative (FAC) placement, flagging for RI bordereaux review.',
    `scope` STRING COMMENT 'Indicates whether the exclusion applies broadly (blanket), to a scheduled item, a specific location, a specific vehicle, named perils only, or all-risk basis.. Valid values are `blanket|scheduled|location_specific|vehicle_specific|named_peril|all_risk`',
    `sir_amount` DECIMAL(18,2) COMMENT 'Self-Insured Retention dollar amount associated with this exclusion or condition clause, applicable to commercial lines where the insured retains a layer of risk.',
    `source_system_ref` STRING COMMENT 'Native primary key or record identifier from the originating source system, used for lineage tracing and reconciliation with upstream policy administration systems.',
    `state_code` STRING COMMENT 'Two-letter US state code where this exclusion clause is applicable or was filed, per USPS/NAIC state code standards.. Valid values are `^[A-Z]{2}$`',
    `sublimit_amount` DECIMAL(18,2) COMMENT 'Maximum dollar amount payable under this clause when clause_type is sublimit. Null for pure exclusions, conditions, or warranties.',
    `sublimit_basis` STRING COMMENT 'Defines how the sublimit amount is applied: per occurrence, per claim, in the aggregate, per insured location, or per scheduled item.. Valid values are `per_occurrence|per_claim|aggregate|per_location|per_item`',
    `terrorism_flag` BOOLEAN COMMENT 'Indicates whether this clause is a terrorism exclusion, relevant for TRIA (Terrorism Risk Insurance Act) compliance and federal backstop reporting.',
    `tiv_reduction_amount` DECIMAL(18,2) COMMENT 'Dollar amount by which this exclusion reduces the Total Insured Value (TIV) for the affected location or schedule item, used in CAT modeling and PML calculations.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this exclusion record, supporting change data capture (CDC) and incremental Silver layer processing.',
    `uw_authority_level` STRING COMMENT 'Underwriting authority level required to approve or waive this exclusion clause, from standard automated to chief underwriter or reinsurer sign-off.. Valid values are `standard|referral|senior_uw|chief_uw|reinsurer`',
    `version_number` BIGINT COMMENT 'Monotonically increasing version counter for this exclusion record, incremented on each material change to support policy form version control and audit.',
    `waiver_endorsement_ref` STRING COMMENT 'Reference number of the endorsement that waives this exclusion, populated only when waiver_flag is true.',
    `waiver_flag` BOOLEAN COMMENT 'Indicates whether this exclusion has been waived by endorsement or underwriting agreement, restoring coverage for the excluded peril or property class.',
    CONSTRAINT pk_exclusion PRIMARY KEY(`exclusion_id`)
) COMMENT 'Coverage exclusions, sublimits, conditions, and warranties attached to a coverage form or endorsement. Records clause type, peril/property class scope, and sublimit amount.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` (
    `additional_insured_id` BIGINT COMMENT 'Unique surrogate identifier for the additional insured endorsement record on a policy. Primary key for the additional_insured entity in the coverage domain.',
    `effective_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Additional insured effective dates determine coverage applicability for certificate holders. New FK needed for temporal tracking and certificate issuance.',
    `endorsement_id` BIGINT COMMENT 'Reference to the endorsement record that formally grants additional insured status. Links to the ENDT that modifies the base policy to add this party.',
    `insured_entity_id` BIGINT COMMENT 'Reference to the party master record representing the additional insured entity (person or organization). Provides identity resolution for the AI.',
    `insured_location_id` BIGINT COMMENT 'Reference to the specific insured location or premises associated with this additional insured grant. Scopes AI coverage to a defined property or job site.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Reference to the specific coverage line under the policy to which this additional insureds rights apply. Scopes the AI grant to a particular coverage.',
    `policy_id` BIGINT COMMENT 'Reference to the parent policy to which this additional insured endorsement is attached. Links the AI record to its governing policy contract.',
    `added_by_user` STRING COMMENT 'Username or system identifier of the underwriter or policy service representative who added this additional insured record to the policy in the policy administration system.',
    `added_date` DATE COMMENT 'Calendar date on which the additional insured was added to the policy in the policy administration system. Used for audit trail and endorsement processing records.',
    `additional_premium` DECIMAL(18,2) COMMENT 'Incremental premium charged for adding this additional insured endorsement to the policy. Contributes to gross written premium (GWP) and earned premium (EP) calculations.',
    `aggregate_limit` DECIMAL(18,2) COMMENT 'Maximum aggregate dollar amount payable for all claims involving the additional insured during the policy period. May be sub-limited below the policy aggregate.',
    `ai_address_line1` STRING COMMENT 'First line of the additional insureds mailing or registered address. Used for certificate delivery, notice of cancellation, and claims correspondence.',
    `ai_address_line2` STRING COMMENT 'Second line of the additional insureds mailing or registered address (suite, floor, unit). Supplements address line 1 for complete address capture.',
    `ai_city` STRING COMMENT 'City of the additional insureds mailing or registered address. Required for certificate issuance and regulatory notice compliance.',
    `ai_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for the additional insureds address. Required for international policies and cross-border certificate issuance.. Valid values are `^[A-Z]{3}$`',
    `ai_name` STRING COMMENT 'Full legal name of the additional insured party as it appears on the endorsement and certificate of insurance. Used for claims and legal correspondence.',
    `ai_number` STRING COMMENT 'Externally visible business identifier for this additional insured record, used on certificates of insurance and correspondence. Unique within the policy.. Valid values are `^AI-[0-9]{8,12}$`',
    `ai_postal_code` STRING COMMENT 'ZIP or postal code of the additional insureds address. Used for geographic rating, certificate issuance, and regulatory notice delivery.. Valid values are `^[0-9]{5}(-[0-9]{4})?$`',
    `ai_state_code` STRING COMMENT 'Two-letter US state or territory code for the additional insureds address. Used for regulatory jurisdiction determination and certificate compliance.. Valid values are `^[A-Z]{2}$`',
    `ai_status` STRING COMMENT 'Current lifecycle status of the additional insured endorsement record. Drives certificate issuance eligibility and claims coverage validation.. Valid values are `active|inactive|pending|cancelled|expired`',
    `ai_type` STRING COMMENT 'Classifies the additional insured as an individual, organization, government entity, trust, or joint venture. Drives certificate formatting and coverage scope rules.. Valid values are `organization|individual|government|trust|joint_venture`',
    `auto_cert_issuance_flag` BOOLEAN COMMENT 'Indicates whether certificates of insurance for this additional insured should be automatically generated and distributed upon policy issuance or renewal.',
    `cancellation_date` DATE COMMENT 'Date on which the additional insured endorsement was cancelled or removed from the policy prior to its scheduled expiration. Null if not cancelled.',
    `cancellation_reason` STRING COMMENT 'Reason code for the cancellation of the additional insured endorsement. Required for regulatory reporting and audit trail in states with mandatory cancellation notice rules.. Valid values are `contract_expired|insured_request|underwriter_decision|non_payment|other`',
    `certificate_holder_flag` BOOLEAN COMMENT 'Indicates whether the additional insured is also designated as a certificate holder on the ACORD 25 certificate of insurance. Drives automated certificate generation.',
    `contract_reference` STRING COMMENT 'Reference number or description of the underlying contract, lease, or agreement that requires the additional insured designation. Provides audit trail for AI requirement.',
    `coverage_scope` STRING COMMENT 'Defines the scope of coverage granted to the AI: ongoing operations, completed operations, both, products liability, or premises only. Directly tied to the endorsement form selected.. Valid values are `ongoing_operations|completed_operations|both|products_liability|premises`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this additional insured record was first created in the data platform. Used for audit trail, data lineage, and Silver layer ingestion tracking.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this additional insured record (limits, premium). Defaults to USD for domestic policies.. Valid values are `^[A-Z]{3}$`',
    `dba_name` STRING COMMENT 'Trade or operating name of the additional insured if different from the legal name. Captured for certificate issuance and claims identification purposes.',
    `effective_date` DATE COMMENT 'Date on which the additional insured endorsement becomes effective and coverage rights are granted to the AI party. Must fall within the policy term.',
    `endorsement_form_edition` STRING COMMENT 'Edition date of the ISO or proprietary endorsement form (MM/YY format), indicating the version of the AI grant language in use. Critical for coverage interpretation.. Valid values are `^[0-9]{2}/[0-9]{2}$`',
    `endorsement_form_number` STRING COMMENT 'ISO or proprietary form number of the additional insured endorsement (e.g., CG 20 10, CG 20 26, CG 20 33, CG 20 37). Identifies the exact AI grant language applied.',
    `exclusions_description` STRING COMMENT 'Free-text description of any specific exclusions or limitations applied to the additional insureds coverage grant beyond the standard endorsement form language.',
    `expiration_date` DATE COMMENT 'Date on which the additional insured endorsement expires and coverage rights terminate. Typically co-terminus with the policy expiration date unless separately scheduled.',
    `lob_code` STRING COMMENT 'Line of business under which this additional insured endorsement is issued (e.g., GL, CGL, BOP, WC, APD). Determines applicable coverage forms and regulatory requirements.',
    `notice_of_cancellation_days` BIGINT COMMENT 'Number of days advance written notice of cancellation or material change that must be provided to the additional insured. Typically 30 or 60 days per contract requirement.',
    `occurrence_limit` DECIMAL(18,2) COMMENT 'Maximum dollar amount payable per occurrence for claims involving the additional insured under this endorsement. May be sub-limited below the policy occurrence limit.',
    `primary_noncontributory_flag` BOOLEAN COMMENT 'Indicates whether the policy is designated as primary and non-contributory with respect to the additional insureds own insurance. Common contractual requirement in construction and leasing.',
    `project_description` STRING COMMENT 'Description of the specific project, location, or operations for which the additional insured designation applies. Scopes the AI grant to defined work or premises.',
    `relationship_type` STRING COMMENT 'Categorizes the contractual relationship between the named insured and the additional insured (e.g., lessor, lender, owner, contractor, mortgagee). [ENUM-REF-CANDIDATE: lessor|lender|owner|contractor|mortgagee|franchisor|vendor|co-owner — promote to. Valid values are `lessor|lender|owner|contractor|mortgagee|other`',
    `source_system_code` STRING COMMENT 'Identifies the originating policy administration system from which this additional insured record was sourced (e.g., Guidewire PolicyCenter, Duck Creek, Sapiens IDIT).. Valid values are `GUIDEWIRE|DUCK_CREEK|SAPIENS|MANUAL`',
    `source_system_ref_code` STRING COMMENT 'Native record identifier from the originating policy administration system for this additional insured record. Enables lineage tracing and reconciliation with source systems.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this additional insured record in the data platform. Supports change data capture (CDC) and incremental processing in the Silver layer.',
    `waiver_of_subrogation_flag` BOOLEAN COMMENT 'Indicates whether a waiver of subrogation in favor of the additional insured has been endorsed onto the policy. Prevents the insurer from pursuing recovery against the AI.',
    CONSTRAINT pk_additional_insured PRIMARY KEY(`additional_insured_id`)
) COMMENT 'Additional insured (AI) endorsement records granting third-party coverage rights on a policy. Captures AI name, relationship type (lessor, lender, owner), endorsement form, and scope of coverage granted.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` (
    `named_insured_id` BIGINT COMMENT 'Unique surrogate identifier for a named insured record on a policy declarations page. Primary key for the named_insured data product in the coverage domain.',
    `effective_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Named insured effective dates track when parties are added/removed from coverage. New FK needed for temporal tracking and coverage determination.',
    `insured_entity_id` BIGINT COMMENT 'Reference to the enterprise party master record representing this named insured. Enables cross-policy party consolidation and 360-degree view.',
    `policy_id` BIGINT COMMENT 'Reference to the policy on whose declarations page (DEC) this named insured appears. Links the named insured to its parent policy record.',
    `annual_payroll` DECIMAL(18,2) COMMENT 'Total annual payroll of the commercial named insured in USD. Primary exposure base for workers compensation (WC) premium rating and NCCI experience modification calculation.',
    `annual_revenue` DECIMAL(18,2) COMMENT 'Reported annual gross revenue of the commercial named insured in USD. Used as an exposure base for general liability (GL) and commercial general liability (CGL) premium rating.',
    `consent_to_electronic_delivery` BOOLEAN COMMENT 'Indicates whether the named insured has consented to receive policy documents, notices, and the declarations page (DEC) electronically. Required for e-delivery compliance under state DOI rules.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this named insured record was first created in the policy administration system. Supports audit trail, data lineage, and NAIC regulatory compliance requirements.',
    `credit_score_tier` STRING COMMENT 'Insurance credit score tier derived from the named insureds credit report. Used as a rating factor for personal lines where permitted; actual score is not stored per FCRA requirements.. Valid values are `preferred|standard|non_standard|unscored`',
    `date_of_birth` DATE COMMENT 'Date of birth of the individual named insured. Used for age-based underwriting rating, eligibility determination, and actuarial segmentation in personal lines.',
    `date_of_incorporation` DATE COMMENT 'Date on which the commercial named insured was legally incorporated or formed. Used for years-in-business underwriting factor and commercial eligibility rules.',
    `dba_name` STRING COMMENT 'Trade or assumed name under which the insured operates, distinct from the registered legal name. Commonly used for commercial lines where the entity trades as a DBA.',
    `effective_date` DATE COMMENT 'Date on which this named insureds coverage became effective on the policy. May differ from the policy effective date when added by endorsement mid-term.',
    `email` STRING COMMENT 'Primary email address of the named insured used for policy correspondence, renewal notices, and digital document delivery on the declarations page.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `endorsement_number` STRING COMMENT 'Endorsement (ENDT) number by which this named insured was added or removed from the policy mid-term. Null for named insureds present at policy inception.',
    `expiration_date` DATE COMMENT 'Date on which this named insureds coverage expires or was removed from the policy. Null for active named insureds whose coverage runs to the policy expiration date.',
    `fein` STRING COMMENT 'IRS-issued Federal Employer Identification Number (FEIN) for commercial named insureds. Used for statutory reporting, premium audit, and workers compensation payroll verification.. Valid values are `^[0-9]{2}-[0-9]{7}$`',
    `gender` STRING COMMENT 'Self-reported gender of the individual named insured. Used for personal lines underwriting rating in jurisdictions where gender-based rating is permitted by state DOI.. Valid values are `male|female|non_binary|not_disclosed`',
    `insured_role` STRING COMMENT 'Role of this party on the declarations page. First named insured has primary rights and obligations; additional named insureds share coverage. [ENUM-REF-CANDIDATE: first_named|additional_named|mortgagee|loss_payee|additional_interest — promote to. Valid values are `first_named|additional_named|mortgagee|loss_payee|additional_interest`',
    `insured_type` STRING COMMENT 'Legal entity type of the named insured. Drives underwriting eligibility, form selection, and regulatory reporting. [ENUM-REF-CANDIDATE: individual|corporation|partnership|llc|trust|government|non_profit — promote to reference product]',
    `is_first_named` BOOLEAN COMMENT 'Indicates whether this party is the first named insured on the declarations page (DEC). The first named insured holds primary rights including cancellation authority and premium refund entitlement.',
    `is_primary_contact` BOOLEAN COMMENT 'Indicates whether this named insured is the primary contact for policy correspondence, billing notices, and renewal communications. Only one named insured per policy should be flagged true.',
    `legal_name` STRING COMMENT 'Full legal name of the named insured as it appears on the declarations page (DEC). For individuals this is the full personal name; for entities it is the registered legal name.',
    `lob_code` STRING COMMENT 'Primary line of business (LOB) code associated with this named insureds policy. Drives form selection, rating algorithm, and statutory reporting classification.',
    `marital_status` STRING COMMENT 'Marital status of the individual named insured. Used as a personal lines underwriting (UW) rating variable for auto and homeowners policies where permitted by state DOI.. Valid values are `single|married|divorced|widowed|domestic_partner`',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code identifying the writing insurance company for this named insureds policy. Required for NAIC Annual Statement and state regulatory filings.. Valid values are `^[0-9]{5}$`',
    `naics_code` STRING COMMENT 'Six-digit North American Industry Classification System (NAICS) code describing the primary business activity of the commercial named insured. Used for class-of-business rating and underwriting.. Valid values are `^[0-9]{6}$`',
    `named_insured_status` STRING COMMENT 'Current lifecycle status of this named insured on the policy. Active indicates coverage is in force; removed indicates the party was deleted by endorsement.. Valid values are `active|inactive|pending|removed|suspended`',
    `num_employees` BIGINT COMMENT 'Total number of full-time equivalent employees of the commercial named insured. Used as an underwriting (UW) eligibility factor and exposure indicator for workers compensation (WC) and GL.',
    `phone` STRING COMMENT 'Primary contact phone number for the named insured. Used for underwriting contact, claims first notice of loss (FNOL) intake, and billing communications.. Valid values are `^+?[0-9-s().]{7,20}$`',
    `primary_address_line1` STRING COMMENT 'First line of the named insureds primary mailing address as shown on the declarations page. Used for policy correspondence, premium billing, and regulatory filings.',
    `primary_address_line2` STRING COMMENT 'Second line of the named insureds primary mailing address (suite, unit, floor, PO Box). Supplements address line 1 for complete address representation on the DEC.',
    `primary_city` STRING COMMENT 'City of the named insureds primary mailing address. Used for territory rating, regulatory jurisdiction determination, and statutory reporting.',
    `primary_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the named insureds primary mailing address. Supports multinational commercial policies and IFRS 17 jurisdictional reporting.. Valid values are `^[A-Z]{3}$`',
    `primary_state` STRING COMMENT 'Two-letter US state code of the named insureds primary mailing address. Determines the governing state for policy issuance, rate filing, and regulatory compliance.. Valid values are `^[A-Z]{2}$`',
    `primary_zip` STRING COMMENT 'ZIP or ZIP+4 postal code of the named insureds primary mailing address. Used for territory rating, catastrophe (CAT) zone assignment, and USPS deliverability.. Valid values are `^[0-9]{5}(-[0-9]{4})?$`',
    `removal_reason` STRING COMMENT 'Reason code explaining why this named insured was removed from the policy. Populated only when status is removed or inactive; supports audit and regulatory compliance.',
    `sequence_number` BIGINT COMMENT 'Ordinal position of this named insured on the declarations page. The first named insured is sequence 1; subsequent named insureds are numbered sequentially.',
    `sic_code` STRING COMMENT 'Four-digit Standard Industrial Classification (SIC) code for the named insureds primary industry. Legacy classification used alongside NAICS for ISO rating and NAIC statutory reporting.. Valid values are `^[0-9]{4}$`',
    `source_system_ref` STRING COMMENT 'Native identifier of this named insured record in the originating policy administration system (e.g., Guidewire PolicyCenter internal ID). Enables traceability back to the system of record.',
    `ssn_masked` STRING COMMENT 'Masked Social Security Number (SSN) for individual named insureds, storing only the last four digits. Full SSN is stored in a restricted vault; this field supports identity verification without full exposure.. Valid values are `^XXX-XX-[0-9]{4}$`',
    `state_of_incorporation` STRING COMMENT 'Two-letter US state code where the commercial named insured is legally incorporated or domiciled. Drives jurisdictional form selection and regulatory compliance.. Valid values are `^[A-Z]{2}$`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this named insured record. Used for change data capture (CDC), incremental ETL processing, and audit trail in the Databricks Silver layer.',
    `years_in_business` BIGINT COMMENT 'Number of years the commercial named insured has been continuously operating. Used as an underwriting (UW) rating factor for commercial lines eligibility and experience credit.',
    CONSTRAINT pk_named_insured PRIMARY KEY(`named_insured_id`)
) COMMENT 'Named insured parties listed on the declarations page (DEC) of a policy. Supports multiple named insureds per policy with role (first named, additional named), FEIN/SSN reference, and DBA name.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` (
    `amendment_id` BIGINT COMMENT 'Unique surrogate identifier for a mid-term coverage amendment record on a policy. Primary key of the coverage_amendment product.',
    `effective_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Amendment effective dates drive mid-term rating changes and earned premium calculations. New FK needed for temporal analytics and premium earning.',
    `endorsement_id` BIGINT COMMENT 'Foreign key linking to coverage.endorsement. Business justification: Amendments track mid-term changes to coverage terms and are typically implemented via formal endorsements.',
    `insured_location_id` BIGINT COMMENT 'Reference to the specific insured location affected by this amendment, applicable for property and GL location-level changes.',
    `insured_vehicle_id` BIGINT COMMENT 'Reference to the specific insured vehicle affected by this amendment, applicable for APD, BI/PD, UM/UIM, and PIP coverage changes.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Reference to the specific coverage line being amended on the policy.',
    `policy_id` BIGINT COMMENT 'Reference to the policy on which this mid-term coverage amendment is applied.',
    `policy_transaction_id` BIGINT COMMENT 'Native transaction or job ID from the originating policy administration system, enabling traceability back to the system of record.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the agent or broker who submitted or requested this coverage amendment on behalf of the insured.',
    `uw_decision_id` BIGINT COMMENT 'Reference to the underwriter who reviewed and approved this coverage amendment. Required for UW authority audit trails.',
    `amendment_number` STRING COMMENT 'Externally visible business identifier for this amendment, used in correspondence, audit trails, and bordereaux reporting.. Valid values are `^AMD-[0-9]{4}-[0-9]{6}$`',
    `amendment_status` STRING COMMENT 'Current workflow lifecycle state of the amendment from initiation through application or rejection.. Valid values are `draft|pending_approval|approved|applied|rejected|voided`',
    `amendment_type` STRING COMMENT 'Categorizes the nature of the mid-term change. [ENUM-REF-CANDIDATE: limit_change|deductible_change|sir_change|location_add|location_remove|vehicle_add|vehicle_remove|coverage_add|coverage_remove — promote to reference product]',
    `applied_timestamp` TIMESTAMP COMMENT 'Date and time at which the amendment was committed to the policy administration system and coverage terms were updated.',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time at which an authorized underwriter or system workflow approved the coverage amendment.',
    `change_reason_code` STRING COMMENT 'Standardized code identifying the business reason for the mid-term amendment (e.g., insured request, underwriter correction, regulatory mandate, audit finding).',
    `change_reason_description` STRING COMMENT 'Free-text narrative explaining the business justification for the coverage amendment, captured at time of entry.',
    `coverage_form_number` STRING COMMENT 'ISO or proprietary form number of the coverage being amended (e.g., CG 00 01, HO 00 03). Identifies the specific policy form.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the amendment record was first created in the data platform. Used for audit and data lineage.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this amendment record (e.g., USD, CAD).. Valid values are `^[A-Z]{3}$`',
    `effective_date` DATE COMMENT 'Date on which the amended coverage terms become contractually binding. Drives pro-rata premium adjustment calculations.',
    `expiration_date` DATE COMMENT 'Date on which the amended terms expire, if the change is temporary. Null for permanent mid-term amendments.',
    `itv_ratio` DECIMAL(7,4) COMMENT 'Insurance to Value (ITV) ratio after the amendment, calculated as new TIV divided by replacement cost value. Flags coinsurance exposure.',
    `lob_code` STRING COMMENT 'NAIC-aligned Line of Business code identifying the insurance product line to which the amended coverage belongs. [ENUM-REF-CANDIDATE: GL|CGL|BOP|WC|APD|HO|CPP|IM|UMBR|EXCESS — 10 candidates stripped; promote to reference product]',
    `new_deductible_amount` DECIMAL(18,2) COMMENT 'Deductible amount effective after this amendment. Drives re-rating and impacts insureds out-of-pocket exposure.',
    `new_limit_amount` DECIMAL(18,2) COMMENT 'Coverage limit effective after this amendment is applied. Used for premium re-rating and reinsurance cession recalculation.',
    `new_sir_amount` DECIMAL(18,2) COMMENT 'Self-Insured Retention (SIR) amount effective after this amendment. Impacts claims payment thresholds and reinsurance attachment.',
    `new_tiv_amount` DECIMAL(18,2) COMMENT 'Total Insured Value (TIV) effective after this amendment. Drives property premium re-rating and reinsurance treaty cession updates.',
    `notes` STRING COMMENT 'Free-text underwriter or operations notes providing additional context for the amendment, visible in the policy file and audit log.',
    `premium_impact_amount` DECIMAL(18,2) COMMENT 'Net additional or return premium resulting from this amendment, calculated pro-rata from the effective date to policy expiration.',
    `premium_impact_type` STRING COMMENT 'Indicates whether the amendment generates an additional premium charge, a return premium credit, or a flat (no-change) premium adjustment.. Valid values are `additional|return|flat`',
    `prior_deductible_amount` DECIMAL(18,2) COMMENT 'Deductible amount in force immediately before this amendment. Supports before/after comparison for premium adjustment.',
    `prior_limit_amount` DECIMAL(18,2) COMMENT 'Coverage limit in force immediately before this amendment. Retained for audit, regulatory, and premium adjustment purposes.',
    `prior_sir_amount` DECIMAL(18,2) COMMENT 'Self-Insured Retention (SIR) amount in force before this amendment. Relevant for large commercial and excess liability lines.',
    `prior_tiv_amount` DECIMAL(18,2) COMMENT 'Total Insured Value (TIV) of the insured property or schedule before this amendment. Used for ITV analysis and CAT modeling.',
    `regulatory_filing_reference` STRING COMMENT 'State DOI filing reference number associated with this amendment when a regulatory filing is required and submitted.',
    `regulatory_filing_required` BOOLEAN COMMENT 'Indicates whether this amendment triggers a state DOI rate or form filing obligation under applicable insurance regulations.',
    `reinsurance_impact_flag` BOOLEAN COMMENT 'Indicates whether this amendment materially affects reinsurance treaty cession amounts, requiring bordereaux update or facultative re-placement.',
    `requested_date` DATE COMMENT 'Calendar date on which the insured, producer, or underwriter formally requested the coverage amendment.',
    `requires_endorsement` BOOLEAN COMMENT 'Indicates whether this amendment requires a formal endorsement document to be issued to the insured per policy terms or state regulation.',
    `source_system_code` STRING COMMENT 'Identifies the originating policy administration system from which this amendment record was ingested into the data lakehouse.. Valid values are `GUIDEWIRE_PC|DUCK_CREEK|SAPIENS_IDIT|MANUAL`',
    `state_code` STRING COMMENT 'Two-letter US state code where the amended coverage is domiciled or the risk is located. Drives regulatory filing and rate applicability.. Valid values are `^[A-Z]{2}$`',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp of the most recent modification to this amendment record. Supports change data capture and audit compliance.',
    `uw_authority_level` STRING COMMENT 'Underwriting authority tier required to approve this amendment based on limit size, LOB, and risk characteristics.. Valid values are `auto_approved|underwriter|senior_underwriter|manager|referral_required`',
    CONSTRAINT pk_amendment PRIMARY KEY(`amendment_id`)
) COMMENT 'Tracks mid-term amendments to coverage terms (limit changes, deductible changes, added/removed locations or vehicles) outside of a full endorsement cycle. Records change reason, effective date, and prior vs new values.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` (
    `itv_assessment_id` BIGINT COMMENT 'Unique surrogate identifier for each Insurance-to-Value assessment record on an insured property location.',
    `effective_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Assessment effective dates determine when coinsurance penalties apply. New FK needed for temporal tracking and underwriting decisions.',
    `insured_location_id` BIGINT COMMENT 'Reference to the insured property location record being assessed for Insurance-to-Value adequacy.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Reference to the specific coverage line (e.g., building, contents, BOP property) to which this ITV assessment applies.',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which the insured location is covered and for which this ITV assessment is performed.',
    `acv_estimate` DECIMAL(18,2) COMMENT 'Actual Cash Value (ACV) estimate for the insured property, calculated as RCV less depreciation, used for ACV policy settlements.',
    `agreed_value_flag` BOOLEAN COMMENT 'Indicates whether the policy carries an Agreed Value endorsement, suspending the coinsurance clause for this location.',
    `assessed_rcv` DECIMAL(18,2) COMMENT 'Replacement Cost Value (RCV) determined by the assessment methodology, representing the estimated cost to rebuild the structure at current prices.',
    `assessment_date` DATE COMMENT 'Calendar date on which the ITV assessment was conducted or the valuation report was produced.',
    `assessment_method` STRING COMMENT 'Valuation methodology used to derive the Replacement Cost Value (RCV). [ENUM-REF-CANDIDATE: marshall_swift|corelogic|xactware|internal_model|broker_estimate|appraisal — promote to reference product]. Valid values are `marshall_swift|corelogic|xactware|internal_model|broker_estimate|appraisal`',
    `assessment_number` STRING COMMENT 'Externally visible business identifier for this ITV assessment, used in underwriting correspondence and bordereaux reporting.. Valid values are `^ITV-[0-9]{4}-[0-9]{8}$`',
    `assessment_status` STRING COMMENT 'Current workflow status of the ITV assessment record, driving underwriting action and coinsurance penalty determination.. Valid values are `pending|in_review|completed|waived|expired`',
    `assessment_type` STRING COMMENT 'Business trigger category for this assessment: new business underwriting, renewal review, mid-term endorsement, post-loss, or regulatory requirement.. Valid values are `new_business|renewal|mid_term|post_loss|regulatory`',
    `assessor_credential` STRING COMMENT 'Professional credential or license of the assessor (e.g., MAI, ASA, SRA), supporting regulatory and E&O defensibility.',
    `assessor_name` STRING COMMENT 'Name of the individual, firm, or automated service that performed the ITV assessment (e.g., Marshall Swift, CoreLogic, staff appraiser).',
    `coinsurance_pct` DECIMAL(5,2) COMMENT 'Contractual coinsurance percentage required by the policy (e.g., 80%, 90%, 100%) against which the ITV ratio is evaluated.',
    `coinsurance_penalty_flag` BOOLEAN COMMENT 'Indicates whether the insured property is underinsured relative to the coinsurance requirement, triggering a proportional loss penalty.',
    `construction_type` STRING COMMENT 'ISO COPE construction classification of the insured building, a primary driver of replacement cost and fire loss severity.. Valid values are `frame|joisted_masonry|masonry_noncombustible|modified_fire_resistive|fire_resistive`',
    `cost_index_factor` DECIMAL(8,4) COMMENT 'Regional construction cost index factor from the valuation model (e.g., Marshall Swift regional multiplier) applied to base replacement cost.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this ITV assessment record was first created in the system, used for audit trail and data lineage.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this assessment record (e.g., USD, CAD).. Valid values are `^[A-Z]{3}$`',
    `data_source` STRING COMMENT 'Originating system or data feed that supplied this ITV assessment record (e.g., Guidewire PolicyCenter, Verisk, CoreLogic).. Valid values are `guidewire_pc|duck_creek|sapiens_idit|verisk|corelogic|manual`',
    `effective_date` DATE COMMENT 'Date from which this ITV assessment is considered binding for underwriting, rating, and coinsurance penalty calculations.',
    `expiry_date` DATE COMMENT 'Date after which this ITV assessment is no longer valid and a new assessment must be ordered before policy renewal.',
    `inflation_guard_pct` DECIMAL(5,2) COMMENT 'Annual inflation guard percentage applied to the insured value to keep pace with construction cost inflation between assessments.',
    `itv_ratio` DECIMAL(7,4) COMMENT 'ITV ratio computed as reported TIV divided by assessed RCV. A ratio below the coinsurance threshold triggers a penalty flag.',
    `number_of_stories` BIGINT COMMENT 'Number of above-grade stories in the insured building, influencing replacement cost per square foot in valuation models.',
    `occupancy_code` STRING COMMENT 'ISO COPE occupancy classification code describing the primary use of the insured building (e.g., office, retail, manufacturing).',
    `protection_class` STRING COMMENT 'ISO Public Protection Classification (PPC) code (1–10) for the insured location, reflecting fire suppression capability and affecting property rates.. Valid values are `^([1-9]|10|10W)$`',
    `report_reference_number` STRING COMMENT 'External reference number of the valuation report or certificate issued by the assessment vendor, used for document retrieval.',
    `reported_tiv` DECIMAL(18,2) COMMENT 'Total Insured Value (TIV) as declared by the insured or broker on the policy application or schedule of values.',
    `roof_material` STRING COMMENT 'Primary roofing material of the insured structure, used in replacement cost estimation and CAT wind/hail underwriting.. Valid values are `asphalt_shingle|metal|tile|slate|built_up|membrane`',
    `roof_type` STRING COMMENT 'Roof geometry classification of the insured structure, affecting both replacement cost estimation and wind/hail loss susceptibility.. Valid values are `flat|gable|hip|mansard|gambrel|shed`',
    `roof_year` BIGINT COMMENT 'Year the current roof was installed or last replaced, used in depreciation schedules and wind/hail underwriting eligibility.',
    `sprinkler_flag` BOOLEAN COMMENT 'Indicates whether the insured building is equipped with an automatic fire sprinkler system, qualifying for rate credits.',
    `total_area_sqft` DECIMAL(12,2) COMMENT 'Total gross floor area of the insured structure in square feet, used as the primary size input for replacement cost estimation.',
    `underinsurance_gap` DECIMAL(18,2) COMMENT 'Dollar shortfall between the assessed RCV and the reported TIV, representing the monetary exposure from underinsurance at this location.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this ITV assessment record, supporting audit trail and change tracking.',
    `uw_action_taken` STRING COMMENT 'Underwriting disposition recorded after review of the ITV assessment findings (e.g., limit increased, coinsurance waived, declined).. Valid values are `none|limit_increased|coinsurance_waived|policy_endorsed|declined|referred`',
    `uw_review_required_flag` BOOLEAN COMMENT 'Indicates that the ITV ratio or assessment findings require underwriter review before binding or renewal, triggering a UW referral.',
    `uw_reviewed_date` DATE COMMENT 'Date on which the underwriter completed review of the ITV assessment and recorded the UW action taken.',
    `valuation_basis` STRING COMMENT 'Policy valuation basis applied at this location: Replacement Cost Value (RCV), Actual Cash Value (ACV), Functional RCV, or Agreed Value.. Valid values are `rcv|acv|functional_rcv|agreed_value`',
    `year_built` BIGINT COMMENT 'Four-digit year the insured structure was originally constructed, used in depreciation and replacement cost calculations.',
    CONSTRAINT pk_itv_assessment PRIMARY KEY(`itv_assessment_id`)
) COMMENT 'Insurance-to-Value (ITV) assessment records for insured property locations. Captures assessed replacement cost value (RCV), reported TIV, ITV ratio, assessment method (Marshall Swift, CoreLogic), and coinsurance penalty flag.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` (
    `coverage_peril_id` BIGINT COMMENT 'Unique surrogate identifier for each coverage-peril association record in the junction table.',
    `effective_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Peril association effective dates determine coverage applicability at loss date. New FK needed for temporal tracking and claims adjudication.',
    `limit_id` BIGINT COMMENT 'Reference to a sublimit definition record that caps the insurers liability for this specific peril within the broader coverage limit.',
    `peril_coverage_peril_id` BIGINT COMMENT 'Reference to the peril definition record that is being associated with the coverage form.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Reference to the coverage form or coverage line to which this peril association belongs.',
    `aggregate_deductible_amount` DECIMAL(18,2) COMMENT 'Maximum total deductible the insured must pay for all losses from this peril in a policy period before the deductible is exhausted and full coverage applies.',
    `association_status` STRING COMMENT 'Current lifecycle status of this coverage-peril association record (ACTIVE, INACTIVE, PENDING approval, SUPERSEDED by endorsement, or WITHDRAWN).. Valid values are `ACTIVE|INACTIVE|PENDING|SUPERSEDED|WITHDRAWN`',
    `cat_designation_flag` BOOLEAN COMMENT 'Indicates whether this peril is classified as a catastrophe event for reinsurance treaty and reserving purposes.',
    `cat_event_type` STRING COMMENT 'Specific catastrophe event classification when CAT designation flag is true, used for CAT modeling and PML calculation. [ENUM-REF-CANDIDATE: hurricane|tornado|earthquake|flood|wildfire|hail|windstorm|other|none — 9 candidates stripped; promote to',
    `cat_peril_code` STRING COMMENT 'Industry-standard CAT peril code used in catastrophe modeling and reinsurance bordereaux (e.g., HU for Hurricane, EQ for Earthquake, FL for Flood, WS for Windstorm).. Valid values are `^[A-Z0-9]{2,10}$`',
    `cat_peril_flag` BOOLEAN COMMENT 'Indicates whether this peril is classified as a catastrophe (CAT) peril for reinsurance treaty cession, PML modeling, and statutory CAT reporting purposes.',
    `cat_xl_applicable_flag` BOOLEAN COMMENT 'Indicates whether this peril is covered under catastrophe excess of loss reinsurance treaties.',
    `coverage_peril_category` STRING COMMENT 'High-level classification grouping perils by origin or nature for underwriting and rating purposes. [ENUM-REF-CANDIDATE: natural|man-made|liability|theft|weather|fire|water|other — 8 candidates stripped; promote to reference product]',
    `coverage_peril_code` STRING COMMENT 'Standard industry code identifying the peril, typically ISO or carrier-specific classification code.. Valid values are `^[A-Z0-9]{2,10}$`',
    `coinsurance_percentage` DECIMAL(7,4) COMMENT 'Coinsurance percentage applicable to this peril, requiring the insured to maintain coverage at a specified percentage of TIV to avoid penalty at loss settlement.',
    `coverage_form_edition_date` DATE COMMENT 'Edition date of the coverage form version under which this peril association is defined, ensuring correct form version is applied for rating and claims.',
    `coverage_form_number` STRING COMMENT 'ISO or proprietary form number of the coverage form to which this peril is attached (e.g., ISO CP 00 10, HO 00 03). Used for rate filing and regulatory compliance.',
    `coverage_peril_status` STRING COMMENT 'Current lifecycle status of the peril definition in the reference catalog.. Valid values are `active|inactive|deprecated|pending`',
    `coverage_trigger` STRING COMMENT 'Defines the event or condition that activates coverage for this peril under policy terms.. Valid values are `occurrence|claims-made|manifestation|exposure|other`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this coverage-peril association record was first created in the data platform, used for audit trail and data lineage.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this coverage-peril record (e.g., USD, CAD, GBP).. Valid values are `^[A-Z]{3}$`',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Peril-level deductible override amount that applies specifically to this peril on this coverage, superseding the coverage-level deductible where applicable.',
    `deductible_basis` STRING COMMENT 'Basis on which the peril deductible is applied: per occurrence, per claim, annual aggregate, per location, or per unit.. Valid values are `PER_OCCURRENCE|PER_CLAIM|ANNUAL_AGGREGATE|PER_LOCATION|PER_UNIT`',
    `deductible_percentage` DECIMAL(7,4) COMMENT 'Percentage used when peril_deductible_type is PERCENTAGE, expressed as a decimal (e.g., 0.02 = 2% of TIV). Null for flat deductibles.',
    `deductible_type` STRING COMMENT 'Type of deductible applied to this peril (e.g., FLAT dollar, PERCENTAGE of loss or TIV, FRANCHISE, DISAPPEARING, SPLIT). Governs how deductible_amount is applied.. Valid values are `FLAT|PERCENTAGE|FRANCHISE|DISAPPEARING|SPLIT`',
    `coverage_peril_description` STRING COMMENT 'Detailed definition of the peril including scope of covered loss events and typical manifestations.',
    `effective_date` DATE COMMENT 'Date on which this coverage-peril association becomes effective, aligning with policy inception or endorsement effective date.',
    `endorsement_number` STRING COMMENT 'Endorsement number that introduced or modified this coverage-peril association. Null if the association originates from the base policy form.',
    `endorsement_type_code` STRING COMMENT 'Type of endorsement action that created this peril association: ADD a new peril, REMOVE an existing peril, MODIFY terms, RESTRICT coverage, or EXTEND coverage.. Valid values are `ADD|REMOVE|MODIFY|RESTRICT|EXTEND`',
    `excluded_by_default_flag` BOOLEAN COMMENT 'Indicates whether this peril is excluded by default in standard forms and requires explicit endorsement for coverage.',
    `exclusion_description` STRING COMMENT 'Free-text description of the specific exclusion language or endorsement wording applied when the peril is excluded from coverage.',
    `exclusion_reason_code` STRING COMMENT 'Standardized code describing why the peril is excluded when insured_flag is False (e.g., FLOOD_ZONE, WAR, NUCLEAR, WEAR_TEAR). Null when peril is covered. [ENUM-REF-CANDIDATE: FLOOD_ZONE|WAR|NUCLEAR|WEAR_TEAR|INTENTIONAL|REGULATORY|OTHER — promote to',
    `expiration_date` DATE COMMENT 'Date on which this coverage-peril association expires, aligning with policy expiration or endorsement termination date. Null for open-ended associations.',
    `frequency_rating` STRING COMMENT 'Typical loss frequency classification for underwriting and pricing purposes based on historical claim data.. Valid values are `rare|occasional|frequent|very-frequent`',
    `geographic_scope` STRING COMMENT 'Typical geographic extent of loss events for this peril, used for exposure aggregation and PML modeling.. Valid values are `global|regional|localized|property-specific`',
    `group_code` STRING COMMENT 'Higher-level grouping code for the peril (e.g., CAT, NON-CAT, LIABILITY, THEFT). Used for aggregation in actuarial and reinsurance reporting. [ENUM-REF-CANDIDATE: CAT|NON_CAT|LIABILITY|THEFT|WEATHER|FIRE|OTHER — promote to reference product]',
    `insurable_flag` BOOLEAN COMMENT 'Indicates whether this peril is generally insurable under standard P&C policies or typically excluded.',
    `insured_flag` BOOLEAN COMMENT 'Indicates whether the peril is covered (True) or excluded (False) under the associated coverage form. Core junction discriminator.',
    `iso_peril_code` STRING COMMENT 'ISO/Verisk standardized peril code used for industry statistical reporting, rate filings, and CLUE data exchange.. Valid values are `^[A-Z0-9]{2,10}$`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this peril record was last modified in the reference catalog.',
    `lob` STRING COMMENT 'Primary line of business where this peril is most commonly insured, such as GL, CGL, BOP, WC, APD, or property.',
    `lob_code` STRING COMMENT 'Line of business to which this coverage-peril association applies (e.g., GL, CGL, BOP, WC, APD, HO). Drives LOB-specific peril eligibility rules. [ENUM-REF-CANDIDATE: GL|CGL|BOP|WC|APD|HO|CPP|IM|MARINE|UMBRELLA|EXCESS — 11 candidates stripped; promote to',
    `loss_settlement_basis` STRING COMMENT 'Basis on which losses from this peril are settled: occurrence-based, claims-made, or reporting form. Determines trigger and coverage period for peril losses.. Valid values are `OCCURRENCE|CLAIMS_MADE|REPORTING`',
    `mandatory_peril_flag` BOOLEAN COMMENT 'Indicates whether this peril is mandatory under the coverage form and cannot be excluded by the insured (True) or is optional (False).',
    `naic_peril_code` STRING COMMENT 'NAIC statistical peril code used in Annual Statement Schedule P and other statutory filings for loss reporting by cause of loss.. Valid values are `^[0-9]{2,4}$`',
    `coverage_peril_name` STRING COMMENT 'Full business name of the peril as recognized in policy forms and coverage documentation.',
    `nfip_overlap_indicator` BOOLEAN COMMENT 'Indicates whether this peril overlaps with NFIP coverage, requiring coordination of benefits and exclusion language.',
    `pml_modeling_required_flag` BOOLEAN COMMENT 'Indicates whether this peril requires PML modeling for exposure management and capital adequacy assessment.',
    `premium_amount` DECIMAL(18,2) COMMENT 'Portion of the written premium allocated to this specific peril within the coverage, used for peril-level profitability analysis and reinsurance pricing.',
    `rate` DECIMAL(12,6) COMMENT 'Rate per unit of exposure (e.g., per $100 of TIV) applied to this peril for premium calculation purposes, sourced from the filed rate manual.',
    `regulatory_reporting_required_flag` BOOLEAN COMMENT 'Indicates whether losses from this peril require special regulatory reporting to state DOI or NAIC.',
    `reinsurance_peril_code` STRING COMMENT 'Peril code used in reinsurance treaty and facultative (FAC) cession reporting and bordereaux submissions to reinsurers.. Valid values are `^[A-Z0-9_]{2,20}$`',
    `reinsurance_treaty_applicable_flag` BOOLEAN COMMENT 'Indicates whether this peril is typically covered under reinsurance treaties or requires facultative placement.',
    `retroactive_date` DATE COMMENT 'Earliest date from which losses from this peril are covered under a claims-made form. Null for occurrence-based perils.',
    `scheduled_peril_flag` BOOLEAN COMMENT 'Indicates whether this peril is on a named/scheduled basis (True) requiring specific listing, versus an open-peril or all-risk basis (False).',
    `severity_rating` STRING COMMENT 'Typical loss severity classification for underwriting and pricing purposes based on historical claim data.. Valid values are `low|moderate|high|catastrophic`',
    `sir_amount` DECIMAL(18,2) COMMENT 'Self-Insured Retention amount the insured must absorb for losses from this peril before the insurers coverage obligation is triggered.',
    `source_system_code` STRING COMMENT 'Identifies the originating policy administration system that created this coverage-peril record (e.g., GUIDEWIRE, DUCK_CREEK, SAPIENS, MANUAL entry, or MIGRATION).. Valid values are `GUIDEWIRE|DUCK_CREEK|SAPIENS|MANUAL|MIGRATION`',
    `source_system_record_code` STRING COMMENT 'Native record identifier from the originating policy administration system, enabling traceability and reconciliation back to the system of record.',
    `sublimit_amount` DECIMAL(18,2) COMMENT 'Maximum insurer liability for losses arising from this specific peril, acting as a sublimit within the overall coverage limit. Null if no peril-specific sublimit applies.',
    `sublimit_basis` STRING COMMENT 'Basis on which the peril sublimit is applied: per occurrence, per claim, annual aggregate, or per location. Governs how peril_sublimit_amount is consumed.. Valid values are `PER_OCCURRENCE|PER_CLAIM|ANNUAL_AGGREGATE|PER_LOCATION`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this coverage-peril association record, supporting change tracking and audit compliance.',
    `valuation_method` STRING COMMENT 'Method used to value losses for this peril: Actual Cash Value (ACV), Replacement Cost Value (RCV), Agreed Value, Functional Replacement Cost, or Market Value.. Valid values are `ACV|RCV|AGREED_VALUE|FUNCTIONAL|MARKET`',
    `version_number` STRING COMMENT 'Version identifier for this peril definition, incremented when definition or classification changes.. Valid values are `^[0-9]{1,3}.[0-9]{1,3}$`',
    `waiting_period_days` BIGINT COMMENT 'Number of days after policy inception or peril trigger before coverage for this peril becomes effective (e.g., flood waiting period under NFIP-aligned policies).',
    CONSTRAINT pk_coverage_peril PRIMARY KEY(`coverage_peril_id`)
) COMMENT 'Reference catalog of insured and excluded perils (fire, wind, hail, flood, earthquake, theft, liability). Stores ISO peril code, peril category, CAT designation flag, and NFIP overlap indicator.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`peril` (
    `peril_id` BIGINT COMMENT 'Primary key for peril',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Auto-generated FK linking siloed peril to policy_coverage',
    CONSTRAINT pk_peril PRIMARY KEY(`peril_id`)
) COMMENT 'Junction table associating coverage forms with the specific perils they insure or exclude. Carries insured/excluded flag, sublimit linkage, and peril-specific deductible override for each coverage-peril combination.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` (
    `waiver_of_subrogation_id` BIGINT COMMENT 'Unique surrogate identifier for the waiver of subrogation endorsement record on the Databricks Silver Layer.',
    `document_id` BIGINT COMMENT 'Reference identifier to the endorsement document stored in the content management system (OpenText or FileNet) for audit and compliance retrieval.',
    `endorsement_id` BIGINT COMMENT 'Foreign key linking to coverage.endorsement. Business justification: Waiver of subrogation is implemented via endorsement. The waiver_of_subrogation table has endorsement_number and endorsement_form_number as strings but lacks FK to endorsement record.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Reference to the specific coverage line under the policy to which this waiver of subrogation applies.',
    `policy_id` BIGINT COMMENT 'Reference to the parent policy to which this waiver of subrogation endorsement is attached.',
    `risk_unit_id` BIGINT COMMENT 'Reference to the specific risk exposure (insured location, vehicle, or employee group) to which this waiver of subrogation is scoped.',
    `version_id` BIGINT COMMENT 'Reference to the specific policy term period during which this waiver of subrogation endorsement is in force.',
    `additional_premium` DECIMAL(18,2) COMMENT 'Additional premium charged to the insured for adding the waiver of subrogation endorsement, expressed in the policy currency.',
    `beneficiary_fein` STRING COMMENT 'Federal Employer Identification Number (FEIN) of the beneficiary organization, used for tax reporting and identity verification.. Valid values are `^[0-9]{2}-[0-9]{7}$`',
    `beneficiary_name` STRING COMMENT 'Full legal name of the third-party entity granted immunity from subrogation recovery actions under this endorsement.',
    `beneficiary_relationship` STRING COMMENT 'Contractual or business relationship between the named insured and the waiver beneficiary (e.g., contractor, lessor). [ENUM-REF-CANDIDATE: additional_insured|contractor|subcontractor|lessor|lessee|mortgagee|owner|joint_venture|other — promote to reference',
    `beneficiary_type` STRING COMMENT 'Classification of the waiver beneficiary entity type, used for regulatory reporting and underwriting analytics.. Valid values are `individual|corporation|partnership|government|trust|other`',
    `blanket_waiver_flag` BOOLEAN COMMENT 'Indicates whether this waiver of subrogation applies on a blanket basis to all parties with whom the insured has a written contract requiring such waiver.',
    `cancellation_date` DATE COMMENT 'Date on which the waiver of subrogation endorsement was cancelled mid-term, if applicable. Null for endorsements that run to expiration.',
    `cancellation_reason` STRING COMMENT 'Reason code for mid-term cancellation of the waiver endorsement. Null if the endorsement was not cancelled.. Valid values are `insured_request|underwriter_decision|policy_cancellation|non_payment|other`',
    `contractual_requirement_flag` BOOLEAN COMMENT 'Indicates whether this waiver of subrogation was required by a written contract between the insured and the beneficiary prior to policy issuance.',
    `coverage_scope` STRING COMMENT 'Defines whether the waiver applies on a blanket basis to all qualifying parties, or is scheduled to specific named beneficiaries, projects, or locations.. Valid values are `blanket|scheduled|project_specific|location_specific`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this waiver of subrogation record was first created in the Databricks Silver Layer, used for data lineage and audit trail.',
    `effective_date` DATE COMMENT 'Date on which the waiver of subrogation endorsement becomes effective and the insurer relinquishes recovery rights against the named beneficiary.',
    `endorsement_status` STRING COMMENT 'Current lifecycle status of the waiver of subrogation endorsement within the policy administration workflow.. Valid values are `active|pending|cancelled|expired|superseded`',
    `exclusion_notes` STRING COMMENT 'Free-text notes describing any exclusions or carve-outs from the waiver of subrogation, such as gross negligence or intentional acts exceptions.',
    `expiration_date` DATE COMMENT 'Date on which the waiver of subrogation endorsement expires. Null indicates the waiver runs co-terminus with the policy term.',
    `lob_code` STRING COMMENT 'NAIC or internal Line of Business (LOB) code identifying the insurance line under which this waiver is issued (e.g., GL, WC, APD, BOP).',
    `location_description` STRING COMMENT 'Free-text description of the insured location or job site address to which a location-specific waiver of subrogation is restricted.',
    `naic_line_code` STRING COMMENT 'NAIC statutory line of business code used for regulatory annual statement reporting associated with this waiver endorsement.. Valid values are `^[0-9]{2}(.1)?$`',
    `premium_basis` STRING COMMENT 'Basis on which the additional premium for the waiver endorsement is calculated (e.g., flat charge, percentage of base premium, payroll).. Valid values are `flat|percentage_of_premium|payroll|receipts|other`',
    `premium_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the additional premium charged for this waiver endorsement (e.g., USD, CAD).. Valid values are `^[A-Z]{3}$`',
    `project_name` STRING COMMENT 'Name of the specific construction project, contract, or job site to which a project-specific waiver of subrogation applies. Null for blanket waivers.',
    `project_number` STRING COMMENT 'External project or contract number associated with a project-specific waiver, enabling cross-reference to the insureds contract management system.',
    `regulatory_filing_required_flag` BOOLEAN COMMENT 'Indicates whether this waiver of subrogation endorsement form requires a separate regulatory filing with the state Department of Insurance.',
    `regulatory_filing_status` STRING COMMENT 'Current status of the regulatory form filing for this waiver endorsement with the applicable state Department of Insurance.. Valid values are `not_required|pending|filed|approved|rejected`',
    `reinsurance_eligible_flag` BOOLEAN COMMENT 'Indicates whether the coverage subject to this waiver of subrogation endorsement is eligible for cession under reinsurance treaties.',
    `source_system_code` STRING COMMENT 'Code identifying the policy administration system of record from which this waiver of subrogation record was sourced.. Valid values are `guidewire|duck_creek|sapiens_idit|other`',
    `source_system_reference_code` STRING COMMENT 'Native primary key or reference identifier of this waiver record in the originating policy administration system, used for data lineage and reconciliation.',
    `state_code` STRING COMMENT 'Two-letter US state code of the jurisdiction where the waiver of subrogation endorsement is filed and effective.. Valid values are `^[A-Z]{2}$`',
    `subrogation_rights_description` STRING COMMENT 'Free-text description of the specific subrogation rights being waived, including any limitations or conditions on the scope of the waiver.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this waiver of subrogation record in the Databricks Silver Layer, supporting change tracking and audit.',
    `uw_approval_date` DATE COMMENT 'Date on which the underwriter approved the waiver of subrogation endorsement. Null if UW approval was not required.',
    `uw_approval_required_flag` BOOLEAN COMMENT 'Indicates whether underwriting authority approval was required before binding this waiver of subrogation endorsement.',
    `uw_approved_by` STRING COMMENT 'Name or user ID of the underwriter who approved this waiver of subrogation endorsement when UW authority was required.',
    `waiver_type` STRING COMMENT 'Classification of the waiver of subrogation as blanket (all parties), specific (named party), contractual (per contract requirement), or statutory.. Valid values are `blanket|specific|contractual|statutory`',
    `wc_class_code` STRING COMMENT 'NCCI Workers Compensation (WC) class code applicable when the waiver is issued under a WC policy, driving the premium surcharge calculation.. Valid values are `^[0-9]{4}$`',
    CONSTRAINT pk_waiver_of_subrogation PRIMARY KEY(`waiver_of_subrogation_id`)
) COMMENT 'Waiver of subrogation endorsement records granting a third party immunity from recovery actions. Captures beneficiary name, relationship, endorsement form number, and effective coverage scope.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` (
    `exposure_id` BIGINT COMMENT 'Unique identifier for the coverage exposure junction record linking policy coverage to insured exposures.',
    `deductible_id` BIGINT COMMENT 'Foreign key linking to coverage.deductible. Business justification: Exposure records capture deductible_amount and deductible_type inline, but the deductible table contains structured deductible records with full details (flat, percentage, split',
    `effective_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Exposure effective dates drive premium earning and loss development analysis. New FK needed for temporal analytics and accident year assignment.',
    `endorsement_id` BIGINT COMMENT 'Foreign key linking to coverage.endorsement. Business justification: Exposure records can be added or modified via endorsements (e.g., adding a new location, vehicle, or scheduled item).',
    `insured_location_id` BIGINT COMMENT 'Reference to the insured location exposure when coverage applies to a fixed property location.',
    `insured_vehicle_id` BIGINT COMMENT 'Reference to the scheduled vehicle exposure when coverage applies to an auto or fleet vehicle.',
    `limit_id` BIGINT COMMENT 'Foreign key linking to coverage.limit. Business justification: Exposure records capture occurrence_limit, aggregate_limit, and sublimit_amount inline, but the limit table contains structured limit records with full details (limit type, basis, application',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Reference to the policy coverage record that applies to this exposure.',
    `scheduled_item_id` BIGINT COMMENT 'Reference to the scheduled item exposure when coverage applies to a specific valuable or equipment piece.',
    `sir_layer_id` BIGINT COMMENT 'Foreign key linking to coverage.sir_layer. Business justification: Exposure records capture sir_amount inline, but the sir_layer table contains structured SIR records with full details (aggregate cap, erosion basis, defense inside/outside, ALAE treatment',
    `cat_exposed_flag` BOOLEAN COMMENT 'Indicates whether this exposure is subject to catastrophe perils such as hurricane, earthquake, or flood.',
    `coinsurance_percentage` DECIMAL(5,2) COMMENT 'Coinsurance percentage requirement for this exposure, typically 80%, 90%, or 100% of replacement cost.',
    `construction_type` STRING COMMENT 'ISO construction type classification for this exposure used in property rating and underwriting.. Valid values are `frame|joisted_masonry|noncombustible|masonry_noncombustible|modified_fire_resistive|fire_resistive`',
    `coverage_scope` STRING COMMENT 'Scope of coverage application: specific to this exposure, blanket across multiple exposures, scheduled list, or floating.. Valid values are `specific|blanket|scheduled|floating`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this coverage exposure record was first created in the system.',
    `earned_premium_amount` DECIMAL(18,2) COMMENT 'Earned premium for this coverage exposure as of the current accounting period.',
    `effective_date` DATE COMMENT 'Date when coverage begins applying to this specific exposure.',
    `exclusion_codes` STRING COMMENT 'Comma-separated list of exclusion codes that apply to this coverage exposure limiting covered perils or losses.',
    `expiration_date` DATE COMMENT 'Date when coverage ceases to apply to this specific exposure.',
    `exposure_status` STRING COMMENT 'Current lifecycle status of the coverage exposure assignment.. Valid values are `active|suspended|cancelled|expired|pending`',
    `exposure_type` STRING COMMENT 'Classification of the exposure being covered: fixed location, vehicle, scheduled item, blanket, or floating.. Valid values are `location|vehicle|scheduled_item|blanket|floating`',
    `itv_ratio` DECIMAL(5,4) COMMENT 'Ratio of insured limit to actual replacement cost value for this exposure, used to assess coinsurance compliance.',
    `lob_code` STRING COMMENT 'Line of business code applicable to this coverage exposure such as GL, CGL, BOP, WC, APD, or CPP.',
    `occupancy_code` STRING COMMENT 'ISO occupancy classification code describing the use of the property or vehicle at this exposure.',
    `pml_amount` DECIMAL(18,2) COMMENT 'Probable maximum loss estimate for this exposure used in catastrophe modeling and reinsurance placement.',
    `premium_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for premium amounts on this exposure.. Valid values are `^[A-Z]{3}$`',
    `protection_class` STRING COMMENT 'ISO Public Protection Classification or similar fire protection rating for this exposure location.',
    `reference_number` STRING COMMENT 'Business-readable identifier for this coverage exposure assignment used in policy documents and bordereaux.',
    `reinsurance_eligible_flag` BOOLEAN COMMENT 'Indicates whether this coverage exposure is eligible for reinsurance cession under treaty or facultative agreements.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record that originated this coverage exposure, such as PolicyCenter or Duck Creek Policy.',
    `state_code` STRING COMMENT 'Two-letter state code where this exposure is located and subject to regulatory jurisdiction.. Valid values are `^[A-Z]{2}$`',
    `territory_code` STRING COMMENT 'Rating territory code applicable to this exposure for premium calculation and risk classification.',
    `tiv_amount` DECIMAL(18,2) COMMENT 'Total insured value for this specific exposure representing maximum property value at risk.',
    `unearned_premium_amount` DECIMAL(18,2) COMMENT 'Unearned premium remaining for this coverage exposure representing future coverage obligation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this coverage exposure record was last modified.',
    `valuation_method` STRING COMMENT 'Method used to value losses for this exposure: Actual Cash Value, Replacement Cost Value, agreed value, stated amount, or market value.. Valid values are `ACV|RCV|agreed_value|stated_amount|market_value`',
    `waiting_period_days` BIGINT COMMENT 'Number of days after loss occurrence before coverage begins paying for this exposure, common in business interruption.',
    `written_premium_amount` DECIMAL(18,2) COMMENT 'Written premium allocated to this specific coverage exposure for the policy term.',
    CONSTRAINT pk_exposure PRIMARY KEY(`exposure_id`)
) COMMENT 'Junction resolving the M:N between coverage_policy_coverage and insured exposures (insured_location, scheduled_vehicle, scheduled_item). Carries applied limit, deductible, and coverage scope per exposure.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` (
    `cession_id` BIGINT COMMENT 'Unique surrogate primary key for each coverage cession record.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to the specific policy coverage being ceded to the reinsurer.',
    `reinsurer_id` BIGINT COMMENT 'Foreign key linking to the reinsurer counterparty accepting the ceded risk.',
    `ri_treaty_id` BIGINT COMMENT 'Foreign key reference to the reinsurance treaty under which this cession is placed, if treaty reinsurance.',
    `ceded_limit_amount` DECIMAL(18,2) COMMENT 'Maximum dollar amount of coverage limit ceded to this reinsurer under this cession.',
    `ceded_premium_amount` DECIMAL(18,2) COMMENT 'Gross premium amount ceded to this reinsurer for this coverage under the cession arrangement.',
    `ceded_share_pct` DECIMAL(7,4) COMMENT 'Percentage of the coverage risk ceded to this reinsurer, expressed as decimal (0.25 = 25%).',
    `collateral_held_amount` DECIMAL(18,2) COMMENT 'Dollar amount of collateral held from this reinsurer to secure recoverables under this cession.',
    `commission_pct` DECIMAL(7,4) COMMENT 'Commission percentage paid by the reinsurer to the ceding company on ceded premium.',
    `effective_date` DATE COMMENT 'Date on which this reinsurers participation in the coverage cession becomes effective.',
    `expiration_date` DATE COMMENT 'Date on which this reinsurers participation in the coverage cession expires.',
    `facultative_certificate_number` STRING COMMENT 'Certificate number for facultative reinsurance placement, if this cession is facultative rather than treaty.',
    `participation_status` STRING COMMENT 'Current lifecycle status of this reinsurer participation in the coverage cession.',
    `recoverable_balance` DECIMAL(18,2) COMMENT 'Outstanding balance of claim recoveries due from this reinsurer for this coverage as of reporting date.',
    `settlement_status` STRING COMMENT 'Current status of financial settlement between cedant and reinsurer for this cession.',
    CONSTRAINT pk_cession PRIMARY KEY(`cession_id`)
) COMMENT 'Represents the cession of a specific policy coverage to a reinsurer. Captures the reinsurers participation share, ceded limits, recoverable balances, and settlement status for each coverage-reinsurer combination..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`coverage`.`product` (
    `product_id` BIGINT COMMENT 'Primary key for product',
    `aggregate_limit_applies` BOOLEAN COMMENT 'Indicates whether an annual aggregate limit of liability applies to this product in addition to per-occurrence limits.',
    `audit_required` BOOLEAN COMMENT 'Indicates whether policies written under this product require a premium audit at policy expiration to adjust premium based on actual exposures.',
    `cancellation_allowed` BOOLEAN COMMENT 'Indicates whether policies written under this product may be cancelled mid-term by the insurer, subject to regulatory notice requirements.',
    `catastrophe_exposure_flag` BOOLEAN COMMENT 'Indicates whether this product carries exposure to catastrophic perils such as hurricane, earthquake, or wildfire.',
    `claims_made_retroactive_date` DATE COMMENT 'Default retroactive date for claims-made products, establishing the earliest date of occurrence for which claims will be covered.',
    `commission_rate_percent` DECIMAL(5,2) COMMENT 'Standard commission percentage paid to agents or brokers for policies written under this product.',
    `coverage_basis` STRING COMMENT 'Trigger basis for coverage: occurrence-based, claims-made, or claims-made-and-reported.',
    `created_by_user` STRING COMMENT 'Username or identifier of the user who created this product record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this product record was first created in the system.',
    `default_deductible_amount` DECIMAL(15,2) COMMENT 'Standard deductible amount applied to claims under this product unless overridden at the policy or coverage level.',
    `default_limit_amount` DECIMAL(15,2) COMMENT 'Standard per-occurrence or aggregate limit of liability for this product unless overridden at the policy or coverage level.',
    `endorsement_allowed` BOOLEAN COMMENT 'Indicates whether mid-term endorsements and policy changes are permitted for policies written under this product.',
    `extended_reporting_period_months` BIGINT COMMENT 'Standard duration in months for the extended reporting period tail coverage available for claims-made products.',
    `filing_effective_date` DATE COMMENT 'Date on which the regulatory filing became effective and the product became available for new business.',
    `filing_expiration_date` DATE COMMENT 'Date on which the regulatory filing expires or is superseded, after which the product may no longer be sold.',
    `form_edition_date` DATE COMMENT 'Edition date of the base coverage form, indicating the version of policy language in use.',
    `form_number` STRING COMMENT 'Primary ISO or proprietary form number for the base coverage form, such as CG 00 01, HO 00 03, or CA 00 01.',
    `installment_billing_allowed` BOOLEAN COMMENT 'Indicates whether premium for policies under this product may be paid in installments rather than in full at inception.',
    `iso_class_code` STRING COMMENT 'ISO general liability or workers compensation classification code associated with the product for rating and exposure analysis.',
    `line_of_business` STRING COMMENT 'Primary line of business classification for the product: personal auto, commercial auto, homeowners, commercial property, general liability, or workers compensation.',
    `maximum_premium_amount` DECIMAL(15,2) COMMENT 'Maximum allowable premium for a single policy under this product, used for underwriting authority limits.',
    `minimum_premium_amount` DECIMAL(15,2) COMMENT 'Minimum earned premium required for a policy written under this product, enforced at policy issuance or audit.',
    `modified_by_user` STRING COMMENT 'Username or identifier of the user who last modified this product record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this product record was last modified in the system.',
    `ncci_class_code` STRING COMMENT 'NCCI classification code for workers compensation products, used for rating and loss cost determination.',
    `new_business_allowed` BOOLEAN COMMENT 'Indicates whether new policies may be written under this product; false if product is closed to new business but renewals continue.',
    `non_renewal_allowed` BOOLEAN COMMENT 'Indicates whether the insurer may elect not to renew policies written under this product at expiration, subject to regulatory notice requirements.',
    `policy_term_months` BIGINT COMMENT 'Standard policy term duration in months for this product, typically 6, 12, or 24 months.',
    `product_code` STRING COMMENT 'Externally-known unique alphanumeric code identifying the product in catalogs, rating systems, and policy administration systems.',
    `product_description` STRING COMMENT 'Detailed narrative describing the coverage intent, target market, and key features of the product.',
    `product_name` STRING COMMENT 'Human-readable name of the insurance product as marketed to agents, brokers, and insureds.',
    `product_status` STRING COMMENT 'Current lifecycle status of the product: active for new business, inactive, withdrawn from market, or pending regulatory approval.',
    `product_type` STRING COMMENT 'Structural classification of the product: monoline, package, umbrella, excess, or business owners policy.',
    `rating_plan_code` STRING COMMENT 'Code identifying the rating algorithm, factor tables, and premium calculation methodology used for this product.',
    `regulatory_filing_number` STRING COMMENT 'State insurance department filing or SERFF tracking number for the approved product and rates.',
    `reinsurance_treaty_applicable` BOOLEAN COMMENT 'Indicates whether policies written under this product are automatically ceded to a reinsurance treaty.',
    `renewal_allowed` BOOLEAN COMMENT 'Indicates whether existing policies may be renewed under this product; false if product is being phased out.',
    `reporting_form_flag` BOOLEAN COMMENT 'Indicates whether this product uses a reporting form structure requiring periodic exposure or value reports from the insured.',
    `self_insured_retention_amount` DECIMAL(15,2) COMMENT 'Standard self-insured retention amount that the insured must pay before coverage attaches, common in umbrella and excess products.',
    `state_availability` STRING COMMENT 'Comma-separated list of two-letter state codes where this product is approved for sale and binding.',
    `target_market_segment` STRING COMMENT 'Description of the intended customer segment or industry vertical for this product, such as small business, contractors, or high-net-worth individuals.',
    `underwriting_tier` STRING COMMENT 'Risk tier classification for the product: preferred, standard, non-standard, or specialty.',
    CONSTRAINT pk_product PRIMARY KEY(`product_id`)
) COMMENT 'Master reference table for product. Referenced by product_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ADD CONSTRAINT `fk_coverage_coverage_policy_coverage_coverage_form_id` FOREIGN KEY (`coverage_form_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_form`(`coverage_form_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ADD CONSTRAINT `fk_coverage_coverage_policy_coverage_part_id` FOREIGN KEY (`part_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`part`(`part_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ADD CONSTRAINT `fk_coverage_part_coverage_form_id` FOREIGN KEY (`coverage_form_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_form`(`coverage_form_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ADD CONSTRAINT `fk_coverage_part_product_id` FOREIGN KEY (`product_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`product`(`product_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ADD CONSTRAINT `fk_coverage_limit_parent_limit_id` FOREIGN KEY (`parent_limit_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`limit`(`limit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ADD CONSTRAINT `fk_coverage_limit_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ADD CONSTRAINT `fk_coverage_deductible_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ADD CONSTRAINT `fk_coverage_sir_layer_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ADD CONSTRAINT `fk_coverage_endorsement_coverage_form_id` FOREIGN KEY (`coverage_form_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_form`(`coverage_form_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ADD CONSTRAINT `fk_coverage_endorsement_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ADD CONSTRAINT `fk_coverage_exclusion_coverage_form_id` FOREIGN KEY (`coverage_form_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_form`(`coverage_form_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ADD CONSTRAINT `fk_coverage_exclusion_endorsement_id` FOREIGN KEY (`endorsement_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`endorsement`(`endorsement_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ADD CONSTRAINT `fk_coverage_exclusion_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ADD CONSTRAINT `fk_coverage_additional_insured_endorsement_id` FOREIGN KEY (`endorsement_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`endorsement`(`endorsement_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ADD CONSTRAINT `fk_coverage_additional_insured_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ADD CONSTRAINT `fk_coverage_amendment_endorsement_id` FOREIGN KEY (`endorsement_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`endorsement`(`endorsement_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ADD CONSTRAINT `fk_coverage_amendment_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ADD CONSTRAINT `fk_coverage_itv_assessment_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ADD CONSTRAINT `fk_coverage_coverage_peril_limit_id` FOREIGN KEY (`limit_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`limit`(`limit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ADD CONSTRAINT `fk_coverage_coverage_peril_peril_coverage_peril_id` FOREIGN KEY (`peril_coverage_peril_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_peril`(`coverage_peril_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ADD CONSTRAINT `fk_coverage_coverage_peril_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`peril` ADD CONSTRAINT `fk_coverage_peril_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ADD CONSTRAINT `fk_coverage_waiver_of_subrogation_endorsement_id` FOREIGN KEY (`endorsement_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`endorsement`(`endorsement_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ADD CONSTRAINT `fk_coverage_waiver_of_subrogation_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ADD CONSTRAINT `fk_coverage_exposure_deductible_id` FOREIGN KEY (`deductible_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`deductible`(`deductible_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ADD CONSTRAINT `fk_coverage_exposure_endorsement_id` FOREIGN KEY (`endorsement_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`endorsement`(`endorsement_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ADD CONSTRAINT `fk_coverage_exposure_limit_id` FOREIGN KEY (`limit_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`limit`(`limit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ADD CONSTRAINT `fk_coverage_exposure_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ADD CONSTRAINT `fk_coverage_exposure_sir_layer_id` FOREIGN KEY (`sir_layer_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`sir_layer`(`sir_layer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ADD CONSTRAINT `fk_coverage_cession_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_v499`.`coverage` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_v499`.`coverage` SET TAGS ('dbx_domain' = 'coverage');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` SET TAGS ('dbx_subdomain' = 'policy_binding');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `part_id` SET TAGS ('dbx_business_glossary_term' = 'Part Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Exposure ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `aggregate_limit` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `aggregate_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Cancellation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `cat_exposed_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_business_glossary_term' = 'Coverage Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_value_regex' = 'occurrence|claims_made|claims_made_reported|discovery');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Coverage Sequence Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_sequence_number` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_sequence_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_status` SET TAGS ('dbx_business_glossary_term' = 'Coverage Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_status` SET TAGS ('dbx_value_regex' = 'active|suspended|cancelled|expired|pending|lapsed');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_status` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_status` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_type_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_type_code` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `coverage_type_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `deductible_type` SET TAGS ('dbx_business_glossary_term' = 'Deductible Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `deductible_type` SET TAGS ('dbx_value_regex' = 'flat|percentage|disappearing|split|none');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `earned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `earned_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `endorsement_flag` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `exclusion_codes` SET TAGS ('dbx_business_glossary_term' = 'Coverage Exclusion Codes');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_business_glossary_term' = 'Extended Reporting Period (ERP) Days');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `itv_ratio` SET TAGS ('dbx_business_glossary_term' = 'Insurance to Value (ITV) Ratio');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `mandatory_coverage_flag` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Coverage Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `mandatory_coverage_flag` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `mandatory_coverage_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `occurrence_limit` SET TAGS ('dbx_business_glossary_term' = 'Per Occurrence Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `occurrence_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `pml_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `policy_transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `policy_transaction_type` SET TAGS ('dbx_value_regex' = 'NB|REN|ENDT|CANC|reinstatement|rewrite');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `premium_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Premium Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `premium_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `rate_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Rate Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `rate_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Rate Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `reinsurance_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Eligible Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `reinsurance_eligible_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `reinsurance_eligible_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `retroactive_date` SET TAGS ('dbx_business_glossary_term' = 'Retroactive Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `sir_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `sir_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'guidewire|duck_creek|sapiens_idit|legacy');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `source_system_coverage_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Coverage Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `source_system_coverage_ref` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `source_system_coverage_ref` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `sublimit_amount` SET TAGS ('dbx_business_glossary_term' = 'Coverage Sublimit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `sublimit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `sublimit_description` SET TAGS ('dbx_business_glossary_term' = 'Coverage Sublimit Description');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `tiv_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `tiv_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `unearned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Unearned Premium (UEP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `unearned_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'ACV|RCV|agreed_value|functional_replacement|stated_amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_business_glossary_term' = 'Waiting Period Days');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `written_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Written Premium (WP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ALTER COLUMN `written_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` SET TAGS ('dbx_subdomain' = 'product_catalog');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `aggregate_limit_applicable` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit Applicable Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `cat_exposed` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposed Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `coinsurance_percent` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `coverage_category` SET TAGS ('dbx_business_glossary_term' = 'Coverage Category');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `coverage_category` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `coverage_category` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `default_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Default Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `default_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Default Coverage Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `document_template_code` SET TAGS ('dbx_business_glossary_term' = 'Document Template Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `edition_date` SET TAGS ('dbx_business_glossary_term' = 'Form Edition Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Form Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Form Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_business_glossary_term' = 'Extended Reporting Period (ERP) Days');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `filing_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `filing_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Filing Jurisdiction State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `filing_jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `filing_status` SET TAGS ('dbx_value_regex' = 'approved|filed|objected|withdrawn|not_required');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `form_description` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Description');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `form_name` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `form_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `form_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `form_number` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `form_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-.]{2,30}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `form_status` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `form_status` SET TAGS ('dbx_value_regex' = 'active|inactive|superseded|withdrawn|pending_approval');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `form_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `form_type` SET TAGS ('dbx_value_regex' = 'coverage|endorsement|exclusion|schedule|declaration|condition');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `is_base_form` SET TAGS ('dbx_business_glossary_term' = 'Base Form Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `is_iso_standard` SET TAGS ('dbx_business_glossary_term' = 'ISO Standard Form Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Form Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `iso_program_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Program Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `lob_description` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Description');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `minimum_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `naic_line_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Line Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `naic_line_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2,3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `occurrence_claims_basis` SET TAGS ('dbx_business_glossary_term' = 'Occurrence or Claims-Made Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `occurrence_claims_basis` SET TAGS ('dbx_value_regex' = 'occurrence|claims_made|reporting|not_applicable');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `origin` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Origin');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `origin` SET TAGS ('dbx_value_regex' = 'ISO|AAIS|proprietary|manuscript|NCCI|NFIP');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `policy_type_applicability` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Applicability');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `policy_type_applicability` SET TAGS ('dbx_value_regex' = 'personal|commercial|both');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `premium_basis` SET TAGS ('dbx_business_glossary_term' = 'Premium Rating Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `reinsurance_eligible` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Eligible Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `reinsurance_eligible` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `reinsurance_eligible` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `retroactive_date_required` SET TAGS ('dbx_business_glossary_term' = 'Retroactive Date Required Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `sir_eligible` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Eligible Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'GUIDEWIRE|DUCK_CREEK|SAPIENS_IDIT|ISO_ISONET|MANUAL');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `source_system_form_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Form Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `state_specific_version` SET TAGS ('dbx_business_glossary_term' = 'State-Specific Version Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `tiv_applicable` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Applicable Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `valuation_basis` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_form` ALTER COLUMN `valuation_basis` SET TAGS ('dbx_value_regex' = 'ACV|RCV|agreed_value|functional_replacement|not_applicable');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` SET TAGS ('dbx_subdomain' = 'product_catalog');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `part_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `product_id` SET TAGS ('dbx_business_glossary_term' = 'Product ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `aggregate_limit` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `cat_exposed_ind` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposed Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `claims_made_ind` SET TAGS ('dbx_business_glossary_term' = 'Claims-Made Coverage Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `coinsurance_pct` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `deductible_type` SET TAGS ('dbx_business_glossary_term' = 'Deductible Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `deductible_type` SET TAGS ('dbx_value_regex' = 'straight|franchise|aggregate|disappearing|per_occurrence');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `earned_premium` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `earned_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `experience_mod_factor` SET TAGS ('dbx_business_glossary_term' = 'Experience Modification Factor (EMF)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Exposure Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_business_glossary_term' = 'Extended Reporting Period (ERP) Days');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `filing_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Filing Jurisdiction State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `filing_jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Inception Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `insuring_agreement_desc` SET TAGS ('dbx_business_glossary_term' = 'Insuring Agreement Description');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `itv_ratio` SET TAGS ('dbx_business_glossary_term' = 'Insurance to Value (ITV) Ratio');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `lob_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `med_expense_limit` SET TAGS ('dbx_business_glossary_term' = 'Medical Expense (MedPay) Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `naic_line_code` SET TAGS ('dbx_business_glossary_term' = 'NAIC Line of Business Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `naic_line_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2,3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `part_name` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `part_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `part_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `occurrence_limit` SET TAGS ('dbx_business_glossary_term' = 'Per Occurrence Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `part_number` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `part_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{3,30}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `part_status` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `part_status` SET TAGS ('dbx_value_regex' = 'active|pending|suspended|cancelled|expired');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `part_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `personal_adv_injury_limit` SET TAGS ('dbx_business_glossary_term' = 'Personal and Advertising Injury Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `policy_term_months` SET TAGS ('dbx_business_glossary_term' = 'Policy Term (Months)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `premium_currency` SET TAGS ('dbx_business_glossary_term' = 'Premium Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `premium_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `products_completed_ops_limit` SET TAGS ('dbx_business_glossary_term' = 'Products and Completed Operations Aggregate Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `rate_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Rate Per Unit');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `rate_per_unit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `rating_basis` SET TAGS ('dbx_business_glossary_term' = 'Rating Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `rating_basis` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `rating_basis` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `retroactive_date` SET TAGS ('dbx_business_glossary_term' = 'Retroactive Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `schedule_mod_factor` SET TAGS ('dbx_business_glossary_term' = 'Schedule Modification Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `schedule_mod_factor` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `sir_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `source_system_part_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Coverage Part Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `state_filed_ind` SET TAGS ('dbx_business_glossary_term' = 'State Filed Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `terrorism_coverage_ind` SET TAGS ('dbx_business_glossary_term' = 'Terrorism Coverage Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `terrorism_coverage_ind` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `terrorism_coverage_ind` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `tiv_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `unearned_premium` SET TAGS ('dbx_business_glossary_term' = 'Unearned Premium (UEP)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `unearned_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'ACV|RCV|agreed_value|functional_replacement|stated_amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `written_premium` SET TAGS ('dbx_business_glossary_term' = 'Written Premium (WP)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ALTER COLUMN `written_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` SET TAGS ('dbx_subdomain' = 'product_catalog');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `limit_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Limit ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `parent_limit_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Limit ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `aggregate_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `aggregate_limit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `amount_2` SET TAGS ('dbx_business_glossary_term' = 'Secondary Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `amount_2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `amount_3` SET TAGS ('dbx_business_glossary_term' = 'Tertiary Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `amount_3` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `application` SET TAGS ('dbx_business_glossary_term' = 'Limit Application Scope');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `application` SET TAGS ('dbx_value_regex' = 'per_insured|per_location|per_vehicle|per_project|per_employee|blanket');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `basis` SET TAGS ('dbx_business_glossary_term' = 'Limit Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `basis` SET TAGS ('dbx_value_regex' = 'occurrence|claims_made|accident|policy_period|location|vehicle');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `cat_exposed_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `limit_code` SET TAGS ('dbx_business_glossary_term' = 'Limit Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `limit_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,30}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `coinsurance_pct` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `coverage_form_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `coverage_form_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[s][0-9]{2}[s][0-9]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `coverage_form_code` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `coverage_form_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Limit Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Limit Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `iso_limit_symbol` SET TAGS ('dbx_business_glossary_term' = 'ISO Limit Symbol');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `iso_limit_symbol` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `itv_ratio` SET TAGS ('dbx_business_glossary_term' = 'Insurance to Value (ITV) Ratio');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `jurisdiction_state_code` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `jurisdiction_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `jurisdiction_state_code` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `jurisdiction_state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `limit_status` SET TAGS ('dbx_business_glossary_term' = 'Limit Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `limit_status` SET TAGS ('dbx_value_regex' = 'active|inactive|superseded|pending|expired');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `limit_type` SET TAGS ('dbx_business_glossary_term' = 'Limit Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `lob_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `med_expense_limit` SET TAGS ('dbx_business_glossary_term' = 'Medical Expense (MedPay) Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `med_expense_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `naic_coverage_code` SET TAGS ('dbx_business_glossary_term' = 'NAIC Coverage Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `naic_coverage_code` SET TAGS ('dbx_value_regex' = '^[0-9]{3,6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `naic_coverage_code` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `naic_coverage_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `limit_name` SET TAGS ('dbx_business_glossary_term' = 'Limit Name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `limit_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `limit_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `peril_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `personal_adv_injury_limit` SET TAGS ('dbx_business_glossary_term' = 'Personal and Advertising Injury Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `personal_adv_injury_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `pml_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `policy_transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `policy_transaction_type` SET TAGS ('dbx_value_regex' = 'new_business|renewal|endorsement|reinstatement|cancellation');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `products_completed_ops_aggregate` SET TAGS ('dbx_business_glossary_term' = 'Products-Completed Operations Aggregate Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `products_completed_ops_aggregate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `reinstatable_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinstatable Limit Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `reinstatable_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `reinstatable_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `reinstatement_premium_pct` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `reinstatement_premium_pct` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `reinstatement_premium_pct` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `ri_retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Retention Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `ri_retention_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `shared_limit_flag` SET TAGS ('dbx_business_glossary_term' = 'Shared Limit Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `sir_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `sir_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'guidewire_pc|duck_creek_policy|sapiens_idit|iso_isonet|manual');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `source_system_limit_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Limit ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `state_minimum_flag` SET TAGS ('dbx_business_glossary_term' = 'State Minimum Limit Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `tiv_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `tiv_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'acv|rcv|agreed_value|functional_replacement|market_value');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Limit Version Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `xol_attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Excess of Loss (XOL) Attachment Point Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`limit` ALTER COLUMN `xol_attachment_point` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` SET TAGS ('dbx_subdomain' = 'product_catalog');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `deductible_id` SET TAGS ('dbx_business_glossary_term' = 'Deductible ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `effective_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Effective Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `aggregate_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `aggregate_deductible_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `application_method` SET TAGS ('dbx_business_glossary_term' = 'Deductible Application Method');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `application_method` SET TAGS ('dbx_value_regex' = 'per_occurrence|per_claim|per_accident|aggregate|per_location');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `buyback_available_flag` SET TAGS ('dbx_business_glossary_term' = 'Deductible Buyback Available Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `buyback_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Buyback Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `buyback_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `cat_deductible_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Deductible Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `cat_peril_type` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Peril Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `cat_peril_type` SET TAGS ('dbx_value_regex' = 'named_storm|earthquake|flood|hail|wildfire|all_cat');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `deductible_code` SET TAGS ('dbx_business_glossary_term' = 'Deductible Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `deductible_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{2,30}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `coverage_form_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `coverage_form_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9 ]{2,30}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `coverage_form_code` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `coverage_form_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `deductible_status` SET TAGS ('dbx_business_glossary_term' = 'Deductible Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `deductible_status` SET TAGS ('dbx_value_regex' = 'active|inactive|superseded|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `deductible_type` SET TAGS ('dbx_business_glossary_term' = 'Deductible Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `deductible_type` SET TAGS ('dbx_value_regex' = 'flat|percentage|split|disappearing|sir');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `defense_inside_sir_flag` SET TAGS ('dbx_business_glossary_term' = 'Defense Inside Self-Insured Retention (SIR) Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `disappearing_max_amount` SET TAGS ('dbx_business_glossary_term' = 'Disappearing Deductible Maximum Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `disappearing_max_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `disappearing_min_amount` SET TAGS ('dbx_business_glossary_term' = 'Disappearing Deductible Minimum Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `disappearing_min_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Deductible Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `erosion_basis` SET TAGS ('dbx_business_glossary_term' = 'Deductible Erosion Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `erosion_basis` SET TAGS ('dbx_value_regex' = 'loss_only|loss_and_alae|loss_and_lae');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Deductible Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `flat_amount` SET TAGS ('dbx_business_glossary_term' = 'Flat Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `flat_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `lob_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `maximum_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `maximum_deductible_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `minimum_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `minimum_deductible_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Deductible Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `percentage_basis` SET TAGS ('dbx_business_glossary_term' = 'Percentage Deductible Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `percentage_basis` SET TAGS ('dbx_value_regex' = 'tiv|loss|si|aav');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `percentage_basis` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `percentage_basis` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `percentage_rate` SET TAGS ('dbx_business_glossary_term' = 'Deductible Percentage Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `percentage_rate` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `percentage_rate` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `rate_credit_factor` SET TAGS ('dbx_business_glossary_term' = 'Deductible Rate Credit Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `reinstatement_basis` SET TAGS ('dbx_business_glossary_term' = 'Deductible Reinstatement Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `reinstatement_basis` SET TAGS ('dbx_value_regex' = 'automatic|paid|none');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `reinstatement_basis` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `reinstatement_basis` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `sir_aggregate_cap` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Aggregate Cap');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `sir_aggregate_cap` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `sir_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `sir_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'guidewire_pc|duck_creek|sapiens_idit|manual');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `source_system_ref_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `split_aggregate_amount` SET TAGS ('dbx_business_glossary_term' = 'Split Aggregate Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `split_aggregate_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `split_per_occurrence_amount` SET TAGS ('dbx_business_glossary_term' = 'Split Per-Occurrence Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `split_per_occurrence_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Deductible Version Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_business_glossary_term' = 'Deductible Waiting Period Days');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ALTER COLUMN `waiver_of_deductible_flag` SET TAGS ('dbx_business_glossary_term' = 'Waiver of Deductible Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` SET TAGS ('dbx_subdomain' = 'product_catalog');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `sir_layer_id` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Layer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `effective_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Effective Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `aggregate_limit` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Policy Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `aggregate_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `aggregate_sir_cap` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Self-Insured Retention (SIR) Cap');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `aggregate_sir_cap` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `alae_treatment` SET TAGS ('dbx_business_glossary_term' = 'Allocated Loss Adjustment Expense (ALAE) Treatment');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `alae_treatment` SET TAGS ('dbx_value_regex' = 'included|excluded|pro_rata');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `alae_treatment` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `alae_treatment` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `claims_made_flag` SET TAGS ('dbx_business_glossary_term' = 'Claims-Made Policy Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `collateral_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Collateral Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `collateral_required` SET TAGS ('dbx_business_glossary_term' = 'Collateral Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'letter_of_credit|surety_bond|cash_deposit|trust_fund|none');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `defense_inside_sir` SET TAGS ('dbx_business_glossary_term' = 'Defense Inside Self-Insured Retention (SIR) Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'SIR Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `erosion_basis` SET TAGS ('dbx_business_glossary_term' = 'SIR Erosion Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `erosion_basis` SET TAGS ('dbx_value_regex' = 'paid|incurred');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'SIR Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_business_glossary_term' = 'Extended Reporting Period (ERP) Days');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `form_edition_date` SET TAGS ('dbx_business_glossary_term' = 'SIR Form Edition Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `form_number` SET TAGS ('dbx_business_glossary_term' = 'ISO/Verisk SIR Form Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `insured_defense_obligation` SET TAGS ('dbx_business_glossary_term' = 'Insured Defense Obligation');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `insured_defense_obligation` SET TAGS ('dbx_value_regex' = 'insured_controls|insurer_controls|shared');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `insured_financial_rating` SET TAGS ('dbx_business_glossary_term' = 'Insured Financial Rating');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `insured_financial_rating` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `insured_financial_rating` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `insured_financial_rating` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `layer_status` SET TAGS ('dbx_business_glossary_term' = 'SIR Layer Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `layer_status` SET TAGS ('dbx_value_regex' = 'active|suspended|expired|cancelled|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `minimum_sir_premium` SET TAGS ('dbx_business_glossary_term' = 'Minimum SIR Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `minimum_sir_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `naic_line_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Line Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `naic_line_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2,4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'SIR Layer Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `occurrence_limit` SET TAGS ('dbx_business_glossary_term' = 'Per-Occurrence Policy Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `occurrence_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `reinsurance_applies_above_sir` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Applies Above SIR Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `reinsurance_applies_above_sir` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `reinsurance_applies_above_sir` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `retroactive_date` SET TAGS ('dbx_business_glossary_term' = 'Retroactive Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `ri_attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Attachment Point');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `ri_attachment_point` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `sir_aggregate_eroded_amount` SET TAGS ('dbx_business_glossary_term' = 'SIR Aggregate Eroded Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `sir_aggregate_eroded_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `sir_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `sir_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `sir_per_occurrence_eroded_amount` SET TAGS ('dbx_business_glossary_term' = 'SIR Per-Occurrence Eroded Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `sir_per_occurrence_eroded_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `sir_premium_credit` SET TAGS ('dbx_business_glossary_term' = 'SIR Premium Credit');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `sir_premium_credit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `sir_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `sir_reference_number` SET TAGS ('dbx_value_regex' = '^SIR-[A-Z0-9]{6,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `sir_type` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `sir_type` SET TAGS ('dbx_value_regex' = 'per_occurrence|per_claim|aggregate|combined');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'GUIDEWIRE_PC|DUCK_CREEK|SAPIENS_IDIT|MANUAL');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `uw_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `uw_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Approval Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ALTER COLUMN `uw_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Approved By');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` SET TAGS ('dbx_subdomain' = 'policy_binding');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `endorsement_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Endorsement (ENDT) ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `effective_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Effective Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `aggregate_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `aggregate_limit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `beneficiary_name` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Beneficiary Name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `beneficiary_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `beneficiary_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `beneficiary_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `beneficiary_type` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Beneficiary Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `beneficiary_type` SET TAGS ('dbx_value_regex' = 'additional_insured|loss_payee|mortgagee|named_insured|certificate_holder');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `coverage_territory` SET TAGS ('dbx_business_glossary_term' = 'Coverage Territory');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `coverage_territory` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `coverage_territory` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `coverage_territory` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `endorsement_description` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Description');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_value_regex' = '^ENDT-[A-Z0-9]{3,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `endorsement_status` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Lifecycle Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `endorsement_status` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|active|superseded|cancelled|expired');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `endorsement_type` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `endorsement_type` SET TAGS ('dbx_value_regex' = 'additional_insured|waiver_of_subrogation|coverage_add|coverage_delete|coverage_modify|limit_change');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `exclusion_description` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Description');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `issued_date` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Issued Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `itv_ratio` SET TAGS ('dbx_business_glossary_term' = 'Insurance to Value (ITV) Ratio');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `new_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'New Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `new_deductible_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `new_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'New Coverage Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `new_limit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `occurrence_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Per Occurrence Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `occurrence_limit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `policy_transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `policy_transaction_type` SET TAGS ('dbx_value_regex' = 'NB|REN|ENDT|CANC|REINSTATE|REWRITE');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `premium_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Premium Impact Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `premium_impact_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `premium_impact_type` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Premium Impact Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `premium_impact_type` SET TAGS ('dbx_value_regex' = 'additional|return|flat|waived');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `prior_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `prior_deductible_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `prior_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Coverage Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `prior_limit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `regulatory_filing_number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `regulatory_filing_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `requested_by_party_type` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Requested By Party Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `requested_by_party_type` SET TAGS ('dbx_value_regex' = 'insured|agent|broker|underwriter|system');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `retroactive_date` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Retroactive Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `sir_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `sir_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'GUIDEWIRE_PC|DUCK_CREEK|SAPIENS_IDIT|LEGACY');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `source_system_endt_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Endorsement Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `subrogation_waiver_flag` SET TAGS ('dbx_business_glossary_term' = 'Subrogation (SubroFT) Waiver Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `tiv_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Impact Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `tiv_impact_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `transaction_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Transaction Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `uw_approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Approval Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `uw_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Approved By');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `uw_approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Approval Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Version Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` SET TAGS ('dbx_subdomain' = 'product_catalog');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `exclusion_id` SET TAGS ('dbx_business_glossary_term' = 'Exclusion ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `effective_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Effective Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `endorsement_id` SET TAGS ('dbx_business_glossary_term' = 'Endorsement ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `bureau_filed_flag` SET TAGS ('dbx_business_glossary_term' = 'Bureau Filed Clause Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `cat_peril_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Peril Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `claims_handling_note` SET TAGS ('dbx_business_glossary_term' = 'Claims Handling Note');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `clause_name` SET TAGS ('dbx_business_glossary_term' = 'Clause Name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `clause_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `clause_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `clause_status` SET TAGS ('dbx_business_glossary_term' = 'Clause Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `clause_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|superseded|voided');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `clause_summary` SET TAGS ('dbx_business_glossary_term' = 'Clause Summary');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `clause_text` SET TAGS ('dbx_business_glossary_term' = 'Clause Text');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `clause_type` SET TAGS ('dbx_business_glossary_term' = 'Clause Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `clause_type` SET TAGS ('dbx_value_regex' = 'exclusion|sublimit|condition|warranty|limitation');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `cyber_flag` SET TAGS ('dbx_business_glossary_term' = 'Cyber Exclusion Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `itv_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Insurance to Value (ITV) Impact Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `manuscript_flag` SET TAGS ('dbx_business_glossary_term' = 'Manuscript Clause Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `naic_line_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Line Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `naic_line_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2,4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^EXC-[A-Z0-9]{4,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `peril_class` SET TAGS ('dbx_business_glossary_term' = 'Peril Class');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `pollution_flag` SET TAGS ('dbx_business_glossary_term' = 'Pollution Exclusion Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `property_class` SET TAGS ('dbx_business_glossary_term' = 'Property Class');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `regulatory_approval_number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `reinsurance_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Impact Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `reinsurance_impact_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `reinsurance_impact_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Scope');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `scope` SET TAGS ('dbx_value_regex' = 'blanket|scheduled|location_specific|vehicle_specific|named_peril|all_risk');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `sir_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `source_system_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `sublimit_amount` SET TAGS ('dbx_business_glossary_term' = 'Sublimit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `sublimit_basis` SET TAGS ('dbx_business_glossary_term' = 'Sublimit Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `sublimit_basis` SET TAGS ('dbx_value_regex' = 'per_occurrence|per_claim|aggregate|per_location|per_item');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `terrorism_flag` SET TAGS ('dbx_business_glossary_term' = 'Terrorism Exclusion Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `tiv_reduction_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Reduction Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `uw_authority_level` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Authority Level');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `uw_authority_level` SET TAGS ('dbx_value_regex' = 'standard|referral|senior_uw|chief_uw|reinsurer');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `waiver_endorsement_ref` SET TAGS ('dbx_business_glossary_term' = 'Waiver Endorsement Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ALTER COLUMN `waiver_flag` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Waiver Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` SET TAGS ('dbx_subdomain' = 'policy_binding');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `additional_insured_id` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured (AI) ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `effective_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Effective Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `endorsement_id` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `added_by_user` SET TAGS ('dbx_business_glossary_term' = 'Added By User');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `added_date` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured Added Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `additional_premium` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured Endorsement Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `aggregate_limit` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured Aggregate Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_city` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured City');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_country_code` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured Country Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_name` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured (AI) Legal Name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_number` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured (AI) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_number` SET TAGS ('dbx_value_regex' = '^AI-[0-9]{8,12}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_postal_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}(-[0-9]{4})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_state_code` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_state_code` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_status` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured (AI) Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|cancelled|expired');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_type` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured (AI) Entity Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `ai_type` SET TAGS ('dbx_value_regex' = 'organization|individual|government|trust|joint_venture');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `auto_cert_issuance_flag` SET TAGS ('dbx_business_glossary_term' = 'Automatic Certificate Issuance Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured Cancellation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured Cancellation Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_value_regex' = 'contract_expired|insured_request|underwriter_decision|non_payment|other');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `certificate_holder_flag` SET TAGS ('dbx_business_glossary_term' = 'Certificate Holder Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `contract_reference` SET TAGS ('dbx_business_glossary_term' = 'Underlying Contract Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `coverage_scope` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured Coverage Scope');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `coverage_scope` SET TAGS ('dbx_value_regex' = 'ongoing_operations|completed_operations|both|products_liability|premises');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `coverage_scope` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `coverage_scope` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `dba_name` SET TAGS ('dbx_business_glossary_term' = 'Doing Business As (DBA) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `dba_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `endorsement_form_edition` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Form Edition Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `endorsement_form_edition` SET TAGS ('dbx_value_regex' = '^[0-9]{2}/[0-9]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `endorsement_form_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Form Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `exclusions_description` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured Exclusions Description');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `notice_of_cancellation_days` SET TAGS ('dbx_business_glossary_term' = 'Notice of Cancellation Days');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `occurrence_limit` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured Per Occurrence Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `primary_noncontributory_flag` SET TAGS ('dbx_business_glossary_term' = 'Primary and Non-Contributory Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `project_description` SET TAGS ('dbx_business_glossary_term' = 'Project or Operations Description');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `relationship_type` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured Relationship Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `relationship_type` SET TAGS ('dbx_value_regex' = 'lessor|lender|owner|contractor|mortgagee|other');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'GUIDEWIRE|DUCK_CREEK|SAPIENS|MANUAL');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `source_system_ref_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ALTER COLUMN `waiver_of_subrogation_flag` SET TAGS ('dbx_business_glossary_term' = 'Waiver of Subrogation Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` SET TAGS ('dbx_subdomain' = 'policy_binding');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `named_insured_id` SET TAGS ('dbx_business_glossary_term' = 'Named Insured ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `effective_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Effective Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `annual_payroll` SET TAGS ('dbx_business_glossary_term' = 'Annual Payroll');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `annual_payroll` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `annual_revenue` SET TAGS ('dbx_business_glossary_term' = 'Annual Revenue');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `annual_revenue` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `consent_to_electronic_delivery` SET TAGS ('dbx_business_glossary_term' = 'Consent to Electronic Delivery Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `credit_score_tier` SET TAGS ('dbx_business_glossary_term' = 'Credit Score Tier');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `credit_score_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|non_standard|unscored');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `credit_score_tier` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_business_glossary_term' = 'Date of Birth');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `date_of_incorporation` SET TAGS ('dbx_business_glossary_term' = 'Date of Incorporation');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `dba_name` SET TAGS ('dbx_business_glossary_term' = 'Doing Business As (DBA) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `dba_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Named Insured Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `email` SET TAGS ('dbx_business_glossary_term' = 'Named Insured Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Named Insured Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `fein` SET TAGS ('dbx_business_glossary_term' = 'Federal Employer Identification Number (FEIN)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `fein` SET TAGS ('dbx_value_regex' = '^[0-9]{2}-[0-9]{7}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `fein` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `fein` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `gender` SET TAGS ('dbx_business_glossary_term' = 'Gender');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `gender` SET TAGS ('dbx_value_regex' = 'male|female|non_binary|not_disclosed');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `gender` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `gender` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `insured_role` SET TAGS ('dbx_business_glossary_term' = 'Named Insured Role');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `insured_role` SET TAGS ('dbx_value_regex' = 'first_named|additional_named|mortgagee|loss_payee|additional_interest');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `insured_type` SET TAGS ('dbx_business_glossary_term' = 'Named Insured Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `is_first_named` SET TAGS ('dbx_business_glossary_term' = 'Is First Named Insured Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `is_first_named` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `is_first_named` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `is_primary_contact` SET TAGS ('dbx_business_glossary_term' = 'Is Primary Contact Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `legal_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `legal_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `marital_status` SET TAGS ('dbx_business_glossary_term' = 'Marital Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `marital_status` SET TAGS ('dbx_value_regex' = 'single|married|divorced|widowed|domestic_partner');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `marital_status` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `marital_status` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System (NAICS) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `naics_code` SET TAGS ('dbx_value_regex' = '^[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `named_insured_status` SET TAGS ('dbx_business_glossary_term' = 'Named Insured Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `named_insured_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|removed|suspended');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `num_employees` SET TAGS ('dbx_business_glossary_term' = 'Number of Employees');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `phone` SET TAGS ('dbx_business_glossary_term' = 'Named Insured Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `phone` SET TAGS ('dbx_value_regex' = '^+?[0-9-s().]{7,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `primary_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Primary Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `primary_address_line1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `primary_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `primary_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Primary Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `primary_address_line2` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `primary_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `primary_city` SET TAGS ('dbx_business_glossary_term' = 'Primary City');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `primary_city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `primary_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `primary_country` SET TAGS ('dbx_business_glossary_term' = 'Primary Country Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `primary_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `primary_state` SET TAGS ('dbx_business_glossary_term' = 'Primary State');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `primary_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `primary_zip` SET TAGS ('dbx_business_glossary_term' = 'Primary ZIP Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `primary_zip` SET TAGS ('dbx_value_regex' = '^[0-9]{5}(-[0-9]{4})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `primary_zip` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `primary_zip` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `removal_reason` SET TAGS ('dbx_business_glossary_term' = 'Named Insured Removal Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Named Insured Sequence Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification (SIC) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `sic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `source_system_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `ssn_masked` SET TAGS ('dbx_business_glossary_term' = 'Social Security Number (SSN) Masked');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `ssn_masked` SET TAGS ('dbx_value_regex' = '^XXX-XX-[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `ssn_masked` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `ssn_masked` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `state_of_incorporation` SET TAGS ('dbx_business_glossary_term' = 'State of Incorporation');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `state_of_incorporation` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ALTER COLUMN `years_in_business` SET TAGS ('dbx_business_glossary_term' = 'Years in Business');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` SET TAGS ('dbx_subdomain' = 'policy_binding');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Amendment ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `effective_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Effective Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `endorsement_id` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Source System Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `uw_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter (UW) ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Coverage Amendment Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `amendment_number` SET TAGS ('dbx_value_regex' = '^AMD-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_business_glossary_term' = 'Coverage Amendment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|approved|applied|rejected|voided');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Amendment Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `applied_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Amendment Applied Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Amendment Approved Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `change_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Change Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `change_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Change Reason Description');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `coverage_form_number` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `coverage_form_number` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `coverage_form_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `itv_ratio` SET TAGS ('dbx_business_glossary_term' = 'Insurance to Value (ITV) Ratio');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `new_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'New Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `new_deductible_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `new_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'New Coverage Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `new_limit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `new_sir_amount` SET TAGS ('dbx_business_glossary_term' = 'New Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `new_sir_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `new_tiv_amount` SET TAGS ('dbx_business_glossary_term' = 'New Total Insured Value (TIV) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `new_tiv_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Amendment Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `premium_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Impact Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `premium_impact_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `premium_impact_type` SET TAGS ('dbx_business_glossary_term' = 'Premium Impact Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `premium_impact_type` SET TAGS ('dbx_value_regex' = 'additional|return|flat');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `prior_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `prior_deductible_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `prior_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Coverage Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `prior_limit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `prior_sir_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `prior_sir_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `prior_tiv_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Total Insured Value (TIV) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `prior_tiv_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `regulatory_filing_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `regulatory_filing_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `reinsurance_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Impact Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `reinsurance_impact_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `reinsurance_impact_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `requested_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Requested Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `requires_endorsement` SET TAGS ('dbx_business_glossary_term' = 'Requires Endorsement Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'GUIDEWIRE_PC|DUCK_CREEK|SAPIENS_IDIT|MANUAL');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `uw_authority_level` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Authority Level');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ALTER COLUMN `uw_authority_level` SET TAGS ('dbx_value_regex' = 'auto_approved|underwriter|senior_underwriter|manager|referral_required');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` SET TAGS ('dbx_subdomain' = 'risk_valuation');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `itv_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Insurance-to-Value (ITV) Assessment ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `effective_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Effective Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `acv_estimate` SET TAGS ('dbx_business_glossary_term' = 'Actual Cash Value (ACV) Estimate');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `acv_estimate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `agreed_value_flag` SET TAGS ('dbx_business_glossary_term' = 'Agreed Value Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `assessed_rcv` SET TAGS ('dbx_business_glossary_term' = 'Assessed Replacement Cost Value (RCV)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `assessed_rcv` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Assessment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `assessment_method` SET TAGS ('dbx_business_glossary_term' = 'ITV Assessment Method');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `assessment_method` SET TAGS ('dbx_value_regex' = 'marshall_swift|corelogic|xactware|internal_model|broker_estimate|appraisal');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `assessment_number` SET TAGS ('dbx_business_glossary_term' = 'ITV Assessment Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `assessment_number` SET TAGS ('dbx_value_regex' = '^ITV-[0-9]{4}-[0-9]{8}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'ITV Assessment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'pending|in_review|completed|waived|expired');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `assessment_type` SET TAGS ('dbx_business_glossary_term' = 'ITV Assessment Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `assessment_type` SET TAGS ('dbx_value_regex' = 'new_business|renewal|mid_term|post_loss|regulatory');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `assessor_credential` SET TAGS ('dbx_business_glossary_term' = 'Assessor Credential');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `assessor_name` SET TAGS ('dbx_business_glossary_term' = 'Assessor Name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `assessor_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `assessor_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `coinsurance_pct` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `coinsurance_penalty_flag` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Penalty Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `construction_type` SET TAGS ('dbx_business_glossary_term' = 'COPE Construction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `construction_type` SET TAGS ('dbx_value_regex' = 'frame|joisted_masonry|masonry_noncombustible|modified_fire_resistive|fire_resistive');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `cost_index_factor` SET TAGS ('dbx_business_glossary_term' = 'Construction Cost Index Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `data_source` SET TAGS ('dbx_value_regex' = 'guidewire_pc|duck_creek|sapiens_idit|verisk|corelogic|manual');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Assessment Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Assessment Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `inflation_guard_pct` SET TAGS ('dbx_business_glossary_term' = 'Inflation Guard Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `itv_ratio` SET TAGS ('dbx_business_glossary_term' = 'Insurance-to-Value (ITV) Ratio');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `number_of_stories` SET TAGS ('dbx_business_glossary_term' = 'Number of Stories');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `occupancy_code` SET TAGS ('dbx_business_glossary_term' = 'COPE Occupancy Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `protection_class` SET TAGS ('dbx_business_glossary_term' = 'ISO Protection Class');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `protection_class` SET TAGS ('dbx_value_regex' = '^([1-9]|10|10W)$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `report_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Valuation Report Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `reported_tiv` SET TAGS ('dbx_business_glossary_term' = 'Reported Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `reported_tiv` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `roof_material` SET TAGS ('dbx_business_glossary_term' = 'Roof Material');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `roof_material` SET TAGS ('dbx_value_regex' = 'asphalt_shingle|metal|tile|slate|built_up|membrane');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `roof_type` SET TAGS ('dbx_business_glossary_term' = 'Roof Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `roof_type` SET TAGS ('dbx_value_regex' = 'flat|gable|hip|mansard|gambrel|shed');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `roof_year` SET TAGS ('dbx_business_glossary_term' = 'Roof Year');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `sprinkler_flag` SET TAGS ('dbx_business_glossary_term' = 'Sprinkler System Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `total_area_sqft` SET TAGS ('dbx_business_glossary_term' = 'Total Building Area (Square Feet)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `underinsurance_gap` SET TAGS ('dbx_business_glossary_term' = 'Underinsurance Gap Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `underinsurance_gap` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `uw_action_taken` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Action Taken');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `uw_action_taken` SET TAGS ('dbx_value_regex' = 'none|limit_increased|coinsurance_waived|policy_endorsed|declined|referred');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `uw_review_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Review Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `uw_reviewed_date` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Review Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `valuation_basis` SET TAGS ('dbx_business_glossary_term' = 'Valuation Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `valuation_basis` SET TAGS ('dbx_value_regex' = 'rcv|acv|functional_rcv|agreed_value');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ALTER COLUMN `year_built` SET TAGS ('dbx_business_glossary_term' = 'Year Built');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` SET TAGS ('dbx_subdomain' = 'product_catalog');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Peril ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `effective_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Effective Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `limit_id` SET TAGS ('dbx_business_glossary_term' = 'Sublimit ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `peril_coverage_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `peril_coverage_peril_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `peril_coverage_peril_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `aggregate_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `association_status` SET TAGS ('dbx_business_glossary_term' = 'Peril Association Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `association_status` SET TAGS ('dbx_value_regex' = 'ACTIVE|INACTIVE|PENDING|SUPERSEDED|WITHDRAWN');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `cat_designation_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Designation Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `cat_event_type` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `cat_peril_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Peril Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `cat_peril_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `cat_peril_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Peril Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `cat_xl_applicable_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Excess of Loss (CAT XL) Applicable Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_category` SET TAGS ('dbx_business_glossary_term' = 'Peril Category');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_category` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_category` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_code` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_form_edition_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Edition Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_form_edition_date` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_form_edition_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_form_number` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_form_number` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_form_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_status` SET TAGS ('dbx_business_glossary_term' = 'Peril Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_status` SET TAGS ('dbx_value_regex' = 'active|inactive|deprecated|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_status` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_status` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_trigger` SET TAGS ('dbx_business_glossary_term' = 'Coverage Trigger');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_trigger` SET TAGS ('dbx_value_regex' = 'occurrence|claims-made|manifestation|exposure|other');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_trigger` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_trigger` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Peril-Specific Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `deductible_basis` SET TAGS ('dbx_business_glossary_term' = 'Peril Deductible Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `deductible_basis` SET TAGS ('dbx_value_regex' = 'PER_OCCURRENCE|PER_CLAIM|ANNUAL_AGGREGATE|PER_LOCATION|PER_UNIT');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `deductible_percentage` SET TAGS ('dbx_business_glossary_term' = 'Peril Deductible Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `deductible_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `deductible_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `deductible_type` SET TAGS ('dbx_business_glossary_term' = 'Peril Deductible Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `deductible_type` SET TAGS ('dbx_value_regex' = 'FLAT|PERCENTAGE|FRANCHISE|DISAPPEARING|SPLIT');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_description` SET TAGS ('dbx_business_glossary_term' = 'Peril Description');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_description` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_description` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `endorsement_type_code` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Type Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `endorsement_type_code` SET TAGS ('dbx_value_regex' = 'ADD|REMOVE|MODIFY|RESTRICT|EXTEND');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `excluded_by_default_flag` SET TAGS ('dbx_business_glossary_term' = 'Excluded by Default Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `exclusion_description` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Description');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `exclusion_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `frequency_rating` SET TAGS ('dbx_business_glossary_term' = 'Frequency Rating');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `frequency_rating` SET TAGS ('dbx_value_regex' = 'rare|occasional|frequent|very-frequent');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `frequency_rating` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `frequency_rating` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_value_regex' = 'global|regional|localized|property-specific');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `group_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Group Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `insurable_flag` SET TAGS ('dbx_business_glossary_term' = 'Insurable Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `insured_flag` SET TAGS ('dbx_business_glossary_term' = 'Insured Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `iso_peril_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Peril Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `iso_peril_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `loss_settlement_basis` SET TAGS ('dbx_business_glossary_term' = 'Loss Settlement Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `loss_settlement_basis` SET TAGS ('dbx_value_regex' = 'OCCURRENCE|CLAIMS_MADE|REPORTING');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `mandatory_peril_flag` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Peril Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `naic_peril_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Peril Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `naic_peril_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2,4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_name` SET TAGS ('dbx_business_glossary_term' = 'Peril Name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `nfip_overlap_indicator` SET TAGS ('dbx_business_glossary_term' = 'National Flood Insurance Program (NFIP) Overlap Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `pml_modeling_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Modeling Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Peril Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `rate` SET TAGS ('dbx_business_glossary_term' = 'Peril Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `regulatory_reporting_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `regulatory_reporting_required_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `regulatory_reporting_required_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `reinsurance_peril_code` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Peril Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `reinsurance_peril_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `reinsurance_peril_code` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `reinsurance_peril_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `reinsurance_treaty_applicable_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Treaty Applicable Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `reinsurance_treaty_applicable_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `reinsurance_treaty_applicable_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `retroactive_date` SET TAGS ('dbx_business_glossary_term' = 'Retroactive Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `scheduled_peril_flag` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Peril Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `severity_rating` SET TAGS ('dbx_business_glossary_term' = 'Severity Rating');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `severity_rating` SET TAGS ('dbx_value_regex' = 'low|moderate|high|catastrophic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `severity_rating` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `severity_rating` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `sir_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'GUIDEWIRE|DUCK_CREEK|SAPIENS|MANUAL|MIGRATION');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `sublimit_amount` SET TAGS ('dbx_business_glossary_term' = 'Peril Sublimit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `sublimit_basis` SET TAGS ('dbx_business_glossary_term' = 'Peril Sublimit Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `sublimit_basis` SET TAGS ('dbx_value_regex' = 'PER_OCCURRENCE|PER_CLAIM|ANNUAL_AGGREGATE|PER_LOCATION');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'ACV|RCV|AGREED_VALUE|FUNCTIONAL|MARKET');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]{1,3}.[0-9]{1,3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_business_glossary_term' = 'Waiting Period Days');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`peril` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`peril` SET TAGS ('dbx_subdomain' = 'policy_binding');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`peril` ALTER COLUMN `peril_id` SET TAGS ('dbx_business_glossary_term' = 'peril Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`peril` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Reference to policy_coverage');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`peril` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`peril` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` SET TAGS ('dbx_subdomain' = 'policy_binding');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `waiver_of_subrogation_id` SET TAGS ('dbx_business_glossary_term' = 'Waiver of Subrogation ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `document_id` SET TAGS ('dbx_business_glossary_term' = 'Document Reference ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `endorsement_id` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Exposure ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `additional_premium` SET TAGS ('dbx_business_glossary_term' = 'Additional Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `beneficiary_fein` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Federal Employer Identification Number (FEIN)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `beneficiary_fein` SET TAGS ('dbx_value_regex' = '^[0-9]{2}-[0-9]{7}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `beneficiary_fein` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `beneficiary_fein` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `beneficiary_fein` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `beneficiary_name` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `beneficiary_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `beneficiary_name` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `beneficiary_relationship` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Relationship');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `beneficiary_type` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `beneficiary_type` SET TAGS ('dbx_value_regex' = 'individual|corporation|partnership|government|trust|other');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `blanket_waiver_flag` SET TAGS ('dbx_business_glossary_term' = 'Blanket Waiver Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation (CANC) Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Cancellation (CANC) Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_value_regex' = 'insured_request|underwriter_decision|policy_cancellation|non_payment|other');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `contractual_requirement_flag` SET TAGS ('dbx_business_glossary_term' = 'Contractual Requirement Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `coverage_scope` SET TAGS ('dbx_business_glossary_term' = 'Coverage Scope');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `coverage_scope` SET TAGS ('dbx_value_regex' = 'blanket|scheduled|project_specific|location_specific');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `coverage_scope` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `coverage_scope` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `endorsement_status` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `endorsement_status` SET TAGS ('dbx_value_regex' = 'active|pending|cancelled|expired|superseded');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `exclusion_notes` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `location_description` SET TAGS ('dbx_business_glossary_term' = 'Location Description');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `naic_line_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Line Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `naic_line_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2}(.1)?$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `premium_basis` SET TAGS ('dbx_business_glossary_term' = 'Premium Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `premium_basis` SET TAGS ('dbx_value_regex' = 'flat|percentage_of_premium|payroll|receipts|other');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `premium_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Premium Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `premium_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `project_name` SET TAGS ('dbx_business_glossary_term' = 'Project Name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `project_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `project_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `project_number` SET TAGS ('dbx_business_glossary_term' = 'Project Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `regulatory_filing_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `regulatory_filing_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `regulatory_filing_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|filed|approved|rejected');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `reinsurance_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Eligible Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `reinsurance_eligible_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `reinsurance_eligible_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'guidewire|duck_creek|sapiens_idit|other');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference ID');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `subrogation_rights_description` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Rights Description');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `uw_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `uw_approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Approval Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `uw_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Approved By');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `waiver_type` SET TAGS ('dbx_business_glossary_term' = 'Waiver Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `waiver_type` SET TAGS ('dbx_value_regex' = 'blanket|specific|contractual|statutory');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `wc_class_code` SET TAGS ('dbx_business_glossary_term' = 'Workers Compensation (WC) Class Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ALTER COLUMN `wc_class_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` SET TAGS ('dbx_subdomain' = 'risk_valuation');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Exposure Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `deductible_id` SET TAGS ('dbx_business_glossary_term' = 'Deductible Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `effective_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Effective Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `endorsement_id` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Vehicle Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `limit_id` SET TAGS ('dbx_business_glossary_term' = 'Limit Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `scheduled_item_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Item Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `sir_layer_id` SET TAGS ('dbx_business_glossary_term' = 'Sir Layer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `cat_exposed_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `construction_type` SET TAGS ('dbx_business_glossary_term' = 'Construction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `construction_type` SET TAGS ('dbx_value_regex' = 'frame|joisted_masonry|noncombustible|masonry_noncombustible|modified_fire_resistive|fire_resistive');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `coverage_scope` SET TAGS ('dbx_business_glossary_term' = 'Coverage Scope');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `coverage_scope` SET TAGS ('dbx_value_regex' = 'specific|blanket|scheduled|floating');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `coverage_scope` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `coverage_scope` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `earned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `exclusion_codes` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Codes');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `exposure_status` SET TAGS ('dbx_business_glossary_term' = 'Exposure Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `exposure_status` SET TAGS ('dbx_value_regex' = 'active|suspended|cancelled|expired|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `exposure_type` SET TAGS ('dbx_business_glossary_term' = 'Exposure Type');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `exposure_type` SET TAGS ('dbx_value_regex' = 'location|vehicle|scheduled_item|blanket|floating');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `itv_ratio` SET TAGS ('dbx_business_glossary_term' = 'Insurance to Value (ITV) Ratio');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `occupancy_code` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `premium_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Premium Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `premium_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `protection_class` SET TAGS ('dbx_business_glossary_term' = 'Protection Class');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Exposure Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `reinsurance_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Eligible Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `reinsurance_eligible_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `reinsurance_eligible_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `tiv_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `unearned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Unearned Premium (UEP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'ACV|RCV|agreed_value|stated_amount|market_value');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_business_glossary_term' = 'Waiting Period Days');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ALTER COLUMN `written_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Written Premium (WP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` SET TAGS ('dbx_subdomain' = 'risk_valuation');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` SET TAGS ('dbx_association_edges' = 'coverage.coverage_policy_coverage,reinsurance.reinsurer');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `cession_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Cession Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Cession - Coverage Policy Coverage Id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Cession - Reinsurer Id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `ceded_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `ceded_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `ceded_share_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceded Share Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `collateral_held_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Held Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Cession Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Cession Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Cession Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `facultative_certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Facultative Certificate Number');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `participation_status` SET TAGS ('dbx_business_glossary_term' = 'Participation Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `recoverable_balance` SET TAGS ('dbx_business_glossary_term' = 'Recoverable Balance');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ALTER COLUMN `settlement_status` SET TAGS ('dbx_business_glossary_term' = 'Settlement Status');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`product` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`product` SET TAGS ('dbx_subdomain' = 'product_catalog');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`product` ALTER COLUMN `product_id` SET TAGS ('dbx_business_glossary_term' = 'Product Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`product` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`product` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`product` ALTER COLUMN `extended_reporting_period_months` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`product` ALTER COLUMN `extended_reporting_period_months` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`product` ALTER COLUMN `product_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`product` ALTER COLUMN `product_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`product` ALTER COLUMN `rating_plan_code` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`product` ALTER COLUMN `rating_plan_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`product` ALTER COLUMN `reinsurance_treaty_applicable` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`product` ALTER COLUMN `reinsurance_treaty_applicable` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`product` ALTER COLUMN `reporting_form_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`product` ALTER COLUMN `reporting_form_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`product` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`product` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_pii_flag' = 'true');
