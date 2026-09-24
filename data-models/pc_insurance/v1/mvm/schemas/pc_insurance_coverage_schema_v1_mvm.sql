-- Schema for Domain: coverage | Business: Pc_Insurance | Version: v1_mvm
-- Generated on: 2026-09-20 21:40:51

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_blog_v499`.`coverage` COMMENT 'Bridge between the policy contract and the insured risk. Owns Coverage (one row per coverage per policy term) with attached Limit, Deductible, Exclusion, and Condition.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` (
    `submission_id` BIGINT COMMENT 'Unique identifier for the submission record. Primary key.',
    `agency_id` BIGINT COMMENT 'Foreign key to the agency or brokerage firm associated with this submission.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Underwriters evaluate catastrophe exposure during submission intake to determine risk appetite, pricing tier, and referral triggers.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Submissions capture risk location (risk_state, risk_country) which maps to geography hierarchy for territory rating, catastrophe zone assignment, and regulatory jurisdiction',
    `household_id` BIGINT COMMENT 'Foreign key linking to party.household. Business justification: Personal lines underwriting requires household-level risk assessment at submission: aggregate prior losses, household member count, and multi-policy exposure are evaluated before quoting.',
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
) COMMENT 'One row per submission (application for coverage). Entry point of the underwriting lifecycle. Captures applicant, producer, LOB, risk state, estimated premium, eligibility status, and links to bound policy when accepted.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` (
    `uw_decision_id` BIGINT COMMENT 'Unique identifier for the underwriting decision event. Grain: one row per UW decision event.',
    `primary_uw_approved_by_party_id` BIGINT COMMENT 'Reference to the party who provided final approval for the underwriting decision, if approval was required.',
    `quote_id` BIGINT COMMENT 'Reference to the quote being evaluated or modified by this underwriting decision, if applicable.',
    `submission_id` BIGINT COMMENT 'Reference to the submission being evaluated by this underwriting decision.',
    `tertiary_uw_referred_to_underwriter_party_id` BIGINT COMMENT 'Reference to the senior underwriter or specialist to whom the submission was escalated.',
    `uw_referral_id` BIGINT COMMENT 'Foreign key linking to coverage.uw_referral. Business justification: UW decision can result from a referral being resolved. 1 decision resolves 1 referral. FK populated when referral is resolved with decision.',
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
) COMMENT 'One row per underwriting decision on a submission or quote. Records accept/decline/refer outcome, risk score, authority level, conditions, exclusions added, modified limits/deductibles, and SLA compliance.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` (
    `uw_referral_id` BIGINT COMMENT 'Unique identifier for the underwriting referral record. Primary key.',
    `agency_id` BIGINT COMMENT 'Identifier of the agency representing the producer who submitted the business.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Referrals are routed to underwriters by line of business expertise and authority limits.',
    `policy_id` BIGINT COMMENT 'Identifier of the policy associated with this referral, if applicable for endorsements or renewals.',
    `primary_uw_assigned_underwriter_party_id` BIGINT COMMENT 'Identifier of the senior underwriter or specialist assigned to review and resolve the referral.',
    `producers_producer_id` BIGINT COMMENT 'Identifier of the agent or broker who submitted the business that triggered the referral.',
    `quote_id` BIGINT COMMENT 'Identifier of the quote that triggered this referral, if applicable.',
    `submission_id` BIGINT COMMENT 'Identifier of the submission that triggered this referral.',
    `term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Referrals occur at renewal (term-specific underwriting review triggered by loss activity, occupancy change, limit increase).',
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
) COMMENT 'One row per underwriting referral. Tracks referral reason, priority, assigned underwriter, escalation level, SLA due date, resolution outcome, and links to submission, quote, and policy for full audit trail.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` (
    `quote_id` BIGINT COMMENT 'Unique identifier for the insurance quote. Primary key.',
    `agency_id` BIGINT COMMENT 'Identifier of the agency through which the quote was submitted.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Quotes are priced with catastrophe load factors based on the risks cat zone. Rating worksheets apply zone-specific surcharges for wind, earthquake, and other cat perils.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Quote rating uses geography for territory assignment, tax jurisdiction determination, and regulatory filing compliance.',
    `household_id` BIGINT COMMENT 'Foreign key linking to party.household. Business justification: Personal lines quoting applies household-level discounts (multi-policy, loyalty, companion policy credits) and aggregates household exposure for pricing.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Quotes are classified by line of business for premium aggregation, loss ratio analysis, and regulatory reporting.',
    `party_id` BIGINT COMMENT 'Identifier of the underwriter who reviewed and approved the quote.',
    `payment_plan_id` BIGINT COMMENT 'Foreign key linking to billing.payment_plan. Business justification: Quotes present payment plan options to applicants with plan-specific premium calculations.',
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
) COMMENT 'One row per quote version. Captures quoted premium, commission, fees, taxes, rating engine version, rating tier, and binding status. Versioned so multiple quote iterations per submission are preserved.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` (
    `quote_coverage_id` BIGINT COMMENT 'Unique identifier for the quote coverage line. Primary key. Grain: one row per coverage per quote.',
    `bound_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Quote coverages become bound policy coverages when a quote is accepted. This lineage link enables tracking quote-to-policy conversion, comparing quoted vs bound terms, and supporting audit',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Premium amounts on quote coverages must reference the currency master for multi-currency rating, financial reporting, and regulatory filings.',
    `fac_agreement_id` BIGINT COMMENT 'Foreign key linking to reinsurance.fac_agreement. Business justification: Facultative reinsurance underwriting decisions are made at the quote_coverage level before binding.',
    `insured_risk_id` BIGINT COMMENT 'Foreign key to the insured risk. Links this coverage to the specific property, vehicle, or other exposure being covered.',
    `peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Each coverage protects against specific perils (wind, earthquake, flood). Underwriters and actuaries need peril-level exposure aggregation for catastrophe modeling and reinsurance',
    `quote_id` BIGINT COMMENT 'Foreign key to the parent quote. Links this coverage line to the quote proposal.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to coverage.rating_worksheet. Business justification: Each coverage line can have its own rating calculation. FK associates coverage with its rating worksheet.',
    `term_id` BIGINT COMMENT 'Foreign key to the coverage form master. Identifies the ISO or proprietary form attached to this coverage line.',
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
) COMMENT 'One row per coverage line on a quote. Captures quoted limit, deductible, premium, exclusion/condition codes, and coverage basis per insured risk. Links to bound coverage.coverage when quote is accepted.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` (
    `rating_factor_id` BIGINT COMMENT 'Unique identifier for the rating factor record.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Rating factors are also applied when rating a bound coverage (e.g., endorsement re-rating, renewal rating).',
    `insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Rating factors are applied to specific insured risks during premium calculation. Underwriters and actuaries need to trace which territory, construction, protection class, and',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Rating factors are defined and filed by line of business for regulatory compliance.',
    `override_user_party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Factor-level overrides (schedule rating, experience mod adjustments) require user attribution for regulatory audit (rate filing compliance), pricing integrity validation, and underwriting',
    `peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Rating factors are often peril-specific (wind deductible credit, earthquake increased limits factor, flood base rate). Peril provides standardized taxonomy for factor application.',
    `quote_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.quote_coverage. Business justification: Rating factors are applied at the coverage-line level during quoting. Linking rating_factor.quote_coverage_id -> quote_coverage.quote_coverage_id provides precise traceability of',
    `quote_id` BIGINT COMMENT 'Foreign key linking to coverage.quote. Business justification: Rating factors are computed during the quoting/pricing process for a specific quote. Linking rating_factor.quote_id -> quote.quote_id establishes the quoting context in which each factor was',
    `submission_id` BIGINT COMMENT 'Foreign key to the parent rating worksheet that contains this factor.',
    `calculation_formula` STRING COMMENT 'Mathematical expression or rule describing how this factor is computed or applied in the rating algorithm.',
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
) COMMENT 'One row per rating factor applied during premium calculation. Records factor name, value, basis, peril, and rating engine version. Supports full rate reconstruction and actuarial audit of any quoted or written premium.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` (
    `loss_history_id` BIGINT COMMENT 'Unique identifier for the prior loss record.',
    `auto_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.auto_risk. Business justification: Auto loss history (collision, comprehensive, liability claims) must link to auto_risk for vehicle-specific and driver-specific rating.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Prior catastrophe losses (catastrophe_flag, catastrophe_code fields exist) link to specific cat events for loss history verification and underwriting surcharge',
    `claim_id` BIGINT COMMENT 'Foreign key to the current claim used to verify the prior loss record.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Prior loss amounts from CLUE/MVR reports and carrier loss runs are denominated in specific currencies.',
    `insured_risk_id` BIGINT COMMENT 'Insured risk (property, vehicle, driver) to which this prior loss applies.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Prior losses are classified by line of business for experience rating and loss development analysis.',
    `location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.location. Business justification: Loss history may trigger or be validated by inspection. FK associates loss with the inspection order that investigated it. Nullable YES (not all losses trigger inspections).',
    `loss_date_calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Loss date is the primary dimension for accident year analysis, loss development triangles, IBNR reserve calculations, and statutory reporting (Schedule P).',
    `party_id` BIGINT COMMENT 'Party (applicant, named insured, driver) associated with this prior loss.',
    `peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Prior losses are categorized by peril (loss_cause_code field exists). Peril provides standardized taxonomy for underwriting evaluation and loss-free year calculation by peril type.',
    `property_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.property_risk. Business justification: Property loss history (roof damage, fire, water damage) must link directly to property_risk for property-specific underwriting rules, inspection triggers, and pricing.',
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

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` (
    `bind_request_id` BIGINT COMMENT 'Unique identifier for the bind request. Primary key. Grain: one row per bind request.',
    `agency_id` BIGINT COMMENT 'Reference to the agency through which the bind request was submitted. Distribution channel tracking.',
    `binder_id` BIGINT COMMENT 'Foreign key linking to coverage.binder. Business justification: Bind request results in a binder being issued when approved. 1 bind_request → 1 binder. FK populated when bind is approved and binder issued.',
    `primary_bind_applicant_party_id` BIGINT COMMENT 'Reference to the party requesting to bind the policy. Primary insured or named insured.',
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

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` (
    `coverage_id` BIGINT COMMENT 'Unique identifier for the coverage. Primary key.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Premium amounts on coverages must be denominated in a specific currency for multi-currency policies, financial reporting, and reinsurance cession calculations.',
    `fac_agreement_id` BIGINT COMMENT 'Foreign key linking to reinsurance.fac_agreement. Business justification: Facultative reinsurance is placed on specific high-value or unusual coverages. Underwriters and reinsurance managers need to track which coverages have facultative protection for',
    `insured_risk_id` BIGINT COMMENT 'Foreign key to the insured risk this coverage protects.',
    `line_id` BIGINT COMMENT 'Foreign key linking to policy.line. Business justification: A coverage belongs to a specific LOB line record. LOB-level premium aggregation, loss ratio reporting, and reinsurance treaty allocation require navigating from coverage to its parent line',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Coverages must link to LOB master for regulatory reporting (Schedule P), reinsurance treaty assignment, loss ratio analysis, and underwriting authority limits.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term this coverage is attached to.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: Coverages are created or modified by specific policy transactions (new business, endorsements, renewals).',
    `prior_coverage_id` BIGINT COMMENT 'Foreign key to the previous version of this coverage, if this is an endorsement or renewal.',
    `reinsurance_treaty_id` BIGINT COMMENT 'Foreign key to the reinsurance treaty covering this coverage, if applicable.',
    `servicing_agency_id` BIGINT COMMENT 'Foreign key linking to producers.agency. Business justification: Tracks the agency of record for in-force coverage, supporting producer servicing assignments, commission calculations on earned premium, policy change routing, and producer performance',
    `servicing_producers_producer_id` BIGINT COMMENT 'Foreign key linking to producers.producers_producer. Business justification: Identifies the individual producer of record for the coverage, enabling producer-level commission allocation, book of business tracking, servicing responsibility assignment, and',
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
) COMMENT 'Grain: one row per coverage per policy term. Each record represents a single coverage attached to a specific policy term and insured risk.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` (
    `limit_id` BIGINT COMMENT 'Unique identifier for the limit record. Primary key.',
    `coverage_id` BIGINT COMMENT 'Foreign key to the coverage to which this limit is attached.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Limit amounts require formal currency reference for multi-currency policies, reinsurance treaty attachment points, and regulatory capital calculations.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this limit is in force.',
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
    `coverage_id` BIGINT COMMENT 'Foreign key to the coverage to which this exclusion is attached.',
    `excluded_party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Named exclusions (excluded driver in personal auto, excluded partner in commercial liability) explicitly identify a specific party to be excluded from coverage.',
    `peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Exclusions reference specific perils (earthquake, flood, wind) by ISO/NAIC codes.',
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

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` (
    `rate_id` BIGINT COMMENT 'Unique identifier for the rate element applied to a coverage during pricing.',
    `coverage_id` BIGINT COMMENT 'Reference to the coverage to which this rate element applies.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Rates are territory-specific; territory_code is denormalized geography reference.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.classification_code. Business justification: Rating requires formal link to classification code master for base rate lookup, hazard group assignment, loss cost retrieval, and regulatory filing compliance.',
    `policy_term_id` BIGINT COMMENT 'Reference to the policy term during which this rate is effective.',
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

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`condition` (
    `condition_id` BIGINT COMMENT 'Represents the condition id value associated with the condition entity in the coverage domain.',
    `condition_policy_transaction_id` BIGINT COMMENT 'Policy transaction (endorsement, new business, renewal) that introduced or last modified this condition.',
    `coverage_id` BIGINT COMMENT 'coverage.coverage.coverage_id',
    `policy_term_id` BIGINT COMMENT 'policy.term.term_id',
    `waived_by_party_id` BIGINT COMMENT 'description',
    `breach_consequence` STRING COMMENT 'description',
    `condition_category` STRING COMMENT 'description',
    `condition_code` STRING COMMENT 'Carrier or ISO form code identifying the standard condition text, e.g. ISO form number or internal code.',
    `compliance_due_date` DATE COMMENT 'Date by which the insured must demonstrate compliance with the condition.',
    `compliance_required` BOOLEAN COMMENT 'description',
    `compliance_required_flag` BOOLEAN COMMENT 'Represents the compliance required flag value associated with the condition entity in the coverage domain.',
    `compliance_verified_date` DATE COMMENT 'Date on which underwriting confirmed the insured satisfied this condition.',
    `compliance_verified_flag` BOOLEAN COMMENT 'Represents the compliance verified flag value associated with the condition entity in the coverage domain.',
    `condition_status` STRING COMMENT 'Represents the condition status value associated with the condition entity in the coverage domain.',
    `condition_type` STRING COMMENT 'Classifies the condition: WARRANTY, CONDITION_PRECEDENT, CONDITION_SUBSEQUENT, SPECIAL_PROVISION, REPORTING_REQUIREMENT, OTHER.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this condition record was first inserted.',
    `condition_description` STRING COMMENT 'Full text or summary of the contractual condition as it appears on the policy form.',
    `effective_date` DATE COMMENT 'Date from which this condition is in force on the coverage. Supports mid-term endorsement of conditions.',
    `expiration_date` DATE COMMENT 'Date on which this condition ceases to apply. Null means the condition runs to the end of the policy term.',
    `form_number` STRING COMMENT 'Represents the form number value associated with the condition entity in the coverage domain.',
    `is_active` BOOLEAN COMMENT 'description',
    `is_mandatory` BOOLEAN COMMENT 'TRUE if the condition is a mandatory statutory or regulatory requirement; FALSE if it is a negotiated or optional provision.',
    `is_satisfied` BOOLEAN COMMENT 'Tracks whether the insured has fulfilled the condition. NULL = not yet evaluated; TRUE = satisfied; FALSE = breached.',
    `iso_condition_code` STRING COMMENT 'description',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Represents the last modified timestamp value associated with the condition entity in the coverage domain.',
    `mandatory_flag` BOOLEAN COMMENT 'Represents the mandatory flag value associated with the condition entity in the coverage domain.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this condition record.',
    `non_compliance_action` STRING COMMENT 'Action taken if condition is not met: CANCEL, ENDORSE, SURCHARGE, NOTIFY, NONE.',
    `notes` STRING COMMENT 'Free-text underwriter or compliance notes about this condition, e.g. reason for imposition or waiver details.',
    `satisfaction_date` DATE COMMENT 'Date on which the condition was confirmed satisfied or breached. Null until evaluated.',
    `source_form_number` STRING COMMENT 'Represents the source form number value associated with the condition entity in the coverage domain.',
    `source_system_code` STRING COMMENT 'Code identifying the originating system of record for this condition row.',
    `source_system_condition_ref` STRING COMMENT 'Represents the source system condition ref value associated with the condition entity in the coverage domain.',
    `text` STRING COMMENT 'Full policy language or manuscript wording of the condition as it appears in the contract.',
    `type_code` STRING COMMENT 'Classifies the condition: WARRANTY, CONDITION_PRECEDENT, SPECIAL_CONDITION, REPORTING_REQUIREMENT, OTHER.',
    `underwriter_notes` STRING COMMENT 'Represents the underwriter notes value associated with the condition entity in the coverage domain.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp of the most recent update to this condition record.',
    `waiver_reason` STRING COMMENT 'Free-text reason recorded when condition_status is WAIVED; NULL otherwise.',
    `waiver_reason_code` STRING COMMENT 'Represents the waiver reason code value associated with the condition entity in the coverage domain.',
    CONSTRAINT pk_condition PRIMARY KEY(`condition_id`)
) COMMENT 'One row per contract Condition per Coverage. Attaches named Conditions to a Coverage and Policy Term, completing the VREQ-004 quartet alongside Limit, Deductible, and Exclusion.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ADD CONSTRAINT `fk_coverage_uw_decision_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ADD CONSTRAINT `fk_coverage_uw_decision_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ADD CONSTRAINT `fk_coverage_uw_decision_uw_referral_id` FOREIGN KEY (`uw_referral_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral`(`uw_referral_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ADD CONSTRAINT `fk_coverage_uw_referral_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ADD CONSTRAINT `fk_coverage_uw_referral_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ADD CONSTRAINT `fk_coverage_quote_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ADD CONSTRAINT `fk_coverage_quote_coverage_bound_coverage_id` FOREIGN KEY (`bound_coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ADD CONSTRAINT `fk_coverage_quote_coverage_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ADD CONSTRAINT `fk_coverage_quote_coverage_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ADD CONSTRAINT `fk_coverage_rating_factor_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ADD CONSTRAINT `fk_coverage_rating_factor_quote_coverage_id` FOREIGN KEY (`quote_coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage`(`quote_coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ADD CONSTRAINT `fk_coverage_rating_factor_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ADD CONSTRAINT `fk_coverage_rating_factor_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ADD CONSTRAINT `fk_coverage_bind_request_binder_id` FOREIGN KEY (`binder_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`binder`(`binder_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ADD CONSTRAINT `fk_coverage_bind_request_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ADD CONSTRAINT `fk_coverage_bind_request_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ADD CONSTRAINT `fk_coverage_bind_request_uw_decision_id` FOREIGN KEY (`uw_decision_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision`(`uw_decision_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_uw_decision_id` FOREIGN KEY (`uw_decision_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision`(`uw_decision_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_prior_coverage_id` FOREIGN KEY (`prior_coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ADD CONSTRAINT `fk_coverage_limit_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ADD CONSTRAINT `fk_coverage_deductible_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ADD CONSTRAINT `fk_coverage_exclusion_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ADD CONSTRAINT `fk_coverage_exclusion_superseded_by_exclusion_id` FOREIGN KEY (`superseded_by_exclusion_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion`(`exclusion_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ADD CONSTRAINT `fk_coverage_rate_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`condition` ADD CONSTRAINT `fk_coverage_condition_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`coverage` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`coverage` SET TAGS ('dbx_domain' = 'coverage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ALTER COLUMN `household_id` SET TAGS ('dbx_business_glossary_term' = 'Household Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `uw_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `primary_uw_approved_by_party_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Party Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `tertiary_uw_referred_to_underwriter_party_id` SET TAGS ('dbx_business_glossary_term' = 'Referred To Underwriter (UW) Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ALTER COLUMN `uw_referral_id` SET TAGS ('dbx_business_glossary_term' = 'Uw Referral Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `primary_uw_assigned_underwriter_party_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Underwriter (UW) Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ALTER COLUMN `term_id` SET TAGS ('dbx_business_glossary_term' = 'Term Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `household_id` SET TAGS ('dbx_business_glossary_term' = 'Household Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ALTER COLUMN `payment_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `fac_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Fac Agreement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Rating Worksheet Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ALTER COLUMN `term_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Identifier (ID)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `rating_factor_id` SET TAGS ('dbx_business_glossary_term' = 'Rating Factor Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `override_user_party_id` SET TAGS ('dbx_business_glossary_term' = 'Override User Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `quote_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Rating Worksheet Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ALTER COLUMN `calculation_formula` SET TAGS ('dbx_business_glossary_term' = 'Calculation Formula');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `loss_history_id` SET TAGS ('dbx_business_glossary_term' = 'Loss History ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `auto_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Auto Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Loss History Verification - Claim Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `location_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Order Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `loss_date_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Date Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ALTER COLUMN `property_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Property Risk Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` SET TAGS ('dbx_subdomain' = 'underwriting_evaluation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `bind_request_id` SET TAGS ('dbx_business_glossary_term' = 'Bind Request Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `binder_id` SET TAGS ('dbx_business_glossary_term' = 'Binder Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ALTER COLUMN `primary_bind_applicant_party_id` SET TAGS ('dbx_business_glossary_term' = 'Applicant Party Identifier (ID)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` SET TAGS ('dbx_subdomain' = 'contract_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Currency Code (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `fac_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Fac Agreement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `line_id` SET TAGS ('dbx_business_glossary_term' = 'Line Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `prior_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `reinsurance_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `servicing_agency_id` SET TAGS ('dbx_business_glossary_term' = 'Servicing Agency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ALTER COLUMN `servicing_producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Servicing Producers Producer Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` SET TAGS ('dbx_subdomain' = 'contract_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `limit_id` SET TAGS ('dbx_business_glossary_term' = 'Limit Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` SET TAGS ('dbx_subdomain' = 'contract_terms');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` SET TAGS ('dbx_subdomain' = 'contract_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `exclusion_id` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `excluded_party_id` SET TAGS ('dbx_business_glossary_term' = 'Excluded Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ALTER COLUMN `peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` SET TAGS ('dbx_subdomain' = 'contract_terms');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `rate_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Classification Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
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
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`condition` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`condition` SET TAGS ('dbx_subdomain' = 'contract_terms');
