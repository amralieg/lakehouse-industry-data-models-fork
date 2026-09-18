-- Schema for Domain: claims | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-18 02:30:17

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_v499`.`claims` COMMENT 'Provisional description for user-specified domain claims. Awaiting a generated description of what this domain owns.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` (
    `fnol_id` BIGINT COMMENT 'Unique identifier for the first notice of loss record.',
    `assigned_adjuster_id` BIGINT COMMENT 'Identifier of the adjuster assigned to handle the claim from this FNOL.',
    `claim_id` BIGINT COMMENT 'Reference to the claim record created from this FNOL, if already established.',
    `claimant_id` BIGINT COMMENT 'Reference to the party record for the claimant reporting the loss.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: FNOL estimated_loss_amount requires currency reference for initial loss estimation in international claims.',
    `dol_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: FNOL date of loss determines accident year for initial triage, catastrophe event matching, and intake period analysis.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: FNOL intake for property losses must link to insured location for immediate coverage-in-force verification, CAT assignment, adjuster routing by geography, and loss location',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: FNOL for auto losses must link to the vehicle for immediate VIN validation, coverage-in-force verification, and proper claim setup.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: FNOL LOB determines initial triage, adjuster assignment based on specialization, and handling protocol selection.',
    `loss_location_country_id` BIGINT COMMENT 'Foreign key linking to shared.country. Business justification: FNOL loss location country determines international jurisdiction for initial claim handling, language requirements, and catastrophe exposure identification.',
    `loss_location_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: FNOL loss location state determines initial jurisdiction for adjuster assignment, state-specific handling requirements, and catastrophe exposure zone identification.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: FNOL intake captures which coverage is potentially triggered at first notice.',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which the loss is being reported.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key linking to producers.producers_producer. Business justification: FNOL intake captures the producer/agent who reported the loss. Essential for producer performance tracking, fraud pattern detection (staged losses), and regulatory reporting.',
    `cat_code` STRING COMMENT 'Catastrophe event code if the loss is associated with a declared catastrophe.',
    `claimant_email` STRING COMMENT 'Email address for the claimant.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `claimant_phone` STRING COMMENT 'Primary contact phone number for the claimant.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the FNOL record was first created in the system.',
    `dol` DATE COMMENT 'Date when the loss event occurred.',
    `dol_timestamp` TIMESTAMP COMMENT 'Precise date and time when the loss event occurred, if known.',
    `estimated_loss_amount` DECIMAL(15,2) COMMENT 'Initial estimate of the loss amount as reported at FNOL.',
    `fnol_status` STRING COMMENT 'Current status of the FNOL record in the intake workflow.. Valid values are `draft|submitted|assigned|converted|closed`',
    `fraud_indicator` BOOLEAN COMMENT 'Flag indicating potential fraud detected during FNOL intake.',
    `injury_indicator` BOOLEAN COMMENT 'Flag indicating whether bodily injury was reported.',
    `intake_channel` STRING COMMENT 'Channel through which the FNOL was received.. Valid values are `phone|web|mobile_app|email|agent|in_person`',
    `intake_user_code` STRING COMMENT 'Identifier of the user or system that recorded the FNOL.',
    `is_cat_loss` BOOLEAN COMMENT 'Flag indicating whether the loss is part of a catastrophe event.',
    `loss_description` STRING COMMENT 'Narrative description of the loss event as reported by the claimant or reporter.',
    `loss_location_latitude` DECIMAL(10,7) COMMENT 'Geographic latitude coordinate of the loss location.',
    `loss_location_longitude` DECIMAL(10,7) COMMENT 'Geographic longitude coordinate of the loss location.',
    `number` STRING COMMENT 'Business identifier for the FNOL record, often displayed to users and external parties.',
    `peril_code` STRING COMMENT 'Code representing the peril or cause of loss reported.',
    `police_report_filed` BOOLEAN COMMENT 'Flag indicating whether a police report was filed for the loss.',
    `police_report_number` STRING COMMENT 'Police report number if a report was filed.',
    `property_damage_indicator` BOOLEAN COMMENT 'Flag indicating whether property damage was reported.',
    `reported_date` DATE COMMENT 'Date when the loss was first reported to the insurer.',
    `reported_timestamp` TIMESTAMP COMMENT 'Precise date and time when the loss was first reported to the insurer.',
    `reporter_name` STRING COMMENT 'Full name of the person who reported the loss.',
    `reporter_party_code` BIGINT COMMENT 'Reference to the party who reported the loss, if different from the claimant.',
    `reporter_relationship` STRING COMMENT 'Relationship of the reporter to the insured or claimant.. Valid values are `insured|agent|broker|attorney|third_party|other`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the FNOL record was last updated.',
    `witness_present` BOOLEAN COMMENT 'Flag indicating whether witnesses were present at the loss event.',
    CONSTRAINT pk_fnol PRIMARY KEY(`fnol_id`)
) COMMENT 'First Notice of Loss record capturing initial claim intake: date of loss, loss location, reported peril, claimant contact, policy reference, and FNOL channel. SSOT for claim origination events.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`claim` (
    `claim_id` BIGINT COMMENT 'Unique system identifier for the claim record. Primary key.',
    `cat_event_id` BIGINT COMMENT 'FK to reservespayments.cat_event.cat_event_id — Ties claims to the single catastrophe master for deterministic CAT rollups (PCS code aggregation) across claims, reserves, and reinsurance.',
    `claim_adjuster_id` BIGINT COMMENT 'Reference to the claims adjuster assigned to handle this claim.',
    `claim_examiner_adjuster_id` BIGINT COMMENT 'Reference to the claims examiner responsible for oversight and approval of claim decisions.',
    `claimant_party_id` BIGINT COMMENT 'Reference to the party making the claim (insured, third party, or other claimant).',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Multi-currency claim financials require proper currency reference for total_incurred_amount, paid_loss_amount, outstanding_reserve_amount, ALAE amounts, subrogation, salvage, and deductible.',
    `dol_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Date of loss determines accident year for loss development analysis, IBNR calculations, and statutory reporting.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Property claims must link to the insured location where loss occurred for coverage verification, exposure validation, CAT modeling, and territory rating confirmation.',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Auto claims must link to the specific vehicle involved for VIN validation, coverage verification, vehicle valuation, total loss determination, and symbol rating validation.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Claim LOB determines handling protocols, reserve authority limits, reinsurance treaty applicability, and statutory reporting classification.',
    `loss_location_country_id` BIGINT COMMENT 'Foreign key linking to shared.country. Business justification: Loss location country determines international jurisdiction, applicable law, reinsurance treaty applicability, and catastrophe exposure zone.',
    `loss_location_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Loss location state determines jurisdiction for coverage interpretation, statute of limitations, comparative negligence rules, and regulatory reporting.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Claims are filed under specific policy coverages. Core adjudication process requires linking claim to the exact coverage_policy_coverage for limit verification, deductible',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which this claim is filed.',
    `policy_insured_id` BIGINT COMMENT 'Reference to the named insured party on the policy at the time of loss.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key linking to producers.producers_producer. Business justification: Claims must link to the producer who wrote the underlying policy for loss ratio calculation, contingent commission determination, producer performance evaluation, E&O exposure',
    `scheduled_item_id` BIGINT COMMENT 'Foreign key linking to riskexposure.scheduled_item. Business justification: Claims for scheduled personal property (jewelry, fine arts, collectibles) must link to the scheduled item for agreed value verification, appraisal validation, and item-specific',
    `tpa_id` BIGINT COMMENT 'Foreign key linking to claims.tpa. Business justification: TPA (Third Party Administrator) handles claims on behalf of the insurer. One TPA administers many claims; one claim is administered by one TPA (when TPA-administered).',
    `alae_paid_amount` DECIMAL(18,2) COMMENT 'Total allocated loss adjustment expenses paid to date (legal, expert, investigation costs directly attributable to this claim).',
    `alae_reserve_amount` DECIMAL(18,2) COMMENT 'Outstanding reserve for allocated loss adjustment expenses on this claim.',
    `cat_indicator` BOOLEAN COMMENT 'Flag indicating whether the claim is part of a catastrophe event.',
    `claim_status` STRING COMMENT 'Current lifecycle status of the claim in the adjudication workflow.. Valid values are `open|closed|reopened|pending|denied|withdrawn`',
    `claim_type` STRING COMMENT 'Classification of the claim based on the relationship of the claimant to the policy (first-party, third-party, subrogation, salvage).. Valid values are `first_party|third_party|subrogation|salvage`',
    `closed_date` DATE COMMENT 'The date the claim was closed (final closure if reopened multiple times).',
    `closed_reason` STRING COMMENT 'Reason code or description for claim closure (e.g., paid in full, denied, withdrawn, settled).',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the claim record was first created in the claims system.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Policy deductible amount applicable to this claim.',
    `dol` DATE COMMENT 'The date on which the loss event occurred.',
    `fnol_date` DATE COMMENT 'The date the claim was first reported to the insurer.',
    `fnol_timestamp` TIMESTAMP COMMENT 'The precise timestamp when the claim was first reported to the insurer.',
    `fraud_indicator` BOOLEAN COMMENT 'Flag indicating whether the claim has been flagged for potential fraud investigation.',
    `litigation_indicator` BOOLEAN COMMENT 'Flag indicating whether the claim is in litigation or legal proceedings.',
    `loss_cause` STRING COMMENT 'The peril or cause of loss (e.g., collision, fire, theft, wind, hail, water damage, liability incident).',
    `loss_description` STRING COMMENT 'Narrative description of the loss event and circumstances as reported by the claimant or adjuster.',
    `loss_time` TIMESTAMP COMMENT 'The precise timestamp when the loss event occurred, if known.',
    `modified_timestamp` TIMESTAMP COMMENT 'System timestamp when the claim record was last modified.',
    `number` STRING COMMENT 'Externally-known unique business identifier for the claim, used in all communications and reporting.. Valid values are `^[A-Z0-9]{8,20}$`',
    `outstanding_reserve_amount` DECIMAL(18,2) COMMENT 'Current outstanding case reserve amount for unpaid losses on this claim.',
    `paid_loss_amount` DECIMAL(18,2) COMMENT 'Total amount paid to date for indemnity losses on this claim.',
    `reopened_count` BIGINT COMMENT 'Number of times the claim has been reopened after initial closure.',
    `reported_by` STRING COMMENT 'Name or identifier of the person or entity who reported the claim (insured, agent, third party).',
    `salvage_value_amount` DECIMAL(18,2) COMMENT 'Estimated or realized salvage value from damaged property retained by the insurer.',
    `settlement_date` DATE COMMENT 'The date a settlement agreement was reached with the claimant.',
    `subrogation_potential_amount` DECIMAL(18,2) COMMENT 'Estimated recoverable amount from subrogation against responsible third parties.',
    `subrogation_recovered_amount` DECIMAL(18,2) COMMENT 'Actual amount recovered to date through subrogation activities.',
    `total_incurred_amount` DECIMAL(18,2) COMMENT 'Total incurred loss amount including paid losses, outstanding case reserves, and allocated loss adjustment expenses.',
    CONSTRAINT pk_claim PRIMARY KEY(`claim_id`)
) COMMENT 'Master P&C claim record for a loss event: claim number, line of business, coverage type, loss cause, CAT code, open/closed status, adjuster assignment, and total incurred. SSOT for claim activity.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` (
    `claimant_id` BIGINT COMMENT 'Unique identifier for the claimant record. Primary key.',
    `attorney_id` BIGINT COMMENT 'Foreign key linking to claims.attorney. Business justification: Claimants are represented by attorneys when they assert claims. One attorney represents many claimants; one claimant has one attorney (when represented).',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim under which this claimant is asserting a loss.',
    `country_id` BIGINT COMMENT 'Foreign key linking to shared.country. Business justification: Claimant country determines payment processing requirements, tax withholding rules, data privacy compliance (GDPR, etc.), and international communication protocols.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Claimant reserve_amount, paid_amount, demand_amount, and settlement_amount require currency reference for multi-jurisdiction claims.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Claimant LOB determines coverage type applicability, settlement authority limits, and claimant-specific handling requirements.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Each claimants exposure is associated with a specific coverage part (e.g., BI vs PD in auto, occurrence vs aggregate in GL).',
    `settlement_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Claimant settlement date determines settlement period for settlement rate analysis, average time to settle metrics, and financial close reporting.',
    `address_line1` STRING COMMENT 'Primary street address line for the claimant residence or business location.',
    `address_line2` STRING COMMENT 'Secondary address line for apartment, suite, or unit number.',
    `body_part_injured` STRING COMMENT 'Specific body part or area injured in the claim event, using standardized anatomical terminology.',
    `city` STRING COMMENT 'City or municipality of the claimant address.',
    `claimant_status` STRING COMMENT 'Current lifecycle status of the claimant record: active, settled, closed, withdrawn, litigated, or denied.. Valid values are `active|settled|closed|withdrawn|litigated|denied`',
    `claimant_type` STRING COMMENT 'Classification of the claimant entity: person, organization, estate, trust, minor, or dependent.. Valid values are `person|organization|estate|trust|minor|dependent`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the claimant record was first created in the system.',
    `date_of_birth` DATE COMMENT 'Date of birth of the claimant if the claimant is a person, used for identification and age verification.',
    `dba_name` STRING COMMENT 'Trade name or doing business as name for the claimant organization if different from legal name.',
    `demand_amount` DECIMAL(15,2) COMMENT 'Amount demanded by the claimant or their attorney for settlement of the claim.',
    `email_address` STRING COMMENT 'Primary email address for claimant communication and correspondence.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `fault_percentage` DECIMAL(5,2) COMMENT 'Percentage of fault attributed to this claimant in comparative negligence determination, ranging from 0.00 to 100.00.',
    `fein` STRING COMMENT 'Federal Employer Identification Number for organizational claimants, used for tax and business identification.. Valid values are `^d{2}-d{7}$`',
    `first_name` STRING COMMENT 'First or given name of the claimant if the claimant is a person.',
    `injury_description` STRING COMMENT 'Detailed narrative description of the injury or damage sustained by the claimant.',
    `injury_severity` STRING COMMENT 'Severity classification of the claimant injury: minor, moderate, severe, critical, or fatal.. Valid values are `minor|moderate|severe|critical|fatal`',
    `injury_type` STRING COMMENT 'Classification of the injury or damage sustained by the claimant. [ENUM-REF-CANDIDATE: bodily_injury|property_damage|personal_injury_protection|medical_payments|lost_wages|pain_suffering|wrongful_death — promote to reference product]',
    `is_represented` BOOLEAN COMMENT 'Indicates whether the claimant is represented by legal counsel.',
    `last_name` STRING COMMENT 'Last name or surname of the claimant if the claimant is a person.',
    `middle_name` STRING COMMENT 'Middle name or initial of the claimant if applicable.',
    `mobile_phone_number` STRING COMMENT 'Mobile phone number for SMS and mobile communication with the claimant.. Valid values are `^+?[1-9]d{1,14}$`',
    `number` STRING COMMENT 'Business-assigned unique number for the claimant within the claim, used for external reference and reporting.',
    `organization_name` STRING COMMENT 'Legal name of the organization if the claimant is a business entity.',
    `paid_amount` DECIMAL(15,2) COMMENT 'Total amount paid to date for this claimant across all payments and settlements.',
    `party_code` BIGINT COMMENT 'Reference to the party master record representing this claimant.',
    `phone_number` STRING COMMENT 'Primary contact phone number for the claimant.. Valid values are `^+?[1-9]d{1,14}$`',
    `postal_code` STRING COMMENT 'Postal or ZIP code of the claimant address.',
    `representation_date` DATE COMMENT 'Date when the claimant retained legal representation for this claim.',
    `reserve_amount` DECIMAL(15,2) COMMENT 'Current reserve amount set aside for this claimant anticipated loss and expense payments.',
    `role` STRING COMMENT 'Role of the claimant in relation to the claim: insured party, third-party claimant, lienholder, additional insured, mortgagee, or loss payee.. Valid values are `insured|third_party|lienholder|additional_insured|mortgagee|loss_payee`',
    `settlement_amount` DECIMAL(15,2) COMMENT 'Final negotiated settlement amount agreed upon for this claimant.',
    `settlement_date` DATE COMMENT 'Date when the settlement agreement was executed for this claimant.',
    `ssn` STRING COMMENT 'Social Security Number of the claimant for tax reporting and identification purposes.. Valid values are `^d{3}-d{2}-d{4}$`',
    `state_province` STRING COMMENT 'State, province, or region of the claimant address.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the claimant record was last modified.',
    CONSTRAINT pk_claimant PRIMARY KEY(`claimant_id`)
) COMMENT 'Party asserting a loss under a claim: name, role (insured, third-party, lienholder), contact details, injury/damage type, representation status, and attorney info. Supports BI, PD, PIP, and WC claimant tracking.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` (
    `claim_coverage_id` BIGINT COMMENT 'Unique identifier for the claim coverage junction record linking a claim to a specific policy coverage.',
    `claim_id` BIGINT COMMENT 'Foreign key reference to the claim that triggered this coverage evaluation.',
    `coverage_adjuster_id` BIGINT COMMENT 'Identifier of the adjuster who made the coverage determination for this claim coverage.',
    `policy_coverage_id` BIGINT COMMENT 'Foreign key reference to the specific policy coverage being applied to this claim.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Coverage-level financials (applicable_limit_amount, deductible, SIR, incurred/paid/reserve amounts, ALAE, limit erosion) require currency reference for multi-currency policies.',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Auto coverage determinations must link to the vehicle for vehicle-specific coverage verification, symbol rating validation, and stated value limit application.',
    `loss_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Coverage loss date determines coverage trigger analysis for claims-made vs. occurrence policies. Essential for coverage determination, policy period matching, and trigger date disputes.',
    `risk_unit_id` BIGINT COMMENT 'Foreign key linking to riskexposure.risk_unit. Business justification: Coverage determinations must link to the specific risk unit that was rated and covered for exposure validation, limit verification, deductible application, and premium allocation.',
    `scheduled_item_id` BIGINT COMMENT 'Foreign key linking to riskexposure.scheduled_item. Business justification: Coverage for scheduled items must link to the item for agreed value application, item-specific deductible, and coverage trigger validation.',
    `applicable_deductible_amount` DECIMAL(18,2) COMMENT 'The deductible amount that applies to this coverage for the claim, representing the insureds out-of-pocket responsibility before coverage begins.',
    `applicable_limit_amount` DECIMAL(18,2) COMMENT 'The maximum coverage limit amount applicable to this specific coverage for the claim, reflecting per-occurrence, per-person, or aggregate limits.',
    `applicable_sir_amount` DECIMAL(18,2) COMMENT 'The self-insured retention amount applicable to this coverage, representing the amount the insured must pay before the insurers obligation begins.',
    `coinsurance_percentage` DECIMAL(5,2) COMMENT 'The percentage of loss shared by the insured after deductible is met, expressed as a decimal percentage.',
    `coverage_alae_amount` DECIMAL(18,2) COMMENT 'Allocated loss adjustment expenses directly attributable to this coverage, including legal fees, expert fees, and investigation costs.',
    `coverage_basis` STRING COMMENT 'The basis on which coverage limits and deductibles apply, such as per occurrence, per claim, or aggregate.. Valid values are `per_occurrence|per_claim|aggregate|per_person|per_accident`',
    `coverage_denial_reason_code` STRING COMMENT 'Standardized code indicating the reason for coverage denial if coverage status is denied, such as exclusion, policy lapse, or non-covered peril.',
    `coverage_denial_reason_description` STRING COMMENT 'Detailed explanation of why coverage was denied for this claim under this specific coverage.',
    `coverage_determination_date` DATE COMMENT 'Date when the coverage determination was made by the adjuster or underwriter for this claim coverage.',
    `coverage_incurred_loss_amount` DECIMAL(18,2) COMMENT 'Total incurred loss amount attributed to this specific coverage, including paid losses and outstanding reserves.',
    `coverage_notes` STRING COMMENT 'Free-text notes documenting coverage decisions, special considerations, or adjuster commentary for this claim coverage.',
    `coverage_outstanding_reserve_amount` DECIMAL(18,2) COMMENT 'Outstanding case reserve amount held for this specific coverage representing estimated future payments.',
    `coverage_paid_loss_amount` DECIMAL(18,2) COMMENT 'Total amount of loss payments made under this specific coverage to date.',
    `coverage_part` STRING COMMENT 'The specific part or section of the policy coverage applicable to this claim, such as liability, property, medical payments, or other coverage divisions.. Valid values are `Part A|Part B|Part C|Part D|Part E|Part F`',
    `coverage_status` STRING COMMENT 'Current adjudication status of this coverage for the claim indicating whether coverage applies, is denied, or is under review.. Valid values are `pending|covered|denied|excluded|exhausted|suspended`',
    `coverage_trigger_type` STRING COMMENT 'The type of trigger that activates this coverage, such as occurrence-based, claims-made, or manifestation trigger.. Valid values are `occurrence|claims_made|manifestation|exposure|injury_in_fact`',
    `created_by_user_code` STRING COMMENT 'Identifier of the user or system process that created this claim coverage record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this claim coverage record was first created in the system.',
    `deductible_satisfied_date` DATE COMMENT 'Date when the deductible was fully satisfied for this coverage.',
    `deductible_satisfied_flag` BOOLEAN COMMENT 'Indicates whether the applicable deductible has been fully satisfied by the insured for this coverage.',
    `exclusion_applied_flag` BOOLEAN COMMENT 'Indicates whether a policy exclusion was applied that affects coverage for this claim.',
    `exclusion_code` STRING COMMENT 'Code identifying the specific policy exclusion applied to this claim coverage, if applicable.',
    `limit_erosion_amount` DECIMAL(18,2) COMMENT 'The amount by which the coverage limit has been reduced due to prior claims or payments under the same policy term.',
    `loss_date` DATE COMMENT 'Date when the loss occurred, used to determine coverage applicability and trigger evaluation.',
    `policy_effective_date` DATE COMMENT 'Effective date of the policy coverage at the time of loss, used to validate coverage applicability.',
    `policy_expiration_date` DATE COMMENT 'Expiration date of the policy coverage at the time of loss, used to validate coverage applicability.',
    `remaining_limit_amount` DECIMAL(18,2) COMMENT 'The remaining available coverage limit after accounting for limit erosion and current claim incurred amounts.',
    `sublimit_amount` DECIMAL(18,2) COMMENT 'The sublimit amount applicable to this coverage if a sublimit applies, representing a lower maximum payout for specific perils or property types.',
    `sublimit_applied_flag` BOOLEAN COMMENT 'Indicates whether a sublimit applies to this coverage for the claim, restricting the maximum payout below the main policy limit.',
    `updated_by_user_code` STRING COMMENT 'Identifier of the user or system process that last updated this claim coverage record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this claim coverage record was last modified.',
    CONSTRAINT pk_claim_coverage PRIMARY KEY(`claim_coverage_id`)
) COMMENT 'Junction resolving the many-to-many claim-to-coverage relationship: applicable limit, deductible, SIR, coverage part, and coverage-level incurred amounts for each policy coverage triggered by the loss.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` (
    `claims_loss_reserve_id` BIGINT COMMENT 'Unique identifier for the loss reserve record.',
    `claim_coverage_id` BIGINT COMMENT 'Reference to the specific coverage line within the claim if reserve is coverage-specific.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim for which this reserve is established.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Reserve amounts (reserve_amount, prior_reserve_amount, reserve_change_amount, paid_to_date_amount, ultimate_loss_estimate) require currency reference for actuarial analysis, IBNR',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Property loss reserves must link to location for CAT modeling, geographic loss analysis, PML validation, territory loss ratio analysis, and CAT reserve adequacy.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Reserve LOB determines actuarial segmentation, loss development patterns, and statutory reserve requirements.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Reserves are established at the coverage level for actuarial segmentation and IBNR calculations.',
    `reserve_set_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Reserve set date determines reserve period for reserve movement analysis, reserve adequacy testing, and financial reporting.',
    `risk_unit_id` BIGINT COMMENT 'Foreign key linking to riskexposure.risk_unit. Business justification: Loss reserves must link to risk unit for exposure-based reserving, actuarial segmentation, loss development analysis, rate adequacy testing, and exposure-based reserve adequacy',
    `accident_year` BIGINT COMMENT 'Calendar year in which the loss event occurred, used for actuarial development triangle analysis.',
    `actuarial_segment_code` STRING COMMENT 'Code identifying the actuarial segment or homogeneous risk group to which this reserve is assigned for reserving and pricing analysis.',
    `approval_date` DATE COMMENT 'Date on which the reserve was formally approved by the authorized approver.',
    `approver_user_code` STRING COMMENT 'User ID of the manager or actuary who approved this reserve, for audit trail and authority verification.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this reserve record was first created in the data warehouse.',
    `paid_to_date_amount` DECIMAL(18,2) COMMENT 'Cumulative amount paid on this claim or coverage line as of the reserve set date, used to calculate ultimate loss estimate.',
    `prior_reserve_amount` DECIMAL(18,2) COMMENT 'Previous reserve amount before this adjustment, used to calculate reserve development and redundancy/deficiency.',
    `report_year` BIGINT COMMENT 'Calendar year in which the claim was first reported, used for IBNR and development analysis.',
    `reserve_amount` DECIMAL(18,2) COMMENT 'Monetary value of the reserve established for this claim or coverage line, in policy currency.',
    `reserve_approval_status` STRING COMMENT 'Approval workflow status for reserves requiring management or actuarial sign-off: pending, approved, rejected, or escalated.. Valid values are `pending|approved|rejected|escalated`',
    `reserve_basis` STRING COMMENT 'Basis or methodology used to establish the reserve: adjuster estimate, actuarial model, medical report, legal opinion, or settlement demand.. Valid values are `adjuster_estimate|actuarial_model|medical_report|legal_opinion|settlement_demand`',
    `reserve_category` STRING COMMENT 'Category of loss reserve: indemnity (pure loss), ALAE (Allocated Loss Adjustment Expense), ULAE (Unallocated Loss Adjustment Expense), defense costs, or medical payments.. Valid values are `indemnity|alae|ulae|defense|medical`',
    `reserve_change_amount` DECIMAL(18,2) COMMENT 'Net change in reserve amount from prior valuation, positive for increases and negative for decreases.',
    `reserve_confidence_level` STRING COMMENT 'Confidence level in the reserve estimate: low, medium, high, or very high, reflecting uncertainty in the valuation.. Valid values are `low|medium|high|very_high`',
    `reserve_effective_date` DATE COMMENT 'Date from which this reserve amount is effective for financial and actuarial reporting purposes.',
    `reserve_notes` STRING COMMENT 'Free-text notes or comments from the adjuster or actuary explaining the rationale, assumptions, or special considerations for this reserve.',
    `reserve_number` STRING COMMENT 'Business identifier for the reserve transaction, often system-generated or sequential.',
    `reserve_reason_code` STRING COMMENT 'Code indicating the reason for reserve establishment or adjustment (e.g., new claim, medical update, legal development, settlement negotiation).',
    `reserve_set_date` DATE COMMENT 'Date on which this reserve amount was established or last revised by the adjuster or actuary.',
    `reserve_source_system` STRING COMMENT 'Name of the source system from which this reserve record originated (e.g., ClaimCenter, Duck Creek Claims, Arius).',
    `reserve_source_system_code` STRING COMMENT 'Unique identifier of this reserve record in the source system, for traceability and reconciliation.',
    `reserve_status` STRING COMMENT 'Current lifecycle status of the reserve entry: open (active), closed (finalized), superseded (replaced by newer estimate), or pending review.. Valid values are `open|closed|superseded|pending_review`',
    `reserve_type` STRING COMMENT 'Classification of reserve: case (Outstanding Case Reserve/OCR), IBNR (Incurred But Not Reported), IBNER (Incurred But Not Enough Reported), salvage, or subrogation.. Valid values are `case|ibnr|ibner|salvage|subrogation`',
    `ultimate_loss_estimate` DECIMAL(18,2) COMMENT 'Estimated total loss (paid plus outstanding reserve) expected to be incurred on this claim or coverage line at final settlement.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this reserve record was last modified in the data warehouse.',
    `valuation_date` DATE COMMENT 'As-of date for which this reserve valuation is calculated, typically quarter-end or year-end for statutory reporting.',
    CONSTRAINT pk_claims_loss_reserve PRIMARY KEY(`claims_loss_reserve_id`)
) COMMENT 'Case reserve for a claim or claim-coverage line: OCR amount, ALAE reserve, reserve type (case/IBNR/IBNER), set date, basis, and actuarial segment. SSOT for reserve development fed to actuarial reserving.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` (
    `claims_reserve_transaction_id` BIGINT COMMENT 'Unique identifier for each reserve transaction record in the audit ledger.',
    `claim_id` BIGINT COMMENT 'Identifier of the claim to which this reserve transaction applies.',
    `claims_adjuster_id` BIGINT COMMENT 'Identifier of the claims adjuster who authorized or executed this reserve movement.',
    `claims_supervisor_adjuster_id` BIGINT COMMENT 'Identifier of the supervisor who approved this reserve change if approval was required.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Reserve transaction amounts (prior_reserve_amount, transaction_amount, new_reserve_amount, reinsurance_recoverable_amount, net_reserve_amount) require currency reference for reserve movement',
    `effective_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Reserve transaction effective date determines transaction period for reserve movement tracking, loss development analysis, and financial reporting.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Reserve transaction LOB determines GL account mapping, statutory reporting classification, and reinsurance recovery allocation.',
    `reversed_transaction_claims_reserve_transaction_id` BIGINT COMMENT 'Identifier of the original transaction being reversed, if this is a reversal entry.',
    `risk_unit_id` BIGINT COMMENT 'Foreign key linking to riskexposure.risk_unit. Business justification: Reserve changes must link to risk unit for loss development triangles, exposure-based reserve adequacy, and rate indication analysis.',
    `accident_year` BIGINT COMMENT 'Calendar year in which the loss occurred, used for Schedule P triangle reporting and IBNR development.',
    `accounting_period` STRING COMMENT 'Year-month accounting period to which this reserve transaction is posted for financial reporting.. Valid values are `^d{4}-d{2}$`',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether supervisory approval was required for this reserve transaction based on authority limits.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the supervisor approved this reserve transaction, if applicable.',
    `bulk_reserve_flag` BOOLEAN COMMENT 'Indicates whether this transaction is part of a bulk reserve adjustment across multiple claims.',
    `cat_code` STRING COMMENT 'Industry catastrophe event code if this reserve relates to a declared catastrophe event.',
    `coverage_code` STRING COMMENT 'Code identifying the specific policy coverage under which this reserve is held.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this reserve transaction record was first created in the data warehouse.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this reserve transaction is posted for financial statement preparation.',
    `loss_development_factor` DECIMAL(10,4) COMMENT 'Actuarial development factor applied to adjust reserves based on historical loss emergence patterns.',
    `net_reserve_amount` DECIMAL(18,2) COMMENT 'Net reserve after deducting reinsurance recoverables, representing the companys retained exposure.',
    `new_reserve_amount` DECIMAL(18,2) COMMENT 'Reserve balance after applying this transaction, in policy currency.',
    `notes` STRING COMMENT 'Free-text notes or comments providing additional context for this reserve transaction.',
    `peril_code` STRING COMMENT 'Code identifying the cause of loss or peril associated with this reserve.',
    `posting_status` STRING COMMENT 'Current lifecycle status of this reserve transaction in the financial ledger.. Valid values are `draft|pending|posted|reversed|voided`',
    `prior_reserve_amount` DECIMAL(18,2) COMMENT 'Reserve balance immediately before this transaction, in policy currency.',
    `reason_code` STRING COMMENT 'Standardized code indicating the business reason for this reserve adjustment.',
    `reason_description` STRING COMMENT 'Detailed narrative explanation of why this reserve change was made, supporting actuarial review and audit.',
    `reinsurance_recoverable_amount` DECIMAL(18,2) COMMENT 'Portion of this reserve that is expected to be recovered from reinsurers under treaty or facultative agreements.',
    `report_year` BIGINT COMMENT 'Calendar year in which the claim was first reported, supporting incurred-but-not-reported analysis.',
    `reserve_category` STRING COMMENT 'Type of reserve being adjusted: case reserve (OCR), IBNR, ALAE, or ULAE.. Valid values are `case_reserve|ibnr|alae|ulae`',
    `reserve_confidence_level` STRING COMMENT 'Adjuster or actuarial assessment of confidence in the adequacy of this reserve estimate.. Valid values are `low|medium|high|very_high`',
    `reserve_method` STRING COMMENT 'Methodology used to calculate this reserve: case-by-case, formula-driven, actuarial model, or bulk reserve.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether this transaction reverses a prior reserve transaction due to error correction or adjustment.',
    `salvage_subrogation_estimate` DECIMAL(18,2) COMMENT 'Estimated amount expected to be recovered through salvage or subrogation, reducing net reserve exposure.',
    `source_transaction_code` STRING COMMENT 'Unique identifier of this transaction in the source claims system for reconciliation and traceability.',
    `transaction_amount` DECIMAL(18,2) COMMENT 'Signed delta applied in this transaction; positive for increases, negative for decreases.',
    `transaction_effective_date` DATE COMMENT 'Accounting date on which this reserve change takes effect for financial and statutory reporting.',
    `transaction_number` STRING COMMENT 'Business-facing sequence or reference number for this reserve movement within the claim lifecycle.',
    `transaction_timestamp` TIMESTAMP COMMENT 'Precise date and time when this reserve transaction was recorded in the system.',
    `transaction_type` STRING COMMENT 'Category of reserve movement: initial set, increase, decrease, reopen, close, or transfer between reserve types.. Valid values are `initial_set|increase|decrease|reopen|close|transfer`',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp when this reserve transaction record was last modified in the data warehouse.',
    `valuation_date` DATE COMMENT 'As-of date for reserve valuation, typically quarter-end or year-end for statutory reporting.',
    CONSTRAINT pk_claims_reserve_transaction PRIMARY KEY(`claims_reserve_transaction_id`)
) COMMENT 'Audit-grade ledger of every reserve movement on a claim: prior amount, new amount, delta, transaction type (set/increase/decrease/close), and authorizing adjuster. Supports IBNR development and NAIC Schedule P triangles.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` (
    `claims_claim_payment_id` BIGINT COMMENT 'Unique identifier for the claim payment transaction record.',
    `claim_coverage_id` BIGINT COMMENT 'Reference to the specific coverage line within the claim being paid, if payment is coverage-specific.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim for which this payment is issued.',
    `claims_reserve_transaction_id` BIGINT COMMENT 'Reference to the reserve transaction that authorized or funded this payment.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Payment amounts (gross_payment_amount, deductible_amount, offset_amount, withholding_amount, net_payment_amount) require currency reference for payment processing, tax withholding',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Property claim payments must link to location for geographic loss analysis, territory rate adequacy, CAT loss validation, and PML reconciliation.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Payment LOB determines GL account mapping, statutory reporting classification, and reinsurance recovery allocation.',
    `payee_id` BIGINT COMMENT 'Reference to the party entity receiving the payment.',
    `payment_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Payment date determines payment period for cash flow analysis, paid loss development, and financial reporting. Essential for Schedule P paid loss reporting and cash management.',
    `payment_transaction_id` BIGINT COMMENT 'Foreign key linking to reservespayments.payment_transaction. Business justification: Payment reconciliation requires linking operational payment records (claims domain) to financial payment transactions (reservespayments domain).',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Payments erode specific coverage limits and must be tracked against the coverage_policy_coverage for aggregate limit monitoring, reinsurance cession calculations, and',
    `risk_unit_id` BIGINT COMMENT 'Foreign key linking to riskexposure.risk_unit. Business justification: Claim payments must link to risk unit for premium-to-loss ratio analysis, rate adequacy testing, exposure-based profitability, and actuarial pricing.',
    `accounting_date` DATE COMMENT 'Date the payment was posted to the general ledger for financial reporting purposes.',
    `approval_authority` STRING COMMENT 'Name or identifier of the adjuster, supervisor, or system that approved the payment.',
    `approval_date` DATE COMMENT 'Date the payment was approved for issuance.',
    `catastrophe_code` STRING COMMENT 'ISO or PCS catastrophe event code if the payment is related to a declared catastrophe.',
    `check_number` STRING COMMENT 'Physical or virtual check number assigned to the payment, if payment method is check.',
    `cleared_date` DATE COMMENT 'Date the payment cleared the bank or financial institution.',
    `created_by_user` STRING COMMENT 'User ID or name of the person or system that created the payment record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the payment record was first created in the system.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Portion of the loss retained by the insured and deducted from the gross payment.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which the payment is posted for financial reporting.',
    `gross_payment_amount` DECIMAL(18,2) COMMENT 'Total payment amount before any deductions, offsets, or withholdings.',
    `is_joint_payee` BOOLEAN COMMENT 'Indicates whether the payment is issued to multiple payees jointly (e.g., insured and mortgagee).',
    `is_reportable_1099` BOOLEAN COMMENT 'Indicates whether the payment is reportable to the IRS on Form 1099-MISC.',
    `joint_payee_name` STRING COMMENT 'Name of the second payee if payment is issued jointly.',
    `loss_category` STRING COMMENT 'High-level classification of the loss type for which payment is made: property, liability, auto physical damage, workers compensation, medical, legal, or other.',
    `net_payment_amount` DECIMAL(18,2) COMMENT 'Final disbursed amount after all deductions, offsets, and withholdings.',
    `offset_amount` DECIMAL(18,2) COMMENT 'Amount offset against the payment for prior overpayments, subrogation, or other recoveries.',
    `payee_tax_number` STRING COMMENT 'Tax identification number (SSN or FEIN) of the payee for IRS 1099 reporting purposes.',
    `payee_type` STRING COMMENT 'Classification of the payment recipient: claimant, insured, vendor, medical provider, legal counsel, mortgagee, lienholder, or other party. [ENUM-REF-CANDIDATE: claimant|insured|vendor|medical_provider|legal_counsel|mortgagee|lienholder|other — 8',
    `payment_batch_code` STRING COMMENT 'Identifier for the batch or run in which this payment was processed, if applicable.',
    `payment_date` DATE COMMENT 'Date the payment was issued or disbursed to the payee.',
    `payment_memo` STRING COMMENT 'Free-text memo or note describing the purpose or context of the payment.',
    `payment_method` STRING COMMENT 'Instrument used to disburse payment: check, EFT (Electronic Funds Transfer), wire transfer, ACH (Automated Clearing House), debit card, or virtual card.. Valid values are `check|eft|wire|ach|debit_card|virtual_card`',
    `payment_number` STRING COMMENT 'Business identifier for the payment transaction, often sequential within a claim.',
    `payment_status` STRING COMMENT 'Current lifecycle status of the payment: pending approval, approved, issued, cleared by bank, voided, stopped, or returned. [ENUM-REF-CANDIDATE: pending|approved|issued|cleared|voided|stopped|returned — 7 candidates stripped; promote to reference product]',
    `payment_type` STRING COMMENT 'Classification of payment: indemnity, ALAE (Allocated Loss Adjustment Expense), ULAE (Unallocated Loss Adjustment Expense), medical, expense, subrogation recovery, salvage recovery, or deductible reimbursement.',
    `salvage_potential_flag` BOOLEAN COMMENT 'Indicates whether the payment has potential for salvage recovery from damaged property.',
    `state_code` STRING COMMENT 'Two-letter US state or Canadian province code where the payment is allocated for regulatory reporting.. Valid values are `^[A-Z]{2}$`',
    `subrogation_potential_flag` BOOLEAN COMMENT 'Indicates whether the payment has potential for subrogation recovery from a third party.',
    `transaction_reference_number` STRING COMMENT 'Electronic payment confirmation or trace number from the financial institution or payment processor.',
    `updated_by_user` STRING COMMENT 'User ID or name of the person or system that last modified the payment record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the payment record was last modified.',
    `void_date` DATE COMMENT 'Date the payment was voided or cancelled, if applicable.',
    `withholding_amount` DECIMAL(18,2) COMMENT 'Tax or legal withholding amount deducted from the gross payment per regulatory or court order.',
    CONSTRAINT pk_claims_claim_payment PRIMARY KEY(`claims_claim_payment_id`)
) COMMENT 'Junction table linking a claim (or claim-coverage line) to a disbursement: payee, payment amount, payment type (indemnity/ALAE/ULAE/subrogation recovery), check number, and payment date. Resolves the many-to-many claim-to-payment relationship.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` (
    `disbursement_id` BIGINT COMMENT 'Unique identifier for the claim payment disbursement transaction.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Disbursement date determines disbursement period for cash flow analysis, bank reconciliation, and treasury management. Essential for cash management and disbursement volume tracking.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim for which this disbursement is issued.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Disbursement amounts (gross_amount, withholding_amount, offset_amount, net_amount) require currency reference for check/EFT processing, bank reconciliation, and GL posting.',
    `payee_id` BIGINT COMMENT 'Reference to the party entity receiving the disbursement funds (claimant, vendor, provider, attorney).',
    `payment_id` BIGINT COMMENT 'Reference to the logical payment authorization that this disbursement fulfills.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the disbursement was approved for issuance.',
    `approval_user_code` STRING COMMENT 'User identifier of the claims adjuster or supervisor who authorized the disbursement.',
    `bank_account_number` STRING COMMENT 'Payee bank account number for electronic funds transfer (EFT/ACH/Wire) disbursements.',
    `bank_name` STRING COMMENT 'Name of the financial institution receiving the electronic disbursement.',
    `bank_routing_number` STRING COMMENT 'ABA routing transit number for the payee financial institution, used for electronic disbursements.',
    `check_number` STRING COMMENT 'Physical check number printed on the disbursement instrument, if disbursement method is check.',
    `cleared_date` DATE COMMENT 'Date the disbursement cleared the bank or was confirmed as received by the payee.',
    `coverage_code` STRING COMMENT 'ISO or internal coverage code identifying the policy coverage under which this disbursement is paid.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the disbursement record was first created in the system.',
    `disbursement_date` DATE COMMENT 'Date the disbursement was issued or initiated (check date or EFT origination date).',
    `disbursement_status` STRING COMMENT 'Current lifecycle status of the disbursement transaction.. Valid values are `pending|issued|cleared|voided|stopped|cancelled`',
    `eft_trace_number` STRING COMMENT 'Unique trace or confirmation number assigned by the ACH or wire transfer system for electronic disbursements.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this disbursement is posted for financial reporting.',
    `gl_posting_date` DATE COMMENT 'Accounting date when the disbursement transaction was posted to the general ledger.',
    `gross_amount` DECIMAL(18,2) COMMENT 'Total authorized payment amount before any deductions, withholdings, or offsets.',
    `is_void` BOOLEAN COMMENT 'Indicator whether the disbursement has been voided or cancelled.',
    `issued_by_user_code` STRING COMMENT 'User identifier of the person or system that issued or generated the disbursement instrument.',
    `issued_timestamp` TIMESTAMP COMMENT 'Date and time when the disbursement was physically or electronically issued to the payee.',
    `loss_category` STRING COMMENT 'Classification of the loss type for statutory and regulatory reporting (e.g., bodily injury, property damage, medical payments).',
    `memo` STRING COMMENT 'Free-text memo or note describing the purpose or context of the disbursement, often printed on check stub or remittance advice.',
    `method` STRING COMMENT 'Payment instrument or mechanism used to disburse funds to the payee. [ENUM-REF-CANDIDATE: check|eft|wire|ach|debit_card|paypal|other — 7 candidates stripped; promote to reference product]',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when the disbursement record was last updated or modified.',
    `net_amount` DECIMAL(18,2) COMMENT 'Actual amount paid to the payee after all withholdings and offsets (gross minus withholding minus offset).',
    `number` STRING COMMENT 'Business-facing unique identifier for the disbursement, often printed on checks or remittance advice.',
    `offset_amount` DECIMAL(18,2) COMMENT 'Amount deducted from gross due to subrogation recovery, overpayment recoupment, or other offsets.',
    `payee_address_line1` STRING COMMENT 'Primary street address line for the payee receiving the disbursement.',
    `payee_address_line2` STRING COMMENT 'Secondary address line for the payee (suite, apartment, building number).',
    `payee_city` STRING COMMENT 'City name for the payee mailing address.',
    `payee_country` STRING COMMENT 'Three-letter ISO country code for the payee mailing address.',
    `payee_postal_code` STRING COMMENT 'Postal or ZIP code for the payee mailing address.',
    `payee_state` STRING COMMENT 'State or province code for the payee mailing address.',
    `payee_tax_number` STRING COMMENT 'Tax identification number for the payee, used for IRS 1099 reporting and tax withholding compliance.',
    `payment_type` STRING COMMENT 'Classification of the payment purpose (indemnity, expense, ALAE, ULAE, subrogation recovery, salvage, other). [ENUM-REF-CANDIDATE: indemnity|expense|alae|ulae|subrogation|salvage|other — 7 candidates stripped; promote to reference product]',
    `void_date` DATE COMMENT 'Date the disbursement was voided or cancelled, if applicable.',
    `void_reason` STRING COMMENT 'Business reason or explanation for voiding the disbursement (e.g., duplicate payment, incorrect amount, payee request).',
    `withholding_amount` DECIMAL(18,2) COMMENT 'Total amount withheld from gross for tax, legal, or other mandatory deductions.',
    CONSTRAINT pk_disbursement PRIMARY KEY(`disbursement_id`)
) COMMENT 'Financial disbursement record for a claim payment: payee party, bank/check details, gross amount, net amount, withholding, void flag, EFT/check indicator, and GL posting reference. SSOT for claim cash outflow.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` (
    `adjuster_id` BIGINT COMMENT 'Unique identifier for the claims adjuster record. Primary key.',
    `license_issue_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Adjuster license issue date tracks license lifecycle for compliance monitoring and license history analysis. Essential for adjuster qualification tracking and regulatory compliance.',
    `license_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Adjuster license state links to state licensing authority (DOI) for license verification, continuing education requirements, and regulatory compliance.',
    `supervisor_adjuster_id` BIGINT COMMENT 'Identifier of the supervising adjuster or claims manager responsible for oversight and escalations.',
    `tpa_id` BIGINT COMMENT 'Foreign key linking to claims.tpa. Business justification: Adjusters can be employed by TPAs (Third Party Administrators) rather than directly by the insurer. One TPA employs many adjusters; one adjuster works for one TPA (when adjuster_type = TPA).',
    `adjuster_type` STRING COMMENT 'Classification of adjuster employment relationship: staff employee, independent contractor, Third-Party Administrator (TPA), Catastrophe (CAT) specialist, or public adjuster.. Valid values are `staff|independent|TPA|CAT|public`',
    `background_check_date` DATE COMMENT 'Date the most recent background check was completed for compliance and risk management.',
    `background_check_status` STRING COMMENT 'Result status of the most recent background check screening.. Valid values are `passed|failed|pending|expired`',
    `ce_due_date` DATE COMMENT 'Date by which the adjuster must complete required continuing education hours to maintain license.',
    `continuing_education_hours` BIGINT COMMENT 'Total continuing education hours completed in the current licensing period for compliance tracking.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the adjuster record was first created in the system.',
    `current_workload_count` BIGINT COMMENT 'Number of open claims currently assigned to the adjuster for capacity planning and workload balancing.',
    `email_address` STRING COMMENT 'Primary business email address for adjuster communication and claim correspondence.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `employment_status` STRING COMMENT 'Current employment or engagement status of the adjuster.. Valid values are `active|inactive|suspended|terminated|leave`',
    `eo_expiration_date` DATE COMMENT 'Expiration date of the errors and omissions insurance policy for compliance monitoring.',
    `eo_insurance_carrier` STRING COMMENT 'Name of the insurance carrier providing errors and omissions coverage for the adjuster.',
    `eo_policy_number` STRING COMMENT 'Policy number of the errors and omissions insurance coverage required for independent adjusters.',
    `fein` STRING COMMENT 'Federal tax identification number for independent adjusters operating as business entities.. Valid values are `^[0-9]{2}-[0-9]{7}$`',
    `first_name` STRING COMMENT 'Legal first name of the adjuster as registered with licensing authorities.',
    `hire_date` DATE COMMENT 'Date the adjuster was hired or contracted to begin claims handling services.',
    `home_office_location` STRING COMMENT 'Primary office or branch location where the adjuster is based for assignment and reporting purposes.',
    `last_name` STRING COMMENT 'Legal last name of the adjuster as registered with licensing authorities.',
    `license_expiration_date` DATE COMMENT 'Date the adjuster license expires and requires renewal to maintain active status.',
    `license_issue_date` DATE COMMENT 'Date the adjuster license was originally issued by the state Department of Insurance.',
    `license_number` STRING COMMENT 'Primary state-issued adjuster license number for regulatory compliance and claim handling authority.',
    `license_status` STRING COMMENT 'Current regulatory status of the adjuster license with the state Department of Insurance.. Valid values are `active|expired|suspended|revoked|pending`',
    `lob_authority` STRING COMMENT 'Comma-separated list of lines of business the adjuster is authorized to handle based on license and training. [ENUM-REF-CANDIDATE: personal_auto|commercial_auto|homeowners|commercial_property|GL|WC|umbrella|inland_marine — promote to reference product]',
    `max_workload_capacity` BIGINT COMMENT 'Maximum number of concurrent claims the adjuster can handle based on complexity and line of business.',
    `middle_name` STRING COMMENT 'Middle name or initial of the adjuster.',
    `mobile_number` STRING COMMENT 'Mobile phone number for field adjuster contact and emergency communication.. Valid values are `^+?[1-9]d{1,14}$`',
    `naic_code` STRING COMMENT 'Five-digit NAIC company code if adjuster is associated with a specific carrier for regulatory reporting.. Valid values are `^[0-9]{5}$`',
    `notes` STRING COMMENT 'Free-form notes capturing special skills, restrictions, preferences, or administrative remarks about the adjuster.',
    `number` STRING COMMENT 'Business identifier assigned to the adjuster for external reference and licensing purposes.. Valid values are `^ADJ[0-9]{6,10}$`',
    `phone_number` STRING COMMENT 'Primary contact phone number for the adjuster.. Valid values are `^+?[1-9]d{1,14}$`',
    `reserve_authority_limit` DECIMAL(15,2) COMMENT 'Maximum dollar amount the adjuster is authorized to establish or modify case reserves without supervisory approval.',
    `settlement_authority_limit` DECIMAL(15,2) COMMENT 'Maximum dollar amount the adjuster is authorized to settle without supervisory approval.',
    `specialization` STRING COMMENT 'Primary area of claims expertise such as CAT, auto physical damage, general liability, workers compensation, property, or medical. [ENUM-REF-CANDIDATE: CAT|auto|APD|GL|CGL|WC|property|medical|subrogation|fraud — promote to reference product]',
    `ssn_last_four` STRING COMMENT 'Last four digits of the adjuster Social Security Number for identity verification and tax reporting.. Valid values are `^[0-9]{4}$`',
    `termination_date` DATE COMMENT 'Date the adjuster employment or contract was terminated.',
    `territory_code` STRING COMMENT 'Geographic territory code defining the adjuster service area for claim assignment routing.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the adjuster record was last modified.',
    `vendor_company_name` STRING COMMENT 'Name of the independent adjusting firm or TPA if adjuster is not a staff employee.',
    `vendor_contract_number` STRING COMMENT 'Contract or agreement number governing the independent adjuster or TPA engagement terms.',
    `years_of_experience` BIGINT COMMENT 'Total years of claims adjusting experience across all employers and lines of business.',
    CONSTRAINT pk_adjuster PRIMARY KEY(`adjuster_id`)
) COMMENT 'Claims adjuster master: staff or independent adjuster name, license number, state appointments, adjuster type (staff/IA/TPA), specialization (CAT/auto/GL/WC), and current workload capacity. SSOT for adjuster identity.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` (
    `adjuster_assignment_id` BIGINT COMMENT 'Unique identifier for the adjuster assignment record.',
    `assignment_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Adjuster assignment date determines assignment period for workload analysis, assignment lag metrics, and operational reporting.',
    `claim_id` BIGINT COMMENT 'Reference to the claim being assigned to an adjuster.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Adjuster assignments for property claims must link to location for geographic routing, workload management by territory, travel optimization, and local expertise matching.',
    `primary_adjuster_id` BIGINT COMMENT 'Reference to the adjuster assigned to handle the claim.',
    `actual_hours` DECIMAL(10,2) COMMENT 'Actual number of hours spent by the adjuster on this claim assignment.',
    `assigned_by_name` STRING COMMENT 'Name of the user or system that performed the assignment.',
    `assigned_by_user_code` BIGINT COMMENT 'Reference to the user who performed the assignment.',
    `assignment_date` DATE COMMENT 'Date when the adjuster was assigned to the claim.',
    `assignment_method` STRING COMMENT 'Method used to assign the adjuster: manual selection, automatic routing, round-robin, skill-based matching, geographic proximity, or workload balancing algorithm.. Valid values are `manual|automatic|round_robin|skill_based|geographic|workload_balanced`',
    `assignment_notes` STRING COMMENT 'Free-text notes or comments regarding the assignment, including special instructions or context.',
    `assignment_number` STRING COMMENT 'Business-readable unique identifier for the assignment.',
    `assignment_reason` STRING COMMENT 'Business reason for the assignment: initial intake, workload balancing, expertise required, geographic coverage, catastrophe response, or other justification.',
    `assignment_role` STRING COMMENT 'Role of the adjuster in this assignment: primary handler, supervisor, catastrophe adjuster, specialist, desk adjuster, field adjuster, or independent adjuster.',
    `assignment_status` STRING COMMENT 'Current status of the adjuster assignment.. Valid values are `active|inactive|suspended|completed|cancelled`',
    `assignment_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the adjuster assignment was created.',
    `assignment_type` STRING COMMENT 'Type of assignment: initial assignment, reassignment, escalation, transfer, temporary coverage, or permanent assignment.. Valid values are `initial|reassignment|escalation|transfer|temporary|permanent`',
    `cat_code` STRING COMMENT 'Catastrophe event code if this assignment is related to a declared catastrophe event.',
    `complexity_level` STRING COMMENT 'Assessed complexity level of the claim for assignment and workload planning purposes.. Valid values are `low|medium|high|complex|catastrophic`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the assignment record was first created in the system.',
    `effective_date` DATE COMMENT 'Date when the assignment becomes effective.',
    `end_date` DATE COMMENT 'Date when the assignment ended or was terminated.',
    `end_reason` STRING COMMENT 'Reason the assignment ended: claim closed, reassignment, adjuster departure, escalation, or other termination cause.',
    `end_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the assignment was ended or terminated.',
    `estimated_hours` DECIMAL(10,2) COMMENT 'Estimated number of hours required to handle this claim assignment.',
    `first_contact_date` DATE COMMENT 'Date when the adjuster first contacted the claimant or insured after assignment.',
    `is_active` BOOLEAN COMMENT 'Indicates whether this is the current active assignment for the claim.',
    `is_cat_assignment` BOOLEAN COMMENT 'Indicates whether this assignment is part of a catastrophe response effort.',
    `is_primary` BOOLEAN COMMENT 'Indicates whether this adjuster is the primary handler for the claim.',
    `last_activity_date` DATE COMMENT 'Date of the most recent activity or action taken by the adjuster on this assignment.',
    `license_required` STRING COMMENT 'Adjuster license or certification required for this assignment based on jurisdiction and claim type.',
    `lob` STRING COMMENT 'Line of business for the claim: personal auto, homeowners, commercial property, general liability, workers compensation, or other product line.',
    `modified_by_user_code` BIGINT COMMENT 'Reference to the user who last modified the assignment record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the assignment record was last modified.',
    `reassignment_reason` STRING COMMENT 'Reason for reassigning the claim to a different adjuster: workload rebalancing, adjuster unavailability, escalation, conflict of interest, or other cause.',
    `sla_target_days` BIGINT COMMENT 'Target number of days to complete key milestones for this assignment per service level agreement.',
    `specialty_required` STRING COMMENT 'Specific adjuster specialty or expertise required for this assignment: bodily injury, property damage, subrogation, fraud investigation, large loss, or other specialization.',
    `territory_code` STRING COMMENT 'Geographic territory code for the assignment, used for routing and workload distribution.',
    `workload_priority` BIGINT COMMENT 'Priority ranking of this assignment within the adjusters workload, with lower numbers indicating higher priority.',
    CONSTRAINT pk_adjuster_assignment PRIMARY KEY(`adjuster_assignment_id`)
) COMMENT 'Assignment of an adjuster to a claim: assignment date, role (primary/supervisor/CAT/specialist), reassignment reason, and active flag. Tracks adjuster workload and claim ownership history.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` (
    `claim_note_id` BIGINT COMMENT 'Unique identifier for the claim note record.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim to which this note is attached.',
    `claim_coverage_id` BIGINT COMMENT 'Reference to the specific coverage under which this note is categorized, if applicable.',
    `exposure_id` BIGINT COMMENT 'Reference to the claim exposure this note pertains to, if applicable.',
    `note_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Claim note date determines note period for activity tracking, diary management, and audit trail. Essential for claim activity analysis and operational metrics.',
    `activity_code` BIGINT COMMENT 'Reference to the claim activity or task associated with this note, if applicable.',
    `assigned_to_user_code` STRING COMMENT 'System identifier of the user to whom follow-up or review of this note is assigned.',
    `attachment_count` BIGINT COMMENT 'Number of documents or files attached to this note.',
    `author_name` STRING COMMENT 'Full name of the user who authored the note for display and audit purposes.',
    `author_user_code` STRING COMMENT 'System identifier of the user who created the note.',
    `body_text` STRING COMMENT 'Full text content of the note capturing detailed information, observations, or instructions.',
    `confidential_flag` BOOLEAN COMMENT 'Indicator whether the note contains confidential or sensitive information restricted to specific roles.',
    `deleted_by_user_code` STRING COMMENT 'System identifier of the user who deleted the note, if applicable.',
    `deleted_date` DATE COMMENT 'Date on which the note was marked as deleted, if applicable.',
    `deleted_flag` BOOLEAN COMMENT 'Indicator whether the note has been soft-deleted and should be excluded from active views.',
    `editable_flag` BOOLEAN COMMENT 'Indicator whether the note can be edited after creation or is locked for audit integrity.',
    `external_reference_code` STRING COMMENT 'Identifier from an external system or document management system linking to related content.',
    `follow_up_date` DATE COMMENT 'Target date by which follow-up action on this note should be completed.',
    `follow_up_required_flag` BOOLEAN COMMENT 'Indicator whether the note requires follow-up action or review by another user.',
    `language_code` STRING COMMENT 'Three-letter ISO 639-2 language code indicating the language in which the note is written.. Valid values are `^[A-Z]{3}$`',
    `last_modified_by_user_code` STRING COMMENT 'System identifier of the user who last modified the note.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when the note was last updated or modified.',
    `litigation_flag` BOOLEAN COMMENT 'Indicator whether the note is related to litigation or legal proceedings and subject to discovery.',
    `note_date` DATE COMMENT 'Business date on which the note was created or the event it describes occurred.',
    `note_number` STRING COMMENT 'Business-readable sequential or formatted identifier for the note within the claim.',
    `note_subtype` STRING COMMENT 'Further classification or subcategory of the note type for granular categorization.',
    `note_timestamp` TIMESTAMP COMMENT 'Precise date and time when the note was created in the system.',
    `note_type` STRING COMMENT 'Classification of the note indicating its purpose: diary, coverage analysis, legal, medical, general, activity log, reserve, or payment. [ENUM-REF-CANDIDATE: diary|coverage|legal|medical|general|activity|reserve|payment — 8 candidates stripped; promote to',
    `priority` STRING COMMENT 'Priority level assigned to the note indicating urgency or importance: low, normal, high, or urgent.. Valid values are `low|normal|high|urgent`',
    `privileged_flag` BOOLEAN COMMENT 'Indicator whether the note is protected by attorney-client privilege or work product doctrine.',
    `related_party_code` BIGINT COMMENT 'Reference to a party involved in the claim that this note discusses, such as claimant, witness, or attorney.',
    `reviewed_by_user_code` STRING COMMENT 'System identifier of the user who reviewed the note.',
    `reviewed_date` DATE COMMENT 'Date on which the note was reviewed, if applicable.',
    `reviewed_flag` BOOLEAN COMMENT 'Indicator whether the note has been reviewed by a supervisor or designated reviewer.',
    `security_level` STRING COMMENT 'Classification level controlling access to the note: public, internal, confidential, or restricted.. Valid values are `public|internal|confidential|restricted`',
    `subject` STRING COMMENT 'Brief subject line or title summarizing the content of the note.',
    `topic` STRING COMMENT 'Keyword or topic tag for categorizing and searching notes by subject matter.',
    `visibility_scope` STRING COMMENT 'Defines who can view the note: internal staff only, external parties, vendors, legal counsel, or medical reviewers.. Valid values are `internal|external|vendor|legal|medical`',
    CONSTRAINT pk_claim_note PRIMARY KEY(`claim_note_id`)
) COMMENT 'Structured diary and activity note on a claim: note type (diary/coverage/legal/medical), author, note date, body text, confidentiality flag, and linked activity. Supports adjudication audit trail and litigation management.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` (
    `claim_document_id` BIGINT COMMENT 'Unique identifier for the claim document record.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim to which this document is attached.',
    `document_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Claim document date determines document period for document management, retention policy application, and audit trail. Essential for document lifecycle management and legal hold tracking.',
    `fnol_id` BIGINT COMMENT 'Reference to the FNOL record if document was submitted at intake.',
    `approved_by_user_code` STRING COMMENT 'User identifier of the person who approved the document.',
    `approved_date` DATE COMMENT 'Date the document was approved for use in claim processing.',
    `approved_flag` BOOLEAN COMMENT 'Indicates whether the document has been approved for use in claim adjudication.',
    `author_name` STRING COMMENT 'Name of the person or entity who authored or created the document.',
    `author_organization` STRING COMMENT 'Organization or company affiliation of the document author.',
    `confidential_flag` BOOLEAN COMMENT 'Indicates whether the document contains confidential or sensitive information.',
    `claim_document_description` STRING COMMENT 'Free-text description or summary of the document content and purpose.',
    `document_date` DATE COMMENT 'Date the document was originally created or issued by the author.',
    `document_number` STRING COMMENT 'Business-facing unique document number or reference code.',
    `document_status` STRING COMMENT 'Current lifecycle status of the document in the claims workflow. [ENUM-REF-CANDIDATE: pending_review|approved|rejected|archived|deleted|under_review|requires_resubmission — 7 candidates stripped; promote to reference product]',
    `document_subtype` STRING COMMENT 'Granular subtype or category within the primary document type.',
    `document_type` STRING COMMENT 'Classification of the document type supporting claim adjudication. [ENUM-REF-CANDIDATE: police_report|medical_record|repair_estimate|photo|video|dec_page|correspondence|legal_filing|subrogation_demand|witness_statement|appraisal|invoice — 12 candidates',
    `ecm_folder_path` STRING COMMENT 'Hierarchical folder or path location within the ECM repository.',
    `ecm_repository` STRING COMMENT 'Name of the ECM or document management system storing the file.. Valid values are `opentext|filenet|sharepoint|s3|azure_blob`',
    `file_extension` STRING COMMENT 'File format extension indicating the document type. [ENUM-REF-CANDIDATE: pdf|jpg|jpeg|png|tif|tiff|doc|docx|xls|xlsx|msg|eml — 12 candidates stripped; promote to reference product]',
    `file_name` STRING COMMENT 'Original file name of the uploaded or scanned document.',
    `file_size_bytes` BIGINT COMMENT 'Size of the document file in bytes for storage and retrieval tracking.',
    `legal_hold_flag` BOOLEAN COMMENT 'Indicates whether the document is under legal hold and cannot be destroyed.',
    `legal_hold_reason` STRING COMMENT 'Reason or case reference for the legal hold on the document.',
    `mime_type` STRING COMMENT 'MIME type of the document file for content handling and rendering.',
    `notes` STRING COMMENT 'Additional notes or comments regarding the document handling or review.',
    `ocr_processed_flag` BOOLEAN COMMENT 'Indicates whether the document has been processed through OCR for text extraction.',
    `ocr_text` STRING COMMENT 'Extracted text content from OCR processing for search and indexing.',
    `page_count` BIGINT COMMENT 'Number of pages in the document for indexing and review tracking.',
    `phi_flag` BOOLEAN COMMENT 'Indicates whether the document contains protected health information under HIPAA.',
    `pii_flag` BOOLEAN COMMENT 'Indicates whether the document contains personally identifiable information.',
    `received_date` DATE COMMENT 'Date the document was physically or electronically received by the insurer.',
    `redaction_required_flag` BOOLEAN COMMENT 'Indicates whether the document requires redaction before external sharing.',
    `retention_class` STRING COMMENT 'Document retention classification determining how long the document must be kept.. Valid values are `permanent|seven_year|ten_year|litigation_hold|regulatory_hold`',
    `retention_expiry_date` DATE COMMENT 'Date when the document retention period expires and may be eligible for destruction.',
    `reviewed_by_user_code` STRING COMMENT 'User identifier of the adjuster or examiner who reviewed the document.',
    `reviewed_date` DATE COMMENT 'Date the document was reviewed by an adjuster or examiner.',
    `reviewed_flag` BOOLEAN COMMENT 'Indicates whether the document has been reviewed by an adjuster or examiner.',
    `source_system_code` STRING COMMENT 'Unique identifier of the document in the originating source system.',
    `upload_date` DATE COMMENT 'Date the document was uploaded or received into the claims system.',
    `upload_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the document was uploaded or received.',
    `uploaded_by_party_code` BIGINT COMMENT 'Party identifier for the individual or organization that submitted the document.',
    `uploaded_by_user_code` STRING COMMENT 'User or system account that uploaded or submitted the document.',
    CONSTRAINT pk_claim_document PRIMARY KEY(`claim_document_id`)
) COMMENT 'Document attached to a claim: document type (police report/medical record/estimate/DEC page), source system, file reference (OpenText/FileNet), upload date, author, and retention class. Supports adjudication and litigation.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` (
    `litigation_id` BIGINT COMMENT 'Unique identifier for the litigation record.',
    `adjuster_id` BIGINT COMMENT 'Identifier of the litigation manager overseeing the case.',
    `assigned_adjuster_id` BIGINT COMMENT 'Identifier of the claims adjuster managing the litigation.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim under litigation.',
    `defense_counsel_service_vendor_id` BIGINT COMMENT 'Foreign key linking to claims.service_vendor. Business justification: Defense counsel (law firms) are service vendors engaged by the insurer to defend claims in litigation.',
    `plaintiff_attorney_id` BIGINT COMMENT 'Foreign key linking to claims.attorney. Business justification: Litigation involves a plaintiff attorney who represents the claimant in suit. One attorney can represent plaintiffs in many litigations; one litigation has one plaintiff attorney.',
    `plaintiff_claimant_id` BIGINT COMMENT 'Foreign key linking to claims.claimant. Business justification: In litigation, the plaintiff is typically a claimant asserting a loss under the policy (or the insured in a coverage dispute).',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Lawsuits trigger specific liability coverages with defense obligations. Required for defense cost allocation (inside vs outside limits), duty to defend determination, and',
    `suit_filed_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Litigation suit filed date determines litigation period for litigation rate analysis, defense cost tracking, and operational metrics.',
    `alae_incurred` DECIMAL(18,2) COMMENT 'Total allocated loss adjustment expense incurred for litigation defense and legal costs.',
    `alae_paid` DECIMAL(18,2) COMMENT 'Total allocated loss adjustment expense paid to date for litigation.',
    `appeal_filed_indicator` BOOLEAN COMMENT 'Flag indicating whether an appeal has been filed following verdict.',
    `bad_faith_indicator` BOOLEAN COMMENT 'Flag indicating whether the litigation involves bad faith allegations against the insurer.',
    `case_description` STRING COMMENT 'Detailed narrative description of the litigation case and allegations.',
    `court_county` STRING COMMENT 'County where the court is located.',
    `court_jurisdiction` STRING COMMENT 'Name and jurisdiction of the court where the suit is filed.',
    `court_state` STRING COMMENT 'State where the court is located.',
    `court_type` STRING COMMENT 'Type or level of court handling the litigation.. Valid values are `state|federal|appellate|supreme|municipal|district`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the litigation record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts.. Valid values are `^[A-Z]{3}$`',
    `discovery_deadline_date` DATE COMMENT 'Court-imposed deadline for completion of discovery phase.',
    `dismissal_date` DATE COMMENT 'Date the lawsuit was dismissed by the court.',
    `litigation_status` STRING COMMENT 'Current procedural status of the litigation case. [ENUM-REF-CANDIDATE: filed|discovery|mediation|trial|settled|verdict|dismissed|appealed — 8 candidates stripped; promote to reference product]',
    `litigation_type` STRING COMMENT 'Classification of the nature of the litigation.. Valid values are `bodily_injury|property_damage|bad_faith|coverage_dispute|subrogation|other`',
    `mediation_scheduled_date` DATE COMMENT 'Date scheduled for mediation or alternative dispute resolution.',
    `notes` STRING COMMENT 'Free-form notes and comments regarding the litigation case.',
    `plaintiff_demand_amount` DECIMAL(18,2) COMMENT 'Monetary amount demanded by the plaintiff in the lawsuit.',
    `punitive_damages_sought` BOOLEAN COMMENT 'Flag indicating whether plaintiff is seeking punitive damages.',
    `reserve_amount` DECIMAL(18,2) COMMENT 'Financial reserve set aside for potential litigation exposure.',
    `settlement_amount` DECIMAL(18,2) COMMENT 'Agreed settlement amount paid to resolve the litigation.',
    `settlement_date` DATE COMMENT 'Date the litigation was settled out of court.',
    `suit_filed_date` DATE COMMENT 'Date the lawsuit was filed with the court.',
    `suit_filed_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the lawsuit was filed with the court.',
    `suit_number` STRING COMMENT 'Court-assigned case or docket number for the lawsuit.',
    `trial_date` DATE COMMENT 'Scheduled or actual date of trial hearing.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the litigation record was last modified.',
    `verdict_amount` DECIMAL(18,2) COMMENT 'Court-awarded judgment amount in favor of plaintiff or defendant.',
    `verdict_date` DATE COMMENT 'Date the court issued a verdict or judgment.',
    CONSTRAINT pk_litigation PRIMARY KEY(`litigation_id`)
) COMMENT 'Litigation record for a claim in suit: plaintiff attorney, defense counsel, court jurisdiction, suit filed date, trial date, verdict amount, settlement amount, and litigation status. Tracks legal exposure and LAE spend.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` (
    `medical_bill_id` BIGINT COMMENT 'Unique identifier for the medical bill record.',
    `adjuster_id` BIGINT COMMENT 'Identifier of the claims examiner or nurse reviewer who evaluated the bill.',
    `bill_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Medical bill date determines billing period for medical cost trend analysis, bill review metrics, and operational reporting.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim for which this medical bill was submitted.',
    `claimant_id` BIGINT COMMENT 'Reference to the party who received the medical treatment.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Medical bill amounts (billed_amount, allowed_amount, paid_amount, reduction_amount) require currency reference for bill review, fee schedule application, and payment processing.',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Medical bills for auto injury claims must link to the vehicle for PIP/med pay coverage verification, per-person limit application, and liability determination.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Medical bill LOB determines fee schedule applicability (workers comp vs. auto injury), bill review protocols, and payment authorization limits.',
    `payment_transaction_id` BIGINT COMMENT 'Foreign key linking to reservespayments.payment_transaction. Business justification: Medical bill payment processing requires linking bill records to payment transactions for provider payment tracking, fee schedule compliance audits, Medicare Secondary',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Medical bills are paid under specific medical payments, PIP, or bodily injury coverages.',
    `service_vendor_id` BIGINT COMMENT 'Foreign key linking to claims.service_vendor. Business justification: Medical providers (hospitals, clinics, physicians, physical therapists) are service vendors in P&C claims (BI, PIP, MedPay, WC).',
    `admission_date` DATE COMMENT 'Date the patient was admitted to the facility for inpatient care, if applicable.',
    `allowed_amount` DECIMAL(15,2) COMMENT 'Maximum amount allowed per fee schedule or negotiated rate after bill review.',
    `bill_date` DATE COMMENT 'Date the medical bill was issued by the provider.',
    `bill_number` STRING COMMENT 'External bill number assigned by the medical provider or billing system.',
    `bill_received_date` DATE COMMENT 'Date the medical bill was received by the insurer for processing.',
    `bill_review_date` DATE COMMENT 'Date the medical bill review was completed by the insurer or third-party reviewer.',
    `bill_review_outcome` STRING COMMENT 'Result of the medical bill review process indicating approval, reduction, or denial.. Valid values are `approved|reduced|denied|pending|appealed|resubmitted`',
    `bill_type_code` STRING COMMENT 'Three-digit UB-04 type of bill code indicating facility type and care type.. Valid values are `^[0-9]{3}$`',
    `billed_amount` DECIMAL(15,2) COMMENT 'Total amount billed by the provider before any adjustments or reductions.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this medical bill record was first created in the system.',
    `denial_reason_code` STRING COMMENT 'Code indicating the reason for denial or reduction of the medical bill.',
    `denial_reason_description` STRING COMMENT 'Narrative explanation of why the medical bill was denied or reduced.',
    `diagnosis_code_primary` STRING COMMENT 'ICD-10 code representing the primary diagnosis for the medical treatment.',
    `diagnosis_code_secondary` STRING COMMENT 'ICD-10 code representing secondary or additional diagnoses.',
    `discharge_date` DATE COMMENT 'Date the patient was discharged from the facility, if applicable.',
    `fee_schedule_applied` STRING COMMENT 'Name or code of the fee schedule used to determine allowed amounts (e.g., Medicare, PPO, UCR).',
    `notes` STRING COMMENT 'Free-text notes or comments regarding the medical bill review or payment decision.',
    `paid_amount` DECIMAL(15,2) COMMENT 'Actual amount paid by the insurer to the provider or claimant.',
    `payment_date` DATE COMMENT 'Date the payment was issued to the provider or claimant.',
    `payment_method` STRING COMMENT 'Method used to remit payment to the provider (e.g., check, EFT, wire transfer).. Valid values are `check|eft|wire|card`',
    `payment_status` STRING COMMENT 'Current status of payment processing for this medical bill.. Valid values are `pending|approved|paid|denied|appealed`',
    `procedure_code` STRING COMMENT 'CPT or HCPCS code representing the medical procedure or service performed.',
    `procedure_description` STRING COMMENT 'Narrative description of the medical procedure or service performed.',
    `provider_npi` STRING COMMENT 'Ten-digit unique identifier for the healthcare provider who rendered services.. Valid values are `^[0-9]{10}$`',
    `reduction_amount` DECIMAL(15,2) COMMENT 'Amount reduced from billed to allowed due to fee schedule or bill review.',
    `revenue_code` STRING COMMENT 'Four-digit UB-04 revenue code classifying the type of service or accommodation.. Valid values are `^[0-9]{4}$`',
    `service_date_from` DATE COMMENT 'Start date of the medical service period covered by this bill.',
    `service_date_to` DATE COMMENT 'End date of the medical service period covered by this bill.',
    `service_units` DECIMAL(10,2) COMMENT 'Quantity of service units provided (e.g., days, visits, procedures).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this medical bill record was last modified.',
    CONSTRAINT pk_medical_bill PRIMARY KEY(`medical_bill_id`)
) COMMENT 'Medical bill record for BI, PIP, MedPay, or WC claims: provider NPI, bill date, CPT codes, billed amount, allowed amount, paid amount, bill review outcome, and fee schedule applied. Supports medical cost containment.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` (
    `damage_estimate_id` BIGINT COMMENT 'Unique identifier for the damage estimate record.',
    `approved_by_adjuster_id` BIGINT COMMENT 'Reference to the claims adjuster who reviewed and approved this estimate for payment authorization.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim for which this damage estimate was prepared.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Estimate amounts (rcv_amount, depreciation_amount, acv_amount, deductible_amount, net_payable_amount, salvage_value, labor/materials/equipment/tax amounts) require currency reference for',
    `estimate_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Damage estimate date determines estimate period for estimate cycle time analysis, estimator performance metrics, and operational reporting.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Property damage estimates must link to insured location for scope validation, replacement cost verification, building characteristics confirmation (construction type, year',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Auto damage estimates must link to the insured vehicle for VIN validation, stated value comparison, total loss threshold calculation, and vehicle characteristics verification.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Property damage estimates are scoped to specific coverages (dwelling, other structures, contents, ALE in homeowners).',
    `scheduled_item_id` BIGINT COMMENT 'Foreign key linking to riskexposure.scheduled_item. Business justification: Damage estimates for scheduled items must link to the item record for agreed value verification, appraisal comparison, and coverage limit validation.',
    `service_vendor_id` BIGINT COMMENT 'Foreign key linking to claims.service_vendor. Business justification: Damage estimates are often prepared by third-party vendors (body shops, restoration companies, independent adjusters).',
    `acv_amount` DECIMAL(15,2) COMMENT 'Net settlement value after depreciation, calculated as RCV minus depreciation, representing the pre-loss market value of the damaged property.',
    `approval_date` DATE COMMENT 'Date when the damage estimate was approved by the adjuster or claims manager, authorizing payment processing.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the damage estimate record was first created in the claims system.',
    `damage_estimate_status` STRING COMMENT 'Current workflow status of the damage estimate: draft in progress, submitted for review, approved for payment, rejected for revision, revised and resubmitted, or final.. Valid values are `draft|submitted|approved|rejected|revised|final`',
    `damage_type` STRING COMMENT 'High-level classification of the damaged asset: property (building/structure), vehicle (auto physical damage), equipment, or other.. Valid values are `property|vehicle|equipment|other`',
    `deductible_amount` DECIMAL(15,2) COMMENT 'Policy deductible applicable to this estimate, representing the insureds out-of-pocket responsibility before insurance payment.',
    `depreciation_amount` DECIMAL(15,2) COMMENT 'Calculated depreciation deducted from RCV based on age, condition, and useful life of damaged components, used to determine ACV.',
    `equipment_amount` DECIMAL(15,2) COMMENT 'Total estimated equipment rental or specialized tool cost component of the RCV, such as scaffolding, lifts, or drying equipment.',
    `estimate_date` DATE COMMENT 'Date when the damage estimate was prepared or finalized by the estimator.',
    `estimate_methodology` STRING COMMENT 'Method used to prepare the estimate: detailed on-site inspection, summary estimate, desk review of documentation, or photo-based remote estimate.. Valid values are `detailed|summary|desk_review|photo_estimate`',
    `estimate_number` STRING COMMENT 'Business identifier for the damage estimate, often used in external communications and vendor coordination.',
    `estimate_software` STRING COMMENT 'Name of the estimating software or platform used to prepare the estimate (e.g., Xactimate, Mitchell, CCC ONE), important for data integration and audit.',
    `estimate_type` STRING COMMENT 'Classification of the estimate in the claim lifecycle: initial assessment, supplemental for additional damage, revised for corrections, or final settlement estimate.. Valid values are `initial|supplemental|revised|final`',
    `estimator_license_number` STRING COMMENT 'Professional license or certification number of the estimator, required for appraisers and engineers in many jurisdictions.',
    `estimator_party_code` BIGINT COMMENT 'Reference to the party (individual or organization) who prepared the damage estimate.',
    `estimator_type` STRING COMMENT 'Category of the party who prepared the estimate: staff adjuster, independent adjuster (IA), third-party vendor, licensed appraiser, or structural engineer.. Valid values are `staff|independent_adjuster|vendor|appraiser|engineer`',
    `inspection_date` DATE COMMENT 'Date when the physical inspection of the damaged property or vehicle was conducted.',
    `labor_amount` DECIMAL(15,2) COMMENT 'Total estimated labor cost component of the RCV, representing the cost of skilled trades and technicians to perform repairs.',
    `line_item_count` BIGINT COMMENT 'Number of individual line items or components included in the detailed estimate, indicating scope and complexity.',
    `loss_description` STRING COMMENT 'Detailed narrative description of the damage observed during inspection, including scope, severity, and affected components.',
    `materials_amount` DECIMAL(15,2) COMMENT 'Total estimated materials and parts cost component of the RCV, representing the cost of replacement components and supplies.',
    `net_payable_amount` DECIMAL(15,2) COMMENT 'Final amount payable to the insured or claimant after applying depreciation, deductible, and any other adjustments.',
    `notes` STRING COMMENT 'Additional comments, observations, or special instructions related to the damage estimate, repair scope, or settlement considerations.',
    `overhead_profit_amount` DECIMAL(15,2) COMMENT 'Contractor overhead and profit allowance included in the RCV, typically applied when general contractor coordination is required.',
    `rcv_amount` DECIMAL(15,2) COMMENT 'Total estimated cost to repair or replace the damaged property with new materials of like kind and quality, without deduction for depreciation.',
    `rejection_reason` STRING COMMENT 'Explanation provided when an estimate is rejected, detailing discrepancies, missing information, or policy coverage issues requiring correction.',
    `repair_vs_total_decision` STRING COMMENT 'Determination of whether the damaged property should be repaired or declared a total loss based on cost-to-repair versus pre-loss value threshold.. Valid values are `repair|total_loss|pending`',
    `salvage_value` DECIMAL(15,2) COMMENT 'Estimated residual value of the damaged property if declared a total loss, representing the amount recoverable through salvage sale.',
    `tax_amount` DECIMAL(15,2) COMMENT 'Sales tax or other applicable taxes included in the estimate, based on jurisdiction and taxability of repair services and materials.',
    `total_loss_threshold_percentage` DECIMAL(5,2) COMMENT 'Percentage threshold used to determine total loss, typically when repair cost exceeds this percentage of pre-loss value (commonly 70-80 percent).',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp when the damage estimate record was last modified, supporting audit trail and version control.',
    CONSTRAINT pk_damage_estimate PRIMARY KEY(`damage_estimate_id`)
) COMMENT 'Property or vehicle damage estimate: estimator type (staff/IA/vendor), estimate date, RCV amount, ACV amount, depreciation, repair vs. total-loss decision, and vendor reference. Supports APD and property claim settlement.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` (
    `service_vendor_id` BIGINT COMMENT 'Unique identifier for the service vendor record.',
    `business_country_id` BIGINT COMMENT 'Foreign key linking to shared.country. Business justification: Service vendor business country determines international tax treatment, payment processing requirements, and regulatory compliance.',
    `business_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Service vendor business state determines licensing requirements, tax jurisdiction, and regulatory oversight.',
    `onboarding_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Service vendor onboarding date determines vendor lifecycle for vendor tenure analysis, performance tracking, and vendor management metrics.',
    `payee_id` BIGINT COMMENT 'Foreign key linking to reservespayments.payee. Business justification: Service vendors (repair shops, medical providers, attorneys) are payees receiving claim payments.',
    `average_cycle_time_days` DECIMAL(5,2) COMMENT 'Average number of days from assignment to completion for vendor services.',
    `background_check_date` DATE COMMENT 'Date of the most recent background check or compliance screening performed on the vendor.',
    `background_check_status` STRING COMMENT 'Result status of the most recent vendor background check or compliance screening.. Valid values are `passed|failed|pending|not_required`',
    `bank_account_number` STRING COMMENT 'Vendor bank account number for ACH or wire transfer payments.',
    `bank_routing_number` STRING COMMENT 'ABA routing number for the vendor bank account.. Valid values are `^d{9}$`',
    `business_address_line1` STRING COMMENT 'Primary street address line for the vendor business location.',
    `business_address_line2` STRING COMMENT 'Secondary address line for suite, unit, or building information.',
    `business_city` STRING COMMENT 'City where the vendor business is located.',
    `business_postal_code` STRING COMMENT 'ZIP or postal code for the vendor business address.. Valid values are `^d{5}(-d{4})?$`',
    `contract_effective_date` DATE COMMENT 'Effective start date of the current vendor service agreement.',
    `contract_expiration_date` DATE COMMENT 'Expiration date of the current vendor service agreement.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the vendor record was first created in the system.',
    `customer_satisfaction_score` DECIMAL(3,2) COMMENT 'Average customer satisfaction rating on a scale of 0.00 to 5.00 from claimant surveys.',
    `dba_name` STRING COMMENT 'Trade name or DBA name under which the vendor operates if different from legal name.',
    `insurance_certificate_number` STRING COMMENT 'Certificate number for the vendor general liability or professional liability insurance policy.',
    `insurance_coverage_amount` DECIMAL(15,2) COMMENT 'Total liability coverage amount in USD provided by the vendor insurance policy.',
    `insurance_expiration_date` DATE COMMENT 'Expiration date of the vendor liability insurance coverage.',
    `licensed_states` STRING COMMENT 'Comma-separated list of two-letter state codes where the vendor holds active licenses or approvals.',
    `notes` STRING COMMENT 'Free-text notes for special instructions, restrictions, or other relevant vendor information.',
    `onboarding_date` DATE COMMENT 'Date the vendor was onboarded and approved to receive claim assignments.',
    `payment_method` STRING COMMENT 'Preferred method of payment for vendor invoices.. Valid values are `ach|check|wire_transfer|virtual_card`',
    `payment_terms` STRING COMMENT 'Standard payment terms agreed upon with the vendor for invoice settlement.. Valid values are `net_15|net_30|net_45|net_60|due_on_receipt`',
    `performance_tier` STRING COMMENT 'Performance rating tier assigned based on quality metrics, cycle time, and customer satisfaction scores.. Valid values are `platinum|gold|silver|bronze|unrated`',
    `preferred_vendor_flag` BOOLEAN COMMENT 'Indicates whether the vendor is designated as a preferred provider in the network.',
    `primary_contact_email` STRING COMMENT 'Primary email address for vendor correspondence and assignment notifications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_contact_name` STRING COMMENT 'Full name of the primary business contact at the vendor organization.',
    `primary_contact_phone` STRING COMMENT 'Primary telephone number for reaching the vendor contact.. Valid values are `^+?1?d{10,15}$`',
    `primary_license_expiration_date` DATE COMMENT 'Expiration date of the vendor primary professional or business license.',
    `primary_license_number` STRING COMMENT 'Primary professional or business license number issued by the state regulatory authority.',
    `primary_license_state` STRING COMMENT 'State that issued the primary license for the vendor.. Valid values are `^[A-Z]{2}$`',
    `quality_score` DECIMAL(3,2) COMMENT 'Composite quality score on a scale of 0.00 to 5.00 based on work quality audits and customer feedback.',
    `service_radius_miles` BIGINT COMMENT 'Geographic service radius in miles from the vendor primary location.',
    `termination_date` DATE COMMENT 'Date the vendor relationship was terminated if no longer active.',
    `termination_reason` STRING COMMENT 'Reason for vendor termination such as performance issues, license revocation, or business closure.',
    `total_assignments_ytd` BIGINT COMMENT 'Total number of claim assignments sent to the vendor in the current calendar year.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the vendor record was last modified.',
    `vendor_name` STRING COMMENT 'Legal business name of the service vendor as registered with regulatory authorities.',
    `vendor_status` STRING COMMENT 'Current operational status of the vendor in the service network.. Valid values are `active|inactive|suspended|pending_approval|terminated`',
    `vendor_tin` STRING COMMENT 'Federal Tax Identification Number (TIN) or Employer Identification Number (EIN) for the vendor.. Valid values are `^d{2}-d{7}$|^d{9}$`',
    `vendor_type` STRING COMMENT 'Classification of the service type provided by the vendor in claims handling. [ENUM-REF-CANDIDATE',
    `w9_on_file_flag` BOOLEAN COMMENT 'Indicates whether a current IRS Form W-9 is on file for the vendor.',
    CONSTRAINT pk_service_vendor PRIMARY KEY(`service_vendor_id`)
) COMMENT 'Third-party service vendor engaged on a claim: vendor type (body shop/restoration/IA/attorney/IME/nurse case manager), TIN, license, preferred-vendor flag, state approvals, and performance tier. SSOT for claim vendor master.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` (
    `claim_status_history_id` BIGINT COMMENT 'Unique identifier for each claim status transition record in the immutable audit log.',
    `assigned_adjuster_id` BIGINT COMMENT 'Reference to the claims adjuster assigned to the claim at the time of this status transition.',
    `claim_id` BIGINT COMMENT 'Reference to the claim that experienced this status transition.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Status history financial snapshots (reserve_amount, paid_amount, incurred_amount) require currency reference for claim lifecycle analysis, reserve development tracking, and audit trail of',
    `examiner_adjuster_id` BIGINT COMMENT 'Reference to the claims examiner responsible for oversight at the time of this status transition.',
    `transition_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Claim status transition date determines transition period for status duration analysis, workflow efficiency metrics, and operational reporting.',
    `acting_user_code` STRING COMMENT 'System identifier of the user or automated process that initiated this status transition.',
    `acting_user_name` STRING COMMENT 'Full name of the user who performed the status change, captured for audit and regulatory reporting.',
    `acting_user_role` STRING COMMENT 'Business role or job function of the user at the time of the status transition, such as adjuster, examiner, or supervisor.',
    `approval_required_indicator` BOOLEAN COMMENT 'Flag indicating whether this status transition required supervisory or management approval per authority limits.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when supervisory approval was granted for this status transition.',
    `approval_user_code` STRING COMMENT 'System identifier of the supervisor or manager who approved this status transition, if approval was required.',
    `comments` STRING COMMENT 'Free-text notes or comments entered by the user at the time of the status change, providing additional context for the transition.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this status history record was first inserted into the data warehouse, used for data lineage and audit purposes.',
    `effective_date` DATE COMMENT 'Business-effective date when the new status became active, which may differ from the system transition timestamp for backdated adjustments.',
    `incurred_amount` DECIMAL(15,2) COMMENT 'Total incurred loss amount (paid plus outstanding reserve) at the time of this status transition.',
    `new_status` STRING COMMENT 'The claim status immediately after this transition was applied. [ENUM-REF-CANDIDATE: open|assigned|investigating|pending_info|approved|denied|closed|reopened — 8 candidates stripped; promote to reference product]',
    `notification_sent_indicator` BOOLEAN COMMENT 'Flag indicating whether automated notifications were sent to stakeholders as a result of this status change.',
    `notification_timestamp` TIMESTAMP COMMENT 'Date and time when stakeholder notifications were dispatched following this status transition.',
    `paid_amount` DECIMAL(15,2) COMMENT 'Cumulative paid loss amount at the time of this status transition, used for loss development tracking.',
    `prior_status` STRING COMMENT 'The claim status immediately before this transition occurred. [ENUM-REF-CANDIDATE: open|assigned|investigating|pending_info|approved|denied|closed|reopened — 8 candidates stripped; promote to reference product]',
    `regulatory_reportable_indicator` BOOLEAN COMMENT 'Flag indicating whether this status transition must be included in regulatory reporting to state Departments of Insurance or NAIC.',
    `reserve_amount` DECIMAL(15,2) COMMENT 'Total outstanding case reserve amount at the time of this status transition, captured for reserve development analysis.',
    `sequence_number` BIGINT COMMENT 'Ordinal position of this status change within the claims lifecycle, starting at 1.',
    `sla_actual_hours` DECIMAL(10,2) COMMENT 'Actual number of hours the claim remained in the prior status before this transition, used for SLA compliance reporting.',
    `sla_compliance_indicator` BOOLEAN COMMENT 'Flag indicating whether the status transition met the defined SLA target for the prior status stage.',
    `sla_target_hours` DECIMAL(10,2) COMMENT 'Number of hours allowed for this status stage per service level agreement, used for compliance monitoring.',
    `system_source` STRING COMMENT 'Name of the source system or application that recorded this status transition, such as ClaimCenter or Duck Creek Claims.',
    `transaction_code` STRING COMMENT 'Unique transaction identifier from the source system that created this status history record, used for reconciliation and traceability.',
    `transition_reason_code` STRING COMMENT 'Standardized code indicating why the status change occurred, aligned with business rules and regulatory requirements.',
    `transition_reason_description` STRING COMMENT 'Detailed explanation of the business rationale or event that triggered this status change.',
    `transition_source` STRING COMMENT 'Indicates whether the status change was initiated manually by a user, automatically by a workflow rule, or via system integration.. Valid values are `manual|automated|workflow|api|batch`',
    `transition_timestamp` TIMESTAMP COMMENT 'Precise date and time when the status change was recorded in the system, used for SLA compliance and audit trails.',
    `workflow_step_code` STRING COMMENT 'Identifier of the workflow step or business process stage that triggered this status transition, if applicable.',
    CONSTRAINT pk_claim_status_history PRIMARY KEY(`claim_status_history_id`)
) COMMENT 'Immutable log of every claim status transition: prior status, new status, transition reason, effective timestamp, and acting user. Supports SLA compliance, adjudication audit, and regulatory reporting.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` (
    `fraud_referral_id` BIGINT COMMENT 'Unique identifier for the fraud referral record.',
    `adjuster_id` BIGINT COMMENT 'Identifier of the SIU investigator assigned to conduct the fraud investigation.',
    `claim_id` BIGINT COMMENT 'Identifier of the claim being referred for fraud investigation.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Fraud amounts (estimated_fraud_amount, confirmed_fraud_amount, recovery_amount) require currency reference for fraud investigation, SIU reporting, law enforcement referrals, and recovery',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Fraud investigations for property claims must link to the location for scene investigation, occupancy verification, ownership validation, and prior loss history analysis.',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Fraud investigations for auto claims must link to the vehicle for VIN verification, ownership validation, prior damage investigation, and salvage history check.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Fraud investigations often focus on specific coverage misrepresentation or material concealment affecting a particular coverage.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key linking to producers.producers_producer. Business justification: Fraud investigations examine producer involvement in premium diversion, fictitious policies, staged losses, and collusion schemes.',
    `referral_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Fraud referral date determines referral period for fraud detection rate analysis, investigation cycle time metrics, and SIU operational reporting.',
    `scheduled_item_id` BIGINT COMMENT 'Foreign key linking to riskexposure.scheduled_item. Business justification: Fraud investigations for scheduled item claims must link to the item for appraisal validation, ownership verification, purchase documentation review, and serial number',
    `assigned_date` DATE COMMENT 'Date the fraud referral was assigned to an SIU investigator.',
    `confirmed_fraud_amount` DECIMAL(15,2) COMMENT 'Actual monetary value of the fraud substantiated through investigation, representing the loss prevented or identified.',
    `created_by_user_code` STRING COMMENT 'System user identifier of the person who created the fraud referral record.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the fraud referral record was first created in the database.',
    `denial_reason_code` STRING COMMENT 'Standardized code representing the specific fraud-related reason for recommending claim denial.',
    `denial_recommended_flag` BOOLEAN COMMENT 'Indicator whether the SIU investigation recommends denying the claim based on fraud findings.',
    `estimated_fraud_amount` DECIMAL(15,2) COMMENT 'Initial estimated monetary value of the suspected fraudulent claim or loss at the time of referral.',
    `fraud_confirmed_flag` BOOLEAN COMMENT 'Indicator whether fraud was definitively confirmed through the investigation.',
    `fraud_indicator_code` STRING COMMENT 'Standardized code representing the specific red flag or suspicious activity pattern that triggered the referral.',
    `fraud_indicator_description` STRING COMMENT 'Detailed explanation of the suspicious activity or red flags that prompted the fraud referral.',
    `fraud_referral_status` STRING COMMENT 'Current state of the fraud investigation workflow.. Valid values are `pending|assigned|under_investigation|suspended|closed`',
    `fraud_type` STRING COMMENT 'Classification of the suspected fraud based on severity and intent.. Valid values are `hard_fraud|soft_fraud|opportunistic|organized|internal|external`',
    `investigation_close_date` DATE COMMENT 'Date the fraud investigation was formally concluded and the case closed.',
    `investigation_notes` STRING COMMENT 'Comprehensive narrative documenting investigation activities, interviews conducted, evidence gathered, and findings.',
    `investigation_start_date` DATE COMMENT 'Date the SIU investigator formally began the fraud investigation activities.',
    `law_enforcement_agency` STRING COMMENT 'Name of the law enforcement or prosecutorial agency to which the fraud case was referred.',
    `law_enforcement_case_number` STRING COMMENT 'Case or docket number assigned by the law enforcement agency for tracking the criminal investigation.',
    `law_enforcement_referral_date` DATE COMMENT 'Date the fraud case was formally referred to law enforcement authorities.',
    `law_enforcement_referral_flag` BOOLEAN COMMENT 'Indicator whether the case was referred to law enforcement or prosecutorial authorities.',
    `nicb_referral_date` DATE COMMENT 'Date the fraud case was submitted to the National Insurance Crime Bureau.',
    `nicb_referral_flag` BOOLEAN COMMENT 'Indicator whether the fraud case was reported to the National Insurance Crime Bureau for industry-wide tracking.',
    `outcome` STRING COMMENT 'Final determination of the fraud investigation indicating whether fraud was substantiated.. Valid values are `confirmed_fraud|unfounded|pending|insufficient_evidence|referred_to_law_enforcement`',
    `outcome_date` DATE COMMENT 'Date the final investigation outcome was determined and documented.',
    `outcome_description` STRING COMMENT 'Detailed narrative explaining the investigation findings, evidence reviewed, and rationale for the outcome determination.',
    `policy_cancellation_recommended_flag` BOOLEAN COMMENT 'Indicator whether the SIU investigation recommends canceling the policy due to material misrepresentation or fraud.',
    `priority` STRING COMMENT 'Urgency level assigned to the fraud referral based on severity, potential loss amount, and risk factors.. Valid values are `critical|high|medium|low`',
    `recovery_amount` DECIMAL(15,2) COMMENT 'Total monetary amount recovered from the fraudulent party through restitution, subrogation, or legal action.',
    `recovery_date` DATE COMMENT 'Date the recovery amount was received or collected from the fraudulent party.',
    `referral_date` DATE COMMENT 'Date the claim was referred to the Special Investigation Unit (SIU) for fraud investigation.',
    `referral_number` STRING COMMENT 'Business-facing unique number assigned to the fraud referral for tracking and communication purposes.',
    `referral_reason` STRING COMMENT 'Narrative explanation of why the claim was referred for fraud investigation, including specific concerns and evidence.',
    `referral_source` STRING COMMENT 'Origin of the fraud referral indicating who or what initiated the investigation request. [ENUM-REF-CANDIDATE: adjuster|examiner|underwriter|producer|automated_system|tip_line|external_agency|data_analytics — 8 candidates stripped; promote to reference',
    `referral_timestamp` TIMESTAMP COMMENT 'Precise date and time the fraud referral was created in the system.',
    `referring_party_code` BIGINT COMMENT 'Identifier of the person or entity who initiated the fraud referral.',
    `referring_user_code` STRING COMMENT 'System user identifier of the employee who submitted the fraud referral.',
    `state_fraud_bureau_referral_date` DATE COMMENT 'Date the fraud case was submitted to the state insurance fraud bureau.',
    `state_fraud_bureau_referral_flag` BOOLEAN COMMENT 'Indicator whether the fraud case was reported to the state insurance fraud bureau as required by statute.',
    `updated_by_user_code` STRING COMMENT 'System user identifier of the person who last modified the fraud referral record.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp when the fraud referral record was last modified.',
    CONSTRAINT pk_fraud_referral PRIMARY KEY(`fraud_referral_id`)
) COMMENT 'Operational SIU fraud referral record for a claim: referral date, referral reason, SIU investigator assigned, investigation status, outcome (confirmed fraud/unfounded/pending), and recovery amount. Supports SIU workflow.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` (
    `service_assignment_id` BIGINT COMMENT 'Unique identifier for this service assignment record. Primary key.',
    `claim_id` BIGINT COMMENT 'Foreign key linking to the claim on which the vendor service was engaged.',
    `service_vendor_id` BIGINT COMMENT 'Foreign key linking to the service vendor engaged for this assignment.',
    `assignment_date` DATE COMMENT 'Date the vendor was assigned to the claim.',
    `assignment_status` STRING COMMENT 'Current lifecycle status of the vendor assignment.',
    `assignment_type` STRING COMMENT 'Type of service the vendor was engaged to provide on this claim.',
    `completion_date` DATE COMMENT 'Date the vendor completed their service on the claim.',
    `invoice_amount` DECIMAL(15,2) COMMENT 'Total amount invoiced by the vendor for services rendered on this assignment.',
    `performance_rating` DECIMAL(3,2) COMMENT 'Performance rating assigned to the vendor for this specific assignment on a scale of 0.00 to 5.00.',
    `sla_compliance_flag` BOOLEAN COMMENT 'Indicates whether the vendor met service level agreement requirements for this assignment.',
    CONSTRAINT pk_service_assignment PRIMARY KEY(`service_assignment_id`)
) COMMENT 'Association between claim and service_vendor capturing each engagement of a third-party vendor on a claim. Tracks assignment lifecycle, performance, and cost for vendor management and regulatory reporting..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` (
    `claim_peril_causation_id` BIGINT COMMENT 'Unique identifier for this claim-peril causation record',
    `claim_id` BIGINT COMMENT 'Foreign key linking to the claim for which peril causation is being determined',
    `coverage_peril_id` BIGINT COMMENT 'Foreign key linking to the peril that contributed to this claim loss event',
    `determined_by_adjuster_id` BIGINT COMMENT 'Reference to the adjuster who made the peril causation determination',
    `adjuster_notes` STRING COMMENT 'Narrative notes from adjuster explaining causation determination and coverage analysis',
    `causation_sequence_order` BIGINT COMMENT 'Order in which this peril occurred in the chain of causation for sequential loss events',
    `claim_peril_causation_status` STRING COMMENT 'Current status of the peril causation determination in the adjudication workflow',
    `concurrent_causation_flag` BOOLEAN COMMENT 'Indicates whether this peril operated concurrently with other perils to cause loss',
    `coverage_applicable_flag` BOOLEAN COMMENT 'Indicates whether coverage applies for this peril based on policy terms and exclusions',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this causation record was created in the claims system',
    `exclusion_applied_flag` BOOLEAN COMMENT 'Indicates whether a policy exclusion was applied to deny coverage for this peril',
    `exclusion_reason` STRING COMMENT 'Specific policy exclusion clause or reason coverage was denied for this peril',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this causation record was last modified',
    `loss_cause_determination_date` DATE COMMENT 'Date when the adjuster determined this peril contributed to the loss event',
    `peril_contribution_percentage` DECIMAL(5,2) COMMENT 'Percentage of total loss attributed to this peril for apportionment purposes',
    `proximate_cause_flag` BOOLEAN COMMENT 'Indicates whether this peril is the proximate cause of loss under coverage doctrine',
    `subrogation_target_flag` BOOLEAN COMMENT 'Indicates whether this peril causation supports subrogation against a responsible third party',
    CONSTRAINT pk_claim_peril_causation PRIMARY KEY(`claim_peril_causation_id`)
) COMMENT 'Association between claim and peril capturing which perils contributed to a loss event. Records proximate vs concurrent cause determinations, contribution percentages for apportionment, and causation analysis required for coverage application and';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` (
    `tpa_id` BIGINT COMMENT 'Primary key for tpa',
    `address_line_1` STRING COMMENT 'First line of the TPA physical business address including street number and name.',
    `address_line_2` STRING COMMENT 'Second line of the TPA physical business address for suite, floor, or building details.',
    `audit_frequency` STRING COMMENT 'Scheduled frequency at which the insurer conducts performance and compliance audits of the TPA.',
    `average_claim_cycle_time_days` BIGINT COMMENT 'Average number of days the TPA takes to close a claim from first notice of loss to final settlement.',
    `city` STRING COMMENT 'City name where the TPA business is located.',
    `claims_handling_authority_limit` DECIMAL(18,2) COMMENT 'Maximum monetary amount the TPA is authorized to settle claims without escalation.',
    `contract_effective_date` DATE COMMENT 'Date when the TPA service contract becomes effective and binding.',
    `contract_expiration_date` DATE COMMENT 'Date when the TPA service contract expires or terminates.',
    `country_code` STRING COMMENT 'Three-letter ISO country code where the TPA business is domiciled.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the TPA record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code for all monetary amounts associated with the TPA.',
    `data_exchange_method` STRING COMMENT 'Primary technical method used to exchange claim data between the insurer and TPA systems.',
    `fee_structure_type` STRING COMMENT 'Pricing model used to compensate the TPA for claims administration services.',
    `last_audit_date` DATE COMMENT 'Date of the most recent performance or compliance audit conducted on the TPA.',
    `license_expiration_date` DATE COMMENT 'Date when the TPA regulatory license expires and requires renewal.',
    `license_number` STRING COMMENT 'State or regulatory license number authorizing the TPA to administer insurance claims.',
    `license_state` STRING COMMENT 'State or jurisdiction that issued the TPA operating license.',
    `tpa_name` STRING COMMENT 'Legal business name of the third-party administrator organization.',
    `next_audit_date` DATE COMMENT 'Scheduled date for the next performance or compliance audit of the TPA.',
    `notes` STRING COMMENT 'Free-form text field for additional comments, special instructions, or historical context about the TPA relationship.',
    `payment_processing_enabled` BOOLEAN COMMENT 'Indicates whether the TPA is authorized to process and issue claim payments on behalf of the insurer.',
    `performance_rating` STRING COMMENT 'Current performance evaluation rating of the TPA based on service quality metrics.',
    `postal_code` STRING COMMENT 'Postal or ZIP code for the TPA business address.',
    `primary_contact_email` STRING COMMENT 'Email address of the primary business contact at the TPA for operational communication.',
    `primary_contact_name` STRING COMMENT 'Full name of the primary business contact person at the TPA organization.',
    `primary_contact_phone` STRING COMMENT 'Primary telephone number for reaching the TPA business contact.',
    `reserve_setting_authority` BOOLEAN COMMENT 'Indicates whether the TPA has authority to establish and adjust loss reserves.',
    `service_scope_description` STRING COMMENT 'Detailed description of the claims administration and related services provided by the TPA.',
    `sla_response_time_hours` BIGINT COMMENT 'Contractual maximum hours the TPA has to respond to new claim assignments or inquiries.',
    `specialization_lines` STRING COMMENT 'Comma-separated list of insurance lines of business the TPA specializes in handling.',
    `standard_fee_amount` DECIMAL(18,2) COMMENT 'Standard fee charged by the TPA per claim or per period based on the fee structure type.',
    `state_province` STRING COMMENT 'State or province code where the TPA business is located.',
    `tpa_status` STRING COMMENT 'Current operational status of the TPA relationship.',
    `tax_identification_number` STRING COMMENT 'Federal tax identification number or employer identification number for the TPA entity.',
    `tpa_code` STRING COMMENT 'Unique alphanumeric business identifier code assigned to the TPA for operational reference.',
    `tpa_type` STRING COMMENT 'Classification of the TPA based on the scope of services provided.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when the TPA record was last modified in the system.',
    `website_url` STRING COMMENT 'Public website address of the TPA organization.',
    CONSTRAINT pk_tpa PRIMARY KEY(`tpa_id`)
) COMMENT 'Master reference table for tpa. Referenced by tpa_id.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` (
    `attorney_id` BIGINT COMMENT 'Primary key for attorney',
    `address_line_1` STRING COMMENT 'Primary street address line for the attorney office location.',
    `address_line_2` STRING COMMENT 'Secondary address line for suite, floor, or building information.',
    `attorney_type` STRING COMMENT 'Classification of the attorney role in relation to the insurer: defense counsel, plaintiff counsel, coverage counsel, panel attorney, or independent.',
    `bar_admission_date` DATE COMMENT 'Date when the attorney was admitted to the bar and licensed to practice law.',
    `bar_number` STRING COMMENT 'Unique bar association registration number issued to the attorney by the state licensing authority.',
    `bar_state` STRING COMMENT 'State or jurisdiction where the attorney is admitted to practice law.',
    `city` STRING COMMENT 'City where the attorney office is located.',
    `country_code` STRING COMMENT 'Three-letter ISO country code for the attorney office location.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the attorney record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code for the attorney billing rate.',
    `email_address` STRING COMMENT 'Primary email address for professional communication with the attorney.',
    `fax_number` STRING COMMENT 'Fax number for transmitting legal documents to the attorney.',
    `first_name` STRING COMMENT 'First or given name of the attorney.',
    `full_name` STRING COMMENT 'Complete legal name of the attorney as registered with the bar association.',
    `hourly_rate` DECIMAL(15,2) COMMENT 'Standard hourly billing rate charged by the attorney for legal services.',
    `last_name` STRING COMMENT 'Last name or surname of the attorney.',
    `law_firm_name` STRING COMMENT 'Name of the law firm or legal practice with which the attorney is affiliated.',
    `middle_name` STRING COMMENT 'Middle name or initial of the attorney.',
    `mobile_number` STRING COMMENT 'Mobile phone number for urgent or after-hours contact with the attorney.',
    `notes` STRING COMMENT 'Free-form notes regarding the attorney relationship, performance, or special handling instructions.',
    `panel_effective_date` DATE COMMENT 'Date when the attorney was added to the insurer defense panel.',
    `panel_member_flag` BOOLEAN COMMENT 'Indicates whether the attorney is a member of the insurer approved defense panel.',
    `panel_termination_date` DATE COMMENT 'Date when the attorney was removed from the insurer defense panel.',
    `phone_number` STRING COMMENT 'Primary business phone number for contacting the attorney.',
    `postal_code` STRING COMMENT 'Postal or ZIP code for the attorney office location.',
    `preferred_contact_method` STRING COMMENT 'Preferred method for contacting the attorney for routine communications.',
    `specialty` STRING COMMENT 'Primary area of legal specialization such as personal injury, workers compensation, property damage, liability, or subrogation.',
    `state_province` STRING COMMENT 'State or province where the attorney office is located and where the attorney is licensed to practice.',
    `attorney_status` STRING COMMENT 'Current status of the attorney in relation to the insurer and bar association standing.',
    `suffix` STRING COMMENT 'Professional or generational suffix appended to the attorney name.',
    `tax_number` STRING COMMENT 'Tax identification number for the attorney or law firm used for payment processing and tax reporting.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the attorney record was last modified.',
    CONSTRAINT pk_attorney PRIMARY KEY(`attorney_id`)
) COMMENT 'Master reference table for attorney. Referenced by attorney_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_assigned_adjuster_id` FOREIGN KEY (`assigned_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_claimant_id` FOREIGN KEY (`claimant_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claimant`(`claimant_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_claim_adjuster_id` FOREIGN KEY (`claim_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_claim_examiner_adjuster_id` FOREIGN KEY (`claim_examiner_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_tpa_id` FOREIGN KEY (`tpa_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`tpa`(`tpa_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ADD CONSTRAINT `fk_claims_claimant_attorney_id` FOREIGN KEY (`attorney_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`attorney`(`attorney_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ADD CONSTRAINT `fk_claims_claimant_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ADD CONSTRAINT `fk_claims_claim_coverage_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ADD CONSTRAINT `fk_claims_claim_coverage_coverage_adjuster_id` FOREIGN KEY (`coverage_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ADD CONSTRAINT `fk_claims_claims_loss_reserve_claim_coverage_id` FOREIGN KEY (`claim_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim_coverage`(`claim_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ADD CONSTRAINT `fk_claims_claims_loss_reserve_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ADD CONSTRAINT `fk_claims_claims_reserve_transaction_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ADD CONSTRAINT `fk_claims_claims_reserve_transaction_claims_adjuster_id` FOREIGN KEY (`claims_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ADD CONSTRAINT `fk_claims_claims_reserve_transaction_claims_supervisor_adjuster_id` FOREIGN KEY (`claims_supervisor_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ADD CONSTRAINT `fk_claims_claims_reserve_transaction_reversed_transaction_claims_reserve_transaction_id` FOREIGN KEY (`reversed_transaction_claims_reserve_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction`(`claims_reserve_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ADD CONSTRAINT `fk_claims_claims_claim_payment_claim_coverage_id` FOREIGN KEY (`claim_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim_coverage`(`claim_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ADD CONSTRAINT `fk_claims_claims_claim_payment_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ADD CONSTRAINT `fk_claims_claims_claim_payment_claims_reserve_transaction_id` FOREIGN KEY (`claims_reserve_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction`(`claims_reserve_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ADD CONSTRAINT `fk_claims_disbursement_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ADD CONSTRAINT `fk_claims_adjuster_supervisor_adjuster_id` FOREIGN KEY (`supervisor_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ADD CONSTRAINT `fk_claims_adjuster_tpa_id` FOREIGN KEY (`tpa_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`tpa`(`tpa_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ADD CONSTRAINT `fk_claims_adjuster_assignment_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ADD CONSTRAINT `fk_claims_adjuster_assignment_primary_adjuster_id` FOREIGN KEY (`primary_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ADD CONSTRAINT `fk_claims_claim_note_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ADD CONSTRAINT `fk_claims_claim_note_claim_coverage_id` FOREIGN KEY (`claim_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim_coverage`(`claim_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ADD CONSTRAINT `fk_claims_claim_document_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ADD CONSTRAINT `fk_claims_claim_document_fnol_id` FOREIGN KEY (`fnol_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`fnol`(`fnol_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ADD CONSTRAINT `fk_claims_litigation_adjuster_id` FOREIGN KEY (`adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ADD CONSTRAINT `fk_claims_litigation_assigned_adjuster_id` FOREIGN KEY (`assigned_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ADD CONSTRAINT `fk_claims_litigation_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ADD CONSTRAINT `fk_claims_litigation_defense_counsel_service_vendor_id` FOREIGN KEY (`defense_counsel_service_vendor_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`service_vendor`(`service_vendor_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ADD CONSTRAINT `fk_claims_litigation_plaintiff_attorney_id` FOREIGN KEY (`plaintiff_attorney_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`attorney`(`attorney_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ADD CONSTRAINT `fk_claims_litigation_plaintiff_claimant_id` FOREIGN KEY (`plaintiff_claimant_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claimant`(`claimant_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ADD CONSTRAINT `fk_claims_medical_bill_adjuster_id` FOREIGN KEY (`adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ADD CONSTRAINT `fk_claims_medical_bill_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ADD CONSTRAINT `fk_claims_medical_bill_claimant_id` FOREIGN KEY (`claimant_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claimant`(`claimant_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ADD CONSTRAINT `fk_claims_medical_bill_service_vendor_id` FOREIGN KEY (`service_vendor_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`service_vendor`(`service_vendor_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ADD CONSTRAINT `fk_claims_damage_estimate_approved_by_adjuster_id` FOREIGN KEY (`approved_by_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ADD CONSTRAINT `fk_claims_damage_estimate_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ADD CONSTRAINT `fk_claims_damage_estimate_service_vendor_id` FOREIGN KEY (`service_vendor_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`service_vendor`(`service_vendor_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ADD CONSTRAINT `fk_claims_claim_status_history_assigned_adjuster_id` FOREIGN KEY (`assigned_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ADD CONSTRAINT `fk_claims_claim_status_history_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ADD CONSTRAINT `fk_claims_claim_status_history_examiner_adjuster_id` FOREIGN KEY (`examiner_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ADD CONSTRAINT `fk_claims_fraud_referral_adjuster_id` FOREIGN KEY (`adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ADD CONSTRAINT `fk_claims_fraud_referral_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` ADD CONSTRAINT `fk_claims_service_assignment_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` ADD CONSTRAINT `fk_claims_service_assignment_service_vendor_id` FOREIGN KEY (`service_vendor_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`service_vendor`(`service_vendor_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ADD CONSTRAINT `fk_claims_claim_peril_causation_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ADD CONSTRAINT `fk_claims_claim_peril_causation_determined_by_adjuster_id` FOREIGN KEY (`determined_by_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_v499`.`claims` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_v499`.`claims` SET TAGS ('dbx_domain' = 'claims');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` SET TAGS ('dbx_subdomain' = 'loss_intake');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `fnol_id` SET TAGS ('dbx_business_glossary_term' = 'First Notice of Loss (FNOL) ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `assigned_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Adjuster ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `claimant_id` SET TAGS ('dbx_business_glossary_term' = 'Claimant Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `dol_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Dol Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_country_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Country Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_state_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Location State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Reporting Producer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `cat_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `claimant_email` SET TAGS ('dbx_business_glossary_term' = 'Claimant Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `claimant_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `claimant_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `claimant_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `claimant_phone` SET TAGS ('dbx_business_glossary_term' = 'Claimant Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `claimant_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `claimant_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `dol` SET TAGS ('dbx_business_glossary_term' = 'Date of Loss (DOL)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `dol_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Date of Loss (DOL) Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `estimated_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Estimated Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `fnol_status` SET TAGS ('dbx_business_glossary_term' = 'First Notice of Loss (FNOL) Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `fnol_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|assigned|converted|closed');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `fraud_indicator` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `injury_indicator` SET TAGS ('dbx_business_glossary_term' = 'Injury Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `intake_channel` SET TAGS ('dbx_business_glossary_term' = 'Intake Channel');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `intake_channel` SET TAGS ('dbx_value_regex' = 'phone|web|mobile_app|email|agent|in_person');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `intake_user_code` SET TAGS ('dbx_business_glossary_term' = 'Intake User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `intake_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `intake_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `is_cat_loss` SET TAGS ('dbx_business_glossary_term' = 'Is Catastrophe (CAT) Loss');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `loss_description` SET TAGS ('dbx_business_glossary_term' = 'Loss Description');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_latitude` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Latitude');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_longitude` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Longitude');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `loss_location_longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'First Notice of Loss (FNOL) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `police_report_filed` SET TAGS ('dbx_business_glossary_term' = 'Police Report Filed');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `police_report_number` SET TAGS ('dbx_business_glossary_term' = 'Police Report Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `property_damage_indicator` SET TAGS ('dbx_business_glossary_term' = 'Property Damage Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `property_damage_indicator` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `property_damage_indicator` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `reported_date` SET TAGS ('dbx_business_glossary_term' = 'Reported Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `reported_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Reported Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `reporter_name` SET TAGS ('dbx_business_glossary_term' = 'Reporter Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `reporter_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `reporter_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `reporter_party_code` SET TAGS ('dbx_business_glossary_term' = 'Reporter Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `reporter_relationship` SET TAGS ('dbx_business_glossary_term' = 'Reporter Relationship');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `reporter_relationship` SET TAGS ('dbx_value_regex' = 'insured|agent|broker|attorney|third_party|other');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ALTER COLUMN `witness_present` SET TAGS ('dbx_business_glossary_term' = 'Witness Present');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` SET TAGS ('dbx_subdomain' = 'loss_intake');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `claim_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `claim_examiner_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Examiner Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `claimant_party_id` SET TAGS ('dbx_business_glossary_term' = 'Claimant Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `dol_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Dol Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `loss_location_country_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Country Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `loss_location_state_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Location State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `policy_insured_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Writing Producer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `scheduled_item_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Item Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `tpa_id` SET TAGS ('dbx_business_glossary_term' = 'Tpa Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `alae_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Allocated Loss Adjustment Expense (ALAE) Paid Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `alae_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Allocated Loss Adjustment Expense (ALAE) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `cat_indicator` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `claim_status` SET TAGS ('dbx_business_glossary_term' = 'Claim Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `claim_status` SET TAGS ('dbx_value_regex' = 'open|closed|reopened|pending|denied|withdrawn');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `claim_type` SET TAGS ('dbx_business_glossary_term' = 'Claim Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `claim_type` SET TAGS ('dbx_value_regex' = 'first_party|third_party|subrogation|salvage');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `closed_date` SET TAGS ('dbx_business_glossary_term' = 'Closed Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `closed_reason` SET TAGS ('dbx_business_glossary_term' = 'Closed Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `dol` SET TAGS ('dbx_business_glossary_term' = 'Date of Loss (DOL)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `fnol_date` SET TAGS ('dbx_business_glossary_term' = 'First Notice of Loss (FNOL) Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `fnol_timestamp` SET TAGS ('dbx_business_glossary_term' = 'First Notice of Loss (FNOL) Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `fraud_indicator` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `litigation_indicator` SET TAGS ('dbx_business_glossary_term' = 'Litigation Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `loss_cause` SET TAGS ('dbx_business_glossary_term' = 'Loss Cause');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `loss_description` SET TAGS ('dbx_business_glossary_term' = 'Loss Description');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `loss_time` SET TAGS ('dbx_business_glossary_term' = 'Loss Time');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Claim Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{8,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `outstanding_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Case Reserve (OCR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `paid_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `reopened_count` SET TAGS ('dbx_business_glossary_term' = 'Reopened Count');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `reported_by` SET TAGS ('dbx_business_glossary_term' = 'Reported By');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `salvage_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Salvage Value Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `salvage_value_amount` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `salvage_value_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `subrogation_potential_amount` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Potential Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `subrogation_recovered_amount` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Recovered Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ALTER COLUMN `total_incurred_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Incurred Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` SET TAGS ('dbx_subdomain' = 'loss_intake');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `claimant_id` SET TAGS ('dbx_business_glossary_term' = 'Claimant Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `attorney_id` SET TAGS ('dbx_business_glossary_term' = 'Attorney Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Country Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `settlement_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Settlement Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `address_line1` SET TAGS ('dbx_business_glossary_term' = 'Claimant Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `address_line1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `address_line2` SET TAGS ('dbx_business_glossary_term' = 'Claimant Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `address_line2` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `body_part_injured` SET TAGS ('dbx_business_glossary_term' = 'Body Part Injured');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'Claimant City');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `claimant_status` SET TAGS ('dbx_business_glossary_term' = 'Claimant Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `claimant_status` SET TAGS ('dbx_value_regex' = 'active|settled|closed|withdrawn|litigated|denied');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `claimant_type` SET TAGS ('dbx_business_glossary_term' = 'Claimant Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `claimant_type` SET TAGS ('dbx_value_regex' = 'person|organization|estate|trust|minor|dependent');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Claimant Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_business_glossary_term' = 'Claimant Date of Birth');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `dba_name` SET TAGS ('dbx_business_glossary_term' = 'Doing Business As (DBA) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `demand_amount` SET TAGS ('dbx_business_glossary_term' = 'Claimant Demand Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `demand_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'Claimant Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `fault_percentage` SET TAGS ('dbx_business_glossary_term' = 'Claimant Fault Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `fault_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `fault_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `fein` SET TAGS ('dbx_business_glossary_term' = 'Federal Employer Identification Number (FEIN)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `fein` SET TAGS ('dbx_value_regex' = '^d{2}-d{7}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `fein` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `fein` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `first_name` SET TAGS ('dbx_business_glossary_term' = 'Claimant First Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `injury_description` SET TAGS ('dbx_business_glossary_term' = 'Injury Description');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `injury_severity` SET TAGS ('dbx_business_glossary_term' = 'Injury Severity');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `injury_severity` SET TAGS ('dbx_value_regex' = 'minor|moderate|severe|critical|fatal');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `injury_type` SET TAGS ('dbx_business_glossary_term' = 'Injury Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `is_represented` SET TAGS ('dbx_business_glossary_term' = 'Is Claimant Represented');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `last_name` SET TAGS ('dbx_business_glossary_term' = 'Claimant Last Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `middle_name` SET TAGS ('dbx_business_glossary_term' = 'Claimant Middle Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `middle_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `middle_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `mobile_phone_number` SET TAGS ('dbx_business_glossary_term' = 'Claimant Mobile Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `mobile_phone_number` SET TAGS ('dbx_value_regex' = '^+?[1-9]d{1,14}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `mobile_phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `mobile_phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Claimant Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `organization_name` SET TAGS ('dbx_business_glossary_term' = 'Claimant Organization Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `organization_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `organization_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Claimant Paid Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `paid_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `party_code` SET TAGS ('dbx_business_glossary_term' = 'Party Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `phone_number` SET TAGS ('dbx_business_glossary_term' = 'Claimant Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `phone_number` SET TAGS ('dbx_value_regex' = '^+?[1-9]d{1,14}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Claimant Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `representation_date` SET TAGS ('dbx_business_glossary_term' = 'Representation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Claimant Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `reserve_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `role` SET TAGS ('dbx_business_glossary_term' = 'Claimant Role');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `role` SET TAGS ('dbx_value_regex' = 'insured|third_party|lienholder|additional_insured|mortgagee|loss_payee');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Claimant Settlement Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `settlement_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Claimant Settlement Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `ssn` SET TAGS ('dbx_business_glossary_term' = 'Social Security Number (SSN)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `ssn` SET TAGS ('dbx_value_regex' = '^d{3}-d{2}-d{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `ssn` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `ssn` SET TAGS ('dbx_pii_national_id' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `state_province` SET TAGS ('dbx_business_glossary_term' = 'Claimant State or Province');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `state_province` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `state_province` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Claimant Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` SET TAGS ('dbx_subdomain' = 'loss_intake');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `claim_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `claim_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `claim_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Adjuster Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_adjuster_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_adjuster_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `loss_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `scheduled_item_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Item Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `applicable_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Applicable Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `applicable_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Applicable Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `applicable_sir_amount` SET TAGS ('dbx_business_glossary_term' = 'Applicable Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Coverage Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_alae_amount` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_alae_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_business_glossary_term' = 'Coverage Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_value_regex' = 'per_occurrence|per_claim|aggregate|per_person|per_accident');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_denial_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Denial Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_denial_reason_code` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_denial_reason_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_denial_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Coverage Denial Reason Description');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_denial_reason_description` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_denial_reason_description` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_determination_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Determination Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_determination_date` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_determination_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_incurred_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Coverage Incurred Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_incurred_loss_amount` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_incurred_loss_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_notes` SET TAGS ('dbx_business_glossary_term' = 'Coverage Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_notes` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_notes` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_outstanding_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Coverage Outstanding Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_outstanding_reserve_amount` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_outstanding_reserve_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_paid_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Coverage Paid Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_paid_loss_amount` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_paid_loss_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_part` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_part` SET TAGS ('dbx_value_regex' = 'Part A|Part B|Part C|Part D|Part E|Part F');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_part` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_part` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_status` SET TAGS ('dbx_business_glossary_term' = 'Coverage Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_status` SET TAGS ('dbx_value_regex' = 'pending|covered|denied|excluded|exhausted|suspended');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_status` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_status` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_trigger_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Trigger Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_trigger_type` SET TAGS ('dbx_value_regex' = 'occurrence|claims_made|manifestation|exposure|injury_in_fact');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_trigger_type` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `coverage_trigger_type` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Created By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `deductible_satisfied_date` SET TAGS ('dbx_business_glossary_term' = 'Deductible Satisfied Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `deductible_satisfied_flag` SET TAGS ('dbx_business_glossary_term' = 'Deductible Satisfied Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `exclusion_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Applied Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `exclusion_code` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `limit_erosion_amount` SET TAGS ('dbx_business_glossary_term' = 'Limit Erosion Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `loss_date` SET TAGS ('dbx_business_glossary_term' = 'Date of Loss (DOL)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `policy_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `policy_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `remaining_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Remaining Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `sublimit_amount` SET TAGS ('dbx_business_glossary_term' = 'Sublimit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `sublimit_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Sublimit Applied Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `updated_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Updated By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `updated_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `updated_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` SET TAGS ('dbx_subdomain' = 'financial_settlement');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `claims_loss_reserve_id` SET TAGS ('dbx_business_glossary_term' = 'Claims Loss Reserve ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `claim_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `claim_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `claim_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_set_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Reserve Set Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `actuarial_segment_code` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Segment Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `approver_user_code` SET TAGS ('dbx_business_glossary_term' = 'Approver User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `approver_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `approver_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `paid_to_date_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid to Date Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `prior_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `report_year` SET TAGS ('dbx_business_glossary_term' = 'Report Year');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Reserve Approval Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|escalated');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_basis` SET TAGS ('dbx_business_glossary_term' = 'Reserve Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_basis` SET TAGS ('dbx_value_regex' = 'adjuster_estimate|actuarial_model|medical_report|legal_opinion|settlement_demand');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_category` SET TAGS ('dbx_business_glossary_term' = 'Reserve Category');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_category` SET TAGS ('dbx_value_regex' = 'indemnity|alae|ulae|defense|medical');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Reserve Change Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Reserve Confidence Level');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_confidence_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|very_high');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Reserve Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_notes` SET TAGS ('dbx_business_glossary_term' = 'Reserve Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_number` SET TAGS ('dbx_business_glossary_term' = 'Reserve Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reserve Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_set_date` SET TAGS ('dbx_business_glossary_term' = 'Reserve Set Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_source_system` SET TAGS ('dbx_business_glossary_term' = 'Reserve Source System');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Reserve Source System ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_status` SET TAGS ('dbx_business_glossary_term' = 'Reserve Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_status` SET TAGS ('dbx_value_regex' = 'open|closed|superseded|pending_review');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_type` SET TAGS ('dbx_business_glossary_term' = 'Reserve Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `reserve_type` SET TAGS ('dbx_value_regex' = 'case|ibnr|ibner|salvage|subrogation');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `ultimate_loss_estimate` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Loss Estimate');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` SET TAGS ('dbx_subdomain' = 'financial_settlement');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `claims_reserve_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Claims Reserve Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `claims_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `claims_supervisor_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Supervisor ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `effective_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Effective Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `reversed_transaction_claims_reserve_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Reversed Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `accounting_period` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `accounting_period` SET TAGS ('dbx_value_regex' = '^d{4}-d{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `bulk_reserve_flag` SET TAGS ('dbx_business_glossary_term' = 'Bulk Reserve Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `cat_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `coverage_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `coverage_code` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `coverage_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `loss_development_factor` SET TAGS ('dbx_business_glossary_term' = 'Loss Development Factor (LDF)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `net_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `new_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'New Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `posting_status` SET TAGS ('dbx_business_glossary_term' = 'Posting Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `posting_status` SET TAGS ('dbx_value_regex' = 'draft|pending|posted|reversed|voided');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `posting_status` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `posting_status` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `prior_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `reason_description` SET TAGS ('dbx_business_glossary_term' = 'Reason Description');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `reinsurance_recoverable_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `report_year` SET TAGS ('dbx_business_glossary_term' = 'Report Year');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `reserve_category` SET TAGS ('dbx_business_glossary_term' = 'Reserve Category');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `reserve_category` SET TAGS ('dbx_value_regex' = 'case_reserve|ibnr|alae|ulae');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `reserve_confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Reserve Confidence Level');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `reserve_confidence_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|very_high');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `reserve_method` SET TAGS ('dbx_business_glossary_term' = 'Reserve Method');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Reversal Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `salvage_subrogation_estimate` SET TAGS ('dbx_business_glossary_term' = 'Salvage and Subrogation Estimate');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `salvage_subrogation_estimate` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `salvage_subrogation_estimate` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `source_transaction_code` SET TAGS ('dbx_business_glossary_term' = 'Source Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `transaction_amount` SET TAGS ('dbx_business_glossary_term' = 'Transaction Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `transaction_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `transaction_number` SET TAGS ('dbx_business_glossary_term' = 'Transaction Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `transaction_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Transaction Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Transaction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'initial_set|increase|decrease|reopen|close|transfer');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` SET TAGS ('dbx_subdomain' = 'financial_settlement');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `claims_claim_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Payment ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `claim_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `claim_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `claim_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `claims_reserve_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Reserve Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `payee_id` SET TAGS ('dbx_business_glossary_term' = 'Payee Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `payment_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `payment_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `accounting_date` SET TAGS ('dbx_business_glossary_term' = 'Accounting Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `accounting_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `accounting_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `approval_authority` SET TAGS ('dbx_business_glossary_term' = 'Approval Authority');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `catastrophe_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `check_number` SET TAGS ('dbx_business_glossary_term' = 'Check Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `cleared_date` SET TAGS ('dbx_business_glossary_term' = 'Cleared Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `gross_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Payment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `is_joint_payee` SET TAGS ('dbx_business_glossary_term' = 'Is Joint Payee');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `is_reportable_1099` SET TAGS ('dbx_business_glossary_term' = 'Is Reportable 1099');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `joint_payee_name` SET TAGS ('dbx_business_glossary_term' = 'Joint Payee Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `joint_payee_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `joint_payee_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `loss_category` SET TAGS ('dbx_business_glossary_term' = 'Loss Category');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `net_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Payment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `offset_amount` SET TAGS ('dbx_business_glossary_term' = 'Offset Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `payee_tax_number` SET TAGS ('dbx_business_glossary_term' = 'Payee Tax ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `payee_tax_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `payee_tax_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `payee_type` SET TAGS ('dbx_business_glossary_term' = 'Payee Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `payment_batch_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Batch ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `payment_memo` SET TAGS ('dbx_business_glossary_term' = 'Payment Memo');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'check|eft|wire|ach|debit_card|virtual_card');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `payment_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `payment_type` SET TAGS ('dbx_business_glossary_term' = 'Payment Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `salvage_potential_flag` SET TAGS ('dbx_business_glossary_term' = 'Salvage Potential Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `salvage_potential_flag` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `salvage_potential_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `subrogation_potential_flag` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Potential Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `transaction_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Transaction Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `updated_by_user` SET TAGS ('dbx_business_glossary_term' = 'Updated By User');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `void_date` SET TAGS ('dbx_business_glossary_term' = 'Void Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ALTER COLUMN `withholding_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` SET TAGS ('dbx_subdomain' = 'financial_settlement');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `disbursement_id` SET TAGS ('dbx_business_glossary_term' = 'Disbursement Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Disbursement Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_id` SET TAGS ('dbx_business_glossary_term' = 'Payee Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payment_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `approval_user_code` SET TAGS ('dbx_business_glossary_term' = 'Approval User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `approval_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `approval_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `bank_name` SET TAGS ('dbx_business_glossary_term' = 'Bank Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `bank_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `bank_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_business_glossary_term' = 'Bank Routing Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `check_number` SET TAGS ('dbx_business_glossary_term' = 'Check Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `cleared_date` SET TAGS ('dbx_business_glossary_term' = 'Cleared Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `coverage_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `coverage_code` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `coverage_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `disbursement_date` SET TAGS ('dbx_business_glossary_term' = 'Disbursement Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `disbursement_status` SET TAGS ('dbx_business_glossary_term' = 'Disbursement Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `disbursement_status` SET TAGS ('dbx_value_regex' = 'pending|issued|cleared|voided|stopped|cancelled');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `eft_trace_number` SET TAGS ('dbx_business_glossary_term' = 'Electronic Funds Transfer (EFT) Trace Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `eft_trace_number` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `eft_trace_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `gl_posting_date` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Posting Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `gl_posting_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `gl_posting_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Disbursement Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `is_void` SET TAGS ('dbx_business_glossary_term' = 'Is Void Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `issued_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Issued By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `issued_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `issued_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `issued_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Issued Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `loss_category` SET TAGS ('dbx_business_glossary_term' = 'Loss Category');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `memo` SET TAGS ('dbx_business_glossary_term' = 'Disbursement Memo');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `method` SET TAGS ('dbx_business_glossary_term' = 'Disbursement Method');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Disbursement Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Disbursement Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `offset_amount` SET TAGS ('dbx_business_glossary_term' = 'Offset Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Payee Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_address_line1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Payee Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_address_line2` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_city` SET TAGS ('dbx_business_glossary_term' = 'Payee City');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_country` SET TAGS ('dbx_business_glossary_term' = 'Payee Country Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Payee Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_state` SET TAGS ('dbx_business_glossary_term' = 'Payee State or Province');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_state` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_state` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_tax_number` SET TAGS ('dbx_business_glossary_term' = 'Payee Tax Identifier (TIN/SSN/FEIN)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_tax_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payee_tax_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `payment_type` SET TAGS ('dbx_business_glossary_term' = 'Payment Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `void_date` SET TAGS ('dbx_business_glossary_term' = 'Void Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `void_reason` SET TAGS ('dbx_business_glossary_term' = 'Void Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ALTER COLUMN `withholding_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` SET TAGS ('dbx_subdomain' = 'adjudication_operations');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `license_issue_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'License Issue Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `license_state_id` SET TAGS ('dbx_business_glossary_term' = 'License State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `supervisor_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Supervisor Adjuster Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `tpa_id` SET TAGS ('dbx_business_glossary_term' = 'Tpa Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `adjuster_type` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `adjuster_type` SET TAGS ('dbx_value_regex' = 'staff|independent|TPA|CAT|public');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `background_check_date` SET TAGS ('dbx_business_glossary_term' = 'Background Check Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `background_check_status` SET TAGS ('dbx_business_glossary_term' = 'Background Check Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `background_check_status` SET TAGS ('dbx_value_regex' = 'passed|failed|pending|expired');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `ce_due_date` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `continuing_education_hours` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Hours');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `continuing_education_hours` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `continuing_education_hours` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `current_workload_count` SET TAGS ('dbx_business_glossary_term' = 'Current Workload Count');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `employment_status` SET TAGS ('dbx_business_glossary_term' = 'Employment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `employment_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|terminated|leave');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `eo_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `eo_insurance_carrier` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Insurance Carrier');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `eo_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `fein` SET TAGS ('dbx_business_glossary_term' = 'Federal Employer Identification Number (FEIN)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `fein` SET TAGS ('dbx_value_regex' = '^[0-9]{2}-[0-9]{7}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `fein` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `fein` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `first_name` SET TAGS ('dbx_business_glossary_term' = 'Adjuster First Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `hire_date` SET TAGS ('dbx_business_glossary_term' = 'Hire Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `home_office_location` SET TAGS ('dbx_business_glossary_term' = 'Home Office Location');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `last_name` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Last Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `license_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'License Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `license_issue_date` SET TAGS ('dbx_business_glossary_term' = 'License Issue Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `license_number` SET TAGS ('dbx_business_glossary_term' = 'Adjuster License Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `license_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `license_status` SET TAGS ('dbx_business_glossary_term' = 'License Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `license_status` SET TAGS ('dbx_value_regex' = 'active|expired|suspended|revoked|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `lob_authority` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Authority');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `max_workload_capacity` SET TAGS ('dbx_business_glossary_term' = 'Maximum Workload Capacity');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `max_workload_capacity` SET TAGS ('dbx_pii_category' = 'address');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `max_workload_capacity` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `middle_name` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Middle Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `middle_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `middle_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `mobile_number` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Mobile Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `mobile_number` SET TAGS ('dbx_value_regex' = '^+?[1-9]d{1,14}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `mobile_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `mobile_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `naic_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^ADJ[0-9]{6,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `phone_number` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `phone_number` SET TAGS ('dbx_value_regex' = '^+?[1-9]d{1,14}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `reserve_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Reserve Authority Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `reserve_authority_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `settlement_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Settlement Authority Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `settlement_authority_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `specialization` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Specialization');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `ssn_last_four` SET TAGS ('dbx_business_glossary_term' = 'Social Security Number (SSN) Last Four Digits');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `ssn_last_four` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `ssn_last_four` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `ssn_last_four` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `vendor_company_name` SET TAGS ('dbx_business_glossary_term' = 'Vendor Company Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `vendor_company_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `vendor_company_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `vendor_contract_number` SET TAGS ('dbx_business_glossary_term' = 'Vendor Contract Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ALTER COLUMN `years_of_experience` SET TAGS ('dbx_business_glossary_term' = 'Years of Experience');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` SET TAGS ('dbx_subdomain' = 'adjudication_operations');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `adjuster_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Assignment ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Assignment Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `primary_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `actual_hours` SET TAGS ('dbx_business_glossary_term' = 'Actual Hours');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assigned_by_name` SET TAGS ('dbx_business_glossary_term' = 'Assigned By Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assigned_by_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assigned_by_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assigned_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Assigned By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assigned_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assigned_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_method` SET TAGS ('dbx_business_glossary_term' = 'Assignment Method');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_method` SET TAGS ('dbx_value_regex' = 'manual|automatic|round_robin|skill_based|geographic|workload_balanced');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_notes` SET TAGS ('dbx_business_glossary_term' = 'Assignment Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_number` SET TAGS ('dbx_business_glossary_term' = 'Assignment Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_reason` SET TAGS ('dbx_business_glossary_term' = 'Assignment Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_role` SET TAGS ('dbx_business_glossary_term' = 'Assignment Role');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Assignment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|completed|cancelled');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Assignment Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_business_glossary_term' = 'Assignment Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_value_regex' = 'initial|reassignment|escalation|transfer|temporary|permanent');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `cat_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `complexity_level` SET TAGS ('dbx_business_glossary_term' = 'Complexity Level');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `complexity_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|complex|catastrophic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'End Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `end_reason` SET TAGS ('dbx_business_glossary_term' = 'End Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `end_timestamp` SET TAGS ('dbx_business_glossary_term' = 'End Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `estimated_hours` SET TAGS ('dbx_business_glossary_term' = 'Estimated Hours');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `first_contact_date` SET TAGS ('dbx_business_glossary_term' = 'First Contact Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `is_cat_assignment` SET TAGS ('dbx_business_glossary_term' = 'Is Catastrophe (CAT) Assignment Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `is_primary` SET TAGS ('dbx_business_glossary_term' = 'Is Primary Adjuster Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `last_activity_date` SET TAGS ('dbx_business_glossary_term' = 'Last Activity Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `license_required` SET TAGS ('dbx_business_glossary_term' = 'License Required');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Modified By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `reassignment_reason` SET TAGS ('dbx_business_glossary_term' = 'Reassignment Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `sla_target_days` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Target Days');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `specialty_required` SET TAGS ('dbx_business_glossary_term' = 'Specialty Required');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ALTER COLUMN `workload_priority` SET TAGS ('dbx_business_glossary_term' = 'Workload Priority');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` SET TAGS ('dbx_subdomain' = 'adjudication_operations');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `claim_note_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Note Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `claim_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `claim_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `claim_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Exposure Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `note_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Note Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `activity_code` SET TAGS ('dbx_business_glossary_term' = 'Activity Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `assigned_to_user_code` SET TAGS ('dbx_business_glossary_term' = 'Assigned To User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `assigned_to_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `assigned_to_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `attachment_count` SET TAGS ('dbx_business_glossary_term' = 'Attachment Count');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `author_name` SET TAGS ('dbx_business_glossary_term' = 'Author Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `author_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `author_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `author_user_code` SET TAGS ('dbx_business_glossary_term' = 'Author User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `author_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `author_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `body_text` SET TAGS ('dbx_business_glossary_term' = 'Note Body Text');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `confidential_flag` SET TAGS ('dbx_business_glossary_term' = 'Confidential Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `deleted_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Deleted By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `deleted_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `deleted_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `deleted_date` SET TAGS ('dbx_business_glossary_term' = 'Deleted Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `deleted_flag` SET TAGS ('dbx_business_glossary_term' = 'Deleted Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `editable_flag` SET TAGS ('dbx_business_glossary_term' = 'Editable Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `external_reference_code` SET TAGS ('dbx_business_glossary_term' = 'External Reference Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `follow_up_date` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `follow_up_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Language Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `language_code` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `language_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `litigation_flag` SET TAGS ('dbx_business_glossary_term' = 'Litigation Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `note_date` SET TAGS ('dbx_business_glossary_term' = 'Note Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `note_number` SET TAGS ('dbx_business_glossary_term' = 'Note Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `note_subtype` SET TAGS ('dbx_business_glossary_term' = 'Note Subtype');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `note_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Note Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `note_type` SET TAGS ('dbx_business_glossary_term' = 'Note Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Note Priority');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'low|normal|high|urgent');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `privileged_flag` SET TAGS ('dbx_business_glossary_term' = 'Privileged Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `related_party_code` SET TAGS ('dbx_business_glossary_term' = 'Related Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `reviewed_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Reviewed By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `reviewed_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `reviewed_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `reviewed_date` SET TAGS ('dbx_business_glossary_term' = 'Reviewed Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `reviewed_flag` SET TAGS ('dbx_business_glossary_term' = 'Reviewed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `security_level` SET TAGS ('dbx_business_glossary_term' = 'Security Level');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `security_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `subject` SET TAGS ('dbx_business_glossary_term' = 'Note Subject');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `topic` SET TAGS ('dbx_business_glossary_term' = 'Note Topic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `visibility_scope` SET TAGS ('dbx_business_glossary_term' = 'Visibility Scope');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ALTER COLUMN `visibility_scope` SET TAGS ('dbx_value_regex' = 'internal|external|vendor|legal|medical');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` SET TAGS ('dbx_subdomain' = 'adjudication_operations');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `claim_document_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Document Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `document_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Document Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `fnol_id` SET TAGS ('dbx_business_glossary_term' = 'First Notice of Loss (FNOL) Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Approved Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `approved_flag` SET TAGS ('dbx_business_glossary_term' = 'Approved Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `author_name` SET TAGS ('dbx_business_glossary_term' = 'Author Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `author_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `author_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `author_organization` SET TAGS ('dbx_business_glossary_term' = 'Author Organization');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `confidential_flag` SET TAGS ('dbx_business_glossary_term' = 'Confidential Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `claim_document_description` SET TAGS ('dbx_business_glossary_term' = 'Document Description');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `document_date` SET TAGS ('dbx_business_glossary_term' = 'Document Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `document_number` SET TAGS ('dbx_business_glossary_term' = 'Document Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'Document Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `document_subtype` SET TAGS ('dbx_business_glossary_term' = 'Document Subtype');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `document_type` SET TAGS ('dbx_business_glossary_term' = 'Document Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `ecm_folder_path` SET TAGS ('dbx_business_glossary_term' = 'Enterprise Content Management (ECM) Folder Path');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `ecm_repository` SET TAGS ('dbx_business_glossary_term' = 'Enterprise Content Management (ECM) Repository');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `ecm_repository` SET TAGS ('dbx_value_regex' = 'opentext|filenet|sharepoint|s3|azure_blob');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `file_extension` SET TAGS ('dbx_business_glossary_term' = 'File Extension');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `file_name` SET TAGS ('dbx_business_glossary_term' = 'File Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `file_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `file_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `file_size_bytes` SET TAGS ('dbx_business_glossary_term' = 'File Size in Bytes');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `legal_hold_flag` SET TAGS ('dbx_business_glossary_term' = 'Legal Hold Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `legal_hold_reason` SET TAGS ('dbx_business_glossary_term' = 'Legal Hold Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `mime_type` SET TAGS ('dbx_business_glossary_term' = 'Multipurpose Internet Mail Extensions (MIME) Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Document Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `ocr_processed_flag` SET TAGS ('dbx_business_glossary_term' = 'Optical Character Recognition (OCR) Processed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `ocr_text` SET TAGS ('dbx_business_glossary_term' = 'Optical Character Recognition (OCR) Text');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `page_count` SET TAGS ('dbx_business_glossary_term' = 'Page Count');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `page_count` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `page_count` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `phi_flag` SET TAGS ('dbx_business_glossary_term' = 'Protected Health Information (PHI) Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `pii_flag` SET TAGS ('dbx_business_glossary_term' = 'Personally Identifiable Information (PII) Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `received_date` SET TAGS ('dbx_business_glossary_term' = 'Received Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `redaction_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Redaction Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `retention_class` SET TAGS ('dbx_business_glossary_term' = 'Retention Class');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `retention_class` SET TAGS ('dbx_value_regex' = 'permanent|seven_year|ten_year|litigation_hold|regulatory_hold');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `retention_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Retention Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `reviewed_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Reviewed By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `reviewed_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `reviewed_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `reviewed_date` SET TAGS ('dbx_business_glossary_term' = 'Reviewed Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `reviewed_flag` SET TAGS ('dbx_business_glossary_term' = 'Reviewed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `upload_date` SET TAGS ('dbx_business_glossary_term' = 'Upload Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `upload_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Upload Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `uploaded_by_party_code` SET TAGS ('dbx_business_glossary_term' = 'Uploaded By Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `uploaded_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Uploaded By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `uploaded_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ALTER COLUMN `uploaded_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` SET TAGS ('dbx_subdomain' = 'special_handling');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `litigation_id` SET TAGS ('dbx_business_glossary_term' = 'Litigation Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Litigation Manager Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `assigned_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Adjuster Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `defense_counsel_service_vendor_id` SET TAGS ('dbx_business_glossary_term' = 'Defense Counsel Service Vendor Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `plaintiff_attorney_id` SET TAGS ('dbx_business_glossary_term' = 'Plaintiff Attorney Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `plaintiff_claimant_id` SET TAGS ('dbx_business_glossary_term' = 'Plaintiff Claimant Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `suit_filed_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Suit Filed Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `alae_incurred` SET TAGS ('dbx_business_glossary_term' = 'Allocated Loss Adjustment Expense (ALAE) Incurred');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `alae_paid` SET TAGS ('dbx_business_glossary_term' = 'Allocated Loss Adjustment Expense (ALAE) Paid');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `appeal_filed_indicator` SET TAGS ('dbx_business_glossary_term' = 'Appeal Filed Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `bad_faith_indicator` SET TAGS ('dbx_business_glossary_term' = 'Bad Faith Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `case_description` SET TAGS ('dbx_business_glossary_term' = 'Case Description');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `court_county` SET TAGS ('dbx_business_glossary_term' = 'Court County');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `court_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Court Jurisdiction');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `court_state` SET TAGS ('dbx_business_glossary_term' = 'Court State');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `court_type` SET TAGS ('dbx_business_glossary_term' = 'Court Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `court_type` SET TAGS ('dbx_value_regex' = 'state|federal|appellate|supreme|municipal|district');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `discovery_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Discovery Deadline Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `dismissal_date` SET TAGS ('dbx_business_glossary_term' = 'Dismissal Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `litigation_status` SET TAGS ('dbx_business_glossary_term' = 'Litigation Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `litigation_type` SET TAGS ('dbx_business_glossary_term' = 'Litigation Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `litigation_type` SET TAGS ('dbx_value_regex' = 'bodily_injury|property_damage|bad_faith|coverage_dispute|subrogation|other');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `mediation_scheduled_date` SET TAGS ('dbx_business_glossary_term' = 'Mediation Scheduled Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Litigation Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `plaintiff_demand_amount` SET TAGS ('dbx_business_glossary_term' = 'Plaintiff Demand Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `punitive_damages_sought` SET TAGS ('dbx_business_glossary_term' = 'Punitive Damages Sought Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `punitive_damages_sought` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `punitive_damages_sought` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Litigation Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Settlement Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `suit_filed_date` SET TAGS ('dbx_business_glossary_term' = 'Suit Filed Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `suit_filed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Suit Filed Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `suit_number` SET TAGS ('dbx_business_glossary_term' = 'Lawsuit Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `trial_date` SET TAGS ('dbx_business_glossary_term' = 'Trial Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `verdict_amount` SET TAGS ('dbx_business_glossary_term' = 'Verdict Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ALTER COLUMN `verdict_date` SET TAGS ('dbx_business_glossary_term' = 'Verdict Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` SET TAGS ('dbx_subdomain' = 'special_handling');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `medical_bill_id` SET TAGS ('dbx_business_glossary_term' = 'Medical Bill ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `medical_bill_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `medical_bill_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Bill Reviewer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `bill_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Bill Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `claimant_id` SET TAGS ('dbx_business_glossary_term' = 'Claimant Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `payment_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `service_vendor_id` SET TAGS ('dbx_business_glossary_term' = 'Service Vendor Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `admission_date` SET TAGS ('dbx_business_glossary_term' = 'Admission Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `allowed_amount` SET TAGS ('dbx_business_glossary_term' = 'Allowed Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `bill_date` SET TAGS ('dbx_business_glossary_term' = 'Bill Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `bill_number` SET TAGS ('dbx_business_glossary_term' = 'Medical Bill Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `bill_received_date` SET TAGS ('dbx_business_glossary_term' = 'Bill Received Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `bill_review_date` SET TAGS ('dbx_business_glossary_term' = 'Bill Review Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `bill_review_outcome` SET TAGS ('dbx_business_glossary_term' = 'Bill Review Outcome');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `bill_review_outcome` SET TAGS ('dbx_value_regex' = 'approved|reduced|denied|pending|appealed|resubmitted');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `bill_type_code` SET TAGS ('dbx_business_glossary_term' = 'Bill Type Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `bill_type_code` SET TAGS ('dbx_value_regex' = '^[0-9]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `billed_amount` SET TAGS ('dbx_business_glossary_term' = 'Billed Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `denial_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Denial Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `denial_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Denial Reason Description');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `diagnosis_code_primary` SET TAGS ('dbx_business_glossary_term' = 'Primary Diagnosis Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `diagnosis_code_primary` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `diagnosis_code_primary` SET TAGS ('dbx_pii_health' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `diagnosis_code_secondary` SET TAGS ('dbx_business_glossary_term' = 'Secondary Diagnosis Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `diagnosis_code_secondary` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `diagnosis_code_secondary` SET TAGS ('dbx_pii_health' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `discharge_date` SET TAGS ('dbx_business_glossary_term' = 'Discharge Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `fee_schedule_applied` SET TAGS ('dbx_business_glossary_term' = 'Fee Schedule Applied');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Bill Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'check|eft|wire|card');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'pending|approved|paid|denied|appealed');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `procedure_code` SET TAGS ('dbx_business_glossary_term' = 'Procedure Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `procedure_description` SET TAGS ('dbx_business_glossary_term' = 'Procedure Description');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `provider_npi` SET TAGS ('dbx_business_glossary_term' = 'National Provider Identifier (NPI)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `provider_npi` SET TAGS ('dbx_value_regex' = '^[0-9]{10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `provider_npi` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `reduction_amount` SET TAGS ('dbx_business_glossary_term' = 'Reduction Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `revenue_code` SET TAGS ('dbx_business_glossary_term' = 'Revenue Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `revenue_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `service_date_from` SET TAGS ('dbx_business_glossary_term' = 'Service Date From');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `service_date_to` SET TAGS ('dbx_business_glossary_term' = 'Service Date To');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `service_units` SET TAGS ('dbx_business_glossary_term' = 'Service Units');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` SET TAGS ('dbx_subdomain' = 'adjudication_operations');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `damage_estimate_id` SET TAGS ('dbx_business_glossary_term' = 'Damage Estimate ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `damage_estimate_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `damage_estimate_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `approved_by_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Adjuster ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `estimate_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Estimate Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `scheduled_item_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Item Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `service_vendor_id` SET TAGS ('dbx_business_glossary_term' = 'Service Vendor Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `acv_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Cash Value (ACV) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `damage_estimate_status` SET TAGS ('dbx_business_glossary_term' = 'Estimate Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `damage_estimate_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|approved|rejected|revised|final');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `damage_estimate_status` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `damage_estimate_status` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `damage_type` SET TAGS ('dbx_business_glossary_term' = 'Damage Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `damage_type` SET TAGS ('dbx_value_regex' = 'property|vehicle|equipment|other');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `damage_type` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `damage_type` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `depreciation_amount` SET TAGS ('dbx_business_glossary_term' = 'Depreciation Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `equipment_amount` SET TAGS ('dbx_business_glossary_term' = 'Equipment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `estimate_date` SET TAGS ('dbx_business_glossary_term' = 'Estimate Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `estimate_methodology` SET TAGS ('dbx_business_glossary_term' = 'Estimate Methodology');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `estimate_methodology` SET TAGS ('dbx_value_regex' = 'detailed|summary|desk_review|photo_estimate');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `estimate_number` SET TAGS ('dbx_business_glossary_term' = 'Estimate Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `estimate_software` SET TAGS ('dbx_business_glossary_term' = 'Estimate Software');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `estimate_type` SET TAGS ('dbx_business_glossary_term' = 'Estimate Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `estimate_type` SET TAGS ('dbx_value_regex' = 'initial|supplemental|revised|final');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `estimator_license_number` SET TAGS ('dbx_business_glossary_term' = 'Estimator License Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `estimator_license_number` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `estimator_license_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `estimator_party_code` SET TAGS ('dbx_business_glossary_term' = 'Estimator Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `estimator_type` SET TAGS ('dbx_business_glossary_term' = 'Estimator Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `estimator_type` SET TAGS ('dbx_value_regex' = 'staff|independent_adjuster|vendor|appraiser|engineer');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Inspection Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `labor_amount` SET TAGS ('dbx_business_glossary_term' = 'Labor Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `line_item_count` SET TAGS ('dbx_business_glossary_term' = 'Line Item Count');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `loss_description` SET TAGS ('dbx_business_glossary_term' = 'Loss Description');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `materials_amount` SET TAGS ('dbx_business_glossary_term' = 'Materials Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `net_payable_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Payable Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Estimate Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `overhead_profit_amount` SET TAGS ('dbx_business_glossary_term' = 'Overhead and Profit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `rcv_amount` SET TAGS ('dbx_business_glossary_term' = 'Replacement Cost Value (RCV) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `repair_vs_total_decision` SET TAGS ('dbx_business_glossary_term' = 'Repair Versus Total Loss Decision');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `repair_vs_total_decision` SET TAGS ('dbx_value_regex' = 'repair|total_loss|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `salvage_value` SET TAGS ('dbx_business_glossary_term' = 'Salvage Value');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `salvage_value` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `salvage_value` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `total_loss_threshold_percentage` SET TAGS ('dbx_business_glossary_term' = 'Total Loss Threshold Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `total_loss_threshold_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `total_loss_threshold_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` SET TAGS ('dbx_subdomain' = 'adjudication_operations');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `service_vendor_id` SET TAGS ('dbx_business_glossary_term' = 'Service Vendor ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `business_country_id` SET TAGS ('dbx_business_glossary_term' = 'Business Country Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `business_state_id` SET TAGS ('dbx_business_glossary_term' = 'Business State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `onboarding_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Onboarding Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `payee_id` SET TAGS ('dbx_business_glossary_term' = 'Payee Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `average_cycle_time_days` SET TAGS ('dbx_business_glossary_term' = 'Average Cycle Time in Days');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `average_cycle_time_days` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `average_cycle_time_days` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `background_check_date` SET TAGS ('dbx_business_glossary_term' = 'Background Check Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `background_check_status` SET TAGS ('dbx_business_glossary_term' = 'Background Check Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `background_check_status` SET TAGS ('dbx_value_regex' = 'passed|failed|pending|not_required');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_business_glossary_term' = 'Bank Routing Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_value_regex' = '^d{9}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `business_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Business Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `business_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `business_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `business_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Business Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `business_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `business_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `business_city` SET TAGS ('dbx_business_glossary_term' = 'Business City');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `business_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `business_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `business_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Business Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `business_postal_code` SET TAGS ('dbx_value_regex' = '^d{5}(-d{4})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `business_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `business_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `contract_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `contract_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `customer_satisfaction_score` SET TAGS ('dbx_business_glossary_term' = 'Customer Satisfaction Score');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `dba_name` SET TAGS ('dbx_business_glossary_term' = 'Doing Business As (DBA) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `insurance_certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Insurance Certificate Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `insurance_coverage_amount` SET TAGS ('dbx_business_glossary_term' = 'Insurance Coverage Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `insurance_coverage_amount` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `insurance_coverage_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `insurance_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Insurance Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `licensed_states` SET TAGS ('dbx_business_glossary_term' = 'Licensed States');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Vendor Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `onboarding_date` SET TAGS ('dbx_business_glossary_term' = 'Onboarding Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'ach|check|wire_transfer|virtual_card');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `payment_terms` SET TAGS ('dbx_business_glossary_term' = 'Payment Terms');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `payment_terms` SET TAGS ('dbx_value_regex' = 'net_15|net_30|net_45|net_60|due_on_receipt');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `performance_tier` SET TAGS ('dbx_business_glossary_term' = 'Performance Tier');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `performance_tier` SET TAGS ('dbx_value_regex' = 'platinum|gold|silver|bronze|unrated');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `preferred_vendor_flag` SET TAGS ('dbx_business_glossary_term' = 'Preferred Vendor Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_value_regex' = '^+?1?d{10,15}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `primary_license_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Primary License Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `primary_license_number` SET TAGS ('dbx_business_glossary_term' = 'Primary License Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `primary_license_number` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `primary_license_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `primary_license_state` SET TAGS ('dbx_business_glossary_term' = 'Primary License State');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `primary_license_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `quality_score` SET TAGS ('dbx_business_glossary_term' = 'Quality Score');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `service_radius_miles` SET TAGS ('dbx_business_glossary_term' = 'Service Radius in Miles');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `total_assignments_ytd` SET TAGS ('dbx_business_glossary_term' = 'Total Assignments Year-to-Date (YTD)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `vendor_name` SET TAGS ('dbx_business_glossary_term' = 'Vendor Legal Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `vendor_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `vendor_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `vendor_status` SET TAGS ('dbx_business_glossary_term' = 'Vendor Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `vendor_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending_approval|terminated');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `vendor_tin` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number (TIN)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `vendor_tin` SET TAGS ('dbx_value_regex' = '^d{2}-d{7}$|^d{9}$');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `vendor_tin` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `vendor_tin` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `vendor_type` SET TAGS ('dbx_business_glossary_term' = 'Vendor Service Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ALTER COLUMN `w9_on_file_flag` SET TAGS ('dbx_business_glossary_term' = 'W-9 Form on File Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` SET TAGS ('dbx_subdomain' = 'loss_intake');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `claim_status_history_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Status History ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `assigned_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Adjuster ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `assigned_adjuster_id` SET TAGS ('dbx_renamed_from' = 'adjuster_id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `assigned_adjuster_id` SET TAGS ('dbx_business_role' = 'assigned');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `examiner_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Examiner ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `transition_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Transition Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `acting_user_code` SET TAGS ('dbx_business_glossary_term' = 'Acting User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `acting_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `acting_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `acting_user_code` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `acting_user_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `acting_user_name` SET TAGS ('dbx_business_glossary_term' = 'Acting User Name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `acting_user_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `acting_user_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `acting_user_role` SET TAGS ('dbx_business_glossary_term' = 'Acting User Role');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `acting_user_role` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `acting_user_role` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `approval_required_indicator` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `approval_user_code` SET TAGS ('dbx_business_glossary_term' = 'Approval User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `approval_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `approval_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Comments');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Status Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `incurred_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Incurred Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `new_status` SET TAGS ('dbx_business_glossary_term' = 'New Claim Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `notification_sent_indicator` SET TAGS ('dbx_business_glossary_term' = 'Notification Sent Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `notification_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Notification Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `prior_status` SET TAGS ('dbx_business_glossary_term' = 'Prior Claim Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `regulatory_reportable_indicator` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reportable Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Case Reserve (OCR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Sequence Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `sla_actual_hours` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Actual Hours');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `sla_compliance_indicator` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Compliance Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `sla_target_hours` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Target Hours');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `system_source` SET TAGS ('dbx_business_glossary_term' = 'System Source');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `transaction_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `transition_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `transition_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Reason Description');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `transition_source` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Source');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `transition_source` SET TAGS ('dbx_value_regex' = 'manual|automated|workflow|api|batch');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `transition_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ALTER COLUMN `workflow_step_code` SET TAGS ('dbx_business_glossary_term' = 'Workflow Step ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` SET TAGS ('dbx_subdomain' = 'special_handling');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `fraud_referral_id` SET TAGS ('dbx_business_glossary_term' = 'Fraud Referral ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Special Investigation Unit (SIU) Investigator ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Producer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `referral_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Referral Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `scheduled_item_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Item Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `assigned_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `confirmed_fraud_amount` SET TAGS ('dbx_business_glossary_term' = 'Confirmed Fraud Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Created By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `denial_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Denial Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `denial_recommended_flag` SET TAGS ('dbx_business_glossary_term' = 'Claim Denial Recommended Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `estimated_fraud_amount` SET TAGS ('dbx_business_glossary_term' = 'Estimated Fraud Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `fraud_confirmed_flag` SET TAGS ('dbx_business_glossary_term' = 'Fraud Confirmed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `fraud_indicator_code` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator Code');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `fraud_indicator_description` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator Description');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `fraud_referral_status` SET TAGS ('dbx_business_glossary_term' = 'Investigation Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `fraud_referral_status` SET TAGS ('dbx_value_regex' = 'pending|assigned|under_investigation|suspended|closed');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `fraud_type` SET TAGS ('dbx_business_glossary_term' = 'Fraud Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `fraud_type` SET TAGS ('dbx_value_regex' = 'hard_fraud|soft_fraud|opportunistic|organized|internal|external');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `investigation_close_date` SET TAGS ('dbx_business_glossary_term' = 'Investigation Close Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `investigation_notes` SET TAGS ('dbx_business_glossary_term' = 'Investigation Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `investigation_start_date` SET TAGS ('dbx_business_glossary_term' = 'Investigation Start Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `law_enforcement_agency` SET TAGS ('dbx_business_glossary_term' = 'Law Enforcement Agency');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `law_enforcement_agency` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `law_enforcement_agency` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `law_enforcement_case_number` SET TAGS ('dbx_business_glossary_term' = 'Law Enforcement Case Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `law_enforcement_referral_date` SET TAGS ('dbx_business_glossary_term' = 'Law Enforcement Referral Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `law_enforcement_referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Law Enforcement Referral Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `nicb_referral_date` SET TAGS ('dbx_business_glossary_term' = 'National Insurance Crime Bureau (NICB) Referral Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `nicb_referral_flag` SET TAGS ('dbx_business_glossary_term' = 'National Insurance Crime Bureau (NICB) Referral Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `outcome` SET TAGS ('dbx_business_glossary_term' = 'Investigation Outcome');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `outcome` SET TAGS ('dbx_value_regex' = 'confirmed_fraud|unfounded|pending|insufficient_evidence|referred_to_law_enforcement');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `outcome_date` SET TAGS ('dbx_business_glossary_term' = 'Outcome Determination Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `outcome_description` SET TAGS ('dbx_business_glossary_term' = 'Outcome Description');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `policy_cancellation_recommended_flag` SET TAGS ('dbx_business_glossary_term' = 'Policy Cancellation Recommended Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Referral Priority');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `recovery_amount` SET TAGS ('dbx_business_glossary_term' = 'Recovery Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `recovery_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `referral_date` SET TAGS ('dbx_business_glossary_term' = 'Referral Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `referral_number` SET TAGS ('dbx_business_glossary_term' = 'Fraud Referral Number');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `referral_reason` SET TAGS ('dbx_business_glossary_term' = 'Referral Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `referral_source` SET TAGS ('dbx_business_glossary_term' = 'Referral Source');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `referral_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Referral Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `referring_party_code` SET TAGS ('dbx_business_glossary_term' = 'Referring Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `referring_user_code` SET TAGS ('dbx_business_glossary_term' = 'Referring User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `referring_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `referring_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `state_fraud_bureau_referral_date` SET TAGS ('dbx_business_glossary_term' = 'State Fraud Bureau Referral Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `state_fraud_bureau_referral_flag` SET TAGS ('dbx_business_glossary_term' = 'State Fraud Bureau Referral Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `updated_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Updated By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `updated_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `updated_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` SET TAGS ('dbx_subdomain' = 'adjudication_operations');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` SET TAGS ('dbx_association_edges' = 'claims.claim,claims.service_vendor');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` ALTER COLUMN `service_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Service Assignment Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Service Assignment - Claim Id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` ALTER COLUMN `service_vendor_id` SET TAGS ('dbx_business_glossary_term' = 'Service Assignment - Service Vendor Id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` ALTER COLUMN `assignment_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Assignment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_business_glossary_term' = 'Assignment Type');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'Completion Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` ALTER COLUMN `invoice_amount` SET TAGS ('dbx_business_glossary_term' = 'Invoice Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` ALTER COLUMN `performance_rating` SET TAGS ('dbx_business_glossary_term' = 'Performance Rating');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` ALTER COLUMN `performance_rating` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` ALTER COLUMN `performance_rating` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_assignment` ALTER COLUMN `sla_compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'SLA Compliance Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` SET TAGS ('dbx_subdomain' = 'loss_intake');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` SET TAGS ('dbx_association_edges' = 'coverage.peril,claims.claim');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `claim_peril_causation_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Peril Causation ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Peril Causation - Claim Id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `coverage_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Peril Causation - Peril Id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `coverage_peril_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `coverage_peril_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `determined_by_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Determined By Adjuster ID');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `adjuster_notes` SET TAGS ('dbx_business_glossary_term' = 'Adjuster Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `causation_sequence_order` SET TAGS ('dbx_business_glossary_term' = 'Causation Sequence Order');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `claim_peril_causation_status` SET TAGS ('dbx_business_glossary_term' = 'Causation Status');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `concurrent_causation_flag` SET TAGS ('dbx_business_glossary_term' = 'Concurrent Causation Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `coverage_applicable_flag` SET TAGS ('dbx_business_glossary_term' = 'Coverage Applicable Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `coverage_applicable_flag` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `coverage_applicable_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `exclusion_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Applied Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `exclusion_reason` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `loss_cause_determination_date` SET TAGS ('dbx_business_glossary_term' = 'Loss Cause Determination Date');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `peril_contribution_percentage` SET TAGS ('dbx_business_glossary_term' = 'Peril Contribution Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `peril_contribution_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `peril_contribution_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `proximate_cause_flag` SET TAGS ('dbx_business_glossary_term' = 'Proximate Cause Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ALTER COLUMN `subrogation_target_flag` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Target Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` SET TAGS ('dbx_subdomain' = 'special_handling');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `tpa_id` SET TAGS ('dbx_business_glossary_term' = 'Tpa Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `address_line_1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `address_line_1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `address_line_2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `address_line_2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `average_claim_cycle_time_days` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `average_claim_cycle_time_days` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `tpa_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `tpa_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `performance_rating` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `performance_rating` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `reserve_setting_authority` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `reserve_setting_authority` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `state_province` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `state_province` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`tpa` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` SET TAGS ('dbx_subdomain' = 'special_handling');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `attorney_id` SET TAGS ('dbx_business_glossary_term' = 'Attorney Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `address_line_1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `address_line_1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `address_line_2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `address_line_2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `fax_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `fax_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `full_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `full_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `hourly_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `law_firm_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `law_firm_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `middle_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `middle_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `mobile_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `mobile_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `tax_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`attorney` ALTER COLUMN `tax_number` SET TAGS ('dbx_pii_financial' = 'true');
