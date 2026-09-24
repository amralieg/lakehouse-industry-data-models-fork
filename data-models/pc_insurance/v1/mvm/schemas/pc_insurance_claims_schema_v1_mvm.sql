-- Schema for Domain: claims | Business: Pc_Insurance | Version: v1_mvm
-- Generated on: 2026-09-20 21:40:51

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_blog_v499`.`claims` COMMENT 'Provisional description for user-specified domain claims. Awaiting a generated description of what this domain owns.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` (
    `loss_event_id` BIGINT COMMENT 'Unique identifier for the loss event occurrence. Primary key.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Loss events are aggregated by accident year and fiscal period for catastrophe exposure reporting, reinsurance treaty reinstatement calculations, and NAIC CAT reporting.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Zone-level loss accumulation reporting groups loss events by cat zone to compare against accumulation limits and reinsurance attachment points.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key to the catastrophe event if this loss is part of a declared catastrophe.',
    `currency_id` BIGINT COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts associated with this loss event.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Loss event geocoding links the loss location to the geographic hierarchy for territory-level loss ratio reporting, regulatory state filings, and catastrophe exposure',
    `peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophegeography_peril. Business justification: Normalizes the peril that caused the loss event, enabling peril-level loss aggregation across events for cat modeling input and reinsurance treaty peril',
    `cat_serial_number` STRING COMMENT 'Industry-standard catastrophe serial number assigned by ISO or PCS for declared catastrophe events.',
    `closed_date` DATE COMMENT 'Date when the loss event was closed and all associated claims were finalized.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this loss event record was first created in the claims management system.',
    `estimated_total_loss_amount` DECIMAL(15,2) COMMENT 'Initial estimated total financial impact of the loss event across all affected claims and coverages.',
    `fatality_occurred` BOOLEAN COMMENT 'Indicates whether a fatality occurred as part of this loss event, requiring special handling and reporting.',
    `fire_department_notified` BOOLEAN COMMENT 'Indicates whether the fire department was notified and responded to this loss event.',
    `fire_report_number` STRING COMMENT 'Official fire department report number or incident number for fire-related losses.',
    `fraud_indicator` BOOLEAN COMMENT 'Indicates whether this loss event has been flagged for potential fraud investigation by SIU.',
    `injury_occurred` BOOLEAN COMMENT 'Indicates whether bodily injury occurred as part of this loss event, triggering liability and medical coverage.',
    `is_catastrophe_loss` BOOLEAN COMMENT 'Indicates whether this loss event is part of a declared catastrophe event for aggregation and reinsurance purposes.',
    `is_large_loss` BOOLEAN COMMENT 'Indicates whether this loss exceeds the threshold for large loss reporting and special handling.',
    `large_loss_threshold_amount` DECIMAL(15,2) COMMENT 'Monetary threshold amount that defines a large loss for this event, used for reinsurance and escalation.',
    `loss_complexity_code` STRING COMMENT 'Classification of the loss event by complexity, used for adjuster assignment and workflow routing.. Valid values are `simple|moderate|complex|highly_complex`',
    `loss_description` STRING COMMENT 'Narrative description of the loss event, including circumstances, cause, and extent of damage or injury.',
    `loss_discovery_date` DATE COMMENT 'Date when the loss was first discovered or became known to the insured or insurer.',
    `loss_event_status` STRING COMMENT 'Current lifecycle state of the loss event in the claims workflow.. Valid values are `open|closed|under_investigation|pending_review|resolved`',
    `loss_event_type` STRING COMMENT 'Classification of the physical loss occurrence by peril or cause of loss. [ENUM-REF-CANDIDATE: fire|water_damage|wind|hail|theft|vandalism|collision|liability|weather|flood|earthquake|explosion|other — 13 candidates stripped; promote to reference product]',
    `loss_location_address` STRING COMMENT 'Street address where the loss event occurred. Used for catastrophe aggregation and geographic analysis.',
    `loss_location_city` STRING COMMENT 'City where the loss event occurred.',
    `loss_location_country` STRING COMMENT 'Three-letter ISO country code where the loss event occurred.. Valid values are `USA|CAN|MEX`',
    `loss_location_latitude` DECIMAL(10,7) COMMENT 'Geographic latitude coordinate of the loss location, used for catastrophe modeling and spatial analysis.',
    `loss_location_longitude` DECIMAL(10,7) COMMENT 'Geographic longitude coordinate of the loss location, used for catastrophe modeling and spatial analysis.',
    `loss_location_postal_code` STRING COMMENT 'Postal or ZIP code of the loss location, used for geocoding and catastrophe zone assignment.',
    `loss_location_state` STRING COMMENT 'State or province where the loss event occurred. Critical for regulatory reporting and territorial analysis.',
    `loss_occurrence_date` DATE COMMENT 'The calendar date on which the physical loss event occurred. Critical for policy coverage determination and loss reserving.',
    `loss_occurrence_timestamp` TIMESTAMP COMMENT 'Precise date and time when the loss event occurred, used for detailed event sequencing and catastrophe modeling.',
    `loss_reported_date` DATE COMMENT 'Date when the loss was formally reported to the insurer, triggering First Notice of Loss (FNOL) processing.',
    `loss_severity_code` STRING COMMENT 'Classification of the loss event by severity level, used for triage and resource allocation.. Valid values are `minor|moderate|major|total_loss|catastrophic`',
    `notes` STRING COMMENT 'Additional notes, comments, or observations about the loss event for internal use.',
    `number` STRING COMMENT 'Business identifier for the loss event, externally visible and used for tracking and reporting.',
    `number_of_fatalities` BIGINT COMMENT 'Count of fatalities resulting from this loss event.',
    `number_of_injuries` BIGINT COMMENT 'Count of individuals injured in this loss event.',
    `police_report_filed` BOOLEAN COMMENT 'Indicates whether a police report was filed for this loss event, relevant for theft, vandalism, and liability claims.',
    `police_report_number` STRING COMMENT 'Official police report number or case number associated with this loss event.',
    `reopened_date` DATE COMMENT 'Date when a previously closed loss event was reopened for additional investigation or claims processing.',
    `salvage_potential` BOOLEAN COMMENT 'Indicates whether damaged property from this loss event has salvage value that can be recovered.',
    `siu_referral_date` DATE COMMENT 'Date when this loss event was referred to the Special Investigation Unit for fraud investigation.',
    `subrogation_potential` BOOLEAN COMMENT 'Indicates whether this loss event has potential for subrogation recovery from a responsible third party.',
    `third_party_involved` BOOLEAN COMMENT 'Indicates whether a third party is involved in this loss event, triggering liability investigation.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp when this loss event record was last modified.',
    `weather_condition` STRING COMMENT 'Description of weather conditions at the time of loss, relevant for weather-related perils.',
    CONSTRAINT pk_loss_event PRIMARY KEY(`loss_event_id`)
) COMMENT 'Master record of a physical loss occurrence (storm, fire, collision, liability event). One row per occurrence. Links multiple claims arising from the same event. Supports CAT aggregation and PML analysis.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` (
    `claim_id` BIGINT COMMENT 'Unique identifier for the claim. Primary key. Grain: one row per reported loss.',
    `agency_id` BIGINT COMMENT 'Foreign key linking to producers.agency. Business justification: Agency-level loss ratio monitoring, contingent commission calculation, and regulatory claim reporting all require direct claim-to-agency attribution.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Claims must be aligned to accident year, policy year, and report year periods for NAIC Schedule P loss development triangles and IBNR actuarial analysis.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Cat zone assignment on a claim drives reinsurance treaty attachment determination and bordereaux reporting.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key to the catastrophe event if this claim is CAT-related.',
    `claim_adjuster_party_id` BIGINT COMMENT 'Foreign key to the party record of the assigned adjuster.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Claim payments, reserves, and incurred amounts are monetary values requiring currency context for multi-currency insurer operations, GAAP/IFRS17 reporting, and reinsurance settlement.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Links claim loss location to the geography master for territory-level loss ratio reporting, state regulatory filings, and geographic concentration analysis.',
    `insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Claims adjusters review underwriting risk scores for SIU referral decisions, subrogation potential assessment, and fraud pattern analysis.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Normalize lob_code string to FK reference to shared.line_of_business master data. Claim currently stores lob_code as string; replacing with FK enables consistent LOB classification',
    `location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.location. Business justification: Pre-bind inspection reports establish baseline property condition for damage assessment, fraud detection, and pre-existing damage disputes.',
    `loss_event_id` BIGINT COMMENT 'Foreign key to the loss event that triggered this claim.',
    `peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophegeography_peril. Business justification: Normalizes peril classification on claims, replacing denormalized peril_code and peril_description.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy under which this claim was filed.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the specific policy term in force at the time of loss.',
    `primary_claimant_party_id` BIGINT COMMENT 'Foreign key to the party record of the primary claimant.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key linking to producers.producers_producer. Business justification: Tracks producer/agent of record at time of loss for commission clawback calculations, producer loss ratio reporting, E&O exposure analysis, and regulatory claim-to-producer',
    `ri_agreement_id` BIGINT COMMENT 'Foreign key to the reinsurance agreement applicable to this claim.',
    `risk_score_id` BIGINT COMMENT 'Foreign key linking to riskexposure.risk_score. Business justification: Fraud analytics and reserve adequacy — linking the underwriting risk score at policy bind to the resulting claim enables predictive model validation, SIU referral scoring, and',
    `uw_decision_id` BIGINT COMMENT 'Foreign key linking to coverage.uw_decision. Business justification: Underwriting decisions (referrals, conditions, exclusions, modified terms) are reviewed during claims for coverage interpretation, exclusion enforcement, and bad faith litigation',
    `accident_year` BIGINT COMMENT 'Calendar year in which the loss occurred, used for actuarial reserving and loss development.',
    `adjuster_type` STRING COMMENT 'Type of adjuster assigned to the claim.. Valid values are `staff|independent|public`',
    `catastrophe_flag` BOOLEAN COMMENT 'Indicates whether this claim is associated with a catastrophe event.',
    `claim_status` STRING COMMENT 'Current lifecycle status of the claim.. Valid values are `open|closed|reopened|pending|denied|withdrawn`',
    `claimant_type` STRING COMMENT 'Indicates whether the claimant is a first-party or third-party claimant.. Valid values are `first_party|third_party`',
    `close_date` DATE COMMENT 'Date when the claim was closed or finalized.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this claim record was first created in the system.',
    `fnol_date` DATE COMMENT 'Date when the claim was first reported to the insurer.',
    `fnol_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the claim was first reported to the insurer.',
    `iso_cat_serial_number` STRING COMMENT 'ISO-assigned serial number for the catastrophe event.',
    `litigation_date` DATE COMMENT 'Date when litigation was initiated for this claim.',
    `litigation_flag` BOOLEAN COMMENT 'Indicates whether this claim is in litigation or has legal representation involved.',
    `loss_date` DATE COMMENT 'Date when the loss or accident occurred.',
    `loss_description` STRING COMMENT 'Detailed narrative description of the loss event and circumstances.',
    `loss_location_address` STRING COMMENT 'Street address where the loss occurred.',
    `loss_location_city` STRING COMMENT 'City where the loss occurred.',
    `loss_location_country` STRING COMMENT 'Country where the loss occurred, using 3-letter ISO code.. Valid values are `USA|CAN|MEX`',
    `loss_location_postal_code` STRING COMMENT 'Postal or ZIP code where the loss occurred.',
    `loss_location_state` STRING COMMENT 'State or province where the loss occurred.',
    `loss_time` TIMESTAMP COMMENT 'Precise time when the loss or accident occurred, if known.',
    `number` STRING COMMENT 'Externally-known unique claim number assigned by the insurer for tracking and reference.',
    `policy_year` BIGINT COMMENT 'Policy year in which the loss occurred, used for policy-year loss analysis.',
    `reinsurance_flag` BOOLEAN COMMENT 'Indicates whether this claim is subject to reinsurance cession.',
    `reopen_date` DATE COMMENT 'Date when the claim was reopened after being previously closed.',
    `report_date` DATE COMMENT 'Date when the claim was formally recorded in the claims system.',
    `report_year` BIGINT COMMENT 'Calendar year in which the claim was reported.',
    `salvage_flag` BOOLEAN COMMENT 'Indicates whether salvage recovery is applicable for this claim.',
    `siu_flag` BOOLEAN COMMENT 'Indicates whether this claim has been referred to the Special Investigations Unit for fraud investigation.',
    `siu_referral_date` DATE COMMENT 'Date when the claim was referred to SIU.',
    `status_reason` STRING COMMENT 'Reason or explanation for the current claim status.',
    `subrogation_flag` BOOLEAN COMMENT 'Indicates whether subrogation is being pursued for this claim.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this claim record was last modified.',
    CONSTRAINT pk_claim PRIMARY KEY(`claim_id`)
) COMMENT 'Grain: one row per reported loss. Each record represents a single claim reported against a policy.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` (
    `claimant_id` BIGINT COMMENT 'Unique identifier for the claimant record. Grain: one row per party per claim.',
    `claim_id` BIGINT COMMENT 'Foreign key to the parent claim this claimant is associated with.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: settlement_demand_amount and settlement_offer_amount on claimant are monetary; currency FK is required for multi-currency claim settlement operations and accurate financial reporting of',
    `mailing_address_id` BIGINT COMMENT 'Foreign key linking to party.address. Business justification: Claims correspondence, settlement checks, and legal notices require a verified, standardized claimant address.',
    `party_id` BIGINT COMMENT 'Foreign key to the party master record representing this claimant.',
    `attorney_contact_email` STRING COMMENT 'Primary email address for the claimants attorney or law firm.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `attorney_contact_phone` STRING COMMENT 'Primary contact phone number for the claimants attorney or law firm.',
    `attorney_name` STRING COMMENT 'Full name of the attorney or law firm representing the claimant, if applicable.',
    `claimant_status` STRING COMMENT 'Current lifecycle status of the claimant within the claim: active, closed, withdrawn, settled, denied, or pending investigation.. Valid values are `active|closed|withdrawn|settled|denied|pending`',
    `claimant_type` STRING COMMENT 'Classification of the claimant role: first-party insured, third-party claimant, additional insured, named insured, or other.. Valid values are `first_party|third_party|additional_insured|named_insured|other`',
    `contact_preference` STRING COMMENT 'Preferred method of communication for the claimant: email, phone, mail, SMS, or online portal.. Valid values are `email|phone|mail|sms|portal`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the claimant record was first created in the claims system.',
    `date_of_death` DATE COMMENT 'Date of death if the claimant died as a result of the loss event. Null if claimant is alive.',
    `date_of_injury` DATE COMMENT 'The specific date on which the claimant sustained the injury or damage, which may differ from the loss event date in some cases.',
    `fault_indicator` BOOLEAN COMMENT 'Boolean flag indicating whether the claimant is determined to be at fault in the loss event. True if at fault, False otherwise.',
    `fraud_indicator_flag` BOOLEAN COMMENT 'Boolean flag indicating whether fraud indicators or red flags have been identified for this claimant. True if indicators present, False otherwise.',
    `guardian_contact_phone` STRING COMMENT 'Primary contact phone number for the claimants legal guardian or parent.',
    `guardian_name` STRING COMMENT 'Full name of the legal guardian or parent if the claimant is a minor or legally incapacitated.',
    `hospital_name` STRING COMMENT 'Name of the hospital or medical facility where the claimant received treatment, if applicable.',
    `hospitalization_flag` BOOLEAN COMMENT 'Boolean flag indicating whether the claimant was hospitalized as a result of the loss event. True if hospitalized, False otherwise.',
    `injury_description` STRING COMMENT 'Detailed narrative description of the injury or damage sustained by the claimant, as reported during First Notice of Loss (FNOL) or investigation.',
    `injury_severity_code` STRING COMMENT 'Standardized severity classification of the injury: minor, moderate, major, catastrophic, or fatal.. Valid values are `minor|moderate|major|catastrophic|fatal`',
    `injury_type` STRING COMMENT 'Type of injury or damage sustained by the claimant: bodily injury, property damage, both, or none.. Valid values are `bodily_injury|property_damage|both|none`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the claimant record was last updated or modified in the claims system.',
    `liability_percentage` DECIMAL(5,2) COMMENT 'Percentage of liability attributed to this claimant in comparative negligence or contributory negligence scenarios, ranging from 0.00 to 100.00.',
    `medical_treatment_required_flag` BOOLEAN COMMENT 'Boolean flag indicating whether the claimant required or is receiving medical treatment for injuries sustained. True if treatment required, False otherwise.',
    `minor_flag` BOOLEAN COMMENT 'Boolean flag indicating whether the claimant is a minor (under 18 years of age). True if minor, False otherwise.',
    `notes` STRING COMMENT 'Free-form text field for adjuster notes, observations, and additional context regarding the claimant and their involvement in the claim.',
    `number` STRING COMMENT 'Business-facing unique identifier for the claimant within the claim, often displayed on correspondence and documents.',
    `primary_contact_email` STRING COMMENT 'Primary email address to reach the claimant for claim-related communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_contact_phone` STRING COMMENT 'Primary phone number to reach the claimant for claim-related communications.',
    `relationship_to_insured` STRING COMMENT 'Describes the claimants relationship to the named insured: self, spouse, child, parent, other relative, employee, passenger, pedestrian, or other. [ENUM-REF-CANDIDATE: self|spouse|child|parent|other_relative|employee|passenger|pedestrian|other — 9',
    `release_signed_date` DATE COMMENT 'Date on which the claimant signed the legal release document.',
    `release_signed_flag` BOOLEAN COMMENT 'Boolean flag indicating whether the claimant has signed a legal release waiving further claims. True if signed, False otherwise.',
    `represented_by_attorney_flag` BOOLEAN COMMENT 'Boolean flag indicating whether the claimant is represented by legal counsel. True if represented, False otherwise.',
    `settlement_date` DATE COMMENT 'Date on which the claimants portion of the claim was settled and agreed upon by all parties.',
    `settlement_demand_amount` DECIMAL(15,2) COMMENT 'The monetary amount demanded by the claimant or their attorney for settlement of the claim.',
    `settlement_offer_amount` DECIMAL(15,2) COMMENT 'The monetary amount offered by the insurer to settle the claimants portion of the claim.',
    `siu_referral_date` DATE COMMENT 'Date on which the claimant was referred to the Special Investigation Unit for fraud investigation.',
    `siu_referral_flag` BOOLEAN COMMENT 'Boolean flag indicating whether this claimant has been referred to the Special Investigation Unit for fraud investigation. True if referred, False otherwise.',
    `subrogation_potential_flag` BOOLEAN COMMENT 'Boolean flag indicating whether this claimant presents potential for subrogation recovery. True if potential exists, False otherwise.',
    `treating_physician_name` STRING COMMENT 'Full name of the primary physician treating the claimant for injuries sustained in the loss event.',
    CONSTRAINT pk_claimant PRIMARY KEY(`claimant_id`)
) COMMENT 'Party involved in a claim as first-party insured or third-party claimant. Grain: one row per party per claim. Captures claimant type (FP/TP), injury or damage description, and links to Party domain.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` (
    `claim_exposure_id` BIGINT COMMENT 'Unique identifier for the claim exposure. Primary key. Grain: one row per coverage per claim.',
    `adjuster_id` BIGINT COMMENT 'Foreign key to the adjuster assigned to handle this exposure.',
    `building_id` BIGINT COMMENT 'Foreign key linking to riskexposure.building. Business justification: Property claims adjustment — repair scopes, replacement cost verification, and construction-type coverage checks require the specific building per exposure.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Cat zone at the exposure level is required for reinsurance cession calculation and treaty bordereau reporting at per-coverage granularity.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key to the catastrophe event if this exposure is CAT-related. Nullable for non-CAT exposures.',
    `claim_id` BIGINT COMMENT 'Foreign key to the parent claim. Links this exposure to the reported loss event.',
    `claimant_id` BIGINT COMMENT 'Foreign key to the claimant (first party or third party) associated with this exposure.',
    `coverage_id` BIGINT COMMENT 'Foreign key to the coverage under which this exposure is being claimed.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: claim_exposure carries incurred_amount, paid_amount, lae_paid_amount, outstanding_reserve_amount — all monetary.',
    `driver_id` BIGINT COMMENT 'Foreign key linking to riskexposure.driver. Business justification: Auto liability/BI/PD claims — excluded-driver coverage verification, subrogation eligibility, and MVR review at claim time require identifying the specific driver per exposure.',
    `insured_risk_id` BIGINT COMMENT 'Foreign key to the insured risk (property, vehicle, driver) that suffered the loss.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Claim exposure is the grain for NAIC Schedule P loss development triangles, which are organized by line of business.',
    `peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Claim exposures track coverage_type and loss_cause but lack FK to peril master. Underwriters and actuaries need peril attributes (cat_peril flag, severity classification',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term in force at the loss date. Enables effective-dated coverage reconstruction.',
    `vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.vehicle. Business justification: Auto claims processing — total-loss evaluation, salvage disposition, and rental initiation require the specific vehicle per coverage exposure.',
    `accident_year` BIGINT COMMENT 'Calendar year in which the loss occurred. Derived from loss_date for actuarial and statutory reporting.',
    `catastrophe_flag` BOOLEAN COMMENT 'True if this exposure is part of a declared catastrophe event. Drives CAT reporting and reinsurance recovery.',
    `claim_party_role` STRING COMMENT 'Indicates whether the claimant is a first party (insured) or third party (external claimant).. Valid values are `first_party|third_party`',
    `closed_date` DATE COMMENT 'Date the exposure was closed. Nullable until closure. Used for settlement lag and closure rate analytics.',
    `coverage_limit_amount` DECIMAL(18,2) COMMENT 'Maximum amount payable under this coverage for this exposure. Denormalized from coverage for financial posting efficiency.',
    `coverage_type` STRING COMMENT 'Type of coverage under which the exposure is claimed (e.g., Property Damage, Bodily Injury, Collision, Comprehensive, Liability).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this exposure record was first created in the system.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Deductible applicable to this exposure. Denormalized from coverage for payment calculation efficiency.',
    `denial_reason` STRING COMMENT 'Reason for denial if the exposure was denied. Nullable if not denied.',
    `exposure_description` STRING COMMENT 'Narrative description of the exposure, including nature of injury or damage and circumstances.',
    `exposure_number` STRING COMMENT 'Business identifier for the exposure, often a concatenation of claim number and coverage line sequence.',
    `exposure_status` STRING COMMENT 'Current lifecycle status of the claim exposure. Drives workflow and financial posting rules.. Valid values are `open|closed|reopened|denied|pending|settled`',
    `fraud_flag` BOOLEAN COMMENT 'True if this exposure has been flagged for potential fraud by SIU or fraud detection systems.',
    `incurred_amount` DECIMAL(18,2) COMMENT 'Total incurred loss for this exposure (paid + outstanding reserves). Snapshot value for reporting.',
    `lae_paid_amount` DECIMAL(18,2) COMMENT 'Total allocated loss adjustment expense paid to date on this exposure.',
    `lae_reserve_amount` DECIMAL(18,2) COMMENT 'Current outstanding allocated loss adjustment expense reserve for this exposure.',
    `liability_indicator` BOOLEAN COMMENT 'True if this exposure involves liability coverage; false for property or other first-party coverages.',
    `litigation_flag` BOOLEAN COMMENT 'True if this exposure is in litigation or has legal representation involved.',
    `loss_cause` STRING COMMENT 'Peril or cause of loss for this exposure (e.g., Fire, Theft, Collision, Wind, Hail, Water Damage, Vandalism).',
    `loss_date` DATE COMMENT 'Date the loss occurred. Critical for policy term lookup, reserving, and accident year reporting.',
    `outstanding_reserve_amount` DECIMAL(18,2) COMMENT 'Current outstanding case reserve for this exposure. Snapshot value for reporting.',
    `paid_amount` DECIMAL(18,2) COMMENT 'Total amount paid to date on this exposure. Snapshot value for reporting.',
    `recovery_amount` DECIMAL(18,2) COMMENT 'Total recoveries received to date (subrogation, salvage, reinsurance). Snapshot value for reporting.',
    `reinsurance_ceded_flag` BOOLEAN COMMENT 'True if this exposure has been ceded to reinsurance under treaty or facultative agreements.',
    `reopened_date` DATE COMMENT 'Date the exposure was reopened after initial closure. Nullable if never reopened.',
    `report_year` BIGINT COMMENT 'Calendar year in which the exposure was first reported. Derived from reported_date for lag analysis.',
    `reported_date` DATE COMMENT 'Date the exposure was first reported to the insurer. Used for IBNR lag analysis and reporting year assignment.',
    `salvage_potential_flag` BOOLEAN COMMENT 'True if the exposure has potential for salvage recovery (e.g., damaged vehicle or property).',
    `settlement_type` STRING COMMENT 'Type of settlement reached for this exposure. Nullable until settled.. Valid values are `full_payment|partial_payment|denied|withdrawn|structured_settlement`',
    `siu_referral_date` DATE COMMENT 'Date the exposure was referred to SIU for fraud investigation. Nullable if not referred.',
    `subrogation_potential_flag` BOOLEAN COMMENT 'True if the exposure has potential for subrogation recovery from a third party.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this exposure record was last modified.',
    CONSTRAINT pk_claim_exposure PRIMARY KEY(`claim_exposure_id`)
) COMMENT 'Grain: one row per coverage line per claim. Each record represents a single coverage exposure within a claim, linking Claim to Coverage and Insured Risk.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` (
    `claim_status_id` BIGINT COMMENT 'Unique identifier for each claim status transition record. Primary key.',
    `adjuster_id` BIGINT COMMENT 'Foreign key to the adjuster assigned to the claim at the time of this status transition.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: claim_status snapshots reserve_amount, paid_amount, and incurred_amount at a point in time.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: claim_status records reserve_amount, paid_amount, and incurred_amount as financial snapshots.',
    `primary_status_claim_id` BIGINT COMMENT 'Foreign key to the parent claim for which this status transition applies.',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether supervisory or management approval is required for this status transition per authority limits.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the status transition was approved by authorized personnel, nullable if no approval required.',
    `approved_by_user_code` STRING COMMENT 'System identifier of the supervisor or manager who approved this status transition, nullable if no approval required.',
    `approved_by_user_name` STRING COMMENT 'Full name of the supervisor or manager who approved this status transition, for audit trail purposes.',
    `cat_serial_number` STRING COMMENT 'ISO catastrophe serial number linking this claim to a specific catastrophe event, nullable if not CAT-related.',
    `catastrophe_flag` BOOLEAN COMMENT 'Indicates whether this claim is associated with a declared catastrophe event at this status point.',
    `closure_type_code` STRING COMMENT 'Classification of how the claim was closed, applicable only when status is CLOSED. Supports loss ratio and settlement analytics.. Valid values are `PAID|DENIED|WITHDRAWN|SETTLED|LITIGATED`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this status transition record was first created in the source system.',
    `effective_timestamp` TIMESTAMP COMMENT 'Date and time when this status became effective, supporting point-in-time queries and regulatory reporting.',
    `expiration_timestamp` TIMESTAMP COMMENT 'Date and time when this status ceased to be effective, nullable for current status. Enables temporal queries.',
    `fraud_investigation_flag` BOOLEAN COMMENT 'Indicates whether the claim is under fraud investigation by Special Investigations Unit at this status point.',
    `incurred_amount` DECIMAL(18,2) COMMENT 'Total incurred loss amount at this status point, calculated as paid plus outstanding reserves.',
    `is_current_status` BOOLEAN COMMENT 'Boolean flag indicating whether this is the current active status for the claim. True for latest, false for historical.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this status transition record was last updated in the source system.',
    `litigation_flag` BOOLEAN COMMENT 'Indicates whether the claim is in litigation at this status point. True if litigated, false otherwise.',
    `litigation_start_date` DATE COMMENT 'Date when litigation commenced for this claim, nullable if not litigated. Supports legal expense tracking.',
    `paid_amount` DECIMAL(18,2) COMMENT 'Cumulative amount paid on the claim as of this status transition, in policy currency.',
    `previous_status_code` STRING COMMENT 'Status code immediately prior to this transition, enabling lifecycle reconstruction and audit trail.. Valid values are `OPEN|PENDING|CLOSED|REOPENED|DENIED|LITIGATED`',
    `reopen_count` BIGINT COMMENT 'Cumulative number of times the claim has been reopened as of this status transition, indicating claim complexity.',
    `reserve_amount` DECIMAL(18,2) COMMENT 'Total case reserve amount held for the claim at the time of this status transition, in policy currency.',
    `siu_referral_date` DATE COMMENT 'Date when the claim was referred to SIU for fraud investigation, nullable if not referred.',
    `status_code` STRING COMMENT 'Current lifecycle status of the claim at this transition point.. Valid values are `OPEN|PENDING|CLOSED|REOPENED|DENIED|LITIGATED`',
    `status_duration_days` BIGINT COMMENT 'Number of calendar days the claim remained in this status, calculated for cycle time and performance analytics.',
    `status_notes` STRING COMMENT 'Free-text notes or comments recorded by the adjuster or system at the time of status transition, supporting claim documentation.',
    `status_reason_code` STRING COMMENT 'Coded reason explaining why the status transition occurred, aligned with business rules and regulatory requirements.',
    `status_reason_description` STRING COMMENT 'Detailed narrative explanation of the reason for the status change, supporting audit and regulatory review.',
    `status_set_by_user_code` STRING COMMENT 'System identifier of the user or automated process that triggered this status transition.',
    `status_set_by_user_name` STRING COMMENT 'Full name of the user who set this status, supporting audit and accountability requirements.',
    `subrogation_flag` BOOLEAN COMMENT 'Indicates whether subrogation is being pursued at this status point. True if subrogation active, false otherwise.',
    `system_source_code` STRING COMMENT 'Code identifying the source system that recorded this status transition, supporting multi-system integration and data lineage.',
    `workflow_step_code` STRING COMMENT 'Code representing the workflow step or stage in the claims process at this status transition.',
    `workflow_step_name` STRING COMMENT 'Human-readable name of the workflow step or stage in the claims adjudication process.',
    CONSTRAINT pk_claim_status PRIMARY KEY(`claim_status_id`)
) COMMENT 'Lifecycle status history for a claim. Grain: one row per status transition per claim. Tracks Open, Pending, Closed, Reopened, Denied, Litigated transitions with effective timestamps and reason codes.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` (
    `adjuster_id` BIGINT COMMENT 'Unique identifier for the adjuster record. Primary key.',
    `license_id` BIGINT COMMENT 'Foreign key linking to party.license. Business justification: Adjuster licensing compliance is a state-mandated regulatory requirement. Linking adjuster to party.license enables license expiry monitoring, multi-state authorization checks, and DOI audit',
    `party_id` BIGINT COMMENT 'Reference to the party master record for this adjusters identity and contact information.',
    `supervisor_adjuster_id` BIGINT COMMENT 'Reference to the supervising adjuster or claims manager overseeing this adjusters work.',
    `adjuster_status` STRING COMMENT 'Current operational status of the adjuster indicating availability for claim assignments.. Valid values are `active|inactive|suspended|terminated|on_leave`',
    `adjuster_type` STRING COMMENT 'Classification of adjuster employment relationship: staff employee, independent contractor, third-party administrator, catastrophe specialist, or public adjuster.. Valid values are `staff|independent|tpa|catastrophe|public`',
    `background_check_date` DATE COMMENT 'Date the most recent background check was completed for the adjuster.',
    `background_check_status` STRING COMMENT 'Result status of the most recent background check.. Valid values are `passed|failed|pending|expired`',
    `catastrophe_qualified_flag` BOOLEAN COMMENT 'Indicates whether the adjuster is qualified and available for catastrophe event deployments.',
    `certification_designations` STRING COMMENT 'Professional certifications held by the adjuster such as AIC, CPCU, SCLA, or other industry designations.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this adjuster record was first created in the system.',
    `current_caseload_count` BIGINT COMMENT 'Number of open claims currently assigned to the adjuster.',
    `effective_date` DATE COMMENT 'Date this adjuster record became effective for claim assignments.',
    `expiration_date` DATE COMMENT 'Date this adjuster record expires or was superseded. Null if currently active.',
    `field_adjuster_flag` BOOLEAN COMMENT 'Indicates whether the adjuster conducts on-site field inspections versus desk-only adjusting.',
    `hire_date` DATE COMMENT 'Date the adjuster was hired or contracted by the insurer or TPA.',
    `home_office_location` STRING COMMENT 'Primary office or geographic location where the adjuster is based.',
    `language_skills` STRING COMMENT 'Comma-separated list of languages the adjuster is fluent in for claimant communication.',
    `last_performance_review_date` DATE COMMENT 'Date of the most recent formal performance review.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this adjuster record was most recently modified.',
    `max_caseload_capacity` BIGINT COMMENT 'Maximum number of concurrent claims the adjuster can handle based on workload management policies.',
    `max_claim_authority` DECIMAL(15,2) COMMENT 'Maximum dollar amount the adjuster is authorized to settle without supervisory approval.',
    `multi_state_licensed_flag` BOOLEAN COMMENT 'Indicates whether the adjuster holds licenses in multiple states.',
    `notes` STRING COMMENT 'Free-text notes capturing additional information about the adjusters skills, restrictions, or special circumstances.',
    `npn` STRING COMMENT 'National Producer Number assigned by NIPR if the adjuster also holds producer licensing.',
    `number` STRING COMMENT 'Business identifier assigned to the adjuster by the insurer or TPA.',
    `performance_rating` STRING COMMENT 'Most recent performance evaluation rating for the adjuster.. Valid values are `excellent|good|satisfactory|needs_improvement|unsatisfactory`',
    `service_territory` STRING COMMENT 'Geographic territory or region the adjuster is assigned to cover for claim investigations.',
    `specialty_lines` STRING COMMENT 'Comma-separated list of insurance lines the adjuster specializes in handling, such as property, auto, liability, workers compensation.',
    `termination_date` DATE COMMENT 'Date the adjusters employment or contract ended. Null if currently active.',
    `vendor_company_name` STRING COMMENT 'Name of the independent adjusting firm or TPA if the adjuster is not a staff employee.',
    `vendor_contract_number` STRING COMMENT 'Contract identifier for independent or TPA adjusters linking to the vendor agreement.',
    `years_experience` BIGINT COMMENT 'Total years of claims adjusting experience across all employers.',
    CONSTRAINT pk_adjuster PRIMARY KEY(`adjuster_id`)
) COMMENT 'Staff or independent adjuster assigned to handle claims. Captures adjuster type (staff/IA/TPA), license number, state appointments, assignment capacity, and links to Party domain for identity.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` (
    `adjuster_assignment_id` BIGINT COMMENT 'Unique identifier for the adjuster assignment record. Primary key.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Cat deployment planning tracks adjuster assignments by cat zone to manage capacity, SLA compliance, and surge staffing during catastrophe events.',
    `catastrophe_event_id` BIGINT COMMENT 'The catastrophe event this assignment is associated with, if applicable. Null for non-catastrophe claims.',
    `claim_exposure_id` BIGINT COMMENT 'The specific claim exposure (coverage line) to which the adjuster is assigned. Nullable if assignment is at claim level.',
    `claim_id` BIGINT COMMENT 'The claim to which the adjuster is assigned.',
    `primary_adjuster_id` BIGINT COMMENT 'The adjuster assigned to handle the claim or exposure.',
    `assigned_by_user_code` STRING COMMENT 'The system user or supervisor who made the assignment. Null for automatic assignments.',
    `assignment_authority_level` STRING COMMENT 'The level of authority the adjuster has in this assignment: full settlement authority, limited, or advisory only.. Valid values are `full|limited|review_only|advisory`',
    `assignment_date` DATE COMMENT 'The date the adjuster was assigned to the claim or exposure.',
    `assignment_method` STRING COMMENT 'The method used to assign the adjuster: automatic routing, manual selection, or rule-based assignment.. Valid values are `automatic|manual|round_robin|skill_based|geographic|workload_balanced`',
    `assignment_notes` STRING COMMENT 'Free-text notes or instructions provided at the time of assignment, such as special handling requirements or context.',
    `assignment_number` STRING COMMENT 'Business identifier for the assignment, often used in workflow systems and correspondence.',
    `assignment_role` STRING COMMENT 'The role the adjuster plays in this assignment: primary handler, supervisor, specialist, or support. [ENUM-REF-CANDIDATE: primary|secondary|supervisor|desk|field|independent|catastrophe|specialist — 8 candidates stripped; promote to reference product]',
    `assignment_source_system` STRING COMMENT 'The system that originated this assignment record: ClaimCenter, legacy system, or external vendor platform.',
    `assignment_source_system_code` STRING COMMENT 'The unique identifier for this assignment in the source system, used for reconciliation and traceability.',
    `assignment_status` STRING COMMENT 'Current lifecycle status of the adjuster assignment. [ENUM-REF-CANDIDATE: assigned|active|suspended|completed|closed|reassigned|withdrawn — 7 candidates stripped; promote to reference product]',
    `assignment_timestamp` TIMESTAMP COMMENT 'The precise date and time the assignment was created in the system.',
    `assignment_type` STRING COMMENT 'The nature of the assignment: initial assignment, reassignment, escalation, or specialist referral.. Valid values are `initial|reassignment|escalation|catastrophe|specialist_referral|peer_review`',
    `completion_date` DATE COMMENT 'The date the adjuster completed their work on the assignment.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time this assignment record was first created in the data warehouse.',
    `effective_date` DATE COMMENT 'The date from which the adjuster assignment becomes active and the adjuster assumes responsibility.',
    `expected_completion_date` DATE COMMENT 'The target date by which the adjuster is expected to complete their work on this assignment.',
    `expiration_date` DATE COMMENT 'The date the assignment ends or is superseded. Null for open assignments.',
    `geographic_territory` STRING COMMENT 'The geographic territory or region this assignment covers, relevant for field adjusters.',
    `is_active` BOOLEAN COMMENT 'Indicates whether this assignment is currently active. False for completed, closed, or superseded assignments.',
    `is_primary_adjuster` BOOLEAN COMMENT 'Indicates whether this adjuster is the primary handler for the claim or exposure. True for primary, false for secondary or support roles.',
    `is_supervisor_assignment` BOOLEAN COMMENT 'Indicates whether this is a supervisory assignment for oversight and quality review rather than primary handling.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The date and time this assignment record was last updated in the data warehouse.',
    `priority_level` STRING COMMENT 'The priority assigned to this claim assignment, influencing adjuster workflow and response time.. Valid values are `low|normal|high|urgent|catastrophe`',
    `reassignment_reason_code` STRING COMMENT 'Standardized code indicating why the claim was reassigned from a previous adjuster.',
    `reassignment_reason_description` STRING COMMENT 'Detailed explanation of why the assignment was transferred to this adjuster.',
    `reserve_authority_limit` DECIMAL(15,2) COMMENT 'The maximum reserve amount the adjuster can set without supervisor approval for this assignment.',
    `service_level_agreement_days` BIGINT COMMENT 'The number of days within which the adjuster must take initial action or complete key milestones per service level agreement.',
    `settlement_authority_limit` DECIMAL(15,2) COMMENT 'The maximum settlement amount the adjuster can approve without escalation for this assignment.',
    `specialty_line` STRING COMMENT 'The line of business specialty for which the adjuster was assigned: property, auto, liability, workers compensation, etc.',
    `workload_at_assignment` BIGINT COMMENT 'The number of open claims the adjuster had at the time of this assignment, used for workload balancing analysis.',
    CONSTRAINT pk_adjuster_assignment PRIMARY KEY(`adjuster_assignment_id`)
) COMMENT 'Assignment of an adjuster to a claim or claim exposure. Grain: one row per assignment. Tracks assignment date, reassignment reason, workload at assignment, and primary vs supervisory role. FK to adjuster and claim.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` (
    `fnol_id` BIGINT COMMENT 'Unique identifier for the FNOL submission record.',
    `assigned_adjuster_id` BIGINT COMMENT 'Reference to the adjuster assigned to investigate the FNOL, if assigned during intake.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: FNOL triage uses cat zone to route incoming loss reports to cat-qualified adjusters and apply cat SLAs.',
    `catastrophe_event_id` BIGINT COMMENT 'Reference to the catastrophe event if the loss is CAT-related.',
    `claim_id` BIGINT COMMENT 'Reference to the formal claim record created from this FNOL, if opened.',
    `coverage_id` BIGINT COMMENT 'Reference to the specific coverage under which the loss is being reported, if known at FNOL time.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: estimated_loss_amount on FNOL is a monetary value used for initial reserve setting and large-loss triage.',
    `driver_id` BIGINT COMMENT 'Foreign key linking to riskexposure.driver. Business justification: Auto FNOL — identifying the driver at first notice is required for excluded-driver triage, coverage-in-doubt flagging, and SIU referral decisions.',
    `insured_risk_id` BIGINT COMMENT 'Reference to the insured risk (property, vehicle, driver) involved in the loss, if identified at FNOL time.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: FNOL triage, adjuster routing, and SLA assignment are driven by LOB. The existing lob plain-text column is a denormalization of the shared LOB entity.',
    `loss_event_id` BIGINT COMMENT 'Foreign key linking to claims.loss_event. Business justification: An FNOL submission may be matched to a master loss event record once the event is identified (e.g., a catastrophe or multi-claim occurrence).',
    `peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophegeography_peril. Business justification: Normalizes peril classification at first notice of loss, enabling peril-based triage routing, specialist adjuster assignment, and cat flag determination.',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which the loss is being reported.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key linking to producers.producers_producer. Business justification: Captures which producer reported the loss when reporter_party_role indicates producer involvement.',
    `reporter_party_id` BIGINT COMMENT 'Reference to the party who reported the loss (policyholder, agent, claimant, or third party).',
    `reporter_party_role_id` BIGINT COMMENT 'Reference to the specific role the reporter was acting in at the time of report (policyholder, named insured, agent, claimant).',
    `vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.vehicle. Business justification: Auto FNOL triage — rental car initiation, total-loss pre-screening, and glass/roadside dispatch at first notice require the specific vehicle (VIN, make/model, ACV).',
    `cat_event_flag` BOOLEAN COMMENT 'Indicates whether the loss is associated with a declared catastrophe event.',
    `claim_opened_flag` BOOLEAN COMMENT 'Indicates whether a formal claim record has been created from this FNOL submission.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the FNOL record was first created in the claims management system.',
    `estimated_loss_amount` DECIMAL(18,2) COMMENT 'Initial estimate of the loss amount provided by the reporter at the time of FNOL.',
    `fatality_flag` BOOLEAN COMMENT 'Indicates whether a fatality occurred as part of the loss event.',
    `fnol_status` STRING COMMENT 'Current status of the FNOL submission in the intake and triage workflow.. Valid values are `submitted|under_review|claim_opened|rejected|duplicate|withdrawn`',
    `fraud_indicator_flag` BOOLEAN COMMENT 'Indicates whether the FNOL has been flagged for potential fraud based on initial screening rules.',
    `injury_flag` BOOLEAN COMMENT 'Indicates whether bodily injury was reported as part of the loss.',
    `iso_cat_serial_number` STRING COMMENT 'ISO-assigned catastrophe serial number for industry-wide catastrophe event tracking.',
    `loss_cause` STRING COMMENT 'Preliminary cause or peril of the loss as reported (fire, theft, collision, wind, water, liability, etc.).',
    `loss_date` DATE COMMENT 'Date the loss or incident occurred as reported by the reporter.',
    `loss_description` STRING COMMENT 'Initial narrative description of the loss event as provided by the reporter.',
    `loss_location_address` STRING COMMENT 'Street address where the loss occurred.',
    `loss_location_city` STRING COMMENT 'City where the loss occurred.',
    `loss_location_country` STRING COMMENT 'Country where the loss occurred, using 3-letter ISO country code.',
    `loss_location_postal_code` STRING COMMENT 'Postal or ZIP code of the loss location.',
    `loss_location_state` STRING COMMENT 'State or province where the loss occurred.',
    `loss_time` TIMESTAMP COMMENT 'Time of day the loss occurred, if known and reported.',
    `modified_timestamp` TIMESTAMP COMMENT 'System timestamp when the FNOL record was last updated.',
    `number` STRING COMMENT 'Business identifier for the FNOL submission, often displayed to users and external parties.',
    `police_department` STRING COMMENT 'Name of the police department or law enforcement agency that took the report.',
    `police_report_filed_flag` BOOLEAN COMMENT 'Indicates whether a police report was filed for the loss event.',
    `police_report_number` STRING COMMENT 'Police report or incident number, if a report was filed.',
    `property_damage_flag` BOOLEAN COMMENT 'Indicates whether property damage was reported as part of the loss.',
    `rejection_reason` STRING COMMENT 'Reason the FNOL was rejected or not converted to a formal claim, if applicable.',
    `report_channel` STRING COMMENT 'Channel through which the loss was reported.. Valid values are `phone|web|mobile_app|email|agent|in_person`',
    `report_date` DATE COMMENT 'Date the loss was reported to the insurer.',
    `report_timestamp` TIMESTAMP COMMENT 'Precise date and time the FNOL was submitted or received by the system.',
    `reporter_contact_email` STRING COMMENT 'Email address of the reporter for follow-up communication.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `reporter_contact_phone` STRING COMMENT 'Phone number of the reporter for follow-up communication.',
    `siu_referral_flag` BOOLEAN COMMENT 'Indicates whether the FNOL has been referred to the Special Investigations Unit for fraud investigation.',
    `third_party_involved_flag` BOOLEAN COMMENT 'Indicates whether a third party (non-insured) is involved in the loss event.',
    `triage_priority` STRING COMMENT 'Priority level assigned to the FNOL for adjuster assignment and investigation, based on severity and complexity.. Valid values are `urgent|high|medium|low`',
    CONSTRAINT pk_fnol PRIMARY KEY(`fnol_id`)
) COMMENT 'First Notice of Loss intake record. Grain: one row per FNOL submission. Captures report channel, reporter party, initial loss description, date/time of loss, and triage flags before a formal claim is opened.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` (
    `litigation_id` BIGINT COMMENT 'Unique identifier for the litigation record. Primary key.',
    `assigned_adjuster_id` BIGINT COMMENT 'Identifier of the adjuster assigned to manage this litigation.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Cat-related litigation (bad faith, coverage disputes post-hurricane/flood) must be tracked against the triggering catastrophe event for reinsurance bad faith cost',
    `claim_exposure_id` BIGINT COMMENT 'Foreign key linking to claims.claim_exposure. Business justification: Litigation is frequently tied to a specific coverage line (claim exposure) rather than the entire claim — e.g., a bodily injury lawsuit targets the BI coverage exposure specifically.',
    `claim_id` BIGINT COMMENT 'Foreign key to the claim that this litigation is attached to.',
    `claimant_id` BIGINT COMMENT 'Foreign key linking to claims.claimant. Business justification: A lawsuit is filed by a specific claimant party. Linking litigation directly to the claimant record (beyond the claim-level link) enables precise tracking of which claimant is the plaintiff',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Litigation defense strategy, reserve authority, and settlement negotiations require direct reference to the specific coverage part in dispute.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: litigation carries defense_cost_incurred, demand_amount, reserve_amount, settlement_amount, and verdict_amount — all monetary.',
    `defense_counsel_party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Defense attorneys are parties requiring tracking for legal billing, conflict checks, panel counsel management, and regulatory reporting.',
    `appeal_date` DATE COMMENT 'Date the appeal was filed.',
    `appeal_filed_flag` BOOLEAN COMMENT 'Indicates whether an appeal has been filed following the verdict.',
    `cause_of_action` STRING COMMENT 'Legal basis or grounds for the lawsuit, such as negligence, breach of contract, or bad faith.',
    `closure_date` DATE COMMENT 'Date the litigation was formally closed in the claims system.',
    `confidentiality_flag` BOOLEAN COMMENT 'Indicates whether the litigation settlement or details are subject to a confidentiality agreement.',
    `court_jurisdiction` STRING COMMENT 'Name of the court or jurisdiction where the lawsuit is filed, including district or county.',
    `court_type` STRING COMMENT 'Type or level of court handling the litigation.. Valid values are `federal|state|county|municipal|appellate|supreme`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the litigation record was first created in the system.',
    `defense_cost_incurred` DECIMAL(18,2) COMMENT 'Total defense and cost containment expenses incurred for this litigation.',
    `demand_amount` DECIMAL(18,2) COMMENT 'Monetary amount demanded by the plaintiff in the lawsuit.',
    `dismissal_date` DATE COMMENT 'Date the lawsuit was dismissed by the court.',
    `dismissal_reason` STRING COMMENT 'Reason provided for the dismissal of the lawsuit, such as lack of jurisdiction or settlement.',
    `filing_date` DATE COMMENT 'Date the lawsuit was filed with the court.',
    `lawsuit_number` STRING COMMENT 'Court-assigned case number or docket number for the lawsuit.',
    `litigation_status` STRING COMMENT 'Current status of the litigation in its lifecycle. [ENUM-REF-CANDIDATE: filed|discovery|mediation|trial|settled|dismissed|verdict_rendered|appeal|closed — 9 candidates stripped; promote to reference product]',
    `litigation_type` STRING COMMENT 'Classification of the litigation based on the nature of the dispute.. Valid values are `first_party|third_party|subrogation|bad_faith|coverage_dispute|declaratory_judgment`',
    `mediation_date` DATE COMMENT 'Date of scheduled or completed mediation session.',
    `notes` STRING COMMENT 'Free-text notes capturing key details, strategy, or updates related to the litigation.',
    `plaintiff_attorney_firm` STRING COMMENT 'Law firm name representing the plaintiff.',
    `plaintiff_attorney_name` STRING COMMENT 'Name of the attorney or law firm representing the plaintiff.',
    `plaintiff_attorney_phone` STRING COMMENT 'Contact phone number for the plaintiff attorney.',
    `plaintiff_name` STRING COMMENT 'Name of the plaintiff or claimant who filed the lawsuit.',
    `reserve_amount` DECIMAL(18,2) COMMENT 'Total reserve amount set aside for this litigation, including indemnity and defense costs.',
    `settlement_amount` DECIMAL(18,2) COMMENT 'Total monetary amount agreed upon in the settlement.',
    `settlement_date` DATE COMMENT 'Date the litigation was settled, if applicable.',
    `trial_date` DATE COMMENT 'Scheduled date for the trial or hearing.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the litigation record was last updated.',
    `venue_county` STRING COMMENT 'County where the lawsuit is being heard.',
    `venue_state` STRING COMMENT 'State where the lawsuit is being heard.',
    `verdict_amount` DECIMAL(18,2) COMMENT 'Monetary award determined by the court or jury in the verdict.',
    `verdict_date` DATE COMMENT 'Date the court or jury rendered a verdict.',
    `verdict_type` STRING COMMENT 'Outcome of the verdict indicating which party prevailed.. Valid values are `plaintiff|defendant|split|hung_jury`',
    CONSTRAINT pk_litigation PRIMARY KEY(`litigation_id`)
) COMMENT 'Litigation record attached to a claim. Tracks lawsuit filing date, plaintiff attorney, defense counsel, court jurisdiction, trial date, verdict, and settlement amount. One row per lawsuit per claim.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_loss_event_id` FOREIGN KEY (`loss_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`loss_event`(`loss_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ADD CONSTRAINT `fk_claims_claimant_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_adjuster_id` FOREIGN KEY (`adjuster_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_claimant_id` FOREIGN KEY (`claimant_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claimant`(`claimant_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ADD CONSTRAINT `fk_claims_claim_status_adjuster_id` FOREIGN KEY (`adjuster_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ADD CONSTRAINT `fk_claims_claim_status_primary_status_claim_id` FOREIGN KEY (`primary_status_claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ADD CONSTRAINT `fk_claims_adjuster_supervisor_adjuster_id` FOREIGN KEY (`supervisor_adjuster_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ADD CONSTRAINT `fk_claims_adjuster_assignment_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ADD CONSTRAINT `fk_claims_adjuster_assignment_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ADD CONSTRAINT `fk_claims_adjuster_assignment_primary_adjuster_id` FOREIGN KEY (`primary_adjuster_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_assigned_adjuster_id` FOREIGN KEY (`assigned_adjuster_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_loss_event_id` FOREIGN KEY (`loss_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`loss_event`(`loss_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ADD CONSTRAINT `fk_claims_litigation_assigned_adjuster_id` FOREIGN KEY (`assigned_adjuster_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ADD CONSTRAINT `fk_claims_litigation_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ADD CONSTRAINT `fk_claims_litigation_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ADD CONSTRAINT `fk_claims_litigation_claimant_id` FOREIGN KEY (`claimant_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claimant`(`claimant_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`claims` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`claims` SET TAGS ('dbx_domain' = 'claims');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` SET TAGS ('dbx_subdomain' = 'loss_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_event_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Event Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `peril_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophegeography Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `cat_serial_number` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Serial Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `closed_date` SET TAGS ('dbx_business_glossary_term' = 'Closed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `estimated_total_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Estimated Total Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `fatality_occurred` SET TAGS ('dbx_business_glossary_term' = 'Fatality Occurred Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `fire_department_notified` SET TAGS ('dbx_business_glossary_term' = 'Fire Department Notified Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `fire_report_number` SET TAGS ('dbx_business_glossary_term' = 'Fire Report Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `fraud_indicator` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `injury_occurred` SET TAGS ('dbx_business_glossary_term' = 'Injury Occurred Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `is_catastrophe_loss` SET TAGS ('dbx_business_glossary_term' = 'Is Catastrophe (CAT) Loss Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `is_large_loss` SET TAGS ('dbx_business_glossary_term' = 'Is Large Loss Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `large_loss_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Large Loss Threshold Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_complexity_code` SET TAGS ('dbx_business_glossary_term' = 'Loss Complexity Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_complexity_code` SET TAGS ('dbx_value_regex' = 'simple|moderate|complex|highly_complex');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_description` SET TAGS ('dbx_business_glossary_term' = 'Loss Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_discovery_date` SET TAGS ('dbx_business_glossary_term' = 'Loss Discovery Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_event_status` SET TAGS ('dbx_business_glossary_term' = 'Loss Event Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_event_status` SET TAGS ('dbx_value_regex' = 'open|closed|under_investigation|pending_review|resolved');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_event_type` SET TAGS ('dbx_business_glossary_term' = 'Loss Event Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_address` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_city` SET TAGS ('dbx_business_glossary_term' = 'Loss Location City');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_city` SET TAGS ('dbx_pii_category' = 'address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_country` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Country');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_country` SET TAGS ('dbx_value_regex' = 'USA|CAN|MEX');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_country` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_latitude` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Latitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_longitude` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Longitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Postal Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_state` SET TAGS ('dbx_business_glossary_term' = 'Loss Location State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_location_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_occurrence_date` SET TAGS ('dbx_business_glossary_term' = 'Loss Occurrence Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_occurrence_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Loss Occurrence Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_reported_date` SET TAGS ('dbx_business_glossary_term' = 'Loss Reported Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_severity_code` SET TAGS ('dbx_business_glossary_term' = 'Loss Severity Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `loss_severity_code` SET TAGS ('dbx_value_regex' = 'minor|moderate|major|total_loss|catastrophic');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Loss Event Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `number_of_fatalities` SET TAGS ('dbx_business_glossary_term' = 'Number of Fatalities');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `number_of_injuries` SET TAGS ('dbx_business_glossary_term' = 'Number of Injuries');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `police_report_filed` SET TAGS ('dbx_business_glossary_term' = 'Police Report Filed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `police_report_number` SET TAGS ('dbx_business_glossary_term' = 'Police Report Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `reopened_date` SET TAGS ('dbx_business_glossary_term' = 'Reopened Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `salvage_potential` SET TAGS ('dbx_business_glossary_term' = 'Salvage Potential Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `siu_referral_date` SET TAGS ('dbx_business_glossary_term' = 'Special Investigation Unit (SIU) Referral Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `subrogation_potential` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Potential Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `third_party_involved` SET TAGS ('dbx_business_glossary_term' = 'Third Party Involved Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ALTER COLUMN `weather_condition` SET TAGS ('dbx_business_glossary_term' = 'Weather Condition');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` SET TAGS ('dbx_subdomain' = 'loss_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `claim_adjuster_party_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Party Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Risk Score Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `location_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Order Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `loss_event_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Event Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `peril_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophegeography Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `primary_claimant_party_id` SET TAGS ('dbx_business_glossary_term' = 'Claimant Party Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `risk_score_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Score Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `uw_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Uw Decision Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `adjuster_type` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `adjuster_type` SET TAGS ('dbx_value_regex' = 'staff|independent|public');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `catastrophe_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `claim_status` SET TAGS ('dbx_business_glossary_term' = 'Claim Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `claim_status` SET TAGS ('dbx_value_regex' = 'open|closed|reopened|pending|denied|withdrawn');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `claimant_type` SET TAGS ('dbx_business_glossary_term' = 'Claimant Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `claimant_type` SET TAGS ('dbx_value_regex' = 'first_party|third_party');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `close_date` SET TAGS ('dbx_business_glossary_term' = 'Claim Close Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `fnol_date` SET TAGS ('dbx_business_glossary_term' = 'First Notice of Loss (FNOL) Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `fnol_timestamp` SET TAGS ('dbx_business_glossary_term' = 'First Notice of Loss (FNOL) Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `iso_cat_serial_number` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Catastrophe (CAT) Serial Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `litigation_date` SET TAGS ('dbx_business_glossary_term' = 'Litigation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `litigation_flag` SET TAGS ('dbx_business_glossary_term' = 'Litigation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `loss_date` SET TAGS ('dbx_business_glossary_term' = 'Loss Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `loss_description` SET TAGS ('dbx_business_glossary_term' = 'Loss Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `loss_location_address` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `loss_location_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `loss_location_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `loss_location_city` SET TAGS ('dbx_business_glossary_term' = 'Loss Location City');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `loss_location_city` SET TAGS ('dbx_pii_category' = 'address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `loss_location_country` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Country');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `loss_location_country` SET TAGS ('dbx_value_regex' = 'USA|CAN|MEX');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `loss_location_country` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `loss_location_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Postal Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `loss_location_postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `loss_location_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `loss_location_state` SET TAGS ('dbx_business_glossary_term' = 'Loss Location State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `loss_location_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `loss_time` SET TAGS ('dbx_business_glossary_term' = 'Loss Time');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Claim Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `reinsurance_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `reopen_date` SET TAGS ('dbx_business_glossary_term' = 'Claim Reopen Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `report_date` SET TAGS ('dbx_business_glossary_term' = 'Report Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `report_year` SET TAGS ('dbx_business_glossary_term' = 'Report Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `salvage_flag` SET TAGS ('dbx_business_glossary_term' = 'Salvage Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `siu_flag` SET TAGS ('dbx_business_glossary_term' = 'Special Investigations Unit (SIU) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `siu_referral_date` SET TAGS ('dbx_business_glossary_term' = 'Special Investigations Unit (SIU) Referral Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `status_reason` SET TAGS ('dbx_business_glossary_term' = 'Claim Status Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `subrogation_flag` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` SET TAGS ('dbx_subdomain' = 'loss_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `claimant_id` SET TAGS ('dbx_business_glossary_term' = 'Claimant Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `mailing_address_id` SET TAGS ('dbx_business_glossary_term' = 'Mailing Address Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `mailing_address_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `mailing_address_id` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `attorney_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Attorney Contact Email');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `attorney_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `attorney_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `attorney_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `attorney_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Attorney Contact Phone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `attorney_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `attorney_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `attorney_name` SET TAGS ('dbx_business_glossary_term' = 'Attorney Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `attorney_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `attorney_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `claimant_status` SET TAGS ('dbx_business_glossary_term' = 'Claimant Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `claimant_status` SET TAGS ('dbx_value_regex' = 'active|closed|withdrawn|settled|denied|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `claimant_type` SET TAGS ('dbx_business_glossary_term' = 'Claimant Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `claimant_type` SET TAGS ('dbx_value_regex' = 'first_party|third_party|additional_insured|named_insured|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `contact_preference` SET TAGS ('dbx_business_glossary_term' = 'Contact Preference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `contact_preference` SET TAGS ('dbx_value_regex' = 'email|phone|mail|sms|portal');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `date_of_death` SET TAGS ('dbx_business_glossary_term' = 'Date of Death');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `date_of_death` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `date_of_death` SET TAGS ('dbx_pii_health' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `date_of_injury` SET TAGS ('dbx_business_glossary_term' = 'Date of Injury');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `fault_indicator` SET TAGS ('dbx_business_glossary_term' = 'Fault Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `fraud_indicator_flag` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `guardian_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Guardian Contact Phone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `guardian_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `guardian_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `guardian_name` SET TAGS ('dbx_business_glossary_term' = 'Guardian Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `guardian_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `guardian_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `hospital_name` SET TAGS ('dbx_business_glossary_term' = 'Hospital Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `hospital_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `hospital_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `hospitalization_flag` SET TAGS ('dbx_business_glossary_term' = 'Hospitalization Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `injury_description` SET TAGS ('dbx_business_glossary_term' = 'Injury Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `injury_description` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `injury_severity_code` SET TAGS ('dbx_business_glossary_term' = 'Injury Severity Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `injury_severity_code` SET TAGS ('dbx_value_regex' = 'minor|moderate|major|catastrophic|fatal');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `injury_type` SET TAGS ('dbx_business_glossary_term' = 'Injury Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `injury_type` SET TAGS ('dbx_value_regex' = 'bodily_injury|property_damage|both|none');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `liability_percentage` SET TAGS ('dbx_business_glossary_term' = 'Liability Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `medical_treatment_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Medical Treatment Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `medical_treatment_required_flag` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `medical_treatment_required_flag` SET TAGS ('dbx_pii_health' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `minor_flag` SET TAGS ('dbx_business_glossary_term' = 'Minor Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Claimant Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Claimant Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Email');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Phone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `relationship_to_insured` SET TAGS ('dbx_business_glossary_term' = 'Relationship to Insured');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `release_signed_date` SET TAGS ('dbx_business_glossary_term' = 'Release Signed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `release_signed_flag` SET TAGS ('dbx_business_glossary_term' = 'Release Signed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `represented_by_attorney_flag` SET TAGS ('dbx_business_glossary_term' = 'Represented by Attorney Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `settlement_demand_amount` SET TAGS ('dbx_business_glossary_term' = 'Settlement Demand Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `settlement_demand_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `settlement_offer_amount` SET TAGS ('dbx_business_glossary_term' = 'Settlement Offer Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `settlement_offer_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `siu_referral_date` SET TAGS ('dbx_business_glossary_term' = 'Special Investigation Unit (SIU) Referral Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `siu_referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Special Investigation Unit (SIU) Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `subrogation_potential_flag` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Potential Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `treating_physician_name` SET TAGS ('dbx_business_glossary_term' = 'Treating Physician Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `treating_physician_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ALTER COLUMN `treating_physician_name` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` SET TAGS ('dbx_subdomain' = 'loss_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `building_id` SET TAGS ('dbx_business_glossary_term' = 'Building Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `claimant_id` SET TAGS ('dbx_business_glossary_term' = 'Claimant Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `driver_id` SET TAGS ('dbx_business_glossary_term' = 'Driver Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `catastrophe_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `claim_party_role` SET TAGS ('dbx_business_glossary_term' = 'Claim Party Role');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `claim_party_role` SET TAGS ('dbx_value_regex' = 'first_party|third_party');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `closed_date` SET TAGS ('dbx_business_glossary_term' = 'Closed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `coverage_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Coverage Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `coverage_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `denial_reason` SET TAGS ('dbx_business_glossary_term' = 'Denial Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `exposure_description` SET TAGS ('dbx_business_glossary_term' = 'Exposure Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `exposure_number` SET TAGS ('dbx_business_glossary_term' = 'Exposure Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `exposure_status` SET TAGS ('dbx_business_glossary_term' = 'Exposure Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `exposure_status` SET TAGS ('dbx_value_regex' = 'open|closed|reopened|denied|pending|settled');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `fraud_flag` SET TAGS ('dbx_business_glossary_term' = 'Fraud Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `incurred_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `lae_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Loss Adjustment Expense (LAE) Paid Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `lae_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Loss Adjustment Expense (LAE) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `liability_indicator` SET TAGS ('dbx_business_glossary_term' = 'Liability Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `litigation_flag` SET TAGS ('dbx_business_glossary_term' = 'Litigation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `loss_cause` SET TAGS ('dbx_business_glossary_term' = 'Loss Cause');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `loss_date` SET TAGS ('dbx_business_glossary_term' = 'Loss Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `outstanding_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `recovery_amount` SET TAGS ('dbx_business_glossary_term' = 'Recovery Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `reinsurance_ceded_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Ceded Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `reopened_date` SET TAGS ('dbx_business_glossary_term' = 'Reopened Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `report_year` SET TAGS ('dbx_business_glossary_term' = 'Report Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `reported_date` SET TAGS ('dbx_business_glossary_term' = 'Reported Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `salvage_potential_flag` SET TAGS ('dbx_business_glossary_term' = 'Salvage Potential Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `settlement_type` SET TAGS ('dbx_business_glossary_term' = 'Settlement Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `settlement_type` SET TAGS ('dbx_value_regex' = 'full_payment|partial_payment|denied|withdrawn|structured_settlement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `siu_referral_date` SET TAGS ('dbx_business_glossary_term' = 'Special Investigation Unit (SIU) Referral Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `subrogation_potential_flag` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Potential Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` SET TAGS ('dbx_subdomain' = 'loss_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `claim_status_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Status ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `primary_status_claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Approved By User ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `approved_by_user_name` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `approved_by_user_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `approved_by_user_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `cat_serial_number` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Serial Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `catastrophe_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `closure_type_code` SET TAGS ('dbx_business_glossary_term' = 'Closure Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `closure_type_code` SET TAGS ('dbx_value_regex' = 'PAID|DENIED|WITHDRAWN|SETTLED|LITIGATED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `effective_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Effective Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `expiration_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Expiration Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `fraud_investigation_flag` SET TAGS ('dbx_business_glossary_term' = 'Fraud Investigation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `incurred_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `is_current_status` SET TAGS ('dbx_business_glossary_term' = 'Is Current Status Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `litigation_flag` SET TAGS ('dbx_business_glossary_term' = 'Litigation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `litigation_start_date` SET TAGS ('dbx_business_glossary_term' = 'Litigation Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `previous_status_code` SET TAGS ('dbx_business_glossary_term' = 'Previous Status Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `previous_status_code` SET TAGS ('dbx_value_regex' = 'OPEN|PENDING|CLOSED|REOPENED|DENIED|LITIGATED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `reopen_count` SET TAGS ('dbx_business_glossary_term' = 'Reopen Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `siu_referral_date` SET TAGS ('dbx_business_glossary_term' = 'Special Investigations Unit (SIU) Referral Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `status_code` SET TAGS ('dbx_business_glossary_term' = 'Status Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `status_code` SET TAGS ('dbx_value_regex' = 'OPEN|PENDING|CLOSED|REOPENED|DENIED|LITIGATED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `status_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Status Duration Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `status_notes` SET TAGS ('dbx_business_glossary_term' = 'Status Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `status_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Status Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `status_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Status Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `status_set_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Status Set By User ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `status_set_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `status_set_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `status_set_by_user_name` SET TAGS ('dbx_business_glossary_term' = 'Status Set By User Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `status_set_by_user_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `status_set_by_user_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `subrogation_flag` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `system_source_code` SET TAGS ('dbx_business_glossary_term' = 'System Source Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `workflow_step_code` SET TAGS ('dbx_business_glossary_term' = 'Workflow Step Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `workflow_step_name` SET TAGS ('dbx_business_glossary_term' = 'Workflow Step Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ALTER COLUMN `workflow_step_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` SET TAGS ('dbx_subdomain' = 'adjuster_operations');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `license_id` SET TAGS ('dbx_business_glossary_term' = 'License Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `supervisor_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Supervisor Adjuster Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `adjuster_status` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `adjuster_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|terminated|on_leave');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `adjuster_type` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `adjuster_type` SET TAGS ('dbx_value_regex' = 'staff|independent|tpa|catastrophe|public');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `background_check_date` SET TAGS ('dbx_business_glossary_term' = 'Background Check Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `background_check_date` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `background_check_status` SET TAGS ('dbx_business_glossary_term' = 'Background Check Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `background_check_status` SET TAGS ('dbx_value_regex' = 'passed|failed|pending|expired');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `background_check_status` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `catastrophe_qualified_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Qualified Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `certification_designations` SET TAGS ('dbx_business_glossary_term' = 'Professional Certification Designations');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `current_caseload_count` SET TAGS ('dbx_business_glossary_term' = 'Current Caseload Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `field_adjuster_flag` SET TAGS ('dbx_business_glossary_term' = 'Field Adjuster Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `hire_date` SET TAGS ('dbx_business_glossary_term' = 'Hire Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `home_office_location` SET TAGS ('dbx_business_glossary_term' = 'Home Office Location');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `language_skills` SET TAGS ('dbx_business_glossary_term' = 'Language Skills');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `last_performance_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Performance Review Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `max_caseload_capacity` SET TAGS ('dbx_business_glossary_term' = 'Maximum Caseload Capacity');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `max_claim_authority` SET TAGS ('dbx_business_glossary_term' = 'Maximum Claim Authority Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `max_claim_authority` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `multi_state_licensed_flag` SET TAGS ('dbx_business_glossary_term' = 'Multi-State Licensed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `multi_state_licensed_flag` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `npn` SET TAGS ('dbx_business_glossary_term' = 'National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `npn` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `performance_rating` SET TAGS ('dbx_business_glossary_term' = 'Performance Rating');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `performance_rating` SET TAGS ('dbx_value_regex' = 'excellent|good|satisfactory|needs_improvement|unsatisfactory');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `performance_rating` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `service_territory` SET TAGS ('dbx_business_glossary_term' = 'Service Territory');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `specialty_lines` SET TAGS ('dbx_business_glossary_term' = 'Specialty Lines of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `vendor_company_name` SET TAGS ('dbx_business_glossary_term' = 'Vendor Company Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `vendor_company_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `vendor_contract_number` SET TAGS ('dbx_business_glossary_term' = 'Vendor Contract Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ALTER COLUMN `years_experience` SET TAGS ('dbx_business_glossary_term' = 'Years of Experience');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` SET TAGS ('dbx_subdomain' = 'adjuster_operations');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `adjuster_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Assignment Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `primary_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assigned_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Assigned By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assigned_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assigned_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_authority_level` SET TAGS ('dbx_business_glossary_term' = 'Assignment Authority Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_authority_level` SET TAGS ('dbx_value_regex' = 'full|limited|review_only|advisory');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_method` SET TAGS ('dbx_business_glossary_term' = 'Assignment Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_method` SET TAGS ('dbx_value_regex' = 'automatic|manual|round_robin|skill_based|geographic|workload_balanced');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_notes` SET TAGS ('dbx_business_glossary_term' = 'Assignment Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_number` SET TAGS ('dbx_business_glossary_term' = 'Assignment Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_role` SET TAGS ('dbx_business_glossary_term' = 'Assignment Role');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_source_system` SET TAGS ('dbx_business_glossary_term' = 'Assignment Source System');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Assignment Source System Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Assignment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Assignment Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_business_glossary_term' = 'Assignment Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_value_regex' = 'initial|reassignment|escalation|catastrophe|specialist_referral|peer_review');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'Completion Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `expected_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Expected Completion Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `geographic_territory` SET TAGS ('dbx_business_glossary_term' = 'Geographic Territory');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `is_primary_adjuster` SET TAGS ('dbx_business_glossary_term' = 'Is Primary Adjuster Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `is_supervisor_assignment` SET TAGS ('dbx_business_glossary_term' = 'Is Supervisor Assignment Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Priority Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'low|normal|high|urgent|catastrophe');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `reassignment_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reassignment Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `reassignment_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Reassignment Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `reserve_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Reserve Authority Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `service_level_agreement_days` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `settlement_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Settlement Authority Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `specialty_line` SET TAGS ('dbx_business_glossary_term' = 'Specialty Line');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `workload_at_assignment` SET TAGS ('dbx_business_glossary_term' = 'Workload at Assignment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` SET TAGS ('dbx_subdomain' = 'loss_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `fnol_id` SET TAGS ('dbx_business_glossary_term' = 'First Notice of Loss (FNOL) ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `assigned_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Adjuster ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `driver_id` SET TAGS ('dbx_business_glossary_term' = 'Driver Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `loss_event_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `peril_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophegeography Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Reporter Producer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `reporter_party_id` SET TAGS ('dbx_business_glossary_term' = 'Reporter Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `reporter_party_role_id` SET TAGS ('dbx_business_glossary_term' = 'Reporter Party Role ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `cat_event_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `claim_opened_flag` SET TAGS ('dbx_business_glossary_term' = 'Claim Opened Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `estimated_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Estimated Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `fatality_flag` SET TAGS ('dbx_business_glossary_term' = 'Fatality Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `fnol_status` SET TAGS ('dbx_business_glossary_term' = 'First Notice of Loss (FNOL) Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `fnol_status` SET TAGS ('dbx_value_regex' = 'submitted|under_review|claim_opened|rejected|duplicate|withdrawn');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `fraud_indicator_flag` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `injury_flag` SET TAGS ('dbx_business_glossary_term' = 'Injury Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `iso_cat_serial_number` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Catastrophe (CAT) Serial Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `loss_cause` SET TAGS ('dbx_business_glossary_term' = 'Loss Cause');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `loss_date` SET TAGS ('dbx_business_glossary_term' = 'Loss Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `loss_description` SET TAGS ('dbx_business_glossary_term' = 'Loss Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_address` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_city` SET TAGS ('dbx_business_glossary_term' = 'Loss Location City');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_city` SET TAGS ('dbx_pii_category' = 'address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_country` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Country');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_country` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Postal Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_state` SET TAGS ('dbx_business_glossary_term' = 'Loss Location State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `loss_time` SET TAGS ('dbx_business_glossary_term' = 'Loss Time');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'First Notice of Loss (FNOL) Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `police_department` SET TAGS ('dbx_business_glossary_term' = 'Police Department');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `police_report_filed_flag` SET TAGS ('dbx_business_glossary_term' = 'Police Report Filed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `police_report_number` SET TAGS ('dbx_business_glossary_term' = 'Police Report Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `property_damage_flag` SET TAGS ('dbx_business_glossary_term' = 'Property Damage Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `report_channel` SET TAGS ('dbx_business_glossary_term' = 'Report Channel');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `report_channel` SET TAGS ('dbx_value_regex' = 'phone|web|mobile_app|email|agent|in_person');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `report_date` SET TAGS ('dbx_business_glossary_term' = 'Report Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `report_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Report Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `reporter_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Reporter Contact Email');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `reporter_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `reporter_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `reporter_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `reporter_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Reporter Contact Phone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `reporter_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `reporter_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `siu_referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Special Investigations Unit (SIU) Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `third_party_involved_flag` SET TAGS ('dbx_business_glossary_term' = 'Third Party Involved Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `triage_priority` SET TAGS ('dbx_business_glossary_term' = 'Triage Priority');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ALTER COLUMN `triage_priority` SET TAGS ('dbx_value_regex' = 'urgent|high|medium|low');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` SET TAGS ('dbx_subdomain' = 'adjuster_operations');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `litigation_id` SET TAGS ('dbx_business_glossary_term' = 'Litigation Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `assigned_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Adjuster Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `claimant_id` SET TAGS ('dbx_business_glossary_term' = 'Claimant Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `defense_counsel_party_id` SET TAGS ('dbx_business_glossary_term' = 'Defense Counsel Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `appeal_date` SET TAGS ('dbx_business_glossary_term' = 'Appeal Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `appeal_filed_flag` SET TAGS ('dbx_business_glossary_term' = 'Appeal Filed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `cause_of_action` SET TAGS ('dbx_business_glossary_term' = 'Cause of Action');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `closure_date` SET TAGS ('dbx_business_glossary_term' = 'Closure Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `confidentiality_flag` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `court_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Court Jurisdiction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `court_type` SET TAGS ('dbx_business_glossary_term' = 'Court Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `court_type` SET TAGS ('dbx_value_regex' = 'federal|state|county|municipal|appellate|supreme');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `defense_cost_incurred` SET TAGS ('dbx_business_glossary_term' = 'Defense Cost Incurred (DCC)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `defense_cost_incurred` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `demand_amount` SET TAGS ('dbx_business_glossary_term' = 'Demand Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `demand_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `dismissal_date` SET TAGS ('dbx_business_glossary_term' = 'Dismissal Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `dismissal_reason` SET TAGS ('dbx_business_glossary_term' = 'Dismissal Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `filing_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `lawsuit_number` SET TAGS ('dbx_business_glossary_term' = 'Lawsuit Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `litigation_status` SET TAGS ('dbx_business_glossary_term' = 'Litigation Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `litigation_type` SET TAGS ('dbx_business_glossary_term' = 'Litigation Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `litigation_type` SET TAGS ('dbx_value_regex' = 'first_party|third_party|subrogation|bad_faith|coverage_dispute|declaratory_judgment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `mediation_date` SET TAGS ('dbx_business_glossary_term' = 'Mediation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Litigation Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `plaintiff_attorney_firm` SET TAGS ('dbx_business_glossary_term' = 'Plaintiff Attorney Firm');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `plaintiff_attorney_name` SET TAGS ('dbx_business_glossary_term' = 'Plaintiff Attorney Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `plaintiff_attorney_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `plaintiff_attorney_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `plaintiff_attorney_phone` SET TAGS ('dbx_business_glossary_term' = 'Plaintiff Attorney Phone Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `plaintiff_attorney_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `plaintiff_attorney_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `plaintiff_name` SET TAGS ('dbx_business_glossary_term' = 'Plaintiff Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `plaintiff_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `plaintiff_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Settlement Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `settlement_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `trial_date` SET TAGS ('dbx_business_glossary_term' = 'Trial Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `venue_county` SET TAGS ('dbx_business_glossary_term' = 'Venue County');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `venue_county` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `venue_state` SET TAGS ('dbx_business_glossary_term' = 'Venue State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `venue_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `verdict_amount` SET TAGS ('dbx_business_glossary_term' = 'Verdict Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `verdict_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `verdict_date` SET TAGS ('dbx_business_glossary_term' = 'Verdict Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `verdict_type` SET TAGS ('dbx_business_glossary_term' = 'Verdict Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ALTER COLUMN `verdict_type` SET TAGS ('dbx_value_regex' = 'plaintiff|defendant|split|hung_jury');
