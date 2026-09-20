-- Schema for Domain: coverage | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-20 14:33:30

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_blog_v499`.`coverage` COMMENT 'Bridge between the policy contract and the insured risk. Owns Coverage (one row per coverage per policy term) with attached Limit, Deductible, Exclusion, and Condition.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` (
    `submission_id` BIGINT COMMENT 'Unique identifier for the submission record. Primary key.',
    `agency_id` BIGINT COMMENT 'Foreign key to the agency or brokerage firm associated with this submission.',
    `bound_policy_id` BIGINT COMMENT 'Foreign key to the policy table if this submission was bound into an active policy.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Underwriters evaluate catastrophe exposure during submission intake to determine risk appetite, pricing tier, and referral triggers.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Submissions capture risk location (risk_state, risk_country) which maps to geography hierarchy for territory rating, catastrophe zone assignment, and regulatory jurisdiction',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Normalize lob_code string to FK reference to shared.line_of_business master data. Submission currently stores lob_code as string; replacing with FK enables consistent LOB',
    `producers_producer_id` BIGINT COMMENT 'Foreign key to the producer or agent who submitted or is associated with this submission.',
    `submission_applicant_party_id` BIGINT COMMENT 'Foreign key to the party table identifying the applicant or prospect submitting the risk for underwriting evaluation.',
    `submission_party_id` BIGINT COMMENT 'Foreign key to the underwriter assigned to evaluate this submission.',
    `acord_form_type` STRING COMMENT 'ACORD standard form type used for this submission such as ACORD 125 for commercial, ACORD 126 for commercial supplemental, ACORD 140 for personal lines.. Valid values are `ACORD_125|ACORD_126|ACORD_140|other`',
    `clearance_status` STRING COMMENT 'Status of submission intake clearance process indicating whether all required information and documents have been received.. Valid values are `cleared|pending|blocked|requires_documents`',
    `clue_report_date` DATE COMMENT 'Date the CLUE or Comprehensive Loss Underwriting Exchange report was pulled for this submission.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this submission record was first created in the underwriting system.',
    `credit_report_date` DATE COMMENT 'Date the credit report or insurance score was pulled for this submission.',
    `credit_score` BIGINT COMMENT 'Insurance credit score or credit-based insurance score used in underwriting and rating where permitted by state regulation.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this submission.. Valid values are `USD|CAD|MXN`',
    `decline_reason` STRING COMMENT 'Business reason for declining the submission if status is declined such as adverse loss history, unacceptable risk, or outside appetite.',
    `effective_date` DATE COMMENT 'Requested or proposed effective date for coverage to begin if the submission is bound.',
    `eligibility_status` STRING COMMENT 'Result of automated eligibility screening indicating whether the submission meets basic acceptance criteria.. Valid values are `eligible|ineligible|conditional|pending_review`',
    `estimated_annual_premium` DECIMAL(18,2) COMMENT 'Estimated or indicative annual premium for this submission prior to final rating.',
    `expiration_date` DATE COMMENT 'Requested or proposed expiration date for coverage if the submission is bound.',
    `inspection_completed_date` DATE COMMENT 'Date the required inspection was completed if applicable.',
    `inspection_required_flag` BOOLEAN COMMENT 'Boolean flag indicating whether a physical inspection of the insured property or risk is required before binding.',
    `line_of_business` STRING COMMENT 'Insurance line of business for this submission such as Personal Auto, Homeowners, Commercial General Liability, Workers Compensation.',
    `loss_history_reviewed_flag` BOOLEAN COMMENT 'Boolean flag indicating whether prior loss history was reviewed via CLUE, ISO, or other loss database.',
    `modified_timestamp` TIMESTAMP COMMENT 'System timestamp when this submission record was last modified or updated.',
    `mvr_report_date` DATE COMMENT 'Date the Motor Vehicle Record report was pulled for auto submissions.',
    `naics_code` STRING COMMENT 'Six-digit NAICS code classifying the business or industry of the applicant for commercial submissions.',
    `number` STRING COMMENT 'Business-facing unique submission number displayed to users and producers.',
    `policy_type_code` STRING COMMENT 'Code identifying the type of policy being submitted such as HO3, PAP, BOP, CGL, WC.',
    `prior_carrier_naic_code` STRING COMMENT 'NAIC company code of the prior insurance carrier.',
    `prior_carrier_name` STRING COMMENT 'Name of the prior insurance carrier if the applicant is switching carriers.',
    `prior_policy_number` STRING COMMENT 'Policy number of the prior or expiring policy if this submission is a renewal or rewrite.',
    `quote_count` BIGINT COMMENT 'Number of quotes generated from this submission.',
    `referral_reason` STRING COMMENT 'Business reason or rule that triggered the referral requirement such as high TIV, adverse loss history, or non-standard risk.',
    `referral_required_flag` BOOLEAN COMMENT 'Boolean flag indicating whether this submission requires referral to senior underwriter or management for approval.',
    `risk_appetite_score` DECIMAL(5,2) COMMENT 'Automated or manual risk appetite score indicating alignment with underwriting guidelines and risk tolerance.',
    `risk_country` STRING COMMENT 'Three-letter ISO country code where the insured risk is located.. Valid values are `USA|CAN|MEX`',
    `risk_state` STRING COMMENT 'Two-letter state code where the primary insured risk is located.',
    `sic_code` STRING COMMENT 'Four-digit SIC code classifying the business or industry of the applicant for commercial submissions.',
    `source` STRING COMMENT 'Channel or origin through which the submission was received. [ENUM-REF-CANDIDATE: agent|broker|direct|web_portal|mobile_app|call_center|renewal|endorsement — 8 candidates stripped; promote to reference product]',
    `submission_date` DATE COMMENT 'Date the submission was received or created in the system.',
    `submission_status` STRING COMMENT 'Current lifecycle status of the submission in the underwriting workflow. [ENUM-REF-CANDIDATE: draft|submitted|under_review|quoted|bound|declined|withdrawn|expired — 8 candidates stripped; promote to reference product]',
    `submission_type` STRING COMMENT 'Classification of the submission as new business, renewal, rewrite, or remarketing of existing risk.. Valid values are `new_business|renewal|rewrite|remarket`',
    `submitted_by_user_code` STRING COMMENT 'User identifier or login of the person who created or submitted this submission record.',
    `total_insured_value` DECIMAL(18,2) COMMENT 'Total insured value or sum insured across all risks and coverages in this submission.',
    `withdrawn_reason` STRING COMMENT 'Reason the submission was withdrawn by the applicant or producer before binding.',
    CONSTRAINT pk_submission PRIMARY KEY(`submission_id`)
) COMMENT 'ACORD 125/126/140 submission record capturing prospect risk information submitted for UW evaluation. Grain: one row per submission. Tracks source, status, line of business, and submission date.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` (
    `submission_party_id` BIGINT COMMENT 'Unique identifier for the submission party association record.',
    `party_id` BIGINT COMMENT 'Foreign key to the party playing a role in this submission.',
    `role_id` BIGINT COMMENT 'Foreign key linking to party.party_role. Business justification: Submission_party tracks roles (applicant, additional insured, loss payee) at submission stage.',
    `submission_id` BIGINT COMMENT 'Foreign key to the submission this party is associated with.',
    `clue_report_date` DATE COMMENT 'Date when the CLUE report was obtained for this party.',
    `clue_report_ordered_flag` BOOLEAN COMMENT 'Indicates whether a CLUE report was ordered for this party during submission underwriting.',
    `consent_date` DATE COMMENT 'Date when this party provided consent for underwriting and rating activities.',
    `consent_to_rate_flag` BOOLEAN COMMENT 'Indicates whether this party has provided consent to be rated for insurance purposes.',
    `created_by_user` STRING COMMENT 'User identifier of the person or system that created this submission party association record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this submission party association record was first created in the system.',
    `credit_score` BIGINT COMMENT 'Credit score of the party at the time of submission, used for underwriting and rating purposes.',
    `distribution_channel` STRING COMMENT 'Distribution channel through which this party is associated with the submission.. Valid values are `DIRECT|INDEPENDENT_AGENT|CAPTIVE_AGENT|BROKER|ONLINE|AFFINITY`',
    `effective_date` DATE COMMENT 'Date when this party role association became effective for the submission.',
    `expiration_date` DATE COMMENT 'Date when this party role association expires or was terminated for the submission.',
    `fraud_indicator_flag` BOOLEAN COMMENT 'Indicates whether fraud indicators were detected for this party during submission screening.',
    `fraud_score` DECIMAL(5,2) COMMENT 'Quantitative fraud risk score assigned to this party during submission evaluation, scale 0-100.',
    `insurable_interest_type` STRING COMMENT 'Type of insurable interest this party holds in the risk being underwritten.. Valid values are `OWNER|LESSEE|MORTGAGEE|LIENHOLDER|BAILEE|TRUSTEE`',
    `is_primary_party` BOOLEAN COMMENT 'Indicates whether this party is the primary party for this role on the submission.',
    `kyc_verification_date` DATE COMMENT 'Date when KYC verification was completed for this party.',
    `kyc_verification_status` STRING COMMENT 'Status of Know Your Customer verification for this party at submission time.. Valid values are `VERIFIED|PENDING|FAILED|NOT_REQUIRED`',
    `lapse_duration_days` BIGINT COMMENT 'Number of days of coverage lapse if prior coverage lapse flag is true.',
    `loss_payee_rank` BIGINT COMMENT 'Priority ranking for loss payment distribution when multiple loss payees exist, applicable for loss payee roles.',
    `modified_by_user` STRING COMMENT 'User identifier of the person or system that last modified this submission party association record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this submission party association record was last modified.',
    `mvr_ordered_flag` BOOLEAN COMMENT 'Indicates whether a Motor Vehicle Record was ordered for this party, applicable for auto submissions.',
    `mvr_report_date` DATE COMMENT 'Date when the MVR report was obtained for this party.',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage of ownership or interest this party holds in the insured risk, applicable for named insured and additional insured roles.',
    `party_role_code` STRING COMMENT 'The role this party plays in the submission context. [ENUM-REF-CANDIDATE: APPLICANT|NAMED_INSURED|ADDITIONAL_INSURED|PRODUCER|BROKER|AGENT|LOSS_PAYEE — 7 candidates stripped; promote to reference product]',
    `prior_carrier_name` STRING COMMENT 'Name of the insurance carrier that previously insured this party, used for underwriting continuity assessment.',
    `prior_coverage_lapse_flag` BOOLEAN COMMENT 'Indicates whether this party experienced a lapse in coverage prior to this submission.',
    `prior_policy_number` STRING COMMENT 'Policy number from the prior carrier, used for loss history verification and underwriting.',
    `producer_appointment_status` STRING COMMENT 'Status of the producer appointment at the time of submission, applicable for producer roles.. Valid values are `ACTIVE|INACTIVE|PENDING|TERMINATED`',
    `producer_commission_rate` DECIMAL(5,2) COMMENT 'Commission rate percentage applicable to this producer for this submission.',
    `producer_npn` STRING COMMENT 'National Producer Number for the producer party, required for producer and agent roles.. Valid values are `^[0-9]{10}$`',
    `referral_reason` STRING COMMENT 'Reason code or description for why this party was referred to underwriting.',
    `relationship_to_applicant` STRING COMMENT 'Relationship of this party to the primary applicant on the submission. [ENUM-REF-CANDIDATE: SELF|SPOUSE|PARENT|CHILD|SIBLING|BUSINESS_PARTNER|EMPLOYEE|OTHER — 8 candidates stripped; promote to reference product]',
    `risk_score` DECIMAL(5,2) COMMENT 'Quantitative risk score assigned to this party during underwriting evaluation, scale 0-100.',
    `role_sequence` BIGINT COMMENT 'Ordering sequence when multiple parties hold the same role on a submission.',
    `role_status` STRING COMMENT 'Current lifecycle status of this party role association.. Valid values are `ACTIVE|INACTIVE|PENDING|TERMINATED|SUSPENDED`',
    `source_system_code` STRING COMMENT 'Unique identifier of this record in the source operational system.',
    `underwriter_notes` STRING COMMENT 'Free-text notes entered by the underwriter regarding this party during submission review.',
    `underwriting_referral_flag` BOOLEAN COMMENT 'Indicates whether this party triggered an underwriting referral during submission evaluation.',
    `underwriting_tier` STRING COMMENT 'Underwriting tier assigned to this party based on risk evaluation during submission review.. Valid values are `PREFERRED|STANDARD|SUBSTANDARD|DECLINED`',
    `years_with_prior_carrier` BIGINT COMMENT 'Number of years this party was insured with the prior carrier, used for continuity credit evaluation.',
    CONSTRAINT pk_submission_party PRIMARY KEY(`submission_party_id`)
) COMMENT 'Associates parties (applicant, named insured, additional insured, producer) to a submission with role and effective dates. Junction table carrying role-specific UW attributes per submission.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` (
    `uw_decision_id` BIGINT COMMENT 'Unique identifier for the underwriting decision event. Grain: one row per UW decision event.',
    `quote_id` BIGINT COMMENT 'Reference to the quote being evaluated or modified by this underwriting decision, if applicable.',
    `submission_id` BIGINT COMMENT 'Reference to the submission being evaluated by this underwriting decision.',
    `uw_approved_by_party_id` BIGINT COMMENT 'Reference to the party who provided final approval for the underwriting decision, if approval was required.',
    `uw_party_id` BIGINT COMMENT 'Reference to the underwriter who rendered this decision.',
    `uw_referral_id` BIGINT COMMENT 'Foreign key linking to coverage.uw_referral. Business justification: UW decision can result from a referral being resolved. 1 decision resolves 1 referral. FK populated when referral is resolved with decision.',
    `uw_referred_to_underwriter_party_id` BIGINT COMMENT 'Reference to the senior underwriter or specialist to whom the submission was escalated.',
    `appetite_match_flag` BOOLEAN COMMENT 'Indicates whether the submission aligns with the insurers current risk appetite and strategic guidelines.',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether the underwriting decision requires additional approval from management or a senior authority before being finalized.',
    `approval_timestamp` TIMESTAMP COMMENT 'The date and time when the underwriting decision was approved by the designated authority.',
    `assigned_underwriter_name` STRING COMMENT 'Full name of the underwriter who rendered this decision, for reporting and audit purposes.',
    `automated_decision_flag` BOOLEAN COMMENT 'Indicates whether the underwriting decision was rendered by an automated rules engine or AI model versus a human underwriter.',
    `conditions_required` STRING COMMENT 'List of conditions or requirements that must be met for conditional acceptance, such as inspections, loss control measures, or additional documentation.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this underwriting decision record was first created in the system.',
    `decision_effective_date` DATE COMMENT 'The date from which the underwriting decision becomes effective, relevant for conditional acceptances or modified terms.',
    `decision_expiration_date` DATE COMMENT 'The date when the underwriting decision expires if not acted upon, typically for quotes or conditional offers.',
    `decision_model_version` STRING COMMENT 'Version identifier of the automated underwriting model or rules engine used to render the decision, for audit and reproducibility.',
    `decision_number` STRING COMMENT 'Business-facing unique identifier for the underwriting decision, used in correspondence and workflow tracking.',
    `decision_rationale` STRING COMMENT 'Detailed explanation of the reasoning behind the underwriting decision, including risk factors and business considerations.',
    `decision_status` STRING COMMENT 'Current lifecycle status of the underwriting decision within the workflow. [ENUM-REF-CANDIDATE: pending|in_review|approved|rejected|escalated|withdrawn|expired — 7 candidates stripped; promote to reference product]',
    `decision_timestamp` TIMESTAMP COMMENT 'The date and time when the underwriting decision was rendered by the underwriter.',
    `decision_type` STRING COMMENT 'The type of underwriting decision rendered: accept, decline, refer to senior UW, modify terms, counter-offer, or conditional acceptance.. Valid values are `accept|decline|refer|modify|counter_offer|conditional_accept`',
    `decline_reason_code` STRING COMMENT 'Standardized code indicating the primary reason for declining the submission, aligned with regulatory disclosure requirements.',
    `decline_reason_description` STRING COMMENT 'Human-readable description of the decline reason, provided to the applicant per regulatory requirements.',
    `eligibility_flag` BOOLEAN COMMENT 'Indicates whether the submission meets all eligibility criteria for the requested line of business and coverage.',
    `endorsements_required` STRING COMMENT 'List of endorsements or policy forms that must be attached as part of the underwriting decision.',
    `exclusions_added` STRING COMMENT 'List of exclusions added to the policy as part of the underwriting decision to mitigate specific risks.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The date and time when this underwriting decision record was last updated in the system.',
    `modified_deductible_amount` DECIMAL(18,2) COMMENT 'The revised deductible amount proposed by the underwriter if the decision type is modify or counter-offer.',
    `modified_limit_amount` DECIMAL(18,2) COMMENT 'The revised coverage limit proposed by the underwriter if the decision type is modify or counter-offer.',
    `modified_premium_amount` DECIMAL(18,2) COMMENT 'The revised premium amount proposed by the underwriter if the decision type is modify or counter-offer.',
    `notes` STRING COMMENT 'Additional free-text notes or comments recorded by the underwriter regarding the decision, for internal reference and knowledge transfer.',
    `override_flag` BOOLEAN COMMENT 'Indicates whether the underwriter manually overrode an automated decision or system recommendation.',
    `override_reason` STRING COMMENT 'Explanation of why the underwriter overrode the automated decision, required for compliance and audit purposes.',
    `referral_due_date` DATE COMMENT 'Service Level Agreement (SLA) due date by which the referral must be resolved to meet business commitments.',
    `referral_priority` STRING COMMENT 'Priority level assigned to the referral, determining the urgency of senior underwriter review.. Valid values are `low|normal|high|urgent|critical`',
    `referral_reason_code` STRING COMMENT 'Standardized code indicating why the submission was referred to a senior underwriter or specialist for further review.',
    `referral_reason_description` STRING COMMENT 'Detailed explanation of why the submission requires escalation or specialist review.',
    `risk_score` DECIMAL(10,4) COMMENT 'Quantitative risk score calculated for the submission, used to support the underwriting decision.',
    `risk_tier` STRING COMMENT 'Categorical risk classification assigned to the submission based on underwriting evaluation.. Valid values are `preferred|standard|substandard|declined`',
    `sla_actual_hours` DECIMAL(10,2) COMMENT 'The actual number of hours taken to render the underwriting decision, measured from submission intake to decision timestamp.',
    `sla_met_flag` BOOLEAN COMMENT 'Indicates whether the underwriting decision was rendered within the committed service level agreement timeframe.',
    `sla_target_hours` BIGINT COMMENT 'The target number of hours within which the underwriting decision should be rendered per business commitments.',
    `underwriter_authority_level` STRING COMMENT 'The authority level of the underwriter who made the decision, indicating approval limits and escalation tier.. Valid values are `junior|senior|principal|chief|automated`',
    CONSTRAINT pk_uw_decision PRIMARY KEY(`uw_decision_id`)
) COMMENT 'Underwriter accept/decline/refer/modify decision for a submission or quote, including referral escalation (absorbs uw_referral): assigned UW, priority, SLA due date, resolution. Grain: one row per UW decision event.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` (
    `uw_referral_id` BIGINT COMMENT 'Unique identifier for the underwriting referral record. Primary key.',
    `agency_id` BIGINT COMMENT 'Identifier of the agency representing the producer who submitted the business.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Referrals are routed to underwriters by line of business expertise and authority limits.',
    `policy_id` BIGINT COMMENT 'Identifier of the policy associated with this referral, if applicable for endorsements or renewals.',
    `producers_producer_id` BIGINT COMMENT 'Identifier of the agent or broker who submitted the business that triggered the referral.',
    `quote_id` BIGINT COMMENT 'Identifier of the quote that triggered this referral, if applicable.',
    `submission_id` BIGINT COMMENT 'Identifier of the submission that triggered this referral.',
    `term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Referrals occur at renewal (term-specific underwriting review triggered by loss activity, occupancy change, limit increase).',
    `uw_assigned_underwriter_party_id` BIGINT COMMENT 'Identifier of the senior underwriter or specialist assigned to review and resolve the referral.',
    `uw_party_id` BIGINT COMMENT 'Identifier of the underwriter who initiated the referral.',
    `approval_conditions` STRING COMMENT 'Specific conditions or requirements that must be met for approval, such as additional documentation, coverage modifications, or premium adjustments.',
    `assigned_underwriter_name` STRING COMMENT 'Full name of the assigned underwriter for display and reporting purposes.',
    `authority_level_required` STRING COMMENT 'Level of underwriting authority required to approve this referral based on risk, premium, or policy limits.. Valid values are `senior_underwriter|chief_underwriter|regional_manager|executive_approval`',
    `catastrophe_exposure_flag` BOOLEAN COMMENT 'Indicates whether the referral involves significant catastrophe exposure requiring senior review.',
    `created_by_user_code` STRING COMMENT 'User identifier of the person or system that created the referral record.',
    `decline_reason_code` STRING COMMENT 'Standardized code indicating the primary reason for declining the referral, if applicable.',
    `decline_reason_description` STRING COMMENT 'Detailed explanation of why the referral was declined, if applicable.',
    `escalation_level` BIGINT COMMENT 'Number of times the referral has been escalated to higher authority levels. Zero indicates no escalation.',
    `fraud_indicator_flag` BOOLEAN COMMENT 'Indicates whether fraud detection systems flagged this submission for potential fraud requiring special investigation unit review.',
    `last_modified_by_user_code` STRING COMMENT 'User identifier of the person or system that last modified the referral record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when the referral record was last updated.',
    `premium_amount` DECIMAL(15,2) COMMENT 'Total premium amount associated with the referred submission or quote.',
    `prior_loss_amount` DECIMAL(15,2) COMMENT 'Total dollar amount of prior losses for the insured or risk that contributed to the referral decision.',
    `prior_loss_count` BIGINT COMMENT 'Number of prior losses reported for the insured or risk that contributed to the referral decision.',
    `priority_level` STRING COMMENT 'Business priority assigned to the referral for queue management and SLA tracking.. Valid values are `low|normal|high|urgent|critical`',
    `product_code` STRING COMMENT 'Internal product code identifying the specific insurance product being underwritten.',
    `referral_assigned_timestamp` TIMESTAMP COMMENT 'Date and time when the referral was assigned to a senior underwriter for review.',
    `referral_created_timestamp` TIMESTAMP COMMENT 'Date and time when the referral was first created in the underwriting workbench.',
    `referral_number` STRING COMMENT 'Business-facing unique referral number displayed to underwriters and stakeholders.',
    `referral_reason_code` STRING COMMENT 'Standardized code indicating the primary reason for referral. [ENUM-REF-CANDIDATE',
    `referral_reason_description` STRING COMMENT 'Detailed narrative explanation of why the submission or quote was referred beyond standard authority.',
    `referral_status` STRING COMMENT 'Current lifecycle status of the referral: pending, under review, approved, declined, withdrawn, escalated, or returned. [ENUM-REF-CANDIDATE: pending|under_review|approved|declined|withdrawn|escalated|returned — 7 candidates stripped; promote to reference',
    `referral_type` STRING COMMENT 'Type of transaction that triggered the referral: new business, renewal, endorsement, cancellation, reinstatement, or quote revision.. Valid values are `new_business|renewal|endorsement|cancellation|reinstatement|quote_revision`',
    `regulatory_concern_flag` BOOLEAN COMMENT 'Indicates whether the referral involves regulatory compliance concerns requiring legal or compliance review.',
    `reinsurance_required_flag` BOOLEAN COMMENT 'Indicates whether reinsurance placement or facultative coverage is required as part of the referral review.',
    `resolution_notes` STRING COMMENT 'Detailed notes from the reviewing underwriter explaining the resolution decision and any special conditions or requirements.',
    `resolution_outcome` STRING COMMENT 'Final decision outcome of the referral review: approved, approved with conditions, declined, withdrawn, escalated, or returned for rework.. Valid values are `approved|approved_with_conditions|declined|withdrawn|escalated|returned_for_rework`',
    `resolution_timestamp` TIMESTAMP COMMENT 'Date and time when the referral was resolved with a final decision.',
    `risk_score` DECIMAL(5,2) COMMENT 'Quantitative risk score assigned to the submission or quote that triggered the referral.',
    `sla_due_date` DATE COMMENT 'Target date by which the referral must be resolved per underwriting service level agreements.',
    `sla_due_timestamp` TIMESTAMP COMMENT 'Precise date and time by which the referral must be resolved per underwriting service level agreements.',
    `state_code` STRING COMMENT 'Two-letter US state code where the risk is located, relevant for regulatory and underwriting authority rules.',
    `territory_code` STRING COMMENT 'Internal territory code used for rating and underwriting segmentation.',
    `total_insured_value` DECIMAL(15,2) COMMENT 'Total insured value of all risks covered under the referred submission or quote.',
    CONSTRAINT pk_uw_referral PRIMARY KEY(`uw_referral_id`)
) COMMENT 'Tracks submissions or quotes escalated beyond standard UW authority for senior review. Captures referral reason, assigned UW, priority, SLA due date, and resolution outcome.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` (
    `risk_appetite_rule_id` BIGINT COMMENT 'Unique identifier for the risk appetite rule. Primary key.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Appetite rules often restrict underwriting in high-hazard cat zones (e.g., no new business in CAT zone 5, mandatory wind deductibles in coastal territories, moratorium',
    `coverage_type_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_type. Business justification: Risk appetite rules can be coverage-specific (e.g., decline earthquake coverage if PML exceeds $5M, require sprinkler system for fire coverage on buildings over 50,000 sq ft).',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Appetite rules are geography-specific (state_code field exists). Geography provides hierarchical context for rule application across territories, counties, and zip codes.',
    `policy_type_id` BIGINT COMMENT 'Foreign key linking to policy.policy_type. Business justification: Risk appetite rules are configured per policy type to define acceptance criteria (e.g., max TIV for homeowners, min credit score for personal auto).',
    `approval_authority_level` STRING COMMENT 'Minimum authority level required to approve exceptions to this rule: automatic, underwriter, senior underwriter, chief underwriter, or executive.. Valid values are `auto|underwriter|senior_underwriter|chief_underwriter|executive`',
    `approved_by` STRING COMMENT 'Name or identifier of the individual who approved the rule for activation, supporting accountability and audit requirements.',
    `approved_timestamp` TIMESTAMP COMMENT 'Timestamp when the rule was formally approved for activation by the designated authority.',
    `business_owner` STRING COMMENT 'Name or identifier of the business unit or individual responsible for maintaining and approving changes to this rule.',
    `class_code` STRING COMMENT 'ISO or NCCI class code identifying the specific risk class to which the rule applies. Null indicates rule applies across all classes within the LOB.',
    `condition_expression` STRING COMMENT 'Logical expression or criteria defining when the rule is triggered, typically in business rule engine syntax or structured query format.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the rule record was first created in the system.',
    `decision_action` STRING COMMENT 'Underwriting action triggered when the rule condition is met: accept automatically, decline submission, refer to underwriter, quote with conditions, or require mandatory endorsement.. Valid values are `accept|decline|refer|quote_with_conditions|require_endorsement`',
    `effective_date` DATE COMMENT 'Date from which the rule becomes active and enforceable in underwriting decisions.',
    `exception_allowed_flag` BOOLEAN COMMENT 'Indicates whether underwriters are permitted to override this rule with appropriate authority. True allows exceptions; False enforces strict compliance.',
    `expiration_date` DATE COMMENT 'Date on which the rule ceases to be active. Null indicates an open-ended rule with no planned expiration.',
    `last_review_date` DATE COMMENT 'Date when the rule was last reviewed for accuracy, relevance, and regulatory compliance.',
    `lob` STRING COMMENT 'Line of business to which the rule applies: Personal Auto, Homeowners, Commercial General Liability, Workers Compensation, etc. [ENUM-REF-CANDIDATE: PAP|HO|CGL|WC|CA|BOP|CPP|EPLI|D&O|E&O — promote to reference product]',
    `mandatory_endorsement_code` STRING COMMENT 'ISO or proprietary endorsement form code that must be attached to the policy when this rule triggers a require endorsement action.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the rule record was last modified, supporting audit trail and change tracking.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review of the rule to ensure continued alignment with business strategy and regulatory requirements.',
    `notes` STRING COMMENT 'Free-text field for additional context, implementation guidance, or historical notes related to the rule.',
    `pricing_adjustment_factor` DECIMAL(8,4) COMMENT 'Multiplicative factor applied to base premium when the rule triggers a pricing constraint, typically representing a surcharge or credit.',
    `priority_rank` BIGINT COMMENT 'Execution priority rank determining rule evaluation order when multiple rules apply to the same submission. Lower numbers execute first.',
    `referral_reason_code` STRING COMMENT 'Standardized code indicating the reason for underwriter referral when the rule triggers a refer action.',
    `regulatory_mandate_flag` BOOLEAN COMMENT 'Indicates whether the rule is mandated by state Department of Insurance regulation or NAIC model law. True means regulatory compliance is required; False indicates internal policy.',
    `regulatory_reference` STRING COMMENT 'Citation of the specific state statute, NAIC model regulation, or Department of Insurance bulletin that mandates this rule, if applicable.',
    `rule_code` STRING COMMENT 'Business-assigned unique code identifying the rule for external reference and system integration.. Valid values are `^[A-Z0-9_-]{3,20}$`',
    `rule_description` STRING COMMENT 'Detailed business explanation of the rule purpose, conditions, and intended underwriting outcome.',
    `rule_name` STRING COMMENT 'Human-readable name of the risk appetite rule for business user identification and reporting.',
    `rule_status` STRING COMMENT 'Current lifecycle status of the rule indicating whether it is in draft, actively enforced, temporarily suspended, retired, or awaiting approval.. Valid values are `draft|active|suspended|retired|pending_approval`',
    `rule_type` STRING COMMENT 'Classification of the rule governing its purpose: eligibility screening, appetite boundary, underwriting guideline, class restriction, mandatory endorsement requirement, or pricing constraint.. Valid values are `eligibility|appetite|guideline|class_restriction|mandatory_endorsement|pricing_constraint`',
    `state_code` STRING COMMENT 'Two-letter US state code where the rule applies. Null indicates rule applies across all states.. Valid values are `^[A-Z]{2}$`',
    `threshold_unit` STRING COMMENT 'Unit of measure for the threshold value: currency amount, percentage, count, ratio, or risk score.. Valid values are `currency|percentage|count|ratio|score`',
    `threshold_value` DECIMAL(18,4) COMMENT 'Numeric threshold or limit value used in the rule condition for comparison against submission attributes such as Total Insured Value, premium, or loss ratio.',
    `version_number` BIGINT COMMENT 'Sequential version number tracking rule revisions for audit trail and change management.',
    CONSTRAINT pk_risk_appetite_rule PRIMARY KEY(`risk_appetite_rule_id`)
) COMMENT 'Business-managed, versioned, effective-dated UW governance (absorbs uw_guideline): eligibility/appetite rules, guideline criteria, class restrictions, mandatory-endorsement and pricing constraints by LOB, state, and class that trigger accept, decline, or';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` (
    `eligibility_check_id` BIGINT COMMENT 'Unique identifier for the eligibility evaluation record. Primary key.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Eligibility checks evaluate whether a risk falls within acceptable cat zones per appetite rules. Cat zone moratorium flags and concentration limits drive eligibility decisions.',
    `eligibility_override_user_party_id` BIGINT COMMENT 'User ID of the underwriter who performed the override.',
    `eligibility_party_id` BIGINT COMMENT 'Foreign key to the underwriter assigned to review the eligibility check.',
    `primary_risk_appetite_rule_id` BIGINT COMMENT 'Foreign key linking to coverage.risk_appetite_rule. Business justification: Eligibility check applies specific appetite rules. FK captures the primary rule that triggered the check result.',
    `submission_id` BIGINT COMMENT 'Foreign key to the submission being evaluated for eligibility.',
    `appetite_tier` STRING COMMENT 'Risk appetite classification assigned by the eligibility check: preferred, standard, non-standard, or declined.. Valid values are `preferred|standard|non_standard|declined`',
    `check_duration_seconds` BIGINT COMMENT 'Elapsed time in seconds for the eligibility check execution.',
    `check_number` STRING COMMENT 'Business-readable identifier for this eligibility check, often sequential within a submission.',
    `check_status` STRING COMMENT 'Current status of the eligibility evaluation: pass, fail, pending, override, or manual review.. Valid values are `pass|fail|pending|override|manual_review`',
    `check_timestamp` TIMESTAMP COMMENT 'Date and time when the eligibility check was executed.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the eligibility check record was first created in the system.',
    `data_source` STRING COMMENT 'Source system or module that generated the eligibility check record.',
    `decision_reason` STRING COMMENT 'Detailed explanation or reason code for the eligibility decision.',
    `effective_date` DATE COMMENT 'Date when the eligibility check result becomes effective for underwriting decisions.',
    `eligibility_decision` STRING COMMENT 'Final eligibility decision: eligible, ineligible, conditional, or refer.. Valid values are `eligible|ineligible|conditional|refer`',
    `expiration_date` DATE COMMENT 'Date when the eligibility check result expires and must be re-evaluated.',
    `fail_flag` BOOLEAN COMMENT 'Boolean indicator whether the submission failed one or more eligibility criteria.',
    `failed_rule_ids` STRING COMMENT 'Comma-separated list of rule IDs that caused the eligibility check to fail.',
    `lob` STRING COMMENT 'Line of business for which eligibility was evaluated: HO, PAP, CGL, BOP, WC, etc.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when the eligibility check record was last modified.',
    `naic_company_code` STRING COMMENT 'NAIC company code of the insurer entity performing the eligibility check.',
    `notes` STRING COMMENT 'Free-text notes or comments added by underwriters regarding the eligibility check.',
    `override_flag` BOOLEAN COMMENT 'Boolean indicator whether an underwriter manually overrode the automated eligibility decision.',
    `override_reason` STRING COMMENT 'Free-text explanation provided by the underwriter for overriding the automated eligibility result.',
    `override_timestamp` TIMESTAMP COMMENT 'Date and time when the override was applied.',
    `pass_flag` BOOLEAN COMMENT 'Boolean indicator whether the submission passed all eligibility criteria.',
    `product_code` STRING COMMENT 'Specific product code within the line of business being evaluated for eligibility.',
    `referral_flag` BOOLEAN COMMENT 'Boolean indicator whether the eligibility check resulted in a referral to senior underwriting.',
    `referral_reason` STRING COMMENT 'Reason code or description explaining why the submission was referred for manual review.',
    `risk_score` DECIMAL(5,2) COMMENT 'Numeric risk score calculated during eligibility evaluation, typically 0-100 or 0-999.',
    `risk_score_band` STRING COMMENT 'Categorical band assigned based on the numeric risk score: low, medium, high, or very high.. Valid values are `low|medium|high|very_high`',
    `rule_set_name` STRING COMMENT 'Name of the eligibility rule set applied, such as appetite screening or risk tier assignment.',
    `rule_set_version` STRING COMMENT 'Version identifier of the eligibility rule set applied during this check.',
    `state_code` STRING COMMENT 'Two-letter state code where the risk is domiciled, used for appetite and regulatory eligibility.',
    `triggered_rule_ids` STRING COMMENT 'Comma-separated list of rule IDs that were triggered during the eligibility check.',
    CONSTRAINT pk_eligibility_check PRIMARY KEY(`eligibility_check_id`)
) COMMENT 'Records the outcome of automated eligibility and risk appetite screening for a submission. Grain: one row per eligibility evaluation. Captures rule set version, pass/fail flags, and triggered rule IDs.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` (
    `underwriting_risk_score_id` BIGINT COMMENT 'Unique identifier for the underwriting risk score record. Primary key.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Risk scoring models incorporate catastrophe zone hazard scores (earthquake PML, hurricane AAL) as key underwriting factors.',
    `clearance_check_id` BIGINT COMMENT 'Foreign key linking to coverage.clearance_check. Business justification: Risk score is generated as part of clearance screening. FK associates score with the check that produced it. Nullable YES (scores can be generated outside clearance checks).',
    `eligibility_check_id` BIGINT COMMENT 'Foreign key linking to coverage.eligibility_check. Business justification: Risk score is generated as part of eligibility screening. FK associates score with the check that produced it.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Risk scores are geography-dependent (territory_score, catastrophe_score fields exist).',
    `insured_risk_id` BIGINT COMMENT 'Foreign key to the insured risk being scored. Links this risk score to the specific risk exposure (property, auto, etc.).',
    `party_id` BIGINT COMMENT 'User identifier of the underwriter who performed the manual override. Null if no override occurred.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy if this score was generated post-binding. Null for pre-bind scoring.',
    `submission_id` BIGINT COMMENT 'Foreign key to the submission being scored. Links this risk score to the submission intake record.',
    `term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Risk scores are recalculated per term for renewal underwriting (score changes term-over-term based on updated loss history, credit, MVR, territory).',
    `auto_decline_flag` BOOLEAN COMMENT 'Indicates whether this score triggered an automatic decline decision. True if risk is outside appetite.',
    `auto_decline_reason` STRING COMMENT 'Business reason for automatic decline. Describes which rule or threshold caused the decline decision.',
    `catastrophe_score` DECIMAL(10,4) COMMENT 'Component score for catastrophe exposure including hurricane, earthquake, wildfire, and flood risk.',
    `claim_count_3yr` BIGINT COMMENT 'Number of claims filed in the prior 3 years. Key indicator of loss frequency.',
    `claim_count_5yr` BIGINT COMMENT 'Number of claims filed in the prior 5 years. Extended loss history view for high-value risks.',
    `clue_score` DECIMAL(10,4) COMMENT 'Component score derived from prior loss history via CLUE database. Reflects historical claim frequency and severity.',
    `composite_score` DECIMAL(10,4) COMMENT 'Overall composite risk score calculated by the model. Primary output of the scoring process.',
    `cope_score` DECIMAL(10,4) COMMENT 'Component score for property risk factors: construction type, occupancy class, fire protection, and external exposure.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this risk score record was first created in the system. Audit trail field.',
    `credit_score` DECIMAL(10,4) COMMENT 'Component score derived from credit-based insurance score. Used where permitted by state regulation.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Percentage score reflecting completeness and accuracy of input data used for scoring. Range 0-100.',
    `itv_ratio` DECIMAL(5,2) COMMENT 'Ratio of insured value to actual replacement cost. Used to assess adequacy of coverage limits.',
    `lapse_in_coverage_days` BIGINT COMMENT 'Number of days without insurance coverage prior to this application. Zero indicates continuous coverage.',
    `lob` STRING COMMENT 'Insurance line of business this score applies to. Determines which scoring model and rules are used.. Valid values are `personal_auto|homeowners|commercial_auto|commercial_property|general_liability|workers_comp`',
    `loss_free_years` BIGINT COMMENT 'Number of consecutive years without a reported claim. Used for experience rating and NCB calculation.',
    `mvr_score` DECIMAL(10,4) COMMENT 'Component score derived from driver motor vehicle records. Includes violations, accidents, and license status.',
    `occupancy_score` DECIMAL(10,4) COMMENT 'Component score for business occupancy classification and associated hazards. Uses SIC or NAICS codes.',
    `override_flag` BOOLEAN COMMENT 'Indicates whether an underwriter manually overrode the system-generated score. True if overridden.',
    `override_reason` STRING COMMENT 'Business justification for manual score override. Required for audit and compliance when override occurs.',
    `override_timestamp` TIMESTAMP COMMENT 'Date and time when the manual override was performed. Null if no override occurred.',
    `prior_carrier_score` DECIMAL(10,4) COMMENT 'Component score reflecting prior insurance history, carrier quality, and continuity of coverage.',
    `protection_class` STRING COMMENT 'ISO Public Protection Classification (PPC) code for fire protection. Ranges from 1 (best) to 10 (worst).',
    `score_band` STRING COMMENT 'Risk classification band derived from the composite score. Used for underwriting decisioning and pricing tier assignment.. Valid values are `excellent|preferred|standard|substandard|declined|refer`',
    `score_confidence_level` STRING COMMENT 'Model confidence in the score result. Reflects data completeness and model certainty.. Valid values are `high|medium|low`',
    `score_model_name` STRING COMMENT 'Name of the risk scoring model used (e.g., ISO ERC, proprietary UW model, third-party vendor model).',
    `score_model_version` STRING COMMENT 'Version identifier of the scoring model used. Enables tracking of model changes over time.',
    `score_reason_code_1` STRING COMMENT 'Primary reason code explaining the score result. Top adverse action factor per FCRA requirements.',
    `score_reason_code_2` STRING COMMENT 'Secondary reason code explaining the score result. Second adverse action factor per FCRA requirements.',
    `score_reason_code_3` STRING COMMENT 'Tertiary reason code explaining the score result. Third adverse action factor per FCRA requirements.',
    `score_reason_code_4` STRING COMMENT 'Quaternary reason code explaining the score result. Fourth adverse action factor per FCRA requirements.',
    `score_run_code` STRING COMMENT 'Unique identifier for the scoring batch or run. Enables traceability and audit of scoring execution.',
    `score_timestamp` TIMESTAMP COMMENT 'Date and time when the risk score was calculated. Business event timestamp for the scoring event.',
    `scoring_engine` STRING COMMENT 'Name of the scoring engine or platform that executed the model (e.g., ISO ERC, Earnix, proprietary).',
    `state_code` STRING COMMENT 'Two-letter US state code where the risk is located. Determines regulatory rules and scoring factors.',
    `territory_score` DECIMAL(10,4) COMMENT 'Component score based on geographic territory risk factors including crime, weather, and loss history.',
    `total_incurred_3yr` DECIMAL(15,2) COMMENT 'Total incurred loss amount (paid plus reserves) for claims in the prior 3 years. Measures loss severity.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this risk score record was last modified. Audit trail field.',
    `uw_referral_flag` BOOLEAN COMMENT 'Indicates whether this score triggered a referral to manual underwriting review. True if referral required.',
    `uw_referral_reason` STRING COMMENT 'Business reason for underwriting referral. Describes which rule or threshold triggered manual review.',
    `years_with_prior_carrier` BIGINT COMMENT 'Number of years the applicant was insured with their prior carrier. Indicates stability and insurability.',
    CONSTRAINT pk_underwriting_risk_score PRIMARY KEY(`underwriting_risk_score_id`)
) COMMENT 'UW risk scoring result for a submission or insured risk. Grain: one row per scoring event. Captures model version, composite score, component scores (COPE, MVR, CLUE), and score band classification.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` (
    `quote_id` BIGINT COMMENT 'Unique identifier for the insurance quote. Primary key.',
    `agency_id` BIGINT COMMENT 'Identifier of the agency through which the quote was submitted.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Quotes are priced with catastrophe load factors based on the risks cat zone. Rating worksheets apply zone-specific surcharges for wind, earthquake, and other cat perils.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Quote rating uses geography for territory assignment, tax jurisdiction determination, and regulatory filing compliance.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Quotes are classified by line of business for premium aggregation, loss ratio analysis, and regulatory reporting.',
    `party_id` BIGINT COMMENT 'Identifier of the underwriter who reviewed and approved the quote.',
    `producers_producer_id` BIGINT COMMENT 'Identifier of the producer or agent who submitted the quote request.',
    `submission_id` BIGINT COMMENT 'Reference to the submission from which this quote was generated.',
    `base_premium_amount` DECIMAL(15,2) COMMENT 'Base premium before application of discounts, surcharges, taxes, and fees.',
    `binding_authority_flag` BOOLEAN COMMENT 'Indicates whether the producer has authority to bind this quote without further underwriter approval.',
    `bound_by_user_code` BIGINT COMMENT 'Identifier of the user who bound the quote.',
    `bound_timestamp` TIMESTAMP COMMENT 'Timestamp when the quote was bound and converted to a policy.',
    `commission_amount` DECIMAL(15,2) COMMENT 'Estimated commission amount payable to the producer if the quote is bound.',
    `commission_rate` DECIMAL(5,4) COMMENT 'Commission rate percentage payable to the producer if the quote is bound.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the quote record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this quote.. Valid values are `USD|CAD|EUR|GBP|AUD`',
    `decline_reason` STRING COMMENT 'Reason the quote was declined if status is declined.',
    `distribution_channel` STRING COMMENT 'Channel through which the quote was originated and distributed.. Valid values are `direct|captive_agent|independent_agent|broker|online|affinity`',
    `effective_date` DATE COMMENT 'Proposed effective date when coverage would begin if the quote is bound.',
    `expiration_date` DATE COMMENT 'Proposed expiration date when coverage would end if the quote is bound.',
    `expiry_date` DATE COMMENT 'Date after which the quote is no longer valid for binding.',
    `fee_amount` DECIMAL(15,2) COMMENT 'Total fees included in the quoted premium, such as policy fees and stamping fees.',
    `loss_free_years` BIGINT COMMENT 'Number of consecutive years without a claim, used for rating and discount eligibility.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the quote record was last modified.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code identifying the insurer issuing the quote.',
    `notes` STRING COMMENT 'Free-text notes or comments entered by the underwriter or producer regarding the quote.',
    `number` STRING COMMENT 'Business-facing unique quote number displayed to producers and customers.',
    `payment_plan_code` STRING COMMENT 'Code representing the payment plan offered with this quote.',
    `policy_type_code` STRING COMMENT 'Code representing the policy type or product offering.',
    `prior_carrier_name` STRING COMMENT 'Name of the insurance carrier that previously insured the risk, if applicable.',
    `prior_expiration_date` DATE COMMENT 'Expiration date of the prior policy, used to assess continuity of coverage.',
    `prior_policy_number` STRING COMMENT 'Policy number from the prior carrier, used for continuity and loss history verification.',
    `quote_date` DATE COMMENT 'Date the quote was generated and presented to the customer or producer.',
    `quote_status` STRING COMMENT 'Current lifecycle status of the quote.. Valid values are `draft|quoted|bound|declined|expired|withdrawn`',
    `quoted_premium_amount` DECIMAL(15,2) COMMENT 'Total premium amount quoted to the customer, including all charges, taxes, and fees.',
    `rate_effective_date` DATE COMMENT 'Effective date of the rate table or pricing rules used to generate this quote.',
    `rating_engine_version` STRING COMMENT 'Version of the rating engine or pricing algorithm used to calculate the quoted premium.',
    `rating_tier` STRING COMMENT 'Risk tier assigned during underwriting that determines pricing level.. Valid values are `preferred|standard|non_standard|declined`',
    `referral_flag` BOOLEAN COMMENT 'Indicates whether the quote was referred to senior underwriting for manual review.',
    `referral_reason` STRING COMMENT 'Business reason why the quote was referred for manual underwriting review.',
    `risk_score` DECIMAL(5,2) COMMENT 'Numeric risk score calculated by the rating engine, used for pricing and underwriting decisions.',
    `state_code` STRING COMMENT 'Two-letter state code where the risk is domiciled and coverage will be written.',
    `tax_amount` DECIMAL(15,2) COMMENT 'Total tax amount included in the quoted premium.',
    `version` BIGINT COMMENT 'Version number of the quote, incremented when quote is re-rated or modified.',
    CONSTRAINT pk_quote PRIMARY KEY(`quote_id`)
) COMMENT 'Priced insurance proposal generated from a submission. Grain: one row per quote. Captures quoted premium, LOB, effective date, expiration date, quote status, and binding eligibility flag.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` (
    `quote_coverage_id` BIGINT COMMENT 'Unique identifier for the quote coverage line. Primary key. Grain: one row per coverage per quote.',
    `bound_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Quote coverages become bound policy coverages when a quote is accepted. This lineage link enables tracking quote-to-policy conversion, comparing quoted vs bound terms, and supporting audit',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Each coverage protects against specific perils (wind, earthquake, flood). Underwriters and actuaries need peril-level exposure aggregation for catastrophe modeling and reinsurance',
    `coverage_form_id` BIGINT COMMENT 'Foreign key to the coverage form master. Identifies the ISO or proprietary form attached to this coverage line.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Premium amounts on quote coverages must reference the currency master for multi-currency rating, financial reporting, and regulatory filings.',
    `insured_risk_id` BIGINT COMMENT 'Foreign key to the insured risk. Links this coverage to the specific property, vehicle, or other exposure being covered.',
    `quote_id` BIGINT COMMENT 'Foreign key to the parent quote. Links this coverage line to the quote proposal.',
    `quote_option_id` BIGINT COMMENT 'Foreign key linking to coverage.quote_option. Business justification: Coverage can be associated with a specific quote option/scenario. Many coverages can belong to one option.',
    `rating_worksheet_id` BIGINT COMMENT 'Foreign key linking to coverage.rating_worksheet. Business justification: Each coverage line can have its own rating calculation. FK associates coverage with its rating worksheet.',
    `aggregate_limit_amount` DECIMAL(18,2) COMMENT 'Maximum amount the insurer will pay for all claims during the policy term. Null if no aggregate limit applies.',
    `class_code` STRING COMMENT 'ISO or NCCI class code for this coverage. Used in rating and risk classification.',
    `coinsurance_percentage` DECIMAL(5,2) COMMENT 'Percentage of loss shared by the insured after deductible. Null if no coinsurance applies.',
    `condition_codes` STRING COMMENT 'Comma-separated list of condition codes applied to this coverage. References standard condition forms.',
    `coverage_basis` STRING COMMENT 'Trigger basis for the coverage. Occurrence-based or claims-made, determining when coverage applies.. Valid values are `occurrence|claims_made|claims_made_reported|aggregate|per_event`',
    `coverage_code` STRING COMMENT 'Standard code identifying the coverage type. Examples: BIPD, COLL, COMP, FIRE, THEFT, GL, WC.',
    `coverage_description` STRING COMMENT 'Detailed description of what this coverage protects against, including scope and key terms.',
    `coverage_name` STRING COMMENT 'Human-readable name of the coverage. Examples: Bodily Injury, Property Damage, Collision, Comprehensive, Fire, General Liability.',
    `coverage_status` STRING COMMENT 'Current status of this coverage line within the quote. Indicates whether coverage was quoted, declined, or referred.. Valid values are `quoted|declined|referred|accepted|excluded`',
    `coverage_type` STRING COMMENT 'Classification of the coverage layer. Indicates whether this is primary, excess, umbrella, or supplemental coverage.. Valid values are `primary|excess|umbrella|supplemental|optional|mandatory`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this quote coverage record was first created in the system. Audit trail for record creation.',
    `declination_reason` STRING COMMENT 'Reason the applicant declined this coverage. Null if coverage was not declined.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Amount the insured must pay out-of-pocket before coverage applies. The deductible for this coverage line.',
    `deductible_applies_to` STRING COMMENT 'Scope of deductible application. Per occurrence, per claim, per policy term, or aggregate across all claims.. Valid values are `per_occurrence|per_claim|per_policy_term|aggregate`',
    `deductible_type` STRING COMMENT 'Structure of the deductible. Flat dollar amount, percentage of loss, franchise, disappearing, or aggregate annual.. Valid values are `flat|percentage|franchise|disappearing|aggregate`',
    `effective_date` DATE COMMENT 'Proposed effective date for this coverage if the quote is bound. Coverage inception date.',
    `endorsement_codes` STRING COMMENT 'Comma-separated list of endorsement form numbers modifying this coverage. References ISO or proprietary endorsements.',
    `exclusion_codes` STRING COMMENT 'Comma-separated list of exclusion codes applied to this coverage. References standard exclusion forms.',
    `expiration_date` DATE COMMENT 'Proposed expiration date for this coverage if the quote is bound. Coverage termination date.',
    `exposure_units` DECIMAL(18,2) COMMENT 'Quantity of exposure units used in premium calculation. Examples: number of vehicles, square footage, payroll amount.',
    `extended_reporting_period_months` BIGINT COMMENT 'Length of extended reporting period in months for claims-made coverage. Null if not applicable.',
    `form_edition_date` DATE COMMENT 'Edition date of the coverage form. ISO forms are versioned by edition date.',
    `form_number` STRING COMMENT 'ISO or proprietary form number for this coverage. Examples: CG0001, CA0001, HO0003.',
    `is_declined` BOOLEAN COMMENT 'Indicates whether the applicant declined this optional coverage. True if declined, false otherwise.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether this coverage is mandatory by law or regulation. True if required, false if optional.',
    `limit_amount` DECIMAL(18,2) COMMENT 'Maximum amount the insurer will pay under this coverage. The policy limit for this coverage line.',
    `limit_type` STRING COMMENT 'Structure of the limit. Per occurrence, per claim, aggregate annual, combined single limit, or split limits.. Valid values are `per_occurrence|per_claim|aggregate|combined_single|split`',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this quote coverage record was last modified. Audit trail for record updates.',
    `per_accident_limit_amount` DECIMAL(18,2) COMMENT 'Maximum amount payable per accident or occurrence. Null if not applicable.',
    `per_person_limit_amount` DECIMAL(18,2) COMMENT 'Maximum amount payable per person for bodily injury or medical payments. Null if not applicable.',
    `premium_basis` STRING COMMENT 'Rating basis for premium calculation. Examples: per vehicle, per square foot, per payroll dollar, per revenue dollar, flat.',
    `quoted_date` DATE COMMENT 'Date this coverage line was quoted. Business event timestamp for the quote generation.',
    `quoted_premium_amount` DECIMAL(18,2) COMMENT 'Premium amount quoted for this coverage line. Coverage-level premium before taxes and fees.',
    `rate` DECIMAL(12,6) COMMENT 'Unit rate applied to the exposure base to calculate premium. Rate per unit of exposure.',
    `retroactive_date` DATE COMMENT 'Retroactive date for claims-made coverage. Claims arising from incidents before this date are not covered.',
    `self_insured_retention_amount` DECIMAL(18,2) COMMENT 'Self-insured retention amount the insured must pay before coverage applies. Differs from deductible in claims handling.',
    `territory_code` STRING COMMENT 'Rating territory code for this coverage. Used in premium calculation and catastrophe exposure aggregation.',
    `underwriter_notes` STRING COMMENT 'Free-text notes from the underwriter regarding this coverage line. May include special terms, conditions, or referral reasons.',
    `valuation_method` STRING COMMENT 'Method used to value losses under this coverage. Actual cash value, replacement cost, agreed value, stated amount, or market value.. Valid values are `actual_cash_value|replacement_cost|agreed_value|stated_amount|market_value`',
    `waiting_period_days` BIGINT COMMENT 'Number of days before coverage becomes effective after policy inception. Null if no waiting period applies.',
    CONSTRAINT pk_quote_coverage PRIMARY KEY(`quote_coverage_id`)
) COMMENT 'Coverage line proposed within a quote: quoted limit, deductible, form number, and coverage-level premium. Junction between quote and coverage form. Grain: one row per coverage per quote; prevents premium fan-out.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` (
    `quote_option_id` BIGINT COMMENT 'Unique identifier for the quote option. Primary key.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Quote options present alternative premium structures in specific currencies for comparative selection.',
    `quote_id` BIGINT COMMENT 'Parent quote to which this option belongs.',
    `quoted_by_party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Quote option creation attribution for producer performance tracking (quote-to-bind ratio), pricing governance (who quoted what rates), and commission calculation validation.',
    `base_premium_amount` DECIMAL(15,2) COMMENT 'Base premium before taxes, fees, and surcharges for this option.',
    `coinsurance_percentage` DECIMAL(5,2) COMMENT 'Coinsurance percentage applicable to this option, typically for property coverage.',
    `commission_amount` DECIMAL(15,2) COMMENT 'Producer commission payable on this option if bound.',
    `commission_rate` DECIMAL(5,4) COMMENT 'Commission rate as a decimal applied to the premium for this option.',
    `coverage_package_code` STRING COMMENT 'Internal or ISO code representing the bundled coverage package offered in this option.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this quote option record was first created in the system.',
    `declination_reason` STRING COMMENT 'Reason code or narrative if this option was declined by the prospect or withdrawn by the insurer.',
    `deductible_amount` DECIMAL(15,2) COMMENT 'Primary deductible amount for this option. May be per-occurrence or aggregate depending on coverage.',
    `down_payment_amount` DECIMAL(15,2) COMMENT 'Initial down payment required to bind this option.',
    `effective_date` DATE COMMENT 'Proposed effective date when coverage under this option would begin if bound.',
    `expiration_date` DATE COMMENT 'Proposed expiration date when coverage under this option would end.',
    `fee_amount` DECIMAL(15,2) COMMENT 'Total fees and surcharges applied to this option, such as policy fees or stamping fees.',
    `installment_amount` DECIMAL(15,2) COMMENT 'Amount of each subsequent installment payment for this option.',
    `installment_count` BIGINT COMMENT 'Number of installment payments for this option under the selected payment plan.',
    `is_default_option` BOOLEAN COMMENT 'Indicates whether this is the default or recommended option presented to the prospect.',
    `is_selected` BOOLEAN COMMENT 'Indicates whether the prospect selected this option for binding.',
    `limit_amount` DECIMAL(15,2) COMMENT 'Primary coverage limit for this option. May represent per-occurrence, aggregate, or total insured value.',
    `limit_type` STRING COMMENT 'Type of limit structure: per occurrence, aggregate, combined single limit, split limit, or blanket.. Valid values are `per_occurrence|aggregate|combined_single_limit|split_limit|blanket`',
    `lob` STRING COMMENT 'Insurance line of business for this option: personal auto, commercial auto, homeowners, commercial property, general liability, or workers compensation.. Valid values are `personal_auto|commercial_auto|homeowners|commercial_property|general_liability|workers_comp`',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this quote option record was last modified.',
    `option_description` STRING COMMENT 'Detailed narrative describing the coverage, limits, deductibles, and key features of this option.',
    `option_name` STRING COMMENT 'Business-friendly name or label for this option, such as Standard Coverage or Enhanced Protection.',
    `option_number` BIGINT COMMENT 'Sequential number of this option within the parent quote for ordering and display.',
    `option_status` STRING COMMENT 'Current status of this option: active, withdrawn, expired, bound, or declined.. Valid values are `active|withdrawn|expired|bound|declined`',
    `option_type` STRING COMMENT 'Classification of the option by packaging strategy: standard, enhanced, economy, custom, package, or a la carte.. Valid values are `standard|enhanced|economy|custom|package|ala_carte`',
    `payment_plan_code` STRING COMMENT 'Code identifying the payment plan offered with this option, such as full pay, monthly, quarterly.',
    `policy_form_code` STRING COMMENT 'ISO or proprietary form code identifying the coverage form used in this option, such as HO-3 or CGL.',
    `producer_code` STRING COMMENT 'Code identifying the producer or agency associated with this option.',
    `rating_class` STRING COMMENT 'Detailed rating classification code used to price this option.',
    `rating_tier` STRING COMMENT 'Underwriting tier assigned to this option: preferred, standard, non-standard, or high risk.. Valid values are `preferred|standard|non_standard|high_risk`',
    `sir_amount` DECIMAL(15,2) COMMENT 'Self-insured retention amount applicable to this option, if any.',
    `tax_amount` DECIMAL(15,2) COMMENT 'Total tax amount applied to this option premium.',
    `term_months` BIGINT COMMENT 'Policy term length in months for this option, typically 6 or 12.',
    `territory_code` STRING COMMENT 'Geographic territory code used for rating this option.',
    `total_premium_amount` DECIMAL(15,2) COMMENT 'Total premium for this option including all coverages, charges, taxes, and fees.',
    `underwriter_notes` STRING COMMENT 'Internal underwriting notes or rationale for this option configuration.',
    CONSTRAINT pk_quote_option PRIMARY KEY(`quote_option_id`)
) COMMENT 'Alternative pricing scenario or coverage option presented within a single quote (e.g., higher deductible, broader form). Enables multi-option proposals. One row per option per quote.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` (
    `rating_worksheet_id` BIGINT COMMENT 'Unique identifier for the rating worksheet. Grain: one row per rating run per quote or policy transaction.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Rating worksheets apply cat zone surcharges and load factors. Territory_code field exists but cat_zone provides the catastrophe-specific pricing context for wind, quake, and',
    `classification_code_id` BIGINT COMMENT 'Foreign key linking to shared.classification_code. Business justification: Rating worksheets apply base rates and factors from classification code tables for premium calculation.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Rating worksheets calculate premium for specific coverages during quote and policy transaction rating.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Rating calculations produce premium amounts in specific currencies; actuarial systems require currency reference for rate table application, conversion factors, and multi-currency policy',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Rating uses geography for territory assignment (territory_code, state_code fields exist). Geography provides hierarchical lookup for rate table selection and tax jurisdiction.',
    `override_user_party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Rating overrides require audit trail of which underwriter performed override for regulatory compliance (rate filing adherence), pricing governance, fraud detection, and E&O risk management.',
    `policy_transaction_id` BIGINT COMMENT 'Reference to the policy transaction (New Business, Renewal, Endorsement) for which this rating was performed.',
    `quote_id` BIGINT COMMENT 'Reference to the quote for which this rating worksheet was generated.',
    `rating_rule_set_id` BIGINT COMMENT 'Identifier of the specific rule set or rating plan applied in this calculation.',
    `submission_id` BIGINT COMMENT 'Reference to the submission that initiated this rating calculation.',
    `underwriting_risk_score_id` BIGINT COMMENT 'Foreign key linking to coverage.underwriting_risk_score. Business justification: Rating uses risk score as input to pricing. FK associates rating worksheet with the score used in calculation.',
    `unit_of_measure_id` BIGINT COMMENT 'Foreign key linking to shared.unit_of_measure. Business justification: Rating worksheets calculate premium using exposure bases measured in specific units (per $1000 payroll, per square foot, per vehicle).',
    `base_rate` DECIMAL(18,6) COMMENT 'Starting rate from the rate table before application of any surcharges, credits, or modifiers.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this rating worksheet record was first created in the system.',
    `deductible_credit_factor` DECIMAL(10,4) COMMENT 'Credit factor applied for higher deductibles, reducing premium to reflect reduced insurer exposure.',
    `experience_modifier` DECIMAL(10,4) COMMENT 'Experience modification factor applied based on loss history, typically used in commercial lines and workers compensation.',
    `exposure_base` DECIMAL(18,6) COMMENT 'Quantity of exposure units used in the rating calculation (e.g., payroll for WC, vehicle count for auto, square footage for property).',
    `final_premium` DECIMAL(18,2) COMMENT 'Final premium amount after minimum premium rules and any manual overrides, representing the amount to be charged.',
    `increased_limits_factor` DECIMAL(10,4) COMMENT 'Factor applied when coverage limits exceed the base limit, reflecting increased exposure.',
    `lob` STRING COMMENT 'Insurance line of business for which this rating was performed.. Valid values are `personal_auto|commercial_auto|homeowners|commercial_property|general_liability|workers_comp`',
    `manual_premium` DECIMAL(18,2) COMMENT 'Premium calculated by applying the base rate to the exposure base before any modifications.',
    `minimum_premium` DECIMAL(18,2) COMMENT 'Minimum premium threshold for this policy or coverage, below which the rated premium cannot fall.',
    `minimum_premium_applied_flag` BOOLEAN COMMENT 'Indicator whether the minimum premium override was applied because the rated premium fell below the threshold.',
    `override_flag` BOOLEAN COMMENT 'Indicator whether the rating calculation was manually overridden by an underwriter or authorized user.',
    `override_reason_code` STRING COMMENT 'Code indicating the reason for manual override of the rating calculation.',
    `override_timestamp` TIMESTAMP COMMENT 'Date and time when the manual override was applied.',
    `policy_type_code` STRING COMMENT 'Code identifying the specific policy type or product being rated (e.g., HO3, PAP, BOP, CGL).',
    `rate_table_effective_date` DATE COMMENT 'Effective date of the rate tables used in this calculation.',
    `rate_table_version` STRING COMMENT 'Version identifier of the rate tables applied in this rating calculation, critical for audit and regulatory compliance.',
    `rated_premium` DECIMAL(18,2) COMMENT 'Final calculated premium after all rating factors, surcharges, credits, and modifiers have been applied.',
    `rating_calculation_method` STRING COMMENT 'Method by which the rating was performed: fully automated, manual, or hybrid with human intervention.. Valid values are `manual|automated|hybrid`',
    `rating_effective_date` DATE COMMENT 'Effective date for which the rating calculation applies, typically the policy or coverage effective date.',
    `rating_engine_name` STRING COMMENT 'Name of the rating engine or pricing system that performed the calculation (e.g., ISO ERC, Earnix, proprietary engine).',
    `rating_engine_version` STRING COMMENT 'Version number of the rating engine software used for this calculation.',
    `rating_notes` STRING COMMENT 'Free-text notes or comments regarding the rating calculation, exceptions, or special considerations.',
    `rating_run_number` STRING COMMENT 'Business identifier for this rating calculation run, used for tracking and audit purposes.',
    `rating_status` STRING COMMENT 'Current status of the rating calculation workflow.. Valid values are `pending|in_progress|completed|failed|rejected|overridden`',
    `rating_timestamp` TIMESTAMP COMMENT 'Date and time when the rating calculation was executed.',
    `schedule_modifier` DECIMAL(10,4) COMMENT 'Schedule rating modifier applied for specific risk characteristics at underwriter discretion.',
    `state_code` STRING COMMENT 'Two-letter state code where the risk is domiciled, used for jurisdiction-specific rating rules.',
    `territory_code` STRING COMMENT 'Rating territory code within the state, used for geographic risk segmentation.',
    `total_credit_amount` DECIMAL(18,2) COMMENT 'Sum of all credits or discounts applied to reduce the premium (e.g., multi-policy, safety features, claims-free).',
    `total_surcharge_amount` DECIMAL(18,2) COMMENT 'Sum of all surcharges applied to the manual premium (e.g., for claims history, risk characteristics).',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this rating worksheet record was last modified.',
    `validation_error_message` STRING COMMENT 'Error or warning message generated during validation of the rating calculation.',
    `validation_status` STRING COMMENT 'Status of validation checks performed on the rating calculation to ensure accuracy and compliance.. Valid values are `passed|failed|warning|pending`',
    CONSTRAINT pk_rating_worksheet PRIMARY KEY(`rating_worksheet_id`)
) COMMENT 'Detailed rating calculation produced by the rating engine for a quote or policy transaction: rate table version, base rate, surcharges, credits, and final rated premium. Grain: one row per rating run per quote.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` (
    `rating_factor_id` BIGINT COMMENT 'Unique identifier for the rating factor record.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Rating factors are often peril-specific (wind deductible credit, earthquake increased limits factor, flood base rate). Peril provides standardized taxonomy for factor application.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Rating factors are defined and filed by line of business for regulatory compliance.',
    `override_user_party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Factor-level overrides (schedule rating, experience mod adjustments) require user attribution for regulatory audit (rate filing compliance), pricing integrity validation, and underwriting',
    `rating_worksheet_id` BIGINT COMMENT 'Foreign key to the parent rating worksheet that contains this factor.',
    `calculation_formula` STRING COMMENT 'Mathematical expression or rule describing how this factor is computed or applied in the rating algorithm.',
    `coverage_code` STRING COMMENT 'Specific coverage or peril code to which this factor applies (e.g., BI, PD, COLL, COMP).',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this rating factor record was first created in the system.',
    `effective_date` DATE COMMENT 'Date when this rating factor becomes effective for use in premium calculations.',
    `expiration_date` DATE COMMENT 'Date when this rating factor expires and is no longer valid for use in premium calculations.',
    `factor_basis` STRING COMMENT 'The underlying risk characteristic or attribute that this factor is based on (e.g., ZIP code, NAICS code, loss history).',
    `factor_category` STRING COMMENT 'Classification of the factor type within the rating algorithm structure. [ENUM-REF-CANDIDATE: base_rate|territory|class_code|experience_mod|schedule_credit|schedule_debit|coverage_adjustment|limit_factor|deductible_credit — 9 candidates stripped; promote',
    `factor_code` STRING COMMENT 'Short code or abbreviation identifying the factor type for system processing and reporting.',
    `factor_description` STRING COMMENT 'Detailed explanation of what the factor represents and how it impacts the premium calculation.',
    `factor_name` STRING COMMENT 'Business name of the rating factor (e.g., Territory Factor, Class Code Factor, Experience Modification).',
    `factor_sequence` BIGINT COMMENT 'Ordinal position of this factor within the rating worksheet calculation sequence.',
    `factor_source` STRING COMMENT 'Origin of the factor value (ISO table, proprietary rating plan, manual underwriter override, actuarial model, or state filing).. Valid values are `iso_table|proprietary_table|manual_override|actuarial_model|state_filing`',
    `factor_type` STRING COMMENT 'Indicates how the factor value is applied in the calculation (multiplicative, additive, percentage, or flat).. Valid values are `multiplier|additive|percentage|flat_amount`',
    `factor_value` DECIMAL(18,6) COMMENT 'Numeric value of the rating factor applied in the premium calculation (multiplier or additive amount).',
    `filing_number` STRING COMMENT 'Regulatory filing reference number under which this factor was approved by the state Department of Insurance (DOI).',
    `is_filed` BOOLEAN COMMENT 'Indicates whether this factor is part of a state-filed rating plan and subject to regulatory approval.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether this factor must be applied per regulatory or underwriting guidelines (true) or is optional (false).',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this rating factor record was last updated.',
    `max_factor_value` DECIMAL(18,6) COMMENT 'Maximum allowable value for this factor, enforcing underwriting or regulatory constraints.',
    `min_factor_value` DECIMAL(18,6) COMMENT 'Minimum allowable value for this factor, enforcing underwriting or regulatory constraints.',
    `override_reason` STRING COMMENT 'Explanation provided by the underwriter if this factor was manually overridden from the standard table value.',
    `override_timestamp` TIMESTAMP COMMENT 'Date and time when the manual override was applied to this rating factor.',
    `rating_factor_status` STRING COMMENT 'Current lifecycle status of the rating factor within the rating engine.. Valid values are `active|inactive|pending_approval|superseded`',
    `state_code` STRING COMMENT 'Two-letter US state code where this rating factor applies, ensuring jurisdiction-specific compliance.',
    `table_effective_date` DATE COMMENT 'Date when the rating table version became effective for use in premium calculations.',
    `table_name` STRING COMMENT 'Name of the rating table or rule set from which this factor was retrieved.',
    `table_version` STRING COMMENT 'Version identifier of the rating table used to derive this factor, ensuring auditability and regulatory compliance.',
    CONSTRAINT pk_rating_factor PRIMARY KEY(`rating_factor_id`)
) COMMENT 'Individual rating factor applied within a rating worksheet (e.g., territory factor, class factor, experience mod, schedule credit). One row per factor per worksheet. Supports full rate reconstruction.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` (
    `uw_condition_id` BIGINT COMMENT 'Unique identifier for the underwriting condition record.',
    `clearance_check_id` BIGINT COMMENT 'Foreign key linking to coverage.clearance_check. Business justification: Conditions can be imposed based on clearance check results. FK references the check that triggered the condition. Nullable YES (not all conditions stem from clearance checks).',
    `coverage_id` BIGINT COMMENT 'Reference to the specific coverage to which this condition applies, if coverage-specific.',
    `eligibility_check_id` BIGINT COMMENT 'Foreign key linking to coverage.eligibility_check. Business justification: Conditions can be imposed based on eligibility check results. FK references the check that triggered the condition.',
    `inspection_order_id` BIGINT COMMENT 'Foreign key linking to coverage.inspection_order. Business justification: Conditions can require inspections or be based on inspection findings. FK references the inspection (e.g., roof replacement required per inspection findings).',
    `insured_risk_id` BIGINT COMMENT 'Reference to the specific insured risk to which this condition applies, if risk-specific.',
    `loss_history_id` BIGINT COMMENT 'Foreign key linking to coverage.loss_history. Business justification: Conditions can be imposed based on specific prior losses. FK references the loss that triggered the condition (e.g., must install sprinkler system due to prior fire loss).',
    `policy_id` BIGINT COMMENT 'Reference to the policy if the condition carries forward post-binding.',
    `quote_id` BIGINT COMMENT 'Reference to the quote to which this underwriting condition applies, if bound to a quote.',
    `submission_id` BIGINT COMMENT 'Reference to the submission to which this underwriting condition applies.',
    `term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Underwriting conditions are imposed at term level (e.g., roof inspection required by renewal, install sprinkler system by policy anniversary).',
    `uw_approved_by_underwriter_party_id` BIGINT COMMENT 'Reference to the underwriter or manager who approved the condition or its waiver.',
    `uw_decision_id` BIGINT COMMENT 'Foreign key linking to coverage.uw_decision. Business justification: Conditions are imposed as part of UW decision. Many conditions can stem from one decision. FK captures the decision that imposed this condition.',
    `uw_party_id` BIGINT COMMENT 'Reference to the underwriter party who imposed this condition.',
    `uw_referred_to_underwriter_party_id` BIGINT COMMENT 'Reference to the senior underwriter or manager to whom the condition was referred.',
    `uw_waived_by_underwriter_party_id` BIGINT COMMENT 'Reference to the underwriter party who waived this condition.',
    `approval_date` DATE COMMENT 'Date on which the condition or its waiver was approved by the authorized party.',
    `condition_category` STRING COMMENT 'Broad category grouping the nature of the condition for reporting and analytics. [ENUM-REF-CANDIDATE: loss_control|protective_device|occupancy|construction|exposure_mitigation|documentation|financial|other — 8 candidates stripped; promote to reference',
    `condition_code` STRING COMMENT 'Standardized code representing the condition type, often from ISO or carrier-specific code tables.',
    `condition_description` STRING COMMENT 'Detailed narrative describing the specific requirement or restriction imposed by the underwriter.',
    `condition_number` STRING COMMENT 'Business-facing identifier or sequence number for the condition within the submission or quote.',
    `condition_status` STRING COMMENT 'Current fulfillment status of the underwriting condition.. Valid values are `pending|fulfilled|waived|expired|not_fulfilled|cancelled`',
    `condition_type` STRING COMMENT 'Classification of the underwriting condition imposed by the underwriter.. Valid values are `warranty|requirement|restriction|endorsement_mandatory|survey_required|inspection_required`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the underwriting condition record was first created in the system.',
    `document_reference` STRING COMMENT 'Reference to the document or evidence submitted to fulfill the condition.',
    `due_date` DATE COMMENT 'Date by which the condition must be fulfilled or satisfied.',
    `effective_date` DATE COMMENT 'Date from which the condition becomes effective or applicable.',
    `expiration_date` DATE COMMENT 'Date on which the condition expires or is no longer applicable.',
    `fulfilled_date` DATE COMMENT 'Date on which the condition was marked as fulfilled or satisfied.',
    `fulfillment_method` STRING COMMENT 'Method or mechanism by which the condition is expected to be fulfilled. [ENUM-REF-CANDIDATE: document_upload|inspection|survey|attestation|endorsement|payment|other — 7 candidates stripped; promote to reference product]',
    `fulfillment_notes` STRING COMMENT 'Additional notes or comments regarding the fulfillment of the condition.',
    `imposed_date` DATE COMMENT 'Date on which the underwriting condition was imposed or added to the submission or quote.',
    `is_binding_condition` BOOLEAN COMMENT 'Indicates whether the condition must be fulfilled before the policy can be bound.',
    `is_renewal_condition` BOOLEAN COMMENT 'Indicates whether the condition must be fulfilled before the policy can be renewed.',
    `line_of_business` STRING COMMENT 'Line of business to which this condition applies, such as Commercial General Liability or Personal Auto Policy.',
    `modified_by_user_code` STRING COMMENT 'Identifier of the user or system process that last modified the condition record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the underwriting condition record was last modified or updated.',
    `premium_impact_amount` DECIMAL(15,2) COMMENT 'Dollar amount by which the premium is adjusted if the condition is fulfilled or not fulfilled.',
    `premium_impact_percentage` DECIMAL(5,2) COMMENT 'Percentage by which the premium is adjusted if the condition is fulfilled or not fulfilled.',
    `priority` STRING COMMENT 'Priority level assigned to the condition for tracking and fulfillment sequencing.. Valid values are `critical|high|medium|low`',
    `referral_date` DATE COMMENT 'Date on which the condition was referred to senior underwriting or management.',
    `referral_required` BOOLEAN COMMENT 'Indicates whether the condition requires referral to senior underwriting or management for approval.',
    `system_source` STRING COMMENT 'Source system or module from which the condition record originated, such as Guidewire PolicyCenter or Duck Creek Policy.',
    `waived_date` DATE COMMENT 'Date on which the condition was waived by the underwriter or authorized party.',
    `waiver_reason` STRING COMMENT 'Explanation or justification for waiving the underwriting condition.',
    CONSTRAINT pk_uw_condition PRIMARY KEY(`uw_condition_id`)
) COMMENT 'Condition or requirement imposed by the underwriter on a submission or quote (e.g., loss control survey required, protective device warranty). Tracks fulfillment status and due date.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` (
    `loss_history_id` BIGINT COMMENT 'Unique identifier for the prior loss record.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Prior catastrophe losses (catastrophe_flag, catastrophe_code fields exist) link to specific cat events for loss history verification and underwriting surcharge',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Prior losses are categorized by peril (loss_cause_code field exists). Peril provides standardized taxonomy for underwriting evaluation and loss-free year calculation by peril type.',
    `claim_id` BIGINT COMMENT 'Foreign key to the current claim used to verify the prior loss record.',
    `coverage_type_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_type. Business justification: Prior loss history is categorized by coverage type for underwriting evaluation and risk scoring.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Prior loss amounts from CLUE/MVR reports and carrier loss runs are denominated in specific currencies.',
    `inspection_order_id` BIGINT COMMENT 'Foreign key linking to coverage.inspection_order. Business justification: Loss history may trigger or be validated by inspection. FK associates loss with the inspection order that investigated it. Nullable YES (not all losses trigger inspections).',
    `insured_risk_id` BIGINT COMMENT 'Insured risk (property, vehicle, driver) to which this prior loss applies.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Prior losses are classified by line of business for experience rating and loss development analysis.',
    `party_id` BIGINT COMMENT 'Party (applicant, named insured, driver) associated with this prior loss.',
    `submission_id` BIGINT COMMENT 'Submission to which this prior loss record is attached.',
    `verified_by_adjuster_id` BIGINT COMMENT 'Foreign key to the adjuster party who performed the verification.',
    `at_fault_flag` BOOLEAN COMMENT 'Indicates whether the applicant or insured party was determined to be at fault for the loss.',
    `catastrophe_code` STRING COMMENT 'Industry catastrophe event code if the loss was part of a declared CAT event.',
    `catastrophe_flag` BOOLEAN COMMENT 'Indicates whether the prior loss was part of a declared catastrophe event.',
    `claim_status` STRING COMMENT 'Status of the prior claim at the time of reporting (open, closed, settled, denied, withdrawn).. Valid values are `open|closed|settled|denied|withdrawn`',
    `clue_report_order_number` STRING COMMENT 'Order number for the CLUE report from which this loss record was extracted.',
    `coverage_type` STRING COMMENT 'Type of coverage under which the prior loss was claimed (collision, comprehensive, liability, property, etc.).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this loss history record was first created in the system.',
    `excluded_from_rating_flag` BOOLEAN COMMENT 'Indicates whether this prior loss is excluded from rating calculations (e.g., not-at-fault, CAT event).',
    `exclusion_reason` STRING COMMENT 'Reason the prior loss is excluded from rating (not at fault, catastrophe, outside lookback period).',
    `impact_on_current_claim` STRING COMMENT 'Assessment of how the verified prior loss information affects the handling or settlement of the current claim.',
    `impact_on_rating` STRING COMMENT 'Underwriting decision on how the prior loss impacts rating (surcharge, decline, refer, no impact, credit).. Valid values are `surcharge|decline|refer|no_impact|credit`',
    `incurred_amount` DECIMAL(18,2) COMMENT 'Total incurred amount (paid plus outstanding reserves) for the prior loss.',
    `lookback_period_months` BIGINT COMMENT 'Number of months in the lookback period for this loss type as defined by underwriting guidelines.',
    `loss_cause_code` STRING COMMENT 'Standardized code for the cause of loss (fire, theft, collision, liability, water damage, wind, hail).',
    `loss_cause_description` STRING COMMENT 'Human-readable description of the loss cause.',
    `loss_date` DATE COMMENT 'Date the prior loss event occurred.',
    `loss_description` STRING COMMENT 'Narrative description of the prior loss event as reported by applicant or third-party source.',
    `loss_free_years` BIGINT COMMENT 'Number of years since this loss occurred, used in loss-free discount calculations.',
    `loss_type` STRING COMMENT 'Classification of the loss by type (first party, third party, liability, property, auto, workers compensation).. Valid values are `first_party|third_party|liability|property|auto|workers_comp`',
    `mvr_report_order_number` STRING COMMENT 'Order number for the MVR report from which this loss record was extracted.',
    `paid_amount` DECIMAL(18,2) COMMENT 'Total amount paid on the prior loss claim by the carrier.',
    `prior_carrier_naic_code` STRING COMMENT 'Five-digit NAIC company code for the carrier that handled the prior loss.. Valid values are `^[0-9]{5}$`',
    `prior_carrier_name` STRING COMMENT 'Name of the insurance carrier that handled the prior loss claim.',
    `prior_policy_number` STRING COMMENT 'Policy number under which the prior loss was claimed.',
    `report_date` DATE COMMENT 'Date the loss history report (CLUE, MVR, or carrier inquiry) was generated.',
    `reserve_amount` DECIMAL(18,2) COMMENT 'Outstanding reserve amount on the prior loss at the time of reporting.',
    `surcharge_amount` DECIMAL(18,2) COMMENT 'Premium surcharge amount applied due to this prior loss.',
    `surcharge_percentage` DECIMAL(5,2) COMMENT 'Premium surcharge percentage applied due to this prior loss.',
    `underwriter_notes` STRING COMMENT 'Free-text notes entered by the underwriter regarding the prior loss and its impact on risk assessment.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this loss history record was last updated.',
    `variance_amount` DECIMAL(18,2) COMMENT 'Dollar difference between prior loss reported amount and verified claim amount, if applicable.',
    `variance_explanation` STRING COMMENT 'Adjuster notes explaining any discrepancies found between the prior loss record and actual claim data.',
    `verification_date` DATE COMMENT 'Date the prior loss record was verified by underwriting.',
    `verification_method` STRING COMMENT 'Method used to verify the prior loss (third-party report, carrier inquiry, applicant statement, document review). [Moved from loss_history: Verification method may differ by claim context (one claim uses carrier inquiry, another uses adjuster inspection). Valid values are `third_party_report|carrier_inquiry|applicant_statement|document_review`',
    `verification_status` STRING COMMENT 'Current status of the verification process comparing prior loss data to actual claim outcome.',
    `verified_flag` BOOLEAN COMMENT 'Indicates whether the prior loss has been verified by underwriting or third-party source. [Moved from loss_history: Verification is claim-specific. A prior loss may be verified against one claim but not another, so the flag belongs to the association, not',
    `within_lookback_flag` BOOLEAN COMMENT 'Indicates whether the prior loss falls within the applicable lookback period for underwriting and rating.',
    CONSTRAINT pk_loss_history PRIMARY KEY(`loss_history_id`)
) COMMENT 'Prior loss record for a submission or insured risk from CLUE, MVR, or applicant disclosure: loss date, cause, paid amount, open/closed status. Grain: one row per prior loss. Used in appetite and pricing.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` (
    `underwriting_mvr_report_id` BIGINT COMMENT 'Unique identifier for the Motor Vehicle Record report ordered during auto underwriting.',
    `riskexposure_driver_id` BIGINT COMMENT 'Foreign key linking to riskexposure.driver. Business justification: MVR reports are ordered for specific drivers during auto underwriting. Direct link to driver entity is essential for driver-specific underwriting decisions, rate tier assignments',
    `submission_id` BIGINT COMMENT 'Reference to the submission for which this Motor Vehicle Record report was ordered.',
    `underwriting_driver_party_id` BIGINT COMMENT 'Reference to the party record of the driver whose Motor Vehicle Record was pulled.',
    `underwriting_party_id` BIGINT COMMENT 'Reference to the underwriter who reviewed the Motor Vehicle Record report.',
    `accident_count` BIGINT COMMENT 'Total number of accidents reported on the Motor Vehicle Record within the review period.',
    `at_fault_accident_count` BIGINT COMMENT 'Number of accidents where the driver was determined to be at fault.',
    `cost_amount` DECIMAL(10,2) COMMENT 'Cost paid to the vendor for obtaining the Motor Vehicle Record report.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the Motor Vehicle Record report record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter International Organization for Standardization currency code for the Motor Vehicle Record cost.. Valid values are `USD|CAD|EUR|GBP|AUD`',
    `decline_reason` STRING COMMENT 'Explanation of why the Motor Vehicle Record findings recommend declination, such as excessive violations or suspended license.',
    `decline_recommended_flag` BOOLEAN COMMENT 'Indicates whether the Motor Vehicle Record findings suggest the submission should be declined.',
    `driver_license_class` STRING COMMENT 'License class or type indicating the vehicle categories the driver is authorized to operate.',
    `driver_license_expiration_date` DATE COMMENT 'Date when the driver license expires or expired.',
    `driver_license_issue_date` DATE COMMENT 'Date when the driver license was originally issued.',
    `driver_license_number` STRING COMMENT 'Driver license number for which the Motor Vehicle Record was pulled.',
    `driver_license_state` STRING COMMENT 'State or jurisdiction that issued the driver license.',
    `driver_license_status` STRING COMMENT 'Current status of the driver license as reported in the Motor Vehicle Record.. Valid values are `valid|suspended|revoked|expired|restricted|cancelled`',
    `dui_dwi_count` BIGINT COMMENT 'Number of Driving Under the Influence or Driving While Intoxicated convictions reported on the Motor Vehicle Record.',
    `major_violation_count` BIGINT COMMENT 'Number of major violations such as Driving Under the Influence, reckless driving, or hit-and-run reported on the Motor Vehicle Record.',
    `minor_violation_count` BIGINT COMMENT 'Number of minor violations such as speeding or improper lane change reported on the Motor Vehicle Record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the Motor Vehicle Record report record was last modified.',
    `most_recent_accident_date` DATE COMMENT 'Date of the most recent accident reported on the Motor Vehicle Record.',
    `most_recent_violation_date` DATE COMMENT 'Date of the most recent moving violation reported on the Motor Vehicle Record.',
    `mvr_score` BIGINT COMMENT 'Numeric risk score assigned by the vendor based on the driver driving history.',
    `mvr_tier` STRING COMMENT 'Risk tier classification assigned based on the Motor Vehicle Record findings.. Valid values are `preferred|standard|substandard|declined`',
    `referral_reason` STRING COMMENT 'Explanation of why the Motor Vehicle Record triggered a referral, such as multiple major violations or recent Driving Under the Influence.',
    `referral_required_flag` BOOLEAN COMMENT 'Indicates whether the Motor Vehicle Record findings trigger a referral to senior underwriter or special review.',
    `report_document_url` STRING COMMENT 'Uniform Resource Locator pointing to the stored Motor Vehicle Record report document.',
    `report_order_date` DATE COMMENT 'Date when the Motor Vehicle Record report was ordered from the vendor.',
    `report_order_number` STRING COMMENT 'External order number or reference assigned by the Motor Vehicle Record vendor.',
    `report_received_date` DATE COMMENT 'Date when the Motor Vehicle Record report was received from the vendor.',
    `report_status` STRING COMMENT 'Current status of the Motor Vehicle Record report in the underwriting workflow.. Valid values are `ordered|received|reviewed|error|cancelled`',
    `review_period_years` BIGINT COMMENT 'Number of years of driving history covered by this Motor Vehicle Record report.',
    `reviewed_date` DATE COMMENT 'Date when the underwriter completed review of the Motor Vehicle Record report.',
    `surcharge_amount` DECIMAL(15,2) COMMENT 'Additional premium surcharge amount applied based on the Motor Vehicle Record findings.',
    `surcharge_percentage` DECIMAL(5,2) COMMENT 'Percentage surcharge applied to the base premium based on the Motor Vehicle Record findings.',
    `suspension_count` BIGINT COMMENT 'Number of times the driver license has been suspended within the review period.',
    `underwriter_notes` STRING COMMENT 'Free-text notes entered by the underwriter regarding the Motor Vehicle Record findings and their impact on the risk.',
    `uw_impact_flag` BOOLEAN COMMENT 'Indicates whether the Motor Vehicle Record findings materially impact the underwriting decision.',
    `vendor_name` STRING COMMENT 'Name of the vendor or service provider that supplied the Motor Vehicle Record report.. Valid values are `LexisNexis|Verisk|ISO|TransUnion|Experian|Other`',
    `vendor_report_number` STRING COMMENT 'Unique identifier assigned by the vendor to this Motor Vehicle Record report.',
    `violation_count` BIGINT COMMENT 'Total number of moving violations reported on the Motor Vehicle Record within the review period.',
    CONSTRAINT pk_underwriting_mvr_report PRIMARY KEY(`underwriting_mvr_report_id`)
) COMMENT 'Motor Vehicle Record report ordered for a driver during auto UW. Captures report order date, source, violation count, license status, and UW impact flag. One row per MVR order.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` (
    `inspection_order_id` BIGINT COMMENT 'Unique identifier for the inspection order record. Primary key.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Inspection requirements vary by cat zone (high-hazard zones require detailed COPE data, roof condition, and construction type verification for catastrophe modeling accuracy).',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Inspection vendor costs are tracked in specific currencies for expense allocation and vendor payment processing.',
    `driver_id` BIGINT COMMENT 'Foreign key to the driver whose MVR is being ordered, if applicable.',
    `inspection_insured_party_id` BIGINT COMMENT 'Foreign key to the party being insured and subject to the inspection.',
    `inspection_party_id` BIGINT COMMENT 'Foreign key to the underwriter who ordered the inspection.',
    `location_id` BIGINT COMMENT 'Foreign key to the property location being inspected, if applicable.',
    `ordering_agency_id` BIGINT COMMENT 'Foreign key linking to producers.agency. Business justification: Agencies often coordinate inspection orders as part of submission workflow or renewal servicing.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy for which this inspection was ordered, if applicable.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key linking to producers.producers_producer. Business justification: Inspections are frequently ordered or coordinated by the producer/agency in P&C operations.',
    `submission_id` BIGINT COMMENT 'Foreign key to the submission that triggered this inspection order.',
    `term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Inspections are ordered per term (initial term inspection at bind, renewal term re-inspection for property condition updates).',
    `vehicle_id` BIGINT COMMENT 'Foreign key to the vehicle being inspected or associated with the MVR order, if applicable.',
    `cancellation_reason` STRING COMMENT 'Reason the inspection order was cancelled, if applicable.',
    `completed_date` DATE COMMENT 'Date the inspection was completed by the vendor.',
    `construction_type` STRING COMMENT 'Type of construction as identified in the COPE inspection (e.g., frame, masonry, fire-resistive).',
    `cost_amount` DECIMAL(10,2) COMMENT 'Cost charged by the vendor for the inspection service.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the inspection order record was first created in the system.',
    `due_date` DATE COMMENT 'Target date by which the inspection report must be received to meet underwriting timelines.',
    `exposure_description` STRING COMMENT 'Description of external exposures as identified in the COPE inspection (e.g., proximity to hazards, wildfire risk).',
    `inspection_findings` STRING COMMENT 'Summary of key findings from the inspection report, including any risk concerns or recommendations.',
    `lob` STRING COMMENT 'Line of business for which the inspection is being performed (e.g., Homeowners, Commercial Property, Personal Auto).',
    `lob_code` STRING COMMENT 'Standardized code representing the line of business.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the inspection order record was last modified in the system.',
    `mvr_accident_count` BIGINT COMMENT 'Number of accidents found on the drivers MVR, if applicable.',
    `mvr_license_number` STRING COMMENT 'Drivers license number as reported on the MVR.',
    `mvr_license_status` STRING COMMENT 'Current status of the drivers license as reported on the MVR.. Valid values are `valid|suspended|revoked|expired|restricted`',
    `mvr_state` STRING COMMENT 'State that issued the drivers license and MVR report.',
    `mvr_violation_count` BIGINT COMMENT 'Number of violations found on the drivers MVR, if applicable.',
    `notes` STRING COMMENT 'Free-text notes or comments related to the inspection order, findings, or follow-up actions.',
    `occupancy_type` STRING COMMENT 'Occupancy classification as identified in the COPE inspection (e.g., residential, commercial, mixed-use).',
    `order_date` DATE COMMENT 'Date the inspection order was placed with the vendor.',
    `order_number` STRING COMMENT 'Business-facing unique order number assigned by the underwriting system or vendor.',
    `order_status` STRING COMMENT 'Current lifecycle status of the inspection order. [ENUM-REF-CANDIDATE: pending|ordered|scheduled|in_progress|completed|cancelled|failed — 7 candidates stripped; promote to reference product]',
    `order_type` STRING COMMENT 'Type of inspection ordered: property interior, exterior, COPE (Construction Occupancy Protection Exposure), MVR (Motor Vehicle Record), or combined. [ENUM-REF-CANDIDATE',
    `pass_fail_indicator` STRING COMMENT 'Indicator of whether the inspection passed, failed, or passed with conditions.. Valid values are `pass|fail|conditional`',
    `property_condition` STRING COMMENT 'Overall condition rating of the inspected property, if applicable.. Valid values are `excellent|good|fair|poor|unacceptable`',
    `protection_class` STRING COMMENT 'Fire protection class as identified in the COPE inspection (e.g., sprinklered, fire alarm, distance to fire station).',
    `received_date` DATE COMMENT 'Date the completed inspection report was received by the underwriting system.',
    `referral_reason` STRING COMMENT 'Reason the inspection findings triggered a referral, if applicable.',
    `referral_required_flag` BOOLEAN COMMENT 'Flag indicating whether the inspection findings require underwriter referral or management review.',
    `report_document_url` STRING COMMENT 'URL or file path to the stored inspection report document.',
    `report_format` STRING COMMENT 'Format of the inspection report document received from the vendor.. Valid values are `pdf|xml|json|acord_xml|proprietary`',
    `risk_score` DECIMAL(5,2) COMMENT 'Calculated risk score based on inspection findings, used in underwriting decision-making.',
    `roof_age_years` BIGINT COMMENT 'Age of the roof in years as determined by the inspection.',
    `roof_condition` STRING COMMENT 'Condition rating of the roof based on inspection findings.. Valid values are `excellent|good|fair|poor|needs_replacement`',
    `scheduled_date` DATE COMMENT 'Date the inspection is scheduled to be performed.',
    `vendor_code` STRING COMMENT 'Standardized code identifying the inspection vendor in the system.',
    `vendor_name` STRING COMMENT 'Name of the third-party vendor or service provider fulfilling the inspection order.',
    `vendor_reference_number` STRING COMMENT 'Vendors internal reference or tracking number for the inspection order.',
    CONSTRAINT pk_inspection_order PRIMARY KEY(`inspection_order_id`)
) COMMENT 'External UW report/order covering property inspection AND motor vehicle record (absorbs underwriting_mvr_report). Grain: one row per order. Captures order_type (interior/exterior/COPE/MVR), vendor, order date, status, findings, violation/license data, and';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` (
    `clearance_check_id` BIGINT COMMENT 'Unique identifier for each clearance and eligibility screening event performed on a submission.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Clearance includes cat zone validation against concentration limits and moratorium flags. Automated clearance rules check zone-level accumulation thresholds before binding.',
    `clearance_override_user_party_id` BIGINT COMMENT 'User ID of the underwriter who performed the manual override of the screening result.',
    `clearance_party_id` BIGINT COMMENT 'Identifier of the underwriter assigned to review or override the clearance screening results.',
    `primary_risk_appetite_rule_id` BIGINT COMMENT 'Foreign key linking to coverage.risk_appetite_rule. Business justification: Clearance check applies appetite rules (absorbed eligibility functionality). FK captures the primary rule that triggered the check result.',
    `submission_id` BIGINT COMMENT 'Foreign key to the submission being screened for clearance and eligibility.',
    `appetite_tier` STRING COMMENT 'Risk appetite classification tier assigned to the submission based on screening criteria.. Valid values are `preferred|standard|substandard|declined`',
    `check_duration_seconds` BIGINT COMMENT 'Total elapsed time in seconds for the clearance and eligibility screening process to complete.',
    `check_number` BIGINT COMMENT 'Sequential number of this clearance check within the submission lifecycle, supporting multiple screening iterations.',
    `check_status` STRING COMMENT 'Current processing status of the clearance check execution.. Valid values are `pending|in_progress|completed|failed|cancelled`',
    `check_timestamp` TIMESTAMP COMMENT 'Date and time when the clearance and eligibility screening was executed.',
    `check_type` STRING COMMENT 'Type of screening performed: clearance for duplicates, eligibility for risk appetite, or combined screening.. Valid values are `clearance|eligibility|combined|duplicate|risk_appetite`',
    `clearance_result` STRING COMMENT 'Overall result of the clearance screening: pass indicates no duplicates or conflicts detected.. Valid values are `pass|fail|refer|override`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the clearance check record was first created in the system.',
    `data_source` STRING COMMENT 'Source system or module from which the clearance check was initiated and data was retrieved.',
    `decision_code` STRING COMMENT 'Standardized code representing the final clearance and eligibility decision outcome.',
    `decision_reason` STRING COMMENT 'Detailed explanation of the clearance and eligibility decision, including contributing factors and rule outcomes.',
    `duplicate_detected_flag` BOOLEAN COMMENT 'Indicates whether a duplicate submission or policy was detected during clearance screening.',
    `duplicate_match_score` DECIMAL(5,2) COMMENT 'Confidence score for duplicate detection, ranging from 0.00 to 100.00, with higher values indicating stronger match.',
    `duplicate_policy_numbers` STRING COMMENT 'Comma-separated list of existing policy numbers identified as duplicates or conflicts.',
    `duplicate_submission_ids` STRING COMMENT 'Comma-separated list of submission IDs identified as potential duplicates during clearance.',
    `effective_date` DATE COMMENT 'Date from which the clearance and eligibility screening result is considered valid and applicable.',
    `eligibility_result` STRING COMMENT 'Overall eligibility determination based on risk appetite and underwriting guidelines evaluation.. Valid values are `eligible|ineligible|refer|conditional`',
    `expiration_date` DATE COMMENT 'Date after which the clearance screening result is no longer valid and must be re-evaluated.',
    `fail_flag` BOOLEAN COMMENT 'Indicates whether the submission failed clearance or eligibility screening and should be declined.',
    `failed_rule_ids` STRING COMMENT 'Comma-separated list of rule IDs that failed during screening, contributing to ineligibility or referral.',
    `lob` STRING COMMENT 'Insurance line of business for which clearance and eligibility screening was performed.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when the clearance check record was last modified or updated.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code of the insurer performing the clearance screening.',
    `notes` STRING COMMENT 'Free-text field for additional comments, observations, or context related to the clearance screening event.',
    `override_flag` BOOLEAN COMMENT 'Indicates whether an underwriter manually overrode the clearance or eligibility screening result.',
    `override_reason` STRING COMMENT 'Business justification provided by the underwriter for overriding the automated screening decision.',
    `override_timestamp` TIMESTAMP COMMENT 'Date and time when the underwriter override was recorded in the system.',
    `pass_flag` BOOLEAN COMMENT 'Indicates whether the submission passed all clearance and eligibility screening criteria without exceptions.',
    `product_code` STRING COMMENT 'Specific insurance product code being evaluated during clearance screening.',
    `referral_flag` BOOLEAN COMMENT 'Indicates whether the submission requires underwriter referral based on clearance or eligibility screening results.',
    `referral_reason` STRING COMMENT 'Business reason or rule trigger that caused the submission to be referred to an underwriter for manual review.',
    `risk_score` DECIMAL(5,2) COMMENT 'Calculated risk score from eligibility screening, used to determine appetite tier and referral requirements.',
    `risk_score_band` STRING COMMENT 'Categorical band or range into which the calculated risk score falls for classification purposes.',
    `rule_set_name` STRING COMMENT 'Name of the rule set configuration used for clearance and eligibility evaluation.',
    `rule_set_version` STRING COMMENT 'Version identifier of the clearance and eligibility rule set applied during this screening.',
    `state_code` STRING COMMENT 'Two-letter state code where the risk is domiciled, used for jurisdiction-specific clearance rules.',
    `triggered_rule_ids` STRING COMMENT 'Comma-separated list of all rule IDs that were triggered during clearance and eligibility screening.',
    CONSTRAINT pk_clearance_check PRIMARY KEY(`clearance_check_id`)
) COMMENT 'Submission screening result covering duplicate/clearance detection AND eligibility/risk-appetite evaluation (absorbs eligibility_check). Grain: one row per screening event per submission.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` (
    `submission_document_id` BIGINT COMMENT 'Unique identifier for the submission document. Primary key. One row per document attached to a submission.',
    `inspection_order_id` BIGINT COMMENT 'Foreign key linking to coverage.inspection_order. Business justification: Inspection reports are documents attached to submission. FK associates document with the inspection order that produced it.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key linking to producers.producers_producer. Business justification: Documents are frequently submitted BY the producer (applications, loss runs, inspection reports, certificates).',
    `riskexposure_insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: P&C underwriting requires risk-specific documentation (COPE reports, property appraisals, vehicle titles, engineering surveys, building inspection certificates) tracked per',
    `submission_id` BIGINT COMMENT 'Foreign key to the submission this document is attached to. Links document to parent submission record.',
    `submission_received_from_party_id` BIGINT COMMENT 'Party identifier of the external party from whom the document was received. May differ from uploader.',
    `submission_uploaded_by_party_id` BIGINT COMMENT 'Party identifier of the individual or organization that uploaded the document. Links to party master.',
    `submitting_agency_id` BIGINT COMMENT 'Foreign key linking to producers.agency. Business justification: Agencies are often the source of submission documents in P&C workflows. Direct agency tracking supports agency performance metrics (document completeness, timeliness), workflow routing',
    `approval_date` DATE COMMENT 'Date when the document was formally approved by authorized personnel.',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether formal approval is required for this document type before proceeding with underwriting.',
    `approved_by_user_code` STRING COMMENT 'System user identifier of the person who formally approved the document.',
    `archive_date` DATE COMMENT 'Date when the document was moved to archive storage or marked for long-term retention.',
    `checksum` STRING COMMENT 'Hash or checksum value of the document file for integrity verification and duplicate detection.',
    `confidential_flag` BOOLEAN COMMENT 'Indicates whether the document contains confidential or sensitive information requiring restricted access.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the document record was first created in the database. Audit trail field.',
    `submission_document_description` STRING COMMENT 'Detailed description of the document content, purpose, or context within the submission.',
    `document_category` STRING COMMENT 'High-level category grouping for the document. Used for organizing and filtering documents by business function.. Valid values are `application|supporting|financial|risk_assessment|regulatory|correspondence`',
    `document_date` DATE COMMENT 'Date shown on the document itself or the date the document was created by the originator.',
    `document_format` STRING COMMENT 'File format or MIME type of the document. Indicates the technical format for storage and retrieval. [ENUM-REF-CANDIDATE: PDF|JPEG|PNG|TIFF|DOCX|XLSX|XML|CSV|other — 9 candidates stripped; promote to reference product]',
    `document_name` STRING COMMENT 'Human-readable name or title of the document as provided by the submitter or system.',
    `document_number` STRING COMMENT 'Business-assigned unique number or code for the document within the submission context.',
    `document_source` STRING COMMENT 'Origin or provider of the document. Indicates who submitted or generated the document.. Valid values are `applicant|producer|underwriter|third_party|system_generated|external_vendor`',
    `document_status` STRING COMMENT 'Current lifecycle status of the document in the underwriting review workflow.. Valid values are `pending_review|under_review|approved|rejected|incomplete|archived`',
    `document_type` STRING COMMENT 'Classification of the document type. Indicates the nature and purpose of the document within underwriting workflow. [ENUM-REF-CANDIDATE: ACORD_125|ACORD_126|ACORD_140|loss_run|photo|financial_statement|schedule|inspection_report|other — 9 candidates',
    `effective_date` DATE COMMENT 'Date from which the document information is effective or applicable to the submission.',
    `expiration_date` DATE COMMENT 'Date when the document information expires or is no longer valid for underwriting purposes.',
    `external_reference_number` STRING COMMENT 'Reference number or identifier from an external system or third-party vendor associated with this document.',
    `extracted_text` STRING COMMENT 'Full text content extracted from the document via OCR or native text extraction for search and analysis.',
    `file_path` STRING COMMENT 'Storage location or URI where the document file is persisted in the document management system.',
    `file_size_bytes` BIGINT COMMENT 'Size of the document file in bytes. Used for storage management and upload validation.',
    `mandatory_flag` BOOLEAN COMMENT 'Indicates whether this document is mandatory for the submission to proceed through underwriting.',
    `modified_timestamp` TIMESTAMP COMMENT 'System timestamp when the document record was last modified. Audit trail field for change tracking.',
    `ocr_confidence_score` DECIMAL(5,2) COMMENT 'Confidence score from OCR processing indicating the accuracy of text extraction. Range 0.00 to 100.00.',
    `ocr_processed_flag` BOOLEAN COMMENT 'Indicates whether the document has been processed through optical character recognition for text extraction.',
    `page_count` BIGINT COMMENT 'Number of pages in the document. Used for completeness validation and processing estimation.',
    `purge_eligible_date` DATE COMMENT 'Date when the document becomes eligible for deletion per retention policy and regulatory requirements.',
    `rejection_reason` STRING COMMENT 'Explanation or code indicating why the document was rejected or deemed unacceptable.',
    `retention_period_years` BIGINT COMMENT 'Number of years the document must be retained per regulatory or business policy requirements.',
    `review_date` DATE COMMENT 'Date when the document review was completed by the underwriter.',
    `review_notes` STRING COMMENT 'Free-text notes or comments entered by the reviewer regarding the document content or quality.',
    `review_status` STRING COMMENT 'Status of underwriter review process for this document. Tracks progress through review workflow.. Valid values are `not_started|in_progress|completed|deferred|waived`',
    `review_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the document review was completed. Captures exact moment of review completion.',
    `reviewed_by_user_code` STRING COMMENT 'System user identifier of the underwriter or reviewer who evaluated the document.',
    `upload_date` DATE COMMENT 'Date when the document was uploaded or attached to the submission. Business event date.',
    `upload_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the document was uploaded to the system. Captures exact moment of document receipt.',
    `uploaded_by_user_code` STRING COMMENT 'System user identifier of the person who uploaded the document. Tracks accountability for document submission.',
    `vendor_name` STRING COMMENT 'Name of the third-party vendor or service provider that supplied or generated the document.',
    `version_number` BIGINT COMMENT 'Version number of the document if multiple versions have been submitted or revised.',
    CONSTRAINT pk_submission_document PRIMARY KEY(`submission_document_id`)
) COMMENT 'Document attached to a submission (ACORD applications, loss runs, photos, financials, schedules). Tracks document type, source, upload date, and review status. One row per document.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` (
    `bind_request_id` BIGINT COMMENT 'Unique identifier for the bind request. Primary key. Grain: one row per bind request.',
    `agency_id` BIGINT COMMENT 'Reference to the agency through which the bind request was submitted. Distribution channel tracking.',
    `bind_applicant_party_id` BIGINT COMMENT 'Reference to the party requesting to bind the policy. Primary insured or named insured.',
    `bind_party_id` BIGINT COMMENT 'Reference to the underwriter assigned to review and approve or reject the bind request.',
    `binder_id` BIGINT COMMENT 'Foreign key linking to coverage.binder. Business justification: Bind request results in a binder being issued when approved. 1 bind_request → 1 binder. FK populated when bind is approved and binder issued.',
    `bound_policy_id` BIGINT COMMENT 'Reference to the policy created when bind request was approved. Links bind request to issued policy.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the agent or broker submitting the bind request on behalf of the applicant.',
    `quote_id` BIGINT COMMENT 'Reference to the quote being bound. Links bind request to the quoted coverage and premium.',
    `submission_id` BIGINT COMMENT 'Reference to the originating submission. Traces bind request back to initial application.',
    `uw_decision_id` BIGINT COMMENT 'Foreign key linking to coverage.uw_decision. Business justification: Bind request follows from UW decision to approve. FK references the decision that authorized the bind.',
    `automated_bind_flag` BOOLEAN COMMENT 'Indicates whether the bind request was approved automatically by system rules without underwriter review.',
    `bind_approval_date` DATE COMMENT 'Date the underwriter or system approved the bind request. Policy issuance proceeds after approval.',
    `bind_approval_timestamp` TIMESTAMP COMMENT 'Precise date and time the bind request was approved. Used for SLA compliance and audit trail.',
    `bind_authority_level` STRING COMMENT 'Authority level required to approve this bind request. Determined by risk characteristics and premium size.. Valid values are `automated|agent|underwriter|senior_underwriter|manager|executive`',
    `bind_conditions_met_flag` BOOLEAN COMMENT 'Indicates whether all required bind conditions have been satisfied. Must be true for bind approval.',
    `bind_conditions_required` STRING COMMENT 'List of conditions that must be satisfied before bind approval. Inspection, loss control, additional documentation.',
    `bind_rejection_date` DATE COMMENT 'Date the bind request was rejected by underwriter or system. Ends bind request lifecycle.',
    `bind_rejection_reason_code` STRING COMMENT 'Standardized code indicating why the bind request was rejected. Links to rejection reason reference table.',
    `bind_rejection_reason_description` STRING COMMENT 'Detailed explanation of why the bind request was rejected. Provided to producer and applicant.',
    `bind_request_date` DATE COMMENT 'Date the bind request was submitted by producer or applicant. Business event timestamp for bind initiation.',
    `bind_request_status` STRING COMMENT 'Current lifecycle status of the bind request. Tracks progression from submission through final disposition.. Valid values are `pending|approved|rejected|withdrawn|expired|bound`',
    `certificate_of_insurance_required_flag` BOOLEAN COMMENT 'Indicates whether a certificate of insurance must be issued at bind. Common for commercial liability.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the bind request record was first created in the database. Audit trail.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts. Typically USD for domestic US business.',
    `down_payment_amount` DECIMAL(15,2) COMMENT 'Amount due at bind to initiate coverage. First installment or full premium depending on payment plan.',
    `down_payment_received_date` DATE COMMENT 'Date the down payment was received and cleared. Triggers bind approval workflow.',
    `down_payment_received_flag` BOOLEAN COMMENT 'Indicates whether the down payment has been received and cleared. Required for bind approval.',
    `inspection_completed_date` DATE COMMENT 'Date the required inspection was completed. Satisfies bind condition for inspection requirement.',
    `inspection_required_flag` BOOLEAN COMMENT 'Indicates whether a property or risk inspection is required before bind approval. Common for commercial property.',
    `lob` STRING COMMENT 'Insurance line of business for the bind request. Personal Auto, Homeowners, Commercial General Liability, etc.',
    `modified_timestamp` TIMESTAMP COMMENT 'System timestamp when the bind request record was last modified. Audit trail for status changes and updates.',
    `mortgagee_required_flag` BOOLEAN COMMENT 'Indicates whether mortgagee or loss payee information is required before bind. Common for property coverage.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC code identifying the insurance company issuing the policy. Required for statutory reporting.',
    `notes` STRING COMMENT 'Free-text notes from producer, applicant, or underwriter regarding the bind request. Special instructions or clarifications.',
    `number` STRING COMMENT 'Human-readable business identifier for the bind request. Used in producer and customer communications.',
    `payment_method` STRING COMMENT 'Instrument used for down payment or first installment. Credit card, ACH, check, wire, cash, or escrow. [ENUM-REF-CANDIDATE: credit_card|debit_card|ach|check|wire_transfer|cash|escrow — 7 candidates stripped; promote to reference product]',
    `payment_plan_code` STRING COMMENT 'Code identifying the requested payment plan. Determines installment schedule and down payment.',
    `policy_type_code` STRING COMMENT 'Code identifying the policy form or product type being bound. Links to policy type reference table.',
    `prior_carrier_cancellation_required_flag` BOOLEAN COMMENT 'Indicates whether proof of prior carrier cancellation is required before bind. Prevents dual coverage.',
    `requested_effective_date` DATE COMMENT 'Date the applicant or producer requests coverage to begin. May differ from quote effective date.',
    `requested_expiration_date` DATE COMMENT 'Date the applicant or producer requests coverage to end. Typically one year from effective date.',
    `sla_actual_hours` DECIMAL(10,2) COMMENT 'Actual number of hours taken to process bind request. Calculated from request to approval or rejection.',
    `sla_met_flag` BOOLEAN COMMENT 'Indicates whether the bind request was processed within the SLA target. Used for performance reporting.',
    `sla_target_hours` BIGINT COMMENT 'Target number of hours for bind request processing. Used for performance tracking and producer expectations.',
    `state_code` STRING COMMENT 'Two-letter state code where the risk is domiciled. Determines regulatory jurisdiction and filing requirements.',
    `timestamp` TIMESTAMP COMMENT 'Precise date and time the bind request was received. Used for SLA tracking and audit trail.',
    `total_premium_amount` DECIMAL(15,2) COMMENT 'Total premium amount from the quote being bound. Includes base premium, taxes, fees, and surcharges.',
    CONSTRAINT pk_bind_request PRIMARY KEY(`bind_request_id`)
) COMMENT 'Formal request to bind a quoted policy, submitted by producer or applicant. Grain: one row per bind request. Captures requested effective date, payment plan, and bind confirmation or rejection reason.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` (
    `binder_id` BIGINT COMMENT 'Unique identifier for the binder record. Primary key.',
    `agency_id` BIGINT COMMENT 'Reference to the agency that bound this coverage.',
    `binder_insured_party_id` BIGINT COMMENT 'Reference to the party being insured under this binder.',
    `binder_party_id` BIGINT COMMENT 'Reference to the underwriter who authorized this binder.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Binders commit premium amounts in specific currencies before policy issuance. Binding authority systems require currency reference for limit validation, premium reconciliation, and bordereaux',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Binders are issued under specific lines of business for binding authority limit tracking and bordereaux reporting.',
    `policy_id` BIGINT COMMENT 'Reference to the formal policy issued after this binder, if applicable.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer or agent who bound this coverage.',
    `quote_id` BIGINT COMMENT 'Reference to the quote that was bound to create this binder.',
    `submission_id` BIGINT COMMENT 'Reference to the submission that resulted in this binder.',
    `term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Binders are issued for a specific policy term (the initial term being bound). Real business process: binder documents and premium accounting require term-level granularity for term-specific',
    `uw_decision_id` BIGINT COMMENT 'Foreign key linking to coverage.uw_decision. Business justification: Binder is issued based on UW decision. FK references the decision that authorized the binder. Nullable YES (some binders may not have explicit decision records).',
    `bind_date` DATE COMMENT 'Date when the binder was issued and coverage became effective.',
    `binder_status` STRING COMMENT 'Current lifecycle status of the binder contract.. Valid values are `active|expired|cancelled|replaced|issued`',
    `binding_authority_limit` DECIMAL(15,2) COMMENT 'Maximum premium or limit the binding authority can issue without referral.',
    `binding_authority_type` STRING COMMENT 'Type of authority under which this binder was issued.. Valid values are `underwriter|producer|mga|agency`',
    `cancellation_date` DATE COMMENT 'Date when the binder was cancelled, if applicable.',
    `cancellation_reason` STRING COMMENT 'Reason for binder cancellation, if applicable.',
    `commission_amount` DECIMAL(15,2) COMMENT 'Total commission payable to the producer for this binder.',
    `commission_rate` DECIMAL(5,4) COMMENT 'Producer commission rate as a decimal percentage for this binder.',
    `coverage_limit_amount` DECIMAL(15,2) COMMENT 'Maximum liability limit provided under this binder.',
    `created_by_user_code` STRING COMMENT 'User identifier of the person who created this binder record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this binder record was first created in the system.',
    `deductible_amount` DECIMAL(15,2) COMMENT 'Deductible amount applicable to claims under this binder.',
    `document_url` STRING COMMENT 'Reference URL or path to the binder document in the document management system.',
    `down_payment_amount` DECIMAL(15,2) COMMENT 'Initial payment required to bind coverage.',
    `effective_date` DATE COMMENT 'Date when binder coverage begins.',
    `expiration_date` DATE COMMENT 'Date when binder coverage ends or formal policy must be issued.',
    `issuing_company_code` STRING COMMENT 'NAIC company code of the insurer issuing this binder.',
    `issuing_state` STRING COMMENT 'State jurisdiction where the binder was issued.',
    `modified_by_user_code` STRING COMMENT 'User identifier of the person who last modified this binder record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this binder record was last modified.',
    `notes` STRING COMMENT 'Free-form notes or comments about this binder.',
    `number` STRING COMMENT 'Externally-known unique business identifier for the binder contract.',
    `payment_plan_code` STRING COMMENT 'Code identifying the premium payment plan for this binder.',
    `policy_issued_date` DATE COMMENT 'Date when the formal policy was issued to replace this binder.',
    `policy_type_code` STRING COMMENT 'Code identifying the specific policy form or product type.',
    `premium_amount` DECIMAL(15,2) COMMENT 'Total premium amount for the binder period.',
    `replaced_by_policy_flag` BOOLEAN COMMENT 'Indicates whether this binder was replaced by a formal policy issuance.',
    `risk_state` STRING COMMENT 'State where the insured risk is located.',
    `special_conditions` STRING COMMENT 'Any special conditions or endorsements attached to this binder.',
    `term_days` BIGINT COMMENT 'Duration of binder coverage in days, typically 30-90 days.',
    `total_insured_value` DECIMAL(15,2) COMMENT 'Total value of all property and assets covered under this binder.',
    CONSTRAINT pk_binder PRIMARY KEY(`binder_id`)
) COMMENT 'Temporary insurance contract issued upon bind confirmation, providing coverage before the formal policy is issued. Captures binder number, effective/expiration dates, LOB, and issuing authority.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` (
    `submission_status_history_id` BIGINT COMMENT 'Unique identifier for each submission status change record. Primary key.',
    `bind_request_id` BIGINT COMMENT 'Foreign key linking to coverage.bind_request. Business justification: Status transitions can be triggered by bind requests. FK references the bind request that caused the status change (e.g., transition to Bind Requested status).',
    `changed_by_party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Workflow audit trail requires party linkage for regulatory compliance (who touched submission when), SLA breach analysis, underwriter performance metrics, and fraud investigation support.',
    `party_id` BIGINT COMMENT 'Foreign key to the underwriter assigned at the time of this status change.',
    `quote_id` BIGINT COMMENT 'Foreign key linking to coverage.quote. Business justification: Status transitions can be triggered by quote generation. FK references the quote that caused the status change (e.g., transition to Quoted status).',
    `referred_to_underwriter_party_id` BIGINT COMMENT 'Foreign key to the senior underwriter or manager to whom the submission was referred.',
    `submission_id` BIGINT COMMENT 'Foreign key to the submission that experienced this status change.',
    `coverage_transaction_id` BIGINT COMMENT 'Unique transaction identifier from the source system for this status change event.',
    `uw_decision_id` BIGINT COMMENT 'Foreign key linking to coverage.uw_decision. Business justification: Status transitions can be triggered by UW decisions. FK references the decision that caused the status change (e.g., transition to Approved status).',
    `uw_referral_id` BIGINT COMMENT 'Foreign key linking to coverage.uw_referral. Business justification: Status transitions can be triggered by referrals. FK references the referral that caused the status change (e.g., transition to Referred status).',
    `changed_by_role` STRING COMMENT 'Business role of the user who changed the status, such as Underwriter, CSR, or System.',
    `changed_by_user_name` STRING COMMENT 'Full name of the user who initiated this status change.',
    `comments` STRING COMMENT 'Free-text comments or notes entered by the user at the time of status change.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this status history record was first created in the system.',
    `duration_hours` DECIMAL(10,2) COMMENT 'Number of hours the submission remained in this status. Null for current status.',
    `is_current_status` BOOLEAN COMMENT 'Indicates whether this is the current active status for the submission. True for latest status, false for historical.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this status history record was last modified.',
    `previous_status_code` STRING COMMENT 'The status code immediately before this transition. Null for initial status.',
    `referral_flag` BOOLEAN COMMENT 'Indicates whether this status change involved a referral to senior underwriter or management.',
    `referral_reason` STRING COMMENT 'Reason for referral if this status change triggered an underwriting referral.',
    `sla_breach_hours` DECIMAL(10,2) COMMENT 'Number of hours by which the SLA was breached. Null if SLA was met.',
    `sla_met_flag` BOOLEAN COMMENT 'Indicates whether the SLA target was met for this status stage. True if met, false if breached.',
    `sla_target_hours` DECIMAL(10,2) COMMENT 'Target number of hours defined by SLA for completing this status stage.',
    `status_category` STRING COMMENT 'High-level category grouping related statuses for workflow analytics.. Valid values are `INTAKE|UNDERWRITING|DECISION|TERMINAL`',
    `status_code` STRING COMMENT 'Code representing the submission status at this point in time. [ENUM-REF-CANDIDATE: RECEIVED|IN_REVIEW|REFERRED|QUOTED|BOUND|DECLINED|WITHDRAWN|INCOMPLETE|PENDING_INFO — 9 candidates stripped; promote to reference product]',
    `status_effective_timestamp` TIMESTAMP COMMENT 'Date and time when this status became effective. Primary business event timestamp for this record.',
    `status_end_timestamp` TIMESTAMP COMMENT 'Date and time when this status ended and transitioned to next status. Null for current status.',
    `status_name` STRING COMMENT 'Human-readable name of the submission status.',
    `status_sequence_number` BIGINT COMMENT 'Sequential order of this status change within the submission lifecycle. Starts at 1 for first status.',
    `system_source` STRING COMMENT 'Source system or module that recorded this status change, such as PolicyCenter or Underwriting Workbench.',
    `transition_reason_code` STRING COMMENT 'Code indicating the reason for the status transition.',
    `transition_reason_description` STRING COMMENT 'Detailed explanation of why the status changed.',
    `transition_type` STRING COMMENT 'Indicates whether the status change was automatic, manual, or system-triggered.. Valid values are `AUTOMATIC|MANUAL|SYSTEM_TRIGGERED|USER_INITIATED`',
    `underwriter_name` STRING COMMENT 'Name of the underwriter assigned when this status was set.',
    `workflow_stage` STRING COMMENT 'The workflow stage or phase associated with this status in the submission lifecycle.',
    CONSTRAINT pk_submission_status_history PRIMARY KEY(`submission_status_history_id`)
) COMMENT 'Audit trail of submission status transitions (Received, In Review, Referred, Quoted, Bound, Declined, Withdrawn). One row per status change. Supports SLA tracking and workflow analytics.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` (
    `coverage_id` BIGINT COMMENT 'Unique identifier for the coverage. Primary key.',
    `coverage_type_id` BIGINT COMMENT 'Code representing the type of coverage (e.g., Dwelling, Liability, Collision, Comprehensive).',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Premium amounts on coverages must be denominated in a specific currency for multi-currency policies, financial reporting, and reinsurance cession calculations.',
    `exposure_unit_of_measure_id` BIGINT COMMENT 'Foreign key linking to shared.unit_of_measure. Business justification: Coverage exposure_units field requires UOM reference for rating basis validation, premium audit calculations, and exposure aggregation.',
    `fac_agreement_id` BIGINT COMMENT 'Foreign key linking to reinsurance.fac_agreement. Business justification: Facultative reinsurance is placed on specific high-value or unusual coverages. Underwriters and reinsurance managers need to track which coverages have facultative protection for',
    `insured_risk_id` BIGINT COMMENT 'Foreign key to the insured risk this coverage protects.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Coverages must link to LOB master for regulatory reporting (Schedule P), reinsurance treaty assignment, loss ratio analysis, and underwriting authority limits.',
    `part_id` BIGINT COMMENT 'Foreign key linking to coverage.part. Business justification: coverage currently has part as STRING attribute. part is a product in this domain representing named coverage parts within CPP/BOP (e.g., Commercial Property, CGL).',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term this coverage is attached to.',
    `prior_coverage_id` BIGINT COMMENT 'Foreign key to the previous version of this coverage, if this is an endorsement or renewal.',
    `reinsurance_treaty_id` BIGINT COMMENT 'Foreign key to the reinsurance treaty covering this coverage, if applicable.',
    `aggregate_limit_amount` DECIMAL(18,2) COMMENT 'Maximum total amount payable under this coverage for all occurrences during the policy term.',
    `basis` STRING COMMENT 'Trigger basis for the coverage (occurrence-based or claims-made).. Valid values are `occurrence|claims_made|claims_made_and_reported`',
    `cancellation_date` DATE COMMENT 'Date when the coverage was cancelled, if applicable.',
    `cancellation_reason_code` STRING COMMENT 'Code indicating the reason for coverage cancellation.',
    `ceded_percentage` DECIMAL(5,2) COMMENT 'Percentage of this coverage ceded to reinsurers.',
    `coinsurance_percentage` DECIMAL(5,2) COMMENT 'Percentage of loss shared by the insured after deductible is met.',
    `coverage_status` STRING COMMENT 'Current lifecycle status of the coverage.. Valid values are `active|suspended|cancelled|expired|pending`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this coverage record was first created in the system.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Amount the insured must pay out-of-pocket before coverage applies.',
    `deductible_type` STRING COMMENT 'Type of deductible applied to this coverage.. Valid values are `flat|percentage|franchise|disappearing`',
    `coverage_description` STRING COMMENT 'Detailed textual description of what this coverage protects against.',
    `effective_date` DATE COMMENT 'Date when the coverage becomes effective and protection begins.',
    `expiration_date` DATE COMMENT 'Date when the coverage expires and protection ends.',
    `exposure_units` DECIMAL(18,2) COMMENT 'Number of rating units used to calculate premium (e.g., payroll amount, number of vehicles).',
    `form_edition_date` DATE COMMENT 'Edition date of the coverage form used.',
    `form_number` STRING COMMENT 'ISO or proprietary form number defining the coverage terms and conditions.',
    `is_mandatory_coverage` BOOLEAN COMMENT 'Indicates whether this coverage is required by law or regulation.',
    `is_optional_coverage` BOOLEAN COMMENT 'Indicates whether this coverage was elected by the insured as optional.',
    `is_primary_coverage` BOOLEAN COMMENT 'Indicates whether this is the primary coverage on the policy term.',
    `iso_coverage_code` STRING COMMENT 'Standardized ISO code for this coverage type.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this coverage record was last updated.',
    `naic_line_code` STRING COMMENT 'NAIC line of business code for statutory reporting.',
    `number` STRING COMMENT 'Business identifier for the coverage, often printed on declarations page.',
    `per_occurrence_limit_amount` DECIMAL(18,2) COMMENT 'Maximum amount payable per occurrence or event under this coverage.',
    `premium_amount` DECIMAL(18,2) COMMENT 'Premium charged for this specific coverage.',
    `rate` DECIMAL(10,6) COMMENT 'Rating factor or rate per unit applied to calculate premium for this coverage.',
    `rating_basis` STRING COMMENT 'Unit of measure used for rating (e.g., per $1000 of coverage, per vehicle, per square foot).',
    `source_system_code` STRING COMMENT 'Code identifying the source system that originated this coverage record.',
    `sub_coverage_code` STRING COMMENT 'Code for sub-coverage or endorsement modifying the base coverage.',
    `territory` STRING COMMENT 'Geographic territory where the coverage applies (e.g., USA, Worldwide).',
    `underwriting_tier` STRING COMMENT 'Risk tier assigned during underwriting that affects coverage pricing.. Valid values are `preferred|standard|non_standard|high_risk`',
    `valuation_method` STRING COMMENT 'Method used to determine the value of a covered loss.. Valid values are `actual_cash_value|replacement_cost|agreed_value|stated_amount`',
    `version_number` BIGINT COMMENT 'Version number tracking changes to this coverage over the policy term lifecycle.',
    CONSTRAINT pk_coverage PRIMARY KEY(`coverage_id`)
) COMMENT 'Coverage: The bridge between the policy contract and insured risk, defining what is covered. GRAIN: One row per coverage per policy term. Grain: one row per coverage per policy term.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` (
    `limit_id` BIGINT COMMENT 'Unique identifier for the limit record. Primary key.',
    `coverage_id` BIGINT COMMENT 'Foreign key to the coverage to which this limit is attached.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Limit amounts require formal currency reference for multi-currency policies, reinsurance treaty attachment points, and regulatory capital calculations.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this limit is in force.',
    `shared_limit_group_id` BIGINT COMMENT 'Identifier for the group of coverages or risks that share this limit. Null if limit is not shared.',
    `aggregate_limit_period` STRING COMMENT 'Time period over which the aggregate limit applies: policy period, calendar year, accident year, or rolling 12 months.. Valid values are `policy_period|calendar_year|accident_year|rolling_12_months`',
    `amount` DECIMAL(18,2) COMMENT 'The monetary value of the limit in the policy currency.',
    `applies_to_coverage_part` STRING COMMENT 'Specific coverage part or section to which this limit applies (e.g., Coverage A, Coverage B, Medical Payments). Null if limit applies to entire coverage.',
    `applies_to_peril` STRING COMMENT 'Specific peril or cause of loss to which this limit applies (e.g., fire, wind, flood, earthquake, theft). Null if limit applies to all covered perils.',
    `attachment_point` DECIMAL(18,2) COMMENT 'For excess or umbrella limits, the attachment point or retention amount above which this limit begins to apply.',
    `basis` STRING COMMENT 'Basis on which the limit applies: per occurrence, per claim, per policy period, per location, per person, per accident, or aggregate annual. [ENUM-REF-CANDIDATE',
    `limit_code` STRING COMMENT 'Standard code or abbreviation for the limit type, often used in rating and policy administration systems (e.g., ISO limit codes).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this limit record was first created in the data warehouse.',
    `limit_description` STRING COMMENT 'Detailed textual description of the limit, including any special conditions, exclusions, or clarifications.',
    `effective_date` DATE COMMENT 'Date on which this limit becomes effective and begins to apply to covered losses.',
    `erosion_method` STRING COMMENT 'Method by which the limit is eroded or depleted: per claim, per payment, or aggregate depletion over the policy period.. Valid values are `per_claim|per_payment|aggregate_depletion`',
    `exhausted_date` DATE COMMENT 'Date on which the limit was fully exhausted by claim payments. Null if limit has not been exhausted.',
    `expiration_date` DATE COMMENT 'Date on which this limit expires and ceases to apply. Null for limits that remain in force through the end of the policy term.',
    `is_combined_single_limit` BOOLEAN COMMENT 'Indicates whether this is a combined single limit (CSL) covering bodily injury and property damage under one limit.',
    `is_shared_limit` BOOLEAN COMMENT 'Indicates whether this limit is shared across multiple coverages, insured risks, or policy terms.',
    `is_stacked` BOOLEAN COMMENT 'Indicates whether this limit can be stacked with other limits (e.g., uninsured/underinsured motorist coverage).',
    `iso_limit_code` STRING COMMENT 'Standard ISO code for the limit type, used for rating and statistical reporting.',
    `limit_status` STRING COMMENT 'Current status of the limit: active, suspended, exhausted (fully depleted by claims), cancelled, or expired.. Valid values are `active|suspended|exhausted|cancelled|expired`',
    `limit_type` STRING COMMENT 'Type of limit: occurrence, aggregate, per-person, per-accident, combined single limit (CSL), split limits, or sublimit. [ENUM-REF-CANDIDATE: occurrence|aggregate|per_person|per_accident|combined_single|split|sublimit — 7 candidates stripped; promote to',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this limit record was last modified in the data warehouse.',
    `naic_limit_code` STRING COMMENT 'NAIC standard code for the limit type, used for regulatory and statutory reporting.',
    `reinstatement_premium_rate` DECIMAL(5,4) COMMENT 'Rate or percentage of the original premium charged for reinstating the limit after a claim. Null if no reinstatement premium applies.',
    `reinstatement_provision` STRING COMMENT 'Provision for reinstating the limit after a claim: automatic reinstatement, manual reinstatement with additional premium, or no reinstatement.. Valid values are `automatic|manual|none`',
    `remaining_limit_amount` DECIMAL(18,2) COMMENT 'Current remaining amount of the limit after deducting claim payments and reserves. Null if not tracked or if limit is not aggregate.',
    `scope` STRING COMMENT 'Scope of the limit: primary, excess, umbrella, or sublimit within a broader coverage.. Valid values are `primary|excess|umbrella|sublimit`',
    `sequence` BIGINT COMMENT 'Sequence or ordering number for this limit within the coverage, used when multiple limits apply to the same coverage.',
    `source_system_code` STRING COMMENT 'Unique identifier for this limit in the source policy administration system.',
    `split_limit_bodily_injury_per_accident` DECIMAL(18,2) COMMENT 'For split limits, the maximum amount payable for bodily injury per accident (all persons combined).',
    `split_limit_bodily_injury_per_person` DECIMAL(18,2) COMMENT 'For split limits, the maximum amount payable for bodily injury per person per accident.',
    `split_limit_property_damage_per_accident` DECIMAL(18,2) COMMENT 'For split limits, the maximum amount payable for property damage per accident.',
    CONSTRAINT pk_limit PRIMARY KEY(`limit_id`)
) COMMENT 'Limit attached to a coverage: occurrence limit, aggregate limit, per-person limit, split limits. Supports stacked, CSL, and sublimit structures. One row per limit per coverage.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` (
    `deductible_id` BIGINT COMMENT 'Unique identifier for the deductible record. Primary key.',
    `coverage_id` BIGINT COMMENT 'Foreign key to the coverage to which this deductible applies.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Deductible amounts must reference currency for multi-currency policies, claims adjudication in foreign jurisdictions, and financial statement presentation.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this deductible is in effect.',
    `acord_code` STRING COMMENT 'ACORD standard code for this deductible type, used for data exchange and reporting.',
    `aggregate_limit` DECIMAL(18,2) COMMENT 'Maximum total deductible amount the insured must pay during the policy term when deductible_basis is aggregate_annual.',
    `amount` DECIMAL(18,2) COMMENT 'Flat dollar amount of the deductible when deductible_type is flat or SIR.',
    `application_method` STRING COMMENT 'How the deductible is applied: before coverage limits, after coverage limits, or split between insured and insurer.. Valid values are `before_coverage|after_coverage|split`',
    `applies_to_coverage_part` STRING COMMENT 'Specific coverage part to which this deductible applies (e.g., Property, Liability, Medical Payments). Null if applies to entire coverage.',
    `applies_to_lae_flag` BOOLEAN COMMENT 'Indicates whether the deductible applies to Loss Adjustment Expenses in addition to the loss amount. True if LAE is subject to deductible.',
    `applies_to_peril` STRING COMMENT 'Specific peril or cause of loss to which this deductible applies (e.g., wind, hail, earthquake, flood). Null if applies to all perils.',
    `applies_to_salvage_flag` BOOLEAN COMMENT 'Indicates whether salvage recoveries reduce the deductible amount. True if salvage offsets deductible.',
    `applies_to_subrogation_flag` BOOLEAN COMMENT 'Indicates whether subrogation recoveries reduce the deductible amount. True if subrogation offsets deductible.',
    `basis` STRING COMMENT 'Basis on which the deductible applies: per occurrence, per claim, per policy term, per location, per item, or aggregate annual.. Valid values are `per_occurrence|per_claim|per_policy|per_location|per_item|aggregate_annual`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this deductible record was first created in the system.',
    `deductible_type` STRING COMMENT 'Type of deductible: flat dollar amount, percentage of loss, Self-Insured Retention (SIR), disappearing, franchise, or aggregate.. Valid values are `flat|percentage|sir|disappearing|franchise|aggregate`',
    `deductible_description` STRING COMMENT 'Free-text description of the deductible terms, conditions, and any special provisions or endorsements.',
    `disappearing_threshold` DECIMAL(18,2) COMMENT 'Loss amount at which a disappearing deductible fully disappears. Deductible reduces proportionally as loss approaches this threshold.',
    `effective_date` DATE COMMENT 'Date on which this deductible becomes effective for the coverage.',
    `expiration_date` DATE COMMENT 'Date on which this deductible expires or is no longer in effect. Null for open-ended deductibles.',
    `iso_form_code` STRING COMMENT 'ISO form code or endorsement number that defines this deductible structure (e.g., IL 03 10, CP 03 10).',
    `maximum_deductible_amount` DECIMAL(18,2) COMMENT 'Maximum dollar amount for percentage-based or disappearing deductibles. Caps the deductible at this ceiling.',
    `minimum_deductible_amount` DECIMAL(18,2) COMMENT 'Minimum dollar amount for percentage-based deductibles. Ensures deductible does not fall below this floor.',
    `naic_code` STRING COMMENT 'NAIC code for deductible classification used in statutory reporting (Schedule P, Annual Statement).',
    `percentage` DECIMAL(5,2) COMMENT 'Percentage of loss or insured value when deductible_type is percentage. Stored as decimal (e.g., 5.00 for 5%).',
    `source_system_code` STRING COMMENT 'Unique identifier for this deductible in the source policy administration system.',
    `transaction_effective_date` DATE COMMENT 'Effective date of the policy transaction that created or modified this deductible.',
    `transaction_type` STRING COMMENT 'Type of policy transaction that created or modified this deductible record (NB, REN, END, CAN, RI).. Valid values are `new_business|renewal|endorsement|cancellation|reinstatement`',
    `underwriter_notes` STRING COMMENT 'Free-text notes from the underwriter regarding special deductible terms, exceptions, or rationale for non-standard deductibles.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this deductible record was last modified.',
    `waiting_period_days` BIGINT COMMENT 'Number of days the insured must wait before coverage begins, applicable to time-based deductibles (e.g., business interruption).',
    `waiver_authority` STRING COMMENT 'Name or role of the person or system that authorized the deductible waiver.',
    `waiver_date` DATE COMMENT 'Date on which the deductible waiver was granted.',
    `waiver_flag` BOOLEAN COMMENT 'Indicates whether the deductible has been waived for this coverage. True if waived, False otherwise.',
    `waiver_reason` STRING COMMENT 'Business reason for waiving the deductible (e.g., catastrophe event, customer retention, underwriting exception).',
    CONSTRAINT pk_deductible PRIMARY KEY(`deductible_id`)
) COMMENT 'Deductible attached to a coverage: flat, percentage, SIR, or disappearing. Captures amount, basis, application method, and waiver flags. One row per deductible per coverage.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` (
    `exclusion_id` BIGINT COMMENT 'Unique identifier for the exclusion record. Primary key.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Exclusions reference specific perils (earthquake, flood, wind) by ISO/NAIC codes.',
    `coverage_id` BIGINT COMMENT 'Foreign key to the coverage to which this exclusion is attached.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this exclusion is in force.',
    `specific_insured_risk_id` BIGINT COMMENT 'Foreign key to a specific insured risk if this exclusion applies only to that risk. Null if exclusion applies to all risks under the coverage.',
    `superseded_by_exclusion_id` BIGINT COMMENT 'Foreign key to the exclusion record that supersedes this one, if this exclusion has been replaced by a later endorsement. Null if current.',
    `applies_to_all_insured_risks` BOOLEAN COMMENT 'Boolean flag indicating whether this exclusion applies blanket to all insured risks under the coverage or only to specific risks.',
    `applies_to_first_party` BOOLEAN COMMENT 'Boolean flag indicating whether this exclusion applies to first-party coverage under the policy.',
    `applies_to_third_party` BOOLEAN COMMENT 'Boolean flag indicating whether this exclusion applies to third-party liability coverage under the policy.',
    `buyback_endorsement_available` BOOLEAN COMMENT 'Boolean flag indicating whether a standard endorsement exists to buy back coverage for this exclusion.',
    `buyback_premium_amount` DECIMAL(15,2) COMMENT 'Additional premium charged to waive or buy back this exclusion, if applicable. Null if exclusion is not waivable.',
    `exclusion_category` STRING COMMENT 'High-level classification of what dimension the exclusion applies to: specific peril, property type, activity, location, person, time period, condition, or other.',
    `claims_made_trigger` BOOLEAN COMMENT 'Boolean flag indicating whether this exclusion applies only to claims-made policies or claims-made coverage triggers.',
    `exclusion_code` STRING COMMENT 'Standard code identifying the exclusion type. May be ISO (Insurance Services Office) standard code or carrier-specific manuscript code.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this exclusion record was first created in the system.',
    `exclusion_description` STRING COMMENT 'Detailed narrative description of what perils, circumstances, or losses are excluded from coverage under this exclusion clause.',
    `effective_date` DATE COMMENT 'Date from which this exclusion applies to the coverage. Must align with policy term or endorsement effective date.',
    `endorsement_effective_date` DATE COMMENT 'Date on which the endorsement introducing this exclusion became effective.',
    `endorsement_number` STRING COMMENT 'Policy endorsement number that introduced or modified this exclusion, if applicable.',
    `exclusion_status` STRING COMMENT 'Current lifecycle status of the exclusion: active and in force, inactive, superseded by a later endorsement, deleted, or pending approval.. Valid values are `active|inactive|superseded|deleted|pending`',
    `exclusion_type` STRING COMMENT 'Classification of the exclusion origin: ISO standard form, manuscript custom language, endorsement-based, statutory requirement, regulatory mandate, or carrier-specific.. Valid values are `ISO|manuscript|endorsement|statutory|regulatory|carrier_specific`',
    `expiration_date` DATE COMMENT 'Date on which this exclusion ceases to apply. Nullable for exclusions that remain in force through policy term expiration.',
    `iso_form_number` STRING COMMENT 'ISO standard form number if this exclusion is derived from an ISO policy form or endorsement.',
    `language_text` STRING COMMENT 'Full legal text of the exclusion clause as it appears in the policy contract or endorsement.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this exclusion record was last updated or modified.',
    `exclusion_name` STRING COMMENT 'Short business-friendly name of the exclusion for display and reporting purposes.',
    `occurrence_trigger` BOOLEAN COMMENT 'Boolean flag indicating whether this exclusion applies to occurrence-based policies or occurrence coverage triggers.',
    `regulatory_mandate_flag` BOOLEAN COMMENT 'Boolean flag indicating whether this exclusion is mandated by state or federal regulation and cannot be waived.',
    `scope` STRING COMMENT 'Scope level at which the exclusion operates: coverage-level, policy-wide, location-specific, vehicle-specific, driver-specific, building-specific, or other.',
    `source_system_code` STRING COMMENT 'Unique identifier of this exclusion record in the source policy administration system.',
    `state_mandate_code` STRING COMMENT 'State jurisdiction code if this exclusion is mandated by a specific state Department of Insurance regulation.',
    `underwriter_notes` STRING COMMENT 'Free-text notes from the underwriter explaining the rationale for applying this exclusion or any special handling instructions.',
    `version_number` BIGINT COMMENT 'Version number of this exclusion record, incremented with each endorsement or modification.',
    `waivable_flag` BOOLEAN COMMENT 'Boolean flag indicating whether this exclusion can be waived or bought back through an endorsement or additional premium.',
    CONSTRAINT pk_exclusion PRIMARY KEY(`exclusion_id`)
) COMMENT 'Exclusion attached to a coverage: ISO or manuscript exclusion code, description, endorsement reference, and effective dates. One row per exclusion per coverage.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` (
    `coverage_condition_id` BIGINT COMMENT 'Unique identifier for the condition data product (auto-inserted during validation).',
    `coverage_id` BIGINT COMMENT 'Foreign key to the coverage to which this condition is attached.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this condition is in force.',
    `agreed_value_amount` DECIMAL(15,2) COMMENT 'The agreed value amount established for the insured property when agreed_value_indicator is true. Null otherwise.',
    `agreed_value_indicator` BOOLEAN COMMENT 'True if this condition waives coinsurance and establishes an agreed value for the insured property. False otherwise.',
    `clause_text` STRING COMMENT 'Full legal text of the condition clause as it appears in the policy contract or endorsement form.',
    `coinsurance_percentage` DECIMAL(5,2) COMMENT 'Coinsurance percentage required under the condition. Typically 80%, 90%, or 100%. Null if condition is not coinsurance.',
    `compliance_status_code` STRING COMMENT 'Current compliance status: COMP=Compliant, NCOMP=Non-compliant, PEND=Pending verification, WAIV=Waived, UNKN=Unknown.. Valid values are `COMP|NCOMP|PEND|WAIV|UNKN`',
    `compliance_verification_date` DATE COMMENT 'Date on which compliance with this condition was last verified by the insurer or third party.',
    `compliance_verified_by` STRING COMMENT 'Name or identifier of the party who verified compliance: underwriter, inspector, third-party auditor, or insured self-certification.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this condition record was first created in the source system.',
    `coverage_condition_description` STRING COMMENT 'Detailed description of the condition, including its purpose and applicability to the coverage.',
    `effective_date` DATE COMMENT 'Date on which this condition becomes effective and binding on the insured and insurer.',
    `endorsement_number` STRING COMMENT 'Endorsement number that added or modified this condition. Null if condition was present at policy inception.',
    `expiration_date` DATE COMMENT 'Date on which this condition expires or is no longer in force. Null for open-ended conditions.',
    `inspection_frequency_code` STRING COMMENT 'Frequency of inspection required: MONTH=Monthly, QUAR=Quarterly, SEMI=Semi-annually, ANN=Annually, ONDEM=On Demand. Null if not an inspection condition.. Valid values are `MONTH|QUAR|SEMI|ANN|ONDEM`',
    `iso_form_number` STRING COMMENT 'ISO standard form number if this condition is derived from an ISO policy form or endorsement.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this condition record was last modified in the source system.',
    `mandatory_indicator` BOOLEAN COMMENT 'True if this condition is mandatory per regulatory or underwriting requirements and cannot be waived. False if optional or negotiable.',
    `margin_percentage` DECIMAL(5,2) COMMENT 'Margin percentage allowed under a margin clause condition. Null if condition is not a margin clause.',
    `coverage_condition_name` STRING COMMENT 'Business-friendly name of the condition as it appears on the policy declarations page.',
    `non_compliance_reason` STRING COMMENT 'Explanation of why the insured is non-compliant with this condition. Null if compliant or status is unknown.',
    `penalty_amount` DECIMAL(15,2) COMMENT 'Flat penalty amount if penalty_method_code is FLAT. Null otherwise.',
    `penalty_method_code` STRING COMMENT 'Method for calculating penalty if condition is not met: PROP=Proportional reduction, FLAT=Flat penalty amount, NONE=No penalty specified.. Valid values are `PROP|FLAT|NONE`',
    `regulatory_requirement_indicator` BOOLEAN COMMENT 'True if this condition is required by state or federal regulation. False if it is a voluntary underwriting condition.',
    `reporting_deadline_days` BIGINT COMMENT 'Number of days after the reporting period end by which the insured must submit the report. Null if not a reporting condition.',
    `reporting_frequency_code` STRING COMMENT 'Frequency of reporting required under a reporting condition: MONTH=Monthly, QUAR=Quarterly, SEMI=Semi-annually, ANN=Annually. Null if not a reporting condition.. Valid values are `MONTH|QUAR|SEMI|ANN`',
    `sequence_number` BIGINT COMMENT 'Ordinal sequence number of this condition within the coverage for display and sorting purposes.',
    `source_system_code` STRING COMMENT 'System of record that created this condition: PAS=Policy Admin System, UW=Underwriting Workbench, RATE=Rating Engine, DOC=Document Management.. Valid values are `PAS|UW|RATE|DOC`',
    `type_code` STRING COMMENT 'Type of condition: COINS=Coinsurance, AGRVAL=Agreed Value, MARGIN=Margin Clause, REPORT=Reporting Requirement, INSP=Inspection Requirement, WARR=Warranty.. Valid values are `COINS|AGRVAL|MARGIN|REPORT|INSP|WARR`',
    `waiver_granted_by` STRING COMMENT 'Name or identifier of the underwriter or authority who granted the waiver. Null if no waiver granted.',
    `waiver_granted_date` DATE COMMENT 'Date on which the waiver was granted by the insurer. Null if no waiver granted.',
    `waiver_granted_indicator` BOOLEAN COMMENT 'True if the insurer has granted a waiver of this condition for the current policy term. False otherwise.',
    `waiver_reason` STRING COMMENT 'Business justification for granting a waiver of this condition. Null if no waiver granted.',
    `warranty_description` STRING COMMENT 'Detailed description of the warranty obligation the insured must fulfill. Null if not a warranty condition.',
    `warranty_type_code` STRING COMMENT 'Type of warranty: PROM=Promissory (future action), AFFIRM=Affirmative (current state), COND=Conditional (if-then). Null if not a warranty condition.. Valid values are `PROM|AFFIRM|COND`',
    CONSTRAINT pk_coverage_condition PRIMARY KEY(`coverage_condition_id`)
) COMMENT 'Condition attached to a coverage: coinsurance, reporting, inspection, warranty, or margin clause. SOLE owner of coinsurance percentage, agreed-value indicator, margin percentage, penalty method, plus clause text, compliance status, and effective dates.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` (
    `coverage_form_id` BIGINT COMMENT 'Unique identifier for the form data product (auto-inserted during validation).',
    `coverage_id` BIGINT COMMENT 'Foreign key to the coverage to which this form applies.',
    `coverage_type_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_type. Business justification: Coverage forms are designed for specific coverage types (e.g., ISO CGL form for general liability coverage, HO-3 form for homeowners).',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term to which this form is attached.',
    `acord_form_code` STRING COMMENT 'The standardized ACORD form code if this is an ACORD form. Example: ACORD 125, ACORD 126, ACORD 140.',
    `approval_date` DATE COMMENT 'The date the form was approved by the state Department of Insurance. Null if not yet approved or approval not required.',
    `attachment_point` STRING COMMENT 'The level at which this form attaches: policy level, coverage level, or insured risk level. Determines scope of applicability.. Valid values are `policy|coverage|insured_risk`',
    `coverage_form_category` STRING COMMENT 'Functional category of the form: coverage extension, coverage restriction, additional insured, waiver of subrogation, or other.. Valid values are `coverage_extension|coverage_restriction|additional_insured|waiver_of_subrogation|other`',
    `coverage_form_status` STRING COMMENT 'The current lifecycle status of the form: active, inactive, withdrawn, or obsolete.. Valid values are `active|inactive|withdrawn|obsolete`',
    `coverage_form_type` STRING COMMENT 'Classification of the form: base coverage form, endorsement, exclusion, condition, schedule, declaration page, or manuscript form. [ENUM-REF-CANDIDATE: base_coverage|endorsement|exclusion|condition|schedule|declaration|manuscript — 7 candidates stripped',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this form record was first created in the system.',
    `coverage_form_description` STRING COMMENT 'Detailed description of the coverage, exclusion, or condition provided by this form. Used for underwriting and claims interpretation.',
    `document_uri` STRING COMMENT 'The URI or file path to the digital copy of the form document stored in the document management system.',
    `edition_date` DATE COMMENT 'The edition or revision date of the form as published by ISO or the carrier. Critical for regulatory compliance and coverage interpretation.',
    `effective_date` DATE COMMENT 'The date from which this form is effective on the policy term. Used for mid-term endorsements and form changes.',
    `expiration_date` DATE COMMENT 'The date on which this form expires or is replaced. Null if the form remains in force through the policy term end.',
    `filing_date` DATE COMMENT 'The date the form was filed with the state Department of Insurance for approval.',
    `filing_number` STRING COMMENT 'The unique filing number assigned by the state DOI when the form was submitted for regulatory approval.',
    `filing_status` STRING COMMENT 'The regulatory filing status of the form with the state Department of Insurance: approved, pending, withdrawn, rejected, or not required.. Valid values are `approved|pending|withdrawn|rejected|not_required`',
    `is_amendatory` BOOLEAN COMMENT 'Indicates whether this form is an amendatory endorsement that modifies the base coverage form. True for amendatory endorsements, false otherwise.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether this form is mandatory for the coverage or policy term. True if required by regulation or underwriting rules, false if optional.',
    `iso_form_code` STRING COMMENT 'The standardized ISO form code if this is an ISO form. Example: CG 00 01, HO 00 03, CA 00 01.',
    `jurisdiction` STRING COMMENT 'The regulatory jurisdiction governing this form. Typically the state name or multi-state designation.',
    `language` STRING COMMENT 'The language in which the form is written. Used for multi-lingual policy issuance and compliance.. Valid values are `english|spanish|french|other`',
    `lob` STRING COMMENT 'The insurance line of business to which this form applies: personal auto, homeowners, commercial auto, general liability, workers compensation, property, umbrella, or BOP.',
    `naic_company_code` STRING COMMENT 'The five-digit NAIC company code of the carrier that filed or uses this form. Used for regulatory reporting and multi-carrier form management.',
    `coverage_form_name` STRING COMMENT 'The full descriptive name of the form. Example: Commercial General Liability Coverage Form, Homeowners Special Form, Business Auto Coverage Form.',
    `number` STRING COMMENT 'The unique alphanumeric identifier assigned to the form by ISO, ACORD, or the carrier. Example: CG 00 01, HO 00 03, CA 00 01.',
    `premium_amount` DECIMAL(15,2) COMMENT 'The additional premium amount charged for this form, if premium-bearing. Null if the form does not carry a separate premium.',
    `premium_bearing_flag` BOOLEAN COMMENT 'Indicates whether this form carries an additional premium charge. True if the form has a premium impact, false if it is informational or no-charge.',
    `sequence` BIGINT COMMENT 'The order in which this form appears in the policy document or declarations page. Used for document assembly and printing.',
    `source` STRING COMMENT 'The origin of the form: ISO standard, ACORD standard, carrier proprietary, manuscript, or state-mandated form.. Valid values are `iso|acord|carrier_proprietary|manuscript|state_mandated`',
    `state_code` STRING COMMENT 'The two-letter state code where this form is filed and approved. Example: CA, NY, TX. Used for multi-state form management.',
    `superseded_form_number` STRING COMMENT 'The form number of the previous form that this form replaces or supersedes. Used for form version tracking and historical analysis.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this form record was last updated in the system.',
    `version` STRING COMMENT 'The internal version number or identifier for this form. Used to track revisions and updates to carrier proprietary or manuscript forms.',
    CONSTRAINT pk_coverage_form PRIMARY KEY(`coverage_form_id`)
) COMMENT 'ISO or manuscript form attached to a coverage or policy term. Tracks form number, edition date, form type (base, endorsement, exclusion), and filing status with the DOI.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` (
    `part_id` BIGINT COMMENT 'Unique identifier for the coverage part. Primary key.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Policy parts require LOB reference for package policy construction, regulatory filings, reinsurance treaty applicability, and financial statement line-of-business segmentation.',
    `party_id` BIGINT COMMENT 'Identifier of the underwriter responsible for this coverage part.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term under which this coverage part is issued.',
    `producers_producer_id` BIGINT COMMENT 'Identifier of the producer or agent who sold this coverage part.',
    `aggregate_limit_amount` DECIMAL(18,2) COMMENT 'Maximum aggregate limit of liability for this coverage part across all claims during the policy term.',
    `audit_required_indicator` BOOLEAN COMMENT 'Indicates whether this coverage part requires a premium audit at policy expiration.',
    `cancellation_date` DATE COMMENT 'Date when this coverage part was cancelled, if applicable. Null if not cancelled.',
    `cancellation_reason_code` STRING COMMENT 'Standardized code indicating the reason for cancellation of this coverage part.. Valid values are `NON_PAY|UW_RISK|INSURED_REQ|FRAUD|MATERIAL_MISREP|OTHER`',
    `cat_exposure_indicator` BOOLEAN COMMENT 'Indicates whether this coverage part has catastrophe exposure requiring CAT modeling.',
    `claims_made_indicator` BOOLEAN COMMENT 'Indicates whether this coverage part is written on a claims-made basis (true) or occurrence basis (false).',
    `coinsurance_percentage` DECIMAL(5,2) COMMENT 'Coinsurance percentage requirement for this coverage part (e.g., 80%, 90%, 100%).',
    `commission_rate_percentage` DECIMAL(5,2) COMMENT 'Commission rate percentage paid to the producer for this coverage part.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this coverage part record was first created in the system.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Standard deductible amount applicable to this coverage part. May be overridden at coverage level.',
    `deductible_type_code` STRING COMMENT 'Type of deductible applied to this coverage part (per occurrence, aggregate, percentage of loss, etc.).. Valid values are `PER_OCCURRENCE|PER_CLAIM|AGGREGATE|PERCENTAGE|FRANCHISE`',
    `part_description` STRING COMMENT 'Detailed textual description of the coverage part, including any special terms or conditions.',
    `effective_date` DATE COMMENT 'Date when this coverage part becomes effective and coverage begins.',
    `endorsement_count` BIGINT COMMENT 'Number of endorsements applied to this coverage part during the policy term.',
    `expiration_date` DATE COMMENT 'Date when this coverage part expires and coverage ends.',
    `extended_reporting_period_days` BIGINT COMMENT 'Number of days of extended reporting period (tail coverage) provided for claims-made policies.',
    `iso_form_edition_date` DATE COMMENT 'Edition date of the ISO form used for this coverage part.',
    `iso_form_number` STRING COMMENT 'ISO standard form number used for this coverage part (e.g., CP 00 10, CG 00 01).',
    `minimum_premium_amount` DECIMAL(18,2) COMMENT 'Minimum premium amount required for this coverage part, regardless of rating basis.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this coverage part record was last modified in the system.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code of the insurer issuing this coverage part.',
    `part_name` STRING COMMENT 'Human-readable name of the coverage part (e.g., Commercial Property, General Liability, Commercial Auto).',
    `number` STRING COMMENT 'Business identifier for the coverage part, typically printed on declarations page.',
    `package_indicator` BOOLEAN COMMENT 'Indicates whether this part is part of a package policy (CPP, BOP) or standalone.',
    `package_type_code` STRING COMMENT 'Type of package policy this part belongs to (Commercial Package Policy, Business Owners Policy, etc.).. Valid values are `CPP|BOP|PAP|HO|STANDALONE`',
    `part_status` STRING COMMENT 'Current lifecycle status of the coverage part within the policy term.. Valid values are `active|cancelled|expired|suspended|pending`',
    `per_occurrence_limit_amount` DECIMAL(18,2) COMMENT 'Maximum limit of liability per occurrence or claim for this coverage part.',
    `premium_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for premium amounts. Typically USD for US P&C insurers.. Valid values are `USD`',
    `rate_per_unit` DECIMAL(12,6) COMMENT 'Premium rate applied per unit of rating basis (e.g., $0.50 per $100 of payroll).',
    `rating_basis_code` STRING COMMENT 'The basis used for rating this coverage part (e.g., square footage, payroll, receipts, number of vehicles). [ENUM-REF-CANDIDATE: AREA|PAYROLL|RECEIPTS|UNITS|VEHICLES|TIV|OTHER — 7 candidates stripped; promote to reference product]',
    `rating_basis_unit` STRING COMMENT 'Unit of measure for the rating basis value (e.g., sq_ft, USD, vehicles, employees).',
    `rating_basis_value` DECIMAL(18,2) COMMENT 'Numeric value of the rating basis used to calculate premium (e.g., 10000 sq ft, $500000 payroll).',
    `reinsurance_treaty_indicator` BOOLEAN COMMENT 'Indicates whether this coverage part is subject to reinsurance treaty cession.',
    `retroactive_date` DATE COMMENT 'Retroactive date for claims-made coverage parts, defining the earliest date of loss covered.',
    `sequence` BIGINT COMMENT 'Ordering sequence of this part within the policy package for display and processing.',
    `state_code` STRING COMMENT 'Two-letter US state code where this coverage part is issued and regulated.',
    `territory_code` STRING COMMENT 'Geographic territory code used for rating this coverage part.',
    `type_code` STRING COMMENT 'Standardized code classifying the coverage part type (Property, General Liability, Auto, Workers Comp, etc.). [ENUM-REF-CANDIDATE: PROP|GL|AUTO|WC|EPLI|DO|EO|CRIME|INLAND|OCEAN — 10 candidates stripped; promote to reference product]',
    `valuation_method_code` STRING COMMENT 'Method used to value losses under this coverage part (Actual Cash Value, Replacement Cost, Stated Value, Agreed Value).. Valid values are `ACV|RC|STATED|AGREED|MARKET`',
    `written_premium_amount` DECIMAL(18,2) COMMENT 'Total written premium amount for this coverage part for the policy term.',
    CONSTRAINT pk_part PRIMARY KEY(`part_id`)
) COMMENT 'Named coverage part within a CPP or BOP (e.g., Commercial Property, CGL, Commercial Auto). Groups coverages under a single policy package. One row per coverage part per policy term.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` (
    `coverage_endorsement_id` BIGINT COMMENT 'Unique identifier for the endorsement data product (auto-inserted during validation).',
    `coverage_form_id` BIGINT COMMENT 'Foreign key linking to coverage.form. Business justification: endorsement currently has form_number (STRING) and form_edition_date (DATE) as denormalized attributes.',
    `coverage_id` BIGINT COMMENT 'Reference to the base coverage being modified by this endorsement.',
    `coverage_party_id` BIGINT COMMENT 'Reference to the underwriter who approved the endorsement.',
    `coverage_requested_by_party_id` BIGINT COMMENT 'Reference to the party who requested the endorsement, typically the insured or producer.',
    `policy_document_id` BIGINT COMMENT 'Reference to the physical or electronic document containing the endorsement form and language.',
    `policy_term_id` BIGINT COMMENT 'Reference to the policy term during which this endorsement is effective.',
    `policy_transaction_id` BIGINT COMMENT 'Reference to the policy transaction that created this endorsement.',
    `premium_impact_currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Endorsement premium impacts require currency reference for mid-term policy changes, pro-rata calculations, and audit reconciliation.',
    `superseded_by_endorsement_id` BIGINT COMMENT 'Reference to a subsequent endorsement that supersedes this one, if applicable.',
    `approved_date` DATE COMMENT 'Date on which the endorsement was approved by underwriting.',
    `cancellation_date` DATE COMMENT 'Date on which the endorsement was cancelled, if applicable.',
    `cancellation_reason_code` STRING COMMENT 'Code indicating the reason the endorsement was cancelled, if applicable.. Valid values are `insured_request|underwriting_decision|non_payment|policy_cancelled|error_correction`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this endorsement record was first created in the system.',
    `deductible_change_amount` DECIMAL(15,2) COMMENT 'Net change in deductible amount resulting from this endorsement, if applicable.',
    `coverage_endorsement_description` STRING COMMENT 'Detailed description of the change being made to the coverage by this endorsement.',
    `effective_date` DATE COMMENT 'Date on which the endorsement becomes effective and the coverage change takes effect.',
    `expiration_date` DATE COMMENT 'Date on which the endorsement expires, typically aligned with the policy term expiration.',
    `issued_date` DATE COMMENT 'Date on which the endorsement was formally issued and communicated to the insured.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this endorsement record was last updated in the system.',
    `limit_change_amount` DECIMAL(15,2) COMMENT 'Net change in coverage limit resulting from this endorsement, if applicable.',
    `mandatory_indicator` BOOLEAN COMMENT 'Flag indicating whether the endorsement is mandatory per regulatory or underwriting requirements.',
    `number` STRING COMMENT 'Business identifier for the endorsement, typically sequential within the policy term.',
    `premium_impact_amount` DECIMAL(15,2) COMMENT 'Net change in premium resulting from this endorsement, positive for additional premium, negative for return premium.',
    `reason_code` STRING COMMENT 'Code indicating the business reason for issuing this endorsement.. Valid values are `insured_request|underwriting_requirement|regulatory_mandate|rate_change|exposure_change|correction`',
    `reason_description` STRING COMMENT 'Detailed explanation of why the endorsement was issued.',
    `regulatory_authority_code` STRING COMMENT 'Code identifying the regulatory authority mandating the endorsement, if applicable.',
    `regulatory_requirement_indicator` BOOLEAN COMMENT 'Flag indicating whether the endorsement is required by state or federal regulation.',
    `requested_date` DATE COMMENT 'Date on which the endorsement was requested by the insured or producer.',
    `sequence_number` BIGINT COMMENT 'Sequential order of this endorsement within the coverage and policy term for chronological tracking.',
    `source_system_code` STRING COMMENT 'Code identifying the policy administration system or module that originated this endorsement record.',
    `status_code` STRING COMMENT 'Current lifecycle status of the endorsement in the policy administration workflow.. Valid values are `draft|pending_approval|approved|issued|cancelled|superseded`',
    `title` STRING COMMENT 'Full title or name of the endorsement as it appears on the policy declarations page.',
    `type_code` STRING COMMENT 'Classification of the endorsement by the nature of the change being made to the coverage.. Valid values are `coverage_change|limit_change|deductible_change|exclusion_add|exclusion_remove|condition_add`',
    CONSTRAINT pk_coverage_endorsement PRIMARY KEY(`coverage_endorsement_id`)
) COMMENT 'Endorsement modifying a base coverage: endorsement number, form reference, effective date, premium impact, and change description. One row per endorsement per coverage.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` (
    `additional_interest_id` BIGINT COMMENT 'Unique identifier for the additional interest record.',
    `coverage_id` BIGINT COMMENT 'Coverage to which this additional interest is attached.',
    `party_id` BIGINT COMMENT 'Party who holds the additional interest or insured status.',
    `policy_term_id` BIGINT COMMENT 'Policy term during which this additional interest is effective.',
    `address_line_1` STRING COMMENT 'First line of the mailing address for the additional interest party.',
    `address_line_2` STRING COMMENT 'Second line of the mailing address (suite, unit, building) for the additional interest party.',
    `blanket_description` STRING COMMENT 'Description of the criteria or class of parties covered under a blanket additional insured endorsement.',
    `blanket_indicator` BOOLEAN COMMENT 'Indicates whether this is a blanket additional insured endorsement covering multiple unnamed parties meeting specified criteria.',
    `cancellation_notice_days` BIGINT COMMENT 'Number of days advance notice required to be given to this additional interest before policy cancellation.',
    `certificate_holder_indicator` BOOLEAN COMMENT 'Indicates whether this party requires a Certificate of Insurance (CoI) to be issued.',
    `certificate_issue_date` DATE COMMENT 'Date when the Certificate of Insurance (CoI) was issued to this additional interest.',
    `certificate_number` STRING COMMENT 'Certificate of Insurance (CoI) number issued to this additional interest party.',
    `city` STRING COMMENT 'City name for the additional interest mailing address.',
    `contract_reference_number` STRING COMMENT 'External contract or agreement number that requires this additional interest attachment.',
    `country_code` STRING COMMENT 'Three-letter ISO country code for the additional interest mailing address.. Valid values are `USA|CAN|MEX`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this additional interest record was first created in the system.',
    `effective_date` DATE COMMENT 'Date when the additional interest attachment becomes effective on the coverage.',
    `endorsement_number` STRING COMMENT 'Policy endorsement number that added or modified this additional interest.',
    `expiration_date` DATE COMMENT 'Date when the additional interest attachment expires or is removed from the coverage.',
    `interest_description` STRING COMMENT 'Detailed description of the nature and scope of the additional interest.',
    `interest_name` STRING COMMENT 'Full legal name of the additional interest party as it appears on the policy.',
    `interest_type_code` STRING COMMENT 'Type of additional interest: AI (Additional Insured), ALI (Additional Loss Payee), LP (Loss Payee), MORT (Mortgagee), LH (Lienholder), COI (Certificate of Insurance Holder).. Valid values are `AI|ALI|LP|MORT|LH|COI`',
    `iso_form_number` STRING COMMENT 'ISO form number used to attach this additional interest (e.g., CG 20 10 for Additional Insured).',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this additional interest record was last updated.',
    `loan_amount` DECIMAL(15,2) COMMENT 'Outstanding loan or lien amount secured by the insured property.',
    `loan_number` STRING COMMENT 'Loan or mortgage account number associated with the interest, applicable for mortgagees and lienholders.',
    `postal_code` STRING COMMENT 'Postal or ZIP code for the additional interest mailing address.',
    `primary_indicator` BOOLEAN COMMENT 'Indicates whether this is the primary additional interest when multiple interests exist on the same coverage.',
    `rank_order` BIGINT COMMENT 'Priority ranking for loss payment distribution when multiple interests exist (1 = highest priority).',
    `removal_date` DATE COMMENT 'Date when the additional interest was removed from the coverage.',
    `removal_reason_code` STRING COMMENT 'Reason for removing the additional interest: loan paid off, contract ended, party request, or data entry error.. Valid values are `loan_paid|contract_end|request|error`',
    `source_system_code` STRING COMMENT 'Code identifying the source system that created or manages this additional interest record.',
    `state_province_code` STRING COMMENT 'Two-letter state or province code for the additional interest mailing address.',
    `status_code` STRING COMMENT 'Current status of the additional interest attachment: active, expired, cancelled, or pending.. Valid values are `active|expired|cancelled|pending`',
    `waiver_of_subrogation_indicator` BOOLEAN COMMENT 'Indicates whether the insurer waives subrogation rights against this additional interest.',
    CONSTRAINT pk_additional_interest PRIMARY KEY(`additional_interest_id`)
) COMMENT 'Additional interest or additional insured attached to a coverage: party reference, interest type (AI, loss payee, mortgagee, lienholder), certificate holder flag, and effective dates.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` (
    `rate_id` BIGINT COMMENT 'Unique identifier for the rate element applied to a coverage during pricing.',
    `classification_code_id` BIGINT COMMENT 'Foreign key linking to shared.classification_code. Business justification: Rating requires formal link to classification code master for base rate lookup, hazard group assignment, loss cost retrieval, and regulatory filing compliance.',
    `coverage_id` BIGINT COMMENT 'Reference to the coverage to which this rate element applies.',
    `coverage_type_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_type. Business justification: rate currently has type_code (STRING) attribute. coverage_type is the reference catalog for coverage types with PK coverage_type_id and coverage_code as business key.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Rates are territory-specific; territory_code is denormalized geography reference.',
    `policy_term_id` BIGINT COMMENT 'Reference to the policy term during which this rate is effective.',
    `rating_basis_unit_of_measure_id` BIGINT COMMENT 'Foreign key linking to shared.unit_of_measure. Business justification: Rating basis requires UOM reference for rate-per-unit calculations, audit reconciliation, and exposure conversion.',
    `basis_code` STRING COMMENT 'The unit of measure to which the rate applies: per hundred of coverage, per thousand, per unit, per vehicle, per location, per employee, per payroll unit, or flat amount.',
    `rate_code` STRING COMMENT 'The unique code identifying the rate element in the rating engine or rate table.',
    `coinsurance_factor` DECIMAL(6,4) COMMENT 'Factor applied when coinsurance provisions are in effect, adjusting premium based on the ratio of insurance to value.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this rate record was first created in the system.',
    `deductible_credit_factor` DECIMAL(6,4) COMMENT 'Credit factor applied to reduce premium when a deductible is selected, reflecting reduced carrier exposure.',
    `effective_date` DATE COMMENT 'The date on which this rate element becomes effective for premium calculation.',
    `endorsement_number` STRING COMMENT 'Endorsement number if this rate element was added or modified via a policy endorsement.',
    `experience_modifier` DECIMAL(6,3) COMMENT 'Experience modification factor applied to adjust premium based on the insureds historical loss experience. Typically ranges from 0.500 to 2.000.',
    `expiration_date` DATE COMMENT 'The date on which this rate element expires and is no longer valid for premium calculation. Null indicates no expiration.',
    `factor` DECIMAL(10,4) COMMENT 'Multiplicative factor applied to base rate for territory, class, or experience adjustments. Typically a decimal multiplier.',
    `filing_approval_date` DATE COMMENT 'The date on which the state Department of Insurance (DOI) approved this rate for use.',
    `filing_number` STRING COMMENT 'The regulatory filing number under which this rate was approved by the state Department of Insurance (DOI).',
    `filing_state_code` STRING COMMENT 'Two-letter state code where this rate was filed and approved. Rates are state-specific in Property and Casualty insurance.',
    `increased_limits_factor` DECIMAL(8,4) COMMENT 'Factor applied when coverage limits exceed the base limit, reflecting the increased exposure. Common in liability coverages.',
    `iso_form_number` STRING COMMENT 'ISO form number associated with this rate element, linking the rate to standardized policy forms and endorsements.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this rate record was last modified, supporting audit trail and premium reconstruction.',
    `minimum_premium_amount` DECIMAL(15,2) COMMENT 'The minimum premium amount that must be charged for this coverage, regardless of calculated premium. Ensures carrier covers administrative costs.',
    `override_approval_date` DATE COMMENT 'Date on which the rate override was approved.',
    `override_approved_by` STRING COMMENT 'Name or identifier of the underwriter or manager who approved the rate override.',
    `override_indicator` BOOLEAN COMMENT 'Indicates whether this rate was manually overridden by an underwriter, deviating from the standard rating algorithm.',
    `override_reason` STRING COMMENT 'Business justification for the rate override, required for audit and regulatory compliance.',
    `rating_algorithm_code` STRING COMMENT 'Code identifying the rating algorithm or pricing model used to calculate this rate element.',
    `rating_variable_name` STRING COMMENT 'Name of the rating variable or input factor used in the rating algorithm for this rate element.',
    `rating_variable_value` DECIMAL(18,2) COMMENT 'The value of the rating variable at the time of rating, captured for premium reconstruction and audit purposes.',
    `schedule_credit_debit_amount` DECIMAL(15,2) COMMENT 'Dollar amount of schedule credit (negative) or debit (positive) applied for underwriting judgment factors such as management quality, safety programs, or loss control.',
    `schedule_credit_debit_percentage` DECIMAL(5,2) COMMENT 'Percentage credit (negative) or debit (positive) applied for underwriting judgment factors. Expressed as a percentage of base premium.',
    `sequence_number` BIGINT COMMENT 'Sequence number for ordering multiple rate elements applied to the same coverage within a policy term.',
    `source_system_code` STRING COMMENT 'Code identifying the source system from which this rate element originated, such as the rating engine or policy administration system.',
    `table_name` STRING COMMENT 'Name or identifier of the rate table from which this rate element was retrieved.',
    `table_version` STRING COMMENT 'Version identifier of the rate table, enabling reconstruction of premium at any point in time using the correct rate version.',
    `transaction_type_code` STRING COMMENT 'Type of policy transaction that introduced or modified this rate element: New Business (NB), Renewal (REN), Endorsement (END), Cancellation (CAN), or Reinstatement (RI).. Valid values are `new_business|renewal|endorsement|cancellation|reinstatement`',
    `type_code` STRING COMMENT 'Classification of the rate element: base rate, territory factor, class factor, experience modifier, schedule credit or debit, discretionary adjustment, minimum premium, or flat charge.',
    `value` DECIMAL(18,6) COMMENT 'The numeric rate value or factor applied during premium calculation. Precision supports actuarial rating accuracy.',
    CONSTRAINT pk_rate PRIMARY KEY(`rate_id`)
) COMMENT 'Rate element applied to a coverage during pricing: rate code, rate basis, rate value, territory factor, class factor, and effective date. Supports reconstruction of premium at any point in time.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` (
    `coverage_type_id` BIGINT COMMENT 'Unique identifier for the coverage type. Primary key.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Coverage types must link to LOB master for product catalog management, underwriting rule assignment, rating algorithm selection, and regulatory approval tracking.',
    `acord_coverage_code` STRING COMMENT 'ACORD standard coverage code for data exchange with agents, brokers, and trading partners. Enables interoperability across industry systems.. Valid values are `^[A-Z0-9]{2,6}$`',
    `aggregate_limit_required_indicator` BOOLEAN COMMENT 'True if this coverage type requires an aggregate limit for the policy term; false if per-occurrence only. Used in exposure tracking and limit erosion monitoring.',
    `catastrophe_eligible_indicator` BOOLEAN COMMENT 'True if losses under this coverage may be designated as catastrophe losses for aggregation and reinsurance purposes; false otherwise.',
    `claims_made_indicator` BOOLEAN COMMENT 'True if coverage is triggered only when claim is made during the policy period; false if occurrence-based. Affects tail coverage and extended reporting periods.',
    `coinsurance_allowed_indicator` BOOLEAN COMMENT 'True if coinsurance provisions may be attached to this coverage; false otherwise. Determines whether insured shares in loss beyond deductible.',
    `coverage_category` STRING COMMENT 'High-level classification grouping coverages by type of risk protected. Used for portfolio analysis and exposure aggregation.. Valid values are `PROPERTY|LIABILITY|AUTO_PHYSICAL_DAMAGE|BODILY_INJURY|MEDICAL_PAYMENTS|UNINSURED_MOTORIST`',
    `coverage_code` STRING COMMENT 'Short alphanumeric code uniquely identifying the coverage type within the insurers catalog. Business identifier used in rating, policy issuance, and claims.. Valid values are `^[A-Z0-9]{2,10}$`',
    `coverage_description` STRING COMMENT 'Detailed description of what the coverage protects against, including scope of protection and key terms.',
    `coverage_name` STRING COMMENT 'Full business name of the coverage type as displayed on policy documents and declarations pages.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this coverage type record was first created in the system. Audit trail for catalog management.',
    `deductible_required_indicator` BOOLEAN COMMENT 'True if a deductible must be specified for this coverage; false if no deductible applies. Influences rating and claims payment calculations.',
    `defense_cost_included_indicator` BOOLEAN COMMENT 'True if defense and legal costs are included within the coverage limit; false if provided in addition to limit. Critical for liability coverage reserving.',
    `effective_date` DATE COMMENT 'Date from which this coverage type definition becomes active and available for policy issuance. Supports versioning of coverage catalog.',
    `expiration_date` DATE COMMENT 'Date on which this coverage type definition is retired and no longer available for new business. Null if currently active.',
    `first_party_indicator` BOOLEAN COMMENT 'True if coverage protects the insureds own property or person; false if third-party liability. Determines claims handling and reserving approach.',
    `iso_coverage_symbol` STRING COMMENT 'Standard ISO coverage symbol used for industry-wide classification and statistical reporting. Enables benchmarking and regulatory compliance.. Valid values are `^[A-Z0-9]{1,5}$`',
    `iso_edition_date` DATE COMMENT 'Edition date of the ISO form used for this coverage type. Ensures correct form version is applied to policies.',
    `iso_form_number` STRING COMMENT 'Standard ISO form number for the coverage form or endorsement. Format: XX YY ZZ AA BB where XX=line, YY=year, ZZ=month, AA=sequence, BB=edition.. Valid values are `^[A-Z]{2}s[0-9]{2}s[0-9]{2}s[0-9]{2}s[0-9]{2}$`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this coverage type record was last updated. Supports change tracking and version control.',
    `mandatory_indicator` BOOLEAN COMMENT 'True if this coverage is mandatory for the line of business or jurisdiction; false if optional. Drives underwriting rules and quote generation logic.',
    `minimum_premium_amount` DECIMAL(15,2) COMMENT 'Minimum premium charge for this coverage type regardless of exposure or rate calculation. Ensures profitability on small accounts.',
    `naic_coverage_code` STRING COMMENT 'NAIC standardized coverage code for statutory reporting and regulatory filings. Required for Schedule P and Annual Statement submissions.. Valid values are `^[0-9]{3,6}$`',
    `occurrence_basis_indicator` BOOLEAN COMMENT 'True if coverage is triggered by loss occurrence during the policy period regardless of when reported; false if claims-made. Critical for reserving and IBNR estimation.',
    `optional_indicator` BOOLEAN COMMENT 'True if this coverage may be elected by the policyholder; false if automatically included. Used in quote presentation and policy customization.',
    `per_occurrence_limit_required_indicator` BOOLEAN COMMENT 'True if this coverage type requires a per-occurrence limit; false if aggregate-only or unlimited. Drives limit configuration in policy issuance.',
    `peril_type` STRING COMMENT 'Indicates whether coverage is triggered by named perils only, open perils, or all risks except exclusions. Determines breadth of protection.. Valid values are `NAMED_PERIL|OPEN_PERIL|SPECIFIED_PERIL|ALL_RISK`',
    `rate_type_code` STRING COMMENT 'Type of rate structure applied: per-unit rate, percentage of value, flat fee, tiered schedule, or experience-rated. Determines premium calculation method.. Valid values are `PER_UNIT|PERCENTAGE|FLAT_FEE|TIERED|EXPERIENCE_RATED`',
    `rating_basis_code` STRING COMMENT 'Unit of measure used to calculate premium for this coverage: exposure units, payroll, sales, area, number of units, underlying premium, or flat charge. [ENUM-REF-CANDIDATE: EXPOSURE|PAYROLL|SALES|AREA|UNITS|PREMIUM|FLAT — 7 candidates stripped; promote to',
    `regulatory_approval_required_indicator` BOOLEAN COMMENT 'True if this coverage type requires state Department of Insurance approval before use; false if filed-and-use or exempt. Drives compliance workflow.',
    `salvage_allowed_indicator` BOOLEAN COMMENT 'True if the insurer may take salvage rights on damaged property after total loss settlement; false otherwise. Relevant for property and auto physical damage coverages.',
    `sort_order` BIGINT COMMENT 'Numeric sequence for displaying coverage types in a consistent order on quotes, policies, and reports. Lower numbers appear first.',
    `status_code` STRING COMMENT 'Current lifecycle status of the coverage type in the catalog. Active types are available for underwriting; inactive types are retained for historical policy servicing.. Valid values are `ACTIVE|INACTIVE|PENDING_APPROVAL|WITHDRAWN|SUPERSEDED`',
    `sublimit_allowed_indicator` BOOLEAN COMMENT 'True if sublimits may be applied to specific perils or property classes within this coverage; false if single limit only. Used in complex commercial policies.',
    `subrogation_allowed_indicator` BOOLEAN COMMENT 'True if the insurer retains subrogation rights after paying a claim under this coverage; false if waived. Impacts recovery potential and claims handling.',
    `supplementary_payments_indicator` BOOLEAN COMMENT 'True if coverage includes supplementary payments such as bail bonds, loss of earnings, or post-judgment interest in addition to limits; false otherwise.',
    `third_party_indicator` BOOLEAN COMMENT 'True if coverage protects against liability to third parties; false if first-party. Impacts claims investigation, legal defense, and subrogation.',
    `valuation_method_code` STRING COMMENT 'Method used to determine loss settlement value: Actual Cash Value, Replacement Cost, Agreed Value, Stated Amount, Functional Replacement, or Market Value.. Valid values are `ACV|REPLACEMENT_COST|AGREED_VALUE|STATED_AMOUNT|FUNCTIONAL_REPLACEMENT|MARKET_VALUE`',
    CONSTRAINT pk_coverage_type PRIMARY KEY(`coverage_type_id`)
) COMMENT 'Reference catalog of coverage types: coverage code, name, LOB, ISO coverage symbol, mandatory/optional flag. Standardizes coverage classification across lines. One row per coverage type.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` (
    `coverage_peril_id` BIGINT COMMENT 'Primary key for peril',
    `peril_link_id` BIGINT COMMENT 'Unique identifier for the coverage peril reference record. Primary key.',
    `cat_indicator` BOOLEAN COMMENT 'Flag indicating whether this peril is classified as a catastrophe peril for exposure aggregation and Probable Maximum Loss (PML) modeling.',
    `cat_model_code` STRING COMMENT 'Code identifying the catastrophe model used for this peril (e.g., RMS Hurricane, AIR Earthquake). Null if not a CAT peril.',
    `coinsurance_applicable_indicator` BOOLEAN COMMENT 'Flag indicating whether coinsurance provisions typically apply to this peril.',
    `coverage_peril_status` STRING COMMENT 'Current lifecycle status of the peril reference record (e.g., ACTIVE, INACTIVE, DEPRECATED, PENDING).. Valid values are `ACTIVE|INACTIVE|DEPRECATED|PENDING`',
    `coverage_trigger` STRING COMMENT 'The event that triggers coverage for this peril (e.g., OCCURRENCE, CLAIMS_MADE, LOSS_SUSTAINED, DISCOVERY).. Valid values are `OCCURRENCE|CLAIMS_MADE|LOSS_SUSTAINED|DISCOVERY`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this peril reference record was first created in the data warehouse.',
    `deductible_applicable_indicator` BOOLEAN COMMENT 'Flag indicating whether a deductible typically applies to claims under this peril.',
    `coverage_peril_description` STRING COMMENT 'Detailed business description of the peril, including coverage scope, typical exclusions, and underwriting considerations.',
    `effective_date` DATE COMMENT 'Date from which this peril definition is effective for rating, underwriting, and claims processing.',
    `expiration_date` DATE COMMENT 'Date on which this peril definition expires or is superseded. Null if currently active.',
    `facultative_typical_indicator` BOOLEAN COMMENT 'Flag indicating whether this peril commonly requires facultative reinsurance placement.',
    `first_party_indicator` BOOLEAN COMMENT 'Flag indicating whether this peril applies to first-party (insureds own) losses.',
    `group_code` STRING COMMENT 'High-level grouping of perils for aggregation and reporting (e.g., FIRE, WIND, WATER, THEFT, LIABILITY, CAT, OTHER). [ENUM-REF-CANDIDATE: FIRE|WIND|WATER|THEFT|LIABILITY|CAT|OTHER — 7 candidates stripped; promote to reference product]',
    `iso_peril_code` STRING COMMENT 'ISO standard peril code used for forms, rating, and industry benchmarking.. Valid values are `^[A-Z0-9]{2,6}$`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this peril reference record was last updated in the data warehouse.',
    `naic_peril_code` STRING COMMENT 'NAIC statutory reporting peril code used for Schedule P and annual statement filings.. Valid values are `^[0-9]{3,5}$`',
    `peril_category` STRING COMMENT 'Line of business category to which the peril applies (e.g., PROPERTY, CASUALTY, LIABILITY, AUTO, WORKERS_COMP, SPECIALTY).. Valid values are `PROPERTY|CASUALTY|LIABILITY|AUTO|WORKERS_COMP|SPECIALTY`',
    `peril_code` STRING COMMENT 'Standard code identifying the insured peril (e.g., FIRE, WIND, THEFT, FLOOD, LIAB). Used for rating, claims, and catastrophe modeling.. Valid values are `^[A-Z0-9]{2,10}$`',
    `peril_name` STRING COMMENT 'Full descriptive name of the peril (e.g., Fire, Windstorm, Theft, Flood, General Liability).',
    `pml_applicable_indicator` BOOLEAN COMMENT 'Flag indicating whether Probable Maximum Loss (PML) calculations apply to this peril for exposure management.',
    `regulatory_reporting_required_indicator` BOOLEAN COMMENT 'Flag indicating whether losses from this peril require specific regulatory reporting (e.g., CAT event reporting to state DOI).',
    `reinsurance_treaty_eligible_indicator` BOOLEAN COMMENT 'Flag indicating whether losses from this peril are typically eligible for treaty reinsurance cession.',
    `sort_order` BIGINT COMMENT 'Numeric sequence for display ordering of perils in user interfaces and reports.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record that maintains this peril definition (e.g., PAS, RATING_ENGINE, ISO_LIBRARY).',
    `sublimit_typical_indicator` BOOLEAN COMMENT 'Flag indicating whether sublimits are commonly applied to this peril (e.g., jewelry, fine arts, flood).',
    `third_party_indicator` BOOLEAN COMMENT 'Flag indicating whether this peril applies to third-party (liability) losses.',
    CONSTRAINT pk_coverage_peril PRIMARY KEY(`coverage_peril_id`)
) COMMENT 'Reference catalog of insured perils: peril code, name, peril group (fire, wind, flood, theft, liability), CAT indicator, and NAIC peril classification. Referenced by coverage_peril_link and claims. One row per peril.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` (
    `peril_link_id` BIGINT COMMENT 'Primary key for peril_link',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Reference to the peril being associated with the coverage.',
    `coverage_id` BIGINT COMMENT 'Reference to the coverage to which this peril is linked.',
    `aggregate_limit_amount` DECIMAL(18,2) COMMENT 'Maximum aggregate amount payable for all claims under this peril during the policy term. Null if no aggregate limit applies.',
    `aggregate_limit_applies` BOOLEAN COMMENT 'Indicates whether an aggregate limit applies to this peril across all claims during the policy term.',
    `applies_to_first_party` BOOLEAN COMMENT 'Indicates whether this peril coverage applies to first-party claims (insureds own losses).',
    `applies_to_third_party` BOOLEAN COMMENT 'Indicates whether this peril coverage applies to third-party claims (liability to others).',
    `buyback_available_indicator` BOOLEAN COMMENT 'Indicates whether the insured can buy back coverage for this peril if it is excluded by default.',
    `buyback_premium_amount` DECIMAL(18,2) COMMENT 'Additional premium charged to buy back coverage for this peril. Null if buyback is not available or not exercised.',
    `cat_peril_indicator` BOOLEAN COMMENT 'Indicates whether this peril is classified as a catastrophe peril for exposure aggregation and PML modeling purposes.',
    `cat_zone_applicable` BOOLEAN COMMENT 'Indicates whether catastrophe zone restrictions apply to this peril coverage.',
    `coinsurance_percentage` DECIMAL(5,2) COMMENT 'Percentage of loss shared by the insured after the deductible is applied, specific to this peril. Null if no coinsurance applies.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this coverage-peril association record was first created in the data platform.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Override deductible amount specific to this peril, if different from the coverage deductible. Null if no override applies.',
    `deductible_basis` STRING COMMENT 'Basis on which the peril deductible applies, such as per occurrence, per claim, aggregate, or per location.. Valid values are `per_occurrence|per_claim|aggregate|per_location`',
    `deductible_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the deductible amount.. Valid values are `USD|CAD|EUR|GBP|AUD`',
    `deductible_percentage` DECIMAL(5,2) COMMENT 'Percentage deductible applied to the loss amount for this peril, if deductible type is percentage. Null otherwise.',
    `deductible_type` STRING COMMENT 'Type of deductible applied to this peril: flat dollar amount, percentage of loss, franchise, or disappearing deductible.. Valid values are `flat|percentage|franchise|disappearing`',
    `effective_date` DATE COMMENT 'Date on which the coverage-peril association becomes effective.',
    `endorsement_effective_date` DATE COMMENT 'Effective date of the endorsement that modified this coverage-peril association. Null if no endorsement applies.',
    `endorsement_number` STRING COMMENT 'Endorsement number that added, modified, or removed this peril from the coverage. Null if part of original policy issuance.',
    `expiration_date` DATE COMMENT 'Date on which the coverage-peril association expires. Null for open-ended associations.',
    `extended_reporting_period_days` BIGINT COMMENT 'Number of days after policy expiration during which claims may be reported for this peril under claims-made coverage. Null if not applicable.',
    `inclusion_status` STRING COMMENT 'Indicates whether the peril is included in, excluded from, or conditionally covered under the coverage.. Valid values are `included|excluded|conditionally_included|suspended`',
    `iso_form_number` STRING COMMENT 'ISO form number associated with the peril coverage or exclusion, if applicable.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this coverage-peril association record was last updated in the data platform.',
    `naic_peril_code` STRING COMMENT 'NAIC standard code for the peril, used for regulatory reporting and statutory accounting.',
    `per_occurrence_limit_amount` DECIMAL(18,2) COMMENT 'Maximum amount payable per occurrence for this peril. Null if no per-occurrence limit applies.',
    `peril_description` STRING COMMENT 'Detailed description of the peril and the circumstances under which it applies to the coverage.',
    `peril_link_status` STRING COMMENT 'Current lifecycle status of the coverage-peril association.. Valid values are `active|inactive|suspended|pending|expired`',
    `peril_type_code` STRING COMMENT 'Classification code for the type of peril, such as fire, wind, hail, theft, flood, earthquake, or liability event.',
    `regulatory_mandate_indicator` BOOLEAN COMMENT 'Indicates whether inclusion or exclusion of this peril is mandated by state or federal regulation.',
    `retroactive_date` DATE COMMENT 'Retroactive date for claims-made coverage. Claims arising from events before this date are not covered. Null for occurrence-based coverage.',
    `sequence_number` BIGINT COMMENT 'Ordering sequence for displaying or processing perils within the coverage. Lower numbers are processed first.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system from which this coverage-peril association was sourced.',
    `state_mandate_code` STRING COMMENT 'Two-letter state code if this peril association is mandated by state-specific regulation. Null if not state-mandated.',
    `sublimit_amount` DECIMAL(18,2) COMMENT 'Override limit amount specific to this peril, if different from the coverage limit. Null if no sublimit applies.',
    `sublimit_basis` STRING COMMENT 'Basis on which the peril sublimit applies, such as per occurrence, per claim, aggregate, per location, or per person.. Valid values are `per_occurrence|per_claim|aggregate|per_location|per_person`',
    `sublimit_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the sublimit amount.. Valid values are `USD|CAD|EUR|GBP|AUD`',
    `trigger_type` STRING COMMENT 'Type of trigger that activates coverage for this peril: occurrence-based, claims-made, or claims-made-and-reported.. Valid values are `occurrence|claims_made|claims_made_and_reported`',
    `underwriter_notes` STRING COMMENT 'Free-text notes from the underwriter regarding the inclusion, exclusion, or modification of this peril.',
    `waiting_period_days` BIGINT COMMENT 'Number of days after policy inception before coverage for this peril becomes effective. Zero if no waiting period applies.',
    CONSTRAINT pk_peril_link PRIMARY KEY(`peril_link_id`)
) COMMENT 'Association between a coverage and the perils it insures. Captures whether the peril is included or excluded, sublimit override, and deductible override at the peril level. One row per peril per coverage.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` (
    `coverage_interest_id` BIGINT COMMENT 'Primary key for coverage_interest',
    `coverage_id` BIGINT COMMENT 'Foreign key to the coverage in which the party holds an interest.',
    `policy_interest_id` BIGINT COMMENT 'Unique surrogate identifier for this coverage interest record. Primary key.',
    `role_id` BIGINT COMMENT 'Foreign key to the party role holding an interest in this coverage.',
    `certificate_required` BOOLEAN COMMENT 'Indicates whether this party requires a certificate of insurance for this coverage. Drives certificate issuance workflow.',
    `effective_date` DATE COMMENT 'Date on which this partys interest in the coverage becomes effective. Used to determine coverage eligibility at loss date.',
    `expiration_date` DATE COMMENT 'Date on which this partys interest in the coverage expires or is terminated. Null indicates open-ended interest.',
    `is_primary_interest` BOOLEAN COMMENT 'Indicates whether this is the primary insurable interest for this coverage. Drives first-loss payment priority.',
    `percentage` DECIMAL(5,2) COMMENT 'Percentage of the insurable interest held by this party in this coverage. Used for loss payee and mortgagee payment allocation.',
    `type_code` STRING COMMENT 'Classifies the nature of the insurable interest this party holds in the coverage. Drives claims payment and certificate issuance rules.',
    `waiver_of_subrogation` BOOLEAN COMMENT 'Indicates whether the insurer has waived subrogation rights against this party for this coverage. Affects recovery processing.',
    CONSTRAINT pk_coverage_interest PRIMARY KEY(`coverage_interest_id`)
) COMMENT 'One row per party-role per coverage. Captures the insurable interest a party holds in a specific coverage, including interest type, role, effective dates, and interest percentage. Enables multiple parties with different interests on one coverage..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` (
    `coverage_cession_id` BIGINT COMMENT 'Primary key for coverage_cession',
    `reinsurance_cession_id` BIGINT COMMENT 'Unique identifier for this cession record. Primary key.',
    `coverage_id` BIGINT COMMENT 'Foreign key to the coverage being ceded to reinsurance under this treaty layer.',
    `treaty_layer_id` BIGINT COMMENT 'Foreign key to the treaty layer providing reinsurance protection for this coverage.',
    `attachment_point` DECIMAL(18,2) COMMENT 'Dollar amount of loss at which this treaty layer begins to respond for this specific coverage.',
    `ceded_premium_amount` DECIMAL(18,2) COMMENT 'Premium amount ceded to reinsurers for this coverage under this treaty layer.',
    `cession_status` STRING COMMENT 'Current lifecycle status of this cession record indicating whether reinsurance protection is in force.',
    `effective_date` DATE COMMENT 'Date when this cession becomes effective and reinsurance protection begins for this coverage under this layer.',
    `expiration_date` DATE COMMENT 'Date when this cession expires and reinsurance protection ends for this coverage under this layer.',
    `layer_limit` DECIMAL(18,2) COMMENT 'Maximum dollar amount recoverable from this treaty layer for this coverage per occurrence.',
    `percentage` DECIMAL(7,4) COMMENT 'Percentage of the coverage limit ceded to this treaty layer. Represents the reinsurers share of risk.',
    `retention_amount` DECIMAL(18,2) COMMENT 'Dollar amount of loss retained by the cedant before this treaty layer responds for this coverage.',
    CONSTRAINT pk_coverage_cession PRIMARY KEY(`coverage_cession_id`)
) COMMENT 'One row per coverage per treaty layer. Records the reinsurance placement linking a ceded coverage to a specific treaty layer with cession terms, attachment point, limit, and retention amount..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility` (
    `eligibility_id` BIGINT COMMENT 'Unique surrogate identifier for the coverage eligibility record. Primary key.',
    `coverage_type_id` BIGINT COMMENT 'Foreign key linking to the coverage type eligible for cession under this agreement.',
    `ri_agreement_id` BIGINT COMMENT 'Foreign key linking to the reinsurance agreement that covers this coverage type.',
    `cession_priority` BIGINT COMMENT 'Numeric priority order when multiple agreements cover the same coverage type. Lower numbers cede first.',
    `default_cession_pct` DECIMAL(7,4) COMMENT 'Default percentage of premium and loss to cede for this coverage type under this agreement, subject to policy-level override.',
    `effective_date` DATE COMMENT 'Date from which this coverage eligibility rule becomes active for the agreement.',
    `eligible_indicator` BOOLEAN COMMENT 'True if this coverage type is eligible for cession under this agreement; false if explicitly excluded.',
    `exclusion_reason` STRING COMMENT 'Business reason why this coverage type is excluded from the agreement, if eligible_indicator is false.',
    `expiry_date` DATE COMMENT 'Date on which this coverage eligibility rule expires or is superseded by a new rule.',
    `reinsurance_treaty_eligible_indicator` BOOLEAN COMMENT 'True if this coverage type is eligible for treaty reinsurance cession; false if excluded or facultative-only. Drives reinsurance accounting and bordereaux reporting. [Moved from coverage_type: This boolean on coverage_type is a generic flag.',
    CONSTRAINT pk_eligibility PRIMARY KEY(`eligibility_id`)
) COMMENT 'Association between coverage types and reinsurance agreements defining which coverages are eligible for cession under each treaty or facultative agreement. One row per coverage type per agreement..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`producer_coverage_authority` (
    `producer_coverage_authority_id` BIGINT COMMENT 'Unique surrogate identifier for each producer-coverage authority record. Primary key.',
    `coverage_type_id` BIGINT COMMENT 'Foreign key linking to the coverage type for which authority is granted.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key linking to the producer receiving binding authority.',
    `authority_level` STRING COMMENT 'Level of binding authority granted: FULL_BIND allows binding without referral, QUOTE_ONLY requires underwriter approval, REFER_ALL prohibits binding, CONDITIONAL allows binding within limits.',
    `binding_authority_flag` BOOLEAN COMMENT 'True if producer has delegated binding authority for this coverage type; false if producer may only quote and must refer to underwriter for binding.',
    `effective_date` DATE COMMENT 'Date from which this binding authority becomes effective. Producer may bind coverage of this type on or after this date.',
    `expiration_date` DATE COMMENT 'Date on which this binding authority expires. Null if authority is open-ended. Producer may not bind coverage of this type after this date without renewal.',
    `max_limit` DECIMAL(18,2) COMMENT 'Maximum coverage limit in USD the producer may bind for this coverage type without underwriter referral. Null if no limit applies or authority is REFER_ALL.',
    `referral_threshold` DECIMAL(18,2) COMMENT 'Premium or TIV threshold above which producer must refer the risk to underwriting even if binding authority is granted. Null if no threshold applies.',
    CONSTRAINT pk_producer_coverage_authority PRIMARY KEY(`producer_coverage_authority_id`)
) COMMENT 'Binding authority granted to a producer for a specific coverage type. Captures authority level, binding limits, effective dates, and referral thresholds per producer-coverage combination. One row per producer per coverage type per authority period..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` (
    `type_peril_id` BIGINT COMMENT 'Unique identifier for this coverage type peril applicability record. Primary key.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to the peril covered under this coverage type.',
    `primary_coverage_type_id` BIGINT COMMENT 'Foreign key linking to the coverage type being configured.',
    `type_coverage_type_id` BIGINT COMMENT 'Foreign key linking to the coverage type being configured.',
    `coverage_trigger` STRING COMMENT 'Defines how this peril triggers coverage: named peril only, open peril, all risk, or explicitly excluded from this coverage type.',
    `effective_date` DATE COMMENT 'Date from which this peril applicability rule becomes active for this coverage type.',
    `endorsement_required` STRING COMMENT 'ISO or proprietary endorsement form number required to add or modify coverage for this peril under this coverage type. Null if no endorsement needed.',
    `expiration_date` DATE COMMENT 'Date on which this peril applicability rule expires for this coverage type. Null if currently active.',
    `is_standard_coverage` BOOLEAN COMMENT 'True if this peril is covered by default under this coverage type; false if endorsement or separate election is required.',
    `sublimit_typical_indicator` BOOLEAN COMMENT 'True if this peril typically requires a sublimit when covered under this coverage type; false if full coverage limit applies.',
    `typical_deductible_type` STRING COMMENT 'Standard deductible structure applied when this peril triggers under this coverage type: flat dollar, percentage of insured value, or percentage of limit.',
    CONSTRAINT pk_type_peril PRIMARY KEY(`type_peril_id`)
) COMMENT 'Defines which perils are covered under each coverage type, with peril-specific deductible structures, sublimits, and coverage triggers. One row per coverage type per applicable peril..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` (
    `facultative_quotation_id` BIGINT COMMENT 'Unique surrogate identifier for each facultative quotation record. Primary key.',
    `facultative_marketing_id` BIGINT COMMENT 'Foreign key linking to coverage.facultative_marketing. Business justification: Facultative quotations result from marketing activity. Currently facultative_quotation links to quote and reinsurer, but not to the marketing activity that generated it.',
    `quote_id` BIGINT COMMENT 'Foreign key linking to the original insurance quote for which facultative reinsurance is being placed.',
    `reinsurer_id` BIGINT COMMENT 'Foreign key linking to the reinsurer providing the facultative quotation.',
    `acceptance_date` DATE COMMENT 'Date on which the ceding company accepted the reinsurers facultative quotation.',
    `brokerage_percentage` DECIMAL(5,2) COMMENT 'Brokerage fee percentage applicable to this facultative quotation if placed through a broker.',
    `commission_percentage` DECIMAL(5,2) COMMENT 'Ceding commission percentage offered by the reinsurer on this facultative placement.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this facultative quotation.',
    `decline_reason` STRING COMMENT 'Business reason provided by the reinsurer if the facultative quotation was declined.',
    `expiry_date` DATE COMMENT 'Date after which the reinsurers facultative quotation is no longer valid for acceptance.',
    `quote_date` DATE COMMENT 'Date on which the reinsurer provided their facultative quotation to the ceding company.',
    `quote_status` STRING COMMENT 'Current status of the reinsurers facultative quotation in the placement process.',
    `quoted_premium_amount` DECIMAL(15,2) COMMENT 'Premium amount quoted by the reinsurer for their share of the facultative placement.',
    `quoted_share_percentage` DECIMAL(5,2) COMMENT 'Percentage of the risk that the reinsurer is willing to assume under this facultative quotation.',
    `terms_and_conditions` STRING COMMENT 'Special terms, conditions, or exclusions attached to the reinsurers facultative quotation.',
    CONSTRAINT pk_facultative_quotation PRIMARY KEY(`facultative_quotation_id`)
) COMMENT 'Captures each reinsurers quoted terms for a specific facultative submission quote. Grain: one row per quote per reinsurer. Stores quoted share, premium, acceptance status, and quote date for facultative placement..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_marketing` (
    `facultative_marketing_id` BIGINT COMMENT 'Unique surrogate identifier for each facultative marketing record. Primary key.',
    `reinsurer_id` BIGINT COMMENT 'Foreign key to the reinsurer approached for facultative participation on this submission.',
    `submission_id` BIGINT COMMENT 'Foreign key to the submission being marketed for facultative reinsurance interest.',
    `contact_date` DATE COMMENT 'Date on which the reinsurer was contacted or approached regarding this submission.',
    `indicative_rate` DECIMAL(8,5) COMMENT 'Indicative facultative rate or pricing percentage provided by the reinsurer during marketing phase.',
    `indicative_terms_provided_flag` BOOLEAN COMMENT 'Boolean flag indicating whether the reinsurer provided indicative terms or pricing for this submission.',
    `marketing_status` STRING COMMENT 'Current status of the facultative marketing effort with this reinsurer for this submission.',
    `notes` STRING COMMENT 'Free-text notes capturing additional context or details about the marketing interaction with this reinsurer.',
    `reinsurer_interest_level` STRING COMMENT 'Categorical assessment of the reinsurers interest in participating on this submission.',
    `response_date` DATE COMMENT 'Date on which the reinsurer responded with their interest level or indicative terms.',
    CONSTRAINT pk_facultative_marketing PRIMARY KEY(`facultative_marketing_id`)
) COMMENT 'Tracks facultative reinsurance marketing activity per submission. Each record links one submission to one reinsurer approached for facultative interest, capturing contact date, interest level, and indicative terms provided during the marketing phase..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` (
    `coverage_transaction_id` BIGINT COMMENT 'Primary key for coverage_transaction',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to the coverage affected by this transaction.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to the policy transaction that modified this coverage.',
    `billing_transaction_id` BIGINT COMMENT '',
    `change_description` STRING COMMENT 'Detailed narrative describing the specific changes made to this coverage in this transaction. Printed on endorsement declarations.',
    `change_reason_code` STRING COMMENT 'Standardized code indicating why this coverage was modified in this transaction. Examples: LIMIT_INCREASE, ADD_COVERAGE, REMOVE_COVERAGE, RATE_CHANGE.',
    `coverage_status` STRING COMMENT 'Status of the coverage as of this transaction. Tracks lifecycle changes: Active, Suspended, Cancelled, Reinstated, Expired.',
    `effective_date` DATE COMMENT 'Date when this transactions changes to the coverage became effective. May differ from policy transaction effective date for phased endorsements.',
    `is_coverage_added_flag` BOOLEAN COMMENT 'Indicates whether this transaction added this coverage to the policy. True for new coverages added via endorsement.',
    `is_coverage_removed_flag` BOOLEAN COMMENT 'Indicates whether this transaction removed this coverage from the policy. True for coverages deleted via endorsement or cancellation.',
    `limit_change_amount` DECIMAL(18,2) COMMENT 'Net change in coverage limit resulting from this transaction. Null if limit unchanged.',
    `new_deductible_amount` DECIMAL(18,2) COMMENT 'Deductible amount after this transaction. Null if deductible unchanged.',
    `new_limit_amount` DECIMAL(18,2) COMMENT 'Coverage limit after this transaction was applied. Current limit for this coverage as of this transaction.',
    `premium_change_amount` DECIMAL(15,2) COMMENT 'Net change in written premium for this specific coverage resulting from this transaction. Positive for increases, negative for decreases.',
    `prior_deductible_amount` DECIMAL(18,2) COMMENT 'Deductible amount before this transaction. Null if deductible unchanged.',
    `prior_limit_amount` DECIMAL(18,2) COMMENT 'Coverage limit before this transaction was applied. Used for audit trail and premium calculation verification.',
    `prorated_premium_factor` DECIMAL(10,6) COMMENT 'Proration factor applied to calculate premium change for midterm transactions. Based on days remaining in term.',
    `underwriter_notes` STRING COMMENT 'Internal notes from underwriter regarding this coverage change. Used for audit and quality review.',
    CONSTRAINT pk_coverage_transaction PRIMARY KEY(`coverage_transaction_id`)
) COMMENT 'Event recording a policy transactions impact on a specific coverage. One row per coverage per transaction. Captures transaction-specific changes: premium delta, limit adjustments, effective dates, and status changes for audit and endorsement processing..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` (
    `form_attachment_id` BIGINT COMMENT 'Unique identifier for the coverage form attachment record. Primary key.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to the coverage to which this form is attached.',
    `policy_form_id` BIGINT COMMENT 'Foreign key linking to the policy form being attached to this coverage.',
    `attachment_reason_code` STRING COMMENT 'Coded reason for attaching this form to this coverage: regulatory requirement, risk mitigation, customer request, underwriter discretion.',
    `attachment_sequence` BIGINT COMMENT 'The order in which this form is attached to the coverage, used for precedence and interpretation when forms conflict or layer.',
    `effective_date` DATE COMMENT 'The date this form attachment becomes effective on the coverage.',
    `expiration_date` DATE COMMENT 'The date this form attachment expires or is removed from the coverage. Null indicates the form remains in force through coverage expiration.',
    `form_premium_amount` DECIMAL(15,2) COMMENT 'The additional premium amount charged for this form attachment on this specific coverage, if premium-bearing.',
    `form_status` STRING COMMENT 'Current status of the form attachment on this coverage: active, superseded by a newer edition, withdrawn, or pending approval.',
    `mandatory_flag` BOOLEAN COMMENT 'Indicates whether this form is mandatory per state filing or carrier underwriting rules for this specific coverage.',
    `premium_bearing_flag` BOOLEAN COMMENT 'Indicates whether this form attachment carries an additional premium charge specific to this coverage.',
    `underwriter_notes` STRING COMMENT 'Free-text notes from the underwriter regarding the reason for attaching this form to this specific coverage.',
    CONSTRAINT pk_form_attachment PRIMARY KEY(`form_attachment_id`)
) COMMENT 'One row per form attached to a coverage. Captures the attachment of ISO/ACORD forms and endorsements to specific coverages, recording attachment sequence, effective dates, mandatory status, and premium impact per coverage..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`shared_limit_group` (
    `shared_limit_group_id` BIGINT COMMENT 'Primary key for shared_limit_group',
    `allocation_method` STRING COMMENT 'Method used to allocate the shared limit across multiple coverages or claims when the limit is exhausted.',
    `applies_to_deductible_flag` BOOLEAN COMMENT 'Indicates whether the shared limit applies before or after deductibles are satisfied.',
    `coverage_scope` STRING COMMENT 'Defines the scope of coverages included within the shared limit group boundary.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the shared limit group record was first created in the system.',
    `effective_date` DATE COMMENT 'Date when the shared limit group definition becomes effective for policy binding and coverage attachment.',
    `expiration_date` DATE COMMENT 'Date when the shared limit group definition expires and is no longer available for new policy terms.',
    `group_code` STRING COMMENT 'Business identifier code for the shared limit group used in policy documents and underwriting systems.',
    `group_description` STRING COMMENT 'Detailed explanation of the shared limit group purpose, scope, and coverage aggregation rules.',
    `group_name` STRING COMMENT 'Descriptive name of the shared limit group for business user identification and reporting purposes.',
    `group_type` STRING COMMENT 'Classification of how the shared limit is applied across coverages within the group.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when the shared limit group record was most recently updated.',
    `limit_amount` DECIMAL(18,2) COMMENT 'Maximum aggregate limit amount shared across all coverages within this group.',
    `limit_basis` STRING COMMENT 'Basis on which the shared limit is calculated and applied across the policy term.',
    `limit_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the shared limit amount.',
    `line_of_business` STRING COMMENT 'Insurance line of business to which this shared limit group applies.',
    `maximum_reinstatements` BIGINT COMMENT 'Maximum number of times the shared limit can be reinstated within a single policy term.',
    `notes` STRING COMMENT 'Additional underwriting notes, special instructions, or business context for the shared limit group configuration.',
    `regulatory_approval_required_flag` BOOLEAN COMMENT 'Indicates whether this shared limit group structure requires state insurance department approval before use.',
    `regulatory_filing_number` STRING COMMENT 'State insurance department filing reference number for the approved shared limit group structure.',
    `reinstatement_premium_rate` DECIMAL(5,4) COMMENT 'Premium rate charged as a percentage of the original limit when the shared limit is reinstated.',
    `reinstatement_provision_flag` BOOLEAN COMMENT 'Indicates whether the shared limit can be reinstated after partial or full exhaustion during the policy term.',
    `shared_limit_group_status` STRING COMMENT 'Current lifecycle status of the shared limit group in the underwriting and policy administration system.',
    `version_number` BIGINT COMMENT 'Version number of the shared limit group definition to track changes and maintain historical configurations.',
    CONSTRAINT pk_shared_limit_group PRIMARY KEY(`shared_limit_group_id`)
) COMMENT 'Master reference table for shared_limit_group. Referenced by shared_limit_group_id.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_rule_set` (
    `rating_rule_set_id` BIGINT COMMENT 'Primary key for rating_rule_set',
    `parent_rule_set_id` BIGINT COMMENT 'Reference to a parent rating rule set when this rule set is a specialized or derived version, enabling hierarchical rule set structures.',
    `actuarial_basis` STRING COMMENT 'Description of the actuarial data, loss experience, and statistical methods underlying the development of this rating rule set.',
    `approval_date` DATE COMMENT 'Date on which the regulatory authority approved this rating rule set for use.',
    `approval_status` STRING COMMENT 'Current regulatory and internal approval state of the rating rule set within its lifecycle.',
    `approved_by` STRING COMMENT 'Name or identifier of the regulatory authority or internal approver who authorized this rating rule set.',
    `calculation_formula` STRING COMMENT 'Proprietary formula or expression defining how this rating rule set computes its output, stored as text or reference to formula library.',
    `catastrophe_load_percentage` DECIMAL(5,4) COMMENT 'Additional premium percentage loaded into rates to cover expected catastrophe losses for the jurisdiction and line of business.',
    `coverage_type` STRING COMMENT 'Specific coverage type within the line of business that this rating rule set applies to, such as liability, collision, or comprehensive.',
    `created_by_user` STRING COMMENT 'Identifier of the user or system process that created this rating rule set record.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this rating rule set record was first created in the system.',
    `credibility_factor` DECIMAL(5,4) COMMENT 'Statistical weight assigned to this rating rule set based on the volume and reliability of underlying loss data.',
    `effective_date` DATE COMMENT 'Date on which this rating rule set becomes active and available for use in premium calculations.',
    `expense_provision_percentage` DECIMAL(5,4) COMMENT 'Percentage of premium allocated to cover underwriting expenses, commissions, and overhead within this rating rule set.',
    `expiration_date` DATE COMMENT 'Date on which this rating rule set ceases to be valid for new business, nullable for open-ended rule sets.',
    `filing_date` DATE COMMENT 'Date on which this rating rule set was submitted to the regulatory authority for approval.',
    `is_active` BOOLEAN COMMENT 'Indicates whether this rating rule set is currently active and available for use in premium calculations.',
    `is_default` BOOLEAN COMMENT 'Indicates whether this rating rule set is the default choice for its line of business and jurisdiction when no specific rule set is selected.',
    `jurisdiction_code` STRING COMMENT 'Two-letter state or province code indicating the regulatory jurisdiction where this rating rule set is approved for use.',
    `line_of_business` STRING COMMENT 'Insurance line of business to which this rating rule set applies, defining the product scope.',
    `loss_cost_multiplier` DECIMAL(10,6) COMMENT 'Factor applied to advisory loss costs to derive final premium rates, incorporating expenses, profit, and contingencies.',
    `loss_ratio_target` DECIMAL(5,4) COMMENT 'Target loss ratio that this rating rule set is designed to achieve, expressed as a decimal proportion of premium to losses.',
    `maximum_premium_amount` DECIMAL(15,2) COMMENT 'Ceiling premium amount enforced by this rating rule set, capping exposure on high-risk policies.',
    `minimum_premium_amount` DECIMAL(15,2) COMMENT 'Floor premium amount enforced by this rating rule set, ensuring minimum revenue per policy.',
    `notes` STRING COMMENT 'Free-text field for additional comments, implementation guidance, or special instructions related to this rating rule set.',
    `priority_order` BIGINT COMMENT 'Numeric sequence defining the order in which this rating rule set is applied when multiple rule sets are chained in a rating workflow.',
    `profit_margin_percentage` DECIMAL(5,4) COMMENT 'Target profit margin built into the premium rates calculated by this rating rule set, expressed as a percentage.',
    `rating_algorithm` STRING COMMENT 'Mathematical approach used by this rule set to calculate premium factors or rates.',
    `regulatory_filing_number` STRING COMMENT 'Official filing reference number assigned by the state insurance department for this rating rule set approval.',
    `rounding_rule` STRING COMMENT 'Method for rounding calculated premium amounts to the nearest cent or dollar as specified by this rule set.',
    `rule_set_code` STRING COMMENT 'Business identifier code for the rating rule set, used for external reference and integration.',
    `rule_set_description` STRING COMMENT 'Detailed description of the rating rule set, including its business logic, application scope, and calculation methodology.',
    `rule_set_name` STRING COMMENT 'Human-readable name of the rating rule set describing its purpose and scope.',
    `rule_set_type` STRING COMMENT 'Classification of the rating rule set by its functional purpose in the premium calculation workflow.',
    `trend_factor` DECIMAL(7,6) COMMENT 'Adjustment factor applied to historical loss data to project future loss costs, accounting for inflation and claim severity trends.',
    `updated_by_user` STRING COMMENT 'Identifier of the user or system process that last modified this rating rule set record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this rating rule set record was last modified.',
    `version_number` STRING COMMENT 'Semantic version identifier for this rating rule set, tracking revisions and updates over time.',
    CONSTRAINT pk_rating_rule_set PRIMARY KEY(`rating_rule_set_id`)
) COMMENT 'Master reference table for rating_rule_set. Referenced by rating_rule_set_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ADD CONSTRAINT `fk_coverage_submission_party_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ADD CONSTRAINT `fk_coverage_uw_decision_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ADD CONSTRAINT `fk_coverage_uw_decision_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ADD CONSTRAINT `fk_coverage_uw_decision_uw_referral_id` FOREIGN KEY (`uw_referral_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral`(`uw_referral_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ADD CONSTRAINT `fk_coverage_uw_referral_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ADD CONSTRAINT `fk_coverage_uw_referral_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ADD CONSTRAINT `fk_coverage_risk_appetite_rule_coverage_type_id` FOREIGN KEY (`coverage_type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type`(`coverage_type_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ADD CONSTRAINT `fk_coverage_eligibility_check_primary_risk_appetite_rule_id` FOREIGN KEY (`primary_risk_appetite_rule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule`(`risk_appetite_rule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ADD CONSTRAINT `fk_coverage_eligibility_check_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ADD CONSTRAINT `fk_coverage_underwriting_risk_score_clearance_check_id` FOREIGN KEY (`clearance_check_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check`(`clearance_check_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ADD CONSTRAINT `fk_coverage_underwriting_risk_score_eligibility_check_id` FOREIGN KEY (`eligibility_check_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check`(`eligibility_check_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ADD CONSTRAINT `fk_coverage_underwriting_risk_score_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ADD CONSTRAINT `fk_coverage_quote_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ADD CONSTRAINT `fk_coverage_quote_coverage_bound_coverage_id` FOREIGN KEY (`bound_coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ADD CONSTRAINT `fk_coverage_quote_coverage_coverage_form_id` FOREIGN KEY (`coverage_form_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form`(`coverage_form_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ADD CONSTRAINT `fk_coverage_quote_coverage_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ADD CONSTRAINT `fk_coverage_quote_coverage_quote_option_id` FOREIGN KEY (`quote_option_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option`(`quote_option_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ADD CONSTRAINT `fk_coverage_quote_coverage_rating_worksheet_id` FOREIGN KEY (`rating_worksheet_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet`(`rating_worksheet_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ADD CONSTRAINT `fk_coverage_quote_option_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ADD CONSTRAINT `fk_coverage_rating_worksheet_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ADD CONSTRAINT `fk_coverage_rating_worksheet_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ADD CONSTRAINT `fk_coverage_rating_worksheet_rating_rule_set_id` FOREIGN KEY (`rating_rule_set_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`rating_rule_set`(`rating_rule_set_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ADD CONSTRAINT `fk_coverage_rating_worksheet_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ADD CONSTRAINT `fk_coverage_rating_worksheet_underwriting_risk_score_id` FOREIGN KEY (`underwriting_risk_score_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score`(`underwriting_risk_score_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ADD CONSTRAINT `fk_coverage_rating_factor_rating_worksheet_id` FOREIGN KEY (`rating_worksheet_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet`(`rating_worksheet_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ADD CONSTRAINT `fk_coverage_uw_condition_clearance_check_id` FOREIGN KEY (`clearance_check_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check`(`clearance_check_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ADD CONSTRAINT `fk_coverage_uw_condition_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ADD CONSTRAINT `fk_coverage_uw_condition_eligibility_check_id` FOREIGN KEY (`eligibility_check_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check`(`eligibility_check_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ADD CONSTRAINT `fk_coverage_uw_condition_inspection_order_id` FOREIGN KEY (`inspection_order_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order`(`inspection_order_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ADD CONSTRAINT `fk_coverage_uw_condition_loss_history_id` FOREIGN KEY (`loss_history_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history`(`loss_history_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ADD CONSTRAINT `fk_coverage_uw_condition_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ADD CONSTRAINT `fk_coverage_uw_condition_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ADD CONSTRAINT `fk_coverage_uw_condition_uw_decision_id` FOREIGN KEY (`uw_decision_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision`(`uw_decision_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_coverage_type_id` FOREIGN KEY (`coverage_type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type`(`coverage_type_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_inspection_order_id` FOREIGN KEY (`inspection_order_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order`(`inspection_order_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ADD CONSTRAINT `fk_coverage_underwriting_mvr_report_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ADD CONSTRAINT `fk_coverage_inspection_order_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ADD CONSTRAINT `fk_coverage_clearance_check_primary_risk_appetite_rule_id` FOREIGN KEY (`primary_risk_appetite_rule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule`(`risk_appetite_rule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ADD CONSTRAINT `fk_coverage_clearance_check_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ADD CONSTRAINT `fk_coverage_submission_document_inspection_order_id` FOREIGN KEY (`inspection_order_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order`(`inspection_order_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ADD CONSTRAINT `fk_coverage_submission_document_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ADD CONSTRAINT `fk_coverage_bind_request_binder_id` FOREIGN KEY (`binder_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`binder`(`binder_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ADD CONSTRAINT `fk_coverage_bind_request_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ADD CONSTRAINT `fk_coverage_bind_request_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ADD CONSTRAINT `fk_coverage_bind_request_uw_decision_id` FOREIGN KEY (`uw_decision_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision`(`uw_decision_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_uw_decision_id` FOREIGN KEY (`uw_decision_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision`(`uw_decision_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ADD CONSTRAINT `fk_coverage_submission_status_history_bind_request_id` FOREIGN KEY (`bind_request_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request`(`bind_request_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ADD CONSTRAINT `fk_coverage_submission_status_history_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ADD CONSTRAINT `fk_coverage_submission_status_history_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ADD CONSTRAINT `fk_coverage_submission_status_history_coverage_transaction_id` FOREIGN KEY (`coverage_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction`(`coverage_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ADD CONSTRAINT `fk_coverage_submission_status_history_uw_decision_id` FOREIGN KEY (`uw_decision_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision`(`uw_decision_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ADD CONSTRAINT `fk_coverage_submission_status_history_uw_referral_id` FOREIGN KEY (`uw_referral_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral`(`uw_referral_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_coverage_type_id` FOREIGN KEY (`coverage_type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type`(`coverage_type_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_part_id` FOREIGN KEY (`part_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`part`(`part_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_prior_coverage_id` FOREIGN KEY (`prior_coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ADD CONSTRAINT `fk_coverage_limit_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ADD CONSTRAINT `fk_coverage_limit_shared_limit_group_id` FOREIGN KEY (`shared_limit_group_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`shared_limit_group`(`shared_limit_group_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ADD CONSTRAINT `fk_coverage_deductible_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ADD CONSTRAINT `fk_coverage_exclusion_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ADD CONSTRAINT `fk_coverage_exclusion_superseded_by_exclusion_id` FOREIGN KEY (`superseded_by_exclusion_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion`(`exclusion_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ADD CONSTRAINT `fk_coverage_coverage_condition_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ADD CONSTRAINT `fk_coverage_coverage_form_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ADD CONSTRAINT `fk_coverage_coverage_form_coverage_type_id` FOREIGN KEY (`coverage_type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type`(`coverage_type_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ADD CONSTRAINT `fk_coverage_coverage_endorsement_coverage_form_id` FOREIGN KEY (`coverage_form_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form`(`coverage_form_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ADD CONSTRAINT `fk_coverage_coverage_endorsement_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ADD CONSTRAINT `fk_coverage_coverage_endorsement_superseded_by_endorsement_id` FOREIGN KEY (`superseded_by_endorsement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement`(`coverage_endorsement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ADD CONSTRAINT `fk_coverage_additional_interest_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ADD CONSTRAINT `fk_coverage_rate_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ADD CONSTRAINT `fk_coverage_rate_coverage_type_id` FOREIGN KEY (`coverage_type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type`(`coverage_type_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ADD CONSTRAINT `fk_coverage_coverage_peril_peril_link_id` FOREIGN KEY (`peril_link_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link`(`peril_link_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ADD CONSTRAINT `fk_coverage_peril_link_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` ADD CONSTRAINT `fk_coverage_coverage_interest_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` ADD CONSTRAINT `fk_coverage_coverage_cession_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility` ADD CONSTRAINT `fk_coverage_eligibility_coverage_type_id` FOREIGN KEY (`coverage_type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type`(`coverage_type_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`producer_coverage_authority` ADD CONSTRAINT `fk_coverage_producer_coverage_authority_coverage_type_id` FOREIGN KEY (`coverage_type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type`(`coverage_type_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` ADD CONSTRAINT `fk_coverage_type_peril_primary_coverage_type_id` FOREIGN KEY (`primary_coverage_type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type`(`coverage_type_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` ADD CONSTRAINT `fk_coverage_type_peril_type_coverage_type_id` FOREIGN KEY (`type_coverage_type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type`(`coverage_type_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ADD CONSTRAINT `fk_coverage_facultative_quotation_facultative_marketing_id` FOREIGN KEY (`facultative_marketing_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_marketing`(`facultative_marketing_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ADD CONSTRAINT `fk_coverage_facultative_quotation_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_marketing` ADD CONSTRAINT `fk_coverage_facultative_marketing_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ADD CONSTRAINT `fk_coverage_coverage_transaction_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` ADD CONSTRAINT `fk_coverage_form_attachment_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_rule_set` ADD CONSTRAINT `fk_coverage_rating_rule_set_parent_rule_set_id` FOREIGN KEY (`parent_rule_set_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`rating_rule_set`(`rating_rule_set_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`coverage` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`coverage` SET TAGS ('dbx_domain' = 'coverage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `bound_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Bound Policy Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `submission_applicant_party_id` SET TAGS ('dbx_business_glossary_term' = 'Applicant Party Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `submission_party_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `acord_form_type` SET TAGS ('dbx_business_glossary_term' = 'ACORD Form Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `acord_form_type` SET TAGS ('dbx_value_regex' = 'ACORD_125|ACORD_126|ACORD_140|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `clearance_status` SET TAGS ('dbx_business_glossary_term' = 'Clearance Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `clearance_status` SET TAGS ('dbx_value_regex' = 'cleared|pending|blocked|requires_documents');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `clue_report_date` SET TAGS ('dbx_business_glossary_term' = 'CLUE Report Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `credit_report_date` SET TAGS ('dbx_business_glossary_term' = 'Credit Report Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `credit_score` SET TAGS ('dbx_business_glossary_term' = 'Credit Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `credit_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|CAD|MXN');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `decline_reason` SET TAGS ('dbx_business_glossary_term' = 'Decline Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Requested Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `eligibility_status` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `eligibility_status` SET TAGS ('dbx_value_regex' = 'eligible|ineligible|conditional|pending_review');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `estimated_annual_premium` SET TAGS ('dbx_business_glossary_term' = 'Estimated Annual Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Requested Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `inspection_completed_date` SET TAGS ('dbx_business_glossary_term' = 'Inspection Completed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `inspection_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Inspection Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `line_of_business` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `loss_history_reviewed_flag` SET TAGS ('dbx_business_glossary_term' = 'Loss History Reviewed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `mvr_report_date` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Report Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System (NAICS) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Submission Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `policy_type_code` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `prior_carrier_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Prior Carrier NAIC Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_business_glossary_term' = 'Prior Carrier Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `prior_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `quote_count` SET TAGS ('dbx_business_glossary_term' = 'Quote Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `referral_reason` SET TAGS ('dbx_business_glossary_term' = 'Referral Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `referral_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Referral Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `risk_appetite_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Appetite Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `risk_country` SET TAGS ('dbx_business_glossary_term' = 'Risk Country');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `risk_country` SET TAGS ('dbx_value_regex' = 'USA|CAN|MEX');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `risk_country` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `risk_state` SET TAGS ('dbx_business_glossary_term' = 'Risk State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `risk_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification (SIC) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `source` SET TAGS ('dbx_business_glossary_term' = 'Submission Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `submission_status` SET TAGS ('dbx_business_glossary_term' = 'Submission Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `submission_type` SET TAGS ('dbx_business_glossary_term' = 'Submission Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `submission_type` SET TAGS ('dbx_value_regex' = 'new_business|renewal|rewrite|remarket');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `submitted_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Submitted By User Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `submitted_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `submitted_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `total_insured_value` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `withdrawn_reason` SET TAGS ('dbx_business_glossary_term' = 'Withdrawn Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `submission_party_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `role_id` SET TAGS ('dbx_business_glossary_term' = 'Party Role Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `clue_report_date` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Loss Underwriting Exchange (CLUE) Report Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `clue_report_ordered_flag` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Loss Underwriting Exchange (CLUE) Report Ordered Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `consent_date` SET TAGS ('dbx_business_glossary_term' = 'Consent Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `consent_to_rate_flag` SET TAGS ('dbx_business_glossary_term' = 'Consent to Rate Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `credit_score` SET TAGS ('dbx_business_glossary_term' = 'Credit Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `credit_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `distribution_channel` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `distribution_channel` SET TAGS ('dbx_value_regex' = 'DIRECT|INDEPENDENT_AGENT|CAPTIVE_AGENT|BROKER|ONLINE|AFFINITY');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `fraud_indicator_flag` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `fraud_indicator_flag` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `fraud_score` SET TAGS ('dbx_business_glossary_term' = 'Fraud Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `fraud_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `insurable_interest_type` SET TAGS ('dbx_business_glossary_term' = 'Insurable Interest Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `insurable_interest_type` SET TAGS ('dbx_value_regex' = 'OWNER|LESSEE|MORTGAGEE|LIENHOLDER|BAILEE|TRUSTEE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `is_primary_party` SET TAGS ('dbx_business_glossary_term' = 'Is Primary Party Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `kyc_verification_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Verification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `kyc_verification_status` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Verification Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `kyc_verification_status` SET TAGS ('dbx_value_regex' = 'VERIFIED|PENDING|FAILED|NOT_REQUIRED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `lapse_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Lapse Duration in Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `loss_payee_rank` SET TAGS ('dbx_business_glossary_term' = 'Loss Payee Rank');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `modified_by_user` SET TAGS ('dbx_business_glossary_term' = 'Modified By User');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `mvr_ordered_flag` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Ordered Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `mvr_report_date` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Report Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `party_role_code` SET TAGS ('dbx_business_glossary_term' = 'Party Role Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_business_glossary_term' = 'Prior Carrier Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `prior_coverage_lapse_flag` SET TAGS ('dbx_business_glossary_term' = 'Prior Coverage Lapse Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `prior_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `producer_appointment_status` SET TAGS ('dbx_business_glossary_term' = 'Producer Appointment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `producer_appointment_status` SET TAGS ('dbx_value_regex' = 'ACTIVE|INACTIVE|PENDING|TERMINATED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `producer_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Producer Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `producer_commission_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `producer_npn` SET TAGS ('dbx_business_glossary_term' = 'National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `producer_npn` SET TAGS ('dbx_value_regex' = '^[0-9]{10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `referral_reason` SET TAGS ('dbx_business_glossary_term' = 'Referral Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `relationship_to_applicant` SET TAGS ('dbx_business_glossary_term' = 'Relationship to Applicant');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `risk_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `role_sequence` SET TAGS ('dbx_business_glossary_term' = 'Role Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `role_status` SET TAGS ('dbx_business_glossary_term' = 'Role Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `role_status` SET TAGS ('dbx_value_regex' = 'ACTIVE|INACTIVE|PENDING|TERMINATED|SUSPENDED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter (UW) Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `underwriting_referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_value_regex' = 'PREFERRED|STANDARD|SUBSTANDARD|DECLINED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ALTER COLUMN `years_with_prior_carrier` SET TAGS ('dbx_business_glossary_term' = 'Years with Prior Carrier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `uw_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `uw_approved_by_party_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Party Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `uw_party_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Underwriter (UW) Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `uw_referral_id` SET TAGS ('dbx_business_glossary_term' = 'Uw Referral Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `uw_referred_to_underwriter_party_id` SET TAGS ('dbx_business_glossary_term' = 'Referred To Underwriter (UW) Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `appetite_match_flag` SET TAGS ('dbx_business_glossary_term' = 'Appetite Match Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `assigned_underwriter_name` SET TAGS ('dbx_business_glossary_term' = 'Assigned Underwriter (UW) Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `assigned_underwriter_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `automated_decision_flag` SET TAGS ('dbx_business_glossary_term' = 'Automated Decision Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `conditions_required` SET TAGS ('dbx_business_glossary_term' = 'Conditions Required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `decision_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `decision_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `decision_model_version` SET TAGS ('dbx_business_glossary_term' = 'Decision Model Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `decision_number` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `decision_rationale` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Rationale');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `decision_status` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `decision_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `decision_type` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `decision_type` SET TAGS ('dbx_value_regex' = 'accept|decline|refer|modify|counter_offer|conditional_accept');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `decline_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Decline Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `decline_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Decline Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `eligibility_flag` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `endorsements_required` SET TAGS ('dbx_business_glossary_term' = 'Endorsements Required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `exclusions_added` SET TAGS ('dbx_business_glossary_term' = 'Exclusions Added');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `modified_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Modified Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `modified_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Modified Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `modified_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Modified Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `override_flag` SET TAGS ('dbx_business_glossary_term' = 'Override Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `override_reason` SET TAGS ('dbx_business_glossary_term' = 'Override Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `referral_due_date` SET TAGS ('dbx_business_glossary_term' = 'Referral Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `referral_priority` SET TAGS ('dbx_business_glossary_term' = 'Referral Priority');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `referral_priority` SET TAGS ('dbx_value_regex' = 'low|normal|high|urgent|critical');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `referral_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Referral Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `referral_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Referral Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `risk_tier` SET TAGS ('dbx_business_glossary_term' = 'Risk Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `risk_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|substandard|declined');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `sla_actual_hours` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Actual Hours');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `sla_met_flag` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Met Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `sla_target_hours` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Target Hours');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `underwriter_authority_level` SET TAGS ('dbx_business_glossary_term' = 'Underwriter (UW) Authority Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `underwriter_authority_level` SET TAGS ('dbx_value_regex' = 'junior|senior|principal|chief|automated');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `uw_referral_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Referral Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `term_id` SET TAGS ('dbx_business_glossary_term' = 'Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `uw_assigned_underwriter_party_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Underwriter (UW) Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `uw_party_id` SET TAGS ('dbx_business_glossary_term' = 'Referring Underwriter (UW) Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `approval_conditions` SET TAGS ('dbx_business_glossary_term' = 'Approval Conditions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `assigned_underwriter_name` SET TAGS ('dbx_business_glossary_term' = 'Assigned Underwriter (UW) Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `assigned_underwriter_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `authority_level_required` SET TAGS ('dbx_business_glossary_term' = 'Authority Level Required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `authority_level_required` SET TAGS ('dbx_value_regex' = 'senior_underwriter|chief_underwriter|regional_manager|executive_approval');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `catastrophe_exposure_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposure Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Created By User Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `decline_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Decline Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `decline_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Decline Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `escalation_level` SET TAGS ('dbx_business_glossary_term' = 'Escalation Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `fraud_indicator_flag` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `prior_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `prior_loss_count` SET TAGS ('dbx_business_glossary_term' = 'Prior Loss Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Priority Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'low|normal|high|urgent|critical');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `product_code` SET TAGS ('dbx_business_glossary_term' = 'Product Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `referral_assigned_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Referral Assigned Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `referral_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Referral Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `referral_number` SET TAGS ('dbx_business_glossary_term' = 'Referral Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `referral_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Referral Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `referral_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Referral Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `referral_status` SET TAGS ('dbx_business_glossary_term' = 'Referral Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `referral_type` SET TAGS ('dbx_business_glossary_term' = 'Referral Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `referral_type` SET TAGS ('dbx_value_regex' = 'new_business|renewal|endorsement|cancellation|reinstatement|quote_revision');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `regulatory_concern_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Concern Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `reinsurance_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `resolution_notes` SET TAGS ('dbx_business_glossary_term' = 'Resolution Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `resolution_outcome` SET TAGS ('dbx_business_glossary_term' = 'Resolution Outcome');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `resolution_outcome` SET TAGS ('dbx_value_regex' = 'approved|approved_with_conditions|declined|withdrawn|escalated|returned_for_rework');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `resolution_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Resolution Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `sla_due_date` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `sla_due_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Due Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `total_insured_value` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `risk_appetite_rule_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Appetite Rule ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `coverage_type_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `policy_type_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `approval_authority_level` SET TAGS ('dbx_business_glossary_term' = 'Approval Authority Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `approval_authority_level` SET TAGS ('dbx_value_regex' = 'auto|underwriter|senior_underwriter|chief_underwriter|executive');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approved Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `business_owner` SET TAGS ('dbx_business_glossary_term' = 'Business Owner');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `class_code` SET TAGS ('dbx_business_glossary_term' = 'Class Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `condition_expression` SET TAGS ('dbx_business_glossary_term' = 'Condition Expression');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `decision_action` SET TAGS ('dbx_business_glossary_term' = 'Decision Action');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `decision_action` SET TAGS ('dbx_value_regex' = 'accept|decline|refer|quote_with_conditions|require_endorsement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `exception_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Exception Allowed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `mandatory_endorsement_code` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Endorsement Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `pricing_adjustment_factor` SET TAGS ('dbx_business_glossary_term' = 'Pricing Adjustment Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `priority_rank` SET TAGS ('dbx_business_glossary_term' = 'Priority Rank');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `referral_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Referral Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `regulatory_mandate_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Mandate Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `rule_code` SET TAGS ('dbx_business_glossary_term' = 'Rule Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `rule_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,20}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `rule_description` SET TAGS ('dbx_business_glossary_term' = 'Rule Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `rule_name` SET TAGS ('dbx_business_glossary_term' = 'Rule Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `rule_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `rule_status` SET TAGS ('dbx_business_glossary_term' = 'Rule Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `rule_status` SET TAGS ('dbx_value_regex' = 'draft|active|suspended|retired|pending_approval');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `rule_type` SET TAGS ('dbx_business_glossary_term' = 'Rule Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `rule_type` SET TAGS ('dbx_value_regex' = 'eligibility|appetite|guideline|class_restriction|mandatory_endorsement|pricing_constraint');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `threshold_unit` SET TAGS ('dbx_business_glossary_term' = 'Threshold Unit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `threshold_unit` SET TAGS ('dbx_value_regex' = 'currency|percentage|count|ratio|score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `threshold_value` SET TAGS ('dbx_business_glossary_term' = 'Threshold Value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `eligibility_check_id` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Check Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `eligibility_override_user_party_id` SET TAGS ('dbx_business_glossary_term' = 'Override User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `eligibility_override_user_party_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `eligibility_party_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `primary_risk_appetite_rule_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Risk Appetite Rule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `appetite_tier` SET TAGS ('dbx_business_glossary_term' = 'Risk Appetite Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `appetite_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|non_standard|declined');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `check_duration_seconds` SET TAGS ('dbx_business_glossary_term' = 'Check Duration in Seconds');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `check_number` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Check Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `check_status` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Check Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `check_status` SET TAGS ('dbx_value_regex' = 'pass|fail|pending|override|manual_review');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `check_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Check Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `decision_reason` SET TAGS ('dbx_business_glossary_term' = 'Decision Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `eligibility_decision` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Decision');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `eligibility_decision` SET TAGS ('dbx_value_regex' = 'eligible|ineligible|conditional|refer');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `fail_flag` SET TAGS ('dbx_business_glossary_term' = 'Fail Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `failed_rule_ids` SET TAGS ('dbx_business_glossary_term' = 'Failed Rule Identifiers (IDs)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `override_flag` SET TAGS ('dbx_business_glossary_term' = 'Override Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `override_reason` SET TAGS ('dbx_business_glossary_term' = 'Override Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `override_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Override Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `pass_flag` SET TAGS ('dbx_business_glossary_term' = 'Pass Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `product_code` SET TAGS ('dbx_business_glossary_term' = 'Product Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `referral_reason` SET TAGS ('dbx_business_glossary_term' = 'Referral Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `risk_score_band` SET TAGS ('dbx_business_glossary_term' = 'Risk Score Band');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `risk_score_band` SET TAGS ('dbx_value_regex' = 'low|medium|high|very_high');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `rule_set_name` SET TAGS ('dbx_business_glossary_term' = 'Rule Set Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `rule_set_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `rule_set_version` SET TAGS ('dbx_business_glossary_term' = 'Rule Set Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ALTER COLUMN `triggered_rule_ids` SET TAGS ('dbx_business_glossary_term' = 'Triggered Rule Identifiers (IDs)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `underwriting_risk_score_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Risk Score ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `clearance_check_id` SET TAGS ('dbx_business_glossary_term' = 'Clearance Check Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `eligibility_check_id` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Check Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Override By User ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `term_id` SET TAGS ('dbx_business_glossary_term' = 'Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `auto_decline_flag` SET TAGS ('dbx_business_glossary_term' = 'Auto Decline Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `auto_decline_reason` SET TAGS ('dbx_business_glossary_term' = 'Auto Decline Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `catastrophe_score` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposure Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `claim_count_3yr` SET TAGS ('dbx_business_glossary_term' = 'Claim Count 3 Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `claim_count_5yr` SET TAGS ('dbx_business_glossary_term' = 'Claim Count 5 Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `clue_score` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Loss Underwriting Exchange (CLUE) Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `composite_score` SET TAGS ('dbx_business_glossary_term' = 'Composite Risk Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `cope_score` SET TAGS ('dbx_business_glossary_term' = 'Construction Occupancy Protection Exposure (COPE) Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `credit_score` SET TAGS ('dbx_business_glossary_term' = 'Insurance Credit Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `credit_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `itv_ratio` SET TAGS ('dbx_business_glossary_term' = 'Insurance to Value (ITV) Ratio');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `lapse_in_coverage_days` SET TAGS ('dbx_business_glossary_term' = 'Lapse in Coverage Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `lob` SET TAGS ('dbx_value_regex' = 'personal_auto|homeowners|commercial_auto|commercial_property|general_liability|workers_comp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `loss_free_years` SET TAGS ('dbx_business_glossary_term' = 'Loss Free Years');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `mvr_score` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `occupancy_score` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Risk Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `override_flag` SET TAGS ('dbx_business_glossary_term' = 'Override Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `override_reason` SET TAGS ('dbx_business_glossary_term' = 'Override Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `override_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Override Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `prior_carrier_score` SET TAGS ('dbx_business_glossary_term' = 'Prior Carrier Continuity Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `protection_class` SET TAGS ('dbx_business_glossary_term' = 'Protection Class Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `score_band` SET TAGS ('dbx_business_glossary_term' = 'Score Band Classification');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `score_band` SET TAGS ('dbx_value_regex' = 'excellent|preferred|standard|substandard|declined|refer');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `score_confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Score Confidence Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `score_confidence_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `score_model_name` SET TAGS ('dbx_business_glossary_term' = 'Score Model Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `score_model_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `score_model_version` SET TAGS ('dbx_business_glossary_term' = 'Score Model Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `score_reason_code_1` SET TAGS ('dbx_business_glossary_term' = 'Score Reason Code 1');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `score_reason_code_2` SET TAGS ('dbx_business_glossary_term' = 'Score Reason Code 2');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `score_reason_code_3` SET TAGS ('dbx_business_glossary_term' = 'Score Reason Code 3');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `score_reason_code_4` SET TAGS ('dbx_business_glossary_term' = 'Score Reason Code 4');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `score_run_code` SET TAGS ('dbx_business_glossary_term' = 'Score Run ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `score_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Score Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `scoring_engine` SET TAGS ('dbx_business_glossary_term' = 'Scoring Engine');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `territory_score` SET TAGS ('dbx_business_glossary_term' = 'Territory Risk Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `total_incurred_3yr` SET TAGS ('dbx_business_glossary_term' = 'Total Incurred 3 Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `uw_referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `uw_referral_reason` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Referral Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ALTER COLUMN `years_with_prior_carrier` SET TAGS ('dbx_business_glossary_term' = 'Years with Prior Carrier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `base_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `binding_authority_flag` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `bound_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Bound By User Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `bound_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `bound_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `bound_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Bound Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|AUD');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `decline_reason` SET TAGS ('dbx_business_glossary_term' = 'Decline Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `distribution_channel` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `distribution_channel` SET TAGS ('dbx_value_regex' = 'direct|captive_agent|independent_agent|broker|online|affinity');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Quote Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Quote Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Quote Expiry Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `loss_free_years` SET TAGS ('dbx_business_glossary_term' = 'Loss Free Years');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Quote Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Quote Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `payment_plan_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `policy_type_code` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_business_glossary_term' = 'Prior Carrier Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `prior_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `prior_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `quote_date` SET TAGS ('dbx_business_glossary_term' = 'Quote Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `quote_status` SET TAGS ('dbx_business_glossary_term' = 'Quote Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `quote_status` SET TAGS ('dbx_value_regex' = 'draft|quoted|bound|declined|expired|withdrawn');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `quoted_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Quoted Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `rate_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Rate Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `rating_engine_version` SET TAGS ('dbx_business_glossary_term' = 'Rating Engine Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `rating_tier` SET TAGS ('dbx_business_glossary_term' = 'Rating Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `rating_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|non_standard|declined');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `referral_reason` SET TAGS ('dbx_business_glossary_term' = 'Referral Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Quote Version Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `quote_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `bound_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Bound Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `quote_option_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Option Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `rating_worksheet_id` SET TAGS ('dbx_business_glossary_term' = 'Rating Worksheet Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `aggregate_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `class_code` SET TAGS ('dbx_business_glossary_term' = 'Class Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `condition_codes` SET TAGS ('dbx_business_glossary_term' = 'Condition Codes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_business_glossary_term' = 'Coverage Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_value_regex' = 'occurrence|claims_made|claims_made_reported|aggregate|per_event');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `coverage_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `coverage_description` SET TAGS ('dbx_business_glossary_term' = 'Coverage Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `coverage_name` SET TAGS ('dbx_business_glossary_term' = 'Coverage Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `coverage_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `coverage_status` SET TAGS ('dbx_business_glossary_term' = 'Coverage Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `coverage_status` SET TAGS ('dbx_value_regex' = 'quoted|declined|referred|accepted|excluded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `coverage_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `coverage_type` SET TAGS ('dbx_value_regex' = 'primary|excess|umbrella|supplemental|optional|mandatory');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `declination_reason` SET TAGS ('dbx_business_glossary_term' = 'Declination Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `deductible_applies_to` SET TAGS ('dbx_business_glossary_term' = 'Deductible Applies To');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `deductible_applies_to` SET TAGS ('dbx_value_regex' = 'per_occurrence|per_claim|per_policy_term|aggregate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `deductible_type` SET TAGS ('dbx_business_glossary_term' = 'Deductible Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `deductible_type` SET TAGS ('dbx_value_regex' = 'flat|percentage|franchise|disappearing|aggregate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `endorsement_codes` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Codes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `exclusion_codes` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Codes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `exposure_units` SET TAGS ('dbx_business_glossary_term' = 'Exposure Units');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `extended_reporting_period_months` SET TAGS ('dbx_business_glossary_term' = 'Extended Reporting Period (ERP) Months');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `form_edition_date` SET TAGS ('dbx_business_glossary_term' = 'Form Edition Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `form_number` SET TAGS ('dbx_business_glossary_term' = 'Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `is_declined` SET TAGS ('dbx_business_glossary_term' = 'Is Declined Coverage Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Is Mandatory Coverage Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `limit_type` SET TAGS ('dbx_business_glossary_term' = 'Limit Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `limit_type` SET TAGS ('dbx_value_regex' = 'per_occurrence|per_claim|aggregate|combined_single|split');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `per_accident_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Per Accident Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `per_person_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Per Person Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `premium_basis` SET TAGS ('dbx_business_glossary_term' = 'Premium Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `quoted_date` SET TAGS ('dbx_business_glossary_term' = 'Quoted Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `quoted_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Quoted Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `rate` SET TAGS ('dbx_business_glossary_term' = 'Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `retroactive_date` SET TAGS ('dbx_business_glossary_term' = 'Retroactive Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `self_insured_retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'actual_cash_value|replacement_cost|agreed_value|stated_amount|market_value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_business_glossary_term' = 'Waiting Period Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `quote_option_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Option Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `quoted_by_party_id` SET TAGS ('dbx_business_glossary_term' = 'Quoted By Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `base_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `commission_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `coverage_package_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Package Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `declination_reason` SET TAGS ('dbx_business_glossary_term' = 'Declination Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `down_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Down Payment Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `installment_amount` SET TAGS ('dbx_business_glossary_term' = 'Installment Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `installment_count` SET TAGS ('dbx_business_glossary_term' = 'Installment Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `is_default_option` SET TAGS ('dbx_business_glossary_term' = 'Is Default Option Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `is_selected` SET TAGS ('dbx_business_glossary_term' = 'Is Selected Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `limit_type` SET TAGS ('dbx_business_glossary_term' = 'Limit Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `limit_type` SET TAGS ('dbx_value_regex' = 'per_occurrence|aggregate|combined_single_limit|split_limit|blanket');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `lob` SET TAGS ('dbx_value_regex' = 'personal_auto|commercial_auto|homeowners|commercial_property|general_liability|workers_comp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `option_description` SET TAGS ('dbx_business_glossary_term' = 'Option Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `option_name` SET TAGS ('dbx_business_glossary_term' = 'Option Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `option_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `option_number` SET TAGS ('dbx_business_glossary_term' = 'Option Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `option_status` SET TAGS ('dbx_business_glossary_term' = 'Option Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `option_status` SET TAGS ('dbx_value_regex' = 'active|withdrawn|expired|bound|declined');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `option_type` SET TAGS ('dbx_business_glossary_term' = 'Option Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `option_type` SET TAGS ('dbx_value_regex' = 'standard|enhanced|economy|custom|package|ala_carte');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `payment_plan_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `policy_form_code` SET TAGS ('dbx_business_glossary_term' = 'Policy Form Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `producer_code` SET TAGS ('dbx_business_glossary_term' = 'Producer Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `rating_class` SET TAGS ('dbx_business_glossary_term' = 'Rating Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `rating_tier` SET TAGS ('dbx_business_glossary_term' = 'Rating Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `rating_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|non_standard|high_risk');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `sir_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `term_months` SET TAGS ('dbx_business_glossary_term' = 'Term Months');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `total_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `rating_worksheet_id` SET TAGS ('dbx_business_glossary_term' = 'Rating Worksheet Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `classification_code_id` SET TAGS ('dbx_business_glossary_term' = 'Classification Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `override_user_party_id` SET TAGS ('dbx_business_glossary_term' = 'Override User Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `rating_rule_set_id` SET TAGS ('dbx_business_glossary_term' = 'Rating Rule Set Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `underwriting_risk_score_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Risk Score Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `unit_of_measure_id` SET TAGS ('dbx_business_glossary_term' = 'Unit Of Measure Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `base_rate` SET TAGS ('dbx_business_glossary_term' = 'Base Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `deductible_credit_factor` SET TAGS ('dbx_business_glossary_term' = 'Deductible Credit Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `experience_modifier` SET TAGS ('dbx_business_glossary_term' = 'Experience Modifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `exposure_base` SET TAGS ('dbx_business_glossary_term' = 'Exposure Base');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `final_premium` SET TAGS ('dbx_business_glossary_term' = 'Final Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `increased_limits_factor` SET TAGS ('dbx_business_glossary_term' = 'Increased Limits Factor (ILF)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `lob` SET TAGS ('dbx_value_regex' = 'personal_auto|commercial_auto|homeowners|commercial_property|general_liability|workers_comp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `manual_premium` SET TAGS ('dbx_business_glossary_term' = 'Manual Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `minimum_premium` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `minimum_premium_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Applied Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `override_flag` SET TAGS ('dbx_business_glossary_term' = 'Override Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `override_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Override Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `override_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Override Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `policy_type_code` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `rate_table_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `rate_table_version` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `rated_premium` SET TAGS ('dbx_business_glossary_term' = 'Rated Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `rating_calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Rating Calculation Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `rating_calculation_method` SET TAGS ('dbx_value_regex' = 'manual|automated|hybrid');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `rating_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Rating Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `rating_engine_name` SET TAGS ('dbx_business_glossary_term' = 'Rating Engine Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `rating_engine_name` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `rating_engine_version` SET TAGS ('dbx_business_glossary_term' = 'Rating Engine Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `rating_notes` SET TAGS ('dbx_business_glossary_term' = 'Rating Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `rating_run_number` SET TAGS ('dbx_business_glossary_term' = 'Rating Run Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `rating_status` SET TAGS ('dbx_business_glossary_term' = 'Rating Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `rating_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|failed|rejected|overridden');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `rating_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Rating Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `schedule_modifier` SET TAGS ('dbx_business_glossary_term' = 'Schedule Modifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `total_credit_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Credit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `total_surcharge_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Surcharge Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `validation_error_message` SET TAGS ('dbx_business_glossary_term' = 'Validation Error Message');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `validation_status` SET TAGS ('dbx_business_glossary_term' = 'Validation Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'passed|failed|warning|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `rating_factor_id` SET TAGS ('dbx_business_glossary_term' = 'Rating Factor Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `override_user_party_id` SET TAGS ('dbx_business_glossary_term' = 'Override User Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `rating_worksheet_id` SET TAGS ('dbx_business_glossary_term' = 'Rating Worksheet Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `calculation_formula` SET TAGS ('dbx_business_glossary_term' = 'Calculation Formula');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `coverage_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Factor Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Factor Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `factor_basis` SET TAGS ('dbx_business_glossary_term' = 'Rating Factor Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `factor_category` SET TAGS ('dbx_business_glossary_term' = 'Rating Factor Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `factor_code` SET TAGS ('dbx_business_glossary_term' = 'Rating Factor Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `factor_description` SET TAGS ('dbx_business_glossary_term' = 'Rating Factor Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `factor_name` SET TAGS ('dbx_business_glossary_term' = 'Rating Factor Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `factor_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `factor_sequence` SET TAGS ('dbx_business_glossary_term' = 'Factor Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `factor_source` SET TAGS ('dbx_business_glossary_term' = 'Rating Factor Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `factor_source` SET TAGS ('dbx_value_regex' = 'iso_table|proprietary_table|manual_override|actuarial_model|state_filing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `factor_type` SET TAGS ('dbx_business_glossary_term' = 'Rating Factor Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `factor_type` SET TAGS ('dbx_value_regex' = 'multiplier|additive|percentage|flat_amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `factor_value` SET TAGS ('dbx_business_glossary_term' = 'Rating Factor Value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `filing_number` SET TAGS ('dbx_business_glossary_term' = 'State Filing Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `is_filed` SET TAGS ('dbx_business_glossary_term' = 'Is Filed Factor Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Is Mandatory Factor Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `max_factor_value` SET TAGS ('dbx_business_glossary_term' = 'Maximum Factor Value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `min_factor_value` SET TAGS ('dbx_business_glossary_term' = 'Minimum Factor Value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `override_reason` SET TAGS ('dbx_business_glossary_term' = 'Override Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `override_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Override Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `rating_factor_status` SET TAGS ('dbx_business_glossary_term' = 'Rating Factor Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `rating_factor_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending_approval|superseded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `table_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Rating Table Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `table_name` SET TAGS ('dbx_business_glossary_term' = 'Rating Table Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `table_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `table_version` SET TAGS ('dbx_business_glossary_term' = 'Rating Table Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `uw_condition_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Condition Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `clearance_check_id` SET TAGS ('dbx_business_glossary_term' = 'Clearance Check Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `eligibility_check_id` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Check Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `inspection_order_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Order Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `loss_history_id` SET TAGS ('dbx_business_glossary_term' = 'Loss History Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `term_id` SET TAGS ('dbx_business_glossary_term' = 'Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `uw_approved_by_underwriter_party_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Underwriter Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `uw_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Uw Decision Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `uw_party_id` SET TAGS ('dbx_business_glossary_term' = 'Imposed By Underwriter Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `uw_referred_to_underwriter_party_id` SET TAGS ('dbx_business_glossary_term' = 'Referred To Underwriter Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `uw_waived_by_underwriter_party_id` SET TAGS ('dbx_business_glossary_term' = 'Waived By Underwriter Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `condition_category` SET TAGS ('dbx_business_glossary_term' = 'Condition Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `condition_code` SET TAGS ('dbx_business_glossary_term' = 'Condition Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `condition_description` SET TAGS ('dbx_business_glossary_term' = 'Condition Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `condition_number` SET TAGS ('dbx_business_glossary_term' = 'Condition Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `condition_status` SET TAGS ('dbx_business_glossary_term' = 'Condition Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `condition_status` SET TAGS ('dbx_value_regex' = 'pending|fulfilled|waived|expired|not_fulfilled|cancelled');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `condition_type` SET TAGS ('dbx_business_glossary_term' = 'Condition Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `condition_type` SET TAGS ('dbx_value_regex' = 'warranty|requirement|restriction|endorsement_mandatory|survey_required|inspection_required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `document_reference` SET TAGS ('dbx_business_glossary_term' = 'Document Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `fulfilled_date` SET TAGS ('dbx_business_glossary_term' = 'Fulfilled Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `fulfillment_method` SET TAGS ('dbx_business_glossary_term' = 'Fulfillment Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `fulfillment_notes` SET TAGS ('dbx_business_glossary_term' = 'Fulfillment Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `imposed_date` SET TAGS ('dbx_business_glossary_term' = 'Imposed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `is_binding_condition` SET TAGS ('dbx_business_glossary_term' = 'Is Binding Condition Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `is_renewal_condition` SET TAGS ('dbx_business_glossary_term' = 'Is Renewal Condition Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `line_of_business` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Modified By User Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `premium_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Impact Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `premium_impact_percentage` SET TAGS ('dbx_business_glossary_term' = 'Premium Impact Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Priority');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `referral_date` SET TAGS ('dbx_business_glossary_term' = 'Referral Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `referral_required` SET TAGS ('dbx_business_glossary_term' = 'Referral Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `system_source` SET TAGS ('dbx_business_glossary_term' = 'System Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `waived_date` SET TAGS ('dbx_business_glossary_term' = 'Waived Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `loss_history_id` SET TAGS ('dbx_business_glossary_term' = 'Loss History ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Loss History Verification - Claim Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `coverage_type_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `inspection_order_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Order Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `verified_by_adjuster_id` SET TAGS ('dbx_business_glossary_term' = 'Verified By Adjuster');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `at_fault_flag` SET TAGS ('dbx_business_glossary_term' = 'At Fault Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `catastrophe_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `catastrophe_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `claim_status` SET TAGS ('dbx_business_glossary_term' = 'Claim Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `claim_status` SET TAGS ('dbx_value_regex' = 'open|closed|settled|denied|withdrawn');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `clue_report_order_number` SET TAGS ('dbx_business_glossary_term' = 'CLUE (Comprehensive Loss Underwriting Exchange) Report Order Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `coverage_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `excluded_from_rating_flag` SET TAGS ('dbx_business_glossary_term' = 'Excluded from Rating Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `exclusion_reason` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `impact_on_current_claim` SET TAGS ('dbx_business_glossary_term' = 'Impact on Current Claim');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `impact_on_rating` SET TAGS ('dbx_business_glossary_term' = 'Impact on Rating');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `impact_on_rating` SET TAGS ('dbx_value_regex' = 'surcharge|decline|refer|no_impact|credit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `incurred_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `lookback_period_months` SET TAGS ('dbx_business_glossary_term' = 'Lookback Period Months');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `loss_cause_code` SET TAGS ('dbx_business_glossary_term' = 'Loss Cause Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `loss_cause_description` SET TAGS ('dbx_business_glossary_term' = 'Loss Cause Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `loss_date` SET TAGS ('dbx_business_glossary_term' = 'Loss Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `loss_description` SET TAGS ('dbx_business_glossary_term' = 'Loss Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `loss_free_years` SET TAGS ('dbx_business_glossary_term' = 'Loss Free Years');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `loss_type` SET TAGS ('dbx_business_glossary_term' = 'Loss Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `loss_type` SET TAGS ('dbx_value_regex' = 'first_party|third_party|liability|property|auto|workers_comp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `mvr_report_order_number` SET TAGS ('dbx_business_glossary_term' = 'MVR (Motor Vehicle Record) Report Order Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `prior_carrier_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Prior Carrier NAIC (National Association of Insurance Commissioners) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `prior_carrier_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_business_glossary_term' = 'Prior Carrier Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `prior_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `report_date` SET TAGS ('dbx_business_glossary_term' = 'Report Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `surcharge_amount` SET TAGS ('dbx_business_glossary_term' = 'Surcharge Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `surcharge_percentage` SET TAGS ('dbx_business_glossary_term' = 'Surcharge Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Variance Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `variance_explanation` SET TAGS ('dbx_business_glossary_term' = 'Variance Explanation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Verification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `verification_method` SET TAGS ('dbx_business_glossary_term' = 'Verification Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `verification_method` SET TAGS ('dbx_value_regex' = 'third_party_report|carrier_inquiry|applicant_statement|document_review');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `verification_status` SET TAGS ('dbx_business_glossary_term' = 'Verification Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `verified_flag` SET TAGS ('dbx_business_glossary_term' = 'Verified Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `within_lookback_flag` SET TAGS ('dbx_business_glossary_term' = 'Within Lookback Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `underwriting_mvr_report_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Motor Vehicle Record (MVR) Report ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `riskexposure_driver_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Driver Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `underwriting_driver_party_id` SET TAGS ('dbx_business_glossary_term' = 'Driver Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `underwriting_party_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewed By Underwriter ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `accident_count` SET TAGS ('dbx_business_glossary_term' = 'Accident Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `at_fault_accident_count` SET TAGS ('dbx_business_glossary_term' = 'At-Fault Accident Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Cost Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|AUD');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `decline_reason` SET TAGS ('dbx_business_glossary_term' = 'Decline Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `decline_recommended_flag` SET TAGS ('dbx_business_glossary_term' = 'Decline Recommended Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_class` SET TAGS ('dbx_business_glossary_term' = 'Driver License Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_class` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_class` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Driver License Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_expiration_date` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_expiration_date` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_issue_date` SET TAGS ('dbx_business_glossary_term' = 'Driver License Issue Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_issue_date` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_issue_date` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_number` SET TAGS ('dbx_business_glossary_term' = 'Driver License Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_state` SET TAGS ('dbx_business_glossary_term' = 'Driver License State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_state` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_state` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_status` SET TAGS ('dbx_business_glossary_term' = 'Driver License Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_status` SET TAGS ('dbx_value_regex' = 'valid|suspended|revoked|expired|restricted|cancelled');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_status` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `driver_license_status` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `dui_dwi_count` SET TAGS ('dbx_business_glossary_term' = 'Driving Under the Influence (DUI) / Driving While Intoxicated (DWI) Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `major_violation_count` SET TAGS ('dbx_business_glossary_term' = 'Major Violation Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `minor_violation_count` SET TAGS ('dbx_business_glossary_term' = 'Minor Violation Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `most_recent_accident_date` SET TAGS ('dbx_business_glossary_term' = 'Most Recent Accident Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `most_recent_violation_date` SET TAGS ('dbx_business_glossary_term' = 'Most Recent Violation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `mvr_score` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `mvr_tier` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `mvr_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|substandard|declined');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `referral_reason` SET TAGS ('dbx_business_glossary_term' = 'Referral Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `referral_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Referral Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `report_document_url` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Report Document URL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `report_order_date` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Report Order Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `report_order_number` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Report Order Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `report_received_date` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Report Received Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `report_status` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Report Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `report_status` SET TAGS ('dbx_value_regex' = 'ordered|received|reviewed|error|cancelled');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `review_period_years` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Review Period Years');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `reviewed_date` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Reviewed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `surcharge_amount` SET TAGS ('dbx_business_glossary_term' = 'Surcharge Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `surcharge_percentage` SET TAGS ('dbx_business_glossary_term' = 'Surcharge Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `suspension_count` SET TAGS ('dbx_business_glossary_term' = 'License Suspension Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `uw_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Impact Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `vendor_name` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Vendor Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `vendor_name` SET TAGS ('dbx_value_regex' = 'LexisNexis|Verisk|ISO|TransUnion|Experian|Other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `vendor_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `vendor_report_number` SET TAGS ('dbx_business_glossary_term' = 'Vendor Motor Vehicle Record (MVR) Report ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ALTER COLUMN `violation_count` SET TAGS ('dbx_business_glossary_term' = 'Violation Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `inspection_order_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Order Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `driver_id` SET TAGS ('dbx_business_glossary_term' = 'Driver Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `inspection_insured_party_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `inspection_party_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `location_id` SET TAGS ('dbx_business_glossary_term' = 'Location Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `ordering_agency_id` SET TAGS ('dbx_business_glossary_term' = 'Ordering Agency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Ordering Producer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `term_id` SET TAGS ('dbx_business_glossary_term' = 'Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Inspection Order Cancellation Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `completed_date` SET TAGS ('dbx_business_glossary_term' = 'Inspection Completed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `construction_type` SET TAGS ('dbx_business_glossary_term' = 'Construction Type (COPE)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Inspection Cost Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Inspection Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `exposure_description` SET TAGS ('dbx_business_glossary_term' = 'Exposure Description (COPE)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `inspection_findings` SET TAGS ('dbx_business_glossary_term' = 'Inspection Findings Summary');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `mvr_accident_count` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Accident Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `mvr_license_number` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) License Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `mvr_license_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `mvr_license_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `mvr_license_status` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) License Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `mvr_license_status` SET TAGS ('dbx_value_regex' = 'valid|suspended|revoked|expired|restricted');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `mvr_state` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `mvr_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `mvr_violation_count` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Violation Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Inspection Order Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `occupancy_type` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Type (COPE)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `order_date` SET TAGS ('dbx_business_glossary_term' = 'Inspection Order Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `order_number` SET TAGS ('dbx_business_glossary_term' = 'Inspection Order Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `order_status` SET TAGS ('dbx_business_glossary_term' = 'Inspection Order Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `order_type` SET TAGS ('dbx_business_glossary_term' = 'Inspection Order Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `pass_fail_indicator` SET TAGS ('dbx_business_glossary_term' = 'Inspection Pass or Fail Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `pass_fail_indicator` SET TAGS ('dbx_value_regex' = 'pass|fail|conditional');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `property_condition` SET TAGS ('dbx_business_glossary_term' = 'Property Condition Rating');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `property_condition` SET TAGS ('dbx_value_regex' = 'excellent|good|fair|poor|unacceptable');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `protection_class` SET TAGS ('dbx_business_glossary_term' = 'Protection Class (COPE)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `received_date` SET TAGS ('dbx_business_glossary_term' = 'Inspection Report Received Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `referral_reason` SET TAGS ('dbx_business_glossary_term' = 'Referral Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `referral_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Referral Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `report_document_url` SET TAGS ('dbx_business_glossary_term' = 'Inspection Report Document Uniform Resource Locator (URL)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `report_format` SET TAGS ('dbx_business_glossary_term' = 'Inspection Report Format');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `report_format` SET TAGS ('dbx_value_regex' = 'pdf|xml|json|acord_xml|proprietary');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Inspection Risk Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `roof_age_years` SET TAGS ('dbx_business_glossary_term' = 'Roof Age in Years');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `roof_age_years` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `roof_condition` SET TAGS ('dbx_business_glossary_term' = 'Roof Condition Rating');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `roof_condition` SET TAGS ('dbx_value_regex' = 'excellent|good|fair|poor|needs_replacement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `scheduled_date` SET TAGS ('dbx_business_glossary_term' = 'Inspection Scheduled Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `vendor_code` SET TAGS ('dbx_business_glossary_term' = 'Inspection Vendor Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `vendor_name` SET TAGS ('dbx_business_glossary_term' = 'Inspection Vendor Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `vendor_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ALTER COLUMN `vendor_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Vendor Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `clearance_check_id` SET TAGS ('dbx_business_glossary_term' = 'Clearance Check Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `clearance_override_user_party_id` SET TAGS ('dbx_business_glossary_term' = 'Override User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `clearance_party_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `primary_risk_appetite_rule_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Risk Appetite Rule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `appetite_tier` SET TAGS ('dbx_business_glossary_term' = 'Risk Appetite Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `appetite_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|substandard|declined');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `check_duration_seconds` SET TAGS ('dbx_business_glossary_term' = 'Check Duration in Seconds');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `check_number` SET TAGS ('dbx_business_glossary_term' = 'Check Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `check_status` SET TAGS ('dbx_business_glossary_term' = 'Check Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `check_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|failed|cancelled');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `check_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Check Execution Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `check_type` SET TAGS ('dbx_business_glossary_term' = 'Check Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `check_type` SET TAGS ('dbx_value_regex' = 'clearance|eligibility|combined|duplicate|risk_appetite');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `clearance_result` SET TAGS ('dbx_business_glossary_term' = 'Clearance Result');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `clearance_result` SET TAGS ('dbx_value_regex' = 'pass|fail|refer|override');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `decision_code` SET TAGS ('dbx_business_glossary_term' = 'Decision Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `decision_reason` SET TAGS ('dbx_business_glossary_term' = 'Decision Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `duplicate_detected_flag` SET TAGS ('dbx_business_glossary_term' = 'Duplicate Detected Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `duplicate_match_score` SET TAGS ('dbx_business_glossary_term' = 'Duplicate Match Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `duplicate_policy_numbers` SET TAGS ('dbx_business_glossary_term' = 'Duplicate Policy Numbers');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `duplicate_submission_ids` SET TAGS ('dbx_business_glossary_term' = 'Duplicate Submission Identifiers (IDs)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `eligibility_result` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Result');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `eligibility_result` SET TAGS ('dbx_value_regex' = 'eligible|ineligible|refer|conditional');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `fail_flag` SET TAGS ('dbx_business_glossary_term' = 'Fail Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `failed_rule_ids` SET TAGS ('dbx_business_glossary_term' = 'Failed Rule Identifiers (IDs)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `override_flag` SET TAGS ('dbx_business_glossary_term' = 'Override Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `override_reason` SET TAGS ('dbx_business_glossary_term' = 'Override Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `override_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Override Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `pass_flag` SET TAGS ('dbx_business_glossary_term' = 'Pass Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `product_code` SET TAGS ('dbx_business_glossary_term' = 'Product Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `referral_reason` SET TAGS ('dbx_business_glossary_term' = 'Referral Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `risk_score_band` SET TAGS ('dbx_business_glossary_term' = 'Risk Score Band');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `rule_set_name` SET TAGS ('dbx_business_glossary_term' = 'Rule Set Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `rule_set_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `rule_set_version` SET TAGS ('dbx_business_glossary_term' = 'Rule Set Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ALTER COLUMN `triggered_rule_ids` SET TAGS ('dbx_business_glossary_term' = 'Triggered Rule Identifiers (IDs)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `submission_document_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Document Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `inspection_order_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Order Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Submitting Producer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `riskexposure_insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `submission_received_from_party_id` SET TAGS ('dbx_business_glossary_term' = 'Received From Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `submission_uploaded_by_party_id` SET TAGS ('dbx_business_glossary_term' = 'Uploaded By Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `submitting_agency_id` SET TAGS ('dbx_business_glossary_term' = 'Submitting Agency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `archive_date` SET TAGS ('dbx_business_glossary_term' = 'Archive Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `checksum` SET TAGS ('dbx_business_glossary_term' = 'Document Checksum');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `confidential_flag` SET TAGS ('dbx_business_glossary_term' = 'Confidential Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `submission_document_description` SET TAGS ('dbx_business_glossary_term' = 'Document Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `document_category` SET TAGS ('dbx_business_glossary_term' = 'Document Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `document_category` SET TAGS ('dbx_value_regex' = 'application|supporting|financial|risk_assessment|regulatory|correspondence');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `document_date` SET TAGS ('dbx_business_glossary_term' = 'Document Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `document_format` SET TAGS ('dbx_business_glossary_term' = 'Document Format');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `document_name` SET TAGS ('dbx_business_glossary_term' = 'Document Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `document_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `document_number` SET TAGS ('dbx_business_glossary_term' = 'Document Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `document_source` SET TAGS ('dbx_business_glossary_term' = 'Document Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `document_source` SET TAGS ('dbx_value_regex' = 'applicant|producer|underwriter|third_party|system_generated|external_vendor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'Document Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `document_status` SET TAGS ('dbx_value_regex' = 'pending_review|under_review|approved|rejected|incomplete|archived');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `document_type` SET TAGS ('dbx_business_glossary_term' = 'Document Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `external_reference_number` SET TAGS ('dbx_business_glossary_term' = 'External Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `extracted_text` SET TAGS ('dbx_business_glossary_term' = 'Extracted Text');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `file_path` SET TAGS ('dbx_business_glossary_term' = 'File Storage Path');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `file_path` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `file_size_bytes` SET TAGS ('dbx_business_glossary_term' = 'File Size in Bytes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `mandatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `ocr_confidence_score` SET TAGS ('dbx_business_glossary_term' = 'Optical Character Recognition (OCR) Confidence Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `ocr_processed_flag` SET TAGS ('dbx_business_glossary_term' = 'Optical Character Recognition (OCR) Processed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `page_count` SET TAGS ('dbx_business_glossary_term' = 'Page Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `purge_eligible_date` SET TAGS ('dbx_business_glossary_term' = 'Purge Eligible Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `retention_period_years` SET TAGS ('dbx_business_glossary_term' = 'Retention Period in Years');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'Review Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `review_notes` SET TAGS ('dbx_business_glossary_term' = 'Review Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `review_status` SET TAGS ('dbx_business_glossary_term' = 'Review Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `review_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed|deferred|waived');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `review_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Review Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `reviewed_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Reviewed By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `reviewed_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `reviewed_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `upload_date` SET TAGS ('dbx_business_glossary_term' = 'Upload Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `upload_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Upload Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `uploaded_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Uploaded By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `uploaded_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `uploaded_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `vendor_name` SET TAGS ('dbx_business_glossary_term' = 'Vendor Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `vendor_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `bind_request_id` SET TAGS ('dbx_business_glossary_term' = 'Bind Request Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `bind_applicant_party_id` SET TAGS ('dbx_business_glossary_term' = 'Applicant Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `bind_party_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `binder_id` SET TAGS ('dbx_business_glossary_term' = 'Binder Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `bound_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Bound Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `uw_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Uw Decision Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `automated_bind_flag` SET TAGS ('dbx_business_glossary_term' = 'Automated Bind Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `bind_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Bind Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `bind_approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Bind Approval Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `bind_authority_level` SET TAGS ('dbx_business_glossary_term' = 'Bind Authority Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `bind_authority_level` SET TAGS ('dbx_value_regex' = 'automated|agent|underwriter|senior_underwriter|manager|executive');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `bind_conditions_met_flag` SET TAGS ('dbx_business_glossary_term' = 'Bind Conditions Met Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `bind_conditions_required` SET TAGS ('dbx_business_glossary_term' = 'Bind Conditions Required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `bind_rejection_date` SET TAGS ('dbx_business_glossary_term' = 'Bind Rejection Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `bind_rejection_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Bind Rejection Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `bind_rejection_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Bind Rejection Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `bind_request_date` SET TAGS ('dbx_business_glossary_term' = 'Bind Request Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `bind_request_status` SET TAGS ('dbx_business_glossary_term' = 'Bind Request Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `bind_request_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|withdrawn|expired|bound');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `certificate_of_insurance_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Certificate of Insurance (COI) Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `down_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Down Payment Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `down_payment_received_date` SET TAGS ('dbx_business_glossary_term' = 'Down Payment Received Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `down_payment_received_flag` SET TAGS ('dbx_business_glossary_term' = 'Down Payment Received Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `inspection_completed_date` SET TAGS ('dbx_business_glossary_term' = 'Inspection Completed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `inspection_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Inspection Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `mortgagee_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Mortgagee Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Bind Request Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Bind Request Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `payment_plan_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `policy_type_code` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `prior_carrier_cancellation_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Prior Carrier Cancellation Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `requested_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Requested Policy Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `requested_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Requested Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `sla_actual_hours` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Actual Hours');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `sla_met_flag` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Met Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `sla_target_hours` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Target Hours');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `timestamp` SET TAGS ('dbx_business_glossary_term' = 'Bind Request Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `total_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `binder_id` SET TAGS ('dbx_business_glossary_term' = 'Binder Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `binder_insured_party_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `binder_party_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `term_id` SET TAGS ('dbx_business_glossary_term' = 'Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `uw_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Uw Decision Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `bind_date` SET TAGS ('dbx_business_glossary_term' = 'Bind Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `binder_status` SET TAGS ('dbx_business_glossary_term' = 'Binder Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `binder_status` SET TAGS ('dbx_value_regex' = 'active|expired|cancelled|replaced|issued');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `binding_authority_type` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `binding_authority_type` SET TAGS ('dbx_value_regex' = 'underwriter|producer|mga|agency');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `coverage_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Coverage Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Created By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `document_url` SET TAGS ('dbx_business_glossary_term' = 'Binder Document Uniform Resource Locator (URL)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `down_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Down Payment Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `issuing_company_code` SET TAGS ('dbx_business_glossary_term' = 'Issuing Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `issuing_state` SET TAGS ('dbx_business_glossary_term' = 'Issuing State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `issuing_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Modified By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Binder Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `payment_plan_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `policy_issued_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Issued Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `policy_type_code` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Binder Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `replaced_by_policy_flag` SET TAGS ('dbx_business_glossary_term' = 'Replaced by Policy Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `risk_state` SET TAGS ('dbx_business_glossary_term' = 'Risk State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `risk_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `special_conditions` SET TAGS ('dbx_business_glossary_term' = 'Special Conditions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `term_days` SET TAGS ('dbx_business_glossary_term' = 'Term Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ALTER COLUMN `total_insured_value` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `submission_status_history_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Status History ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `bind_request_id` SET TAGS ('dbx_business_glossary_term' = 'Bind Request Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `changed_by_party_id` SET TAGS ('dbx_business_glossary_term' = 'Changed By Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter (UW) ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `referred_to_underwriter_party_id` SET TAGS ('dbx_business_glossary_term' = 'Referred To Underwriter (UW) ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `coverage_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `uw_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Uw Decision Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `uw_referral_id` SET TAGS ('dbx_business_glossary_term' = 'Uw Referral Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `changed_by_role` SET TAGS ('dbx_business_glossary_term' = 'Changed By Role');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `changed_by_user_name` SET TAGS ('dbx_business_glossary_term' = 'Changed By User Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `changed_by_user_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `changed_by_user_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `duration_hours` SET TAGS ('dbx_business_glossary_term' = 'Duration Hours');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `is_current_status` SET TAGS ('dbx_business_glossary_term' = 'Is Current Status Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `previous_status_code` SET TAGS ('dbx_business_glossary_term' = 'Previous Status Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `referral_reason` SET TAGS ('dbx_business_glossary_term' = 'Referral Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `sla_breach_hours` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Breach Hours');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `sla_met_flag` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Met Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `sla_target_hours` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Target Hours');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `status_category` SET TAGS ('dbx_business_glossary_term' = 'Status Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `status_category` SET TAGS ('dbx_value_regex' = 'INTAKE|UNDERWRITING|DECISION|TERMINAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `status_code` SET TAGS ('dbx_business_glossary_term' = 'Status Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `status_effective_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Status Effective Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `status_end_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Status End Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `status_name` SET TAGS ('dbx_business_glossary_term' = 'Status Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `status_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `status_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Status Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `system_source` SET TAGS ('dbx_business_glossary_term' = 'System Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `transition_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Transition Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `transition_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Transition Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `transition_type` SET TAGS ('dbx_business_glossary_term' = 'Transition Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `transition_type` SET TAGS ('dbx_value_regex' = 'AUTOMATIC|MANUAL|SYSTEM_TRIGGERED|USER_INITIATED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_business_glossary_term' = 'Underwriter (UW) Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ALTER COLUMN `workflow_stage` SET TAGS ('dbx_business_glossary_term' = 'Workflow Stage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `coverage_type_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Currency Code (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `exposure_unit_of_measure_id` SET TAGS ('dbx_business_glossary_term' = 'Exposure Unit Of Measure Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `fac_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Fac Agreement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `part_id` SET TAGS ('dbx_business_glossary_term' = 'Part Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `prior_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `reinsurance_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `aggregate_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `basis` SET TAGS ('dbx_business_glossary_term' = 'Coverage Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `basis` SET TAGS ('dbx_value_regex' = 'occurrence|claims_made|claims_made_and_reported');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Cancellation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `ceded_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ceded Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `coverage_status` SET TAGS ('dbx_business_glossary_term' = 'Coverage Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `coverage_status` SET TAGS ('dbx_value_regex' = 'active|suspended|cancelled|expired|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Coverage Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `deductible_type` SET TAGS ('dbx_business_glossary_term' = 'Deductible Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `deductible_type` SET TAGS ('dbx_value_regex' = 'flat|percentage|franchise|disappearing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `coverage_description` SET TAGS ('dbx_business_glossary_term' = 'Coverage Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `exposure_units` SET TAGS ('dbx_business_glossary_term' = 'Exposure Units');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `form_edition_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Edition Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `form_number` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `is_mandatory_coverage` SET TAGS ('dbx_business_glossary_term' = 'Is Mandatory Coverage Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `is_optional_coverage` SET TAGS ('dbx_business_glossary_term' = 'Is Optional Coverage Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `is_primary_coverage` SET TAGS ('dbx_business_glossary_term' = 'Is Primary Coverage Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `iso_coverage_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Coverage Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Coverage Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `naic_line_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Line Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Coverage Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `per_occurrence_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Per Occurrence Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Coverage Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `rate` SET TAGS ('dbx_business_glossary_term' = 'Coverage Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `rating_basis` SET TAGS ('dbx_business_glossary_term' = 'Rating Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `sub_coverage_code` SET TAGS ('dbx_business_glossary_term' = 'Sub-Coverage Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `territory` SET TAGS ('dbx_business_glossary_term' = 'Coverage Territory');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|non_standard|high_risk');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'actual_cash_value|replacement_cost|agreed_value|stated_amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Coverage Version Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `limit_id` SET TAGS ('dbx_business_glossary_term' = 'Limit Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `shared_limit_group_id` SET TAGS ('dbx_business_glossary_term' = 'Shared Limit Group Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `aggregate_limit_period` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `aggregate_limit_period` SET TAGS ('dbx_value_regex' = 'policy_period|calendar_year|accident_year|rolling_12_months');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `applies_to_coverage_part` SET TAGS ('dbx_business_glossary_term' = 'Limit Applies to Coverage Part');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `applies_to_peril` SET TAGS ('dbx_business_glossary_term' = 'Limit Applies to Peril');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Limit Attachment Point');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `basis` SET TAGS ('dbx_business_glossary_term' = 'Limit Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `limit_code` SET TAGS ('dbx_business_glossary_term' = 'Limit Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Limit Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `limit_description` SET TAGS ('dbx_business_glossary_term' = 'Limit Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Limit Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `erosion_method` SET TAGS ('dbx_business_glossary_term' = 'Limit Erosion Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `erosion_method` SET TAGS ('dbx_value_regex' = 'per_claim|per_payment|aggregate_depletion');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `exhausted_date` SET TAGS ('dbx_business_glossary_term' = 'Limit Exhausted Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Limit Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `is_combined_single_limit` SET TAGS ('dbx_business_glossary_term' = 'Is Combined Single Limit (CSL)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `is_shared_limit` SET TAGS ('dbx_business_glossary_term' = 'Is Shared Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `is_stacked` SET TAGS ('dbx_business_glossary_term' = 'Is Stacked Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `iso_limit_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Limit Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `limit_status` SET TAGS ('dbx_business_glossary_term' = 'Limit Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `limit_status` SET TAGS ('dbx_value_regex' = 'active|suspended|exhausted|cancelled|expired');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `limit_type` SET TAGS ('dbx_business_glossary_term' = 'Limit Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Limit Record Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `naic_limit_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Limit Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `reinstatement_premium_rate` SET TAGS ('dbx_business_glossary_term' = 'Limit Reinstatement Premium Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `reinstatement_provision` SET TAGS ('dbx_business_glossary_term' = 'Limit Reinstatement Provision');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `reinstatement_provision` SET TAGS ('dbx_value_regex' = 'automatic|manual|none');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `remaining_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Remaining Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'Limit Scope');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `scope` SET TAGS ('dbx_value_regex' = 'primary|excess|umbrella|sublimit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `sequence` SET TAGS ('dbx_business_glossary_term' = 'Limit Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Limit Source System Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `split_limit_bodily_injury_per_accident` SET TAGS ('dbx_business_glossary_term' = 'Split Limit Bodily Injury (BI) Per Accident');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `split_limit_bodily_injury_per_person` SET TAGS ('dbx_business_glossary_term' = 'Split Limit Bodily Injury (BI) Per Person');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `split_limit_property_damage_per_accident` SET TAGS ('dbx_business_glossary_term' = 'Split Limit Property Damage (PD) Per Accident');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `deductible_id` SET TAGS ('dbx_business_glossary_term' = 'Deductible Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `acord_code` SET TAGS ('dbx_business_glossary_term' = 'Association for Cooperative Operations Research and Development (ACORD) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `aggregate_limit` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `application_method` SET TAGS ('dbx_business_glossary_term' = 'Application Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `application_method` SET TAGS ('dbx_value_regex' = 'before_coverage|after_coverage|split');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `applies_to_coverage_part` SET TAGS ('dbx_business_glossary_term' = 'Applies to Coverage Part');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `applies_to_lae_flag` SET TAGS ('dbx_business_glossary_term' = 'Applies to Loss Adjustment Expense (LAE) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `applies_to_peril` SET TAGS ('dbx_business_glossary_term' = 'Applies to Peril');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `applies_to_salvage_flag` SET TAGS ('dbx_business_glossary_term' = 'Applies to Salvage Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `applies_to_subrogation_flag` SET TAGS ('dbx_business_glossary_term' = 'Applies to Subrogation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `basis` SET TAGS ('dbx_business_glossary_term' = 'Deductible Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `basis` SET TAGS ('dbx_value_regex' = 'per_occurrence|per_claim|per_policy|per_location|per_item|aggregate_annual');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `deductible_type` SET TAGS ('dbx_business_glossary_term' = 'Deductible Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `deductible_type` SET TAGS ('dbx_value_regex' = 'flat|percentage|sir|disappearing|franchise|aggregate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `deductible_description` SET TAGS ('dbx_business_glossary_term' = 'Deductible Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `disappearing_threshold` SET TAGS ('dbx_business_glossary_term' = 'Disappearing Threshold');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `iso_form_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Form Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `maximum_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `minimum_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `naic_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `percentage` SET TAGS ('dbx_business_glossary_term' = 'Deductible Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `transaction_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Transaction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'new_business|renewal|endorsement|cancellation|reinstatement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_business_glossary_term' = 'Waiting Period Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `waiver_authority` SET TAGS ('dbx_business_glossary_term' = 'Waiver Authority');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `waiver_date` SET TAGS ('dbx_business_glossary_term' = 'Waiver Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `waiver_flag` SET TAGS ('dbx_business_glossary_term' = 'Waiver Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `exclusion_id` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `specific_insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Specific Insured Risk Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `superseded_by_exclusion_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Exclusion Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `applies_to_all_insured_risks` SET TAGS ('dbx_business_glossary_term' = 'Applies to All Insured Risks Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `applies_to_first_party` SET TAGS ('dbx_business_glossary_term' = 'Applies to First Party Coverage Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `applies_to_third_party` SET TAGS ('dbx_business_glossary_term' = 'Applies to Third Party Liability Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `buyback_endorsement_available` SET TAGS ('dbx_business_glossary_term' = 'Buyback Endorsement Available Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `buyback_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Buyback Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `exclusion_category` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `claims_made_trigger` SET TAGS ('dbx_business_glossary_term' = 'Claims Made Trigger Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `exclusion_code` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `exclusion_description` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `endorsement_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `exclusion_status` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `exclusion_status` SET TAGS ('dbx_value_regex' = 'active|inactive|superseded|deleted|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `exclusion_type` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `exclusion_type` SET TAGS ('dbx_value_regex' = 'ISO|manuscript|endorsement|statutory|regulatory|carrier_specific');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `iso_form_number` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `language_text` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Language Text');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `exclusion_name` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `exclusion_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `occurrence_trigger` SET TAGS ('dbx_business_glossary_term' = 'Occurrence Trigger Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `regulatory_mandate_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Mandate Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Scope');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `state_mandate_code` SET TAGS ('dbx_business_glossary_term' = 'State Mandate Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `state_mandate_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `waivable_flag` SET TAGS ('dbx_business_glossary_term' = 'Waivable Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `coverage_condition_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for condition');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `agreed_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Agreed Value Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `agreed_value_indicator` SET TAGS ('dbx_business_glossary_term' = 'Agreed Value Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `clause_text` SET TAGS ('dbx_business_glossary_term' = 'Clause Text');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `compliance_status_code` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `compliance_status_code` SET TAGS ('dbx_value_regex' = 'COMP|NCOMP|PEND|WAIV|UNKN');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `compliance_verification_date` SET TAGS ('dbx_business_glossary_term' = 'Compliance Verification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `compliance_verified_by` SET TAGS ('dbx_business_glossary_term' = 'Compliance Verified By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `coverage_condition_description` SET TAGS ('dbx_business_glossary_term' = 'Condition Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `inspection_frequency_code` SET TAGS ('dbx_business_glossary_term' = 'Inspection Frequency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `inspection_frequency_code` SET TAGS ('dbx_value_regex' = 'MONTH|QUAR|SEMI|ANN|ONDEM');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `iso_form_number` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `mandatory_indicator` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `margin_percentage` SET TAGS ('dbx_business_glossary_term' = 'Margin Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `coverage_condition_name` SET TAGS ('dbx_business_glossary_term' = 'Condition Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `coverage_condition_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `non_compliance_reason` SET TAGS ('dbx_business_glossary_term' = 'Non-Compliance Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `penalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Penalty Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `penalty_method_code` SET TAGS ('dbx_business_glossary_term' = 'Penalty Method Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `penalty_method_code` SET TAGS ('dbx_value_regex' = 'PROP|FLAT|NONE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `regulatory_requirement_indicator` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `reporting_deadline_days` SET TAGS ('dbx_business_glossary_term' = 'Reporting Deadline Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `reporting_frequency_code` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `reporting_frequency_code` SET TAGS ('dbx_value_regex' = 'MONTH|QUAR|SEMI|ANN');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Condition Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'PAS|UW|RATE|DOC');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `type_code` SET TAGS ('dbx_business_glossary_term' = 'Condition Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `type_code` SET TAGS ('dbx_value_regex' = 'COINS|AGRVAL|MARGIN|REPORT|INSP|WARR');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `waiver_granted_by` SET TAGS ('dbx_business_glossary_term' = 'Waiver Granted By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `waiver_granted_date` SET TAGS ('dbx_business_glossary_term' = 'Waiver Granted Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `waiver_granted_indicator` SET TAGS ('dbx_business_glossary_term' = 'Waiver Granted Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `warranty_description` SET TAGS ('dbx_business_glossary_term' = 'Warranty Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `warranty_type_code` SET TAGS ('dbx_business_glossary_term' = 'Warranty Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ALTER COLUMN `warranty_type_code` SET TAGS ('dbx_value_regex' = 'PROM|AFFIRM|COND');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for form');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `coverage_type_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `acord_form_code` SET TAGS ('dbx_business_glossary_term' = 'Association for Cooperative Operations Research and Development (ACORD) Form Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Attachment Point');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `attachment_point` SET TAGS ('dbx_value_regex' = 'policy|coverage|insured_risk');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `coverage_form_category` SET TAGS ('dbx_business_glossary_term' = 'Form Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `coverage_form_category` SET TAGS ('dbx_value_regex' = 'coverage_extension|coverage_restriction|additional_insured|waiver_of_subrogation|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `coverage_form_status` SET TAGS ('dbx_business_glossary_term' = 'Form Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `coverage_form_status` SET TAGS ('dbx_value_regex' = 'active|inactive|withdrawn|obsolete');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `coverage_form_type` SET TAGS ('dbx_business_glossary_term' = 'Form Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `coverage_form_description` SET TAGS ('dbx_business_glossary_term' = 'Form Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `document_uri` SET TAGS ('dbx_business_glossary_term' = 'Document Uniform Resource Identifier (URI)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `edition_date` SET TAGS ('dbx_business_glossary_term' = 'Form Edition Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `filing_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `filing_number` SET TAGS ('dbx_business_glossary_term' = 'Filing Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Filing Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `filing_status` SET TAGS ('dbx_value_regex' = 'approved|pending|withdrawn|rejected|not_required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `is_amendatory` SET TAGS ('dbx_business_glossary_term' = 'Is Amendatory Endorsement Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Is Mandatory Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `iso_form_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Form Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `language` SET TAGS ('dbx_business_glossary_term' = 'Form Language');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `language` SET TAGS ('dbx_value_regex' = 'english|spanish|french|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `coverage_form_name` SET TAGS ('dbx_business_glossary_term' = 'Form Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `coverage_form_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Form Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `premium_bearing_flag` SET TAGS ('dbx_business_glossary_term' = 'Premium Bearing Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `sequence` SET TAGS ('dbx_business_glossary_term' = 'Form Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `source` SET TAGS ('dbx_business_glossary_term' = 'Form Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `source` SET TAGS ('dbx_value_regex' = 'iso|acord|carrier_proprietary|manuscript|state_mandated');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `superseded_form_number` SET TAGS ('dbx_business_glossary_term' = 'Superseded Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Form Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `part_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `aggregate_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `audit_required_indicator` SET TAGS ('dbx_business_glossary_term' = 'Premium Audit Required Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Cancellation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_value_regex' = 'NON_PAY|UW_RISK|INSURED_REQ|FRAUD|MATERIAL_MISREP|OTHER');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `cat_exposure_indicator` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposure Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `claims_made_indicator` SET TAGS ('dbx_business_glossary_term' = 'Claims Made Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `commission_rate_percentage` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `deductible_type_code` SET TAGS ('dbx_business_glossary_term' = 'Deductible Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `deductible_type_code` SET TAGS ('dbx_value_regex' = 'PER_OCCURRENCE|PER_CLAIM|AGGREGATE|PERCENTAGE|FRANCHISE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `part_description` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `endorsement_count` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_business_glossary_term' = 'Extended Reporting Period (ERP) Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `iso_form_edition_date` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Form Edition Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `iso_form_number` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `minimum_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `part_name` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `part_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `package_indicator` SET TAGS ('dbx_business_glossary_term' = 'Package Policy Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `package_type_code` SET TAGS ('dbx_business_glossary_term' = 'Package Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `package_type_code` SET TAGS ('dbx_value_regex' = 'CPP|BOP|PAP|HO|STANDALONE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `part_status` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `part_status` SET TAGS ('dbx_value_regex' = 'active|cancelled|expired|suspended|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `per_occurrence_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Per Occurrence Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `premium_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Premium Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `premium_currency_code` SET TAGS ('dbx_value_regex' = 'USD');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `rate_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Rate Per Unit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `rating_basis_code` SET TAGS ('dbx_business_glossary_term' = 'Rating Basis Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `rating_basis_unit` SET TAGS ('dbx_business_glossary_term' = 'Rating Basis Unit of Measure');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `rating_basis_value` SET TAGS ('dbx_business_glossary_term' = 'Rating Basis Value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `reinsurance_treaty_indicator` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `retroactive_date` SET TAGS ('dbx_business_glossary_term' = 'Retroactive Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `sequence` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Rating Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `type_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Part Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `valuation_method_code` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `valuation_method_code` SET TAGS ('dbx_value_regex' = 'ACV|RC|STATED|AGREED|MARKET');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ALTER COLUMN `written_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Written Premium (WP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `coverage_endorsement_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for endorsement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `coverage_form_id` SET TAGS ('dbx_business_glossary_term' = 'Form Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `coverage_party_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Underwriter Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `coverage_requested_by_party_id` SET TAGS ('dbx_business_glossary_term' = 'Requested By Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `policy_document_id` SET TAGS ('dbx_business_glossary_term' = 'Document Reference Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `premium_impact_currency_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Impact Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `superseded_by_endorsement_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Endorsement Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Approved Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_value_regex' = 'insured_request|underwriting_decision|non_payment|policy_cancelled|error_correction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `deductible_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Change Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `coverage_endorsement_description` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `issued_date` SET TAGS ('dbx_business_glossary_term' = 'Issued Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `limit_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Limit Change Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `mandatory_indicator` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `premium_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Impact Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `reason_code` SET TAGS ('dbx_value_regex' = 'insured_request|underwriting_requirement|regulatory_mandate|rate_change|exposure_change|correction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `reason_description` SET TAGS ('dbx_business_glossary_term' = 'Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `regulatory_authority_code` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `regulatory_requirement_indicator` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `requested_date` SET TAGS ('dbx_business_glossary_term' = 'Requested Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `status_code` SET TAGS ('dbx_business_glossary_term' = 'Status Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `status_code` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|approved|issued|cancelled|superseded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Title');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `type_code` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ALTER COLUMN `type_code` SET TAGS ('dbx_value_regex' = 'coverage_change|limit_change|deductible_change|exclusion_add|exclusion_remove|condition_add');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `additional_interest_id` SET TAGS ('dbx_business_glossary_term' = 'Additional Interest ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `address_line_1` SET TAGS ('dbx_business_glossary_term' = 'Address Line 1');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `address_line_1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `address_line_1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `address_line_2` SET TAGS ('dbx_business_glossary_term' = 'Address Line 2');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `address_line_2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `address_line_2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `blanket_description` SET TAGS ('dbx_business_glossary_term' = 'Blanket Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `blanket_indicator` SET TAGS ('dbx_business_glossary_term' = 'Blanket Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `cancellation_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Notice Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `certificate_holder_indicator` SET TAGS ('dbx_business_glossary_term' = 'Certificate Holder Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `certificate_issue_date` SET TAGS ('dbx_business_glossary_term' = 'Certificate Issue Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Certificate Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'City');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `contract_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Contract Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = 'USA|CAN|MEX');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `interest_description` SET TAGS ('dbx_business_glossary_term' = 'Interest Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `interest_name` SET TAGS ('dbx_business_glossary_term' = 'Interest Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `interest_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `interest_type_code` SET TAGS ('dbx_business_glossary_term' = 'Interest Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `interest_type_code` SET TAGS ('dbx_value_regex' = 'AI|ALI|LP|MORT|LH|COI');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `iso_form_number` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `loan_amount` SET TAGS ('dbx_business_glossary_term' = 'Loan Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `loan_number` SET TAGS ('dbx_business_glossary_term' = 'Loan Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `primary_indicator` SET TAGS ('dbx_business_glossary_term' = 'Primary Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `rank_order` SET TAGS ('dbx_business_glossary_term' = 'Rank Order');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `removal_date` SET TAGS ('dbx_business_glossary_term' = 'Removal Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `removal_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Removal Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `removal_reason_code` SET TAGS ('dbx_value_regex' = 'loan_paid|contract_end|request|error');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `state_province_code` SET TAGS ('dbx_business_glossary_term' = 'State or Province Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `state_province_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `status_code` SET TAGS ('dbx_business_glossary_term' = 'Status Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `status_code` SET TAGS ('dbx_value_regex' = 'active|expired|cancelled|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ALTER COLUMN `waiver_of_subrogation_indicator` SET TAGS ('dbx_business_glossary_term' = 'Waiver of Subrogation Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `rate_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `classification_code_id` SET TAGS ('dbx_business_glossary_term' = 'Classification Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `coverage_type_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Code (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `rating_basis_unit_of_measure_id` SET TAGS ('dbx_business_glossary_term' = 'Rating Basis Unit Of Measure Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `basis_code` SET TAGS ('dbx_business_glossary_term' = 'Rate Basis Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `rate_code` SET TAGS ('dbx_business_glossary_term' = 'Rate Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `coinsurance_factor` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `deductible_credit_factor` SET TAGS ('dbx_business_glossary_term' = 'Deductible Credit Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Rate Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `experience_modifier` SET TAGS ('dbx_business_glossary_term' = 'Experience Modifier (Mod)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Rate Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `factor` SET TAGS ('dbx_business_glossary_term' = 'Rate Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `filing_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Rate Filing Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `filing_number` SET TAGS ('dbx_business_glossary_term' = 'Rate Filing Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `filing_state_code` SET TAGS ('dbx_business_glossary_term' = 'Rate Filing State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `filing_state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `increased_limits_factor` SET TAGS ('dbx_business_glossary_term' = 'Increased Limits Factor (ILF)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `iso_form_number` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `minimum_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `override_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Rate Override Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `override_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Rate Override Approved By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `override_indicator` SET TAGS ('dbx_business_glossary_term' = 'Rate Override Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `override_reason` SET TAGS ('dbx_business_glossary_term' = 'Rate Override Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `rating_algorithm_code` SET TAGS ('dbx_business_glossary_term' = 'Rating Algorithm Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `rating_variable_name` SET TAGS ('dbx_business_glossary_term' = 'Rating Variable Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `rating_variable_name` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `rating_variable_value` SET TAGS ('dbx_business_glossary_term' = 'Rating Variable Value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `schedule_credit_debit_amount` SET TAGS ('dbx_business_glossary_term' = 'Schedule Credit or Debit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `schedule_credit_debit_percentage` SET TAGS ('dbx_business_glossary_term' = 'Schedule Credit or Debit Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Rate Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `table_name` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `table_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `table_version` SET TAGS ('dbx_business_glossary_term' = 'Rate Table Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `transaction_type_code` SET TAGS ('dbx_business_glossary_term' = 'Transaction Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `transaction_type_code` SET TAGS ('dbx_value_regex' = 'new_business|renewal|endorsement|cancellation|reinstatement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `type_code` SET TAGS ('dbx_business_glossary_term' = 'Rate Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `value` SET TAGS ('dbx_business_glossary_term' = 'Rate Value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `coverage_type_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `acord_coverage_code` SET TAGS ('dbx_business_glossary_term' = 'Association for Cooperative Operations Research and Development (ACORD) Coverage Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `acord_coverage_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,6}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `aggregate_limit_required_indicator` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit Required Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `catastrophe_eligible_indicator` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Eligible Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `claims_made_indicator` SET TAGS ('dbx_business_glossary_term' = 'Claims Made Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `coinsurance_allowed_indicator` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Allowed Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `coverage_category` SET TAGS ('dbx_business_glossary_term' = 'Coverage Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `coverage_category` SET TAGS ('dbx_value_regex' = 'PROPERTY|LIABILITY|AUTO_PHYSICAL_DAMAGE|BODILY_INJURY|MEDICAL_PAYMENTS|UNINSURED_MOTORIST');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `coverage_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `coverage_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `coverage_description` SET TAGS ('dbx_business_glossary_term' = 'Coverage Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `coverage_name` SET TAGS ('dbx_business_glossary_term' = 'Coverage Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `coverage_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `deductible_required_indicator` SET TAGS ('dbx_business_glossary_term' = 'Deductible Required Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `defense_cost_included_indicator` SET TAGS ('dbx_business_glossary_term' = 'Defense Cost Included Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `first_party_indicator` SET TAGS ('dbx_business_glossary_term' = 'First Party Coverage Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `iso_coverage_symbol` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Coverage Symbol');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `iso_coverage_symbol` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `iso_edition_date` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Edition Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `iso_form_number` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `iso_form_number` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}s[0-9]{2}s[0-9]{2}s[0-9]{2}s[0-9]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `mandatory_indicator` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Coverage Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `minimum_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `naic_coverage_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Coverage Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `naic_coverage_code` SET TAGS ('dbx_value_regex' = '^[0-9]{3,6}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `occurrence_basis_indicator` SET TAGS ('dbx_business_glossary_term' = 'Occurrence Basis Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `optional_indicator` SET TAGS ('dbx_business_glossary_term' = 'Optional Coverage Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `per_occurrence_limit_required_indicator` SET TAGS ('dbx_business_glossary_term' = 'Per Occurrence Limit Required Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `peril_type` SET TAGS ('dbx_business_glossary_term' = 'Peril Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `peril_type` SET TAGS ('dbx_value_regex' = 'NAMED_PERIL|OPEN_PERIL|SPECIFIED_PERIL|ALL_RISK');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `rate_type_code` SET TAGS ('dbx_business_glossary_term' = 'Rate Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `rate_type_code` SET TAGS ('dbx_value_regex' = 'PER_UNIT|PERCENTAGE|FLAT_FEE|TIERED|EXPERIENCE_RATED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `rating_basis_code` SET TAGS ('dbx_business_glossary_term' = 'Rating Basis Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `regulatory_approval_required_indicator` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Required Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `salvage_allowed_indicator` SET TAGS ('dbx_business_glossary_term' = 'Salvage Allowed Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `sort_order` SET TAGS ('dbx_business_glossary_term' = 'Sort Order');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `status_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Status Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `status_code` SET TAGS ('dbx_value_regex' = 'ACTIVE|INACTIVE|PENDING_APPROVAL|WITHDRAWN|SUPERSEDED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `sublimit_allowed_indicator` SET TAGS ('dbx_business_glossary_term' = 'Sublimit Allowed Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `subrogation_allowed_indicator` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Allowed Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `supplementary_payments_indicator` SET TAGS ('dbx_business_glossary_term' = 'Supplementary Payments Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `third_party_indicator` SET TAGS ('dbx_business_glossary_term' = 'Third Party Coverage Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `valuation_method_code` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ALTER COLUMN `valuation_method_code` SET TAGS ('dbx_value_regex' = 'ACV|REPLACEMENT_COST|AGREED_VALUE|STATED_AMOUNT|FUNCTIONAL_REPLACEMENT|MARKET_VALUE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `peril_link_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Peril Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `cat_indicator` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `cat_model_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Model Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coinsurance_applicable_indicator` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Applicable Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_status` SET TAGS ('dbx_business_glossary_term' = 'Peril Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_status` SET TAGS ('dbx_value_regex' = 'ACTIVE|INACTIVE|DEPRECATED|PENDING');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_trigger` SET TAGS ('dbx_business_glossary_term' = 'Coverage Trigger');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_trigger` SET TAGS ('dbx_value_regex' = 'OCCURRENCE|CLAIMS_MADE|LOSS_SUSTAINED|DISCOVERY');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `deductible_applicable_indicator` SET TAGS ('dbx_business_glossary_term' = 'Deductible Applicable Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `coverage_peril_description` SET TAGS ('dbx_business_glossary_term' = 'Peril Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `facultative_typical_indicator` SET TAGS ('dbx_business_glossary_term' = 'Facultative Typical Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `first_party_indicator` SET TAGS ('dbx_business_glossary_term' = 'First Party Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `group_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Group Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `iso_peril_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Peril Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `iso_peril_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,6}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `naic_peril_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Peril Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `naic_peril_code` SET TAGS ('dbx_value_regex' = '^[0-9]{3,5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `peril_category` SET TAGS ('dbx_business_glossary_term' = 'Peril Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `peril_category` SET TAGS ('dbx_value_regex' = 'PROPERTY|CASUALTY|LIABILITY|AUTO|WORKERS_COMP|SPECIALTY');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `peril_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `peril_name` SET TAGS ('dbx_business_glossary_term' = 'Peril Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `peril_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `pml_applicable_indicator` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Applicable Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `regulatory_reporting_required_indicator` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Required Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `reinsurance_treaty_eligible_indicator` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty Eligible Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `sort_order` SET TAGS ('dbx_business_glossary_term' = 'Sort Order');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `sublimit_typical_indicator` SET TAGS ('dbx_business_glossary_term' = 'Sublimit Typical Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_peril` ALTER COLUMN `third_party_indicator` SET TAGS ('dbx_business_glossary_term' = 'Third Party Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `peril_link_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Link Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `aggregate_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `aggregate_limit_applies` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit Applies Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `applies_to_first_party` SET TAGS ('dbx_business_glossary_term' = 'Applies to First Party Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `applies_to_third_party` SET TAGS ('dbx_business_glossary_term' = 'Applies to Third Party Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `buyback_available_indicator` SET TAGS ('dbx_business_glossary_term' = 'Buyback Available Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `buyback_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Buyback Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `cat_peril_indicator` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Peril Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `cat_zone_applicable` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone Applicable Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Peril Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `deductible_basis` SET TAGS ('dbx_business_glossary_term' = 'Deductible Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `deductible_basis` SET TAGS ('dbx_value_regex' = 'per_occurrence|per_claim|aggregate|per_location');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `deductible_currency` SET TAGS ('dbx_business_glossary_term' = 'Deductible Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `deductible_currency` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|AUD');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `deductible_percentage` SET TAGS ('dbx_business_glossary_term' = 'Deductible Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `deductible_type` SET TAGS ('dbx_business_glossary_term' = 'Deductible Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `deductible_type` SET TAGS ('dbx_value_regex' = 'flat|percentage|franchise|disappearing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `endorsement_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_business_glossary_term' = 'Extended Reporting Period (ERP) Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `inclusion_status` SET TAGS ('dbx_business_glossary_term' = 'Peril Inclusion Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `inclusion_status` SET TAGS ('dbx_value_regex' = 'included|excluded|conditionally_included|suspended');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `iso_form_number` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `naic_peril_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Peril Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `per_occurrence_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Per Occurrence Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `peril_description` SET TAGS ('dbx_business_glossary_term' = 'Peril Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `peril_link_status` SET TAGS ('dbx_business_glossary_term' = 'Coverage Peril Link Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `peril_link_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending|expired');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `peril_type_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `regulatory_mandate_indicator` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Mandate Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `retroactive_date` SET TAGS ('dbx_business_glossary_term' = 'Retroactive Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `state_mandate_code` SET TAGS ('dbx_business_glossary_term' = 'State Mandate Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `state_mandate_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `sublimit_amount` SET TAGS ('dbx_business_glossary_term' = 'Peril Sublimit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `sublimit_basis` SET TAGS ('dbx_business_glossary_term' = 'Sublimit Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `sublimit_basis` SET TAGS ('dbx_value_regex' = 'per_occurrence|per_claim|aggregate|per_location|per_person');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `sublimit_currency` SET TAGS ('dbx_business_glossary_term' = 'Sublimit Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `sublimit_currency` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|AUD');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `trigger_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Trigger Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `trigger_type` SET TAGS ('dbx_value_regex' = 'occurrence|claims_made|claims_made_and_reported');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_business_glossary_term' = 'Waiting Period Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` SET TAGS ('dbx_association_edges' = 'party.party_role,coverage.coverage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` ALTER COLUMN `coverage_interest_id` SET TAGS ('dbx_business_glossary_term' = 'coverage_interest Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Interest - Coverage Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` ALTER COLUMN `policy_interest_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Interest Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` ALTER COLUMN `role_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Interest - Role Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` ALTER COLUMN `certificate_required` SET TAGS ('dbx_business_glossary_term' = 'Certificate Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Interest Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Interest Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` ALTER COLUMN `is_primary_interest` SET TAGS ('dbx_business_glossary_term' = 'Primary Interest Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` ALTER COLUMN `percentage` SET TAGS ('dbx_business_glossary_term' = 'Interest Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` ALTER COLUMN `type_code` SET TAGS ('dbx_business_glossary_term' = 'Interest Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` ALTER COLUMN `waiver_of_subrogation` SET TAGS ('dbx_business_glossary_term' = 'Waiver of Subrogation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` SET TAGS ('dbx_association_edges' = 'coverage.coverage,reinsurance.treaty_layer');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` ALTER COLUMN `coverage_cession_id` SET TAGS ('dbx_business_glossary_term' = 'coverage_cession Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Cession - Coverage Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` ALTER COLUMN `treaty_layer_id` SET TAGS ('dbx_business_glossary_term' = 'Cession - Treaty Layer Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` ALTER COLUMN `attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Cession Attachment Point');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` ALTER COLUMN `ceded_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` ALTER COLUMN `cession_status` SET TAGS ('dbx_business_glossary_term' = 'Cession Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Cession Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Cession Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` ALTER COLUMN `layer_limit` SET TAGS ('dbx_business_glossary_term' = 'Cession Layer Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` ALTER COLUMN `percentage` SET TAGS ('dbx_business_glossary_term' = 'Cession Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Cedant Retention Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility` SET TAGS ('dbx_association_edges' = 'coverage.coverage_type,reinsurance.ri_agreement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility` ALTER COLUMN `eligibility_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Eligibility Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility` ALTER COLUMN `coverage_type_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Eligibility - Coverage Type Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Eligibility - Ri Agreement Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility` ALTER COLUMN `cession_priority` SET TAGS ('dbx_business_glossary_term' = 'Cession Priority');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility` ALTER COLUMN `default_cession_pct` SET TAGS ('dbx_business_glossary_term' = 'Default Cession Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility` ALTER COLUMN `eligible_indicator` SET TAGS ('dbx_business_glossary_term' = 'Eligible Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility` ALTER COLUMN `exclusion_reason` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility` ALTER COLUMN `reinsurance_treaty_eligible_indicator` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty Eligible Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`producer_coverage_authority` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`producer_coverage_authority` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`producer_coverage_authority` SET TAGS ('dbx_association_edges' = 'coverage.coverage_type,producers.producers_producer');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`producer_coverage_authority` ALTER COLUMN `producer_coverage_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Coverage Authority Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`producer_coverage_authority` ALTER COLUMN `coverage_type_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Coverage Authority - Coverage Type Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`producer_coverage_authority` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Coverage Authority - Producers Producer Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`producer_coverage_authority` ALTER COLUMN `authority_level` SET TAGS ('dbx_business_glossary_term' = 'Authority Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`producer_coverage_authority` ALTER COLUMN `binding_authority_flag` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`producer_coverage_authority` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Authority Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`producer_coverage_authority` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Authority Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`producer_coverage_authority` ALTER COLUMN `max_limit` SET TAGS ('dbx_business_glossary_term' = 'Maximum Binding Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`producer_coverage_authority` ALTER COLUMN `referral_threshold` SET TAGS ('dbx_business_glossary_term' = 'Referral Threshold Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` SET TAGS ('dbx_association_edges' = 'coverage.coverage_type,catastrophegeography.peril');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` ALTER COLUMN `type_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Peril Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Peril - Peril Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` ALTER COLUMN `primary_coverage_type_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` ALTER COLUMN `type_coverage_type_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Peril - Coverage Type Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` ALTER COLUMN `coverage_trigger` SET TAGS ('dbx_business_glossary_term' = 'Coverage Trigger');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` ALTER COLUMN `endorsement_required` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` ALTER COLUMN `is_standard_coverage` SET TAGS ('dbx_business_glossary_term' = 'Standard Coverage Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` ALTER COLUMN `sublimit_typical_indicator` SET TAGS ('dbx_business_glossary_term' = 'Sublimit Typical Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` ALTER COLUMN `typical_deductible_type` SET TAGS ('dbx_business_glossary_term' = 'Typical Deductible Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` SET TAGS ('dbx_association_edges' = 'underwriting.quote,reinsurance.reinsurer');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ALTER COLUMN `facultative_quotation_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative Quotation Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ALTER COLUMN `facultative_marketing_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative Marketing Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative Quotation - Quote Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative Quotation - Reinsurer Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ALTER COLUMN `acceptance_date` SET TAGS ('dbx_business_glossary_term' = 'Acceptance Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ALTER COLUMN `brokerage_percentage` SET TAGS ('dbx_business_glossary_term' = 'Brokerage Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ALTER COLUMN `commission_percentage` SET TAGS ('dbx_business_glossary_term' = 'Commission Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ALTER COLUMN `decline_reason` SET TAGS ('dbx_business_glossary_term' = 'Decline Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ALTER COLUMN `quote_date` SET TAGS ('dbx_business_glossary_term' = 'Quote Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ALTER COLUMN `quote_status` SET TAGS ('dbx_business_glossary_term' = 'Quote Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ALTER COLUMN `quoted_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Quoted Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ALTER COLUMN `quoted_share_percentage` SET TAGS ('dbx_business_glossary_term' = 'Quoted Share Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ALTER COLUMN `terms_and_conditions` SET TAGS ('dbx_business_glossary_term' = 'Terms and Conditions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_marketing` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_marketing` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_marketing` SET TAGS ('dbx_association_edges' = 'underwriting.submission,reinsurance.reinsurer');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_marketing` ALTER COLUMN `facultative_marketing_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative Marketing ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_marketing` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative Marketing - Reinsurer Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_marketing` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative Marketing - Submission Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_marketing` ALTER COLUMN `contact_date` SET TAGS ('dbx_business_glossary_term' = 'Contact Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_marketing` ALTER COLUMN `indicative_rate` SET TAGS ('dbx_business_glossary_term' = 'Indicative Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_marketing` ALTER COLUMN `indicative_terms_provided_flag` SET TAGS ('dbx_business_glossary_term' = 'Indicative Terms Provided Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_marketing` ALTER COLUMN `marketing_status` SET TAGS ('dbx_business_glossary_term' = 'Marketing Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_marketing` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Marketing Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_marketing` ALTER COLUMN `reinsurer_interest_level` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Interest Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_marketing` ALTER COLUMN `response_date` SET TAGS ('dbx_business_glossary_term' = 'Response Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` SET TAGS ('dbx_association_edges' = 'policy.policy_transaction,coverage.coverage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `coverage_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'coverage_transaction Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Transaction - Coverage Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Transaction - Policy Transaction Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `billing_transaction_id` SET TAGS ('dbx_ssot_reference' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `change_description` SET TAGS ('dbx_business_glossary_term' = 'Change Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `change_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Change Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `coverage_status` SET TAGS ('dbx_business_glossary_term' = 'Coverage Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `is_coverage_added_flag` SET TAGS ('dbx_business_glossary_term' = 'Coverage Added Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `is_coverage_removed_flag` SET TAGS ('dbx_business_glossary_term' = 'Coverage Removed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `limit_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Limit Change Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `new_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'New Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `new_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'New Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `premium_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Change Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `prior_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `prior_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `prorated_premium_factor` SET TAGS ('dbx_business_glossary_term' = 'Prorated Premium Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` SET TAGS ('dbx_association_edges' = 'policy.policy_form,coverage.coverage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` ALTER COLUMN `form_attachment_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Attachment Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Attachment - Coverage Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` ALTER COLUMN `policy_form_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Attachment - Policy Form Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` ALTER COLUMN `attachment_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Attachment Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` ALTER COLUMN `attachment_sequence` SET TAGS ('dbx_business_glossary_term' = 'Attachment Sequence');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Form Attachment Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Form Attachment Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` ALTER COLUMN `form_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Form Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` ALTER COLUMN `form_status` SET TAGS ('dbx_business_glossary_term' = 'Form Attachment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` ALTER COLUMN `mandatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Form Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` ALTER COLUMN `premium_bearing_flag` SET TAGS ('dbx_business_glossary_term' = 'Premium Bearing Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`shared_limit_group` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`shared_limit_group` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`shared_limit_group` ALTER COLUMN `shared_limit_group_id` SET TAGS ('dbx_business_glossary_term' = 'Shared Limit Group Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`shared_limit_group` ALTER COLUMN `group_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_rule_set` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_rule_set` SET TAGS ('dbx_subdomain' = 'policy_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_rule_set` ALTER COLUMN `rating_rule_set_id` SET TAGS ('dbx_business_glossary_term' = 'Rating Rule Set Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_rule_set` ALTER COLUMN `actuarial_basis` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_rule_set` ALTER COLUMN `calculation_formula` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_rule_set` ALTER COLUMN `catastrophe_load_percentage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_rule_set` ALTER COLUMN `credibility_factor` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_rule_set` ALTER COLUMN `expense_provision_percentage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_rule_set` ALTER COLUMN `loss_cost_multiplier` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_rule_set` ALTER COLUMN `loss_ratio_target` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_rule_set` ALTER COLUMN `profit_margin_percentage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_rule_set` ALTER COLUMN `rule_set_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_rule_set` ALTER COLUMN `trend_factor` SET TAGS ('dbx_confidential' = 'true');
